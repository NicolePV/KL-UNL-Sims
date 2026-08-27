/* ===========================================================================
   KL-UNL Celestial Sphere (`kl-unl-celestial-sphere.js`)
   ---------------------------------------------------------------------------
   Shared mathematical and projection engine for celestial sphere.

   Matrices on scratch object `c`:
     a0..a8  — world (horizon) → screen projection (scaled by sphere radius r)
     m0..m8  — celestial → world (observer latitude + local sidereal time)
     b0..b8  — celestial → screen (a · m composite)

   Angle conventions:
     RA is in hours when passed to parse / setParameters; stored internally
     in radians.
   =========================================================================== */

import { pMod } from './kl-unl-utils.js';

/** Geometric constants */
export const D2R =  0.017453292519943295;   /** Degrees → radians (π/180)      */
export const R2D = 57.29577951308232;       /** Radians → degrees (180/π)      */
export const H2R =  0.2617993877991494;     /** Hours   → radians (15° = π/12) */
export const R2H =  3.819718634205488;      /** Radians → hours                */

export const TWO_PI  = 6.283185307179586;   /** 2π   */
export const PI      = 3.141592653589793;   /**  π   */
export const HALF_PI = 1.5707963267948966;  /**  π/2 */
export const QURT_PI = 0.7853981633974483;  /**  π/4 */
export const SXTH_PI = 0.5235987755982988;  /**  π/6 */

/** Default celestial sphere colors in hex */
export const CELESTIAL_SPHERE_COLORS = {
  // Arcs and line segments
  AZ_ARC:     '#5645f5',  // (slate blue)
  AZ_ARC_BCK: '#ffffff',  // (white)
  ALT_ARC:    '#a63743',  // (brick red)
  AZ_CIRC:    '#a0a0a0',  // (medium gray)
  ALT_CIRC:   '#a0a0a0',  // (medium gray)
  MRDN2_CIRC: '#000000',  // (black)
  MRDN_CIRC:  '#216331',  // (dark green)
  POLE_LNSG:  '#505050',  // (dark gray)

  // Celestial sphere
  CSPHERE_1:  '#e6e9ec',  // (pale  grayish blue)
  CSPHERE_2:  '#d0d4d9',  // (light grayish blue)
  CSPHERE_3:  '#787e86',  // (muted grayish blue)

  // Horizon
  HOR_ABV_1:  '#46b446',  // (vibrant green)
  HOR_ABV_2:  '#3da53d',  // (medium  green)
  HOR_ABV_3:  '#2f8a2f',  // (forest  green)
  HOR_BLW_1:  '#0a7a14',  // (deep    green)
  HOR_BLW_2:  '#005000',  // (dark    green)

  // North and south poles
  POLE_MRK1:  '#222222',  // (dark grey)
  POLE_MRK2:  '#ffffff',  // (white)

  // General labels (zenith, nadir, horizon, meridian)
  LABEL_LNSG: '#1f1f1f',  // (charcoal grey)
  LABEL_FILL: '#1a1a1a',  // (dark     grey)
  LABEL_HALO: '#ffffff',  // (white)

  // Altitude and azimuth labels
  AZ_LABEL:   '#4a4080',  // (dark blue)
  ALT_LABEL:  '#9a2230',  // (scarlet sage)

  // Cardinal direction labels
  NESW_LINE:  '#1a1a1a',  // (dark grey)
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
    if (style) this.setStyle(style.thickness, style.color, style.alpha);
    if (def)   this.setParameters(def);
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
    this.front.length = 0;
    this.back.length  = 0;
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
      return;
    }
    const sj = -v8 / A;
    if (sj <= -1) { drawArc(this.gS, this.gE, frontArr); return; }
    if (sj >=  1) { drawArc(this.gS, this.gE, backArr);  return; }

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
 * Star location describer.
 *
 * @param   {number} az  - Azimuth  angle of star for stick figure on horizon (degrees)
 * @param   {number} alt - Altitude angle of star for stick figure on horizon (degrees)
 * @returns {string} snt - Description of star position in sky, for accessibility content
 */

export function locateStar(az,alt)  {
  // Place star in observer's sky as one might describe it to a fellow viewer,
  // based on stellar azimuth and altitude and oriented with respect to
  // the cardinal directions and the horizon.
  //
  // Text is designed to be used by screen readers and in aria labels.

  // Describe star's position in the sky based on azimuth.
  let s0 = 'The star appears ';
  if        ( az ==   0 )  {
    s0 += 'due north';
  } else if ( (  0   <= az && az <  22.5) ||
              (337.5 <= az && az < 360  ) )  {
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
  return s0;
};

