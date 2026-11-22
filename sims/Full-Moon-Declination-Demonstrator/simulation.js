/* ==========================================================================
   Full Moon Declination Demonstrator — accessible HTML5 port
   Ported from fullMoonDec001 (Adobe Flash / AS1).

   Ground truth for behavior is the decompiled ActionScript. Constants,
   formulas, and colors match that source:
     - Moon Dec Demo.as   : sphere scene, Sun/Moon from day of year
     - Moon Dec Plot.as   : declination-range curve + shaded band
     - frame_1/DoAction.as: reset() -> setThetaAndPhi(200,20), setDayOfYear(45)
     - CelestialSphere.as + 2..11 CS *.as: projection engine (foundation)
   ========================================================================== */

import {
  CelestialSphere, Circle, Line,
  CELESTIAL_SPHERE_COLORS,
  D2R, R2D, H2R, R2H, TWO_PI, HALF_PI, PI,
  drawCircleBucket, drawLineLayer,
  drawStarSprite, projectPointScreen, 
  absOrient
} from '../foundation/js/kl-unl-celestial-sphere.js';

import {
  legToFixed, speak, pMod, clamp, keyAccel,
  hexToRGBA, announceLive, announceSettled, VO_FIX_LGND, logAct,
  descMoreKeys, hideMoreKeys
} from '../foundation/js/kl-unl-utils.js';

import { DualControl } from '../foundation/js/kl-unl-dual-control.js';

logAct('INIT_FullMoonDec');

// Assume vanilla URL (masthead and control panels shown)
let urlClean = false;

let announceTimer;

/* ---- Simulation-specific palette ---------------------- */
const COL_ECLIPTIC   = '#a04040';     // dull red
const COL_MERIDIAN   = '#4675d5';     // cornflower blue (not #ffe375, yellow blends with grey sphere)
const COL_EQUATOR    =  COL_MERIDIAN; 
const COL_POLE_AXIS  =  COL_MERIDIAN; // was light sky blue (#75a9ff)
const COL_BAND_EDGE  = '#ff0000';     // red
const COL_PLOT_CURVE = '#a04040';     // muted  red
const COL_PLOT_BAND  = '#d08080';     // reddish-pink
const COL_BAND_IN    = '#f18d8d';     // coral  pink
const COL_BAND_OUT   = '#6c1e1e';     // deep   maroon
const COL_HOR_IN     = '#51c451';     // medium green
const COL_HOR_OUT    = '#3aa53a';     // medium-dark green

const SIN_OBLIQ      =   0.39714789063478056;  // sin obliquity (AS)
const COS_OBLIQ      =   0.9177546256839811;   // cos obliquity (AS)

const INIT_THETA     = 200;
const INIT_PHI       =  20;
const MIN_PHI        =   7;
const INIT_DAY       =  45;
const INIT_LAT       =  41;
let   xLat           = INIT_LAT;

const LAT_PRECISION  =   0;
const LAT_STEP       =   1;
const LAT_PAGE       =   5;

const DOY_STEP       =   1;
const VIEW_STEP      =   5;

const MONTHS_FULL = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December'
];
const MONTHS_SHORT = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
];

const srStatus   = document.getElementById('sr-status');
const plotCanvas = document.getElementById('plot-canvas');
const skyCanvas  = document.getElementById('sky-canvas');
const plotCtx    = plotCanvas.getContext(  '2d');
const skyCtx     = skyCanvas.getContext(   '2d');

/* ========================================================================
   Disc — screen projection of Sun / Moon (rotationally symmetric)
   ======================================================================== */
class Disc {
  constructor(sphere, position) {
    this.s   = sphere;
    this._sp = { x: 0, y: 0, z: 0 };
    this.setPosition(position);
  }
  setPosition(a) {
    const p  = this.s.parse(a);
    this._sys = (p.sys === 1) ? 1 : 0;
    this._p   = p;
  }
  update() {
    if (this._sys === 0) this.s.WtoSz(this._p, this._sp);
    else                 this.s.CtoSz(this._p, this._sp);
  }
}

/* ========================================================================
   ShadedBand — faithful port of "11 CS Shaded Bands.as" (sim-local;
   not yet in foundation). Adapted to CelestialSphere.c (not ._c).
   ======================================================================== */
class ShadedBand {
  constructor(sphere, params) {
    this.s        = sphere;
    this._c       = {};
    this.visible  = true;
    this._bThick  = 1;
    this._bColor  = COL_BAND_EDGE;
    this._bAlpha  = 0.4;
    this.setParameters(params);
  }
  setParameters(a) {
    this._sys  = 1;
    this._beta = (a.ra != null) ? H2R * pMod(a.ra, 24) : 0;
    this._tilt = (a.tilt != null)
      ? (a.tilt < 0 ? 0 : a.tilt > 180 ? PI : a.tilt * D2R)
      : 0;
    if      (a.dec1 <= -90) { this._lambda1 = -HALF_PI; this._type1 = 1; }
    else if (a.dec1 >=  90) { this._lambda1 =  HALF_PI; this._type1 = 1; }
    else                    { this._lambda1 = a.dec1 * D2R; this._type1 = 0; }
    if      (a.dec2 <= -90) { this._lambda2 = -HALF_PI; this._type2 = 1; }
    else if (a.dec2 >=  90) { this._lambda2 =  HALF_PI; this._type2 = 1; }
    else                    { this._lambda2 = a.dec2 * D2R; this._type2 = 0; }
    if (this._lambda1 > this._lambda2) {
      let t = this._lambda2; this._lambda2 = this._lambda1; this._lambda1 = t;
      t = this._type2; this._type2 = this._type1; this._type1 = t;
    }
    this.doK();
  }
  doK() {
    const st = Math.sin(this._tilt), ct = Math.cos(this._tilt);
    const sb = Math.sin(this._beta), cb = Math.cos(this._beta);
    const c  = this._c;
    c.k0 = cb; c.k1 = -sb * ct; c.k2 =  sb * st;
    c.k3 = sb; c.k4 =  cb * ct; c.k5 = -cb * st;
    c.k7 = st; c.k8 = ct;
  }
  buildPaths() {
    const tc = this._c, pc = this.s.c, s = 100 / this.s.c.r;
    let v0, v1, v2, v3, v4, v5, v6, v7, v8;
    v0 = s * (pc.b0 * tc.k0 + pc.b1 * tc.k3);
    v1 = s * (pc.b0 * tc.k1 + pc.b1 * tc.k4 + pc.b2 * tc.k7);
    v2 = s * (pc.b0 * tc.k2 + pc.b1 * tc.k5 + pc.b2 * tc.k8);
    v3 = s * (pc.b3 * tc.k0 + pc.b4 * tc.k3);
    v4 = s * (pc.b3 * tc.k1 + pc.b4 * tc.k4 + pc.b5 * tc.k7);
    v5 = s * (pc.b3 * tc.k2 + pc.b4 * tc.k5 + pc.b5 * tc.k8);
    v6 = s * (pc.b6 * tc.k0 + pc.b7 * tc.k3);
    v7 = s * (pc.b6 * tc.k1 + pc.b7 * tc.k4 + pc.b8 * tc.k7);
    v8 = s * (pc.b6 * tc.k2 + pc.b7 * tc.k5 + pc.b8 * tc.k8);

    const front = new Path2D(), back = new Path2D();
    const minStep = 0.5235987755982988;
    const cl1 = Math.cos(this._lambda1), sl1 = Math.sin(this._lambda1);
    const cl2 = Math.cos(this._lambda2), sl2 = Math.sin(this._lambda2);
    const cos = Math.cos, sin = Math.sin, asin = Math.asin;
    const atan2 = Math.atan2, sqrt = Math.sqrt;
    const self = this;

    function perim(t1, t2, dir) {
      let arc, doMove;
      if (dir === 1) { arc = pMod(t2 - t1, TWO_PI); }
      else           { arc = pMod(t1 - t2, TWO_PI); }
      if (arc === 0) { arc = TWO_PI; doMove = true; } else { doMove = false; }
      const n = Math.ceil(arc / minStep);
      const step = (dir === 1 ? arc : -arc) / n;
      const half = step / 2, cr = 100 / cos(half);
      if (doMove) {
        front.moveTo(100 * cos(t1), 100 * sin(t1));
        back.moveTo( 100 * cos(t1), 100 * sin(t1));
      }
      let aA = t1 + step, cA = aA - half;
      for (let i = 0; i < n; i++) {
        const ax = 100 * cos(aA), ay = 100 * sin(aA);
        const cx = cr * cos(cA),  cy = cr * sin(cA);
        front.quadraticCurveTo(cx, cy, ax, ay);
        back.quadraticCurveTo( cx, cy, ax, ay);
        aA += step; cA += step;
      }
    }
    function sph(path, g1, g2, cl, sl, dir) {
      let arc, doMove;
      if (dir === 1) { arc = pMod(g2 - g1, TWO_PI); }
      else           { arc = pMod(g1 - g2, TWO_PI); }
      if (arc === 0) { arc = TWO_PI; doMove = true; } else { doMove = false; }
      const n = Math.ceil(arc / minStep);
      const step = (dir === 1 ? arc : -arc) / n;
      const half = step / 2, cRad = 1 / cos(half);
      let iax = cos(g1), iay = sin(g1);
      let ax = cl * (v0 * iax + v1 * iay) + sl * v2;
      let ay = cl * (v3 * iax + v4 * iay) + sl * v5;
      if (doMove) path.moveTo(ax, ay);
      let aA = g1 + step, cA = aA - half;
      for (let i = 0; i < n; i++) {
        iax = cos(aA); iay = sin(aA);
        const icx = cRad * cos(cA), icy = cRad * sin(cA);
        ax = cl * (v0 * iax + v1 * iay) + sl * v2;
        ay = cl * (v3 * iax + v4 * iay) + sl * v5;
        const cx = cl * (v0 * icx + v1 * icy) + sl * v2;
        const cy = cl * (v3 * icx + v4 * icy) + sl * v5;
        path.quadraticCurveTo(cx, cy, ax, ay);
        aA += step; cA += step;
      }
    }

    let startX = null, startY = null;
    let gD1, gA1, tD1, tA1, gD2, gA2, tD2, tA2, loc1, loc2, x, y, j, t;

    const A1 = cl1 * sqrt(v6 * v6 + v7 * v7);
    if (A1 === 0) { loc1 = (sl1 * v8 < 0) ? 2 : 1; }
    else {
      const sj1 = -sl1 * v8 / A1;
      if      (sj1 <= -1) loc1 = 1;
      else if (sj1 >=  1) loc1 = 2;
      else {
        loc1 = 0; j = asin(sj1); t = atan2(v6, v7);
        if (cos(j) < 0) { gD1 = j - t; gA1 = PI - j - t; }
        else            { gD1 = PI - j - t; gA1 = j - t; }
        x = cos(gD1); y = sin(gD1);
        tD1 = atan2(cl1 * (v3 * x + v4 * y) + sl1 * v5,
                    cl1 * (v0 * x + v1 * y) + sl1 * v2);
        x = cos(gA1); y = sin(gA1);
        startX = cl1 * (v0 * x + v1 * y) + sl1 * v2;
        startY = cl1 * (v3 * x + v4 * y) + sl1 * v5;
        tA1 = atan2(startY, startX);
      }
    }
    const A2 = cl2 * sqrt(v6 * v6 + v7 * v7);
    if (A2 === 0) { loc2 = (sl2 * v8 < 0) ? 2 : 1; }
    else {
      const sj2 = -sl2 * v8 / A2;
      if      (sj2 <= -1) loc2 = 1;
      else if (sj2 >=  1) loc2 = 2;
      else {
        loc2 = 0; j = asin(sj2); t = atan2(v6, v7);
        if (cos(j) < 0) { gD2 = j - t; gA2 = PI - j - t; }
        else            { gD2 = PI - j - t; gA2 = j - t; }
        x = cos(gD2); y = sin(gD2);
        tD2 = atan2(cl2 * (v3 * x + v4 * y) + sl2 * v5,
                    cl2 * (v0 * x + v1 * y) + sl2 * v2);
        x = cos(gA2); y = sin(gA2);
        if (startX == null) {
          startX = cl2 * (v0 * x + v1 * y) + sl2 * v2;
          startY = cl2 * (v3 * x + v4 * y) + sl2 * v5;
          tA2 = atan2(startY, startX);
        } else {
          tA2 = atan2(cl2 * (v3 * x + v4 * y) + sl2 * v5,
                      cl2 * (v0 * x + v1 * y) + sl2 * v2);
        }
      }
    }
    function moveStart() {
      front.moveTo(startX, startY);
      back.moveTo( startX, startY);
    }

    if (loc1 === 0 && loc2 === 0) {
      moveStart(); perim(tA1, tA2, 1);
      sph(front, gA2, gD2, cl2, sl2, 1); sph(back, gA2, gD2, cl2, sl2, -1);
      perim(tD2, tD1, 1);
      sph(front, gD1, gA1, cl1, sl1, -1); sph(back, gD1, gA1, cl1, sl1, 1);
    } else if (loc1 === 0 && loc2 === 1) {
      moveStart();
      sph(front, gA1, gD1, cl1, sl1, 1); sph(back, gA1, gD1, cl1, sl1, -1);
      perim(tD1, tA1, -1);
      if (self._type2 === 0) sph(front, 0, 0, cl2, sl2, -1);
    } else if (loc1 === 0 && loc2 === 2) {
      moveStart();
      sph(front, gA1, gD1, cl1, sl1, 1); sph(back, gA1, gD1, cl1, sl1, -1);
      perim(tD1, tA1, -1);
      if (self._type2 === 0) sph(back, 0, 0, cl2, sl2, 1);
    } else if (loc1 === 1 && loc2 === 0) {
      moveStart();
      sph(front, gA2, gD2, cl2, sl2, 1); sph(back, gA2, gD2, cl2, sl2, -1);
      perim(tD2, tA2, 1);
      if (self._type1 === 0) sph(front, 0, 0, cl1, sl1, -1);
    } else if (loc1 === 1 && loc2 === 1) {
      if (self._type1 === 0) sph(front, 0, 0, cl1, sl1, 1);
      if (self._type2 === 0) sph(front, 0, 0, cl2, sl2, -1);
    } else if (loc1 === 1 && loc2 === 2) {
      if (self._type1 === 0) sph(front, 0, 0, cl1, sl1, 1);
      if (self._type2 === 0) sph(back,  0, 0, cl2, sl2, 1);
      perim(0, 0, -1);
    } else if (loc1 === 2 && loc2 === 0) {
      moveStart();
      sph(front, gA2, gD2, cl2, sl2, 1); sph(back, gA2, gD2, cl2, sl2, -1);
      perim(tD2, tA2, 1);
      if (self._type1 === 0) sph(back, 0, 0, cl1, sl1, 1);
    } else if (loc1 === 2 && loc2 === 1) {
      if (self._type1 === 0) sph(back,  0, 0, cl1, sl1, 1);
      if (self._type2 === 0) sph(front, 0, 0, cl2, sl2, 1);
      perim(0, 0, 1);
    } else if (loc1 === 2 && loc2 === 2) {
      if (self._type1 === 0) sph(back, 0, 0, cl1, sl1, 1);
      if (self._type2 === 0) sph(back, 0, 0, cl2, sl2, -1);
    }
    return { front, back };
  }
}

/* ======================= SCENE ========================================== */
const S = new CelestialSphere(150);
S.setMinPhi(MIN_PHI);
S.setLatitude(INIT_LAT);

S.CSC = CELESTIAL_SPHERE_COLORS;
const imgStick = new Image(), imgMoon = new Image(), imgSun = new Image();
loadAssets();

const moonBand = new ShadedBand(S, { dec1: -5.1, dec2: 5.1, tilt: 23.4 });

const ecliptic = new Circle(S,
  { thickness: 2, color: COL_ECLIPTIC, alpha: 0.5 },
  { ra: 0, dec: 0, tilt: 23.4 });
const meridian = new Circle(S,
  { thickness: 2, color: COL_MERIDIAN, alpha: 0.7 },
  { az: 0, alt: 0, tilt: 90 });
const celestialEquator = new Circle(S,
  { thickness: 2, color: COL_EQUATOR, alpha: 0.7 },
  { ra: 0, dec: 0, tilt: 0 });
const circles = [ecliptic, meridian, celestialEquator];

const ncpAxis = new Line(S,
  { thickness: 2, color: COL_POLE_AXIS, alpha: 1 },
  { x: 0, y: 0, z:  1,    system: 'celestial' },
  { x: 0, y: 0, z:  1.15, system: 'celestial' });
const scpAxis = new Line(S,
  { thickness: 2, color: COL_POLE_AXIS, alpha: 1 },
  { x: 0, y: 0, z: -1,    system: 'celestial' },
  { x: 0, y: 0, z: -1.15, system: 'celestial' });
const lines = [ncpAxis, scpAxis];

const sun  = new Disc(S, { ra: 0,  dec: 0 });
const moon = new Disc(S, { ra: 12, dec: 0 });

const state = { dayOfYear: INIT_DAY, moonDec: 0 };

function moonDecAt(doy) {
  const lon = (doy - 78.5) / 365 * TWO_PI;
  return -R2D * Math.asin(SIN_OBLIQ * Math.sin(lon));
}

function setDayOfYear(arg) {
  const doy            = pMod(arg, 365);
  state.dayOfYear      = doy;
  const sunLongitude   = (doy - 78) / 365 * TWO_PI;
  const sunDeclination = Math.asin(SIN_OBLIQ * Math.sin(sunLongitude));
  const sunDec         = R2D * sunDeclination;
  const sunRA          = pMod(
    R2H * Math.atan2(Math.sin(sunLongitude) * COS_OBLIQ, Math.cos(sunLongitude)),
    24);
  sun.setPosition( { ra: sunRA,      dec:  sunDec });
  moon.setPosition({ ra: sunRA + 12, dec: -sunDec });
  S.setSiderealTime(sunRA + 12);
  state.moonDec        = moonDecAt(doy);
  syncReadouts();
}

function monthName(doy) {
  let m = Math.floor(pMod(doy, 365) / 365 * 12);
  if (m > 11) m = 11;
  return MONTHS_FULL[m];
}

function loadAssets() {
  let   pending  = 3;
  const done = () => { if (--pending === 0) renderSky(); };
  imgStick.onload = done; imgStick.onerror = done;
  imgSun.onload   = done; imgSun.onerror   = done;
  imgMoon.onload  = done; imgMoon.onerror  = done;
  imgStick.src    = 'images/stickfigure.png';
  imgSun.src      = 'images/sun-disc.svg';
  imgMoon.src     = 'images/moon-disc.svg';
}

/* ---- interpretive helpers ---------------------------------------------- */
function moonAltitudeMeaning() {
  // Characterize the season, observer location, and lunar altitude
  
  const dec = state.moonDec;
  const lat = S.getLatitude();
  const alt = 90 - Math.abs( state.moonDec - S.getLatitude() );
  const day = state.dayOfYear;
  
  let   season, mLoc;
  let   s0,s1, s2;
  
  [ season, mLoc ] = placeSeason( day, lat, alt );
  
  if ( Math.abs(lat) < 23.5 )  {
    s0 = 'Near the equator, the full Moon always transits high in the sky. ';
  } else if ( 66.5 <= lat   )  {
    s0 = season + 'above the Arctic Circle, '       + mLoc;
  } else if ( 23.5 <= lat   )  {
    s0 = season + 'above the Tropic of Cancer, '    + mLoc;
  } else if ( lat  <= -23.5 )  {
    s0 = season + 'below the Tropic of Capricorn, ' + mLoc;
  } else if ( lat  <= -66.5 )  {
    s0 = season + 'below the Antarctic Circle, '    + mLoc;
  }
  return s0;
}


function placeSeason(day, lat, alt)  {
  // Characterize the northern or southern season and the lunar altitude, where 
  // the heart of a season is +/- 1/16 of a year around it (1/8 of a year in total),
  // and the intervening 1/8 year periods are described as heading into the next
  // season (because the lunar declination shifts monotonically between maxima 
  // and minima through all four intervals, as well as in spring and autumn).
  
  const seas = [ 'winter', 'spring', 'spring', 'summer', 'summer', 'autumn', 'autumn', 'winter' ];
  const phse = [ 'heart',  'into',   'heart',  'into',   'heart',  'into',   'heart',  'into'   ];
  const trnd = [  2,        -1,       -1,       -1,       -2,       +1,       +1,       +1      ];
  
  const hemi = (lat >= 0) ? 'northern' : 'southern';
  const now1 = Math.floor( 8 * ( pMod(day + 11, 365) / 365 ) );  // days since northern winter solstice
  const now2 = Math.floor( 8 * ( pMod(day + 34, 365) / 365 ) );  // shift by 1/16 of a year (23 days)
  const now3 = (lat >= 0) ? now2 : pMod( now2 - 4, 7 );          // match hemisphere
  
  let   s0, s1, s2;
  
  s0 = (lat >= 0) ? 'southern' : 'northern';
  if ( phse[now2] === 'heart' )    s1  = 'In the heart of ' + hemi + ' ' + seas[now3] + ' ';
  else                             s1  = 'As we head into ' + hemi + ' ' + seas[now3] + ' ';
                                   s2  = 'the full Moon transits ';
  if      (alt < 0)                s2 += 'below the '      + s0 + ' horizon. ';
  else if (alt < 5)                s2 += 'just above the ' + s0 + ' horizon. ';
  else  {
    if      ( trnd[now3] === -1 )  s2 += 'lower and lower ';
    else if ( trnd[now3] === +1 )  s2 += 'higher and higher ';
    else if (60 <= alt)            s2 += 'high ';
                                   s2 += 'above the ' + s0 + ' horizon';
    if      ( trnd[now3] === -1 )  s2 += ' with each passing day';
    else if ( trnd[now3] === +1 )  s2 += ' with each passing day';
                                   s2 += '. ';
  }
  return [ s1, s2 ];
}

function dayAnnounce(settled) {
  const msg =
    'Day ' + legToFixed(state.dayOfYear, 0) + ' (' + monthName(state.dayOfYear) +
        '). Full Moon declination ' + speak(state.moonDec, 0, 'degree') + '. ';

  if (settled) announceSettled(srStatus, msg);
  else         announceLive(   srStatus, msg);
  refreshCanvasNames();
}

function viewAnnounce(settled) {
  const msg =
    'Celestial sphere rotated by ' + speak(pMod(S.getTheta(), 360), 0, 'degree') +
                ', and tilted by ' + speak(     S.getPhi(),         0, 'degree') + '. ' 

  if (settled) announceSettled(srStatus, msg);
  else         announceLive(   srStatus, msg);
  refreshCanvasNames();
}

function plotAriaLabel() {
  return 'Plot of the full Moon declination over the year; current declination '      + 
    speak(state.moonDec, LAT_PRECISION, 'degree') + ' on day ' + legToFixed(state.dayOfYear, 0) +
    ' (' + monthName(state.dayOfYear) + '). ' + 
    ' Shaded band encompasses plus or minus 7 degrees of lunar wander.';
}

function skyAriaLabel() {
  const hemi = S.getLatitude() < 0 ? 'south' : 'north';

  return 'Horizon diagram for an observer at latitude ' +
    speak(Math.abs( S.getLatitude() ), LAT_PRECISION, 'degree') + ' ' + hemi +
    ' on day ' + legToFixed(state.dayOfYear, 0) + ' (' + monthName(state.dayOfYear) + '). ' +
    moonAltitudeMeaning() + 
    'Gold Sun and grey full Moon appear on opposite sides of the celestial sphere, '     +
    'with blue celestial equator, local meridian, and North and South Celestial Poles, ' +
    'pink ecliptic and lunar declination band, and green horizon plane marked '             +
    'North, East, South, and West. ' +
    'Celestial sphere rotated by ' + speak(pMod(S.getTheta(), 360), 0, 'degree') +
    ', and tilted by ' + speak(     S.getPhi(),         0, 'degree') + '. ';
}

function refreshCanvasNames() {
  if (document.activeElement !== plotCanvas) {
    plotCanvas.setAttribute('aria-label', plotAriaLabel());
  }
  if (document.activeElement !== skyCanvas) {
    skyCanvas.setAttribute('aria-label', skyAriaLabel());
  }
}

plotCanvas.addEventListener('blur', () => {
  plotCanvas.setAttribute('aria-label', plotAriaLabel());
});
skyCanvas.addEventListener('blur', () => {
  skyCanvas.setAttribute('aria-label', skyAriaLabel());
});

/* =========================== DualControl (day) ========================== */
const doyDual = new DualControl({
  mount:          '#doy-dual-mount',
  id:             'doy',
  label:          'Day of Year:',
  min:            1,
  max:            365,
  step:           DOY_STEP,
  pageStep:       30,
  value:          INIT_DAY,
  unit:           '',
  minLabel:       '1',
  maxLabel:       '365',
  wrap:           true,
  liveRegion:     document.getElementById('doy-dual-live'),
  numberRowClass: 'control-row sim-dual-number kl-dual__number-row',
  sliderRowClass: 'control-row sim-dual-slider kl-dual__slider-row',
  numberClass:    'control-row__input  sim-dual-num kl-dual__number',
  sliderClass:    'control-row__slider sim-dual-range kl-dual__slider',
  formatValue:    (v) => legToFixed(v, 0),
  formatAnnounce: (v) =>
    'Day of year ' + speak(v, 0) + ', ' + monthName(v),
  announceMoving:  true,
  onInput: (v) => {
    setDayOfYear(v);
    requestRender();
  },
  onChange: (v) => {
    setDayOfYear(v);
    requestRender();
    refreshCanvasNames();
    return 'Day ' + speak(v, 0) + ' (' + monthName(v) + '). ';
  }
});

/* Accessible paired latitude number box + muted slider (aria-hidden). */
const latDual = new DualControl({
  mount:           '#latitude-dual-mount',
  id:              'latitude',
  label:           'Latitude:',
  min:             -90,
  max:              90,
  step:            LAT_STEP,
  pageStep:        LAT_PAGE,
  value:           INIT_LAT,
  unit:            '°',
  minLabel:        '90&deg;&nbsp;S',
  maxLabel:        '90&deg;&nbsp;N',
  numberRowClass:  'control-row sim-row-number     kl-dual__number-row',
  sliderRowClass:  'control-row sim-row-latitude   kl-dual__slider-row',
  numberClass:     'control-row__input  sim-number kl-dual__number',
  sliderClass:     'control-row__slider sim-slider kl-dual__slider',
  formatValue:     (v) => legToFixed(v, LAT_PRECISION),
  formatAnnounce:  (v) => latSpoken(v),
  /* Call out multiples of 30 degrees while dragging. */
  milestone:       (v) => (v % 30 === 0) && (Math.abs(v) !== 90),
  announceMoving:  true,
  autoAnnounce:    true,
  onInput:         (v) => { setLatitude(v); },
  onChange:        (v) => commitLatitude(v, true)
});

function commitDoy(d, announceIt, settled) {
  d = Math.round(d);
  d = clamp(d, 1, 365);
  doyDual.setValue(d);
  setDayOfYear(d);
  requestRender();
  if (announceIt) dayAnnounce(settled);
  else refreshCanvasNames();
}

function stepDay(delta, settled) {
  commitDoy(state.dayOfYear + delta, true, settled);
}

function setLatitude(deg) {
  const k = Math.pow(10, LAT_PRECISION);
  let   v = Math.round(k * deg) / k;
  if      (v < -90) v = -90;
  else if (v >  90) v =  90;
  S.setLatitude(v);
  requestRender();
}

function commitLatitude(v, doAnnounce) {
  setLatitude(v);

  let msg = null;
  if (doAnnounce) {
    let s0;
    if ( ( ( v * xLat < 0 )        ||
         ( v    == 0 && xLat < 0 ) ||
         ( xLat == 0 && v    < 0 ) ) )  {
      s0   = '. Observer now in ';
      s0  += ( v >= 0 ) ? 'northern' : 'southern';
      s0  += ' hemisphere. ';
    } else {
      s0 = '. ';
    }
    xLat = v;
    msg  = latSpoken(v) + s0;
  }

  if (document.activeElement !== skyCanvas) {
    skyCanvas.setAttribute('aria-label', skyAriaLabel());
  } else if ( urlClean )  {
    clearTimeout(announceTimer);
    announceTimer = setTimeout(() => { announceLive( srStatus, msg ); }, 600);
  }

  return msg;
}

function latSpoken(v) {
  const hemi = v < 0 ? 'south' : 'north';
  return 'Latitude ' + speak(Math.abs(v), LAT_PRECISION, 'degree') + ' ' + hemi;
}

/* =========================== SKY RENDERING ============================== */
const SKY_STAGE = 380;
const SKY_CX    = SKY_STAGE / 2;
const SKY_CY    = SKY_STAGE / 2;

function fitSky() {
  const dpr = window.devicePixelRatio || 1;
  skyCanvas.width  = SKY_STAGE * dpr;
  skyCanvas.height = SKY_STAGE * dpr;
  skyCtx.setTransform(dpr, 0, 0, dpr, 0, 0);
}

function fillBand(path, alpha) {
  const r = S.c.r;
  skyCtx.save();
  skyCtx.scale(r / 100, r / 100);
  const g = skyCtx.createRadialGradient(0, 0, 0, 0, 0, 100);
  g.addColorStop(0, hexToRGBA(COL_BAND_IN,  alpha));
  g.addColorStop(1, hexToRGBA(COL_BAND_OUT, alpha));
  skyCtx.fillStyle = g;
  skyCtx.fill(path);
  skyCtx.lineWidth   = 100 / r;
  skyCtx.strokeStyle = hexToRGBA(COL_BAND_EDGE, 0.4);
  skyCtx.stroke(path);
  skyCtx.restore();
}

function drawBowl() {
  const r = S.c.r;
  const g = skyCtx.createRadialGradient(0, 0, 0, 0, 0, r);
  g.addColorStop(0,    'rgba(255,255,255,0)');
  g.addColorStop(0.75, 'rgba(0,0,0,0.03)');
  g.addColorStop(1,    'rgba(0,0,0,0.20)');
  skyCtx.fillStyle = g;
  skyCtx.beginPath();
  skyCtx.arc(0, 0, r, 0, TWO_PI);
  skyCtx.fill();
}

function drawHorizonPlane() {
  skyCtx.beginPath();
  const N = 96;
  const sp = {};
  for (let i = 0; i <= N; i++) {
    S.WtoSz(S.parse({ az: i / N * 360, alt: 0, r: 1 }), sp);
    if (i === 0) skyCtx.moveTo(sp.x, sp.y);
    else         skyCtx.lineTo(sp.x, sp.y);
  }
  skyCtx.closePath();
  const g = skyCtx.createRadialGradient(0, 0, 0, 0, 0, S.c.r);
  g.addColorStop(0, COL_HOR_IN);
  g.addColorStop(1, COL_HOR_OUT);
  skyCtx.fillStyle   = g;
  skyCtx.globalAlpha = 0.92;
  skyCtx.fill();
  skyCtx.globalAlpha = 1;
  skyCtx.strokeStyle = 'rgba(255,255,255,0.45)';
  skyCtx.lineWidth   = 1;
  skyCtx.stroke();
}

const DIRS = [
  { az:   0, t: 'N' },
  { az:  90, t: 'E' },
  { az: 180, t: 'S' },
  { az: 270, t: 'W' }
];

function drawCardinalLabel(az, text) {
  //const ctx = this.ctx, S = this.S;
  const p = {};
  S.parsePointInput({ az, alt: 0, r: 0.82 }, p);
  const n = { x: 0, y: 0, z: 1 };
  const u = { x: 1, y: 0, z: 0 };   // N's plane "up" — same for all cardinals
  const o = absOrient(S, p, n, u);
  skyCtx.save();
  skyCtx.translate(o.sp.x, o.sp.y);
  skyCtx.rotate(o.shellRot);
  skyCtx.scale(1, o.yscale);
  skyCtx.rotate(o.instRot);
  skyCtx.lineJoin     = 'round';
  skyCtx.miterLimit   = 2;
  skyCtx.font         = '600 25px system-ui, -apple-system, Segoe UI, sans-serif';
  skyCtx.textAlign    = 'center';
  skyCtx.textBaseline = 'middle';
  skyCtx.lineWidth    = 3;
  skyCtx.strokeStyle  = S.CSC.NESW_LINE;
  skyCtx.fillStyle    = S.CSC.NESW_FILL;
  skyCtx.strokeText(text, 0, 0);
  skyCtx.fillText(  text, 0, 0);
  skyCtx.restore();
}

// which: 'back' (sp.z < 0, before figure) or 'front' (sp.z >= 0, after figure)
function drawCardinals(which) {
  if (S.phi <= 0) return;
  for (const c of DIRS) {
    const p = {}, sp = {};
    S.parsePointInput({ az: c.az, alt: 0, r: 0.82 }, p);
    S.WtoSz(p, sp);
    const behind = sp.z < 0;
    if ((which === 'back' && behind) || (which === 'front' && !behind)) {
      drawCardinalLabel(c.az, c.t);
    }
  }
}

const CPS = [
  { x: 0, y: 0, z:  1.21, system: 'celestial', t: 'NCP' },
  { x: 0, y: 0, z: -1.21, system: 'celestial', t: 'SCP' }
];

function drawCelestialPoleLabel(sp, text, behind) {
  skyCtx.save();
  skyCtx.translate(sp.x, sp.y);
  skyCtx.globalAlpha  = 1;
  skyCtx.lineJoin     = 'round';
  skyCtx.miterLimit   = 2;
  skyCtx.font         = '600 13px system-ui, -apple-system, Segoe UI, sans-serif';
  skyCtx.textAlign    = 'center';
  skyCtx.textBaseline = 'middle';
  skyCtx.lineWidth    = 3;
  skyCtx.strokeStyle  = S.CSC.LABEL_HALO;
  skyCtx.fillStyle    = COL_POLE_AXIS;
  skyCtx.strokeText(text, 0, 0);
  skyCtx.fillText(  text, 0, 0);
  skyCtx.restore();
}

// which: 'back' (sp.z < 0, behind sphere) or 'front' (sp.z >= 0, in front)
function drawCelestialPoles(which) {
  for (const c of CPS) {
    const p  = {};
    const sp = {};
    S.parsePointInput(c, p);
    S.CtoSz(p, sp);
    const behind = sp.z < 0;
    if ((which === 'back' && behind) || (which === 'front' && !behind)) {
      drawCelestialPoleLabel(sp, c.t, behind);
    }
  }
}

// Stick figure (observer) standing at the sphere center. setOrientationType
// ("absolute", normal (-1,0,0), up = zenith (0,0,1)) -> tilts/foreshortens
// with the local ground as view rotates.
function drawStick() {
  if (!imgStick.naturalWidth) return;
  const sc = 1.2;
  const w  = imgStick.naturalWidth  * sc;
  const h  = imgStick.naturalHeight * sc;
  const o  = absOrient(S, { x: 0, y: 0, z: 0 }, { x: -1, y: 0, z: 0 }, { x: 0, y: 0, z: 1 });
  skyCtx.save();
  skyCtx.translate(o.sp.x, o.sp.y);
  skyCtx.rotate(o.shellRot);
  skyCtx.scale(1, o.yscale);
  skyCtx.rotate(o.instRot);
  skyCtx.drawImage(imgStick, -w / 2, -h, w, h);   // feet at the origin
  skyCtx.restore();
}

let sunHover = false;

function drawSun()  {
  drawStarSprite( skyCtx, S, sun._p, imgSun, imgSun, false, {sp: sun._sp} );
}

function drawMoon()  {
  drawStarSprite( skyCtx, S, moon._p, imgMoon, imgMoon, false, {sp: moon._sp} );
}

function renderSky() {
  S.doA();
  S.doB();
  sun.update();
  moon.update();
  for (let i = 0; i < circles.length; i++) circles[i].update();
  for (let i = 0; i < lines.length;   i++) lines[i].update();

  skyCtx.clearRect(0, 0, SKY_STAGE, SKY_STAGE);
  skyCtx.save();
  skyCtx.translate(SKY_CX, SKY_CY);
  skyCtx.lineCap  = 'round';
  skyCtx.lineJoin = 'round';

  skyCtx.beginPath();
  skyCtx.arc(0, 0, S.c.r, 0, TWO_PI);
  skyCtx.fillStyle = 'rgba(250,250,252,0.9)';
  skyCtx.fill();

  const bandPaths = moonBand.visible ? moonBand.buildPaths() : null;

  // ---- back hemisphere ----
  if (bandPaths) fillBand(bandPaths.back, 0.22);
  drawCircleBucket(skyCtx, circles, 'back', { dim: 0.5, lineCap: 'round' });
  drawLineLayer(skyCtx, lines, 'bE');
  drawCelestialPoles('back');
  drawLineLayer(skyCtx, lines, 'bI');
  if (sun._sp.z  < 0) drawSun( sun._sp.x,  sun._sp.y,  false);
  if (moon._sp.z < 0) drawMoon(moon._sp.x, moon._sp.y, false);

  // ---- middle: horizon + NESW ----
  drawHorizonPlane();
//drawDirLabels();

  // Cardinal labels on horizon plane, split by screen depth so stick 
  // figure occludes labels behind it.
  drawCardinals(     'back');
  drawStick();                         // observer stands on the plane
  drawCardinals(     'front');

  // ---- front hemisphere ----
  if (bandPaths) fillBand(bandPaths.front, 0.5);
  drawCircleBucket(skyCtx, circles, 'front', { dim: 1, lineCap: 'round' });
  drawLineLayer(skyCtx, lines, 'aI');
  drawLineLayer(skyCtx, lines, 'fE');
  drawBowl();
  skyCtx.strokeStyle = 'rgba(120,120,120,0.55)';
  skyCtx.lineWidth   = 1;
  skyCtx.beginPath();
  skyCtx.arc(0, 0, S.c.r, 0, TWO_PI);
  skyCtx.stroke();
  if (sun._sp.z  >= 0) drawSun( sun._sp.x,  sun._sp.y,  true);
  if (moon._sp.z >= 0) drawMoon(moon._sp.x, moon._sp.y, true);
  drawCelestialPoles('front');

  skyCtx.restore();
}

/* =========================== PLOT RENDERING ============================= */
const PLOT_STAGE_W = 470, PLOT_STAGE_H = 320;
const PLOT_W       = 400, PLOT_H   = 275, MAX_DEC = 40;
const PLOT_LEFT    =  54, PLOT_TOP = 24;
const PLOT_VC      =   PLOT_TOP + PLOT_H / 2;
const yScale       = (-PLOT_H / 2) / MAX_DEC;
const xScale       =   PLOT_W / 365;
const DEC_TICKS    = [40, 30, 20, 10, 0, -10, -20, -30, -40];

// Place declination label at bottom-right corner inside plot frame
const pctX     = (x) => (x / PLOT_STAGE_W * 100).toFixed(2) + '%';
const pctY     = (y) => (y / PLOT_STAGE_H * 100).toFixed(2) + '%';
const decLabel = document.getElementById('dec-eqn');
new ResizeObserver(() => requestRender()).observe(decLabel);
decLabel.style.left    = pctX(PLOT_LEFT + 10);
decLabel.style.bottom  = pctY(PLOT_STAGE_H - (PLOT_TOP  + PLOT_H) + 10);
    
function fitPlot() {
  const dpr = window.devicePixelRatio || 1;
  plotCanvas.width  = PLOT_STAGE_W * dpr;
  plotCanvas.height = PLOT_STAGE_H * dpr;
  plotCtx.setTransform(dpr, 0, 0, dpr, 0, 0);
}

function renderPlot() {
  plotCtx.clearRect(0, 0, PLOT_STAGE_W, PLOT_STAGE_H);

  // Axes / frame
  plotCtx.strokeStyle = '#767676';
  plotCtx.lineWidth   = 1;
  plotCtx.strokeRect(PLOT_LEFT, PLOT_TOP, PLOT_W, PLOT_H);

  // ±7° shaded band around the curve
  plotCtx.beginPath();
  for (let d = 0; d <= 365; d++) {
    const y = PLOT_VC + (moonDecAt(d) + 7) * yScale;
    const x = PLOT_LEFT + d * xScale;
    if (d === 0) plotCtx.moveTo(x, y); else plotCtx.lineTo(x, y);
  }
  for (let d = 365; d >= 0; d--) {
    const y = PLOT_VC + (moonDecAt(d) - 7) * yScale;
    const x = PLOT_LEFT + d * xScale;
    plotCtx.lineTo(x, y);
  }
  plotCtx.closePath();
  plotCtx.fillStyle = hexToRGBA(COL_PLOT_BAND, 0.35);
  plotCtx.fill();

  // Dec = 0 line
  plotCtx.beginPath();
  plotCtx.moveTo(PLOT_LEFT, PLOT_VC);
  plotCtx.lineTo(PLOT_LEFT + PLOT_W, PLOT_VC);
  plotCtx.strokeStyle = '#999999';
  plotCtx.stroke();

  // Curve
  plotCtx.beginPath();
  for (let d = 0; d <= 365; d++) {
    const y = PLOT_VC + moonDecAt(d) * yScale;
    const x = PLOT_LEFT + d * xScale;
    if (d === 0) plotCtx.moveTo(x, y); else plotCtx.lineTo(x, y);
  }
  plotCtx.strokeStyle = COL_PLOT_CURVE;
  plotCtx.lineWidth   = 2;
  plotCtx.stroke();

  // Y ticks / labels
  plotCtx.fillStyle = '#333333';
  plotCtx.font      = '11px Verdana, Geneva, sans-serif';
  plotCtx.textAlign = 'right';
  plotCtx.textBaseline = 'middle';
  for (let i = 0; i < DEC_TICKS.length; i++) {
    const dec = DEC_TICKS[i];
    const y   = PLOT_VC + dec * yScale;
    plotCtx.beginPath();
    plotCtx.moveTo(PLOT_LEFT - 4, y);
    plotCtx.lineTo(PLOT_LEFT, y);
    plotCtx.strokeStyle = '#767676';
    plotCtx.lineWidth   = 1;
    plotCtx.stroke();
    plotCtx.fillText(String(dec) + '°', PLOT_LEFT - 6, y);
  }

  // Month labels
  plotCtx.textAlign    = 'center';
  plotCtx.textBaseline = 'top';
  for (let m = 0; m < 12; m++) {
    const d = (m + 0.5) / 12 * 365;
    const x = PLOT_LEFT + d * xScale;
    plotCtx.fillText(MONTHS_SHORT[m], x, PLOT_TOP + PLOT_H + 4);
  }

  // Cursor
  const cx = PLOT_LEFT + state.dayOfYear * xScale;
  const cy = PLOT_VC   + state.moonDec   * yScale;
  
  // Hide part of cursor line when it overlaps with equation
  const canvasRect = plotCanvas.getBoundingClientRect();
  const eqnRect    = decLabel.getBoundingClientRect();
  const sx         = PLOT_STAGE_W / canvasRect.width;
  const sy         = PLOT_STAGE_H / canvasRect.height;
  const pad        = 3;
  const eqnLeft    = (eqnRect.left   - canvasRect.left) * sx - pad;
  const eqnRight   = (eqnRect.right  - canvasRect.left) * sx + pad;
  const eqnTop     = (eqnRect.top    - canvasRect.top)  * sy - pad;
  const eqnBottom  = (eqnRect.bottom - canvasRect.top)  * sy + pad;

  plotCtx.beginPath();
  plotCtx.moveTo(cx, PLOT_TOP);
  if (cx < eqnLeft || eqnRight < cx || eqnRect.width === 0) {
    plotCtx.lineTo(cx, PLOT_TOP + PLOT_H);
  } else {
    plotCtx.lineTo(cx, Math.max(PLOT_TOP, eqnTop));
    plotCtx.moveTo(cx, Math.min(PLOT_TOP + PLOT_H, eqnBottom));
    plotCtx.lineTo(cx, PLOT_TOP + PLOT_H);
  }         
  plotCtx.strokeStyle = '#005a9c';
  plotCtx.lineWidth   = 1.5;
  plotCtx.stroke();
  plotCtx.beginPath();
  plotCtx.arc(cx, cy, 5, 0, TWO_PI);
  plotCtx.fillStyle = '#005a9c';
  plotCtx.fill();
}

let renderQueued = false;
function requestRender() {
  if (renderQueued) return;
  renderQueued = true;
  requestAnimationFrame(() => {
    renderQueued = false;
    renderSky();
    renderPlot();
    updateURL();
  });
}

/* =========================== MathJax readout ============================ */
function syncReadouts() {
  const sign = state.moonDec >= 0 ? '+' : '';
  if (typeof klunlShowEquation === 'function') {
    if ( !urlClean )  { 
      klunlShowEquation(
        ['dec-eqn',
         '$\\delta = ' + sign + legToFixed(state.moonDec, 0) +
         '^{\\circ}$'],
        ['dec-eqn-sr',
         'Full moon declination ' + speak(state.moonDec, 0, 'degree') +
         ' on day ' + legToFixed(state.dayOfYear, 0) + ' of the year.']
      );
    } else  {
      const hemi = S.getLatitude() < 0 ? 'south' : 'north';
      klunlShowEquation(
        ['dec-eqn',
         '$\\text{lat} = ' + legToFixed(S.getLatitude(), 0) + '^{\\circ}$'],
        ['dec-eqn-sr',
         'Full moon declination ' + speak(state.moonDec, 0, 'degree') +
         ' on day ' + legToFixed(state.dayOfYear, 0) + ' of the year.']
      );
    }
  }
}

window.klunlInitEqn = function () {
  syncReadouts();
};

/* =========================== URL state ================================== */
function updateURL() {
  const theta = Math.round(R2D * S.theta);
  const phi   = Math.round(R2D * S.phi);
  const day   = Math.round(doyDual.getValue());

  let s0 = 'Full-Moon-Declination-Demonstrator/index.html';
  s0 += '?theta=' + theta + '&phi=' + phi;
  s0 += '&day='   + day;

  window.stateURL = s0;
}

function applyURL() {
  document.getElementById('canvas-more-keys').style.display = 'none';

  const urlParams = Object.fromEntries(new URLSearchParams(window.location.search));
  if (Object.keys(urlParams).length === 0) return;

  let URL_THT, URL_PHI, URL_DAY;

  if ((urlParams.theta !== undefined) && (!Number.isNaN(Number(urlParams.theta)))) {
    URL_THT = Math.round(pMod(Number(urlParams.theta), 360));
  } else { URL_THT = INIT_THETA; }

  if ((urlParams.phi !== undefined) && (!Number.isNaN(Number(urlParams.phi)))) {
    URL_PHI = Math.round(clamp(Number(urlParams.phi), MIN_PHI, 90));
  } else { URL_PHI = INIT_PHI; }

  if ((urlParams.day !== undefined) && (!Number.isNaN(Number(urlParams.day)))) {
    URL_DAY = Math.round(clamp(Number(urlParams.day), 1, 365));
  } else { URL_DAY = INIT_DAY; }

  S.setThetaAndPhi(URL_THT, URL_PHI);
  doyDual.setValue(URL_DAY);
  setDayOfYear(URL_DAY);

  let clean = false;
  try {
    clean = (urlParams.clean !== undefined) && (JSON.parse(urlParams.clean) == true);
  } catch (e) { /* ignore */ }

  if (clean) {
    urlClean = true;
    document.getElementById('canvas-more-keys').style.display = 'block';
    document.getElementById('day-panel').style.display        = 'none';
    document.querySelectorAll('.app-layout').forEach((el) => {
      el.style.display        = 'flex';
      el.style.justifyContent = 'center';
    });

    document.getElementById('plot-canvas-help').textContent =
      'Drag or use the arrow keys to change the day of year, and R to reset. ' + VO_FIX_LGND;
    document.getElementById('sky-canvas-help').textContent =
      'Drag or use the arrow keys to rotate the view. ' +
      'Use minus and plus to increment the latitude, and R to reset. ' + VO_FIX_LGND;

    const oldSkipLink = document.querySelector('.sr-only-focusable');
    if (oldSkipLink) {
      const newSkipLink       = oldSkipLink.cloneNode(true);
      newSkipLink.textContent = 'Skip to Keyboard Navigation';
      newSkipLink.setAttribute('href', '#canvas-more-keys');
      newSkipLink.addEventListener('click', (e) => {
        e.preventDefault();
        const gearBtn = document.getElementById('canvas-more-keys');
        if (gearBtn) gearBtn.focus();
      });
      oldSkipLink.parentNode.replaceChild(newSkipLink, oldSkipLink);
    }
  }
}

function reset() {
  S.setThetaAndPhi(INIT_THETA, INIT_PHI);
  doyDual.setValue(INIT_DAY);
  setDayOfYear(INIT_DAY);
  applyURL();
  requestRender();
  refreshCanvasNames();
  announceLive(srStatus,
    'View reset. Day ' + speak(state.dayOfYear, 0) + ' (' + monthName(state.dayOfYear) +
    '). Full Moon declination ' + speak(state.moonDec, 0, 'degree') + '. ' + 
    + moonAltitudeMeaning() );
}

/* =========================== Interaction ================================ */
function plotToDoy(ev) {
  const rect = plotCanvas.getBoundingClientRect();
  const x    = (ev.clientX - rect.left) / rect.width * PLOT_STAGE_W;
  return 365 * (x - PLOT_LEFT) / PLOT_W;
}

let plotDragging = false;
plotCanvas.addEventListener('pointerdown', (ev) => {
  plotCanvas.setPointerCapture(ev.pointerId);
  plotCanvas.focus();
  plotDragging = true;
  commitDoy(plotToDoy(ev), false);
  ev.preventDefault();
});
plotCanvas.addEventListener('pointermove', (ev) => {
  if (!plotDragging) return;
  commitDoy(plotToDoy(ev), false);
  ev.preventDefault();
});
function endPlotDrag() {
  if (!plotDragging) return;
  plotDragging = false;
  dayAnnounce(false);
}
plotCanvas.addEventListener('pointerup',     endPlotDrag);
plotCanvas.addEventListener('pointercancel', endPlotDrag);

function handleCleanKeys(ev) {
  if (!urlClean) return false;
  switch (ev.key) {
    case 'r': case 'R':
      ev.preventDefault();
      reset();
      return true;
    case '-': case '_':
      ev.preventDefault();
    commitLatitude( S.getLatitude() - keyAccel(ev, 1), true );
      syncReadouts();
      return true;
    case '+': case '=':
      ev.preventDefault();
      commitLatitude( S.getLatitude() + keyAccel(ev, 1), true );
      syncReadouts();
      return true;
    default:
      return false;
  }
}

plotCanvas.addEventListener('keydown', (ev) => {
  if (handleCleanKeys(ev)) return;
  let   d    = state.dayOfYear, used = true;
  const step = keyAccel(ev, DOY_STEP);
  const held = ev.repeat;
  switch (ev.key) {
    case 'ArrowLeft':  case 'a': case 'A':
    case 'ArrowDown':  case 's': case 'S': d -= step; break;
    case 'ArrowRight': case 'd': case 'D':
    case 'ArrowUp':    case 'w': case 'W': d += step; break;
    case 'Home':     d = 1;   break;
    case 'End':      d = 365; break;
    case 'PageUp':   d += 30; break;
    case 'PageDown': d -= 30; break;
    default: used = false;
  }
  if (used) {
    commitDoy(d, true, held);
    ev.preventDefault();
  }
});

function skyToStage(ev) {
  const rect = skyCanvas.getBoundingClientRect();
  const sx = rect.width  ? SKY_STAGE / rect.width  : 1;
  const sy = rect.height ? SKY_STAGE / rect.height : 1;
  return {
    x: (ev.clientX - rect.left) * sx - SKY_CX,
    y: (ev.clientY - rect.top)  * sy - SKY_CY
  };
}

let skyDrag = null;
skyCanvas.addEventListener('pointerdown', (ev) => {
  skyCanvas.setPointerCapture(ev.pointerId);
  skyCanvas.focus();
  const m = skyToStage(ev);
  skyDrag = { x: m.x, y: m.y, theta: S.theta, phi: S.phi };
  ev.preventDefault();
});
skyCanvas.addEventListener('pointermove', (ev) => {
  const m = skyToStage(ev);
  if (!skyDrag) {
    const d = Math.hypot(m.x - sun._sp.x, m.y - sun._sp.y);
    const h = (sun._sp.z >= 0 && d <= 12);
    if (h !== sunHover) { sunHover = h; requestRender(); }
    return;
  }
  S.setThetaAndPhi(
    R2D * (skyDrag.theta - (m.x - skyDrag.x) / S.c.r),
    R2D * (skyDrag.phi   + (m.y - skyDrag.y) / S.c.r)
  );
  requestRender();
  ev.preventDefault();
});
function endSkyDrag() {
  if (!skyDrag) return;
  skyDrag = null;
  viewAnnounce(false);
}
skyCanvas.addEventListener('pointerup',     endSkyDrag);
skyCanvas.addEventListener('pointercancel', endSkyDrag);

skyCanvas.addEventListener('keydown', (ev) => {
  if (handleCleanKeys(ev)) return;
  const step = keyAccel(ev, VIEW_STEP);
  const held = ev.repeat;
  let t = S.getTheta(), p = S.getPhi(), used = true;
  switch (ev.key) {
    case 'ArrowLeft':  case 'a': case 'A': t += step; break;
    case 'ArrowRight': case 'd': case 'D': t -= step; break;
    case 'ArrowUp':    case 'w': case 'W': p -= step; break;
    case 'ArrowDown':  case 's': case 'S': p += step; break;
    default: used = false;
  }
  if (used) {
    S.setThetaAndPhi(t, p);
    requestRender();
    viewAnnounce(held);
    ev.preventDefault();
  }
});

document.getElementById('canvas-more-keys').addEventListener('click',
  () => descMoreKeys(urlClean));
document.getElementById('closeKeyNavBtn').addEventListener('click',
  () => hideMoreKeys());

document.addEventListener('sim-reset', reset);

/* =========================== STARTUP ==================================== */
window.addEventListener('resize', () => {
  fitSky();
  fitPlot();
  requestRender();
});
document.addEventListener('visibilitychange', () => {
  if (!document.hidden) requestRender();
});

fitSky();
fitPlot();
reset();
renderSky();
renderPlot();
updateURL();
refreshCanvasNames();
announceLive(srStatus,
    'Day ' + speak(state.dayOfYear, 0) + ' (' + monthName(state.dayOfYear) +
    '). Full Moon declination ' + speak(state.moonDec, 0, 'degree') + '. ' + 
    + moonAltitudeMeaning() );
