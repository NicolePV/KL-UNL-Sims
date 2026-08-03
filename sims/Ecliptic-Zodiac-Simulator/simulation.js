/* ===========================================================================
   Ecliptic (Zodiac) Simulator  --  HTML5 port
   ---------------------------------------------------------------------------
   Behavioural ground truth: the decompiled ActionScript 1 in ../scripts/
     ZodiacViewer.as, CelestialSphere.as, "2 CS Getter Setter.as",
     "3 CS Geometry.as", "4 CS Mouse.as", "8 CS Circles.as",
     "7 CS Objects.as", GlobeComponent.as, "Modified Year Slider.as".

   Every constant, matrix and formula below is copied verbatim from that
   source; the AS line of provenance is named in the comment above each block.
   Presentation (KL-UNL shell, native controls, ARIA) is new -- the physics and
   geometry are not.

   Coordinate systems, exactly as in the original:
     world / "horizon"  frame  (az, alt)  -- x,y,z unit vectors
     "celestial"        frame  (ra, dec)  -- x,y,z unit vectors
     screen             frame  (x right, y DOWN, z toward the viewer)
   The drawing code works in original Flash stage pixels throughout; CSS scales
   the canvas element, so the ported maths never sees the on-screen size.
   =========================================================================== */

'use strict';

/* ---------------------------------------------------------------------------
   1. Constants -- all verbatim from the ActionScript
   --------------------------------------------------------------------------- */

// Radian/degree/hour conversions, using the same literals the AS source uses.
const DEG      = 0.017453292519943295;   // pi/180
const RAD      = 57.29577951308232;      // 180/pi
const HOUR_RAD = 0.2617993877991494;     // pi/12   (hours -> radians)
const RAD_HOUR = 3.819718634205488;      // 12/pi   (radians -> hours)
const TWO_PI   = 6.283185307179586;
const HALF_PI  = 1.5707963267948966;
const PI       = 3.141592653589793;

// ZodiacViewer on(initialize) -- scripts/frame_1/PlaceObject2_58_...on(initialize).as
const INIT_EARTH_DISK_SIZE  = 35;
const INIT_EARTH_ORBIT_SIZE = 250;
const INIT_ZODIAC_SIZE      = 600;

// ZodiacViewerClass() -- ZodiacViewer.as
const INIT_THETA             = 206;      // celestialSphere.theta = 206
const INIT_PHI               = 30;       // from CelestialSphere setThetaAndPhi(90, 30)
const MAX_VIEWER_ALTITUDE    = 50;       // celestialSphere.maxViewerAltitude = 50
const MIN_VIEWER_ALTITUDE    = -90;      // CelestialSphere default _minPhi
const SIDEREAL_TIME          = 18;       // celestialSphere.siderealTime = 18
const LATITUDE               = 66.5;     // celestialSphere.latitude = 66.5
const ZODIAC_BAND_HALF_ANGLE = 24;       // var zodiacBandHalfAngle = 24

// AS colour ints -> CSS.  14671839 = 0xDFDFDF, 5263440 = 0x505050.
const CONSTELLATIONS_COLOR = '#dfdfdf';  // this.constellationsColor = 14671839
const ECLIPTIC_COLOR       = '#505050';  // addCircle("ecliptic", {color:5263440})
const ECLIPTIC_TILT        = 23.5;       // addCircle("ecliptic", {tilt:23.5})

// updateZodiacBand() gradient -- 11455999 = 0xAECDFF, 4671303 = 0x474747.
const BAND_LIGHT = '174,205,255';        // rgb triple for 0xAECDFF
const BAND_DARK  = '71,71,71';           // rgb triple for 0x474747
const BAND_ALPHA = 60 / 100;             // alphas1/alphas2 are all 60
const BAND_HALF_WIDTH_DEG = 15;          // var width = 15

// GlobeComponentClass -- GlobeComponent.as
const GLOBE_RADIUS = 40;                 // p._radius = 40
// setScale(100 * (initEarthDiskSize / 2 / 40)) -> 43.75%
const GLOBE_SCALE  = INIT_EARTH_DISK_SIZE / 2 / GLOBE_RADIUS;
const GLOBE_OBLIQUITY_COS = 0.91706;     // cos(23.5 deg) as spelled in the AS
const GLOBE_OBLIQUITY_SIN = 0.39875;     // sin(23.5 deg) as spelled in the AS

// p.setMonthAndDay -- ZodiacViewer.as.  Day 0 of the year is 1 January.
const MONTH_FIRST_DAY = [0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334];
const MONTH_LABELS = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
const MONTH_NAMES  = ['January', 'February', 'March', 'April', 'May', 'June',
                      'July', 'August', 'September', 'October', 'November',
                      'December'];

// Modified Year Slider on(initialize) -- initMin/initMax
const DAY_MIN = 0;
const DAY_MAX = 365;

// Constellation Label / TimelineLabel text fields: Arial, 280 twips = 14 px,
// colour #dfdfdf, centre aligned (see texts/47.txt, texts/53.txt).
const LABEL_FONT  = '14px Arial, Helvetica, sans-serif';
const LABEL_COLOR = '#dfdfdf';

// Canvas: the sphere is 600 px across and centred on the ZodiacViewer origin,
// so a 620x620 stage holds it with a 10 px margin. Original stage coordinates
// are preserved; only the (empty) left/right margins of the 800x650 Flash
// stage are trimmed, and the timeline moved into HTML below the canvas.
const CANVAS_SIZE = 620;
const ORIGIN_X = CANVAS_SIZE / 2;
const ORIGIN_Y = CANVAS_SIZE / 2;

/* ---------------------------------------------------------------------------
   2. Small helpers
   --------------------------------------------------------------------------- */

// CelestialSphereClass.prototype.mod -- CelestialSphere.as
function mod(n, m) {
  return ((n % m) + m) % m;
}

/* ---------------------------------------------------------------------------
   3. CelestialSphere -- the projection engine
      Ported from CelestialSphere.as, "2 CS Getter Setter.as", "3 CS Geometry.as".
   --------------------------------------------------------------------------- */

class CelestialSphere {
  constructor() {
    this.c = {};                 // the _c matrix cache (a*, b*, m*)
    this.aVer = -1;              // version counters used by the circle cache
    this.bVer = -1;
    this.maxPhi = 90;
    this.minPhi = -90;
    this.c.r = 150;
    this.c.r2 = this.c.r * this.c.r;
    this.showUnder = true;
    this.objects = [];
    this.circles = [];

    // Constructor order in CelestialSphere.as
    this.setThetaAndPhi(90, 30);
    this.setLatitude(41);
    this.setSiderealTime(0);
  }

  /* --- getters/setters ("2 CS Getter Setter.as") -------------------------- */

  get theta()   { return RAD * this._theta; }
  get phi()     { return RAD * this._phi; }
  get size()    { return 2 * this.c.r; }
  get latitude(){ return RAD * this._lat; }
  get siderealTime() { return this._sTime * RAD_HOUR; }

  // p.getViewerAzimuth: (360 - theta) % 360
  get viewerAzimuth() { return mod(360 - this.theta, 360); }

  set size(v) {
    this.c.r = v / 2;
    this.c.r2 = this.c.r * this.c.r;
    this.doA();
    this.doB();
  }

  setThetaAndPhi(newTheta, newPhi) {
    let phi = newPhi;
    this._theta = DEG * mod(newTheta, 360);
    if (phi > this.maxPhi) phi = this.maxPhi;
    else if (phi < this.minPhi) phi = this.minPhi;
    this._phi = phi * DEG;
    this.doA();
    this.doB();
  }

  setTheta(v) {
    this._theta = DEG * mod(v, 360);
    this.doA();
    this.doB();
  }

  setViewerAzimuth(v) { this.setTheta(360 - v); }

  setPhi(newPhi) {
    let phi = newPhi;
    if (phi > this.maxPhi) phi = this.maxPhi;
    else if (phi < this.minPhi) phi = this.minPhi;
    this._phi = phi * DEG;
    this.doA();
    this.doB();
  }

  setSiderealTime(v) {
    this._sTime = mod(v, 24) * HOUR_RAD;
    this.doM();
    this.doB();
  }

  setLatitude(v) {
    let lat = v;
    if (lat > 90) lat = 90;
    else if (lat < -90) lat = -90;
    this._lat = lat * DEG;
    this.doM();
    this.doB();
  }

  /* --- matrix builders (p.doA / p.doM / p.doB, "3 CS Geometry.as") -------- */

  doA() {
    const c = this.c;
    const ct = Math.cos(this._theta), st = Math.sin(this._theta);
    const cp = Math.cos(this._phi),   sp = Math.sin(this._phi);
    c.a0 = -c.r * st;
    c.a1 =  c.r * ct;
    c.a3 =  c.r * ct * sp;
    c.a4 =  c.r * st * sp;
    c.a5 = -c.r * cp;
    c.a6 =  c.r * ct * cp;
    c.a7 =  c.r * st * cp;
    c.a8 =  c.r * sp;
    this.aVer += 1;
  }

  doM() {
    const c = this.c;
    c.m2 = Math.cos(this._lat);
    c.m3 = Math.sin(this._sTime);
    c.m4 = -Math.cos(this._sTime);
    c.m8 = Math.sin(this._lat);
    c.m0 = c.m4 * c.m8;
    c.m1 = -c.m3 * c.m8;
    c.m6 = -c.m2 * c.m4;
    c.m7 = c.m2 * c.m3;
  }

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
    this.bVer += 1;
  }

  /* --- point parsing and transforms ("3 CS Geometry.as") ----------------- */

  // p.parsePointInput: accepts {az,alt[,r]}, {ra,dec[,r]} or {x,y,z[,system]}
  parsePointInput(p, out) {
    let r;
    if (p.az !== undefined && p.alt !== undefined) {
      out.sys = 0;
      r = (p.r !== undefined) ? p.r : 1;
      const d = r * Math.cos(p.alt * DEG);
      out.x = d * Math.cos(p.az * DEG);
      out.y = d * Math.sin(-p.az * DEG);
      out.z = r * Math.sin(p.alt * DEG);
      out.r = Math.abs(r);
    } else if (p.ra !== undefined && p.dec !== undefined) {
      out.sys = 1;
      r = (p.r !== undefined) ? p.r : 1;
      const d = r * Math.cos(p.dec * DEG);
      out.x = d * Math.cos(p.ra * HOUR_RAD);
      out.y = d * Math.sin(p.ra * HOUR_RAD);
      out.z = r * Math.sin(p.dec * DEG);
      out.r = Math.abs(r);
    } else {
      out.sys = (p.system === 'celestial') ? 1 : 0;
      out.x = p.x; out.y = p.y; out.z = p.z;
      out.r = Math.sqrt(p.x * p.x + p.y * p.y + p.z * p.z);
      if (out.r < 1.000001 && out.r > 0.999999) out.r = 1;
    }
    return out;
  }

  // p.WtoSz -- world (horizon) -> screen, keeping z
  WtoSz(p, sp) {
    const c = this.c;
    sp.x = p.x * c.a0 + p.y * c.a1;
    sp.y = p.x * c.a3 + p.y * c.a4 + p.z * c.a5;
    sp.z = p.x * c.a6 + p.y * c.a7 + p.z * c.a8;
    return sp;
  }

  // p.CtoSz -- celestial -> screen, keeping z
  CtoSz(p, sp) {
    const c = this.c;
    sp.x = p.x * c.b0 + p.y * c.b1 + p.z * c.b2;
    sp.y = p.x * c.b3 + p.y * c.b4 + p.z * c.b5;
    sp.z = p.x * c.b6 + p.y * c.b7 + p.z * c.b8;
    return sp;
  }

  // p.CtoW / p.WtoC
  CtoW(p, wp) {
    const c = this.c;
    wp.x = p.x * c.m0 + p.y * c.m1 + p.z * c.m2;
    wp.y = p.x * c.m3 + p.y * c.m4;
    wp.z = p.x * c.m6 + p.y * c.m7 + p.z * c.m8;
    return wp;
  }

  WtoC(p, cp) {
    const c = this.c;
    cp.x = p.x * c.m0 + p.y * c.m3 + p.z * c.m6;
    cp.y = p.x * c.m1 + p.y * c.m4 + p.z * c.m7;
    cp.z = p.x * c.m2 + p.z * c.m8;
    return cp;
  }

  // p.toScreen
  toScreen(up, sp) {
    const p = this.parsePointInput(up, {});
    if (p.sys === 1) this.CtoSz(p, sp);
    else this.WtoSz(p, sp);
    return sp;
  }

  // p.pointToHorizon
  pointToHorizon(p, out) {
    let src = p, s;
    if (p.sys === 1) src = this.CtoW(p, {});
    s = src.z / p.r;
    if (s < -1) s = -1; else if (s > 1) s = 1;
    out.az = mod(-RAD * Math.atan2(src.y, src.x), 360);
    out.alt = RAD * Math.asin(s);
    out.r = p.r;
    return out;
  }

  // p.pointToCelestial
  pointToCelestial(p, out) {
    let src = p, s;
    if (p.sys !== 1) src = this.WtoC(p, {});
    s = src.z / p.r;
    if (s > 1) s = 1; else if (s < -1) s = -1;
    out.ra = mod(RAD_HOUR * Math.atan2(src.y, src.x), 24);
    out.dec = RAD * Math.asin(s);
    out.r = p.r;
    return out;
  }
}

/* ---------------------------------------------------------------------------
   4. CSObject -- an item pinned to (or inside) the sphere
      Ported from "7 CS Objects.as".
   --------------------------------------------------------------------------- */

class CSObject {
  constructor(sphere, name) {
    this.sphere = sphere;
    this.name = name;
    this.p = {};
    this.sp = {};                       // screen position
    this.o = { x: 0, y: 0, z: 0 };      // "flat"/"skewed" orientation vector
    this.n = { x: 0, y: 0, z: 0 };      // "absolute" normal
    this.u = { x: 0, y: 0, z: 0 };      // "absolute" up
    this.oType = 0;
    // Draw-time transform, filled in by update()
    this.rotation = 0;                  // shell._rotation, radians
    this.yScale = 1;                    // shell._yscale / 100
    this.innerRotation = 0;             // instance._rotation, radians
  }

  // p.setPosition
  setPosition(arg) {
    const q = this.sphere.parsePointInput(arg, {});
    this.sys = q.sys;
    this.p = q;
    this.r = q.r;
    this.recomputeOffsets();
  }

  recomputeOffsets() {
    const p = this.p;
    this.p_o = { x: p.x + this.o.x, y: p.y + this.o.y, z: p.z + this.o.z };
    this.p_n = { x: p.x + this.n.x, y: p.y + this.n.y, z: p.z + this.n.z };
    this.p_u = { x: p.x + this.u.x, y: p.y + this.u.y, z: p.z + this.u.z };
  }

  // p.setOrientationType("absolute", normalPoint, upPoint)
  // With no arguments the normal is the object's own radial direction and the
  // up vector is derived from it, exactly as in the AS.
  setAbsoluteOrientation(arg2, arg3) {
    this.oType = 2;
    const sphere = this.sphere;

    if (typeof arg2 !== 'object' || typeof arg3 !== 'object') {
      const p = this.p;
      const nm = Math.sqrt(p.x * p.x + p.y * p.y + p.z * p.z);
      this.n = { x: p.x / nm, y: p.y / nm, z: p.z / nm };
      if (!(this.n.x === 0 && this.n.y === 0)) {
        let u = {
          x: -this.n.x * this.n.z,
          y: -this.n.z * this.n.y,
          z: this.n.x * this.n.x + this.n.y * this.n.y
        };
        const nu = Math.sqrt(u.x * u.x + u.y * u.y + u.z * u.z);
        this.u = { x: u.x / nu, y: u.y / nu, z: u.z / nu };
      } else {
        this.u = { x: 0, y: 1, z: 0 };
      }
    } else {
      // Both reference points are converted into THIS object's frame first.
      let v1 = sphere.parsePointInput(arg2, {});
      if (v1.sys === 0 && this.sys === 1) v1 = sphere.WtoC(v1, {});
      else if (v1.sys === 1 && this.sys === 0) v1 = sphere.CtoW(v1, {});

      let v2 = sphere.parsePointInput(arg3, {});
      if (v2.sys === 0 && this.sys === 1) v2 = sphere.WtoC(v2, {});
      else if (v2.sys === 1 && this.sys === 0) v2 = sphere.CtoW(v2, {});

      const nm = Math.sqrt(v1.x * v1.x + v1.y * v1.y + v1.z * v1.z);
      this.n = { x: v1.x / nm, y: v1.y / nm, z: v1.z / nm };
      const nx = this.n.x, ny = this.n.y, nz = this.n.z;
      const ax = v2.x, ay = v2.y, az = v2.z;
      // (I - n n^T) a -- the part of "up" perpendicular to the normal
      const ux = ny * ny * ax - nx * ny * ay - nx * nz * az + nz * nz * ax;
      const uy = nz * nz * ay - ny * nz * az - nx * ny * ax + nx * nx * ay;
      const uz = nx * nx * az - nx * nz * ax - ny * nz * ay + ny * ny * az;
      const un = Math.sqrt(ux * ux + uy * uy + uz * uz);
      this.u = { x: ux / un, y: uy / un, z: uz / un };
    }
    this.recomputeOffsets();
  }

  // p.update -- computes the shell/instance transform for the current view
  update() {
    const sphere = this.sphere;
    const c = sphere.c;
    const sp = this.sp;

    if (this.oType === 2) {
      const sp_n = {}, sp_u = {};
      let npz;
      if (this.sys === 0) {
        npz = (this.n.x * c.a6 + this.n.y * c.a7 + this.n.z * c.a8) / c.r;
        sphere.WtoSz(this.p_n, sp_n);
        sphere.WtoSz(this.p_u, sp_u);
      } else {
        npz = (this.n.x * c.b6 + this.n.y * c.b7 + this.n.z * c.b8) / c.r;
        sphere.CtoSz(this.p_n, sp_n);
        sphere.CtoSz(this.p_u, sp_u);
      }
      this.yScale = npz;
      const A = Math.atan2(sp_n.y - sp.y, sp_n.x - sp.x) + HALF_PI;
      this.rotation = A;
      const cA = Math.cos(A), sA = Math.sin(A);
      const x0 = sp_u.x - sp.x, y0 = sp_u.y - sp.y;
      const x1 = cA * x0 + sA * y0;
      const y1 = -sA * x0 + cA * y0;
      this.innerRotation = Math.atan2(y1 / npz, x1) + HALF_PI;
    } else {
      // "flat"/"skewed": the AS shares one branch for oType 0 and 1.
      const sp_o = {};
      let opz;
      if (this.sys === 0) {
        opz = this.o.x * c.a6 + this.o.y * c.a7 + this.o.z * c.a8;
        sphere.WtoSz(this.p_o, sp_o);
      } else {
        opz = this.o.x * c.b6 + this.o.y * c.b7 + this.o.z * c.b8;
        sphere.CtoSz(this.p_o, sp_o);
      }
      this.yScale = Math.sqrt(1 - (opz * opz) / c.r2);
      // The globe uses the default zero orientation vector, so sp_o is exactly
      // sp and the AS evaluates Math.atan2(0, 0) here. Flash returns NaN for
      // that case and its _rotation setter ignores a non-finite assignment, so
      // the clip keeps the rotation it already had. Reproduced literally --
      // verified against the original screenshot, see CONVERSION_NOTES.md.
      const dx = sp_o.x - sp.x, dy = sp_o.y - sp.y;
      if (dx !== 0 || dy !== 0) this.rotation = Math.atan2(dy, dx) + HALF_PI;
      this.innerRotation = 0;
    }
  }

  get az()  { return this.sphere.pointToHorizon(this.p, {}).az; }
  get alt() { return this.sphere.pointToHorizon(this.p, {}).alt; }
  get ra()  { return this.sphere.pointToCelestial(this.p, {}).ra; }
  get dec() { return this.sphere.pointToCelestial(this.p, {}).dec; }
}

/* ---------------------------------------------------------------------------
   5. CSCircle -- a great/small circle on the sphere
      Ported from "8 CS Circles.as".
   --------------------------------------------------------------------------- */

class CSCircle {
  constructor(sphere, name) {
    this.sphere = sphere;
    this.name = name;
    this.c = {};
    this.gS = 0;              // gamma start
    this.gE = 0;              // gamma end (equal to gS means a full circle)
    this.beta = 0;
    this.tilt = 0;
    this.lambda = 0;
    this.sys = 0;
    this.visible = true;
    this.color = '#ff0000';
    this.thickness = 1;
    this.alpha = 0.8;
    this.minStep = 0.7853981633974483;   // p._minStep = pi/4
  }

  setStyle(thickness, color, alpha) {
    if (thickness !== undefined) this.thickness = thickness;
    if (color !== undefined) this.color = color;
    if (alpha !== undefined) this.alpha = alpha / 100;
  }

  // p.setCircleParameters / p.setParameters
  setParameters(arg) {
    if (arg.az !== undefined && arg.alt !== undefined && arg.tilt !== undefined) {
      this.sys = 0;
      this.tilt = (arg.tilt < 0) ? 0 : (arg.tilt > 180) ? PI : arg.tilt * DEG;
      this.lambda = (arg.alt < -90) ? -PI : (arg.alt > 90) ? PI : arg.alt * DEG;
      this.beta = DEG * mod(-arg.az, 360);
    } else if (arg.ra !== undefined && arg.dec !== undefined && arg.tilt !== undefined) {
      this.sys = 1;
      this.tilt = (arg.tilt < 0) ? 0 : (arg.tilt > 180) ? PI : arg.tilt * DEG;
      this.lambda = (arg.dec < -90) ? -PI : (arg.dec > 90) ? PI : arg.dec * DEG;
      this.beta = HOUR_RAD * mod(arg.ra, 24);
    }
    this.doW();
  }

  // p.doW -- the circle's own frame (w matrix)
  doW() {
    const st = Math.sin(this.tilt), ct = Math.cos(this.tilt);
    const sb = Math.sin(this.beta), cb = Math.cos(this.beta);
    const cl = Math.cos(this.lambda), sl = Math.sin(this.lambda);
    const c = this.c;
    c.w0 = cl * cb;
    c.w1 = -cl * sb * ct;
    c.w2 = sl * sb * st;
    c.w3 = cl * sb;
    c.w4 = cl * cb * ct;
    c.w5 = -sl * cb * st;
    c.w7 = cl * st;
    c.w8 = sl * ct;
  }

  // The v matrix: w composed with the current view projection.
  // Returns [v0..v8] as a flat array.
  computeV() {
    const pc = this.sphere.c;
    const tc = this.c;
    if (this.sys === 0) {
      return [
        pc.a0 * tc.w0 + pc.a1 * tc.w3,
        pc.a0 * tc.w1 + pc.a1 * tc.w4,
        pc.a0 * tc.w2 + pc.a1 * tc.w5,
        pc.a3 * tc.w0 + pc.a4 * tc.w3,
        pc.a3 * tc.w1 + pc.a4 * tc.w4 + pc.a5 * tc.w7,
        pc.a3 * tc.w2 + pc.a4 * tc.w5 + pc.a5 * tc.w8,
        pc.a6 * tc.w0 + pc.a7 * tc.w3,
        pc.a6 * tc.w1 + pc.a7 * tc.w4 + pc.a8 * tc.w7,
        pc.a6 * tc.w2 + pc.a7 * tc.w5 + pc.a8 * tc.w8
      ];
    }
    return [
      pc.b0 * tc.w0 + pc.b1 * tc.w3,
      pc.b0 * tc.w1 + pc.b1 * tc.w4 + pc.b2 * tc.w7,
      pc.b0 * tc.w2 + pc.b1 * tc.w5 + pc.b2 * tc.w8,
      pc.b3 * tc.w0 + pc.b4 * tc.w3,
      pc.b3 * tc.w1 + pc.b4 * tc.w4 + pc.b5 * tc.w7,
      pc.b3 * tc.w2 + pc.b4 * tc.w5 + pc.b5 * tc.w8,
      pc.b6 * tc.w0 + pc.b7 * tc.w3,
      pc.b6 * tc.w1 + pc.b7 * tc.w4 + pc.b8 * tc.w7,
      pc.b6 * tc.w2 + pc.b7 * tc.w5 + pc.b8 * tc.w8
    ];
  }

  // Returns { front: [arc,...], back: [arc,...] }; each arc is
  // { sx, sy, segs:[{cx,cy,ax,ay}] } ready to feed quadraticCurveTo.
  buildArcs() {
    const out = { front: [], back: [] };
    if (!this.visible) return out;

    const v = this.computeV();
    const minStep = this.minStep;
    const push = (g1, g2, list) => list.push(arcFromV(g1, g2, minStep, v));

    const A = Math.sqrt(v[6] * v[6] + v[7] * v[7]);
    if (A === 0) {
      push(this.gS, this.gE, v[8] < 0 ? out.back : out.front);
      return out;
    }
    const sj = -v[8] / A;
    if (sj <= -1) { push(this.gS, this.gE, out.front); return out; }
    if (sj >= 1)  { push(this.gS, this.gE, out.back);  return out; }

    const j = Math.asin(sj);
    const t = Math.atan2(v[6], v[7]);
    let gDesc, gAsc;
    if (Math.cos(j) < 0) {
      gDesc = mod(j - t, TWO_PI);
      gAsc  = mod(PI - j - t, TWO_PI);
    } else {
      gDesc = mod(PI - j - t, TWO_PI);
      gAsc  = mod(j - t, TWO_PI);
    }

    if (this.gS === this.gE) {
      // Full circle: ascending->descending is the near half, the rest is far.
      push(gAsc, gDesc, out.front);
      push(gDesc, gAsc, out.back);
      return out;
    }

    // Partial arc: walk the four boundary angles in order, toggling
    // draw/front as each is crossed.
    const gArray = [[gAsc, 0], [gDesc, 1], [this.gS, 2], [this.gE, 3]];
    gArray.sort((a, b) => (a[0] < b[0] ? -1 : a[0] > b[0] ? 1 : 0));
    let draw = false, front = true;
    for (let k = 0; k < 4; k++) {
      const tag = gArray[k][1];
      if (tag === 0) front = true;
      else if (tag === 1) front = false;
      else if (tag === 2) draw = true;
      else draw = false;
    }
    let prev = gArray[3];
    for (let i = 0; i < 4; i++) {
      const g1 = prev;
      prev = gArray[i];
      if (draw && g1[0] !== prev[0]) push(g1[0], prev[0], front ? out.front : out.back);
      const tag = prev[1];
      if (tag === 0) front = true;
      else if (tag === 1) front = false;
      else if (tag === 2) draw = true;
      else draw = false;
    }
    return out;
  }
}

// The tessellated arc from "8 CS Circles.as" p.update -> inner drawArc().
// Flash approximates the arc with quadratic curves; canvas reproduces it
// exactly with quadraticCurveTo.
function arcFromV(g1, g2, minStep, v) {
  if (g2 < g1) g2 += TWO_PI;
  let arc = g2 - g1;
  if (arc === 0) arc = TWO_PI;
  const n = Math.ceil(arc / minStep);
  const step = arc / n;
  const halfStep = step / 2;
  const cRad = 1 / Math.cos(halfStep);
  const ax0 = Math.cos(g1), ay0 = Math.sin(g1);
  const result = {
    sx: v[0] * ax0 + v[1] * ay0 + v[2],
    sy: v[3] * ax0 + v[4] * ay0 + v[5],
    segs: []
  };
  let aAngle = g1 + step;
  let cAngle = aAngle - halfStep;
  for (let i = 0; i < n; i++) {
    const ax = Math.cos(aAngle), ay = Math.sin(aAngle);
    const cx = cRad * Math.cos(cAngle), cy = cRad * Math.sin(cAngle);
    result.segs.push({
      cx: v[0] * cx + v[1] * cy + v[2],
      cy: v[3] * cx + v[4] * cy + v[5],
      ax: v[0] * ax + v[1] * ay + v[2],
      ay: v[3] * ax + v[4] * ay + v[5]
    });
    aAngle += step;
    cAngle += step;
  }
  return result;
}

/* ---------------------------------------------------------------------------
   6. GlobeComponent -- the little Earth at the centre
      Ported from GlobeComponent.as.
   --------------------------------------------------------------------------- */

class GlobeComponent {
  constructor(sphere) {
    this.sphere = sphere;
    this.c = {};
    this.radius = GLOBE_RADIUS;
    this.shoreData = SHORE_DATA;
    this.sunDir = null;
    this.setPrecessionAngle(0);
    this.setRotationAngle(0);
  }

  // p.setSunDirection
  setSunDirection(arg) {
    this.sunDir = this.sphere.parsePointInput(arg, {});
  }

  // p.setPrecessionAngle -- 0.91706 / 0.39875 are cos/sin of the obliquity
  setPrecessionAngle(deg) {
    this.precessionAngle = deg;
    const a = deg * DEG;
    const cp = Math.cos(a), sp = Math.sin(a);
    const c = this.c;
    c.p0 = cp;
    c.p1 = -sp;
    c.p3 = sp * GLOBE_OBLIQUITY_COS;
    c.p4 = cp * GLOBE_OBLIQUITY_COS;
    c.p5 = -GLOBE_OBLIQUITY_SIN;
    c.p6 = sp * GLOBE_OBLIQUITY_SIN;
    c.p7 = cp * GLOBE_OBLIQUITY_SIN;
    c.p8 = GLOBE_OBLIQUITY_COS;
    this.doQ();
  }

  // p.setRotationAngle -- note the sidereal time is folded straight in
  setRotationAngle(deg) {
    this.rotationAngle = deg;
    const a = this.sphere._sTime + deg * DEG;
    const ca = Math.cos(a), sa = Math.sin(a);
    const c = this.c;
    c.r0 = ca;
    c.r1 = -sa;
    c.r3 = sa * GLOBE_OBLIQUITY_COS;
    c.r4 = ca * GLOBE_OBLIQUITY_COS;
    c.r5 = GLOBE_OBLIQUITY_SIN;
    c.r6 = -sa * GLOBE_OBLIQUITY_SIN;
    c.r7 = -ca * GLOBE_OBLIQUITY_SIN;
    c.r8 = GLOBE_OBLIQUITY_COS;
    this.doQ();
  }

  // q = p . r  (shared tail of setPrecessionAngle / setRotationAngle)
  doQ() {
    const c = this.c;
    if (c.r0 === undefined || c.p0 === undefined) return;
    c.q0 = c.p0 * c.r0 + c.p1 * c.r3;
    c.q1 = c.p0 * c.r1 + c.p1 * c.r4;
    c.q2 = c.p1 * c.r5;
    c.q3 = c.p3 * c.r0 + c.p4 * c.r3 + c.p5 * c.r6;
    c.q4 = c.p3 * c.r1 + c.p4 * c.r4 + c.p5 * c.r7;
    c.q5 = c.p4 * c.r5 + c.p5 * c.r8;
    c.q6 = c.p6 * c.r0 + c.p7 * c.r3 + c.p8 * c.r6;
    c.q7 = c.p6 * c.r1 + c.p7 * c.r4 + c.p8 * c.r7;
    c.q8 = c.p7 * c.r5 + c.p8 * c.r8;
  }

  // p.update -- builds the coastline outline used as a mask over the land disk
  buildShorePath() {
    const tc = this.c;
    const pc = this.sphere.c;
    const sf = this.radius / pc.r;
    const k0 = sf * (pc.b0 * tc.q0 + pc.b1 * tc.q3 + pc.b2 * tc.q6);
    const k1 = sf * (pc.b0 * tc.q1 + pc.b1 * tc.q4 + pc.b2 * tc.q7);
    const k2 = sf * (pc.b0 * tc.q2 + pc.b1 * tc.q5 + pc.b2 * tc.q8);
    const k3 = sf * (pc.b3 * tc.q0 + pc.b4 * tc.q3 + pc.b5 * tc.q6);
    const k4 = sf * (pc.b3 * tc.q1 + pc.b4 * tc.q4 + pc.b5 * tc.q7);
    const k5 = sf * (pc.b3 * tc.q2 + pc.b4 * tc.q5 + pc.b5 * tc.q8);
    const k6 = sf * (pc.b6 * tc.q0 + pc.b7 * tc.q3 + pc.b8 * tc.q6);
    const k7 = sf * (pc.b6 * tc.q1 + pc.b7 * tc.q4 + pc.b8 * tc.q7);
    const k8 = sf * (pc.b6 * tc.q2 + pc.b7 * tc.q5 + pc.b8 * tc.q8);

    const path = new Path2D();
    const s = this.shoreData;
    const r = this.radius;
    const d = 1.5 * r;
    const minStep = 2 * Math.acos((r * 1.1) / d);
    let angleLast = 0;

    for (let i = 0; i < s.length; i++) {
      const poly = s[i];
      const pl = poly.length;

      // Find the first vertex whose predecessor was also on the near side.
      let lastInFront = false;
      let sj = 0;
      for (; sj < pl; sj++) {
        const q = poly[sj];
        if (q.x * k6 + q.y * k7 + q.z * k8 > 0) {
          if (lastInFront) {
            path.moveTo(q.x * k0 + q.y * k1 + q.z * k2,
                        q.x * k3 + q.y * k4 + q.z * k5);
            break;
          }
          lastInFront = true;
        } else {
          lastInFront = false;
        }
      }
      if (sj === pl) continue;   // wholly on the far side: nothing to draw

      let ibLast = false;
      for (let j = 1; j < pl; j++) {
        const q = poly[(sj + j) % pl];
        const ibNow = (q.x * k6 + q.y * k7 + q.z * k8) < 0;
        if (!ibNow) {
          const sx = q.x * k0 + q.y * k1 + q.z * k2;
          const sy = q.x * k3 + q.y * k4 + q.z * k5;
          if (ibLast) {
            // Coming back into view: follow the limb from where we left it.
            const angleNow = Math.atan2(sy, sx);
            let da = mod(angleNow - angleLast, TWO_PI);
            let n, step;
            if (da > PI) {
              da = TWO_PI - da;
              n = Math.ceil(da / minStep);
              step = -da / n;
            } else {
              n = Math.ceil(da / minStep);
              step = da / n;
            }
            for (let m = 1; m <= n; m++) {
              const angle = angleLast + step * m;
              path.lineTo(d * Math.cos(angle), d * Math.sin(angle));
            }
            path.lineTo(sx, sy);
          } else {
            path.lineTo(sx, sy);
          }
        } else if (!ibLast) {
          // Going behind the limb: step out to the limb radius and remember it.
          const x = q.x * k0 + q.y * k1 + q.z * k2;
          const y = q.x * k3 + q.y * k4 + q.z * k5;
          angleLast = Math.atan2(y, x);
          path.lineTo(d * Math.cos(angleLast), d * Math.sin(angleLast));
        }
        ibLast = ibNow;
      }
      path.closePath();
    }
    return path;
  }

  // p.updateShading -- the night-side crescent
  buildNightSide() {
    const sd = this.sunDir;
    if (!sd) return null;
    const sp = {};
    if (sd.sys === 1) this.sphere.CtoSz(sd, sp);
    else this.sphere.WtoSz(sd, sp);

    const rotation = Math.atan2(sp.x, -sp.y);
    const s = -sp.z / Math.sqrt(sp.x * sp.x + sp.y * sp.y + sp.z * sp.z);

    const hnp = 4;
    const step = PI / hnp;
    const halfStep = step / 2;
    const r = this.radius;
    const cr = r / Math.cos(halfStep);

    const path = new Path2D();
    path.moveTo(r, 0);
    let aAngle = step;
    let cAngle = step - halfStep;
    for (let i = 0; i < hnp; i++) {
      path.quadraticCurveTo(cr * Math.cos(cAngle), cr * Math.sin(cAngle),
                            r * Math.cos(aAngle),  r * Math.sin(aAngle));
      aAngle += step; cAngle += step;
    }
    for (let i = 0; i < hnp; i++) {
      path.quadraticCurveTo(cr * Math.cos(cAngle), s * cr * Math.sin(cAngle),
                            r * Math.cos(aAngle),  s * r * Math.sin(aAngle));
      aAngle += step; cAngle += step;
    }
    path.closePath();
    return { path, rotation };
  }
}

/* ---------------------------------------------------------------------------
   7. ZodiacViewer -- the simulation itself
      Ported from ZodiacViewer.as.
   --------------------------------------------------------------------------- */

// Constellation label centres, verbatim from ZodiacViewerClass().
const CONSTELLATION_LABELS = [
  { key: 'lib', text: 'Libra',       ra: 14.9, dec: -29.6 },
  { key: 'tau', text: 'Taurus',      ra: 4.1,  dec: 22.8  },
  { key: 'aqr', text: 'Aquarius',    ra: 22.2, dec: 3.2   },
  { key: 'sco', text: 'Scorpius',    ra: 16.9, dec: -22   },
  { key: 'psc', text: 'Pisces',      ra: 0.7,  dec: -0.6  },
  { key: 'ari', text: 'Aries',       ra: 2.5,  dec: 16.3  },
  { key: 'cnc', text: 'Cancer',      ra: 8.8,  dec: 8.6   },
  { key: 'leo', text: 'Leo',         ra: 10.6, dec: 7.6   },
  { key: 'gem', text: 'Gemini',      ra: 6.7,  dec: 33.3  },
  { key: 'sgr', text: 'Sagittarius', ra: 18.5, dec: -16.1 },
  { key: 'cap', text: 'Capricornus', ra: 21.3, dec: -28.6 },
  { key: 'vir', text: 'Virgo',       ra: 13.2, dec: -14.7 }
];

// The label "up" reference: the ecliptic pole, {ra: 18, dec: 66.56}.
const LABEL_UP_REFERENCE = { ra: 18, dec: 66.56 };

class ZodiacViewer {
  constructor() {
    const sphere = new CelestialSphere();
    this.sphere = sphere;

    // ZodiacViewerClass() constructor order
    sphere.maxPhi = MAX_VIEWER_ALTITUDE;
    sphere.minPhi = MIN_VIEWER_ALTITUDE;
    sphere.setTheta(INIT_THETA);

    this.sunDisk = new CSObject(sphere, 'sunDisk');
    this.sunDisk.setPosition({ ra: 0, dec: 0 });

    this.labels = CONSTELLATION_LABELS.map((def) => {
      const obj = new CSObject(sphere, def.key);
      obj.text = def.text;
      obj.setPosition({ ra: def.ra, dec: def.dec });
      // setOrientationType("absolute", {ra: ra+12, dec: -dec}, eclipticPole)
      obj.setAbsoluteOrientation({ ra: def.ra + 12, dec: -def.dec },
                                 LABEL_UP_REFERENCE);
      return obj;
    });

    this.globeObject = new CSObject(sphere, 'globe');
    this.globeObject.setPosition({ ra: 0, dec: 0, r: INIT_EARTH_ORBIT_SIZE / INIT_ZODIAC_SIZE });
    this.globe = new GlobeComponent(sphere);

    sphere.setSiderealTime(SIDEREAL_TIME);
    sphere.setLatitude(LATITUDE);

    // addCircle("bandCircle", ..., {alt: 24, az: 0, tilt: 0}); visible = false
    this.bandCircle = new CSCircle(sphere, 'bandCircle');
    this.bandCircle.setStyle(1, '#ff0000', 100);
    this.bandCircle.setParameters({ alt: ZODIAC_BAND_HALF_ANGLE, az: 0, tilt: 0 });
    this.bandCircle.visible = false;

    // addCircle("ecliptic", {thickness:1, color:5263440, alpha:100},
    //           {dec:0, ra:0, tilt:23.5})
    this.ecliptic = new CSCircle(sphere, 'ecliptic');
    this.ecliptic.setStyle(1, ECLIPTIC_COLOR, 100);
    this.ecliptic.setParameters({ dec: 0, ra: 0, tilt: ECLIPTIC_TILT });

    sphere.size = INIT_ZODIAC_SIZE;
    this.setDayOfYear(0);
  }

  // p.setDayOfYear -- the geometry wraps at 365, but the control keeps the
  // value the user actually chose, exactly as the Flash slider does: dragging
  // the grabber to the far right leaves it there while the sky shows day 0.
  setDayOfYear(day) {
    this.dayInput = day;
    this.dayOfYear = mod(day, 365);
    this.updateGlobe();
  }

  // p.setMonthAndDay -- month is 1-based, dayOfMonth is 1-based
  setMonthAndDay(month, dayOfMonth) {
    this.setDayOfYear(mod(MONTH_FIRST_DAY[month - 1] + dayOfMonth - 1, 365));
  }

  // p.updateGlobe -- the whole date -> geometry chain
  updateGlobe() {
    // az = -(360/365) * (dayOfYear + 10.8)
    const az = -0.9863013698630136 * (this.dayOfYear + 10.8);
    this.earthAzimuth = az;

    this.globeObject.setPosition({ az: az, alt: 0, r: 0.001 });
    this.sunDisk.setPosition({ az: az + 180, alt: 0, r: 0.9999 });
    this.sunDisk.setAbsoluteOrientation();

    this.globe.setSunDirection({ az: az + 180, alt: 0 });
    // The Earth turns 366.25/365.25 times per year relative to the stars.
    const turns = this.dayOfYear * 1.0027397260273974;
    this.globe.setRotationAngle((turns % 1) * 360);
  }

  // Called after any view change; keeps the globe's spin locked to sidereal time.
  refresh() {
    this.globe.setRotationAngle(this.globe.rotationAngle);
  }

  /* --- depth sorting (p.updateObjectsSort, "7 CS Objects.as") ------------- */
  // Returns the objects grouped into the AS depth bands, each sorted by
  // screen z ascending (farthest first).
  sortedObjects() {
    const sphere = this.sphere;
    const bS = [], fS = [], bI = [], aI = [];

    const place = (obj) => {
      if (obj.r < 1) {
        // Inside the sphere: sorted by the HORIZON-frame z (above/below).
        const wp = (obj.sys === 1) ? sphere.CtoW(obj.p, {}) : obj.p;
        sphere.WtoSz(wp, obj.sp);
        (wp.z < 0 ? bI : aI).push(obj);
      } else {
        // On (or outside) the surface: split by screen z.
        if (obj.sys === 1) sphere.CtoSz(obj.p, obj.sp);
        else sphere.WtoSz(obj.p, obj.sp);
        (obj.sp.z < 0 ? bS : fS).push(obj);
      }
      obj.update();
    };

    place(this.sunDisk);
    place(this.globeObject);
    this.labels.forEach(place);

    const byZ = (a, b) => (a.sp.z < b.sp.z ? -1 : a.sp.z === b.sp.z ? 0 : 1);
    bS.sort(byZ); fS.sort(byZ); bI.sort(byZ); aI.sort(byZ);
    return { bS, fS, bI, aI };
  }

  /* --- p.updateConstellations -------------------------------------------- */
  // Returns { front: [[{x,y},...],...], back: [...] } -- polylines in screen px.
  buildConstellations() {
    const c = this.sphere.c;
    const front = [], back = [];
    const data = CONSTELLATION_DATA;

    for (let i = 0; i < data.length; i++) {
      const curves = data[i].path;
      const points = data[i].stars;
      for (let j = 0; j < curves.length; j++) {
        const stroke = curves[j];
        let s = points[stroke.m];
        let lx = c.b0 * s.x + c.b1 * s.y + c.b2 * s.z;
        let ly = c.b3 * s.x + c.b4 * s.y + c.b5 * s.z;
        let lif = (c.b6 * s.x + c.b7 * s.y + c.b8 * s.z) > 0;
        let poly = { pts: [{ x: lx, y: ly }] };
        (lif ? front : back).push(poly);

        for (let k = stroke.b; k < stroke.e; k++) {
          s = points[k];
          const tx = c.b0 * s.x + c.b1 * s.y + c.b2 * s.z;
          const ty = c.b3 * s.x + c.b4 * s.y + c.b5 * s.z;
          const tif = (c.b6 * s.x + c.b7 * s.y + c.b8 * s.z) > 0;
          if (tif !== lif) {
            // The segment crosses the limb: it is drawn on the side it ends on,
            // starting from the previous point (exactly as the AS does).
            poly = { pts: [{ x: lx, y: ly }, { x: tx, y: ty }] };
            (tif ? front : back).push(poly);
          } else {
            poly.pts.push({ x: tx, y: ty });
          }
          lx = tx; ly = ty; lif = tif;
        }
      }
    }
    return { front, back };
  }

  /* --- p.updateZodiacBand ------------------------------------------------- */
  // Returns the two linear gradients (as stop lists) for the back and front
  // surfaces, plus which way round they go.
  buildBandGradients() {
    const sphere = this.sphere;
    const az = this.globeObject.az - 90;
    const width = BAND_HALF_WIDTH_DEG;
    const sp = {};

    sphere.toScreen({ alt: 0, az: az }, sp);
    const inFront = sp.z > 0;
    sphere.toScreen({ alt: 0, az: az - width }, sp);
    const darkX = sp.x;
    sphere.toScreen({ alt: 0, az: az + width }, sp);
    const lightX = sp.x;

    const size = sphere.size;
    const half = size / 2;
    const k = 256 / size;

    let colors1, ratios1, colors2, ratios2;
    if (darkX > lightX) {
      colors1 = [BAND_LIGHT, BAND_LIGHT, BAND_DARK, BAND_DARK];
      ratios1 = [0, k * (lightX + half), k * (darkX + half), 255];
      colors2 = [BAND_DARK, BAND_DARK, BAND_LIGHT, BAND_LIGHT];
      ratios2 = [0, k * (lightX + half), k * (darkX + half), 255];
    } else {
      colors1 = [BAND_DARK, BAND_DARK, BAND_LIGHT, BAND_LIGHT];
      ratios1 = [0, k * (darkX + half), k * (lightX + half), 255];
      colors2 = [BAND_LIGHT, BAND_LIGHT, BAND_DARK, BAND_DARK];
      ratios2 = [0, k * (darkX + half), k * (lightX + half), 255];
    }

    // matrix1 has rotation pi (gradient runs right->left), matrix2 rotation 0.
    const g1 = { colors: colors1, ratios: ratios1, reversed: true };
    const g2 = { colors: colors2, ratios: ratios2, reversed: false };
    return inFront ? { back: g1, front: g2 } : { back: g2, front: g1 };
  }

  /* --- p.drawZodiacBandMasks --------------------------------------------- */
  // Builds the closed outline of the zodiac band. The same point list is used
  // for both surfaces; the front copy has its y coordinates negated.
  buildBandMaskPoints() {
    const sphere = this.sphere;
    const v = this.bandCircle.computeV();
    const [v0, v1, v2, v3, v4, v5, v6, v7, v8] = v;

    const minPoints = 10;
    const minStep = TWO_PI / minPoints;
    const A = Math.sqrt(v6 * v6 + v7 * v7);
    if (A === 0) return null;
    const sj = -v8 / A;
    if (!(sj > -1 && sj < 1)) return null;

    const j = Math.asin(sj);
    const t = Math.atan2(v6, v7);
    let gDesc, gAsc;
    if (Math.cos(j) < 0) {
      gDesc = mod(j - t, TWO_PI);
      gAsc  = mod(PI - j - t, TWO_PI);
    } else {
      gDesc = mod(PI - j - t, TWO_PI);
      gAsc  = mod(j - t, TWO_PI);
    }

    const points = [];
    const p1 = {
      x: v0 * Math.cos(gDesc) + v1 * Math.sin(gDesc) + v2,
      y: v3 * Math.cos(gDesc) + v4 * Math.sin(gDesc) + v5
    };

    // Segment 1: the band circle from its descending to its ascending node.
    sweep(gDesc, gAsc, minStep, 1, (ax, ay, cx, cy) => {
      points.push({
        cx: v0 * cx + v1 * cy + v2, cy: v3 * cx + v4 * cy + v5,
        ax: v0 * ax + v1 * ay + v2, ay: v3 * ax + v4 * ay + v5
      });
    });
    const index2 = points.length;

    // Segment 2: around the limb of the sphere.
    const r = sphere.size / 2;
    sweep(mod(Math.atan2(-p1.y, -p1.x), TWO_PI),
          mod(Math.atan2(p1.y, -p1.x), TWO_PI), minStep, r,
          (ax, ay, cx, cy) => {
            points.push({ cx: cx, cy: -cy, ax: ax, ay: -ay });
          });
    const index3 = points.length;

    // Segment 3: the band circle back again, mirrored in y.
    sweep(gAsc, gDesc, minStep, 1, (ax, ay, cx, cy) => {
      points.push({
        cx: v0 * cx + v1 * cy + v2, cy: -(v3 * cx + v4 * cy + v5),
        ax: v0 * ax + v1 * ay + v2, ay: -(v3 * ax + v4 * ay + v5)
      });
    });

    // Segment 4: the limb again, point-reflected through the centre.
    for (let i = index2; i < index3; i++) {
      const q = points[i];
      points.push({ ax: -q.ax, ay: -q.ay, cx: -q.cx, cy: -q.cy });
    }
    return points;
  }
}

// Shared tessellation helper for drawZodiacBandMasks: walks g1 -> g2 in
// quadratic steps, handing back raw (anchor, control) pairs scaled by `rad`.
function sweep(g1, g2, minStep, rad, emit) {
  if (g2 < g1) g2 += TWO_PI;
  let arc = g2 - g1;
  if (arc === 0) arc = TWO_PI;
  const n = Math.ceil(arc / minStep);
  const step = arc / n;
  const halfStep = step / 2;
  const cRad = rad / Math.cos(halfStep);
  let aAngle = g1 + step;
  let cAngle = aAngle - halfStep;
  for (let i = 0; i < n; i++) {
    emit(rad * Math.cos(aAngle), rad * Math.sin(aAngle),
         cRad * Math.cos(cAngle), cRad * Math.sin(cAngle));
    aAngle += step;
    cAngle += step;
  }
}

/* ---------------------------------------------------------------------------
   8. Rendering
   --------------------------------------------------------------------------- */

// Exported vector art, reused as-is from the JPEXS export (never redrawn):
//   shape-1.svg  GlobeComponentWater   shape-3.svg  GlobeComponentLand
//   shape-49.svg Symbol 65 (front haze) shape-51.svg Symbol 64 (back haze)
//   shape-55.svg Sun Disk
const ART = {
  water: 'assets/shape-1.svg',
  land:  'assets/shape-3.svg',
  hazeFront: 'assets/shape-49.svg',
  hazeBack:  'assets/shape-51.svg',
  sun:   'assets/shape-55.svg'
};
const images = {};

function loadArt() {
  const jobs = Object.keys(ART).map((key) => new Promise((resolve) => {
    const img = new Image();
    img.onload = () => { images[key] = img; resolve(); };
    img.onerror = () => { images[key] = null; resolve(); };
    img.src = ART[key];
  }));
  return Promise.all(jobs);
}

// Turns a Flash gradient stop list into a canvas linear gradient across the
// 600 px square, matching the {matrixType:"box", w:600, r:0|pi} matrices.
function bandGradient(ctx, spec, half) {
  const g = spec.reversed
    ? ctx.createLinearGradient(half, 0, -half, 0)
    : ctx.createLinearGradient(-half, 0, half, 0);
  let last = -1;
  for (let i = 0; i < spec.colors.length; i++) {
    let stop = spec.ratios[i] / 255;
    if (stop < 0) stop = 0;
    if (stop > 1) stop = 1;
    if (stop < last) stop = last;      // canvas requires non-decreasing offsets
    last = stop;
    g.addColorStop(stop, `rgba(${spec.colors[i]},${BAND_ALPHA})`);
  }
  return g;
}

function tracePoints(ctx, points, flipY) {
  const s = flipY ? -1 : 1;
  const last = points[points.length - 1];
  ctx.moveTo(last.ax, s * last.ay);
  for (let i = 0; i < points.length; i++) {
    const q = points[i];
    ctx.quadraticCurveTo(q.cx, s * q.cy, q.ax, s * q.ay);
  }
  ctx.closePath();
}

function strokeArcs(ctx, arcs, color, width, alpha) {
  if (!arcs.length) return;
  ctx.save();
  ctx.globalAlpha = alpha;
  ctx.strokeStyle = color;
  ctx.lineWidth = width;
  ctx.beginPath();
  for (const arc of arcs) {
    ctx.moveTo(arc.sx, arc.sy);
    for (const seg of arc.segs) ctx.quadraticCurveTo(seg.cx, seg.cy, seg.ax, seg.ay);
  }
  ctx.stroke();
  ctx.restore();
}

function strokePolylines(ctx, polys, color) {
  ctx.save();
  ctx.strokeStyle = color;
  ctx.lineWidth = 1;
  ctx.beginPath();
  for (const poly of polys) {
    if (poly.pts.length < 2) continue;
    ctx.moveTo(poly.pts[0].x, poly.pts[0].y);
    for (let i = 1; i < poly.pts.length; i++) ctx.lineTo(poly.pts[i].x, poly.pts[i].y);
  }
  ctx.stroke();
  ctx.restore();
}

function drawLabels(ctx, objects) {
  ctx.save();
  ctx.font = LABEL_FONT;
  ctx.fillStyle = LABEL_COLOR;
  ctx.textAlign = 'center';
  ctx.textBaseline = 'middle';
  for (const obj of objects) {
    if (!obj.text) continue;
    ctx.save();
    ctx.translate(obj.sp.x, obj.sp.y);
    ctx.rotate(obj.rotation);
    // The AS applies the foreshortening as _yscale on the shell; a zero or
    // near-zero scale collapses the label to nothing, so skip those.
    if (Math.abs(obj.yScale) > 1e-4) {
      ctx.scale(1, obj.yScale);
      ctx.rotate(obj.innerRotation);
      // Text field origin offset (see texts/47.txt placement: -67, -8.4 for a
      // 136 x 20 centred field).
      ctx.fillText(obj.text, 1, 2.5);
    }
    ctx.restore();
  }
  ctx.restore();
}

function drawSun(ctx, obj) {
  const img = images.sun;
  if (!img) return;
  ctx.save();
  ctx.translate(obj.sp.x, obj.sp.y);
  ctx.rotate(obj.rotation);
  ctx.scale(1, obj.yScale === 0 ? 1e-6 : obj.yScale);
  ctx.rotate(obj.innerRotation);
  ctx.drawImage(img, -8, -8, 16, 16);   // Sun Disk shape is 16 x 16, centred
  ctx.restore();
}

function drawGlobe(ctx, viewer) {
  const obj = viewer.globeObject;
  const globe = viewer.globe;
  ctx.save();
  ctx.translate(obj.sp.x, obj.sp.y);
  ctx.rotate(obj.rotation);
  ctx.scale(1, obj.yScale === 0 ? 1e-6 : obj.yScale);

  // globe clip (depth 10): water disk, then land clipped to the coastlines
  ctx.save();
  ctx.scale(GLOBE_SCALE, GLOBE_SCALE);
  if (images.water) ctx.drawImage(images.water, -40, -40, 80, 80);
  if (images.land) {
    ctx.save();
    ctx.clip(globe.buildShorePath());
    ctx.drawImage(images.land, -40, -40, 80, 80);
    ctx.restore();
  }
  ctx.restore();

  // nightSide clip (depth 15): beginFill(0, 60)
  const night = globe.buildNightSide();
  if (night) {
    ctx.save();
    ctx.scale(GLOBE_SCALE, GLOBE_SCALE);
    ctx.rotate(night.rotation);
    ctx.fillStyle = 'rgba(0,0,0,0.6)';
    ctx.fill(night.path);
    ctx.restore();
  }
  ctx.restore();
}

function render(ctx, viewer) {
  const sphere = viewer.sphere;
  const half = sphere.size / 2;

  ctx.save();
  ctx.setTransform(1, 0, 0, 1, 0, 0);
  ctx.scale(state.dpr, state.dpr);
  ctx.fillStyle = '#000000';           // SetBackgroundColor 00 00 00
  ctx.fillRect(0, 0, CANVAS_SIZE, CANVAS_SIZE);
  ctx.translate(ORIGIN_X, ORIGIN_Y);

  viewer.refresh();
  const buckets = viewer.sortedObjects();
  const constellations = viewer.buildConstellations();
  const eclipticArcs = viewer.ecliptic.buildArcs();
  const maskPoints = viewer.buildBandMaskPoints();
  const gradients = viewer.buildBandGradients();

  // --- backSurface (depth 45), clipped to the far half of the band ---------
  if (maskPoints) {
    ctx.save();
    ctx.beginPath();
    tracePoints(ctx, maskPoints, false);
    ctx.clip();
    ctx.fillStyle = bandGradient(ctx, gradients.back, half);
    ctx.fillRect(-half, -half, sphere.size, sphere.size);
    if (images.hazeBack) ctx.drawImage(images.hazeBack, -half, -half, sphere.size, sphere.size);
    ctx.restore();
  }

  // --- celestialSphere (depth 100), in AS depth order ---------------------
  strokeArcs(ctx, eclipticArcs.back, viewer.ecliptic.color,
             viewer.ecliptic.thickness, viewer.ecliptic.alpha);   // _bC  = 1999
  drawLabels(ctx, buckets.bS);                                    // bS   = 2000+
  strokePolylines(ctx, constellations.back, CONSTELLATIONS_COLOR); // 2N-20 = 3980
  for (const obj of buckets.bI) drawInner(ctx, viewer, obj);      // bI   = 4000+
  for (const obj of buckets.aI) drawInner(ctx, viewer, obj);      // aI   = 6000+
  strokeArcs(ctx, eclipticArcs.front, viewer.ecliptic.color,
             viewer.ecliptic.thickness, viewer.ecliptic.alpha);   // _fC  = 7999
  drawLabels(ctx, buckets.fS);                                    // fS   = 8000+
  strokePolylines(ctx, constellations.front, CONSTELLATIONS_COLOR); // 5N-20 = 9980

  // --- frontSurface (depth 145), clipped to the near half of the band -----
  if (maskPoints) {
    ctx.save();
    ctx.beginPath();
    tracePoints(ctx, maskPoints, true);
    ctx.clip();
    ctx.fillStyle = bandGradient(ctx, gradients.front, half);
    ctx.fillRect(-half, -half, sphere.size, sphere.size);
    if (images.hazeFront) ctx.drawImage(images.hazeFront, -half, -half, sphere.size, sphere.size);
    ctx.restore();
  }

  ctx.restore();
}

function drawInner(ctx, viewer, obj) {
  if (obj === viewer.globeObject) drawGlobe(ctx, viewer);
  else if (obj === viewer.sunDisk) drawSun(ctx, obj);
}

/* ---------------------------------------------------------------------------
   9. State, DOM wiring and narration
   --------------------------------------------------------------------------- */

const state = {
  viewer: null,
  ctx: null,
  canvas: null,
  dpr: 1,
  needsRender: false,
  editing: null        // the field currently being typed into, if any
};

const el = {};

function $(id) { return document.getElementById(id); }

function cacheElements() {
  ['stage', 'stage-canvas', 'stage-desc', 'sim-status',
   'day-range', 'day-number', 'month-select', 'dom-number',
   'azimuth-range', 'azimuth-number',
   'elevation-range', 'elevation-number',
   'sun-ra-readout', 'sun-dec-readout', 'sun-near-readout', 'sun-sep-readout',
   'timeline', 'timeline-months'].forEach((id) => { el[id] = $(id); });
}

/* --- date helpers (p.setMonthAndDay table) ------------------------------- */

function monthIndexForDay(day) {
  const d = Math.floor(mod(day, 365));
  let m = 11;
  for (let i = 0; i < 12; i++) {
    if (d < MONTH_FIRST_DAY[i]) { m = i - 1; break; }
  }
  return m < 0 ? 0 : m;
}

function calendarDate(day) {
  const d = Math.floor(mod(day, 365));
  const m = monthIndexForDay(d);
  return { month: m, dayOfMonth: d - MONTH_FIRST_DAY[m] + 1 };
}

// Length of each month in the 365-day table the simulation uses.
function monthLength(monthIndex) {
  const next = (monthIndex === 11) ? 365 : MONTH_FIRST_DAY[monthIndex + 1];
  return next - MONTH_FIRST_DAY[monthIndex];
}

function formatDate(day) {
  const c = calendarDate(day);
  return `${MONTH_NAMES[c.month]} ${c.dayOfMonth}`;
}

/* --- spoken value strings (always quantity + number + unit) -------------- */

// Units are spelled out as words so screen readers say them rather than
// skipping a symbol, and singular/plural is honoured so the speech reads
// naturally.
function plural(value, unit) {
  return `${value} ${Math.abs(value) === 1 ? unit : unit + 's'}`;
}

function raWords(hours) {
  const h = Math.floor(hours);
  const m = Math.round((hours - h) * 60);
  const hh = (m === 60) ? h + 1 : h;
  const mm = (m === 60) ? 0 : m;
  return `${plural(mod(hh, 24), 'hour')} ${plural(mm, 'minute')}`;
}

function degWords(deg) {
  const v = Math.round(deg * 10) / 10;
  return v < 0 ? `minus ${plural(Math.abs(v), 'degree')}` : plural(v, 'degree');
}

/* --- the nearest zodiac label to the Sun (a geometric readout, not an
       IAU constellation-boundary lookup -- see ACCESSIBILITY.md) ---------- */

function nearestLabelToSun(viewer) {
  const sun = viewer.sunDisk.p;
  const mag = Math.sqrt(sun.x * sun.x + sun.y * sun.y + sun.z * sun.z);
  const sunC = viewer.sphere.WtoC(sun, {});
  let best = null, bestDot = -2;
  for (const obj of viewer.labels) {
    const p = obj.p;
    const dot = (sunC.x * p.x + sunC.y * p.y + sunC.z * p.z) / mag;
    if (dot > bestDot) { bestDot = dot; best = obj; }
  }
  return { text: best.text, separation: RAD * Math.acos(Math.min(1, Math.max(-1, bestDot))) };
}

/* --- syncing the DOM from state ----------------------------------------- */

// Write a value into a control, except into the one field the user is actually
// typing in right now -- rewriting that would move the caret and fight the
// typing. Every other control, and every change from anywhere else (Reset, a
// drag, the wheel), still syncs.
function setFieldValue(field, value) {
  if (field === state.editing) return;
  const next = String(value);
  if (field.value === next) return;
  field.value = next;
}

function syncControls() {
  const viewer = state.viewer;
  const sphere = viewer.sphere;
  const day = Math.round(viewer.dayInput);
  const dateText = formatDate(viewer.dayOfYear);
  const cal = calendarDate(viewer.dayOfYear);
  const azimuth = Math.round(sphere.viewerAzimuth);
  const elevation = Math.round(sphere.phi);

  // setFieldValue leaves a field alone while the user is typing in it, so the
  // caret is never yanked around mid-edit.
  setFieldValue(el['day-range'], day);
  el['day-range'].setAttribute('aria-valuetext',
    `Day ${day} of the year, ${dateText}`);
  setFieldValue(el['day-number'], day);

  setFieldValue(el['month-select'], cal.month + 1);
  el['dom-number'].max = String(monthLength(cal.month));
  setFieldValue(el['dom-number'], cal.dayOfMonth);

  setFieldValue(el['azimuth-range'], azimuth);
  el['azimuth-range'].setAttribute('aria-valuetext',
    `View azimuth ${plural(azimuth, 'degree')}`);
  setFieldValue(el['azimuth-number'], azimuth);

  setFieldValue(el['elevation-range'], elevation);
  el['elevation-range'].setAttribute('aria-valuetext',
    `View elevation ${degWords(elevation)}`);
  setFieldValue(el['elevation-number'], elevation);

  const sun = sphere.pointToCelestial(viewer.sunDisk.p, {});
  el['sun-ra-readout'].textContent = raWords(sun.ra);
  el['sun-dec-readout'].textContent = degWords(sun.dec);
  const near = nearestLabelToSun(viewer);
  el['sun-near-readout'].textContent = near.text;
  el['sun-sep-readout'].textContent = plural(Math.round(near.separation), 'degree');

  el['stage-desc'].textContent = describeScene();
  positionTimelineMarker();
}

// The text equivalent of the picture, for anyone working from audio alone.
function describeScene() {
  const viewer = state.viewer;
  const sphere = viewer.sphere;
  const sun = sphere.pointToCelestial(viewer.sunDisk.p, {});
  const near = nearestLabelToSun(viewer);
  const front = viewer.labels
    .filter((obj) => obj.sp.z >= 0)
    .map((obj) => obj.text);
  return [
    `Day ${Math.round(viewer.dayInput)} of the year, ${formatDate(viewer.dayOfYear)}.`,
    `Earth sits at the centre of the zodiac band; the Sun is on the band at`,
    `right ascension ${raWords(sun.ra)}, declination ${degWords(sun.dec)},`,
    `closest to the ${near.text} label, ${plural(Math.round(near.separation), 'degree')} away.`,
    `The view looks along azimuth ${plural(Math.round(sphere.viewerAzimuth), 'degree')}`,
    `from an elevation of ${degWords(sphere.phi)}.`,
    front.length
      ? `Constellations on the near side of the band: ${front.join(', ')}.`
      : `No constellation labels are on the near side of the band.`
  ].join(' ');
}

let announceTimer = null;
function announce(message) {
  window.clearTimeout(announceTimer);
  // A short delay coalesces rapid changes so the screen reader is not flooded.
  announceTimer = window.setTimeout(() => {
    el['sim-status'].textContent = message;
  }, 150);
}

function requestRender() {
  if (state.needsRender) return;
  state.needsRender = true;
  window.requestAnimationFrame(() => {
    state.needsRender = false;
    render(state.ctx, state.viewer);
  });
}

function update({ announceText } = {}) {
  // Refresh every object's screen position first: the readouts and the text
  // description below are written from the same numbers the canvas draws.
  state.viewer.sortedObjects();
  syncControls();
  requestRender();
  if (announceText) announce(announceText);
}

/* --- canvas sizing ------------------------------------------------------- */

function resizeCanvas() {
  const canvas = el['stage-canvas'];
  const dpr = window.devicePixelRatio || 1;
  state.dpr = dpr;
  canvas.width = Math.round(CANVAS_SIZE * dpr);
  canvas.height = Math.round(CANVAS_SIZE * dpr);
  requestRender();
}

// Every numeric field also steps on the mouse wheel while it is focused, by
// the same amount as an arrow key. preventDefault stops the page scrolling.
function addWheelStepping(field, setter) {
  field.addEventListener('wheel', (event) => {
    if (document.activeElement !== field) return;
    event.preventDefault();
    const step = Number(field.step) || 1;
    const min = Number(field.min);
    const max = Number(field.max);
    const current = Number(field.value) || 0;
    const next = Math.min(max, Math.max(min, current + (event.deltaY < 0 ? step : -step)));
    field.value = String(next);
    setter(next);
    update({ announceText: describeScene() });
  }, { passive: false });
}

/* --- pointer drag on the sphere (p.startSimpleDragging / p.updateSimpleDragging) --- */

let drag = null;

function stageCoords(event) {
  const canvas = el['stage-canvas'];
  const rect = canvas.getBoundingClientRect();
  // Map the pointer back through the CSS scale so the drag maths runs in
  // original Flash stage pixels at any display size.
  const scale = CANVAS_SIZE / rect.width;
  return {
    x: (event.clientX - rect.left) * scale - ORIGIN_X,
    y: (event.clientY - rect.top) * (CANVAS_SIZE / rect.height) - ORIGIN_Y
  };
}

function onPointerDown(event) {
  const sphere = state.viewer.sphere;
  const p = stageCoords(event);
  // The AS mouse area is the sphere disk; presses outside it do nothing.
  if (Math.sqrt(p.x * p.x + p.y * p.y) > sphere.c.r) return;
  el.stage.focus();                        // click-to-focus, so arrows work next
  drag = {
    id: event.pointerId,
    x: p.x, y: p.y,
    theta: sphere._theta,
    phi: sphere._phi
  };
  el.stage.setPointerCapture(event.pointerId);
  event.preventDefault();
}

function onPointerMove(event) {
  if (!drag || event.pointerId !== drag.id) return;
  const sphere = state.viewer.sphere;
  const p = stageCoords(event);
  sphere.setThetaAndPhi(
    RAD * (drag.theta - (p.x - drag.x) / sphere.c.r),
    RAD * (drag.phi + (p.y - drag.y) / sphere.c.r)
  );
  update();
  event.preventDefault();
}

function onPointerUp(event) {
  if (!drag || event.pointerId !== drag.id) return;
  el.stage.releasePointerCapture(drag.id);
  drag = null;
  announce(describeScene());
}

/* --- keyboard on the sphere (the equivalent of dragging) ----------------- */

const VIEW_STEP = 1;        // degrees per arrow press
const VIEW_STEP_BIG = 15;   // degrees per Page / Shift+arrow press

function onStageKeyDown(event) {
  const sphere = state.viewer.sphere;
  const big = event.shiftKey;
  const step = big ? VIEW_STEP_BIG : VIEW_STEP;
  let handled = true;

  switch (event.key) {
    case 'ArrowLeft':  sphere.setViewerAzimuth(mod(sphere.viewerAzimuth - step, 360)); break;
    case 'ArrowRight': sphere.setViewerAzimuth(mod(sphere.viewerAzimuth + step, 360)); break;
    case 'ArrowUp':    sphere.setPhi(sphere.phi + step); break;
    case 'ArrowDown':  sphere.setPhi(sphere.phi - step); break;
    case 'PageUp':     sphere.setPhi(sphere.phi + VIEW_STEP_BIG); break;
    case 'PageDown':   sphere.setPhi(sphere.phi - VIEW_STEP_BIG); break;
    case 'Home':       sphere.setPhi(MIN_VIEWER_ALTITUDE); break;
    case 'End':        sphere.setPhi(MAX_VIEWER_ALTITUDE); break;
    default: handled = false;
  }
  if (!handled) return;     // Tab and everything else pass straight through
  event.preventDefault();
  update({ announceText: describeScene() });
}

/* --- the timeline (Modified Year Slider) --------------------------------- */

function buildTimeline() {
  const host = el['timeline-months'];
  // Month boundaries at scaleFactor * MONTH_FIRST_DAY, labels centred between
  // them -- the same layout the AS builds with attachMovie("TimelineLabel").
  const frag = document.createDocumentFragment();
  for (let i = 0; i < 12; i++) {
    const start = MONTH_FIRST_DAY[i];
    const end = (i === 11) ? 365 : MONTH_FIRST_DAY[i + 1];
    const cell = document.createElement('span');
    cell.className = 'sim-timeline__month';
    cell.style.left = `${(start / 365) * 100}%`;
    cell.style.width = `${((end - start) / 365) * 100}%`;
    cell.textContent = MONTH_LABELS[i];
    frag.appendChild(cell);
  }
  host.appendChild(frag);
}

// The red grabber (assets/shape-13.svg) is an overlay positioned by percentage
// so it lines up exactly with the month ticks; the native range input on top of
// it stays transparent and supplies all the pointer and keyboard behaviour.
function positionTimelineMarker() {
  const day = state.viewer.dayInput;
  el.timeline.style.setProperty('--marker-position', `${(day / DAY_MAX) * 100}%`);
}

/* --- reset (the masthead's sim-reset event) ------------------------------ */

function resetSim() {
  const viewer = state.viewer;
  viewer.sphere.setThetaAndPhi(INIT_THETA, INIT_PHI);
  viewer.setDayOfYear(0);
  update({ announceText: `Simulation reset. ${describeScene()}` });
}

/* --- equation (via the foundation's kl-unl.js MathJax helper) ------------ */

// Redefining klunlInitEqn is the documented extension point in kl-unl.js.
function klunlInitEqn() {
  klunlShowEquation(
    ['sun-direction-eqn',
     '\\[ a_{\\oplus} \\;=\\; -\\frac{360^{\\circ}}{365}\\,\\bigl(N + 10.8\\bigr)' +
     ' \\qquad a_{\\odot} \\;=\\; a_{\\oplus} + 180^{\\circ} \\]'],
    ['sun-direction-eqn-sr',
     'The direction of the Earth from the centre of the celestial sphere, ' +
     'a sub Earth, equals minus 360 degrees divided by 365, times the ' +
     'quantity N plus 10.8, where N is the day of the year. The direction ' +
     'of the Sun, a sub Sun, is a sub Earth plus 180 degrees.']
  );
}
window.klunlInitEqn = klunlInitEqn;

// kl-unl.js only DEFINES klunlInitEqn; each sim is responsible for calling it
// once MathJax has finished starting up.
function setUpEquation() {
  if (window.MathJax && window.MathJax.startup && window.MathJax.startup.promise) {
    window.MathJax.startup.promise
      .then(() => {
        klunlInitEqn();
        // MathJax queues typeset calls, so this one resolves after the
        // equation above has been rendered.
        return window.MathJax.typesetPromise();
      })
      .then(untabTypesetMath)
      .catch((err) => console.error(err));
  } else {
    klunlInitEqn();
  }
}

// The typeset equation is output the reader looks at, not a control. MathJax's
// SVG output puts tabindex="0" on its container, which would put it in the Tab
// order; take it back out. Right-click still opens the MathJax menu, and the
// paired .sr-only description still carries the maths to screen readers.
function untabTypesetMath() {
  document.querySelectorAll('.sim-equation__math [tabindex]')
    .forEach((node) => { node.setAttribute('tabindex', '-1'); });
}

/* --- start-up ------------------------------------------------------------ */

function wireControls() {
  const sphere = state.viewer.sphere;

  // Each control writes into the same state object; render() then redraws
  // everything from it, so typed values, sliders and the drag stay in step.
  const apply = {
    day: (v) => state.viewer.setDayOfYear(v),
    azimuth: (v) => sphere.setViewerAzimuth(v),
    elevation: (v) => sphere.setPhi(v)
  };

  const bind = (field, setter) => {
    field.addEventListener('input', () => {
      // A half-typed field ("", "-") is left alone until it parses.
      const v = Number(field.value);
      if (field.value === '' || Number.isNaN(v)) return;
      state.editing = field;
      setter(v);
      update();
      state.editing = null;
    });
    field.addEventListener('change', () => {
      // On commit, clamp anything out of range back into it and announce.
      const min = Number(field.min), max = Number(field.max);
      let v = Number(field.value);
      if (field.value === '' || Number.isNaN(v)) v = min;
      v = Math.min(max, Math.max(min, v));
      setter(v);
      update({ announceText: describeScene() });
    });
    addWheelStepping(field, setter);
  };

  bind(el['day-range'], apply.day);
  bind(el['day-number'], apply.day);
  bind(el['azimuth-range'], apply.azimuth);
  bind(el['azimuth-number'], apply.azimuth);
  bind(el['elevation-range'], apply.elevation);
  bind(el['elevation-number'], apply.elevation);

  // Month and day of the month go through the AS setMonthAndDay path.
  const applyCalendar = () => {
    const month = Number(el['month-select'].value);
    const maxDay = monthLength(month - 1);
    let dom = Number(el['dom-number'].value);
    if (el['dom-number'].value === '' || Number.isNaN(dom)) return;
    dom = Math.min(maxDay, Math.max(1, dom));
    state.editing = (document.activeElement === el['dom-number']) ? el['dom-number'] : null;
    state.viewer.setMonthAndDay(month, dom);
    update();
    state.editing = null;
  };
  el['month-select'].addEventListener('change', () => {
    applyCalendar();
    announce(describeScene());
  });
  el['dom-number'].addEventListener('input', applyCalendar);
  el['dom-number'].addEventListener('change', () => {
    applyCalendar();
    announce(describeScene());
  });
  addWheelStepping(el['dom-number'], () => applyCalendar());

  const stage = el.stage;
  stage.addEventListener('pointerdown', onPointerDown);
  stage.addEventListener('pointermove', onPointerMove);
  stage.addEventListener('pointerup', onPointerUp);
  stage.addEventListener('pointercancel', onPointerUp);
  stage.addEventListener('keydown', onStageKeyDown);

  // The masthead dispatches a bubbling, composed "sim-reset" CustomEvent.
  document.addEventListener('sim-reset', resetSim);

  window.addEventListener('resize', resizeCanvas);
}

function init() {
  cacheElements();
  state.viewer = new ZodiacViewer();
  state.canvas = el['stage-canvas'];
  state.ctx = state.canvas.getContext('2d');

  buildTimeline();
  wireControls();
  resizeCanvas();
  update();
  setUpEquation();

  loadArt().then(() => requestRender());
}

if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', init);
} else {
  init();
}
