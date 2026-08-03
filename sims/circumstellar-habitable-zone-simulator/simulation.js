/* =============================================================================
   Circumstellar Habitable Zone Simulator - all simulation logic.

   BEHAVIOUR (Goal A) is a faithful port of the decompiled ActionScript
   (MainTimeline, SHZDiagram*, SHZTimeline, SHZHabitabilityPlot, SHZSystemHistory,
   SHZHRDiagram, ProtoSliderLogic). Every physics constant, table, formula and
   piece of on-screen text is copied verbatim from that source; the stellar
   evolution tracks come from shzStars.dat (decoded to assets/shzStars.json).

   PRESENTATION (Goal B) follows the KL-UNL foundation + WCAG 2.1 AA: native
   accessible controls, canvas only for the code-drawn stage art, MathJax for
   every symbol/unit, full keyboard operation with units spoken, a single
   render() from one state object, and reset via the masthead "sim-reset" event.

   Original internal stage coordinates are preserved exactly; the drawing/physics
   math never sees the on-screen (CSS-scaled) size.
   ============================================================================= */
(function () {
  'use strict';

  /* ---------------------------------------------------------------------------
     0. Small math helpers
     --------------------------------------------------------------------------- */
  var LN10 = Math.LN10;
  function log10(x) { return Math.log(x) / LN10; }
  function pow10(x) { return Math.pow(10, x); }
  function clamp(v, lo, hi) { return v < lo ? lo : (v > hi ? hi : v); }

  /* ---------------------------------------------------------------------------
     1. Constants copied verbatim from the ActionScript (MainTimeline frame1 +
        member consts, SHZDiagram, SHZTimeline geometry).
     --------------------------------------------------------------------------- */
  // Habitable-zone limit assumptions (fraction of the equal-flux distance).
  var OPT_INNER = 0.8,  OPT_OUTER = 1.5;    // optimisticInner/OuterSHZLimit
  var PES_INNER = 0.95, PES_OUTER = 1.37;   // pessimisticInner/OuterSHZLimit

  var MIN_DIST_T0 = 0.01;      // minPlanetDistanceAtTimeZero
  var MAX_DIST_T0 = 500;       // maxPlanetDistanceAtTimeZero
  var DEFAULT_DIST = 1;        // defaultDistance
  var DEFAULT_MASS = 1;        // defaultStarMass
  var MIN_PLANET_DISTANCE = 1.5; // minPlanetDistance (Roche floor, stellar radii)

  // Reference solar-system orbits (a in AU, e, label). ma is unused (mean anomaly).
  var SOLAR_SYSTEM = [
    { e: 0, a: 0.387, label: 'Mercury' },
    { e: 0, a: 0.723, label: 'Venus' },
    { e: 0, a: 1,     label: 'Earth' },
    { e: 0, a: 1.524, label: 'Mars' },
    { e: 0, a: 5.203, label: 'Jupiter' },
    { e: 0, a: 9.54,  label: 'Saturn' },
    { e: 0, a: 19.18, label: 'Uranus' },
    { e: 0, a: 30.06, label: 'Neptune' },
    { e: 0, a: 39.44, label: 'Pluto' }
  ];

  // Known planetary systems (name, host mass in Msun, planets with label,e,a).
  var SYSTEMS = [
    { name: '(none selected)', mass: 0, planetsList: [] },
    { name: 'Gliese 581', mass: 0.31, planetsList: [
      { label: 'e', e: 0,    a: 0.03 }, { label: 'b', e: 0,    a: 0.041 },
      { label: 'c', e: 0.16, a: 0.073 }, { label: 'd', e: 0.2, a: 0.22 } ] },
    { name: '55 Cancri A', mass: 0.95, planetsList: [
      { label: 'e', e: 0.2637, a: 0.038 }, { label: 'b', e: 0.0159, a: 0.115 },
      { label: 'c', e: 0.053,  a: 0.241 }, { label: 'f', e: 0.0002, a: 0.785 },
      { label: 'd', e: 0.0633, a: 5.901 } ] },
    { name: '51 Pegasi', mass: 1.06, planetsList: [ { label: 'b', e: 0, a: 0.052 } ] },
    { name: 'HD 40307', mass: 0.75, planetsList: [
      { label: 'c', e: 0, a: 0.081 }, { label: 'd', e: 0, a: 0.134 },
      { label: 'b', e: 0, a: 0.47 } ] },
    { name: 'HD 189733', mass: 0.8, planetsList: [ { label: 'b', e: 0, a: 0.03099 } ] },
    { name: 'HD 93083', mass: 0.7, planetsList: [ { label: 'b', e: 0.14, a: 0.477 } ] }
  ];

  // Diagram (SHZDiagram(966,250)) geometry.
  var DIAG_W = 966, DIAG_H = 250, STAR_X = 130;
  var SAFE_RADIUS = 1.1 * Math.sqrt(DIAG_H * DIAG_H / 4 + DIAG_W * DIAG_W);
  var PLANET_DRAG_MIN_X = STAR_X + 135;              // starX + planetDragLeftXHardMargin
  var PLANET_DRAG_MAX_X = DIAG_W - 30;               // w - planetDragRightXHardMargin
  var PLANET_ZOOM_MIN_X = PLANET_DRAG_MIN_X + 0.15 * (PLANET_DRAG_MAX_X - PLANET_DRAG_MIN_X);
  var PLANET_ZOOM_MAX_X = PLANET_DRAG_MIN_X + (1 - 0.35) * (PLANET_DRAG_MAX_X - PLANET_DRAG_MIN_X);
  var PLANET_DRAG_MIN_DIST_HARD = 0.01, PLANET_DRAG_MAX_DIST_HARD = 300; // hard clamp in processMouse
  var ZOOMER_FACTOR = 1.3, MIN_ZOOM_SCALE = 0.25, MAX_ZOOM_SCALE = 25000, ZOOM_DEAD = 95;
  var AU_PER_SOLAR_RADIUS = 0.00465, STAR_MIN_DISC = 1.2;
  var EASING_TIME = 500; // ms

  // Star colour (getColorFromTemp) working range.
  var ln1000 = Math.log(1000), ln40000 = Math.log(40000);

  // Timeline geometry (SHZTimeline(870)).
  var TL_WIDTH = 870, TL_HEIGHT = 6;
  // Habitability plot (SHZHabitabilityPlot(width,50)).
  var PLOT_W = 870, PLOT_H = 50, SHADING_EXTENT = 5;
  // System history (SHZSystemHistory(width,5)).
  var HIST_W = 870, HIST_H = 5;

  // HR diagram (SHZHRDiagram) axis ranges + geometry.
  var HR_W = 130, HR_H = 140;
  var HR_MIN_LOGT = log10(2500), HR_MAX_LOGT = log10(50000);
  var HR_MIN_LOGL = -4, HR_MAX_LOGL = 7;

  // Art colours from the AS (kept because pedagogically meaningful; never the
  // ONLY signal - each is paired with text). Given as canvas CSS strings.
  var C_ZONE = 'rgba(96,128,208,0.5)';        // fill 6324432 @ 0.5
  var C_ORBIT = '#909090';                    // refOrbit line 9474192
  var C_ORBIT_HL = '#ffcc00';                 // starSystem highlight 16763904
  var C_ORBIT_STAR = '#b08000';               // starSystem line 11567104
  var C_GRID = '#e0e0e0';                     // grid 14737632
  var C_HR_MAINSEQ = '#b8b8b8';               // 12105912
  var C_HR_TRACK = '#ff8a50';                 // 16748688
  var C_HR_DOT = '#e03030';                   // 14692400
  var C_PLOT_CURVE = '#505050';               // 5263440
  var C_PLOT_HOT = '250,210,172';             // hotColor 16437932 (rgb)
  var C_PLOT_COLD = '156,173,235';            // coldColor 10268139 (rgb)
  var C_PLOT_BORDER = '#e0e0e0';              // 14737632
  var C_CURSOR = 'rgba(224,48,48,0.5)';       // 14692400 @ 0.5
  var C_HIST_COLD = 'rgba(156,173,235,0.3)';  // state -1
  var C_HIST_JUST = 'rgba(96,128,208,0.9)';   // state 0
  var C_HIST_HOT  = 'rgba(250,210,172,0.3)';  // state +1
  var C_HIST_DEAD = '#a0a0a0';                // 10526880

  /* ---------------------------------------------------------------------------
     2. MathJax helper. Every mathematical symbol in the UI (M_sun, L_sun,
        R_sun, K, AU, the My/Gy time scale) is typeset by MathJax so that right-
        clicking it opens the MathJax menu. A plain-text fallback is written
        immediately and the typeset is debounced, so a fast drag that rewrites a
        readout every frame cannot thrash MathJax. dataset.rendered records what
        each node is typeset to, so unchanged values are skipped.
     --------------------------------------------------------------------------- */
  var mjPending = new Map(), mjTimer = null, mjBusy = false;
  function mjReady() { return !!(window.MathJax && window.MathJax.typesetPromise); }
  function setMath(el, latex, fallback) {
    if (!el) return;
    if (el.dataset.rendered === latex && !mjPending.has(el)) return;
    // Fallback shown until MathJax typesets. Set as HTML (strings are all
    // sim-generated, never user input) so a solar unit's fallback can carry a
    // real <sub> and match the typeset subscript, instead of flashing an inline
    // glyph while a slider is dragged.
    el.innerHTML = fallback;
    el.dataset.rendered = '';
    mjPending.set(el, latex);
    scheduleMathFlush();
  }
  // Debounced: reset the timer on every update so a fast drag (many updates per
  // second) coalesces into ONE typeset when it pauses, instead of flashing the
  // plain-text fallback / raw LaTeX on every frame. The fallback is the same
  // sans-serif symbol form as the typeset output, so the brief pre-typeset text
  // is visually indistinguishable.
  function scheduleMathFlush() { if (mjTimer) clearTimeout(mjTimer); mjTimer = setTimeout(flushMath, 110); }
  function flushMath() {
    mjTimer = null;
    if (!mjReady() || mjBusy || mjPending.size === 0) { if (mjPending.size) scheduleMathFlush(); return; }
    var batch = [];
    mjPending.forEach(function (latex, el) { el.textContent = '\\(' + latex + '\\)'; batch.push([el, latex]); });
    mjPending.clear();
    mjBusy = true;
    window.MathJax.typesetPromise(batch.map(function (b) { return b[0]; }))
      .then(function () {
        batch.forEach(function (p) {
          p[0].dataset.rendered = p[1];
          var c = p[0].querySelector('mjx-container'); // keep typeset math out of the Tab order
          if (c) c.setAttribute('tabindex', '-1');
        });
      })
      .catch(function () {})
      .finally(function () { mjBusy = false; if (mjPending.size) scheduleMathFlush(); });
  }
  if (window.MathJax) {
    var prevReady = window.MathJax.startup && window.MathJax.startup.ready;
    window.MathJax.startup = window.MathJax.startup || {};
    window.MathJax.startup.ready = function () {
      if (window.MathJax.startup.defaultReady) window.MathJax.startup.defaultReady();
      if (prevReady) { try { prevReady(); } catch (e) {} }
      scheduleMathFlush();
    };
  }
  window.klunlInitEqn = function () { scheduleMathFlush(); };

  /* ---------------------------------------------------------------------------
     3. Number formatting, copied from the AS.
     --------------------------------------------------------------------------- */
  // MainTimeline.getNumberString: round to `sig` significant figures.
  function getNumberString(v, sig) {
    var e = Math.floor(log10(v)) - (sig - 1);
    if (e >= 0) { var f = pow10(e); return String(f * Math.round(v / f)); }
    return v.toFixed(-e);
  }
  // ProtoSliderLogic significant-digits value string (used for the slider fields).
  function sigDigitString(v, digs) {
    if (!isFinite(v) || v <= 0) return String(v);
    var mag = Math.floor(log10(v));
    var lower = pow10(digs - 1);
    var sig = Math.round(v * lower / pow10(mag));
    if (sig >= pow10(digs)) { sig = lower; mag++; }
    var val = sig / lower * pow10(mag);
    var places = digs - mag - 1;
    return places > 0 ? val.toFixed(places) : String(Math.round(val));
  }
  // SHZTimeline.getFormattedNumber.
  function getFormattedNumber(v, p) {
    if (p >= 0) { var f = pow10(p); return String(f * Math.round(v / f)); }
    return v.toFixed(-p);
  }
  // SHZTimeline.getTimeString, guarded for t<=0 (log(0) is -Infinity in the AS).
  function timeParts(t) {
    if (!(t > 0)) return { num: '0', unit: 'My', spoken: 'megayears' };
    var mag = Math.floor(log10(t));
    if (mag >= 3) return { num: getFormattedNumber(t / 1000, mag - 3 - 2), unit: 'Gy', spoken: 'gigayears' };
    return { num: getFormattedNumber(t, mag - 2), unit: 'My', spoken: 'megayears' };
  }

  /* ---------------------------------------------------------------------------
     4. Single state object - the one source of truth. render() redraws
        everything from it after every action.
     --------------------------------------------------------------------------- */
  var state = {
    starsList: null,
    masses: [],            // sorted list of the available track masses
    selectedStar: null,    // one of starsList (nearest track to the mass slider)
    selectedSystem: null,  // a SYSTEMS entry, or null
    innerSHZLimit: 1, outerSHZLimit: 2,
    initStarMass: DEFAULT_MASS,  // slider value (a track mass)
    initDistance: DEFAULT_DIST,  // slider value (AU at time zero-ish)
    distFinite: null,      // sorted perihelion set when a system is selected, else null
    time: 0,               // timeline time (My)
    scale: 353,            // diagram scale (px per AU)
    scaleTarget: 353, scaleAnimStart: 0, scaleAnimFrom: 353, scaleAnimating: false,
    planetDragging: false, dragDistance: 1,
    running: false, runSpeed: 12, runLast: 0,
    showGrid: false, showRefOrbits: true,
    timePlanetDestroyed: Infinity, timePlanetTidallyLocked: Infinity,
    statesList: [],
    // cached derived star-system reference orbits (for the diagram)
    starOrbits: [], highlightOrbit: -1,
    zoneVisible: true, starVisible: true
  };

  /* ---------------------------------------------------------------------------
     5. Data-table maths, copied from MainTimeline.
     --------------------------------------------------------------------------- */
  // getData: interpolate the star's evolution track at time t (clamped).
  function getData(t) {
    var tab = state.selectedStar.dataTable;
    if (t < 0) t = 0; else if (t > state.selectedStar.timespan) t = state.selectedStar.timespan;
    var i = 1;
    while (i < tab.length) { if (t < tab[i].time) break; i++; }
    if (i >= tab.length) i = tab.length - 1;
    var a = tab[i - 1], b = tab[i];
    var u = (t - a.time) / (b.time - a.time);
    return {
      time: t,
      mass: a.mass + u * (b.mass - a.mass),
      logRadius: a.logRadius + u * (b.logRadius - a.logRadius),
      logTemp: a.logTemp + u * (b.logTemp - a.logTemp),
      logLum: a.logLum + u * (b.logLum - a.logLum),
      shzInner: a.shzInner + u * (b.shzInner - a.shzInner),
      shzOuter: a.shzOuter + u * (b.shzOuter - a.shzOuter),
      shzTemp: a.shzTemp + u * (b.shzTemp - a.shzTemp),
      distance: a.distance + u * (b.distance - a.distance)
    };
  }
  // getSHZTemp: normalized in/out-of-zone value for a given distance and time.
  function getSHZTemp(distance, t) {
    var tab = state.selectedStar.dataTable;
    var i = 1;
    while (i < tab.length) { if (t < tab[i].time) break; i++; }
    if (i >= tab.length) i = tab.length - 1;
    var a = tab[i - 1], b = tab[i];
    var u = (t - a.time) / (b.time - a.time);
    var va = 1 - (distance - a.shzInner) / (a.shzOuter - a.shzInner);
    var vb = 1 - (distance - b.shzInner) / (b.shzOuter - b.shzInner);
    return va + u * (vb - va);
  }
  // Binary search for a habitability boundary crossing time (16 iterations).
  function findTimeOfHabitabilityCrossing(p1, p2, dm, target) {
    var dMass = p2.mass - p1.mass, dIn = p2.shzInner - p1.shzInner, dOut = p2.shzOuter - p1.shzOuter;
    var s = 0.5, step = 0.25;
    if (p1.shzTemp > p2.shzTemp) step *= -1;
    for (var k = 0; k < 16; k++) {
      var dist = dm / (p1.mass + s * dMass);
      var inr = p1.shzInner + s * dIn, outr = p1.shzOuter + s * dOut;
      var v = 1 - (dist - inr) / (outr - inr);
      if (v < target) s += step; else s -= step;
      step *= 0.5;
    }
    return p1.time + s * (p2.time - p1.time);
  }
  // completeDataTable1: recompute shzInner/shzOuter for the whole track.
  function completeDataTable1() {
    var tab = state.selectedStar.dataTable;
    for (var i = 0; i < tab.length; i++) {
      var s = Math.sqrt(pow10(tab[i].logLum)); // equal-flux distance ~ sqrt(L)
      tab[i].shzInner = s * state.innerSHZLimit;
      tab[i].shzOuter = s * state.outerSHZLimit;
    }
    completeDataTable2();
  }
  // completeDataTable2: recompute distance/shzTemp, planet destruction (Roche),
  // tidal-locking time, habitability state segments; feed plot + history.
  function completeDataTable2() {
    var tab = state.selectedStar.dataTable;
    var starMass = state.selectedStar.mass;
    var d0 = state.initDistance;
    var dm = d0 * starMass;                 // distance * mass invariant
    var i = 0;
    var minPD = MIN_PLANET_DISTANCE;
    var destroyTime = NaN;

    var dist = dm / tab[0].mass;
    tab[0].distance = dist;
    var v = 1 - (dist - tab[0].shzInner) / (tab[0].shzOuter - tab[0].shzInner);
    tab[0].shzTemp = v;
    var st = v < 0 ? -1 : (v > 1 ? 1 : 0);
    var states = [{ start: 0, end: state.selectedStar.timespan, state: st }];

    // Roche-limit destruction check at row 0.
    var Rm = 696000000 * pow10(tab[0].logRadius);
    var rho = 1.99e30 * tab[0].mass / (4 * Math.PI * Rm * Rm * Rm / 3);
    var dRoche = 2.44 * Math.pow(rho / 5500, 1 / 3);
    if (dRoche < minPD) dRoche = minPD;
    var rocheAU = 6.685e-12 * Rm * dRoche;
    if (dist <= rocheAU) destroyTime = tab[0].time;

    // Tidal-locking time (constant across the track; from the AS formula).
    var G = 6.67e-11, AUm = 149600000000;
    var lockConst = 100, spin = 2 * Math.PI / (24 * 60 * 60), earthMass = 6.0e24;
    var earthR3 = Math.pow(6370000, 3);
    var mm = 2e30 * 2e30 * starMass * starMass;
    var a6 = Math.pow(AUm * d0, 6);
    var lockT = lockConst * spin * earthMass * a6 / (G * mm * earthR3);
    lockT = lockT / (60 * 60 * 24 * 365 * 1000000);

    for (i = 1; i < tab.length; i++) {
      dist = dm / tab[i].mass;
      tab[i].distance = dist;
      v = 1 - (dist - tab[i].shzInner) / (tab[i].shzOuter - tab[i].shzInner);
      tab[i].shzTemp = v;
      var st2 = v < 0 ? -1 : (v > 1 ? 1 : 0);
      if (isNaN(destroyTime)) {
        Rm = 696000000 * pow10(tab[i].logRadius);
        rho = 1.99e30 * tab[i].mass / (4 * Math.PI * Rm * Rm * Rm / 3);
        dRoche = 2.44 * Math.pow(rho / 5500, 1 / 3);
        if (dRoche < minPD) dRoche = minPD;
        rocheAU = 6.685e-12 * Rm * dRoche;
        if (dist <= rocheAU) destroyTime = tab[i].time;
      }
      if (st2 !== st) {
        var pa = tab[i - 1], pb = tab[i], tc;
        if (st === 0 && st2 === 1) { tc = findTimeOfHabitabilityCrossing(pa, pb, dm, 1); states[states.length - 1].end = tc; states.push({ start: tc, end: state.selectedStar.timespan, state: st2 }); }
        else if (st === 0 && st2 === -1) { tc = findTimeOfHabitabilityCrossing(pa, pb, dm, 0); states[states.length - 1].end = tc; states.push({ start: tc, end: state.selectedStar.timespan, state: st2 }); }
        else if (st === 1 && st2 === 0) { tc = findTimeOfHabitabilityCrossing(pa, pb, dm, 1); states[states.length - 1].end = tc; states.push({ start: tc, end: state.selectedStar.timespan, state: st2 }); }
        else if (st === -1 && st2 === 0) { tc = findTimeOfHabitabilityCrossing(pa, pb, dm, 0); states[states.length - 1].end = tc; states.push({ start: tc, end: state.selectedStar.timespan, state: st2 }); }
        else if (st === 1 && st2 === -1) {
          tc = findTimeOfHabitabilityCrossing(pa, pb, dm, 1); states[states.length - 1].end = tc; states.push({ start: tc, end: state.selectedStar.timespan, state: 0 });
          tc = findTimeOfHabitabilityCrossing(pa, pb, dm, 0); states[states.length - 1].end = tc; states.push({ start: tc, end: state.selectedStar.timespan, state: st2 });
        } else if (st === -1 && st2 === 1) {
          tc = findTimeOfHabitabilityCrossing(pa, pb, dm, 0); states[states.length - 1].end = tc; states.push({ start: tc, end: state.selectedStar.timespan, state: 0 });
          tc = findTimeOfHabitabilityCrossing(pa, pb, dm, 1); states[states.length - 1].end = tc; states.push({ start: tc, end: state.selectedStar.timespan, state: st2 });
        }
      }
      st = st2;
    }
    state.timePlanetDestroyed = isNaN(destroyTime) ? Infinity : destroyTime;
    var lockPx = lockT * TL_WIDTH / state.selectedStar.timespan;
    state.timePlanetTidallyLocked = isNaN(lockT) ? Infinity : (lockPx < 4 ? 0 : lockT);
    state.statesList = states;
  }

  /* ---------------------------------------------------------------------------
     6. Star colour and H-R main-sequence curve, copied from the AS.
     --------------------------------------------------------------------------- */
  function colorFromTemp(t) {
    if (t < 1000) t = 1000; else if (t > 40000) t = 40000;
    var L = log10(t), L2 = L * L, L3 = L * L2;
    var r = 22686.34111 - L * 15082.52755 + L2 * 3375.333832 - L3 * 252.4073853;
    var g = (t <= 6500)
      ? (-811.6499145 + L * 36.97365953 + L2 * 160.7861677 - L3 * 25.57573664)
      : (13836.23586 - L * 9069.078214 + L2 * 2015.254756 - L3 * 149.7766966);
    var b = -11545.34298 + L * 8529.658165 - L2 * 2150.198586 + L3 * 190.0306573;
    r = clamp(r, 0, 255); g = clamp(g, 0, 255); b = clamp(b, 0, 255);
    return [r | 0, g | 0, b | 0];
  }
  // SHZHRDiagram.getLogLumFromLogTempAndClass, default class 5 (the only one used).
  function mainSeqLogLum(x) {
    if (x < 3.5081) return -4686.707 + x * (4157.5332 + x * (-1232.05177 + x * 121.875554));
    if (x < 3.5799) return 22801.9307 + x * (-19349.4898 + x * (5468.65774 + x * -514.806626));
    if (x < 3.728)  return -9950.2659 + x * (8097.5483 + x * (-2198.40972 + x * 199.100683));
    if (x < 3.8287) return 10594.1896 + x * (-8435.0942 + x * (2236.33537 + x * -197.427256));
    if (x < 3.9156) return -7990.8168 + x * (6127.2576 + x * (-1567.12652 + x * 133.707956));
    if (x < 4.2129) return 277.0365 + x * (-207.2491 + x * (50.62412 + x * -4.009536));
    if (x < 4.6015) return -280.446 + x * (189.7309 + x * (-43.6049 + x * 3.446011));
    return -9724.5727 + x * (6346.9359 + x * (-1381.69136 + x * 100.377185));
  }

  /* ---------------------------------------------------------------------------
     7. DOM handles + canvases
     --------------------------------------------------------------------------- */
  var els = {};
  ['liveRegion', 'diagramStage', 'diagramCanvas', 'zoneLabel', 'zoneArrow', 'zoomProxy', 'planetHandle',
   'diagramDesc', 'showGrid', 'showRefOrbits',
   'systemSelect', 'massField', 'massSlider', 'distField', 'distSlider',
   'roMass', 'roLum', 'roTemp', 'roRadius', 'roDistance',
   'hrCanvas', 'hrDesc', 'runButton', 'rateSlider', 'roTime',
   'timelineStage', 'timelineCanvas', 'timelineLabels', 'timeCursor', 'timelineDesc',
   'plotCanvas', 'plotDesc', 'historyCanvas', 'historyTags', 'historyDesc'
  ].forEach(function (id) { els[id] = document.getElementById(id); });

  var ctxDiag, ctxHR, ctxPlot, ctxHist, dpr = 1;
  var hrImage = null, hrImageReady = false;
  var planetImgs = {}, planetReady = 0;

  function setupCanvas(canvas, w, h) {
    var d = Math.min(window.devicePixelRatio || 1, 3);
    canvas.width = Math.round(w * d);
    canvas.height = Math.round(h * d);
    return { ctx: canvas.getContext('2d'), dpr: d };
  }

  /* ---------------------------------------------------------------------------
     8. Diagram scale logic (SHZDiagram.setPlanetDistance / easeToScale). Sets
        the px-per-AU scale so the planet sits comfortably; eases on big jumps.
     --------------------------------------------------------------------------- */
  function setScale(s) { state.scale = s; }
  function startScaleEase(target) {
    if (prefersReducedMotion() || Math.abs(Math.log(target) - Math.log(state.scale)) < 1e-6) {
      state.scaleAnimating = false; setScale(target); return;
    }
    state.scaleAnimFrom = state.scale; state.scaleTarget = target;
    state.scaleAnimStart = now(); state.scaleAnimating = true;
    ensureLoop();
  }
  // setPlanetDistance(distance, doScale): match the AS's sticky auto-zoom.
  function setPlanetDistance(distance, doScale) {
    state.planetDistance = distance;
    var targetX;
    if (doScale) {
      var px = distance * state.scale + STAR_X;
      if (px < PLANET_ZOOM_MIN_X) targetX = PLANET_ZOOM_MIN_X;
      else if (px > PLANET_ZOOM_MAX_X) targetX = PLANET_ZOOM_MAX_X;
      else { targetX = px; doScale = false; }
    } else {
      targetX = DIAG_W / 2;
    }
    var newScale = (targetX - STAR_X) / distance;
    if (doScale) startScaleEase(newScale);
    else { state.scaleAnimating = false; setScale(newScale); }
  }

  /* ---------------------------------------------------------------------------
     9. update() - the AS MainTimeline.update(): recompute everything derived
        from the current time and push it into the readouts + render.
     --------------------------------------------------------------------------- */
  function update() {
    if (!state.selectedStar) return;
    var d = getData(state.time);
    var massRatio = state.selectedStar.mass / d.mass;
    state.dragLimitMin = massRatio * distSliderMin();
    state.dragLimitMax = massRatio * distSliderMax();
    state.starRadius = pow10(d.logRadius);
    state.starTemp = pow10(d.logTemp);

    var epochs = state.selectedStar.epochsList;
    var lastEpoch = epochs[epochs.length - 1];
    if (state.time >= lastEpoch.time && lastEpoch.type >= 14) {
      state.zoneVisible = false; state.starVisible = false;
    } else {
      state.zoneInner = d.shzInner; state.zoneOuter = d.shzOuter;
      state.zoneVisible = true; state.starVisible = true;
    }

    // As in the AS, drive the planet through setPlanetDistance so the diagram
    // applies its sticky auto-zoom (rescaling only when the planet would drift
    // out of the comfortable horizontal band).
    if (state.selectedSystem && state.planetDragging) {
      setPlanetDistance(state.dragDistance, true);
      setPlanetState(state.time >= state.timePlanetDestroyed, state.time >= state.timePlanetTidallyLocked, getSHZTemp(state.dragDistance, state.time));
    } else {
      setPlanetDistance(massRatio * state.initDistance, true);
      setPlanetState(state.time >= state.timePlanetDestroyed, state.time >= state.timePlanetTidallyLocked, getData(state.time).shzTemp);
    }

    // star-system reference orbits + highlighted orbit
    if (state.selectedSystem) {
      state.starOrbits = state.selectedSystem.planetsList.map(function (p) {
        return { label: p.label, e: p.e, a: massRatio * p.a };
      });
      state.highlightOrbit = distValueIndex();
    } else {
      state.starOrbits = [];
      state.highlightOrbit = -1;
    }

    // numeric readouts (MathJax visual + role=img/aria-label spoken form)
    var tp = timeParts(state.time);
    setMath(els.roTime, '\\text{' + tp.num + ' ' + tp.unit + '}', tp.num + ' ' + tp.unit);
    els.roTime.setAttribute('role', 'img');
    els.roTime.setAttribute('aria-label', tp.num + ' ' + tp.spoken);

    setReadout(els.roMass, getNumberString(d.mass, 3), 'M', '_\\odot', 'M⊙', 'solar masses');
    if (d.logLum < -5) setReadout(els.roLum, '0', 'L', '_\\odot', 'L⊙', 'solar luminosities');
    else setReadout(els.roLum, getNumberString(pow10(d.logLum), 3), 'L', '_\\odot', 'L⊙', 'solar luminosities');
    setReadout(els.roTemp, getNumberString(pow10(d.logTemp), 3), 'K', '', 'K', 'kelvin');
    setReadout(els.roRadius, getNumberString(pow10(d.logRadius), 3), 'R', '_\\odot', 'R⊙', 'solar radii');
    setReadout(els.roDistance, getNumberString(d.distance, 3), 'AU', '', 'AU', 'astronomical units');

    state.hrNow = d;
    render();
    updateAria();
  }
  // numStr + unit, typeset in the page's own font: \text{NUM UNIT}<sub>. The
  // whole alphanumeric part sits in \text{} (mtextInheritFont) so it is the
  // exact UI sans-serif; `sub` is an optional subscript (_\odot for solar
  // units). `symbol` is the plain-text fallback (matches the typeset output);
  // `spoken` is the screen-reader form.
  function setReadout(el, numStr, unitText, sub, symbol, spoken) {
    // fallback matches the typeset output: a real <sub> for the solar subscript
    // (sub set), otherwise the plain symbol
    var fb = sub ? (numStr + ' ' + unitText + '<sub>⊙</sub>') : (numStr + ' ' + symbol);
    setMath(el, '\\text{' + numStr + ' ' + unitText + '}' + sub, fb);
    // Display-only value: expose the spoken form as an image label so screen
    // readers say e.g. "1.00 solar masses" while the MathJax visual (and its
    // right-click menu) stays intact; role=img keeps the assistive MML quiet.
    el.setAttribute('role', 'img');
    el.setAttribute('aria-label', numStr + ' ' + spoken);
  }
  // SHZDiagramPlanet.setState -> which planet frame is shown.
  function setPlanetState(destroyed, locked, shzTemp) {
    state.planetFrame = destroyed ? 'destroyed'
      : locked ? 'tidallyLocked'
      : shzTemp < 0 ? 'tooCold'
      : shzTemp > 1 ? 'tooHot'
      : 'justRight';
  }

  /* ---------------------------------------------------------------------------
     10. Rendering. One render() redraws every canvas + repositions overlays.
     --------------------------------------------------------------------------- */
  function render() {
    drawDiagram();
    drawHR();
    drawPlot();
    drawHistory();
    positionOverlays();
  }

  function drawDiagram() {
    var ctx = ctxDiag;
    ctx.setTransform(dprDiag, 0, 0, dprDiag, 0, 0);
    ctx.clearRect(0, 0, DIAG_W, DIAG_H);
    // background
    ctx.fillStyle = '#000';
    ctx.fillRect(0, 0, DIAG_W, DIAG_H);
    // clip to the diagram (the AS uses a mask)
    ctx.save();
    ctx.beginPath(); ctx.rect(0, 0, DIAG_W, DIAG_H); ctx.clip();
    ctx.translate(STAR_X, DIAG_H / 2);
    var scale = state.scale;

    if (state.showGrid) drawGrid(ctx, scale);
    if (state.showRefOrbits) drawRefOrbits(ctx, SOLAR_SYSTEM, scale, C_ORBIT, C_ORBIT, 1, 25, -1, true);
    if (state.selectedSystem) drawRefOrbits(ctx, state.starOrbits, scale, C_ORBIT_STAR, C_ORBIT_HL, 1, 42, state.highlightOrbit, true);
    if (state.zoneVisible) drawZone(ctx, scale);
    if (state.starVisible) drawStar(ctx, scale);
    ctx.restore();

    drawScalebar(ctx, scale);
    // planet is drawn as a positioned HTML-less bitmap on the canvas at its x
    drawPlanet(ctx, scale);
  }

  // SHZDiagramGrid.update
  function drawGrid(ctx, scale) {
    var minX = -STAR_X, maxX = DIAG_W - STAR_X, minY = -DIAG_H / 2, maxY = DIAG_H / 2;
    var m = 15 / scale, lg = log10(m), k = Math.ceil(lg);
    var spacing, below, major;
    if (k - lg > log10(2)) { below = pow10(k - 1); spacing = 5 * below; major = 2; }
    else { spacing = pow10(k); below = 0.5 * spacing; major = 5; }
    var aMin = 0.05, aMax = 0.2;
    var aMinor = aMin + (aMax - aMin) * (spacing - m) / (spacing - below);
    ctx.lineWidth = 1;
    var i, x, y;
    for (i = Math.ceil(minX / scale / spacing); i < Math.ceil(maxX / scale / spacing); i++) {
      x = i * spacing * scale;
      ctx.strokeStyle = 'rgba(224,224,224,' + (i % major === 0 ? aMax : aMinor) + ')';
      ctx.beginPath(); ctx.moveTo(x, minY); ctx.lineTo(x, maxY); ctx.stroke();
    }
    for (i = Math.ceil(minY / scale / spacing); i < Math.ceil(maxY / scale / spacing); i++) {
      y = i * spacing * scale;
      ctx.strokeStyle = 'rgba(224,224,224,' + (i % major === 0 ? aMax : aMinor) + ')';
      ctx.beginPath(); ctx.moveTo(minX, y); ctx.lineTo(maxX, y); ctx.stroke();
    }
  }

  // SHZDiagramRefOrbits: 12-point Bezier ellipses + curve-following labels.
  function drawRefOrbits(ctx, list, scale, lineColor, hlColor, thick, labelMargin, highlight, showLabels) {
    var N = 12, step = 2 * Math.PI / N, sec = 1 / Math.cos(step / 2);
    var labelBaseX = 200, labelBaseY = DIAG_H / 2 - labelMargin;
    var labelBaseR = Math.sqrt(labelBaseX * labelBaseX + labelBaseY * labelBaseY);
    var curveX = labelBaseX / 4, KX1 = 2 * curveX, KX2 = labelBaseX - 2 * curveX;
    var KY1 = 2 * labelBaseY, KY2 = labelBaseY - 2 * labelBaseY;
    ctx.font = 'bold 11px ' + UI_FONT;
    ctx.textAlign = 'center'; ctx.textBaseline = 'middle';

    for (var o = 0; o < list.length; o++) {
      var orb = list[o], a = orb.a, e = orb.e || 0;
      if (a * scale >= SAFE_RADIUS) continue;
      var b = a * Math.sqrt(1 - e * e), cShift = e * a, k = Math.sqrt(1 - e * e);
      var hl = (o === highlight);
      ctx.strokeStyle = hl ? hlColor : lineColor;
      ctx.lineWidth = hl ? 1.5 : thick;
      ctx.globalAlpha = 0.8;
      // last anchor point
      var angA = step + (N - 1) * step;
      ctx.beginPath();
      ctx.moveTo(scale * (-cShift + a * Math.cos(angA)), scale * (b * Math.sin(angA)));
      for (var i = 0; i < N; i++) {
        var ac = step / 2 + i * step, aa = step + i * step;
        ctx.quadraticCurveTo(
          scale * (-cShift + a * sec * Math.cos(ac)), scale * (b * sec * Math.sin(ac)),
          scale * (-cShift + a * Math.cos(aa)), scale * (b * Math.sin(aa)));
      }
      ctx.stroke();
      ctx.globalAlpha = 1;

      if (showLabels && orb.label != null) {
        var lx, ly, lscale = 1;
        var v = labelBaseY / (scale * a * k);
        var useCurve = (v > 1 || v < -1);
        if (!useCurve) {
          var l10 = (scale * a) * (-e + Math.cos(Math.asin(v)));
          useCurve = l10 < labelBaseX;
          if (!useCurve) { lx = l10; ly = labelBaseY; }
        }
        if (useCurve) {
          var s = 0.5, d6 = 0.5, l7 = 0, l8 = 0;
          for (var it = 0; it < 12; it++) {
            d6 *= 0.5;
            l7 = s * (KX1 + s * KX2); l8 = s * (KY1 + s * KY2);
            var vv = l8 / (scale * a * k);
            if (vv > 1) { s -= d6; }
            else { if (vv < -1) vv = -1; var l9 = (scale * a) * (-e + Math.cos(Math.asin(vv))); if (l9 > l7) s += d6; else s -= d6; }
          }
          lscale = Math.pow(Math.sqrt(l7 * l7 + l8 * l8) / labelBaseR, 0.4);
          lx = l7; ly = l8;
        }
        ctx.save();
        ctx.fillStyle = hl ? hlColor : lineColor;
        ctx.translate(lx, ly); ctx.scale(lscale, lscale);
        ctx.fillText(String(orb.label), 0, 0);
        ctx.restore();
      }
    }
    ctx.globalAlpha = 1;
  }

  // SHZDiagramZone.update: habitable-zone annulus (even-odd ring).
  function drawZone(ctx, scale) {
    var inner = state.zoneInner, outer = state.zoneOuter;
    if (inner * scale > SAFE_RADIUS) return;
    ctx.fillStyle = C_ZONE;
    ctx.beginPath();
    ctx.arc(0, 0, outer * scale, 0, 2 * Math.PI);
    ctx.arc(0, 0, inner * scale, 0, 2 * Math.PI);
    ctx.fill('evenodd');
  }

  // SHZDiagramStar.update: temperature-coloured disc + halo (gradients; the AS
  // blur is approximated by the soft gradient edge for Safari/WebKit safety).
  function drawStar(ctx, scale) {
    var temp = state.starTemp, radius = state.starRadius;
    var rgb = colorFromTemp(temp);
    var col = 'rgb(' + rgb[0] + ',' + rgb[1] + ',' + rgb[2] + ')';
    var disc = radius * AU_PER_SOLAR_RADIUS * scale;
    if (disc < STAR_MIN_DISC) disc = STAR_MIN_DISC;
    var drawR = Math.min(disc, SAFE_RADIUS);
    var haloScale = 1.2 + 1.4 * (Math.log(temp) - ln1000) / (ln40000 - ln1000);
    var halo = haloScale * disc;

    if (drawR !== SAFE_RADIUS) {
      var loc6 = Math.min(halo, SAFE_RADIUS);
      var white = 0.6, ha = clamp(0.3 + 0.2 * (Math.log(temp) - ln1000) / (ln40000 - ln1000), 0, 0.7);
      var cm = rgb.map(function (c) { return Math.min(255, c + white * (255 - c)) | 0; });
      var cmStr = 'rgb(' + cm[0] + ',' + cm[1] + ',' + cm[2] + ')';
      var g = ctx.createRadialGradient(0, 0, 0, 0, 0, halo);
      var mid = clamp((255 / haloScale - 1) / 255, 0, 1);
      g.addColorStop(0, 'rgba(' + cm[0] + ',' + cm[1] + ',' + cm[2] + ',' + ha + ')');
      g.addColorStop(mid, 'rgba(' + cm[0] + ',' + cm[1] + ',' + cm[2] + ',' + ha + ')');
      g.addColorStop(1, 'rgba(255,255,255,0)');
      ctx.fillStyle = g;
      ctx.beginPath(); ctx.arc(0, 0, loc6, 0, 2 * Math.PI); ctx.fill();
    }
    // solid disc
    ctx.fillStyle = col;
    ctx.beginPath(); ctx.arc(0, 0, disc, 0, 2 * Math.PI); ctx.fill();
    // white core gradient
    var g2 = ctx.createRadialGradient(0, 0, 0, 0, 0, drawR);
    g2.addColorStop(0, 'rgba(255,255,255,0.95)');
    g2.addColorStop(170 / 255, 'rgba(255,255,255,0.8)');
    g2.addColorStop(1, 'rgba(255,255,255,0.6)');
    ctx.fillStyle = g2;
    ctx.beginPath(); ctx.arc(0, 0, drawR, 0, 2 * Math.PI); ctx.fill();
  }

  // SHZDiagramScalebar.update: dynamic "nice" scale bar at top-right.
  function drawScalebar(ctx, scale) {
    var minSpacing = 15;
    var m = minSpacing / scale, lg = log10(m), k = Math.ceil(lg);
    var spacing, below, major;
    if (k - lg > log10(2)) { below = pow10(k - 1); spacing = 5 * below; major = 2; }
    else { spacing = pow10(k); below = 0.5 * spacing; major = 5; }
    var half = major * spacing * scale / 2;
    var cx = DIAG_W - 85, cy = 23;
    ctx.save();
    ctx.fillStyle = '#fff';
    ctx.fillRect(cx - half, cy, 2 * half, 5);
    state.scalebarText = String(major * spacing) + ' AU';
    ctx.restore();
    // label rendered as MathJax HTML overlay (positionOverlays)
  }

  var planetLabelMap = {
    'default': 'planet-default', 'destroyed': 'planet-destroyed',
    'tidallyLocked': 'planet-tidallylocked', 'tooHot': 'planet-toohot',
    'justRight': 'planet-justright', 'tooCold': 'planet-toocold'
  };
  function planetX() {
    if (state.planetDragging && state.planetDragX > 0) return state.planetDragX;
    return STAR_X + state.planetDistance * state.scale;
  }
  function drawPlanet(ctx) {
    var px = planetX(), py = DIAG_H / 2;
    var sc = px >= PLANET_DRAG_MIN_X ? 1 : Math.pow((px - STAR_X) / (PLANET_DRAG_MIN_X - STAR_X), 0.4);
    var frame = state.planetFrame || 'default';
    var img = planetImgs[planetLabelMap[frame]];
    if (!img || !img.complete || !img.naturalWidth) return;
    var w = 26 * sc, h = 27 * sc;
    ctx.drawImage(img, px - w / 2, py - h / 2, w, h);
  }

  // H-R diagram (SHZHRDiagram.update).
  function drawHR() {
    if (!state.hrNow) return;
    var ctx = ctxHR;
    ctx.setTransform(dprHR, 0, 0, dprHR, 0, 0);
    ctx.clearRect(0, 0, HR_W, HR_H);
    ctx.fillStyle = '#fff'; ctx.fillRect(0, 0, HR_W, HR_H);
    if (hrImageReady) ctx.drawImage(hrImage, 0, 0, HR_W, HR_H);

    var sx = HR_W / (HR_MAX_LOGT - HR_MIN_LOGT), sy = -HR_H / (HR_MAX_LOGL - HR_MIN_LOGL);
    function X(logT) { return HR_W - sx * (logT - HR_MIN_LOGT); }
    function Y(logL) { return HR_H + sy * (logL - HR_MIN_LOGL); }
    ctx.save();
    ctx.beginPath(); ctx.rect(0, 0, HR_W, HR_H); ctx.clip();
    // main-sequence reference curve
    ctx.strokeStyle = C_HR_MAINSEQ; ctx.lineWidth = 1;
    ctx.beginPath();
    for (var xp = 0; xp <= HR_W; xp++) {
      var logT = HR_MIN_LOGT + (HR_MAX_LOGT - HR_MIN_LOGT) * (1 - xp / HR_W);
      var logL = mainSeqLogLum(logT);
      var px = HR_W - sx * (logT - HR_MIN_LOGT), py = HR_H + sy * (logL - HR_MIN_LOGL);
      if (xp === 0) ctx.moveTo(px, py); else ctx.lineTo(px, py);
    }
    ctx.stroke();
    // star's evolutionary track, up to "now", then the red "now" marker
    var tab = state.selectedStar.dataTable, nowT = state.hrNow.time;
    ctx.strokeStyle = C_HR_TRACK; ctx.lineWidth = 1;
    ctx.beginPath(); ctx.moveTo(X(tab[0].logTemp), Y(tab[0].logLum));
    var broke = false;
    for (var i = 1; i < tab.length; i++) {
      ctx.lineTo(X(tab[i].logTemp), Y(tab[i].logLum));
      if (tab[i].time >= nowT) { ctx.lineTo(X(state.hrNow.logTemp), Y(state.hrNow.logLum)); broke = true; break; }
    }
    // When "now" is at/after the final data point (end of the animation), the
    // loop finishes without the break above; connect to the current position so
    // the track + dot never vanish.
    if (!broke) ctx.lineTo(X(state.hrNow.logTemp), Y(state.hrNow.logLum));
    ctx.stroke();
    ctx.fillStyle = C_HR_DOT;
    ctx.beginPath(); ctx.arc(X(state.hrNow.logTemp), Y(state.hrNow.logLum), 3, 0, 2 * Math.PI); ctx.fill();
    ctx.restore();
  }

  // Habitability plot (SHZHabitabilityPlot).
  function drawPlot() {
    if (!state.selectedStar) return;
    var ctx = ctxPlot, span = state.selectedStar.timespan;
    ctx.setTransform(dprPlot, 0, 0, dprPlot, 0, 0);
    ctx.clearRect(0, 0, PLOT_W, PLOT_H);
    ctx.fillStyle = '#fff'; ctx.fillRect(0, 0, PLOT_W, PLOT_H);
    // hot shading (top) + cold shading (bottom)
    var gh = ctx.createLinearGradient(0, 0, 0, SHADING_EXTENT);
    gh.addColorStop(0, 'rgba(' + C_PLOT_HOT + ',1)'); gh.addColorStop(1, 'rgba(' + C_PLOT_HOT + ',0.2)');
    ctx.fillStyle = gh; ctx.fillRect(0, 0, PLOT_W, SHADING_EXTENT);
    var gc = ctx.createLinearGradient(0, PLOT_H, 0, PLOT_H - SHADING_EXTENT);
    gc.addColorStop(0, 'rgba(' + C_PLOT_COLD + ',1)'); gc.addColorStop(1, 'rgba(' + C_PLOT_COLD + ',0.2)');
    ctx.fillStyle = gc; ctx.fillRect(0, PLOT_H - SHADING_EXTENT, PLOT_W, SHADING_EXTENT);

    // shzTemp curve, clamped, with gaps where off-scale (matches the AS masking)
    var tab = state.selectedStar.dataTable;
    var sx = PLOT_W / span, k = -(PLOT_H - 2 * SHADING_EXTENT), off = PLOT_H - SHADING_EXTENT;
    var loMin = -10, loMax = PLOT_H + 10;
    ctx.strokeStyle = C_PLOT_CURVE; ctx.lineWidth = 1;
    ctx.beginPath();
    var px = sx * tab[0].time, py = k * tab[0].shzTemp + off;
    var region = py < 0 ? 1 : (py > PLOT_H ? -1 : 0);
    py = clamp(py, loMin, loMax);
    if (region === 0) ctx.moveTo(px, py);
    var lpx = px, lpy = py, lregion = region;
    for (var i = 1; i < tab.length; i++) {
      var cx = sx * tab[i].time, cy = k * tab[i].shzTemp + off;
      var creg = cy < 0 ? 1 : (cy > PLOT_H ? -1 : 0);
      cy = clamp(cy, loMin, loMax);
      if (lregion === 0) ctx.lineTo(cx, cy);
      else if (lregion !== creg) { ctx.moveTo(lpx, lpy); ctx.lineTo(cx, cy); }
      lpx = cx; lpy = cy; lregion = creg;
    }
    ctx.stroke();

    // planet-destroyed shading
    if (state.timePlanetDestroyed < Infinity) {
      var dx = sx * state.timePlanetDestroyed;
      if (dx < PLOT_W) { ctx.fillStyle = 'rgba(0,0,0,0.15)'; ctx.fillRect(dx, 0, PLOT_W - dx, PLOT_H); }
    }
    // border
    ctx.strokeStyle = C_PLOT_BORDER; ctx.lineWidth = 1; ctx.strokeRect(0.5, 0.5, PLOT_W - 1, PLOT_H - 1);
    // cursor
    var curX = state.time * PLOT_W / span;
    ctx.strokeStyle = C_CURSOR; ctx.lineWidth = 2;
    ctx.beginPath(); ctx.moveTo(curX, 0); ctx.lineTo(curX, PLOT_H); ctx.stroke();
  }

  // System-history bar (SHZSystemHistory) + tags positioned as HTML.
  function drawHistory() {
    if (!state.selectedStar) return;
    var ctx = ctxHist, span = state.selectedStar.timespan;
    ctx.setTransform(dprHist, 0, 0, dprHist, 0, 0);
    ctx.clearRect(0, 0, HIST_W, HIST_H);
    var sx = HIST_W / span, destroyed = state.timePlanetDestroyed;
    var colors = [C_HIST_COLD, C_HIST_JUST, C_HIST_HOT];
    var segs = state.statesList;
    for (var i = 0; i < segs.length; i++) {
      var x0 = sx * segs[i].start;
      if (segs[i].end > destroyed) {
        ctx.fillStyle = colors[segs[i].state + 1];
        ctx.fillRect(x0, 0, sx * destroyed - x0, HIST_H);
        ctx.fillStyle = C_HIST_DEAD;
        ctx.fillRect(sx * destroyed, 0, HIST_W - sx * destroyed, HIST_H);
        break;
      }
      ctx.fillStyle = colors[segs[i].state + 1];
      ctx.fillRect(x0, 0, sx * segs[i].end - x0, HIST_H);
    }
    // cursor
    var curX = state.time * HIST_W / span;
    ctx.strokeStyle = C_CURSOR; ctx.lineWidth = 2;
    ctx.beginPath(); ctx.moveTo(curX, -1); ctx.lineTo(curX, HIST_H + 1); ctx.stroke();
    positionHistoryTags(sx);
  }

  /* ---------------------------------------------------------------------------
     11. HTML overlays positioned in per-cent of each stage (so they track the
         CSS-scaled canvases). Text labels + MathJax live here, not on canvas.
     --------------------------------------------------------------------------- */
  function pctX(px, w) { return (px / w * 100) + '%'; }
  function pctY(py, h) { return (py / h * 100) + '%'; }

  function positionOverlays() {
    // planet handle
    var px = planetX(), py = DIAG_H / 2;
    els.planetHandle.style.left = pctX(px, DIAG_W);
    els.planetHandle.style.top = pctY(py, DIAG_H);
    els.planetHandle.setAttribute('aria-valuenow', String(round3(state.planetDistance)));
    els.planetHandle.setAttribute('aria-valuetext', planetSpoken());

    // habitable-zone label (SHZDiagramZone label placement)
    positionZoneLabel();

    // scale bar label (MathJax): pin it centred just above the drawn bar
    // (which sits at x = DIAG_W-85, y = 23) so it tracks the bar instead of
    // drifting to the stage origin.
    if (state.scalebarText) {
      var sEl = els.zoneScaleDummy || (els.zoneScaleDummy = ensureScaleEl());
      sEl.style.left = pctX(DIAG_W - 85, DIAG_W);
      sEl.style.top = pctY(19, DIAG_H);
      var parts = state.scalebarText.split(' '); // "0.1 AU"
      setMath(sEl, '\\text{' + parts[0] + ' AU}', state.scalebarText);
    }
  }
  function ensureScaleEl() {
    var e = document.createElement('span');
    e.className = 'shz-scalebar-label'; e.setAttribute('aria-hidden', 'true');
    e.style.position = 'absolute'; e.style.color = '#fff'; e.style.fontWeight = 'bold';
    e.style.fontSize = '0.75rem'; e.style.transform = 'translate(-50%,-100%)';
    e.style.textShadow = '0 0 3px #000,0 0 3px #000'; e.style.pointerEvents = 'none';
    e.style.whiteSpace = 'nowrap';
    els.diagramStage.appendChild(e);
    return e;
  }
  // SHZDiagramZone.update() label + arrow placement. All coordinates are
  // star-relative stage units (origin at the star), exactly as in the AS:
  // labelLeft/labelTop are the label's left/top edges.
  var ARROW_MAX_THRESHOLD = DIAG_W - STAR_X - 7;   // zone inner edge past the right edge
  var ARROW_MIN_THRESHOLD = 22;                    // whole zone tiny, hidden by the star
  function positionZoneLabel() {
    var el = els.zoneLabel, arrow = els.zoneArrow;
    if (!state.zoneVisible) { el.style.display = 'none'; arrow.hidden = true; state.zoneArrowHint = null; return; }
    el.style.display = '';

    // Label size in stage units (the overlay text is CSS-sized, so convert).
    var stageW = els.diagramStage.clientWidth || DIAG_W;
    var k = DIAG_W / stageW;
    var lw = el.offsetWidth * k, lh = el.offsetHeight * k;

    var scale = state.scale, inner = state.zoneInner, outer = state.zoneOuter;
    var r = (inner + (outer - inner) / 2) * scale;
    var labelBaseX = 200, labelBaseY = -(DIAG_H / 2 - 35);
    var labelBaseR = Math.sqrt(labelBaseX * labelBaseX + labelBaseY * labelBaseY);
    var labelMaxX = DIAG_W - STAR_X - lw - 27;
    var curveX = labelBaseX / 4, KX1 = 2 * curveX, KX2 = labelBaseX - 2 * curveX;
    var KY1 = 2 * labelBaseY, KY2 = labelBaseY - 2 * labelBaseY;
    var labelLeft, labelTop;
    if (r < labelBaseR) {
      // follow the quadratic guide curve inward (bisection on its parameter)
      var u = 0.5, uStep = 0.25, ux = 0, uy = 0;
      for (var i = 0; i < 12; i++) {
        ux = u * (KX1 + u * KX2); uy = u * (KY1 + u * KY2);
        var ur = Math.sqrt(ux * ux + uy * uy);
        if (ur > r) u -= uStep; else u += uStep;
        uStep *= 0.5;
      }
      labelLeft = ux - lw / 2;
      labelTop = uy - (uy - labelBaseY) / 2.3;
    } else {
      labelLeft = Math.sqrt(r * r - labelBaseY * labelBaseY) - lw / 2;
      labelTop = labelBaseY;
      // AS clamps (never hides) so the label stays on screen at the right edge
      if (labelLeft > labelMaxX) labelLeft = labelMaxX;
    }

    // place the label (CSS centres it on the given point)
    el.style.left = pctX(STAR_X + labelLeft + lw / 2, DIAG_W);
    el.style.top = pctY(DIAG_H / 2 + labelTop + lh / 2, DIAG_H);

    // --- arrow ---
    var ax, ay, rot;
    state.zoneArrowHint = (inner * scale > ARROW_MAX_THRESHOLD) ? 'offscreen'
      : (outer * scale < ARROW_MIN_THRESHOLD) ? 'atstar' : null;
    if (inner * scale > ARROW_MAX_THRESHOLD) {
      // zone lies beyond the right edge: arrow sits after the label, pointing
      // right (the art's natural direction) toward the off-screen zone
      // +7 = half the 14px art, so the 5px gap after the label reads correctly
      // once the arrow is centred on this point
      ax = labelLeft + lw + 5 + 7; ay = labelTop + lh / 2; rot = 0;
    } else if (outer * scale < ARROW_MIN_THRESHOLD) {
      // Zone is tiny and hidden behind the star: point back at the star. The AS
      // places the arrow at the label's bottom edge; because the exported art is
      // centred on its position (and grows to 14 units tall once rotated), drop
      // it a further half-diagonal so it hangs clear of the text instead of
      // overlapping the last line.
      // clearance is derived from the arrow's real on-screen size (it is a fixed
      // CSS-pixel image, so convert through k) => correct at any stage scale
      ax = labelLeft + lw / 2;
      ay = labelTop + lh - 2 + (14 * k) / 2 + 3 * k;
      rot = 180 + 180 / Math.PI * Math.atan2(ay, ax);
    } else {
      arrow.hidden = true; return;
    }
    arrow.hidden = false;
    arrow.style.left = pctX(STAR_X + ax, DIAG_W);
    arrow.style.top = pctY(DIAG_H / 2 + ay, DIAG_H);
    arrow.style.setProperty('--rot', rot + 'deg');
  }
  function positionHistoryTags(sx) {
    var epochs = state.selectedStar.epochsList;
    var endMainSeq = epochs[1].time;
    var lastType = epochs[epochs.length - 1].type;
    var deathTime = epochs[epochs.length - 1].time;
    var deathText = (lastType >= 10 && lastType <= 12) ? 'star becomes\nwhite dwarf'
      : lastType === 13 ? 'star becomes\na neutron star'
      : lastType === 14 ? 'star becomes\na black hole'
      : lastType === 15 ? 'star destroyed\nin supernova' : '';
    var tags = [];
    tags.push({ x: endMainSeq * sx, text: 'star stops\nfusing H', pos: 'above' });
    if (deathText) tags.push({ x: deathTime * sx, text: deathText, pos: 'above' });
    if (state.timePlanetDestroyed < state.selectedStar.timespan)
      tags.push({ x: state.timePlanetDestroyed * sx, text: 'planet is\ndestroyed', pos: 'below' });
    if (state.timePlanetTidallyLocked < state.selectedStar.timespan &&
        state.timePlanetTidallyLocked < state.timePlanetDestroyed)
      tags.push({ x: state.timePlanetTidallyLocked * sx, text: 'planet becomes\ntidally locked', pos: 'below' });

    var host = els.historyTags;
    host.textContent = '';
    tags.forEach(function (t) {
      var d = document.createElement('span');
      d.className = 'shz-history-tag shz-history-tag--' + t.pos;
      d.style.left = pctX(t.x, HIST_W);
      var arrow = document.createElement('span');
      arrow.className = 'shz-tag-arrow'; arrow.textContent = t.pos === 'above' ? '▼' : '▲';
      var txt = document.createElement('span');
      t.text.split('\n').forEach(function (line, idx) {
        if (idx) txt.appendChild(document.createElement('br'));
        txt.appendChild(document.createTextNode(line));
      });
      if (t.pos === 'above') { d.appendChild(txt); d.appendChild(arrow); }
      else { d.appendChild(arrow); d.appendChild(txt); }
      host.appendChild(d);
    });
  }

  /* ---------------------------------------------------------------------------
     12. Timeline tick marks + labels (SHZTimeline.updateTickmarks).
     --------------------------------------------------------------------------- */
  function drawTimeline() {
    if (!state.selectedStar) return;
    var ctx = ctxTL, span = state.selectedStar.timespan;
    ctx.setTransform(dprTL, 0, 0, dprTL, 0, 0);
    ctx.clearRect(0, 0, TL_WIDTH, TL_HEIGHT + 20);
    // background bar
    ctx.fillStyle = '#fff'; ctx.strokeStyle = 'rgb(234,234,234)'; ctx.lineWidth = 1;
    ctx.fillRect(0, -0.5, TL_WIDTH, TL_HEIGHT + 4);
    ctx.strokeRect(0.5, -1.5, TL_WIDTH - 1, TL_HEIGHT + 4);

    var s3 = TL_WIDTH / span;
    var minor = pow10(Math.ceil(log10(15 / s3)));
    if (minor / 2 * s3 > 15) minor /= 2;
    var p = Math.ceil(log10(80 / s3));
    var majorStep = pow10(p);
    if (majorStep / 2 * s3 > 80) { majorStep /= 2; p--; }

    ctx.strokeStyle = 'rgb(80,79,79)'; ctx.lineWidth = 1;
    var labels = [{ x: 0, text: '0' }];
    for (var t = 0; t < span; t += minor) {
      var x = s3 * t;
      if (Math.abs(t % majorStep) < minor * 1e-6 || Math.abs(majorStep - (t % majorStep)) < minor * 1e-6) {
        if (t !== 0) {
          var lab;
          if (t >= 1000) lab = getFormattedNumber(t / 1000, p - 3) + ' Gy';
          else lab = getFormattedNumber(t, p) + ' My';
          labels.push({ x: x, text: lab });
        }
        ctx.beginPath(); ctx.moveTo(x, 0); ctx.lineTo(x, TL_HEIGHT); ctx.stroke();
      } else {
        ctx.beginPath(); ctx.moveTo(x, 1.5); ctx.lineTo(x, TL_HEIGHT - 1.5); ctx.stroke();
      }
    }
    // MathJax labels as HTML under the timeline
    var host = els.timelineLabels; host.textContent = '';
    labels.forEach(function (l) {
      var span2 = document.createElement('span');
      span2.className = 'shz-tl-label';
      span2.style.left = pctX(l.x, TL_WIDTH);
      var parts = l.text.split(' ');
      if (parts.length === 2) setMath(span2, '\\text{' + parts[0] + ' ' + parts[1] + '}', l.text);
      else span2.textContent = l.text;
      host.appendChild(span2);
    });
  }

  /* ---------------------------------------------------------------------------
     13. Timeline time stepping (SHZTimeline.increment) - snaps to data points.
     --------------------------------------------------------------------------- */
  function timelineIncrement(dir) {
    if (dir === 0 || !state.selectedStar) return;
    var span = state.selectedStar.timespan, tab = state.selectedStar.dataTable;
    var dt = span / TL_WIDTH;
    var t5 = state.time + dir * dt;
    t5 = clamp(t5, 0, span);
    var t6 = t5 - state.time;
    var i = 1;
    while (i < tab.length) { if (state.time < tab[i].time) break; i++; }
    i--;
    if (i === tab.length - 1) { if (dir < 0) i += dir; }
    else {
      var thr = 0.1 * (tab[i + 1].time - tab[i].time);
      if (state.time < tab[i].time + thr) i += dir;
      else if (i < tab.length - 1 && state.time > tab[i + 1].time - thr) i += dir + 1;
      else if (i < tab.length - 1) { i += dir; if (dir < 0) i++; }
    }
    i = clamp(i, 0, tab.length - 1);
    var t8 = tab[i].time, t9 = t8 - state.time;
    state.time = (Math.abs(t6) < Math.abs(t9)) ? t5 : t8;
    onTimeChanged();
  }
  function setTime(t) { state.time = clamp(t, 0, state.selectedStar.timespan); onTimeChanged(); }
  // A time / distance change never alters the timeline's tick marks (those
  // depend only on the star's timespan), so onTimeChanged does NOT rebuild them
  // — that avoids the labels being torn down and rebuilt (and jumping) on every
  // drag / run frame. drawTimeline() is called only where the star changes.
  function onTimeChanged() { update(); positionTimeCursor(); }

  function positionTimeCursor() {
    if (!state.selectedStar) return;
    var span = state.selectedStar.timespan;
    els.timeCursor.style.left = pctX(state.time * TL_WIDTH / span, TL_WIDTH);
    els.timeCursor.setAttribute('aria-valuemin', '0');
    els.timeCursor.setAttribute('aria-valuemax', String(Math.round(span)));
    els.timeCursor.setAttribute('aria-valuenow', String(Math.round(state.time)));
    var tp = timeParts(state.time);
    els.timeCursor.setAttribute('aria-valuetext', tp.num + ' ' + tp.spoken + ' since star system formation');
  }

  /* ---------------------------------------------------------------------------
     14. Controls: sliders (native range), fields, selects, checkboxes, radios,
         run/pause, rate. Mass slider = index into the finite track-mass set;
         distance slider = log-continuous or index into the perihelion set.
     --------------------------------------------------------------------------- */
  // --- mass slider (finite set of the 17 track masses) ---
  function massFromIndex(i) { return state.masses[clamp(i, 0, state.masses.length - 1)]; }
  function nearestMassIndex(m) {
    var best = 0, bd = Infinity;
    for (var i = 0; i < state.masses.length; i++) { var d = Math.abs(state.masses[i] - m); if (d < bd) { bd = d; best = i; } }
    return best;
  }
  function syncMassField() {
    els.massField.value = sigDigitString(state.initStarMass, 2);
    els.massSlider.value = String(nearestMassIndex(state.initStarMass));
    els.massSlider.setAttribute('aria-valuetext', 'star mass ' + sigDigitString(state.initStarMass, 2) + ' solar masses');
  }
  function onMassChanged(fromUser) {
    // find the track star whose mass matches the slider value (nearest of 17)
    var i = nearestMassIndex(state.initStarMass);
    state.initStarMass = state.masses[i];
    for (var k = 0; k < state.starsList.length; k++) {
      if (Math.abs(state.starsList[k].mass - state.initStarMass) < 1e-10) { state.selectedStar = state.starsList[k]; break; }
    }
    if (state.running) toggleRunning();
    state.time = 0;
    completeDataTable1();
    syncMassField();
    drawTimeline();   // the star (hence timespan + tick marks) changed
    onTimeChanged();
    if (fromUser) announce('Star mass ' + sigDigitString(state.initStarMass, 2) + ' solar masses.');
  }

  // --- distance slider (continuous log, or finite perihelion set) ---
  var LOG_MIN = Math.log(MIN_DIST_T0), LOG_MAX = Math.log(MAX_DIST_T0);
  function distSliderMin() { return state.distFinite ? state.distFinite[0] : MIN_DIST_T0; }
  function distSliderMax() { return state.distFinite ? state.distFinite[state.distFinite.length - 1] : MAX_DIST_T0; }
  function distValueIndex() {
    if (!state.distFinite) return -1;
    var best = 0, bd = Infinity;
    for (var i = 0; i < state.distFinite.length; i++) { var d = Math.abs(state.distFinite[i] - state.initDistance); if (d < bd) { bd = d; best = i; } }
    return best;
  }
  function distFromParam(p) {
    if (state.distFinite) return state.distFinite[clamp(Math.round(p), 0, state.distFinite.length - 1)];
    var v = Math.exp(LOG_MIN + (p / 1000) * (LOG_MAX - LOG_MIN));
    // snap to 3 significant figures like the AS
    return parseFloat(sigDigitString(v, 3));
  }
  function paramFromDist(d) {
    if (state.distFinite) return distValueIndex();
    return clamp(1000 * (Math.log(d) - LOG_MIN) / (LOG_MAX - LOG_MIN), 0, 1000);
  }
  function configDistSlider() {
    if (state.distFinite) {
      els.distSlider.min = '0'; els.distSlider.max = String(state.distFinite.length - 1); els.distSlider.step = '1';
    } else {
      els.distSlider.min = '0'; els.distSlider.max = '1000'; els.distSlider.step = '1';
    }
  }
  function syncDistField() {
    els.distField.value = sigDigitString(state.initDistance, 3);
    els.distSlider.value = String(paramFromDist(state.initDistance));
    els.distSlider.setAttribute('aria-valuetext', 'planet distance ' + sigDigitString(state.initDistance, 3) + ' astronomical units');
  }
  function onDistanceChanged(fromUser) {
    if (state.running) toggleRunning();
    completeDataTable2();
    syncDistField();
    onTimeChanged();
    if (fromUser) announce('Initial planet distance ' + sigDigitString(state.initDistance, 3) + ' astronomical units.');
  }

  // --- system selector (syncToSelectedSystem) ---
  function syncToSelectedSystem() {
    var sys = SYSTEMS[parseInt(els.systemSelect.value, 10)];
    state.selectedSystem = (sys.mass === 0) ? null : sys;
    if (state.selectedSystem) {
      // distance slider -> finite set of perihelion distances
      state.distFinite = state.selectedSystem.planetsList.map(function (p) { return p.a * (1 - p.e); }).sort(function (a, b) { return a - b; });
      // re-snap current distance into the new set
      state.initDistance = state.distFinite[distValueIndex()];
      // mass slider -> the system's mass (snapped to nearest track), disabled
      state.initStarMass = massFromIndex(nearestMassIndex(state.selectedSystem.mass));
      els.massSlider.disabled = true; els.massField.disabled = true;
    } else {
      state.distFinite = null;
      els.massSlider.disabled = false; els.massField.disabled = false;
    }
    configDistSlider();
  }
  function onSystemChanged() {
    syncToSelectedSystem();
    onMassChanged(false);       // reselect star track for the (possibly new) mass
    update(); drawTimeline(); positionTimeCursor();
    syncMassField(); syncDistField();
    announce(state.selectedSystem ? (state.selectedSystem.name + ' selected.') : 'No star system selected.');
  }

  // --- habitable-zone assumption (pessimistic, matching the original) ---
  // The Flash sim had optimistic/pessimistic radio buttons but the optimistic
  // one was permanently disabled, so it always used the pessimistic limits.
  // Those buttons are not part of the original visible UI, so there is no
  // control here; the limits are fixed to pessimistic.
  function onAssumptionsChanged() {
    state.innerSHZLimit = PES_INNER; state.outerSHZLimit = PES_OUTER;
    if (state.running) toggleRunning();
    completeDataTable1();
    onTimeChanged();
  }

  // --- run / pause + rate ---
  function toggleRunning() {
    if (state.running) { state.running = false; els.runButton.textContent = 'run'; }
    else {
      // If the timeline is already at the end, pressing run replays from t = 0.
      if (state.selectedStar && state.time >= state.selectedStar.timespan - 1e-6) setTime(0);
      state.running = true; els.runButton.textContent = 'pause'; state.runLast = now(); ensureLoop(); announce('Running.');
    }
  }
  function runTick() {
    var t = now();
    var span = state.selectedStar.timespan;
    var nt = state.time + span / 50000000 * state.runSpeed * 1000 * (t - state.runLast);
    state.runLast = t;
    if (nt > span) { nt = span; setTime(nt); toggleRunning(); announceState(); return; }
    setTime(nt);
  }

  /* ---------------------------------------------------------------------------
     15. Pointer + keyboard interactions on the canvas stages.
     --------------------------------------------------------------------------- */
  function stageX(stage, ev, w) {
    var r = stage.getBoundingClientRect();
    return (ev.clientX - r.left) * (w / r.width);
  }

  // Planet drag (SHZDiagram.processMouse + onPlanetDragged).
  function processPlanetMouse(mouseXStage) {
    var dragX = mouseXStage + state.planetDragXOffset;
    dragX = clamp(dragX, PLANET_DRAG_MIN_X, PLANET_DRAG_MAX_X);
    var dist = (dragX - STAR_X) / state.scale;
    if (dist > state.dragLimitMax) { dist = state.dragLimitMax; dragX = -1; }
    else if (dist < state.dragLimitMin) { dist = state.dragLimitMin; dragX = -1; }
    if (dist > PLANET_DRAG_MAX_DIST_HARD) { dist = PLANET_DRAG_MAX_DIST_HARD; dragX = -1; }
    else if (dist < PLANET_DRAG_MIN_DIST_HARD) { dist = PLANET_DRAG_MIN_DIST_HARD; dragX = -1; }
    state.planetDragX = dragX;
    return dist;
  }
  function planetDragged(dist) {
    if (state.running) toggleRunning();
    var massRatio = state.selectedStar.mass / getData(state.time).mass;
    state.initDistance = clamp(dist / massRatio, distSliderMin(), distSliderMax());
    if (!state.distFinite) state.initDistance = parseFloat(sigDigitString(state.initDistance, 3));
    else state.initDistance = state.distFinite[distValueIndex()];
    state.dragDistance = dist;
    completeDataTable2();
    syncDistField();
    onTimeChanged();
  }
  function initPlanetDrag() {
    var handle = els.planetHandle;
    handle.addEventListener('pointerdown', function (ev) {
      handle.focus();
      handle.setPointerCapture(ev.pointerId);
      var mx = stageX(els.diagramStage, ev, DIAG_W);
      state.planetDragXOffset = planetX() - mx;
      state.planetDragging = true;
      ev.preventDefault();
    });
    handle.addEventListener('pointermove', function (ev) {
      if (!state.planetDragging) return;
      var mx = stageX(els.diagramStage, ev, DIAG_W);
      var dist = processPlanetMouse(mx);
      planetDragged(dist);
    });
    function end(ev) {
      if (!state.planetDragging) return;
      state.planetDragging = false;
      var mx = stageX(els.diagramStage, ev, DIAG_W);
      var dist = processPlanetMouse(mx);
      planetDragged(dist);
      announcePlanet();
    }
    handle.addEventListener('pointerup', end);
    handle.addEventListener('pointercancel', end);
    handle.addEventListener('keydown', function (ev) {
      var step = 0;
      switch (ev.key) {
        case 'ArrowRight': case 'ArrowUp': step = 1; break;
        case 'ArrowLeft': case 'ArrowDown': step = -1; break;
        case 'PageUp': step = 10; break; case 'PageDown': step = -10; break;
        case 'Home': adjustDistanceToEnd(-1); ev.preventDefault(); return;
        case 'End': adjustDistanceToEnd(1); ev.preventDefault(); return;
        default: return;
      }
      ev.preventDefault();
      adjustDistanceSteps(step);
    });
  }
  // adjust the distance slider by n steps (finite set index, or log param).
  function adjustDistanceSteps(n) {
    if (state.running) toggleRunning();
    var p = parseFloat(els.distSlider.value);
    p = clamp(p + n, parseFloat(els.distSlider.min), parseFloat(els.distSlider.max));
    state.initDistance = distFromParam(p);
    onDistanceChanged(false);
    announcePlanet();
  }
  function adjustDistanceToEnd(dir) {
    if (state.running) toggleRunning();
    state.initDistance = dir < 0 ? distSliderMin() : distSliderMax();
    if (!state.distFinite) state.initDistance = parseFloat(sigDigitString(state.initDistance, 3));
    onDistanceChanged(false);
    announcePlanet();
  }

  // Diagram zoom (SHZDiagram zoomer): horizontal drag + arrow keys.
  function initZoom() {
    var proxy = els.zoomProxy;
    var zoomStartX = 0, zooming = false, baseScale = 1;
    proxy.addEventListener('pointerdown', function (ev) {
      proxy.focus(); proxy.setPointerCapture(ev.pointerId);
      zooming = true; baseScale = state.scale;
      zoomStartX = stageX(els.diagramStage, ev, DIAG_W);
      state.scaleAnimating = false;
      ev.preventDefault();
    });
    proxy.addEventListener('pointermove', function (ev) {
      if (!zooming) return;
      var mx = stageX(els.diagramStage, ev, DIAG_W);
      var f;
      if (mx > zoomStartX) { f = (mx - (zoomStartX + ZOOM_DEAD)) / DIAG_W; f = clamp(f, 0, 1); }
      else { f = (mx - (zoomStartX - ZOOM_DEAD)) / DIAG_W; f = clamp(f, -1, 0); }
      var ns = baseScale * Math.pow(ZOOMER_FACTOR, -f);
      ns = clamp(ns, MIN_ZOOM_SCALE, MAX_ZOOM_SCALE);
      setScale(ns); render();
    });
    function end() {
      if (!zooming) return; zooming = false;
      // re-centre the planet (AS onZoomerMouseUp -> easeToScale to centre)
      var target = (DIAG_W / 2 - STAR_X) / state.planetDistance;
      startScaleEase(target);
      announce('Zoom ' + state.scalebarText + ' scale bar.');
    }
    proxy.addEventListener('pointerup', end);
    proxy.addEventListener('pointercancel', end);
    proxy.addEventListener('keydown', function (ev) {
      var f = 0;
      switch (ev.key) {
        case 'ArrowRight': case 'ArrowUp': f = 1; break;
        case 'ArrowLeft': case 'ArrowDown': f = -1; break;
        case 'PageUp': f = 3; break; case 'PageDown': f = -3; break;
        case 'Home': setScale(MIN_ZOOM_SCALE); render(); ev.preventDefault(); announce('Zoom ' + state.scalebarText + ' scale bar.'); return;
        case 'End': setScale(Math.min(MAX_ZOOM_SCALE, 5000)); render(); ev.preventDefault(); announce('Zoom ' + state.scalebarText + ' scale bar.'); return;
        default: return;
      }
      ev.preventDefault();
      var ns = clamp(state.scale * Math.pow(ZOOMER_FACTOR, f * 0.5), MIN_ZOOM_SCALE, MAX_ZOOM_SCALE);
      setScale(ns); render();
      proxy.setAttribute('aria-valuetext', 'zoom, scale bar ' + state.scalebarText);
      announce('Zoom ' + state.scalebarText + ' scale bar.');
    });
  }

  // Timeline scrubbing + cursor keyboard.
  function initTimeline() {
    var stage = els.timelineStage, cursor = els.timeCursor, scrubbing = false;
    function scrubTo(ev) {
      var mx = stageX(stage, ev, TL_WIDTH);
      var span = state.selectedStar.timespan;
      setTime(clamp(mx * span / TL_WIDTH, 0, span));
    }
    stage.addEventListener('pointerdown', function (ev) {
      if (state.running) toggleRunning();
      cursor.focus();
      scrubbing = true;
      try { stage.setPointerCapture(ev.pointerId); } catch (e) {}
      scrubTo(ev); ev.preventDefault();
    });
    stage.addEventListener('pointermove', function (ev) { if (scrubbing) scrubTo(ev); });
    function end() { if (scrubbing) { scrubbing = false; announceState(); } }
    stage.addEventListener('pointerup', end);
    stage.addEventListener('pointercancel', end);
    cursor.addEventListener('keydown', function (ev) {
      var span = state.selectedStar.timespan;
      switch (ev.key) {
        case 'ArrowRight': case 'ArrowUp': timelineIncrement(1); break;
        case 'ArrowLeft': case 'ArrowDown': timelineIncrement(-1); break;
        case 'PageUp': setTime(state.time + span * 0.05); break;
        case 'PageDown': setTime(state.time - span * 0.05); break;
        case 'Home': setTime(0); break;
        case 'End': setTime(span); break;
        default: return;
      }
      ev.preventDefault();
      announceState();
    });
  }

  /* ---------------------------------------------------------------------------
     16. Screen-reader narration
     --------------------------------------------------------------------------- */
  var liveTimer = null, lastAnnounced = '';
  function announce(msg) {
    if (!msg || msg === lastAnnounced) return;
    lastAnnounced = msg;
    if (liveTimer) clearTimeout(liveTimer);
    liveTimer = setTimeout(function () { els.liveRegion.textContent = msg; }, 120);
  }
  function planetSpoken() {
    return 'planet distance ' + sigDigitString(state.planetDistance, 3) + ' astronomical units, ' + zoneStateWords();
  }
  function zoneStateWords() {
    switch (state.planetFrame) {
      case 'destroyed': return 'planet destroyed';
      case 'tidallyLocked': return 'planet tidally locked';
      case 'tooCold': return 'too cold, outside the habitable zone';
      case 'tooHot': return 'too hot, inside the habitable zone';
      default: return 'in the habitable zone, temperature just right';
    }
  }
  function announcePlanet() {
    announce('Planet distance ' + sigDigitString(state.planetDistance, 3) + ' astronomical units. ' + capitalize(zoneStateWords()) + '.');
  }
  function announceState() {
    var d = state.hrNow || getData(state.time);
    var tp = timeParts(state.time);
    announce('Time ' + tp.num + ' ' + tp.spoken + '. Star ' + getNumberString(pow10(d.logTemp), 3) +
      ' kelvin, luminosity ' + (d.logLum < -5 ? '0' : getNumberString(pow10(d.logLum), 3)) +
      ' solar luminosities. ' + capitalize(zoneStateWords()) + '.');
  }
  function capitalize(s) { return s.charAt(0).toUpperCase() + s.slice(1); }
  function round3(v) { return parseFloat(sigDigitString(v, 3)); }

  function updateAria() {
    // diagram text equivalent
    var d = state.hrNow;
    if (!d) return;
    var tp = timeParts(state.time);
    var zone = state.zoneVisible
      ? ('Habitable zone from ' + getNumberString(state.zoneInner, 3) + ' to ' + getNumberString(state.zoneOuter, 3) + ' astronomical units. ')
      : 'The star is no longer on the main sequence; no habitable zone is shown. ';
    // same information the on-screen arrow conveys
    if (state.zoneArrowHint === 'offscreen')
      zone += 'The habitable zone lies beyond the right edge of the diagram; an arrow points toward it. ';
    else if (state.zoneArrowHint === 'atstar')
      zone += 'The habitable zone is too small to see at this scale, close around the star; an arrow points to it. ';
    els.diagramDesc.textContent =
      'Top-down view of the star system. Star mass ' + getNumberString(d.mass, 3) + ' solar masses, temperature ' +
      getNumberString(pow10(d.logTemp), 3) + ' kelvin, radius ' + getNumberString(pow10(d.logRadius), 3) + ' solar radii. ' +
      'Planet at ' + getNumberString(state.planetDistance, 3) + ' astronomical units, ' + zoneStateWords() + '. ' +
      zone + 'Time since formation ' + tp.num + ' ' + tp.spoken + '. Scale bar ' + (state.scalebarText || '') + '.' +
      (state.showRefOrbits ? ' Solar-system reference orbits shown: Mercury, Venus, Earth, Mars and beyond.' : '');
    els.hrDesc.textContent =
      'Hertzsprung-Russell diagram. The red marker shows the star now at temperature ' +
      getNumberString(pow10(d.logTemp), 3) + ' kelvin and luminosity ' +
      (d.logLum < -5 ? '0' : getNumberString(pow10(d.logLum), 3)) + ' solar luminosities, on its evolutionary track.';
    els.timelineDesc.textContent = 'Timeline from 0 to ' + timeParts(state.selectedStar.timespan).num + ' ' +
      timeParts(state.selectedStar.timespan).spoken + '. Cursor at ' + tp.num + ' ' + tp.spoken + '.';
    els.plotDesc.textContent = 'Plot of planet temperature relative to the habitable zone over time. ' +
      capitalize(zoneStateWords()) + ' now.';
    els.historyDesc.textContent = historyNarration();
  }
  function historyNarration() {
    if (!state.selectedStar) return '';
    var epochs = state.selectedStar.epochsList;
    var out = 'System history bar. Main-sequence hydrogen fusion ends at ' + timeParts(epochs[1].time).num + ' ' + timeParts(epochs[1].time).spoken + '. ';
    if (state.timePlanetTidallyLocked < state.selectedStar.timespan && state.timePlanetTidallyLocked < state.timePlanetDestroyed)
      out += 'Planet becomes tidally locked at ' + timeParts(state.timePlanetTidallyLocked).num + ' ' + timeParts(state.timePlanetTidallyLocked).spoken + '. ';
    if (state.timePlanetDestroyed < state.selectedStar.timespan)
      out += 'Planet is destroyed at ' + timeParts(state.timePlanetDestroyed).num + ' ' + timeParts(state.timePlanetDestroyed).spoken + '. ';
    return out;
  }

  /* ---------------------------------------------------------------------------
     17. Animation loop (run + scale easing) with reduced-motion awareness.
     --------------------------------------------------------------------------- */
  var loopId = null;
  function now() { return (window.performance && performance.now) ? performance.now() : Date.now(); }
  function prefersReducedMotion() {
    return window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches;
  }
  function ensureLoop() { if (loopId == null) loopId = requestAnimationFrame(loop); }
  function loop() {
    loopId = null;
    var busy = false;
    if (state.scaleAnimating) {
      var t = (now() - state.scaleAnimStart) / EASING_TIME;
      if (t >= 1) { setScale(state.scaleTarget); state.scaleAnimating = false; }
      else {
        var e = t * t * (3 - 2 * t); // smoothstep on log(scale)
        var ls = Math.log(state.scaleAnimFrom) + e * (Math.log(state.scaleTarget) - Math.log(state.scaleAnimFrom));
        setScale(Math.exp(ls)); busy = true;
      }
      render();
    }
    if (state.running) { runTick(); busy = true; }
    if (busy || state.scaleAnimating || state.running) ensureLoop();
  }

  /* ---------------------------------------------------------------------------
     18. Reset (MainTimeline.reset) - wired to the masthead "sim-reset" event.
     --------------------------------------------------------------------------- */
  function reset() {
    if (!state.starsList) return;
    state.running = false; els.runButton.textContent = 'run';
    state.innerSHZLimit = 1; state.outerSHZLimit = 2;
    els.systemSelect.value = '0';
    syncToSelectedSystem();                // none selected
    state.initDistance = DEFAULT_DIST;
    state.initStarMass = DEFAULT_MASS;
    els.showGrid.checked = false; state.showGrid = false;
    els.showRefOrbits.checked = true; state.showRefOrbits = true;
    els.rateSlider.value = '12'; state.runSpeed = 12;
    configDistSlider();
    onMassChanged(false);                  // selects the 1.0 Msun track, time=0, tables
    setPlanetDistance(DEFAULT_DIST, false); // centre planet + set scale
    onAssumptionsChanged();                // pessimistic limits + recompute
    syncMassField(); syncDistField();
    onTimeChanged();
    announce('Simulator reset.');
  }

  /* ---------------------------------------------------------------------------
     19. Wiring + init
     --------------------------------------------------------------------------- */
  var dprDiag, dprHR, dprPlot, dprHist, dprTL, ctxTL;
  var UI_FONT = 'Verdana, Geneva, "DejaVu Sans", sans-serif';

  function setupCanvases() {
    var a = setupCanvas(els.diagramCanvas, DIAG_W, DIAG_H); ctxDiag = a.ctx; dprDiag = a.dpr;
    var b = setupCanvas(els.hrCanvas, HR_W, HR_H); ctxHR = b.ctx; dprHR = b.dpr;
    var c = setupCanvas(els.plotCanvas, PLOT_W, PLOT_H); ctxPlot = c.ctx; dprPlot = c.dpr;
    var e = setupCanvas(els.historyCanvas, HIST_W, HIST_H); ctxHist = e.ctx; dprHist = e.dpr;
    var f = setupCanvas(els.timelineCanvas, TL_WIDTH, TL_HEIGHT + 20); ctxTL = f.ctx; dprTL = f.dpr;
  }

  function loadImages() {
    hrImage = new Image();
    hrImage.onload = function () { hrImageReady = true; if (state.selectedStar) render(); };
    hrImage.src = 'assets/hr-background.jpg';
    Object.keys(planetLabelMap).forEach(function (key) {
      var name = planetLabelMap[key];
      var img = new Image();
      img.onload = function () { planetReady++; if (state.selectedStar) render(); };
      img.src = 'assets/' + name + '.png';
      planetImgs[name] = img;
    });
  }

  function wireControls() {
    // system selector
    els.systemSelect.addEventListener('change', onSystemChanged);

    // mass slider + field
    els.massSlider.addEventListener('input', function () {
      state.initStarMass = massFromIndex(parseInt(els.massSlider.value, 10));
      onMassChanged(true);
    });
    els.massField.addEventListener('change', function () {
      var v = parseFloat(els.massField.value);
      if (isFinite(v)) { state.initStarMass = massFromIndex(nearestMassIndex(v)); onMassChanged(true); }
      else syncMassField();
    });

    // distance slider + field
    els.distSlider.addEventListener('input', function () {
      state.initDistance = distFromParam(parseFloat(els.distSlider.value));
      onDistanceChanged(true);
    });
    els.distField.addEventListener('change', function () {
      var v = parseFloat(els.distField.value);
      if (isFinite(v)) {
        if (state.distFinite) { // snap to nearest perihelion
          var best = state.distFinite[0], bd = Infinity;
          state.distFinite.forEach(function (d) { var dd = Math.abs(d - v); if (dd < bd) { bd = dd; best = d; } });
          state.initDistance = best;
        } else state.initDistance = parseFloat(sigDigitString(clamp(v, MIN_DIST_T0, MAX_DIST_T0), 3));
        onDistanceChanged(true);
      } else syncDistField();
    });

    // checkboxes
    els.showGrid.addEventListener('change', function () { state.showGrid = els.showGrid.checked; render(); announce(state.showGrid ? 'Scale grid shown.' : 'Scale grid hidden.'); });
    els.showRefOrbits.addEventListener('change', function () { state.showRefOrbits = els.showRefOrbits.checked; render(); updateAria(); announce(state.showRefOrbits ? 'Solar system orbits shown.' : 'Solar system orbits hidden.'); });

    // run / pause + rate
    els.runButton.addEventListener('click', function () { toggleRunning(); });
    els.rateSlider.addEventListener('input', function () {
      state.runSpeed = parseFloat(els.rateSlider.value);
      els.rateSlider.setAttribute('aria-valuetext', 'rate ' + state.runSpeed.toFixed(1) + ' (relative animation speed)');
    });

    initPlanetDrag();
    initZoom();
    initTimeline();

    document.addEventListener('sim-reset', reset);

    // keep the run clock honest when returning to a hidden tab
    document.addEventListener('visibilitychange', function () {
      if (document.visibilityState === 'visible') state.runLast = now();
    });

    window.addEventListener('resize', function () { setupCanvases(); if (state.selectedStar) { render(); drawTimeline(); positionTimeCursor(); } });
  }

  function buildStar(raw) {
    var flat = raw.rawDataTable, rows = flat.length / 5, tab = new Array(rows);
    for (var i = 0; i < rows; i++) {
      var o = i * 5;
      tab[i] = {
        time: flat[o], mass: flat[o + 1], logLum: flat[o + 2], logRadius: flat[o + 3], logTemp: flat[o + 4],
        shzInner: 1, shzOuter: 1, shzTemp: 1, distance: 1
      };
    }
    return { mass: raw.mass, timespan: raw.timespan, epochsList: raw.epochsList, dataTable: tab };
  }

  function init() {
    setupCanvases();
    loadImages();
    wireControls();
    els.rateSlider.setAttribute('aria-valuetext', 'rate 12.0 (relative animation speed)');

    fetch('assets/shzStars.json')
      .then(function (r) { if (!r.ok) throw new Error('HTTP ' + r.status); return r.json(); })
      .then(function (data) {
        state.starsList = data.map(buildStar);
        state.masses = state.starsList.map(function (s) { return s.mass; }).sort(function (a, b) { return a - b; });
        reset();
      })
      .catch(function (err) {
        els.diagramDesc.textContent = 'Could not load the stellar data (' + err.message +
          '). This simulator must be served over HTTP, not opened from a file path.';
        announce('Error loading stellar data. Serve the simulator over HTTP.');
        // surface a visible message on the diagram
        ctxDiag.setTransform(dprDiag, 0, 0, dprDiag, 0, 0);
        ctxDiag.fillStyle = '#000'; ctxDiag.fillRect(0, 0, DIAG_W, DIAG_H);
        ctxDiag.fillStyle = '#fff'; ctxDiag.font = '16px ' + UI_FONT; ctxDiag.textAlign = 'center';
        ctxDiag.fillText('Could not load stellar data — serve this page over HTTP.', DIAG_W / 2, DIAG_H / 2);
      });
  }

  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', init);
  else init();
})();
