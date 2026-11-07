/* =====================================================================
   Blackbody Curves and Filters Explorer  --  HTML5 port
   Behavior ported verbatim from the decompiled NAAP Flash sim
   (bbExplorer026.swf: "Blackbody Explorer", "Simple Blackbody",
    "Filterer", "Filter Details Panel", "Number Formatting").
   The canvas is the visual layer only; native controls + the sr-only
   description / live region are the accessibility layer.
   ===================================================================== */
'use strict';

/* ---------------------------------------------------------------------
   PHYSICS CONSTANTS  (copied verbatim from the ActionScript source)
   --------------------------------------------------------------------- */
// Planck spectral-radiance form used by the sim:  f(w) = A / ( w^5 * (e^(B/(w*T)) - 1) )
const A = 1.1910425859324616e-16;          // Simple Blackbody.redraw
const B = 0.014387750559248378;            // hc/k  (Simple Blackbody.redraw)
const WIEN = 0.0028977682864295084;        // Wien displacement constant, m*K
const WIEN_NM = 2897768.2864295086;        // peak wavelength in nm = WIEN_NM / T
const SIGMA = 5.669e-8;                     // Stefan-Boltzmann (area = SIGMA * T^4)
const VTARGET = 0.9;                        // autoscale target peak height fraction

const MINWAV = 2.5e-8;                      // minWavelength (m) = 25 nm  (fixed)
const CURVE_COLORS = [15753312, 6344800, 10526960, 15580466, 10526880]; // curveColorsList
const MIN_CURVES = 1, MAX_CURVES = 5;

// Temperature slider (sliderV5Component init): log scale, 3 sig figs
const T_MIN = 3000, T_MAX = 25000, T_DEFAULT = 6000, T_SIGFIGS = 3;
// Horizontal-scale slider ("rightmost limit"): linear 1000-5000 nm, 2 sig figs
const H_MIN = 1000, H_MAX = 5000, H_DEFAULT = 1000, H_SIGFIGS = 2;

/* ---------------------------------------------------------------------
   PLOT GEOMETRY  (internal stage coordinates; canvas scales via CSS)
   Plot area 515 x 420 matches the Flash stage (Filterer _plotWidth/Height).
   --------------------------------------------------------------------- */
const M_L = 82, M_T = 34, M_R = 15, M_B = 46;   // top margin leaves room for the ×10^n header
const PLOT_W = 515, PLOT_H = 420;
const TW = M_L + PLOT_W + M_R;             // 612
const TH = M_T + PLOT_H + M_B;             // 478
const PLOT_LEFT = M_L, PLOT_TOP = M_T;
const PLOT_RIGHT = M_L + PLOT_W;           // 597
const PLOT_BOTTOM = M_T + PLOT_H;          // 432

const MIN_SCREEN_X = 45, MIN_SCREEN_Y = 30;    // minScreenXSpacing / Y
const MAJOR_EXT = 10, MINOR_EXT = 7;           // tickmark extents
const SPECTRUM_H = 14;                          // visible-spectrum band height (px, see notes)

const BG_COLOR = intToRgb(16448250);            // plot background #FAFAFA
const AXIS_COLOR = '#000000';

// Visible-spectrum gradient (updateHorizontalAxis: colors/ratios/alphas, 380-720 nm)
const SPEC_COLORS = [9044223, 5905407, 1087455, 65472, 2424576, 15330304, 16717568, 16711738];
const SPEC_RATIOS = [0, 62, 73, 107, 129, 141, 174, 255];
const SPEC_ALPHAS = [0, 100, 100, 100, 100, 100, 100, 0];

/* ---------------------------------------------------------------------
   FILTER DATA  (U, B, V, R transmittance tables -- verbatim from Filter Data.as)
   Loaded lazily from an embedded block at the bottom of this file.
   --------------------------------------------------------------------- */
// (FILTERS defined near the end of file to keep the logic readable.)

/* ---------------------------------------------------------------------
   NUMBER FORMATTING  (ported from Number Formatting.as / Sci Not Number)
   --------------------------------------------------------------------- */
// Round to N significant figures (matches sliderV5 setValue / Math.toSigDigits intent).
function sigDigits(v, n) {
  if (v === 0 || !isFinite(v)) return v;
  const s = v < 0 ? -1 : 1; v = Math.abs(v);
  const d = Math.floor(Math.log(v) / Math.LN10);
  const f = Math.pow(10, n - 1 - d);
  return s * Math.round(v * f) / f;
}
// Scientific coefficient + exponent strings (ported from getCoefficientAndExponent).
function sciParts(num, digs) {
  if (num === 0) {
    let c = '0'; const ez = digs - 1;
    if (ez !== 0) { c += '.'; for (let i = 0; i < ez; i++) c += '0'; }
    return { coeff: c, exp: '0' };
  }
  let coeff = '';
  if (num < 0) { coeff = '-'; num = Math.abs(num); }
  let expo = Math.floor(Math.log(num) / Math.LN10);
  const num2raw = Math.round(Math.pow(10, digs - 1) * Math.pow(10, -expo) * num) / Math.pow(10, digs - 1);
  let num2 = num2raw;
  if (num2 >= 10) { num2 /= 10; expo++; }
  let s = String(num2);
  const addDot = s.indexOf('.') === -1;
  let sf = 0;
  for (let i = 0; i < s.length; i++) { const cc = s.charCodeAt(i); if (cc > 47 && cc < 58) sf++; }
  const nz = digs - sf;
  if (nz > 0 && addDot) s += '.';
  for (let i = 0; i < nz; i++) s += '0';
  return { coeff: coeff + s, exp: String(expo) };
}
// LaTeX for a value in scientific notation, e.g. 7.35 x 10^7
function sciLatex(num, digs) {
  const p = sciParts(num, digs);
  if (p.exp === '0') return p.coeff;
  return `${p.coeff}\\times10^{${p.exp}}`;
}
// Spoken form, e.g. "7.35 times 10 to the 7"
function sciSpoken(num, digs) {
  const p = sciParts(num, digs);
  if (p.exp === '0') return p.coeff;
  return `${p.coeff} times 10 to the ${p.exp}`;
}

/* ---------------------------------------------------------------------
   COLOR HELPERS
   --------------------------------------------------------------------- */
function intToRgb(c) {
  return `rgb(${(c >> 16) & 255},${(c >> 8) & 255},${c & 255})`;
}
function intToRgba(c, a) {
  return `rgba(${(c >> 16) & 255},${(c >> 8) & 255},${c & 255},${a})`;
}

/* ---------------------------------------------------------------------
   SI PREFIX TABLE  (for x-axis tick labels -- from Simple Blackbody.as)
   --------------------------------------------------------------------- */
const SI_PREFIXES = [
  { power: 24, prefix: 'Y' }, { power: 21, prefix: 'Z' }, { power: 18, prefix: 'E' },
  { power: 15, prefix: 'P' }, { power: 12, prefix: 'T' }, { power: 9, prefix: 'G' },
  { power: 6, prefix: 'M' }, { power: 3, prefix: 'k' }, { power: 0, prefix: '' },
  { power: -2, prefix: 'c' }, { power: -3, prefix: 'm' }, { power: -6, prefix: 'µ' },
  { power: -9, prefix: 'n' }, { power: -12, prefix: 'p' }, { power: -15, prefix: 'f' },
  { power: -18, prefix: 'a' }, { power: -21, prefix: 'z' }, { power: -24, prefix: 'y' }
];

/* =====================================================================
   STATE  (single source of truth; render() redraws everything from it)
   ===================================================================== */
const state = {
  curves: [],            // { id, temp, color }
  selected: null,
  freeId: 0,
  temperature: T_DEFAULT,
  hScaleNm: H_DEFAULT,   // rightmost limit in nm
  maxWav: H_DEFAULT * 1e-9,
  maxBrightness: 1e12,
  scaleMode: 'all',      // 'locked' | 'all' | 'selected'
  showArea: false,
  showPeak: false,
  tab: 'curves',         // 'curves' | 'filters'
  scaleTab: 'vertical',  // 'vertical' | 'horizontal'
  ciMinuend: 'U',
  ciSubtrahend: 'U',
  // filter results (recomputed when filters tab active)
  filterSums: null,
  filterMags: null
};

let canvas, ctx, dpr = 1;
let els = {};            // cached DOM references
let lastTickSig = '';    // to avoid rebuilding tick overlay unnecessarily
let FILTERS = null;      // U,B,V,R tables (from assets/filter-data.js), set in init()

/* =====================================================================
   PLANCK PHYSICS
   ===================================================================== */
// f(w meters, T) -- spectral radiance form used by the sim
function planck(w, T) {
  return A / (Math.pow(w, 5) * (Math.exp(B / (w * T)) - 1));
}
function peakWavelengthNm(T) { return WIEN_NM / T; }
function areaUnderCurve(T) { return SIGMA * Math.pow(T, 4); }   // W/m^2

// Recompute maxBrightness (top-of-plot value) for the current scale mode.
function recomputeScale() {
  state.maxWav = state.hScaleNm * 1e-9;
  if (state.scaleMode === 'locked') return;   // frozen (vScaleMode 0)
  const curves = state.scaleMode === 'selected' ? [state.selected] : state.curves;
  let maxT = 0;
  for (const c of curves) if (c && c.temp > maxT) maxT = c.temp;
  let wPeak = WIEN / maxT;
  if (wPeak < MINWAV) wPeak = MINWAV;
  else if (wPeak > state.maxWav) wPeak = state.maxWav;
  state.maxBrightness = A / (Math.pow(wPeak, 5) * (Math.exp(B / (wPeak * maxT)) - 1)) / VTARGET;
}

/* =====================================================================
   COORDINATE MAPPING (original stage coordinates)
   ===================================================================== */
function wavMToX(wm) {                    // wavelength (m) -> canvas x
  return PLOT_LEFT + (wm - MINWAV) / (state.maxWav - MINWAV) * PLOT_W;
}
function wavNmToX(wnm) { return wavMToX(wnm * 1e-9); }
function brightToY(b) {                   // brightness -> canvas y (clamped to plot top)
  const y = PLOT_BOTTOM - b * (PLOT_H / state.maxBrightness);
  return y < PLOT_TOP ? PLOT_TOP : y;
}

/* =====================================================================
   CANVAS RENDERING
   ===================================================================== */
function setupCanvas() {
  canvas = document.getElementById('plot-canvas');
  ctx = canvas.getContext('2d');
  dpr = Math.max(1, window.devicePixelRatio || 1);
  canvas.width = Math.round(TW * dpr);
  canvas.height = Math.round(TH * dpr);
}

function drawPlot() {
  ctx.setTransform(dpr, 0, 0, dpr, 0, 0);
  ctx.clearRect(0, 0, TW, TH);

  // plot background
  ctx.fillStyle = BG_COLOR;
  ctx.fillRect(PLOT_LEFT, PLOT_TOP, PLOT_W, PLOT_H);

  drawVisibleSpectrum();
  drawAxes();

  // Curves clipped to plot area
  ctx.save();
  ctx.beginPath();
  ctx.rect(PLOT_LEFT, PLOT_TOP, PLOT_W, PLOT_H);
  ctx.clip();

  if (state.tab === 'filters') {
    drawFilterProfiles();
    drawBlackbodyCurve(state.selected, true);   // selected curve only, thick
  } else {
    // non-selected first, selected on top (thicker)
    for (const c of state.curves) if (c !== state.selected) drawBlackbodyCurve(c, false);
    drawBlackbodyCurve(state.selected, true);
  }
  ctx.restore();
}

function drawVisibleSpectrum() {
  const x0 = wavMToX(3.8e-7), x1 = wavMToX(7.2e-7);
  if (x1 <= PLOT_LEFT || x0 >= PLOT_RIGHT) return;
  const grad = ctx.createLinearGradient(x0, 0, x1, 0);
  for (let i = 0; i < SPEC_COLORS.length; i++) {
    grad.addColorStop(SPEC_RATIOS[i] / 255, intToRgba(SPEC_COLORS[i], SPEC_ALPHAS[i] / 100));
  }
  ctx.save();
  ctx.beginPath();
  ctx.rect(PLOT_LEFT, PLOT_TOP, PLOT_W, PLOT_H);
  ctx.clip();
  ctx.fillStyle = grad;
  ctx.fillRect(x0, PLOT_BOTTOM - SPECTRUM_H, x1 - x0, SPECTRUM_H);
  ctx.restore();
}

function drawBlackbodyCurve(curve, selected) {
  if (!curve) return;
  const T = curve.temp;
  const yScale = PLOT_H / state.maxBrightness;
  ctx.beginPath();
  let started = false;
  // sample one point per pixel column across the plot
  for (let px = 0; px <= PLOT_W; px++) {
    const wm = MINWAV + (px / PLOT_W) * (state.maxWav - MINWAV);
    const f = planck(wm, T);
    let y = PLOT_BOTTOM - f * yScale;
    if (y < PLOT_TOP) y = PLOT_TOP;
    const x = PLOT_LEFT + px;
    if (!started) { ctx.moveTo(x, y); started = true; } else { ctx.lineTo(x, y); }
  }
  // optional fill under the (selected) curve
  if (selected && state.showArea && state.tab !== 'filters') {
    ctx.lineTo(PLOT_RIGHT, PLOT_BOTTOM);
    ctx.lineTo(PLOT_LEFT, PLOT_BOTTOM);
    ctx.closePath();
    ctx.fillStyle = intToRgba(curve.color, 0.30);   // fillAlpha 30
    ctx.fill();
    // re-stroke just the curve line on top
    ctx.beginPath();
    started = false;
    for (let px = 0; px <= PLOT_W; px++) {
      const wm = MINWAV + (px / PLOT_W) * (state.maxWav - MINWAV);
      let y = PLOT_BOTTOM - planck(wm, T) * yScale;
      if (y < PLOT_TOP) y = PLOT_TOP;
      const x = PLOT_LEFT + px;
      if (!started) { ctx.moveTo(x, y); started = true; } else { ctx.lineTo(x, y); }
    }
  }
  ctx.lineWidth = selected ? 3 : 1;              // selected thickness 3, else 1
  ctx.strokeStyle = intToRgb(curve.color);
  ctx.lineJoin = 'round';
  ctx.stroke();
}

function drawFilterProfiles() {
  const T = state.selected.temp;
  const yScale = PLOT_H / state.maxBrightness;
  const A_ = A / Math.pow(1e-9, 5);
  const B_ = B / (1e-9 * T);
  for (const f of FILTERS) {
    const d = f.data;
    ctx.beginPath();
    ctx.moveTo(wavNmToX(d[0].w), PLOT_BOTTOM);
    for (let j = 0; j < d.length; j++) {
      const w = d[j].w;
      const b = d[j].t * (A_ / (Math.pow(w, 5) * (Math.exp(B_ / w) - 1)));
      let y = PLOT_BOTTOM - b * yScale;
      if (y < PLOT_TOP) y = PLOT_TOP;
      ctx.lineTo(wavNmToX(w), y);
    }
    ctx.lineTo(wavNmToX(d[d.length - 1].w), PLOT_BOTTOM);
    ctx.closePath();
    ctx.fillStyle = intToRgba(f.color, 0.20);      // inactiveAlpha 20
    ctx.fill();
    ctx.lineWidth = 1;
    ctx.strokeStyle = intToRgba(f.color, 0.55);
    ctx.stroke();
  }
}

function drawAxes() {
  ctx.strokeStyle = AXIS_COLOR;
  ctx.lineWidth = 1;
  ctx.font = '11px sans-serif';   // (only used for potential fallbacks; labels are HTML)

  // ---- vertical axis + ticks ----
  const yTicks = computeYTicks();
  ctx.beginPath();
  for (const t of yTicks.ticks) {
    const y = PLOT_BOTTOM - t.ypx;
    const ext = t.major ? MAJOR_EXT : MINOR_EXT;
    ctx.moveTo(PLOT_LEFT - ext, y);
    ctx.lineTo(PLOT_LEFT, y);
  }
  ctx.moveTo(PLOT_LEFT, PLOT_BOTTOM);
  ctx.lineTo(PLOT_LEFT, PLOT_BOTTOM - PLOT_H);
  ctx.stroke();

  // ---- horizontal axis + ticks ----
  const xTicks = computeXTicks();
  ctx.beginPath();
  for (const t of xTicks.ticks) {
    const ext = t.major ? MAJOR_EXT : MINOR_EXT;
    ctx.moveTo(t.xpx, PLOT_BOTTOM);
    ctx.lineTo(t.xpx, PLOT_BOTTOM + ext);
  }
  ctx.moveTo(PLOT_LEFT, PLOT_BOTTOM);
  ctx.lineTo(PLOT_LEFT + PLOT_W, PLOT_BOTTOM);
  ctx.stroke();

  updateTickOverlay(yTicks.labels, xTicks.labels);
}

// Y tick computation (ported from updateVerticalAxis)
function computeYTicks() {
  const ticks = [], labels = [];
  const maxBrightness = state.maxBrightness;
  const yScale = PLOT_H / maxBrightness;
  if (yScale > 0) {
    const minimumSpacing = MIN_SCREEN_Y / yScale;
    let majorSpacing = Math.pow(10, Math.ceil(Math.log(minimumSpacing) / Math.LN10));
    let multiple;
    if (majorSpacing / 2 > minimumSpacing) { majorSpacing /= 2; multiple = 5; } else { multiple = 2; }
    const minorSpacing = majorSpacing / multiple;
    const yStep = minorSpacing * yScale;
    const tickNumLimit = 1 + Math.floor(maxBrightness / minorSpacing);
    for (let i = 0; i < tickNumLimit; i++) {
      const ypx = i * yStep;
      const major = (i % multiple === 0);
      ticks.push({ ypx, major });
      if (major) {
        const value = minorSpacing * i;
        labels.push({ ypx, value });
      }
    }
  }
  return { ticks, labels };
}

// X tick computation (ported from updateHorizontalAxis)
function computeXTicks() {
  const ticks = [], labels = [];
  const minWav = MINWAV, maxWav = state.maxWav;
  const xScale = PLOT_W / (maxWav - minWav);
  if (xScale > 0) {
    const minimumSpacing = MIN_SCREEN_X / xScale;
    let majorSpacing = Math.pow(10, Math.ceil(Math.log(minimumSpacing) / Math.LN10));
    let multiple;
    if (majorSpacing / 2 > minimumSpacing) { majorSpacing /= 2; multiple = 5; } else { multiple = 2; }
    const minorSpacing = majorSpacing / multiple;
    const xStep = minorSpacing * xScale;
    const startTickNum = Math.ceil(minWav / minorSpacing);
    const tickNumLimit = 1 + Math.floor(maxWav / minorSpacing);
    let x = xScale * (minorSpacing * startTickNum - minWav);
    for (let n = startTickNum; n < tickNumLimit; n++) {
      const major = (n % multiple === 0);
      ticks.push({ xpx: PLOT_LEFT + x, major });
      if (major) {
        const value = minorSpacing * n;
        labels.push({ xpx: PLOT_LEFT + x, label: siLabel(value) });
      }
      x += xStep;
    }
  }
  // De-congest: if there would be too many labels to read, label every other
  // major (keeping the rightmost). Tick MARKS are unchanged.
  if (labels.length > 7) {
    const keep = (labels.length - 1) % 2;
    return { ticks, labels: labels.filter((_, i) => i % 2 === keep) };
  }
  return { ticks, labels };
}

function siLabel(value) {
  if (value <= 0) return '0';
  const logValue = Math.log(value) / Math.LN10;
  const last = SI_PREFIXES.length - 1;
  let i;
  if (SI_PREFIXES[last].power > logValue) i = last;
  else { i = 0; while (SI_PREFIXES[i].power > logValue) i++; }
  const coeff = value / Math.pow(10, SI_PREFIXES[i].power);
  // trim floating noise
  const c = parseFloat(coeff.toPrecision(6));
  return `${c} ${SI_PREFIXES[i].prefix}m`;
}

/* =====================================================================
   MATHJAX TICK-LABEL + PEAK-LABEL OVERLAY  (HTML, so it zooms & is
   MathJax-typeset -> right-click "Show Math As" works on every symbol)
   ===================================================================== */
function pctLeft(px) { return (px / TW * 100) + '%'; }
function pctTop(py) { return (py / TH * 100) + '%'; }

function updateTickOverlay(yLabels, xLabels) {
  const overlay = els.overlay;
  // Factor a common power of ten out of the y-axis labels: show it once as a
  // "×10^n" header at the top of the axis, and label ticks as plain mantissas
  // (3.5, 3.0, 2.5, ...), which is far less cluttered than "3.5×10^13" per tick.
  const nonzero = yLabels.filter(l => l.value !== 0);
  let commonExp = null;
  if (nonzero.length) {
    const maxVal = Math.max.apply(null, nonzero.map(l => l.value));
    commonExp = Math.floor(Math.log(maxVal) / Math.LN10);
  }

  // signature to skip rebuilds when nothing changed
  const sig = 'Y' + yLabels.map(l => l.value.toExponential(3)).join(',') + '|E' + commonExp +
              '|X' + xLabels.map(l => l.label).join(',') +
              '|P' + (state.showPeak ? peakWavelengthNm(state.selected.temp).toFixed(1) : '-') +
              '|T' + state.tab;
  if (sig === lastTickSig) { positionPeakLabel(); return; }
  lastTickSig = sig;

  let html = '';
  // ×10^n header centered above the top of the y-axis (MathJax-typeset)
  if (commonExp !== null) {
    html += `<span class="tick tick--yexp" style="left:${pctLeft(PLOT_LEFT)};top:${pctTop(16)}">\\(\\times 10^{${commonExp}}\\)</span>`;
  }
  // y-axis major labels as MathJax mantissas (right-aligned, ending at PLOT_LEFT - MAJOR_EXT)
  for (const l of yLabels) {
    const y = PLOT_BOTTOM - l.ypx;
    const mant = l.value === 0 ? '0' : (l.value / Math.pow(10, commonExp)).toFixed(1);
    html += `<span class="tick tick--y" style="left:${pctLeft(PLOT_LEFT - MAJOR_EXT - 3)};top:${pctTop(y)}">\\(${mant}\\)</span>`;
  }
  // x-axis major labels (centered below tick)
  for (const l of xLabels) {
    html += `<span class="tick tick--x" style="left:${pctLeft(l.xpx)};top:${pctTop(PLOT_BOTTOM + MAJOR_EXT + 1)}">${xLabelLatex(l.label)}</span>`;
  }
  // peak-wavelength label
  if (state.showPeak && state.selected) {
    html += `<span class="tick tick--peak" id="peak-label"></span>`;
  }
  overlay.innerHTML = html;
  if (state.showPeak && state.selected) {
    const nm = peakWavelengthNm(state.selected.temp).toFixed(1);
    document.getElementById('peak-label').innerHTML = `\\(\\text{peak at }${nm}\\ \\mathrm{nm}\\)`;
    positionPeakLabel();
  }
  typeset(overlay);
}

// wrap the numeric part of "100 nm" / "1 µm" in MathJax
function xLabelLatex(label) {
  const m = label.match(/^([\d.]+)\s+(\S+)$/);
  if (!m) return `\\(${label}\\)`;
  return `\\(${m[1]}\\ \\mathrm{${m[2].replace('µ', '\\mu ')}}\\)`;
}

function positionPeakLabel() {
  const el = document.getElementById('peak-label');
  if (!el || !state.selected) return;
  const T = state.selected.temp;
  const wPeak = WIEN / T;
  const px = wavMToX(wPeak);
  const maxB = planck(wPeak, T);
  let y = PLOT_BOTTOM - maxB * (PLOT_H / state.maxBrightness);
  if (y < PLOT_TOP + 12) y = PLOT_TOP + 12;
  el.style.left = pctLeft(Math.max(PLOT_LEFT + 24, Math.min(PLOT_RIGHT - 24, px)));
  el.style.top = pctTop(y - 6);
}

/* =====================================================================
   MATHJAX helpers  (batch typeset via rAF so slider drags stay smooth)
   ===================================================================== */
let mjQueue = new Set(), mjScheduled = false;
function typeset(el) {
  mjQueue.add(el);
  if (mjScheduled) return;
  mjScheduled = true;
  // setTimeout (not rAF) so batching also fires in headless/background contexts
  setTimeout(flushTypeset, 0);
}
function flushTypeset() {
  mjScheduled = false;
  const nodes = [...mjQueue].filter(n => n && n.isConnected);
  mjQueue.clear();
  if (window.MathJax && MathJax.typesetPromise && nodes.length) {
    MathJax.typesetClear && MathJax.typesetClear(nodes);
    MathJax.typesetPromise(nodes).then(stripMathTabstops).catch(() => {});
  }
}
// The sim's math is all read-only readouts/labels, not interactive controls.
// MathJax gives each container tabindex="0"; remove it so Tab visits only the
// real controls (right-click still opens the MathJax "Show Math As" menu).
function stripMathTabstops() {
  document.querySelectorAll('mjx-container[tabindex]').forEach(c => c.setAttribute('tabindex', '-1'));
}

/* =====================================================================
   CURVES LIST (radiogroup rendered as a table)
   ===================================================================== */
function renderCurvesList() {
  const box = els.curvesRows;
  box.innerHTML = '';
  state.curves.forEach((c, idx) => {
    const temp = sigDigits(c.temp, 3);
    const peak = peakWavelengthNm(c.temp);
    const area = areaUnderCurve(c.temp);
    const selected = (c === state.selected);
    const row = document.createElement('label');
    row.className = 'curve-row' + (selected ? ' curve-row--selected' : '');
    // UNIQUE name per row so the browser doesn't apply radio "roving" (which
    // skips unchecked radios during Tab) -> every curve row is its own Tab stop.
    row.innerHTML =
      `<input type="radio" name="curveSel-${c.id}" class="sr-only" value="${c.id}" ${selected ? 'checked' : ''}>` +
      `<span class="cl-swatch"><span class="swatch" style="background:${intToRgb(c.color)}"></span></span>` +
      `<span class="cl-temp">${temp} K</span>` +
      `<span class="cl-peak">${peak.toFixed(1)} nm</span>` +
      `<span class="cl-area mj-area"></span>`;
    // accessible label with units, fully spoken
    const input = row.querySelector('input');
    input.setAttribute('aria-label',
      `Curve ${idx + 1}: temperature ${temp} kelvin, peak wavelength ${peak.toFixed(1)} nanometers, ` +
      `area under curve ${sciSpoken(area, 3)} watts per square meter${selected ? ', selected' : ''}`);
    input.addEventListener('change', () => {
      selectCurve(c.id);
      renderCurvesList();
      const sel = els.curvesRows.querySelector(`input[value="${c.id}"]`);
      if (sel) sel.focus();   // keep focus on the row the user just selected
    });
    box.appendChild(row);
    // typeset the area cell (scientific)
    const areaCell = row.querySelector('.mj-area');
    areaCell.innerHTML = `\\(${sciLatex(area, 3)}\\ \\mathrm{W/m^2}\\)`;
    typeset(areaCell);
  });
}

/* =====================================================================
   FILTERS  (ported from Filterer.update + Filter Details Panel)
   ===================================================================== */
// constant offset for "1 R_sun star at 10 pc"  (Filter Details Panel.update)
const MAG_CONST = 2.5 * Math.log(
  (1.288659793814433 * 1.288659793814433) / (0.37037037037037035 * 0.37037037037037035)
) / Math.LN10;

function computeFilters() {
  const T = state.selected.temp;
  const A_ = A / Math.pow(1e-9, 5);
  const B_ = B / (1e-9 * T);
  const sums = {}, mags = {};
  for (const f of FILTERS) {
    const d = f.data;
    let sum = 0, lb = 0;
    for (let j = 1; j < d.length; j++) {
      const b = d[j].t * (A_ / (Math.pow(d[j].w, 5) * (Math.exp(B_ / d[j].w) - 1)));
      sum += 1e-9 * (lb + (b - lb) / 2);   // trapezoid, exactly as AS
      lb = b;
    }
    sums[f.name] = sum;
    mags[f.name] = f.offset - Math.log(sum) * 2.5 / Math.LN10;
  }
  state.filterSums = sums;
  state.filterMags = mags;
}

function updateFilterDetails() {
  if (state.tab !== 'filters') return;
  computeFilters();
  const m = state.filterMags;
  els.magU.textContent = (MAG_CONST + m.U).toFixed(2);
  els.magB.textContent = (MAG_CONST + m.B).toFixed(2);
  els.magV.textContent = (MAG_CONST + m.V).toFixed(2);
  els.magR.textContent = (MAG_CONST + m.R).toFixed(2);
  updateColorIndex();
  updateBarGraph();
}

function updateColorIndex() {
  const m = state.filterMags; if (!m) return;
  const ci = m[state.ciMinuend] - m[state.ciSubtrahend];
  els.ciResult.innerHTML = `\\(=\\ ${ci.toFixed(2).replace('-', '-')}\\)`;
  typeset(els.ciResult);
}

// Bar-graph relative heights (ported from updateBarGraph normalizers)
function updateBarGraph() {
  const sums = state.filterSums; if (!sums) return;
  const area = SIGMA * Math.pow(state.selected.temp, 4);
  const K = 32500;
  const raw = {
    U: K * (Math.PI * sums.U / area) / 101.6,
    B: K * (Math.PI * sums.B / area) / 70.45,
    V: K * (Math.PI * sums.V / area) / 47.7,
    R: K * (Math.PI * sums.R / area) / 60.65
  };
  // uniform display scale so bars fit the graph box while preserving ratios
  const BAR_MAX_PX = 130, DISPLAY_SCALE = 0.9;
  for (const k of ['U', 'B', 'V', 'R']) {
    const h = Math.max(0, Math.min(BAR_MAX_PX, raw[k] * DISPLAY_SCALE));
    els['bar' + k].style.height = h.toFixed(1) + 'px';
    els['bar' + k].style.background = intToRgb(FILTERS.find(f => f.name === k).color);
  }
}

/* =====================================================================
   CURVE MANAGEMENT  (ported from Blackbody Explorer)
   ===================================================================== */
function addCurve(silent) {
  const id = state.freeId++;
  const color = CURVE_COLORS[id % CURVE_COLORS.length];
  const curve = { id, temp: state.temperature, color };
  state.curves.push(curve);
  selectCurve(id, true);
  els.btnRemove.disabled = !(state.curves.length > MIN_CURVES);
  els.btnAdd.disabled = (state.curves.length >= MAX_CURVES);
  if (!silent) {
    render();
    announce(`Added curve. ${state.curves.length} of ${MAX_CURVES} curves. ` + selectedSpoken());
  }
}

function removeCurve() {
  if (state.curves.length <= MIN_CURVES) return;
  const idx = state.curves.indexOf(state.selected);
  state.curves.splice(idx, 1);
  const nextIdx = idx >= state.curves.length ? state.curves.length - 1 : idx;
  selectCurve(state.curves[nextIdx].id, true);
  els.btnRemove.disabled = !(state.curves.length > MIN_CURVES);
  els.btnAdd.disabled = (state.curves.length >= MAX_CURVES);
  render();
  announce(`Removed curve. ${state.curves.length} of ${MAX_CURVES} curves. ` + selectedSpoken());
}

function selectCurve(id, quiet) {
  const c = state.curves.find(x => x.id === id);
  if (!c) return;
  state.selected = c;
  // selecting a curve moves the temperature slider/field to that curve's temp
  state.temperature = c.temp;
  syncTemperatureControls();
  if (state.scaleMode === 'selected') recomputeScale();
  if (!quiet) { render(); announce(selectedSpoken()); }
}

/* =====================================================================
   TEMPERATURE + HSCALE SLIDER MAPPING
   ===================================================================== */
const T_LN_MIN = Math.log(T_MIN), T_LN_MAX = Math.log(T_MAX);
function tempPosToValue(pos) {                        // 0..1000 (log) -> snapped temp
  const raw = Math.exp(T_LN_MIN + (pos / 1000) * (T_LN_MAX - T_LN_MIN));
  return clamp(sigDigits(raw, T_SIGFIGS), T_MIN, T_MAX);
}
function tempValueToPos(v) {
  return Math.round((Math.log(clamp(v, T_MIN, T_MAX)) - T_LN_MIN) / (T_LN_MAX - T_LN_MIN) * 1000);
}
function clamp(v, lo, hi) { return v < lo ? lo : (v > hi ? hi : v); }

function syncTemperatureControls() {
  els.tempInput.value = String(sigDigits(state.temperature, T_SIGFIGS));
  els.tempSlider.value = String(tempValueToPos(state.temperature));
  els.tempSlider.setAttribute('aria-valuetext',
    `Temperature ${sigDigits(state.temperature, T_SIGFIGS)} kelvin`);
}

function setTemperature(temp, commit) {
  state.temperature = temp;
  if (state.selected) state.selected.temp = temp;
  if (state.scaleMode === 'selected' || state.scaleMode === 'all') recomputeScale();
  render();
  if (commit) announce(selectedSpoken());
}

// hScale
function hPosToValue(pos) { return clamp(sigDigits(pos, H_SIGFIGS), H_MIN, H_MAX); }
function hMicronText(nm) {
  const um = nm / 1000;
  const s = parseFloat(um.toPrecision(3));
  return `${s} µm`;
}
function setHScale(nm, commit) {
  state.hScaleNm = nm;
  state.maxWav = nm * 1e-9;
  recomputeScale();
  els.hscaleOut.textContent = hMicronText(nm);
  els.hscaleSlider.setAttribute('aria-valuetext',
    `Rightmost limit ${nm} nanometers, ${hMicronText(nm)}`);
  render();
  if (commit) announce(`Rightmost wavelength limit ${hMicronText(nm)}, ${nm} nanometers.`);
}

/* =====================================================================
   ANNOUNCEMENTS (aria-live, always with units)
   ===================================================================== */
function announce(msg) { els.status.textContent = msg; }
function selectedSpoken() {
  const c = state.selected; if (!c) return '';
  const peak = peakWavelengthNm(c.temp).toFixed(1);
  const area = sciSpoken(areaUnderCurve(c.temp), 3);
  return `Selected curve temperature ${sigDigits(c.temp, 3)} kelvin, ` +
         `peak wavelength ${peak} nanometers, area under curve ${area} watts per square meter.`;
}

/* =====================================================================
   PLOT DESCRIPTION (sr-only, kept in sync from render)
   ===================================================================== */
function updatePlotDesc() {
  const n = state.curves.length;
  const c = state.selected;
  let d = `Flux versus wavelength plot from 25 nanometers to ${state.hScaleNm} nanometers. ` +
    `${n} blackbody ${n === 1 ? 'curve' : 'curves'}. `;
  if (c) {
    d += `Selected curve: temperature ${sigDigits(c.temp, 3)} kelvin, ` +
      `peak wavelength ${peakWavelengthNm(c.temp).toFixed(1)} nanometers. `;
  }
  if (state.tab === 'filters') d += 'Filters view: U, B, V and R filter bands are shown over the selected curve. ';
  els.plotDesc.textContent = d;
}

/* =====================================================================
   MASTER RENDER
   ===================================================================== */
function render() {
  recomputeScale();
  drawPlot();
  updatePlotDesc();
  if (state.tab === 'filters') updateFilterDetails();
}

/* =====================================================================
   TAB SWITCHING
   ===================================================================== */
function setMainTab(tab) {
  state.tab = tab;
  const curves = tab === 'curves';
  els.tabCurves.setAttribute('aria-selected', String(curves));
  els.tabFilters.setAttribute('aria-selected', String(!curves));
  // all tab buttons stay in the Tab order (every button is keyboard-reachable)
  els.panelCurves.hidden = !curves;
  els.panelFilters.hidden = curves;
  render();
}
function setScaleTab(tab) {
  state.scaleTab = tab;
  const vert = tab === 'vertical';
  els.tabVscale.setAttribute('aria-selected', String(vert));
  els.tabHscale.setAttribute('aria-selected', String(!vert));
  els.panelVscale.hidden = !vert;
  els.panelHscale.hidden = vert;
}

// Roving-tabindex arrow navigation for a tablist
function wireTablist(tablist, onSelect, tabs) {
  tablist.addEventListener('keydown', (e) => {
    const i = tabs.indexOf(document.activeElement);
    if (i === -1) return;
    let n = i;
    if (e.key === 'ArrowRight' || e.key === 'ArrowDown') n = (i + 1) % tabs.length;
    else if (e.key === 'ArrowLeft' || e.key === 'ArrowUp') n = (i - 1 + tabs.length) % tabs.length;
    else if (e.key === 'Home') n = 0;
    else if (e.key === 'End') n = tabs.length - 1;
    else return;
    e.preventDefault();
    tabs[n].focus();
    onSelect(tabs[n]);
  });
}

/* =====================================================================
   RESET  (ported from Blackbody Explorer.reset)
   ===================================================================== */
function resetSim() {
  state.curves = [];
  state.selected = null;
  state.freeId = 0;
  state.temperature = T_DEFAULT;
  state.showArea = false;
  state.showPeak = false;
  state.scaleMode = 'all';
  state.hScaleNm = H_DEFAULT;
  state.maxWav = H_DEFAULT * 1e-9;
  state.ciMinuend = 'U';
  state.ciSubtrahend = 'U';

  els.chkArea.checked = false;
  els.chkPeak.checked = false;
  document.getElementById('sm-locked').checked = false;
  document.getElementById('sm-all').checked = true;
  document.getElementById('sm-selected').checked = false;
  els.ciMin.value = 'U';
  els.ciSub.value = 'U';
  els.hscaleSlider.value = String(H_DEFAULT);
  setHScaleControlsOnly(H_DEFAULT);

  setMainTab('curves');
  setScaleTab('vertical');
  els.btnAdd.disabled = false;
  els.btnRemove.disabled = true;

  addCurve(true);            // one curve at 6000 K
  syncTemperatureControls();
  renderCurvesList();
  render();
  announce('Simulation reset. One curve at 6000 kelvin.');
}
function setHScaleControlsOnly(nm) {
  els.hscaleOut.textContent = hMicronText(nm);
  els.hscaleSlider.setAttribute('aria-valuetext',
    `Rightmost limit ${nm} nanometers, ${hMicronText(nm)}`);
}

/* =====================================================================
   INIT / EVENT WIRING
   ===================================================================== */
function cache() {
  els = {
    status: document.getElementById('sr-status'),
    overlay: document.getElementById('plot-overlay'),
    plotDesc: document.getElementById('plot-desc'),
    tabCurves: document.getElementById('tab-curves'),
    tabFilters: document.getElementById('tab-filters'),
    panelCurves: document.getElementById('panel-curves'),
    panelFilters: document.getElementById('panel-filters'),
    tabVscale: document.getElementById('tab-vscale'),
    tabHscale: document.getElementById('tab-hscale'),
    panelVscale: document.getElementById('panel-vscale'),
    panelHscale: document.getElementById('panel-hscale'),
    tempInput: document.getElementById('temp-input'),
    tempSlider: document.getElementById('temp-slider'),
    chkArea: document.getElementById('chk-area'),
    chkPeak: document.getElementById('chk-peak'),
    curvesRows: document.getElementById('curves-rows'),
    btnAdd: document.getElementById('btn-add'),
    btnRemove: document.getElementById('btn-remove'),
    hscaleSlider: document.getElementById('hscale-slider'),
    hscaleOut: document.getElementById('hscale-out'),
    magU: document.getElementById('mag-U'), magB: document.getElementById('mag-B'),
    magV: document.getElementById('mag-V'), magR: document.getElementById('mag-R'),
    ciMin: document.getElementById('ci-minuend'),
    ciSub: document.getElementById('ci-subtrahend'),
    ciResult: document.getElementById('ci-result'),
    barU: document.getElementById('bar-U'), barB: document.getElementById('bar-B'),
    barV: document.getElementById('bar-V'), barR: document.getElementById('bar-R')
  };
}

function wire() {
  // Masthead reset
  document.addEventListener('sim-reset', resetSim);

  // Main tabs
  els.tabCurves.addEventListener('click', () => setMainTab('curves'));
  els.tabFilters.addEventListener('click', () => setMainTab('filters'));
  wireTablist(document.querySelector('.tab-panel .tabs'), (t) =>
    setMainTab(t.id === 'tab-curves' ? 'curves' : 'filters'),
    [els.tabCurves, els.tabFilters]);

  // Scale tabs
  els.tabVscale.addEventListener('click', () => setScaleTab('vertical'));
  els.tabHscale.addEventListener('click', () => setScaleTab('horizontal'));
  const scaleTabs = document.querySelectorAll('.tab-panel .tabs')[1];
  wireTablist(scaleTabs, (t) =>
    setScaleTab(t.id === 'tab-vscale' ? 'vertical' : 'horizontal'),
    [els.tabVscale, els.tabHscale]);

  // Temperature slider (input = live redraw; change = commit announce)
  els.tempSlider.addEventListener('input', () => {
    const v = tempPosToValue(parseFloat(els.tempSlider.value));
    els.tempInput.value = String(v);
    els.tempSlider.setAttribute('aria-valuetext', `Temperature ${v} kelvin`);
    setTemperature(v, false);
    renderCurvesList();
  });
  els.tempSlider.addEventListener('change', () => announce(selectedSpoken()));

  // Temperature text field (direct entry)
  els.tempInput.addEventListener('change', () => {
    let v = parseFloat(els.tempInput.value);
    if (!isFinite(v)) { syncTemperatureControls(); return; }
    v = clamp(sigDigits(v, T_SIGFIGS), T_MIN, T_MAX);
    state.temperature = v;
    if (state.selected) state.selected.temp = v;
    syncTemperatureControls();
    recomputeScale();
    render(); renderCurvesList();
    announce(selectedSpoken());
  });

  // Checkboxes
  els.chkArea.addEventListener('change', () => {
    state.showArea = els.chkArea.checked;
    render();
    announce(`Area under curve ${state.showArea ? 'highlighted' : 'not highlighted'}.`);
  });
  els.chkPeak.addEventListener('change', () => {
    state.showPeak = els.chkPeak.checked;
    lastTickSig = '';           // force overlay rebuild
    render();
    announce(`Peak wavelength indicator ${state.showPeak ? 'shown' : 'hidden'}.`);
  });

  // Add / remove
  els.btnAdd.addEventListener('click', () => { addCurve(false); renderCurvesList(); });
  els.btnRemove.addEventListener('click', () => { removeCurve(); renderCurvesList(); });

  // Scale mode radios (unique names -> each is its own Tab stop; JS enforces
  // that only one is checked at a time)
  const scaleRadios = document.querySelectorAll('.scale-mode');
  scaleRadios.forEach(r => {
    r.addEventListener('change', () => {
      if (!r.checked) return;
      scaleRadios.forEach(o => { if (o !== r) o.checked = false; });
      state.scaleMode = r.value;
      recomputeScale();
      render();
      const labels = { locked: 'Locked scale', all: 'Autoscale to all curves', selected: 'Autoscale to selected curve' };
      announce('Vertical scale: ' + labels[r.value] + '.');
    });
  });

  // Horizontal-scale slider
  els.hscaleSlider.addEventListener('input', () => {
    const nm = hPosToValue(parseFloat(els.hscaleSlider.value));
    setHScale(nm, false);
  });
  els.hscaleSlider.addEventListener('change', () => {
    const nm = hPosToValue(parseFloat(els.hscaleSlider.value));
    announce(`Rightmost wavelength limit ${hMicronText(nm)}, ${nm} nanometers.`);
  });

  // Color-index selects
  els.ciMin.addEventListener('change', () => {
    state.ciMinuend = els.ciMin.value; updateColorIndex();
    announce(`Color index ${state.ciMinuend} minus ${state.ciSubtrahend}, ${colorIndexValue()}.`);
  });
  els.ciSub.addEventListener('change', () => {
    state.ciSubtrahend = els.ciSub.value; updateColorIndex();
    announce(`Color index ${state.ciMinuend} minus ${state.ciSubtrahend}, ${colorIndexValue()}.`);
  });

  // Re-crisp canvas on resize / DPR change
  window.addEventListener('resize', () => { setupCanvas(); drawPlot(); }, { passive: true });
}

function colorIndexValue() {
  const m = state.filterMags; if (!m) return '0.00';
  return (m[state.ciMinuend] - m[state.ciSubtrahend]).toFixed(2);
}

function init() {
  FILTERS = window.BB_FILTERS;
  cache();
  setupCanvas();
  wire();
  // initial state (Blackbody Explorer.init): one curve at default temperature
  addCurve(true);
  syncTemperatureControls();
  setMainTab('curves');
  setScaleTab('vertical');
  renderCurvesList();
  render();
  // typeset the static math already in the HTML (axis title, R_sun, operators)
  if (window.MathJax && MathJax.startup && MathJax.startup.promise) {
    MathJax.startup.promise.then(() => { lastTickSig = ''; render(); stripMathTabstops(); });
  }
}

if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', init);
else init();

