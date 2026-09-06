/* ==========================================================================
   Paths of the Sun Demonstrator  —  accessible HTML5 port
   --------------------------------------------------------------------------
   Behaviour is a faithful port of the decompiled ActionScript (AS1) celestial
   sphere engine (scripts/CelestialSphere.as + "CS *" prototype files) and the
   controller (scripts/frame_1/DoAction.as, scripts/DoInitAction.as).

   Reproduces code-drawn vector art (great circles, sky bowl, horizon plane) 
   on canvas; stickman, shadow, and sun sprites from images.

   Projection engine: foundation/js/kl-unl-celestial-sphere.js
   ========================================================================== */

import {
  CelestialSphere, Circle,
  CELESTIAL_SPHERE_COLORS,
  D2R, R2D, H2R, RA_H, DEC_D, TME_H, TWO_PI,
  drawCircleBucket, absOrient
} from '../foundation/js/kl-unl-celestial-sphere.js';

import {
  pMod, speak, hexToRGBA, logAct, updateSliderProgress, noEinNumber, keyAccel
} from '../foundation/js/kl-unl-utils.js';

logAct('INIT_SUNPATHS');

const S = new CelestialSphere(120);   // radius 120 (AS sphere.size = 240)
S.showUnder = false;
S.setMinPhi(7);
S.setMaxPhi(90);

const CSC = CELESTIAL_SPHERE_COLORS;

const sun = { ra: 0, dec: 0, p: {}, _altaz: {} };
let day   = 0;

let   showTemperatures   = document.getElementById("light").checked;
const showTemperatures_0 = showTemperatures;
let   canvasVar          = 0;  // cycle between moving celestial sphere, date, and latitude

/* ---- Stage geometry (original internal coordinates) -------------------- */
const STAGE_W  = 360, STAGE_H  = 268;
const CENTER_X = 180, CENTER_Y = 150;

/* ======================================================================
   The circles used by this sim (colours/tilts VERBATIM from DoAction.as)
   ====================================================================== */
const celestialEquator = new Circle(S, { thickness: 1,   color: CSC.CEL_EQUTR,  alpha: 1 });
const sunsPath         = new Circle(S, { thickness: 1.6, color: CSC.SUN_PATH,   alpha: 1 });
const meridian         = new Circle(S, { thickness: 1,   color: CSC.MRDN3_CIRC, alpha: 1 });
const ecliptic         = new Circle(S, { thickness: 1,   color: CSC.ECLPTC_3,   alpha: 1 });
const allCircles = [celestialEquator, sunsPath, meridian, ecliptic];

/* ======================================================================
   Sun + date  (ported from "10 CS Experimental.as" / "2 CS Getter Setter")
   ====================================================================== */
function updateSun() {
  const raNow  = day  * RA_H;                   // right ascension, in hours
  const decNow = 23.5 * Math.sin(day * DEC_D);  // declination,     in degrees
  sun.ra       = raNow;
  sun.dec      = decNow;
  sun.p        = S.parse({ ra: raNow, dec: decNow });
}

function setDay(arg) {
  day = arg % 365;
  updateSun();
  S.setSiderealTime( pMod(TME_H * day, 1) * 24 );  // sidereal time, in hours
}

const MONTHS = [ [  31, "January" ], [  59, "February" ], [  90, "March"     ],
                 [ 120, "April"   ], [ 151, "May"      ], [ 181, "June"      ],
                 [ 212, "July"    ], [ 243, "August"   ], [ 273, "September" ],
                 [ 304, "October" ], [ 334, "November" ], [ 365, "December"  ] ];

function getDateString(d = day) {
  let today = pMod(d + 79.5, 365);
  let i     = 0;
  while (i < 12) { if (today < MONTHS[i][0]) break; i++; }
  if (i !== 0) today = today - MONTHS[i - 1][0] + 1; else today += 1;
  return MONTHS[i][1] + " " + Math.floor(today);
}

// Calendar-day UI axis: cd 0 = Jan 1, cd 79 = Mar 21 (= simulation day 0).
const CDAY_OFFSET = 79;

function simDayToCalendarDay(sd) {
  return pMod(sd + CDAY_OFFSET, 365);
}

function calendarDayToSimDay(cd) {
  return pMod(cd - CDAY_OFFSET, 365);
}

function wrapCalendarDay(cd) {
  return pMod(Math.round(cd), 365);
}

const CDAY_JUN_21 = MONTHS[4][0]  + 20;  // June 21, cd 171
const CDAY_DEC_21 = MONTHS[10][0] + 20;  // Dec. 21, cd 354
const TROPIC_LAT  = 23.5;

function updateSeasonLabels(latDeg) {
  // Label winter and summer seasons when latitude is outside of the tropics
  // Label warmer and colder regions in winter and summer seasons
  let junText   = "", decText   = "";
  let southText = "", northText = "";
  if ( showTemperatures )  { 
    if      (latDeg >  TROPIC_LAT) { junText = "summer"; decText = "winter"; }
    else if (latDeg < -TROPIC_LAT) { junText = "winter"; decText = "summer"; }

    if    ( ( Math.abs(simDayToCalendarDay(day)       - CDAY_DEC_21) < 30 ) ||
            ( Math.abs(simDayToCalendarDay(day) + 365 - CDAY_DEC_21) < 30 ) ) {
      southText = "warmer"; northText = "colder";
    }
    else if ( Math.abs(simDayToCalendarDay(day) - CDAY_JUN_21) < 30 ) {
      southText = "colder"; northText = "warmer";
    }
  }
  elSeasonJun.textContent   = junText;
  elSeasonDec.textContent   = decText;
  elSeasonSouth.textContent = southText;
  elSeasonNorth.textContent = northText;  
}

/* ======================================================================
   Temperature bars (insolation proxy: noon sun angle × day length)
   ====================================================================== */
let TEMP_MIN = 0;
let TEMP_MAX = 1;
let TEMP_NOW = 0;

function insolationIndex(latDeg, calendarDay) {
  // We consider angle sun's rays make to ground and length of day; 
  // colors reflect a state between peak and average temperatures per day.
  //
  // For example, on the northern summer solstice the North Pole receives
  // the highest amount of sunlight (insolation) due to the 24-hour day,
  // but the subtropics have the highest peak temperatures due to the
  // Sun being nearly overhead at local noon.
  // 
  const simDay   =  calendarDayToSimDay(calendarDay);
  const dec      =  23.5 * D2R * Math.sin(simDay * TWO_PI / 365);
  const phi      =  latDeg * D2R;
  const sinAlt   =  Math.sin(phi) * Math.sin(dec) + Math.cos(phi) * Math.cos(dec);
  const alt      =  Math.asin(Math.max(-1, Math.min(1, sinAlt)));
  const cosOmega = -Math.tan(phi) * Math.tan(dec);
  let dayFrac;
  if      (cosOmega <= -1) dayFrac = 1;
  else if (cosOmega >=  1) dayFrac = 0;
  else                     dayFrac = Math.acos(cosOmega) / Math.PI;
  return Math.max(0, Math.sin(alt)) * dayFrac;
}

function initTempColorScale() {
  if (!showTemperatures) return;
  let min = Infinity, max = -Infinity;
  for (let cd = 0; cd < 365; cd++) {
    for (let lat = -90; lat <= 90; lat++) {
      const v = insolationIndex(lat, cd);
      if (v < min) min = v;
      if (v > max) max = v;
    }
  }
  TEMP_MIN = min;
  TEMP_MAX = max;
}

function tempIndexToColor(v) {
  let t = (v - TEMP_MIN) / (TEMP_MAX - TEMP_MIN);
  if      (t < 0) t = 0;
  else if (t > 1) t = 1;
  
  // Show index as 0, 1, 2, 3, 4, 5, 10, 15, ... 95, 100%
  if ( t < 0.05 )  { TEMP_NOW =     Math.round( 100*t ); }
  else             { TEMP_NOW = 5 * Math.round(  20*t ); }
  return `hsl(${240 - 240 * t}, 75%, ${38 + 22 * t}%)`;
}

function buildTempGradient(sampleAtFrac) {
  const GRADIENT_STOPS = 48;
  const parts = [];
  for (let i = 0; i <= GRADIENT_STOPS; i++) {
    const frac = i / GRADIENT_STOPS;
    parts.push(`${tempIndexToColor(sampleAtFrac(frac))} ${(frac * 100).toFixed(1)}%`);
  }
  return `linear-gradient(to right, ${parts.join(', ')})`;
}

function applyTempTrackGradient(slider, gradient) {
  slider.style.setProperty('--temp-track-gradient', gradient);
}

function showTemperatureForDate(simDay, latDeg) {
  if (!showTemperatures) return;
  applyTempTrackGradient(elCdaySlider,
    buildTempGradient(frac => insolationIndex(latDeg, frac * 364)));
}

function showTemperatureForLatitude(simDay, latDeg) {
  if (!showTemperatures) return;
  const cd = simDayToCalendarDay(simDay);
  applyTempTrackGradient(elLatInput,
    buildTempGradient(frac => insolationIndex(-90 + frac * 180, cd)));
}

function updateLightIndex(latDeg, calendarDay) {
  if (!showTemperatures) {
    elLightIndex.hidden = true;
    return;
  }
  tempIndexToColor(insolationIndex(latDeg, calendarDay));
  elLightIndex.textContent = "insolation: " + TEMP_NOW + "%";
  elLightIndex.hidden      = false;
}

function sunAltAz() {
  const hp = {};
  S.CtoMH({ ra: sun.ra * H2R, dec: sun.dec * D2R }, hp);
  return { alt: hp.alt * R2D, az: pMod(-hp.az * R2D, 360) };
}

/* ======================================================================
   Sky colour (ported from DoInitAction.as). The shadow is computed in
   drawShadow() from the sun's altitude/azimuth.
   ====================================================================== */
const SKY = CSC.SKY_1;
const sky = { backInner: 1, backOuter: 0.8, frontInner: 0.1, frontOuter: 0.4 };

const dayBackInner  = 1,   nightBackInner  = 0.3, dayBackOuter  = 0.8, nightBackOuter  = 0.2;
const dayFrontInner = 0.1, nightFrontInner = 0,   dayFrontOuter = 0.4, nightFrontOuter = 0.15;

function setSkyColor() {
  const aa       = sun._altaz;
  let intensity  = aa.alt / 10 + 0.5;
  if (intensity > 1) intensity = 1; else if (intensity < 0) intensity = 0;
  sky.backInner  = intensity * (dayBackInner  - nightBackInner)  + nightBackInner;
  sky.backOuter  = intensity * (dayBackOuter  - nightBackOuter)  + nightBackOuter;
  sky.frontInner = intensity * (dayFrontInner - nightFrontInner) + nightFrontInner;
  sky.frontOuter = intensity * (dayFrontOuter - nightFrontOuter) + nightFrontOuter;
}

/* ======================================================================
   Rendering on the <canvas>
   ====================================================================== */
const canvas = document.getElementById("sky-canvas");
const ctx    = canvas.getContext("2d");
let dpr      = Math.max(1, Math.min(3, window.devicePixelRatio || 1));

function sizeCanvas() {
  canvas.width  = STAGE_W * dpr;
  canvas.height = STAGE_H * dpr;
}
sizeCanvas();

function loadImg(src) { const im = new Image(); im.src = src; return im; }
const imgStickman = loadImg("images/stickman.svg");
const imgShadow   = loadImg("images/shadow.svg");
const imgSun      = loadImg("images/sun.svg");
[imgStickman, imgShadow, imgSun].forEach(function (im) {
  im.addEventListener("load", function () { render(); });
});

function horizonClip(side) {
  const s   = Math.sin(S.phi);
  const sgn = (side === "front") ? 1 : -1;
  const r   = S.c.r;
  ctx.beginPath();
  ctx.moveTo(-r, 0);
  ctx.arc(0, 0, r, Math.PI, TWO_PI, false);
  const steps = 32;
  for (let i = 1; i <= steps; i++) {
    const ang = Math.PI * i / steps;
    ctx.lineTo(r * Math.cos(ang), sgn * r * s * Math.sin(ang));
  }
  ctx.closePath();
}

function fillSky(side, innerA, outerA) {
  const r = S.c.r;
  const g = ctx.createRadialGradient(0, 0, 0, 0, 0, r);
  g.addColorStop(0, hexToRGBA(SKY, innerA));
  g.addColorStop(1, hexToRGBA(SKY, outerA));
  ctx.save();
  horizonClip(side);
  ctx.clip();
  ctx.fillStyle = g;
  ctx.fillRect(-r, -r, 2 * r, 2 * r);
  ctx.restore();
}

function drawHorizonPlane() {
  const r      = S.c.r;
  const yscale = Math.sin(S.phi);
  ctx.save();
  ctx.scale(1, yscale);
  const above  = S.phi > 0;
  const g = ctx.createRadialGradient(0, 0, r * 0.05, 0, 0, r);
  if (above) {
    g.addColorStop(0,    CSC.HOR_ABV_1);
    g.addColorStop(0.75, CSC.HOR_ABV_2);
    g.addColorStop(1,    CSC.HOR_ABV_3);
  } else {
    g.addColorStop(0,    CSC.HOR_BLW_1);
    g.addColorStop(1,    CSC.HOR_BLW_2);
  }
  ctx.beginPath();
  ctx.arc(0, 0, r, 0, TWO_PI);
  ctx.fillStyle = g;
  ctx.fill();
  ctx.restore();
}

const CARDINAL_R = 0.88;
const CARDINALS  = [
  { t: 'N', az:   0 }, { t: 'E', az:  90 },
  { t: 'S', az: 180 }, { t: 'W', az: 270 }
];

function drawCardinalLabel(az, text) {
  const p = {};
  S.parsePointInput({ az, alt: 0, r: CARDINAL_R }, p);
  const n = { x: 0, y: 0, z: 1 };
  const u = { x: 1, y: 0, z: 0 };
  const o = absOrient(S, p, n, u);
  ctx.save();
  ctx.translate(o.sp.x, o.sp.y);
  ctx.rotate(o.shellRot);
  ctx.scale(1, o.yscale);
  ctx.rotate(o.instRot);
  ctx.lineJoin     = 'round';
  ctx.miterLimit   = 2;
  ctx.font         = '600 18px system-ui, -apple-system, Segoe UI, sans-serif';
  ctx.textAlign    = 'center';
  ctx.textBaseline = 'middle';
  ctx.lineWidth    = 3;
  ctx.strokeStyle  = CSC.NESW_LINE;
  ctx.fillStyle    = CSC.NESW_FILL;
  ctx.strokeText(text, 0, 0);
  ctx.fillText(  text, 0, 0);
  ctx.restore();
}

function drawCardinals(which) {
  if (S.phi <= 0) return;
  for (const c of CARDINALS) {
    const p = {}, sp = {};
    S.parsePointInput({ az: c.az, alt: 0, r: CARDINAL_R }, p);
    S.WtoSz(p, sp);
    const behind = sp.z < 0;
    if ((which === 'back' && behind) || (which === 'front' && !behind)) {
      drawCardinalLabel(c.az, c.t);
    }
  }
}

function drawSun(which) {
  const useImg = false;
  const aa     = sun._altaz;
  if (aa.alt <= 0) return;
  const sp     = {};
  S.CtoSz(sun.p, sp);
  const behind = sp.z < 0;
  if ((which === 'back' && behind) || (which === 'front' && !behind)) {
    const size   = 16;
    if (useImg && imgSun.complete && imgSun.naturalWidth ) {
      ctx.drawImage(imgSun, sp.x - size / 2, sp.y - size / 2, size, size);
    } else {
      // Scale hue with altitude (note red #ff0000 is a hue of 0, yellow #ffcc00 is 48)
      const hue = 50      * Math.cbrt( Math.max( aa.alt, 1 ) / 90 );  //  11 -  50
      const sat = 40 + 60 * Math.cbrt( Math.max( aa.alt, 1 ) / 90 );  //  53 - 100
      const lgt = 50;
      ctx.save();
      ctx.fillStyle   = "hsl(" + hue + ", " + sat + "%, " + lgt + "%)";
      ctx.strokeStyle = CSC.SKY_2;
      ctx.lineWidth   = 0.5;
      ctx.beginPath();
      ctx.arc(sp.x, sp.y, 7.5, 0, TWO_PI);
      ctx.fill();
      ctx.arc(sp.x, sp.y, 7.5, 0, TWO_PI);
      ctx.stroke();
      ctx.restore();
    }
  }
}

function drawStickman() {
  if (!imgStickman.complete || !imgStickman.naturalWidth) return;
  const BASE = 34;
  const w    = BASE * imgStickman.naturalWidth / imgStickman.naturalHeight;
  const h    = BASE;
  const o    = absOrient(S, { x: 0, y: 0, z: 0 }, { x: -1, y: 0, z: 0 }, { x: 0, y: 0, z: 1 });
  ctx.save();
  ctx.translate(o.sp.x, o.sp.y);
  ctx.rotate(o.shellRot);
  ctx.scale(1, o.yscale);
  ctx.rotate(o.instRot);
  ctx.drawImage(imgStickman, -w / 2, -h, w, h);
  ctx.restore();
}

function drawShadow() {
  if (!imgShadow.complete || !imgShadow.naturalWidth) return;
  const aa     = sun._altaz;
  const alt    = aa.alt;
  if (alt <= 0) return;

  // Smooth shadow opacity "a" function for low altitudes (0 to 10 degrees)
  const aMax   = 0.6;
  const u      = Math.min(Math.max(alt / 10, 0), 1);  // Smoothstep function, u=[0-1]
  const a      = aMax * (u * u * (3 - 2 * u));
  if (a < 0.01) return;

  // Define shadow length L to grow for low altitudes
  let L;
  const Lmin   = 0.04;
  const t      = Math.tan( Math.max(alt, 0.5) * D2R );
  const L0     = 0.5 / t;
  const doClip = true;        // clip shadow beyond horizon plane or lengthen asymptotically
  if ( doClip )  { L = L0; } 
  else           { L = 0.98 * Math.tanh( L0 / 0.98 ); }
  if (L < Lmin)    L = Lmin;  // keep appreciable shadow when Sun near zenith

  // Transform shadow image
  const as  = aa.az + 180;
  const img = imgShadow, W = img.naturalWidth, H = img.naturalHeight;
  const tip = {}, across = {};
  S.WtoSz(S.parse({ az: as,      alt: 0, r: L }), tip   );
  S.WtoSz(S.parse({ az: as + 90, alt: 0, r: 1 }), across);
  const am   = Math.hypot( across.x, across.y ) || 1;
  const figW = 13;
  const wx   = across.x / am * figW;
  const wy   = across.y / am * figW;
  const lx   = tip.x;
  const ly   = tip.y;
  const A    =  wx / W;
  const B    =  wy / W;
  const C    = -lx / H;
  const D    = -ly / H;
  const E    = -(A * (W / 2) + C * H)
  const F    = -(B * (W / 2) + D * H);
  
  ctx.save();
  if ( doClip )  {
    ctx.clip();  // clip shadow head and shoulders beyond horizon plane
  }
  ctx.globalAlpha = a;
  ctx.transform(A, B, C, D, E, F);
  ctx.drawImage(img, 0, 0, W, H);
  ctx.restore();
  ctx.globalAlpha = 1;
}

function render() {
  ctx.setTransform(dpr, 0, 0, dpr, 0, 0);
  ctx.clearRect(0, 0, STAGE_W, STAGE_H);
  ctx.fillStyle = CSC.SKY_2;
  ctx.fillRect( 0, 0, STAGE_W, STAGE_H);
  ctx.translate(CENTER_X, CENTER_Y);

  fillSky(      'back', sky.backInner, sky.backOuter);

  ctx.save(); horizonClip('back'); ctx.clip();
  drawCircleBucket(ctx, allCircles, 'back');
  ctx.restore();

  drawSun(      'back' );
  drawHorizonPlane();
  drawCardinals('back' );
  drawShadow();
  drawStickman();
  drawCardinals('front');
  fillSky(      'front', sky.frontInner, sky.frontOuter);

  ctx.save(); horizonClip('front'); ctx.clip();
  drawCircleBucket(ctx, allCircles, 'front');
  ctx.restore();

  drawSun(      'front');

}

/* ======================================================================
   State recompute + DOM sync (single source of truth)
   ====================================================================== */
const elLatNum       = document.getElementById("latitude-value");
const elLatInput     = document.getElementById("latitude");
const elCdaySlider   = document.getElementById("cday");
const elCdayValue    = document.getElementById("cday-value");
const elCdayStepUp   = document.querySelector( ".sim-cday-step--up"  );
const elCdayStepDown = document.querySelector( ".sim-cday-step--down");
const elDate         = document.getElementById("date-string");
const elDateSr       = document.getElementById("date-sr");
const elStatus       = document.getElementById("sr-status");
const elCanvasDesc   = document.getElementById("canvas-desc");
const elAnimate      = document.getElementById("animate");
const elLight        = document.getElementById("light");
const elLightIndex   = document.getElementById("light-index");
const elSeasonJun    = document.getElementById("season-jun");
const elSeasonDec    = document.getElementById("season-dec");
const elSeasonSouth  = document.getElementById("season-south");
const elSeasonNorth  = document.getElementById("season-north");

const TEMP_TRACK_CLASS = "sim-slider--temp-track";

function initTemperatureBars() {
  if (!showTemperatures) {
    elCdaySlider.classList.remove(    TEMP_TRACK_CLASS);
    elLatInput.classList.remove(      TEMP_TRACK_CLASS);
    elCdaySlider.style.removeProperty("--temp-track-gradient");
    elLatInput.style.removeProperty(  "--temp-track-gradient");
    elCdaySlider.removeAttribute(     "aria-describedby");
    elLatInput.removeAttribute(       "aria-describedby");
    updateSliderProgress(             elCdaySlider);
    updateSliderProgress(             elLatInput);
    return;
  }
  elCdaySlider.classList.add(         TEMP_TRACK_CLASS);
  elLatInput.classList.add(           TEMP_TRACK_CLASS);
  elCdaySlider.setAttribute(          "aria-describedby", "temp-desc-date");
  elLatInput.setAttribute(            "aria-describedby", "temp-desc-latitude");
  initTempColorScale();
}

function latDegrees() {
  return Math.round(S.lat * R2D * 10) / 10;
}

function latSpoken() {
  const v    = Math.abs( latDegrees() );
  const hemi = (S.lat < 0) ? "south" : "north";
  return speak(v, 1, "degree") + " " + hemi;
}

function recompute() {
  sun._altaz = sunAltAz();
  setSkyColor();
  for (const c of allCircles) c.update();
  render();
}

function syncReadouts() {
  if (document.activeElement !== elLatNum) {
    elLatNum.value = String(latDegrees());
  }
  elLatInput.setAttribute("aria-valuetext", latSpoken());
  if (!showTemperatures) updateSliderProgress(elLatInput);
  
  const ds = getDateString();
  const cd = simDayToCalendarDay(day);
  elDate.textContent   = ds;
  elDateSr.textContent = "Date: " + ds;
  if (document.activeElement !== elCdayValue) {
    elCdayValue.value = ds;
  }
  elCdayValue.setAttribute("aria-valuenow", String(cd));
  elCdayValue.setAttribute("aria-valuetext", ds);
  elCdaySlider.value = String(cd);
  elCdaySlider.setAttribute("aria-valuetext", ds);
  if (!showTemperatures) updateSliderProgress(elCdaySlider);
  if (showTemperatures) {
    const latDeg = S.lat * R2D;
    showTemperatureForDate(    day, latDeg);
    showTemperatureForLatitude(day, latDeg);
    updateLightIndex(latDeg, cd);
  } else {
    updateLightIndex();
  }
  updateSeasonLabels(S.lat * R2D);
}

function commitLatNum() {
  let v = parseFloat(elLatNum.value);
  if (!isFinite(v)) { syncReadouts(); return; }
  if (v > 90) v = 90; else if (v < -90) v = -90;
  S.setLatitude(v);
  elLatInput.value = String(Math.round(v * 10) / 10);
  if (!showTemperatures) updateSliderProgress(elLatInput);
  recompute();
  syncReadouts();
  updateCanvasDesc();
  announce("Latitude " + latSpoken() + ".");
}

function diagramDescription() {
  const aa     = sun._altaz;
  const dirOf  = function (az) {
    const dirs = ["north", "northeast", "east", "southeast",
                  "south", "southwest", "west", "northwest", "north"];
    return dirs[ Math.round(pMod(az, 360) / 45) ];
  };
  const sunDesc = (aa.alt > 0)
    ? ("The sun is up at altitude " + speak(aa.alt, 0, "degree") + ", toward the " + dirOf(aa.az) + ". ")
    : "The sun is below the horizon. ";

  const insDesc = ( showTemperatures ) ? "Insolation index is " + TEMP_NOW + " percent. " : "";

  return "Horizon diagram for latitude " + latSpoken() + " on " + getDateString() +
    ". Sun's declination " + speak(sun.dec, 1, "degree") + ". " + sunDesc + insDesc;
  // XXX
}

function announce(msg)      { elStatus.textContent     = msg; }
function updateCanvasDesc() { elCanvasDesc.textContent = diagramDescription(); }

/* ======================================================================
   Controls
   ====================================================================== */
function onLatInput() {
  S.setLatitude(parseFloat(elLatInput.value));
  recompute();
  syncReadouts();
}

elLatInput.addEventListener("input",  onLatInput);
elLatInput.addEventListener("change", function () {
  updateCanvasDesc();
  announce("Latitude " + latSpoken() + ".");
});

elLatNum.addEventListener("change",  commitLatNum);
elLatNum.addEventListener("keydown", function (ev) {
  noEinNumber(ev);
  if (ev.key === "Enter") { ev.preventDefault(); commitLatNum(); }
});

const reduceMotion = window.matchMedia &&
  window.matchMedia("(prefers-reduced-motion: reduce)").matches;
let animating = false, rafId = null, lastT = null, dayAcc = 0;
const DAYS_PER_SEC = 24;

function stopAnimateSilent() {
  animating = false;
  if (rafId) window.cancelAnimationFrame(rafId);
  rafId = null;
}

function stopAnimateIfRunning() {
  if (!animating) return;
  elAnimate.checked = false;
  stopAnimateSilent();
}

function commitCalendarDay(cd, doAnnounce) {
  stopAnimateIfRunning();
  cd = wrapCalendarDay(cd);
  setDay(calendarDayToSimDay(cd));
  sunsPath.setParameters({ ra: 0, dec: sun.dec, tilt: 0 });
  recompute();
  syncReadouts();
  updateCanvasDesc();
  if (doAnnounce) announce("Date " + getDateString() + ".");
}

function onCdayInput() {
  commitCalendarDay(parseInt(elCdaySlider.value, 10), false);
}

elCdaySlider.addEventListener("input", onCdayInput);
elCdaySlider.addEventListener("change", function () {
  commitCalendarDay(parseInt(elCdaySlider.value, 10), true);
});

elCdayStepUp.addEventListener("click", function () {
  commitCalendarDay(simDayToCalendarDay(day) - 1, true);
});
elCdayStepDown.addEventListener("click", function () {
  commitCalendarDay(simDayToCalendarDay(day) + 1, true);
});

function tick(t) {
  if (!animating) return;
  if (lastT === null) lastT = t;
  const dt    = (t - lastT) / 1000; lastT = t;
  dayAcc     += dt * DAYS_PER_SEC;
  const whole = Math.floor(dayAcc);
  if ( whole >= 1 ) {
    dayAcc   -= whole;
    setDay(day + whole);
    sunsPath.setParameters({ ra: 0, dec: sun.dec, tilt: 0 });
    recompute();
    syncReadouts();
  }
  rafId = window.requestAnimationFrame(tick);
}

function startAnimate() {
  if (animating) return;
  animating = true; lastT = null; dayAcc = 0;
  rafId     = window.requestAnimationFrame(tick);
  announce("Animation started.");
}

function stopAnimate() {
  animating = false;
  if (rafId) window.cancelAnimationFrame(rafId);
  rafId     = null;
  updateCanvasDesc();
  announce("Animation stopped on " + getDateString() + ".");
}

elAnimate.addEventListener("change", function () {
  if (elAnimate.checked) {
    if (reduceMotion) {
      setDay(day + 1);
      sunsPath.setParameters({ ra: 0, dec: sun.dec, tilt: 0 });
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

elLight.addEventListener("change", function () {
  showTemperatures = elLight.checked;
  initTemperatureBars();
  syncReadouts();
  if ( showTemperatures )  { announce("Showing insolation index. "); }
  else                     { announce("Hiding insolation index. ");  }

});

/* ---- Pointer drag + keyboard rotation of the view -------------------- */
function stageCoords(ev) {
  const rect = canvas.getBoundingClientRect();
  const x    = (ev.clientX - rect.left) * (STAGE_W / rect.width ) - CENTER_X;
  const y    = (ev.clientY - rect.top ) * (STAGE_H / rect.height) - CENTER_Y;
  return { x: x, y: y };
}

let dragMode    = null;
let canvasFocus = "view";
let dragX = 0, dragY = 0, dragTheta = 0, dragPhi = 0;

function sunVisible() { return sun._altaz && sun._altaz.alt > 0; }

function hitSun(p) {
  if (!sunVisible()) return false;
  const sp = {};
  S.CtoSz(sun.p, sp);
  const dx = p.x - sp.x, dy = p.y - sp.y;
  return (dx * dx + dy * dy) <= 225 && sp.z > 0;
}

function applyDayChange() {
  sunsPath.setParameters({ ra: 0, dec: sun.dec, tilt: 0 });
  recompute();
  syncReadouts();
  updateCanvasDesc();
}

function applyLatChange() {
  recompute();
  syncReadouts();
  updateCanvasDesc();
}

function announceSun() {
  announce("Sun on " + getDateString() + ". Declination " +
    speak(sun.dec, 1, "degree") + ".");
}

function sunDragToCursor(px, py) {
  const raHours = S.getSiderealTime();
  const cur     = day;
  let   best    = cur;
  let bestScore = Infinity;
  for (let d = 0; d < 365; d++) {
    const dec   = 23.5 * Math.sin(d * 0.01721420632103996);
    const sp    = {};
    S.CtoSz(S.parse({ ra: raHours, dec: dec }), sp);
    if (sp.z <= 0) continue;
    const dx    = sp.x - px, dy = sp.y - py;
    let   dd    = Math.abs(d - cur); if (dd > 182.5) dd = 365 - dd;
    let   score = dx * dx + dy * dy + dd * 0.05;
    if (score < bestScore) { bestScore = score; best = d; }
  }
  setDay(best);
  applyDayChange();
}

function moveDay(delta) {
  setDay(((day + delta) % 365 + 365) % 365);
  applyDayChange();
  announceSun();
}

function moveLat(delta) {
  const lat = Math.min( Math.max( latDegrees() + delta, -90 ), 90 );
  S.setLatitude( lat );
  applyLatChange();
  latSpoken();
}

canvas.addEventListener("pointerdown", function (ev) {
  canvas.focus();
  try { canvas.setPointerCapture(ev.pointerId); } catch (e) {}
  const p            = stageCoords(ev);
  const allowGrabSun = false;
  if ( (hitSun(p)) && allowGrabSun ) {
    dragMode = "sun"; canvasFocus = "sun";
    if (animating) { elAnimate.checked = false; stopAnimate(); }
  } else {
    dragMode = "view"; canvasFocus = "view";
    dragX    = p.x; dragY = p.y; dragTheta = S.theta; dragPhi = S.phi;
    canvas.classList.add("dragging");
  }
  ev.preventDefault();
});

canvas.addEventListener("pointermove", function (ev) {
  const p = stageCoords(ev);
  if (dragMode === "view") {
    S.setThetaAndPhi(
      R2D * (dragTheta - (p.x - dragX) / S.c.r),
      R2D * (dragPhi   + (p.y - dragY) / S.c.r)
    );
    recompute();
  } else if (dragMode === "sun") {
    sunDragToCursor(p.x, p.y);
  } else {
    canvas.classList.toggle("sun-hover", hitSun(p));
  }
});

function endDrag(ev) {
  const wasSun = dragMode === "sun";
  if (dragMode) updateCanvasDesc();
  dragMode = null;
  canvas.classList.remove("dragging", "sun-hover");
  try { canvas.releasePointerCapture(ev.pointerId); } catch (e) {}
  if (wasSun) announceSun();
}

canvas.addEventListener("pointerup",     endDrag);
canvas.addEventListener("pointercancel", endDrag);

// Keyboard control on canvas (for celestial sphere, date, and latitude)
canvas.addEventListener("keydown", function (ev) {
  // Change target
  if ( (ev.key == "Enter") || (ev.key == " ") )  {
    canvasVar = pMod( canvasVar + 1, 3 );
    if ( canvasVar == 1 )  { 
      canvasFocus = "sun";
      announce( "Date control mode; " +
                "arrow keys now change the date forward and backward. " +
                "Press Enter to change latitude." );
    } else if ( canvasVar == 2 )  {
      canvasFocus = "lat";
      announce( "Latitude control mode; " +
                "arrow keys now move observer north and south. " +
                "Press Enter to change celestial sphere orientation." );
    } else  {
      canvasFocus = "";
      announce( "Celestial sphere control mode; " +
                "arrow keys now rotate and tilt viewpoint. " +
                "Press Enter to change date." );
    }
    ev.preventDefault();
    return;
  };
  // Keyboard control for date
  let used = true;
  if (canvasFocus === "sun") {
    if (animating) return;
    const dayStep  = keyAccel(ev, 1);
    const weekStep = keyAccel(ev, 7);
    switch (ev.key) {
      case "ArrowLeft":  case "ArrowUp":   moveDay(-dayStep );   break;
      case "ArrowRight": case "ArrowDown": moveDay( dayStep );   break;
      case "PageUp":                       moveDay(-weekStep);   break;
      case "PageDown":                     moveDay( weekStep);   break;
      case "Home": setDay(0);   applyDayChange(); announceSun(); break;
      default: used = false;
    }
    if (used) ev.preventDefault();
    return;
  // Keyboard control for latitude
  } else if (canvasFocus === "lat" ) {
    const latStep  = keyAccel(ev, 0.1);
    const bigStep  = keyAccel(ev, 0.5);
    switch (ev.key) {
      case "ArrowLeft":  case "ArrowUp":   moveLat(-latStep);  break;
      case "ArrowRight": case "ArrowDown": moveLat( latStep);  break;
      case "PageUp":                       moveLat(-bigStep);  break;
      case "PageDown":                     moveLat( bigStep);  break;
      case "Home": S.setLatitude(-90);     moveLat(0);         break;
      case "End":  S.setLatitude( 90);     moveLat(0);         break;
      default: used = false;
    }
    if (used) ev.preventDefault();
    return;
  }
  // Keyboard control for celestial sphere
  const step   = keyAccel(ev, 1);
  const stepBg =             15;
  let handled  = true;
  let thetaDeg = S.theta * R2D, phiDeg = S.phi * R2D;
  let s0;
  switch (ev.key) {
    case "ArrowLeft":  thetaDeg += step;   break;
    case "ArrowRight": thetaDeg -= step;   break;
    case "ArrowUp":    phiDeg   -= step;   break;
    case "ArrowDown":  phiDeg   += step;   break;
    case "PageUp":     phiDeg   -= stepBg; break;
    case "PageDown":   phiDeg   += stepBg; break;
    default: handled = false;
  }
  if (handled) {
    ev.preventDefault();
    S.setThetaAndPhi(thetaDeg, phiDeg);
    recompute(); updateCanvasDesc();
    const az  = Math.round(pMod(360 - S.theta * R2D, 360));
    const alt = Math.round(S.phi * R2D);
    announce("View rotated. Azimuth " + speak(az,  0, "degree") +
                        ", altitude " + speak(alt, 0, "degree") + ".");
  }
});

/* ======================================================================
   Reset (from the KL-UNL masthead "sim-reset" event) + init
   ====================================================================== */
function resetState() {
  S.setThetaAndPhi(160, 30);
  S.setLatitude(41);
  setDay(0);
  sun._altaz       = sunAltAz();
  sunsPath.setParameters(        { ra: 0, dec: sun.dec, tilt:  0   });
  celestialEquator.setParameters({ ra: 0, dec:       0, tilt:  0   });
  meridian.setParameters(        { az: 0, alt:       0, tilt: 90   });
  ecliptic.setParameters(        { ra: 0, dec:       0, tilt: 23.5 });
  elLatInput.value = "41";
  elLatNum.value   = "41";
  elLight.checked  = showTemperatures_0;
  showTemperatures = showTemperatures_0;
  initTemperatureBars();
  if (elAnimate.checked) { elAnimate.checked = false; }
  stopAnimateSilent();
  recompute();
  syncReadouts();
  updateCanvasDesc();
}

document.addEventListener("sim-reset", function () {
  resetState();
  announce("Simulation reset to latitude " + latSpoken() + " on March 21.");
});

window.klunlInitEqn = function () { /* this demonstrator has no equations */ };

elLight.checked = showTemperatures;
initTemperatureBars();
resetState();
window.addEventListener("resize", render);
