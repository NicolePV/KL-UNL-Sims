/* ============================================================================
   Retrograde Motion -- HTML5 port of the Flash (AS1) demonstrator.

   What the original does
   ----------------------
   Earth and a superior planet ("mars") each ride the upper half of an ellipse
   centred on the Sun.  A sight line is drawn from Earth through the planet and
   extended out to a distant line of background stars; where it crosses, a copy
   of the planet is painted.  As the two planets sweep round, Earth -- moving
   faster on the inner orbit -- overtakes the outer planet, and the projected
   planet reverses direction against the stars: retrograde motion.  The user
   either plays the sequence with START / STOP, or scrubs it by hand with the
   timeline marker.

   Everything below is in the original Flash stage coordinate system
   (700 x 600 px, y increasing downwards).  The canvas keeps that internal
   system and CSS scales it, so no physics or geometry is ever recomputed from
   the on-screen size.
   ========================================================================== */

(function () {
  "use strict";

  /* ---------------------------------------------------------------------- */
  /* Constants, all copied verbatim from the decompiled ActionScript         */
  /* ---------------------------------------------------------------------- */

  var STAGE_W = 700;
  var STAGE_H = 600;

  // Placement of the "retrograde" sprite on the stage; its origin is the Sun.
  var SUN_X = 349.95;
  var SUN_Y = 556;

  // Orbits, from  y = -sqrt(B2 * (1 - x^2 / A2))  in the frame scripts:
  //   Earth  x^2/22500 + y^2/11025 = 1   (a = 150, b = 105)
  //   planet x^2/40000 + y^2/19600 = 1   (a = 200, b = 140)
  var EARTH_A2 = 22500, EARTH_B2 = 11025;
  var MARS_A2  = 40000, MARS_B2  = 19600;

  // Starting positions and per-frame steps:  earth._x = 150 - temp * 1.3
  //                                          mars._x  = 135 - temp * 1.05
  var EARTH_X0   = 150,  MARS_X0   = 135;
  var EARTH_RATE = 1.3,  MARS_RATE = 1.05;
  var EARTH_MIN_X = -149, MARS_MIN_X = -125;

  // The distant "background stars" line the sight line is projected onto.
  var RETRO_Y = -400;

  // The original SWF runs at 12 frames per second and advances one timeline
  // unit per frame, so the animation is driven by elapsed wall-clock time at
  // this rate rather than by frame counts.
  var FPS = 12;

  // Marker travel: onClipEvent(load) sets right = left + 250, and
  // onClipEvent(enterFrame) sets temp = _x - left.
  var TEMP_MAX = 250;

  // The animation ends when the planet reaches its clamp:
  //   135 - temp * 1.05 = -125  ->  temp = 247.619...
  var TEMP_END = (MARS_X0 - MARS_MIN_X) / MARS_RATE;

  // Sizes of the exported symbols, in stage pixels.
  var PLANET_SIZE = 26;   // earth and mars sprites are 26 x 26, centre origin
  var SUN_SIZE    = 50;   // sun symbol is 50 x 50, centre origin

  var SIGHT_COLOR = "#ff00ff";  // line.lineStyle(2, 16711935, 100)
  var SIGHT_WIDTH = 2;

  // Annotation strings, verbatim from DefineSprite_12 frame 4 (including the
  // embedded line breaks).  These are shown only while the animation runs;
  // frame 2 -- the timeline-scrubbing state -- always blanks the label.
  var MSG_EAST_FIRST  = "The planet is initially moving \neastward relative to the background stars";
  var MSG_WEST        = "The planet slows, stops and begins moving \nwestward relative to the background stars";
  var MSG_EAST_AGAIN  = "The planet now slows, stops and begins \nmoving eastward again";

  /* ---------------------------------------------------------------------- */
  /* State -- the single source of truth                                     */
  /* ---------------------------------------------------------------------- */

  var INITIAL_STATE = { temp: 0, playing: false };

  var state = {
    temp:    INITIAL_STATE.temp,     // timeline position, 0 .. 250
    playing: INITIAL_STATE.playing   // true while the animation is running
  };

  /* ---------------------------------------------------------------------- */
  /* Elements                                                                */
  /* ---------------------------------------------------------------------- */

  var canvas, ctx;
  var slider, valueOut, startStopBtn, restartBtn, caption, stageDesc;

  var images   = {};
  var imgReady = false;

  var rafId      = 0;
  var lastTickMs = 0;
  var lastSpokenMessage = null;

  /* ---------------------------------------------------------------------- */
  /* Geometry                                                                */
  /* ---------------------------------------------------------------------- */

  // Orbital position for a given timeline value.  Both planets are clamped
  // exactly as the ActionScript clamps them, and both stay on the upper half
  // of their ellipse (the source negates the square root).
  function positionsAt(temp) {
    var earthX = EARTH_X0 - temp * EARTH_RATE;
    var marsX  = MARS_X0  - temp * MARS_RATE;

    if (earthX <= EARTH_MIN_X) { earthX = EARTH_MIN_X; }
    if (marsX  <= MARS_MIN_X)  { marsX  = MARS_MIN_X;  }

    var earthY = -1 * Math.sqrt(EARTH_B2 * (1 - (earthX * earthX) / EARTH_A2));
    var marsY  = -1 * Math.sqrt(MARS_B2  * (1 - (marsX  * marsX)  / MARS_A2));

    // Sight line Earth -> planet, extended to the background-star line y = -400.
    //   m = (mars.y - earth.y) / (mars.x - earth.x)
    //   b = earth.y - m * earth.x
    //   x = (-400 - b) / m
    var retroX;
    var dx = marsX - earthX;

    if (Math.abs(dx) < 1e-9) {
      // Earth passes the planet: the sight line is exactly vertical.  The AS
      // divides by zero here and yields NaN; the limit of its own formula is
      // simply the shared x, which is what we use.
      retroX = earthX;
    } else {
      var m = (marsY - earthY) / dx;
      var b = earthY - m * earthX;
      retroX = (RETRO_Y - b) / m;
    }

    return {
      earthX: earthX, earthY: earthY,
      marsX:  marsX,  marsY:  marsY,
      retroX: retroX, retroY: RETRO_Y
    };
  }

  // Angle along the orbit, measured from the right-hand end (0 degrees) round
  // the top of the diagram to the left-hand end (180 degrees).
  function orbitAngleDeg(x, y) {
    return Math.atan2(-y, x) * 180 / Math.PI;
  }

  // Which way the projected planet is drifting against the stars right now.
  // On screen, east is to the left, so a decreasing x is eastward motion.
  function apparentDirection(temp) {
    var lo = Math.max(0, temp - 0.5);
    var hi = Math.min(TEMP_MAX, temp + 0.5);
    if (hi <= lo) { return "stationary"; }

    var delta = positionsAt(hi).retroX - positionsAt(lo).retroX;

    if (Math.abs(delta) < 0.01) { return "momentarily stationary"; }
    return delta > 0 ? "westward" : "eastward";
  }

  /* ---------------------------------------------------------------------- */
  /* Text                                                                    */
  /* ---------------------------------------------------------------------- */

  // The annotation shown while the animation runs, exactly as frame 4 selects
  // it from _root.time.temp.  Outside the animation it is always blank, which
  // is what frame 2 does.
  function messageFor(temp, playing) {
    if (!playing) { return ""; }

    if (temp < 20) {
      return MSG_EAST_FIRST;
    } else if (temp >= 26 && temp < 70) {
      return MSG_WEST;
    } else if (temp >= 137 && temp < 200) {
      return MSG_EAST_AGAIN;
    }
    return "";
  }

  function timelinePercent(temp) {
    return Math.round((temp / TEMP_MAX) * 100);
  }

  // Everything spoken carries its quantity name and its unit; a bare number is
  // never announced.
  function sliderValueText(temp) {
    return "timeline " + timelinePercent(temp) + " percent";
  }

  function describeDiagram(p, temp) {
    var earthDeg = Math.round(orbitAngleDeg(p.earthX, p.earthY));
    var marsDeg  = Math.round(orbitAngleDeg(p.marsX,  p.marsY));

    // Where the projected planet falls across the sky, from the east edge of
    // the star field to the west edge.
    var skyPct = Math.round((p.retroX + SUN_X) / STAGE_W * 100);
    if (skyPct < 0)   { skyPct = 0; }
    if (skyPct > 100) { skyPct = 100; }

    return "Timeline " + timelinePercent(temp) + " percent. " +
           "Earth is " + earthDeg + " degrees around its orbit and the superior planet is " +
           marsDeg + " degrees around its orbit, both measured from the right-hand side. " +
           "Seen from Earth, the planet appears " + skyPct +
           " percent of the way from east to west across the background stars, moving " +
           apparentDirection(temp) + ".";
  }

  /* ---------------------------------------------------------------------- */
  /* Rendering                                                               */
  /* ---------------------------------------------------------------------- */

  function sizeCanvas() {
    var dpr = window.devicePixelRatio || 1;

    canvas.width  = Math.round(STAGE_W * dpr);
    canvas.height = Math.round(STAGE_H * dpr);

    ctx = canvas.getContext("2d");
    ctx.setTransform(dpr, 0, 0, dpr, 0, 0);
  }

  function drawCentered(img, cx, cy, size) {
    ctx.drawImage(img, cx - size / 2, cy - size / 2, size, size);
  }

  // One render() redraws the canvas and syncs every piece of DOM from state, so
  // the picture, the controls and the spoken description can never drift apart.
  function render(announce) {
    var p = positionsAt(state.temp);

    if (imgReady && ctx) {
      ctx.clearRect(0, 0, STAGE_W, STAGE_H);

      // Sight line first: in the original it lives below the planet symbols.
      ctx.save();
      ctx.strokeStyle = SIGHT_COLOR;
      ctx.lineWidth   = SIGHT_WIDTH;
      ctx.lineCap     = "round";
      ctx.beginPath();
      ctx.moveTo(SUN_X + p.earthX, SUN_Y + p.earthY);
      ctx.lineTo(SUN_X + p.retroX, SUN_Y + p.retroY);
      ctx.stroke();
      ctx.restore();

      // Exported bitmaps, reused as-is at their original sizes and z-order:
      // earth, planet, projected planet, then the Sun on top.
      drawCentered(images.earth, SUN_X + p.earthX, SUN_Y + p.earthY, PLANET_SIZE);
      drawCentered(images.mars,  SUN_X + p.marsX,  SUN_Y + p.marsY,  PLANET_SIZE);
      drawCentered(images.mars,  SUN_X + p.retroX, SUN_Y + p.retroY, PLANET_SIZE);
      drawCentered(images.sun,   SUN_X,            SUN_Y,            SUN_SIZE);
    }

    // Controls
    var shown = Math.round(state.temp);
    if (slider.value !== String(shown)) { slider.value = String(shown); }
    slider.setAttribute("aria-valuetext", sliderValueText(state.temp));
    valueOut.textContent = timelinePercent(state.temp) + "%";

    startStopBtn.textContent = state.playing ? "STOP" : "START";

    // Annotation. Only written when it actually changes, so the live region
    // speaks at each transition rather than on every animation tick.
    var msg = messageFor(state.temp, state.playing);
    if (msg !== lastSpokenMessage) {
      caption.textContent = msg;
      lastSpokenMessage   = msg;
      // A transition in the annotation is a meaningful moment in the animation,
      // so refresh the diagram description with it.
      announce = true;
    }

    // Diagram description, announced on commit only (never per tick).
    if (announce) {
      stageDesc.textContent = describeDiagram(p, state.temp);
    }
  }

  /* ---------------------------------------------------------------------- */
  /* Animation                                                               */
  /* ---------------------------------------------------------------------- */

  function tick(nowMs) {
    if (!state.playing) { return; }

    var dt = nowMs - lastTickMs;
    lastTickMs = nowMs;

    // Guard against the huge dt a backgrounded tab hands back on return.
    if (dt < 0)   { dt = 0; }
    if (dt > 250) { dt = 250; }

    state.temp += (dt / 1000) * FPS;

    if (state.temp >= TEMP_END) {
      // The planet has reached its clamp: the original stops the animation and
      // flips the button back to START.
      state.temp   = TEMP_END;
      state.playing = false;
      render(true);
      return;
    }

    render(false);
    rafId = window.requestAnimationFrame(tick);
  }

  function play() {
    if (state.playing) { return; }
    if (state.temp >= TEMP_END) { state.temp = 0; }  // nothing left to run

    state.playing = true;
    lastTickMs = (window.performance && performance.now) ? performance.now() : Date.now();
    render(true);
    rafId = window.requestAnimationFrame(tick);
  }

  function pause() {
    if (!state.playing) { return; }
    state.playing = false;
    window.cancelAnimationFrame(rafId);
    render(true);
  }

  function restart() {
    state.playing = false;
    window.cancelAnimationFrame(rafId);
    state.temp = 0;
    render(true);
  }

  /* ---------------------------------------------------------------------- */
  /* Events                                                                  */
  /* ---------------------------------------------------------------------- */

  function onSliderInput() {
    // The original blocks the marker while the animation runs.  Silently
    // dropping keyboard or pointer input is worse for accessibility than
    // honouring it, so scrubbing simply stops the animation first; the physics
    // is untouched either way.
    if (state.playing) {
      state.playing = false;
      window.cancelAnimationFrame(rafId);
    }

    var v = parseFloat(slider.value);
    state.temp = isNaN(v) ? 0 : Math.min(Math.max(v, 0), TEMP_MAX);
    render(false);
  }

  function onSliderCommit() {
    render(true);
  }

  // Mouse wheel adjusts the focused slider by one step, matching its arrow keys.
  function onSliderWheel(e) {
    if (document.activeElement !== slider) { return; }
    e.preventDefault();

    var step = e.deltaY < 0 ? 1 : -1;
    slider.value = String(Math.min(Math.max(parseFloat(slider.value) + step, 0), TEMP_MAX));
    onSliderInput();
    onSliderCommit();
  }

  function onReset() {
    state.temp    = INITIAL_STATE.temp;
    state.playing = INITIAL_STATE.playing;
    window.cancelAnimationFrame(rafId);
    render(true);
  }

  /* ---------------------------------------------------------------------- */
  /* Boot                                                                    */
  /* ---------------------------------------------------------------------- */

  function loadImages(done) {
    var sources = {
      earth: "assets/earth.png",
      mars:  "assets/mars.png",
      sun:   "assets/sun.png"
    };
    var keys      = Object.keys(sources);
    var remaining = keys.length;

    keys.forEach(function (key) {
      var img = new Image();
      img.onload = img.onerror = function () {
        remaining -= 1;
        if (remaining === 0) { done(); }
      };
      img.src = sources[key];
      images[key] = img;
    });
  }

  var booted = false;

  function boot() {
    if (booted) { return; }
    booted = true;

    canvas       = document.getElementById("stage-canvas");
    slider       = document.getElementById("timeline-range");
    valueOut     = document.getElementById("timeline-value");
    startStopBtn = document.getElementById("startstop-btn");
    restartBtn   = document.getElementById("restart-btn");
    caption      = document.getElementById("sim-status");
    stageDesc    = document.getElementById("stage-desc");

    sizeCanvas();

    slider.addEventListener("input",  onSliderInput);
    slider.addEventListener("change", onSliderCommit);
    slider.addEventListener("wheel",  onSliderWheel, { passive: false });

    startStopBtn.addEventListener("click", function () {
      if (state.playing) { pause(); } else { play(); }
    });

    // The original disables RESTART mid-animation; here it always works, which
    // spares keyboard users a control that refuses input without explanation.
    restartBtn.addEventListener("click", restart);

    // Reset comes from the shared masthead (sim-reset event); there is no
    // second Reset button in the sim.
    document.addEventListener("sim-reset", onReset);

    // Redraw at the new backing resolution if the page moves between displays.
    window.addEventListener("resize", function () {
      sizeCanvas();
      render(false);
    });

    loadImages(function () {
      imgReady = true;
      render(true);
    });

    render(true);
  }

  // The foundation calls klunlInitEqn() to initialise sim components; redefining
  // it here supersedes the default. This sim shows no equations, so it only
  // needs to bring the simulation up.
  window.klunlInitEqn = boot;

  if (window.MathJax && window.MathJax.startup && window.MathJax.startup.promise) {
    window.MathJax.startup.promise.then(boot, boot);
  } else if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", boot);
  } else {
    boot();
  }
})();
