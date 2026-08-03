/* ============================================================================
   Phase Positions Demonstrator -- HTML5 port of phaseDemonstrator.swf (Flash / AS1)

   Behaviour model
   ---------------
   A star sits at the centre of a black "orbital view". Two planets orbit it and
   can be dragged anywhere on the field. What each planet looks like as seen from
   the OTHER planet is drawn as a lit/dark phase disc in the right-hand "Disc
   Appearances" column. Dragging one planet within a snapping distance of the
   other makes it a moon of that planet (locked at a fixed separation); dragging a
   moon away frees it again. Holding Shift while dragging keeps a planet in its
   current circular orbit. The star cannot be approached closer than a minimum
   separation, and neither object can leave the field. A "show orbits" checkbox
   draws each object's orbit circle, and each disc has a hide/show toggle.

   Source of truth for behaviour: the decompiled ActionScript, chiefly
     scripts/Phase Demonstrator.as   -- the controller (setPlanetPosition,
                                        updatePhases, updateOrbits, panel titles)
     scripts/Draggable Planet.as     -- the disc + drag handlers
     scripts/Phase Panel.as          -- setPhaseAngle, the phase-disc drawing
   Every constant below is copied verbatim from those files; see
   CONVERSION_NOTES.md for the full AS -> JS mapping.
============================================================================ */

(function () {
  'use strict';

  var PI     = 3.141592653589793;
  var TWO_PI = 6.283185307179586;
  var DEG    = 57.29577951308232;   // rad -> deg

  /* ==========================================================================
     Constants -- verbatim from the ActionScript
     ========================================================================== */

  /* Phase Demonstrator.as prototype properties */
  var MOON_DIST = 30;   // p.moonDistance
  var MOON_SNAP = 42;   // p.moonSnappingDistance
  var SUN_SEP   = 50;   // p.sunSeparation
  var DRAG_MARGIN = 20; // p.dragMargin

  /* Draggable Planet.as prototype properties */
  var DISC_RADIUS  = 6;         // p.discRadius (the little planet dot)
  var LABEL_RADIUS = 20;        // p.labelRadius
  var BORDER_COLOR = '#ffffff'; // p.borderColor = 16777215
  var BORDER_THICK = 2;         // p.borderThickness

  /* attachMovie init objects (Phase Demonstrator.as, PhaseDemonstratorClass) */
  var P1_INIT = { x: 100, y: -160, disc: '#ff9090' }; // discColor 16748688
  var P2_INIT = { x: 120, y:  -40, disc: '#9090ff' }; // discColor 9474303

  /* updateOrbits line colours */
  var ORBIT1_COLOR = '#ffa0a0';  // 16752800
  var ORBIT2_COLOR = '#8c8db3';  // 9211315

  /* The active area is the 506 x 506 black square (shape 103), origin centred.
     Phase Demonstrator.as:
       xDragLimit = activeArea._width/2  - discRadius - dragMargin
       yDragLimit = activeArea._height/2 - discRadius - dragMargin            */
  var STAGE = 506;
  var HALF  = STAGE / 2;                         // 253
  var XLIM  = HALF - DISC_RADIUS - DRAG_MARGIN;  // 227
  var YLIM  = HALF - DISC_RADIUS - DRAG_MARGIN;  // 227

  /* Phase Panel.as: the phase disc and its two colours. The light/dark colours
     are the per-instance overrides from the two on(initialize) blocks in
     DefineSprite_106 (planet 1's disc is pink, planet 2's is lavender). */
  var DISC_R = 70;                       // p.discRadius
  var PANEL1 = { light: '#ffe0e0', dark: '#604040' }; // 16769248 / 6307904
  var PANEL2 = { light: '#e0e0ff', dark: '#404040' }; // 14737663 / 4210752 (default)

  /* Phase-disc canvas: keeps the disc's original 70-unit radius; a small margin
     around it, exactly as the black Flash phase panel has. */
  var DISC_CANVAS = 170;
  var DISC_C      = DISC_CANVAS / 2;

  /* ==========================================================================
     State -- the single source of truth. render() redraws everything from it.
     ========================================================================== */

  function hypot(x, y) { return Math.sqrt(x * x + y * y); }

  var state = {
    /* state: 0 = free planet, 1 = a planet that has a moon, -1 = a moon */
    p1: { x: P1_INIT.x, y: P1_INIT.y, state: 0, orbitRadius: 0, labelAngle: 0 },
    p2: { x: P2_INIT.x, y: P2_INIT.y, state: 0, orbitRadius: 0, labelAngle: 0 },
    phase1: 0,          // phase angle drawn in disc 1
    phase2: 0,          // phase angle drawn in disc 2
    showOrbits: true,   // showOrbitsCheck initialValue = true
    disc1Visible: true, // phaseMC._visible (hide/show button)
    disc2Visible: true,
    dragging: 0,        // 0 = none, else planet id being dragged
    hovered: 0,         // planet id under the pointer (border shows)
    focused: 0          // planet id whose handle has focus (border shows)
  };

  function initialState() {
    state.p1.x = P1_INIT.x; state.p1.y = P1_INIT.y; state.p1.state = 0;
    state.p2.x = P2_INIT.x; state.p2.y = P2_INIT.y; state.p2.state = 0;
    state.p1.orbitRadius = hypot(state.p1.x, state.p1.y);
    state.p2.orbitRadius = hypot(state.p2.x, state.p2.y);
    state.showOrbits   = true;
    state.disc1Visible = true;
    state.disc2Visible = true;
    state.dragging = 0;
  }
  /* PhaseDemonstratorClass() sets each planet's initial orbitRadius from its
     placement, so do the same before the first render. */
  state.p1.orbitRadius = hypot(state.p1.x, state.p1.y);
  state.p2.orbitRadius = hypot(state.p2.x, state.p2.y);

  function planetById(id)  { return id === 1 ? state.p1 : state.p2; }
  function otherById(id)   { return id === 1 ? state.p2 : state.p1; }

  /* ==========================================================================
     Elements
     ========================================================================== */

  var orbitCanvas = document.getElementById('orbit-canvas');
  var disc1Canvas = document.getElementById('disc1-canvas');
  var disc2Canvas = document.getElementById('disc2-canvas');
  var handle1     = document.getElementById('planet1-handle');
  var handle2     = document.getElementById('planet2-handle');
  var label1      = document.getElementById('planet1-label');
  var label2      = document.getElementById('planet2-label');
  var showOrbits  = document.getElementById('show-orbits');
  var disc1Hide   = document.getElementById('disc1-hide');
  var disc2Hide   = document.getElementById('disc2-hide');
  var disc1Title  = document.getElementById('disc1-title');
  var disc2Title  = document.getElementById('disc2-title');
  var orbitDesc   = document.getElementById('orbit-desc');
  var disc1Desc   = document.getElementById('disc1-desc');
  var disc2Desc   = document.getElementById('disc2-desc');
  var statusRegion = document.getElementById('sim-status');

  var octx  = orbitCanvas.getContext('2d');
  var d1ctx = disc1Canvas.getContext('2d');
  var d2ctx = disc2Canvas.getContext('2d');

  /* ==========================================================================
     Ported controller methods -- Phase Demonstrator.as
     ========================================================================== */

  /* p.setPlanetPosition(id, x, y): the heart of the drag. Both the pointer and
     the keyboard paths call this with a target (x, y); shiftDown reproduces
     Key.isDown(16). Transcribed line-for-line from the AS. */
  function setPlanetPosition(id, x, y, shiftDown) {
    var thisP  = planetById(id);
    var otherP = otherById(id);
    var angle;

    /* Shift: keep this object in its current circular orbit. */
    if (shiftDown && thisP.state >= 0) {
      angle = Math.atan2(y, x);
      x = thisP.orbitRadius * Math.cos(angle);
      y = thisP.orbitRadius * Math.sin(angle);
    }

    /* Clamp to the field. */
    var wasOutOfBounds = false;
    if (x < -XLIM)      { x = -XLIM; wasOutOfBounds = true; }
    else if (x > XLIM)  { x =  XLIM; wasOutOfBounds = true; }
    if (y < -YLIM)      { y = -YLIM; wasOutOfBounds = true; }
    else if (y > YLIM)  { y =  YLIM; wasOutOfBounds = true; }

    /* Cannot approach the star closer than the minimum separation. */
    var sunDistance = hypot(x, y);
    if (sunDistance < SUN_SEP) {
      angle = Math.atan2(y, x);
      x = SUN_SEP * Math.cos(angle);
      y = SUN_SEP * Math.sin(angle);
    }

    var dx = x - otherP.x;
    var dy = y - otherP.y;
    if (thisP.state === 1) {
      /* This object owns a moon: drag the moon along, keeping its bearing. */
      angle = Math.atan2(-dy, -dx);
      otherP.x = x + MOON_DIST * Math.cos(angle);
      otherP.y = y + MOON_DIST * Math.sin(angle);
    } else {
      var planetDistance = hypot(dx, dy);
      if (planetDistance < MOON_SNAP || (shiftDown && thisP.state === -1)) {
        /* Snap into orbit around the other object as its moon. */
        angle = Math.atan2(dy, dx);
        x = otherP.x + MOON_DIST * Math.cos(angle);
        y = otherP.y + MOON_DIST * Math.sin(angle);
        thisP.state = -1;
        otherP.state = 1;
      } else {
        thisP.state = 0;
        otherP.state = 0;
      }
    }

    thisP.x = x;
    thisP.y = y;

    /* A free planet (state >= 0) updates its remembered orbit radius, except
       while Shift-dragging in-bounds (then it stays on its old orbit). */
    if ((!shiftDown || wasOutOfBounds) && thisP.state >= 0) {
      thisP.orbitRadius = hypot(x, y);
    }

    updatePhases();
  }

  /* p.updatePhases(): the geometry that turns the two positions into the two
     phase angles and the label bearings. Transcribed verbatim. */
  function updatePhases() {
    var x1 = state.p1.x, y1 = state.p1.y;
    var x2 = state.p2.x, y2 = state.p2.y;
    var r1 = hypot(x1, y1);
    var r2 = hypot(x2, y2);
    var angle1 = Math.atan2(y1, x1);
    var angle2 = Math.atan2(y2, x2);

    /* theta: the star-centred angle between the two objects, in [0, 2*PI). */
    var theta = TWO_PI * (((angle1 - angle2) / TWO_PI % 1 + 1) % 1);
    var cosTheta = Math.cos(theta);

    /* d: the distance between the two objects (law of cosines). */
    var d = Math.sqrt(r1 * r1 + r2 * r2 - 2 * r1 * r2 * cosTheta);
    if (d === 0) { d = 1e-9; }   // guard: coincident points never occur in play

    var cosBeta1 = (r1 - r2 * cosTheta) / d;
    if (cosBeta1 > 1) { cosBeta1 = 1; } else if (cosBeta1 < -1) { cosBeta1 = -1; }
    var beta1 = Math.acos(cosBeta1);

    var cosBeta2 = (r2 - r1 * cosTheta) / d;
    if (cosBeta2 > 1) { cosBeta2 = 1; } else if (cosBeta2 < -1) { cosBeta2 = -1; }
    var beta2 = Math.acos(cosBeta2);

    if (theta < PI) {
      state.phase1 = beta1;
      state.phase2 = TWO_PI - beta2;
    } else {
      state.phase1 = TWO_PI - beta1;
      state.phase2 = beta2;
    }

    /* Identity labels sit on the far side of each object from the other one. */
    var labelAngle2 = Math.atan2(y2 - y1, x2 - x1);
    state.p1.labelAngle = labelAngle2 + PI;
    state.p2.labelAngle = labelAngle2;
  }

  /* p.updatePanelTitles(): "planet"/"moon" naming that also feeds the discs'
     accessible names. */
  function panelTitles() {
    var n1 = state.p1.state >= 0 ? 'planet 1' : 'moon 1';
    var n2 = state.p2.state >= 0 ? 'planet 2' : 'moon 2';
    return {
      disc1: n1 + ' as seen from ' + n2,
      disc2: n2 + ' as seen from ' + n1,
      n1: n1, n2: n2
    };
  }

  /* ==========================================================================
     Phase-disc drawing -- Phase Panel.as p.setPhaseAngle, transcribed onto the
     2D context (origin already translated to the disc centre; Flash Y-down ==
     canvas Y-down, so every coordinate is the AS value).
     ========================================================================== */

  function drawPhaseDisc(ctx, angle, colors) {
    var sin = Math.sin, cos = Math.cos;
    angle = (angle % TWO_PI + TWO_PI) % TWO_PI;

    var dir = angle < PI ? -1 : 1;
    var n = 4;
    var r = DISC_R;
    var s = r * cos(angle);
    var step = PI / n;
    var halfStep = step / 2;
    var kr = r / cos(halfStep);
    var ks = s / cos(halfStep);
    var i, a, ax, ay, cAngle, cx, cy;

    /* dark fill */
    ctx.beginPath();
    ctx.moveTo(0, -r);
    for (i = 1; i <= n; i++) {
      a = i * step; ax = r * sin(a); ay = -r * cos(a);
      cAngle = a - halfStep; cx = kr * sin(cAngle); cy = -kr * cos(cAngle);
      ctx.quadraticCurveTo(dir * cx, cy, dir * ax, ay);
    }
    for (i = n - 1; i >= 0; i--) {
      a = i * step; ax = s * sin(a); ay = -r * cos(a);
      cAngle = a + halfStep; cx = ks * sin(cAngle); cy = -kr * cos(cAngle);
      ctx.quadraticCurveTo(dir * cx, cy, dir * ax, ay);
    }
    ctx.closePath();
    ctx.fillStyle = colors.dark;
    ctx.fill();

    /* light fill (drawn on top, exactly as the second beginFill in the AS) */
    ctx.beginPath();
    ctx.moveTo(0, -r);
    for (i = 1; i <= n; i++) {
      a = i * step; ax = -r * sin(a); ay = -r * cos(a);
      cAngle = a - halfStep; cx = -kr * sin(cAngle); cy = -kr * cos(cAngle);
      ctx.quadraticCurveTo(dir * cx, cy, dir * ax, ay);
    }
    for (i = n - 1; i >= 0; i--) {
      a = i * step; ax = s * sin(a); ay = -r * cos(a);
      cAngle = a + halfStep; cx = ks * sin(cAngle); cy = -kr * cos(cAngle);
      ctx.quadraticCurveTo(dir * cx, cy, dir * ax, ay);
    }
    ctx.closePath();
    ctx.fillStyle = colors.light;
    ctx.fill();
  }

  /* ==========================================================================
     Rendering
     ========================================================================== */

  function sizeCanvas(canvas, w, h) {
    var dpr = Math.min(window.devicePixelRatio || 1, 3);
    canvas.width  = Math.round(w * dpr);
    canvas.height = Math.round(h * dpr);
    return dpr;
  }

  var orbitDpr = 1, disc1Dpr = 1, disc2Dpr = 1;

  function resizeCanvases() {
    orbitDpr = sizeCanvas(orbitCanvas, STAGE, STAGE);
    disc1Dpr = sizeCanvas(disc1Canvas, DISC_CANVAS, DISC_CANVAS);
    disc2Dpr = sizeCanvas(disc2Canvas, DISC_CANVAS, DISC_CANVAS);
  }

  /* A soft radial glow reproduces the star at the centre of the active area
     (a Flash gradient fill; no exported bitmap for it). */
  function drawStar(ctx) {
    var g = ctx.createRadialGradient(0, 0, 0, 0, 0, 26);
    g.addColorStop(0.00, 'rgba(255,255,245,1)');
    g.addColorStop(0.30, 'rgba(255,240,190,1)');
    g.addColorStop(0.55, 'rgba(240,190,120,0.55)');
    g.addColorStop(1.00, 'rgba(240,190,120,0)');
    ctx.fillStyle = g;
    ctx.beginPath();
    ctx.arc(0, 0, 26, 0, TWO_PI);
    ctx.fill();
  }

  /* p.updateOrbits / p.drawCircle: an object's orbit is a circle round the star
     (radius = its distance) unless it is a moon, when it is a small circle round
     its primary. ctx.arc reproduces the curveTo circle exactly. */
  function drawOrbitCircle(ctx, obj, other, color) {
    ctx.strokeStyle = color;
    ctx.lineWidth = 1;
    ctx.beginPath();
    if (obj.state < 0) {
      ctx.arc(other.x, other.y, MOON_DIST, 0, TWO_PI);
    } else {
      ctx.arc(0, 0, hypot(obj.x, obj.y), 0, TWO_PI);
    }
    ctx.stroke();
  }

  function drawPlanet(ctx, obj, color, showBorder) {
    ctx.fillStyle = color;
    ctx.beginPath();
    ctx.arc(obj.x, obj.y, DISC_RADIUS, 0, TWO_PI);
    ctx.fill();
    if (showBorder) {
      ctx.strokeStyle = BORDER_COLOR;
      ctx.lineWidth = BORDER_THICK;
      ctx.beginPath();
      ctx.arc(obj.x, obj.y, DISC_RADIUS, 0, TWO_PI);
      ctx.stroke();
    }
  }

  function renderOrbit() {
    var ctx = octx;
    ctx.setTransform(orbitDpr, 0, 0, orbitDpr, 0, 0);
    ctx.clearRect(0, 0, STAGE, STAGE);
    ctx.fillStyle = '#000000';
    ctx.fillRect(0, 0, STAGE, STAGE);

    ctx.save();
    ctx.translate(HALF, HALF);              // origin at the star, as in Flash

    drawStar(ctx);

    if (state.showOrbits) {
      drawOrbitCircle(ctx, state.p1, state.p2, ORBIT1_COLOR);
      drawOrbitCircle(ctx, state.p2, state.p1, ORBIT2_COLOR);
    }

    drawPlanet(ctx, state.p1, P1_INIT.disc, borderShown(1));
    drawPlanet(ctx, state.p2, P2_INIT.disc, borderShown(2));

    ctx.restore();

    positionOverlays();
  }

  function borderShown(id) {
    return state.dragging === id || state.hovered === id || state.focused === id;
  }

  function pct(value) { return (100 * (value + HALF) / STAGE) + '%'; }

  function positionOverlays() {
    handle1.style.left = pct(state.p1.x); handle1.style.top = pct(state.p1.y);
    handle2.style.left = pct(state.p2.x); handle2.style.top = pct(state.p2.y);

    label1.style.left = pct(state.p1.x + LABEL_RADIUS * Math.cos(state.p1.labelAngle));
    label1.style.top  = pct(state.p1.y + LABEL_RADIUS * Math.sin(state.p1.labelAngle));
    label2.style.left = pct(state.p2.x + LABEL_RADIUS * Math.cos(state.p2.labelAngle));
    label2.style.top  = pct(state.p2.y + LABEL_RADIUS * Math.sin(state.p2.labelAngle));
  }

  function renderDisc(ctx, dpr, visible, phase, colors) {
    ctx.setTransform(dpr, 0, 0, dpr, 0, 0);
    ctx.clearRect(0, 0, DISC_CANVAS, DISC_CANVAS);
    ctx.fillStyle = '#000000';
    ctx.fillRect(0, 0, DISC_CANVAS, DISC_CANVAS);
    if (!visible) { return; }
    ctx.save();
    ctx.translate(DISC_C, DISC_C);
    drawPhaseDisc(ctx, phase, colors);
    ctx.restore();
  }

  /* ==========================================================================
     Descriptions for assistive technology -- derived from the same numbers that
     drive the picture, so what is spoken can never drift from what is drawn.
     ========================================================================== */

  /* Illuminated fraction of a disc, from the phase angle the disc is drawn with:
       f = (1 + cos(phase)) / 2
     1 at phase 0 (full), 0 at phase PI (new), 0.5 at the quarters. */
  function litFraction(phase) {
    return (1 + Math.cos(phase)) / 2;
  }

  /* Which limb is in shadow, read off the same test that draws the terminator:
     for 0 < phase < PI the lit side is the disc's right, so the shadow is on the
     left; otherwise the shadow is on the right. */
  function shadedSide(phase) {
    var a = (phase % TWO_PI + TWO_PI) % TWO_PI;
    return a < PI ? 'left' : 'right';
  }

  function phaseName(f) {
    if (f >= 0.99) { return 'full'; }
    if (f <= 0.01) { return 'new'; }
    if (f > 0.55)  { return 'gibbous'; }
    if (f < 0.45)  { return 'crescent'; }
    return 'quarter';
  }

  function discDescription(name, visible, phase) {
    if (!visible) {
      return name + ' is hidden. Choose show to reveal the phase.';
    }
    var f = litFraction(phase);
    var pctLit = Math.round(f * 100);
    if (f >= 0.995) { return name + ': full disc, fully illuminated.'; }
    if (f <= 0.005) { return name + ': new, dark disc, no illumination.'; }
    return name + ': ' + phaseName(f) + ', ' + pctLit +
           ' percent illuminated, with the ' + shadedSide(phase) + ' side in shadow.';
  }

  /* Polar description of an object's position: angle measured counter-clockwise
     from the right (east), and distance in stage units. */
  function objectSpeech(id) {
    var p = planetById(id);
    var t = panelTitles();
    var name = id === 1 ? t.n1 : t.n2;
    var name0 = name.charAt(0).toUpperCase() + name.slice(1);
    var ang = Math.round((DEG * Math.atan2(-p.y, p.x) % 360 + 360) % 360);
    var dist = Math.round(hypot(p.x, p.y));
    return name0 + ' at angle ' + ang + ' degrees, distance ' + dist +
           ' units from the star';
  }

  function commitSpeech(id) {
    var t = panelTitles();
    return objectSpeech(id) + '. ' +
           discDescription(t.disc1, state.disc1Visible, state.phase1) + ' ' +
           discDescription(t.disc2, state.disc2Visible, state.phase2);
  }

  function syncDescriptions() {
    var t = panelTitles();

    disc1Title.textContent = t.disc1;
    disc2Title.textContent = t.disc2;

    handle1.setAttribute('aria-label', objectSpeech(1) + '. Arrow keys move it.');
    handle2.setAttribute('aria-label', objectSpeech(2) + '. Arrow keys move it.');

    disc1Desc.textContent = discDescription(t.disc1, state.disc1Visible, state.phase1);
    disc2Desc.textContent = discDescription(t.disc2, state.disc2Visible, state.phase2);

    orbitDesc.textContent =
      'Overhead view of a star with two planets. ' + objectSpeech(1) + '. ' +
      objectSpeech(2) + '. Orbit circles are ' +
      (state.showOrbits ? 'shown' : 'hidden') + '.';

    /* Per-disc illuminated percentage and the relationship, typeset by MathJax
       through the foundation helper. Spoken forms carry the words, since the
       percent and degree symbols are not reliably announced on their own. */
    if (typeof klunlShowEquation === 'function') {
      updateDiscEqn('disc1-eqn', 'disc1-eqn-sr', state.disc1Visible, state.phase1);
      updateDiscEqn('disc2-eqn', 'disc2-eqn-sr', state.disc2Visible, state.phase2);
    }
  }

  function updateDiscEqn(eqnId, srId, visible, phase) {
    if (!visible) {
      klunlShowEquation([eqnId, '\\(-\\)'], [srId, 'Disc hidden.']);
      return;
    }
    var pctLit = Math.round(litFraction(phase) * 100);
    klunlShowEquation(
      [eqnId, '\\(' + pctLit + '\\%\\)'],
      [srId, pctLit + ' percent illuminated.']
    );
  }

  /* Typeset math is display-only and must never become a tab stop (WCAG 2.4.3;
     some MathJax builds make their container focusable). */
  function keepMathOutOfTabOrder() {
    var containers = document.querySelectorAll(
      '#frac-eqn mjx-container, #frac-eqn svg,' +
      '#disc1-eqn mjx-container, #disc1-eqn svg,' +
      '#disc2-eqn mjx-container, #disc2-eqn svg');
    for (var i = 0; i < containers.length; i++) {
      containers[i].setAttribute('tabindex', '-1');
    }
  }

  /* Announcements are debounced so holding an arrow key, or dragging, produces
     one settled message instead of a flood. */
  var announceTimer = null;
  function announce(message) {
    if (announceTimer) { clearTimeout(announceTimer); }
    announceTimer = setTimeout(function () {
      statusRegion.textContent = message;
    }, 350);
  }

  /* ==========================================================================
     The single render pass
     ========================================================================== */

  function render() {
    renderOrbit();
    renderDisc(d1ctx, disc1Dpr, state.disc1Visible, state.phase1, PANEL1);
    renderDisc(d2ctx, disc2Dpr, state.disc2Visible, state.phase2, PANEL2);
    syncDescriptions();
    keepMathOutOfTabOrder();
  }

  /* ==========================================================================
     Pointer input -- Draggable Planet.as onPress / onMouseMove

       onPress:      xOffset = _parent._x - _xmouse   (grab offset)
       onMouseMove:  setPlanetPosition(id, xOffset + _xmouse, yOffset + _ymouse)

     Pointer coordinates are mapped back through the current CSS scale so the
     maths runs in original stage units at any display size.
     ========================================================================== */

  function stagePoint(ev) {
    var rect = orbitCanvas.getBoundingClientRect();
    return {
      x: (ev.clientX - rect.left) * (STAGE / rect.width)  - HALF,
      y: (ev.clientY - rect.top)  * (STAGE / rect.height) - HALF
    };
  }

  /* Flash hit-tests the 6-unit disc itself; a larger radius is used so the grab
     target clears the touch minimum. When both objects are within range (a moon
     next to its primary) the nearer one wins. */
  var GRAB_RADIUS = 18;

  function planetAt(p) {
    var d1 = hypot(p.x - state.p1.x, p.y - state.p1.y);
    var d2 = hypot(p.x - state.p2.x, p.y - state.p2.y);
    var within1 = d1 <= GRAB_RADIUS, within2 = d2 <= GRAB_RADIUS;
    if (within1 && within2) { return d1 <= d2 ? 1 : 2; }
    if (within1) { return 1; }
    if (within2) { return 2; }
    return 0;
  }

  var dragOffset = { x: 0, y: 0 };

  orbitCanvas.addEventListener('pointerdown', function (ev) {
    var p = stagePoint(ev);
    var id = planetAt(p);
    if (!id) { return; }
    var obj = planetById(id);
    state.dragging = id;
    dragOffset.x = obj.x - p.x;    // xOffset = _parent._x - _xmouse
    dragOffset.y = obj.y - p.y;
    /* Click-to-focus: arrow keys work straight after a click, with no Tab. */
    (id === 1 ? handle1 : handle2).focus();
    orbitCanvas.setPointerCapture(ev.pointerId);
    render();
    ev.preventDefault();
  });

  orbitCanvas.addEventListener('pointermove', function (ev) {
    var p = stagePoint(ev);
    if (!state.dragging) {
      var over = planetAt(p);
      state.hovered = over;
      orbitCanvas.style.cursor = over ? 'grab' : 'default';
      render();
      return;
    }
    orbitCanvas.style.cursor = 'grabbing';
    setPlanetPosition(state.dragging, dragOffset.x + p.x, dragOffset.y + p.y, ev.shiftKey);
    render();
    ev.preventDefault();
  });

  function endDrag(ev) {
    if (!state.dragging) { return; }
    var id = state.dragging;
    state.dragging = 0;
    orbitCanvas.style.cursor = 'default';
    if (ev && ev.pointerId !== undefined && orbitCanvas.hasPointerCapture(ev.pointerId)) {
      orbitCanvas.releasePointerCapture(ev.pointerId);
    }
    render();
    announce(commitSpeech(id));   // announce on release, not on every tick
  }

  orbitCanvas.addEventListener('pointerup', endDrag);
  orbitCanvas.addEventListener('pointercancel', endDrag);

  /* ==========================================================================
     Keyboard input on each planet handle

     Every mouse-draggable element must also be reachable by Tab, focusable by
     click, and movable with the arrow keys. Arrows nudge in x/y; Shift+arrow
     keeps the object on its orbit (Key.isDown(16) in the AS); Page keys rotate
     it a coarse step around the star; Home/End set the nearest / farthest orbit.
     ========================================================================== */

  var STEP_FINE   = 2;    // arrow keys, stage units
  var STEP_COARSE = 15;   // Page keys, degrees around the star

  function moveByKey(id, ev) {
    var p = planetById(id);
    var handled = true;
    var x = p.x, y = p.y, ang, r;

    switch (ev.key) {
      case 'ArrowRight': x += STEP_FINE; break;
      case 'ArrowLeft':  x -= STEP_FINE; break;
      case 'ArrowUp':    y -= STEP_FINE; break;   // screen up = -y in Flash
      case 'ArrowDown':  y += STEP_FINE; break;
      case 'PageUp':     // rotate one coarse step counter-clockwise, on-orbit
        ang = Math.atan2(y, x) - STEP_COARSE / DEG; r = hypot(x, y);
        x = r * Math.cos(ang); y = r * Math.sin(ang); break;
      case 'PageDown':   // rotate one coarse step clockwise, on-orbit
        ang = Math.atan2(y, x) + STEP_COARSE / DEG; r = hypot(x, y);
        x = r * Math.cos(ang); y = r * Math.sin(ang); break;
      case 'Home':       // nearest allowed orbit (minimum star separation)
        ang = Math.atan2(y, x); x = SUN_SEP * Math.cos(ang); y = SUN_SEP * Math.sin(ang); break;
      case 'End':        // farthest allowed orbit along the current bearing
        ang = Math.atan2(y, x); x = XLIM * Math.cos(ang); y = XLIM * Math.sin(ang); break;
      default: handled = false;
    }
    if (!handled) { return false; }

    /* Shift keeps the object on its orbit, matching the pointer path. Page/Home/
       End already computed an on-orbit / on-bearing target, so pass their intent
       through too (Shift optional there). */
    var shift = ev.shiftKey || ev.key === 'PageUp' || ev.key === 'PageDown';
    setPlanetPosition(id, x, y, shift);
    render();
    announce(commitSpeech(id));
    return true;
  }

  function wireHandle(id, handle) {
    handle.addEventListener('keydown', function (ev) {
      if (moveByKey(id, ev)) { ev.preventDefault(); }
      /* every other key (Tab included) passes through, so focus escapes normally */
    });
    handle.addEventListener('focus', function () { state.focused = id; render(); });
    handle.addEventListener('blur',  function () {
      if (state.focused === id) { state.focused = 0; render(); }
    });
  }
  wireHandle(1, handle1);
  wireHandle(2, handle2);

  /* ==========================================================================
     Controls
     ========================================================================== */

  /* showOrbitsCheck changeHandler = "updateOrbits". */
  showOrbits.addEventListener('change', function () {
    state.showOrbits = showOrbits.checked;
    render();
    announce(state.showOrbits ? 'Orbit circles shown.' : 'Orbit circles hidden.');
  });

  /* Phase Panel.as p.toggleVisibility: flip the disc's visibility and swap the
     button label between "hide" and "show". */
  function wireHideButton(btn, key) {
    btn.addEventListener('click', function () {
      state[key] = !state[key];
      btn.textContent = state[key] ? 'hide' : 'show';
      render();
      var t = panelTitles();
      var name = key === 'disc1Visible' ? t.disc1 : t.disc2;
      var phase = key === 'disc1Visible' ? state.phase1 : state.phase2;
      announce(discDescription(name, state[key], phase));
    });
  }
  wireHideButton(disc1Hide, 'disc1Visible');
  wireHideButton(disc2Hide, 'disc2Visible');

  /* ==========================================================================
     Reset -- the masthead's Reset button dispatches "sim-reset"
     ========================================================================== */

  document.addEventListener('sim-reset', function () {
    initialState();
    showOrbits.checked = true;
    disc1Hide.textContent = 'hide';
    disc2Hide.textContent = 'hide';
    updatePhases();
    render();
    statusRegion.textContent = 'Simulation reset. ' + commitSpeech(1);
  });

  /* ==========================================================================
     Start-up
     ========================================================================== */

  /* kl-unl.js defines klunlInitEqn as a stub and expects the sim to redefine it;
     this version brings up the equations and the rest of the simulation. */
  window.klunlInitEqn = function () {
    resizeCanvases();
    /* The illuminated-fraction relationship: f = (1 + cos alpha) / 2. */
    if (typeof klunlShowEquation === 'function') {
      klunlShowEquation(
        ['frac-eqn', '\\( f = \\dfrac{1 + \\cos\\alpha}{2} \\)'],
        ['frac-eqn-sr',
         'Illuminated fraction f equals one plus cosine of the phase angle alpha, all divided by two.']
      );
    }
    updatePhases();     // fill in phase angles + label bearings before first draw
    render();
  };

  window.addEventListener('resize', function () {
    /* Only the backing-store resolution depends on the device pixel ratio, which
       changes when a window moves between displays or the page is zoomed. */
    resizeCanvases();
    render();
  });

  /* MathJax loads asynchronously; if it is ready, klunlInitEqn typesets now,
     otherwise the first render still happens and the equations fill in on load. */
  updatePhases();
  render();
  if (window.MathJax && window.MathJax.startup && window.MathJax.startup.promise) {
    window.MathJax.startup.promise.then(function () { klunlInitEqn(); });
  } else {
    klunlInitEqn();
  }

})();
