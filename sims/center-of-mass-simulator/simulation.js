/* ===========================================================================
   Center of Mass Simulator

   HTML5 / accessible port of the legacy Flash center-of-mass demonstrator.
   Audience: science educators, web maintainers, and future open-source
   contributors extending the KL-UNL catalog.

   Physics:

     On screen the two objects are always PIXEL_SEPARATION pixels apart; the
     separation control rescales the grid (distance units per square), not the
     pixel gap. With the center of mass at the object-container origin:

         x1 = -PIXEL_SEPARATION * m2 / (m1 + m2)      (left of CM)
         x2 = -x1 * m1 / m2                           (right of CM)

     which is the lever rule m1 · |x1| = m2 · |x2|. Labeled distances use the
     same ratio in distance units:

         r1 = m2 · d / (m1 + m2)      r2 = m1 · d / (m1 + m2)

     so r1 + r2 = d and m1 · r1 = m2 · r2. Sphere diameter scales as m^0.37 so
     a ten-fold mass change stays visually readable (not a literal volume model).

   Rendering: the grid and arrows are drawn on the canvas in legacy stage
   coordinates. Mass spheres and the CM cross are SVG overlays. Math labels are
   typeset by MathJax in the overlay above the canvas.
   =========================================================================== */

import {
  legToFixed, speak, snapFixed, amplifyArrowKey, updateSliderProgress,
  drawArrowhead, soon, announceLive
} from '../foundation/js/kl-unl-utils.js';

(function () {
  'use strict';

  /* =========================================================================
     1. CONSTANTS
     ========================================================================= */

  // Set up stage for grid diagram
  const PIXEL_SEPARATION = 200;
  const GRID_WIDTH       = 420;
  const GRID_HEIGHT      = 160;
  const GRID_HALF_WIDTH  = GRID_WIDTH  / 2;   // 210
  const GRID_HALF_HEIGHT = GRID_HEIGHT / 2;   //  80

  // Visual mass scaling exponent (not physical radius ∝ m^(1/3)).
  const MASS_SCALE_EXP   = 0.37;

  // Stage = drawn grid plus margin so outer grid lines are not clipped.
  // Origin (0, 0) is grid center — CM location when "keep CM fixed" is on.
  const STAGE_MARGIN = 4;
  const STAGE_W      = GRID_WIDTH  + 2 * STAGE_MARGIN;   // 428
  const STAGE_H      = GRID_HEIGHT + 2 * STAGE_MARGIN;   // 168
  const ORIGIN_X     = STAGE_W / 2;
  const ORIGIN_Y     = STAGE_H / 2;

  // Vertical placement of arrows and captions in stage coordinates.
  const ARROW_Y      = 41.5;
  const CM_TEXT_Y    = 16;
  const R_LABEL_Y    = 62;

  // Exported asset box sizes (images/*.svg).
  const MASS_ART     = 28;    // sphere.svg: 28 × 28, radius 14
  const CROSS_ART    = 12;    // cross.svg:  12 × 12

  const SLIDER_SPEC = {
    mass1: { min:  1, max: 10, init:  7, precision: 1, text: 'object 1 mass:' },
    mass2: { min:  1, max: 10, init:  3, precision: 1, text: 'object 2 mass:' },
    sep:   { min:  1, max: 20, init: 10, precision: 1, text: 'separation:'    }
  };
  // Product default is unchecked; keep in sync with index.html (no checked attr).
  const FIX_CM_INIT = false;

  // Quantities are dimensionless; spoken units name the abstract measure.
  const MASS_UNIT = 'mass unit';
  const DIST_UNIT = 'distance unit';

  /* =========================================================================
     2. STATE — one plain object; render() redraws everything from it
     ========================================================================= */

  const state = {
    mass1: SLIDER_SPEC.mass1.init,
    mass2: SLIDER_SPEC.mass2.init,
    sep:   SLIDER_SPEC.sep.init,
    fixCM: FIX_CM_INIT
  };

  // Derived layout and labeled distances from current masses and separation.
  function derive() {
    const m1 = state.mass1;
    const m2 = state.mass2;

    const artScale1 = Math.pow(m1, MASS_SCALE_EXP);
    const artScale2 = Math.pow(m2, MASS_SCALE_EXP);

    // Lever rule in pixel space (CM at container origin).
    const x1 = (-PIXEL_SEPARATION) * m2 / (m1 + m2);
    const x2 = (-x1) * m1 / m2;

    // Distances in user units: r1 + r2 = sep, m1·r1 = m2·r2.
    const factor = state.sep / (m1 + m2);
    const r1     = m2 * factor;
    const r2     = m1 * factor;

    // Arrowhead size tracks relative lever arms (legacy visual cue).
    const headScale1 = Math.sqrt((-x1) / PIXEL_SEPARATION);
    const headScale2 = Math.sqrt(  x2  / PIXEL_SEPARATION);

    // Separation slider → pixels per distance unit on the grid.
    const gridSpacing = PIXEL_SEPARATION / state.sep;

    // fixCM on: CM stays at stage center. Off: objects stay put, CM slides.
    const containerX = state.fixCM ? 0 : -(x1 + PIXEL_SEPARATION / 2);

    return { m1, m2, artScale1, artScale2, x1, x2, r1, r2,
             headScale1, headScale2, gridSpacing, containerX };
  }

  /* =========================================================================
     3. ELEMENTS
     ========================================================================= */

  const el = {
    stage:      document.getElementById('stage'),
    canvas:     document.getElementById('simCanvas'),
    canvasDesc: document.getElementById('canvasDesc'),
    live:       document.getElementById('liveRegion'),

    mass1:      document.getElementById('mass1'),
    mass2:      document.getElementById('mass2'),
    cmCross:    document.getElementById('cmCross'),

    lblM1:      document.getElementById('lblM1'),
    lblM2:      document.getElementById('lblM2'),
    lblCM:      document.getElementById('lblCM'),
    lblR1:      document.getElementById('lblR1'),
    lblR2:      document.getElementById('lblR2'),

    fixCM:      document.getElementById('fixCM')
  };

  const controls = {
    mass1: { num:   document.getElementById('mass1Num'),
             range: document.getElementById('mass1Slider'),
             spec:  SLIDER_SPEC.mass1, unit: MASS_UNIT, name: 'Object 1 mass' },
    mass2: { num:   document.getElementById('mass2Num'),
             range: document.getElementById('mass2Slider'),
             spec:  SLIDER_SPEC.mass2, unit: MASS_UNIT, name: 'Object 2 mass' },
    sep:   { num:   document.getElementById('sepNum'),
             range: document.getElementById('sepSlider'),
             spec:  SLIDER_SPEC.sep,   unit: DIST_UNIT, name: 'Separation' }
  };

  const ctx = el.canvas.getContext('2d');

  /* =========================================================================
     4. MATHJAX PLUMBING

     Typesetting is coalesced so slider drags do not queue a typeset per event.
     Each label remembers its last LaTeX so unchanged math is skipped.
     ========================================================================= */

  let   mathReady     = false;
  const mathSimple    = new Set();
  let   typesetQueued = false;

  // Center mass labels on glyph ink, not the MathJax box (subscripts add depth).
  // Re-measure after fonts load — first typeset may use fallback metrics.
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

  // Foundation klunlShowEquation typesets on its own schedule; watch new nodes.
  if (window.MutationObserver) {
    new window.MutationObserver(function (records) {
      for (let i = 0; i < records.length; i++) {
        const added = records[i].addedNodes;
        for (let j = 0; j < added.length; j++) {
          if (added[j].nodeType === 1) { klunlDetabEquation(added[j]); }
        }
      }
    }).observe(document.documentElement, { childList: true, subtree: true });
  }

  // Plain-text fallback if MathJax never loads.
  function setMath(element, latex, plain) {
    const key = latex;
    if (element.dataset.latex === key && element.dataset.rendered === String(mathReady)) {
      return;
    }
    element.dataset.latex    = key;
    element.dataset.rendered = String(mathReady);
    if (mathReady) {
      element.textContent = latex;
      mathSimple.add(element);
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
      if (!mathSimple.size) { return; }
      const targets = Array.from(mathSimple);
      mathSimple.clear();
      if (!window.MathJax || !window.MathJax.typesetPromise) { return; }
      try {
        if (window.MathJax.typesetClear) { window.MathJax.typesetClear(targets); }
        window.MathJax.typesetPromise(targets).then(function () {
          klunlDetabEquation(document.documentElement);
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
        callback();
      }
    }());
  }

  /* =========================================================================
     5. RENDER — canvas, DOM overlay, controls, and SR description from state
     ========================================================================= */

  // Canvas colors come from CSS variables so prefers-contrast applies to art.
  let palette = { grid: '#e0e0e0', blue: '#0066ff', red: '#cc0000' };

  function readPalette() {
    const cs   = window.getComputedStyle(document.documentElement);
    const pick = function (name, fallback) {
      const v = cs.getPropertyValue(name).trim();
      return v || fallback;
    };
    palette = {
      grid: pick('--com-grid', '#e0e0e0'),
      blue: pick('--com-blue', '#0066ff'),
      red:  pick('--com-red',  '#cc0000'),
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

  let sizeRetryPending   = false;
  let sizeRetries        =  0;
  const MAX_SIZE_RETRIES = 30;

  function drawCanvas(d) {
    const rect = el.stage.getBoundingClientRect();
    if (!rect.width || !rect.height) {
      // Stage not laid out yet (or tab never composited). Retry a bounded number
      // of times; resize / visibility listeners also call back when size appears.
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

    // Uniform scale: draw in legacy Flash stage coordinates.
    const k = bw / STAGE_W;
    ctx.setTransform(k, 0, 0, k, ORIGIN_X * k, ORIGIN_Y * k);
    ctx.clearRect(-ORIGIN_X, -ORIGIN_Y, STAGE_W, STAGE_H);

    // Grid lines at current spacing (separation units → pixels).
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

    ctx.save();
    ctx.translate(d.containerX, 0);

    // r1 (blue) and r2 (red) shafts with arrowheads.
    let sz1 = 2, sz2 = 0.5, sz3 = 2.5;
    let del = 2.5 / Math.sqrt(d.headScale2);
    ctx.beginPath();
    ctx.moveTo(d.x1 + sz1, ARROW_Y);
    ctx.lineTo(0    - sz1, ARROW_Y);
    ctx.lineWidth   = sz1;
    ctx.strokeStyle = palette.blue;
    ctx.fillStyle   = palette.blue;
    ctx.stroke();

    ctx.lineWidth   = sz2;
    drawArrowhead( ctx, [ d.x1, ARROW_Y ], [  sz3*del, del ] );
    drawArrowhead( ctx, [ 0,    ARROW_Y ], [ -sz3*del, del ] );

    ctx.beginPath();
    ctx.moveTo(0    + sz1, ARROW_Y);
    ctx.lineTo(d.x2 - sz1, ARROW_Y);
    ctx.lineWidth   = sz1;
    ctx.strokeStyle = palette.red;
    ctx.fillStyle   = palette.red;
    ctx.stroke();

    del *= Math.sqrt(d.headScale2 / d.headScale1);
    ctx.lineWidth   = sz2;
    drawArrowhead( ctx, [ d.x2, ARROW_Y ], [ -sz3*del, del ] );
    drawArrowhead( ctx, [ 0,    ARROW_Y ], [  sz3*del, del ] );

    ctx.restore();
  }

  function updateOverlay(d) {
    const cx = d.containerX;

    sizeInStage(el.mass1, MASS_ART * d.artScale1, MASS_ART * d.artScale1);
    sizeInStage(el.mass2, MASS_ART * d.artScale2, MASS_ART * d.artScale2);
    place(el.mass1, cx + d.x1, 0);
    place(el.mass2, cx + d.x2, 0);

    place(el.cmCross, cx, 0);

    // Mass labels at object centers; r captions midway along each arrow.
    place(el.lblM1, cx + d.x1,     0);
    place(el.lblM2, cx + d.x2,     0);
    place(el.lblCM, cx,            CM_TEXT_Y);
    place(el.lblR1, cx + d.x1 / 2, R_LABEL_Y);
    place(el.lblR2, cx + d.x2 / 2, R_LABEL_Y);
  }

  function updateLabels(d) {
    const sml_screen = 500;
    const sz = (window.innerWidth < sml_screen ) ? '\\Large ' : '';

    // Bold upright mass labels survive the dark outline on grey spheres.
    // chtml.scale 0.97 in index.html reduces top-of-glyph clipping.
    setMath(el.lblM1, '$$\\mathbf{\\vphantom{Z}m_{1}}$$', 'm1');
    setMath(el.lblM2, '$$\\mathbf{\\vphantom{Z}m_{2}}$$', 'm2');
    setMath(el.lblCM, '$$' + sz + '\\mathbf{CM}$$',  'CM');
    setMath(el.lblR1, '$$' + sz + 'r_1 = ' + legToFixed(d.r1, 2) + '$$',
                                  'r1 = '  + legToFixed(d.r1, 2) );
    setMath(el.lblR2, '$$' + sz + 'r_2 = ' + legToFixed(d.r2, 2) + '$$',
                                  'r2 = '  + legToFixed(d.r2, 2) );
  }

  // Color is never the only cue: each tinted term is named r1/r2 and spoken below.

  function describeDiagram(d) {
    const vm1 = speak(state.mass1, SLIDER_SPEC.mass1.precision, MASS_UNIT);
    const vm2 = speak(state.mass2, SLIDER_SPEC.mass2.precision, MASS_UNIT);
    const vd1 = speak(d.r1,        2,                           DIST_UNIT);
    const vd2 = speak(d.r2,        2,                           DIST_UNIT);
    const vsp = speak(state.sep,   2,                           DIST_UNIT);

    let heavier;
    if (state.mass1 > state.mass2) {
      heavier = 'Object 1 is the heavier object, so the center of mass lies closer to it.';
    } else if (state.mass2 > state.mass1) {
      heavier = 'Object 2 is the heavier object, so the center of mass lies closer to it.';
    } else {
      heavier = 'The two objects have equal mass, so the center of mass lies midway between them.';
    }

    const frame = state.fixCM
      ? 'The center of mass is fixed, so it stays at the middle of the grid and the two objects move when the masses change. '
      : 'The center of mass can shift position, so the two objects stay where they are and the center of mass moves between them. ';

    return 'Object 1, a sphere of ' + vm1 + ', is on the left; '  +
           'object 2, a sphere of ' + vm2 + ', is on the right, ' +
           'they are separated by ' + vsp + '. ' +
           'A green cross labeled C M marks the center of mass, located between them. ' +
           'A blue arrow spans r 1, ' + vd1 +
           ', from object 1 to the center of mass, and a red arrow spans r 2, ' +
           vd2 + ', from the center of mass to object 2. ' + heavier + ' ' + frame;
  }

  function syncControls(d) {
    Object.keys(controls).forEach(function (key) {
      const c     = controls[key];
      const value = state[key];
      const text  = legToFixed(value, c.spec.precision);
      // Always rewrite the text field from clamped state (including rejections).
      c.num.value   = text;
      c.range.value = String(value);

      updateSliderProgress(c.range);
    });
    el.fixCM.checked = state.fixCM;
  }

  function render() {
    const d = derive();
    drawCanvas(d);
    updateOverlay(d);
    updateLabels(d);
    syncControls(d);
    el.canvasDesc.textContent = describeDiagram(d);
    calibrateMassLabels();
    return d;
  }

  /* =========================================================================
     6. ANNOUNCEMENTS — on commit only, never on every drag tick
     ========================================================================= */

  function announce(message) {
    announceLive(el.live, message);
  }

  function distancesSentence(d) {
    const vd1 = speak(d.r1, 2, DIST_UNIT);
    const vd2 = speak(d.r2, 2, DIST_UNIT);
    let cmp;
    if        ( state.mass1 > state.mass2 )  {
      cmp = 'Because object 1 is more massive than object 2, ' +
            'it lies closer to the center of mass. ';
    } else if ( state.mass1 < state.mass2 )  {
      cmp = 'Because object 1 is less massive than object 2, ' +
            'it lies further from the center of mass. ';
    } else  {
      cmp = 'Because objects 1 and 2 are of equal mass, ' +
            'they lie the same distance from the center of mass. ';
    }
    return 'Object 1 is ' + vd1 + ' from the center of mass, and object 2 is '
           + vd2 + '. ' + cmp;
  }

  function announceControl(key, d) {
    const c = controls[key];
    announce(c.name + ' ' + speak(state[key], c.spec.precision, c.unit) + '. ' +
             distancesSentence(d));
  }

  /* =========================================================================
     7. INPUT — linked number boxes and sliders write the same state

     A catalog-wide binder may move to foundation once a second sim needs it;
     for now the commit / announce wording stays sim-specific here.
     ========================================================================= */

  function setValue(key, raw, announceIt=true) {
    const c    = controls[key];
    const spec = c.spec;

    if (typeof raw !== 'number' || Number.isNaN(raw) || !Number.isFinite(raw)) {
      const d = render();
      if (announceIt) {
        announce('Enter a number from ' + spec.min + ' to ' + spec.max + '. ' +
                 c.name + ' remains ' + speak(state[key], spec.precision, c.unit) + '.');
      }
      return d;
    }

    const outOfRange = raw < spec.min || raw > spec.max;
    state[key] = snapFixed(raw, spec.precision, spec.min, spec.max);
    const d = render();

    if (outOfRange) {
      announce('Value must lie within valid range (' + spec.min + ' to ' + spec.max + '). ' +
               c.name + ' ' + speak(state[key], spec.precision, c.unit) + '. ' +
               distancesSentence(d));
    } else if (announceIt) {
      announceControl(key, d);
    }
    return d;
  }

  Object.keys(controls).forEach(function (key) {
    const c = controls[key];

    // input = live while dragging / arrowing; change = commit + announce.
    c.range.addEventListener('input', function () {
      setValue(key, parseFloat(c.range.value), false);
    });
    c.range.addEventListener('change', function () {
      setValue(key, parseFloat(c.range.value), true);
    });

    // Number box: Enter, spin button, or blur commits.
    let keydownTriggered = false;
    c.num.addEventListener('keydown', function (event) {
      const isAllowedKey = ['Backspace', 'Delete', 'ArrowLeft', 'ArrowRight', 'Tab', 'Enter'].includes(event.key);
      const isDigit      = event.key >=  '0' && event.key <= '9';
      const isDecimal    = event.key === '.' && !c.num.value.includes('.');

      if ( !isAllowedKey  && !isDigit && !isDecimal && event.key.length === 1 &&
           !event.ctrlKey && !event.metaKey ) {
        event.preventDefault();
        return;
      }
      if (event.key === 'Enter') {
        event.preventDefault();
        keydownTriggered = true;
        setValue(key, parseFloat(c.num.value), true);
        c.num.blur();
      }
    });
    // Capture spin button events (clicking on up or down arrows within number box)
    c.num.addEventListener('change', function () {
      if (keydownTriggered) {
        keydownTriggered = false;
        return;
      }
      setValue(key, parseFloat(c.num.value), true);
    });
    c.num.addEventListener('blur', function () {
      if (keydownTriggered) {
        keydownTriggered = false;
        return;
      }
      setValue(key, parseFloat(c.num.value), true);
    });
  });

  el.fixCM.addEventListener('change', function () {
    state.fixCM = el.fixCM.checked;
    const d = render();
    announce(state.fixCM
      ? 'Keep CM fixed is on. The center of mass stays at the middle of the grid. '          + distancesSentence(d)
      : 'Keep CM fixed is off. The two objects stay in place and the center of mass moves. ' + distancesSentence(d));
  });

  document.addEventListener('sim-reset', function () {
    state.mass1 = SLIDER_SPEC.mass1.init;
    state.mass2 = SLIDER_SPEC.mass2.init;
    state.sep   = SLIDER_SPEC.sep.init;
    state.fixCM = FIX_CM_INIT;

    const d   = render();
    const vm1 = speak(state.mass1, SLIDER_SPEC.mass1.precision, MASS_UNIT);
    const vm2 = speak(state.mass2, SLIDER_SPEC.mass2.precision, MASS_UNIT);
    const vsp = speak(state.sep,   SLIDER_SPEC.sep.precision,   DIST_UNIT);
    const cms = state.fixCM ? 'fixed' : 'shifts';

    announce('Resetting simulator. ' +
             'Object 1 mass ' + vm1 + ', ' +
             'object 2 mass ' + vm2 + ', ' +
             'separation '    + vsp + '. ' +
             'C M position '  + cms + '. ' + distancesSentence(d));
  });

  // Shift (or Caps Lock) + arrow: ×10 (9+1) step via foundation amplifyArrowKey.
  controls.mass1.range.addEventListener('keydown', function (event) {
    amplifyArrowKey(event, controls.mass1.range, 9);
    updateSliderProgress(controls['mass1'].range);
  });
  controls.mass2.range.addEventListener('keydown', function (event) {
    amplifyArrowKey(event, controls.mass2.range, 9);
    updateSliderProgress(controls['mass2'].range); 
  });
  controls.sep.range.addEventListener('keydown',   function (event) {
    amplifyArrowKey(event, controls.sep.range, 9);
    updateSliderProgress(controls['sep'].range);
  });

  /* =========================================================================
     8. SIZING — stage scale drives overlay label size and redraw
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
  window.addEventListener('resize',   onGeometryChange);
  window.addEventListener('load',     onGeometryChange);
  window.addEventListener('pageshow', onGeometryChange);
  document.addEventListener('visibilitychange', onGeometryChange);

  if (window.matchMedia) {
    const contrastQuery = window.matchMedia('(prefers-contrast: more)');
    const onContrast    = function () { readPalette(); render(); };
    if (contrastQuery.addEventListener) {
      contrastQuery.addEventListener('change', onContrast);
    } else if (contrastQuery.addListener) {
      contrastQuery.addListener(onContrast);
    }
  }

  /* =========================================================================
     9. START-UP

     Foundation klunlInitEqn() is a stub; replace it here so MathJax ready
     (and a direct call below) both initialize the sim.
     ========================================================================= */

  window.klunlInitEqn = function () {
    readPalette();
    updateStageScale();
    render();

    whenMathJaxReady(function () {
      mathReady = !!(window.MathJax && window.MathJax.typesetPromise);
      if (!mathReady) { return; }
      render();

      if (document.fonts && document.fonts.ready) {
        document.fonts.ready.then(function () { render(); });
      }
    });
  };

  window.klunlInitEqn();
}());
