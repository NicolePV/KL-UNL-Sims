/* ==========================================================================
 * Eclipse Shadow Simulator  --  accessible HTML5 port of shadows003.swf
 *
 * BEHAVIOR is a verbatim port of the decompiled ActionScript (AS1):
 *   - scripts/Shadow.as               -> Shadow.update() umbra/penumbra geometry
 *   - scripts/frame_1/DoAction.as     -> drag + collision/clamp logic
 *
 * All drawing math runs in the ORIGINAL 900x500 Flash stage coordinate system.
 * The canvas backing store is scaled by devicePixelRatio for crispness and the
 * canvas ELEMENT is scaled by CSS to fit its panel, so the ported geometry
 * never needs to know the on-screen size (parity is preserved at any size).
 * ========================================================================== */

(function () {
  "use strict";

  /* ---- Fixed stage constants, taken from the SWF PlaceObject matrices ----- */
  var STAGE_W = 900;
  var STAGE_H = 500;

  // Sun: char 4, scale 0.2283173 * 438px art => 100px diameter, centered (54,250).
  // The Sun is NOT draggable in the original (only Earth and Moon have onPress).
  var SUN = { x: 54, y: 250, r: 50 };           // r = sunMC._width / 2

  // Earth: char 6, scale 0.3846130 * 130px => 50px diameter (r = 25) at (310.8,203.9)
  // Moon:  char 2, scale 0.5        * 40px  => 20px diameter (r = 10) at (327.9,313.9)
  var EARTH_INIT = { x: 310.8, y: 203.9 };
  var MOON_INIT  = { x: 327.9, y: 313.9 };
  var EARTH_R = 25;
  var MOON_R  = 10;

  var DRAG_MARGIN = 20;                          // "margin" in onMouseMoveFunc

  // Shadow fill/line colors -- copied verbatim from Shadow.as (AS color ints).
  //   penumbra fill  beginFill(5263440, 10)  -> 0x505050 @ 10%
  //   umbra    fill  beginFill(11579568, 90) -> 0xB0B0B0 @ 90%
  //   boundary lines lineStyle(0, 5263440, 50) -> 0x505050 @ 50%
  var C_PENUMBRA = "rgba(80,80,80,0.10)";       // 5263440  = 0x505050
  var C_UMBRA    = "rgba(176,176,176,0.90)";    // 11579568 = 0xB0B0B0
  var C_LINE     = "rgba(80,80,80,0.50)";

  /* ---- Single source of truth --------------------------------------------- */
  var state = {
    earth:   { x: EARTH_INIT.x, y: EARTH_INIT.y },
    moon:    { x: MOON_INIT.x,  y: MOON_INIT.y },
    focused: null                 // 'earth' | 'moon' | null  ("focus mode")
  };

  /* ---- DOM handles -------------------------------------------------------- */
  var canvas, ctx, dpr;
  var els = {};
  var handles = { earth: null, moon: null };   // focusable disc overlays
  var imgs = { sun: null, earth: null, moon: null };
  var drag = null;   // { which:'earth'|'moon', offX, offY }

  /* ======================================================================== *
   *  GEOMETRY  --  verbatim port of Shadow.as update()
   *  The shadow MovieClip is placed at the Sun center (54,250); the object
   *  (Earth or Moon) is passed as the "illuminant position". s = source
   *  (Sun) radius, r = object radius, d = Sun->object distance.
   *  Returns polygons already translated into stage coordinates.
   * ======================================================================== */
  function computeShadow(objX, objY, r) {
    var s = SUN.r;                 // illuminantRadius (sunMC._width / 2)

    var x = objX - SUN.x;          // illuminantX - this._x
    var y = objY - SUN.y;          // illuminantY - this._y
    var d = Math.sqrt(x * x + y * y);
    var angle  = Math.atan2(y, x);
    var cAngle = Math.cos(angle);
    var sAngle = Math.sin(angle);
    var k0 = cAngle, k1 = -sAngle, k2 = sAngle, k3 = cAngle;

    // Internal-tangent branch (sa) -> penumbra edges
    var sa = (s + r) / d;
    var a  = Math.asin(sa);
    var ca = Math.cos(a);
    var ta = Math.tan(a);
    var x1 = s * sa,  y1 = s * ca;
    var x2 = d - r * sa, y2 = r * ca;
    var x3 = s / sa,  y3 = 0;
    var x4 = 1200,    y4 = (x4 - x3) * ta;

    // External-tangent branch (sb) -> umbra edges
    var sb = (s - r) / d;
    var b  = Math.asin(sb);
    var cb = Math.cos(b);
    var tb = Math.tan(b);
    var x5 = s * sb,  y5 = s * cb;
    var x6 = d + r * sb, y6 = r * cb;
    var x7 = d + r / sb, y7 = 0;
    var x8 = 1200,    y8 = (x8 - x7) * tb;

    // Mirror ("prime") points across the shadow axis
    var x1p = x1, y1p = -y1;
    var x2p = x2, y2p = -y2;
    var x4p = x4, y4p = -y4;
    var x5p = x5, y5p = -y5;
    var x6p = x6, y6p = -y6;
    var x8p = x8, y8p = -y8;

    // Rotate every point by the Sun->object angle (k matrix), then translate
    // to the Sun center. Screen Y is down in both Flash and canvas, so the
    // arithmetic is copied without sign changes.
    function P(px, py) {
      return { x: SUN.x + (k0 * px + k1 * py), y: SUN.y + (k2 * px + k3 * py) };
    }
    var X1 = P(x1, y1),  X2 = P(x2, y2),  X4 = P(x4, y4);
    var X6 = P(x6, y6),  X7 = P(x7, y7),  X8 = P(x8, y8);
    var X2p = P(x2p, y2p), X4p = P(x4p, y4p);
    var X6p = P(x6p, y6p), X8p = P(x8p, y8p);

    return {
      penumbra: [X2, X4, X4p, X2p],            // beginFill(0x505050,10) quad
      umbra:    [X6, X6p, X7],                 // beginFill(0xB0B0B0,90) triangle
      antumbra: [X7, X8, X8p],                 // stroked-only outline past umbra tip
      d: d
    };
  }

  /* ======================================================================== *
   *  CONSTRAINTS  --  verbatim port of onMouseMoveFunc()
   *  Given a desired center, returns the allowed center: pushed out of the
   *  no-overlap circle around the Sun, then clamped to the stage.
   * ======================================================================== */
  function constrain(objW, desiredX, desiredY) {
    var newX = desiredX, newY = desiredY;
    var sunW = SUN.r * 2;                        // sunMC._width
    var margin = DRAG_MARGIN;

    var xs = newX - SUN.x;
    var ys = newY - SUN.y;
    var ds = Math.sqrt(xs * xs + ys * ys);
    var minD = (sunW + objW) / 2 + margin;

    if (ds < minD) {
      var as = Math.atan2(ys, xs);
      ds = minD;
      xs = ds * Math.cos(as);
      ys = ds * Math.sin(as);
      newX = xs + SUN.x;
      newY = ys + SUN.y;
    }

    if (newX < 0) {
      newX = 0;
      var delta = Math.sqrt(Math.pow(minD, 2) - Math.pow(SUN.x, 2));
      if (newY < SUN.y && newY > SUN.y - delta) {
        newY = SUN.y - delta;
      } else if (newY >= SUN.y && newY < SUN.y + delta) {
        newY = SUN.y + delta;
      }
    } else if (newX > 900) {
      newX = 900;
    }

    if (newY < 0) { newY = 0; }
    else if (newY > 500) { newY = 500; }

    return { x: newX, y: newY };
  }

  function objRadius(which) { return which === "earth" ? EARTH_R : MOON_R; }
  function objWidth(which)  { return objRadius(which) * 2; }

  /* Move an object to a desired center (applies parity constraints). */
  function moveObject(which, desiredX, desiredY) {
    var p = constrain(objWidth(which), desiredX, desiredY);
    state[which].x = p.x;
    state[which].y = p.y;
  }

  /* ======================================================================== *
   *  RENDER  --  redraws canvas + syncs sliders/readouts/description
   * ======================================================================== */
  function drawShadow(objX, objY, r) {
    var sh = computeShadow(objX, objY, r);

    // Penumbra: filled AND stroked (lineStyle is active in the AS)
    poly(sh.penumbra); ctx.fillStyle = C_PENUMBRA; ctx.fill();
    ctx.strokeStyle = C_LINE; ctx.lineWidth = 1; ctx.stroke();

    // Umbra: filled AND stroked
    poly(sh.umbra); ctx.fillStyle = C_UMBRA; ctx.fill(); ctx.stroke();

    // Antumbra: stroked outline only (no beginFill in the AS after endFill)
    poly(sh.antumbra); ctx.stroke();

    return sh;
  }

  function poly(pts) {
    ctx.beginPath();
    ctx.moveTo(pts[0].x, pts[0].y);
    for (var i = 1; i < pts.length; i++) { ctx.lineTo(pts[i].x, pts[i].y); }
    ctx.closePath();
  }

  function disc(img, cx, cy, r) {
    if (img && img.complete && img.naturalWidth) {
      ctx.drawImage(img, cx - r, cy - r, r * 2, r * 2);
    }
  }

  function render() {
    // Clear to the stage background (white, matching the original stage)
    ctx.save();
    ctx.setTransform(dpr, 0, 0, dpr, 0, 0);
    ctx.clearRect(0, 0, STAGE_W, STAGE_H);
    ctx.fillStyle = "#ffffff";
    ctx.fillRect(0, 0, STAGE_W, STAGE_H);

    // z-order from the SWF: earthShadow(1), moonShadow(3), earthMC(5),
    // sunMC(7), moonMC(9)  -> shadows first, then Earth, Sun, Moon.
    var eSh = drawShadow(state.earth.x, state.earth.y, EARTH_R);
    var mSh = drawShadow(state.moon.x,  state.moon.y,  MOON_R);
    disc(imgs.earth, state.earth.x, state.earth.y, EARTH_R);
    disc(imgs.sun,   SUN.x,        SUN.y,          SUN.r);
    disc(imgs.moon,  state.moon.x, state.moon.y,   MOON_R);

    // "Focus mode": ring the disc that currently has keyboard focus.
    if (state.focused) {
      var fo = state[state.focused];
      var fr = objRadius(state.focused);
      ctx.strokeStyle = "#005fcc";
      ctx.lineWidth = 2;
      ctx.setLineDash([6, 4]);
      ctx.beginPath();
      ctx.arc(fo.x, fo.y, fr + 6, 0, Math.PI * 2);
      ctx.stroke();
      ctx.setLineDash([]);
    }
    ctx.restore();

    positionHandles();
    syncControls(eSh, mSh);
  }

  /* Keep each focusable handle sized/placed over its disc, in CSS pixels
     relative to the stage wrapper (which tightly wraps the canvas). */
  function positionHandles() {
    var w = canvas.clientWidth;
    if (!w) { return; }              // not laid out yet
    var scale = w / STAGE_W;         // CSS px per stage unit
    place(handles.earth, state.earth, EARTH_R, scale);
    place(handles.moon,  state.moon,  MOON_R,  scale);
  }

  function place(handle, obj, r, scale) {
    var d = 2 * r * scale;
    handle.style.width  = d + "px";
    handle.style.height = d + "px";
    handle.style.left   = (obj.x * scale - d / 2) + "px";
    handle.style.top    = (obj.y * scale - d / 2) + "px";
  }

  /* ---- Keep DOM controls + accessible text in sync with state ------------- */
  function fmt(n) { return Math.round(n); }

  function bodyText(name, obj, r, sh) {
    return name + " at horizontal " + fmt(obj.x) + " pixels, vertical " +
      fmt(obj.y) + " pixels. Distance from the Sun " + fmt(sh.d) +
      " pixels. Umbra tip about " + fmt(sh.d) + " pixels beyond, then a " +
      "spreading penumbra.";
  }

  function syncControls(eSh, mSh) {
    setSlider("earthX", state.earth.x,
      "Earth horizontal position: " + fmt(state.earth.x) + " pixels from the left edge, range 0 to 900");
    setSlider("earthY", state.earth.y,
      "Earth vertical position: " + fmt(state.earth.y) + " pixels from the top edge, range 0 to 500");
    setSlider("moonX", state.moon.x,
      "Moon horizontal position: " + fmt(state.moon.x) + " pixels from the left edge, range 0 to 900");
    setSlider("moonY", state.moon.y,
      "Moon vertical position: " + fmt(state.moon.y) + " pixels from the top edge, range 0 to 500");

    els.earthXval.value = fmt(state.earth.x) + " px";
    els.earthYval.value = fmt(state.earth.y) + " px";
    els.moonXval.value  = fmt(state.moon.x)  + " px";
    els.moonYval.value  = fmt(state.moon.y)  + " px";

    els.earthReadout.textContent =
      "Distance from Sun: " + fmt(eSh.d) + " pixels.";
    els.moonReadout.textContent =
      "Distance from Sun: " + fmt(mSh.d) + " pixels.";

    els.stageDesc.textContent =
      "Diagram of the Sun at the left (fixed) with two draggable discs that " +
      "cast shadows to the right. " +
      bodyText("Earth, the large blue disc,", state.earth, EARTH_R, eSh) + " " +
      bodyText("Moon, the small gray disc,", state.moon, MOON_R, mSh);

    handles.earth.setAttribute("aria-label", handleLabel("Earth", state.earth));
    handles.moon.setAttribute("aria-label",  handleLabel("Moon",  state.moon));
  }

  function handleLabel(name, obj) {
    return name + " disc, horizontal " + fmt(obj.x) + " pixels, vertical " +
      fmt(obj.y) + " pixels. Use the arrow keys to move; hold Shift for larger steps.";
  }

  function setSlider(id, value, valueText) {
    var el = els[id];
    var v = String(fmt(value));
    if (el.value !== v) { el.value = v; }
    el.setAttribute("aria-valuetext", valueText);
  }

  var liveTimer = null;
  function announce(msg) {
    // Debounce so dragging/holding an arrow key doesn't flood the live region.
    if (liveTimer) { clearTimeout(liveTimer); }
    liveTimer = setTimeout(function () { els.live.textContent = msg; }, 120);
  }

  function announceBody(which) {
    var obj = state[which];
    var name = which === "earth" ? "Earth" : "Moon";
    var sh = computeShadow(obj.x, obj.y, objRadius(which));
    announce(name + " moved to horizontal " + fmt(obj.x) +
      " pixels, vertical " + fmt(obj.y) + " pixels. Distance from the Sun " +
      fmt(sh.d) + " pixels.");
  }

  /* ======================================================================== *
   *  POINTER DRAG  --  Pointer Events so mouse + touch share one path
   * ======================================================================== */
  function stageCoords(e) {
    var rect = canvas.getBoundingClientRect();
    return {
      x: (e.clientX - rect.left) / rect.width * STAGE_W,
      y: (e.clientY - rect.top) / rect.height * STAGE_H
    };
  }

  function hitTest(sx, sy) {
    // Moon is on top (depth 9) so test it first, then Earth (depth 5).
    if (Math.hypot(sx - state.moon.x, sy - state.moon.y) <= MOON_R) return "moon";
    if (Math.hypot(sx - state.earth.x, sy - state.earth.y) <= EARTH_R) return "earth";
    return null;
  }

  function onPointerDown(e) {
    var p = stageCoords(e);
    var which = hitTest(p.x, p.y);
    if (!which) { return; }
    // Clicking a disc turns on "focus mode": move keyboard focus to its handle
    // and light the ring immediately (don't rely on the focus event alone).
    state.focused = which;
    handles[which].focus();
    render();
    // xOffset/yOffset from onPressFunc: keep the grab point under the pointer.
    drag = { which: which, offX: p.x - state[which].x, offY: p.y - state[which].y };
    canvas.setPointerCapture(e.pointerId);
    canvas.style.cursor = "grabbing";
    e.preventDefault();
  }

  function onPointerMove(e) {
    if (!drag) { return; }
    var p = stageCoords(e);
    moveObject(drag.which, p.x - drag.offX, p.y - drag.offY);
    render();
    e.preventDefault();
  }

  function onPointerUp(e) {
    if (!drag) { return; }
    var which = drag.which;
    drag = null;
    canvas.style.cursor = "grab";
    announceBody(which);          // announce on commit, not every tick
    if (canvas.hasPointerCapture(e.pointerId)) {
      canvas.releasePointerCapture(e.pointerId);
    }
  }

  function onHoverCursor(e) {
    if (drag) { return; }
    var p = stageCoords(e);
    canvas.style.cursor = hitTest(p.x, p.y) ? "grab" : "default";
  }

  /* ======================================================================== *
   *  SLIDER (keyboard) PATH  --  native range inputs give arrows/Page/Home/End
   * ======================================================================== */
  function bindSlider(id, which, axis) {
    els[id].addEventListener("input", function () {
      var v = Number(els[id].value);
      if (axis === "x") { moveObject(which, v, state[which].y); }
      else              { moveObject(which, state[which].x, v); }
      render();
    });
    els[id].addEventListener("change", function () { announceBody(which); });
  }

  /* ======================================================================== *
   *  DISC HANDLE (keyboard) PATH  --  Tab to a disc, arrow keys to move it
   * ======================================================================== */
  function bindHandle(which) {
    var handle = handles[which];

    // Focus mode on/off (also drives the on-canvas ring).
    handle.addEventListener("focus", function () {
      state.focused = which;
      render();
    });
    handle.addEventListener("blur", function () {
      if (state.focused === which) { state.focused = null; render(); }
    });

    handle.addEventListener("keydown", function (e) {
      var step = e.shiftKey ? 10 : 1;
      var dx = 0, dy = 0;
      switch (e.key) {
        case "ArrowLeft":  dx = -step; break;
        case "ArrowRight": dx =  step; break;
        case "ArrowUp":    dy = -step; break;   // up on screen = smaller y
        case "ArrowDown":  dy =  step; break;
        default: return;                        // let Tab, etc. behave normally
      }
      e.preventDefault();                        // don't scroll the page
      moveObject(which, state[which].x + dx, state[which].y + dy);
      render();
      announceBody(which);                       // debounced live announcement
    });
  }

  /* ======================================================================== *
   *  RESET  --  driven by the masthead 'sim-reset' event
   * ======================================================================== */
  function resetState() {
    state.earth.x = EARTH_INIT.x; state.earth.y = EARTH_INIT.y;
    state.moon.x  = MOON_INIT.x;  state.moon.y  = MOON_INIT.y;
    render();
    announce("Simulation reset. Earth and Moon returned to their starting positions.");
  }

  /* ======================================================================== *
   *  SETUP
   * ======================================================================== */
  function setupCanvas() {
    dpr = Math.min(window.devicePixelRatio || 1, 2);
    canvas.width  = STAGE_W * dpr;
    canvas.height = STAGE_H * dpr;
  }

  function loadImage(src) {
    var img = new Image();
    img.src = src;
    img.onload = render;   // re-render as each disc art arrives
    return img;
  }

  function init() {
    canvas = document.getElementById("stage");
    ctx = canvas.getContext("2d");

    var ids = ["earthX", "earthY", "moonX", "moonY",
               "earthXval", "earthYval", "moonXval", "moonYval"];
    ids.forEach(function (id) { els[id] = document.getElementById(id); });
    els.earthReadout = document.getElementById("earth-readout");
    els.moonReadout  = document.getElementById("moon-readout");
    els.stageDesc    = document.getElementById("stage-desc");
    els.live         = document.getElementById("live");
    handles.earth    = document.getElementById("earth-handle");
    handles.moon     = document.getElementById("moon-handle");

    setupCanvas();

    imgs.sun   = loadImage("assets/sun.png");
    imgs.earth = loadImage("assets/earth.png");
    imgs.moon  = loadImage("assets/moon.png");

    // Pointer drag (mouse + touch); touch-action:none is set in CSS on the canvas
    canvas.addEventListener("pointerdown", onPointerDown);
    canvas.addEventListener("pointermove", onPointerMove);
    canvas.addEventListener("pointerup", onPointerUp);
    canvas.addEventListener("pointercancel", onPointerUp);
    canvas.addEventListener("pointermove", onHoverCursor);

    bindSlider("earthX", "earth", "x");
    bindSlider("earthY", "earth", "y");
    bindSlider("moonX",  "moon",  "x");
    bindSlider("moonY",  "moon",  "y");

    bindHandle("earth");
    bindHandle("moon");

    document.addEventListener("sim-reset", resetState);

    // Recompute the backing store if the device pixel ratio changes (e.g. the
    // window is dragged between monitors). Redraw at the new resolution.
    if (window.matchMedia) {
      window.addEventListener("resize", function () {
        var d = Math.min(window.devicePixelRatio || 1, 2);
        if (d !== dpr) { setupCanvas(); }
        render();
      });
    }

    render();
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", init);
  } else {
    init();
  }
})();
