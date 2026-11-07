/* =====================================================================
   Melted Nail Demonstration ("Blackbody Curves of Melting") -- HTML5 port
   Behavior ported verbatim from the decompiled Flash sim (meltednail.swf):
     - main frame script  (pause/start/stop/restart/reset state machine,
       temperature-vs-frame formula, peakHeight)
     - "Simple Blackbody" class  (Planck curve, locked + custom vertical
       scaling, visible-spectrum gradient)
   The <canvas> plots and the <video> are the VISUAL layer only; the native
   controls plus the sr-only descriptions / live region are the accessibility
   layer. All physics constants and on-screen text are copied verbatim.
   ===================================================================== */
'use strict';

/* ---------------------------------------------------------------------
   PHYSICS CONSTANTS  (verbatim from Simple Blackbody.redraw / .updateScale)
   Planck form used by the sim:  f(w) = A / ( w^5 * (e^(B/(w*T)) - 1) )
   --------------------------------------------------------------------- */
const A    = 1.1910425859324616e-16;     // Simple Blackbody numerator constant
const B    = 0.014387750559248378;       // hc/k  (second radiation constant, m*K)
const WIEN = 0.0028977682864295084;      // Wien displacement constant, m*K

/* ---------------------------------------------------------------------
   ANIMATION / TEMPERATURE MODEL  (verbatim from frame_1 DoAction.as)
   --------------------------------------------------------------------- */
const MAX_FRAME  = 849;                  // nailMovie._totalframes (frameSlider.maxValue)
const SNAP_FRAME = 429;                  // snapFrame
const FPS        = 20;                   // SWF frame rate
const VIDEO_FRAMES = 847;                // frames actually present in the exported video

// bbPlot (300-800 nm) uses locked vertical scaling with this exact maxBrightness.
const LOCKED_MAX_BRIGHTNESS = 183955504.96;

// temperature(frame) -- exactly as update() computes _loc1_
function tempForFrame(f) {
  let t;
  if (f === 1)                     t = 300;
  else if (f <= SNAP_FRAME)        t = 800 + 1000 / SNAP_FRAME * f;
  else if (f < MAX_FRAME)          t = 1800 - 1000 / (MAX_FRAME - SNAP_FRAME) * (f - SNAP_FRAME);
  else                             t = 300;
  return t;
}
// peakHeight(temperature) -- exactly as update() computes it for bbPlotInset
function peakHeightForTemp(t) {
  return t <= 800 ? 0 : (t - 800) / 1000;
}

/* ---------------------------------------------------------------------
   PLOT GEOMETRY  (internal coordinates; canvases scale via CSS while the
   drawing math stays in these coordinates, so curve shape is resolution
   independent -- the locked/custom scaling is a FRACTION of plot height,
   so the absolute pixel size is free to choose.)
   --------------------------------------------------------------------- */
// Main plot (bbPlot): 300-800 nm, showYAxis=false, visible-spectrum band.
const M = {
  minWav: 3e-7, maxWav: 8e-7,
  // L small so the plot sits close to the "intensity" title; R leaves room for
  // the rightmost "800 nm" label so nothing spills outside the canvas box.
  L: 16, T: 12, R: 30, B: 42,
  W: 374, H: 236,
  get RIGHT() { return this.L + this.W; },
  get BOTTOM() { return this.T + this.H; }
};
const SPECTRUM_H = 8;                     // visible-spectrum band height (px)

// Inset plot (bbPlotInset): 0-10 um, custom peak-height scaling, no spectrum.
const I = {
  minWav: 0, maxWav: 1e-5,
  L: 8, T: 10, R: 8, B: 18,
  W: 144, H: 68,
  get RIGHT() { return this.L + this.W; },
  get BOTTOM() { return this.T + this.H; }
};

/* ---------------------------------------------------------------------
   Visible-spectrum gradient (Simple Blackbody.updateHorizontalAxis)
   colors / alphas(0-100) / ratios(0-255), spanning 400-700 nm.
   --------------------------------------------------------------------- */
const SPEC_COLORS = [0, 255, 65535, 65280, 16776960, 16711680, 0];
const SPEC_ALPHAS = [0, 90, 90, 90, 90, 90, 0];
const SPEC_RATIOS = [0, 48, 96, 128, 160, 207, 255];

/* ---------------------------------------------------------------------
   STATE  (single source of truth; render() redraws everything from it)
   --------------------------------------------------------------------- */
const INITIAL_STATE = { frame: 1, mode: 'atStart' };   // matches resetAnimation()
const state = { frame: 1, mode: 'atStart', temp: 300, peakHeight: 0 };

let els = {};
let video = null;
let mainCtx = null, insetCtx = null, dpr = 1;
let staticLabelsDone = false;

/* =====================================================================
   PHYSICS
   ===================================================================== */
function planck(w, T) {
  if (w <= 0 || T <= 0) return 0;               // w->0 limit of the Planck form is 0
  return A / (Math.pow(w, 5) * (Math.exp(B / (w * T)) - 1));
}
function peakWavelengthM(T) { return WIEN / T; } // Wien's law

/* =====================================================================
   COLOR HELPERS  (AS color ints are decimal RGB; alpha 0-100)
   ===================================================================== */
function intToRgb(n) {
  return '#' + (n & 0xffffff).toString(16).padStart(6, '0');
}
function intToRgba(n, alpha01) {
  const r = (n >> 16) & 0xff, g = (n >> 8) & 0xff, b = n & 0xff;
  return `rgba(${r},${g},${b},${alpha01})`;
}

/* =====================================================================
   CANVAS SETUP
   ===================================================================== */
function setupCanvas(canvas, geomW, geomH) {
  const ctx = canvas.getContext('2d');
  dpr = Math.max(1, window.devicePixelRatio || 1);
  canvas.width  = Math.round(geomW * dpr);
  canvas.height = Math.round(geomH * dpr);
  return ctx;
}

/* =====================================================================
   MAIN PLOT (bbPlot): locked vertical scale over 300-800 nm
   ===================================================================== */
function mainWavToX(w) {
  return M.L + (w - M.minWav) / (M.maxWav - M.minWav) * M.W;
}

function drawMainPlot() {
  const ctx = mainCtx;
  ctx.setTransform(dpr, 0, 0, dpr, 0, 0);
  ctx.clearRect(0, 0, 420, 290);

  // plot background (white, transparent in source -> keep panel white)
  ctx.fillStyle = '#ffffff';
  ctx.fillRect(M.L, M.T, M.W, M.H);

  drawMainSpectrum();
  drawMainAxis();

  // curve, clipped to plot area
  ctx.save();
  ctx.beginPath();
  ctx.rect(M.L, M.T, M.W, M.H);
  ctx.clip();
  drawCurveLocked(state.temp);
  ctx.restore();
}

function drawMainSpectrum() {
  const ctx = mainCtx;
  // Only if 700nm > minWav and 400nm < maxWav (always true for 300-800 nm)
  const x0 = mainWavToX(4e-7), x1 = mainWavToX(7e-7);
  const grad = ctx.createLinearGradient(x0, 0, x1, 0);
  for (let i = 0; i < SPEC_COLORS.length; i++) {
    grad.addColorStop(SPEC_RATIOS[i] / 255, intToRgba(SPEC_COLORS[i], SPEC_ALPHAS[i] / 100));
  }
  ctx.save();
  ctx.beginPath();
  ctx.rect(M.L, M.T, M.W, M.H);
  ctx.clip();
  ctx.fillStyle = grad;
  ctx.fillRect(x0, M.BOTTOM - SPECTRUM_H, x1 - x0, SPECTRUM_H);
  ctx.restore();
}

function drawMainAxis() {
  const ctx = mainCtx;
  ctx.strokeStyle = '#000000';
  ctx.lineWidth = 1;
  ctx.beginPath();
  // y-axis line (intensity)
  ctx.moveTo(M.L + 0.5, M.T);
  ctx.lineTo(M.L + 0.5, M.BOTTOM + 0.5);
  // x-axis line (wavelength)
  ctx.moveTo(M.L, M.BOTTOM + 0.5);
  ctx.lineTo(M.RIGHT, M.BOTTOM + 0.5);
  // major ticks every 100 nm (300..800), minor every 50 nm
  for (let nm = 300; nm <= 800; nm += 50) {
    const x = mainWavToX(nm * 1e-9) + 0.5;
    const major = (nm % 100 === 0);
    ctx.moveTo(x, M.BOTTOM + 0.5);
    ctx.lineTo(x, M.BOTTOM + 0.5 + (major ? 10 : 7));
  }
  ctx.stroke();
}

// Draw the blackbody curve using the LOCKED maxBrightness, with 20% gray fill.
function drawCurveLocked(T) {
  const ctx = mainCtx;
  const yScale = M.H / LOCKED_MAX_BRIGHTNESS;
  const pts = [];
  for (let px = 0; px <= M.W; px++) {
    const w = M.minWav + (px / M.W) * (M.maxWav - M.minWav);
    let y = M.BOTTOM - planck(w, T) * yScale;
    if (y < M.T) y = M.T;                       // clamp to plot top
    pts.push([M.L + px, y]);
  }
  // gray fill under curve (fillColor 0xC0C0C0, fillAlpha 20)
  ctx.beginPath();
  ctx.moveTo(pts[0][0], pts[0][1]);
  for (let i = 1; i < pts.length; i++) ctx.lineTo(pts[i][0], pts[i][1]);
  ctx.lineTo(M.RIGHT, M.BOTTOM);
  ctx.lineTo(M.L, M.BOTTOM);
  ctx.closePath();
  ctx.fillStyle = intToRgba(12632256, 0.20);
  ctx.fill();
  // black curve line on top
  ctx.beginPath();
  ctx.moveTo(pts[0][0], pts[0][1]);
  for (let i = 1; i < pts.length; i++) ctx.lineTo(pts[i][0], pts[i][1]);
  ctx.strokeStyle = '#000000';
  ctx.lineWidth = 1;
  ctx.lineJoin = 'round';
  ctx.stroke();
}

/* =====================================================================
   INSET PLOT (bbPlotInset): custom vertical scale over 0-10 um
   yScale chosen so the curve peak reaches (peakHeight * plotHeight).
   ===================================================================== */
function insetWavToX(w) {
  return I.L + (w - I.minWav) / (I.maxWav - I.minWav) * I.W;
}

function drawInsetPlot() {
  const ctx = insetCtx;
  ctx.setTransform(dpr, 0, 0, dpr, 0, 0);
  ctx.clearRect(0, 0, 160, 96);

  // light inset background + subtle frame (accessibility: legible over the
  // main plot it overlaps; the Flash inset was transparent -- see notes)
  ctx.fillStyle = 'rgba(255,255,255,0.92)';
  ctx.fillRect(I.L, I.T, I.W, I.H);

  // x-axis + short major ticks at 0, 5, 10 um (majorTickmarkExtent 3)
  ctx.strokeStyle = '#000000';
  ctx.lineWidth = 1;
  ctx.beginPath();
  ctx.moveTo(I.L, I.BOTTOM + 0.5);
  ctx.lineTo(I.RIGHT, I.BOTTOM + 0.5);
  for (const um of [0, 5, 10]) {
    const x = insetWavToX(um * 1e-6) + 0.5;
    ctx.moveTo(x, I.BOTTOM + 0.5);
    ctx.lineTo(x, I.BOTTOM + 3.5);
  }
  ctx.stroke();

  // curve, clipped
  ctx.save();
  ctx.beginPath();
  ctx.rect(I.L, I.T, I.W, I.H);
  ctx.clip();
  drawCurveCustom(state.temp, state.peakHeight);
  ctx.restore();

  // frame around inset
  ctx.strokeStyle = 'rgba(0,0,0,0.35)';
  ctx.strokeRect(I.L + 0.5, I.T + 0.5, I.W - 1, I.H - 1);
}

function drawCurveCustom(T, peakHeight) {
  const ctx = insetCtx;
  const wPeak = peakWavelengthM(T);
  const peakBright = planck(wPeak, T);
  // yScale so peak height = peakHeight fraction of plot height (custom mode)
  const yScale = peakBright > 0 ? (I.H * peakHeight) / peakBright : 0;

  const pts = [];
  for (let px = 0; px <= I.W; px++) {
    const w = I.minWav + (px / I.W) * (I.maxWav - I.minWav);
    let y = I.BOTTOM - planck(w, T) * yScale;
    if (y < I.T) y = I.T;
    pts.push([I.L + px, y]);
  }
  ctx.beginPath();
  ctx.moveTo(pts[0][0], pts[0][1]);
  for (let i = 1; i < pts.length; i++) ctx.lineTo(pts[i][0], pts[i][1]);
  ctx.lineTo(I.RIGHT, I.BOTTOM);
  ctx.lineTo(I.L, I.BOTTOM);
  ctx.closePath();
  ctx.fillStyle = intToRgba(12632256, 0.20);
  ctx.fill();

  ctx.beginPath();
  ctx.moveTo(pts[0][0], pts[0][1]);
  for (let i = 1; i < pts.length; i++) ctx.lineTo(pts[i][0], pts[i][1]);
  ctx.strokeStyle = '#000000';
  ctx.lineWidth = 1;
  ctx.lineJoin = 'round';
  ctx.stroke();
}

/* =====================================================================
   STATIC MATHJAX LABELS  (typeset once; HTML so they zoom & are readable
   by the MathJax "Show Math As" menu on right-click)
   ===================================================================== */
function pct(v, total) { return (v / total * 100) + '%'; }

function buildStaticLabels() {
  // Main x-axis labels: 300..800 nm
  let html = '';
  for (let nm = 300; nm <= 800; nm += 100) {
    const x = mainWavToX(nm * 1e-9);
    html += `<span class="tick tick--x" style="left:${pct(x, 420)};top:${pct(M.BOTTOM + 12, 290)}">` +
            `\\(${nm}\\ \\mathrm{nm}\\)</span>`;
  }
  els.overlay.innerHTML = html;

  // Inset x-axis labels: 0, 5, 10 um
  let ih = '';
  const insetLabels = [[0, '0'], [5, '5'], [10, '10']];
  for (const [um, txt] of insetLabels) {
    const x = insetWavToX(um * 1e-6);
    ih += `<span class="tick tick--inset" style="left:${pct(x, 160)};top:${pct(I.BOTTOM + 4, 96)}">` +
          `\\(${txt}\\ \\mathrm{\\mu m}\\)</span>`;
  }
  els.insetOverlay.innerHTML = ih;

  typeset(els.overlay);
  typeset(els.insetOverlay);
  staticLabelsDone = true;
}

/* =====================================================================
   MATHJAX HELPERS  (batched via a microtask so rapid updates coalesce;
   read-only math is stripped from the Tab order)
   ===================================================================== */
let mjQueue = new Set(), mjScheduled = false;
function typeset(el) {
  if (!el) return;
  mjQueue.add(el);
  if (mjScheduled) return;
  mjScheduled = true;
  setTimeout(flushTypeset, 0);
}
function flushTypeset() {
  mjScheduled = false;
  const nodes = [...mjQueue].filter(n => n && n.isConnected);
  mjQueue.clear();
  if (window.MathJax && MathJax.typesetPromise && nodes.length) {
    if (MathJax.typesetClear) MathJax.typesetClear(nodes);
    MathJax.typesetPromise(nodes).then(stripMathTabstops).catch(() => {});
  }
}
// MathJax may put tabindex="0" on its containers; keep math out of the Tab
// order (right-click "Show Math As" still works with tabindex="-1").
function stripMathTabstops() {
  document.querySelectorAll('mjx-container[tabindex="0"]').forEach(c => c.setAttribute('tabindex', '-1'));
}
// MathJax typesets asynchronously and can (re)add tabindex="0" after any manual
// strip. A MutationObserver guarantees typeset math never lingers in the Tab
// order, no matter when MathJax finishes.
function installMathTabstopGuard() {
  const strip = () => stripMathTabstops();
  const obs = new MutationObserver((muts) => {
    for (const m of muts) {
      const t = m.target;
      if (m.type === 'attributes' && t.matches && t.matches('mjx-container[tabindex="0"]')) {
        t.setAttribute('tabindex', '-1');
      } else if (m.type === 'childList' && m.addedNodes.length) {
        strip();
      }
    }
  });
  obs.observe(document.body, {
    subtree: true, childList: true, attributes: true, attributeFilter: ['tabindex']
  });
}

/* =====================================================================
   TEXT / DESCRIPTIONS  (units always spoken; color described for audio users)
   ===================================================================== */
function glowDescription(T) {
  if (T < 800)  return 'not yet visibly glowing';
  if (T < 950)  return 'glowing faint red';
  if (T < 1100) return 'glowing dull red';
  if (T < 1250) return 'glowing red';
  if (T < 1400) return 'glowing orange-red';
  if (T < 1550) return 'glowing orange';
  if (T < 1700) return 'glowing bright orange';
  return 'glowing yellow-white and melting';
}

function fmtNm(T) { return (peakWavelengthM(T) * 1e9).toFixed(0); }
function fmtUm(T) { return (peakWavelengthM(T) * 1e6).toFixed(2); }

/* =====================================================================
   RENDER  (single function; redraws canvases, syncs DOM + live region)
   ===================================================================== */
let lastTempMathK = null;
let lastMjTempTime = 0;

function render() {
  const T = state.temp;
  const K = Math.floor(T);                       // temperatureField: Math.floor(t)+" K"

  // canvases (cheap; every frame)
  drawMainPlot();
  drawInsetPlot();
  if (!staticLabelsDone) buildStaticLabels();

  // temperature readout -- MathJax, throttled during animation to stay smooth
  updateTempReadout(K);

  // Wien's-law readout (peak wavelength) -- MathJax via foundation helper
  updateWienReadout(K, T);

  // slider position + spoken value (with units)
  els.slider.value = String(state.frame);
  els.slider.setAttribute('aria-valuetext',
    `Temperature ${K} kelvin. Frame ${state.frame} of ${MAX_FRAME}, ${modeWord()}.`);

  // button label (start / pause / resume / restart)
  els.playBtn.textContent = buttonLabel();

  // hidden descriptions (visual equivalents for assistive tech)
  els.nailDesc.textContent = `The nail is at ${K} kelvin, ${glowDescription(T)}.`;
  els.plotDesc.textContent =
    `Blackbody curve at ${K} kelvin. Peak wavelength ${fmtNm(T)} nanometers ` +
    `(${fmtUm(T)} micrometers). The small inset shows the full curve from 0 to 10 micrometers; ` +
    `the main plot shows the visible range from 300 to 800 nanometers.`;
}

function updateTempReadout(K) {
  if (K === lastTempMathK) return;
  const now = performance.now();
  // during animation, cap MathJax re-typeset to ~10 Hz (canvas still 60 Hz)
  if (state.mode === 'animating' && (now - lastMjTempTime) < 100) return;
  lastTempMathK = K;
  lastMjTempTime = now;
  els.tempValue.innerHTML = `\\(${K}\\ \\mathrm{K}\\)`;
  typeset(els.tempValue);
}

let lastWienK = null;
function updateWienReadout(K, T) {
  if (K === lastWienK) return;
  lastWienK = K;
  const nm = fmtNm(T), um = fmtUm(T);
  // Wien's displacement law with the current substituted value
  const latex = `\\lambda_{\\max} = \\dfrac{b}{T} = \\dfrac{2.898\\times 10^{-3}\\ \\mathrm{m\\,K}}{${K}\\ \\mathrm{K}} = ${nm}\\ \\mathrm{nm}`;
  if (typeof klunlShowEquation === 'function') {
    klunlShowEquation(
      ['wien-eqn', `\\(${latex}\\)`],
      ['wien-sr', `Wien's displacement law: peak wavelength equals the Wien constant, ` +
        `2.898 times ten to the minus three meter kelvin, divided by temperature. ` +
        `At ${K} kelvin the peak wavelength is ${nm} nanometers, ${um} micrometers.`]
    );
    setTimeout(stripMathTabstops, 0);
  }
}

function modeWord() {
  switch (state.mode) {
    case 'atStart':   return 'start';
    case 'animating': return 'playing';
    case 'paused':    return 'paused';
    case 'atEnd':     return 'ended';
  }
  return '';
}
function buttonLabel() {
  switch (state.mode) {
    case 'atStart':   return 'start';
    case 'animating': return 'pause';
    case 'paused':    return 'resume';
    case 'atEnd':     return 'restart';
  }
  return 'start';
}

/* =====================================================================
   CORE UPDATE  (mirrors update() in the Flash main frame script)
   ===================================================================== */
function update() {
  state.temp = tempForFrame(state.frame);
  state.peakHeight = peakHeightForTemp(state.temp);
  syncVideoToFrame();
  render();
}

// Show the video frame that matches state.frame (gotoAndStop equivalent).
function syncVideoToFrame() {
  if (!video || !video.duration) return;
  if (state.mode === 'animating') return;        // video plays itself while animating
  const idx = Math.min(state.frame - 1, VIDEO_FRAMES - 1);
  const t = Math.max(0, Math.min(idx / FPS, video.duration - 0.001));
  // avoid redundant seeks
  if (Math.abs(video.currentTime - t) > 0.01) video.currentTime = t;
}

/* =====================================================================
   STATE MACHINE  (verbatim from frame_1 DoAction.as)
   ===================================================================== */
function announce(msg) { els.status.textContent = msg; }

function resetAnimation() {
  video && video.pause();
  state.frame = 1;
  state.mode = 'atStart';
  update();
}
function startAnimation() {
  state.mode = 'animating';
  if (video) { const p = video.play(); if (p && p.catch) p.catch(() => {}); }
  render();
  announce(`Playing. Temperature ${Math.floor(state.temp)} kelvin.`);
}
function pauseAnimation() {
  video && video.pause();
  state.mode = 'paused';
  update();
  announce(`Paused at ${Math.floor(state.temp)} kelvin.`);
}
function stopAnimation() {
  video && video.pause();
  state.frame = MAX_FRAME;
  state.mode = 'atEnd';
  update();
  announce(`Animation complete. Nail broke; temperature returned to ${Math.floor(state.temp)} kelvin.`);
}
function restartAnimation() {
  state.frame = 1;
  state.temp = tempForFrame(1);
  state.peakHeight = peakHeightForTemp(state.temp);
  state.mode = 'animating';
  playVideoFromStart();
  render();
  announce('Restarting animation.');
}

// Rewind to frame 1 and play. When the video is not already at the start we
// must wait for the seek to complete before play(), otherwise the seek and
// play() race and playback can fail to start on some browsers.
function playVideoFromStart() {
  if (!video) return;
  const go = () => { const p = video.play(); if (p && p.catch) p.catch(() => {}); };
  if (video.currentTime > 0.05) {
    video.addEventListener('seeked', go, { once: true });
    video.currentTime = 0;
  } else {
    go();
  }
}

// slider drag -> onFrameChangedViaSlider()
function onFrameChangedViaSlider() {
  if (state.frame === 1)             resetAnimation();
  else if (state.frame >= MAX_FRAME) stopAnimation();
  else                               pauseAnimation();
}

// button -> onAnimationButtonPressed()
function onAnimationButtonPressed() {
  if (state.mode === 'atStart' || state.mode === 'paused') startAnimation();
  else if (state.mode === 'animating')                     pauseAnimation();
  else                                                     restartAnimation();
}

/* =====================================================================
   ANIMATION SYNC  (video-driven while playing; the video clock is the
   elapsed-time source so timing matches the original 20 fps across
   machines). Driven by BOTH requestAnimationFrame (smooth when visible)
   and the video's own timeupdate event (keeps temperature/curve in sync
   even when rAF is throttled, e.g. a backgrounded tab).
   ===================================================================== */
function syncFromVideo() {
  if (state.mode !== 'animating' || !video) return;
  let f = Math.round(video.currentTime * FPS) + 1;
  if (f < 1) f = 1;
  if (f > MAX_FRAME) f = MAX_FRAME;
  if (f !== state.frame) {
    state.frame = f;
    state.temp = tempForFrame(f);
    state.peakHeight = peakHeightForTemp(state.temp);
    render();
  }
}
function loop() {
  syncFromVideo();
  requestAnimationFrame(loop);
}

/* =====================================================================
   WIRING
   ===================================================================== */
function cacheEls() {
  els = {
    status:       document.getElementById('sr-status'),
    tempValue:    document.getElementById('temp-value'),
    playBtn:      document.getElementById('play-btn'),
    slider:       document.getElementById('frame-slider'),
    nailDesc:     document.getElementById('nail-desc'),
    plotDesc:     document.getElementById('plot-desc'),
    overlay:      document.getElementById('plot-overlay'),
    insetOverlay: document.getElementById('inset-overlay'),
    wienEqn:      document.getElementById('wien-eqn')
  };
  video = document.getElementById('nail-video');
}

function wireControls() {
  els.playBtn.addEventListener('click', onAnimationButtonPressed);

  // Native range slider: full keyboard support (arrows/Page/Home/End) for free.
  els.slider.addEventListener('input', () => {
    state.frame = parseInt(els.slider.value, 10) || 1;
    onFrameChangedViaSlider();
  });
  // Mouse wheel adjusts the focused slider (nudge one frame per notch).
  els.slider.addEventListener('wheel', (e) => {
    if (document.activeElement !== els.slider) return;
    e.preventDefault();
    let f = state.frame + (e.deltaY < 0 ? 1 : -1);
    f = Math.max(1, Math.min(MAX_FRAME, f));
    state.frame = f;
    onFrameChangedViaSlider();
  }, { passive: false });

  // Reset comes from the shared masthead (do NOT build a second Reset button).
  document.addEventListener('sim-reset', () => {
    lastTempMathK = null; lastWienK = null;
    resetAnimation();
    announce('Simulation reset to the start.');
  });

  // Keep temperature/curve synced to the video position during playback,
  // even when requestAnimationFrame is throttled (backgrounded tab).
  video.addEventListener('timeupdate', syncFromVideo);

  // When the video reaches its end, finish exactly like animateOnEnterFrame.
  video.addEventListener('ended', () => {
    if (state.mode === 'animating') stopAnimation();
  });
}

function initVideoAndRender() {
  // Force a clean initial state (frame 1, paused) even if the browser restored
  // a previous playback position (bfcache / media-session carryover).
  const start = () => {
    video.pause();
    state.frame = 1; state.mode = 'atStart';
    state.temp = tempForFrame(1); state.peakHeight = peakHeightForTemp(state.temp);
    syncVideoToFrame();
    render();
  };
  if (video.readyState >= 1 && video.duration) start();
  else video.addEventListener('loadedmetadata', start, { once: true });
  // draw immediately even before metadata (curves don't need the video)
  render();
}

function boot() {
  cacheEls();
  mainCtx  = setupCanvas(document.getElementById('plot-canvas'), 420, 290);
  insetCtx = setupCanvas(document.getElementById('inset-canvas'), 160, 96);

  state.frame = 1; state.mode = 'atStart';
  state.temp = tempForFrame(1); state.peakHeight = peakHeightForTemp(state.temp);

  wireControls();
  installMathTabstopGuard();
  initVideoAndRender();
  requestAnimationFrame(loop);

  // Re-typeset static labels once MathJax has finished starting up.
  if (window.MathJax && MathJax.startup && MathJax.startup.promise) {
    MathJax.startup.promise.then(() => {
      staticLabelsDone = false; lastTempMathK = null; lastWienK = null;
      render(); stripMathTabstops();
    });
  }
}

// The foundation's klunlInitEqn is meant to be redefined by the sim.
function klunlInitEqn() { /* equations are driven from render()/updateWienReadout */ }

if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', boot);
} else {
  boot();
}
