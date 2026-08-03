/* ==========================================================================
   Daylight Simulator - HTML5 port of daylightsimulator.swf (AS1, SWF v6)

   Behaviour is ported from the decompiled ActionScript:
     scripts/frame_1/DoAction.as          - the controller (animation, clock,
                                            daylight-hours, date, reset)
     scripts/Flat Map Component 007.as    - the map: terminator geometry, grid,
                                            border, longitude scrolling, drag
     scripts/SliderV3Symbol.as            - slider value/label semantics

   Constants, formulas and on-screen strings are verbatim from that source.
   Deviations are listed in CONVERSION_NOTES.md.

   Presentation follows the KL-UNL foundation + WCAG 2.1 AA: the canvas carries
   only the code-drawn map stage, every control is a native element, and all
   mathematical notation is MathJax-typeset in HTML.
   ========================================================================== */

'use strict';

/* --------------------------------------------------------------------------
   Geometry, taken from the SWF

   The component reads its own placeholder height before resetting its scale:
     placeholder 450 x 225 px, placed with scale 1.1500092
     => mapHeight = 225 * 1.1500092 = 258.75, mapWidth = 2 * mapHeight = 517.5
   -------------------------------------------------------------------------- */
const MAP_H       = 258.75;             // p.defaultMapHeight * placement scale
const MAP_W       = 2 * MAP_H;          // 517.5; this.mapWidth = 2 * mapHeight
const BORDER      = 6;                  // p.borderWidth
const LABEL_GAP   = 5;                  // p.borderLabelMargin
const N_LAT_DIV   = 6;                  // numberOfLatitudeDivisions
const N_LON_DIV   = 8;                  // numberOfLongitudeDivisions

const CANVAS_W    = MAP_W + 2 * BORDER; // 529.5
const CANVAS_H    = MAP_H + 2 * BORDER; // 270.75
const OX          = BORDER;             // map origin inside the canvas
const OY          = BORDER;

const DEG_PER_PX  = 360 / MAP_W;        // 0.6956...
const PX_PER_DEG  = MAP_W / 360;        // 1.4375

// AS colour ints -> CSS. 9474192 = 0x909090, 15249781 = 0xE8B175.
const GRID_COLOR    = '#909090';        // p.gridColor  (set on the placement)
const TERM_COLOR    = '#909090';        // p.terminatorColor
const BORDER_LIGHT  = '#000000';        // borderLightColor from the placement
const BORDER_DARK   = '#E8B175';        // borderDarkColor  from the placement

// Source bitmaps. Both are two world copies side by side. The night export is
// exactly 900 x 225 (4:1). The day export is 904 x 229 - the same map inside a
// 2 px frame - so it is drawn from its 900 x 225 content rect to keep day and
// night in register. See CONVERSION_NOTES.md.
const DAY_SRC   = { x: 2, y: 2, w: 900, h: 225 };
const NIGHT_SRC = { x: 0, y: 0, w: 900, h: 225 };

const MARKER_R  = 5 * (MAP_H / 225);    // marker shape r=5, scaled with the map

// Original ran at 30 fps and stepped its counters once per onEnterFrame.
const FRAME_MS  = 1000 / 30;

const MONTHS      = ['January','February','March','April','May','June',
                     'July','August','September','October','November','December'];
const DAYS_IN_MON = [31,28,31,30,31,30,31,31,30,31,30,31];

/* --------------------------------------------------------------------------
   State - the single source of truth. render() redraws everything from this.
   -------------------------------------------------------------------------- */
const INITIAL = {
  // controller variables, from the bottom of frame_1/DoAction.as
  lat1:        0,        // NEGATED observer latitude  (lat1 = -latitude)
  long1:       0,        // NEGATED observer longitude (long1 = -longitude)
  amp:        -23.26,    // obliquity amplitude
  speed:       1,        // animation speed slider / 5
  count1:    359,        // day-cycle counter
  count2:      1,        // year-cycle counter
  m1:          0,        // month index
  day:         0,        // day-of-month index
  changeMD:    0,
  sunDec:      undefined,// set by the first year step
  mode:       'Year',    // radioGroup: "Year" is initialState
  animating:   true,     // component_Animate(true) runs at load

  // map component state
  offset:      180,      // initOffset; longitude offset in degrees
  sunLatitude: 0,        // _sunLatitude: terminator x offset, in PIXELS
  sunLongitude:0,        // _sunLongitude: never changed by this sim
  mapDeclination: 10,    // initSunDeclination

  // slider positions (degrees; observer position = -lat1 / -long1)
  latDeg:      0,
  lonDeg:      0,
  speedVal:    5,

  // readout strings
  dateText:      'January 1',
  timeText:      '12:00 PM',
  sunDecText:    '',
  latRaysText:   '',
  daylightText:  ''
};

let S = Object.assign({}, INITIAL);

/* --------------------------------------------------------------------------
   DOM handles
   -------------------------------------------------------------------------- */
const $ = (id) => document.getElementById(id);

let canvas, ctx, dpr = 1;
let dayImg, nightImg, markerImg;
let imagesReady = false;

/* ==========================================================================
   PHYSICS / CONTROLLER  - ported 1:1 from frame_1/DoAction.as
   ========================================================================== */

/**
 * Clock readout. Ported from the animation branch of component_Animate.
 *   long1 <= 0 -> longNow = |long1| - 1   else   longNow = 180 + (180 - long1)
 * The two non-animating callers use a different offset (+1 / 181 +) - that
 * discrepancy is in the original and is preserved; see makeClockStatic().
 */
function makeClockAnimated(long1, count1, speed) {
  let longNow = (long1 <= 0) ? Math.abs(long1) - 1
                             : 180 + (180 - long1);
  return formatClock(longNow, count1, speed);
}

/** Clock readout as computed by long1Changed() and resetChanged(). */
function makeClockStatic(long1, count1, speed) {
  let longNow = (long1 <= 0) ? Math.abs(long1) + 1
                             : 181 + (180 - long1);
  return formatClock(longNow, count1, speed);
}

/** Shared tail of the clock code: identical in all three call sites. */
function formatClock(longNow, count1, speed) {
  longNow = Math.floor(count1 * speed + longNow);
  if (longNow > 360) { longNow -= 360; }

  const timeNow1 = Math.floor(longNow / 15);
  let text;

  if (timeNow1 > 12) {
    if (longNow - timeNow1 * 15 < 3) {
      text = (timeNow1 - 12) + ':0' + (longNow % 15 * 4);
    } else {
      text = (timeNow1 - 12) + ':' + (longNow % 15 * 4);
    }
    text += (timeNow1 - 12 === 12) ? ' PM' : ' AM';

  } else if (timeNow1 === 0) {
    if (longNow % 15 < 3) {
      text = '12:0' + (longNow % 15 * 4) + ' PM';
    } else {
      text = '12:' + (longNow % 15 * 4) + ' PM';
    }

  } else {
    if (longNow % 15 < 3) {
      text = timeNow1 + ':0' + (longNow % 15 * 4);
    } else {
      text = timeNow1 + ':' + (longNow % 15 * 4);
    }
    text += (timeNow1 === 12) ? ' AM' : ' PM';
  }
  return text;
}

/**
 * Daylight hours for day-of-year N at the current latitude.
 *
 *   time2 = asin( 0.39795 * cos( 0.2163108
 *                 + 2*atan( 0.9671396 * tan( 0.0086*(N - 186) ) ) ) )
 *   time1 = 24 - (24/pi) * acos( ( sin(0.8333 deg)
 *                 + sin(lat)*sin(time2) ) / ( cos(lat)*cos(time2) ) )
 *
 * 7.639437268410976 = 24/pi;  0.014543315936696234 = sin(0.8333 deg), the
 * standard sunrise/sunset zenith correction.
 *
 * `latSign` selects which sign convention the isNaN fallback uses: the year
 * animation and lat1Changed() test -lat1, resetChanged() tests lat1. Both are
 * reproduced verbatim.
 */
function daylightHours(N, lat1, sunDec, useRawLat1InFallback) {
  const time2 = Math.asin(
    0.39795 * Math.cos(
      0.2163108 + 2 * Math.atan(0.9671396 * Math.tan(0.0086 * (N - 186)))
    )
  );

  let time1 = 24 - 7.639437268410976 * Math.acos(
    (0.014543315936696234
      + Math.sin((-lat1) * 3.141592653589793 / 180) * Math.sin(time2))
    / (Math.cos((-lat1) * 3.141592653589793 / 180) * Math.cos(time2))
  );

  if (isNaN(time1)) {
    // Polar day or polar night: same hemisphere as the Sun -> 24 h, else 0 h.
    const lat = useRawLat1InFallback ? lat1 : -lat1;
    time1 = ((sunDec > 0 && lat > 0) || (sunDec < 0 && lat < 0)) ? 24 : 0;
  }
  return time1;
}

function formatDaylight(time1) {
  return (Math.round(time1 * 100) / 100) + ' hours';
}

/* ---- One animation step ------------------------------------------------- */

/** Day-cycle step: the Sun's longitude sweeps, the map scrolls beneath it. */
function stepDay() {
  S.sunLatitude = (-S.count1) * 1.4375 * S.speed;
  setLongitudeOffset(-(S.count1 * S.speed + 180));
  S.mapDeclination = validDeclination(S.sunDec, S.mapDeclination);

  S.count1++;
  if (S.count1 * S.speed >= 361) { S.count1 = 1; }

  S.timeText = makeClockAnimated(S.long1, S.count1, S.speed);
}

/** Year-cycle step: the Sun's declination sweeps through the seasons. */
function stepYear() {
  const count3 = S.count2 * S.speed;

  // Solar declination: dec = amp * cos( 2*pi/365 * (dayOfYear + 10) ),
  // with amp = -23.26 deg. 0.01721420632103996 = 2*pi/365.
  S.sunDec = S.amp * Math.cos(0.01721420632103996 * (count3 + 10));
  S.mapDeclination = validDeclination(S.sunDec, S.mapDeclination);

  const rounded = Math.round(S.sunDec * 100) / 100;
  if (S.sunDec < 0) {
    S.sunDecText  = String(rounded);
    S.latRaysText = Math.abs(rounded) + '° S';
  } else {
    S.latRaysText = rounded + '° N';
    S.sunDecText  = '+' + rounded;
  }

  S.daylightText = formatDaylight(daylightHours(count3, S.lat1, S.sunDec, false));

  S.count2++;
  if (count3 === 366) { S.count2 = 0; }

  // Date advance. With any speed in [0.2, 2] the modulo test is always true,
  // so the date advances every frame - verbatim from the source.
  if (S.changeMD % S.speed < 2) {
    S.dateText = MONTHS[S.m1] + ' ' + (S.day + 1);
    S.day++;
    if (S.day >= DAYS_IN_MON[S.m1]) {
      S.m1++;
      S.day = 0;
      if (S.m1 > MONTHS.length - 1) { S.m1 = 0; }
    }
    S.changeMD++;
  } else {
    S.changeMD = 0;
  }
}

function step() {
  if (S.mode === 'Day') { stepDay(); } else { stepYear(); }
}

/** setSunDeclination() ignores non-finite input and keeps the previous value. */
function validDeclination(value, previous) {
  return (typeof value === 'number' && isFinite(value)) ? value : previous;
}

/* ---- Control handlers --------------------------------------------------- */

/** long1Changed(val) */
function longitudeChanged(val) {
  S.lonDeg = val;
  S.long1  = -val;
  S.timeText = makeClockStatic(S.long1, S.count1, S.speed);
}

/** lat1Changed(val) - note it uses count2, not count2*speed. */
function latitudeChanged(val) {
  S.latDeg = val;
  S.lat1   = -val;
  S.daylightText = formatDaylight(daylightHours(S.count2, S.lat1, S.sunDec, false));
}

/** animChanged(val) */
function speedChanged(val) {
  S.speedVal = val;
  S.speed    = val / 5;
}

/** resetChanged() - the sim's own "Reset to (0,0)" button. */
function resetToOrigin() {
  S.lonDeg = 0; S.latDeg = 0;
  S.long1  = 0; S.lat1   = 0;
  S.timeText     = makeClockStatic(S.long1, S.count1, S.speed);
  S.daylightText = formatDaylight(daylightHours(S.count2, S.lat1, S.sunDec, true));
}

/** setLongitudeOffset(arg) - wraps into [0, 360). */
function setLongitudeOffset(arg) {
  if (typeof arg === 'number' && isFinite(arg)) {
    S.offset = ((arg % 360) + 360) % 360;
  }
}

/** maskedAreaMC._x: how far the map content is scrolled. */
function mapScrollX() {
  return (-(S.offset + 180) * PX_PER_DEG) % MAP_W;
}

/* ==========================================================================
   TERMINATOR GEOMETRY - ported from p.updateDayAndNightRegions
   ========================================================================== */

let termCache = { dec: null, spec: null };

function terminatorSpec(dec) {
  if (termCache.dec === dec) { return termCache.spec; }

  const W  = MAP_W;
  const R  = W / 6.283185307179586;    // mapWidth / 2pi
  const q  = W / 4;
  const ad = Math.abs(dec);

  // Subdivision count grows as the curve flattens near an equinox.
  let n;
  if      (ad > 30)  { n = 10; }
  else if (ad > 10)  { n = 15; }
  else if (ad > 1.5) { n = 30; }
  else if (ad > 0.5) { n = 40; }
  else               { n = 50; }

  const c  = 1 / Math.tan(dec * 3.141592653589793 / 180);
  const c2 = -c;
  const cc = c * c;

  let spec;

  if (!isFinite(c) || isNaN(c)) {
    // Equinox: the terminator is two straight meridians.
    spec = { straight: true, q: q };

  } else {
    const pts = [];
    let th  = 0;
    let cth = Math.cos(th);
    let pa  = Math.atan(c * cth);
    let ps  = c2 * Math.sin(th) / (1 + cc * (cth * cth));
    const dth = 3.141592653589793 / (2 * n);

    pts.push({ ax: R * th, ay: -R * pa });

    for (let i = 0; i < n; i++) {
      th  += dth;
      cth  = Math.cos(th);
      const a  = Math.atan(c * cth);
      const s  = c2 * Math.sin(th) / (1 + cc * (cth * cth));
      const cx = th + (pa - a + ps * dth) / (s - ps);   // control point
      const cy = s * (cx - th) + a;
      pts.push({ cx: R * cx, cy: -R * cy });
      pts.push({ ax: R * th, ay: -R * a });
      pa = a; ps = s;
    }

    // The four passes that trace one full period of the terminator.
    const H2 = W / 2;
    const curves = [];
    for (let i = 1; i < pts.length; i += 2) {
      curves.push([pts[i].cx, pts[i].cy, pts[i + 1].ax, pts[i + 1].ay]);
    }
    for (let i = pts.length - 2; i > 0; i -= 2) {
      curves.push([H2 - pts[i].cx, -pts[i].cy, H2 - pts[i - 1].ax, -pts[i - 1].ay]);
    }
    for (let i = 1; i < pts.length; i += 2) {
      curves.push([H2 + pts[i].cx, -pts[i].cy, H2 + pts[i + 1].ax, -pts[i + 1].ay]);
    }
    for (let i = pts.length - 2; i > 0; i -= 2) {
      curves.push([W - pts[i].cx, pts[i].cy, W - pts[i - 1].ax, pts[i - 1].ay]);
    }

    spec = {
      straight: false,
      curves:   curves,
      x0:       pts[0].ax,
      y0:       pts[0].ay,
      yNight:   dec >= 0 ? q : -q,
      yDay:     dec <= 0 ? q : -q
    };
  }

  termCache = { dec: dec, spec: spec };
  return spec;
}

/** Closed night-side region, translated to (dx, dy). */
function nightPath(spec, dx, dy) {
  const p = new Path2D();
  const W = MAP_W;

  if (spec.straight) {
    const q = spec.q;
    p.moveTo(dx + 0,     dy + q);
    p.lineTo(dx + q,     dy + q);
    p.lineTo(dx + q,     dy - q);
    p.lineTo(dx + 0,     dy - q);
    p.closePath();
    p.moveTo(dx + W,     dy + q);
    p.lineTo(dx + W,     dy - q);
    p.lineTo(dx + W - q, dy - q);
    p.lineTo(dx + W - q, dy + q);
    p.closePath();
    return p;
  }

  p.moveTo(dx + spec.x0, dy + spec.y0);
  for (const c of spec.curves) {
    p.quadraticCurveTo(dx + c[0], dy + c[1], dx + c[2], dy + c[3]);
  }
  p.lineTo(dx + W, dy + spec.yNight);
  p.lineTo(dx + 0, dy + spec.yNight);
  p.lineTo(dx + spec.x0, dy + spec.y0);
  p.closePath();
  return p;
}

/** The terminator line itself, translated to (dx, dy). */
function terminatorPath(spec, dx, dy) {
  const p = new Path2D();
  const W = MAP_W;

  if (spec.straight) {
    const q = spec.q;
    p.moveTo(dx + q,     dy + q); p.lineTo(dx + q,     dy - q);
    p.moveTo(dx + W - q, dy + q); p.lineTo(dx + W - q, dy - q);
    return p;
  }

  p.moveTo(dx + spec.x0, dy + spec.y0);
  for (const c of spec.curves) {
    p.quadraticCurveTo(dx + c[0], dy + c[1], dx + c[2], dy + c[3]);
  }
  return p;
}

/** Terminator x offset inside maskedAreaMC, from updateDayAndNightRegionsOffset. */
function terminatorBase() {
  // allowDragging is true only while the animation is stopped, and the
  // component then contributes no latitude offset.
  const latOffset = S.animating ? S.sunLatitude : 0;
  const base = MAP_W * (((S.sunLongitude / 360 % 1) + 1) % 1) + latOffset;
  // The pattern tiles with period mapWidth, so normalising is equivalent and
  // guarantees the drawn copies always cover the visible window.
  return ((base % MAP_W) + MAP_W) % MAP_W;
}

/* ==========================================================================
   RENDERING
   ========================================================================== */

function render() {
  drawMap();
  syncDom();
}

function drawMap() {
  if (!ctx) { return; }

  ctx.setTransform(dpr, 0, 0, dpr, 0, 0);
  ctx.clearRect(0, 0, CANVAS_W, CANVAS_H);

  if (!imagesReady) { return; }

  const mx   = mapScrollX();
  const spec = terminatorSpec(S.mapDeclination);
  const base = terminatorBase();

  /* ---- map content, clipped to the map rectangle and scrolled by mx ---- */
  ctx.save();
  ctx.beginPath();
  ctx.rect(OX, OY, MAP_W, MAP_H);
  ctx.clip();
  ctx.translate(OX + mx, OY);

  // Day map: two world copies, 2*mapWidth x mapHeight.
  ctx.drawImage(dayImg, DAY_SRC.x, DAY_SRC.y, DAY_SRC.w, DAY_SRC.h,
                0, 0, 2 * MAP_W, MAP_H);

  // Night map, revealed only through the night-side mask.
  ctx.save();
  const clip = new Path2D();
  for (let k = -1; k <= 2; k++) {
    clip.addPath(nightPath(spec, base + k * MAP_W, MAP_H / 2));
  }
  ctx.clip(clip);
  ctx.drawImage(nightImg, NIGHT_SRC.x, NIGHT_SRC.y, NIGHT_SRC.w, NIGHT_SRC.h,
                0, 0, 2 * MAP_W, MAP_H);
  ctx.restore();

  drawGrid();

  // Terminator line, on top of both maps.
  ctx.strokeStyle = TERM_COLOR;
  ctx.lineWidth   = 1;
  for (let k = -1; k <= 2; k++) {
    ctx.stroke(terminatorPath(spec, base + k * MAP_W, MAP_H / 2));
  }

  drawMarker();
  ctx.restore();

  drawHorizontalBorder(mx);
  drawSideBorder();
}

/** updateLatitudeGrid + updateLongitudeGrid, both inside maskedAreaMC. */
function drawGrid() {
  ctx.strokeStyle = GRID_COLOR;
  ctx.lineWidth   = 1;
  ctx.beginPath();

  const dy = MAP_H / N_LAT_DIV;
  for (let i = 1; i < N_LAT_DIV; i++) {
    const y = i * dy;
    ctx.moveTo(0, y);
    ctx.lineTo(2 * MAP_W, y);
  }

  const dx = MAP_W / N_LON_DIV;
  for (let i = 0; i <= 2 * N_LON_DIV; i++) {
    const x = i * dx;
    ctx.moveTo(x, 0);
    ctx.lineTo(x, MAP_H);
  }
  ctx.stroke();
}

/**
 * "You are here" marker, reusing the exported shape (assets/marker.svg).
 *
 * DEVIATION: the original positions this with constants left over from a
 * 450 x 225 map (225 + lon*450/360, 112.5 - lat*225/180), which lands it about
 * 3 degrees off at (0,0) on the real 517.5 x 258.75 map. It is placed here by
 * the component's own projection instead. See CONVERSION_NOTES.md.
 */
function drawMarker() {
  const x = MAP_W * ((((S.lonDeg + 180) / 360 % 1) + 1) % 1);
  const y = (90 - S.latDeg) * PX_PER_DEG;
  const d = MARKER_R * 2;

  for (let k = -1; k <= 1; k++) {
    ctx.drawImage(markerImg, x + k * MAP_W - MARKER_R, y - MARKER_R, d, d);
  }
}

/**
 * updateBorder(), horizontalBorderMC: the top and bottom bars scroll with the
 * map and are masked to the map's width.
 */
function drawHorizontalBorder(mx) {
  ctx.save();
  ctx.beginPath();
  ctx.rect(OX, OY - BORDER - 5, MAP_W, MAP_H + 2 * BORDER + 10);
  ctx.clip();
  ctx.translate(OX + mx, OY);

  ctx.fillStyle = BORDER_LIGHT;
  ctx.fillRect(0, -BORDER, 2 * MAP_W, BORDER);
  ctx.fillRect(0, MAP_H,   2 * MAP_W, BORDER);

  const bw = MAP_W / N_LON_DIV;
  ctx.fillStyle = BORDER_DARK;
  for (let i = 0; i < 2 * N_LON_DIV; i += 2) {
    ctx.fillRect(i * bw, -BORDER, bw, BORDER);
    ctx.fillRect(i * bw, MAP_H,   bw, BORDER);
  }
  ctx.restore();
}

/** updateBorder(), borderMC: the fixed left and right bars. */
function drawSideBorder() {
  ctx.save();
  ctx.translate(OX, OY);

  ctx.fillStyle   = BORDER_LIGHT;
  ctx.strokeStyle = BORDER_DARK;
  ctx.lineWidth   = 1;

  // Left and right bars.
  ctx.fillRect(-BORDER, -BORDER, BORDER, MAP_H + 2 * BORDER);
  ctx.fillRect(MAP_W,   -BORDER, BORDER, MAP_H + 2 * BORDER);
  ctx.strokeRect(-BORDER + 0.5, -BORDER + 0.5, BORDER, MAP_H + 2 * BORDER);
  ctx.strokeRect(MAP_W + 0.5,   -BORDER + 0.5, BORDER, MAP_H + 2 * BORDER);

  // Alternating blocks down each bar.
  const bh = MAP_H / N_LAT_DIV;
  ctx.fillStyle = BORDER_DARK;
  for (let i = 0; i < N_LAT_DIV; i += 2) {
    ctx.fillRect(-BORDER, i * bh, BORDER, bh);
    ctx.fillRect(MAP_W,   i * bh, BORDER, bh);
  }

  // Hairlines closing the frame at the map edges.
  ctx.strokeStyle = BORDER_DARK;
  ctx.beginPath();
  for (const y of [0, MAP_H]) {
    ctx.moveTo(-BORDER, y + 0.5); ctx.lineTo(0,         y + 0.5);
    ctx.moveTo(MAP_W,   y + 0.5); ctx.lineTo(MAP_W + BORDER, y + 0.5);
  }
  ctx.stroke();
  ctx.restore();
}

/* ==========================================================================
   MATHJAX OUTPUT

   Every symbol shown in the UI - degree signs, signed values, units - is
   typeset by MathJax so it exposes the "Show Math As" menu (never disabled).
   Typeset elements are display-only and are never given a tabindex.
   ========================================================================== */

const mjLast    = Object.create(null);   // element id -> last LaTeX written
let   mjPending = new Set();
let   mjBusy    = false;
let   mjTimer   = null;

// Typesetting is synchronous work on the main thread. During an animation the
// declination readout changes 30 times a second, which is far faster than
// anyone can read, so batches are rate-limited: the canvas keeps its full
// frame rate while the typeset readouts refresh a few times a second.
const MJ_INTERVAL_MS = 200;

function setMath(id, latex) {
  if (mjLast[id] === latex) { return; }
  mjLast[id] = latex;
  const el = $(id);
  if (!el) { return; }
  el.dataset.tex = latex;
  mjPending.add(el);
  scheduleMath();
}

function scheduleMath() {
  if (mjTimer !== null || mjBusy || mjPending.size === 0) { return; }
  mjTimer = setTimeout(() => { mjTimer = null; flushMath(); }, MJ_INTERVAL_MS);
}

/**
 * Typeset content that is written once and never changes (the axis labels).
 * These carry their own markup, so they must not go through setMath()'s
 * deferred-write path.
 */
function typesetStatic(elements) {
  if (!(window.MathJax && MathJax.typesetPromise)) { return; }
  MathJax.typesetPromise(elements)
    .catch((err) => console.error(err))
    .then(() => {
      for (const el of elements) {
        el.querySelectorAll('mjx-container, svg').forEach((n) => {
          n.setAttribute('tabindex', '-1');
          n.setAttribute('focusable', 'false');
        });
      }
      positionLonLabels();
    });
}

function flushMath() {
  if (mjBusy || mjPending.size === 0) { return; }
  if (!(window.MathJax && MathJax.typesetPromise)) { return; }

  const batch = Array.from(mjPending);
  mjPending.clear();
  mjBusy = true;

  // Write the latest LaTeX only now, so frames skipped by the rate limit cost
  // nothing at all.
  for (const el of batch) { el.innerHTML = '$' + (el.dataset.tex || '') + '$'; }

  MathJax.typesetPromise(batch)
    .catch((err) => console.error(err))
    .then(() => {
      mjBusy = false;
      // Keep typeset output out of the tab order (rule 8b): some MathJax
      // configurations make the container or its SVG focusable.
      for (const el of batch) {
        el.querySelectorAll('mjx-container, svg').forEach((n) => {
          n.setAttribute('tabindex', '-1');
          n.setAttribute('focusable', 'false');
        });
      }
      scheduleMath();
    });
}

/* ---- LaTeX + spoken-form builders --------------------------------------- */

/** "-22.84" / "+22.84"  ->  LaTeX with a degree sign, and a spoken form. */
function decLatex(text) {
  if (!text) { return { tex: '', say: '' }; }
  const sign = text.charAt(0);
  const body = text.slice(1);
  const word = sign === '-' ? 'minus ' : 'plus ';
  return {
    tex: sign + body + '^{\\circ}',
    say: word + body + ' degrees'
  };
}

/** "22.84° N"  ->  LaTeX, and a spoken form with the hemisphere spelled out. */
function raysLatex(text) {
  if (!text) { return { tex: '', say: '' }; }
  const m = /^([\d.]+)°\s*([NS])$/.exec(text);
  if (!m) { return { tex: '\\text{' + text + '}', say: text }; }
  const hemi = m[2] === 'N' ? 'north' : 'south';
  return {
    tex: m[1] + '^{\\circ}\\,\\mathrm{' + m[2] + '}',
    say: m[1] + ' degrees ' + hemi
  };
}

/** "9.42 hours" -> LaTeX, and a spoken form. */
function hoursLatex(text) {
  if (!text) { return { tex: '', say: '' }; }
  const m = /^([\d.]+) hours$/.exec(text);
  if (!m) { return { tex: '\\text{' + text + '}', say: text }; }
  return {
    tex: m[1] + '\\ \\text{hours}',
    say: m[1] + ' hours'
  };
}

/** Signed latitude/longitude -> LaTeX with hemisphere letter, plus spoken form. */
function coordLatex(deg, posLetter, negLetter, posWord, negWord, zeroWord) {
  const a = Math.abs(deg);
  if (deg === 0) {
    return { tex: '0^{\\circ}', say: '0 degrees, ' + zeroWord };
  }
  const letter = deg > 0 ? posLetter : negLetter;
  const word   = deg > 0 ? posWord   : negWord;
  return {
    tex: a + '^{\\circ}\\,\\mathrm{' + letter + '}',
    say: a + (a === 1 ? ' degree ' : ' degrees ') + word
  };
}

/* ==========================================================================
   DOM SYNC
   ========================================================================== */

let lastAnnouncement = '';

function syncDom() {
  // Plain-text readouts (a date and a clock time are not mathematical notation).
  $('out-date').textContent = S.dateText;
  $('out-time').textContent = S.timeText;

  const dec   = decLatex(S.sunDecText);
  const rays  = raysLatex(S.latRaysText);
  const hours = hoursLatex(S.daylightText);

  setMath('out-dec',      dec.tex);
  setMath('out-rays',     rays.tex);
  setMath('out-daylight', hours.tex);

  // Spoken equivalents of the three typeset readouts.
  $('sr-readouts').textContent =
    'Sun declination ' + dec.say + '. ' +
    'Latitude of direct rays ' + rays.say + '. ' +
    'Daylight hours ' + hours.say + '.';

  // Slider companions.
  const lat = coordLatex(S.latDeg, 'N', 'S', 'north', 'south', 'the equator');
  const lon = coordLatex(S.lonDeg, 'E', 'W', 'east',  'west',  'the prime meridian');
  setMath('lat-value', lat.tex);
  setMath('lon-value', lon.tex);
  setMath('spd-value', String(S.speedVal));

  $('latSlider').setAttribute('aria-valuetext',   'Latitude '  + lat.say);
  $('lonSlider').setAttribute('aria-valuetext',   'Longitude ' + lon.say);
  $('speedSlider').setAttribute('aria-valuetext', 'Animation speed ' + S.speedVal + ' of 10');

  if ($('latSlider').value   !== String(S.latDeg))   { $('latSlider').value   = S.latDeg; }
  if ($('latBox').value      !== String(S.latDeg))   { $('latBox').value      = S.latDeg; }
  if ($('lonSlider').value   !== String(S.lonDeg))   { $('lonSlider').value   = S.lonDeg; }
  if ($('lonBox').value      !== String(S.lonDeg))   { $('lonBox').value      = S.lonDeg; }
  if ($('speedSlider').value !== String(S.speedVal)) { $('speedSlider').value = S.speedVal; }
  if ($('speedBox').value    !== String(S.speedVal)) { $('speedBox').value    = S.speedVal; }

  $('modeYear').checked = (S.mode === 'Year');
  $('modeDay').checked  = (S.mode === 'Day');
  $('animationButton').textContent = S.animating ? 'Stop Animation' : 'Start Animation';

  // Map drag proxy: report the longitude currently at the centre of the map.
  const centreLon = normaliseLon(180 - S.offset);
  const dragEl = $('map-drag');
  dragEl.setAttribute('aria-valuenow', Math.round(S.offset));
  dragEl.setAttribute('aria-valuetext',
    'Map centred on longitude ' + describeLon(centreLon));

  positionLonLabels();
  updateMapDescription();
}

function normaliseLon(d) {
  let x = ((d % 360) + 360) % 360;
  if (x > 180) { x -= 360; }
  return x;
}

function describeLon(d) {
  const a = Math.round(Math.abs(d));
  if (a === 0)   { return '0 degrees'; }
  if (a === 180) { return '180 degrees'; }
  return a + ' degrees ' + (d > 0 ? 'east' : 'west');
}

/** Text equivalent of the diagram, for screen-reader users. */
function updateMapDescription() {
  const lat = coordLatex(S.latDeg, 'N', 'S', 'north', 'south', 'the equator');
  const lon = coordLatex(S.lonDeg, 'E', 'W', 'east',  'west',  'the prime meridian');
  const rays = raysLatex(S.latRaysText);

  $('map-description').textContent =
    'Flat map of Earth showing the daylight and night-time regions. ' +
    'The Sun is overhead at latitude ' + rays.say + '. ' +
    'Your location marker is at latitude ' + lat.say +
    ', longitude ' + lon.say + '. ' +
    'Local time there is ' + S.timeText + ' on ' + S.dateText + ', with ' +
    hoursLatex(S.daylightText).say + ' of daylight. ' +
    (S.animating
      ? ('The ' + (S.mode === 'Day' ? 'daily' : 'yearly') + ' animation is running.')
      : 'The animation is stopped.');
}

/* ---- Axis labels (HTML, MathJax-typeset, positioned over the canvas) ----- */

/**
 * attachBorderLabels(): 8 longitude labels top and bottom, 7 latitude labels
 * each side. Longitude label text is fixed; only its x position moves, so the
 * labels are typeset once and then repositioned with CSS percentages.
 */
function buildAxisLabels() {
  const top    = $('lon-labels-top');
  const bottom = $('lon-labels-bottom');
  const left   = $('lat-labels-left');
  const right  = $('lat-labels-right');

  const lonStep = 360 / N_LON_DIV;
  for (let i = 0; i < N_LON_DIV; i++) {
    const v = Math.round(i * lonStep);
    let tex;
    if      (v === 0)   { tex = '0^{\\circ}'; }
    else if (v === 180) { tex = '180^{\\circ}'; }
    else if (v < 180)   { tex = v + '^{\\circ}\\,\\mathrm{E}'; }
    else                { tex = (360 - v) + '^{\\circ}\\,\\mathrm{W}'; }

    for (const host of [top, bottom]) {
      const span = document.createElement('span');
      span.innerHTML = '$' + tex + '$';
      host.appendChild(span);
    }
  }

  const latStep = 180 / N_LAT_DIV;
  for (let i = 0; i <= N_LAT_DIV; i++) {
    const v = Math.round(90 - i * latStep);
    let tex;
    if      (v > 0) { tex = v + '^{\\circ}\\,\\mathrm{N}'; }
    else if (v < 0) { tex = (-v) + '^{\\circ}\\,\\mathrm{S}'; }
    else            { tex = '0^{\\circ}'; }

    // y is the centre of the label, as a percentage of the canvas height.
    const pct = ((BORDER + i * (MAP_H / N_LAT_DIV)) / CANVAS_H) * 100;
    for (const host of [left, right]) {
      const span = document.createElement('span');
      span.innerHTML = '$' + tex + '$';
      span.style.top = pct + '%';
      host.appendChild(span);
    }
  }

  // Static min/max labels beside each slider (setMinLabel / setMaxLabel).
  setMath('lat-min-label', '90^{\\circ}\\,\\mathrm{S}');
  setMath('lat-max-label', '90^{\\circ}\\,\\mathrm{N}');
  setMath('lon-min-label', '180^{\\circ}\\,\\mathrm{W}');
  setMath('lon-max-label', '180^{\\circ}\\,\\mathrm{E}');
  setMath('spd-min-label', '1');
  setMath('spd-max-label', '10');

  typesetStatic([top, bottom, left, right]);
  positionLonLabels();
}

/** updateBorderLabels(): longitude labels follow the map offset. */
function positionLonLabels() {
  const top    = $('lon-labels-top');
  const bottom = $('lon-labels-bottom');
  if (!top || top.children.length === 0) { return; }

  let x = (S.offset !== 0) ? MAP_W * (1 - S.offset / 360) : 0;
  const stepX = MAP_W / N_LON_DIV;

  for (let i = 0; i < N_LON_DIV; i++) {
    const pct = ((BORDER + x) / CANVAS_W) * 100;
    top.children[i].style.left    = pct + '%';
    bottom.children[i].style.left = pct + '%';
    x = (x + stepX) % MAP_W;
  }
}

/* ==========================================================================
   ANIMATION LOOP

   onEnterFrame ran at the SWF's 30 fps. Here the counters are advanced from
   elapsed wall-clock time so the pace matches on any display refresh rate.
   ========================================================================== */

let rafId    = null;
let lastTime = 0;
let accum    = 0;

function loop(now) {
  rafId = requestAnimationFrame(loop);

  if (!lastTime) { lastTime = now; }
  let dt = now - lastTime;
  lastTime = now;

  // A backgrounded tab must not fast-forward the sim when it returns.
  if (dt > 250) { dt = 250; }
  accum += dt;

  let steps = 0;
  while (accum >= FRAME_MS && steps < 8) {
    step();
    accum -= FRAME_MS;
    steps++;
  }
  if (steps > 0) { render(); }
}

function startAnimation() {
  S.animating = true;
  lastTime = 0;
  accum = 0;
  if (rafId === null) { rafId = requestAnimationFrame(loop); }
  render();
}

function stopAnimation() {
  S.animating = false;
  if (rafId !== null) { cancelAnimationFrame(rafId); rafId = null; }
  render();
}

/* ==========================================================================
   INPUT
   ========================================================================== */

let liveTimer = null;

/** Announce on commit, not per tick, and never twice with the same wording. */
function announce(message) {
  if (message === lastAnnouncement) { return; }
  lastAnnouncement = message;
  clearTimeout(liveTimer);
  liveTimer = setTimeout(() => { $('sr-live').textContent = message; }, 120);
}

/**
 * Wire a number box and a range slider to the same state.
 * Both get mouse-wheel adjustment while focused, in addition to the arrow-key
 * behaviour a native control already provides.
 */
function wireNumericPair(boxId, sliderId, min, max, apply, describe) {
  const box    = $(boxId);
  const slider = $(sliderId);

  const commit = (raw, announceIt) => {
    let v = Math.round(Number(raw));
    if (!isFinite(v)) { return; }
    v = Math.min(max, Math.max(min, v));
    apply(v);
    render();
    if (announceIt) { announce(describe(v)); }
  };

  slider.addEventListener('input',  () => commit(slider.value, false));
  slider.addEventListener('change', () => commit(slider.value, true));

  box.addEventListener('input',  () => commit(box.value, false));
  box.addEventListener('change', () => commit(box.value, true));

  // Mouse wheel on either control, only while it has focus, so the page
  // never scrolls out from under the user.
  for (const el of [box, slider]) {
    el.addEventListener('wheel', (e) => {
      if (document.activeElement !== el) { return; }
      e.preventDefault();
      const delta = e.deltaY < 0 ? 1 : -1;
      commit(Number(el.value) + delta, true);
    }, { passive: false });
  }

  // PageUp/PageDown and Home/End on the number box (the slider has them free).
  box.addEventListener('keydown', (e) => {
    const big = Math.max(1, Math.round((max - min) / 10));
    let v = null;
    if      (e.key === 'PageUp')   { v = Number(box.value) + big; }
    else if (e.key === 'PageDown') { v = Number(box.value) - big; }
    else if (e.key === 'Home')     { v = min; }
    else if (e.key === 'End')      { v = max; }
    if (v !== null) { e.preventDefault(); commit(v, true); }
  });
}

/* ---- Map drag: pointer and keyboard, both driving S.offset --------------- */

function wireMapDrag() {
  const el = $('map-drag');
  let dragging = false, pointerId = null, startX = 0, startOffset = 0;

  const scaleFactor = () => {
    // Map client pixels back into original stage units so the drag maths keeps
    // matching the ActionScript at any display size.
    const rect = canvas.getBoundingClientRect();
    return rect.width > 0 ? (CANVAS_W / rect.width) : 1;
  };

  el.addEventListener('pointerdown', (e) => {
    // Dragging is enabled only while the animation is stopped, exactly as
    // component_Animate() does with setAllowDragging().
    el.focus();                       // click-to-focus, so arrows work at once
    if (S.animating) { return; }
    dragging = true;
    pointerId = e.pointerId;
    el.setPointerCapture(pointerId);
    el.classList.add('is-dragging');
    startX = e.clientX * scaleFactor();
    startOffset = S.offset;
    e.preventDefault();
  });

  el.addEventListener('pointermove', (e) => {
    if (!dragging) { return; }
    // dragOnMouseMoveFunc: offset = initOffset - dx * (360 / mapWidth)
    const dx = e.clientX * scaleFactor() - startX;
    setLongitudeOffset(startOffset - dx * DEG_PER_PX);
    render();
  });

  const endDrag = () => {
    if (!dragging) { return; }
    dragging = false;
    el.classList.remove('is-dragging');
    if (pointerId !== null) {
      try { el.releasePointerCapture(pointerId); } catch (err) { /* already gone */ }
      pointerId = null;
    }
    announce($('map-drag').getAttribute('aria-valuetext'));
  };

  el.addEventListener('pointerup', endDrag);
  el.addEventListener('pointercancel', endDrag);

  el.addEventListener('keydown', (e) => {
    if (S.animating) { return; }
    let d = 0;
    switch (e.key) {
      case 'ArrowLeft':  case 'ArrowDown': d = -1;  break;
      case 'ArrowRight': case 'ArrowUp':   d =  1;  break;
      case 'PageDown':                     d = -15; break;
      case 'PageUp':                       d =  15; break;
      case 'Home': setLongitudeOffset(180); render();
                   announce(el.getAttribute('aria-valuetext')); e.preventDefault(); return;
      default: return;
    }
    e.preventDefault();
    setLongitudeOffset(S.offset + d);
    render();
    announce(el.getAttribute('aria-valuetext'));
  });
}

/* ==========================================================================
   RESET / SETUP
   ========================================================================== */

/** Restore the exact load-time state. Wired to the masthead's sim-reset event. */
function resetSimulation() {
  S = Object.assign({}, INITIAL);
  termCache = { dec: null, spec: null };
  primeReadouts();
  if (prefersReducedMotion()) { stopAnimation(); } else { startAnimation(); }
  announce('Simulation reset.');
}

function prefersReducedMotion() {
  return window.matchMedia &&
         window.matchMedia('(prefers-reduced-motion: reduce)').matches;
}

/**
 * The SWF starts animating immediately, so its first frame replaces the
 * authoring placeholders ("Angle", "January 1") in the readouts. Running one
 * step here reproduces that first frame rather than showing the placeholders.
 */
function primeReadouts() {
  step();
  S.timeText = makeClockStatic(S.long1, S.count1, S.speed);
}

function loadImage(src) {
  return new Promise((resolve, reject) => {
    const img = new Image();
    img.onload  = () => resolve(img);
    img.onerror = () => reject(new Error('Could not load ' + src));
    img.src = src;
  });
}

function sizeCanvas() {
  dpr = Math.min(window.devicePixelRatio || 1, 3);
  canvas.width  = Math.round(CANVAS_W * dpr);
  canvas.height = Math.round(CANVAS_H * dpr);
  ctx = canvas.getContext('2d');
  ctx.imageSmoothingEnabled = true;
  drawMap();
}

async function init() {
  canvas = $('map-canvas');
  sizeCanvas();

  buildAxisLabels();

  wireNumericPair('latBox', 'latSlider', -90, 90,
    (v) => latitudeChanged(v),
    (v) => 'Latitude ' + coordLatex(v, 'N', 'S', 'north', 'south', 'the equator').say +
           '. Daylight hours ' + hoursLatex(S.daylightText).say + '.');

  wireNumericPair('lonBox', 'lonSlider', -180, 180,
    (v) => longitudeChanged(v),
    (v) => 'Longitude ' + coordLatex(v, 'E', 'W', 'east', 'west', 'the prime meridian').say +
           '. Local time ' + S.timeText + '.');

  wireNumericPair('speedBox', 'speedSlider', 1, 10,
    (v) => speedChanged(v),
    (v) => 'Animation speed ' + v + ' of 10.');

  wireMapDrag();

  $('resetButton').addEventListener('click', () => {
    resetToOrigin();
    render();
    announce('Location reset to latitude 0 degrees, longitude 0 degrees. Local time '
             + S.timeText + '. Daylight hours ' + hoursLatex(S.daylightText).say + '.');
  });

  $('animationButton').addEventListener('click', () => {
    // animationChanged(): the button label drives the toggle.
    if ($('animationButton').textContent === 'Stop Animation') {
      stopAnimation();
      announce('Animation stopped. You can now drag the map, or focus it and use the arrow keys.');
    } else {
      startAnimation();
      announce('Animation started, ' + (S.mode === 'Day' ? 'daily' : 'yearly') + ' cycle.');
    }
  });

  for (const id of ['modeYear', 'modeDay']) {
    $(id).addEventListener('change', () => {
      if (!$(id).checked) { return; }
      S.mode = $(id).value;
      render();
      announce(S.mode === 'Day'
        ? 'Daily cycle selected. The map scrolls beneath the Sun through one day.'
        : 'Yearly cycle selected. The Sun’s declination sweeps through the seasons.');
    });
  }

  // Reset comes from the masthead component; the sim adds no second Reset.
  document.addEventListener('sim-reset', resetSimulation);

  window.addEventListener('resize', () => { sizeCanvas(); positionLonLabels(); });

  try {
    [dayImg, nightImg, markerImg] = await Promise.all([
      loadImage('assets/map-day.jpg'),
      loadImage('assets/map-night.jpg'),
      loadImage('assets/marker.svg')
    ]);
    imagesReady = true;
  } catch (err) {
    console.error(err);
    $('map-description').textContent =
      'The map images could not be loaded. The numeric readouts are still correct.';
  }

  primeReadouts();

  if (prefersReducedMotion()) {
    // 2.3.3 / 2.2.2: show the equivalent state without motion, and say so.
    stopAnimation();
    announce('Reduced motion is enabled, so the animation is stopped. '
             + 'Choose Start Animation to run it.');
  } else {
    startAnimation();
  }
}

/**
 * kl-unl.js calls klunlInitEqn() once MathJax is ready; redefining it here is
 * the foundation's documented hook for sim start-up.
 */
function klunlInitEqn() {
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init, { once: true });
  } else {
    init();
  }
}

// If MathJax fails to arrive for any reason, still start the sim.
window.addEventListener('load', () => {
  if (!canvas) { klunlInitEqn(); }
});
