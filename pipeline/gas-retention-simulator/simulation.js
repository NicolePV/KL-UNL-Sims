/* =====================================================================
   Gas Retention Simulator  --  HTML5 / KL-UNL accessible port
   Behavior is ported verbatim from the decompiled ActionScript (AS1).
   Presentation follows the KL-UNL foundation + WCAG 2.1 AA.

   Physics ground truth (from scripts/*.as):
     - Maxwell-Boltzmann speed distribution, parameter a = sqrt(R*T/M),
       with R = 8314.47147 J/(kmol*K) and M the molar mass in u (= g/mol).
       Equivalently a = sqrt(kT/m), k = 1.3806503e-23, m = mass*1.66053886e-27.
     - Fraction slower than v:  CDF(v) = erf(v/(sqrt2*a)) - sqrt(2/pi)*v*exp(-v^2/2a^2)/a
     - Atmospheric escape: decay constant = 0.001 * (1 - CDF(v_escape)),
       fraction(t) = fraction0 * exp(-decay * t_ms).
   ===================================================================== */

'use strict';

/* -------------------------------------------------------------------
   0.  Error function -- ported EXACTLY from scripts/Error Function.as
   ------------------------------------------------------------------- */
const LN10 = 2.302585092994046;

function gammln(xx) {
  const cof = [76.18009172947146, -86.50532032941678, 24.01409824083091,
               -1.231739572450155, 0.001208650973866179, -0.000005395239384953];
  let x = xx, y = xx;
  let tmp = x + 5.5;
  tmp -= (x + 0.5) * Math.log(tmp);
  let ser = 1.000000000190015;
  for (let j = 0; j <= 5; j++) { ser += cof[j] / ++y; }
  return -tmp + Math.log(2.5066282746310007 * ser / x);
}
function gser(a, x) {
  const itmax = 100, eps = 3e-7;
  const gln = gammln(a);
  if (x <= 0) return 0;
  let ap = a, del = 1 / a, sum = 1 / a;
  for (let n = 1; n <= itmax; n++) {
    ap++;
    del *= x / ap;
    sum += del;
    if (Math.abs(del) < Math.abs(sum) * eps) {
      return sum * Math.exp(-x + a * Math.log(x) - gln);
    }
  }
  return 0;
}
function gcf(a, x) {
  const itmax = 100, eps = 3e-7, fpmin = 1e-30;
  const gln = gammln(a);
  let b = x + 1 - a, c = 1 / fpmin, d = 1 / b, h = d;
  for (let i = 1; i <= itmax; i++) {
    const an = -i * (i - a);
    b += 2;
    d = an * d + b; if (Math.abs(d) < fpmin) d = fpmin;
    c = b + an / c;  if (Math.abs(c) < fpmin) c = fpmin;
    d = 1 / d;
    const del = d * c;
    h *= del;
    if (Math.abs(del - 1) < eps) break;
  }
  return Math.exp(-x + a * Math.log(x) - gln) * h;
}
function gammp(a, x) {
  if (x < 0 || a <= 0) return 0;
  if (x < a + 1) return gser(a, x);
  return 1 - gcf(a, x);
}
function erf(x) {
  return x >= 0 ? gammp(0.5, x * x) : -gammp(0.5, x * x);
}

/* Fraction of a Maxwell-Boltzmann speed distribution with parameter a that is
   SLOWER than speed x (the cumulative distribution). From Maxwell Plot Cursor
   Overlay.as getCDF() and the escape math in Gas Retention Simulator.as. */
function maxwellCDF(a, x) {
  return erf(x / (a * 1.4142135623730951))
       - 0.7978845608028654 * x * Math.exp(-x * x / (2 * a * a)) / a;
}

/* Inverse-CDF sampler for a unit (a = 1) Maxwell-Boltzmann speed, ported
   verbatim from the rational polynomial in TGC Gas Class.as / doPseudoCollisions. */
function sampleUnitSpeed(u) {
  return (0.0335009738566387 + u * (324.499855174808 + u * (67952.3527878137 + u * (1649609.82033456 + u * (2184252.22113819 + u * (-21058874.6332882 + u * (26738095.9605488 + u * (769197.569308745 + u * (-21394748.7073447 + u * (13624855.3507324 + u * -2580664.4615644))))))))))
       / (1 + u * (1632.61962771862 + u * (155759.053592243 + u * (1790252.45942473 + u * (-3060237.16137971 + u * (-9765674.6273682 + u * (28452708.8769605 + u * (-25616300.7710808 + u * (7698980.62184725 + u * (1037426.91742616 + u * -694548.98898973))))))))));
}

/* -------------------------------------------------------------------
   1.  Physical constants + gas table (VERBATIM from Gas Retention Simulator.as)
   ------------------------------------------------------------------- */
const K_BOLTZ = 1.3806503e-23;      // J/K
const M_U     = 1.66053886e-27;     // kg per u
const R_GAS   = 8314.47147;          // a = sqrt(R*T/mass)  (mass in u)
const SCALE   = 0.001;               // chamber pixel scale (m per px-ish)
const ANIM_RATE = 0.00015;           // Thermal Gas Component animationRate
const NUM_PARTICLES = 160;           // numParticlesMultiplier
const GAS_LIMIT = 3;
const T_MIN = 100, T_MAX = 1000;     // temperature slider range (K)
const C_PEAK = 0.5870506526949597;   // = 2*sqrt(2/pi)/e  (MB peak height * a)

// particle fade/lifetime (ms) -- TGC Gas Class defaults
const FADE_TIME = 2500, MAX_ALPHA_TIME = 10000;
const LIFETIME  = 2 * FADE_TIME + MAX_ALPHA_TIME;   // 15000
const MIN_ALPHA = 10, MAX_ALPHA = 100;

// chamber geometry (internal coordinates; CSS scales the canvas)
const BW = 264, BH = 264;            // chamber box (boundary) -- larger, fills more of the panel
const CMARGIN = 44;                  // room for escaping ghost particles
const CW = BW + 2 * CMARGIN, CH = BH + 2 * CMARGIN;
const ESCAPEE_TRAVEL = 42;

// plot geometry (internal curve region)
const PW = 470, PH = 275;
const X_MIN = 0, X_MAX = 2000;

// ordered gas definitions (order preserved for the "add gas" menu)
const GAS_DEFS = [
  { id: 'xenon',        size: 6,   color: 6710944,  name: 'xenon',          symbol: 'Xe',              mass: 131.293  },
  { id: 'carbonDioxide',size: 4.5, color: 11579392, name: 'carbon dioxide', symbol: 'CO<sub>2</sub>',  mass: 44.0095  },
  { id: 'oxygen',       size: 4,   color: 53488,    name: 'oxygen',         symbol: 'O<sub>2</sub>',   mass: 31.9988  },
  { id: 'nitrogen',     size: 3.5, color: 12090177, name: 'nitrogen',       symbol: 'N<sub>2</sub>',   mass: 28.0134  },
  { id: 'water',        size: 3,   color: 20735,    name: 'water',          symbol: 'H<sub>2</sub>O',  mass: 18.01528 },
  { id: 'ammonia',      size: 3,   color: 10506495, name: 'ammonia',        symbol: 'NH<sub>3</sub>',  mass: 17.03052 },
  { id: 'methane',      size: 3,   color: 16737792, name: 'methane',        symbol: 'CH<sub>4</sub>',  mass: 16.04246 },
  { id: 'helium',       size: 2.5, color: 43520,    name: 'helium',         symbol: 'He',              mass: 4.002602 },
  { id: 'hydrogen',     size: 2.5, color: 16711680, name: 'hydrogen',       symbol: 'H<sub>2</sub>',   mass: 2.01588  }
];
const GAS_BY_ID = {};
GAS_DEFS.forEach(g => { GAS_BY_ID[g.id] = g; });

function colorHex(c) { return '#' + (c >>> 0).toString(16).padStart(6, '0'); }

/* symbol markup helpers (for MathJax + plain-text fallback) */
const SUB = { '0':'₀','1':'₁','2':'₂','3':'₃','4':'₄',
              '5':'₅','6':'₆','7':'₇','8':'₈','9':'₉' };
function symbolToLatex(sym) {
  return '\\mathrm{' + sym.replace(/<sub>(.*?)<\/sub>/g, '_{$1}')
                          .replace(/<sup>(.*?)<\/sup>/g, '^{$1}') + '}';
}
function symbolToText(sym) {
  return sym.replace(/<sub>(.*?)<\/sub>/g, (m, d) => d.replace(/./g, c => SUB[c] || c))
            .replace(/<\/?sup>/g, '').replace(/<\/?sub>/g, '');
}

/* -------------------------------------------------------------------
   2.  MathJax rendering helper (all math/symbols go through MathJax).
       Dynamic readouts show a readable text fallback until (re)typeset,
       and a full fallback if the MathJax library is unavailable.
   ------------------------------------------------------------------- */
const mjQueue = new Set();
let mjTimer = null, mjLast = 0;
function mjReady() { return !!(window.MathJax && window.MathJax.typesetPromise); }

function setMath(el, latex, fallback) {
  if (!el) return;
  el.dataset.fallback = fallback != null ? fallback : latex;
  if (mjReady()) {
    el.textContent = '\\(' + latex + '\\)';
    queueTypeset(el);
  } else {
    el.textContent = el.dataset.fallback;   // readable until MathJax loads
    el.dataset.pendingTex = latex;
    mjQueue.add(el);
  }
}
function queueTypeset(el) {
  mjQueue.add(el);
  const now = performance.now();
  const flush = () => {
    mjTimer = null; mjLast = performance.now();
    if (!mjReady() || mjQueue.size === 0) return;
    const nodes = [...mjQueue]; mjQueue.clear();
    window.MathJax.typesetPromise(nodes).catch(() => {});
  };
  if (mjTimer) return;
  const wait = Math.max(0, 140 - (now - mjLast));  // throttle re-typesets
  mjTimer = setTimeout(flush, wait);
}
// When MathJax finishes loading, typeset everything authored so far.
function mjOnReady() {
  document.querySelectorAll('[data-pending-tex]').forEach(el => {
    el.textContent = '\\(' + el.dataset.pendingTex + '\\)';
    mjQueue.add(el);
  });
  if (mjReady()) window.MathJax.typesetPromise([...mjQueue]).then(() => mjQueue.clear()).catch(() => {});
}
if (window.MathJax) {
  const prev = window.MathJax.startup && window.MathJax.startup.ready;
  window.MathJax.startup = window.MathJax.startup || {};
  window.MathJax.startup.ready = () => {
    if (window.MathJax.startup.defaultReady) window.MathJax.startup.defaultReady();
    if (prev) try { prev(); } catch (e) {}
    mjOnReady();
  };
}
// Also poll briefly in case the script loads without a startup hook.
let mjPoll = 0;
const mjPoller = setInterval(() => {
  if (mjReady()) { clearInterval(mjPoller); mjOnReady(); }
  else if (++mjPoll > 40) clearInterval(mjPoller);
}, 250);

/* -------------------------------------------------------------------
   3.  State (single source of truth)
   ------------------------------------------------------------------- */
const state = {
  gases: {},          // id -> runtime gas object (only in-use gases)
  order: [],          // ids in list order
  selectedGas: null,
  temperature: 300,
  escapeSpeed: 1500,
  allowEscape: false,
  showCursor: false,
  showInfo: true,
  running: false,
  cursorSpeed: 1000,
  simStartTime: 0,
  yScaleMag: 0
};

const DEFAULTS = { temperature: 300, escapeSpeed: 1500 };

/* runtime gas factory */
function makeGas(def) {
  return {
    id: def.id, def,
    fraction: 1,
    initialFraction: 1,
    decayConstant: 0,
    numberOfParticles: NUM_PARTICLES,
    particles: [],
    escapees: []
  };
}

/* a = sqrt(R*T/mass)  (m/s)   -- shared by plot, cursor and escape math */
function speedParam(mass, T) { return Math.sqrt(R_GAS * T / mass); }

/* -------------------------------------------------------------------
   4.  DOM references
   ------------------------------------------------------------------- */
const $ = id => document.getElementById(id);
const chamberCanvas = $('chamberCanvas'), chamberCtx = chamberCanvas.getContext('2d');
const plotCanvas = $('plotCanvas'), plotCtx = plotCanvas.getContext('2d');
const plotArea = $('plotArea');
const tempSlider = $('tempSlider'), escapeSlider = $('escapeSlider');
const tempReadout = $('tempReadout'), escapeReadout = $('escapeReadout');
const allowEscapeCheck = $('allowEscapeCheck');
const showCursorCheck = $('showCursorCheck'), showInfoCheck = $('showInfoCheck');
const startButton = $('startButton');
const addGasSelect = $('addGasSelect');
const removeGasButton = $('removeGasButton');
const resetProportionsButton = $('resetProportionsButton');
const gasListEl = $('gasList');
const proportionBars = $('proportionBars');
const plotTicks = $('plotTicks');
const escapeLabel = $('escapeLabel');
const plotCursor = $('plotCursor');
const cursorSpeedEl = $('cursorSpeed');
const cursorInfoLeft = $('cursorInfoLeft'), cursorInfoRight = $('cursorInfoRight');
const liveStatus = $('liveStatus'), liveAlert = $('liveAlert');
const chamberDesc = $('chamberDesc');

const prefersReducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;

/* -------------------------------------------------------------------
   5.  Canvas sizing (backing store = internal size * dpr; CSS scales)
   ------------------------------------------------------------------- */
function sizeCanvas(canvas, ctx, w, h) {
  const dpr = Math.max(1, window.devicePixelRatio || 1);
  canvas.width = Math.round(w * dpr);
  canvas.height = Math.round(h * dpr);
  ctx.setTransform(dpr, 0, 0, dpr, 0, 0);
}
function sizeAllCanvases() {
  sizeCanvas(chamberCanvas, chamberCtx, CW, CH);
  sizeCanvas(plotCanvas, plotCtx, PW, PH);
  drawChamber();
  drawPlot();
}

/* -------------------------------------------------------------------
   6.  Speeds / particles  (ported from TGC Gas Class.as)
   ------------------------------------------------------------------- */
function calculateSpeeds(gas, list) {
  const a = speedParam(gas.def.mass, state.temperature) / SCALE;  // px per sim-sec
  for (const p of list) {
    p.v = a * p.unscaledV;
    p.vx = a * p.unscaledVX;
    p.vy = a * p.unscaledVY;
  }
}
function alphaForAge(age) {
  if (age < FADE_TIME) return MIN_ALPHA + (MAX_ALPHA - MIN_ALPHA) * age / FADE_TIME;
  if (age < FADE_TIME + MAX_ALPHA_TIME) return MAX_ALPHA;
  return MAX_ALPHA - (MAX_ALPHA - MIN_ALPHA) * (age - FADE_TIME - MAX_ALPHA_TIME) / FADE_TIME;
}
function initParticles(gas, list, fadeIn) {
  for (const p of list) {
    if (fadeIn) { p.age = 0; p.alpha = MIN_ALPHA; }
    else { p.age = LIFETIME * Math.random(); p.alpha = alphaForAge(p.age); }
    p.x = BW * Math.random();
    p.y = BH * Math.random();
    const speed = sampleUnitSpeed(Math.random());
    const angle = 6.283185307179586 * Math.random();
    p.unscaledV = speed;
    p.unscaledVX = speed * Math.cos(angle);
    p.unscaledVY = speed * Math.sin(angle);
  }
  calculateSpeeds(gas, list);
}
function setNumberOfParticles(gas, n) {
  const cur = gas.particles.length;
  if (n > cur) {
    const added = [];
    for (let i = cur; i < n; i++) { const p = {}; gas.particles.push(p); added.push(p); }
    initParticles(gas, added, false);
  } else if (n < cur) {
    gas.particles.length = n;
  }
}

/* -------------------------------------------------------------------
   7.  Animation step (Thermal Gas Component + doPseudoCollisions)
   ------------------------------------------------------------------- */
function doPseudoCollisions() {
  let fractionalSum = 0;
  for (const id of state.order) fractionalSum += state.gases[id].fraction;
  let F = 0.1 * (fractionalSum / GAS_LIMIT) * Math.sqrt(state.temperature / T_MAX);
  for (const id of state.order) {
    const gas = state.gases[id];
    const changed = [];
    for (const p of gas.particles) {
      if (Math.random() < F) {
        const speed = sampleUnitSpeed(Math.random());
        const angle = 6.283185307179586 * Math.random();
        p.unscaledV = speed;
        p.unscaledVX = speed * Math.cos(angle);
        p.unscaledVY = speed * Math.sin(angle);
        changed.push(p);
      }
    }
    if (changed.length) calculateSpeeds(gas, changed);
  }
}

function advanceParticles(gas, deltaTime, deltaAge) {
  const pL = gas.particles;
  // fade / lifetime
  const reinit = [];
  for (const p of pL) {
    p.age += deltaAge;
    if (p.age > LIFETIME) reinit.push(p);
    else p.alpha = alphaForAge(p.age);
  }
  if (reinit.length) initParticles(gas, reinit, true);

  const w = BW, h = BH;
  if (state.allowEscape) {
    const ev = state.escapeSpeed / SCALE;
    const relocated = [], newEscapees = [];
    for (const p of pL) {
      if (p.v > ev) {
        const nx = p.x + deltaTime * p.vx;
        const ny = p.y + deltaTime * p.vy;
        if (nx > w || nx < 0 || ny < 0 || ny > h) {
          newEscapees.push({ x: p.x, y: p.y, vx: p.vx, vy: p.vy, baseAlpha: p.alpha, dispAlpha: p.alpha });
          p.x = w * Math.random();
          p.y = h * Math.random();
          const angle = 6.283185307179586 * Math.random();
          p.unscaledVX = p.unscaledV * Math.cos(angle);
          p.unscaledVY = p.unscaledV * Math.sin(angle);
          relocated.push(p);
        } else { p.x = nx; p.y = ny; }
      } else {
        bounce(p, deltaTime, w, h);
      }
    }
    if (relocated.length) calculateSpeeds(gas, relocated);
    if (newEscapees.length) gas.escapees.push(...newEscapees);
  } else {
    for (const p of pL) bounce(p, deltaTime, w, h);
  }
  advanceEscapees(gas, deltaTime);
}
function bounce(p, deltaTime, w, h) {
  const nx = p.x + deltaTime * p.vx;
  const ny = p.y + deltaTime * p.vy;
  let mx = ((nx / w) % 2 + 2) % 2;
  let my = ((ny / h) % 2 + 2) % 2;
  if (mx < 1) p.x = mx * w; else { p.vx *= -1; p.unscaledVX *= -1; p.x = 2 * w - mx * w; }
  if (my < 1) p.y = my * h; else { p.vy *= -1; p.unscaledVY *= -1; p.y = 2 * h - my * h; }
}
function advanceEscapees(gas, deltaTime) {
  const w = BW, h = BH, d = ESCAPEE_TRAVEL;
  for (let i = gas.escapees.length - 1; i >= 0; i--) {
    const e = gas.escapees[i];
    const nx = e.x + deltaTime * e.vx;
    const ny = e.y + deltaTime * e.vy;
    const dx = nx > w ? nx - w : -nx;
    const dy = ny > h ? ny - h : -ny;
    const u = Math.max(dx, dy) / d;
    if (u < 1) { e.x = nx; e.y = ny; e.dispAlpha = (1 - u) * e.baseAlpha; }
    else gas.escapees.splice(i, 1);
  }
}

/* -------------------------------------------------------------------
   8.  Escape decay (Gas Retention Simulator.as onStartSimulation + enterFrame)
   ------------------------------------------------------------------- */
function computeDecayConstants() {
  const vesc = state.escapeSpeed;
  for (const id of state.order) {
    const gas = state.gases[id];
    const a = speedParam(gas.def.mass, state.temperature);       // m/s
    const fesc = 1 - maxwellCDF(a, vesc);                        // fraction faster than escape
    gas.decayConstant = 0.001 * fesc;
    gas.initialFraction = gas.fraction;
  }
}
function applyDecay(dtMs) {
  for (const id of state.order) {
    const gas = state.gases[id];
    gas.fraction = gas.initialFraction * Math.exp(-gas.decayConstant * dtMs);
    setNumberOfParticles(gas, Math.round(NUM_PARTICLES * gas.fraction));
  }
}

/* -------------------------------------------------------------------
   9.  Animation loop.  The requestAnimationFrame loop runs ONLY while the
       simulation is running; when stopped the canvas is redrawn on demand
       (via requestChamberRedraw) so the renderer can go idle.
   ------------------------------------------------------------------- */
let lastTime = 0;
let rafId = null;
let idleRedraw = null;

function loop(now) {
  let deltaAge = now - lastTime;
  if (deltaAge > 100) deltaAge = 100;   // cap large gaps (tab was hidden, etc.)
  if (deltaAge < 0) deltaAge = 0;
  const deltaTime = ANIM_RATE * deltaAge / 1000;
  doPseudoCollisions();
  for (const id of state.order) advanceParticles(state.gases[id], deltaTime, deltaAge);
  if (state.allowEscape) {
    applyDecay(now - state.simStartTime);   // decay tracks elapsed wall-clock (like AS getTimer)
    updateProportionsFromState();
    drawPlot();
    throttledLiveUpdate();
  }
  lastTime = now;
  drawChamber();
  rafId = state.running ? requestAnimationFrame(loop) : null;
}
function startLoop() {
  if (rafId == null) { lastTime = performance.now(); rafId = requestAnimationFrame(loop); }
}
// Redraw the (static) chamber once, coalescing multiple calls into one frame.
function requestChamberRedraw() {
  if (state.running || idleRedraw != null) return;
  idleRedraw = requestAnimationFrame(() => { idleRedraw = null; drawChamber(); });
}

/* -------------------------------------------------------------------
   10.  Chamber rendering
   ------------------------------------------------------------------- */
function drawChamber() {
  const ctx = chamberCtx;
  ctx.clearRect(0, 0, CW, CH);
  const ox = CMARGIN, oy = CMARGIN;

  // particles (clipped to the box, like the AS particle mask)
  ctx.save();
  ctx.beginPath();
  ctx.rect(ox, oy, BW, BH);
  ctx.clip();
  for (const id of state.order) {
    const gas = state.gases[id];
    ctx.fillStyle = colorHex(gas.def.color);
    const r = gas.def.size / 2;
    for (const p of gas.particles) {
      ctx.globalAlpha = Math.max(0, Math.min(1, p.alpha / 100));
      ctx.beginPath();
      ctx.arc(ox + p.x, oy + p.y, r, 0, 6.283185307179586);
      ctx.fill();
    }
  }
  ctx.restore();

  // escaping ghost particles (drawn outside the box, fading)
  for (const id of state.order) {
    const gas = state.gases[id];
    if (!gas.escapees.length) continue;
    ctx.fillStyle = colorHex(gas.def.color);
    const r = gas.def.size / 2;
    for (const e of gas.escapees) {
      ctx.globalAlpha = Math.max(0, Math.min(1, e.dispAlpha / 100));
      ctx.beginPath();
      ctx.arc(ox + e.x, oy + e.y, r, 0, 6.283185307179586);
      ctx.fill();
    }
  }
  ctx.globalAlpha = 1;

  // box border
  ctx.strokeStyle = colorHex(9474192);   // AS boundaryColor #909090
  ctx.lineWidth = 1;
  ctx.strokeRect(ox + 0.5, oy + 0.5, BW, BH);
}

/* -------------------------------------------------------------------
   11.  Plot rendering (Maxwell Plot Component.as)
   ------------------------------------------------------------------- */
function recalcPlotScale() {
  if (state.order.length === 0) { state.yScaleMag = 0; return; }
  let maxPeak = -Infinity;
  for (const id of state.order) {
    const a = speedParam(state.gases[id].def.mass, T_MIN);  // coldest = tallest peaks
    const peak = C_PEAK / a;
    if (peak > maxPeak) maxPeak = peak;
  }
  state.yScaleMag = 0.95 * PH / maxPeak;
}
// Maxwell-Boltzmann speed pdf value (unit fraction) at speed v, parameter a.
function mbValue(v, a) {
  return 0.7978845608028654 / (a * a * a) * v * v * Math.exp(-v * v / (2 * a * a));
}
function xToPx(v) { return (v - X_MIN) / (X_MAX - X_MIN) * PW; }

function curvePath(ctx, gas) {
  const a = speedParam(gas.def.mass, state.temperature);
  const N = 240;
  ctx.moveTo(0, PH);
  for (let i = 0; i <= N; i++) {
    const v = X_MIN + (X_MAX - X_MIN) * i / N;
    const y = PH - gas.fraction * mbValue(v, a) * state.yScaleMag;
    ctx.lineTo(xToPx(v), y);
  }
}
function drawPlot() {
  const ctx = plotCtx;
  ctx.clearRect(0, 0, PW, PH);

  // background + border
  ctx.fillStyle = '#ffffff';
  ctx.fillRect(0, 0, PW, PH);

  // tick marks (numbers are HTML/MathJax; marks are graphical)
  ctx.strokeStyle = colorHex(5263440);  // #5050D0-ish axis color from AS (#504E... actually 0x5050... )
  ctx.strokeStyle = '#505050';
  ctx.lineWidth = 1;
  ctx.beginPath();
  for (let v = 0; v <= X_MAX; v += 100) {
    const x = xToPx(v);
    const major = (v % 500 === 0);
    ctx.moveTo(x + 0.5, PH);
    ctx.lineTo(x + 0.5, PH - (major ? 8 : 4));
  }
  ctx.stroke();

  // fill under the selected gas
  if (state.selectedGas && state.gases[state.selectedGas]) {
    const gas = state.gases[state.selectedGas];
    ctx.beginPath();
    curvePath(ctx, gas);
    ctx.lineTo(PW, PH);
    ctx.closePath();
    ctx.fillStyle = hexA(gas.def.color, 0.2);
    ctx.fill();
  }

  // escape-speed dashed line
  if (state.allowEscape) {
    const x = xToPx(state.escapeSpeed);
    ctx.strokeStyle = '#909090';
    ctx.lineWidth = 1;
    ctx.setLineDash([5, 5]);
    ctx.beginPath();
    ctx.moveTo(x + 0.5, PH);
    ctx.lineTo(x + 0.5, 0);
    ctx.stroke();
    ctx.setLineDash([]);
  }

  // curves
  for (const id of state.order) {
    const gas = state.gases[id];
    ctx.beginPath();
    curvePath(ctx, gas);
    ctx.strokeStyle = colorHex(gas.def.color);
    ctx.lineWidth = (id === state.selectedGas) ? 2.4 : 1.6;
    ctx.stroke();
  }

  // border last, on top
  ctx.strokeStyle = '#505050';
  ctx.lineWidth = 1;
  ctx.strokeRect(0.5, 0.5, PW - 1, PH - 1);
}
function hexA(c, a) {
  const r = (c >> 16) & 255, g = (c >> 8) & 255, b = c & 255;
  return `rgba(${r},${g},${b},${a})`;
}

/* build the HTML x-axis tick labels once */
function buildTicks() {
  plotTicks.innerHTML = '';
  for (let v = 0; v <= X_MAX; v += 500) {
    const span = document.createElement('span');
    span.className = 'sim-plot__tick mjx';
    span.style.left = (xToPx(v) / PW * 100) + '%';
    setMath(span, String(v), String(v));
    plotTicks.appendChild(span);
  }
}

/* -------------------------------------------------------------------
   12.  Cursor overlay (Maxwell Plot Cursor Overlay.as)
   ------------------------------------------------------------------- */
function formatCDF(cdf) {
  if (cdf <= 0) return { left: '0.0%', right: '100.0%' };
  const cdfPercent = (cdf * 100).toFixed(1);
  const num = parseFloat(cdfPercent);
  if (num === 0) return { left: '<0.1%', right: '>99.9%' };
  if (num === 100) return { left: '>99.9%', right: '<0.1%' };
  return { left: cdfPercent + '%', right: (100 - num).toFixed(1) + '%' };
}
function pctLatex(str) {  // "93.5%", "<0.1%" -> latex
  return str.replace('%', '\\%').replace('<', '\\lt ').replace('>', '\\gt ');
}
function updateCursor() {
  plotCursor.hidden = !state.showCursor;
  escapeLabel.hidden = !state.allowEscape;
  if (state.allowEscape) escapeLabel.style.left = (xToPx(state.escapeSpeed) / PW * 100) + '%';
  if (!state.showCursor) return;

  const v = state.cursorSpeed;
  plotCursor.style.left = (xToPx(v) / PW * 100) + '%';
  plotCursor.setAttribute('aria-valuenow', String(Math.round(v)));
  setMath(cursorSpeedEl, Math.round(v) + '\\ \\mathrm{m/s}', Math.round(v) + ' m/s');

  const showInfo = state.showInfo && state.selectedGas != null;
  cursorInfoLeft.style.display = showInfo ? '' : 'none';
  cursorInfoRight.style.display = showInfo ? '' : 'none';

  let valueText = Math.round(v) + ' meters per second';
  if (showInfo) {
    const gas = state.gases[state.selectedGas];
    const a = speedParam(gas.def.mass, state.temperature);
    const cdf = maxwellCDF(a, v);
    const f = formatCDF(cdf);
    const symL = symbolToLatex(gas.def.symbol), symT = symbolToText(gas.def.symbol);
    cursorInfoLeft.innerHTML =
      `<span class="mjx" data-tex="${pctLatex(f.left)}">${f.left}</span> of ` +
      `<span class="mjx" data-tex="${symL}">${symT}</span> moves slower`;
    cursorInfoRight.innerHTML =
      `<span class="mjx" data-tex="${pctLatex(f.right)}">${f.right}</span> of ` +
      `<span class="mjx" data-tex="${symL}">${symT}</span> moves faster`;
    typesetChildren(cursorInfoLeft); typesetChildren(cursorInfoRight);
    valueText += `, ${f.left} of ${gas.def.name} moves slower, ${f.right} moves faster`;
  }
  plotCursor.setAttribute('aria-valuetext', valueText);
}
function typesetChildren(container) {
  container.querySelectorAll('.mjx[data-tex]').forEach(el => {
    if (mjReady()) { el.textContent = '\\(' + el.dataset.tex + '\\)'; queueTypeset(el); }
  });
}

/* -------------------------------------------------------------------
   13.  Proportions bars (custom accessible slider; Proportions Adjuster.as)
   ------------------------------------------------------------------- */
function buildProportions() {
  proportionBars.innerHTML = '';
  for (const id of state.order) {
    const gas = state.gases[id];
    const bar = document.createElement('div');
    bar.className = 'sim-bar';
    bar.dataset.id = id;
    bar.setAttribute('role', 'slider');
    bar.setAttribute('tabindex', '0');
    bar.setAttribute('aria-valuemin', '0');
    bar.setAttribute('aria-valuemax', '100');

    const track = document.createElement('div');
    track.className = 'sim-bar__track';
    const fill = document.createElement('div');
    fill.className = 'sim-bar__fill';
    fill.style.background = colorHex(gas.def.color);
    track.appendChild(fill);

    const label = document.createElement('div');
    label.className = 'sim-bar__label mjx';
    setMath(label, symbolToLatex(gas.def.symbol), symbolToText(gas.def.symbol));

    bar.appendChild(track);
    bar.appendChild(label);
    proportionBars.appendChild(bar);

    bar._fill = fill;
    wireBar(bar, id);
  }
  updateProportionsFromState();
}
function wireBar(bar, id) {
  const setFromClientY = (clientY) => {
    const track = bar.querySelector('.sim-bar__track');
    const rect = track.getBoundingClientRect();
    let frac = (rect.bottom - clientY) / rect.height;
    frac = Math.max(0, Math.min(1, frac));
    onProportionsChanged(id, frac);
  };
  bar.addEventListener('pointerdown', (e) => {
    if (state.running) { selectGas(id); return; }
    bar.setPointerCapture(e.pointerId);
    selectGas(id);
    bar.focus();
    setFromClientY(e.clientY);
    e.preventDefault();
  });
  bar.addEventListener('pointermove', (e) => {
    if (state.running) return;
    if (bar.hasPointerCapture && bar.hasPointerCapture(e.pointerId)) setFromClientY(e.clientY);
  });
  bar.addEventListener('keydown', (e) => {
    if (state.running) return;
    const gas = state.gases[id]; let f = gas.fraction; let handled = true;
    switch (e.key) {
      case 'ArrowUp': case 'ArrowRight': f += 0.05; break;
      case 'ArrowDown': case 'ArrowLeft': f -= 0.05; break;
      case 'PageUp': f += 0.2; break;
      case 'PageDown': f -= 0.2; break;
      case 'Home': f = 1; break;   // full amount
      case 'End': f = 0; break;
      default: handled = false;
    }
    if (handled) {
      e.preventDefault();
      selectGas(id);
      onProportionsChanged(id, Math.max(0, Math.min(1, f)));
    }
  });
  bar.addEventListener('focus', () => selectGas(id));
}
function updateProportionsFromState() {
  for (const bar of proportionBars.children) {
    const gas = state.gases[bar.dataset.id];
    if (!gas) continue;
    bar._fill.style.height = (gas.fraction * 100) + '%';
    bar.setAttribute('aria-valuenow', String(Math.round(gas.fraction * 100)));
    bar.setAttribute('aria-valuetext',
      `${gas.def.name} ${Math.round(gas.fraction * 100)} percent of full amount`);
    bar.classList.toggle('sim-bar--selected', bar.dataset.id === state.selectedGas);
  }
}

/* -------------------------------------------------------------------
   14.  Gas list (Gas List.as / Gas List Entry.as)
   ------------------------------------------------------------------- */
function buildGasList() {
  gasListEl.innerHTML = '';
  const sum = totalFraction();
  for (const id of state.order) {
    const gas = state.gases[id];
    const li = document.createElement('li');
    li.className = 'sim-gaslist__item';
    const btn = document.createElement('button');
    btn.type = 'button';
    btn.className = 'sim-gaslist__btn';
    btn.dataset.id = id;
    btn.setAttribute('aria-pressed', id === state.selectedGas ? 'true' : 'false');

    const dot = document.createElement('span');
    dot.className = 'sim-gaslist__dot';
    dot.style.background = colorHex(gas.def.color);
    dot.setAttribute('aria-hidden', 'true');

    const nameEl = document.createElement('span');
    nameEl.className = 'sim-gaslist__name mjx';
    setMath(nameEl, `\\text{${gas.def.name} (}${symbolToLatex(gas.def.symbol)}\\text{)}`,
            `${gas.def.name} (${symbolToText(gas.def.symbol)})`);

    const massEl = document.createElement('span');
    massEl.className = 'sim-gaslist__mass mjx';
    setMath(massEl, `${Math.round(gas.def.mass)}\\,\\mathrm{u}`, `${Math.round(gas.def.mass)} u`);

    const pctEl = document.createElement('span');
    pctEl.className = 'sim-gaslist__pct mjx';
    pctEl.dataset.role = 'pct';
    const pct = sum > 0 ? (100 * gas.fraction / sum) : 0;
    setMath(pctEl, `${pct.toFixed(1)}\\%`, `${pct.toFixed(1)}%`);

    btn.append(dot, nameEl, massEl, pctEl);
    btn.addEventListener('click', () => selectGas(id));
    li.appendChild(btn);
    gasListEl.appendChild(li);
  }
  updateGasListSelection();
}
function totalFraction() {
  let s = 0; for (const id of state.order) s += state.gases[id].fraction; return s;
}
function refreshPercentages() {
  const sum = totalFraction();
  for (const btn of gasListEl.querySelectorAll('.sim-gaslist__btn')) {
    const gas = state.gases[btn.dataset.id];
    const pctEl = btn.querySelector('[data-role="pct"]');
    const pct = sum > 0 ? (100 * gas.fraction / sum) : 0;
    setMath(pctEl, `${pct.toFixed(1)}\\%`, `${pct.toFixed(1)}%`);
  }
}
function updateGasListSelection() {
  for (const btn of gasListEl.querySelectorAll('.sim-gaslist__btn')) {
    const sel = btn.dataset.id === state.selectedGas;
    btn.classList.toggle('sim-gaslist__btn--selected', sel);
    btn.setAttribute('aria-pressed', sel ? 'true' : 'false');
  }
}

/* add-gas <select> (FComboBox behavior) */
function refreshAddGasSelect() {
  addGasSelect.innerHTML = '';
  if (state.order.length >= GAS_LIMIT) {
    const o = new Option('(limit reached)', '');
    addGasSelect.appendChild(o);
    addGasSelect.disabled = true;
    return;
  }
  addGasSelect.disabled = state.running;
  addGasSelect.appendChild(new Option('select gas to add', ''));
  for (const def of GAS_DEFS) {
    if (!state.gases[def.id]) addGasSelect.appendChild(new Option(def.name, def.id));
  }
  addGasSelect.value = '';
}

/* -------------------------------------------------------------------
   15.  Controller actions (Gas Retention Simulator.as)
   ------------------------------------------------------------------- */
function addGas(id) {
  if (state.gases[id] || state.order.length >= GAS_LIMIT) return;
  const gas = makeGas(GAS_BY_ID[id]);
  gas.fraction = 1;
  state.gases[id] = gas;
  state.order.push(id);
  setNumberOfParticles(gas, NUM_PARTICLES);
  recalcPlotScale();
  buildProportions();
  buildGasList();
  refreshAddGasSelect();
  selectGas(id);
  drawPlot();
  requestChamberRedraw();
  announce(`${gas.def.name} added. ${state.order.length} of ${GAS_LIMIT} gases in the chamber.`);
  updateChamberDesc();
}
function removeGas(id) {
  if (!state.gases[id]) return;
  const idx = state.order.indexOf(id);
  delete state.gases[id];
  state.order.splice(idx, 1);
  recalcPlotScale();
  buildProportions();
  buildGasList();
  refreshAddGasSelect();
  // selection follows the AS logic: pick neighbour, else last, else null
  let next = null;
  if (state.order.length > 0) {
    next = idx < state.order.length ? state.order[idx] : state.order[state.order.length - 1];
  }
  selectGas(next);
  drawPlot();
  requestChamberRedraw();
  announce(`Gas removed. ${state.order.length} of ${GAS_LIMIT} gases in the chamber.`);
  updateChamberDesc();
}
function selectGas(id) {
  state.selectedGas = id;
  updateGasListSelection();
  updateProportionsFromState();
  updateCursor();
  drawPlot();
  removeGasButton.disabled = !(id != null && !state.running);
}
function onProportionsChanged(id, fraction) {
  const gas = state.gases[id];
  gas.fraction = fraction;
  setNumberOfParticles(gas, Math.round(NUM_PARTICLES * fraction));
  updateProportionsFromState();
  refreshPercentages();
  drawPlot();
  updateCursor();
  requestChamberRedraw();
  updateChamberDesc();
}
function resetProportions() {
  for (const id of state.order) {
    const gas = state.gases[id];
    gas.fraction = 1;
    setNumberOfParticles(gas, NUM_PARTICLES);
  }
  updateProportionsFromState();
  refreshPercentages();
  drawPlot();
  updateCursor();
  requestChamberRedraw();
  announce('Proportions reset. All gases restored to their full amounts.');
  updateChamberDesc();
}

function setRunning(run) {
  if (run === state.running) return;
  state.running = run;
  if (run) {
    startButton.textContent = 'stop simulation';
    if (state.allowEscape) computeDecayConstants();
    state.simStartTime = performance.now();
    lastTime = performance.now();
    startLoop();
  } else {
    startButton.textContent = 'start simulation';
  }
  syncEnabledStates();
  announce(run ? 'Simulation running.' : 'Simulation stopped.');
  updateChamberDesc();
}
function syncEnabledStates() {
  const running = state.running;
  tempSlider.disabled = running;
  escapeSlider.disabled = running || !state.allowEscape;
  allowEscapeCheck.disabled = running;
  resetProportionsButton.disabled = running || state.order.length === 0;
  removeGasButton.disabled = running || state.selectedGas == null;
  refreshAddGasSelect();
  for (const bar of proportionBars.children) bar.setAttribute('aria-disabled', running ? 'true' : 'false');
}

/* -------------------------------------------------------------------
   16.  Readouts, live region
   ------------------------------------------------------------------- */
function updateReadouts() {
  setMath(tempReadout, `${Math.round(state.temperature)}\\,\\mathrm{K}`, `${Math.round(state.temperature)} K`);
  tempSlider.setAttribute('aria-valuetext', `temperature ${Math.round(state.temperature)} kelvin`);
  setMath(escapeReadout, `${Math.round(state.escapeSpeed)}\\,\\mathrm{m/s}`, `${Math.round(state.escapeSpeed)} m/s`);
  escapeSlider.setAttribute('aria-valuetext', `escape speed ${Math.round(state.escapeSpeed)} meters per second`);
}
function announce(msg) { liveStatus.textContent = msg; }
let liveThrottle = 0;
function throttledLiveUpdate() {
  const now = performance.now();
  if (now - liveThrottle < 2000) return;
  liveThrottle = now;
  refreshPercentages();
  updateChamberDesc();
}
function updateChamberDesc() {
  if (state.order.length === 0) {
    chamberDesc.textContent = 'The chamber is empty. Choose a gas from the "select gas to add" menu in the Gases panel to begin.';
    return;
  }
  const sum = totalFraction();
  const parts = state.order.map(id => {
    const g = state.gases[id];
    const pct = sum > 0 ? (100 * g.fraction / sum) : 0;
    return `${g.def.name} ${pct.toFixed(0)} percent`;
  });
  const temp = `temperature ${Math.round(state.temperature)} kelvin`;
  const esc = state.allowEscape ? `, escape allowed above ${Math.round(state.escapeSpeed)} meters per second` : '';
  chamberDesc.textContent =
    `Chamber holds ${state.order.length} gas${state.order.length > 1 ? 'es' : ''}: ${parts.join(', ')}. ${temp}${esc}. ` +
    (state.running ? 'Simulation running.' : 'Simulation stopped.');
}

/* -------------------------------------------------------------------
   17.  Reset to initial state (masthead "sim-reset")
   ------------------------------------------------------------------- */
function resetAll() {
  if (state.running) setRunning(false);
  for (const id of [...state.order]) { delete state.gases[id]; }
  state.order = [];
  state.selectedGas = null;
  state.temperature = DEFAULTS.temperature;
  state.escapeSpeed = DEFAULTS.escapeSpeed;
  state.allowEscape = false;
  state.showCursor = false;
  state.showInfo = true;
  state.cursorSpeed = 1000;
  state.yScaleMag = 0;

  tempSlider.value = DEFAULTS.temperature;
  escapeSlider.value = DEFAULTS.escapeSpeed;
  allowEscapeCheck.checked = false;
  showCursorCheck.checked = false;
  showInfoCheck.checked = true;
  showInfoCheck.disabled = true;

  buildProportions();
  buildGasList();
  refreshAddGasSelect();
  syncEnabledStates();
  updateReadouts();
  updateCursor();
  drawPlot();
  requestChamberRedraw();
  updateChamberDesc();
  announce('Simulation reset. The chamber is empty and all controls are at their starting values.');
}

/* -------------------------------------------------------------------
   18.  Wiring
   ------------------------------------------------------------------- */
function wireControls() {
  tempSlider.addEventListener('input', () => {
    state.temperature = parseFloat(tempSlider.value);
    updateReadouts();
    recalcPlotScale();  // yScale is locked to min-temp; set unchanged, but keep parity call
    drawPlot();
    updateCursor();
    updateChamberDesc();
  });
  tempSlider.addEventListener('change', () =>
    announce(`Temperature ${Math.round(state.temperature)} kelvin.`));

  escapeSlider.addEventListener('input', () => {
    state.escapeSpeed = parseFloat(escapeSlider.value);
    updateReadouts();
    updateCursor();
    drawPlot();
    updateChamberDesc();
  });
  escapeSlider.addEventListener('change', () =>
    announce(`Escape speed ${Math.round(state.escapeSpeed)} meters per second.`));

  allowEscapeCheck.addEventListener('change', () => {
    state.allowEscape = allowEscapeCheck.checked;
    syncEnabledStates();
    updateReadouts();
    updateCursor();
    drawPlot();
    updateChamberDesc();
    announce(state.allowEscape ? 'Escape from chamber allowed.' : 'Escape from chamber disabled.');
  });

  showCursorCheck.addEventListener('change', () => {
    state.showCursor = showCursorCheck.checked;
    showInfoCheck.disabled = !state.showCursor;
    updateCursor();
    announce(state.showCursor ? 'Draggable speed cursor shown.' : 'Speed cursor hidden.');
  });
  showInfoCheck.addEventListener('change', () => {
    state.showInfo = showInfoCheck.checked;
    updateCursor();
  });

  startButton.addEventListener('click', () => setRunning(!state.running));

  addGasSelect.addEventListener('change', () => {
    const id = addGasSelect.value;
    if (id) addGas(id);
  });
  removeGasButton.addEventListener('click', () => {
    if (state.selectedGas) removeGas(state.selectedGas);
  });
  resetProportionsButton.addEventListener('click', resetProportions);

  // masthead reset
  document.addEventListener('sim-reset', resetAll);

  // cursor drag + keyboard
  wireCursor();

  window.addEventListener('resize', () => { placeTicks(); });
}

function wireCursor() {
  const setFromClientX = (clientX) => {
    const rect = plotCanvas.getBoundingClientRect();
    let frac = (clientX - rect.left) / rect.width;
    frac = Math.max(0, Math.min(1, frac));
    state.cursorSpeed = frac * (X_MAX - X_MIN) + X_MIN;
    updateCursor();
  };
  let dragging = false;
  const onDown = (e) => {
    if (!state.showCursor) return;
    dragging = true;
    plotArea.setPointerCapture(e.pointerId);
    plotCursor.focus();
    setFromClientX(e.clientX);
    e.preventDefault();
  };
  plotArea.addEventListener('pointerdown', onDown);
  plotArea.addEventListener('pointermove', (e) => { if (dragging) setFromClientX(e.clientX); });
  plotArea.addEventListener('pointerup', (e) => {
    if (dragging) { dragging = false; announceCursor(); }
  });
  plotCursor.addEventListener('keydown', (e) => {
    let v = state.cursorSpeed; let handled = true;
    switch (e.key) {
      case 'ArrowRight': case 'ArrowUp': v += 25; break;
      case 'ArrowLeft': case 'ArrowDown': v -= 25; break;
      case 'PageUp': v += 100; break;
      case 'PageDown': v -= 100; break;
      case 'Home': v = X_MIN; break;
      case 'End': v = X_MAX; break;
      default: handled = false;
    }
    if (handled) {
      e.preventDefault();
      state.cursorSpeed = Math.max(X_MIN, Math.min(X_MAX, v));
      updateCursor();
      announceCursor();
    }
  });
}
function announceCursor() {
  announce(plotCursor.getAttribute('aria-valuetext'));
}

/* position ticks/escape label after layout (they use % so mostly automatic) */
function placeTicks() { /* percentages handle layout; kept for resize hook */ }

/* -------------------------------------------------------------------
   19.  Init
   ------------------------------------------------------------------- */
function init() {
  chamberCanvas.style.aspectRatio = CW + ' / ' + CH;
  plotCanvas.style.aspectRatio = PW + ' / ' + PH;
  sizeAllCanvases();
  setMath($('plotXTitle'), '\\text{Molecular Speed } (\\mathrm{m/s})', 'Molecular Speed (m/s)');
  buildTicks();
  buildProportions();
  buildGasList();
  refreshAddGasSelect();
  syncEnabledStates();
  updateReadouts();
  updateCursor();
  updateChamberDesc();
  wireControls();
  window.addEventListener('resize', sizeAllCanvases);
}

// redefine the foundation equation-init hook (kl-unl.js calls it on load)
window.klunlInitEqn = function () { /* equations authored inline via setMath */ };

if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', init);
else init();
