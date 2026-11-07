/* ==========================================================================
   Sun's Position on Horizon -- HTML5 port of horizon.swf (ActionScript 1)

   Behaviour is a direct translation of the decompiled `sun_Gradient.as`
   (registered as the class `horizonClass` on the "sun_Gradient" symbol) plus
   the main-timeline frame script. Constants, the month table, the date-array
   rotation, the offset formula and the shadow-frame formula are all verbatim.

   Presentation is rebuilt on the KL-UNL foundation: the artwork is the set of
   vector shapes exported by JPEXS, reused as-is (see assets/scene-data.js),
   and every control is a native, labelled HTML element.
   ========================================================================== */

import {
  SCENE, SHADOW_MATS, SUN, SHAPE_DEFS, DATE_OFFSET, FILTERS,
} from "./assets/scene-data.js";

/* --------------------------------------------------------------------------
   Constants -- verbatim from the AS source
   --------------------------------------------------------------------------
   `_range` and `_speed` come from the on(initialize) clip event attached to
   the sun_Gradient instance on frame 1 of the main timeline:
       _anim = false;  _range = 350;  _speed = 0.025;
   -------------------------------------------------------------------------- */
const RANGE = 350;        // horizontal half-travel of the sun, in stage units
const SPEED = 0.025;      // days advanced per millisecond of elapsed time
const YEAR  = 365;        // _day wraps here (note: dateArray holds 366 entries)

// monthArray, exactly as pushed in sun_Gradient.as. February is 29 days and
// September is 30 in the original table; kept as authored so that every date
// label matches the Flash version day for day.
const MONTH_TABLE = [
  { month: "January",   days: 31 },
  { month: "February",  days: 29 },
  { month: "March",     days: 31 },
  { month: "April",     days: 30 },
  { month: "May",       days: 31 },
  { month: "June",      days: 30 },
  { month: "July",      days: 31 },
  { month: "August",    days: 31 },
  { month: "September", days: 30 },
  { month: "October",   days: 31 },
  { month: "November",  days: 30 },
  { month: "December",  days: 31 },
];

// dateArray: every "Month D" string, then rotated left 80 places so that
// index 0 is "March 21" -- the vernal equinox, where the offset is zero.
const DATE_ARRAY = [];
for (const m of MONTH_TABLE) {
  for (let j = 0; j < m.days; j++) DATE_ARRAY.push(`${m.month} ${j + 1}`);
}
for (let i = 0; i < 80; i++) DATE_ARRAY.push(DATE_ARRAY.shift());

const VIEW_SUNRISE = 0;
const VIEW_SUNSET  = 1;

/* --------------------------------------------------------------------------
   Physics
   -------------------------------------------------------------------------- */

// p.getOffsetAt: Math.sin(dayNum / 365 * 360 * Math.PI / 180)
// i.e. sin(2*pi*day/365) -- one full cycle per year, zero at the equinoxes.
function getOffsetAt(dayNum) {
  return Math.sin(((dayNum / YEAR) * 360 * Math.PI) / 180);
}

/* --------------------------------------------------------------------------
   State -- the single source of truth
   -------------------------------------------------------------------------- */
const state = {
  day:       0,          // _day
  view:      VIEW_SUNRISE,
  animating: false,      // _anim
};

let lastTime  = 0;       // _oldTime
let rafId     = null;
let lastSpoken = 0;
let builtView = null;

/* --------------------------------------------------------------------------
   DOM handles
   -------------------------------------------------------------------------- */
const el = {
  stage:       document.getElementById("stage"),
  defs:        document.getElementById("shapeDefs"),
  sky:         document.getElementById("layerSky"),
  sun:         document.getElementById("layerSun"),
  sunGlow:     document.getElementById("sunGlow"),
  ground:      document.getElementById("layerGround"),
  shadows:     document.getElementById("layerShadows"),
  fg:          document.getElementById("layerFg"),
  dateMonth:   document.getElementById("dateMonth"),
  dateDay:     document.getElementById("dateDay"),
  labelCentre: document.getElementById("labelCentre"),
  labelLeft:   document.getElementById("labelLeft"),
  labelRight:  document.getElementById("labelRight"),
  stageTitle:  document.getElementById("stageTitle"),
  stageDesc:   document.getElementById("stageDesc"),
  caption:     document.getElementById("viewCaption"),
  slider:      document.getElementById("dateSlider"),
  readout:     document.getElementById("dateReadout"),
  monthSelect: document.getElementById("monthSelect"),
  dayInput:    document.getElementById("dayInput"),
  playBtn:     document.getElementById("playBtn"),
  radios:      Array.from(document.querySelectorAll('input[name="view"]')),
  status:      document.getElementById("srStatus"),
};

const SVG_NS = "http://www.w3.org/2000/svg";
const reducedMotion = window.matchMedia("(prefers-reduced-motion: reduce)");

/* --------------------------------------------------------------------------
   Scene construction

   Each entry in SCENE is an ordered display list taken from the SWF's
   PlaceObject2 tags, so drawing them in array order reproduces the original
   depth ordering exactly.
   -------------------------------------------------------------------------- */

function matrixOf(m) {
  return `matrix(${m.join(" ")})`;
}

function useShape(shapeId, matrix, filterIndex) {
  const node = document.createElementNS(SVG_NS, "use");
  node.setAttribute("href", `#sh${shapeId}`);
  if (matrix) node.setAttribute("transform", matrixOf(matrix));
  if (filterIndex !== undefined) node.setAttribute("filter", `url(#cx${filterIndex})`);
  return node;
}

function fillLayer(layer, placements) {
  layer.replaceChildren(...placements.map((p) => useShape(p.sh, p.m, p.f)));
}

/* Flash colour transforms become feColorMatrix filters.

   A CXFORM is  out = clamp(in * mult / 256 + add), which maps directly onto a
   colour matrix whose diagonal holds the multipliers and whose fifth column
   holds the offsets. These are what render the landscape as dark silhouettes
   and draw the direction arrows at half opacity -- without them the artwork
   shows through in its full authoring colours.

   color-interpolation-filters="sRGB" is required: the SVG default is linearRGB,
   which would darken the result differently from Flash. */
function buildFilters() {
  const markup = FILTERS.map((cx, i) => {
    const [mr, mg, mb, ma, ar, ag, ab, aa] = cx;
    const values = [
      mr / 256, 0, 0, 0, ar / 255,
      0, mg / 256, 0, 0, ag / 255,
      0, 0, mb / 256, 0, ab / 255,
      0, 0, 0, ma / 256, aa / 255,
    ].join(" ");
    return `<filter id="cx${i}" color-interpolation-filters="sRGB">` +
           `<feColorMatrix type="matrix" values="${values}"/></filter>`;
  }).join("");

  el.defs.insertAdjacentHTML("beforeend", markup);
}

// Text positions, in stage units, derived from the DefineText / DefineEditText
// records in the SWF (glyph advance centres and baselines).
const LABEL_LAYOUT = {
  centre: {
    [VIEW_SUNRISE]: { text: "East", x: -2.75,  y: -178.25 },
    [VIEW_SUNSET]:  { text: "West", x: -5.425, y: -178.25 },
  },
  side: { leftX: -369.55, rightX: 370.45, y1: -195.25, y2: -173.25 },
};

function setSideLabel(node, x, second) {
  node.setAttribute("text-anchor", "middle");
  node.replaceChildren();
  for (const [line, y] of [["To", LABEL_LAYOUT.side.y1], [second, LABEL_LAYOUT.side.y2]]) {
    const tspan = document.createElementNS(SVG_NS, "tspan");
    tspan.setAttribute("x", x);
    tspan.setAttribute("y", y);
    tspan.textContent = line;
    node.appendChild(tspan);
  }
}

function buildScene(view) {
  const scene = SCENE[view];

  fillLayer(el.sky, scene.sky);
  fillLayer(el.ground, scene.ground);
  fillLayer(el.fg, scene.fg);

  // Shadow clips: an outer group carrying the clip's own placement matrix,
  // wrapping the shape whose matrix is swapped per animation frame.
  el.shadows.replaceChildren(
    ...scene.shadows.map((s) => {
      const group = document.createElementNS(SVG_NS, "g");
      group.setAttribute("transform", matrixOf(s.m));
      if (s.f !== undefined) group.setAttribute("filter", `url(#cx${s.f})`);
      group.dataset.sprite = s.spr;
      group.appendChild(useShape(s.sh, null));
      return group;
    })
  );

  el.sunGlow.setAttribute("href", `#sh${SUN[view]}`);

  const centre = LABEL_LAYOUT.centre[view];
  el.labelCentre.setAttribute("text-anchor", "middle");
  el.labelCentre.setAttribute("x", centre.x);
  el.labelCentre.setAttribute("y", centre.y);
  el.labelCentre.textContent = centre.text;

  // At sunrise you face east, so north is on your left; at sunset you face
  // west and north moves to your right. The SWF swaps these two DefineTexts
  // between its two frames for exactly this reason.
  const { leftX, rightX } = LABEL_LAYOUT.side;
  setSideLabel(el.labelLeft, leftX, view === VIEW_SUNRISE ? "North" : "South");
  setSideLabel(el.labelRight, rightX, view === VIEW_SUNRISE ? "South" : "North");

  builtView = view;
}

/* --------------------------------------------------------------------------
   Render -- everything on screen is derived from `state` here, once.
   This is the direct equivalent of p.moveSunTo() plus the DOM/ARIA sync.
   -------------------------------------------------------------------------- */

// dateArray lookup, guarded so a rounding edge can never index off the end.
function dateAt(day) {
  const i = Math.floor(day);
  return DATE_ARRAY[Math.min(Math.max(i, 0), DATE_ARRAY.length - 1)];
}

function daysInMonth(monthName) {
  const entry = MONTH_TABLE.find((m) => m.month === monthName);
  return entry ? entry.days : 31;
}

// "March 21" -> its position in DATE_ARRAY. Looking the label up in the same
// array the simulation renders from means the typed date and the displayed
// date can never drift apart.
function dayFromDate(monthName, dayNumber) {
  return DATE_ARRAY.indexOf(`${monthName} ${dayNumber}`);
}

function describePosition(view, offset) {
  const percent = Math.round(Math.abs(offset) * 100);
  const facing  = view === VIEW_SUNRISE ? "east" : "west";
  const verb    = view === VIEW_SUNRISE ? "rises" : "sets";

  if (percent === 0) return `The sun ${verb} due ${facing}.`;

  // sin > 0 puts the sun toward the northern end of the horizon in both views.
  const end = offset > 0 ? "north" : "south";
  return `The sun ${verb} ${percent} percent of the way from due ${facing} ` +
         `toward the ${end} end of the horizon.`;
}

function render() {
  if (builtView !== state.view) buildScene(state.view);

  const dateText = dateAt(state.day);
  const [month, dayNumber] = dateText.split(" ");

  // --- p.moveSunTo ------------------------------------------------------
  let offset = getOffsetAt(state.day);
  if (state.view === VIEW_SUNRISE) offset *= -1;

  el.sun.setAttribute("transform", `translate(${RANGE * offset} 0)`);

  if (state.view === VIEW_SUNSET) offset *= -1;

  // shadowFrame = 184 - Math.floor(offset * 91), clamped into the 1..366
  // range of the authored shadow clips. offset is a sine, so this always
  // lands between 93 and 275; the AS wrap-around branch is unreachable.
  let shadowFrame = 184 - Math.floor(offset * 91);
  if (shadowFrame < 0) shadowFrame += 183;

  for (const group of el.shadows.children) {
    const mats = SHADOW_MATS[group.dataset.sprite];
    const mat  = mats[Math.min(Math.max(shadowFrame - 1, 0), mats.length - 1)];
    group.firstChild.setAttribute("transform", matrixOf(mat));
  }

  // The date field lives inside the sun clip, so it travels with the sun.
  el.dateMonth.textContent = month;
  el.dateDay.textContent   = dayNumber;

  // --- DOM + ARIA sync --------------------------------------------------
  const period = state.view === VIEW_SUNRISE ? "sunrise" : "sunset";
  el.caption.textContent = `Position of the sun on the horizon at ${period}`;

  const dayIndex = Math.floor(state.day);
  if (el.slider.value !== String(dayIndex)) el.slider.value = String(dayIndex);
  el.slider.setAttribute(
    "aria-valuetext",
    `${dateText}, day ${dayIndex + 1} of ${DATE_ARRAY.length}`
  );
  el.readout.textContent = dateText;

  // Don't overwrite a field while it is being typed into.
  if (document.activeElement !== el.monthSelect) el.monthSelect.value = month;
  el.dayInput.max = String(daysInMonth(month));
  if (document.activeElement !== el.dayInput) el.dayInput.value = dayNumber;

  el.playBtn.textContent = state.animating ? "Pause" : "Play";

  el.stageTitle.textContent =
    state.view === VIEW_SUNRISE
      ? "Sunrise view toward the eastern horizon"
      : "Sunset view toward the western horizon";
  el.stageDesc.textContent =
    `${dateText}. ${describePosition(state.view, getOffsetAt(state.day))}`;
}

function announce(message) {
  el.status.textContent = message;
}

function currentSentence() {
  const dateText = dateAt(state.day);
  return `${dateText}. ${describePosition(state.view, getOffsetAt(state.day))}`;
}

/* --------------------------------------------------------------------------
   Animation -- p.onEnterFrame

   The original integrates elapsed wall-clock time (getTimer()), not frame
   counts, so the year takes the same 14.6 s regardless of frame rate. Sampling
   less often under prefers-reduced-motion therefore does not change which date
   is shown at any given instant.
   -------------------------------------------------------------------------- */

// One full year of elapsed time. Flash ran onEnterFrame continuously, so its
// single `_day -= 365` wrap was always enough; a browser can hand us a much
// larger gap (a backgrounded tab stops rAF entirely), which would push _day
// past the end of dateArray. Clamping the step keeps the original wrap exact.
const MAX_STEP_MS = YEAR / SPEED;

function tick(now) {
  if (!state.animating) return;

  const elapsed = Math.min(now - lastTime, MAX_STEP_MS);
  const minStep = reducedMotion.matches ? 250 : 0;

  if (elapsed >= minStep) {
    state.day += SPEED * elapsed;
    if (state.day > YEAR) state.day -= YEAR;
    lastTime = now;
    render();

    if (now - lastSpoken > 2000) {
      lastSpoken = now;
      announce(currentSentence());
    }
  }

  rafId = requestAnimationFrame(tick);
}

// p.setAnimate
function setAnimate(on) {
  const next = Boolean(on);
  if (next === state.animating) return;

  state.animating = next;

  if (next) {
    lastTime   = performance.now();
    lastSpoken = lastTime;
    rafId      = requestAnimationFrame(tick);
    announce("Animation playing.");
  } else {
    if (rafId !== null) cancelAnimationFrame(rafId);
    rafId = null;
    announce(`Animation paused. ${currentSentence()}`);
  }

  render();
}

// p.setType
function setType(view) {
  state.view = view === VIEW_SUNSET ? VIEW_SUNSET : VIEW_SUNRISE;
  render();
}

// p.setDay
function setDay(day) {
  state.day = day;
  render();
}

/* --------------------------------------------------------------------------
   Controls
   -------------------------------------------------------------------------- */

el.playBtn.addEventListener("click", () => setAnimate(!state.animating));

for (const radio of el.radios) {
  radio.addEventListener("change", () => {
    if (!radio.checked) return;
    setType(Number(radio.value));
    announce(currentSentence());
  });
}

// The date slider is an accessibility addition: it drives the same setDay()
// entry point the AS class already exposed but never wired to a control.
el.slider.addEventListener("input", () => {
  setAnimate(false);
  setDay(Number(el.slider.value));
});

el.slider.addEventListener("change", () => announce(currentSentence()));

// Mouse wheel adjusts the focused slider, matching the arrow-key step.
el.slider.addEventListener(
  "wheel",
  (event) => {
    if (document.activeElement !== el.slider) return;
    event.preventDefault();

    const step  = event.deltaY < 0 ? 1 : -1;
    const value = Math.min(YEAR, Math.max(0, Math.floor(state.day) + step));

    setAnimate(false);
    setDay(value);
    announce(currentSentence());
  },
  { passive: false }
);

/* --- manual date entry ------------------------------------------------- */

// Commit whatever the month/day fields currently hold, clamping the day to the
// selected month's length (switching from "January 31" to February has to land
// somewhere real).
function commitDateFields({ announceChange = true } = {}) {
  const month = el.monthSelect.value;
  const max   = daysInMonth(month);

  let dayNumber = parseInt(el.dayInput.value, 10);
  if (!Number.isFinite(dayNumber)) dayNumber = 1;
  dayNumber = Math.min(Math.max(dayNumber, 1), max);

  const day = dayFromDate(month, dayNumber);
  if (day < 0) return;                 // not a date this simulation knows

  setAnimate(false);
  setDay(day);

  // render() leaves a focused field alone, so put the clamped value back here.
  if (String(dayNumber) !== el.dayInput.value) el.dayInput.value = String(dayNumber);

  if (announceChange) announce(currentSentence());
}

el.monthSelect.addEventListener("change", () => commitDateFields());
el.dayInput.addEventListener("change", () => commitDateFields());

// Page Up/Down and Home/End are not native to number inputs; add them so the
// day field behaves like every other numeric control in the sim.
el.dayInput.addEventListener("keydown", (event) => {
  const max = daysInMonth(el.monthSelect.value);
  const current = parseInt(el.dayInput.value, 10) || 1;
  let next;

  if (event.key === "PageUp") next = current + 10;
  else if (event.key === "PageDown") next = current - 10;
  else if (event.key === "Home") next = 1;
  else if (event.key === "End") next = max;
  else return;

  event.preventDefault();
  el.dayInput.value = String(Math.min(Math.max(next, 1), max));
  commitDateFields();
});

el.dayInput.addEventListener(
  "wheel",
  (event) => {
    if (document.activeElement !== el.dayInput) return;
    event.preventDefault();

    const max = daysInMonth(el.monthSelect.value);
    const current = parseInt(el.dayInput.value, 10) || 1;
    const next = current + (event.deltaY < 0 ? 1 : -1);

    el.dayInput.value = String(Math.min(Math.max(next, 1), max));
    commitDateFields();
  },
  { passive: false }
);

// Browsers suspend requestAnimationFrame while a tab is hidden. Restart the
// clock on return so the year picks up where the reader left it instead of
// leaping forward by however long the tab sat in the background.
document.addEventListener("visibilitychange", () => {
  if (!document.hidden && state.animating) {
    lastTime   = performance.now();
    lastSpoken = lastTime;
    if (rafId === null) rafId = requestAnimationFrame(tick);
  }
});

// Reset comes from the KL-UNL masthead component, not a button of our own.
document.addEventListener("sim-reset", () => {
  setAnimate(false);
  state.day  = 0;
  state.view = VIEW_SUNRISE;

  el.radios[0].checked = true;
  el.radios[1].checked = false;

  render();
  announce(`Simulation reset. ${currentSentence()}`);
});

/* --------------------------------------------------------------------------
   Start-up
   -------------------------------------------------------------------------- */

let started = false;

function init() {
  if (started) return;   // kl-unl.js and DOMContentLoaded can both land here
  started = true;

  // Inject the exported shape library and the colour-transform filters once.
  el.defs.innerHTML = SHAPE_DEFS;
  buildFilters();

  // Month options come from the simulation's own table, not a second list.
  el.monthSelect.replaceChildren(
    ...MONTH_TABLE.map((m) => new Option(m.month, m.month))
  );

  // The date label's position inside the sun clip, from the SWF placements.
  el.dateMonth.setAttribute("y", DATE_OFFSET[1] + 17);
  el.dateDay.setAttribute("y", DATE_OFFSET[1] + 37);

  buildScene(state.view);

  // The authored first frame showed a stale placeholder date ("September 21")
  // that did not match _day = 0. Rendering from state on load makes the date,
  // the sun and the shadows mutually consistent -- see CONVERSION_NOTES.md.
  render();
}

// kl-unl.js calls klunlInitEqn() on load and expects the sim to redefine it.
// This simulation displays no equations, so it is used purely to initialise.
window.klunlInitEqn = init;

if (document.readyState === "loading") {
  document.addEventListener("DOMContentLoaded", init, { once: true });
} else {
  init();
}
