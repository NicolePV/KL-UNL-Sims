/* ===========================================================================
   Milky Way Rotational Velocity Explorer
   HTML5 port of milkyWayRotationalVelocity005.swf (Flash / ActionScript 1).

   Behaviour is a faithful port of:
     scripts/Milky Way Rotational Velocity.as   (plot, snapping, equation)
     scripts/MWRV Draggable Point.as            (drag)
     scripts/Milky Way Component.as             (galactic disc overlay)
     scripts/Scientific Notation Number.as      (mass formatting)
     scripts/Number Formatting Functions.as     (toFixed / toSigDigits)

   All constants, tables and number formatting below are copied verbatim from
   those files. The physics being modelled is the enclosed-mass relation

        M = V^2 R / G          (mass inside radius R implied by a circular
                                orbital speed V at that radius)

   with G expressed in kpc (km/s)^2 / M_sun.
   =========================================================================== */

(function () {
  'use strict';

  /* =========================================================================
     1. Verbatim constants from the ActionScript source
     ========================================================================= */

  // Milky Way Rotational Velocity.as -> p.updateEquation
  var G = 0.000004298675311966532;               // kpc (km/s)^2 / M_sun

  // Milky Way Rotational Velocity.as -> prototype properties
  var PLOT_WIDTH   = 500;                        // px  <-> 40 kpc
  var PLOT_HEIGHT  = 250;                        // px  <-> 300 km/s
  var MAX_DISTANCE = 40;                         // kpc
  var MAX_VELOCITY = 300;                        // km/s

  var X_SCALE = MAX_DISTANCE / PLOT_WIDTH;       //  0.08  kpc  per plot px
  var Y_SCALE = -MAX_VELOCITY / PLOT_HEIGHT;     // -1.2   km/s per plot px

  var POINTS_X_SCALE = 0.055031446540880505 / X_SCALE;
  var POINTS_Y_SCALE = -1.1070110701107012 / Y_SCALE;

  var START_POINT = { x: 7.75, y: 0 };

  // The rotation curve: a chain of quadratic Beziers in "points space".
  var POINTS_LIST = [
    { cx:  15.9, cy: -134.3, ax:  20.7, ay: -219.8 },
    { cx:  21.5, cy: -233.1, ax:  34.7, ay: -222.9 },
    { cx:  49.1, cy: -211.7, ax:  59.0, ay: -196.2 },
    { cx:  69.2, cy: -180.0, ax:  86.8, ay: -183.2 },
    { cx:  95.9, cy: -184.8, ax: 110.0, ay: -201.5 },
    { cx: 121.5, cy: -215.3, ax: 133.0, ay: -214.0 },
    { cx: 147.2, cy: -212.4, ax: 158.3, ay: -200.8 },
    { cx: 167.6, cy: -191.0, ax: 182.0, ay: -192.1 },
    { cx: 192.4, cy: -192.8, ax: 204.5, ay: -206.1 },
    { cx: 212.4, cy: -214.7, ax: 222.8, ay: -218.8 },
    { cx: 232.6, cy: -222.6, ax: 250.0, ay: -221.9 },
    { cx: 260.6, cy: -221.5, ax: 269.3, ay: -220.6 },
    { cx: 278.7, cy: -219.6, ax: 287.5, ay: -219.7 },
    { cx: 296.2, cy: -219.8, ax: 308.0, ay: -222.9 },
    { cx: 316.4, cy: -225.1, ax: 328.3, ay: -225.0 },
    { cx: 394.2, cy: -224.0, ax: 513.0, ay: -236.2 },
    { cx: 582.3, cy: -243.2, ax: 710.3, ay: -263.7 }
  ];

  var LEFTMOST_X  = START_POINT.x * POINTS_X_SCALE;
  var RIGHTMOST_X = POINTS_LIST[POINTS_LIST.length - 1].ax * POINTS_X_SCALE;
  var RIGHTMOST_Y = POINTS_LIST[POINTS_LIST.length - 1].ay * POINTS_Y_SCALE;

  // Milky Way Rotational Velocity.as -> constructor: attachMovie(..., {_x:100})
  var INITIAL_POINT_X = 100;
  var INITIAL_POINT_Y = 0;

  // Milky Way Component.as
  var GALAXY_SCALE       = 8.36;   // px per kpc inside the 350 x 350 disc view
  var GALAXY_STAGE       = 350;
  var GALAXY_NUM_POINTS  = 12;     // precomputePoints(12)

  // Colours, from the AS decimal colour ints / the exported shapes.
  //   16740464 = #FF7070 (rotation curve)   -> darkened for WCAG 1.4.11
  //   16711680 = #FF0000 (galactic disc)
  //     #009900          (dashed guide lines, shapes/15.svg)
  var CURVE_COLOR      = '#e85c50';
  var CURVE_FILL_ALPHA = 0.20;                 // beginFill(16711680, 20)
  var DISC_COLOR       = '#ff0000';
  var DISC_FILL        = 'rgba(255, 0, 0, 0.2)';
  var GUIDE_COLOR      = '#009900';
  var AXIS_COLOR       = '#000000';

  /* Plot canvas geometry. The canvas keeps the ORIGINAL Flash plot coordinate
     system: the origin below is the (0,0) corner of the axes, x runs right in
     plot px (500 px = 40 kpc) and y runs UP as negative (250 px = 300 km/s).
     The extra margin only makes room for the tick marks and the axis
     arrowheads (exported shapes/64.svg, 65.svg and 79.svg). */
  var STAGE = { W: 540, H: 318, OX: 16, OY: 302 };

  var AXIS_X_END = 500;   // shapes/64.svg: M500,0 L0,0 L0,-290
  var AXIS_Y_END = -290;

  var X_TICKS = [0, 5, 10, 15, 20, 25, 30, 35];       // kpc,  shapes/65.svg
  var Y_TICKS = [0, 100, 200, 300];                   // km/s, shapes/65.svg
  var TICK_LEN = 10;

  // shapes/79.svg, apex up, drawn about its own origin.
  var ARROW_PATH = [[4.45, 7.1], [0, 3.7], [-4.4, 7.1], [0.05, -7.1]];

  // shapes/15.svg: round dots of radius 1, first centre at 2.25, pitch 5.
  var DASH_FIRST = 2.25;
  var DASH_PITCH = 5;
  var DASH_RADIUS = 1;
  var DASH_LAST = 592.25;

  /* =========================================================================
     2. Number formatting, ported verbatim
     ========================================================================= */

  // Number.prototype.toFixed polyfill from Number Formatting Functions.as.
  // (It rounds x*10^d with Math.round, which differs from the native toFixed
  //  at some binary-representation boundaries -- so it is reproduced exactly.)
  function asToFixed(value, fractionDigits) {
    var f = fractionDigits | 0;
    if (f < 0 || f > 20) { return 'Range Error'; }

    var x = value;
    if (isNaN(x)) { return 'NaN'; }

    var s = '';
    if (x < 0) { s = '-'; x = -x; }

    var m = '';
    if (x < 1e21) {
      var n = Math.round(x * Math.pow(10, f));
      m = (n === 0) ? '0' : n.toString();
      if (f > 0) {
        var k = m.length;
        if (k <= f) {
          var z = '';
          for (var i = 0; i < f + 1 - k; i++) { z += '0'; }
          m = z + m;
          k = f + 1;
        }
        m = m.substr(0, k - f) + '.' + m.substr(k - f);
      }
    } else {
      m = x.toString();
    }
    return s + m;
  }

  // Math.toSigDigits from Number Formatting Functions.as. Returns a NUMBER;
  // the AS then relies on implicit String() conversion for display.
  function asToSigDigits(value, digits) {
    var num = parseFloat(value);
    var digs = Math.abs(parseInt(digits, 10));
    if (!isFinite(digs) || !isFinite(num)) { return NaN; }
    if (num === 0 || digs === 0) { return 0; }
    if (digs > 15) { digs = 15; }

    var sign = 1;
    if (num < 0) { sign = -1; num = Math.abs(num); }

    var tmp = Math.floor(Math.log(num) / 2.302585092994046);
    var fact = Math.pow(10, digs - (1 + tmp));
    return sign * (Math.round(fact * num) / fact);
  }

  // ScientificNotationNumberClass.getCoefficientAndExponent, verbatim.
  function asCoefficientAndExponent(value, sigFigs) {
    var num = value;
    var digs = sigFigs;
    var result = {};
    var s, i;

    if (!isFinite(num) || isNaN(num)) {
      return { coefficient: '...', exponent: '...' };
    }

    if (num === 0) {
      s = '0';
      var extraZeros = digs - 1;
      if (extraZeros !== 0) {
        s += '.';
        for (i = 0; i < extraZeros; i++) { s += '0'; }
      }
      return { coefficient: s, exponent: '0' };
    }

    if (num < 0) { result.coefficient = '-'; num = Math.abs(num); }
    else         { result.coefficient = ''; }

    var expo = Math.floor(Math.log(num) / 2.302585092994046);
    var expoFact = Math.pow(10, -expo);
    var fact = Math.pow(10, digs - 1);
    var num2 = Math.round(fact * expoFact * num) / fact;
    if (num2 >= 10) { num2 /= 10; expo++; }

    s = String(num2);
    var addDot = (s.indexOf('.') === -1);

    var sigfigs = 0;
    for (i = 0; i < s.length; i++) {
      var code = s.charCodeAt(i);
      if (code > 47 && code < 58) { sigfigs++; }
    }

    var numZeros = digs - sigfigs;
    if (numZeros > 0 && addDot === true) { s += '.'; }
    for (i = 0; i < numZeros; i++) { s += '0'; }

    result.coefficient += s;
    result.exponent = String(expo);
    return result;
  }

  /* =========================================================================
     3. The rotation curve: segments, snapping, arc length
     ========================================================================= */

  // Segment i is the quadratic Bezier (p0, control, p1) in points space.
  var SEGMENTS = (function () {
    var segs = [];
    var prev = START_POINT;
    for (var i = 0; i < POINTS_LIST.length; i++) {
      var p = POINTS_LIST[i];
      segs.push({
        x0: prev.x, y0: prev.y,
        x1: p.cx,   y1: p.cy,
        x2: p.ax,   y2: p.ay
      });
      prev = { x: p.ax, y: p.ay };
    }
    return segs;
  })();

  function bezierAt(seg, u) {
    var a = (1 - u) * (1 - u);
    var b = 2 * u * (1 - u);
    var c = u * u;
    return {
      x: POINTS_X_SCALE * (a * seg.x0 + b * seg.x1 + c * seg.x2),
      y: POINTS_Y_SCALE * (a * seg.y0 + b * seg.y1 + c * seg.y2)
    };
  }

  /* The AS solves a quadratic for the Bezier parameter and then picks a root
     with this exact branch structure. Note that in the fall-through branch the
     source reads `d1 -= 1` / `d2 -= 1` on variables that were never assigned;
     both therefore evaluate to NaN, `d1 < d2` is false, and the second root is
     always taken (then clamped to [0,1]). That behaviour is preserved here. */
  function solveParam(a, b, c) {
    var u, d1, d2;
    var d = b * b - 4 * a * c;

    if (a === 0) {
      u = (-c) / b;
    } else if (d < 0) {
      u = 0.5;
    } else {
      var u1 = (-b + Math.sqrt(d)) / (2 * a);
      var u2 = (-b - Math.sqrt(d)) / (2 * a);
      if (u1 >= 0 && u1 <= 1) {
        u = u1;
      } else if (u2 >= 0 && u2 <= 1) {
        u = u2;
      } else {
        if (u1 < 0) { d1 = -u1; } else { d1 = d1 - 1; }   // NaN, as in the AS
        if (u2 < 0) { d2 = -u2; } else { d2 = d2 - 1; }   // NaN, as in the AS
        u = (d1 < d2) ? u1 : u2;
        if (u < 0) { u = 0; } else if (u > 1) { u = 1; }
      }
    }
    return u;
  }

  /* p.snapPointToCurve, verbatim. Operates on state.pointX / state.pointY,
     which are the Flash pointMC._x / pointMC._y in plot coordinates. */
  function snapPointToCurve() {
    if (state.pointY > -100) { state.pointY = -100; }
    if (state.pointX < 10)   { state.pointX = 10; }

    var x = state.pointX;
    var seg, u, pt;

    if (x <= LEFTMOST_X) {
      // Unreachable in practice (the x >= 10 clamp above already exceeds
      // LEFTMOST_X = 5.33), but ported for fidelity.
      state.pointX = LEFTMOST_X;
      state.pointY = 0;
    } else if (x >= RIGHTMOST_X) {
      state.pointX = RIGHTMOST_X;
      state.pointY = RIGHTMOST_Y;
    } else {
      var pL = POINTS_LIST;
      var xu = x / POINTS_X_SCALE;

      if (xu < pL[0].ax) {
        // The first segment is very nearly vertical, so the AS matches on Y.
        var yu = state.pointY / POINTS_Y_SCALE;
        seg = SEGMENTS[0];
        u = solveParam(seg.y0 - 2 * seg.y1 + seg.y2,
                       2 * seg.y1 - 2 * seg.y0,
                       seg.y0 - yu);
        pt = bezierAt(seg, u);
        state.pointX = pt.x;
        state.pointY = pt.y;
      } else {
        for (var i = 1; i < pL.length; i++) {
          if (xu < pL[i].ax) {
            seg = SEGMENTS[i];
            u = solveParam(seg.x0 - 2 * seg.x1 + seg.x2,
                           2 * seg.x1 - 2 * seg.x0,
                           seg.x0 - xu);
            pt = bezierAt(seg, u);
            state.pointX = pt.x;
            state.pointY = pt.y;
            break;
          }
        }
      }
    }
  }

  /* --- Arc-length table -----------------------------------------------------
     Used only by the keyboard path, so that arrow keys walk the curve at an
     even visual pace -- including up the steep inner rise, where a step in x
     would barely move the cursor but the speed changes by tens of km/s.
     The pointer path never uses this; it runs the AS snapping above. */

  var SUB_STEPS = 96;
  var ARC = { s: [], x: [], y: [], g: [], total: 0 };

  function buildArcTable() {
    var prev = bezierAt(SEGMENTS[0], 0);
    var s = 0;
    ARC.s.push(0); ARC.x.push(prev.x); ARC.y.push(prev.y); ARC.g.push(0);

    for (var i = 0; i < SEGMENTS.length; i++) {
      for (var k = 1; k <= SUB_STEPS; k++) {
        var u = k / SUB_STEPS;
        var pt = bezierAt(SEGMENTS[i], u);
        s += Math.sqrt((pt.x - prev.x) * (pt.x - prev.x) +
                       (pt.y - prev.y) * (pt.y - prev.y));
        ARC.s.push(s); ARC.x.push(pt.x); ARC.y.push(pt.y); ARC.g.push(i + u);
        prev = pt;
      }
    }
    ARC.total = s;
  }

  function lerpIndex(arr, value) {
    // arr is ascending; returns a fractional index for `value`.
    var lo = 0, hi = arr.length - 1;
    if (value <= arr[0])  { return 0; }
    if (value >= arr[hi]) { return hi; }
    while (hi - lo > 1) {
      var mid = (lo + hi) >> 1;
      if (arr[mid] <= value) { lo = mid; } else { hi = mid; }
    }
    var span = arr[hi] - arr[lo];
    return lo + (span > 0 ? (value - arr[lo]) / span : 0);
  }

  function pointAtArc(s) {
    var fi = lerpIndex(ARC.s, s);
    var i = Math.floor(fi);
    var t = fi - i;
    var g = (i + 1 < ARC.g.length) ? ARC.g[i] + t * (ARC.g[i + 1] - ARC.g[i])
                                   : ARC.g[i];
    var segIndex = Math.min(Math.floor(g), SEGMENTS.length - 1);
    var u = Math.min(Math.max(g - segIndex, 0), 1);
    return bezierAt(SEGMENTS[segIndex], u);
  }

  function arcAtX(px) {
    // x is monotonically increasing along the whole curve.
    var fi = lerpIndex(ARC.x, px);
    var i = Math.floor(fi);
    var t = fi - i;
    return (i + 1 < ARC.s.length) ? ARC.s[i] + t * (ARC.s[i + 1] - ARC.s[i])
                                  : ARC.s[i];
  }

  /* The lowest point the Flash cursor can reach is where the y >= -100 clamp
     bites on the first segment (120 km/s). The keyboard range is limited to
     the same reachable stretch of curve so both input paths agree. */
  var ARC_MIN = 0, ARC_MAX = 0, MIN_DISTANCE = 0, MAX_DISTANCE_REACHABLE = 0;

  function computeArcLimits() {
    var seg = SEGMENTS[0];
    var yu = -100 / POINTS_Y_SCALE;
    var u = solveParam(seg.y0 - 2 * seg.y1 + seg.y2,
                       2 * seg.y1 - 2 * seg.y0,
                       seg.y0 - yu);
    var pt = bezierAt(seg, u);
    ARC_MIN = arcAtX(pt.x);
    ARC_MAX = ARC.total;
    MIN_DISTANCE = X_SCALE * pt.x;
    MAX_DISTANCE_REACHABLE = X_SCALE * RIGHTMOST_X;
  }

  var ARROW_STEPS = 240;   // arrow presses to traverse the whole curve
  function arrowStep() { return (ARC_MAX - ARC_MIN) / ARROW_STEPS; }

  /* =========================================================================
     4. State  (single source of truth; render() redraws everything from it)
     ========================================================================= */

  var state = {
    pointX: INITIAL_POINT_X,
    pointY: INITIAL_POINT_Y,
    arc: 0,
    dragging: false
  };

  var els = {};
  var mathReady = false;

  function distanceKpc()  { return X_SCALE * state.pointX; }   // updateEquation
  function velocityKmS()  { return Y_SCALE * state.pointY; }   // updateEquation
  function massSolar()    {                                    // M = V^2 R / G
    var v = velocityKmS();
    var r = distanceKpc();
    return v * v * r / G;
  }

  function syncArcFromPoint() { state.arc = arcAtX(state.pointX); }

  function setArc(s) {
    state.arc = Math.min(Math.max(s, ARC_MIN), ARC_MAX);
    var pt = pointAtArc(state.arc);
    state.pointX = pt.x;
    state.pointY = pt.y;
  }

  /* Drive the same state from a distance in kpc instead of a curve position.
     Used by the galaxy-view ring: distance increases monotonically along the
     curve, so this lands on exactly one point and the two controls can never
     disagree. */
  function setDistanceKpc(kpc) {
    var clamped = Math.min(Math.max(kpc, MIN_DISTANCE), MAX_DISTANCE_REACHABLE);
    setArc(arcAtX(clamped / X_SCALE));
  }

  /* =========================================================================
     5. Canvas drawing  (only the code-drawn Flash art is redrawn here)
     ========================================================================= */

  /* The drawing code always works in the ORIGINAL Flash stage coordinates.
     Only the backing store is resized: it is matched to however large CSS has
     drawn the element (times the device pixel ratio) so the 1 px axes stay
     crisp, and a single ctx transform maps stage units onto it. No physics or
     geometry is ever recomputed from the live element size. */
  function fitCanvas(canvas, w, h) {
    var dpr = window.devicePixelRatio || 1;
    var rect = canvas.getBoundingClientRect();
    var cssW = rect.width  || w;
    var cssH = rect.height || h;

    canvas.width  = Math.max(1, Math.round(cssW * dpr));
    canvas.height = Math.max(1, Math.round(cssH * dpr));

    var ctx = canvas.getContext('2d');
    ctx.setTransform(canvas.width / w, 0, 0, canvas.height / h, 0, 0);
    return ctx;
  }

  function drawArrowHead(ctx, x, y, rotationDeg) {
    ctx.save();
    ctx.translate(x, y);
    ctx.rotate(rotationDeg * Math.PI / 180);
    ctx.beginPath();
    ctx.moveTo(ARROW_PATH[0][0], ARROW_PATH[0][1]);
    for (var i = 1; i < ARROW_PATH.length; i++) {
      ctx.lineTo(ARROW_PATH[i][0], ARROW_PATH[i][1]);
    }
    ctx.closePath();
    ctx.fillStyle = AXIS_COLOR;
    ctx.fill();
    ctx.restore();
  }

  function drawDashedRun(ctx, count, mapper) {
    ctx.fillStyle = GUIDE_COLOR;
    for (var k = 0; k < count; k++) {
      var d = DASH_FIRST + DASH_PITCH * k;
      if (d > DASH_LAST) { break; }
      var p = mapper(d);
      if (p === null) { break; }
      ctx.beginPath();
      ctx.arc(p[0], p[1], DASH_RADIUS, 0, Math.PI * 2);
      ctx.fill();
    }
  }

  function drawPlot() {
    var ctx = els.plotCtx;
    if (!ctx) { return; }

    ctx.clearRect(0, 0, STAGE.W, STAGE.H);
    ctx.save();
    ctx.translate(STAGE.OX, STAGE.OY);

    // --- axes and ticks (geometry from shapes/64.svg and shapes/65.svg) ---
    ctx.lineCap = 'round';
    ctx.lineJoin = 'round';
    ctx.strokeStyle = AXIS_COLOR;
    ctx.lineWidth = 1;

    ctx.beginPath();
    ctx.moveTo(AXIS_X_END, 0);
    ctx.lineTo(0, 0);
    ctx.lineTo(0, AXIS_Y_END);
    ctx.stroke();

    ctx.beginPath();
    var i;
    for (i = 0; i < X_TICKS.length; i++) {
      var tx = X_TICKS[i] * (PLOT_WIDTH / MAX_DISTANCE);   // 12.5 px per kpc
      ctx.moveTo(tx, 0);
      ctx.lineTo(tx, TICK_LEN);
    }
    for (i = 0; i < Y_TICKS.length; i++) {
      var ty = -Y_TICKS[i] * (PLOT_HEIGHT / MAX_VELOCITY);
      ctx.moveTo(0, ty);
      ctx.lineTo(-TICK_LEN, ty);
    }
    ctx.stroke();

    drawArrowHead(ctx, AXIS_X_END, 0, 90);    // pointing right
    drawArrowHead(ctx, 0, AXIS_Y_END, 0);     // pointing up

    // --- the rotation curve: p.drawCurve, lineStyle(2, 16740464, 100) ---
    ctx.strokeStyle = CURVE_COLOR;
    ctx.lineWidth = 2;
    ctx.beginPath();
    ctx.moveTo(POINTS_X_SCALE * START_POINT.x, POINTS_Y_SCALE * START_POINT.y);
    for (i = 0; i < POINTS_LIST.length; i++) {
      var p = POINTS_LIST[i];
      ctx.quadraticCurveTo(POINTS_X_SCALE * p.cx, POINTS_Y_SCALE * p.cy,
                           POINTS_X_SCALE * p.ax, POINTS_Y_SCALE * p.ay);
    }
    ctx.stroke();

    // --- dashed guide lines: p.updateDashedLines + the two mask rectangles ---
    var px = state.pointX;
    var py = state.pointY;

    // vertical line: the dashed strip rotated -90 deg at x = px, masked to
    // the band between y = 0 and y = py.
    drawDashedRun(ctx, 200, function (d) {
      return (d <= -py) ? [px, -d] : null;
    });

    // horizontal line: unrotated at y = py, masked to x between 0 and px.
    drawDashedRun(ctx, 200, function (d) {
      return (d <= px) ? [d, py] : null;
    });

    ctx.restore();
  }

  /* Milky Way Component.as: precomputePoints(12) + drawDisc(radius). */
  var DISC_POINTS = (function () {
    var nP = GALAXY_NUM_POINTS;
    var aP = [], cP = [];
    var step = 6.283185307179586 / nP;
    var halfStep = step / 2;
    var cRad = 1 / Math.cos(halfStep);
    for (var i = 0; i < nP; i++) {
      var ang = (i + 1) * step;
      aP.push({ x: Math.cos(ang), y: -Math.sin(ang) });
      var cAngle = ang - halfStep;
      cP.push({ x: cRad * Math.cos(cAngle), y: -cRad * Math.sin(cAngle) });
    }
    return { nP: nP, aP: aP, cP: cP, sP: { x: aP[nP - 1].x, y: aP[nP - 1].y } };
  })();

  /* Where to park the ring's grip, given the ring radius in view pixels.

     The ring outgrows the 350 x 350 view well before the far end of the curve
     (it leaves entirely at about 28 kpc), so the grip slides around the ring
     towards the top-right as it grows, staying on the part of the ring that is
     still visible. Once no part of the ring is on screen it rests in the
     corner. It is only ever an affordance -- the drag itself reads the raw
     pointer distance from the centre and is never clamped. */
  function ringGripPosition(radius) {
    var limit = GALAXY_STAGE / 2 - 10;

    if (radius <= limit) { return { x: radius, y: 0 }; }

    var cosine = limit / radius;                 // where the ring meets x = limit
    if (cosine >= -1 && cosine <= 1) {
      var y = radius * Math.sin(Math.acos(cosine));
      if (y <= limit) { return { x: limit, y: -y }; }
    }
    return { x: limit, y: -limit };
  }

  function drawGalaxy() {
    var ctx = els.galaxyCtx;
    if (!ctx) { return; }

    ctx.clearRect(0, 0, GALAXY_STAGE, GALAXY_STAGE);
    ctx.save();
    ctx.translate(GALAXY_STAGE / 2, GALAXY_STAGE / 2);

    var r = distanceKpc() * GALAXY_SCALE;   // setRadius(distance)
    var d = DISC_POINTS;

    ctx.beginPath();
    ctx.moveTo(r * d.sP.x, r * d.sP.y);
    for (var i = 0; i < d.nP; i++) {
      ctx.quadraticCurveTo(r * d.cP[i].x, r * d.cP[i].y,
                           r * d.aP[i].x, r * d.aP[i].y);
    }
    ctx.closePath();

    ctx.fillStyle = DISC_FILL;              // beginFill(16711680, 20)
    ctx.fill();

    // The 1 px pure-red outline of the original can drop below 3:1 where it
    // crosses the bright galactic bulge, so a white casing is drawn beneath
    // it. One of the two edges always clears 3:1 (see ACCESSIBILITY.md).
    ctx.lineJoin = 'round';
    ctx.strokeStyle = 'rgba(255, 255, 255, 0.9)';
    ctx.lineWidth = 3;
    ctx.stroke();
    ctx.strokeStyle = DISC_COLOR;           // lineStyle(1, 16711680, 100)
    ctx.lineWidth = 1.5;
    ctx.stroke();

    ctx.restore();
  }

  /* =========================================================================
     6. MathJax content
     ========================================================================= */

  function massLatex(coefficient, exponent) {
    if (coefficient === '...') {
      return '\\ldots \\times 10^{\\ldots}';
    }
    return coefficient + ' \\times 10^{' + exponent + '}';
  }

  function buildEquationLatex(distanceText, velocityText, coefficient, exponent) {
    // distanceText / velocityText are the verbatim Flash field strings,
    // e.g. "(8.0 kpc)" and "(233 km/s)".
    var vNum = velocityText.replace('(', '').replace(' km/s)', '');
    var rNum = distanceText.replace('(', '').replace(' kpc)', '');

    var symbolic = '\\frac{V^{2}R}{G}';
    var numeric  = '\\frac{(' + vNum + '\\;\\mathrm{km/s})^{2}\\,' +
                   '(' + rNum + '\\;\\mathrm{kpc})}{G}';
    var answer   = massLatex(coefficient, exponent) + '\\; M_{\\odot}';

    // Two lines where there is room (as in the original Flash layout); three
    // narrower lines when there is not, so the box never has to scroll. The
    // trigger is a phone-width media query OR a measured overflow, which is
    // what catches a user who has enlarged their browser's default font.
    if (forcedNarrowEqn || (narrowQuery && narrowQuery.matches)) {
      return '\\[\\begin{aligned}' +
             'M \\;&=\\; ' + symbolic + ' \\\\[4pt]' +
             '\\;&=\\; ' + numeric + ' \\\\[4pt]' +
             '\\;&=\\; ' + answer +
             '\\end{aligned}\\]';
    }

    return '\\[\\begin{aligned}' +
           'M \\;&=\\; ' + symbolic + ' \\;=\\; ' + numeric + ' \\\\[4pt]' +
           '\\;&=\\; ' + answer +
           '\\end{aligned}\\]';
  }

  // Equation typesetting is throttled during a drag: MathJax re-typesets the
  // whole expression on every call, which is far more work than the canvas.
  var EQ_MIN_INTERVAL = 80;
  var eqLastTime = 0;
  var eqTimer = null;
  var eqPayload = null;

  function emitEquation() {
    eqLastTime = (window.performance && performance.now) ? performance.now()
                                                         : Date.now();
    if (typeof window.klunlShowEquation === 'function' && eqPayload) {
      window.klunlShowEquation(eqPayload.eqn, eqPayload.msg1, eqPayload.msg2);
      // MathJax typesets asynchronously, and its context-menu extension sets
      // tabindex="0" a tick after the container lands -- after the mutation
      // observer has already seen it. Re-run both checks once it has settled.
      setTimeout(function () {
        markMathNotFocusable();
        checkEquationFit();
      }, 250);
    }
  }

  function scheduleEquation(payload, immediate) {
    eqPayload = payload;
    if (!mathReady) { return; }

    if (immediate) {
      if (eqTimer) { clearTimeout(eqTimer); eqTimer = null; }
      emitEquation();
      return;
    }
    var now = (window.performance && performance.now) ? performance.now()
                                                      : Date.now();
    var wait = EQ_MIN_INTERVAL - (now - eqLastTime);
    if (wait <= 0) {
      emitEquation();
    } else if (!eqTimer) {
      eqTimer = setTimeout(function () { eqTimer = null; emitEquation(); }, wait);
    }
  }

  /* =========================================================================
     7. Spoken text  (every number carries its quantity name AND its unit)
     ========================================================================= */

  function spokenExponent(exponent) {
    if (exponent === '...') { return 'an undefined power'; }
    return '10 to the power ' + exponent;
  }

  function spokenMass(coefficient, exponent) {
    if (coefficient === '...') { return 'undefined'; }
    return coefficient + ' times ' + spokenExponent(exponent) + ' solar masses';
  }

  function spokenDistance(distanceDigits) {
    return distanceDigits + ' kiloparsecs';
  }

  function spokenVelocity(velocityDigits) {
    return velocityDigits + ' kilometers per second';
  }

  /* =========================================================================
     8. render()  -- one function, everything redrawn from state
     ========================================================================= */

  function render(options) {
    var opts = options || {};

    // p.updateEquation: the exact Flash field strings.
    var distance = distanceKpc();
    var velocity = velocityKmS();
    var distanceDigits = asToFixed(distance, 1);                 // "8.0"
    var velocityDigits = String(asToSigDigits(velocity, 3));     // "233"
    var distanceText = '(' + distanceDigits + ' kpc)';
    var velocityText = '(' + velocityDigits + ' km/s)';
    var mass = asCoefficientAndExponent(massSolar(), 3);

    drawPlot();
    drawGalaxy();

    // --- cursor position on the plot (percentages of the internal stage) ---
    if (els.pointHandle) {
      els.pointHandle.style.left =
        ((STAGE.OX + state.pointX) / STAGE.W * 100) + '%';
      els.pointHandle.style.top =
        ((STAGE.OY + state.pointY) / STAGE.H * 100) + '%';
    }

    // --- equation + its two screen-reader companions, via kl-unl.js ---
    var eqnSentence =
      'Enclosed mass M equals V squared R divided by G, ' +
      'where V is the rotational speed of ' + spokenVelocity(velocityDigits) +
      ', R is the distance from the galactic center of ' +
      spokenDistance(distanceDigits) +
      ', and G is the gravitational constant. The enclosed mass is ' +
      spokenMass(mass.coefficient, mass.exponent) + '.';

    var plotSentence =
      'Rotation curve of the Milky Way. The cursor sits on the curve at ' +
      spokenDistance(distanceDigits) + ' from the galactic center, where the ' +
      'rotational speed is ' + spokenVelocity(velocityDigits) + '. ' +
      'Dashed guide lines run from the cursor to both axes. The curve rises ' +
      'steeply inside about 1 kiloparsec, then stays roughly flat between ' +
      '200 and 250 kilometers per second all the way out to 39 kiloparsecs.';

    scheduleEquation({
      eqn:  ['massEquation', buildEquationLatex(distanceText, velocityText,
                                                mass.coefficient, mass.exponent)],
      msg1: ['srEqnDesc', eqnSentence],
      msg2: ['srPlotDesc', plotSentence]
    }, opts.immediate === true);

    // --- galaxy-view description ---
    if (els.srGalaxyDesc) {
      els.srGalaxyDesc.textContent =
        'Face-on view of the Milky Way. A red shaded circle marks the region ' +
        'within ' + spokenDistance(distanceDigits) + ' of the galactic ' +
        'center; that is the region whose mass is being measured. The Sun is ' +
        'marked about 8 kiloparsecs from the center.';
    }

    // --- the red ring's grip in the galaxy view ---
    if (els.radiusHandle) {
      var grip = ringGripPosition(distance * GALAXY_SCALE);
      els.radiusHandle.style.left =
        ((GALAXY_STAGE / 2 + grip.x) / GALAXY_STAGE * 100) + '%';
      els.radiusHandle.style.top =
        ((GALAXY_STAGE / 2 + grip.y) / GALAXY_STAGE * 100) + '%';
    }

    // --- accessible values on both handles (skipped mid-drag; see below) ---
    if (!state.dragging || opts.commit === true) {
      var readout =
        'rotational speed ' + spokenVelocity(velocityDigits) + ', ' +
        'enclosed mass ' + spokenMass(mass.coefficient, mass.exponent);
      var now = String(Math.round(distance * 100) / 100);

      if (els.pointHandle) {
        els.pointHandle.setAttribute('aria-valuenow', now);
        els.pointHandle.setAttribute('aria-valuetext',
          spokenDistance(distanceDigits) + ' from the galactic center, ' + readout);
      }
      if (els.radiusHandle) {
        els.radiusHandle.setAttribute('aria-valuenow', now);
        els.radiusHandle.setAttribute('aria-valuetext',
          'Measured region radius ' + spokenDistance(distanceDigits) + ', ' + readout);
      }
    }

    if (opts.announce) {
      els.srStatus.textContent = opts.announce;
    }
  }

  /* =========================================================================
     9. Input: pointer drag (MWRV Draggable Point.as) + keyboard equivalent
     ========================================================================= */

  var drag = { id: null, mode: null, xOffset: 0, yOffset: 0, radiusOffset: 0 };

  // How close to the ring a press has to land to count as grabbing it (in the
  // galaxy view's own 350 x 350 coordinates).
  var RING_GRAB_TOLERANCE = 12;

  function stageCoords(event) {
    // Map client coordinates back through the current CSS scale so the drag
    // maths runs in the original Flash plot coordinates at any display size.
    var rect = els.plotStage.getBoundingClientRect();
    if (!rect.width || !rect.height) { return { x: 0, y: 0 }; }
    return {
      x: (event.clientX - rect.left) / rect.width * STAGE.W - STAGE.OX,
      y: (event.clientY - rect.top) / rect.height * STAGE.H - STAGE.OY
    };
  }

  function capture(el, pointerId) {
    if (el.setPointerCapture) {
      try { el.setPointerCapture(pointerId); } catch (e) { /* noop */ }
    }
  }

  /* --- the plot cursor (MWRV Draggable Point.as) --- */

  function onPointerDown(event) {
    if (event.button !== undefined && event.button !== 0) { return; }
    event.preventDefault();

    // "Click to focus": after a click/tap the arrow keys work immediately.
    els.pointHandle.focus();

    var m = stageCoords(event);
    drag.id = event.pointerId;
    drag.mode = 'point';
    drag.xOffset = m.x - state.pointX;      // p.onPress
    drag.yOffset = m.y - state.pointY;
    state.dragging = true;
    els.pointHandle.classList.add('is-active');

    capture(els.pointHandle, event.pointerId);
  }

  /* --- the red radius ring in the galaxy view (new; see CONVERSION_NOTES) --- */

  function galaxyCoords(event) {
    var rect = els.galaxyStage.getBoundingClientRect();
    if (!rect.width || !rect.height) { return { x: 0, y: 0, r: 0 }; }
    var x = (event.clientX - rect.left) / rect.width * GALAXY_STAGE - GALAXY_STAGE / 2;
    var y = (event.clientY - rect.top) / rect.height * GALAXY_STAGE - GALAXY_STAGE / 2;
    return { x: x, y: y, r: Math.sqrt(x * x + y * y) };
  }

  function startRadiusDrag(event, grabRadius) {
    event.preventDefault();
    els.radiusHandle.focus();

    drag.id = event.pointerId;
    drag.mode = 'radius';
    // Keep the grab offset, exactly as the plot cursor does, so the ring does
    // not jump under the pointer when you grab it slightly off the line.
    drag.radiusOffset = grabRadius - distanceKpc() * GALAXY_SCALE;
    state.dragging = true;
    els.radiusHandle.classList.add('is-active');

    capture(els.radiusHandle, event.pointerId);
  }

  function onRadiusHandleDown(event) {
    if (event.button !== undefined && event.button !== 0) { return; }
    startRadiusDrag(event, galaxyCoords(event).r);
  }

  // Pressing anywhere on the ring itself grabs it too -- that is what "drag
  // the red circle" means. A press away from the ring is ignored, so clicking
  // the picture never yanks the value somewhere unintended.
  function onGalaxyStageDown(event) {
    if (event.button !== undefined && event.button !== 0) { return; }
    if (state.dragging) { return; }

    var g = galaxyCoords(event);
    var ringRadius = distanceKpc() * GALAXY_SCALE;
    if (Math.abs(g.r - ringRadius) > RING_GRAB_TOLERANCE) { return; }

    startRadiusDrag(event, g.r);
  }

  /* --- shared move / release --- */

  function onPointerMove(event) {
    if (!state.dragging || event.pointerId !== drag.id) { return; }
    event.preventDefault();

    if (drag.mode === 'radius') {
      var g = galaxyCoords(event);
      // The ring can grow past the edge of the 350 x 350 view; the pointer is
      // still tracked out there, so the full range stays reachable by drag.
      setDistanceKpc((g.r - drag.radiusOffset) / GALAXY_SCALE);
    } else {
      var m = stageCoords(event);
      state.pointX = m.x - drag.xOffset;    // p.onMouseMoveFunc
      state.pointY = m.y - drag.yOffset;
      snapPointToCurve();
      syncArcFromPoint();
    }
    render();
  }

  function endDrag(event) {
    if (!state.dragging || (event && event.pointerId !== drag.id)) { return; }
    state.dragging = false;
    drag.id = null;
    drag.mode = null;
    els.pointHandle.classList.remove('is-active');
    els.radiusHandle.classList.remove('is-active');
    // Commit: this is where the handles' aria-valuetext is refreshed, so a
    // screen reader speaks the result once on release rather than per tick.
    render({ commit: true, immediate: true });
  }

  function onKeyDown(event) {
    // Leave browser and screen-reader shortcuts (Ctrl+Home, Alt+Left, ...) alone.
    if (event.altKey || event.ctrlKey || event.metaKey) { return; }

    var step = arrowStep();
    var delta = 0;
    var jump = null;

    switch (event.key) {
      case 'ArrowRight': case 'Right':
      case 'ArrowUp':    case 'Up':      delta =  step; break;
      case 'ArrowLeft':  case 'Left':
      case 'ArrowDown':  case 'Down':    delta = -step; break;
      case 'PageUp':                     delta =  step * 10; break;
      case 'PageDown':                   delta = -step * 10; break;
      case 'Home':                       jump = ARC_MIN; break;
      case 'End':                        jump = ARC_MAX; break;
      default: return;                   // let Tab and everything else through
    }

    event.preventDefault();
    setArc(jump === null ? state.arc + delta : jump);
    render({ commit: true, immediate: true });
  }

  /* =========================================================================
     10. Axis labels and tick labels (HTML + MathJax, never painted on canvas)
     ========================================================================= */

  function buildTicks() {
    var i, el, frag;

    frag = document.createDocumentFragment();
    for (i = 0; i < X_TICKS.length; i++) {
      var kpc = X_TICKS[i];
      el = document.createElement('span');
      el.className = 'mwrv-tick' + ((i % 2 === 1) ? ' mwrv-tick--minor' : '');
      el.style.left = ((STAGE.OX + kpc * (PLOT_WIDTH / MAX_DISTANCE)) /
                       STAGE.W * 100) + '%';
      el.textContent = '\\(' + kpc + '\\)';
      frag.appendChild(el);
    }
    els.xTicks.appendChild(frag);

    frag = document.createDocumentFragment();
    for (i = 0; i < Y_TICKS.length; i++) {
      var kms = Y_TICKS[i];
      el = document.createElement('span');
      el.className = 'mwrv-tick';
      el.style.top = ((STAGE.OY - kms * (PLOT_HEIGHT / MAX_VELOCITY)) /
                      STAGE.H * 100) + '%';
      el.textContent = '\\(' + kms + '\\)';
      frag.appendChild(el);
    }
    els.yTicks.appendChild(frag);

    // Axis titles, verbatim from texts/77.txt and texts/78.txt.
    els.xTitle.textContent =
      '\\(\\text{distance from galactic center }(\\mathrm{kpc})\\)';
    els.yTitle.textContent =
      '\\(\\text{rotational speed }(\\mathrm{km/s})\\)';
  }

  function typesetStatic() {
    // MathJax's own pageReady pass usually typesets these already. Only feed
    // it the containers that still hold raw \( ... \) source, otherwise a
    // second pass would re-typeset the assistive MathML it just generated and
    // nest a duplicate container inside every label.
    var targets = [els.xTicks, els.yTicks, els.xTitle, els.yTitle]
      .filter(function (el) { return el && el.textContent.indexOf('\\(') !== -1; });

    if (targets.length && window.MathJax && MathJax.typesetPromise) {
      MathJax.typesetPromise(targets)
        .then(markMathNotFocusable)
        .catch(function (err) { console.error(err); });
    } else {
      markMathNotFocusable();
    }
  }

  function markMathNotFocusable() {
    // Display-only math must never become a tab stop. MathJax's context-menu
    // extension gives every container tabindex="0"; this takes it back out of
    // the Tab order. The right-click "Show Math As" menu still works.
    var list = document.querySelectorAll('mjx-container');
    for (var i = 0; i < list.length; i++) {
      if (list[i].getAttribute('tabindex') !== '-1') {
        list[i].setAttribute('tabindex', '-1');
      }
    }
  }

  /* If the typeset equation turns out wider than its box -- which happens when
     the reader has enlarged their default font rather than zoomed -- fall back
     to the three-line form. One-way, so it settles after a single re-render;
     a resize clears it so the wider form can come back. */
  function checkEquationFit() {
    if (forcedNarrowEqn || !els.eqBox) { return; }
    if (els.eqBox.scrollWidth > els.eqBox.clientWidth + 2) {
      forcedNarrowEqn = true;
      render({ commit: true, immediate: true });
    }
  }

  /* The equation is re-typeset on every change, so new containers keep
     appearing. Watching for added nodes (not attributes) keeps them out of the
     Tab order without the observer retriggering itself. */
  function watchMath() {
    if (!window.MutationObserver) { return; }
    var observer = new MutationObserver(function () {
      markMathNotFocusable();
      checkEquationFit();
    });
    observer.observe(els.eqBox, { childList: true, subtree: true });
    observer.observe(els.plotWrap, { childList: true, subtree: true });
  }

  /* =========================================================================
     11. Layout: the equation box overlays the plot only when there is room
     ========================================================================= */

  var wideQuery = null;
  var narrowQuery = null;
  var forcedNarrowEqn = false;

  function listenToQuery(query, handler) {
    if (query.addEventListener) {
      query.addEventListener('change', handler);
    } else if (query.addListener) {
      query.addListener(handler);            // Safari < 14
    }
  }

  function placeEquationBox() {
    var wide = wideQuery ? wideQuery.matches : true;
    var target = wide ? els.plotStage : els.plotWrap;
    if (els.eqBox.parentNode !== target) {
      if (wide) {
        target.appendChild(els.eqBox);
      } else {
        els.plotWrap.insertBefore(els.eqBox, els.srEqnDesc);
      }
    }
  }

  /* =========================================================================
     12. Boot
     ========================================================================= */

  var resizeFrame = null;

  function resizeCanvases() {
    els.plotCtx = fitCanvas(els.plotCanvas, STAGE.W, STAGE.H);
    els.galaxyCtx = fitCanvas(els.galaxyCanvas, GALAXY_STAGE, GALAXY_STAGE);
    render();
  }

  function onResize() {
    if (resizeFrame) { return; }
    resizeFrame = window.requestAnimationFrame(function () {
      resizeFrame = null;
      forcedNarrowEqn = false;    // let the wider form back if it now fits
      placeEquationBox();
      resizeCanvases();
      render({ commit: true, immediate: true });
    });
  }

  function resetSim(announce) {
    // Exactly the MilkyWayRotationalVelocityClass constructor sequence.
    state.pointX = INITIAL_POINT_X;
    state.pointY = INITIAL_POINT_Y;
    snapPointToCurve();
    syncArcFromPoint();
    render({
      commit: true,
      immediate: true,
      announce: announce
    });
  }

  function init() {
    els.plotCanvas   = document.getElementById('plotCanvas');
    els.galaxyCanvas = document.getElementById('galaxyCanvas');
    els.galaxyStage  = document.getElementById('galaxyStage');
    els.radiusHandle = document.getElementById('radiusHandle');
    els.plotStage    = document.getElementById('plotStage');
    els.plotWrap     = document.getElementById('plotWrap');
    els.pointHandle  = document.getElementById('pointHandle');
    els.eqBox        = document.getElementById('eqBox');
    els.massEquation = document.getElementById('massEquation');
    els.xTicks       = document.getElementById('xTicks');
    els.yTicks       = document.getElementById('yTicks');
    els.xTitle       = document.getElementById('eqnXTitle');
    els.yTitle       = document.getElementById('eqnYTitle');
    els.srGalaxyDesc = document.getElementById('srGalaxyDesc');
    els.srEqnDesc    = document.getElementById('srEqnDesc');
    els.srStatus     = document.getElementById('srStatus');
    els.caption      = document.getElementById('galaxyCaption');

    if (!els.plotCanvas) { return; }

    els.caption.textContent =
      'Drag the red circle to resize the measured region — its mass is the ' +
      'mass computed at right, and the plot cursor follows. The white dot ' +
      'marks the position of the Sun.';

    buildArcTable();
    computeArcLimits();
    buildTicks();

    var vMin = String(Math.round(MIN_DISTANCE * 100) / 100);
    var vMax = String(Math.round(MAX_DISTANCE_REACHABLE * 100) / 100);
    [els.pointHandle, els.radiusHandle].forEach(function (h) {
      h.setAttribute('aria-valuemin', vMin);
      h.setAttribute('aria-valuemax', vMax);
    });

    // Layout
    if (window.matchMedia) {
      wideQuery = window.matchMedia('(min-width: 56.0625rem)');
      narrowQuery = window.matchMedia('(max-width: 34rem)');
      listenToQuery(wideQuery, placeEquationBox);
      listenToQuery(narrowQuery, function () {
        render({ commit: true, immediate: true });
      });
    }
    placeEquationBox();
    watchMath();

    // Input. The move/up listeners live on window so the drag survives even
    // where setPointerCapture is unavailable; captured events still bubble
    // there, so each event is handled exactly once.
    els.pointHandle.addEventListener('pointerdown', onPointerDown);
    els.pointHandle.addEventListener('keydown', onKeyDown);
    // The ring grip drives the same arc parameter, so it shares the key map.
    els.radiusHandle.addEventListener('pointerdown', onRadiusHandleDown);
    els.radiusHandle.addEventListener('keydown', onKeyDown);
    els.galaxyStage.addEventListener('pointerdown', onGalaxyStageDown);
    window.addEventListener('pointermove', onPointerMove);
    window.addEventListener('pointerup', endDrag);
    window.addEventListener('pointercancel', endDrag);
    // If capture is lost some other way (the element re-parents, a dialog
    // steals input), end the drag rather than leaving it stuck open.
    els.pointHandle.addEventListener('lostpointercapture', endDrag);
    els.radiusHandle.addEventListener('lostpointercapture', endDrag);

    // Reset comes from the shared masthead (bubbling, composed "sim-reset").
    document.addEventListener('sim-reset', function () {
      resetSim('Simulation reset. ' +
               'Cursor returned to 8.0 kiloparsecs from the galactic center, ' +
               'rotational speed 233 kilometers per second.');
    });

    window.addEventListener('resize', onResize);
    window.addEventListener('orientationchange', onResize);

    // The panels are laid out by CSS, so measure once the first layout pass is
    // done, then again after web fonts / MathJax may have shifted things.
    if (window.ResizeObserver) {
      var ro = new ResizeObserver(onResize);
      ro.observe(els.plotStage);
      ro.observe(els.galaxyCanvas);

      // Separate observer: the equation only needs a fit check, and must not
      // go through onResize (which clears the narrow-form flag).
      var eqRo = new ResizeObserver(function () { checkEquationFit(); });
      eqRo.observe(els.eqBox);
      eqRo.observe(els.massEquation);
    }

    els.plotCtx = fitCanvas(els.plotCanvas, STAGE.W, STAGE.H);
    els.galaxyCtx = fitCanvas(els.galaxyCanvas, GALAXY_STAGE, GALAXY_STAGE);

    resetSim();
    waitForMathJax();
  }

  /* kl-unl.js calls klunlInitEqn() once MathJax is ready; redefining it here
     is the documented hook for sim-specific equation set-up. The simulation
     itself is booted from DOMContentLoaded so the canvas and the drag still
     work even if MathJax is slow to arrive. */
  window.klunlInitEqn = function () {
    if (mathReady) { return; }        // idempotent: the poll below may race us
    mathReady = true;
    typesetStatic();
    render({ commit: true, immediate: true });
  };

  /* Safety net. The equation and every axis label depend on klunlInitEqn being
     called, and MathJax's startup hook has been observed to complete without
     ever invoking it -- which silently leaves the sim with no mathematics at
     all. So once MathJax is loadable, drive the initialisation ourselves if
     nobody else has. klunlInitEqn is idempotent, so whichever path wins first
     is the only one that does any work. */
  var MATH_POLL_MS = 100;
  var MATH_POLL_LIMIT = 100;          // give up after ~10 s
  var mathPolls = 0;

  function waitForMathJax() {
    if (mathReady) { return; }

    if (window.MathJax && window.MathJax.typesetPromise) {
      if (window.MathJax.startup && window.MathJax.startup.promise) {
        window.MathJax.startup.promise
          .then(function () { window.klunlInitEqn(); })
          .catch(function () { window.klunlInitEqn(); });
      } else {
        window.klunlInitEqn();
      }
      return;
    }

    if (++mathPolls < MATH_POLL_LIMIT) {
      setTimeout(waitForMathJax, MATH_POLL_MS);
    } else {
      console.warn('MathJax did not load; equations and axis labels are ' +
                   'showing their LaTeX source.');
    }
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();
