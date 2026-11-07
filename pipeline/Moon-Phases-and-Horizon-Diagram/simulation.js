/* ============================================================================
 * Moon Phases and the Horizon Demonstrator  --  accessible HTML5 port
 * ----------------------------------------------------------------------------
 * Behaviour is ported faithfully from the decompiled Flash ActionScript (AS1):
 *   - CelestialSphere.as + "2..11 CS *.as"  (the 3D projection engine)
 *   - Moon Positions Demonstrator.as         (the controller)
 *   - Moon Disc.as / Sun Disc.as / drawPhaseDisc Function.as / ShadowMaker.as
 * All geometry runs in the ORIGINAL Flash stage coordinate system (sphere of
 * radius r = 160, centred at the canvas origin). CSS scales the canvas.
 *
 * Single source of truth: the `state` object. One render() redraws the canvas,
 * syncs the DOM readouts, and updates the screen-reader description.
 * ==========================================================================*/

'use strict';

/* -------------------------------------------------------------------------
 * Constants (verbatim from the AS source)
 * ---------------------------------------------------------------------- */
const DEG     = 0.017453292519943295;   // pi/180
const RAD2DEG = 57.29577951308232;       // 180/pi
const HR2RAD  = 0.2617993877991494;      // 2*pi/24
const RAD2HR  = 3.819718634205488;       // 24/(2*pi)
const TWO_PI  = 6.283185307179586;
const HALF_PI = 1.5707963267948966;

const SPHERE_R = 160;                    // sphere.size = 320 -> r = 160
const CANVAS   = 400;                    // internal backing size (px)
const CX = CANVAS / 2, CY = CANVAS / 2;  // sphere centre on canvas

// Initial view (CelestialSphere ctor setThetaAndPhi(90,30) then
// viewerAzimuth = 200 -> theta = 360-200 = 160; phi = 30; minViewerAltitude=7)
const INIT = {
  viewerAzimuth: 200,   // deg  -> theta = 360 - az
  phiDeg:        30,    // deg  (viewer altitude)
  minPhi:        7,     // deg
  maxPhi:        90,    // deg
  latitude:      41,    // deg
  siderealTime:  0,     // hours
  sunPos:        4,
  moonPos:       2
};

function mod(n, m) { return ((n % m) + m) % m; }

/* -------------------------------------------------------------------------
 * Colours (AS decimal RGB -> hex)  -- reused as-is from the exported art / AS
 * ---------------------------------------------------------------------- */
const COL = {
  meridian:      '#e0e0e0',   // 14737632, alpha 70
  equator:       '#e8d898',   // 15259800, alpha 100
  axis:          '#2174fe',   //  2192638, alpha 100
  bandBorder:    '#b0b0b0',   // 11579568, alpha 50
  horizonInner:  '#51c451',   // shape 69 radial gradient inner
  horizonOuter:  '#3aa53a',   // shape 69 radial gradient outer
  sunInner:      '#ffcc00',   // shape 88
  sunOuter:      '#edb101',
  sunLineNormal: '#999999',   // shape 89
  sunLineOver:   '#000000',   // shape 90
  dot:           '#d11818',   // shape 93 (red cross / Position Dot)
  moonDark:      '#909090',   //  9474192
  moonLight:     '#d0d0d0',   // 13684944
  moonSolid:     '#a8a8a8',   // 11053224
  moonLine:      '#808080',   //  8421504
  discDark:      '#909090',   // panel phase disc darkColor 9474192
  discLight:     '#d0d0d0',   // panel phase disc lightColor 13684944
  label:         '#333333',
  dirLabel:      '#333333'
};

const PHASE_NAMES = ['New Moon', 'Waxing Crescent', 'First Quarter', 'Waxing Gibbous',
                     'Full Moon', 'Waning Gibbous', 'Third Quarter', 'Waning Crescent'];

/* =========================================================================
 * STATE  (the single source of truth)
 * ======================================================================= */
const state = {
  theta: DEG * mod(360 - INIT.viewerAzimuth, 360),   // rad
  phi:   DEG * INIT.phiDeg,                           // rad
  lat:   DEG * INIT.latitude,                         // rad
  sTime: mod(INIT.siderealTime, 24) * HR2RAD,         // rad
  sunPos:  INIT.sunPos,     // 1..8 (continuous while dragging)
  moonPos: INIT.moonPos,
  show: {
    positionLabels: false,
    eclipticBand:   false,
    sun:            true,
    time:           true,
    moon:           true,
    phase:          true,
    phaseOnDisc:    false
  },
  hover: { sun: false, moon: false }   // outline highlight while dragging
};

/* =========================================================================
 * CAMERA / PROJECTION MATRICES  (doA, doM, doB ports)
 * ======================================================================= */
const cam = { r: SPHERE_R, r2: SPHERE_R * SPHERE_R, a: {}, m: {}, b: {} };

function doA() {
  const ct = Math.cos(state.theta), st = Math.sin(state.theta);
  const cp = Math.cos(state.phi),   sp = Math.sin(state.phi);
  const r = cam.r, a = cam.a;
  a.a0 = -r * st;      a.a1 = r * ct;
  a.a3 = r * ct * sp;  a.a4 = r * st * sp;  a.a5 = -r * cp;
  a.a6 = r * ct * cp;  a.a7 = r * st * cp;  a.a8 = r * sp;
}
function doM() {
  const m = cam.m;
  m.m2 = Math.cos(state.lat);
  m.m3 = Math.sin(state.sTime);
  m.m4 = -Math.cos(state.sTime);
  m.m8 = Math.sin(state.lat);
  m.m0 = m.m4 * m.m8;   m.m1 = -m.m3 * m.m8;
  m.m6 = -m.m2 * m.m4;  m.m7 = m.m2 * m.m3;
}
function doB() {
  const a = cam.a, m = cam.m, b = cam.b;
  b.b0 = a.a0 * m.m0 + a.a1 * m.m3;
  b.b1 = a.a0 * m.m1 + a.a1 * m.m4;
  b.b2 = a.a0 * m.m2;
  b.b3 = a.a3 * m.m0 + a.a4 * m.m3 + a.a5 * m.m6;
  b.b4 = a.a3 * m.m1 + a.a4 * m.m4 + a.a5 * m.m7;
  b.b5 = a.a3 * m.m2 + a.a5 * m.m8;
  b.b6 = a.a6 * m.m0 + a.a7 * m.m3 + a.a8 * m.m6;
  b.b7 = a.a6 * m.m1 + a.a7 * m.m4 + a.a8 * m.m7;
  b.b8 = a.a6 * m.m2 + a.a8 * m.m8;
}
function updateMatrices() { doA(); doM(); doB(); }

// World (horizon) xyz -> screen xyz
function WtoSz(p) {
  const a = cam.a;
  return {
    x: p.x * a.a0 + p.y * a.a1,
    y: p.x * a.a3 + p.y * a.a4 + p.z * a.a5,
    z: p.x * a.a6 + p.y * a.a7 + p.z * a.a8
  };
}
// Celestial xyz -> screen xyz
function CtoSz(p) {
  const b = cam.b;
  return {
    x: p.x * b.b0 + p.y * b.b1 + p.z * b.b2,
    y: p.x * b.b3 + p.y * b.b4 + p.z * b.b5,
    z: p.x * b.b6 + p.y * b.b7 + p.z * b.b8
  };
}
// Celestial xyz -> world (horizon) xyz
function CtoW(p) {
  const m = cam.m;
  return {
    x: p.x * m.m0 + p.y * m.m1 + p.z * m.m2,
    y: p.x * m.m3 + p.y * m.m4,
    z: p.x * m.m6 + p.y * m.m7 + p.z * m.m8
  };
}
// World -> celestial (m is orthonormal: transpose)
function WtoC(p) {
  const m = cam.m;
  return {
    x: p.x * m.m0 + p.y * m.m3 + p.z * m.m6,
    y: p.x * m.m1 + p.y * m.m4 + p.z * m.m7,
    z: p.x * m.m2 + p.z * m.m8
  };
}

// Build a unit xyz from az/alt (deg) [horizon] or ra(hr)/dec(deg) [celestial]
function fromHorizon(az, alt, r) {
  r = (r === undefined) ? 1 : r;
  const d = r * Math.cos(alt * DEG);
  return { x: d * Math.cos(az * DEG), y: d * Math.sin(-az * DEG),
           z: r * Math.sin(alt * DEG), r: Math.abs(r) };
}
function fromCelestial(ra, dec, r) {
  r = (r === undefined) ? 1 : r;
  const d = r * Math.cos(dec * DEG);
  return { x: d * Math.cos(ra * HR2RAD), y: d * Math.sin(ra * HR2RAD),
           z: r * Math.sin(dec * DEG), r: Math.abs(r) };
}

// Screen point -> "math horizon" {az,alt} in RADIANS (StoMH port)
function StoMH(sx, sy) {
  let d = Math.sqrt(sx * sx + sy * sy) / cam.r;
  if (d > 1) d = 1;
  const b = Math.asin(d);
  const A = Math.atan2(sx, -sy);
  const phi = state.phi;
  let alt, az;
  if (phi === HALF_PI) {
    alt = HALF_PI - b;  az = state.theta + Math.PI - A;
  } else if (phi === -HALF_PI) {
    alt = -HALF_PI + b; az = state.theta + A;
  } else {
    const c = HALF_PI - phi, cc = Math.cos(c), sc = Math.sin(c);
    const cb = Math.cos(b), sb = Math.sin(b);
    const ca = cb * cc + sb * sc * Math.cos(A);
    alt = HALF_PI - Math.acos(ca);
    az  = state.theta + Math.atan2(sb * Math.sin(A), (cb - ca * cc) / sc);
  }
  return { az: mod(az, TWO_PI), alt: alt };
}
// math-horizon (rad) -> celestial (MHtoC port); returns ra(rad),dec(rad)
function MHtoC(az, alt) {
  const salt = Math.sin(alt), calt = Math.cos(alt);
  const saz = Math.sin(az), caz = Math.cos(az);
  const sl = Math.sin(state.lat), cl = Math.cos(state.lat);
  const sh = calt * saz;
  const ch = salt * cl - calt * sl * caz;
  const ra = (ch === 0) ? 0 : mod(state.sTime - Math.atan2(sh, ch), TWO_PI);
  const dec = Math.asin(salt * sl + calt * caz * cl);
  return { ra: ra, dec: dec };
}
// screen -> celestial, ra in HOURS, dec in DEG (screenToCelestial port)
function screenToCelestial(sx, sy) {
  const h = StoMH(sx, sy);
  const c = MHtoC(h.az, h.alt);
  return { ra: c.ra * RAD2HR, dec: c.dec * RAD2DEG };
}

/* =========================================================================
 * GREAT/SMALL CIRCLES  (8 CS Circles port)  -- all our circles are celestial
 * ======================================================================= */

function makeCircle(color, alpha, thickness, tiltDeg, raHr, decDeg) {
  const c = { color, alpha, thickness };
  const tilt = tiltDeg * DEG;
  const beta = HR2RAD * mod(raHr, 24);
  const lambda = decDeg * DEG;
  const st = Math.sin(tilt), ct = Math.cos(tilt);
  const sb = Math.sin(beta), cb = Math.cos(beta);
  const cl = Math.cos(lambda), sl = Math.sin(lambda);
  c.w = {
    w0: cl * cb, w1: -cl * sb * ct, w2: sl * sb * st,
    w3: cl * sb, w4: cl * cb * ct,  w5: -sl * cb * st,
    w7: cl * st, w8: sl * ct
  };
  return c;
}

// Returns {front:[segments], back:[segments]} where each segment is a polyline
// of screen points. gS==gE (full circle) so we split at the horizon crossing.
function projectCircle(c) {
  const b = cam.b, w = c.w;
  const v0 = b.b0 * w.w0 + b.b1 * w.w3;
  const v1 = b.b0 * w.w1 + b.b1 * w.w4 + b.b2 * w.w7;
  const v2 = b.b0 * w.w2 + b.b1 * w.w5 + b.b2 * w.w8;
  const v3 = b.b3 * w.w0 + b.b4 * w.w3;
  const v4 = b.b3 * w.w1 + b.b4 * w.w4 + b.b5 * w.w7;
  const v5 = b.b3 * w.w2 + b.b4 * w.w5 + b.b5 * w.w8;
  const v6 = b.b6 * w.w0 + b.b7 * w.w3;
  const v7 = b.b6 * w.w1 + b.b7 * w.w4 + b.b8 * w.w7;
  const v8 = b.b6 * w.w2 + b.b7 * w.w5 + b.b8 * w.w8;

  const out = { front: [], back: [] };
  const arc = (g1, g2) => sampleArc(v0, v1, v2, v3, v4, v5, g1, g2);

  const A = Math.sqrt(v6 * v6 + v7 * v7);
  if (A === 0) {
    (v8 < 0 ? out.back : out.front).push(arc(0, 0));
    return out;
  }
  const sj = -v8 / A;
  if (sj <= -1) { out.front.push(arc(0, 0)); return out; }
  if (sj >= 1)  { out.back.push(arc(0, 0));  return out; }

  const j = Math.asin(sj);
  const t = Math.atan2(v6, v7);
  let gDesc, gAsc;
  if (Math.cos(j) < 0) { gDesc = mod(j - t, TWO_PI);          gAsc = mod(Math.PI - j - t, TWO_PI); }
  else                 { gDesc = mod(Math.PI - j - t, TWO_PI); gAsc = mod(j - t, TWO_PI); }
  out.front.push(arc(gAsc, gDesc));
  out.back.push(arc(gDesc, gAsc));
  return out;
}

// Fine tessellation step: the projection of a circle is an ellipse, so we
// sample densely (~2 degrees) and connect with straight segments -> visually
// smooth. (The AS drawArc used quadratic curveTo at pi/4 steps; dense line
// sampling is equivalent on screen and simpler.)
const ARC_STEP = Math.PI / 90; // 2 degrees

// Tessellate one arc (g1->g2) into an array of screen points {x,y} (centre added)
function sampleArc(v0, v1, v2, v3, v4, v5, g1, g2) {
  if (g2 < g1) g2 += TWO_PI;
  let arc = g2 - g1;
  if (arc === 0) arc = TWO_PI;
  const n = Math.max(2, Math.ceil(arc / ARC_STEP));
  const step = arc / n;
  const pts = [];
  for (let i = 0; i <= n; i++) {
    const g = g1 + step * i;
    const cg = Math.cos(g), sg = Math.sin(g);
    pts.push({ x: CX + v0 * cg + v1 * sg + v2, y: CY + v3 * cg + v4 * sg + v5 });
  }
  return pts;
}

function strokePolyline(ctx, pts, color, alpha, thickness) {
  if (!pts || pts.length < 2) return;
  ctx.save();
  ctx.globalAlpha = alpha / 100;
  ctx.strokeStyle = color;
  ctx.lineWidth = Math.max(thickness, 1);
  ctx.lineJoin = 'round';
  ctx.lineCap = 'round';
  ctx.beginPath();
  ctx.moveTo(pts[0].x, pts[0].y);
  for (let i = 1; i < pts.length; i++) ctx.lineTo(pts[i].x, pts[i].y);
  ctx.stroke();
  ctx.restore();
}

/* =========================================================================
 * LINES  (9 CS Lines port, showUnder = true branch)
 * Returns segments tagged with layer: 'bE' | 'fE' | 'aI' | 'bI'
 * head/tail are celestial xyz; projected to screen first.
 * ======================================================================= */
function computeLineSegments(headC, tailC) {
  const head = CtoSz(headC), tail = CtoSz(tailC);
  const mx = head.x - tail.x, my = head.y - tail.y, mz = head.z - tail.z;
  const A = mx * mx + my * my + mz * mz;
  const B = 2 * (mx * tail.x + my * tail.y + mz * tail.z);
  const C = tail.x * tail.x + tail.y * tail.y + tail.z * tail.z;
  const rad2 = cam.r2, phi = state.phi;
  const stmp = [];
  const D = B * B - 4 * A * (C - rad2);
  if (D > 0) { const sD = Math.sqrt(D); stmp.push((-B + sD) / (2 * A), (-B - sD) / (2 * A)); }

  let tp = null;
  const nearTop = Math.abs(phi) >= HALF_PI - 1e-9;
  if (!nearTop) {
    tp = Math.tan(phi);
    if (my !== tp * mz) stmp.push((tp * tail.z - tail.y) / (my - tp * mz));
    if (mz !== 0) { const tmp = -tail.z / mz; if (tmp * (tmp * A + B) + C >= rad2) stmp.push(tmp); }
  } else if (mz !== 0) {
    stmp.push(-tail.z / mz);
  }

  const s = [0, 1];
  for (let i = 0; i < stmp.length; i++) {
    const v = stmp[i];
    if (v > 0 && v < 1) {
      let k = 1; while (v > s[k]) k++;
      if (v !== s[k]) s.splice(k, 0, v);
    }
  }

  const segs = [];
  for (let i = 0; i < s.length - 1; i++) {
    const s1 = s[i], s2 = s[i + 1], mid = s1 + (s2 - s1) / 2;
    const r2 = mid * (mid * A + B) + C;
    let layer;
    if (r2 < rad2) {                                 // inside the sphere disc
      if (nearTop) layer = 'aI';
      else layer = (mid * my + tail.y - (mid * mz + tail.z) * tp > 1e-9) ? 'bI' : 'aI';
    } else {                                         // outside -> external
      layer = (mid * mz + tail.z < 0) ? 'bE' : 'fE';
    }
    segs.push({
      x1: CX + s1 * mx + tail.x, y1: CY + s1 * my + tail.y,
      x2: CX + s2 * mx + tail.x, y2: CY + s2 * my + tail.y,
      layer
    });
  }
  return segs;
}

/* =========================================================================
 * OBJECTS  (7 CS Objects: position + orientation + foreshortening)
 * ======================================================================= */
// Normalise a vector
function norm(v) { const m = Math.hypot(v.x, v.y, v.z) || 1; return { x: v.x / m, y: v.y / m, z: v.z / m }; }

// Default "absolute" orientation basis (n = radial, u perpendicular-up)
function absoluteBasisDefault(p) {
  const n = norm(p);
  let u;
  if (!(n.x === 0 && n.y === 0)) {
    u = norm({ x: -n.x * n.z, y: -n.z * n.y, z: n.x * n.x + n.y * n.y });
  } else {
    u = { x: 0, y: 1, z: 0 };
  }
  return { n, u };
}
// "absolute" orientation from explicit normal-vector and up-vector (already same system)
function absoluteBasisFrom(normalVec, upVec) {
  const n = norm(normalVec);
  const ax = upVec.x, ay = upVec.y, az = upVec.z, nx = n.x, ny = n.y, nz = n.z;
  const ux = ny * ny * ax - nx * ny * ay - nx * nz * az + nz * nz * ax;
  const uy = nz * nz * ay - ny * nz * az - nx * ny * ax + nx * nx * ay;
  const uz = nx * nx * az - nx * nz * ax - ny * nz * ay + ny * ny * az;
  const un = Math.hypot(ux, uy, uz) || 1;
  return { n, u: { x: ux / un, y: uy / un, z: uz / un } };
}

// Compute screen transform for an object. sys: 0 horizon(a), 1 celestial(b).
// Returns {sp, yscale, shellRot(rad), instRot(rad)} ; oType: 'flat' | 'absolute'
function objectTransform(p, sys, oType, basis) {
  const proj = (sys === 0) ? WtoSz : CtoSz;
  const sp = proj(p);
  const cc = (sys === 0) ? cam.a : cam.b;
  const c6 = (sys === 0) ? cc.a6 : cc.b6;
  const c7 = (sys === 0) ? cc.a7 : cc.b7;
  const c8 = (sys === 0) ? cc.a8 : cc.b8;

  if (oType === 'flat') {
    return { sp, yscale: 100, shellRot: 0, instRot: 0 };
  }
  // absolute
  const n = basis.n, u = basis.u;
  const p_n = { x: p.x + n.x, y: p.y + n.y, z: p.z + n.z };
  const p_u = { x: p.x + u.x, y: p.y + u.y, z: p.z + u.z };
  const npz = (n.x * c6 + n.y * c7 + n.z * c8) / cam.r;
  const sp_n = proj(p_n), sp_u = proj(p_u);
  const yscale = 100 * npz;
  const Aang = Math.atan2(sp_n.y - sp.y, sp_n.x - sp.x) + HALF_PI;
  const shellRot = Aang;
  const cA = Math.cos(Aang), sA = Math.sin(Aang);
  const x0 = sp_u.x - sp.x, y0 = sp_u.y - sp.y;
  const x1 = cA * x0 + sA * y0, y1 = -sA * x0 + cA * y0;
  const x2 = x1, y2 = y1 / npz;
  const instRot = Math.atan2(y2, x2) + HALF_PI;
  return { sp, yscale, shellRot, instRot };
}

/* Apply an object transform then invoke drawFn(ctx) drawing in local coords. */
function withObjectTransform(ctx, tr, drawFn) {
  ctx.save();
  ctx.translate(CX + tr.sp.x, CY + tr.sp.y);
  ctx.rotate(tr.shellRot);
  ctx.scale(1, tr.yscale / 100);
  ctx.rotate(tr.instRot);
  drawFn(ctx);
  ctx.restore();
}

/* =========================================================================
 * PHASE DISC  (drawPhaseDisc Function.as port)
 * Draws into ctx centred at (ox,oy), radius r, split by a terminator ellipse.
 * ======================================================================= */
function drawPhaseDisc(ctx, phaseDeg, radius, lightColor, darkColor,
                       lineColor, lineAlpha, lineThickness, ox, oy) {
  ox = ox || 0; oy = oy || 0;
  let phase = mod(phaseDeg * DEG, TWO_PI);
  const f = (phase < Math.PI) ? -1 : 1;
  const n = 4, r = radius;
  const s = r * Math.cos(phase);
  const step = Math.PI / n, halfStep = step / 2;
  const kr = r / Math.cos(halfStep);
  const ks = s / Math.cos(halfStep);
  const sin = Math.sin, cos = Math.cos;

  function halfShape(fillColor, outerSign) {
    ctx.beginPath();
    ctx.moveTo(ox, oy - r);
    // outer semicircle (outerSign = +1 draws the ax = ±r*sin side)
    for (let i = 1; i <= n; i++) {
      const ang = i * step;
      const ax = outerSign * r * sin(ang), ay = -r * cos(ang);
      const cAng = ang - halfStep;
      const cx = outerSign * kr * sin(cAng), cy = -kr * cos(cAng);
      ctx.quadraticCurveTo(ox + f * cx, oy + cy, ox + f * ax, oy + ay);
    }
    // terminator ellipse back to top
    for (let i = n - 1; i >= 0; i--) {
      const ang = i * step;
      const ax = s * sin(ang), ay = -r * cos(ang);
      const cAng = ang + halfStep;
      const cx = ks * sin(cAng), cy = -kr * cos(cAng);
      ctx.quadraticCurveTo(ox + f * cx, oy + cy, ox + f * ax, oy + ay);
    }
    ctx.closePath();
    ctx.fillStyle = fillColor;
    ctx.fill();
  }

  halfShape(darkColor, 1);    // dark portion
  halfShape(lightColor, -1);  // lit portion

  if (lineThickness > 0 && lineAlpha > 0) {
    ctx.save();
    ctx.globalAlpha = lineAlpha / 100;
    ctx.strokeStyle = lineColor;
    ctx.lineWidth = lineThickness;
    ctx.beginPath();
    ctx.arc(ox, oy, r, 0, TWO_PI);
    ctx.stroke();
    ctx.restore();
  } else if (lineColor) {
    // hairline outline (lineThickness 0 in AS renders a hairline)
    ctx.save();
    ctx.globalAlpha = 1;
    ctx.strokeStyle = lineColor;
    ctx.lineWidth = 1;
    ctx.beginPath();
    ctx.arc(ox, oy, r, 0, TWO_PI);
    ctx.stroke();
    ctx.restore();
  }
}

/* =========================================================================
 * DERIVED QUANTITIES  (controller formulas, verbatim)
 * ======================================================================= */
// slider value (1..8) -> raw RA in hours  (onSunPositionChanged/onMoonPositionChanged)
function posToRawRa(v) { return -3 * (v - 1) + 6; }
// normalised RA in hours [0,24)  (matches CSObjects.getRa)
function posToRaHours(v) { return mod(posToRawRa(v), 24); }

function sunCelestial()  { return fromCelestial(posToRawRa(state.sunPos),  0, 1.00001); }
function moonCelestial() { return fromCelestial(posToRawRa(state.moonPos), 0, 1); }

// Sun altitude above the horizon (deg) -- for shadow + horizon shading
function sunAltitudeDeg() {
  const w = CtoW(sunCelestial());
  let z = w.z / 1.00001;
  if (z < -1) z = -1; else if (z > 1) z = 1;
  return RAD2DEG * Math.asin(z);
}

// updateTimeOfDay port -> formatted string (with the AS's leading space)
function timeOfDayString() {
  let h = mod(6 + 3 * (state.sunPos - 1), 24);
  let ampm;
  if (h < 12) ampm = 'AM'; else { h -= 12; ampm = 'PM'; }
  let hour = Math.floor(h);
  const min = Math.floor(60 * (h - hour));
  if (hour === 0) hour = 12;
  const hourStr = (hour < 10) ? ' ' + hour : String(hour);
  const minStr = (min < 10) ? '0' + min : String(min);
  return hourStr + ':' + minStr + ' ' + ampm;
}
// spoken form of the time (units-complete, no stray leading space)
function timeOfDaySpoken() { return timeOfDayString().trim() + ' local solar time'; }

// updateMoonPhase port -> {angle, descriptor}
function moonPhase() {
  const phaseAngle = 15 * (posToRaHours(state.sunPos) - posToRaHours(state.moonPos)) + 180;
  const t2 = 12, t1 = 5;
  const x = mod(180 - phaseAngle, 360);
  let id;
  if      (x <= t2)        id = 0;
  else if (x <= 90 - t1)   id = 1;
  else if (x <= 90 + t1)   id = 2;
  else if (x <= 180 - t2)  id = 3;
  else if (x <= 180 + t2)  id = 4;
  else if (x <= 270 - t1)  id = 5;
  else if (x <= 270 + t1)  id = 6;
  else if (x <= 360 - t2)  id = 7;
  else                     id = 0;
  return { angle: phaseAngle, descriptor: PHASE_NAMES[id] };
}

/* =========================================================================
 * RENDER
 * ======================================================================= */
let ctx, canvas, phaseCtx, phaseCanvas;

// Static object definitions (positions recomputed each frame)
function buildObjectList() {
  const list = [];
  // 8 position dots (red crosses) + number labels, at ra = 9 - 3k, dec 0 / dec 12
  for (let k = 1; k <= 8; k++) {
    const raHr = 9 - k * 3;
    list.push({ kind: 'dot', sys: 1, R: 1.00005, visible: state.show.positionLabels,
                pos: () => fromCelestial(raHr, 0, 1.00005), oType: 'absolute' });
  }
  for (let k = 1; k <= 8; k++) {
    const raHr = 9 - k * 3;
    list.push({ kind: 'label', text: String(k), sys: 1, R: 1, visible: state.show.positionLabels,
                pos: () => fromCelestial(raHr, 12, 1), oType: 'absolute' });
  }
  // Moon (surface, R=1): orientation absolute facing -pos, up = NCP
  list.push({ kind: 'moon', sys: 1, R: 1, visible: state.show.moon,
              pos: moonCelestial, oType: 'absolute',
              basis: () => {
                const p = moonCelestial();
                return absoluteBasisFrom({ x: -p.x, y: -p.y, z: -p.z }, fromCelestial(0, 90, 1));
              } });
  // Sun (external, R=1.00001): absolute default
  list.push({ kind: 'sun', sys: 1, R: 1.00001, visible: state.show.sun,
              pos: sunCelestial, oType: 'absolute' });
  return list;
}

function objRegion(sp, R) {
  const back = sp.z < 0;
  if (R > 1) return back ? 'bE' : 'fE';
  if (R < 1) return back ? 'bI' : 'aI';
  return back ? 'bS' : 'fS';
}

function drawObjectSprite(ctx, o) {
  if (o.kind === 'sun') {
    const rr = 12;
    const g = ctx.createRadialGradient(0, 0.8, 0, 0, 0.8, rr * 1.2);
    g.addColorStop(0, COL.sunInner); g.addColorStop(1, COL.sunOuter);
    ctx.beginPath(); ctx.arc(0, 0, rr, 0, TWO_PI);
    ctx.fillStyle = g; ctx.fill();
    ctx.lineWidth = 1;
    ctx.strokeStyle = state.hover.sun ? COL.sunLineOver : COL.sunLineNormal;
    ctx.stroke();
  } else if (o.kind === 'moon') {
    const p = moonPhase();
    if (state.show.phaseOnDisc) {
      drawPhaseDisc(ctx, p.angle, 12, COL.moonLight, COL.moonDark,
                    state.hover.moon ? '#000000' : COL.moonLine, 100, 0, 0, 0);
    } else {
      drawPhaseDisc(ctx, 180, 12, COL.moonSolid, COL.moonSolid,
                    state.hover.moon ? '#000000' : COL.moonLine, 100, 0, 0, 0);
    }
  } else if (o.kind === 'dot') {
    // red cross (shape 93): two 3px arms, 2px thick
    ctx.strokeStyle = COL.dot; ctx.lineWidth = 2; ctx.lineCap = 'round';
    ctx.beginPath();
    ctx.moveTo(-3, 0); ctx.lineTo(3, 0);
    ctx.moveTo(0, -3); ctx.lineTo(0, 3);
    ctx.stroke();
  } else if (o.kind === 'label') {
    ctx.fillStyle = COL.label;
    ctx.font = 'bold 13px Verdana, Arial, sans-serif';
    ctx.textAlign = 'center'; ctx.textBaseline = 'middle';
    ctx.fillText(o.text, 0, 0);
  }
}

// Labels/dots/text stay UPRIGHT for legibility (only sun/moon get billboarded
// foreshortening); this preserves the educational content and accessibility.
function drawObjectUpright(ctx, o, sp) {
  ctx.save();
  ctx.translate(CX + sp.x, CY + sp.y);
  drawObjectSprite(ctx, o);
  ctx.restore();
}

/* --- Horizon plane (green ellipse) + direction labels + horizon shading --- */
function drawHorizonPlane(ctx) {
  const sp = Math.sin(state.phi);
  const rx = cam.r, ry = cam.r * sp;   // semi-axes
  ctx.save();
  ctx.translate(CX, CY);
  // green gradient disk (shape 69 colours)
  ctx.save();
  ctx.scale(1, sp);
  const g = ctx.createRadialGradient(0, 0, 0, 0, 0, cam.r);
  g.addColorStop(0, COL.horizonInner);
  g.addColorStop(1, COL.horizonOuter);
  ctx.beginPath(); ctx.arc(0, 0, cam.r, 0, TWO_PI);
  ctx.fillStyle = g; ctx.fill();
  // horizon shading (dusk darkening) from sun altitude (updateShadow port)
  let shade = 0;
  if (state.show.sun) {
    const alt = sunAltitudeDeg();
    shade = 40 * Math.pow(1 - alt / 90, 4);
    if (shade > 40) shade = 40;
  }
  if (shade > 0) {
    ctx.beginPath(); ctx.arc(0, 0, cam.r, 0, TWO_PI);
    ctx.fillStyle = 'rgba(0,0,0,' + (shade / 100) + ')';
    ctx.fill();
  }
  ctx.restore();
  ctx.restore();

  // Direction labels N/E/S/W just outside the horizon rim (upright text)
  drawDirectionLabels(ctx);
}

function drawDirectionLabels(ctx) {
  const dirs = [ ['N', 0], ['E', 90], ['S', 180], ['W', 270] ];
  ctx.save();
  ctx.font = 'bold 13px Verdana, Arial, sans-serif';
  ctx.fillStyle = COL.dirLabel;
  ctx.textAlign = 'center';
  ctx.textBaseline = 'middle';
  for (const [letter, az] of dirs) {
    const p = fromHorizon(az, 0, 1.14);       // just outside the rim
    const s = WtoSz(p);
    ctx.fillText(letter, CX + s.x, CY + s.y);
  }
  ctx.restore();
}

/* --- Ecliptic band (11 CS Shaded Bands): +/-30 deg zone, blue translucent --- */
function drawEclipticBand(ctx, whichHalf) {
  // Faithful-visual rendering: fill the spherical zone between dec = -30 and
  // dec = +30 by sampling RA, splitting quads into front (z>=0) / back (z<0).
  const decs = [-30, 30];
  const N = 72;
  const step = 24 / N;
  ctx.save();
  ctx.beginPath();
  ctx.arc(CX, CY, cam.r, 0, TWO_PI);
  ctx.clip();                                  // never draw outside the sphere
  ctx.fillStyle = 'rgba(120,175,215,0.28)';    // Band Disc (shape 86) blue tint
  ctx.strokeStyle = COL.bandBorder;
  ctx.globalAlpha = 1;
  for (let i = 0; i < N; i++) {
    const ra1 = i * step, ra2 = (i + 1) * step;
    const q = [
      fromCelestial(ra1, decs[0], 1), fromCelestial(ra2, decs[0], 1),
      fromCelestial(ra2, decs[1], 1), fromCelestial(ra1, decs[1], 1)
    ].map(CtoSz);
    const zavg = (q[0].z + q[1].z + q[2].z + q[3].z) / 4;
    const isFront = zavg >= 0;
    if ((whichHalf === 'front') !== isFront) continue;
    ctx.beginPath();
    ctx.moveTo(CX + q[0].x, CY + q[0].y);
    for (let k = 1; k < 4; k++) ctx.lineTo(CX + q[k].x, CY + q[k].y);
    ctx.closePath();
    ctx.fill();
  }
  ctx.restore();

  // Border curves at dec = +/-30 (front or back half)
  for (const d of decs) {
    const c = makeCircle(COL.bandBorder, 50, 1, 0, 0, d);
    const proj = projectCircle(c);
    const segs = (whichHalf === 'front') ? proj.front : proj.back;
    for (const s of segs) strokePolyline(ctx, s, COL.bandBorder, 50, 1);
  }
}

/* --- Celestial bowl shading (CSGradientDisk: transparent centre -> 20% black rim) --- */
function drawCelestialBowl(ctx) {
  ctx.save();
  ctx.beginPath(); ctx.arc(CX, CY, cam.r, 0, TWO_PI); ctx.clip();
  const g = ctx.createRadialGradient(CX, CY, 0, CX, CY, cam.r);
  g.addColorStop(0, 'rgba(0,0,0,0)');
  g.addColorStop(1, 'rgba(0,0,0,0.20)');
  ctx.fillStyle = g;
  ctx.fillRect(CX - cam.r, CY - cam.r, 2 * cam.r, 2 * cam.r);
  ctx.restore();
}

/* --- Stickfigure + shadow (both reuse the exported vector art as-is) ---
 * shapes/59.svg = "Stickfigure"        (white head, black limbs) 14.6 x 36.3,
 *                 registration point (7.3, 35.3)  -> at the figure's feet
 * shapes/24.svg = "Stickfigure Shadow" (solid #333 silhouette)   12.6 x 34.3,
 *                 registration point (6.3, 34.3)  -> at the figure's feet
 */
const FIG = { w: 14.6, h: 36.3, ox: 7.3, oy: 35.3 };
const SHA = { w: 12.6, h: 34.3, ox: 6.3, oy: 34.3 };

let stickImg = null, stickReady = false;
let shadowImg = null, shadowReady = false;
function loadStickfigure() {
  stickImg = new Image();
  stickImg.onload = () => { stickReady = true; render(); };
  stickImg.src = 'assets/stickfigure.svg';
  shadowImg = new Image();
  shadowImg.onload = () => { shadowReady = true; render(); };
  shadowImg.src = 'assets/stickfigure-shadow.svg';
}

// 2x2 matrix helpers, [a,b,c,d] == canvas transform(a,b,c,d,0,0)
function matRot(rad) { const c = Math.cos(rad), s = Math.sin(rad); return [c, s, -s, c]; }
function matScale(sx, sy) { return [sx, 0, 0, sy]; }
function matMul(m1, m2) {
  return [
    m1[0] * m2[0] + m1[2] * m2[1],
    m1[1] * m2[0] + m1[3] * m2[1],
    m1[0] * m2[2] + m1[2] * m2[3],
    m1[1] * m2[2] + m1[3] * m2[3]
  ];
}

function drawStickfigure(ctx) {
  // Stickfigure: horizon centre, just above the ground (z = 0.0001),
  // absolute orientation, normal facing south {-1,0,0}, up = zenith {0,0,1}.
  const p = { x: 0, y: 0, z: 0.0001 };
  const basis = absoluteBasisFrom({ x: -1, y: 0, z: 0 }, { x: 0, y: 0, z: 1 });
  const tr = objectTransform(p, 0, 'absolute', basis);

  drawShadow(ctx);                       // shadow lies on the ground, drawn first

  if (stickReady) {
    withObjectTransform(ctx, tr, (c) => {
      c.drawImage(stickImg, -FIG.ox, -FIG.oy, FIG.w, FIG.h);
    });
  }
}

/* ShadowMaker.as port.
 * The shadow object sits at the horizon origin with absolute orientation
 * normal = zenith {0,0,1}, up = north {1,0,0}, i.e. it lies FLAT on the ground
 * and is foreshortened by the view. Inside that, ShadowMaker builds a shear
 * from two nested rotated/scaled clips ("outer" then "inner") that stretches
 * the silhouette away from the sun by 1/tan(altitude).
 */
function drawShadow(ctx) {
  if (!shadowReady || !state.show.sun) return;

  // Sun position in horizon coordinates (getPositionHorizon)
  const w = CtoW(sunCelestial());
  let z = w.z / 1.00001; if (z < -1) z = -1; else if (z > 1) z = 1;
  const altDeg = RAD2DEG * Math.asin(z);
  const azDeg = mod(-RAD2DEG * Math.atan2(w.y, w.x), 360);

  if (altDeg < 0.1) return;                       // inner._visible = false
  const tanAlt = Math.tan(altDeg * DEG);
  const alpha = 1 - 1 / (15 * tanAlt);            // lengthLimit = 15
  if (alpha <= 0) return;

  // --- ShadowMaker skew ---
  const xskew = azDeg - 180, yskew = 0;
  const xr = xskew * DEG, yr = yskew * DEG;
  const cosxr = Math.cos(xr), cosyr = Math.cos(yr);
  const RoDeg = 45 + (xskew + yskew) / 2;
  let den = Math.sin(RoDeg * DEG) * 0.707106781186547;
  if (!den) den = 1e-7;
  const Sox = (Math.sin(yr) + cosxr) / den;       // outer._xscale / 100
  const Soy = (Math.sin(xr) + cosyr) / den;       // outer._yscale / 100
  const baseYScale = Math.sin((azDeg - 90) * DEG) / tanAlt;
  const Six = 1 * 0.5 / cosyr;                    // inner._xscale / 100
  const Siy = baseYScale * 0.5 / cosxr;           // inner._yscale / 100

  // M = R(Ro)·S(Sox,Soy)·R(-45)·S(Six,Siy)
  let M = matMul(matRot(RoDeg * DEG), matScale(Sox, Soy));
  M = matMul(M, matRot(-45 * DEG));
  M = matMul(M, matScale(Six, Siy));

  // The shadow object's own placement on the ground plane
  const basis = absoluteBasisFrom({ x: 0, y: 0, z: 1 }, { x: 1, y: 0, z: 0 });
  const tr = objectTransform({ x: 0, y: 0, z: 0 }, 0, 'absolute', basis);

  ctx.save();
  ctx.globalAlpha = Math.min(1, alpha);
  ctx.translate(CX + tr.sp.x, CY + tr.sp.y);
  ctx.rotate(tr.shellRot);
  ctx.scale(1, tr.yscale / 100);
  ctx.rotate(tr.instRot);
  ctx.transform(M[0], M[1], M[2], M[3], 0, 0);
  ctx.drawImage(shadowImg, -SHA.ox, -SHA.oy, SHA.w, SHA.h);
  ctx.restore();
}

/* --- The master render --- */
function render() {
  updateMatrices();
  ctx.clearRect(0, 0, CANVAS, CANVAS);

  // Circles: celestial equator + two meridians
  const circles = [
    makeCircle(COL.meridian, 70, 1, 90,  0, 0),
    makeCircle(COL.meridian, 70, 1, 90, 90, 0),
    makeCircle(COL.equator, 100, 2,  0,  0, 0)
  ];
  const circleProj = circles.map(c => ({ c, p: projectCircle(c) }));

  // Axis lines (NCP/SCP stubs)
  const axisSegs = [];
  axisSegs.push(...computeLineSegments({ x: 0, y: 0, z: 1 }, { x: 0, y: 0, z: 1.2 }));
  axisSegs.push(...computeLineSegments({ x: 0, y: 0, z: -1 }, { x: 0, y: 0, z: -1.2 }));

  // Objects: compute transforms + regions
  const objs = buildObjectList().filter(o => o.visible).map(o => {
    const p = o.pos();
    const basis = o.oType === 'absolute'
      ? (o.basis ? o.basis() : absoluteBasisDefault(p))
      : null;
    const tr = objectTransform(p, o.sys, o.oType, basis);
    return { o, p, tr, region: objRegion(tr.sp, o.R) };
  });
  const inRegion = (r) => objs.filter(x => x.region === r)
                              .sort((a, b) => a.tr.sp.z - b.tr.sp.z);

  const drawObj = (x) => {
    if (x.o.kind === 'sun' || x.o.kind === 'moon') {
      withObjectTransform(ctx, x.tr, (c) => drawObjectSprite(c, x.o));
    } else {
      drawObjectUpright(ctx, x.o, x.tr.sp);  // dots & number labels upright
    }
  };
  const drawAxis = (layer) => {
    for (const s of axisSegs) if (s.layer === layer)
      strokePolyline(ctx, [{ x: s.x1, y: s.y1 }, { x: s.x2, y: s.y2 }],
                     COL.axis, 100, 2);
  };

  /* ---- Painter's order (back -> front), mirroring the Flash depth bands ---- */
  // 1. back external objects, 2. back external lines
  inRegion('bE').forEach(drawObj);
  drawAxis('bE');
  // 4. back circles, 5. back surface objects
  for (const { c, p } of circleProj) for (const s of p.back)
    strokePolyline(ctx, s, c.color, c.alpha, c.thickness);
  inRegion('bS').forEach(drawObj);
  // 6. back half of ecliptic band, 7. back inner objects, 8. inner lines below
  if (state.show.eclipticBand) drawEclipticBand(ctx, 'back');
  inRegion('bI').forEach(drawObj);
  drawAxis('bI');
  // 9. HORIZON PLANE
  drawHorizonPlane(ctx);
  // 10. front(above) inner objects (stickfigure sits here), 11. inner lines above
  drawStickfigure(ctx);
  inRegion('aI').forEach(drawObj);
  drawAxis('aI');
  // 12. front inner shading: celestial bowl + ecliptic band front
  drawCelestialBowl(ctx);
  if (state.show.eclipticBand) drawEclipticBand(ctx, 'front');
  // 13. front circles, 14. front surface objects
  for (const { c, p } of circleProj) for (const s of p.front)
    strokePolyline(ctx, s, c.color, c.alpha, c.thickness);
  inRegion('fS').forEach(drawObj);
  // 16. front external objects, 17. front external lines
  inRegion('fE').forEach(drawObj);
  drawAxis('fE');

  syncDom();
  drawPhaseDiscPanel();
  updateDiagramDescription();
}

/* =========================================================================
 * DOM SYNC (readouts) + panel phase disc
 * ======================================================================= */
let el = {};
function cacheEls() {
  el = {
    latSlider:  document.getElementById('latitudeSlider'),
    latValue:   document.getElementById('latitudeValue'),
    sunSlider:  document.getElementById('sunPositionSlider'),
    sunValue:   document.getElementById('sunPositionValue'),
    moonSlider: document.getElementById('moonPositionSlider'),
    moonValue:  document.getElementById('moonPositionValue'),
    timeValue:  document.getElementById('timeOfDayValue'),
    timeLabel:  document.getElementById('timeOfDayLabel'),
    phaseValue: document.getElementById('moonPhaseValue'),
    phaseLabel: document.getElementById('moonPhaseLabel'),
    cbPositionLabels: document.getElementById('cbPositionLabels'),
    cbEclipticBand:   document.getElementById('cbEclipticBand'),
    cbShowSun:        document.getElementById('cbShowSun'),
    cbShowTime:       document.getElementById('cbShowTime'),
    cbShowMoon:       document.getElementById('cbShowMoon'),
    cbShowPhase:      document.getElementById('cbShowPhase'),
    cbShowPhaseOnDisc:document.getElementById('cbShowPhaseOnDisc'),
    live:       document.getElementById('liveRegion'),
    desc:       document.getElementById('diagramDescription')
  };
}

function syncDom() {
  // Latitude readout
  const latDeg = Number((state.lat * RAD2DEG).toFixed(1));
  el.latValue.textContent = latDeg.toFixed(1) + '°';
  el.latSlider.setAttribute('aria-valuetext', 'Latitude ' + latDeg.toFixed(1) + ' degrees');

  // Sun / moon position readouts
  const sv = Math.round(state.sunPos), mv = Math.round(state.moonPos);
  el.sunValue.textContent = String(sv);
  el.moonValue.textContent = String(mv);
  el.sunSlider.setAttribute('aria-valuetext', 'Sun position ' + sv + ' of 8');
  el.moonSlider.setAttribute('aria-valuetext', 'Moon position ' + mv + ' of 8');

  // Time of day
  el.timeValue.textContent = timeOfDayString();
  el.timeValue.classList.toggle('is-dimmed', !state.show.time);
  el.timeValue.style.visibility = state.show.time ? 'visible' : 'hidden';

  // Moon phase name
  const ph = moonPhase();
  el.phaseValue.textContent = ph.descriptor;
  el.phaseValue.classList.toggle('is-dimmed', !state.show.phase);
  el.phaseValue.style.visibility = state.show.phase ? 'visible' : 'hidden';
}

function drawPhaseDiscPanel() {
  phaseCtx.clearRect(0, 0, phaseCanvas.width, phaseCanvas.height);
  if (!state.show.phase) return;
  const ph = moonPhase();
  const cx = phaseCanvas.width / 2, cy = phaseCanvas.height / 2;
  drawPhaseDisc(phaseCtx, ph.angle, 28, COL.discLight, COL.discDark,
                COL.moonLine, 100, 1, cx, cy);
}

/* =========================================================================
 * SCREEN-READER: continuously-updated diagram description
 * ======================================================================= */
function updateDiagramDescription() {
  const az = Math.round(mod(360 - state.theta * RAD2DEG, 360));
  const alt = Math.round(state.phi * RAD2DEG);
  const lat = (state.lat * RAD2DEG).toFixed(1);
  const parts = [];
  parts.push('Horizon diagram viewed from azimuth ' + az + ' degrees, altitude ' +
             alt + ' degrees, for an observer at latitude ' + lat + ' degrees.');
  if (state.show.sun) {
    const sAlt = Math.round(sunAltitudeDeg());
    parts.push('Sun at position ' + Math.round(state.sunPos) + ' of 8, altitude ' +
               sAlt + ' degrees; local solar time ' + timeOfDayString().trim() + '.');
  } else {
    parts.push('Sun hidden.');
  }
  if (state.show.moon) {
    const ph = moonPhase();
    parts.push('Moon at position ' + Math.round(state.moonPos) + ' of 8' +
               (state.show.phase ? ', phase ' + ph.descriptor : '') + '.');
  } else {
    parts.push('Moon hidden.');
  }
  el.desc.textContent = parts.join(' ');
}

let liveTimer = null;
function announce(msg) {
  if (liveTimer) clearTimeout(liveTimer);
  // brief clear so repeated identical messages are still spoken
  el.live.textContent = '';
  liveTimer = setTimeout(() => { el.live.textContent = msg; }, 60);
}

/* =========================================================================
 * SLIDER SNAP-TWEEN (hackSlider doTween port) for sun/moon position
 * ======================================================================= */
const prefersReducedMotion =
  window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches;

function posSliderFor(which) { return which === 'sun' ? el.sunSlider : el.moonSlider; }
function clampPos(v) { return mod(v - 1, 8) + 1; }   // keep within 1..8, wrapping

// Snap-tween to the nearest whole position (hackSlider.doTween: 200 ms, pow 0.3)
function snapPosition(which) {
  const key = which + 'Pos';
  const slider = posSliderFor(which);
  const start = state[key];
  const end = Math.round(start);
  if (prefersReducedMotion || Math.abs(start - end) < 1e-6) {
    state[key] = clampPos(end);
    slider.value = String(state[key]);
    finishPositionChange(which);
    return;
  }
  const t0 = performance.now(), dur = 200;
  let done = false;
  const finish = () => {
    if (done) return;
    done = true;
    state[key] = clampPos(end);
    slider.value = String(state[key]);
    finishPositionChange(which);
  };
  function step(now) {
    if (done) return;
    const f = Math.min(1, (now - t0) / dur);
    state[key] = start + (end - start) * Math.pow(f, 0.3);
    slider.value = String(state[key]);           // handle animates with it
    render();
    if (f < 1) requestAnimationFrame(step);
    else finish();
  }
  requestAnimationFrame(step);
  // Guarantee the snap completes even if rAF is throttled (backgrounded tab,
  // hidden page); otherwise the sim could be left on a fractional position.
  setTimeout(finish, dur + 80);
}

function announcePos(which) {
  const v = Math.round(state[which + 'Pos']);
  if (which === 'sun') {
    announce('Sun position ' + v + ' of 8. Local solar time ' +
             timeOfDayString().trim() + '. Moon phase ' + moonPhase().descriptor + '.');
  } else {
    announce('Moon position ' + v + ' of 8. Moon phase ' + moonPhase().descriptor + '.');
  }
}
function finishPositionChange(which) {
  render();
  announcePos(which);
}

/* =========================================================================
 * POINTER INTERACTION (sphere rotate + sun/moon drag)
 * ======================================================================= */
function canvasMouse(e) {
  const rect = canvas.getBoundingClientRect();
  const cx = (e.clientX - rect.left) / rect.width * CANVAS - CX;
  const cy = (e.clientY - rect.top) / rect.height * CANVAS - CY;
  return { x: cx, y: cy };
}

let drag = null;   // {mode:'sphere'|'sun'|'moon', ...}

function objectScreen(which) {
  const p = which === 'sun' ? sunCelestial() : moonCelestial();
  return CtoSz(p);
}

function hitTestDisc(m) {
  // Returns 'sun' | 'moon' | null (front discs only, matching onPress z>0 test)
  const candidates = [];
  if (state.show.sun) {
    const s = objectScreen('sun');
    if (s.z > 0 && Math.hypot(m.x - s.x, m.y - s.y) <= 13) candidates.push(['sun', s.z]);
  }
  if (state.show.moon) {
    const s = objectScreen('moon');
    if (s.z > 0 && Math.hypot(m.x - s.x, m.y - s.y) <= 13) candidates.push(['moon', s.z]);
  }
  if (!candidates.length) return null;
  candidates.sort((a, b) => b[1] - a[1]);   // topmost (largest z) first
  return candidates[0][0];
}

function onPointerDown(e) {
  canvas.focus();
  const m = canvasMouse(e);
  const hit = hitTestDisc(m);
  try { canvas.setPointerCapture(e.pointerId); } catch (_) {}
  if (hit) {
    const cel = screenToCelestial(m.x, m.y);
    const objRa = posToRaHours(hit === 'sun' ? state.sunPos : state.moonPos);
    // offset = mouseRA - objectRA   (Sun/Moon Disc onPress)
    drag = { mode: hit, offset: cel.ra - objRa };
    state.hover[hit] = true;
    render();
  } else {
    drag = { mode: 'sphere', mx: m.x, my: m.y, theta: state.theta, phi: state.phi };
  }
  e.preventDefault();
}

function onPointerMove(e) {
  if (!drag) return;
  const m = canvasMouse(e);
  if (drag.mode === 'sphere') {
    setThetaPhi(
      RAD2DEG * (drag.theta - (m.x - drag.mx) / cam.r),
      RAD2DEG * (drag.phi + (m.y - drag.my) / cam.r)
    );
    render();
  } else {
    // Sun/Moon Disc onMouseMoveFunc port
    const cel = screenToCelestial(m.x, m.y);
    const newRa = cel.ra - drag.offset;
    let v = 1 + (newRa - 6) / -3;
    v = 0.5 + mod(v - 0.5, 8);
    state[drag.mode + 'Pos'] = v;
    posSliderFor(drag.mode).value = String(v);   // slider handle follows the disc
    render();
  }
  e.preventDefault();
}

function onPointerUp(e) {
  if (!drag) return;
  if (drag.mode === 'sphere') {
    announceView();
  } else {
    state.hover[drag.mode] = false;
    snapPosition(drag.mode);          // tween to nearest integer (1..8, wraps)
  }
  drag = null;
  try { canvas.releasePointerCapture(e.pointerId); } catch (_) {}
}

// setThetaAndPhi port (clamped phi to [minPhi,maxPhi])
function setThetaPhi(thetaDeg, phiDeg) {
  state.theta = DEG * mod(thetaDeg, 360);
  let p = phiDeg;
  if (p > INIT.maxPhi) p = INIT.maxPhi; else if (p < INIT.minPhi) p = INIT.minPhi;
  state.phi = p * DEG;
}
function announceView() {
  const az = Math.round(mod(360 - state.theta * RAD2DEG, 360));
  const alt = Math.round(state.phi * RAD2DEG);
  announce('View azimuth ' + az + ' degrees, altitude ' + alt + ' degrees.');
}

/* =========================================================================
 * KEYBOARD (sphere rotation when the canvas is focused)
 * ======================================================================= */
function onCanvasKey(e) {
  const stepBig = e.shiftKey || e.key.indexOf('Page') === 0;
  const stepAz = stepBig ? 15 : 5, stepAlt = stepBig ? 15 : 5;
  let thetaDeg = mod(360 - state.theta * RAD2DEG, 360); // viewer azimuth
  let phiDeg = state.phi * RAD2DEG;
  let handled = true;
  switch (e.key) {
    case 'ArrowLeft':  thetaDeg -= stepAz; break;
    case 'ArrowRight': thetaDeg += stepAz; break;
    case 'PageUp':
    case 'ArrowUp':    phiDeg += stepAlt; break;
    case 'PageDown':
    case 'ArrowDown':  phiDeg -= stepAlt; break;
    case 'Home':       phiDeg = INIT.maxPhi; break;
    case 'End':        phiDeg = INIT.minPhi; break;
    default: handled = false;
  }
  if (!handled) return;
  e.preventDefault();
  // viewerAzimuth -> theta = 360 - az
  setThetaPhi(360 - mod(thetaDeg, 360), phiDeg);
  render();
  announceView();
}

/* =========================================================================
 * NUMERIC / SLIDER + CHECKBOX WIRING
 * ======================================================================= */
function wheelStep(slider, onChange) {
  slider.addEventListener('wheel', (e) => {
    if (document.activeElement !== slider) return;   // only when focused
    e.preventDefault();
    const step = Number(slider.step) || 1;
    const dir = e.deltaY < 0 ? 1 : -1;
    let v = Number(slider.value) + dir * step;
    v = Math.max(Number(slider.min), Math.min(Number(slider.max), v));
    slider.value = String(v);
    onChange();
  }, { passive: false });
}

function wireControls() {
  // Latitude slider (native range: arrows/Page/Home/End free; add wheel)
  const onLat = () => {
    state.lat = Number(el.latSlider.value) * DEG;
    render();
    announce('Latitude ' + Number(el.latSlider.value).toFixed(1) + ' degrees.');
  };
  el.latSlider.addEventListener('input', onLat);
  wheelStep(el.latSlider, onLat);

  // Sun / Moon position sliders.
  // Pointer dragging is CONTINUOUS (the AS slider runs 0.51..8.49 and only
  // snaps to a whole position on release, via doTween). Keyboard moves by
  // whole positions with 1<->8 wrap (the AS incrementValue).
  const posSlider = (slider, which) => {
    // continuous while dragging - no announcement per tick
    slider.addEventListener('input', () => {
      state[which + 'Pos'] = Number(slider.value);
      render();
    });
    // fires on pointer release / after a committed change -> snap + announce
    slider.addEventListener('change', () => { snapPosition(which); });

    const stepTo = (next) => {
      next = clampPos(next);
      state[which + 'Pos'] = next;
      slider.value = String(next);
      render();
      announcePos(which);
    };
    slider.addEventListener('keydown', (e) => {
      const cur = Math.round(state[which + 'Pos']);
      let next;
      switch (e.key) {
        case 'ArrowLeft': case 'ArrowDown':  next = cur - 1; break;
        case 'ArrowRight': case 'ArrowUp':   next = cur + 1; break;
        case 'PageDown':                     next = cur - 2; break;
        case 'PageUp':                       next = cur + 2; break;
        case 'Home':                         next = 1; break;
        case 'End':                          next = 8; break;
        default: return;
      }
      e.preventDefault();     // stop the native 0.01-step move
      stepTo(next);
    });
    slider.addEventListener('wheel', (e) => {
      if (document.activeElement !== slider) return;
      e.preventDefault();
      stepTo(Math.round(state[which + 'Pos']) + (e.deltaY < 0 ? 1 : -1));
    }, { passive: false });
  };
  posSlider(el.sunSlider, 'sun');
  posSlider(el.moonSlider, 'moon');

  // Checkboxes
  const cb = (node, key, msgOn, msgOff) => {
    node.addEventListener('change', () => {
      state.show[key] = node.checked;
      render();
      announce(node.checked ? msgOn : msgOff);
    });
  };
  cb(el.cbPositionLabels, 'positionLabels', 'Position labels shown.', 'Position labels hidden.');
  cb(el.cbEclipticBand,   'eclipticBand',   'Ecliptic band shown.',   'Ecliptic band hidden.');
  cb(el.cbShowSun,        'sun',            'Sun shown.',             'Sun hidden.');
  cb(el.cbShowTime,       'time',           'Time of day shown.',     'Time of day hidden.');
  cb(el.cbShowMoon,       'moon',           'Moon shown.',            'Moon hidden.');
  cb(el.cbShowPhase,      'phase',          'Moon phase shown.',      'Moon phase hidden.');
  cb(el.cbShowPhaseOnDisc,'phaseOnDisc',    'Phase shown on the moon disc.',
                                             'Phase not shown on the moon disc.');
}

/* =========================================================================
 * RESET  (masthead "sim-reset" -> restore exact initial state)
 * ======================================================================= */
function resetSim() {
  state.theta = DEG * mod(360 - INIT.viewerAzimuth, 360);
  state.phi   = DEG * INIT.phiDeg;
  state.lat   = DEG * INIT.latitude;
  state.sTime = mod(INIT.siderealTime, 24) * HR2RAD;
  state.sunPos = INIT.sunPos;
  state.moonPos = INIT.moonPos;
  state.show = { positionLabels: false, eclipticBand: false, sun: true,
                 time: true, moon: true, phase: true, phaseOnDisc: false };
  state.hover = { sun: false, moon: false };

  el.latSlider.value = String(INIT.latitude.toFixed(1));
  el.sunSlider.value = String(INIT.sunPos);
  el.moonSlider.value = String(INIT.moonPos);
  el.cbPositionLabels.checked = false;
  el.cbEclipticBand.checked = false;
  el.cbShowSun.checked = true;
  el.cbShowTime.checked = true;
  el.cbShowMoon.checked = true;
  el.cbShowPhase.checked = true;
  el.cbShowPhaseOnDisc.checked = false;

  render();
  announce('Simulation reset to its initial state.');
}

/* =========================================================================
 * INIT
 * ======================================================================= */
function init() {
  canvas = document.getElementById('sphereCanvas');
  ctx = canvas.getContext('2d');
  phaseCanvas = document.getElementById('phaseDiscCanvas');
  phaseCtx = phaseCanvas.getContext('2d');
  cacheEls();
  wireControls();
  loadStickfigure();

  canvas.addEventListener('pointerdown', onPointerDown);
  canvas.addEventListener('pointermove', onPointerMove);
  window.addEventListener('pointerup', onPointerUp);
  canvas.addEventListener('keydown', onCanvasKey);

  // Reset event bubbles (composed) from the masthead custom element
  document.addEventListener('sim-reset', resetSim);

  render();
}

// klunlInitEqn is called by the foundation on load; there are no equations in
// this sim, so we (re)define it to initialise the simulation instead.
window.klunlInitEqn = function () { init(); };

// Fallback: if the foundation script already ran klunlInitEqn before our
// redefinition, or MathJax hooks differ, ensure init runs once on DOM ready.
if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', () => { if (!ctx) init(); });
} else {
  if (!ctx) init();
}
