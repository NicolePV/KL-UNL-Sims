/* ==========================================================================
   Celestial and Horizon Systems Comparison
   HTML5 port of celestialHorizon004.swf (Adobe Flash, ActionScript 1).

   Modern ES module using foundation CelestialSphere / Circle / Line /
   CSObject / GlobeComponent / sphere-shading helpers. Visual and behavioral
   parity with archive/simulation_02.js (morph, latitude, drag, Flash depth
   stack).

   Sim-local: art loading, Flash Instance transforms, Scene/DepthStack
   renderer, tangent plane / stickfigure / observer-dot drawing, nested
   little-Earth globe, celestial↔horizon morph, and UI controller.
   ========================================================================== */

import {
  CelestialSphere, Circle, Line, CSObject,
  CELESTIAL_SPHERE_COLORS,
  D2R, R2D, HALF_PI, 
  strokeCirclePaths, drawLineLayer
} from '../foundation/js/kl-unl-celestial-sphere.js';

import { GlobeComponent, drawGlobeDisk } from '../foundation/js/kl-unl-globe.js';

import {
  buildHorizonMasks, withClip, drawGradientDisk,
  horizonPlaneTransform, drawHorizonPlaneArt
} from '../foundation/js/kl-unl-sphere-shading.js';

import {
  legToFixed, speak, pMod, noEinNumber, keyAccel,
  updateSliderProgress, announceLive, VO_FIX_LGND, logAct
} from '../foundation/js/kl-unl-utils.js';

import { EARTH_SHORES } from '../foundation/js/kl-unl-earth-shores.js';

logAct('INIT_celestialhorizon');

let currentTransitionResolve = null;

/* ------------------------------------------------------------------ *
 *  Constants (from archive / ActionScript)                             *
 * ------------------------------------------------------------------ */

const CSC = CELESTIAL_SPHERE_COLORS;

const TRANSITION_TIME   = 3000;
const MAX_GLOBE_SIZE    =   80;
const SPHERE_SIZE       =  300;
const GLOBE_SPHERE_SIZE =   80;
const INIT_THETA        =  105;
const INIT_PHI          =   30;
const INIT_LATITUDE     =   41;
const LAT_MIN           =  -90;
const LAT_MAX           =   90;
const LAT_INCREMENT     =    0.1;
const LAT_PRECISION     =    1;

const STAGE             =  380;
const ORIGIN            = STAGE / 2;

/* Transition Arrow */
const ARROW_MIN_COLOR  = 0x767676;
const ARROW_MAX_COLOR  = 0x1a1a1a;
const ARROW_MIN_FACTOR = 0.001;
const ARROW_MAX_FACTOR = 1;
const ARROW_HALF_RANGE = (ARROW_MAX_FACTOR - ARROW_MIN_FACTOR) / 2;
const ARROW_HALF_POINT =  ARROW_MIN_FACTOR + ARROW_HALF_RANGE;

/* ------------------------------------------------------------------ *
 *  Artwork                                                           *
 * ------------------------------------------------------------------ */

const ART = {
  sphereShading: { src: 'images/sphere-shading.svg',      w: 200,    h: 200,   ox: 100,    oy: 100    },
  horizonAbove:  { src: 'images/horizon-plane-above.svg', w: 199.95, h: 200,   ox:  99.95, oy: 100    },
  horizonBelow:  { src: 'images/horizon-plane-below.svg', w: 199.95, h: 200,   ox:  99.95, oy: 100    },
  globeWater:    { src: 'images/globe-water.svg',         w:  80,    h:  80,   ox:  40,    oy:  40    },
  globeLand:     { src: 'images/globe-land.svg',          w:  80,    h:  80,   ox:  40,    oy:  40    },
  observerDot:   { src: 'images/observer-dot_green.png',  w:   8.5,  h:   8.5, ox:   4.25, oy:   4.25 },
  stickfigure:   { src: 'images/fox02.png',               w:  34.5,  h:  50,   ox:   17.25,oy:   42.5 }
};

function loadArt() {
  return Promise.all(Object.keys(ART).map((key) => new Promise((resolve) => {
    const a       = ART[key];
    a.img         = new Image();
    a.img.onload  = () => { a.ready = true;  resolve(); };
    a.img.onerror = () => { a.ready = false; resolve(); };
    a.img.src     = a.src;
  })));
}

function drawArt(ctx, a) {
  if (a.ready) ctx.drawImage(a.img, -a.ox, -a.oy, a.w, a.h);
}

/* ------------------------------------------------------------------ *
 *  Flash-style Instance transform (percent / degrees / 0–100 alpha)    *
 * ------------------------------------------------------------------ */

class Instance {
  constructor() {
    this._xscale   = 100;
    this._yscale   = 100;
    this._rotation =   0;   // degrees
    this._alpha    = 100;   // 0–100
  }

  drawArt(_ctx) {}

  draw(ctx) {
    ctx.save();
    if (this._rotation) ctx.rotate(this._rotation * D2R);
    ctx.scale(this._xscale / 100, this._yscale / 100);
    if (this._alpha < 100) {
      ctx.globalAlpha *= Math.max(0, this._alpha) / 100;
    }
    this.drawArt(ctx);
    ctx.restore();
  }
}

/* ------------------------------------------------------------------ *
 *  Placed object: foundation CSObject + Instance + draw hook         *
 * ------------------------------------------------------------------ */

/**
 * Sim-specific placement wrapper. Uses foundation CSObject for projection
 * and orientation; Instance for Flash-style nested drawing transforms.
 */
class PlacedObject {
  constructor(sphere, name, inst, position) {
    this.cs           = new CSObject(sphere, name);
    this.inst         = inst || new Instance();
    this.inst._sphere = sphere;
    this.inst._object = this;
    this.visible      = true;
    sphere.minPhi     = -180; 
    if (position) this.cs.setPosition(position);
  }

  get r()   { return this.cs.r;   }
  get sys() { return this.cs.sys; }
  get p()   { return this.cs.p;   }
  get sp()  { return this.cs.sp;  }

  setPosition(arg) { this.cs.setPosition(arg); }

  setAbsoluteOrientation(arg2, arg3) {
    this.cs.setAbsoluteOrientation(arg2, arg3);
  }

  setSkewedOrientation(arg2) {
    this.cs.setSkewedOrientation(arg2);
  }

  updateOrientation() {
    // Sync Instance._rotation from foundation innerRotation (radians → degrees)
    this.cs.update();
    if (this.cs.oType === 2) {
      this.inst._rotation = this.cs.innerRotation * R2D;
    }
  }

  draw(ctx) {
    const obj = this.cs;
    ctx.save();
    ctx.translate(obj.sp.x, obj.sp.y);
    if (obj.rotation) ctx.rotate(obj.rotation);
    ctx.scale(1, obj.yScale === 0 ? 1e-6 : obj.yScale);
    this.inst.draw(ctx);
    ctx.restore();
  }
}

/* ------------------------------------------------------------------ *
 *  Scene / DepthStack — Flash layer order from archive                 *
 * ------------------------------------------------------------------ */

function sortRegion(a, b) {
  return a.z < b.z ? -1 : (a.z > b.z ? 1 : 0);
}

class Scene {
  /**
   * @param {CelestialSphere} sphere
   * @param {{hpVisible?: boolean}} [opts]
   */
  constructor(sphere, opts = {}) {
    this.sphere    = sphere;
    this.circles   = [];
    this.lines     = [];
    this.objects   = [];
    this.hpVisible = opts.hpVisible !== undefined ? opts.hpVisible : true;
    this.shading   = {
      bOSB: [], bOSA: [], bOSF: [],
      bISB: [], bISA: [], bISF: [],
      fISB: [], fISA: [], fISF: [],
      fOSB: [], fOSA: [], fOSF: []
    };
    this.hPlane   = { above: [], below: [] };
    this.grp      = { bE: [], bS: [], bI: [], aI: [], fS: [], fE: [] };
    this.M1       = null; this.M2 = null; this.M3 = null; this.M4 = null;
    this.hpXScale = 100; this.hpYScale = 100; this.hpRotation = 0; this.hpSide = 'above';

    // Archive CelestialSphere constructor always added these clips.
    this.addHorizonPlaneClip('CSAboveHorizonPlane', 'above');
    this.addHorizonPlaneClip('CSBelowHorizonPlane', 'below');
    this.addShadingClip(     'CSGradientDisk', 'front', 'inner', 'both', {
      innerAlpha: 0,    innerColor: '#ffffff',  // (white)
      outerAlpha: 0.20, outerColor: '#000000'   // (black)
    });
  }

  addCircle(name, style, def) {
    const c    = new Circle(this.sphere, style, def);
    this[name] = c;
    this.circles.push(c);
    return c;
  }

  addLine(name, style, head, tail) {
    const l    = new Line(this.sphere, style, head, tail);
    this[name] = l;
    this.lines.push(l);
    return l;
  }

  addObject(name, placed) {
    this[name] = placed;
    this.objects.push(placed);
    return placed;
  }

  addShadingClip(linkageName, side, surface, hemisphere, initObject) {
    const layer = (side       === 'back'  ? 'b' : 'f') +
                  (surface    === 'inner' ? 'I' : 'O') + 'S' +
                  (hemisphere === 'below' ? 'B' : (hemisphere === 'above' ? 'A' : 'F'));
    const clip = { kind: linkageName, init: initObject || {} };
    this.shading[layer].push(clip);
    return clip;
  }

  addHorizonPlaneClip(linkageName, side) {
    const clip = { kind: linkageName };
    this.hPlane[side === 'below' ? 'below' : 'above'].push(clip);
    return clip;
  }

  updateMasks() {
    const masks = buildHorizonMasks(this.sphere);
    if (!masks) return;
    this.M1 = masks.M1;
    this.M2 = masks.M2;
    this.M3 = masks.M3;
    this.M4 = masks.M4;
  }

  updateHorizonPlane() {
    const t         = horizonPlaneTransform(this.sphere);
    this.hpXScale   = t.xScale;
    this.hpYScale   = t.yScale;
    this.hpRotation = t.rotationDeg;
    this.hpSide     = t.side;
  }

  updateCircles() {
    for (const c of this.circles) c.update();
  }

  updateLines() {
    for (const l of this.lines)   l.update();
  }

  updateObjects() {
    const g  = this.grp;
    g.bE     = []; g.bS = []; g.bI = []; g.aI = []; g.fS = []; g.fE = [];
    const S  = this.sphere;
    const hU = !S.showUnder;

    for (const placed of this.objects) {
      if (!placed.visible) continue;
      const obj = placed.cs;
      let wp;

      if (obj.r > 1) {
        if (hU) {
          wp = {};
          if      (obj.sys === 0) wp = obj.p;
          else if (obj.sys === 1) S.CtoW(obj.p, wp);
          if (wp.z < 0) continue;
          S.WtoSz(wp, obj.sp);
        } else if (obj.sys === 0) S.WtoSz(obj.p, obj.sp);
        else                      S.CtoSz(obj.p, obj.sp);
        (obj.sp.z < 0 ? g.bE : g.fE).push({ z: obj.sp.z, obj: placed });

      } else if (obj.r < 1) {
        wp = {};
        if      (obj.sys === 0) wp = obj.p;
        else if (obj.sys === 1) S.CtoW(obj.p, wp);
        if (hU && wp.z < 0) continue;
        S.WtoSz(wp, obj.sp);
        (wp.z < 0 ? g.bI : g.aI).push({ z: obj.sp.z, obj: placed });

      } else {
        if (hU) {
          wp = {};
          if      (obj.sys === 0) wp = obj.p;
          else if (obj.sys === 1) S.CtoW(obj.p, wp);
          if (wp.z < 0) continue;
          S.WtoSz(wp, obj.sp);
        } else if (obj.sys === 0) S.WtoSz(obj.p, obj.sp);
        else                      S.CtoSz(obj.p, obj.sp);
        (obj.sp.z < 0 ? g.bS : g.fS).push({ z: obj.sp.z, obj: placed });
      }

      placed.updateOrientation();
    }

    if (!this.hpVisible) {
      while (g.aI.length) g.bI.push(g.aI.pop());
    }

    g.bE.sort(sortRegion); g.bS.sort(sortRegion); g.bI.sort(sortRegion);
    g.aI.sort(sortRegion); g.fS.sort(sortRegion); g.fE.sort(sortRegion);
  }

  refresh() {
    this.updateMasks();
    this.updateHorizonPlane();
    this.updateCircles();
    this.updateLines();
    this.updateObjects();
  }

  _clipped(ctx, mask, fn) {
    withClip(ctx, mask, fn);
  }

  _drawShading(ctx, layer) {
    const list = this.shading[layer];
    if (!list.length) return;
    const scale = this.sphere.c.r / 100;
    for (const clip of list) {
      ctx.save();
      ctx.scale(scale, scale);
      if        (clip.kind === 'Sphere Shading') {
        drawArt(ctx, ART.sphereShading);
      } else if (clip.kind === 'CSGradientDisk') {
        drawGradientDisk(ctx, clip.init);
      }
      ctx.restore();
    }
  }

  _drawHorizonPlane(ctx) {
    if (!this.hpVisible) return;
    const list = this.hPlane[this.hpSide];
    if (!list.length) return;
    drawHorizonPlaneArt(
      ctx,
      {
        xScale:      this.hpXScale,
        yScale:      this.hpYScale,
        rotationDeg: this.hpRotation,
        side:        this.hpSide
      },
      (c) => drawArt(c, ART.horizonAbove),
      (c) => drawArt(c, ART.horizonBelow)
    );
  }

  _drawCircles(ctx, which) {
    for (const c of this.circles) {
      if (c.visible === false) continue;
      const paths = c[which];
      if (!paths || !paths.length) continue;
      strokeCirclePaths(ctx, paths, {
        color: c.color, thick: c.thick, alpha: c.alpha
      });
    }
    ctx.globalAlpha = 1;
  }

  _drawLines(ctx, which) {
    drawLineLayer(ctx, this.lines, which);
  }

  _drawGroup(ctx, group) {
    for (const entry of group) entry.obj.draw(ctx);
  }

  /** Flash depth-stack render order (archive CelestialSphere.render). */
  render(ctx) {
    const g           = this.grp;
    const phiPositive = this.sphere.phi >= 0;
    const self        = this;

    ctx.lineCap  = 'butt';
    ctx.lineJoin = 'round';

    this._drawGroup(ctx, g.bE);
    this._drawLines(ctx, 'bE');
    this._clipped(ctx, this.M4, () => { self._drawShading(ctx, 'bOSB'); });
    this._clipped(ctx, this.M3, () => { self._drawShading(ctx, 'bOSA'); });
    this._drawShading(ctx, 'bOSF');
    this._drawCircles(ctx, 'back');
    this._drawGroup(ctx, g.bS);
    this._clipped(ctx, this.M4, () => { self._drawShading(ctx, 'bISB'); });
    this._clipped(ctx, this.M3, () => { self._drawShading(ctx, 'bISA'); });
    this._drawShading(ctx, 'bISF');

    this._drawGroup(ctx, phiPositive ? g.bI : g.aI);
    this._drawLines(ctx, phiPositive ? 'bI' : 'aI');
    this._drawHorizonPlane(ctx);
    this._drawGroup(ctx, phiPositive ? g.aI : g.bI);
    this._drawLines(ctx, phiPositive ? 'aI' : 'bI');

    this._clipped(ctx, this.M2, () => { self._drawShading(ctx, 'fISB'); });
    this._clipped(ctx, this.M1, () => { self._drawShading(ctx, 'fISA'); });
    this._drawShading(ctx, 'fISF');
    this._drawCircles(ctx, 'front');
    this._drawGroup(ctx, g.fS);
    this._clipped(ctx, this.M2, () => { self._drawShading(ctx, 'fOSB'); });
    this._clipped(ctx, this.M1, () => { self._drawShading(ctx, 'fOSA'); });
    this._drawShading(ctx, 'fOSF');
    this._drawGroup(ctx, g.fE);
    this._drawLines(ctx, 'fE');
  }
}

/* ------------------------------------------------------------------ *
 *  Tangent plane, stickfigure, observer dot, nested globe              *
 * ------------------------------------------------------------------ */

class TangentPlaneInst extends Instance {
  constructor() {
    super();
    this._frame = 1;
  }

  update(arg, sphereSize, spZ) {
    this._xscale = this._yscale = sphereSize * (1 - arg) / 2;
    this._alpha  = 40 + 0.6 * this._xscale;
    this._frame  = (spZ >= 0) ? 1 : 2;
  }

  drawArt(ctx) {
    if (this._xscale <= 0.01) return;
    drawArt(ctx, this._frame === 1 ? ART.horizonAbove : ART.horizonBelow);

    const labelColor = (this._frame === 1) ? '#ffffff' : '#999999';
    ctx.save();
    ctx.fillStyle    = labelColor;
    ctx.font         = '12px Sans-Serif, Arial, Helvetica, sans-serif';
    ctx.textAlign    = 'center';
    ctx.textBaseline = 'middle';
    ctx.fillText('N',   0, -88);
    ctx.fillText('S',   0,  88);
    ctx.fillText('E',  88,   0);
    ctx.fillText('W', -88,   0);
    ctx.restore();
        
  }
}

class StickfigureInst extends Instance {
  drawArt(ctx) {
    if (this._xscale <= 0.01) return;
    drawArt(ctx, ART.stickfigure);
  }
}

class ObserverDotInst extends Instance {
  drawArt(ctx) { drawArt(ctx, ART.observerDot); }
}

/** Nested little-Earth Instance: morph scale + full globe Scene render. */
class GlobeSphereInst extends Instance {
  constructor(globeScene, globeComponent) {
    super();
    this.globeScene     = globeScene;
    this.globeComponent = globeComponent;
  }

  drawArt(ctx) {
    this.globeScene.refresh();
    this.globeScene.render(ctx);
  }
}

class GlobeArtInst extends Instance {
  constructor(globeComponent) {
    super();
    this.globeComponent = globeComponent;
    this._globeScale    = 100;
  }

  setScale(arg) { this._globeScale = arg; }

  drawArt(ctx) {
    drawGlobeDisk(ctx, this.globeComponent, {
      scale: this._globeScale / 100,
      water: (c) => drawArt(c, ART.globeWater),
      land:  (c) => drawArt(c, ART.globeLand)
    });
  }
}

/* ------------------------------------------------------------------ *
 *  Controller state                                                    *
 * ------------------------------------------------------------------ */

let canvas, ctx, dpr, renderScale = 1;
let mainScene, globeScene, globeComponent, globeSphere;
let globeSize = 1, latFrac = 1;
let transitionEpoch = 0, cancelActiveDelay = null;
let direction, startTime, animating;
let latVal, latValOld = 360;
let renderQueued = false;
let dragging     = false, dragPointerId = null;
let dragX = 0, dragY = 0, dragTheta = 0, dragPhi = 0;

const el = {};

function prefersReducedMotion() {
  return window.matchMedia &&
         window.matchMedia('(prefers-reduced-motion: reduce)').matches;
}

function sliderSetValue(x) {
  x = Number(x);
  if (!isFinite(x) || isNaN(x)) return latVal;
  if      (x < LAT_MIN) x = LAT_MIN;
  else if (x > LAT_MAX) x = LAT_MAX;
  return LAT_INCREMENT * Math.round(x / LAT_INCREMENT);
}

/* ---- initSphere ---- */

function initSphere() {
  const sphere = new CelestialSphere();
  sphere.setSize(SPHERE_SIZE);
  sphere.setLatitude(90);
  sphere.setSiderealTime(0);
  sphere.setThetaAndPhi(INIT_THETA, INIT_PHI);

  mainScene = new Scene(sphere, { hpVisible: false });
  mainScene.addShadingClip('Sphere Shading', 'front', 'inner', 'both');
  mainScene.addShadingClip('Sphere Shading', 'back',  'inner', 'both');

  mainScene.addCircle('horizonCircle',
    { thickness: 2, color: CSC.HOR_MRK,    alpha: 0.30 },
    { az: 0, alt: 0, tilt: 0 });
  mainScene.addCircle('meridianCircle1',
    { thickness: 2, color: CSC.HOR_MRK,    alpha: 0.30 },
    { az: 0, alt: 0, tilt: 0 });
  mainScene.addCircle('meridianCircle2',
    { thickness: 2, color: CSC.HOR_MRK,    alpha: 0.30 },
    { az: 0, alt: 0, tilt: 0 });
  mainScene.addCircle('zeroHoursCircle',
    { thickness: 2, color: CSC.CEL_EQUTR2, alpha: 0.70 },
    { ra: 0, dec: 0, tilt: 90, gammaStart: -90, gammaEnd: 90 });
  mainScene.addCircle('celestialEquator',
    { thickness: 2, color: CSC.CEL_EQUTR2, alpha: 0.70 },
    { ra: 0, dec: 0, tilt: 0 });

  mainScene.addLine('ncpAxis',
    { thickness: 2, color: CSC.POLE_MRK3, alpha: 1 },
    { x: 0, y: 0, z:  1,   system: 'celestial' },
    { x: 0, y: 0, z:  1.2, system: 'celestial' });
  mainScene.addLine('scpAxis',
    { thickness: 2, color: CSC.POLE_MRK3, alpha: 1 },
    { x: 0, y: 0, z: -1,   system: 'celestial' },
    { x: 0, y: 0, z: -1.2, system: 'celestial' });

  const tangentInst = new TangentPlaneInst();
  mainScene.addObject('tangentPlane',
    new PlacedObject(sphere, 'tangentPlane', tangentInst,
      { x: 0, y: 0, z: 0, system: 'horizon' }));

  mainScene.addObject('stickfigure',
    new PlacedObject(sphere, 'stickfigure', new StickfigureInst(),
      { x: 0, y: 0, z: 0, system: 'horizon' }));

  // Nested little-Earth sphere (projection only; drawn via GlobeSphereInst)
  globeSphere = new CelestialSphere();
  globeSphere.setSize(GLOBE_SPHERE_SIZE);
  globeSphere.setLatitude(90);
  globeSphere.setSiderealTime(0);
  globeSphere.setThetaAndPhi(INIT_THETA, INIT_PHI);

  globeScene = new Scene(globeSphere, { hpVisible: false });

  globeScene.addCircle('longitudeCircle',
    { thickness: 1.5, color: CSC.EARTH_4, alpha: 1 },
    { alt: 0, az: 0, tilt: 90, gammaStart: 90, gammaEnd: -90 });
  globeScene.addCircle('latitudeCircle',
    { thickness: 1.5, color: CSC.EARTH_4, alpha: 1 },
    { alt: 0, az: 0, tilt: 0 });

  globeScene.addObject('dot',
    new PlacedObject(globeSphere, 'dot', new ObserverDotInst(),
      { x: 0, y: 0, z: 0, system: 'horizon' }));

  globeComponent = new GlobeComponent(globeSphere, { shoreData: EARTH_SHORES });
  globeComponent.setPrecessionAngle(0);
  globeComponent.setRotationAngle(0);

  const globeArt = new GlobeArtInst(globeComponent);
  globeArt.setScale(100);
  globeScene.addObject('globe',
    new PlacedObject(globeSphere, 'globe', globeArt,
      { x: 0, y: 0, z: 0, system: 'horizon' }));

  const globeSphereInst = new GlobeSphereInst(globeScene, globeComponent);
  mainScene.addObject('globeSphere',
    new PlacedObject(sphere, 'globeSphere', globeSphereInst,
      { x: 0, y: 0, z: 0.001, system: 'horizon' }));

  changeLatitude();
}

function syncGlobeView() {
  globeSphere.setThetaAndPhi(mainScene.sphere.getTheta(), mainScene.sphere.getPhi());
  // Rebuild rotation matrix (sidereal time folded in) after view sync.
  globeComponent.setRotationAngle(globeComponent.rotationAngle);
}

/** Apply morph scales and tangent / stickfigure placement (archive updateCelestialDiagram). */
function applyMorphTransforms() {

  // Celestial sphere latitude in celestial sphere view (sphere upright)
  const latCS = 90;

  // Switch between view of celestial sphere and view of horizon plane
  const t     = globeSize;
  const scale = t * 100;
  if ( animating == 1 )  {
    mainScene.globeSphere.inst._xscale = scale;
    mainScene.globeSphere.inst._yscale = scale;
  }

  // Rotate horizon plane (and stick figure) between latitude and 90 degrees
  let altValue = latVal;
  let lat      = latCS;
  if ( animating == 2 )  {
    altValue = latVal + ( latCS - latVal ) * ( 1 - latFrac );
    lat      = latVal + ( latCS - latVal ) * (     latFrac );
  }

  // Preserve current orientations when not switching views
  if ( animating == 0 )  {
    if        ( direction == -1 )  {
      altValue = latCS; 
      lat      = latVal;
    } else if ( direction ==  1 )  {
      altValue = latVal; 
      lat      = latCS;
    }
  }

  // Update horizon plane
  const pt = {
    az: 180, alt: altValue,
    r: t * MAX_GLOBE_SIZE / mainScene.sphere.getSize()
  };
  mainScene.tangentPlane.setPosition(pt);
  mainScene.tangentPlane.setAbsoluteOrientation();

  // Update stick figure
  const pt2 = { az: pt.az, alt: pt.alt, r: pt.r + 0.001 };
  mainScene.stickfigure.setPosition(pt2);
  lookSouthStickfigure( altValue );
  mainScene.stickfigure.inst._xscale = 100 - scale;
  mainScene.stickfigure.inst._yscale = 100 - scale;

  // Update arcs for local horizon, meridian, and prime vertical
  if (altValue < 0) {
    mainScene.globeSphere.setPosition({ x: 0, y: 0, z: -0.001, system: 'horizon' });
    mainScene.meridianCircle1.setParameters(
      { alt: 0, az: 180, tilt:   90,       gammaStart: altValue - 90, gammaEnd: altValue + 90 });
    mainScene.meridianCircle2.setParameters(
      { alt: 0, az:  90, tilt: -altValue,       gammaStart: 180,      gammaEnd: 0        });
  } else {
    mainScene.globeSphere.setPosition({ x: 0, y: 0, z:  0.001, system: 'horizon' });
    mainScene.meridianCircle1.setParameters(
      { alt: 0, az: 180, tilt:   90,       gammaStart: altValue - 90, gammaEnd: altValue + 90 });
    mainScene.meridianCircle2.setParameters(
      { alt: 0, az:  90, tilt:  180 - altValue, gammaStart:   0,      gammaEnd: 180      });
  }
  mainScene.horizonCircle.setParameters({ alt: 0, az: 90, tilt: 90 - altValue });

  // Update celestial sphere
  if ( animating != 1 )  { 
    mainScene.sphere.setLatitude( lat );
  }
}

function lookSouthStickfigure( alt )  {
  // Orient stick figure to look south
  
  // Face south (tangent), stand on plane (up = radial), 
  // normal and radial both + 90 due to local coordinates for stickfigure image
  const normal = { az: 180, alt: alt + 90 };  // perpendicular to plane
  const radial = { az: 180, alt: alt      };  // facing direction (around plane)
  mainScene.stickfigure.setAbsoluteOrientation( normal, radial );

}

function updateCelestialDiagram() {
  if ( animating == 1 )  { 
    setTransitionFactor(globeSize);
  }
  applyMorphTransforms();
  requestRender();
}

function changeLatitude() {
  const lat = latVal;

  globeScene.latitudeCircle.setParameters({ alt: lat, az: 0, tilt: 0 });
  globeScene.dot.setPosition({ az: 180, alt: lat });
  globeScene.dot.setAbsoluteOrientation();
  globeScene.updateObjects();

  if (lat < 0) {
    mainScene.globeSphere.setPosition({ x: 0, y: 0, z: -0.001, system: 'horizon' });
    mainScene.meridianCircle1.setParameters(
      { alt: 0, az: 180, tilt:   90,       gammaStart: lat - 90, gammaEnd: lat + 90 });
    mainScene.meridianCircle2.setParameters(
      { alt: 0, az:  90, tilt: -lat,       gammaStart: 180,      gammaEnd: 0        });
  } else {
    mainScene.globeSphere.setPosition({ x: 0, y: 0, z:  0.001, system: 'horizon' });
    mainScene.meridianCircle1.setParameters(
      { alt: 0, az: 180, tilt:   90,       gammaStart: lat - 90, gammaEnd: lat + 90 });
    mainScene.meridianCircle2.setParameters(
      { alt: 0, az:  90, tilt:  180 - lat, gammaStart:   0,      gammaEnd: 180      });
  }

  mainScene.horizonCircle.setParameters({ alt: 0, az: 90, tilt: 90 - lat });
  updateCelestialDiagram();
}

/* ---- morph ---- */

function doTransition() {

  // If previous transition is pausing (between two transition phases), cancel it
  if (cancelActiveDelay) { cancelActiveDelay(); }

  // Switch between view of celestial sphere (direction = 1) and 
  // horizon plane (direction = -1)
  direction *= -1;

  // Collapse both transitions into single frame update to reduce motion
  if ( (prefersReducedMotion() ) || ( document.getElementById('chkRdcMotion').checked ) )  {
    // Shift between celestial sphere and horizon plane
    globeSize = (direction === 1) ? 1 : 0.001;
    animating = 1;
    updateCelestialDiagram();
  //announceMode(true);
    
    // Rotate horizon plane between latitude and 90 degrees
    animating = 2;
    setReferenceFrame();
    animating = 0;

    announceMode(true);
    
    return;
  }

  // Animate shift between celestial sphere and horizon plane, and rotation of
  // horizon plane, with stepwise transitions.
  shiftMode();

}

function resizeHorizonPlane()  {
  return new Promise((resolve) => {
    // If viewer flips direction of switch midstream,
    // spoof starting time to match current position in transition
    if ( animating == 1 )  {
      startTime = 2 * performance.now() - startTime - TRANSITION_TIME;
    } else  {
      startTime = performance.now();
      animating = 1;
    }
    currentTransitionResolve = resolve;
    requestAnimationFrame(onEnterFrameFunc);
  });
}

function shiftCelestialSphereLatitude()  {
  return new Promise((resolve) => {
    // If viewer flips direction of switch midstream,
    // spoof starting time to match current position in transition
    if ( animating == 2 )  {
      startTime = 2 * performance.now() - startTime - TRANSITION_TIME;
    } else  {
      startTime = performance.now();
      animating = 2;
    }
    currentTransitionResolve = resolve;
    requestAnimationFrame(onEnterFrameFunc);
  });
}

async function shiftMode()  {
  // Shift between celestial sphere and horizon plane, and rotate horizon
  // plane between latitude and horizontal, with pause in between
  
  const delta   = 1000;  // 1-second pause to let viewer absorb first change
  const myEpoch = ++transitionEpoch;
  
  // Disable latitude controls during transitions
  el.latSlider.disabled = true;
  el.latNumber.disabled = true;

  // Shift from celestial sphere to horizon plane view
  if        ( direction == -1 )  { 
    if ( ( latFrac == 1 ) && ( globeSize != 0.001 ) )  {
      await resizeHorizonPlane();
      if (myEpoch !== transitionEpoch) return;  // abort sequence if new transition underway
      if ( latVal != 90 )  { 
        await interruptibleDelay(delta);
        if (myEpoch !== transitionEpoch) return;
      }
    }
    if ( ( direction == -1 ) && ( latVal != 90 ) )  { 
      await shiftCelestialSphereLatitude();
      if (myEpoch !== transitionEpoch) return;
    }
      
  // Shift from horizon plane to celestial sphere view
  } else if ( direction ==  1 )  {
    if ( ( globeSize == 0.001 ) && ( latFrac != 1 ) )  {
      await shiftCelestialSphereLatitude();
      if (myEpoch !== transitionEpoch) return;
      if ( latVal != 90 )  { 
        await interruptibleDelay(delta);
        if (myEpoch !== transitionEpoch) return;
      }
    }
    if ( direction == 1 )  { 
      await resizeHorizonPlane();
    }
  }

  // The latest transition request completion triggers cleanup
  if ( myEpoch === transitionEpoch )  { 
    // Re-enable latitude controls 
    el.latSlider.disabled = false;
    el.latNumber.disabled = false;

    animating = 0;
    announceMode(true)
  }
}

// Add pause in between shifting between celestial sphere and horizon plane
// and rotating horizon plane, to let viewer absorb the change in orientation
const delay = (ms) => new Promise( (resolve) => setTimeout(resolve, ms) );

// Add interruptible pause as user can reverse transition during either
// transition phase or during the pause in between them.
function interruptibleDelay(ms) {
  return new Promise((resolve) => {
    const timer = setTimeout(() => {
      cancelActiveDelay = null;
      resolve();
    }, ms);
    cancelActiveDelay = () => {
      clearTimeout(timer);
      cancelActiveDelay = null;
      resolve();
    };
  });
}

function setReferenceFrame()  {
  // Set reference frame to be either celestial sphere (as viewed by user's
  // choice of theta and phi) or horizon plane (horizontal across screen)

  // Follow celestial sphere (default)
  const lat = latVal;
  if ( direction == 1 )  {
    mainScene.sphere.setLatitude( 90 );
    mainScene.horizonCircle.setParameters({ alt: 0, az: 90, tilt: 90 - lat });
    mainScene.meridianCircle1.setParameters(
      { alt: 0, az: 180, tilt:   90,       gammaStart: lat - 90, gammaEnd: lat + 90 });
    mainScene.meridianCircle2.setParameters(
      { alt: 0, az:  90, tilt:  180 - lat, gammaStart:        0, gammaEnd: 180      });

  // Follow horizon plane
  } else if ( direction == -1 )  {
    mainScene.sphere.setLatitude( lat );
    mainScene.horizonCircle.setParameters({ alt: 0, az: 0, tilt: 0 });
    mainScene.meridianCircle1.setParameters(
      { alt: 0, az: 180, tilt:  90, gammaStart: 0, gammaEnd: 180 });
    mainScene.meridianCircle2.setParameters(
      { alt: 0, az:  90, tilt:  90, gammaStart: 0, gammaEnd: 180 });
    
    const pt = {
      az: 180, alt: 0, tilt: 90, 
      r: 0.001
    };
    mainScene.tangentPlane.setPosition(pt);
    mainScene.tangentPlane.setAbsoluteOrientation();
  }
};

function onEnterFrameFunc() {
  if ( animating == 0 ) return;

  const now    = performance.now();
  let u        = (now - startTime) / TRANSITION_TIME;
  let finished = false;

  if ( 1 <= u )  { finished = true; } 
  
  const factor        = (direction === 1) ? u : (1 - u);
  const clampedFactor = Math.max (0.001, Math.min(1, factor) );

  if      (animating === 1) { globeSize = clampedFactor; }
  else if (animating === 2) { latFrac   = clampedFactor; }

  updateCelestialDiagram();

  if (!finished) {
    requestAnimationFrame(onEnterFrameFunc);
  } else {
    if (currentTransitionResolve) {
      const resolve = currentTransitionResolve;
      currentTransitionResolve = null;
      resolve();
    }
  }
}

function setTransitionFactor(arg) {
  // Style arrow pointing to new view
  
  const maxR       = (ARROW_MAX_COLOR >> 16) & 255;
  const maxG       = (ARROW_MAX_COLOR >>  8) & 255;
  const maxB       =  ARROW_MAX_COLOR        & 255;
  const minR       = (ARROW_MIN_COLOR >> 16) & 255;
  const minG       = (ARROW_MIN_COLOR >>  8) & 255;
  const minB       =  ARROW_MIN_COLOR        & 255;
  const halfRangeR = (maxR - minR) / 2;
  const halfRangeG = (maxG - minG) / 2;
  const halfRangeB = (maxB - minB) / 2;
  const halfPointR =  minR + halfRangeR;
  const halfPointG =  minG + halfRangeG;
  const halfPointB =  minB + halfRangeB;

  const u     = (arg - ARROW_HALF_POINT) / ARROW_HALF_RANGE;
  const left  = 'rgb(' + Math.round( u * halfRangeR + halfPointR) + ',' +
                         Math.round( u * halfRangeG + halfPointG) + ',' +
                         Math.round( u * halfRangeB + halfPointB) + ')';
  const right = 'rgb(' + Math.round(-u * halfRangeR + halfPointR) + ',' +
                         Math.round(-u * halfRangeG + halfPointG) + ',' +
                         Math.round(-u * halfRangeB + halfPointB) + ')';

  el.headLeft.setAttribute( 'fill', left);
  el.headRight.setAttribute('fill', right);
  el.barLeft.style.background   = 'linear-gradient(to right, ' + left + ', ' + right + ')';
  el.barRight.style.background  = 'linear-gradient(to right, ' + left + ', ' + right + ')';
  el.labelCelestial.style.color = left;
  el.labelHorizon.style.color   = right;

  const celestialActive = arg >= 0.5;
  el.labelCelestial.classList.toggle('is-active',  celestialActive);
  el.labelHorizon.classList.toggle(  'is-active', !celestialActive);
  el.labelCelestialState.textContent = celestialActive ? ' (view shown)' :     ' (view not shown)';
  el.labelHorizonState.textContent   = celestialActive ? ' (view not shown)' : ' (view shown)';

  /** Lengthening label leads to arrow/label overlap when screen width is 
      just wider than break point */
  /*
  if ( celestialActive )  {
    el.labelCelestial.innerHTML = 'celestial sphere';
    el.labelHorizon.innerHTML   = '(horizon diagram)';
  } else  {
    el.labelCelestial.innerHTML = '(celestial sphere)';
    el.labelHorizon.innerHTML   = 'horizon diagram';
  }
  */
}

/* ---- render ---- */

function requestRender() {
  if (document.hidden) {
    renderQueued = false;
    render();
    return;
  }
  if (renderQueued) return;
  renderQueued = true;
  requestAnimationFrame(() => {
    renderQueued = false;
    render();
  });
}

function render() {
  syncCanvasSize();
  ctx.setTransform(renderScale, 0, 0, renderScale, 0, 0);
  ctx.clearRect(0, 0, STAGE, STAGE);
  ctx.fillStyle = CSC.SKY_2;
  ctx.fillRect( 0, 0, STAGE, STAGE);
  ctx.translate(ORIGIN, ORIGIN);

  syncGlobeView();
  applyMorphTransforms();
  mainScene.refresh();
  // Frame (above/below art) needs projected sp.z from updateObjects.
  mainScene.tangentPlane.inst.update(
    globeSize,
    mainScene.sphere.getSize(),
    mainScene.tangentPlane.sp.z
  );

  mainScene.render(ctx);
  updateDescriptions();
}

/* ---- a11y narration ---- */

function latitudeSpoken(v) {
  const txt = 'latitude ' + speak( v, LAT_PRECISION, 'degree' );
  
  if (v > 0) { return txt + ' (north of equator)'; }
  if (v < 0) { return txt + ' (south of equator)'; }
               return txt + ' (on the equator)';
}

function modeName() {
  if (globeSize >= 0.999) return 'celestial sphere';
  if (globeSize <= 0.002) return 'horizon diagram';
  return (direction === 1) ? 'changing to the celestial sphere'
                           : 'changing to the horizon diagram';
}

function announce(text) {
  announceLive(el.live, text);
}

function announceMode(atEnd) {
  if (atEnd) {
    announce('Now showing the ' + modeName() + ' for an observer at ' +
             latitudeSpoken(latVal) + '.');
  }
}

function updateDescriptions() {
  const az   = mainScene.sphere.getViewerAzimuth();
  const alt  = mainScene.sphere.getPhi();
  const view = 'View direction: azimuth '  + speak(  az, 0, 'degree' ) +
                             ', altitude ' + speak( alt, 0, 'degree' ) + '.';

  // Note A-D-W-S alternate keyboard controls for MacOS+Voiceover users
  // running screen reader and using keyboard controls (VO_FIX_LGND).
  el.canvas.setAttribute('aria-label',
    'Celestial sphere diagram, currently showing the ' + modeName() + '. ' + view +
    ' Drag, or use the arrow keys, to rotate the view. ' + VO_FIX_LGND);
  
  el.stageDesc.textContent =
    'The diagram shows the ' + modeName() + ' for an observer at ' + latitudeSpoken(latVal) + '. ' +
    'The Earth globe sits at the center of the celestial sphere, with a small green observer ' +
    'horizon plane defined by grey latitude and longitude circles. '                           +
    'Yellow arcs denote the celestial equator and the zero hour right ascension arc; '         +
    'white circles show the observer\'s local horizon, meridian, and prime vertical; '         +
    'blue line segments at the poles mark the rotation axis of the celestial sphere. '         +
    'As the view changes to the horizon diagram, the globe shrinks in size and the green '     +
    'horizon plane, marked with north, south, east and west labels, grows to fill the sphere ' +
    'with an observer positioned at its center. ' + view;
}

window.klunlInitEqn = klunlInitEqn;

/* ---- latitude controls ---- */

function setLatitude(raw, announceIt) {
  const v = sliderSetValue(raw);
  if (v === latVal) {
    syncLatitudeControls();
    return;
  }
  latValOld = latVal;
  latVal    = v;
  changeLatitude();
  syncLatitudeControls();

  // Announce new latitude value, and place NCP/SCP in sky
  let s0;
  if (announceIt)  { 
    s0 = 'Observer\'s ' + latitudeSpoken(latVal) + '.';
    if        ( latVal ==  90 )  {
      s0 += ' North Celestial Pole directly overhead for observer, and celestial equator on horizon.';
    } else if ( ( latVal >=  80 ) && ( latValOld <  80 ) )  {
      s0 += ' North Celestial Pole almost directly overhead for observer.';
    } else if ( ( latVal >   10 ) && ( ( latValOld <   10 ) || ( latValOld >=  80 ) ) )  {
      s0 += ' North Celestial Pole well above horizon.';
    } else if ( ( latVal    <=  10 ) && ( latVal    >   0 ) &&
              ( ( latValOld <=   0 ) || ( latValOld >  10 ) ) )  {
      s0 += ' North Celestial Pole on observer\'s northern horizon.';
    } else if ( latVal == 0 )  { 
      s0 += ' North and South Celestial Poles on observer\'s northern and southern horizons, and celestial equator overhead.';
    } else if ( latVal == -90 )  {
      s0 += ' South Celestial Pole directly overhead for observer, and celestial equator on horizon.';
    } else if ( ( latVal <= -80 ) && ( latValOld > -80 ) )  {
      s0 += ' South Celestial Pole almost directly overhead for observer.';
    } else if ( ( latVal <  -10 ) && ( ( latValOld >= -10 ) || ( latValOld <= -80 ) ) )  {
      s0 += ' South Celestial Pole well above horizon.';
    } else if ( ( latVal    >= -10 ) && ( latVal    <   0 ) &&
              ( ( latValOld >=   0 ) || ( latValOld < -10 ) ) )  {
      s0 += ' South Celestial Pole on observer\'s southern horizon.';
    }
    announce( s0 );
  }
  
  setReferenceFrame();
}

function syncLatitudeControls() {
  const txt = legToFixed(latVal, LAT_PRECISION);
  if (document.activeElement !== el.latNumber) el.latNumber.value = txt;
  el.latSlider.value = String(latVal);
  updateSliderProgress(el.latSlider);
  
  const spoken = 'Observer\'s ' + latitudeSpoken(latVal);
  el.latSlider.setAttribute('aria-valuetext', spoken);
  el.latNumber.setAttribute('aria-label',     spoken);
}

/* ---- pointer / keyboard drag ---- */

function stageCoords(e) {
  const rect = el.canvas.getBoundingClientRect();
  const sx   = STAGE / rect.width;
  const sy   = STAGE / rect.height;
  return {
    x: (e.clientX - rect.left) * sx - ORIGIN,
    y: (e.clientY - rect.top)  * sy - ORIGIN
  };
}

function hitTest(mx, my) {
  const r = mainScene.sphere.c.r;
  return Math.sqrt(mx * mx + my * my) <= r;
}

function startSimpleDragging(mx, my) {
  const S   = mainScene.sphere;
  dragX     = mx;
  dragY     = my;
  dragTheta = S.theta;
  dragPhi   = S.phi;
}

function updateSimpleDragging(mx, my) {
  const S = mainScene.sphere;
  S.setThetaAndPhi(
    R2D * (dragTheta - (mx - dragX) / S.c.r),
    R2D * (dragPhi   + (my - dragY) / S.c.r)
  );
  syncGlobeView();
}

function onPointerDown(e) {
  const p = stageCoords(e);
  if (!hitTest(p.x, p.y)) return;
  el.canvas.focus();
  dragging      = true;
  dragPointerId = e.pointerId;
  el.canvas.setPointerCapture(e.pointerId);
  startSimpleDragging(p.x, p.y);
  e.preventDefault();
}

function onPointerMove(e) {
  if (!dragging || e.pointerId !== dragPointerId) return;
  const p = stageCoords(e);
  updateSimpleDragging(p.x, p.y);
  requestRender();
  e.preventDefault();
}

function onPointerUp(e) {
  if (!dragging || e.pointerId !== dragPointerId) return;
  dragging      = false;
  dragPointerId = null;
  try { el.canvas.releasePointerCapture(e.pointerId); } catch (_err) { /* already released */ }
  announceView();
}

function announceView() {
  const az  = mainScene.sphere.getViewerAzimuth();
  const alt = mainScene.sphere.getPhi();
  announce('View rotated to azimuth '  + speak( az, 0, 'degree') +
                         ', altitude ' + speak(alt, 0, 'degree') + '.');
}

function rotateView(dTheta, dPhi) {
  const S = mainScene.sphere;
  S.setThetaAndPhi(S.getTheta() + dTheta, S.getPhi() + dPhi);
  syncGlobeView();
  requestRender();
  announceView();
}

function onStageKeyDown(e) {
  const step    = keyAccel(e, 2);
  const bigStep = 15;
  const S       = mainScene.sphere;
  switch (e.key) {
  case 'ArrowLeft':  rotateView( step,    0); break;
  case 'ArrowRight': rotateView(-step,    0); break;
  case 'ArrowUp':    rotateView(0,    -step); break;
  case 'ArrowDown':  rotateView(0,     step); break;
  case 'PageUp':     rotateView(0, -bigStep); break;
  case 'PageDown':   rotateView(0,  bigStep); break;
  case 'Home':
    S.setThetaAndPhi(180, 2);  // Face-on figure, horizon tilted 2 deg for visibility
    syncGlobeView();
    requestRender();
    announceView();
    break;
  case 'End':
    S.setThetaAndPhi(92, 2);  // Edge-on figure, horizon tilted 2 deg for visibility
    syncGlobeView();
    requestRender();
    announceView();
    break;
  // MacOS+Voiceover users need an alternative to arrow keys
  case 'a': rotateView( step,  0); break; case 'A': rotateView( step,   0); break; 
  case 'd': rotateView(-step,  0); break; case 'D': rotateView(-step,   0); break; 
  case 'w': rotateView( 0, -step); break; case 'W': rotateView(  0, -step); break; 
  case 's': rotateView( 0,  step); break; case 'S': rotateView(  0,  step); break; 
  default:
    return;
  }
  e.preventDefault();
}

/* ---- reset ---- */

function resetSim() {
  direction = 1;
  globeSize = 1;
  latFrac   = 1;
  animating = 0;
  latVal    = INIT_LATITUDE;
  mainScene.sphere.setThetaAndPhi(INIT_THETA, INIT_PHI);
  globeSphere.setThetaAndPhi(     INIT_THETA, INIT_PHI);
  globeComponent.setRotationAngle(0);
  mainScene.globeSphere.inst._xscale = 100;
  mainScene.globeSphere.inst._yscale = 100;
  changeLatitude();
  syncLatitudeControls();
  setTransitionFactor(1);
  announce('Simulation reset. Showing the celestial sphere for an observer at ' +
           latitudeSpoken(latVal) + '. View direction restored.');
}

/* ---- boot ---- */

function cacheElements() {
  ['stage', 'stageDesc', 'switchBtn', 'latNumber', 'latSlider', 
   'labelCelestial', 'labelHorizon', 'labelCelestialState', 'labelHorizonState',
   'headLeft', 'headRight', 'barLeft', 'barRight'].forEach((id) => {
    el[id]  = document.getElementById(id);
  });
  el.canvas = el.stage;
  el.live   = document.getElementById('sr-status');
}

function syncCanvasSize() {
  dpr             = window.devicePixelRatio || 1;
  const cssWidth  = canvas.getBoundingClientRect().width || STAGE;
  const backing   = Math.max(1, Math.round(cssWidth * dpr));
  renderScale     = backing / STAGE;
  if (canvas.width !== backing || canvas.height !== backing) {
    canvas.width  = backing;
    canvas.height = backing;
  }
}

function sizeCanvas() { requestRender(); }

function boot() {
  cacheElements();
  canvas = el.canvas;
  ctx    = canvas.getContext('2d');

  direction = 1;
  globeSize = 1;
  latFrac   = 1;
  animating = 0;
  latVal    = INIT_LATITUDE;

  initSphere();
  sizeCanvas();
  syncLatitudeControls();
  setTransitionFactor(1);

  el.switchBtn.addEventListener('click', doTransition);

  el.latSlider.addEventListener('input', () => {
    setLatitude(el.latSlider.value, false);
  });
  el.latSlider.addEventListener('change', () => {
    setLatitude(el.latSlider.value, true);
  });

  /*
  // Let user enter multi-digit number without updating latitude with each digit
  // (entering "65" should not update for both "6" and "65", for example)
  el.latNumber.addEventListener('input', () => {
    if (el.latNumber.value === '' || el.latNumber.value === '-') return;
    setLatitude(el.latNumber.value, false);
  });
  */
  el.latNumber.addEventListener('change', () => {
    setLatitude(el.latNumber.value, true);
    el.latNumber.value = legToFixed(latVal, LAT_PRECISION);
  });
  el.latNumber.addEventListener('blur', () => {
    el.latNumber.value = legToFixed(latVal, LAT_PRECISION);
  });
  el.latNumber.addEventListener('keydown', noEinNumber);
  el.latNumber.addEventListener('wheel', (e) => {
    if (document.activeElement !== el.latNumber) return;
    e.preventDefault();
    setLatitude(latVal + (e.deltaY < 0 ? LAT_INCREMENT : -LAT_INCREMENT), true);
    el.latNumber.value = legToFixed(latVal, LAT_PRECISION);
  }, { passive: false });
  el.latNumber.addEventListener('keydown', (e) => {
    const big = 1;
    if      (e.key === 'PageUp')   setLatitude(latVal + big, true);
    else if (e.key === 'PageDown') setLatitude(latVal - big, true);
    else if (e.key === 'Home')     setLatitude(LAT_MIN,      true);
    else if (e.key === 'End')      setLatitude(LAT_MAX,      true);
    else return;
    el.latNumber.value = legToFixed(latVal, LAT_PRECISION);
    e.preventDefault();
  });

  canvas.addEventListener('pointerdown',   onPointerDown);
  canvas.addEventListener('pointermove',   onPointerMove);
  canvas.addEventListener('pointerup',     onPointerUp);
  canvas.addEventListener('pointercancel', onPointerUp);
  canvas.addEventListener('keydown',       onStageKeyDown);

  document.addEventListener('sim-reset', resetSim);
  window.addEventListener('resize', sizeCanvas);
  if (window.ResizeObserver) {
    new ResizeObserver(sizeCanvas).observe(canvas);
  }

  requestRender();
}

loadArt().then(() => {
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', boot);
  } else {
    boot();
  }
});
