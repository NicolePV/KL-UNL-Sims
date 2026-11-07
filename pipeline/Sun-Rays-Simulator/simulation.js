/* ==========================================================================
   Sun's Rays Simulator -- HTML5 port of sunsrays.swf (Flash / ActionScript 1)
   --------------------------------------------------------------------------
   Behaviour is a faithful port of the original main-timeline script
   (scripts/frame_1/DoAction.as in the JPEXS export). Every constant, table,
   formula and string below is copied from that source; the presentation is
   rebuilt on the KL-UNL foundation and to WCAG 2.1 AA.

   The model: the Sun's rays arrive horizontally from the left. Over one
   simulated year (30 real seconds) the Earth's 23.5-degree axial tilt is
   represented by rotating the ray bundle -- and the night shadow with it --
   through  rotangle = 23.5 * sin(theta),  so the most direct rays sweep
   between the Tropic of Cancer and the Tropic of Capricorn.
   ========================================================================== */

(function () {
  'use strict';

  /* ======================================================================
     1. Constants copied verbatim from the ActionScript
     ====================================================================== */

  // monthArray = new Array([["  January"],[31],[31]], ...)
  // [ display name (space-padded in the original), days in month,
  //   cumulative day-of-year at the end of the month ]
  var MONTH_ARRAY = [
    ['  January',   31,  31],
    [' February',   28,  59],
    ['    March',   31,  90],
    ['    April',   30, 120],
    ['      May',   31, 151],
    ['     June',   30, 181],
    ['     July',   31, 212],
    ['   August',   31, 243],
    ['September',   30, 273],
    ['  October',   31, 304],
    [' November',   30, 334],
    [' December',   31, 365]
  ];

  var PERIOD          = 30;                 // period = 30 (seconds per year)
  var TWO_PI          = 6.283185307179586;  // literal used by the AS source
  var TILT            = 23.5;               // rotangle = 23.5 * Math.sin(theta)
  var DAYS_PER_YEAR   = 365;

  var SEASON_TOL      = 8;                  // tol = 8
  var SEASON_INC      = 100 / SEASON_TOL;   // inc = 100 / tol

  // Season labels, keyed by the day-of-year the AS tests against.
  // Text is verbatim, including the original leading spaces.
  var SEASONS = [
    { day:  80, text: '  Vernal Equinox'  },
    { day: 172, text: '  Summer Solstice' },
    { day: 264, text: 'Autumnal Equinox'  },
    { day: 355, text: '  Winter Solstice' }
  ];

  var DEG_SYM = 'º';                   // degsym = unescape("%ba")

  // Initial state, verbatim from the first frame of the AS.
  var INITIAL = {
    month:     2,
    day:       21,
    totaldays: 80,
    theta:     0,
    dateText:  '    March 21',              // DateBox.text
    seasonText: '  Vernal Equinox',         // DayBox.day_string
    seasonAlpha: 100,
    latText:   'at latitude: 0.0' + DEG_SYM // lat_string
  };

  /* ======================================================================
     2. Original Flash stage geometry
     ---------------------------------------------------------------------
     The canvas keeps the original coordinate system so no ported drawing
     maths has to be re-derived. The Flash stage was 600 x 550; the diagram
     panel occupied y = 50 .. 450, so the canvas is 600 x 400 and every
     original y is shifted by -STAGE_Y0.
     ====================================================================== */

  var STAGE_W  = 600;
  var STAGE_H  = 400;
  var STAGE_Y0 = 50;

  var GLOBE_CX = 350;                       // Earth placed at (350, 258)
  var GLOBE_CY = 258 - STAGE_Y0;            // -> 208
  var GLOBE_R  = 219 * 0.6986389;           // shape radius x placement scale

  // LineGroup: PlaceObject matrix (349.95, 258) with scaleX 1.2857208.
  var RAY_ORIGIN_X  = 349.95;
  var RAY_ORIGIN_Y  = 258 - STAGE_Y0;
  var RAY_SCALE_X   = 1.2857208;
  var RAY_X_FROM    = -349.95;              // -174.95 + (-175.0)
  var RAY_X_TO      = 0.05;                 // -174.95 + ( 175.0)
  var RAY_Y_STEP    = 25;                   // Line1..Line13 at -150 .. +150
  var RAY_COUNT     = 13;

  // ShadowBox: PlaceObject matrix (347.8, 257.8), scale (1.3512421, 0.75772095),
  // colour transform alphaMultTerm 179/256, over a black rectangle.
  var SHADOW_ORIGIN_X = 347.8;
  var SHADOW_ORIGIN_Y = 257.8 - STAGE_Y0;
  var SHADOW_SCALE_X  = 1.3512421;
  var SHADOW_SCALE_Y  = 0.75772095;
  var SHADOW_RECT     = { x: -0.5, y: -199.7, w: 449.95, h: 399.9 };
  var SHADOW_ALPHA    = 179 / 256;

  // Earth axis (shape 157) and latitude lines (shape 170), in stage units.
  var AXIS_LINE = { x: 347, y1: 103 - STAGE_Y0, y2: 410.5 - STAGE_Y0, w: 4 };

  var LAT_LINES = [
    { x1: 289.05, y1: 119.75, x2: 410.35, y2: 119.75 },  // Arctic Circle
    { x1: 211.10, y1: 199.95, x2: 488.15, y2: 199.90 },  // Tropic of Cancer
    { x1: 199.80, y1: 258.15, x2: 499.80, y2: 258.15 },  // Equator
    { x1: 211.45, y1: 316.05, x2: 487.80, y2: 316.00 },  // Tropic of Capricorn
    { x1: 288.95, y1: 395.40, x2: 411.10, y2: 395.60 }   // Antarctic Circle
  ].map(function (l) {
    return { x1: l.x1, y1: l.y1 - STAGE_Y0, x2: l.x2, y2: l.y2 - STAGE_Y0 };
  });

  /* ======================================================================
     3. Single source of truth
     ====================================================================== */

  var state = {
    month:       INITIAL.month,
    day:         INITIAL.day,
    totaldays:   INITIAL.totaldays,
    theta:       INITIAL.theta,
    animating:   false,
    lastTime:    0,
    rotangle:    0,
    dateText:    INITIAL.dateText,
    seasonText:  INITIAL.seasonText,
    seasonAlpha: INITIAL.seasonAlpha,
    latText:     INITIAL.latText,
    latValue:    '0.0',                     // the truncated string the AS builds
    latDir:      ''                         // '', ' N' or ' S'
  };

  /* ======================================================================
     4. DOM handles
     ====================================================================== */

  var canvas, ctx, dpr = 1;
  var elRotor, elDateLine, elSeasonLine, elRunButton, elStageDesc, elLive;
  var earthImage    = null;
  var earthImageOk  = false;
  var cssVars       = {};

  var reduceMotion  = window.matchMedia &&
                      window.matchMedia('(prefers-reduced-motion: reduce)').matches;
  var REDRAW_MS     = reduceMotion ? 250 : 0;   // step rather than sweep
  var lastPaint     = 0;
  var lastAnnounce  = 0;
  var ANNOUNCE_MS   = 2000;

  /* ======================================================================
     5. Simulation step -- a direct port of _root.onEnterFrame
     ====================================================================== */

  function step(newTime) {
    // theta_inc = (new_time - old_time) * 2 * PI / (period * 1000)
    var thetaInc = (newTime - state.lastTime) * 2 * Math.PI / (PERIOD * 1000);
    state.lastTime = newTime;

    state.theta += thetaInc;

    if (state.theta > TWO_PI) {
      state.theta    -= TWO_PI;
      state.totaldays = 80 + state.theta * DAYS_PER_YEAR / TWO_PI;
    }

    state.totaldays += thetaInc * DAYS_PER_YEAR / TWO_PI;
    state.day       += thetaInc * DAYS_PER_YEAR / TWO_PI;

    // Roll over to the next month once the cumulative day count is reached.
    if (state.totaldays >= MONTH_ARRAY[state.month][2]) {
      if (state.month === 11) {
        state.month      = 0;
        state.day        = state.totaldays - 365;
        state.totaldays -= 365;
      } else {
        state.day    = state.totaldays - MONTH_ARRAY[state.month][2];
        state.month += 1;
      }
    }

    // date_string = monthArray[month][0] + "  " + Math.ceil(day)
    state.dateText = MONTH_ARRAY[state.month][0] + '  ' + Math.ceil(state.day);

    // Season captions fade in and out over a +/- 8 day window.
    var season = null;
    for (var i = 0; i < SEASONS.length; i++) {
      if (Math.abs(state.totaldays - SEASONS[i].day) < SEASON_TOL) {
        season = SEASONS[i];
        break;
      }
    }
    if (season) {
      state.seasonAlpha = 100 - SEASON_INC * Math.abs(state.totaldays - season.day);
      state.seasonText  = season.text;
    } else {
      // The AS clears the caption text but leaves _alpha where it was.
      state.seasonText = '';
    }

    // rotangle = 23.5 * Math.sin(theta)   -- drives the rays and the shadow
    state.rotangle = TILT * Math.sin(state.theta);

    var dir = state.rotangle > 0 ? ' N' : ' S';

    // The AS builds the readout by string truncation, not by rounding, and
    // pins the value to 23.5 within a day of either solstice.
    var lat1 = String(Math.abs(state.rotangle));
    if (Math.abs(state.totaldays - 172) < 1 || Math.abs(state.totaldays - 355) < 1) {
      lat1 = '23.5';
    }
    var lat2 = (lat1 > 10) ? lat1.substr(0, 4) : lat1.substr(0, 3);

    state.latValue = lat2;
    state.latDir   = dir;
    // The original assembled this exact string for its text field; the port
    // renders the same content as label text plus a MathJax-typeset value.
    state.latText  = 'at latitude: ' + lat2 + DEG_SYM + dir;
  }

  /* ======================================================================
     6. Rendering -- one render() redraws canvas, DOM and the description
     ====================================================================== */

  function readCssVars() {
    var s = getComputedStyle(document.documentElement);
    cssVars = {
      stageBg:   s.getPropertyValue('--sim-stage-bg').trim()   || '#f3f3f3',
      stageEdge: s.getPropertyValue('--sim-stage-edge').trim() || '#767676',
      ray:       s.getPropertyValue('--sim-ray').trim()        || '#ffe000',
      rayEdge:   s.getPropertyValue('--sim-ray-edge').trim()   || '#6b5200',
      line:      s.getPropertyValue('--sim-line').trim()       || '#000000'
    };
  }

  // The backing store follows the on-screen size (times the device pixel
  // ratio) so the diagram stays crisp, but the drawing code always works in
  // original Flash stage units -- no ported geometry is ever recomputed from
  // the live element size.
  function resizeCanvas() {
    var cssWidth = canvas.clientWidth || STAGE_W;
    var ratio    = Math.min(window.devicePixelRatio || 1, 3);
    dpr = (cssWidth / STAGE_W) * ratio;

    var w = Math.max(1, Math.round(STAGE_W * dpr));
    var h = Math.max(1, Math.round(STAGE_H * dpr));
    if (canvas.width !== w || canvas.height !== h) {
      canvas.width  = w;
      canvas.height = h;
    }
    drawStage();
  }

  // Reset the context to "one unit = one original Flash stage unit".
  function baseTransform() {
    ctx.setTransform(dpr, 0, 0, dpr, 0, 0);
  }

  function drawStage() {
    if (!ctx) { return; }

    baseTransform();
    ctx.clearRect(0, 0, STAGE_W, STAGE_H);

    // Panel background (Flash shape 148, 0xF3F3F3).
    ctx.fillStyle = cssVars.stageBg;
    ctx.fillRect(0, 0, STAGE_W, STAGE_H);

    drawRays();
    drawAxis();
    drawEarth();
    drawLatitudeLines();
    drawShadow();
    drawFrame();
  }

  // The 13 horizontal rays of the LineGroup clip, tilted by rotangle.
  function drawRays() {
    var rad = state.rotangle * Math.PI / 180;

    baseTransform();
    ctx.save();
    ctx.translate(RAY_ORIGIN_X, RAY_ORIGIN_Y);
    ctx.rotate(rad);
    ctx.scale(RAY_SCALE_X, 1);

    ctx.lineCap = 'round';

    // Two passes: a dark casing then the yellow core. The casing is the
    // accessibility change that gives the rays a >= 3:1 edge against the
    // light panel; pure 0xFFFF00 on 0xF3F3F3 is about 1.07:1.
    var passes = [
      { color: cssVars.rayEdge, width: 6 },
      { color: cssVars.ray,     width: 3.5 }
    ];

    for (var p = 0; p < passes.length; p++) {
      ctx.strokeStyle = passes[p].color;
      ctx.lineWidth   = passes[p].width;
      ctx.beginPath();
      for (var i = 0; i < RAY_COUNT; i++) {
        var y = -150 + i * RAY_Y_STEP;
        ctx.moveTo(RAY_X_FROM, y);
        ctx.lineTo(RAY_X_TO,   y);
      }
      ctx.stroke();
    }

    ctx.restore();
  }

  // Earth's rotation axis (drawn beneath the globe, as in the original).
  function drawAxis() {
    baseTransform();
    ctx.strokeStyle = cssVars.line;
    ctx.lineWidth   = AXIS_LINE.w;
    ctx.lineCap     = 'round';
    ctx.beginPath();
    ctx.moveTo(AXIS_LINE.x, AXIS_LINE.y1);
    ctx.lineTo(AXIS_LINE.x, AXIS_LINE.y2);
    ctx.stroke();
  }

  // The exported bitmap (images/167.png), reused as-is at its original size.
  function drawEarth() {
    if (!earthImageOk) { return; }
    baseTransform();
    ctx.drawImage(earthImage,
                  GLOBE_CX - GLOBE_R, GLOBE_CY - GLOBE_R,
                  GLOBE_R * 2, GLOBE_R * 2);
  }

  function drawLatitudeLines() {
    baseTransform();
    ctx.strokeStyle = cssVars.line;
    ctx.lineWidth   = 2;
    ctx.lineCap     = 'round';
    ctx.beginPath();
    for (var i = 0; i < LAT_LINES.length; i++) {
      var l = LAT_LINES[i];
      ctx.moveTo(l.x1, l.y1);
      ctx.lineTo(l.x2, l.y2);
    }
    ctx.stroke();
  }

  // The night side: a large translucent black rectangle that turns with the
  // rays, so its leading edge is always the terminator.
  function drawShadow() {
    var rad = state.rotangle * Math.PI / 180;

    baseTransform();
    ctx.save();
    ctx.translate(SHADOW_ORIGIN_X, SHADOW_ORIGIN_Y);
    ctx.rotate(rad);
    ctx.scale(SHADOW_SCALE_X, SHADOW_SCALE_Y);
    ctx.fillStyle   = 'rgba(0, 0, 0, ' + SHADOW_ALPHA + ')';
    ctx.fillRect(SHADOW_RECT.x, SHADOW_RECT.y, SHADOW_RECT.w, SHADOW_RECT.h);
    ctx.restore();
  }

  function drawFrame() {
    baseTransform();
    ctx.strokeStyle = cssVars.stageEdge;
    ctx.lineWidth   = 1;
    ctx.strokeRect(0.5, 0.5, STAGE_W - 1, STAGE_H - 1);
  }

  /* ---- Text helpers ---------------------------------------------------- */

  // The original padded its strings with spaces to centre them inside
  // fixed-width Flash text fields. The HTML boxes centre their own content,
  // so the padding is collapsed; the wording itself is untouched.
  function tidy(s) {
    return s.replace(/\s+/g, ' ').trim();
  }

  function latexLatitude() {
    var dir = state.latDir.trim();
    return '\\(' + state.latValue + '^{\\circ}' +
           (dir ? '\\,\\mathrm{' + dir + '}' : '') + '\\)';
  }

  function spokenLatitude() {
    var dir = state.latDir.trim();
    var hemisphere = dir === 'N' ? ' north' : (dir === 'S' ? ' south' : '');
    return 'The direct rays hit at latitude ' + state.latValue +
           ' degrees' + hemisphere + '.';
  }

  function spokenDate() {
    var season = tidy(state.seasonText);
    return 'Date ' + tidy(state.dateText) + (season ? ', ' + season : '') + '.';
  }

  function describeStage() {
    var tilt = Math.abs(state.rotangle).toFixed(1);
    var side = state.rotangle > 0 ? 'north' : (state.rotangle < 0 ? 'south' : 'neither');
    var tiltPhrase = state.rotangle === 0
      ? 'The rays are level with the equator, so the terminator between day and night runs through both poles.'
      : 'The ray bundle is tilted ' + tilt + ' degrees, carrying the most direct sunlight ' +
        side + ' of the equator, and the terminator between day and night is tilted with it.';

    return 'The Earth is drawn with the North Pole at the top, the Arctic Circle, ' +
           'Tropic of Cancer, equator, Tropic of Capricorn and Antarctic Circle marked ' +
           'across it. The Sun’s rays arrive horizontally from the left; the half of ' +
           'the globe turned away from them is shaded as night. ' + tiltPhrase + ' ' +
           spokenDate() + ' ' + spokenLatitude();
  }

  function render() {
    drawStage();

    // Rotating label layer: the same rotangle the canvas uses.
    elRotor.style.transform = 'rotate(' + state.rotangle + 'deg)';

    elDateLine.textContent    = tidy(state.dateText);
    elSeasonLine.textContent  = tidy(state.seasonText);
    elSeasonLine.style.opacity = String(Math.max(0, Math.min(100, state.seasonAlpha)) / 100);

    // Latitude readout: LaTeX through the foundation helper, with the spoken
    // form supplied alongside so the value is never a bare number in audio.
    klunlShowEquation(
      ['latitude-eqn',    latexLatitude()],
      ['latitude-eqn-sr', spokenLatitude()],
      ['date-sr',         spokenDate()]
    );

    elStageDesc.textContent = describeStage();
  }

  // MathJax v3 stamps tabindex="0" on its container, which would put a
  // display-only readout into the Tab order. Strip it; the MathJax context
  // menu (right-click / Show Math As) still works at tabindex="-1".
  function untabMath(root) {
    var nodes = root.querySelectorAll('mjx-container[tabindex]');
    for (var i = 0; i < nodes.length; i++) {
      nodes[i].setAttribute('tabindex', '-1');
    }
  }

  function announce(message) {
    elLive.textContent = message;
  }

  /* ======================================================================
     7. Animation loop
     ====================================================================== */

  function frame(now) {
    if (!state.animating) { return; }

    step(now);

    if (now - lastPaint >= REDRAW_MS) {
      lastPaint = now;
      render();
    }

    if (now - lastAnnounce >= ANNOUNCE_MS) {
      lastAnnounce = now;
      announce(spokenDate() + ' ' + spokenLatitude());
    }

    window.requestAnimationFrame(frame);
  }

  function start() {
    if (state.animating) { return; }
    state.animating = true;
    state.lastTime  = performance.now();
    lastPaint       = 0;
    lastAnnounce    = performance.now();
    elRunButton.textContent = 'Stop';
    announce('Animation started. One year passes every ' + PERIOD + ' seconds. ' +
             spokenDate() + ' ' + spokenLatitude());
    window.requestAnimationFrame(frame);
  }

  function stop() {
    if (!state.animating) { return; }
    state.animating = false;
    elRunButton.textContent = 'Start';
    render();
    announce('Animation stopped. ' + spokenDate() + ' ' + spokenLatitude());
  }

  function reset() {
    state.animating   = false;
    state.month       = INITIAL.month;
    state.day         = INITIAL.day;
    state.totaldays   = INITIAL.totaldays;
    state.theta       = INITIAL.theta;
    state.rotangle    = 0;
    state.dateText    = INITIAL.dateText;
    state.seasonText  = INITIAL.seasonText;
    state.seasonAlpha = INITIAL.seasonAlpha;
    state.latText     = INITIAL.latText;
    state.latValue    = '0.0';
    state.latDir      = '';
    elRunButton.textContent = 'Start';
    render();
    announce('Simulation reset. ' + spokenDate() + ' ' + spokenLatitude());
  }

  /* ======================================================================
     8. Wiring
     ====================================================================== */

  function init() {
    canvas       = document.getElementById('stage-canvas');
    ctx          = canvas.getContext('2d');
    elRotor      = document.getElementById('sim-rotor');
    elDateLine   = document.getElementById('date-line');
    elSeasonLine = document.getElementById('season-line');
    elRunButton  = document.getElementById('run-button');
    elStageDesc  = document.getElementById('stage-desc');
    elLive       = document.getElementById('live-region');

    readCssVars();

    // MathJax typesets asynchronously, so watch the container and de-tab each
    // new mjx-container as it lands.
    var eqnHost = document.getElementById('latitude-eqn');
    untabMath(eqnHost);
    if (window.MutationObserver) {
      new MutationObserver(function () { untabMath(eqnHost); })
        .observe(eqnHost, { childList: true, subtree: true });
    }

    earthImage = new Image();
    earthImage.addEventListener('load', function () {
      earthImageOk = true;
      drawStage();
    });
    earthImage.addEventListener('error', function () {
      console.error('Sun’s Rays Simulator: assets/earth.png failed to load.');
    });
    earthImage.src = 'assets/earth.png';

    elRunButton.addEventListener('click', function () {
      if (state.animating) { stop(); } else { start(); }
    });

    // The masthead's Reset button bubbles a composed "sim-reset" event.
    document.addEventListener('sim-reset', reset);

    window.addEventListener('resize', resizeCanvas);
    if (window.ResizeObserver) {
      new ResizeObserver(resizeCanvas).observe(canvas);
    }

    // requestAnimationFrame stops in a hidden tab. Without this the first frame
    // after the tab comes back would credit all the intervening wall-clock time
    // at once and jump the calendar; discard that gap instead.
    document.addEventListener('visibilitychange', function () {
      if (!document.hidden && state.animating) {
        state.lastTime = performance.now();
        window.requestAnimationFrame(frame);
      }
    });

    resizeCanvas();
    render();

    // MathJax loads asynchronously; typeset the readout again once it is up.
    if (window.MathJax && window.MathJax.startup && window.MathJax.startup.promise) {
      window.MathJax.startup.promise.then(render);
    }
  }

  // kl-unl.js expects this hook to be redefined by the sim.
  window.klunlInitEqn = init;

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', function () { klunlInitEqn(); });
  } else {
    klunlInitEqn();
  }

})();
