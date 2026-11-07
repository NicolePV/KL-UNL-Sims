/* ==========================================================================
 * Synodic Period Calculator -- HTML5 port of the legacy Flash (AS1) sim.
 *
 * Behaviour is ported verbatim from the decompiled ActionScript (see
 * CONVERSION_NOTES.md). The calculator relates a planet's sidereal period P,
 * Earth's (fixed) sidereal period E, and the synodic period S through:
 *
 *     Superior planet:   1/S = 1/E - 1/P     (P > E)
 *     Inferior planet:   1/S = 1/P - 1/E     (P < E)
 *
 * E is FIXED by the chosen units: 1.00 years, or 365.25 days. In the original,
 * the "Days" branch multiplies by the literal reciprocal constant 1/365.25 and
 * compares P (or S) against 365.25 -- reproduced exactly below. The planet
 * period P and synodic period S are interlinked: editing one computes the
 * other, and out-of-range inputs display the literal string "Ouch!".
 * ========================================================================== */

'use strict';

/* -------------------------------------------------------------------------- */
/* Constants (verbatim from the AS source)                                     */
/* -------------------------------------------------------------------------- */
const E_YEARS = 1.00;           // Earth sidereal period in years  (display "1.00")
const E_DAYS  = 365.25;         // Earth sidereal period in days   (display "365.25")
const INV_E_YEARS = 1;          // 1/E used in the Years arithmetic (literal 1)
const INV_E_DAYS  = 1 / 365.25; // 1/E used in the Days  arithmetic (literal 1/365.25)

const PMODE = { SUPERIOR: 1, INFERIOR: 2 };
const UMODE = { YEARS: 1, DAYS: 2 };

/* -------------------------------------------------------------------------- */
/* Single source of truth: one state object                                    */
/* -------------------------------------------------------------------------- */
const state = {
  pmode: PMODE.SUPERIOR,
  umode: UMODE.YEARS,
  pText: '',      // planet-period field text (verbatim, may be "" or "Ouch!")
  sText: '',      // synodic-period field text
  stepSize: 0.01  // Arrow/wheel step: hundredths of a year, or 1 day
};

/* -------------------------------------------------------------------------- */
/* Element references                                                          */
/* -------------------------------------------------------------------------- */
const el = {
  planetSuperior: document.getElementById('planet-superior'),
  planetInferior: document.getElementById('planet-inferior'),
  unitsYears:     document.getElementById('units-years'),
  unitsDays:      document.getElementById('units-days'),
  sInput:         document.getElementById('s-input'),
  pInput:         document.getElementById('p-input'),
  eOutput:        document.getElementById('e-output'),
  sUnit:          document.getElementById('s-unit'),
  eUnit:          document.getElementById('e-unit'),
  pUnit:          document.getElementById('p-unit'),
  live:           document.getElementById('syn-live')
};

/* -------------------------------------------------------------------------- */
/* Helpers                                                                     */
/* -------------------------------------------------------------------------- */

// Earth period and its reciprocal for the current units.
function earthPeriod() { return state.umode === UMODE.YEARS ? E_YEARS : E_DAYS; }
function invEarth()    { return state.umode === UMODE.YEARS ? INV_E_YEARS : INV_E_DAYS; }

// Display string for E, matching the original literal text.
function earthText()   { return state.umode === UMODE.YEARS ? '1.00' : '365.25'; }

// Unit word for speech / display.
function unitWord()    { return state.umode === UMODE.YEARS ? 'years' : 'days'; }

// Round to two decimals exactly as the AS: Math.round(x * 100) / 100.
function round2(x) { return Math.round(x * 100) / 100; }

// Format a computed number for display, matching Flash Number -> String
// (drops trailing zeros: 1.5 -> "1.5", 2 -> "2").
function numText(x) { return String(x); }

/* -------------------------------------------------------------------------- */
/* Core calculation (ported branch-for-branch from the AS onChanged handlers)  */
/* -------------------------------------------------------------------------- */

// Compute the synodic period S from the planet period P (the "P changed" path).
// Returns { kind: 'blank' | 'ouch' | 'value', value }.
function computeSfromP(pText) {
  const P = parseFloat(pText);
  if (!(P > 0) || !isFinite(P)) return { kind: 'blank' };

  if (state.pmode === PMODE.SUPERIOR) {
    // Valid only when P > E; else "Ouch!". S = 1 / (1/E - 1/P).
    if (P > earthPeriod()) {
      return { kind: 'value', value: round2(1 / (invEarth() - 1 / P)) };
    }
    return { kind: 'ouch' };
  } else {
    // Inferior: valid only when P < E; else "Ouch!". S = 1 / (1/P - 1/E).
    if (P < earthPeriod()) {
      return { kind: 'value', value: round2(1 / (1 / P - invEarth())) };
    }
    return { kind: 'ouch' };
  }
}

// Compute the planet period P from the synodic period S (the "S changed" path).
// Returns { kind: 'blank' | 'ouch' | 'value', value }.
function computePfromS(sText) {
  const S = parseFloat(sText);
  if (!(S > 0) || !isFinite(S)) return { kind: 'blank' };

  let P;
  if (state.pmode === PMODE.SUPERIOR) {
    // P = 1 / (1/E - 1/S)
    P = round2(1 / (invEarth() - 1 / S));
  } else {
    // Inferior: P = 1 / (1/S + 1/E)
    P = round2(1 / (1 / S + invEarth()));
  }
  // Original guards tmp2 > 0, else "Ouch!".
  return P > 0 ? { kind: 'value', value: P } : { kind: 'ouch' };
}

/* -------------------------------------------------------------------------- */
/* Rendering: one render() syncs the DOM + live region from state              */
/* -------------------------------------------------------------------------- */

// The two editable fields hold verbatim text (numbers, "", or "Ouch!"); we only
// write them when the value differs, so we never disturb the caret while typing.
function setFieldText(input, text) {
  if (input.value !== text) input.value = text;
}

function render() {
  // Earth (fixed display).
  el.eOutput.textContent = earthText();
  el.eOutput.setAttribute('aria-label',
    `Earth period E, ${earthText()} ${unitWord()}`);

  // Unit labels next to each field.
  el.sUnit.textContent = unitWord();
  el.eUnit.textContent = unitWord();
  el.pUnit.textContent = unitWord();

  // Accessible names for the editable fields, WITH units.
  el.sInput.setAttribute('aria-label', `Synodic period S, in ${unitWord()}`);
  el.pInput.setAttribute('aria-label', `Planet sidereal period P, in ${unitWord()}`);

  // Field text.
  setFieldText(el.sInput, state.sText);
  setFieldText(el.pInput, state.pText);

  // Colour the "Ouch!" state (never colour-only: the word "Ouch!" is the signal).
  el.sInput.classList.toggle('syn-input--ouch', state.sText === 'Ouch!');
  el.pInput.classList.toggle('syn-input--ouch', state.pText === 'Ouch!');

  updateEquation();
}

// Announce a computed result on the live region, with units.
function announce(quantityName, result) {
  let msg;
  if (result.kind === 'value') {
    msg = `${quantityName} is ${numText(result.value)} ${unitWord()}.`;
  } else if (result.kind === 'ouch') {
    msg = `${quantityName}: Ouch, no valid value for these inputs.`;
  } else {
    return; // blank -> nothing to announce
  }
  el.live.textContent = msg;
}

/* -------------------------------------------------------------------------- */
/* Event handlers                                                              */
/* -------------------------------------------------------------------------- */

// Mirror the Flash restrict "0-9.e": keep only digits, dot, and 'e'.
function filterNumeric(value) {
  return value.replace(/[^0-9.e]/g, '');
}

// User edits the planet-period field -> recompute S.
function onPInput() {
  const filtered = filterNumeric(el.pInput.value);
  if (filtered !== el.pInput.value) el.pInput.value = filtered;

  state.pText = filtered;
  const result = computeSfromP(filtered);
  state.sText = result.kind === 'value' ? numText(result.value)
              : result.kind === 'ouch'  ? 'Ouch!'
              : '';
  render();
  announce('Synodic period S', result);
}

// User edits the synodic-period field -> recompute P.
function onSInput() {
  const filtered = filterNumeric(el.sInput.value);
  if (filtered !== el.sInput.value) el.sInput.value = filtered;

  state.sText = filtered;
  const result = computePfromS(filtered);
  state.pText = result.kind === 'value' ? numText(result.value)
              : result.kind === 'ouch'  ? 'Ouch!'
              : '';
  render();
  announce('Planet sidereal period P', result);
}

// Switch Superior/Inferior: set pmode, clear both period fields (E unchanged).
function changePlanets(mode) {
  state.pmode = mode;
  state.pText = '';
  state.sText = '';
  render();
  el.live.textContent =
    `${mode === PMODE.SUPERIOR ? 'Superior' : 'Inferior'} planet selected. ` +
    `Planet and synodic period cleared.`;
}

// Switch Years/Days: set umode, reset E display, clear both period fields.
function changeUnits(mode) {
  state.umode = mode;
  state.pText = '';
  state.sText = '';
  // Match the original step feel: whole days vs hundredths of a year.
  state.stepSize = mode === UMODE.YEARS ? 0.01 : 1;
  render();
  el.live.textContent =
    `Units set to ${unitWord()}. Earth period E is ${earthText()} ${unitWord()}. ` +
    `Planet and synodic period cleared.`;
}

/* -------------------------------------------------------------------------- */
/* Keyboard + wheel stepping for the numeric text fields (accessibility)       */
/* -------------------------------------------------------------------------- */
// The originals were plain text fields; per the accessibility rules every
// numeric value field must also increment/decrement by Arrow keys and the mouse
// wheel while focused. Each change flows through the same onInput path.
function stepField(input, onInput, delta) {
  const base = parseFloat(input.value);
  let next = (isFinite(base) ? base : 0) + delta;
  next = round2(next);
  if (next < 0) next = 0;             // respects min="0"
  input.value = numText(next);
  onInput();
}

function attachStepping(input, onInput) {
  input.addEventListener('keydown', (ev) => {
    const step = state.stepSize;
    let delta = 0;
    switch (ev.key) {
      case 'ArrowUp':   delta =  step;      break;
      case 'ArrowDown': delta = -step;      break;
      case 'PageUp':    delta =  step * 10; break;
      case 'PageDown':  delta = -step * 10; break;
      case 'Home':
        ev.preventDefault();
        input.value = '0';
        onInput();
        return;
      default: return;
    }
    ev.preventDefault();
    stepField(input, onInput, delta);
  });

  // Mouse wheel adjusts only while the field is focused (so page scroll is
  // unaffected otherwise).
  input.addEventListener('wheel', (ev) => {
    if (document.activeElement !== input) return;
    ev.preventDefault();
    const step = state.stepSize;
    stepField(input, onInput, ev.deltaY < 0 ? step : -step);
  }, { passive: false });
}

/* -------------------------------------------------------------------------- */
/* Reset (masthead "sim-reset" event) -> exact initial state                   */
/* -------------------------------------------------------------------------- */
function resetSim() {
  state.pmode = PMODE.SUPERIOR;
  state.umode = UMODE.YEARS;
  state.pText = '';
  state.sText = '';
  state.stepSize = 0.01;

  el.planetSuperior.checked = true;
  el.planetInferior.checked = false;
  el.unitsYears.checked = true;
  el.unitsDays.checked = false;

  render();
  el.live.textContent =
    'Reset. Superior planet, units in years. Earth period E is 1.00 years.';
}

/* -------------------------------------------------------------------------- */
/* Equation via the foundation MathJax helper                                  */
/* -------------------------------------------------------------------------- */
function updateEquation() {
  if (state.pmode === PMODE.SUPERIOR) {
    klunlShowEquation(
      ['eqn-synodic', '\\[ \\dfrac{1}{S} = \\dfrac{1}{E} - \\dfrac{1}{P} \\]'],
      ['sr-eqn-synodic',
        'Superior planet relation: one over S equals one over E minus one over P.']
    );
  } else {
    klunlShowEquation(
      ['eqn-synodic', '\\[ \\dfrac{1}{S} = \\dfrac{1}{P} - \\dfrac{1}{E} \\]'],
      ['sr-eqn-synodic',
        'Inferior planet relation: one over S equals one over P minus one over E.']
    );
  }
}

// Redefine the foundation hook so it is invoked once MathJax is ready.
window.klunlInitEqn = function () {
  updateEquation();
};

/* -------------------------------------------------------------------------- */
/* Init                                                                         */
/* -------------------------------------------------------------------------- */
function init() {
  el.pInput.addEventListener('input', onPInput);
  el.sInput.addEventListener('input', onSInput);
  attachStepping(el.pInput, onPInput);
  attachStepping(el.sInput, onSInput);

  el.planetSuperior.addEventListener('change', () => changePlanets(PMODE.SUPERIOR));
  el.planetInferior.addEventListener('change', () => changePlanets(PMODE.INFERIOR));
  el.unitsYears.addEventListener('change', () => changeUnits(UMODE.YEARS));
  el.unitsDays.addEventListener('change', () => changeUnits(UMODE.DAYS));

  document.addEventListener('sim-reset', resetSim);

  render();

  // Typeset the equation once MathJax has finished loading (it also auto-typesets
  // the static variable labels \(S\), \(E\), \(P\) in the markup).
  if (window.MathJax && window.MathJax.startup && window.MathJax.startup.promise) {
    window.MathJax.startup.promise.then(() => window.klunlInitEqn());
  } else {
    window.addEventListener('load', () => window.klunlInitEqn());
  }
}

init();
