/* ==========================================================================
   Time-Lapse Seasons Demonstrator -- HTML5 port of the Flash (AS1) original.

   Source of truth for behaviour:
     transitmovie/scripts/DefineSprite_165/frame_2/DoAction.as   (controller)
     transitmovie/scripts/DefineSprite_165/frame_1/DoAction_2.as (diagram setup)
     transitmovie/scripts/CelestialSphere.as + "2..9 CS *.as"    (projection)
     transitmovie/scripts/Timeline.as, SunDisk.as, ShadowMaker.as
     transitimages_scripts/scripts/Transit Image Sequence.as     (day table)

   The day table (366 entries of time / timeZone / ra / dec / alt, plus the
   overcast and missing flags) is carried verbatim in assets/daydata.json,
   generated from the ActionScript above. No constant is rounded or restated.

   Architecture: one plain `state` object, and one render() that redraws the
   canvases, syncs the DOM, and refreshes the live region, so the picture,
   the controls and what a screen reader hears can never drift apart.
   ========================================================================== */

'use strict';

(function () {

  /* ======================================================================
     Constants, verbatim from the ActionScript.
     ====================================================================== */

  // DefineSprite_165/frame_2/DoAction.as
  var DEFAULT_START_DAY    = 282;
  var STOP_ANIMATION_LABEL = 'pause animation';
  var START_ANIMATION_LABEL = 'start animation';

  // Animate-rate slider (PlaceObject2_78_Standard Slider v6_23 on(initialize)).
  // Units are days per millisecond; the original scale is logarithmic.
  var RATE_MIN  = 0.0015;
  var RATE_MAX  = 0.25;
  var RATE_INIT = 0.03;

  // Horizon diagram setup (DoAction_2.as initializeHorizonDiagram).
  var DIAGRAM_SIZE       = 260;          // sphere diameter in stage units
  var LATITUDE           = 40.8;         // degrees north
  var VIEWER_AZIMUTH     = 200;          // degrees
  var VIEWER_ALTITUDE    = 40;           // degrees
  var MIN_VIEWER_ALTITUDE = 7;           // degrees
  var MAX_VIEWER_ALTITUDE = 90;          // CelestialSphereClass default _maxPhi
  var SIDEREAL_TIME      = 0;            // hours; never changed by this sim
  var SHOW_UNDER         = false;

  // Circle styles, ORIG colours and alphas from DoAction_2.as.
  var CIRCLES = [
    { key: 'meridian1',  color: '#ffffff', alpha: 0.20, width: 1, sys: 'h', az: 0,  alt: 0, tilt: 90 },
    { key: 'meridian2',  color: '#ffffff', alpha: 0.20, width: 1, sys: 'h', az: 90, alt: 0, tilt: 90 },
    { key: 'maxDec',     color: '#ffffff', alpha: 0.50, width: 1, sys: 'c', ra: 0, dec:  23.44, tilt: 0 },
    { key: 'minDec',     color: '#ffffff', alpha: 0.50, width: 1, sys: 'c', ra: 0, dec: -23.44, tilt: 0 },
    { key: 'equator',    color: '#2c7bfe', alpha: 0.60, width: 2, sys: 'c', ra: 0, dec:  0,     tilt: 0 },
    { key: 'decCircle',  color: '#ffcc00', alpha: 0.70, width: 2, sys: 'c', ra: 0, dec:  0,     tilt: 0 }
  ];

  // Sky shading discs (addShadingClip calls in DoAction_2.as).
  var SKY_INNER_COLOR = '#bfe4ff';       // ORIG 0xBFE4FF
  var SKY_BACK_COLOR  = '#b2d3e6';       // ORIG 0xB2D3E6

  // ShadowMaker.as
  var SHADOW_LENGTH_LIMIT = 15;

  // Timeline.as
  var MONTH_POINTS_NO_LEAP = [0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334, 365];
  var MONTH_POINTS_LEAP    = [0, 31, 60, 91, 121, 152, 182, 213, 244, 274, 305, 335, 366];
  var MONTH_LABELS = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  var NO_IMAGE_COLOR = '#999999';        // ORIG 0x999999
  var TIMELINE_DELAY_TIME    = 500;      // ms before press-and-hold repeats
  var TIMELINE_INCREMENT_RATE = 0.01;    // days per ms while held

  // setDay() date formatting tables, verbatim.
  var MONTH_NAMES = ['January', 'February', 'March', 'April', 'May', 'June',
                     'July', 'August', 'September', 'October', 'November', 'December'];
  var DAYS_OF_WEEK = ['Sunday', 'Monday', 'Tuesday', 'Wednesday',
                      'Thursday', 'Friday', 'Saturday'];

  // Spoken forms of the time zones that appear in the day table.
  var TIME_ZONE_WORDS = {
    CST: 'Central Standard Time',
    CDT: 'Central Daylight Time'
  };

  var DEG = Math.PI / 180;
  var HOUR_TO_RAD = Math.PI / 12;        // 0.2617993877991494 in the source

  /* ======================================================================
     Canvas geometry. The sphere keeps its original internal units; CSS
     scales the element (see styles.css), so nothing here depends on the
     on-screen size.
     ====================================================================== */

  var STAGE_SIZE = 300;                  // internal drawing box, sphere centred
  var STAGE_MID  = STAGE_SIZE / 2;
  var SPHERE_R   = DIAGRAM_SIZE / 2;     // 130

  var TIMELINE_W = 732;                  // ORIG timelineWidth
  var TIMELINE_H = 46;                   // tick band + no-image band

  /* ======================================================================
     State. One object; render() is the only thing that paints.
     ====================================================================== */

  var state = {
    data:            null,   // parsed daydata.json
    dayTable:        null,
    len:             0,
    currentDay:      DEFAULT_START_DAY,
    excludeOvercast: false,
    showDirections:  false,
    animating:       false,
    animateRate:     RATE_INIT,
    animateDay:      DEFAULT_START_DAY,
    showShadowCursor: false,
    shadowCursorDay: DEFAULT_START_DAY,

    // Viewing direction (the sphere is drag-rotatable in the original).
    theta:           (360 - VIEWER_AZIMUTH) * DEG,   // setViewerAzimuth
    phi:             VIEWER_ALTITUDE * DEG,

    // analyzeDayTable() results
    clearWinterSolstice:    0,
    clearSummerSolstice:    0,
    overcastWinterSolstice: 0,
    overcastSummerSolstice: 0,
    decLookupTable:  null,
    lastInterval:    0,
    atSolstice:      false,

    // Derived display strings, produced by setDay()
    dayOfWeekString: '',
    dayOfMonthString: '',
    monthString:     '',
    yearString:      '',
    timeString:      '',
    timeZone:        '',
    raString:        '',
    decString:       '',
    altString:       ''
  };

  // Projection matrices, rebuilt whenever theta/phi/latitude change.
  var C = {};

  /* ======================================================================
     DOM handles.
     ====================================================================== */

  var el = {};

  function grab() {
    [
      'photo-wrap', 'photo', 'photo-directions', 'photo-desc',
      'out-weekday', 'out-daynum', 'out-month', 'out-year', 'out-time',
      'chk-directions', 'chk-overcast',
      'sim-stage', 'stage-canvas', 'stage-desc',
      'sun-handle', 'view-handle',
      'dir-n', 'dir-e', 'dir-s', 'dir-w',
      'btn-animate', 'rate-slider',
      'timeline', 'timeline-canvas', 'day-cursor', 'month-labels',
      'live-region'
    ].forEach(function (id) {
      el[id] = document.getElementById(id);
    });
  }

  /* ======================================================================
     Small helpers.
     ====================================================================== */

  function mod(n, m) {
    return ((n % m) + m) % m;
  }

  // The AS source ships a toFixed polyfill that matches the ECMAScript
  // behaviour of Number.prototype.toFixed, so the native one is used here.
  function fixed(n, digits) {
    return n.toFixed(digits);
  }

  function hexToRgba(hex, alpha) {
    var r = parseInt(hex.slice(1, 3), 16);
    var g = parseInt(hex.slice(3, 5), 16);
    var b = parseInt(hex.slice(5, 7), 16);
    return 'rgba(' + r + ',' + g + ',' + b + ',' + alpha + ')';
  }

  function prefersReducedMotion() {
    return window.matchMedia &&
           window.matchMedia('(prefers-reduced-motion: reduce)').matches;
  }

  /* ======================================================================
     Projection -- ported from "3 CS Geometry.as".

     doA(): world (horizon) -> screen.   doM(): celestial -> world.
     doB(): the composition, celestial -> screen.
     Screen y runs downward, exactly as in Flash, so the sense of the
     sun's motion around the sphere matches the original.
     ====================================================================== */

  function doA() {
    var r  = SPHERE_R;
    var ct = Math.cos(state.theta), st = Math.sin(state.theta);
    var cp = Math.cos(state.phi),   sp = Math.sin(state.phi);
    C.a0 = -r * st;      C.a1 = r * ct;
    C.a3 = r * ct * sp;  C.a4 = r * st * sp;  C.a5 = -r * cp;
    C.a6 = r * ct * cp;  C.a7 = r * st * cp;  C.a8 = r * sp;
  }

  function doM() {
    var lat   = LATITUDE * DEG;
    var sTime = SIDEREAL_TIME * HOUR_TO_RAD;
    C.m2 = Math.cos(lat);
    C.m3 = Math.sin(sTime);
    C.m4 = -Math.cos(sTime);
    C.m8 = Math.sin(lat);
    C.m0 = C.m4 * C.m8;
    C.m1 = -C.m3 * C.m8;
    C.m6 = -C.m2 * C.m4;
    C.m7 = C.m2 * C.m3;
  }

  function doB() {
    C.b0 = C.a0 * C.m0 + C.a1 * C.m3;
    C.b1 = C.a0 * C.m1 + C.a1 * C.m4;
    C.b2 = C.a0 * C.m2;
    C.b3 = C.a3 * C.m0 + C.a4 * C.m3 + C.a5 * C.m6;
    C.b4 = C.a3 * C.m1 + C.a4 * C.m4 + C.a5 * C.m7;
    C.b5 = C.a3 * C.m2 + C.a5 * C.m8;
    C.b6 = C.a6 * C.m0 + C.a7 * C.m3 + C.a8 * C.m6;
    C.b7 = C.a6 * C.m1 + C.a7 * C.m4 + C.a8 * C.m7;
    C.b8 = C.a6 * C.m2 + C.a8 * C.m8;
  }

  function rebuildMatrices() {
    doA();
    doM();
    doB();
  }

  // parsePointInput, horizon branch: az/alt (degrees) -> world xyz.
  function horizonToWorld(az, alt, r) {
    if (r === undefined) { r = 1; }
    var d = r * Math.cos(alt * DEG);
    return {
      x: d * Math.cos(az * DEG),
      y: d * Math.sin(-az * DEG),
      z: r * Math.sin(alt * DEG)
    };
  }

  // parsePointInput, celestial branch: ra (hours) / dec (degrees) -> xyz.
  function celestialToVec(ra, dec, r) {
    if (r === undefined) { r = 1; }
    var d = r * Math.cos(dec * DEG);
    return {
      x: d * Math.cos(ra * HOUR_TO_RAD),
      y: d * Math.sin(ra * HOUR_TO_RAD),
      z: r * Math.sin(dec * DEG)
    };
  }

  function worldToScreen(p) {
    return {
      x: p.x * C.a0 + p.y * C.a1,
      y: p.x * C.a3 + p.y * C.a4 + p.z * C.a5,
      z: p.x * C.a6 + p.y * C.a7 + p.z * C.a8
    };
  }

  function celestialToScreen(p) {
    return {
      x: p.x * C.b0 + p.y * C.b1 + p.z * C.b2,
      y: p.x * C.b3 + p.y * C.b4 + p.z * C.b5,
      z: p.x * C.b6 + p.y * C.b7 + p.z * C.b8
    };
  }

  // StoMH: screen point -> horizon az/alt in radians (4 CS Mouse.as).
  function screenToHorizonRad(sx, sy) {
    var d = Math.sqrt(sx * sx + sy * sy) / SPHERE_R;
    if (d > 1) { d = 1; }
    var b = Math.asin(d);
    var A = Math.atan2(sx, -sy);
    var alt, az;
    if (state.phi === Math.PI / 2) {
      alt = Math.PI / 2 - b;
      az  = state.theta + Math.PI - A;
    } else if (state.phi === -Math.PI / 2) {
      alt = -Math.PI / 2 + b;
      az  = state.theta + A;
    } else {
      var c  = Math.PI / 2 - state.phi;
      var cc = Math.cos(c), sc = Math.sin(c);
      var cb = Math.cos(b), sb = Math.sin(b);
      var ca = cb * cc + sb * sc * Math.cos(A);
      alt = Math.PI / 2 - Math.acos(ca);
      az  = state.theta + Math.atan2(sb * Math.sin(A), (cb - ca * cc) / sc);
    }
    return { alt: alt, az: mod(az, 2 * Math.PI) };
  }

  // MHtoC: horizon (radians) -> celestial ra (radians) / dec (radians).
  function horizonRadToCelestial(hp) {
    var lat   = LATITUDE * DEG;
    var sTime = SIDEREAL_TIME * HOUR_TO_RAD;
    var salt = Math.sin(hp.alt), calt = Math.cos(hp.alt);
    var saz  = Math.sin(hp.az),  caz  = Math.cos(hp.az);
    var slat = Math.sin(lat),    clat = Math.cos(lat);
    var sh = calt * saz;
    var ch = salt * clat - calt * slat * caz;
    var ra = (ch === 0) ? 0 : mod(sTime - Math.atan2(sh, ch), 2 * Math.PI);
    return { ra: ra, dec: Math.asin(salt * slat + calt * caz * clat) };
  }

  // getMouseRaDec: stage point -> {ra hours, dec degrees}, or nulls outside.
  function stageToRaDec(sx, sy) {
    if (Math.sqrt(sx * sx + sy * sy) > SPHERE_R) {
      return { ra: null, dec: null };
    }
    var c = horizonRadToCelestial(screenToHorizonRad(sx, sy));
    return { ra: c.ra * (12 / Math.PI), dec: c.dec / DEG };
  }

  /* ======================================================================
     Circle drawing -- ported from "8 CS Circles.as".

     A circle on the sphere is defined by tilt / beta / lambda. doW() builds
     its own 3x3, which is composed with the view matrix to give the six
     coefficients v0..v8 of the screen-space ellipse. The circle is then
     split into the arc in front of the sphere and the arc behind it, so
     the two halves can be drawn in the right z-order.
     ====================================================================== */

  function circleW(def) {
    var tilt, beta, lambda;
    if (def.sys === 'h') {
      tilt   = def.tilt * DEG;
      lambda = def.alt * DEG;
      beta   = mod(-def.az, 360) * DEG;
    } else {
      tilt   = def.tilt * DEG;
      lambda = def.dec * DEG;
      beta   = mod(def.ra, 24) * HOUR_TO_RAD;
    }
    var st = Math.sin(tilt),   ct = Math.cos(tilt);
    var sb = Math.sin(beta),   cb = Math.cos(beta);
    var cl = Math.cos(lambda), sl = Math.sin(lambda);
    return {
      w0: cl * cb,        w1: -cl * sb * ct,  w2: sl * sb * st,
      w3: cl * sb,        w4: cl * cb * ct,   w5: -sl * cb * st,
      w7: cl * st,        w8: sl * ct
    };
  }

  function circleV(def) {
    var w = circleW(def);
    if (def.sys === 'h') {
      return {
        v0: C.a0 * w.w0 + C.a1 * w.w3,
        v1: C.a0 * w.w1 + C.a1 * w.w4,
        v2: C.a0 * w.w2 + C.a1 * w.w5,
        v3: C.a3 * w.w0 + C.a4 * w.w3,
        v4: C.a3 * w.w1 + C.a4 * w.w4 + C.a5 * w.w7,
        v5: C.a3 * w.w2 + C.a4 * w.w5 + C.a5 * w.w8,
        v6: C.a6 * w.w0 + C.a7 * w.w3,
        v7: C.a6 * w.w1 + C.a7 * w.w4 + C.a8 * w.w7,
        v8: C.a6 * w.w2 + C.a7 * w.w5 + C.a8 * w.w8
      };
    }
    return {
      v0: C.b0 * w.w0 + C.b1 * w.w3,
      v1: C.b0 * w.w1 + C.b1 * w.w4 + C.b2 * w.w7,
      v2: C.b0 * w.w2 + C.b1 * w.w5 + C.b2 * w.w8,
      v3: C.b3 * w.w0 + C.b4 * w.w3,
      v4: C.b3 * w.w1 + C.b4 * w.w4 + C.b5 * w.w7,
      v5: C.b3 * w.w2 + C.b4 * w.w5 + C.b5 * w.w8,
      v6: C.b6 * w.w0 + C.b7 * w.w3,
      v7: C.b6 * w.w1 + C.b7 * w.w4 + C.b8 * w.w7,
      v8: C.b6 * w.w2 + C.b7 * w.w5 + C.b8 * w.w8
    };
  }

  var MIN_STEP = Math.PI / 4;            // p._minStep in the source

  // Trace the arc from g1 to g2 of the ellipse described by v. ctx.arc
  // cannot be used because the projected circle is a general ellipse, so
  // the same tessellation the original used is reproduced with lineTo.
  function traceArc(ctx, v, g1, g2) {
    if (g2 < g1) { g2 += 2 * Math.PI; }
    var arc = g2 - g1;
    if (arc === 0) { arc = 2 * Math.PI; }
    var n = Math.max(2, Math.ceil(arc / MIN_STEP) * 8);   // finer: canvas has no curveTo tessellation to lean on
    var step = arc / n;
    for (var i = 0; i <= n; i++) {
      var a = g1 + i * step;
      var ca = Math.cos(a), sa = Math.sin(a);
      var x = v.v0 * ca + v.v1 * sa + v.v2;
      var y = v.v3 * ca + v.v4 * sa + v.v5;
      if (i === 0) { ctx.moveTo(STAGE_MID + x, STAGE_MID + y); }
      else         { ctx.lineTo(STAGE_MID + x, STAGE_MID + y); }
    }
  }

  // Returns {front: [[g1,g2],...], back: [...]} for a full circle.
  function splitCircle(v) {
    var A = Math.sqrt(v.v6 * v.v6 + v.v7 * v.v7);
    if (A === 0) {
      return (v.v8 < 0) ? { front: [], back: [[0, 0]] }
                        : { front: [[0, 0]], back: [] };
    }
    var sj = -v.v8 / A;
    if (sj <= -1) { return { front: [[0, 0]], back: [] }; }
    if (sj >=  1) { return { front: [], back: [[0, 0]] }; }

    var j = Math.asin(sj);
    var t = Math.atan2(v.v6, v.v7);
    var gDesc, gAsc;
    if (Math.cos(j) < 0) {
      gDesc = mod(j - t, 2 * Math.PI);
      gAsc  = mod(Math.PI - j - t, 2 * Math.PI);
    } else {
      gDesc = mod(Math.PI - j - t, 2 * Math.PI);
      gAsc  = mod(j - t, 2 * Math.PI);
    }
    return { front: [[gAsc, gDesc]], back: [[gDesc, gAsc]] };
  }

  function drawCircleSide(ctx, def, v, side) {
    var parts = splitCircle(v)[side];
    if (!parts.length) { return; }
    ctx.save();
    ctx.strokeStyle = hexToRgba(def.color, def.alpha);
    ctx.lineWidth   = def.width;
    ctx.beginPath();
    for (var i = 0; i < parts.length; i++) {
      traceArc(ctx, v, parts[i][0], parts[i][1]);
    }
    ctx.stroke();
    ctx.restore();
  }

  /* ======================================================================
     Clip regions -- the mask machinery of "6 CS Shading.as", reduced to
     the showUnder === false case this sim uses.

     M1 is everything above the NEAR (front) half of the horizon ellipse;
     M3 is everything above the FAR (back) half. They gate the front and
     back sky shading and the front/back circle arcs respectively.
     ====================================================================== */

  function horizonEllipseY() {
    return SPHERE_R * Math.sin(state.phi);
  }

  function clipAbove(ctx, half) {
    // half: +1 -> near/front edge of the ellipse, -1 -> far/back edge.
    var r = SPHERE_R;
    var s = horizonEllipseY();
    var d = STAGE_SIZE;                  // beyond the drawing box, as 120 was
    ctx.beginPath();
    ctx.moveTo(STAGE_MID + d, STAGE_MID - d);
    ctx.lineTo(STAGE_MID + d, STAGE_MID);
    ctx.lineTo(STAGE_MID + r, STAGE_MID);
    var n = 64;
    for (var i = 0; i <= n; i++) {
      var a = (i / n) * Math.PI;
      ctx.lineTo(STAGE_MID + r * Math.cos(a),
                 STAGE_MID + half * s * Math.sin(a));
    }
    ctx.lineTo(STAGE_MID - d, STAGE_MID);
    ctx.lineTo(STAGE_MID - d, STAGE_MID - d);
    ctx.closePath();
    ctx.clip();
  }

  function clipSphere(ctx) {
    ctx.beginPath();
    ctx.arc(STAGE_MID, STAGE_MID, SPHERE_R, 0, 2 * Math.PI);
    ctx.clip();
  }

  /* ======================================================================
     Exported art. Every one of these is the JPEXS-exported file reused
     as-is: nothing here is traced or redrawn by hand.
     ====================================================================== */

  var art = {};
  var ART_FILES = {
    horizonPlane: 'assets/shapes/34.svg',   // CSAboveHorizonPlane
    sun:          'assets/shapes/49.svg',   // SunDisk frame 1
    sunOutline:   'assets/shapes/50.svg',   // SunDisk frame 2 (hover/focus)
    stickman:     'assets/shapes/55.svg',   // Stickman
    stickmanShad: 'assets/shapes/53.svg',   // StickmanShadow
    dayCursor:    'assets/shapes/61.svg',   // TimelineCursor
    shadowCursor: 'assets/shapes/59.svg'    // TimelineShadowCursor
  };

  function loadArt() {
    var keys = Object.keys(ART_FILES);
    return Promise.all(keys.map(function (k) {
      return new Promise(function (resolve) {
        var img = new Image();
        img.onload  = function () { art[k] = img; resolve(); };
        img.onerror = function () { resolve(); };   // degrade, never hang
        img.src = ART_FILES[k];
      });
    }));
  }

  /* ======================================================================
     analyzeDayTable() -- ported verbatim from the controller.

     Builds, for each of the two half-years, the ordered list of
     (day, dec) pairs used to turn a dragged declination back into a day.
     ====================================================================== */

  function analyzeDayTable() {
    var dT  = state.dayTable;
    var len = state.len;

    state.clearWinterSolstice    = state.data.winterSolstice;
    state.clearSummerSolstice    = state.data.summerSolstice;
    state.overcastWinterSolstice = state.data.winterSolstice;
    state.overcastSummerSolstice = state.data.summerSolstice;

    while (dT[state.clearWinterSolstice].overcast || dT[state.clearWinterSolstice].missing) {
      state.clearWinterSolstice--;
    }
    while (dT[state.overcastWinterSolstice].missing) {
      state.overcastWinterSolstice--;
    }
    while (dT[state.clearSummerSolstice].overcast || dT[state.clearSummerSolstice].missing) {
      state.clearSummerSolstice--;
    }
    while (dT[state.overcastSummerSolstice].missing) {
      state.overcastSummerSolstice--;
    }

    var cSS = state.clearSummerSolstice, cWS = state.clearWinterSolstice;
    var oSS = state.overcastSummerSolstice, oWS = state.overcastWinterSolstice;
    var lookup = { clear: [], overcast: [] };
    var tmp, i, k, count;

    // clear[0]: summer -> winter, skipping missing and overcast days
    tmp = [];
    for (i = cSS + 1; i < cWS; i++) {
      if (!(dT[i].missing || dT[i].overcast)) { tmp.push({ day: i, dec: dT[i].dec }); }
    }
    lookup.clear[0] = tmp;

    // clear[1]: winter -> summer, wrapping through the end of the table
    tmp = [];
    count = cSS + (len - cWS);
    for (i = 1; i < count; i++) {
      k = (cWS + i) % len;
      if (!(dT[k].missing || dT[k].overcast)) { tmp.push({ day: k, dec: dT[k].dec }); }
    }
    lookup.clear[1] = tmp;

    // overcast[0]/[1]: the same two runs, skipping only missing days
    tmp = [];
    for (i = oSS + 1; i < oWS; i++) {
      if (!dT[i].missing) { tmp.push({ day: i, dec: dT[i].dec }); }
    }
    lookup.overcast[0] = tmp;

    tmp = [];
    count = oSS + (len - oWS);
    for (i = 1; i < count; i++) {
      k = (oWS + i) % len;
      if (!dT[k].missing) { tmp.push({ day: k, dec: dT[k].dec }); }
    }
    lookup.overcast[1] = tmp;

    state.decLookupTable = lookup;
  }

  /* ======================================================================
     setDay() -- the heart of the controller, ported verbatim.
     ====================================================================== */

  function setDay(arg) {
    var dT  = state.dayTable;
    var len = state.len;
    var day = mod(arg, len);

    if (state.excludeOvercast) {
      while (dT[day].overcast || dT[day].missing) { day = mod(day - 1, len); }
      if (day > state.clearSummerSolstice && day < state.clearWinterSolstice) {
        state.lastInterval = 0; state.atSolstice = false;
      } else if (day > state.clearWinterSolstice || day < state.clearSummerSolstice) {
        state.lastInterval = 1; state.atSolstice = false;
      } else {
        state.atSolstice = true;
      }
    } else {
      while (dT[day].missing) { day = mod(day - 1, len); }
      if (day > state.overcastSummerSolstice && day < state.overcastWinterSolstice) {
        state.lastInterval = 0; state.atSolstice = false;
      } else if (day > state.overcastWinterSolstice || day < state.overcastSummerSolstice) {
        state.lastInterval = 1; state.atSolstice = false;
      } else {
        state.atSolstice = true;
      }
    }

    state.currentDay = day;
    var info = dT[day];

    // Date and time strings. The original reads the stored epoch time in
    // UTC (the offset is already baked into the stored value) and rounds
    // the minute when the seconds are >= 30.
    var d = new Date(info.time);
    state.dayOfWeekString  = DAYS_OF_WEEK[d.getUTCDay()];
    state.dayOfMonthString = String(d.getUTCDate());
    state.monthString      = MONTH_NAMES[d.getUTCMonth()];
    state.yearString       = String(d.getUTCFullYear());

    var hours   = d.getUTCHours();
    var minutes = d.getUTCMinutes();
    var seconds = d.getUTCSeconds();
    if (seconds >= 30) {
      if (minutes === 59) { hours = hours + 1; minutes = 0; }
      else                { minutes++; }
    }
    hours %= 12;
    if (hours === 0) { hours = 12; }

    var t = hours + ':';
    t += (minutes < 10) ? ('0' + minutes) : String(minutes);
    // Every image was captured at the meridional transit, so the original
    // hard-codes "pm" here rather than deriving it.
    t += ' pm ' + info.timeZone;
    state.timeString = t;
    state.timeZone   = info.timeZone;

    var hour   = Math.floor(info.ra);
    var minute = Math.floor((info.ra - hour) * 60);
    state.raString  = hour + 'h ' + minute + 'm';
    state.decString = fixed(info.dec, 1) + '°';
    state.altString = fixed(info.alt, 1) + '°';
  }

  /* ======================================================================
     setSunDec() -- turn a dragged declination back into a day.
     ====================================================================== */

  function setSunDec(arg) {
    var target = parseFloat(arg);
    if (isNaN(target) || !isFinite(target)) { return; }

    if (target <= state.data.minDec) {
      setDay(state.excludeOvercast ? state.clearWinterSolstice
                                   : state.overcastWinterSolstice);
      return;
    }
    if (target >= state.data.maxDec) {
      setDay(state.excludeOvercast ? state.clearSummerSolstice
                                   : state.overcastSummerSolstice);
      return;
    }

    var thisInterval = state.atSolstice ? (state.lastInterval + 1) % 2
                                        : state.lastInterval;
    var list = state.excludeOvercast ? state.decLookupTable.clear[thisInterval]
                                     : state.decLookupTable.overcast[thisInterval];
    var len = list.length;
    var i = 0;
    if (thisInterval === 0) {
      while (i < len && target < list[i].dec) { i++; }
    } else {
      while (i < len && target > list[i].dec) { i++; }
    }
    if (i !== 0) { i--; }
    if (list[i]) { setDay(list[i].day); }
  }

  /* ======================================================================
     incrementUpBy / incrementDownBy -- step over skipped days.
     ====================================================================== */

  function incrementUpBy(count) {
    var dT = state.dayTable, len = state.len;
    var day = state.currentDay;
    for (var n = count; n > 0; n--) {
      if (state.excludeOvercast) {
        do { day = mod(day + 1, len); } while (dT[day].overcast || dT[day].missing);
      } else {
        do { day = mod(day + 1, len); } while (dT[day].missing);
      }
    }
    setDay(day);
  }

  function incrementDownBy(count) {
    var dT = state.dayTable, len = state.len;
    var day = state.currentDay;
    for (var n = count; n > 0; n--) {
      if (state.excludeOvercast) {
        do { day = mod(day - 1, len); } while (dT[day].overcast || dT[day].missing);
      } else {
        do { day = mod(day - 1, len); } while (dT[day].missing);
      }
    }
    setDay(day);
  }

  /* ======================================================================
     Animation -- animateOnEnterFrame(), on a rAF loop.

     The original advances by animateRate * elapsed-milliseconds, using
     getTimer(). performance.now() and elapsed wall-clock time reproduce
     that on any refresh rate.
     ====================================================================== */

  var rafId = null;
  var timeLast = 0;

  // Longest elapsed slice a single frame may advance. requestAnimationFrame
  // is paused while the tab is in the background, so without this the first
  // frame after the user returns would carry minutes of elapsed time and
  // jump the sim to an arbitrary day.
  var MAX_FRAME_MS = 100;

  function animateFrame() {
    if (!state.animating) { return; }
    var now = performance.now();
    var len = state.len;
    var dt = Math.min(now - timeLast, MAX_FRAME_MS);
    state.animateDay = mod(state.animateDay + state.animateRate * dt, len);
    var day = Math.floor(state.animateDay);
    setDay(day);
    state.shadowCursorDay = day;
    timeLast = now;
    render();
    rafId = requestAnimationFrame(animateFrame);
  }

  function setAnimateState(on) {
    if (on) {
      // prefers-reduced-motion: honour the preference by not running a
      // continuous animation; the sim stays fully usable via the timeline,
      // the sun drag and the arrow keys.
      if (prefersReducedMotion()) {
        state.animating = false;
        state.showShadowCursor = false;
        announce('Continuous animation is turned off because your system ' +
                 'requests reduced motion. Use the timeline slider or the ' +
                 'arrow keys to step through the year.');
        syncAnimateButton();
        return;
      }
      timeLast = performance.now();
      state.animateDay = state.currentDay;
      state.showShadowCursor = true;
      state.animating = true;
      rafId = requestAnimationFrame(animateFrame);
    } else {
      state.animating = false;
      state.showShadowCursor = false;
      if (rafId !== null) { cancelAnimationFrame(rafId); rafId = null; }
    }
    syncAnimateButton();
  }

  function syncAnimateButton() {
    el['btn-animate'].textContent = state.animating ? STOP_ANIMATION_LABEL
                                                    : START_ANIMATION_LABEL;
  }

  function toggleAnimateButton() {
    if (state.animating) {
      setAnimateState(false);
      announce('Animation paused on ' + spokenDate() + '.');
    } else {
      setAnimateState(true);
      if (state.animating) { announce('Animation started.'); }
    }
    render();
  }

  /* ======================================================================
     Rate slider. The original slider is logarithmic between minValue and
     maxValue; the native range input carries 0..1000 and is mapped through
     the same geometric interpolation the AS slider logic used:
         value = exp( t * (ln max - ln min) + ln min )
     ====================================================================== */

  function sliderPosToRate(pos) {
    var t = pos / 1000;
    return Math.exp(t * (Math.log(RATE_MAX) - Math.log(RATE_MIN)) + Math.log(RATE_MIN));
  }

  function rateToSliderPos(rate) {
    var t = (Math.log(rate) - Math.log(RATE_MIN)) /
            (Math.log(RATE_MAX) - Math.log(RATE_MIN));
    return Math.round(t * 1000);
  }

  // Days per second reads more naturally aloud than days per millisecond.
  function rateSpoken(rate) {
    var perSecond = rate * 1000;
    var digits = (perSecond < 10) ? 1 : 0;
    return 'Animation rate ' + fixed(perSecond, digits) + ' days per second';
  }

  /* ======================================================================
     Rendering.
     ====================================================================== */

  function render() {
    renderPhoto();
    renderDiagram();
    renderTimeline();
    renderReadouts();
    renderDescriptions();
  }

  function renderPhoto() {
    var info = state.dayTable[state.currentDay];
    if (info.image) {
      el['photo-wrap'].setAttribute('data-missing', 'false');
      var src = 'assets/images/' + info.image;
      if (el['photo'].getAttribute('src') !== src) {
        el['photo'].setAttribute('src', src);
      }
      el['photo'].style.visibility = 'visible';
    } else {
      // A missing day is never selected by setDay(), which walks backwards
      // past them, so this is a safety net rather than a normal state.
      el['photo-wrap'].setAttribute('data-missing', 'true');
      el['photo'].style.visibility = 'hidden';
    }
    el['photo-directions'].hidden = !state.showDirections;
  }

  function renderDiagram() {
    var canvas = el['stage-canvas'];
    var dpr = window.devicePixelRatio || 1;
    var need = Math.round(STAGE_SIZE * dpr);
    // Both dimensions must be checked: a canvas defaults to 300x150, so
    // testing width alone leaves the height at 150 when dpr is 1.
    if (canvas.width !== need || canvas.height !== need) {
      canvas.width  = need;
      canvas.height = need;
    }

    var ctx = canvas.getContext('2d');
    ctx.setTransform(dpr, 0, 0, dpr, 0, 0);
    ctx.clearRect(0, 0, STAGE_SIZE, STAGE_SIZE);

    rebuildMatrices();

    var info = state.dayTable[state.currentDay];
    var s = horizonEllipseY();

    // Circle definitions for this frame; decCircle follows the sun.
    var defs = CIRCLES.map(function (d) {
      if (d.key === 'decCircle') {
        return { key: d.key, color: d.color, alpha: d.alpha, width: d.width,
                 sys: 'c', ra: 0, dec: info.dec, tilt: 0 };
      }
      return d;
    });
    var vs = defs.map(circleV);

    /* ---- back of the sphere ------------------------------------------- */
    ctx.save();
    clipSphere(ctx);

    // skyBackDark: back / outer / both -> clipped to the far-above region
    ctx.save();
    clipAbove(ctx, -1);
    ctx.fillStyle = SKY_BACK_COLOR;
    ctx.beginPath();
    ctx.arc(STAGE_MID, STAGE_MID, SPHERE_R, 0, 2 * Math.PI);
    ctx.fill();
    ctx.restore();

    // back circle arcs
    ctx.save();
    clipAbove(ctx, -1);
    for (var i = 0; i < defs.length; i++) { drawCircleSide(ctx, defs[i], vs[i], 'back'); }
    ctx.restore();

    // skyBack: back / inner / above
    ctx.save();
    clipAbove(ctx, -1);
    paintSkyGradient(ctx, 0.15, 0.35);
    ctx.restore();

    ctx.restore();

    /* ---- the horizon plane -------------------------------------------- */
    // Exported art (shapes/34.svg), a 200x200 unit disc, scaled by the
    // sphere radius horizontally and by r*sin(phi) vertically, exactly as
    // updateHorizonPlane() did with _xscale / _yscale.
    if (art.horizonPlane && state.phi > 0) {
      ctx.save();
      ctx.translate(STAGE_MID, STAGE_MID);
      ctx.drawImage(art.horizonPlane, -SPHERE_R, -s, SPHERE_R * 2, s * 2);
      ctx.restore();
    }

    /* ---- objects that sit on the plane: stickman and its shadow -------- */
    drawShadowAndStickman(ctx, info);

    /* ---- front of the sphere ------------------------------------------ */
    ctx.save();
    clipSphere(ctx);

    // skyFront: front / inner / above
    ctx.save();
    clipAbove(ctx, 1);
    paintSkyGradient(ctx, 0.10, 0.30);
    ctx.restore();

    // front circle arcs
    ctx.save();
    clipAbove(ctx, 1);
    for (var j = 0; j < defs.length; j++) { drawCircleSide(ctx, defs[j], vs[j], 'front'); }
    ctx.restore();

    ctx.restore();

    /* ---- the sun ------------------------------------------------------ */
    var sunPos = drawSun(ctx, info);
    positionSunHandle(sunPos);
    positionDirectionLabels();
  }

  // CSGradientDisk: a radial gradient disc of the sky colour, drawn at
  // the sphere radius. innerAlpha/outerAlpha come from DoAction_2.as.
  function paintSkyGradient(ctx, innerAlpha, outerAlpha) {
    var g = ctx.createRadialGradient(STAGE_MID, STAGE_MID, 0,
                                     STAGE_MID, STAGE_MID, SPHERE_R);
    g.addColorStop(0, hexToRgba(SKY_INNER_COLOR, innerAlpha));
    g.addColorStop(1, hexToRgba(SKY_INNER_COLOR, outerAlpha));
    ctx.fillStyle = g;
    ctx.beginPath();
    ctx.arc(STAGE_MID, STAGE_MID, SPHERE_R, 0, 2 * Math.PI);
    ctx.fill();
  }

  // Stickman at the centre of the plane, plus the shadow the sun casts.
  // ShadowMaker.as scales the shadow by 1/tan(altitude) and fades it out
  // as the sun approaches the horizon.
  // Project a direction lying in the horizon plane (no translation) into
  // screen space. The a-matrix already carries the sphere radius, so a
  // world-unit ground vector comes back correctly foreshortened for the
  // current viewing elevation.
  function groundDirectionToScreen(az) {
    var g = horizonToWorld(az, 0, 1);
    return {
      x: g.x * C.a0 + g.y * C.a1,
      y: g.x * C.a3 + g.y * C.a4 + g.z * C.a5
    };
  }

  /* The figure's size is a property of the figure, not of the camera, so it
     is pinned in WORLD units once and everything else is projected from it.
     The values are chosen so that at the sim's default viewpoint the figure
     projects to exactly the pixel size of the exported art:
        height * r * cos(40 deg) = 35.55 px,  width * r = 14.3 px
     Deriving these from the live viewing elevation instead would make the
     shadow's length change when the user merely rotated the view. */
  var PERSON_WORLD_HEIGHT = 35.55 / (SPHERE_R * Math.cos(VIEWER_ALTITUDE * DEG));
  var PERSON_WORLD_WIDTH  = 14.3 / SPHERE_R;

  /* Where each exported sprite's registration point sits inside its own
     image, as a fraction of the image height. This is the point the
     ActionScript pins to the object's position -- the figure's feet. The two
     sprites disagree: StickmanShadow's origin is at the exact bottom of its
     33.55px image, while Stickman's is 1px up from the bottom of its 35.55px
     image. Ignoring that leaves the shadow's base and the figure's feet
     landing on different points. */
  var STICKMAN_REG_Y = 34.55 / 35.55;
  var SHADOW_REG_Y   = 33.55 / 33.55;

  /* CSObjectsClass.update(), the "absolute" orientation case (oType 2).

     An object placed on the sphere is a flat card. `n` is the direction its
     face looks along and `u` is its up-axis, both given in the horizon
     system. The card is foreshortened by the component of `n` along the view
     axis and rotated so its up-axis follows `u`. This is what makes the
     figure turn and squash as the ground is rotated underneath it, rather
     than standing bolt upright no matter where the viewer is.

     Returns the three values the Flash display list applied in order:
     an outer rotation, a vertical scale, then an inner rotation. */
  function absoluteOrientation(n, u) {
    var npz = (n.x * C.a6 + n.y * C.a7 + n.z * C.a8) / SPHERE_R;
    // The object sits at the origin, so p + n projects as just n.
    var spn = worldToScreen(n);
    var A   = Math.atan2(spn.y, spn.x) + Math.PI / 2;
    var spu = worldToScreen(u);
    var cA  = Math.cos(A), sA = Math.sin(A);
    var x1  =  cA * spu.x + sA * spu.y;
    var y1  = -sA * spu.x + cA * spu.y;
    var y2  = npz !== 0 ? y1 / npz : y1;
    return { rotation: A, yscale: npz, instRotation: Math.atan2(y2, x1) + Math.PI / 2 };
  }

  function drawShadowAndStickman(ctx, info) {
    var alt = info.alt;
    var az  = 180;                       // the sun is always due south at transit

    // Shadow first, so the figure stands on top of it.
    if (art.stickmanShad && alt >= 0.01) {
      // ShadowMaker.as: the shadow fades out as the sun nears the horizon
      // and its length runs away, capped by lengthLimit.
      var alpha = (100 - 100 / (SHADOW_LENGTH_LIMIT * Math.tan(alt * DEG))) / 100;
      if (alpha > 0) {
        // The shadow lies flat in the ground plane, running directly away
        // from the sun, with  length = height / tan(altitude).
        var shadowAz = mod(az + 180, 360);

        // Basis of the ground plane, projected to screen: one world unit
        // ALONG the shadow, and one world unit ACROSS it. Both come back
        // foreshortened by the current viewing elevation, and they are
        // foreshortened by *different* amounts -- which is exactly what
        // makes a ground shadow look like it is lying down rather than
        // standing up and rotated.
        var along  = groundDirectionToScreen(shadowAz);
        var across = groundDirectionToScreen(mod(shadowAz + 90, 360));

        var worldLength = PERSON_WORLD_HEIGHT / Math.tan(alt * DEG);
        var worldWidth  = PERSON_WORLD_WIDTH;

        var sw = art.stickmanShad.naturalWidth  || 12.3;
        var sh = art.stickmanShad.naturalHeight || 33.55;

        // Map the art's own axes onto that ground basis. The art's +x is its
        // width and its -y is its length (it is drawn standing, feet at the
        // origin), so the second column is negated.
        var kx = worldWidth  / sw;
        var ky = worldLength / sh;

        ctx.save();
        ctx.globalAlpha = Math.min(1, alpha);
        ctx.translate(STAGE_MID, STAGE_MID);
        ctx.transform(across.x * kx, across.y * kx,
                      -along.x * ky, -along.y * ky,
                      0, 0);
        // Anchor the sprite by its registration point so the base of the
        // shadow sits exactly on the figure's feet.
        ctx.drawImage(art.stickmanShad, -sw / 2, -sh * SHADOW_REG_Y, sw, sh);
        ctx.restore();
      }
    }

    if (art.stickman) {
      // The figure is a card standing on the plane, facing south (the
      // direction the sun transits) with the zenith as its up-axis, exactly
      // as initializeHorizonDiagram() set it up. Orienting it this way makes
      // it turn and foreshorten together with the ground when the view is
      // rotated, instead of staying rigidly upright.
      var o = absoluteOrientation(
        horizonToWorld(180, 0, 1),          // n: faces south
        { x: 0, y: 0, z: 1 }                // u: up is the zenith
      );

      var w = PERSON_WORLD_WIDTH  * SPHERE_R;
      var h = PERSON_WORLD_HEIGHT * SPHERE_R;

      ctx.save();
      ctx.translate(STAGE_MID, STAGE_MID);
      ctx.rotate(o.rotation);
      ctx.scale(1, o.yscale);
      ctx.rotate(o.instRotation);
      ctx.drawImage(art.stickman, -w / 2, -h * STICKMAN_REG_Y, w, h);
      ctx.restore();
    }
  }

  // The sun sits at az 180, alt = the day's transit altitude, on the
  // sphere surface (r = 1). Returns its screen position, or null if it is
  // behind the sphere.
  function sunScreen(info) {
    var sp = worldToScreen(horizonToWorld(180, info.alt, 1));
    return sp;
  }

  function drawSun(ctx, info) {
    var sp = sunScreen(info);
    if (!art.sun) { return sp; }
    var w = art.sun.naturalWidth  || 20;
    var h = art.sun.naturalHeight || 20;
    ctx.save();
    ctx.drawImage(art.sun, STAGE_MID + sp.x - w / 2, STAGE_MID + sp.y - h / 2, w, h);
    if (sunFocused && art.sunOutline) {
      var ow = art.sunOutline.naturalWidth  || 22;
      var oh = art.sunOutline.naturalHeight || 22;
      ctx.drawImage(art.sunOutline,
                    STAGE_MID + sp.x - ow / 2, STAGE_MID + sp.y - oh / 2, ow, oh);
    }
    ctx.restore();
    return sp;
  }

  function positionSunHandle(sp) {
    if (!sp) { el['sun-handle'].hidden = true; return; }
    el['sun-handle'].hidden = false;
    el['sun-handle'].style.left = (100 * (STAGE_MID + sp.x) / STAGE_SIZE) + '%';
    el['sun-handle'].style.top  = (100 * (STAGE_MID + sp.y) / STAGE_SIZE) + '%';
  }

  // N / E / S / W placed at their projected positions on the horizon
  // circle, just inside the rim.
  function positionDirectionLabels() {
    var R = 0.88;
    [['dir-n', 0], ['dir-e', 90], ['dir-s', 180], ['dir-w', 270]].forEach(function (pair) {
      var sp = worldToScreen(horizonToWorld(pair[1], 0, R));
      var node = el[pair[0]];
      node.style.left = (100 * (STAGE_MID + sp.x) / STAGE_SIZE) + '%';
      node.style.top  = (100 * (STAGE_MID + sp.y) / STAGE_SIZE) + '%';
      // Fade the two that are on the far side of the sphere, as the
      // original did by drawing them beneath the plane.
      node.style.opacity = (sp.z < 0) ? '0.45' : '1';
    });
  }

  /* ---------------------------------------------------------------------
     Timeline rendering. Month ticks and the no-image bands are code-drawn
     in the original (Timeline.as initialize), so they are reproduced on a
     canvas; the month names are real HTML text so they zoom.
     --------------------------------------------------------------------- */

  function renderTimeline() {
    var canvas = el['timeline-canvas'];
    var dpr = window.devicePixelRatio || 1;
    var needW = Math.round(TIMELINE_W * dpr);
    var needH = Math.round(TIMELINE_H * dpr);
    if (canvas.width !== needW || canvas.height !== needH) {
      canvas.width  = needW;
      canvas.height = needH;
    }
    var ctx = canvas.getContext('2d');
    ctx.setTransform(dpr, 0, 0, dpr, 0, 0);
    ctx.clearRect(0, 0, TIMELINE_W, TIMELINE_H);

    var len = state.len;
    var scale = TIMELINE_W / len;
    var monthPoints = (len === 366) ? MONTH_POINTS_LEAP : MONTH_POINTS_NO_LEAP;

    // Month ticks (mc.moveTo/lineTo at +/- barHeight/2 in the original).
    var midY = 14;
    var hh = 5;
    ctx.strokeStyle = 'currentColor';
    ctx.strokeStyle = getComputedStyle(canvas).color || '#1a1a1a';
    ctx.lineWidth = 1;
    ctx.beginPath();
    for (var i = 0; i < 13; i++) {
      var x = Math.round(scale * monthPoints[i]) + 0.5;
      ctx.moveTo(x, midY - hh);
      ctx.lineTo(x, midY + hh);
    }
    // the baseline the ticks hang from
    ctx.moveTo(0.5, midY);
    ctx.lineTo(TIMELINE_W - 0.5, midY);
    ctx.stroke();

    // "days with no image" band: the missing days, plus the overcast days
    // when the exclude option is on (the two bands of Timeline.as, only
    // one of which is ever visible).
    var y1 = 26, y2 = 40;
    ctx.fillStyle = NO_IMAGE_COLOR;
    var dT = state.dayTable;
    var d = 0;
    while (d < len) {
      var skip = state.excludeOvercast ? (dT[d].missing || dT[d].overcast)
                                       : dT[d].missing;
      if (skip) {
        var lx = scale * d;
        while (d < len && (state.excludeOvercast ? (dT[d].missing || dT[d].overcast)
                                                 : dT[d].missing)) { d++; }
        var rx = scale * d;
        ctx.fillRect(lx, y1, Math.max(1, rx - lx), y2 - y1);
      }
      d++;
    }

    // The shadow cursor: where the animation currently is, shown while
    // animating or dragging (Timeline.as showShadowCursor).
    if (state.showShadowCursor && art.shadowCursor) {
      var sx = state.shadowCursorDay * scale + scale / 2;
      ctx.save();
      ctx.globalAlpha = 0.55;
      ctx.strokeStyle = '#000000';
      ctx.lineWidth = 1;
      ctx.beginPath();
      ctx.moveTo(Math.round(sx) + 0.5, 2);
      ctx.lineTo(Math.round(sx) + 0.5, y2);
      ctx.stroke();
      ctx.restore();
    }

    // The day cursor itself, reusing the exported pointer art.
    var cx = state.currentDay * scale + scale / 2;
    if (art.dayCursor) {
      var w = art.dayCursor.naturalWidth  || 14;
      var h = art.dayCursor.naturalHeight || 43.45;
      ctx.drawImage(art.dayCursor, cx - w / 2, 0, w, Math.min(h, midY + 4));
    }

    // Keep the focusable cursor button over the painted pointer.
    el['day-cursor'].style.left = (100 * cx / TIMELINE_W) + '%';

    layoutMonthLabels(monthPoints, scale);
    syncDayCursorAria();
  }

  var monthLabelsBuilt = false;

  function layoutMonthLabels(monthPoints, scale) {
    var host = el['month-labels'];
    if (!monthLabelsBuilt) {
      host.innerHTML = '';
      for (var i = 0; i < 12; i++) {
        var span = document.createElement('span');
        span.className = 'sim-month-label';
        span.textContent = MONTH_LABELS[i];
        host.appendChild(span);
      }
      monthLabelsBuilt = true;
    }
    var nodes = host.children;
    for (var k = 0; k < 12; k++) {
      var centre = monthPoints[k] + (monthPoints[k + 1] - monthPoints[k]) / 2;
      nodes[k].style.left = (100 * (scale * centre) / TIMELINE_W) + '%';
    }
  }

  /* ---------------------------------------------------------------------
     Readouts. Every number that carries a unit is typeset by MathJax for
     the eye AND written out in words for the ear.
     --------------------------------------------------------------------- */

  function renderReadouts() {
    var info = state.dayTable[state.currentDay];

    el['out-weekday'].textContent = state.dayOfWeekString;
    el['out-daynum'].textContent  = state.dayOfMonthString;
    el['out-month'].textContent   = state.monthString;
    el['out-year'].textContent    = state.yearString;
    el['out-time'].textContent    = state.timeString;

    klunlShowEquation(
      ['eqn-alt', '\\(' + fixed(info.alt, 1) + '^{\\circ}\\)'],
      ['sr-alt', "Sun's altitude " + spokenDegrees(info.alt) + '.']
    );
    klunlShowEquation(
      ['eqn-dec', '\\(' + fixed(info.dec, 1) + '^{\\circ}\\)'],
      ['sr-dec', 'Declination ' + spokenDegrees(info.dec) + '.']
    );

    el['rate-slider'].setAttribute('aria-valuetext', rateSpoken(state.animateRate));
    syncSunHandleAria(info);
  }

  // "minus 6.3 degrees" reads unambiguously on both NVDA and VoiceOver;
  // a bare "-6.3" is often dropped or read as a dash.
  function spokenDegrees(value) {
    var v = fixed(value, 1);
    if (v.charAt(0) === '-') { return 'minus ' + v.slice(1) + ' degrees'; }
    return v + ' degrees';
  }

  function spokenDate() {
    return state.dayOfWeekString + ', ' + state.monthString + ' ' +
           state.dayOfMonthString + ', ' + state.yearString;
  }

  function spokenTime() {
    var zone = TIME_ZONE_WORDS[state.timeZone] || state.timeZone;
    // "1:13 pm CDT" -> "1:13 p m, Central Daylight Time"
    var clock = state.timeString
      .replace(' ' + state.timeZone, '')
      .replace(' pm', '')
      .trim();
    return clock + ' p m, ' + zone;
  }

  function syncSunHandleAria(info) {
    var h = el['sun-handle'];
    h.setAttribute('aria-valuenow', fixed(info.dec, 1));
    h.setAttribute('aria-valuetext',
      "Sun's declination " + spokenDegrees(info.dec) +
      ', on ' + spokenDate() + '.');
  }

  function syncDayCursorAria() {
    var c = el['day-cursor'];
    c.setAttribute('aria-valuemin', '0');
    c.setAttribute('aria-valuemax', String(state.len - 1));
    c.setAttribute('aria-valuenow', String(state.currentDay));
    c.setAttribute('aria-valuetext',
      spokenDate() + ', day ' + (state.currentDay + 1) + ' of ' + state.len + '.');
  }

  /* ---------------------------------------------------------------------
     Text equivalents for the two graphics, refreshed from the same state
     so an audio-only user gets what a sighted user sees.
     --------------------------------------------------------------------- */

  function renderDescriptions() {
    var info = state.dayTable[state.currentDay];

    el['photo-desc'].textContent =
      'Webcam photograph of Memorial Plaza at the University of Nebraska, ' +
      'looking east, taken on ' + spokenDate() + ' at ' + spokenTime() +
      ', when the sun reached its highest point in the sky. ' +
      (info.overcast ? 'This is an overcast day, so the building casts no shadow.'
                     : 'The building casts a shadow across the plaza.');

    el['photo'].setAttribute('alt', el['photo-desc'].textContent);

    var viewerAz = mod(360 - state.theta / DEG, 360);
    el['stage-desc'].textContent =
      "Horizon diagram for latitude 40.8 degrees north. The sun is due south " +
      'at an altitude of ' + spokenDegrees(info.alt) + ', with a declination of ' +
      spokenDegrees(info.dec) + '. Its yellow daily path lies between the two ' +
      'white declination limit circles at plus and minus 23.44 degrees, which ' +
      'mark the summer and winter solstices, and crosses the blue celestial ' +
      'equator at the equinoxes. A figure stands at the centre of the green ' +
      'horizon plane casting a shadow. The view faces azimuth ' +
      fixed(viewerAz, 0) + ' degrees from an elevation of ' +
      fixed(state.phi / DEG, 0) + ' degrees.';
  }

  /* ---------------------------------------------------------------------
     Live region. Announcements are made on commit -- on release, on a key
     press, on a checkbox change -- never on every animation tick.
     --------------------------------------------------------------------- */

  /* ---------------------------------------------------------------------
     MathJax v3 puts tabindex="0" on every mjx-container so its context
     menu can be reached from the keyboard. Typeset maths is display-only
     output here, not a control, so it must not be a tab stop: the
     containers are demoted to tabindex="-1". That still leaves the
     right-click "Show Math As" menu working, and the maths is still read
     aloud through the paired .sr-only descriptions.
     --------------------------------------------------------------------- */

  function dropMathTabStops(root) {
    var scope = root && root.querySelectorAll ? root : document;
    var nodes = scope.querySelectorAll('mjx-container[tabindex="0"]');
    for (var i = 0; i < nodes.length; i++) {
      nodes[i].setAttribute('tabindex', '-1');
    }
  }

  function watchMathTabStops() {
    dropMathTabStops(document);
    if (!window.MutationObserver) { return; }
    new MutationObserver(function (records) {
      for (var i = 0; i < records.length; i++) {
        var added = records[i].addedNodes;
        for (var j = 0; j < added.length; j++) {
          var n = added[j];
          if (n.nodeType !== 1) { continue; }
          if (n.tagName && n.tagName.toLowerCase() === 'mjx-container') {
            n.setAttribute('tabindex', '-1');
          } else {
            dropMathTabStops(n);
          }
        }
      }
    }).observe(document.body, { childList: true, subtree: true });
  }

  var announceTimer = null;

  function announce(message) {
    if (announceTimer) { clearTimeout(announceTimer); }
    announceTimer = setTimeout(function () {
      el['live-region'].textContent = message;
    }, 60);
  }

  function announceDay() {
    var info = state.dayTable[state.currentDay];
    announce(spokenDate() + '. Sun\'s altitude ' + spokenDegrees(info.alt) +
             ', declination ' + spokenDegrees(info.dec) + '.');
  }

  /* ======================================================================
     Pointer and keyboard wiring.

     Every draggable element has BOTH a pointer path and a keyboard path,
     and both mutate the same state object.
     ====================================================================== */

  // Map a pointer event to the sphere's internal stage coordinates,
  // relative to the sphere's centre -- so the drag maths runs in the
  // original Flash units at any display size.
  function pointerToStage(ev, node) {
    var rect = node.getBoundingClientRect();
    var scale = rect.width / STAGE_SIZE;
    return {
      x: (ev.clientX - rect.left) / scale - STAGE_MID,
      y: (ev.clientY - rect.top)  / scale - STAGE_MID
    };
  }

  var sunFocused = false;

  function wireSunDrag() {
    var handle = el['sun-handle'];
    var stage  = el['sim-stage'];
    var decOffset = 0;
    var dragging = false;
    var resumeAnimation = false;

    handle.addEventListener('pointerdown', function (ev) {
      ev.preventDefault();
      ev.stopPropagation();               // do not also start a view rotation
      handle.focus();                     // click-to-focus (rule: both paths)
      resumeAnimation = state.animating;
      setAnimateState(false);

      var p = pointerToStage(ev, stage);
      var m = stageToRaDec(p.x, p.y);
      var info = state.dayTable[state.currentDay];
      decOffset = (m.dec === null) ? 0 : m.dec - info.dec;
      dragging = true;
      handle.setPointerCapture(ev.pointerId);
    });

    handle.addEventListener('pointermove', function (ev) {
      if (!dragging) { return; }
      var p = pointerToStage(ev, stage);
      var m = stageToRaDec(p.x, p.y);
      if (m.dec !== null) {
        setSunDec(m.dec - decOffset);
        render();
      }
    });

    function endDrag(ev) {
      if (!dragging) { return; }
      dragging = false;
      if (ev && ev.pointerId !== undefined && handle.hasPointerCapture(ev.pointerId)) {
        handle.releasePointerCapture(ev.pointerId);
      }
      if (resumeAnimation) { setAnimateState(true); }
      render();
      announceDay();                      // announce on commit, not per move
    }

    handle.addEventListener('pointerup', endDrag);
    handle.addEventListener('pointercancel', endDrag);

    handle.addEventListener('focus', function () { sunFocused = true;  render(); });
    handle.addEventListener('blur',  function () { sunFocused = false; render(); });

    // Keyboard: the sun steps through the year by day, which is the same
    // quantity the drag changes.
    handle.addEventListener('keydown', function (ev) {
      var handled = true;
      switch (ev.key) {
        case 'ArrowUp':
        case 'ArrowRight': stepDay(1);  break;
        case 'ArrowDown':
        case 'ArrowLeft':  stepDay(-1); break;
        case 'PageUp':     stepDay(7);  break;
        case 'PageDown':   stepDay(-7); break;
        case 'Home':
          setAnimateState(false);
          setSunDec(state.data.maxDec);   // summer solstice
          break;
        case 'End':
          setAnimateState(false);
          setSunDec(state.data.minDec);   // winter solstice
          break;
        default: handled = false;
      }
      if (handled) {
        ev.preventDefault();
        render();
        announceDay();
      }
    });

    // Mouse wheel over the focused sun steps the day, matching the
    // numeric-field wheel behaviour used elsewhere in the sim.
    handle.addEventListener('wheel', function (ev) {
      if (document.activeElement !== handle) { return; }
      ev.preventDefault();
      stepDay(ev.deltaY < 0 ? 1 : -1);
      render();
      announceDay();
    }, { passive: false });
  }

  function stepDay(delta) {
    setAnimateState(false);
    if (delta > 0) { incrementUpBy(delta); }
    else           { incrementDownBy(-delta); }
  }

  // Rotating the view: drag anywhere on the sphere, as in the original
  // (setMouseBehavior('simple drag')), or focus and use the arrow keys.
  function wireViewDrag() {
    var handle = el['view-handle'];
    var stage  = el['sim-stage'];
    var dragging = false;
    var start = null;

    handle.addEventListener('pointerdown', function (ev) {
      ev.preventDefault();
      handle.focus();
      var p = pointerToStage(ev, stage);
      if (Math.sqrt(p.x * p.x + p.y * p.y) > SPHERE_R) { return; }
      start = { x: p.x, y: p.y, theta: state.theta, phi: state.phi };
      dragging = true;
      handle.setPointerCapture(ev.pointerId);
    });

    handle.addEventListener('pointermove', function (ev) {
      if (!dragging) { return; }
      var p = pointerToStage(ev, stage);
      // updateSimpleDragging(), in the source's own units
      setThetaAndPhi((start.theta - (p.x - start.x) / SPHERE_R) / DEG,
                     (start.phi   + (p.y - start.y) / SPHERE_R) / DEG);
      render();
    });

    function endDrag(ev) {
      if (!dragging) { return; }
      dragging = false;
      if (ev && ev.pointerId !== undefined && handle.hasPointerCapture(ev.pointerId)) {
        handle.releasePointerCapture(ev.pointerId);
      }
      announceView();
    }

    handle.addEventListener('pointerup', endDrag);
    handle.addEventListener('pointercancel', endDrag);

    handle.addEventListener('keydown', function (ev) {
      var step = ev.shiftKey ? 15 : 5;
      var handled = true;
      var az  = mod(360 - state.theta / DEG, 360);
      var alt = state.phi / DEG;
      switch (ev.key) {
        case 'ArrowLeft':  setViewerAzimuth(az - step); break;
        case 'ArrowRight': setViewerAzimuth(az + step); break;
        case 'ArrowUp':    setThetaAndPhi(state.theta / DEG, alt + step); break;
        case 'ArrowDown':  setThetaAndPhi(state.theta / DEG, alt - step); break;
        case 'PageUp':     setThetaAndPhi(state.theta / DEG, alt + 15); break;
        case 'PageDown':   setThetaAndPhi(state.theta / DEG, alt - 15); break;
        case 'Home':
          // back to the original viewing direction
          setViewerAzimuth(VIEWER_AZIMUTH);
          setThetaAndPhi(state.theta / DEG, VIEWER_ALTITUDE);
          break;
        default: handled = false;
      }
      if (handled) {
        ev.preventDefault();
        render();
        announceView();
      }
    });
  }

  function setThetaAndPhi(thetaDeg, phiDeg) {
    state.theta = mod(thetaDeg, 360) * DEG;
    var p = phiDeg;
    if (p > MAX_VIEWER_ALTITUDE)      { p = MAX_VIEWER_ALTITUDE; }
    else if (p < MIN_VIEWER_ALTITUDE) { p = MIN_VIEWER_ALTITUDE; }
    state.phi = p * DEG;
  }

  function setViewerAzimuth(azDeg) {
    state.theta = mod(360 - azDeg, 360) * DEG;
  }

  function announceView() {
    var az = mod(360 - state.theta / DEG, 360);
    announce('View facing azimuth ' + fixed(az, 0) +
             ' degrees, elevation ' + fixed(state.phi / DEG, 0) + ' degrees.');
    renderDescriptions();
  }

  // The timeline: drag the cursor, press elsewhere on the strip to step
  // toward the press (with the original's press-and-hold acceleration),
  // or focus the cursor and use the keyboard.
  function wireTimeline() {
    var strip  = el['timeline'];
    var cursor = el['day-cursor'];
    var dragging = false;
    var offset = 0;
    var resumeAnimation = false;
    var holdTimer = null;

    function stripScale() {
      return strip.getBoundingClientRect().width / state.len;
    }

    function dayFromClientX(clientX) {
      var rect = strip.getBoundingClientRect();
      return Math.floor(mod(clientX - rect.left - offset, rect.width) / (rect.width / state.len));
    }

    cursor.addEventListener('pointerdown', function (ev) {
      ev.preventDefault();
      ev.stopPropagation();
      cursor.focus();
      resumeAnimation = state.animating;
      setAnimateState(false);
      var rect = strip.getBoundingClientRect();
      offset = (ev.clientX - rect.left) - (state.currentDay * stripScale() + stripScale() / 2);
      dragging = true;
      state.showShadowCursor = true;
      state.shadowCursorDay = state.currentDay;
      cursor.setPointerCapture(ev.pointerId);
      render();
    });

    cursor.addEventListener('pointermove', function (ev) {
      if (!dragging) { return; }
      var day = dayFromClientX(ev.clientX);
      state.shadowCursorDay = day;
      setDay(day);
      render();
    });

    function endCursorDrag(ev) {
      if (!dragging) { return; }
      dragging = false;
      state.showShadowCursor = false;
      if (ev && ev.pointerId !== undefined && cursor.hasPointerCapture(ev.pointerId)) {
        cursor.releasePointerCapture(ev.pointerId);
      }
      if (resumeAnimation) { setAnimateState(true); }
      render();
      announceDay();
    }

    cursor.addEventListener('pointerup', endCursorDrag);
    cursor.addEventListener('pointercancel', endCursorDrag);

    cursor.addEventListener('keydown', function (ev) {
      var handled = true;
      switch (ev.key) {
        case 'ArrowRight':
        case 'ArrowUp':    stepDay(1);   break;
        case 'ArrowLeft':
        case 'ArrowDown':  stepDay(-1);  break;
        case 'PageUp':     stepDay(30);  break;
        case 'PageDown':   stepDay(-30); break;
        case 'Home':       setAnimateState(false); setDay(0); break;
        case 'End':        setAnimateState(false); setDay(state.len - 1); break;
        default: handled = false;
      }
      if (handled) {
        ev.preventDefault();
        render();
        announceDay();
      }
    });

    cursor.addEventListener('wheel', function (ev) {
      if (document.activeElement !== cursor) { return; }
      ev.preventDefault();
      stepDay(ev.deltaY < 0 ? 1 : -1);
      render();
      announceDay();
    }, { passive: false });

    // Press-and-hold on the strip itself: one step immediately, then
    // repeat after delayTime at incrementRate days per millisecond.
    strip.addEventListener('pointerdown', function (ev) {
      if (ev.target === cursor) { return; }
      ev.preventDefault();
      resumeAnimation = state.animating;
      setAnimateState(false);

      var rect = strip.getBoundingClientRect();
      var pressX = ev.clientX - rect.left;
      var cursorX = state.currentDay * stripScale() + stripScale() / 2;
      var dir = (pressX > cursorX) ? 1 : -1;

      stepOnce(dir);

      var startTime = performance.now();
      var timeLastHold = startTime;
      holdTimer = setInterval(function () {
        var now = performance.now();
        if (now - startTime < TIMELINE_DELAY_TIME) { timeLastHold = now; return; }
        var n = Math.floor((now - timeLastHold) * TIMELINE_INCREMENT_RATE);
        if (n > 0) {
          stepOnce(dir, n);
          timeLastHold += n / TIMELINE_INCREMENT_RATE;
        }
      }, 30);

      function stepOnce(d, n) {
        n = n || 1;
        if (d > 0) { incrementUpBy(n); } else { incrementDownBy(n); }
        render();
      }
    });

    function releaseHold() {
      if (holdTimer !== null) {
        clearInterval(holdTimer);
        holdTimer = null;
        if (resumeAnimation) { setAnimateState(true); }
        announceDay();
      }
    }

    window.addEventListener('pointerup', releaseHold);
    window.addEventListener('pointercancel', releaseHold);
  }

  function wireControls() {
    el['btn-animate'].addEventListener('click', toggleAnimateButton);

    // Native range input: arrows, Page keys and Home/End all come free.
    var rate = el['rate-slider'];
    rate.addEventListener('input', function () {
      state.animateRate = sliderPosToRate(parseFloat(rate.value));
      rate.setAttribute('aria-valuetext', rateSpoken(state.animateRate));
    });
    rate.addEventListener('change', function () {
      announce(rateSpoken(state.animateRate) + '.');
    });
    // Wheel adjustment while focused, per the numeric-field requirement.
    rate.addEventListener('wheel', function (ev) {
      if (document.activeElement !== rate) { return; }
      ev.preventDefault();
      var step = 25;
      var next = Math.max(0, Math.min(1000,
                   parseFloat(rate.value) + (ev.deltaY < 0 ? step : -step)));
      rate.value = String(next);
      state.animateRate = sliderPosToRate(next);
      rate.setAttribute('aria-valuetext', rateSpoken(state.animateRate));
      announce(rateSpoken(state.animateRate) + '.');
    }, { passive: false });

    el['chk-directions'].addEventListener('change', function (ev) {
      state.showDirections = ev.target.checked;
      render();
      announce(state.showDirections
        ? 'Direction labels shown on the photograph.'
        : 'Direction labels hidden.');
    });

    el['chk-overcast'].addEventListener('change', function (ev) {
      state.excludeOvercast = ev.target.checked;
      // onExcludeOvercastChange(): re-select the current day under the
      // new rule, which may walk back to the previous usable day.
      setDay(state.currentDay);
      render();
      announce(state.excludeOvercast
        ? 'Overcast days excluded. Showing ' + spokenDate() + '.'
        : 'Overcast days included. Showing ' + spokenDate() + '.');
    });

    // Reset comes from the masthead component; never a second button.
    document.addEventListener('sim-reset', function () {
      resetToInitialState();
    });

    // Keep the layout honest when the viewport or zoom changes.
    window.addEventListener('resize', function () { render(); });
  }

  function resetToInitialState() {
    setAnimateState(false);
    state.excludeOvercast = false;
    state.showDirections  = false;
    state.animateRate     = RATE_INIT;
    state.theta = (360 - VIEWER_AZIMUTH) * DEG;
    state.phi   = VIEWER_ALTITUDE * DEG;
    state.lastInterval = 0;
    state.atSolstice   = false;
    state.showShadowCursor = false;

    el['chk-overcast'].checked   = false;
    el['chk-directions'].checked = false;
    el['rate-slider'].value = String(rateToSliderPos(RATE_INIT));

    setDay(DEFAULT_START_DAY);
    state.animateDay = state.currentDay;
    syncAnimateButton();
    render();
    announce('Simulation reset. Showing ' + spokenDate() + '.');
  }

  /* ======================================================================
     Start-up.
     ====================================================================== */

  // klunlInitEqn is called by the foundation on load; redefining it here
  // is the documented way to initialise a sim's equations.
  window.klunlInitEqn = function () {
    klunlShowEquation(
      ['eqn-location', '\\(40.8^{\\circ}\\,\\mathrm{N},\\ 96.7^{\\circ}\\,\\mathrm{W}\\)'],
      ['sr-location', 'Latitude 40.8 degrees north, longitude 96.7 degrees west.']
    );
    if (state.dayTable) { renderReadouts(); }
  };

  function boot() {
    grab();

    Promise.all([
      fetch('assets/daydata.json').then(function (r) { return r.json(); }),
      loadArt()
    ]).then(function (results) {
      state.data     = results[0];
      state.dayTable = state.data.dayTable;
      state.len      = state.dayTable.length;

      analyzeDayTable();

      el['rate-slider'].value = String(rateToSliderPos(RATE_INIT));
      state.animateRate = RATE_INIT;

      // The original honours a ?startDay= parameter, falling back to 282.
      var params = new URLSearchParams(window.location.search);
      var start = DEFAULT_START_DAY;
      if (params.has('startDay')) {
        var parsed = parseInt(params.get('startDay'), 10);
        if (isFinite(parsed) && !isNaN(parsed)) { start = mod(parsed, state.len); }
      }
      setDay(start);
      state.animateDay = state.currentDay;

      wireSunDrag();
      wireViewDrag();
      wireTimeline();
      wireControls();

      syncAnimateButton();
      render();
      window.klunlInitEqn();
      watchMathTabStops();
    }).catch(function (err) {
      console.error('Failed to start the simulation:', err);
      el['live-region'].textContent =
        'The simulation data could not be loaded. It must be served over HTTP; ' +
        'see README.md.';
    });
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', boot);
  } else {
    boot();
  }

})();
