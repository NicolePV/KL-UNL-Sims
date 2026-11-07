/* ==========================================================================
   Paths of the Sun Demonstrator  —  accessible HTML5 port
   --------------------------------------------------------------------------
   Behaviour is a faithful port of the decompiled ActionScript (AS1) celestial
   sphere engine (scripts/CelestialSphere.as + "CS *" prototype files) and the
   controller (scripts/frame_1/DoAction.as, scripts/DoInitAction.as).

   All physics constants and formulas are copied VERBATIM from the source:
     sun RA (hours)   = day * 24/365            (0.06575342465753424)
     sun declination  = 23.5 * sin(day * 2pi/365)   (0.01721420632103996)
     sidereal time    = 2pi * frac(366.25/365 * day)   (1.0027397260273974)
   The drawing reproduces the code-drawn vector art (great circles, sky bowl,
   horizon plane) on a <canvas>; exported bitmaps/shapes (stickman, shadow,
   sun, ground) are REUSED as-is from assets/ (copied from shapes/*.svg).
   ========================================================================== */

(function () {
  "use strict";

  /* ---- AS angle constants (kept verbatim) -------------------------------- */
  var DEG = 0.017453292519943295;   // pi/180   degrees -> radians
  var HRS = 0.2617993877991494;     // pi/12    hours   -> radians
  var RAD = 57.29577951308232;      // 180/pi   radians -> degrees
  var TWO_PI = 6.283185307179586;
  var HALF_PI = 1.5707963267948966;

  /* ---- Stage geometry (original internal coordinates) -------------------- */
  // Landscape framing (like the original Flash diagram): the dome + ground +
  // shadow fit snugly so the panel is not padded with empty black space.
  var STAGE_W = 360, STAGE_H = 268;
  var CENTER_X = 180, CENTER_Y = 150;   // sphere centre in stage coords
  var R = 120;                          // sphere radius (sphere.size = 240)

  /* ======================================================================
     The celestial-sphere engine (ported 1:1 from the AS prototype methods)
     ====================================================================== */
  var sphere = {
    r: R, r2: R * R,
    theta: 0, phi: 0, lat: 0, sTime: 0,
    day: 0,
    showUnder: false,
    c: {},               // projection matrices a*/b*/m*
    sun: { ra: 0, dec: 0, p: { x: 0, y: 0, z: 0, r: 1 }, alt: 0, az: 0, sp: {} }
  };

  function mod(n, m) { return (n % m + m) % m; }

  /* world(horizon)->screen, celestial->screen (with z component) */
  function WtoSz(p, sp) {
    var c = sphere.c;
    sp.x = p.x * c.a0 + p.y * c.a1;
    sp.y = p.x * c.a3 + p.y * c.a4 + p.z * c.a5;
    sp.z = p.x * c.a6 + p.y * c.a7 + p.z * c.a8;
  }
  function WtoS(p, sp) {
    var c = sphere.c;
    sp.x = p.x * c.a0 + p.y * c.a1;
    sp.y = p.x * c.a3 + p.y * c.a4 + p.z * c.a5;
  }
  function CtoSz(p, sp) {
    var c = sphere.c;
    sp.x = p.x * c.b0 + p.y * c.b1 + p.z * c.b2;
    sp.y = p.x * c.b3 + p.y * c.b4 + p.z * c.b5;
    sp.z = p.x * c.b6 + p.y * c.b7 + p.z * c.b8;
  }
  function CtoS(p, sp) {
    var c = sphere.c;
    sp.x = p.x * c.b0 + p.y * c.b1 + p.z * c.b2;
    sp.y = p.x * c.b3 + p.y * c.b4 + p.z * c.b5;
  }
  function CtoW(p, wp) {
    var c = sphere.c;
    wp.x = p.x * c.m0 + p.y * c.m1 + p.z * c.m2;
    wp.y = p.x * c.m3 + p.y * c.m4;
    wp.z = p.x * c.m6 + p.y * c.m7 + p.z * c.m8;
  }

  function parsePointInput(p1) {
    var p2 = {};
    if (p1.az !== undefined && p1.alt !== undefined) {
      p2.sys = 0;
      var r0 = (p1.r !== undefined) ? p1.r : 1;
      var d = r0 * Math.cos(p1.alt * DEG);
      p2.x = d * Math.cos(p1.az * DEG);
      p2.y = d * Math.sin(-p1.az * DEG);
      p2.z = r0 * Math.sin(p1.alt * DEG);
      p2.r = Math.abs(r0);
    } else if (p1.ra !== undefined && p1.dec !== undefined) {
      p2.sys = 1;
      var r1 = (p1.r !== undefined) ? p1.r : 1;
      var d2 = r1 * Math.cos(p1.dec * DEG);
      p2.x = d2 * Math.cos(p1.ra * HRS);
      p2.y = d2 * Math.sin(p1.ra * HRS);
      p2.z = r1 * Math.sin(p1.dec * DEG);
      p2.r = Math.abs(r1);
    } else if (p1.x !== undefined && p1.y !== undefined && p1.z !== undefined) {
      p2.sys = (p1.system === "horizon") ? 0 : (p1.system === "celestial" ? 1 : -1);
      p2.x = p1.x; p2.y = p1.y; p2.z = p1.z;
      p2.r = Math.sqrt(p2.x * p2.x + p2.y * p2.y + p2.z * p2.z);
    }
    return p2;
  }

  /* celestial (ra,dec in radians) -> horizon (az,alt in radians) */
  function CtoMH(cp) {
    var hp = {};
    var sd = Math.sin(cp.dec), cd = Math.cos(cp.dec);
    var sl = Math.sin(sphere.lat), cl = Math.cos(sphere.lat);
    var h = sphere.sTime - cp.ra;
    var ch = Math.cos(h);
    var caz = sd * cl - cd * ch * sl;
    var saz = cd * Math.sin(h);
    hp.az = (caz === 0) ? 0 : mod(Math.atan2(saz, caz), TWO_PI);
    hp.alt = Math.asin(sd * sl + cd * ch * cl);
    return hp;
  }

  /* screen -> horizon (az,alt in radians) — for pointer hit-test / rotation */
  function StoMH(sp) {
    var hp = {};
    var d = Math.sqrt(sp.x * sp.x + sp.y * sp.y) / sphere.r;
    if (d > 1) d = 1;
    var b = Math.asin(d);
    var A = Math.atan2(sp.x, -sp.y);
    if (sphere.phi === HALF_PI) {
      hp.alt = HALF_PI - b;
      hp.az = sphere.theta + Math.PI - A;
    } else if (sphere.phi === -HALF_PI) {
      hp.alt = -HALF_PI + b;
      hp.az = sphere.theta + A;
    } else {
      var c = HALF_PI - sphere.phi;
      var cc = Math.cos(c), sc = Math.sin(c);
      var cb = Math.cos(b), sb = Math.sin(b);
      var ca = cb * cc + sb * sc * Math.cos(A);
      hp.alt = HALF_PI - Math.acos(ca);
      hp.az = sphere.theta + Math.atan2(sb * Math.sin(A), (cb - ca * cc) / sc);
    }
    hp.az = mod(hp.az, TWO_PI);
    return hp;
  }

  function doA() {
    var c = sphere.c, r = sphere.r;
    var ct = Math.cos(sphere.theta), st = Math.sin(sphere.theta);
    var cp = Math.cos(sphere.phi), sp = Math.sin(sphere.phi);
    c.a0 = -r * st;        c.a1 = r * ct;
    c.a3 = r * ct * sp;    c.a4 = r * st * sp;   c.a5 = -r * cp;
    c.a6 = r * ct * cp;    c.a7 = r * st * cp;   c.a8 = r * sp;
  }
  function doM() {
    var c = sphere.c;
    c.m2 = Math.cos(sphere.lat);
    c.m3 = Math.sin(sphere.sTime);
    c.m4 = -Math.cos(sphere.sTime);
    c.m8 = Math.sin(sphere.lat);
    c.m0 = c.m4 * c.m8;
    c.m1 = -c.m3 * c.m8;
    c.m6 = -c.m2 * c.m4;
    c.m7 = c.m2 * c.m3;
  }
  function doB() {
    var c = sphere.c;
    c.b0 = c.a0 * c.m0 + c.a1 * c.m3;
    c.b1 = c.a0 * c.m1 + c.a1 * c.m4;
    c.b2 = c.a0 * c.m2;
    c.b3 = c.a3 * c.m0 + c.a4 * c.m3 + c.a5 * c.m6;
    c.b4 = c.a3 * c.m1 + c.a4 * c.m4 + c.a5 * c.m7;
    c.b5 = c.a3 * c.m2 + c.a5 * c.m8;
    c.b6 = c.a6 * c.m0 + c.a7 * c.m3 + c.a8 * c.m6;
    c.b7 = c.a6 * c.m1 + c.a7 * c.m4 + c.a8 * c.m7;
    c.b8 = c.a6 * c.m2 + c.a8 * c.m8;
  }

  /* ======================================================================
     Great-circle drawing (ported from "8 CS Circles.as")
     ====================================================================== */
  // class-level sample points for a unit circle (nP = 10 quadratic segments)
  var nP = 10;
  var cStep = TWO_PI / nP;
  var uaP = [], ucP = [];
  (function () {
    var halfStep = cStep / 2;
    var cRad = 1 / Math.cos(halfStep);
    for (var i = 0; i < nP; i++) {
      var aAngle = (i + 1) * cStep;
      uaP.push({ x: Math.cos(aAngle), y: Math.sin(aAngle) });
      var cAngle = aAngle - halfStep;
      ucP.push({ x: cRad * Math.cos(cAngle), y: cRad * Math.sin(cAngle) });
    }
  })();

  // A "pen" mirrors the Flash MovieClip drawing API but records segments
  function Pen() { this.segs = []; this.cur = null; }
  Pen.prototype.clear = function () { this.segs = []; this.cur = null; };
  Pen.prototype.moveTo = function (x, y) { this.cur = [["M", x, y]]; this.segs.push(this.cur); };
  Pen.prototype.curveTo = function (cx, cy, x, y) {
    if (!this.cur) { this.cur = [["M", 0, 0]]; this.segs.push(this.cur); }
    this.cur.push(["Q", cx, cy, x, y]);
  };

  function Circle(color, alpha, thick) {
    this.color = color; this.alpha = alpha; this.thick = thick;
    this.sys = 0; this.tilt = 0; this.beta = 0; this.lambda = 0;
    this.gS = 0; this.gE = 0;
    this.c = {};                 // w matrix
    this.aP = []; this.cP = []; this.sP = {};
    this.front = new Pen(); this.back = new Pen();
    this.visible = true;
  }
  Circle.prototype.setParams = function (arg) {
    if (arg.az !== undefined && arg.alt !== undefined && arg.tilt !== undefined) {
      this.sys = 0;
      this.tilt = clampTilt(arg.tilt);
      this.lambda = clampLambda(arg.alt);
      this.beta = DEG * mod(-arg.az, 360);
    } else if (arg.ra !== undefined && arg.dec !== undefined && arg.tilt !== undefined) {
      this.sys = 1;
      this.tilt = clampTilt(arg.tilt);
      this.lambda = clampLambda(arg.dec);
      this.beta = HRS * mod(arg.ra, 24);
    }
    this.doW(); this.prerender();
  };
  function clampTilt(t) { return t < 0 ? 0 : (t > 180 ? Math.PI : t * DEG); }
  function clampLambda(l) { return l < -90 ? -Math.PI : (l > 90 ? Math.PI : l * DEG); }

  Circle.prototype.doW = function () {
    var st = Math.sin(this.tilt), ct = Math.cos(this.tilt);
    var sb = Math.sin(this.beta), cb = Math.cos(this.beta);
    var cl = Math.cos(this.lambda), sl = Math.sin(this.lambda);
    var c = this.c;
    c.w0 = cl * cb;        c.w1 = -cl * sb * ct;   c.w2 = sl * sb * st;
    c.w3 = cl * sb;        c.w4 = cl * cb * ct;    c.w5 = -sl * cb * st;
    c.w7 = cl * st;        c.w8 = sl * ct;
  };
  Circle.prototype.CPtoSYS = function (cp, o) {
    var c = this.c;
    o.x = cp.x * c.w0 + cp.y * c.w1 + c.w2;
    o.y = cp.x * c.w3 + cp.y * c.w4 + c.w5;
    o.z = cp.y * c.w7 + c.w8;
  };
  Circle.prototype.CGtoSYS = function (g, o) {
    var x = Math.cos(g), y = Math.sin(g), c = this.c;
    o.x = x * c.w0 + y * c.w1 + c.w2;
    o.y = x * c.w3 + y * c.w4 + c.w5;
    o.z = y * c.w7 + c.w8;
  };
  Circle.prototype.prerender = function () {
    this.aP = []; this.cP = [];
    for (var i = 0; i < nP; i++) {
      var a = {}, cc = {};
      this.CPtoSYS(uaP[i], a);
      this.CPtoSYS(ucP[i], cc);
      this.aP.push(a); this.cP.push(cc);
    }
    this.sP = { x: this.aP[nP - 1].x, y: this.aP[nP - 1].y, z: this.aP[nP - 1].z };
  };

  Circle.prototype.arc = function (g1, g2, pen) {
    var proj = (this.sys === 0) ? WtoS : CtoS;
    var saP = {}, scP = {};
    if (g2 < g1) g2 += TWO_PI;
    var arc = g2 - g1;
    var i, aP, cP, icP = {}, naP = {}, ncP = {}, half, cRad;
    if (arc === 0) {                              // full circle
      proj(this.sP, saP);
      pen.moveTo(saP.x, saP.y);
      for (i = 0; i < nP; i++) {
        proj(this.aP[i], saP);
        proj(this.cP[i], scP);
        pen.curveTo(scP.x, scP.y, saP.x, saP.y);
      }
    } else if (arc <= cStep) {
      aP = {}; cP = {};
      this.CGtoSYS(g1, aP);
      proj(aP, saP); pen.moveTo(saP.x, saP.y);
      half = arc / 2; cRad = 1 / Math.cos(half);
      icP.x = cRad * Math.cos(g1 + half); icP.y = cRad * Math.sin(g1 + half);
      this.CPtoSYS(icP, cP);
      this.CGtoSYS(g2, aP);
      proj(aP, saP); proj(cP, scP);
      pen.curveTo(scP.x, scP.y, saP.x, saP.y);
    } else {
      aP = this.aP; cP = this.cP;
      var a1 = mod(Math.ceil(g1 / cStep) - 1, nP);
      var a2 = mod(Math.floor(g2 / cStep) - 1, nP);
      var angle = (a1 + 1) * cStep - g1;
      if (angle === 0) {
        proj(aP[a1], saP); pen.moveTo(saP.x, saP.y);
      } else {
        this.CGtoSYS(g1, naP);
        proj(naP, saP); pen.moveTo(saP.x, saP.y);
        half = angle / 2; cRad = 1 / Math.cos(half);
        icP.x = cRad * Math.cos(g1 + half); icP.y = cRad * Math.sin(g1 + half);
        this.CPtoSYS(icP, ncP);
        proj(ncP, scP); proj(aP[a1], saP);
        pen.curveTo(scP.x, scP.y, saP.x, saP.y);
      }
      var lim = a2; if (lim < a1) lim += nP;
      for (i = a1 + 1; i <= lim; i++) {
        proj(aP[i % nP], saP); proj(cP[i % nP], scP);
        pen.curveTo(scP.x, scP.y, saP.x, saP.y);
      }
      angle = (g2 % TWO_PI) - (a2 + 1) * cStep;
      if (angle !== 0) {
        half = angle / 2; cRad = 1 / Math.cos(half);
        icP.x = cRad * Math.cos(g2 - half); icP.y = cRad * Math.sin(g2 - half);
        this.CPtoSYS(icP, ncP);
        proj(ncP, scP);
        this.CGtoSYS(g2, naP); proj(naP, saP);
        pen.curveTo(scP.x, scP.y, saP.x, saP.y);
      }
    }
  };

  // Decide which parts of the circle are on the near (front) vs far (back)
  // side of the sphere and emit them to the two pens (ported from update()).
  Circle.prototype.update = function () {
    this.front.clear(); this.back.clear();
    if (!this.visible) return;
    var tc = this.c, pc = sphere.c, k1, k2, k3;
    if (this.sys === 0) {
      k1 = tc.w0 * pc.a6 + tc.w3 * pc.a7;
      k2 = tc.w1 * pc.a6 + tc.w4 * pc.a7 + tc.w7 * pc.a8;
      k3 = tc.w2 * pc.a6 + tc.w5 * pc.a7 + tc.w8 * pc.a8;
    } else {
      k1 = tc.w0 * pc.b6 + tc.w3 * pc.b7;
      k2 = tc.w1 * pc.b6 + tc.w4 * pc.b7 + tc.w7 * pc.b8;
      k3 = tc.w2 * pc.b6 + tc.w5 * pc.b7 + tc.w8 * pc.b8;
    }
    var A = Math.sqrt(k1 * k1 + k2 * k2);
    if (A === 0) {
      this.arc(this.gS, this.gE, k3 < 0 ? this.back : this.front);
    } else {
      var sj = -k3 / A;
      if (sj <= -1) {
        this.arc(this.gS, this.gE, this.front);
      } else if (sj >= 1) {
        this.arc(this.gS, this.gE, this.back);
      } else {
        var j = Math.asin(sj), t = Math.atan2(k1, k2), gDesc, gAsc;
        if (Math.cos(j) < 0) {
          gDesc = mod(j - t, TWO_PI); gAsc = mod(Math.PI - j - t, TWO_PI);
        } else {
          gDesc = mod(Math.PI - j - t, TWO_PI); gAsc = mod(j - t, TWO_PI);
        }
        // every circle here is a full circle (gS == gE == 0)
        this.arc(gAsc, gDesc, this.front);
        this.arc(gDesc, gAsc, this.back);
      }
    }
  };

  /* ======================================================================
     The circles used by this sim (colours/tilts VERBATIM from DoAction.as)
     ====================================================================== */
  var celestialEquator = new Circle("#505050", 1, 1);    // 5263440  "black"
  var sunsPath         = new Circle("#FFFFC0", 1, 1.6);  // 16777152 yellow
  var meridian         = new Circle("#C0C0C0", 1, 1);    // 12632256 gray
  var ecliptic         = new Circle("#FF5050", 1, 1);    // 16732240 red
  var allCircles = [celestialEquator, sunsPath, meridian, ecliptic];

  /* ======================================================================
     Sun + date  (ported from "10 CS Experimental.as" / "2 CS Getter Setter")
     ====================================================================== */
  function updateSun() {
    var raNow = sphere.day * 0.06575342465753424;          // = day*24/365 hours
    var decNow = 23.5 * Math.sin(sphere.day * 0.01721420632103996); // 2pi/365
    sphere.sun.ra = raNow; sphere.sun.dec = decNow;
    sphere.sun.p = parsePointInput({ ra: raNow, dec: decNow });
  }
  function setDay(arg) {
    sphere.day = arg % 365;
    updateSun();
    sphere.sTime = TWO_PI * (1.0027397260273974 * sphere.day % 1);
  }

  var MONTHS = [[31, "January"], [59, "February"], [90, "March"], [120, "April"],
    [151, "May"], [181, "June"], [212, "July"], [243, "August"],
    [273, "September"], [304, "October"], [334, "November"], [365, "December"]];
  function getDateString() {
    var today = mod(sphere.day + 79.5, 365);
    var i = 0;
    while (i < 12) { if (today < MONTHS[i][0]) break; i++; }
    if (i !== 0) today = today - MONTHS[i - 1][0] + 1; else today += 1;
    return MONTHS[i][1] + " " + Math.floor(today);
  }

  // sun horizon coordinates (degrees), matching CSObjects getAlt/getAz
  function sunAltAz() {
    var hp = CtoMH({ ra: sphere.sun.ra * HRS, dec: sphere.sun.dec * DEG });
    var alt = hp.alt * RAD;
    var az = mod(-hp.az * RAD, 360);
    return { alt: alt, az: az };
  }

  /* ======================================================================
     Sky colour (ported from DoInitAction.as). The shadow is computed in
     drawShadow() from the sun's altitude/azimuth.
     ====================================================================== */
  var SKY = "#84CBFF";  // 8702975 inner == outer colour
  var sky = { backInner: 100, backOuter: 80, frontInner: 10, frontOuter: 40 };

  // alpha ranges (day/night), verbatim
  var dayBackInner = 100, nightBackInner = 30, dayBackOuter = 80, nightBackOuter = 20;
  var dayFrontInner = 10, nightFrontInner = 0, dayFrontOuter = 40, nightFrontOuter = 15;

  function setSkyColor() {
    var aa = sphere.sun._altaz;
    var intensity = aa.alt / 10 + 0.5;
    if (intensity > 1) intensity = 1; else if (intensity < 0) intensity = 0;
    sky.backInner = intensity * (dayBackInner - nightBackInner) + nightBackInner;
    sky.backOuter = intensity * (dayBackOuter - nightBackOuter) + nightBackOuter;
    sky.frontInner = intensity * (dayFrontInner - nightFrontInner) + nightFrontInner;
    sky.frontOuter = intensity * (dayFrontOuter - nightFrontOuter) + nightFrontOuter;
  }

  /* ======================================================================
     Rendering on the <canvas>
     ====================================================================== */
  var canvas = document.getElementById("sky-canvas");
  var ctx = canvas.getContext("2d");
  var dpr = Math.max(1, Math.min(3, window.devicePixelRatio || 1));

  function sizeCanvas() {
    canvas.width = STAGE_W * dpr;
    canvas.height = STAGE_H * dpr;
  }
  sizeCanvas();

  // reusable images (exported assets reused as-is)
  function loadImg(src) { var im = new Image(); im.src = src; return im; }
  var imgStickman = loadImg("assets/stickman.svg");
  var imgShadow = loadImg("assets/shadow.svg");
  var imgSun = loadImg("assets/sun.svg");
  var imgGround = loadImg("assets/ground-above.svg");
  var imgGroundBelow = loadImg("assets/ground-below.svg");
  var imagesReady = 0, imagesNeeded = 5;
  [imgStickman, imgShadow, imgSun, imgGround, imgGroundBelow].forEach(function (im) {
    im.addEventListener("load", function () { imagesReady++; render(); });
  });

  // Build the above-horizon clip path. side: "front" uses the near rim
  // (lower ellipse half, +y), "back" uses the far rim (upper half, -y).
  // This reproduces the Flash masks M1 (front) and M3 (back).
  function horizonClip(side) {
    var s = Math.sin(sphere.phi);
    var sgn = (side === "front") ? 1 : -1;
    ctx.beginPath();
    // top outer circle arc, from (-r,0) over the top to (r,0)
    ctx.moveTo(-sphere.r, 0);
    ctx.arc(0, 0, sphere.r, Math.PI, TWO_PI, false);  // upper half (y<0)
    // rim ellipse arc back from (r,0) to (-r,0)
    var steps = 32;
    for (var i = 1; i <= steps; i++) {
      var ang = Math.PI * i / steps;            // 0..pi along the bottom
      ctx.lineTo(sphere.r * Math.cos(ang), sgn * sphere.r * s * Math.sin(ang));
    }
    ctx.closePath();
  }

  function strokePen(pen, color, alpha, thick) {
    ctx.strokeStyle = color;
    ctx.globalAlpha = alpha;
    ctx.lineWidth = thick;
    ctx.lineJoin = "round";
    ctx.lineCap = "round";
    for (var s = 0; s < pen.segs.length; s++) {
      var seg = pen.segs[s];
      ctx.beginPath();
      for (var k = 0; k < seg.length; k++) {
        var cmd = seg[k];
        if (cmd[0] === "M") ctx.moveTo(cmd[1], cmd[2]);
        else if (cmd[0] === "Q") ctx.quadraticCurveTo(cmd[1], cmd[2], cmd[3], cmd[4]);
      }
      ctx.stroke();
    }
    ctx.globalAlpha = 1;
  }

  function fillSky(side, innerA, outerA) {
    // radial gradient centred on the sphere, inner -> outer over radius r
    var g = ctx.createRadialGradient(0, 0, 0, 0, 0, sphere.r);
    g.addColorStop(0, rgbaFromHex(SKY, innerA / 100));
    g.addColorStop(1, rgbaFromHex(SKY, outerA / 100));
    ctx.save();
    horizonClip(side);
    ctx.clip();
    ctx.fillStyle = g;
    ctx.fillRect(-sphere.r, -sphere.r, 2 * sphere.r, 2 * sphere.r);
    ctx.restore();
  }

  function rgbaFromHex(hex, a) {
    var n = parseInt(hex.slice(1), 16);
    return "rgba(" + ((n >> 16) & 255) + "," + ((n >> 8) & 255) + "," + (n & 255) + "," + a + ")";
  }

  function drawGround() {
    // horizon plane = circle scaled to (r, r*sin(phi)); reuse the exported SVG
    var s = Math.sin(sphere.phi);
    var img = (sphere.phi > 0) ? imgGround : imgGroundBelow;
    if (!img.complete || !img.naturalWidth) {
      // fallback flat ellipse if the SVG has not loaded yet
      ctx.save(); ctx.fillStyle = "#3aa53a";
      ctx.beginPath(); ctx.ellipse(0, 0, sphere.r, sphere.r * Math.abs(s), 0, 0, TWO_PI);
      ctx.fill(); ctx.restore();
      return;
    }
    ctx.save();
    ctx.scale(sphere.r / 100, (sphere.r * s) / 100);  // SVG is radius 100
    ctx.drawImage(img, -100, -100, 200, 200);
    ctx.restore();
  }

  // Cardinal direction labels on the horizon plane (the original attaches
  // "direction labels dark/light" to _hP). Positions are the alt=0 points at
  // azimuth 0/90/180/270, projected to screen, so they rotate with the view.
  // Kept upright (not squished with the tilted plane) for legibility, with a
  // contrasting outline so they read on both the green ground and the sky.
  var CARDINALS = [{ az: 0, t: "N" }, { az: 90, t: "E" }, { az: 180, t: "S" }, { az: 270, t: "W" }];
  function drawDirectionLabels() {
    var rr = 0.92;                       // just inside the horizon rim
    ctx.save();
    ctx.font = "bold 13px Arial, Helvetica, sans-serif";
    ctx.textAlign = "center";
    ctx.textBaseline = "middle";
    ctx.lineJoin = "round";
    for (var i = 0; i < CARDINALS.length; i++) {
      var c = sphere.c, a = CARDINALS[i].az * DEG;
      var wx = rr * Math.cos(a), wy = -rr * Math.sin(a);     // alt=0, z=0
      var sx = wx * c.a0 + wy * c.a1;
      var sy = wx * c.a3 + wy * c.a4;
      var sz = wx * c.a6 + wy * c.a7;                        // <0 = far (back) rim
      // far labels light (near the dim dome base), near labels dark (bright grass)
      if (sz < 0) { ctx.strokeStyle = "rgba(0,0,0,0.85)"; ctx.fillStyle = "#ffffff"; }
      else { ctx.strokeStyle = "rgba(255,255,255,0.9)"; ctx.fillStyle = "#10250f"; }
      ctx.lineWidth = 3;
      ctx.strokeText(CARDINALS[i].t, sx, sy);
      ctx.fillText(CARDINALS[i].t, sx, sy);
    }
    ctx.restore();
  }

  function drawSun() {
    var aa = sphere.sun._altaz;
    if (aa.alt <= 0) return;                 // below horizon: hidden (showUnder false)
    var sp = {}; CtoSz(sphere.sun.p, sp);
    var size = 16;                           // sun.svg is 16x16 (radius ~7.5)
    if (imgSun.complete && imgSun.naturalWidth) {
      ctx.drawImage(imgSun, sp.x - size / 2, sp.y - size / 2, size, size);
    } else {
      ctx.save(); ctx.fillStyle = "#ffcc00";
      ctx.beginPath(); ctx.arc(sp.x, sp.y, 7.5, 0, TWO_PI); ctx.fill(); ctx.restore();
    }
  }

  // Stickman + shadow follow the working sibling sim (Sun Motion Demo): the
  // observer stands UPRIGHT at the horizon-plane centre (feet at the origin),
  // foreshortened vertically by cos(viewer altitude) so it stays planted on the
  // tilting ground; the shadow is the same silhouette laid FLAT on the ground,
  // pinned at the same feet and pointing away from the sun.
  function drawStickman() {
    if (!imgStickman.complete || !imgStickman.naturalWidth) return;
    var scaleY = Math.max(Math.cos(sphere.phi), 0.12);   // squash as the disk tilts
    var BASE = 34;
    var w = BASE * imgStickman.naturalWidth / imgStickman.naturalHeight;
    var h = BASE * scaleY;
    ctx.drawImage(imgStickman, -w / 2, -h, w, h);        // feet at the origin
  }

  function drawShadow() {
    var aa = sphere.sun._altaz;
    var alt = aa.alt;
    if (alt < 1) return;                                 // sun at/below horizon: none
    if (!imgShadow.complete || !imgShadow.naturalWidth) return;
    var t = Math.tan(alt * DEG);
    var a = 1 - 1 / (15 * t);                            // alpha (fades near noon)
    if (a <= 0.03) return;
    if (a > 0.6) a = 0.6;
    var L = 0.5 / t;                                     // length grows as the sun lowers
    if (L > 0.95) L = 0.95; else if (L < 0.07) L = 0.07;
    var as = aa.az + 180;                                // shadow points away from the sun
    // Map the silhouette flat onto the ground: feet (W/2,H) -> origin, head
    // (W/2,0) -> the anti-sun ground point (length L), width along the
    // perpendicular ground direction. This keeps the shadow attached to the feet
    // and oriented correctly as the view rotates and the sun moves.
    var img = imgShadow, W = img.naturalWidth, H = img.naturalHeight;
    var tip = {}; WtoSz(parsePointInput({ az: as, alt: 0, r: L }), tip);
    var across = {}; WtoSz(parsePointInput({ az: as + 90, alt: 0, r: 1 }), across);
    var am = Math.hypot(across.x, across.y) || 1;
    var figW = 13;                                       // shadow width in stage px
    var wx = across.x / am * figW, wy = across.y / am * figW;
    var lx = tip.x, ly = tip.y;
    var A = wx / W, B = wy / W, C = -lx / H, D = -ly / H;
    var E = -(A * (W / 2) + C * H), F = -(B * (W / 2) + D * H);
    ctx.save();
    ctx.globalAlpha = a;
    ctx.transform(A, B, C, D, E, F);
    ctx.drawImage(img, 0, 0, W, H);
    ctx.restore();
    ctx.globalAlpha = 1;
  }

  function render() {
    // backing-store transform: device pixels -> stage coords, origin at centre
    ctx.setTransform(dpr, 0, 0, dpr, 0, 0);
    ctx.clearRect(0, 0, STAGE_W, STAGE_H);
    ctx.fillStyle = "#000";
    ctx.fillRect(0, 0, STAGE_W, STAGE_H);
    ctx.translate(CENTER_X, CENTER_Y);

    // 1. back sky bowl (far inner surface)
    fillSky("back", sky.backInner, sky.backOuter);

    // 2. back circle arcs (clipped to far rim)
    ctx.save(); horizonClip("back"); ctx.clip();
    for (var i = 0; i < allCircles.length; i++) {
      strokePen(allCircles[i].back, allCircles[i].color, allCircles[i].alpha, allCircles[i].thick);
    }
    ctx.restore();

    // 3. ground / horizon plane + cardinal direction labels (N/E/S/W)
    drawGround();
    drawDirectionLabels();

    // 4. front sky bowl (near inner surface, faint)
    fillSky("front", sky.frontInner, sky.frontOuter);

    // 5. front circle arcs (clipped to near rim)
    ctx.save(); horizonClip("front"); ctx.clip();
    for (var j = 0; j < allCircles.length; j++) {
      strokePen(allCircles[j].front, allCircles[j].color, allCircles[j].alpha, allCircles[j].thick);
    }
    ctx.restore();

    // 6. objects on top (depth-ordered in the original): shadow, then the
    //    figure standing over it, then the sun.
    drawShadow();
    drawStickman();
    drawSun();
  }

  /* ======================================================================
     State recompute + DOM sync (single source of truth)
     ====================================================================== */
  var elLatValue = document.getElementById("latitude-value");
  var elLatInput = document.getElementById("latitude");
  var elDate = document.getElementById("date-string");
  var elDateSr = document.getElementById("date-sr");
  var elStatus = document.getElementById("sr-status");
  var elCanvasDesc = document.getElementById("canvas-desc");
  var elAnimate = document.getElementById("animate");

  function latText() {
    var v = Math.round(Math.abs(sphere.lat * RAD) * 10) / 10;
    var hemi = (sphere.lat < 0) ? "S" : "N";
    return v.toFixed(1) + "° " + hemi;
  }
  function latSpoken() {
    var v = Math.round(Math.abs(sphere.lat * RAD) * 10) / 10;
    var hemi = (sphere.lat < 0) ? "south" : "north";
    return v.toFixed(1) + " degrees " + hemi;
  }

  function recompute() {
    doA(); doM(); doB();
    sphere.sun._altaz = sunAltAz();
    setSkyColor();
    for (var i = 0; i < allCircles.length; i++) allCircles[i].update();
    render();
  }

  function syncReadouts() {
    // don't clobber the field while the user is typing in it
    if (document.activeElement !== elLatValue) elLatValue.value = latText();
    elLatInput.setAttribute("aria-valuetext", latSpoken());
    var ds = getDateString();
    elDate.textContent = ds;
    elDateSr.textContent = "Date: " + ds;
  }

  // Parse a typed latitude: accepts "41", "41.5", "-23.5", "23.5 S", "19.5° N".
  // Negative or a trailing S means south; N (or no suffix) means north.
  function parseLatitude(str) {
    if (str == null) return null;
    var s = ("" + str).trim().toUpperCase();
    var m = s.match(/-?\d+(\.\d+)?/);
    if (!m) return null;
    var v = parseFloat(m[0]);
    if (!isFinite(v)) return null;
    if (/S/.test(s)) v = -Math.abs(v);
    else if (/N/.test(s)) v = Math.abs(v);
    return v;
  }

  function commitLatInput() {
    var v = parseLatitude(elLatValue.value);
    if (v === null) { elLatValue.value = latText(); return; }   // revert bad input
    if (v > 90) v = 90; else if (v < -90) v = -90;
    setLatitude(v);
    elLatInput.value = String(Math.round(v * 10) / 10);          // sync the slider
    recompute();
    elLatValue.value = latText();                                // canonical format
    elLatInput.setAttribute("aria-valuetext", latSpoken());
    updateCanvasDesc();
    announce("Latitude " + latSpoken() + ".");
  }

  function diagramDescription() {
    var aa = sphere.sun._altaz;
    var dirOf = function (az) {
      var dirs = ["north", "northeast", "east", "southeast", "south", "southwest", "west", "northwest", "north"];
      return dirs[Math.round(mod(az, 360) / 45)];
    };
    var sunDesc = (aa.alt > 0)
      ? ("The sun is up at altitude " + aa.alt.toFixed(0) + " degrees, toward the " + dirOf(aa.az) + ".")
      : "The sun is below the horizon.";
    return "Horizon diagram for latitude " + latSpoken() + " on " + getDateString() +
      ". Sun's declination " + sphere.sun.dec.toFixed(1) + " degrees. " + sunDesc;
  }

  function announce(msg) { elStatus.textContent = msg; }
  function updateCanvasDesc() { elCanvasDesc.textContent = diagramDescription(); }

  /* ======================================================================
     Controls
     ====================================================================== */
  // Latitude slider (native range => full keyboard support)
  function onLatInput() {
    setLatitude(parseFloat(elLatInput.value));
    recompute();
    syncReadouts();
  }
  function setLatitude(deg) {
    if (deg > 90) deg = 90; else if (deg < -90) deg = -90;
    sphere.lat = deg * DEG;
  }
  elLatInput.addEventListener("input", onLatInput);
  elLatInput.addEventListener("change", function () {
    updateCanvasDesc();
    announce("Latitude " + latSpoken() + ".");
  });

  // Editable latitude field: type a value, commit on Enter or blur.
  elLatValue.addEventListener("change", commitLatInput);
  elLatValue.addEventListener("keydown", function (ev) {
    if (ev.key === "Enter") { ev.preventDefault(); commitLatInput(); }
  });
  elLatValue.addEventListener("focus", function () {
    try { elLatValue.select(); } catch (e) {}
  });

  // Animate checkbox
  var reduceMotion = window.matchMedia &&
    window.matchMedia("(prefers-reduced-motion: reduce)").matches;
  var animating = false, rafId = null, lastT = null, dayAcc = 0;
  var DAYS_PER_SEC = 24;   // ~ original 24 fps, one day per frame

  function tick(t) {
    if (!animating) return;
    if (lastT === null) lastT = t;
    var dt = (t - lastT) / 1000; lastT = t;
    dayAcc += dt * DAYS_PER_SEC;
    var whole = Math.floor(dayAcc);
    if (whole >= 1) {
      dayAcc -= whole;
      setDay(sphere.day + whole);
      // sun's path circle tracks the sun's current declination (DoAction.as)
      sunsPath.setParams({ ra: 0, dec: sphere.sun.dec, tilt: 0 });
      recompute();
      syncReadouts();
    }
    rafId = window.requestAnimationFrame(tick);
  }
  function startAnimate() {
    if (animating) return;
    animating = true; lastT = null; dayAcc = 0;
    rafId = window.requestAnimationFrame(tick);
    announce("Animation started.");
  }
  function stopAnimate() {
    animating = false;
    if (rafId) window.cancelAnimationFrame(rafId);
    rafId = null;
    updateCanvasDesc();
    announce("Animation stopped on " + getDateString() + ".");
  }
  elAnimate.addEventListener("change", function () {
    if (elAnimate.checked) {
      if (reduceMotion) {
        // Honour reduced motion: step a single day instead of continuous run.
        setDay(sphere.day + 1);
        sunsPath.setParams({ ra: 0, dec: sphere.sun.dec, tilt: 0 });
        recompute(); syncReadouts(); updateCanvasDesc();
        announce("Reduced motion is on. Stepped one day to " + getDateString() + ".");
        elAnimate.checked = false;
      } else {
        startAnimate();
      }
    } else {
      stopAnimate();
    }
  });

  /* ---- Pointer drag + keyboard rotation of the view (mouse behaviour:
          "simple drag" in 4 CS Mouse.as) ----------------------------------- */
  var MIN_PHI = 7, MAX_PHI = 90;      // sphere.minViewerAltitude = 7
  function setThetaPhi(thetaDeg, phiDeg) {
    if (phiDeg > MAX_PHI) phiDeg = MAX_PHI; else if (phiDeg < MIN_PHI) phiDeg = MIN_PHI;
    sphere.theta = DEG * mod(thetaDeg, 360);
    sphere.phi = phiDeg * DEG;
  }
  function stageCoords(ev) {
    var rect = canvas.getBoundingClientRect();
    var x = (ev.clientX - rect.left) * (STAGE_W / rect.width) - CENTER_X;
    var y = (ev.clientY - rect.top) * (STAGE_H / rect.height) - CENTER_Y;
    return { x: x, y: y };
  }
  // Two interaction targets share the canvas (matching the Sun Motion Demo):
  //   - clicking/dragging the SUN moves it through the year (changes the day);
  //   - clicking/dragging elsewhere on the SPHERE rotates the view.
  // canvasFocus records which one the arrow keys drive after a click (and is
  // toggled by Enter/Space for keyboard-only users).
  var dragMode = null;          // null | 'view' | 'sun'  (active pointer drag)
  var canvasFocus = "view";     // 'view' | 'sun'         (what arrow keys drive)
  var dragX = 0, dragY = 0, dragTheta = 0, dragPhi = 0;

  function sunVisible() { return sphere.sun._altaz && sphere.sun._altaz.alt > 0; }
  function hitSun(p) {
    if (!sunVisible()) return false;
    var sp = {}; CtoSz(sphere.sun.p, sp);
    var dx = p.x - sp.x, dy = p.y - sp.y;
    return (dx * dx + dy * dy) <= 225 && sp.z > 0;   // within ~15px and in front
  }

  // Apply a day change: keep the sun's-path circle on the sun's declination,
  // recompute, and refresh the date readout (no announcement — done on commit).
  function applyDayChange() {
    sunsPath.setParams({ ra: 0, dec: sphere.sun.dec, tilt: 0 });
    recompute();
    syncReadouts();
    updateCanvasDesc();
  }
  function announceSun() {
    announce("Sun on " + getDateString() + ". Declination " +
      sphere.sun.dec.toFixed(1) + " degrees.");
  }
  // Drag the sun: pick the day whose (meridian) sun is closest to the cursor,
  // with a small bias toward the current day so scrubbing stays continuous.
  function sunDragToCursor(px, py) {
    var raHours = sphere.sTime * 3.819718634205488;   // RA giving hour-angle 0
    var cur = sphere.day, best = cur, bestScore = Infinity;
    for (var d = 0; d < 365; d++) {
      var dec = 23.5 * Math.sin(d * 0.01721420632103996);
      var sp = {}; CtoSz(parsePointInput({ ra: raHours, dec: dec }), sp);
      if (sp.z <= 0) continue;                         // behind the sphere
      var dx = sp.x - px, dy = sp.y - py;
      var dd = Math.abs(d - cur); if (dd > 182.5) dd = 365 - dd;
      var score = dx * dx + dy * dy + dd * 0.05;
      if (score < bestScore) { bestScore = score; best = d; }
    }
    setDay(best);
    applyDayChange();
  }
  function moveDay(delta) {
    setDay(((sphere.day + delta) % 365 + 365) % 365);
    applyDayChange();
    announceSun();
  }

  canvas.addEventListener("pointerdown", function (ev) {
    canvas.focus();                                    // clicking focuses for arrow keys
    try { canvas.setPointerCapture(ev.pointerId); } catch (e) {}
    var p = stageCoords(ev);
    if (hitSun(p)) {
      dragMode = "sun"; canvasFocus = "sun";
      if (animating) { elAnimate.checked = false; stopAnimate(); }
    } else {
      dragMode = "view"; canvasFocus = "view";
      dragX = p.x; dragY = p.y; dragTheta = sphere.theta; dragPhi = sphere.phi;
    }
    ev.preventDefault();
  });
  canvas.addEventListener("pointermove", function (ev) {
    var p = stageCoords(ev);
    if (dragMode === "view") {
      setThetaPhi(RAD * (dragTheta - (p.x - dragX) / sphere.r),
                  RAD * (dragPhi + (p.y - dragY) / sphere.r));
      recompute();
    } else if (dragMode === "sun") {
      sunDragToCursor(p.x, p.y);
    } else {
      canvas.style.cursor = hitSun(p) ? "move" : "grab";   // hint: sun vs rotate
    }
  });
  function endDrag(ev) {
    var wasSun = dragMode === "sun";
    if (dragMode) updateCanvasDesc();
    dragMode = null;
    try { canvas.releasePointerCapture(ev.pointerId); } catch (e) {}
    if (wasSun) announceSun();
  }
  canvas.addEventListener("pointerup", endDrag);
  canvas.addEventListener("pointercancel", endDrag);

  canvas.addEventListener("keydown", function (ev) {
    // SUN mode: arrow keys move the sun through the year
    if (canvasFocus === "sun") {
      if (animating) return;
      var used = true;
      switch (ev.key) {
        case "ArrowLeft": case "ArrowDown": moveDay(-1); break;
        case "ArrowRight": case "ArrowUp": moveDay(1); break;
        case "PageDown": moveDay(-7); break;
        case "PageUp": moveDay(7); break;
        case "Home": setDay(0); applyDayChange(); announceSun(); break;
        case "End": setDay(364); applyDayChange(); announceSun(); break;
        case "Enter": case " ":
          canvasFocus = "view";
          announce("View rotation mode. Arrow keys rotate the diagram.");
          break;
        default: used = false;
      }
      if (used) ev.preventDefault();
      return;
    }
    // VIEW mode: arrow keys rotate; Enter/Space switches to moving the sun
    var step = 5, handled = true;
    var thetaDeg = sphere.theta * RAD, phiDeg = sphere.phi * RAD;
    switch (ev.key) {
      case "ArrowLeft": thetaDeg -= step; break;
      case "ArrowRight": thetaDeg += step; break;
      case "ArrowUp": phiDeg += step; break;
      case "ArrowDown": phiDeg -= step; break;
      case "Enter": case " ":
        if (sunVisible()) {
          canvasFocus = "sun";
          announce("Sun control mode. Arrow keys move the sun by day. " +
            "Press Enter to return to rotating the view.");
        } else {
          announce("The sun is below the horizon and cannot be moved right now.");
        }
        ev.preventDefault();
        return;
      default: handled = false;
    }
    if (handled) {
      ev.preventDefault();
      setThetaPhi(thetaDeg, phiDeg);
      recompute(); updateCanvasDesc();
      announce("View rotated. Azimuth " + Math.round(mod(360 - sphere.theta * RAD, 360)) +
        " degrees, altitude " + Math.round(sphere.phi * RAD) + " degrees.");
    }
  });

  /* ======================================================================
     Reset (from the KL-UNL masthead "sim-reset" event) + init
     ====================================================================== */
  function resetState() {
    setThetaPhi(160, 30);        // viewerAzimuth 200 -> theta 160; phi 30
    setLatitude(41);             // initValue
    setDay(0);                   // March 21, sun on the celestial equator
    sphere.sun._altaz = sunAltAz();
    sunsPath.setParams({ ra: 0, dec: sphere.sun.dec, tilt: 0 });
    celestialEquator.setParams({ ra: 0, dec: 0, tilt: 0 });
    meridian.setParams({ az: 0, alt: 0, tilt: 90 });
    ecliptic.setParams({ ra: 0, dec: 0, tilt: 23.5 });
    elLatInput.value = "41";
    if (elAnimate.checked) { elAnimate.checked = false; }
    stopAnimateSilent();
    recompute();
    syncReadouts();
    updateCanvasDesc();
  }
  function stopAnimateSilent() {
    animating = false;
    if (rafId) window.cancelAnimationFrame(rafId);
    rafId = null;
  }

  document.addEventListener("sim-reset", function () {
    resetState();
    announce("Simulation reset to latitude 41.0 degrees north on March 21.");
  });

  // Redefine the foundation equation-init hook (no equations in this sim).
  window.klunlInitEqn = function () { /* this demonstrator has no equations */ };

  // Initial build
  resetState();
  window.addEventListener("resize", render);

})();
