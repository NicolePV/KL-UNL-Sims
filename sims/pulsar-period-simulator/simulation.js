// Pulsar Period Simulator - ported from AS3 (pulsarPeriodSim001_fla/MainTimeline.as,
// Pulsar.as, IntervalsPlot.as). See CONVERSION_NOTES.md for the behavior model and
// asset mapping.

//////////////////////////////////////////////////////////////////////////////
// Constants (verbatim from MainTimeline.as frame1())
//////////////////////////////////////////////////////////////////////////////

const PULSE_PERIOD  = 250;    // ms of sim time between pulsar pulses
const PULSE_SPEED    = 0.1;   // px (stage units) per ms - speed a pulse wavefront travels
const ORBIT_RADIUS   = 100;
const ORBIT_X        = 120;
const ORBIT_Y         = 120;
const ORBIT_PERIOD   = 12000; // ms of sim time per orbit
const PULSAR_SPEED   = 2 * Math.PI * ORBIT_RADIUS / ORBIT_PERIOD;

// earth's fixed stage position. The original placed it at (864, 568) - jammed
// into the bottom-right corner (measured from frames/1.png, since
// MainTimeline.as only reads earth.x/earth.y, never sets them). Nudged up and
// left to (822, 526) at the user's request so it no longer touches the corner;
// this is a small, intentional geometry change (it shifts the sight-line that
// drives pulse colours and interval variation) that leaves the qualitative
// behaviour unchanged. See CONVERSION_NOTES.md.
const EARTH_X = 822;
const EARTH_Y = 526;

// IntervalsPlot(350, 180, 40000) placed at plot.x = 900 - plot.width - 15,
// plot.y = plot.height + 15 (see MainTimeline.as frame1()).
const PLOT_WIDTH    = 350;
const PLOT_HEIGHT   = 180;
const PLOT_TIMESPAN = 40000;
const PLOT_X = 900 - PLOT_WIDTH - 15;      // left edge of the plot box
const PLOT_Y = PLOT_HEIGHT + 15;           // bottom edge of the plot box (AS origin convention)

const MIN_DELTA = PULSE_PERIOD * (1 - 1.07 * PULSAR_SPEED / PULSE_SPEED);
const MAX_DELTA = PULSE_PERIOD * (1 + 1.07 * PULSAR_SPEED / PULSE_SPEED);

const SPEED_MIN = -2;
const SPEED_MAX = 1.1;
const SPEED_DEFAULT = -0.4;

const COLOR_GRAY_ORBIT  = 'rgba(160,160,160,0.5)'; // 10526880 (0xA0A0A0), alpha 0.5
const COLOR_PULSE_GRAY  = '#808080';               // 8421504
const COLOR_PLOT_BORDER = '#d0d0d0';               // 13684944
const COLOR_PLOT_BG     = '#ffffff';               // 16777215

const STAGE_W = 900;
const STAGE_H = 600;

//////////////////////////////////////////////////////////////////////////////
// Color formula (verbatim translation of the AS red/blue "approach/recede"
// tint used both for individual pulses and for the coloured orbit trace)
//////////////////////////////////////////////////////////////////////////////

function clampByte(v) {
  if (v < 0) return 0;
  if (v > 255) return 255;
  return v;
}

// theta: orbital angle (radians) of the pulsar at emission time.
function pulseColorAtAngle(theta) {
  const ex = ORBIT_X + ORBIT_RADIUS * Math.cos(theta);
  const ey = ORBIT_Y + ORBIT_RADIUS * Math.sin(theta);
  const velX = -Math.sin(theta);
  const velY = Math.cos(theta);
  let dx = EARTH_X - ex;
  let dy = EARTH_Y - ey;
  const dist = Math.sqrt(dx * dx + dy * dy);
  dx /= dist;
  dy /= dist;
  const dot = velX * dx + velY * dy;

  let g = dot < 0 ? 128 + dot * 128 : 128 - dot * 128;
  let r = 255 - (dot + 1) / 2 * 255;
  let b = (dot + 1) / 2 * 255;
  r = clampByte(r);
  g = clampByte(g);
  b = clampByte(b);

  const hex = (Math.round(r) << 16 | Math.round(g) << 8 | Math.round(b))
    .toString(16).padStart(6, '0');
  return { x: ex, y: ey, css: '#' + hex };
}

//////////////////////////////////////////////////////////////////////////////
// IntervalsPlot (ported from IntervalsPlot.as)
//////////////////////////////////////////////////////////////////////////////

class IntervalsPlot {
  constructor(x, y, width, height, timespan) {
    this.x = x;
    this.y = y;
    this.width = width;
    this.height = height;
    this.timespan = timespan;
    this.minDelta = 1;
    this.maxDelta = 500;
    this.useColor = true;
    this.dataList = [];
    this.time = 0;
  }

  clearData() {
    this.dataList = [];
  }

  addData(entries) {
    for (const e of entries) this.dataList.push(e);
  }

  // Prunes data outside the rolling time window and returns the still-visible
  // entries as {cx, cy, color} points in absolute stage coordinates. Mirrors
  // IntervalsPlot.update()'s combined prune + point-placement behavior.
  update(time) {
    if (time === undefined) time = this.time;
    else this.time = time;

    const windowStart = this.time - this.timespan;
    const scaleX = this.width / this.timespan;
    const scaleY = -this.height / (this.maxDelta - this.minDelta);

    const kept = [];
    const points = [];
    for (const d of this.dataList) {
      if (d.time >= windowStart) {
        kept.push(d);
        if (d.time < this.time) {
          points.push({
            cx: this.x + scaleX * (d.time - windowStart),
            cy: this.y + scaleY * (d.delta - this.minDelta),
            color: this.useColor ? d.color : COLOR_PULSE_GRAY
          });
        }
      }
    }
    this.dataList = kept;
    return points;
  }
}

//////////////////////////////////////////////////////////////////////////////
// Simulation state (single source of truth - see hard rule 6)
//////////////////////////////////////////////////////////////////////////////

const state = {
  time: 0,
  timeLast: 0,
  timerLast: 0,
  speedValue: SPEED_DEFAULT,
  motionMode: 'stationary',   // 'stationary' | 'circular'
  colorCoding: false,
  animating: false,
  pulseList: [],
  lastPulseNum: 1,
  pulsar: { x: ORBIT_X, y: ORBIT_Y },
  grayOrbitVisible: false,
  coloredOrbitVisible: false,
  plot: new IntervalsPlot(PLOT_X, PLOT_Y, PLOT_WIDTH, PLOT_HEIGHT, PLOT_TIMESPAN)
};
state.plot.minDelta = MIN_DELTA;
state.plot.maxDelta = MAX_DELTA;

function prefersReducedMotion() {
  return window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches;
}

//////////////////////////////////////////////////////////////////////////////
// Physics / data update (ported from updateCircular / updateStationary)
//////////////////////////////////////////////////////////////////////////////

function updateCircular(nowMs) {
  const dt = nowMs - state.timerLast;
  state.time += Math.exp(state.speedValue) * dt;

  const theta = 2 * Math.PI * state.time / ORBIT_PERIOD;
  state.pulsar.x = ORBIT_X + ORBIT_RADIUS * Math.cos(theta);
  state.pulsar.y = ORBIT_Y + ORBIT_RADIUS * Math.sin(theta);

  const pulseIndexNow = Math.floor(state.time / PULSE_PERIOD);
  const newDeltas = [];

  for (let n = state.lastPulseNum; n <= pulseIndexNow; n++) {
    const t0 = n * PULSE_PERIOD;
    const theta0 = 2 * Math.PI * t0 / ORBIT_PERIOD;
    const { x: ex, y: ey, css } = pulseColorAtAngle(theta0);

    const dxE = EARTH_X - ex;
    const dyE = EARTH_Y - ey;
    const dist = Math.sqrt(dxE * dxE + dyE * dyE);
    const angle = Math.atan2(dyE, dxE);
    const t1 = t0 + dist / PULSE_SPEED;

    const pulse = {
      color: css,
      waveDx0: 3 * Math.cos(angle + Math.PI / 2), waveDy0: 3 * Math.sin(angle + Math.PI / 2),
      waveDx1: 3 * Math.cos(angle - Math.PI / 2), waveDy1: 3 * Math.sin(angle - Math.PI / 2),
      x0: ex, y0: ey, t0,
      x1: EARTH_X, y1: EARTH_Y, t1,
      mx: (EARTH_X - ex) / (t1 - t0),
      my: (EARTH_Y - ey) / (t1 - t0)
    };
    state.pulseList.push(pulse);
    if (state.pulseList.length > 1) {
      const prev = state.pulseList[state.pulseList.length - 2];
      newDeltas.push({ time: t1, delta: t1 - prev.t1, color: css });
    }
  }

  state.plot.addData(newDeltas);
  state.lastPulseNum = pulseIndexNow + 1;
  state.timeLast = state.time;
  state.timerLast = nowMs;
}

function updateStationary(nowMs) {
  const dt = nowMs - state.timerLast;
  state.time += Math.exp(state.speedValue) * dt;

  const pulseIndexNow = Math.floor(state.time / PULSE_PERIOD);
  const ex = ORBIT_X, ey = ORBIT_Y;
  const dxE = EARTH_X - ex, dyE = EARTH_Y - ey;
  const dist = Math.sqrt(dxE * dxE + dyE * dyE);
  const angle = Math.atan2(dyE, dxE);
  const newDeltas = [];

  for (let n = state.lastPulseNum; n <= pulseIndexNow; n++) {
    const t0 = n * PULSE_PERIOD;
    const t1 = t0 + dist / PULSE_SPEED;
    const pulse = {
      color: COLOR_PULSE_GRAY,
      waveDx0: 3 * Math.cos(angle + Math.PI / 2), waveDy0: 3 * Math.sin(angle + Math.PI / 2),
      waveDx1: 3 * Math.cos(angle - Math.PI / 2), waveDy1: 3 * Math.sin(angle - Math.PI / 2),
      x0: ex, y0: ey, t0,
      x1: EARTH_X, y1: EARTH_Y, t1,
      mx: (EARTH_X - ex) / (t1 - t0),
      my: (EARTH_Y - ey) / (t1 - t0)
    };
    state.pulseList.push(pulse);
    if (state.pulseList.length > 1) {
      const prev = state.pulseList[state.pulseList.length - 2];
      newDeltas.push({ time: t1, delta: t1 - prev.t1, color: COLOR_PULSE_GRAY });
    }
  }

  state.plot.addData(newDeltas);
  state.lastPulseNum = pulseIndexNow + 1;
  state.timeLast = state.time;
  state.timerLast = nowMs;
}

//////////////////////////////////////////////////////////////////////////////
// updateOrbits (ported) - decides which precomputed orbit trace is visible
//////////////////////////////////////////////////////////////////////////////

function updateOrbits() {
  if (state.motionMode === 'circular') {
    if (state.colorCoding) {
      state.coloredOrbitVisible = true;
      state.grayOrbitVisible = false;
      state.plot.useColor = true;
    } else {
      state.coloredOrbitVisible = false;
      state.grayOrbitVisible = true;
      state.plot.useColor = false;
    }
  } else {
    state.coloredOrbitVisible = false;
    state.grayOrbitVisible = false;
  }
}

//////////////////////////////////////////////////////////////////////////////
// Precomputed orbit layers (static geometry - drawn once, matches drawOrbit())
//////////////////////////////////////////////////////////////////////////////

let grayOrbitCanvas, coloredOrbitCanvas;

function buildOrbitLayers() {
  grayOrbitCanvas = document.createElement('canvas');
  grayOrbitCanvas.width = STAGE_W;
  grayOrbitCanvas.height = STAGE_H;
  const gctx = grayOrbitCanvas.getContext('2d');
  gctx.strokeStyle = COLOR_GRAY_ORBIT;
  gctx.lineWidth = 1;
  gctx.beginPath();
  gctx.arc(ORBIT_X, ORBIT_Y, ORBIT_RADIUS, 0, Math.PI * 2);
  gctx.stroke();

  coloredOrbitCanvas = document.createElement('canvas');
  coloredOrbitCanvas.width = STAGE_W;
  coloredOrbitCanvas.height = STAGE_H;
  const cctx = coloredOrbitCanvas.getContext('2d');
  const segments = 600;
  const step = (2 * Math.PI) / segments;
  let theta = 0;
  let prev = pulseColorAtAngle(theta);
  cctx.lineWidth = 1;
  cctx.globalAlpha = 0.5;
  for (let i = 0; i < segments; i++) {
    theta += step;
    const cur = pulseColorAtAngle(theta);
    cctx.strokeStyle = cur.css;
    cctx.beginPath();
    cctx.moveTo(prev.x, prev.y);
    cctx.lineTo(cur.x, cur.y);
    cctx.stroke();
    prev = cur;
  }
  cctx.globalAlpha = 1;
}

//////////////////////////////////////////////////////////////////////////////
// render() - single point of truth: redraws canvas from state (hard rule 6)
//////////////////////////////////////////////////////////////////////////////

let ctx, pulsarImg, earthImg;

function render() {
  ctx.clearRect(0, 0, STAGE_W, STAGE_H);

  if (state.grayOrbitVisible) ctx.drawImage(grayOrbitCanvas, 0, 0);
  if (state.coloredOrbitVisible) ctx.drawImage(coloredOrbitCanvas, 0, 0);

  // Pulses in transit (prune expired ones - mirrors drawPulses()).
  const now = state.timeLast;
  const kept = [];
  ctx.lineWidth = 2;
  for (const p of state.pulseList) {
    if (now < p.t1) {
      const x = p.x0 + (now - p.t0) * p.mx;
      const y = p.y0 + (now - p.t0) * p.my;
      ctx.strokeStyle = state.colorCoding ? p.color : COLOR_PULSE_GRAY;
      ctx.beginPath();
      ctx.moveTo(x + p.waveDx0, y + p.waveDy0);
      ctx.lineTo(x + p.waveDx1, y + p.waveDy1);
      ctx.stroke();
      kept.push(p);
    }
  }
  state.pulseList = kept;

  // Interval plot (background, data, border).
  const plot = state.plot;
  ctx.fillStyle = COLOR_PLOT_BG;
  ctx.fillRect(plot.x, plot.y - plot.height, plot.width, plot.height);

  // Clip the data dots to the plot rectangle, reproducing the original's
  // _data.mask (IntervalsPlot.as: `_data.mask = _dataMask`). Without this a
  // dot entering/leaving at an edge draws over the border instead of being
  // cropped to the box.
  const points = plot.update(state.timeLast);
  ctx.save();
  ctx.beginPath();
  ctx.rect(plot.x, plot.y - plot.height, plot.width, plot.height);
  ctx.clip();
  for (const pt of points) {
    ctx.fillStyle = pt.color;
    ctx.beginPath();
    ctx.arc(pt.cx, pt.cy, 2, 0, Math.PI * 2);
    ctx.fill();
  }
  ctx.restore();

  ctx.strokeStyle = COLOR_PLOT_BORDER;
  ctx.lineWidth = 1;
  ctx.strokeRect(plot.x + 0.5, plot.y - plot.height + 0.5, plot.width - 1, plot.height - 1);

  // Pulsar and earth markers (exported vector assets, composited each frame).
  if (pulsarImg && pulsarImg.complete) {
    ctx.drawImage(pulsarImg, state.pulsar.x - 6, state.pulsar.y - 6, 12, 12);
  }
  if (earthImg && earthImg.complete) {
    ctx.drawImage(earthImg, EARTH_X - 4, EARTH_Y - 4, 8, 8);
  }
}

//////////////////////////////////////////////////////////////////////////////
// Screen-reader narration
//////////////////////////////////////////////////////////////////////////////

let diagramDesc;

function speedMultiplier() {
  return Math.exp(state.speedValue);
}

function announceState(extra) {
  const parts = [];
  parts.push(`Pulsar motion: ${state.motionMode}.`);
  parts.push(`Animation ${state.animating ? 'running' : 'paused'}.`);
  parts.push(`Color coding ${state.colorCoding ? 'on' : 'off'}.`);
  parts.push(`Speed ${speedMultiplier().toFixed(2)} times normal rate.`);
  if (extra) parts.push(extra);
  diagramDesc.textContent = parts.join(' ');
}

//////////////////////////////////////////////////////////////////////////////
// Reset (wired to the masthead's "sim-reset" event) - restores exact initial
// state, except that the auto-run default yields to prefers-reduced-motion
// (see ACCESSIBILITY.md).
//////////////////////////////////////////////////////////////////////////////

function resetSim() {
  state.time = 0;
  state.timeLast = 0;
  state.timerLast = performance.now();
  state.speedValue = SPEED_DEFAULT;
  state.motionMode = 'stationary';
  state.colorCoding = false;
  state.pulseList = [];
  state.lastPulseNum = 1;
  state.pulsar.x = ORBIT_X;
  state.pulsar.y = ORBIT_Y;
  state.animating = !prefersReducedMotion();
  state.plot.clearData();

  motionStationaryInput.checked = true;
  motionCircularInput.checked = false;
  colorCheckboxInput.checked = false;
  speedSliderInput.value = String(SPEED_DEFAULT);
  updateSpeedValueText();
  pauseButton.textContent = state.animating ? 'pause' : 'run';

  updateOrbits();
  render();
  announceState('Simulation reset.');
}

//////////////////////////////////////////////////////////////////////////////
// DOM wiring
//////////////////////////////////////////////////////////////////////////////

let motionStationaryInput, motionCircularInput, colorCheckboxInput,
    speedSliderInput, pauseButton;

function updateSpeedValueText() {
  const mult = speedMultiplier();
  speedSliderInput.setAttribute(
    'aria-valuetext',
    `Speed ${mult.toFixed(2)} times normal rate`
  );
}

function wireControls() {
  motionStationaryInput = document.getElementById('motionStationary');
  motionCircularInput = document.getElementById('motionCircular');
  colorCheckboxInput = document.getElementById('colorCheckbox');
  speedSliderInput = document.getElementById('speedSlider');
  pauseButton = document.getElementById('pauseButton');
  diagramDesc = document.getElementById('diagram-desc');

  function onMotionModeChanged() {
    state.motionMode = motionCircularInput.checked ? 'circular' : 'stationary';
    state.pulseList = [];
    state.lastPulseNum = 1;
    state.time = 0;
    state.timeLast = 0;
    state.timerLast = performance.now();
    state.plot.clearData();
    state.plot.update();
    if (state.motionMode === 'circular') {
      state.pulsar.x = ORBIT_X + ORBIT_RADIUS;
      state.pulsar.y = ORBIT_Y;
    } else {
      state.pulsar.x = ORBIT_X;
      state.pulsar.y = ORBIT_Y;
    }
    updateOrbits();
    render();
    announceState();
  }

  motionStationaryInput.addEventListener('change', onMotionModeChanged);
  motionCircularInput.addEventListener('change', onMotionModeChanged);

  colorCheckboxInput.addEventListener('change', () => {
    state.colorCoding = colorCheckboxInput.checked;
    updateOrbits();
    state.plot.useColor = state.colorCoding;
    render();
    announceState();
  });

  pauseButton.addEventListener('click', () => {
    state.animating = !state.animating;
    pauseButton.textContent = state.animating ? 'pause' : 'run';
    if (state.animating) state.timerLast = performance.now();
    announceState();
  });

  speedSliderInput.addEventListener('input', () => {
    state.speedValue = parseFloat(speedSliderInput.value);
    updateSpeedValueText();
  });
  speedSliderInput.addEventListener('change', () => {
    announceState();
  });

  document.addEventListener('sim-reset', resetSim);
}

//////////////////////////////////////////////////////////////////////////////
// Boot
//////////////////////////////////////////////////////////////////////////////

function loadImage(src) {
  const img = new Image();
  img.src = src;
  return img;
}

function frameLoop(nowMs) {
  if (state.animating) {
    if (state.motionMode === 'circular') updateCircular(nowMs);
    else updateStationary(nowMs);
  }
  render();
  requestAnimationFrame(frameLoop);
}

function init() {
  const canvas = document.getElementById('stageCanvas');
  ctx = canvas.getContext('2d');

  pulsarImg = loadImage('assets/pulsar-dot.svg');
  earthImg = loadImage('assets/earth-dot.svg');

  buildOrbitLayers();
  wireControls();

  state.timerLast = performance.now();
  state.animating = !prefersReducedMotion();
  pauseButton.textContent = state.animating ? 'pause' : 'run';
  updateSpeedValueText();
  updateOrbits();
  announceState('Simulation loaded.');

  requestAnimationFrame(frameLoop);
}

// No displayed equations/symbols exist in this sim (see CONVERSION_NOTES.md),
// so klunlInitEqn is left at its foundation no-op default and MathJax is not
// loaded.

if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', init);
} else {
  init();
}
