/* ============================================================================
   Basketball Phases Simulator -- HTML5 port of basketball.swf (Flash 6 / AS1)

   Behaviour model
   ---------------
   A basketball sits at the centre of a circular track, lit from the left by a
   bank of light rays. An eye rides the track and always faces the ball. What
   that eye sees is drawn in the "View of Ball" panel: one of 79 pre-rendered
   rotation frames of the ball, overlaid with a dark terminator region whose
   shape depends on where the observer stands. Walking the eye once around the
   track therefore cycles the ball through a full set of phases, exactly as the
   Moon does for an observer on Earth. The eye can be dragged by hand or set
   running at a chosen speed; the phase shading and the light rays can both be
   switched off; and the ball itself can be hidden so a student can predict the
   phase before revealing it.

   Source of truth for behaviour: the decompiled ActionScript, chiefly
     scripts/animation.as          -- the per-frame controller
     scripts/BasketballRotator.as  -- frame selection + terminator geometry
     scripts/eye_clip.as           -- the observer's motion and drag
   Every constant below is copied verbatim from those files; see
   CONVERSION_NOTES.md for the full AS -> JS mapping.
============================================================================ */

(function () {
  'use strict';

  /* ==========================================================================
     Constants -- verbatim from the ActionScript
     ========================================================================== */

  /* BasketballRotator.as: prototype properties */
  var FRAMES     = 79;                       // p._frames
  var STEP_SIZE  = 6.283185307179586 / FRAMES; // p._stepSize = 2*PI / _frames
  var MARGIN     = 10;                       // p._margin
  var RADIUS     = 86;                       // p._radius
  var N          = 5;                        // p._N  (terminator curve segments)

  /* on(initialize) for the BasketballRotator instance named "rotator" */
  var INIT_LONGITUDE  = 0;
  var INIT_SUN_ANGLE  = 0;
  var INIT_DARK_ALPHA = 70;                  // 0-100 in Flash; /100 for canvas

  /* eye_clip.as: the observer rides a circle of this radius, in stage units. */
  var EYE_ORBIT = 250;

  /* on(initialize) for the "Slider v2" instance named "mySlider".
     Units are degrees per millisecond -- 0.05 deg/ms == 50 deg/s. */
  var SPEED_MIN  = 0.01;
  var SPEED_MAX  = 0.1;
  var SPEED_INIT = 0.05;

  var DEG = 57.29577951308232;               // p.degrees: rad -> deg
  var RAD = 0.017453292519943295;            // p.radians: deg -> rad

  /* ==========================================================================
     Canvas geometry

     Both canvases keep the ORIGINAL Flash coordinate system internally; CSS
     scales the elements to fit their panels. No drawing or physics maths is
     ever recomputed from the on-screen size, so parity holds at any zoom.

     Overhead view: the origin is the centre of the ball, matching the "animation"
     clip's own registration point, so every placement below is the AS value.
     ========================================================================== */

  var ORBIT_W = 680, ORBIT_H = 540;          // logical size of the overhead canvas
  var ORBIT_CX = 405, ORBIT_CY = 270;        // ball centre within it

  var BALL_W = 225, BALL_H = 225;            // the rotator's black backing square
  var BALL_CX = 112.5, BALL_CY = 112.5;

  /* Placements read out of the SWF (twips/20), relative to the ball centre.
     myLight sits at (-330.85, 4.2); inside it the four arrow clips are at
     x = -44.95 and y = 100 / 34 / -34 / -100, and each arrow clip holds the
     arrow shape offset a further +50 in x. */
  var LIGHT_X = -330.85, LIGHT_Y = 4.2;
  var ARROW_X = -44.95 + 50;
  var ARROW_Y = [100, 34, -34, -100];
  var ARROW_COLOR = '#ffcc00';               // arrow.as: _myColor = 16763904

  /* The "Light" caption: EditText 274, placed at (-52.25, -14.35) inside
     myLight, 95.7 x 33.2 with right alignment -- so its visual centre is here. */
  var LIGHT_LABEL_X = LIGHT_X - 52.25 + 95.7 / 2;
  var LIGHT_LABEL_Y = LIGHT_Y - 14.35 + 33.2 / 2;

  /* the_eye is placed at scale 0.630691 / 0.627121 inside eye_clip. */
  var EYE_SCALE_X = 0.630691, EYE_SCALE_Y = 0.627121;

  /* myShadow: placed at (2.55, 0.05), scale (-0.544663, -0.575409).
     The negative scales flip it onto the unlit half of the overhead ball. */
  var SHADOW_X = 2.55, SHADOW_Y = 0.05;
  var SHADOW_SCALE_X = -0.544663, SHADOW_SCALE_Y = -0.575409;

  /* Registration offsets: each exported SVG's own origin sits at (-Xmin, -Ymin)
     within the file, so drawing at (x + Xmin, y + Ymin) reproduces Flash's
     placement exactly. */
  var REG = {
    eye:    { x: -42,    y: -59    },   // shape 256, 84.5 x 118
    ball:   { x: -47.5,  y: -47.5  },   // shape 252, 91.9 x 95
    shadow: { x: -82.5,  y: -82.5  },   // shape 260, 89.55 x 165.1
    orbit:  { x: -250.5, y: -250.5 },   // shape 258, 501 x 501
    arrow:  { x: -49.7,  y: -4.7   }    // shape 240, 99.4 x 9.4
  };

  /* ==========================================================================
     Terminator geometry -- BasketballRotator.as, computed once at class scope

       var step = Math.PI / (p._N - 1);
       var cRad = p._radius / Math.cos(step / 2);
       ... taP[i] = ( r*sin(a),    -r*cos(a)    )   with a  = i*step
           tcP[i] = ( cRad*sin(a2), -cRad*cos(a2) )  with a2 = step/2 + (i-1)*step

     taP are the on-circle anchor points, tcP the quadratic control points; the
     pair tessellates a half-circle that gets squashed horizontally by cos(phase)
     to sweep the terminator across the disc.
     ========================================================================== */

  var taP = [], tcP = [];
  (function buildTerminator() {
    var step = 3.141592653589793 / (N - 1);
    var cRad = RADIUS / Math.cos(step / 2);
    for (var i = 0; i < N; i++) {
      var angle = i * step;
      taP[i] = { x: RADIUS * Math.sin(angle), y: -RADIUS * Math.cos(angle) };
      var angle2 = step / 2 + (i - 1) * step;
      tcP[i] = { x: cRad * Math.sin(angle2), y: -cRad * Math.cos(angle2) };
    }
  })();

  /* BasketballRotator.as p.mod -- a modulo that returns a non-negative result. */
  function mod(n, m) {
    if (n < 0) { return n % m + m; }
    return n % m;
  }

  /* ==========================================================================
     State -- the single source of truth. render() redraws everything from it.
     ========================================================================== */

  var state = {
    angle:   INIT_LONGITUDE,   // eye_clip "angle" property, degrees
    time:    INIT_LONGITUDE,   // eye_clip._time, the animation's accumulator
    animate: false,            // man_auto value: false = "Move Eye Manually"
    phases:  true,             // phaseRadio value: true = "With Phases"
    hidden:  false,            // hide_show.hideValue
    speed:   SPEED_INIT,       // mySlider value, degrees per millisecond
    dragging: false
  };

  function initialState() {
    state.angle    = INIT_LONGITUDE;
    state.time     = INIT_LONGITUDE;
    state.animate  = false;
    state.phases   = true;
    state.hidden   = false;
    state.speed    = SPEED_INIT;
    state.dragging = false;
  }

  /* ==========================================================================
     Elements
     ========================================================================== */

  var orbitCanvas  = document.getElementById('orbit-canvas');
  var ballCanvas   = document.getElementById('ball-canvas');
  var orbitStage   = document.getElementById('orbit-stage');
  var eyeHandle    = document.getElementById('eye-handle');
  var lightLabel   = document.getElementById('light-label');
  var hideButton   = document.getElementById('hide-button');
  var eyeManual    = document.getElementById('eye-manual');
  var eyeAnimate   = document.getElementById('eye-animate');
  var phaseWith    = document.getElementById('phase-with');
  var phaseNone    = document.getElementById('phase-none');
  var speedRange   = document.getElementById('speed-range');
  var orbitDesc    = document.getElementById('orbit-desc');
  var ballDesc     = document.getElementById('ball-desc');
  var statusRegion = document.getElementById('sim-status');

  var octx = orbitCanvas.getContext('2d');
  var bctx = ballCanvas.getContext('2d');

  /* ==========================================================================
     Assets -- exported by JPEXS and reused as-is, never redrawn by hand.
     ========================================================================== */

  var art = {};
  var sequence = [];            // the 79 rotation frames, index 0 == Flash frame 1
  var assetsReady = false;

  function loadImage(src) {
    return new Promise(function (resolve) {
      var img = new Image();
      img.onload  = function () { resolve(img); };
      img.onerror = function () { console.error('Could not load ' + src); resolve(null); };
      img.src = src;
    });
  }

  function loadAssets() {
    var jobs = [
      loadImage('assets/eye.svg').then(function (i) { art.eye = i; }),
      loadImage('assets/ball.svg').then(function (i) { art.ball = i; }),
      loadImage('assets/ball-shadow.svg').then(function (i) { art.shadow = i; }),
      loadImage('assets/orbit.svg').then(function (i) { art.orbit = i; }),
      loadImage('assets/arrow.svg').then(function (i) { art.arrow = i; })
    ];
    for (var n = 1; n <= FRAMES; n++) {
      (function (idx) {
        var name = 'assets/sequence/f' + (idx < 10 ? '0' + idx : idx) + '.png';
        jobs.push(loadImage(name).then(function (i) { sequence[idx - 1] = i; }));
      })(n);
    }
    return Promise.all(jobs).then(function () {
      /* arrow.as recolours the arrow wholesale via Color.setRGB, which replaces
         RGB and keeps alpha. Reproduce that once, offscreen, by painting the
         flat colour through the exported shape's own alpha. */
      if (art.arrow) { art.arrow = tintImage(art.arrow, ARROW_COLOR); }
      assetsReady = true;
    });
  }

  function tintImage(img, color) {
    var w = img.naturalWidth || img.width;
    var h = img.naturalHeight || img.height;
    var off = document.createElement('canvas');
    off.width = w; off.height = h;
    var c = off.getContext('2d');
    c.drawImage(img, 0, 0, w, h);
    c.globalCompositeOperation = 'source-in';
    c.fillStyle = color;
    c.fillRect(0, 0, w, h);
    return off;
  }

  /* Draw an exported asset with its Flash registration point at (x, y). */
  function drawArt(ctx, img, kind, x, y) {
    if (!img) { return; }
    var w = img.naturalWidth || img.width;
    var h = img.naturalHeight || img.height;
    ctx.drawImage(img, x + REG[kind].x, y + REG[kind].y, w, h);
  }

  /* ==========================================================================
     Ported rotator methods -- BasketballRotator.as
     ========================================================================== */

  /* p.setLongitude: pick which of the 79 pre-rendered rotation frames to show. */
  function frameForLongitude(deg) {
    var lng = mod(deg, 360) * RAD;
    return 1 + mod(Math.floor(lng / STEP_SIZE), FRAMES);   // 1-based, as in Flash
  }

  /* p.setSunAngle: the terminator phase, in radians. */
  function phaseForSunAngle(deg) {
    return RAD * mod(-deg + 180, 360);
  }

  /* p.updateMask, transcribed onto the 2D context.

     The path is a box covering one side of the disc, closed by a half-ellipse
     whose horizontal extent is cos(phase). Canvas fills with the non-zero
     winding rule by default -- the same rule Flash's drawing API uses -- so the
     box and the closing curve add or cancel exactly as they do in the original,
     giving an unshaded disc at full phase and a fully shaded one at new. */
  function drawTerminator(ctx, phase, darkAlpha) {
    var boxDirection = 1;
    if (phase < 3.141592653589793) { boxDirection = -1; }
    var boxSide = RADIUS + MARGIN;

    ctx.save();
    ctx.beginPath();
    ctx.moveTo(0, RADIUS);
    ctx.lineTo(0, boxSide);
    ctx.lineTo(boxDirection * boxSide, boxSide);
    ctx.lineTo(boxDirection * boxSide, -boxSide);
    ctx.lineTo(0, -boxSide);
    ctx.lineTo(0, -RADIUS);

    var cp = Math.cos(mod(phase, 3.141592653589793));
    for (var i = 0; i < N; i++) {
      ctx.quadraticCurveTo(cp * tcP[i].x, tcP[i].y, cp * taP[i].x, taP[i].y);
    }

    ctx.closePath();
    ctx.globalAlpha = darkAlpha / 100;    // Flash alpha is 0-100
    ctx.fillStyle = '#000000';
    ctx.fill();                            // non-zero winding, as in Flash
    ctx.restore();
  }

  /* ==========================================================================
     Rendering
     ========================================================================== */

  function sizeCanvas(canvas, w, h) {
    var dpr = Math.min(window.devicePixelRatio || 1, 3);
    canvas.width  = Math.round(w * dpr);
    canvas.height = Math.round(h * dpr);
    /* width/height keep the w:h ratio, so the CSS `width:100%; height:auto`
       rule preserves the aspect ratio even without the aspect-ratio property. */
    return dpr;
  }

  var orbitDpr = 1, ballDpr = 1;

  function resizeCanvases() {
    orbitDpr = sizeCanvas(orbitCanvas, ORBIT_W, ORBIT_H);
    ballDpr  = sizeCanvas(ballCanvas,  BALL_W,  BALL_H);
  }

  /* Where the eye sits, in overhead-view coordinates.

     eye_clip.as animates with  nextX = -250*cos(angle), nextY = -250*sin(angle)
     and drags with             newX  =  250*cos(a),     newY  =  250*sin(a)
     where the drag also sets   angle =  180 + a.
     Those are the same point, so deriving position from `angle` alone matches
     both paths and keeps one source of truth. */
  function eyePosition() {
    var r = state.angle * RAD;
    return { x: -EYE_ORBIT * Math.cos(r), y: -EYE_ORBIT * Math.sin(r) };
  }

  function renderOrbit() {
    var ctx = octx;
    ctx.setTransform(orbitDpr, 0, 0, orbitDpr, 0, 0);
    ctx.clearRect(0, 0, ORBIT_W, ORBIT_H);

    ctx.save();
    ctx.translate(ORBIT_CX, ORBIT_CY);       // origin == ball centre, as in Flash

    /* Draw order follows the depths inside the eye_clip and animation clips:
       ball(7) < eye(11) < orbit circle(27) < shadow(29) < light rays(138). */
    drawArt(ctx, art.ball, 'ball', 0, 0);

    var eye = eyePosition();
    if (art.eye) {
      ctx.save();
      ctx.translate(eye.x, eye.y);
      ctx.rotate(state.angle * RAD);         // the_eye._rotation, in degrees
      ctx.scale(EYE_SCALE_X, EYE_SCALE_Y);
      drawArt(ctx, art.eye, 'eye', 0, 0);
      ctx.restore();
    }

    drawArt(ctx, art.orbit, 'orbit', 0, 0);

    /* myShadow._visible and myLight._visible both follow the phases radio
       (animation.as and eye_clip.as read phRadio.value every frame). */
    if (state.phases) {
      if (art.shadow) {
        ctx.save();
        ctx.translate(SHADOW_X, SHADOW_Y);
        ctx.scale(SHADOW_SCALE_X, SHADOW_SCALE_Y);
        drawArt(ctx, art.shadow, 'shadow', 0, 0);
        ctx.restore();
      }
      for (var i = 0; i < ARROW_Y.length; i++) {
        drawArt(ctx, art.arrow, 'arrow', LIGHT_X + ARROW_X, LIGHT_Y + ARROW_Y[i]);
      }
    }

    ctx.restore();

    positionOverlays(eye);
  }

  /* The "Light" caption and the eye's focus proxy are HTML, so they scale with
     the user's font size. Position them as percentages of the stage box so they
     track the canvas however CSS has scaled it. */
  function positionOverlays(eye) {
    lightLabel.style.display = state.phases ? '' : 'none';
    lightLabel.style.left = pct(LIGHT_LABEL_X + ORBIT_CX, ORBIT_W);
    lightLabel.style.top  = pct(LIGHT_LABEL_Y + ORBIT_CY, ORBIT_H);

    eyeHandle.style.left = pct(eye.x + ORBIT_CX, ORBIT_W);
    eyeHandle.style.top  = pct(eye.y + ORBIT_CY, ORBIT_H);
  }

  function pct(value, total) {
    return (100 * value / total) + '%';
  }

  function renderBall() {
    var ctx = bctx;
    ctx.setTransform(ballDpr, 0, 0, ballDpr, 0, 0);
    ctx.clearRect(0, 0, BALL_W, BALL_H);

    /* Shape 250: the rotator's 225 x 225 black backing square. */
    ctx.fillStyle = '#000000';
    ctx.fillRect(0, 0, BALL_W, BALL_H);

    ctx.save();
    ctx.translate(BALL_CX, BALL_CY);

    /* animation.as: rotator.setLongitude(eyeball.angle) every frame, and
       rotator._sequence._visible = !hide_show.hideValue. Hiding the ball hides
       ONLY the rotation frames -- the black square and the shading stay. */
    if (!state.hidden) {
      var img = sequence[frameForLongitude(state.angle) - 1];
      if (img) {
        var w = img.naturalWidth || img.width;
        var h = img.naturalHeight || img.height;
        ctx.drawImage(img, -w / 2, -h / 2, w, h);
      }
    }

    /* animation.as: with phases the sun angle tracks the eye; without phases it
       is pinned to 0, which puts the terminator entirely off the disc. */
    drawTerminator(ctx, phaseForSunAngle(state.phases ? state.angle : 0), INIT_DARK_ALPHA);

    ctx.restore();
  }

  /* ==========================================================================
     Descriptions for assistive technology

     Derived from the same numbers that drive the picture, so what is spoken can
     never drift from what is drawn.
     ========================================================================== */

  /* Illuminated fraction: 1 at angle 0 (observer beside the light, ball fully
     lit) falling to 0 at angle 180 (observer opposite the light). */
  function litFraction() {
    if (!state.phases) { return 1; }
    return (1 + Math.cos(state.angle * RAD)) / 2;
  }

  /* Which limb the terminator leaves in shadow -- read straight off the same
     boxDirection test that draws it. */
  function shadedSide() {
    return phaseForSunAngle(state.angle) < Math.PI ? 'left' : 'right';
  }

  function ballDescription() {
    if (state.hidden) {
      return 'The basketball is hidden. Choose Show Basketball to reveal it.';
    }
    if (!state.phases) {
      return 'The basketball is shown evenly lit, with no phase shading.';
    }
    var k = litFraction();
    if (k >= 0.995) { return 'The basketball appears fully lit.'; }
    if (k <= 0.005) { return 'The basketball appears completely dark.'; }
    return 'The basketball appears ' + Math.round(k * 100) +
           ' percent lit, with the ' + shadedSide() + ' side in shadow.';
  }

  function angleSpeech() {
    return 'Viewing angle ' + Math.round(state.angle) + ' degrees';
  }

  function eyeValueText() {
    return angleSpeech() + '. ' + ballDescription();
  }

  function syncDescriptions() {
    var a = Math.round(state.angle);

    eyeHandle.setAttribute('aria-valuenow', String(a));
    eyeHandle.setAttribute('aria-valuetext', eyeValueText());

    orbitDesc.textContent =
      'Overhead view. The basketball is at the centre of a circular track, lit from the left' +
      (state.phases ? ' by four light rays' : ', with the light rays hidden') +
      '. The observer\'s eye is on the track at a viewing angle of ' + a +
      ' degrees, facing the ball.';

    ballDesc.textContent = ballDescription();

    /* Viewing angle, typeset by MathJax through the foundation helper. The
       spoken form carries the quantity name and unit, since the degree symbol
       alone is not reliably announced. */
    if (typeof klunlShowEquation === 'function') {
      klunlShowEquation(
        ['angle-eqn', '\\(\\theta = ' + a + '^\\circ\\)'],
        ['angle-eqn-sr', angleSpeech() + '.']
      );
    }
  }

  /* Typeset math is display-only and must never become a tab stop (WCAG 2.4.3;
     some MathJax builds make their container focusable). */
  function keepMathOutOfTabOrder() {
    var containers = document.querySelectorAll('#angle-eqn mjx-container, #angle-eqn svg');
    for (var i = 0; i < containers.length; i++) {
      containers[i].setAttribute('tabindex', '-1');
    }
  }

  /* Announcements are debounced so that holding an arrow key, or dragging,
     produces one settled message instead of a flood. */
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
    renderBall();
    syncDescriptions();
    keepMathOutOfTabOrder();
  }

  /* ==========================================================================
     Pointer input -- eye_clip.as drag handlers

       the_eye.onMouseMove:
         newAngle = degrees(atan2(_ymouse, _xmouse))
         angle    = 180 + newAngle
         _time    = angle

     Pointer coordinates are mapped back through the current CSS scale so the
     maths runs in original stage units at any display size.
     ========================================================================== */

  function stagePoint(ev) {
    var rect = orbitCanvas.getBoundingClientRect();
    return {
      x: (ev.clientX - rect.left) * (ORBIT_W / rect.width)  - ORBIT_CX,
      y: (ev.clientY - rect.top)  * (ORBIT_H / rect.height) - ORBIT_CY
    };
  }

  /* Flash hit-tests the eye artwork itself. A radius around the eye's centre is
     used instead so the target clears the 44px minimum on touch; the eye is
     about 53 x 74 stage units once scaled. */
  var EYE_GRAB_RADIUS = 38;

  function overEye(p) {
    var eye = eyePosition();
    var dx = p.x - eye.x, dy = p.y - eye.y;
    return dx * dx + dy * dy <= EYE_GRAB_RADIUS * EYE_GRAB_RADIUS;
  }

  function angleFromPoint(p) {
    var newAngle = DEG * Math.atan2(p.y, p.x);
    return mod(180 + newAngle, 360);
  }

  orbitCanvas.addEventListener('pointerdown', function (ev) {
    var p = stagePoint(ev);
    if (!overEye(p)) { return; }
    state.dragging = true;
    syncAnimationLoop();          // a drag takes over from the animation
    /* Click-to-focus: the arrow keys work straight after a click, with no Tab. */
    eyeHandle.focus();
    orbitCanvas.setPointerCapture(ev.pointerId);
    ev.preventDefault();
  });

  orbitCanvas.addEventListener('pointermove', function (ev) {
    var p = stagePoint(ev);
    if (!state.dragging) {
      orbitCanvas.style.cursor = overEye(p) ? 'grab' : 'default';
      return;
    }
    orbitCanvas.style.cursor = 'grabbing';
    setAngle(angleFromPoint(p));
    ev.preventDefault();
  });

  function endDrag(ev) {
    if (!state.dragging) { return; }
    state.dragging = false;
    orbitCanvas.style.cursor = 'default';
    if (ev && ev.pointerId !== undefined && orbitCanvas.hasPointerCapture(ev.pointerId)) {
      orbitCanvas.releasePointerCapture(ev.pointerId);
    }
    syncAnimationLoop();             // resume animating from where the eye landed
    announce(eyeValueText());        // announce on release, not on every tick
  }

  orbitCanvas.addEventListener('pointerup', endDrag);
  orbitCanvas.addEventListener('pointercancel', endDrag);

  /* Both input paths funnel through here, so keyboard, pointer and the
     animation loop all mutate exactly the same state. */
  function setAngle(deg) {
    state.angle = mod(deg, 360);
    state.time  = state.angle;       // eye_clip.as: _parent._time = _parent.angle
    render();
  }

  /* ==========================================================================
     Keyboard input on the eye

     Every mouse-draggable element must also be reachable by Tab, focusable by
     click, and movable with the arrow keys.
     ========================================================================== */

  var STEP_FINE   = 1;      // arrow keys
  var STEP_COARSE = 15;     // Page keys and Shift + arrow

  eyeHandle.addEventListener('keydown', function (ev) {
    var step = ev.shiftKey ? STEP_COARSE : STEP_FINE;
    var next = null;

    switch (ev.key) {
      case 'ArrowRight': case 'ArrowUp':   next = state.angle + step; break;
      case 'ArrowLeft':  case 'ArrowDown': next = state.angle - step; break;
      case 'PageUp':     next = state.angle + STEP_COARSE; break;
      case 'PageDown':   next = state.angle - STEP_COARSE; break;
      case 'Home':       next = 0;   break;    // observer beside the light: fully lit
      case 'End':        next = 180; break;    // observer opposite: fully dark
      default: return;                         // let every other key through, so
                                               // Tab still moves focus away
    }

    ev.preventDefault();
    setAngle(next);
    announce(eyeValueText());
  });

  /* ==========================================================================
     Controls
     ========================================================================== */

  /* hide_show.as: hideHandler / showHandler set hideValue, and the visible
     button swaps. Here that is one button whose label swaps -- the same
     observable behaviour. */
  hideButton.addEventListener('click', function () {
    state.hidden = !state.hidden;
    hideButton.textContent = state.hidden ? 'Show Basketball' : 'Hide Basketball';
    render();
    announce(ballDescription());
  });

  /* man_auto.as: manEye -> value = false, autoEye -> value = true. */
  function onMotionChange() {
    state.animate = eyeAnimate.checked;
    /* eye_clip.as accumulates into _time; restart it from where the eye now is
       so switching modes never jumps the ball. */
    state.time = state.angle;
    lastTime = null;
    syncAnimationLoop();
    render();
    announce(state.animate
      ? 'Animating the eye. ' + speedSpeech() + '.'
      : 'Eye motion stopped. ' + eyeValueText());
  }
  eyeManual.addEventListener('change', onMotionChange);
  eyeAnimate.addEventListener('change', onMotionChange);

  /* phaseRadio.as: noPhases -> value = false, withPhases -> value = true. */
  function onPhaseChange() {
    state.phases = phaseWith.checked;
    render();
    announce(state.phases
      ? 'Phases shown. ' + ballDescription()
      : 'Phases hidden. ' + ballDescription());
  }
  phaseWith.addEventListener('change', onPhaseChange);
  phaseNone.addEventListener('change', onPhaseChange);

  /* Slider v2: value is degrees per millisecond. Spoken as degrees per second,
     which is the figure a listener can actually picture. */
  function speedSpeech() {
    return 'Speed ' + Math.round(state.speed * 1000) + ' degrees per second';
  }

  function onSpeedInput() {
    state.speed = parseFloat(speedRange.value);
    speedRange.setAttribute('aria-valuetext', Math.round(state.speed * 1000) + ' degrees per second');
  }

  speedRange.addEventListener('input', onSpeedInput);
  speedRange.addEventListener('change', function () {
    onSpeedInput();
    announce(speedSpeech() + '.');     // announce on commit, not on every tick
  });

  /* A focused numeric control should also respond to the mouse wheel. */
  speedRange.addEventListener('wheel', function (ev) {
    if (document.activeElement !== speedRange) { return; }
    ev.preventDefault();
    var step = parseFloat(speedRange.step) || 0.001;
    var next = parseFloat(speedRange.value) + (ev.deltaY < 0 ? step : -step);
    next = Math.min(SPEED_MAX, Math.max(SPEED_MIN, next));
    speedRange.value = String(next);
    onSpeedInput();
    announce(speedSpeech() + '.');
  }, { passive: false });

  /* ==========================================================================
     Animation -- eye_clip.as onEnterframe

       var dt = getTimer() - _oldTime;
       _time += dt * _speed;
       angle  = _time % 360;

     The original ran on a 12 fps onEnterFrame but advanced by elapsed
     wall-clock time, so requestAnimationFrame with performance.now() gives
     identical motion on any machine.
     ========================================================================== */

  var lastTime = null;
  var rafId = null;

  function tick(now) {
    if (!state.animate || state.dragging) {   // nothing to advance: stop the loop
      lastTime = null;
      rafId = null;
      return;
    }
    if (lastTime === null) { lastTime = now; }
    var dt = now - lastTime;
    lastTime = now;
    state.time += dt * state.speed;           // degrees, since speed is deg/ms
    state.angle = state.time % 360;
    render();
    rafId = requestAnimationFrame(tick);
  }

  /* The loop only runs while the eye is actually animating, so an idle sim costs
     nothing. Every path that can start or stop motion calls this. */
  function syncAnimationLoop() {
    if (state.animate && !state.dragging) {
      if (rafId === null) { rafId = requestAnimationFrame(tick); }
    } else if (rafId !== null) {
      cancelAnimationFrame(rafId);
      rafId = null;
      lastTime = null;
    }
  }

  /* ==========================================================================
     Reset -- the masthead's Reset button dispatches "sim-reset"
     ========================================================================== */

  document.addEventListener('sim-reset', function () {
    initialState();
    eyeManual.checked  = true;
    eyeAnimate.checked = false;
    phaseWith.checked  = true;
    phaseNone.checked  = false;
    hideButton.textContent = 'Hide Basketball';
    speedRange.value = String(SPEED_INIT);
    onSpeedInput();
    lastTime = null;
    syncAnimationLoop();          // Reset returns to manual, so this stops motion
    render();
    statusRegion.textContent = 'Simulation reset. ' + eyeValueText();
  });

  /* ==========================================================================
     Start-up
     ========================================================================== */

  /* kl-unl.js defines klunlInitEqn as a stub and expects the sim to redefine it;
     this version brings up the equation and the rest of the simulation. */
  window.klunlInitEqn = function () {
    resizeCanvases();
    onSpeedInput();
    render();
  };

  window.addEventListener('resize', function () {
    /* Only the backing-store resolution depends on the device pixel ratio, which
       changes when a window moves between displays or the page is zoomed. */
    resizeCanvases();
    render();
  });

  loadAssets().then(function () {
    klunlInitEqn();
    /* The sim opens in "Move Eye Manually", so nothing is animating yet and the
       loop stays parked until the user asks for motion. */
    syncAnimationLoop();
  });

})();
