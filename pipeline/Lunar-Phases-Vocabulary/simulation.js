// ---------------------------------------------------------------------------
// Lunar Phase Vocabulary -- HTML5 port of lunar_phaser.swf (Flash 6 / AS1)
//
// Ported from the decompiled ActionScript:
//   scripts/moonPhaseSymbol.as                       -> moonPhaseClass below
//   scripts/frame_1/DoAction.as                      -> wiring + elapsed-time text
//   scripts/frame_1/PlaceObject2_2_..._on(initialize) -> INIT_* constants
//
// Every constant, formula and displayed string below is verbatim from that
// source. Presentation (KL-UNL chrome, semantics, narration) follows the
// pipeline + WCAG rules; the physics/geometry is untouched.
// ---------------------------------------------------------------------------

'use strict';

// --- Constants, verbatim from moonPhaseClass() ------------------------------
const SYNODIC = 29.5;   // this._SYNODIC -- synodic month, days
const MARGIN  = 10;     // this._MARGIN  -- mask box overhang beyond the disc
const RADIUS  = 101;    // this._RADIUS  -- moon disc radius, stage units
const N       = 5;      // this._N       -- terminator anchor points

// --- From the on(initialize) clip action on the myMoon instance -------------
const INIT_ANIM   = false;
const INIT_PERIOD = 10;          // superseded on frame 1 (see INIT_* use below)
const INIT_PHASE  = 'Full Moon';

// --- Set on frame 1 (scripts/frame_1/DoAction.as), overriding the above -----
const FRAME_PERIOD     = 29.5;   // myMoon.setSpeed("period", 29.5)
const FRAME_DARK_ALPHA = 60;     // myMoon.darkAlpha = 60
const PHASE_TOLERANCE  = 12;     // this.setPhaseTolerance(12) -- hours

const DEG2RAD = 0.017453292519943295;
const RAD2DEG = 57.29577951308232;
const TWO_PI  = 6.283185307179586;

// The moon bitmap exported from the SWF (images/3.jpg) is 220x220 and the
// symbol places it centred on its own origin, so the symbol's natural box is
// 220x220 with (0,0) at the middle. All ported math stays in these units.
const STAGE_SIZE = 220;
const STAGE_MID  = STAGE_SIZE / 2;

// ---------------------------------------------------------------------------
// moonPhaseClass -- port of the AS1 prototype class
// ---------------------------------------------------------------------------
function moonPhaseClass() {
  // Terminator control/anchor points. Verbatim from the AS constructor: the
  // terminator is a 4-segment quadratic approximation of a half-ellipse whose
  // horizontal semi-axis is RADIUS * cos(phase).
  this._term_aP = [];
  this._term_cP = [];
  const step   = Math.PI / (N - 1);
  const a_dist = 1 / Math.cos(step / 2);
  for (let i = 0; i < N; i++) {
    const angle = i * step;
    this._term_aP[i] = { x: RADIUS * Math.sin(angle), y: RADIUS * Math.cos(angle) };
    if (i !== 0) {
      const angle2 = step / 2 + (i - 1) * step;
      this._term_cP[i] = {
        x: RADIUS * a_dist * Math.sin(angle2),
        y: RADIUS * a_dist * Math.cos(angle2)
      };
    } else {
      this._term_cP[0] = null;
    }
  }

  this._dark_alpha = 70;              // setDarkAlpha(70) in the constructor
  this._phase      = 0;
  this.setPhase(INIT_PHASE);
  this.setPhaseTolerance(PHASE_TOLERANCE);
  this._animating  = Boolean(INIT_ANIM);
  this._stop_at    = null;
  this._time_last  = 0;
  this.setSpeed('period', INIT_PERIOD);
}

const p = moonPhaseClass.prototype;

// AS1 mod(): always returns a non-negative remainder.
p.mod = function (number, modulus) {
  if (number < 0) { return number % modulus + modulus; }
  return number % modulus;
};

p.stringCompare = function (str1, str2) {
  return String(str1).toLowerCase() === String(str2).toLowerCase();
};

// getSpeed/setSpeed: _speed is in days-of-phase per millisecond.
// "period" seconds of wall clock == one full synodic month.
p.setSpeed = function (mode, value) {
  const tmp = parseFloat(value);
  if (!isFinite(tmp)) { return false; }
  if (this.stringCompare(mode, 'period')) {
    if (tmp === 0) { return false; }
    this._speed = SYNODIC / (1000 * tmp);
    return true;
  }
  if (this.stringCompare(mode, 'rate')) {
    this._speed = tmp / 1000;
    return true;
  }
  return false;
};

p.startAnimation = function () { this._stop_at = null; this._animating = true;  };
p.stopAnimation  = function () { this._stop_at = null; this._animating = false; };
p.getAnimating   = function () { return this._animating; };

p.getPhase = function () { return this._phase * RAD2DEG; };

p.setPhase = function (nameOrAngle) {
  let tmp = this.getAngleFromName(nameOrAngle);
  if (isNaN(tmp)) {
    tmp = Number(nameOrAngle);
    if (!isFinite(tmp)) { return false; }
  }
  this._phase = this.mod(tmp, 360) * DEG2RAD;
  return true;
};

p.getAngleFromName = function (name) {
  if (this.stringCompare(name, 'new') || this.stringCompare(name, 'new moon')) { return 0; }
  if (this.stringCompare(name, 'waxing crescent'))                             { return 45; }
  if (this.stringCompare(name, 'first quarter'))                               { return 90; }
  if (this.stringCompare(name, 'waxing gibbous'))                              { return 135; }
  if (this.stringCompare(name, 'full') || this.stringCompare(name, 'full moon')) { return 180; }
  if (this.stringCompare(name, 'waning gibbous'))                              { return 225; }
  if (this.stringCompare(name, 'third quarter') || this.stringCompare(name, 'last quarter')) { return 270; }
  if (this.stringCompare(name, 'waning crescent'))                             { return 315; }
  return NaN;
};

// Note: the source names 270 degrees "Third Quarter" here while the on-stage
// button reads "Last Quarter". Both strings are kept verbatim; see
// CONVERSION_NOTES.md.
p.getNameFromAngle = function (angle) {
  let tmp = parseFloat(angle);
  if (!isFinite(tmp)) { return '<invalid phase>'; }
  tmp = this.mod(tmp, 360);
  const tol = this._phase_tol;
  if (tmp <= tol)        { return 'New Moon';        }
  if (tmp <  90  - tol)  { return 'Waxing Crescent'; }
  if (tmp <= 90  + tol)  { return 'First Quarter';   }
  if (tmp <  180 - tol)  { return 'Waxing Gibbous';  }
  if (tmp <= 180 + tol)  { return 'Full Moon';       }
  if (tmp <  270 - tol)  { return 'Waning Gibbous';  }
  if (tmp <= 270 + tol)  { return 'Third Quarter';   }
  if (tmp <  360 - tol)  { return 'Waning Crescent'; }
  if (tmp <= 360)        { return 'New Moon';        }
  return '<invalid phase>';
};

p.getPhaseAsName = function () { return this.getNameFromAngle(this.getPhase()); };

// Tolerance is given in hours and converted to degrees of phase.
p.setPhaseTolerance = function (hours) {
  const arg = Math.abs(parseFloat(hours));
  if (!isFinite(arg)) { return; }
  this._phase_tol = arg * 360 / (SYNODIC * 24);
  if (this._phase_tol > 30) { this._phase_tol = 30; }
};

p.setDarkAlpha = function (value) {
  const tmp = Number(value);
  if (isFinite(tmp)) { this._dark_alpha = tmp; }
};

// onEnterFrame -> driven by the rAF loop. Uses elapsed wall-clock time, as the
// AS did with getTimer(), so the rate is frame-rate independent.
p.step = function (time_now) {
  if (this._animating) {
    const dt        = this._speed * (time_now - this._time_last);
    const da        = dt * (360 / SYNODIC) * DEG2RAD;
    const old_phase = this._phase;
    const mid_step  = old_phase + da;
    this._phase     = this.mod(mid_step, TWO_PI);

    const wrapped = (mid_step !== this._phase);

    // _stop_at is only ever set by animateTo()/animateFor(), which this sim
    // never calls; kept for parity with the source class.
    if (this._stop_at !== null) {
      const hit = wrapped
        ? (this._stop_at < old_phase && this._stop_at <= this._phase) ||
          (this._stop_at > old_phase && this._stop_at >= this._phase)
        : (this._stop_at > old_phase && this._stop_at <= this._phase) ||
          (this._stop_at < old_phase && this._stop_at >= this._phase);
      if (hit) {
        this._phase    = this._stop_at;
        this._animating = false;
        this._stop_at   = null;
      }
    }
  }
  this._time_last = time_now;
};

// Port of updateMask(). The AS drew this into an empty movie clip layered over
// the moon bitmap -- despite the name it is a translucent black overlay, not a
// clipping mask -- so it becomes a filled canvas path with the same geometry.
p.drawTerminator = function (ctx) {
  const phase = this.mod(this._phase, TWO_PI);

  // Which side the unlit box sits on: left while waxing, right while waning.
  let box_direction = 1;
  if (phase < Math.PI) { box_direction = -1; }
  const box_side = RADIUS + MARGIN;

  ctx.beginPath();
  ctx.moveTo(0, RADIUS);
  ctx.lineTo(0, box_side);
  ctx.lineTo(box_direction * box_side,  box_side);
  ctx.lineTo(box_direction * box_side, -box_side);
  ctx.lineTo(0, -box_side);
  ctx.lineTo(0, -RADIUS);

  const cos_phase = Math.cos(this.mod(phase, Math.PI));
  // The AS loop starts at i = 0, but _term_cP[0] is null and _term_aP[0] lands
  // exactly on the current pen position, so that first curve is degenerate and
  // encloses no area. Starting at 1 is equivalent. (See CONVERSION_NOTES.md.)
  for (let i = 1; i < N; i++) {
    ctx.quadraticCurveTo(
      this._term_cP[i].x * cos_phase, -this._term_cP[i].y,
      this._term_aP[i].x * cos_phase, -this._term_aP[i].y
    );
  }
  ctx.closePath();

  ctx.fillStyle = 'rgba(0, 0, 0, ' + (this._dark_alpha / 100) + ')';
  ctx.fill();
};

// Fraction of the disc that is sunlit, for the screen-reader description.
// k = (1 - cos(phase)) / 2  -- 0 at new moon, 1 at full moon.
p.getIlluminatedFraction = function () {
  return (1 - Math.cos(this._phase)) / 2;
};

// Which limb is lit: the unlit box is on the left while waxing.
p.getLitSide = function () {
  return (this.mod(this._phase, TWO_PI) < Math.PI) ? 'right' : 'left';
};

// ---------------------------------------------------------------------------
// Single state object -- everything the sim knows lives here.
// ---------------------------------------------------------------------------
const state = {
  moon:       null,   // moonPhaseClass instance
  start_time: 0,      // getTimer() baseline for the elapsed-day readout
  run_time:   '',     // exact text of the original run_time field
  lastSpokenPhaseName: null
};

const dom = {};
let ctx = null;
let moonImage = null;
let moonImageReady = false;
let lastEqnLatex = null;

// ---------------------------------------------------------------------------
// Initial state, exactly as frame 1 leaves it
// ---------------------------------------------------------------------------
function resetToInitialState() {
  const moon = new moonPhaseClass();
  moon.setSpeed('period', FRAME_PERIOD);   // myMoon.setSpeed("period", 29.5)
  moon.setDarkAlpha(FRAME_DARK_ALPHA);     // myMoon.darkAlpha = 60
  moon.stopAnimation();                    // myMoon.stopAnimation()
  moon._time_last = performance.now();

  state.moon                = moon;
  state.start_time          = performance.now();
  state.run_time            = '';          // runtime.text = ""
  state.lastSpokenPhaseName = moon.getPhaseAsName();
}

// ---------------------------------------------------------------------------
// Elapsed-time text -- verbatim port of the onEnterFrame formatting
// ---------------------------------------------------------------------------
function formatElapsed(current_time) {
  const elapsed_time = (current_time - state.start_time) / 1000;
  const days = Math.round(elapsed_time * 10) / 10;
  let temp = days + ' days';
  // The AS wrote temp.indexof("."); SWF 6 resolved member names
  // case-insensitively, so this ran as String.indexOf and the pad below
  // applies. Whole days therefore display as e.g. "5.0 days".
  if (temp.indexOf('.') === -1) {
    const i = temp.split(' ');
    i[0] += '.0 ';
    temp = i[0] + i[1];
  }
  return temp;
}

// ---------------------------------------------------------------------------
// Rendering -- one render() drives canvas, DOM and the narration text
// ---------------------------------------------------------------------------
function sizeCanvas() {
  const dpr = window.devicePixelRatio || 1;
  dom.canvas.width  = Math.round(STAGE_SIZE * dpr);
  dom.canvas.height = Math.round(STAGE_SIZE * dpr);
  ctx = dom.canvas.getContext('2d');
  ctx.setTransform(dpr, 0, 0, dpr, 0, 0);
  ctx.translate(STAGE_MID, STAGE_MID);   // symbol origin at the disc centre
}

function drawCanvas() {
  if (!ctx) { return; }
  ctx.save();
  ctx.setTransform(1, 0, 0, 1, 0, 0);
  ctx.clearRect(0, 0, dom.canvas.width, dom.canvas.height);
  ctx.restore();

  // Preference order: the moon is an exported BITMAP, so it is drawn from the
  // file as-is, never redrawn. Only the terminator overlay was code-drawn in
  // the AS, so only that is reproduced on the canvas.
  if (moonImageReady) {
    ctx.drawImage(moonImage, -STAGE_MID, -STAGE_MID, STAGE_SIZE, STAGE_SIZE);
  }
  state.moon.drawTerminator(ctx);
}

function describeMoon() {
  const moon    = state.moon;
  const name    = moon.getPhaseAsName();
  const percent = Math.round(moon.getIlluminatedFraction() * 100);
  if (percent === 0)   { return name + ', none of the disc sunlit.'; }
  if (percent === 100) { return name + ', the whole disc sunlit.'; }
  return name + ', ' + percent + ' percent of the disc sunlit, on the ' +
         moon.getLitSide() + ' side.';
}

function renderElapsed() {
  // The readout is mathematical content, so it goes through MathJax via the
  // foundation helper rather than being written as plain text. The value only
  // changes ten times a second, and the guard keeps typesetting to that rate.
  const latex = state.run_time === ''
    ? ''
    : '\\(' + state.run_time.replace(' days', '\\ \\text{days}') + '\\)';
  if (latex === lastEqnLatex) { return; }
  lastEqnLatex = latex;

  const spoken = state.run_time === ''
    ? ''
    : 'Elapsed time ' + state.run_time;   // e.g. "Elapsed time 5.0 days"
  klunlShowEquation(['elapsed-eqn', latex], ['elapsed-sr', spoken]);
}

// MathJax v3's SVG output puts tabindex="0" on every mjx-container it builds.
// This readout is display-only, so that would add a bogus tab stop -- and put a
// focusable node inside an aria-hidden subtree. Strip it on every re-typeset;
// the MathJax right-click menu still works at tabindex -1.
function keepMathOutOfTabOrder(container) {
  const strip = function () {
    container.querySelectorAll('mjx-container').forEach(function (n) {
      if (n.getAttribute('tabindex') !== '-1') { n.setAttribute('tabindex', '-1'); }
    });
  };
  strip();
  new MutationObserver(strip).observe(container, { childList: true, subtree: true });
}

function render() {
  drawCanvas();
  dom.moonDesc.textContent = describeMoon();
  dom.animButton.textContent = state.moon.getAnimating()
    ? 'Stop Animation'      // verbatim from texts/38.txt
    : 'Run Animation';      // verbatim from texts/36.txt
  renderElapsed();
}

function announce(message) {
  // Cleared first so an identical repeated message is still spoken.
  dom.status.textContent = '';
  window.setTimeout(function () { dom.status.textContent = message; }, 30);
}

// ---------------------------------------------------------------------------
// Animation loop (onEnterFrame)
//
// The AS ran onEnterFrame continuously and did nothing while stopped; here the
// rAF loop only runs while the moon is actually animating, which is equivalent
// and leaves the page idle the rest of the time.
// ---------------------------------------------------------------------------
let rafId = null;

function tick(now) {
  // Captured before step(), because the AS only refreshed run_time on frames
  // where myMoon.animating was already true.
  const wasAnimating = state.moon.getAnimating();
  state.moon.step(now);

  if (wasAnimating) {
    // The reading freezes where it stopped rather than resetting, as in the AS.
    state.run_time = formatElapsed(now);

    // Speak each named phase as the moon reaches it -- meaningful, and far
    // below a per-frame flood (eight announcements per synodic cycle).
    const name = state.moon.getPhaseAsName();
    if (name !== state.lastSpokenPhaseName) {
      state.lastSpokenPhaseName = name;
      announce(describeMoon());
    }
    render();
  }

  rafId = state.moon.getAnimating() ? window.requestAnimationFrame(tick) : null;
}

function startLoop() {
  // Re-baseline the clock so the first step() sees a small dt.
  state.moon._time_last = performance.now();
  if (rafId === null) { rafId = window.requestAnimationFrame(tick); }
}

// ---------------------------------------------------------------------------
// Controls
// ---------------------------------------------------------------------------
function onPhaseButton(button) {
  // Port of the eight *Button.onRelease handlers.
  state.moon.setPhase(button.dataset.phase);
  state.start_time = performance.now();
  state.run_time   = '';
  state.lastSpokenPhaseName = state.moon.getPhaseAsName();
  render();
  // Echo the button's own wording so the press is confirmed in the user's terms.
  announce(button.textContent + ' selected. ' + describeMoon());
}

function onAnimButton() {
  if (state.moon.getAnimating()) {
    // StopAnimationButton.onRelease
    state.moon.stopAnimation();
    render();
    announce('Animation stopped at ' + (state.run_time || '0.0 days') + '. ' +
             describeMoon());
  } else {
    // RunAnimationButton.onRelease
    state.start_time = performance.now();
    state.moon.startAnimation();
    startLoop();
    render();
    announce('Animation started. The moon advances through one synodic month, ' +
             SYNODIC + ' days, every ' + FRAME_PERIOD + ' seconds.');
  }
}

function onSimReset() {
  resetToInitialState();
  render();
  announce('Simulation reset. ' + describeMoon());
}

// ---------------------------------------------------------------------------
// Start-up
// ---------------------------------------------------------------------------
function boot() {
  dom.canvas     = document.getElementById('moon-canvas');
  dom.moonDesc   = document.getElementById('moon-desc');
  dom.animButton = document.getElementById('anim-button');
  dom.status     = document.getElementById('sim-status');

  resetToInitialState();
  sizeCanvas();
  keepMathOutOfTabOrder(document.getElementById('elapsed-eqn'));

  moonImage = new Image();
  moonImage.addEventListener('load', function () {
    moonImageReady = true;
    render();
  });
  moonImage.src = 'assets/moon.jpg';

  document.querySelectorAll('.sim-phase').forEach(function (button) {
    button.addEventListener('click', function () { onPhaseButton(button); });
  });
  dom.animButton.addEventListener('click', onAnimButton);

  // Reset is the masthead's; listen for its event rather than adding a button.
  document.addEventListener('sim-reset', onSimReset);

  // Re-point the backing store when the device pixel ratio changes (zoom, or a
  // window moved between displays) so the disc stays crisp.
  window.addEventListener('resize', function () { sizeCanvas(); render(); });

  render();
}

// klunlInitEqn() is the foundation's equation hook; kl-unl.js documents that a
// sim redefines it to (re)initialise its typeset content. Ours forces the next
// renderElapsed() to typeset from scratch.
window.klunlInitEqn = function () { lastEqnLatex = null; renderElapsed(); };

if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', boot);
} else {
  boot();
}
