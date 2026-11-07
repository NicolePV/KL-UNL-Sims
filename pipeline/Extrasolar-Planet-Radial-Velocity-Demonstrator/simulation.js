/* ==========================================================================
   Radial Velocity Demonstrator
   HTML5 port of radialVelocityDemo003.swf (ActionScript 1).

   The whole original program is the main timeline script, reproduced here
   verbatim in behaviour:

       function update() {
          var _loc2_ = Math.sin(bodiesMC._rotation * 0.017453292519943295);
          this.spectrometerMC.linesMC._x = linesX + _loc2_ * linesRange;
       }
       function animOnEnterFrame() {
          var _loc2_ = getTimer();
          this.bodiesMC._rotation =
             (this.bodiesMC._rotation + this.animRate * (_loc2_ - this.timeLast)) % 360;
          this.timeLast = _loc2_;
          this.update();
       }
       function toggleAnimation() {
          if (this.onEnterFrame == this.animOnEnterFrame) {
             delete this.onEnterFrame;
             this.toggleAnimationButton.setLabel("start animation");
          } else {
             this.onEnterFrame = this.animOnEnterFrame;
             this.timeLast = getTimer();
             this.toggleAnimationButton.setLabel("pause animation");
          }
          this.update();
       }
       animRate  = 0.04;
       linesX    = this.spectrometerMC.linesMC._x;
       linesRange = 20;
       update();

   onEnterFrame becomes one requestAnimationFrame loop and getTimer() becomes
   performance.now(), both in milliseconds, so the rate constant and the
   elapsed-time arithmetic carry over unchanged.
   ========================================================================== */

'use strict';

/* ----- constants, verbatim from the ActionScript ------------------------- */

const ANIM_RATE   = 0.04;                  // animRate: degrees per millisecond
const LINES_RANGE = 20;                    // linesRange: peak line offset, px
const DEG_TO_RAD  = 0.017453292519943295;  // the literal used by update()

/* Registration values read out of the SWF display list (twips / 20 = px).
   linesX is the design-time _x of spectrometerMC.linesMC, which is what the
   original captures into `linesX` on the first frame. */
const LINES_X = 162.45;   // 3249 twips
const LINES_Y = 17.95;    // 359 twips, never changes

/* ----- single source of truth -------------------------------------------- */

const state = {
  rotation: 0,        // bodiesMC._rotation, degrees, 0 .. 360
  running:  false,    // is animOnEnterFrame installed?
  timeLast: 0         // getTimer() value at the previous frame
};

const INITIAL_STATE = Object.freeze({ rotation: 0, running: false });

/* ----- elements ---------------------------------------------------------- */

const el = {
  bodies:      document.getElementById('bodies-group'),
  lines:       document.getElementById('lines-group'),
  toggle:      document.getElementById('toggle-animation'),
  phase:       document.getElementById('phase-range'),
  phaseNumber: document.getElementById('phase-number'),
  status:      document.getElementById('sr-status'),
  stageDesc:   document.getElementById('stage-desc')
};

let rafId          = 0;
let lastSlowAt     = 0;     // throttles the spoken updates while running
let announceTimer  = 0;     // debounces the live region

// While the animation runs, the assistive-technology facing text refreshes a few
// times a second instead of every frame. Left unthrottled, a focused slider would
// chatter its value at sixty frames a second.
const SLOW_UPDATE_MS = 200;

/* ----- derived quantities ------------------------------------------------ */

// update(): the line offset is linesRange * sin(rotation), in stage pixels.
function lineOffset() {
  return Math.sin(state.rotation * DEG_TO_RAD) * LINES_RANGE;
}

// The continuous spectrum runs violet at the left to red at the right, so a
// positive offset carries the absorption lines towards the red end.
function shiftDirection(offset) {
  if (offset >  0.05) { return 'toward the red end of the spectrum'; }
  if (offset < -0.05) { return 'toward the blue end of the spectrum'; }
  return 'at rest positions';
}

// Where a body sitting at position angle `deg` appears, for the spoken
// description. Flash and SVG both measure rotation clockwise with y downwards.
function bearing(deg) {
  const names = ['to the right of', 'below and right of', 'below', 'below and left of',
                 'to the left of', 'above and left of', 'above', 'above and right of'];
  return names[Math.round(((deg % 360) + 360) % 360 / 45) % 8];
}

function phaseDegrees() {
  return Math.round(state.rotation) % 360;
}

/* ----- rendering --------------------------------------------------------- */

// Everything the user sees is written from `state` here, so the diagram, the
// controls and the spoken text can never drift apart.
function render(options) {
  const opts      = options || {};
  const offset    = lineOffset();
  const degrees   = phaseDegrees();
  const dir       = shiftDirection(offset);
  const magnitude = Math.abs(offset).toFixed(1);

  // Diagram: bodiesMC rotates about the centre of mass, linesMC slides.
  el.bodies.setAttribute('transform', 'translate(462, 163) rotate(' + state.rotation + ')');
  el.lines.setAttribute('transform', 'translate(' + (LINES_X + offset) + ', ' + LINES_Y + ')');

  const now = performance.now();
  if (state.running && !opts.force && now - lastSlowAt < SLOW_UPDATE_MS) { return; }
  lastSlowAt = now;

  // Both phase controls, except whichever one the change came from - see the
  // note on `source` by setPhaseFromControl().
  if (opts.source !== 'slider') { el.phase.value       = String(degrees); }
  if (opts.source !== 'number') { el.phaseNumber.value = String(degrees); }

  // Spoken value and diagram description. The size and direction of the shift
  // are not shown on screen, so these carry them.
  el.phase.setAttribute('aria-valuetext', valueText(degrees, magnitude, dir));
  el.stageDesc.textContent = describeStage(degrees, magnitude, dir);
}

function valueText(degrees, magnitude, dir) {
  if (dir === 'at rest positions') {
    return 'Orbital phase ' + degrees + ' degrees, spectral lines at their rest positions';
  }
  return 'Orbital phase ' + degrees + ' degrees, spectral lines shifted '
       + magnitude + ' pixels ' + dir;
}

function describeStage(degrees, magnitude, dir) {
  const lines = dir === 'at rest positions'
    ? 'The absorption lines sit at their rest positions.'
    : 'The absorption lines are shifted ' + magnitude + ' pixels ' + dir + '.';

  return 'Orbital phase ' + degrees + ' degrees. '
       + 'The planet is ' + bearing(degrees) + ' the centre of mass and the star is '
       + bearing(degrees + 180) + ' it. '
       + lines + ' '
       + (state.running ? 'The animation is running.' : 'The animation is paused.');
}

/* ----- keeping typeset maths out of the tab order ------------------------ */
/* The sim currently displays no equations, so this normally finds nothing. It is
   kept because MathJax is still loaded: MathJax v3 puts tabindex="0" on every
   mjx-container when its context menu is enabled, which would land display-only
   maths in the Tab order the moment any is added back. Demoting to tabindex="-1"
   leaves the right-click "Show Math As" menu working while Tab visits only the
   controls a visitor can actually operate. The observer catches containers
   created by the initial page typeset and by every later update. */

function demoteMathTabStops(root) {
  const scope = root || document;
  scope.querySelectorAll('mjx-container[tabindex="0"]')
       .forEach(function (node) { node.setAttribute('tabindex', '-1'); });
}

new MutationObserver(function () { demoteMathTabStops(); })
  .observe(document.body, {
    childList: true, subtree: true,
    attributes: true, attributeFilter: ['tabindex']
  });

/* ----- announcements ----------------------------------------------------- */

// Spoken on commit only - a button press, the end of a slider adjustment, a
// reset - never once per animation frame.
function announce(message, immediate) {
  window.clearTimeout(announceTimer);
  const say = function () { el.status.textContent = message; };
  if (immediate) { say(); } else { announceTimer = window.setTimeout(say, 400); }
}

/* ----- animation --------------------------------------------------------- */

// animOnEnterFrame(): advance by animRate * elapsed milliseconds, wrap at 360.
// The `running` guard is what actually stops the loop. cancelAnimationFrame can
// only cancel the one id we stored, so if a callback is ever already queued when
// the visitor pauses or resets, the loop would otherwise resurrect itself and
// advance the rotation out from under the new state.
function animOnEnterFrame(now) {
  if (!state.running) { rafId = 0; return; }
  state.rotation = (state.rotation + ANIM_RATE * (now - state.timeLast)) % 360;
  state.timeLast = now;
  render();
  rafId = window.requestAnimationFrame(animOnEnterFrame);
}

function startAnimation() {
  if (state.running) { return; }
  state.running  = true;
  state.timeLast = performance.now();          // timeLast = getTimer()
  el.toggle.textContent = 'pause animation';   // setLabel("pause animation")
  rafId = window.requestAnimationFrame(animOnEnterFrame);
  render({ force: true });
}

function stopAnimation() {
  if (!state.running) { return; }
  state.running = false;
  window.cancelAnimationFrame(rafId);
  rafId = 0;
  el.toggle.textContent = 'start animation';   // setLabel("start animation")
  render({ force: true });
}

// toggleAnimation()
function toggleAnimation() {
  if (state.running) { stopAnimation(); } else { startAnimation(); }
  announce(describeStage(phaseDegrees(), Math.abs(lineOffset()).toFixed(1),
                         shiftDirection(lineOffset())), true);
}

/* ----- orbital phase controls -------------------------------------------- */
/* Not present in the Flash original. They are the keyboard and screen-reader
   equivalent of watching the animation: they let a visitor stop on any phase and
   read off the state. Two controls, one value - a typable number field and a
   slider - and every path writes to the same `state`.

   `source` names the control the change came from, so render() leaves that one
   alone: rewriting a field mid-edit would fight the caret, and rewriting the
   slider mid-drag would fight the thumb. */

const PHASE_MIN  = 0;
const PHASE_MAX  = 359;
const PHASE_PAGE = 10;      // Page Up / Page Down step

function clampPhase(degrees) {
  return Math.min(PHASE_MAX, Math.max(PHASE_MIN, Math.round(degrees)));
}

function setPhaseFromControl(degrees, source) {
  // Set the phase first: stopAnimation() renders, and it must not write the
  // outgoing value back into the control the visitor is working.
  state.rotation = clampPhase(degrees);
  stopAnimation();                    // scrubbing takes over from the animation
  render({ source: source, force: true });
}

// Stepping (wheel, Page, Home, End) updates BOTH controls, so no source.
function stepPhaseTo(degrees) {
  setPhaseFromControl(degrees, null);
  announce(el.phase.getAttribute('aria-valuetext'));
}

// Page Up/Down and Home/End on a value field, per the pipeline rules. A native
// <input type="number"> already handles Arrow Up/Down and gives a spinner.
function phaseKeydown(event) {
  let next;
  switch (event.key) {
    case 'PageUp':   next = state.rotation + PHASE_PAGE; break;
    case 'PageDown': next = state.rotation - PHASE_PAGE; break;
    case 'Home':     next = PHASE_MIN; break;
    case 'End':      next = PHASE_MAX; break;
    default: return;
  }
  event.preventDefault();             // and the page does not scroll
  stepPhaseTo(next);
}

// Mouse wheel adjusts a focused value control by one step. Only while it holds
// focus, so the page still scrolls normally everywhere else.
function phaseWheel(event) {
  if (document.activeElement !== event.currentTarget) { return; }
  event.preventDefault();
  stepPhaseTo(state.rotation + (event.deltaY < 0 ? 1 : -1));
}

/* ----- wiring ------------------------------------------------------------ */

el.toggle.addEventListener('click', toggleAnimation);

/* --- the slider --- */

el.phase.addEventListener('input', function () {
  setPhaseFromControl(Number(el.phase.value), 'slider');
});

el.phase.addEventListener('change', function () {
  announce(el.phase.getAttribute('aria-valuetext'));
});

el.phase.addEventListener('wheel', phaseWheel, { passive: false });

/* --- the typable number field --- */

// Track every keystroke so the diagram follows as the visitor types, but only
// once what is in the box is actually a number: part-typed text like "" or "-"
// is left alone rather than snapped to a value.
el.phaseNumber.addEventListener('input', function () {
  const typed = el.phaseNumber.value.trim();
  if (!/^\d+$/.test(typed)) { return; }
  setPhaseFromControl(Number(typed), 'number');
});

// On commit, normalise whatever survived typing so the box can never disagree
// with the diagram. Out-of-range values clamp; an empty box (which is also what
// the element reports for unparseable text) reverts to the current phase rather
// than snapping the star to zero, so clearing the field and clicking away is not
// a destructive edit.
el.phaseNumber.addEventListener('change', function () {
  const raw     = el.phaseNumber.value.trim();
  const typed   = Number(raw);
  const settled = clampPhase(raw !== '' && isFinite(typed) ? typed : state.rotation);
  el.phaseNumber.value = String(settled);
  setPhaseFromControl(settled, 'number');
  announce(el.phase.getAttribute('aria-valuetext'));
});

// Leaving a half-finished edit behind should not strand a stale box either.
el.phaseNumber.addEventListener('blur', function () {
  el.phaseNumber.value = String(phaseDegrees());
});

el.phaseNumber.addEventListener('keydown', phaseKeydown);
el.phaseNumber.addEventListener('wheel', phaseWheel, { passive: false });

// The slider gets Page/Home/End natively; it only needs the same wheel support,
// wired above.

// Reset comes from the shared masthead; the sim never draws its own button.
document.addEventListener('sim-reset', function () {
  stopAnimation();
  state.rotation = INITIAL_STATE.rotation;
  state.timeLast = 0;
  el.toggle.textContent = 'start animation';
  render({ force: true });
  announce('Simulation reset. ' + describeStage(0, '0.0', shiftDirection(0)), true);
});

/* ----- start-up ---------------------------------------------------------- */

// kl-unl.js calls klunlInitEqn() on load; redefining it here is how a sim hooks
// its own initialisation into the foundation.
function klunlInitEqn() {
  render({ force: true });
  demoteMathTabStops();
}

window.addEventListener('load', klunlInitEqn);

if (window.MathJax && MathJax.startup && MathJax.startup.promise) {
  MathJax.startup.promise.then(function () { demoteMathTabStops(); });
}

// The diagram must be correct even before MathJax finishes loading, so draw the
// opening state now. This is the original's trailing `update()` call.
render({ force: true });
