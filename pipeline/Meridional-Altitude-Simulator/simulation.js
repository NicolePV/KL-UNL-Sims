/* ==========================================================================
   Meridional Altitude Simulator
   HTML5 port of meridaltdiagram.swf (Flash 6 / ActionScript 1).

   Behaviour is a direct translation of the decompiled ActionScript:
     question.as     -- the main controller (onEnterFrame, moveObj, moveText,
                        drawAngles, calcAlt)
     tangDiagram.as  -- the Earth cross-section (setPos, calculatePos)
     SliderV3*.as    -- the sliders (value rounding, min/max, label text)
     objectRadio.as / rangeCheckbox.as -- the radio group and checkboxes

   Every constant, formula and on-screen string below is copied verbatim from
   that source. All drawing maths stays in the ORIGINAL Flash stage
   coordinates (720 x 560, of which the diagram occupies the top 720 x 400);
   CSS scales the canvas, and pointer coordinates are mapped back through that
   scale, so nothing here ever depends on the on-screen size.
   ========================================================================== */

'use strict';

/* --------------------------------------------------------------------------
   Original stage geometry (twips / 20 from the SWF placement matrices).
   The "question" clip sits at (17.1, 17.1) on the stage; the two diagram
   origins below are already in absolute stage coordinates.
   -------------------------------------------------------------------------- */
const STAGE_W = 720;
const STAGE_H = 400;             // the diagram panel; the control strip is HTML

const QUESTION_X = 17.1;
const QUESTION_Y = 17.1;

const MER = { x: 461.1 + QUESTION_X, y: 242.95 + QUESTION_Y };  // horizon diagram
const TAN = { x: 136.1 + QUESTION_X, y: 182.95 + QUESTION_Y };  // Earth cross-section

// Static text anchors (centre-x, baseline-y) taken from the SWF text-field
// bounds. These labels do not move in the original.
const FIXED_LABELS = {
  north:  { x: 344.5 + QUESTION_X, y: 267.85 + QUESTION_Y },  // "N" by merDiag
  south:  { x: 580.7 + QUESTION_X, y: 268.70 + QUESTION_Y },  // "S" by merDiag
  zenith: { x: 462.5 + QUESTION_X, y: 121.70 + QUESTION_Y },  // "Z" by merDiag
  np:     { x: TAN.x -  2,         y: TAN.y - 84.2 },         // "NP" on circle
  sp:     { x: TAN.x -  1,         y: TAN.y + 68.65 },        // "SP" on circle
  eq:     { x: TAN.x - 78,         y: TAN.y -  7.35 }         // "EQ" on circle
};

// Colours. ORIG values are the decimal RGB ints from the ActionScript;
// A11Y values were lightened within the same hue for contrast (ACCESSIBILITY.md).
const COLOR = {
  pole:      '#ffffcc',   // ORIG 16777164  pole_arrow
  equator:   '#ffffff',   // ORIG 16777215  equ_arrow1 / equ_arrow2
  north:     '#33cc99',   // ORIG  3394713  northArrow
  south:     '#66cc33',   // A11Y (ORIG 3381708 = #33990C)  southArrow
  zenith:    '#b3b3b3',   // A11Y (ORIG 10066329 = #999999) zenithArrow
  latWedge:  '#ff6b6b',   // A11Y (ORIG 14156033 = #D80101) _latColor
  decWedge:  '#ffff00',   // ORIG 16776960  _decColor
  sunRange:  '#ff9999',   // ORIG 16751001
  sunEdge:   '#ffb3b3',   // A11Y added outline
  moonRange: '#ff9933',   // ORIG 16750899
  moonEdge:  '#ffc266',   // A11Y added outline
  objLine:   '#ffffff'    // ORIG 16777215, 90% alpha
};

// Declination limits per object, verbatim from question.as onEnterFrame.
const OBJECTS = {
  0: { key: 'none',   label: 'No Object', min: -90,   max: 90   },
  1: { key: 'star',   label: 'Star',      min: -90,   max: 90   },
  2: { key: 'sun',    label: 'Sun',       min: -23.5, max: 23.5 },
  3: { key: 'planet', label: 'Planet',    min: -23.5, max: 23.5 },
  4: { key: 'moon',   label: 'Moon',      min: -29.3, max: 29.3 }
};

const LAT_STEP  = 0.1;   // SliderV3 _minIncrement = 10^-initPrecision, prec = 1
const PAGE_STEP = 10;

// question.as: p.rad = function(deg) { return deg * 0.017453292519943295; }
const rad = (deg) => deg * 0.017453292519943295;

// SliderV3Class.setValue rounds to the slider's precision (1 decimal place).
const round1 = (x) => Math.round(10 * x) / 10;

const clamp = (x, lo, hi) => (x < lo ? lo : (x > hi ? hi : x));

/* --------------------------------------------------------------------------
   Single source of truth. Every pointer, keyboard and control path mutates
   this object and then calls render(); nothing else holds state.
   -------------------------------------------------------------------------- */
const INITIAL_STATE = Object.freeze({
  obj: 0,           // frame_1 on(initialize): _obj = 0
  latitude: 41,     // latSlider initValue = 41
  dec: 23.5,        // decSlider initValue = 23.5
  showSunRange: false,   // FCheckBox initialValue = false
  showMoonRange: false,
  dragging: false
});

let state = Object.assign({}, INITIAL_STATE);

/* --------------------------------------------------------------------------
   Exported art. Bitmaps and vector shapes come straight out of the JPEXS
   export and are reused as files -- never traced or redrawn. Only the art the
   ActionScript builds at runtime (wedges, the zenith line, the object line)
   is reproduced with canvas drawing calls.
   -------------------------------------------------------------------------- */
const ASSETS = {
  arrow:      'assets/arrow.svg',           // shape  84: the tinted arrow
  lines:      'assets/diagram-lines.svg',   // shape 101: dome + axis rules
  circle:     'assets/earth-circle.svg',    // shape  83: r = 60 circle
  axes:       'assets/earth-axes.svg',      // shape  91: polar + equator lines
  rightAngle: 'assets/right-angle.svg',     // shape  87: right-angle tick
  planet:     'assets/planet.png',          // bitmap 116
  moon:       'assets/moon.png',            // bitmap 120
  sun:        'assets/sun.svg',             // shape 124
  star:       'assets/star.svg'             // shape 126
};

const img = {};          // loaded exported assets
const arrowTint = {};    // arrow.svg recoloured per instance (see below)

function loadImage(src) {
  return new Promise((resolve, reject) => {
    const el = new Image();
    el.onload = () => resolve(el);
    el.onerror = () => reject(new Error('Failed to load ' + src));
    el.src = src;
  });
}

/* The arrow is one exported shape (shape 84) that the original tints per
   instance with Color.setRGB. Rather than redraw it, the exported file is
   reused and its single fill/stroke colour is substituted -- which is exactly
   what setRGB did -- producing one crisp, scalable image per colour. */
async function loadTintedArrows(colors) {
  const svgText = await fetch(ASSETS.arrow).then((r) => r.text());
  await Promise.all(colors.map(async (c) => {
    const tinted = svgText.split('#000000').join(c);
    arrowTint[c] = await loadImage('data:image/svg+xml;charset=utf-8,' + encodeURIComponent(tinted));
  }));
}

/* --------------------------------------------------------------------------
   Canvas plumbing. The backing store is the original stage size multiplied by
   the device pixel ratio; the drawing code only ever works in stage units.
   -------------------------------------------------------------------------- */
const canvas = document.getElementById('stage-canvas');
const ctx = canvas.getContext('2d');
const stageEl = document.getElementById('sim-stage');

function sizeCanvas() {
  const dpr = window.devicePixelRatio || 1;
  const w = Math.round(STAGE_W * dpr);
  const h = Math.round(STAGE_H * dpr);
  if (canvas.width !== w || canvas.height !== h) {
    canvas.width = w;
    canvas.height = h;
  }
  ctx.setTransform(dpr, 0, 0, dpr, 0, 0);
}

/* Stage units -> CSS pixels, used to place the HTML label overlays and to map
   pointer positions back into stage coordinates. */
function stageScale() {
  return stageEl.getBoundingClientRect().width / STAGE_W;
}

/* --------------------------------------------------------------------------
   Drawing helpers
   -------------------------------------------------------------------------- */

/* The `arrow` symbol's own origin is its tail; the exported shape spans
   x 0.3 .. 99.7, y -4.7 .. 4.7 in symbol coordinates. */
function drawArrow(mat, color) {
  const a = arrowTint[color];
  if (!a) return;
  ctx.save();
  ctx.transform(mat[0], mat[1], mat[2], mat[3], mat[4], mat[5]);
  ctx.drawImage(a, 0.3, -4.7, 99.4, 9.4);
  ctx.restore();
}

function drawRightAngle(mat) {
  if (!img.rightAngle) return;
  ctx.save();
  ctx.transform(mat[0], mat[1], mat[2], mat[3], mat[4], mat[5]);
  ctx.drawImage(img.rightAngle, -11.95, -13.0, 23.95, 26.0);
  ctx.restore();
}

/* sprite 89: the celestial-pole arrow plus the celestial-equator arrow and
   their right-angle tick. Drawn in the group's own coordinates; the caller
   has already translated and rotated. */
function drawPoleGroup(latitude) {
  if (latitude >= 0) {
    // equ_arrow2 + right2 visible when the observer is in the north
    drawArrow([0.00015, 1.21999, -0.99997, 0.00012, 0, -1], COLOR.equator);
    drawRightAngle([0.54617, 0, 0, 0.49911, 6, 6]);
  } else {
    drawArrow([0, -1.21951, 1, 0, 0, 1], COLOR.equator);
    drawRightAngle([0.54649, 0, 0, -0.50182, 6, -6]);
  }
  drawArrow([1.21951, 0, 0, 1, -1, 0], COLOR.pole);
}

/* sprite 90: south / north / zenith arrows plus the pole group. */
function drawArrowGroup(originX, originY, groupRotationDeg, poleRotationDeg, latitude) {
  ctx.save();
  ctx.translate(originX, originY);
  ctx.rotate(rad(groupRotationDeg));

  drawArrow([1.21951, 0, 0, 1, -1, -1.2], COLOR.south);        // southArrow
  drawArrow([-1.21951, 0, 0, -1, 1, -1.2], COLOR.north);       // northArrow
  drawArrow([0, -1.24899, 1, 0, 0, 1], COLOR.zenith);          // zenithArrow

  ctx.save();
  ctx.translate(0, -2.9);                                      // poleArrow placement
  ctx.rotate(rad(poleRotationDeg));
  drawPoleGroup(latitude);
  ctx.restore();

  ctx.restore();
}

/* Flash's curveTo is a quadratic Bezier whose control point the source picks
   on the arc's mid-angle. Reproducing it as a quadratic (rather than as a
   true ctx.arc) keeps the rendered wedge geometry identical to the original. */
function fillWedge(cx, cy, p1, ctrl, p2, color, alpha, edge) {
  ctx.save();
  ctx.beginPath();
  ctx.moveTo(cx, cy);
  ctx.lineTo(p1[0], p1[1]);
  ctx.quadraticCurveTo(ctrl[0], ctrl[1], p2[0], p2[1]);
  ctx.lineTo(cx, cy);
  ctx.closePath();
  ctx.globalAlpha = alpha;
  ctx.fillStyle = color;
  ctx.fill();
  ctx.globalAlpha = 1;
  if (edge) {
    // Added for WCAG 1.4.11: the translucent fill alone is below 3:1.
    ctx.strokeStyle = edge;
    ctx.lineWidth = 1.5;
    ctx.stroke();
  }
  ctx.restore();
}

// Point at `deg` on a circle of radius r about (ox, oy), using the source's
// screen convention: y is negated (AS writes `y - r * sin`).
const ptFlip = (ox, oy, r, deg) => [ox + r * Math.cos(rad(deg)), oy - r * Math.sin(rad(deg))];
// The object placement in moveObj uses un-negated sin.
const ptPlain = (ox, oy, r, deg) => [ox + r * Math.cos(rad(deg)), oy + r * Math.sin(rad(deg))];

/* --------------------------------------------------------------------------
   Derived quantities -- the same values the ActionScript recomputes each frame
   -------------------------------------------------------------------------- */
function derive(s) {
  const lat = s.latitude;

  // tangDiagram.setPos(): angle = -lat + 90; arrow offset 60px from centre.
  const angle = -lat + 90;
  const arrowX = 60 * Math.cos(rad(-lat));
  const arrowY = 60 * Math.sin(rad(-lat));

  // tangDiagram.onEnterFrame(): _poleAng
  const poleAng = angle <= 90 ? 270 - angle : 90 - angle;

  // question.as: merDiag.poleArrow._rotation
  const merPoleRotation = angle <= 90 ? 180 + lat : lat;

  // question.as moveObj(): the object's angular position about merDiag.
  const objAngle = lat - 90 - s.dec;
  const objVisible = s.obj !== 0 && !(objAngle < -180 || objAngle > 0);

  return { lat, angle, arrowX, arrowY, poleAng, merPoleRotation, objAngle, objVisible };
}

/* --------------------------------------------------------------------------
   calcAlt() -- verbatim translation, including the exact string forms.
   The original builds e.g. "90-41+23.5= 72.5" and, past 90 degrees, shows a
   separate "180-(" field in front of "90-41+23.5) = 107.5".
   -------------------------------------------------------------------------- */
function calcAlt(s) {
  const latR = round1(s.latitude);
  const decR = round1(s.dec);
  const latAbs = String(Math.abs(latR));
  const decAbs = String(Math.abs(decR));

  let altAns, wrapped;

  if (latR >= 0) {
    if (90 - latR + decR <= 90) {
      wrapped = false;
      altAns = round1(90 - latR + decR);
    } else {
      wrapped = true;
      altAns = round1(180 - (90 - latR + decR));
    }
  } else {
    if (90 + latR - decR <= 90) {
      wrapped = false;
      altAns = round1(90 + latR - decR);
    } else {
      wrapped = true;
      altAns = round1(180 - (90 + latR - decR));
    }
  }

  // The "180-(" prefix is suppressed when there is no object on screen.
  const showOneEighty = wrapped && s.obj !== 0;

  // Rebuild the same terms the original colours by character index: the
  // latitude magnitude in the latitude colour, the declination magnitude in
  // the declination colour.
  const LAT = `\\color{${'#c00000'}}{${latAbs}}`;
  const DEC = `\\color{${'#7a5c00'}}{${decAbs}}`;

  let inner, spokenInner;
  if (latR >= 0) {
    if (decR >= 0) {
      inner = `90 - ${LAT} + ${DEC}`;
      spokenInner = `90 degrees minus latitude ${latAbs} degrees plus declination ${decAbs} degrees`;
    } else {
      inner = `90 - ${LAT} - ${DEC}`;
      spokenInner = `90 degrees minus latitude ${latAbs} degrees minus declination ${decAbs} degrees`;
    }
  } else {
    if (decR >= 0) {
      inner = `90 - ${LAT} - ${DEC}`;
      spokenInner = `90 degrees minus latitude ${latAbs} degrees minus declination ${decAbs} degrees`;
    } else {
      inner = `90 - ${LAT} + ${DEC}`;
      spokenInner = `90 degrees minus latitude ${latAbs} degrees plus declination ${decAbs} degrees`;
    }
  }

  const latex = showOneEighty
    ? `180 - \\left( ${inner} \\right) = ${altAns}^\\circ`
    : `${inner} = ${altAns}^\\circ`;

  const spoken = showOneEighty
    ? `Meridional altitude equals 180 degrees minus, open bracket, ${spokenInner}, close bracket, equals ${altAns} degrees.`
    : `Meridional altitude equals ${spokenInner}, equals ${altAns} degrees.`;

  return { altAns, latex, spoken, latR, decR };
}

/* --------------------------------------------------------------------------
   MathJax helpers. Every symbol, variable and number with a unit in this UI is
   typeset by MathJax, never painted onto the canvas and never hand-built from
   HTML sub/sup -- so right-clicking any of it opens the MathJax menu.
   Typesetting is coalesced into one animation frame and skipped when the LaTeX
   has not actually changed, which keeps dragging smooth.
   -------------------------------------------------------------------------- */
const mathPending = new Map();
const mathCurrent = new Map();
let mathFrame = 0;

function setMath(id, latex) {
  if (mathCurrent.get(id) === latex) return;
  mathCurrent.set(id, latex);
  mathPending.set(id, latex);
  if (!mathFrame) {
    // A timeout, not requestAnimationFrame: rAF is throttled to a stop in
    // background tabs, which would leave the maths permanently un-typeset.
    // Everything queued by one render() still coalesces into a single pass.
    mathFrame = setTimeout(flushMath, 0);
  }
}

function flushMath() {
  mathFrame = 0;
  if (!mathPending.size) return;
  const nodes = [];
  mathPending.forEach((latex, id) => {
    const el = document.getElementById(id);
    if (!el) return;
    el.innerHTML = '\\(' + latex + '\\)';
    nodes.push(el);
  });
  mathPending.clear();
  if (window.MathJax && MathJax.typesetPromise) {
    MathJax.typesetPromise(nodes)
      .then(() => nodes.forEach(stripMathTabStops))
      .catch((err) => console.error(err));
  }
}

/* MathJax v3 does not add tabindex, but some builds leave the output focusable.
   Typeset maths is display-only, so make sure it never becomes a tab stop.
   (aria-hidden is deliberately NOT used: the spoken form is supplied by the
   paired .sr-only description instead.) */
function stripMathTabStops(root) {
  root.querySelectorAll('[tabindex]').forEach((el) => el.setAttribute('tabindex', '-1'));
}

/* --------------------------------------------------------------------------
   Label overlay placement. Anchors come from question.as moveText(); the HTML
   spans are centred on the same anchors the original centred its text fields on.
   -------------------------------------------------------------------------- */
function placeLabel(id, x, y, scale, visible) {
  const el = document.getElementById(id);
  if (!el) return;
  if (visible === false) {
    el.hidden = true;
    return;
  }
  el.hidden = false;
  el.style.transform = `translate(${x * scale}px, ${y * scale}px) translate(-50%, -82%)`;
}

function updateLabels(s, d) {
  const scale = stageScale();
  const poleText = d.angle <= 90 ? '\\mathrm{NCP}' : '\\mathrm{SCP}';

  setMath('lbl-pole', poleText);
  setMath('lbl-pole-2', poleText);
  setMath('lbl-equator', '\\mathrm{CE}');
  setMath('lbl-north', '\\mathrm{N}');
  setMath('lbl-south', '\\mathrm{S}');
  setMath('lbl-zenith', '\\mathrm{Z}');
  setMath('lbl-zenith-2', '\\mathrm{Z}');
  setMath('lbl-north-2', '\\mathrm{N}');
  setMath('lbl-south-2', '\\mathrm{S}');
  setMath('lbl-np', '\\mathrm{NP}');
  setMath('lbl-sp', '\\mathrm{SP}');
  setMath('lbl-eq', '\\mathrm{EQ}');

  // Before first layout (or while the stage is hidden) the measured width is
  // zero; positioning against that would stack every label in one corner.
  // The ResizeObserver re-renders as soon as the stage has a real width.
  if (!(scale > 0)) return;

  // moveText(): pole label, 130px from merDiag
  const poleAnchor = d.lat >= 0
    ? ptPlain(MER.x, MER.y, 130, d.lat + 180)
    : ptPlain(MER.x, MER.y, 130, d.lat);
  placeLabel('lbl-pole', poleAnchor[0], poleAnchor[1], scale);

  // moveText(): celestial-equator label, 130px from merDiag
  const equAnchor = ptPlain(MER.x, MER.y, 130, d.lat - 90);
  placeLabel('lbl-equator', equAnchor[0], equAnchor[1], scale);

  // Fixed labels around merDiag. N and S are hidden at the poles, where the
  // horizon's north/south directions are undefined (question.as).
  const poleCase = (d.lat === 90 || d.lat === -90);
  placeLabel('lbl-north', FIXED_LABELS.north.x, FIXED_LABELS.north.y, scale, !poleCase);
  placeLabel('lbl-south', FIXED_LABELS.south.x, FIXED_LABELS.south.y, scale, !poleCase);
  placeLabel('lbl-zenith', FIXED_LABELS.zenith.x, FIXED_LABELS.zenith.y, scale);

  // moveText(): labels that follow the observer on the cross-section
  const zAnchor = ptFlip(TAN.x, TAN.y, 180, d.lat);
  placeLabel('lbl-zenith-2', zAnchor[0], zAnchor[1], scale);

  const nAnchor = ptFlip(TAN.x + d.arrowX, TAN.y + d.arrowY, 130, 90 + d.lat);
  placeLabel('lbl-north-2', nAnchor[0], nAnchor[1], scale);

  const sAnchor = ptFlip(TAN.x + d.arrowX, TAN.y + d.arrowY, 130, -90 + d.lat);
  placeLabel('lbl-south-2', sAnchor[0], sAnchor[1], scale);

  const pole2X = TAN.x + d.arrowX + 10;
  const pole2Y = (d.lat >= 0 ? -130 : 110) + TAN.y + d.arrowY;
  placeLabel('lbl-pole-2', pole2X, pole2Y, scale);

  // Static NP / SP / EQ inside the cross-section
  placeLabel('lbl-np', FIXED_LABELS.np.x, FIXED_LABELS.np.y, scale);
  placeLabel('lbl-sp', FIXED_LABELS.sp.x, FIXED_LABELS.sp.y, scale);
  placeLabel('lbl-eq', FIXED_LABELS.eq.x, FIXED_LABELS.eq.y, scale);

  // The observer handle rides on the same anchor as the arrow group.
  const handle = document.getElementById('observer-handle');
  handle.style.transform =
    `translate(${(TAN.x + d.arrowX) * scale}px, ${(TAN.y + d.arrowY) * scale}px)`;
}

/* --------------------------------------------------------------------------
   Canvas render -- draw order follows the original's depth order. Clips the
   ActionScript creates at runtime (depths 1-7) sit above every timeline object,
   which is why the wedges and range overlays are painted last.
   -------------------------------------------------------------------------- */
function renderCanvas(s, d) {
  sizeCanvas();

  // Background: the exported #333333 panel rectangle (a single solid fill).
  ctx.fillStyle = '#333333';
  ctx.fillRect(0, 0, STAGE_W, STAGE_H);

  // Static line art (shape 101): the horizon dome and the diagram rules.
  // Anything below y = 400 belonged to the Flash control strip and is clipped
  // away by the canvas, exactly as intended.
  if (img.lines) ctx.drawImage(img.lines, 16.9, 136.65, 684.2, 405.45);

  // --- merDiag: the observer's horizon diagram (right) ---
  drawArrowGroup(MER.x, MER.y, 0, d.merPoleRotation, d.lat);

  // --- tanDiag: the Earth cross-section (left) ---
  if (img.circle) ctx.drawImage(img.circle, TAN.x - 60.5, TAN.y - 60.5, 121, 121);
  if (img.axes)   ctx.drawImage(img.axes, TAN.x - 60.45, TAN.y - 70.5, 121, 141);

  // tangDiagram.onEnterFrame(): zenithLine, 2px white at 90% alpha
  ctx.save();
  ctx.globalAlpha = 0.9;
  ctx.strokeStyle = COLOR.objLine;
  ctx.lineWidth = 2;
  ctx.beginPath();
  ctx.moveTo(TAN.x, TAN.y);
  ctx.lineTo(TAN.x + d.arrowX, TAN.y + d.arrowY);
  ctx.stroke();
  ctx.restore();

  drawArrowGroup(TAN.x + d.arrowX, TAN.y + d.arrowY, d.angle, d.poleAng, d.lat);

  // --- the selected object ---
  if (s.obj !== 0 && d.objVisible) {
    const [ox, oy] = ptPlain(MER.x, MER.y, 123, d.objAngle);
    ctx.save();
    ctx.translate(ox, oy);
    if (s.obj === 1 && img.star) {
      ctx.scale(1.0679321, 1.0705566);
      ctx.drawImage(img.star, -6.95, -6.7, 13.95, 13.45);
    } else if (s.obj === 2 && img.sun) {
      ctx.scale(0.074920654, 0.07495117);
      ctx.drawImage(img.sun, -100.5, -100.5, 201, 201);
    } else if (s.obj === 3 && img.planet) {
      ctx.scale(0.081954956, 0.081954956);
      ctx.drawImage(img.planet, -139, -187.5, 278, 375);
    } else if (s.obj === 4 && img.moon) {
      ctx.scale(0.18518066, 0.18518066);
      ctx.drawImage(img.moon, -40.5, -40.5, 81, 81);
    }
    ctx.restore();
  }

  // --- runtime clips, in their original depth order (1 through 7) ---

  // depth 1: decAngClip -- the declination wedge at merDiag
  if (d.objVisible) {
    const p1 = ptFlip(MER.x, MER.y, 30, 90 - d.lat);
    const p2 = ptFlip(MER.x, MER.y, 30, 90 - d.lat + s.dec);
    const c  = ptFlip(MER.x, MER.y, 30, 90 - d.lat + s.dec / 2);
    fillWedge(MER.x, MER.y, p1, c, p2, COLOR.decWedge, 0.8);
  }

  // depth 2: objLine -- 115px sight line from merDiag to the object
  if (d.objVisible) {
    const [lx, ly] = ptPlain(MER.x, MER.y, 115, d.objAngle);
    ctx.save();
    ctx.globalAlpha = 0.9;
    ctx.strokeStyle = COLOR.objLine;
    ctx.lineWidth = 2;
    ctx.beginPath();
    ctx.moveTo(MER.x, MER.y);
    ctx.lineTo(lx, ly);
    ctx.stroke();
    ctx.restore();
  }

  // depth 3: latAngClip_ce_z -- latitude between equator and zenith (cross-section)
  {
    const p1 = [TAN.x + 30, TAN.y];
    const p2 = ptFlip(TAN.x, TAN.y, 30, d.lat);
    const c  = ptFlip(TAN.x, TAN.y, 30, d.lat / 2);
    fillWedge(TAN.x, TAN.y, p1, c, p2, COLOR.latWedge, 0.8);
  }

  // depth 4: latAngClip_cp_hor -- latitude at the observer, pole to horizon
  {
    const px = TAN.x + d.arrowX;
    const py = TAN.y + d.arrowY;
    let p1, p2, c;
    if (d.lat >= 0) {
      p1 = [px, py - 30];
      p2 = ptFlip(px, py, 30, 90 + d.lat);
      c  = ptFlip(px, py, 30, 90 + d.lat / 2);
    } else {
      p1 = [px, py + 30];
      p2 = ptFlip(px, py, 30, -90 + d.lat);
      c  = ptFlip(px, py, 30, -90 + d.lat / 2);
    }
    fillWedge(px, py, p1, c, p2, COLOR.latWedge, 0.8);
  }

  // depth 5: latAngClip_hor_cp -- latitude on the horizon diagram
  {
    let p1, p2, c;
    if (d.lat >= 0) {
      p1 = [MER.x - 30, MER.y];
      p2 = ptFlip(MER.x, MER.y, 30, 180 - d.lat);
      c  = ptFlip(MER.x, MER.y, 30, 180 - d.lat / 2);
    } else {
      p1 = [MER.x + 30, MER.y];
      p2 = ptFlip(MER.x, MER.y, 30, -d.lat);
      c  = ptFlip(MER.x, MER.y, 30, -d.lat / 2);
    }
    fillWedge(MER.x, MER.y, p1, c, p2, COLOR.latWedge, 0.8);
  }

  // depth 6: sunRange -- the band the Sun/planets can occupy (+/- 23.5 deg)
  if (s.showSunRange) {
    let ctrl, p1, p2;
    if (d.lat > 66.5) {
      ctrl = ptFlip(MER.x, MER.y, 125, (90 - d.lat + 23.5) / 2);
      p1 = [MER.x + 120, MER.y];
      p2 = ptFlip(MER.x, MER.y, 120, 113.5 - d.lat);
    } else if (d.lat < -66.5) {
      ctrl = ptFlip(MER.x, MER.y, 125, 90 + (90 - d.lat - 23.5) / 2);
      p1 = ptFlip(MER.x, MER.y, 120, 66.5 - d.lat);
      p2 = [MER.x - 120, MER.y];
    } else {
      ctrl = ptFlip(MER.x, MER.y, 135, 90 - d.lat);
      p1 = ptFlip(MER.x, MER.y, 120, 66.5 - d.lat);
      p2 = ptFlip(MER.x, MER.y, 120, 113.5 - d.lat);
    }
    fillWedge(MER.x, MER.y, p1, ctrl, p2, COLOR.sunRange, 0.4, COLOR.sunEdge);
  }

  // depth 7: moonRange -- the band the Moon can occupy (+/- 29.3 deg)
  if (s.showMoonRange) {
    let ctrl, p1, p2;
    if (d.lat > 60.7) {
      ctrl = ptFlip(MER.x, MER.y, 128, (90 - d.lat + 29.3) / 2);
      p1 = [MER.x + 123, MER.y];
      p2 = ptFlip(MER.x, MER.y, 123, 119.3 - d.lat);
    } else if (d.lat < -60.7) {
      ctrl = ptFlip(MER.x, MER.y, 128, 90 + (90 - d.lat - 29.3) / 2);
      p1 = ptFlip(MER.x, MER.y, 123, 60.7 - d.lat);
      p2 = [MER.x - 123, MER.y];
    } else {
      ctrl = ptFlip(MER.x, MER.y, 138, 90 - d.lat);
      p1 = ptFlip(MER.x, MER.y, 123, 60.3 - d.lat);
      p2 = ptFlip(MER.x, MER.y, 123, 119.3 - d.lat);
    }
    fillWedge(MER.x, MER.y, p1, ctrl, p2, COLOR.moonRange, 0.4, COLOR.moonEdge);
  }
}

/* --------------------------------------------------------------------------
   Spoken value strings. Every number that has a unit is announced with its
   quantity name AND its unit -- never a bare number.
   -------------------------------------------------------------------------- */
function latitudeSpoken(lat) {
  const v = round1(lat);
  if (v === 0) return 'Latitude 0 degrees, on the equator';
  return `Latitude ${Math.abs(v)} degrees ${v > 0 ? 'north' : 'south'}`;
}

function declinationSpoken(dec) {
  const v = round1(dec);
  if (v === 0) return 'Declination 0 degrees';
  return `Declination ${v < 0 ? 'minus ' : ''}${Math.abs(v)} degrees`;
}

// SliderV3forLat.setValue(): "41°" + " N" / " S" (empty at zero)
function latitudeLatex(lat) {
  const v = round1(lat);
  const dir = v > 0 ? '\\ \\mathrm{N}' : (v < 0 ? '\\ \\mathrm{S}' : '');
  return `${Math.abs(v)}^\\circ${dir}`;
}

// SliderV3forDec.setValue(): value + "°"
function declinationLatex(dec) {
  return `${round1(dec)}^\\circ`;
}

/* --------------------------------------------------------------------------
   render() -- the one place that redraws the canvas, syncs every DOM control
   and refreshes the description of the diagram.
   -------------------------------------------------------------------------- */
const els = {
  latRange:  document.getElementById('lat-range'),
  latValue:  document.getElementById('lat-value'),
  latMin:    document.getElementById('lat-min'),
  latMax:    document.getElementById('lat-max'),
  decRow:    document.getElementById('dec-row'),
  decRange:  document.getElementById('dec-range'),
  decValue:  document.getElementById('dec-value'),
  decMin:    document.getElementById('dec-min'),
  decMax:    document.getElementById('dec-max'),
  sunRange:  document.getElementById('sun-range'),
  moonRange: document.getElementById('moon-range'),
  handle:    document.getElementById('observer-handle'),
  eqn:       document.getElementById('altitude-eqn'),
  eqnSr:     document.getElementById('altitude-eqn-sr'),
  stageDesc: document.getElementById('stage-desc'),
  live:      document.getElementById('live-region')
};

function render() {
  const s = state;
  const d = derive(s);
  const limits = OBJECTS[s.obj];

  renderCanvas(s, d);
  updateLabels(s, d);

  // --- latitude control ---
  const latText = latitudeSpoken(s.latitude);
  els.latRange.value = String(round1(s.latitude));
  els.latRange.setAttribute('aria-valuetext', latText);
  setMath('lat-value', latitudeLatex(s.latitude));
  setMath('lat-min', '90^\\circ\\ \\mathrm{S}');   // SliderV3forLat.setMin
  setMath('lat-max', '90^\\circ\\ \\mathrm{N}');   // SliderV3forLat.setMax

  els.handle.setAttribute('aria-valuenow', String(round1(s.latitude)));
  els.handle.setAttribute('aria-valuetext', latText);

  // --- declination control ---
  els.decRow.hidden = (s.obj === 0);
  if (s.obj !== 0) {
    els.decRange.min = String(limits.min);
    els.decRange.max = String(limits.max);
    els.decRange.value = String(round1(s.dec));
    els.decRange.setAttribute('aria-valuetext', declinationSpoken(s.dec));
    setMath('dec-value', declinationLatex(s.dec));
    setMath('dec-min', `${limits.min}^\\circ`);   // SliderV3forDec.setMin
    setMath('dec-max', `${limits.max}^\\circ`);   // SliderV3forDec.setMax
  }

  els.sunRange.checked = s.showSunRange;
  els.moonRange.checked = s.showMoonRange;

  // --- meridional altitude readout ---
  if (s.obj === 0) {
    // The original hides the altitude field entirely when no object is selected.
    // A short prose hint (not maths) takes its place so the box is not just blank.
    if (mathCurrent.get('altitude-eqn') !== null) {
      mathCurrent.set('altitude-eqn', null);
      els.eqn.textContent = 'Select an object to see its meridional altitude.';
    }
    els.eqnSr.textContent = 'Select an object to see its meridional altitude.';
  } else {
    const alt = calcAlt(s);
    setMath('altitude-eqn', alt.latex);
    els.eqnSr.textContent = alt.spoken;
  }

  els.stageDesc.textContent = describeDiagram(s, d);
}

/* A continuously-updated text equivalent of the canvas, so someone working by
   audio alone gets the same "what is happening" a sighted user sees. */
function describeDiagram(s, d) {
  const parts = [];
  const poleName = d.angle <= 90 ? 'north celestial pole' : 'south celestial pole';
  parts.push(`${latitudeSpoken(s.latitude)}.`);
  parts.push(
    `On the horizon diagram the ${poleName} stands ` +
    `${Math.abs(round1(s.latitude))} degrees above the ` +
    `${s.latitude >= 0 ? 'north' : 'south'} horizon, and the celestial equator ` +
    `crosses the meridian ${round1(90 - Math.abs(s.latitude))} degrees above the ` +
    `${s.latitude >= 0 ? 'south' : 'north'} horizon.`
  );

  if (s.obj === 0) {
    parts.push('No object is selected.');
  } else {
    const alt = calcAlt(s);
    parts.push(`${OBJECTS[s.obj].label} selected, ${declinationSpoken(s.dec)}.`);
    if (d.objVisible) {
      parts.push(`Its meridional altitude is ${alt.altAns} degrees.`);
    } else {
      parts.push(
        `At this latitude and declination the ${OBJECTS[s.obj].label.toLowerCase()} ` +
        `never crosses the visible meridian, so it is not shown.`
      );
    }
  }

  if (s.showSunRange) parts.push('The Sun and planet declination range is shaded.');
  if (s.showMoonRange) parts.push('The Moon declination range is shaded.');

  return parts.join(' ');
}

/* Announcements are made on commit -- on release, on a keystroke, on a control
   change -- rather than on every pointer tick, so the live region is not flooded. */
function announce(message) {
  els.live.textContent = '';
  // Re-filling the region on a later task makes both NVDA and VoiceOver
  // re-read an otherwise-identical string.
  setTimeout(() => { els.live.textContent = message; }, 0);
}

function announceState() {
  announce(describeDiagram(state, derive(state)));
}

/* --------------------------------------------------------------------------
   Latitude changes. Pointer drag, the slider and the arrow keys all funnel
   through here, so every path updates exactly the same state.
   -------------------------------------------------------------------------- */
function setLatitude(value) {
  state.latitude = round1(clamp(value, -90, 90));
  render();
}

function setDeclination(value) {
  const limits = OBJECTS[state.obj];
  state.dec = round1(clamp(value, limits.min, limits.max));
  render();
}

function setObject(objValue) {
  state.obj = objValue;
  // question.as clamps the declination into the new object's range.
  const limits = OBJECTS[objValue];
  state.dec = clamp(state.dec, limits.min, limits.max);
  render();
}

/* --------------------------------------------------------------------------
   Pointer drag on the observer handle.
   tangDiagram.calculatePos(): angle = degrees(atan2(y, x)) + 90, with x
   clamped to >= 0 -- which makes latitude = -degrees(atan2(y, x)).
   -------------------------------------------------------------------------- */
function latitudeFromPointer(clientX, clientY) {
  const rect = canvas.getBoundingClientRect();
  const scale = STAGE_W / rect.width;
  let x = (clientX - rect.left) * scale - TAN.x;
  const y = (clientY - rect.top) * scale - TAN.y;
  if (x < 0) x = 0;                       // the source's own clamp
  return -(Math.atan2(y, x) * 57.29577951308232);
}

els.handle.addEventListener('pointerdown', (event) => {
  // Clicking or tapping the object also focuses it, so the arrow keys work
  // immediately without tabbing first.
  els.handle.focus();
  els.handle.setPointerCapture(event.pointerId);
  state.dragging = true;
  event.preventDefault();
});

els.handle.addEventListener('pointermove', (event) => {
  if (!state.dragging) return;
  setLatitude(latitudeFromPointer(event.clientX, event.clientY));
  event.preventDefault();
});

function endDrag(event) {
  if (!state.dragging) return;
  state.dragging = false;
  if (els.handle.hasPointerCapture(event.pointerId)) {
    els.handle.releasePointerCapture(event.pointerId);
  }
  announceState();          // announce on release, not on every tick
}

els.handle.addEventListener('pointerup', endDrag);
els.handle.addEventListener('pointercancel', endDrag);

/* Keyboard equivalent of the drag: focus the handle, then steer with arrows. */
els.handle.addEventListener('keydown', (event) => {
  let next = state.latitude;
  let handled = true;

  switch (event.key) {
    case 'ArrowUp':
    case 'ArrowRight': next += LAT_STEP; break;
    case 'ArrowDown':
    case 'ArrowLeft':  next -= LAT_STEP; break;
    case 'PageUp':     next += PAGE_STEP; break;
    case 'PageDown':   next -= PAGE_STEP; break;
    case 'Home':       next = -90; break;
    case 'End':        next = 90; break;
    default: handled = false;
  }

  if (!handled) return;     // Tab and everything else still behave normally
  event.preventDefault();
  setLatitude(next);
  announce(latitudeSpoken(state.latitude) + '.');
});

/* Mouse wheel over the focused handle nudges it by the same step. */
els.handle.addEventListener('wheel', (event) => {
  if (document.activeElement !== els.handle) return;
  event.preventDefault();
  setLatitude(state.latitude + (event.deltaY < 0 ? LAT_STEP : -LAT_STEP));
  announce(latitudeSpoken(state.latitude) + '.');
}, { passive: false });

/* --------------------------------------------------------------------------
   Sliders. Native <input type="range"> supplies arrows, Page keys and
   Home/End for free; the wheel handler adds the required wheel behaviour.
   -------------------------------------------------------------------------- */
function wireSlider(input, apply, spoken, step) {
  input.addEventListener('input', () => {
    apply(parseFloat(input.value));
  });

  // Announce on commit rather than on every intermediate value.
  input.addEventListener('change', () => announce(spoken() + '.'));
  input.addEventListener('keyup', (event) => {
    if (event.key.startsWith('Arrow') || event.key.startsWith('Page') ||
        event.key === 'Home' || event.key === 'End') {
      announce(spoken() + '.');
    }
  });

  input.addEventListener('wheel', (event) => {
    if (document.activeElement !== input) return;
    event.preventDefault();
    const current = parseFloat(input.value);
    apply(current + (event.deltaY < 0 ? step : -step));
    announce(spoken() + '.');
  }, { passive: false });
}

wireSlider(els.latRange, setLatitude, () => latitudeSpoken(state.latitude), LAT_STEP);
wireSlider(els.decRange, setDeclination, () => declinationSpoken(state.dec), LAT_STEP);

/* --------------------------------------------------------------------------
   Object radios and range checkboxes
   -------------------------------------------------------------------------- */
document.querySelectorAll('input[name="object"]').forEach((radio) => {
  radio.addEventListener('change', () => {
    if (!radio.checked) return;
    setObject(parseInt(radio.value, 10));
    announceState();
  });
});

els.sunRange.addEventListener('change', () => {
  state.showSunRange = els.sunRange.checked;
  render();
  announce(state.showSunRange
    ? 'Sun and planet declination range shown.'
    : 'Sun and planet declination range hidden.');
});

els.moonRange.addEventListener('change', () => {
  state.showMoonRange = els.moonRange.checked;
  render();
  announce(state.showMoonRange
    ? 'Moon declination range shown.'
    : 'Moon declination range hidden.');
});

/* --------------------------------------------------------------------------
   Reset comes from the shared masthead's "sim-reset" event. No second Reset
   button is added here.
   -------------------------------------------------------------------------- */
document.addEventListener('sim-reset', () => {
  state = Object.assign({}, INITIAL_STATE);
  document.getElementById('obj-none').checked = true;
  els.decRange.value = String(INITIAL_STATE.dec);
  els.latRange.value = String(INITIAL_STATE.latitude);
  render();
  announce('Simulation reset. ' + describeDiagram(state, derive(state)));
});

/* --------------------------------------------------------------------------
   Keep label overlays aligned when the stage is resized or the page zoomed.
   -------------------------------------------------------------------------- */
const resizeObserver = new ResizeObserver(() => render());
resizeObserver.observe(stageEl);
window.addEventListener('resize', render);

/* --------------------------------------------------------------------------
   Startup. klunlInitEqn is the foundation's designated initialisation hook;
   redefining it here supersedes the default, as kl-unl.js intends.
   -------------------------------------------------------------------------- */
window.klunlInitEqn = function () {
  render();
};

async function start() {
  try {
    const [lines, circle, axes, rightAngle, planet, moon, sun, star] = await Promise.all([
      loadImage(ASSETS.lines),
      loadImage(ASSETS.circle),
      loadImage(ASSETS.axes),
      loadImage(ASSETS.rightAngle),
      loadImage(ASSETS.planet),
      loadImage(ASSETS.moon),
      loadImage(ASSETS.sun),
      loadImage(ASSETS.star)
    ]);
    Object.assign(img, { lines, circle, axes, rightAngle, planet, moon, sun, star });

    await loadTintedArrows([
      COLOR.pole, COLOR.equator, COLOR.north, COLOR.south, COLOR.zenith
    ]);
  } catch (err) {
    console.error('Meridional Altitude Simulator: asset load failed.', err);
  }

  if (window.MathJax && MathJax.startup && MathJax.startup.promise) {
    MathJax.startup.promise.then(() => window.klunlInitEqn());
  } else {
    window.klunlInitEqn();
  }
  render();
}

start();
