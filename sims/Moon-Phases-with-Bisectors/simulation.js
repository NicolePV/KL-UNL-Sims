/* ===========================================================================
   Determining Moon Phases Using Bisectors  --  HTML5 / KL-UNL port
   ---------------------------------------------------------------------------
   Faithful port of the decompiled ActionScript 3 simulation (moonbisector.swf,
   moonBisectorDemo005). All geometry, projection, shading, and control logic
   are reproduced from the AS source; constants and text are verbatim.

   Original AS classes mapped here:
     Scene3D                    -> projection matrix (t and it arrays), viewer angles
     Globe / Globe3D            -> Globe (base disc + coastline/maria layers + terminator shading)
     BisectingPlanesForGlobe3D  -> BisectingPlanes (12 depth-sorted plane wedges)
     OrbitalPlane / MBDOrbitalPlane -> OrbitalPlane (reuses assets/orbit.svg + assets/sun-arrow.svg)
     PhaseDisc                  -> PhaseDisc (Step 6 moon-phase disc)
     CubicEaser                 -> CubicEaser (camera slew easing)
     ProtoSimpleSlider / ...    -> native <input type="range"> (accessible)

   Rendering is a single unified depth sort (painter's algorithm on screenZ),
   exactly as Scene3D.update() sorts its object list.
   =========================================================================== */

'use strict';

/* ------------------------------- constants ------------------------------- */
const SCALE       = 100;          // Scene3D _scale
const SCENE_W     = 600;          // Scene3D sceneWidth
const SCENE_H     = 600;          // Scene3D sceneHeight
const CX          = SCENE_W / 2;  // scene-centre in canvas coords
const CY          = SCENE_H / 2;
const MOON_DIST   = 2.2;          // MainTimeline moonDist
const EARTH_R     = 0.4;          // earth scene radius
const MOON_R      = 0.2;          // moon scene radius
const TILT_C      = 0.91706;      // cos(obliquity)  (from AS)
const TILT_S      = 0.39875;      // sin(obliquity)  (from AS)
const SLEW_MS     = 900;          // slewDuration

const PI = Math.PI;
const norm360 = (d) => ((d % 360) + 360) % 360;
const norm2pi = (a) => ((a % (2 * PI)) + 2 * PI) % (2 * PI);

// AS decimal RGB int -> css color
function rgb(intColor) {
  const r = (intColor >> 16) & 0xff;
  const g = (intColor >> 8) & 0xff;
  const b = intColor & 0xff;
  return `rgb(${r},${g},${b})`;
}

/* ------------------------------ scene state ------------------------------ */
// viewer angles (radians), matching Scene3D _viewerTheta/_viewerPhi
let vTheta = 0, vPhi = 0;
// projection matrix
let t0, t1, t2, t3, t4, t5, t6, t7, t8;
let it0, it1, it2, it3, it4, it5, it6, it7, it8;

function calcSceneConstants() {
  const cT = Math.cos(vTheta), sT = Math.sin(vTheta);
  const cP = Math.cos(vPhi),  sP = Math.sin(vPhi);
  t0 = SCALE * sT;      t1 = -SCALE * cT;      t2 = 0;
  t3 = -SCALE * cT * sP; t4 = -SCALE * sT * sP; t5 = -SCALE * cP;
  t6 = -SCALE * cT * cP; t7 = -SCALE * sT * cP; t8 = SCALE * sP;
  const s2 = SCALE * SCALE;
  it0 = t0 / s2; it1 = t3 / s2; it2 = t6 / s2;
  it3 = t1 / s2; it4 = t4 / s2; it5 = t7 / s2;
  it6 = t2 / s2; it7 = t5 / s2; it8 = t8 / s2;
}

function setViewer(thetaDeg, phiDeg) {
  vTheta = (thetaDeg + 180) * PI / 180;
  vPhi = phiDeg * PI / 180;
  if (vPhi > PI / 2) vPhi = PI / 2;
  else if (vPhi < -PI / 2) vPhi = -PI / 2;
  calcSceneConstants();
}
const viewerThetaDeg = () => vTheta * 180 / PI - 180;
const viewerPhiDeg   = () => vPhi * 180 / PI;

function screenOf(wx, wy, wz) {
  return {
    x: t0 * wx + t1 * wy + t2 * wz,
    y: t3 * wx + t4 * wy + t5 * wz,
    z: t6 * wx + t7 * wy + t8 * wz,
  };
}
function worldOf(sx, sy, sz) {
  return {
    x: it0 * sx + it1 * sy + it2 * sz,
    y: it3 * sx + it4 * sy + it5 * sz,
    z: it6 * sx + it7 * sy + it8 * sz,
  };
}

/* ================================ Globe ================================== */
class Globe {
  constructor(sceneRadius, baseColor) {
    this.sceneRadius = sceneRadius;
    this.baseColor = baseColor;
    this.baseAlpha = 1;
    this.layers = [];            // {color, alpha, fills:[[ [x,y,z], ...], ...]}
    this.lineColor = 0xffffff;
    this.lineAlpha = 0;
    this.lineThickness = 0;
    this.shadingColor = 0;
    this.shadingAlpha = 0.6;
    this.showShading = false;
    this.alpha = 1;
    this.rotationDeg = 0;
    this.precessionDeg = 0;
    this.earthBackHack = false;

    this.worldX = 0; this.worldY = 0; this.worldZ = 0;
    this.screenX = 0; this.screenY = 0; this.screenZ = 0;

    // per-globe viewer angles (earthBack uses flipped ones)
    this._vT = 0; this._vP = 0;
    this.sunX = 1; this.sunY = 0; this.sunZ = 0;
  }
  get radius() { return this.sceneRadius; }            // scene radius
  get pxRadius() { return this.sceneRadius * SCALE; }   // pixel radius
  get screenRadius() { return this.sceneRadius * SCALE; }

  setSunDirection(thetaDeg, phiDeg) {
    const st = thetaDeg * PI / 180, sp = phiDeg * PI / 180;
    this.sunX = Math.cos(sp) * Math.cos(st);
    this.sunY = Math.cos(sp) * Math.sin(st);
    this.sunZ = Math.sin(sp);
  }

  setViewerFromScene() {
    if (this.earthBackHack) {
      this._setViewer(viewerThetaDeg() + 180, -viewerPhiDeg());
    } else {
      this._setViewer(viewerThetaDeg(), viewerPhiDeg());
    }
  }
  _setViewer(thetaDeg, phiDeg) {
    this._vT = (thetaDeg + 180) * PI / 180;
    let p = phiDeg * PI / 180;
    if (p > PI / 2) p = PI / 2; else if (p < -PI / 2) p = -PI / 2;
    this._vP = p;
  }

  // b-constants: world(unit sphere) -> screen(px), radius scaled
  _bConsts() {
    const R = this.pxRadius;
    const cT = Math.cos(this._vT), sT = Math.sin(this._vT);
    const cP = Math.cos(this._vP), sP = Math.sin(this._vP);
    return {
      b0: R * sT, b1: -R * cT, b2: 0,
      b3: -R * cT * sP, b4: -R * sT * sP, b5: -R * cP,
      b6: -R * cT * cP, b7: -R * sT * cP, b8: R * sP,
    };
  }
  // precession (p) constants
  _pConsts() {
    const pr = norm360(this.precessionDeg) * PI / 180;
    const c = Math.cos(pr), s = Math.sin(pr);
    return {
      p0: c, p1: -s,
      p3: s * TILT_C, p4: c * TILT_C, p5: -TILT_S,
      p6: s * TILT_S, p7: c * TILT_S, p8: TILT_C,
    };
  }
  // rotation (r) constants
  _rConsts() {
    const rr = norm360(this.rotationDeg) * PI / 180;
    const c = Math.cos(rr), s = Math.sin(rr);
    return {
      r0: c, r1: -s,
      r3: s * TILT_C, r4: c * TILT_C, r5: TILT_S,
      r6: -s * TILT_S, r7: -c * TILT_S, r8: TILT_C,
    };
  }
  _qConsts() {
    const p = this._pConsts(), r = this._rConsts();
    return {
      q0: p.p0 * r.r0 + p.p1 * r.r3,
      q1: p.p0 * r.r1 + p.p1 * r.r4,
      q2: p.p1 * r.r5,
      q3: p.p3 * r.r0 + p.p4 * r.r3 + p.p5 * r.r6,
      q4: p.p3 * r.r1 + p.p4 * r.r4 + p.p5 * r.r7,
      q5: p.p4 * r.r5 + p.p5 * r.r8,
      q6: p.p6 * r.r0 + p.p7 * r.r3 + p.p8 * r.r6,
      q7: p.p6 * r.r1 + p.p7 * r.r4 + p.p8 * r.r7,
      q8: p.p7 * r.r5 + p.p8 * r.r8,
    };
  }

  draw(ctx) {
    this.setViewerFromScene();
    ctx.save();
    ctx.translate(CX + this.screenX, CY + this.screenY);
    if (this.earthBackHack) ctx.scale(-1, 1);
    const R = this.pxRadius;

    // base disc
    ctx.globalAlpha = this.alpha * this.baseAlpha;
    ctx.beginPath();
    ctx.arc(0, 0, R, 0, 2 * PI);
    ctx.fillStyle = rgb(this.baseColor);
    ctx.fill();

    // layers (clipped to the disc)
    ctx.save();
    ctx.beginPath();
    ctx.arc(0, 0, R, 0, 2 * PI);
    ctx.clip();
    this._drawLayers(ctx);
    ctx.restore();

    // day/night terminator shading
    this._drawShading(ctx, R);

    ctx.restore();
    ctx.globalAlpha = 1;
  }

  _drawLayers(ctx) {
    const b = this._bConsts(), q = this._qConsts();
    const R = this.pxRadius;
    const d = 1.5 * R;
    const minStep = 2 * Math.acos(0.7);
    // k = b . q
    const k0 = b.b0 * q.q0 + b.b1 * q.q3 + b.b2 * q.q6;
    const k1 = b.b0 * q.q1 + b.b1 * q.q4 + b.b2 * q.q7;
    const k2 = b.b0 * q.q2 + b.b1 * q.q5 + b.b2 * q.q8;
    const k3 = b.b3 * q.q0 + b.b4 * q.q3 + b.b5 * q.q6;
    const k4 = b.b3 * q.q1 + b.b4 * q.q4 + b.b5 * q.q7;
    const k5 = b.b3 * q.q2 + b.b4 * q.q5 + b.b5 * q.q8;
    const k6 = b.b6 * q.q0 + b.b7 * q.q3 + b.b8 * q.q6;
    const k7 = b.b6 * q.q1 + b.b7 * q.q4 + b.b8 * q.q7;
    const k8 = b.b6 * q.q2 + b.b7 * q.q5 + b.b8 * q.q8;

    const lineOn = this.lineAlpha > 0;
    for (let i = 0; i < this.layers.length; i++) {
      const layer = this.layers[i];
      const fills = layer.fills;
      for (let j = 0; j < fills.length; j++) {
        const pts = fills[j];
        const n = pts.length;
        // find kOff: index of second consecutive front-facing vertex
        let lastInFront = false, kOff = 0;
        for (kOff = 0; kOff < n; kOff++) {
          const p = pts[kOff];
          if (p[0] * k6 + p[1] * k7 + p[2] * k8 > 0) {
            if (lastInFront) break;
            lastInFront = true;
          } else {
            lastInFront = false;
          }
        }
        if (kOff === n) continue;  // fill not visible

        ctx.beginPath();
        const p0 = pts[kOff];
        ctx.moveTo(p0[0] * k0 + p0[1] * k1 + p0[2] * k2,
                   p0[0] * k3 + p0[1] * k4 + p0[2] * k5);
        let ibLast = false, angleLast = 0;
        for (let k = 1; k < n; k++) {
          const p = pts[(k + kOff) % n];
          const ibNow = (p[0] * k6 + p[1] * k7 + p[2] * k8) < 0;
          if (!ibNow) {
            if (ibLast) {
              const sx = p[0] * k0 + p[1] * k1 + p[2] * k2;
              const sy = p[0] * k3 + p[1] * k4 + p[2] * k5;
              const angleNow = Math.atan2(sy, sx);
              let arc = norm2pi(angleNow - angleLast);
              let steps, step;
              if (arc > PI) { arc = 2 * PI - arc; steps = Math.ceil(arc / minStep); step = -arc / steps; }
              else          { steps = Math.ceil(arc / minStep); step = arc / steps; }
              for (let m = 1; m <= steps; m++) {
                const a = angleLast + step * m;
                ctx.lineTo(d * Math.cos(a), d * Math.sin(a));
              }
              ctx.lineTo(sx, sy);
            } else {
              ctx.lineTo(p[0] * k0 + p[1] * k1 + p[2] * k2,
                         p[0] * k3 + p[1] * k4 + p[2] * k5);
            }
          } else if (!ibLast) {
            angleLast = Math.atan2(p[0] * k3 + p[1] * k4 + p[2] * k5,
                                   p[0] * k0 + p[1] * k1 + p[2] * k2);
            ctx.lineTo(d * Math.cos(angleLast), d * Math.sin(angleLast));
          }
          ibLast = ibNow;
        }
        ctx.closePath();
        ctx.globalAlpha = this.alpha * layer.alpha;
        ctx.fillStyle = rgb(layer.color);
        ctx.fill();
        if (lineOn) {
          ctx.globalAlpha = this.alpha * this.lineAlpha;
          ctx.lineWidth = this.lineThickness || 1;
          ctx.strokeStyle = rgb(this.lineColor);
          ctx.stroke();
        }
      }
    }
  }

  _drawShading(ctx, R) {
    if (!this.showShading) return;
    const b = this._bConsts();
    const l2 = this.sunX * b.b0 + this.sunY * b.b1 + this.sunZ * b.b2;
    const l3 = this.sunX * b.b3 + this.sunY * b.b4 + this.sunZ * b.b5;
    const l4 = this.sunX * b.b6 + this.sunY * b.b7 + this.sunZ * b.b8;
    const rotation = Math.atan2(l2, -l3);
    const l5 = -l4 / Math.sqrt(l2 * l2 + l3 * l3 + l4 * l4);
    const segs = 4;
    const step = PI / segs;
    const half = step / 2;
    const r9 = R + 0.25;
    const r10 = r9 / Math.cos(half);

    ctx.save();
    ctx.rotate(rotation);
    ctx.beginPath();
    ctx.moveTo(r9, 0);
    let a1 = step, a2 = step - half;
    for (let i = 0; i < segs; i++) {
      ctx.quadraticCurveTo(r10 * Math.cos(a2), r10 * Math.sin(a2),
                           r9 * Math.cos(a1), r9 * Math.sin(a1));
      a1 += step; a2 += step;
    }
    for (let i = 0; i < segs; i++) {
      ctx.quadraticCurveTo(r10 * Math.cos(a2), l5 * r10 * Math.sin(a2),
                           r9 * Math.cos(a1), l5 * r9 * Math.sin(a1));
      a1 += step; a2 += step;
    }
    ctx.closePath();
    ctx.globalAlpha = this.alpha * this.shadingAlpha;
    ctx.fillStyle = rgb(this.shadingColor);
    ctx.fill();
    ctx.restore();
  }
}

/* =========================== BisectingPlanes ============================= */
class BisectingPlanes {
  constructor(globe) {
    this.globe = globe;
    this.angle1 = 0;   // sun bisector angle (deg)
    this.angle2 = 0;   // earth-moon bisector angle (deg)
    this.show1 = true;
    this.show2 = true;
    this.size1 = 1.4; this.size2 = 1.4;
    this.color1 = 0xff7900;   // 16752640 orange (sun)
    this.color2 = 0x00a0ff;   // 41215 blue (earth-moon)
    this.alpha1 = 0.5; this.alpha2 = 0.5;
    this.lineAlpha1 = 0.8; this.lineAlpha2 = 0.8;
    this.thickness1 = 1; this.thickness2 = 1;
    // 12 fragments: {worldX,worldY,worldZ, screenZ, drawFn}
    this.fragments = [];
    for (let i = 0; i < 12; i++) this.fragments.push({ worldX: 0, worldY: 0, worldZ: 0, screenZ: 0, drawFn: null });
    this._fragIndex = 0;
    this._angles1 = null; this._angles2 = null;
  }

  // returns list of sector objects {angle, fragIdx}
  _positionPlane(angleRad) {
    const g = this.globe;
    const c = Math.cos(angleRad), s = Math.sin(angleRad);
    const l12 = t6 * c - t7 * s;
    const l13 = t8;
    let a = norm2pi(-Math.atan2(l12, l13));
    let list;
    if (viewerPhiDeg() === 0) {
      list = [{ angle: 0 }, { angle: PI / 2 }, { angle: PI }, { angle: 3 * PI / 2 }];
    } else {
      list = [{ angle: 0 }, { angle: PI / 2 }, { angle: PI }, { angle: 3 * PI / 2 },
              { angle: a }, { angle: norm2pi(a + PI) }];
    }
    list.sort((u, v) => u.angle - v.angle);
    for (let i = 0; i < list.length; i++) {
      const a0 = list[i].angle;
      const a1 = list[(i + 1) % list.length].angle;
      let mid;
      if (a1 > a0) mid = a0 + (a1 - a0) / 2;
      else mid = a0 + (a1 - a0 + 2 * PI) / 2;
      const sm = Math.sin(mid), cm = Math.cos(mid);
      const idx = this._fragIndex++;
      const frag = this.fragments[idx];
      frag.worldX = g.worldX + g.radius * c * cm;
      frag.worldY = g.worldY + -g.radius * s * cm;
      frag.worldZ = g.worldZ + g.radius * sm;
      list[i].fragIdx = idx;
    }
    return list;
  }

  onPreUpdate() {
    if (this.angle1 === this.angle2) this.angle1 += 0.000001;
    this._fragIndex = 0;
    for (const f of this.fragments) f.drawFn = null;
    this._angles1 = this._positionPlane(-this.angle1 * PI / 180);
    this._angles2 = this._positionPlane(-this.angle2 * PI / 180);
  }

  // after projection, assign draw closures based on show flags
  prepareDraw() {
    if (this.show1) this._assign(-this.angle1 * PI / 180, this._angles1, this.size1, this.color1, this.alpha1, this.thickness1, this.lineAlpha1);
    if (this.show2) this._assign(-this.angle2 * PI / 180, this._angles2, this.size2, this.color2, this.alpha2, this.thickness2, this.lineAlpha2);
  }

  _assign(planeAngle, angleList, size, color, alpha, thickness, lineAlpha) {
    const self = this;
    for (let i = 0; i < angleList.length; i++) {
      const a0 = angleList[i].angle;
      const a1 = angleList[(i + 1) % angleList.length].angle;
      const frag = this.fragments[angleList[i].fragIdx];
      frag.drawFn = (ctx) => self._drawSector(ctx, a0, a1, planeAngle, size, color, alpha, thickness, lineAlpha);
    }
  }

  _drawSector(ctx, a0, a1, planeAngle, size, color, alpha, thickness, lineAlpha) {
    const g = this.globe;
    const c = Math.cos(planeAngle), s = Math.sin(planeAngle);
    const rr = size * g.radius;
    const m28 = t0 * c - t1 * s, m29 = t2;
    const m30 = t3 * c - t4 * s, m31 = t5;
    const gx = CX + g.screenX, gy = CY + g.screenY;
    const SQ = Math.SQRT2 * rr;
    const corners = [
      { x: SQ * Math.cos(7 * PI / 4), z: SQ * Math.sin(7 * PI / 4) },
      { x: SQ * Math.cos(PI / 4),      z: SQ * Math.sin(PI / 4) },
      { x: SQ * Math.cos(3 * PI / 4),  z: SQ * Math.sin(3 * PI / 4) },
      { x: SQ * Math.cos(5 * PI / 4),  z: SQ * Math.sin(5 * PI / 4) },
    ];
    const toScreen = (px, pz) => [gx + m28 * px + m29 * pz, gy + m30 * px + m31 * pz];

    // square-edge intersection for a ray angle
    const edgePoint = (ang) => {
      const quad = ((Math.floor((ang + PI / 4) / (PI / 2)) % 4) + 4) % 4;
      if (quad === 1) return [rr / Math.tan(ang), rr];
      if (quad === 2) return [-rr, -rr * Math.tan(ang)];
      if (quad === 3) return [-rr / Math.tan(ang), -rr];
      return [rr, rr * Math.tan(ang)];
    };

    const arcPts = getArcPoints(0, 0, g.radius, a0, a1);
    const quad1 = ((Math.floor((a1 + PI / 4) / (PI / 2)) % 4) + 4) % 4;
    const quad0 = ((Math.floor((a0 + PI / 4) / (PI / 2)) % 4) + 4) % 4;
    const [e14, e15] = edgePoint(a1);
    const [e12, e13] = edgePoint(a0);
    const nCorners = (((quad1 - quad0) % 4) + 4) % 4;

    // fill path
    ctx.beginPath();
    let [sx, sy] = toScreen(arcPts[0].ax, arcPts[0].az);
    ctx.moveTo(sx, sy);
    const arcScreen = [[sx, sy]];
    for (let k = 1; k < arcPts.length; k++) {
      const pt = arcPts[k];
      const [ccx, ccy] = toScreen(pt.cx, pt.cz);
      const [aax, aay] = toScreen(pt.ax, pt.az);
      ctx.quadraticCurveTo(ccx, ccy, aax, aay);
      arcScreen.push([ccx, ccy, aax, aay]);
    }
    let [p14x, p14y] = toScreen(e14, e15);
    ctx.lineTo(p14x, p14y);
    for (let k = 0; k < nCorners; k++) {
      const cc = corners[(((quad1 - k) % 4) + 4) % 4];
      const [cx2, cy2] = toScreen(cc.x, cc.z);
      ctx.lineTo(cx2, cy2);
    }
    const [p12x, p12y] = toScreen(e12, e13);
    ctx.lineTo(p12x, p12y);
    ctx.lineTo(sx, sy);
    ctx.closePath();

    ctx.globalAlpha = alpha;
    ctx.fillStyle = rgb(color);
    ctx.fill();

    // stroke the (most visible) outer rounded arc edge only
    if (lineAlpha > 0) {
      ctx.beginPath();
      ctx.moveTo(arcScreen[0][0], arcScreen[0][1]);
      for (let k = 1; k < arcScreen.length; k++) {
        ctx.quadraticCurveTo(arcScreen[k][0], arcScreen[k][1], arcScreen[k][2], arcScreen[k][3]);
      }
      ctx.globalAlpha = lineAlpha;
      ctx.lineWidth = thickness || 1;
      ctx.strokeStyle = rgb(color);
      ctx.stroke();
    }
    ctx.globalAlpha = 1;
  }
}

// quadratic-arc tessellation (BisectingPlanesForGlobe3D.getArcPoints)
function getArcPoints(cx, cz, r, a0, a1) {
  const out = [];
  a0 = norm2pi(a0);
  a1 = norm2pi(a1);
  let span = a1 - a0;
  if (span < 0) span = 2 * PI + span;
  const n = Math.ceil(span / 0.4);
  const seg = span / n;
  const half = seg / 2;
  const rr = r / Math.cos(half);
  let a = a0, ah = a0 - half;
  out.push({ ax: cx + r * Math.cos(a0), az: cz + r * Math.sin(a0) });
  for (let i = 0; i < n; i++) {
    a += seg; ah += seg;
    out.push({
      cx: cx + rr * Math.cos(ah), cz: cz + rr * Math.sin(ah),
      ax: cx + r * Math.cos(a),   az: cz + r * Math.sin(a),
    });
  }
  return out;
}

/* ============================= OrbitalPlane ============================== */
class OrbitalPlane {
  constructor(earth, moon) {
    this.earth = earth;
    this.moon = moon;
    this.sunAngle = 0;
    this.moonAngle = 0;
    this.showSunLines = false;
    this.showEarthMoonLine = false;
    // 3 fragments {worldX,worldY,worldZ,screenZ, band:{y0,y1}}
    this.fragments = [
      { worldX: 0, worldY: 0, worldZ: 0, screenZ: 0, band: null },
      { worldX: 0, worldY: 0, worldZ: 0, screenZ: 0, band: null },
      { worldX: 0, worldY: 0, worldZ: 0, screenZ: 0, band: null },
    ];
  }

  onPreUpdate() {
    const e = this.earth;
    let p = worldOf(e.screenX, e.screenY, e.screenZ - e.screenRadius);
    this.fragments[0].worldX = p.x; this.fragments[0].worldY = p.y; this.fragments[0].worldZ = p.z;
    const c8 = Math.cos(vPhi), s9 = Math.sin(vPhi);
    const globes = [this.earth, this.moon];
    for (let i = 0; i < globes.length; i++) {
      const g = globes[i];
      p = worldOf(g.screenX, g.screenY - g.screenRadius * s9, g.screenZ + g.screenRadius * c8);
      this.fragments[i + 1].worldX = p.x;
      this.fragments[i + 1].worldY = p.y;
      this.fragments[i + 1].worldZ = p.z;
    }
  }

  // assign clip bands (after globes are projected) -- mirrors onPostUpdate masks
  prepareDraw() {
    const h = SCENE_H / 2;
    let top = viewerPhiDeg() > 0 ? -h : h;
    const sorted = [this.earth, this.moon].slice().sort((a, b) => a.screenZ - b.screenZ);
    let y0 = top;
    for (let i = 0; i < 2; i++) {
      const y1 = sorted[i].screenY;
      this.fragments[i].band = { y0, y1 };
      y0 = y1;
    }
    const yEnd = viewerPhiDeg() > 0 ? h : -h;
    this.fragments[2].band = { y0, y1: yEnd };
  }

  drawFragment(ctx, frag) {
    if (!frag.band) return;
    const b = frag.band;
    const yTop = Math.min(b.y0, b.y1), yBot = Math.max(b.y0, b.y1);
    ctx.save();
    ctx.beginPath();
    ctx.rect(CX - SCENE_W / 2, CY + yTop, SCENE_W, yBot - yTop);
    ctx.clip();
    ctx.translate(CX, CY);
    ctx.scale(1, Math.sin(vPhi));         // PlaneRotator scaleY = sin(viewerPhi)
    ctx.rotate(viewerThetaDeg() * PI / 180); // PlaneRotator rotation = viewerTheta (deg)
    this._drawArt(ctx);
    ctx.restore();
  }

  // MBDOrbitalPlane.receiveData drawing (art centred at earth / plane origin)
  _drawArt(ctx) {
    const mR = this.moonAngle * PI / 180, sR = this.sunAngle * PI / 180;
    const sinM = Math.sin(mR), cosM = Math.cos(mR);
    const sinS = Math.sin(sR), cosS = Math.cos(sR);

    // earth-moon line (behind orbit)
    if (this.showEarthMoonLine) {
      ctx.beginPath();
      ctx.moveTo(41 * sinM, 41 * cosM);
      ctx.lineTo(199 * sinM, 199 * cosM);
      ctx.globalAlpha = 0.6;
      ctx.lineWidth = 2;
      ctx.lineCap = 'round';
      ctx.strokeStyle = rgb(0x00a0ff);
      ctx.stroke();
      ctx.globalAlpha = 1;
    }

    // orbit ring (assets/orbit.svg) rotated by (-moonAngle + 83)
    if (imgOrbit.complete && imgOrbit.naturalWidth) {
      ctx.save();
      ctx.rotate((-this.moonAngle + 83) * PI / 180);
      ctx.drawImage(imgOrbit, -ORBIT_OX, -ORBIT_OY);
      ctx.restore();
    }

    // sun-direction arrows (assets/sun-arrow.svg)
    if (this.showSunLines && imgArrow.complete && imgArrow.naturalWidth) {
      // moon arrow
      this._drawArrow(ctx, 220 * sinM + 32 * sinS, 220 * cosM + 32 * cosS, -this.sunAngle);
      // earth arrow
      this._drawArrow(ctx, 64 * sinS, 64 * cosS, -this.sunAngle);
    }
  }

  _drawArrow(ctx, x, y, rotDeg) {
    ctx.save();
    ctx.translate(x, y);
    ctx.rotate(rotDeg * PI / 180);
    ctx.drawImage(imgArrow, -ARROW_OX, -ARROW_OY);
    ctx.restore();
  }
}

/* =============================== PhaseDisc ============================== */
class PhaseDisc {
  constructor(radius) {
    this.radius = radius;
    this.darkColor = 0x404040;
    this.lightColor = 0xe0e0e0;
    this.lineColor = 0x202020;
    this.lineAlpha = 0.3;
    this.lineThickness = 1;
    this.phaseAngle = 0;
  }
  setPhaseAngle(a) { this.phaseAngle = norm2pi(a); }

  draw(ctx, cx, cy) {
    const R = this.radius;
    const pa = this.phaseAngle;
    const sgn = pa < PI ? -1 : 1;
    const segs = 4;
    const l4 = R * Math.cos(pa);
    const step = PI / segs;
    const half = step / 2;
    const r7 = R / Math.cos(half);
    const l8 = l4 / Math.cos(half);

    ctx.save();
    ctx.translate(cx, cy);

    const buildHalf = (edgeSign) => {
      // edgeSign: -1 for dark's outer half sign handling, matches AS sin sign
      ctx.beginPath();
      ctx.moveTo(0, -R);
      for (let i = 1; i <= segs; i++) {
        const a = i * step;
        const ex = edgeSign * R * Math.sin(a);
        const ey = -R * Math.cos(a);
        const ah = a - half;
        const cxp = edgeSign * r7 * Math.sin(ah);
        const cyp = -r7 * Math.cos(ah);
        ctx.quadraticCurveTo(sgn * cxp, cyp, sgn * ex, ey);
      }
      for (let i = segs - 1; i >= 0; i--) {
        const a = i * step;
        const ex = l4 * Math.sin(a);
        const ey = -R * Math.cos(a);
        const ah = a + half;
        const cxp = l8 * Math.sin(ah);
        const cyp = -r7 * Math.cos(ah);
        ctx.quadraticCurveTo(sgn * cxp, cyp, sgn * ex, ey);
      }
      ctx.closePath();
    };

    // dark area
    buildHalf(1);
    ctx.fillStyle = rgb(this.darkColor);
    ctx.fill();
    ctx.globalAlpha = this.lineAlpha;
    ctx.lineWidth = this.lineThickness;
    ctx.strokeStyle = rgb(this.lineColor);
    ctx.stroke();
    ctx.globalAlpha = 1;

    // light area
    buildHalf(-1);
    ctx.fillStyle = rgb(this.lightColor);
    ctx.fill();
    ctx.globalAlpha = this.lineAlpha;
    ctx.strokeStyle = rgb(this.lineColor);
    ctx.stroke();
    ctx.globalAlpha = 1;

    ctx.restore();
  }
}

/* =============================== CubicEaser ============================= */
// Faithful port of CubicEaser (used for the perspective slew).
class CubicEaser {
  constructor(v) { this.slope0 = 0; this.slope1 = 0; this.setTarget(0, v, 1, v); }
  setTarget(t0, v0, t1, v1) {
    this.slope0 = 0;
    this.pts = [{ x: t0, y: v0 }, { x: t1, y: v1 }];
    this.targetValue = v1;
    this._compute();
  }
  _compute() {
    const pts = this.pts.slice().sort((a, b) => a.x - b.x);
    const n = pts.length, last = n - 1, sec = n - 2;
    const s0 = this.slope0, s1 = this.slope1;
    const u = [], d2 = new Array(n);
    d2[0] = -0.5;
    u[0] = 3 / (pts[1].x - pts[0].x) * ((pts[1].y - pts[0].y) / (pts[1].x - pts[0].x) - s0);
    for (let i = 1; i < last; i++) {
      const sig = (pts[i].x - pts[i - 1].x) / (pts[i + 1].x - pts[i - 1].x);
      const p = sig * d2[i - 1] + 2;
      d2[i] = (sig - 1) / p;
      let uu = (pts[i + 1].y - pts[i].y) / (pts[i + 1].x - pts[i].x) - (pts[i].y - pts[i - 1].y) / (pts[i].x - pts[i - 1].x);
      u[i] = (6 * uu / (pts[i + 1].x - pts[i - 1].x) - sig * u[i - 1]) / p;
    }
    const qn = 0.5;
    const un = 3 / (pts[last].x - pts[sec].x) * (s1 - (pts[last].y - pts[sec].y) / (pts[last].x - pts[sec].x));
    d2[last] = (un - qn * u[sec]) / (qn * d2[sec] + 1);
    for (let k = sec; k >= 0; k--) d2[k] = d2[k] * d2[k + 1] + u[k];

    const params = [];
    for (let i = 0; i < last; i++) {
      const y0 = pts[i], y1 = pts[i + 1];
      const dd0 = d2[i], dd1 = d2[i + 1];
      const x0 = y0.x, x1 = y1.x, v0 = y0.y, v1 = y1.y;
      const h = x1 - x0;
      const a = (dd1 - dd0) / (6 * h);
      const b = (3 * x1 * dd0 - 3 * dd1 * x0) / (6 * h);
      const c = (-6 * v0 + 2 * x1 * dd1 * x0 - x1 * x1 * dd1 - 2 * x1 * dd0 * x0 + dd0 * x0 * x0 - 2 * x1 * x1 * dd0 + 6 * v1 + 2 * dd1 * x0 * x0) / (6 * h);
      const dparam = (-2 * dd1 * x1 * x0 * x0 + 2 * dd0 * x1 * x1 * x0 + dd1 * x1 * x1 * x0 - 6 * v1 * x0 + 6 * v0 * x1 - dd0 * x1 * x0 * x0) / (6 * h);
      params.push({ xUpper: x1, a, b, c, d: dparam });
    }
    this.params = params;
  }
  getValue(x) {
    const p = this.params;
    let i = 0;
    for (; i < p.length; i++) if (x < p[i].xUpper) break;
    if (i < p.length) return p[i].d + x * (p[i].c + x * (p[i].b + x * p[i].a));
    return this.targetValue;
  }
}

/* =============================== assets ================================= */
const imgOrbit = new Image();
const imgArrow = new Image();
// SVG internal-origin offsets (from the <g transform="translate(...)"> in each file)
const ORBIT_OX = 220.5, ORBIT_OY = 220.5;
const ARROW_OX = 23.6,  ARROW_OY = 0.5;

/* ============================ world objects ============================= */
const earth     = new Globe(EARTH_R, 12042998);
const earthBack = new Globe(EARTH_R, 12042998);
earthBack.earthBackHack = true;
const moon      = new Globe(MOON_R, 10526880);

const earthPlanes = new BisectingPlanes(earth);
const moonPlanes  = new BisectingPlanes(moon);
const orbital     = new OrbitalPlane(earth, moon);
const disc        = new PhaseDisc(21);

// transparency envelope constants (MainTimeline frame1)
const maxEarthAlpha = 1, minEarthAlpha = 0.08;
const maxEarthLineAlpha = 0, minEarthLineAlpha = 0.9;
const maxEarthPlanesAlpha1 = 0.5, minEarthPlanesAlpha1 = 0.05;
const maxEarthPlanesAlpha2 = 0.5, minEarthPlanesAlpha2 = 0.05;
const maxEarthPlanesLineAlpha1 = 0.8, minEarthPlanesLineAlpha1 = 0.15;
const maxEarthPlanesLineAlpha2 = 0.8, minEarthPlanesLineAlpha2 = 0.15;

/* ============================== sim state ============================== */
const state = {
  sunLines: false, sunBisectors: false, shadows: false,
  earthMoonLine: false, earthMoonBisectors: false, moonDisc: false,
  sunAngle: 270, moonAngle: 180, theta: 0, phi: 90, contrast: 0.65,
};

/* ============================ DOM references =========================== */
const $ = (id) => document.getElementById(id);
const sceneCanvas = $('scene-canvas');
const sceneCtx = sceneCanvas.getContext('2d');
const discCanvas = $('disc-canvas');
const discCtx = discCanvas.getContext('2d');

const cbSunLines = $('cb-sun-lines');
const cbSunBis   = $('cb-sun-bisectors');
const cbShadows  = $('cb-shadows');
const cbEMLine   = $('cb-earth-moon-line');
const cbEMBis    = $('cb-earth-moon-bisectors');
const cbMoonDisc = $('cb-moon-disc');
const contrastSlider = $('contrast-slider');
const sunAngleSlider = $('sun-angle-slider');
const moonAngleSlider = $('moon-angle-slider');
const thetaSlider = $('theta-slider');
const phiSlider = $('phi-slider');
const hideAllBtn = $('hide-all-btn');
const showAllBtn = $('show-all-btn');
const earthViewBtn = $('earth-view-btn');
const overheadViewBtn = $('overhead-view-btn');
const phaseReadout = $('phase-readout');
const phaseNameEl = $('phase-name');
const liveStatus = $('live-status');
const sceneDesc = $('scene-desc');

/* ============================ phase naming ============================= */
// MainTimeline.getPhaseNameFromAngle -- verbatim thresholds
function getPhaseNameFromAngle(angle) {
  angle = norm360(angle);
  const a = 5, b = 12;
  if (angle <= b) return 'New Moon';
  if (angle <= 90 - a) return 'Waxing Crescent';
  if (angle <= 90 + a) return 'First Quarter';
  if (angle <= 180 - b) return 'Waxing Gibbous';
  if (angle <= 180 + b) return 'Full Moon';
  if (angle <= 270 - a) return 'Waning Gibbous';
  if (angle <= 270 + a) return 'Third Quarter';
  if (angle <= 360 - b) return 'Waning Crescent';
  return 'New Moon';
}

/* ============================ update logic ============================= */
function updateTransparency() {
  let factor;
  if (moon.screenZ < 0) {
    const dist = Math.sqrt(moon.screenX * moon.screenX + moon.screenY * moon.screenY);
    const lo = SCALE * (earth.radius - moon.radius);
    const hi = SCALE * (earth.radius + moon.radius);
    factor = (dist - lo) / (hi - lo);
    if (factor < 0) factor = 0; else if (factor > 1) factor = 1;
  } else {
    factor = 1;
  }
  const lerp = (mn, mx) => mn + (mx - mn) * factor;
  earth.alpha = earthBack.alpha = minEarthAlpha + (maxEarthAlpha - minEarthAlpha) * factor;
  earth.lineAlpha = earthBack.lineAlpha = minEarthLineAlpha + (maxEarthLineAlpha - minEarthLineAlpha) * factor;
  earthPlanes.alpha1 = lerp(minEarthPlanesAlpha1, maxEarthPlanesAlpha1);
  earthPlanes.alpha2 = lerp(minEarthPlanesAlpha2, maxEarthPlanesAlpha2);
  earthPlanes.lineAlpha1 = lerp(minEarthPlanesLineAlpha1, maxEarthPlanesLineAlpha1);
  earthPlanes.lineAlpha2 = lerp(minEarthPlanesLineAlpha2, maxEarthPlanesLineAlpha2);
}

// The unified scene render (mirrors Scene3D.update + all postUpdate handlers)
function render() {
  calcSceneConstants();

  // preUpdate: planes + orbital compute fragment world positions
  earthPlanes.onPreUpdate();
  moonPlanes.onPreUpdate();
  orbital.onPreUpdate();

  // project every object to screen coords
  const objs = [];
  const projectGlobe = (g) => {
    const s = screenOf(g.worldX, g.worldY, g.worldZ);
    g.screenX = s.x; g.screenY = s.y; g.screenZ = s.z;
  };
  projectGlobe(earth); projectGlobe(earthBack); projectGlobe(moon);

  // prePostUpdate: transparency depends on projected moon
  updateTransparency();

  // globes
  objs.push({ z: earth.screenZ, kind: 'earth', obj: earth });
  objs.push({ z: earthBack.screenZ, kind: 'earthBack', obj: earthBack });
  objs.push({ z: moon.screenZ, kind: 'globe', obj: moon });

  // plane fragments
  earthPlanes.prepareDraw();
  moonPlanes.prepareDraw();
  for (const set of [earthPlanes, moonPlanes]) {
    for (const f of set.fragments) {
      const s = screenOf(f.worldX, f.worldY, f.worldZ);
      f.screenZ = s.z;
      if (f.drawFn) objs.push({ z: f.screenZ, kind: 'frag', frag: f });
    }
  }

  // orbital fragments
  orbital.prepareDraw();
  for (const f of orbital.fragments) {
    const s = screenOf(f.worldX, f.worldY, f.worldZ);
    f.screenZ = s.z;
    objs.push({ z: f.screenZ, kind: 'orbital', frag: f });
  }

  // depth sort (ascending screenZ -> far first). Keep earth after earthBack
  // (MainTimeline.onPostUpdate swaps so earth draws in front of earthBack).
  objs.sort((u, v) => u.z - v.z);
  const ie = objs.findIndex((o) => o.kind === 'earth');
  const ib = objs.findIndex((o) => o.kind === 'earthBack');
  if (ie < ib) { const tmp = objs[ie]; objs[ie] = objs[ib]; objs[ib] = tmp; }

  // draw
  const dpr = window.devicePixelRatio || 1;
  sceneCtx.setTransform(dpr, 0, 0, dpr, 0, 0);
  sceneCtx.clearRect(0, 0, SCENE_W, SCENE_H);
  sceneCtx.fillStyle = '#000';
  sceneCtx.fillRect(0, 0, SCENE_W, SCENE_H);

  for (const o of objs) {
    if (o.kind === 'earth' || o.kind === 'earthBack' || o.kind === 'globe') {
      o.obj.draw(sceneCtx);
    } else if (o.kind === 'frag') {
      if (o.frag.drawFn) o.frag.drawFn(sceneCtx);
    } else if (o.kind === 'orbital') {
      orbital.drawFragment(sceneCtx, o.frag);
    }
  }
  sceneCtx.globalAlpha = 1;
}

function updateDisc() {
  const diff = state.moonAngle - state.sunAngle;
  disc.setPhaseAngle(PI - diff * PI / 180);
  const name = getPhaseNameFromAngle(diff);
  phaseNameEl.textContent = name;
  drawDisc();
  return name;
}
function drawDisc() {
  const dpr = window.devicePixelRatio || 1;
  discCtx.setTransform(dpr, 0, 0, dpr, 0, 0);
  discCtx.clearRect(0, 0, discCanvas.width / dpr, discCanvas.height / dpr);
  disc.draw(discCtx, 30, 30);
}

/* --------- control -> state -> world, mirroring MainTimeline methods ------ */
function updateShowSunLines() {
  orbital.showSunLines = state.sunLines;
  updateHideShowButtons();
}
function updateSunBisectors() {
  earthPlanes.show1 = moonPlanes.show1 = state.sunBisectors;
  updateHideShowButtons();
}
function updateShowShadows() {
  earthBack.showShading = moon.showShading = earth.showShading = state.shadows;
  contrastSlider.disabled = !state.shadows;
  updateHideShowButtons();
}
function updateShowEarthMoonLine() {
  orbital.showEarthMoonLine = state.earthMoonLine;
  updateHideShowButtons();
}
function updateEarthMoonBisectors() {
  earthPlanes.show2 = moonPlanes.show2 = state.earthMoonBisectors;
  updateHideShowButtons();
}
function updateShowMoonDisc() {
  phaseReadout.hidden = !state.moonDisc;
  updateHideShowButtons();
}
function updateSunAngle() {
  earthPlanes.angle1 = state.sunAngle - 90;
  moonPlanes.angle1 = state.sunAngle - 90;
  moon.setSunDirection(state.sunAngle, 0);
  earth.setSunDirection(state.sunAngle, 0);
  earthBack.setSunDirection(state.sunAngle, 0);
  orbital.sunAngle = state.sunAngle;
  updateDisc();
}
function updateMoonAngle() {
  earthPlanes.angle2 = state.moonAngle - 90;
  moonPlanes.angle2 = state.moonAngle - 90;
  orbital.moonAngle = state.moonAngle;
  moon.worldX = MOON_DIST * Math.cos(state.moonAngle * PI / 180);
  moon.worldY = MOON_DIST * Math.sin(state.moonAngle * PI / 180);
  moon.worldZ = 0;
  moon.rotationDeg = state.moonAngle;
  updateDisc();
}
function updateContrast() {
  earthBack.shadingAlpha = earth.shadingAlpha = moon.shadingAlpha = state.contrast;
}

function updateHideShowButtons() {
  let count = 0;
  if (state.sunLines) count++;
  if (state.sunBisectors) count++;
  if (state.shadows) count++;
  if (state.earthMoonLine) count++;
  if (state.earthMoonBisectors) count++;
  if (state.moonDisc) count++;
  if (count === 6) { showAllBtn.disabled = true; hideAllBtn.disabled = false; }
  else if (count === 0) { showAllBtn.disabled = false; hideAllBtn.disabled = true; }
  else { showAllBtn.disabled = false; hideAllBtn.disabled = false; }
}

/* ============================ camera slew ============================= */
const slewEaser = new CubicEaser(0);
let slewMode = '';
let slewInitTime = 0, slewInitTheta = 0, slewInitPhi = 0, slewTargetTheta = 0, slewTargetPhi = 0;
let slewRAF = 0;
const prefersReduced = () => window.matchMedia('(prefers-reduced-motion: reduce)').matches;

function cancelSlew() {
  if (slewRAF) { cancelAnimationFrame(slewRAF); slewRAF = 0; }
  slewMode = '';
}
function slewTo(targetTheta, targetPhi, mode) {
  if (slewMode === mode) return;
  targetTheta = norm360(targetTheta);
  if (targetPhi > 90) targetPhi = 90; else if (targetPhi < -90) targetPhi = -90;
  const curTheta = norm360(viewerThetaDeg());
  const curPhi = viewerPhiDeg();
  const dT = targetTheta - curTheta;
  const dP = targetPhi - curPhi;
  if (Math.abs(dT) < 0.01 && Math.abs(dP) < 0.01) return;
  if (dT < -180) targetTheta += 360;
  else if (dT > 180) targetTheta -= 360;

  if (prefersReduced()) {
    // reduced motion: jump straight to the end state
    setViewer(targetTheta, targetPhi);
    state.theta = norm360(viewerThetaDeg());
    state.phi = viewerPhiDeg();
    syncPerspectiveSliders();
    render();
    announcePerspective();
    return;
  }

  slewInitTime = performance.now();
  slewInitTheta = curTheta;
  slewInitPhi = curPhi;
  slewTargetTheta = targetTheta;
  slewTargetPhi = targetPhi;
  slewMode = mode;
  slewEaser.setTarget(0, 0, 1, 1);
  if (!slewRAF) slewRAF = requestAnimationFrame(onSlewFrame);
}
function onSlewFrame() {
  let t = (performance.now() - slewInitTime) / SLEW_MS;
  if (t > 1) t = 1;
  const e = slewEaser.getValue(t);
  const th = norm360(slewInitTheta + e * (slewTargetTheta - slewInitTheta));
  let ph = slewInitPhi + e * (slewTargetPhi - slewInitPhi);
  if (ph > 90) ph = 90; else if (ph < -90) ph = -90;
  state.theta = th; state.phi = ph;
  setViewer(th, ph);
  syncPerspectiveSliders();
  render();
  if (t >= 1) { cancelSlew(); announcePerspective(); }
  else slewRAF = requestAnimationFrame(onSlewFrame);
}

function syncPerspectiveSliders() {
  thetaSlider.value = norm360(viewerThetaDeg()).toFixed(1);
  phiSlider.value = viewerPhiDeg().toFixed(1);
  setSliderAria(thetaSlider, `left/right ${Math.round(norm360(viewerThetaDeg()))} degrees`);
  setSliderAria(phiSlider, `up/down ${Math.round(viewerPhiDeg())} degrees`);
}

/* ========================= screen-reader narration ==================== */
function setSliderAria(el, text) { el.setAttribute('aria-valuetext', text); }

let announceTimer = 0;
function announce(msg) {
  // debounce to avoid flooding while dragging
  clearTimeout(announceTimer);
  announceTimer = setTimeout(() => { liveStatus.textContent = msg; }, 120);
}
function announcePerspective() {
  announce(`View rotated to left/right ${Math.round(norm360(state.theta))} degrees, up/down ${Math.round(state.phi)} degrees.`);
  updateSceneDescription();
}
function updateSceneDescription() {
  const diff = state.moonAngle - state.sunAngle;
  const phase = getPhaseNameFromAngle(diff);
  const shown = [];
  if (state.sunLines) shown.push('Sun direction arrows');
  if (state.sunBisectors) shown.push('Sun bisector planes');
  if (state.shadows) shown.push('day-night shadows');
  if (state.earthMoonLine) shown.push('Earth-Moon line');
  if (state.earthMoonBisectors) shown.push('Earth-Moon bisector planes');
  if (state.moonDisc) shown.push('moon phase disc');
  const shownText = shown.length ? shown.join(', ') : 'no construction steps';
  sceneDesc.textContent =
    `Three-dimensional view of the Earth, Moon, and Sun system. ` +
    `Sun direction ${Math.round(state.sunAngle)} degrees, Moon position ${Math.round(state.moonAngle)} degrees. ` +
    `Viewing angle: left/right ${Math.round(norm360(state.theta))} degrees, up/down ${Math.round(state.phi)} degrees. ` +
    `Currently showing ${shownText}. The Moon's phase for this geometry is ${phase}.`;
}

/* ============================== reset ================================= */
function resetSim() {
  state.sunLines = false; state.sunBisectors = false; state.shadows = false;
  state.earthMoonLine = false; state.earthMoonBisectors = false; state.moonDisc = false;
  state.sunAngle = 270; state.moonAngle = 180; state.theta = 0; state.phi = 90;
  state.contrast = 0.65;
  cancelSlew();

  cbSunLines.checked = false;
  cbSunBis.checked = false;
  cbShadows.checked = false;
  cbEMLine.checked = false;
  cbEMBis.checked = false;
  cbMoonDisc.checked = false;
  contrastSlider.value = 0.65;
  sunAngleSlider.value = 270;
  moonAngleSlider.value = 180;
  thetaSlider.value = 0;
  phiSlider.value = 90;

  setViewer(state.theta, state.phi);

  updateShowSunLines();
  updateSunBisectors();
  updateShowShadows();
  updateShowEarthMoonLine();
  updateEarthMoonBisectors();
  updateShowMoonDisc();
  updateSunAngle();
  updateMoonAngle();
  updateContrast();

  syncAllAria();
  render();
  updateSceneDescription();
}

function syncAllAria() {
  setSliderAria(sunAngleSlider, `Sun direction ${Math.round(state.sunAngle)} degrees`);
  setSliderAria(moonAngleSlider, `Moon position ${Math.round(state.moonAngle)} degrees`);
  setSliderAria(thetaSlider, `left/right ${Math.round(norm360(state.theta))} degrees`);
  setSliderAria(phiSlider, `up/down ${Math.round(state.phi)} degrees`);
  setSliderAria(contrastSlider, `Shadow contrast ${Math.round(state.contrast * 100)} percent`);
}

/* ============================ event wiring =========================== */
function wireCheckbox(cb, key, updateFn, label) {
  cb.addEventListener('change', () => {
    state[key] = cb.checked;
    updateFn();
    render();
    updateSceneDescription();
    announce(`${label} ${cb.checked ? 'shown' : 'hidden'}.`);
  });
}
wireCheckbox(cbSunLines, 'sunLines', updateShowSunLines, 'Sun direction');
wireCheckbox(cbSunBis, 'sunBisectors', updateSunBisectors, 'Sun bisectors');
wireCheckbox(cbShadows, 'shadows', updateShowShadows, 'Shadows');
wireCheckbox(cbEMLine, 'earthMoonLine', updateShowEarthMoonLine, 'Earth-Moon line');
wireCheckbox(cbEMBis, 'earthMoonBisectors', updateEarthMoonBisectors, 'Earth-Moon bisectors');
cbMoonDisc.addEventListener('change', () => {
  state.moonDisc = cbMoonDisc.checked;
  updateShowMoonDisc();
  render();
  updateSceneDescription();
  if (cbMoonDisc.checked) announce(`Moon phase disc shown. Current phase ${phaseNameEl.textContent}.`);
  else announce('Moon phase disc hidden.');
});

hideAllBtn.addEventListener('click', () => {
  cbSunLines.checked = cbSunBis.checked = cbShadows.checked = false;
  cbEMLine.checked = cbEMBis.checked = cbMoonDisc.checked = false;
  state.sunLines = state.sunBisectors = state.shadows = false;
  state.earthMoonLine = state.earthMoonBisectors = state.moonDisc = false;
  updateShowSunLines(); updateSunBisectors(); updateShowShadows();
  updateShowEarthMoonLine(); updateEarthMoonBisectors(); updateShowMoonDisc();
  render(); updateSceneDescription();
  announce('All construction steps hidden.');
});
showAllBtn.addEventListener('click', () => {
  cbSunLines.checked = cbSunBis.checked = cbShadows.checked = true;
  cbEMLine.checked = cbEMBis.checked = cbMoonDisc.checked = true;
  state.sunLines = state.sunBisectors = state.shadows = true;
  state.earthMoonLine = state.earthMoonBisectors = state.moonDisc = true;
  updateShowSunLines(); updateSunBisectors(); updateShowShadows();
  updateShowEarthMoonLine(); updateEarthMoonBisectors(); updateShowMoonDisc();
  render(); updateSceneDescription();
  announce('All construction steps shown.');
});

contrastSlider.addEventListener('input', () => {
  state.contrast = parseFloat(contrastSlider.value);
  setSliderAria(contrastSlider, `Shadow contrast ${Math.round(state.contrast * 100)} percent`);
  updateContrast();
  render();
});
contrastSlider.addEventListener('change', () => {
  announce(`Shadow contrast ${Math.round(state.contrast * 100)} percent.`);
});

function wireAngleSlider(slider, key, updateFn, label, cyclic) {
  slider.addEventListener('input', () => {
    let v = parseFloat(slider.value);
    state[key] = v;
    setSliderAria(slider, `${label} ${Math.round(v)} degrees`);
    updateFn();
    render();
  });
  slider.addEventListener('change', () => {
    updateSceneDescription();
    announce(`${label} ${Math.round(state[key])} degrees. Moon phase ${phaseNameEl.textContent}.`);
  });
  // mouse wheel adjusts the focused slider
  slider.addEventListener('wheel', (e) => {
    if (document.activeElement !== slider) return;
    e.preventDefault();
    const stepv = parseFloat(slider.step) || 1;
    let v = parseFloat(slider.value) + (e.deltaY < 0 ? stepv * 10 : -stepv * 10);
    const min = parseFloat(slider.min), max = parseFloat(slider.max);
    if (v < min) v = cyclic ? max : min;
    if (v > max) v = cyclic ? min : max;
    slider.value = v.toFixed(1);
    slider.dispatchEvent(new Event('input', { bubbles: true }));
    slider.dispatchEvent(new Event('change', { bubbles: true }));
  }, { passive: false });
}
wireAngleSlider(sunAngleSlider, 'sunAngle', updateSunAngle, 'Sun direction', true);
wireAngleSlider(moonAngleSlider, 'moonAngle', updateMoonAngle, 'Moon position', true);

// perspective sliders drive the viewer directly (updatePerspective)
function wirePerspSlider(slider, key, label) {
  slider.addEventListener('input', () => {
    cancelSlew();
    state[key] = parseFloat(slider.value);
    setViewer(state.theta, state.phi);
    setSliderAria(slider, `${label} ${Math.round(parseFloat(slider.value))} degrees`);
    render();
  });
  slider.addEventListener('change', () => {
    updateSceneDescription();
    announce(`${label} ${Math.round(parseFloat(slider.value))} degrees.`);
  });
  slider.addEventListener('wheel', (e) => {
    if (document.activeElement !== slider) return;
    e.preventDefault();
    const stepv = parseFloat(slider.step) || 1;
    let v = parseFloat(slider.value) + (e.deltaY < 0 ? stepv * 10 : -stepv * 10);
    const min = parseFloat(slider.min), max = parseFloat(slider.max);
    if (v < min) v = min; if (v > max) v = max;
    slider.value = v.toFixed(1);
    slider.dispatchEvent(new Event('input', { bubbles: true }));
    slider.dispatchEvent(new Event('change', { bubbles: true }));
  }, { passive: false });
}
wirePerspSlider(thetaSlider, 'theta', 'left/right');
wirePerspSlider(phiSlider, 'phi', 'up/down');

earthViewBtn.addEventListener('click', () => {
  slewTo(180 + state.moonAngle, 0, 'earth');
});
overheadViewBtn.addEventListener('click', () => {
  slewTo(90 + state.sunAngle, 90, 'overhead');
});

/* --------------------- canvas drag + keyboard rotate ------------------- */
let dragging = false, dragInitTheta = 0, dragInitPhi = 0, dragInitX = 0, dragInitY = 0;

function canvasToScene(ev) {
  const rect = sceneCanvas.getBoundingClientRect();
  const scaleX = SCENE_W / rect.width;
  const scaleY = SCENE_H / rect.height;
  const x = (ev.clientX - rect.left) * scaleX - CX;
  const y = (ev.clientY - rect.top) * scaleY - CY;
  return { x, y };
}
sceneCanvas.addEventListener('pointerdown', (ev) => {
  sceneCanvas.focus();
  cancelSlew();
  dragging = true;
  sceneCanvas.setPointerCapture(ev.pointerId);
  const p = canvasToScene(ev);
  dragInitX = p.x; dragInitY = p.y;
  dragInitTheta = vTheta; dragInitPhi = vPhi;   // internal radians
  ev.preventDefault();
});
sceneCanvas.addEventListener('pointermove', (ev) => {
  if (!dragging) return;
  const p = canvasToScene(ev);
  const thetaDeg = 180 / PI * (dragInitTheta - (p.x - dragInitX) / SCALE) - 180;
  const phiDeg = 180 / PI * (dragInitPhi + (p.y - dragInitY) / SCALE);
  setViewer(thetaDeg, phiDeg);
  state.theta = norm360(viewerThetaDeg());
  state.phi = viewerPhiDeg();
  syncPerspectiveSliders();
  render();
  ev.preventDefault();
});
function endDrag(ev) {
  if (!dragging) return;
  dragging = false;
  try { sceneCanvas.releasePointerCapture(ev.pointerId); } catch (e) {}
  updateSceneDescription();
  announcePerspective();
}
sceneCanvas.addEventListener('pointerup', endDrag);
sceneCanvas.addEventListener('pointercancel', endDrag);

sceneCanvas.addEventListener('keydown', (ev) => {
  let handled = true;
  const bigStep = ev.shiftKey ? 15 : 5;
  let th = norm360(viewerThetaDeg());
  let ph = viewerPhiDeg();
  switch (ev.key) {
    case 'ArrowLeft':  th = norm360(th - bigStep); break;
    case 'ArrowRight': th = norm360(th + bigStep); break;
    case 'ArrowUp':    ph = Math.min(90, ph + bigStep); break;
    case 'ArrowDown':  ph = Math.max(-90, ph - bigStep); break;
    case 'Home':       th = 0; break;
    case 'End':        ph = 90; break;
    default: handled = false;
  }
  if (!handled) return;
  ev.preventDefault();
  cancelSlew();
  state.theta = th; state.phi = ph;
  setViewer(th, ph);
  syncPerspectiveSliders();
  render();
  announcePerspective();
});

/* ---------------------------- masthead reset --------------------------- */
document.addEventListener('sim-reset', () => {
  resetSim();
  announce('Simulation reset to its initial state.');
});

/* =============================== boot ================================= */
async function loadData() {
  const [shore, moonLayers] = await Promise.all([
    fetch('assets/earth-shore.json').then((r) => r.json()),
    fetch('assets/moon-layers.json').then((r) => r.json()),
  ]);
  // earth: single coastline layer (Globe constructor: color 12097379, alpha 1)
  earth.layers = [{ color: 12097379, alpha: 1, fills: shore }];
  earthBack.layers = [{ color: 12097379, alpha: 1, fills: shore }];
  // moon: maria layers from moonLayersData (alpha 0.1)
  moon.layers = moonLayers.map((l) => ({ color: l.color, alpha: l.alpha, fills: l.fills }));
}

function loadImages() {
  return new Promise((resolve) => {
    let left = 2;
    const done = () => { if (--left <= 0) resolve(); };
    imgOrbit.onload = done; imgOrbit.onerror = done;
    imgArrow.onload = done; imgArrow.onerror = done;
    imgOrbit.src = 'assets/orbit.svg';
    imgArrow.src = 'assets/sun-arrow.svg';
  });
}

function setupHiDPI() {
  const dpr = window.devicePixelRatio || 1;
  sceneCanvas.width = SCENE_W * dpr;
  sceneCanvas.height = SCENE_H * dpr;
  discCanvas.width = 60 * dpr;
  discCanvas.height = 60 * dpr;
}

async function boot() {
  setupHiDPI();
  await loadData();
  await loadImages();
  resetSim();
  // re-render once more in case images finished after first render
  render();
  updateDisc();
}
boot();

window.addEventListener('resize', () => {
  setupHiDPI();
  render();
  drawDisc();
});
