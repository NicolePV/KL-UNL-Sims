'use strict';
/* ===========================================================================
   Variable Star Photometry Analyzer — HTML5 port
   Behavior ported verbatim from the decompiled ActionScript 3 source:
     variableStarPhotometryAnalyzer_fla/MainTimeline.as
     edu/unl/astro/starField/{StarField,Star,PulsatingStar,EclipsingBinary,
                              AiryDisc,GammaTransferFunction,PixelMask}.as
     edu/unl/astro/utils/{Plot,PlotSeries}.as
     StarHalo.as, DeltaMagOverlay.as
   All constants, tables, formulas and number formats are copied exactly.
   Presentation follows the KL-UNL foundation and WCAG 2.1 AA.
   =========================================================================== */

/* ============================ Canvas geometry ============================ */
/* The plots keep the ORIGINAL internal plot dimensions (380x260 and 650x230)
   so tick spacing and zoom limits match the AS source exactly. Margins around
   each plot hold the canvas-drawn tick labels. */
const STARFIELD_W = 400, STARFIELD_H = 300;          // starField.dimensions
const LC = { plotW: 380, plotH: 260, mL: 56, mT: 12, mR: 16, mB: 40 };
LC.canvasW = LC.mL + LC.plotW + LC.mR;               // 452
LC.canvasH = LC.mT + LC.plotH + LC.mB;               // 312
LC.ox = LC.mL; LC.oy = LC.mT + LC.plotH;             // plot origin (bottom-left)
const PDM = { plotW: 650, plotH: 230, mL: 56, mT: 12, mR: 16, mB: 36 };
PDM.canvasW = PDM.mL + PDM.plotW + PDM.mR;           // 722
PDM.canvasH = PDM.mT + PDM.plotH + PDM.mB;           // 278
PDM.ox = PDM.mL; PDM.oy = PDM.mT + PDM.plotH;

const PLOT_FONT = '12px Verdana, "Verdana Embedded", Geneva, "DejaVu Sans", sans-serif';

/* ========================= AiryDisc (IPSF) port ========================== */
/* Airy pattern point spread function: I(r) = 4*J1(r)^2 / r^2, scaled so the
   first zero of J1 (3.831705970256774) falls at the disc radius. */
class AiryDisc {
  constructor(radius) {
    this._radius = 0; this._center = 0; this._size = 0; this._data = [];
    this.radius = (radius === undefined) ? 6 : radius;
  }
  get radius() { return this._radius; }
  set radius(r) {
    r = Math.floor(r);
    if (r < 2) return;
    this._radius = r;
    this._center = this._radius - 1;
    this._size = 2 * this._radius - 1;
    this.reset();
  }
  get x() { return this._center; }
  get y() { return this._center; }
  get width() { return this._size; }
  get height() { return this._size; }
  get data() { return this._data; }
  reset() {
    const c = this._center;
    const scale = 3.831705970256774 / this._radius;
    this._data = [];
    for (let i = 0; i < this._size; i++) this._data[i] = [];
    for (let i = 0; i < this._radius; i++) {
      const xr = scale * i;
      for (let j = 0; j <= i; j++) {
        const yr = scale * j;
        const r2 = xr * xr + yr * yr;
        let v;
        if (r2 >= 14.681970642501405) {
          v = 0;
        } else {
          const j1 = AiryDisc.getJ1(Math.sqrt(r2));
          v = 4 * j1 * j1 / r2;
        }
        this._data[c + i][c - j] = v;
        this._data[c + j][c - i] = v;
        this._data[c - j][c - i] = v;
        this._data[c - i][c - j] = v;
        this._data[c - i][c + j] = v;
        this._data[c - j][c + i] = v;
        this._data[c + j][c + i] = v;
        this._data[c + i][c + j] = v;
      }
    }
    this._data[c][c] = 1;
  }
  /* Bessel function J1 rational approximation (verbatim coefficients). */
  static getJ1(x) {
    let y, p, q, result;
    const ax = Math.abs(x);
    if (ax < 8) {
      y = x * x;
      p = x * (72362614232 + y * (-7895059235 + y * (242396853.1 + y * (-2972611.439 + y * (15704.4826 + y * -30.16036606)))));
      q = 144725228442 + y * (2300535178 + y * (18583304.74 + y * (99447.43394 + y * (376.9991397 + y * 1))));
      result = p / q;
    } else {
      const z = 8 / ax;
      y = z * z;
      const xx = ax - 2.356194491;
      p = 1 + y * (0.00183105 + y * (-0.00003516396496 + y * (0.000002457520174 + y * -2.40337019e-7)));
      q = 0.04687499995 + y * (-0.0002002690873 + y * (0.000008449199096 + y * (-8.8228987e-7 + y * 1.05787412e-7)));
      result = Math.sqrt(0.636619772 / ax) * (Math.cos(xx) * p - z * Math.sin(xx) * q);
      if (x < 0) result = -result;
    }
    return result;
  }
}

/* ==================== GammaTransferFunction port ========================= */
/* Grayscale gamma mapping: level = 255 * (counts/peak)^(1/gamma), gamma=1.8 */
class GammaTransferFunction {
  constructor() {
    this._gamma = 1.8;
    this._peakValue = 0;
    this._table = null;
  }
  set peakValue(p) {
    if (!isFinite(p) || isNaN(p) || p <= 0 || this._peakValue === p) return;
    this._peakValue = p;
    this.refresh();
  }
  get peakValue() { return this._peakValue; }
  refresh() {
    const n = this._peakValue + 1;
    this._table = new Uint32Array(n);
    for (let v = 0; v < n; v++) {
      const level = Math.floor(255 * Math.pow(v / this._peakValue, 1 / this._gamma));
      this._table[v] = (level << 16) | (level << 8) | level;
    }
    /* highlightSaturatedPixels defaults to false: peak maps to white. */
    this._table[this._peakValue] = 16777215;
  }
  getColor(v) { return this._table[v]; }
}

/* ========================= PixelMask port ================================ */
/* Circular boolean mask of radius r inside a (2r+1)^2 square. */
class PixelMask {
  constructor(radius) { this.radius = (radius === undefined) ? 6 : radius; this.left = 0; this.top = 0; }
  set radius(r) {
    this._radius = r;
    const size = 2 * r + 1;
    const r2 = r * r;
    this.data = [];
    for (let i = 0; i < size; i++) {
      const dx = -r + i;
      this.data[i] = [];
      for (let j = 0; j < size; j++) {
        const dy = -r + j;
        this.data[i][j] = (dx * dx + dy * dy) <= r2;
      }
    }
    this.width = size;
    this.height = size;
  }
  get radius() { return this._radius; }
}

/* ===================== Star / PulsatingStar / EclipsingBinary =========== */
class Star {
  constructor(settings) {
    this.x = 0; this.y = 0; this.epoch = 0; this._magnitude = 0;
    if (settings) {
      if (typeof settings.x === 'number') this.x = settings.x;
      if (typeof settings.y === 'number') this.y = settings.y;
      if (typeof settings.magnitude === 'number') this._magnitude = settings.magnitude;
    }
  }
  get magnitude() { return this._magnitude; }
}

class PulsatingStar extends Star {
  /* magnitude(t) = m0 + sum_k A_k * cos( (k+1) * 2*pi*(t - t0)/P + phi_k ) */
  constructor(settings, preset) {
    super(settings);
    this._functionUsed = 'cos';
    this._fourierTermsList = [];
    this._phaseOffset = 0;
    this._period = 3;
    this._centerMagnitude = 0;
    const sources = [settings, preset];
    for (const s of sources) {
      if (!s) continue;
      if (typeof s.phaseOffset === 'number') this._phaseOffset = s.phaseOffset;
      if (typeof s.period === 'number' && s.period > 0) this._period = s.period;
      if (s.functionUsed === 'cos' || s.functionUsed === 'sin') this._functionUsed = s.functionUsed;
      if (typeof s.centerMagnitude === 'number') this._centerMagnitude = s.centerMagnitude;
      if (Array.isArray(s.fourierTermsList)) this._fourierTermsList = s.fourierTermsList.map(t => ({ A: t.A, phi: t.phi }));
    }
  }
  get magnitude() {
    const fn = Math[this._functionUsed];
    let m = this._centerMagnitude;
    const w = 2 * Math.PI * (this.epoch - this._phaseOffset) / this._period;
    for (let k = 0; k < this._fourierTermsList.length; k++) {
      m += this._fourierTermsList[k].A * fn((k + 1) * w + this._fourierTermsList[k].phi);
    }
    return m;
  }
}
/* Fourier presets for real Cepheid / RR Lyrae light curves (verbatim). */
PulsatingStar.PRESETS = {
  del_Cep: { period: 5.366341, functionUsed: 'cos', actualCenterMagnitude: 3.988,
    fourierTermsList: [{ A: 0.3496, phi: 2.491 }, { A: 0.1385, phi: 3.084 }, { A: 0.05499, phi: 3.811 }, { A: 0.02277, phi: 4.083 }, { A: 0.009765, phi: 4.709 }] },
  RT_Mus: { period: 3.08617, functionUsed: 'cos', actualCenterMagnitude: 9.03,
    fourierTermsList: [{ A: 0.331, phi: 0.0277 }, { A: 0.131, phi: 4.13 }, { A: 0.0503, phi: 2.24 }, { A: 0.0416, phi: 6.16 }] },
  AS_Per: { period: 4.972516, functionUsed: 'cos', actualCenterMagnitude: 9.76,
    fourierTermsList: [{ A: 0.3583, phi: 2.468 }, { A: 0.1443, phi: 3.084 }, { A: 0.05731, phi: 3.65 }, { A: 0.02603, phi: 3.695 }, { A: 0.0211, phi: 4.625 }] },
  S_Nor: { period: 9.75411, functionUsed: 'cos', actualCenterMagnitude: 6.4354,
    fourierTermsList: [{ A: 0.2874, phi: 3.1842 }, { A: 0.0191, phi: 4.6142 }, { A: 0.0296, phi: 2.7042 }, { A: 0.0144, phi: 3.3482 }, { A: 0.018, phi: 3.0182 }, { A: 0.0159, phi: 3.4322 }] },
  PZ_Aql: { period: 8.7513, functionUsed: 'cos', actualCenterMagnitude: 11.7,
    fourierTermsList: [{ A: 0.365, phi: 4.66 }, { A: 0.0459, phi: 1.75 }, { A: 0.0208, phi: 2.76 }, { A: 0.0188, phi: 5.98 }] },
  MT_Tel: { period: 0.316897, functionUsed: 'cos', actualCenterMagnitude: 9.01,
    fourierTermsList: [{ A: 0.26, phi: 1.93 }, { A: 0.0735, phi: 1.89 }, { A: 0.0166, phi: 1.85 }, { A: 0.01, phi: 1.95 }, { A: 0.0056, phi: 1.35 }, { A: 0.00489, phi: 1.48 }, { A: 0.00453, phi: 1.62 }, { A: 0.00151, phi: 1.11 }] },
  RR_Leo: { period: 0.4523933, functionUsed: 'cos', actualCenterMagnitude: 10.83,
    fourierTermsList: [{ A: 0.455, phi: 0.691 }, { A: 0.228, phi: 5.16 }, { A: 0.161, phi: 3.69 }, { A: 0.0991, phi: 2.33 }, { A: 0.0779, phi: 1.02 }, { A: 0.0491, phi: 5.81 }, { A: 0.0327, phi: 4.45 }, { A: 0.0314, phi: 2.97 }] },
  VX_Her: { period: 0.45537282, functionUsed: 'cos', actualCenterMagnitude: 10.78,
    fourierTermsList: [{ A: 0.458, phi: 4.51 }, { A: 0.212, phi: 0.261 }, { A: 0.164, phi: 2.56 }, { A: 0.106, phi: 4.96 }, { A: 0.0733, phi: 1.07 }, { A: 0.0592, phi: 3.57 }, { A: 0.0362, phi: 6.07 }, { A: 0.027, phi: 2.2 }] }
};

class EclipsingBinary extends Star {
  constructor(settings, preset) {
    super(settings);
    this._peakMagnitude = 0;
    this._argument = 162.8 * (Math.PI / 180);
    this._temperature2 = 6530;
    this._inclination = 85.66 * (Math.PI / 180);
    this._temperature1 = 8730;
    this._phaseOffset = 0;
    this._radius1 = 1.7 * EclipsingBinary.SOLAR_RADIUS;
    this._radius2 = 1.5 * EclipsingBinary.SOLAR_RADIUS;
    this._mass1 = 1.9 * EclipsingBinary.SOLAR_MASS;
    this._mass2 = 1.4 * EclipsingBinary.SOLAR_MASS;
    this._eccentricity = 0.33;
    this._separation = 10.87 * EclipsingBinary.SOLAR_RADIUS;
    const sources = [settings, preset];
    for (const s of sources) {
      if (!s) continue;
      if (typeof s.argument === 'number') this._argument = s.argument * (Math.PI / 180);
      if (typeof s.inclination === 'number') this._inclination = s.inclination * (Math.PI / 180);
      if (typeof s.eccentricity === 'number' && s.eccentricity >= 0 && s.eccentricity < 1) this._eccentricity = s.eccentricity;
      if (typeof s.separation === 'number' && s.separation > 0) this._separation = s.separation * EclipsingBinary.SOLAR_RADIUS;
      if (typeof s.phaseOffset === 'number') this._phaseOffset = s.phaseOffset;
      if (typeof s.peakMagnitude === 'number') this._peakMagnitude = s.peakMagnitude;
      if (typeof s.mass1 === 'number' && s.mass1 > 0) this._mass1 = s.mass1 * EclipsingBinary.SOLAR_MASS;
      if (typeof s.mass2 === 'number' && s.mass2 > 0) this._mass2 = s.mass2 * EclipsingBinary.SOLAR_MASS;
      if (typeof s.radius1 === 'number' && s.radius1 > 0) this._radius1 = s.radius1 * EclipsingBinary.SOLAR_RADIUS;
      if (typeof s.radius2 === 'number' && s.radius2 > 0) this._radius2 = s.radius2 * EclipsingBinary.SOLAR_RADIUS;
      if (typeof s.temperature1 === 'number' && s.temperature1 > 0) this._temperature1 = s.temperature1;
      if (typeof s.temperature2 === 'number' && s.temperature2 > 0) this._temperature2 = s.temperature2;
    }
    this.calculateConstants();
  }
  /* Piecewise 5th-order bolometric correction in log10(T) (verbatim tables). */
  getBolometricCorrection(temperature) {
    const logT = Math.log(temperature) / Math.LN10;
    let c;
    if (logT > 3.9) {
      c = { a: -100139.4991, b: 116264.1842, c: -53931.97541, d: 12495.04227, e: -1445.868048, f: 66.84924471 };
    } else if (logT < 3.7) {
      c = { a: -13884.14899, b: 8595.127427, c: -488.3425525, d: -627.0092238, e: 137.4608131, f: -7.549572042 };
    } else {
      c = { a: 1439.981506, b: -151.9002581, c: -995.1089203, d: 582.5176671, e: -123.3293641, f: 9.160761128 };
    }
    return c.a + logT * (c.b + logT * (c.c + logT * (c.d + logT * (c.e + c.f * logT))));
  }
  calculateConstants() {
    this._C1 = Math.sqrt((1 + this._eccentricity) / (1 - this._eccentricity));
    const cosI = Math.cos(this._inclination);
    const p = this._separation * (1 - this._eccentricity * this._eccentricity);
    this._J1 = p * p * (1 - cosI * cosI);
    this._J2 = p * p * cosI * cosI;
    this._J3 = 2 * this._eccentricity;
    this._J4 = this._eccentricity * this._eccentricity;
    this._R12 = this._radius1 * this._radius1;
    this._R22 = this._radius2 * this._radius2;
    this._Z0 = 1 / (2 * this._radius2);
    this._Z1 = (this._R22 - this._R12) * this._Z0;
    this._Z2 = 1 / (2 * this._radius1);
    this._Z3 = (this._R12 - this._R22) * this._Z2;
    const bc1 = this.getBolometricCorrection(this._temperature1);
    const bc2 = this.getBolometricCorrection(this._temperature2);
    /* Surface flux terms H = 1.89553328524593e-43 * T^4 * 10^(BC/2.5) */
    this._H1 = 1.89553328524593e-43 * Math.pow(this._temperature1, 4) * Math.pow(10, bc1 / 2.5);
    this._H2 = 1.89553328524593e-43 * Math.pow(this._temperature2, 4) * Math.pow(10, bc2 / 2.5);
    this._maxVisFlux = (this._R12 * this._H1 + this._R22 * this._H2) * Math.PI;
    this._minVisMag = -18.9669559998301 - 2.5 / Math.LN10 * Math.log(this._maxVisFlux);
    /* Kepler's third law: P = sqrt(4*pi^2*a^3 / (G*(m1+m2))) in days */
    this._period = Math.sqrt(4 * Math.PI * Math.PI * this._separation * this._separation * this._separation /
      (6.673e-11 * (this._mass1 + this._mass2))) / (24 * 60 * 60);
    this._distanceModulus = this._peakMagnitude - this._minVisMag;
  }
  get magnitude() {
    /* Solve Kepler's equation, then compute the mutually-eclipsed area of two
       uniform discs and the resulting visual magnitude (verbatim port). */
    const M = 2 * Math.PI * (this.epoch - this._phaseOffset) / this._period;
    let Eprev = 0, E = M, iter = 0;
    do {
      Eprev = E;
      E = Eprev + (M + this._eccentricity * Math.sin(Eprev) - Eprev) / (1 - this._eccentricity * Math.cos(Eprev));
      iter++;
    } while (Math.abs(E - Eprev) > 0.001 && iter < 100);
    if (iter >= 100) {
      throw new Error('iteration limit reached in EclipsingBinary, maybe eccentricity is too high');
    }
    const nu = 2 * Math.atan(this._C1 * Math.tan(E / 2));
    const cosNu = Math.cos(nu);
    const cosNuArg = Math.cos(nu + this._argument);
    let d = Math.sqrt((this._J1 * cosNuArg * cosNuArg + this._J2) / (1 + this._J3 * cosNu + this._J4 * cosNu * cosNu));
    if (d === 0) d = 1e-8;
    let q1 = this._Z0 * d + this._Z1 / d;
    let q2 = this._Z2 * d + this._Z3 / d;
    if (q1 < -1) q1 = -1; else if (q1 > 1) q1 = 1;
    if (q2 < -1) q2 = -1; else if (q2 > 1) q2 = 1;
    const a1 = Math.acos(q1);
    const a2 = Math.acos(q2);
    const overlap = this._R22 * (a1 - q1 * Math.sin(a1)) + this._R12 * (a2 - q2 * Math.sin(a2));
    const frontIs1 = (((nu + this._argument) % (2 * Math.PI) + 2 * Math.PI) % (2 * Math.PI)) < Math.PI;
    const flux = frontIs1 ? this._maxVisFlux - this._H1 * overlap : this._maxVisFlux - this._H2 * overlap;
    const mag = -18.9669559998301 - 2.5 / Math.LN10 * Math.log(flux);
    return this._distanceModulus + mag;
  }
}
EclipsingBinary.SOLAR_MASS = 1.98892e+30;
EclipsingBinary.SOLAR_RADIUS = 695500000;
/* Real eclipsing-binary presets (verbatim). */
EclipsingBinary.PRESETS = {
  TW_Cas: { argument: 0, inclination: 74.7, eccentricity: 0, separation: 8.17,
    mass1: 2.5, radius1: 2, temperature1: 10500, mass2: 1.1, radius2: 2.6, temperature2: 5400 },
  AG_Phi: { argument: 0, inclination: 87.624, eccentricity: 0, separation: 4.22,
    mass1: 1.53, radius1: 1.7, temperature1: 7500, mass2: 0.24, radius2: 1, temperature2: 5400 },
  V477_Cyg: { argument: 162.8, inclination: 85.66, eccentricity: 0.33, separation: 10.87,
    mass1: 1.9, radius1: 1.7, temperature1: 8730, mass2: 1.4, radius2: 1.5, temperature2: 6530 },
  CW_CMa: { argument: 0, inclination: 83.3, eccentricity: 0, separation: 11.92,
    mass1: 2.6, radius1: 2.1, temperature1: 10800, mass2: 2.5, radius2: 1.9, temperature2: 10300 },
  EK_Cep: { argument: 49.8, inclination: 89.16, eccentricity: 0.11, separation: 16.58,
    mass1: 2, radius1: 1.6, temperature1: 9000, mass2: 1.1, radius2: 1.3, temperature2: 5690 },
  V526_Sgr: { argument: 254.8, inclination: 87.3, eccentricity: 0.22, separation: 10.43,
    mass1: 2.4, radius1: 1.9, temperature1: 10100, mass2: 1.8, radius2: 1.6, temperature2: 8450 },
  T_LMi: { argument: 0, inclination: 86.3, eccentricity: 0, separation: 11.97,
    mass1: 2.3, radius1: 1.9, temperature1: 9860, mass2: 0.23, radius2: 2.4, temperature2: 5060 }
};

/* ============================ StarField port ============================= */
/* Simulated CCD field: gaussian read noise generated once with a fixed
   linear congruential generator (minimal standard: s = s*16807 mod 2^31-1),
   shuffled per observation in chunks by the observation's noiseSeed, plus
   each star's Airy-disc flux:  counts = peak * 10^((satMag - m)/2.5) * PSF. */
class StarFieldModel {
  constructor() {
    this.epoch = 0;
    this.shuffleSeed = 1;
    this.locked = false;
    this.starsList = [];
    this.noiseData = null;
    this.fieldData = null;
    this.chunkTable = null;
    this.bitDepth = 16;
    this.peakValue = Math.pow(2, 16) - 1;             // 65535
    this.saturationMagnitude = 3;
    this.noiseMean = 0;
    this.noiseSigma = 1000;
    this.psf = null;
    this.transferFunction = null;
    this._callGenerateNoise = true;
    this.onFieldChanged = null;
  }
  setDimensions(w, h) {
    this.width = w;
    this.height = h;
    this.numChunks = Math.floor(0.7 * this.width);    // int(0.7*400) = 280
    this.chunkSize = Math.ceil(this.width * this.height / this.numChunks);
    if (this.chunkSize % 2 === 1) this.chunkSize += 1; // 430
    this.chunkTable = new Int32Array(this.numChunks);
    this._callGenerateNoise = true;
    this.update();
  }
  lock() { this.locked = true; }
  unlock() { this.locked = false; this.update(); }
  setEpochAndNoiseSeed(epoch, seed) {
    if (!isFinite(epoch) || isNaN(epoch)) return;
    if (!isFinite(seed) || isNaN(seed) || seed < 1 || seed > 2147483646) return;
    this.epoch = epoch;
    this.shuffleSeed = seed;
    this.update();
  }
  addStar(star) { this.starsList.push(star); this.update(); }
  generateNoise() {
    /* Box-Muller (polar form) gaussian pairs from the fixed-seed LCG. */
    const total = this.numChunks * this.chunkSize;
    this.noiseData = new Float64Array(total);
    let u = 1;
    let i = 0;
    while (i < total) {
      let v1, v2, s;
      do {
        v1 = 2 * (u / 2147483647) - 1;
        u = (u * 16807) % 2147483647;
        v2 = 2 * (u / 2147483647) - 1;
        u = (u * 16807) % 2147483647;
        s = v1 * v1 + v2 * v2;
      } while (s >= 1);
      s = Math.sqrt(-2 * Math.log(s) / s);
      this.noiseData[i] = this.noiseMean + this.noiseSigma * v1 * s;
      i++;
      this.noiseData[i] = this.noiseMean + this.noiseSigma * v2 * s;
      i++;
    }
    this._callGenerateNoise = false;
  }
  shuffleNoise() {
    /* Fisher-Yates chunk permutation driven by the observation noise seed. */
    let seed = this.shuffleSeed;
    const n = this.numChunks;
    for (let i = 0; i < n; i++) this.chunkTable[i] = i;
    for (let i = 0; i < n - 1; i++) {
      const j = i + Math.floor((n - i) * (seed / 2147483647));
      seed = (seed * 16807) % 2147483647;
      const tmp = this.chunkTable[j];
      this.chunkTable[j] = this.chunkTable[i];
      this.chunkTable[i] = tmp;
    }
  }
  update() {
    if (this.locked || this.transferFunction == null || this.psf == null) return;
    if (this._callGenerateNoise) this.generateNoise();
    this.shuffleNoise();
    this.fieldData = Float64Array.from(this.noiseData);
    const psf = this.psf;
    for (let s = 0; s < this.starsList.length; s++) {
      const star = this.starsList[s];
      star.epoch = this.epoch;
      /* Star peak counts: peak * 10^((saturationMagnitude - m)/2.5) */
      const flux = this.peakValue * Math.pow(10, (this.saturationMagnitude - star.magnitude) / 2.5);
      const left = star.x - psf.x;
      const top = star.y - psf.y;
      for (let i = 0; i < psf.width; i++) {
        const x = left + i;
        if (x >= 0) {
          if (x >= this.width) break;
          const col = psf.data[i];
          for (let j = 0; j < psf.height; j++) {
            const y = top + j;
            const v = col[j];
            if (!(v <= 0 || y < 0)) {
              if (y >= this.height) break;
              const n = x + y * this.width;
              const chunk = Math.floor(n / this.chunkSize);
              const off = n - chunk * this.chunkSize;
              this.fieldData[off + this.chunkSize * this.chunkTable[chunk]] += flux * v;
            }
          }
        }
      }
    }
    if (this.onFieldChanged) this.onFieldChanged();
  }
  /* Aperture statistics inside a circular PixelMask (verbatim port,
     including its boundary/break semantics). */
  getStatistics(mask) {
    let clipped = false, totalCounts = 0, totalPixels = 0;
    for (let i = 0; i < mask.width; i++) {
      const x = mask.left + i;
      if (x < 0) {
        clipped = true;
      } else {
        if (x >= this.width) { clipped = true; break; }
        for (let j = 0; j < mask.height; j++) {
          const y = mask.top + j;
          if (y < 0) {
            clipped = true;
          } else {
            if (y >= this.height) { clipped = true; break; }
            if (mask.data[i][j]) {
              const n = x + y * this.width;
              const chunk = Math.floor(n / this.chunkSize);
              const off = n - chunk * this.chunkSize;
              let v = this.fieldData[off + this.chunkSize * this.chunkTable[chunk]];
              if (v < 0) v = 0; else if (v > this.peakValue) v = this.peakValue;
              totalCounts += Math.floor(v);
              totalPixels++;
            }
          }
        }
      }
    }
    return { totalCounts, totalPixels, clipped, average: totalCounts / totalPixels };
  }
  /* Paint the current field into an ImageData (display fields only). */
  paintInto(imageData) {
    const px = imageData.data;
    const total = this.width * this.height;
    const tf = this.transferFunction;
    for (let n = 0; n < total; n++) {
      const chunk = Math.floor(n / this.chunkSize);
      const off = n - chunk * this.chunkSize;
      let v = this.fieldData[off + this.chunkSize * this.chunkTable[chunk]];
      if (v < 0) v = 0; else if (v > this.peakValue) v = this.peakValue;
      const rgb = tf.getColor(Math.floor(v));
      const o = n * 4;
      px[o] = (rgb >> 16) & 255;
      px[o + 1] = (rgb >> 8) & 255;
      px[o + 2] = rgb & 255;
      px[o + 3] = 255;
    }
  }
}

/* ============================== Plot port ================================ */
/* Port of edu.unl.astro.utils.Plot: axis/tick generation, series rendering
   with region-code clipping, and the drag-to-zoom window (xZoomOnly mode). */
function cubicEaseInOut(t, b, c, d) {
  /* fl.motion.easing.Cubic.easeInOut */
  if ((t /= d / 2) < 1) return c / 2 * t * t * t + b;
  return c / 2 * ((t -= 2) * t * t + 2) + b;
}

class SimPlot {
  constructor() {
    this.xAxis = { min: 0, max: 10, length: 350, minSpacingForTickmarks: 9, minSpacingForLabels: 34, inverted: false };
    this.yAxis = { min: 0, max: 10, length: 250, minSpacingForTickmarks: 9, minSpacingForLabels: 25, inverted: false };
    this.tickmarkLengths = { long: 6, medium: 4, short: 2 };
    this.tickmarkLabelsPosition = 7;
    this.borderColor = '#000000';
    this.backgroundColor = '#ffffff';
    this.series = [];
    this.xZoomRangeLimit = NaN;
    this.zoomWindowFillColor = '#C4CCC4';   // 12897476
    this.zoomWindowFillAlpha = 0.1;
    this.zoomWindowBorderColor = '#C4CCC4';
    this.zoomWindowBorderAlpha = 0.5;
    this.zoomWindowBorderThickness = 1;
    this.zoomAnimationTime = 1000;          // ms, verbatim
    this.doZoomAnimation = true;
    this.zoomMode = 'none';
    this.zoomWindowParams = null;
    this.zoomAnimationParams = null;
    this.zoomAnimationInProgress = false;
    this.onZoomStart = null;
    this.onZoomStep = null;
    this.onZoomDone = null;
  }
  setPlotDimensions(w, h) { this.xAxis.length = w; this.yAxis.length = h; }
  getPlotDimensions() { return { width: this.xAxis.length, height: this.yAxis.length }; }
  setXAxisRange(min, max) {
    if (!isFinite(min) || isNaN(min) || !isFinite(max) || isNaN(max) || min === max) return;
    this.clearZoomWindow();
    this.cancelZoomAnimation();
    if (min > max) { const t = min; min = max; max = t; }
    this.xAxis.min = min;
    this.xAxis.max = max;
  }
  setYAxisRange(min, max) {
    if (!isFinite(min) || isNaN(min) || !isFinite(max) || isNaN(max) || min === max) return;
    this.clearZoomWindow();
    this.cancelZoomAnimation();
    if (min > max) { const t = min; min = max; max = t; }
    this.yAxis.min = min;
    this.yAxis.max = max;
  }
  getXAxisRange() { return { min: this.xAxis.min, max: this.xAxis.max }; }
  getYAxisRange() { return { min: this.yAxis.min, max: this.yAxis.max }; }

  /* Tick generation — verbatim port of getTickmarksInfo(). */
  getTickmarksInfo(axis) {
    const pxPerUnit = axis.length / (axis.max - axis.min);
    const minTickSpacing = axis.minSpacingForTickmarks / pxPerUnit;
    const minLabelSpacing = axis.minSpacingForLabels / pxPerUnit;
    let exp = Math.ceil(Math.log(minTickSpacing) / Math.LN10);
    let spacing = Math.pow(10, exp);
    let longMod = 0, medMod = 0, labelMod = 0;
    let m;
    if (spacing / 2 >= minTickSpacing) {
      spacing /= 2;
      longMod = 20;
      medMod = 2;
      m = 1;
      while (m <= 100000) {
        if (minLabelSpacing <= m * spacing) { labelMod = m; exp--; break; }
        if (minLabelSpacing <= 2 * m * spacing) { labelMod = 2 * m; break; }
        exp += 1;
        m *= 10;
      }
    } else {
      longMod = 10;
      medMod = 5;
      m = 1;
      while (m <= 100000) {
        if (minLabelSpacing <= m * spacing) { labelMod = m; break; }
        if (minLabelSpacing <= 5 * m * spacing) { labelMod = 5 * m; break; }
        exp += 1;
        m *= 10;
      }
    }
    const i0 = Math.ceil(axis.min / spacing);
    const i1 = 1 + Math.floor(axis.max / spacing);
    const longList = [], medList = [], shortList = [], labelList = [];
    for (let i = i0; i < i1; i++) {
      const tick = {};
      tick.value = i * spacing;
      tick.position = pxPerUnit * (tick.value - axis.min);
      if (axis.inverted) tick.position = axis.length - tick.position;
      if (i % longMod === 0) longList.push(tick);
      else if (i % medMod === 0) medList.push(tick);
      else shortList.push(tick);
      if (i % labelMod === 0) {
        labelList.push({ position: tick.position, label: SimPlot.getFormattedNumber(tick.value, exp) });
      }
    }
    return { longTickmarksList: longList, mediumTickmarksList: medList, shortTickmarksList: shortList, tickmarkLabelsList: labelList };
  }
  static getFormattedNumber(value, exp) {
    if (exp >= 0) {
      const f = Math.pow(10, exp);
      return String(f * Math.round(value / f));
    }
    return value.toFixed(-exp);
  }

  /* Render everything into ctx with the plot origin (bottom-left corner of
     the plot area) at canvas coordinates (ox, oy). */
  render(ctx, ox, oy) {
    const W = this.xAxis.length, H = this.yAxis.length;
    ctx.save();
    /* background + border */
    ctx.fillStyle = this.backgroundColor;
    ctx.fillRect(ox, oy - H, W, H);
    /* tickmarks (extend outward from the plot rectangle) */
    ctx.strokeStyle = this.borderColor;
    ctx.lineWidth = 1;
    const xInfo = this.getTickmarksInfo(this.xAxis);
    const yInfo = this.getTickmarksInfo(this.yAxis);
    const drawXTicks = (list, len) => {
      ctx.beginPath();
      for (const t of list) {
        const x = Math.round(ox + t.position) + 0.5;
        ctx.moveTo(x, oy);
        ctx.lineTo(x, oy + len);
      }
      ctx.stroke();
    };
    const drawYTicks = (list, len) => {
      ctx.beginPath();
      for (const t of list) {
        const y = Math.round(oy - t.position) + 0.5;
        ctx.moveTo(ox, y);
        ctx.lineTo(ox - len, y);
      }
      ctx.stroke();
    };
    drawXTicks(xInfo.longTickmarksList, this.tickmarkLengths.long);
    drawXTicks(xInfo.mediumTickmarksList, this.tickmarkLengths.medium);
    drawXTicks(xInfo.shortTickmarksList, this.tickmarkLengths.short);
    drawYTicks(yInfo.longTickmarksList, this.tickmarkLengths.long);
    drawYTicks(yInfo.mediumTickmarksList, this.tickmarkLengths.medium);
    drawYTicks(yInfo.shortTickmarksList, this.tickmarkLengths.short);
    /* tick labels */
    ctx.fillStyle = '#000000';
    ctx.font = PLOT_FONT;
    ctx.textAlign = 'center';
    ctx.textBaseline = 'top';
    for (const t of xInfo.tickmarkLabelsList) {
      ctx.fillText(t.label, ox + t.position, oy + this.tickmarkLabelsPosition + 2);
    }
    ctx.textAlign = 'right';
    ctx.textBaseline = 'middle';
    for (const t of yInfo.tickmarkLabelsList) {
      ctx.fillText(t.label, ox - this.tickmarkLabelsPosition, oy - t.position);
    }
    /* series (clipped to the plot rectangle, like the data mask sprite) */
    ctx.save();
    ctx.beginPath();
    ctx.rect(ox, oy - H, W, H);
    ctx.clip();
    for (const s of this.series) this.renderSeries(ctx, ox, oy, s);
    ctx.restore();
    /* plot border on top */
    ctx.strokeStyle = this.borderColor;
    ctx.lineWidth = 1;
    ctx.strokeRect(ox + 0.5, oy - H + 0.5, W - 1, H - 1);
    ctx.restore();
  }

  /* Series drawing — verbatim port of updateSeries() region-code logic. */
  renderSeries(ctx, ox, oy, s) {
    const data = s.data;
    if (!data || data.length === 0) return;
    const xs = this.xAxis.length / (this.xAxis.max - this.xAxis.min);
    const ys = -this.yAxis.length / (this.yAxis.max - this.yAxis.min);
    const xProp = s.xAxisPropertyName || 'x';
    const yProp = s.yAxisPropertyName || 'y';
    const r = s.pointRadius;
    const topLimit = -this.yAxis.length - r;
    const bottomLimit = r;
    const leftLimit = -r;
    const rightLimit = this.xAxis.length + r;
    const toLocal = (item) => {
      let px = xs * (item[xProp] - this.xAxis.min);
      let py = ys * (item[yProp] - this.yAxis.min);
      if (this.xAxis.inverted) px = this.xAxis.length - px;
      if (this.yAxis.inverted) py = -this.yAxis.length - py;
      return [px, py];
    };
    const region = (px, py) => {
      if (px < leftLimit) return 0;
      if (py < topLimit) return 1;
      if (py > bottomLimit) return 2;
      if (px > rightLimit) return 3;
      return 4;
    };
    if (s.showLines) {
      ctx.strokeStyle = s.lineColor;
      ctx.globalAlpha = s.lineAlpha;
      ctx.lineWidth = s.lineThickness;
      ctx.beginPath();
      let [px, py] = toLocal(data[0]);
      let prevRegion = region(px, py);
      ctx.moveTo(ox + px, oy + py);
      for (let i = 1; i < data.length; i++) {
        const [nx, ny] = toLocal(data[i]);
        const reg = region(nx, ny);
        if (reg === 4 || reg !== prevRegion) {
          ctx.lineTo(ox + nx, oy + ny);
        } else {
          ctx.moveTo(ox + nx, oy + ny);
        }
        prevRegion = reg;
      }
      ctx.stroke();
      ctx.globalAlpha = 1;
    }
    if (s.showPoints) {
      ctx.fillStyle = s.pointFillColor;
      ctx.globalAlpha = s.pointFillAlpha;
      ctx.beginPath();
      for (let i = 0; i < data.length; i++) {
        const [px, py] = toLocal(data[i]);
        if (region(px, py) === 4) {
          ctx.moveTo(ox + px + r, oy + py);
          ctx.arc(ox + px, oy + py, r, 0, 2 * Math.PI);
        }
      }
      ctx.fill();
      ctx.globalAlpha = 1;
    }
  }

  /* --- zoom window (xZoomOnly, the only mode this sim uses) --- */
  clearZoomWindow() { this.zoomWindowParams = null; }
  cancelZoomAnimation() {
    if (!this.zoomAnimationInProgress) return;
    this.zoomAnimationInProgress = false;
    this.zoomAnimationParams = null;
    if (this.onZoomDone) this.onZoomDone();
  }
  zoomTo(target) {
    if (this.zoomAnimationInProgress) return;
    const hasMin = typeof target.xMin === 'number' && isFinite(target.xMin);
    const hasMax = typeof target.xMax === 'number' && isFinite(target.xMax);
    if (!hasMin && !hasMax) return;
    this.clearZoomWindow();
    if (!this.doZoomAnimation) {
      /* Reduced-motion / instant path: jump straight to the end state. */
      if (this.onZoomStart) this.onZoomStart();
      this.xAxis.min = target.xMin;
      this.xAxis.max = target.xMax;
      if (this.onZoomDone) this.onZoomDone();
      return;
    }
    this.zoomAnimationParams = {
      xMinAtStart: this.xAxis.min, xMinRange: target.xMin - this.xAxis.min,
      xMaxAtStart: this.xAxis.max, xMaxRange: target.xMax - this.xAxis.max,
      startTime: performance.now()
    };
    if (this.onZoomStart) this.onZoomStart();
    this.zoomAnimationInProgress = true;
  }
  /* Advance the zoom animation; returns true while it is still running. */
  tickZoomAnimation(now) {
    if (!this.zoomAnimationInProgress) return false;
    const p = this.zoomAnimationParams;
    const elapsed = now - p.startTime;
    const f = elapsed >= this.zoomAnimationTime ? 1 : cubicEaseInOut(elapsed, 0, 1, this.zoomAnimationTime);
    this.xAxis.min = p.xMinAtStart + f * p.xMinRange;
    this.xAxis.max = p.xMaxAtStart + f * p.xMaxRange;
    if (f >= 1) {
      this.cancelZoomAnimation();
      return false;
    }
    if (this.onZoomStep) this.onZoomStep();
    return true;
  }
  /* Convert a finalized zoom window into an axis range and start the zoom. */
  commitZoomWindow() {
    const zw = this.zoomWindowParams;
    if (!zw || !zw.isValid) return;
    const xs = this.xAxis.length / (this.xAxis.max - this.xAxis.min);
    let x0 = this.xAxis.min + zw.startX / xs;
    let x1 = this.xAxis.min + zw.endX / xs;
    let lo = Math.min(x0, x1), hi = Math.max(x0, x1);
    if (!isNaN(this.xZoomRangeLimit) && isFinite(this.xZoomRangeLimit) && hi - lo < this.xZoomRangeLimit) {
      const c = lo + (hi - lo) / 2;
      lo = c - this.xZoomRangeLimit / 2;
      hi = c + this.xZoomRangeLimit / 2;
    }
    this.zoomTo({ xMin: lo, xMax: hi });
  }
  renderZoomWindow(ctx, ox, oy) {
    const zw = this.zoomWindowParams;
    if (!zw || zw.endX === undefined) return;
    const H = this.yAxis.length;
    const xA = ox + zw.startX, xB = ox + zw.endX;
    ctx.save();
    ctx.fillStyle = this.zoomWindowFillColor;
    ctx.globalAlpha = this.zoomWindowFillAlpha;
    ctx.fillRect(Math.min(xA, xB), oy - H, Math.abs(xB - xA), H);
    ctx.globalAlpha = this.zoomWindowBorderAlpha;
    ctx.strokeStyle = this.zoomWindowBorderColor;
    ctx.lineWidth = this.zoomWindowBorderThickness;
    ctx.beginPath();
    ctx.moveTo(xA + 0.5, oy); ctx.lineTo(xA + 0.5, oy - H);
    ctx.moveTo(xB + 0.5, oy); ctx.lineTo(xB + 0.5, oy - H);
    ctx.stroke();
    ctx.restore();
  }
}

/* ======================= Main simulation controller ====================== */
(function () {

  /* ---- constants from MainTimeline.frame1() (verbatim) ---- */
  const periodPrecision = 4;
  const minPDMPeriod = 0.2;
  const maxPDMPeriod = 12;
  const comparisonStarColor = '#3399FF';   // 3381759
  const featuredStarColor = '#339900';     // 3381504
  const periodCursorColor = '#36365A';     // 3552858
  const inactivePeriodCursorAlpha = 0.4;
  const activePeriodCursorAlpha = 1;
  const outOfBoundsCursorPosition = 10;
  const outOfBoundsSnapMargin = 7;
  const outOfBoundsCursorAlpha = 0.4;
  const periodLinesColor = '#36365A';      // 3552858
  const periodLinesAlpha = 0.2;
  const periodLinesThickness = 1;
  const backgroundMargin = 3;

  const prefersReducedMotion = window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches;

  /* ---- single source of truth ---- */
  const state = {
    loaded: false,
    dataGenerationDone: false,
    starsList: [],            // { x, y, dataList:[], button, index }
    activeStarIndex: 0,       // arrow-key highlight in the star field listbox
    observationsList: [],     // { epoch, noiseSeed }
    comparisonStar: null,     // entry of starsList or null
    featuredStar: null,
    comparisonsList: null,    // [{ epoch, delta, phase }]
    period: 7,
    periodCursorMode: 0,      // -1 off left, 0 on scale, +1 off right
    periodCursorAlpha: inactivePeriodCursorAlpha,
    lastPDMZoomRange: { min: minPDMPeriod, max: maxPDMPeriod },
    undoEnabled: false,
    plotType: 'epoch',        // 'epoch' | 'phase'
    showCrosshair: true,
    showDifferenceTool: false,
    minEpoch: Number.POSITIVE_INFINITY,
    maxEpoch: Number.NEGATIVE_INFINITY,
    minTimePlotValue: 0,
    maxTimePlotValue: 10,
    delta: { limit1: -50, limit2: -100, activeBar: null, dragging: false },
    dataGenerationParameters: { targetTime: 40, totalFields: 0, totalTimeTaken: 0, currFieldIndex: 0 },
    pdmParameters: { resolution: 12000, Nb: 5, Nc: 2, M: 10, targetTime: 30, totalTimeTaken: 0, totalCalculations: 0, calculationInProgress: false },
    pdmSeriesData: []
  };

  /* ---- models ---- */
  const starField = new StarFieldModel();
  const hiddenStarField = new StarFieldModel();
  const gammaTF1 = new GammaTransferFunction();
  const gammaTF2 = new GammaTransferFunction();
  const pixelMask = new PixelMask();

  const lightcurvePlot = new SimPlot();
  lightcurvePlot.setPlotDimensions(380, 260);
  lightcurvePlot.setXAxisRange(0, 10);
  lightcurvePlot.setYAxisRange(-1.5, 1.5);
  lightcurvePlot.yAxis.inverted = true;

  const lightcurveSeries = {
    xAxisPropertyName: 'epoch', yAxisPropertyName: 'delta',
    showLines: false, showPoints: true,
    pointRadius: 2, pointFillColor: '#606060',   // 6316128
    pointFillAlpha: 1, lineColor: '#A0A0A0', lineAlpha: 1, lineThickness: 1,
    data: []
  };
  lightcurvePlot.series.push(lightcurveSeries);

  const pdmPlot = new SimPlot();
  pdmPlot.setPlotDimensions(650, 230);
  pdmPlot.setXAxisRange(minPDMPeriod, maxPDMPeriod);
  pdmPlot.setYAxisRange(0, 1.2);
  pdmPlot.zoomMode = 'xZoomOnly';
  pdmPlot.xZoomRangeLimit = 650 * Math.pow(10, -periodPrecision);  // 0.065
  pdmPlot.zoomWindowFillAlpha = 0.5;
  pdmPlot.doZoomAnimation = !prefersReducedMotion;

  const pdmSeries = {
    xAxisPropertyName: 'x', yAxisPropertyName: 'y',
    showLines: true, showPoints: false,
    pointRadius: 2, pointFillColor: '#F8F8FA', pointFillAlpha: 1,
    lineColor: '#A0A0A0',                        // PlotSeries default 10526880
    lineAlpha: 1, lineThickness: 1,
    data: state.pdmSeriesData
  };
  pdmPlot.series.push(pdmSeries);

  /* ---- DOM handles ---- */
  const $ = (id) => document.getElementById(id);
  const starfieldCanvas = $('starfieldCanvas');
  const lightcurveCanvas = $('lightcurveCanvas');
  const pdmCanvas = $('pdmCanvas');
  const haloLayer = $('haloButtonLayer');
  const crosshairOverlay = $('crosshairOverlay');
  const crosshairX = $('crosshairX');
  const crosshairY = $('crosshairY');
  const loadingInfo = $('loadingInfo');
  const loadingStatus = $('loadingStatus');
  const clickToBegin = $('clickToBegin');
  const deltaBar1 = $('deltaBar1');
  const deltaBar2 = $('deltaBar2');
  const deltaMagLabel = $('deltaMagLabel');
  const periodTextInput = $('periodTextInput');
  const periodPointer = $('periodPointer');
  const periodAtLeft = $('periodAtLeft');
  const periodAtRight = $('periodAtRight');
  const zoomIn3TimesButton = $('zoomIn3TimesButton');
  const zoomOut3TimesButton = $('zoomOut3TimesButton');
  const zoomOutButton = $('zoomOutButton');
  const undoLastZoomButton = $('undoLastZoomButton');
  const showCrosshairCheckBox = $('showCrosshairCheckBox');
  const showDifferenceToolCheckBox = $('showDifferenceToolCheckBox');
  const plotTypeTime = $('plotTypeTime');
  const plotTypePhase = $('plotTypePhase');
  const liveRegion = $('liveRegion');

  const sfCtx = starfieldCanvas.getContext('2d');
  const lcCtx = lightcurveCanvas.getContext('2d');
  const pdmCtx = pdmCanvas.getContext('2d');
  const dpr = Math.max(1, Math.min(3, window.devicePixelRatio || 1));
  function setupHiDPI(canvas, ctx, w, h) {
    canvas.width = Math.round(w * dpr);
    canvas.height = Math.round(h * dpr);
    ctx.setTransform(dpr, 0, 0, dpr, 0, 0);
  }
  setupHiDPI(starfieldCanvas, sfCtx, STARFIELD_W, STARFIELD_H);
  setupHiDPI(lightcurveCanvas, lcCtx, LC.canvasW, LC.canvasH);
  setupHiDPI(pdmCanvas, pdmCtx, PDM.canvasW, PDM.canvasH);

  const fieldImage = document.createElement('canvas');
  fieldImage.width = STARFIELD_W;
  fieldImage.height = STARFIELD_H;
  const fieldImageCtx = fieldImage.getContext('2d');
  const fieldImageData = fieldImageCtx.createImageData(STARFIELD_W, STARFIELD_H);
  let fieldImageDirty = true;

  /* Checkered pattern for the difference tool (DeltaMagOverlay, verbatim:
     4 px squares of ARGB 0x50F0F0F0 and 0x50C0C0C0). */
  const patternCanvas = document.createElement('canvas');
  patternCanvas.width = 8; patternCanvas.height = 8;
  {
    const pctx = patternCanvas.getContext('2d');
    const a = 0x50 / 255;
    pctx.fillStyle = 'rgba(240,240,240,' + a + ')';
    pctx.fillRect(0, 0, 4, 4); pctx.fillRect(4, 4, 4, 4);
    pctx.fillStyle = 'rgba(192,192,192,' + a + ')';
    pctx.fillRect(4, 0, 4, 4); pctx.fillRect(0, 4, 4, 4);
  }
  const checkerPattern = lcCtx.createPattern(patternCanvas, 'repeat');

  /* ---- live region ---- */
  let liveTimer = null;
  function announce(text) {
    /* Small debounce so rapid-fire updates do not flood the screen reader. */
    clearTimeout(liveTimer);
    liveTimer = setTimeout(() => { liveRegion.textContent = text; }, 120);
  }

  /* ---- task scheduler (single rAF loop, active only while needed) ---- */
  const tasks = { dataGen: false, pdmCalc: false, zoomAnim: false };
  let rafActive = false;
  function ensureLoop() {
    if (rafActive) return;
    rafActive = true;
    requestAnimationFrame(loopStep);
  }
  function loopStep(now) {
    let busy = false;
    if (tasks.dataGen) busy = generateDataStep() || busy;
    if (tasks.pdmCalc) busy = pdmCalculationStep() || busy;
    if (tasks.zoomAnim) {
      const running = pdmPlot.tickZoomAnimation(performance.now());
      if (running) {
        repositionPeriodPointer();
        renderPDM();
        busy = true;
      } else {
        tasks.zoomAnim = false;
      }
    }
    if (busy) {
      requestAnimationFrame(loopStep);
    } else {
      rafActive = false;
    }
  }

  /* ================= data generation (generateDataFunc port) ============ */
  function startDataGeneration() {
    state.dataGenerationParameters.currFieldIndex = 0;
    tasks.dataGen = true;
    ensureLoop();
  }
  function generateDataStep() {
    const p = state.dataGenerationParameters;
    const t0 = performance.now();
    let avg = p.totalTimeTaken / p.totalFields;
    if (isNaN(avg) || !isFinite(avg) || avg <= 0) avg = 20;
    let batch = Math.ceil(p.targetTime / avg);
    if (batch < 0) batch = 1;
    let end = p.currFieldIndex + batch;
    if (end > state.observationsList.length) end = state.observationsList.length;
    let i = p.currFieldIndex;
    while (i < end) {
      const obs = state.observationsList[i];
      hiddenStarField.setEpochAndNoiseSeed(obs.epoch, obs.noiseSeed);
      for (const star of state.starsList) {
        pixelMask.left = star.x - pixelMask.radius;
        pixelMask.top = star.y - pixelMask.radius;
        const stats = hiddenStarField.getStatistics(pixelMask);
        /* Background-subtracted counts: total - nPixels * noiseMean */
        star.dataList.push(stats.totalCounts - stats.totalPixels * starField.noiseMean);
      }
      i++;
    }
    p.currFieldIndex = i;
    p.timeTaken = (p.timeTaken || 0) + (performance.now() - t0);
    p.totalTimeTaken += performance.now() - t0;
    p.totalFields += batch;
    if (p.currFieldIndex >= state.observationsList.length) {
      state.dataGenerationDone = true;
      tasks.dataGen = false;
      loadingInfo.hidden = true;
      fieldImageDirty = true;
      for (const star of state.starsList) star.button.disabled = false;
      setActiveStar(state.activeStarIndex, false);   // seed the arrow-key highlight
      renderStarField();
      announce('Data loaded. Star field ready. Select two stars to compare by clicking on them in the star field.');
      return false;
    }
    loadingInfo.hidden = false;
    loadingStatus.textContent = (100 * p.currFieldIndex / state.observationsList.length).toFixed(1) + '% done';
    return true;
  }

  /* ==================== PDM calculation (verbatim port) ================= */
  /* Stellingwerf phase dispersion minimization with Nb=5 bins, Nc=2 covers:
       c1 = (N-1) / ((sum(d^2) - sum(d)^2/N) * (N*Nc - M))
       c2 = c1 * Nc * sum(d^2)
       theta(P) = c2 - c1 * sum_bins( binSum^2 / binCount )               */
  function startPDMCalculation() {
    const p = state.pdmParameters;
    if (p.calculationInProgress) cancelPDMCalculation();
    if (state.comparisonStar == null || state.featuredStar == null) {
      state.pdmSeriesData.length = 0;
      return;
    }
    const range = pdmPlot.getXAxisRange();
    const N = state.comparisonsList.length;
    const Nc = p.Nc, M = p.M;
    let sum = 0, sum2 = 0;
    for (let i = 0; i < N; i++) {
      const d = state.comparisonsList[i].delta;
      sum += d;
      sum2 += d * d;
    }
    p.c1 = (N - 1) / ((sum2 - sum * sum / N) * (N * Nc - M));
    p.c2 = p.c1 * Nc * sum2;
    p.periodStart = range.min;
    p.periodStep = (range.max - range.min) / (p.resolution - 1);
    p.currPeriodIndex = 0;
    state.pdmSeriesData.length = 0;
    p.calculationInProgress = true;
    tasks.pdmCalc = true;
    ensureLoop();
  }
  function cancelPDMCalculation() {
    tasks.pdmCalc = false;
    state.pdmParameters.calculationInProgress = false;
  }
  function doPDMCalculation(periods, out) {
    const t0 = performance.now();
    const p = state.pdmParameters;
    const list = state.comparisonsList;
    const N = list.length;
    const Nb = p.Nb, Nc = p.Nc, M = p.M;
    const c1 = p.c1, c2 = p.c2;
    const binSums = [], binCounts = [];
    for (let i = 0; i < periods.length; i++) {
      const P = periods[i];
      for (let b = 0; b < M; b++) { binSums[b] = 0; binCounts[b] = 0; }
      for (let j = 0; j < N; j++) {
        const phase = (list[j].epoch % P) / P;
        for (let k = 0; k < Nc; k++) {
          const bin = Math.floor(Nb * ((phase + k * (1 / M)) % 1 + k));
          binSums[bin] += list[j].delta;
          binCounts[bin] += 1;
        }
      }
      let s = 0;
      for (let b = 0; b < M; b++) {
        if (binCounts[b] !== 0) s += binSums[b] * binSums[b] / binCounts[b];
      }
      out[i] = { x: P, y: c2 - c1 * s };
    }
    let dt = performance.now() - t0;
    if (dt <= 0) dt = 1;
    return dt;
  }
  function pdmCalculationStep() {
    const p = state.pdmParameters;
    let avg = p.totalTimeTaken / p.totalCalculations;
    if (isNaN(avg) || !isFinite(avg) || avg <= 0) avg = 0.1;
    let batch = Math.ceil(p.targetTime / avg);
    if (batch < 0) batch = 1;
    let end = p.currPeriodIndex + batch;
    if (end > p.resolution) {
      end = p.resolution;
      batch = end - p.currPeriodIndex;
    }
    const periods = [];
    for (let i = p.currPeriodIndex; i < end; i++) {
      periods.push(p.periodStart + p.periodStep * i);
    }
    p.currPeriodIndex = end;
    const out = [];
    const dt = doPDMCalculation(periods, out);
    Array.prototype.push.apply(state.pdmSeriesData, out);
    p.totalTimeTaken += dt;
    p.totalCalculations += batch;
    renderPDM();
    if (p.currPeriodIndex >= p.resolution) {
      cancelPDMCalculation();
      return false;
    }
    return true;
  }

  /* =================== comparisons list (verbatim port) ================= */
  function calculateComparisonsList() {
    if (state.comparisonStar == null || state.featuredStar == null) {
      state.comparisonsList = null;
      clickToBegin.hidden = false;
      lightcurveSeries.data = [];
      return;
    }
    clickToBegin.hidden = true;
    state.comparisonsList = [];
    let max = Number.NEGATIVE_INFINITY;
    let min = Number.POSITIVE_INFINITY;
    for (let i = 0; i < state.observationsList.length; i++) {
      /* Differential magnitude: delta_m = -2.5 * log10( F_interest / F_comparison ) */
      const delta = -2.5 * Math.log(state.featuredStar.dataList[i] / state.comparisonStar.dataList[i]) / Math.LN10;
      state.comparisonsList[i] = { epoch: state.observationsList[i].epoch, delta: delta };
      if (delta > max) max = delta;
      if (delta < min) min = delta;
    }
    let span = max - min;
    if (span < 1) {
      const mid = min + span / 2;
      span = 1;
      min = mid - span / 2;
      max = mid + span / 2;
    }
    const pad = 0.1 * span;
    lightcurvePlot.setYAxisRange(min - pad, max + pad);
    lightcurveSeries.data = state.comparisonsList;
  }

  /* ================= period + phases (verbatim port) ==================== */
  function updatePeriodAndPhases() {
    repositionPeriodPointer();
    if (document.activeElement !== periodTextInput) {
      periodTextInput.value = state.period.toFixed(periodPrecision);
    }
    if (state.comparisonsList) {
      for (const item of state.comparisonsList) {
        item.phase = ((item.epoch / state.period) % 1 + 1) % 1;
      }
    }
    renderLightcurve();
  }

  function repositionPeriodPointer() {
    const range = pdmPlot.getXAxisRange();
    let x = PDM.ox + PDM.plotW * (state.period - range.min) / (range.max - range.min);
    if (x < PDM.ox) {
      state.periodCursorMode = -1;
      x = PDM.ox - outOfBoundsCursorPosition;
    } else if (x > PDM.ox + PDM.plotW) {
      state.periodCursorMode = 1;
      x = PDM.ox + PDM.plotW + outOfBoundsCursorPosition;
    } else {
      state.periodCursorMode = 0;
    }
    state.pointerCanvasX = x;
    syncPointerDOM();
  }

  function syncPointerDOM() {
    periodPointer.style.left = (state.pointerCanvasX / PDM.canvasW * 100) + '%';
    const offscale = state.periodCursorMode !== 0;
    periodPointer.classList.toggle('is-offscale', offscale);
    periodAtLeft.hidden = state.periodCursorMode !== -1;
    periodAtRight.hidden = state.periodCursorMode !== 1;
    const range = pdmPlot.getXAxisRange();
    periodPointer.setAttribute('aria-valuemin', range.min.toFixed(periodPrecision));
    periodPointer.setAttribute('aria-valuemax', range.max.toFixed(periodPrecision));
    periodPointer.setAttribute('aria-valuenow', state.period.toFixed(periodPrecision));
    periodPointer.setAttribute('aria-valuetext', 'period ' + state.period.toFixed(periodPrecision) + ' days');
  }

  /* ======================= star selection (halo clicks) ================= */
  function onHaloClicked(star) {
    if (!state.dataGenerationDone) return;
    let announcement;
    if (state.comparisonStar != null && state.featuredStar != null &&
        (star === state.comparisonStar || star === state.featuredStar)) {
      const t = state.comparisonStar;
      state.comparisonStar = state.featuredStar;
      state.featuredStar = t;
      announcement = 'Comparison star and star of interest swapped.';
    } else if (state.comparisonStar == null) {
      state.comparisonStar = star;
      announcement = 'Comparison star selected at pixel x ' + star.x + ', y ' + star.y + '.';
    } else {
      state.featuredStar = star;
      announcement = 'Star of interest selected at pixel x ' + star.x + ', y ' + star.y + '.';
    }
    calculateComparisonsList();
    updatePeriodAndPhases();
    pdmZoomOut(true);
    startPDMCalculation();
    fieldImageDirty = false;   // halos only; field pixels unchanged
    renderStarField();
    renderPDM();
    syncHaloAria();
    if (state.comparisonStar != null && state.featuredStar == null) {
      announcement += ' Now select the star of interest.';
    } else if (state.comparisonStar != null && state.featuredStar != null) {
      announcement += ' Lightcurve and PDM plots updated.';
    }
    announce(announcement);
  }

  /* ============== star field keyboard navigation (listbox) ==============
     The field is one tab stop. aria-activedescendant marks the highlighted
     star so screen readers announce it as the arrow keys move, without the
     26 individual tab stops the per-star buttons would otherwise create. */
  function setActiveStar(index, announceIt) {
    if (index < 0 || index >= state.starsList.length) return;
    state.activeStarIndex = index;
    for (let i = 0; i < state.starsList.length; i++) {
      state.starsList[i].button.classList.toggle('is-active', i === index);
    }
    const btn = state.starsList[index].button;
    haloLayer.setAttribute('aria-activedescendant', btn.id);
    /* Keep the highlighted star in view when the panel is scrolled/zoomed. */
    if (btn.scrollIntoView) btn.scrollIntoView({ block: 'nearest', inline: 'nearest' });
    if (announceIt) announce(btn.getAttribute('aria-label') + '.');
  }

  /* Nearest star in a direction: prefer small movement along the travel axis,
     penalising sideways drift so the highlight tracks where the eye expects. */
  function findStarInDirection(fromIndex, dx, dy) {
    const from = state.starsList[fromIndex];
    let best = -1, bestScore = Infinity;
    for (let i = 0; i < state.starsList.length; i++) {
      if (i === fromIndex) continue;
      const s = state.starsList[i];
      const along = (s.x - from.x) * dx + (s.y - from.y) * dy;
      if (along <= 0) continue;                       // wrong side
      const across = Math.abs((s.x - from.x) * dy + (s.y - from.y) * dx);
      const score = along + 2 * across;
      if (score < bestScore) { bestScore = score; best = i; }
    }
    return best;
  }

  function onStarFieldKeydown(ev) {
    if (!state.starsList.length) return;
    let dir = null;
    switch (ev.key) {
      case 'ArrowLeft':  dir = [-1, 0]; break;
      case 'ArrowRight': dir = [1, 0]; break;
      case 'ArrowUp':    dir = [0, -1]; break;
      case 'ArrowDown':  dir = [0, 1]; break;
      case 'Home':
        ev.preventDefault();
        setActiveStar(0, true);
        return;
      case 'End':
        ev.preventDefault();
        setActiveStar(state.starsList.length - 1, true);
        return;
      case 'Enter':
      case ' ':
      case 'Spacebar':
        ev.preventDefault();
        onHaloClicked(state.starsList[state.activeStarIndex]);
        return;
      default:
        return;                                       // let Tab etc. through
    }
    ev.preventDefault();
    const next = findStarInDirection(state.activeStarIndex, dir[0], dir[1]);
    if (next >= 0) setActiveStar(next, true);
  }

  function syncHaloAria() {
    for (let i = 0; i < state.starsList.length; i++) {
      const star = state.starsList[i];
      let label = 'Star at pixel x ' + star.x + ', y ' + star.y;
      if (star === state.comparisonStar) label += ', selected as comparison star';
      if (star === state.featuredStar) label += ', selected as star of interest';
      star.button.setAttribute('aria-label', label);
      star.button.setAttribute('aria-selected', (star === state.comparisonStar || star === state.featuredStar) ? 'true' : 'false');
    }
  }

  /* ========================== zoom actions ============================== */
  function updateZoomButtonStates() {
    const range = pdmPlot.getXAxisRange();
    const atFullRange = (range.min === minPDMPeriod && range.max === maxPDMPeriod);
    zoomOutButton.disabled = atFullRange;
    zoomOut3TimesButton.disabled = atFullRange;
    zoomIn3TimesButton.disabled = !(range.max - range.min > pdmPlot.xZoomRangeLimit + 1e-12);
    undoLastZoomButton.disabled = !state.undoEnabled;
  }

  function announcePDMRange() {
    const range = pdmPlot.getXAxisRange();
    announce('PDM plot now shows periods ' + range.min.toFixed(periodPrecision) + ' to ' +
      range.max.toFixed(periodPrecision) + ' days.');
  }

  function pdmZoomByMultiple(mult) {
    const range = pdmPlot.getXAxisRange();
    const span = range.max - range.min;
    let newSpan = mult * span;
    if (newSpan < pdmPlot.xZoomRangeLimit) newSpan = pdmPlot.xZoomRangeLimit;
    const center = state.period;
    let lo = center - newSpan / 2;
    let hi = center + newSpan / 2;
    if (lo < minPDMPeriod) {
      lo = minPDMPeriod;
      hi = lo + newSpan;
      if (hi > maxPDMPeriod) hi = maxPDMPeriod;
    } else if (hi > maxPDMPeriod) {
      hi = maxPDMPeriod;
      lo = hi - newSpan;
      if (lo < minPDMPeriod) lo = minPDMPeriod;
    }
    const f = Math.pow(10, periodPrecision);
    lo = Math.round(lo * f) / f;
    hi = Math.round(hi * f) / f;
    if (lo === range.min && hi === range.max) return;
    state.lastPDMZoomRange.min = range.min;
    state.lastPDMZoomRange.max = range.max;
    state.undoEnabled = true;
    pdmPlot.setXAxisRange(lo, hi);
    repositionPeriodPointer();
    updateZoomButtonStates();
    renderPDM();
    announcePDMRange();
  }

  function pdmZoomOut(silent) {
    const range = pdmPlot.getXAxisRange();
    if (range.min === minPDMPeriod && range.max === maxPDMPeriod) return;
    state.lastPDMZoomRange.min = range.min;
    state.lastPDMZoomRange.max = range.max;
    state.undoEnabled = true;
    pdmPlot.setXAxisRange(minPDMPeriod, maxPDMPeriod);
    repositionPeriodPointer();
    updateZoomButtonStates();
    renderPDM();
    if (!silent) announcePDMRange();
  }

  function pdmUndoLastZoom() {
    const prevMin = state.lastPDMZoomRange.min;
    const prevMax = state.lastPDMZoomRange.max;
    const range = pdmPlot.getXAxisRange();
    state.lastPDMZoomRange.min = range.min;
    state.lastPDMZoomRange.max = range.max;
    pdmPlot.setXAxisRange(prevMin, prevMax);
    repositionPeriodPointer();
    updateZoomButtonStates();
    renderPDM();
    announcePDMRange();
  }

  pdmPlot.onZoomStart = function () {
    /* ZOOM_START handler from MainTimeline (records the pre-zoom range). */
    state.lastPDMZoomRange.min = pdmPlot.zoomAnimationInProgress ? pdmPlot.xAxis.min : pdmPlot.xAxis.min;
    const range = pdmPlot.getXAxisRange();
    state.lastPDMZoomRange.min = range.min;
    state.lastPDMZoomRange.max = range.max;
    state.undoEnabled = true;
    updateZoomButtonStates();
  };
  pdmPlot.onZoomStep = function () { /* handled in the rAF loop */ };
  pdmPlot.onZoomDone = function () {
    repositionPeriodPointer();
    updateZoomButtonStates();
    renderPDM();
    announcePDMRange();
  };

  /* ================== lightcurve type (verbatim port) =================== */
  function setLightcurveType(type) {
    if (type === 'epoch') {
      lightcurveSeries.xAxisPropertyName = 'epoch';
      lightcurvePlot.setXAxisRange(state.minTimePlotValue, state.maxTimePlotValue);
      state.periodLinesVisible = true;
    } else if (type === 'phase') {
      lightcurveSeries.xAxisPropertyName = 'phase';
      lightcurvePlot.setXAxisRange(0, 1);
      state.periodLinesVisible = false;
    }
    state.plotType = type;
    renderLightcurve();
  }

  /* ============================ rendering =============================== */
  function renderStarField() {
    if (!state.loaded) return;
    if (fieldImageDirty && starField.fieldData) {
      starField.paintInto(fieldImageData);
      fieldImageCtx.putImageData(fieldImageData, 0, 0);
      fieldImageDirty = false;
    }
    sfCtx.clearRect(0, 0, STARFIELD_W, STARFIELD_H);
    if (state.dataGenerationDone && starField.fieldData) {
      sfCtx.imageSmoothingEnabled = false;
      sfCtx.drawImage(fieldImage, 0, 0);
      /* Star halos (StarHalo.drawHalo port): comparison = blue square,
         star of interest = green circle with thickness 1.5. */
      if (state.comparisonStar) {
        const s = state.comparisonStar;
        const r = pixelMask.radius;
        sfCtx.strokeStyle = comparisonStarColor;
        sfCtx.lineWidth = 1;
        sfCtx.strokeRect(s.x + 0.5 - r, s.y + 0.5 - r, 2 * r, 2 * r);
      }
      if (state.featuredStar) {
        const s = state.featuredStar;
        const r = pixelMask.radius;
        sfCtx.strokeStyle = featuredStarColor;
        sfCtx.lineWidth = 1.5;
        sfCtx.beginPath();
        sfCtx.arc(s.x + 0.5, s.y + 0.5, r, 0, 2 * Math.PI);
        sfCtx.stroke();
      }
    } else {
      sfCtx.fillStyle = '#000000';
      sfCtx.fillRect(0, 0, STARFIELD_W, STARFIELD_H);
    }
  }

  function renderLightcurve() {
    lcCtx.clearRect(0, 0, LC.canvasW, LC.canvasH);
    lightcurvePlot.render(lcCtx, LC.ox, LC.oy);
    /* Vertical lines at integer multiples of the period (time mode only). */
    if (state.periodLinesVisible && state.loaded) {
      const scale = LC.plotW / (state.maxTimePlotValue - state.minTimePlotValue);
      const k0 = Math.ceil(state.minTimePlotValue / state.period);
      const k1 = k0 + Math.ceil((state.maxTimePlotValue - state.minTimePlotValue) / state.period);
      lcCtx.save();
      lcCtx.strokeStyle = periodLinesColor;
      lcCtx.globalAlpha = periodLinesAlpha;
      lcCtx.lineWidth = periodLinesThickness;
      lcCtx.beginPath();
      for (let k = k0; k < k1; k++) {
        const x = LC.ox + scale * (k * state.period - state.minTimePlotValue);
        lcCtx.moveTo(x, LC.oy - LC.plotH);
        lcCtx.lineTo(x, LC.oy);
      }
      lcCtx.stroke();
      lcCtx.restore();
    }
    /* Difference tool checkered regions (DeltaMagOverlay port). */
    if (state.showDifferenceTool) {
      const lo = Math.min(state.delta.limit1, state.delta.limit2);
      const hi = Math.max(state.delta.limit1, state.delta.limit2);
      lcCtx.save();
      lcCtx.fillStyle = checkerPattern;
      /* region above the upper bar and below the lower bar */
      lcCtx.fillRect(LC.ox, LC.oy - LC.plotH, LC.plotW, (LC.plotH + lo));
      lcCtx.fillRect(LC.ox, LC.oy + hi, LC.plotW, -hi);
      lcCtx.restore();
    }
    syncDeltaDOM();
  }

  function renderPDM() {
    pdmCtx.clearRect(0, 0, PDM.canvasW, PDM.canvasH);
    pdmPlot.render(pdmCtx, PDM.ox, PDM.oy);
    /* Period cursor line (only when the period is on scale). */
    if (state.periodCursorMode === 0) {
      pdmCtx.save();
      pdmCtx.strokeStyle = periodCursorColor;
      pdmCtx.globalAlpha = state.periodCursorAlpha;
      pdmCtx.lineWidth = 1;
      pdmCtx.beginPath();
      const x = Math.round(state.pointerCanvasX) + 0.5;
      pdmCtx.moveTo(x, PDM.oy - PDM.plotH);
      pdmCtx.lineTo(x, PDM.oy);
      pdmCtx.stroke();
      pdmCtx.restore();
    }
    pdmPlot.renderZoomWindow(pdmCtx, PDM.ox, PDM.oy);
  }

  function renderAll() {
    renderStarField();
    renderLightcurve();
    renderPDM();
    updateZoomButtonStates();
    syncPointerDOM();
    syncHaloAria();
  }

  /* ================= difference tool DOM + interaction ================== */
  function deltaBarMagValue(limit) {
    /* Inverted y axis: value = yMin + (yMax - yMin) * (limit + H) / H */
    const range = lightcurvePlot.getYAxisRange();
    return range.min + (range.max - range.min) * ((limit + LC.plotH) / LC.plotH);
  }
  function deltaDifference() {
    const range = lightcurvePlot.getYAxisRange();
    const lo = Math.min(state.delta.limit1, state.delta.limit2);
    const hi = Math.max(state.delta.limit1, state.delta.limit2);
    return (range.max - range.min) * ((hi - lo) / LC.plotH);
  }
  function syncDeltaDOM() {
    const visible = state.showDifferenceTool;
    deltaBar1.hidden = !visible;
    deltaBar2.hidden = !visible;
    deltaMagLabel.hidden = !visible;
    if (!visible) return;
    const bars = [[deltaBar1, state.delta.limit1, 1], [deltaBar2, state.delta.limit2, 2]];
    const range = lightcurvePlot.getYAxisRange();
    for (const [el, limit, n] of bars) {
      el.style.top = ((LC.oy + limit) / LC.canvasH * 100) + '%';
      el.style.left = (LC.ox / LC.canvasW * 100) + '%';
      el.style.width = (LC.plotW / LC.canvasW * 100) + '%';
      const v = deltaBarMagValue(limit);
      el.setAttribute('aria-valuemin', range.min.toFixed(2));
      el.setAttribute('aria-valuemax', range.max.toFixed(2));
      el.setAttribute('aria-valuenow', v.toFixed(2));
      el.setAttribute('aria-valuetext', 'bar ' + n + ' at ' + v.toFixed(2) +
        ' magnitudes, difference ' + deltaDifference().toFixed(2) + ' magnitudes');
      el.classList.toggle('is-active', state.delta.activeBar === el);
    }
    /* Verbatim label format: " X.XX mag " */
    deltaMagLabel.textContent = ' ' + deltaDifference().toFixed(2) + ' mag ';
    const upper = Math.min(state.delta.limit1, state.delta.limit2);
    deltaMagLabel.style.left = ((LC.ox + LC.plotW / 2) / LC.canvasW * 100) + '%';
    deltaMagLabel.style.top = ((LC.oy + upper) / LC.canvasH * 100) + '%';
  }

  function lightcurveCanvasPoint(ev) {
    const rect = lightcurveCanvas.getBoundingClientRect();
    return {
      x: (ev.clientX - rect.left) / rect.width * LC.canvasW,
      y: (ev.clientY - rect.top) / rect.height * LC.canvasH
    };
  }

  function setDeltaLimitFromCanvasY(bar, canvasY) {
    let limit = canvasY - LC.oy;
    if (limit > 0) limit = 0;
    else if (limit < -LC.plotH) limit = -LC.plotH;
    if (bar === deltaBar1) state.delta.limit1 = limit;
    else state.delta.limit2 = limit;
  }

  function onDeltaPointerDown(ev, bar) {
    if (!state.showDifferenceTool) return;
    const pt = lightcurveCanvasPoint(ev);
    if (bar == null) {
      /* Click in the plot area: the nearest bar jumps to the pointer
         (onMouseDownOverMouseArea port). */
      if (pt.x < LC.ox || pt.x > LC.ox + LC.plotW || pt.y < LC.oy - LC.plotH || pt.y > LC.oy) return;
      const y = pt.y - LC.oy;
      const d1 = Math.abs(y - state.delta.limit1);
      const d2 = Math.abs(y - state.delta.limit2);
      bar = d1 < d2 ? deltaBar1 : deltaBar2;
      setDeltaLimitFromCanvasY(bar, pt.y);
    }
    state.delta.activeBar = bar;
    state.delta.dragging = true;
    bar.focus();
    bar.setPointerCapture && ev.pointerId !== undefined && bar.setPointerCapture(ev.pointerId);
    renderLightcurve();
    ev.preventDefault();
    const move = (e) => {
      const p = lightcurveCanvasPoint(e);
      setDeltaLimitFromCanvasY(bar, p.y);
      renderLightcurve();
    };
    const up = () => {
      state.delta.dragging = false;
      window.removeEventListener('pointermove', move);
      window.removeEventListener('pointerup', up);
      window.removeEventListener('pointercancel', up);
      renderLightcurve();
      announce('Magnitude difference between bars ' + deltaDifference().toFixed(2) + ' magnitudes.');
    };
    window.addEventListener('pointermove', move);
    window.addEventListener('pointerup', up);
    window.addEventListener('pointercancel', up);
  }

  function onDeltaBarKeydown(ev) {
    const bar = ev.currentTarget;
    const which = bar === deltaBar1 ? 'limit1' : 'limit2';
    let limit = state.delta[which];
    let handled = true;
    switch (ev.key) {
      case 'ArrowUp': limit -= 2; break;
      case 'ArrowDown': limit += 2; break;
      case 'PageUp': limit -= 20; break;
      case 'PageDown': limit += 20; break;
      case 'Home': limit = -LC.plotH; break;
      case 'End': limit = 0; break;
      default: handled = false;
    }
    if (!handled) return;
    ev.preventDefault();
    if (limit > 0) limit = 0;
    else if (limit < -LC.plotH) limit = -LC.plotH;
    state.delta[which] = limit;
    state.delta.activeBar = bar;
    renderLightcurve();
    announce('Magnitude difference between bars ' + deltaDifference().toFixed(2) + ' magnitudes.');
  }

  /* ==================== period pointer interaction ====================== */
  function pdmCanvasPoint(ev) {
    const rect = pdmCanvas.getBoundingClientRect();
    return {
      x: (ev.clientX - rect.left) / rect.width * PDM.canvasW,
      y: (ev.clientY - rect.top) / rect.height * PDM.canvasH
    };
  }

  /* continuePeriodDragging port: identical offset + clamping + rounding. */
  function movePeriodToCanvasX(canvasX, dragCtx) {
    if (dragCtx.modeAtStart === 1 && canvasX > PDM.ox + PDM.plotW + outOfBoundsSnapMargin) {
      state.period = dragCtx.periodAtStart;
    } else if (dragCtx.modeAtStart === -1 && canvasX < PDM.ox - outOfBoundsSnapMargin) {
      state.period = dragCtx.periodAtStart;
    } else {
      let x = canvasX;
      if (x < PDM.ox) x = PDM.ox;
      else if (x > PDM.ox + PDM.plotW) x = PDM.ox + PDM.plotW;
      const range = pdmPlot.getXAxisRange();
      let p = range.min + (range.max - range.min) * ((x - PDM.ox) / PDM.plotW);
      const f = Math.pow(10, periodPrecision);
      if (p < minPDMPeriod) p = minPDMPeriod;
      if (p > maxPDMPeriod) p = maxPDMPeriod;
      p = Math.round(p * f) / f;
      if (p > range.max) p -= 1 / f;
      else if (p < range.min) p += 1 / f;
      state.period = p;
    }
    updatePeriodAndPhases();
    renderPDM();
  }

  function onPointerDragStart(ev) {
    const dragCtx = {
      modeAtStart: state.periodCursorMode,
      periodAtStart: state.period,
      offsetX: pdmCanvasPoint(ev).x - state.pointerCanvasX
    };
    state.periodCursorAlpha = activePeriodCursorAlpha;
    periodPointer.focus();
    periodPointer.setPointerCapture && ev.pointerId !== undefined && periodPointer.setPointerCapture(ev.pointerId);
    renderPDM();
    ev.preventDefault();
    const move = (e) => {
      movePeriodToCanvasX(pdmCanvasPoint(e).x - dragCtx.offsetX, dragCtx);
    };
    const up = () => {
      window.removeEventListener('pointermove', move);
      window.removeEventListener('pointerup', up);
      window.removeEventListener('pointercancel', up);
      state.periodCursorAlpha = inactivePeriodCursorAlpha;
      repositionPeriodPointer();
      renderPDM();
      announce('Period ' + state.period.toFixed(periodPrecision) + ' days.');
    };
    window.addEventListener('pointermove', move);
    window.addEventListener('pointerup', up);
    window.addEventListener('pointercancel', up);
  }

  function onPointerKeydown(ev) {
    const range = pdmPlot.getXAxisRange();
    const f = Math.pow(10, periodPrecision);
    /* One arrow press ~ one plot pixel, never less than 0.0001 days. */
    let pixelStep = Math.round((range.max - range.min) / PDM.plotW * f) / f;
    if (pixelStep < 1 / f) pixelStep = 1 / f;
    let p = state.period;
    let handled = true;
    switch (ev.key) {
      case 'ArrowLeft': case 'ArrowDown': p -= pixelStep; break;
      case 'ArrowRight': case 'ArrowUp': p += pixelStep; break;
      case 'PageDown': p -= 10 * pixelStep; break;
      case 'PageUp': p += 10 * pixelStep; break;
      case 'Home': p = Math.max(range.min, minPDMPeriod); break;
      case 'End': p = Math.min(range.max, maxPDMPeriod); break;
      default: handled = false;
    }
    if (!handled) return;
    ev.preventDefault();
    if (p < minPDMPeriod) p = minPDMPeriod;
    if (p > maxPDMPeriod) p = maxPDMPeriod;
    if (p < range.min) p = range.min;
    if (p > range.max) p = range.max;
    state.period = Math.round(p * f) / f;
    updatePeriodAndPhases();
    renderPDM();
    announce('Period ' + state.period.toFixed(periodPrecision) + ' days.');
  }

  /* ======================= PDM zoom window input ======================== */
  function onPDMPointerDown(ev) {
    if (pdmPlot.zoomAnimationInProgress) return;
    const pt = pdmCanvasPoint(ev);
    const inPlot = pt.x >= PDM.ox && pt.x <= PDM.ox + PDM.plotW &&
      pt.y >= PDM.oy - PDM.plotH && pt.y <= PDM.oy;
    if (!inPlot) return;
    const zw = pdmPlot.zoomWindowParams;
    const localX = Math.min(Math.max(pt.x - PDM.ox, 0), PDM.plotW);
    if (zw && zw.finalized) {
      const lo = Math.min(zw.startX, zw.endX);
      const hi = Math.max(zw.startX, zw.endX);
      if (localX >= lo && localX <= hi) {
        /* Click on the finalized window commits the zoom. */
        const commit = () => {
          window.removeEventListener('pointerup', commit);
          const p2 = pdmCanvasPoint(ev);
          pdmPlot.commitZoomWindow();
          if (pdmPlot.zoomAnimationInProgress) {
            tasks.zoomAnim = true;
            ensureLoop();
          }
          renderPDM();
        };
        window.addEventListener('pointerup', commit);
        ev.preventDefault();
        return;
      }
    }
    /* Start a new zoom window drag. */
    pdmPlot.clearZoomWindow();
    pdmPlot.zoomWindowParams = { startX: localX, endX: undefined, isValid: false, finalized: false };
    ev.preventDefault();
    const move = (e) => {
      const p = pdmCanvasPoint(e);
      const x = Math.min(Math.max(p.x - PDM.ox, 0), PDM.plotW);
      pdmPlot.zoomWindowParams.endX = x;
      pdmPlot.zoomWindowParams.isValid = (pdmPlot.zoomWindowParams.startX !== x);
      renderPDM();
    };
    const up = () => {
      window.removeEventListener('pointermove', move);
      window.removeEventListener('pointerup', up);
      window.removeEventListener('pointercancel', up);
      const p = pdmPlot.zoomWindowParams;
      if (!p || !p.isValid) {
        pdmPlot.clearZoomWindow();
      } else {
        p.finalized = true;
      }
      renderPDM();
    };
    window.addEventListener('pointermove', move);
    window.addEventListener('pointerup', up);
    window.addEventListener('pointercancel', up);
  }

  /* ========================= crosshair readout ========================== */
  function updateCrosshairFromEvent(ev) {
    if (!state.showCrosshair || !state.dataGenerationDone) {
      crosshairOverlay.hidden = true;
      return;
    }
    const rect = starfieldCanvas.getBoundingClientRect();
    let x = Math.floor((ev.clientX - rect.left) / rect.width * STARFIELD_W);
    let y = Math.floor((ev.clientY - rect.top) / rect.height * STARFIELD_H);
    if (x < 0) x = 0; else if (x >= STARFIELD_W) x = STARFIELD_W - 1;
    if (y < 0) y = 0; else if (y >= STARFIELD_H) y = STARFIELD_H - 1;
    crosshairX.textContent = String(x);
    crosshairY.textContent = String(y);
    crosshairOverlay.style.left = ((x + 0.5) / STARFIELD_W * 100) + '%';
    crosshairOverlay.style.top = ((y + 0.5) / STARFIELD_H * 100) + '%';
    crosshairOverlay.hidden = false;
  }

  /* ========================= period text input ========================== */
  function onPeriodEntered() {
    /* onPeriodEntered port: accept finite values within [0.2, 12] days,
       rounded to 4 decimals; otherwise keep the current period. */
    const v = parseFloat(periodTextInput.value);
    if (isFinite(v) && !isNaN(v) && v >= minPDMPeriod && v <= maxPDMPeriod) {
      const f = Math.pow(10, periodPrecision);
      state.period = Math.round(v * f) / f;
    }
    periodTextInput.classList.remove('is-editing');
    periodTextInput.value = state.period.toFixed(periodPrecision);
    updatePeriodAndPhases();
    renderPDM();
    announce('Period ' + state.period.toFixed(periodPrecision) + ' days.');
  }

  /* ============================== reset ================================= */
  function resetSim() {
    /* Restore the exact initial (post-load) state. The measured photometry
       (dataList) is deterministic and unchanged, so it is kept. */
    cancelPDMCalculation();
    pdmPlot.cancelZoomAnimation();
    tasks.zoomAnim = false;
    state.comparisonStar = null;
    state.featuredStar = null;
    state.comparisonsList = null;
    lightcurveSeries.data = [];
    state.pdmSeriesData.length = 0;
    state.period = 7;
    state.periodCursorMode = 0;
    state.periodCursorAlpha = inactivePeriodCursorAlpha;
    state.lastPDMZoomRange = { min: minPDMPeriod, max: maxPDMPeriod };
    state.undoEnabled = false;
    state.showCrosshair = true;
    state.showDifferenceTool = false;
    state.delta.limit1 = -50;
    state.delta.limit2 = -100;
    state.delta.activeBar = null;
    showCrosshairCheckBox.checked = true;
    showDifferenceToolCheckBox.checked = false;
    plotTypeTime.checked = true;
    plotTypePhase.checked = false;
    pdmPlot.setXAxisRange(minPDMPeriod, maxPDMPeriod);
    lightcurvePlot.setYAxisRange(-1.5, 1.5);
    setLightcurveType('epoch');
    clickToBegin.hidden = false;
    periodTextInput.classList.remove('is-editing');
    updatePeriodAndPhases();
    renderAll();
    announce('Simulation reset to initial state.');
  }

  /* ====================== settings loading + init ======================= */
  function parseSettings(xmlText) {
    const doc = new DOMParser().parseFromString(xmlText, 'application/xml');
    const fp = doc.querySelector('fieldParameters');
    const noiseMean = Number(fp.getAttribute('noiseMean'));
    const noiseSigma = Number(fp.getAttribute('noiseSigma'));
    const saturationMagnitude = Number(fp.getAttribute('saturationMagnitude'));
    const psfRadius = Math.floor(Number(fp.getAttribute('psfRadius')));
    starField.noiseMean = noiseMean;
    starField.noiseSigma = noiseSigma;
    starField.saturationMagnitude = saturationMagnitude;
    starField.psf = new AiryDisc(psfRadius);
    hiddenStarField.noiseMean = noiseMean;
    hiddenStarField.noiseSigma = noiseSigma;
    hiddenStarField.saturationMagnitude = saturationMagnitude;
    hiddenStarField.psf = new AiryDisc(psfRadius);
    pixelMask.radius = backgroundMargin + psfRadius;

    let index = 0;
    for (const el of doc.querySelectorAll('starsList > *')) {
      const x = Math.floor(Number(el.getAttribute('x')));
      const y = Math.floor(Number(el.getAttribute('y')));
      let displayStar = null, hiddenStar = null;
      switch (el.tagName) {
        case 'constantStar': {
          const magnitude = Number(el.getAttribute('magnitude'));
          displayStar = new Star({ x, y, magnitude });
          hiddenStar = new Star({ x, y, magnitude });
          break;
        }
        case 'pulsatingStar': {
          const centerMagnitude = Number(el.getAttribute('centerMagnitude'));
          const preset = PulsatingStar.PRESETS[el.getAttribute('prototypeName')];
          displayStar = new PulsatingStar({ x, y, centerMagnitude }, preset);
          hiddenStar = new PulsatingStar({ x, y, centerMagnitude }, preset);
          break;
        }
        case 'eclipsingBinary': {
          const peakMagnitude = Number(el.getAttribute('peakMagnitude'));
          const preset = EclipsingBinary.PRESETS[el.getAttribute('prototypeName')];
          displayStar = new EclipsingBinary({ x, y, peakMagnitude }, preset);
          hiddenStar = new EclipsingBinary({ x, y, peakMagnitude }, preset);
          break;
        }
        default:
          continue;
      }
      starField.starsList.push(displayStar);
      hiddenStarField.starsList.push(hiddenStar);

      /* Accessible halo proxy for the invisible StarHalo. The star field is a
         single tab stop (a listbox); these are its options, reached with the
         arrow keys rather than by tabbing to each one. */
      const btn = document.createElement('button');
      btn.type = 'button';
      btn.className = 'sim-halo-button';
      btn.id = 'star-' + index;
      btn.disabled = true;                 // enabled once data generation ends
      btn.tabIndex = -1;                   // not a tab stop; container owns focus
      btn.setAttribute('role', 'option');
      btn.setAttribute('aria-selected', 'false');
      btn.style.left = ((x + 0.5) / STARFIELD_W * 100) + '%';
      btn.style.top = ((y + 0.5) / STARFIELD_H * 100) + '%';
      btn.setAttribute('aria-label', 'Star at pixel x ' + x + ', y ' + y);
      haloLayer.appendChild(btn);
      const entry = { x, y, dataList: [], button: btn, index: index };
      btn.addEventListener('click', (ev) => {
        /* Clicking a star also makes it the arrow-key starting point, and
           moves focus to the field so the arrows work straight away. */
        ev.preventDefault();
        setActiveStar(entry.index, false);
        haloLayer.focus();
        onHaloClicked(entry);
      });
      state.starsList[index] = entry;
      index++;
    }

    for (const el of doc.querySelectorAll('observationsList > observation')) {
      const epoch = Number(el.getAttribute('epoch'));
      if (epoch > state.maxEpoch) state.maxEpoch = epoch;
      if (epoch < state.minEpoch) state.minEpoch = epoch;
      state.observationsList.push({ epoch, noiseSeed: Math.floor(Number(el.getAttribute('noiseSeed'))) });
    }
    state.minTimePlotValue = Math.floor(state.minEpoch - 1);
    state.maxTimePlotValue = Math.ceil(state.maxEpoch + 1);
  }

  function init() {
    /* frame1() port: build the locked fields, then load settings. */
    starField.lock();
    hiddenStarField.lock();
    starField.setDimensions(STARFIELD_W, STARFIELD_H);
    hiddenStarField.setDimensions(STARFIELD_W, STARFIELD_H);
    gammaTF1.peakValue = starField.peakValue;
    gammaTF2.peakValue = hiddenStarField.peakValue;
    starField.transferFunction = gammaTF1;
    hiddenStarField.transferFunction = gammaTF2;
    starField.onFieldChanged = function () { fieldImageDirty = true; };

    periodTextInput.value = state.period.toFixed(periodPrecision);
    updateZoomButtonStates();
    setLightcurveType('epoch');
    updatePeriodAndPhases();
    renderPDM();

    const params = new URLSearchParams(window.location.search);
    const settingsFile = params.get('settingsFile') || 'assets/settings.xml';
    fetch(settingsFile)
      .then((r) => {
        if (!r.ok) throw new Error('HTTP ' + r.status);
        return r.text();
      })
      .then((xmlText) => {
        parseSettings(xmlText);
        state.loaded = true;
        setLightcurveType('epoch');
        updatePeriodAndPhases();
        starField.setEpochAndNoiseSeed(state.observationsList[0].epoch, state.observationsList[0].noiseSeed);
        hiddenStarField.unlock();
        starField.unlock();
        fieldImageDirty = true;
        startDataGeneration();
        renderAll();
        announce('Loading data, please wait.');
      })
      .catch((err) => {
        console.error('Failed to load settings file:', err);
        loadingStatus.textContent = 'Could not load ' + settingsFile + '. ' +
          'This page must be served over HTTP (see README.md).';
      });
  }

  /* =========================== event wiring ============================= */
  zoomIn3TimesButton.addEventListener('click', () => pdmZoomByMultiple(1 / 3));
  zoomOut3TimesButton.addEventListener('click', () => pdmZoomByMultiple(3));
  zoomOutButton.addEventListener('click', () => pdmZoomOut(false));
  undoLastZoomButton.addEventListener('click', pdmUndoLastZoom);

  showCrosshairCheckBox.addEventListener('change', () => {
    state.showCrosshair = showCrosshairCheckBox.checked;
    if (!state.showCrosshair) crosshairOverlay.hidden = true;
    announce(state.showCrosshair ? 'Crosshairs on.' : 'Crosshairs off.');
  });
  showDifferenceToolCheckBox.addEventListener('change', () => {
    state.showDifferenceTool = showDifferenceToolCheckBox.checked;
    renderLightcurve();
    announce(state.showDifferenceTool
      ? 'Difference tool shown. Magnitude difference between bars ' + deltaDifference().toFixed(2) + ' magnitudes.'
      : 'Difference tool hidden.');
  });
  plotTypeTime.addEventListener('change', () => {
    if (plotTypeTime.checked) {
      setLightcurveType('epoch');
      announce('Lightcurve plotted versus time in days.');
    }
  });
  plotTypePhase.addEventListener('change', () => {
    if (plotTypePhase.checked) {
      setLightcurveType('phase');
      announce('Lightcurve plotted versus phase.');
    }
  });

  periodTextInput.addEventListener('input', () => {
    /* restrict="0-9." / maxChars=8 port */
    const cleaned = periodTextInput.value.replace(/[^0-9.]/g, '').slice(0, 8);
    if (cleaned !== periodTextInput.value) periodTextInput.value = cleaned;
    periodTextInput.classList.add('is-editing');
  });
  periodTextInput.addEventListener('keydown', (ev) => {
    if (ev.key === 'Enter') { ev.preventDefault(); onPeriodEntered(); }
  });
  periodTextInput.addEventListener('blur', onPeriodEntered);

  periodPointer.addEventListener('pointerdown', onPointerDragStart);
  periodPointer.addEventListener('keydown', onPointerKeydown);

  pdmCanvas.addEventListener('pointerdown', onPDMPointerDown);

  deltaBar1.addEventListener('pointerdown', (ev) => onDeltaPointerDown(ev, deltaBar1));
  deltaBar2.addEventListener('pointerdown', (ev) => onDeltaPointerDown(ev, deltaBar2));
  deltaBar1.addEventListener('keydown', onDeltaBarKeydown);
  deltaBar2.addEventListener('keydown', onDeltaBarKeydown);
  lightcurveCanvas.addEventListener('pointerdown', (ev) => onDeltaPointerDown(ev, null));

  const starfieldWrap = starfieldCanvas.parentElement;
  starfieldWrap.addEventListener('pointermove', updateCrosshairFromEvent);
  starfieldWrap.addEventListener('pointerleave', () => { crosshairOverlay.hidden = true; });

  haloLayer.addEventListener('keydown', onStarFieldKeydown);
  haloLayer.addEventListener('focus', () => {
    /* Announce how to drive the field the first time it receives focus. */
    if (state.dataGenerationDone && !state.starFieldFocusAnnounced) {
      state.starFieldFocusAnnounced = true;
      announce('Star field, ' + state.starsList.length +
        ' stars. Use the arrow keys to move between stars and press Enter to select.');
    }
  });

  document.addEventListener('sim-reset', resetSim);

  /* ====================== MathJax / equations hook ====================== */
  let eqnInitDone = false;
  window.klunlInitEqn = function () {
    if (eqnInitDone) return;
    eqnInitDone = true;
    /* Typeset the PDM y-axis label (the statistic name, kept verbatim as
       "theta") and pair it with a spoken description. */
    klunlShowEquation(
      ['pdm-ytitle', '\\(\\text{theta}\\)'],
      ['pdm-ytitle-sr', 'theta, the phase dispersion minimization statistic. Lower theta means a better candidate period.']
    );
    /* MathJax output is display-only: keep it out of the Tab order. MathJax
       adds tabindex="0" to its containers on every typeset pass, so watch for
       them and force tabindex="-1" (the right-click MathJax menu still works,
       and screen readers still read the math). */
    const detab = () => {
      document.querySelectorAll('mjx-container').forEach((el) => {
        if (el.getAttribute('tabindex') !== '-1') el.setAttribute('tabindex', '-1');
      });
    };
    detab();
    new MutationObserver(detab).observe(document.body, { childList: true, subtree: true, attributeFilter: ['tabindex'] });
  };

  /* ================== plot scale matching (presentation) ================
     Both plots draw their tick labels at the same internal 12 px and use the
     same tick lengths, so they only *look* the same on screen when both
     canvases are displayed at the same px-per-canvas-unit scale. The PDM
     canvas fills its column; the lightcurve canvas is sized here to the same
     scale. This affects CSS display size only — internal coordinates and all
     ported math are untouched, and pointer input is mapped through
     getBoundingClientRect, so parity is unaffected. */
  let lastMatchedWidth = -1;
  function matchPlotScales() {
    const wrap = lightcurveCanvas.parentElement;
    const pdmWidth = pdmCanvas.getBoundingClientRect().width;
    if (!pdmWidth) return;                       // not laid out yet
    /* Target width depends only on the PDM canvas, never on the lightcurve's
       own container, so the value cannot feed back on itself. The write-guard
       below stops any observer ping-pong. CSS max-width: 100% clamps it if
       the panel is narrower than the target. */
    const target = LC.canvasW * (pdmWidth / PDM.canvasW);
    if (Math.abs(target - lastMatchedWidth) < 0.5) return;
    lastMatchedWidth = target;
    wrap.style.flexBasis = target + 'px';
    wrap.style.width = target + 'px';
  }
  /* Run immediately plus two deferred passes: the first pass may observe a
     mid-resize layout. setTimeout (not requestAnimationFrame) so the sync
     still happens when the page is in a background/non-compositing tab. */
  function scheduleMatch() {
    matchPlotScales();
    setTimeout(matchPlotScales, 0);
    setTimeout(matchPlotScales, 80);
  }
  if (window.ResizeObserver) {
    const ro = new ResizeObserver(scheduleMatch);
    ro.observe(pdmCanvas);                    // the input to the calculation
    ro.observe(lightcurveCanvas.parentElement.parentElement);  // trigger only
  }
  window.addEventListener('resize', scheduleMatch);
  window.addEventListener('orientationchange', scheduleMatch);
  window.addEventListener('load', scheduleMatch);
  /* ResizeObserver delivery is tied to the frame loop, which is suspended in
     a background tab; re-sync when the page becomes visible again. */
  document.addEventListener('visibilitychange', () => {
    if (!document.hidden) scheduleMatch();
  });
  if (document.fonts && document.fonts.ready) document.fonts.ready.then(scheduleMatch);

  /* Debug handle for automated tests (read-only use). */
  window.__vspaDebug = { state, starField, hiddenStarField, lightcurvePlot, pdmPlot, pixelMask };

  /* ============================== start ================================= */
  function start() {
    init();
    matchPlotScales();
    /* MathJax may have finished its startup pass before this script ran (its
       ready hook then found no klunlInitEqn yet), so trigger the equation
       setup from here once MathJax is available. */
    if (window.MathJax && MathJax.startup && MathJax.startup.promise) {
      MathJax.startup.promise.then(() => window.klunlInitEqn());
    }
  }
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', start);
  } else {
    start();
  }
})();
