/* ===========================================================================
   Big Dipper in Three Dimensions
   HTML5 port of the Flash celestial-sphere frame scripts.
   ---------------------------------------------------------------------------
   The shared celestial-sphere library owns projection, circles, sight lines,
   and absolute symbol orientation. This file keeps the Dipper scene: the
   shaded sky patch, the seven stars at their true distances, the grid labels,
   and the view clamps from the original frame script.
   =========================================================================== */

import {
  CelestialSphere, Circle, Cone, Line, CSObject,
  CELESTIAL_SPHERE_COLORS,
  drawCircleBucket, drawConeLayer, drawLineLayer,
  D2R, H2R, PI, R2D, TWO_PI, QURT_PI,
  DEC_TEXT_FONT, DEC_TEXT_GAP,
  layoutDeclinationText, drawDeclinationLetters
} from '../foundation/js/kl-unl-celestial-sphere.js';

import {
  legToFixed, stepToPrec, speak, pMod, findMinMaxMid, clamp, noEinNumber, 
  keyAccel, updateSliderProgress, hexToRGBA, announceLive, logAct
} from '../foundation/js/kl-unl-utils.js';

logAct('INIT_BigDipper');

/* --- stage and sphere (frame_1/DoAction_2.as) --------------------------- */
const STAGE_W            =  650;
const STAGE_H            =  480;
let   SIZE               = 1000;   // sphere.size -> radius 500
let   LATITUDE           =   35;
let   SIDEREAL_TIME      =    0;
let   SPHERE_UNIT_RADIUS =  250;

let   THETA_OFFSET       =  185;
let   INIT_THETA         =  221;  // legacy values: 221.2, -8.6
let   INIT_PHI           =  -21;
let xPhi                 = INIT_PHI;
let xTheta               = INIT_THETA - THETA_OFFSET;

let   THETA_MIN          =  122;
let   THETA_MAX          =  247;
let   PHI_MIN            =  -35;
let   PHI_MAX            =   35;
const PHI_PAGE           =   10;     // Page Up / Page Down tilt step

/* Point pinned to stage (325, 240) each frame */
let   CENTER_POINT       = { ra: 12.5, dec: 55, r: 0.5 };
let   PIN_X              =  325;
let   PIN_Y              =  240;

/* ActionScript colors. Patch and grid are used only by this diagram. */
//const PATCH_FILL       = hexToRGBA('#6d89bc', 0.6);  // (grey  blue)
const PATCH_FILL         = hexToRGBA('#253674', 0.6);  // (dark  blue, shifted for WCAG AA w/cone sight lines)
const GRID_COLOR         = '#e0e0e0';                  // (light grey)
const LINE_COLOR         = '#000000';                  // (black)
const LINE_LIGHT         = '#ffffff';                  // (white)
const LINE_ALPHA         = 0.15;
const LABEL_COLOR        = CELESTIAL_SPHERE_COLORS.LABEL_FILL;

/* Developer flags:
/* Method for connecting Earth to stars on celestial sphere; 
   Draw shaded cones rather than thin sight lines (legacy style) */
const showCones          = true;
/* Shift celestial sphere patch labels away from asterism */
const flipLabels         = true;
/* Extend data sets from Big Dipper to all 88 IAU constellations */
const allConst           = true;  // allow user to load any of 88 constellations
const showPics           = true;  // connect stars to form asterism on celestial sphere

/* Asterism line segments stop this fraction short of each star. */
const ARC_INSET          = 0;  // tried 0.10, but then pattern varies over asterism
const ARC_COLOR          = '#ffff00';     // (yellow)
const DIPPER_ID          = 'big-dipper';

/* Sight lines can be either thin black lines or cones */
const CONE_COLOR         = '#ffa500';  // (orange)
const CONE_SHADOW        = '#ff0000';  // (red)
const CONE_HLIGHT        = '#ffffff';  // (white)

const LABEL_FONT         = '13px Verdana, Geneva, "DejaVu Sans", sans-serif';
const EARTH_FONT         = '12px Verdana, Geneva, "DejaVu Sans", sans-serif';

/* Legacy set of seven stars (distances in light years).            */
/* Sorted from edge of asterism bowl through tip of asterism handle */
const BIG_DIPPER_STARS = [
  { name: 'Dubhe',  dec: 61.75092, ra: 11.06215, dist: 123.6, path: 1 },
  { name: 'Merak',  dec: 56.38236, ra: 11.03068, dist:  79.4, path: 2 },
  { name: 'Phecda', dec: 53.69475, ra: 11.89717, dist:  83.7, path: 3 },
  { name: 'Megrez', dec: 57.03258, ra: 12.25709, dist:  81.4, path: 4 },
  { name: 'Alioth', dec: 55.95989, ra: 12.90048, dist:  80.9, path: 5 },
  { name: 'Mizar',  dec: 54.92539, ra: 13.39875, dist:  78.2, path: 6 },
  { name: 'Alkaid', dec: 49.31336, ra: 13.79235, dist: 100.7, path: 7 }
];
const BIG_DIPPER_SEGMENTS = [
  [0, 1], [1, 2], [2, 3], [3, 4], [4, 5], [5, 6]
];

let ASTERISM_STARS     = BIG_DIPPER_STARS;
let ASTERISM_SEGMENTS  = BIG_DIPPER_SEGMENTS;
let figureId           = DIPPER_ID;
let figureName         = 'Big Dipper';
let figureSpoken       = 'The Big Dipper';
let iauFigures         = [];

let raMin,  raMax,  raAvg,  raWid,  raWidLim = 1.25;
let decMin, decMax, decAvg, decWid, decWidLim = 60, decPolLim = 75;
let dstMin, dstMax, dstAvg, dstWid;
let raBrd, decBrd;
let raSpc  = 1;
let decSpc = 5;

// Frame the current asterism; note that right ascension wraps at 24 hours
function characterize() {
  const raVals  = ASTERISM_STARS.map(star => star.ra);
  const decVals = ASTERISM_STARS.map(star => star.dec);
  const dstVals = ASTERISM_STARS.map(star => star.dist);
  let mode;

  // Calculate minimum, maximum, and average values, and widths
  [ raMin,  raMax,  raAvg,  raWid,  mode ] = findMinMaxMid(raVals, 24);
  [ decMin, decMax, decAvg, decWid, mode ] = findMinMaxMid(decVals);
  [ dstMin, dstMax, dstAvg, dstWid, mode ] = findMinMaxMid(dstVals);

  // Add 3 degree border around celestial sky patch
  decBrd = 3;
  raBrd  = decBrd / ( 15 * Math.cos( D2R * decAvg ) );

  // Shift asterism patch far enough away from poles to fit border in
  // between patch and pole
  if (decMax > (90 - decBrd)) {
    decAvg -= decMax - (90 - decBrd);
    decMin -= decMax - (90 - decBrd);
    decMax -= decMax - (90 - decBrd);
  }
  if (decMin < (-90 + decBrd)) {
    decAvg -= decMin + (90 - decBrd);
    decMax -= decMin + (90 - decBrd);
    decMin -= decMin + (90 - decBrd);
  }

  // Set up celestial sphere, placing most distant star halfway to it
  SIZE               = 1000;
  LATITUDE           = (decAvg >= 0) ? 90 - decAvg          : 90 + decAvg;
  SIDEREAL_TIME      = (decAvg >= 0) ? pMod(raAvg - 12, 24) : pMod(raAvg, 24);
  SPHERE_UNIT_RADIUS = 2 * dstMax;

  // Shift initial position closer to canvas center for wide/tall patches
  THETA_OFFSET = (decAvg >= 0) ? 180 : 0;
  if ( raWid  <=  2.5 )  { INIT_THETA = THETA_OFFSET + 35; }
  else                   { INIT_THETA = THETA_OFFSET + 20; }
  if ( decWid <= 20   )  { INIT_PHI   = -20; }
  else                   { INIT_PHI   = -10; }
  xPhi         = INIT_PHI;
  xTheta       = INIT_THETA - THETA_OFFSET;

  THETA_MIN    = THETA_OFFSET - 60;
  THETA_MAX    = THETA_OFFSET + 60;
  PHI_MIN      = -35;
  PHI_MAX      =  35;
  
  CENTER_POINT = { ra: raAvg, dec: decAvg, r: 0.5 };
}

/* Drop stars with no distance and remap stick-figure segments onto the kept list. */
function figureFromConstellation(entry) {
  const indexMap = [];
  const stars    = [];
  for (let i = 0; i < entry.stars.length; i++) {
    const star = entry.stars[i];
    if (star.dist_ly == null) continue;
    indexMap[i] = stars.length;
    stars.push({
      name: star.name,
      ra:   star.ra_hours,
      dec:  star.dec_deg,
      dist: star.dist_ly
    });
  }
  const segments = [];
  const pairs = entry.segments || [];
  for (let i = 0; i < pairs.length; i++) {
    const a = indexMap[pairs[i][0]];
    const b = indexMap[pairs[i][1]];
    if (a == null || b == null) continue;
    segments.push([a, b]);
  }
  return { id: entry.abbr, name: entry.name, stars: stars, segments: segments };
}

function applyFigure(figure) {
  figureId          = figure.id;
  figureName        = figure.id === DIPPER_ID ? 'Big Dipper' :     figure.name;
  figureSpoken      = figure.id === DIPPER_ID ? 'The Big Dipper' : figure.name;
  ASTERISM_STARS    = figure.stars;
  ASTERISM_SEGMENTS = figure.segments;
  characterize();
}

characterize();

class App {
  constructor() {
    this.S = new CelestialSphere();
    this.S.setSize(SIZE);
    this.S.setLatitude(LATITUDE);
    this.S.setSiderealTime(SIDEREAL_TIME);
    this.S.setMinPhi(PHI_MIN);
    this.S.setMaxPhi(PHI_MAX);
    this.S.showUnder = true;

    this.theta       = INIT_THETA;
    this.phi         = INIT_PHI;
    this.offX        = 0;
    this.offY        = 0;
    this.renderScale = 1;
    this.drag        = null;
    this.keyed       = false;

    this.starImg     = null;
    this.arrowImg    = null;

    this.stars       = [];
    this.labels      = [];
    this.gridCircles = [];
    this.patchArcs   = [];
    this.cones       = [];
    this.sightLines  = [];
    this.stickArcs   = [];
    this.earth       = null;
    this.copySlots   = [];
    this.sortKey     = null;
    this.sortDir     = 'asc';

    this.buildScene();
    this.cacheDom();
    this.captureCopy();
    this.installConstellationSelect();
    this.populateTable();
    this.bindEvents();
    this.loadImages();
    this.syncControls();
    this.resizeCanvas();
    this.announce();
  }

  /* =======================================================================
     Scene. Patch arcs, grid, stars, labels, and the Earth marker follow
     frame_1/DoAction_2.as.
     ======================================================================= */
  buildScene() {
    const S = this.S;

    for (let i = 0; i < ASTERISM_STARS.length; i++) {
      const d     = ASTERISM_STARS[i];
      const r     = d.dist / SPHERE_UNIT_RADIUS;
      const point = new CSObject(S, 'dot');
      point.setPosition({ ra: d.ra, dec: d.dec, r: r });

      const csStar = new CSObject(S, 'star');
      csStar.setPosition({ ra: d.ra, dec: d.dec });
      csStar.setAbsoluteOrientation();

      // Create guides (either cones or sight lines from Earth to each star)
      // (cones drawn using orange, red, and white)
      const cone = new Cone(S,
        { x: 0, y: 0, z: 0, system: 'celestial' },
        { ra: d.ra, dec: d.dec, r: 1 },
        { radius: 1.5, color: CONE_COLOR, shadow: CONE_SHADOW, highlight: CONE_HLIGHT }
      );
      const line = new Line(
        S,
        { thickness: 1, color: LINE_COLOR, alpha: LINE_ALPHA },
        { x: 0, y: 0, z: 0, system: 'celestial' },
        { ra: d.ra, dec: d.dec, r: 1 }
      );

      this.stars.push({ data: d, point: point, csStar: csStar });
      this.cones.push(cone);
      this.sightLines.push(line);
    }
    this.S.decLetters = [];

    if (showPics) {
      const arcStyle = { thickness: 1, color: ARC_COLOR, alpha: 1 };
      for (let i = 0; i < ASTERISM_SEGMENTS.length; i++) {
        const pair = ASTERISM_SEGMENTS[i];
        const arc  = greatCircleArc(
          S, arcStyle, ASTERISM_STARS[pair[0]], ASTERISM_STARS[pair[1]]
        );
        if (arc) this.stickArcs.push(arc);
      }
    }

    // Define celestial sphere patch to contain asterism, centered between
    // extreme stars and with a border added
    let r1, r2, r3, r4, r5, d1, d2, d3, d4;
    r1 =  pMod( 0.25 * Math.ceil(  4 * ( raMax  + raBrd      ) ),  24 );
    r2 =  pMod( 0.25 * Math.floor( 4 * ( raMin  - raBrd + 12 ) ),  24 );
    r3 =  pMod( 0.25 * Math.floor( 4 * ( raMin  - raBrd      ) ),  24 );
    r1 =  pMod( raMax  + raBrd,       24 );
    r2 =  pMod( raMin  - raBrd + 12,  24 );
    r3 =  pMod( raMin  - raBrd,       24 );
    r4 =  ( 24 - r1 );
    r5 =  ( 24 - r3 );
    d1 = decMax + decBrd;
    d2 = decMin - decBrd;
    d3 = 180 - d1;
    d4 = 180 - d2;
    const patchDefs = [
      { ra:  0, dec: -d1, tilt: 180, gammaStart: 15*r4, gammaEnd: 15*r5 },
      { ra: r2, dec:   0, tilt:  90, gammaStart:    d3, gammaEnd:    d4 },
      { ra:  0, dec:  d2, tilt:   0, gammaStart: 15*r3, gammaEnd: 15*r1 },
      { ra: r1, dec:   0, tilt:  90, gammaStart:    d2, gammaEnd:    d1 }
    ];
    for (let i = 0; i < patchDefs.length; i++) {
      const arc   = new Circle(S, { thickness: 1, color: LINE_COLOR, alpha: 0 }, patchDefs[i]);
      arc.visible = false;
      this.patchArcs.push(arc);
    }

    // Add grid of arcs of constant right ascension and declination at major values
    const gstyle   = { thickness: 1, color: GRID_COLOR, alpha: 1 };
    const gridDefs = [];
    let r0 = decSpc * Math.ceil( ( decMin - decBrd ) / decSpc );
    raSpc  = ( ( raWid > raWidLim ) || ( decMin < -decWidLim ) ||
                                       ( decMax >  decWidLim ) ) ? 1 : 0.5;
    while ( r0 < decMax + decBrd )  {
      gridDefs.push( { ra: 0, dec: r0, tilt: 0, gammaStart: 15*r3, gammaEnd: 15*r1 } );
      r0 += decSpc;
    }
    r0 = raSpc * Math.ceil( ( raMin - raBrd ) / raSpc );
    while ( r0 < raMin + raWid + raBrd )  {
      gridDefs.push( { ra: r0, dec: 0, tilt: 90, gammaStart: d2, gammaEnd: d1 } );
      r0 += raSpc;
    }

    for (let i = 0; i < gridDefs.length; i++) {
      this.gridCircles.push(new Circle(S, gstyle, gridDefs[i]));
    }

    this.updateScene();
    this.earth = new CSObject(S, 'earth');
    this.earth.setPosition({ ra: raAvg, dec: decAvg, r: 0 });
  }

  updateScene() {
    // Shift right ascension labels above or below celestial sphere patch 
    // and declination labels to the left or right of the patch, keeping
    // labels away from the asterism

    let r0, r1, r2, s0, ort = true;
    
    const raGap  = 2.0;
    const decGap = 1.6;
    
    const mkLabel = (text, pos, normal, up) => {
      const o = new CSObject(this.S, 'label');
      o.setPosition(pos);
      o.setAbsoluteOrientation(normal, up);
      o.text  = text;
      this.labels.push(o);
    };

    // Label celestial sphere patch grid, with superscript h/m and degree symbols
    // 
    // Place declination labels to left or right of celestial sphere patch
    this.labels.length = 0;
    this.theta = pMod(this.theta - THETA_MIN, 360) + THETA_MIN;
    r0 = ( decAvg >= 0 ) ? decSpc * Math.ceil(  ( decMin - decBrd ) / decSpc ) :
                           decSpc * Math.floor( ( decMax + decBrd ) / decSpc ) ;
    
    while ( ( decMin - decBrd <= r0 ) && ( r0 <= decMax + decBrd ) && Math.abs(r0) < 90)  {
      // Place declination labels left of patch (at higher right ascension)
      if ( flipLabels && ( (this.theta - THETA_OFFSET) < 0) )  {
        r1 = raMax + raBrd + 0.75 * decBrd / ( 15 * Math.cos( D2R * r0 ) );
        // Near to poles, keep labels parallel to each other because curvature
        // between labels increases so much across even a small patch
        if ( ort )  {
          r2 = { ra: pMod(r1 - 12, 24), dec: -r0 };
          if (Math.abs(decAvg) > 70)  { ort = false; }
        }
        mkLabel(r0+'\u00b0', { ra: pMod(r1,      24), dec:  r0 },
                               r2, 
                             { ra: 0,                 dec:  90 });

      // Place declination labels right of patch (at lower right ascension)
      } else  {
        r1 = raMin - raBrd -0.75 * decBrd / ( 15 * Math.cos( D2R * r0 ) );
        if ( ort )  {
          r2 = { ra: pMod(r1 - 12, 24), dec: -r0 };
          if (Math.abs(decAvg) > 70)  { ort = false; }
        }
        mkLabel(r0+'\u00b0', { ra: pMod(r1,      24), dec:  r0 },
                               r2,
                             { ra: 0,                 dec:  90 });
      }
      r0 += Math.sign(decAvg) * decSpc;
    }
    // Place right ascension labels above or below celestial sphere patch
    raSpc = ( ( raWid > raWidLim ) || ( decMin < -decWidLim ) ||
                                      ( decMax >  decWidLim ) ) ? 1 : 0.5;
    r0 = raSpc * Math.ceil( ( raMin - raBrd ) / raSpc );
    s0 = ( raWid > raWidLim ) ? pMod(r0,24) + '\u02b0' : RAinMin(r0);
    
    while ( r0 < raMin + raWid + raBrd )  {
      // Place right ascension labels below patch (at lower declination)
      s0 = ( raWid > raWidLim ) ? pMod(r0,24) + '\u02b0' : RAinMin(r0);
      if ( ( flipLabels && (this.phi < 0) &&
             ( decMin >= -decPolLim ) ) || ( decMax > decPolLim ) )  { 
        mkLabel(s0, { ra: r0,                  dec:  decMin - decGap*decBrd },
                    { ra: pMod( r0 + 12, 24 ), dec: -decMin + decGap*decBrd },
                { ra: 0,                   dec:  90                     });
        
      // Place right ascension labels above patch (at higher declination)
      } else  {
        mkLabel(s0, { ra: r0,                  dec:  decMax + decGap*decBrd },
                    { ra: pMod( r0 + 12, 24 ), dec: -decMax - decGap*decBrd },
                    { ra: 0,                   dec:  90                     });
      }
      r0 += raSpc;
    }

    function RAinMin( RA )  {
      // Format right ascension in hours and minutes for extra labels 
      // added between hour markers
      let s0;

      RA = pMod(RA, 24);
      s0 = Math.floor(RA) + '\u02b0';
      if ( Math.round(60*(RA -  Math.floor(RA))) != 0 )  {
        s0 += ' ' + Math.round(60*(RA -  Math.floor(RA))) + '\u1d50';
      }
      return s0;
    }
  }

  cacheDom() {
    this.canvas         = document.getElementById('sky');
    this.ctx            = this.canvas.getContext('2d');
    this.desc           = document.getElementById('diagramDesc');
    this.thetaNumber    = document.getElementById('thetaNumber');
    this.phiNumber      = document.getElementById('phiNumber');
    this.thetaSlider    = document.getElementById('thetaSlider');
    this.phiSlider      = document.getElementById('phiSlider');
    this.sightlinesCBox = document.getElementById('sightlines');
    this.diagramHeading = document.getElementById('diagramHeading');
    this.tableCaption   = document.querySelector('.sim-table caption');
  }

  /* Remember the Big Dipper wording so a later choice can restore it. */
  captureCopy() {
    const slots = [];
    const addText = (el) => {
      if (!el) return;
      slots.push({
        original: el.textContent,
        set: (value) => { el.textContent = value; }
      });
    };
    slots.push({
      original: document.title,
      set: (value) => { document.title = value; }
    });
    addText(this.diagramHeading);
    addText(this.tableCaption);
    if (this.canvas) {
      const canvas = this.canvas;
      slots.push({
        original: canvas.getAttribute('aria-label') || '',
        set: (value) => { canvas.setAttribute('aria-label', value); }
      });
    }
    this.copySlots = slots;
  }

  rewriteCopy() {
    const name = figureId === DIPPER_ID ? null : figureName;
    for (let i = 0; i < this.copySlots.length; i++) {
      const slot = this.copySlots[i];
      slot.set(name == null ? slot.original : slot.original
        .replace(/the\s+Big\s+Dipper/g, name)
        .replace(/Big\s+Dipper/g, name));
    }
  }

  installConstellationSelect() {
    if (!allConst || !iauFigures.length) return;
    const heading    = document.getElementById('dataHeading');
    if (!heading) return;
    const select     = document.createElement('select');
    select.id        = 'dataHeading';
    select.className = 'panel__heading sim-constellation';
    select.setAttribute('aria-label', 'Constellation');

    const dipper       = document.createElement('option');
    dipper.value       = DIPPER_ID;
    dipper.textContent = 'The Big Dipper';
    dipper.selected    = true;
    select.appendChild(dipper);

    for (let i = 0; i < iauFigures.length; i++) {
      const figure       = iauFigures[i];
      const option       = document.createElement('option');
      option.value       = figure.id;
      option.textContent = figure.name;
      select.appendChild(option);
    }

    heading.replaceWith(select);
    const section = select.closest('section');
    if (section) {
      section.removeAttribute('aria-labelledby');
      section.setAttribute('aria-label', 'Star data');
    }
    select.addEventListener('change', () => this.selectFigure(select.value));
    this.constellationSelect = select;
  }

  selectFigure(id) {
    let figure = null;
    if (id === DIPPER_ID) {
      figure = {
        id:       DIPPER_ID,
        name:    'Big Dipper',
        stars:    BIG_DIPPER_STARS,
        segments: BIG_DIPPER_SEGMENTS
      };
    } else {
      for (let i = 0; i < iauFigures.length; i++) {
        if (iauFigures[i].id === id) { figure = iauFigures[i]; break; }
      }
    }
    if (!figure || figure.id === figureId) return;
    applyFigure(figure);
    this.rewriteCopy();
    this.rebuildScene();
    this.thetaSlider.min = THETA_MIN - THETA_OFFSET;
    this.thetaSlider.max = THETA_MAX - THETA_OFFSET;
    this.thetaNumber.min = THETA_MIN - THETA_OFFSET;
    this.thetaNumber.max = THETA_MAX - THETA_OFFSET;
    this.phiSlider.min   = PHI_MIN;
    this.phiSlider.max   = PHI_MAX;
    this.phiNumber.min   = PHI_MIN;
    this.phiNumber.max   = PHI_MAX;
    this.sortKey         = null;
    this.sortDir         = 'asc';
    this.populateTable();
    this.setView(INIT_THETA, INIT_PHI);
    this.syncControls();
    this.render();
    this.announce('Showing ' + figureSpoken + '. ');
  }

  rebuildScene() {
    this.S.setSize(SIZE);
    this.S.setLatitude(LATITUDE);
    this.S.setSiderealTime(SIDEREAL_TIME);
    this.S.setMinPhi(PHI_MIN);
    this.S.setMaxPhi(PHI_MAX);
    this.stars       = [];
    this.labels      = [];
    this.gridCircles = [];
    this.patchArcs   = [];
    this.cones       = [];
    this.sightLines  = [];
    this.stickArcs   = [];
    this.buildScene();
  }

  // Sort table of stars by any column. Right ascension is a 24-hour
  // circle: ascending order starts after the largest gap and walks forward.
  populateTable() {
    const body = document.getElementById('star-table-body');
    if (!body) return;
    let rows = ASTERISM_STARS.slice();
    if (this.sortKey === 'ra') {
      rows = sortByRightAscension(rows, this.sortDir === 'desc');
    } else if (this.sortKey) {
      const key = this.sortKey;
      const dir = this.sortDir === 'asc' ? 1 : -1;
      rows.sort((a, b) => {
        if (key === 'name') return dir * a.name.localeCompare(b.name);
        return dir * (a[key] - b[key]);
      });
    }
    let html = '';
    for (let i = 0; i < rows.length; i++) {
      const d = rows[i];
      html += '<tr><th scope="row">' + d.name + '</th>' +
        '<td>' + legToFixed(d.ra,   2) + '</td>' +
        '<td>' + legToFixed(d.dec,  2) + '</td>' +
        '<td>' + legToFixed(d.dist, 1) + '</td></tr>';
    }
    body.innerHTML = html;
    this.updateSortHeaders();

    // Announce table sort
    let   s0  = '';
    const s1  = (this.sortDir == 'asc') ? 'ascending' : 'descending';
    let   s2  = '';
    if      (this.sortKey == 'name' )  { s2 = 'stellar name';        }
    else if (this.sortKey == 'ra'   )  { s2 = 'right ascension';     }
    else if (this.sortKey == 'dec'  )  { s2 = 'declination';         }
    else if (this.sortKey == 'dist' )  { s2 = 'distance from Earth'; }
    if (this.sortKey != null)  {
      s0 = 'The table of stars is sorted in ' + s1 + ' order by ' + s2 + '.';
    }
    announceLive(this.desc, s0);
  }

  updateSortHeaders() {
    const heads = document.querySelectorAll('.sim-table thead th');
    for (let i = 0; i < heads.length; i++) {
      const th  = heads[i];
      const btn = th.querySelector('.sim-sort');
      if (!btn) continue;
      const active = this.sortKey === btn.dataset.sort;
      th.setAttribute('aria-sort', active
        ? (this.sortDir === 'asc' ? 'ascending' : 'descending')
        : 'none');
      const mark = btn.querySelector('.sim-sort__mark');
      if (mark) mark.textContent = active ? (this.sortDir === 'asc' ? ' \u25B2' : ' \u25BC') : '';
    }
  }

  sortBy(key) {
    if (this.sortKey === key) this.sortDir = this.sortDir === 'asc' ? 'desc' : 'asc';
    else {
      this.sortKey = key;
      this.sortDir = 'asc';
    }
    this.populateTable();
  }

  loadImages() {
    const redraw         = () => this.render();
    this.starImg         = new Image();
    this.starImg.onload  = redraw;
    this.starImg.src     = 'images/star.svg';
    this.arrowImg        = new Image();
    this.arrowImg.onload = redraw;
  //this.arrowImg.src    = 'images/earth-arrow.svg';
    this.arrowImg.src    = 'images/earth-arrow_01.png';
  }

  /* =======================================================================
     Drawing
     ======================================================================= */
  setView(theta, phi) {
    this.theta = clamp(theta, THETA_MIN, THETA_MAX);
    this.phi   = clamp(phi,   PHI_MIN,   PHI_MAX  );
    this.S.setThetaAndPhi(this.theta, this.phi);

    // Shift labels out from behind asterism if necessary
    if ( (   this.phi                    * xPhi   < 0 ) ||
         ( ( this.theta - THETA_OFFSET ) * xTheta < 0 ) ) this.updateScene();
    if ( this.phi                  != 0 ) xPhi   = this.phi;
    if ( this.theta - THETA_OFFSET != 0 ) xTheta = this.theta - THETA_OFFSET;
  }

  /* Closed sky-patch fill. Walk each boundary arc with the same quadratic
     steps as the Flash drawPatch (minimum step pi/4). */
  fillPatch() {
    const ctx    = this.ctx;
    const arcs   = this.patchArcs;
    ctx.beginPath();
    const vFirst = arcs[0].computeV();
    const ax0    = Math.cos(arcs[0].gS);
    const ay0    = Math.sin(arcs[0].gS);
    ctx.moveTo(vFirst[0] * ax0 + vFirst[1] * ay0 + vFirst[2],
               vFirst[3] * ax0 + vFirst[4] * ay0 + vFirst[5]);
    for (let k = 0; k < arcs.length; k++) {
      const arc  = arcs[k];
      const v    = arc.computeV();
      let g1     = arc.gS;
      let g2     = arc.gE;
      if (g2 < g1) g2 += TWO_PI;
      let span = g2 - g1;
      if (span === 0) span = TWO_PI;
      const n        = Math.ceil(span / QURT_PI);
      const step     = span / n;
      const halfStep = step / 2;
      const cRad     = 1 / Math.cos(halfStep);
      let aAngle     = g1 + step;
      let cAngle     = aAngle - halfStep;
      for (let i = 0; i < n; i++) {
        const cax = Math.cos(aAngle), cay = Math.sin(aAngle);
        const cx  = cRad * Math.cos(cAngle), cy = cRad * Math.sin(cAngle);
        ctx.quadraticCurveTo(
          v[0] * cx  + v[1] * cy  + v[2], v[3] * cx  + v[4] * cy  + v[5],
          v[0] * cax + v[1] * cay + v[2], v[3] * cax + v[4] * cay + v[5]);
        aAngle += step;
        cAngle += step;
      }
    }
    ctx.closePath();
    ctx.globalAlpha = 1;
    ctx.fillStyle   = PATCH_FILL;
    ctx.fill();
  }

  placeObject(obj) {
    this.S.CtoSz(obj.p, obj.sp);
    if (obj.oType === 2) obj.update();
    const wp = {};
    this.S.CtoW(obj.p, wp);
    obj.wpz = wp.z;
  }

  drawObjects(list) {
    for (let i = 0; i < list.length; i++) {
      const o = list[i];
      if      (o.name === 'dot')   this.drawDot(o);
      else if (o.name === 'star')  this.drawStar(o);
      else if (o.name === 'label') this.drawLabel(o);
      else if (o.name === 'earth') this.drawEarth(o);
    }
  }

  drawDot(o) {
    const ctx = this.ctx;
    ctx.fillStyle   = LINE_COLOR;
    ctx.globalAlpha = 1;
    ctx.beginPath();
    ctx.arc(o.sp.x, o.sp.y, 2, 0, TWO_PI);
    ctx.fill();
  }

  drawStar(o) {
    const img = this.starImg;
    if (!img || !img.complete || !img.naturalWidth) return;
    const ctx = this.ctx;
    ctx.save();
    ctx.translate(o.sp.x, o.sp.y);
    ctx.rotate(o.rotation);
    ctx.scale(1, o.yScale);
    ctx.rotate(o.innerRotation);
    ctx.drawImage(img, -img.naturalWidth / 2, -img.naturalHeight / 2);
    ctx.restore();
  }

  drawLabel(o) {
    const ctx = this.ctx;
    ctx.save();
    ctx.translate(o.sp.x, o.sp.y);
    ctx.rotate(o.rotation);
    ctx.scale(1, o.yScale);
    ctx.rotate(o.innerRotation);
    ctx.fillStyle    = LABEL_COLOR;
    ctx.globalAlpha  = 1;
    ctx.font         = LABEL_FONT;
    ctx.textAlign    = 'center';
    ctx.textBaseline = 'middle';
    ctx.fillText(o.text, 0, 0);
    ctx.restore();
  }

  /* The arrow graphic points up, with its tip at the top of the image.
     Anchor that tip on the origin, where the sight lines meet.
     Below the horizon (phi < 0) the arrow points down and the caption
     sits above it; the tip stays on Earth. */
  drawEarth(o) {
    const ctx        = this.ctx;
    const x          = o.sp.x;
    const y          = o.sp.y;
    const img        = this.arrowImg;
    const down       = this.phi < 0;
    ctx.globalAlpha  = 1;
    ctx.fillStyle    = LABEL_COLOR;
    // Writing label in white against celestial sphere patch while the label 
    // position shifts from above and below the arrow could be more changes
    // than are helpful, so turn it off for now.
    if ( ( -4 < this.phi && this.phi < 1 ) && false && 
         ( -8 < this.theta - THETA_OFFSET && this.theta - THETA_OFFSET < 6 ) ) {
      ctx.fillStyle = LINE_LIGHT;  // (white)
    }
    ctx.font         = EARTH_FONT;
    ctx.textAlign    = 'center';
    ctx.textBaseline = down ? 'bottom' : 'top';
    if (img && img.complete && img.naturalWidth) {
      const w = img.naturalWidth;
      const h = img.naturalHeight;
      if (down) {
        ctx.save();
        ctx.translate(x, y);
        ctx.scale(1, -1);
        ctx.drawImage(img, -w / 2, 0);
        ctx.restore();
        ctx.fillText("Earth's Position", x, y - h - 3);
      } else {
        ctx.drawImage(img, x - w / 2, y);
        ctx.fillText("Earth's Position", x, y + h + 3);
      }
    } else {
      ctx.strokeStyle = LINE_COLOR;
      ctx.lineWidth   = 1;
      ctx.beginPath();
      if (down) {
        ctx.moveTo(x,     y     );
        ctx.lineTo(x,     y - 22);
        ctx.moveTo(x - 4, y -  8);
        ctx.lineTo(x,     y     );
        ctx.lineTo(x + 4, y -  8);
      } else {
        ctx.moveTo(x,     y     );
        ctx.lineTo(x,     y + 22);
        ctx.moveTo(x - 4, y +  8);
        ctx.lineTo(x,     y     );
        ctx.lineTo(x + 4, y +  8);
      }
      ctx.stroke();
      ctx.fillText("Earth's Position", x, down ? y - 26 : y + 26);
    }
  }

  render() {
    this.S.setThetaAndPhi(this.theta, this.phi);

    const pin   = {};
    const pinSp = {};
    this.S.parsePointInput(CENTER_POINT, pin);
    this.S.CtoSz(pin, pinSp);
    this.offX = PIN_X - pinSp.x;
    this.offY = PIN_Y - pinSp.y;

    for (let i = 0; i < this.gridCircles.length; i++) this.gridCircles[i].update();
    for (let i = 0; i < this.stickArcs.length; i++)   this.stickArcs[i].update();
    const guides = showCones ? this.cones : this.sightLines;
    for (let i = 0; i < guides.length; i++) guides[i].update();

    const bS = [], fS = [], objAI = [], objBI = [];
    const classify = (o) => {
      this.placeObject(o);
      if (o.r < 1) (o.wpz  < 0 ? objBI : objAI).push(o);
      else         (o.sp.z < 0 ? bS    : fS).push(o);
    };
    for (let i = 0; i < this.stars.length; i++) {
      classify(this.stars[i].point);
      classify(this.stars[i].csStar);
    }
    for (let i = 0; i < this.labels.length; i++) classify(this.labels[i]);
    classify(this.earth);

    const byZ = (a, b) => a.sp.z - b.sp.z;
    bS.sort(byZ);
    fS.sort(byZ);
    objAI.sort(byZ);
    objBI.sort(byZ);

    const ctx = this.ctx;
    ctx.setTransform(1, 0, 0, 1, 0, 0);
    ctx.clearRect(0, 0, this.canvas.width,      this.canvas.height);
    ctx.setTransform(   this.renderScale, 0, 0, this.renderScale,
                        this.offX * this.renderScale, this.offY * this.renderScale);

    drawDeclinationLetters(ctx, this.S, this.S.decLetters, 'back',  { font: LABEL_FONT });
    drawDeclinationLetters(ctx, this.S, this.S.decLetters, 'front', { font: LABEL_FONT });

    if (showCones) {
      this.fillPatch();
      if (this.sightlinesCBox.checked)  { drawConeLayer(ctx,    this.cones,       'bE'); }
      drawCircleBucket(ctx, this.gridCircles, 'back', { dim: 1 });
      drawCircleBucket(ctx, this.stickArcs,   'back', { dim: 1 });
      this.drawObjects(bS);

      /* This block draws cone sight lines and star points in technically 
         correct order */
      /*
      if (this.phi < 0) {
        this.drawObjects(objAI);
        if (this.sightlinesCBox.checked)  { drawConeLayer(ctx, this.cones, 'aI'); }
        this.drawObjects(objBI);
        if (this.sightlinesCBox.checked)  { drawConeLayer(ctx, this.cones, 'bI'); }
      } else {
        this.drawObjects(objBI);
        if (this.sightlinesCBox.checked)  { drawConeLayer(ctx, this.cones, 'bI'); }
        this.drawObjects(objAI);
        if (this.sightlinesCBox.checked)  { drawConeLayer(ctx, this.cones, 'aI'); }
      }
      */

      /* This block always draws star points after cone sight lines 
         (technically incorrect order) 
         so that stars appear as points rather than as beads on cone-strings */
      if (this.phi < 0) {
        if (this.sightlinesCBox.checked)  { drawConeLayer(ctx, this.cones, 'aI'); }
        if (this.sightlinesCBox.checked)  { drawConeLayer(ctx, this.cones, 'bI'); }
        this.drawObjects(objAI);
        this.drawObjects(objBI);
      } else {
        if (this.sightlinesCBox.checked)  { drawConeLayer(ctx, this.cones, 'bI'); }
        if (this.sightlinesCBox.checked)  { drawConeLayer(ctx, this.cones, 'aI'); }
        this.drawObjects(objBI);
        this.drawObjects(objAI);
      }

      drawCircleBucket(ctx, this.gridCircles, 'front', { dim: 1 });
      drawCircleBucket(ctx, this.stickArcs,   'front', { dim: 1 });
      this.drawObjects(fS);
      if (this.sightlinesCBox.checked)  { drawConeLayer(ctx, this.cones, 'fE'); }
    } else {
      this.fillPatch();
      if (this.sightlinesCBox.checked)  { drawLineLayer(ctx, this.sightLines, 'bE'); }
      drawCircleBucket(ctx, this.gridCircles, 'back', { dim: 1 });
      drawCircleBucket(ctx, this.stickArcs,   'back', { dim: 1 });
      this.drawObjects(bS);

      if (this.phi < 0) {
        this.drawObjects(objAI);
        if (this.sightlinesCBox.checked)  { drawLineLayer(ctx, this.sightLines, 'aI'); }
        this.drawObjects(objBI);
        if (this.sightlinesCBox.checked)  { drawLineLayer(ctx, this.sightLines, 'bI'); }
      } else {
        this.drawObjects(objBI);
        if (this.sightlinesCBox.checked)  { drawLineLayer(ctx, this.sightLines, 'bI'); }
        this.drawObjects(objAI);
        if (this.sightlinesCBox.checked)  { drawLineLayer(ctx, this.sightLines, 'aI'); }
      }

      drawCircleBucket(ctx, this.gridCircles, 'front', { dim: 1 });
      drawCircleBucket(ctx, this.stickArcs,   'front', { dim: 1 });
      this.drawObjects(fS);
      if (this.sightlinesCBox.checked)  { drawLineLayer(ctx, this.sightLines, 'fE'); }
    }
  }

  resizeCanvas() {
    const dpr          = Math.max(1, window.devicePixelRatio || 1);
    const cssW         = Math.round(this.canvas.getBoundingClientRect().width) || STAGE_W;
    const backingW     = Math.max(STAGE_W, Math.round(cssW * dpr));
    this.renderScale   = backingW / STAGE_W;
    this.canvas.width  = backingW;
    this.canvas.height = Math.round(STAGE_H * this.renderScale);
    this.render();
  }

  /* =======================================================================
     Controls
     ======================================================================= */
  syncControls() {
    const t                = Math.round(this.theta - THETA_OFFSET);
    const p                = Math.round(this.phi);
    const tPrec            = stepToPrec(this.thetaNumber.step);
    const pPrec            = stepToPrec(this.phiNumber.step);
    this.thetaNumber.value = legToFixed(t, tPrec);
    this.phiNumber.value   = legToFixed(p, pPrec);
    this.thetaSlider.value = t;
    this.phiSlider.value   = p;
    this.thetaSlider.setAttribute('aria-valuetext',
      'Horizontal angle ' + speak(t, 0, 'degree'));
    this.phiSlider.setAttribute('aria-valuetext',
      'Vertical tilt '    + speak(p, 0, 'degree'));
    updateSliderProgress(this.thetaSlider);
    updateSliderProgress(this.phiSlider);
  }

  readNumber(input, slider) {
    let v               = Number(input.value);
    if (!isFinite(v)) v = Number(slider.value);
    v                   = clamp(v, Number(slider.min), Number(slider.max));
    input.value         = legToFixed(v, stepToPrec(input.step));
    slider.value        = v;
    updateSliderProgress(slider);
    return v;
  }

  applyControls() {
    this.setView(Number(this.thetaSlider.value) + THETA_OFFSET, Number(this.phiSlider.value));
    this.render();
  }

  announce(prefix) {
    const count = (figureId === DIPPER_ID && ASTERISM_STARS.length === 7)
      ? 'seven' : String(ASTERISM_STARS.length);
    const slines = (this.sightlinesCBox.checked) ? 'shown' : 'hidden';
    const msg =
      (prefix || '') +
      'The ' + count + ' ' + figureName + ' stars are shown at their true distances from Earth. ' +
      'Yellow stars mark where each projects onto the celestial sphere to form the asterism. '    + 
      'View orientation: horizontal angle ' + speak(Math.round(this.theta), 0, 'degree') +
      ', vertical tilt ' + speak(Math.round(this.phi), 0, 'degree') + '. Sightlines: '   + slines + '.';
    announceLive(this.desc, msg);
  }

  reset() {
    if (allConst && iauFigures.length)  { 
      document.getElementById('dataHeading').selectedIndex = 0;
      this.selectFigure(DIPPER_ID);
    }
    this.sortKey = null;
    this.sortDir = 'asc';
    this.populateTable();
    this.setView(INIT_THETA, INIT_PHI);
    this.syncControls();
    this.render();
    this.announce();
  }

  bindEvents() {
    const thetaNumber    = this.thetaNumber;
    const phiNumber      = this.phiNumber;
    const thetaSlider    = this.thetaSlider;
    const phiSlider      = this.phiSlider;
    const sightlinesCBox = this.sightlinesCBox;

    document.addEventListener('sim-reset', () => this.reset());

    const sortButtons = document.querySelectorAll('.sim-sort');
    for (let i = 0; i < sortButtons.length; i++) {
      sortButtons[i].addEventListener('click', () => {
        this.sortBy(sortButtons[i].dataset.sort);
      });
    }

    const onSliderInput = (slider, number) => {
      this.setView(Number(thetaSlider.value) + THETA_OFFSET, Number(phiSlider.value));
      number.value = legToFixed(Number(slider.value), stepToPrec(number.step));
      updateSliderProgress(thetaSlider);
      updateSliderProgress(phiSlider);
      this.render();
    };
    thetaSlider.addEventListener(    'input',  () => onSliderInput(thetaSlider, thetaNumber));
    phiSlider.addEventListener(      'input',  () => onSliderInput(phiSlider,   phiNumber));
    thetaSlider.addEventListener(    'change', () => this.announce());
    phiSlider.addEventListener(      'change', () => this.announce());
    sightlinesCBox.addEventListener( 'change', () => this.render());

    // Apply a number box only when the typed value is already inside the
    // slider range, so a half-finished entry such as "1" of "130" is left alone.
    const onNumberInput = (number, slider) => {
      const v  = Number(number.value);
      const lo = Number(slider.min);
      const hi = Number(slider.max);
      if (!isFinite(v) || v < lo || v > hi) return;
      slider.value = v;
      updateSliderProgress(slider);
      this.applyControls();
    };
    const onNumberChange = (number, slider) => {
      this.readNumber(number, slider);
      this.applyControls();
      this.announce();
    };
    /*
    thetaNumber.addEventListener('input',  () => onNumberInput(thetaNumber,  thetaSlider));
    phiNumber.addEventListener(  'input',  () => onNumberInput(phiNumber,    phiSlider));
    */
    thetaNumber.addEventListener('change', () => onNumberChange(thetaNumber, thetaSlider));
    phiNumber.addEventListener(  'change', () => onNumberChange(phiNumber,   phiSlider));
    thetaNumber.addEventListener('keydown', noEinNumber);
    phiNumber.addEventListener(  'keydown', noEinNumber);

    this.canvas.addEventListener('pointerdown',   (ev) => this.onPointerDown(ev));
    this.canvas.addEventListener('pointermove',   (ev) => this.onPointerMove(ev));
    this.canvas.addEventListener('pointerup',     (ev) => this.onPointerUp(ev));
    this.canvas.addEventListener('pointercancel', (ev) => this.onPointerUp(ev));
    this.canvas.addEventListener('keydown',       (ev) => this.onCanvasKey(ev));
    this.canvas.addEventListener('keyup',         (ev) => this.onCanvasKeyUp(ev));

    window.addEventListener('resize', () => this.resizeCanvas());
  }

  stageScale() {
    return this.canvas.getBoundingClientRect().width / STAGE_W;
  }

  onPointerDown(ev) {
    try { this.canvas.setPointerCapture(ev.pointerId); } catch (err) { /* ignore */ }
    this.canvas.focus();
    this.canvas.classList.add('dragging');
    this.drag = { x: ev.clientX, y: ev.clientY, theta: this.theta, phi: this.phi, moved: false };
    ev.preventDefault();
  }

  onPointerMove(ev) {
    if (!this.drag) return;
    const sc = this.stageScale() || 1;
    const dX = (ev.clientX - this.drag.x) / sc;
    const dY = (ev.clientY - this.drag.y) / sc;
    if (dX !== 0 || dY !== 0) this.drag.moved = true;
    const r  = this.S.c.r;
  //let nT   = pMod(this.drag.theta - R2D * dX / r, 360);
  //let nP   =      this.drag.phi   + R2D * dY / r;
  //let nT   = pMod(this.drag.theta - THETA_MIN - R2D * dX / r, 120) + THETA_MIN;
    let nT   = Math.max( Math.min( this.drag.theta + R2D * dX / r, THETA_MAX), THETA_MIN );
    let nP   =                     this.drag.phi   - R2D * dY / r;
    this.setView(nT, nP);
    this.syncControls();
    this.render();
  }

  onPointerUp() {
    if (!this.drag) return;
    const moved = this.drag.moved;
    this.drag   = null;
    this.canvas.classList.remove('dragging');
    if (moved) {
      this.setView(Math.round(this.theta), Math.round(this.phi));
      this.syncControls();
      this.render();
    }
    this.announce();
  }

  onCanvasKey(ev) {
    const step = keyAccel(ev, 1);
    let dTheta = 0;
    let dPhi   = 0;
    switch (ev.key) {
      case 'ArrowLeft':  case 'a': case 'A':  dTheta = -step;     break;
      case 'ArrowRight': case 'd': case 'D':  dTheta =  step;     break;
      case 'ArrowUp':    case 'w': case 'W':  dPhi   =  step;     break;
      case 'ArrowDown':  case 's': case 'S':  dPhi   = -step;     break;
      case 'PageUp':                          dPhi   =  PHI_PAGE; break;
      case 'PageDown':                        dPhi   = -PHI_PAGE; break;
      case 'Home':   dTheta = THETA_MIN - Math.round(this.theta); break;
      case 'End':    dTheta = THETA_MAX - Math.round(this.theta); break;
      default: return;
    }
    ev.preventDefault();
    this.keyed = true;
    this.setView(Math.round(this.theta) + dTheta, Math.round(this.phi) + dPhi);
    this.syncControls();
    this.render();
  }

  onCanvasKeyUp() {
    if (!this.keyed) return;
    this.keyed = false;
    this.announce();
  }
}

/**
 * Order rows by right ascension on a 24-hour circle.
 * Ascending starts just after the largest gap and walks forward.
 * Descending is that sequence reversed. Equal gaps keep the first
 * one found while walking up from the lowest hour.
 */
function sortByRightAscension(rows, descending) {
  const period = 24;
  const indexed = [];
  for (let i = 0; i < rows.length; i++) {
    indexed.push({ row: rows[i], v: pMod(rows[i].ra, period), i: i });
  }
  indexed.sort((a, b) => a.v - b.v || a.i - b.i);
  const n = indexed.length;
  if (n < 2) return indexed.map((x) => x.row);

  let maxGap = -1;
  let cut    = 0;
  for (let i = 0; i < n; i++) {
    const a = indexed[i].v;
    const b = indexed[(i + 1) % n].v;
    const gap = (i === n - 1) ? (b + period - a) : (b - a);
    if (gap > maxGap) {
      maxGap = gap;
      cut    = (i + 1) % n;
    }
  }
  const ordered = [];
  for (let k = 0; k < n; k++) ordered.push(indexed[(cut + k) % n].row);
  if (descending) ordered.reverse();
  return ordered;
}

function boot() {
  const start = () => {
    if (!window.bigDipperApp) window.bigDipperApp = new App();
  };
  const ready = () => {
    if (!allConst) { start(); return; }
    fetch('../foundation/js/kl-unl-constellations.json')
      .then((res) => {
        if (!res.ok) throw new Error('constellation catalog ' + res.status);
        return res.json();
      })
      .then((data) => {
        const list = (data && data.constellations) || [];
        iauFigures = [];
        for (let i = 0; i < list.length; i++) {
          const figure = figureFromConstellation(list[i]);
          if (figure.stars.length) iauFigures.push(figure);
        }
      })
      .catch((err) => {
        console.error(err);
        iauFigures = [];
      })
      .then(start);
  };
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', ready);
  } else {
    ready();
  }
}

boot();

/**
 * Great-circle arc on the celestial sphere between two stars.
 * The arc runs from ARC_INSET to 1 - ARC_INSET of the short separation.
 * Returns null when the stars are coincident or the trimmed arc vanishes.
 */
function greatCircleArc(sphere, style, starA, starB) {
  const p1 = starVector(starA);
  const p2 = starVector(starB);
  const ax = p1.y * p2.z - p2.y * p1.z;
  const ay = p2.x * p1.z - p1.x * p2.z;
  const nz = p1.x * p2.y - p2.x * p1.y;
  const aN = Math.hypot(ax, ay, nz);
  if (aN < 1e-6) return null;

  const arc = new Circle(sphere, style);
  arc.sys    = 1;
  arc.lambda = 0;
  arc.tilt   = Math.acos(clamp(nz / aN, -1, 1));

  let g1, g2;
  const st = Math.sin(arc.tilt);
  if (Math.abs(st) < 1e-6) {
    const sign = (arc.tilt < 1) ? 1 : -1;
    arc.beta = 0;
    g1 = pMod(Math.atan2(sign * p1.y, p1.x), TWO_PI);
    g2 = pMod(Math.atan2(sign * p2.y, p2.x), TWO_PI);
  } else {
    arc.beta = Math.atan2(ax, -ay);
    g1 = pMod(Math.atan2(p1.z / st, p1.cd * Math.cos(p1.ra - arc.beta)), TWO_PI);
    g2 = pMod(Math.atan2(p2.z / st, p2.cd * Math.cos(p2.ra - arc.beta)), TWO_PI);
  }

  let span   = pMod(g2 - g1, TWO_PI);
  let gStart = g1;
  if (span > PI) {
    gStart = g2;
    span   = TWO_PI - span;
  }
  const drawn = span * (1 - 2 * ARC_INSET);
  if (drawn < 1e-4) return null;
  arc.gS = pMod(gStart + ARC_INSET * span, TWO_PI);
  arc.gE = pMod(gStart + span - ARC_INSET * span, TWO_PI);
  arc.doW();
  return arc;
}

function starVector(star) {
  const dec = star.dec * D2R;
  const ra  = star.ra  * H2R;
  const cd  = Math.cos(dec);
  return {
    x: cd * Math.cos(ra),
    y: cd * Math.sin(ra),
    z:      Math.sin(dec),
    cd: cd,
    ra: ra
  };
}
