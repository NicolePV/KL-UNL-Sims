/* ============================================================================
   Tidal Bulge Simulator  --  HTML5 / KL-UNL port of tidesim.swf
   ----------------------------------------------------------------------------
   Behaviour is ported verbatim from the decompiled ActionScript 1 (earth.as,
   moon.as, tideAnim.as, tidalBulge.as and the frame_1 handlers). The original
   is a top-down diagram: the Moon orbits the Earth, the Earth's oceanic tidal
   bulges point along the Earth-Moon line, and (optionally) the Sun adds
   day/night shading plus a spring/neap variation in the bulge shape.

   AS -> JS mapping (see CONVERSION_NOTES.md for the full table):
     * getTimer()  -> performance.now()
     * onEnterFrame -> a single requestAnimationFrame loop, using elapsed
       wall-clock time (NOT frame counts) so timing matches across machines.
     * one plain state object + one render() that redraws the canvas and syncs
       the DOM / live region after every change.

   There is no draggable/rotatable object and no numeric field in this sim, so
   every control is a native, fully keyboard-accessible <input type="checkbox">.
   There is no on-screen mathematics, so MathJax is not required here.
   ============================================================================ */

(function () {
  'use strict';

  // ---- Original stage geometry (kept as the internal coordinate system) -----
  // Measured from the decompiled stage render (600 x 550 Flash stage).
  var STAGE_W = 600;
  var STAGE_H = 550;

  var EARTH_CX = 277;          // Earth centre on the stage
  var EARTH_CY = 277;
  var EARTH_R  = 38;           // Earth sphere drawn radius (diameter ~76 px)

  var MOON_ORBIT_R = 251;      // Moon centre distance from Earth centre
  var MOON_R = 25;             // Moon drawn radius (diameter ~50 px)

  // The blue tidal-bulge ellipse. In the SWF the bulge is a 360-frame tween of
  // one ellipse whose width/height vary. Natural (tidalBulge symbol) pixel sizes
  // map to on-stage pixels through these factors (derived from the composite):
  //   stageDiameter = naturalDiameter * factor   (then /2 for a semi-axis)
  var BULGE_XS = 0.6076;       // horizontal factor
  var BULGE_YS = 0.688;        // vertical factor
  var BULGE_COLOR = '#6699ff'; // AS fill 0x6699FF, measured (102,153,255)

  // Earth's-rotation lead (tideAnimClass: this._offset = 20).
  var OFFSET_DEG = 20;

  // Timing. moon._speed starts at 510000 and tideAnimClass divides it by the
  // tideAnim _speed of 10  ->  51000 ms for one full orbit.
  var ORBIT_MS = 510000 / 10;  // 51000

  // earth._time = _tideTime * 28  ->  Earth spins 28x per lunar orbit.
  var EARTH_SPIN_MULT = 28;

  var DEG = Math.PI / 180;

  // ---- Single source of truth: the state object ----------------------------
  function initialState() {
    return {
      running: false,      // "Run"  (mySim.animate / playBox)
      withSun: false,      // "Include Sun"  (mySim._withSun / sunBox)
      earthEffects: false, // "Include Effects of Earth's Rotation" (earthBox)
      angleDeg: 0          // Moon orbital phase phi, degrees [0,360)  (moon._angle)
    };
  }
  var state = initialState();

  // ---- DOM + assets --------------------------------------------------------
  var canvas, ctx, dpr = 1;
  var runCb, sunCb, earthCb, srStatus;
  var img = {};            // loaded bitmaps
  var lastTime = null;     // performance.now() of previous frame (getTimer())
  var lastQuadrant = null; // for throttled screen-reader progress

  function loadImages(done) {
    var sources = {
      earth:      'assets/earth.png',       // sphere + continents (myEarth)
      earthShadow:'assets/earth-shadow.png',// night-side terminator overlay
      moon:       'assets/moon.png',        // plain Moon sphere
      moonLit:    'assets/moon-lit.png'     // Moon with sunlit hemisphere
    };
    var keys = Object.keys(sources), pending = keys.length;
    keys.forEach(function (k) {
      var im = new Image();
      im.onload = im.onerror = function () { if (--pending === 0) done(); };
      im.src = sources[k];
      img[k] = im;
    });
  }

  // ---- Canvas sizing (backing store scaled for crispness; CSS scales down) --
  function sizeCanvas() {
    dpr = Math.max(1, window.devicePixelRatio || 1);
    canvas.width  = Math.round(STAGE_W * dpr);
    canvas.height = Math.round(STAGE_H * dpr);
    // Drawing code always works in original 600x550 stage coordinates.
    ctx.setTransform(dpr, 0, 0, dpr, 0, 0);
  }

  // ---- Bulge shape ---------------------------------------------------------
  // Natural (symbol) width/height of the bulge ellipse for phase phi.
  // Sun OFF  -> the original does gotoAndStop(1): a fixed lunar-only ellipse.
  // Sun ON   -> gotoAndStop(round(phi)): the ellipse is most elongated at
  //             phi = 0/180 (spring, Moon in line with the Sun) and roundest at
  //             phi = 90/270 (neap). Calibrated to the measured frame envelope
  //             (W 150..180, H 111..125) with a cos(2*phi) variation.
  function bulgeNatural(phi, withSun) {
    if (!withSun) return { w: 170, h: 111 };          // frame 1
    var c = Math.cos(2 * phi * DEG);
    return { w: 165 + 15 * c, h: 118 - 7 * c };
  }

  // ---- The ported per-frame logic (tideAnimClass.onEnterFrame) -------------
  // Advance the Moon's orbital phase by elapsed wall-clock time.
  function advance(dtMs) {
    if (!state.running) return;
    // moon.as:  da = (dt) * 2*PI / _speed ; _angle += da ; wrap at 2*PI.
    var dDeg = dtMs * 360 / ORBIT_MS;
    state.angleDeg += dDeg;
    if (state.angleDeg >= 360) state.angleDeg -= 360 * Math.floor(state.angleDeg / 360);
  }

  // Derived quantities, exactly as tideAnimClass computes them.
  function derived() {
    var phi = state.angleDeg;                 // moon._angle in degrees
    var tideTime = 360 - phi;                 // earth._tideTime = 360 - deg(angle)
    // Bulge rotation: earth.rotateTide(tideTime) or (tideTime - offset).
    var bulgeRot = state.earthEffects ? (tideTime - OFFSET_DEG) : tideTime;
    // Earth spin: earth._time = _tideTime * 28.
    var earthSpin = (tideTime * EARTH_SPIN_MULT) % 360;
    return { phi: phi, tideTime: tideTime, bulgeRot: bulgeRot, earthSpin: earthSpin };
  }

  // ---- Render (single redraw of everything from state) ---------------------
  function render() {
    var d = derived();
    ctx.clearRect(0, 0, STAGE_W, STAGE_H);

    // 1) Tidal bulge ellipse (drawn first, behind the Earth sphere).
    var bn = bulgeNatural(d.phi, state.withSun);
    var a = bn.w * BULGE_XS / 2;   // semi-major (along Earth-Moon line)
    var b = bn.h * BULGE_YS / 2;   // semi-minor
    ctx.save();
    ctx.translate(EARTH_CX, EARTH_CY);
    ctx.rotate(d.bulgeRot * DEG);  // Flash _rotation: clockwise, y-down == canvas
    ctx.beginPath();
    ctx.ellipse(0, 0, a, b, 0, 0, 2 * Math.PI);
    ctx.fillStyle = BULGE_COLOR;
    ctx.fill();
    ctx.restore();

    // 2) Earth sphere + continents (myEarth), spinning when animated.
    drawSprite(img.earth, EARTH_CX, EARTH_CY, EARTH_R * 2, EARTH_R * 2, d.earthSpin);

    // 3) Earth day/night shadow on the night (left) side -- only with the Sun.
    //    myShadow is toggled visible, never rotated: it stays on the side away
    //    from the Sun while the continents rotate underneath.
    if (state.withSun) {
      var shW = EARTH_R * 2 * (88 / 166);  // shadow image is 88x166, sized to sphere
      var shH = EARTH_R * 2;
      // Right edge of the terminator sits at the Earth centre (+ small nudge).
      ctx.drawImage(img.earthShadow, EARTH_CX - shW + 3, EARTH_CY - shH / 2, shW, shH);
    }

    // 4) Moon. moonVectors._rotation = tideTime places it around the Earth;
    //    visMoon._rotation = -tideTime keeps the Moon graphic upright, so its
    //    sunlit side always faces the Sun (to the right). Sun ON swaps in the
    //    lit-hemisphere art.
    var mRad = d.tideTime * DEG;
    var mx = EARTH_CX + MOON_ORBIT_R * Math.cos(mRad);
    var my = EARTH_CY + MOON_ORBIT_R * Math.sin(mRad);
    var moonImg = state.withSun ? img.moonLit : img.moon;
    drawSprite(moonImg, mx, my, MOON_R * 2, MOON_R * 2, 0);

    // 5) "To Sun" arrow (toSunArrow) -- fixed, pointing right, only with Sun.
    if (state.withSun) drawToSunArrow();
  }

  // Draw a bitmap centred at (cx,cy), scaled to w x h, rotated by deg degrees.
  function drawSprite(im, cx, cy, w, h, deg) {
    if (!im || !im.width) return;
    ctx.save();
    ctx.translate(cx, cy);
    if (deg) ctx.rotate(deg * DEG);
    ctx.drawImage(im, -w / 2, -h / 2, w, h);
    ctx.restore();
  }

  function drawToSunArrow() {
    var y = EARTH_CY, x0 = 545, x1 = 588;
    ctx.save();
    ctx.strokeStyle = '#000000';
    ctx.fillStyle = '#000000';
    ctx.lineWidth = 2;
    ctx.beginPath();
    ctx.moveTo(x0, y);
    ctx.lineTo(x1, y);
    ctx.stroke();
    ctx.beginPath();               // arrowhead
    ctx.moveTo(x1, y);
    ctx.lineTo(x1 - 9, y - 5);
    ctx.lineTo(x1 - 9, y + 5);
    ctx.closePath();
    ctx.fill();
    ctx.font = '600 15px system-ui, Arial, sans-serif';
    ctx.textAlign = 'left';
    ctx.textBaseline = 'top';
    ctx.fillText('To Sun', x0 + 4, y + 8);
    ctx.restore();
  }

  // ---- Animation loop ------------------------------------------------------
  // The loop only spins while the sim is running, so an idle page does not
  // repaint every frame (kinder to battery, especially on mobile).
  var rafId = null;

  function frame(now) {
    if (lastTime === null) lastTime = now;
    var dt = now - lastTime;       // getTimer() delta
    lastTime = now;
    // Browsers pause rAF for hidden tabs; on resume dt can be huge. Clamp it so
    // the Moon never jumps by multiple orbits after the tab was in the
    // background (uses elapsed wall-clock time otherwise, matching the AS).
    if (dt > 200) dt = 200;
    advance(dt);
    render();
    maybeAnnounceProgress();
    if (state.running) {
      rafId = requestAnimationFrame(frame);
    } else {
      rafId = null;                // stop; nothing is moving
    }
  }

  function startLoop() {
    if (rafId === null) {
      lastTime = null;
      rafId = requestAnimationFrame(frame);
    }
  }

  // ---- Screen-reader narration --------------------------------------------
  function say(msg) {
    if (srStatus) srStatus.textContent = msg;
  }

  // Qualitative Moon position from its screen angle (tideTime).
  function moonPositionWords() {
    var t = derived().tideTime % 360;         // 0 = right, grows clockwise (y-down)
    // Screen: 0 right, 90 below, 180 left, 270 above.
    if (t < 45 || t >= 315) return 'to the right of Earth';
    if (t < 135) return 'below Earth';
    if (t < 225) return 'to the left of Earth';
    return 'above Earth';
  }

  // Announce only when the Moon crosses into a new quadrant (avoids flooding).
  function maybeAnnounceProgress() {
    if (!state.running) { lastQuadrant = null; return; }
    var t = derived().tideTime % 360;
    var q = Math.floor(((t + 45) % 360) / 90); // 0..3 quadrant buckets
    if (q !== lastQuadrant) {
      lastQuadrant = q;
      say('Moon ' + moonPositionWords() + '. Tidal bulges point along the Earth–Moon line.');
    }
  }

  // Full state sentence, spoken when a control changes or on reset.
  function announceState() {
    var parts = [];
    parts.push(state.running ? 'Animation running.' : 'Animation paused.');
    parts.push('Moon ' + moonPositionWords() + '.');
    parts.push(state.withSun
      ? 'Sun included: day and night shading shown; bulges vary between spring and neap tides.'
      : 'Sun not included.');
    if (state.earthEffects) {
      parts.push('Earth’s rotation effect on: the tidal bulges lead the Moon by ' +
        OFFSET_DEG + ' degrees.');
    } else {
      parts.push('Earth’s rotation effect off: bulges aligned with the Moon.');
    }
    say(parts.join(' '));
  }

  // ---- Controls ------------------------------------------------------------
  function wireControls() {
    runCb.addEventListener('change', function () {
      state.running = runCb.checked;          // playAnim -> mySim.animate
      lastQuadrant = null;
      announceState();
      if (state.running) startLoop(); else render();
    });
    sunCb.addEventListener('change', function () {
      state.withSun = sunCb.checked;          // includeSun -> mySim._withSun
      render();
      announceState();
    });
    earthCb.addEventListener('change', function () {
      state.earthEffects = earthCb.checked;   // earthsEffects -> mySim._earthEffects
      render();
      announceState();
    });
  }

  function syncControlsToState() {
    runCb.checked   = state.running;
    sunCb.checked   = state.withSun;
    earthCb.checked = state.earthEffects;
  }

  // ---- Reset (dispatched by the masthead component) ------------------------
  function resetSim() {
    state = initialState();
    syncControlsToState();
    lastQuadrant = null;
    render();
    say('Simulation reset. Animation paused, Moon to the right of Earth, ' +
        'Sun not included, Earth’s rotation effect off.');
  }

  // ---- Init ----------------------------------------------------------------
  function init() {
    canvas   = document.getElementById('stage');
    ctx      = canvas.getContext('2d');
    runCb    = document.getElementById('run-cb');
    sunCb    = document.getElementById('sun-cb');
    earthCb  = document.getElementById('earth-cb');
    srStatus = document.getElementById('sr-status');

    sizeCanvas();
    window.addEventListener('resize', function () { sizeCanvas(); render(); });

    wireControls();
    syncControlsToState();

    // The masthead dispatches a bubbling, composed "sim-reset" CustomEvent.
    document.addEventListener('sim-reset', resetSim);

    // Draw the initial (paused) state once. The animation loop starts only
    // when the user turns on "Run".
    loadImages(function () { render(); });
  }

  // klunlInitEqn is called on load by the foundation's kl-unl.js. This sim has
  // no equations, so override it to a no-op (prevents the default from running).
  window.klunlInitEqn = function () {};

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();
