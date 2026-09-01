/* ==========================================================================
   Celestial-Equatorial (RA/Dec) Demonstrator — HTML5 port
   Ported from celestialEquatorialDemo008 (Adobe Flash / AS1, 22 July 2009).
   Projection engine: foundation/js/kl-unl-celestial-sphere.js
   ========================================================================== */

import {
  CelestialSphere, Circle, Line, SphereObject,
  CELESTIAL_SPHERE_COLORS,
  D2R, R2D, TWO_PI, HALF_PI,
  drawCircleBucket, strokeCirclePaths, drawCircleArcBack, drawSphereRim,
  drawLineLayer, drawGlass, drawMarker, fillShorePolygons, drawStarSprite,
  drawCircleHatch,
  projectPointScreen, isScreenFront, drawOrientedLabel,
  locateStar
} from '../foundation/js/kl-unl-celestial-sphere.js';

import {
  legToFixed, stepToPrec, speak, pMod, noEinNumber, updateSliderProgress, hexToRGBA, 
  logAct, updateShowHideLabelButtons
} from '../foundation/js/kl-unl-utils.js';

import { EARTH_SHORES } from '../foundation/js/kl-unl-earth-shores.js';

// Choose whether or not to add hatching to ecliptic plane
const hatchEcliptic = true;

// Log initialization, browser, platform, and screen size in server access log
logAct('INIT_CEQ');

// Intrinsic image sizes — fallback when naturalWidth === 0 (Safari).
const IMG_DIM = {
  star:          [22,    24   ],
  starHv:        [22,    24   ],
  eastArrow:     [42.25, 20.75],
  rotationArrow: [39.5,  34.2 ]
};


class App {
  constructor() {
    this.S = new CelestialSphere();
    this.S.CSC = CELESTIAL_SPHERE_COLORS;
    this.S.setSize(320);
    this.S.setLatitude(90);
    this.S.setSiderealTime(0);

    this.inner = new CelestialSphere(30);
    this.inner.setLatitude(90);
    this.inner.setSiderealTime(0);

    this.STAGE  = 480;
    this.CENTER = 240;
    this.dpr    = Math.max(1, Math.min(3, window.devicePixelRatio || 1));

    this.star = { ra: 4, dec: 60, sp: { x: 0, y: 0, z: 0 } };
    this.labels = {
      earthPoles: false, equator:   false, celPoles: false, celEquator: false,
      zeroHours:  false, eastArrow: false, ecliptic: false
    };

    this.circles = [];
    this.lines   = [];
    this.objects = [];
    this.C       = {};
    this.L       = {};
    this.OBJ     = {};
    this.LBL     = {};

    this.img     = {};
    this.imgDim  = IMG_DIM;

    this.buildCircles();
    this.buildLines();
    this.buildObjects();
    this.loadAssets();
    this.cacheDom();
    this.bindEvents();
    this.setupMathJaxTabStrip();
    this.reset();
  }

  buildCircles() {
    const S = this.S, CSC = this.S.CSC;
    const add      = (name, style, def) => {
      const c      = new Circle(S, style, def);
      this.circles.push(c);
      this.C[name] = c;
      return c;
    };
    add('celestialEquator', { thickness: 2, color: CSC.MRDN_CIRC,  alpha: 1   }, { ra: 0, dec: 0, tilt:  0   });
    add('meridian1',        { thickness: 1, color: CSC.MRDN2_CIRC, alpha: 0.1 }, { ra: 0, dec: 0, tilt: 90, gammaStart:  90, gammaEnd: -90 });
    add('meridian2',        { thickness: 1, color: CSC.MRDN2_CIRC, alpha: 0.1 }, { ra: 6, dec: 0, tilt: 90   });
    add('zeroHoursCircle',  { thickness: 2, color: CSC.MRDN_CIRC,  alpha: 1   }, { ra: 0, dec: 0, tilt: 90, gammaStart: -90, gammaEnd:  90 });
    add('ecliptic',         { thickness: 2, color: CSC.ECLPTC_1,   alpha: 1   }, { ra: 0, dec: 0, tilt: 23.5 });
    add('raCircle',         { thickness: 1, color: CSC.RA_CIRC,    alpha: 1   }, { ra: 0, dec: 0, tilt: 90   });
    add('decCircle',        { thickness: 1, color: CSC.DEC_CIRC,   alpha: 1   }, { ra: 0, dec: 0, tilt: 90   });
    add('raArc',            { thickness: 3, color: CSC.RA_ARC,     alpha: 1   }, { ra: 0, dec: 0, tilt:  0   });
    add('decArc',           { thickness: 3, color: CSC.DEC_ARC,    alpha: 1   }, { ra: 0, dec: 0, tilt: 90   });
    this.raArc  = this.C.raArc;
    this.decArc = this.C.decArc;

    this.earthEquator  = new Circle(this.inner, { thickness: 1, color: CSC.MRDN_CIRC, alpha: 1 }, { ra: 0, dec: 0, tilt: 0 });
    this.inner.circles = [this.earthEquator];

    // Add hatching to ecliptic plane to more clearly illustrate how it aligns 
    // with Earth globe, carving out central hole for Earth
    if (hatchEcliptic)  { 
      this.C.ecliptic.setHatch({
        color: CSC.ECLPTC_2, thick: 1, alpha: 1,
        spacing: 10, angle: 0,
        innerR: this.inner.c.r
      });
    }
  }

  buildLines() {
    const S = this.S, CSC = this.S.CSC;
    const end1 = 1.0;
    const end2 = 1.2;
    const add  = (name, style, head, tail) => {
      const l  = new Line(S, style, head, tail);
      this.lines.push(l);
      this.L[name] = l;
      return l;
    };
    add('ncpLineExtension',              { thickness: 2, color: CSC.POLE_LNSG, alpha: 1 }, { ra: 0, dec:  90, r: end1 }, { ra: 0, dec:  90, r: end2 });
    add('scpLineExtension',              { thickness: 2, color: CSC.POLE_LNSG, alpha: 1 }, { ra: 0, dec: -90, r: end1 }, { ra: 0, dec: -90, r: end2 });

    this.earthNP  = new Line(this.inner, { thickness: 1, color: CSC.POLE_LNSG, alpha: 1 }, { ra: 0, dec:  90, r: end1 }, { ra: 0, dec:  90, r: end2 });
    this.earthSP  = new Line(this.inner, { thickness: 1, color: CSC.POLE_LNSG, alpha: 1 }, { ra: 0, dec: -90, r: end1 }, { ra: 0, dec: -90, r: end2 });
    this.inner.lines = [this.earthNP, this.earthSP];
  }

  buildObjects() {
    const S = this.S, CSC = this.S.CSC;
    const addObj = (name, position, opts, absolute) => {
      const o = new SphereObject(S, position, opts);
      if (absolute) o.setOrientationAbsolute();
      this.objects.push(o);
      this.OBJ[name] = o;
      return o;
    };
    const addLabel = (name, position, text, opts) => {
      const o = new SphereObject(S, position, opts || {});
      o.text         = text;
      o.label        = true;
      this.objects.push(o);
      this.LBL[name] = o;
      return o;
    };

    addObj('rotationArrow',  { ra: 0, dec:  90,       r: 0.4 }, { kind: 'rotationArrow' }, true );
    addObj('eastArrow',      { x:  0, y:     0, z: 0, r: 1.2 }, { kind: 'eastArrow'     }, false);
    addObj('star',           { ra: 0, dec:   0 },               { kind: 'star'          }, true );

    addLabel('northPole',    { x: 0, y: 0, z:  0.2, system: 'horizon' }, 'North Pole',           { leader: true, earth: true });
    addLabel('southPole',    { x: 0, y: 0, z: -0.2, system: 'horizon' }, 'South Pole',           { leader: true, earth: true });
    addLabel('equator',      { x: 0, y: 0, z:  0,   system: 'horizon' }, 'Equator',              { leader: true, earth: true });
    addLabel('ncp',          { x: 0, y: 0, z:  1,   system: 'horizon' }, 'North Celestial Pole', { leader: true });
    addLabel('scp',          { x: 0, y: 0, z: -1,   system: 'horizon' }, 'South Celestial Pole', { leader: true });
    addLabel('ecliptic',     { x: 0, y: 0, z:  0,   system: 'horizon' }, 'Ecliptic',             { leader: true });
    addLabel('ce',           { x: 0, y: 0, z:  0,   system: 'horizon' }, 'Celestial Equator',    { leader: true });
    addLabel('eastArrowLbl', { x: 0, y: 0, z:  0, r: 1.2   },            'East',                 { dy:       16 });
    addLabel('zeroHours',    { ra: 0, dec: 35,    r: 1     },            '0h Circle',            { leader: true });

    addLabel('raLabel',      { ra: 0, dec:  0,    r: 1.001 },            '',                     { color: CSC.RA_LABEL  });
    addLabel('decLabel',     { ra: 0, dec:  0,    r: 1.001 },            '',                     { color: CSC.DEC_LABEL });
  }

  cacheDom() {
    this.canvas = document.getElementById('sky-canvas');
    this.ctx    = this.canvas.getContext('2d');
    this.fitCanvas();

    this.raRange  = document.getElementById('ra-range');
    this.decRange = document.getElementById('dec-range');
    this.raField  = document.getElementById('ra-field');
    this.decField = document.getElementById('dec-field');
    this.chk = {
      earthPoles: document.getElementById('cb-earthpoles'),
      equator:    document.getElementById('cb-equator'),
      celPoles:   document.getElementById('cb-celpoles'),
      celEquator: document.getElementById('cb-celequator'),
      zeroHours:  document.getElementById('cb-zerohours'),
      eastArrow:  document.getElementById('cb-eastarrow'),
      ecliptic:   document.getElementById('cb-ecliptic')
    };
    this.showAllBtn = document.getElementById('showAllBtn');
    this.hideAllBtn = document.getElementById('hideAllBtn');
    this.live       = document.getElementById('sr-status');
    this.skyDesc    = document.getElementById('sky-desc');
    this.starHandle = document.getElementById('star-handle');
  }

  fitCanvas() {
    this.canvas.width  = this.STAGE * this.dpr;
    this.canvas.height = this.STAGE * this.dpr;
    this.ctx.setTransform(this.dpr, 0, 0, this.dpr, 0, 0);
    this.render();
  }

  loadAssets() {
    let pending = 4;
    const done = () => { if (--pending === 0 && this.ctx) this.render(); };
    const load = (key, src) => {
      const im      = new Image();
      im.onload     = done;
      im.onerror    = done;
      this.img[key] = im;
      im.src = src;
    };
  //load('star',          'assets/star.svg');
  //load('starHv',        'assets/star-hi.svg');
  //load('eastArrow',     'assets/east-arrow.svg');
  //load('rotationArrow', 'assets/rotation-arrow.svg');
    load('star',          'images/star.png');
    load('starHv',        'images/star-hover.png');
    load('eastArrow',     'images/east-arrow.svg');
    load('rotationArrow', 'images/rotation-arrow.svg');
    this.starHover = false;
    this.drag      = null;
  }

  reset() {
    this.setStarLocation(4, 60);
    this.S.setThetaAndPhi(217, 32);
    this.onSphereOrientationChanged();
    for (const k in this.labels) this.labels[k] = false;
    this.syncCheckboxes();
    this.updateLabels();
    this.render();
    this.announce('View reset. Star at right ascension ' + legToFixed(4,  stepToPrec( this.raField.step  )) +
                                  ' hours, declination ' + legToFixed(60, stepToPrec( this.decField.step )) +
                  ' degrees, ' + locateStar(this.star.ra, this.star.dec, 1) + 'All labels hidden.');
  }

  onSphereOrientationChanged() {
    this.inner.setThetaAndPhi(this.S.getTheta(), this.S.getPhi());
    this.OBJ.eastArrow.setPosition(   { alt:  0, az: -this.S.getTheta(),      r: 1.15 });
    this.OBJ.eastArrow.setOrientationAbsolute();
    this.LBL.eastArrowLbl.setPosition({ alt:  0, az: -this.S.getTheta(),      r: 1.15 });
    const t2 = -34 - this.S.getTheta();
  //const t3 = Math.atan(Math.sin(t2 * D2R) * 0.4348123749609336) * R2D;
    const t3 = Math.atan(Math.sin(t2 * D2R) * 25 * D2R) * R2D;
    this.LBL.ecliptic.setPosition(    { alt: t3, az: t2,                      r: 1.01 });
    this.LBL.equator.setPosition(     { alt:  0, az: 394 - this.S.getTheta(), r: 0.2  });
    this.LBL.ce.setPosition(          { alt:  0, az: 394 - this.S.getTheta(), r: 1.01 });
  }

  updateStarScreen() {
    const starP = {};
    projectPointScreen(this.S, { ra: this.star.ra, dec: this.star.dec, r: 1 }, this.star.sp, starP);
    this.star.p = starP;
  }

  setStarLocation(ra, dec, skipSliderSync) {
    this.star.ra  = ra;
    this.star.dec = dec;
    const CSC     = this.S.CSC;
    this.LBL.raLabel.text  = legToFixed(ra,  stepToPrec( this.raField.step  )) + 'h';
    this.LBL.raLabel.setPosition( { ra: ra - 0.9, dec: 5,       r: 1.001 });
    this.LBL.raLabel.setOrientationAbsolute();
    this.LBL.decLabel.text = legToFixed(dec, stepToPrec( this.decField.step )) + '°';
    this.LBL.decLabel.setPosition({ ra: ra + 0.9, dec: dec / 2, r: 1.001 });
    this.LBL.decLabel.setOrientationAbsolute();
    this.OBJ.star.setPosition({ ra, dec });
    this.OBJ.star.setOrientationAbsolute();

    if (ra !== 0) {
      this.C.raArc.setParameters(  { ra: 0, dec: 0, tilt:  0, gammaStart:   0, gammaEnd: 15 * ra });
      this.C.raArc.visible = true;
    } else {
      this.C.raArc.visible = false;
    }
    this.C.raCircle.setParameters( { ra,    dec: 0, tilt: 90, gammaStart: -90, gammaEnd: 90  });
    if (dec < 0) {
      this.C.decArc.setParameters( { ra,    dec: 0, tilt: 90, gammaStart: dec, gammaEnd:  0  });
      this.C.decArc.visible = true;
    } else if (dec > 0) {
      this.C.decArc.setParameters( { ra,    dec: 0, tilt: 90, gammaStart:   0, gammaEnd: dec });
      this.C.decArc.visible = true;
    } else {
      this.C.decArc.visible = false;
    }
    this.C.decCircle.setParameters({ ra: 0, dec,    tilt: 0 });

    if (!skipSliderSync) {
      this.raRange.value  = ra;
      this.decRange.value = dec;
      this.raField.value  = legToFixed( ra,  stepToPrec( this.raField.step  ) );
      this.decField.value = legToFixed( dec, stepToPrec( this.decField.step ) );
    }
    this.syncReadouts();
    this.updateStarScreen();
  }

  updateLabels() {
    this.LBL.eastArrowLbl.visible = this.OBJ.eastArrow.visible = this.labels.eastArrow;
    this.C.ecliptic.visible       = this.labels.ecliptic;
    this.LBL.ecliptic.visible     = this.labels.ecliptic;
    this.LBL.northPole.visible    = this.LBL.southPole.visible = this.labels.earthPoles;
    this.LBL.equator.visible      = this.labels.equator;
    this.LBL.ncp.visible          = this.LBL.scp.visible       = this.labels.celPoles;
    this.LBL.ce.visible           = this.labels.celEquator;
    this.LBL.zeroHours.visible    = this.labels.zeroHours;
    updateShowHideLabelButtons(this.showAllBtn, this.hideAllBtn, Object.values(this.chk));
  }

  showAllLabels() { this.setAllLabels(true);  }
  hideAllLabels() { this.setAllLabels(false); }

  setAllLabels(v) {
    for (const k in this.labels) this.labels[k] = v;
    this.syncCheckboxes();
    this.updateLabels();
    this.render();
    this.announce(v ? 'All labels shown.' : 'All labels hidden.');
  }

  syncCheckboxes() {
    for (const k in this.chk) this.chk[k].checked = this.labels[k];
  }

  render() {
    const ctx = this.ctx, cx = this.CENTER, cy = this.CENTER;
    this.S.doA();     this.S.doB();
    this.inner.doA(); this.inner.doB();
    for (const o of this.objects) o.update();
    for (const c of this.circles) c.update();
    for (const l of this.lines)   l.update();

    this.updateStarScreen();
    const starFront = isScreenFront(this.star.sp);

    ctx.clearRect(0, 0, this.STAGE, this.STAGE);
    ctx.save();
    ctx.translate(cx, cy);

    this.drawFeatureLabels('back',  'other' );  // beyond celestial sphere
    this.paintCircleBucket('back', starFront);
    drawLineLayer(ctx, this.lines, 'back');
    if (!starFront) this.drawStar();

    if (hatchEcliptic)  {
      drawCircleHatch(ctx, this.circles, 'back', { dim: 0.55 });  // hatching in ecliptic plane
    }
    this.drawEastArrow(  'back');
    this.drawValueLabels('back');

    this.drawInnerSprites('back' );
    this.drawEarth();
    this.drawInnerSprites('front');
    
    this.drawFeatureLabels('back',  'earth');  // within celestial sphere

    if (hatchEcliptic)  {
      drawCircleHatch(ctx, this.circles, 'front');  // hatching in ecliptic plane
    }
    
    // Add tight circle border around celestial sphere
    drawGlass(    ctx, this.S, this.S.CSC);
    drawSphereRim(ctx, this.S, this.S.CSC);

    this.drawFeatureLabels('front', 'earth');  // within celestial sphere
    if (starFront) {
                              drawCircleArcBack(ctx, this.decArc, { });
      if (this.raArc.visible) drawCircleArcBack(ctx, this.raArc,  { });
    }

    this.paintCircleBucket('front', starFront);
    this.drawCelestialPoleMarkers();
    drawLineLayer(   ctx, this.lines,   'front');

    if (starFront) this.drawStar();
    this.drawValueLabels( 'front');
    this.drawEastArrow(   'front');

    this.drawFeatureLabels('front', 'other');  // beyond celestial sphere

    ctx.restore();
    this.positionStarHandle();
  }

  paintCircleBucket(which, starFront) {
    drawCircleBucket(this.ctx, this.circles, which, {
      skip: (c, w) => {
        const isGuide = (c === this.decArc || c === this.raArc);
        return w === 'back' && isGuide && starFront;
      },
      lineCap: 'round'
    });
  }

  drawCelestialPoleMarkers() {
    const pN = {}, pS = {};
    this.S.parsePointInput({ ra: 0, dec:  90, r: 1 }, pN);
    this.S.parsePointInput({ ra: 0, dec: -90, r: 1 }, pS);
    drawMarker(this.ctx, this.S, pN, this.S.CSC);
    drawMarker(this.ctx, this.S, pS, this.S.CSC);
  }

  isValueLabel(o) {
    return o === this.LBL.raLabel || o === this.LBL.decLabel;
  }

  isFeatureLabel(o) {
    return o.label && !this.isValueLabel(o);
  }

  drawValueLabels(which) {
    for (const key of ['raLabel', 'decLabel']) {
      const o = this.LBL[key];
      const behind = o._sp.z < 0;
      if ((which === 'back' && !behind) || (which === 'front' && behind)) continue;
      drawOrientedLabel(this.ctx, this.S, o._p, o.text, o.opts.color, {
        sys: o._sys, alpha: behind ? 0.5 : 1, halo: this.S.CSC.LABEL_HALO
      });
    }
  }

  drawFeatureLabels(which, where) {
    for (const o of this.objects) {
      if (!this.isFeatureLabel(o) || !o.visible) continue;
      const behind = o._sp.z < 0;
      const terran = ( o.opts.earth && o.opts.earth == true );
      // Divide labels into those in front of or behind the celestial sphere center
      if ((which === 'back' && behind) || (which === 'front' && !behind))  {
        // Divide labels into those near to Earth (N/S Poles. Equator),
        // or beyond celestial sphere, and hide East label when east-pointing arrow
        // disappears because it is edge-on
        if ( ( ( (where == 'earth') && ( o.opts.earth && o.opts.earth == true ) ) || 
               ( (where == 'other') && (!o.opts.earth || o.opts.earth == false) ) ) && 
             ( ( Math.abs( this.S.getPhi() ) < 89 ) || o.text != 'East' ) )  {  
          this.drawLabel(o);
        }
      }
    }
  }

  drawStar() {
    const o = this.OBJ.star;
    if (!o || o.visible === false) return;
    drawStarSprite(this.ctx, this.S, this.star.p,
      this.img.star, this.img.starHv, this.starHover, { sp: this.star.sp, sys: 1 });
  }

  drawInnerSprites(which) {
    const o = this.OBJ.rotationArrow;
    if (!o || o.visible === false) return;
    const behind = o._sp.z < 0;
    if ((which === 'back' && behind) || (which === 'front' && !behind))
      this.drawGraphicalObject(o);
  }

  drawEastArrow(which) {
    const o = this.OBJ.eastArrow;
    if (!o || o.visible === false) return;
    const behind = o._sp.z < 0;
    if ((which === 'back' && behind) || (which === 'front' && !behind))
      this.drawGraphicalObject(o);
  }

  drawEarth() {
    const ctx = this.ctx, inner = this.inner, CSC = this.S.CSC;
    const r = inner.c.r;
    this.earthNP.update();
    this.earthSP.update();
    drawLineLayer(ctx, [this.earthNP], 'back' );
    drawLineLayer(ctx, [this.earthSP], 'back' );
    ctx.save();
    ctx.beginPath();
    ctx.arc(0, 0, r, 0, TWO_PI);
    ctx.clip();
    const wg = ctx.createRadialGradient(-r * 0.3, -r * 0.3, r * 0.1, 0, 0, r);
    wg.addColorStop(0, CSC.EARTH_1);
    wg.addColorStop(1, CSC.EARTH_2);
    ctx.fillStyle = wg;
    ctx.beginPath();
    ctx.arc(0, 0, r, 0, TWO_PI);
    ctx.fill();
    ctx.fillStyle = CSC.EARTH_3;
    fillShorePolygons(ctx, EARTH_SHORES, (pt, out) => inner.CtoSz(pt, out), r);
    ctx.restore();

    this.earthEquator.update();
    strokeCirclePaths(ctx, this.earthEquator.back,  {
      color: this.earthEquator.color, thick: this.earthEquator.thick, alpha: this.earthEquator.alpha * 0.35
    });
    strokeCirclePaths(ctx, this.earthEquator.front, {
      color: this.earthEquator.color, thick: this.earthEquator.thick, alpha: this.earthEquator.alpha
    });
    drawLineLayer(ctx, [this.earthNP], 'front');
    drawLineLayer(ctx, [this.earthSP], 'front');
  }

  drawGraphicalObject(o) {
    const ctx = this.ctx, k = o.opts.kind, sp = o._sp;
    ctx.save();
    ctx.translate(sp.x, sp.y);
    let imgKey;
    if      (k === 'eastArrow')     imgKey = 'eastArrow';
    else if (k === 'rotationArrow') imgKey = 'rotationArrow';
    if (!imgKey) { ctx.restore(); return; }
    const img = this.img[imgKey];
    const dim = this.imgDim[imgKey];
    if (!img?.complete || !dim) { ctx.restore(); return; }
    ctx.rotate(o.rotation || 0);
    const ys  = o.yscale || 1;
    ctx.scale(1, ys === 0 ? 0.001 : ys);
    ctx.rotate(o.instRotation || 0);
    const w   = img.naturalWidth  || dim[0];
    const h   = img.naturalHeight || dim[1];
    const sc  = 0.6;
    ctx.globalAlpha = sp.z < 0 ? 0.5 : 1;
    ctx.scale(sc, sc);
    ctx.drawImage(img, -w / 2, -h / 2, w, h);
    ctx.restore();
  }

  drawLabel(o) {
    if (!o.visible) return;
    const ctx = this.ctx, sp = o._sp;
    ctx.save();
    ctx.font = '12px SimVerdana, Verdana, Arial, sans-serif';
    ctx.textBaseline = 'middle';
  //ctx.globalAlpha  = sp.z < 0 ? 0.5 : 1;  // celestial sphere now drawn properly in between front and back
    const col = (o.opts && o.opts.color != null) ? o.opts.color : this.S.CSC.LABEL_FILL;
    if (o.opts && o.opts.leader) {
      const ax  = sp.x, ay = sp.y;
      const len = Math.sqrt(ax * ax + ay * ay);
      let dx, dy;
      if      (len < 1) { dx = -0.7071;  dy = -0.7071;  }  // poles, viewer above/below N/SCP
      else if (ax == 0) { dx =  0.7071;  dy =  0.7071 * Math.sign(ay);  }  // poles
      else              { dx = ax / len; dy = ay / len; }
      const gap = 0.25; // space between target and leader line
      const off = 32, tx = ax + dx * off, ty = ay + dy * off;
      ctx.strokeStyle = hexToRGBA(this.S.CSC.LABEL_LNSG, 0.9);
      ctx.lineWidth = 1;
      ctx.beginPath();
    //ctx.moveTo(ax, ay);
      ctx.moveTo(ax + (dx*off)*gap, ay + (dy*off)*gap);
      ctx.lineTo(tx, ty);
      ctx.stroke();
      ctx.textAlign = (dx < 0) ? 'right' : 'left';
      const lx = tx + (dx < 0 ? -3 : 3);
      ctx.lineWidth   = 3;
      ctx.strokeStyle = hexToRGBA(this.S.CSC.LABEL_HALO, 0.9);
      ctx.lineJoin    = 'round';
      ctx.strokeText(o.text, lx, ty);
      ctx.fillStyle   = col;
      ctx.fillText(  o.text, lx, ty);
      /*
      console.log( "chk 1", o.text,  Math.round(len),
                   Math.round(sp.x), Math.round(sp.y),
                   Math.round(tx),   Math.round(ty) );
      if ( o.text == 'South Celestial Pole' )  { console.log( "chk 1 0.9", Math.round(sp.z), o.text ); }
      */
    } else {
      const ox = (o.opts && o.opts.dx) || 0, oy = (o.opts && o.opts.dy) || 0;
      const px = sp.x + ox, py = sp.y + oy;
      ctx.textAlign   = 'center';
      ctx.lineWidth   = 3;
      ctx.strokeStyle = hexToRGBA(this.S.CSC.LABEL_HALO, 0.85);
      ctx.lineJoin    = 'round';
      ctx.strokeText(o.text, px, py);
      ctx.fillStyle   = col;
      ctx.fillText(o.text, px, py);
      if ( o.text == 'South Celestial Pole' )  { console.log( "chk 2 0.85", Math.round(sp.z), o.text ); }
    }
    ctx.restore();
  }

  positionStarHandle() {
    if (!this.starHandle) return;
    const op     = this.starHandle.offsetParent;
    if (!op) return;
    
    const cr     = this.canvas.getBoundingClientRect();
    const wr     = op.getBoundingClientRect();
    const scaleX = cr.width  / this.STAGE;
    const scaleY = cr.height / this.STAGE;
    const sp     = this.OBJ.star._sp;
    this.starHandle.style.left = (cr.left - wr.left + (this.CENTER + sp.x) * scaleX) + 'px';
    this.starHandle.style.top  = (cr.top  - wr.top  + (this.CENTER + sp.y) * scaleY) + 'px';
  }

  pointerToStage(ev) {
    const rect = this.canvas.getBoundingClientRect();
    const sx = rect.width  ? this.STAGE / rect.width  : 1;
    const sy = rect.height ? this.STAGE / rect.height : 1;
    return {
      x: (ev.clientX - rect.left) * sx - this.CENTER,
      y: (ev.clientY - rect.top)  * sy - this.CENTER
    };
  }

  clampRa(v)  { v = parseFloat(v); if (isNaN(v)) return this.star.ra;  return Math.max(0, Math.min(24, v)); }
  clampDec(v) { v = parseFloat(v); if (isNaN(v)) return this.star.dec; return Math.max(-90, Math.min(90, v)); }

  labelName(k) {
    return {
      earthPoles: 'North and South Pole',           equator:    'Equator',
      celPoles:   'North and South Celestial Pole', celEquator: 'Celestial Equator',
      zeroHours:  'Zero-hour circle',               ecliptic:   'Ecliptic',
      eastArrow:  'East arrow'
    }[k];
  }

  starDescription() {
    return 'Star at right ascension ' + speak(this.star.ra,  stepToPrec( this.raField.step  ), 'hour')   +
                     ', declination ' + speak(this.star.dec, stepToPrec( this.decField.step ), 'degree') + ', ' + 
                     locateStar(this.star.ra, this.star.dec, 1);
  }

  viewDescription() {
    return 'View rotated. Azimuth ' + speak(pMod(this.S.getTheta(), 360), 0, 'degree') +
                          ', tilt ' + speak(this.S.getPhi(),              0, 'degree') + '. ' +
      this.starDescription();
  }

  describeScene() {
    const shown = [];
    if (this.labels.earthPoles) shown.push('Earth poles');
    if (this.labels.equator)    shown.push('equator');
    if (this.labels.celPoles)   shown.push('celestial poles');
    if (this.labels.celEquator) shown.push('celestial equator');
    if (this.labels.zeroHours)  shown.push('zero-hour circle');
    if (this.labels.ecliptic)   shown.push('ecliptic');
    if (this.labels.eastArrow)  shown.push('east arrow');
    return 'Celestial sphere with the Earth at its center, viewed at azimuth ' +
      speak(pMod(this.S.getTheta(), 360), 0, 'degree') + ' and tilt ' +
      speak(this.S.getPhi(), 0, 'degree') +
      '. A star is plotted at right ascension ' + speak(this.star.ra,  stepToPrec( this.raField.step  ), ' hour') +
                               ', declination ' + speak(this.star.dec, stepToPrec( this.decField.step ), 'degree') +
      ', with its right ascension and declination shown as coloured arcs. ' +
      (shown.length ? 'Labels shown: ' + shown.join(', ') + '.' : 'No labels shown.') +
      ' Arrow keys rotate this view; Tab to the star marker to move the star with the arrow keys instead.';
  }

  announce(msg) {
    if (this.live)    this.live.textContent    = msg;
    if (this.skyDesc) this.skyDesc.textContent = this.describeScene();
  }

  syncReadouts() {
    const decSign = this.star.dec >= 0 ? '+' : '';
    if (window.klunlShowEquation) {
      window.klunlShowEquation(
        ['star-eqn', '\\(\\mathrm{RA} = ' +
         legToFixed(this.star.ra,  stepToPrec( this.raField.step  )) + '^{\\mathrm{h}}, ' +
         '\\quad \\mathrm{dec} = ' + decSign +
         legToFixed(this.star.dec, stepToPrec( this.decField.step )) + '^{\\circ}\\)'],
        ['star-eqn-sr', 'Star position: right ascension ' +
         speak(this.star.ra,  stepToPrec( this.raField.step  ), 'hour') +
         ', declination ' +
         speak(this.star.dec, stepToPrec( this.decField.step ), 'degree') + '.']);
    }
    this.raRange.setAttribute( 'aria-valuetext',
      speak(this.star.ra,  stepToPrec( this.raField.step  ), 'hour'));
    this.decRange.setAttribute('aria-valuetext',
      speak(this.star.dec, stepToPrec( this.decField.step ), 'degree'));
    if (this.starHandle) {
      this.starHandle.setAttribute('aria-label',
        'Star at right ascension ' + speak(this.star.ra,  stepToPrec( this.raField.step  ), 'hour') +
        ', declination ' + speak(this.star.dec, stepToPrec( this.decField.step ), 'degree') +
        '. Use the arrow keys to move it: left and right change right ascension, ' +
        'up and down change declination.');
    }
    updateSliderProgress(this.raRange);
    updateSliderProgress(this.decRange);
  }

  setupMathJaxTabStrip() {
    const el = document.getElementById('star-eqn');
    if (!el) return;
    const strip = () => {
      const cs = el.querySelectorAll('mjx-container[tabindex]:not([tabindex="-1"])');
      for (const c of cs) c.setAttribute('tabindex', '-1');
    };
    if (window.MutationObserver) {
      new MutationObserver(strip).observe(el, {
        childList: true, subtree: true, attributes: true, attributeFilter: ['tabindex']
      });
    }
    strip();
  }

  bindEvents() {
    document.addEventListener('sim-reset', () => this.reset());
    window.addEventListener(  'resize',    () => this.fitCanvas());
    if (document.fonts && document.fonts.ready) document.fonts.ready.then(() => this.render());

    this.canvas.addEventListener('pointerdown', (ev) => {
      this.canvas.setPointerCapture(ev.pointerId);
      this.canvas.classList.add('dragging');
      const m  = this.pointerToStage(ev);
      const st = this.OBJ.star._sp;
      const dx = m.x - st.x, dy = m.y - st.y;
      if (st.z > 0 && Math.sqrt(dx * dx + dy * dy) <= 12) {
        this.drag = { mode: 'star' };
        if (this.starHandle) this.starHandle.focus();
      } else {
        this.drag = { mode: 'view', x: m.x, y: m.y, theta: this.S.theta, phi: this.S.phi };
        this.canvas.focus();
      }
      ev.preventDefault();
    });

    this.canvas.addEventListener('pointermove', (ev) => {
      const m = this.pointerToStage(ev);
      if (!this.drag) {
        const st = this.OBJ.star._sp;
        const d = Math.sqrt((m.x - st.x) ** 2 + (m.y - st.y) ** 2);
        const h = (st.z > 0 && d <= 12);
        if (h !== this.starHover) { this.starHover = h; this.render(); }
        return;
      }
      if (this.drag.mode === 'view') {
        this.S.setThetaAndPhi(
          R2D * (this.drag.theta - (m.x - this.drag.x) / this.S.c.r),
          R2D * (this.drag.phi   + (m.y - this.drag.y) / this.S.c.r));
        this.onSphereOrientationChanged();
        this.render();
      } else {
        const rd = this.S.screenToRaDec(m.x, m.y);
        if (rd) { this.setStarLocation(rd.ra, rd.dec, false); this.render(); }
      }
      ev.preventDefault();
    });

    const endDrag = () => {
      this.canvas.classList.remove('dragging');
      if (this.drag) {
        this.announce(this.drag.mode === 'view' ? this.viewDescription() : this.starDescription());
      }
      this.drag = null;
    };
    this.canvas.addEventListener('pointerup',     endDrag);
    this.canvas.addEventListener('pointercancel', endDrag);

    this.canvas.addEventListener('keydown', (ev) => {
      const step = ( ev.shiftKey || ev.getModifierState('CapsLock') ) ? 15 : 5;
      let t = this.S.getTheta(), p = this.S.getPhi(), used = true;
      switch (ev.key) {
        case 'ArrowLeft':  this.S.setThetaAndPhi(t + step, p); break;
        case 'ArrowRight': this.S.setThetaAndPhi(t - step, p); break;
        case 'ArrowUp':    this.S.setThetaAndPhi(t, p - step); break;
        case 'ArrowDown':  this.S.setThetaAndPhi(t, p + step); break;
        default: used = false;
      }
      if (used) {
        ev.preventDefault();
        this.onSphereOrientationChanged();
        this.render();
        this.announce(this.viewDescription());
      }
    });

    if (this.starHandle) {
      this.starHandle.addEventListener('keydown', (ev) => {
        let used = true;
        let dStp = Number(this.decField.step);
        if ( ( ev.key == 'ArrowLeft' ) || ( ev.key == 'ArrowRight' ) )  { dStp = Number(this.raField.step); }
        const step = ( ev.shiftKey || ev.getModifierState('CapsLock') ) ? 10*dStp : dStp;
      //const raStep  = ( ev.shiftKey || ev.getModifierState('CapsLock') ) ? 0.5 : 0.1;
      //const decStep = ( ev.shiftKey || ev.getModifierState('CapsLock') ) ? 5   : 1;
        let ra = this.star.ra, dec = this.star.dec;
        switch (ev.key) {
          /*
          case 'ArrowLeft':  ra  = this.clampRa( ra  - raStep ); break;
          case 'ArrowRight': ra  = this.clampRa( ra  + raStep ); break;
          case 'ArrowUp':    dec = this.clampDec(dec + decStep); break;
          case 'ArrowDown':  dec = this.clampDec(dec - decStep); break;
          */
          case 'ArrowLeft':  ra  = this.clampRa( ra  - step ); break;
          case 'ArrowRight': ra  = this.clampRa( ra  + step ); break;
          case 'ArrowUp':    dec = this.clampDec(dec + step ); break;
          case 'ArrowDown':  dec = this.clampDec(dec - step ); break;
          case 'Enter': case ' ': ev.preventDefault(); return;
          default: used = false;
        }
        if (used) {
          ev.preventDefault();
          this.setStarLocation(ra, dec, false);
          this.render();
          this.announce(this.starDescription());
        }
      });
    }

    // Recalculate star-handle coordinates when canvas container changes size
    // within flex layout
    if (window.ResizeObserver) {
      const rObs = new ResizeObserver(() => {
        this.positionStarHandle();
      });
      rObs.observe(this.canvas);
    }
    
    this.raRange.addEventListener('input', () => {
      this.setStarLocation(this.clampRa(this.raRange.value), this.star.dec, true);
      this.raField.value  = legToFixed( this.star.ra,  stepToPrec( this.raField.step  ) );
      this.render();
    });
    this.decRange.addEventListener('input', () => {
      this.setStarLocation(this.star.ra, this.clampDec(this.decRange.value), true);
      this.decField.value = legToFixed( this.star.dec, stepToPrec( this.decField.step ) );
      this.render();
    });

    this.raRange.addEventListener( 'change', () => this.announce(this.starDescription()));
    this.decRange.addEventListener('change', () => this.announce(this.starDescription()));

    const commitField = (field, isRa) => {
      const v = isRa ? this.clampRa(field.value) : this.clampDec(field.value);
      if (isRa) this.setStarLocation(v, this.star.dec, false);
      else      this.setStarLocation(this.star.ra, v,  false);
      this.render();
      this.announce(this.starDescription());
    };
    this.raField.addEventListener( 'keydown', noEinNumber );
    this.decField.addEventListener('keydown', noEinNumber );

    this.raField.addEventListener( 'change', () => commitField(this.raField,  true ));
    this.decField.addEventListener('change', () => commitField(this.decField, false));

    const stepField = (field, isRa, delta) => {
      const cur = isRa ? this.clampRa(field.value) : this.clampDec(field.value);
      const v   = isRa ? this.clampRa(cur + delta) : this.clampDec(cur + delta);
      if (isRa) this.setStarLocation(v, this.star.dec, false);
      else      this.setStarLocation(this.star.ra,  v, false);
      this.render();
      this.announce(this.starDescription());
    };
    const wireFieldStepping = (field, isRa) => {
      field.addEventListener('keydown', (ev) => {
        const dir = (ev.key === 'ArrowUp'   || ev.key === 'ArrowRight' || ev.key === 'PageUp'  ) ?  1
                  : (ev.key === 'ArrowDown' || ev.key === 'ArrowLeft'  || ev.key === 'PageDown') ? -1 : 0;
        if (!dir) return;
        ev.preventDefault();

        const step = isRa ? Number(this.raField.step) : Number(this.decField.step);
        stepField(field, isRa,
          dir * ( ( ev.key === 'PageUp' || ev.key === 'PageDown'           ) ? 15*step : 
                  ( ev.shiftKey         || ev.getModifierState('CapsLock') ) ? 10*step : step ) );
      });
      field.addEventListener('wheel', (ev) => {
        if (document.activeElement !== field) return;
        ev.preventDefault();
        const step = isRa ? Number(this.raField.step) : Number(this.decField.step);
        stepField(field, isRa,
          (ev.deltaY < 0 ? 1 : -1) * (ev.shiftKey || ev.getModifierState('CapsLock') ? 10*step : step ) );
      }, { passive: false });
    };
    wireFieldStepping(this.raField,  true );
    wireFieldStepping(this.decField, false);

    for (const k in this.chk) {
      this.chk[k].addEventListener('change', () => {
        this.labels[k] = this.chk[k].checked;
        this.updateLabels();
        this.render();
        this.announce(this.chk[k].checked ? this.labelName(k) + ' labels shown.' : this.labelName(k) + ' labels hidden.');
      });
    }
    document.getElementById('showAllBtn').addEventListener('click', () => this.showAllLabels());
    document.getElementById('hideAllBtn').addEventListener('click', () => this.hideAllLabels());
  }
}

function boot() {
  if (!window.ceqApp) {
    window.ceqApp = new App();
    window.ceqApp.syncReadouts();
    if (window.MathJax && MathJax.startup && MathJax.startup.promise) {
      MathJax.startup.promise.then(() => {
        window.ceqApp.syncReadouts();
        if (MathJax.typesetPromise) MathJax.typesetPromise().catch((e) => console.error(e));
      });
    }
  }
}

window.klunlInitEqn = boot;
if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', boot);
} else {
  boot();
}
