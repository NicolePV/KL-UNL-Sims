/* ===========================================================================
   KL-UNL Globe (`kl-unl-globe.js`)
   ---------------------------------------------------------------------------
   Shared little-Earth disk for celestial-sphere simulations.

   Contains precession and sidereal rotation matrices,
   coastline mask (`buildShorePath`), and night-side terminator
   (`buildNightSide`). Coastline polygons come from `kl-unl-earth-shores.js`.

   Scratch matrices on instance `c`:
     p0..p8  — precession (obliquity-aware)
     r0..r8  — Earth rotation (sidereal time folded in)
     q0..q8  — composite q = p · r used when projecting shores to the disk

   Sims supply water/land artwork and call `buildShorePath` / `buildNightSide`
   at draw time; this module does not load images.
   =========================================================================== */

import { pMod }            from './kl-unl-utils.js';
import { D2R, PI, TWO_PI } from './kl-unl-celestial-sphere.js';
import { EARTH_SHORES }    from './kl-unl-earth-shores.js';

export const GLOBE_OBLIQUITY_COS = 0.91706;  /** cosine of obliquity 23.5° */
export const GLOBE_OBLIQUITY_SIN = 0.39875;  /** sine   of obliquity 23.5° */

/** Default globe disk radius in screen units (shore / shading space). */
export const DEFAULT_GLOBE_RADIUS = 40;

/**
 * Little Earth at the celestial-sphere origin (`GlobeComponentClass`).
 * Requires a {@link CelestialSphere} for `parse`, `CtoSz`/`WtoSz`, `sTime`,
 * and celestial→screen `c.b*`.
 */
export class GlobeComponent {
  /**
   * @param {import('./kl-unl-celestial-sphere.js').CelestialSphere} sphere -
   *   Parent sphere (orientation, sidereal time, projection matrices).
   * @param {object} [opts]
   * @param {number} [opts.radius=DEFAULT_GLOBE_RADIUS] - Disk radius for shores/night.
   * @param {Array<Array<{x:number,y:number,z:number}>>} [opts.shoreData=EARTH_SHORES] -
   *   Closed coastline polygons in celestial Cartesian.
   */
  constructor(sphere, opts = {}) {
    this.sphere    = sphere;
    this.c         = {};
    this.radius    = opts.radius != null ? opts.radius : DEFAULT_GLOBE_RADIUS;
    this.shoreData = opts.shoreData != null ? opts.shoreData : EARTH_SHORES;
    this.sunDir    = null;
    this.setPrecessionAngle(0);
    this.setRotationAngle(0);
  }

  /**
   * Set the Sun direction used by {@link GlobeComponent#buildNightSide}
   * (AS `p.setSunDirection`).
   * @param {object} arg - Point spec accepted by `sphere.parse` (`{ra,dec}`, etc.).
   */
  setSunDirection(arg) {
    this.sunDir = this.sphere.parse(arg);
  }

  /**
   * Precession / obliquity frame (AS `p.setPrecessionAngle`).
   * Uses {@link GLOBE_OBLIQUITY_COS} / {@link GLOBE_OBLIQUITY_SIN}.
   * @param {number} deg - Precession angle in degrees.
   */
  setPrecessionAngle(deg) {
    this.precessionAngle = deg;
    const a  = deg * D2R;
    const cp = Math.cos(a);
    const sp = Math.sin(a);
    const c  = this.c;
    c.p0     =  cp;
    c.p1     = -sp;
    c.p3     =  sp * GLOBE_OBLIQUITY_COS;
    c.p4     =  cp * GLOBE_OBLIQUITY_COS;
    c.p5     =      -GLOBE_OBLIQUITY_SIN;
    c.p6     =  sp * GLOBE_OBLIQUITY_SIN;
    c.p7     =  cp * GLOBE_OBLIQUITY_SIN;
    c.p8     =       GLOBE_OBLIQUITY_COS;
    this.doQ();
  }

  /**
   * Earth rotation about the polar axis (AS `p.setRotationAngle`).
   * Sidereal time from `sphere.sTime` is folded into the angle.
   * @param {number} deg - Rotation angle in degrees (in addition to sidereal time).
   */
  setRotationAngle(deg) {
    this.rotationAngle = deg;
    const a  = this.sphere.sTime + deg * D2R;
    const ca = Math.cos(a);
    const sa = Math.sin(a);
    const c  = this.c;
    c.r0     =  ca;
    c.r1     = -sa;
    c.r3     =  sa * GLOBE_OBLIQUITY_COS;
    c.r4     =  ca * GLOBE_OBLIQUITY_COS;
    c.r5     =       GLOBE_OBLIQUITY_SIN;
    c.r6     = -sa * GLOBE_OBLIQUITY_SIN;
    c.r7     = -ca * GLOBE_OBLIQUITY_SIN;
    c.r8     =       GLOBE_OBLIQUITY_COS;
    this.doQ();
  }

  /**
   * Compose `q = p · r` (shared tail of setPrecessionAngle / setRotationAngle).
   * No-op until both `p*` and `r*` have been written.
   */
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

  /**
   * Coastline outline for clipping the land disk (AS `p.update`).
   * Follows the limb when a polygon segment passes behind the globe.
   * @returns {Path2D} Closed shore path(s) in globe-local screen units.
   */
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

    const path    = new Path2D();
    const s       = this.shoreData;
    const r       = this.radius;
    const d       = 1.5 * r;
    const minStep = 2 * Math.acos((r * 1.1) / d);
    let angleLast = 0;

    for (let i = 0; i < s.length; i++) {
      const poly = s[i];
      const pl   = poly.length;

      // First vertex whose predecessor was also on the near side.
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
            let da = pMod(angleNow - angleLast, TWO_PI);
            let n, step;
            if (da > PI) {
              da   = TWO_PI - da;
              n    = Math.ceil(da / minStep);
              step = -da / n;
            } else {
              n    = Math.ceil(da / minStep);
              step =  da / n;
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

  /**
   * Night-side crescent path and orientation (AS `p.updateShading`).
   * @returns {{path: Path2D, rotation: number}|null} Terminator in globe-local
   *   units, or `null` if no sun direction has been set.
   */
  buildNightSide() {
    const sd = this.sunDir;
    if (!sd) return null;
    const sp = {};
    if (sd.sys === 1) this.sphere.CtoSz(sd, sp);
    else this.sphere.WtoSz(sd, sp);

    const rotation = Math.atan2(sp.x, -sp.y);
    const s        = -sp.z / Math.sqrt(sp.x * sp.x + sp.y * sp.y + sp.z * sp.z);

    const hnp      = 4;
    const step     = PI / hnp;
    const halfStep = step / 2;
    const r        = this.radius;
    const cr       = r / Math.cos(halfStep);

    const path     = new Path2D();
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
                             r * Math.cos(aAngle), s *  r * Math.sin(aAngle));
      aAngle += step; cAngle += step;
    }
    path.closePath();
    return { path, rotation };
  }
}
