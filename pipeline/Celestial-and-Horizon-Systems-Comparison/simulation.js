/* ==========================================================================
   Celestial and Horizon Systems Comparison
   HTML5 port of celestialHorizon004.swf (Adobe Flash, ActionScript 1).

   Behaviour, constants, geometry and number formatting are ported verbatim
   from the decompiled ActionScript. Presentation follows the KL-UNL
   foundation and WCAG 2.1 AA; see CONVERSION_NOTES.md and ACCESSIBILITY.md.

   Source modules ported here:
     CelestialSphere.as      sphere construction, layer stack, update()
     2 CS Getter Setter.as   theta / phi / size / latitude / sidereal time
     3 CS Geometry.as        projection matrices A, M, B and coordinate maps
     4 CS Mouse.as           "simple drag" view rotation
     5 CS Horizon Plane.as   horizon-plane clips
     6 CS Shading.as         mask shapes M0..M5 and the shading layers
     7 CS Objects.as         positioned objects, orientation, depth sorting
     8 CS Circles.as         great/small circles split into front and back
     9 CS Lines.as           line segments split across sphere regions
     GlobeComponent.as       the Earth globe and its shoreline mask
     CSGradientDisk.as       code-drawn radial gradient disk
     Tangent Plane.as        the growing/shrinking horizon plane
     Transition Arrow.as     the celestial-sphere <-> horizon-diagram arrow
     sliderV5Component.as    latitude slider value handling and formatting
     DefineSprite_97 frame 1 the main controller
   ========================================================================== */

(function () {
'use strict';

/* ------------------------------------------------------------------ *
 *  Constants -- verbatim from the ActionScript source                  *
 * ------------------------------------------------------------------ */

var TRANSITION_TIME = 3000;   // transitionTime = 3000  (ms)
var MAX_GLOBE_SIZE  = 80;     // maxGlobeSize   = 80
var SPHERE_SIZE     = 300;    // CelestialSphereClass: _c.r = 150
var GLOBE_SPHERE_SIZE = 80;   // globeSphere.instance.size = 80
var INIT_THETA      = 90;     // setThetaAndPhi(90, 30)
var INIT_PHI        = 30;
var INIT_LATITUDE   = 41;     // slider initValue = 41
var LAT_MIN         = -90;    // initMinValue = -90
var LAT_MAX         =  90;    // initMaxValue =  90
var LAT_INCREMENT   = 0.1;    // initPrecision = 1, "fixed decimal places"
var LAT_PRECISION   = 1;

/* Circle / line colours are AS decimal RGB ints, alphas are 0-100. */
var COLOR_HORIZON_CIRCLES = 16777215;  // 0xFFFFFF  white, alpha 30
var COLOR_CELESTIAL       = 16769909;  // 0xFFE375  pale yellow, alpha 70
var COLOR_AXIS            = 7711231;   // 0x75A9FF  pale blue, alpha 100
var COLOR_GLOBE_CIRCLES   = 7368816;   // 0x707070  grey, alpha 100

/* Transition Arrow.as: minColor 14737632 (#e0e0e0), maxColor 0 (#000000).
   The pale end fails WCAG 1.4.3 on white, so the endpoints are remapped to
   the values below; the interpolation itself is unchanged. */
var ARROW_MIN_COLOR = 0x767676;
var ARROW_MAX_COLOR = 0x1a1a1a;
var ARROW_MIN_FACTOR = 0.001;
var ARROW_MAX_FACTOR = 1;
var ARROW_HALF_RANGE = (ARROW_MAX_FACTOR - ARROW_MIN_FACTOR) / 2;
var ARROW_HALF_POINT = ARROW_MIN_FACTOR + ARROW_HALF_RANGE;

/* Stage geometry: the original black backdrop is 380 x 380 with the sphere
   centred in it. The canvas keeps these coordinates at every display size. */
var STAGE = 380;
var ORIGIN = STAGE / 2;

var D2R = Math.PI / 180;                 // 0.017453292519943295
var R2D = 180 / Math.PI;                 // 57.29577951308232
var H2R = Math.PI / 12;                  // 0.2617993877991494
var R2H = 3.819718634205488;
var TWO_PI = 6.283185307179586;
var HALF_PI = 1.5707963267948966;

function mod(n, m) { return ((n % m) + m) % m; }

/* AS colour int + 0-100 alpha -> CSS colour. */
function cssColor(color, alpha) {
  return 'rgba(' + ((color >> 16) & 255) + ',' + ((color >> 8) & 255) + ',' +
         (color & 255) + ',' + (alpha / 100) + ')';
}

/* ------------------------------------------------------------------ *
 *  Exported artwork (reused as-is from the JPEXS export, never redrawn) *
 * ------------------------------------------------------------------ */

/* Each entry records the symbol origin inside its SVG box, so the art is
   drawn at the same registration point Flash used. */
var ART = {
  sphereShading:    { src: 'assets/sphere-shading.svg',      w: 200,   h: 200,  ox: 100,  oy: 100  },
  horizonAbove:     { src: 'assets/horizon-plane-above.svg', w: 199.95, h: 200, ox: 99.95, oy: 100 },
  horizonBelow:     { src: 'assets/horizon-plane-below.svg', w: 199.95, h: 200, ox: 99.95, oy: 100 },
  globeWater:       { src: 'assets/globe-water.svg',         w: 80,    h: 80,   ox: 40,   oy: 40   },
  globeLand:        { src: 'assets/globe-land.svg',          w: 80,    h: 80,   ox: 40,   oy: 40   },
  observerDot:      { src: 'assets/observer-dot.svg',        w: 8.5,   h: 8.5,  ox: 4.25, oy: 4.25 },
  stickfigure:      { src: 'assets/stickfigure.svg',         w: 14.6,  h: 36.3, ox: 7.3,  oy: 35.3 }
};

function loadArt() {
  var pending = [];
  Object.keys(ART).forEach(function (key) {
    var a = ART[key];
    a.img = new Image();
    pending.push(new Promise(function (resolve) {
      a.img.onload = function () { a.ready = true; resolve(); };
      a.img.onerror = function () { a.ready = false; resolve(); };
      a.img.src = a.src;
    }));
  });
  return Promise.all(pending);
}

function drawArt(ctx, a) {
  if (a.ready) { ctx.drawImage(a.img, -a.ox, -a.oy, a.w, a.h); }
}

/* ------------------------------------------------------------------ *
 *  Instance -- stands in for a Flash MovieClip's own transform          *
 * ------------------------------------------------------------------ */

function Instance() {
  this._xscale = 100;
  this._yscale = 100;
  this._rotation = 0;      // degrees, as in Flash
  this._alpha = 100;       // 0-100, as in Flash
}

Instance.prototype.drawArt = function () {};

Instance.prototype.draw = function (ctx) {
  ctx.save();
  if (this._rotation) { ctx.rotate(this._rotation * D2R); }
  ctx.scale(this._xscale / 100, this._yscale / 100);
  if (this._alpha < 100) {
    ctx.globalAlpha *= Math.max(0, this._alpha) / 100;
  }
  this.drawArt(ctx);
  ctx.restore();
};

/* ------------------------------------------------------------------ *
 *  CSCircle  --  port of "8 CS Circles.as"                             *
 * ------------------------------------------------------------------ */

function CSCircle(sphere, style, definition) {
  this._parent = sphere;
  this._c = {};
  this._gS = 0;
  this._gE = 0;
  this._beta = 0;
  this._tilt = 0;
  this._lambda = 0;
  this._sys = 0;
  this._visible = true;
  this._color = 16711680;
  this._thick = 1;
  this._alpha = 80;
  this.frontPath = new Path2D();
  this.backPath = new Path2D();
  if (style) { this.setStyle(style.thickness, style.color, style.alpha); }
  if (definition) { this.setParameters(definition); }
}

CSCircle.prototype._minStep = 0.7853981633974483;   // p._minStep

CSCircle.prototype.setStyle = function (thickness, circleColor, alpha) {
  if (thickness !== undefined) { this._thick = thickness; }
  if (circleColor !== undefined) { this._color = circleColor; }
  if (alpha !== undefined) { this._alpha = alpha; }
};

CSCircle.prototype.setParameters = function (arg) {
  if (arg.az !== undefined && arg.alt !== undefined && arg.tilt !== undefined) {
    this._sys = 0;
    if (isFinite(arg.tilt)) {
      if (arg.tilt < 0) { this._tilt = 0; }
      else if (arg.tilt > 180) { this._tilt = Math.PI; }
      else { this._tilt = arg.tilt * D2R; }
    }
    if (isFinite(arg.alt)) {
      if (arg.alt < -90) { this._lambda = -Math.PI; }
      else if (arg.alt > 90) { this._lambda = Math.PI; }
      else { this._lambda = arg.alt * D2R; }
    }
    if (isFinite(arg.az)) { this._beta = D2R * mod(-arg.az, 360); }
    if (isFinite(arg.gammaStart)) { this._gS = D2R * mod(arg.gammaStart, 360); }
    if (isFinite(arg.gammaEnd)) { this._gE = D2R * mod(arg.gammaEnd, 360); }
  } else if (arg.ra !== undefined && arg.dec !== undefined && arg.tilt !== undefined) {
    this._sys = 1;
    if (isFinite(arg.tilt)) {
      if (arg.tilt < 0) { this._tilt = 0; }
      else if (arg.tilt > 180) { this._tilt = Math.PI; }
      else { this._tilt = arg.tilt * D2R; }
    }
    if (isFinite(arg.dec)) {
      if (arg.dec < -90) { this._lambda = -Math.PI; }
      else if (arg.dec > 90) { this._lambda = Math.PI; }
      else { this._lambda = arg.dec * D2R; }
    }
    if (isFinite(arg.ra)) { this._beta = H2R * mod(arg.ra, 24); }
    if (isFinite(arg.gammaStart)) { this._gS = D2R * mod(arg.gammaStart, 360); }
    if (isFinite(arg.gammaEnd)) { this._gE = D2R * mod(arg.gammaEnd, 360); }
  }
  this.doW();
};

CSCircle.prototype.doW = function () {
  var st = Math.sin(this._tilt), ct = Math.cos(this._tilt);
  var sb = Math.sin(this._beta), cb = Math.cos(this._beta);
  var cl = Math.cos(this._lambda), sl = Math.sin(this._lambda);
  var c = this._c;
  c.w0 = cl * cb;
  c.w1 = -cl * sb * ct;
  c.w2 = sl * sb * st;
  c.w3 = cl * sb;
  c.w4 = cl * cb * ct;
  c.w5 = -sl * cb * st;
  c.w7 = cl * st;
  c.w8 = sl * ct;
};

CSCircle.prototype.update = function () {
  var front = new Path2D();
  var back = new Path2D();
  this.frontPath = front;
  this.backPath = back;
  if (!this._visible) { return; }

  var tc = this._c, pc = this._parent._c;
  var v0, v1, v2, v3, v4, v5, v6, v7, v8;

  if (this._sys === 0) {
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

  var minStep = this._minStep;

  /* Tessellated arc, identical to the drawArc closure in the AS source. */
  function drawArc(g1, g2, path) {
    if (g2 < g1) { g2 += TWO_PI; }
    var arc = g2 - g1;
    if (arc === 0) { arc = TWO_PI; }
    var n = Math.ceil(arc / minStep);
    var step = arc / n;
    var halfStep = step / 2;
    var cRad = 1 / Math.cos(halfStep);
    var ax = Math.cos(g1), ay = Math.sin(g1);
    path.moveTo(v0 * ax + v1 * ay + v2, v3 * ax + v4 * ay + v5);
    var aAngle = g1 + step;
    var cAngle = aAngle - halfStep;
    for (var i = 0; i < n; i++) {
      ax = Math.cos(aAngle); ay = Math.sin(aAngle);
      var cx = cRad * Math.cos(cAngle), cy = cRad * Math.sin(cAngle);
      path.quadraticCurveTo(v0 * cx + v1 * cy + v2, v3 * cx + v4 * cy + v5,
                            v0 * ax + v1 * ay + v2, v3 * ax + v4 * ay + v5);
      aAngle += step; cAngle += step;
    }
  }

  var A = Math.sqrt(v6 * v6 + v7 * v7);
  if (A === 0) {
    if (v8 < 0) { drawArc(this._gS, this._gE, back); }
    else { drawArc(this._gS, this._gE, front); }
    return;
  }

  var sj = -v8 / A;
  if (sj <= -1) { drawArc(this._gS, this._gE, front); return; }
  if (sj >= 1) { drawArc(this._gS, this._gE, back); return; }

  var j = Math.asin(sj);
  var t = Math.atan2(v6, v7);
  var gDesc, gAsc;
  if (Math.cos(j) < 0) {
    gDesc = mod(j - t, TWO_PI);
    gAsc = mod(Math.PI - j - t, TWO_PI);
  } else {
    gDesc = mod(Math.PI - j - t, TWO_PI);
    gAsc = mod(j - t, TWO_PI);
  }

  if (this._gS === this._gE) {
    drawArc(gAsc, gDesc, front);
    drawArc(gDesc, gAsc, back);
    return;
  }

  /* Partial arc: walk the four ordered breakpoints (ascending node,
     descending node, gammaStart, gammaEnd) and emit each run into the
     front or back path. */
  var gArray = [[gAsc, 0], [gDesc, 1], [this._gS, 2], [this._gE, 3]];
  gArray.sort(function (a, b) { return a[0] < b[0] ? -1 : (a[0] > b[0] ? 1 : 0); });

  var draw = false, frontSide = true, s;
  for (s = 0; s < 4; s++) {
    if (gArray[s][1] === 0) { frontSide = true; }
    else if (gArray[s][1] === 1) { frontSide = false; }
    else if (gArray[s][1] === 2) { draw = true; }
    else { draw = false; }
  }

  var g2 = gArray[3], g1;
  for (var i = 0; i < 4; i++) {
    g1 = g2;
    g2 = gArray[i];
    if (draw && g1[0] !== g2[0]) {
      drawArc(g1[0], g2[0], frontSide ? front : back);
    }
    if (g2[1] === 0) { frontSide = true; }
    else if (g2[1] === 1) { frontSide = false; }
    else if (g2[1] === 2) { draw = true; }
    else { draw = false; }
  }
};

/* ------------------------------------------------------------------ *
 *  CSLine  --  port of "9 CS Lines.as"                                 *
 * ------------------------------------------------------------------ */

function CSLine(sphere, style, head, tail) {
  this._parent = sphere;
  this._thick = 1; this._color = 255; this._alpha = 100;
  if (style) { this.setStyle(style.thickness, style.color, style.alpha); }
  this._visible = true;
  this._head = {};
  this._tail = {};
  this.setPoints(head, tail);
  /* Segment buckets: back-external, front-external, inner-above, inner-below. */
  this.segs = { bE: [], fE: [], aI: [], bI: [] };
}

CSLine.prototype.setStyle = function (thickness, lineColor, alpha) {
  if (thickness !== undefined) { this._thick = thickness; }
  if (lineColor !== undefined) { this._color = lineColor; }
  if (alpha !== undefined) { this._alpha = alpha; }
};

CSLine.prototype.setPoints = function (head, tail) {
  this._parent.parsePointInput(head, this._head);
  if (this._head.sys === -1) { this._head.sys = 0; }
  this._parent.parsePointInput(tail, this._tail);
  if (this._tail.sys === -1) { this._tail.sys = 0; }
};

CSLine.prototype.update = function () {
  var segs = this.segs;
  segs.bE = []; segs.fE = []; segs.aI = []; segs.bI = [];
  if (!this._visible) { return; }

  var head = {}, tail = {};
  if (this._head.sys === 0) { this._parent.WtoSz(this._head, head); }
  else if (this._head.sys === 1) { this._parent.CtoSz(this._head, head); }
  else { return; }
  if (this._tail.sys === 0) { this._parent.WtoSz(this._tail, tail); }
  else if (this._tail.sys === 1) { this._parent.CtoSz(this._tail, tail); }
  else { return; }

  var mx = head.x - tail.x, my = head.y - tail.y, mz = head.z - tail.z;
  var A = mx * mx + my * my + mz * mz;
  var B = 2 * (mx * tail.x + my * tail.y + mz * tail.z);
  var C = tail.x * tail.x + tail.y * tail.y + tail.z * tail.z;
  var rad = this._parent._c.r;
  var rad2 = rad * rad;
  var phi = this._parent._phi;

  /* Parameter values where the line crosses the sphere or the horizon plane. */
  var stmp = [];
  var D = B * B - 4 * A * (C - rad2);
  if (D > 0) {
    var sD = Math.sqrt(D);
    stmp.push((-B + sD) / (2 * A));
    stmp.push((-B - sD) / (2 * A));
  }
  var tp;
  if (phi > -HALF_PI && phi < HALF_PI) {
    tp = Math.tan(phi);
    if (my !== tp * mz) { stmp.push((tp * tail.z - tail.y) / (my - tp * mz)); }
    if (mz !== 0) {
      var tmp = -tail.z / mz;
      if (tmp * (tmp * A + B) + C >= rad2) { stmp.push(tmp); }
    }
  } else if (mz !== 0) {
    stmp.push(-tail.z / mz);
  }

  var s = [0, 1];
  for (var i = 0; i < stmp.length; i++) {
    if (stmp[i] > 0 && stmp[i] < 1) {
      var k = 1;
      while (stmp[i] > s[k]) { k++; }
      if (stmp[i] !== s[k]) { s.splice(k, 0, stmp[i]); }
    }
  }

  /* _showUnder is true throughout this simulation. */
  for (i = 0; i < s.length - 1; i++) {
    var s1 = s[i], s2 = s[i + 1];
    var bucket;
    var u = s1 + (s2 - s1) / 2;
    var r2 = u * (u * A + B) + C;
    if (r2 < rad2) {
      if (phi === -HALF_PI) { bucket = (u * mz + tail.z > 0) ? segs.bI : segs.aI; }
      else if (phi === HALF_PI) { bucket = (u * mz + tail.z > 0) ? segs.aI : segs.bI; }
      else if (u * my + tail.y - (u * mz + tail.z) * tp > 1e-9) { bucket = segs.bI; }
      else { bucket = segs.aI; }
    } else if (u * mz + tail.z < 0) { bucket = segs.bE; }
    else { bucket = segs.fE; }

    bucket.push([s1 * mx + tail.x, s1 * my + tail.y,
                 s2 * mx + tail.x, s2 * my + tail.y]);
  }
};

/* ------------------------------------------------------------------ *
 *  CSObject  --  port of "7 CS Objects.as"                             *
 * ------------------------------------------------------------------ */

function CSObject(sphere, instance, position) {
  this._parent = sphere;
  this.instance = instance;
  instance._sphere = sphere;
  instance._object = this;
  this._p = {};
  this._sp = { x: 0, y: 0, z: 0 };
  this._o = { x: 0, y: 0, z: 0 };
  this._n = { x: 0, y: 0, z: 0 };
  this._u = { x: 0, y: 0, z: 0 };
  this._oType = 0;
  this._visible = true;
  this._shellRotation = 0;
  this._shellYScale = 100;
  this.setPosition(position);
}

CSObject.prototype.setPosition = function (arg) {
  var pt = {};
  this._parent.parsePointInput(arg, pt);
  if (pt.sys === 0 || pt.sys === -1) { this._sys = 0; this._p = pt; this._r = pt.r; }
  else if (pt.sys === 1) { this._sys = 1; this._p = pt; this._r = pt.r; }
  this._p_o = { x: this._p.x + this._o.x, y: this._p.y + this._o.y, z: this._p.z + this._o.z };
  this._p_n = { x: this._p.x + this._n.x, y: this._p.y + this._n.y, z: this._p.z + this._n.z };
  this._p_u = { x: this._p.x + this._u.x, y: this._p.y + this._u.y, z: this._p.z + this._u.z };
};

CSObject.prototype.setOrientationType = function (type, arg2, arg3) {
  var m, v, tv;
  if (type === 'flat') {
    this._oType = 0;
  } else if (type === 'skewed') {
    this._oType = 1;
    if (typeof arg2 !== 'object') {
      m = Math.sqrt(this._p.x * this._p.x + this._p.y * this._p.y + this._p.z * this._p.z);
      this._o = { x: this._p.x / m, y: this._p.y / m, z: this._p.z / m };
    } else {
      v = {};
      this._parent.parsePointInput(arg2, v);
      if (v.sys === 0 && this._sys === 1) { tv = {}; this._parent.WtoC(v, tv); v = tv; }
      else if (v.sys === 1 && this._sys === 0) { tv = {}; this._parent.CtoW(v, tv); v = tv; }
      else if (v.sys === null) { return; }
      m = Math.sqrt(v.x * v.x + v.y * v.y + v.z * v.z);
      this._o = { x: v.x / m, y: v.y / m, z: v.z / m };
    }
    this._p_o = { x: this._p.x + this._o.x, y: this._p.y + this._o.y, z: this._p.z + this._o.z };
  } else if (type === 'absolute') {
    this._oType = 2;
    if (typeof arg2 !== 'object' || typeof arg3 !== 'object') {
      var nm = Math.sqrt(this._p.x * this._p.x + this._p.y * this._p.y + this._p.z * this._p.z);
      this._n = { x: this._p.x / nm, y: this._p.y / nm, z: this._p.z / nm };
      if (!(this._n.x === 0 && this._n.y === 0)) {
        this._u = { x: -this._n.x * this._n.z,
                    y: -this._n.z * this._n.y,
                    z: this._n.x * this._n.x + this._n.y * this._n.y };
        var nu = Math.sqrt(this._u.x * this._u.x + this._u.y * this._u.y + this._u.z * this._u.z);
        this._u = { x: this._u.x / nu, y: this._u.y / nu, z: this._u.z / nu };
      } else {
        this._u = { x: 0, y: 1, z: 0 };
      }
    } else {
      var v1 = {};
      this._parent.parsePointInput(arg2, v1);
      if (v1.sys === 0 && this._sys === 1) { tv = {}; this._parent.WtoC(v1, tv); v1 = tv; }
      else if (v1.sys === 1 && this._sys === 0) { tv = {}; this._parent.CtoW(v1, tv); v1 = tv; }
      else if (v1.sys === null) { return; }
      var v2 = {};
      this._parent.parsePointInput(arg3, v2);
      if (v2.sys === 0 && this._sys === 1) { tv = {}; this._parent.WtoC(v2, tv); v2 = tv; }
      else if (v2.sys === 1 && this._sys === 0) { tv = {}; this._parent.CtoW(v2, tv); v2 = tv; }
      else if (v2.sys === null) { return; }
      var nm2 = Math.sqrt(v1.x * v1.x + v1.y * v1.y + v1.z * v1.z);
      this._n = { x: v1.x / nm2, y: v1.y / nm2, z: v1.z / nm2 };
      var nx = this._n.x, ny = this._n.y, nz = this._n.z;
      var ax = v2.x, ay = v2.y, az = v2.z;
      var ux = ny * ny * ax - nx * ny * ay - nx * nz * az + nz * nz * ax;
      var uy = nz * nz * ay - ny * nz * az - nx * ny * ax + nx * nx * ay;
      var uz = nx * nx * az - nx * nz * ax - ny * nz * ay + ny * ny * az;
      var un = Math.sqrt(ux * ux + uy * uy + uz * uz);
      this._u = { x: ux / un, y: uy / un, z: uz / un };
    }
    this._p_u = { x: this._p.x + this._u.x, y: this._p.y + this._u.y, z: this._p.z + this._u.z };
    this._p_n = { x: this._p.x + this._n.x, y: this._p.y + this._n.y, z: this._p.z + this._n.z };
  }
};

CSObject.prototype.update = function () {
  var sp = this._sp;
  var c = this._parent._c;
  var sp_o, sp_u, sp_n, opz, npz;

  switch (this._oType) {
  case 0:
    this._shellRotation = 0;
    this._shellYScale = 100;
    return;
  case 1:
    sp_o = {};
    if (this._sys === 0) {
      opz = this._o.x * c.a6 + this._o.y * c.a7 + this._o.z * c.a8;
      this._parent.WtoSz(this._p_o, sp_o);
    } else {
      opz = this._o.x * c.b6 + this._o.y * c.b7 + this._o.z * c.b8;
      this._parent.CtoSz(this._p_o, sp_o);
    }
    this._shellYScale = 100 * Math.sqrt(1 - opz * opz / c.r2);
    this._shellRotation = R2D * Math.atan2(sp_o.y - sp.y, sp_o.x - sp.x) + 90;
    return;
  case 2:
    sp_u = {}; sp_n = {};
    if (this._sys === 0) {
      npz = (this._n.x * c.a6 + this._n.y * c.a7 + this._n.z * c.a8) / c.r;
      this._parent.WtoSz(this._p_n, sp_n);
      this._parent.WtoSz(this._p_u, sp_u);
    } else {
      npz = (this._n.x * c.b6 + this._n.y * c.b7 + this._n.z * c.b8) / c.r;
      this._parent.CtoSz(this._p_n, sp_n);
      this._parent.CtoSz(this._p_u, sp_u);
    }
    this._shellYScale = 100 * npz;
    var Aa = Math.atan2(sp_n.y - sp.y, sp_n.x - sp.x) + HALF_PI;
    this._shellRotation = R2D * Aa;
    var cA = Math.cos(Aa), sA = Math.sin(Aa);
    var x0 = sp_u.x - sp.x, y0 = sp_u.y - sp.y;
    var x1 = cA * x0 + sA * y0;
    var y1 = -sA * x0 + cA * y0;
    this.instance._rotation = R2D * Math.atan2(y1 / npz, x1) + 90;
    return;
  }
};

CSObject.prototype.draw = function (ctx) {
  ctx.save();
  ctx.translate(this._sp.x, this._sp.y);
  if (this._shellRotation) { ctx.rotate(this._shellRotation * D2R); }
  ctx.scale(1, this._shellYScale / 100);
  this.instance.draw(ctx);
  ctx.restore();
};

/* ------------------------------------------------------------------ *
 *  CelestialSphere  --  port of CelestialSphere.as + modules 2..9       *
 * ------------------------------------------------------------------ */

function CelestialSphere() {
  Instance.call(this);

  this._c = {};
  this._objectList = [];
  this._circleList = [];
  this._lineList = [];
  this._maxPhi = 90;
  this._minPhi = -90;
  this._c.r = 150;                       // size 300
  this._c.r2 = this._c.r * this._c.r;
  this._showUnder = true;
  this._phi = 0.5235987755982988;
  this._lat = 0;
  this._sTime = 0;

  /* One list per shading layer of the Flash depth stack. */
  this.shading = {
    bOSB: [], bOSA: [], bOSF: [],
    bISB: [], bISA: [], bISF: [],
    fISB: [], fISA: [], fISF: [],
    fOSB: [], fOSA: [], fOSF: []
  };
  this.hPlane = { above: [], below: [] };
  this._hpVisible = true;

  /* Object depth groups, matching the AS depth bands. */
  this._grp = { bE: [], bS: [], bI: [], aI: [], fS: [], fE: [] };

  this.doM();
  this.setThetaAndPhi(INIT_THETA, INIT_PHI);
  this.setLatitude(41);
  this.setSiderealTime(0);
  this.createMasks();

  this.addHorizonPlaneClip('CSAboveHorizonPlane', 'above');
  this.addHorizonPlaneClip('CSBelowHorizonPlane', 'below');
  this.addShadingClip('CSGradientDisk', 'front', 'inner', 'both',
                      { innerAlpha: 0, innerColor: 16777215, outerAlpha: 20, outerColor: 0 });

  this.onMouseUpdate = null;
  this.update();
}

CelestialSphere.prototype = Object.create(Instance.prototype);
CelestialSphere.prototype.constructor = CelestialSphere;

CelestialSphere.prototype.update = function () {
  this.updateMasks();
  this.updateHorizonPlane();
  this.updateObjects();
  this.updateCircles();
  this.updateLines();
};

/* ---- getters / setters -- "2 CS Getter Setter.as" ---- */

CelestialSphere.prototype.setThetaAndPhi = function (newTheta, newPhi) {
  this._theta = D2R * mod(newTheta, 360);
  if (newPhi > this._maxPhi) { newPhi = this._maxPhi; }
  else if (newPhi < this._minPhi) { newPhi = this._minPhi; }
  this._phi = newPhi * D2R;
  this.doA();
  this.doB();
  this.updateMasks();
  this.updateHorizonPlane();
  this.updateObjects();
  this.updateCircles();
  this.updateLines();
};

CelestialSphere.prototype.getTheta = function () { return R2D * this._theta; };
CelestialSphere.prototype.getPhi = function () { return R2D * this._phi; };
CelestialSphere.prototype.getViewerAzimuth = function () { return mod(360 - this.getTheta(), 360); };

CelestialSphere.prototype.setSize = function (arg) {
  this._c.r = arg / 2;
  this._c.r2 = this._c.r * this._c.r;
  this.doA();
  this.doB();
  this.updateMasks();
  this.updateHorizonPlane();
  this.updateObjects();
  this.updateCircles();
  this.updateLines();
};
CelestialSphere.prototype.getSize = function () { return 2 * this._c.r; };

CelestialSphere.prototype.setSiderealTime = function (arg) {
  this._sTime = mod(arg, 24) * H2R;
  this.doM();
  this.doB();
  this.updateObjects();
  this.updateCircles(true);
  this.updateLines(true);
};

CelestialSphere.prototype.setLatitude = function (arg) {
  if (arg > 90) { arg = 90; } else if (arg < -90) { arg = -90; }
  this._lat = arg * D2R;
  this.doM();
  this.doB();
  this.updateObjects();
  this.updateCircles(true);
  this.updateLines(true);
};

/* ---- geometry -- "3 CS Geometry.as" ---- */

CelestialSphere.prototype.parsePointInput = function (p1, p2) {
  var r, d;
  if (p1.az !== undefined && p1.alt !== undefined) {
    p2.sys = 0; p2.system = 'horizon';
    r = (p1.r !== undefined) ? p1.r : 1;
    d = r * Math.cos(p1.alt * D2R);
    p2.x = d * Math.cos(p1.az * D2R);
    p2.y = d * Math.sin(-p1.az * D2R);
    p2.z = r * Math.sin(p1.alt * D2R);
    p2.r = Math.abs(r);
  } else if (p1.ra !== undefined && p1.dec !== undefined) {
    p2.sys = 1; p2.system = 'celestial';
    r = (p1.r !== undefined) ? p1.r : 1;
    d = r * Math.cos(p1.dec * D2R);
    p2.x = d * Math.cos(p1.ra * H2R);
    p2.y = d * Math.sin(p1.ra * H2R);
    p2.z = r * Math.sin(p1.dec * D2R);
    p2.r = Math.abs(r);
  } else if (p1.x !== undefined && p1.y !== undefined && p1.z !== undefined) {
    if (p1.system === 'horizon') { p2.sys = 0; p2.system = 'horizon'; }
    else if (p1.system === 'celestial') { p2.sys = 1; p2.system = 'celestial'; }
    else { p2.sys = -1; p2.system = 'unknown'; }
    p2.x = p1.x; p2.y = p1.y; p2.z = p1.z;
    p2.r = Math.sqrt(p2.x * p2.x + p2.y * p2.y + p2.z * p2.z);
    if (p2.r < 1.000001 && p2.r > 0.999999) { p2.r = 1; }
  } else {
    p2.sys = null; p2.system = null;
    p2.x = null; p2.y = null; p2.z = null; p2.r = null;
  }
};

CelestialSphere.prototype.WtoSz = function (p, sp) {
  var c = this._c;
  sp.x = p.x * c.a0 + p.y * c.a1;
  sp.y = p.x * c.a3 + p.y * c.a4 + p.z * c.a5;
  sp.z = p.x * c.a6 + p.y * c.a7 + p.z * c.a8;
};

CelestialSphere.prototype.CtoSz = function (p, sp) {
  var c = this._c;
  sp.x = p.x * c.b0 + p.y * c.b1 + p.z * c.b2;
  sp.y = p.x * c.b3 + p.y * c.b4 + p.z * c.b5;
  sp.z = p.x * c.b6 + p.y * c.b7 + p.z * c.b8;
};

CelestialSphere.prototype.CtoW = function (p, wp) {
  var c = this._c;
  wp.x = p.x * c.m0 + p.y * c.m1 + p.z * c.m2;
  wp.y = p.x * c.m3 + p.y * c.m4;
  wp.z = p.x * c.m6 + p.y * c.m7 + p.z * c.m8;
};

CelestialSphere.prototype.WtoC = function (p, cp) {
  var c = this._c;
  cp.x = p.x * c.m0 + p.y * c.m3 + p.z * c.m6;
  cp.y = p.x * c.m1 + p.y * c.m4 + p.z * c.m7;
  cp.z = p.x * c.m2 + p.z * c.m8;
};

/* Screen point -> "maths" horizon angles (radians). */
CelestialSphere.prototype.StoMH = function (sp, hp) {
  var M = Math;
  var d = M.sqrt(sp.x * sp.x + sp.y * sp.y) / this._c.r;
  if (d > 1) { d = 1; }
  var b = M.asin(d);
  var A = M.atan2(sp.x, -sp.y);
  if (this._phi === HALF_PI) {
    hp.alt = HALF_PI - b;
    hp.az = this._theta + Math.PI - A;
  } else if (this._phi === -HALF_PI) {
    hp.alt = -HALF_PI + b;
    hp.az = this._theta + A;
  } else {
    var cc = M.cos(HALF_PI - this._phi);
    var sc = M.sin(HALF_PI - this._phi);
    var cb = M.cos(b), sb = M.sin(b);
    var ca = cb * cc + sb * sc * M.cos(A);
    hp.alt = HALF_PI - M.acos(ca);
    hp.az = this._theta + M.atan2(sb * M.sin(A), (cb - ca * cc) / sc);
  }
  hp.az = mod(hp.az, TWO_PI);
};

/* A: horizon -> screen.  M: celestial -> horizon.  B = A . M. */
CelestialSphere.prototype.doA = function () {
  var c = this._c;
  var ct = Math.cos(this._theta), st = Math.sin(this._theta);
  var cp = Math.cos(this._phi), sp = Math.sin(this._phi);
  c.a0 = -c.r * st;
  c.a1 = c.r * ct;
  c.a3 = c.r * ct * sp;
  c.a4 = c.r * st * sp;
  c.a5 = -c.r * cp;
  c.a6 = c.r * ct * cp;
  c.a7 = c.r * st * cp;
  c.a8 = c.r * sp;
};

CelestialSphere.prototype.doM = function () {
  var c = this._c;
  c.m2 = Math.cos(this._lat);
  c.m3 = Math.sin(this._sTime);
  c.m4 = -Math.cos(this._sTime);
  c.m8 = Math.sin(this._lat);
  c.m0 = c.m4 * c.m8;
  c.m1 = -c.m3 * c.m8;
  c.m6 = -c.m2 * c.m4;
  c.m7 = c.m2 * c.m3;
};

CelestialSphere.prototype.doB = function () {
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

/* ---- masks -- "6 CS Shading.as" ---- */

CelestialSphere.prototype.createMasks = function () { this.updateMasks(); };

CelestialSphere.prototype.updateMasks = function () {
  var r = this._c.r;
  if (!r) { return; }
  var d = 1.2 * r;                       // AS: r = 100, d = 120, scaled by _c.r
  var s = Math.sin(this._phi);
  var hnp = 4;
  var step = Math.PI / hnp;
  var halfStep = step / 2;
  var cr = r / Math.cos(halfStep);
  var sax = r, say = s * r, scx = cr, scy = s * cr;

  /* dy picks the square half (top or bottom); sgn picks the near or far
     half of the projected horizon ellipse. */
  function build(dy, sgn) {
    var p = new Path2D();
    p.moveTo(d, dy);
    p.lineTo(d, 0);
    p.lineTo(r, 0);
    var aAngle = step, cAngle = aAngle - halfStep;
    for (var i = 0; i < hnp; i++) {
      p.quadraticCurveTo(scx * Math.cos(cAngle), sgn * scy * Math.sin(cAngle),
                         sax * Math.cos(aAngle), sgn * say * Math.sin(aAngle));
      aAngle += step; cAngle += step;
    }
    p.lineTo(-d, 0);
    p.lineTo(-d, dy);
    p.lineTo(d, dy);
    p.closePath();
    return p;
  }

  this._M1 = build(-d, 1);   // above the near half of the horizon ellipse
  this._M2 = build(d, 1);    // below the near half
  this._M3 = build(-d, -1);  // above the far half
  this._M4 = build(d, -1);   // below the far half
};

/* ---- shading and horizon-plane clips ---- */

CelestialSphere.prototype.addShadingClip = function (linkageName, side, surface, hemisphere, initObject) {
  var layer = (side === 'back' ? 'b' : 'f') + (surface === 'inner' ? 'I' : 'O') + 'S' +
              (hemisphere === 'below' ? 'B' : (hemisphere === 'above' ? 'A' : 'F'));
  var clip = { kind: linkageName, init: initObject || {} };
  this.shading[layer].push(clip);
  return clip;
};

CelestialSphere.prototype.addHorizonPlaneClip = function (linkageName, side) {
  var clip = { kind: linkageName };
  this.hPlane[side === 'below' ? 'below' : 'above'].push(clip);
  return clip;
};

CelestialSphere.prototype.updateHorizonPlane = function () {
  this._hpXScale = this._c.r;                          // percent, art radius 100
  this._hpYScale = this._c.r * Math.sin(this._phi);
  this._hpRotation = 180 + this._theta * R2D;
  this._hpSide = (this._phi > 0) ? 'above' : 'below';
};

/* ---- circles and lines ---- */

CelestialSphere.prototype.addCircle = function (name, style, definition) {
  var circle = new CSCircle(this, style, definition);
  this[name] = circle;
  this._circleList.push(circle);
  return circle;
};

CelestialSphere.prototype.updateCircles = function (notHorizon) {
  /* The AS guards the notHorizon branch with `if (!circle._sys == 0)`, which
     evaluates to true for both _sys 0 and _sys 1, so every circle is updated
     either way. Reproduced as observed. */
  for (var i = 0; i < this._circleList.length; i++) {
    this._circleList[i].update();
  }
};

CelestialSphere.prototype.addLine = function (name, style, head, tail) {
  var line = new CSLine(this, style, head, tail);
  this[name] = line;
  this._lineList.push(line);
  return line;
};

CelestialSphere.prototype.updateLines = function (notHorizon) {
  for (var i = 0; i < this._lineList.length; i++) {
    var line = this._lineList[i];
    if (notHorizon) {
      if (line._head.sys !== 0 || line._tail.sys !== 0) { line.update(); }
    } else {
      line.update();
    }
  }
};

/* ---- objects and depth sorting -- "7 CS Objects.as" ---- */

CelestialSphere.prototype.addObject = function (name, instance, position) {
  var obj = new CSObject(this, instance, position);
  this[name] = obj;
  this._objectList.push(obj);
  return obj;
};

function sortRegion(a, b) { return a.z < b.z ? -1 : (a.z > b.z ? 1 : 0); }

CelestialSphere.prototype.updateObjects = function () {
  var g = this._grp;
  g.bE = []; g.bS = []; g.bI = []; g.aI = []; g.fS = []; g.fE = [];
  var hU = !this._showUnder;              // false throughout this simulation
  var list = this._objectList;

  for (var i = 0; i < list.length; i++) {
    var obj = list[i];
    if (!obj._visible) { continue; }
    var wp;

    if (obj._r > 1) {
      /* outside the sphere */
      if (hU) {
        wp = {};
        if (obj._sys === 0) { wp = obj._p; } else if (obj._sys === 1) { this.CtoW(obj._p, wp); }
        if (wp.z < 0) { continue; }
        this.WtoSz(wp, obj._sp);
      } else if (obj._sys === 0) { this.WtoSz(obj._p, obj._sp); }
      else { this.CtoSz(obj._p, obj._sp); }
      (obj._sp.z < 0 ? g.bE : g.fE).push({ z: obj._sp.z, obj: obj });

    } else if (obj._r < 1) {
      /* inside the sphere */
      wp = {};
      if (obj._sys === 0) { wp = obj._p; } else if (obj._sys === 1) { this.CtoW(obj._p, wp); }
      if (hU && wp.z < 0) { continue; }
      this.WtoSz(wp, obj._sp);
      (wp.z < 0 ? g.bI : g.aI).push({ z: obj._sp.z, obj: obj });

    } else {
      /* on the sphere surface */
      if (hU) {
        wp = {};
        if (obj._sys === 0) { wp = obj._p; } else if (obj._sys === 1) { this.CtoW(obj._p, wp); }
        if (wp.z < 0) { continue; }
        this.WtoSz(wp, obj._sp);
      } else if (obj._sys === 0) { this.WtoSz(obj._p, obj._sp); }
      else { this.CtoSz(obj._p, obj._sp); }
      (obj._sp.z < 0 ? g.bS : g.fS).push({ z: obj._sp.z, obj: obj });
    }

    obj.update();
  }

  /* With the horizon plane hidden there is nothing to separate the two
     inner bands, so the "above" band collapses into the "below" one. */
  if (!this._hpVisible) {
    while (g.aI.length) { g.bI.push(g.aI.pop()); }
  }

  g.bE.sort(sortRegion); g.bS.sort(sortRegion); g.bI.sort(sortRegion);
  g.aI.sort(sortRegion); g.fS.sort(sortRegion); g.fE.sort(sortRegion);
};

/* ---- rendering: walk the Flash depth stack in order ---- */

CelestialSphere.prototype._clipped = function (ctx, mask, fn) {
  if (!mask) { fn(); return; }
  ctx.save();
  ctx.clip(mask);
  fn();
  ctx.restore();
};

CelestialSphere.prototype._drawShading = function (ctx, layer) {
  var list = this.shading[layer];
  if (!list.length) { return; }
  var scale = this._c.r / 100;
  for (var i = 0; i < list.length; i++) {
    var clip = list[i];
    ctx.save();
    ctx.scale(scale, scale);
    if (clip.kind === 'Sphere Shading') {
      drawArt(ctx, ART.sphereShading);
    } else if (clip.kind === 'CSGradientDisk') {
      /* CSGradientDisk.as: radial fill, radius 100, inner -> outer. */
      var init = clip.init;
      var grad = ctx.createRadialGradient(0, 0, 0, 0, 0, 100);
      grad.addColorStop(0, cssColor(init.innerColor === undefined ? 16711680 : init.innerColor,
                                    init.innerAlpha === undefined ? 80 : init.innerAlpha));
      grad.addColorStop(1, cssColor(init.outerColor === undefined ? 16711935 : init.outerColor,
                                    init.outerAlpha === undefined ? 40 : init.outerAlpha));
      ctx.fillStyle = grad;
      ctx.beginPath();
      ctx.arc(0, 0, 100, 0, TWO_PI);
      ctx.fill();
    }
    ctx.restore();
  }
};

CelestialSphere.prototype._drawHorizonPlane = function (ctx) {
  if (!this._hpVisible) { return; }
  var list = this.hPlane[this._hpSide];
  if (!list.length) { return; }
  ctx.save();
  ctx.scale(this._hpXScale / 100, this._hpYScale / 100);
  ctx.rotate(this._hpRotation * D2R);
  for (var i = 0; i < list.length; i++) {
    drawArt(ctx, list[i].kind === 'CSBelowHorizonPlane' ? ART.horizonBelow : ART.horizonAbove);
  }
  ctx.restore();
};

CelestialSphere.prototype._drawCircles = function (ctx, side) {
  for (var i = 0; i < this._circleList.length; i++) {
    var c = this._circleList[i];
    if (!c._visible) { continue; }
    ctx.lineWidth = c._thick || 1;
    ctx.strokeStyle = cssColor(c._color, c._alpha);
    ctx.stroke(side === 'front' ? c.frontPath : c.backPath);
  }
};

CelestialSphere.prototype._drawLines = function (ctx, bucket) {
  for (var i = 0; i < this._lineList.length; i++) {
    var line = this._lineList[i];
    var segs = line.segs[bucket];
    if (!segs.length) { continue; }
    ctx.lineWidth = line._thick || 1;
    ctx.strokeStyle = cssColor(line._color, line._alpha);
    ctx.beginPath();
    for (var j = 0; j < segs.length; j++) {
      ctx.moveTo(segs[j][0], segs[j][1]);
      ctx.lineTo(segs[j][2], segs[j][3]);
    }
    ctx.stroke();
  }
};

CelestialSphere.prototype._drawGroup = function (ctx, group) {
  for (var i = 0; i < group.length; i++) { group[i].obj.draw(ctx); }
};

CelestialSphere.prototype.render = function (ctx) {
  var self = this;
  var g = this._grp;
  var phiPositive = this._phi >= 0;

  ctx.lineCap = 'butt';
  ctx.lineJoin = 'round';

  /* Depth order of the Flash layer stack, with each layer's mask. */
  this._drawGroup(ctx, g.bE);                                            // objects, back external
  this._drawLines(ctx, 'bE');                                            // _bEL
  this._clipped(ctx, this._M4, function () { self._drawShading(ctx, 'bOSB'); });
  this._clipped(ctx, this._M3, function () { self._drawShading(ctx, 'bOSA'); });
  this._drawShading(ctx, 'bOSF');
  this._drawCircles(ctx, 'back');                                        // _bC
  this._drawGroup(ctx, g.bS);                                            // objects, back surface
  this._clipped(ctx, this._M4, function () { self._drawShading(ctx, 'bISB'); });
  this._clipped(ctx, this._M3, function () { self._drawShading(ctx, 'bISA'); });
  this._drawShading(ctx, 'bISF');

  /* The two inner bands swap when the view drops below the horizon plane. */
  this._drawGroup(ctx, phiPositive ? g.bI : g.aI);
  this._drawLines(ctx, phiPositive ? 'bI' : 'aI');                       // _iLB / _iLA
  this._drawHorizonPlane(ctx);                                           // _hP
  this._drawGroup(ctx, phiPositive ? g.aI : g.bI);
  this._drawLines(ctx, phiPositive ? 'aI' : 'bI');                       // _iLA / _iLB

  this._clipped(ctx, this._M2, function () { self._drawShading(ctx, 'fISB'); });
  this._clipped(ctx, this._M1, function () { self._drawShading(ctx, 'fISA'); });
  this._drawShading(ctx, 'fISF');
  this._drawCircles(ctx, 'front');                                       // _fC
  this._drawGroup(ctx, g.fS);                                            // objects, front surface
  this._clipped(ctx, this._M2, function () { self._drawShading(ctx, 'fOSB'); });
  this._clipped(ctx, this._M1, function () { self._drawShading(ctx, 'fOSA'); });
  this._drawShading(ctx, 'fOSF');
  this._drawGroup(ctx, g.fE);                                            // objects, front external
  this._drawLines(ctx, 'fE');                                            // _fEL
};

CelestialSphere.prototype.drawArt = function (ctx) { this.render(ctx); };

/* ------------------------------------------------------------------ *
 *  Simple drag -- "4 CS Mouse.as"                                      *
 * ------------------------------------------------------------------ */

CelestialSphere.prototype.startSimpleDragging = function (mx, my) {
  this._dragXMouse = mx;
  this._dragYMouse = my;
  this._dragTheta = this._theta;
  this._dragPhi = this._phi;
};

CelestialSphere.prototype.updateSimpleDragging = function (mx, my) {
  this.setThetaAndPhi(
    R2D * (this._dragTheta - (mx - this._dragXMouse) / this._c.r),
    R2D * (this._dragPhi + (my - this._dragYMouse) / this._c.r)
  );
  if (this.onMouseUpdate) { this.onMouseUpdate(); }
};

/* Is the pointer inside the draggable disk? (updateMouseArea, _showUnder true) */
CelestialSphere.prototype.hitTest = function (mx, my) {
  return Math.sqrt(mx * mx + my * my) <= this._c.r;
};

/* ------------------------------------------------------------------ *
 *  GlobeComponent  --  port of GlobeComponent.as                       *
 * ------------------------------------------------------------------ */

function GlobeComponent() {
  Instance.call(this);
  this._c = {};
  this._radius = 40;                     // p._radius = 40
  this._globeScale = 100;
  this._shoresPath = new Path2D();
  this.rotationAngle = 0;
  this.precessionAngle = 0;
  this._lastSTime = null;
}

GlobeComponent.prototype = Object.create(Instance.prototype);
GlobeComponent.prototype.constructor = GlobeComponent;

GlobeComponent.prototype.init = function () {
  this.setPrecessionAngle(0);
  this.setRotationAngle(0);
};

GlobeComponent.prototype.setScale = function (arg) { this._globeScale = arg; };

/* 0.91706 = cos(23.44 deg), 0.39875 = sin(23.44 deg): the obliquity tilt. */
GlobeComponent.prototype.setPrecessionAngle = function (arg) {
  this.precessionAngle = arg;
  arg *= D2R;
  var cp = Math.cos(arg), sp = Math.sin(arg);
  var c = this._c;
  c.p0 = cp;  c.p1 = -sp;
  c.p3 = sp * 0.91706; c.p4 = cp * 0.91706; c.p5 = -0.39875;
  c.p6 = sp * 0.39875; c.p7 = cp * 0.39875; c.p8 = 0.91706;
  this._composeQ();
};

GlobeComponent.prototype.setRotationAngle = function (arg) {
  this.rotationAngle = arg;
  arg = this._sphere._sTime + arg * D2R;
  var cr = Math.cos(arg), sr = Math.sin(arg);
  var c = this._c;
  c.r0 = cr;  c.r1 = -sr;
  c.r3 = sr * 0.91706;  c.r4 = cr * 0.91706;  c.r5 = 0.39875;
  c.r6 = -sr * 0.39875; c.r7 = -cr * 0.39875; c.r8 = 0.91706;
  this._composeQ();
};

GlobeComponent.prototype._composeQ = function () {
  var c = this._c;
  if (c.p0 === undefined || c.r0 === undefined) { return; }
  c.q0 = c.p0 * c.r0 + c.p1 * c.r3;
  c.q1 = c.p0 * c.r1 + c.p1 * c.r4;
  c.q2 = c.p1 * c.r5;
  c.q3 = c.p3 * c.r0 + c.p4 * c.r3 + c.p5 * c.r6;
  c.q4 = c.p3 * c.r1 + c.p4 * c.r4 + c.p5 * c.r7;
  c.q5 = c.p4 * c.r5 + c.p5 * c.r8;
  c.q6 = c.p6 * c.r0 + c.p7 * c.r3 + c.p8 * c.r6;
  c.q7 = c.p6 * c.r1 + c.p7 * c.r4 + c.p8 * c.r7;
  c.q8 = c.p7 * c.r5 + c.p8 * c.r8;
};

GlobeComponent.prototype.update = function () {
  var sphere = this._sphere;
  if (sphere._sTime !== this._lastSTime) { this.setRotationAngle(this.rotationAngle); }
  this._lastSTime = sphere._sTime;

  var tc = this._c, pc = sphere._c;
  var sf = this._radius / pc.r;
  var k0 = sf * (pc.b0 * tc.q0 + pc.b1 * tc.q3 + pc.b2 * tc.q6);
  var k1 = sf * (pc.b0 * tc.q1 + pc.b1 * tc.q4 + pc.b2 * tc.q7);
  var k2 = sf * (pc.b0 * tc.q2 + pc.b1 * tc.q5 + pc.b2 * tc.q8);
  var k3 = sf * (pc.b3 * tc.q0 + pc.b4 * tc.q3 + pc.b5 * tc.q6);
  var k4 = sf * (pc.b3 * tc.q1 + pc.b4 * tc.q4 + pc.b5 * tc.q7);
  var k5 = sf * (pc.b3 * tc.q2 + pc.b4 * tc.q5 + pc.b5 * tc.q8);
  var k6 = sf * (pc.b6 * tc.q0 + pc.b7 * tc.q3 + pc.b8 * tc.q6);
  var k7 = sf * (pc.b6 * tc.q1 + pc.b7 * tc.q4 + pc.b8 * tc.q7);
  var k8 = sf * (pc.b6 * tc.q2 + pc.b7 * tc.q5 + pc.b8 * tc.q8);

  /* Rebuild the shoreline mask: each coastline polygon is projected, and
     runs that pass behind the globe are replaced by an arc of radius d. */
  var path = new Path2D();
  var s = SHORE_DATA;
  var r = this._radius;
  var d = 1.5 * r;
  var minStep = 2 * Math.acos(r * 1.1 / d);
  var cos = Math.cos, sin = Math.sin, atan2 = Math.atan2, ceil = Math.ceil;

  for (var i = 0; i < s.length; i++) {
    var p = s[i];
    var pl = p.length;
    var lastInFront = false;
    var sj = 0;
    for (; sj < pl; sj++) {
      var pt = p[sj];
      if (pt.x * k6 + pt.y * k7 + pt.z * k8 > 0) {
        if (lastInFront) {
          path.moveTo(pt.x * k0 + pt.y * k1 + pt.z * k2,
                      pt.x * k3 + pt.y * k4 + pt.z * k5);
          break;
        }
        lastInFront = true;
      } else {
        lastInFront = false;
      }
    }
    if (sj === pl) { continue; }

    var ibLast = false;
    var angleLast = 0;
    for (var j = 1; j < pl; j++) {
      var q = p[(sj + j) % pl];
      var ibNow = (q.x * k6 + q.y * k7 + q.z * k8) < 0;
      if (!ibNow) {
        var sx = q.x * k0 + q.y * k1 + q.z * k2;
        var sy = q.x * k3 + q.y * k4 + q.z * k5;
        if (ibLast) {
          var angleNow = atan2(sy, sx);
          var arc = mod(angleNow - angleLast, TWO_PI);
          var n, step;
          if (arc > Math.PI) { arc = TWO_PI - arc; n = ceil(arc / minStep); step = -arc / n; }
          else { n = ceil(arc / minStep); step = arc / n; }
          for (var k = 1; k <= n; k++) {
            var angle = angleLast + step * k;
            path.lineTo(d * cos(angle), d * sin(angle));
          }
          path.lineTo(sx, sy);
        } else {
          path.lineTo(sx, sy);
        }
      } else if (!ibLast) {
        var x = q.x * k0 + q.y * k1 + q.z * k2;
        var y = q.x * k3 + q.y * k4 + q.z * k5;
        angleLast = atan2(y, x);
        path.lineTo(d * cos(angleLast), d * sin(angleLast));
      }
      ibLast = ibNow;
    }
    path.closePath();
  }
  this._shoresPath = path;
};

GlobeComponent.prototype.drawArt = function (ctx) {
  ctx.save();
  ctx.scale(this._globeScale / 100, this._globeScale / 100);
  drawArt(ctx, ART.globeWater);                 // GlobeComponentWater, depth 10
  ctx.save();
  ctx.clip(this._shoresPath);                   // globe.land.setMask(globe.shores)
  drawArt(ctx, ART.globeLand);                  // GlobeComponentLand, depth 20
  ctx.restore();
  ctx.restore();
};

/* ------------------------------------------------------------------ *
 *  Small instances                                                     *
 * ------------------------------------------------------------------ */

/* Tangent Plane.as -- the horizon disk that grows as the view switches. */
function TangentPlane() {
  Instance.call(this);
  this._frame = 1;
}
TangentPlane.prototype = Object.create(Instance.prototype);
TangentPlane.prototype.constructor = TangentPlane;

TangentPlane.prototype.update = function (arg) {
  this._xscale = this._yscale = this._sphere.getSize() * (1 - arg) / 2;
  this._alpha = 40 + 0.6 * this._xscale;
  this._frame = (this._object._sp.z >= 0) ? 1 : 2;
};

/* Direction labels, 12 px: white over the lit face, #999999 over the dark one. */
TangentPlane.prototype.drawArt = function (ctx) {
  if (this._xscale <= 0.01) { return; }
  drawArt(ctx, this._frame === 1 ? ART.horizonAbove : ART.horizonBelow);

  var labelColor = (this._frame === 1) ? '#ffffff' : '#999999';
  ctx.save();
  ctx.fillStyle = labelColor;
  ctx.font = '12px Sans-Serif, Arial, Helvetica, sans-serif';
  ctx.textAlign = 'center';
  ctx.textBaseline = 'middle';
  ctx.fillText('N', 0, -88);
  ctx.fillText('S', 0, 88);
  ctx.fillText('E', 88, 0);
  ctx.fillText('W', -88, 0);
  ctx.restore();
};

function Stickfigure() { Instance.call(this); }
Stickfigure.prototype = Object.create(Instance.prototype);
Stickfigure.prototype.constructor = Stickfigure;
Stickfigure.prototype.drawArt = function (ctx) {
  if (this._xscale <= 0.01) { return; }
  drawArt(ctx, ART.stickfigure);
};

function ObserverDot() { Instance.call(this); }
ObserverDot.prototype = Object.create(Instance.prototype);
ObserverDot.prototype.constructor = ObserverDot;
ObserverDot.prototype.drawArt = function (ctx) { drawArt(ctx, ART.observerDot); };

/* ------------------------------------------------------------------ *
 *  Controller  --  port of DefineSprite_97 frame 1                     *
 * ------------------------------------------------------------------ */

var canvas, ctx, dpr, renderScale = 1;
var celestialSphere, globeSphere, globeComponent;
var transitionParameter, direction, startTime, animating;
var latitudeValue;

var el = {};

/* sliderV5Component.as: "fixed decimal places" mode. */
function sliderSetValue(x) {
  x = Number(x);
  if (!isFinite(x) || isNaN(x)) { return latitudeValue; }
  if (x < LAT_MIN) { x = LAT_MIN; } else if (x > LAT_MAX) { x = LAT_MAX; }
  return LAT_INCREMENT * Math.round(x / LAT_INCREMENT);
}

/* sliderV5Component.as toFixed polyfill, reproduced so the displayed text
   matches the original exactly (e.g. "41.0", "-5.0"). */
function sliderToFixed(x, f) {
  var s = '';
  if (x < 0) { s = '-'; x = -x; }
  var m = '';
  if (x < 1e21) {
    var n = Math.round(x * Math.pow(10, f));
    m = (n === 0) ? '0' : n.toString();
    if (f > 0) {
      var k = m.length;
      if (k <= f) {
        var z = '';
        for (var i = 0; i < f + 1 - k; i++) { z += '0'; }
        m = z + m;
        k = f + 1;
      }
      m = m.substr(0, k - f) + '.' + m.substr(k - f);
    }
  } else {
    m = x.toString();
  }
  return s + m;
}

function formatLatitude(v) { return sliderToFixed(v, LAT_PRECISION); }

function prefersReducedMotion() {
  return window.matchMedia &&
         window.matchMedia('(prefers-reduced-motion: reduce)').matches;
}

/* ---- initSphere() ---- */

function initSphere() {
  celestialSphere = new CelestialSphere();
  celestialSphere.setLatitude(90);
  celestialSphere.setSiderealTime(0);
  celestialSphere._hpVisible = false;               // showHorizonPlane = false

  celestialSphere.addShadingClip('Sphere Shading', 'front', 'inner', 'both');
  celestialSphere.addShadingClip('Sphere Shading', 'back', 'inner', 'both');

  celestialSphere.addCircle('horizonCircle',
    { thickness: 1, color: COLOR_HORIZON_CIRCLES, alpha: 30 }, { az: 0, alt: 0, tilt: 0 });
  celestialSphere.addCircle('meridianCircle1',
    { thickness: 1, color: COLOR_HORIZON_CIRCLES, alpha: 30 }, { az: 0, alt: 0, tilt: 0 });
  celestialSphere.addCircle('meridianCircle2',
    { thickness: 1, color: COLOR_HORIZON_CIRCLES, alpha: 30 }, { az: 0, alt: 0, tilt: 0 });
  celestialSphere.addCircle('zeroHoursCircle',
    { thickness: 1, color: COLOR_CELESTIAL, alpha: 70 },
    { ra: 0, dec: 0, tilt: 90, gammaStart: -90, gammaEnd: 90 });
  celestialSphere.addCircle('celestialEquator',
    { thickness: 1, color: COLOR_CELESTIAL, alpha: 70 }, { ra: 0, dec: 0, tilt: 0 });
  celestialSphere.zeroHoursCircle.update();
  celestialSphere.celestialEquator.update();

  celestialSphere.addLine('ncpAxis', { thickness: 2, color: COLOR_AXIS, alpha: 100 },
    { x: 0, y: 0, z: 1, system: 'celestial' }, { x: 0, y: 0, z: 1.2, system: 'celestial' });
  celestialSphere.addLine('scpAxis', { thickness: 2, color: COLOR_AXIS, alpha: 100 },
    { x: 0, y: 0, z: -1, system: 'celestial' }, { x: 0, y: 0, z: -1.2, system: 'celestial' });
  celestialSphere.updateLines();

  celestialSphere.addObject('tangentPlane', new TangentPlane(),
    { x: 0, y: 0, z: 0, system: 'horizon' });
  celestialSphere.addObject('stickfigure', new Stickfigure(),
    { x: 0, y: 0, z: 0, system: 'horizon' });

  globeSphere = new CelestialSphere();
  celestialSphere.addObject('globeSphere', globeSphere,
    { x: 0, y: 0, z: 0.001, system: 'horizon' });

  globeSphere.setSize(GLOBE_SPHERE_SIZE);
  globeSphere.setLatitude(90);
  globeSphere.setSiderealTime(0);
  globeSphere._hpVisible = false;

  globeSphere.addCircle('longitudeCircle',
    { thickness: 1, color: COLOR_GLOBE_CIRCLES, alpha: 100 },
    { alt: 0, az: 0, tilt: 90, gammaStart: 90, gammaEnd: -90 });
  globeSphere.addCircle('latitudeCircle',
    { thickness: 1, color: COLOR_GLOBE_CIRCLES, alpha: 100 }, { alt: 0, az: 0, tilt: 0 });
  globeSphere.longitudeCircle.update();

  globeSphere.addObject('dot', new ObserverDot(), { x: 0, y: 0, z: 0, system: 'horizon' });

  globeComponent = new GlobeComponent();
  globeSphere.addObject('globe', globeComponent, { x: 0, y: 0, z: 0, system: 'horizon' });
  globeComponent.init();
  globeComponent.setScale(100);
  globeComponent.update();

  celestialSphere.onMouseUpdate = function () {
    globeSphere.setThetaAndPhi(celestialSphere.getTheta(), celestialSphere.getPhi());
    globeComponent.update();
    celestialSphere.tangentPlane.instance.update(transitionParameter);
  };

  changeLatitude();
}

/* ---- updateCelestialDiagram() ---- */

function updateCelestialDiagram() {
  var t = transitionParameter;

  setTransitionFactor(t);

  var scale = t * 100;
  globeSphere._xscale = scale;
  globeSphere._yscale = scale;

  var pt = { az: 180, alt: latitudeValue, r: t * MAX_GLOBE_SIZE / celestialSphere.getSize() };
  celestialSphere.tangentPlane.setPosition(pt);
  celestialSphere.tangentPlane.setOrientationType('absolute');
  celestialSphere.tangentPlane.instance.update(t);

  pt.r += 0.001;
  celestialSphere.stickfigure.setPosition(pt);
  celestialSphere.stickfigure.setOrientationType('skewed', pt);
  celestialSphere.stickfigure.instance._xscale = 100 - scale;
  celestialSphere.stickfigure.instance._yscale = 100 - scale;

  celestialSphere.updateObjects();
  requestRender();
}

/* ---- changeLatitude() ---- */

function changeLatitude() {
  var lat = latitudeValue;

  globeSphere.latitudeCircle.setParameters({ alt: lat, az: 0, tilt: 0 });
  globeSphere.latitudeCircle.update();
  globeSphere.dot.setPosition({ az: 180, alt: lat });
  globeSphere.dot.setOrientationType('absolute');
  globeSphere.updateObjects();

  if (lat < 0) {
    celestialSphere.globeSphere.setPosition({ x: 0, y: 0, z: -0.001, system: 'horizon' });
    celestialSphere.meridianCircle1.setParameters(
      { alt: 0, az: 180, tilt: 90, gammaStart: lat - 90, gammaEnd: lat + 90 });
    celestialSphere.meridianCircle2.setParameters(
      { alt: 0, az: 90, tilt: -lat, gammaStart: 180, gammaEnd: 0 });
  } else {
    celestialSphere.globeSphere.setPosition({ x: 0, y: 0, z: 0.001, system: 'horizon' });
    celestialSphere.meridianCircle1.setParameters(
      { alt: 0, az: 180, tilt: 90, gammaStart: lat - 90, gammaEnd: lat + 90 });
    celestialSphere.meridianCircle2.setParameters(
      { alt: 0, az: 90, tilt: 180 - lat, gammaStart: 0, gammaEnd: 180 });
  }
  celestialSphere.meridianCircle1.update();
  celestialSphere.meridianCircle2.update();

  celestialSphere.horizonCircle.setParameters({ alt: 0, az: 90, tilt: 90 - lat });
  celestialSphere.horizonCircle.update();

  updateCelestialDiagram();
}

/* ---- doTransition() / onEnterFrameFunc() ---- */

function doTransition() {
  var now = performance.now();
  if (direction === 1) {
    startTime = now - TRANSITION_TIME * (1 - transitionParameter);
  } else {
    startTime = now - TRANSITION_TIME * (transitionParameter - 0.001);
  }
  direction *= -1;

  if (prefersReducedMotion()) {
    /* Equivalent instantaneous end state (WCAG 2.3.3). */
    transitionParameter = (direction === 1) ? 1 : 0.001;
    animating = false;
    updateCelestialDiagram();
    announceMode(true);
    return;
  }

  animating = true;
  requestAnimationFrame(onEnterFrameFunc);
  updateCelestialDiagram();
}

function onEnterFrameFunc() {
  if (!animating) { return; }
  var u = (performance.now() - startTime) / TRANSITION_TIME;
  if (u > 1) { u = 1; animating = false; }
  if (direction !== 1) { u = 1 - u; }
  if (u < 0.001) { u = 0.001; }
  transitionParameter = u;
  updateCelestialDiagram();
  if (animating) { requestAnimationFrame(onEnterFrameFunc); }
  else { announceMode(true); }
}

/* ---- Transition Arrow.as: interpolate the two end colours ---- */

function setTransitionFactor(arg) {
  var maxR = (ARROW_MAX_COLOR >> 16) & 255, maxG = (ARROW_MAX_COLOR >> 8) & 255, maxB = ARROW_MAX_COLOR & 255;
  var minR = (ARROW_MIN_COLOR >> 16) & 255, minG = (ARROW_MIN_COLOR >> 8) & 255, minB = ARROW_MIN_COLOR & 255;
  var halfRangeR = (maxR - minR) / 2, halfRangeG = (maxG - minG) / 2, halfRangeB = (maxB - minB) / 2;
  var halfPointR = minR + halfRangeR, halfPointG = minG + halfRangeG, halfPointB = minB + halfRangeB;

  var u = (arg - ARROW_HALF_POINT) / ARROW_HALF_RANGE;
  var left = 'rgb(' + Math.round(u * halfRangeR + halfPointR) + ',' +
                      Math.round(u * halfRangeG + halfPointG) + ',' +
                      Math.round(u * halfRangeB + halfPointB) + ')';
  var right = 'rgb(' + Math.round(-u * halfRangeR + halfPointR) + ',' +
                       Math.round(-u * halfRangeG + halfPointG) + ',' +
                       Math.round(-u * halfRangeB + halfPointB) + ')';

  el.headLeft.setAttribute('fill', left);
  el.headRight.setAttribute('fill', right);
  el.barLeft.style.background = 'linear-gradient(to right, ' + left + ', ' + right + ')';
  el.barRight.style.background = 'linear-gradient(to right, ' + left + ', ' + right + ')';
  el.labelCelestial.style.color = left;
  el.labelHorizon.style.color = right;

  /* Never colour alone: the dominant view is also bolded and named. */
  var celestialActive = arg >= 0.5;
  el.labelCelestial.classList.toggle('is-active', celestialActive);
  el.labelHorizon.classList.toggle('is-active', !celestialActive);
  el.labelCelestialState.textContent = celestialActive ? ' (view shown)' : ' (view not shown)';
  el.labelHorizonState.textContent = celestialActive ? ' (view not shown)' : ' (view shown)';
}

/* ------------------------------------------------------------------ *
 *  Rendering loop                                                      *
 * ------------------------------------------------------------------ */

var renderQueued = false;

function requestRender() {
  /* When the page is hidden, requestAnimationFrame never fires, so draw
     straight away rather than leaving the canvas blank. */
  if (document.hidden) {
    renderQueued = false;
    render();
    return;
  }
  if (renderQueued) { return; }
  renderQueued = true;
  requestAnimationFrame(function () {
    renderQueued = false;
    render();
  });
}

function render() {
  syncCanvasSize();
  /* All drawing stays in the original 380 x 380 Flash stage coordinates;
     only this outer scale changes with the display size and pixel ratio. */
  ctx.setTransform(renderScale, 0, 0, renderScale, 0, 0);
  ctx.clearRect(0, 0, STAGE, STAGE);
  ctx.fillStyle = '#000000';
  ctx.fillRect(0, 0, STAGE, STAGE);
  ctx.translate(ORIGIN, ORIGIN);
  celestialSphere.render(ctx);
  updateDescriptions();
}

/* ------------------------------------------------------------------ *
 *  Accessible narration                                                *
 * ------------------------------------------------------------------ */

function latitudeSpoken(v) {
  var txt = formatLatitude(v);
  if (v > 0) { return 'latitude ' + txt + ' degrees, that is ' + formatLatitude(v) + ' degrees north'; }
  if (v < 0) { return 'latitude minus ' + formatLatitude(-v) + ' degrees, that is ' +
                      formatLatitude(-v) + ' degrees south'; }
  return 'latitude ' + txt + ' degrees, on the equator';
}

function modeName() {
  if (transitionParameter >= 0.999) { return 'celestial sphere'; }
  if (transitionParameter <= 0.002) { return 'horizon diagram'; }
  return (direction === 1) ? 'changing to the celestial sphere'
                           : 'changing to the horizon diagram';
}

function announce(text) {
  el.live.textContent = text;
}

function announceMode(atEnd) {
  if (atEnd) {
    announce('Now showing the ' + modeName() + ' for an observer at ' +
             latitudeSpoken(latitudeValue) + '.');
  }
}

function updateDescriptions() {
  var az = celestialSphere.getViewerAzimuth();
  var alt = celestialSphere.getPhi();
  var view = 'View direction: azimuth ' + az.toFixed(0) + ' degrees, altitude ' +
             (alt < 0 ? 'minus ' + (-alt).toFixed(0) : alt.toFixed(0)) + ' degrees.';

  el.canvas.setAttribute('aria-label',
    'Celestial sphere diagram, currently showing the ' + modeName() + '. ' + view +
    ' Drag, or use the arrow keys, to rotate the view.');

  el.stageDesc.textContent =
    'The diagram shows the ' + modeName() + ' for an observer at ' +
    latitudeSpoken(latitudeValue) + '. ' +
    'The Earth globe sits at the centre of the celestial sphere, with a white observer dot ' +
    'and grey latitude and longitude circles on the globe. ' +
    'The pale yellow circles are the celestial equator and the zero hours circle; ' +
    'the faint white circles are the observer\'s horizon and two meridians; ' +
    'the pale blue line through the poles is the rotation axis of the celestial sphere. ' +
    'As the view changes to the horizon diagram, the globe shrinks away and the green ' +
    'horizon plane, marked north, south, east and west, grows to fill the sphere with a ' +
    'stick figure observer standing at its centre. ' + view;
}

/* ------------------------------------------------------------------ *
 *  Equation display (foundation kl-unl.js)                             *
 * ------------------------------------------------------------------ */

function showLatitudeEquation() {
  var tex = '\\( \\phi = ' + formatLatitude(latitudeValue) + '^{\\circ} \\)';

  /* The KL-UNL foundation folder supplied with this sim carries no MathJax
     include, and rule 5 forbids a CDN, so MathJax may be absent. Rather than
     print raw LaTeX (which rule 8 forbids), the container is hidden until a
     local MathJax is dropped into foundation/; the spoken description below
     still carries the value and its unit. See CONVERSION_NOTES.md. */
  var haveMathJax = !!(window.MathJax && window.MathJax.typesetPromise);
  el.latEqn.hidden = !haveMathJax;

  klunlShowEquation(
    ['latEqn', haveMathJax ? tex : ''],
    ['latEqnMsg', 'Observer\'s ' + latitudeSpoken(latitudeValue) + '.']
  );
}

/* klunlInitEqn is redefined here, as the foundation intends. */
window.klunlInitEqn = function () { showLatitudeEquation(); };

/* ------------------------------------------------------------------ *
 *  Latitude control wiring                                             *
 * ------------------------------------------------------------------ */

function setLatitude(raw, announceIt) {
  var v = sliderSetValue(raw);
  if (v === latitudeValue) {
    syncLatitudeControls();
    return;
  }
  latitudeValue = v;
  changeLatitude();
  syncLatitudeControls();
  showLatitudeEquation();
  if (announceIt) { announce('Observer\'s ' + latitudeSpoken(latitudeValue) + '.'); }
}

function syncLatitudeControls() {
  var txt = formatLatitude(latitudeValue);
  if (document.activeElement !== el.latNumber) { el.latNumber.value = txt; }
  el.latSlider.value = String(latitudeValue);
  var spoken = 'Observer\'s ' + latitudeSpoken(latitudeValue);
  el.latSlider.setAttribute('aria-valuetext', spoken);
  el.latNumber.setAttribute('aria-label', spoken);
}

/* ------------------------------------------------------------------ *
 *  Pointer and keyboard interaction with the diagram                   *
 * ------------------------------------------------------------------ */

var dragging = false, dragPointerId = null;

function stageCoords(e) {
  var rect = el.canvas.getBoundingClientRect();
  var sx = STAGE / rect.width;
  var sy = STAGE / rect.height;
  return {
    x: (e.clientX - rect.left) * sx - ORIGIN,
    y: (e.clientY - rect.top) * sy - ORIGIN
  };
}

function onPointerDown(e) {
  var p = stageCoords(e);
  if (!celestialSphere.hitTest(p.x, p.y)) { return; }
  /* Click to focus, so the arrow keys work straight away. */
  el.canvas.focus();
  dragging = true;
  dragPointerId = e.pointerId;
  el.canvas.setPointerCapture(e.pointerId);
  celestialSphere.startSimpleDragging(p.x, p.y);
  e.preventDefault();
}

function onPointerMove(e) {
  if (!dragging || e.pointerId !== dragPointerId) { return; }
  var p = stageCoords(e);
  celestialSphere.updateSimpleDragging(p.x, p.y);
  requestRender();
  e.preventDefault();
}

function onPointerUp(e) {
  if (!dragging || e.pointerId !== dragPointerId) { return; }
  dragging = false;
  dragPointerId = null;
  try { el.canvas.releasePointerCapture(e.pointerId); } catch (err) { /* already released */ }
  announceView();
}

function announceView() {
  var az = celestialSphere.getViewerAzimuth();
  var alt = celestialSphere.getPhi();
  announce('View rotated to azimuth ' + az.toFixed(0) + ' degrees, altitude ' +
           (alt < 0 ? 'minus ' + (-alt).toFixed(0) : alt.toFixed(0)) + ' degrees.');
}

/* Keyboard equivalent of the drag: the same state, the same setter. */
function rotateView(dTheta, dPhi) {
  celestialSphere.setThetaAndPhi(celestialSphere.getTheta() + dTheta,
                                 celestialSphere.getPhi() + dPhi);
  if (celestialSphere.onMouseUpdate) { celestialSphere.onMouseUpdate(); }
  requestRender();
  announceView();
}

function onStageKeyDown(e) {
  var step = 5, bigStep = 15;
  switch (e.key) {
  case 'ArrowLeft':  rotateView(-step, 0); break;
  case 'ArrowRight': rotateView(step, 0); break;
  case 'ArrowUp':    rotateView(0, step); break;
  case 'ArrowDown':  rotateView(0, -step); break;
  case 'PageUp':     rotateView(0, bigStep); break;
  case 'PageDown':   rotateView(0, -bigStep); break;
  case 'Home':
    celestialSphere.setThetaAndPhi(celestialSphere.getTheta(), celestialSphere._minPhi);
    if (celestialSphere.onMouseUpdate) { celestialSphere.onMouseUpdate(); }
    requestRender(); announceView();
    break;
  case 'End':
    celestialSphere.setThetaAndPhi(celestialSphere.getTheta(), celestialSphere._maxPhi);
    if (celestialSphere.onMouseUpdate) { celestialSphere.onMouseUpdate(); }
    requestRender(); announceView();
    break;
  default:
    return;    /* Tab and everything else pass through: no keyboard trap. */
  }
  e.preventDefault();
}

/* ------------------------------------------------------------------ *
 *  Reset (masthead "sim-reset")                                        *
 * ------------------------------------------------------------------ */

function resetSim() {
  animating = false;
  transitionParameter = 1;
  direction = 1;
  latitudeValue = INIT_LATITUDE;
  celestialSphere.setThetaAndPhi(INIT_THETA, INIT_PHI);
  globeSphere.setThetaAndPhi(INIT_THETA, INIT_PHI);
  globeComponent.update();
  changeLatitude();
  syncLatitudeControls();
  showLatitudeEquation();
  announce('Simulation reset. Showing the celestial sphere for an observer at ' +
           latitudeSpoken(latitudeValue) + '. View direction restored.');
}

/* ------------------------------------------------------------------ *
 *  Start-up                                                            *
 * ------------------------------------------------------------------ */

function cacheElements() {
  ['stage', 'stageDesc', 'switchBtn', 'latNumber', 'latSlider', 'liveRegion', 'latEqn',
   'labelCelestial', 'labelHorizon', 'labelCelestialState', 'labelHorizonState',
   'headLeft', 'headRight', 'barLeft', 'barRight'].forEach(function (id) {
    el[id] = document.getElementById(id);
  });
  el.canvas = el.stage;
  el.live = el.liveRegion;
}

/* Backing store follows the on-screen size so the stage stays crisp when CSS
   scales it; the drawing code never sees this. Checked at the top of every
   render rather than only on resize events, because resize and
   ResizeObserver callbacks are suspended while the page is hidden and would
   otherwise leave a stale backing store behind. */
function syncCanvasSize() {
  dpr = window.devicePixelRatio || 1;
  var cssWidth = canvas.getBoundingClientRect().width || STAGE;
  var backing = Math.max(1, Math.round(cssWidth * dpr));
  renderScale = backing / STAGE;
  if (canvas.width !== backing || canvas.height !== backing) {
    canvas.width = backing;
    canvas.height = backing;
  }
}

function sizeCanvas() {
  requestRender();
}

function boot() {
  cacheElements();
  canvas = el.canvas;
  ctx = canvas.getContext('2d');

  transitionParameter = 1;      // transitionParameter = 1
  direction = 1;                // direction = 1
  animating = false;
  latitudeValue = INIT_LATITUDE;

  initSphere();
  sizeCanvas();
  syncLatitudeControls();
  showLatitudeEquation();

  /* --- controls --- */
  el.switchBtn.addEventListener('click', doTransition);

  el.latSlider.addEventListener('input', function () {
    setLatitude(el.latSlider.value, false);
  });
  el.latSlider.addEventListener('change', function () {
    setLatitude(el.latSlider.value, true);
  });

  el.latNumber.addEventListener('input', function () {
    if (el.latNumber.value === '' || el.latNumber.value === '-') { return; }
    setLatitude(el.latNumber.value, false);
  });
  el.latNumber.addEventListener('change', function () {
    setLatitude(el.latNumber.value, true);
    el.latNumber.value = formatLatitude(latitudeValue);
  });
  el.latNumber.addEventListener('blur', function () {
    el.latNumber.value = formatLatitude(latitudeValue);
  });

  /* Mouse wheel adjusts the focused numeric field by one step. */
  el.latNumber.addEventListener('wheel', function (e) {
    if (document.activeElement !== el.latNumber) { return; }
    e.preventDefault();
    setLatitude(latitudeValue + (e.deltaY < 0 ? LAT_INCREMENT : -LAT_INCREMENT), true);
    el.latNumber.value = formatLatitude(latitudeValue);
  }, { passive: false });

  el.latNumber.addEventListener('keydown', function (e) {
    var big = 1;
    if (e.key === 'PageUp') { setLatitude(latitudeValue + big, true); }
    else if (e.key === 'PageDown') { setLatitude(latitudeValue - big, true); }
    else if (e.key === 'Home') { setLatitude(LAT_MIN, true); }
    else if (e.key === 'End') { setLatitude(LAT_MAX, true); }
    else { return; }
    el.latNumber.value = formatLatitude(latitudeValue);
    e.preventDefault();
  });

  /* --- diagram --- */
  canvas.addEventListener('pointerdown', onPointerDown);
  canvas.addEventListener('pointermove', onPointerMove);
  canvas.addEventListener('pointerup', onPointerUp);
  canvas.addEventListener('pointercancel', onPointerUp);
  canvas.addEventListener('keydown', onStageKeyDown);

  /* --- masthead Reset --- */
  document.addEventListener('sim-reset', resetSim);

  window.addEventListener('resize', sizeCanvas);
  if (window.ResizeObserver) {
    new ResizeObserver(sizeCanvas).observe(canvas);
  }

  requestRender();
}

/* SHORE_DATA: GlobeComponent.as p._shoreData -- the coastline polygons,
   copied verbatim as unit vectors in the globe's own frame. */
var SHORE_DATA = [[{x:-0.3346,y:0.0459,z:0.9413},{x:-0.3416,y:0.0996,z:0.9346},{x:-0.2114,y:0.2266,z:0.9508},{x:-0.096,y:0.2606,z:0.9607},{x:-0.0754,y:0.2221,z:0.9721},{x:0.1858,y:0.3188,z:0.9294},{x:0.2601,y:0.2689,z:0.9274},{x:0.3333,y:0.1093,z:0.9365},{x:0.5148,y:0.0304,z:0.8568},{x:0.5205,y:0.0699,z:0.851},{x:0.4949,y:0.0935,z:0.8639},{x:0.5415,y:0.1316,z:0.8304},{x:0.4746,y:0.1559,z:0.8663},{x:0.4533,y:0.1428,z:0.8798},{x:0.3811,y:0.182,z:0.9064},{x:0.5518,y:0.1955,z:0.8107},{x:0.5657,y:0.1123,z:0.8169},{x:0.5325,y:0.0913,z:0.8415},{x:0.5788,y:0.0726,z:0.8123},{x:0.6521,y:0.0005,z:0.7582},{x:0.6599,y:-0.0552,z:0.7494},{x:0.6902,y:-0.0128,z:0.7235},{x:0.7263,y:-0.0199,z:0.6871},{x:0.7223,y:-0.1168,z:0.6817},{x:0.7875,y:-0.1261,z:0.6033},{x:0.8049,y:-0.079,z:0.5882},{x:0.7916,y:-0.0099,z:0.611},{x:0.7267,y:0.0424,z:0.6856},{x:0.7059,y:0.1082,z:0.7},{x:0.7406,y:0.2044,z:0.6401},{x:0.761,y:0.2109,z:0.6135},{x:0.7249,y:0.2418,z:0.645},{x:0.7003,y:0.1548,z:0.6969},{x:0.6782,y:0.1634,z:0.7165},{x:0.701,y:0.2505,z:0.6677},{x:0.7398,y:0.316,z:0.5939},{x:0.7024,y:0.2932,z:0.6486},{x:0.6614,y:0.3481,z:0.6644},{x:0.5977,y:0.3465,z:0.723},{x:0.5499,y:0.4863,z:0.679},{x:0.6837,y:0.3491,z:0.6408},{x:0.7121,y:0.3693,z:0.5971},{x:0.6462,y:0.4721,z:0.5996},{x:0.7063,y:0.479,z:0.5213},{x:0.7515,y:0.4162,z:0.5118},{x:0.7804,y:0.3107,z:0.5427},{x:0.816,y:0.2808,z:0.5053},{x:0.8186,y:0.1474,z:0.5552},{x:0.7832,y:0.1514,z:0.6031},{x:0.8072,y:-0.0792,z:0.5849},{x:0.8913,y:-0.2764,z:0.3594},{x:0.9222,y:-0.2913,z:0.2545},{x:0.968,y:-0.2156,z:0.1285},{x:0.996,y:-0.0345,z:0.0829},{x:0.991,y:0.0669,z:0.116},{x:0.9841,y:0.1734,z:0.0387},{x:0.9529,y:0.2358,z:-0.191},{x:0.9216,y:0.199,z:-0.3334},{x:0.7843,y:0.2596,z:-0.5635},{x:0.7424,y:0.3784,z:-0.5528},{x:0.7432,y:0.53,z:-0.4084},{x:0.7742,y:0.5361,z:-0.3363},{x:0.7322,y:0.6312,z:-0.2559},{x:0.7731,y:0.629,z:-0.0816},{x:0.6711,y:0.7371,z:0.0794},{x:0.6185,y:0.7582,z:0.2064},{x:0.7094,y:0.6835,z:0.172},{x:0.7425,y:0.6167,z:0.2616},{x:0.7323,y:0.4634,z:0.499},{x:0.7047,y:0.6485,z:0.288},{x:0.709,y:0.6702,z:0.2195},{x:0.547,y:0.7839,z:0.2936},{x:0.4669,y:0.7999,z:0.3771},{x:0.5075,y:0.7499,z:0.4244},{x:0.5708,y:0.7106,z:0.4113},{x:0.5873,y:0.6439,z:0.4903},{x:0.5637,y:0.6524,z:0.5065},{x:0.4562,y:0.7854,z:0.4183},{x:0.285,y:0.8918,z:0.3513},{x:0.2137,y:0.9667,z:0.1405},{x:0.1742,y:0.9683,z:0.179},{x:0.1617,y:0.9492,z:0.2701},{x:-0.0245,y:0.9218,z:0.3868},{x:-0.0724,y:0.9584,z:0.276},{x:-0.1291,y:0.9498,z:0.2851},{x:-0.1512,y:0.9825,z:0.1087},{x:-0.2453,y:0.9692,z:0.024},{x:-0.2253,y:0.9697,z:0.0943},{x:-0.162,y:0.9742,z:0.1569},{x:-0.1693,y:0.9583,z:0.2302},{x:-0.2604,y:0.9534,z:0.1521},{x:-0.324,y:0.9204,z:0.2189},{x:-0.2558,y:0.9105,z:0.3249},{x:-0.4007,y:0.8273,z:0.3937},{x:-0.461,y:0.7336,z:0.4994},{x:-0.4007,y:0.7145,z:0.5736},{x:-0.428,y:0.6691,z:0.6076},{x:-0.385,y:0.6794,z:0.6247},{x:-0.4476,y:0.6263,z:0.6383},{x:-0.4855,y:0.663,z:0.5698},{x:-0.5161,y:0.6355,z:0.5743},{x:-0.4692,y:0.6094,z:0.6391},{x:-0.5192,y:0.5174,z:0.6803},{x:-0.5026,y:0.4055,z:0.7635},{x:-0.4193,y:0.3708,z:0.8287},{x:-0.4622,y:0.1663,z:0.871},{x:-0.5025,y:0.2226,z:0.8355},{x:-0.5765,y:0.2476,z:0.7787},{x:-0.5338,y:0.1583,z:0.8306},{x:-0.4863,y:0.1283,z:0.8643},{x:-0.4672,y:0.0074,z:0.8841},{x:-0.418,y:0.0021,z:0.9084},{x:-0.4004,y:-0.072,z:0.9135}],[{x:0.206,y:-0.5678,z:-0.797},{x:0.3392,y:-0.6758,z:-0.6544},{x:0.5784,y:-0.6598,z:-0.4797},{x:0.5974,y:-0.6792,z:-0.4264},{x:0.6996,y:-0.6096,z:-0.3727},{x:0.7597,y:-0.612,z:-0.22},{x:0.8105,y:-0.5663,z:-0.1498},{x:0.8141,y:-0.5728,z:-0.0954},{x:0.6662,y:-0.7455,z:0.0175},{x:0.6302,y:-0.767,z:0.1205},{x:0.3556,y:-0.9081,z:0.2212},{x:0.2267,y:-0.9645,z:0.1355},{x:0.1876,y:-0.9681,z:0.1662},{x:0.1322,y:-0.9786,z:0.1575},{x:0.1114,y:-0.9592,z:0.2597},{x:0.0201,y:-0.9619,z:0.2728},{x:0.0499,y:-0.9301,z:0.3639},{x:-0.0045,y:-0.9324,z:0.3614},{x:-0.0268,y:-0.9479,z:0.3173},{x:-0.1023,y:-0.9327,z:0.3458},{x:-0.125,y:-0.8816,z:0.4551},{x:-0.0824,y:-0.8601,z:0.5034},{x:0.0953,y:-0.8597,z:0.5018},{x:0.1497,y:-0.8938,z:0.4228},{x:0.1263,y:-0.8453,z:0.5192},{x:0.1937,y:-0.7964,z:0.5729},{x:0.2105,y:-0.7227,z:0.6583},{x:0.2559,y:-0.7013,z:0.6653},{x:0.2381,y:-0.6877,z:0.6859},{x:0.2978,y:-0.6315,z:0.7159},{x:0.3001,y:-0.6601,z:0.6886},{x:0.3373,y:-0.6187,z:0.7096},{x:0.2658,y:-0.6144,z:0.7428},{x:0.2193,y:-0.6474,z:0.7299},{x:0.2561,y:-0.5848,z:0.7697},{x:0.3205,y:-0.5532,z:0.7689},{x:0.3322,y:-0.4862,z:0.8082},{x:0.284,y:-0.4991,z:0.8187},{x:0.2136,y:-0.4479,z:0.8682},{x:0.195,y:-0.4938,z:0.8474},{x:0.1718,y:-0.4534,z:0.8746},{x:0.0976,y:-0.4563,z:0.8845},{x:0.1089,y:-0.6066,z:0.7875},{x:0.0729,y:-0.5727,z:0.8165},{x:-0.0263,y:-0.5471,z:0.8366},{x:-0.0364,y:-0.4856,z:0.8734},{x:0.0594,y:-0.3827,z:0.922},{x:0.052,y:-0.3518,z:0.9346},{x:0.0091,y:-0.376,z:0.9266},{x:-0.0262,y:-0.3095,z:0.9505},{x:-0.0904,y:-0.365,z:0.9266},{x:-0.2194,y:-0.2788,z:0.9349},{x:-0.2931,y:-0.1264,z:0.9477},{x:-0.3515,y:-0.0852,z:0.9323},{x:-0.3753,y:-0.1338,z:0.9172},{x:-0.407,y:-0.0856,z:0.9094},{x:-0.406,y:-0.1419,z:0.9028},{x:-0.4614,y:-0.1161,z:0.8795},{x:-0.4954,y:-0.1572,z:0.8543},{x:-0.4735,y:-0.2013,z:0.8575},{x:-0.5529,y:-0.168,z:0.8162},{x:-0.4737,y:-0.2264,z:0.8511},{x:-0.4053,y:-0.2586,z:0.8768},{x:-0.3598,y:-0.3663,z:0.8581},{x:-0.3688,y:-0.5542,z:0.7462},{x:-0.433,y:-0.6465,z:0.6282},{x:-0.3806,y:-0.7794,z:0.4977},{x:-0.3212,y:-0.8604,z:0.3956},{x:-0.3576,y:-0.7715,z:0.5262},{x:-0.2197,y:-0.924,z:0.313},{x:0.0463,y:-0.9711,z:0.2343},{x:0.1108,y:-0.9829,z:0.1468},{x:0.1636,y:-0.9786,z:0.125},{x:0.1918,y:-0.9704,z:0.147},{x:0.2199,y:-0.9734,z:0.0637},{x:0.1579,y:-0.9849,z:-0.0705},{x:0.2319,y:-0.939,z:-0.254},{x:0.3228,y:-0.8834,z:-0.3398},{x:0.2626,y:-0.7902,z:-0.5538},{x:0.2245,y:-0.7628,z:-0.6064},{x:0.1743,y:-0.5802,z:-0.7956}],[{x:0.2884,y:-0.169,z:0.9425},{x:0.258,y:-0.135,z:0.9567},{x:0.2665,y:-0.0991,z:0.9587},{x:0.1582,y:-0.0467,z:0.9863},{x:0.0767,y:-0.1085,z:0.9911},{x:0.0709,y:-0.1896,z:0.9793},{x:0.2796,y:-0.3484,z:0.8947},{x:0.3541,y:-0.3522,z:0.8663}],[{x:-0.6199,y:0.4769,z:-0.6232},{x:-0.7027,y:0.3948,z:-0.5919},{x:-0.8027,y:0.4056,z:-0.4373},{x:-0.7799,y:0.5977,z:-0.1855},{x:-0.7366,y:0.6049,z:-0.3026},{x:-0.6881,y:0.6783,z:-0.2577},{x:-0.7106,y:0.6728,z:-0.2059},{x:-0.6562,y:0.7295,z:-0.193},{x:-0.6152,y:0.7435,z:-0.2623},{x:-0.5707,y:0.7852,z:-0.2406},{x:-0.487,y:0.8068,z:-0.3345},{x:-0.3773,y:0.8479,z:-0.3725},{x:-0.3439,y:0.7982,z:-0.4946},{x:-0.4027,y:0.7092,z:-0.5787},{x:-0.5375,y:0.6569,z:-0.5288},{x:-0.616,y:0.5528,z:-0.5612}],[{x:0.195,y:-0.4301,z:0.8815},{x:0.1489,y:-0.3678,z:0.9179},{x:0.1884,y:-0.3839,z:0.9039},{x:0.1903,y:-0.3474,z:0.9182},{x:0.0234,y:-0.286,z:0.9579},{x:0.0282,y:-0.3259,z:0.945},{x:0.1146,y:-0.3675,z:0.9229},{x:0.1043,y:-0.411,z:0.9056}],[{x:0.3616,y:0.0008,z:-0.9323},{x:0.2757,y:-0.095,z:-0.9565},{x:0.1623,y:-0.1217,z:-0.9792},{x:0.1207,y:-0.2253,z:-0.9668},{x:0.2426,y:-0.377,z:-0.8939},{x:0.0849,y:-0.3383,z:-0.9372},{x:0.0888,y:-0.2744,z:-0.9575},{x:-0.0569,y:-0.3062,z:-0.9503},{x:-0.1779,y:-0.2219,z:-0.9587},{x:-0.2086,y:0.0366,z:-0.9773},{x:-0.3158,y:0.0556,z:-0.9472},{x:-0.2925,y:0.2905,z:-0.9111},{x:-0.0938,y:0.4102,z:-0.9072},{x:0.056,y:0.4063,z:-0.912},{x:0.0955,y:0.3336,z:-0.9379},{x:0.2419,y:0.3294,z:-0.9127},{x:0.3116,y:0.1986,z:-0.9292},{x:0.3043,y:0.1373,z:-0.9426}],[{x:-0.8538,y:0.5009,z:-0.1421},{x:-0.7416,y:0.6703,z:-0.0256},{x:-0.709,y:0.7032,z:-0.0528},{x:-0.6683,y:0.7438,z:-0.0045},{x:-0.6686,y:0.741,z:-0.0628},{x:-0.74,y:0.6658,z:-0.0956},{x:-0.7476,y:0.6484,z:-0.1438},{x:-0.7854,y:0.5973,z:-0.1622},{x:-0.8088,y:0.5738,z:-0.129}],[{x:0.412,y:-0.5346,z:0.7379},{x:0.3479,y:-0.5141,z:0.784},{x:0.3439,y:-0.5681,z:0.7477},{x:0.3846,y:-0.5658,z:0.7293}],[{x:-0.476,y:0.8794,z:0.0094},{x:-0.4487,y:0.8918,z:0.0578},{x:-0.4865,y:0.8683,z:0.0968},{x:-0.4544,y:0.8824,z:0.1219},{x:-0.3257,y:0.9452,z:0.0238},{x:-0.3543,y:0.9338,z:-0.0508},{x:-0.4199,y:0.9043,z:-0.0771}],[{x:0.6229,y:-0.0015,z:0.7823},{x:0.5351,y:-0.0161,z:0.8447},{x:0.5191,y:-0.045,z:0.8535},{x:0.5664,y:-0.054,z:0.8224},{x:0.6044,y:-0.0332,z:0.796},{x:0.6377,y:-0.0634,z:0.7677}],[{x:-0.6002,y:0.5602,z:0.5709},{x:-0.63,y:0.5126,z:0.5834},{x:-0.5865,y:0.4671,z:0.6617},{x:-0.5851,y:0.5637,z:0.583},{x:-0.5406,y:0.6248,z:0.5634},{x:-0.5876,y:0.603,z:0.5395}],[{x:0.617,y:0.664,z:-0.4225},{x:0.6136,y:0.7434,z:-0.2664},{x:0.6383,y:0.7414,z:-0.2071},{x:0.6869,y:0.6617,z:-0.3006},{x:0.6624,y:0.6263,z:-0.4111}],[{x:-0.5157,y:0.8519,z:-0.0911},{x:-0.5141,y:0.857,z:-0.0346},{x:-0.5742,y:0.8181,z:0.0314},{x:-0.5062,y:0.8623,z:0.0162},{x:-0.4805,y:0.8757,z:-0.0484}],[{x:0.4193,y:-0.1148,z:0.9006},{x:0.3867,y:-0.0987,z:0.9169},{x:0.3781,y:-0.1507,z:0.9134},{x:0.4088,y:-0.1714,z:0.8964}],[{x:0.6119,y:-0.0864,z:0.7862},{x:0.5713,y:-0.0666,z:0.818},{x:0.5764,y:-0.1031,z:0.8107},{x:0.605,y:-0.1146,z:0.7879}],[{x:-0.7522,y:0.0451,z:-0.6574},{x:-0.8171,y:0.0431,z:-0.5749},{x:-0.8274,y:0.0859,z:-0.555},{x:-0.7623,y:0.0812,z:-0.6421}],[{x:-0.2696,y:0.958,z:-0.0974},{x:-0.2767,y:0.9593,z:-0.0563},{x:-0.2353,y:0.9719,z:0.0031},{x:-0.0907,y:0.9911,z:0.0973}],[{x:0.2428,y:-0.9068,z:0.3446},{x:0.1414,y:-0.9078,z:0.3949},{x:0.0949,y:-0.9173,z:0.3867},{x:0.1925,y:-0.9144,z:0.3562},{x:0.2009,y:-0.9193,z:0.3384}],[{x:0.0223,y:-0.7332,z:0.6796},{x:0.0589,y:-0.6836,z:0.7275},{x:-0.0229,y:-0.6822,z:0.7308},{x:0.0178,y:-0.6568,z:0.7539},{x:0.1038,y:-0.6978,z:0.7087},{x:0.0942,y:-0.7242,z:0.6831},{x:0.0629,y:-0.698,z:0.7134},{x:0.0448,y:-0.7453,z:0.6652}],[{x:0.4824,y:0.5331,z:0.6951},{x:0.4116,y:0.5444,z:0.7309},{x:0.4499,y:0.5682,z:0.689},{x:0.4702,y:0.6478,z:0.5994},{x:0.521,y:0.5986,z:0.6085}],[{x:0.3431,y:-0.8806,z:0.3269},{x:0.2745,y:-0.8987,z:0.3421},{x:0.2662,y:-0.9088,z:0.3212},{x:0.3042,y:-0.8984,z:0.3167}],[{x:-0.5955,y:0.4446,z:0.6691},{x:-0.6012,y:0.4083,z:0.6869},{x:-0.5515,y:0.4322,z:0.7135},{x:-0.5679,y:0.4685,z:0.6767},{x:-0.5955,y:0.4446,z:0.6691},{x:-0.5955,y:0.4446,z:0.6691}]];

loadArt().then(function () {
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', boot);
  } else {
    boot();
  }
});

})();
