/* ==========================================================================
   Rotating Sky Explorer  --  accessible HTML5 port of celhorcomp (Flash / AS1)

   GROUND TRUTH for behaviour is the decompiled ActionScript. Every constant,
   matrix, formula, table and piece of on-screen text below is copied verbatim
   from that source. The drawing is reproduced on HTML5 <canvas> in the original
   Flash stage coordinates; controls are native and keyboard-operable; the
   chrome, layout and colour palette follow the KL-UNL foundation.

   The original is a generic 3-D "celestial sphere" engine (CelestialSphere,
   split across "2 CS Getter Setter" ... "11 CS Shaded Bands") driven by a
   controller on the main timeline. The engine's coordinate systems:
     theta  viewer azimuth rotation of the sphere      (radians internally)
     phi    viewer altitude / tilt                     (radians)
     lat    observer latitude                          (radians)
     sTime  local sidereal time                        (radians, 15 deg = 1 h)
   Matrices:  a* world->screen,  m* celestial->world,  b* celestial->screen.

   Two spheres are wired up:
     sphere1  "celestial sphere view"  lat = 90, sTime = 0, no horizon plane,
                                       carries a nested Earth globe
     sphere2  "horizon diagram view"   lat = observer lat, sTime = local sidereal
   ========================================================================== */
'use strict';
(function () {

  /* ---------------- angle / unit constants (verbatim from the AS) --------- */
  var D2R     = 0.017453292519943295;   // deg   -> rad
  var R2D     = 57.29577951308232;      // rad   -> deg
  var H2R     = 0.2617993877991494;     // hours -> rad (15 deg)
  var R2H     = 3.819718634205488;      // rad   -> hours
  var TWO_PI  = 6.283185307179586;
  var HALF_PI = 1.5707963267948966;
  var PI      = 3.141592653589793;

  function mod(n, m) { return ((n % m) + m) % m; }

  // AS colour ints are decimal RGB; AS alpha is 0-100.
  function css(intColor, alpha) {
    var r = (intColor >> 16) & 255, g = (intColor >> 8) & 255, b = intColor & 255;
    return 'rgba(' + r + ',' + g + ',' + b + ',' + ((alpha == null ? 100 : alpha) / 100) + ')';
  }

  // Reproduces the AS Number.prototype.toFixed polyfill so on-screen numbers match.
  function asFixed(x, d) {
    if (isNaN(x)) return 'NaN';
    var s = ''; if (x < 0) { s = '-'; x = -x; }
    var n = Math.round(x * Math.pow(10, d)), str = (n === 0) ? '0' : String(n);
    if (d > 0) {
      var k = str.length;
      if (k <= d) { var z = ''; for (var i = 0; i < d + 1 - k; i++) z += '0'; str = z + str; k = d + 1; }
      str = str.substr(0, k - d) + '.' + str.substr(k - d);
    }
    return s + str;
  }

  // A leading "-" glyph is routinely dropped by screen readers; say "minus".
  function spoken(x, d) {
    var t = asFixed(x, d);
    return (t.charAt(0) === '-') ? 'minus ' + t.slice(1) : t;
  }

  /* ======================================================================
     Sphere -- port of the CelestialSphereClass prototype methods.
     ====================================================================== */
  function Sphere(size) {
    this._c = {};
    this._c.r = size / 2;
    this._c.r2 = this._c.r * this._c.r;
    this._theta = 0;
    this._phi = 0.5235987755982988;     // AS constructor seed
    this._lat = 41 * D2R;
    this._sTime = 0;
    this._maxPhi = 90;
    this._minPhi = -90;
    this._showUnder = true;
    this._showHorizonPlane = true;
    this.objects = [];                   // insertion order (sortObjects is false)
    this.circles = [];
    this.lines = [];
    this.bands = [];
    this.doA(); this.doM(); this.doB();
  }
  var S = Sphere.prototype;

  S.setThetaAndPhi = function (newTheta, newPhi) {
    this._theta = D2R * mod(newTheta, 360);
    if (newPhi > this._maxPhi) newPhi = this._maxPhi;
    else if (newPhi < this._minPhi) newPhi = this._minPhi;
    this._phi = newPhi * D2R;
    this.doA(); this.doB();
  };
  S.setTheta = function (a) { this._theta = D2R * mod(a, 360); this.doA(); this.doB(); };
  S.getTheta = function () { return R2D * this._theta; };
  S.getPhi   = function () { return R2D * this._phi; };
  S.setSize  = function (a) { this._c.r = a / 2; this._c.r2 = this._c.r * this._c.r; this.doA(); this.doB(); };
  S.setLatitude = function (a) {
    if (a > 90) a = 90; else if (a < -90) a = -90;
    this._lat = a * D2R; this.doM(); this.doB();
  };
  S.setSiderealTime = function (a) { this._sTime = mod(a, 24) * H2R; this.doM(); this.doB(); };
  S.getSiderealTime = function () { return this._sTime * R2H; };
  S.setSTimeAndLat = function (t, lat) {           // port of setSTimeAndLatDelayedUpdate
    this._sTime = mod(t, 24) * H2R;
    if (lat > 90) lat = 90; else if (lat < -90) lat = -90;
    this._lat = lat * D2R;
    this.doM(); this.doB();
  };

  // --- matrices (port of doA / doM / doB in "3 CS Geometry.as") ---
  S.doA = function () {
    var c = this._c, r = c.r,
        ct = Math.cos(this._theta), st = Math.sin(this._theta),
        cp = Math.cos(this._phi),   sp = Math.sin(this._phi);
    c.a0 = -r * st;      c.a1 = r * ct;
    c.a3 = r * ct * sp;  c.a4 = r * st * sp;  c.a5 = -r * cp;
    c.a6 = r * ct * cp;  c.a7 = r * st * cp;  c.a8 = r * sp;
  };
  S.doM = function () {
    var c = this._c;
    c.m2 = Math.cos(this._lat);
    c.m3 = Math.sin(this._sTime);
    c.m4 = -Math.cos(this._sTime);
    c.m8 = Math.sin(this._lat);
    c.m0 = c.m4 * c.m8;   c.m1 = -c.m3 * c.m8;
    c.m6 = -c.m2 * c.m4;  c.m7 = c.m2 * c.m3;
  };
  S.doB = function () {
    var c = this._c;
    c.b0 = c.a0 * c.m0 + c.a1 * c.m3;
    c.b1 = c.a0 * c.m1 + c.a1 * c.m4;
    c.b2 = c.a0 * c.m2;
    c.b3 = c.a3 * c.m0 + c.a4 * c.m3 + c.a5 * c.m6;
    c.b4 = c.a3 * c.m1 + c.a4 * c.m4 + c.a5 * c.m7;
    c.b5 = c.a3 * c.m2 + c.a5 * c.m8;
    c.b6 = c.a6 * c.m0 + c.a7 * c.m3 + c.a8 * c.m6;
    c.b7 = c.a6 * c.m1 + c.a7 * c.m4 + c.a8 * c.m7;
    c.b8 = c.a6 * c.m2 + c.a8 * c.m8;
  };

  // --- projections ---
  S.WtoSz = function (p, sp) {
    var c = this._c;
    sp.x = p.x * c.a0 + p.y * c.a1;
    sp.y = p.x * c.a3 + p.y * c.a4 + p.z * c.a5;
    sp.z = p.x * c.a6 + p.y * c.a7 + p.z * c.a8;
  };
  S.CtoSz = function (p, sp) {
    var c = this._c;
    sp.x = p.x * c.b0 + p.y * c.b1 + p.z * c.b2;
    sp.y = p.x * c.b3 + p.y * c.b4 + p.z * c.b5;
    sp.z = p.x * c.b6 + p.y * c.b7 + p.z * c.b8;
  };
  S.CtoW = function (p, w) {
    var c = this._c;
    w.x = p.x * c.m0 + p.y * c.m1 + p.z * c.m2;
    w.y = p.x * c.m3 + p.y * c.m4;
    w.z = p.x * c.m6 + p.y * c.m7 + p.z * c.m8;
  };
  S.WtoC = function (p, cp) {
    var c = this._c;
    cp.x = p.x * c.m0 + p.y * c.m3 + p.z * c.m6;
    cp.y = p.x * c.m1 + p.y * c.m4 + p.z * c.m7;
    cp.z = p.x * c.m2 + p.z * c.m8;
  };
  S.CtoMH = function (cp, hp) {
    var sd = Math.sin(cp.dec), cd = Math.cos(cp.dec),
        sl = Math.sin(this._lat), cl = Math.cos(this._lat),
        h = this._sTime - cp.ra, ch = Math.cos(h),
        caz = sd * cl - cd * ch * sl, saz = cd * Math.sin(h);
    hp.az = (caz === 0) ? 0 : mod(Math.atan2(saz, caz), TWO_PI);
    hp.alt = Math.asin(sd * sl + cd * ch * cl);
  };
  S.MHtoC = function (hp, cp) {
    var salt = Math.sin(hp.alt), calt = Math.cos(hp.alt),
        saz = Math.sin(hp.az), caz = Math.cos(hp.az),
        sl = Math.sin(this._lat), cl = Math.cos(this._lat),
        sh = calt * saz, ch = salt * cl - calt * sl * caz;
    cp.ra = (ch === 0) ? 0 : mod(this._sTime - Math.atan2(sh, ch), TWO_PI);
    cp.dec = Math.asin(salt * sl + calt * caz * cl);
  };
  // Screen (sphere-centred px) -> "mathematical horizon" spherical.
  S.StoMH = function (sp, hp) {
    var M = Math, d = M.sqrt(sp.x * sp.x + sp.y * sp.y) / this._c.r;
    if (d > 1) d = 1;
    var b = M.asin(d), A = M.atan2(sp.x, -sp.y);
    if (this._phi === HALF_PI) {
      hp.alt = HALF_PI - b; hp.az = this._theta + PI - A;
    } else if (this._phi === -HALF_PI) {
      hp.alt = -HALF_PI + b; hp.az = this._theta + A;
    } else {
      var c = HALF_PI - this._phi, cc = M.cos(c), sc = M.sin(c),
          cb = M.cos(b), sb = M.sin(b), ca = cb * cc + sb * sc * M.cos(A);
      hp.alt = HALF_PI - M.acos(ca);
      hp.az = this._theta + M.atan2(sb * M.sin(A), (cb - ca * cc) / sc);
    }
    hp.az = mod(hp.az, TWO_PI);
  };
  // Port of getMouseRaDec: returns null outside the sphere's disc.
  S.screenToRaDec = function (x, y) {
    if (Math.sqrt(x * x + y * y) > this._c.r) return null;
    var hp = {}, cp = {};
    this.StoMH({ x: x, y: y }, hp);
    this.MHtoC(hp, cp);
    return { ra: cp.ra * R2H, dec: cp.dec * R2D };
  };

  // --- point parsing (port of parsePointInput) ---
  S.parse = function (a) {
    var o = {}, r, d;
    if (a.az != null && a.alt != null) {
      o.sys = 0; o.system = 'horizon'; r = (a.r != null) ? a.r : 1;
      d = r * Math.cos(a.alt * D2R);
      o.x = d * Math.cos(a.az * D2R);
      o.y = d * Math.sin(-a.az * D2R);
      o.z = r * Math.sin(a.alt * D2R);
      o.r = Math.abs(r);
    } else if (a.ra != null && a.dec != null) {
      o.sys = 1; o.system = 'celestial'; r = (a.r != null) ? a.r : 1;
      d = r * Math.cos(a.dec * D2R);
      o.x = d * Math.cos(a.ra * H2R);
      o.y = d * Math.sin(a.ra * H2R);
      o.z = r * Math.sin(a.dec * D2R);
      o.r = Math.abs(r);
    } else {
      // The AS carries `system` alongside `sys`, so a re-parsed point keeps its
      // frame. Dropping it silently reinterprets celestial points as horizon ones.
      o.sys = (a.system === 'horizon') ? 0 : (a.system === 'celestial') ? 1 : -1;
      o.system = (o.sys === 0) ? 'horizon' : (o.sys === 1) ? 'celestial' : 'unknown';
      o.x = a.x; o.y = a.y; o.z = a.z;
      o.r = Math.sqrt(o.x * o.x + o.y * o.y + o.z * o.z);
      if (o.r < 1.000001 && o.r > 0.999999) o.r = 1;
    }
    return o;
  };
  S.pointToHorizon = function (up, hp) {
    var p = this.parse(up), q, s;
    if (p.sys === 1) { q = {}; this.CtoW(p, q); } else { q = p; }
    s = q.z / p.r; if (s < -1) s = -1; else if (s > 1) s = 1;
    hp.az = mod(-R2D * Math.atan2(q.y, q.x), 360);
    hp.alt = R2D * Math.asin(s);
    hp.r = p.r;
  };
  S.pointToCelestial = function (up, cp) {
    var p = this.parse(up), q, s;
    if (p.sys === 1) { q = p; } else { q = {}; this.WtoC(p, q); }
    s = q.z / p.r; if (s > 1) s = 1; else if (s < -1) s = -1;
    cp.ra = mod(R2H * Math.atan2(q.y, q.x), 24);
    cp.dec = R2D * Math.asin(s);
    cp.r = p.r;
  };

  /* ---------------- Circles (port of "8 CS Circles.as") ------------------ */
  function Circle(sphere, style, def) {
    this.s = sphere;
    this._sys = 0; this._tilt = 0; this._lambda = 0; this._beta = 0;
    this._gS = 0; this._gE = 0; this._c = {};
    this._thick = (style && style.thickness != null) ? style.thickness : 1;
    this._color = (style && style.color != null) ? style.color : 16711680;
    this._alpha = (style && style.alpha != null) ? style.alpha : 80;
    this.visible = true;
    this.doW();
    if (def) this.setParameters(def);
  }
  Circle.prototype._minStep = 0.7853981633974483;

  Circle.prototype.setParameters = function (a) {
    if (a.az != null && a.alt != null && a.tilt != null) {
      this._sys = 0;
      if (isFinite(a.tilt)) this._tilt = (a.tilt < 0 ? 0 : a.tilt > 180 ? PI : a.tilt * D2R);
      if (isFinite(a.alt))  this._lambda = (a.alt < -90 ? -PI : a.alt > 90 ? PI : a.alt * D2R);
      if (isFinite(a.az))   this._beta = D2R * mod(-a.az, 360);
      if (isFinite(a.gammaStart)) this._gS = D2R * mod(a.gammaStart, 360);
      if (isFinite(a.gammaEnd))   this._gE = D2R * mod(a.gammaEnd, 360);
    } else if (a.ra != null && a.dec != null && a.tilt != null) {
      this._sys = 1;
      if (isFinite(a.tilt)) this._tilt = (a.tilt < 0 ? 0 : a.tilt > 180 ? PI : a.tilt * D2R);
      if (isFinite(a.dec))  this._lambda = (a.dec < -90 ? -PI : a.dec > 90 ? PI : a.dec * D2R);
      if (isFinite(a.ra))   this._beta = H2R * mod(a.ra, 24);
      if (isFinite(a.gammaStart)) this._gS = D2R * mod(a.gammaStart, 360);
      if (isFinite(a.gammaEnd))   this._gE = D2R * mod(a.gammaEnd, 360);
    }
    this.doW();
  };

  // Great/small circle through two points (port of setArcPoints) -- used by the
  // constellation stick figures.
  Circle.prototype.setArcPoints = function (p1, p2) {
    var b1, l1, b2, l2, t;
    if (p1.az != null && p1.alt != null) { this._sys = 0; b1 = (360 - p1.az) * D2R; l1 = p1.alt * D2R; }
    else if (p1.ra != null && p1.dec != null) { this._sys = 1; b1 = p1.ra * H2R; l1 = p1.dec * D2R; }
    else return false;
    if (p2.az != null && p2.alt != null) {
      if (this._sys === 0) { b2 = (360 - p2.az) * D2R; l2 = p2.alt * D2R; }
      else { t = {}; this.s.MHtoC({ az: (360 - p2.az) * D2R, alt: p2.alt * D2R }, t); b2 = t.ra; l2 = t.dec; }
    } else if (p2.ra != null && p2.dec != null) {
      if (this._sys === 0) { t = {}; this.s.CtoMH({ ra: p2.ra * H2R, dec: p2.dec * D2R }, t); b2 = t.az; l2 = t.alt; }
      else { b2 = p2.ra * H2R; l2 = p2.dec * D2R; }
    } else return false;

    var c1 = Math.cos(l1), z1 = Math.sin(l1), x1 = c1 * Math.cos(b1), y1 = c1 * Math.sin(b1),
        c2 = Math.cos(l2), z2 = Math.sin(l2), x2 = c2 * Math.cos(b2), y2 = c2 * Math.sin(b2),
        nx = y1 * z2 - y2 * z1, ny = x2 * z1 - x1 * z2, nz = x1 * y2 - x2 * y1,
        nn = Math.sqrt(nx * nx + ny * ny + nz * nz);

    if (nn < 0.000001) {
      if (x1 === x2 && y1 === y2 && z1 === z2) return false;
      this._lambda = 0; this._tilt = HALF_PI;
      this._beta = Math.atan2(y1, x1);
      this._gS = Math.acos(Math.sqrt(x1 * x1 + y1 * y1));
      if (z1 < 0) this._gS = -this._gS;
      this._gS = mod(this._gS, TWO_PI);
      this._gE = (this._gS + PI) % TWO_PI;
      this.doW(); return true;
    }
    this._lambda = 0;
    this._tilt = Math.acos(nz / nn);
    if (this._tilt === 0) {
      this._beta = 0;
      this._gS = mod(Math.atan2(y1, x1), TWO_PI);
      this._gE = mod(Math.atan2(y2, x2), TWO_PI);
    } else if (this._tilt === PI) {
      this._beta = 0;
      this._gS = mod(Math.atan2(-y1, x1), TWO_PI);
      this._gE = mod(Math.atan2(-y2, x2), TWO_PI);
    } else {
      this._beta = Math.atan2(nx, -ny);
      var st = Math.sin(this._tilt);
      this._gS = mod(Math.atan2(z1 / st, c1 * Math.cos(b1 - this._beta)), TWO_PI);
      this._gE = mod(Math.atan2(z2 / st, c2 * Math.cos(b2 - this._beta)), TWO_PI);
    }
    this.doW(); return true;
  };

  Circle.prototype.doW = function () {
    var st = Math.sin(this._tilt), ct = Math.cos(this._tilt),
        sb = Math.sin(this._beta), cb = Math.cos(this._beta),
        cl = Math.cos(this._lambda), sl = Math.sin(this._lambda), c = this._c;
    c.w0 = cl * cb;  c.w1 = -cl * sb * ct;  c.w2 = sl * sb * st;
    c.w3 = cl * sb;  c.w4 = cl * cb * ct;   c.w5 = -sl * cb * st;
    c.w7 = cl * st;  c.w8 = sl * ct;
  };

  // Compute the screen basis and split the circle into front / back arc spans.
  Circle.prototype.computeArcs = function () {
    var t = this._c, p = this.s._c, v0, v1, v2, v3, v4, v5, v6, v7, v8;
    if (this._sys === 0) {
      v0 = p.a0 * t.w0 + p.a1 * t.w3; v1 = p.a0 * t.w1 + p.a1 * t.w4;               v2 = p.a0 * t.w2 + p.a1 * t.w5;
      v3 = p.a3 * t.w0 + p.a4 * t.w3; v4 = p.a3 * t.w1 + p.a4 * t.w4 + p.a5 * t.w7; v5 = p.a3 * t.w2 + p.a4 * t.w5 + p.a5 * t.w8;
      v6 = p.a6 * t.w0 + p.a7 * t.w3; v7 = p.a6 * t.w1 + p.a7 * t.w4 + p.a8 * t.w7; v8 = p.a6 * t.w2 + p.a7 * t.w5 + p.a8 * t.w8;
    } else {
      v0 = p.b0 * t.w0 + p.b1 * t.w3; v1 = p.b0 * t.w1 + p.b1 * t.w4 + p.b2 * t.w7; v2 = p.b0 * t.w2 + p.b1 * t.w5 + p.b2 * t.w8;
      v3 = p.b3 * t.w0 + p.b4 * t.w3; v4 = p.b3 * t.w1 + p.b4 * t.w4 + p.b5 * t.w7; v5 = p.b3 * t.w2 + p.b4 * t.w5 + p.b5 * t.w8;
      v6 = p.b6 * t.w0 + p.b7 * t.w3; v7 = p.b6 * t.w1 + p.b7 * t.w4 + p.b8 * t.w7; v8 = p.b6 * t.w2 + p.b7 * t.w5 + p.b8 * t.w8;
    }
    var v = [v0, v1, v2, v3, v4, v5, v6, v7, v8],
        front = [], back = [], A = Math.sqrt(v6 * v6 + v7 * v7),
        gS = this._gS, gE = this._gE;

    if (A === 0) { (v8 < 0 ? back : front).push([gS, gE]); return { v: v, front: front, back: back }; }
    var sj = -v8 / A;
    if (sj <= -1) { front.push([gS, gE]); return { v: v, front: front, back: back }; }
    if (sj >= 1)  { back.push([gS, gE]);  return { v: v, front: front, back: back }; }

    var j = Math.asin(sj), t2 = Math.atan2(v6, v7), gDesc, gAsc;
    if (Math.cos(j) < 0) { gDesc = mod(j - t2, TWO_PI);      gAsc = mod(PI - j - t2, TWO_PI); }
    else                 { gDesc = mod(PI - j - t2, TWO_PI); gAsc = mod(j - t2, TWO_PI); }

    if (gS === gE) { front.push([gAsc, gDesc]); back.push([gDesc, gAsc]); return { v: v, front: front, back: back }; }

    // Partial arc: walk the four sorted breakpoints (gAsc=0, gDesc=1, gS=2, gE=3).
    var arr = [[gAsc, 0], [gDesc, 1], [gS, 2], [gE, 3]], k;
    arr.sort(function (a, b) { return a[0] - b[0]; });
    var draw = false, isFront = true;
    for (k = 0; k < 4; k++) {
      if (arr[k][1] === 0) isFront = true; else if (arr[k][1] === 1) isFront = false;
      else if (arr[k][1] === 2) draw = true; else draw = false;
    }
    var prev = arr[3];
    for (k = 0; k < 4; k++) {
      var g1 = prev; prev = arr[k];
      if (draw && g1[0] !== prev[0]) (isFront ? front : back).push([g1[0], prev[0]]);
      if (prev[1] === 0) isFront = true; else if (prev[1] === 1) isFront = false;
      else if (prev[1] === 2) draw = true; else draw = false;
    }
    return { v: v, front: front, back: back };
  };

  // The AS tessellates arcs with curveTo; quadraticCurveTo reproduces the shape.
  function emitArc(ctx, v, g1, g2, minStep) {
    if (g2 < g1) g2 += TWO_PI;
    var arc = g2 - g1; if (arc === 0) arc = TWO_PI;
    var n = Math.ceil(arc / minStep), step = arc / n, half = step / 2,
        cRad = 1 / Math.cos(half), ax = Math.cos(g1), ay = Math.sin(g1);
    ctx.moveTo(v[0] * ax + v[1] * ay + v[2], v[3] * ax + v[4] * ay + v[5]);
    var aA = g1 + step, cA = aA - half;
    for (var i = 0; i < n; i++) {
      ax = Math.cos(aA); ay = Math.sin(aA);
      var cx = cRad * Math.cos(cA), cy = cRad * Math.sin(cA);
      ctx.quadraticCurveTo(v[0] * cx + v[1] * cy + v[2], v[3] * cx + v[4] * cy + v[5],
                           v[0] * ax + v[1] * ay + v[2], v[3] * ax + v[4] * ay + v[5]);
      aA += step; cA += step;
    }
  }

  /* ---------------- Lines (port of "9 CS Lines.as") ---------------------- */
  function Line(sphere, style, head, tail) {
    this.s = sphere;
    this._thick = (style && style.thickness != null) ? style.thickness : 1;
    this._color = (style && style.color != null) ? style.color : 255;
    this._alpha = (style && style.alpha != null) ? style.alpha : 100;
    this.visible = true;
    this._head = sphere.parse(head); if (this._head.sys === -1) this._head.sys = 0;
    this._tail = sphere.parse(tail); if (this._tail.sys === -1) this._tail.sys = 0;
  }
  // Splits the line where it crosses the sphere surface and the horizon plane, and
  // tags each piece with the layer it belongs to: bE/fE outside, bI/aI inside.
  Line.prototype.computeSegments = function () {
    if (!this.visible) return [];
    var s = this.s, head = {}, tail = {};
    if (this._head.sys === 0) s.WtoSz(this._head, head); else s.CtoSz(this._head, head);
    if (this._tail.sys === 0) s.WtoSz(this._tail, tail); else s.CtoSz(this._tail, tail);
    var mx = head.x - tail.x, my = head.y - tail.y, mz = head.z - tail.z,
        A = mx * mx + my * my + mz * mz,
        B = 2 * (mx * tail.x + my * tail.y + mz * tail.z),
        C = tail.x * tail.x + tail.y * tail.y + tail.z * tail.z,
        rad = s._c.r, rad2 = rad * rad, phi = s._phi, tp,
        cand = [], D = B * B - 4 * A * (C - rad2), i, k;
    if (D > 0) { var sD = Math.sqrt(D); cand.push((-B + sD) / (2 * A)); cand.push((-B - sD) / (2 * A)); }
    if (phi > -HALF_PI && phi < HALF_PI) {
      tp = Math.tan(phi);
      if (my !== tp * mz) cand.push((tp * tail.z - tail.y) / (my - tp * mz));
      if (mz !== 0) { var q = -tail.z / mz; if (q * (q * A + B) + C >= rad2) cand.push(q); }
    } else if (mz !== 0) { cand.push(-tail.z / mz); }

    var arr = [0, 1];
    for (i = 0; i < cand.length; i++) {
      if (cand[i] > 0 && cand[i] < 1) {
        k = 1; while (cand[i] > arr[k]) k++;
        if (cand[i] !== arr[k]) arr.splice(k, 0, cand[i]);
      }
    }
    var out = [], showUnder = s._showUnder;
    for (i = 0; i < arr.length - 1; i++) {
      var s1 = arr[i], s2 = arr[i + 1], mid = s1 + (s2 - s1) / 2,
          r2 = mid * (mid * A + B) + C, layer;
      if (r2 < rad2) {
        if (phi === -HALF_PI)      layer = (mid * mz + tail.z > 0)  ? 'bI' : 'aI';
        else if (phi === HALF_PI)  layer = (mid * mz + tail.z > 0)  ? 'aI' : 'bI';
        else layer = (mid * my + tail.y - (mid * mz + tail.z) * tp > 1e-9) ? 'bI' : 'aI';
        if (!showUnder && layer === 'bI') continue;     // hidden under the plane
      } else {
        layer = (mid * mz + tail.z < 0) ? 'bE' : 'fE';
        if (!showUnder) {
          if (phi === -HALF_PI)     { if (mid * mz + tail.z > 0) continue; layer = 'bE'; }
          else if (phi === HALF_PI) { if (mid * mz + tail.z <= 0) continue; layer = 'fE'; }
          else if (mid * my + tail.y - (mid * mz + tail.z) * tp > 1e-9) continue;
        }
      }
      out.push({ x1: s1 * mx + tail.x, y1: s1 * my + tail.y,
                 x2: s2 * mx + tail.x, y2: s2 * my + tail.y, layer: layer });
    }
    return out;
  };

  /* ---------------- Objects (port of "7 CS Objects.as") ------------------ */
  function SphereObject(sphere, kind, position, opts) {
    this.s = sphere;
    this.kind = kind;                    // what the renderer should draw
    this.opts = opts || {};
    this._o = { x: 0, y: 0, z: 0 };
    this._n = { x: 0, y: 0, z: 1 };
    this._u = { x: 0, y: 1, z: 0 };
    this._oType = 0;
    this._sp = { x: 0, y: 0, z: 0 };
    this.visible = true;
    this.labelText = '';
    this.setPosition(position || { alt: 0, az: 0, r: 1 });
  }
  SphereObject.prototype.setPosition = function (a) {
    var p = this.s.parse(a);
    this._sys = (p.sys === 1) ? 1 : 0;
    this._p = p; this._r = p.r;
    this._p_o = { x: p.x + this._o.x, y: p.y + this._o.y, z: p.z + this._o.z };
    this._p_n = { x: p.x + this._n.x, y: p.y + this._n.y, z: p.z + this._n.z };
    this._p_u = { x: p.x + this._u.x, y: p.y + this._u.y, z: p.z + this._u.z };
  };
  SphereObject.prototype.getPositionHorizon   = function (o) { this.s.pointToHorizon(this._p, o); };
  SphereObject.prototype.getPositionCelestial = function (o) { this.s.pointToCelestial(this._p, o); };

  SphereObject.prototype.setOrientationType = function (type, arg2, arg3) {
    var p = this._p, nm, s = this.s, tmp;
    var conv = function (a) {                    // bring a reference point into our system
      var q = s.parse(a), r;
      if (q.sys === 0 && this._sys === 1) { r = {}; s.WtoC(q, r); return r; }
      if (q.sys === 1 && this._sys === 0) { r = {}; s.CtoW(q, r); return r; }
      return q;
    }.bind(this);

    if (type === 'flat') { this._oType = 0; return; }

    if (type === 'skewed') {
      this._oType = 1;
      if (typeof arg2 !== 'object') {
        nm = Math.sqrt(p.x * p.x + p.y * p.y + p.z * p.z);
        this._o = { x: p.x / nm, y: p.y / nm, z: p.z / nm };
      } else {
        tmp = conv(arg2);
        nm = Math.sqrt(tmp.x * tmp.x + tmp.y * tmp.y + tmp.z * tmp.z);
        this._o = { x: tmp.x / nm, y: tmp.y / nm, z: tmp.z / nm };
      }
      this._p_o = { x: p.x + this._o.x, y: p.y + this._o.y, z: p.z + this._o.z };
      return;
    }

    // 'absolute'
    this._oType = 2;
    if (typeof arg2 !== 'object' || typeof arg3 !== 'object') {
      nm = Math.sqrt(p.x * p.x + p.y * p.y + p.z * p.z);
      this._n = { x: p.x / nm, y: p.y / nm, z: p.z / nm };
      if (!(this._n.x === 0 && this._n.y === 0)) {
        var u = { x: -this._n.x * this._n.z, y: -this._n.z * this._n.y,
                  z: this._n.x * this._n.x + this._n.y * this._n.y },
            un = Math.sqrt(u.x * u.x + u.y * u.y + u.z * u.z);
        this._u = { x: u.x / un, y: u.y / un, z: u.z / un };
      } else { this._u = { x: 0, y: 1, z: 0 }; }
    } else {
      var a = conv(arg2), b = conv(arg3);
      nm = Math.sqrt(a.x * a.x + a.y * a.y + a.z * a.z);
      this._n = { x: a.x / nm, y: a.y / nm, z: a.z / nm };
      var nx = this._n.x, ny = this._n.y, nz = this._n.z,
          ux = ny * ny * b.x - nx * ny * b.y - nx * nz * b.z + nz * nz * b.x,
          uy = nz * nz * b.y - ny * nz * b.z - nx * ny * b.x + nx * nx * b.y,
          uz = nx * nx * b.z - nx * nz * b.x - ny * nz * b.y + ny * ny * b.z,
          un2 = Math.sqrt(ux * ux + uy * uy + uz * uz);
      this._u = { x: ux / un2, y: uy / un2, z: uz / un2 };
    }
    this._p_u = { x: p.x + this._u.x, y: p.y + this._u.y, z: p.z + this._u.z };
    this._p_n = { x: p.x + this._n.x, y: p.y + this._n.y, z: p.z + this._n.z };
  };

  // Screen position plus the shell's rotation / y-squash (mirrors Flash _rotation
  // and _yscale) so 3-D-attached art foreshortens exactly as it did.
  SphereObject.prototype.update = function () {
    var s = this.s, c = s._c, sp = this._sp, o;
    if (this._sys === 0) s.WtoSz(this._p, sp); else s.CtoSz(this._p, sp);
    if (this._oType === 1) {
      o = {};
      var oz;
      if (this._sys === 0) { oz = this._o.x * c.a6 + this._o.y * c.a7 + this._o.z * c.a8; s.WtoSz(this._p_o, o); }
      else                 { oz = this._o.x * c.b6 + this._o.y * c.b7 + this._o.z * c.b8; s.CtoSz(this._p_o, o); }
      this.yscale = Math.sqrt(1 - oz * oz / c.r2);
      this.rotation = Math.atan2(o.y - sp.y, o.x - sp.x) + HALF_PI;
      this.instRotation = 0;
    } else if (this._oType === 2) {
      var spu = {}, spn = {}, npz;
      if (this._sys === 0) {
        npz = (this._n.x * c.a6 + this._n.y * c.a7 + this._n.z * c.a8) / c.r;
        s.WtoSz(this._p_n, spn); s.WtoSz(this._p_u, spu);
      } else {
        npz = (this._n.x * c.b6 + this._n.y * c.b7 + this._n.z * c.b8) / c.r;
        s.CtoSz(this._p_n, spn); s.CtoSz(this._p_u, spu);
      }
      this.yscale = npz;
      var A = Math.atan2(spn.y - sp.y, spn.x - sp.x) + HALF_PI;
      this.rotation = A;
      var cA = Math.cos(A), sA = Math.sin(A),
          x0 = spu.x - sp.x, y0 = spu.y - sp.y,
          x1 = cA * x0 + sA * y0, y1 = -sA * x0 + cA * y0;
      this.instRotation = Math.atan2(y1 / npz, x1) + HALF_PI;
    } else {
      this.yscale = 1; this.rotation = 0; this.instRotation = 0;
    }
  };

  /* ---------------- Shaded bands (port of "11 CS Shaded Bands.as") -------
     A declination band, drawn as a flat-coloured disc clipped to the band's
     silhouette. Front and back halves are separate paths so the band can sit on
     the inner surface of the sphere correctly. ---------------------------- */
  function ShadedBand(sphere, opts) {
    this.s = sphere;
    this.color = opts.innerColor;
    this.alpha = opts.innerAlpha;
    this._bThick = 0; this._bColor = 0; this._bAlpha = 100;
    this.showBorder = false;
    this.visible = true;
    this._noDef = true;
    this._c = {};
    this._tilt = 0; this._beta = 0; this._lambda1 = 0; this._lambda2 = 0;
    this._type1 = 0; this._type2 = 0; this._sys = 1;
    this.doK();
  }
  ShadedBand.prototype._minStep = 0.5235987755982988;
  ShadedBand.prototype.setBorderStyle = function (t, c, a) {
    if (t != null) this._bThick = t; if (c != null) this._bColor = c; if (a != null) this._bAlpha = a;
  };
  ShadedBand.prototype.setParameters = function (arg) {
    var tmp;
    if (arg && arg.dec1 != null && arg.dec2 != null) {
      this._sys = 1;
      this._beta = (arg.ra != null) ? H2R * mod(arg.ra, 24) : 0;
      this._tilt = (arg.tilt != null) ? (arg.tilt < 0 ? 0 : arg.tilt > 180 ? PI : arg.tilt * D2R) : 0;
      if (arg.dec1 <= -90)     { this._lambda1 = -HALF_PI; this._type1 = 1; }
      else if (arg.dec1 >= 90) { this._lambda1 =  HALF_PI; this._type1 = 1; }
      else                     { this._lambda1 = arg.dec1 * D2R; this._type1 = 0; }
      if (arg.dec2 <= -90)     { this._lambda2 = -HALF_PI; this._type2 = 1; }
      else if (arg.dec2 >= 90) { this._lambda2 =  HALF_PI; this._type2 = 1; }
      else                     { this._lambda2 = arg.dec2 * D2R; this._type2 = 0; }
      this._noDef = false;
    } else {
      this._noDef = true;
    }
    if (this._lambda1 > this._lambda2) {
      tmp = this._lambda2; this._lambda2 = this._lambda1; this._lambda1 = tmp;
      tmp = this._type2;   this._type2   = this._type1;   this._type1   = tmp;
    }
    this.doK();
  };
  ShadedBand.prototype.doK = function () {
    var st = Math.sin(this._tilt), ct = Math.cos(this._tilt),
        sb = Math.sin(this._beta), cb = Math.cos(this._beta), c = this._c;
    c.k0 = cb;  c.k1 = -sb * ct;  c.k2 = sb * st;
    c.k3 = sb;  c.k4 = cb * ct;   c.k5 = -cb * st;
    c.k7 = st;  c.k8 = ct;
  };

  // Builds the front/back silhouette paths in the band's 100-unit space.
  // Returns { front: Path2D|null, back: Path2D|null, frontBorder, backBorder }.
  ShadedBand.prototype.buildPaths = function () {
    if (!this.visible || this._noDef) return null;
    var t = this._c, p = this.s._c, k = 100 / p.r, v0, v1, v2, v3, v4, v5, v6, v7, v8;
    if (this._sys === 0) {
      v0 = k * (p.a0 * t.k0 + p.a1 * t.k3); v1 = k * (p.a0 * t.k1 + p.a1 * t.k4);               v2 = k * (p.a0 * t.k2 + p.a1 * t.k5);
      v3 = k * (p.a3 * t.k0 + p.a4 * t.k3); v4 = k * (p.a3 * t.k1 + p.a4 * t.k4 + p.a5 * t.k7); v5 = k * (p.a3 * t.k2 + p.a4 * t.k5 + p.a5 * t.k8);
      v6 = k * (p.a6 * t.k0 + p.a7 * t.k3); v7 = k * (p.a6 * t.k1 + p.a7 * t.k4 + p.a8 * t.k7); v8 = k * (p.a6 * t.k2 + p.a7 * t.k5 + p.a8 * t.k8);
    } else {
      v0 = k * (p.b0 * t.k0 + p.b1 * t.k3); v1 = k * (p.b0 * t.k1 + p.b1 * t.k4 + p.b2 * t.k7); v2 = k * (p.b0 * t.k2 + p.b1 * t.k5 + p.b2 * t.k8);
      v3 = k * (p.b3 * t.k0 + p.b4 * t.k3); v4 = k * (p.b3 * t.k1 + p.b4 * t.k4 + p.b5 * t.k7); v5 = k * (p.b3 * t.k2 + p.b4 * t.k5 + p.b5 * t.k8);
      v6 = k * (p.b6 * t.k0 + p.b7 * t.k3); v7 = k * (p.b6 * t.k1 + p.b7 * t.k4 + p.b8 * t.k7); v8 = k * (p.b6 * t.k2 + p.b7 * t.k5 + p.b8 * t.k8);
    }
    var cos = Math.cos, sin = Math.sin, atan2 = Math.atan2, sqrt = Math.sqrt, asin = Math.asin,
        minStep = this._minStep,
        c1 = cos(this._lambda1), s1 = sin(this._lambda1),
        c2 = cos(this._lambda2), s2 = sin(this._lambda2),
        A = sqrt(v6 * v6 + v7 * v7);

    var front = new Path2D(), back = new Path2D(),
        fBorder = new Path2D(), bBorder = new Path2D();

    // A perimeter arc runs along the sphere's limb between two screen angles.
    function perimeter(t1, t2, dir, m1, m2) {
      var span, closed, n, step;
      if (dir === 1) { span = mod(t2 - t1, TWO_PI); } else { span = mod(t1 - t2, TWO_PI); }
      closed = (span === 0); if (closed) span = TWO_PI;
      n = Math.ceil(span / minStep);
      step = (dir === 1 ? span : -span) / n;
      var half = step / 2, cRad = 100 / cos(half), x, y, i;
      if (closed) { x = 100 * cos(t1); y = 100 * sin(t1); m1.moveTo(x, y); m2.moveTo(x, y); }
      var aA = t1 + step, cA = aA - half;
      for (i = 0; i < n; i++) {
        x = 100 * cos(aA); y = 100 * sin(aA);
        var cx = cRad * cos(cA), cy = cRad * sin(cA);
        m1.quadraticCurveTo(cx, cy, x, y); m2.quadraticCurveTo(cx, cy, x, y);
        aA += step; cA += step;
      }
    }
    // A parallel-of-declination arc across the sphere's surface.
    function spherical(g1, g2, cl, sl, dir, mc, bmc) {
      var span, closed, n, step;
      if (dir === 1) { span = mod(g2 - g1, TWO_PI); } else { span = mod(g1 - g2, TWO_PI); }
      closed = (span === 0); if (closed) span = TWO_PI;
      n = Math.ceil(span / minStep);
      step = (dir === 1 ? span : -span) / n;
      var half = step / 2, cRad = 1 / cos(half),
          ca = cos(g1), sa = sin(g1),
          x = cl * (v0 * ca + v1 * sa) + sl * v2,
          y = cl * (v3 * ca + v4 * sa) + sl * v5, i;
      if (closed) mc.moveTo(x, y);
      bmc.moveTo(x, y);
      var aA = g1 + step, cA = aA - half;
      for (i = 0; i < n; i++) {
        ca = cos(aA); sa = sin(aA);
        var cc = cRad * cos(cA), sc = cRad * sin(cA);
        x = cl * (v0 * ca + v1 * sa) + sl * v2;
        y = cl * (v3 * ca + v4 * sa) + sl * v5;
        var qx = cl * (v0 * cc + v1 * sc) + sl * v2,
            qy = cl * (v3 * cc + v4 * sc) + sl * v5;
        mc.quadraticCurveTo(qx, qy, x, y); bmc.quadraticCurveTo(qx, qy, x, y);
        aA += step; cA += step;
      }
    }

    // Classify each bounding parallel: 0 = crosses the limb, 1 = wholly in front,
    // 2 = wholly behind.
    var startX = null, startY = null, sj, j, tt, gA1, gD1, ca2, sa2, tA1, tD1, gA2, gD2, tA2, tD2, type1, type2;

    var L = c1 * A;
    if (L === 0) { type1 = (s1 * v8 < 0) ? 2 : 1; }
    else {
      sj = -s1 * v8 / L;
      if (sj <= -1) type1 = 1;
      else if (sj >= 1) type1 = 2;
      else {
        type1 = 0;
        j = asin(sj); tt = atan2(v6, v7);
        if (cos(j) < 0) { gD1 = j - tt; gA1 = PI - j - tt; } else { gD1 = PI - j - tt; gA1 = j - tt; }
        ca2 = cos(gD1); sa2 = sin(gD1);
        tD1 = atan2(c1 * (v3 * ca2 + v4 * sa2) + s1 * v5, c1 * (v0 * ca2 + v1 * sa2) + s1 * v2);
        ca2 = cos(gA1); sa2 = sin(gA1);
        startX = c1 * (v0 * ca2 + v1 * sa2) + s1 * v2;
        startY = c1 * (v3 * ca2 + v4 * sa2) + s1 * v5;
        tA1 = atan2(startY, startX);
      }
    }
    L = c2 * A;
    if (L === 0) { type2 = (s2 * v8 < 0) ? 2 : 1; }
    else {
      sj = -s2 * v8 / L;
      if (sj <= -1) type2 = 1;
      else if (sj >= 1) type2 = 2;
      else {
        type2 = 0;
        j = asin(sj); tt = atan2(v6, v7);
        if (cos(j) < 0) { gD2 = j - tt; gA2 = PI - j - tt; } else { gD2 = PI - j - tt; gA2 = j - tt; }
        ca2 = cos(gD2); sa2 = sin(gD2);
        tD2 = atan2(c2 * (v3 * ca2 + v4 * sa2) + s2 * v5, c2 * (v0 * ca2 + v1 * sa2) + s2 * v2);
        ca2 = cos(gA2); sa2 = sin(gA2);
        if (startX === null) {
          startX = c2 * (v0 * ca2 + v1 * sa2) + s2 * v2;
          startY = c2 * (v3 * ca2 + v4 * sa2) + s2 * v5;
          tA2 = atan2(startY, startX);
        } else {
          tA2 = atan2(c2 * (v3 * ca2 + v4 * sa2) + s2 * v5, c2 * (v0 * ca2 + v1 * sa2) + s2 * v2);
        }
      }
    }

    function seed() { front.moveTo(startX, startY); back.moveTo(startX, startY); fBorder.moveTo(startX, startY); bBorder.moveTo(startX, startY); }

    if (type1 === 0 && type2 === 0) {
      seed();
      perimeter(tA1, tA2, 1, front, back);
      spherical(gA2, gD2, c2, s2, 1, front, fBorder);
      spherical(gA2, gD2, c2, s2, -1, back, bBorder);
      perimeter(tD2, tD1, 1, front, back);
      spherical(gD1, gA1, c1, s1, -1, front, fBorder);
      spherical(gD1, gA1, c1, s1, 1, back, bBorder);
    } else if (type1 === 0 && type2 === 1) {
      seed();
      spherical(gA1, gD1, c1, s1, 1, front, fBorder);
      spherical(gA1, gD1, c1, s1, -1, back, bBorder);
      perimeter(tD1, tA1, -1, front, back);
      if (this._type2 === 0) spherical(0, 0, c2, s2, -1, front, fBorder);
    } else if (type1 === 0 && type2 === 2) {
      seed();
      spherical(gA1, gD1, c1, s1, 1, front, fBorder);
      spherical(gA1, gD1, c1, s1, -1, back, bBorder);
      perimeter(tD1, tA1, -1, front, back);
      if (this._type2 === 0) spherical(0, 0, c2, s2, 1, back, bBorder);
    } else if (type1 === 1 && type2 === 0) {
      seed();
      spherical(gA2, gD2, c2, s2, 1, front, fBorder);
      spherical(gA2, gD2, c2, s2, -1, back, bBorder);
      perimeter(tD2, tA2, 1, front, back);
      if (this._type1 === 0) spherical(0, 0, c1, s1, -1, front, fBorder);
    } else if (type1 === 1 && type2 === 1) {
      if (this._type1 === 0) spherical(0, 0, c1, s1, 1, front, fBorder);
      if (this._type2 === 0) spherical(0, 0, c2, s2, -1, front, fBorder);
    } else if (type1 === 1 && type2 === 2) {
      if (this._type1 === 0) spherical(0, 0, c1, s1, 1, front, fBorder);
      if (this._type2 === 0) spherical(0, 0, c2, s2, 1, back, bBorder);
      perimeter(0, 0, -1, front, back);
    } else if (type1 === 2 && type2 === 0) {
      seed();
      spherical(gA2, gD2, c2, s2, 1, front, fBorder);
      spherical(gA2, gD2, c2, s2, -1, back, bBorder);
      perimeter(tD2, tA2, 1, front, back);
      if (this._type1 === 0) spherical(0, 0, c1, s1, 1, back, bBorder);
    } else if (type1 === 2 && type2 === 1) {
      if (this._type1 === 0) spherical(0, 0, c1, s1, 1, back, bBorder);
      if (this._type2 === 0) spherical(0, 0, c2, s2, 1, front, fBorder);
      perimeter(0, 0, 1, front, back);
    } else {  // 2 / 2
      if (this._type1 === 0) spherical(0, 0, c1, s1, 1, back, bBorder);
      if (this._type2 === 0) spherical(0, 0, c2, s2, -1, back, bBorder);
    }
    return { front: front, back: back, fBorder: fBorder, bBorder: bBorder };
  };

  /* ======================================================================
     Verbatim data tables from the AS source
     ====================================================================== */

  // Coastline outlines shared by the globe and the world map ("GlobeComponent.as").
  var SHORE = [[{x:-0.3346,y:0.0459,z:0.9413},{x:-0.3416,y:0.0996,z:0.9346},{x:-0.2114,y:0.2266,z:0.9508},{x:-0.096,y:0.2606,z:0.9607},{x:-0.0754,y:0.2221,z:0.9721},{x:0.1858,y:0.3188,z:0.9294},{x:0.2601,y:0.2689,z:0.9274},{x:0.3333,y:0.1093,z:0.9365},{x:0.5148,y:0.0304,z:0.8568},{x:0.5205,y:0.0699,z:0.851},{x:0.4949,y:0.0935,z:0.8639},{x:0.5415,y:0.1316,z:0.8304},{x:0.4746,y:0.1559,z:0.8663},{x:0.4533,y:0.1428,z:0.8798},{x:0.3811,y:0.182,z:0.9064},{x:0.5518,y:0.1955,z:0.8107},{x:0.5657,y:0.1123,z:0.8169},{x:0.5325,y:0.0913,z:0.8415},{x:0.5788,y:0.0726,z:0.8123},{x:0.6521,y:0.0005,z:0.7582},{x:0.6599,y:-0.0552,z:0.7494},{x:0.6902,y:-0.0128,z:0.7235},{x:0.7263,y:-0.0199,z:0.6871},{x:0.7223,y:-0.1168,z:0.6817},{x:0.7875,y:-0.1261,z:0.6033},{x:0.8049,y:-0.079,z:0.5882},{x:0.7916,y:-0.0099,z:0.611},{x:0.7267,y:0.0424,z:0.6856},{x:0.7059,y:0.1082,z:0.7},{x:0.7406,y:0.2044,z:0.6401},{x:0.761,y:0.2109,z:0.6135},{x:0.7249,y:0.2418,z:0.645},{x:0.7003,y:0.1548,z:0.6969},{x:0.6782,y:0.1634,z:0.7165},{x:0.701,y:0.2505,z:0.6677},{x:0.7398,y:0.316,z:0.5939},{x:0.7024,y:0.2932,z:0.6486},{x:0.6614,y:0.3481,z:0.6644},{x:0.5977,y:0.3465,z:0.723},{x:0.5499,y:0.4863,z:0.679},{x:0.6837,y:0.3491,z:0.6408},{x:0.7121,y:0.3693,z:0.5971},{x:0.6462,y:0.4721,z:0.5996},{x:0.7063,y:0.479,z:0.5213},{x:0.7515,y:0.4162,z:0.5118},{x:0.7804,y:0.3107,z:0.5427},{x:0.816,y:0.2808,z:0.5053},{x:0.8186,y:0.1474,z:0.5552},{x:0.7832,y:0.1514,z:0.6031},{x:0.8072,y:-0.0792,z:0.5849},{x:0.8913,y:-0.2764,z:0.3594},{x:0.9222,y:-0.2913,z:0.2545},{x:0.968,y:-0.2156,z:0.1285},{x:0.996,y:-0.0345,z:0.0829},{x:0.991,y:0.0669,z:0.116},{x:0.9841,y:0.1734,z:0.0387},{x:0.9529,y:0.2358,z:-0.191},{x:0.9216,y:0.199,z:-0.3334},{x:0.7843,y:0.2596,z:-0.5635},{x:0.7424,y:0.3784,z:-0.5528},{x:0.7432,y:0.53,z:-0.4084},{x:0.7742,y:0.5361,z:-0.3363},{x:0.7322,y:0.6312,z:-0.2559},{x:0.7731,y:0.629,z:-0.0816},{x:0.6711,y:0.7371,z:0.0794},{x:0.6185,y:0.7582,z:0.2064},{x:0.7094,y:0.6835,z:0.172},{x:0.7425,y:0.6167,z:0.2616},{x:0.7323,y:0.4634,z:0.499},{x:0.7047,y:0.6485,z:0.288},{x:0.709,y:0.6702,z:0.2195},{x:0.547,y:0.7839,z:0.2936},{x:0.4669,y:0.7999,z:0.3771},{x:0.5075,y:0.7499,z:0.4244},{x:0.5708,y:0.7106,z:0.4113},{x:0.5873,y:0.6439,z:0.4903},{x:0.5637,y:0.6524,z:0.5065},{x:0.4562,y:0.7854,z:0.4183},{x:0.285,y:0.8918,z:0.3513},{x:0.2137,y:0.9667,z:0.1405},{x:0.1742,y:0.9683,z:0.179},{x:0.1617,y:0.9492,z:0.2701},{x:-0.0245,y:0.9218,z:0.3868},{x:-0.0724,y:0.9584,z:0.276},{x:-0.1291,y:0.9498,z:0.2851},{x:-0.1512,y:0.9825,z:0.1087},{x:-0.2453,y:0.9692,z:0.024},{x:-0.2253,y:0.9697,z:0.0943},{x:-0.162,y:0.9742,z:0.1569},{x:-0.1693,y:0.9583,z:0.2302},{x:-0.2604,y:0.9534,z:0.1521},{x:-0.324,y:0.9204,z:0.2189},{x:-0.2558,y:0.9105,z:0.3249},{x:-0.4007,y:0.8273,z:0.3937},{x:-0.461,y:0.7336,z:0.4994},{x:-0.4007,y:0.7145,z:0.5736},{x:-0.428,y:0.6691,z:0.6076},{x:-0.385,y:0.6794,z:0.6247},{x:-0.4476,y:0.6263,z:0.6383},{x:-0.4855,y:0.663,z:0.5698},{x:-0.5161,y:0.6355,z:0.5743},{x:-0.4692,y:0.6094,z:0.6391},{x:-0.5192,y:0.5174,z:0.6803},{x:-0.5026,y:0.4055,z:0.7635},{x:-0.4193,y:0.3708,z:0.8287},{x:-0.4622,y:0.1663,z:0.871},{x:-0.5025,y:0.2226,z:0.8355},{x:-0.5765,y:0.2476,z:0.7787},{x:-0.5338,y:0.1583,z:0.8306},{x:-0.4863,y:0.1283,z:0.8643},{x:-0.4672,y:0.0074,z:0.8841},{x:-0.418,y:0.0021,z:0.9084},{x:-0.4004,y:-0.072,z:0.9135}],[{x:0.206,y:-0.5678,z:-0.797},{x:0.3392,y:-0.6758,z:-0.6544},{x:0.5784,y:-0.6598,z:-0.4797},{x:0.5974,y:-0.6792,z:-0.4264},{x:0.6996,y:-0.6096,z:-0.3727},{x:0.7597,y:-0.612,z:-0.22},{x:0.8105,y:-0.5663,z:-0.1498},{x:0.8141,y:-0.5728,z:-0.0954},{x:0.6662,y:-0.7455,z:0.0175},{x:0.6302,y:-0.767,z:0.1205},{x:0.3556,y:-0.9081,z:0.2212},{x:0.2267,y:-0.9645,z:0.1355},{x:0.1876,y:-0.9681,z:0.1662},{x:0.1322,y:-0.9786,z:0.1575},{x:0.1114,y:-0.9592,z:0.2597},{x:0.0201,y:-0.9619,z:0.2728},{x:0.0499,y:-0.9301,z:0.3639},{x:-0.0045,y:-0.9324,z:0.3614},{x:-0.0268,y:-0.9479,z:0.3173},{x:-0.1023,y:-0.9327,z:0.3458},{x:-0.125,y:-0.8816,z:0.4551},{x:-0.0824,y:-0.8601,z:0.5034},{x:0.0953,y:-0.8597,z:0.5018},{x:0.1497,y:-0.8938,z:0.4228},{x:0.1263,y:-0.8453,z:0.5192},{x:0.1937,y:-0.7964,z:0.5729},{x:0.2105,y:-0.7227,z:0.6583},{x:0.2559,y:-0.7013,z:0.6653},{x:0.2381,y:-0.6877,z:0.6859},{x:0.2978,y:-0.6315,z:0.7159},{x:0.3001,y:-0.6601,z:0.6886},{x:0.3373,y:-0.6187,z:0.7096},{x:0.2658,y:-0.6144,z:0.7428},{x:0.2193,y:-0.6474,z:0.7299},{x:0.2561,y:-0.5848,z:0.7697},{x:0.3205,y:-0.5532,z:0.7689},{x:0.3322,y:-0.4862,z:0.8082},{x:0.284,y:-0.4991,z:0.8187},{x:0.2136,y:-0.4479,z:0.8682},{x:0.195,y:-0.4938,z:0.8474},{x:0.1718,y:-0.4534,z:0.8746},{x:0.0976,y:-0.4563,z:0.8845},{x:0.1089,y:-0.6066,z:0.7875},{x:0.0729,y:-0.5727,z:0.8165},{x:-0.0263,y:-0.5471,z:0.8366},{x:-0.0364,y:-0.4856,z:0.8734},{x:0.0594,y:-0.3827,z:0.922},{x:0.052,y:-0.3518,z:0.9346},{x:0.0091,y:-0.376,z:0.9266},{x:-0.0262,y:-0.3095,z:0.9505},{x:-0.0904,y:-0.365,z:0.9266},{x:-0.2194,y:-0.2788,z:0.9349},{x:-0.2931,y:-0.1264,z:0.9477},{x:-0.3515,y:-0.0852,z:0.9323},{x:-0.3753,y:-0.1338,z:0.9172},{x:-0.407,y:-0.0856,z:0.9094},{x:-0.406,y:-0.1419,z:0.9028},{x:-0.4614,y:-0.1161,z:0.8795},{x:-0.4954,y:-0.1572,z:0.8543},{x:-0.4735,y:-0.2013,z:0.8575},{x:-0.5529,y:-0.168,z:0.8162},{x:-0.4737,y:-0.2264,z:0.8511},{x:-0.4053,y:-0.2586,z:0.8768},{x:-0.3598,y:-0.3663,z:0.8581},{x:-0.3688,y:-0.5542,z:0.7462},{x:-0.433,y:-0.6465,z:0.6282},{x:-0.3806,y:-0.7794,z:0.4977},{x:-0.3212,y:-0.8604,z:0.3956},{x:-0.3576,y:-0.7715,z:0.5262},{x:-0.2197,y:-0.924,z:0.313},{x:0.0463,y:-0.9711,z:0.2343},{x:0.1108,y:-0.9829,z:0.1468},{x:0.1636,y:-0.9786,z:0.125},{x:0.1918,y:-0.9704,z:0.147},{x:0.2199,y:-0.9734,z:0.0637},{x:0.1579,y:-0.9849,z:-0.0705},{x:0.2319,y:-0.939,z:-0.254},{x:0.3228,y:-0.8834,z:-0.3398},{x:0.2626,y:-0.7902,z:-0.5538},{x:0.2245,y:-0.7628,z:-0.6064},{x:0.1743,y:-0.5802,z:-0.7956}],[{x:0.2884,y:-0.169,z:0.9425},{x:0.258,y:-0.135,z:0.9567},{x:0.2665,y:-0.0991,z:0.9587},{x:0.1582,y:-0.0467,z:0.9863},{x:0.0767,y:-0.1085,z:0.9911},{x:0.0709,y:-0.1896,z:0.9793},{x:0.2796,y:-0.3484,z:0.8947},{x:0.3541,y:-0.3522,z:0.8663}],[{x:-0.6199,y:0.4769,z:-0.6232},{x:-0.7027,y:0.3948,z:-0.5919},{x:-0.8027,y:0.4056,z:-0.4373},{x:-0.7799,y:0.5977,z:-0.1855},{x:-0.7366,y:0.6049,z:-0.3026},{x:-0.6881,y:0.6783,z:-0.2577},{x:-0.7106,y:0.6728,z:-0.2059},{x:-0.6562,y:0.7295,z:-0.193},{x:-0.6152,y:0.7435,z:-0.2623},{x:-0.5707,y:0.7852,z:-0.2406},{x:-0.487,y:0.8068,z:-0.3345},{x:-0.3773,y:0.8479,z:-0.3725},{x:-0.3439,y:0.7982,z:-0.4946},{x:-0.4027,y:0.7092,z:-0.5787},{x:-0.5375,y:0.6569,z:-0.5288},{x:-0.616,y:0.5528,z:-0.5612}],[{x:0.195,y:-0.4301,z:0.8815},{x:0.1489,y:-0.3678,z:0.9179},{x:0.1884,y:-0.3839,z:0.9039},{x:0.1903,y:-0.3474,z:0.9182},{x:0.0234,y:-0.286,z:0.9579},{x:0.0282,y:-0.3259,z:0.945},{x:0.1146,y:-0.3675,z:0.9229},{x:0.1043,y:-0.411,z:0.9056}],[{x:0.3616,y:0.0008,z:-0.9323},{x:0.2757,y:-0.095,z:-0.9565},{x:0.1623,y:-0.1217,z:-0.9792},{x:0.1207,y:-0.2253,z:-0.9668},{x:0.2426,y:-0.377,z:-0.8939},{x:0.0849,y:-0.3383,z:-0.9372},{x:0.0888,y:-0.2744,z:-0.9575},{x:-0.0569,y:-0.3062,z:-0.9503},{x:-0.1779,y:-0.2219,z:-0.9587},{x:-0.2086,y:0.0366,z:-0.9773},{x:-0.3158,y:0.0556,z:-0.9472},{x:-0.2925,y:0.2905,z:-0.9111},{x:-0.0938,y:0.4102,z:-0.9072},{x:0.056,y:0.4063,z:-0.912},{x:0.0955,y:0.3336,z:-0.9379},{x:0.2419,y:0.3294,z:-0.9127},{x:0.3116,y:0.1986,z:-0.9292},{x:0.3043,y:0.1373,z:-0.9426}],[{x:-0.8538,y:0.5009,z:-0.1421},{x:-0.7416,y:0.6703,z:-0.0256},{x:-0.709,y:0.7032,z:-0.0528},{x:-0.6683,y:0.7438,z:-0.0045},{x:-0.6686,y:0.741,z:-0.0628},{x:-0.74,y:0.6658,z:-0.0956},{x:-0.7476,y:0.6484,z:-0.1438},{x:-0.7854,y:0.5973,z:-0.1622},{x:-0.8088,y:0.5738,z:-0.129}],[{x:0.412,y:-0.5346,z:0.7379},{x:0.3479,y:-0.5141,z:0.784},{x:0.3439,y:-0.5681,z:0.7477},{x:0.3846,y:-0.5658,z:0.7293}],[{x:-0.476,y:0.8794,z:0.0094},{x:-0.4487,y:0.8918,z:0.0578},{x:-0.4865,y:0.8683,z:0.0968},{x:-0.4544,y:0.8824,z:0.1219},{x:-0.3257,y:0.9452,z:0.0238},{x:-0.3543,y:0.9338,z:-0.0508},{x:-0.4199,y:0.9043,z:-0.0771}],[{x:0.6229,y:-0.0015,z:0.7823},{x:0.5351,y:-0.0161,z:0.8447},{x:0.5191,y:-0.045,z:0.8535},{x:0.5664,y:-0.054,z:0.8224},{x:0.6044,y:-0.0332,z:0.796},{x:0.6377,y:-0.0634,z:0.7677}],[{x:-0.6002,y:0.5602,z:0.5709},{x:-0.63,y:0.5126,z:0.5834},{x:-0.5865,y:0.4671,z:0.6617},{x:-0.5851,y:0.5637,z:0.583},{x:-0.5406,y:0.6248,z:0.5634},{x:-0.5876,y:0.603,z:0.5395}],[{x:0.617,y:0.664,z:-0.4225},{x:0.6136,y:0.7434,z:-0.2664},{x:0.6383,y:0.7414,z:-0.2071},{x:0.6869,y:0.6617,z:-0.3006},{x:0.6624,y:0.6263,z:-0.4111}],[{x:-0.5157,y:0.8519,z:-0.0911},{x:-0.5141,y:0.857,z:-0.0346},{x:-0.5742,y:0.8181,z:0.0314},{x:-0.5062,y:0.8623,z:0.0162},{x:-0.4805,y:0.8757,z:-0.0484}],[{x:0.4193,y:-0.1148,z:0.9006},{x:0.3867,y:-0.0987,z:0.9169},{x:0.3781,y:-0.1507,z:0.9134},{x:0.4088,y:-0.1714,z:0.8964}],[{x:0.6119,y:-0.0864,z:0.7862},{x:0.5713,y:-0.0666,z:0.818},{x:0.5764,y:-0.1031,z:0.8107},{x:0.605,y:-0.1146,z:0.7879}],[{x:-0.7522,y:0.0451,z:-0.6574},{x:-0.8171,y:0.0431,z:-0.5749},{x:-0.8274,y:0.0859,z:-0.555},{x:-0.7623,y:0.0812,z:-0.6421}],[{x:-0.2696,y:0.958,z:-0.0974},{x:-0.2767,y:0.9593,z:-0.0563},{x:-0.2353,y:0.9719,z:0.0031},{x:-0.0907,y:0.9911,z:0.0973}],[{x:0.2428,y:-0.9068,z:0.3446},{x:0.1414,y:-0.9078,z:0.3949},{x:0.0949,y:-0.9173,z:0.3867},{x:0.1925,y:-0.9144,z:0.3562},{x:0.2009,y:-0.9193,z:0.3384}],[{x:0.0223,y:-0.7332,z:0.6796},{x:0.0589,y:-0.6836,z:0.7275},{x:-0.0229,y:-0.6822,z:0.7308},{x:0.0178,y:-0.6568,z:0.7539},{x:0.1038,y:-0.6978,z:0.7087},{x:0.0942,y:-0.7242,z:0.6831},{x:0.0629,y:-0.698,z:0.7134},{x:0.0448,y:-0.7453,z:0.6652}],[{x:0.4824,y:0.5331,z:0.6951},{x:0.4116,y:0.5444,z:0.7309},{x:0.4499,y:0.5682,z:0.689},{x:0.4702,y:0.6478,z:0.5994},{x:0.521,y:0.5986,z:0.6085}],[{x:0.3431,y:-0.8806,z:0.3269},{x:0.2745,y:-0.8987,z:0.3421},{x:0.2662,y:-0.9088,z:0.3212},{x:0.3042,y:-0.8984,z:0.3167}],[{x:-0.5955,y:0.4446,z:0.6691},{x:-0.6012,y:0.4083,z:0.6869},{x:-0.5515,y:0.4322,z:0.7135},{x:-0.5679,y:0.4685,z:0.6767},{x:-0.5955,y:0.4446,z:0.6691},{x:-0.5955,y:0.4446,z:0.6691}]];

  // Constellation stick figures (verbatim from the main timeline).
  var CONSTELLATIONS = {
    bigDipper: { inUse: false, paths: [{ m: 0, b: 1, e: 7 }], stars: [
      { dec: 61.75092, ra: 11.06215 }, { dec: 56.38236, ra: 11.03068 }, { dec: 53.69475, ra: 11.89717 },
      { dec: 57.03258, ra: 12.25709 }, { dec: 55.95989, ra: 12.90048 }, { dec: 54.92539, ra: 13.39875 },
      { dec: 49.31336, ra: 13.79235 }] },
    orion: { inUse: false, paths: [{ m: 0, b: 1, e: 5 }, { m: 1, b: 5, e: 6 }, { m: 3, b: 6, e: 7 }], stars: [
      { dec: 7.40706, ra: 5.91953 }, { dec: -1.94257, ra: 5.67931 }, { dec: -1.20192, ra: 5.60356 },
      { dec: -0.29909, ra: 5.53344 }, { dec: 6.3497, ra: 5.41885 }, { dec: -9.6696, ra: 5.79594 },
      { dec: -8.20164, ra: 5.2423 }] },
    southernCross: { inUse: false, paths: [{ m: 0, b: 1, e: 2 }, { m: 2, b: 3, e: 4 }], stars: [
      { dec: -63.09905, ra: 12.4433 }, { dec: -57.11321, ra: 12.51943 },
      { dec: -59.68876, ra: 12.79535 }, { dec: -58.74893, ra: 12.25242 }] }
  };
  var CONSTELLATION_NAMES = { bigDipper: 'Big Dipper', orion: 'Orion', southernCross: 'Southern Cross' };

  /* ======================================================================
     Vector assets reused as-is from the decompiled export (never redrawn).
     Each entry records the symbol's registration point inside its SVG so the
     art lands exactly where the Flash movie clip's origin was.
     ====================================================================== */
  var ASSETS = {
    star:        { src: 'assets/star.svg',                 w: 21.9,   h: 21.15,  ox: 10.95, oy: 10.55 },
    starHi:      { src: 'assets/star-hi.svg',              w: 21.9,   h: 21.15,  ox: 10.95, oy: 10.55 },
    cstar:       { src: 'assets/cstar.svg',                w: 21.9,   h: 21.15,  ox: 10.95, oy: 10.55 },
    cstarHi:     { src: 'assets/cstar-hi.svg',             w: 21.9,   h: 21.15,  ox: 10.95, oy: 10.55 },
    stickfigure: { src: 'assets/stickfigure.svg',          w: 14.6,   h: 36.3,   ox: 7.3,   oy: 35.3 },
    observerDot: { src: 'assets/observer-dot.svg',         w: 7.5,    h: 7.5,    ox: 3.75,  oy: 3.75 },
    grayDot:     { src: 'assets/small-gray-dot.svg',       w: 4.95,   h: 4.95,   ox: 2.5,   oy: 2.5 },
    cursor:      { src: 'assets/location-cursor.svg',      w: 13,     h: 13,     ox: 6.5,   oy: 6.5 },
    hpAbove:     { src: 'assets/horizon-plane-above.svg',  w: 199.95, h: 200,    ox: 99.95, oy: 100 },
    hpBelow:     { src: 'assets/horizon-plane-below.svg',  w: 199.95, h: 200,    ox: 99.95, oy: 100 },
    shadingA:    { src: 'assets/shading-layer-a.svg',      w: 200,    h: 200,    ox: 100,   oy: 100 },
    shadingB:    { src: 'assets/shading-layer-b.svg',      w: 200,    h: 200,    ox: 100,   oy: 100 },
    globeWater:  { src: 'assets/globe-water.svg',          w: 80,     h: 80,     ox: 40,    oy: 40 },
    globeLand:   { src: 'assets/globe-land.svg',           w: 80,     h: 80,     ox: 40,    oy: 40 }
  };
  var assetsPending = 0, assetsReady = false;
  function loadAssets(done) {
    var keys = Object.keys(ASSETS);
    assetsPending = keys.length;
    keys.forEach(function (k) {
      var a = ASSETS[k], img = new Image();
      a.img = img;
      img.onload = img.onerror = function () { if (--assetsPending === 0) { assetsReady = true; done(); } };
      img.src = a.src;
    });
  }
  // Draw an asset centred on its Flash registration point, at 1:1 stage scale.
  function drawAsset(ctx, a, scale) {
    if (!a.img || !a.img.complete || !a.img.naturalWidth) return;
    var s = (scale == null) ? 1 : scale;
    ctx.drawImage(a.img, -a.ox * s, -a.oy * s, a.w * s, a.h * s);
  }

  /* ======================================================================
     Scene construction -- a direct transcription of the AS init()
     ====================================================================== */
  var SPHERE_SIZE = 350;
  var CX = 217.5, CY = 200;          // sphere centre inside the 435 x 415 canvas

  var sphere1 = new Sphere(SPHERE_SIZE);
  var sphere2 = new Sphere(SPHERE_SIZE);
  var globeSphere = new Sphere(60);  // the little Earth inside sphere1

  sphere1._lat = 90 * D2R; sphere1._sTime = 0; sphere1._showHorizonPlane = false;
  sphere1.doM(); sphere1.doB();
  globeSphere._lat = 90 * D2R; globeSphere._sTime = 0; globeSphere._showHorizonPlane = false;
  globeSphere.doM(); globeSphere.doB();
  sphere2.setTheta(145);
  sphere1.setThetaAndPhi(100, 20);
  sphere2._minPhi = 7;               // sphere2.minViewerAltitude = 7

  // --- colour constants (verbatim decimal RGB) ---
  var raColor  = 16756912;   // #FFB130  RA arc / label
  var decColor = 16777136;   // #FFFFB0  declination arc / label
  var azColor  = 12632319;   // #C0C0FF  azimuth arc / label
  var altColor = 16777215;   // #FFFFFF  altitude arc / label
  var angleColor = 13684944; // #D0D0D0  celestial-equator/horizon angle
  var BAND = {
    neverRise:  { innerAlpha: 30, innerColor: 6316256 },   // #6060E0
    neverSet:   { innerAlpha: 30, innerColor: 14704736 },  // #E06060
    riseAndSet: { innerAlpha: 30, innerColor: 14737632 }   // #E0E0E0
  };

  function addBand(sphere, opts) { var b = new ShadedBand(sphere, opts); sphere.bands.push(b); return b; }
  function addCircle(sphere, style, def) { var c = new Circle(sphere, style, def); sphere.circles.push(c); return c; }
  function addLine(sphere, style, h, t) { var l = new Line(sphere, style, h, t); sphere.lines.push(l); return l; }
  function addObject(sphere, kind, pos, opts) { var o = new SphereObject(sphere, kind, pos, opts); sphere.objects.push(o); return o; }

  var B1 = {}, B2 = {}, C1 = {}, C2 = {}, O1 = {}, O2 = {}, GO = {};

  // Shaded declination bands (order matters -- it fixes their draw order).
  ['neverRise', 'neverSet', 'riseAndSet'].forEach(function (n) {
    B2[n] = addBand(sphere2, BAND[n]); B1[n] = addBand(sphere1, BAND[n]);
    B2[n].setBorderStyle(1, 8421504, 100); B1[n].setBorderStyle(1, 8421504, 100);
    B2[n].showBorder = true; B1[n].showBorder = true;
  });

  // Grey graticule circles (alpha 30) and the two labelled celestial circles.
  [sphere1, sphere2].forEach(function (sp, i) {
    var C = i === 0 ? C1 : C2;
    C.meridian1 = addCircle(sp, { thickness: 1, color: 14737632, alpha: 30 }, { alt: 0, az: 0,  tilt: 90 });
    C.meridian2 = addCircle(sp, { thickness: 1, color: 14737632, alpha: 30 }, { alt: 0, az: 90, tilt: 90 });
    if (i === 0) C.meridian3 = addCircle(sp, { thickness: 1, color: 14737632, alpha: 30 }, { alt: 0, az: 0, tilt: 0 });
    C.zeroHoursCircle  = addCircle(sp, { thickness: 1, color: 16769909, alpha: 100 }, { ra: 0, dec: 0, tilt: 90, gammaStart: -90, gammaEnd: 90 });
    C.celestialEquator = addCircle(sp, { thickness: 1, color: 16769909, alpha: 100 }, { ra: 0, dec: 0, tilt: 0 });
  });

  // Selected-star coordinate arcs and their value labels.
  O1.raLabel  = addObject(sphere1, 'cslabel', { ra: 0, dec: 0 }, { color: raColor });
  O1.decLabel = addObject(sphere1, 'cslabel', { ra: 0, dec: 0 }, { color: decColor });
  C1.raArc  = addCircle(sphere1, { thickness: 3, color: raColor,  alpha: 100 }, { ra: 0, dec: 0, tilt: 0 });
  C1.decArc = addCircle(sphere1, { thickness: 3, color: decColor, alpha: 100 }, { ra: 0, dec: 0, tilt: 0 });
  O2.azLabel  = addObject(sphere2, 'cslabel', { alt: 0, az: 0 }, { color: azColor });
  O2.altLabel = addObject(sphere2, 'cslabel', { alt: 0, az: 0 }, { color: altColor });
  C2.azArc  = addCircle(sphere2, { thickness: 3, color: azColor,  alpha: 100 }, { az: 0, alt: 0, tilt: 0 });
  C2.altArc = addCircle(sphere2, { thickness: 3, color: altColor, alpha: 100 }, { az: 0, alt: 0, tilt: 0 });

  O2.angle1Label = addObject(sphere2, 'cslabel', { alt: 0, az: 0 }, { color: angleColor });
  O2.angle2Label = addObject(sphere2, 'cslabel', { alt: 0, az: 0 }, { color: angleColor });
  C2.angle1Circle = addCircle(sphere2, { thickness: 2, color: angleColor, alpha: 100 }, { alt: 0, az: 0, tilt: 0 });
  C2.angle2Circle = addCircle(sphere2, { thickness: 2, color: angleColor, alpha: 100 }, { alt: 0, az: 0, tilt: 0 });
  O1.raLabel.visible = O1.decLabel.visible = O2.azLabel.visible = O2.altLabel.visible = false;

  // The Earth globe lives inside sphere1 as an object holding a nested sphere.
  O1.globeSphere = addObject(sphere1, 'globe', { x: 0, y: 0, z: 0, system: 'celestial' });
  globeSphere.setThetaAndPhi(sphere1.getTheta(), sphere1.getPhi());
  GO.observerDot     = addObject(globeSphere, 'observerDot', { ra: 0, dec: 0 });
  GO.latitudeCircle  = addCircle(globeSphere, { thickness: 0, color: 0, alpha: 30 }, { ra: 0, dec: 0, tilt: 0 });
  GO.longitudeCircle = addCircle(globeSphere, { thickness: 0, color: 0, alpha: 30 }, { ra: 0, dec: 0, tilt: 90, gammaStart: -90, gammaEnd: 90 });

  // Sphere labels (r > 1 so they float just outside the surface).
  O1.ncpLabel = addObject(sphere1, 'label', { ra: 0, dec:  85, r: 1.13 }, { text: 'ncp',   color: '#75a9ff' });
  O1.scpLabel = addObject(sphere1, 'label', { ra: 0, dec: -85, r: 1.13 }, { text: 'scp',   color: '#75a9ff' });
  O2.ncpLabel = addObject(sphere2, 'label', { ra: 0, dec:  85, r: 1.16 }, { text: 'ncp',   color: '#75a9ff' });
  O2.scpLabel = addObject(sphere2, 'label', { ra: 0, dec: -85, r: 1.16 }, { text: 'scp',   color: '#75a9ff' });
  O2.ncpLabel.setOrientationType('skewed', { ra: 0, dec: 90 });
  O2.scpLabel.setOrientationType('skewed', { ra: 0, dec: 90 });
  O1.celestialEquatorLabel = addObject(sphere1, 'label', { ra: 3, dec: 0, r: 1.1 }, { text: 'celestial equator', color: '#ffe375' });
  O2.celestialEquatorLabel = addObject(sphere2, 'label', { ra: 3, dec: 0, r: 1.1 }, { text: 'celestial equator', color: '#ffe375' });
  O1.celestialEquatorLabel.setOrientationType('absolute');
  O2.celestialEquatorLabel.setOrientationType('absolute');
  O1.zeroHoursLabel = addObject(sphere1, 'label', { ra: 0, dec: 45, r: 1.1 }, { text: '0h circle', color: '#ffe375' });
  O2.zeroHoursLabel = addObject(sphere2, 'label', { ra: 0, dec: 45, r: 1.1 }, { text: '0h circle', color: '#ffe375' });
  O1.zeroHoursLabel.setOrientationType('absolute', { ra: 0, dec: 45 }, { ra: 18, dec: 0 });
  O2.zeroHoursLabel.setOrientationType('absolute', { ra: 0, dec: 45 }, { ra: 18, dec: 0 });
  O2.meridianLabel = addObject(sphere2, 'label', { az: 180, alt: 45, r: 1.1 }, { text: 'meridian', color: '#cccccc' });
  O2.meridianLabel.setOrientationType('absolute', { az: 180, alt: 45 }, { az: 270, alt: 0 });
  O2.zenithLabel = addObject(sphere2, 'label', { az: 0, alt:  90, r: 1.09 }, { text: 'zenith', color: '#cccccc' });
  O2.nadirLabel  = addObject(sphere2, 'label', { az: 0, alt: -90, r: 1.09 }, { text: 'nadir',  color: '#cccccc' });
  O2.zenithLabel.setOrientationType('skewed', { az: 0, alt: 90 });
  O2.nadirLabel.setOrientationType('skewed', { az: 0, alt: 90 });
  O2.zenithDot = addObject(sphere2, 'grayDot', { az: 0, alt:  90 });
  O2.nadirDot  = addObject(sphere2, 'grayDot', { az: 0, alt: -90 });
  O2.zenithDot.setOrientationType('absolute');
  O2.nadirDot.setOrientationType('absolute');
  [O1.ncpLabel, O1.scpLabel, O1.celestialEquatorLabel, O1.zeroHoursLabel,
   O2.ncpLabel, O2.scpLabel, O2.celestialEquatorLabel, O2.zeroHoursLabel,
   O2.meridianLabel, O2.zenithLabel, O2.nadirLabel, O2.zenithDot, O2.nadirDot
  ].forEach(function (o) { o.visible = false; });

  // The rotation axis stubs poking out of each pole.
  [sphere1, sphere2].forEach(function (sp) {
    addLine(sp, { thickness: 2, color: 7711231, alpha: 100 }, { x: 0, y: 0, z:  1, system: 'celestial' }, { x: 0, y: 0, z:  1.2, system: 'celestial' });
    addLine(sp, { thickness: 2, color: 7711231, alpha: 100 }, { x: 0, y: 0, z: -1, system: 'celestial' }, { x: 0, y: 0, z: -1.2, system: 'celestial' });
  });

  O2.stickfigure = addObject(sphere2, 'stickfigure', { x: 0, y: 0, z: 0, system: 'horizon' }, { scale: 1.2 });
  O2.stickfigure.setOrientationType('absolute', { x: -1, y: 0, z: 0, system: 'horizon' }, { x: 0, y: 0, z: 1, system: 'horizon' });

  /* ======================================================================
     Controller state
     ====================================================================== */
  var state = {
    time: 0,                     // days
    observerLatitude: 40.8,
    observerLongitude: mod(-96.7, 360),
    selectedStar: null,
    animating: false,
    animateTill: null,
    rate: 0.05,                  // days of simulated time per real second
    maxTrailLength: 0,
    trailType: 'none'
  };
  var starCounter = 0, starsList = [], STAR_LIMIT = 50;
  var stars = {};                // id -> { o1, o2, trail, isConstellation, constellation, trailLength }
  var constellationArcs = {};    // constellation name -> [ {c1, c2} ]
  var hoveredStar = null;

  var els = {};
  ['sphere1-canvas', 'sphere2-canvas', 'map-canvas', 'sphere1-handle', 'sphere2-handle', 'map-handle',
   'sphere1-desc', 'sphere2-desc', 'map-desc', 'sr-status',
   'star-eq-strip', 'star-hz-strip', 'ra-field', 'dec-field', 'az-field', 'alt-field',
   'lat-field', 'dec-field', 'lon-field', 'lat-dir', 'lon-dir',
   'btn-animate', 'animate-duration', 'rate-slider',
   'cb-labels', 'cb-zerohours', 'cb-celequator', 'cb-showunder',
   'cb-neverrise', 'cb-riseset', 'cb-neverset', 'cb-angle',
   'btn-patterns', 'patterns-menu', 'btn-addstar', 'btn-removestars', 'btn-resettrails',
   'cb-bigDipper', 'cb-orion', 'cb-southernCross'
  ].forEach(function (id) { els[id] = document.getElementById(id); });

  var ctx1 = els['sphere1-canvas'].getContext('2d');
  var ctx2 = els['sphere2-canvas'].getContext('2d');
  var ctxMap = els['map-canvas'].getContext('2d');

  var prefersReducedMotion = window.matchMedia &&
      window.matchMedia('(prefers-reduced-motion: reduce)').matches;

  /* ---------------- animation-rate slider (logarithmic, 0.01 .. 0.2) ----- */
  var RATE_MIN = 0.01, RATE_MAX = 0.2;
  function sliderToRate(v) { return RATE_MIN * Math.pow(RATE_MAX / RATE_MIN, v / 1000); }
  function rateToSlider(r) { return Math.round(1000 * Math.log(r / RATE_MIN) / Math.log(RATE_MAX / RATE_MIN)); }

  /* ======================================================================
     Behaviour -- ports of the main-timeline functions
     ====================================================================== */

  // updateBands(): which declinations never rise / never set at this latitude.
  function updateBands() {
    var lat = state.observerLatitude, upper, lower;
    function set(rs, nr, ns) {
      B1.riseAndSet.setParameters(rs); B2.riseAndSet.setParameters(rs);
      B1.neverRise.setParameters(nr);  B2.neverRise.setParameters(nr);
      B1.neverSet.setParameters(ns);   B2.neverSet.setParameters(ns);
    }
    if (lat >= 90)      set(null, { dec1: -90, dec2: 0 }, { dec1: 0, dec2: 90 });
    else if (lat <= -90) set(null, { dec1: 0, dec2: 90 }, { dec1: 0, dec2: -90 });
    else if (lat > 0) {
      upper = 90 - lat; lower = -upper;
      set({ dec1: lower, dec2: upper }, { dec1: -90, dec2: lower }, { dec1: upper, dec2: 90 });
    } else if (lat < 0) {
      upper = 90 + lat; lower = -upper;
      set({ dec1: lower, dec2: upper }, { dec1: 90, dec2: upper }, { dec1: lower, dec2: -90 });
    } else {
      set({ dec1: -90, dec2: 90 }, null, null);
    }
  }

  // setLocation(): the single entry point for changing the observer's position.
  function setLocation(pt, announce) {
    var lat = pt.lat, lon = pt.lon;
    if (lat > 90) lat = 90; else if (lat < -90) lat = -90;
    lon = mod(lon, 360);
    state.observerLatitude = lat;
    state.observerLongitude = lon;

    if (lon > 180) { els['lon-field'].value = asFixed(Math.abs(lon - 360), 1); els['lon-dir'].value = 'W'; }
    else           { els['lon-field'].value = asFixed(lon, 1);                 els['lon-dir'].value = 'E'; }
    if (lat < 0)   { els['lat-field'].value = asFixed(Math.abs(lat), 1);       els['lat-dir'].value = 'S'; }
    else           { els['lat-field'].value = asFixed(lat, 1);                 els['lat-dir'].value = 'N'; }

    updateAngle();
    GO.latitudeCircle.setParameters({ ra: 0, tilt: 0, dec: lat });
    GO.observerDot.setPosition({ ra: 0, dec: lat });
    GO.observerDot.setOrientationType('absolute');

    var rotAngle = (state.time % 1) * 360, sidereal = (lon + rotAngle) / 15;
    globeSphere.setSiderealTime(-sidereal);
    globeRotationAngle = rotAngle;
    sphere2.setSTimeAndLat(sidereal, lat);
    if (state.selectedStar != null) updateHorizonArcs();
    updateBands();
    if (announce) {
      announceStatus('Observer at latitude ' + spoken(lat, 1) + ' degrees, longitude ' +
        spoken(lon > 180 ? lon - 360 : lon, 1) + ' degrees.');
    }
  }

  var globeRotationAngle = 0;

  // update(): advance every derived quantity from state.time.
  function update() {
    var rotAngle = (state.time % 1) * 360,
        sidereal = (state.observerLongitude + rotAngle) / 15;
    globeSphere.setSiderealTime(-sidereal);
    globeRotationAngle = rotAngle;
    sphere2.setSiderealTime(sidereal);
    if (state.selectedStar != null) updateHorizonArcs();
    updateConstellationArcs();
  }

  function updateConstellationArcs() {
    for (var name in constellationArcs) {
      var arcs = constellationArcs[name];
      for (var i = 0; i < arcs.length; i++) { /* geometry is static; only the view changes */ }
    }
  }

  // updateCelestialArcs(): the RA and declination arcs plus their value labels.
  function updateCelestialArcs() {
    var st = stars[state.selectedStar]; if (!st) return;
    var p = {};
    st.o1.getPositionCelestial(p);
    if (p.dec < -0.0001)     C1.decArc.setParameters({ ra: p.ra, dec: 0, tilt: 90, gammaStart: p.dec, gammaEnd: 0 });
    else if (p.dec > 0.0001) C1.decArc.setParameters({ ra: p.ra, dec: 0, tilt: 90, gammaStart: 0, gammaEnd: p.dec });
    else                     C1.decArc.setParameters({ ra: p.ra, dec: 0, tilt: 90, gammaStart: 0, gammaEnd: 0.001 });
    if (p.ra < 0.000001)     C1.raArc.setParameters({ ra: 0, dec: 0, tilt: 0, gammaStart: 0, gammaEnd: 0.001 });
    else                     C1.raArc.setParameters({ ra: 0, dec: 0, tilt: 0, gammaStart: 0, gammaEnd: 15 * p.ra });

    var raStr = asFixed(p.ra, 1), decStr = asFixed(p.dec, 1);
    if (document.activeElement !== els['ra-field'])  els['ra-field'].value  = raStr;
    if (document.activeElement !== els['dec-field']) els['dec-field'].value = decStr;
    O1.decLabel.labelText = decStr + '°';
    O1.decLabel.setPosition({ ra: p.ra + 0.9, dec: p.dec / 2, r: 1.001 });
    O1.decLabel.setOrientationType('absolute');
    O1.raLabel.labelText = raStr + 'h';
    O1.raLabel.setPosition({ ra: p.ra - 0.9, dec: 5, r: 1.001 });
    O1.raLabel.setOrientationType('absolute');
  }

  // updateHorizonArcs(): the azimuth and altitude arcs plus their value labels.
  function updateHorizonArcs() {
    var st = stars[state.selectedStar]; if (!st) return;
    var p = {};
    st.o2.getPositionHorizon(p);
    if (p.alt < -0.0001)     C2.altArc.setParameters({ az: p.az, alt: 0, tilt: 90, gammaStart: p.alt, gammaEnd: 0 });
    else if (p.alt > 0.0001) C2.altArc.setParameters({ az: p.az, alt: 0, tilt: 90, gammaStart: 0, gammaEnd: p.alt });
    else                     C2.altArc.setParameters({ az: p.az, alt: 0, tilt: 90, gammaStart: 0, gammaEnd: 0.001 });
    if (p.az < 0.0001)       C2.azArc.setParameters({ az: 0, alt: 0, tilt: 0, gammaStart: 0, gammaEnd: 0.001 });
    else                     C2.azArc.setParameters({ az: 0, alt: 0, tilt: 0, gammaStart: 360 - p.az, gammaEnd: 0 });

    var azStr = asFixed(p.az, 1), altStr = asFixed(p.alt, 1);
    if (document.activeElement !== els['az-field'])  els['az-field'].value  = azStr;
    if (document.activeElement !== els['alt-field']) els['alt-field'].value = altStr;
    O2.altLabel.labelText = altStr + '°';
    O2.altLabel.setPosition({ az: p.az + 13, alt: p.alt / 2, r: 1.001 });
    O2.altLabel.setOrientationType('absolute');
    O2.azLabel.labelText = azStr + '°';
    O2.azLabel.setPosition({ az: p.az - 13, alt: 5, r: 1.001 });
    O2.azLabel.setOrientationType('absolute');
  }

  // updateAngle(): the wedge showing the celestial equator / horizon angle.
  var angleText = '0°';
  function updateAngle() {
    if (!els['cb-angle'].checked) return;
    var LABEL_ARC = 0.4363323129985824, SPAN = 20, ALT = 90 - SPAN,
        lat = state.observerLatitude, txt, half, dir;

    if (lat >= 90) {
      txt = '0°';
      C2.angle1Circle.setParameters({ az: 0, tilt: 0, alt: 0, gammaStart: 270 - SPAN, gammaEnd: 270 });
      C2.angle2Circle.setParameters({ az: 0, tilt: 0, alt: 0, gammaStart: 90, gammaEnd: 90 + SPAN });
      half = 0; dir = 1;
    } else if (lat >= 0) {
      txt = asFixed(90 - lat, 1) + '°';
      C2.angle1Circle.setParameters({ az: 0, tilt: 90, alt:  ALT, gammaStart: 90 + lat, gammaEnd: 180 });
      C2.angle2Circle.setParameters({ az: 0, tilt: 90, alt: -ALT, gammaStart: 90 + lat, gammaEnd: 180 });
      half = (90 - lat) / 2 * PI / 180; dir = 1;
    } else if (lat > -90) {
      txt = asFixed(90 + lat, 1) + '°';
      C2.angle1Circle.setParameters({ az: 0, tilt: 90, alt:  ALT, gammaStart: 0, gammaEnd: 90 + lat });
      C2.angle2Circle.setParameters({ az: 0, tilt: 90, alt: -ALT, gammaStart: 0, gammaEnd: 90 + lat });
      half = (90 + lat) / 2 * PI / 180; dir = -1;
    } else {
      txt = '0°';
      C2.angle1Circle.setParameters({ az: 0, tilt: 0, alt: 0, gammaStart: 270, gammaEnd: 270 + SPAN });
      C2.angle2Circle.setParameters({ az: 0, tilt: 0, alt: 0, gammaStart: 90 - SPAN, gammaEnd: 90 });
      half = 0; dir = -1;
    }
    angleText = txt;
    var lAlt = R2D * Math.asin(Math.sin(half) * Math.sin(LABEL_ARC)),
        lAz  = R2D * Math.atan(Math.cos(half) * Math.tan(LABEL_ARC)),
        p1 = { alt: lAlt, az: 90 + dir * lAz },
        p2 = { alt: lAlt, az: 270 - dir * lAz },
        up = (dir === -1) ? { az: 0, alt: half * 180 / PI } : { az: 180, alt: half * 180 / PI };
    O2.angle1Label.setPosition(p1); O2.angle2Label.setPosition(p2);
    O2.angle1Label.setOrientationType('absolute', p1, up);
    O2.angle2Label.setOrientationType('absolute', p2, up);
    O2.angle1Label.labelText = txt; O2.angle2Label.labelText = txt;
  }

  /* ---------------- stars ------------------------------------------------ */
  function addStar(cp, isConstellationStar) {
    if (!isConstellationStar && starsList.length >= STAR_LIMIT) return null;
    var id = '_' + (starCounter++),
        o1 = addObject(sphere1, isConstellationStar ? 'cstar' : 'star', cp, { starID: id }),
        o2 = addObject(sphere2, isConstellationStar ? 'cstar' : 'star', cp, { starID: id }),
        trail = addCircle(sphere2, { thickness: 1, color: 16777215, alpha: 60 }, { ra: 0, dec: 0, tilt: 0 });
    trail.visible = false;
    o1.setPosition(cp); o2.setPosition(cp);
    o1.setOrientationType('absolute'); o2.setOrientationType('absolute');
    stars[id] = { id: id, o1: o1, o2: o2, trail: trail, trailLength: 0,
                  isConstellation: !!isConstellationStar, constellation: null };
    starsList.push(id);
    return id;
  }
  function addStarRandomly() {
    var cp = { dec: 180 * Math.random() - 90, ra: 24 * Math.random() };
    var id = addStar(cp);
    if (id) announceStatus('Star added at right ascension ' + spoken(cp.ra, 1) +
      ' hours, declination ' + spoken(cp.dec, 1) + ' degrees. ' + starsList.length + ' stars.');
    else announceStatus('Star limit of ' + STAR_LIMIT + ' reached; no star added.');
    render();
  }
  function removeStar(id) {
    var st = stars[id]; if (!st) return;
    if (state.selectedStar === id) deselectSelectedStar();
    removeFrom(sphere1.objects, st.o1);
    removeFrom(sphere2.objects, st.o2);
    removeFrom(sphere2.circles, st.trail);
    delete stars[id];
    var i = starsList.indexOf(id); if (i >= 0) starsList.splice(i, 1);
  }
  function removeAllStars(announce) {
    deselectSelectedStar();
    removeAllConstellations();
    starsList.slice().forEach(removeStar);
    starsList = [];
    if (announce) announceStatus('All stars removed.');
  }
  function removeFrom(arr, item) { var i = arr.indexOf(item); if (i >= 0) arr.splice(i, 1); }

  function selectStar(id) {
    state.selectedStar = id;
    els['star-eq-strip'].hidden = false;
    els['star-hz-strip'].hidden = false;
    C1.raArc.visible = C1.decArc.visible = true;
    C2.azArc.visible = C2.altArc.visible = true;
    O1.raLabel.visible = O1.decLabel.visible = true;
    O2.azLabel.visible = O2.altLabel.visible = true;
    updateCelestialArcs(); updateHorizonArcs();
    announceSelectedStar('Star selected.');
  }
  function deselectSelectedStar() {
    if (state.selectedStar != null) announceStatus('Star deselected.');
    state.selectedStar = null;
    els['star-eq-strip'].hidden = true;
    els['star-hz-strip'].hidden = true;
    C1.raArc.visible = C1.decArc.visible = false;
    C2.azArc.visible = C2.altArc.visible = false;
    O1.raLabel.visible = O1.decLabel.visible = false;
    O2.azLabel.visible = O2.altLabel.visible = false;
  }
  function moveStar(id, pt) {
    if (pt.ra == null) return;
    var st = stars[id]; if (!st) return;
    st.o1.setPosition(pt); st.o2.setPosition(pt);
    st.o1.setOrientationType('absolute'); st.o2.setOrientationType('absolute');
    updateCelestialArcs(); updateHorizonArcs();
    updateTrail(st);
  }

  /* ---------------- constellations --------------------------------------- */
  function addConstellation(name) {
    var con = CONSTELLATIONS[name];
    if (!con || con.inUse) return false;
    con.inUse = true;
    var i, arcs = [];
    for (i = 0; i < con.stars.length; i++) {
      var sid = addStar(con.stars[i], true);
      stars[sid].constellation = name;
      con.stars[i].starID = sid;
    }
    for (i = 0; i < con.paths.length; i++) {
      var path = con.paths[i], from = con.stars[path.m];
      for (var j = path.b; j < path.e; j++) {
        var to = con.stars[j],
            a1 = addCircle(sphere1, { thickness: 1, color: 16777215, alpha: 80 }, null),
            a2 = addCircle(sphere2, { thickness: 1, color: 16777215, alpha: 80 }, null);
        a1.setArcPoints(from, to); a2.setArcPoints(from, to);
        arcs.push({ c1: a1, c2: a2 });
        from = to;
      }
    }
    constellationArcs[name] = arcs;
    return true;
  }
  function removeConstellation(name) {
    var con = CONSTELLATIONS[name];
    if (!con || !con.inUse) return;
    con.inUse = false;
    for (var i = 0; i < con.stars.length; i++) removeStar(con.stars[i].starID);
    (constellationArcs[name] || []).forEach(function (a) {
      removeFrom(sphere1.circles, a.c1); removeFrom(sphere2.circles, a.c2);
    });
    delete constellationArcs[name];
  }
  function removeAllConstellations() {
    Object.keys(CONSTELLATIONS).forEach(function (n) {
      removeConstellation(n);
      var cb = els['cb-' + n]; if (cb) cb.checked = false;
    });
  }

  /* ---------------- star trails ------------------------------------------ */
  function updateTrail(st) {
    var dec = R2D * Math.asin(st.o2._p.z);
    if (st.trailLength === 360) {
      st.trail.setParameters({ ra: 0, dec: dec, tilt: 0 });
    } else {
      var g = R2D * Math.atan2(st.o2._p.y, st.o2._p.x);
      st.trail.setParameters({ ra: 0, dec: dec, tilt: 0, gammaStart: g, gammaEnd: g + st.trailLength });
    }
  }
  function setTrailLength(st, len) {
    st.trailLength = len;
    if (len === 0) { st.trail.visible = false; }
    else { updateTrail(st); st.trail.visible = true; }
  }
  function changeTrailType() {
    var v = document.querySelector('input[name="trailType"]:checked').value;
    state.trailType = v;
    if (v === 'none') {
      state.maxTrailLength = 0;
      starsList.forEach(function (id) { setTrailLength(stars[id], 0); });
    } else if (v === 'short') {
      state.maxTrailLength = 45;
      starsList.forEach(function (id) {
        if (stars[id].trailLength > 45) setTrailLength(stars[id], 45);
      });
    } else {
      state.maxTrailLength = 360;
    }
    render();
  }
  function resetTrails() {
    starsList.forEach(function (id) { setTrailLength(stars[id], 0); });
    announceStatus('Star trails reset.');
    render();
  }
  function growStarTrails(delta) {
    if (state.trailType === 'none') return;
    var max = state.maxTrailLength;
    starsList.forEach(function (id) {
      var st = stars[id], next = st.trailLength + delta;
      if (st.trailLength >= max) { if (max !== 360) updateTrail(st); }
      else { if (next > max) next = max; setTrailLength(st, next); }
    });
  }

  /* ---------------- appearance toggles ----------------------------------- */
  function changeShowLabels() {
    var on = els['cb-labels'].checked,
        zero = on && els['cb-zerohours'].checked,
        eq   = on && els['cb-celequator'].checked;
    O1.celestialEquatorLabel.visible = O2.celestialEquatorLabel.visible = eq;
    O1.zeroHoursLabel.visible = O2.zeroHoursLabel.visible = zero;
    O1.ncpLabel.visible = O1.scpLabel.visible = on;
    O2.ncpLabel.visible = O2.scpLabel.visible = on;
    O2.meridianLabel.visible = O2.zenithLabel.visible = O2.nadirLabel.visible = on;
    O2.zenithDot.visible = O2.nadirDot.visible = on;
    render();
  }
  function changeShow0hCircle() {
    var on = els['cb-zerohours'].checked, lbl = on && els['cb-labels'].checked;
    C1.zeroHoursCircle.visible = C2.zeroHoursCircle.visible = on;
    O1.zeroHoursLabel.visible = O2.zeroHoursLabel.visible = lbl;
    render();
  }
  function changeShowCelestialEquator() {
    var on = els['cb-celequator'].checked, lbl = on && els['cb-labels'].checked;
    C1.celestialEquator.visible = C2.celestialEquator.visible = on;
    O1.celestialEquatorLabel.visible = O2.celestialEquatorLabel.visible = lbl;
    render();
  }
  function changeShowUnder() { sphere2._showUnder = els['cb-showunder'].checked; render(); }
  function changeShowRiseSet()  { B1.riseAndSet.visible = B2.riseAndSet.visible = els['cb-riseset'].checked;  render(); }
  function changeShowNeverSet() { B1.neverSet.visible   = B2.neverSet.visible   = els['cb-neverset'].checked; render(); }
  function changeShowNeverRise(){ B1.neverRise.visible  = B2.neverRise.visible  = els['cb-neverrise'].checked; render(); }
  function changeShowAngle() {
    var on = els['cb-angle'].checked;
    if (on) updateAngle();
    O2.angle1Label.visible = O2.angle2Label.visible = on;
    C2.angle1Circle.visible = C2.angle2Circle.visible = on;
    render();
  }

  /* ---------------- animation -------------------------------------------- */
  var timeLast = 0, rafID = null;
  function frame() {
    rafID = null;
    if (!state.animating) return;
    var now = performance.now(), prev = state.time;
    state.time += state.rate * (now - timeLast) / 1000;
    if (state.animateTill != null && state.time > state.animateTill) {
      state.time = state.animateTill;
      toggleAnimation();
    }
    timeLast = now;
    update();
    growStarTrails(360 * (state.time - prev));
    render();
    if (state.animating) rafID = requestAnimationFrame(frame);
  }
  function pauseAnimation() { if (rafID != null) { cancelAnimationFrame(rafID); rafID = null; } }
  function resumeAnimation() {
    if (state.animating && rafID == null) { timeLast = performance.now(); rafID = requestAnimationFrame(frame); }
  }
  function toggleAnimation() {
    if (state.animating) {
      state.animating = false;
      els['btn-animate'].textContent = 'start animation';
      els['animate-duration'].disabled = false;
      pauseAnimation();
      announceStatus('Animation paused.');
    } else {
      var hours = parseInt(els['animate-duration'].value, 10);
      state.animateTill = (hours === 0) ? null : state.time + hours / 24;
      els['animate-duration'].disabled = true;
      els['btn-animate'].textContent = 'pause animation';
      state.animating = true;
      if (prefersReducedMotion && state.animateTill != null) {
        // Reduced motion: jump straight to the end state instead of tweening.
        state.time = state.animateTill;
        growStarTrails(360 * hours / 24);
        update();
        toggleAnimation();
        announceStatus('Reduced motion: advanced ' + hours + ' hours immediately.');
        return;
      }
      resumeAnimation();
      announceStatus(hours === 0 ? 'Animation started, running continuously.'
                                 : 'Animation started, running for ' + hours + ' hours.');
    }
  }

  /* ======================================================================
     Rendering
     ====================================================================== */

  // The four mask regions from "6 CS Shading.as", as canvas paths in sphere-
  // centred pixels. sign = +1 for the near rim (M1/M2), -1 for the far rim.
  function rimPath(sphere, sign, above) {
    var r = sphere._c.r, k = r / 100, box = 120 * k, R = 100 * k,
        sp = Math.sin(sphere._phi) * sign, p = new Path2D(),
        n = 4, step = PI / n, half = step / 2, cRad = 100 / Math.cos(half), i;
    var yEdge = above ? -box : box;
    p.moveTo(box, yEdge);
    p.lineTo(box, 0);
    p.lineTo(R, 0);
    var aA = step, cA = aA - half;
    for (i = 0; i < n; i++) {
      p.quadraticCurveTo(k * cRad * Math.cos(cA), k * sp * cRad * Math.sin(cA),
                         k * 100 * Math.cos(aA),  k * sp * 100 * Math.sin(aA));
      aA += step; cA += step;
    }
    p.lineTo(-box, 0);
    p.lineTo(-box, yEdge);
    p.closePath();
    return p;
  }
  function boxPath(sphere) {
    var box = 120 * sphere._c.r / 100, p = new Path2D();
    p.rect(-box, -box, 2 * box, 2 * box);
    return p;
  }

  function withClip(ctx, path, fn) {
    if (path === null) return;                 // hidden layer (mask M5)
    ctx.save();
    if (path) ctx.clip(path);
    fn();
    ctx.restore();
  }

  function drawCircles(ctx, sphere, which) {
    var i, c, a, spans, j;
    for (i = 0; i < sphere.circles.length; i++) {
      c = sphere.circles[i];
      if (!c.visible) continue;
      a = c.computeArcs();
      spans = (which === 'front') ? a.front : a.back;
      if (!spans.length) continue;
      ctx.beginPath();
      for (j = 0; j < spans.length; j++) emitArc(ctx, a.v, spans[j][0], spans[j][1], c._minStep);
      ctx.strokeStyle = css(c._color, c._alpha);
      ctx.lineWidth = c._thick || 1;           // AS thickness 0 means "hairline"
      ctx.stroke();
    }
  }

  function drawLines(ctx, sphere, layer) {
    for (var i = 0; i < sphere.lines.length; i++) {
      var ln = sphere.lines[i], segs = ln.computeSegments();
      ctx.strokeStyle = css(ln._color, ln._alpha);
      ctx.lineWidth = ln._thick;
      for (var j = 0; j < segs.length; j++) {
        if (segs[j].layer !== layer) continue;
        ctx.beginPath();
        ctx.moveTo(segs[j].x1, segs[j].y1);
        ctx.lineTo(segs[j].x2, segs[j].y2);
        ctx.stroke();
      }
    }
  }

  function drawBands(ctx, sphere, which) {
    var r = sphere._c.r, k = r / 100;
    for (var i = 0; i < sphere.bands.length; i++) {
      var b = sphere.bands[i], paths = b.buildPaths();
      if (!paths) continue;
      var fill = (which === 'front') ? paths.front : paths.back,
          border = (which === 'front') ? paths.fBorder : paths.bBorder;
      ctx.save();
      ctx.scale(k, k);                          // the band works in a 100-unit space
      ctx.save();
      ctx.clip(fill);
      ctx.fillStyle = css(b.color, b.alpha);
      ctx.fillRect(-100, -100, 200, 200);
      ctx.restore();
      if (b.showBorder) {
        ctx.strokeStyle = css(b._bColor, b._bAlpha);
        ctx.lineWidth = (b._bThick || 1) / k;
        ctx.stroke(border);
      }
      ctx.restore();
    }
  }

  // Objects are bucketed exactly as the AS depth arithmetic buckets them.
  function bucketObjects(sphere) {
    var buckets = { rGtBack: [], rEqBack: [], rLtA: [], rLtB: [], rEqFront: [], rGtFront: [] },
        hideUnder = !sphere._showUnder, i, o, w;
    for (i = 0; i < sphere.objects.length; i++) {
      o = sphere.objects[i];
      if (!o.visible) continue;
      if (o._r > 1 || o._r === 1) {
        if (hideUnder) {
          w = {};
          if (o._sys === 1) sphere.CtoW(o._p, w); else w = o._p;
          if (w.z < 0) continue;
        }
        o.update();
        var list = (o._r > 1)
          ? (o._sp.z < 0 ? buckets.rGtBack : buckets.rGtFront)
          : (o._sp.z < 0 ? buckets.rEqBack : buckets.rEqFront);
        list.push(o);
      } else {                                   // r < 1: inside the sphere
        w = {};
        if (o._sys === 1) sphere.CtoW(o._p, w); else w = o._p;
        if (hideUnder && w.z < 0) continue;
        o.update();
        if (!sphere._showHorizonPlane) { buckets.rLtA.push(o); continue; }
        if (sphere._phi < 0) (w.z < 0 ? buckets.rLtB : buckets.rLtA).push(o);
        else                 (w.z < 0 ? buckets.rLtA : buckets.rLtB).push(o);
      }
    }
    return buckets;
  }

  function drawObjects(ctx, list) {
    for (var i = 0; i < list.length; i++) drawObject(ctx, list[i]);
  }

  var LABEL_FONT = '10px SimVerdana, Verdana, Geneva, sans-serif';
  var VALUE_FONT = '14px SimVerdana, Verdana, Geneva, sans-serif';

  function drawObject(ctx, o) {
    ctx.save();
    ctx.translate(o._sp.x, o._sp.y);
    if (o._oType !== 0) {
      ctx.rotate(o.rotation);
      ctx.scale(1, o.yscale);
    }
    switch (o.kind) {
      case 'star':
      case 'cstar': {
        var isC = (o.kind === 'cstar'), hi = (hoveredStar === o.opts.starID && o._sp.z > 0);
        ctx.rotate(o.instRotation);
        var a = isC ? (hi ? ASSETS.cstarHi : ASSETS.cstar) : (hi ? ASSETS.starHi : ASSETS.star);
        drawAsset(ctx, a, isC ? 0.5 : 1);        // Constellation Star is at 50% scale
        break;
      }
      case 'grayDot':     drawAsset(ctx, ASSETS.grayDot); break;
      case 'observerDot': drawAsset(ctx, ASSETS.observerDot); break;
      case 'stickfigure':
        ctx.rotate(o.instRotation);
        drawAsset(ctx, ASSETS.stickfigure, o.opts.scale || 1);
        break;
      case 'label':
        ctx.rotate(o.instRotation);
        ctx.font = LABEL_FONT;
        ctx.fillStyle = o.opts.color;
        ctx.textAlign = 'center'; ctx.textBaseline = 'middle';
        ctx.fillText(o.opts.text, 0, 0);
        break;
      case 'cslabel':
        ctx.rotate(o.instRotation);
        ctx.font = VALUE_FONT;
        ctx.fillStyle = css(o.opts.color, 100);
        ctx.textAlign = 'center'; ctx.textBaseline = 'middle';
        ctx.fillText(o.labelText, 0, 0);
        break;
      case 'globe':
        drawGlobe(ctx);
        break;
    }
    ctx.restore();
  }

  // The Earth globe: reused water/land discs plus the code-drawn coastlines,
  // exactly as "GlobeComponent.as" builds them.
  function drawGlobe(ctx) {
    var GLOBE_SCALE = 0.75, RADIUS = 40, ic = globeSphere._c, f = RADIUS / ic.r,
        q = globeQ(),
        x0 = f * (ic.b0 * q.q0 + ic.b1 * q.q3 + ic.b2 * q.q6),
        x1 = f * (ic.b0 * q.q1 + ic.b1 * q.q4 + ic.b2 * q.q7),
        x2 = f * (ic.b0 * q.q2 + ic.b1 * q.q5 + ic.b2 * q.q8),
        y0 = f * (ic.b3 * q.q0 + ic.b4 * q.q3 + ic.b5 * q.q6),
        y1 = f * (ic.b3 * q.q1 + ic.b4 * q.q4 + ic.b5 * q.q7),
        y2 = f * (ic.b3 * q.q2 + ic.b4 * q.q5 + ic.b5 * q.q8),
        z0 = f * (ic.b6 * q.q0 + ic.b7 * q.q3 + ic.b8 * q.q6),
        z1 = f * (ic.b6 * q.q1 + ic.b7 * q.q4 + ic.b8 * q.q7),
        z2 = f * (ic.b6 * q.q2 + ic.b7 * q.q5 + ic.b8 * q.q8);

    ctx.save();
    ctx.scale(GLOBE_SCALE, GLOBE_SCALE);
    drawAsset(ctx, ASSETS.globeWater);

    // Coastline outlines, closed around the limb when they run off the far side.
    var limb = 1.5 * RADIUS, maxStep = 2 * Math.acos(RADIUS * 1.1 / limb), path = new Path2D();
    for (var pi = 0; pi < SHORE.length; pi++) {
      var poly = SHORE[pi], n = poly.length, prevVisible = false, start = 0, p;
      for (start = 0; start < n; start++) {
        p = poly[start];
        if (p.x * z0 + p.y * z1 + p.z * z2 > 0) {
          if (prevVisible) { path.moveTo(p.x * x0 + p.y * x1 + p.z * x2, p.x * y0 + p.y * y1 + p.z * y2); break; }
          prevVisible = true;
        } else prevVisible = false;
      }
      if (start === n) continue;
      var wasHidden = false, angleLast = 0;
      for (var j = 1; j < n; j++) {
        p = poly[(start + j) % n];
        var hidden = (p.x * z0 + p.y * z1 + p.z * z2) < 0;
        if (!hidden) {
          var px = p.x * x0 + p.y * x1 + p.z * x2, py = p.x * y0 + p.y * y1 + p.z * y2;
          if (wasHidden) {
            var ang = Math.atan2(py, px), d = mod(ang - angleLast, TWO_PI), steps, inc;
            if (d > PI) { d = TWO_PI - d; steps = Math.ceil(d / maxStep); inc = -d / steps; }
            else { steps = Math.ceil(d / maxStep); inc = d / steps; }
            for (var s = 1; s <= steps; s++) {
              var t = angleLast + inc * s;
              path.lineTo(limb * Math.cos(t), limb * Math.sin(t));
            }
          }
          path.lineTo(px, py);
        } else if (!wasHidden) {
          var qx = p.x * x0 + p.y * x1 + p.z * x2, qy = p.x * y0 + p.y * y1 + p.z * y2;
          angleLast = Math.atan2(qy, qx);
          path.lineTo(limb * Math.cos(angleLast), limb * Math.sin(angleLast));
        }
        wasHidden = hidden;
      }
      path.closePath();
    }
    ctx.save();
    ctx.clip(path);
    drawAsset(ctx, ASSETS.globeLand);
    ctx.restore();
    ctx.restore();
  }

  // Earth's own rotation combined with its 23.44 deg axial tilt (setRotationAngle
  // / setPrecessionAngle; 0.91706 = cos(23.44 deg), 0.39875 = sin(23.5 deg)).
  function globeQ() {
    var a = globeSphere._sTime + globeRotationAngle * D2R,
        ca = Math.cos(a), sa = Math.sin(a),
        r0 = ca, r1 = -sa, r3 = sa * 0.91706, r4 = ca * 0.91706, r5 = 0.39875,
        r6 = -sa * 0.39875, r7 = -ca * 0.39875, r8 = 0.91706,
        p0 = 1, p1 = 0, p3 = 0, p4 = 0.91706, p5 = -0.39875, p6 = 0, p7 = 0.39875, p8 = 0.91706;
    return {
      q0: p0 * r0 + p1 * r3, q1: p0 * r1 + p1 * r4, q2: p1 * r5,
      q3: p3 * r0 + p4 * r3 + p5 * r6, q4: p3 * r1 + p4 * r4 + p5 * r7, q5: p4 * r5 + p5 * r8,
      q6: p6 * r0 + p7 * r3 + p8 * r6, q7: p6 * r1 + p7 * r4 + p8 * r7, q8: p7 * r5 + p8 * r8
    };
  }

  // The horizon plane plus its N/S/E/W direction labels.
  var DIR_LABELS = [{ t: 'N', x: 4.6, y: -87.8 }, { t: 'S', x: 4.85, y: 81.3 },
                    { t: 'E', x: 87.95, y: -2.75 }, { t: 'W', x: -78.0, y: -2.75 }];
  function drawHorizonPlane(ctx, sphere) {
    if (!sphere._showHorizonPlane) return;
    var r = sphere._c.r, sy = r * Math.sin(sphere._phi) / 100, above = sphere._phi > 0;
    ctx.save();
    ctx.scale(r / 100, sy);
    ctx.rotate(PI + sphere._theta);
    drawAsset(ctx, above ? ASSETS.hpAbove : ASSETS.hpBelow);
    if (above) {
      ctx.font = '10px SimVerdana, Verdana, Geneva, sans-serif';
      ctx.fillStyle = '#ffffff';
      ctx.textAlign = 'center'; ctx.textBaseline = 'middle';
      for (var i = 0; i < DIR_LABELS.length; i++) {
        ctx.fillText(DIR_LABELS[i].t, DIR_LABELS[i].x, DIR_LABELS[i].y);
      }
    }
    ctx.restore();
  }

  // The full layered draw, in the AS depth order.
  function renderSphere(ctx, sphere, canvas) {
    ctx.setTransform(1, 0, 0, 1, 0, 0);
    ctx.clearRect(0, 0, canvas.width, canvas.height);
    ctx.fillStyle = '#000000';
    ctx.fillRect(0, 0, canvas.width, canvas.height);
    ctx.translate(CX, CY);

    var r = sphere._c.r, k = r / 100,
        showUnder = sphere._showUnder,
        M0 = boxPath(sphere),
        M1 = rimPath(sphere, 1, true),   M2 = rimPath(sphere, 1, false),
        M3 = rimPath(sphere, -1, true),  M4 = rimPath(sphere, -1, false),
        buckets = bucketObjects(sphere);

    // ---- behind the sphere ----
    drawObjects(ctx, buckets.rGtBack);
    withClip(ctx, M0, function () { drawLines(ctx, sphere, 'bE'); });
    withClip(ctx, showUnder ? M4 : null, function () { /* _bOSB: no clip content */ });
    withClip(ctx, M3, function () { /* _bOSA */ });
    withClip(ctx, showUnder ? M0 : M3, function () {          // _bOSF: shading3
      ctx.save(); ctx.scale(k, k); drawAsset(ctx, ASSETS.shadingA); ctx.restore();
    });
    withClip(ctx, showUnder ? M0 : M3, function () { drawCircles(ctx, sphere, 'back'); });
    drawObjects(ctx, buckets.rEqBack);
    withClip(ctx, showUnder ? M0 : M3, function () {          // _bISF: bands + shading1
      drawBands(ctx, sphere, 'back');
      ctx.save(); ctx.scale(k, k); drawAsset(ctx, ASSETS.shadingB); ctx.restore();
    });

    // ---- inside the sphere, around the horizon plane ----
    drawObjects(ctx, buckets.rLtA);
    withClip(ctx, M0, function () { drawLines(ctx, sphere, sphere._phi < 0 ? 'aI' : 'bI'); });
    drawHorizonPlane(ctx, sphere);
    drawObjects(ctx, buckets.rLtB);
    withClip(ctx, M0, function () { drawLines(ctx, sphere, sphere._phi < 0 ? 'bI' : 'aI'); });

    // ---- in front of the sphere ----
    withClip(ctx, showUnder ? M0 : M1, function () {          // _fISF: bands
      drawBands(ctx, sphere, 'front');
    });
    withClip(ctx, showUnder ? M0 : M1, function () { drawCircles(ctx, sphere, 'front'); });
    drawObjects(ctx, buckets.rEqFront);
    withClip(ctx, showUnder ? M0 : M1, function () {          // _fOSF: shading2
      ctx.save(); ctx.scale(k, k); drawAsset(ctx, ASSETS.shadingA); ctx.restore();
    });
    drawObjects(ctx, buckets.rGtFront);
    withClip(ctx, M0, function () { drawLines(ctx, sphere, 'fE'); });
  }

  /* ---------------- world map (port of "Location Selector.as") ----------- */
  var MAP_W = 360, MAP_OFFSET = 170;
  function renderMap() {
    var ctx = ctxMap, w = MAP_W, R = w / TWO_PI, half = w / 2, quarter = w / 4, off = MAP_OFFSET;
    ctx.setTransform(1, 0, 0, 1, 0, 0);
    ctx.clearRect(0, 0, w, 2 * quarter);
    ctx.translate(0, quarter);

    ctx.fillStyle = css(15068410, 100);           // ocean #E5F5FA
    ctx.fillRect(0, -quarter, w, 2 * quarter);

    var path = new Path2D();
    for (var i = 0; i < SHORE.length; i++) {
      var poly = SHORE[i],
          x0 = off + R * Math.atan2(poly[0].y, poly[0].x),
          y0 = -R * Math.asin(poly[0].z), prev = x0, prevY = y0, j, p, x, y;
      // Antarctica (index 5) is closed off along the bottom edge of the map.
      if (i === 5) {
        [0, w, -w].forEach(function (dx) {
          path.moveTo(dx + x0, y0);
          var px = x0, py = y0;
          for (j = 1; j < poly.length; j++) {
            p = poly[j];
            x = off + R * Math.atan2(p.y, p.x); y = -R * Math.asin(p.z);
            if (x - px > half) {
              var a = off - R * PI, b = off + R * PI, mid = (y + py) / 2;
              path.lineTo(dx + a, mid); path.lineTo(dx + a, half);
              path.lineTo(dx + b, half); path.lineTo(dx + b, mid);
            }
            path.lineTo(dx + x, y);
            px = x; py = y;
          }
          path.lineTo(dx + x0, y0);
        });
      } else {
        [0, w, -w].forEach(function (dx) {
          path.moveTo(dx + x0, y0);
          var px = x0;
          for (j = 1; j < poly.length; j++) {
            p = poly[j];
            x = off + R * Math.atan2(p.y, p.x); y = -R * Math.asin(p.z);
            if (x - px > half) x -= w; else if (px - x > half) x += w;
            path.lineTo(dx + x, y);
            px = x;
          }
          path.lineTo(dx + x0, y0);
        });
      }
    }
    ctx.save();
    ctx.clip(path);
    ctx.fillStyle = css(13481116, 100);           // land #CDBBDC
    ctx.fillRect(0, -quarter, w, 2 * quarter);
    ctx.restore();

    // Cursor + cross hairs
    var scale = 360 / w,
        cx = mod((mod(state.observerLongitude, 360) + off) / scale, w),
        cy = -state.observerLatitude / scale;
    ctx.strokeStyle = css(8421504, 50);
    ctx.lineWidth = 1;
    ctx.beginPath();
    ctx.moveTo(cx, quarter); ctx.lineTo(cx, -quarter);
    ctx.moveTo(0, cy);       ctx.lineTo(w, cy);
    ctx.stroke();
    ctx.save();
    ctx.translate(cx, cy);
    drawAsset(ctx, ASSETS.cursor);
    ctx.restore();

    ctx.strokeStyle = '#000000';
    ctx.strokeRect(0, -quarter, w, 2 * quarter);
  }

  /* ---------------- the single render() ---------------------------------- */
  function render() {
    if (!assetsReady) return;
    globeSphere.setThetaAndPhi(sphere1.getTheta(), sphere1.getPhi());
    renderSphere(ctx1, sphere1, els['sphere1-canvas']);
    renderSphere(ctx2, sphere2, els['sphere2-canvas']);
    renderMap();
    updateDescriptions();
  }

  /* ======================================================================
     Screen-reader text -- every value is announced with its quantity and unit.
     ====================================================================== */
  function announceStatus(msg) { els['sr-status'].textContent = msg; }

  function announceSelectedStar(prefix) {
    var st = stars[state.selectedStar]; if (!st) return;
    var c = {}, h = {};
    st.o1.getPositionCelestial(c); st.o2.getPositionHorizon(h);
    announceStatus((prefix ? prefix + ' ' : '') +
      'Right ascension ' + spoken(c.ra, 1) + ' hours, declination ' + spoken(c.dec, 1) +
      ' degrees. Azimuth ' + spoken(h.az, 1) + ' degrees, altitude ' + spoken(h.alt, 1) + ' degrees.');
  }

  function updateDescriptions() {
    var lon = state.observerLongitude > 180 ? state.observerLongitude - 360 : state.observerLongitude,
        loc = 'Observer at latitude ' + spoken(state.observerLatitude, 1) + ' degrees, longitude ' +
              spoken(lon, 1) + ' degrees.',
        hours = mod(state.time * 24, 24),
        clock = 'Elapsed simulated time ' + spoken(state.time * 24, 1) + ' hours.',
        count = starsList.length + (starsList.length === 1 ? ' star' : ' stars') + ' on the sphere.';

    els['sphere1-desc'].textContent =
      'Celestial sphere seen from outside, with the Earth at its centre. ' + loc + ' ' + count + ' ' +
      'View rotated to azimuth ' + spoken(sphere1.getTheta(), 0) + ' degrees, altitude ' +
      spoken(sphere1.getPhi(), 0) + ' degrees. ' + clock;

    els['sphere2-desc'].textContent =
      'Horizon diagram for the observer, with the green horizon plane and a figure at its centre. ' +
      loc + ' ' + count + ' View rotated to azimuth ' + spoken(sphere2.getTheta(), 0) +
      ' degrees, altitude ' + spoken(sphere2.getPhi(), 0) + ' degrees. ' +
      (els['cb-angle'].checked ? 'Angle between the celestial equator and the horizon ' +
        angleText.replace('°', '') + ' degrees. ' : '') + clock;

    els['map-desc'].textContent = loc;

    els['rate-slider'].setAttribute('aria-valuetext',
      'Animation rate ' + asFixed(state.rate * 24, 1) + ' hours of simulated time per second');
  }

  /* ======================================================================
     Pointer + keyboard interaction
     ====================================================================== */

  // Map a pointer event to sphere-centred stage coordinates.
  function stageCoords(canvas, ev) {
    var b = canvas.getBoundingClientRect(),
        sx = canvas.width / b.width, sy = canvas.height / b.height;
    return { x: (ev.clientX - b.left) * sx - CX, y: (ev.clientY - b.top) * sy - CY };
  }

  // Hit-test the stars on the near side, in the same order the AS stacks them.
  function starAt(sphere, x, y) {
    var best = null;
    for (var i = 0; i < starsList.length; i++) {
      var st = stars[starsList[i]], o = (sphere === sphere1) ? st.o1 : st.o2;
      if (!o.visible) continue;
      o.update();
      if (o._sp.z <= 0) continue;                 // only near-side stars are clickable
      var d = Math.hypot(o._sp.x - x, o._sp.y - y),
          rad = st.isConstellation ? 6 : 11;
      if (d <= rad) best = st;                    // later stars win, matching depth order
    }
    return best;
  }

  function attachSphere(canvas, sphere, handle, other) {
    var drag = null, wasAnimating = false;

    canvas.addEventListener('pointerdown', function (ev) {
      var pt = stageCoords(canvas, ev);
      handle.focus();                             // click also focuses (arrow keys work next)

      if (ev.shiftKey) {                          // shift-click adds a star
        var cp = sphere.screenToRaDec(pt.x, pt.y);
        if (cp) { var id = addStar(cp); if (id) selectStar(id); render(); }
        return;
      }
      var hit = starAt(sphere, pt.x, pt.y);
      if (hit) {
        if (ev.getModifierState && ev.getModifierState('Delete')) { /* handled on keydown path */ }
        if (deleteKeyDown) {
          if (hit.isConstellation) { removeConstellation(hit.constellation); syncPatternChecks(); }
          else removeStar(hit.id);
          render();
          return;
        }
        wasAnimating = state.animating; pauseAnimation();
        var already = (state.selectedStar === hit.id);
        if (!already) selectStar(hit.id);
        drag = { mode: 'star', star: hit, moved: false, already: already };
        canvas.setPointerCapture(ev.pointerId);
        render();
        return;
      }
      // Otherwise: rotate the view
      wasAnimating = state.animating; pauseAnimation();
      drag = { mode: 'view', moved: false, x: pt.x, y: pt.y,
               theta: sphere._theta, phi: sphere._phi };
      canvas.setPointerCapture(ev.pointerId);
      ev.preventDefault();
    });

    canvas.addEventListener('pointermove', function (ev) {
      var pt = stageCoords(canvas, ev);
      if (!drag) {
        var hit = starAt(sphere, pt.x, pt.y), id = hit ? hit.id : null;
        if (id !== hoveredStar) { hoveredStar = id; render(); }
        return;
      }
      drag.moved = true;
      if (drag.mode === 'view') {
        sphere.setThetaAndPhi(R2D * (drag.theta - (pt.x - drag.x) / sphere._c.r),
                              R2D * (drag.phi + (pt.y - drag.y) / sphere._c.r));
        render();
      } else if (drag.mode === 'star' && !drag.star.isConstellation) {
        var cp = sphere.screenToRaDec(pt.x, pt.y);
        if (cp) { moveStar(drag.star.id, cp); render(); }
      }
    });

    function endDrag(ev) {
      if (!drag) return;
      if (drag.mode === 'star' && drag.already && !drag.moved) deselectSelectedStar();
      else if (drag.mode === 'view' && !drag.moved) deselectSelectedStar();
      else if (drag.mode === 'star') announceSelectedStar('Star moved.');
      else announceStatus('View rotated to azimuth ' + spoken(sphere.getTheta(), 0) +
             ' degrees, altitude ' + spoken(sphere.getPhi(), 0) + ' degrees.');
      drag = null;
      if (wasAnimating) resumeAnimation();
      render();
    }
    canvas.addEventListener('pointerup', endDrag);
    canvas.addEventListener('pointercancel', endDrag);
    canvas.addEventListener('pointerleave', function () {
      if (!drag && hoveredStar != null) { hoveredStar = null; render(); }
    });

    // Keyboard equivalent for the pointer drag: rotate the view with the arrows.
    handle.addEventListener('keydown', function (ev) {
      var step = ev.shiftKey ? 15 : 5, t = sphere.getTheta(), p = sphere.getPhi(), used = true;
      switch (ev.key) {
        case 'ArrowLeft':  t -= step; break;
        case 'ArrowRight': t += step; break;
        case 'ArrowUp':    p += step; break;
        case 'ArrowDown':  p -= step; break;
        case 'PageUp':     p += 15; break;
        case 'PageDown':   p -= 15; break;
        case 'Home':       t = 0; break;
        case 'End':        t = 180; break;
        default: used = false;
      }
      if (!used) return;
      ev.preventDefault();
      sphere.setThetaAndPhi(t, p);
      render();
      announceStatus('View rotated to azimuth ' + spoken(sphere.getTheta(), 0) +
        ' degrees, altitude ' + spoken(sphere.getPhi(), 0) + ' degrees.');
    });
  }

  var deleteKeyDown = false;
  window.addEventListener('keydown', function (e) { if (e.key === 'Delete') deleteKeyDown = true; });
  window.addEventListener('keyup',   function (e) { if (e.key === 'Delete') deleteKeyDown = false; });

  attachSphere(els['sphere1-canvas'], sphere1, els['sphere1-handle']);
  attachSphere(els['sphere2-canvas'], sphere2, els['sphere2-handle']);

  /* ---------------- world map interaction -------------------------------- */
  (function () {
    var canvas = els['map-canvas'], handle = els['map-handle'], dragging = false;
    function toLatLon(ev) {
      var b = canvas.getBoundingClientRect(),
          x = (ev.clientX - b.left) * (canvas.width / b.width),
          y = (ev.clientY - b.top) * (canvas.height / b.height) - canvas.height / 2,
          scale = 360 / MAP_W,
          lon = scale * x - MAP_OFFSET, lat = -scale * y;
      if (lat < -90) lat = -90; else if (lat > 90) lat = 90;
      return { lat: lat, lon: lon };
    }
    canvas.addEventListener('pointerdown', function (ev) {
      dragging = true; canvas.setPointerCapture(ev.pointerId);
      handle.focus();
      setLocation(toLatLon(ev)); render(); ev.preventDefault();
    });
    canvas.addEventListener('pointermove', function (ev) {
      if (!dragging) return; setLocation(toLatLon(ev)); render();
    });
    function stop() { if (dragging) { dragging = false; setLocation({ lat: state.observerLatitude, lon: state.observerLongitude }, true); } }
    canvas.addEventListener('pointerup', stop);
    canvas.addEventListener('pointercancel', stop);

    // Arrow keys move the observer by deltaPos = 5 degrees, as in the AS.
    handle.addEventListener('keydown', function (ev) {
      var d = ev.shiftKey ? 15 : 5, lat = state.observerLatitude, lon = state.observerLongitude, used = true;
      switch (ev.key) {
        case 'ArrowLeft':  lon -= d; break;
        case 'ArrowRight': lon += d; break;
        case 'ArrowUp':    lat += d; break;
        case 'ArrowDown':  lat -= d; break;
        case 'PageUp':     lat += 15; break;
        case 'PageDown':   lat -= 15; break;
        case 'Home':       lat = 90; break;
        case 'End':        lat = -90; break;
        default: used = false;
      }
      if (!used) return;
      ev.preventDefault();
      setLocation({ lat: lat, lon: lon }, true);
      render();
    });
  })();

  /* ---------------- numeric fields: arrows, wheel, commit ---------------- */
  function wireNumberField(el, commit) {
    el.addEventListener('change', commit);
    el.addEventListener('blur', commit);
    el.addEventListener('keydown', function (ev) {
      if (ev.key === 'Enter') { ev.preventDefault(); commit(); }
    });
    // Mouse wheel adjusts the focused field by its own step.
    el.addEventListener('wheel', function (ev) {
      if (document.activeElement !== el) return;
      ev.preventDefault();
      var step = parseFloat(el.step) || 1,
          v = (parseFloat(el.value) || 0) + (ev.deltaY < 0 ? step : -step);
      if (el.min !== '' && v < parseFloat(el.min)) v = parseFloat(el.min);
      if (el.max !== '' && v > parseFloat(el.max)) v = parseFloat(el.max);
      el.value = asFixed(v, 1);
      commit();
    }, { passive: false });
  }

  function commitLat() {
    var v = parseFloat(els['lat-field'].value);
    if (!isNaN(v) && isFinite(v) && v >= -90 && v <= 90) {
      if (els['lat-dir'].value === 'S' && v > 0) v = -v;
      setLocation({ lat: v, lon: state.observerLongitude }, true);
    } else {
      setLocation({ lat: state.observerLatitude, lon: state.observerLongitude });
    }
    render();
  }
  function commitLon() {
    var v = parseFloat(els['lon-field'].value);
    if (!isNaN(v) && isFinite(v)) {
      if (els['lon-dir'].value === 'W' && v > 0) v = 360 - v;
      setLocation({ lat: state.observerLatitude, lon: v }, true);
    } else {
      setLocation({ lat: state.observerLatitude, lon: state.observerLongitude });
    }
    render();
  }
  wireNumberField(els['lat-field'], commitLat);
  wireNumberField(els['lon-field'], commitLon);

  els['lat-dir'].addEventListener('change', function () {
    var lat = Math.abs(state.observerLatitude);
    setLocation({ lat: els['lat-dir'].value === 'N' ? lat : -lat, lon: state.observerLongitude }, true);
    render();
  });
  els['lon-dir'].addEventListener('change', function () {
    var lon = state.observerLongitude;
    if (els['lon-dir'].value === 'E') { if (lon > 180) lon = -lon; }
    else { if (lon <= 180) lon = -lon; }
    setLocation({ lat: state.observerLatitude, lon: lon }, true);
    render();
  });

  function commitRaDec() {
    if (state.selectedStar == null) return;
    var ra = parseFloat(els['ra-field'].value), dec = parseFloat(els['dec-field'].value), p;
    if (!isNaN(ra) && isFinite(ra) && !isNaN(dec) && isFinite(dec)) {
      if (dec > 90) dec = 90; else if (dec < -90) dec = -90;
      moveStar(state.selectedStar, { ra: ra, dec: dec });
    } else {
      p = {}; stars[state.selectedStar].o1.getPositionCelestial(p); moveStar(state.selectedStar, p);
    }
    announceSelectedStar('Star moved.');
    render();
  }
  function commitAzAlt() {
    if (state.selectedStar == null) return;
    var az = parseFloat(els['az-field'].value), alt = parseFloat(els['alt-field'].value), p = {};
    if (!isNaN(az) && isFinite(az) && !isNaN(alt) && isFinite(alt)) {
      if (alt > 90) alt = 90; else if (alt < -90) alt = -90;
      sphere2.pointToCelestial({ az: az, alt: alt }, p);
      moveStar(state.selectedStar, p);
    } else {
      stars[state.selectedStar].o1.getPositionCelestial(p); moveStar(state.selectedStar, p);
    }
    announceSelectedStar('Star moved.');
    render();
  }
  wireNumberField(els['ra-field'], commitRaDec);
  wireNumberField(els['dec-field'], commitRaDec);
  wireNumberField(els['az-field'], commitAzAlt);
  wireNumberField(els['alt-field'], commitAzAlt);

  /* ---------------- buttons, checkboxes, radios -------------------------- */
  els['btn-animate'].addEventListener('click', toggleAnimation);
  els['btn-addstar'].addEventListener('click', addStarRandomly);
  els['btn-removestars'].addEventListener('click', function () { removeAllStars(true); render(); });
  els['btn-resettrails'].addEventListener('click', resetTrails);

  els['btn-patterns'].addEventListener('click', function () {
    var open = els['patterns-menu'].hidden;
    els['patterns-menu'].hidden = !open;
    els['btn-patterns'].setAttribute('aria-expanded', String(open));
  });
  Object.keys(CONSTELLATIONS).forEach(function (n) {
    els['cb-' + n].addEventListener('change', function () {
      if (els['cb-' + n].checked) { addConstellation(n); announceStatus(CONSTELLATION_NAMES[n] + ' added.'); }
      else { removeConstellation(n); announceStatus(CONSTELLATION_NAMES[n] + ' removed.'); }
      render();
    });
  });
  function syncPatternChecks() {
    Object.keys(CONSTELLATIONS).forEach(function (n) { els['cb-' + n].checked = CONSTELLATIONS[n].inUse; });
  }

  els['cb-labels'].addEventListener('change', changeShowLabels);
  els['cb-zerohours'].addEventListener('change', changeShow0hCircle);
  els['cb-celequator'].addEventListener('change', changeShowCelestialEquator);
  els['cb-showunder'].addEventListener('change', changeShowUnder);
  els['cb-neverrise'].addEventListener('change', changeShowNeverRise);
  els['cb-riseset'].addEventListener('change', changeShowRiseSet);
  els['cb-neverset'].addEventListener('change', changeShowNeverSet);
  els['cb-angle'].addEventListener('change', changeShowAngle);
  Array.prototype.forEach.call(document.querySelectorAll('input[name="trailType"]'),
    function (rb) { rb.addEventListener('change', changeTrailType); });

  els['rate-slider'].addEventListener('input', function () {
    state.rate = sliderToRate(parseFloat(els['rate-slider'].value));
    updateDescriptions();
  });
  els['rate-slider'].addEventListener('change', function () {
    announceStatus('Animation rate ' + asFixed(state.rate * 24, 1) +
      ' hours of simulated time per second.');
  });

  /* ---------------- Reset (from the shared masthead) --------------------- */
  // onReset() -- restores exactly the initial state the AS restores.
  function onReset() {
    if (state.animating) toggleAnimation();
    removeAllStars(false);
    state.rate = 0.05;
    els['rate-slider'].value = rateToSlider(0.05);
    els['animate-duration'].value = '0';
    els['animate-duration'].disabled = false;
    document.getElementById('rb-trail-none').checked = true;
    els['cb-labels'].checked = false;
    els['cb-zerohours'].checked = true;
    els['cb-celequator'].checked = true;
    els['cb-showunder'].checked = true;
    els['cb-neverrise'].checked = false;
    els['cb-riseset'].checked = false;
    els['cb-neverset'].checked = false;
    els['cb-angle'].checked = false;
    els['patterns-menu'].hidden = true;
    els['btn-patterns'].setAttribute('aria-expanded', 'false');
    syncPatternChecks();

    changeTrailType();
    changeShowLabels(); changeShow0hCircle(); changeShowCelestialEquator();
    changeShowUnder(); changeShowNeverRise(); changeShowRiseSet();
    changeShowNeverSet(); changeShowAngle();

    state.time = 0;
    setLocation({ lat: 40.8, lon: -96.7 });
    sphere1.setThetaAndPhi(100, 20);
    sphere2.setThetaAndPhi(145, 30);
    globeSphere.setThetaAndPhi(sphere1.getTheta(), sphere1.getPhi());
    update();
    render();
    announceStatus('Simulation reset.');
  }
  document.addEventListener('sim-reset', onReset);

  /* ---------------- MathJax wiring --------------------------------------- */
  // The foundation calls klunlInitEqn() on load; redefine it to typeset the
  // static inline math in the page (units, the "0h circle" label).
  window.klunlInitEqn = function () {
    if (window.MathJax && MathJax.typesetPromise) {
      MathJax.typesetPromise().then(untabMath).catch(function (e) { console.error(e); });
    }
  };
  // Typeset math is display-only: keep it out of the Tab order (rule 8b).
  function untabMath() {
    Array.prototype.forEach.call(document.querySelectorAll('mjx-container'), function (m) {
      m.setAttribute('tabindex', '-1');
      Array.prototype.forEach.call(m.querySelectorAll('[tabindex="0"]'), function (n) {
        n.setAttribute('tabindex', '-1');
      });
    });
  }
  if (window.MathJax && MathJax.startup && MathJax.startup.promise) {
    MathJax.startup.promise.then(function () { window.klunlInitEqn(); });
  }

  /* ---------------- boot ------------------------------------------------- */
  loadAssets(function () {
    els['rate-slider'].value = rateToSlider(state.rate);
    onReset();
  });

})();
