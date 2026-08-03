/* =====================================================================
   Influence of Planets on the Sun Explorer
   HTML5 port of ca_extrasolarplanets_starwobble.swf (ActionScript 1).

   Ground truth for behaviour: the decompiled ActionScript, chiefly
     scripts/frame_1/DoAction.as            (activity_Setup, body_Update,
                                              resetSun, onSliderChanged,
                                              math_computeFixedDigits)
     scripts/frame_1/PlaceObject2_...       (slider + button + checkbox
                                              construct/release handlers)
     scripts/Standard Slider v6.as          (slider component)
     scripts/Slider Logic Class v6.as       (slider value model)
   Ground truth for geometry: the SWF placement tags --
     stage 780 x 420 @ 30 fps, sun sprite placed at (270, 210) scaled 1.5,
     gravityCenter placed at (270, 210) scaled 1.0.

   Every constant, table and formula below is copied verbatim from that
   source.  Presentation follows the KL-UNL foundation + WCAG 2.1 AA.
   ===================================================================== */
'use strict';

/* ---------------------------------------------------------------------
   1. Constants ported verbatim from the ActionScript / SWF
   --------------------------------------------------------------------- */

// activity_Setup():  sunArray = {radius:695500, onscreenradius:..., mass:{a:1.989,b:30}}
const SUN_RADIUS_KM = 695500;
const SUN_MASS      = { a: 1.989, b: 30 };          // 1.989 x 10^30 kg

// sun.globe is shape 86, 80 px wide in symbol space; the sun instance is
// placed with _xscale = 150.  onscreenradius = globe._width / 2 * (_xscale/100)
const GLOBE_SYMBOL_WIDTH = 80;
const SUN_STAGE_SCALE    = 1.5;                     // _xscale 150 -> 1.5
const ONSCREEN_RADIUS    = GLOBE_SYMBOL_WIDTH / 2 * (SUN_STAGE_SCALE * 100 / 100);
const KM_PER_PIXEL       = SUN_RADIUS_KM / ONSCREEN_RADIUS;   // 11591.666...

// gravityCenter instance placement on the 780 x 420 stage
const GRAVITY_CENTER = { x: 270, y: 210 };

// activity_Setup(): sunpathSize = 100, sunpathSegmentMinimum = 10
const SUNPATH_SIZE            = 100;
const SUNPATH_SEGMENT_MINIMUM = 10;

// Standard Slider "on(construct)": minValue 0, maxValue 5000, initValue 1000,
// scalingMode linear, precisionMode "fixed digits", precision 0 (so the
// smallest step -- one arrow-key tick -- is 10^-0 = 1 day per second).
const SPEED_MIN        = 0;
const SPEED_MAX        = 5000;
const SPEED_INIT       = 1000;
const SPEED_INCREMENT  = Math.pow(10, -0);          // = 1

// The original ran body_Update from sun.onEnterFrame at the SWF's 30 fps.
// Stepping at that same cadence keeps the per-frame orbital advance and the
// spacing of the traced path identical to the original.
const FRAME_INTERVAL_MS = 1000 / 30;

// Any gap longer than this is a stall, not a slow frame (about seven missed
// frames).  See frame() -- the gap is discarded rather than integrated.
const MAX_FRAME_GAP_MS = 250;

// Canvas viewport: the left 540 px of the original 780 x 420 stage.  All
// drawing and physics stay in original stage coordinates -- nothing is
// recomputed from the on-screen element size.
const STAGE_W = 540;
const STAGE_H = 420;

// Exported art reused as-is (never redrawn): shapes/85.svg is the sun's
// glow, shapes/86.svg the sun's globe, shapes/89.svg the green centre-of-
// mass cross.  Symbol-space sizes come straight from the SVG headers.
const ART = {
  glow:  { src: 'assets/sun-glow-85.svg',       w: 150, h: 150 },
  globe: { src: 'assets/sun-globe-86.svg',      w:  80, h:  80 },
  com:   { src: 'assets/center-of-mass-89.svg', w:  28, h:  28 }
};

// sunpathClip.lineStyle(2, 16777215, 100)  ->  2 px, #FFFFFF, alpha 100
const PATH_LINE_WIDTH = 2;
const PATH_LINE_COLOR = '#ffffff';

/* Planet table -- verbatim from activity_Setup().
   mass  = a x 10^b kg,  distance = a x 10^b km,  orbitperiod in days.   */
function buildPlanetTable() {
  const planets = [
    { planetname: 'Mercury', mass: { a: 3.3022, b: 23 }, distance: { a: 5.7909175, b: 7 }, orbitperiod:    87.97 },
    { planetname: 'Venus',   mass: { a: 4.8685, b: 24 }, distance: { a: 1.0820893, b: 8 }, orbitperiod:   224.7  },
    { planetname: 'Earth',   mass: { a: 5.9737, b: 24 }, distance: { a: 1.4959789, b: 8 }, orbitperiod:   365.24 },
    { planetname: 'Mars',    mass: { a: 6.4185, b: 23 }, distance: { a: 2.2793664, b: 8 }, orbitperiod:   686.93 },
    { planetname: 'Jupiter', mass: { a: 1.8987, b: 27 }, distance: { a: 7.7841202, b: 8 }, orbitperiod:  4330.6  },
    { planetname: 'Saturn',  mass: { a: 5.6851, b: 26 }, distance: { a: 1.4267254, b: 9 }, orbitperiod: 10755.7  },
    { planetname: 'Uranus',  mass: { a: 8.6849, b: 25 }, distance: { a: 2.8709722, b: 9 }, orbitperiod: 30687.2  },
    { planetname: 'Neptune', mass: { a: 1.0244, b: 26 }, distance: { a: 4.4982529, b: 9 }, orbitperiod: 60190    },
    { planetname: 'Pluto',   mass: { a: 1.3,    b: 22 }, distance: { a: 5.90638,   b: 9 }, orbitperiod: 90553    }
  ];

  // status = false; anglestarting = Math.random() * 3600; anglecurrent = anglestarting
  for (let i = 0; i < planets.length; i++) {
    planets[i].status        = false;
    planets[i].anglestarting = Math.random() * 3600;
    planets[i].anglecurrent  = planets[i].anglestarting;
  }

  // Everything is expressed relative to the Earth, exactly as in the source.
  const earth = planets[2];
  for (let i = 0; i < planets.length; i++) {
    planets[i].mass.earthbased =
      planets[i].mass.a / earth.mass.a * Math.pow(10, planets[i].mass.b - earth.mass.b);
    planets[i].distance.earthbased =
      planets[i].distance.a / earth.distance.a * Math.pow(10, planets[i].distance.b - earth.distance.b);
  }
  return planets;
}

// sunArray.mass.earthbased = 1.989e30 / 5.9737e24  (Earth masses)
const EARTH_REF = { mass: { a: 5.9737, b: 24 }, distance: { a: 1.4959789, b: 8 } };
const SUN_MASS_EARTHBASED =
  SUN_MASS.a / EARTH_REF.mass.a * Math.pow(10, SUN_MASS.b - EARTH_REF.mass.b);

/* ---------------------------------------------------------------------
   2. Number formatting -- exact port of math_computeFixedDigits()
   --------------------------------------------------------------------- */
function mathComputeFixedDigits(numInput, numDigits, forceFlag) {
  numInput *= Math.pow(10, numDigits);
  numInput = Math.round(numInput);
  numInput /= Math.pow(10, numDigits);
  let out = String(numInput);
  if (forceFlag) {
    const parts = out.split('.');
    if (parts.length <= 1) { out += '.'; }
    const have = parts[1] === undefined ? 0 : parts[1].length;
    for (let i = have; i < numDigits; i++) { out += '0'; }
  }
  return out;
}

/* ---------------------------------------------------------------------
   3. Text readouts.

   The original simulation displays no equations, formulas or mathematical
   notation -- only plain numbers and the unit "AU" -- so nothing here is
   typeset.  Values are written straight into the element as ordinary
   sans-serif text, which also means the digits never change typeface as a
   value updates.
   --------------------------------------------------------------------- */
function setText(el, value) {
  if (!el) { return; }
  if (el.textContent !== value) { el.textContent = value; }
}

/* ---------------------------------------------------------------------
   4. State -- one plain object; render() redraws everything from it.
   --------------------------------------------------------------------- */
const state = {
  planets:        buildPlanetTable(),
  daysPerSecond:  SPEED_INIT,
  daysTotal:      0,                 // activity_Setup(): daysTotal = 0
  gradualChange:  0,                 // activity_Setup(): gradualChange = 0
  sunX:           GRAVITY_CENTER.x,
  sunY:           GRAVITY_CENTER.y,
  sunpath:        { counter: 0, positionarray: [] },
  sunpathcurve:   [],
  timeStarting:   0,                 // activity_Setup(): time_Starting = new Date()
  lastFrameTime:  0,
  running:        true,
  needsDraw:      true
};

const el = {};          // cached DOM references
const art = {};         // loaded <img> elements for the reused SVG art
let   ctx = null;
let   canvasScale = 1;  // devicePixelRatio backing-store multiplier

/* ---------------------------------------------------------------------
   5. Physics -- exact port of body_Update()
   --------------------------------------------------------------------- */
function bodyUpdate(nowMs) {
  const secondsElapsed = (nowMs - state.timeStarting) / 1000;
  const daysElapsed    = state.daysPerSecond * secondsElapsed;
  state.daysTotal += daysElapsed;

  let xDelta = 0;
  let yDelta = 0;

  for (let i = 0; i < state.planets.length; i++) {
    const p = state.planets[i];
    if (!p.status) { continue; }        // unchecked planets do not advance

    // Fraction of one orbit completed since the previous frame.
    let periodPortion = daysElapsed / p.orbitperiod;
    periodPortion -= Math.floor(periodPortion);

    p.anglecurrent = p.anglestarting - periodPortion * 360;
    p.anglecurrent = p.anglecurrent >= 0 ? p.anglecurrent : p.anglecurrent + 360;

    // Distance of the Sun from the barycentre due to THIS planet:
    //   d_sun = (m_planet / M_sun) * a_planet
    const sunDistanceEarthbased =
      p.mass.earthbased * p.distance.earthbased / SUN_MASS_EARTHBASED;
    const sunDistanceKM =
      sunDistanceEarthbased * EARTH_REF.distance.a * Math.pow(10, EARTH_REF.distance.b);

    // The Sun is pulled opposite the planet, hence the subtraction.
    xDelta -= Math.cos(6.283185307179586 * p.anglecurrent / 360) * sunDistanceKM / KM_PER_PIXEL;
    yDelta -= Math.sin(6.283185307179586 * p.anglecurrent / 360) * sunDistanceKM / KM_PER_PIXEL;

    p.anglestarting = p.anglecurrent;
  }

  state.sunX = GRAVITY_CENTER.x + xDelta;
  state.sunY = GRAVITY_CENTER.y + yDelta;
  state.timeStarting = nowMs;         // time_Starting = new Date()

  updateSunPath();
}

/* Trail bookkeeping -- exact port of the second half of body_Update().
   Each stored point owns the one segment drawn from the previous point to
   it (the original gave each segment its own movie clip at level++, drawn
   above the sun and the centre-of-mass marker). */
function updateSunPath() {
  const pa = state.sunpath.positionarray;

  // sunpathIndex = positionarray.length - 2  (undefined -> NaN on the first
  // two frames, exactly as in the original, so the else-branch is taken).
  const prev   = pa[pa.length - 2];
  const prevX  = prev ? prev.x : NaN;
  const prevY  = prev ? prev.y : NaN;
  const deltaX = Math.abs(state.sunX - prevX);
  const deltaY = Math.abs(state.sunY - prevY);
  const distance = Math.sqrt(Math.pow(deltaX, 2) + Math.pow(deltaY, 2));

  if (distance < SUNPATH_SEGMENT_MINIMUM) {
    // Too close to the point before last: drop the last point and its clip.
    state.sunpath.counter--;
    pa.pop();
  } else {
    state.sunpathcurve = [];
  }

  state.sunpathcurve.push({ x: state.sunX, y: state.sunY });

  state.sunpath.counter++;
  const point = { x: state.sunX, y: state.sunY, alpha: 100, removed: false, seg: null };
  pa.push(point);

  const idx = pa.length - 1;
  if (pa.length > 1) {
    const from = pa[idx - 1];
    if (state.gradualChange >= 5) {
      // One segment is skipped after a checkbox change so the jump in the
      // Sun's position is not drawn as a line.
      state.gradualChange--;
    } else if (state.sunpathcurve.length < 2) {
      point.seg = { type: 'line', fromX: from.x, fromY: from.y, toX: point.x, toY: point.y };
    } else {
      const ca = state.sunpathcurve;
      const ci = Math.floor((ca.length - 1) / 2);
      let cx, cy;
      if ((ca.length - 1) / 2 === ci) {
        cx = (ca[ci].x + ca[ci + 1].x) / 2;
        cy = (ca[ci].y + ca[ci + 1].y) / 2;
      } else {
        cx = ca[ci].x;
        cy = ca[ci].y;
      }
      point.seg = { type: 'curve', fromX: from.x, fromY: from.y, cx: cx, cy: cy, toX: point.x, toY: point.y };
    }
  }

  if (distance >= SUNPATH_SEGMENT_MINIMUM) {
    // Every older segment fades by 1% per step (_alpha -= 1).
    for (let i = 0; i < pa.length - 1; i++) { pa[i].alpha -= 1; }
  }

  if (pa.length > SUNPATH_SIZE) { pa.shift(); }
}

/* resetSun() -- exact port.  The original removes the drawn path clips but
   deliberately leaves positionarray and counter untouched, so the next
   segment is still drawn from the Sun's last recorded position. */
function resetSun() {
  const pa = state.sunpath.positionarray;
  for (let i = 0; i < pa.length; i++) { pa[i].removed = true; }
  state.needsDraw = true;
}

/* ---------------------------------------------------------------------
   6. Canvas rendering.  The reused SVG art is composited at its original
      position, size and z-order; only the code-drawn trail is redrawn.
   --------------------------------------------------------------------- */
function sizeCanvas() {
  const canvas = el.stage;
  canvasScale = Math.min(window.devicePixelRatio || 1, 2);
  const w = Math.round(STAGE_W * canvasScale);
  const h = Math.round(STAGE_H * canvasScale);
  if (canvas.width !== w || canvas.height !== h) {
    canvas.width  = w;
    canvas.height = h;
  }
  state.needsDraw = true;
}

function drawStage() {
  if (!ctx) { return; }
  ctx.setTransform(canvasScale, 0, 0, canvasScale, 0, 0);
  ctx.globalAlpha = 1;
  ctx.fillStyle   = '#000000';                 // original stage background
  ctx.fillRect(0, 0, STAGE_W, STAGE_H);

  // ---- 1. the Sun: glow (shape 85) then globe (shape 86), scaled 1.5 ----
  drawArt('glow',  state.sunX, state.sunY, SUN_STAGE_SCALE);
  drawArt('globe', state.sunX, state.sunY, SUN_STAGE_SCALE);

  // ---- 2. the centre-of-mass cross (shape 89), scale 1, fixed ----
  drawArt('com', GRAVITY_CENTER.x, GRAVITY_CENTER.y, 1);

  // ---- 3. the traced path, drawn above everything (level++ depths) ----
  ctx.lineWidth   = PATH_LINE_WIDTH;
  ctx.strokeStyle = PATH_LINE_COLOR;
  ctx.lineCap     = 'round';
  ctx.lineJoin    = 'round';
  const pa = state.sunpath.positionarray;
  for (let i = 0; i < pa.length; i++) {
    const pt = pa[i];
    if (pt.removed || !pt.seg) { continue; }
    const alpha = Math.max(0, Math.min(100, pt.alpha)) / 100;
    if (alpha <= 0) { continue; }
    ctx.globalAlpha = alpha;
    ctx.beginPath();
    ctx.moveTo(pt.seg.fromX, pt.seg.fromY);
    if (pt.seg.type === 'curve') {
      ctx.quadraticCurveTo(pt.seg.cx, pt.seg.cy, pt.seg.toX, pt.seg.toY);
    } else {
      ctx.lineTo(pt.seg.toX, pt.seg.toY);
    }
    ctx.stroke();
  }
  ctx.globalAlpha = 1;
}

function drawArt(key, cx, cy, scale) {
  const spec = ART[key];
  const img  = art[key];
  const w = spec.w * scale;
  const h = spec.h * scale;
  if (img && img.complete && img.naturalWidth > 0) {
    ctx.drawImage(img, cx - w / 2, cy - h / 2, w, h);
    return;
  }
  drawArtFallback(key, cx, cy, scale);
}

/* Only used if an exported SVG fails to load (e.g. opened from file://).
   Colours and radii come from the same SVG headers. */
function drawArtFallback(key, cx, cy, scale) {
  if (key === 'glow') {
    const r = 75 * scale;
    const g = ctx.createRadialGradient(cx, cy, 0, cx, cy, r);
    g.addColorStop(0, 'rgba(255,255,128,1)');
    g.addColorStop(0.4392156862745098, 'rgba(255,255,128,1)');
    g.addColorStop(0.49411764705882355, 'rgba(255,255,139,0.5019608)');
    g.addColorStop(1, 'rgba(255,255,255,0)');
    ctx.fillStyle = g;
    ctx.beginPath(); ctx.arc(cx, cy, r, 0, 6.283185307179586); ctx.fill();
  } else if (key === 'globe') {
    const r = 40 * scale;
    const g = ctx.createRadialGradient(cx, cy, 0, cx, cy, r);
    g.addColorStop(0, '#fecb00');
    g.addColorStop(0.28627450980392155, '#fecb00');
    g.addColorStop(0.8823529411764706, '#fea000');
    g.addColorStop(1, '#fe9100');
    ctx.fillStyle = g;
    ctx.beginPath(); ctx.arc(cx, cy, r, 0, 6.283185307179586); ctx.fill();
  } else {
    const r = 12.5 * scale;
    ctx.save();
    ctx.strokeStyle = '#00ff00';
    ctx.lineWidth   = 3 * scale;
    ctx.lineCap     = 'round';
    ctx.beginPath();
    ctx.moveTo(cx - r, cy); ctx.lineTo(cx + r, cy);
    ctx.moveTo(cx, cy - r); ctx.lineTo(cx, cy + r);
    ctx.stroke();
    ctx.restore();
  }
}

function loadArt() {
  Object.keys(ART).forEach(function (key) {
    const img = new Image();
    img.decoding = 'async';
    img.addEventListener('load',  function () { state.needsDraw = true; });
    img.addEventListener('error', function () { state.needsDraw = true; });
    img.src = ART[key].src;
    art[key] = img;
  });
}

/* ---------------------------------------------------------------------
   7. Derived quantities used by the readouts and the spoken description
   --------------------------------------------------------------------- */
function sunOffset() {
  const dxPixels = state.sunX - GRAVITY_CENTER.x;
  const dyPixels = state.sunY - GRAVITY_CENTER.y;
  const rPixels  = Math.sqrt(dxPixels * dxPixels + dyPixels * dyPixels);
  return {
    dxPixels: dxPixels,
    dyPixels: dyPixels,
    km:       rPixels * KM_PER_PIXEL,
    rsun:     rPixels * KM_PER_PIXEL / SUN_RADIUS_KM,
    dxRsun:   dxPixels * KM_PER_PIXEL / SUN_RADIUS_KM,
    dyRsun:   dyPixels * KM_PER_PIXEL / SUN_RADIUS_KM
  };
}

function selectedPlanetNames() {
  return state.planets.filter(function (p) { return p.status; })
                      .map(function (p) { return p.planetname; });
}

function listToSentence(names) {
  if (names.length === 0) { return 'No planets are selected'; }
  if (names.length === 1) { return names[0] + ' is selected'; }
  return names.slice(0, -1).join(', ') + ' and ' + names[names.length - 1] + ' are selected';
}

/* ---------------------------------------------------------------------
   8. render() -- single place that redraws the canvas, syncs the DOM and
      refreshes the text equivalent of the diagram.
   --------------------------------------------------------------------- */
let lastDescUpdate    = 0;
let lastReadoutUpdate = 0;

// The canvas is redrawn every frame; the years readout refreshes five times a
// second.  The original rewrote its text field every frame, which at 1000 days
// per second churns the tenths digit ~27 times a second -- unreadable.  The
// value shown is the same value, sampled from the same state.
const READOUT_INTERVAL_MS = 200;
const DESC_INTERVAL_MS    = 1000;

function render(now) {
  drawStage();

  const time = now || 0;
  if (!now || time - lastReadoutUpdate >= READOUT_INTERVAL_MS) {
    lastReadoutUpdate = time;
    updateReadouts(time);
  }
}

function updateReadouts(time) {
  // ---- Years Elapsed (yearsTextField.text in the original) ----
  const years = mathComputeFixedDigits(state.daysTotal / 365, 1, true);
  setText(el.yearsValue, years);
  setText(el.yearsSr, 'Years elapsed ' + years + ' years.');

  // ---- Text equivalent of the canvas (slower; not a live region) ----
  if (!time || time - lastDescUpdate >= DESC_INTERVAL_MS) {
    lastDescUpdate = time;
    setText(el.stageDesc, describeStage(sunOffset(), years));
  }
}

function describeStage(off, years) {
  const horiz = Math.abs(off.dxRsun).toFixed(2) + ' solar radii to the ' +
                (off.dxPixels >= 0 ? 'right of' : 'left of');
  const vert  = Math.abs(off.dyRsun).toFixed(2) + ' solar radii ' +
                (off.dyPixels >= 0 ? 'below' : 'above');
  const names = selectedPlanetNames();
  return 'Diagram: the Sun is drawn on a black field with the fixed center of ' +
         'mass of the solar system marked by a green cross at the middle. ' +
         listToSentence(names) + '. ' +
         'Elapsed time ' + years + ' years. ' +
         'The Sun is ' + off.rsun.toFixed(2) + ' solar radii from the center of mass: ' +
         horiz + ' it and ' + vert + ' it. ' +
         (names.length
            ? 'A fading white curve traces where the Sun has been.'
            : 'With no planets selected the Sun sits on the center of mass and no path is traced.');
}

/* ---------------------------------------------------------------------
   9. Live-region announcements (on commit only, never per animation tick)
   --------------------------------------------------------------------- */
function announce(message) {
  el.srStatus.textContent = message;
}

/* ---------------------------------------------------------------------
   10. Animation loop.  getTimer()/new Date() -> performance.now();
       onEnterFrame -> one requestAnimationFrame loop throttled to the
       original 30 fps frame cadence.
   --------------------------------------------------------------------- */
function frame(now) {
  window.requestAnimationFrame(frame);

  const gap = now - state.lastFrameTime;

  if (state.running && gap >= FRAME_INTERVAL_MS - 0.5) {
    if (gap > MAX_FRAME_GAP_MS) {
      // The animation loop stalled -- a modal dialog opening, the tab going
      // to the background, a slow repaint.  bodyUpdate integrates real
      // elapsed time, so handing it the whole gap would advance every planet
      // by one huge step and draw a long straight chord across the traced
      // path instead of a smooth arc.  Treat the stall as time the
      // simulation was not running: resync the clock and take a zero-length
      // step this frame.
      state.timeStarting = now;
    }
    state.lastFrameTime = now;
    bodyUpdate(now);
    state.needsDraw = true;
  }

  if (state.needsDraw) {
    state.needsDraw = false;
    render(now);
  }
}

/* ---------------------------------------------------------------------
   11. Controls
   --------------------------------------------------------------------- */

/* Slider value model, "fixed digits" precision 0: clamp to [0, 5000] then
   snap to the nearest whole day per second (getValueObjectFromValue()). */
function snapSpeed(x) {
  if (x < SPEED_MIN) { x = SPEED_MIN; }
  else if (x > SPEED_MAX) { x = SPEED_MAX; }
  return SPEED_INCREMENT * Math.round(x / SPEED_INCREMENT);
}

// onSliderChanged(sliderValue) { daysPerSecond = sliderValue; }
function setDaysPerSecond(value) {
  state.daysPerSecond = value;
}

function speakSpeed(value) {
  return 'Animation speed ' + value + ' days per second';
}

function syncSpeedUi() {
  const v = state.daysPerSecond;
  el.speedField.value  = String(v);
  el.speedSlider.value = String(v);
  el.speedSlider.setAttribute('aria-valuetext', speakSpeed(v));
}

function buildPlanetList() {
  const list = el.planetList;
  list.textContent = '';

  state.planets.forEach(function (p, i) {
    // distance readout: exact port of the activity_Setup() text field code
    const planetDistance = p.distance.earthbased;
    const fixedDigits    = planetDistance >= 1 ? 1 : 3;
    const shown          = mathComputeFixedDigits(planetDistance, fixedDigits);

    const choice = document.createElement('div');
    choice.className = 'ips-planet-choice';

    const box = document.createElement('input');
    box.type  = 'checkbox';
    box.id    = 'planet_' + i;
    box.checked = p.status;
    box.setAttribute('aria-describedby', 'planetDist_' + i);
    box.addEventListener('change', function () { onPlanetToggled(i, box.checked); });

    const label = document.createElement('label');
    label.setAttribute('for', box.id);
    label.textContent = p.planetname;

    choice.appendChild(box);
    choice.appendChild(label);

    const dist = document.createElement('div');
    dist.className = 'ips-planet-distance';

    // "0.387 AU" -- identical to the original on-screen text, plain text.
    const value = document.createElement('span');
    value.className = 'ips-planet-au';
    value.id = 'planetDistValue_' + i;
    value.setAttribute('aria-hidden', 'true');
    value.textContent = shown + ' AU';

    // Spoken form: the unit spelled out, so "AU" is never read as letters.
    const sr = document.createElement('span');
    sr.className = 'sr-only';
    sr.id = 'planetDist_' + i;
    sr.textContent = 'mean orbital distance ' + shown +
                     (shown === '1' ? ' astronomical unit' : ' astronomical units');

    dist.appendChild(value);
    dist.appendChild(sr);

    list.appendChild(choice);
    list.appendChild(dist);
  });
}

/* myListener.click in activity_Setup():
     resetSun(); daysTotal = 0; status = !status; gradualChange = 5;         */
function onPlanetToggled(index, checked) {
  resetSun();
  state.daysTotal = 0;
  state.planets[index].status = checked;
  state.gradualChange = 5;
  state.needsDraw = true;

  const names = selectedPlanetNames();
  announce(state.planets[index].planetname + (checked ? ' added.' : ' removed.') + ' ' +
           listToSentence(names) + '. ' +
           'Traced path cleared and elapsed time reset to 0.0 years.');
  render(0);
}

function onSpeedSliderInput() {
  const v = snapSpeed(parseFloat(el.speedSlider.value));
  setDaysPerSecond(v);
  el.speedField.value = String(v);
  el.speedSlider.setAttribute('aria-valuetext', speakSpeed(v));
}

function onSpeedSliderCommit() {
  announce(speakSpeed(state.daysPerSecond) + '.');
}

/* The original value field restricted typing to 0-9 . e E + - and committed
   on Enter or on losing focus; anything unparseable reverted to the current
   value (setValue ignores NaN, then updateSynchronization redraws it). */
function onSpeedFieldInput() {
  const cleaned = el.speedField.value.replace(/[^0-9.eE+\-]/g, '');
  if (cleaned !== el.speedField.value) { el.speedField.value = cleaned; }
}

function commitSpeedField() {
  const parsed = parseFloat(el.speedField.value);
  if (!isNaN(parsed) && isFinite(parsed)) {
    setDaysPerSecond(snapSpeed(parsed));
  }
  syncSpeedUi();
  announce(speakSpeed(state.daysPerSecond) + '.');
}

function setRunning(running) {
  state.running = running;
  if (running) {
    // Do not count the paused interval as elapsed simulation time.
    state.timeStarting  = window.performance.now();
    state.lastFrameTime = state.timeStarting;
  }
  el.pauseButton.textContent = running ? 'Pause' : 'Resume';
  el.pauseButton.setAttribute('aria-label',
    running ? 'Pause the animation' : 'Resume the animation');
  const years = mathComputeFixedDigits(state.daysTotal / 365, 1, true);
  announce(running
    ? 'Animation running at ' + state.daysPerSecond + ' days per second.'
    : 'Animation paused at ' + years + ' years elapsed.');
}

/* ---------------------------------------------------------------------
   12. Reset (from the masthead's bubbling "sim-reset" event).

   The masthead Reset restores the exact initial state of the page: no
   planets selected, freshly randomised starting angles, elapsed time 0,
   the traced path gone and the animation speed back to its initial value.
   (The original Flash Reset button only cleared the path and the elapsed
   time counter -- see CONVERSION_NOTES.md.)
   --------------------------------------------------------------------- */
function resetAll() {
  state.planets       = buildPlanetTable();
  state.daysPerSecond = SPEED_INIT;
  state.daysTotal     = 0;
  state.gradualChange = 0;
  state.sunX          = GRAVITY_CENTER.x;
  state.sunY          = GRAVITY_CENTER.y;
  state.sunpath       = { counter: 0, positionarray: [] };
  state.sunpathcurve  = [];
  state.timeStarting  = window.performance.now();
  state.lastFrameTime = state.timeStarting;
  state.needsDraw     = true;

  buildPlanetList();
  syncSpeedUi();
  setRunningQuiet(!prefersReducedMotion());
  render(0);
  announce('Simulation reset. No planets are selected, elapsed time 0.0 years, ' +
           'animation speed ' + state.daysPerSecond + ' days per second.');
}

function setRunningQuiet(running) {
  state.running = running;
  if (running) {
    state.timeStarting  = window.performance.now();
    state.lastFrameTime = state.timeStarting;
  }
  el.pauseButton.textContent = running ? 'Pause' : 'Resume';
  el.pauseButton.setAttribute('aria-label',
    running ? 'Pause the animation' : 'Resume the animation');
}

function prefersReducedMotion() {
  return !!(window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches);
}

/* While the masthead's Help / About dialog is open the page behind it is
   inert, so the user cannot pause or reset -- but the animation would keep
   running and burn simulated years while they read.  Suspend it for as long
   as the dialog is showing and pick up exactly where it left off.

   This only READS the component's open shadow root (watching the <dialog>'s
   "open" attribute); kl-unl-masthead.js itself is not modified.  The shadow
   root exists from the constructor but is filled in after the component's
   fetch resolves, so the observer watches for that too. */
function watchMastheadDialog() {
  const masthead = document.querySelector('kl-unl-masthead');
  if (!masthead || !masthead.shadowRoot || !window.MutationObserver) { return; }

  let suspended = false;

  function check() {
    const dialog = masthead.shadowRoot.querySelector('dialog');
    const isOpen = !!(dialog && dialog.open);

    if (isOpen && !suspended && state.running) {
      suspended = true;
      setRunningQuiet(false);
    } else if (!isOpen && suspended) {
      suspended = false;
      setRunningQuiet(true);     // also resyncs the clock, so no jump
    }
  }

  new window.MutationObserver(check).observe(masthead.shadowRoot, {
    childList:      true,
    subtree:        true,
    attributes:     true,
    attributeFilter: ['open']
  });
}

/* kl-unl.js calls klunlInitEqn() so a simulation can set up its equations.
   This one displays no equations -- the original has none -- so it is a
   deliberate no-op that supersedes the foundation's default. */
window.klunlInitEqn = function () {};

/* ---------------------------------------------------------------------
   13. Start-up
   --------------------------------------------------------------------- */
function cacheElements() {
  ['stage', 'yearsValue', 'yearsSr', 'stageDesc', 'speedField', 'speedSlider',
   'pauseButton', 'planetList', 'srStatus'].forEach(function (id) {
    el[id] = document.getElementById(id);
  });
}

function init() {
  cacheElements();

  ctx = el.stage.getContext('2d');
  el.stage.setAttribute('aria-label',
    'Diagram of the Sun moving around the center of mass of the solar system');
  sizeCanvas();
  loadArt();

  buildPlanetList();
  syncSpeedUi();

  // Pointer Events give mouse and touch a single path; the native range
  // input supplies full keyboard operation (arrows, Page Up/Down, Home/End).
  el.speedSlider.addEventListener('input',  onSpeedSliderInput);
  el.speedSlider.addEventListener('change', onSpeedSliderCommit);

  el.speedField.addEventListener('input', onSpeedFieldInput);
  el.speedField.addEventListener('blur',  commitSpeedField);
  el.speedField.addEventListener('keydown', function (event) {
    if (event.key === 'Enter') {
      event.preventDefault();
      commitSpeedField();
    }
  });

  el.pauseButton.addEventListener('click', function () { setRunning(!state.running); });

  // The masthead dispatches a bubbling, composed "sim-reset" CustomEvent.
  document.addEventListener('sim-reset', resetAll);

  watchMastheadDialog();

  window.addEventListener('resize', sizeCanvas);

  // No motion without a stop: honour prefers-reduced-motion by starting
  // paused; the Resume button is the equivalent opt-in.
  setRunningQuiet(!prefersReducedMotion());

  state.timeStarting  = window.performance.now();
  state.lastFrameTime = state.timeStarting;

  render(0);
  window.requestAnimationFrame(frame);
}

if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', init);
} else {
  init();
}
