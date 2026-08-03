// ===========================================================================
// Planet Formation Temperatures Plot -- HTML5 port of formationTemps002.swf
// (Adobe Flash / ActionScript 1, 31 August 2009)
//
// Everything below the "STATE" banner is a direct translation of the
// decompiled ActionScript: graph.as (graphClass), layout.as (layoutClass),
// "Slider Logic Class v6.as" (SliderLogicClassV6) and the on(initialize)
// blocks that supplied their parameters. Constants and formulas are verbatim.
//
// The original stage coordinate system is preserved: all plotting math is done
// in "graph" coordinates (the coordinate space of the Flash "graph" symbol) and
// the canvas is scaled by CSS. Text never goes on the canvas -- it lives in the
// HTML layers so it zooms with the page and is typeset by MathJax.
// ===========================================================================

'use strict';

// ---------------------------------------------------------------------------
// CONSTANTS -- verbatim from the ActionScript source
// ---------------------------------------------------------------------------

// graphClass(): the tick sprites whose positions anchor the two log axes.
// twoThous._y = 0, twenty._y = 300, pointOne._x = 0, fifty._x = 350 (pixels).
const GRAPH = {
  t_pixel_high: 0,     // y of the 2000 K tick
  t_pixel_low:  300,   // y of the   20 K tick
  t_high:       2000,
  t_low:        20,
  d_pixel_high: 350,   // x of the 50   AU tick
  d_pixel_low:  0,     // x of the  0.1 AU tick
  d_high:       50,
  d_low:        0.1,
  earth_t:      600,
  earth_d:      1,
  jupiter_t:    175,
  jupiter_d:    5.203
};

// Planet distances (AU) and the on-screen symbol sizes passed to place().
// bbox is the exported shape's bounding box, which the bitmap fills exactly;
// w/h are the rad1/rad2 arguments of graphClass.place().
const PLANETS = [
  { id: 'mercury', name: 'Mercury', file: 'mercury.png', d: 0.387,
    w: 10, h: 10, bbox: { xmin: -28.5, ymin: -29.0,  width: 57, height: 58 }, offset: 10 },
  { id: 'venus',   name: 'Venus',   file: 'venus.png',   d: 0.723,
    w: 15, h: 15, bbox: { xmin: -44.5, ymin: -43.0,  width: 89, height: 86 }, offset: 15 },
  { id: 'earth',   name: 'Earth',   file: 'earth.png',   d: 1,
    w: 15, h: 15, bbox: { xmin: -43.5, ymin: -46.0,  width: 87, height: 92 }, offset: 15 },
  { id: 'mars',    name: 'Mars',    file: 'mars.png',    d: 1.524,
    w: 10, h: 10, bbox: { xmin: -43.5, ymin: -43.5,  width: 87, height: 87 }, offset: 10 },
  { id: 'jupiter', name: 'Jupiter', file: 'jupiter.png', d: 5.203,
    w: 25, h: 25, bbox: { xmin: -46.5, ymin: -46.0,  width: 93, height: 92 }, offset: 20 },
  { id: 'saturn',  name: 'Saturn',  file: 'saturn.png',  d: 9.529,
    w: 30, h: 41, bbox: { xmin: -34.5, ymin: -47.5,  width: 69, height: 95 }, offset: 20 },
  { id: 'uranus',  name: 'Uranus',  file: 'uranus.png',  d: 19.19,
    w: 20, h: 20, bbox: { xmin: -46.0, ymin: -45.5,  width: 92, height: 91 }, offset: 15 },
  { id: 'neptune', name: 'Neptune', file: 'neptune.png', d: 30.06,
    w: 20, h: 20, bbox: { xmin: -43.0, ymin: -43.0,  width: 86, height: 88 }, offset: 20 },
  { id: 'pluto',   name: 'Pluto',   file: 'pluto.png',   d: 39.53,
    w: 8,  h: 8,  bbox: { xmin:  -7.0, ymin:  -7.0,  width: 14, height: 14 }, offset: 10 }
];

// The marker circle: exported shape 33 x 33 px, placed at 40 x 40 px.
const MARKER = { w: 40, h: 40, bbox: { xmin: -16.5, ymin: -16.5, width: 33, height: 33 } };

// The axis artwork and the four named tick sprites, at their original offsets.
const AXES  = { x: -16.5, y: -11.5, width: 408.1, height: 378 };
const TICKS = [
  // "pointOne" -- the long tick under 0.1 AU (placed with _yscale 148.5%)
  { src: 'tick-vertical',   x: 0,   y: 357.5,  w: 3,  h: 13.1 * 1.4851532 },
  // "fifty" -- the tick under 50 AU
  { src: 'tick-vertical',   x: 350, y: 355.05, w: 3,  h: 13.1 },
  // "twoThous" and "twenty" -- the ticks beside 2000 K and 20 K
  { src: 'tick-horizontal', x: -5,  y: 0,      w: 13, h: 3 },
  { src: 'tick-horizontal', x: -5,  y: 300,    w: 13, h: 3 }
];
const TICK_BBOX = {
  'tick-vertical':   { xmin: -1.5, ymin: -6.55, height: 13.1 },
  'tick-horizontal': { xmin: -6.5, ymin: -1.5,  height: 3    }
};

// "Standard Slider v6" on(initialize) parameters.
const SLIDER = {
  minValue:  35,
  maxValue:  1520,
  initValue: 600,
  precision: 0            // "fixed digits", 0 -> values are whole kelvins
};
const MIN_INCREMENT = Math.pow(10, -SLIDER.precision);   // 1 K

// layoutClass(): the condensation panel. pixel_high / pixel_low are the vertical
// centres of the "Metal Oxides" and "Argon - Neon" labels in the original
// layout symbol; the panel box itself spans y = 26 to y = 466.
const OVERLAY = {
  pixel_high: 38.1786,
  pixel_low:  458.5047,
  temp_high:  1500,
  temp_low:   65,
  box_top:    26,
  box_height: 440
};

// Substance labels, verbatim from the original, with their condensation
// temperatures and a spelled-out name for speech.
const SUBSTANCES = [
  { temp: 1500, speech: 'metal oxides'      },
  { temp: 1300, speech: 'metallic iron-nickel' },
  { temp: 1200, speech: 'silicates'         },
  { temp: 1000, speech: 'feldspars'         },
  { temp:  680, speech: 'troilite'             },
  { temp:  175, speech: 'water'             },
  { temp:  150, speech: 'ammonia'           },
  { temp:  120, speech: 'methane'           },
  { temp:   65, speech: 'argon and neon'    }
];

// The canvas viewport, expressed in graph coordinates. It is wider and taller
// than the axes so that the HTML label layer, which shares this box, has room
// for the tick values and the axis titles.
// Keep styles/styles.css in step: .ft-stage__canvas has aspect-ratio 495 / 440.
const VIEW = { x0: -95, y0: -20, w: 495, h: 440 };

// Rail geometry inside the condensation panel, in CSS pixels from its left
// edge: the tick segment, then the leader, then the label column.
const RAIL = { tickLeft: 22, tickRight: 34, labelLeft: 52 };

// ---------------------------------------------------------------------------
// PHYSICS AND GEOMETRY -- verbatim ports of the graphClass methods
// ---------------------------------------------------------------------------

// AS1 had no Math.log10; the source divides by this literal.
function logBaseTen(num) {
  return Math.log(num) / 2.302585092994046;
}

// Horizontal position of a distance on the logarithmic distance axis.
function findX(d) {
  const high     = GRAPH.d_pixel_high;
  const low      = GRAPH.d_pixel_low;
  const log10Hi  = logBaseTen(GRAPH.d_high);
  const log10Low = logBaseTen(GRAPH.d_low);
  return (high - low) / (log10Hi - log10Low) * (logBaseTen(d) - log10Hi) + high;
}

// Vertical position of a temperature on the logarithmic temperature axis.
function findY(k) {
  const high     = GRAPH.t_pixel_high;
  const low      = GRAPH.t_pixel_low;
  const log10Hi  = logBaseTen(GRAPH.t_high);
  const log10Low = logBaseTen(GRAPH.t_low);
  return (high - low) / (log10Hi - log10Low) * (logBaseTen(k) - log10Hi) + high;
}

// The disk temperature profile. It is a power law in distance, fixed by the two
// anchor planets: T = 600 K at 1 AU (Earth) and T = 175 K at 5.203 AU (Jupiter).
//     log10(T) = m * ( log10(d) - log10(d_earth) ) + log10(T_earth)
function findTemp(d) {
  const m = (logBaseTen(GRAPH.earth_t) - logBaseTen(GRAPH.jupiter_t)) /
            (logBaseTen(GRAPH.earth_d) - logBaseTen(GRAPH.jupiter_d));
  const logT = m * (logBaseTen(d) - logBaseTen(GRAPH.earth_d)) + logBaseTen(GRAPH.earth_t);
  return Math.pow(10, logT);
}

// The same power law solved for distance.
function findDist(k) {
  const m = (logBaseTen(GRAPH.earth_t) - logBaseTen(GRAPH.jupiter_t)) /
            (logBaseTen(GRAPH.earth_d) - logBaseTen(GRAPH.jupiter_d));
  const logD = (logBaseTen(k) - logBaseTen(GRAPH.earth_t)) / m + logBaseTen(GRAPH.earth_d);
  return Math.pow(10, logD);
}

// layoutClass.findOverlayY(): the solid / gas boundary is LINEAR in temperature
// between the 1500 K and 65 K label positions.
function findOverlayY(k) {
  return (OVERLAY.pixel_high - OVERLAY.pixel_low) / (OVERLAY.temp_high - OVERLAY.temp_low) *
         (k - OVERLAY.temp_high) + OVERLAY.pixel_high;
}

// findOverlayY expressed as a fraction of the condensation panel's height.
function bandFraction(k) {
  return (findOverlayY(k) - OVERLAY.box_top) / OVERLAY.box_height;
}

// ---------------------------------------------------------------------------
// SLIDER LOGIC -- verbatim port of SliderLogicClassV6 in logarithmic /
// "fixed digits" mode, over a 0..1000 parameter range instead of pixels.
// ---------------------------------------------------------------------------

const PARAM_MIN = 0;
const PARAM_MAX = 1000;
const LOG_MIN_V = Math.log(SLIDER.minValue);
const PARAM_SCALE = (Math.log(SLIDER.maxValue) - LOG_MIN_V) / (PARAM_MAX - PARAM_MIN);

// getValueObjectFromValue(): clamp, then snap to the nearest whole increment.
function snapValue(x) {
  let v = x;
  if (v < SLIDER.minValue)      { v = SLIDER.minValue; }
  else if (v > SLIDER.maxValue) { v = SLIDER.maxValue; }
  return MIN_INCREMENT * Math.round(v / MIN_INCREMENT);
}

function valueFromParameter(p) {
  return Math.exp((p - PARAM_MIN) * PARAM_SCALE + LOG_MIN_V);
}

function parameterFromValue(v) {
  return PARAM_MIN + (Math.log(v) - LOG_MIN_V) / PARAM_SCALE;
}

// getIncrementedValueObject(): n ticks of one whole increment each, then clamp.
function incrementValue(v, ticks) {
  return snapValue(MIN_INCREMENT * Math.round(ticks + v / MIN_INCREMENT));
}

// ---------------------------------------------------------------------------
// STATE -- one plain object; render() redraws everything from it
// ---------------------------------------------------------------------------

const state = {
  currTemp:     SLIDER.initValue,   // layoutClass._currTemp
  markerAlpha:  100,                // circle_mc._alpha (100 until first roll-out)
  readoutFor:   null                // id of the object whose readout is showing
};

const dom = {};
const images = {};
let labelLayout = [];               // resolved substance label positions
let mathQueue = new Set();          // elements awaiting MathJax typesetting
let renderPending = false;

// ---------------------------------------------------------------------------
// FORMATTING -- matches the original readout strings
// ---------------------------------------------------------------------------

// The original prints the marker distance as Math.round(100 * d) / 100.
function roundHundredths(d) {
  return Math.round(100 * d) / 100;
}

function tex(value, unit) {
  return '\\(' + value + '\\ \\mathrm{' + unit + '}\\)';
}

function speakTemp(k) {
  return k + ' kelvin';
}

function speakDist(d) {
  return d + (d === 1 ? ' astronomical unit' : ' astronomical units');
}

// ---------------------------------------------------------------------------
// MATHJAX HELPERS
// ---------------------------------------------------------------------------

// Set a node's LaTeX only when it actually changed, then queue one typeset pass.
function setMath(el, latex) {
  if (!el || el.dataset.latex === latex) { return; }
  el.dataset.latex = latex;
  el.innerHTML = latex;
  mathQueue.add(el);
}

function flushMath() {
  if (!mathQueue.size) { return; }
  const nodes = Array.from(mathQueue);
  mathQueue.clear();
  if (window.MathJax && MathJax.typesetPromise) {
    MathJax.typesetPromise(nodes)
      .then(() => {
        nodes.forEach(untabMath);
        // Typesetting changes the readout's measured size, so re-place it. This
        // settles after one pass: unchanged LaTeX queues nothing.
        scheduleRender();
      })
      .catch((err) => console.error(err));
  }
}

// Typeset mathematics is display-only: keep it out of the Tab order (WCAG 2.4.3)
// without hiding it, so the MathJax context menu still works on right-click.
function untabMath(root) {
  const scope = root || document;
  scope.querySelectorAll('mjx-container').forEach((c) => {
    c.setAttribute('tabindex', '-1');
    const svg = c.querySelector('svg');
    if (svg) { svg.setAttribute('tabindex', '-1'); svg.setAttribute('focusable', 'false'); }
  });
}

// ---------------------------------------------------------------------------
// CANVAS -- reused exported artwork plus the one code-drawn element (the line)
// ---------------------------------------------------------------------------

function loadImage(name, src) {
  return new Promise((resolve) => {
    const img = new Image();
    img.onload  = () => { images[name] = img; resolve(); };
    img.onerror = () => { console.error('Could not load ' + src); resolve(); };
    img.src = src;
  });
}

function loadArtwork() {
  const jobs = [
    loadImage('axes',            'assets/plot-axes.svg'),
    loadImage('marker',          'assets/marker-circle.svg'),
    loadImage('tick-vertical',   'assets/tick-vertical.svg'),
    loadImage('tick-horizontal', 'assets/tick-horizontal.svg')
  ];
  PLANETS.forEach((p) => jobs.push(loadImage(p.id, 'assets/planets/' + p.file)));
  return Promise.all(jobs);
}

// Reproduce Flash's _x / _y / _width / _height on a symbol whose artwork fills
// its bounding box: the box is scaled about the registration point (0, 0).
function drawSymbol(ctx, img, bbox, cx, cy, w, h) {
  if (!img) { return; }
  const sx = w / bbox.width;
  const sy = h / bbox.height;
  ctx.drawImage(img, cx + bbox.xmin * sx, cy + bbox.ymin * sy, w, h);
}

function sizeCanvas() {
  const canvas = dom.canvas;
  const rect   = canvas.getBoundingClientRect();
  const dpr    = window.devicePixelRatio || 1;
  const cssW   = rect.width  || VIEW.w;
  const cssH   = rect.height || VIEW.h;
  const needW  = Math.max(1, Math.round(cssW * dpr));
  const needH  = Math.max(1, Math.round(cssH * dpr));
  if (canvas.width !== needW || canvas.height !== needH) {
    canvas.width  = needW;
    canvas.height = needH;
  }
  return { scale: needW / VIEW.w };
}

function drawPlot() {
  const ctx = dom.canvas.getContext('2d');
  const { scale } = sizeCanvas();

  ctx.setTransform(1, 0, 0, 1, 0, 0);
  ctx.clearRect(0, 0, dom.canvas.width, dom.canvas.height);
  // Work in graph coordinates from here on.
  ctx.setTransform(scale, 0, 0, scale, -VIEW.x0 * scale, -VIEW.y0 * scale);

  // Axis artwork and the four named tick sprites (exported vector art, as-is).
  if (images.axes) { ctx.drawImage(images.axes, AXES.x, AXES.y, AXES.width, AXES.height); }
  TICKS.forEach((t) => {
    const img  = images[t.src];
    const bbox = TICK_BBOX[t.src];
    if (!img) { return; }
    const sy = t.h / bbox.height;   // the "pointOne" tick is placed at _yscale 148.5%
    ctx.drawImage(img, t.x + bbox.xmin, t.y + bbox.ymin * sy, t.w, t.h);
  });

  // The trend line -- the only art the ActionScript draws at run time:
  //   myLine.lineStyle(3, 0x000000, 70) from 0.2 AU to 65 AU
  ctx.save();
  ctx.lineWidth   = 3;
  ctx.strokeStyle = '#000000';
  ctx.globalAlpha = 0.7;
  ctx.lineCap     = 'round';
  ctx.beginPath();
  ctx.moveTo(findX(0.2), findY(findTemp(0.2)));
  ctx.lineTo(findX(65),  findY(findTemp(65)));
  ctx.stroke();
  ctx.restore();

  // The nine planet bitmaps, in the original attach order (depths 2 .. 10).
  PLANETS.forEach((p) => {
    const t = (p.id === 'earth')   ? GRAPH.earth_t
            : (p.id === 'jupiter') ? GRAPH.jupiter_t
            : findTemp(p.d);
    drawSymbol(ctx, images[p.id], p.bbox, findX(p.d), findY(t), p.w, p.h);
  });

  // The marker circle (depth 11), on top of the planets.
  ctx.save();
  ctx.globalAlpha = state.markerAlpha / 100;
  drawSymbol(ctx, images.marker, MARKER.bbox,
             findX(findDist(state.currTemp)), findY(state.currTemp), MARKER.w, MARKER.h);
  ctx.restore();

  ctx.setTransform(1, 0, 0, 1, 0, 0);
}

// ---------------------------------------------------------------------------
// HTML LAYERS OVER THE PLOT
// ---------------------------------------------------------------------------

// Graph coordinates -> percentage position inside the stage box.
function stageLeft(gx) { return ((gx - VIEW.x0) / VIEW.w) * 100; }
function stageTop(gy)  { return ((gy - VIEW.y0) / VIEW.h) * 100; }

function placePlotLabels() {
  document.querySelectorAll('.ft-tick--y').forEach((el) => {
    const t = Number(el.dataset.temp);
    el.style.left = stageLeft(-16) + '%';
    el.style.top  = stageTop(findY(t)) + '%';
  });
  document.querySelectorAll('.ft-tick--x').forEach((el) => {
    const d = Number(el.dataset.dist);
    el.style.left = stageLeft(findX(d)) + '%';
    el.style.top  = stageTop(374) + '%';
  });
  dom.axisTitleY.style.left = stageLeft(-76) + '%';
  dom.axisTitleY.style.top  = stageTop(175) + '%';
  dom.axisTitleX.style.left = stageLeft(195) + '%';
  dom.axisTitleX.style.top  = stageTop(404) + '%';
}

// One focusable button per plotted object. They give the original roll-over
// readouts a keyboard and touch path, and carry the values in their names.
function buildHitTargets() {
  const frag = document.createDocumentFragment();

  PLANETS.forEach((p) => {
    const t = Math.round(findTemp(p.d));
    frag.appendChild(makeHit(p.id,
      p.name + ', ' + speakDist(p.d) + ' from the Sun, formation temperature ' + speakTemp(t)));
  });

  // The marker's name carries the current temperature, so render() rewrites it.
  const marker = makeHit('marker', '');
  frag.appendChild(marker);

  dom.hits.innerHTML = '';
  dom.hits.appendChild(frag);
  dom.markerHit = marker;
}

function makeHit(id, label) {
  const btn = document.createElement('button');
  btn.type = 'button';
  btn.className = 'ft-hit';
  btn.id = 'hit-' + id;
  btn.setAttribute('aria-label', label);
  btn.addEventListener('pointerenter', () => showReadout(id));
  btn.addEventListener('pointerleave', () => hideReadout(id));
  btn.addEventListener('focus',        () => showReadout(id));
  btn.addEventListener('blur',         () => hideReadout(id));
  btn.addEventListener('click',        () => { btn.focus(); showReadout(id); });
  return btn;
}

// Hit areas track the symbol they cover, but never shrink below 16 graph units
// (about 24 CSS pixels at the default desktop size) so they stay tappable.
function placeHitTargets() {
  const minSize = 16;
  PLANETS.forEach((p) => {
    const t = (p.id === 'earth')   ? GRAPH.earth_t
            : (p.id === 'jupiter') ? GRAPH.jupiter_t
            : findTemp(p.d);
    positionHit(document.getElementById('hit-' + p.id),
                findX(p.d), findY(t),
                Math.max(p.w, minSize), Math.max(p.h, minSize));
  });
  positionHit(dom.markerHit,
              findX(findDist(state.currTemp)), findY(state.currTemp),
              MARKER.w, MARKER.h);
}

function positionHit(btn, gx, gy, w, h) {
  if (!btn) { return; }
  btn.style.left   = stageLeft(gx - w / 2) + '%';
  btn.style.top    = stageTop(gy - h / 2)  + '%';
  btn.style.width  = (w / VIEW.w * 100) + '%';
  btn.style.height = (h / VIEW.h * 100) + '%';
}

function showReadout(id) {
  state.readoutFor = id;
  if (id === 'marker') { state.markerAlpha = 100; }
  scheduleRender();
}

function hideReadout(id) {
  if (state.readoutFor !== id) { return; }
  state.readoutFor = null;
  if (id === 'marker') { state.markerAlpha = 80; }
  scheduleRender();
}

function renderReadout() {
  const id = state.readoutFor;
  if (!id) { dom.readout.hidden = true; return; }

  let gx, gy, offset, tempText, distText;

  if (id === 'marker') {
    // circle_mc.onRollOver: temp is the slider value, distance is rounded to
    // hundredths -- both exactly as the original prints them.
    gx = findX(findDist(state.currTemp));
    gy = findY(state.currTemp);
    offset   = 20;
    tempText = tex(state.currTemp, 'K');
    distText = tex(roundHundredths(findDist(state.currTemp)), 'AU');
  } else {
    const p = PLANETS.find((q) => q.id === id);
    const t = (p.id === 'earth')   ? GRAPH.earth_t
            : (p.id === 'jupiter') ? GRAPH.jupiter_t
            : findTemp(p.d);
    gx = findX(p.d);
    gy = findY(t);
    offset   = p.offset;
    tempText = tex(Math.round(findTemp(p.d)), 'K');
    distText = tex(p.d, 'AU');
  }

  // readout_mc._x = object._x + offset; readout_mc._y = object._y, with the
  // readout artwork rising from that anchor. The box is sized by its content
  // here, rather than to the original 81 x 47.8 px, so the text stays legible at
  // any zoom level.
  dom.readout.hidden = false;
  setMath(dom.readoutTemp, tempText);
  setMath(dom.readoutDist, distText);

  const stageW = dom.stage.clientWidth  || VIEW.w;
  const stageH = dom.stage.clientHeight || VIEW.h;
  let left = (gx + offset - VIEW.x0) / VIEW.w * stageW;
  let top  = (gy + 1.5  - VIEW.y0) / VIEW.h * stageH;

  dom.readout.style.left = left + 'px';
  dom.readout.style.top  = top  + 'px';

  // Objects near an edge of the plot would push the box outside it, so nudge it
  // back in. The original let it run off the graph.
  const box = dom.readout.getBoundingClientRect();
  if (box.width && box.height) {
    left = Math.max(0, Math.min(left, stageW - box.width));
    top  = Math.max(box.height, Math.min(top, stageH));
    dom.readout.style.left = left + 'px';
    dom.readout.style.top  = top  + 'px';
  }
}

// ---------------------------------------------------------------------------
// CONDENSATION PANEL
// ---------------------------------------------------------------------------

// Substance labels sit at their exact condensation temperature wherever there is
// room. Where the bottom of the scale crowds them together they are nudged
// apart by the minimum readable spacing, and a leader joins each label back to
// its tick, which always stays on the true temperature.
function resolveLabelPositions() {
  const bandHeight = dom.band.clientHeight || 1;
  const sample     = dom.substances[0];
  const lineHeight = (sample ? sample.offsetHeight : 16) || 16;
  const gap        = (lineHeight + 3) / bandHeight;
  const half       = lineHeight / 2 / bandHeight;

  const positions = SUBSTANCES.map((s) => bandFraction(s.temp));

  // Push down, then pull back up off the bottom edge, then settle.
  for (let pass = 0; pass < 3; pass++) {
    for (let i = 1; i < positions.length; i++) {
      positions[i] = Math.max(positions[i], positions[i - 1] + gap);
    }
    positions[positions.length - 1] = Math.min(positions[positions.length - 1], 1 - half);
    for (let i = positions.length - 2; i >= 0; i--) {
      positions[i] = Math.min(positions[i], positions[i + 1] - gap);
    }
    positions[0] = Math.max(positions[0], half);
  }

  labelLayout = SUBSTANCES.map((s, i) => ({
    trueY:  bandFraction(s.temp),   // where the tick goes: the exact temperature
    labelY: positions[i]            // where the label goes: nudged clear if crowded
  }));
}

function placeSubstanceLabels() {
  resolveLabelPositions();

  // The leader artwork lives in a 0..100 viewBox stretched to the panel, so the
  // rail's pixel offsets convert to percentages of the current panel width.
  const bandWidth = dom.band.clientWidth || 1;
  const x0 = RAIL.tickLeft   / bandWidth * 100;
  const x1 = RAIL.tickRight  / bandWidth * 100;
  const x2 = (RAIL.labelLeft - 4) / bandWidth * 100;

  const leaders = [];
  labelLayout.forEach((item, i) => {
    const el = dom.substances[i];
    el.style.top  = (item.labelY * 100) + '%';
    el.style.left = RAIL.labelLeft + 'px';

    leaders.push('<polyline points="' +
      x0 + ',' + (item.trueY * 100) + ' ' +
      x1 + ',' + (item.trueY * 100) + ' ' +
      x2 + ',' + (item.labelY * 100) + '"></polyline>');
  });
  dom.bandLeaders.innerHTML = leaders.join('');
}

function renderBand() {
  const boundary = Math.min(1, Math.max(0, bandFraction(state.currTemp)));
  const pct = boundary * 100;

  dom.bandSolid.style.height = pct + '%';
  dom.bandGas.style.top      = pct + '%';
  dom.bandGas.style.height   = (100 - pct) + '%';
  dom.bandDivider.style.top  = pct + '%';

  // Keep the two rotated region labels inside their own region.
  dom.sideSolid.style.top = (pct / 2) + '%';
  dom.sideGas.style.top   = (pct + (100 - pct) / 2) + '%';
  dom.sideSolid.style.visibility = boundary > 0.12 ? 'visible' : 'hidden';
  dom.sideGas.style.visibility   = boundary < 0.88 ? 'visible' : 'hidden';
}

function solidSubstances() {
  return SUBSTANCES.filter((s) => s.temp >= state.currTemp);
}

// ---------------------------------------------------------------------------
// RENDER -- the single place that pushes state into the page
// ---------------------------------------------------------------------------

function scheduleRender() {
  if (renderPending) { return; }
  renderPending = true;
  requestAnimationFrame(() => { renderPending = false; render(); });
}

function render() {
  drawPlot();
  placeHitTargets();
  renderBand();
  renderReadout();

  const dist = roundHundredths(findDist(state.currTemp));

  // Controls stay in step with each other and with the state object.
  if (document.activeElement !== dom.number) { dom.number.value = String(state.currTemp); }
  dom.slider.value = String(Math.round(parameterFromValue(state.currTemp)));
  dom.slider.setAttribute('aria-valuetext', 'Temperature ' + speakTemp(state.currTemp));

  setMath(dom.currentDist, tex(dist, 'AU'));
  dom.currentDistSr.textContent = 'Distance from the Sun ' + speakDist(dist);

  // The marker readout is the one that follows the temperature.
  dom.markerHit.setAttribute('aria-label',
    'Formation temperature marker, ' + speakTemp(state.currTemp) + ', ' +
    speakDist(dist) + ' from the Sun');

  const solid = solidSubstances();
  dom.plotDesc.textContent =
    'Log-log plot of formation temperature against distance from the Sun. A straight ' +
    'trend line falls from about 2000 kelvin at 0.2 astronomical units to about 27 kelvin ' +
    'at 65 astronomical units. The nine planets sit on the line: ' +
    PLANETS.map((p) => p.name + ' at ' + speakDist(p.d) + ' and ' +
                speakTemp(Math.round(findTemp(p.d)))).join('; ') + '. ' +
    'A red circle marks the current setting of ' + speakTemp(state.currTemp) +
    ' at ' + speakDist(dist) + '.';

  dom.statesDesc.textContent =
    'Condensation temperatures. At ' + speakTemp(state.currTemp) + ' the solid region holds ' +
    (solid.length ? solid.map((s) => s.speech).join(', ') : 'nothing') + '. The gas region holds ' +
    (solid.length < SUBSTANCES.length
       ? SUBSTANCES.slice(solid.length).map((s) => s.speech).join(', ')
       : 'nothing') + '.';

  flushMath();
}

// Announce only once a change has settled, so dragging does not flood speech.
let announceTimer = null;
function announce() {
  window.clearTimeout(announceTimer);
  announceTimer = window.setTimeout(() => {
    const solid = solidSubstances();
    const dist  = roundHundredths(findDist(state.currTemp));
    dom.status.textContent =
      'Temperature ' + speakTemp(state.currTemp) + '. Distance from the Sun ' +
      speakDist(dist) + '. ' + solid.length + ' of ' + SUBSTANCES.length +
      ' substances are solid: ' +
      (solid.length ? solid.map((s) => s.speech).join(', ') : 'none') + '.';
  }, 350);
}

// ---------------------------------------------------------------------------
// INPUT -- both paths write the same state, exactly as layoutClass.update() did
// ---------------------------------------------------------------------------

function setTemperature(k) {
  const next = snapValue(k);
  if (next === state.currTemp) { return; }
  state.currTemp = next;
  scheduleRender();
  announce();
}

function nudgeTemperature(ticks) {
  setTemperature(incrementValue(state.currTemp, ticks));
}

function wireSlider() {
  const slider = dom.slider;

  slider.addEventListener('input', () => {
    setTemperature(valueFromParameter(Number(slider.value)));
  });

  // The original slider stepped by one whole kelvin per arrow key. Page Up /
  // Page Down and Home / End are added here for keyboard usability.
  slider.addEventListener('keydown', (e) => {
    let ticks = 0;
    switch (e.key) {
      case 'ArrowLeft':  case 'ArrowDown':  ticks = -1;  break;
      case 'ArrowRight': case 'ArrowUp':    ticks =  1;  break;
      case 'PageDown':   ticks = -50; break;
      case 'PageUp':     ticks =  50; break;
      case 'Home': e.preventDefault(); setTemperature(SLIDER.minValue); return;
      case 'End':  e.preventDefault(); setTemperature(SLIDER.maxValue); return;
      default: return;
    }
    e.preventDefault();
    nudgeTemperature(ticks);
  });

  slider.addEventListener('wheel', (e) => {
    if (document.activeElement !== slider) { return; }
    e.preventDefault();
    nudgeTemperature(e.deltaY < 0 ? 1 : -1);
  }, { passive: false });
}

function wireNumberField() {
  const field = dom.number;

  // The original committed on Enter and on losing focus, clamping the result.
  const commit = () => {
    const parsed = parseFloat(field.value);
    if (isFinite(parsed)) { setTemperature(parsed); }
    field.value = String(state.currTemp);
    scheduleRender();
  };

  field.addEventListener('change', commit);
  field.addEventListener('blur',   commit);
  // Up / Down arrows and the spinner come free with <input type="number">;
  // Page Up / Page Down and Home / End are added for keyboard usability.
  field.addEventListener('keydown', (e) => {
    switch (e.key) {
      case 'Enter':    e.preventDefault(); commit(); break;
      case 'PageUp':   e.preventDefault(); nudgeTemperature(50);  break;
      case 'PageDown': e.preventDefault(); nudgeTemperature(-50); break;
      case 'Home':     e.preventDefault(); setTemperature(SLIDER.minValue); break;
      case 'End':      e.preventDefault(); setTemperature(SLIDER.maxValue); break;
      default: break;
    }
  });
  field.addEventListener('wheel', (e) => {
    if (document.activeElement !== field) { return; }
    e.preventDefault();
    nudgeTemperature(e.deltaY < 0 ? 1 : -1);
  }, { passive: false });
}

function reset() {
  state.currTemp    = SLIDER.initValue;
  state.markerAlpha = 100;
  state.readoutFor  = null;
  dom.number.value  = String(SLIDER.initValue);
  scheduleRender();
  announce();
}

// ---------------------------------------------------------------------------
// START-UP
// ---------------------------------------------------------------------------

function cacheDom() {
  dom.canvas         = document.getElementById('plot-canvas');
  dom.stage          = document.getElementById('plot-stage');
  dom.hits           = document.getElementById('plot-hits');
  dom.readout        = document.getElementById('plot-readout');
  dom.readoutTemp    = document.getElementById('readout-temp');
  dom.readoutDist    = document.getElementById('readout-dist');
  dom.axisTitleX     = document.getElementById('axis-title-x');
  dom.axisTitleY     = document.getElementById('axis-title-y');
  dom.band           = document.getElementById('state-band');
  dom.bandSolid      = document.getElementById('band-solid');
  dom.bandGas        = document.getElementById('band-gas');
  dom.bandDivider    = document.getElementById('band-divider');
  dom.bandLeaders    = document.getElementById('band-leaders');
  dom.sideSolid      = document.getElementById('side-solid');
  dom.sideGas        = document.getElementById('side-gas');
  dom.substances     = Array.from(document.querySelectorAll('.ft-substance'));
  dom.slider         = document.getElementById('temp-slider');
  dom.number         = document.getElementById('temp-number');
  dom.currentDist    = document.getElementById('current-dist');
  dom.currentDistSr  = document.getElementById('current-dist-sr');
  dom.plotDesc       = document.getElementById('plot-desc');
  dom.statesDesc     = document.getElementById('states-desc');
  dom.status         = document.getElementById('sr-status');
}

// Redefines the foundation's placeholder hook (kl-unl.js) so this sim owns the
// MathJax-dependent part of its set-up, exactly as that file intends. The tick
// values, axis unit, substance labels and readouts are all written as inline
// LaTeX, so MathJax's own start-up pass typesets them; this hook then takes
// that output out of the Tab order and lays the labels out at their final size.
window.klunlInitEqn = function () {
  untabMath();
  placeSubstanceLabels();
  scheduleRender();
};

function boot() {
  cacheDom();
  buildHitTargets();
  placePlotLabels();
  wireSlider();
  wireNumberField();

  // The visible label reads "Temperature"; the accessible name adds the unit so
  // that screen readers never announce a bare number.
  dom.number.setAttribute('aria-label', 'Temperature in kelvin');

  // The masthead dispatches a bubbling, composed "sim-reset" event.
  document.addEventListener('sim-reset', reset);

  let resizeTimer = null;
  const relayout = () => {
    window.clearTimeout(resizeTimer);
    resizeTimer = window.setTimeout(() => { placeSubstanceLabels(); scheduleRender(); }, 100);
  };
  window.addEventListener('resize', relayout);

  // The condensation panel grows to match the plot panel's height, so its label
  // spacing has to be recomputed whenever that height settles -- not just when
  // the window is resized.
  if (window.ResizeObserver) {
    new ResizeObserver(relayout).observe(dom.band);
  }

  loadArtwork().then(() => { placeSubstanceLabels(); render(); });

  if (window.MathJax && MathJax.startup && MathJax.startup.promise) {
    MathJax.startup.promise.then(() => window.klunlInitEqn());
  } else {
    window.setTimeout(() => window.klunlInitEqn(), 0);
  }
}

if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', boot);
} else {
  boot();
}
