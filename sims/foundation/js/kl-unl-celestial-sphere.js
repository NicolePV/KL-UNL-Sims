/* ===========================================================================
   KL-UNL Celestial Sphere (`kl-unl-celestial-sphere.js`)
   ---------------------------------------------------------------------------
   Shared mathematical and projection engine for celestial sphere.

   New constants include the celestial sphere colors blocks, containing 
   default colors that can be overwritten within individual simulations.

   New functionality includes optional hatching of interiors of great circles 
   (not included in legacy code base).

   Matrices on scratch object `c`:
     a0..a8  — world (horizon) → screen projection (scaled by sphere radius r)
     m0..m8  — celestial → world (observer latitude + local sidereal time)
     b0..b8  — celestial → screen (a · m composite)

   Angle conventions:
     RA is in hours when passed to parse / setParameters; stored internally
     in radians.
   =========================================================================== */

import { pMod, hexToRGBA } from './kl-unl-utils.js';

/** Geometric constants */
export const D2R =  0.017453292519943295;   /** Degrees → radians (π/180)      */
export const R2D = 57.29577951308232;       /** Radians → degrees (180/π)      */
export const H2R =  0.2617993877991494;     /** Hours   → radians (15° = π/12) */
export const R2H =  3.819718634205488;      /** Radians → hours                */

/** Conversion factors  */
export const RA_H    = 0.06575342465753424; /** RA   (hours) from DOY =  24/365 */
export const DEC_D   = 0.01721420632103996; /** Dec. (deg.)  from DOY = 2PI/365 */
export const TME_H   = 1.0027397260273974;  /** Time (hours) from DOY = 366/365 */

/** Factors of PI       */
export const TWO_PI  = 6.283185307179586;   /** 2π   */
export const PI      = 3.141592653589793;   /**  π   */
export const HALF_PI = 1.5707963267948966;  /**  π/2 */
export const QURT_PI = 0.7853981633974483;  /**  π/4 */
export const SXTH_PI = 0.5235987755982988;  /**  π/6 */

/** Default celestial sphere colors in hex */
export const CELESTIAL_SPHERE_COLORS = {
  // Arcs
  AZ_ARC:     '#5645f5',  // (slate   blue)
  AZ_ARC_BCK: '#ffffff',  // (white)
  ALT_ARC:    '#a63743',  // (brick   red)
  AZ_CIRC:    '#a0a0a0',  // (medium  grey)
  ALT_CIRC:   '#a0a0a0',  // (medium  grey)
  RA_ARC:     '#4b4bfe',  // (bright  blue)
  DEC_ARC:    '#fe4b4b',  // (bright  red)
  RA_CIRC:    '#a0a0a0',  // (medium  grey)
  DEC_CIRC:   '#a0a0a0',  // (medium  grey)
  MRDN_CIRC:  '#216331',  // (dark    green)
  MRDN2_CIRC: '#000000',  // (black)
  MRDN3_CIRC: '#c0c0c0',  // (light   grey)
  CEL_EQUTR:  '#505050',  // (dark    gray)
  SUN_PATH:   '#ffffc0',  // (pale    yellow)
  
  // Line segments
  POLE_LNSG:  '#505050',  // (dark    grey)

  // Celestial sphere
  CSPHERE_1:  '#e6e9ec',  // (pale    greyish blue)
  CSPHERE_2:  '#d0d4d9',  // (light   greyish blue)
  CSPHERE_3:  '#787e86',  // (muted   greyish blue)
  CSPHERE_4:  '#787878',  // (medium  grey)

  // Ecliptic 
  ECLPTC_1:   '#9931DF',  // (violet)
  ECLPTC_2:   '#9408c7',  // (violet)
  ECLPTC_3:   '#ff5050',  // (bright  red)

  // Horizon plane
  HOR_ABV_1:  '#46b446',  // (vibrant green)
  HOR_ABV_2:  '#3da53d',  // (medium  green)
  HOR_ABV_3:  '#2f8a2f',  // (forest  green)
  HOR_BLW_1:  '#0a7a14',  // (deep    green)
  HOR_BLW_2:  '#005000',  // (dark    green)

  // Earth
  EARTH_1:    '#bcd2f5',  // (light   blue)
  EARTH_2:    '#5b86d6',  // (medium  blue)
  EARTH_3:    '#3f8f4a',  // (medium  green)

  // Sky
  SKY_1:      '#84cbff',  // (light   blue)
  SKY_2:      '#000000',  // (black)

  // North and south pole base markers
  POLE_MRK1:  '#222222',  // (dark    grey)
  POLE_MRK2:  '#ffffff',  // (white)

  // General labels (zenith, nadir, horizon, meridian)
  LABEL_LNSG: '#1f1f1f',  // (charcoal grey)
  LABEL_FILL: '#1a1a1a',  // (dark     grey)
  LABEL_HALO: '#ffffff',  // (white)

  // Star position labels
  AZ_LABEL:   '#4a4080',  // (dark    blue)
  ALT_LABEL:  '#9a2230',  // (scarlet sage)
  RA_LABEL:   '#4b4bfe',  // (bright  blue)
  DEC_LABEL:  '#fe4b4b',  // (bright  red)

  // Cardinal direction labels
  NESW_LINE:  '#1a1a1a',  // (dark    grey)
  NESW_FILL:  '#ffffff'   // (white)
};

/** Default sphere radius in screen units */
export const DEFAULT_SPHERE_RADIUS = 150;

/**
 * Sort projected render objects back-to-front by depth (`z`).
 * Higher `z` is closer to viewer (projected out of screen).
 *
 * @param   {Array<{z?: number, sp?: {z?: number}}>} items - Objects with `z` or `sp.z`.
 * @returns {Array} New array sorted ascending by depth (back first).
 */
export function sortByDepth(items) {
  return items.slice().sort((a, b) => {
    const za = (a.sp && a.sp.z !== undefined) ? a.sp.z : (a.z || 0);
    const zb = (b.sp && b.sp.z !== undefined) ? b.sp.z : (b.z || 0);
    return za - zb;
  });
}

/**
 * Celestial sphere projection engine.
 *
 * Owns viewer orientation (theta/phi), observer latitude, local sidereal time,
 * and the a/m/b projection matrices used by Circle and Line helpers.
 */
export class CelestialSphere {
  /**
   * @param {number} [radius=DEFAULT_SPHERE_RADIUS] - Sphere radius in screen units
   *   (half of Flash `sphereMC.size`). Pass 160 for size 320, or 30 for the
   *   nested Earth globe in the RA/Dec demonstrator.
   */
  constructor(radius) {
    /** @type {{r: number, r2: number, [key: string]: number}} Matrix scratchpad (AS `_c`). */
    this.c      =  {};
    this.aVer   =  -1;
    this.bVer   =  -1;
    this.maxPhi =  90;
    this.minPhi = -90;
    const r     = (radius !== undefined && radius !== null) ? radius : DEFAULT_SPHERE_RADIUS;
    this.c.r    = r;
    this.c.r2   = r * r;
    /** @type {boolean} When true, draw under-horizon / back-hemisphere segments. */
    this.showUnder = true;
    /** @type {number} Viewer azimuth rotation (radians). */
    this.theta = 0;
    /** @type {number} Viewer altitude / tilt (radians). */
    this.phi = SXTH_PI ;
    /** @type {number} Observer geographic latitude (radians). */
    this.lat = 0;
    /** @type {number} Local sidereal time (radians). */
    this.sTime = 0;

    this.setThetaAndPhi(90, 30);
    this.setLatitude(41);
    this.setSiderealTime(0);
  }

  /**
   * @returns {number} Viewer theta in degrees [0, 360).
   */
  getTheta() { return R2D * this.theta; }

  /**
   * @returns {number} Viewer phi (altitude) in degrees.
   */
  getPhi() { return R2D * this.phi; }

  /**
   * Viewer azimuth as used by Hour Angle Demo (`360 - theta`).
   * @returns {number} Degrees [0, 360).
   */
  getViewerAzimuth() { return mod(360 - this.getTheta(), 360); }

  /**
   * @returns {number} Observer latitude in degrees.
   */
  getLatitude() { return R2D * this.lat; }

  /**
   * @returns {number} Local sidereal time in hours [0, 24).
   */
  getSiderealTime() { return this.sTime * R2H; }

  /**
   * Set sphere diameter in screen units (Flash `sphereMC.size`).
   * Radius becomes `arg / 2`.
   * @param {number} arg - Diameter (e.g. 320 → r = 160).
   */
  setSize(arg) {
    this.c.r  = arg / 2;
    this.c.r2 = this.c.r * this.c.r;
    this.doA();
    this.doB();
  }

  /**
   * @param {number} v - Minimum viewer altitude (degrees). Invalid → 90.
   */
  setMinPhi(v) { this.minPhi = (v > 90 || v < -90) ? 90 : v; }

  /**
   * @param {number} v - Maximum viewer altitude (degrees). Invalid → 90.
   */
  setMaxPhi(v) { this.maxPhi = (v > 90 || v < -90) ? 90 : v; }

  /**
   * Set viewer orientation.
   * @param {number} newTheta - Viewer azimuth rotation (degrees).
   * @param {number} newPhi   - Viewer altitude / tilt (degrees), clamped to min/maxPhi.
   */
  setThetaAndPhi(newTheta, newPhi) {
    this.theta = D2R * pMod(newTheta, 360);
    let p      = newPhi;
    if      (p > this.maxPhi) p = this.maxPhi;
    else if (p < this.minPhi) p = this.minPhi;
    this.phi   = p * D2R;
    this.doA();
    this.doB();
  }

  /**
   * @param {number} arg - Viewer theta in degrees.
   */
  setTheta(arg) {
    this.theta = D2R * pMod(arg, 360);
    this.doA();
    this.doB();
  }

  /**
   * @param {number} az - Viewer azimuth in degrees (Hour Angle Demo convention).
   */
  setViewerAzimuth(az) { this.setTheta(360 - az); }

  /**
   * @param {number} arg - Observer latitude in degrees [-90, 90].
   */
  setLatitude(arg) {
    let v    = arg;
    if      (v >  90) v =  90;
    else if (v < -90) v = -90;
    this.lat = v * D2R;
    this.doM();
    this.doB();
  }

  /**
   * @param {number} arg - Local sidereal time in hours [0, 24).
   */
  setSiderealTime(arg) {
    this.sTime = pMod(arg, 24) * H2R;
    this.doM(); this.doB();
  }

  /**
   * Build world→screen matrix `a*` from theta, phi, and radius.
   * Increments `aVer` for cache invalidation.
   */
  doA() {
    const c  = this.c;
    const ct = Math.cos(this.theta), st = Math.sin(this.theta);
    const cp = Math.cos(this.phi),   sp = Math.sin(this.phi);
    c.a0 = -c.r * st;
    c.a1 =  c.r * ct;
    c.a3 =  c.r * ct * sp;
    c.a4 =  c.r * st * sp;
    c.a5 = -c.r * cp;
    c.a6 =  c.r * ct * cp;
    c.a7 =  c.r * st * cp;
    c.a8 =  c.r * sp;
    this.aVer++;
  }

  /**
   * Build celestial→world matrix `m*` from latitude and sidereal time.
   */
  doM() {
    const c = this.c;
    c.m2 =  Math.cos(this.lat);
    c.m3 =  Math.sin(this.sTime);
    c.m4 = -Math.cos(this.sTime);
    c.m8 =  Math.sin(this.lat);
    c.m0 =  c.m4 * c.m8;
    c.m1 = -c.m3 * c.m8;
    c.m6 = -c.m2 * c.m4;
    c.m7 =  c.m2 * c.m3;
  }

  /**
   * Build celestial→screen matrix `b*` = a · m.
   * Increments `bVer` for cache invalidation.
   */
  doB() {
    const c = this.c;
    c.b0 = c.a0 * c.m0 + c.a1 * c.m3;
    c.b1 = c.a0 * c.m1 + c.a1 * c.m4;
    c.b2 = c.a0 * c.m2;
    c.b3 = c.a3 * c.m0 + c.a4 * c.m3 + c.a5 * c.m6;
    c.b4 = c.a3 * c.m1 + c.a4 * c.m4 + c.a5 * c.m7;
    c.b5 = c.a3 * c.m2 + c.a5 * c.m8;
    c.b6 = c.a6 * c.m0 + c.a7 * c.m3 + c.a8 * c.m6;
    c.b7 = c.a6 * c.m1 + c.a7 * c.m4 + c.a8 * c.m7;
    c.b8 = c.a6 * c.m2 + c.a8 * c.m8;
    this.bVer++;
  }

  /**
   * Parse a point specification into Cartesian coordinates plus system tag.
   *
   * Accepts horizon `{az, alt, r?}`, celestial `{ra, dec, r?}` (RA in hours),
   * or Cartesian `{x, y, z, system?}`.
   *
   * @param {object} inP - Input point.
   * @param {object} out - Mutated result: `sys` (0 horizon / 1 celestial / -1 unknown),
   *   `system`, `x`, `y`, `z`, `r`.
   */
  parsePointInput(inP, out) {
    if (inP.az !== undefined && inP.alt !== undefined) {
      out.sys = 0; out.system = 'horizon';
      const r = (inP.r !== undefined) ? inP.r : 1;
      const d = r * Math.cos( inP.alt * D2R);
      out.x   = d * Math.cos( inP.az  * D2R);
      out.y   = d * Math.sin(-inP.az  * D2R);
      out.z   = r * Math.sin( inP.alt * D2R);
      out.r   = Math.abs(r);
    } else if (inP.ra !== undefined && inP.dec !== undefined) {
      out.sys = 1; out.system = 'celestial';
      const r = (inP.r !== undefined) ? inP.r : 1;
      const d = r * Math.cos(inP.dec * D2R);
      out.x   = d * Math.cos(inP.ra  * H2R);
      out.y   = d * Math.sin(inP.ra  * H2R);
      out.z   = r * Math.sin(inP.dec * D2R);
      out.r   = Math.abs(r);
    } else if (inP.x !== undefined && inP.y !== undefined && inP.z !== undefined) {
      if      (inP.system === 'horizon')   { out.sys = 0; out.system = 'horizon';   }
      else if (inP.system === 'celestial') { out.sys = 1; out.system = 'celestial'; }
      else { out.sys = -1; out.system = 'unknown'; }
      out.x = inP.x;
      out.y = inP.y;
      out.z = inP.z;
      out.r = Math.sqrt(inP.x * inP.x + inP.y * inP.y + inP.z * inP.z);
      if (out.r < 1.000001 && out.r > 0.999999) out.r = 1;
    } else {
      out.sys    = null;
      out.system = null;
      out.x      = null;
      out.y      = null;
      out.z      = null;
      out.r      = null;
    }
  }

  /**
   * Parse and return a new point object (CelEq-style convenience).
   * @param {object} a - Same input forms as {@link parsePointInput}.
   * @returns {object} Parsed point.
   */
  parse(a) {
    const out = {};
    this.parsePointInput(a, out);
    return out;
  }

  /**
   * World (horizon) Cartesian → screen with depth.
   * @param {{x:number,y:number,z:number}} p - World point.
   * @param {{x?:number,y?:number,z?:number}} sp - Output screen point (`z` = depth).
   */
  WtoSz(p, sp) {
    const c = this.c;
    sp.x = p.x * c.a0 + p.y * c.a1;
    sp.y = p.x * c.a3 + p.y * c.a4 + p.z * c.a5;
    sp.z = p.x * c.a6 + p.y * c.a7 + p.z * c.a8;
  }

  /**
   * Celestial Cartesian → screen with depth.
   * @param {{x:number,y:number,z:number}} p - Celestial point.
   * @param {{x?:number,y?:number,z?:number}} sp - Output screen point.
   */
  CtoSz(p, sp) {
    const c = this.c;
    sp.x = p.x * c.b0 + p.y * c.b1 + p.z * c.b2;
    sp.y = p.x * c.b3 + p.y * c.b4 + p.z * c.b5;
    sp.z = p.x * c.b6 + p.y * c.b7 + p.z * c.b8;
  }

  /**
   * Celestial Cartesian → world (horizon) Cartesian.
   * @param {{x:number,y:number,z:number}} p - Celestial point.
   * @param {{x?:number,y?:number,z?:number}} wp - Output world point.
   */
  CtoW(p, wp) {
    const c = this.c;
    wp.x = p.x * c.m0 + p.y * c.m1 + p.z * c.m2;
    wp.y = p.x * c.m3 + p.y * c.m4;
    wp.z = p.x * c.m6 + p.y * c.m7 + p.z * c.m8;
  }

  /**
   * World (horizon) Cartesian → celestial Cartesian.
   * @param {{x:number,y:number,z:number}} p - World point.
   * @param {{x?:number,y?:number,z?:number}} cp - Output celestial point.
   */
  WtoC(p, cp) {
    const c = this.c;
    cp.x = p.x * c.m0 + p.y * c.m3 + p.z * c.m6;
    cp.y = p.x * c.m1 + p.y * c.m4 + p.z * c.m7;
    cp.z = p.x * c.m2 + p.z * c.m8;
  }

  /**
   * Celestial spherical (radians) → mounted-horizon spherical (radians).
   * @param {{ra:number,dec:number}} cp - Right ascension & declination (radians).
   * @param {{az?:number,alt?:number}} hp - Output azimuth & altitude (radians).
   */
  CtoMH(cp, hp) {
    const sd = Math.sin(cp.dec),   cd = Math.cos(cp.dec);
    const sl = Math.sin(this.lat), cl = Math.cos(this.lat);
    const h  = this.sTime - cp.ra, ch = Math.cos(h);
    const caz = sd * cl - cd * ch * sl, saz = cd * Math.sin(h);
    hp.az  = (caz === 0) ? 0 : pMod(Math.atan2(saz, caz), TWO_PI);
    hp.alt = Math.asin(sd * sl + cd * ch * cl);
  }

  /**
   * Mounted-horizon spherical (radians) → celestial spherical (radians).
   * @param {{az:number,alt:number}} hp - Azimuth & altitude (radians).
   * @param {{ra?:number,dec?:number}} cp - Output RA & Dec (radians).
   */
  MHtoC(hp, cp) {
    const salt = Math.sin(hp.alt),   calt = Math.cos(hp.alt);
    const saz  = Math.sin(hp.az),    caz  = Math.cos(hp.az);
    const sl   = Math.sin(this.lat), cl   = Math.cos(this.lat);
    const sh   = calt * saz, ch = salt * cl - calt * sl * caz;
    cp.ra = (ch === 0) ? 0 : pMod(this.sTime - Math.atan2(sh, ch), TWO_PI);
    cp.dec = Math.asin(salt * sl + calt * caz * cl);
  }

  /**
   * Screen (sphere-centered pixels) → mounted-horizon spherical (radians).
   * Used by view and star drag (AS `StoMH`).
   * @param {{x:number,y:number}} sp - Screen point relative to sphere center.
   * @param {{az?:number,alt?:number}} hp - Output azimuth & altitude (radians).
   */
  StoMH(sp, hp) {
    const r = this.c.r;
    let d = Math.sqrt(sp.x * sp.x + sp.y * sp.y) / r;
    if (d > 1) d = 1;
    const b = Math.asin(d);
    const A = Math.atan2(sp.x, -sp.y);
    if (this.phi === HALF_PI) {
      hp.alt = HALF_PI - b;
      hp.az  = this.theta + PI - A;
    } else if (this.phi === -HALF_PI) {
      hp.alt = -HALF_PI + b;
      hp.az  = this.theta + A;
    } else {
      const cc   = HALF_PI - this.phi;
      const ccos = Math.cos(cc), csin = Math.sin(cc);
      const cb   = Math.cos(b), sb = Math.sin(b);
      const ca   = cb * ccos + sb * csin * Math.cos(A);
      hp.alt     = HALF_PI - Math.acos(ca);
      hp.az      = this.theta + Math.atan2(sb * Math.sin(A), (cb - ca * ccos) / csin);
    }
    hp.az = pMod(hp.az, TWO_PI);
  }

  /**
   * Screen pixels (sphere-centered) → RA/Dec for star dragging.
   * @param {number} x - Screen x relative to center.
   * @param {number} y - Screen y relative to center.
   * @returns {{ra: number, dec: number}|null} RA in hours, Dec in degrees, or null if outside sphere.
   */
  screenToRaDec(x, y) {
    if (Math.sqrt(x * x + y * y) > this.c.r) return null;
    const hp = {}, cp = {};
    this.StoMH({ x: x, y: y }, hp);
    this.MHtoC(hp, cp);
    return { ra: cp.ra * R2H, dec: cp.dec * R2D };
  }
}

/**
 * Great/small circle or arc on the sphere (AS `8 CS Circles.as`).
 *
 * Supports horizon (`az`/`alt`/`tilt`) and celestial (`ra`/`dec`/`tilt`) systems.
 * After {@link Circle#update}, `front` and `back` hold path objects
 * `{ move: [x,y], curves: [[cx,cy,ax,ay], ...] }` for canvas stroking.
 */
export class Circle {
  /**
   * @param {CelestialSphere} sphere - Parent projection engine.
   * @param {{thickness?: number, color?: number, alpha?: number}} [style] - Stroke style.
   * @param {object} [def] - Optional initial {@link Circle#setParameters} argument.
   */
  constructor(sphere, style, def) {
    this.sphere = sphere;
    /** @type {object} Local w-matrix scratchpad. */
    this.c      = {};
    this.wVer   = -1;
    this.gS     =  0;
    this.gE     =  0;
    this.beta   =  0;
    this.tilt   =  0;
    this.lambda =  0;
    /** @type {number} 0 = horizon, 1 = celestial. */
    this.sys     = 0;
    this.visible = true;
    this.color   = "#ffffff"; this.thick = 1; this.alpha = 0.8;
    this.minStep = QURT_PI;
    /** @type {Array<{move:number[], curves:number[][]}>} */
    this.front = [];
    /** @type {Array<{move:number[], curves:number[][]}>} */
    this.back  = [];
    /** @type {object|null} Hatch fill config; null = disabled. */
    this.hatch = null;
    /** @type {Array<{move:number[], line:number[]}>} */
    this.hatchFront = [];
    /** @type {Array<{move:number[], line:number[]}>} */
    this.hatchBack  = [];
    if (style) {
      this.setStyle(style.thickness, style.color, style.alpha);
      if (style.hatch) this.setHatch(style.hatch);
    }
    if (def) {
      this.setParameters(def);
      if (def.hatch) this.setHatch(def.hatch);
    }
  }

  /**
   * Enable or disable interior parallel hatching.
   * @param {object|null} options - { color, thick, alpha, spacing, angle, innerR }
   */
  setHatch(options) {
    if (options == null) { this.hatch = null; return; }
    this.hatch = options;
  }

  /**
   * @param {number} [t]   - Stroke thickness.
   * @param {number} [col] - Decimal RGB colour.
   * @param {number} [a]   - Alpha 0–1.
   */
  setStyle(t, col, a) {
    if (t   !== undefined) this.thick = t;
    if (col !== undefined) this.color = col;
    if (a   !== undefined) this.alpha = a;
  }

  /**
   * Build local circle orientation matrix `w*` from tilt / beta / lambda.
   */
  doW() {
    const st = Math.sin(this.tilt),   ct = Math.cos(this.tilt);
    const sb = Math.sin(this.beta),   cb = Math.cos(this.beta);
    const cl = Math.cos(this.lambda), sl = Math.sin(this.lambda);
    const c  = this.c;
    c.w0 =  cl * cb;
    c.w1 = -cl * sb * ct;
    c.w2 =  sl * sb * st;
    c.w3 =  cl * sb;
    c.w4 =  cl * cb * ct;
    c.w5 = -sl * cb * st;
    c.w7 =  cl * st;
    c.w8 =  sl * ct;
    this.wVer++;
  }

  /**
   * Configure circle from horizon or celestial parameters (degrees / hours).
   *
   * Horizon: `{ az, alt, tilt, gammaStart?, gammaEnd? }`
   * Celestial: `{ ra, dec, tilt, gammaStart?, gammaEnd? }` (RA in hours)
   *
   * @param {object} arg - Parameter object.
   */
  setParameters(arg) {
    if (arg.az !== undefined && arg.alt !== undefined && arg.tilt !== undefined) {
      this.sys = 0;
      if (isFinite(arg.tilt)) {
        if      (arg.tilt <   0) this.tilt = 0;
        else if (arg.tilt > 180) this.tilt = PI;
        else                     this.tilt = arg.tilt * D2R;
      }
      if (isFinite(arg.alt)) {
        if      (arg.alt < -90) this.lambda = -PI;
        else if (arg.alt >  90) this.lambda =  PI;
        else                    this.lambda = arg.alt * D2R;
      }
      if (isFinite(arg.az))         this.beta = D2R * pMod(-arg.az,         360);
      if (isFinite(arg.gammaStart)) this.gS   = D2R * pMod( arg.gammaStart, 360);
      if (isFinite(arg.gammaEnd))   this.gE   = D2R * pMod( arg.gammaEnd,   360);
    } else if (arg.ra !== undefined && arg.dec !== undefined && arg.tilt !== undefined) {
      this.sys = 1;
      if (isFinite(arg.tilt)) {
        if      (arg.tilt <   0) this.tilt = 0;
        else if (arg.tilt > 180) this.tilt = PI;
        else                     this.tilt = arg.tilt * D2R;
      }
      if (isFinite(arg.dec)) {
        if      (arg.dec < -90) this.lambda = -PI;
        else if (arg.dec >  90) this.lambda =  PI;
        else                    this.lambda = arg.dec * D2R;
      }
      if (isFinite(arg.ra))         this.beta = H2R * pMod(arg.ra,          24);
      if (isFinite(arg.gammaStart)) this.gS   = D2R * pMod(arg.gammaStart, 360);
      if (isFinite(arg.gammaEnd))   this.gE   = D2R * pMod(arg.gammaEnd,   360);
    }
    this.doW();
  }

  /**
   * Set only the gamma arc extents (degrees). Used when latitude changes the
   * observer meridian start/end.
   * @param {number} gStartDeg - Arc start (degrees).
   * @param {number} gEndDeg - Arc end (degrees).
   */
  setGamma(gStartDeg, gEndDeg) {
    this.gS = D2R * pMod(gStartDeg, 360);
    this.gE = D2R * pMod(gEndDeg,   360);
  }

  /**
   * Configure a great-circle arc between two horizon points (AS `setArcPoints`).
   * Used for International Date Line segments and similar polylines on the sphere.
   *
   * @param {{az: number, alt: number}} p1 - First horizon point (degrees).
   * @param {{az: number, alt: number}} p2 - Second horizon point (degrees).
   * @returns {boolean} false if the points are coincident or antipodal.
   */
  setArcPoints(p1, p2) {
    const theta1 = (360 - p1.az) * D2R, phi1 = p1.alt * D2R;
    const theta2 = (360 - p2.az) * D2R, phi2 = p2.alt * D2R;
    const cp1 = Math.cos(phi1), sp1 = Math.sin(phi1), z1 = sp1;
    const x1  = cp1 * Math.cos(theta1), y1 = cp1 * Math.sin(theta1);
    const cp2 = Math.cos(phi2), sp2 = Math.sin(phi2), z2 = sp2;
    const x2  = cp2 * Math.cos(theta2), y2 = cp2 * Math.sin(theta2);
    const ax  = y1 * z2 - y2 * z1;
    const ay  = x2 * z1 - x1 * z2;
    const nz  = x1 * y2 - x2 * y1;
    const aN  = Math.sqrt(ax * ax + ay * ay + nz * nz);
    if (aN < 0.000001) return false;
    this.sys    = 0;
    this.lambda = 0;
    this.tilt   = Math.acos(nz / aN);
    if (this.tilt === 0) {
      this.beta = 0;
      this.gS   = pMod(Math.atan2(y1, x1), TWO_PI);
      this.gE   = pMod(Math.atan2(y2, x2), TWO_PI);
    } else if (this.tilt === PI) {
      this.beta = 0;
      this.gS   = pMod(Math.atan2(-y1, x1), TWO_PI);
      this.gE   = pMod(Math.atan2(-y2, x2), TWO_PI);
    } else {
      this.beta = Math.atan2(ax, -ay);
      const st  = Math.sin(this.tilt);
      this.gS   = pMod(Math.atan2(sp1 / st, cp1 * Math.cos(theta1 - this.beta)), TWO_PI);
      this.gE   = pMod(Math.atan2(sp2 / st, cp2 * Math.cos(theta2 - this.beta)), TWO_PI);
    }
    this.doW();
    return true;
  }

  /**
   * @param   {number[]} a
   * @param   {number[]} b
   * @returns {number}
   */
  gSort(a, b) { return a[0] < b[0] ? -1 : (a[0] > b[0] ? 1 : 0); }

  /**
   * Recompute projected ellipse and split [gS, gE] into front/back path buckets.
   */
  update() {
    this.front.length      = 0;
    this.back.length       = 0;
    this.hatchFront.length = 0;
    this.hatchBack.length  = 0;
    if (!this.visible) return;

    const tc = this.c, pc = this.sphere.c;
    let v0, v1, v2, v3, v4, v5, v6, v7, v8;
    if (this.sys === 0) {
      v0 = pc.a0 * tc.w0 + pc.a1 * tc.w3;
      v1 = pc.a0 * tc.w1 + pc.a1 * tc.w4;
      v2 = pc.a0 * tc.w2 + pc.a1 * tc.w5;
      v3 = pc.a3 * tc.w0 + pc.a4 * tc.w3;
      v4 = pc.a3 * tc.w1 + pc.a4 * tc.w4 + pc.a5 * tc.w7;
      v5 = pc.a3 * tc.w2 + pc.a4 * tc.w5 + pc.a5 * tc.w8;
      v6 = pc.a6 * tc.w0 + pc.a7 * tc.w3;
      v7 = pc.a6 * tc.w1 + pc.a7 * tc.w4 + pc.a8 * tc.w7;
      v8 = pc.a6 * tc.w2 + pc.a7 * tc.w5 + pc.a8 * tc.w8;
    } else {
      v0 = pc.b0 * tc.w0 + pc.b1 * tc.w3;
      v1 = pc.b0 * tc.w1 + pc.b1 * tc.w4 + pc.b2 * tc.w7;
      v2 = pc.b0 * tc.w2 + pc.b1 * tc.w5 + pc.b2 * tc.w8;
      v3 = pc.b3 * tc.w0 + pc.b4 * tc.w3;
      v4 = pc.b3 * tc.w1 + pc.b4 * tc.w4 + pc.b5 * tc.w7;
      v5 = pc.b3 * tc.w2 + pc.b4 * tc.w5 + pc.b5 * tc.w8;
      v6 = pc.b6 * tc.w0 + pc.b7 * tc.w3;
      v7 = pc.b6 * tc.w1 + pc.b7 * tc.w4 + pc.b8 * tc.w7;
      v8 = pc.b6 * tc.w2 + pc.b7 * tc.w5 + pc.b8 * tc.w8;
    }

    const computeHatch = () => {
      if (!this.hatch || this.gS !== this.gE) return;
      const R       = pc.r;
      const spacing =  this.hatch.spacing ?? 10;
      const innerR  =  this.hatch.innerR  ??  0;
      const psi     = (this.hatch.angle   ??  0) * D2R;
      const cosP    =  Math.cos(psi), sinP = Math.sin(psi);
      const frontH  =  this.hatchFront, backH = this.hatchBack;
      const p1 = {}, p2 = {}, pm = {};

      const planeToScreen = (u, v, out) => {
        out.x = (v0 / R) * u + (v1 / R) * v + v2;
        out.y = (v3 / R) * u + (v4 / R) * v + v5;
        out.z = (v6 / R) * u + (v7 / R) * v + v8;
      };

      const pushInterval = (s, t1, t2) => {
        if (t2 <= t1) return;
        const u1 =  s * cosP + t1 * sinP, v1 = -s * sinP + t1 * cosP;
        const u2 =  s * cosP + t2 * sinP, v2 = -s * sinP + t2 * cosP;
        planeToScreen(u1, v1, p1);
        planeToScreen(u2, v2, p2);
        if (p1.z >= 0 && p2.z >= 0) {
          frontH.push({ move: [p1.x, p1.y], line: [p2.x, p2.y] });
        } else if (p1.z < 0 && p2.z < 0) {
          backH.push( { move: [p1.x, p1.y], line: [p2.x, p2.y] });
        } else {
          const f  = p1.z / (p1.z - p2.z);
          const tm = t1 + f * (t2 - t1);
          const um = s * cosP + tm * sinP, vm = -s * sinP + tm * cosP;
          planeToScreen(um, vm, pm);
          if (p1.z >= 0) {
            frontH.push({ move: [p1.x, p1.y], line: [pm.x, pm.y] });
            backH.push( { move: [pm.x, pm.y], line: [p2.x, p2.y] });
          } else {
            backH.push( { move: [p1.x, p1.y], line: [pm.x, pm.y] });
            frontH.push({ move: [pm.x, pm.y], line: [p2.x, p2.y] });
          }
        }
      };

      const kMax = Math.ceil(R / spacing);
      for (let k = -kMax; k <= kMax; k++) {
        const s = k * spacing;
        if (Math.abs(s) >= R) continue;
        const tMax = Math.sqrt(R * R - s * s);
        if (innerR > 0 && Math.abs(s) < innerR) {
          const tIn = Math.sqrt(innerR * innerR - s * s);
          pushInterval(s, -tMax, -tIn );
          pushInterval(s,  tIn,   tMax);
        } else {
          pushInterval(s, -tMax,  tMax);
        }
      }
    };

    const minStep  = this.minStep;
    const frontArr = this.front,
          backArr  = this.back;

    function drawArc(g1, g2, bucket) {
      if (g2 < g1) g2 += TWO_PI;
      let arc = g2 - g1;
      if (arc === 0) arc = TWO_PI;
      const n        = Math.ceil(arc / minStep);
      const step     = arc  / n;
      const halfStep = step / 2;
      const cRad     = 1 / Math.cos(halfStep);
      let   ax       =     Math.cos(g1),
            ay       =     Math.sin(g1);
      const path = { move: [v0 * ax + v1 * ay + v2, v3 * ax + v4 * ay + v5], curves: [] };
      let aAngle = g1 + step;
      let cAngle = aAngle - halfStep;
      for (let i = 0; i < n; i++) {
        ax       = Math.cos(aAngle);
        ay       = Math.sin(aAngle);
        const cx = cRad * Math.cos(cAngle),
              cy = cRad * Math.sin(cAngle);
        path.curves.push([
          v0 * cx + v1 * cy + v2, v3 * cx + v4 * cy + v5,
          v0 * ax + v1 * ay + v2, v3 * ax + v4 * ay + v5
        ]);
        aAngle += step; cAngle += step;
      }
      bucket.push(path);
    }

    const A = Math.sqrt(v6 * v6 + v7 * v7);
    if (A === 0) {
      if (v8 < 0) drawArc(this.gS, this.gE, backArr);
      else drawArc(this.gS, this.gE, frontArr);
      computeHatch();
      return;
    }
    const sj = -v8 / A;
    if (sj <= -1) { drawArc(this.gS, this.gE, frontArr); computeHatch(); return; }
    if (sj >=  1) { drawArc(this.gS, this.gE, backArr);  computeHatch(); return; }

    const j = Math.asin(sj);
    const t = Math.atan2(v6, v7);
    let gDesc, gAsc;
    if (Math.cos(j) < 0) {
      gDesc = pMod(     j - t, TWO_PI);
      gAsc  = pMod(PI - j - t, TWO_PI);
    } else {
      gDesc = pMod(PI - j - t, TWO_PI);
      gAsc  = pMod(     j - t, TWO_PI);
    }
    if (this.gS === this.gE) {
      drawArc(gAsc,  gDesc, frontArr);
      drawArc(gDesc, gAsc,  backArr);
      computeHatch();
      return;
    }
    const gArray = [[gAsc, 0], [gDesc, 1], [this.gS, 2], [this.gE, 3]];
    gArray.sort(this.gSort);
    let draw = false, front = true;
    for (let k = 0; k < 4; k++) {
      const code = gArray[k][1];
      if      (code === 0) front = true;
      else if (code === 1) front = false;
      else if (code === 2) draw  = true;
      else                 draw  = false;
    }
    let prev = gArray[3];
    for (let i = 0; i < 4; i++) {
      const g1 = prev;
      prev = gArray[i];
      if (draw && g1[0] !== prev[0]) {
        if (front) drawArc(g1[0], prev[0], frontArr);
        else       drawArc(g1[0], prev[0], backArr);
      }
      const code = prev[1];
      if      (code === 0) front = true;
      else if (code === 1) front = false;
      else if (code === 2) draw  = true;
      else                 draw  = false;
    }
    computeHatch();
  }
}

/**
 * Straight segment in space, split by the sphere boundary and horizon plane
 * into the four AS clips (`9 CS Lines.as`):
 *   bE — external, behind center (`_bEL`, unmasked)
 *   fE — external, in front      (`_fEL`, unmasked)
 *   aI — inner, above horizon    (`_iLA`, just over  the plane)
 *   bI — inner, below horizon    (`_iLB`, just under the plane)
 *
 * `front` / `back` are merged aliases (fE+aI / bE+bI) so existing sims keep working.
 */
export class Line {
  /**
   * @param {CelestialSphere} sphere - Parent projection engine.
   * @param {{thickness?: number, color?: number, alpha?: number}} [style] - Stroke style.
   * @param {object} [head] - Head point (same forms as parsePointInput).
   * @param {object} [tail] - Tail point.
   */
  constructor(sphere, style, head, tail) {
    this.sphere  = sphere;
  //this.thick   = 1; this.color = 255; this.alpha = 100;
    this.thick   = 1; this.color = "#ffffff"; this.alpha = 1;
    if (style) this.setStyle(style.thickness, style.color, style.alpha);
    this.visible = true;
    this.head    = {};
    this.tail    = {};
    if (head) this.setHeadPoint(head);
    if (tail) this.setTailPoint(tail);
    /** @type {Array<{move:number[], line:number[]}>} */
    this.bE = [];
    /** @type {Array<{move:number[], line:number[]}>} */
    this.fE = [];
    /** @type {Array<{move:number[], line:number[]}>} */
    this.aI = [];
    /** @type {Array<{move:number[], line:number[]}>} */
    this.bI = [];
    /** @type {Array<{move:number[], line:number[]}>} */
    this.front = [];
    /** @type {Array<{move:number[], line:number[]}>} */
    this.back = [];
  }

  /**
   * @param {number} [t] - Stroke thickness.
   * @param {number} [col] - Decimal RGB colour.
   * @param {number} [a] - Alpha 0–1.
   */
  setStyle(t, col, a) {
    if (t   !== undefined) this.thick = t;
    if (col !== undefined) this.color = col;
    if (a   !== undefined) this.alpha = a;
  }

  /**
   * @param {object} h - Head point spec.
   */
  setHeadPoint(h) {
    this.sphere.parsePointInput(h, this.head);
    if (this.head.sys === -1) this.head.sys = 0;
  }

  /**
   * @param {object} t - Tail point spec.
   */
  setTailPoint(t) {
    this.sphere.parsePointInput(t, this.tail);
    if (this.tail.sys === -1) this.tail.sys = 0;
  }

  /**
   * Recompute screen segments into bE / bI / aI / fE (and merged front / back).
   *   bE : behind sphere
   *   bI : within sphere, below horizon
   *   aI : within sphere, above horizon
   *   fE : before sphere
   */
  update() {
    this.bE.length    = 0; this.fE.length   = 0;
    this.aI.length    = 0; this.bI.length   = 0;
    this.front.length = 0; this.back.length = 0;
    if (!this.visible) return;
    const S    = this.sphere;
    const head = {},
          tail = {};
    if      (this.head.sys === 0) S.WtoSz(this.head, head);
    else if (this.head.sys === 1) S.CtoSz(this.head, head); else return;
    if      (this.tail.sys === 0) S.WtoSz(this.tail, tail);
    else if (this.tail.sys === 1) S.CtoSz(this.tail, tail); else return;

    const mx   = head.x - tail.x,
          my   = head.y - tail.y,
          mz   = head.z - tail.z;
    const A    = mx * mx + my * my + mz * mz;
    const B    = 2 * (mx * tail.x + my * tail.y + mz * tail.z);
    const C    = tail.x * tail.x + tail.y * tail.y + tail.z * tail.z;
    const rad  = S.c.r, rad2 = rad * rad;
    const phi  = S.phi;
    const stmp = [];
    const Dsc  = B * B - 4 * A * (C - rad2);
    if (Dsc > 0) {
      const sD = Math.sqrt(Dsc);
      stmp.push((-B + sD) / (2 * A));
      stmp.push((-B - sD) / (2 * A));
    }
    let tp;
    if (phi > -HALF_PI && phi < HALF_PI) {
      tp = Math.tan(phi);
      if (my !== tp * mz) stmp.push((tp * tail.z - tail.y) / (my - tp * mz));
      if (mz !== 0) {
        const tmp = -tail.z / mz;
        if (tmp * (tmp * A + B) + C >= rad2) stmp.push(tmp);
      }
    } else if (mz !== 0) {
      stmp.push(-tail.z / mz);
    }
    const s = [0, 1];
    for (let i = 0; i < stmp.length; i++) {
      if (stmp[i] > 0 && stmp[i] < 1) {
        let k = 1;
        while (stmp[i] > s[k]) k++;
        if (stmp[i] !== s[k]) s.splice(k, 0, stmp[i]);
      }
    }
    const push = (bucket, s1, s2) => bucket.push({
      move: [s1 * mx + tail.x, s1 * my + tail.y],
      line: [s2 * mx + tail.x, s2 * my + tail.y]
    });

    if (S.showUnder) {
      for (let i = 0; i < s.length - 1; i++) {
        const s1 = s[i], s2 = s[i + 1];
        const m  = s1 + (s2 - s1) / 2;
        const r2 = m * (m * A + B) + C;
        let bucket;
        if (r2 < rad2) {
          if      (phi === -HALF_PI) bucket = (m * mz + tail.z > 0) ? this.bI : this.aI;
          else if (phi ===  HALF_PI) bucket = (m * mz + tail.z > 0) ? this.aI : this.bI;
          else bucket = (m * my + tail.y - (m * mz + tail.z) * tp > 1e-9) ? this.bI : this.aI;
        } else {
          bucket = (m * mz + tail.z < 0) ? this.bE : this.fE;
        }
        push(bucket, s1, s2);
      }
    } else {
      for (let i = 0; i < s.length - 1; i++) {
        const s1 = s[i], s2 = s[i + 1];
        const m  = s1 + (s2 - s1) / 2;
        const r2 = m * (m * A + B) + C;
        if (r2 < rad2) {
          if      (phi === -HALF_PI) { if (m * mz + tail.z >  0) continue; }
          else if (phi ===  HALF_PI) { if (m * mz + tail.z <= 0) continue; }
          else { if (m * my + tail.y - (m * mz + tail.z) * tp > 1e-9) continue; }
          push(this.aI, s1, s2);
        } else if (phi === -HALF_PI) {
          if (m * mz + tail.z > 0) continue;
          push(this.bE, s1, s2);
        } else if (phi ===  HALF_PI) {
          if (m * mz + tail.z <= 0) continue;
          push(this.fE, s1, s2);
        } else {
          if (m * my + tail.y - (m * mz + tail.z) * tp > 1e-9) continue;
          push((m * mz + tail.z < 0) ? this.bE : this.fE, s1, s2);
        }
      }
    }
    this.front.push(...this.fE, ...this.aI);
    this.back.push (...this.bE, ...this.bI);
  }
}

/**
 * Default absolute orientation: normal = radial, up in the meridional plane.
 * @param {{x:number,y:number,z:number}} p - Point on the sphere.
 */
export function radialUp(p) {
  const n = { x: p.x, y: p.y, z: p.z };
  let u;
  if (!(n.x === 0 && n.y === 0)) {
    const ux = -n.x * n.z, uy = -n.z * n.y, uz = n.x * n.x + n.y * n.y;
    const m  = Math.sqrt(ux * ux + uy * uy + uz * uz);
    u = { x: ux / m, y: uy / m, z: uz / m };
  } else {
    u = { x: 0, y: 1, z: 0 };
  }
  return { n, u };
}

/**
 * Screen transform at world point p with unit normal n and up u (Flash absOrient).
 * @param {CelestialSphere} S
 * @param {{x:number,y:number,z:number}} p
 * @param {{x:number,y:number,z:number}} n
 * @param {{x:number,y:number,z:number}} u
 * @param {number} [sys=0] - 0 horizon (WtoSz), 1 celestial (CtoSz).
 */
export function absOrient(S, p, n, u, sys = 0) {
  const c = S.c;
  const sp = {}, sp_n = {}, sp_u = {};
  const toSz = (pt, out) => (sys === 1 ? S.CtoSz(pt, out) : S.WtoSz(pt, out));
  toSz(p, sp);
  toSz({ x: p.x + n.x, y: p.y + n.y, z: p.z + n.z }, sp_n);
  toSz({ x: p.x + u.x, y: p.y + u.y, z: p.z + u.z }, sp_u);
  const npz = sys === 1
    ? (n.x * c.b6 + n.y * c.b7 + n.z * c.b8) / c.r
    : (n.x * c.a6 + n.y * c.a7 + n.z * c.a8) / c.r;
  const A = Math.atan2(sp_n.y - sp.y, sp_n.x - sp.x) + HALF_PI;
  const cA = Math.cos(A), sA = Math.sin(A);
  const x0 = sp_u.x - sp.x, y0 = sp_u.y - sp.y;
  const x1 = cA * x0 + sA * y0, y1 = -sA * x0 + cA * y0;
  const instRot = Math.atan2(y1 / npz, x1) + HALF_PI;
  return { sp, yscale: npz, shellRot: A, instRot };
}

/** Stroke quadratic circle path buckets onto ctx. */
export function strokeCirclePaths(ctx, paths, { color, thick, alpha, lineCap }) {
  if (!paths || !paths.length) return;
  ctx.strokeStyle = color;
  ctx.lineWidth   = Math.max(thick, 0.6);
  ctx.globalAlpha = alpha;
  if (lineCap) ctx.lineCap = lineCap;
  for (const p of paths) {
    ctx.beginPath();
    ctx.moveTo(p.move[0], p.move[1]);
    for (const cu of p.curves) ctx.quadraticCurveTo(cu[0], cu[1], cu[2], cu[3]);
    ctx.stroke();
  }
}

/**
 * Parse a horizon or celestial point and project to screen coordinates.
 * @param {CelestialSphere} S
 * @param {object} inP - `{az,alt}` or `{ra,dec}` (optional `r`)
 * @param {object} outSp - Mutated screen point `{x,y,z}`
 * @param {object} [outP] - Optional mutated parsed point `{sys,x,y,z,...}`
 * @returns {object} Parsed point (same as outP when provided)
 */
export function projectPointScreen(S, inP, outSp, outP) {
  const p = outP || {};
  S.parsePointInput(inP, p);
  if      (p.sys === 1) S.CtoSz(p, outSp);
  else if (p.sys === 0) S.WtoSz(p, outSp);
  return p;
}

/** Legacy fS/bS band: true when the projected point is on the near hemisphere. */
export function isScreenFront(sp) {
  return sp.z >= 0;
}

/**
 * Far-side circle arc, stroked after an occluding fill (horizon plane, Earth, …).
 * Dimmed like other back circles, with an optional halo underlay for rim readability.
 * @param {CanvasRenderingContext2D} ctx
 * @param {Circle} circle
 * @param {{ hexToRGBA: function, haloColor?: string, haloAlpha?: number, dim?: number, haloWidth?: number }} opts
 */
export function drawCircleArcBack(ctx, circle, { haloColor = '#ffffff', haloAlpha = 0.9, dim = 0.55, haloWidth = 5 }) {
  if (!circle || circle.visible === false) return;
  const paths = circle.back;
  if (!paths || !paths.length) return;
  const strokePaths = () => {
    for (const p of paths) {
      ctx.beginPath();
      ctx.moveTo(p.move[0], p.move[1]);
      for (const cu of p.curves) ctx.quadraticCurveTo(cu[0], cu[1], cu[2], cu[3]);
      ctx.stroke();
    }
  };
  ctx.save();
  ctx.lineCap     = 'round';
  ctx.lineJoin    = 'round';
  ctx.globalAlpha = circle.alpha * dim;
  ctx.strokeStyle = hexToRGBA(haloColor, haloAlpha);
  ctx.lineWidth   = haloWidth;
  strokePaths();
  ctx.strokeStyle = circle.color;
  ctx.lineWidth   = Math.max(1, circle.thick);
  strokePaths();
  ctx.restore();
}

/**
 * Faint outline at the celestial-sphere limb (after {@link drawGlass}).
 * @param {function(string, number): string} hexToRGBA
 */
export function drawSphereRim(ctx, S, CSC, alpha = 0.5) {
  ctx.strokeStyle = hexToRGBA(CSC.CSPHERE_4, alpha);
  ctx.lineWidth   = 1;
  ctx.beginPath();
  ctx.arc(0, 0, S.c.r, 0, TWO_PI);
  ctx.stroke();
}

/** Stroke line-segment path buckets onto ctx. */
export function strokeLinePaths(ctx, paths, { color, thick, alpha }) {
  if (!paths || !paths.length) return;
  ctx.lineJoin    = 'round';
  ctx.miterLimit  = 2;
  ctx.strokeStyle = color;
  ctx.lineWidth   = Math.max(thick, 0.6);
  ctx.globalAlpha = alpha;
  for (const p of paths) {
    ctx.beginPath();
    ctx.moveTo(p.move[0], p.move[1]);
    ctx.lineTo(p.line[0], p.line[1]);
    ctx.stroke();
  }
}

/**
 * Draw front or back circle bucket with optional dimming and skip predicate.
 * @param {CanvasRenderingContext2D} ctx
 * @param {Circle[]} circles
 * @param {'back'|'front'} which
 * @param {{dim?: number, skip?: function, lineCap?: string}} [opts]
 */
export function drawCircleBucket(ctx, circles, which, opts = {}) {
  const dim  = (which === 'back') ? (opts.dim ?? 0.55) : 1;
  const skip = opts.skip || (() => false);
  for (const c of circles) {
    if (skip(c, which)) continue;
    if (c.visible === false) continue;
    const paths = c[which];
    if (!paths || !paths.length) continue;
    strokeCirclePaths(ctx, paths, {
      color: c.color, thick: c.thick, alpha: c.alpha * dim, lineCap: opts.lineCap
    });
  }
  ctx.globalAlpha = 1;
}

/**
 * Stroke interior hatch chords for circles with an enabled hatch config.
 * @param {CanvasRenderingContext2D} ctx
 * @param {Circle[]} circles
 * @param {'back'|'front'} which
 * @param {{dim?: number}} [opts]
 */
export function drawCircleHatch(ctx, circles, which, opts = {}) {
  const dim = (which === 'back') ? (opts.dim ?? 0.55) : 1;
  for (const c of circles) {
    if (!c.hatch || c.visible === false) continue;
    const segs = (which === 'back') ? c.hatchBack : c.hatchFront;
    if (!segs || !segs.length) continue;
    const h = c.hatch;
    strokeLinePaths(ctx, segs, {
      color: h.color ?? c.color,
      thick: h.thick ?? 1,
      alpha: (h.alpha ?? 1) * dim
    });
  }
  ctx.globalAlpha = 1;
}

/** Stroke one Line clip bucket (bE / fE / aI / bI or merged front/back). */
export function drawLineLayer(ctx, lines, which) {
  for (const l of lines) {
    const segs = l[which];
    if (!segs || !segs.length) continue;
    strokeLinePaths(ctx, segs, { color: l.color, thick: l.thick, alpha: l.alpha });
  }
  ctx.globalAlpha = 1;
}

/**
 * Small open ring at world point p, radial orientation (Flash zenith/nadir marker).
 * @param {function(string, number): string} hexToRGBA - from kl-unl-utils.js
 */
export function drawMarker(ctx, S, p, CSC) {
  const { n, u } = radialUp(p);
  const o = absOrient(S, p, n, u);
  ctx.save();
  ctx.translate(o.sp.x, o.sp.y);
  ctx.rotate(o.shellRot);
  ctx.scale(1, o.yscale);
  ctx.rotate(o.instRot);
  ctx.lineWidth   = 1.5;
  ctx.strokeStyle = CSC.POLE_MRK1;
  ctx.fillStyle   = hexToRGBA(CSC.POLE_MRK2, 0.9);
  ctx.beginPath();
  ctx.arc(0, 0, 4, 0, TWO_PI);
  ctx.fill();
  ctx.stroke();
  ctx.restore();
}

/**
 * Radially oriented star burst at a sphere point (Flash Draggable Star /
 * setOrientationType("absolute") with radial normal). Full opacity; optional
 * hover image when front-facing.
 *
 * @param {CanvasRenderingContext2D} ctx
 * @param {CelestialSphere} S
 * @param {object} worldPt - Parsed or parseable point ({az,alt,r} or {ra,dec,r}, …).
 * @param {HTMLImageElement} img
 * @param {HTMLImageElement} imgHover
 * @param {boolean} hovered - pointer is over the star hit target
 * @param {object} [opts] - { sys, scale, sp } optional precomputed screen point
 */
export function drawStarSprite(ctx, S, worldPt, img, imgHover, hovered, opts = {}) {
  const p = (worldPt.x != null) ? worldPt : (() => { const q = {}; S.parsePointInput(worldPt, q); return q; })();
  const sp = opts.sp || (() => {
    const s = {};
    if (p.sys === 1) S.CtoSz(p, s); else S.WtoSz(p, s);
    return s;
  })();
  const image = (hovered && isScreenFront(sp)) ? imgHover : img;
  if (!image?.naturalWidth) return;
  const w     = image.naturalWidth, h = image.naturalHeight;
  const scale = opts.scale ?? 1;
  const sys   = opts.sys != null ? opts.sys : (p.sys != null ? p.sys : 0);
  const { n, u } = radialUp(p);
  const o     = absOrient(S, p, n, u, sys);
  ctx.save();
  ctx.translate(o.sp.x, o.sp.y);
  ctx.rotate(o.shellRot);
  ctx.scale(1, o.yscale);
  ctx.rotate(o.instRot);
  if (scale !== 1) ctx.scale(scale, scale);
  ctx.drawImage(image, -w / 2, -h / 2, w, h);
  ctx.restore();
}

/**
 * Canvas label at a sphere point with absolute orientation (mirrors on far side).
 * @param {CelestialSphere} S
 * @param {object} worldPt - Parsed or parseable point ({x,y,z} or {ra,dec,r}, …).
 * @param {object} [opts] - { sys, font, halo, alpha }
 */
export function drawOrientedLabel(ctx, S, worldPt, text, color, opts = {}) {
  const p = (worldPt.x != null) ? worldPt : (() => { const q = {}; S.parsePointInput(worldPt, q); return q; })();
  const sys   = opts.sys != null ? opts.sys : 0;
  const { n, u } = radialUp(p);
  const o     = absOrient(S, p, n, u, sys);
  ctx.save();
  if (opts.alpha != null) ctx.globalAlpha = opts.alpha;
  ctx.translate(o.sp.x, o.sp.y);
  ctx.rotate(o.shellRot);
  ctx.scale(1, o.yscale);
  ctx.rotate(o.instRot);
  ctx.lineJoin     = 'round';
  ctx.miterLimit   = 2;
  ctx.font         = opts.font || '700 16px system-ui, -apple-system, Segoe UI, sans-serif';
  ctx.textAlign    = 'center';
  ctx.textBaseline = 'middle';
  ctx.lineWidth    = 3;
  ctx.strokeStyle  = opts.halo || (S.CSC && S.CSC.LABEL_HALO) || '#ffffff';
  ctx.fillStyle    = color;
  ctx.strokeText(text, 0, 0);
  ctx.fillText(  text, 0, 0);
  ctx.restore();
}

/**
 * Fill coastline polygons on a globe disk, following the limb when segments pass
 * behind the visible hemisphere. Ports Flash GlobeComponent.updateGlobe().
 * Without limb-following, skipping back-facing vertices and calling closePath()
 * draws a straight chord across the disk and produces spurious land fill.
 *
 * @param {CanvasRenderingContext2D} ctx - translated to globe center; disk clip optional
 * @param {Array<Array<{x:number,y:number,z:number}>>} shoreData
 * @param {function({x,y,z}, {x,y,z}): void} project - writes screen x, y and depth z
 * @param {number} globeRadius - visible disk radius (e.g. inner.c.r)
 */
export function fillShorePolygons(ctx, shoreData, project, globeRadius) {
  const arcR    = 1.5 * globeRadius;
  const arcStep = 2   * Math.acos(globeRadius * 1.1 / arcR);
  const out     = {};

  for (const poly of shoreData) {
    const len = poly.length;
    let startIdx = -1, prevFront = false;
    for (let k = 0; k < len; k++) {
      project(poly[k], out);
      if (out.z > 0) {
        if (prevFront) { startIdx = k; break; }
        prevFront = true;
      } else prevFront = false;
    }
    if (startIdx < 0) continue;

    ctx.beginPath();
    project(poly[startIdx], out);
    ctx.moveTo(out.x, out.y);
    let prevBack = false, angleLast = 0;

    for (let w = 1; w < len; w++) {
      project(poly[(startIdx + w) % len], out);
      const isBack = out.z < 0;
      if (!isBack) {
        if (prevBack) {
          const ang = Math.atan2(out.y, out.x);
          let da = pMod(ang - angleLast, TWO_PI);
          let steps, inc;
          if (da > PI) { da = TWO_PI - da; steps = Math.ceil(da / arcStep); inc = -da / steps; }
          else { steps = Math.ceil(da / arcStep); inc = da / steps; }
          for (let t = 1; t <= steps; t++) {
            const aa = angleLast + inc * t;
            ctx.lineTo(arcR * Math.cos(aa), arcR * Math.sin(aa));
          }
          ctx.lineTo(out.x, out.y);
        } else {
          ctx.lineTo(out.x, out.y);
        }
      } else if (!prevBack) {
        angleLast = Math.atan2(out.y, out.x);
        ctx.lineTo(arcR * Math.cos(angleLast), arcR * Math.sin(angleLast));
      }
      prevBack = isBack;
    }
    ctx.closePath();
    ctx.fill();
  }
}

/**
 * Frosted-glass sphere body using CSC grey radial stops.
 * @param {function(string, number): string} hexToRGBA - from kl-unl-utils.js
 */
export function drawGlass(ctx, S, CSC) {
  const r = S.c.r;
  const g = ctx.createRadialGradient(0, 0, r * 0.1, 0, 0, r);
  g.addColorStop(0,    hexToRGBA(CSC.CSPHERE_1, 0.32));
  g.addColorStop(0.80, hexToRGBA(CSC.CSPHERE_2, 0.38));
  g.addColorStop(1,    hexToRGBA(CSC.CSPHERE_3, 0.52));
  ctx.beginPath();
  ctx.arc(0, 0, r, 0, TWO_PI);
  ctx.fillStyle = g;
  ctx.fill();
}

/**
 * Port of Flash "7 CS Objects.as": screen position + orientation for sphere sprites.
 */
export class SphereObject {
  constructor(sphere, position, opts) {
    this.s = sphere;
    this._o = { x: 0, y: 0, z: 0 };
    this._n = { x: 0, y: 0, z: 1 };
    this._u = { x: 0, y: 1, z: 0 };
    this._oType  = 0;
    this.visible = true;
    this._sp     = { x: 0, y: 0, z: 0 };
    this.opts    = opts || {};
    this.labe    = false;
    this.text    = '';
    if (position) this.setPosition(position);
    else { this._p = { x: 0, y: 0, z: 1 }; this._sys = 0; this._r = 1; }
  }

  setPosition(a) {
    const p = this.s.parse(a);
    this._sys = (p.sys === 1) ? 1 : 0;
    this._p = p;
    this._r = p.r;
  }

  setOrientationAbsolute() {
    this._oType = 2;
    const p = this._p;
    const nm = Math.sqrt(p.x * p.x + p.y * p.y + p.z * p.z);
    this._n = { x: p.x / nm, y: p.y / nm, z: p.z / nm };
    if (!(this._n.x === 0 && this._n.y === 0)) {
      const u = {
        x: -this._n.x * this._n.z,
        y: -this._n.z * this._n.y,
        z:  this._n.x * this._n.x + this._n.y * this._n.y
      };
      const nu = Math.sqrt(u.x * u.x + u.y * u.y + u.z * u.z);
      this._u = { x: u.x / nu, y: u.y / nu, z: u.z / nu };
    } else {
      this._u = { x: 0, y: 1, z: 0 };
    }
    this._p_u = { x: p.x + this._u.x, y: p.y + this._u.y, z: p.z + this._u.z };
    this._p_n = { x: p.x + this._n.x, y: p.y + this._n.y, z: p.z + this._n.z };
  }

  update() {
    const s = this.s, c = s.c, sp = this._sp;
    if (this._sys === 0) s.WtoSz(this._p, sp); else s.CtoSz(this._p, sp);
    if (this._oType === 2) {
      const sp_u = {}, sp_n = {};
      let npz;
      if (this._sys === 0) {
        npz = (this._n.x * c.a6 + this._n.y * c.a7 + this._n.z * c.a8) / c.r;
        s.WtoSz(this._p_n, sp_n);
        s.WtoSz(this._p_u, sp_u);
      } else {
        npz = (this._n.x * c.b6 + this._n.y * c.b7 + this._n.z * c.b8) / c.r;
        s.CtoSz(this._p_n, sp_n);
        s.CtoSz(this._p_u, sp_u);
      }
      this.yscale = npz;
      const Aa = Math.atan2(sp_n.y - sp.y, sp_n.x - sp.x) + HALF_PI;
      this.rotation = Aa;
      const cA = Math.cos(Aa),      sA = Math.sin(Aa);
      const x0 = sp_u.x - sp.x,     y0 = sp_u.y - sp.y;
      const x1 = cA * x0 + sA * y0, y1 = -sA * x0 + cA * y0;
      this.instRotation = Math.atan2(y1 / npz, x1) + HALF_PI;
    } else {
      this.yscale       = 1;
      this.rotation     = 0;
      this.instRotation = 0;
    }
  }
}

/**
 * Star location describer.
 *
 * @param   {number} mode - Mode 0 for altitude        and azimuth     angles, 
  *                         Mode 1 for right ascension and declination angles  
 * @param   {number} az   - Azimuth  angle of star for stick figure on horizon (degrees)
 * @param   {number} alt  - Altitude angle of star for stick figure on horizon (degrees)
 * @returns {string} snt  - Description of star position in sky, for accessibility content
 */

export function locateStar(coord1,coord2,mode=0)  {
  // Place star in observer's sky as one might describe it to a fellow viewer.
  // Text is designed to be used by screen readers and in aria labels.

  let s0 = '';
  
  if ( !Number.isFinite( coord1 ) )  { coord1 = 0; }
  if ( !Number.isFinite( coord2 ) )  { coord2 = 0; }
    
  // Place star in observer's sky based on stellar azimuth and altitude and
  // oriented with respect to the cardinal directions and the horizon.
  if ( mode == 0 )  {
    
    const az  = Math.min( Math.max( coord1,   0 ), 360 );
    const alt = Math.min( Math.max( coord2, -90 ),  90 );
    
    // Describe star's position in the sky based on azimuth.
    s0 = 'The star appears ';
    if        ( az ==   0 )  {
      s0 += 'due north';
    } else if ( (  0   <= az && az <  22.5) ||
                (337.5 <= az && az <= 360  ) )  {
      s0 += 'slightly ' + (az < 180 ? 'east'  : 'west'  ) + ' of north';
    } else if ( 22.5 <= az && az <  67.5 )  {
      s0 += 'in the northeast';
    } else if ( az ==  90 )  {
      s0 += 'due east';
    } else if ( 67.5 <= az && az < 112.5 )  {
      s0 += 'slightly ' + (az <  90 ? 'north' : 'south' ) + ' of east';
    } else if (112.5 <= az && az < 157.5 )  {
      s0 += 'in the southeast';
    } else if ( az == 180 )  {
      s0 += 'due south';
    } else if (157.5 <= az && az < 202.5 )  {
      s0 += 'slightly ' + (az < 180 ? 'east'  : 'west'  ) + ' of south';
    } else if (202.5 <= az && az < 247.5 )  {
      s0 += 'in the southwest';
    } else if ( az == 270 )  {
      s0 += 'due west';
    } else if (247.5 <= az && az < 292.5 )  {
      s0 += 'slightly ' + (az < 270 ? 'south' : 'north' ) + ' of west';
    } else if (292.5 <= az && az < 337.5 )  {
      s0 += 'in the northwest';
    }
    // Describe star's position in the sky based on altitude.
    if        ( alt <  -5 )  {
      s0  = 'The star is hidden well below the horizon. ';
    } else if ( alt <   0 )  {
      s0  = 'The star is hidden just below the horizon. ';
    } else if ( alt ==  0 )  {
      s0 += ', right on the horizon. ';
    } else if ( alt <  30 )  {
      s0 += ', above the horizon. ';
    } else if ( alt <  60 )  {
      s0 += ', well above the horizon. ';
    } else if ( alt <  75 )  {
      s0 += ', high above the horizon. ';
    } else if ( alt <  90 )  {
      s0 += ', almost directly above the observer\'s head. ';
    } else  {
      s0  = 'The star is directly above the observer\'s head. ';
    }
    
  // Place star in observer's sky based on stellar right ascension and declination.
  } else if (mode == 1)  {
    
    const ra  = Math.min( Math.max( coord1,   0 ), 24 );
    const dec = Math.min( Math.max( coord2, -90 ), 90 );
    
    // Describe star's position in the sky based on declination.
    if        ( dec == -90   )  {
      s0 += 'directly above the South Pole. ';
    } else if ( dec <  -66.5 )  {
      s0 += 'almost directly above the South Pole. ';
    } else if ( dec <  -23.5 )  {
      s0 += 'visible from the southern hemisphere. ';
    } else if ( dec <   23.5 )  {
      s0 += 'above the equator. ';
    } else if ( dec <   66.5 )  {
      s0 += 'visible from the northern hemisphere. ';
    } else if ( dec <   90   )  {
      s0 += 'almost directly above the North Pole. ';
    } else  {
      s0 += 'directly above the North Pole. ';
    }
  }
  return s0;
};

