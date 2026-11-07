/* =====================================================================
   HR Diagram Star Cluster Fitting Explorer
   HTML5 port of the decompiled Adobe Flash simulation (clusterFittingExplorer009,
   12 November 2009), built on the shared KL-UNL foundation.

   BEHAVIOUR PARITY: all physics constants, tables and formulas below are copied
   VERBATIM from the ActionScript source (scripts/HR Diagram Component 042
   Modded.as and friends). Only the presentation is modernised.

   Coordinate system: the plot keeps the original internal magnitude/temperature
   ranges; the canvas draws in fixed logical units (PLOT_W x PLOT_H) and CSS
   scales it. Pointer coordinates are mapped back through the live scale so the
   drag math matches the AS source at any display size.
   ===================================================================== */
(function () {
  "use strict";

  /* ------------------------------------------------------------------ *
   * 1. PHYSICS  (verbatim ports — do not "simplify" the coefficients)   *
   * ------------------------------------------------------------------ */
  var LN10 = 2.302585092994046;   // Math.log(10), the exact constant used in AS

  // Spectral-type number  ->  log10(temperature)
  function getLogTempFromType(x) {
    if (x < 8.5167)  return 4.7009  + x * (-0.01    + x * (0.0000392  + x * -0.00014247));
    if (x < 16.1)    return 4.4348  + x * (0.08374  + x * (-0.010967  + x * 0.000288299));
    if (x < 23.2167) return 6.0516  + x * (-0.21754 + x * (0.007746   + x * -0.000099133));
    if (x < 34.1833) return 5.0538  + x * (-0.08861 + x * (0.0021924  + x * -0.000019396));
    if (x < 50.5108) return 4.7553  + x * (-0.06241 + x * (0.0014259  + x * -0.000011922));
    if (x < 57.9775) return 1.1584  + x * (0.15122  + x * (-0.0028034 + x * 0.000015988));
    if (x < 64.3942) return 26.4612 + x * (-1.15805 + x * (0.019779   + x * -0.000113846));
    return -115.7858 + x * (5.46896 + x * (-0.0831343 + x * 0.000418879));
  }

  // B-V colour index  ->  spectral-type number
  function getTypeFromBV(x) {
    if (x < -0.3021) return 7009.7558   + x * (69770.6118  + x * (232162.4881 + x * 258039.06485));
    if (x < -0.2623) return 217.5991    + x * (2326.7725   + x * (8930.9142   + x * 11748.54064));
    if (x < -0.1723) return 29.9994     + x * (181.1411    + x * (750.8478    + x * 1353.23439));
    if (x < -0.0825) return 19.8398     + x * (4.2475      + x * (-275.8126   + x * -632.95316));
    if (x < 0.0264)  return 20.3718     + x * (23.5866     + x * (-41.4702    + x * 313.59799));
    if (x < 0.2766)  return 20.3763     + x * (23.0727     + x * (-21.9861    + x * 67.35311));
    if (x < 0.439)   return 20.0065     + x * (27.0848     + x * (-36.4924    + x * 84.83639));
    if (x < 0.6642)  return 45.9759     + x * (-150.373    + x * (367.7165    + x * -222.06249));
    if (x < 0.8501)  return -41.1478    + x * (243.1104    + x * (-224.6559   + x * 75.20128));
    if (x < 1.0695)  return -19.9166    + x * (168.1854    + x * (-136.5193   + x * 40.64197));
    if (x < 1.3622)  return 6.6348      + x * (93.7057     + x * (-66.8779    + x * 18.93618));
    if (x < 1.4815)  return -567.6877   + x * (1358.5475   + x * (-995.4066   + x * 246.1492));
    if (x < 1.5305)  return 5740.3207   + x * (-11415.4409 + x * (7627.2188   + x * -1693.98275));
    if (x < 1.6464)  return -1788.0326  + x * (3341.2138   + x * (-2014.5026  + x * 405.92391));
    if (x < 1.9479)  return -36.4698    + x * (149.542     + x * (-75.8971    + x * 13.42411));
    if (x < 2.1121)  return -1255.211   + x * (2026.574    + x * (-1039.5277  + x * 178.32699));
    return -66110.1638 + x * (94144.6344 + x * (-44653.4522 + x * 7061.43043));
  }

  // Convenience chain used for the cluster data (which stores B-V colour).
  function getLogTempFromBV(BV) { return getLogTempFromType(getTypeFromBV(BV)); }

  // log10(temperature)  ->  bolometric correction (BC)
  function getBCFromLogTemp(x) {
    if (x < 3.588)  return -1873.0763 + x * (1364.8081 + x * (-328.11949 + x * 25.958485));
    if (x < 3.6978) return -4208.8678 + x * (3317.811  + x * (-872.43468 + x * 76.5266));
    if (x < 3.7957) return -2920.8124 + x * (2272.8215 + x * (-589.83737 + x * 51.052264));
    if (x < 3.903)  return 1749.5431  + x * (-1418.5107 + x * (382.67484 + x * -34.353217));
    if (x < 4.1317) return -2011.2742 + x * (1472.2021 + x * (-357.96384 + x * 28.900577));
    return 123.5421 + x * (-77.8864 + x * (17.20884 + x * -1.367489));
  }

  // log10(temperature) + luminosity class  ->  log10(luminosity).
  // This sim uses the main sequence (class V), i.e. the "default" branch.
  function getLogLumFromLogTempAndClassV(x) {
    if (x < 3.5081) return -4686.707  + x * (4157.5332  + x * (-1232.05177 + x * 121.875554));
    if (x < 3.5799) return 22801.9307 + x * (-19349.4898 + x * (5468.65774 + x * -514.806626));
    if (x < 3.728)  return -9950.2659 + x * (8097.5483  + x * (-2198.40972 + x * 199.100683));
    if (x < 3.8287) return 10594.1896 + x * (-8435.0942 + x * (2236.33537  + x * -197.427256));
    if (x < 3.9156) return -7990.8168 + x * (6127.2576  + x * (-1567.12652 + x * 133.707956));
    if (x < 4.2129) return 277.0365   + x * (-207.2491  + x * (50.62412    + x * -4.009536));
    if (x < 4.6015) return -280.446   + x * (189.7309   + x * (-43.6049    + x * 3.446011));
    return -9724.5727 + x * (6346.9359 + x * (-1381.69136 + x * 100.377185));
  }

  // Magnitude <-> log-luminosity (M_bol,sun = 4.75; 2.51189 = 100^(1/5))
  function getMagFromLogLum(L) { return 4.75 - 2.51189 * L; }

  /* ------------------------------------------------------------------ *
   * 2. AXIS RANGES & PLOT GEOMETRY (from the AS init)                    *
   * ------------------------------------------------------------------ */
  // setXAxisType("logTemp", 3.397939, 4.3013)   [x reversed: hot on the left]
  var X_MIN = 3.397939, X_MAX = 4.3013;
  // setYAxisType("absBolMag") default range: y from getMagFromLogLum(6) (top,
  // brightest) to getMagFromLogLum(-5) (bottom, faintest).
  var Y_MIN = getMagFromLogLum(6);    // ~ -10.32134  (top)
  var Y_MAX = getMagFromLogLum(-5);   // ~  17.30945  (bottom)
  var Y_RANGE = Y_MAX - Y_MIN;

  // Distance-modulus (drag offset) limits: initMinOffset/initMaxOffset.
  var MOD_MIN = -10, MOD_MAX = 20;

  // Internal (logical) plot size. The 400 tall matches the original draggable
  // area height, so the drag sensitivity equals the AS scaleFactor exactly.
  var PLOT_W = 340, PLOT_H = 400;

  var TEMP_LABELS = [2500, 5000, 10000, 20000];   // logTempLabelsList
  var Y_LABEL_MULTIPLE = 2;                         // absBolMag/appBolMagLabelMultiple

  var COL_RED  = "#d03030";   // absolute magnitude (13643824)
  var COL_BLUE = "#1d5ef3";   // apparent magnitude (1924851)
  var COL_AXIS = "#1a1a1a";   // temperature axis / border
  var DOT_R = 1;              // HR Diagram Dot: dotSize 2 -> radius 1

  /* ------------------------------------------------------------------ *
   * 3. STATE (single source of truth)                                   *
   * ------------------------------------------------------------------ */
  var state = {
    distanceModulus: 0,        // set by dragging / arrow keys on the plot
    selectedKey: "",           // "" == "select cluster"
    showBar: false,
    barAbsMag: (Y_MIN + Y_MAX) / 2,   // reference-line position (absolute mag)
    stars: []                  // precomputed {x, logTemp, appBolMag} for current cluster
  };

  var clusters = (window.CLUSTER_DATA || []);
  var clusterByKey = {};
  clusters.forEach(function (c) { clusterByKey[c.key] = c.cluster; });

  /* ------------------------------------------------------------------ *
   * 4. DOM references                                                   *
   * ------------------------------------------------------------------ */
  var canvas, ctx, plotbox, dragEl, barEl, overlay,
      selectEl, showBarEl, appInput, absInput,
      liveEl, diagramDescEl, barLeftEl, barRightEl,
      calcModEl, calcResEl, calcResultSrEl;

  /* ------------------------------------------------------------------ *
   * 5. Coordinate transforms (logical plot units)                       *
   * ------------------------------------------------------------------ */
  function sx(logTemp) {              // temperature -> x  (reversed)
    return (1 - (logTemp - X_MIN) / (X_MAX - X_MIN)) * PLOT_W;
  }
  function sy(absMag) {               // absolute magnitude -> y (Y_MIN at top)
    return ((absMag - Y_MIN) / Y_RANGE) * PLOT_H;
  }
  function fracY(absMag) { return (absMag - Y_MIN) / Y_RANGE; }   // 0..1 top..bottom
  function fracX(logTemp) { return 1 - (logTemp - X_MIN) / (X_MAX - X_MIN); }

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

  // Set an element's TeX and queue a (re)typeset.
  function setTex(el, tex) {
    if (!el) return;
    if (el.getAttribute("data-current") === tex) return;
    el.setAttribute("data-current", tex);
    el.innerHTML = "\\(" + tex + "\\)";
    scheduleTypeset(el);
  }

  // Readouts that change continuously while dragging: show the value INSTANTLY as
  // plain text (identical to the typeset form thanks to mtextInheritFont) and
  // debounce the MathJax typeset. The typeset is rendered off-screen and swapped
  // in only once the value settles, so there is no raw-LaTeX flash mid-drag while
  // the settled value is still real MathJax (right-click menu works).
  function setReadout(el, text) {
    if (!el || el.getAttribute("data-readout") === text) return;
    el.setAttribute("data-readout", text);
    el.textContent = text;                  // instant, page-font render
    clearTimeout(el._mjTimer);
    el._mjTimer = setTimeout(function () { typesetReadout(el, text); }, 180);
  }
  function typesetReadout(el, text) {
    if (!mathReady()) { el._mjTimer = setTimeout(function () { typesetReadout(el, text); }, 60); return; }
    // Stage inside el so the math inherits the readout's font-size and colour.
    var stage = document.createElement("span");
    stage.setAttribute("aria-hidden", "true");
    stage.style.cssText = "position:absolute;visibility:hidden";
    stage.innerHTML = "\\(\\text{" + text + "}\\)";
    el.appendChild(stage);
    MathJax.typesetPromise([stage]).then(function () {
      var rendered = stage.querySelector("mjx-container");
      if (rendered && el.getAttribute("data-readout") === text) {
        rendered.remove();
        el.textContent = "";          // drop the plain text (and the empty stage)
        el.appendChild(rendered);
        fixTabIndex();
      } else {
        stage.remove();               // value changed meanwhile; a newer typeset will win
      }
    }).catch(function () { stage.remove(); });
  }

  // Typeset math is display-only: keep it out of the Tab order (rule 8b).
  function fixTabIndex() {
    document.querySelectorAll('mjx-container[tabindex], mjx-container svg[tabindex]').forEach(function (n) {
      n.setAttribute("tabindex", "-1");
    });
  }

  /* ------------------------------------------------------------------ *
   * 7. Tick-label overlays (built once; right axis repositions on drag) *
   * ------------------------------------------------------------------ */
  var rightPool = [];   // {el, value}
  var barTop = null;

  function makeTick(cls, tex) {
    var el = document.createElement("span");
    el.className = "cfe-tick " + cls;
    el.setAttribute("data-current", tex);
    // \text keeps the number MathJax-typeset (right-clickable) while inheriting
    // the page's sans-serif font (via chtml.mtextInheritFont), so it matches the
    // surrounding HTML labels exactly.
    el.innerHTML = "\\(\\text{" + tex + "}\\)";
    overlay.appendChild(el);
    scheduleTypeset(el);
    return el;
  }
  function texInt(v) { return (v < 0 ? "-" : "") + Math.abs(v); }  // "-10", "0", "16"

  function buildStaticTicks() {
    // Left axis: absolute magnitude labels at even integers within range.
    var vmin = Math.ceil(Y_MIN), vmax = Math.floor(Y_MAX);
    for (var v = vmin; v <= vmax; v++) {
      if (v % Y_LABEL_MULTIPLE !== 0) continue;
      var el = makeTick("cfe-tick--left", texInt(v));
      el.style.left = "0";
      el.style.top = (fracY(v) * 100) + "%";
    }
    // Bottom axis: temperature labels (fixed positions).
    TEMP_LABELS.forEach(function (t) {
      var el = makeTick("cfe-tick--bottom", "" + t);
      el.style.top = "100%";
      el.style.left = (fracX(Math.log(t) / LN10) * 100) + "%";
    });
    // Right axis: apparent magnitude pool (repositioned every render).
    for (var a = -20; a <= 38; a += Y_LABEL_MULTIPLE) {
      var re = makeTick("cfe-tick--right", texInt(a));
      re.style.left = "100%";
      re.style.display = "none";
      rightPool.push({ el: re, value: a });
    }
  }

  function positionRightTicks() {
    var mod = state.distanceModulus;
    rightPool.forEach(function (p) {
      var f = fracY(p.value - mod);        // apparent value sits at absolute (v - mod)
      if (f < -0.001 || f > 1.001) { p.el.style.display = "none"; }
      else { p.el.style.display = ""; p.el.style.top = (f * 100) + "%"; }
    });
  }

  /* ------------------------------------------------------------------ *
   * 8. Canvas rendering                                                 *
   * ------------------------------------------------------------------ */
  function setupCanvas() {
    var dpr = Math.max(1, window.devicePixelRatio || 1);
    canvas.width = Math.round(PLOT_W * dpr);
    canvas.height = Math.round(PLOT_H * dpr);
    ctx.setTransform(dpr, 0, 0, dpr, 0, 0);
  }

  function drawCanvas() {
    ctx.clearRect(0, 0, PLOT_W, PLOT_H);

    // Plot background (white).
    ctx.fillStyle = "#ffffff";
    ctx.fillRect(0, 0, PLOT_W, PLOT_H);

    // Data + curve clipped to the plot rectangle (like the AS plot mask).
    ctx.save();
    ctx.beginPath();
    ctx.rect(0, 0, PLOT_W, PLOT_H);
    ctx.clip();

    drawMainSequence();
    drawStars();

    ctx.restore();

    drawTicks();

    // Border.
    ctx.strokeStyle = COL_AXIS;
    ctx.lineWidth = 1;
    ctx.strokeRect(0.5, 0.5, PLOT_W - 1, PLOT_H - 1);
  }

  function drawMainSequence() {
    ctx.strokeStyle = COL_RED;
    ctx.lineWidth = 2;
    ctx.lineJoin = "round";
    ctx.beginPath();
    var STEPS = 240;
    for (var i = 0; i <= STEPS; i++) {
      var t = X_MIN + (X_MAX - X_MIN) * (i / STEPS);
      var mag = getMagFromLogLum(getLogLumFromLogTempAndClassV(t));
      var x = sx(t), y = sy(mag);
      if (i === 0) ctx.moveTo(x, y); else ctx.lineTo(x, y);
    }
    ctx.stroke();
  }

  function drawStars() {
    var mod = state.distanceModulus;
    ctx.fillStyle = COL_BLUE;
    for (var i = 0; i < state.stars.length; i++) {
      var s = state.stars[i];
      var y = sy(s.appBolMag - mod);
      ctx.beginPath();
      ctx.arc(s.x, y, DOT_R, 0, Math.PI * 2);
      ctx.fill();
    }
  }

  function drawTicks() {
    // Left axis (absolute, red): major at every integer, minor at half.
    ctx.strokeStyle = COL_RED;
    ctx.lineWidth = 1;
    ctx.beginPath();
    var vi = Math.ceil(Y_MIN - 1), vmax = Math.floor(Y_MAX + 1);
    for (var v = vi; v <= vmax; v++) {
      var yy = sy(v);
      if (yy >= 0 && yy <= PLOT_H) { ctx.moveTo(0, yy); ctx.lineTo(7, yy); }        // major inward
      var yh = sy(v + 0.5);
      if (yh >= 0 && yh <= PLOT_H) { ctx.moveTo(0, yh); ctx.lineTo(3, yh); }        // minor
    }
    ctx.stroke();

    // Right axis (apparent, blue): shifted by distance modulus.
    ctx.strokeStyle = COL_BLUE;
    ctx.beginPath();
    var mod = state.distanceModulus;
    var amin = Math.ceil(Y_MIN + mod - 1), amax = Math.floor(Y_MAX + mod + 1);
    for (var a = amin; a <= amax; a++) {
      var ya = sy(a - mod);
      if (ya >= 0 && ya <= PLOT_H) { ctx.moveTo(PLOT_W, ya); ctx.lineTo(PLOT_W - 7, ya); }
      var yah = sy(a + 0.5 - mod);
      if (yah >= 0 && yah <= PLOT_H) { ctx.moveTo(PLOT_W, yah); ctx.lineTo(PLOT_W - 3, yah); }
    }
    ctx.stroke();

    // Bottom axis (temperature, black): ticks at the labelled temperatures.
    ctx.strokeStyle = COL_AXIS;
    ctx.beginPath();
    TEMP_LABELS.forEach(function (t) {
      var xx = sx(Math.log(t) / LN10);
      if (xx >= 0 && xx <= PLOT_W) { ctx.moveTo(xx, PLOT_H); ctx.lineTo(xx, PLOT_H - 6); }
    });
    ctx.stroke();
  }

  /* ------------------------------------------------------------------ *
   * 9. Horizontal reference bar                                         *
   * ------------------------------------------------------------------ */
  function positionBar() {
    if (!state.showBar) return;
    barEl.style.top = (fracY(state.barAbsMag) * 100) + "%";
  }
  function updateBarReadouts() {
    if (!state.showBar) return;
    var left = state.barAbsMag;
    var right = state.barAbsMag + state.distanceModulus;
    setReadout(barLeftEl, fixed1(left));
    setReadout(barRightEl, fixed1(right));
    barEl.setAttribute("aria-valuenow", left.toFixed(1));
    barEl.setAttribute("aria-valuetext",
      "Reference line. Absolute magnitude " + fixed1Spoken(left) +
      ", apparent magnitude " + fixed1Spoken(right) + ".");
  }

  /* ------------------------------------------------------------------ *
   * 10. Number formatting (matches the AS number helpers)               *
   * ------------------------------------------------------------------ */
  function fixed1(x) { return x.toFixed(1); }                  // "3.5", "-1.2"
  function fixed1Spoken(x) {                                   // "minus 1.2"
    return (x < 0 ? "minus " : "") + Math.abs(x).toFixed(1);
  }
  // Mimics AVM1 Number.toString: up to 15 significant digits, trailing noise trimmed.
  function flashNum(x) {
    if (!isFinite(x)) return "" + x;
    var s = String(parseFloat(x.toPrecision(15)));
    return s;
  }
  function toScientific(num, digits) {          // port of Number.prototype.toScientific
    if (!isFinite(num) || isNaN(num)) return null;
    var sig, exp, sign = "";
    if (num === 0) { sig = (0).toFixed(digits - 1); exp = 0; }
    else {
      if (num < 0) { sign = "-"; num = -num; }
      exp = Math.floor(Math.log(num) / LN10);
      sig = (num / Math.pow(10, exp)).toFixed(digits - 1);
      if (Number(sig) >= 10) { sig = (1).toFixed(digits - 1); exp += 1; }
      sig = sign + sig;
    }
    return { sig: sig, exp: exp };
  }
  function formatNumber(num, digits) {          // port of formatNumber()
    var e = Math.floor(Math.log(num) / LN10) - (digits - 1);
    if (e >= 0) { var p = Math.pow(10, e); return String(p * Math.round(num / p)); }
    return num.toFixed(-e);
  }

  /* ------------------------------------------------------------------ *
   * 11. Distance Modulus Calculator                                     *
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
    var m = parseFloat(appInput.value);
    var M = parseFloat(absInput.value);
    var modLatex, distLatex, srText;

    if (isNaN(m) || isNaN(M)) {
      modLatex = "\\ldots"; distLatex = "\\ldots";
      srText = "Enter values for m and M to compute the distance modulus and distance.";
    } else {
      var mod = m - M;
      var dist = Math.pow(10, (mod + 5) / 5);
      modLatex = isFinite(mod) ? flashNum(mod) : "\\ldots";

      var distSpoken;
      if (!isFinite(dist)) { distLatex = "\\ldots"; distSpoken = "undefined"; }
      else if (dist === 0) { distLatex = "0\\,\\mathrm{pc}"; distSpoken = "0 parsecs"; }
      else if (dist < 0.001 || dist > 100000) {
        var s = toScientific(dist, 3);
        distLatex = s.sig + "\\times10^{" + s.exp + "}\\,\\mathrm{pc}";
        distSpoken = s.sig + " times 10 to the " + s.exp + " parsecs";
      } else {
        var fn = formatNumber(dist, 3);
        distLatex = fn + "\\,\\mathrm{pc}";
        distSpoken = fn + " parsecs";
      }
      srText = "m minus M equals " + flashNum(mod) + " magnitudes. Distance d equals " + distSpoken + ".";
    }

    // Result split across the grid: modulus under "m - M", the rest under the
    // formula's right-hand side so both lines align vertically.
    setTex(calcModEl, modLatex);
    setTex(calcResEl, "= -5 + 5\\log_{10} " + distLatex);
    calcResultSrEl.textContent = srText;
  }

  /* ------------------------------------------------------------------ *
   * 12. Cluster selection                                               *
   * ------------------------------------------------------------------ */
  function buildSelect() {
    // "select cluster" first (index 0), then clusters in source order.
    var opt0 = document.createElement("option");
    opt0.value = ""; opt0.textContent = "select cluster";
    selectEl.appendChild(opt0);
    clusters.forEach(function (c) {
      var o = document.createElement("option");
      o.value = c.key; o.textContent = c.cluster.name;
      selectEl.appendChild(o);
    });
  }

  function loadCluster(key) {
    state.selectedKey = key;
    state.stars = [];
    var c = clusterByKey[key];
    if (c) {
      for (var i = 0; i < c.starList.length; i++) {
        var st = c.starList[i];
        var logTemp = getLogTempFromBV(st.BV);
        var bc = getBCFromLogTemp(logTemp);
        state.stars.push({
          x: sx(logTemp),
          logTemp: logTemp,
          appBolMag: st.appVisMag + bc     // apparent bolometric magnitude (mod applied at draw)
        });
      }
    }
  }

  /* ------------------------------------------------------------------ *
   * 13. Live region / diagram description (units always spoken)         *
   * ------------------------------------------------------------------ */
  function announce(msg) { liveEl.textContent = msg; }

  function updateDiagramDesc() {
    var c = clusterByKey[state.selectedKey];
    var parts = [];
    parts.push("Hertzsprung-Russell diagram. Horizontal axis temperature from 20000 kelvin on the left to 2500 kelvin on the right. Left vertical axis absolute magnitude; right vertical axis apparent magnitude.");
    parts.push("A red model main-sequence curve runs from about absolute magnitude minus 3 at 20000 kelvin down to about 13 at 2500 kelvin.");
    if (c) {
      parts.push(c.name + " selected: " + c.starList.length + " stars plotted as blue points.");
    } else {
      parts.push("No cluster selected.");
    }
    parts.push("Distance modulus m minus M is currently " + fixed1Spoken(state.distanceModulus) + " magnitudes.");
    if (state.showBar) {
      parts.push("Reference line shown at absolute magnitude " + fixed1Spoken(state.barAbsMag) +
        ", apparent magnitude " + fixed1Spoken(state.barAbsMag + state.distanceModulus) + ".");
    }
    diagramDescEl.textContent = parts.join(" ");
  }

  function updateDragAria() {
    dragEl.setAttribute("aria-valuenow", state.distanceModulus.toFixed(1));
    dragEl.setAttribute("aria-valuetext",
      "Distance modulus m minus M, " + fixed1Spoken(state.distanceModulus) + " magnitudes.");
  }

  /* ------------------------------------------------------------------ *
   * 14. Master render                                                   *
   * ------------------------------------------------------------------ */
  function render() {
    drawCanvas();
    positionRightTicks();
    positionBar();
    updateBarReadouts();
    updateDragAria();
    updateDiagramDesc();
  }

  /* ------------------------------------------------------------------ *
   * 15. Interaction — distance-modulus drag (pointer + keyboard)        *
   * ------------------------------------------------------------------ */
  function plotClientHeight() { return plotbox.getBoundingClientRect().height; }

  function setModulus(v, announceIt) {
    v = Math.max(MOD_MIN, Math.min(MOD_MAX, v));
    state.distanceModulus = v;
    render();
    if (announceIt) announce("Distance modulus m minus M " + fixed1Spoken(v) + " magnitudes.");
  }

  function initDragPointer() {
    var startY = 0, startMod = 0, dragging = false;
    dragEl.addEventListener("pointerdown", function (e) {
      dragEl.focus();
      dragging = true;
      startY = e.clientY;
      startMod = state.distanceModulus;
      dragEl.classList.add("cfe-dragging");
      try { dragEl.setPointerCapture(e.pointerId); } catch (err) {}
      e.preventDefault();
    });
    dragEl.addEventListener("pointermove", function (e) {
      if (!dragging) return;
      var h = plotClientHeight() || PLOT_H;
      // Matches AS: offset += scaleFactor * dyStage,  scaleFactor = -Y_RANGE/PLOT_H.
      var newMod = startMod - Y_RANGE * (e.clientY - startY) / h;
      setModulus(newMod, false);
    });
    function end() {
      if (!dragging) return;
      dragging = false;
      dragEl.classList.remove("cfe-dragging");
      announce("Distance modulus m minus M " + fixed1Spoken(state.distanceModulus) + " magnitudes.");
    }
    dragEl.addEventListener("pointerup", end);
    dragEl.addEventListener("pointercancel", end);
  }

  function initDragKeys() {
    dragEl.addEventListener("keydown", function (e) {
      var v = state.distanceModulus, handled = true;
      switch (e.key) {
        case "ArrowUp": case "ArrowRight": v += 0.1; break;
        case "ArrowDown": case "ArrowLeft": v -= 0.1; break;
        case "PageUp":   v += 1; break;
        case "PageDown": v -= 1; break;
        case "Home":     v = MOD_MIN; break;
        case "End":      v = MOD_MAX; break;
        default: handled = false;
      }
      if (handled) {
        e.preventDefault();
        setModulus(Math.round(v * 10) / 10, true);
      }
    });
  }

  /* ------------------------------------------------------------------ *
   * 16. Interaction — horizontal reference bar (pointer + keyboard)     *
   * ------------------------------------------------------------------ */
  function setBar(v, announceIt) {
    // Keep the line + readouts a few pixels inside the plot so they never cover
    // the temperature labels below (or the top edge). Margin scales with size.
    var h = plotClientHeight() || PLOT_H;
    var marginMag = 12 * Y_RANGE / h;
    v = Math.max(Y_MIN + marginMag, Math.min(Y_MAX - marginMag, v));
    state.barAbsMag = v;
    positionBar();
    updateBarReadouts();
    updateDiagramDesc();
    if (announceIt) announce("Reference line. Absolute magnitude " + fixed1Spoken(v) +
      ", apparent magnitude " + fixed1Spoken(v + state.distanceModulus) + ".");
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
      var h = plotClientHeight() || PLOT_H;
      var newVal = startVal + Y_RANGE * (e.clientY - startY) / h;  // down = fainter
      setBar(newVal, false);
      e.stopPropagation();
    });
    function end(e) {
      if (!dragging) return;
      dragging = false;
      announce("Reference line. Absolute magnitude " + fixed1Spoken(state.barAbsMag) +
        ", apparent magnitude " + fixed1Spoken(state.barAbsMag + state.distanceModulus) + ".");
    }
    barEl.addEventListener("pointerup", end);
    barEl.addEventListener("pointercancel", end);
  }

  function initBarKeys() {
    barEl.addEventListener("keydown", function (e) {
      var v = state.barAbsMag, handled = true;
      switch (e.key) {
        // ArrowUp moves the line UP (toward brighter, smaller magnitude).
        case "ArrowUp": case "ArrowLeft":  v -= 0.1; break;
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
   * 17. Controls wiring                                                 *
   * ------------------------------------------------------------------ */
  function initControls() {
    selectEl.addEventListener("change", function () {
      loadCluster(selectEl.value);
      render();
      var c = clusterByKey[state.selectedKey];
      announce(c ? (c.name + " selected. " + c.starList.length + " stars plotted.")
                 : "No cluster selected.");
    });

    showBarEl.addEventListener("change", function () {
      state.showBar = showBarEl.checked;
      barEl.hidden = !state.showBar;
      if (state.showBar) { positionBar(); updateBarReadouts(); }
      updateDiagramDesc();
      announce(state.showBar ? "Horizontal reference bar shown." : "Horizontal reference bar hidden.");
    });

    [appInput, absInput].forEach(function (el) {
      el.addEventListener("input", function () { sanitizeInput(el); updateCalculator(); });
    });
  }

  /* ------------------------------------------------------------------ *
   * 18. Reset (from the foundation masthead "sim-reset" event)          *
   * ------------------------------------------------------------------ */
  function onReset() {
    showBarEl.checked = false;
    state.showBar = false;
    barEl.hidden = true;
    state.barAbsMag = (Y_MIN + Y_MAX) / 2;
    selectEl.value = "";
    loadCluster("");
    state.distanceModulus = 0;
    appInput.value = "";
    absInput.value = "";
    updateCalculator();
    render();
    announce("Simulation reset.");
  }

  /* ------------------------------------------------------------------ *
   * 19. Static MathJax bits (axis-title variables, calc formula, minus) *
   * ------------------------------------------------------------------ */
  function typesetStatic() {
    document.querySelectorAll(".cfe-mj[data-tex]").forEach(function (el) {
      var tex = el.getAttribute("data-tex");
      if (tex) { el.innerHTML = "\\(" + tex + "\\)"; scheduleTypeset(el); }
    });
  }

  /* ------------------------------------------------------------------ *
   * 20. Boot                                                            *
   * ------------------------------------------------------------------ */
  function grab() {
    canvas = document.getElementById("cfe-canvas");
    ctx = canvas.getContext("2d");
    plotbox = document.getElementById("cfe-plotbox");
    dragEl = document.getElementById("cfe-drag");
    barEl = document.getElementById("cfe-bar");
    overlay = document.getElementById("cfe-overlay");
    selectEl = document.getElementById("cfe-cluster");
    showBarEl = document.getElementById("cfe-showbar");
    appInput = document.getElementById("cfe-app");
    absInput = document.getElementById("cfe-abs");
    liveEl = document.getElementById("cfe-live");
    diagramDescEl = document.getElementById("cfe-diagram-desc");
    barLeftEl = document.getElementById("cfe-bar-left");
    barRightEl = document.getElementById("cfe-bar-right");
    calcModEl = document.getElementById("cfe-calc-mod");
    calcResEl = document.getElementById("cfe-calc-res");
    calcResultSrEl = document.getElementById("cfe-calc-result-sr");
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

    loadCluster("");
    updateCalculator();
    render();

    // Typeset once MathJax is ready (it loads async).
    if (mathReady()) { mjReady = true; typesetStatic(); flushTypeset(); }
    else if (window.MathJax && MathJax.startup && MathJax.startup.promise) {
      MathJax.startup.promise.then(function () { mjReady = true; typesetStatic(); flushTypeset(); });
    } else {
      // Fallback: poll briefly for MathJax.
      var tries = 0;
      var iv = setInterval(function () {
        if (mathReady()) { clearInterval(iv); mjReady = true; typesetStatic(); flushTypeset(); }
        else if (++tries > 200) clearInterval(iv);
      }, 50);
    }
  }

  // kl-unl.js calls klunlInitEqn() on load; route it to our typesetting too.
  window.klunlInitEqn = function () { if (mjReady) { typesetStatic(); } };

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", boot);
  } else {
    boot();
  }
})();
