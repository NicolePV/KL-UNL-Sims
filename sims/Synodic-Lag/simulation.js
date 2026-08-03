/* ==========================================================================
   Synodic Lag Demonstrator
   HTML5 port of synodiclag.swf (Adobe Flash / ActionScript 1).

   Earth orbits the Sun counter-clockwise while spinning counter-clockwise on
   its axis. A SIDEREAL day is one full 360 degree rotation with respect to the
   stars; a SOLAR (synodic) day is one full rotation with respect to the Sun.
   Because Earth also moves along its orbit, the solar day is the longer of the
   two, and the gap between them is the "synodic lag" the readout reports as the
   angle to noon.

   All physics below is a direct transcription of the decompiled frame script.
   Angles are in DEGREES and one unit of `time` is one year, exactly as in the
   original. Screen geometry keeps the original Flash stage coordinates (Sun at
   150, 150; orbital radius 125); CSS scales the canvas element.
   ========================================================================== */

(function () {
  'use strict';

  /* ------------------------------------------------------------------ */
  /* Constants -- verbatim from the ActionScript frame script            */
  /* ------------------------------------------------------------------ */

  var X0 = 150;                 // var x0 = 150;   Sun / orbit centre, stage x
  var Y0 = 150;                 // var y0 = 150;   Sun / orbit centre, stage y
  var R0 = 125;                 // var r0 = 125;   orbital radius, stage px
  var YEAR = 8766.15271;        // var year = 8766.15271;   hours in a year

  var SHADOW_ALPHA = 0.25;      // earthShadow._alpha = 25;

  // onEnterFrameFunc: time += (getTimer() - timeLast) / 1000 / 50 / delay
  // i.e. one year of simulated time takes 50 * delay seconds of wall-clock time.
  var SECONDS_PER_YEAR = 50;

  var MODE_IDLE = 0;            // var mode = 0;
  var MODE_SIDEREAL = 1;        // animateSidereal sets mode = 1
  var MODE_SYNODIC = 2;         // animateSynodic  sets mode = 2

  /* ------------------------------------------------------------------ */
  /* Reused exported art                                                 */
  /*                                                                     */
  /* Every visual element in this sim is an exported vector shape, so all */
  /* four are reused as-is from the JPEXS export rather than redrawn. The */
  /* registration point of each shape sits at the offset FFDec baked into */
  /* the SVG's own <g transform>, recorded here as regX / regY.           */
  /* ------------------------------------------------------------------ */

  var ART = {
    // shapes/101.svg -- orbit path circle. Placed at (150.4, 150), scaled 1.25.
    orbit: { src: 'assets/shapes/101.svg', w: 200.95, h: 201, regX: 100.8, regY: 100.5,
             x: 150.4, y: 150, sx: 1.2503052, sy: 1.2499847 },
    // shapes/105.svg -- Sun-to-Earth line. Placed at (150, 150), scaled in x only.
    line:  { src: 'assets/shapes/105.svg', w: 131, h: 1, regX: 0.5, regY: 0.5,
             x: 150, y: 150, sx: 0.88461304, sy: 1 },
    // shapes/91.svg -- the Sun. Placed at (150, 150).
    sun:   { src: 'assets/shapes/91.svg', w: 30, h: 30, regX: 15, regY: 15,
             x: 150, y: 150, sx: 1, sy: 1 },
    // shapes/99.svg -- Earth: blue disc, three short tick marks, and the long
    // tick that marks the local meridian (it points at the Sun at noon).
    earth: { src: 'assets/shapes/99.svg', w: 41, h: 31, regX: 25.5, regY: 15.5,
             x: 0, y: 0, sx: 1, sy: 1 }
  };

  /* ------------------------------------------------------------------ */
  /* State -- the single source of truth. render() redraws everything    */
  /* from here after every action.                                       */
  /* ------------------------------------------------------------------ */

  var state = {
    theta: 0,        // var theta  = 0;  Earth's orbital angle, degrees
    theta0: 0,       // var theta0 = 0;  orbital angle at the start of the run
    phi: 0,          // var phi    = 0;  Earth's rotation angle, degrees
    phi0: 0,         // var phi0   = 0;  rotation angle at the start of the run
    mode: MODE_IDLE, // var mode   = 0;
    time: 0,         // var time;        elapsed simulated time, in years
    timeLast: 0,     // var timeLast = getTimer();
    running: false,  // onEnterFrame == onEnterFrameFunc
    paused: false,   // added for WCAG 2.2.2; not part of the original
    day: 240,        // factorGroup.getValue(); default radio is "240 hours"
    delay: 1,        // delayGroup.getValue();  default radio is "fast"
    shadow: true,    // shadowButton initialValue = true
    // earthShadow is a duplicate of the Earth clip, parked wherever Earth
    // stood when the current run began.
    shadowX: 0,
    shadowY: 0,
    shadowRot: 0
  };

  var el = {};
  var ctx = null;
  var images = {};
  var rafId = null;

  var reducedMotion = window.matchMedia
    ? window.matchMedia('(prefers-reduced-motion: reduce)')
    : { matches: false };

  /* ------------------------------------------------------------------ */
  /* Number formatting                                                   */
  /*                                                                     */
  /* The SWF ships its own Number.prototype.toFixed polyfill (AS1 has no  */
  /* native toFixed). It is reproduced here so the readout rounds exactly */
  /* the way the original did, including at .005 ties.                    */
  /* ------------------------------------------------------------------ */

  function asToFixed(value, fractionDigits) {
    var digits = fractionDigits | 0;
    if (digits < 0 || digits > 20) { return 'Range Error'; }

    var x = value;
    if (isNaN(x)) { return 'NaN'; }

    var sign = '';
    if (x < 0) { sign = '-'; x = -x; }

    var out = '';
    if (x < 1e21) {
      var n = Math.round(x * Math.pow(10, digits));
      out = (n === 0) ? '0' : n.toString();

      if (digits > 0) {
        var k = out.length;
        if (k <= digits) {
          var zeros = '';
          for (var i = 0; i < digits + 1 - k; i++) { zeros += '0'; }
          out = zeros + out;
          k = digits + 1;
        }
        out = out.substr(0, k - digits) + '.' + out.substr(k - digits);
      }
    } else {
      out = x.toString();
    }
    return sign + out;
  }

  /* ------------------------------------------------------------------ */
  /* Ported physics                                                      */
  /* ------------------------------------------------------------------ */

  // function setposition(object, theta)
  //   object._x = r0 * Math.cos(theta) + x0
  //   object._y = -r0 * Math.sin(theta) + y0
  // Note the negated sine: Flash's y axis points down, so this is a standard
  // counter-clockwise orbit as seen on screen.
  function setPosition(thetaDeg) {
    var rad = thetaDeg * Math.PI / 180;
    return {
      x: R0 * Math.cos(rad) + X0,
      y: -R0 * Math.sin(rad) + Y0
    };
  }

  // function update(time)
  //   revRate  = 360                 degrees of orbit per year
  //   spinRate = 360 * year / day    degrees of rotation per year
  // A sidereal day ends when Earth has spun 360 degrees; a solar day ends when
  // it has spun 360 degrees MORE than it has revolved.
  function update(t) {
    var day = state.day;
    var revRate = 360;
    var spinRate = 360 * YEAR / day;
    var reachedEnd = false;

    if (state.mode === MODE_SIDEREAL && t > 360 / spinRate) {
      t = 360 / spinRate;
      reachedEnd = true;
    } else if (state.mode === MODE_SYNODIC && t > 360 / (spinRate - revRate)) {
      t = 360 / (spinRate - revRate);
      reachedEnd = true;
    }

    state.theta = revRate * t + state.theta0;
    state.phi = spinRate * t + state.phi0;

    if (reachedEnd) { stopAnimation(); }

    render();
    return reachedEnd;
  }

  // function updatetext()
  //   angle = phi % 360 - theta % 360; if (angle < 0) angle += 360;
  //   if (angle == 360) angle = 0;
  // This is the angle between Earth's meridian marker and the Sun direction --
  // how far past (or short of) local noon the marker currently is.
  function angleToNoon() {
    var angle = (state.phi % 360) - (state.theta % 360);
    if (angle < 0) { angle = 360 + angle; }
    if (angle === 360) { angle = 0; }
    return angle;
  }

  function angleText() {
    return asToFixed(angleToNoon(), 2);
  }

  // function animateSidereal() / animateSynodic()
  // Both park the shadow at Earth's current spot, zero the clock, set the mode,
  // start the enter-frame loop and disable the controls that must not change
  // mid-run.
  function startAnimation(mode) {
    if (state.running) { return; }

    var pos = setPosition(state.theta);
    state.shadowX = pos.x;
    state.shadowY = pos.y;
    state.shadowRot = -state.phi;

    state.time = 0;
    state.timeLast = performance.now();
    state.mode = mode;
    state.running = true;
    state.paused = false;

    disableButtons();

    var label = (mode === MODE_SIDEREAL) ? 'one sidereal day' : 'one solar day';

    if (reducedMotion.matches) {
      // Same end state, reached instantly (WCAG 2.3.3). The physics is
      // untouched: update() clamps the time to the end of the run exactly as it
      // would have on the final animated frame.
      update(Number.MAX_VALUE);
      announce(label + ' complete. Angle to noon ' + angleText() + ' degrees.');
      return;
    }

    announce('Animating ' + label + '. Length of day ' + state.day + ' hours.');
    rafId = requestAnimationFrame(tick);
  }

  // function onEnterFrameFunc()
  //   time += (getTimer() - timeLast) / 1000 / 50 / delayGroup.getValue()
  // Elapsed wall-clock time drives the clock, not a frame count, so the run
  // takes the same number of seconds on any machine.
  function tick(now) {
    if (!state.running || state.paused) { return; }

    state.time += (now - state.timeLast) / 1000 / SECONDS_PER_YEAR / state.delay;
    state.timeLast = now;

    var finished = update(state.time);

    if (finished) {
      rafId = null;
      var label = (state.mode === MODE_SIDEREAL) ? 'one sidereal day' : 'one solar day';
      announce(label + ' complete. Angle to noon ' + angleText() + ' degrees.');
    } else {
      rafId = requestAnimationFrame(tick);
    }
  }

  // function stopAnimation()
  // Freezes the run by carrying the current angles into theta0 / phi0, so the
  // next run continues from exactly where this one ended.
  function stopAnimation() {
    if (!state.running) { return; }
    state.theta0 = state.theta;
    state.phi0 = state.phi;
    state.running = false;
    state.paused = false;
    if (rafId !== null) { cancelAnimationFrame(rafId); rafId = null; }
    enableButtons();
  }

  // function toggleNoon()
  // Snaps Earth's rotation so the meridian marker faces the Sun again, keeping
  // the whole number of rotations it has already completed.
  function toggleNoon() {
    state.phi0 = state.theta0 + Math.floor(state.phi0 / 360) * 360;
    state.theta = state.theta0;
    state.phi = state.phi0;
    render();
    announce('Realigned to noon. Angle to noon ' + angleText() + ' degrees.');
  }

  // function disableButtons() / enableButtons()
  // The original disables the three push buttons and the length-of-day radio
  // group during a run; the animation-speed radios and the shadow checkbox stay
  // live, and changing the speed mid-run takes effect immediately.
  function disableButtons() {
    el.btnSidereal.disabled = true;
    el.btnSynodic.disabled = true;
    el.btnNoon.disabled = true;
    el.fsLength.disabled = true;
    el.btnPause.disabled = reducedMotion.matches;
  }

  function enableButtons() {
    el.btnSidereal.disabled = false;
    el.btnSynodic.disabled = false;
    el.btnNoon.disabled = false;
    el.fsLength.disabled = false;
    el.btnPause.disabled = true;
    el.btnPause.textContent = 'Pause';
  }

  // Added control (not in the original): a run at 1200 hours / slow lasts well
  // over five seconds, which WCAG 2.2.2 requires the user to be able to stop.
  // Pausing only suspends the clock; no state or physics is altered.
  function togglePause() {
    if (!state.running) { return; }

    if (state.paused) {
      state.paused = false;
      state.timeLast = performance.now();
      el.btnPause.textContent = 'Pause';
      rafId = requestAnimationFrame(tick);
      announce('Animation resumed.');
    } else {
      state.paused = true;
      if (rafId !== null) { cancelAnimationFrame(rafId); rafId = null; }
      el.btnPause.textContent = 'Resume';
      announce('Animation paused. Angle to noon ' + angleText() + ' degrees.');
    }
  }

  // function init()
  //   time = 0; update();
  //   earthShadow._x = earth._x; earthShadow._y = earth._y;
  //   earthShadow._rotation = earth._rotation;
  // (The SWF targets Flash 6, where the missing argument to update() coerces to
  // zero, so the sim opens with theta = phi = 0.)
  function init() {
    stopAnimation();
    state.theta = 0;
    state.theta0 = 0;
    state.phi = 0;
    state.phi0 = 0;
    state.mode = MODE_IDLE;
    state.time = 0;
    state.running = false;
    state.paused = false;
    state.day = 240;
    state.delay = 1;
    state.shadow = true;

    var pos = setPosition(state.theta);
    state.shadowX = pos.x;
    state.shadowY = pos.y;
    state.shadowRot = -state.phi;

    // Sync the DOM controls back to the initial state.
    el.day240.checked = true;
    el.speedFast.checked = true;
    el.shadowBox.checked = true;
    enableButtons();

    render();
  }

  /* ------------------------------------------------------------------ */
  /* Rendering                                                           */
  /* ------------------------------------------------------------------ */

  function sizeCanvas() {
    var dpr = Math.min(window.devicePixelRatio || 1, 3);
    var w = 300, h = 300;
    if (el.canvas.width !== Math.round(w * dpr)) {
      el.canvas.width = Math.round(w * dpr);
      el.canvas.height = Math.round(h * dpr);
    }
    ctx.setTransform(el.canvas.width / w, 0, 0, el.canvas.height / h, 0, 0);
  }

  // Draws one exported shape at Flash's placement: translate to the placement
  // point, apply _rotation (degrees, clockwise on screen), apply the scale, then
  // offset by the shape's registration point.
  function drawArt(art, x, y, rotationDeg, alpha) {
    var img = images[art.src];
    if (!img) { return; }

    ctx.save();
    ctx.globalAlpha = (alpha === undefined) ? 1 : alpha;
    ctx.translate(x, y);
    ctx.rotate(rotationDeg * Math.PI / 180);
    ctx.scale(art.sx, art.sy);
    ctx.drawImage(img, -art.regX, -art.regY, art.w, art.h);
    ctx.restore();
  }

  // Single render pass: canvas, DOM readout and the screen-reader description
  // are all rebuilt from `state`, so they can never drift apart.
  function render() {
    if (!ctx) { return; }

    sizeCanvas();
    // Left transparent so the panel's own --background-color shows through
    // rather than a hardcoded stage colour.
    ctx.clearRect(0, 0, 300, 300);

    var pos = setPosition(state.theta);

    // Depth order from the SWF, bottom to top:
    // orbit path (1), line (12), earthShadow (50), sun (59), earth (100).
    drawArt(ART.orbit, ART.orbit.x, ART.orbit.y, 0, 1);
    drawArt(ART.line, ART.line.x, ART.line.y, -state.theta, 1);

    if (state.shadow) {
      drawArt(ART.earth, state.shadowX, state.shadowY, state.shadowRot, SHADOW_ALPHA);
    }

    drawArt(ART.sun, ART.sun.x, ART.sun.y, 0, 1);
    drawArt(ART.earth, pos.x, pos.y, -state.phi, 1);

    updateReadout();
    updateDescription(pos);
  }

  /* ------------------------------------------------------------------ */
  /* MathJax readout                                                     */
  /*                                                                     */
  /* The degree symbol is mathematical notation, so the readout is real   */
  /* HTML typeset by MathJax (never painted on the canvas) and carries a   */
  /* paired spoken description. Typesetting is coalesced so a 60 Hz run    */
  /* does not queue up work faster than MathJax can retire it; the final   */
  /* value of every run is always typeset.                                */
  /* ------------------------------------------------------------------ */

  var TYPESET_INTERVAL_MS = 100;   // ~10 readout updates a second while running

  // MathJax stamps tabindex="0" on the container it emits, which would put a
  // display-only readout in the Tab order. Strip it as soon as each typeset
  // lands. Right-click still opens MathJax's own "Show Math As" menu, and the
  // value stays readable to screen readers via #angle-eqn-sr.
  // The :not() guard matters: setAttribute queues a mutation record even when
  // the value is unchanged, so re-stamping an already-fixed container would
  // retrigger the observer below in an endless loop.
  function unfocusMath(root) {
    var containers = root.querySelectorAll('mjx-container[tabindex]:not([tabindex="-1"])');
    for (var i = 0; i < containers.length; i++) {
      containers[i].setAttribute('tabindex', '-1');
    }
  }

  function watchMathTabOrder() {
    var host = document.getElementById('angle-eqn');
    if (!host || !window.MutationObserver) { return; }
    unfocusMath(host);
    new MutationObserver(function () { unfocusMath(host); })
      .observe(host, { childList: true, subtree: true, attributeFilter: ['tabindex'] });
  }

  var shownAngle = null;
  var lastTypesetAt = 0;
  var trailingTimer = null;

  function updateReadout() {
    var text = angleText();
    if (text === shownAngle) { return; }

    // While a run is in flight, cap how often MathJax is asked to re-typeset so
    // a 60 Hz loop cannot queue work faster than it retires. The value shown
    // when the run stops is always typeset, because stopAnimation() clears
    // state.running before the final render().
    if (state.running && !state.paused) {
      var now = performance.now();
      if (now - lastTypesetAt < TYPESET_INTERVAL_MS) {
        if (trailingTimer === null) {
          trailingTimer = setTimeout(function () {
            trailingTimer = null;
            updateReadout();
          }, TYPESET_INTERVAL_MS);
        }
        return;
      }
      lastTypesetAt = now;
    }

    shownAngle = text;

    klunlShowEquation(
      ['angle-eqn', '\\(' + text + '^\\circ\\)'],
      ['angle-eqn-sr', 'angle to noon ' + text + ' degrees']
    );
  }

  // Continuously-updated text equivalent of the canvas, so an audio-only user
  // gets the same "what's happening" a sighted user sees. Every number is
  // announced with its quantity name and its unit.
  function updateDescription(pos) {
    var orbital = asToFixed(state.theta % 360, 2);
    var text =
      'Diagram: the Sun sits at the centre of a circular orbit. ' +
      'Earth is at orbital angle ' + orbital + ' degrees, measured ' +
      'counter-clockwise from the right-hand side of the orbit. ' +
      'Earth\'s meridian marker is ' + angleText() + ' degrees past pointing ' +
      'at the Sun, so the angle to noon is ' + angleText() + ' degrees. ' +
      'Length of day ' + state.day + ' hours. ' +
      'Animation speed ' + (state.delay === 1 ? 'fast' : 'slow') + '. ' +
      'Starting-position shadow ' + (state.shadow ? 'shown' : 'hidden') + '.';

    if (el.desc.textContent !== text) { el.desc.textContent = text; }
  }

  function announce(message) {
    el.status.textContent = message;
  }

  /* ------------------------------------------------------------------ */
  /* Wiring                                                              */
  /* ------------------------------------------------------------------ */

  function cacheElements() {
    el.canvas = document.getElementById('stage');
    el.status = document.getElementById('sr-status');
    el.desc = document.getElementById('diagram-desc');
    el.btnSidereal = document.getElementById('btn-sidereal');
    el.btnSynodic = document.getElementById('btn-synodic');
    el.btnNoon = document.getElementById('btn-noon');
    el.btnPause = document.getElementById('btn-pause');
    el.fsLength = document.getElementById('fs-length');
    el.day24 = document.getElementById('day-24');
    el.day240 = document.getElementById('day-240');
    el.day1200 = document.getElementById('day-1200');
    el.speedFast = document.getElementById('speed-fast');
    el.speedSlow = document.getElementById('speed-slow');
    el.shadowBox = document.getElementById('shadow');
  }

  function wire() {
    el.btnSidereal.addEventListener('click', function () {
      startAnimation(MODE_SIDEREAL);
    });

    el.btnSynodic.addEventListener('click', function () {
      startAnimation(MODE_SYNODIC);
    });

    el.btnNoon.addEventListener('click', toggleNoon);
    el.btnPause.addEventListener('click', togglePause);

    // factorGroup.getValue() -- length of day, in hours
    [el.day24, el.day240, el.day1200].forEach(function (radio) {
      radio.addEventListener('change', function () {
        if (!radio.checked) { return; }
        state.day = Number(radio.value);
        render();
        announce('Length of day ' + state.day + ' hours.');
      });
    });

    // delayGroup.getValue() -- 1 for fast, 10 for slow. Read every frame in the
    // original, so a change mid-run takes effect immediately.
    [el.speedFast, el.speedSlow].forEach(function (radio) {
      radio.addEventListener('change', function () {
        if (!radio.checked) { return; }
        state.delay = Number(radio.value);
        announce('Animation speed ' + (state.delay === 1 ? 'fast' : 'slow') + '.');
      });
    });

    // function showShadow()
    el.shadowBox.addEventListener('change', function () {
      state.shadow = el.shadowBox.checked;
      render();
      announce('Starting-position shadow ' + (state.shadow ? 'shown.' : 'hidden.'));
    });

    // The masthead component owns Reset; it dispatches a bubbling, composed
    // "sim-reset" event. There is no second Reset button in the sim itself.
    document.addEventListener('sim-reset', function () {
      init();
      announce('Simulation reset. Angle to noon ' + angleText() +
               ' degrees. Length of day ' + state.day + ' hours. ' +
               'Animation speed fast. Starting-position shadow shown.');
    });

    // Keep the backing store matched to the device pixel ratio if the window
    // moves between displays or the user zooms.
    window.addEventListener('resize', render);

    if (reducedMotion.addEventListener) {
      reducedMotion.addEventListener('change', function () {
        el.btnPause.disabled = !state.running || reducedMotion.matches;
      });
    }
  }

  function loadArt() {
    var sources = Object.keys(ART).map(function (key) { return ART[key].src; });
    var unique = sources.filter(function (src, i) { return sources.indexOf(src) === i; });

    return Promise.all(unique.map(function (src) {
      return new Promise(function (resolve) {
        var img = new Image();
        img.onload = function () { images[src] = img; resolve(); };
        img.onerror = function () {
          console.error('Synodic Lag: could not load exported shape ' + src);
          resolve();
        };
        img.src = src;
      });
    }));
  }

  /* ------------------------------------------------------------------ */
  /* Boot                                                                */
  /*                                                                     */
  /* kl-unl.js defines klunlInitEqn() as a stub and expects the sim to    */
  /* redefine it; that redefinition is the sim's entry point.             */
  /* ------------------------------------------------------------------ */

  window.klunlInitEqn = function () {
    cacheElements();
    ctx = el.canvas.getContext('2d');
    wire();
    watchMathTabOrder();
    init();
    loadArt().then(render);
  };

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', function () { klunlInitEqn(); });
  } else {
    klunlInitEqn();
  }
})();
