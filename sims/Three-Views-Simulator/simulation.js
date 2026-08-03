/* =============================================================================
 * Three Views Simulator  (ClassAction / NAAP "moonphases.swf")  ->  HTML5
 * -----------------------------------------------------------------------------
 * Faithful port of the decompiled ActionScript-1 behaviour. All physics
 * constants, formulas and geometry are copied VERBATIM from the source
 * (animation.as, sunEarth.as, tideAnim.as, earth.as, moon.as,
 *  moonPhaseSymbol.as, MoonRotator.as). Presentation follows the KL-UNL shell.
 *
 * Behaviour model (see CONVERSION_NOTES.md for the full derivation):
 *   - A hidden "clock" moon advances an angle at a rate set by the speed slider.
 *   - That angle drives everything: the Moon's orbital position, the Earth's
 *     spin (28 rotations per orbit), and the Earth's slow revolution about the
 *     Sun (27.6 deg per synodic cycle).
 *   - The right-hand "View of Moon" panel shows the Moon as seen From Earth,
 *     From Sun, or From a point in Space, each rendered with the original's
 *     terminator-mask (a dark lune drawn over a reused Moon photograph).
 * ========================================================================== */

'use strict';

/* ------------------------------------------------------------------ helpers */
const DEG = 180 / Math.PI;          // radians -> degrees   (57.29577951308232)
const RAD = Math.PI / 180;          // degrees -> radians   (0.017453292519943295)
const TWO_PI = 2 * Math.PI;

function mod(n, m) {                 // AS-style positive modulo
  if (n < 0) { return (n % m) + m; }
  return n % m;
}

/* ------------------------------------------------------------- stage layout */
/* Original Flash stage is 900x600. The left "orbit" region maps to a 592x600
 * canvas; the whole `animation` clip sits at stage (298, 304.4) -> that point
 * is the Sun, and the origin for all top-view geometry. Matrices below are the
 * exact PlaceObject values from the SWF (px). */
const ORBIT_W = 592, ORBIT_H = 600;
const SUN_X = 298, SUN_Y = 304.4;   // animation-clip origin (= Sun) in canvas A

/* "View of Moon" canvas */
const MOON_W = 240, MOON_H = 240;
const MOON_CX = 120, MOON_CY = 120;
const MOON_R = 92;                  // drawn Moon-disk radius (see notes)

/* physics constants (verbatim) ------------------------------------------- */
const SQ_E_RADIUS = 41209;          // Earth-Sun distance^2  (203^2)
const SQ_M_RADIUS = 3721;           // Earth-Moon distance^2 (61^2)
const CROSS = 24766;                // 2 * 203 * 61
const EARTH_MOON = 61;              // Earth-Moon distance
const MOON_CLOCK_SPEED = 510000;    // ms constant for the hidden clock moon
const EARTH_SPIN_PER = 28;          // Earth rotations coupling (earth._time = moonTime*28)
const REV_DIV = 365;                // animation.as: earth._time/365 - 27.6
const REV_OFF = 27.6;
const SPACE_CLAMP = 280;            // spaceArrow drag clamp (+/- 280)

/* moon-phase naming (moonPhaseSymbol.as) --------------------------------- */
const SYNODIC = 29.5;
const PHASE_TOL = 12 * 360 / (SYNODIC * 24);   // setPhaseTolerance(12) -> 6.1017 deg

function getNameFromAngle(angle) {   // verbatim thresholds from moonPhaseSymbol.as
  let t = mod(angle, 360);
  const tol = PHASE_TOL;
  if (t <= tol)            return 'New Moon';
  if (t < 90 - tol)        return 'Waxing Crescent';
  if (t <= 90 + tol)       return 'First Quarter';
  if (t < 180 - tol)       return 'Waxing Gibbous';
  if (t <= 180 + tol)      return 'Full Moon';
  if (t < 270 - tol)       return 'Waning Gibbous';
  if (t <= 270 + tol)      return 'Third Quarter';
  if (t < 360 - tol)       return 'Waning Crescent';
  return 'New Moon';
}

/* ---------------------------------------------------------------- assets */
const IMG = {};
function loadImages() {
  const sources = {
    sun:   'assets/sun.png',
    earth: 'assets/earth.png',
    moonSmall: 'assets/moon_small.png',
    arrow: 'assets/arrow.png',
    moonEarth: 'assets/moon_earthview.png',
  };
  const promises = [];
  for (const key in sources) {
    const img = new Image();
    IMG[key] = img;
    promises.push(new Promise((res) => { img.onload = res; img.onerror = res; img.src = sources[key]; }));
  }
  IMG.seq = [];
  for (let i = 1; i <= 59; i++) {
    const img = new Image();
    IMG.seq[i] = img;
    promises.push(new Promise((res) => { img.onload = res; img.onerror = res; img.src = 'assets/moon_seq/' + i + '.png'; }));
  }
  return Promise.all(promises);
}

/* ============================================================= STATE ===== */
const INITIAL = () => ({
  running: false,
  animSpeed: 50,          // speed slider value (1..100), default 50
  perspective: 'earth',   // 'earth' | 'sun' | 'space'
  hideMoon: false,
  moonAngle: 0,           // hidden clock-moon angle (radians), unbounded
  spaceX: 260,            // space-observer position, relative to Sun (Flash y-down)
  spaceY: -260,
});
let state = INITIAL();

/* derived per-frame values (recomputed in updatePhysics) */
let d = {};

/* ============================================================= PHYSICS === */
/* One evaluation of the ported per-frame logic (animation.as + children). */
function updatePhysics(dtMs) {
  // ---- hidden clock moon (moon.as): advances only while running ----------
  //   effective _speed = MOON_CLOCK_SPEED / animSpeed ; da = dt*2*PI/_speed
  if (state.running) {
    const effSpeed = MOON_CLOCK_SPEED / state.animSpeed;
    state.moonAngle += dtMs * TWO_PI / effSpeed;
  }

  // ---- tideAnim.as: derive frame/time from the clock moon -----------------
  const frameDeg = state.moonAngle * DEG;          // tideAnim._frame = degrees(moon._angle)
  const moonTime = 360 - frameDeg;                 // _moonTime
  const earthTime = moonTime * EARTH_SPIN_PER;     // earth._time (Earth spin, degrees)

  // ---- animation.as: Earth revolution angle -------------------------------
  let angle;                                       // _angle (Earth heliocentric, deg)
  if (earthTime === 0) { angle = 0; }
  else { angle = earthTime / REV_DIV - REV_OFF; }
  const revAngle = frameDeg;                        // _revAngle

  // ---- sunEarth.as: Sun-Earth-Moon geometry -------------------------------
  const angMES = mod(frameDeg + 180, 360) * RAD;                        // _angMES
  const distSM = Math.sqrt(SQ_E_RADIUS + SQ_M_RADIUS - CROSS * Math.cos(angMES)); // _distSM

  // ---- animation.as onEnterFrame geometry block ---------------------------
  const angESM = Math.asin(EARTH_MOON * Math.sin(angMES) / distSM);
  const angMS0 = mod(Math.abs(angESM + angle * RAD), TWO_PI);
  const moonX = distSM * Math.cos(angMS0);
  const moonY = distSM * Math.sin(angMS0);

  const v1 = state.spaceX - moonX;
  const v2 = -state.spaceY - moonY;
  const w1 = -moonX;
  const w2 = -moonY;
  const angSMA = Math.atan2(w2, w1) - Math.atan2(v2, v1);
  const u1 = moonX - state.spaceX;
  const u2 = moonY + state.spaceY;
  const angMA0 = -Math.atan2(u2, u1);
  const angAM0 = Math.atan2(v2, v1);

  d = { frameDeg, moonTime, earthTime, angle, revAngle,
        angMES, distSM, moonX, moonY, angSMA, angMA0, angAM0 };
}

/* ---- moonPhaseSymbol terminator geometry (earthView) ------------------- */
/* Precompute the anchor/control points for the terminator ellipse at radius R,
 * following moonPhaseSymbol.updateMask (N = 5). */
function buildTermEarth(R) {
  const N = 5, step = Math.PI / (N - 1);           // PI/4
  const aDist = 1 / Math.cos(step / 2);
  const aP = [], cP = [];
  for (let i = 0; i < N; i++) {
    aP[i] = { x: R * Math.sin(i * step), y: R * Math.cos(i * step) };
    if (i !== 0) {
      const a2 = step / 2 + (i - 1) * step;
      cP[i] = { x: R * aDist * Math.sin(a2), y: R * aDist * Math.cos(a2) };
    } else { cP[i] = null; }
  }
  return { aP, cP };
}
/* ---- MoonRotator terminator geometry (space/sun view) ------------------ */
function buildTermRotator(R) {
  const N = 5, step = Math.PI / (N - 1);
  const cRad = R / Math.cos(step / 2);
  const aP = [], cP = [];
  for (let i = 0; i < N; i++) {
    aP[i] = { x: R * Math.sin(i * step), y: -R * Math.cos(i * step) };
    const a2 = step / 2 + (i - 1) * step;
    cP[i] = { x: cRad * Math.sin(a2), y: -cRad * Math.cos(a2) };
  }
  return { aP, cP };
}
const TERM_EARTH = buildTermEarth(MOON_R);
const TERM_ROTATOR = buildTermRotator(MOON_R);
const DARK_ALPHA = 70;              // setDarkAlpha(70) -> 70% opaque black lune

/* Draw the dark (unlit) lune over the Moon disk. `phaseRad` is the internal
 * _phase; `variant` selects the earthView vs MoonRotator sign convention. */
function drawTerminator(ctx, cx, cy, R, phaseRad, variant) {
  const phase = mod(phaseRad, TWO_PI);
  const boxDir = phase < Math.PI ? -1 : 1;
  const boxSide = R + R * 0.12;      // MARGIN scaled (original 10 with R=101)
  const cosP = Math.cos(mod(phase, Math.PI));
  const T = variant === 'earth' ? TERM_EARTH : TERM_ROTATOR;

  ctx.save();
  ctx.translate(cx, cy);
  ctx.beginPath();                   // clip to Moon disk so the box never spills
  ctx.arc(0, 0, R, 0, TWO_PI);
  ctx.clip();

  ctx.beginPath();
  ctx.moveTo(0, R);
  ctx.lineTo(0, boxSide);
  ctx.lineTo(boxDir * boxSide, boxSide);
  ctx.lineTo(boxDir * boxSide, -boxSide);
  ctx.lineTo(0, -boxSide);
  ctx.lineTo(0, -R);
  if (variant === 'earth') {
    // moonPhaseSymbol: y is negated in the loop; i = 0 is a no-op (cP[0]=null)
    for (let i = 1; i < 5; i++) {
      ctx.quadraticCurveTo(T.cP[i].x * cosP, -T.cP[i].y, T.aP[i].x * cosP, -T.aP[i].y);
    }
  } else {
    // MoonRotator: y already carries its sign; loop i = 0..4
    for (let i = 0; i < 5; i++) {
      ctx.quadraticCurveTo(cosP * T.cP[i].x, T.cP[i].y, cosP * T.aP[i].x, T.aP[i].y);
    }
  }
  ctx.closePath();
  ctx.fillStyle = 'rgba(0,0,0,' + (DARK_ALPHA / 100) + ')';
  ctx.fill();
  ctx.restore();
}

/* MoonRotator.setLongitude -> which sequence frame (1..59) faces the observer */
function longitudeToFrame(longDeg) {
  const frames = 59;
  const stepSize = TWO_PI / frames;
  const longRad = mod(longDeg, 360) * RAD;
  return 1 + mod(Math.floor(longRad / stepSize), frames);
}

/* ============================================================= RENDER ==== */
let orbitCtx, moonCtx;

function drawImageCentered(ctx, img, w, h) {
  if (img && img.complete && img.naturalWidth) {
    ctx.drawImage(img, -w / 2, -h / 2, w, h);
  }
}

function renderOrbit() {
  const ctx = orbitCtx;
  ctx.clearRect(0, 0, ORBIT_W, ORBIT_H);

  // --- myAnim (sunEarth) : rotated about the Sun by _angle -----------------
  ctx.save();
  ctx.translate(SUN_X, SUN_Y);
  ctx.rotate(d.angle * RAD);

  // sun (216) scale 0.2698, 201x201, centered at origin
  ctx.save();
  ctx.scale(0.2698, 0.2698);
  drawImageCentered(ctx, IMG.sun, 201, 201);
  ctx.restore();

  // myEarth (tideAnim 214) at (203.4, 0.3) scale 0.1811
  ctx.save();
  ctx.translate(203.4, 0.3);
  ctx.scale(0.18112, 0.18124);

  //   earth (212) at (0.6,-1.1) scale ~1.011
  ctx.save();
  ctx.translate(0.6, -1.1);
  ctx.scale(1.0110, 1.0043);

  //     earth globe (209) spins by earthTime
  ctx.save();
  ctx.rotate(d.earthTime * RAD);
  drawImageCentered(ctx, IMG.earth, 164, 164);
  ctx.restore();

  //     earthArrow (207) at (-1.4,0) scale 2.738, rot -revAngle  (Earth view only)
  if (state.perspective === 'earth') {
    ctx.save();
    ctx.translate(-1.4, 0);
    ctx.rotate(-d.revAngle * RAD);
    ctx.scale(2.7381, 2.7381);
    if (IMG.arrow.complete) ctx.drawImage(IMG.arrow, 0, -5, 100, 10); // tail at origin
    ctx.restore();
  }
  ctx.restore(); // earth

  //   moon2 (213) at (-0.2,-3.0) rotate moonTime ; visMoon (204) at (335.6,-0.9)
  ctx.save();
  ctx.translate(-0.2, -3.0);
  ctx.rotate(d.moonTime * RAD);
  ctx.translate(335.6, -0.9);
  ctx.rotate(-d.moonTime * RAD);
  ctx.scale(0.9640, 0.9728);
  drawImageCentered(ctx, IMG.moonSmall, 75, 75);
  ctx.restore(); // moon2

  ctx.restore(); // tideAnim
  ctx.restore(); // myAnim (rotation cleared)

  // --- observer-direction arrows (animation level; NOT rotated by _angle) --
  if (state.perspective === 'sun') {
    const rot = -Math.atan2(d.moonY, d.moonX);       // deg(-atan2(moonY,moonX))
    ctx.save();
    ctx.translate(SUN_X - 0.8, SUN_Y + 0.1);
    ctx.rotate(rot);
    ctx.scale(1.0112, 0.9712);
    if (IMG.arrow.complete) ctx.drawImage(IMG.arrow, 0, -5, 100, 10);
    ctx.restore();
  } else if (state.perspective === 'space') {
    ctx.save();
    ctx.translate(SUN_X + state.spaceX, SUN_Y + state.spaceY);
    ctx.rotate(d.angMA0);
    ctx.scale(1.0117, 0.9887);
    if (IMG.arrow.complete) ctx.drawImage(IMG.arrow, 0, -5, 100, 10);
    ctx.restore();
  }
}

function renderMoonView() {
  const ctx = moonCtx;
  // black "View of Moon" box
  ctx.fillStyle = '#000';
  ctx.fillRect(0, 0, MOON_W, MOON_H);
  if (state.hideMoon) { return; }

  if (state.perspective === 'earth') {
    // earthView (moonPhaseSymbol): fixed near-side photo + terminator lune
    // setPhase(180 + revAngle)
    const phaseDeg = mod(180 + d.revAngle, 360);
    ctx.save();
    ctx.beginPath(); ctx.arc(MOON_CX, MOON_CY, MOON_R, 0, TWO_PI); ctx.clip();
    if (IMG.moonEarth.complete) {
      ctx.drawImage(IMG.moonEarth, MOON_CX - MOON_R, MOON_CY - MOON_R, MOON_R * 2, MOON_R * 2);
    }
    ctx.restore();
    drawTerminator(ctx, MOON_CX, MOON_CY, MOON_R, phaseDeg * RAD, 'earth');
  } else {
    // spaceView (MoonRotator): rotating face (by longitude) + terminator lune
    let sunAngle, longitude;
    if (state.perspective === 'sun') {
      sunAngle = 0;                                  // setSunAngle(0)
      longitude = 45 + d.revAngle;                   // setLongitude(45 + revAngle)
    } else { // space
      sunAngle = d.angSMA * DEG;                     // setSunAngle(deg(angSMA))
      longitude = (d.angAM0 + d.angMES) * DEG + 45;  // setLongitude(deg(angAM0+angMES)+45)
    }
    const frame = longitudeToFrame(longitude);
    ctx.save();
    ctx.beginPath(); ctx.arc(MOON_CX, MOON_CY, MOON_R, 0, TWO_PI); ctx.clip();
    const seq = IMG.seq[frame];
    if (seq && seq.complete) {
      ctx.drawImage(seq, MOON_CX - MOON_R, MOON_CY - MOON_R, MOON_R * 2, MOON_R * 2);
    }
    ctx.restore();
    // MoonRotator.setSunAngle: _phase = rad(mod(-arg+180,360))
    const phaseRad = mod(-sunAngle + 180, 360) * RAD;
    drawTerminator(ctx, MOON_CX, MOON_CY, MOON_R, phaseRad, 'rotator');
  }
}

/* Illuminated fraction for narration: (1 - cos(phaseAngle)) / 2 */
function illumPct(phaseDeg) {
  return Math.round((1 - Math.cos(mod(phaseDeg, 360) * RAD)) / 2 * 100);
}

let lastNarration = '';
function describeMoonView() {
  if (state.perspective === 'earth') {
    const phaseDeg = mod(180 + d.revAngle, 360);
    const name = getNameFromAngle(phaseDeg);
    return 'View from Earth. The Moon appears as a ' + name + ', ' +
           illumPct(phaseDeg) + ' percent illuminated.';
  }
  if (state.perspective === 'sun') {
    return 'View from the Sun. The Moon’s sunlit hemisphere faces the Sun, ' +
           'so it appears fully illuminated.';
  }
  const phaseDeg = mod(180 - d.angSMA * DEG, 360);
  return 'View from a point in space. The Moon appears ' +
         illumPct(phaseDeg) + ' percent illuminated.';
}

function updateAria(force) {
  const moonDesc = document.getElementById('moon-desc');
  if (moonDesc) { moonDesc.textContent = state.hideMoon ? 'The Moon is hidden.' : describeMoonView(); }
  const orbitDesc = document.getElementById('orbit-desc');
  if (orbitDesc) {
    orbitDesc.textContent =
      'Top-down view. The Sun is at the center, the Earth orbits the Sun, and the ' +
      'Moon orbits the Earth. ' + (state.running ? 'The animation is running.' : 'The animation is paused.');
  }
  if (force) { announce(describeMoonView()); }
}

/* aria-live status (announce on commit, not every tick) */
let announceTimer = null;
function announce(msg) {
  if (msg === lastNarration) { return; }
  lastNarration = msg;
  const el = document.getElementById('sr-status');
  if (!el) { return; }
  clearTimeout(announceTimer);
  announceTimer = setTimeout(() => { el.textContent = msg; }, 120);
}

/* Position the keyboard/pointer proxy over the space observer arrow. */
function updateObserverProxy() {
  const proxy = document.getElementById('space-observer');
  if (!proxy) { return; }
  const active = state.perspective === 'space';
  proxy.hidden = !active;
  proxy.setAttribute('aria-hidden', active ? 'false' : 'true');
  // only suppress touch-scroll on the canvas while it is actually draggable
  orbitCtx.canvas.classList.toggle('tv-canvas--grab', active);
  if (!active) { return; }
  const cv = orbitCtx.canvas;
  const scale = cv.clientWidth / ORBIT_W || 1;
  // position within the shared offset parent, accounting for the canvas padding
  proxy.style.left = (cv.offsetLeft + (SUN_X + state.spaceX) * scale) + 'px';
  proxy.style.top = (cv.offsetTop + (SUN_Y + state.spaceY) * scale) + 'px';
  proxy.setAttribute('aria-label', observerValueText());
}
function observerValueText() {
  const x = Math.round(state.spaceX);
  const y = Math.round(-state.spaceY); // report "up" as positive
  const h = x >= 0 ? x + ' units right of the Sun' : (-x) + ' units left of the Sun';
  const v = y >= 0 ? y + ' units above' : (-y) + ' units below';
  return 'Observation point ' + h + ', ' + v + '. ' + describeMoonView();
}

/* Single render entry point: physics is already updated for this frame. */
function render() {
  renderOrbit();
  renderMoonView();
  updateObserverProxy();
}

/* ============================================================= LOOP ====== */
/* The requestAnimationFrame loop runs ONLY while the animation is running, so
 * there is no continuous motion (or CPU churn) when paused. This also honours
 * prefers-reduced-motion: the sim is fully static until the user presses Run,
 * and Run is a stoppable, user-initiated action. */
let rafId = null, lastTime = null;

function frame(now) {
  if (lastTime === null) { lastTime = now; }
  const dt = now - lastTime;
  lastTime = now;
  updatePhysics(dt);
  render();
  if (state.running) { rafId = requestAnimationFrame(frame); }
  else { rafId = null; }
}
function startLoop() {
  if (rafId === null) { lastTime = null; rafId = requestAnimationFrame(frame); }
}
function stopLoop() {
  if (rafId !== null) { cancelAnimationFrame(rafId); rafId = null; }
}

/* Recompute + redraw once without advancing time (dt = 0 never advances the
 * clock), for control changes made while paused. */
function renderStatic() {
  updatePhysics(0);
  render();
  updateAria(false);
}

/* ============================================================= CONTROLS == */
function setRunning(run) {
  state.running = run;
  const btn = document.getElementById('run-btn');
  btn.textContent = run ? 'Stop Animation' : 'Run Animation';
  btn.setAttribute('aria-pressed', run ? 'true' : 'false');
  if (run) { startLoop(); } else { stopLoop(); renderStatic(); }
  updateAria(false);
  announce(run ? 'Animation running.' : 'Animation paused.');
}

function doRestart() {
  stopLoop();
  const keepPersp = state.perspective;   // radio selection persists; motion resets
  const keepSpeed = state.animSpeed;
  const keepHide = state.hideMoon;
  state = INITIAL();
  state.perspective = keepPersp;
  state.animSpeed = keepSpeed;
  state.hideMoon = keepHide;
  const btn = document.getElementById('run-btn');
  btn.textContent = 'Run Animation';
  btn.setAttribute('aria-pressed', 'false');
  renderStatic();
  announce('Animation restarted. ' + describeMoonView());
}

/* Full reset from the masthead "sim-reset" event -> exact initial state. */
function doFullReset() {
  stopLoop();
  state = INITIAL();
  document.getElementById('persp-earth').checked = true;
  const slider = document.getElementById('speed-slider');
  slider.value = 50;
  slider.setAttribute('aria-valuetext', 'Animation speed 50 out of 100');
  const hs = document.getElementById('hide-show-btn');
  hs.textContent = 'Hide Moon';
  const run = document.getElementById('run-btn');
  run.textContent = 'Run Animation';
  run.setAttribute('aria-pressed', 'false');
  renderStatic();
  announce('Simulation reset. ' + describeMoonView());
}

function wireControls() {
  // perspective radios
  document.querySelectorAll('input[name="perspective"]').forEach((r) => {
    r.addEventListener('change', () => {
      if (r.checked) {
        state.perspective = r.value;
        renderStatic();
        updateAria(true);
      }
    });
  });

  // speed slider (native range: keyboard arrows/Page/Home/End for free)
  const slider = document.getElementById('speed-slider');
  slider.addEventListener('input', () => {
    state.animSpeed = parseInt(slider.value, 10);
    slider.setAttribute('aria-valuetext', 'Animation speed ' + slider.value + ' out of 100');
  });
  // mouse wheel adjusts the focused slider
  slider.addEventListener('wheel', (e) => {
    if (document.activeElement !== slider) { return; }
    e.preventDefault();
    let v = parseInt(slider.value, 10) + (e.deltaY < 0 ? 1 : -1);
    v = Math.max(1, Math.min(100, v));
    slider.value = v;
    state.animSpeed = v;
    slider.setAttribute('aria-valuetext', 'Animation speed ' + v + ' out of 100');
  }, { passive: false });

  // run / stop toggle
  document.getElementById('run-btn').addEventListener('click', () => setRunning(!state.running));
  // restart
  document.getElementById('restart-btn').addEventListener('click', doRestart);

  // hide / show moon
  document.getElementById('hide-show-btn').addEventListener('click', (e) => {
    state.hideMoon = !state.hideMoon;
    e.currentTarget.textContent = state.hideMoon ? 'Show Moon' : 'Hide Moon';
    renderStatic();
    announce(state.hideMoon ? 'Moon hidden.' : 'Moon shown. ' + describeMoonView());
  });

  // masthead reset
  document.addEventListener('sim-reset', doFullReset);

  wireSpaceObserver();
}

/* -------- draggable "point in space" observer: pointer + keyboard -------- */
function setSpace(x, y, announceIt) {
  state.spaceX = Math.max(-SPACE_CLAMP, Math.min(SPACE_CLAMP, x));
  state.spaceY = Math.max(-SPACE_CLAMP, Math.min(SPACE_CLAMP, y));
  renderStatic();
  const proxy = document.getElementById('space-observer');
  if (proxy) { proxy.setAttribute('aria-label', observerValueText()); }
  if (announceIt) { announce(observerValueText()); }
}

function wireSpaceObserver() {
  const canvas = orbitCtx.canvas;
  const proxy = document.getElementById('space-observer');
  let dragging = false;

  function canvasStage(evt) {
    const rect = canvas.getBoundingClientRect();
    const sx = ORBIT_W / rect.width;
    const sy = ORBIT_H / rect.height;
    return {
      x: (evt.clientX - rect.left) * sx - SUN_X,
      y: (evt.clientY - rect.top) * sy - SUN_Y,
    };
  }
  function nearObserver(p) {
    const dx = p.x - state.spaceX, dy = p.y - state.spaceY;
    return (dx * dx + dy * dy) <= (44 * 44);
  }

  canvas.addEventListener('pointerdown', (evt) => {
    if (state.perspective !== 'space') { return; }
    const p = canvasStage(evt);
    if (!nearObserver(p)) { return; }
    dragging = true;
    canvas.setPointerCapture(evt.pointerId);
    proxy.focus();
    setSpace(p.x, p.y, false);
    evt.preventDefault();
  });
  canvas.addEventListener('pointermove', (evt) => {
    if (!dragging) { return; }
    const p = canvasStage(evt);
    setSpace(p.x, p.y, false);   // matches AS onMouseMove (continuous)
  });
  function endDrag(evt) {
    if (!dragging) { return; }
    dragging = false;
    try { canvas.releasePointerCapture(evt.pointerId); } catch (_) {}
    announce(observerValueText());   // announce on release, not every tick
  }
  canvas.addEventListener('pointerup', endDrag);
  canvas.addEventListener('pointercancel', endDrag);

  // keyboard: arrows nudge, Page = larger, Home/End = extremes
  proxy.addEventListener('keydown', (evt) => {
    const STEP = 10, BIG = 40;
    let x = state.spaceX, y = state.spaceY, handled = true;
    switch (evt.key) {
      case 'ArrowLeft':  x -= STEP; break;
      case 'ArrowRight': x += STEP; break;
      case 'ArrowUp':    y -= STEP; break;   // up = negative (Flash y-down)
      case 'ArrowDown':  y += STEP; break;
      case 'PageUp':     y -= BIG; break;
      case 'PageDown':   y += BIG; break;
      case 'Home':       x = -SPACE_CLAMP; break;
      case 'End':        x = SPACE_CLAMP; break;
      default: handled = false;
    }
    if (handled) { evt.preventDefault(); setSpace(x, y, true); }
  });
  proxy.addEventListener('wheel', (evt) => {
    evt.preventDefault();
    setSpace(state.spaceX, state.spaceY + (evt.deltaY < 0 ? -10 : 10), true);
  }, { passive: false });
}

/* ============================================================= INIT ====== */
/* Redefine the foundation hook so any future equation setup lives here. */
function klunlInitEqn() { /* this sim displays no equations (see ACCESSIBILITY.md) */ }
window.klunlInitEqn = klunlInitEqn;

function init() {
  orbitCtx = document.getElementById('orbit-canvas').getContext('2d');
  moonCtx = document.getElementById('moon-canvas').getContext('2d');
  wireControls();
  window.addEventListener('resize', () => { updateObserverProxy(); });

  loadImages().then(() => {
    renderStatic();
    updateAria(false);   // static until the user presses Run (see LOOP section)
  });
}

if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', init);
} else { init(); }
