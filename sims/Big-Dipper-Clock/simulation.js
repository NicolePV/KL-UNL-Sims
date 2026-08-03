/* =============================================================================
   Big Dipper Clock  --  HTML5 / KL-UNL accessible port
   -----------------------------------------------------------------------------
   Behavior is ported verbatim from the decompiled ActionScript (AS1):
     scripts/frame_1/DoAction.as          (master controller, DST, update())
     scripts/Sky Diagram.as               (star-group rotation + twilight alpha)
     scripts/Time Of Day Clock.as         (clock hand geometry + drag)
     scripts/Time Of Day Panel.as         (HH:MM <-> timeOfDay, formatting)
     scripts/Day Of Year Panel.as         (day <-> month/day, monthPoints)
     scripts/Day Of Year Slider.as        (timeline cursor + increment drag)

   The simulation is STATIC (no animation loop): the AS calls pauseAnimation()/
   resumeAnimation() on the root, but those functions are never defined in the
   source, so they are no-ops. State changes therefore only happen on user input.

   Constellation geometry (star positions + connector lines + pointer line) is
   taken VERBATIM from the exported vector shapes
     shapes/262.svg  (Big Dipper + Cassiopeia connector lines, white)
     shapes/273.svg  (Little Dipper connector line, white)
     shapes/271.svg  (orange "pointer" dotted line)
   which all share one coordinate frame whose origin is the North Star (Polaris),
   the rotation pole.  Copies live in assets/.
============================================================================= */

"use strict";

/* -------------------------------------------------------------------------- */
/*  Constants copied verbatim from the ActionScript source                    */
/* -------------------------------------------------------------------------- */

// frame_1/DoAction.as  +  Day Of Year Panel.as / Slider.as
const MONTH_POINTS = [0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334, 365];
const MONTH_LABELS_FULL = ["January", "February", "March", "April", "May", "June",
  "July", "August", "September", "October", "November", "December"];
const MONTH_LABELS_SHORT = ["Jan", "Feb", "Mar", "Apr", "May", "Jun",
  "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];

// Sky Diagram.as  -- setSolarDaysSinceZero() physical constants (verbatim)
const TWILIGHT_ANGLE = 0.12217304763960307;   // 7 degrees, civil-ish twilight
const LATITUDE       = 0.7155849933176751;     // ~41 deg N (Lincoln, NE)
const OBLIQUITY_SIN  = 0.39714789063478056;    // sin(obliquity) factor
const TWO_PI         = 6.283185307179586;
const PI             = 3.141592653589793;

/* -------------------------------------------------------------------------- */
/*  Daylight-saving setup (frame_1/DoAction.as lines 97-104)                  */
/*  Used ONLY for the informational "daylight saving time in effect" placard.  */
/*  The original does NOT use a DST offset for the sky position (see update());*/
/*  we use the true current year here so the placard is correct for the user's */
/*  locale (the original's getYear() math made its sky DST delta zero).         */
/* -------------------------------------------------------------------------- */
const currentYear = new Date().getFullYear();
const standardOffset       = new Date(currentYear, 0, 1).getTimezoneOffset();   // Jan 1
const daylightSavingOffset = new Date(currentYear, 6, 1).getTimezoneOffset();   // Jul 1

/* -------------------------------------------------------------------------- */
/*  Single source of truth for state                                          */
/* -------------------------------------------------------------------------- */
const state = {
  timeOfDay: 0.05,   // fraction of a day [0,1)
  dayOfYear: 78,     // integer [0,364]
  showLabels: true,
  dstActive: false,  // recomputed every update()
};

/* -------------------------------------------------------------------------- */
/*  Constellation geometry (verbatim shape coordinates; Polaris at origin)    */
/*  Each [x,y] is a star; consecutive stars are joined by the connector line.  */
/* -------------------------------------------------------------------------- */
// shapes/262.svg, subpath A  -- Big Dipper (handle -> bowl)
const BIG_DIPPER = [
  [-336.2, -89.8], [-288.9, -50.1], [-280.45, -12.8], [-265.4, 31.2],
  [-286.6, 63.3], [-240.9, 109.9], [-204.9, 90.35],
];
// shapes/262.svg, subpath B  -- Cassiopeia (the "W")
const CASSIOPEIA = [
  [176.3, 81.4], [211.3, 68.4], [216.6, 40.4], [254.1, 32.9], [237.3, -5.8],
];
// shapes/273.svg  -- Little Dipper (Kochab -> Polaris); last point ~ origin
const LITTLE_DIPPER = [
  [-110.15, -73.85], [-114.65, -99.85], [-69.15, -98.35], [-70.15, -74.85],
  [-34.15, -59.85], [-12.35, -28.6], [-0.35, -0.1],
];
// shapes/271.svg  -- orange pointer dotted line. The shape is placed so its
// upper-right end lands exactly on Polaris (the pole); the line runs from the
// Big Dipper bowl UP to the North Star and stops there (it does not extend past
// it). Offset applied: t = (-164.0, 73.0) so the shape's 'b' end -> origin.
const POINTER_LINE = { a: [-324.65, 143.25], b: [0.7, -0.5] };

// Text-label anchor points in the star frame (measured from the sprite render).
// Anchors rotate with the sky; the text itself is kept upright (counter-rotated).
const SKY_LABELS = [
  { text: "North Star",    x: -5,   y: 47 },
  { text: "Big\nDipper",   x: -190, y: 157 },
  { text: "Little\nDipper",x: -25,  y: -158 },
  { text: "Cassiopeia",    x: 285,  y: 107 },
];

// Sky canvas layout (internal coordinates; CSS scales the element)
const SKY_W = 880, SKY_H = 790;
const POLE_X = 440, POLE_Y = 384;       // North Star / rotation pole
const GROUND_TOP = 700;                 // green ground begins here

/* -------------------------------------------------------------------------- */
/*  DOM references                                                            */
/* -------------------------------------------------------------------------- */
const skyCanvas   = document.getElementById("sky-canvas");
const skyCtx      = skyCanvas.getContext("2d");
const skyDesc     = document.getElementById("sky-desc");
const clockCanvas = document.getElementById("clock-canvas");
const clockCtx    = clockCanvas.getContext("2d");
const clockDesc   = document.getElementById("clock-desc");

const hourInput   = document.getElementById("hour-input");
const minuteInput = document.getElementById("minute-input");
const dayInput    = document.getElementById("day-input");
const monthSelect = document.getElementById("month-select");
const dstNote     = document.getElementById("dst-note");
const showDetails = document.getElementById("show-details");
const systemBtn   = document.getElementById("system-clock-btn");

const doySlider   = document.getElementById("doy-slider");
const doyMonths   = document.getElementById("doy-months");
const doyCursor   = document.getElementById("doy-cursor");
const simStatus   = document.getElementById("sim-status");

let prefersReducedMotion = false; // this sim has no continuous motion, but honor it anyway

/* -------------------------------------------------------------------------- */
/*  Master controller  (frame_1/DoAction.as)                                  */
/* -------------------------------------------------------------------------- */

function getTimeOfDay() { return state.timeOfDay; }

// setTimeOfDay(tod): wrap into [0,1) exactly as AS:  (tod % 1 + 1) % 1
function setTimeOfDay(tod) {
  if (typeof tod === "number" && !isNaN(tod) && isFinite(tod)) {
    state.timeOfDay = ((tod % 1) + 1) % 1;
  }
  update();
}

function getDayOfYear() { return state.dayOfYear; }

// setDayOfYear(doy): floor + wrap into [0,365)  exactly as AS
function setDayOfYear(doy) {
  if (typeof doy === "number" && !isNaN(doy) && isFinite(doy)) {
    state.dayOfYear = ((Math.floor(doy) % 365) + 365) % 365;
  }
  update();
}

// setFracDayOfYear(fdoy): split a fractional day-of-year into day + time-of-day
function setFracDayOfYear(fdoy) {
  if (typeof fdoy === "number" && !isNaN(fdoy) && isFinite(fdoy)) {
    state.dayOfYear = ((Math.floor(fdoy) % 365) + 365) % 365;
    state.timeOfDay = ((fdoy % 1) + 1) % 1;
  }
  update();
}

// update()  -- recompute DST placard + solar day, then redraw everything.
function update() {
  // Determine current month index from dayOfYear (frame_1/DoAction.as)
  let mi = 0;
  while (mi < 12) {
    if (state.dayOfYear < MONTH_POINTS[mi]) break;
    mi++;
  }
  mi = mi - 1;
  const dateNum = state.dayOfYear - MONTH_POINTS[mi] + 1;

  const fhour  = state.timeOfDay * 24;
  const hour   = Math.floor(fhour);
  const fmin   = 60 * (fhour - hour);
  const minute = Math.floor(fmin);
  const second = Math.floor(60 * (fmin - minute));

  // Placard only (informational): is the chosen date within DST for this locale?
  const d = new Date(currentYear, mi, dateNum, hour, minute, second);
  state.dstActive = (d.getTimezoneOffset() === daylightSavingOffset) &&
                    (daylightSavingOffset !== standardOffset);

  // PARITY: the original Flash sim does NOT apply a DST correction to the
  // celestial position. Its ActionScript uses currentYear = now.getYear()
  // (which returns the year MINUS 1900, e.g. 126 for 2026) and feeds that back
  // into new Date(currentYear, ...), creating dates in year 126 AD where no DST
  // exists -- so its daylightSavingDelta evaluates to 0 and the sky is driven
  // straight from the displayed clock time. Applying a real DST shift here
  // offset every DST-window date (~Mar-Nov) by one hour versus the original, so
  // we match the original exactly and apply no DST offset to the sky.
  const solarDaysSinceZero = state.dayOfYear + state.timeOfDay - 78.5;

  renderAll(solarDaysSinceZero);
}

// reset()  -- exact initial state (frame_1/DoAction.as)
function reset() {
  state.showLabels = true;
  showDetails.checked = true;
  state.timeOfDay = 0.05;
  state.dayOfYear = 78;
  update();
}

// setToNow()  -- "set to system clock" button (frame_1/DoAction.as)
function setToNow() {
  const n = new Date();
  let mo = n.getMonth();
  let da = n.getDate();
  if (mo === 1 && da === 29) { da = 28; }            // skip leap day, as AS does
  const fdoy = MONTH_POINTS[mo] + da - 1 +
    (n.getHours() + (n.getMinutes() + n.getSeconds() / 60) / 60) / 24;
  setFracDayOfYear(fdoy);
}

/* -------------------------------------------------------------------------- */
/*  Sky Diagram math (Sky Diagram.as, verbatim)                               */
/* -------------------------------------------------------------------------- */

// Rotation of the whole star group, in degrees (Flash _rotation: CW positive).
function starGroupRotationDeg(solDaysSinceZero) {
  let r = (102.5 - 360 * (solDaysSinceZero * 366 / 365 - 0.49583333333333335)) % 360;
  return r;
}

// Sky (daytime blue) opacity in [0,1] from the twilight model. Returns null in
// the degenerate polar cases the AS guards against (never happens at lat 41).
function skyOpacity(solDaysSinceZero) {
  let f = ((solDaysSinceZero - 0.5) % 1 + 1) % 1;

  const sunLongitude  = solDaysSinceZero / 365 * 2 * PI;
  const sunDeclination = Math.asin(OBLIQUITY_SIN * Math.sin(sunLongitude));
  const sinSunDec = Math.sin(sunDeclination);
  const sinLat    = Math.sin(LATITUDE);
  const cosSunDec = Math.cos(sunDeclination);
  const cosLat    = Math.cos(LATITUDE);
  const zTwilight = Math.sin(-TWILIGHT_ANGLE);
  const sinProduct = sinSunDec * sinLat;
  const cosProduct = cosSunDec * cosLat;
  const cosAlphaAtTwilightLimit = (zTwilight - sinProduct) / cosProduct;
  const cosAlphaOnHorizon       = (-sinProduct) / cosProduct;

  const neverAboveTwilightLimit = cosAlphaAtTwilightLimit >= 1;
  const neverBelowTwilightLimit = cosAlphaAtTwilightLimit <= -1;
  const neverAboveHorizon       = cosAlphaOnHorizon >= 1;
  const neverBelowHorizon       = cosAlphaOnHorizon <= -1;

  if (neverBelowHorizon || neverAboveTwilightLimit || neverBelowTwilightLimit ||
      neverAboveHorizon) {
    return null; // AS traces "shouldn't happen"; leave sky alpha unchanged
  }

  const twilightStartAlpha = Math.acos(cosAlphaAtTwilightLimit);
  const nightEnds = 0.5 * (1 - twilightStartAlpha / PI);
  const twilightEndAlpha = Math.acos(cosAlphaOnHorizon);
  const dayStarts = 0.5 * (1 - twilightEndAlpha / PI);
  const twilightFraction = dayStarts - nightEnds;

  if (f > 0.5) { f = 1 - f; }
  let a = (f - nightEnds) / twilightFraction;
  if (a < 0) a = 0; else if (a > 1) a = 1;
  return a;
}

/* -------------------------------------------------------------------------- */
/*  Rendering                                                                 */
/* -------------------------------------------------------------------------- */

let lastSkyOpacity = 1;

function renderAll(solDaysSinceZero) {
  const rotDeg = starGroupRotationDeg(solDaysSinceZero);
  let op = skyOpacity(solDaysSinceZero);
  if (op === null) op = lastSkyOpacity; else lastSkyOpacity = op;

  drawSky(rotDeg, op);
  syncTimePanel();
  syncDatePanel();
  drawClock();
  updateLiveDescriptions(rotDeg, op);
}

// ---- Sky ------------------------------------------------------------------
function drawSky(rotDeg, op) {
  const ctx = skyCtx;
  ctx.clearRect(0, 0, SKY_W, SKY_H);

  // Night background gradient (shapes/259.svg: #444444 -> #262626 -> #000000)
  const night = ctx.createLinearGradient(0, 0, 0, SKY_H);
  night.addColorStop(0, "#444444");
  night.addColorStop(0.30, "#262626");
  night.addColorStop(1, "#000000");
  ctx.fillStyle = night;
  ctx.fillRect(0, 0, SKY_W, SKY_H);

  // Daytime sky gradient (shapes/260.svg: top #4f79b9 -> #9cb4d8 -> #d5dfee)
  // Opacity fades with the twilight model (Sky Diagram.as skyMC._alpha).
  ctx.save();
  ctx.globalAlpha = op;
  const day = ctx.createLinearGradient(0, 0, 0, SKY_H);
  day.addColorStop(0, "#4f79b9");
  day.addColorStop(0.6, "#9cb4d8");
  day.addColorStop(1, "#d5dfee");
  ctx.fillStyle = day;
  ctx.fillRect(0, 0, SKY_W, SKY_H);
  ctx.restore();

  // Rotating star group (stars + connector lines + pointer line)
  ctx.save();
  ctx.translate(POLE_X, POLE_Y);
  ctx.rotate(rotDeg * Math.PI / 180);

  // Orange pointer line (only with "show details")  -- shapes/271.svg
  if (state.showLabels) drawPointerLine(ctx);

  // White connector lines
  drawPolyline(ctx, BIG_DIPPER);
  drawPolyline(ctx, CASSIOPEIA);
  drawPolyline(ctx, LITTLE_DIPPER);

  // White star dots (shapes/274.svg: r=4 circle)
  drawStars(ctx, BIG_DIPPER);
  drawStars(ctx, CASSIOPEIA);
  drawStars(ctx, LITTLE_DIPPER);
  ctx.restore();

  // Upright, counter-rotated text labels (only with "show details")
  if (state.showLabels) drawSkyLabels(ctx, rotDeg);

  // Ground (shapes/277.svg: #623726 -> #81c851), fixed (does not rotate)
  const ground = ctx.createLinearGradient(0, GROUND_TOP, 0, SKY_H);
  ground.addColorStop(0, "#623726");
  ground.addColorStop(0.45, "#81c851");
  ground.addColorStop(1, "#5e9636");
  ctx.fillStyle = ground;
  // Horizon curves UP toward the left/right edges (concave-up valley): a
  // wide-angle / fish-eye effect of mapping a large sky angle onto a flat
  // rectangle. Matches shapes/277.svg, whose top edge dips ~15px in the middle.
  ctx.beginPath();
  ctx.moveTo(0, GROUND_TOP);
  ctx.quadraticCurveTo(SKY_W / 2, GROUND_TOP + 30, SKY_W, GROUND_TOP);
  ctx.lineTo(SKY_W, SKY_H);
  ctx.lineTo(0, SKY_H);
  ctx.closePath();
  ctx.fill();
}

function drawPolyline(ctx, pts) {
  ctx.strokeStyle = "#ffffff";
  ctx.lineWidth = 1.6;
  ctx.lineJoin = "round";
  ctx.lineCap = "round";
  ctx.beginPath();
  ctx.moveTo(pts[0][0], pts[0][1]);
  for (let i = 1; i < pts.length; i++) ctx.lineTo(pts[i][0], pts[i][1]);
  ctx.stroke();
}

function drawStars(ctx, pts) {
  ctx.fillStyle = "#fbfbfb";
  for (const [x, y] of pts) {
    ctx.beginPath();
    ctx.arc(x, y, 4, 0, TWO_PI);
    ctx.fill();
  }
}

function drawPointerLine(ctx) {
  const { a, b } = POINTER_LINE;
  const dots = 42;            // matches the dotted density of shapes/271.svg
  ctx.fillStyle = "#ffcc99";
  for (let i = 0; i <= dots; i++) {
    const t = i / dots;
    const x = a[0] + (b[0] - a[0]) * t;
    const y = a[1] + (b[1] - a[1]) * t;
    ctx.beginPath();
    ctx.arc(x, y, 2.4, 0, TWO_PI);
    ctx.fill();
  }
}

function drawSkyLabels(ctx, rotDeg) {
  const rad = rotDeg * Math.PI / 180;
  const cos = Math.cos(rad), sin = Math.sin(rad);
  ctx.fillStyle = "#ffffff";
  ctx.font = "600 26px system-ui, -apple-system, 'Segoe UI', sans-serif";
  ctx.textAlign = "center";
  ctx.textBaseline = "middle";
  for (const lab of SKY_LABELS) {
    // anchor rotates with the star group; text stays upright
    const rx = lab.x * cos - lab.y * sin + POLE_X;
    const ry = lab.x * sin + lab.y * cos + POLE_Y;
    const lines = lab.text.split("\n");
    const lineH = 28;
    const y0 = ry - (lines.length - 1) * lineH / 2;
    lines.forEach((ln, i) => ctx.fillText(ln, rx, y0 + i * lineH));
  }
}

// ---- Clock (Time Of Day Clock.as) -----------------------------------------
const CLOCK = { cx: 180, cy: 180, r: 160 };

function drawClock() {
  const ctx = clockCtx;
  const { cx, cy, r } = CLOCK;
  ctx.clearRect(0, 0, 360, 360);

  // dial face
  const face = ctx.createRadialGradient(cx, cy - 30, 20, cx, cy, r);
  face.addColorStop(0, "#ffffff");
  face.addColorStop(1, "#e6e6e6");
  ctx.fillStyle = face;
  ctx.beginPath();
  ctx.arc(cx, cy, r, 0, TWO_PI);
  ctx.fill();

  // outer rings
  ctx.strokeStyle = "#000000";
  ctx.lineWidth = 1.4;
  ctx.beginPath(); ctx.arc(cx, cy, r, 0, TWO_PI); ctx.stroke();
  ctx.beginPath(); ctx.arc(cx, cy, r - 12, 0, TWO_PI); ctx.stroke();

  // 24 hour ticks (longer/bolder every 3 hours)
  for (let h = 0; h < 24; h++) {
    const ang = h / 24 * TWO_PI;            // 0 at top, CW
    const sin = Math.sin(ang), cos = Math.cos(ang);
    const major = (h % 3 === 0);
    const outer = r;
    const inner = r - (major ? 15 : 9);
    ctx.lineWidth = major ? 2.8 : 1.2;
    ctx.beginPath();
    ctx.moveTo(cx + sin * outer, cy - cos * outer);
    ctx.lineTo(cx + sin * inner, cy - cos * inner);
    ctx.stroke();
  }

  // hour numbers 0..23
  ctx.fillStyle = "#1a1a1a";
  ctx.textAlign = "center";
  ctx.textBaseline = "middle";
  const numR = r - 26;
  for (let h = 0; h < 24; h++) {
    const ang = h / 24 * TWO_PI;
    const x = cx + Math.sin(ang) * numR;
    const y = cy - Math.cos(ang) * numR;
    const major = (h % 3 === 0);
    ctx.font = (major ? "700 " : "400 ") + (major ? "22px" : "16px") +
               " system-ui, -apple-system, 'Segoe UI', sans-serif";
    ctx.fillText(String(h), x, y);
  }

  // cardinal text labels
  ctx.fillStyle = "#000000";
  ctx.font = "700 15px system-ui, -apple-system, 'Segoe UI', sans-serif";
  const cardR = r - 72;
  ctx.fillText("12 am", cx, cy - cardR);
  ctx.fillText("12 pm", cx, cy + cardR);
  ctx.fillText("6 am", cx + cardR, cy);
  ctx.fillText("6 pm", cx - cardR, cy);

  // ----- hands -----
  const tod = state.timeOfDay;
  const clockHour = Math.floor(24 * tod);
  const clockMinute = 60 * (24 * tod - clockHour);

  // minute hand: grey, long, thin  (shapes/242-243.svg) -- 6 deg per minute
  drawHand(ctx, 6 * clockMinute, r - 22, 6, "#666666");
  // hour hand: black, short, fat   (shapes/239-240.svg) -- 360 deg per day
  drawHand(ctx, 360 * tod, r - 68, 9, "#000000");

  // pivot
  ctx.fillStyle = "#333333";
  ctx.beginPath();
  ctx.arc(cx, cy, 7, 0, TWO_PI);
  ctx.fill();
}

function drawHand(ctx, rotDeg, len, width, color) {
  const { cx, cy } = CLOCK;
  const ang = rotDeg * Math.PI / 180;       // 0 = up, CW positive
  const tipX = cx + Math.sin(ang) * len;
  const tipY = cy - Math.cos(ang) * len;
  const backX = cx - Math.sin(ang) * 16;    // small tail
  const backY = cy + Math.cos(ang) * 16;
  ctx.strokeStyle = color;
  ctx.lineWidth = width;
  ctx.lineCap = "round";
  ctx.beginPath();
  ctx.moveTo(backX, backY);
  ctx.lineTo(tipX, tipY);
  ctx.stroke();
}

/* -------------------------------------------------------------------------- */
/*  Panel synchronisation (Time Of Day Panel.as / Day Of Year Panel.as)       */
/* -------------------------------------------------------------------------- */

let traditionalTimeString = "";

function syncTimePanel() {
  const tod = getTimeOfDay();
  let h = Math.floor(24 * tod);
  const minf = 60 * (24 * tod - h);
  let min = Math.floor(minf + 0.5);
  if (min === 60) { h = (h + 1) % 24; min = 0; }
  const hourStr = (h < 10 ? "0" : "") + h;
  const minStr  = (min < 10 ? "0" : "") + min;

  // Don't clobber a field the user is actively editing
  if (document.activeElement !== hourInput)   hourInput.value = hourStr;
  if (document.activeElement !== minuteInput)  minuteInput.value = minStr;

  // traditional 12-hour string (Time Of Day Panel.as), used for screen readers
  if (h === 0)        traditionalTimeString = "12:" + minStr + " AM";
  else if (h === 12)  traditionalTimeString = "12:" + minStr + " PM";
  else if (h > 12)    traditionalTimeString = (h - 12) + ":" + minStr + " PM";
  else                traditionalTimeString = hourStr + ":" + minStr + " AM";

  // clock slider value (minutes since midnight) + spoken time, for keyboard use
  clockCanvas.setAttribute("aria-valuenow", String(h * 60 + min));
  clockCanvas.setAttribute("aria-valuetext", traditionalTimeString);

  dstNote.hidden = !state.dstActive;
}

function syncDatePanel() {
  const doy = getDayOfYear();
  let mi = 0;
  while (doy >= MONTH_POINTS[mi] && mi < 13) mi++;
  mi = mi - 1;
  const dayOfMonth = doy - MONTH_POINTS[mi] + 1;

  if (document.activeElement !== monthSelect) monthSelect.selectedIndex = mi;
  if (document.activeElement !== dayInput)    dayInput.value = String(dayOfMonth);

  // day-of-year strip cursor: scaleFactor * (day + 0.5) / 365 of the width
  const frac = (doy + 0.5) / 365;
  doyCursor.style.left = (frac * 100) + "%";
  doySlider.setAttribute("aria-valuenow", String(doy));
  doySlider.setAttribute("aria-valuetext",
    MONTH_LABELS_FULL[mi] + " " + dayOfMonth + " (day " + (doy + 1) + " of 365)");
}

function updateLiveDescriptions(rotDeg, op) {
  // Sky description
  let phase;
  if (op > 0.85) phase = "daytime (sky bright)";
  else if (op > 0.15) phase = "twilight";
  else phase = "night (sky dark, stars prominent)";
  const doy = getDayOfYear();
  let mi = 0;
  while (doy >= MONTH_POINTS[mi] && mi < 13) mi++;
  mi -= 1;
  const dayOfMonth = doy - MONTH_POINTS[mi] + 1;
  skyDesc.textContent =
    "Northern sky looking due north on " + MONTH_LABELS_FULL[mi] + " " + dayOfMonth +
    " at " + traditionalTimeString + ". The Big Dipper, Little Dipper and Cassiopeia " +
    "circle the North Star. It is currently " + phase + ".";

  clockDesc.textContent = "Clock reads " + traditionalTimeString +
    (state.dstActive ? ". Daylight saving time is in effect." : ".");
}

/* -------------------------------------------------------------------------- */
/*  Screen-reader status announcements (audio pass)                            */
/*  Fired only on COMMIT/RELEASE (not per drag tick) through one polite live   */
/*  region, with quantity names and units spoken as words.                     */
/* -------------------------------------------------------------------------- */
function skyPhaseWords() {
  if (lastSkyOpacity > 0.85) return "daytime, sky bright";
  if (lastSkyOpacity > 0.15) return "twilight";
  return "night, sky dark and stars prominent";
}

// Full current state as a spoken sentence: date, time (with units), sky, DST.
function currentStateSpoken() {
  const doy = getDayOfYear();
  let mi = 0;
  while (doy >= MONTH_POINTS[mi] && mi < 13) mi++;
  mi -= 1;
  const dayOfMonth = doy - MONTH_POINTS[mi] + 1;

  // time spoken with explicit unit words (hours / minutes) plus the clock form
  const tod = getTimeOfDay();
  let h = Math.floor(24 * tod);
  const minf = 60 * (24 * tod - h);
  let mn = Math.floor(minf + 0.5);
  if (mn === 60) { h = (h + 1) % 24; mn = 0; }
  const hWord = h + (h === 1 ? " hour " : " hours ");
  const mWord = mn + (mn === 1 ? " minute" : " minutes");
  const dst = state.dstActive ? " Daylight saving time in effect." : "";

  return MONTH_LABELS_FULL[mi] + " " + dayOfMonth + ", time of day " + hWord + mWord +
    " (" + traditionalTimeString + "). The sky is " + skyPhaseWords() + "." + dst;
}

function announce(message) {
  if (simStatus) simStatus.textContent = message;
}

/* -------------------------------------------------------------------------- */
/*  Time text-field input (Time Of Day Panel.as setTimeByTextFields)          */
/* -------------------------------------------------------------------------- */
function commitTimeFields() {
  const hour = parseInt(hourInput.value, 10);
  const min  = parseInt(minuteInput.value, 10);
  if (!isFinite(hour) || isNaN(hour) || !isFinite(min) || isNaN(min) ||
      hour < 0 || hour > 23 || min < 0 || min > 59) {
    syncTimePanel();   // invalid -> restore display (AS: update())
    announce("Invalid time entry ignored. " + currentStateSpoken());
  } else {
    setTimeOfDay((((hour + min / 60) / 24) % 1 + 1) % 1);
    announce("Time changed. " + currentStateSpoken());
  }
}

/* -------------------------------------------------------------------------- */
/*  Date field / month input (Day Of Year Panel.as setDayOfYearManually)      */
/* -------------------------------------------------------------------------- */
function commitDateFields() {
  const dayOfMonth = parseInt(dayInput.value, 10);
  const month = monthSelect.selectedIndex;
  const candidate = dayOfMonth + MONTH_POINTS[month] - 1;
  if (candidate === undefined || !isFinite(candidate) || isNaN(candidate) ||
      candidate < MONTH_POINTS[month] || candidate >= MONTH_POINTS[month + 1]) {
    syncDatePanel();   // invalid -> restore display
    announce("Invalid date entry ignored. " + currentStateSpoken());
  } else {
    setDayOfYear(candidate);
    announce("Date changed. " + currentStateSpoken());
  }
}

/* -------------------------------------------------------------------------- */
/*  Clock hand dragging (Time Of Day Clock.as onMouseMoveFunc)                */
/* -------------------------------------------------------------------------- */
// Map a pointer event to clock-internal coordinates relative to the centre.
function clockPointer(ev) {
  const rect = clockCanvas.getBoundingClientRect();
  const sx = clockCanvas.width / rect.width;
  const sy = clockCanvas.height / rect.height;
  const x = (ev.clientX - rect.left) * sx - CLOCK.cx;
  const y = (ev.clientY - rect.top) * sy - CLOCK.cy;
  return { x, y };
}

let clockDrag = null; // { hand: 'hour'|'minute', angleOffset }

function clockHourAt() { return Math.floor(24 * state.timeOfDay); }
function clockMinuteAt() {
  const h = clockHourAt();
  return 60 * (24 * state.timeOfDay - h);
}

function beginClockDrag(ev) {
  const { x, y } = clockPointer(ev);
  const dist = Math.hypot(x, y);
  if (dist > CLOCK.r) return;                 // outside dial
  // choose hand: minute hand is long; pick hour hand only when near the centre
  // half. Use the current hand angles to decide which is closer to the cursor.
  const hourRot = 360 * state.timeOfDay;
  const minRot  = 6 * clockMinuteAt();
  const ptrDeg  = ((Math.atan2(y, x) * 180 / Math.PI) + 90 + 360) % 360; // 0=up CW
  const dHour = angularDist(ptrDeg, ((hourRot % 360) + 360) % 360);
  const dMin  = angularDist(ptrDeg, ((minRot % 360) + 360) % 360);
  // prefer hour hand if the click is in the inner region OR clearly closer to it
  const hand = (dist < CLOCK.r - 56 ? (dHour <= dMin + 25 ? "hour" : "minute")
                                    : (dMin <= dHour ? "minute" : "hour"));
  const curRotRad = (hand === "hour" ? hourRot : minRot) * Math.PI / 180;
  // angleOffset (Time Of Day Clock.as): rotation - atan2(ymouse,xmouse)
  const angleOffset = curRotRad - Math.atan2(y, x);
  clockDrag = { hand, angleOffset };
  ev.preventDefault();
  clockCanvas.setPointerCapture?.(ev.pointerId);
}

function angularDist(a, b) {
  let d = Math.abs(a - b) % 360;
  return d > 180 ? 360 - d : d;
}

function moveClockDrag(ev) {
  if (!clockDrag) return;
  const { x, y } = clockPointer(ev);
  // fraction = (angleOffset + atan2(ymouse,xmouse)) / 2pi, wrapped to [0,1)
  let frac = (clockDrag.angleOffset + Math.atan2(y, x)) / TWO_PI;
  frac = ((frac % 1) + 1) % 1;

  if (clockDrag.hand === "hour") {
    // Time Of Day Clock.as hour-hand onMouseMoveFunc (with day rollover)
    const t = 24 * frac;
    const clockHour = clockHourAt();
    if (t < 6 && clockHour >= 18) {
      setFracDayOfYear(getDayOfYear() + frac + 1);
    } else if (t >= 18 && clockHour < 6) {
      setFracDayOfYear(getDayOfYear() + frac - 1);
    } else {
      setTimeOfDay(frac);
    }
  } else {
    // minute-hand onMouseMoveFunc (with hour/day rollover)
    const clockHour = clockHourAt();
    const clockMinute = clockMinuteAt();
    if (clockMinute > 45 && frac < 0.25) {
      if (clockHour === 23) setFracDayOfYear(getDayOfYear() + frac / 24 + 1);
      else setTimeOfDay((clockHour + frac + 1) / 24);
    } else if (clockMinute < 15 && frac > 0.75) {
      if (clockHour === 0) setFracDayOfYear(getDayOfYear() + (23 + frac) / 24 - 1);
      else setTimeOfDay((clockHour + frac - 1) / 24);
    } else {
      setTimeOfDay((clockHour + frac) / 24);
    }
  }
  ev.preventDefault();
}

function endClockDrag(ev) {
  if (!clockDrag) return;
  clockDrag = null;
  try { clockCanvas.releasePointerCapture?.(ev.pointerId); } catch (e) {}
  announce("Time changed. " + currentStateSpoken());   // announce on release, not per tick
}

// Current displayed hour + minute (same rounding as syncTimePanel).
function currentHM() {
  const tod = state.timeOfDay;
  let h = Math.floor(24 * tod);
  const minf = 60 * (24 * tod - h);
  let m = Math.floor(minf + 0.5);
  if (m === 60) { h = (h + 1) % 24; m = 0; }
  return { h, m };
}

// Set the time of day from whole hours + minutes (wraps into [0,1) like the AS).
function setTimeHM(h, m) {
  setTimeOfDay((((h + m / 60) / 24) % 1 + 1) % 1);
}

// Clock keyboard control (role="slider"): arrows = 1 minute, Page = 1 hour,
// Home/End = 12:00 AM / 11:59 PM. Time wraps within the day. The focused
// slider's aria-valuetext (updated in syncTimePanel) is what the screen reader
// announces, so we do not also push to #sim-status (avoids double-speaking).
function clockKey(ev) {
  const { h, m } = currentHM();
  let total = h * 60 + m;     // minutes since midnight
  let handled = true;
  switch (ev.key) {
    case "ArrowUp": case "ArrowRight":  total += 1; break;
    case "ArrowDown": case "ArrowLeft": total -= 1; break;
    case "PageUp":   total += 60; break;
    case "PageDown": total -= 60; break;
    case "Home":     total = 0; break;
    case "End":      total = 23 * 60 + 59; break;
    default: handled = false;
  }
  if (!handled) return;
  ev.preventDefault();
  total = ((total % 1440) + 1440) % 1440;
  setTimeHM(Math.floor(total / 60), total % 60);
}

// Arrow-key steppers for the number fields (Tab to the field, then Up/Down).
// These are text inputs (not sliders), so they announce through #sim-status.
// syncTimePanel/syncDatePanel skip the focused field (so typing isn't clobbered),
// so the steppers refresh their own field explicitly after changing state.
function refreshTimeFields() {
  const { h, m } = currentHM();
  hourInput.value = (h < 10 ? "0" : "") + h;
  minuteInput.value = (m < 10 ? "0" : "") + m;
}
function refreshDateFields() {
  const doy = getDayOfYear();
  let mi = 0;
  while (doy >= MONTH_POINTS[mi] && mi < 13) mi++;
  mi -= 1;
  dayInput.value = String(doy - MONTH_POINTS[mi] + 1);
  monthSelect.selectedIndex = mi;
}
function stepHour(dir) {
  const { h, m } = currentHM();
  setTimeHM(((h + dir) % 24 + 24) % 24, m);
  refreshTimeFields();
  announce("Time changed. " + currentStateSpoken());
}
function stepMinute(dir) {
  const { h, m } = currentHM();
  let total = h * 60 + m + dir;
  total = ((total % 1440) + 1440) % 1440;
  setTimeHM(Math.floor(total / 60), total % 60);
  refreshTimeFields();
  announce("Time changed. " + currentStateSpoken());
}
function stepDay(dir) {
  setDayOfYear(getDayOfYear() + dir);   // wraps like the AS (and the strip slider)
  refreshDateFields();
  announce("Date changed. " + currentStateSpoken());
}

/* -------------------------------------------------------------------------- */
/*  Day-of-year strip slider (Day Of Year Slider.as)                          */
/* -------------------------------------------------------------------------- */
function doyPointerFrac(ev) {
  const rect = doySlider.getBoundingClientRect();
  let f = (ev.clientX - rect.left) / rect.width;
  if (f < 0) f = 0; else if (f > 1) f = 1;
  return f;
}

let doyDragging = false;
let doyGrabOffsetPx = 0;   // pointer-to-handle offset, so grabbing doesn't jump

function dayFromFrac(f) {
  // inverse of setCursorDay: cursor at scaleFactor*(day+0.5); width spans 365 days
  return f * 365 - 0.5;
}

function beginDoyDrag(ev) {
  doyDragging = true;
  doySlider.focus();
  const rect = doySlider.getBoundingClientRect();
  // Grabbing the triangle/line handle: preserve the offset so it doesn't jump
  // (matches the original Day Of Year Cursor onPress offset behavior).
  if (ev.target === doyCursor || doyCursor.contains(ev.target)) {
    const cursorX = rect.left + (parseFloat(doyCursor.style.left) || 0) / 100 * rect.width;
    doyGrabOffsetPx = ev.clientX - cursorX;
  } else {
    // Clicking the strip body jumps the cursor to that position.
    doyGrabOffsetPx = 0;
    setDayOfYear(dayFromFrac(doyPointerFrac(ev)));
  }
  ev.preventDefault();
  doySlider.setPointerCapture?.(ev.pointerId);
}
function moveDoyDrag(ev) {
  if (!doyDragging) return;
  const rect = doySlider.getBoundingClientRect();
  let f = (ev.clientX - doyGrabOffsetPx - rect.left) / rect.width;
  if (f < 0) f = 0; else if (f > 1) f = 1;
  setDayOfYear(dayFromFrac(f));
  ev.preventDefault();
}
function endDoyDrag(ev) {
  if (!doyDragging) return;
  doyDragging = false;
  try { doySlider.releasePointerCapture?.(ev.pointerId); } catch (e) {}
  announce("Date changed. " + currentStateSpoken());   // announce on release, not per tick
}

function doyKey(ev) {
  let handled = true;
  const doy = getDayOfYear();
  switch (ev.key) {
    case "ArrowLeft": case "ArrowDown":  setDayOfYear(doy - 1); break;
    case "ArrowRight": case "ArrowUp":   setDayOfYear(doy + 1); break;
    case "PageDown": setDayOfYear(doy - 7); break;
    case "PageUp":   setDayOfYear(doy + 7); break;
    case "Home":     setDayOfYear(0); break;
    case "End":      setDayOfYear(364); break;
    default: handled = false;
  }
  if (handled) ev.preventDefault();
}

/* -------------------------------------------------------------------------- */
/*  Month strip labels                                                        */
/* -------------------------------------------------------------------------- */
function buildMonthStrip() {
  // month <select>
  MONTH_LABELS_FULL.forEach((m, i) => {
    const opt = document.createElement("option");
    opt.value = String(i);
    opt.textContent = m;
    monthSelect.appendChild(opt);
  });

  // month tick labels across the strip (Jan..Dec), centred in each month span
  doyMonths.innerHTML = "";
  for (let i = 0; i < 12; i++) {
    const start = MONTH_POINTS[i], end = MONTH_POINTS[i + 1];
    const centerFrac = ((start + end) / 2) / 365;
    const tick = document.createElement("span");
    tick.className = "doy-slider__month";
    tick.style.left = (centerFrac * 100) + "%";
    tick.textContent = MONTH_LABELS_SHORT[i];
    doyMonths.appendChild(tick);

    // divider line at month start
    if (i > 0) {
      const div = document.createElement("span");
      div.className = "doy-slider__divider";
      div.style.left = (start / 365 * 100) + "%";
      doyMonths.appendChild(div);
    }
  }
}

/* -------------------------------------------------------------------------- */
/*  Wiring                                                                    */
/* -------------------------------------------------------------------------- */
function wire() {
  buildMonthStrip();

  // masthead Reset
  document.addEventListener("sim-reset", () => {
    reset();
    announce("Simulation reset. " + currentStateSpoken());
  });

  // show details
  showDetails.addEventListener("change", () => {
    state.showLabels = showDetails.checked;
    update();
    announce(showDetails.checked
      ? "Constellation labels and pointer line shown."
      : "Constellation labels and pointer line hidden.");
  });

  // set to system clock
  systemBtn.addEventListener("click", () => {
    setToNow();
    announce("Set to system clock. " + currentStateSpoken());
  });

  // time fields: commit on Enter or blur; Up/Down arrows step the value
  hourInput.addEventListener("keydown", (e) => {
    if (e.key === "Enter") commitTimeFields();
    else if (e.key === "ArrowUp")   { e.preventDefault(); stepHour(1); }
    else if (e.key === "ArrowDown") { e.preventDefault(); stepHour(-1); }
  });
  minuteInput.addEventListener("keydown", (e) => {
    if (e.key === "Enter") commitTimeFields();
    else if (e.key === "ArrowUp")   { e.preventDefault(); stepMinute(1); }
    else if (e.key === "ArrowDown") { e.preventDefault(); stepMinute(-1); }
  });
  hourInput.addEventListener("blur", commitTimeFields);
  minuteInput.addEventListener("blur", commitTimeFields);
  // restrict to digits (AS: restrict = "0-9")
  [hourInput, minuteInput, dayInput].forEach((el) => {
    el.addEventListener("input", () => { el.value = el.value.replace(/[^0-9]/g, ""); });
  });

  // date fields: commit on Enter or blur; Up/Down arrows step the day of year
  dayInput.addEventListener("keydown", (e) => {
    if (e.key === "Enter") commitDateFields();
    else if (e.key === "ArrowUp")   { e.preventDefault(); stepDay(1); }
    else if (e.key === "ArrowDown") { e.preventDefault(); stepDay(-1); }
  });
  dayInput.addEventListener("blur", commitDateFields);
  monthSelect.addEventListener("change", commitDateFields);

  // clock: hand drag (Pointer Events: one path for mouse + touch) + keyboard
  clockCanvas.addEventListener("pointerdown", beginClockDrag);
  clockCanvas.addEventListener("pointermove", moveClockDrag);
  clockCanvas.addEventListener("pointerup", endClockDrag);
  clockCanvas.addEventListener("pointercancel", endClockDrag);
  clockCanvas.addEventListener("keydown", clockKey);

  // day-of-year strip drag + keyboard
  doySlider.addEventListener("pointerdown", beginDoyDrag);
  doySlider.addEventListener("pointermove", moveDoyDrag);
  doySlider.addEventListener("pointerup", endDoyDrag);
  doySlider.addEventListener("pointercancel", endDoyDrag);
  doySlider.addEventListener("keydown", doyKey);

  // reduced motion preference (no continuous motion here, but recorded)
  const mq = window.matchMedia("(prefers-reduced-motion: reduce)");
  prefersReducedMotion = mq.matches;
  mq.addEventListener?.("change", (e) => { prefersReducedMotion = e.matches; });

  reset();
}

// Redefine the foundation equation initializer (no equations in this sim).
window.klunlInitEqn = function () { /* no mathematics to typeset */ };

if (document.readyState === "loading") {
  document.addEventListener("DOMContentLoaded", wire);
} else {
  wire();
}
