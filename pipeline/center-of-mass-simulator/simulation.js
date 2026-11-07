/* ===========================================================================
   Center of Mass Simulator

   HTML5 port of centerOfMass009.swf (ActionScript 1). Every constant, formula
   and piece of on-screen text below is taken verbatim from the decompiled
   source, principally scripts/DefineSprite_72/frame_1/DoAction.as (the update()
   controller), the four on(initialize) clip-action blocks that configure the
   three sliders and the checkbox, and scripts/Slider Logic Class v6.as (value
   quantisation and number formatting).

   Physics of the simulator:

     The two objects are always drawn PIXEL_SEPARATION apart on screen, no
     matter what the separation slider says; the separation slider rescales the
     grid instead. The centre of mass sits at the origin of the object
     container, so the two objects are placed at

         x1 = -PIXEL_SEPARATION * m2 / (m1 + m2)      (left of the CM)
         x2 = -x1 * m1 / m2                           (right of the CM)

     which is the lever rule m1 * |x1| = m2 * |x2|. The labelled distances are
     the same ratio expressed in the user's distance units,

         r1 = m2 * d / (m1 + m2)      r2 = m1 * d / (m1 + m2)

     with d the separation, so r1 + r2 = d and m1 r1 = m2 r2 always. Each object
     is drawn at 100 * m^0.37 percent of the exported sphere art, an area-like
     scaling chosen so a ten-fold mass change is legible on screen rather than
     a literal volume relation.

   Rendering: the grid and the two arrow shafts are the only art the
   ActionScript drew at run time (lineStyle / moveTo / lineTo), so they are the
   only art redrawn here, on the canvas, in the original stage coordinates.
   The mass spheres, the centre-of-mass cross and the arrowheads are exported
   Flash assets and are reused as-is from assets/shapes/. Every label is
   mathematics and is typeset by MathJax in an HTML overlay above the canvas.
   =========================================================================== */

(function () {
  'use strict';

  /* =========================================================================
     1. CONSTANTS - verbatim from the ActionScript
     ========================================================================= */

  // DefineSprite_72/frame_1/DoAction.as
  const PIXEL_SEPARATION = 200;
  const GRID_WIDTH       = 420;
  const GRID_HEIGHT      = 160;
  const GRID_HALF_WIDTH  = GRID_WIDTH  / 2;   // 210
  const GRID_HALF_HEIGHT = GRID_HEIGHT / 2;   // 80

  const MASS_SCALE_EXPONENT = 0.37;           // _xscale = 100 * m^0.37

  // Stage box for the canvas: the drawn grid plus a small margin so the
  // outermost grid lines are not sliced in half by the edge of the element.
  // The internal coordinate system is unchanged - (0, 0) is the grid centre,
  // which is where the centre of mass sits when "keep CM fixed" is on.
  const STAGE_MARGIN = 4;
  const STAGE_W  = GRID_WIDTH  + 2 * STAGE_MARGIN;   // 428
  const STAGE_H  = GRID_HEIGHT + 2 * STAGE_MARGIN;   // 168
  const ORIGIN_X = STAGE_W / 2;
  const ORIGIN_Y = STAGE_H / 2;

  // Fixed offsets inside the object container, measured off the exported
  // sprite renders (sprites/DefineSprite_71/1.png) and confirmed against the
  // screenshot of the running original (Capture.PNG).
  const ARROW_Y      = 41.5;   // the y of the two arrow shafts and arrowheads
  const CM_TEXT_Y    = 16;     // centre of the "CM" caption under the cross
  const R_LABEL_Y    = 62;     // centre of the r1 / r2 captions

  // Exported asset boxes (assets/shapes/*.svg, straight from the SWF).
  const MASS_ART      = 28;     // 53.svg: 28 x 28, ball centred, radius 14
  const CROSS_ART     = 12;     // 51.svg: 12 x 12, cross centred
  const ARROW_ART     = 22.6;   // 60.svg: 22.6 x 22.6 arrowhead
  const ARROW_TIP_X   = 0.5;    // where the point sits inside that box
  const ARROW_TIP_Y   = 11.3;

  // Presentation only. The AS sizes each arrowhead at 100*sqrt(|x|/200) percent
  // and this multiplier is applied on top of that, so the heads still grow and
  // shrink with their arrow exactly as the original did - they are just drawn a
  // little lighter, at the reviewer's request. Nothing reads this value except
  // the drawing code. See CONVERSION_NOTES.md.
  const ARROWHEAD_DISPLAY_SCALE = 0.8;

  // Slider configuration, verbatim from the on(initialize) clip actions on the
  // three "Standard Slider v6" instances in DefineSprite_72.
  const SLIDER_SPEC = {
    mass1: { min:  1, max: 10, init:  7, precision: 1, text: 'object 1 mass:' },
    mass2: { min:  1, max: 10, init:  3, precision: 1, text: 'object 2 mass:' },
    sep:   { min:  1, max: 20, init: 10, precision: 1, text: 'separation:'    }
  };
  // on(initialize) on the FCheckBoxSymbol instance: label " keep CM fixed",
  // initialValue true.
  const FIX_CM_INIT = true;

  // Spoken names and units. The original quantities are dimensionless - the
  // separation and the two distances share one arbitrary length unit and the
  // masses share one arbitrary mass unit - so the spoken form names the unit
  // as such rather than inventing a physical one.
  const MASS_UNIT = 'mass units';
  const DIST_UNIT = 'distance units';

  /* =========================================================================
     2. NUMBER FORMATTING - the AS1 toFixed polyfill, ported unchanged
     ========================================================================= */

  // Number.prototype.toFixed as defined in DefineSprite_72/frame_1 and again as
  // SliderLogicClassV6.toFixed. Kept rather than using the native toFixed so
  // that every displayed digit matches the original exactly.
  function asToFixed(x, fractionDigits) {
    const f = fractionDigits | 0;
    if (f < 0 || f > 20) { return 'Range Error'; }
    if (isNaN(x)) { return 'NaN'; }
    let s = '';
    if (x < 0) { s = '-'; x = -x; }
    let m = '';
    if (x < 1e21) {
      const n = Math.round(x * Math.pow(10, f));
      m = (n === 0) ? '0' : n.toString();
      if (f > 0) {
        let k = m.length;
        if (k <= f) {
          let z = '';
          for (let i = 0; i < f + 1 - k; i++) { z += '0'; }
          m = z + m;
          k = f + 1;
        }
        m = m.substr(0, k - f) + '.' + m.substr(k - f);
      }
    } else {
      m = x.toString();
    }
    return s + m;
  }

  // SliderLogicClassV6.getValueObjectFromValue for precisionMode
  // "fixed digits": clamp into range, then snap to the nearest 10^-precision.
  function quantise(spec, x) {
    if (x < spec.min) { x = spec.min; }
    else if (x > spec.max) { x = spec.max; }
    const minIncrement = Math.pow(10, -spec.precision);
    return minIncrement * Math.round(x / minIncrement);
  }

  function sliderText(spec, value) {
    return asToFixed(value, spec.precision);
  }

  /* =========================================================================
     3. STATE - one plain object; render() redraws everything from it
     ========================================================================= */

  const state = {
    mass1: SLIDER_SPEC.mass1.init,
    mass2: SLIDER_SPEC.mass2.init,
    sep:   SLIDER_SPEC.sep.init,
    fixCM: FIX_CM_INIT
  };

  // Everything the AS update() derives from the slider values, in one place.
  function derive() {
    const m1 = state.mass1;
    const m2 = state.mass2;

    // containerMC.massNMC._xscale = _yscale = 100 * Math.pow(mN, 0.37)
    const artScale1 = Math.pow(m1, MASS_SCALE_EXPONENT);
    const artScale2 = Math.pow(m2, MASS_SCALE_EXPONENT);

    // x1 = -pixelSeparation * m2 / (m1 + m2);  x2 = -x1 * m1 / m2
    const x1 = (-PIXEL_SEPARATION) * m2 / (m1 + m2);
    const x2 = (-x1) * m1 / m2;

    // factor = separationSlider.value / (m1 + m2)
    // label1 = m2 * factor      label2 = m1 * factor
    const factor = state.sep / (m1 + m2);
    const r1 = m2 * factor;
    const r2 = m1 * factor;

    // Arrowhead scaling: 100 * Math.sqrt(-x1 / pixelSeparation) and
    // 100 * Math.sqrt(x2 / pixelSeparation).
    const headScale1 = Math.sqrt((-x1) / PIXEL_SEPARATION);
    const headScale2 = Math.sqrt(x2 / PIXEL_SEPARATION);

    // gridSpacing = pixelSeparation / separationSlider.value
    const gridSpacing = PIXEL_SEPARATION / state.sep;

    // fixCMCheck.getValue() ? containerMC._x = 0
    //                       : containerMC._x = -(x1 + pixelSeparation / 2)
    const containerX = state.fixCM ? 0 : -(x1 + PIXEL_SEPARATION / 2);

    return { m1, m2, artScale1, artScale2, x1, x2, r1, r2,
             headScale1, headScale2, gridSpacing, containerX };
  }

  /* =========================================================================
     4. ELEMENTS
     ========================================================================= */

  const el = {
    stage:      document.getElementById('stage'),
    canvas:     document.getElementById('simCanvas'),
    canvasDesc: document.getElementById('canvasDesc'),
    live:       document.getElementById('liveRegion'),

    mass1:      document.getElementById('mass1'),
    mass2:      document.getElementById('mass2'),
    cmCross:    document.getElementById('cmCross'),
    arrowLeft1: document.getElementById('arrowLeft1'),
    arrowRight1:document.getElementById('arrowRight1'),
    arrowLeft2: document.getElementById('arrowLeft2'),
    arrowRight2:document.getElementById('arrowRight2'),

    lblM1:      document.getElementById('lblM1'),
    lblM2:      document.getElementById('lblM2'),
    lblCM:      document.getElementById('lblCM'),
    lblR1:      document.getElementById('lblR1'),
    lblR2:      document.getElementById('lblR2'),

    fixCM:      document.getElementById('fixCM')
  };

  const controls = {
    mass1: { num: document.getElementById('mass1Num'),
             range: document.getElementById('mass1Slider'),
             spec: SLIDER_SPEC.mass1, unit: MASS_UNIT, name: 'Object 1 mass' },
    mass2: { num: document.getElementById('mass2Num'),
             range: document.getElementById('mass2Slider'),
             spec: SLIDER_SPEC.mass2, unit: MASS_UNIT, name: 'Object 2 mass' },
    sep:   { num: document.getElementById('sepNum'),
             range: document.getElementById('sepSlider'),
             spec: SLIDER_SPEC.sep,   unit: DIST_UNIT, name: 'Separation' }
  };

  const ctx = el.canvas.getContext('2d');

  /* =========================================================================
     5. MATHJAX PLUMBING

     Every symbol shown anywhere in this simulator is typeset by MathJax, so
     right-clicking any of them opens the MathJax menu. Typesetting is
     coalesced into one animation frame so dragging a slider does not queue a
     typeset per pointer event, and each element remembers its last LaTeX so
     unchanged labels are never re-typeset.
     ========================================================================= */

  // Runs the callback once, on whichever of the next animation frame or a
  // short timer arrives first. requestAnimationFrame alone is not enough:
  // a background or not-yet-composited tab never fires it, which would leave
  // labels un-typeset and live-region updates unsent until the tab is shown.
  function soon(callback) {
    let done = false;
    const run = function () {
      if (done) { return; }
      done = true;
      callback();
    };
    window.requestAnimationFrame(run);
    window.setTimeout(run, 60);
  }

  let mathReady   = false;
  const mathDirty = new Set();
  let typesetQueued = false;

  // MathJax 3's CHTML output puts tabindex="0" on every <mjx-container> so the
  // container can take focus for its contextual menu. Typeset maths here is
  // display-only - diagram labels and an equation the user reads, never operates -
  // so leaving it in the tab order would put eight non-controls between the
  // real controls. Dropping to tabindex="-1" takes it out of the Tab sequence
  // while keeping it reachable programmatically, keeping it in the accessibility
  // tree, and leaving the right-click MathJax menu fully working.
  function detabMath(root) {
    const containers = (root && root.querySelectorAll)
      ? root.querySelectorAll('mjx-container[tabindex="0"]')
      : [];
    for (let i = 0; i < containers.length; i++) {
      containers[i].setAttribute('tabindex', '-1');
    }
    if (root && root.tagName === 'MJX-CONTAINER' && root.getAttribute('tabindex') === '0') {
      root.setAttribute('tabindex', '-1');
    }
  }

  // Centre the object labels on their glyphs rather than on their boxes.
  //
  // A MathJax container is as deep as the maths it holds, and "m" with a
  // subscript has depth below the baseline but nothing above it, so the box is
  // taller underneath the ink than over it. Centring that box on the sphere
  // leaves the visible glyph sitting low. The offset is a pure font-metric
  // ratio, so a value measured against the current font size stays correct at
  // every stage size; it is published as an em for the stylesheet to subtract.
  //
  // Deliberately NOT a one-shot measurement. MathJax inserts its container
  // before its web fonts have finished loading, and the glyph metrics of the
  // fallback font are different, so latching the first reading pins the labels
  // using numbers that stop being true a moment later. Re-measuring is two
  // getBoundingClientRect calls and cannot feed back on itself: the transform
  // being set moves the box and the ink together, leaving their difference
  // unchanged.
  let massShift = null;

  function calibrateMassLabels() {
    const ink = el.lblM1.querySelector('mjx-msub') || el.lblM1.querySelector('mjx-math');
    if (!ink) { return; }
    const inkBox = ink.getBoundingClientRect();
    const lblBox = el.lblM1.getBoundingClientRect();
    const fontPx = parseFloat(window.getComputedStyle(el.lblM1).fontSize);
    if (!inkBox.height || !lblBox.height || !fontPx) { return; }
    const shift = ((inkBox.top + inkBox.height / 2) -
                   (lblBox.top + lblBox.height / 2)) / fontPx;
    if (massShift !== null && Math.abs(shift - massShift) < 0.002) { return; }
    massShift = shift;
    document.documentElement.style.setProperty(
      '--mass-label-shift', shift.toFixed(4) + 'em');
  }

  // klunlShowEquation() in the foundation typesets on its own schedule, so
  // watch for new containers rather than only handling our own typeset calls.
  if (window.MutationObserver) {
    new window.MutationObserver(function (records) {
      for (let i = 0; i < records.length; i++) {
        const added = records[i].addedNodes;
        for (let j = 0; j < added.length; j++) {
          if (added[j].nodeType === 1) { detabMath(added[j]); }
        }
      }
    }).observe(document.documentElement, { childList: true, subtree: true });
  }

  // Plain-text stand-ins used only if MathJax never loads, so the simulator
  // stays readable instead of showing raw LaTeX.
  function setMath(element, latex, plain) {
    const key = latex;
    if (element.dataset.latex === key && element.dataset.rendered === String(mathReady)) {
      return;
    }
    element.dataset.latex = key;
    element.dataset.rendered = String(mathReady);
    if (mathReady) {
      element.textContent = latex;
      mathDirty.add(element);
      queueTypeset();
    } else {
      element.textContent = plain;
    }
  }

  function queueTypeset() {
    if (typesetQueued) { return; }
    typesetQueued = true;
    soon(function () {
      typesetQueued = false;
      if (!mathDirty.size) { return; }
      const targets = Array.from(mathDirty);
      mathDirty.clear();
      if (!window.MathJax || !window.MathJax.typesetPromise) { return; }
      try {
        if (window.MathJax.typesetClear) { window.MathJax.typesetClear(targets); }
        window.MathJax.typesetPromise(targets).then(function () {
          detabMath(document.documentElement);
          calibrateMassLabels();
        }).catch(function (err) {
          console.error('MathJax typeset failed', err);
        });
      } catch (err) {
        console.error('MathJax typeset failed', err);
      }
    });
  }

  function whenMathJaxReady(callback) {
    const started = Date.now();
    (function poll() {
      if (window.MathJax && window.MathJax.startup && window.MathJax.startup.promise) {
        window.MathJax.startup.promise.then(callback, callback);
      } else if (Date.now() - started < 10000) {
        window.setTimeout(poll, 50);
      } else {
        callback();   // give up quietly; the plain-text fallbacks stay
      }
    }());
  }

  /* =========================================================================
     6. RENDER - single entry point; canvas, DOM and the description all come
        from the same state on every call
     ========================================================================= */

  // Canvas colours live in styles/styles.css so that the prefers-contrast
  // variants apply to the drawn art as well as to the HTML.
  let palette = { grid: '#e0e0e0', blue: '#0066ff', red: '#ff0000', redText: '#cc0000' };

  function readPalette() {
    const cs = window.getComputedStyle(document.documentElement);
    const pick = function (name, fallback) {
      const v = cs.getPropertyValue(name).trim();
      return v || fallback;
    };
    palette = {
      grid:    pick('--com-grid',     '#e0e0e0'),
      blue:    pick('--com-blue',     '#0066ff'),
      red:     pick('--com-red',      '#ff0000'),
      // Text-weight red: #ff0000 clears 3:1 for a graphic but not 4.5:1 for
      // text, so the tinted numbers in the equation use the darker value.
      redText: pick('--com-red-text', '#cc0000')
    };
  }

  function pctX(x) { return ((x + ORIGIN_X) / STAGE_W) * 100; }
  function pctY(y) { return ((y + ORIGIN_Y) / STAGE_H) * 100; }

  function place(element, x, y) {
    element.style.left = pctX(x) + '%';
    element.style.top  = pctY(y) + '%';
  }

  function sizeInStage(element, w, h) {
    element.style.width  = (w / STAGE_W) * 100 + '%';
    element.style.height = (h / STAGE_H) * 100 + '%';
  }

  let sizeRetryPending = false;
  let sizeRetries      = 0;
  const MAX_SIZE_RETRIES = 30;

  function drawCanvas(d) {
    const rect = el.stage.getBoundingClientRect();
    if (!rect.width || !rect.height) {
      // The stage has no box yet: the page can still be laying out, or the tab
      // is hidden and has never been composited. Come back shortly - but only a
      // bounded number of times, so a tab that stays hidden does not sit in a
      // retry loop. The resize / load / visibilitychange listeners and the
      // ResizeObserver all call back in once the stage really does get a size.
      if (!sizeRetryPending && sizeRetries < MAX_SIZE_RETRIES) {
        sizeRetryPending = true;
        sizeRetries++;
        soon(function () { sizeRetryPending = false; updateStageScale(); render(); });
      }
      return;
    }
    sizeRetries = 0;

    const dpr = window.devicePixelRatio || 1;
    const bw  = Math.max(1, Math.round(rect.width  * dpr));
    const bh  = Math.max(1, Math.round(rect.height * dpr));
    if (el.canvas.width  !== bw) { el.canvas.width  = bw; }
    if (el.canvas.height !== bh) { el.canvas.height = bh; }

    // One uniform scale takes the 428 x 168 stage to the backing store, so all
    // drawing below stays in the original Flash coordinates.
    const k = bw / STAGE_W;
    ctx.setTransform(k, 0, 0, k, ORIGIN_X * k, ORIGIN_Y * k);
    ctx.clearRect(-ORIGIN_X, -ORIGIN_Y, STAGE_W, STAGE_H);

    // --- gridMC: lineStyle(1, 14737632, 100) then the two while loops -------
    ctx.beginPath();
    let k1 = Math.floor(GRID_HALF_WIDTH / d.gridSpacing);
    for (let i = -k1; i <= k1; i++) {
      ctx.moveTo(i * d.gridSpacing,  GRID_HALF_HEIGHT);
      ctx.lineTo(i * d.gridSpacing, -GRID_HALF_HEIGHT);
    }
    let k2 = Math.floor(GRID_HALF_HEIGHT / d.gridSpacing);
    for (let i = -k2; i <= k2; i++) {
      ctx.moveTo(-GRID_HALF_WIDTH, i * d.gridSpacing);
      ctx.lineTo( GRID_HALF_WIDTH, i * d.gridSpacing);
    }
    ctx.lineWidth   = 1;
    ctx.lineCap     = 'butt';
    ctx.strokeStyle = palette.grid;
    ctx.stroke();

    // --- containerMC.linesMC: the two arrow shafts --------------------------
    // lineStyle(1, 26367, 100); moveTo(x1, 0); lineTo(0, 0);
    // lineStyle(1, 16711680, 100); moveTo(0, 0); lineTo(x2, 0);
    ctx.save();
    ctx.translate(d.containerX, 0);

    ctx.beginPath();
    ctx.moveTo(d.x1, ARROW_Y);
    ctx.lineTo(0,    ARROW_Y);
    ctx.strokeStyle = palette.blue;
    ctx.stroke();

    ctx.beginPath();
    ctx.moveTo(0,    ARROW_Y);
    ctx.lineTo(d.x2, ARROW_Y);
    ctx.strokeStyle = palette.red;
    ctx.stroke();

    ctx.restore();
  }

  function placeArrowhead(element, tipX, asScale) {
    // The asset box is ARROW_ART square with its point at (0.5, 11.3); the
    // rotated heads spin about that point (transform-origin in the stylesheet),
    // so both orientations are positioned from the tip in the same way.
    const scale = asScale * ARROWHEAD_DISPLAY_SCALE;
    const w = ARROW_ART * scale;
    element.style.left   = pctX(tipX - ARROW_TIP_X * scale) + '%';
    element.style.top    = pctY(ARROW_Y - ARROW_TIP_Y * scale) + '%';
    sizeInStage(element, w, w);
  }

  function updateOverlay(d) {
    const cx = d.containerX;

    // containerMC.massNMC._x, at the original _xscale = 100 * m^0.37
    sizeInStage(el.mass1, MASS_ART * d.artScale1, MASS_ART * d.artScale1);
    sizeInStage(el.mass2, MASS_ART * d.artScale2, MASS_ART * d.artScale2);
    place(el.mass1, cx + d.x1, 0);
    place(el.mass2, cx + d.x2, 0);

    // The CM cross marks the container origin.
    place(el.cmCross, cx, 0);

    // linesMC.left1MC / right1MC at x1 and 0 (blue), left2MC / right2MC at 0
    // and x2 (red); the "right" heads are the same art rotated 180 degrees.
    placeArrowhead(el.arrowLeft1,  cx + d.x1, d.headScale1);
    placeArrowhead(el.arrowRight1, cx + 0,    d.headScale1);
    el.arrowRight1.style.transform = 'rotate(180deg)';
    placeArrowhead(el.arrowLeft2,  cx + 0,    d.headScale2);
    placeArrowhead(el.arrowRight2, cx + d.x2, d.headScale2);
    el.arrowRight2.style.transform = 'rotate(180deg)';

    // Labels. containerMC.massLabelN._x = xN; the r captions are centred on the
    // middle of their arrow, which is what
    //   label1._x = x1 / 2 - (labelField.textWidth + labelField._x) / 2
    // amounts to once the text is centred rather than left-anchored.
    place(el.lblM1, cx + d.x1, 0);
    place(el.lblM2, cx + d.x2, 0);
    place(el.lblCM, cx, CM_TEXT_Y);
    place(el.lblR1, cx + d.x1 / 2, R_LABEL_Y);
    place(el.lblR2, cx + d.x2 / 2, R_LABEL_Y);
  }

  function updateLabels(d) {
    // mc.labelN.labelField.text = (m * factor).toFixed(2)
    const r1Text = asToFixed(d.r1, 2);
    const r2Text = asToFixed(d.r2, 2);

    // Bold on the object labels: they sit on the grey spheres, where MathJax's
    // light italic strokes were too thin to survive the dark outline that gives
    // them contrast. \mathbf is upright bold, which is also how the SWF drew
    // these two labels. It is part of MathJax's base TeX package - \boldsymbol
    // is not, and this build renders it as literal red text.
    setMath(el.lblM1, '\\(\\mathbf{m_1}\\)', 'm1');
    setMath(el.lblM2, '\\(\\mathbf{m_2}\\)', 'm2');
    setMath(el.lblCM, '\\(\\mathrm{CM}\\)', 'CM');
    setMath(el.lblR1, '\\(r_1 = ' + r1Text + '\\)', 'r1 = ' + r1Text);
    setMath(el.lblR2, '\\(r_2 = ' + r2Text + '\\)', 'r2 = ' + r2Text);
  }

  // The relation is written as MathML rather than LaTeX so that r1, r2 and the
  // numbers that stand for them can be tinted to match their arrows on the
  // diagram. LaTeX's \color lives in a TeX extension that is not part of the
  // vendored MathJax bundle and would have to be fetched from the network;
  // MathML's own mathcolor attribute is built in. This is still real MathJax
  // output - right-clicking it opens the MathJax menu - and it degrades to
  // native browser MathML if the library is ever missing.
  //
  // Colour is never the only signal: each tinted term is also named r1 or r2,
  // and the spoken description below repeats both values with their units.
  function colourAttr(colour) {
    return colour ? ' mathcolor="' + colour + '"' : '';
  }

  function updateEquation(d) {
    const m1Text = sliderText(SLIDER_SPEC.mass1, state.mass1);
    const m2Text = sliderText(SLIDER_SPEC.mass2, state.mass2);
    const r1Text = asToFixed(d.r1, 2);
    const r2Text = asToFixed(d.r2, 2);
    const product = asToFixed(state.mass1 * d.r1, 2);

    const sub = function (base, index, colour) {
      return '<msub' + colourAttr(colour) + '>' +
             '<mi>' + base + '</mi><mn>' + index + '</mn></msub>';
    };
    const num = function (value, colour) {
      return '<mn' + colourAttr(colour) + '>' + value + '</mn>';
    };
    const TIMES   = '<mo>&#xD7;</mo>';       // multiplication sign
    const IMPLIED = '<mo>&#x2062;</mo>';     // invisible times
    const EQ      = '<mo>=</mo>';

    const row = function (left, right) {
      return '<mtr><mtd>' + left + '</mtd><mtd>' + EQ + '</mtd><mtd>' + right + '</mtd></mtr>';
    };

    const equation =
      '<math display="block">' +
      '<mtable columnalign="right center left" rowspacing="0.35em">' +
      row('<mrow>' + sub('m', 1) + IMPLIED + sub('r', 1, palette.blue) + '</mrow>',
          '<mrow>' + sub('m', 2) + IMPLIED + sub('r', 2, palette.redText) + '</mrow>') +
      row('<mrow>' + num(m1Text) + TIMES + num(r1Text, palette.blue) + '</mrow>',
          '<mrow>' + num(m2Text) + TIMES + num(r2Text, palette.redText) +
            EQ + num(product) + '</mrow>') +
      '</mtable></math>';

    const spoken =
      'The center of mass relation: mass 1 times r 1 equals mass 2 times r 2. ' +
      'With object 1 at ' + m1Text + ' ' + MASS_UNIT + ' and r 1 at ' + r1Text +
      ' ' + DIST_UNIT + ', and object 2 at ' + m2Text + ' ' + MASS_UNIT +
      ' and r 2 at ' + r2Text + ' ' + DIST_UNIT + ', both products equal ' +
      product + '.';

    if (typeof window.klunlShowEquation === 'function') {
      window.klunlShowEquation(
        ['eqnMain', equation],
        ['eqnSrMsg', spoken],
        ['eqnSrFig', describeDiagram(d)]
      );
    }
  }

  function describeDiagram(d) {
    const m1Text = sliderText(SLIDER_SPEC.mass1, state.mass1);
    const m2Text = sliderText(SLIDER_SPEC.mass2, state.mass2);
    const sepText = sliderText(SLIDER_SPEC.sep, state.sep);
    const r1Text = asToFixed(d.r1, 2);
    const r2Text = asToFixed(d.r2, 2);

    let heavier;
    if (state.mass1 > state.mass2) {
      heavier = 'Object 1 is the heavier object, so the center of mass lies closer to it.';
    } else if (state.mass2 > state.mass1) {
      heavier = 'Object 2 is the heavier object, so the center of mass lies closer to it.';
    } else {
      heavier = 'The two objects have equal mass, so the center of mass lies midway between them.';
    }

    const frame = state.fixCM
      ? 'Keep CM fixed is on, so the center of mass stays at the middle of the grid and the two objects move when the masses change.'
      : 'Keep CM fixed is off, so the two objects stay where they are and the center of mass moves between them.';

    return 'Object 1, of mass ' + m1Text + ' ' + MASS_UNIT + ', is on the left; ' +
           'object 2, of mass ' + m2Text + ' ' + MASS_UNIT + ', is on the right, ' +
           'separated by ' + sepText + ' ' + DIST_UNIT + '. ' +
           'A green cross labelled C M marks the center of mass. ' +
           'A blue arrow spans r 1, ' + r1Text + ' ' + DIST_UNIT +
           ', from object 1 to the center of mass, and a red arrow spans r 2, ' +
           r2Text + ' ' + DIST_UNIT + ', from the center of mass to object 2. ' +
           heavier + ' ' + frame;
  }

  function syncControls(d) {
    Object.keys(controls).forEach(function (key) {
      const c = controls[key];
      const value = state[key];
      const text = sliderText(c.spec, value);
      // StandardSliderClassV6.updateSynchronization always rewrote the field
      // from the committed value, including after a rejected entry.
      c.num.value = text;
      c.range.value = String(value);
      c.range.setAttribute('aria-valuetext', c.name + ' ' + text + ' ' + c.unit);
    });
    el.fixCM.checked = state.fixCM;
  }

  function render() {
    const d = derive();
    drawCanvas(d);
    updateOverlay(d);
    updateLabels(d);
    updateEquation(d);
    syncControls(d);
    el.canvasDesc.textContent = describeDiagram(d);
    // Cheap and self-gating. Called here as well as after a typeset because the
    // first typeset can land before the stage has a box to measure against, and
    // nothing else would typeset again until the user changed something.
    calibrateMassLabels();
    return d;
  }

  /* =========================================================================
     7. ANNOUNCEMENTS - on commit only, never on every drag tick
     ========================================================================= */

  function announce(message) {
    // Re-setting identical text does not always re-trigger a live region, so
    // clear first and set on the next frame.
    el.live.textContent = '';
    soon(function () {
      el.live.textContent = message;
    });
  }

  function distancesSentence(d) {
    return 'Object 1 is ' + asToFixed(d.r1, 2) + ' ' + DIST_UNIT +
           ' from the center of mass; object 2 is ' + asToFixed(d.r2, 2) +
           ' ' + DIST_UNIT + '.';
  }

  function announceControl(key, d) {
    const c = controls[key];
    announce(c.name + ' ' + sliderText(c.spec, state[key]) + ' ' + c.unit + '. ' +
             distancesSentence(d));
  }

  /* =========================================================================
     8. INPUT - pointer and keyboard both write to the same state
     ========================================================================= */

  function setValue(key, raw, announceIt) {
    const spec = controls[key].spec;
    // StandardSliderClassV6.setValue: a non-finite value leaves the old one in
    // place and the field is simply re-synchronised from state.
    if (typeof raw === 'number' && !isNaN(raw) && isFinite(raw)) {
      state[key] = quantise(spec, raw);
    }
    const d = render();
    if (announceIt) { announceControl(key, d); }
  }

  Object.keys(controls).forEach(function (key) {
    const c = controls[key];

    // Slider: "input" updates live while dragging or arrowing, "change" is the
    // commit point where the result is announced.
    c.range.addEventListener('input', function () {
      setValue(key, parseFloat(c.range.value), false);
    });
    c.range.addEventListener('change', function () {
      setValue(key, parseFloat(c.range.value), true);
    });

    // Value box: Enter commits, as it did in the Flash field's onKeyDown, and
    // losing focus commits, as its onKillFocus did.
    c.num.addEventListener('keydown', function (event) {
      if (event.key === 'Enter') {
        event.preventDefault();
        setValue(key, parseFloat(c.num.value), true);
      }
    });
    c.num.addEventListener('blur', function () {
      setValue(key, parseFloat(c.num.value), true);
    });
  });

  el.fixCM.addEventListener('change', function () {
    state.fixCM = el.fixCM.checked;
    const d = render();
    announce(state.fixCM
      ? 'Keep CM fixed is on. The center of mass stays at the middle of the grid. ' + distancesSentence(d)
      : 'Keep CM fixed is off. The two objects stay in place and the center of mass moves. ' + distancesSentence(d));
  });

  // The masthead dispatches a bubbling, composed "sim-reset" event.
  document.addEventListener('sim-reset', function () {
    state.mass1 = SLIDER_SPEC.mass1.init;
    state.mass2 = SLIDER_SPEC.mass2.init;
    state.sep   = SLIDER_SPEC.sep.init;
    state.fixCM = FIX_CM_INIT;
    const d = render();
    announce('Simulator reset. ' +
             'Object 1 mass ' + sliderText(SLIDER_SPEC.mass1, state.mass1) + ' ' + MASS_UNIT + ', ' +
             'object 2 mass ' + sliderText(SLIDER_SPEC.mass2, state.mass2) + ' ' + MASS_UNIT + ', ' +
             'separation ' + sliderText(SLIDER_SPEC.sep, state.sep) + ' ' + DIST_UNIT + ', ' +
             'keep CM fixed on. ' + distancesSentence(d));
  });

  /* =========================================================================
     9. SIZING - the stage scale drives the overlay label size and a redraw
     ========================================================================= */

  function updateStageScale() {
    const width = el.stage.getBoundingClientRect().width;
    if (!width) { return; }
    document.documentElement.style.setProperty('--stage-scale',
      String(Math.round((width / STAGE_W) * 1000) / 1000));
  }

  function onGeometryChange() {
    updateStageScale();
    render();
  }

  if (window.ResizeObserver) {
    new window.ResizeObserver(onGeometryChange).observe(el.stage);
  }
  // Kept alongside the observer rather than as an either/or: it also covers a
  // devicePixelRatio change when the window is dragged to another display, and
  // browsers without ResizeObserver.
  window.addEventListener('resize', onGeometryChange);
  window.addEventListener('load', onGeometryChange);
  window.addEventListener('pageshow', onGeometryChange);
  // A tab that was hidden when the sim loaded may have had no layout at all.
  document.addEventListener('visibilitychange', onGeometryChange);

  if (window.matchMedia) {
    const contrastQuery = window.matchMedia('(prefers-contrast: more)');
    const onContrast = function () { readPalette(); render(); };
    if (contrastQuery.addEventListener) {
      contrastQuery.addEventListener('change', onContrast);
    } else if (contrastQuery.addListener) {
      contrastQuery.addListener(onContrast);
    }
  }

  /* =========================================================================
     10. START-UP

     kl-unl.js defines klunlInitEqn() as a stub meant to be replaced by the
     simulation; this is that replacement.
     ========================================================================= */

  window.klunlInitEqn = function () {
    readPalette();
    updateStageScale();
    render();

    whenMathJaxReady(function () {
      mathReady = !!(window.MathJax && window.MathJax.typesetPromise);
      if (!mathReady) { return; }
      // Re-issue every label now that real typesetting is available. All maths
      // on the page is written by render(), so there is nothing else to
      // typeset (start-up typesetting is turned off in index.html so that the
      // ordering is under our control).
      render();

      // The object labels are positioned from their glyph metrics, which are
      // only final once MathJax's web fonts have actually arrived.
      if (document.fonts && document.fonts.ready) {
        document.fonts.ready.then(function () { render(); });
      }
    });
  };

  window.klunlInitEqn();
}());
