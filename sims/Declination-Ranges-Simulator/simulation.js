/* ==========================================================================
   Declination Ranges Simulator  —  HTML5 port of latsim.swf (Flash / AS1)
   --------------------------------------------------------------------------
   Behaviour is ported from the decompiled ActionScript:
     scripts/simulator.as                     — latClass: calcRanges, radian,
                                                 degree, findControlRadius,
                                                 the lat property
     scripts/DefineSprite_90_simulator/...    — pers_tan drag handlers
     scripts/SliderV3forLat.as                — latitude slider + value format
     scripts/enlargeBox.as + FCheckBox init   — the "Enlarge Earth" checkbox

   Every constant, formula and on-screen string below is verbatim from that
   source. Presentation (panel structure, colour usage, labelling, keyboard
   paths) follows the KL-UNL foundation and WCAG 2.1 AA; the physics is
   untouched. See CONVERSION_NOTES.md and ACCESSIBILITY.md.
   ========================================================================== */

(function () {
  "use strict";

  /* --- Constants, verbatim from the AS source ----------------------------- */

  // Original Flash stage coordinates. The canvas keeps these internally and is
  // scaled by CSS, so all ported geometry matches the source exactly.
  var STAGE = 450;                 // the square diagram panel of the 660x450 stage
  var CX = 225, CY = 225;          // dial centre used throughout simulator.as

  var R_INNER = 165;               // band inner radius (simulator.as)
  var R_OUTER = 178;               // band outer radius (simulator.as)
  var BAND_ALPHA = 0.9;            // beginFill(color, 90) -> 90/100

  // Range label colours: DefineEditText textColor of cir_label / rise_label /
  // nev_label, which calcRanges reads back as cirColor / riseColor / nevColor.
  var CIR_COLOR = "#ff9900";       // rgb(255, 153, 0)
  var RISE_COLOR = "#33ccff";      // rgb( 51, 204, 255)
  var NEV_COLOR = "#33cc66";       // rgb( 51, 204, 102)
  var STAGE_BG = "#333333";        // shape 54/55 fill

  // SliderV3forLat on(initialize): initMin/initMax/initValue/initPrecision
  var LAT_MIN = -90;
  var LAT_MAX = 90;
  var LAT_INIT = 41;
  var LAT_PRECISION = 1;                                  // -> 1 decimal place
  var LAT_STEP = Math.pow(10, -LAT_PRECISION);            // _minIncrement = 0.1

  // Earth scale set by latClass / onEnterFrame: _xscale 20 normally, 100 when
  // the Enlarge Earth box is checked; alpha 100 -> 50 at the same time.
  var EARTH_SCALE_SMALL = 0.20;
  var EARTH_SCALE_LARGE = 1.00;
  var ENLARGED_ALPHA = 0.5;
  var ENLARGED_OFFSET = 25;        // observer moves onto the enlarged Earth's rim

  // Exported symbol geometry (twips/20 from the SWF placement matrices), so the
  // reused artwork lands at its original position, size and z-order.
  var ART = {
    // mySphere: shape 72, 350x350, registration point at its centre, at (225,225)
    sphere:   { src: "assets/sphere.svg",   w: 350,   h: 350,   ox: 175,    oy: 175,   x: 225,    y: 225 },
    // myGrid: shape 65 (tick marks), 374.8x374.8, registration (187.8,176.75), at (225.2,214.25)
    ticks:    { src: "assets/ticks.svg",    w: 374.8, h: 374.8, ox: 187.8,  oy: 176.75, x: 225.2, y: 214.25 },
    // myEarth: shape 74, 50.15x50.05, registration at its centre, at (224.8,224.75)
    earth:    { src: "assets/earth.svg",    w: 50.15, h: 50.05, ox: 25.05,  oy: 25.0,  x: 224.8,  y: 224.75 },
    // pers_tan: shape 88 (horizon line + observer), registration on the line at (224.95,225)
    observer: { src: "assets/observer.svg", w: 393,   h: 57.5,  ox: 196.45, oy: 56.0,  x: 224.95, y: 225 }
  };

  // Centre of the standing figure within observer.svg, in the symbol's own
  // local coordinates (measured from the exported artwork). Used to park the
  // keyboard focus ring on the figure rather than on the line's pivot.
  var FIGURE_LOCAL = { x: -0.2, y: -28.0 };

  // Fixed sky labels, at their original stage positions. np/sp shift when the
  // Earth is enlarged, exactly as onEnterFrame does (_y 192->182 and 237->247).
  var SKY_MARKS = {
    "mark-ncp":      { x: 228.5,  y: 74 },
    "mark-scp":      { x: 228.0,  y: 377 },
    "mark-ce-left":  { x: 77.8,   y: 225 },
    "mark-ce-right": { x: 370.75, y: 225 },
    "mark-np":       { x: 225.85, y: 199, yEnlarged: 189 },
    "mark-sp":       { x: 224.95, y: 244, yEnlarged: 254 }
  };

  // Declination tick labels, from the static text in the myGrid symbol
  // (texts/59-70). +/-90 appear once, at the top and bottom; the rest appear on
  // both halves of the dial.
  var DEC_LABELS = [90, 80, 60, 40, 20, 0, -20, -40, -60, -80, -90];
  var DEC_LABEL_RADIUS = 198;

  /* --- Small helpers ------------------------------------------------------ */

  // p.radian / p.degree in simulator.as, same constants.
  function radian(deg) { return deg * 0.017453292519943295; }
  function degree(rad) { return rad * 57.29577951308232; }

  function clamp(v, lo, hi) { return v < lo ? lo : (v > hi ? hi : v); }

  // SliderV3Class.setValue: round to the slider's precision, then clamp.
  function quantise(v) {
    var f = Math.pow(10, LAT_PRECISION);
    return clamp(Math.round(f * v) / f, LAT_MIN, LAT_MAX);
  }

  /* --- State (single source of truth) ------------------------------------- */

  var state = {
    lat: LAT_INIT,       // latClass: _lat, initialised from latSlider.initValue
    enlarge: false,      // enlargeClass: _enlarge
    dragging: false      // latClass: _active
  };

  var els = {};
  var ctx = null;
  var art = {};          // loaded <img> elements, keyed as in ART
  var artReady = false;

  /* --- calcRanges, ported verbatim from simulator.as ---------------------- */
  /*
     Returns both the three declination intervals used to shade the dial and the
     three on-screen strings. Variable names follow the AS source; the obfuscated
     locals are spelled out (_loc3_ -> cirStartVal, _loc2_ -> riseStartVal).
  */
  function calcRanges(lat) {
    var span = Math.round(10 * (90 - Math.abs(lat))) / 10;

    var cirStartVal = span;                                   // _loc3_
    var cirEndVal = 90;
    var riseStartVal = span;                                  // _loc2_
    var nevStartVal = Math.round(10 * (-(90 - Math.abs(lat)))) / 10;
    var riseEndVal = nevStartVal;
    var nevEndVal = -90;
    var temp;

    if (lat < 0) {
      temp = cirStartVal; cirStartVal = nevStartVal; nevStartVal = temp;
      temp = cirEndVal;   cirEndVal   = nevEndVal;   nevEndVal   = temp;
    }

    // Note the AS deliberately re-derives the printed number from |lat| rather
    // than from the (possibly swapped) interval endpoints.
    var cirStart, nevStart;
    if (cirStartVal != 0) {
      cirStart = "+" + Math.round(10 * (90 - Math.abs(lat))) / 10 + "°";
    } else {
      cirStart = (-Math.round(10 * (90 - Math.abs(lat))) / 10) + "°";
    }
    var cirEnd = "+90°";
    var riseStart = cirStart;

    if (nevStartVal != 0) {
      nevStart = (-Math.round(10 * (90 - Math.abs(lat))) / 10) + "°";
    } else {
      nevStart = Math.round(10 * (90 - Math.abs(lat))) / 10 + "°";
    }
    var riseEnd = nevStart;
    var nevEnd = "-90°";

    if (lat < 0) {
      temp = cirStart; cirStart = nevStart; nevStart = temp;
      temp = cirEnd;   cirEnd   = nevEnd;   nevEnd   = temp;
    }

    return {
      cirText:  (cirStartVal  == cirEndVal)  ? "None" : cirStart  + " to " + cirEnd,
      riseText: (riseStartVal == riseEndVal) ? "None" : riseStart + " to " + riseEnd,
      nevText:  (nevStartVal  == nevEndVal)  ? "None" : nevStart  + " to " + nevEnd,
      cir:  [cirStartVal,  cirEndVal],
      rise: [riseStartVal, riseEndVal],
      nev:  [nevStartVal,  nevEndVal]
    };
  }

  /* --- Latitude value formatting, from SliderV3forLat.setValue ------------- */
  /*
     _valueLabel.labelText = Math.abs(toFixed(_value)) + "°" + (" N" | " S" | "")
     Math.abs() on the fixed-point STRING is what drops a trailing ".0", so 41
     became "41° N" while 41.5 became "41.5° N". On screen the value is now the
     editable box, which holds signed degrees; this split into magnitude and
     hemisphere is what the spoken value is still built from.
  */
  function latParts(lat) {
    var v = quantise(lat);
    var fixed = v.toFixed(LAT_PRECISION);
    var direct = (Number(fixed) < 0) ? " S" : (Number(fixed) > 0 ? " N" : "");
    return { magnitude: Math.abs(Number(fixed)), direct: direct };
  }

  function latSpoken(lat) {                    // e.g. "41 degrees north"
    var p = latParts(lat);
    var word = p.direct === " N" ? " north" : (p.direct === " S" ? " south" : "");
    return p.magnitude + " degree" + (p.magnitude === 1 ? "" : "s") + word;
  }

  // "+49° to +90°"  ->  "plus 49 degrees to plus 90 degrees"; "None" is passed through.
  function rangeSpoken(text) {
    if (text === "None") return "None";
    return text
      .replace(/\+/g, "plus ")
      .replace(/-/g, "minus ")
      .replace(/°/g, " degrees");
  }

  /* --- MathJax plumbing --------------------------------------------------- */
  /*
     Every number, degree symbol and signed value in the UI is typeset by
     MathJax so it exposes the MathJax context menu (Show Math As...). Typeset
     calls are coalesced into one rAF batch: a drag can change the readouts far
     faster than MathJax can lay them out, and only the newest content matters.
  */
  var mathPending = Object.create(null);
  var mathScheduled = false;

  function setMath(el, latex) {
    if (!el || el.dataset.math === latex) return;
    el.dataset.math = latex;
    el.innerHTML = latex;
    mathPending[el.id || (el.id = "m" + Math.random().toString(36).slice(2))] = el;
    if (!mathScheduled) {
      mathScheduled = true;
      // A timer, not requestAnimationFrame: rAF is suspended in background or
      // unpainted tabs, which would leave the maths untypeset there.
      setTimeout(flushMath, 16);
    }
  }

  function flushMath() {
    mathScheduled = false;
    var nodes = [];
    for (var k in mathPending) nodes.push(mathPending[k]);
    mathPending = Object.create(null);
    if (nodes.length) typeset(nodes);
  }

  // MathJax v3 finishes booting asynchronously, so the first batch can be queued
  // before typesetPromise exists. Chain onto startup.promise when it is there and
  // retry otherwise, rather than silently dropping the nodes.
  function typeset(nodes) {
    var MJ = window.MathJax;
    if (!MJ || !MJ.typesetPromise) {
      setTimeout(function () { typeset(nodes); }, 50);
      return;
    }
    var run = function () { return MJ.typesetPromise(nodes).then(stripMathTabStops); };
    if (MJ.startup && MJ.startup.promise) {
      MJ.startup.promise = MJ.startup.promise.then(run)
        .catch(function (e) { console.error(e); });
    } else {
      run().catch(function (e) { console.error(e); });
    }
  }

  // MathJax's tex-svg output puts tabindex="0" on every <mjx-container>, which
  // would drop display-only maths into the Tab order (WCAG 2.4.3 / rule 8b).
  // The context menu still works with tabindex="-1".
  function stripMathTabStops() {
    var list = document.querySelectorAll("mjx-container[tabindex]");
    for (var i = 0; i < list.length; i++) list[i].setAttribute("tabindex", "-1");
  }

  // "+49° to +90°" -> inline maths for each endpoint, with "to" left as prose.
  function rangeLatex(text) {
    if (text === "None") return "None";
    var parts = text.split(" to ");
    return parts.map(function (p) {
      return "\\(" + p.replace(/°/g, "^{\\circ}") + "\\)";
    }).join(" to ");
  }

  /* --- Canvas drawing ----------------------------------------------------- */

  // Maps an AS dial angle (degrees) to a canvas arc angle. simulator.as places
  // points at x = 225 - r*cos(t), y = 225 - r*sin(t); canvas arc uses
  // x = cx + r*cos(a), y = cy + r*sin(a), so a = t + 180.
  function arcAngle(t) { return radian(t + 180); }

  // One annular sector between two dial angles, added to the current path.
  function addSector(t1, t2) {
    if (Math.abs(t2 - t1) < 1e-9) return;
    var a1 = arcAngle(t1), a2 = arcAngle(t2);
    var ccw = a2 < a1;
    ctx.moveTo(CX + R_OUTER * Math.cos(a1), CY + R_OUTER * Math.sin(a1));
    ctx.arc(CX, CY, R_OUTER, a1, a2, ccw);
    ctx.lineTo(CX + R_INNER * Math.cos(a2), CY + R_INNER * Math.sin(a2));
    ctx.arc(CX, CY, R_INNER, a2, a1, !ccw);
    ctx.closePath();
  }

  /*
     A declination band appears twice on an edge-on dial: once on the left half
     (angle = declination) and once mirrored on the right half (angle =
     180 - declination). The AS draws these as separate clips (cir_polar_1 /
     cir_polar_2 and friends); both halves go into ONE path here so the 90%
     fill alpha is applied once and no seam shows where they meet at the pole.
  */
  function drawBand(interval, color) {
    var d1 = interval[0], d2 = interval[1];
    if (Math.abs(d2 - d1) < 1e-9) return;          // a "None" range draws nothing
    ctx.beginPath();
    addSector(d1, d2);
    addSector(180 - d1, 180 - d2);
    ctx.globalAlpha = BAND_ALPHA;
    ctx.fillStyle = color;
    ctx.fill();
    ctx.globalAlpha = 1;
  }

  function drawArt(key, scale, alpha) {
    var a = ART[key], img = art[key];
    if (!img) return;
    if (scale === undefined) scale = 1;
    ctx.globalAlpha = (alpha === undefined) ? 1 : alpha;
    ctx.drawImage(img,
      a.x - a.ox * scale, a.y - a.oy * scale,
      a.w * scale, a.h * scale);
    ctx.globalAlpha = 1;
  }

  // pers_tan._x / _y in onEnterFrame. Normally the dial centre; when the Earth
  // is enlarged the observer stands on its surface:
  //   x = 225 - 25*cos(rotation + 90), y = 225 - 25*sin(rotation + 90)
  // with rotation = 90 - lat, which reduces to the form below.
  function observerPos() {
    if (!state.enlarge) return { x: CX, y: CY };
    return {
      x: CX + ENLARGED_OFFSET * Math.cos(radian(state.lat)),
      y: CY - ENLARGED_OFFSET * Math.sin(radian(state.lat))
    };
  }

  function drawStage(ranges) {
    ctx.setTransform(1, 0, 0, 1, 0, 0);
    ctx.fillStyle = STAGE_BG;
    ctx.fillRect(0, 0, STAGE, STAGE);
    if (!artReady) return;

    var dim = state.enlarge ? ENLARGED_ALPHA : 1;

    // Draw order follows the running original: celestial sphere, then the three
    // shaded bands over it at 90% alpha, then the tick dial, the Earth, and
    // finally the observer's horizon line on top.
    drawArt("sphere");

    drawBand(ranges.cir,  CIR_COLOR);
    drawBand(ranges.rise, RISE_COLOR);
    drawBand(ranges.nev,  NEV_COLOR);

    drawArt("ticks", 1, dim);
    drawArt("earth", state.enlarge ? EARTH_SCALE_LARGE : EARTH_SCALE_SMALL, dim);

    // pers_tan._rotation = 90 - lat, about the symbol's registration point.
    var pos = observerPos();
    var o = ART.observer;
    ctx.save();
    ctx.translate(pos.x, pos.y);
    ctx.rotate(radian(90 - state.lat));
    ctx.drawImage(art.observer, -o.ox, -o.oy, o.w, o.h);
    ctx.restore();
  }

  /* --- HTML overlays ------------------------------------------------------ */

  function pct(v) { return (v / STAGE * 100) + "%"; }

  function buildDecLabels() {
    var frag = document.createDocumentFragment();
    DEC_LABELS.forEach(function (dec) {
      // +/-90 sit at the poles and appear once; every other value is labelled on
      // both halves of the dial, as in the original grid symbol.
      var angles = (Math.abs(dec) === 90) ? [dec] : [dec, 180 - dec];
      angles.forEach(function (t) {
        var span = document.createElement("span");
        span.className = "dec-label";
        span.style.left = pct(CX - DEC_LABEL_RADIUS * Math.cos(radian(t)));
        span.style.top = pct(CY - DEC_LABEL_RADIUS * Math.sin(radian(t)));
        var sign = dec > 0 ? "+" : (dec < 0 ? "-" : "");
        setMath(span, "\\(" + sign + Math.abs(dec) + "^{\\circ}\\)");
        frag.appendChild(span);
      });
    });
    els.decLabels.appendChild(frag);
  }

  function placeSkyMarks() {
    Object.keys(SKY_MARKS).forEach(function (id) {
      var m = SKY_MARKS[id];
      var el = document.getElementById(id);
      if (!el) return;
      var y = (state.enlarge && m.yEnlarged !== undefined) ? m.yEnlarged : m.y;
      el.style.left = pct(m.x);
      el.style.top = pct(y);
    });
  }

  function placeObserverHandle() {
    var pos = observerPos();
    var t = radian(90 - state.lat);
    // Rotate the figure's local centre with the symbol so the focus ring lands
    // on the observer rather than on the line's pivot.
    var fx = FIGURE_LOCAL.x * Math.cos(t) - FIGURE_LOCAL.y * Math.sin(t);
    var fy = FIGURE_LOCAL.x * Math.sin(t) + FIGURE_LOCAL.y * Math.cos(t);
    els.handle.style.left = pct(pos.x + fx);
    els.handle.style.top = pct(pos.y + fy);
  }

  /* --- render(): one function redraws everything from state ---------------- */

  // The control the current change came from, if any. render() leaves that one
  // control's own text alone so it does not overwrite what is being typed.
  var echoTo = null;

  function render() {
    var ranges = calcRanges(state.lat);

    drawStage(ranges);
    placeSkyMarks();
    placeObserverHandle();
    els.holder.classList.toggle("is-enlarged", state.enlarge);

    // The editable box is the on-screen readout; the spoken value with its units
    // and hemisphere rides on the controls' aria-valuetext / aria-label.
    var spoken = latSpoken(state.lat);
    // Write the value back into both controls, EXCEPT into the one the user is
    // mid-edit in: rewriting the number field while it is being typed into would
    // fight the caret (typing "-2" on the way to "-24.7"). Everything else --
    // the wheel, the Page/Home/End keys, the slider, the drag, Reset -- must
    // still update it, so this is keyed on the originating event, not on focus.
    if (echoTo !== els.latSlider) {
      els.latSlider.value = String(quantise(state.lat));
    }
    els.latSlider.setAttribute("aria-valuetext", spoken);
    if (echoTo !== els.latNumber) {
      els.latNumber.value = String(quantise(state.lat));
    }

    els.handle.setAttribute("aria-valuenow", String(quantise(state.lat)));
    els.handle.setAttribute("aria-valuetext", "Latitude " + spoken);

    // Declination range readouts.
    setMath(els.cirRange, rangeLatex(ranges.cirText));
    setMath(els.riseRange, rangeLatex(ranges.riseText));
    setMath(els.nevRange, rangeLatex(ranges.nevText));
    els.cirRangeSr.textContent = rangeSpoken(ranges.cirText);
    els.riseRangeSr.textContent = rangeSpoken(ranges.riseText);
    els.nevRangeSr.textContent = rangeSpoken(ranges.nevText);

    // Text equivalent of the diagram, for anyone who cannot see the canvas.
    els.skyDesc.textContent =
      "Edge-on view of the celestial sphere for an observer at latitude " + spoken +
      ". Circumpolar declinations: " + rangeSpoken(ranges.cirText) +
      ". Rise and set declinations: " + rangeSpoken(ranges.riseText) +
      ". Never rise declinations: " + rangeSpoken(ranges.nevText) +
      ". The Earth is drawn " + (state.enlarge ? "enlarged" : "at its normal small size") + ".";

    return ranges;
  }

  // Announced on commit (release / change), never on every drag tick.
  function announce() {
    var ranges = calcRanges(state.lat);
    els.status.textContent =
      "Latitude " + latSpoken(state.lat) +
      ". Circumpolar " + rangeSpoken(ranges.cirText) +
      ". Rise and set " + rangeSpoken(ranges.riseText) +
      ". Never rise " + rangeSpoken(ranges.nevText) + ".";
  }

  // `source` is the control the change came from, when it is one whose own text
  // must not be rewritten underneath the user (see render()).
  function setLat(v, announceNow, source) {
    state.lat = clamp(v, LAT_MIN, LAT_MAX);
    echoTo = source || null;
    render();
    echoTo = null;
    if (announceNow) announce();
  }

  /* --- Pointer drag on the horizon line ----------------------------------- */
  /*
     DefineSprite_90_simulator frame 1: pressing pers_tan sets _active, and while
     active onMouseMove recomputes the latitude from the pointer angle:

        x   = _parent._xmouse - pers_tan._x
        y   = _parent._ymouse - pers_tan._y
        lat = -degree(Math.atan2(y, x)) - 90
        if (lat >  90) lat -= 90
        else if (lat < -90) lat = 180 + lat

     Pointer coordinates are mapped back through the current CSS scale first, so
     the arithmetic runs in original stage coordinates at any display size.
  */
  function toStage(evt) {
    var r = els.canvas.getBoundingClientRect();
    return {
      x: (evt.clientX - r.left) * (STAGE / r.width),
      y: (evt.clientY - r.top) * (STAGE / r.height)
    };
  }

  function latFromPointer(p) {
    var pos = observerPos();
    var x = p.x - pos.x;
    var y = p.y - pos.y;
    var lat = -degree(Math.atan2(y, x)) - 90;
    if (lat > 90) { lat -= 90; }
    else if (lat < -90) { lat = 180 + lat; }
    return lat;
  }

  // Is the pointer on the horizon line (or the figure standing on it)?
  // The stroke itself is only a few pixels wide, so a small tolerance is allowed
  // to keep the target usable with touch.
  var GRAB_TOLERANCE = 10;

  function onLine(p) {
    var pos = observerPos();
    var t = radian(90 - state.lat);
    var dx = p.x - pos.x, dy = p.y - pos.y;
    // Distance from the line through pos at angle t, and along it.
    var along = dx * Math.cos(t) + dy * Math.sin(t);
    var across = -dx * Math.sin(t) + dy * Math.cos(t);
    var o = ART.observer;
    if (Math.abs(along) <= o.w / 2 && Math.abs(across) <= GRAB_TOLERANCE) return true;
    // The standing figure sits above the line near its midpoint.
    return (Math.abs(along - FIGURE_LOCAL.x) <= 12 &&
            across <= 0 && across >= FIGURE_LOCAL.y * 2);
  }

  function onPointerDown(evt) {
    if (evt.button !== undefined && evt.button !== 0) return;
    var p = toStage(evt);
    if (!onLine(p)) return;
    state.dragging = true;                                   // _active = true
    els.holder.classList.add("is-dragging");
    els.handle.focus();                       // click-to-focus: arrows work next
    if (els.holder.setPointerCapture) {
      try { els.holder.setPointerCapture(evt.pointerId); } catch (e) { /* ignore */ }
    }
    evt.preventDefault();
    setLat(latFromPointer(p), false);
  }

  function onPointerMove(evt) {
    if (!state.dragging) return;
    evt.preventDefault();
    setLat(latFromPointer(toStage(evt)), false);
  }

  function onPointerUp() {
    if (!state.dragging) return;
    state.dragging = false;                                  // _active = false
    els.holder.classList.remove("is-dragging");
    announce();
  }

  /* --- Keyboard path for the same drag ------------------------------------ */

  function onHandleKey(evt) {
    var step = 1, big = 10, v = state.lat, handled = true;
    switch (evt.key) {
      case "ArrowRight": case "ArrowUp":   v += step; break;
      case "ArrowLeft":  case "ArrowDown": v -= step; break;
      case "PageUp":     v += big; break;
      case "PageDown":   v -= big; break;
      case "Home":       v = LAT_MIN; break;
      case "End":        v = LAT_MAX; break;
      default: handled = false;
    }
    if (!handled) return;
    evt.preventDefault();
    setLat(quantise(v), true);
  }

  /* --- Controls ----------------------------------------------------------- */

  function wireControls() {
    // Slider: native <input type="range"> gives arrows, Page, Home/End for free.
    els.latSlider.addEventListener("input", function () {
      setLat(Number(els.latSlider.value), false, els.latSlider);
    });
    els.latSlider.addEventListener("change", function () {
      setLat(Number(els.latSlider.value), true);
    });
    // Announce keyboard steps as they commit (a native range fires input, not
    // change, for each arrow press in some browsers).
    els.latSlider.addEventListener("keyup", function () { announce(); });

    // Number field: arrow keys come free with type="number"; add the wheel path
    // and the larger Page/Home/End steps.
    els.latNumber.addEventListener("input", function () {
      // A half-typed value like "-" or "" is not a number yet; leave the state
      // alone until it becomes one rather than snapping to 0.
      if (els.latNumber.value === "" || els.latNumber.value === "-") return;
      var v = Number(els.latNumber.value);
      if (isFinite(v)) setLat(v, false, els.latNumber);
    });
    els.latNumber.addEventListener("change", function () {
      // Committing an empty or malformed entry reverts to the latitude that is
      // actually in effect, rather than snapping to zero (Number("") === 0).
      var raw = els.latNumber.value.trim();
      var v = Number(raw);
      setLat((raw !== "" && isFinite(v)) ? v : state.lat, true);
      els.latNumber.value = String(quantise(state.lat));
    });
    els.latNumber.addEventListener("keydown", function (evt) {
      var v = state.lat, handled = true;
      switch (evt.key) {
        case "PageUp":   v += 10; break;
        case "PageDown": v -= 10; break;
        case "Home":     v = LAT_MIN; break;
        case "End":      v = LAT_MAX; break;
        default: handled = false;
      }
      if (!handled) return;
      evt.preventDefault();
      setLat(quantise(v), true);
    });
    els.latNumber.addEventListener("wheel", function (evt) {
      if (document.activeElement !== els.latNumber) return;   // only while focused
      evt.preventDefault();
      setLat(quantise(state.lat + (evt.deltaY < 0 ? LAT_STEP : -LAT_STEP)), true);
    }, { passive: false });

    // enlargeHandler(): this.enlarge = this.enlargeCheck.getValue()
    els.enlargeCheck.addEventListener("change", function () {
      state.enlarge = els.enlargeCheck.checked;
      render();
      els.status.textContent = state.enlarge
        ? "Earth enlarged. The observer now stands on the Earth's surface at latitude " +
          latSpoken(state.lat) + "."
        : "Earth returned to its normal small size.";
    });

    // Pointer drag on the diagram (mouse, pen and touch share one path).
    els.holder.addEventListener("pointerdown", onPointerDown);
    els.holder.addEventListener("pointermove", onPointerMove);
    els.holder.addEventListener("pointerup", onPointerUp);
    els.holder.addEventListener("pointercancel", onPointerUp);

    // Keyboard equivalent of the drag.
    els.handle.addEventListener("keydown", onHandleKey);

    // Reset comes from the shared masthead; restore the exact initial state.
    document.addEventListener("sim-reset", function () {
      state.lat = LAT_INIT;
      state.enlarge = false;
      state.dragging = false;
      els.enlargeCheck.checked = false;
      els.latSlider.value = String(LAT_INIT);
      els.latNumber.value = String(LAT_INIT);
      render();
      els.status.textContent = "Simulation reset. " + els.status.textContent;
      announce();
    });
  }

  /* --- Asset loading ------------------------------------------------------ */
  /*
     The dial's tick marks, the celestial sphere, the Earth and the observer are
     the EXPORTED vector artwork from the SWF, reused as-is. Only the three
     shaded bands are redrawn, because the AS builds them at runtime with
     beginFill/lineTo/curveTo and there is no exported file for them.
  */
  function loadArt(done) {
    var keys = Object.keys(ART);
    var left = keys.length;
    keys.forEach(function (k) {
      var img = new Image();
      img.onload = img.onerror = function () {
        art[k] = img;
        if (--left === 0) done();
      };
      img.src = ART[k].src;
    });
  }

  /* --- Boot --------------------------------------------------------------- */

  function init() {
    els.canvas = document.getElementById("sky-canvas");
    els.holder = document.getElementById("sphere-holder");
    els.decLabels = document.getElementById("dec-labels");
    els.handle = document.getElementById("observer-handle");
    els.latSlider = document.getElementById("lat-slider");
    els.latNumber = document.getElementById("lat-number");
    els.latMin = document.getElementById("lat-min");
    els.latMax = document.getElementById("lat-max");
    els.latUnit = document.querySelector(".lat-unit");
    els.enlargeCheck = document.getElementById("enlarge-check");
    els.cirRange = document.getElementById("cir-range");
    els.riseRange = document.getElementById("rise-range");
    els.nevRange = document.getElementById("nev-range");
    els.cirRangeSr = document.getElementById("cir-range-sr");
    els.riseRangeSr = document.getElementById("rise-range-sr");
    els.nevRangeSr = document.getElementById("nev-range-sr");
    els.skyDesc = document.getElementById("sky-desc");
    els.status = document.getElementById("sr-status");

    if (!els.canvas) return;
    ctx = els.canvas.getContext("2d");

    // Slider end labels, from SliderV3forLat.setMin / setMax:
    //   _minLabel = Math.abs(_min) + "° S";  _maxLabel = _max + "° N"
    setMath(els.latMin, "\\(" + Math.abs(LAT_MIN) + "^{\\circ}\\) S");
    setMath(els.latMax, "\\(" + LAT_MAX + "^{\\circ}\\) N");
    setMath(els.latUnit, "\\(^{\\circ}\\)");

    buildDecLabels();
    wireControls();
    render();

    loadArt(function () {
      artReady = true;
      render();
    });
  }

  // kl-unl.js calls klunlInitEqn() on load; redefine it so the sim owns its own
  // typesetting (the foundation's default would just clear the equation slot).
  window.klunlInitEqn = function () { stripMathTabStops(); };

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", init);
  } else {
    init();
  }
})();
