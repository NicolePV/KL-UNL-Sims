"use strict";
/* ============================================================================
 * Small-Angle Approximation Demonstrator  -  HTML5 / KL-UNL accessible conversion
 * Source: smallAngleDemo003.swf / .fla  (astro.unl.edu), decompiled with JPEXS.
 *
 * GOAL A (functional parity): the model below is a verbatim port of the original
 *   ActionScript-1 prototype classes (SmallAngleDemo.as, Cubic Easing Class.as,
 *   drawArc.as, toFixed.as, Slider Logic Class v6.as). Every constant, formula,
 *   and number format is copied unchanged from the source:
 *     centerY = 193, originX = 42, arcRadius = 200, rInPixels = 14.73,
 *     ease time = 300 ms, alpha(arcsec) = 206265 * diameter / distance.
 *   The observer (person) and ball are the EXPORTED bitmaps, reused as-is.
 *
 * GOAL B (accessible KL-UNL presentation): the original canvas-drawn chrome
 *   (title bar, panel, slider widgets, preset buttons, About dialog) is NOT
 *   reproduced pixel-for-pixel. The sim lives in the shared KL-UNL shell: the
 *   <kl-unl-masthead> supplies title + Reset / About; panels use the foundation
 *   CSS classes; every control is a native, fully keyboard-operable element. Only
 *   the genuinely code-drawn art (tangent lines, the angle arc) is drawn on the
 *   <canvas>, compositing the reused person/ball bitmaps. The equation and the
 *   angle label alpha are real HTML typeset by MathJax (klunlShowEquation).
 *
 * Timing: getTimer() -> performance.now()-relative ms (original 300 ms constants
 * kept). onEnterFrame -> a single requestAnimationFrame loop, run only while an
 * ease is in progress.
 * ========================================================================== */

(function () {

  const _t0 = performance.now();
  function getTimer() { return performance.now() - _t0; }   // ms since load (Flash getTimer)

  /* =========================================================================
   * SECTION 1 -- VERBATIM HELPERS
   * ======================================================================= */

  // Number.prototype.toFixed polyfill (toFixed.as) -- round-half-up, matches source.
  function toFixed(x, f) {
    f = parseInt(f, 10);
    if (f < 0 || f > 20) return "Range Error";
    if (isNaN(x)) return "NaN";
    let s = "";
    if (x < 0) { s = "-"; x = -x; }
    let m = "";
    if (x < 1e21) {
      const n = Math.round(x * Math.pow(10, f));
      m = (n === 0) ? "0" : n.toString();
      if (f > 0) {
        let k = m.length;
        if (k <= f) {
          let z = "";
          for (let i = 0; i < f + 1 - k; i++) z += "0";
          m = z + m; k = f + 1;
        }
        const a = m.substr(0, k - f);
        const b = m.substr(k - f);
        m = a + "." + b;
      }
    } else {
      m = x.toString();
    }
    return s + m;
  }

  // drawArc.as -- tessellated arc via quadratic curves. AS screen-Y-down with sin
  // negated (y - r*sin), reproduced exactly so the geometry matches.
  const TWO_PI = 6.283185307179586;
  function drawArc(ctx, x, y, radius, startAngle, endAngle) {
    if (startAngle === undefined) {
      startAngle = 0; endAngle = TWO_PI;
    } else {
      startAngle = (startAngle < 0) ? (startAngle % TWO_PI + TWO_PI) : (startAngle % TWO_PI);
      endAngle   = (endAngle   < 0) ? (endAngle   % TWO_PI + TWO_PI) : (endAngle   % TWO_PI);
    }
    let range = endAngle - startAngle;
    if (range < 0) range = TWO_PI + range;
    const maxArcStep = 0.5;
    const n = Math.ceil(range / maxArcStep);
    const step = range / n;
    const half = step / 2;
    const cRadius = radius / Math.cos(half);
    let a3 = startAngle;
    let a2 = startAngle - half;
    ctx.moveTo(x + radius * Math.cos(startAngle), y - radius * Math.sin(startAngle));
    for (let i = 0; i < n; i++) {
      a3 += step; a2 += step;
      ctx.quadraticCurveTo(x + cRadius * Math.cos(a2), y - cRadius * Math.sin(a2),
                           x + radius * Math.cos(a3), y - radius * Math.sin(a3));
    }
  }

  // Cubic Easing Class.as -- natural cubic spline easer (verbatim port). Eases the
  // distance / diameter from the current value to a target over the ease time,
  // preserving current velocity. Used by the preset buttons.
  function CubicEasingClass(initValue) {
    this.slope1 = 0;
    this.xEnd = 1;
    this.init(initValue);
  }
  CubicEasingClass.prototype.init = function (initValue) {
    this.setTarget(0, initValue, 1, initValue);
  };
  CubicEasingClass.prototype.setTarget = function (xStart, yStart, xTarget, yTarget) {
    let y0 = yStart;
    if (y0 == null) {
      y0 = this.getValue(xStart);
      this.slope0 = this.getDerivative(xStart);
    } else {
      this.slope0 = 0;
    }
    this.splinePointsList = [{ x: xStart, y: y0 }, { x: xTarget, y: yTarget }];
    this.doComputations();
    this.targetValue = yTarget;
    this.xEnd = xTarget;
  };
  CubicEasingClass.prototype.getValue = function (x) {
    const p = this.parametersList;
    const n = p.length;
    let i = 0;
    while (i < n) { if (x < p[i].xUpper) break; i++; }
    if (i < n) return p[i].d + x * (p[i].c + x * (p[i].b + x * p[i].a));
    return this.targetValue;
  };
  CubicEasingClass.prototype.getDerivative = function (x) {
    const p = this.parametersList;
    const n = p.length;
    let i = 0;
    while (i < n) { if (x < p[i].xUpper) break; i++; }
    if (i < n) return p[i].c + x * (2 * p[i].b + 3 * x * p[i].a);
    return 0;
  };
  CubicEasingClass.prototype.doComputations = function () {
    const L = this.splinePointsList;
    L.sort(this.pointsCompareFunc);
    const n = L.length, n_1 = n - 1, n_2 = n - 2;
    const m0 = this.slope0, m1 = this.slope1;
    const uL = [];
    L[0].d2 = -0.5;
    uL[0] = 3 / (L[1].x - L[0].x) * ((L[1].y - L[0].y) / (L[1].x - L[0].x) - m0);
    for (let i = 1; i < n_1; i++) {
      const sig = (L[i].x - L[i - 1].x) / (L[i + 1].x - L[i - 1].x);
      const pp = sig * L[i - 1].d2 + 2;
      L[i].d2 = (sig - 1) / pp;
      uL[i] = (L[i + 1].y - L[i].y) / (L[i + 1].x - L[i].x) - (L[i].y - L[i - 1].y) / (L[i].x - L[i - 1].x);
      uL[i] = (6 * uL[i] / (L[i + 1].x - L[i - 1].x) - sig * uL[i - 1]) / pp;
    }
    const qn = 0.5;
    const un = 3 / (L[n_1].x - L[n_2].x) * (m1 - (L[n_1].y - L[n_2].y) / (L[n_1].x - L[n_2].x));
    L[n_1].d2 = (un - qn * uL[n_2]) / (qn * L[n_2].d2 + 1);
    for (let k = n_2; k >= 0; k--) L[k].d2 = L[k].d2 * L[k + 1].d2 + uL[k];
    const cL = [];
    for (let i = 0; i < n_1; i++) {
      const p1 = L[i], p2 = L[i + 1];
      const p1d2 = p1.d2, p2d2 = p2.d2;
      const x1 = p1.x, x2 = p2.x, p1y = p1.y, p2y = p2.y;
      const h = x2 - x1;
      const a = (p2d2 - p1d2) / (6 * h);
      const b = (3 * x2 * p1d2 - 3 * p2d2 * x1) / (6 * h);
      const c = (-6 * p1y + 2 * x2 * p2d2 * x1 - x2 * x2 * p2d2 - 2 * x2 * p1d2 * x1 + p1d2 * x1 * x1 - 2 * x2 * x2 * p1d2 + 6 * p2y + 2 * p2d2 * x1 * x1) / (6 * h);
      const d = (-2 * p2d2 * x2 * x1 * x1 + 2 * p1d2 * x2 * x2 * x1 + p2d2 * x2 * x2 * x1 - 6 * p2y * x1 + 6 * p1y * x2 - p1d2 * x2 * x1 * x1) / (6 * h);
      cL.push({ xUpper: x2, a: a, b: b, c: c, d: d });
    }
    this.parametersList = cL;
  };
  CubicEasingClass.prototype.pointsCompareFunc = function (a, b) {
    if (a.x < b.x) return -1;
    if (a.x > b.x) return 1;
    return 0;
  };

  /* =========================================================================
   * SECTION 2 -- CONSTANTS (verbatim from SmallAngleDemo.as)
   * ======================================================================= */
  const centerY   = 193;
  const originX   = 42;
  const arcRadius = 200;
  const rInPixels = 14.73;        // pixels per unit
  const distanceEaseTime = 300;   // ms
  const diameterEaseTime = 300;   // ms

  // Slider ranges (PlaceObject initialize blocks): distance 20..60, diameter 1..3,
  // both "fixed digits" precision 1 -> snapped to 0.1.
  const DIST_MIN = 20, DIST_MAX = 60;
  const DIA_MIN  = 1,  DIA_MAX  = 3;
  const STEP = 0.1;

  // Initial state (onReset): distance = 40, diameter = 2.
  const INIT_DISTANCE = 40;
  const INIT_DIAMETER = 2;

  // Canvas: keep the original internal stage coordinates. The visible band is a
  // tight window (VIEW_TOP..VIEW_TOP+BASE_H) around the diagram; drawing math is
  // unchanged and uses the absolute internal coords above. The band is chosen so
  // the whole setup (observer head/feet, rays, ball, arc, alpha label) is centered
  // vertically with roughly equal top/bottom margins.
  const BASE_W = 960;
  const VIEW_TOP = 156;
  const BASE_H = 148;

  // Reused exported person bitmap (sprites/DefineSprite_66). The export faces LEFT
  // (away from the ball), so it is drawn flipped horizontally to face the ball on
  // the right. The eye/sextant pixel is anchored to the observer origin
  // (originX, centerY) so the triangle's vertex (the tangent rays) originates from
  // the eye. Eye-point measured from the export.
  const PERSON_SCALE = 0.18;
  const PERSON_EYE_X = 95;   // px within the 200x591 export (eye / sextant eyepiece)
  const PERSON_EYE_Y = 41;

  // The angle is drawn as a small arc at the vertex (standard angle notation),
  // not at the original 200 px radius (which, for these small angles, rendered as
  // a near-vertical line floating mid-diagram). Physics is unchanged: the arc still
  // spans the true half-angle +/- theta; only the marker's display radius differs.
  // Recorded as a presentational deviation in CONVERSION_NOTES.md.
  const ANGLE_MARK_R = 54;   // display radius of the angle arc (internal px)

  // Colors. Original: tangent lines 0xA0A0A0 (=10526880), arc 0x000000. The light
  // grey fails WCAG 1.4.11 (>=3:1) against white, so it is darkened; the arc maps to
  // the foreground charcoal. See ACCESSIBILITY.md. Color is never the only signal
  // (every quantity is also given as text/equation).
  const TANGENT_COLOR = "#5f5f5f";   // remap of 0xA0A0A0 for contrast
  const ARC_COLOR     = "#1a1a1a";   // 0x000000 -> --foreground-color

  /* =========================================================================
   * SECTION 3 -- STATE + EASERS
   * ======================================================================= */
  // state = immediate values (drive slider, ARIA, readouts, equation).
  // disp  = eased display values (drive ONLY the canvas drawing) so the ball/rays/
  //         arc glide. The original Flash eased preset transitions; per request the
  //         easing now also applies to slider and ball-drag changes. Easing the
  //         picture (not the form controls) keeps the slider fully accessible.
  const state = { distance: INIT_DISTANCE, diameter: INIT_DIAMETER };
  const disp  = { distance: INIT_DISTANCE, diameter: INIT_DIAMETER };
  const distanceEaser = new CubicEasingClass(INIT_DISTANCE);
  const diameterEaser = new CubicEasingClass(INIT_DIAMETER);
  let animating = false;

  function snap(v, lo, hi) {
    if (v < lo) v = lo; else if (v > hi) v = hi;       // clamp (getValueObjectFromValue)
    return Math.round(v / STEP) * STEP;                // then snap to 0.1
  }

  /* =========================================================================
   * SECTION 4 -- DOM
   * ======================================================================= */
  const canvas = document.getElementById("stage-canvas");
  const ctx = canvas.getContext("2d");
  const stageEl = canvas.parentElement;               // .sim-canvas-stage (position:relative)
  const alphaLabel = document.getElementById("alpha-label");
  const distRange = document.getElementById("distance-range");
  const diaRange  = document.getElementById("diameter-range");
  const distValue = document.getElementById("distance-value");
  const diaValue  = document.getElementById("diameter-value");
  const stageDesc = document.getElementById("stage-desc");

  const reduceMotion = window.matchMedia("(prefers-reduced-motion: reduce)");

  const personImg = new Image();
  const ballImg = new Image();
  let imagesLoaded = 0;
  function onImg() { imagesLoaded++; if (imagesLoaded === 2) draw(); }
  personImg.onload = onImg; ballImg.onload = onImg;
  personImg.src = "assets/person.png";
  ballImg.src = "assets/ball.png";

  // Last arc-endpoint (internal coords) for positioning the alpha label.
  const alphaPos = { x: originX + arcRadius, y: centerY };

  /* =========================================================================
   * SECTION 5 -- CANVAS SIZING (HiDPI; stage coordinates unchanged)
   * ======================================================================= */
  function setupCanvas() {
    const dpr = window.devicePixelRatio || 1;
    canvas.width = Math.round(BASE_W * dpr);
    canvas.height = Math.round(BASE_H * dpr);
    canvas.style.aspectRatio = BASE_W + " / " + BASE_H;
  }

  /* =========================================================================
   * SECTION 6 -- RENDER (single source of truth: state -> canvas + DOM + live)
   * ======================================================================= */
  function refresh() {
    draw();
    updateReadouts();
  }

  function draw() {
    const dpr = window.devicePixelRatio || 1;
    // Map internal coords to device px, shifting the visible window to VIEW_TOP.
    ctx.setTransform(dpr, 0, 0, dpr, 0, -VIEW_TOP * dpr);
    ctx.clearRect(0, VIEW_TOP, BASE_W, BASE_H);

    // Geometry (SmallAngleDemo.refresh) -----------------------------------
    // The canvas draws from the EASED display values (disp) so the ball, rays,
    // arc, and alpha glide smoothly. The HTML readouts/slider/aria use the
    // immediate values (state) -- see updateReadouts -- so they stay accurate and
    // accessible while the picture catches up.
    const distPx = rInPixels * disp.distance;           // distance in px
    const pr = rInPixels * disp.diameter / 2;           // ball radius in px
    const ballX = originX + distPx;
    const theta = Math.asin(pr / distPx);               // half-angle
    const a = Math.sqrt(distPx * distPx - pr * pr);     // dist to tangent point
    const ax = originX + a * Math.cos(theta);
    const ay = a * Math.sin(theta);

    // Observer (reused exported bitmap), flipped to face the ball and anchored so
    // the eye sits at the vertex (originX, centerY). Drawn first (behind the rays).
    if (personImg.complete && personImg.naturalWidth) {
      ctx.save();
      ctx.translate(originX, centerY);
      ctx.scale(-PERSON_SCALE, PERSON_SCALE);   // negative X mirrors the image
      ctx.drawImage(personImg, -PERSON_EYE_X, -PERSON_EYE_Y,
        personImg.naturalWidth, personImg.naturalHeight);
      ctx.restore();
    }

    // Tangent lines (lineStyle(1, 0xA0A0A0) -> remapped color).
    ctx.lineCap = "round";
    ctx.lineJoin = "round";
    ctx.strokeStyle = TANGENT_COLOR;
    ctx.lineWidth = 1;
    ctx.beginPath();
    ctx.moveTo(ax, centerY + ay);
    ctx.lineTo(originX, centerY);
    ctx.lineTo(ax, centerY - ay);
    ctx.stroke();

    // Angle arc at the vertex (lineStyle(3, 0) -> charcoal), spanning -theta..theta.
    ctx.strokeStyle = ARC_COLOR;
    ctx.lineWidth = 2;
    ctx.beginPath();
    drawArc(ctx, originX, centerY, ANGLE_MARK_R, -theta, theta);
    ctx.stroke();

    // Ball (reused exported bitmap), scaled to displayed diameter = 2*pr, on top.
    const bd = 2 * pr;
    if (ballImg.complete && ballImg.naturalWidth) {
      ctx.drawImage(ballImg, ballX - bd / 2, centerY - bd / 2, bd, bd);
    }

    // Alpha label sits just OUTSIDE the arc, above the upper ray so it never cuts a
    // line. (alphaMC position, adapted for the vertex-arc presentation.)
    alphaPos.x = originX + (ANGLE_MARK_R + 16) * Math.cos(theta);
    alphaPos.y = centerY - (ANGLE_MARK_R + 16) * Math.sin(theta) - 18;
    positionAlpha();
  }

  // Place the (HTML, MathJax) alpha label over the scaled canvas.
  function positionAlpha() {
    const scale = canvas.clientWidth / BASE_W;
    if (!scale || !isFinite(scale)) return;
    const cssX = alphaPos.x * scale;
    const cssY = (alphaPos.y - VIEW_TOP) * scale;
    alphaLabel.style.left = cssX + "px";
    alphaLabel.style.top = cssY + "px";
  }

  let _lastEqn = "";
  function updateReadouts() {
    // alpha (arcsec) = 206265 * diameter / distance, formatted toFixed(1).
    const approxAlpha = 206265 * state.diameter / state.distance;
    const valStr = toFixed(approxAlpha, 1);
    const dStr = toFixed(state.diameter, 1);
    const rStr = toFixed(state.distance, 1);

    // Slider value outputs (visual).
    distValue.textContent = rStr;
    diaValue.textContent = dStr;

    // Spoken value WITH unit for the sliders (the <label> gives the quantity name).
    // Kept in sync with the visible value/precision so screen readers never read a
    // bare number. "units" is the sim's own unit word.
    distRange.setAttribute("aria-valuetext", rStr + " units");
    diaRange.setAttribute("aria-valuetext", dStr + " units");

    // Equation (constant "206,265" verbatim from the source; words "linear
    // diameter" / "distance" verbatim). Only re-typeset when the string changes.
    const latex = "\\[ \\alpha = 206{,}265 \\times \\dfrac{\\text{linear diameter}}{\\text{distance}} = " +
                  valStr + "\\ \\text{arcsec} \\]";
    if (latex !== _lastEqn) {
      _lastEqn = latex;
      const srMsg = "Alpha equals 206,265 times linear diameter over distance, equals " +
                    valStr + " arcseconds, for a linear diameter of " + dStr +
                    " units and a distance of " + rStr + " units.";
      klunlShowEquation(["angle-eqn", latex], ["angle-eqn-sr", srMsg]);
    }
  }

  // Live-region announcement of the diagram state (on commit, not per tick).
  function announce() {
    const valStr = toFixed(206265 * state.diameter / state.distance, 1);
    stageDesc.textContent =
      "Ball of linear diameter " + toFixed(state.diameter, 1) + " units at a distance of " +
      toFixed(state.distance, 1) + " units. Angular size by the small-angle approximation: " +
      valStr + " arcseconds.";
  }

  /* =========================================================================
   * SECTION 7 -- BEHAVIOR (ported from SmallAngleDemo.as)
   * ======================================================================= */
  function syncDistanceUI() { distRange.value = String(state.distance); }
  function syncDiameterUI() { diaRange.value = String(state.diameter); }

  // applyDistance / applyDiameter: set the immediate value (snap + update slider,
  // ARIA, readouts), then either EASE the canvas toward it (animate) or jump the
  // canvas there instantly. Used by the slider, the ball drag, and the presets.
  function applyDistance(x, animate) {
    state.distance = snap(x, DIST_MIN, DIST_MAX);
    syncDistanceUI();
    updateReadouts();
    if (animate && !reduceMotion.matches) {
      const now = getTimer();
      distanceEaser.setTarget(now, null, now + distanceEaseTime, state.distance);
      ensureAnimating();
    } else {
      distanceEaser.init(state.distance);
      disp.distance = state.distance;
      draw();
    }
  }
  function applyDiameter(d, animate) {
    state.diameter = snap(d, DIA_MIN, DIA_MAX);
    syncDiameterUI();
    updateReadouts();
    if (animate && !reduceMotion.matches) {
      const now = getTimer();
      diameterEaser.setTarget(now, null, now + diameterEaseTime, state.diameter);
      ensureAnimating();
    } else {
      diameterEaser.init(state.diameter);
      disp.diameter = state.diameter;
      draw();
    }
  }

  // easeOnEnterFrame -> rAF loop, run only while an ease is active. It advances the
  // eased DISPLAY values (disp) and redraws the canvas; the HTML readouts already
  // reflect the immediate state and are not touched per-frame.
  function ensureAnimating() {
    if (animating) return;
    animating = true;
    requestAnimationFrame(animTick);
  }
  function animTick() {
    const now = getTimer();
    disp.distance = distanceEaser.getValue(now);
    disp.diameter = diameterEaser.getValue(now);
    draw();

    if (now >= distanceEaser.xEnd && now >= diameterEaser.xEnd) {
      animating = false;
      disp.distance = state.distance;   // land exactly on the committed value
      disp.diameter = state.diameter;
      draw();
    } else {
      requestAnimationFrame(animTick);
    }
  }

  // onReset: restore the exact initial state (distance 40, diameter 2), no ease.
  function onReset() {
    animating = false;
    state.distance = INIT_DISTANCE;
    state.diameter = INIT_DIAMETER;
    disp.distance = INIT_DISTANCE;
    disp.diameter = INIT_DIAMETER;
    distanceEaser.init(INIT_DISTANCE);
    diameterEaser.init(INIT_DIAMETER);
    syncDistanceUI();
    syncDiameterUI();
    refresh();
    announce();
  }

  /* =========================================================================
   * SECTION 8 -- BALL DRAG (pointer) + keyboard parity via the sliders
   * ======================================================================= */
  // The distance slider IS the keyboard-operable equivalent of dragging the ball
  // (both mutate state.distance). Pointer + touch share one path (Pointer Events).
  let dragging = false;
  let xOffset = 0;

  function toInternal(ev) {
    const rect = canvas.getBoundingClientRect();
    return {
      x: (ev.clientX - rect.left) / rect.width * BASE_W,
      y: (ev.clientY - rect.top) / rect.height * BASE_H + VIEW_TOP
    };
  }
  function ballGeom() {
    // Use the DRAWN (eased) position so hit-testing matches the ball you can see.
    const distPx = rInPixels * disp.distance;
    const pr = rInPixels * disp.diameter / 2;
    return { x: originX + distPx, y: centerY, r: pr };
  }
  let dragPointerId = null;

  canvas.addEventListener("pointerdown", function (ev) {
    // Only the primary (left / single-finger) button starts a drag; ignore
    // right/middle clicks (mouse) so the context menu still works (Safari/macOS).
    if (ev.button != null && ev.button > 0) return;
    const p = toInternal(ev);
    const b = ballGeom();
    const grab = Math.max(b.r + 4, 16);                // small balls still grabbable
    if (Math.hypot(p.x - b.x, p.y - b.y) <= grab) {
      dragging = true;
      dragPointerId = ev.pointerId;
      xOffset = p.x - b.x;                             // AS: _xmouse - _x
      // Pointer capture is a best-effort nicety; the window-level listeners below
      // drive the drag regardless, so behavior is identical even where capture
      // is flaky (older WebKit). Hence the try/catch.
      try { canvas.setPointerCapture(ev.pointerId); } catch (e) {}
      canvas.style.cursor = "grabbing";
      ev.preventDefault();
    }
  });

  // Hover cursor only (when not dragging) -- on the canvas itself.
  canvas.addEventListener("pointermove", function (ev) {
    if (dragging) return;
    const p = toInternal(ev);
    const b = ballGeom();
    canvas.style.cursor =
      (Math.hypot(p.x - b.x, p.y - b.y) <= Math.max(b.r + 4, 16)) ? "grab" : "default";
  });

  // The actual drag is handled at the window level so it keeps tracking even if
  // the pointer leaves the canvas and regardless of pointer-capture quirks. One
  // code path serves mouse, touch, and pen on every browser (Safari included).
  window.addEventListener("pointermove", function (ev) {
    if (!dragging || (dragPointerId !== null && ev.pointerId !== dragPointerId)) return;
    const p = toInternal(ev);
    // AS: setDistance((_xmouse - xOffset - originX) / rInPixels). Animated so the
    // ball eases toward the pointer (per request to ease drag too).
    applyDistance((p.x - xOffset - originX) / rInPixels, true);
    ev.preventDefault();
  }, { passive: false });

  function endDrag(ev) {
    if (!dragging || (dragPointerId !== null && ev.pointerId !== dragPointerId)) return;
    dragging = false;
    dragPointerId = null;
    canvas.style.cursor = "grab";
    try { canvas.releasePointerCapture(ev.pointerId); } catch (e) {}
    announce();
  }
  window.addEventListener("pointerup", endDrag);
  window.addEventListener("pointercancel", endDrag);

  /* =========================================================================
   * SECTION 9 -- CONTROL WIRING
   * ======================================================================= */
  // Sliders: 'input' updates live and eases the picture; 'change' commits (announce).
  distRange.addEventListener("input", function () { applyDistance(parseFloat(distRange.value), true); });
  distRange.addEventListener("change", function () { applyDistance(parseFloat(distRange.value), true); announce(); });
  diaRange.addEventListener("input", function () { applyDiameter(parseFloat(diaRange.value), true); });
  diaRange.addEventListener("change", function () { applyDiameter(parseFloat(diaRange.value), true); announce(); });

  // Preset buttons -> ease the picture to the preset value (the original changeHandlers).
  document.querySelectorAll(".sim-preset").forEach(function (btn) {
    // Descriptive accessible name so the screen reader speaks the quantity + value
    // + unit instead of a bare number ("20" -> "Set distance to 20 units").
    const kind = btn.getAttribute("data-kind");
    const val = btn.getAttribute("data-value");
    btn.setAttribute("aria-label", "Set " + kind + " to " + val + " units");
    btn.addEventListener("click", function () {
      const v = parseFloat(btn.getAttribute("data-value"));
      if (kind === "distance") applyDistance(v, true);
      else applyDiameter(v, true);
      announce();
    });
  });

  // Reset comes from the shared masthead (sim-reset event).
  document.addEventListener("sim-reset", onReset);

  // Keep the alpha label aligned (and backing crisp) on resize / zoom.
  window.addEventListener("resize", function () { setupCanvas(); refresh(); });

  /* =========================================================================
   * SECTION 9b -- KEEP MATHJAX OUT OF THE TAB ORDER
   * =========================================================================
   * With the menu enabled, MathJax makes every mjx-container focusable
   * (tabindex="0"). That put the decorative angle label alpha (and the
   * aria-hidden equation) into the keyboard tab order. We set tabindex="-1" on
   * the sim's MathJax containers so tabbing skips them. Right-clicking still
   * opens the MathJax context menu (we don't touch the contextmenu handler).
   */
  function suppressMathTabstops() {
    document.querySelectorAll("mjx-container[tabindex]").forEach(function (c) {
      if (c.getAttribute("tabindex") !== "-1") c.setAttribute("tabindex", "-1");
    });
  }
  const _mjxObserver = new MutationObserver(suppressMathTabstops);
  _mjxObserver.observe(document.body, {
    childList: true, subtree: true, attributes: true, attributeFilter: ["tabindex"]
  });

  /* =========================================================================
   * SECTION 10 -- BOOT
   * ======================================================================= */
  // Redefine the foundation hook (per the KL-UNL contract) to initialize equations.
  window.klunlInitEqn = function () { _lastEqn = ""; updateReadouts(); };

  let _booted = false;
  function boot() {
    if (_booted) return;
    _booted = true;
    setupCanvas();
    syncDistanceUI();
    syncDiameterUI();
    refresh();
    announce();
    suppressMathTabstops();
  }

  // Boot once MathJax is ready (so equation + alpha label typeset), with fallbacks.
  if (window.MathJax && window.MathJax.startup && window.MathJax.startup.promise) {
    window.MathJax.startup.promise.then(boot, boot);
  } else if (document.readyState !== "loading") {
    boot();
  } else {
    document.addEventListener("DOMContentLoaded", boot);
  }
})();
