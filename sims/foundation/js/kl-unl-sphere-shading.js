/* ===========================================================================
   KL-UNL Sphere Shading (`kl-unl-sphere-shading.js`)
   ---------------------------------------------------------------------------
   Shared Flash celestial-sphere shading and horizon-plane primitives.

   Ports of ActionScript library modules used by multiple simulations:
     - `6 CS Shading.as`     — hemisphere clip masks M1–M4
     - `CSGradientDisk.as`   — unit radial gradient disk (registration r=100)
     - `5 CS Horizon Plane.as` — scale / rotate / side for the tangent plane

   Distinct from `drawGlass` in `kl-unl-celestial-sphere.js` (frosted CSC
   greys). This module owns the AS gradient-disk bowl and horizon masks.

   Full Scene / depth-stack orchestrators stay in individual sims until a
   shared render order is justified.
   =========================================================================== */

import { D2R, R2D, TWO_PI } from './kl-unl-celestial-sphere.js';
import { hexToRGBA }        from './kl-unl-utils.js';

/**
 * Build the four hemisphere clip paths used by Flash sphere shading
 * (AS `p.updateMasks` in "6 CS Shading.as").
 *
 *   M1 — above the near half of the horizon ellipse
 *   M2 — below the near half
 *   M3 — above the far half
 *   M4 — below the far half
 *
 * @param {import('./kl-unl-celestial-sphere.js').CelestialSphere} sphere
 * @returns {{M1: Path2D, M2: Path2D, M3: Path2D, M4: Path2D}|null}
 *   Null when sphere radius is not yet set.
 */
export function buildHorizonMasks(sphere) {
  const r = sphere.c.r;
  if (!r) return null;

  const d    = 1.2 * r;                 // AS: r = 100, d = 120, scaled by c.r
  const s    = Math.sin(sphere.phi);
  const hnp  = 4;
  const step = Math.PI / hnp;
  const half = step / 2;
  const cr   = r / Math.cos(half);
  const sax  = r, say = s * r, scx = cr, scy = s * cr;

  /** @param {number} dy - Slab half (+d or -d). @param {1|-1} sgn - Near/far ellipse. */
  function build(dy, sgn) {
    const p = new Path2D();
    p.moveTo(d, dy);
    p.lineTo(d,  0);
    p.lineTo(r,  0);
    let aAngle = step, cAngle = aAngle - half;
    for (let i = 0; i < hnp; i++) {
      p.quadraticCurveTo(
        scx * Math.cos(cAngle), sgn * scy * Math.sin(cAngle),
        sax * Math.cos(aAngle), sgn * say * Math.sin(aAngle)
      );
      aAngle += step;
      cAngle += step;
    }
    p.lineTo(-d,  0);
    p.lineTo(-d, dy);
    p.lineTo( d, dy);
    p.closePath();
    return p;
  }

  return {
    M1: build(-d,  1),
    M2: build( d,  1),
    M3: build(-d, -1),
    M4: build( d, -1)
  };
}

/**
 * Run `fn` inside `ctx.clip(mask)` (Flash `setMask`). No-op clip when mask
 * is null/undefined.
 * @param {CanvasRenderingContext2D} ctx
 * @param {Path2D|null|undefined} mask
 * @param {function(): void} fn
 */
export function withClip(ctx, mask, fn) {
  if (!mask) { fn(); return; }
  ctx.save();
  ctx.clip(mask);
  fn();
  ctx.restore();
}

/**
 * Draw a CSGradientDisk in Flash registration space (radius 100).
 * Caller typically `ctx.scale(sphere.c.r / 100, …)` first.
 *
 * AS defaults: inner (16711680, 80), outer (16711935, 40) — red / magenta.
 * Celhor uses white→black at alpha 0 / 0.20.
 *
 * @param {CanvasRenderingContext2D} ctx
 * @param {{innerColor?: string, innerAlpha?: number, outerColor?: string, outerAlpha?: number}} [init]
 *   Hex colors; alphas on 0–1 scale.
 */
export function drawGradientDisk(ctx, init = {}) {
  const innerColor = init.innerColor ?? '#ff0000';
  const innerAlpha = init.innerAlpha ?? 0.80;
  const outerColor = init.outerColor ?? '#ff00ff';
  const outerAlpha = init.outerAlpha ?? 0.40;

  const grad = ctx.createRadialGradient(0, 0, 0, 0, 0, 100);
  grad.addColorStop(0, hexToRGBA(innerColor, innerAlpha));
  grad.addColorStop(1, hexToRGBA(outerColor, outerAlpha));
  ctx.fillStyle = grad;
  ctx.beginPath();
  ctx.arc(0, 0, 100, 0, TWO_PI);
  ctx.fill();
}

/**
 * Horizon-plane screen transform from viewer theta / phi
 * (AS "5 CS Horizon Plane.as").
 *
 * @param {import('./kl-unl-celestial-sphere.js').CelestialSphere} sphere
 * @returns {{xScale: number, yScale: number, rotationDeg: number, side: 'above'|'below'}}
 */
export function horizonPlaneTransform(sphere) {
  return {
    xScale:      sphere.c.r,
    yScale:      sphere.c.r * Math.sin(sphere.phi),
    rotationDeg: 180 + sphere.theta * R2D,
    rotationDeg: 0,  // XXX
    side:        (sphere.phi > 0) ? 'above' : 'below'
  };
}

/**
 * Draw the above or below horizon-plane artwork at the current view transform.
 * `artAbove` / `artBelow` are draw callables invoked at the Flash registration
 * origin (typically SVG art with a 100-unit radius).
 *
 * @param {CanvasRenderingContext2D} ctx
 * @param {{xScale: number, yScale: number, rotationDeg: number, side: 'above'|'below'}} transform
 * @param {function(CanvasRenderingContext2D): void} artAbove
 * @param {function(CanvasRenderingContext2D): void} artBelow
 */
export function drawHorizonPlaneArt(ctx, transform, artAbove, artBelow) {
  const draw = (transform.side === 'below') ? artBelow : artAbove;
  if (typeof draw !== 'function') return;
  ctx.save();
  ctx.scale(transform.xScale / 100, transform.yScale / 100);
  ctx.rotate(transform.rotationDeg * D2R);
  console.log( "f-ss 1", Math.round( transform.rotationDeg * D2R ) );
  draw(ctx);
  ctx.restore();
}
