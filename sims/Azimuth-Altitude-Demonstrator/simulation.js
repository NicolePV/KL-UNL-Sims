/* ===========================================================================
   Azimuth/Altitude Demonstrator: HTML5 port of altAzDemo005 (legacy Flash AS1)
   ---------------------------------------------------------------------------
   Rendering uses an HTML5 <canvas> for code-drawn geometry (sphere shading,
   horizon plane, circles, arcs, pole stubs, markers, and feature labels) and
   images for the star and stick figure. Feature labels and degree readouts are 
   announced via canvas aria-label and live region.
   
   Math (rotation matrices, great/small-circle front/back splitting,
   screen<->horizon conversion, drag + snapping) is kept identical to legacy 
   source so positions, arcs and drag behavior match original.
   =========================================================================== */

// Import celestial sphere and utilities module components
import {
  CelestialSphere, Circle, Line,
  CELESTIAL_SPHERE_COLORS,
  D2R, R2D, TWO_PI, HALF_PI, PI,
  drawCircleBucket, drawCircleArcBack,
  drawLineLayer, drawGlass, drawMarker, drawStarSprite, 
//drawCircleHatch,
  projectPointScreen, isScreenFront, drawOrientedLabel, 
  locateStar, absOrient, radialUp
} from '../foundation/js/kl-unl-celestial-sphere.js';

import {
  legToFixed, stepToPrec, speak, listLabels, pMod, snapFixed, keyAccel,
  hexToRGBA, soon, announceLive, announceSettled, VO_FIX_LGND, logAct,
  updateShowHideLabelButtons, descMoreKeys, hideMoreKeys
} from '../foundation/js/kl-unl-utils.js';

import { DualControl } from '../foundation/js/kl-unl-dual-control.js';

// Log initialization, browser, platform, and screen size in server access log
logAct("INIT_AltAz");

// Assume vanilla URL (masthead and control panels shown)
let urlClean = false;

const AZ_STEP   = 1;
const ALT_STEP  = 1;
const AZ_PREC   = stepToPrec(String(AZ_STEP ));
const ALT_PREC  = stepToPrec(String(ALT_STEP));

// Adjust DualControl labels for mid-wide screens via two breakpoints
const brkpt1      = 65;  // first  breakpoint, at 65rem
const brkpt2      = 75;  // second breakpoint, at 75rem
const mediaCheck1 = window.matchMedia('(min-width: ' + brkpt1 + 'rem)');
const mediaCheck2 = window.matchMedia('(min-width: ' + brkpt2 + 'rem)');

/** Announce once when altitude crosses the horizon (0°). */
function altHorizonCrossing(v, prev) {
  if (prev == null || !isFinite(prev) || v === prev) return false;
  if ((prev < 0 && v >= 0) || (prev > 0 && v <= 0))
    return 'Crossing the horizon.';
  return false;
}

// Update screen reader help for MacOS+Voiceover issues
document.getElementById('skyHelp').innerHTML =
  'Drag, or use the arrow keys, to rotate the view. ' + VO_FIX_LGND;
document.getElementById('starHandleHelp').innerHTML =
  'Drag, or use the arrow keys, to move star in azimuth and altitude. ' + VO_FIX_LGND;

/* =========================================================================
   App: controller, canvas renderer, UI wiring.
   Projection engine: foundation/js/kl-unl-celestial-sphere.js
   ========================================================================= */
class App {
  constructor() {
    this.S     = new CelestialSphere();
    this.S.CSC = CELESTIAL_SPHERE_COLORS;
    this.S.setSize(320);              // sphereMC.size = 320  -> r = 160
    this.S.setMinPhi(1);              // minViewerAltitude = 1
    this.S.setMaxPhi(90);

    this.STAGE  = 440;                // canvas internal size (square)
    this.CENTER = 220;
    this.dpr    = Math.max(1, Math.min(3, window.devicePixelRatio || 1));

    // star state (horizon az/alt in degrees)
    this.star = { az: 140, alt: 45, sp: { x: 0, y: 0, z: 0 } };

    // label checkbox visibility (zenith/horizon/nadir/meridian)
    this.labels = { zenith: false, horizon: false, nadir: false, meridian: false };

    this.buildCircles();
    this.buildLines();
    this.cacheDom();
    this.buildDualControls();
    this.loadAssets();
    this.bindEvents();

    this.reset();
  }

  /* =========================================================================
     Define fixed and shifting circles and arcs on celestial sphere
       - meridian2: secondary great circle          (faint grey, zenith-E-nadir-W)
       - altCircle: stellar guide small circle      (light grey, at altitude)
       - azCircle:  stellar guide half-great circle (light grey, at azimuth )
       - meridian:  principal great circle          (dark green, zenith-N-nadir-S)
       - altArc:    stellar guide arc               (red,        at azimuth )
       - azArc:     stellar guide arc               (blue,       at horizon )
     ========================================================================= */
  buildCircles() {
    const S = this.S;
    this.meridian2 = new Circle(S, { thickness: 1, color: this.S.CSC.MRDN2_CIRC, alpha: 0.1 });
    this.azCircle  = new Circle(S, { thickness: 1, color: this.S.CSC.AZ_CIRC,    alpha: 1   });
    this.altCircle = new Circle(S, { thickness: 1, color: this.S.CSC.ALT_CIRC,   alpha: 1   });
    this.meridian  = new Circle(S, { thickness: 2, color: this.S.CSC.MRDN_CIRC,  alpha: 1   });
    this.azArc     = new Circle(S, { thickness: 3, color: this.S.CSC.AZ_ARC,     alpha: 1   });
    this.altArc    = new Circle(S, { thickness: 3, color: this.S.CSC.ALT_ARC,    alpha: 1   });

    this.meridian2.setParameters({ az: 90, alt: 0, tilt: 90 });
    this.azCircle.setParameters ({ az:  0, alt: 0, tilt: 90 });
    this.altCircle.setParameters({ az:  0, alt: 0, tilt: 90 });
    this.meridian.setParameters ({ az:  0, alt: 0, tilt: 90 });
    this.azArc.setParameters    ({ az:  0, alt: 0, tilt:  0 });
    this.altArc.setParameters   ({ az:  0, alt: 0, tilt: 90 });

    // Halos increase contrast of arcs against multiple backgrounds (e.g., grey sphere and green plane)
    // Not needed for non-essential arcs meridian2, azCircle, and altCircle
    this.meridianH = new Circle(S, { thickness: 4, color: this.S.CSC.AZ_ARC_BCK, alpha: 1   });
    this.azArcH    = new Circle(S, { thickness: 5, color: this.S.CSC.AZ_ARC_BCK, alpha: 1   });
    this.altArcH   = new Circle(S, { thickness: 5, color: this.S.CSC.AZ_ARC_BCK, alpha: 1   });
    this.meridianH.setParameters ({ az:  0, alt: 0, tilt: 90 });
    this.azArcH.setParameters    ({ az:  0, alt: 0, tilt:  0 });
    this.altArcH.setParameters   ({ az:  0, alt: 0, tilt: 90 });

    // Draw guides first, and then stellar coordinates
    this.circles = [this.meridianH, this.azArcH,   this.altArcH, 
                    this.meridian2, this.azCircle, this.altCircle,
                    this.meridian,  this.azArc,    this.altArc];

    // Test hatching of a celestial sphere circle (checking implementation and format)
    /*
    this.meridian.setHatch({
      color: this.S.CSC.ECLPTC_2, thick: 1, alpha: 1,
      spacing: 10, angle: 0,
      innerR: 50
    });
    */

  }

  /* =========================================================================
     Define fixed line segments (label markers) on celestial sphere
       - North Pole: line segment (dark grey, zenith-up)
       - South Pole: line segment (dark gray, nadir-down)
     ========================================================================= */
  buildLines() {
    const S    = this.S;
    const end1 = 1.0;
    const end2 = 1.2;
    this.npLine = new Line(S, { thickness: 2, color: this.S.CSC.POLE_LNSG, alpha: 1 },
                              { az: 0, alt:  90, r: end1 }, { az: 0, alt:  90, r: end2 });
    this.spLine = new Line(S, { thickness: 2, color: this.S.CSC.POLE_LNSG, alpha: 1 },
                              { az: 0, alt: -90, r: end1 }, { az: 0, alt: -90, r: end2 });
    this.lines = [this.npLine, this.spLine];
  }

  cacheDom() {
    this.canvas        = document.getElementById('sky-canvas');
    this.ctx           = this.canvas.getContext('2d');
    this.canvas.width  = this.STAGE * this.dpr;
    this.canvas.height = this.STAGE * this.dpr;
    this.ctx.scale(this.dpr, this.dpr);

    this.chk = {
      zenith:   document.getElementById('chkZenith'  ),
      horizon:  document.getElementById('chkHorizon' ),
      nadir:    document.getElementById('chkNadir'   ),
      meridian: document.getElementById('chkMeridian')
    };
    this.srStatus   = document.getElementById('sr-status'  );
    this.starHandle = document.getElementById('starHandle' );
  }

  buildDualControls() {
    const app = this;

    this.azDual = new DualControl({
      mount:          '#az-dual-mount',
      id:             'az',
      label:          'azimuth:',
      min:            0,
      max:            360,
      step:           AZ_STEP,
      pageStep:       10,
      value:          140,
      unit:           '°',
      minLabel:       '0&deg;',
      maxLabel:       '360&deg;',
      wrap:           true,
      liveRegion:     document.getElementById('az-dual-live'),
      numberRowClass: 'control-row sim-dual-number kl-dual__number-row',
      sliderRowClass: 'control-row sim-dual-slider kl-dual__slider-row',
      numberClass:    'control-row__input  sim-dual-num kl-dual__number',
      sliderClass:    'control-row__slider sim-dual-range kl-dual__slider',
      formatAnnounce: (v) => 'Azimuth ' + speak(v, AZ_PREC, 'degree'),
      onInput:        (v) => {
        app.setStarLocation({ az: v, alt: app.altDual.getValue() }, true);
        app.render();
      },
      onChange:       (v) => {
        app.syncStarChrome();
        return 'Azimuth ' + speak(v, AZ_PREC, 'degree') + '.';
      }
    });

    this.altDual = new DualControl({
      mount:          '#alt-dual-mount',
      id:             'alt',
      label:          'altitude:',
      min:            -90,
      max:             90,
      step:           ALT_STEP,
      pageStep:       10,
      value:          45,
      unit:           '°',
      minLabel:       '-90&deg;',
      maxLabel:       '+90&deg;',
      liveRegion:     document.getElementById('alt-dual-live'),
      numberRowClass: 'control-row sim-dual-number kl-dual__number-row',
      sliderRowClass: 'control-row sim-dual-slider kl-dual__slider-row',
      numberClass:    'control-row__input  sim-dual-num kl-dual__number',
      sliderClass:    'control-row__slider sim-dual-range kl-dual__slider',
      formatAnnounce: (v) => 'Altitude ' + speak(v, ALT_PREC, 'degree'),
      milestone:      altHorizonCrossing,
      onInput:        (v) => {
        app.setStarLocation({ az: app.azDual.getValue(), alt: v }, true);
        app.render();
      },
      onChange:       (v) => {
        app.syncStarChrome();
        return 'Altitude ' + speak(v, ALT_PREC, 'degree') + '.';
      }
    });

    this.azNumber  = this.azDual.numberEl;
    this.altNumber = this.altDual.numberEl;
    this.azSlider  = this.azDual.sliderEl;
    this.altSlider = this.altDual.sliderEl;

    updateControlLabels(mediaCheck1);
    updateControlLabels(mediaCheck2);
  }

  loadAssets() {
    this.imgStar      = new Image();
    this.imgStarHover = new Image();  // adds dark border
    this.imgStick     = new Image();
    let pending = 3;
    const done = () => { if (--pending === 0) this.render(); };
    this.imgStar.onload      = done; this.imgStar.onerror      = done;
    this.imgStarHover.onload = done; this.imgStarHover.onerror = done;
    this.imgStick.onload     = done; this.imgStick.onerror     = done;
    this.imgStar.src         = 'images/star.png';
    this.imgStarHover.src    = 'images/star-hover.png';
    this.imgStick.src        = 'images/stickfigure.png';
    this.starHovered         = false;
  }

  // ----------------------------------------------------------------------
  // Controller methods
  // ----------------------------------------------------------------------
  reset() {
    this.setStarLocation({ az: 140, alt: 45 });
    this.S.setThetaAndPhi(190, 28);
    this.chk.zenith.checked = false; this.chk.horizon.checked  = false;
    this.chk.nadir.checked  = false; this.chk.meridian.checked = false;
    this.updateLabels();
    this.applyURL();
    
    this.onSphereOrientationChanged();
    this.render();
    this.announce(true);
  }

  onSphereOrientationChanged() {
    // horizonLabel sits on horizon at az = 394 - theta(deg)
    this.horizonAz = 394 - this.S.getTheta();
    this.render();
  }

  updateLabels() {
    this.labels.zenith   = this.chk.zenith.checked;
    this.labels.horizon  = this.chk.horizon.checked;
    this.labels.nadir    = this.chk.nadir.checked;
    this.labels.meridian = this.chk.meridian.checked;

    updateShowHideLabelButtons(
      document.getElementById('showAllBtn'),
      document.getElementById('hideAllBtn'),
      Object.values(this.chk)
    );
    this.render();
    // Silently update canvas description
    this.updateCanvasDescription();
  }
  setAllLabelsVisibility(v) {
    this.chk.zenith.checked = v; this.chk.horizon.checked  = v;
    this.chk.nadir.checked  = v; this.chk.meridian.checked = v;
    this.updateLabels();
    this.updateLabelDescription();
  }
  showAllLabels() { this.setAllLabelsVisibility(true);  }
  hideAllLabels() { this.setAllLabelsVisibility(false); }

  /** Update canvas / star-handle names without writing #sr-status (DualControl owns commit speech). */
  syncStarChrome() {
    this.updateCanvasDescription();
    if (document.activeElement !== this.starHandle) {
      this.starHandle.setAttribute('aria-label',
        'Star position. Azimuth ' + speak(this.star.az,  AZ_PREC,  'degree') +
                    ', altitude ' + speak(this.star.alt, ALT_PREC, 'degree') + '.');
    }
  }

  setStarLocation(pt, skipSliderSync) {
    const S = this.S;
    if (pt.az !== 360) pt.az = pMod(pt.az, 360);

    this.star.az  = pt.az;
    this.star.alt = pt.alt;

    // azArc: horizon arc from (360-az) back to 0, hidden when az == 0
    if (pt.az !== 0) {
      this.azArcH.setParameters({   az: 0,     alt: 0,      tilt:  0, gammaStart: 360 - pt.az, gammaEnd:  0     });
      this.azArcH.visible = true;
      this.azArc.setParameters({    az: 0,     alt: 0,      tilt:  0, gammaStart: 360 - pt.az, gammaEnd:  0     });
      this.azArc.visible  = true;
    } else {
      this.azArcH.visible = false;
      this.azArc.visible  = false;
    }
    this.azCircle.setParameters({  az: pt.az, alt: 0,      tilt: 90, gammaStart: -90,         gammaEnd: 90     });

    // altArc: vertical arc from horizon up (or down) to the star
    if (pt.alt < 0) {
      this.altArcH.setParameters({  az: pt.az, alt: 0,      tilt: 90, gammaStart: pt.alt,      gammaEnd:  0     });
      this.altArcH.visible = true;
      this.altArc.setParameters({   az: pt.az, alt: 0,      tilt: 90, gammaStart: pt.alt,      gammaEnd:  0     });
      this.altArc.visible  = true;
    } else if (pt.alt > 0) {
      this.altArcH.setParameters({  az: pt.az, alt: 0,      tilt: 90, gammaStart:   0,         gammaEnd: pt.alt });
      this.altArcH.visible = true;
      this.altArc.setParameters({   az: pt.az, alt: 0,      tilt: 90, gammaStart:   0,         gammaEnd: pt.alt });
      this.altArc.visible  = true;
    } else {
      this.altArcH.visible = false;
      this.altArc.visible  = false;
    }
    this.altCircle.setParameters({ az: 0,     alt: pt.alt, tilt:  0 });

    if (!skipSliderSync && this.azDual && this.altDual) {
      this.azDual.setValue( pt.az,  { silent: true, source: 'sync' });
      this.altDual.setValue(pt.alt, { silent: true, source: 'sync' });
    }
  }

  // ----------------------------------------------------------------------
  // Rendering
  // ----------------------------------------------------------------------
  render() {
    const S = this.S, ctx = this.ctx, cx = this.CENTER, cy = this.CENTER, r = S.c.r;

    // Recompute geometry
    for (const c of this.circles) c.update();
    for (const l of this.lines  ) l.update();

    // star + markers screen positions
    const starP = {};
    projectPointScreen(S, { az: this.star.az, alt: this.star.alt, r: 1 }, this.star.sp, starP);
    this.star.p = starP;
    const zenithSp = {}; S.WtoSz({ x: 0, y: 0, z:  1 }, zenithSp);
    const nadirSp  = {}; S.WtoSz({ x: 0, y: 0, z: -1 }, nadirSp );
    this.computeLabelAnchors(zenithSp, nadirSp);

    ctx.clearRect(0, 0, this.STAGE, this.STAGE);
    ctx.save();
    ctx.translate(cx, cy);

    // For star, legacy fS/bS bands keyed on screen depth (sp.z),
    // not world altitude — drawn after circles in the matching hemisphere.
    const starFront = isScreenFront(this.star.sp);

    // Legacy line layers: bE (unmasked, behind) → shading →
    // bI (under plane) → horizon → aI (over plane) → front circles → fE.
    // External stubs use full alpha; only back *circles* are dimmed.
    this.paintLineLayer(   'bE');
    this.paintCircleBucket('back');
    this.drawValueLabels(  'back');           // before glass and stick figure
    this.drawFeatureLabels('back');           // before glass (far-side names)
    drawMarker(this.ctx, this.S, { x: 0, y: 0, z: -1 }, this.S.CSC);  // nadir ring (_bF after _bEL)
    if (!starFront) this.drawStar();          // bS: after back circles

    // Test hatching of a celestial sphere circle
  //drawCircleHatch(this.ctx, this.circles, 'back', { dim: 0.55 });  // great circle hatching

    // Frosted-glass sphere body: a translucent grey disk that sits between
    // the far and near halves, so far-side circles read as fainter (seen
    // "through" the front of the sphere). Also gives the sphere shape.
    drawGlass(this.ctx, this.S, this.S.CSC);

    this.paintLineLayer(   'bI');             // inner-below, under the plane
    this.drawHorizonPlane();
  //drawCircleHatch(this.ctx, this.circles, 'front');  // great circle hatching
    this.paintLineLayer(   'aI');             // inner-above, over the plane
    this.drawAzArcBack();                     // far azArc on the green rim (after plane)

    // Cardinal labels on horizon plane, split by screen depth so stick 
    // figure occludes labels behind it.
    this.drawCardinals(   'back');
    this.drawStick();                         // observer stands on the plane
    this.drawCardinals(   'front');

    // Near-side geometry (in front of sphere center), full strength
    this.paintCircleBucket('front');
    drawMarker(this.ctx, this.S, { x: 0, y: 0, z: 1 }, this.S.CSC);   // zenith ring (_fF) before npLine
    this.paintLineLayer(   'fE');             // npLine through the ellipse center
    if (starFront) this.drawStar();           // fS: after front circles
    this.drawValueLabels(  'front');          // after stick and front arcs
    this.drawFeatureLabels('front');          // near-side names, after geometry

    ctx.restore();

    this.positionOverlay();    
    this.updateURL();
  }

  paintCircleBucket(which) {
    drawCircleBucket(this.ctx, this.circles, which, {
      skip: (c, w) => (w === 'back' && c === this.azArc),
      lineCap: 'round'
    });
  }

  // Far-side azimuth arc, painted after the horizon plane so green fill
  // does not cover it. Same geometry (alt = 0); dimmed like other back
  // circles, with a white halo so blue stays readable on dark rim.
  //
  // Note that without this addition, far-side blue arc appeared to be
  // absent.
  drawAzArcBack() {
    drawCircleArcBack(this.ctx, this.azArc, { haloColor: this.S.CSC.AZ_ARC_BCK });
  }

  // Stroke lines (bE / fE / aI / bI) at line's own alpha value.
  // External back stubs (bE) stay full strength so the part past the rim
  // is not dimmed; the glass disk covers the overlapping portion.
  paintLineLayer(which) {
    drawLineLayer(this.ctx, this.lines, which);
  }

  drawHorizonPlane() {
    const ctx = this.ctx, S = this.S, r = S.c.r;
    // The horizon plane is the (horizontal) alt=0 circle. Its orthographic
    // projection is an axis-aligned ellipse: full width (semi-axis r) and a
    // vertical semi-axis r*sin(phi) that opens/closes with the view altitude
    // (phi) but does not rotate with the azimuth (theta). Rotation only
    // repositions the direction labels (separately drawn).
    const yscale = Math.sin(S.phi);             // r*sin(phi) / r
    ctx.save();
    ctx.scale(1, yscale);                       // squash circle into the horizon ellipse
    const above = S.phi > 0;
    const g = ctx.createRadialGradient(0, 0, r * 0.05, 0, 0, r);
    if (above) {                                // above horizon (bright greens)
      g.addColorStop(0,    this.S.CSC.HOR_ABV_1);
      g.addColorStop(0.75, this.S.CSC.HOR_ABV_2);
      g.addColorStop(1,    this.S.CSC.HOR_ABV_3);
    } else {                                    // below horizon (dark greens)
      g.addColorStop(0,    this.S.CSC.HOR_BLW_1);
      g.addColorStop(1,    this.S.CSC.HOR_BLW_2);
    }
    ctx.beginPath(); ctx.arc(0, 0, r, 0, TWO_PI);
    ctx.fillStyle = g; ctx.fill();
    ctx.restore();
  }

  // Stick figure (observer) standing at the sphere center. setOrientationType
  // ("absolute", normal (-1,0,0), up = zenith (0,0,1)) -> tilts/foreshortens
  // with the local ground as view rotates.
  drawStick() {
    const ctx = this.ctx;  if (!this.imgStick.naturalWidth) return;
    const sc  = 1.2;
    const w   = this.imgStick.naturalWidth  * sc;
    const h   = this.imgStick.naturalHeight * sc;
    const o   = absOrient(this.S, { x: 0, y: 0, z: 0 }, { x: -1, y: 0, z: 0 }, { x: 0, y: 0, z: 1 });
    ctx.save();
    ctx.translate(o.sp.x, o.sp.y);
    ctx.rotate(o.shellRot);
    ctx.scale(1, o.yscale);
    ctx.rotate(o.instRot);
    ctx.drawImage(this.imgStick, -w / 2, -h, w, h);   // feet at the origin
    ctx.restore();
  }

  // NESW labels are inlaid on the horizon plane.
  static get CARDINAL_R() { return 0.88; }  // inside green rim
  static get CARDINALS() {
    return [
      { t: 'N', az:   0 }, { t: 'E', az:  90 },
      { t: 'S', az: 180 }, { t: 'W', az: 270 }
    ];
  }

  drawCardinalLabel(az, text) {
    const ctx = this.ctx, S = this.S;
    const p   = {};
    S.parsePointInput({ az, alt: 0, r: App.CARDINAL_R }, p);
    const n   = { x: 0, y: 0, z: 1 };
    const u   = { x: 1, y: 0, z: 0 };   // N's plane "up" — same for all cardinals
    const o   = absOrient(this.S, p, n, u);
    ctx.save();
    ctx.translate(o.sp.x, o.sp.y);
    ctx.rotate(o.shellRot);
    ctx.scale(1, o.yscale);
  //ctx.rotate(o.instRot - az * D2R); // letters tops point towards stick figure
    ctx.rotate(o.instRot);
    ctx.lineJoin     = 'round';
    ctx.miterLimit   = 2;
    ctx.font         = '600 25px system-ui, -apple-system, Segoe UI, sans-serif';
    ctx.textAlign    = 'center';
    ctx.textBaseline = 'middle';
    ctx.lineWidth    = 3;
    ctx.strokeStyle  = this.S.CSC.NESW_LINE;
    ctx.fillStyle    = this.S.CSC.NESW_FILL;
    ctx.strokeText(text, 0, 0);
    ctx.fillText(  text, 0, 0);
    ctx.restore();
  }

  // which: 'back' (sp.z < 0, before figure) or 'front' (sp.z >= 0, after figure)
  drawCardinals(which) {
    if (this.S.phi <= 0) return;
    const S   = this.S;
    for (const c of App.CARDINALS) {
      const p = {}, sp = {};
      S.parsePointInput({ az: c.az, alt: 0, r: App.CARDINAL_R }, p);
      S.WtoSz(p, sp);
      const behind = sp.z < 0;
      if ((which === 'back' && behind) || (which === 'front' && !behind)) {
        this.drawCardinalLabel(c.az, c.t);
      }
    }
  }

  drawValueLabel(pt, text, ltrColor) {
    drawOrientedLabel(this.ctx, this.S,
      { az: pt.az, alt: pt.alt, r: 1.001 }, text, ltrColor, 
      { halo: this.S.CSC.LABEL_HALO });
  }

  // which: 'back' (sp.z < 0, before figure) or 'front' (sp.z >= 0, after figure).
  // Az and alt are treated independently, as they can lie on opposite hemispheres.
  drawValueLabels(which) {
    const S = this.S;
    const specs = [
      { pt: { az: this.star.az - 13, alt: 5 },
        text:  legToFixed(this.star.az,  AZ_PREC ) + '°',
        color: this.S.CSC.AZ_LABEL  },
      { pt: { az: this.star.az + 13, alt: this.star.alt / 2 },
        text:  legToFixed(this.star.alt, ALT_PREC) + '°',
        color: this.S.CSC.ALT_LABEL }
    ];
    for (const s of specs) {
      const p = {}, sp = {};
      S.parsePointInput({ az: s.pt.az, alt: s.pt.alt, r: 1.001 }, p);
      S.WtoSz(p, sp);
      const behind = sp.z < 0;
      if ((which === 'back' && behind) || (which === 'front' && !behind)) {
        this.drawValueLabel(s.pt, s.text, s.color);
      }
    }
  }

  // Star. setOrientationType("absolute") with no args -> normal = radial (the
  // star's own direction), so the sprite lies flat against sphere surface
  // and foreshortens toward limb instead of always facing viewer.
  drawStar() {
    drawStarSprite(this.ctx, this.S, this.star.p,
      this.imgStar, this.imgStarHover, this.starHovered, { sp: this.star.sp });
  }

  // Anchor screen points for four named feature labels (used by the leader
  // lines and the offset text placement).
  computeLabelAnchors(zenithSp, nadirSp) {
    const S = this.S;
    const project = (pt) => { const o = {}, sp = {}; S.parsePointInput(pt, o); S.WtoSz(o, sp); return sp; };
    this._labelAnchor = {
      zenith:   zenithSp,
      nadir:    nadirSp,
      horizon:  project({ az: this.horizonAz, alt:  0, r: 1 }),
      meridian: project({ az: 180,            alt: 35, r: 1 })
    };
  }

  // Offsets (x and y in stage px) from each feature point to its text label, 
  // with a clear leader line pointing back to the point: Zenith up-right,
  // Nadir down-right, Meridian left, Horizon Plane down-left -- so marker
  // rings and lines stay visible.
  //
  // Third element determines where leader line should attach: 0-3:TRBL.
  static get LABEL_OFFSET() {
    return { zenith: [34, -20, 2], nadir: [22, 26, 0], horizon: [-46, 26, 0], meridian: [-74, -4, 1] };
  }

  static get NAMED_LABELS() {
    return { zenith: 'Zenith', nadir: 'Nadir', horizon: 'Horizon Plane', meridian: 'Meridian' };
  }

  static get NAMED_LABEL_FONT() {
    return '600 15px system-ui, -apple-system, Segoe UI, sans-serif';
  }

  // Developer-only flag:
  // true  = legacy style (gap before feature, no dot);
  // false = new style (line to feature + small black dot). Not exposed in the UI.
  static LEADER_LEGACY_STYLE = true;

  // Screen position of a named label: preferred offset, then clamped so the
  // glyph box stays a few pixels inside the canvas (Meridian on the left limb
  // would otherwise clip first letters). dx/dy are the clamped vector
  // from the feature so leader still meets text.
  namedLabelPos(key) {
    const ctx          = this.ctx;
    const a            = this._labelAnchor[key];
    const [dx, dy, os] = App.LABEL_OFFSET[key];
    const text         = App.NAMED_LABELS[key];
    ctx.save();
    ctx.font           = App.NAMED_LABEL_FONT;
    const halfW        = ctx.measureText(text).width / 2;
    const match        = App.NAMED_LABEL_FONT.match(/(\d+)px/);
    const halfH        = match ? ( ( parseInt(match[1], 10) + 1 ) / 2 ): 8;  // 15px font default
    const pad          = 8;
    ctx.restore();
    let x = a.x + dx, y = a.y + dy;
    x = Math.min(this.CENTER - pad - halfW, Math.max(-this.CENTER + pad + halfW, x));
    y = Math.min(this.CENTER - pad - halfH, Math.max(-this.CENTER + pad + halfH, y));
    let xll, yll;
    if      ( os == 0 )  { xll = x - a.x;              yll = y - a.y - halfH; }
    else if ( os == 1 )  { xll = x - a.x + 1.15*halfW; yll = y - a.y;         }
    else if ( os == 2 )  { xll = x - a.x;              yll = y - a.y + halfH * 1.3; }
    else if ( os == 3 )  { xll = x - a.x - 1.15*halfW; yll = y - a.y;         }
    return { a, x, y, dx: a.x - x, dy: a.y - y, xll, yll, text };
  }

  // Camera-facing named labels (Legacy default _oType = 0, not absOrient).
  // which: 'back' (feature sp.z < 0, before glass) or 'front' (sp.z >= 0).
  drawFeatureLabels(which) {
    const off = App.LABEL_OFFSET;
    for (const key of Object.keys(off)) {
      if (!this.labels[key]) continue;
      const a = this._labelAnchor[key];
      const behind = a.z < 0;
      if ((which === 'back' && behind) || (which === 'front' && !behind)) {
        this.drawLabelLeader(  key);
        this.drawFeatureLabel( key);
        this.drawLabelLeader(  key);
      }
    }
  }

  drawLabelLeader(key) {
    const ctx = this.ctx;
    const { a, dx, dy, xll, yll } = this.namedLabelPos(key);
    let x0, y0, x1, y1, gap = 8, ang = -Math.atan2( -yll, -xll );
    if (App.LEADER_LEGACY_STYLE) {
      x0 = a.x + xll;                   y0 = a.y + yll;
      x1 = a.x - gap * Math.cos( ang ); y1 = a.y + gap * Math.sin( ang );
    } else {
      x0 = a.x + xll; y0 = a.y + yll;
      x1 = a.x;       y1 = a.y;
    }
    // Add light halo so dark line stays visible over white, grey, and green backgrounds
    ctx.save();
    ctx.lineCap     = 'round';
    ctx.lineJoin    = 'round';
    ctx.miterLimit  = 2;          // safety guard for extreme glyph vector joints ("2" spikes)
    ctx.strokeStyle = hexToRGBA( this.S.CSC.LABEL_HALO, 0.85 );
    ctx.lineWidth   = 2.6;
  //ctx.lineWidth   = 3.8;        // leave ~1.25px halo on each side of a 1.3px line
    ctx.beginPath(); ctx.moveTo(x0, y0); ctx.lineTo(x1, y1); ctx.stroke();  // light halo
    ctx.strokeStyle = this.S.CSC.LABEL_LNSG;
    ctx.lineWidth   = 1.3;
    ctx.beginPath(); ctx.moveTo(x0, y0); ctx.lineTo(x1, y1); ctx.stroke();  // dark line
    if (!App.LEADER_LEGACY_STYLE) {
      ctx.fillStyle = this.S.CSC.LABEL_LNSG;
      ctx.beginPath(); ctx.arc(a.x, a.y, 1.6, 0, TWO_PI); ctx.fill();
    }
    ctx.restore();
  }

  drawFeatureLabel(key) {
    const ctx = this.ctx;
    const { x, y, text } = this.namedLabelPos(key);
    ctx.save();
    ctx.translate(x, y);           // upright billboard, no absOrient call
  //ctx.lineCap      = 'round';
    ctx.lineJoin     = 'round';
    ctx.miterLimit   = 2;          // safety guard for extreme glyph vector joints ("2" spikes)
    ctx.font         = App.NAMED_LABEL_FONT;
    ctx.textAlign    = 'center';
    ctx.textBaseline = 'middle';
    ctx.lineWidth    = 3;
    ctx.strokeStyle  = this.S.CSC.LABEL_HALO;
    ctx.fillStyle    = this.S.CSC.LABEL_FILL;
    ctx.strokeText(text, 0, 0);
    ctx.fillText(  text, 0, 0);
    ctx.restore();
  }

  // Keyboard handle tracks the star's screen position + current coordinates.
  positionOverlay() {
    this.starHandle.style.left = ((this.CENTER + this.star.sp.x) / this.STAGE * 100) + '%';
    this.starHandle.style.top  = ((this.CENTER + this.star.sp.y) / this.STAGE * 100) + '%';
  }

  updateCanvasDescription() {
    // Chrome speaks aria-label changes on the focused element and Safari
    // ignores them; refresh on blur instead (see bindEvents).
    if (document.activeElement === this.canvas) return;
    this.canvas.setAttribute('aria-label',
      'Horizon diagram. Cardinal directions N, E, S, and W shown on the horizon. ' +
      'Star at azimuth ' + speak(this.star.az,  0, 'degree') +
           ', altitude ' + speak(this.star.alt, 0, 'degree') + '. ' + 
       locateStar(this.star.az,this.star.alt, 0) + this.addLabels() );
  }

  updateLabelDescription() {
    // Announce state of labels

    // Update canvas aria-label (full state) silently
    this.updateLabels();

    announceLive(this.srStatus, this.addLabels());
  }

  addLabels()  {
    // Define state of labels

    const onLabels = [];
    if (this.chk.zenith.checked)   onLabels.push('Zenith');
    if (this.chk.horizon.checked)  onLabels.push('Horizon Plane');
    if (this.chk.nadir.checked)    onLabels.push('Nadir');
    if (this.chk.meridian.checked) onLabels.push('Meridian');

    return listLabels( onLabels );
  }

  announce(isReset) {
    // Announce state of simulation
    
    const az  = pMod(360 - this.S.getTheta(), 360);   // viewer azimuth
    const alt = this.S.getPhi();                      // viewer altitude

    let msg = (isReset) ? 'Simulation reset. ' : '';
    msg    += 'Star at azimuth ' + speak(this.star.az,  0, 'degree') +
                   ', altitude ' + speak(this.star.alt, 0, 'degree') + '. ' +
               locateStar(this.star.az,this.star.alt, 0);
    msg    += 'Celestial sphere rotated by ' + speak( az,  0, 'degree' ) +
                           ' and tilted by ' + speak( alt, 0, 'degree' ) + '. ';
    msg    += this.addLabels();

    announceLive(this.srStatus, msg);

    // Update aria-label contents for view of celestial sphere and star
    this.updateCanvasDescription();
    // Under MacOS Chrome triggers a name change event for aria-label below to  
    // screen readers when element holds keyboard focus, while Safari+Voiceover  
    // typically ignores dynamic name changes on focused elements. We thus 
    // only perform the following update when the element does not hold focus.
    if (document.activeElement !== this.starHandle) {
      this.starHandle.setAttribute('aria-label',
        'Star position. Azimuth ' + speak(this.star.az,  0, 'degree') +
                    ', altitude ' + speak(this.star.alt, 0, 'degree') + '.');
    }
  }

  /** @param {boolean} [settled] - true for held keys (announce once input stops). */
  announceStar(settled = false) {
    // Announce state of star

    let msg = 'Star at azimuth ' + speak(this.star.az,  0, 'degree') +
                   ', altitude ' + speak(this.star.alt, 0, 'degree') + '. ' +
               locateStar(this.star.az,this.star.alt, 0);

    if (settled) announceSettled(this.srStatus, msg);
    else         announceLive(   this.srStatus, msg);

    // Update aria-label contents for view of celestial sphere and star
    this.updateCanvasDescription();
    // Under MacOS Chrome triggers a name change event for aria-label below to  
    // screen readers when element holds keyboard focus, while Safari+Voiceover  
    // typically ignores dynamic name changes on focused elements. We thus 
    // only perform the following update when the element does not hold focus.
    if (document.activeElement !== this.starHandle) {
      this.starHandle.setAttribute('aria-label',
        'Star at azimuth ' + speak(this.star.az,  0, 'degree') +
             ', altitude ' + speak(this.star.alt, 0, 'degree') + '. ');
    }
  }

  applyURL()  {
    // Check loaded URL for initial setup parameters, allowing user to specify
    // theta and phi on celestial sphere, azimuth and altitude of star,
    // and/or visibility of zenith, nadir, horizon, and meridian labels, as
    // well as visibility of masthead and control panels.

    document.getElementById('canvas-more-keys').style.display = 'none';

    const urlParams = Object.fromEntries( new URLSearchParams(window.location.search) );

    if ( Object.keys(urlParams).length === 0 )  return;

    let URL_THT, URL_PHI, URL_AZI, URL_ALT, URL_LBL;

    // Define theta and phi of celestial sphere, and azimuth and altitude of star
    // (use simulation defaults for any unspecified values)
    if ( (urlParams.theta !== undefined) && (!Number.isNaN(Number(urlParams.theta))) )  {
      URL_THT = Math.round( pMod( Number(urlParams.theta), 360 ) );
    } else  { URL_THT = 190; }
    if ( (urlParams.phi   !== undefined) && (!Number.isNaN(Number(urlParams.phi  ))) )  {
      URL_PHI = Math.round( Math.max( Math.min( Number(urlParams.phi), 90 ),   1 ) );
    } else  { URL_PHI =  28; }
    if ( (urlParams.azi   !== undefined) && (!Number.isNaN(Number(urlParams.azi  ))) )  {
      URL_AZI = Math.round( pMod( Number(urlParams.azi), 360 ) );
    } else  { URL_AZI = 140; }
    if ( (urlParams.alt   !== undefined) && (!Number.isNaN(Number(urlParams.alt  ))) )  {
      URL_ALT = Math.round( Math.max( Math.min( Number(urlParams.alt), 90 ), -90 ) );
    } else  { URL_ALT =  45; }

    this.setStarLocation({ az: URL_AZI, alt: URL_ALT });
    this.S.setThetaAndPhi( URL_THT, URL_PHI );

    // Show/hide zenith, nadir, horizon, and meridian labels if label
    // parameter is a defined array with four elements
    // (ignore any values but 1 or 0)
    if ( urlParams.labels !== undefined )  {
      try        { URL_LBL = JSON.parse(urlParams.labels); }
      catch (e)  { URL_LBL = null; }
      if ( Array.isArray(URL_LBL) && (URL_LBL.length === 4) )  {
        if      ( URL_LBL[0] == 1 )  { this.chk.zenith.checked   = true;  }
        else if ( URL_LBL[0] == 0 )  { this.chk.zenith.checked   = false; }
        if      ( URL_LBL[1] == 1 )  { this.chk.nadir.checked    = true;  }
        else if ( URL_LBL[1] == 0 )  { this.chk.nadir.checked    = false; }
        if      ( URL_LBL[2] == 1 )  { this.chk.horizon.checked  = true;  }
        else if ( URL_LBL[2] == 0 )  { this.chk.horizon.checked  = false; }
        if      ( URL_LBL[3] == 1 )  { this.chk.meridian.checked = true;  }
        else if ( URL_LBL[3] == 0 )  { this.chk.meridian.checked = false; }
        this.updateLabels();
      }
    }

    // Hide masthead and control panels (everything except canvas)
    // (hide if clean=true or clean=1)
    let URL_CLN = false;
    if ( urlParams.clean !== undefined )  {
      try        { URL_CLN = (JSON.parse(urlParams.clean) == true); }
      catch (e)  { URL_CLN = false; }
    }
    if ( URL_CLN )  {
      urlClean = true;
      document.getElementById('canvas-more-keys').style.display = 'block';
      document.getElementById('star-panel').style.display       = 'none';
      document.getElementById('label-panel').style.display      = 'none';
      document.querySelectorAll('.app-layout').forEach((el) => {
        el.style.display        = 'flex';
        el.style.justifyContent = 'center';
      });
      
      // Update screen reader help for keyboard control over canvas
      document.getElementById('skyHelp').innerHTML =
        'Drag, or use the arrow keys, to rotate the view. ' +
        'Toggle label visibility with 1, 2, 3, and 4, and reset the simulation with R.';

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

  updateURL()  {
    // Log current state parameters for possible URL-building

    // URL parameters are theta and phi for celestial sphere, azimuth and altitude
    // for star, and visibility of four labels.
    const theta = Math.round( R2D*this.S.theta );
    const phi   = Math.round( R2D*this.S.phi   );
    const azi   = Math.round( this.azDual.getValue()  );
    const alt   = Math.round( this.altDual.getValue() );
    const zen   = +document.getElementById('chkZenith').checked;
    const ndr   = +document.getElementById('chkNadir').checked;
    const hor   = +document.getElementById('chkHorizon').checked;
    const mrd   = +document.getElementById('chkMeridian').checked;

    let s0 = 'Azimuth-Altitude-Demonstrator/index.html';    
    s0    += '?theta=' + theta + '&phi=' + phi;
    s0    += '&alt='   + alt   + '&azi=' + azi;
    s0    += '&labels=\[' + zen + ',' + ndr + ',' + hor + ',' + mrd + '\]';

    window.stateURL = s0;
  }
  
  // ----------------------------------------------------------------------
  // Pointer + keyboard interaction
  // ----------------------------------------------------------------------
  // Convert a pointer event to sphere-local stage coordinates (origin at center).
  pointerToStage(ev) {
    const rect = this.canvas.getBoundingClientRect();
    const sx   = (ev.clientX - rect.left) / rect.width  * this.STAGE - this.CENTER;
    const sy   = (ev.clientY - rect.top)  / rect.height * this.STAGE - this.CENTER;
    return { x: sx, y: sy };
  }

  bindEvents() {
    // Masthead Reset (sim-reset bubbles up from the component)
    document.addEventListener('sim-reset', () => this.reset());

    // DualControls own slider + number sync and single-axis live announcements.
    // Canvas / star-handle paths announce through #sr-status.

    // Buttons announce the visible labels; checkboxes rely on native
    // semantics and only update the canvas aria-label silently.
    document.getElementById('showAllBtn').addEventListener('click', () => this.showAllLabels());
    document.getElementById('hideAllBtn').addEventListener('click', () => this.hideAllLabels());
    for (const k of Object.keys(this.chk)) {
      this.chk[k].addEventListener('change', () => this.updateLabels());
    }

    // Setting gear when only figure is shown
    document.getElementById('canvas-more-keys').addEventListener('click', () => descMoreKeys(urlClean));
    document.getElementById('closeKeyNavBtn').addEventListener(  'click', () => hideMoreKeys());

    // Canvas pointer drag: star (if front-facing) else rotate the sphere
    this.dragMode = null;
    this.canvas.addEventListener('pointermove', (ev) => this.onPointerHover(ev));
    this.canvas.addEventListener('pointerdown', (ev) => this.onPointerDown( ev));
    window.addEventListener(     'pointermove', (ev) => this.onPointerDrag( ev));
    window.addEventListener(     'pointerup',   (ev) => this.onPointerUp(   ev));

    // Keyboard equivalent for the pointer-drag view rotation (arrows rotate the
    // sphere; directions match the mouse drag). The star itself is moved with
    // the Star Position controls.
    this.canvas.addEventListener(    'keydown', (ev) => this.onCanvasKey(ev));
    this.starHandle.addEventListener('keydown', (ev) => this.onStarKey(  ev));

    window.addEventListener('resize', () => this.render());

    // Insure that if user moves star via starHandle and then tabs to another
    // element and then shift-tabs back, the star Handle aria-label is updated
    // as soon as focus leaves. 
    this.starHandle.addEventListener('blur', () => {
      this.starHandle.setAttribute('aria-label',
        'Star position. Azimuth ' + speak(this.star.az,  0, 'degree') +
                    ', altitude ' + speak(this.star.alt, 0, 'degree') + '.');
    });
    this.canvas.addEventListener('blur', () => this.updateCanvasDescription());
  }

  nearStar(stage) {
    const dx = stage.x - this.star.sp.x, dy = stage.y - this.star.sp.y;
    return (dx * dx + dy * dy) <= 14 * 14;     // ~star hit radius
  }

  onPointerHover(ev) {
    if (this.dragMode) return;
    const stage = this.pointerToStage(ev);
    const over  = this.nearStar(stage) && this.star.sp.z > 0;
    if (over !== this.starHovered) { this.starHovered = over; this.render(); }
  }

  onPointerDown(ev) {
    const stage = this.pointerToStage(ev);
    this.canvas.setPointerCapture && this.canvas.setPointerCapture(ev.pointerId);
    // AzAlt Draggable Star.onPress: front-facing star -> drag star; else sphere.
    // Move keyboard focus to the matching control so that after a click the
    // arrow keys act on what was clicked (the star handle is pointer-transparent,
    // and ev.preventDefault() below would otherwise suppress default focusing).
    if (this.nearStar(stage) && this.star.sp.z > 0) {
      this.dragMode = 'star';
      this.starHandle.focus();
    } else {
      this.dragMode   = 'sphere';
      this.dragXMouse = stage.x; this.dragYMouse = stage.y;
      this.dragTheta  = this.S.theta; this.dragPhi = this.S.phi;
      this.canvas.focus();
    }
    this.canvas.classList.add('dragging');
    ev.preventDefault();
  }

  onPointerDrag(ev) {
    if (!this.dragMode) return;
    const stage = this.pointerToStage(ev);
    if (this.dragMode === 'star') {
      // AzAlt Draggable Star.onMouseMoveFunc
      const hp = {};
      this.S.StoMH({ x: stage.x, y: stage.y }, hp);
      this.setStarLocation({ az: -hp.az * 180 / PI, alt: hp.alt * 180 / PI });
      this.render();
    } else {
      // CelestialSphere.updateSimpleDragging
      const r = this.S.c.r;
      this.S.setThetaAndPhi(
        R2D * (this.dragTheta - (stage.x - this.dragXMouse) / r),
        R2D * (this.dragPhi   + (stage.y - this.dragYMouse) / r)
      );
      this.onSphereOrientationChanged();
    }
  }

  onPointerUp() {
    if (!this.dragMode) return;
    if (this.dragMode === 'star') { this.announceStar(); }
    else                          { this.announceView(); }
    this.dragMode = null;
    this.canvas.classList.remove('dragging');
  }

  // Arrow keys rotate view; Shift/CapsLock = x10 larger step (10deg vs 1deg),
  // PageUp/Down = phi in 15deg steps. 
  onCanvasKey(ev) {
    const dStp    =  1;
    const bigStep = 15;
  //const step    = ( ev.shiftKey || ev.getModifierState('CapsLock') ) ? 10*dStp : dStp;
    const step    = keyAccel(ev, dStp);
    let   dTheta  = 0, dPhi = 0; 
    switch (ev.key) {
      // MacOS+Voiceover users need an alternative to arrow keys
      case 'ArrowLeft':  case 'a': case 'A': dTheta =     step;  break;
      case 'ArrowRight': case 'd': case 'D': dTheta =    -step;  break;
      case 'ArrowUp':    case 'w': case 'W': dPhi   =    -step;  break;
      case 'ArrowDown':  case 's': case 'S': dPhi   =     step;  break;
      case 'PageUp':                         dPhi   = -bigStep;  break;
      case 'PageDown':                       dPhi   =  bigStep;  break;
      // If control panels are hidden, enable keyboard controls to reset simulation or show/hide labels
      case 'r': case 'R': if (urlClean) { this.reset(); break; }
      case '1': case '!': if (urlClean) { this.chk.zenith.checked   = !this.chk.zenith.checked;   this.updateLabelDescription(); break; }
      case '2': case '@': if (urlClean) { this.chk.nadir.checked    = !this.chk.nadir.checked;    this.updateLabelDescription(); break; }
      case '3': case '#': if (urlClean) { this.chk.horizon.checked  = !this.chk.horizon.checked;  this.updateLabelDescription(); break; }
      case '4': case '$': if (urlClean) { this.chk.meridian.checked = !this.chk.meridian.checked; this.updateLabelDescription(); break; }
      default: return;
    }
    ev.preventDefault();
    if ( (dTheta != 0 ) || (dPhi != 0) )  { 
      this.S.setThetaAndPhi(this.S.getTheta() + dTheta, this.S.getPhi() + dPhi);
      this.onSphereOrientationChanged();
      this.announceView(true);
    }
  }

  // Arrow keys move star (alt/az), mirroring star drag. Same step scheme 
  // as view rotation: 1deg arrows, 10deg with Shift/CapsLock, 15deg Page keys.
  onStarKey(ev) {
    let dStp = ALT_STEP;
    if ( ( ev.key == 'ArrowLeft' ) || ( ev.key == 'ArrowRight' ) )  { dStp = AZ_STEP; }
    const step = ( ev.shiftKey || ev.getModifierState('CapsLock') ) ? 10*dStp : dStp;
    let dAz = 0, dAlt = 0;
    switch (ev.key) {
      // MacOS+Voiceover users need an alternative to arrow keys
      case 'ArrowLeft':  case 'a': case 'A': dAz  =     step;  break;
      case 'ArrowRight': case 'd': case 'D': dAz  =    -step;  break;
      case 'ArrowUp':    case 'w': case 'W': dAlt =     step;  break;
      case 'ArrowDown':  case 's': case 'S': dAlt =    -step;  break;
      case 'PageUp':                         dAlt =  15*dStp;  break;
      case 'PageDown':                       dAlt = -15*dStp;  break;
      // If control panels are hidden, enable keyboard controls to reset simulation or show/hide labels
      case 'r': case 'R': if (urlClean) { this.reset(); break; }
      case '1': case '!': if (urlClean) { this.chk.zenith.checked   = !this.chk.zenith.checked;   this.updateLabelDescription(); break; }
      case '2': case '@': if (urlClean) { this.chk.nadir.checked    = !this.chk.nadir.checked;    this.updateLabelDescription(); break; }
      case '3': case '#': if (urlClean) { this.chk.horizon.checked  = !this.chk.horizon.checked;  this.updateLabelDescription(); break; }
      case '4': case '$': if (urlClean) { this.chk.meridian.checked = !this.chk.meridian.checked; this.updateLabelDescription(); break; }
      default: return;
    }
    ev.preventDefault();
    if ( (dAz != 0 ) || (dAlt != 0) )  {
      let alt = this.star.alt + dAlt;
      if (alt > 90) alt = 90; else if (alt < -90) alt = -90;
      // setStarLocation normalizes azimuth mod 360 and syncs DualControls.
      this.setStarLocation({ az: this.star.az + dAz, alt: alt });
      this.render();
      this.announceStar(true);
    }
  }

  /** @param {boolean} [settled] - true for held keys (announce once input stops). */
  announceView(settled = false) {
    const az  = pMod(360 - this.S.getTheta(), 360);   // viewer azimuth
    const alt = this.S.getPhi();                      // viewer altitude
    const msg = 'Celestial sphere rotated by ' + speak( az,  0, 'degree' ) +
                             ' and tilted by ' + speak( alt, 0, 'degree' ) + '. ';

    if (settled) announceSettled(this.srStatus, msg);
    else         announceLive(   this.srStatus, msg);

    // Update aria-label content for view of celestial sphere
    this.updateCanvasDescription();
  }
}

// Abbreviate DualControl labels in the mid-wide band; full labels otherwise.
mediaCheck1.addEventListener('change', updateControlLabels);
mediaCheck2.addEventListener('change', updateControlLabels);
function updateControlLabels(ev) {
  const azLabel  = document.querySelector('label[for="az-number"]' );
  const altLabel = document.querySelector('label[for="alt-number"]');
  if (!azLabel || !altLabel) return;

  const remToPx = parseFloat( getComputedStyle( document.documentElement ).fontSize );
  const wid     = document.documentElement.scrollWidth / remToPx;

  if ( (brkpt1 <= wid) && (wid <= brkpt2) ) {
    azLabel.textContent  = 'az:';
    altLabel.textContent = 'alt:';
  } else {
    azLabel.textContent  = 'azimuth:';
    altLabel.textContent = 'altitude:';
  }
}

// Initialize once the DOM is ready (this sim has no equations, so it does
// not load kl-unl-mathjax.js or use its klunlInitEqn hook).
function boot() { if (!window.altAzApp) window.altAzApp = new App(); }
if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', boot);
} else {
  boot();
}
