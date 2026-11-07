/* ===========================================================================
   Spectroscopic Parallax Simulator  --  HTML5 port
   ---------------------------------------------------------------------------
   Behaviour is a direct port of the decompiled ActionScript 1 of
   spectroParallax013.swf:

     scripts/DefineSprite_164/frame_1/DoAction.as   the simulator controller
     scripts/spectra.as                             the simulated spectrum
     scripts/HR Diagram Component 043.as            the HR diagram component
     scripts/Slider Logic Class v6.as               the magnitude slider

   Every constant, polynomial, table and format below is verbatim from those
   files. Presentation follows the KL-UNL foundation and WCAG 2.1 AA; see
   ACCESSIBILITY.md and CONVERSION_NOTES.md.
   =========================================================================== */

'use strict';

/* ===========================================================================
   1. CONSTANTS FROM THE ACTIONSCRIPT SOURCE
   =========================================================================== */

/* The controller's plot geometry (DoAction.as, init()). The spectral-type axis
   runs from x = 58 to x = 58 + 350 in original stage coordinates, one tick per
   spectral subtype, 70 subtypes in all. */
const X_START = 58;
const X_WIDTH = 350;
const X_INC   = X_WIDTH / 70;          // 5 stage units per subtype
const NUM_ST_MAX = 69;
const INITIAL_CURSOR_X = 268;          // init(): setCursorPosition(268) -> G2

/* Math.log(10); the AS source spells this constant out everywhere. */
const LN10 = 2.302585092994046;

/* Line-family descriptions, one per spectral subtype 0..69.
   Verbatim from spectralClassUpdate(). */
const LINE_DESCRIPTIONS = [
  "very strong ionized helium, moderate helium lines",
  "very strong ionized helium, moderate helium lines",
  "very strong ionized helium, moderate helium lines",
  "strong ionized helium, moderate helium lines",
  "strong ionized helium, strong helium lines",
  "strong ionized helium, strong helium lines",
  "moderate ionized helium, very strong helium lines",
  "moderate ionized helium, very strong helium lines",
  "weak ionized helium, very strong helium lines",
  "very weak ionized helium, very strong helium, very weak hydrogen lines",
  "very strong helium, very weak hydrogen lines",
  "very strong helium, weak hydrogen lines",
  "very strong helium, weak hydrogen lines",
  "very strong helium, moderate hydrogen lines",
  "strong helium, moderate hydrogen lines",
  "strong helium, moderate hydrogen lines",
  "moderate helium, moderate hydrogen lines",
  "moderate helium, moderate hydrogen lines",
  "moderate helium, strong hydrogen, very weak ionized metal lines",
  "weak helium, strong hydrogen, very weak ionized metal lines",
  "very weak helium, very strong hydrogen, weak ionized metal lines",
  "very weak helium, very strong hydrogen, weak ionized metal lines",
  "very strong hydrogen, weak ionized metal lines",
  "very strong hydrogen, weak ionized metal lines",
  "strong hydrogen, moderate ionized metal lines",
  "strong hydrogen, moderate ionized metal lines",
  "strong hydrogen, moderate ionized metal lines",
  "strong hydrogen, moderate ionized metal lines",
  "moderate hydrogen, moderate ionized metal lines",
  "moderate hydrogen, strong ionized metal lines",
  "moderate hydrogen, strong ionized metal lines",
  "moderate hydrogen, strong ionized metal lines",
  "moderate hydrogen, strong ionized metal, very weak neutral metal lines",
  "moderate hydrogen, strong ionized metal, very weak neutral metal lines",
  "moderate hydrogen, strong ionized metal, weak neutral metal lines",
  "moderate hydrogen, very strong ionized metal, weak neutral metal lines",
  "moderate hydrogen, very strong ionized metal, weak neutral metal lines",
  "moderate hydrogen, very strong ionized metal, weak neutral metal lines",
  "weak hydrogen, very strong ionized metal, weak neutral metal lines",
  "weak hydrogen, very strong ionized metal, weak neutral metal lines",
  "weak hydrogen, very strong ionized metal, moderate neutral metal lines",
  "weak hydrogen, very strong ionized metal, moderate neutral metal lines",
  "weak hydrogen, strong ionized metal, moderate neutral metal lines",
  "weak hydrogen, strong ionized metal, moderate neutral metal lines",
  "weak hydrogen, strong ionized metal, strong neutral metal lines",
  "weak hydrogen, strong ionized metal, strong neutral metal lines",
  "weak hydrogen, strong ionized metal, strong neutral metal lines",
  "weak hydrogen, moderate ionized metal, very strong neutral metal lines",
  "weak hydrogen, moderate ionized metal, very strong neutral metal lines",
  "very weak hydrogen, moderate ionized metal, very strong neutral metal lines",
  "very weak hydrogen, weak ionized metal, very strong neutral metal lines",
  "very weak hydrogen, weak ionized metal, very strong neutral metal lines",
  "very weak ionized metal, very strong neutral metal lines",
  "very weak ionized metal, very strong neutral metal lines",
  "very weak ionized metal, strong neutral metal lines",
  "strong neutral metal lines",
  "strong neutral metal, very weak molecular lines",
  "moderate neutral metal, weak molecular lines",
  "moderate neutral metal, weak molecular lines",
  "weak neutral metal, weak molecular lines",
  "weak neutral metal, weak molecular lines",
  "very weak neutral metal, moderate molecular lines",
  "very weak neutral metal, moderate molecular lines",
  "moderate molecular lines",
  "moderate molecular lines",
  "strong molecular lines",
  "strong molecular lines",
  "very strong molecular lines",
  "very strong molecular lines",
  "very strong molecular lines"
];

/* Rest wavelengths in nm, verbatim from createArrays(). */
const WAVELENGTHS = {
  ionizedHelium: [433.9, 454.2, 468.6],
  helium:        [402.6, 438.8, 447.1, 706.5],
  hydrogen:      [397, 410.1, 434, 486.1, 656.3],
  ionizedMetals: [393.3, 396.8, 407.7, 417.5, 421.5, 423.3, 424.6, 426.7, 430, 444.4, 448.1],
  metals:        [403.2, 404.5, 432.5, 422.6, 589],
  molecules:     [421.5, 430, 458.4, 462.5, 467, 469.7, 467, 478]
};

/* HR diagram component geometry. plotWidth / plotHeight come from
   setDimensions(this._width, this._height): the 301 x 351 placeholder scaled by
   the component's placement matrix (0.9833374, 0.9142914). */
const HR_PLOT_W = 301 * 0.9833374;      // 295.9845574
const HR_PLOT_H = 351 * 0.9142914;      // 320.9162814

/* setXAxisType("logTemp") / setYAxisType("logLum") with no explicit range. */
const HR_Y_MIN = -5;
const HR_Y_MAX = 6;

/* Temperature tick labels, verbatim from drawTemperatureScale(). */
const HR_TEMP_TICKS = ["50000", "25000", "10000", "5000", "2500"];

/* Canvas colours, straight from the component's own settings. Text colours that
   had to be darkened for contrast live in styles/styles.css instead, so the
   whole accessible palette sits in one place; see ACCESSIBILITY.md. */
const COLOR = {
  // initLuminosityClassCurvesColor = 16737894 = #ff6666, which is only 2.86:1
  // against the white plot background. Darkened to the same light red at 3.81:1
  // so the class tracks meet WCAG 1.4.11 for graphical objects.
  luminosityCurves: '#e84a4a',
  border:           '#000000',   // initBorderAndScalesColor = 0
  background:       '#ffffff',   // initBackgroundColor = 16777215
  dot:              '#000000'    // dotColor 0, dotSize 6
};

/* ===========================================================================
   2. PHYSICS AND CONVERSION FUNCTIONS (HR Diagram Component 043.as)
   Piecewise cubics, reproduced exactly.
   =========================================================================== */

// log10(T_eff) from spectral type number (O0 = 0 ... M9 = 69)
function getLogTempFromType(x) {
  if (x < 8.5167)  return 4.7009    + x * (-0.01     + x * (0.0000392   + x * -0.00014247));
  if (x < 16.1)    return 4.4348    + x * (0.08374   + x * (-0.010967   + x * 0.000288299));
  if (x < 23.2167) return 6.0516    + x * (-0.21754  + x * (0.007746    + x * -0.000099133));
  if (x < 34.1833) return 5.0538    + x * (-0.08861  + x * (0.0021924   + x * -0.000019396));
  if (x < 50.5108) return 4.7553    + x * (-0.06241  + x * (0.0014259   + x * -0.000011922));
  if (x < 57.9775) return 1.1584    + x * (0.15122   + x * (-0.0028034  + x * 0.000015988));
  if (x < 64.3942) return 26.4612   + x * (-1.15805  + x * (0.019779    + x * -0.000113846));
  return              -115.7858     + x * (5.46896   + x * (-0.0831343  + x * 0.000418879));
}

// Bolometric correction BC from log10(T_eff)
function getBCFromLogTemp(x) {
  if (x < 3.588)   return -1873.0763 + x * (1364.8081 + x * (-328.11949 + x * 25.958485));
  if (x < 3.6978)  return -4208.8678 + x * (3317.811  + x * (-872.43468 + x * 76.5266));
  if (x < 3.7957)  return -2920.8124 + x * (2272.8215 + x * (-589.83737 + x * 51.052264));
  if (x < 3.903)   return  1749.5431 + x * (-1418.5107 + x * (382.67484 + x * -34.353217));
  if (x < 4.1317)  return -2011.2742 + x * (1472.2021 + x * (-357.96384 + x * 28.900577));
  return                    123.5421 + x * (-77.8864  + x * (17.20884   + x * -1.367489));
}

// log10(L / L_sun) on the given luminosity class track, from log10(T_eff)
function getLogLumFromLogTempAndClass(x, lumClass) {
  switch (lumClass) {
    case 1:
      if (x < 4.1476) return 44.8387   + x * (-30.1309 + x * (7.59468   + x * -0.636977));
      return              -459.5864    + x * (334.7205 + x * (-80.37116 + x * 6.432557));
    case 2:
      if (x < 4.0358) return -36.2843  + x * (39.6781  + x * (-12.545   + x * 1.280459));
      return               -37.0612    + x * (40.2556  + x * (-12.68811 + x * 1.292279));
    case 3:
      if (x < 3.9092) return -53.8721  + x * (59.2071  + x * (-19.71611 + x * 2.108195));
      return               161.9073    + x * (-106.3856 + x * (22.64341 + x * -1.503738));
    case 4:
      if (x < 4.1372) return -167.256  + x * (125.271  + x * (-31.96691 + x * 2.804002));
      return                54.567     + x * (-35.5787 + x * (6.91186   + x * -0.328444));
    default:
      if (x < 3.5081) return -4686.707 + x * (4157.5332 + x * (-1232.05177 + x * 121.875554));
      if (x < 3.5799) return 22801.9307 + x * (-19349.4898 + x * (5468.65774 + x * -514.806626));
      if (x < 3.728)  return -9950.2659 + x * (8097.5483 + x * (-2198.40972 + x * 199.100683));
      if (x < 3.8287) return 10594.1896 + x * (-8435.0942 + x * (2236.33537 + x * -197.427256));
      if (x < 3.9156) return -7990.8168 + x * (6127.2576 + x * (-1567.12652 + x * 133.707956));
      if (x < 4.2129) return 277.0365  + x * (-207.2491 + x * (50.62412  + x * -4.009536));
      if (x < 4.6015) return -280.446  + x * (189.7309 + x * (-43.6049  + x * 3.446011));
      return             -9724.5727    + x * (6346.9359 + x * (-1381.69136 + x * 100.377185));
  }
}

// M_bol = 4.75 - 2.51189 * log10(L / L_sun)
function getMagFromLogLum(L) { return 4.75 - 2.51189 * L; }

// M_vis = M_bol - BC
function getAbsVisMagFromLogLum(lum, BC) { return getMagFromLogLum(lum) - (BC === undefined ? 0 : BC); }

/* Spectral type string -> type number, e.g. "G2" -> 42
   (getSpectralTypeNumber, reduced to the two-character strings this sim uses). */
function getSpectralTypeNumber(typeStr) {
  const s = typeStr.toLowerCase();
  const base = { o: 0, b: 10, a: 20, f: 30, g: 40, k: 50, m: 60 }[s.charAt(0)];
  if (base === undefined) return null;
  const digit = parseFloat(s.slice(1));
  if (isNaN(digit)) return base + 5;
  return base + digit;
}

/* d from the distance modulus, getDistanceFromAbsAndApp():
   m - M = -5 + 5 log10(d)  =>  d = 10^((m - M + 5) / 5) */
function getDistanceFromAbsAndApp(absMag, appMag) {
  return Math.pow(10, (appMag - absMag + 5) / 5);
}

/* formatNumber(num, digits) from DoAction.as: round to `digits` significant
   figures, printing either an integer or a fixed-point value. */
function formatNumber(num, digits) {
  const e = Math.floor(Math.log(num) / LN10) - (digits - 1);
  if (e >= 0) {
    const p = Math.pow(10, e);
    return String(p * Math.round(num / p));
  }
  return num.toFixed(-e);
}

/* ===========================================================================
   3. LINE-STRENGTH TABLES (createLineArrays)
   Each entry is a percentage, 0..100, used as the opacity of that family's
   absorption lines at that spectral subtype.
   =========================================================================== */

function createLineArrays() {
  const iHe = [], He = [], H = [], imet = [], met = [], mol = [];
  for (let i = 0; i < 70; i++) iHe[i]  = (i < 8)  ? Math.floor(-12.5 * i + 100) : 0;
  for (let i = 0; i < 70; i++) He[i]   = (i < 8)  ? Math.floor(3.75 * i + 70)
                                      : (i < 21) ? Math.floor(-7.7 * i + 161.7) : 0;
  for (let i = 0; i < 70; i++) H[i]    = (i < 7)  ? 0
                                      : (i < 20) ? Math.floor(7.7 * i - 53.9)
                                      : (i < 54) ? Math.floor(-2.94 * i + 158.7) : 0;
  for (let i = 0; i < 70; i++) imet[i] = (i < 11) ? 0
                                      : (i < 38) ? Math.floor(3.7 * i - 40.7)
                                      : (i < 52) ? Math.floor(-7.14 * i + 371.3) : 0;
  for (let i = 0; i < 70; i++) met[i]  = (i < 30) ? 0
                                      : (i < 49) ? Math.floor(5.26 * i - 157.8)
                                      : (i < 62) ? Math.floor(-7.7 * i + 477.4) : 0;
  for (let i = 0; i < 70; i++) mol[i]  = (i < 50) ? 0 : Math.floor(5.26 * i - 263.16);
  return { iHe, He, H, imet, met, mol };
}

const LINE_STRENGTH = createLineArrays();

/* ===========================================================================
   4. SPECTRUM GEOMETRY (spectra.as)
   =========================================================================== */

/* spectPos(wavelength): position along the 0..255 gradient ramp. */
function spectPos(wavelength) {
  return 255 - (wavelength - 395) * 0.8225806451612904;
}

/* xPos(wavelength): position in the clip's own 0..500 coordinates. */
function spectXPos(wavelength) {
  return spectPos(wavelength) * 1.9607843137254901;
}

/* The clip is placed on stage with a negative x scale, so the canvas is drawn
   left-to-right in screen order: violet at the left, red at the right. */
function spectrumCanvasX(wavelength) {
  return 500 - spectXPos(wavelength);
}

/* The continuous spectrum's gradient (spectraClass constructor). AS colour ints
   converted to CSS hex; ratios are 0..255 across the 500-unit-wide box. */
const SPECTRUM_STOPS = [
  { wl: 700, color: '#ff0000' },   // 16711680
  { wl: 590, color: '#ffa500' },   // 16753920
  { wl: 570, color: '#ffff00' },   // 16776960
  { wl: 510, color: '#00ff00' },   //    65280
  { wl: 475, color: '#00ffff' },   //    65535
  { wl: 445, color: '#0000ff' },   //      255
  { wl: 400, color: '#800080' }    //  8388736
];

/* drawColorLineAt(): the wavelength is truncated to an integer and clamped
   into the 395..705 nm window the gradient covers. */
function clampLineWavelength(wavelength) {
  const w = Math.trunc(wavelength);
  if (w >= 395 && w <= 705) return w;
  if (w < 400) return 400;
  return 700;
}

/* ===========================================================================
   5. SIMULATION STATE  (single source of truth)
   =========================================================================== */

const state = {
  numST: 42,          // spectral subtype index, 0..69   (G2 at start-up)
  cursorX: INITIAL_CURSOR_X,
  lumClass: 5,        // classGroup value: 1..5          (V at start-up)
  lineThickness: 3,   // classChange(): 1, 1.5, 2, 2.5, 3
  appMag: 1,          // magSlider value, -5..15 step 0.1

  // derived, filled in by recompute()
  st: 'G2', temp: 0, tempText: '', logTemp: 0, logLum: 0,
  absM: 0, absMText: '', distText: '', description: ''
};

const INITIAL_STATE = { numST: 42, cursorX: INITIAL_CURSOR_X, lumClass: 5, lineThickness: 3, appMag: 1 };

/* ===========================================================================
   6. DERIVED VALUES  (spectralClassUpdate / classChange)
   =========================================================================== */

const CLASS_LETTERS = ['O', 'B', 'A', 'F', 'G', 'K', 'M'];
const CLASS_NUMERALS = { 1: 'I', 2: 'II', 3: 'III', 4: 'IV', 5: 'V' };
const CLASS_NAMES = {
  1: 'supergiants', 2: 'bright giants', 3: 'giants',
  4: 'subgiants',   5: 'main sequence dwarfs'
};

function recompute() {
  const decade = Math.floor(state.numST / 10);
  const number = state.numST % 10;
  const letter = CLASS_LETTERS[Math.min(decade, 6)];
  state.st = letter + number;

  // T_eff = 10 ^ logTemp(type)
  state.temp = Math.pow(10, getLogTempFromType(getSpectralTypeNumber(state.st)));
  state.tempText = formatNumber(state.temp, 3);
  state.logTemp = Math.log(state.temp) / LN10;
  state.logLum = getLogLumFromLogTempAndClass(state.logTemp, state.lumClass);

  state.absM = getAbsVisMagFromLogLum(state.logLum, getBCFromLogTemp(state.logTemp));
  state.absMText = state.absM.toFixed(1);
  state.distText = formatNumber(getDistanceFromAbsAndApp(state.absM, state.appMag), 3);
  state.description = '(' + LINE_DESCRIPTIONS[state.numST] + ')';
}

/* classChange(): line thickness grows with luminosity class number I..V. */
function lineThicknessForClass(c) {
  return c === 1 ? 1 : c === 2 ? 1.5 : c === 3 ? 2 : c === 4 ? 2.5 : 3;
}

/* ===========================================================================
   7. DOM REFERENCES
   =========================================================================== */

const dom = {};

function cacheDom() {
  const id = (s) => document.getElementById(s);
  dom.stTypeMath   = id('st-type-math');
  dom.stTempMath   = id('st-temp-math');
  dom.lineDesc     = id('line-description');
  dom.linesStage   = id('lines-stage');
  dom.linesTicks   = id('lines-ticks');
  dom.linesCursor  = id('lines-cursor');
  dom.linesXTicks  = id('lines-xticks');
  dom.linesDesc    = id('lines-desc');
  dom.handle       = id('cursor-handle');

  dom.spectrumCanvas = id('spectrum-canvas');
  dom.spectrumDesc   = id('spectrum-desc');

  dom.hrStage   = id('hr-stage');
  dom.hrCanvas  = id('hr-canvas');
  dom.hrPlot    = id('hr-plot');
  dom.hrRegions = id('hr-regions');
  dom.hrLabels  = id('hr-labels');
  dom.hrYTicks  = id('hr-yticks');
  dom.hrXTicks  = id('hr-xticks');
  dom.hrDesc    = id('hr-desc');
  dom.hrYLabel  = id('hr-ylabel-math');
  dom.hrXLabel  = id('hr-xlabel-math');

  dom.dmEqn = id('dm-eqn');
  dom.dmSr  = id('dm-sr');

  dom.magField  = id('mag-field');
  dom.magSlider = id('mag-slider');
  dom.classRadios = Array.from(document.querySelectorAll('input[name="lumclass"]'));
  dom.attrsType = id('attrs-type-math');
  dom.attrsTemp = id('attrs-temp-math');

  dom.srStatus = id('sr-status');
}

/* ===========================================================================
   8. MATHJAX HELPERS
   Every mathematical symbol in the interface is typeset by MathJax so that the
   MathJax contextual menu is available on all of it. Typesetting is coalesced
   into one animation frame so dragging stays smooth.
   =========================================================================== */

let typesetQueue = new Set();
let typesetScheduled = false;
let typesetRunning = false;

/* Coalesced with setTimeout rather than requestAnimationFrame: rAF does not run
   while the page is hidden or in a background tab, which would leave raw TeX on
   screen when the user came back. */
function queueTypeset(el) {
  if (!el) return;
  typesetQueue.add(el);
  if (typesetScheduled) return;
  typesetScheduled = true;
  setTimeout(runTypeset, 0);
}

function runTypeset() {
  typesetScheduled = false;
  if (!window.MathJax || !window.MathJax.typesetPromise) {
    // MathJax has not finished loading yet; try again shortly.
    if (typesetQueue.size) { typesetScheduled = true; setTimeout(runTypeset, 50); }
    return;
  }
  if (typesetRunning) { typesetScheduled = true; setTimeout(runTypeset, 16); return; }
  const batch = Array.from(typesetQueue);
  typesetQueue.clear();
  if (!batch.length) return;
  typesetRunning = true;
  window.MathJax.typesetPromise(batch)
    .catch((err) => console.error(err))
    .then(() => {
      typesetRunning = false;
      // Typeset output must never become a tab stop (display-only content).
      batch.forEach(untabMath);
    });
}

/* MathJax v3 does not add tabindex, but some configurations leave the SVG
   focusable. Remove any typeset output from the tab order explicitly. */
function untabMath(root) {
  root.querySelectorAll('mjx-container, mjx-container svg').forEach((el) => {
    el.setAttribute('tabindex', '-1');
  });
}

function setMath(el, tex) {
  if (!el) return;
  const next = '\\(' + tex + '\\)';
  if (el.dataset.rendered === next) return;
  el.dataset.rendered = next;
  el.textContent = next;
  queueTypeset(el);
}

/* Typeset every static \(...\) placeholder that carries a data-tex attribute. */
function initStaticMath(root) {
  root.querySelectorAll('[data-tex]').forEach((el) => setMath(el, el.dataset.tex));
}

/* ===========================================================================
   9. ABSORPTION LINE INTENSITIES PANEL
   =========================================================================== */

/* Stage viewBox of the artwork, kept in original Flash stage coordinates. */
const LINES_VIEW = { x: 50, y: 96, w: 368, h: 210 };

function buildLinesTicks() {
  const NS = 'http://www.w3.org/2000/svg';
  // Seven copies of the exported tick-mark group (Symbol 141), one per decade,
  // at the original placement coordinates 80.5, 130.5, ... 380.5 on y = 289.
  for (let i = 0; i < 7; i++) {
    const cx = 80.5 + 50 * i;
    const img = document.createElementNS(NS, 'image');
    img.setAttribute('href', 'assets/absorption-tickmarks.svg');
    img.setAttribute('x', cx - 23.5);
    img.setAttribute('y', 289 - 8.5);
    img.setAttribute('width', 46.5);
    img.setAttribute('height', 17);
    img.setAttribute('preserveAspectRatio', 'none');
    dom.linesTicks.appendChild(img);
  }
}

function layoutLinesOverlays() {
  const pct = (v, min, span) => ((v - min) / span) * 100;
  dom.linesStage.querySelectorAll('.sp-curve-label').forEach((el) => {
    el.style.left = pct(parseFloat(el.dataset.x), LINES_VIEW.x, LINES_VIEW.w) + '%';
    el.style.top  = pct(parseFloat(el.dataset.y), LINES_VIEW.y, LINES_VIEW.h) + '%';
  });
  dom.linesXTicks.querySelectorAll('.sp-xtick').forEach((el) => {
    el.style.left = pct(parseFloat(el.dataset.x), LINES_VIEW.x, LINES_VIEW.w) + '%';
  });
}

function renderLines() {
  // The cursor's placement matrix from the original, with only tx changing.
  dom.linesCursor.setAttribute(
    'transform',
    'matrix(0,0.7069092,-0.6000061,0,' + state.cursorX + ',199.5)'
  );
  const left = ((state.cursorX - LINES_VIEW.x) / LINES_VIEW.w) * 100;
  dom.handle.style.left = left + '%';

  dom.handle.setAttribute('aria-valuenow', String(state.numST));
  dom.handle.setAttribute('aria-valuetext', spokenTypeAndTemp());

  setMath(dom.stTypeMath, '\\mathrm{' + state.st + '}');
  setMath(dom.stTempMath, state.tempText + '\\;\\mathrm{K}');
  dom.lineDesc.textContent = state.description;

  dom.linesDesc.textContent =
    'Line strength plot. Six curves show how the strength of ionized helium, ' +
    'neutral helium, hydrogen, ionized metal, neutral metal and molecular ' +
    'absorption lines varies across the spectral sequence from O at the left to ' +
    'M at the right. A red cursor marks the selected spectral type, ' +
    spokenTypeAndTemp() + '. At this type the spectrum shows ' +
    LINE_DESCRIPTIONS[state.numST] + '.';
}

function spokenTypeAndTemp() {
  return 'spectral type ' + state.st.charAt(0) + ' ' + state.st.charAt(1) +
         ', temperature ' + state.tempText + ' kelvin';
}

/* setCursorPosition(newX) -- identical snapping to the ActionScript. */
function setCursorPosition(newX) {
  let n = Math.floor((newX - X_START + 0.5 * X_INC) / X_INC);
  if (n < 0) n = 0;
  if (n > NUM_ST_MAX) n = NUM_ST_MAX;
  state.numST = n;
  state.cursorX = n * X_INC + X_START;
}

function setSubtype(n) {
  const clamped = Math.max(0, Math.min(NUM_ST_MAX, n));
  state.numST = clamped;
  state.cursorX = clamped * X_INC + X_START;
}

/* ===========================================================================
   10. SIMULATED SPECTRUM PANEL  (makeSpectrum / createArrays / drawColorSet)
   =========================================================================== */

function renderSpectrum() {
  const canvas = dom.spectrumCanvas;
  const dpr = window.devicePixelRatio || 1;
  const w = 500, h = 50;
  if (canvas.width !== Math.round(w * dpr)) {
    canvas.width = Math.round(w * dpr);
    canvas.height = Math.round(h * dpr);
  }
  const ctx = canvas.getContext('2d');
  ctx.setTransform(dpr, 0, 0, dpr, 0, 0);
  ctx.clearRect(0, 0, w, h);

  // drawContinuous(): the seven-stop linear gradient across the 500-unit box.
  const grad = ctx.createLinearGradient(0, 0, w, 0);
  const stops = SPECTRUM_STOPS
    .map((s) => ({ pos: spectrumCanvasX(s.wl) / w, color: s.color }))
    .sort((a, b) => a.pos - b.pos);
  stops.forEach((s) => grad.addColorStop(Math.max(0, Math.min(1, s.pos)), s.color));
  ctx.fillStyle = grad;
  ctx.fillRect(0, 0, w, h);

  // createArrays() + drawColorSet(): one line per rest wavelength, its opacity
  // taken from that family's line-strength table, drawn only when > 10.
  const families = [
    { list: WAVELENGTHS.ionizedHelium, table: LINE_STRENGTH.iHe },
    { list: WAVELENGTHS.helium,        table: LINE_STRENGTH.He },
    { list: WAVELENGTHS.hydrogen,      table: LINE_STRENGTH.H },
    { list: WAVELENGTHS.ionizedMetals, table: LINE_STRENGTH.imet },
    { list: WAVELENGTHS.metals,        table: LINE_STRENGTH.met },
    { list: WAVELENGTHS.molecules,     table: LINE_STRENGTH.mol }
  ];

  ctx.lineWidth = state.lineThickness;
  ctx.strokeStyle = '#000000';           // emission off: colorArray.push(0)
  ctx.lineCap = 'butt';
  families.forEach((f) => {
    const alpha = f.table[state.numST];
    if (!(alpha > 10)) return;
    ctx.globalAlpha = alpha / 100;
    f.list.forEach((wl) => {
      const x = spectrumCanvasX(clampLineWavelength(wl));
      ctx.beginPath();
      ctx.moveTo(x, 0);
      ctx.lineTo(x, h);
      ctx.stroke();
    });
  });
  ctx.globalAlpha = 1;

  dom.spectrumDesc.textContent =
    'Simulated spectrum of the selected star: a continuous rainbow band running ' +
    'from 400 nanometres, violet, at the left to 700 nanometres, red, at the ' +
    'right, crossed by dark absorption lines. ' + describeVisibleLines() +
    ' The lines are drawn more thickly for the more luminous classes; this star ' +
    'is luminosity class ' + CLASS_NUMERALS[state.lumClass] + ', ' +
    CLASS_NAMES[state.lumClass] + '.';
}

function describeVisibleLines() {
  const named = [
    ['ionized helium', LINE_STRENGTH.iHe],
    ['neutral helium', LINE_STRENGTH.He],
    ['hydrogen', LINE_STRENGTH.H],
    ['ionized metal', LINE_STRENGTH.imet],
    ['neutral metal', LINE_STRENGTH.met],
    ['molecular', LINE_STRENGTH.mol]
  ].filter(([, table]) => table[state.numST] > 10)
   .map(([name, table]) => name + ' at ' + table[state.numST] + ' percent strength');
  if (!named.length) return 'No absorption lines are strong enough to be drawn.';
  return 'Lines shown: ' + named.join(', ') + '.';
}

/* ===========================================================================
   11. HR DIAGRAM PANEL
   =========================================================================== */

/* Axis limits: setXAxisType("logTemp") uses the spectral-type endpoints. */
const HR_X_MIN = getLogTempFromType(70);
const HR_X_MAX = getLogTempFromType(0);
const HR_X_SCALE = HR_PLOT_W / (HR_X_MAX - HR_X_MIN);
const HR_Y_SCALE = -HR_PLOT_H / (HR_Y_MAX - HR_Y_MIN);

/* The x axis runs hot-to-cool, so it is mirrored (getX in the component). */
function hrX(logTemp) { return HR_PLOT_W - (logTemp - HR_X_MIN) * HR_X_SCALE; }
function hrY(logLum)  { return (logLum - HR_Y_MIN) * HR_Y_SCALE; }

/* Canvas viewport: the plot area plus room for the tick marks that the
   component draws just outside it. */
const HR_VIEW = { x0: -8, y0: -322, w: 305, h: 330 };

/* Luminosity class curves: the log10(T) span each track is drawn over,
   verbatim from updateLuminosityClassLines(). */
const HR_CLASS_TRACKS = [
  { lumClass: 1, minLogT: 3.39,  maxLogT: 4.65 },
  { lumClass: 2, minLogT: 3.39,  maxLogT: 4.45 },
  { lumClass: 3, minLogT: 3.38,  maxLogT: 4.3 },
  { lumClass: 4, minLogT: 3.38,  maxLogT: 4 },
  { lumClass: 5, minLogT: 3.359, maxLogT: 4.701 }
];

/* Position of the exported luminosity-class artwork, from init():
   addObject("Luminosity Classes Overlay", ..., {logTemp: 4.6021, logLum: 6,
   _xscale: ..., _yscale: ...}) */
const HR_OVERLAY = {
  originX: hrX(4.6021),
  originY: hrY(6),
  scaleX: 0.3758787878787879 * HR_X_SCALE / 100,
  scaleY: 2.7027027027027026 * (HR_PLOT_H / (HR_Y_MAX - HR_Y_MIN)) / 100,
  artX: -19.05, artY: 3.35, artW: 367.05, artH: 362.05
};

function layoutHrStatic() {
  const pctX = (x) => ((x - HR_VIEW.x0) / HR_VIEW.w) * 100;
  const pctY = (y) => ((y - HR_VIEW.y0) / HR_VIEW.h) * 100;

  // Plot rectangle inside the stage (the artwork is clipped to it).
  dom.hrPlot.style.left   = pctX(0) + '%';
  dom.hrPlot.style.top    = pctY(-HR_PLOT_H) + '%';
  dom.hrPlot.style.width  = (HR_PLOT_W / HR_VIEW.w) * 100 + '%';
  dom.hrPlot.style.height = (HR_PLOT_H / HR_VIEW.h) * 100 + '%';

  // The exported region artwork, positioned relative to the plot rectangle.
  const ox = HR_OVERLAY.originX + HR_OVERLAY.artX * HR_OVERLAY.scaleX;
  const oy = HR_OVERLAY.originY + HR_OVERLAY.artY * HR_OVERLAY.scaleY;
  dom.hrRegions.style.left   = (ox / HR_PLOT_W) * 100 + '%';
  dom.hrRegions.style.top    = ((oy + HR_PLOT_H) / HR_PLOT_H) * 100 + '%';
  dom.hrRegions.style.width  = (HR_OVERLAY.artW * HR_OVERLAY.scaleX / HR_PLOT_W) * 100 + '%';
  dom.hrRegions.style.height = (HR_OVERLAY.artH * HR_OVERLAY.scaleY / HR_PLOT_H) * 100 + '%';

  // Region labels, at their original positions inside the artwork.
  dom.hrLabels.querySelectorAll('.sp-hr-label').forEach((el) => {
    const x = parseFloat(el.dataset.x);
    const y = parseFloat(el.dataset.y);
    el.style.left = (x / HR_PLOT_W) * 100 + '%';
    el.style.top  = ((y + HR_PLOT_H) / HR_PLOT_H) * 100 + '%';
  });

  // Luminosity tick labels, 10^6 down to 10^-5 (logLumLabelMultiple = 1).
  dom.hrYTicks.textContent = '';
  for (let n = HR_Y_MAX; n >= HR_Y_MIN; n--) {
    const span = document.createElement('span');
    span.className = 'sp-math sp-ytick';
    span.style.top = pctY(hrY(n)) + '%';
    dom.hrYTicks.appendChild(span);
    setMath(span, '10^{' + n + '}');
  }

  // Temperature tick labels.
  dom.hrXTicks.textContent = '';
  HR_TEMP_TICKS.forEach((t) => {
    const span = document.createElement('span');
    span.className = 'sp-math sp-hr-xtick';
    span.style.left = pctX(hrX(Math.log(parseFloat(t)) / LN10)) + '%';
    dom.hrXTicks.appendChild(span);
    setMath(span, t);
  });

  setMath(dom.hrYLabel, '(L_{\\odot})');
  setMath(dom.hrXLabel, '(\\mathrm{K})');
}

function renderHr() {
  const canvas = dom.hrCanvas;
  const dpr = window.devicePixelRatio || 1;
  const w = HR_VIEW.w, h = HR_VIEW.h;
  if (canvas.width !== Math.round(w * dpr)) {
    canvas.width = Math.round(w * dpr);
    canvas.height = Math.round(h * dpr);
  }
  const ctx = canvas.getContext('2d');
  // Draw in the component's own coordinates: x right from the plot's left edge,
  // y negative upwards from the plot's baseline.
  ctx.setTransform(dpr, 0, 0, dpr, -HR_VIEW.x0 * dpr, -HR_VIEW.y0 * dpr);
  ctx.clearRect(HR_VIEW.x0, HR_VIEW.y0, w, h);

  // updateBackgroundAndBorder(): white fill, black 1px border.
  ctx.fillStyle = COLOR.background;
  ctx.fillRect(0, -HR_PLOT_H, HR_PLOT_W, HR_PLOT_H);

  // updateLuminosityClassLines(): 100 segments across the axis for each class.
  ctx.save();
  ctx.beginPath();
  ctx.rect(0, -HR_PLOT_H, HR_PLOT_W, HR_PLOT_H);
  ctx.clip();
  ctx.strokeStyle = COLOR.luminosityCurves;
  ctx.lineWidth = 1;
  const steps = 100;
  const dx = (HR_X_MAX - HR_X_MIN) / steps;
  HR_CLASS_TRACKS.forEach((track) => {
    ctx.beginPath();
    let started = false;
    for (let i = 0; i <= steps; i++) {
      const logT = HR_X_MIN + dx * i;
      const yv = hrY(getLogLumFromLogTempAndClass(logT, track.lumClass));
      const xv = hrX(logT);
      if (logT < track.minLogT || logT > track.maxLogT) { started = false; continue; }
      if (!started) { ctx.moveTo(xv, yv); started = true; } else { ctx.lineTo(xv, yv); }
    }
    ctx.stroke();
  });
  ctx.restore();

  // The star marker: HR Diagram Dot, dotSize 6, dotColor 0.
  const dotX = hrX(state.logTemp);
  const dotY = hrY(state.logLum);
  ctx.save();
  ctx.beginPath();
  ctx.rect(0, -HR_PLOT_H, HR_PLOT_W, HR_PLOT_H);
  ctx.clip();
  ctx.fillStyle = COLOR.dot;
  ctx.beginPath();
  ctx.arc(dotX, dotY, 3, 0, Math.PI * 2);
  ctx.fill();
  ctx.restore();

  // Border and scales.
  ctx.strokeStyle = COLOR.border;
  ctx.lineWidth = 1;
  ctx.strokeRect(0, -HR_PLOT_H, HR_PLOT_W, HR_PLOT_H);

  // drawYScale("left", "LogLum"): major ticks 7 units long at each decade,
  // minor ticks 3 units long at log10(2) .. log10(9) within each decade.
  ctx.beginPath();
  for (let n = Math.floor(HR_Y_MIN); n <= Math.ceil(HR_Y_MAX); n++) {
    const y = hrY(n);
    if (y <= 0 && y >= -HR_PLOT_H) { ctx.moveTo(0, y); ctx.lineTo(-7, y); }
    for (let k = 1; k < 10; k++) {
      const ym = hrY(n + Math.log(k) / LN10);
      if (ym <= 0 && ym >= -HR_PLOT_H) { ctx.moveTo(0, ym); ctx.lineTo(-3, ym); }
    }
  }
  // drawTemperatureScale("bottom"): a 6-unit tick under each labelled value.
  HR_TEMP_TICKS.forEach((t) => {
    const x = hrX(Math.log(parseFloat(t)) / LN10);
    if (x < 0 || x > HR_PLOT_W) return;
    ctx.moveTo(x, 0);
    ctx.lineTo(x, 6);
  });
  ctx.stroke();

  dom.hrDesc.textContent =
    'Hertzsprung Russell diagram. The horizontal axis is surface temperature ' +
    'running from 50000 kelvin at the left down to 2500 kelvin at the right; ' +
    'the vertical axis is luminosity from 10 to the power minus 5 up to 10 to ' +
    'the power 6 solar luminosities. Shaded regions mark the supergiants, the ' +
    'giants, the main sequence dwarfs and the white dwarfs, and five red curves ' +
    'trace luminosity classes one to five. A black dot marks the selected star ' +
    'at temperature ' + state.tempText + ' kelvin and luminosity ' +
    formatNumber(Math.pow(10, state.logLum), 3) + ' solar luminosities, on the ' +
    'luminosity class ' + CLASS_NUMERALS[state.lumClass] + ' track.';
}

/* ===========================================================================
   12. DISTANCE MODULUS PANEL
   =========================================================================== */

/* The calculation is laid out as a two-row CSS grid of separate MathJax
   expressions, so each value sits under the symbol it stands for exactly as in
   the original, and so the colour coding can come from the style sheet
   (MathJax SVG output paints with currentColor). Building it as one \color-ed
   array would need the TeX colour package, which is not in the local bundle. */
const DM_CELLS = [
  { cls: 'sp-dm--mv',   sym: 'm_{v}',            val: () => state.appMag.toFixed(1) },
  { cls: 'sp-dm--op',   sym: '-',                val: () => '-' },
  { cls: 'sp-dm--absm', sym: 'M_{v}',            val: () => state.absMText },
  { cls: 'sp-dm--op',   sym: '=',                val: () => '=' },
  { cls: 'sp-dm--rhs',  sym: '-5 + 5\\log_{10}', val: () => '-5 + 5\\log_{10}' },
  { cls: 'sp-dm--d',    sym: 'd',                val: () => state.distText }
];

function renderDistanceModulus() {
  const tex = DM_CELLS.map((c) => c.val()).join('|');

  const spoken =
    'Distance modulus. Apparent visual magnitude m sub v minus absolute visual ' +
    'magnitude M sub v equals minus 5 plus 5 times the base ten logarithm of the ' +
    'distance d in parsecs. Apparent magnitude ' + state.appMag.toFixed(1) +
    ' minus absolute magnitude ' + state.absMText + ' gives a distance of ' +
    state.distText + ' parsecs.';

  if (dom.dmEqn.dataset.rendered === tex) return;
  dom.dmEqn.dataset.rendered = tex;

  const html = DM_CELLS.map((c) =>
    '<span class="sp-dm__cell ' + c.cls + '">\\(' + c.sym + '\\)</span>').join('') +
    DM_CELLS.map((c) =>
    '<span class="sp-dm__cell ' + c.cls + '">\\(' + c.val() + '\\)</span>').join('');

  klunlShowEquation(['dm-eqn', html], ['dm-sr', spoken]);
  // klunlShowEquation typesets asynchronously; keep the output out of the tab
  // order once MathJax has finished with it.
  setTimeout(() => untabMath(dom.dmEqn), 0);
}

/* ===========================================================================
   13. STAR ATTRIBUTES PANEL
   =========================================================================== */

function renderAttributes() {
  const text = state.appMag.toFixed(1);
  if (document.activeElement !== dom.magField) dom.magField.value = text;
  dom.magSlider.value = String(state.appMag);
  dom.magSlider.setAttribute('aria-valuetext', 'apparent magnitude ' + text);

  dom.classRadios.forEach((r) => { r.checked = Number(r.value) === state.lumClass; });

  setMath(dom.attrsType, '\\mathrm{' + state.st + '}');
  setMath(dom.attrsTemp, state.tempText + '\\;\\mathrm{K}');
}

/* ===========================================================================
   14. RENDER  (single pass; everything is redrawn from state)
   =========================================================================== */

function render() {
  recompute();
  renderLines();
  renderSpectrum();
  renderHr();
  renderDistanceModulus();
  renderAttributes();
}

/* The live region is updated only when a change has settled, so dragging or
   holding an arrow key does not flood the screen reader. */
let announceTimer = null;
function announce() {
  if (announceTimer) clearTimeout(announceTimer);
  announceTimer = setTimeout(() => {
    dom.srStatus.textContent =
      'Spectral type ' + state.st.charAt(0) + ' ' + state.st.charAt(1) +
      ', temperature ' + state.tempText + ' kelvin, luminosity class ' +
      CLASS_NUMERALS[state.lumClass] + ', ' + CLASS_NAMES[state.lumClass] +
      '. Apparent magnitude ' + state.appMag.toFixed(1) +
      ', absolute magnitude ' + state.absMText +
      ', distance ' + state.distText + ' parsecs.';
  }, 250);
}

function update() { render(); announce(); }

/* ===========================================================================
   15. INPUT: the spectral-type cursor
   Pointer dragging keeps the original grab offset and snapping; the keyboard
   path moves the same state by whole subtypes.
   =========================================================================== */

let dragPointerId = null;
let dragOffset = 0;

/* Map a pointer event to the stage's own coordinate system, so the drag maths
   matches the ActionScript at any display size. */
function stageXFromEvent(evt) {
  const rect = dom.linesStage.getBoundingClientRect();
  return LINES_VIEW.x + ((evt.clientX - rect.left) / rect.width) * LINES_VIEW.w;
}

function initCursorInput() {
  const handle = dom.handle;

  // onPress: remember the offset between the cursor and the pointer.
  handle.addEventListener('pointerdown', (evt) => {
    if (dragPointerId !== null) return;
    dragPointerId = evt.pointerId;
    dragOffset = state.cursorX - stageXFromEvent(evt);
    handle.setPointerCapture(evt.pointerId);
    handle.focus();                       // click to focus, then use arrow keys
    evt.preventDefault();
  });

  // onMouseMove: setCursorPosition(xOffset + _xmouse)
  handle.addEventListener('pointermove', (evt) => {
    if (evt.pointerId !== dragPointerId) return;
    setCursorPosition(dragOffset + stageXFromEvent(evt));
    update();
  });

  const endDrag = (evt) => {
    if (evt.pointerId !== dragPointerId) return;
    dragPointerId = null;
    if (handle.hasPointerCapture(evt.pointerId)) handle.releasePointerCapture(evt.pointerId);
  };
  handle.addEventListener('pointerup', endDrag);
  handle.addEventListener('pointercancel', endDrag);

  handle.addEventListener('keydown', (evt) => {
    let n = state.numST;
    switch (evt.key) {
      case 'ArrowLeft':  case 'ArrowDown': n -= 1;  break;
      case 'ArrowRight': case 'ArrowUp':   n += 1;  break;
      case 'PageDown':                     n -= 10; break;
      case 'PageUp':                       n += 10; break;
      case 'Home':                         n = 0;   break;
      case 'End':                          n = NUM_ST_MAX; break;
      default: return;
    }
    evt.preventDefault();
    setSubtype(n);
    update();
  });

  // Mouse wheel over the focused cursor steps it one subtype at a time.
  handle.addEventListener('wheel', (evt) => {
    if (document.activeElement !== handle) return;
    evt.preventDefault();
    setSubtype(state.numST + (evt.deltaY > 0 ? 1 : -1));
    update();
  }, { passive: false });
}

/* ===========================================================================
   16. INPUT: apparent magnitude and luminosity class
   =========================================================================== */

/* The original slider quantises to its minimum increment, 10^-precision = 0.1,
   and clamps to [-5, 15]  (Slider Logic Class v6, getValueObjectFromValue). */
const MAG_MIN = -5, MAG_MAX = 15, MAG_STEP = 0.1;

function setAppMag(value) {
  let x = value;
  if (!isFinite(x) || isNaN(x)) return;
  if (x < MAG_MIN) x = MAG_MIN;
  else if (x > MAG_MAX) x = MAG_MAX;
  state.appMag = MAG_STEP * Math.round(x / MAG_STEP);
}

function initAttributeInput() {
  dom.magSlider.addEventListener('input', () => {
    setAppMag(parseFloat(dom.magSlider.value));
    update();
  });

  dom.magField.addEventListener('input', () => {
    const v = parseFloat(dom.magField.value);
    if (isNaN(v)) return;
    setAppMag(v);
    update();
  });
  dom.magField.addEventListener('change', () => {
    setAppMag(parseFloat(dom.magField.value));
    dom.magField.value = state.appMag.toFixed(1);
    update();
  });
  dom.magField.addEventListener('blur', () => {
    dom.magField.value = state.appMag.toFixed(1);
  });

  // Mouse wheel adjusts the focused number field, matching its arrow keys.
  dom.magField.addEventListener('wheel', (evt) => {
    if (document.activeElement !== dom.magField) return;
    evt.preventDefault();
    setAppMag(state.appMag + (evt.deltaY > 0 ? -MAG_STEP : MAG_STEP));
    dom.magField.value = state.appMag.toFixed(1);
    update();
  }, { passive: false });

  // PageUp / PageDown / Home / End on the number field (arrow keys are native).
  dom.magField.addEventListener('keydown', (evt) => {
    let v = state.appMag;
    switch (evt.key) {
      case 'PageUp':   v += 10 * MAG_STEP; break;
      case 'PageDown': v -= 10 * MAG_STEP; break;
      case 'Home':     v = MAG_MIN; break;
      case 'End':      v = MAG_MAX; break;
      default: return;
    }
    evt.preventDefault();
    setAppMag(v);
    dom.magField.value = state.appMag.toFixed(1);
    update();
  });

  // classChange(): set the class, then recompute the line thickness.
  dom.classRadios.forEach((radio) => {
    radio.addEventListener('change', () => {
      if (!radio.checked) return;
      state.lumClass = Number(radio.value);
      state.lineThickness = lineThicknessForClass(state.lumClass);
      update();
    });
  });
}

/* ===========================================================================
   17. RESET  (onReset in the original: class V, magnitude 1, cursor at G2)
   =========================================================================== */

function onReset() {
  state.numST = INITIAL_STATE.numST;
  state.cursorX = INITIAL_STATE.cursorX;
  state.lumClass = INITIAL_STATE.lumClass;
  state.lineThickness = INITIAL_STATE.lineThickness;
  state.appMag = INITIAL_STATE.appMag;
  dom.magField.value = state.appMag.toFixed(1);
  update();
}

/* ===========================================================================
   18. START-UP
   klunlInitEqn() is the foundation's hook: it is redefined here so the
   simulation is initialised once the page and MathJax are ready.
   =========================================================================== */

function klunlInitEqn() {
  cacheDom();
  buildLinesTicks();
  layoutLinesOverlays();
  layoutHrStatic();
  initStaticMath(document);
  initCursorInput();
  initAttributeInput();

  document.addEventListener('sim-reset', onReset);

  // init(): setCursorPosition(268) then classChange()
  setCursorPosition(INITIAL_CURSOR_X);
  state.lineThickness = lineThicknessForClass(state.lumClass);
  render();

  window.addEventListener('resize', () => { renderHr(); });
}

function boot() {
  // MathJax typesets asynchronously; start once its own start-up has settled so
  // the first paint already shows typeset mathematics rather than raw TeX.
  if (window.MathJax && window.MathJax.startup && window.MathJax.startup.promise) {
    window.MathJax.startup.promise.then(klunlInitEqn).catch(klunlInitEqn);
  } else {
    klunlInitEqn();
  }
}

if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', boot);
} else {
  boot();
}
