/* ==========================================================================
   Sun Motions Overview — HTML5 port of sunmotionsoverview.swf (Flash / AS1)

   Projection engine: foundation/js/kl-unl-celestial-sphere.js
   Behavior parity: decompiled DefineSprite_105 + CS Geometry / Circles / Lines
   / Objects / Mouse / Horizon Plane / Shading.
   ========================================================================== */

import {
  CelestialSphere, Circle, Line,
  CELESTIAL_SPHERE_COLORS,
  R2D, TWO_PI,
  drawLineLayer, drawCircleBucket,
  absOrient,
  DEC_TEXT_FONT, DEC_TEXT_GAP,
  layoutDeclinationText, drawDeclinationLetters
} from '../foundation/js/kl-unl-celestial-sphere.js';

import {
  legToFixed, speak, noEinNumber, keyAccel,
  updateSliderProgress, announceLive, VO_FIX_LGND, logAct
} from '../foundation/js/kl-unl-utils.js';

logAct('INIT_sunmotionsoverview');

/* ---- constants (Flash parity) ------------------------------------------ */

const CSC = CELESTIAL_SPHERE_COLORS;

const SPHERE_SIZE = 250;                 // Flash sphereMC.size → r = 125
const MASK_R      = 100;
const MASK_D      = 120;
const MASK_HALF_N =   4;

const INIT_VIEWER_AZIMUTH  = 200;
const INIT_VIEWER_ALTITUDE =  40;
const INIT_LATITUDE        =  41;
let   xLat                 = INIT_LATITUDE;

const COLOR_POLE_AXIS = CSC.POLE_MRK3;   // #75a9ff (light  blue)
const COLOR_CELESTIAL = CSC.CEL_EQUTR2;  // #ffe375 (bright yellow)
const COLOR_SUN_PATH  = '#ff0000';       // red
const COLOR_MERIDIAN  = CSC.MRDN4_CIRC;  // #ffffff (white)
const COLOR_UNDRNETH  = '#999999';       // medium grey

const DEC_SUMMER_SOLSTICE =  23.5;
const DEC_WINTER_SOLSTICE = -23.5;

const STAGE_W  = 420;
const STAGE_H  = 420;
const STAGE_CX = 210;
const STAGE_CY = 210;

const LETTER_COLOR = CSC.LABEL_HALO;  // white

const LAT_PRECISION = 0;
const LAT_STEP      = 1;
const LAT_PAGE      = 5;
const VIEW_STEP     = 1;

/* ---- sphere + checkbox flags ------------------------------------------- */

const S = new CelestialSphere();
S.setSize(SPHERE_SIZE);
S.setMinPhi(-90);
S.setMaxPhi(90);
S.setViewerAzimuth(INIT_VIEWER_AZIMUTH);
S.setPhi(INIT_VIEWER_ALTITUDE);
S.setLatitude(INIT_LATITUDE);
S.setSiderealTime(0);

const flags = {
  showPoles:    false,
  showCE:       false,
  showEquinox:  false,
  showSolstice: false
};

function sphereR() { return S.c.r; }

const CARDINAL_R = 0.88;
const CARDINALS  = [
  { t: 'N', az:   0 },
  { t: 'E', az:  90 },
  { t: 'S', az: 180 },
  { t: 'W', az: 270 }
];

/* ---- scene assembly ---------------------------------------------------- */

const scene = {
  circles:    [],
  lines:      [],
  decLetters: []   // { ch, ra, dec, color } — Flash-style curved captions
};

let activeLabels = [];

function makeCircle(style, def) {
  return new Circle(S, style, def);
}

function makeLine(style, head, tail) {
  return new Line(S, style, head, tail);
}

function buildScene() {
  scene.circles.length    = 0;
  scene.lines.length      = 0;
  scene.decLetters.length = 0;
  activeLabels            = [];

  scene.circles.push({
    key: 'meridian1',
    circle: makeCircle(
      { thickness: 2, color: COLOR_MERIDIAN, alpha: 0.40 },
      { ra: 0, dec: 0, tilt: 90 })
  });
  scene.circles.push({
    key: 'meridian2',
    circle: makeCircle(
      { thickness: 2, color: COLOR_MERIDIAN, alpha: 0.40 },
      { ra: 6, dec: 0, tilt: 90 })
  });
  scene.circles.push({
    key: 'edge',
    circle: makeCircle(
      { thickness: 2, color: COLOR_MERIDIAN, alpha: 0.40 },
      { az: 0, alt: 0, tilt: 0 })
  });

  if (flags.showPoles) {
    scene.lines.push({
      key: 'ncpAxis',
      line: makeLine(
        { thickness: 3, color: COLOR_POLE_AXIS, alpha: 1 },
        { x: 0, y: 0, z: 0,   system: 'celestial' },
        { x: 0, y: 0, z: 1.2, system: 'celestial' })
    });
    scene.lines.push({
      key: 'scpAxis',
      line: makeLine(
        { thickness: 3, color: COLOR_POLE_AXIS, alpha: 1 },
        { x: 0, y: 0, z: 0,    system: 'celestial' },
        { x: 0, y: 0, z: -1.2, system: 'celestial' })
    });
    // Two copies each (RA 0h and 12h)
    pushDecText('NCP',  0,  85, LETTER_COLOR, false);
    pushDecText('NCP', 12,  85, LETTER_COLOR, false);
    pushDecText('SCP',  0, -85, LETTER_COLOR, false);
    pushDecText('SCP', 12, -85, LETTER_COLOR, false);
  }

  if (flags.showCE) {
    scene.circles.push({
      key: 'celestialEquator',
      circle: makeCircle(
        { thickness: 3, color: COLOR_CELESTIAL, alpha: 1 },
        { ra: 0, dec: 0, tilt: 0 })
    });
  }

  if (flags.showEquinox) {
    scene.circles.push({
      key: 'equinoxPath',
      circle: makeCircle(
        { thickness: 3, color: COLOR_SUN_PATH, alpha: 1 },
        { ra: 0, dec: 0, tilt: 0 })
    });
  }

  // Equinox caption wins over CE when both are on.
  if (flags.showEquinox) {
    pushDecText('Equinox Path',      0, 0.7, LETTER_COLOR, false);
  } else if (flags.showCE) {
    pushDecText('Celestial Equator', 0, 0.7, LETTER_COLOR, false);
  }

  if (flags.showSolstice) {
    scene.circles.push({
      key: 'sSolsticePath',
      circle: makeCircle(
        { thickness: 3, color: COLOR_SUN_PATH, alpha: 1 },
        { ra: 0, dec: DEC_SUMMER_SOLSTICE, tilt: 0 })
    });
    scene.circles.push({
      key: 'wSolsticePath',
      circle: makeCircle(
        { thickness: 3, color: COLOR_SUN_PATH, alpha: 1 },
        { ra: 0, dec: DEC_WINTER_SOLSTICE, tilt: 0 })
    });
    // Swap winter and summer solstice labels for northern and southern latitudes
    if ( S.getLatitude() >= 0 )  { 
      pushDecText('Summer Solstice Path', 0, DEC_SUMMER_SOLSTICE, LETTER_COLOR, false);
      pushDecText('Winter Solstice Path', 0, DEC_WINTER_SOLSTICE, LETTER_COLOR, false);
    } else  { 
      pushDecText('Winter Solstice Path', 0, DEC_SUMMER_SOLSTICE, LETTER_COLOR, false);
      pushDecText('Summer Solstice Path', 0, DEC_WINTER_SOLSTICE, LETTER_COLOR, false);
    }
  }
  // Swap winter and summer solstice declination labels for northern and southern latitudes
  if ( S.getLatitude() >= 0 )  { 
    document.getElementById('smrSol').innerHTML = 'summer solstice';
    document.getElementById('wntSol').innerHTML = 'winter solstice';
  } else  { 
    document.getElementById('smrSol').innerHTML = 'winter solstice';
    document.getElementById('wntSol').innerHTML = 'summer solstice';
  }
}

function pushDecText(str, ra, dec, color, reverseRa) {
  const laid = layoutDeclinationText(str, ra, dec, {
    sphereSize: SPHERE_SIZE,
    gap:        DEC_TEXT_GAP,
    reverseRa:  !!reverseRa,
    font:       DEC_TEXT_FONT
  });
  for (let i = 0; i < laid.length; i++) {
    scene.decLetters.push({
      ch:    laid[i].ch,
      ra:    laid[i].ra,
      dec:   laid[i].dec,
      color: color
    });
  }
  if (activeLabels.indexOf(str) === -1) activeLabels.push(str);
}

/* ---- artwork (images/) ------------------------------------------------- */

const ART = {
  aboveHorizon:   { src: 'images/23.svg',    w: 199.95, h: 200,    ox:  99.95, oy: 100    },
  belowHorizon:   { src: 'images/21.svg',    w: 199.95, h: 200,    ox:  99.95, oy: 100    },
  sphereOutside:  { src: 'images/67.svg',    w: 200,    h: 200,    ox: 100,    oy: 100    },
  sphereOutside2: { src: 'images/65.svg',    w: 200,    h: 200,    ox: 100,    oy: 100    },
//stickman:       { src: 'images/59.svg',    w:   9.2,  h:  21.65, ox:   4.6,  oy:  20.65 }
  stickman:       { src: 'images/fox02.png', w:  34.5,  h:  50,    ox:  17.25, oy:  42.5  }
};

let artReady = false;

function loadArt() {
  const keys  = Object.keys(ART);
  let pending = keys.length;
  return new Promise((resolve) => {
    keys.forEach((k) => {
      const img    = new Image();
      img.decoding = 'sync';
      img.onload   = img.onerror = () => {
        ART[k].img = img;
        if (--pending === 0) { artReady = true; resolve(); }
      };
      img.src = ART[k].src;
    });
  });
}

function drawArt(ctx, spec) {
  if (!spec.img || !spec.img.complete || !spec.img.naturalWidth) return;
  ctx.drawImage(spec.img, -spec.ox, -spec.oy, spec.w, spec.h);
}

function clipMaskM2(ctx) {
  const scale    = sphereR() / 100;          // _M2._xscale = _M2._yscale = _c.r
  const r        = MASK_R,
        d        = MASK_D;
  const step     = Math.PI / MASK_HALF_N;
  const halfStep = step / 2;
  const cRad     = r / Math.cos(halfStep);
  const s        =     Math.sin(S.phi);

  ctx.save();
  ctx.scale(scale, scale);
  ctx.beginPath();
  ctx.moveTo(d, d);
  ctx.lineTo(d, 0);
  ctx.lineTo(r, 0);
  let aAngle = step, cAngle = aAngle - halfStep;
  for (let i = 0; i < MASK_HALF_N; i++) {
    ctx.quadraticCurveTo(
      cRad * Math.cos(cAngle), s * cRad * Math.sin(cAngle),
      r    * Math.cos(aAngle), s * r    * Math.sin(aAngle)
    );
    aAngle += step;
    cAngle += step;
  }
  ctx.lineTo(-d, 0);
  ctx.lineTo(-d, d);
  ctx.lineTo( d, d);
  ctx.closePath();
  ctx.restore();
  ctx.clip();
}

/* ---- canvas / paint ---------------------------------------------------- */

const canvas   = document.getElementById('sim-canvas');
const ctx      = canvas.getContext('2d');
let stageScale = 1;

function sizeCanvas() {
  const dpr  = window.devicePixelRatio || 1;
  const cssW = canvas.clientWidth      || STAGE_W;
  const cssH = canvas.clientHeight     || STAGE_H;
  stageScale = Math.min(cssW / STAGE_W, cssH / STAGE_H);
  const bw   = Math.round(STAGE_W * stageScale * dpr);
  const bh   = Math.round(STAGE_H * stageScale * dpr);
  if (canvas.width !== bw || canvas.height !== bh) {
    canvas.width  = bw;
    canvas.height = bh;
  }
}

function applyStageTransform() {
  const dpr = window.devicePixelRatio || 1;
  const k   = stageScale * dpr;
  ctx.setTransform(k, 0, 0, k, STAGE_CX * k, STAGE_CY * k);
}

/** Stick figure facing south; hidden when viewing from below the horizon. */
function paintStick(ctx2) {
  if (S.phi < 0) return;
  const spec = ART.stickman;
  if (!spec.img || !spec.img.complete || !spec.img.naturalWidth) return;
  const o = absOrient(
    S,
    { x: 0, y: 0, z: 0 },
    { x: -1, y: 0, z: 0 },   // normal = south
    { x:  0, y: 0, z: 1 }    // up = zenith
  );
  ctx2.save();
  ctx2.translate(o.sp.x, o.sp.y);
  ctx2.rotate(o.shellRot);
  ctx2.scale(1, o.yscale === 0 ? 1e-6 : o.yscale);
  ctx2.rotate(o.instRot);
  drawArt(ctx2, spec);
  ctx2.restore();
}

/** NESW letters inlaid on the horizon plane (visible above and below). */
function paintCardinalLabel(ctx2, az, text, fillColor) {
  const p = {};
  S.parsePointInput({ az, alt: 0, r: CARDINAL_R }, p);
  const n = { x: 0, y: 0, z: 1 };
  const u = { x: 1, y: 0, z: 0 };
  const o = absOrient(S, p, n, u);
  ctx2.save();
  ctx2.translate(o.sp.x, o.sp.y);
  ctx2.rotate(o.shellRot);
  ctx2.scale(1, o.yscale === 0 ? 1e-6 : o.yscale);
  ctx2.rotate(o.instRot);
  ctx2.lineJoin     = 'round';
  ctx2.miterLimit   = 2;
  ctx2.font         = '600 14px Verdana, "DejaVu Sans", Geneva, sans-serif';
  ctx2.textAlign    = 'center';
  ctx2.textBaseline = 'middle';
  ctx2.lineWidth    = 3;
  ctx2.strokeStyle  = CSC.NESW_LINE;
  ctx2.fillStyle    = fillColor;
  ctx2.strokeText(text, 0, 0);
  ctx2.fillText(text, 0, 0);
  ctx2.restore();
}

function paintCardinals(ctx2, which) {
  // Dim when viewing from below the horizon (Celhor below-frame style).
  const fillColor = (S.phi < 0) ? COLOR_UNDRNETH : CSC.NESW_FILL;
  for (const c of CARDINALS) {
    const p = {}, sp = {};
    S.parsePointInput({ az: c.az, alt: 0, r: CARDINAL_R }, p);
    S.WtoSz(p, sp);
    const isBack = sp.z < 0;
    if ((which === 'back' && isBack) || (which === 'front' && !isBack)) {
      paintCardinalLabel(ctx2, c.az, c.t, fillColor);
    }
  }
}

/** Green horizon disk only (NESW painted separately via absOrient). */
function paintHorizonPlane(ctx2) {
  const r  = sphereR();
  const sx = r / 100;
  const sy = (r * Math.sin(S.phi)) / 100;
  if (sy === 0) return;

  const above = S.phi > 0;
  const A     = Math.PI + S.theta;

  ctx2.save();
  ctx2.scale(sx, sy);
  ctx2.rotate(A);
  drawArt(ctx2, above ? ART.aboveHorizon : ART.belowHorizon);
  ctx2.restore();
}

function paintCelestialBowl(ctx2) {
  const scale = sphereR() / 100;
  ctx2.save();
  ctx2.scale(scale, scale);
  const g = ctx2.createRadialGradient(0, 0, 0, 0, 0, 100);
  g.addColorStop(0, 'rgba(255,255,255,0)');
  g.addColorStop(1, 'rgba(0,0,0,0.2)');
  ctx2.fillStyle = g;
  ctx2.beginPath();
  ctx2.arc(0, 0, 100, 0, TWO_PI);
  ctx2.fill();
  ctx2.restore();
}

function paintShadingScaled(ctx2, spec) {
  const scale = sphereR() / 100;
  ctx2.save();
  ctx2.scale(scale, scale);
  drawArt(ctx2, spec);
  ctx2.restore();
}

function render() {
  sizeCanvas();

  const circles = scene.circles.map((e) => e.circle);
  const lines   = scene.lines.map((e)   => e.line);
  for (let i = 0; i < circles.length; i++) circles[i].update();
  for (let i = 0; i < lines.length;   i++) lines[i].update();

  ctx.setTransform(1, 0, 0, 1, 0, 0);
  ctx.clearRect(0, 0, canvas.width, canvas.height);
  applyStageTransform();
  ctx.lineCap = 'round';

  const innerFirst  = (S.phi < 0) ? 'aI' : 'bI';
  const innerSecond = (S.phi < 0) ? 'bI' : 'aI';

  // Flash depth order with AzAlt-style cardinals around the stick
  drawLineLayer(     ctx, lines, 'bE');
  drawCircleBucket(  ctx, circles, 'back', { dim: 1, lineCap: 'round' });
  drawDeclinationLetters(ctx, S, scene.decLetters, 'back',  { font: DEC_TEXT_FONT });
  drawLineLayer(     ctx, lines, innerFirst);
  paintHorizonPlane( ctx);
  paintCardinals(    ctx, 'back');
  paintStick(        ctx);
  paintCardinals(    ctx, 'front');
  drawLineLayer(     ctx, lines, innerSecond);

  paintCelestialBowl(ctx);
  paintShadingScaled(ctx, ART.sphereOutside);
  drawCircleBucket(  ctx, circles, 'front', { dim: 1, lineCap: 'round' });
  drawDeclinationLetters(ctx, S, scene.decLetters, 'front', { font: DEC_TEXT_FONT });

  ctx.save();
  clipMaskM2(ctx);
  paintShadingScaled(ctx, ART.sphereOutside2);
  ctx.restore();

  drawLineLayer(ctx, lines, 'fE');

  syncDom();
}

/* ---- DOM / a11y -------------------------------------------------------- */

const el = {
  latSlider:    document.getElementById('latitude-slider'),
  latNumber:    document.getElementById('latitude-number'),
  viewProxy:    document.getElementById('sphere-view'),
  status:       document.getElementById('sim-status'),
  canvasDesc:   document.getElementById('canvas-description'),
  step1:        document.getElementById('step-1'),
  step2:        document.getElementById('step-2'),
  step3:        document.getElementById('step-3'),
  step4:        document.getElementById('step-4')
};

function latHemisphere(v) { return v < 0 ? '° S' : '° N'; }
function latText(v)       { return legToFixed(Math.abs(v), LAT_PRECISION) + latHemisphere(v); }

function latSpoken(v) {
  const hemi = v < 0 ? 'south' : 'north';
  return 'Latitude ' + speak(Math.abs(v), LAT_PRECISION, 'degree') + ' ' + hemi;
}

function klunlInitEqn() {}
window.klunlInitEqn = klunlInitEqn;

function setLatitude(deg) {
  const k = Math.pow(10, LAT_PRECISION);
  let   v = Math.round(k * deg) / k;
  if      (v < -90) v = -90;
  else if (v >  90) v =  90;
  S.setLatitude(v);
  buildScene();
  render();
}

function setThetaAndPhi(thetaDeg, phiDeg) {
  S.setThetaAndPhi(thetaDeg, phiDeg);
  render();
}

function syncDom() {
  const v = S.getLatitude();
  if (document.activeElement !== el.latSlider) el.latSlider.value = String(v);
  if (document.activeElement !== el.latNumber) {
    el.latNumber.value = legToFixed(v, LAT_PRECISION);
  }
  el.latSlider.setAttribute('aria-valuetext', latSpoken(v));
  el.latNumber.setAttribute('aria-label',     latSpoken(v));
  updateSliderProgress(el.latSlider);

  el.step1.checked = flags.showPoles;
  el.step2.checked = flags.showCE;
  el.step3.checked = flags.showEquinox;
  el.step4.checked = flags.showSolstice;

  el.canvasDesc.textContent = describeScene();
}

function describeScene() {
  const v     = S.getLatitude();
  const parts = [];
  parts.push('Celestial sphere seen from ' +
             speak( Math.abs(v), LAT_PRECISION, 'degree' ) + 
             (v < 0 ? ' south' : ' north') + ' latitude, ' +
             'looking toward azimuth ' + speak( S.getViewerAzimuth(), 0, 'degree' ) +
        ' from a viewing altitude of ' + speak(S.getPhi(),            0, 'degree' ) +
             '. ');
  parts.push('An observer is at the center of the green horizon plane, ' +
             'with north, east, south, and west marked around its border. ');

  const sayWhere = [];
  const v2       = Math.abs( v );
  let   v3       = ( v >= 0 ) ? 'northern' : 'southern';
  let   v4       = ( v >= 0 ) ? 'southern' : 'northern';
  if (flags.showPoles)  {
    if      ( v  >=   0 )  { sayWhere[0]   = 'The North Celestial Pole is ';      }
    else                   { sayWhere[0]   = 'The South Celestial Pole is ';      }
    if      ( v2 ==  90 )  { sayWhere[0]  += 'directly overhead ';                }
    else if ( v2 >=  80 )  { sayWhere[0]  += 'almost directly overhead';          }
    else if ( v2 >=  45 )  { sayWhere[0]  += 'high in the '    + v3 + ' sky';     }
    else if ( v2 >=  10 )  { sayWhere[0]  += 'visible in the ' + v3 + ' sky';     }
    else if ( v2 >    0 )  { sayWhere[0]  += 'above the '      + v3 + ' horizon'; }
    else if ( v2 ==   0 )  { sayWhere[0]  += 'on the northern horizon ' +
      'and the South Celestial Pole is on the southern horizon'; }
    sayWhere[0] += ' for the observer. ';
  }
  if (flags.showCE || flags.showEquinox)  {
    if (!flags.showEquinox)  { sayWhere[1]   = 'The celestial equator ';            }
    else                     { sayWhere[1]   = 'The Sun\'s path on the equinoxes '; }
    if      ( v2 ==  90 )    { sayWhere[1]  += 'is on the horizon'; }
    else if ( v2 >=  80 )    { sayWhere[1]  += 'is on the '                          + v4 + ' horizon'; }
    else if ( v2 >=  45 )    { sayWhere[1]  += 'stretches across the sky above the ' + v4 + ' horizon'; }
    else if ( v2 >=  10 )    { sayWhere[1]  += 'is high in the '                     + v4 + ' sky';     }
    else                     { sayWhere[1]  += 'spans the observer\'s sky from east to west.'; }
    if (v2 >= 10)  { 
      if (!flags.showPoles)  { sayWhere[1] += ' for the observer'; }
      sayWhere[1] += '. ';
    }
  }
  if (flags.showSolstice)  {
    sayWhere[2] = ' On the summer solstice '; 
    if      ( v2 >= 66.5 )  { sayWhere[2] += 'the Sun never sets below the horizon';      }
    else if ( v2 >  33.5 )  { sayWhere[2] += 'the Sun stays mostly above the horizon, transiting high in the ' + v4 + ' sky'; }
    else if ( v2 >  23.5 )  { sayWhere[2] += 'the Sun transits almost directly overhead'; }
    else if ( v2 == 23.5 )  { sayWhere[2] += 'the Sun transits directly overhead';        }
    else if ( v2 >  13.5 )  { sayWhere[2] += 'the Sun transits almost directly overhead'; }
    else if ( v2 >   0   )  { sayWhere[2] += 'the day is barely longer than twelve hours'; }
    else if ( v2 ==  0   )  { sayWhere[2] += 'the day is twelve hours long';      }
    if (!flags.showPoles && !flags.showCE && !flags.showEquinox)  { sayWhere[2] += ' for the observer. '; }
    else  { sayWhere[2] += '. '; }
  
    sayWhere[2] += 'On the winter solstice '; 
    if      ( v2 >= 66.5 )  { sayWhere[2] += 'the Sun never rises above the horizon';     }
    else if ( v2 >  43.5 )  { sayWhere[2] += 'the Sun stays mostly below the horizon, transiting low in the ' + v4 + ' sky'; }
    else if ( v2 >  13.5 )  { sayWhere[2] += 'the day is shorter than twelve hours'; }
    else if ( v2 >   0   )  { sayWhere[2] += 'the day is barely shorter than twelve hours'; }
    else if ( v2 ==  0   )  { sayWhere[2] += 'the day is twelve hours long';      }
    sayWhere[2] += '. ';
  }

  const shown = [];
  if (flags.showPoles) {
    shown.push('the axis through the North and South Celestial Poles, ' +
               'labelled N C P and S C P');
  }
  if (flags.showCE && !flags.showEquinox) shown.push('the celestial equator');
  if (flags.showEquinox) {
    shown.push('the Sun\'s path on the autumnal and spring equinoxes, ' +
               'at declination 0 degrees');
  }
  if (flags.showSolstice) {
    if ( el.latSlider.value >= 0 )  { 
    shown.push('the Sun\'s paths on the summer and winter solstices, ' +
               'at declinations plus and minus ' +
               speak(DEC_SUMMER_SOLSTICE, 1, 'degree' ) );
    } else  {
    shown.push('the Sun\'s paths on the winter and summer solstices, ' +
               'at declinations plus and minus ' +
               speak(DEC_SUMMER_SOLSTICE, 1, 'degree' ) );
    }
  }
  parts.push(shown.length
    ? 'Also shown: ' + shown.join('; ') + '. ' + sayWhere.join('')
             : 'No Sun paths currently shown. Click through the steps to build up the picture.');

  return parts.join(' ');
}

function announce(msg) {
  announceLive(el.status, msg);
}

/* ---- pointer drag ------------------------------------------------------ */

let drag = null;

function pointerToStage(evt) {
  const rect  = canvas.getBoundingClientRect();
  const scale = rect.width / STAGE_W;
  return {
    x: (evt.clientX - rect.left) / scale - STAGE_CX,
    y: (evt.clientY - rect.top)  / scale - STAGE_CY
  };
}

canvas.addEventListener('pointerdown', (evt) => {
  const p = pointerToStage(evt);
  drag = {
    id:     evt.pointerId,
    xMouse: p.x,
    yMouse: p.y,
    theta:  S.theta,
    phi:    S.phi
  };
  try { canvas.setPointerCapture(evt.pointerId); } catch (_e) { /* ok */ }
  el.viewProxy.focus({ preventScroll: true });
  evt.preventDefault();
});

canvas.addEventListener('pointermove', (evt) => {
  if (!drag || evt.pointerId !== drag.id) return;
  const p = pointerToStage(evt);
  const r = sphereR();
  setThetaAndPhi(
    R2D * (drag.theta - (p.x - drag.xMouse) / r),
    R2D * (drag.phi   + (p.y - drag.yMouse) / r)
  );
  evt.preventDefault();
});

function endDrag(evt) {
  if (!drag || (evt && evt.pointerId !== drag.id)) return;
  drag = null;
  announce('Viewing direction: azimuth ' + speak(S.getViewerAzimuth(), 0, 'degree') +
                   ', viewing altitude ' + speak(S.getPhi(),           0, 'degree') + '.');
}
canvas.addEventListener('pointerup',     endDrag);
canvas.addEventListener('pointercancel', endDrag);

/* ---- keyboard view ----------------------------------------------------- */

el.viewProxy.addEventListener('keydown', (evt) => {
  let dAz = 0, dAlt = 0, handled = true;
  const step = keyAccel(evt, VIEW_STEP);

  switch (evt.key) {
    case 'ArrowLeft':  case 'A': case 'a': dAz  = -step; break;
    case 'ArrowRight': case 'D': case 'd': dAz  =  step; break;
    case 'ArrowUp':    case 'W': case 'w': dAlt = -step; break;
    case 'ArrowDown':  case 'S': case 's': dAlt =  step; break;
    case 'PageUp':                         dAlt =   -15; break;
    case 'PageDown':                       dAlt =    15; break;
    case 'Home':                           dAlt =  90 - S.getPhi(); break;
    case 'End':                            dAlt = -90 - S.getPhi(); break;
    default: handled = false;
  }
  if (!handled) return;
  evt.preventDefault();

  S.setViewerAzimuth(S.getViewerAzimuth() + dAz);
  S.setPhi(S.getPhi() + dAlt);
  render();
  announce(           'Azimuth ' + speak(S.getViewerAzimuth(), 0, 'degree') +
           ', viewing altitude ' + speak(S.getPhi(),           0, 'degree') + '.');
});

/* ---- latitude controls ------------------------------------------------- */

function commitLatitude(v, doAnnounce) {
  setLatitude(v);

  // Announce new latitude and flag when summer and winter solstices swap dates
  let s0;
  if ( flags.showSolstice && ( ( v * xLat < 0 )          ||
                               ( v    == 0 && xLat < 0 ) ||
                               ( xLat == 0 && v    < 0 ) ) )  {
    s0  = '. The summer solstice is now in ';
    s0 += ( v >= 0 ) ? 'June' : 'December';
    s0 += ' and the winter solstice is now in ';
    s0 += ( v <  0 ) ? 'June' : 'December';
    s0 += '.';
  } else  {
    s0  = '.';
  }
  xLat = v;
  if (doAnnounce) announce(latSpoken(S.getLatitude()) + s0 );
}

el.latSlider.addEventListener('input', () => {
  setLatitude(parseFloat(el.latSlider.value));
});
el.latSlider.addEventListener('change', () => {
  commitLatitude(parseFloat(el.latSlider.value), true);
});

/*
el.latNumber.addEventListener('input', () => {
  const v = parseFloat(el.latNumber.value);
});
*/
el.latNumber.addEventListener('change', () => {
  el.latNumber.value = Math.max( Math.min( parseFloat(el.latNumber.value), 90 ), -90 );
  const v = parseFloat(el.latNumber.value);
  commitLatitude(isFinite(v) ? v : S.getLatitude(), true);
});
el.latNumber.addEventListener('keydown', noEinNumber);

el.latNumber.addEventListener('wheel', (evt) => {
  evt.preventDefault();
  commitLatitude(S.getLatitude() + (evt.deltaY < 0 ? LAT_STEP : -LAT_STEP), true);
});
el.latSlider.addEventListener('wheel', (evt) => {
  evt.preventDefault();
  commitLatitude(S.getLatitude() + (evt.deltaY < 0 ? LAT_STEP : -LAT_STEP), true);
});

el.latNumber.addEventListener('keydown', (evt) => {
  let delta = 0;
  if      (evt.key === 'ArrowUp'  ) delta =  keyAccel(evt, LAT_STEP);
  else if (evt.key === 'ArrowDown') delta = -keyAccel(evt, LAT_STEP);
  else if (evt.key === 'PageUp')    delta =  LAT_PAGE;
  else if (evt.key === 'PageDown')  delta = -LAT_PAGE;
  else return;
  evt.preventDefault();
  commitLatitude(S.getLatitude() + delta, true);
  el.latNumber.value = Math.round( S.getLatitude() );
});

const STEPS = [
  { el: 'step1', flag: 'showPoles',    label: 'show poles'             },
  { el: 'step2', flag: 'showCE',       label: 'show celestial equator' },
  { el: 'step3', flag: 'showEquinox',  label: 'show equinox path'      },
  { el: 'step4', flag: 'showSolstice', label: 'show solstice paths'    }
];

STEPS.forEach((step) => {
  el[step.el].addEventListener('change', () => {
    flags[step.flag] = el[step.el].checked;
    buildScene();
    render();
    announce(step.label + (flags[step.flag] ? ' on.' : ' off.'));
  });
});

/* ---- reset / resize / boot --------------------------------------------- */

function resetSim() {
  flags.showPoles = flags.showCE = flags.showEquinox = flags.showSolstice = false;
  S.setViewerAzimuth(INIT_VIEWER_AZIMUTH);
  S.setPhi(INIT_VIEWER_ALTITUDE);
  S.setLatitude(INIT_LATITUDE);
  buildScene();
  render();
  announce('Simulation reset. Showing the celestial sphere for an observer at ' +
           latSpoken(INIT_LATITUDE) + '.');
}

document.addEventListener('sim-reset', resetSim);

let resizeTimer = 0;
function scheduleResize() {
  if (resizeTimer) cancelAnimationFrame(resizeTimer);
  resizeTimer = requestAnimationFrame(() => { resizeTimer = 0; render(); });
}
window.addEventListener('resize', scheduleResize);

function boot() {
  buildScene();
  klunlInitEqn();
  render();
}

loadArt().then(boot);


// Show screen width on console when testing responsive design
const trackScreen = false;
if (trackScreen) {
  const ro = new ResizeObserver((entries) => {
    for (const entry of entries) {
      const widthPx      = window.innerWidth;
      const rootFontSize = parseFloat(getComputedStyle(document.documentElement).fontSize) || 16;
      const widthRem1    = widthPx / rootFontSize;
      console.log( 'CSS width is:', `${widthRem1}rem`);
    }
  });
  ro.observe( document.getElementById('controls-heading') );
}
