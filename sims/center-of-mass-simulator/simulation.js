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
  legToFixed, stepToPrec, speak,
  drawArrowhead, soon, pMod, keyAccel, announceLive, logAct,
  descMoreKeys, hideMoreKeys
} from '../foundation/js/kl-unl-utils.js';
import { DualControl } from '../foundation/js/kl-unl-dual-control.js';

logAct('INIT_centerofmasssimulator');

// Assume vanilla URL (masthead and control panels shown)
let urlClean = false;

let   canvasVar   = 0;  // cycle between updating mass 1, mass 2, and mass separation
let   canvasFocus = 'mass1';
const PARM_STEP   = 0.1;

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

  const PARM_PREC   = stepToPrec(String(PARM_STEP));

  const SLIDER_SPEC = {
    mass1: { min:  1, max: 10, init:  7, precision: PARM_PREC, text: 'object 1 mass:' },
    mass2: { min:  1, max: 10, init:  3, precision: PARM_PREC, text: 'object 2 mass:' },
    sep:   { min:  1, max: 20, init: 10, precision: PARM_PREC, text: 'separation:'    }
  };

  // Same rounding as DualControl, so state and the number boxes always agree.
  function quantize(n, spec) {
    const k = Math.pow(10, spec.precision);
    return Math.round(Math.min(Math.max(n, spec.min), spec.max) * k) / k;
  }

  // Product default is unchecked; keep in sync with index.html (no checked attr).
  // A URL cmf value replaces it so Reset returns to the linked setup.
  let FIX_CM_INIT = false;

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

  // dual (DualControl) is attached in section 8 once the helpers exist.
  const controls = {
    mass1: { mount: 'mass1-dual-mount', hint: 'massRangeHint', other: 'mass2',
             spec:  SLIDER_SPEC.mass1,  unit: MASS_UNIT,       name:  'Object 1 mass', dual: null },
    mass2: { mount: 'mass2-dual-mount', hint: 'massRangeHint', other: 'mass1',
             spec:  SLIDER_SPEC.mass2,  unit: MASS_UNIT,       name:  'Object 2 mass', dual: null },
    sep:   { mount: 'sep-dual-mount',   hint: 'sepRangeHint',  other: null,
             spec:  SLIDER_SPEC.sep,    unit: DIST_UNIT,       name:  'Separation',    dual: null }
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
    updateURL();
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

  // Silent: DualControl skips writes to a focused field mid-gesture and never
  // announces from here (announcements come from commit handlers only).
  function syncControls() {
    Object.keys(controls).forEach(function (key) {
      const dual = controls[key].dual;
      if (dual) { dual.setValue(state[key], { silent: true, source: 'sync' }); }
    });
    el.fixCM.checked = state.fixCM;
  }

  function render() {
    const d = derive();
    drawCanvas(d);
    updateOverlay(d);
    updateLabels(d);
    syncControls();
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
            'it lies farther from the center of mass. ';
    } else  {
      cmp = 'Because objects 1 and 2 are of equal mass, ' +
            'they lie the same distance from the center of mass. ';
    }
    return 'Object 1 is ' + vd1 + ' from the center of mass, and object 2 is '
           + vd2 + '. ' + cmp;
  }

  function controlSentence(key, d) {
    const c = controls[key];
    return c.name + ' ' + speak(state[key], c.spec.precision, c.unit) + '. ' +
           distancesSentence(d);
  }

  // A dragged mass reaching or passing the other mass (null otherwise).
  function massesEqualCrossing(key, v, prev) {
    const other = controls[key].other;
    if (!other || prev === state[other]) { return null; }
    return ((prev - state[other]) * (v - state[other]) <= 0) ? 'Masses equal.' : null;
  }

  /* =========================================================================
     7. URL — URL parameters can specify initial setup
     ========================================================================= */

  function applyURL()  {
    // Check loaded URL for initial setup parameters, allowing user to specify
    // mass 1 and 2, mass separation, and/or fixed or free center of mass  
    // position, as well as visibility of masthead and control panels.

    document.getElementById('canvas-more-keys').style.display = 'none';

    const urlParams = Object.fromEntries( new URLSearchParams(window.location.search) );

    if ( Object.keys(urlParams).length === 0 )  return;

    let URL_MS1, URL_MS2, URL_SEP, URL_CMF;

    // Define mass 1, mass 2, and mass separation 
    // (use simulation defaults for any unspecified values)
    // Keep tenths (the controls' step); clamp to each control's range.
    const fromURL = function (raw, spec) {
      const n = Number(raw);
      return (raw !== undefined && raw !== '' && Number.isFinite(n))
        ? quantize(n, spec)
        : spec.init;
    };
    URL_MS1 = fromURL(urlParams.ms1, SLIDER_SPEC.mass1);
    URL_MS2 = fromURL(urlParams.ms2, SLIDER_SPEC.mass2);
    URL_SEP = fromURL(urlParams.sep, SLIDER_SPEC.sep  );

    state.mass1 = SLIDER_SPEC.mass1.init = URL_MS1;
    state.mass2 = SLIDER_SPEC.mass2.init = URL_MS2;
    state.sep   = SLIDER_SPEC.sep.init   = URL_SEP;

    // Make center of mass fixed/free to shift if linked parameter is defined
    // (ignore any values but 1 or 0; anm is accepted from older links)
    const cmfParam = (urlParams.cmf !== undefined) ? urlParams.cmf : urlParams.anm;
    if ( cmfParam !== undefined )  {
      URL_CMF = cmfParam;
      if      ( URL_CMF == 1 )  { state.fixCM = FIX_CM_INIT = true;  }
      else if ( URL_CMF == 0 )  { state.fixCM = FIX_CM_INIT = false; }
    } else  { URL_CMF = FIX_CM_INIT; }
    syncControls();

    // Hide masthead and control panels (everything except canvas)
    // (hide if clean=true or clean=1)
    if ( (urlParams.clean !== undefined) && (JSON.parse(urlParams.clean) == true) )  {
      urlClean = true;
      document.getElementById('canvas-more-keys').style.display = 'block';
      document.getElementById('control-panel').style.display    = 'none';
      document.querySelector('.stage-panel').classList.add('stage-panel--clean');
      document.querySelectorAll('.app-layout').forEach((el) => {
        el.style.display        = 'flex';
        el.style.justifyContent = 'center';
      });

      // Update screen reader help for keyboard control over canvas
      document.getElementById('grid-instructions').innerHTML =
        'Use the arrow keys (or A and D) to change the mass of Object 1, '      + 
        'amplifying the effect with the Shift or Caps Lock keys. Press enter '  + 
        'once to update the mass of Object 2 similarly, and a second time to '  + 
        'update the object separation. Toggle keeping the center of mass '      + 
        'fixed or free with F, and reset the simulation with R.';

      // Re-direct skip link to new help (gear button) and strip masthead event listener
      const oldSkipLink = document.querySelector('.sr-only-focusable');
      if (oldSkipLink) {
        const newSkipLink       = oldSkipLink.cloneNode(true);
        newSkipLink.textContent = 'Skip to Keyboard Navigation';
        newSkipLink.setAttribute('href', '#canvas-more-keys');

        newSkipLink.addEventListener('click', (e) => {
          e.preventDefault();
          const gearBtn = document.getElementById('canvas-more-keys');
          if (gearBtn) gearBtn.focus();
        });

        oldSkipLink.parentNode.replaceChild(newSkipLink, oldSkipLink);
      }
    }
  }

  function updateURL()  {
    // Log current state parameters for possible URL-building

    // URL parameters are mass of objects 1 and 2, object separation, and
    // fixed/free nature of center of mass.
    const ms1 = state.mass1;
    const ms2 = state.mass2;
    const sep = state.sep;
    const cmf = +document.getElementById('fixCM').checked;

    let s0 = 'center-of-mass-simulator/index.html';    
    s0    += '?ms1=' + ms1 + '&ms2=' + ms2;
    s0    += '&sep=' + sep + '&cmf=' + cmf;

    window.stateURL = s0;
  }
  
  /* =========================================================================
     8. INPUT — foundation DualControl pairs (number box + muted slider)

     DualControl owns the gesture timing (silent mid-drag, one message on
     release); the commit wording stays sim-specific here.
     ========================================================================= */

  // Commit text for a DualControl release / Enter / blur. Typed commits carry
  // meta.invalid (not a number; value kept) or meta.clamped (pinned to an end).
  function commitSentence(key, meta) {
    const c    = controls[key];
    const spec = c.spec;
    const d    = derive();
    if (meta.invalid) {
      return 'Enter a number from ' + spec.min + ' to ' + spec.max + '. ' +
             c.name + ' remains ' + speak(state[key], spec.precision, c.unit) + '.';
    }
    if (meta.clamped) {
      return 'Value must lie within valid range (' + spec.min + ' to ' + spec.max + '). ' +
             controlSentence(key, d);
    }
    return controlSentence(key, d);
  }

  Object.keys(controls).forEach(function (key) {
    const c = controls[key];
    c.dual  = new DualControl({
      mount:       document.getElementById(c.mount),
      id:          key + '-ctl',
      label:       c.spec.text,
      min:         c.spec.min,
      max:         c.spec.max,
      step:        PARM_STEP,
      pageStep:    1,
      value:       state[key],
      minLabel:    String(c.spec.min),
      maxLabel:    String(c.spec.max),
      liveRegion:  el.live,
      describedBy: c.hint,
      milestone:   c.other ? function (v, prev) { return massesEqualCrossing(key, v, prev); } : null,
      onInput:     function (v) { state[key] = v; render(); },
      onChange:    function (v, meta) { return commitSentence(key, meta); }
    });
  });

  // Canvas keyboard mode (clean URL): same state path, announced per key press.
  function stepControl(key, next) {
    const prev    = state[key];
    state[key]    = controls[key].dual.setValue(next, { silent: true, source: 'canvas' });
    const d       = render();
    const crossed = (state[key] !== prev) ? massesEqualCrossing(key, state[key], prev) : null;
    announce((crossed ? crossed + ' ' : '') + controlSentence(key, d));
  }

  el.fixCM.addEventListener('change', function () {
    state.fixCM = el.fixCM.checked;
    const d = render();
    announce(state.fixCM
      ? 'Keep C M fixed is on. The center of mass stays at the middle of the grid. '          + distancesSentence(d)
      : 'Keep C M fixed is off. The two objects stay in place and the center of mass moves. ' + distancesSentence(d));
  });

  document.addEventListener('sim-reset', function () {
    reset();
  });

  function reset()  {
    state.mass1 = SLIDER_SPEC.mass1.init;
    state.mass2 = SLIDER_SPEC.mass2.init;
    state.sep   = SLIDER_SPEC.sep.init;
    state.fixCM = FIX_CM_INIT;
    applyURL();

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
  }

  el.canvas.addEventListener('keydown', (evt) => {

    if (!urlClean) return;
    
    // Change target (mass 1, mass 2, or separation of masses)
    if ( (evt.key == "Enter") || (evt.key == " ") )  {
      canvasVar = pMod( canvasVar + 1, 3 );
      if ( canvasVar == 1 )  { 
        canvasFocus = "mass2";
        announce( "Mass 2 control mode; " +
                  "arrow keys now decrease and increase mass 2. " +
                  "Press Enter to change separation of masses." );
      } else if ( canvasVar == 2 )  {
        canvasFocus = "sep";
        announce( "Mass separation control mode; " +
                  "arrow keys now decrease and increase separation of masses. " +
                  "Press Enter to change mass 1." );
      } else  {
        canvasFocus = "mass1";
        announce( "Mass 1 control mode; " +
                  "arrow keys now decrease and increase mass 1. " +
                  "Press Enter to change mass 2." );
      }
      evt.preventDefault();
      return;
    };
  
    // Keyboard control for reset and fixed/free center of mass 
    // when controls are hidden
    if (urlClean) {
      switch (evt.key) {
        case 'r': case 'R': reset();          return;
        case 'f': case 'F': el.fixCM.click(); return;
      }
    }
  
    // Keyboard control for the current target (mass 1, mass 2, or separation)
    const key  = canvasFocus;
    const spec = SLIDER_SPEC[key];
    const step = keyAccel(evt, PARM_STEP);
    let used   = true;
    switch (evt.key) {
      // MacOS+Voiceover users need an alternative to arrow keys
      case "ArrowLeft":  case "ArrowDown": case 'A': case 'a': stepControl(key, state[key] - step); break;
      case "ArrowRight": case "ArrowUp":   case 'D': case 'd': stepControl(key, state[key] + step); break;
      case "Home":                                             stepControl(key, spec.min);          break;
      case "End":                                              stepControl(key, spec.max);          break;
      default: used = false;
    }
    if (used) evt.preventDefault();
  });
  
  // Setting gear when only figure is shown
  document.getElementById('canvas-more-keys').addEventListener('click', () => descMoreKeys(urlClean));
  document.getElementById('closeKeyNavBtn').addEventListener(  'click', () => hideMoreKeys());

  /* =========================================================================
     9. SIZING — stage scale drives overlay label size and redraw
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
     10. START-UP

     Foundation klunlInitEqn() is a stub; replace it here so MathJax ready
     (and a direct call below) both initialize the sim.
     ========================================================================= */

  window.klunlInitEqn = function () {
    applyURL();
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
