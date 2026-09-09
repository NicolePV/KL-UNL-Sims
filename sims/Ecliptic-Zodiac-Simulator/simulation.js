/* ===========================================================================
   Ecliptic (Zodiac) Simulator  --  HTML5 port
   ---------------------------------------------------------------------------
   Projection engine and shared helpers come from ../foundation/.
   Zodiac-specific band, constellations, and UI remain here.
   =========================================================================== */

import {
  CelestialSphere, Circle, CSObject, CELESTIAL_SPHERE_COLORS,
  D2R, R2D, TME_H, AZ_D, TWO_PI, HALF_PI, PI,
  strokeCirclePaths
} from '../foundation/js/kl-unl-celestial-sphere.js';

import {
  GlobeComponent, DEFAULT_GLOBE_RADIUS
} from '../foundation/js/kl-unl-globe.js';

import {
  pMod, speak, keyAccel, noEinNumber, hexToRGBA,
  updateSliderProgress, announceLive, logAct
} from '../foundation/js/kl-unl-utils.js';

import { CONSTELLATION_DATA } from '../foundation/js/kl-unl-zodiacal-constellations.js';

logAct('INIT_Zodiac');

/* ---------------------------------------------------------------------------
   1. Constants
   --------------------------------------------------------------------------- */

const CSC = CELESTIAL_SPHERE_COLORS;

const INIT_EARTH_DISK_SIZE   =  35;
const INIT_EARTH_ORBIT_SIZE  = 250;
const INIT_ZODIAC_SIZE       = 600;

//const INIT_THETA           = 206;  // update to match current date if used
const INIT_PHI               =  30;
const MAX_VIEWER_ALTITUDE    =  50;
//const MIN_VIEWER_ALTITUDE  = -90;
const MIN_VIEWER_ALTITUDE    = -50;  // restrict over-tilting for +/- phi
const SIDEREAL_TIME          =  18;
const LATITUDE               =  66.5;
const ZODIAC_BAND_HALF_ANGLE =  24;
const OPHIUCHUS_HALF_ANGLE   =  40;  // (for Ophiuchus to fit in band, +2deg for Earth)

const CONSTELLATIONS_COLOR   = CSC.CNSTLN_1;
const ECLIPTIC_COLOR         = CSC.CEL_EQUTR;
const ECLIPTIC_TILT          = 23.5;

const BAND_LIGHT             = CSC.CNSTLN_2;
const BAND_DARK              = CSC.CNSTLN_3;
const BAND_ALPHA             =   0.6;
const BAND_HALF_WIDTH_DEG    =  15;

const GLOBE_RADIUS           = DEFAULT_GLOBE_RADIUS;
const GLOBE_SCALE            = INIT_EARTH_DISK_SIZE / 2 / GLOBE_RADIUS;

const MONTH_FIRST_DAY = [0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334];
const MONTH_LABELS    = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                         'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
const MONTH_NAMES     = ['January',   'February', 'March',    'April',
                         'May',       'June',     'July',     'August',
                         'September', 'October',  'November', 'December'];

const DAY_MIN     =   0;
const DAY_MAX     = 365;

const LABEL_FONT  = '14px Arial, Helvetica, sans-serif';
const LABEL_COLOR = CSC.CNSTLN_1;

const CANVAS_SIZE = 620;
const ORIGIN_X    = CANVAS_SIZE / 2;
const ORIGIN_Y    = CANVAS_SIZE / 2;

const VIEW_STEP   = 1;

// Begin on current day of year, or on January 1 (from 0 to 364)
const BEGIN_NOW   = true;
let   day_0       = 0;
const date        = new Date()
const year        = date.getFullYear();
if ( BEGIN_NOW )  {
  day_0 = Math.floor( ( date - new Date(year, 0, 0) ) / 86400000 ) - 1;
  // If leap year, treat Feb. 29 as another Feb. 28
  if ( (year % 4 === 0 && year % 100 !== 0) || year % 400 === 0 )  {
    if ( day_0 > 59 ) day_0 = day_0 - 1;
  }
  day_0 = Math.min( Math.max( day_0, 0 ), 364 );
}
const INIT_THETA  = pMod( 206 + day_0, 364 );

/* ---------------------------------------------------------------------------
   2. ZodiacViewer -- the simulation itself
      Ported from ZodiacViewer.as.
      (CSObject / GlobeComponent live in ../foundation/js/.)
   --------------------------------------------------------------------------- */

// Constellation label centers, verbatim from ZodiacViewerClass().
const CONSTELLATION_LABELS = [
  { key: 'psc', text: 'Pisces',      ra:  0.7, dec:  -0.6 },
  { key: 'ari', text: 'Aries',       ra:  2.5, dec:  16.3 },
  { key: 'tau', text: 'Taurus',      ra:  4.1, dec:  22.8 },
  { key: 'gem', text: 'Gemini',      ra:  6.5, dec:  31.5 },
  { key: 'cnc', text: 'Cancer',      ra:  8.8, dec:   8.6 },
  { key: 'leo', text: 'Leo',         ra: 10.6, dec:   7.6 }, 
  { key: 'vir', text: 'Virgo',       ra: 13.2, dec: -14.7 }, 
  { key: 'lib', text: 'Libra',       ra: 14.9, dec: -29.6 },
  { key: 'oph', text: 'Ophiuchus',   ra: 16.0, dec:  -8.5 },
  { key: 'sco', text: 'Scorpius',    ra: 17.4, dec: -33   },
  { key: 'sgr', text: 'Sagittarius', ra: 18.5, dec: -16.1 },
  { key: 'cap', text: 'Capricornus', ra: 21.3, dec: -28.6 },
  { key: 'aqr', text: 'Aquarius',    ra: 22.2, dec:   3.2 }
];

// The label "up" reference: the ecliptic pole, {ra: 18, dec: 66.56}.
const LABEL_UP_REFERENCE = { ra: 18, dec: 66.56 };

class ZodiacViewer {
  constructor() {
    const sphere = new CelestialSphere();
    this.sphere  = sphere;

    // ZodiacViewerClass() constructor order
    sphere.setMaxPhi(MAX_VIEWER_ALTITUDE);
    sphere.setMinPhi(MIN_VIEWER_ALTITUDE);
    sphere.setTheta(INIT_THETA);

    this.sunDisk = new CSObject(sphere, 'sunDisk');
    this.sunDisk.setPosition({ ra: 0, dec: 0 });

    this.labels = CONSTELLATION_LABELS.map((def) => {
      const obj = new CSObject(sphere, def.key);
      obj.text  = def.text;
      obj.setPosition({ ra: def.ra, dec: def.dec });
      // setOrientationType("absolute", {ra: ra+12, dec: -dec}, eclipticPole)
      obj.setAbsoluteOrientation({ ra: def.ra + 12, dec: -def.dec },
                                 LABEL_UP_REFERENCE);
      return obj;
    });

    this.globeObject = new CSObject(sphere, 'globe');
    this.globeObject.setPosition({ ra: 0, dec: 0, r: INIT_EARTH_ORBIT_SIZE / INIT_ZODIAC_SIZE });
    this.globe       = new GlobeComponent(sphere);

    sphere.setSiderealTime(SIDEREAL_TIME);
    sphere.setLatitude(LATITUDE);

    // Band circle used only for mask geometry (not stroked).
    this.bandCircle = new Circle(sphere, { thickness: 1, color: CSC.ECLPTC_3, alpha: 1 },
      { alt: ZODIAC_BAND_HALF_ANGLE, az: 0, tilt: 0 });
    this.bandCircle.visible = false;

    this.ecliptic = new Circle(sphere, { thickness: 1, color: ECLIPTIC_COLOR, alpha: 1 },
      { dec: 0, ra: 0, tilt: ECLIPTIC_TILT });

    sphere.setSize(INIT_ZODIAC_SIZE);
    this.setDayOfYear( day_0 );
  }

  // p.setDayOfYear -- the geometry wraps at 365, but the control keeps the
  // value the user actually chose: dragging the grabber to the far right 
  // leaves it there while the sky shows day 0.
  setDayOfYear(day) {
    this.dayInput  = day;
    this.dayOfYear = pMod(day, 365);
    this.updateGlobe();
  }

  // p.setMonthAndDay -- month is 1-based, dayOfMonth is 1-based
  setMonthAndDay(month, dayOfMonth) {
    this.setDayOfYear(pMod(MONTH_FIRST_DAY[month - 1] + dayOfMonth - 1, 365));
  }

  // p.updateGlobe -- the whole date -> geometry chain
  updateGlobe() {
    // az = -(360/365) * (dayOfYear + 10.8)
    const az = AZ_D * (this.dayOfYear + 10.8);
    this.earthAzimuth = az;

    this.globeObject.setPosition({ az: az,       alt: 0, r: 0.001  });
    this.sunDisk.setPosition    ({ az: az + 180, alt: 0, r: 0.9999 });
    this.sunDisk.setAbsoluteOrientation();

    this.globe.setSunDirection({ az: az + 180, alt: 0 });
    // The Earth turns 366/365 times per year relative to the stars.
    const turns = TME_H * this.dayOfYear;
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
  // Returns polylines in screen px. Ophiuchus (last data entry) is split out so
  // the renderer can band-clip it on the front and leave the overhang on the back.
  buildConstellations() {
    const c        = this.sphere.c;
    const front    = [],
          back     = [],
          ophFront = [],
          ophBack  = [];
    const data     = CONSTELLATION_DATA;
    const ophIndex = data.length - 1;

    for (let i = 0; i < data.length; i++) {
      const isOph  = (i === ophIndex);
      const curves = data[i].path;
      const points = data[i].stars;
      for (let j = 0; j < curves.length; j++) {
        const stroke = curves[j];
        let s    = points[stroke.m];
        let lx   =  c.b0 * s.x + c.b1 * s.y + c.b2 * s.z;
        let ly   =  c.b3 * s.x + c.b4 * s.y + c.b5 * s.z;
        let lif  = (c.b6 * s.x + c.b7 * s.y + c.b8 * s.z) > 0;
        let poly = { pts: [{ x: lx, y: ly }] };
        const pushSide = (inFront, p) => {
          if (isOph) (inFront ? ophFront : ophBack).push(p);
          else       (inFront ? front    : back   ).push(p);
        };
        pushSide(lif, poly);

        for (let k = stroke.b; k < stroke.e; k++) {
          s = points[k];
          const tx  =  c.b0 * s.x + c.b1 * s.y + c.b2 * s.z;
          const ty  =  c.b3 * s.x + c.b4 * s.y + c.b5 * s.z;
          const tif = (c.b6 * s.x + c.b7 * s.y + c.b8 * s.z) > 0;
          if (tif !== lif) {
            // The segment crosses the limb: it is drawn on the side it ends on,
            // starting from the previous point.
            poly = { pts: [{ x: lx, y: ly }, { x: tx, y: ty }] };
            pushSide(tif, poly);
          } else {
            poly.pts.push({ x: tx, y: ty });
          }
          lx = tx; ly = ty; lif = tif;
        }
      }
    }
    return { front, back, ophFront, ophBack };
  }

  /* --- p.updateZodiacBand ------------------------------------------------- */
  // Returns the two linear gradients (as stop lists) for the back and front
  // surfaces, plus which way round they go.
  buildBandGradients() {
    const sphere = this.sphere;
    const az     = this.globeObject.az - 90;
    const width  = BAND_HALF_WIDTH_DEG;
    const sp     = {};

    sphere.toScreen({ alt: 0, az: az         }, sp);
    const inFront = sp.z > 0;
    sphere.toScreen({ alt: 0, az: az - width }, sp);
    const darkX = sp.x;
    sphere.toScreen({ alt: 0, az: az + width }, sp);
    const lightX = sp.x;

    const size = sphere.getSize();
    const half = size / 2;
    const k    = 256  / size;

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
  // Front/back clip paths for the ±zodiacBandHalfAngle spherical zone.
  // Edges meet the sphere silhouette and are closed by limb arcs. Front/back
  // follow screen z. Silhouette nodes are where the projected edge meets
  // x²+y² = r² (robust even when sampling is coarse); with signed doA those
  // nodes coincide with z≈0 limb hits.
  buildBandMaskPaths() {
    const halfAlt = ZODIAC_BAND_HALF_ANGLE;
    const r       = this.sphere.getSize() / 2;
    const r2      = r * r;
    const minStep = TWO_PI / 64;

    const projectV = (v, g) => {
      const c = Math.cos(g), s = Math.sin(g);
      return {
        x: v[0] * c + v[1] * s + v[2],
        y: v[3] * c + v[4] * s + v[5],
        z: v[6] * c + v[7] * s + v[8]
      };
    };

    this.bandCircle.setParameters({ alt:  halfAlt, az: 0, tilt: 0 });
    const vHi = this.bandCircle.computeV();
    this.bandCircle.setParameters({ alt: -halfAlt, az: 0, tilt: 0 });
    const vLo = this.bandCircle.computeV();
    this.bandCircle.setParameters({ alt:  halfAlt, az: 0, tilt: 0 });

    const angDiff = (a, b) => {
      const d = pMod(a - b, TWO_PI);
      return d > PI ? TWO_PI - d : d;
    };

    // g where the projected small circle meets the visible sphere outline.
    // Prefer x²+y² = r² (visual limb). Fall back to the two rho² maxima when
    // the ellipse sits inside the disk (no crossing).
    const limbNodeGs = (v) => {
      const n    = 180;
      const rho  = new Array(n);
      let max0   = -1, max1 = -1, i0 = 0, i1 = 1;
      for (let i = 0; i < n; i++) {
        const p  = projectV(v, (i / n) * TWO_PI);
        const rr = p.x * p.x + p.y * p.y;
        rho[i]   = rr;
        if      (rr > max0) { max1 = max0; i1 = i0; max0 = rr; i0 = i; }
        else if (rr > max1) { max1 = rr;   i1 = i; }
      }

      const nodes = [];
      const seen  = [];
      const pushNode = (g) => {
        const gg  = pMod(g, TWO_PI);
        for (let k = 0; k < seen.length; k++) {
          if (angDiff(seen[k], gg) < 1e-3) return;
        }
        seen.push(gg);
        nodes.push(gg);
      };

      for (let i = 0; i < n; i++) {
        const j = (i + 1) % n;
        const a = rho[i] - r2;
        const b = rho[j] - r2;
        if (a === 0) {
          pushNode(( i      / n) * TWO_PI);
        } else if (a * b < 0) {
          const t = a / (a - b);
          pushNode(((i + t) / n) * TWO_PI);
        }
      }

      if (nodes.length >= 2) {
        // Keep the pair with the largest angular separation (the true two hits).
        let bestI = 0, bestJ = 1, bestSep = -1;
        for (let i = 0; i < nodes.length; i++) {
          for (let j = i + 1; j < nodes.length; j++) {
            const sep = angDiff(nodes[i], nodes[j]);
            if (sep > bestSep) { bestSep = sep; bestI = i; bestJ = j; }
          }
        }
        return [nodes[bestI], nodes[bestJ]];
      }

      // No crossing: use the two densest samples with locally max rho
      // (refine with a short bracket around each peak index).
      const refinePeak = (iPeak) => {
        let bestG  = (iPeak / n) * TWO_PI, bestR = rho[iPeak];
        const g0   = ((iPeak - 1 + n) % n) / n * TWO_PI;
        for (let s = 0; s <= 16; s++) {
          const g  = g0 + (s / 16) * (TWO_PI / n) * 2;
          const p  = projectV(v, g);
          const rr = p.x * p.x + p.y * p.y;
          if (rr > bestR) { bestR = rr; bestG = g; }
        }
        return pMod(bestG, TWO_PI);
      };

      // Second peak: farthest sample index from i0 among local maxima.
      let jPeak    = i1;
      let bestFar  = -1;
      for (let i = 0; i < n; i++) {
        const prev = rho[(i - 1 + n) % n], next = rho[(i + 1) % n];
        if (rho[i] >= prev && rho[i] >= next) {
          const far = angDiff((i / n) * TWO_PI, (i0 / n) * TWO_PI);
          if (far > bestFar) { bestFar = far; jPeak = i; }
        }
      }
      return [refinePeak(i0), refinePeak(jPeak)];
    };

    const onLimb = (p) => {
      const len = Math.hypot(p.x, p.y) || 1;
      return { x: (p.x / len) * r, y: (p.y / len) * r };
    };

    const limbPt = (v, g) => onLimb(projectV(v, g));

    const appendPolarArc = (path, rad, a0, a1, useShort) => {
      let arc = pMod(a1 - a0, TWO_PI);
      if (!useShort) arc = arc - TWO_PI;
      if (Math.abs(arc) < 1e-9) return;
      const steps = Math.max(1, Math.ceil(Math.abs(arc) / minStep));
      const step  = arc / steps;
      const half  = step / 2;
      const cRad  = rad / Math.cos(half);
      let aAngle  = a0 + step;
      let cAngle  = aAngle - half;
      for (let i = 0; i < steps; i++) {
        path.quadraticCurveTo(
          cRad * Math.cos(cAngle), cRad * Math.sin(cAngle),
          rad  * Math.cos(aAngle), rad  * Math.sin(aAngle)
        );
        aAngle += step;
        cAngle += step;
      }
    };

    const appendLimb = (path, from, to) => {
      const a0       = Math.atan2(from.y, from.x);
      const a1       = Math.atan2(  to.y,   to.x);
      const d        = pMod(a1 - a0, TWO_PI);
      const midS     = a0 + 0.5 *  d;
      const midL     = a0 + 0.5 * (d - TWO_PI);
      const bx       = from.x + to.x,
            by       = from.y + to.y;
      const shortDot = Math.cos(midS) * bx + Math.sin(midS) * by;
      const longDot  = Math.cos(midL) * bx + Math.sin(midL) * by;
      appendPolarArc(path, r, a0, a1, shortDot >= longDot);
    };

    // Walk gFrom→gTo along the arc whose mid-z matches wantFront (may be the long way).
    const appendCircleArc = (path, v, gFrom, gTo, wantFront) => {
      let span = pMod(gTo - gFrom, TWO_PI);
      if (span < 1e-9) return;
      const mid = projectV(v, gFrom + 0.5 * span).z;
      if ((mid >= 0) !== wantFront) span -= TWO_PI;
      if (Math.abs(span) < 1e-9) return;
      const steps = Math.max(1, Math.ceil(Math.abs(span) / minStep));
      const step  = span / steps;
      const half  = step / 2;
      const cRad  = 1 / Math.cos(half);
      const map = (cg, sg) => ({
        x: v[0] * cg + v[1] * sg + v[2],
        y: v[3] * cg + v[4] * sg + v[5]
      });
      for (let i = 0; i < steps; i++) {
        const aAngle = gFrom + (i + 1) * step;
        const cAngle = aAngle - half;
        const a      = map(       Math.cos(aAngle),        Math.sin(aAngle));
        const c      = map(cRad * Math.cos(cAngle), cRad * Math.sin(cAngle));
        path.quadraticCurveTo(c.x, c.y, a.x, a.y);
      }
    };

    const appendFullLoop = (path, v, reverse) => {
      const span  = reverse ? -TWO_PI : TWO_PI;
      const steps = Math.max(1, Math.ceil(TWO_PI / minStep));
      const step  = span / steps;
      const half  = step / 2;
      const cRad  = 1 / Math.cos(half);
      const map = (cg, sg) => ({
        x: v[0] * cg + v[1] * sg + v[2],
        y: v[3] * cg + v[4] * sg + v[5]
      });
      for (let i = 0; i < steps; i++) {
        const aAngle = (i + 1) * step;
        const cAngle = aAngle - half;
        const a      = map(       Math.cos(aAngle),        Math.sin(aAngle));
        const c      = map(cRad * Math.cos(cAngle), cRad * Math.sin(cAngle));
        path.quadraticCurveTo(c.x, c.y, a.x, a.y);
      }
    };

    const midZ = (v, g0, g1) => {
      const span = pMod(g1 - g0, TWO_PI);
      return projectV(v, g0 + 0.5 * span).z;
    };

    const addAnnulus = (path, vOuter, vInner) => {
      const p0 = projectV(vOuter, 0);
      path.moveTo(p0.x, p0.y);
      appendFullLoop(path, vOuter, false);
      path.closePath();
      const q0 = projectV(vInner, 0);
      path.moveTo(q0.x, q0.y);
      appendFullLoop(path, vInner, true);
      path.closePath();
    };

    // One hemisphere's zone: hi arc, limb, lo arc, limb.
    const addHemisphereZone = (path, wantFront) => {
      const hiNodes = limbNodeGs(vHi);
      const loNodes = limbNodeGs(vLo);
      if (!hiNodes || !loNodes) {
        const probe = projectV(vHi, 0).z + projectV(vLo, 0).z;
        if ((probe >= 0) === wantFront) addAnnulus(path, vHi, vLo);
        return;
      }

      const [hA, hB] = hiNodes;
      const [lA, lB] = loNodes;
      const pHA = limbPt(vHi, hA), pHB = limbPt(vHi, hB);
      const pLA = limbPt(vLo, lA), pLB = limbPt(vLo, lB);
      const aHA = Math.atan2(pHA.y, pHA.x), aHB = Math.atan2(pHB.y, pHB.x);
      const aLA = Math.atan2(pLA.y, pLA.x), aLB = Math.atan2(pLB.y, pLB.x);

      // Pair each hi limb node with the nearer lo limb node (no crossing).
      let lForHA, lForHB, pLForHA, pLForHB;
      if (angDiff(aHA, aLA) + angDiff(aHB, aLB) <= angDiff(aHA, aLB) + angDiff(aHB, aLA)) {
        lForHA = lA; pLForHA = pLA; lForHB = lB; pLForHB = pLB;
      } else {
        lForHA = lB; pLForHA = pLB; lForHB = lA; pLForHB = pLA;
      }

      const hABFront = midZ(vHi, hA, hB) >= 0;
      let h0, h1, pH0, pH1, l0, l1, pL0, pL1;
      if (hABFront === wantFront) {
        h0 = hA; h1 = hB; pH0 = pHA; pH1 = pHB;
        l0 = lForHA; l1 = lForHB; pL0 = pLForHA; pL1 = pLForHB;
      } else {
        h0 = hB; h1 = hA; pH0 = pHB; pH1 = pHA;
        l0 = lForHB; l1 = lForHA; pL0 = pLForHB; pL1 = pLForHA;
      }

      path.moveTo(pH0.x, pH0.y);
      appendCircleArc(path, vHi, h0, h1, wantFront);
      path.lineTo(pH1.x, pH1.y);
      appendLimb(path, pH1, pL1);
      appendCircleArc(path, vLo, l1, l0, wantFront);
      path.lineTo(pL0.x, pL0.y);
      appendLimb(path, pL0, pH0);
      path.closePath();
    };

    const front = new Path2D();
    const back  = new Path2D();
    addHemisphereZone(front, true);
    addHemisphereZone(back, false);
    return { front, back };
  }
}

/* ---------------------------------------------------------------------------
   3. Rendering
   --------------------------------------------------------------------------- */

// Exported vector art, reused as-is from the JPEXS export (never redrawn):
//   shape-1.svg  GlobeComponentWater   shape-3.svg  GlobeComponentLand
//   shape-49.svg Symbol 65 (front haze) shape-51.svg Symbol 64 (back haze)
//   shape-55.svg Sun Disk
const ART = {
  water:     'images/shape-1.svg',
  land:      'images/shape-3.svg',
  hazeFront: 'images/shape-49.svg',
  hazeBack:  'images/shape-51.svg',
  sun:       'images/shape-55.svg'
};
const images = {};

function loadArt() {
  const jobs    = Object.keys(ART).map((key) => new Promise((resolve) => {
    const img   = new Image();
    img.onload  = () => { images[key] = img; resolve(); };
    img.onerror = () => { images[key] = null; resolve(); };
    img.src     = ART[key];
  }));
  return Promise.all(jobs);
}

// Turns a Flash gradient stop list into a canvas linear gradient across the
// 600 px square, matching the {matrixType:"box", w:600, r:0|pi} matrices.
function bandGradient(ctx, spec, half) {
  const g = spec.reversed
    ? ctx.createLinearGradient( half, 0, -half, 0)
    : ctx.createLinearGradient(-half, 0,  half, 0);
  let last = -1;
  for (let i = 0; i < spec.colors.length; i++) {
    let stop = spec.ratios[i] / 255;
    if (stop < 0)    stop = 0;
    if (stop > 1)    stop = 1;
    if (stop < last) stop = last;      // canvas requires non-decreasing offsets
    last = stop;
    g.addColorStop(stop, hexToRGBA(spec.colors[i], BAND_ALPHA));
  }
  return g;
}

function strokePolylines(ctx, polys, color) {
  ctx.save();
  ctx.strokeStyle = color;
  ctx.lineWidth   = 1;
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
  ctx.font         = LABEL_FONT;
  ctx.fillStyle    = LABEL_COLOR;
  ctx.textAlign    = 'center';
  ctx.textBaseline = 'middle';
  for (const obj of objects) {
    if (!obj.text) continue;
    ctx.save();
    ctx.translate(obj.sp.x, obj.sp.y);
    ctx.rotate(obj.rotation);
    // Apply the foreshortening as _yscale on the shell; a zero or
    // near-zero scale collapses the label to nothing, so skip those.
    if (Math.abs(obj.yScale) > 1e-4) {
      ctx.scale(1, obj.yScale);
      ctx.rotate(obj.innerRotation);
      // Text field origin offset (see texts/47.txt placement: -67, -8.4 for a
      // 136 x 20 centered field).
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
  ctx.drawImage(img, -8, -8, 16, 16);   // Sun Disk shape is 16 x 16, centered
  ctx.restore();
}

function drawGlobe(ctx, viewer) {
  const obj   = viewer.globeObject;
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
    ctx.fillStyle = hexToRGBA(CSC.SKY_2, 0.6);
    ctx.fill(night.path);
    ctx.restore();
  }
  ctx.restore();
}

function render(ctx, viewer) {
  const sphere = viewer.sphere;
  const half   = sphere.getSize() / 2;

  ctx.save();
  ctx.setTransform(1, 0, 0, 1, 0, 0);
  ctx.scale(state.dpr, state.dpr);
  ctx.fillStyle = CSC.SKY_2;           // SetBackgroundColor black
  ctx.fillRect(0, 0, CANVAS_SIZE, CANVAS_SIZE);
  ctx.translate(ORIGIN_X, ORIGIN_Y);

  viewer.refresh();
  const buckets        = viewer.sortedObjects();
  const constellations = viewer.buildConstellations();
  viewer.ecliptic.update();
  const masks          = viewer.buildBandMaskPaths();
  const gradients      = viewer.buildBandGradients();
  const size           = sphere.getSize();
  // AS swaps bI/aI paint order when phi < 0.
  const belowView      = sphere.phi < 0;

  // --- backSurface (depth 45), clipped to the far half of the band ---------
  if (masks) {
    ctx.save();
    ctx.clip(masks.back);
    ctx.fillStyle = bandGradient(ctx, gradients.back, half);
    ctx.fillRect(-half, -half, size, size);
    if (images.hazeBack) ctx.drawImage(images.hazeBack, -half, -half, size, size);
    ctx.restore();
  }

  // --- celestialSphere (depth 100), in AS depth order ---------------------
  strokeCirclePaths(ctx, viewer.ecliptic.back, {
    color: viewer.ecliptic.color, thick: viewer.ecliptic.thick, alpha: viewer.ecliptic.alpha
  });
  drawLabels(ctx, buckets.bS);
  strokePolylines(ctx, constellations.back, CONSTELLATIONS_COLOR);
  
  // Ophiuchus on the far side: clip to the back band so the overhang
  // does not clutter unless unobscured.
  if (masks && constellations.ophBack.length &&
      (0 < -sphere.phi) && (-R2D*sphere.phi < OPHIUCHUS_HALF_ANGLE) ) {
    ctx.save();
    ctx.clip(masks.back);
    strokePolylines(ctx, constellations.ophBack, CONSTELLATIONS_COLOR);
    ctx.restore();
  } else {
    strokePolylines(ctx, constellations.ophBack, CONSTELLATIONS_COLOR);
  }
  const innerFirst  = belowView ? buckets.aI : buckets.bI;
  const innerSecond = belowView ? buckets.bI : buckets.aI;
  for (const obj of innerFirst)  drawInner(ctx, viewer, obj);
  for (const obj of innerSecond) drawInner(ctx, viewer, obj);
  strokeCirclePaths(ctx, viewer.ecliptic.front, {
    color: viewer.ecliptic.color, thick: viewer.ecliptic.thick, alpha: viewer.ecliptic.alpha
  });
  drawLabels(ctx, buckets.fS);
  strokePolylines(ctx, constellations.front, CONSTELLATIONS_COLOR);
  
  // Ophiuchus on the near side: clip to the front band so the overhang does
  // not clutter unless unobscured.
  if (masks && constellations.ophFront.length &&
      (0 <= sphere.phi) && (R2D*sphere.phi < OPHIUCHUS_HALF_ANGLE) ) {
    ctx.save();
    ctx.clip(masks.front);
    strokePolylines(ctx, constellations.ophFront, CONSTELLATIONS_COLOR);
    ctx.restore();
  } else {
    strokePolylines(ctx, constellations.ophFront, CONSTELLATIONS_COLOR);
  }

  // --- frontSurface (depth 145), clipped to the near half of the band -----
  if (masks) {
    ctx.save();
    ctx.clip(masks.front);
    ctx.fillStyle = bandGradient(ctx, gradients.front, half);
    ctx.fillRect(-half, -half, size, size);
    if (images.hazeFront) ctx.drawImage(images.hazeFront, -half, -half, size, size);
    ctx.restore();
  }

  ctx.restore();
}

function drawInner(ctx, viewer, obj) {
  if      (obj === viewer.globeObject) drawGlobe(ctx, viewer);
  else if (obj === viewer.sunDisk)     drawSun(  ctx, obj   );
}

/* ---------------------------------------------------------------------------
   4. State, DOM wiring and narration
   --------------------------------------------------------------------------- */

const state = {
  viewer:      null,
  ctx:         null,
  canvas:      null,
  dpr:         1,
  needsRender: false,
  editing:     null        // the field currently being typed into, if any
};

const el = {};

function $(id) { return document.getElementById(id); }

function cacheElements() {
  ['stage', 'stage-canvas', 'stage-desc', 'sr-status',
   'day-range', 'day-number', 'month-select', 'dom-number',
   'azimuth-range', 'azimuth-number',
   'elevation-range', 'elevation-number',
   'sun-ra-readout', 'sun-dec-readout', 'sun-near-readout', 'sun-sep-readout',
   'timeline', 'timeline-months'].forEach((id) => { el[id] = $(id); });
}

/* --- date helpers (p.setMonthAndDay table) ------------------------------- */

// Flash year slider initPrecision = 2 → hundredths of a day.
const DAY_PREC = 0.01;

// In-flight track-click day tween (cancelled by keyboard, other controls, reset).
let dayTween = null;

function cancelDayTween() {
  if (!dayTween) return;
  cancelAnimationFrame(dayTween.rafId);
  dayTween = null;
}

function snapDay(day) {
  return Math.round(day / DAY_PREC) * DAY_PREC;
}

function dayFieldString(day) {
  const s = snapDay(day);
  // Prefer "12" over "12.00" when the value is a whole day.
  return (Math.round(s * 100) % 100 === 0) ? String(Math.round(s)) : s.toFixed(2);
}

function monthIndexForDay(day) {
  const d = Math.floor(pMod(day, 365));
  let m   = 11;
  for (let i = 0; i < 12; i++) {
    if (d < MONTH_FIRST_DAY[i]) { m = i - 1; break; }
  }
  return m < 0 ? 0 : m;
}

function calendarDate(day) {
  const d = Math.floor(pMod(day, 365));
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

function dayAriaText(day) {
  const s    = snapDay(day);
//const prec = (Math.round(s * 100) % 100 === 0) ? 0 : 2;
  const prec = (Math.round(s *   1) %   1 === 0) ? 0 : 2;
  return `Day ${speak(s, prec)} of the year, ${formatDate(s)}`;
}

/* --- spoken value strings (always quantity + number + unit) -------------- */

// Units are spelled out as words so screen readers say them rather than
// skipping a symbol, and singular/plural is honored so the speech reads
// naturally.
function raWords(hours) {
  const h  = Math.floor( hours);
  const m  = Math.round((hours - h) * 60);
  const hh = (m === 60) ? h + 1 : h;
  const mm = (m === 60) ?     0 : m;
  return `${speak(pMod(hh, 24), 0, 'hour')} ${speak(mm, 0, 'minute')}`;
}

/* --- the nearest zodiac label to the Sun (a geometric readout, not an
       IAU constellation-boundary lookup -- see ACCESSIBILITY.md) ---------- */

function nearestLabelToSun(viewer) {
  const sun  = viewer.sunDisk.p;
  const mag  = Math.sqrt(sun.x * sun.x + sun.y * sun.y + sun.z * sun.z);
  const sunC = viewer.sphere.WtoC(sun, {});
  let best   = null, bestDot = -2;
  for (const obj of viewer.labels) {
    const p   = obj.p;
    const dot = (sunC.x * p.x + sunC.y * p.y + sunC.z * p.z) / mag;
    if (dot > bestDot) { bestDot = dot; best = obj; }
  }
  return { text: best.text, separation: R2D * Math.acos(Math.min(1, Math.max(-1, bestDot))) };
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
  const viewer    =              state.viewer;
  const sphere    =              viewer.sphere;
  const day       = snapDay(     viewer.dayInput );
  const cal       = calendarDate(viewer.dayOfYear);
  const azimuth   = Math.round(  sphere.getViewerAzimuth());
  const elevation = Math.round(  sphere.getPhi());

  // setFieldValue leaves a field alone while the user is typing in it, so the
  // caret is never yanked around mid-edit.
  setFieldValue(el['day-range'], dayFieldString(day));
  el['day-range'].setAttribute('aria-valuetext', dayAriaText(day));

  el['stage-desc'].textContent = describeScene();
  positionTimelineMarker();
}

// The text equivalent of the picture, for anyone working from audio alone.
function describeScene() {
  let i;
  let cnames;

  const viewer = state.viewer;
  const sphere = viewer.sphere;
  const sun    = sphere.pointToCelestial(viewer.sunDisk.p, {});
  const near   = nearestLabelToSun(viewer);

  // Sort constellation names on band front from left to right
  const front  = [...viewer.labels]
    .filter((obj) => obj.sp.z >= 0)
    .sort((a, b)  => a.sp.x - b.sp.x)
    .map((obj)    => obj.text);
  if ( front.length > 2 )  { 
    front.splice(-1, 0, 'and');
    cnames = front.join(', ');
    i      = cnames.lastIndexOf(',');
    if ( i !== -1 )  { cnames = cnames.slice(0, i) + cnames.slice(i+1); }
  } else if ( front.length == 2 )  {
    cnames = front.join(' and ');
  } else if ( front.length == 1 )  {
    cnames = front[0];
  }

  return [
    `${dayAriaText(viewer.dayInput)}.`,
    `Earth sits at the center of the zodiac band of constellations; the Sun is at`,
    `right ascension ${raWords(sun.ra)}, declination ${speak(sun.dec, 1, 'degree')},`,
    `close to ${near.text}.`,
    front.length
      ? `The constellations on the near side of the band are ${cnames}.`
      : `No constellation labels are on the near side of the band.`
  ].join(' ');
}

function announce(message) {
  announceLive(el['sr-status'], message, 150);
}

function requestRender() {
  if (state.needsRender) return;
  state.needsRender   = true;
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
  const canvas  = el['stage-canvas'];
  const dpr     = window.devicePixelRatio || 1;
  state.dpr     = dpr;
  canvas.width  = Math.round(CANVAS_SIZE * dpr);
  canvas.height = Math.round(CANVAS_SIZE * dpr);
  requestRender();
}

// Every numeric field also steps on the mouse wheel while it is focused, by
// the same amount as an arrow key. preventDefault stops the page scrolling.
function addWheelStepping(field, setter) {
  field.addEventListener('wheel', (event) => {
    if (document.activeElement !== field) return;
    event.preventDefault();
    const step    = Number(field.step) || 1;
    const min     = Number(field.min);
    const max     = Number(field.max);
    const current = Number(field.value) || 0;
    const next    = Math.min(max, Math.max(min, current + (event.deltaY < 0 ? step : -step)));
    field.value   = String(next);
    setter(next);
    update({ announceText: describeScene() });
  }, { passive: false });
}

/* --- pointer drag on the sphere (p.startSimpleDragging / p.updateSimpleDragging) --- */

let drag = null;

function stageCoords(event) {
  const canvas = el['stage-canvas'];
  const rect   = canvas.getBoundingClientRect();
  // Map the pointer back through the CSS scale so the drag maths runs in
  // stage pixels at any display size.
  const scale = CANVAS_SIZE / rect.width;
  return {
    x: (event.clientX - rect.left) * scale                       - ORIGIN_X,
    y: (event.clientY - rect.top)  * (CANVAS_SIZE / rect.height) - ORIGIN_Y
  };
}

function onPointerDown(event) {
  const sphere = state.viewer.sphere;
  const p      = stageCoords(event);
  const p2     = { x: p.x, y: -p.y };
  const hp     = {};
  const hp2    = {};
  let drc      = 1;

  // Dragging on back portion rather than front should spin in correct direction
  sphere.StoMH(p, hp);
  // Drag front of band
  if        ( Math.abs( R2D*hp.alt ) <= ZODIAC_BAND_HALF_ANGLE  )  {
  // Ignore presses above or below front of band
  } else if ( Math.sign( state.viewer.sphere.phi * p.y ) != -1 )  { 
    return;
  } else {
    sphere.StoMH(p2, hp2);
    // Drag back of band
    if ( Math.abs( R2D*hp2.alt ) <= ZODIAC_BAND_HALF_ANGLE  )  {
      drc = -1;
    // Ignore presses above or below back of band
    } else  {
      return;
    }
  }
    
  // The mouse area is the sphere disk; presses outside it do nothing.
  if (Math.sqrt(p.x * p.x + p.y * p.y) > sphere.c.r) return;
  el.stage.focus();                        // click-to-focus, so arrows work next
  drag = {
    id:    event.pointerId,
    x:     p.x, y: p.y,
    theta: sphere.theta,
    phi:   sphere.phi,
    drc:   drc
  };
  el.stage.setPointerCapture(event.pointerId);
  event.preventDefault();
}

function onPointerMove(event) {
  if (!drag || event.pointerId !== drag.id) return;
  const sphere = state.viewer.sphere;
  const p      = stageCoords(event);
  sphere.setThetaAndPhi(
    R2D * (drag.theta - (p.x - drag.x) * drag.drc / sphere.c.r),
    R2D * (drag.phi   + (p.y - drag.y) * drag.drc / sphere.c.r)
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

function onStageKeyDown(event) {
  const sphere = state.viewer.sphere;
  const step   = keyAccel(event, VIEW_STEP);
  let handled  = true;

  switch (event.key) {
    case 'ArrowLeft':
      sphere.setViewerAzimuth(pMod(sphere.getViewerAzimuth() - step, 360));
      break;
    case 'ArrowRight':
      sphere.setViewerAzimuth(pMod(sphere.getViewerAzimuth() + step, 360));
      break;
    case 'ArrowUp':
      sphere.setPhi(sphere.getPhi() - step);
      break;
    case 'ArrowDown':
      sphere.setPhi(sphere.getPhi() + step);
      break;
    case 'PageUp':
      sphere.setPhi(sphere.getPhi() - keyAccel(event, 15));
      break;
    case 'PageDown':
      sphere.setPhi(sphere.getPhi() + keyAccel(event, 15));
      break;
    case 'Home':
      sphere.setPhi(MIN_VIEWER_ALTITUDE);
      break;
    case 'End':
      sphere.setPhi(MAX_VIEWER_ALTITUDE);
      break;
    default:
      handled = false;
  }
  if (!handled) return;
  event.preventDefault();
  update({ announceText: describeScene() });
}

/* --- the timeline (Modified Year Slider) --------------------------------- */

function buildTimeline() {
  const host = el['timeline-months'];
  // Month boundaries at scaleFactor * MONTH_FIRST_DAY, labels centered between
  // them.
  const frag = document.createDocumentFragment();
  for (let i = 0; i < 12; i++) {
    const start      = MONTH_FIRST_DAY[i];
    const end        = (i === 11) ? 365 : MONTH_FIRST_DAY[i + 1];
    const cell       = document.createElement('span');
    cell.className   = 'sim-timeline__month';
    cell.style.left  = `${(       start  / 365) * 100}%`;
    cell.style.width = `${((end - start) / 365) * 100}%`;
    cell.textContent = MONTH_LABELS[i];
    frag.appendChild(cell);
  }
  host.appendChild(frag);
}

// The red grabber (images/shape-13.svg) is an overlay positioned by percentage
// so it lines up exactly with the month ticks; the native range input on top of
// it stays transparent and supplies all the pointer and keyboard behavior.
function positionTimelineMarker() {
  const day = state.viewer.dayInput;
  el.timeline.style.setProperty('--marker-position', `${(day / DAY_MAX) * 100}%`);
}

/* --- reset (the masthead's sim-reset event) ------------------------------ */

function resetSim() {
  cancelDayTween();
  const viewer = state.viewer;
  viewer.sphere.setThetaAndPhi(INIT_THETA, INIT_PHI);
  viewer.setDayOfYear( day_0 );
  update({ announceText: `Simulation reset. ${describeScene()}` });
}

/* --- equation (via foundation kl-unl-mathjax.js) ------------------------- */

// Redefining klunlInitEqn is the documented extension point in kl-unl-mathjax.js.
function klunlInitEqn() {
  klunlShowEquation(
    ['sun-direction-eqn',
     '\\[ a_{\\oplus} \\;=\\; -\\frac{360^{\\circ}}{365}\\,\\bigl(N + 10.8\\bigr)' +
     ' \\qquad a_{\\odot} \\;=\\; a_{\\oplus} + 180^{\\circ} \\]'],
    ['sun-direction-eqn-sr',
     'The direction of the Earth from the center of the celestial sphere, ' +
     'a sub Earth, equals minus 360 degrees divided by 365, times the ' +
     'quantity N plus 10.8, where N is the day of the year. The direction ' +
     'of the Sun, a sub Sun, is a sub Earth plus 180 degrees.']
  );
}
window.klunlInitEqn = klunlInitEqn;

// kl-unl-mathjax.js only DEFINES klunlInitEqn; each sim is responsible for calling it
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
  const root = document.getElementById('sun-direction-eqn');
  if (typeof klunlDetabEquation === 'function') klunlDetabEquation(root);
  else {
    document.querySelectorAll('.sim-equation__math [tabindex]')
      .forEach((node) => { node.setAttribute('tabindex', '-1'); });
  }
}

/* --- start-up ------------------------------------------------------------ */

function wireControls() {
  const sphere = state.viewer.sphere;

  // Block exponential notation in numeric fields.
  /*
  ['day-number', 'dom-number', 'azimuth-number', 'elevation-number'].forEach((id) => {
    el[id].addEventListener('keydown', noEinNumber);
  });
  */

  // Each control writes into the same state object; render() then redraws
  // everything from it, so typed values, sliders and the drag stay in step.
  const apply = {
    day:       (v) => state.viewer.setDayOfYear(snapDay(v)),
    azimuth:   (v) => sphere.setViewerAzimuth(v),
    elevation: (v) => sphere.setPhi(v)
  };

  // Track click jumps the native range in one step, which would skip the
  // continent spin that continuous scrubbing shows. Detect thumb vs track and
  // tween large track jumps through intermediate days (capped duration).
  const DAY_JUMP_EPS =    0.05;
  const THUMB_HIT_PX =   14;
  const MS_PER_DAY   =  200;
  const TWEEN_MIN_MS =  200;
  const TWEEN_MAX_MS = 1200;

  let dayPointer = null; // { fromDay, onThumb } while a pointer is down on the timeline

  const prefersReducedMotion = () =>
    window.matchMedia('(prefers-reduced-motion: reduce)').matches;

  const startDayTween = (fromDay, toDay) => {
    cancelDayTween();
    const delta    = Math.abs(toDay - fromDay);
    const duration = Math.min(TWEEN_MAX_MS, Math.max(TWEEN_MIN_MS, delta * MS_PER_DAY));
    const t0       = performance.now();
    const tween    = { rafId: 0, target: toDay, announceOnEnd: true };
    dayTween       = tween;

    const tick = (now) => {
      if (dayTween !== tween) return;
      const t = Math.min(1, (now - t0) / duration);
      apply.day(fromDay + (toDay - fromDay) * t);
      update();
      if (t < 1) {
        tween.rafId = requestAnimationFrame(tick);
        return;
      }
      dayTween = null;
      apply.day(toDay);
      update(tween.announceOnEnd ? { announceText: describeScene() } : undefined);
    };
    tween.rafId = requestAnimationFrame(tick);
  };

  const dayThumbX = (slider) => {
    const rect  = slider.getBoundingClientRect();
    const min   = Number(slider.min);
    const max   = Number(slider.max);
    const val   = Number(slider.value);
    const ratio = (max === min) ? 0 : (val - min) / (max - min);
    return rect.left + ratio * rect.width;
  };

  const range = el['day-range'];

  range.addEventListener('pointerdown', (event) => {
    cancelDayTween();
    dayPointer = {
      fromDay: snapDay(state.viewer.dayInput),
      onThumb: Math.abs(event.clientX - dayThumbX(range)) <= THUMB_HIT_PX
    };
  });
  const clearDayPointer = () => { dayPointer = null; };
  range.addEventListener('pointerup',     clearDayPointer);
  range.addEventListener('pointercancel', clearDayPointer);

  range.addEventListener('input', () => {
    const target = snapDay(Number(range.value));
    if (Number.isNaN(target)) return;

    const fromDay = dayPointer ? dayPointer.fromDay : snapDay(state.viewer.dayInput);
    const onThumb = dayPointer ? dayPointer.onThumb : true;
    const jump    = Math.abs(target - fromDay) > DAY_JUMP_EPS;

    if (onThumb || prefersReducedMotion() || !jump) {
      cancelDayTween();
      state.editing = range;
      apply.day(target);
      update();
      state.editing = null;
      return;
    }

    // Track click: animate through intermediate days, then treat further
    // pointer motion in this gesture as a live scrub.
    startDayTween(fromDay, target);
    if (dayPointer) dayPointer.onThumb = true;
  });

  range.addEventListener('change', () => {
    if (dayTween) {
      dayTween.announceOnEnd = true;
      return;
    }
    const min = Number(range.min), max = Number(range.max);
    let v = Number(range.value);
    if (range.value === '' || Number.isNaN(v)) v = min;
    v = snapDay(Math.min(max, Math.max(min, v)));
    apply.day(v);
    update({ announceText: describeScene() });
  });

  // Timeline step is 0.01 for pointer scrubbing (initPrecision = 2), but
  // keyboard arrows use whole days so the control stays usable.
  range.addEventListener('keydown', (event) => {
    const keys = ['ArrowLeft', 'ArrowRight', 'ArrowUp', 'ArrowDown',
                  'PageUp', 'PageDown', 'Home', 'End'];
    if (!keys.includes(event.key)) return;
    event.preventDefault();
    cancelDayTween();
    const min  = Number(range.min);
    const max  = Number(range.max);
    let day    = snapDay(Number(range.value) || 0);
    const step = keyAccel(event, 1);
    switch (event.key) {
      case 'ArrowLeft':
      case 'ArrowUp':
        day -= step;
        break;
      case 'ArrowRight':
      case 'ArrowDown':
        day += step;
        break;
      case 'PageUp':
        day -= keyAccel(event, 10);
        break;
      case 'PageDown':
        day += keyAccel(event, 10);
        break;
      case 'Home':
        day = min;
        break;
      case 'End':
        day = max;
        break;
    }
    day = snapDay(Math.min(max, Math.max(min, day)));
    apply.day(day);
    update({ announceText: describeScene() });
  });

  const stage = el.stage;
  stage.addEventListener('pointerdown',   onPointerDown);
  stage.addEventListener('pointermove',   onPointerMove);
  stage.addEventListener('pointerup',     onPointerUp);
  stage.addEventListener('pointercancel', onPointerUp);
  stage.addEventListener('keydown',       onStageKeyDown);

  // The masthead dispatches a bubbling, composed "sim-reset" CustomEvent.
  document.addEventListener('sim-reset', resetSim);

  window.addEventListener(  'resize', resizeCanvas);
}

function init() {
  cacheElements();
  state.viewer = new ZodiacViewer();
  state.canvas = el['stage-canvas'];
  state.ctx    = state.canvas.getContext('2d');

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
