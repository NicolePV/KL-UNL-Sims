/* ===========================================================================
   Azimuth/Altitude Demonstrator: HTML5 port of altAzDemo005 (legacy Flash AS1)
   ---------------------------------------------------------------------------
   Rendering uses an HTML5 <canvas> for code-drawn geometry (sphere shading,
   horizon plane, circles, arcs, pole stubs, markers, and feature labels) and
   images for the star and stick figure. Feature labels and degree readouts are 
   announced via canvas aria-label and live region.
   
   Math (rotation matrices, great/small-circle front/back splitting,
   screen<->horizon conversion, drag + snapping) is kept identical to legacy 
   source so positions, arcs and drag behaviour match original.
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
  legToFixed, stepToPrec, speak, pMod, snapFixed, noEinNumber, amplifyArrowKey,
  updateSliderProgress, hexToRGBA, soon, announceLive, logAct,
  updateShowHideLabelButtons
} from '../foundation/js/kl-unl-utils.js';

// Log initialization, browser, platform, and screen size in server access log
logAct("INIT_AltAz");

// Adjust control panel control labels for very width screens via two break-points
const brkpt1      = 65;  // first  breakpoint, at 65rem
const brkpt2      = 75;  // second breakpoint, at 75rem
const mediaCheck1 = window.matchMedia('(min-width: ' + brkpt1 + 'rem)');
const mediaCheck2 = window.matchMedia('(min-width: ' + brkpt2 + 'rem)');
updateControlLabels(mediaCheck1);
updateControlLabels(mediaCheck2);

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

    // Draw guides first, and then stellar coordinates
    this.circles = [this.meridian2, this.azCircle, this.altCircle,
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

    this.azSlider  = document.getElementById('azSlider' );
    this.altSlider = document.getElementById('altSlider');
    this.azNumber  = document.getElementById('azNumber' );
    this.altNumber = document.getElementById('altNumber');
    this.chk = {
      zenith:   document.getElementById('chkZenith'  ),
      horizon:  document.getElementById('chkHorizon' ),
      nadir:    document.getElementById('chkNadir'   ),
      meridian: document.getElementById('chkMeridian')
    };
    this.desc       = document.getElementById('diagramDesc');
    this.starHandle = document.getElementById('starHandle' );
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
    this.onSphereOrientationChanged();
    this.hideAllLabels();
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
    this.announce();
  }
  setAllLabelsVisibility(v) {
    this.chk.zenith.checked = v; this.chk.horizon.checked  = v;
    this.chk.nadir.checked  = v; this.chk.meridian.checked = v;
    this.updateLabels();
  }
  showAllLabels() { this.setAllLabelsVisibility(true);  }
  hideAllLabels() { this.setAllLabelsVisibility(false); }

  onPositionSliderChanged() {
    this.setStarLocation({ az:  Number(this.azSlider.value),
                           alt: Number(this.altSlider.value) }, true);
    this.render();
  }

  setStarLocation(pt, skipSliderSync) {
    const S = this.S;
    if (pt.az !== 360) pt.az = pMod(pt.az, 360);

    this.star.az  = pt.az;
    this.star.alt = pt.alt;

    // azArc: horizon arc from (360-az) back to 0, hidden when az == 0
    if (pt.az !== 0) {
      this.azArc.setParameters({   az: 0,     alt: 0,      tilt:  0, gammaStart: 360 - pt.az, gammaEnd:  0     });
      this.azArc.visible = true;
    } else {
      this.azArc.visible = false;
    }
    this.azCircle.setParameters({  az: pt.az, alt: 0,      tilt: 90, gammaStart: -90,         gammaEnd: 90     });

    // altArc: vertical arc from horizon up (or down) to the star
    if (pt.alt < 0) {
      this.altArc.setParameters({  az: pt.az, alt: 0,      tilt: 90, gammaStart: pt.alt,      gammaEnd:  0     });
      this.altArc.visible = true;
    } else if (pt.alt > 0) {
      this.altArc.setParameters({  az: pt.az, alt: 0,      tilt: 90, gammaStart:   0,         gammaEnd: pt.alt });
      this.altArc.visible = true;
    } else {
      this.altArc.visible = false;
    }
    this.altCircle.setParameters({ az: 0,     alt: pt.alt, tilt:  0 });

    if (!skipSliderSync) {
      this.azSlider.value  = pt.az;
      this.altSlider.value = pt.alt;
      this.azNumber.value  = legToFixed(pt.az,  stepToPrec(azNumber.step  ) );
      this.altNumber.value = legToFixed(pt.alt, stepToPrec(altNumber.step ) );
    }
    // Spoken values include angle name and degrees unit.
    this.azSlider.setAttribute ('aria-valuetext', 'Azimuth '  + speak(pt.az,  0, 'degree'));
    this.altSlider.setAttribute('aria-valuetext', 'Altitude ' + speak(pt.alt, 1, 'degree'));
  }

  // ----------------------------------------------------------------------
  // Rendering
  // ----------------------------------------------------------------------
  render() {
    const S = this.S, ctx = this.ctx, cx = this.CENTER, cy = this.CENTER, r = S.c.r;

    // recompute geometry
    for (const c of this.circles) c.update();
    for (const l of this.lines  ) l.update();

    // star + markers screen positions
    const starP = {};
    projectPointScreen(S, { az: this.star.az, alt: this.star.alt, r: 1 }, this.star.sp, starP);
    this.star.p = starP;
    const zenithSp = {}; S.WtoSz({ x: 0, y: 0, z:  1 }, zenithSp);
    const nadirSp  = {}; S.WtoSz({ x: 0, y: 0, z: -1 }, nadirSp );
    this.computeLabelAnchors(zenithSp, nadirSp);

    // Fill slider from 0 to thumb position
    updateSliderProgress(document.getElementById('azSlider' ));
    updateSliderProgress(document.getElementById('altSlider'));

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
    this.updateCanvasDescription();
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
        text:  legToFixed(this.star.az,  stepToPrec(azNumber.step  ) ) + '°',
        color: this.S.CSC.AZ_LABEL  },
      { pt: { az: this.star.az + 13, alt: this.star.alt / 2 },
        text:  legToFixed(this.star.alt, stepToPrec(altNumber.step ) ) + '°',
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
    this.starHandle.setAttribute('aria-label',
      'Star position. Azimuth ' + speak(this.star.az,  1, 'degree') +
                  ', altitude ' + speak(this.star.alt, 1, 'degree') + '.');
  }

  updateCanvasDescription() {
    const onLabels = [];
    if (this.labels.zenith)   onLabels.push('Zenith');
    if (this.labels.horizon)  onLabels.push('Horizon Plane');
    if (this.labels.nadir)    onLabels.push('Nadir');
    if (this.labels.meridian) onLabels.push('Meridian');

    const labelText = onLabels.length ? onLabels.join(', ') : 'none';
    this.canvas.setAttribute('aria-label',
      'Horizon diagram. Cardinal directions N, E, S, and W shown on the horizon. ' +
      'Star at azimuth ' + speak(this.star.az,  1, 'degree') +
           ', altitude ' + speak(this.star.alt, 1, 'degree') + '. ' + 
      locateStar(this.star.az,this.star.alt, 0) + 'Visible labels: ' + labelText + '.');
  }

  announce(includeOrientation) {
    let msg = 'Star at azimuth ' + speak(this.star.az,  1, 'degree') +
                   ', altitude ' + speak(this.star.alt, 1, 'degree') + '. ' +
              locateStar(this.star.az,this.star.alt, 0);
    if (includeOrientation) {
      msg += ' View reset.';
    }
    this.desc.textContent = msg;
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

    // Sliders + number fields (both mutate the same state)
    const syncFromSlider = (slider, number) => {
      number.value = legToFixed(Number(slider.value), stepToPrec(number.step) );
      this.onPositionSliderChanged();
      this.announce();
    };
    this.azSlider.addEventListener( 'input', () => syncFromSlider(this.azSlider,  this.azNumber ));
    this.altSlider.addEventListener('input', () => syncFromSlider(this.altSlider, this.altNumber));

    const syncFromNumber = (number, slider) => {
      let v = Number(number.value);
      if (!isFinite(v)) return;
      v = Math.max(Number(slider.min), Math.min(Number(slider.max), v));
      number.value = legToFixed(v, stepToPrec(number.step) );
      slider.value = v;
      this.onPositionSliderChanged();
      this.announce();
    };
    this.azNumber.addEventListener( 'change',  () => syncFromNumber(this.azNumber,  this.azSlider) );
    this.altNumber.addEventListener('change',  () => syncFromNumber(this.altNumber, this.altSlider));

    this.azNumber.addEventListener(  'keydown', noEinNumber );
    this.altNumber.addEventListener( 'keydown', noEinNumber );

    // Buttons + checkboxes
    document.getElementById('showAllBtn').addEventListener('click', () => this.showAllLabels());
    document.getElementById('hideAllBtn').addEventListener('click', () => this.hideAllLabels());
    for (const k of Object.keys(this.chk)) {
      this.chk[k].addEventListener('change', () => this.updateLabels());
    }

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
    this.dragMode = null;
    this.canvas.classList.remove('dragging');
    this.announce();
  }

  // Arrow keys rotate view; Shift/CapsLock = x10 larger step (10deg vs 1deg),
  // PageUp/Down = phi in 15deg steps. 
  onCanvasKey(ev) {
    const dStp = 1;
    const step = ( ev.shiftKey || ev.getModifierState('CapsLock') ) ? 10*dStp : dStp;
    let dTheta = 0, dPhi = 0; 
    switch (ev.key) {
      case 'ArrowLeft':  dTheta =     step;  break;
      case 'ArrowRight': dTheta =    -step;  break;
      case 'ArrowUp':    dPhi   =    -step;  break;
      case 'ArrowDown':  dPhi   =     step;  break;
      case 'PageUp':     dPhi   = -15*dStp;  break;
      case 'PageDown':   dPhi   =  15*dStp;  break;
      default: return;
    }
    ev.preventDefault();
    this.S.setThetaAndPhi(this.S.getTheta() + dTheta, this.S.getPhi() + dPhi);
    this.onSphereOrientationChanged();
    this.announceView();
  }

  // Arrow keys move star (alt/az), mirroring star drag. Same step scheme 
  // as view rotation: 1deg arrows, 10deg with Shift/CapsLock, 15deg Page keys.
  onStarKey(ev) {
    let dStp   = Number(altNumber.step);
    if ( ( ev.key == 'ArrowLeft' ) || ( ev.key == 'ArrowRight' ) )  { dStp = Number(azNumber.step); }
    const step = ( ev.shiftKey || ev.getModifierState('CapsLock') ) ? 10*dStp : dStp;
    let dAz = 0, dAlt = 0;
    switch (ev.key) {
      case 'ArrowLeft':  dAz  =     step;  break;
      case 'ArrowRight': dAz  =    -step;  break;
      case 'ArrowUp':    dAlt =     step;  break;
      case 'ArrowDown':  dAlt =    -step;  break;
      case 'PageUp':     dAlt =  15*dStp;  break;
      case 'PageDown':   dAlt = -15*dStp;  break;
      default: return;
    }
    ev.preventDefault();
    let alt = this.star.alt + dAlt;
    if (alt > 90) alt = 90; else if (alt < -90) alt = -90;   // slider range
    // setStarLocation normalizes azimuth mod 360 and syncs sliders/boxes.
    this.setStarLocation({ az: this.star.az + dAz, alt: alt });
    this.render();
    this.announce();
  }

  announceView() {
    const az  = pMod(360 - this.S.getTheta(), 360);   // viewer azimuth
    const alt = this.S.getPhi();                      // viewer altitude
    this.desc.textContent = 'View rotated. ' +
         'Viewing azimuth ' + speak(az,  1, 'degree') +
      ', viewing altitude ' + speak(alt, 1, 'degree') + '.';
  }
}

// Update control panel labels for very wide screens
mediaCheck1.addEventListener('change', updateControlLabels);
mediaCheck2.addEventListener('change', updateControlLabels);
function updateControlLabels(ev) {
  const remToPx = parseFloat( getComputedStyle( document.documentElement ).fontSize );
  const wid     = document.documentElement.scrollWidth / remToPx;  // convert px to rem

  if ( (brkpt1 <= wid) && (wid <= brkpt2) ) {
    document.querySelector('label[for="azNumber"]' ).innerHTML = 'az:';
    document.querySelector('label[for="altNumber"]').innerHTML = 'alt:';
  } else  {
    document.querySelector('label[for="azNumber"]' ).innerHTML = 'azimuth:';
    document.querySelector('label[for="altNumber"]').innerHTML = 'altitude:';
  }
}

// Initialise once the foundation helper (kl-unl.js) is ready. We redefine
// klunlInitEqn (per the foundation convention) to boot the sim.
function boot() { if (!window.altAzApp) window.altAzApp = new App(); }
if (typeof window.klunlInitEqn === 'function') {
  window.klunlInitEqn = boot;
}
if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', boot);
} else {
  boot();
}
