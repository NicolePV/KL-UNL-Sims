'use strict';

/* =====================================================================
   Radial Velocity Simulator — ported from AS1 (radialVelocitySimulator012)
   Single state object + single render() per panel; canvas is the visual
   layer only, all interactive controls are native HTML elements.
   ===================================================================== */

/* -------------------------------------------------------------------
   1. Orbit mechanics (Kepler's equation, solved by Newton's method —
      same iteration/tolerance as the AS source: |ΔE| < 0.001 rad).
   ------------------------------------------------------------------- */

// Solve Kepler's equation M = E - e*sin(E) for the eccentric anomaly E.
function solveEccentricAnomaly(meanAnomaly, e) {
  let ea0 = 0, ea1 = meanAnomaly, iter = 0;
  do {
    ea0 = ea1;
    ea1 = ea0 + (meanAnomaly + e * Math.sin(ea0) - ea0) / (1 - e * Math.cos(ea0));
    iter++;
  } while (Math.abs(ea1 - ea0) > 0.001 && iter < 100);
  return ea1;
}

// True anomaly from eccentric anomaly: tan(ν/2) = sqrt((1+e)/(1-e)) * tan(E/2)
function trueAnomalyFromEccentric(ea, e) {
  return 2 * Math.atan(Math.sqrt((1 + e) / (1 - e)) * Math.tan(ea / 2));
}

/* -------------------------------------------------------------------
   2. Number formatting (verbatim from the AS source's toFixed /
      Math.toSigDigits / Number.prototype.toScientific polyfills, which
      differ from native JS rounding in their exact carry/round rules —
      keep byte-identical output).
   ------------------------------------------------------------------- */

function asToFixed(x, f) {
  if (isNaN(x) || !isFinite(x)) return 'error';
  f = Math.trunc(f);
  if (isNaN(f) || !isFinite(f)) return 'error';
  if (f <= 0) {
    const k = Math.pow(10, -f);
    return String(k * Math.round(x / k));
  }
  if (f > 20) f = 20;
  let s = '';
  if (x < 0) { s = '-'; x = -x; }
  let m;
  if (x < 1e21) {
    const n = Math.round(x * Math.pow(10, f));
    m = (n === 0) ? '0' : n.toString();
    if (f > 0) {
      let k = m.length;
      if (k <= f) {
        m = '0'.repeat(f + 1 - k) + m;
        k = f + 1;
      }
      m = m.substr(0, k - f) + '.' + m.substr(k - f);
    }
  } else {
    m = x.toString();
  }
  return s + m;
}

function toSigDigits(num, digs) {
  digs = Math.abs(Math.trunc(digs));
  if (!isFinite(digs) || !isFinite(num)) return NaN;
  if (num === 0 || digs === 0) return 0;
  if (digs > 15) digs = 15;
  let sign = 1;
  if (num < 0) { sign = -1; num = Math.abs(num); }
  const tmp = Math.floor(Math.log(num) / Math.LN10);
  const fact = Math.pow(10, digs - (1 + tmp));
  return sign * (Math.round(fact * num) / fact);
}

// Returns {string, significand, magnitude} — string is the MathJax-ready form.
function toScientific(x, digits) {
  if (!isFinite(x) || isNaN(x)) return null;
  let s, m;
  if (x === 0) {
    s = (0).toFixed(digits - 1);
    m = 0;
  } else {
    let sign = '';
    if (x < 0) { sign = '-'; x = -x; }
    m = Math.floor(Math.log(x) / Math.LN10);
    s = (x / Math.pow(10, m)).toFixed(digits - 1);
    if (Number(s) >= 10) { s = (1).toFixed(digits - 1); m += 1; }
    s = sign + s;
  }
  return { significand: s, magnitude: m, string: s + '\\times10^{' + m + '}' };
}

/* Formats a number the way the main controller's getFormattedNumber() does:
   `digits` significant figures, capped at `kLimit` decimal places. */
function getFormattedNumber(x, digits, kLimit) {
  const m = Math.floor(Math.log(x) / Math.LN10);
  let k = digits - 1 - m;
  if (k <= 0) return String(toSigDigits(x, digits));
  if (k > kLimit) k = kLimit;
  return x.toFixed(k);
}

/* -------------------------------------------------------------------
   3. Star physics (verbatim from Number Functions.as / the main
      controller's DoAction_1 — same polynomial fits & spectral tables).
   ------------------------------------------------------------------- */

// Mass-luminosity relation, L in solar luminosities, mass in solar masses.
function getLuminosityFromMass(mass) {
  if (mass < 0.43) return 0.232220431737728 * Math.pow(mass, 2.26);
  return Math.pow(mass, 3.99);
}

// Empirical fit of log(T_eff) as a 6th-order polynomial in log(L).
function getTempFromLuminosity(lum) {
  const logL = Math.log(lum) / Math.LN10;
  let a, b, c, d, e, f, g;
  if (logL < -1.61) { a=3.76424847491303; b=0.140316436337353; c=0.0139709648834783; d=0.00146257952166353; e=0.000114203991057792; f=0.00000534009520193973; g=1.00897501873505e-7; }
  else if (logL < 0.22) { a=3.76404749064937; b=0.139720836051662; c=0.0131949471107482; d=0.000878016217920958; e=-0.00016087678534046; f=-0.0000718923778642037; g=-0.0000098430921759891; }
  else if (logL < 1.48) { a=3.76404935999916; b=0.139700505514371; c=0.0132834512392025; d=0.000681148684168764; e=0.0000515647954029831; f=-0.000230931527900807; g=0.0000134429776870977; }
  else if (logL < 2.61) { a=3.76208682178285; b=0.14541668375348; c=0.00684584757963743; d=0.00396076543835346; e=-0.000464655201610208; f=-0.000381007438333072; g=0.0000623586254118745; }
  else if (logL < 3.62) { a=3.7785507438146; b=0.129897095940252; c=0.00142810707728862; d=0.0167045399494531; e=-0.00693250229182094; f=0.00103845665508301; g=-0.000055992055857869; }
  else if (logL < 5.43) { a=3.94943146036608; b=-0.154281251321452; c=0.1979230342627; d=-0.055596100619304; e=0.00799539610207913; f=-0.000600846748510063; g=0.0000187770530697032; }
  else { a=4.36797099518548; b=-0.314871178456464; c=0.143399968097621; d=-0.0130740129137381; e=-0.00159255369850374; f=0.000357973227398207; g=-0.000017804556980593; }
  const logT = a + logL * (b + logL * (c + logL * (d + logL * (e + logL * (f + logL * g)))));
  return Math.pow(10, logT);
}

// Stefan-Boltzmann: R/Rsun = sqrt(L/Lsun) * (Tsun/T)^2
function getRadiusFromTempAndLuminosity(temp, luminosity) {
  return 33736108.2311059 * Math.sqrt(luminosity) / (temp * temp);
}

const spectralTypesAndTemps = {
  v: [{type:7,teff:38000},{type:9,teff:33200},{type:9.5,teff:31450},{type:10,teff:29700},{type:11,teff:25600},{type:12,teff:22300},{type:13,teff:19000},{type:14,teff:17200},{type:15,teff:15400},{type:16,teff:14100},{type:17,teff:13000},{type:18,teff:11800},{type:19,teff:10700},{type:20,teff:9480},{type:22,teff:8810},{type:25,teff:8160},{type:27,teff:7930},{type:30,teff:7020},{type:32,teff:6750},{type:35,teff:6530},{type:37,teff:6240},{type:40,teff:5930},{type:42,teff:5830},{type:44,teff:5740},{type:46,teff:5620},{type:50,teff:5240},{type:52,teff:5010},{type:54,teff:4560},{type:55,teff:4340},{type:57,teff:4040},{type:60,teff:3800},{type:61,teff:3680},{type:62,teff:3530},{type:63,teff:3380},{type:64,teff:3180},{type:65,teff:3030},{type:66,teff:2850}],
  iii: [{type:40,teff:5910},{type:44,teff:5190},{type:46,teff:5050},{type:48,teff:4960},{type:50,teff:4810},{type:51,teff:4610},{type:52,teff:4500},{type:53,teff:4320},{type:54,teff:4080},{type:55,teff:3980},{type:60,teff:3820},{type:61,teff:3780},{type:62,teff:3710},{type:63,teff:3630},{type:64,teff:3560},{type:65,teff:3420},{type:66,teff:3250}],
  i: [{type:9,teff:32500},{type:10,teff:26000},{type:11,teff:20700},{type:12,teff:17800},{type:13,teff:15600},{type:14,teff:13900},{type:15,teff:13400},{type:16,teff:12700},{type:17,teff:12000},{type:18,teff:11200},{type:19,teff:10500},{type:20,teff:9730},{type:21,teff:9230},{type:22,teff:9080},{type:25,teff:8510},{type:30,teff:7700},{type:32,teff:7170},{type:35,teff:6640},{type:38,teff:6100},{type:40,teff:5510},{type:43,teff:4980},{type:48,teff:4590},{type:50,teff:4420},{type:51,teff:4330},{type:52,teff:4260},{type:53,teff:4130},{type:55,teff:3850},{type:60,teff:3650},{type:61,teff:3550},{type:62,teff:3450},{type:63,teff:3200},{type:64,teff:2980}]
};

function getSpectralTypeFromTemp(temp, lumClass) {
  let cls = (lumClass || 'v').toLowerCase();
  const typesArray = spectralTypesAndTemps[cls];
  if (!typesArray) return null;
  const spectralType = { class: cls.toUpperCase() };
  const len = typesArray.length;
  let i = 0;
  while (i < len && temp <= typesArray[i].teff) i++;
  let i1, i2;
  if (i === 0) { i1 = 0; i2 = 1; }
  else if (i === len) { i1 = len - 2; i2 = len - 1; }
  else { i1 = i - 1; i2 = i; }
  const m = (typesArray[i2].type - typesArray[i1].type) / (typesArray[i2].teff - typesArray[i1].teff);
  const b = typesArray[i1].type - m * typesArray[i1].teff;
  const spectralTypeNumber = m * temp + b;
  if (!isFinite(spectralTypeNumber) || spectralTypeNumber < 0 || spectralTypeNumber >= 70) return null;
  const base = Math.floor(spectralTypeNumber / 10);
  const excess = spectralTypeNumber - 10 * base;
  const letters = ['O', 'B', 'A', 'F', 'G', 'K', 'M'];
  if (base < 0 || base >= letters.length) return null;
  spectralType.type = letters[base];
  spectralType.number = excess;
  return spectralType;
}

// Blackbody color approximation (Binary System Component.getColorFromTemp).
function getColorFromTemp(temp) {
  if (temp < 1000) temp = 1000; else if (temp > 40000) temp = 40000;
  const logT = Math.log(temp) / Math.LN10, logT2 = logT * logT, logT3 = logT * logT2;
  let r = 22686.34111 - logT * 15082.52755 + logT2 * 3375.333832 - logT3 * 252.4073853;
  r = Math.min(255, Math.max(0, r));
  let g = (temp <= 6500)
    ? -811.6499145 + logT * 36.97365953 + logT2 * 160.7861677 - logT3 * 25.57573664
    : 13836.23586 - logT * 9069.078214 + logT2 * 2015.254756 - logT3 * 149.7766966;
  g = Math.min(255, Math.max(0, g));
  let b = -11545.34298 + logT * 8529.658165 - logT2 * 2150.198586 + logT3 * 190.0306573;
  b = Math.min(255, Math.max(0, b));
  return { r: r | 0, g: g | 0, b: b | 0 };
}
function rgbToCss(c) { return `rgb(${c.r},${c.g},${c.b})`; }

/* -------------------------------------------------------------------
   4. MathJax rendering helper. Every symbol/unit/subscript in the UI is
      typeset via MathJax (hard rule 8/8a); a throttled queue avoids
      re-typesetting on every slider-drag tick. Screen-reader text is
      kept in a parallel plain-language string (see updateSrText()).
   ------------------------------------------------------------------- */
// el -> latex string that still needs typesetting. setMath shows the
// readable plain-text fallback immediately (which looks the same as the
// typeset output because of mtextInheritFont) and DEBOUNCES the MathJax
// typeset, so a fast slider drag that rewrites a readout every frame can't
// thrash MathJax and leave the node half-rendered / blank. `data-rendered`
// records the latex a node is currently MathJax-rendered to, so unchanged
// values are skipped.
const mjPending = new Map();
let mjTimer = null, mjBusy = false;
function mjReady() { return !!(window.MathJax && window.MathJax.typesetPromise); }
function setMath(el, latex, fallback) {
  if (!el) return;
  el.dataset.fallback = fallback;
  if (el.dataset.rendered === latex && !mjPending.has(el)) return; // already correct
  el.textContent = fallback;          // readable immediately, no raw LaTeX flash
  el.dataset.rendered = '';
  mjPending.set(el, latex);
  scheduleMathFlush();
}
function scheduleMathFlush() {
  if (mjTimer) clearTimeout(mjTimer);
  // short debounce: coalesces a burst of drag-driven updates; when the drag
  // pauses (>90ms) the final values get typeset once.
  mjTimer = setTimeout(flushMath, 90);
}
function flushMath() {
  mjTimer = null;
  if (!mjReady() || mjBusy || mjPending.size === 0) {
    if (mjPending.size) scheduleMathFlush();
    return;
  }
  const batch = [];
  for (const [el, latex] of mjPending) { el.textContent = '\\(' + latex + '\\)'; batch.push([el, latex]); }
  mjPending.clear();
  mjBusy = true;
  window.MathJax.typesetPromise(batch.map(b => b[0]))
    .then(() => { batch.forEach(([el, latex]) => { el.dataset.rendered = latex; }); })
    .catch(() => {})
    .finally(() => { mjBusy = false; if (mjPending.size) scheduleMathFlush(); });
}
function mjOnReady() { scheduleMathFlush(); }  // typeset anything authored before MathJax loaded
if (window.MathJax) {
  const prevReady = window.MathJax.startup && window.MathJax.startup.ready;
  window.MathJax.startup = window.MathJax.startup || {};
  window.MathJax.startup.ready = () => {
    if (window.MathJax.startup.defaultReady) window.MathJax.startup.defaultReady();
    if (prevReady) try { prevReady(); } catch (e) {}
    mjOnReady();
  };
}
// kl-unl.js calls this on load; this sim authors its equations inline via setMath.
window.klunlInitEqn = function () {};

/* -------------------------------------------------------------------
   5. Slider controller — port of Slider Logic Class v6.as. A native
      <input type="range"> holds a normalized 0..1 "parameter"; this
      layer maps that parameter to the real value through the same
      linear/logarithmic scale and significant-digits/fixed-digits
      rounding as the original, so the ROUNDED value (not the raw
      continuous one) is what feeds the physics, exactly like the
      original slider snapping while being dragged.
   ------------------------------------------------------------------- */
function makeValueLogic(opts) {
  const sMode = opts.scalingMode === 'logarithmic' ? 1 : 0;
  const pMode = opts.precisionMode === 'significant digits' ? 0 : 1;
  const digs = opts.precision;
  const minV = opts.minValue, maxV = opts.maxValue;
  const logMinV = Math.log(minV), logMaxV = Math.log(maxV);
  const lowerSigLimit = pMode === 0 ? Math.pow(10, digs - 1) : null;
  const upperSigLimit = pMode === 0 ? Math.pow(10, digs) : null;
  const minIncrement = pMode === 1 ? Math.pow(10, -digs) : null;
  function clamp(x) { return x < minV ? minV : (x > maxV ? maxV : x); }
  function valueObjectFromValue(x) {
    x = clamp(x);
    if (pMode === 0) {
      let mag = Math.floor(Math.log(x) / Math.LN10);
      let sig = Math.round(x * lowerSigLimit / Math.pow(10, mag));
      if (sig >= upperSigLimit) { sig = lowerSigLimit; mag++; }
      return { value: sig / lowerSigLimit * Math.pow(10, mag), mag, sig };
    }
    return { value: minIncrement * Math.round(x / minIncrement) };
  }
  function valueStringFromValueObject(vObj) {
    const f = pMode === 0 ? (digs - vObj.mag - 1) : digs;
    return f > 0 ? asToFixed(vObj.value, f) : String(vObj.value);
  }
  function valueFromParameter(t) {
    return sMode === 0 ? (minV + t * (maxV - minV)) : Math.exp(logMinV + t * (logMaxV - logMinV));
  }
  function parameterFromValue(v) {
    return sMode === 0 ? (v - minV) / (maxV - minV) : (Math.log(v) - logMinV) / (logMaxV - logMinV);
  }
  return { valueObjectFromValue, valueStringFromValueObject, valueFromParameter, parameterFromValue, minV, maxV };
}

// `fieldEl` is a plain editable <input type="text"> holding only the bare
// number (Standard Slider v6's valueField); `unitsEl` is a separate element
// for the (possibly subscripted/MathJax) unit text (its unitsTextMC) drawn
// OUTSIDE the box, not appended into the editable value itself.
function bindSlider(input, fieldEl, unitsEl, logic, cfg) {
  input.min = '0'; input.max = '1'; input.step = cfg.step || '0.001';
  input.setAttribute('aria-label', cfg.quantity);
  if (fieldEl) {
    // The field's accessible name must stand alone (a screen-reader user
    // may only ever interact with the field, not the paired slider), so it
    // states the unit too, even though the unit's own <span> is aria-hidden.
    fieldEl.setAttribute('aria-label', cfg.quantity + (cfg.unitSpoken ? ` in ${cfg.unitSpoken}` : ''));
  }
  if (unitsEl) setMath(unitsEl, cfg.unitsLatex || '', cfg.unitsPlain || '');
  const api = { el: input, fieldEl, value: logic.minV, valueString: '' };
  function apply(rawValue, fromUser) {
    const vObj = logic.valueObjectFromValue(rawValue);
    const t = logic.parameterFromValue(vObj.value);
    input.value = String(Math.min(1, Math.max(0, t)));
    const valueString = logic.valueStringFromValueObject(vObj);
    api.value = vObj.value;
    api.valueString = valueString;
    // Always reformat the field (even mid-focus): this runs either from the
    // field's own Enter/blur commit (must re-render "1.756" -> "1.76") or
    // from the slider/reset/preset path, and the field + range slider can
    // never be focused at the same time, so there's nothing to clobber.
    if (fieldEl) fieldEl.value = valueString;
    input.setAttribute('aria-valuetext', cfg.spoken(vObj.value, valueString));
    if (cfg.onChange) cfg.onChange(vObj.value, fromUser);
  }
  input.addEventListener('input', () => {
    apply(logic.valueFromParameter(parseFloat(input.value)), true);
  });
  // A native range's arrow keys step by the `step` attribute, which here is
  // 0.001 of the NORMALIZED 0..1 parameter -- ~1000 presses to cross a range,
  // far too slow. Handle the keys explicitly and step by a percentage of the
  // range instead (1% arrows / 10% Page), keeping `step` fine so dragging
  // stays precise. The loop nudges further when significant/fixed-digit
  // rounding would otherwise leave the displayed value unchanged, so every
  // press is guaranteed to move the value (matching the AS grabber's
  // one-tick-per-keypress behaviour, just at a usable pace).
  function stepByFraction(frac) {
    const prev = api.value;
    let t = logic.parameterFromValue(prev);
    for (let i = 0; i < 250; i++) {
      t = Math.min(1, Math.max(0, t + frac));
      const v = logic.valueObjectFromValue(logic.valueFromParameter(t)).value;
      if (v !== prev || t <= 0 || t >= 1) { apply(v, true); return; }
    }
  }
  input.addEventListener('keydown', e => {
    let frac = 0;
    if (e.key === 'ArrowRight' || e.key === 'ArrowUp') frac = 0.01;
    else if (e.key === 'ArrowLeft' || e.key === 'ArrowDown') frac = -0.01;
    else if (e.key === 'PageUp') frac = 0.1;
    else if (e.key === 'PageDown') frac = -0.1;
    else if (e.key === 'Home') { e.preventDefault(); apply(logic.valueFromParameter(0), true); return; }
    else if (e.key === 'End') { e.preventDefault(); apply(logic.valueFromParameter(1), true); return; }
    else return;
    e.preventDefault();
    stepByFraction(frac);
  });
  if (fieldEl) {
    // Typed values commit on Enter or on blur (Standard Slider v6's
    // onKeyDown/onKillFocus); invalid/empty text just reverts to the
    // current formatted value rather than being silently accepted.
    const commit = () => {
      const parsed = parseFloat(fieldEl.value);
      if (isFinite(parsed) && !isNaN(parsed)) apply(parsed, true);
      else fieldEl.value = api.valueString;
    };
    fieldEl.addEventListener('keydown', e => { if (e.key === 'Enter') { commit(); fieldEl.blur(); } });
    fieldEl.addEventListener('blur', commit);
  }
  api.set = (v, fromUser) => apply(v, !!fromUser);
  return api;
}

/* -------------------------------------------------------------------
   6. State (single source of truth). Mirrors DefineSprite_244's frame
      script globals (the main controller / "document class").
   ------------------------------------------------------------------- */
const state = {
  // physical parameters (units noted per slider config below)
  starMass: 1, planetMass: 1, separation: 1, eccentricity: 0.2,
  inclination: 90, longitude: 45,
  // orbital phase, shared by the animation clock, the RV plot cursor and
  // the 3D visualization (RadialVelocityComponent.phaseChangeHandler keeps
  // these three in lockstep — see onCursorPhaseChanged/onSliderPhaseChanged)
  phase: 0,
  // horizontal pan of the RV plot's phase axis (drag-the-background gesture);
  // initPhaseOffset is -0.25 in the original, but the AS setter normalizes
  // into [0,1) — setPhaseOffset does (arg % 1 + 1) % 1 — so the stored value
  // is 0.75. Keeping it normalized here is what makes the two wrapped curve
  // copies (at plotAreaX and plotAreaX - PW) cover the full plot width.
  phaseOffset: 0.75,
  noise: 15, numMeasurements: 150, animRate: 0.0005,
  showCurve: true, showMeasurements: false, showPanels: false,
  animating: false,
  // free-space view orientation (degrees), shared by the celestial-sphere
  // direction arrows and the embedded Binary System Component
  theta: 80, phi: 45,
  presetIndex: 0,
};

const presetsList = [
  { name: '1. Option A',    starMass: 1,    planetMass: 1,     eccentricity: 0,    separation: 1,     inclination: 90, longitude: 0 },
  { name: '2. Option B',    starMass: 1,    planetMass: 1,     eccentricity: 0.4,  separation: 1,     inclination: 90, longitude: 0 },
  { name: '3. Option C',    starMass: 1,    planetMass: 0.05,  eccentricity: 0,    separation: 1,     inclination: 90, longitude: 0 },
  { name: '4. Option D',    starMass: 1,    planetMass: 0.00315, eccentricity: 0,  separation: 1,     inclination: 90, longitude: 0 },
  { name: '5. HD 68988 b',  starMass: 1.2,  planetMass: 1.9,   eccentricity: 0.14, separation: 0.071, inclination: 90, longitude: 40 },
  { name: '6. HD 33564 b',  starMass: 1.25, planetMass: 9.1,   eccentricity: 0.34, separation: 1.1,   inclination: 90, longitude: 205 },
  { name: '7. HD 39091 b',  starMass: 1.1,  planetMass: 10.35, eccentricity: 0.62, separation: 3.29,  inclination: 90, longitude: 331 },
];
const noMeasurementsNoise = 0.1;

/* -------------------------------------------------------------------
   7. Radial-velocity physics + plot rendering
      (Radial Velocity Component.as, ported to plain functions).
   ------------------------------------------------------------------- */
const G_CONST = 6.673e-11;
const MSUN = 1.98892e30, MJUP = 1.899e27, AU_M = 149598000000;
const NUM_FRESH_MEASUREMENTS = 40; // RadialVelocityComponentClass default, unchanged by this sim

// Kepler's third law + RV semi-amplitude:
//   P = sqrt(4*pi^2*a^3 / (G*(m1+m2)))
//   K = (2*pi/P) * a1*sin(i) / sqrt(1-e^2),   a1 = m2/(m1+m2) * a   (star's orbit about the barycenter)
//   center-of-mass velocity offset = K*e*cos(omega)  (omega = longitude of periastron)
function computeRVParams(starMassSun, planetMassJup, separationAU, eccentricity, inclinationDeg, longitudeDeg) {
  const mass1 = starMassSun * MSUN, mass2 = planetMassJup * MJUP;
  const a2 = separationAU * AU_M;
  const a1 = mass2 / mass1 * a2;
  const argument = longitudeDeg * Math.PI / 180;
  const inclination = inclinationDeg * Math.PI / 180;
  const period = Math.sqrt(39.47841760435743 * a2 * a2 * a2 / (G_CONST * (mass1 + mass2))); // seconds
  const K = 6.283185307179586 / period * a1 * Math.sin(inclination) / Math.sqrt(1 - eccentricity * eccentricity);
  return {
    amplitude: K,
    centerVelocity: K * eccentricity * Math.cos(argument),
    periodDays: period / 86400,
    eccentricity, argument,
  };
}

// Actual radial velocity at orbital phase p (0..1): phase is uniform in MEAN
// anomaly (Kepler's 2nd law / uniform areal velocity), so v(phase) requires
// solving Kepler's equation for the eccentric -> true anomaly. The full
// line-of-sight velocity is K*cos(w+ta) + K*e*cos(w) (the second term is the
// centre-of-mass velocity offset). The AS source draws only the first term
// but in a frame whose vertical centre reads centerVelocity; this port maps
// the curve in the actual-velocity frame (the one the axis labels and
// crosshair use, via yAxisMin/yAxisMax), so the centerVelocity offset must
// be included here or eccentric curves shift out of the plot box.
function radialVelocityAtPhase(rv, phase) {
  const ma = ((phase % 1) + 1) % 1 * 6.283185307179586;
  const ea = solveEccentricAnomaly(ma, rv.eccentricity);
  const ta = trueAnomalyFromEccentric(ea, rv.eccentricity);
  return rv.centerVelocity + rv.amplitude * Math.cos(rv.argument + ta);
}

// "Nice" tick spacing for the Y axis (RadialVelocityComponentClass.updateVerticalScale).
function computeYTicks(min, max, yScalePxPerUnit, minScreenYSpacing) {
  const minimumSpacing = minScreenYSpacing / yScalePxPerUnit;
  let majorSpacing = Math.pow(10, Math.ceil(Math.log(minimumSpacing) / Math.LN10));
  let multiple;
  if (majorSpacing / 2 > minimumSpacing) { majorSpacing /= 2; multiple = 5; }
  else { multiple = 2; }
  const minorSpacing = majorSpacing / multiple;
  const startTickNum = Math.ceil(min / minorSpacing);
  const tickNumLimit = 1 + Math.floor(max / minorSpacing);
  const f = -Math.floor(Math.log(majorSpacing) / Math.LN10);
  const ticks = [];
  for (let i = startTickNum; i < tickNumLimit; i++) {
    const value = minorSpacing * i;
    ticks.push({ value, major: i % multiple === 0, label: i % multiple === 0 ? asToFixed(value, f) : null });
  }
  return ticks;
}

const xAxisTickmarksList = [
  { value: 0,   extent: 7, label: '0.0' }, { value: 0.1, extent: 4 },
  { value: 0.2, extent: 7, label: '0.2' }, { value: 0.3, extent: 4 },
  { value: 0.4, extent: 7, label: '0.4' }, { value: 0.5, extent: 4 },
  { value: 0.6, extent: 7, label: '0.6' }, { value: 0.7, extent: 4 },
  { value: 0.8, extent: 7, label: '0.8' }, { value: 0.9, extent: 4 },
];

// Cached, box-Muller-sampled measurement points. Each point keeps BOTH its
// orbital position (mean/true anomaly) AND its standard-normal error
// deviate, so the simulated dataset is STATIC: re-rendering (every animation
// frame, a phase-cursor drag, an axis pan, or toggling the checkbox) redraws
// exactly the same points instead of re-rolling the noise. The stored
// deviate is scaled by activeNoise() at draw time, so moving the noise
// slider smoothly rescales the same scatter pattern rather than reshuffling
// it. Points are only (re)generated when the eccentricity changes (which
// changes the sampled phases, as doKeplersEquation does in the original) or
// when more points are needed.
let measurementPointCache = { eccentricity: null, points: [] };
function ensureMeasurementPoints(eccentricity, count) {
  const needed = 2 * Math.ceil(count / 2);
  if (measurementPointCache.eccentricity !== eccentricity) {
    measurementPointCache = { eccentricity, points: [] };
  }
  const k = Math.sqrt((1 + eccentricity) / (1 - eccentricity));
  while (measurementPointCache.points.length < needed) {
    const ma = Math.random() * 6.283185307179586;
    const ea = solveEccentricAnomaly(ma, eccentricity);
    const ta = 2 * Math.atan(k * Math.tan(ea / 2));
    measurementPointCache.points.push({ ma, ta, err: gaussianPair()[0] });
  }
  return measurementPointCache.points;
}
function gaussianPair() {
  let x1, x2, w;
  do { x1 = 2 * Math.random() - 1; x2 = 2 * Math.random() - 1; w = x1 * x1 + x2 * x2; } while (w >= 1);
  w = Math.sqrt(-2 * Math.log(w) / w);
  return [x1 * w, x2 * w];
}

const rvPlot = {
  canvas: null, ctx: null, PW: 700, PH: 380,
  // The plot rectangle is inset within the (larger) canvas by these margins,
  // so the axis tick marks + numbers (y on the left, x BELOW the bottom
  // border) are drawn OUTSIDE the plot rectangle but still inside the canvas.
  // All the plot/curve/pointer math stays in [0,PW]x[0,PH] "plot coordinates";
  // the renderer translate()s by (OX,OY) and the pointer mappings subtract it.
  OX: 46, OY: 12, OR: 16, OB: 30,
  halfPH: 190, minMarginPx: 25, margin: 2, minScreenYSpacing: 20,
  yAxisMin: -30, yAxisMax: 30, yScale: -6,
  rv: null,
};

// The noise value that drives the plot: the slider value while measurements
// are shown, else noMeasurementsNoise (0.1) so the vertical scale isn't
// blown out by the (irrelevant, hidden) measurement scatter — matches the AS
// source setting radialVelocityPlotMC.noise = noMeasurementsNoise when the
// "show simulated measurements" box is unchecked.
function activeNoise() { return state.showMeasurements ? state.noise : noMeasurementsNoise; }

function updateRVPlot() {
  rvPlot.rv = computeRVParams(state.starMass, state.planetMass, state.separation, state.eccentricity, state.inclination, state.longitude);
  const K = rvPlot.rv.amplitude, m = rvPlot.margin * activeNoise();
  const b = rvPlot.halfPH * (m / (K + m));
  const actualMargin = b < rvPlot.minMarginPx ? (rvPlot.minMarginPx * K / (rvPlot.halfPH - rvPlot.minMarginPx)) : m;
  const h = K + actualMargin;
  rvPlot.yScale = -rvPlot.halfPH / h;
  rvPlot.yAxisMin = rvPlot.rv.centerVelocity - h;
  rvPlot.yAxisMax = rvPlot.rv.centerVelocity + h;
  renderRVPlot();
  updatePlotInfo();
}

function updatePlotInfo() {
  const rv = rvPlot.rv;
  setMath(el('periodReadout'), '\\text{' + getFormattedNumber(rv.periodDays, 3, 12) + ' days}', getFormattedNumber(rv.periodDays, 3, 12) + ' days');
  const amplitudeStr = getFormattedNumber(rv.amplitude, 3, 4) + ' m/s';
  el('vizDesc').dataset.amplitude = amplitudeStr; // folded into the live description, see updateSrText()
}

function renderRVPlot() {
  const ctx = rvPlot.ctx, PW = rvPlot.PW, PH = rvPlot.PH;
  const bw = rvPlot.canvas.width, bh = rvPlot.canvas.height;
  ctx.setTransform(1, 0, 0, 1, 0, 0);
  ctx.clearRect(0, 0, bw, bh);
  ctx.fillStyle = '#ffffff';
  ctx.fillRect(0, 0, bw, bh);
  // Inset the whole plot by the margins so the axis labels have room.
  ctx.save();
  ctx.translate(rvPlot.OX, rvPlot.OY);

  // x tick marks (phase axis, wraps with phaseOffset): marks + numbers BELOW
  // the bottom border, in the bottom margin (matches the AS source's
  // xTickmarksMC._y = plotHeight).
  ctx.strokeStyle = '#000000'; ctx.lineWidth = 1;
  ctx.font = '15px Verdana, sans-serif'; ctx.fillStyle = '#000000';
  ctx.textAlign = 'center'; ctx.textBaseline = 'top';
  for (const tick of xAxisTickmarksList) {
    const x = PW * (((state.phaseOffset + tick.value) % 1 + 1) % 1);
    ctx.beginPath(); ctx.moveTo(x, PH); ctx.lineTo(x, PH + tick.extent); ctx.stroke();
    if (tick.label) ctx.fillText(tick.label, x, PH + tick.extent + 2);
  }

  // y tick marks + numbers to the LEFT of the left border, in the left margin.
  const yScalePxPerUnit = -rvPlot.yScale;
  const ticks = computeYTicks(rvPlot.yAxisMin, rvPlot.yAxisMax, yScalePxPerUnit, rvPlot.minScreenYSpacing);
  ctx.textAlign = 'right'; ctx.textBaseline = 'middle';
  for (const t of ticks) {
    const y = PH - yScalePxPerUnit * (t.value - rvPlot.yAxisMin);
    const extent = t.major ? 7 : 4;
    ctx.beginPath(); ctx.moveTo(0, y); ctx.lineTo(-extent, y); ctx.stroke();
    if (t.label) ctx.fillText(t.label, -extent - 4, y);
  }

  // border
  ctx.strokeStyle = '#000000'; ctx.strokeRect(0.5, 0.5, PW - 1, PH - 1);

  ctx.save();
  ctx.beginPath(); ctx.rect(0, 0, PW, PH); ctx.clip();
  const plotAreaX = state.phaseOffset * PW;

  // simulated measurement points (drawn twice, wrapped one plot-width apart)
  if (state.showMeasurements) {
    const points = ensureMeasurementPoints(state.eccentricity, state.numMeasurements);
    const k3 = PW / 6.283185307179586;
    const r = 2; // measurementDotSize/2, matches AS default of 4px diameter
    ctx.fillStyle = 'rgb(153,153,153)'; // measurementDotColor 10066329 = #999999
    const n = Math.min(points.length, 2 * Math.ceil(state.numMeasurements / 2));
    for (let rep = 0; rep < 2; rep++) {
      const dx = plotAreaX + rep * -PW;
      for (let i = 0; i < n; i++) {
        // cached per-point deviate (NOT re-rolled per render) -> static data
        const v = rvPlot.rv.centerVelocity + rvPlot.rv.amplitude * Math.cos(rvPlot.rv.argument + points[i].ta) + activeNoise() * points[i].err;
        const x = dx + points[i].ma * k3;
        const y = (rvPlot.yAxisMax - v) * yScalePxPerUnit;
        ctx.beginPath(); ctx.arc(x, y, r, 0, 6.283185307179586); ctx.fill();
      }
    }
  }

  // theoretical curve (dense phase sampling; same Kepler math as the AS
  // source, which instead fit bezier segments through fewer points — a
  // rendering-technique simplification, see CONVERSION_NOTES.md)
  if (state.showCurve && rvPlot.rv) {
    ctx.strokeStyle = 'rgb(102,102,255)'; // curveColor 6724095 = #6666FF
    ctx.lineWidth = 1;
    const N = 240;
    for (let rep = 0; rep < 2; rep++) {
      const dx = plotAreaX + rep * -PW;
      ctx.beginPath();
      for (let i = 0; i <= N; i++) {
        const phase = i / N;
        const v = radialVelocityAtPhase(rvPlot.rv, phase);
        const x = dx + phase * PW;
        const y = (rvPlot.yAxisMax - v) * yScalePxPerUnit;
        if (i === 0) ctx.moveTo(x, y); else ctx.lineTo(x, y);
      }
      ctx.stroke();
    }
  }
  ctx.restore();

  // phase cursor (draggable "current phase" line), wrapped into the visible
  // plot — the original draws the cursor line at 0 AND at -plotWidth inside
  // the wrapping plotAreaMC, which is equivalent to this modulo.
  const cursorX = ((plotAreaX + state.phase * PW) % PW + PW) % PW;
  ctx.strokeStyle = 'rgb(238,144,144)'; ctx.lineWidth = 3; // phaseCursorNormalColor 15634576
  ctx.beginPath(); ctx.moveTo(cursorX, 0); ctx.lineTo(cursorX, PH); ctx.stroke();

  ctx.restore(); // undo the (OX,OY) margin translate

  positionPhaseCursorProxy();
  updateVizDesc();
}

/* -------------------------------------------------------------------
   8. Binary System Component (Binary System Component.as) — the
      orbiting star+planet render used by the free-space view and (when
      "show multiple views" is on) the three fixed side/earth/orbit
      sub-panels. Bodies are NOT to scale (see help text) — radius is a
      fixed fraction of the separation for visual clarity, exactly as
      in the original (radiusMultiple1=0.15, radiusMultiple2=0.07).
   ------------------------------------------------------------------- */
const RADIUS_MULTIPLE_1 = 0.15, RADIUS_MULTIPLE_2 = 0.07;

// 3D rotation matrix (Binary System Component.doA / CelestialSphere.doA —
// identical formula, only the scale factor differs between the two uses).
function rotationMatrix(thetaDeg, phiDeg, scale) {
  const theta = thetaDeg * Math.PI / 180, phi = phiDeg * Math.PI / 180;
  const ct = Math.cos(theta), st = Math.sin(theta), cp = Math.cos(phi), sp = Math.sin(phi);
  return {
    a0: -scale * st, a1: scale * ct,
    a3: scale * ct * sp, a4: scale * st * sp, a5: -scale * cp,
    a6: scale * ct * cp, a7: scale * st * cp, a8: scale * sp,
    scale,
  };
}
function project(rot, p) {
  return {
    x: p.x * rot.a0 + p.y * rot.a1,
    y: p.x * rot.a3 + p.y * rot.a4 + p.z * rot.a5,
    z: p.x * rot.a6 + p.y * rot.a7 + p.z * rot.a8,
  };
}

function computeBinarySystem(p) {
  const massTotal = p.mass1 + p.mass2;
  const a1 = p.separation * p.mass2 / massTotal, a2 = p.separation * p.mass1 / massTotal;
  const h = Math.max(a1 * (1 + p.eccentricity) + p.radius1, a2 * (1 + p.eccentricity) + p.radius2);
  const scale = (p.targetSize) / (2 * h);
  const rot = rotationMatrix(p.theta, p.phi, scale);
  // orbit position: solve Kepler's equation, then place each body on its
  // own ellipse (radius r = a(1-e^2)/(1+e*cos ν)) on opposite sides of the
  // barycenter (star and planet ellipses share eccentricity/orientation,
  // scaled by their distance-from-barycenter ratio a1:a2)
  const ma = ((p.phase % 1) + 1) % 1 * 6.283185307179586;
  const ea = solveEccentricAnomaly(ma, p.eccentricity);
  const ta = trueAnomalyFromEccentric(ea, p.eccentricity);
  const k = (1 - p.eccentricity * p.eccentricity) / (1 + p.eccentricity * Math.cos(ta));
  const r1 = a1 * k, r2 = a2 * k;
  const s1 = project(rot, { x: -r1 * Math.cos(ta), y: -r1 * Math.sin(ta), z: 0 });
  const s2 = project(rot, { x: r2 * Math.cos(ta), y: r2 * Math.sin(ta), z: 0 });
  return {
    scale, rot, a1, a2,
    // explicit color overrides (Visualization.as assigns fixed color1/color2
    // to the sub-views and a fixed color2 to the free-space view) win over
    // the temperature-derived color
    body1: { s: s1, radiusPx: scale * p.radius1, color: p.color1 || rgbToCss(getColorFromTemp(p.temperature1)) },
    body2: { s: s2, radiusPx: scale * p.radius2, color: p.color2 || rgbToCss(getColorFromTemp(p.temperature2)) },
  };
}

// Draws one Binary System Component instance into `ctx`, centered at
// (cx, cy), matching updateBackground/updateOrbitalPaths/updateOrbitalPlane/
// updatePositions/setIcon from the AS source.
function drawBinarySystem(ctx, cx, cy, p, opts) {
  const bs = computeBinarySystem(p);
  ctx.save();
  ctx.translate(cx, cy);

  if (opts.background) {
    ctx.fillStyle = opts.background;
    ctx.fillRect(-p.targetSize / 2 - p.margin, -p.targetSize / 2 - p.margin, p.targetSize + 2 * p.margin, p.targetSize + 2 * p.margin);
  }

  // orbital plane: grid + both orbit ellipses live in one local "plan view"
  // 2D space, displayed through scale-then-rotate — a Flash-authored
  // shortcut equivalent to a full 3D projection of a flat tilted plane
  // (parent MC's _yscale = sin(phi), child MC's _rotation = theta+90°).
  const phiRad = p.phi * Math.PI / 180, thetaRad = p.theta * Math.PI / 180;
  ctx.save();
  ctx.scale(1, Math.sin(phiRad));
  ctx.rotate(Math.PI / 2 + thetaRad);

  if (p.showOrbitalPlane) {
    const e = p.eccentricity;
    const kEcc = Math.sqrt(1 - e * e);
    const b1 = bs.a1 * kEcc, b2 = bs.a2 * kEcc;
    const r1v = p.radius1, r2v = p.radius2;
    const leftExtent = -Math.max(bs.a2 * (1 + e) + 1.75 * r2v, bs.a1 * (1 - e) + 1.75 * r1v);
    const rightExtent = Math.max(bs.a1 * (1 + e) + 1.75 * r1v, bs.a2 * (1 - e) + 1.75 * r2v);
    const topExtent = Math.max(b1 + 1.75 * r1v, b2 + 1.75 * r2v);
    const bottomExtent = -topExtent;
    const s = bs.scale;
    const leftX = s * leftExtent, rightX = s * rightExtent;
    const topY = s * topExtent, bottomY = s * bottomExtent;

    ctx.fillStyle = opts.gridFill || 'rgba(128,128,128,0.45)'; // initOrbitalPlaneColor 8421504, alpha 45
    ctx.fillRect(leftX, bottomY, rightX - leftX, topY - bottomY);

    // "Nice" grid line spacing in a 1-2-5 sequence (updateOrbitalPlane's
    // log10-based spacing choice), same algorithm as the RV plot's Y-axis
    // ticks but independently parameterized (minGridSpacing=20,
    // minGridLineAlpha=5, maxGridLineAlpha=50 are Binary System Component
    // constructor constants, fixed for every instance).
    const minGridSpacing = 20, minGridLineAlpha = 5, maxGridLineAlpha = 50;
    const m = minGridSpacing / s;
    const lg = Math.log(m) / Math.LN10;
    const k = Math.ceil(lg);
    let spacing, belowSpacing, majorMultiple;
    if (k - lg > 0.30102999566398114) {
      belowSpacing = Math.pow(10, k - 1);
      spacing = 5 * belowSpacing;
      majorMultiple = 2;
    } else {
      spacing = Math.pow(10, k);
      belowSpacing = 0.5 * spacing;
      majorMultiple = 5;
    }
    const leftGridExtent = Math.ceil(leftExtent / spacing);
    const rightGridLimit = Math.ceil(rightExtent / spacing);
    const topGridLimit = Math.ceil(topExtent / spacing);
    const bottomGridExtent = Math.ceil(bottomExtent / spacing);
    const minorAlpha = (minGridLineAlpha + (maxGridLineAlpha - minGridLineAlpha) * (spacing - m) / (spacing - belowSpacing)) / 100;
    const majorAlpha = maxGridLineAlpha / 100;
    const gridColor = 'rgb(144,144,144)';  // gridLineStyle.color 9474192 = #909090
    const originColor = 'rgb(77,169,77)';  // axisGridLineStyle.color 5089613 = #4DA94D (green)
    const originAlpha = 0.65;              // axisGridLineStyle.alpha 65

    ctx.lineWidth = 1;
    for (let i = leftGridExtent; i < rightGridLimit; i++) {
      const x = i * spacing * s;
      if (i === 0) { ctx.strokeStyle = originColor; ctx.globalAlpha = originAlpha; }
      else if (i % majorMultiple === 0) { ctx.strokeStyle = gridColor; ctx.globalAlpha = majorAlpha; }
      else { ctx.strokeStyle = gridColor; ctx.globalAlpha = minorAlpha; }
      ctx.beginPath(); ctx.moveTo(x, bottomY); ctx.lineTo(x, topY); ctx.stroke();
    }
    for (let i = bottomGridExtent; i < topGridLimit; i++) {
      const y = i * spacing * s;
      if (i === 0) { ctx.strokeStyle = originColor; ctx.globalAlpha = originAlpha; }
      else if (i % majorMultiple === 0) { ctx.strokeStyle = gridColor; ctx.globalAlpha = majorAlpha; }
      else { ctx.strokeStyle = gridColor; ctx.globalAlpha = minorAlpha; }
      ctx.beginPath(); ctx.moveTo(leftX, y); ctx.lineTo(rightX, y); ctx.stroke();
    }
    ctx.globalAlpha = 1;
  }
  if (p.showOrbitalPaths) {
    const e = p.eccentricity, s = bs.scale;
    const dx1 = s * bs.a1 * e, dx2 = -s * bs.a2 * e;
    ctx.strokeStyle = opts.orbitColor || 'rgba(255,255,255,0.9)';
    ctx.lineWidth = 1;
    ctx.beginPath();
    ctx.ellipse(dx1, 0, s * bs.a1, s * bs.a1 * Math.sqrt(1 - e * e), 0, 0, 6.283185307179586);
    ctx.stroke();
    ctx.beginPath();
    ctx.ellipse(dx2, 0, s * bs.a2, s * bs.a2 * Math.sqrt(1 - e * e), 0, 0, 6.283185307179586);
    ctx.stroke();
  }
  ctx.restore();

  // bodies, painter's-algorithm sorted by projected depth (further = drawn first)
  const bodies = [bs.body1, bs.body2].sort((a, b) => a.s.z - b.s.z);
  for (const body of bodies) drawBodyIcon(ctx, body.s.x, body.s.y, body.radiusPx, body.color);

  ctx.restore();
  return bs;
}

// Star/planet disc icon: solid color fill + soft radial highlight, matching
// Binary System Component.setIcon()'s default drawCircle + gradient fill.
function drawBodyIcon(ctx, x, y, r, color) {
  if (r <= 0) return;
  ctx.beginPath(); ctx.arc(x, y, r, 0, 6.283185307179586);
  ctx.fillStyle = color; ctx.fill();
  const g = ctx.createRadialGradient(x - r * 0.35, y - r * 0.35, 0, x, y, r);
  g.addColorStop(0, 'rgba(255,255,255,0.55)');
  g.addColorStop(0.45, 'rgba(255,255,255,0.35)');
  g.addColorStop(1, 'rgba(255,255,255,0.10)');
  ctx.beginPath(); ctx.arc(x, y, r, 0, 6.283185307179586);
  ctx.fillStyle = g; ctx.fill();
}

/* -------------------------------------------------------------------
   9. Celestial-sphere-lite: positions the "direction arrow" objects that
      mark viewing directions on the free-space view. Visualization.as
      never calls addCircle/addLine/addDeclinationTrail/addShadedBand and
      leaves showUnder=true (nothing culled) with the shading disc removed
      and the horizon plane hidden, so only the rotation math and the
      "absolute orientation" arrow-placement math (7 CS Objects.as) are
      needed here — see CONVERSION_NOTES.md "Omitted subsystems".
   ------------------------------------------------------------------- */
const SPHERE_RADIUS = 200; // Visualization.as: sphereMC.size = 400 -> _c.r = 200
const ARROW_PATH = new Path2D('M17.5 -18.25 L17.5 -6.15 35.0 -6.15 0.0 18.25 -35.0 -6.15 -17.5 -6.15 -17.5 -18.25 Z');

function horizonToWorld(azDeg, altDeg, r) {
  r = r || 1;
  const az = azDeg * Math.PI / 180, alt = altDeg * Math.PI / 180;
  const d = r * Math.cos(alt);
  return { x: d * Math.cos(az), y: d * Math.sin(-az), z: r * Math.sin(alt) };
}
function cross(u, v) { return { x: u.y * v.z - u.z * v.y, y: u.z * v.x - u.x * v.z, z: u.x * v.y - u.y * v.x }; }
function normalize(v) { const m = Math.sqrt(v.x * v.x + v.y * v.y + v.z * v.z) || 1; return { x: v.x / m, y: v.y / m, z: v.z / m }; }

// CSObjectsClass.update(), orientation case "absolute": returns the
// screen position plus the shell yscale/rotation and instance rotation
// needed to foreshorten/rotate the arrow icon as the view is dragged.
function computeArrowScreen(rot, posWorld, nVectRaw, aVectRaw) {
  const sp = project(rot, posWorld);
  const n = normalize(nVectRaw);
  const nx = n.x, ny = n.y, nz = n.z, ax = aVectRaw.x, ay = aVectRaw.y, az = aVectRaw.z;
  const ux = ny * ny * ax - nx * ny * ay - nx * nz * az + nz * nz * ax;
  const uy = nz * nz * ay - ny * nz * az - nx * ny * ax + nx * nx * ay;
  const uz = nx * nx * az - nx * nz * ax - ny * nz * ay + ny * ny * az;
  const un = Math.sqrt(ux * ux + uy * uy + uz * uz) || 1;
  const u = { x: ux / un, y: uy / un, z: uz / un };
  const p_n = { x: posWorld.x + n.x, y: posWorld.y + n.y, z: posWorld.z + n.z };
  const p_u = { x: posWorld.x + u.x, y: posWorld.y + u.y, z: posWorld.z + u.z };
  const npz = (n.x * rot.a6 + n.y * rot.a7 + n.z * rot.a8) / SPHERE_RADIUS;
  const sp_n = project(rot, p_n), sp_u = project(rot, p_u);
  const shellRotation = Math.atan2(sp_n.y - sp.y, sp_n.x - sp.x) + Math.PI / 2;
  const cA = Math.cos(shellRotation), sA = Math.sin(shellRotation);
  const x0 = sp_u.x - sp.x, y0 = sp_u.y - sp.y;
  const x1 = cA * x0 + sA * y0, y1 = (-sA * x0 + cA * y0) / npz;
  const instanceRotation = Math.atan2(y1, x1) + Math.PI / 2;
  return { x: sp.x, y: sp.y, yscale: npz, shellRotation, instanceRotation };
}

// Maps a point from the arrow's local (icon) space through the same chain
// used to draw the shape (icon scale -> instance rotation -> foreshorten ->
// shell rotation -> anchor), returning stage coordinates.
function arrowLocalToStage(arrow, iconScale, lx, ly) {
  let x = lx * iconScale, y = ly * iconScale;
  let c = Math.cos(arrow.instanceRotation), s = Math.sin(arrow.instanceRotation);
  let x2 = x * c - y * s, y2 = x * s + y * c;
  y2 *= arrow.yscale;
  c = Math.cos(arrow.shellRotation); s = Math.sin(arrow.shellRotation);
  return { x: arrow.x + x2 * c - y2 * s, y: arrow.y + x2 * s + y2 * c };
}

// opts.number: white digit ANCHORED to the arrow body (its local centre run
// through the same transform chain as the shape) but rendered upright and
// unmirrored — the original bakes the digit into the symbol art, where it
// can appear flipped/upside-down at many view orientations; readability
// wins (WCAG 1.4.4, noted in CONVERSION_NOTES.md). opts.label: text below
// the arrow ("Direction Arrow 2"'s labelText, white in the original).
function drawDirectionArrow(ctx, arrow, color, iconScale, opts = {}) {
  ctx.save();
  ctx.translate(arrow.x, arrow.y);
  ctx.rotate(arrow.shellRotation);
  ctx.scale(1, arrow.yscale);
  ctx.rotate(arrow.instanceRotation);
  ctx.scale(iconScale, iconScale);
  ctx.fillStyle = color; ctx.fill(ARROW_PATH);
  ctx.lineWidth = 1.2 / iconScale; ctx.strokeStyle = '#000'; ctx.stroke(ARROW_PATH);
  ctx.restore();
  if (opts.number) {
    const p = arrowLocalToStage(arrow, iconScale, 0, 0);
    ctx.save();
    ctx.font = 'bold 20px Verdana, sans-serif';
    ctx.textAlign = 'center'; ctx.textBaseline = 'middle';
    ctx.lineWidth = 3; ctx.strokeStyle = 'rgba(0,0,0,0.8)';
    ctx.strokeText(opts.number, p.x, p.y);
    ctx.fillStyle = '#fff'; ctx.fillText(opts.number, p.x, p.y);
    ctx.restore();
  }
  if (opts.label) {
    ctx.save();
    ctx.translate(arrow.x, arrow.y + 24 * Math.max(0.6, Math.abs(arrow.yscale)));
    ctx.font = 'bold 13px Verdana, sans-serif';
    ctx.textAlign = 'center'; ctx.textBaseline = 'top';
    ctx.lineWidth = 3; ctx.strokeStyle = 'rgba(0,0,0,0.85)';
    ctx.strokeText(opts.label, 0, 0);
    ctx.fillStyle = '#fff'; ctx.fillText(opts.label, 0, 0);
    ctx.restore();
  }
}

/* -------------------------------------------------------------------
   10. Visualization compositing (Visualization.as) — either a single
       400x400 free-space view, or (when "show multiple views" is
       checked) that view shrunk to a 200x200 quadrant plus three fixed
       side/earth/orbit sub-views, matching setShowMultiplePanels().
   ------------------------------------------------------------------- */
// The visualization draws in a fixed 400x400 "stage" coordinate system, but
// its canvas fills the whole (rectangular, panel-height-driven) panel: the
// black background is painted across the FULL canvas and the square 400x400
// diagram is centered/scaled within it (matching the original, where the
// black fills the panel and the round diagram sits centered with black
// margins). This removes the white gaps that a shrunk square canvas left,
// without distorting the circles or shrinking the plot.
const viz = { canvas: null, ctx: null, scale: 1, offsetX: 0, offsetY: 0 };
let currentStarTemp = 5810, currentStarColorTemp = 5810;

// Size the canvas backing store to the panel's pixel size and recompute the
// stage->canvas transform (centered square fit). Cheap; guarded so it only
// reallocates the backing store when the size actually changes.
function resizeVizCanvas() {
  const wrap = document.querySelector('.rvs-viz-wrap');
  if (!wrap || !viz.canvas) return;
  const w = Math.round(wrap.clientWidth), h = Math.round(wrap.clientHeight);
  if (w <= 0 || h <= 0) return;
  if (viz.canvas.width !== w || viz.canvas.height !== h) {
    viz.canvas.width = w; viz.canvas.height = h;
  }
  viz.scale = Math.min(w, h) / 400;
  viz.offsetX = (w - 400 * viz.scale) / 2;
  viz.offsetY = (h - 400 * viz.scale) / 2;
}

function bscParams(overrides) {
  return Object.assign({
    separation: state.separation, eccentricity: state.eccentricity,
    mass1: state.starMass, mass2: state.planetMass / 1047.52,
    radius1: state.separation * RADIUS_MULTIPLE_1, radius2: state.separation * RADIUS_MULTIPLE_2,
    temperature1: currentStarColorTemp,
    // free-space view planet color: freeSpaceViewMC.color2 = 10526880 = #A0A0A0
    // (the star color stays temperature-driven); the three sub-views override
    // both colors — see subParams.
    color2: '#a0a0a0',
    phase: state.phase,
  }, overrides);
}

function renderVisualization() {
  const ctx = viz.ctx;
  resizeVizCanvas();
  const W = viz.canvas.width, H = viz.canvas.height;
  // Full-canvas black background (fills the whole panel, no white gaps),
  // then draw the 400x400 stage centered/scaled inside it.
  ctx.setTransform(1, 0, 0, 1, 0, 0);
  ctx.clearRect(0, 0, W, H);
  ctx.fillStyle = '#000'; ctx.fillRect(0, 0, W, H);
  ctx.save();
  ctx.translate(viz.offsetX, viz.offsetY);
  ctx.scale(viz.scale, viz.scale);
  ctx.fillStyle = '#000'; ctx.fillRect(0, 0, 400, 400);

  const lineTheta = 90 - state.longitude, linePhi = 90 - state.inclination;

  if (!state.showPanels) {
    drawBinarySystem(ctx, 200, 200, bscParams({
      theta: state.theta, phi: state.phi, targetSize: 320, margin: 40,
      showOrbitalPlane: true, showOrbitalPaths: true,
    }), { orbitColor: 'rgba(255,255,255,0.9)' });

    const rot = rotationMatrix(state.theta, state.phi, SPHERE_RADIUS);
    const earthPos = horizonToWorld(-lineTheta, linePhi, 1);
    const sidePos = horizonToWorld(90 - lineTheta, 0, 1);
    const nVect = cross(sidePos, earthPos);
    const arrow = computeArrowScreen(rot, earthPos, nVect, earthPos);
    // computeArrowScreen returns a position relative to the sphere centre, so
    // it must be drawn about the diagram centre (200,200) -- the same centre
    // the binary system is drawn at -- not the stage origin.
    // Color 16757557 = #FFB335 (earthViewArrow2's arrowColor); _xscale 65.
    ctx.save();
    ctx.translate(200, 200);
    drawDirectionArrow(ctx, arrow, '#ffb335', 0.65, { label: 'earth view' });
    ctx.restore();
  } else {
    // Quadrant layout per Visualization.as: 1 side view top-left, 2 earth
    // view top-right, 3 orbit view bottom-left, free-space view scaled 50%
    // bottom-right (freeSpaceViewWrapperMC._x/_y = 300, _x/_yscale = 50).
    // Sub-view orbit color: initOrbitalPathsColor 7368816 = #707070.
    const subOrbit = 'rgb(112,112,112)';
    // Sub-view body colors from Visualization.as: color1 = 16769136 =
    // #FFE070 (yellow star), color2 = 9474192 = #909090 (gray planet) —
    // fixed, never temperature-driven (only the free-space star recolors).
    const subParams = { targetSize: 170, margin: 15, showOrbitalPlane: false, showOrbitalPaths: true,
                        color1: '#ffe070', color2: '#909090' };

    // 1 side view (top-left) — its wrapper is ROTATED by linePhi
    // (reconcile(): sideViewWrapperMC._rotation = linePhi).
    ctx.save();
    ctx.beginPath(); ctx.rect(0, 0, 200, 200); ctx.clip();
    ctx.fillStyle = '#ffffff'; ctx.fillRect(0, 0, 200, 200);
    ctx.translate(100, 100);
    ctx.rotate(linePhi * Math.PI / 180);
    drawBinarySystem(ctx, 0, 0, bscParams(Object.assign({ theta: lineTheta - 90, phi: 0 }, subParams)),
      { orbitColor: subOrbit });
    ctx.restore();

    // 2 earth view (top-right)
    drawBinarySystem(ctx, 300, 100, bscParams(Object.assign({ theta: lineTheta, phi: linePhi }, subParams)),
      { background: '#ffffff', orbitColor: subOrbit });

    // 3 orbit view (bottom-left)
    drawBinarySystem(ctx, 100, 300, bscParams(Object.assign({ theta: 0, phi: 90 }, subParams)),
      { background: '#ffffff', orbitColor: subOrbit });

    // free-space view (bottom-right, 50% scale) + numbered direction arrows
    ctx.save();
    ctx.beginPath(); ctx.rect(200, 200, 200, 200); ctx.clip();
    ctx.translate(300, 300); ctx.scale(0.5, 0.5);
    ctx.fillStyle = '#000'; ctx.fillRect(-200, -200, 400, 400);
    drawBinarySystem(ctx, 0, 0, bscParams({
      theta: state.theta, phi: state.phi, targetSize: 320, margin: 40,
      showOrbitalPlane: true, showOrbitalPaths: true,
    }), { orbitColor: 'rgba(255,255,255,0.9)' });
    const rot = rotationMatrix(state.theta, state.phi, SPHERE_RADIUS);
    const earthPos = horizonToWorld(-lineTheta, linePhi, 1);
    const sidePos = horizonToWorld(90 - lineTheta, 0, 1);
    const orbitPos = horizonToWorld(0, 90, 1);
    const nVect = cross(sidePos, earthPos);
    // Arrow colors from Visualization.as: side 2805840=#2AD050 (green),
    // earth 16757557=#FFB335 (orange), orbit 4955113=#4B9BE9 (blue). The
    // orbit arrow keeps its constructor orientation (n={-1,0,0}, up=zenith);
    // reconcile() only re-orients the side/earth arrows.
    // iconScale 1.15 (slightly above the original's 1.0): at 50% quadrant
    // scale the arrows otherwise get hard to make out — a small readability
    // concession noted in CONVERSION_NOTES.md.
    drawDirectionArrow(ctx, computeArrowScreen(rot, sidePos, nVect, sidePos), '#2ad050', 1.15, { number: '1' });
    drawDirectionArrow(ctx, computeArrowScreen(rot, earthPos, nVect, earthPos), '#ffb335', 1.15, { number: '2' });
    drawDirectionArrow(ctx, computeArrowScreen(rot, orbitPos, { x: -1, y: 0, z: 0 }, orbitPos), '#4b9be9', 1.15, { number: '3' });
    ctx.restore();

    // divider mullions + numbered labels (positions/colors from label1-3MC)
    ctx.strokeStyle = '#a0a0a0'; ctx.lineWidth = 1;
    ctx.beginPath(); ctx.moveTo(200, 0); ctx.lineTo(200, 400); ctx.moveTo(0, 200); ctx.lineTo(400, 200); ctx.stroke();
    drawPanelLabel(ctx, 6, 6, '1', '#2ad050', 'side view');
    drawPanelLabel(ctx, 206, 6, '2', '#ffb335', 'earth view');
    drawPanelLabel(ctx, 6, 206, '3', '#4b9be9', 'orbit view');
  }

  ctx.restore();
  positionVizDragProxy();
  if (rvPlot.rv) updateVizDesc();
}

function drawPanelLabel(ctx, x, y, num, color, text) {
  ctx.save();
  ctx.beginPath(); ctx.arc(x + 8, y + 8, 8, 0, 6.283185307179586);
  ctx.fillStyle = color; ctx.fill();
  // white number on the colored disc, black label text (Visualization Panel Label)
  ctx.fillStyle = '#fff'; ctx.font = 'bold 11px Verdana, sans-serif';
  ctx.textAlign = 'center'; ctx.textBaseline = 'middle'; ctx.fillText(num, x + 8, y + 9);
  ctx.font = '12px Verdana, sans-serif'; ctx.textAlign = 'left';
  ctx.fillStyle = '#000'; ctx.fillText(text, x + 20, y + 9);
  ctx.restore();
}

function positionVizDragProxy() {
  el('vizDragProxy').setAttribute('aria-valuenow', String(((state.theta % 360) + 360) % 360));
  el('vizDragProxy').setAttribute('aria-valuetext',
    `View rotated to azimuth ${Math.round(state.theta)} degrees, altitude ${Math.round(state.phi)} degrees`);
}

/* -------------------------------------------------------------------
   11. Star info readout + screen-reader descriptions.
   ------------------------------------------------------------------- */
function updateStarInfo() {
  const starLum = getLuminosityFromMass(state.starMass);
  const starTemp = getTempFromLuminosity(starLum);
  const starRadius = getRadiusFromTempAndLuminosity(starTemp, starLum);
  currentStarColorTemp = starTemp;
  const starType = getSpectralTypeFromTemp(starTemp, 'v');
  const box = el('starInfoField');
  if (!starType) { box.textContent = ''; return; }
  let starTypeNum = Math.round(starType.number);
  if (starTypeNum === 10) starTypeNum = 9;
  box.textContent = `(a main sequence star of this mass would have spectral type `
    + `${starType.type}${starTypeNum}V, temperature ${getFormattedNumber(starTemp, 3, 12)} K, `
    + `and radius ${starRadius.toFixed(1)} Rsun)`;
}

function updateVizDesc() {
  const rv = rvPlot.rv;
  const amp = rv ? getFormattedNumber(rv.amplitude, 3, 4) : '0';
  const per = rv ? getFormattedNumber(rv.periodDays, 3, 12) : '0';
  el('vizDesc').textContent = state.showPanels
    ? `Four views of the star-planet system: a rotatable free-space view, and fixed side, earth, and orbit views. `
      + `Star mass ${state.starMass.toFixed(2)} solar masses, planet mass ${state.planetMass} Jupiter masses, `
      + `orbital period ${per} days, radial velocity amplitude ${amp} meters per second.`
    : `Free-space view of the star-planet system, rotated to azimuth ${Math.round(state.theta)} degrees, `
      + `altitude ${Math.round(state.phi)} degrees. The orange arrow marks the direction to earth. `
      + `Orbital period ${per} days, radial velocity amplitude ${amp} meters per second.`;
  el('plotDesc').textContent = `Radial velocity plot: current phase ${state.phase.toFixed(3)}, `
    + `radial velocity ${rv ? getFormattedNumber(radialVelocityAtPhase(rv, state.phase), 3, 4) : '0'} meters per second.`
    + (state.showMeasurements ? ` Showing ${state.numMeasurements} simulated noisy measurements with ${state.noise} meters per second of scatter.` : '');
}

function announce(msg) { el('liveStatus').textContent = msg; }

/* -------------------------------------------------------------------
   12. Physics update pipeline (mirrors the main controller's
       updateVisualization()/updateRadialVelocityPlot() pair).
   ------------------------------------------------------------------- */
function updateVisualization() {
  updateStarInfo();
  renderVisualization();
}
function fullUpdate() {
  updateStarInfo();
  updateRVPlot();
  renderVisualization();
}

/* -------------------------------------------------------------------
   13. UI wiring — one native control per AS "Standard Slider v6" /
       FCheckBox / FPushButton / FComboBox instance, same init values,
       same changeHandler chain (onXxxChanged -> updateVisualization /
       updateRadialVelocityPlot), same onResetClicked() constants.
   ------------------------------------------------------------------- */
function el(id) { return document.getElementById(id); }

let sliders = {};

function initSliders() {
  sliders.planetMass = bindSlider(el('planetMassSlider'), el('planetMassField'), el('planetMassUnits'),
    makeValueLogic({ minValue: 0.001, maxValue: 100, scalingMode: 'logarithmic', precisionMode: 'significant digits', precision: 3 }),
    { quantity: 'Planet mass', unitsLatex: '\\text{M}_{\\text{jup}}', unitsPlain: 'Mjup', unitSpoken: 'Jupiter masses',
      spoken: (v, s) => `Planet mass ${s} Jupiter masses`,
      onChange: (v, fromUser) => { state.planetMass = v; updateVisualization(); updateRVPlot(); if (fromUser) armPresetButton(); } });

  sliders.separation = bindSlider(el('separationSlider'), el('separationField'), el('separationUnits'),
    makeValueLogic({ minValue: 0.01, maxValue: 10, scalingMode: 'logarithmic', precisionMode: 'significant digits', precision: 3 }),
    { quantity: 'Orbital semimajor axis', unitsLatex: '\\text{AU}', unitsPlain: 'AU', unitSpoken: 'astronomical units',
      spoken: (v, s) => `Semimajor axis ${s} astronomical units`,
      onChange: (v, fromUser) => { state.separation = v; updateVisualization(); updateRVPlot(); if (fromUser) armPresetButton(); } });

  sliders.eccentricity = bindSlider(el('eccentricitySlider'), el('eccentricityField'), null,
    makeValueLogic({ minValue: 0, maxValue: 0.8, scalingMode: 'linear', precisionMode: 'fixed digits', precision: 2 }),
    { quantity: 'Orbital eccentricity',
      spoken: (v, s) => `Eccentricity ${s}`,
      onChange: (v, fromUser) => { state.eccentricity = v; updateVisualization(); updateRVPlot(); if (fromUser) armPresetButton(); } });

  sliders.starMass = bindSlider(el('starMassSlider'), el('starMassField'), el('starMassUnits'),
    makeValueLogic({ minValue: 0.2, maxValue: 2, scalingMode: 'linear', precisionMode: 'fixed digits', precision: 2 }),
    { quantity: 'Star mass', unitsLatex: '\\text{M}_{\\text{sun}}', unitsPlain: 'Msun', unitSpoken: 'solar masses',
      spoken: (v, s) => `Star mass ${s} solar masses`,
      onChange: (v, fromUser) => { state.starMass = v; updateVisualization(); updateRVPlot(); if (fromUser) armPresetButton(); } });

  sliders.inclination = bindSlider(el('inclinationSlider'), el('inclinationField'), el('inclinationUnits'),
    makeValueLogic({ minValue: 0, maxValue: 180, scalingMode: 'linear', precisionMode: 'fixed digits', precision: 1 }),
    { quantity: 'Orbital inclination', unitsLatex: '\\text{°}', unitsPlain: '°', unitSpoken: 'degrees',
      spoken: (v, s) => `Inclination ${s} degrees`,
      onChange: (v, fromUser) => { state.inclination = v; updateVisualization(); updateRVPlot(); if (fromUser) armPresetButton(); } });

  sliders.longitude = bindSlider(el('longitudeSlider'), el('longitudeField'), el('longitudeUnits'),
    makeValueLogic({ minValue: 0, maxValue: 360, scalingMode: 'linear', precisionMode: 'fixed digits', precision: 1 }),
    { quantity: 'Longitude of periastron', unitsLatex: '\\text{°}', unitsPlain: '°', unitSpoken: 'degrees',
      spoken: (v, s) => `Longitude ${s} degrees`,
      onChange: (v, fromUser) => { state.longitude = v; updateVisualization(); updateRVPlot(); if (fromUser) armPresetButton(); } });

  sliders.phase = bindSlider(el('phaseSlider'), el('phaseField'), null,
    makeValueLogic({ minValue: 0, maxValue: 1, scalingMode: 'linear', precisionMode: 'fixed digits', precision: 3 }),
    { quantity: 'Orbital phase',
      spoken: (v, s) => `Phase ${s}`,
      onChange: (v) => { state.phase = v; renderVisualizationPhase(); } });

  sliders.animRate = bindSlider(el('animRateSlider'), null, null,
    makeValueLogic({ minValue: 0.00001, maxValue: 0.001, scalingMode: 'linear', precisionMode: 'significant digits', precision: 2 }),
    { quantity: 'Animation speed', spoken: (v, s) => `Animation speed ${s}`,
      onChange: (v) => { state.animRate = v; } });

  sliders.noise = bindSlider(el('noiseSlider'), el('noiseField'), el('noiseUnits'),
    makeValueLogic({ minValue: 1, maxValue: 100, scalingMode: 'logarithmic', precisionMode: 'significant digits', precision: 2 }),
    { quantity: 'Measurement noise', unitsLatex: '\\text{m/s}', unitsPlain: 'm/s', unitSpoken: 'meters per second',
      spoken: (v, s) => `Noise ${s} meters per second`,
      onChange: (v) => { state.noise = v; updateRVPlot(); } });

  sliders.number = bindSlider(el('numberSlider'), el('numberField'), el('numberUnits'),
    makeValueLogic({ minValue: 10, maxValue: 300, scalingMode: 'logarithmic', precisionMode: 'fixed digits', precision: 0 }),
    { quantity: 'Number of measurements', spoken: (v, s) => `${s} measurements`,
      onChange: (v) => { state.numMeasurements = v; updateRVPlot(); } });
}

// Phase changes alone don't need the (expensive-ish) RV-parameter
// recompute — only the plot cursor + visualization body positions move.
function renderVisualizationPhase() {
  renderRVPlot();
  renderVisualization();
}

function armPresetButton() { el('setPresetButton').disabled = false; }

function initCheckboxesAndButtons() {
  el('showCurveCheck').addEventListener('change', e => { state.showCurve = e.target.checked; renderRVPlot(); });
  el('showMeasurementsCheck').addEventListener('change', e => {
    state.showMeasurements = e.target.checked;
    // state.noise stays the slider value; activeNoise() applies the 0.1
    // when measurements are hidden (used for the vertical-scale margin).
    state.noise = sliders.noise.value;
    el('noiseSlider').disabled = el('noiseField').disabled = !state.showMeasurements;
    el('numberSlider').disabled = el('numberField').disabled = !state.showMeasurements;
    updateRVPlot();
  });
  el('showPanelsCheck').addEventListener('change', e => { state.showPanels = e.target.checked; renderVisualization(); });

  el('animateButton').addEventListener('click', toggleAnimation);
  el('setPresetButton').addEventListener('click', setPreset);

  const select = el('presetsSelect');
  presetsList.forEach((p, i) => {
    const opt = document.createElement('option');
    opt.value = String(i); opt.textContent = p.name;
    select.appendChild(opt);
  });
  select.addEventListener('change', armPresetButton);
}

function setPreset() {
  const preset = presetsList[parseInt(el('presetsSelect').value, 10)];
  sliders.planetMass.set(preset.planetMass, false);
  sliders.separation.set(preset.separation, false);
  sliders.eccentricity.set(preset.eccentricity, false);
  sliders.starMass.set(preset.starMass, false);
  sliders.inclination.set(preset.inclination, false);
  sliders.longitude.set(preset.longitude, false);
  state.planetMass = sliders.planetMass.value; state.separation = sliders.separation.value;
  state.eccentricity = sliders.eccentricity.value; state.starMass = sliders.starMass.value;
  state.inclination = sliders.inclination.value; state.longitude = sliders.longitude.value;
  fullUpdate();
  el('setPresetButton').disabled = true;
  announce(`Preset applied: ${preset.name}.`);
}

let animHandle = null, animLastTime = 0;
function toggleAnimation() {
  state.animating = !state.animating;
  el('animateButton').textContent = state.animating ? 'pause animation' : 'start animation';
  if (state.animating) { animLastTime = performance.now(); animHandle = requestAnimationFrame(animTick); }
  else if (animHandle) { cancelAnimationFrame(animHandle); animHandle = null; }
}
function animTick(now) {
  const newPhase = (((state.phase + state.animRate * (now - animLastTime)) % 1) + 1) % 1;
  animLastTime = now;
  sliders.phase.set(newPhase, false);
  state.phase = newPhase;
  renderVisualizationPhase();
  if (state.animating) animHandle = requestAnimationFrame(animTick);
}

function onResetClicked() {
  if (state.animating) toggleAnimation();
  sliders.planetMass.set(1, false);
  sliders.separation.set(1, false);
  sliders.eccentricity.set(0.2, false);
  sliders.starMass.set(1, false);
  sliders.inclination.set(90, false);
  sliders.longitude.set(45, false);
  sliders.noise.set(15, false);
  sliders.number.set(150, false);
  sliders.animRate.set(0.0005, false);
  sliders.phase.set(0, false);
  Object.assign(state, {
    planetMass: 1, separation: 1, eccentricity: 0.2, starMass: 1, inclination: 90, longitude: 45,
    noise: 15, numMeasurements: 150, animRate: 0.0005, phase: 0, phaseOffset: 0.75,
    theta: 80, phi: 45, showCurve: true, showMeasurements: false, showPanels: false,
  });
  el('showCurveCheck').checked = true;
  el('showMeasurementsCheck').checked = false;
  el('showPanelsCheck').checked = false;
  el('noiseSlider').disabled = el('noiseField').disabled = true;
  el('numberSlider').disabled = el('numberField').disabled = true;
  el('presetsSelect').value = '0';
  el('setPresetButton').disabled = true;
  measurementPointCache = { eccentricity: null, points: [] };
  fullUpdate();
  announce('Simulation reset to initial values.');
}

/* -------------------------------------------------------------------
   14. Pointer + keyboard dragging. Canvas keeps its original internal
       coordinate system (400x400 / 700x380); pointer coordinates are
       mapped back through the CSS scale factor so hit-testing and drag
       math match the AS source at any display size (touch-action:none
       on the proxies keeps touch drags from scrolling the page).
   ------------------------------------------------------------------- */
function internalScale(canvas) { return canvas.width / canvas.getBoundingClientRect().width || 1; }

function setupVizDrag() {
  const proxy = el('vizDragProxy'), canvas = viz.canvas;
  let dragging = false, startX = 0, startY = 0, startTheta = 0, startPhi = 0;
  // Map a client point into the 400x400 stage coordinate system: undo the
  // CSS scale (rect -> backing pixels), then the center offset + fit scale.
  function toInternal(clientX, clientY) {
    const r = canvas.getBoundingClientRect();
    const s = canvas.width / r.width || 1;
    return {
      x: ((clientX - r.left) * s - viz.offsetX) / viz.scale,
      y: ((clientY - r.top) * s - viz.offsetY) / viz.scale,
    };
  }
  proxy.addEventListener('pointerdown', e => {
    proxy.focus(); dragging = true; proxy.setPointerCapture(e.pointerId);
    const p = toInternal(e.clientX, e.clientY);
    startX = p.x; startY = p.y; startTheta = state.theta; startPhi = state.phi;
  });
  proxy.addEventListener('pointermove', e => {
    if (!dragging) return;
    const p = toInternal(e.clientX, e.clientY);
    let phi = startPhi + 57.29577951308232 * (p.y - startY) / 200;
    phi = Math.max(-90, Math.min(90, phi));
    state.theta = startTheta - 57.29577951308232 * (p.x - startX) / 200;
    state.phi = phi;
    renderVisualization();
  });
  proxy.addEventListener('pointerup', () => { dragging = false; announceOrientation(); });
  proxy.addEventListener('keydown', e => {
    const step = e.shiftKey ? 10 : 3;
    if (e.key === 'ArrowLeft') { state.theta -= step; }
    else if (e.key === 'ArrowRight') { state.theta += step; }
    else if (e.key === 'ArrowUp') { state.phi = Math.min(90, state.phi + step); }
    else if (e.key === 'ArrowDown') { state.phi = Math.max(-90, state.phi - step); }
    else if (e.key === 'Home') { state.theta = 80; state.phi = 45; }
    else return;
    e.preventDefault();
    renderVisualization();
    announceOrientation();
  });
}
function announceOrientation() {
  positionVizDragProxy();
  announce(`View orientation: azimuth ${Math.round(state.theta)} degrees, altitude ${Math.round(state.phi)} degrees.`);
}

function setupPhaseCursorDrag() {
  const proxy = el('phaseCursorProxy'), canvas = rvPlot.canvas;
  let dragging = false, xOffset = 0;
  function toInternalX(clientX) {
    const r = canvas.getBoundingClientRect();
    return (clientX - r.left) * internalScale(canvas) - rvPlot.OX; // -> plot coords
  }
  proxy.addEventListener('pointerdown', e => {
    proxy.focus(); dragging = true; proxy.setPointerCapture(e.pointerId);
    const cursorX = (((state.phaseOffset + state.phase) % 1 + 1) % 1) * rvPlot.PW;
    xOffset = toInternalX(e.clientX) - cursorX;
  });
  proxy.addEventListener('pointermove', e => {
    if (!dragging) return;
    const x = toInternalX(e.clientX) - xOffset;
    setPhaseFromCursor(x / rvPlot.PW - state.phaseOffset);
  });
  proxy.addEventListener('pointerup', () => { dragging = false; });
  proxy.addEventListener('keydown', e => {
    const step = e.shiftKey ? 0.05 : 0.01;
    if (e.key === 'ArrowLeft') setPhaseFromCursor(state.phase - step);
    else if (e.key === 'ArrowRight') setPhaseFromCursor(state.phase + step);
    else if (e.key === 'Home') setPhaseFromCursor(0);
    else if (e.key === 'End') setPhaseFromCursor(0.999);
    else return;
    e.preventDefault();
  });
}
function setPhaseFromCursor(phase) {
  phase = ((phase % 1) + 1) % 1;
  state.phase = phase;
  sliders.phase.set(phase, false);
  renderVisualizationPhase();
  announce(`Current phase ${phase.toFixed(3)}.`);
}

// Background drag pans the phase axis (phaseOffset) without changing any
// physical parameter; hover shows a crosshair velocity readout — both
// mirror Radial Velocity Component.as's backgroundMC handlers.
function setupPlotBackgroundInteraction() {
  const canvas = rvPlot.canvas, readout = el('plotCrosshairReadout');
  let panning = false, panOffsetStart = 0, panXStart = 0;
  // The plot canvas may be scaled non-uniformly (its display box no longer
  // preserves the 700x380 backing aspect ratio, so the panel can be made
  // shorter to match the square left panel), so x and y must be mapped back
  // through their own separate scale factors.
  function toInternal(clientX, clientY) {
    const r = canvas.getBoundingClientRect();
    const sx = canvas.width / r.width || 1, sy = canvas.height / r.height || 1;
    // subtract the plot-area margin so (0,0) is the plot's top-left corner
    return { x: (clientX - r.left) * sx - rvPlot.OX, y: (clientY - r.top) * sy - rvPlot.OY };
  }
  canvas.addEventListener('pointerdown', e => {
    panning = true; canvas.setPointerCapture(e.pointerId);
    const p = toInternal(e.clientX, e.clientY);
    panXStart = p.x; panOffsetStart = state.phaseOffset;
    readout.hidden = true;
  });
  canvas.addEventListener('pointermove', e => {
    const p = toInternal(e.clientX, e.clientY);
    if (panning) {
      // keep normalized into [0,1), matching the AS setPhaseOffset setter
      state.phaseOffset = ((panOffsetStart + (p.x - panXStart) / rvPlot.PW) % 1 + 1) % 1;
      renderRVPlot();
      return;
    }
    if (p.x < 0 || p.x > rvPlot.PW || p.y < 0 || p.y > rvPlot.PH || !rvPlot.rv) { readout.hidden = true; return; }
    const velocity = rvPlot.yAxisMax + p.y / rvPlot.yScale;
    const kDigits = -Math.floor(Math.log(1 / rvPlot.PW * (rvPlot.yAxisMax - rvPlot.yAxisMin)) / Math.LN10);
    const velocityString = kDigits <= 0
      ? String(Math.pow(10, -kDigits) * Math.round(velocity / Math.pow(10, -kDigits)))
      : velocity.toFixed(kDigits);
    readout.hidden = false; readout.textContent = velocityString + ' m/s';
    // position relative to the canvas/stage: convert plot coords back to
    // backing coords (+OX/+OY) then to CSS px (backing -> client scale).
    const csx = canvas.clientWidth / canvas.width || 1;
    const csy = canvas.clientHeight / canvas.height || 1;
    readout.style.left = ((rvPlot.OX + p.x) * csx) + 'px';
    readout.style.top = Math.max(0, (rvPlot.OY + p.y) * csy - 6) + 'px';
  });
  canvas.addEventListener('pointerup', () => { panning = false; });
  canvas.addEventListener('pointerleave', () => { panning = false; readout.hidden = true; });
}

/* -------------------------------------------------------------------
   15. Reset (masthead "sim-reset" event) + bootstrap.
   ------------------------------------------------------------------- */
function init() {
  viz.canvas = el('vizCanvas'); viz.ctx = viz.canvas.getContext('2d');
  rvPlot.canvas = el('plotCanvas'); rvPlot.ctx = rvPlot.canvas.getContext('2d');
  // Enlarge the plot canvas backing to include the axis-label margins.
  rvPlot.canvas.width = rvPlot.OX + rvPlot.PW + rvPlot.OR;
  rvPlot.canvas.height = rvPlot.OY + rvPlot.PH + rvPlot.OB;

  initSliders();
  initCheckboxesAndButtons();
  setupVizDrag();
  setupPhaseCursorDrag();
  setupPlotBackgroundInteraction();

  document.addEventListener('sim-reset', onResetClicked);
  // Re-fit the top row (square left / matched right), the viz canvas, and the
  // plot cursor proxy when the panel resizes or fonts finish loading.
  window.addEventListener('resize', relayoutTop);
  if (document.fonts && document.fonts.ready) document.fonts.ready.then(relayoutTop);

  onResetClicked();
  relayoutTop();
}

// Force the two top panels to an identical height equal to the left panel's
// width, so the left (visualization) panel is a perfect SQUARE and the right
// (plot) panel is tightened to match it, with their bottom edges aligned. The
// RV plot inside the right panel flexes to fill whatever height remains above
// its fixed controls. Only applies in the two-column layout; below the
// stacking breakpoint the panels are full-width and heights are left natural.
function relayoutTop() {
  const top = document.querySelector('.rvs-top');
  const vizPanel = document.querySelector('.rvs-panel--viz');
  const plotPanel = document.querySelector('.rvs-panel--plot');
  if (!top || !vizPanel || !plotPanel) return;
  vizPanel.style.height = ''; plotPanel.style.height = '';
  const stacked = getComputedStyle(top).gridTemplateColumns.split(' ').filter(Boolean).length < 2;
  if (!stacked) {
    const w = vizPanel.getBoundingClientRect().width;
    if (w > 0) { vizPanel.style.height = w + 'px'; plotPanel.style.height = w + 'px'; }
  }
  renderVisualization();
  positionPhaseCursorProxy();
}

function positionPhaseCursorProxy() {
  const canvas = rvPlot.canvas, proxy = el('phaseCursorProxy');
  const csx = canvas.clientWidth / canvas.width || 1; // backing -> CSS px
  // same wrap as the drawn cursor line, so the proxy sits over it; the plot
  // area starts at OX within the (larger) canvas backing.
  const frac = ((state.phaseOffset + state.phase) % 1 + 1) % 1;
  const xCss = (rvPlot.OX + frac * rvPlot.PW) * csx;
  proxy.style.left = xCss + 'px';
  proxy.setAttribute('aria-valuenow', String(state.phase));
  proxy.setAttribute('aria-valuetext', 'Current phase ' + state.phase.toFixed(3));
}

if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', init);
else init();
