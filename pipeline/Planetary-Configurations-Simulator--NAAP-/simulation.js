/* ============================================================================
   Planetary Configurations Simulator — behaviour ported from the decompiled
   ActionScript 1 (scripts/Configurations Simulator.as, Orbits Diagram.as,
   Orbits Diagram Planet.as, Timeline.as, Zodiac Strip.as, and the component
   init records). All physics constants, formulas and on-screen text are
   verbatim from the source. Presentation is rebuilt on the KL-UNL foundation.

   Single source of truth: the `sim` object. render() redraws all three canvas
   stages and syncs the DOM + screen-reader regions from that state.
   ========================================================================== */
(function () {
  'use strict';

  var TWO_PI = 6.283185307179586;   // verbatim from AS source
  var PI     = 3.141592653589793;

  // AS decimal-RGB color int -> CSS hex
  function C(n) { return '#' + (n >>> 0 & 0xFFFFFF).toString(16).padStart(6, '0'); }
  function norm2pi(a) { return ((a % TWO_PI) + TWO_PI) % TWO_PI; }
  function mod360(x) { return ((x % 360) + 360) % 360; }

  // ---- Preset combo data (verbatim from FComboBox init records) ----
  var PRESET_LABELS = ['<presets>', 'Mercury', 'Venus', 'Earth', 'Mars', 'Jupiter', 'Saturn'];
  var PRESET_DATA   = [0, 0.39, 0.72, 1, 1.52, 5.2, 9.54];

  // ------------------------------------------------------------------------
  //  STATE (mirrors ConfigurationsSimulatorClass fields)
  // ------------------------------------------------------------------------
  var sim = {
    semimajorAxis1: 1, semimajorAxis2: 2.4,
    period1: 1, period2: Math.pow(2.4, 1.5),
    epochAngle1: 0, epochAngle2: 0,
    _time: 0,
    angle1: 0, angle2: 0,
    // derived by calculateSystemProperties:
    synodicPeriod: 0, cycleOffset: 0,
    eventTimesList: [0, 0, 0, 0],
    eventNamesList: ['opposition', 'quadrature (eastern)', 'conjunction', 'quadrature (western)'],
    // derived by update():
    planetLongitude: 0, sunLongitude: 0,
    elongationValue: 0, elongationString: '',
    // event tracking:
    currentCycleNumber: 0, nextCycleNumber: 0, nextEventNumber: 0, nextEventTime: 0,
    lockedOnEvent: false, lockedCycleNumber: 0, lockedEventNumber: 0,
    // animation:
    _animationState: false,
    angularAnimationRate: 0.001, animationRate: 0,
    eventAction: 'run', pauseTime: 5,
    // options:
    labelOrbits: true, showElongationAngle: true /*set false in reset*/, snapToEvents: true,
    // timeline / zodiac view state:
    timelineTimeOffset: 0,
    zodiacOffset: 0
  };

  var slewTime = 650;           // p.slewTime
  var minIncrement = 0.01;      // slider fixed-digits precision 2 -> 10^-2

  // runtime loop state
  var loopMode = 'idle';        // 'idle' | 'animate' | 'slew' | 'countdown'
  var frozen = false;           // freezeAnimation() during a drag
  var timerLast = 0;
  var countdownEndsTimer = 0;
  var slewStartTimer = 0, slewStartTime = 0, slewDeltaTime = 0,
      slewTargetCycleNumber = 0, slewTargetEventNumber = 0;

  // ------------------------------------------------------------------------
  //  CORE SIMULATOR LOGIC (ported method-for-method)
  // ------------------------------------------------------------------------
  function update() {
    sim.angle1 = norm2pi(sim.epochAngle1 + TWO_PI * sim._time / sim.period1);
    sim.angle2 = norm2pi(sim.epochAngle2 + TWO_PI * sim._time / sim.period2);
    var x1 = sim.semimajorAxis1 * Math.cos(sim.angle1);
    var y1 = sim.semimajorAxis1 * Math.sin(sim.angle1);
    var x2 = sim.semimajorAxis2 * Math.cos(sim.angle2);
    var y2 = sim.semimajorAxis2 * Math.sin(sim.angle2);
    sim.planetLongitude = norm2pi(Math.atan2(y2 - y1, x2 - x1));
    sim.sunLongitude    = norm2pi(Math.atan2(-y1, -x1));
    var elong = mod360((sim.sunLongitude - sim.planetLongitude) * 180 / PI);
    if (elong > 180) elong -= 360;
    sim.elongationString = Math.abs(elong).toFixed(1);
    sim.elongationValue = parseFloat(sim.elongationString);
    if (elong < 0 && sim.elongationValue !== 180) sim.elongationValue *= -1;
    sim.elongationString += '°';
    if (sim.elongationValue < 0) sim.elongationString += ' E';
    else if (sim.elongationValue > 0 && sim.elongationValue !== 180) sim.elongationString += ' W';
    render();
  }

  function calculateAnimationRate() {
    sim.animationRate = sim.angularAnimationRate * Math.min(sim.period1, sim.period2) / TWO_PI;
  }

  function calculateSystemProperties() {
    var inferiorSemimajor, superiorSemimajor, inferiorPeriod, superiorPeriod,
        inferiorEpochAngle, superiorEpochAngle;
    if (sim.semimajorAxis1 < sim.semimajorAxis2) {
      inferiorSemimajor = sim.semimajorAxis1; superiorSemimajor = sim.semimajorAxis2;
      inferiorPeriod = sim.period1; superiorPeriod = sim.period2;
      inferiorEpochAngle = sim.epochAngle1; superiorEpochAngle = sim.epochAngle2;
      sim.eventNamesList = ['opposition', 'quadrature (eastern)', 'conjunction', 'quadrature (western)'];
    } else {
      inferiorSemimajor = sim.semimajorAxis2; superiorSemimajor = sim.semimajorAxis1;
      inferiorPeriod = sim.period2; superiorPeriod = sim.period1;
      inferiorEpochAngle = sim.epochAngle2; superiorEpochAngle = sim.epochAngle1;
      sim.eventNamesList = ['inferior conjunction', 'greatest elongation (western)', 'superior conjunction', 'greatest elongation (eastern)'];
    }
    sim.synodicPeriod = 1 / (1 / inferiorPeriod - 1 / superiorPeriod);
    var epochAngleOffset = norm2pi(superiorEpochAngle - inferiorEpochAngle);
    var catchUpRate = TWO_PI / sim.synodicPeriod;
    sim.cycleOffset = epochAngleOffset / catchUpRate;
    var deltaTime = Math.acos(inferiorSemimajor / superiorSemimajor) / catchUpRate;
    sim.eventTimesList = [0, deltaTime, sim.synodicPeriod / 2, sim.synodicPeriod - deltaTime];
    // system-properties listeners are the render-time recomputations (diagram
    // radii, timeline scale, zodiac inferior/superior) — handled in render().
  }

  function cancelAnimationCountdown() {
    if (loopMode === 'countdown') loopMode = 'idle';
    setCountdownText('');
  }

  function getTime() { return sim._time; }

  function setTime(newTime, snapToEvents, timeThreshold) {
    cancelAnimationCountdown();
    if (snapToEvents) {
      var prevCycleNumber = Math.floor((newTime - sim.cycleOffset) / sim.synodicPeriod);
      var timeRemainder = newTime - sim.cycleOffset - prevCycleNumber * sim.synodicPeriod;
      if (timeRemainder < 0) timeRemainder = 0;
      var i = 0;
      while (i < 4) { if (timeRemainder < sim.eventTimesList[i]) break; i++; }
      var prevEventNumber = i - 1, nextEventNumber, nextCycleNumber;
      if (i < 4) { nextEventNumber = i; nextCycleNumber = prevCycleNumber; }
      else { nextEventNumber = 0; nextCycleNumber = prevCycleNumber + 1; }
      var prevEventTime = sim.cycleOffset + prevCycleNumber * sim.synodicPeriod + sim.eventTimesList[prevEventNumber];
      var nextEventTime = sim.cycleOffset + nextCycleNumber * sim.synodicPeriod + sim.eventTimesList[nextEventNumber];
      var timeToPrevEvent = Math.abs(newTime - prevEventTime);
      var timeToNextEvent = Math.abs(nextEventTime - newTime);
      var nearestEventTime = Math.min(timeToPrevEvent, timeToNextEvent);
      if (timeThreshold == undefined || timeThreshold == null || nearestEventTime < timeThreshold) {
        if (nearestEventTime === timeToPrevEvent) setTimeByCycleAndEventNumbers(prevCycleNumber, prevEventNumber);
        else setTimeByCycleAndEventNumbers(nextCycleNumber, nextEventNumber);
        return;
      }
    }
    sim._time = newTime;
    sim.currentCycleNumber = Math.floor((sim._time - sim.cycleOffset) / sim.synodicPeriod);
    var tr = sim._time - sim.cycleOffset - sim.currentCycleNumber * sim.synodicPeriod;
    if (tr < 0) tr = 0;
    var j = 0;
    while (j < 4) { if (tr < sim.eventTimesList[j]) break; j++; }
    if (j < 4) { sim.nextEventNumber = j; sim.nextCycleNumber = sim.currentCycleNumber; }
    else { sim.nextEventNumber = 0; sim.nextCycleNumber = sim.currentCycleNumber + 1; }
    sim.nextEventTime = sim.cycleOffset + sim.nextCycleNumber * sim.synodicPeriod + sim.eventTimesList[sim.nextEventNumber];
    sim.lockedOnEvent = false;
    update();
  }

  function setTimeByCycleAndEventNumbers(cycleNumber, eventNumber, noLock) {
    cancelAnimationCountdown();
    sim._time = sim.cycleOffset + cycleNumber * sim.synodicPeriod + sim.eventTimesList[eventNumber];
    sim.currentCycleNumber = cycleNumber;
    sim.nextCycleNumber = cycleNumber;
    sim.nextEventNumber = eventNumber + 1;
    if (sim.nextEventNumber === 4) { sim.nextEventNumber = 0; sim.nextCycleNumber += 1; }
    sim.nextEventTime = sim.cycleOffset + sim.nextCycleNumber * sim.synodicPeriod + sim.eventTimesList[sim.nextEventNumber];
    sim.lockedOnEvent = !noLock;
    if (sim.lockedOnEvent) { sim.lockedCycleNumber = cycleNumber; sim.lockedEventNumber = eventNumber; }
    update();
  }

  function setTimeByPlanetAngle(planetID, newAngle, snapToEvents, angleThreshold) {
    cancelAnimationCountdown();
    var epochAngle = sim['epochAngle' + planetID];
    var period = sim['period' + planetID];
    var oldAngle = norm2pi(epochAngle + TWO_PI * sim._time / period);
    var deltaAngle = newAngle - oldAngle;
    if (deltaAngle < -PI) deltaAngle += TWO_PI;
    if (deltaAngle > PI) deltaAngle -= TWO_PI;
    var newTime = sim._time + deltaAngle * period / TWO_PI;
    if (snapToEvents) {
      var prevCycleNumber = Math.floor((newTime - sim.cycleOffset) / sim.synodicPeriod);
      var timeRemainder = newTime - sim.cycleOffset - prevCycleNumber * sim.synodicPeriod;
      if (timeRemainder < 0) timeRemainder = 0;
      var i = 0;
      while (i < 4) { if (timeRemainder < sim.eventTimesList[i]) break; i++; }
      var prevEventNumber = i - 1, nextEventNumber, nextCycleNumber;
      if (i < 4) { nextEventNumber = i; nextCycleNumber = prevCycleNumber; }
      else { nextEventNumber = 0; nextCycleNumber = prevCycleNumber + 1; }
      var prevEventTime = sim.cycleOffset + prevCycleNumber * sim.synodicPeriod + sim.eventTimesList[prevEventNumber];
      var nextEventTime = sim.cycleOffset + nextCycleNumber * sim.synodicPeriod + sim.eventTimesList[nextEventNumber];
      var angleToPrevEvent = (newTime - prevEventTime) * 2 * PI / period;
      var angleToNextEvent = (nextEventTime - newTime) * 2 * PI / period;
      var minAngle = Math.min(angleToNextEvent, angleToPrevEvent);
      if (minAngle < angleThreshold) {
        if (minAngle === angleToNextEvent) setTimeByCycleAndEventNumbers(nextCycleNumber, nextEventNumber);
        else setTimeByCycleAndEventNumbers(prevCycleNumber, prevEventNumber);
      } else setTime(newTime);
    } else setTime(newTime);
  }

  function setEpochAngleByPlanetAngle(planetID, newAngle, snapToEvents, angleThreshold) {
    cancelAnimationCountdown();
    var setTimeByEventDetails = false, snapEventNumber;
    if (snapToEvents) {
      var otherID = 1 + planetID % 2;
      var thisSemimajor = sim['semimajorAxis' + planetID];
      var otherSemimajor = sim['semimajorAxis' + otherID];
      var otherAngle = sim['angle' + otherID];
      var snapAnglesList = [];
      snapAnglesList[0] = otherAngle;
      snapAnglesList[2] = norm2pi(otherAngle + PI);
      var theta = (thisSemimajor < otherSemimajor)
        ? Math.acos(thisSemimajor / otherSemimajor)
        : -Math.acos(otherSemimajor / thisSemimajor);
      snapAnglesList[1] = norm2pi(otherAngle + theta);
      snapAnglesList[3] = norm2pi(otherAngle - theta);
      var closestSnapAngleDistance = Infinity, closestSnapAngleEventNumber = null;
      var i = 0;
      while (i < 4) {
        var delta = newAngle - snapAnglesList[i];
        if (delta < -PI) delta += TWO_PI; else if (delta > PI) delta -= TWO_PI;
        if (Math.abs(delta) < closestSnapAngleDistance) {
          closestSnapAngleDistance = Math.abs(delta); closestSnapAngleEventNumber = i;
        }
        i++;
      }
      if (closestSnapAngleDistance < angleThreshold) {
        snapEventNumber = closestSnapAngleEventNumber;
        newAngle = snapAnglesList[snapEventNumber];
        setTimeByEventDetails = true;
      }
    }
    var newEpochAngle = norm2pi(newAngle - TWO_PI * sim._time / sim['period' + planetID]);
    sim['epochAngle' + planetID] = newEpochAngle;
    calculateSystemProperties();
    if (setTimeByEventDetails) {
      var snapCycleNumber = Math.round((sim._time - sim.cycleOffset - sim.eventTimesList[snapEventNumber]) / sim.synodicPeriod);
      setTimeByCycleAndEventNumbers(snapCycleNumber, snapEventNumber);
    } else {
      setTime(sim._time);
    }
  }

  function setSemimajorAxis(planetID, semimajorAxis, keepEpochAngleFixed) {
    cancelAnimationCountdown();
    if (Math.abs(semimajorAxis - sim['semimajorAxis' + (1 + planetID % 2)]) < 1e-10) return false;
    sim['semimajorAxis' + planetID] = semimajorAxis;
    var newPeriod = Math.pow(semimajorAxis, 1.5);   // Kepler III: P = a^1.5 (years, AU)
    if (!keepEpochAngleFixed) {
      var positionAngle = sim['epochAngle' + planetID] + TWO_PI * sim._time / sim['period' + planetID];
      sim['epochAngle' + planetID] = norm2pi(positionAngle - TWO_PI * sim._time / newPeriod);
    }
    sim['period' + planetID] = newPeriod;
    calculateSystemProperties();
    calculateAnimationRate();
    if (sim.lockedOnEvent && sim.lockedEventNumber % 2 === 0) setTime(sim._time, true);
    else setTime(sim._time);
    return true;
  }

  function setSemimajorAxisFromSlider(id) {
    var slider = document.getElementById('a' + id + '-slider');
    var newValue = parseFloat(slider.value);
    var success = setSemimajorAxis(id, newValue);
    if (!success) {
      var oldValue = sim['semimajorAxis' + id];
      var otherValue = sim['semimajorAxis' + (1 + id % 2)];
      var minV = parseFloat(slider.min), maxV = parseFloat(slider.max);
      if (newValue === maxV) setSemimajorAxis(id, maxV - minIncrement);
      else if (newValue === minV) setSemimajorAxis(id, minV + minIncrement);
      else if (oldValue < otherValue) setSemimajorAxis(id, otherValue + minIncrement);
      else setSemimajorAxis(id, otherValue - minIncrement);
    }
    resetPreset(id);
  }

  // ---- animation state ----
  function getAnimationState() { return sim._animationState; }
  function setAnimationState(arg) {
    cancelAnimationCountdown();
    sim._animationState = Boolean(arg);
    if (sim._animationState) {
      timerLast = performance.now();
      loopMode = 'animate';
      document.getElementById('animate-btn').textContent = 'stop animation';
      announce('Animation started.');
    } else {
      if (loopMode === 'animate') loopMode = 'idle';
      document.getElementById('animate-btn').textContent = 'start animation';
    }
    ensureLoop();
  }
  function toggleAnimation() {
    var was = getAnimationState();
    setAnimationState(!was);
    if (was) announce('Animation stopped.');
  }

  function freezeAnimation() { cancelAnimationCountdown(); frozen = true; }
  function thawAnimation() {
    frozen = false;
    if (sim._animationState) { timerLast = performance.now(); loopMode = 'animate'; ensureLoop(); }
  }

  function startAnimationCountdown() {
    loopMode = 'countdown';
    countdownEndsTimer = performance.now() + 1000 * sim.pauseTime;
    ensureLoop();
  }

  function slewToEvent(cycleNumber, eventNumber) {
    if (sim.lockedOnEvent && sim.lockedCycleNumber === cycleNumber && sim.lockedEventNumber === eventNumber) return;
    cancelAnimationCountdown();
    setAnimationState(false);
    slewStartTimer = performance.now();
    slewTargetCycleNumber = cycleNumber;
    slewTargetEventNumber = eventNumber;
    var slewTargetTime = sim.cycleOffset + cycleNumber * sim.synodicPeriod + sim.eventTimesList[eventNumber];
    slewStartTime = sim._time;
    slewDeltaTime = slewTargetTime - slewStartTime;
    timerLast = slewStartTimer;
    loopMode = 'slew';
    ensureLoop();
  }

  // ---- single requestAnimationFrame loop dispatching on loopMode ----
  var rafPending = false;
  function ensureLoop() {
    if (rafPending) return;
    if (loopMode === 'idle' || frozen) return;
    rafPending = true;
    requestAnimationFrame(tick);
  }
  function tick() {
    rafPending = false;
    if (frozen) return;
    if (loopMode === 'animate') animateTick();
    else if (loopMode === 'slew') slewTick();
    else if (loopMode === 'countdown') countdownTick();
    if (loopMode !== 'idle' && !frozen) { rafPending = true; requestAnimationFrame(tick); }
  }
  function animateTick() {
    var timerNow = performance.now();
    var newTime = sim._time + sim.animationRate * (timerNow - timerLast);
    if (newTime > sim.nextEventTime && sim.eventAction !== 'run') {
      setTimeByCycleAndEventNumbers(sim.nextCycleNumber, sim.nextEventNumber);
      setAnimationState(false);
      announce('Event reached: ' + sim.eventNamesList[sim.lockedEventNumber] + '.');
      if (sim.eventAction === 'pause') startAnimationCountdown();
    } else {
      setTime(newTime);
    }
    timerLast = timerNow;
  }
  function slewTick() {
    var timerNow = performance.now();
    var u = (timerNow - slewStartTimer) / slewTime;
    if (u < 1) {
      var f = 1 - Math.pow(1 - u, 3);
      setTime(slewStartTime + f * slewDeltaTime);
    } else {
      setTimeByCycleAndEventNumbers(slewTargetCycleNumber, slewTargetEventNumber);
      loopMode = 'idle';
      announce('Moved to ' + sim.eventNamesList[slewTargetEventNumber] + '.');
    }
  }
  function countdownTick() {
    var timeNow = performance.now();
    var timeleft = Math.ceil((countdownEndsTimer - timeNow) / 1000);
    setCountdownText(timeleft === 1
      ? 'paused for ' + timeleft + ' more second'
      : 'paused for ' + timeleft + ' more seconds');
    if (timeNow > countdownEndsTimer) {
      cancelAnimationCountdown();
      setAnimationState(true);
    }
  }
  function setCountdownText(t) {
    var el = document.getElementById('countdown-field');
    el.textContent = t;
  }

  // ------------------------------------------------------------------------
  //  RESET  (ConfigurationsSimulatorClass.onReset)
  // ------------------------------------------------------------------------
  function onReset() {
    setAnimationState(false);
    loopMode = 'idle'; frozen = false;
    sim.epochAngle1 = 0; sim.epochAngle2 = 0;
    // setSemimajorAxis(...,true) with system calcs suppressed, matching source:
    sim.semimajorAxis1 = 1; sim.period1 = 1;
    sim.semimajorAxis2 = 2.4; sim.period2 = Math.pow(2.4, 1.5);
    sim.angularAnimationRate = 0.001;
    sim.eventAction = 'run';
    sim.pauseTime = 5;
    calculateSystemProperties();
    calculateAnimationRate();
    setTime(0, true);
    // reset listeners: diagram options, timeline zero, zodiac offset
    sim.labelOrbits = true;
    sim.showElongationAngle = false;
    sim.snapToEvents = true;
    sim.timelineTimeOffset = -sim._time;   // zeroTimelineTime()
    setZodiacOffset(-100);                  // zodiac onSimulatorReset
    syncAllControls();
    render();
    announce('Simulator reset. Observer’s planet orbit 1.00 astronomical units, target planet 2.40 astronomical units. Configuration: opposition.');
  }

  function setZodiacOffset(arg) {
    sim.zodiacOffset = ((arg % 400) + 400) % 400;
  }

  // ========================================================================
  //  RENDERING
  // ========================================================================
  var diagCanvas, diagCtx, zCanvas, zCtx, tCanvas, tCtx;
  var timelineEventRects = [];   // hit targets for clicking event names
  var starfieldImg = new Image();
  var starfieldReady = false;

  // diagram constants (Orbits Diagram.as)
  var DIAG_W = 450, DIAG_MARGIN = 60, ANGLE_MARGIN = 15, SNAP_DISTANCE = 10;
  var CENTER = 225;                       // maskedAreaMC at (w/2, w/2)
  var ORBIT_COLOR = C(13158600);          // #c8c8c8
  var OBSERVER_COLOR = C(8626940);        // observer's planet
  var TARGET_COLOR = C(10000536);         // target planet
  var ANGLE_LINE_COLOR = C(10526880);     // elongation angle lines
  var SUN_COLOR = '#f4c40f';              // "Orbits Diagram Sun" (approx; noted)
  var PLANET_R = 7, SUN_R = 9;            // disc radii (approx; noted)

  function render() {
    if (!diagCtx) return;
    drawDiagram();
    drawZodiac();
    drawTimeline();
    syncReadouts();
    updateDescriptions();
  }

  // ---- DIAGRAM ----
  function screenRadii() {
    var scale = (DIAG_W - 2 * DIAG_MARGIN) / Math.max(sim.semimajorAxis1, sim.semimajorAxis2);
    return [scale * sim.semimajorAxis1 / 2, scale * sim.semimajorAxis2 / 2];
  }

  function drawDiagram() {
    var ctx = diagCtx;
    ctx.clearRect(0, 0, DIAG_W, DIAG_W);
    var r = screenRadii(), r1 = r[0], r2 = r[1];

    // orbits
    ctx.strokeStyle = ORBIT_COLOR; ctx.lineWidth = 1;
    ctx.beginPath(); ctx.arc(CENTER, CENTER, r1, 0, TWO_PI); ctx.stroke();
    ctx.beginPath(); ctx.arc(CENTER, CENTER, r2, 0, TWO_PI); ctx.stroke();

    // planet positions (screen y down)
    var x1 = r1 * Math.cos(sim.angle1), y1 = -r1 * Math.sin(sim.angle1);
    var x2 = r2 * Math.cos(sim.angle2), y2 = -r2 * Math.sin(sim.angle2);

    if (sim.showElongationAngle) drawElongationAngle(ctx, x1, y1, x2, y2);

    // orbit labels (CurvedText: observer along its orbit bottom, target top)
    if (sim.labelOrbits) {
      var eR = 13, minR = 30;
      var lr1 = (r1 + eR < minR) ? minR : eR + r1;
      var lr2 = (r2 + eR < minR) ? minR : eR + r2;
      drawCurvedLabel(ctx, "observer's planet", CENTER, CENTER, lr1, true);
      drawCurvedLabel(ctx, 'target planet', CENTER, CENTER, lr2, false);
    }

    // sun
    ctx.fillStyle = SUN_COLOR;
    ctx.beginPath(); ctx.arc(CENTER, CENTER, SUN_R, 0, TWO_PI); ctx.fill();

    // planets
    drawDisc(ctx, CENTER + x1, CENTER + y1, PLANET_R, OBSERVER_COLOR);
    drawDisc(ctx, CENTER + x2, CENTER + y2, PLANET_R, TARGET_COLOR);

    // move focusable handles over the discs
    positionHandle('planet1-handle', CENTER + x1, CENTER + y1);
    positionHandle('planet2-handle', CENTER + x2, CENTER + y2);
  }

  function drawDisc(ctx, x, y, r, color) {
    ctx.fillStyle = color; ctx.strokeStyle = 'rgba(0,0,0,0.35)'; ctx.lineWidth = 1;
    ctx.beginPath(); ctx.arc(x, y, r, 0, TWO_PI); ctx.fill(); ctx.stroke();
  }

  function positionHandle(id, x, y) {
    var el = document.getElementById(id);
    if (!el) return;
    el.style.left = (100 * x / DIAG_W) + '%';
    el.style.top = (100 * y / DIAG_W) + '%';
  }

  function drawCurvedLabel(ctx, text, cx, cy, radius, atBottom) {
    ctx.save();
    ctx.font = '12px Verdana, Geneva, Tahoma, sans-serif';
    ctx.fillStyle = '#8a8a8a';
    ctx.textAlign = 'center';
    ctx.textBaseline = 'middle';
    var chars = text.split('');
    var widths = chars.map(function (ch) { return ctx.measureText(ch).width; });
    var spacing = 0.5;
    var total = widths.reduce(function (a, b) { return a + b; }, 0) + spacing * (chars.length - 1);
    var totalAngle = total / radius;
    var center = atBottom ? Math.PI / 2 : -Math.PI / 2;
    var ang = atBottom ? center + totalAngle / 2 : center - totalAngle / 2;
    for (var i = 0; i < chars.length; i++) {
      var w = widths[i];
      var half = (w / radius) / 2;
      var a = atBottom ? ang - half : ang + half;
      var x = cx + radius * Math.cos(a), y = cy + radius * Math.sin(a);
      ctx.save();
      ctx.translate(x, y);
      ctx.rotate(atBottom ? a - Math.PI / 2 : a + Math.PI / 2);
      ctx.fillText(chars[i], 0, 0);
      ctx.restore();
      var adv = (w + spacing) / radius;
      ang = atBottom ? ang - adv : ang + adv;
    }
    ctx.restore();
  }

  function drawElongationAngle(ctx, x1, y1, x2, y2) {
    var cx = CENTER, cy = CENTER;
    var planetAngle = Math.atan2(y2 - y1, x2 - x1);
    var sunAngle = Math.atan2(-y1, -x1);
    var r = DIAG_W / 2 - ANGLE_MARGIN;   // 210
    var t = Math.sqrt(x1 * x1 + y1 * y1);
    var b = t * Math.cos(sunAngle - planetAngle);
    var Q = b * b - t * t + r * r;
    if (Q < 0) Q = 0;
    var d1 = b + Math.sqrt(Q);
    var x3 = x1 + d1 * Math.cos(planetAngle), y3 = y1 + d1 * Math.sin(planetAngle);
    var x4 = r * Math.cos(sunAngle), y4 = r * Math.sin(sunAngle);
    ctx.save();
    ctx.strokeStyle = ANGLE_LINE_COLOR; ctx.lineWidth = 1; ctx.fillStyle = ANGLE_LINE_COLOR;
    ctx.beginPath();
    ctx.moveTo(cx + x1, cy + y1); ctx.lineTo(cx + x3, cy + y3);
    ctx.moveTo(cx + x1, cy + y1); ctx.lineTo(cx + x4, cy + y4);
    ctx.stroke();
    drawArrowTip(ctx, cx + x3, cy + y3, planetAngle);
    drawArrowTip(ctx, cx + x4, cy + y4, sunAngle);
    // arc of radius 35 at the observer planet, spanning the elongation
    var ar = 35;
    if (sim.elongationValue !== 0) {
      ctx.beginPath();
      var anticw = sim.elongationValue > 0; // choose the short arc between the two rays
      ctx.arc(cx + x1, cy + y1, ar, planetAngle, sunAngle, anticw);
      ctx.stroke();
    }
    // elongation string label near the arc
    var labelAngle = sunAngle + (sim.elongationValue / 2) * 0.017453292519943295;
    var lx = cx + x1 + 45 * Math.cos(labelAngle), ly = cy + y1 + 45 * Math.sin(labelAngle);
    ctx.font = '12px Verdana, sans-serif';
    ctx.textAlign = 'center'; ctx.textBaseline = 'middle';
    var tw = ctx.measureText(sim.elongationString).width;
    ctx.fillStyle = 'rgba(255,255,255,0.6)';
    ctx.fillRect(lx - tw / 2 - 2, ly - 8, tw + 4, 16);
    ctx.fillStyle = '#333';
    ctx.fillText(sim.elongationString, lx, ly);
    ctx.restore();
  }

  function drawArrowTip(ctx, x, y, angle) {
    ctx.save();
    ctx.translate(x, y); ctx.rotate(angle);
    ctx.beginPath();
    ctx.moveTo(0, 0); ctx.lineTo(-7, -3.5); ctx.lineTo(-7, 3.5); ctx.closePath();
    ctx.fill();
    ctx.restore();
  }

  // ---- ZODIAC STRIP (Zodiac Strip.as) ----
  var ZW = 400, ZH = 60, ZTOP = 40;               // strip region on the 400x135 canvas
  var Z_SCALE = ZW / TWO_PI;                        // longitude px scale
  var Z_CONST_SCALE = ZW / 700;                     // constellation coord scale
  var Z_PROJ = 111.40846016432674, Z_OBLIQ = 0.40913426548833737;
  var NORMAL_CONST_COLOR = C(11579568);             // #b0b0b0
  var zodiacProjected = null;                       // cached projected constellation polylines

  function projectStar(px, py, wrapAdjust) {
    var ra = -px * PI / 350, dec = -py * PI / 350, e = Z_OBLIQ;
    var elat = Math.asin(Math.sin(dec) * Math.cos(e) - Math.cos(dec) * Math.sin(ra) * Math.sin(e));
    var coselon = Math.cos(dec) * Math.cos(ra) / Math.cos(elat);
    var sinelon = (Math.cos(dec) * Math.sin(ra) * Math.cos(e) + Math.sin(dec) * Math.sin(e)) / Math.cos(elat);
    var elon = norm2pi(Math.atan2(sinelon, coselon));
    var x = -elon * Z_PROJ;
    if (wrapAdjust === 'left' && x > -350) x -= 700;
    if (wrapAdjust === 'right' && x < -350) x += 700;
    var y = -elat * Z_PROJ;
    return { x: Z_CONST_SCALE * x, y: Z_CONST_SCALE * y };
  }

  function buildConstellationPolylines() {
    var consts = window.CONSTELLATIONS_DATA || [];
    var lines = [];
    for (var i = 0; i < consts.length; i++) {
      var cst = consts[i], curves = cst.path, points = cst.stars;
      var passes = (i === 7) ? ['left', 'right'] : [null];
      for (var pass = 0; pass < passes.length; pass++) {
        var wrap = passes[pass];
        for (var j = 0; j < curves.length; j++) {
          var cv = curves[j];
          var poly = [projectStar(points[cv.m].x, points[cv.m].y, wrap)];
          for (var k = cv.b; k < cv.e; k++) poly.push(projectStar(points[k].x, points[k].y, wrap));
          lines.push(poly);
        }
      }
    }
    return lines;
  }

  function drawZodiac() {
    var ctx = zCtx;
    ctx.clearRect(0, 0, ZW, ZH + 75);
    if (!zodiacProjected) zodiacProjected = buildConstellationPolylines();

    // strip content pans by zodiacOffset (Zodiac Strip.setOffset)
    var stripX = (sim.zodiacOffset < ZW / 2) ? sim.zodiacOffset : sim.zodiacOffset - ZW;
    var sunLocalX = -sim.sunLongitude * Z_SCALE;
    var planetLocalX = -sim.planetLongitude * Z_SCALE;

    ctx.save();
    // clip to the strip rectangle
    ctx.beginPath(); ctx.rect(0, ZTOP, ZW, ZH); ctx.clip();

    // starfield background (bitmap reused as-is), tiled 3x
    if (starfieldReady) {
      for (var c = -1; c <= 1; c++) {
        ctx.drawImage(starfieldImg, stripX + c * ZW, ZTOP, ZW, ZH);
      }
    }

    // constellation outlines (normal grey), tiled across the strip
    ctx.strokeStyle = NORMAL_CONST_COLOR; ctx.lineWidth = 1;
    var midY = ZTOP + ZH / 2;
    for (var copy = 0; copy <= 2; copy++) {
      var ox = stripX + copy * ZW;
      for (var li = 0; li < zodiacProjected.length; li++) {
        var poly = zodiacProjected[li];
        ctx.beginPath();
        for (var pi = 0; pi < poly.length; pi++) {
          var X = ox + poly[pi].x, Y = midY + poly[pi].y;
          if (pi === 0) ctx.moveTo(X, Y); else ctx.lineTo(X, Y);
        }
        ctx.stroke();
      }
    }

    // sun + planet icons (tiled), each offset by their longitude
    for (var t = 0; t <= 2; t++) {
      var so = stripX + sunLocalX + t * ZW;
      var po = stripX + planetLocalX + t * ZW;
      drawDisc(ctx, so, midY, 6, SUN_COLOR);
      // planet: outline ring + grey disc
      drawDisc(ctx, po, midY, 5, TARGET_COLOR);
    }
    ctx.restore();

    // sun / planet labels with connector lines above; elongation below
    drawZodiacLabels(ctx, sunLocalX, planetLocalX);
  }

  function drawZodiacLabels(ctx, sunLocalX, planetLocalX) {
    var w = ZW;
    var planetX = (((w + planetLocalX + sim.zodiacOffset) % w) + w) % w;
    var sunX = (((w + sunLocalX + sim.zodiacOffset) % w) + w) % w;
    ctx.save();
    ctx.strokeStyle = '#999'; ctx.lineWidth = 1;
    ctx.font = '12px Verdana, sans-serif';
    ctx.textAlign = 'center'; ctx.textBaseline = 'middle';
    ctx.fillStyle = '#333';
    // sun connector (taller) + label
    ctx.beginPath(); ctx.moveTo(sunX, ZTOP - 2); ctx.lineTo(sunX, ZTOP + ZH / 2 - 12); ctx.stroke();
    ctx.fillText('sun', sunX, ZTOP - 20);
    // planet connector (shorter) + label
    ctx.beginPath(); ctx.moveTo(planetX, ZTOP - 2); ctx.lineTo(planetX, ZTOP + ZH / 2 - 8); ctx.stroke();
    ctx.fillText('planet', planetX, ZTOP - 8);

    // elongation double-arrow below strip
    var y = ZTOP + ZH + 8;
    var arrowLength = Math.abs(sim.elongationValue) * ZW / 360;
    ctx.strokeStyle = '#000'; ctx.fillStyle = '#000';
    if (sim.elongationValue !== 0) {
      // draw from sun toward planet in the sign direction, wrapping across edges
      var dir = (sim.elongationValue > 0) ? 1 : -1;   // W = +, E = -
      drawZodiacArrow(ctx, sunX, y, dir, arrowLength);
    }
    ctx.textBaseline = 'top';
    var labelX = sunX + (sim.elongationValue > 0 ? 1 : -1) * arrowLength / 2;
    labelX = ((labelX % w) + w) % w;
    ctx.fillStyle = '#000';
    ctx.fillText(sim.elongationString, labelX, y + 6);
    ctx.restore();
  }

  function drawZodiacArrow(ctx, startX, y, dir, len) {
    var w = ZW;
    // segment along the strip (wrap by modulo), with arrow tips at both ends
    var endX = startX + dir * len;
    ctx.beginPath();
    // draw possibly wrapped line as up to two segments
    var x0 = startX, x1 = endX;
    var lo = Math.min(x0, x1), hi = Math.max(x0, x1);
    ctx.moveTo(lo, y); ctx.lineTo(hi, y); ctx.stroke();
    // arrow tips
    zTip(ctx, startX, y, -dir);
    zTip(ctx, endX, y, dir);
  }
  function zTip(ctx, x, y, dir) {
    ctx.beginPath();
    ctx.moveTo(x, y); ctx.lineTo(x - dir * 6, y - 3); ctx.lineTo(x - dir * 6, y + 3); ctx.closePath();
    ctx.fill();
  }

  // ---- TIMELINE (Timeline.as) ----
  var TL_W = 260, TL_H = 200, CYCLE_HEIGHT = 150, MIN_UNIT_SIZE = 20;
  var TL_SNAP_DISTANCE = 1;
  var TL_LINE_COLOR = C(15395562), TL_FILL_COLOR = C(16316664);

  function timelineScaleParams() {
    var scale = CYCLE_HEIGHT / sim.synodicPeriod;
    var minUnitTime = MIN_UNIT_SIZE / scale;
    var logUnitTime = Math.ceil(Math.log(minUnitTime) / 2.302585092994046);
    var unitTime = Math.pow(10, logUnitTime);
    var precision = -logUnitTime;
    if (unitTime / 4 > minUnitTime) { unitTime /= 4; precision += 2; }
    else if (unitTime / 2 > minUnitTime) { unitTime /= 2; precision += 1; }
    return { scale: scale, unitTime: unitTime, precision: precision };
  }

  function drawTimeline() {
    var ctx = tCtx;
    ctx.clearRect(0, 0, TL_W, TL_H);
    timelineEventRects = [];
    var p = timelineScaleParams();
    var scale = p.scale, unitTime = p.unitTime, f = p.precision;
    var timelineTime = sim._time + sim.timelineTimeOffset;
    function yOf(v) { return TL_H / 2 + scale * (v - timelineTime); }

    // shaded unit bands + boundary lines + right-edge labels
    var kMin = Math.floor((timelineTime - (TL_H / 2) / scale) / unitTime) - 1;
    var kMax = Math.ceil((timelineTime + (TL_H / 2) / scale) / unitTime) + 1;
    ctx.font = '10px Verdana, sans-serif';
    ctx.textAlign = 'right'; ctx.textBaseline = 'middle';
    for (var k = kMin; k <= kMax; k++) {
      var vy0 = yOf(k * unitTime), vy1 = yOf((k + 1) * unitTime);
      if (((k % 2) + 2) % 2 === 1) {
        ctx.fillStyle = TL_FILL_COLOR;
        ctx.fillRect(0, Math.min(vy0, vy1), TL_W, Math.abs(vy1 - vy0));
      }
      ctx.strokeStyle = TL_LINE_COLOR; ctx.lineWidth = 1;
      ctx.beginPath(); ctx.moveTo(0, vy0); ctx.lineTo(TL_W, vy0); ctx.stroke();
      var val = k * unitTime;
      var label = (f > 0) ? val.toFixed(f) : String(Math.round(val));
      ctx.fillStyle = '#8a8a8a';
      ctx.fillText(label + ' yr', TL_W - 4, vy0);
    }

    // past / future faint labels
    ctx.textAlign = 'center';
    ctx.font = 'italic bold 15px Verdana, sans-serif';
    ctx.fillStyle = 'rgba(90,100,180,0.55)';
    ctx.fillText('past', TL_W / 2, 22);
    ctx.fillText('future', TL_W / 2, TL_H - 20);

    // event names, per cycle, around the current time
    ctx.textAlign = 'left'; ctx.textBaseline = 'middle';
    ctx.font = '11px Verdana, sans-serif';
    var cyclesAround = 2 + Math.ceil(TL_H / CYCLE_HEIGHT);
    var startCycle = sim.currentCycleNumber - Math.ceil(cyclesAround / 2);
    for (var cyc = startCycle; cyc <= startCycle + cyclesAround; cyc++) {
      for (var ev = 0; ev < 4; ev++) {
        var et = sim.cycleOffset + cyc * sim.synodicPeriod + sim.eventTimesList[ev];
        var ey = yOf(et);
        if (ey < -10 || ey > TL_H + 10) continue;
        var name = sim.eventNamesList[ev];
        var isLocked = sim.lockedOnEvent && cyc === sim.lockedCycleNumber && ev === sim.lockedEventNumber;
        var tx = 20;
        var tw = ctx.measureText(name).width;
        if (isLocked) {
          ctx.fillStyle = '#ffffff'; ctx.strokeStyle = C(16765136); ctx.lineWidth = 1;
          ctx.fillRect(tx - 3, ey - 9, tw + 6, 18);
          ctx.strokeRect(tx - 3, ey - 9, tw + 6, 18);
          ctx.fillStyle = C(16711680);   // red
        } else {
          ctx.fillStyle = '#111';
        }
        ctx.fillText(name, tx, ey);
        timelineEventRects.push({ x: tx - 3, y: ey - 9, w: tw + 6, h: 18, cycle: cyc, event: ev, locked: isLocked });
      }
    }

    // red cursor at center + inward-pointing markers
    ctx.strokeStyle = C(16711680); ctx.fillStyle = C(16711680); ctx.lineWidth = 1;
    ctx.beginPath(); ctx.moveTo(0, TL_H / 2); ctx.lineTo(TL_W, TL_H / 2); ctx.stroke();
    ctx.beginPath(); ctx.moveTo(0, TL_H / 2 - 6); ctx.lineTo(10, TL_H / 2); ctx.lineTo(0, TL_H / 2 + 6); ctx.closePath(); ctx.fill();
    ctx.beginPath(); ctx.moveTo(TL_W, TL_H / 2 - 6); ctx.lineTo(TL_W - 10, TL_H / 2); ctx.lineTo(TL_W, TL_H / 2 + 6); ctx.closePath(); ctx.fill();
  }

  // ---- counter string (Timeline.updateTimeScale) ----
  function counterString() {
    var timelineTime = sim._time + sim.timelineTimeOffset;
    var daysInYear = 365.24;
    var decimalYearsString = timelineTime.toFixed(3);
    var absTimeInDays = daysInYear * Math.abs(timelineTime);
    var counterYears = Math.floor(absTimeInDays / daysInYear);
    var counterDays = absTimeInDays - counterYears * daysInYear;
    var s = decimalYearsString + ' years';
    if (counterYears !== 0 || counterDays !== 0) {
      if (timelineTime < 0) {
        s += ', (';
        if (counterYears === 1) s += '-' + counterYears + ' year, ';
        else if (counterYears > 1) s += '-' + counterYears + ' years, ';
        s += '-' + counterDays.toFixed(1) + ' days';
        s += ')';
      } else {
        s += ', (';
        if (counterYears === 1) s += counterYears + ' year, ';
        else if (counterYears > 1) s += counterYears + ' years, ';
        s += counterDays.toFixed(1) + ' days';
        s += ')';
      }
    }
    return s;
  }

  // ========================================================================
  //  DOM SYNC + SCREEN-READER
  // ========================================================================
  function announce(msg) {
    var el = document.getElementById('sr-status');
    if (el) el.textContent = msg;
  }

  function fmtAxis(v) { return v.toFixed(2); }

  function syncReadouts() {
    // orbit value fields (only when not focused, so typing isn't clobbered)
    var a1f = document.getElementById('a1-field'), a2f = document.getElementById('a2-field');
    if (document.activeElement !== a1f) a1f.value = fmtAxis(sim.semimajorAxis1);
    if (document.activeElement !== a2f) a2f.value = fmtAxis(sim.semimajorAxis2);
    var a1s = document.getElementById('a1-slider'), a2s = document.getElementById('a2-slider');
    if (document.activeElement !== a1s) a1s.value = sim.semimajorAxis1;
    if (document.activeElement !== a2s) a2s.value = sim.semimajorAxis2;
    a1s.setAttribute('aria-valuetext', 'Observer’s planet orbit radius ' + fmtAxis(sim.semimajorAxis1) + ' astronomical units');
    a2s.setAttribute('aria-valuetext', 'Target planet orbit radius ' + fmtAxis(sim.semimajorAxis2) + ' astronomical units');

    // counter
    document.getElementById('counter-field').textContent = counterString();

    // planet handle aria values (position + config)
    var p1 = document.getElementById('planet1-handle');
    var p2 = document.getElementById('planet2-handle');
    var deg1 = (sim.angle1 * 180 / PI).toFixed(0), deg2 = (sim.angle2 * 180 / PI).toFixed(0);
    var cfg = sim.lockedOnEvent ? (', configuration ' + sim.eventNamesList[sim.lockedEventNumber]) : '';
    p1.setAttribute('aria-valuenow', deg1);
    p1.setAttribute('aria-valuetext', 'Observer’s planet at orbital angle ' + deg1 + ' degrees. Elongation ' + elongSpoken() + cfg);
    p2.setAttribute('aria-valuenow', deg2);
    p2.setAttribute('aria-valuetext', 'Target planet at orbital angle ' + deg2 + ' degrees. Elongation ' + elongSpoken() + cfg);

    // timeline slider value
    var tl = document.getElementById('timeline-canvas');
    tl.setAttribute('aria-valuenow', (sim._time + sim.timelineTimeOffset).toFixed(3));
    tl.setAttribute('aria-valuetext', counterString() + (sim.lockedOnEvent ? ('. Currently at ' + sim.eventNamesList[sim.lockedEventNumber]) : ''));

    var zc = document.getElementById('zodiac-canvas');
    zc.setAttribute('aria-valuenow', sim.zodiacOffset.toFixed(0));
  }

  function elongSpoken() {
    var v = Math.abs(sim.elongationValue).toFixed(1);
    if (sim.elongationValue < 0) return v + ' degrees east';
    if (sim.elongationValue > 0 && sim.elongationValue !== 180) return v + ' degrees west';
    return v + ' degrees';
  }

  function updateDescriptions() {
    var cfg = sim.lockedOnEvent ? ('Current configuration: ' + sim.eventNamesList[sim.lockedEventNumber] + '. ') : '';
    document.getElementById('diagram-desc').textContent =
      'Orbit diagram. Observer’s planet orbit radius ' + fmtAxis(sim.semimajorAxis1) +
      ' astronomical units, target planet orbit radius ' + fmtAxis(sim.semimajorAxis2) +
      ' astronomical units. ' + cfg + 'Elongation of the target planet from the sun: ' + elongSpoken() + '.';
    document.getElementById('zodiac-desc').textContent =
      'Zodiac strip showing the sun and target planet against the stars. Elongation ' + elongSpoken() + '.';
    document.getElementById('timeline-desc').textContent =
      'Timeline. ' + counterString() + '. ' + cfg;
  }

  function resetPreset(id) { document.getElementById('a' + id + '-preset').selectedIndex = 0; }

  function syncAllControls() {
    document.getElementById('opt-label-orbits').checked = sim.labelOrbits;
    document.getElementById('opt-elongation').checked = sim.showElongationAngle;
    document.getElementById('opt-snap').checked = sim.snapToEvents;
    document.getElementById('speed-slider').value = sim.angularAnimationRate;
    document.getElementById('pause-field').value = sim.pauseTime;
    document.getElementById('ea-' + sim.eventAction).checked = true;
    document.getElementById('animate-btn').textContent = sim._animationState ? 'stop animation' : 'start animation';
    resetPreset(1); resetPreset(2);
    setCountdownText('');
    updateSpeedAria();
  }

  function updateSpeedAria() {
    document.getElementById('speed-slider').setAttribute('aria-valuetext',
      'Animation speed ' + sim.angularAnimationRate.toFixed(5) + ' radians per millisecond');
  }

  // ========================================================================
  //  INPUT WIRING
  // ========================================================================
  function computeAngleThreshold(id) {
    var r = screenRadii()[id - 1];
    var d = SNAP_DISTANCE;
    var cosThreshold = 1 - d * d / (2 * r * r);
    return (cosThreshold < -1) ? 0 : Math.acos(cosThreshold);
  }

  function wireControls() {
    // orbit sliders
    document.getElementById('a1-slider').addEventListener('input', function () { setSemimajorAxisFromSlider(1); announce('Observer’s planet orbit ' + fmtAxis(sim.semimajorAxis1) + ' astronomical units.'); });
    document.getElementById('a2-slider').addEventListener('input', function () { setSemimajorAxisFromSlider(2); announce('Target planet orbit ' + fmtAxis(sim.semimajorAxis2) + ' astronomical units.'); });

    // orbit fields (editable text)
    wireAxisField(1); wireAxisField(2);

    // preset combos
    var s1 = document.getElementById('a1-preset'), s2 = document.getElementById('a2-preset');
    PRESET_LABELS.forEach(function (lbl, i) {
      s1.add(new Option(lbl, String(i))); s2.add(new Option(lbl, String(i)));
    });
    s1.addEventListener('change', function () { onPresetChanged(1, s1); });
    s2.addEventListener('change', function () { onPresetChanged(2, s2); });

    // speed slider
    document.getElementById('speed-slider').addEventListener('input', function (e) {
      sim.angularAnimationRate = parseFloat(e.target.value);
      calculateAnimationRate(); updateSpeedAria();
    });

    // animate button
    document.getElementById('animate-btn').addEventListener('click', toggleAnimation);

    // event-action radios
    ['stop', 'run', 'pause'].forEach(function (v) {
      document.getElementById('ea-' + v).addEventListener('change', function () {
        if (this.checked) { sim.eventAction = v; announce('When an event occurs: ' + (v === 'run' ? 'keep going' : v) + '.'); }
      });
    });

    // pause field
    var pf = document.getElementById('pause-field');
    pf.addEventListener('change', function () {
      var n = parseInt(pf.value, 10);
      if (!isFinite(n) || isNaN(n)) n = sim.pauseTime;
      n = Math.max(1, Math.min(15, n));
      sim.pauseTime = n; pf.value = n;
      // onPauseTimeChanged -> selects "pause"
      sim.eventAction = 'pause';
      document.getElementById('ea-pause').checked = true;
    });

    // diagram options
    document.getElementById('opt-label-orbits').addEventListener('change', function () { sim.labelOrbits = this.checked; render(); });
    document.getElementById('opt-elongation').addEventListener('change', function () { sim.showElongationAngle = this.checked; render(); });
    document.getElementById('opt-snap').addEventListener('change', function () { sim.snapToEvents = this.checked; });

    // zero counter
    document.getElementById('zero-counter-btn').addEventListener('click', function () {
      sim.timelineTimeOffset = -sim._time; render();
      announce('Counter zeroed. ' + counterString() + '.');
    });

    // planets: pointer + keyboard
    wirePlanet(1); wirePlanet(2);

    // timeline: pointer + keyboard
    wireTimeline();

    // zodiac: pointer + keyboard
    wireZodiac();

    // masthead reset
    document.addEventListener('sim-reset', onReset);
  }

  function wireAxisField(id) {
    var f = document.getElementById('a' + id + '-field');
    f.addEventListener('change', function () {
      var v = parseFloat(f.value);
      if (!isFinite(v) || isNaN(v)) { f.value = fmtAxis(sim['semimajorAxis' + id]); return; }
      v = Math.max(0.25, Math.min(10, v));
      var ok = setSemimajorAxis(id, v);
      if (!ok) f.value = fmtAxis(sim['semimajorAxis' + id]);
      resetPreset(id);
      announce((id === 1 ? 'Observer’s' : 'Target') + ' planet orbit ' + fmtAxis(sim['semimajorAxis' + id]) + ' astronomical units.');
    });
  }

  function onPresetChanged(id, sel) {
    var a = PRESET_DATA[parseInt(sel.value, 10)];
    if (a !== 0 && isFinite(a) && !isNaN(a)) {
      var ok = setSemimajorAxis(id, a);
      if (!ok) resetPreset(id);
      else announce((id === 1 ? 'Observer’s' : 'Target') + ' planet set to ' + PRESET_LABELS[parseInt(sel.value, 10)] + ', ' + fmtAxis(a) + ' astronomical units.');
    } else {
      resetPreset(id);
    }
  }

  // ---- draggable planet (pointer + keyboard) ----
  function wirePlanet(id) {
    var handle = document.getElementById('planet' + id + '-handle');
    var dragging = false, angleOffset = 0, angleThreshold = 0, epochMode = false;

    function stageAngleFromEvent(e) {
      var rect = diagCanvas.getBoundingClientRect();
      var sx = DIAG_W / rect.width, sy = DIAG_W / rect.height;
      var mx = (e.clientX - rect.left) * sx - CENTER;   // stage coords rel. center
      var my = (e.clientY - rect.top) * sy - CENTER;
      // AS: mouseAngle = atan2(-_ymouse, _xmouse)  (screen y up)
      return norm2pi(Math.atan2(-my, mx));
    }

    handle.addEventListener('pointerdown', function (e) {
      e.preventDefault();
      handle.focus();
      handle.setPointerCapture(e.pointerId);
      dragging = true;
      var mouseAngle = stageAngleFromEvent(e);
      angleOffset = mouseAngle - sim['angle' + id];
      if (angleOffset < -PI) angleOffset += TWO_PI;
      if (angleOffset > PI) angleOffset -= TWO_PI;
      angleThreshold = computeAngleThreshold(id);
      epochMode = e.shiftKey;
      freezeAnimation();
    });
    handle.addEventListener('pointermove', function (e) {
      if (!dragging) return;
      var mouseAngle = stageAngleFromEvent(e);
      var angle = norm2pi(mouseAngle - angleOffset);
      if (epochMode) setEpochAngleByPlanetAngle(id, angle, sim.snapToEvents, angleThreshold);
      else setTimeByPlanetAngle(id, angle, sim.snapToEvents, angleThreshold);
    });
    function endDrag(e) {
      if (!dragging) return;
      dragging = false;
      try { handle.releasePointerCapture(e.pointerId); } catch (x) {}
      thawAnimation();
      announceConfig();
    }
    handle.addEventListener('pointerup', endDrag);
    handle.addEventListener('pointercancel', endDrag);

    handle.addEventListener('keydown', function (e) {
      var step = (e.key === 'PageUp' || e.key === 'PageDown') ? 10 * PI / 180 : 2 * PI / 180;
      var dir = 0;
      if (e.key === 'ArrowRight' || e.key === 'ArrowUp' || e.key === 'PageUp') dir = 1;
      else if (e.key === 'ArrowLeft' || e.key === 'ArrowDown' || e.key === 'PageDown') dir = -1;
      else if (e.key === 'Home') { dir = 0; } else if (e.key === 'End') { dir = 0; } else return;
      e.preventDefault();
      var angle = norm2pi(sim['angle' + id] + dir * step);
      var thr = computeAngleThreshold(id);
      if (e.shiftKey) setEpochAngleByPlanetAngle(id, angle, sim.snapToEvents, thr);
      else setTimeByPlanetAngle(id, angle, sim.snapToEvents, thr);
      announceConfig();
    });
  }

  function announceConfig() {
    if (sim.lockedOnEvent) announce(sim.eventNamesList[sim.lockedEventNumber] + '. Elongation ' + elongSpoken() + '. ' + counterString() + '.');
    else announce('Elongation ' + elongSpoken() + '. ' + counterString() + '.');
  }

  // ---- timeline (pointer drag + click events + keyboard) ----
  function wireTimeline() {
    var canvas = document.getElementById('timeline-canvas');
    var dragging = false, initY = 0, initTime = 0, timeThreshold = 0, moved = false;

    function toStageY(e) {
      var rect = canvas.getBoundingClientRect();
      return (e.clientY - rect.top) * (TL_H / rect.height);
    }
    function toStageX(e) {
      var rect = canvas.getBoundingClientRect();
      return (e.clientX - rect.left) * (TL_W / rect.width);
    }

    canvas.addEventListener('pointerdown', function (e) {
      canvas.focus();
      var sx = toStageX(e), sy = toStageY(e);
      // event-name click?
      for (var i = 0; i < timelineEventRects.length; i++) {
        var r = timelineEventRects[i];
        if (!r.locked && sx >= r.x && sx <= r.x + r.w && sy >= r.y && sy <= r.y + r.h) {
          slewToEvent(r.cycle, r.event);
          return;
        }
      }
      // else drag
      e.preventDefault();
      canvas.setPointerCapture(e.pointerId);
      dragging = true; moved = false;
      var p = timelineScaleParams();
      timeThreshold = TL_SNAP_DISTANCE / p.scale;
      initY = sy; initTime = sim._time;
      freezeAnimation();
    });
    canvas.addEventListener('pointermove', function (e) {
      if (!dragging) return;
      moved = true;
      var p = timelineScaleParams();
      var sy = toStageY(e);
      var newTime = initTime + (sy - initY) / p.scale;   // down (larger y) = future
      setTime(newTime, sim.snapToEvents, timeThreshold);
    });
    function endDrag(e) {
      if (!dragging) return;
      dragging = false;
      try { canvas.releasePointerCapture(e.pointerId); } catch (x) {}
      thawAnimation();
      if (moved) announce(counterString() + (sim.lockedOnEvent ? ('. ' + sim.eventNamesList[sim.lockedEventNumber]) : '') + '.');
    }
    canvas.addEventListener('pointerup', endDrag);
    canvas.addEventListener('pointercancel', endDrag);

    canvas.addEventListener('keydown', function (e) {
      var p = timelineScaleParams();
      if (e.key === 'ArrowDown' || e.key === 'ArrowRight') {
        e.preventDefault(); setTime(sim._time + sim.synodicPeriod / 50); announce(counterString() + '.');
      } else if (e.key === 'ArrowUp' || e.key === 'ArrowLeft') {
        e.preventDefault(); setTime(sim._time - sim.synodicPeriod / 50); announce(counterString() + '.');
      } else if (e.key === 'PageDown') {
        e.preventDefault(); gotoAdjacentEvent(1);
      } else if (e.key === 'PageUp') {
        e.preventDefault(); gotoAdjacentEvent(-1);
      }
    });
  }

  function gotoAdjacentEvent(dir) {
    if (dir > 0) {
      slewToEvent(sim.nextCycleNumber, sim.nextEventNumber);
    } else {
      // previous event before current time
      var prevCycle = Math.floor((sim._time - 1e-9 - sim.cycleOffset) / sim.synodicPeriod);
      var tr = sim._time - 1e-9 - sim.cycleOffset - prevCycle * sim.synodicPeriod;
      if (tr < 0) tr = 0;
      var i = 0; while (i < 4) { if (tr < sim.eventTimesList[i]) break; i++; }
      var prevEvent = i - 1, prevEventCycle = prevCycle;
      if (prevEvent < 0) { prevEvent = 3; prevEventCycle = prevCycle - 1; }
      slewToEvent(prevEventCycle, prevEvent);
    }
  }

  // ---- zodiac (pointer drag + keyboard pan) ----
  function wireZodiac() {
    var canvas = document.getElementById('zodiac-canvas');
    var dragging = false, initX = 0, initOffset = 0;
    function toStageX(e) {
      var rect = canvas.getBoundingClientRect();
      return (e.clientX - rect.left) * (ZW / rect.width);
    }
    canvas.addEventListener('pointerdown', function (e) {
      e.preventDefault(); canvas.focus();
      canvas.setPointerCapture(e.pointerId);
      dragging = true; initX = toStageX(e); initOffset = sim.zodiacOffset;
    });
    canvas.addEventListener('pointermove', function (e) {
      if (!dragging) return;
      setZodiacOffset(initOffset + toStageX(e) - initX); render();
    });
    function endDrag(e) {
      if (!dragging) return; dragging = false;
      try { canvas.releasePointerCapture(e.pointerId); } catch (x) {}
    }
    canvas.addEventListener('pointerup', endDrag);
    canvas.addEventListener('pointercancel', endDrag);
    canvas.addEventListener('keydown', function (e) {
      if (e.key === 'ArrowLeft') { e.preventDefault(); setZodiacOffset(sim.zodiacOffset - 20); render(); }
      else if (e.key === 'ArrowRight') { e.preventDefault(); setZodiacOffset(sim.zodiacOffset + 20); render(); }
      else return;
      announce('Zodiac strip panned. Elongation ' + elongSpoken() + '.');
    });
  }

  // ========================================================================
  //  INIT
  // ========================================================================
  function init() {
    diagCanvas = document.getElementById('diagram-canvas'); diagCtx = diagCanvas.getContext('2d');
    zCanvas = document.getElementById('zodiac-canvas'); zCtx = zCanvas.getContext('2d');
    tCanvas = document.getElementById('timeline-canvas'); tCtx = tCanvas.getContext('2d');

    starfieldImg.onload = function () { starfieldReady = true; render(); };
    starfieldImg.src = 'assets/zodiac-starfield.png';

    wireControls();
    onReset();
  }

  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', init);
  else init();

  // expose for debugging
  window.__configSim = sim;
})();
