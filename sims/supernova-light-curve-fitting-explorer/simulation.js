/* =====================================================================
   Supernova Light Curve Fitting Explorer
   HTML5 port of the decompiled Adobe Flash simulation (snCurveExplorer007,
   12 November 2009), built on the shared KL-UNL foundation.

   BEHAVIOUR PARITY: all constants, tables and formulas below are copied
   VERBATIM from the ActionScript source (scripts/"SN Curve Fitting
   Explorer.as", "HR Horizontal Bar.as", "Draggable Area.as",
   DefineSprite_194 calculator script, "Supernova Data.as").
   Only the presentation is modernised.

   Coordinate system: the plot keeps the original internal Flash stage
   units (460 x 325); the canvas draws in those logical units (plus a
   12-unit margin for the outward tick marks) and CSS scales it. Pointer
   coordinates are mapped back through the live scale so the drag math
   matches the AS source at any display size.
   ===================================================================== */
(function () {
  "use strict";

  /* ------------------------------------------------------------------ *
   * 1. CONSTANTS (verbatim from the AS source)                          *
   * ------------------------------------------------------------------ */
  var LN10 = 2.302585092994046;         // the exact constant used in AS

  var PEAK_ABS_MAG = -19.5;             // p.peakAbsMag
  var TIME_RANGE   = 450;               // p.timeRange (days across the plot)
  var TIME_AT_LEFT = -50;               // p.timeAtLeft (day at the left edge)
  var LABELLED_TICKS   = [-50, 0, 50, 100, 150, 200, 250, 300, 350, 400];
  var UNLABELLED_TICKS = [-25, 25, 75, 125, 175, 225, 275, 325, 375];

  // Plot geometry: the Draggable Area is initialised with width 460,
  // height 325 and sits exactly over the plot, so these ARE the plot dims.
  var PLOT_W = 460, PLOT_H = 325;
  var MARGIN = 12;                      // canvas margin for outward ticks
  var PX_PER_DAY = PLOT_W / TIME_RANGE;

  // Y axis: setYAxisType("absBolMag", -22, -10). -22 is at the TOP.
  var Y_MIN = -22, Y_MAX = -10;
  var Y_RANGE = Y_MAX - Y_MIN;          // 12 magnitudes
  var Y_LABEL_MULTIPLE = 2;             // absBolMagLabelMultiple

  // Horizontal drag limits (pixels): minXOffset = 0, maxXOffset = 200.
  var X_OFF_MIN = 0, X_OFF_MAX = 200;

  // Colours (AS decimal colour ints).
  var COL_RED  = "#d02c30";             // 13643824: curve + absolute axis
  var COL_BLUE = "#1d5ef3";             // 1924851:  data dots + apparent axis
  var COL_AXIS = "#1a1a1a";             // time axis / border (AS 0, via palette)
  var DOT_R = 1.5;                      // HRDiagramDot dotSize 3 -> radius 1.5

  // Theoretical Type Ia light-curve template (verbatim from init()):
  // local-unit scale factors and quadratic Bezier control/anchor points.
  var CURVE_KX = 1.205141938939475 * (PLOT_W / TIME_RANGE);
  var CURVE_KY = 0.0330760749724366 * (PLOT_H / Y_RANGE);
  var CURVE_X_OFF = 0;                  // _loc14_
  var CURVE_Y_OFF = 0.1;                // _loc15_
  var CURVE_START = { x: -11.5, y: 108.25 };
  var CURVE_PTS = [
    { cx: -12.9, cy: 70.6,  ax: -8.8,  ay: 30    },
    { cx: -5.7,  cy: 0.2,   ax: 0,     ay: 0.1   },
    { cx: 5.1,   cy: -0.1,  ax: 12.9,  ay: 28.4  },
    { cx: 17,    cy: 43.3,  ax: 20.1,  ay: 58.2  },
    { cx: 21.5,  cy: 64.8,  ax: 27.7,  ay: 79    },
    { cx: 30.4,  cy: 85.2,  ax: 35.8,  ay: 90.9  },
    { cx: 42.2,  cy: 97.5,  ax: 73.8,  ay: 112.6 },
    { cx: 112.5, cy: 131,   ax: 314.3, ay: 233.3 }
  ];
  // The curve "object" is anchored at day 0 / absolute magnitude -19.5:
  // addObject(... {type: (-timeAtLeft)/timeRange, absBolMag: peakAbsMag}).
  var CURVE_ANCHOR_X = PLOT_W * ((0 - TIME_AT_LEFT) / TIME_RANGE);

  /* ------------------------------------------------------------------ *
   * 2. STATE (single source of truth)                                   *
   * ------------------------------------------------------------------ */
  var state = {
    xOffset: 0,             // horizontal data shift in plot px (0..200)
    yOffset: 0,             // vertical shift == distance modulus (m - M)
    minYOffset: NaN,        // set when a supernova is selected (AS parity:
    maxYOffset: NaN,        //   NaN = unclamped until first selection)
    selectedIndex: -1,      // index into SN_LIST; -1 = "select a supernova..."
    showBar: false,
    barAbsMag: (Y_MIN + Y_MAX) / 2   // reset position: middle of the plot
  };

  var snList = window.SN_LIST || [];
  // Precompute each supernova's dot x-positions (days since first observation,
  // in plot px) and its min/max B magnitude (used for the drag clamp).
  var snPlot = snList.map(function (sn) {
    var jd0 = sn.observationsList[0].JD;
    var minMag = Infinity, maxMag = -Infinity;
    var pts = sn.observationsList.map(function (o) {
      if (o.B < minMag) minMag = o.B;
      if (o.B > maxMag) maxMag = o.B;
      return { x: PX_PER_DAY * (o.JD - jd0), B: o.B };
    });
    return { pts: pts, minMag: minMag, maxMag: maxMag };
  });

  /* ------------------------------------------------------------------ *
   * 3. DOM references                                                   *
   * ------------------------------------------------------------------ */
  var canvas, ctx, plotbox, dragEl, barEl, overlay,
      selectEl, showBarEl, appInput, absInput,
      liveEl, plotDescEl, barLeftEl, barRightEl,
      calcResEl, calcResultSrEl;

  /* ------------------------------------------------------------------ *
   * 4. Coordinate transforms (logical plot units; canvas y down)        *
   * ------------------------------------------------------------------ */
  function cy(mag) {                       // magnitude -> y (Y_MIN at top)
    return ((mag - Y_MIN) / Y_RANGE) * PLOT_H;
  }
  function fracY(mag) { return (mag - Y_MIN) / Y_RANGE; }       // 0..1
  function dayToX(day) { return PLOT_W * ((day - TIME_AT_LEFT) / TIME_RANGE); }
  function fracXDay(day) { return (day - TIME_AT_LEFT) / TIME_RANGE; }

  /* ------------------------------------------------------------------ *
   * 5. Number formatting (ports of the AS Number helpers)               *
   * ------------------------------------------------------------------ */
  // Port of the Number.prototype.toFixed POLYFILL in "Number Functions.as"
  // (round-half-away-from-zero on the absolute value).
  function asToFixed(x, fractionDigits) {
    var n = fractionDigits | 0;
    if (n < 0 || n > 20) return "Range Error";
    if (isNaN(x)) return "NaN";
    var sign = "";
    if (x < 0) { sign = "-"; x = -x; }
    var out;
    if (x < 1e21) {
      var r = Math.round(x * Math.pow(10, n));
      out = (r === 0) ? "0" : String(r);
      if (n > 0) {
        var len = out.length;
        if (len <= n) {
          var pad = "";
          for (var i = 0; i < n + 1 - len; i++) pad += "0";
          out = pad + out;
          len = n + 1;
        }
        out = out.substr(0, len - n) + "." + out.substr(len - n);
      }
    } else {
      out = String(x);
    }
    return sign + out;
  }

  // Mimics AVM1 Number.toString: up to 15 significant digits, noise trimmed.
  function flashNum(x) {
    if (!isFinite(x)) return "" + x;
    return String(parseFloat(x.toPrecision(15)));
  }

  // Port of formatNumber() from the calculator script (DefineSprite_194).
  function formatNumber(num, digits) {
    var e = Math.floor(Math.log(num) / LN10) - (digits - 1);
    if (e >= 0) {
      var p = Math.pow(10, e);
      return String(p * Math.round(num / p));
    }
    return asToFixed(num, -e);
  }

  function fixed1Spoken(x) {                       // "minus 16.0"
    var s = asToFixed(Math.abs(x), 1);
    return (x < 0 && s !== "0.0" ? "minus " : "") + s;
  }
  // Proper typographic minus sign (U+2212) for DISPLAYED text only. ASCII "-"
  // is kept in aria-valuenow (must stay a valid number) and the spoken text
  // (which uses the word "minus" instead).
  var MINUS = "−";
  function dispMinus(s) { return String(s).split("-").join(MINUS); }
  function daysSpoken(px) {                        // time shift px -> days text
    var d = px / PX_PER_DAY;
    var s = asToFixed(Math.abs(d), 1).replace(/\.0$/, "");
    return (d < 0 ? "minus " : "") + s;
  }

  /* ------------------------------------------------------------------ *
   * 6. MathJax helpers                                                  *
   * ------------------------------------------------------------------ */
  var mjReady = false;
  var pendingTypeset = new Set();
  var typesetScheduled = false;

  function mathReady() {
    return window.MathJax && MathJax.typesetPromise && MathJax.startup && MathJax.startup.document;
  }

  function scheduleTypeset(el) {
    pendingTypeset.add(el);
    if (!typesetScheduled) {
      typesetScheduled = true;
      // setTimeout (not rAF) so batched typesetting also runs in background tabs.
      setTimeout(flushTypeset, 0);
    }
  }
  function flushTypeset() {
    typesetScheduled = false;
    if (!mathReady()) { setTimeout(flushTypeset, 30); typesetScheduled = true; return; }
    var els = [];
    pendingTypeset.forEach(function (e) { if (e && e.isConnected) els.push(e); });
    pendingTypeset.clear();
    if (!els.length) return;
    try { if (MathJax.typesetClear) MathJax.typesetClear(els); } catch (e) {}
    MathJax.typesetPromise(els).then(fixTabIndex).catch(function (err) { console.error(err); });
  }

  // Readouts that change continuously while dragging: show the value INSTANTLY
  // as plain text (identical to the typeset form thanks to mtextInheritFont)
  // and debounce the MathJax typeset, so there is no raw-LaTeX flash mid-drag
  // while the settled value is still real MathJax (right-click menu works).
  function setReadout(el, text) {
    if (!el || el.getAttribute("data-readout") === text) return;
    el.setAttribute("data-readout", text);
    el.textContent = text;                  // instant, page-font render
    clearTimeout(el._mjTimer);
    el._mjTimer = setTimeout(function () { typesetReadout(el, text); }, 180);
  }
  function typesetReadout(el, text) {
    if (!mathReady()) { el._mjTimer = setTimeout(function () { typesetReadout(el, text); }, 60); return; }
    var stage = document.createElement("span");
    stage.setAttribute("aria-hidden", "true");
    stage.style.cssText = "position:absolute;visibility:hidden";
    stage.innerHTML = "\\(\\text{" + text + "}\\)";
    el.appendChild(stage);
    MathJax.typesetPromise([stage]).then(function () {
      var rendered = stage.querySelector("mjx-container");
      if (rendered && el.getAttribute("data-readout") === text) {
        rendered.remove();
        el.textContent = "";
        el.appendChild(rendered);
        fixTabIndex();
      } else {
        stage.remove();               // value changed meanwhile; newer typeset wins
      }
    }).catch(function () { stage.remove(); });
  }

  // Typeset math is display-only: keep it out of the Tab order.
  function fixTabIndex() {
    document.querySelectorAll('mjx-container[tabindex], mjx-container svg[tabindex]').forEach(function (n) {
      n.setAttribute("tabindex", "-1");
    });
  }

  /* ------------------------------------------------------------------ *
   * 7. Tick-label overlays                                              *
   * ------------------------------------------------------------------ */
  var rightPool = [];    // reusable elements for the moving apparent labels

  function makeTick(cls, text) {
    var el = document.createElement("span");
    el.className = "sn-tick " + cls;
    overlay.appendChild(el);
    if (text !== undefined) {
      el.setAttribute("data-readout", text);
      el.innerHTML = "\\(\\text{" + text + "}\\)";
      scheduleTypeset(el);
    }
    return el;
  }
  function texInt(v) { return (v < 0 ? MINUS : "") + Math.abs(v); }   // proper minus

  function buildStaticTicks() {
    // Left axis: absolute magnitude labels at even integers (-22 .. -10).
    for (var v = Y_MIN; v <= Y_MAX; v++) {
      if (v % Y_LABEL_MULTIPLE !== 0) continue;
      var el = makeTick("sn-tick--left", texInt(v));
      el.style.left = "0";
      el.style.top = (fracY(v) * 100) + "%";
    }
    // Bottom axis: labelled day tick marks (-50 .. 400 step 50).
    LABELLED_TICKS.forEach(function (d) {
      var el = makeTick("sn-tick--bottom", texInt(d));
      el.style.top = "100%";
      el.style.left = (fracXDay(d) * 100) + "%";
    });
    // Right axis: pool of reusable apparent-magnitude labels. Their values
    // change with the distance modulus, so text is set per render (instant
    // plain text + debounced MathJax via setReadout).
    for (var i = 0; i < 9; i++) {
      var re = makeTick("sn-tick--right");
      re.style.left = "100%";
      re.style.display = "none";
      rightPool.push(re);
    }
  }

  function positionRightTicks() {
    var mod = state.yOffset;
    // Visible apparent-magnitude labels: even integers a with the matching
    // absolute position (a - mod) inside the plot range.
    var first = Math.ceil((Y_MIN + mod) / Y_LABEL_MULTIPLE) * Y_LABEL_MULTIPLE;
    var slot = 0;
    for (var a = first; a - mod <= Y_MAX + 1e-9 && slot < rightPool.length; a += Y_LABEL_MULTIPLE) {
      var el = rightPool[slot++];
      el.style.display = "";
      el.style.top = (fracY(a - mod) * 100) + "%";
      setReadout(el, texInt(a));
    }
    for (; slot < rightPool.length; slot++) rightPool[slot].style.display = "none";
  }

  /* ------------------------------------------------------------------ *
   * 8. Canvas rendering                                                 *
   * ------------------------------------------------------------------ */
  function setupCanvas() {
    var dpr = Math.max(1, window.devicePixelRatio || 1);
    // Back the canvas at its ACTUAL displayed size x dpr so the tick lines stay
    // crisp. (A fixed logical backing store stretched up by CSS is what made
    // them blurry.) The drawing coordinate system stays in original stage units
    // via ctx.setTransform, so all ported geometry/physics math is unchanged.
    var rect = canvas.getBoundingClientRect();
    var cssW = rect.width  || (PLOT_W + 2 * MARGIN);
    var cssH = rect.height || (PLOT_H + 2 * MARGIN);
    canvas.width  = Math.max(1, Math.round(cssW * dpr));
    canvas.height = Math.max(1, Math.round(cssH * dpr));
    // Map the logical (PLOT_W + 2*MARGIN) x (PLOT_H + 2*MARGIN) region onto the
    // backing store; origin at the plot's top-left corner, margin for ticks.
    var sx = canvas.width  / (PLOT_W + 2 * MARGIN);
    var sy = canvas.height / (PLOT_H + 2 * MARGIN);
    ctx.setTransform(sx, 0, 0, sy, MARGIN * sx, MARGIN * sy);
  }

  function drawCanvas() {
    ctx.clearRect(-MARGIN, -MARGIN, PLOT_W + 2 * MARGIN, PLOT_H + 2 * MARGIN);

    // Plot background (white), like the component's backgroundMC.
    ctx.fillStyle = "#ffffff";
    ctx.fillRect(0, 0, PLOT_W, PLOT_H);

    // Curve + data clipped to the plot rectangle (the AS plot mask).
    ctx.save();
    ctx.beginPath();
    ctx.rect(0, 0, PLOT_W, PLOT_H);
    ctx.clip();
    drawTemplateCurve();
    drawObservations();
    ctx.restore();

    drawTicks();

    // Border (borderMC: 1px, black).
    ctx.strokeStyle = COL_AXIS;
    ctx.lineWidth = 1;
    ctx.strokeRect(0.5, 0.5, PLOT_W - 1, PLOT_H - 1);
  }

  // The theoretical light curve: same quadratic Beziers as the AS curveTo
  // calls (an affine transform of control points preserves the curve).
  // It is FIXED: the curve lives outside the draggable object layer.
  function drawTemplateCurve() {
    var x0 = CURVE_ANCHOR_X;
    var y0 = cy(PEAK_ABS_MAG);
    function px(v) { return x0 + CURVE_KX * (v - CURVE_X_OFF); }
    function py(v) { return y0 + CURVE_KY * (v - CURVE_Y_OFF); }
    ctx.strokeStyle = COL_RED;
    ctx.lineWidth = 1;
    ctx.lineJoin = "round";
    ctx.beginPath();
    ctx.moveTo(px(CURVE_START.x), py(CURVE_START.y));
    for (var i = 0; i < CURVE_PTS.length; i++) {
      var p = CURVE_PTS[i];
      ctx.quadraticCurveTo(px(p.cx), py(p.cy), px(p.ax), py(p.ay));
    }
    ctx.stroke();
  }

  // The selected supernova's B-band observations, shifted by the drag
  // offsets: x + xOffset px, magnitude - distance modulus.
  function drawObservations() {
    if (state.selectedIndex < 0) return;
    var sp = snPlot[state.selectedIndex];
    var mod = state.yOffset;
    ctx.fillStyle = COL_BLUE;
    for (var i = 0; i < sp.pts.length; i++) {
      var p = sp.pts[i];
      ctx.beginPath();
      ctx.arc(p.x + state.xOffset, cy(p.B - mod), DOT_R, 0, Math.PI * 2);
      ctx.fill();
    }
  }

  function drawTicks() {
    // Left axis (absolute, red): major ticks 7px outward at every integer,
    // minor ticks 3px outward at every half (drawYScale, side "left").
    ctx.strokeStyle = COL_RED;
    ctx.lineWidth = 1;
    ctx.beginPath();
    for (var v = Y_MIN; v <= Y_MAX; v++) {
      var yy = cy(v);
      ctx.moveTo(0, yy); ctx.lineTo(-7, yy);
      if (v + 0.5 <= Y_MAX) {
        var yh = cy(v + 0.5);
        ctx.moveTo(0, yh); ctx.lineTo(-3, yh);
      }
    }
    ctx.stroke();

    // Right axis (apparent, blue): same pattern shifted by the distance
    // modulus (drawYScale, side "right", scaleType AppBolMag).
    ctx.strokeStyle = COL_BLUE;
    ctx.beginPath();
    var mod = state.yOffset;
    var aMin = Math.ceil(Y_MIN + mod - 1), aMax = Math.floor(Y_MAX + mod + 1);
    for (var a = aMin; a <= aMax; a++) {
      var ya = cy(a - mod);
      if (ya >= 0 && ya <= PLOT_H) { ctx.moveTo(PLOT_W, ya); ctx.lineTo(PLOT_W + 7, ya); }
      var yah = cy(a + 0.5 - mod);
      if (yah >= 0 && yah <= PLOT_H) { ctx.moveTo(PLOT_W, yah); ctx.lineTo(PLOT_W + 3, yah); }
    }
    ctx.stroke();

    // Bottom axis (time, black): 3px unlabelled ticks at -25,25,...,375 and
    // 6px labelled ticks at -50,0,...,400 (verbatim from init()).
    ctx.strokeStyle = COL_AXIS;
    ctx.beginPath();
    UNLABELLED_TICKS.forEach(function (d) {
      var x = dayToX(d);
      ctx.moveTo(x, PLOT_H); ctx.lineTo(x, PLOT_H + 3);
    });
    LABELLED_TICKS.forEach(function (d) {
      var x = dayToX(d);
      ctx.moveTo(x, PLOT_H); ctx.lineTo(x, PLOT_H + 6);
    });
    ctx.stroke();
  }

  /* ------------------------------------------------------------------ *
   * 9. Horizontal reference bar (HR Horizontal Bar port)                *
   * ------------------------------------------------------------------ */
  function positionBar() {
    if (!state.showBar) return;
    barEl.style.top = (fracY(state.barAbsMag) * 100) + "%";
  }
  // updateValues(): left = absolute magnitude at the bar, right = + modulus.
  function updateBarReadouts() {
    if (!state.showBar) return;
    var left = state.barAbsMag;
    var right = left + state.yOffset;
    setReadout(barLeftEl, dispMinus(asToFixed(left, 1)));
    setReadout(barRightEl, dispMinus(asToFixed(right, 1)));
    barEl.setAttribute("aria-valuenow", asToFixed(left, 1));
    barEl.setAttribute("aria-valuetext",
      "Reference bar. Absolute magnitude " + fixed1Spoken(left) +
      ", apparent magnitude " + fixed1Spoken(right) + ".");
  }

  /* ------------------------------------------------------------------ *
   * 10. Distance Modulus Calculator (DefineSprite_194 port)             *
   * ------------------------------------------------------------------ */
  var RESTRICT = /[^0-9.+\-]/g;   // AS restrict = "0-9.+\-"

  function sanitizeInput(el) {
    var cleaned = el.value.replace(RESTRICT, "");
    if (cleaned !== el.value) {
      var pos = el.selectionStart - (el.value.length - cleaned.length);
      el.value = cleaned;
      try { el.setSelectionRange(pos, pos); } catch (e) {}
    }
  }

  function updateCalculator() {
    var m = parseFloat(appInput.value);   // appMagField
    var M = parseFloat(absInput.value);   // absMagField
    var modText, distLatex, distSpoken, srText;

    if (isNaN(m) || isNaN(M)) {
      modText = null; distLatex = "\\text{...}";
      srText = "Enter values for m and M to compute the distance modulus and distance.";
    } else {
      var mod = m - M;
      var dist = Math.pow(10, (mod + 5) / 5);
      modText = isFinite(mod) ? flashNum(mod) : null;

      if (!isFinite(dist)) { distLatex = "\\text{...}"; distSpoken = "undefined"; }
      else if (dist === 0) { distLatex = "\\text{0 pc}"; distSpoken = "0 parsecs"; }
      else if (dist < 0.001 || dist > 100000) {
        var mpc = asToFixed(dist / 1000000, 1);
        distLatex = "\\text{" + mpc + " Mpc}";
        distSpoken = mpc + " megaparsecs";
      } else {
        var fn = formatNumber(dist, 3);
        distLatex = "\\text{" + fn + " pc}";
        distSpoken = fn + " parsecs";
      }
      srText = "m minus M equals " + (modText === null ? "undefined" : modText) +
        " magnitudes. Distance d equals " + distSpoken + ".";
    }

    // All-sans rendering: wrap every token in \text{} so MathJax uses the page
    // font (mtextInheritFont), matching the calculator formula above and the
    // "... pc"/"... Mpc" results. Right-click "Show Math As" still works.
    var modLatex = (modText === null ? "\\text{...}" : "\\text{" + dispMinus(modText) + "}");
    var latex = modLatex + "\\text{ = " + MINUS + "5 + 5 log}_{\\text{10}}\\text{ }" + distLatex;

    // Displayed equations go through the foundation helper (kl-unl.js),
    // which also feeds the paired screen-reader message.
    try { if (mathReady() && MathJax.typesetClear) MathJax.typesetClear([calcResEl]); } catch (e) {}
    klunlShowEquation(["sn-calc-res", "\\(" + latex + "\\)"],
                      ["sn-calc-result-sr", srText]);
    if (mathReady()) { MathJax.startup.promise.then(fixTabIndex); }
  }

  /* ------------------------------------------------------------------ *
   * 11. Supernova selection (onSelectorChanged port)                    *
   * ------------------------------------------------------------------ */
  function buildSelect() {
    var opt0 = document.createElement("option");
    opt0.value = "-1";
    opt0.textContent = "select a supernova...";
    selectEl.appendChild(opt0);
    // AVM1 for..in iterates arrays in REVERSE insertion order, so the
    // original combo box listed the supernovae last-pushed first (1993J,
    // 1994Y, ... 1999ee). Replicated here for parity.
    for (var i = snList.length - 1; i >= 0; i--) {
      var o = document.createElement("option");
      o.value = String(i);
      o.textContent = snList[i].name;
      selectEl.appendChild(o);
    }
  }

  function onSelectorChanged() {
    var idx = parseInt(selectEl.value, 10);
    state.selectedIndex = idx;
    if (idx >= 0) {
      var sp = snPlot[idx];
      var margin = 1;   // _loc4_ = 1 magnitude of guaranteed overlap
      state.minYOffset = sp.minMag + margin - Y_MAX;
      state.maxYOffset = sp.maxMag - margin - Y_MIN;
      if (state.yOffset < state.minYOffset) state.yOffset = state.minYOffset;
      if (state.yOffset > state.maxYOffset) state.yOffset = state.maxYOffset;
    }
    // (Deselecting hides the data but keeps the offsets/limits, as in the AS.)
    render();
  }

  /* ------------------------------------------------------------------ *
   * 12. Live region / plot description (units always spoken)            *
   * ------------------------------------------------------------------ */
  function announce(msg) { liveEl.textContent = msg; }

  function shiftSpokenState() {
    return "Time shift " + daysSpoken(state.xOffset) + " days. " +
      "Distance modulus m minus M " + fixed1Spoken(state.yOffset) + " magnitudes.";
  }

  function updatePlotDesc() {
    var parts = [];
    parts.push("Light curve plot. Horizontal axis, days from peak, from minus 50 on the left to 400 on the right. " +
      "Left vertical axis, absolute magnitude M B, from minus 22 at the top to minus 10 at the bottom. " +
      "Right vertical axis, apparent magnitude m B, equal to the absolute magnitude plus the distance modulus.");
    parts.push("A fixed red curve shows the theoretical Type Ia supernova light curve, " +
      "peaking at absolute magnitude minus 19.5 at day 0, then fading for about 380 days.");
    if (state.selectedIndex >= 0) {
      var sn = snList[state.selectedIndex];
      parts.push("Supernova " + sn.name + " selected: " + sn.observationsList.length +
        " observations plotted as blue points.");
    } else {
      parts.push("No supernova selected.");
    }
    parts.push(shiftSpokenState());
    if (state.showBar) {
      parts.push("Reference bar shown at absolute magnitude " + fixed1Spoken(state.barAbsMag) +
        ", apparent magnitude " + fixed1Spoken(state.barAbsMag + state.yOffset) + ".");
    }
    plotDescEl.textContent = parts.join(" ");
  }

  /* ------------------------------------------------------------------ *
   * 13. Master render                                                   *
   * ------------------------------------------------------------------ */
  function render() {
    drawCanvas();
    positionRightTicks();
    positionBar();
    updateBarReadouts();
    updatePlotDesc();
  }

  /* ------------------------------------------------------------------ *
   * 14. Interaction — 2-D data drag (Draggable Area port)               *
   * ------------------------------------------------------------------ */
  function plotClientRect() { return plotbox.getBoundingClientRect(); }

  function setOffsets(xOff, yOff) {
    // Horizontal clamp is always active (minXOffset 0, maxXOffset 200).
    if (xOff < X_OFF_MIN) xOff = X_OFF_MIN;
    if (xOff > X_OFF_MAX) xOff = X_OFF_MAX;
    // Vertical clamp only once limits exist (NaN-safe, like the AS isNaN checks).
    if (!isNaN(state.minYOffset) && yOff < state.minYOffset) yOff = state.minYOffset;
    if (!isNaN(state.maxYOffset) && yOff > state.maxYOffset) yOff = state.maxYOffset;
    state.xOffset = xOff;
    state.yOffset = yOff;   // the vertical offset IS the distance modulus
    render();
  }

  function initDragPointer() {
    var startX = 0, startY = 0, startXOff = 0, startYOff = 0, dragging = false;
    dragEl.addEventListener("pointerdown", function (e) {
      dragEl.focus();
      dragging = true;
      startX = e.clientX; startY = e.clientY;
      startXOff = state.xOffset; startYOff = state.yOffset;
      dragEl.classList.add("sn-dragging");
      try { dragEl.setPointerCapture(e.pointerId); } catch (err) {}
      e.preventDefault();
    });
    dragEl.addEventListener("pointermove", function (e) {
      if (!dragging) return;
      var r = plotClientRect();
      var sxf = PLOT_W / (r.width || PLOT_W);    // client px -> plot px
      var syf = PLOT_H / (r.height || PLOT_H);
      // AS: xOffset = init + xScaleFactor(1) * dx;  yOffset = init +
      // yScaleFactor(-(yMax-yMin)/height) * dy  — in original stage px.
      var xOff = startXOff + 1 * ((e.clientX - startX) * sxf);
      var yOff = startYOff + (-Y_RANGE / PLOT_H) * ((e.clientY - startY) * syf);
      setOffsets(xOff, yOff);
    });
    function end() {
      if (!dragging) return;
      dragging = false;
      dragEl.classList.remove("sn-dragging");
      announce("Observations moved. " + shiftSpokenState());
    }
    dragEl.addEventListener("pointerup", end);
    dragEl.addEventListener("pointercancel", end);
  }

  function initDragKeys() {
    dragEl.addEventListener("keydown", function (e) {
      var xOff = state.xOffset, yOff = state.yOffset, handled = true;
      var dayStep = PX_PER_DAY * (e.shiftKey ? 10 : 1);
      var modStep = e.shiftKey ? 1 : 0.1;
      switch (e.key) {
        case "ArrowRight": xOff += dayStep; break;
        case "ArrowLeft":  xOff -= dayStep; break;
        case "ArrowUp":    yOff = Math.round((yOff + modStep) * 10) / 10; break;
        case "ArrowDown":  yOff = Math.round((yOff - modStep) * 10) / 10; break;
        case "PageUp":     yOff = Math.round((yOff + 1) * 10) / 10; break;
        case "PageDown":   yOff = Math.round((yOff - 1) * 10) / 10; break;
        case "Home":       xOff = X_OFF_MIN; break;
        case "End":        xOff = X_OFF_MAX; break;
        default: handled = false;
      }
      if (handled) {
        e.preventDefault();
        setOffsets(xOff, yOff);
        announce(shiftSpokenState());
      }
    });
  }

  /* ------------------------------------------------------------------ *
   * 15. Interaction — reference bar (pointer + keyboard)                *
   * ------------------------------------------------------------------ */
  function setBar(v, announceIt) {
    // The original clamps the bar to the plot edges exactly.
    if (v < Y_MIN) v = Y_MIN;
    if (v > Y_MAX) v = Y_MAX;
    state.barAbsMag = v;
    positionBar();
    updateBarReadouts();
    updatePlotDesc();
    if (announceIt) {
      announce("Reference bar. Absolute magnitude " + fixed1Spoken(v) +
        ", apparent magnitude " + fixed1Spoken(v + state.yOffset) + ".");
    }
  }

  function initBarPointer() {
    var startY = 0, startVal = 0, dragging = false;
    barEl.addEventListener("pointerdown", function (e) {
      barEl.focus();
      dragging = true;
      startY = e.clientY;
      startVal = state.barAbsMag;
      try { barEl.setPointerCapture(e.pointerId); } catch (err) {}
      e.preventDefault();
      e.stopPropagation();
    });
    barEl.addEventListener("pointermove", function (e) {
      if (!dragging) return;
      var r = plotClientRect();
      var newVal = startVal + Y_RANGE * (e.clientY - startY) / (r.height || PLOT_H);
      setBar(newVal, false);
      e.stopPropagation();
    });
    function end() {
      if (!dragging) return;
      dragging = false;
      announce("Reference bar. Absolute magnitude " + fixed1Spoken(state.barAbsMag) +
        ", apparent magnitude " + fixed1Spoken(state.barAbsMag + state.yOffset) + ".");
    }
    barEl.addEventListener("pointerup", end);
    barEl.addEventListener("pointercancel", end);
  }

  function initBarKeys() {
    barEl.addEventListener("keydown", function (e) {
      var v = state.barAbsMag, handled = true;
      switch (e.key) {
        // ArrowUp moves the bar UP (toward brighter, more negative magnitude).
        case "ArrowUp": case "ArrowLeft":    v -= 0.1; break;
        case "ArrowDown": case "ArrowRight": v += 0.1; break;
        case "PageUp":   v -= 1; break;
        case "PageDown": v += 1; break;
        case "Home":     v = Y_MIN; break;
        case "End":      v = Y_MAX; break;
        default: handled = false;
      }
      if (handled) {
        e.preventDefault();
        setBar(Math.round(v * 10) / 10, true);
      }
    });
  }

  /* ------------------------------------------------------------------ *
   * 16. Controls wiring                                                 *
   * ------------------------------------------------------------------ */
  function initControls() {
    selectEl.addEventListener("change", function () {
      onSelectorChanged();
      if (state.selectedIndex >= 0) {
        var sn = snList[state.selectedIndex];
        announce("Supernova " + sn.name + " selected: " + sn.observationsList.length +
          " observations plotted. " + shiftSpokenState());
      } else {
        announce("No supernova selected. Observations hidden.");
      }
    });

    showBarEl.addEventListener("change", function () {
      state.showBar = showBarEl.checked;
      barEl.hidden = !state.showBar;
      if (state.showBar) { positionBar(); updateBarReadouts(); }
      updatePlotDesc();
      announce(state.showBar ? "Horizontal bar shown." : "Horizontal bar hidden.");
    });

    [appInput, absInput].forEach(function (el) {
      el.addEventListener("input", function () { sanitizeInput(el); updateCalculator(); });
    });
  }

  /* ------------------------------------------------------------------ *
   * 17. Reset (from the foundation masthead "sim-reset" event)          *
   * ------------------------------------------------------------------ */
  function onReset() {
    // onReset(): checkbox off, bar to the middle, selector to index 0,
    // offsets to zero, calculator cleared. (As in the AS, the vertical drag
    // limits from the last selection are intentionally kept.)
    showBarEl.checked = false;
    state.showBar = false;
    barEl.hidden = true;
    state.barAbsMag = (Y_MIN + Y_MAX) / 2;
    selectEl.value = "-1";
    state.selectedIndex = -1;
    state.xOffset = 0;
    state.yOffset = 0;
    appInput.value = "";
    absInput.value = "";
    updateCalculator();
    render();
    announce("Simulation reset.");
  }

  /* ------------------------------------------------------------------ *
   * 18. Static MathJax bits (axis-title variables, calculator formula)  *
   * ------------------------------------------------------------------ */
  function typesetStatic() {
    document.querySelectorAll(".sn-mj[data-tex]").forEach(function (el) {
      var tex = el.getAttribute("data-tex");
      if (tex) { el.innerHTML = "\\(" + tex + "\\)"; scheduleTypeset(el); }
    });
  }

  /* ------------------------------------------------------------------ *
   * 19. Boot                                                            *
   * ------------------------------------------------------------------ */
  function grab() {
    canvas = document.getElementById("sn-canvas");
    ctx = canvas.getContext("2d");
    plotbox = document.getElementById("sn-plotbox");
    dragEl = document.getElementById("sn-drag");
    barEl = document.getElementById("sn-bar");
    overlay = document.getElementById("sn-overlay");
    selectEl = document.getElementById("sn-select");
    showBarEl = document.getElementById("sn-showbar");
    appInput = document.getElementById("sn-app");
    absInput = document.getElementById("sn-abs");
    liveEl = document.getElementById("sn-live");
    plotDescEl = document.getElementById("sn-plot-desc");
    barLeftEl = document.getElementById("sn-bar-left");
    barRightEl = document.getElementById("sn-bar-right");
    calcResEl = document.getElementById("sn-calc-res");
    calcResultSrEl = document.getElementById("sn-calc-result-sr");
  }

  function boot() {
    grab();
    setupCanvas();
    buildSelect();
    buildStaticTicks();
    initControls();
    initDragPointer();
    initDragKeys();
    initBarPointer();
    initBarKeys();

    // Reset comes from the shared masthead (bubbling, composed CustomEvent).
    document.addEventListener("sim-reset", onReset);

    // dpr / layout changes: re-fit the canvas backing store.
    window.addEventListener("resize", function () { setupCanvas(); render(); });

    updateCalculator();
    render();

    // Typeset once MathJax is ready (it loads async).
    if (mathReady()) { mjReady = true; typesetStatic(); updateCalculator(); flushTypeset(); }
    else if (window.MathJax && MathJax.startup && MathJax.startup.promise) {
      MathJax.startup.promise.then(function () {
        mjReady = true; typesetStatic(); updateCalculator(); flushTypeset();
      });
    } else {
      var tries = 0;
      var iv = setInterval(function () {
        if (mathReady()) { clearInterval(iv); mjReady = true; typesetStatic(); updateCalculator(); flushTypeset(); }
        else if (++tries > 200) clearInterval(iv);
      }, 50);
    }
  }

  // kl-unl.js calls klunlInitEqn() to initialize equations; route it to our
  // typesetting so the calculator equation and static math are (re)built.
  window.klunlInitEqn = function () {
    if (mjReady) { typesetStatic(); updateCalculator(); }
  };

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", boot);
  } else {
    boot();
  }
})();
