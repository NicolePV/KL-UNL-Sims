/* =========================================================================
   Gas Retention Plot — accessible HTML5 port (KL-UNL pipeline)
   Behavior is a faithful port of the decompiled ActionScript (AS1). All
   physics constants, formulas, number formatting and educational text are
   copied verbatim from the source; only the presentation is modernized.

   Ground-truth AS files: "Gas Retention Plot.as", "GRP Object.as",
   "GRP Gas.as", "Number Functions.as", "Slider Logic Class v6.as",
   frame_1/DoAction*.as.
   ========================================================================= */
(function () {
  "use strict";

  var LN10 = 2.302585092994046;               // Math.log(10), as used in the AS
  function log10(x) { return Math.log(x) / LN10; }

  /* ------------------------------------------------------------------ *
   * Data tables (verbatim from frame_1/DoAction.as)                    *
   * ------------------------------------------------------------------ */

  // radius [km], density [g/cm^3], temperature [K], textAngle (0 = label above,
  // 180 = label below). escapeSpeed is recomputed below exactly as the AS does.
  var OBJECTS = [
    { name: "Mercury",  radius: 2439.7, density: 5.427,  temperature: 445, textAngle: 0   },
    { name: "Venus",    radius: 6051,   density: 5.204,  temperature: 325, textAngle: 180 },
    { name: "Earth",    radius: 6376,   density: 5.5153, temperature: 277, textAngle: 0   },
    { name: "Moon",     radius: 1737.1, density: 3.3464, temperature: 277, textAngle: 0   },
    { name: "Mars",     radius: 3390,   density: 3.934,  temperature: 225, textAngle: 0   },
    { name: "Jupiter",  radius: 69911,  density: 1.326,  temperature: 122, textAngle: 0   },
    { name: "Saturn",   radius: 58229,  density: 0.6873, temperature: 90,  textAngle: 0   },
    { name: "Uranus",   radius: 25363,  density: 1.318,  temperature: 63,  textAngle: 180 },
    { name: "Neptune",  radius: 24624,  density: 1.638,  temperature: 50,  textAngle: 0   },
    { name: "Pluto",    radius: 1195,   density: 2.03,   temperature: 44,  textAngle: 180 },
    { name: "Titan",    radius: 2575,   density: 1.88,   temperature: 90,  textAngle: 180 },
    { name: "Ganymede", radius: 2631,   density: 1.942,  temperature: 122, textAngle: 0   },
    { name: "Triton",   radius: 1353.4, density: 2.05,   temperature: 50,  textAngle: 0   }
  ];
  // escapeSpeed recompute (DoAction.as lines 2-9): from a uniform sphere.
  //   mass = density(kg/m^3) * (4/3)pi r(m)^3 ;  v = sqrt(2G mass / r) ,  2G = 1.3346e-10
  OBJECTS.forEach(function (o) {
    var mass = o.density * 1000 * Math.pow(o.radius * 1000, 3) * 4 * Math.PI / 3;
    o.escapeSpeed = Math.sqrt(1.3346e-10 * mass / (o.radius * 1000)) / 1000;
  });

  var CATEGORIES = {
    gasGiants:    ["Jupiter", "Saturn", "Uranus", "Neptune"],
    terrestrial:  ["Mercury", "Venus", "Earth", "Mars"],
    icy:          ["Moon", "Titan", "Triton", "Pluto", "Ganymede"]
  };

  // Gases in original array order (index 0 = xenon ... 8 = hydrogen).
  // color is the AS decimal RGB; latex is the MathJax form of the symbol.
  var GASES = [
    { name: "xenon",          symbol: "Xe",  latex: "\\text{Xe}",                 mass: 131.293,  color: 13369599 },
    { name: "carbon dioxide", symbol: "CO2", latex: "\\text{CO}_{\\text{2}}",     mass: 44.0095,  color: 16763904 },
    { name: "oxygen",         symbol: "O2",  latex: "\\text{O}_{\\text{2}}",      mass: 31.9988,  color: 10506495 },
    { name: "nitrogen",       symbol: "N2",  latex: "\\text{N}_{\\text{2}}",      mass: 28.0134,  color: 65484    },
    { name: "water",          symbol: "H2O", latex: "\\text{H}_{\\text{2}}\\text{O}", mass: 18.01528, color: 20735 },
    { name: "ammonia",        symbol: "NH3", latex: "\\text{NH}_{\\text{3}}",     mass: 17.03052, color: 16711884 },
    { name: "methane",        symbol: "CH4", latex: "\\text{CH}_{\\text{4}}",     mass: 16.04246, color: 13434624 },
    { name: "helium",         symbol: "He",  latex: "\\text{He}",                 mass: 4.002602, color: 65280    },
    { name: "hydrogen",       symbol: "H2",  latex: "\\text{H}_{\\text{2}}",      mass: 2.01588,  color: 16711680 }
  ];

  function rgb(intColor) {
    var s = (intColor >>> 0).toString(16);
    while (s.length < 6) s = "0" + s;
    return "#" + s.slice(-6);
  }

  /* ------------------------------------------------------------------ *
   * Plot coordinate system                                             *
   * ------------------------------------------------------------------ */
  var MIN_TEMP = 30, MAX_TEMP = 1000, MIN_SPEED = 0.5, MAX_SPEED = 100;
  var PLOT_W = 632, PLOT_H = 688;                 // internal plot rectangle
  var mL = 115, mT = 26, mR = 190, mB = 100;      // stage margins (room for labels)
  var STAGE_W = mL + PLOT_W + mR;                 // 937
  var STAGE_H = mT + PLOT_H + mB;                 // 814

  // Flash log-log mapping (Gas Retention Plot.as). y is negative-up in plot space.
  function getX(t) { return PLOT_W / (log10(MAX_TEMP) - log10(MIN_TEMP)) * (log10(t) - log10(MIN_TEMP)); }
  function getY(s) { return (-PLOT_H) / (log10(MAX_SPEED) - log10(MIN_SPEED)) * (log10(s) - log10(MIN_SPEED)); }
  function getTemperature(x) {
    var min = log10(MIN_TEMP);
    var scale = PLOT_W / (log10(MAX_TEMP) - min);
    return Math.pow(10, x / scale + min);
  }
  function getSpeed(y) {
    var min = log10(MIN_SPEED);
    var scale = (-PLOT_H) / (log10(MAX_SPEED) - min);
    return Math.pow(10, y / scale + min);
  }
  // internal plot coords -> canvas pixel coords
  function cX(xInternal) { return mL + xInternal; }
  function cY(yInternal) { return mT + PLOT_H + yInternal; }

  var TEMP_MAJOR  = [30, 50, 100, 200, 500, 1000];
  var TEMP_MINOR  = [40, 60, 70, 80, 90, 300, 400, 500, 600, 700, 800, 900];
  var SPEED_MAJOR = [0.5, 1, 2, 3, 4, 6, 10, 20, 40, 60, 100];
  var SPEED_MINOR = [0.6, 0.7, 0.8, 0.9, 5, 7, 8, 9, 30, 50, 70, 80, 90];
  var MAJOR_TICK = 6, MINOR_TICK = 3;

  /* ------------------------------------------------------------------ *
   * Number formatting (verbatim ports of Number Functions.as +          *
   * Slider Logic Class v6.as)                                           *
   * ------------------------------------------------------------------ */

  // Slider Logic Class v6 -> p.toFixed  (and Number.prototype.toFixed)
  function numToFixed(x, f) {
    if (f > 20 || f < 0 || isNaN(x) || !isFinite(x)) return "...";
    var s = "";
    if (x < 0) { s = "-"; x = -x; }
    var m = "";
    if (x < 1e21) {
      var n = Math.round(x * Math.pow(10, f));
      m = (n === 0) ? "0" : n.toString();
      if (f > 0) {
        var k = m.length;
        if (k <= f) {
          var z = "";
          for (var i = 0; i < f + 1 - k; i++) z += "0";
          m = z + m; k = f + 1;
        }
        var a = m.substr(0, k - f);
        var b = m.substr(k - f);
        m = a + "." + b;
      }
    } else {
      m = x.toString();
    }
    return s + m;
  }

  // Number.prototype.toScientific(digits, useTags) -> LaTeX significand x 10^m
  function toScientificLatex(x, digits) {
    if (!isFinite(x) || isNaN(x)) return "";
    var s, m;
    if (x === 0) { s = (0).toFixed(digits - 1); m = 0; }
    else {
      var sign = x < 0 ? "-" : "";
      var ax = Math.abs(x);
      m = Math.floor(Math.log(ax) / LN10);
      s = (ax / Math.pow(10, m)).toFixed(digits - 1);
      if (Number(s) >= 10) { s = (1).toFixed(digits - 1); m += 1; }
      s = sign + s;
    }
    // Rendered as page-font text so it matches surrounding prose (× is a literal
    // character inside \text; the exponent stays a real superscript).
    return "\\text{" + s + "×10}^{\\text{" + m + "}}";
  }

  // frame_1/DoAction_3.as -> formatNumber
  function formatNumber(num, digits) {
    var L = Math.floor(Math.log(num) / LN10) - (digits - 1);
    if (L >= 0) {
      var M = Math.pow(10, L);
      return String(M * Math.round(num / M));
    }
    return numToFixed(num, -L);
  }

  /* ------------------------------------------------------------------ *
   * Significant-digit logarithmic slider (port of Slider Logic Class v6 *
   * significant-digits mode). Rebuilt as an accessible native control.  *
   * ------------------------------------------------------------------ */
  function SigSlider(opts) {
    this.digs = opts.digs;
    this.minValue = opts.minValue;
    this.maxValue = opts.maxValue;
    this.quantity = opts.quantity;         // spoken quantity name
    this.spokenUnit = opts.spokenUnit;     // spoken unit
    this.onUserChange = opts.onUserChange; // called on every user input (live)
    this.onCommit = opts.onCommit;         // called on commit only (announce)
    // Optional: fn() -> extra text appended to aria-valuetext (e.g. the custom
    // object's current escape speed, which has no slider of its own so it would
    // otherwise never be spoken while adjusting temperature/radius/density).
    this.extra = opts.extra;
    this.lowerSig = Math.pow(10, this.digs - 1);
    this.upperSig = Math.pow(10, this.digs);
    this.ticksPerMag = 9 * this.lowerSig;
    this.grid = this._buildGrid();
    this.index = 0;

    this.range = opts.range;
    this.field = opts.field;
    this.range.min = 0;
    this.range.max = this.grid.length - 1;
    this.range.step = 1;

    var self = this;
    this.range.addEventListener("input", function () {
      self.index = clampInt(parseInt(self.range.value, 10) || 0, 0, self.grid.length - 1);
      // Run the change handler BEFORE syncing the UI: for radius/density this
      // recomputes the shared escape speed, so the aria-valuetext's "extra" text
      // (below) reflects the fresh value instead of lagging by one step.
      if (self.onUserChange) self.onUserChange(self.value());
      self._syncUI();
    });
    // 'change' fires on release (drag) or per key (keyboard) -> announce on commit only
    this.range.addEventListener("change", function () { if (self.onCommit) self.onCommit(); });
    this.field.addEventListener("change", function () { self._commitField(); });
    this.field.addEventListener("keydown", function (e) {
      if (e.key === "Enter") { e.preventDefault(); self._commitField(); }
    });
  }
  SigSlider.prototype._valObjFromValue = function (x) {
    if (x < this.minValue) x = this.minValue;
    else if (x > this.maxValue) x = this.maxValue;
    var mag = Math.floor(log10(x));
    var sig = Math.round(x * this.lowerSig / Math.pow(10, mag));
    if (sig >= this.upperSig) { sig = this.lowerSig; mag++; }
    return { value: sig / this.lowerSig * Math.pow(10, mag), mag: mag, sig: sig };
  };
  SigSlider.prototype._incr = function (v) {  // increment by exactly one tick
    var newSig = v.sig + 1, newMag = v.mag;
    if (newSig >= this.upperSig) { newSig -= this.ticksPerMag; newMag++; }
    return { value: newSig / this.lowerSig * Math.pow(10, newMag), mag: newMag, sig: newSig };
  };
  SigSlider.prototype._buildGrid = function () {
    var grid = [];
    var cur = this._valObjFromValue(this.minValue);
    grid.push(cur);
    var guard = 0;
    while (guard++ < 100000) {
      var next = this._incr(cur);
      if (next.value > this.maxValue + 1e-9) break;
      grid.push(next);
      cur = next;
    }
    return grid;
  };
  SigSlider.prototype.value = function () { return this.grid[this.index].value; };
  SigSlider.prototype.displayString = function () {
    var v = this.grid[this.index];
    var f = this.digs - v.mag - 1;
    if (f > 0) return numToFixed(v.value, f);
    // f <= 0 means mag >= digs-1, so the value is mathematically an integer;
    // round away IEEE float noise (AS Number.toString does the same at ~15 sig figs).
    return String(Math.round(v.value));
  };
  SigSlider.prototype._syncUI = function () {
    this.range.value = this.index;
    var disp = this.displayString();
    if (document.activeElement !== this.field) this.field.value = disp;
    this.range.setAttribute("aria-valuenow", String(this.index));
    this.range.setAttribute("aria-valuetext",
      this.quantity + " " + disp + " " + this.spokenUnit + (this.extra ? this.extra() : ""));
  };
  // Set the value programmatically (no change handler) — mirrors setValue snapping.
  SigSlider.prototype.setValueFromNumber = function (x) {
    if (isNaN(x) || !isFinite(x)) return;
    var target = this._valObjFromValue(x).value;
    // nearest grid index to the snapped value
    var best = 0, bestD = Infinity;
    for (var i = 0; i < this.grid.length; i++) {
      var d = Math.abs(this.grid[i].value - target);
      if (d < bestD) { bestD = d; best = i; }
    }
    this.index = best;
    this._syncUI();
  };
  SigSlider.prototype._commitField = function () {
    var x = parseFloat(this.field.value);
    if (isNaN(x) || !isFinite(x)) { this._syncUI(); return; }
    this.setValueFromNumber(x);
    if (this.onUserChange) this.onUserChange(this.value());
    this._syncUI();   // re-sync so aria-valuetext's extra text reflects onUserChange's effects
    if (this.onCommit) this.onCommit();
  };

  function clampInt(v, lo, hi) { return v < lo ? lo : v > hi ? hi : v; }

  /* ------------------------------------------------------------------ *
   * State                                                              *
   * ------------------------------------------------------------------ */
  var state = {
    temperature: 70,      // custom object dot (continuous), K
    escapeSpeed: 1.0,     // custom object dot (continuous), km/s
    snappedName: null,    // name of planet the dot is snapped to, or null
    gasVisible: GASES.map(function () { return false; }),
    showGasGiants: false,
    showTerrestrial: false,
    showIcy: false
  };

  // DOM handles (assigned on init)
  var canvas, ctx, dpr, plotOverlay, dotProxy, srStatus, plotDesc;
  var temperatureSlider, radiusSlider, densitySlider;
  var massInfoEl, distanceInfoEl;
  var massLive, distLive;   // flicker-free LiveReadout wrappers

  /* ------------------------------------------------------------------ *
   * MathJax helpers (typeset dynamic math; keep menu enabled)          *
   * ------------------------------------------------------------------ */
  function mathReady(cb) {
    if (window.MathJax && MathJax.typesetPromise) { cb(); return; }
    setTimeout(function () { mathReady(cb); }, 40);
  }
  // Flicker-free live MathJax readout: two buffers, one shown and one hidden.
  // New content is typeset INTO the hidden buffer (display:none, so the raw
  // LaTeX is never painted), then the buffers swap. Because each buffer is
  // typeset in place (never copied), MathJax's context menu stays attached.
  // Rapid updates coalesce to the latest value.
  function LiveReadout(el) {
    this.a = document.createElement("span");
    this.b = document.createElement("span");
    this.b.style.display = "none";
    this.b.setAttribute("aria-hidden", "true");
    el.textContent = "";
    el.appendChild(this.a);
    el.appendChild(this.b);
    this.shown = this.a;
    this.hidden = this.b;
    this.pending = null;
    this.busy = false;
  }
  LiveReadout.prototype.set = function (html) {
    this.pending = html;
    if (!this.busy) this._flush();
  };
  LiveReadout.prototype._flush = function () {
    if (this.pending === null) return;
    var html = this.pending;
    this.pending = null;
    var self = this;
    if (window.MathJax && MathJax.typesetPromise) {
      this.busy = true;
      this.hidden.innerHTML = html;              // hidden -> raw never visible
      MathJax.typesetPromise([this.hidden]).then(function () {
        self.hidden.style.display = "";
        self.hidden.removeAttribute("aria-hidden");
        self.shown.style.display = "none";
        self.shown.setAttribute("aria-hidden", "true");
        var t = self.shown; self.shown = self.hidden; self.hidden = t;
        self.busy = false;
        if (self.pending !== null) self._flush();
      }).catch(function () { self.busy = false; });
    } else {
      // MathJax not ready yet (initial load): show it now; the initial full-page
      // typeset in init() renders it in place.
      this.shown.innerHTML = html;
    }
  };

  /* ------------------------------------------------------------------ *
   * Behavior (ports of frame_1/DoAction_3.as functions)               *
   * ------------------------------------------------------------------ */
  function desnap() { state.snappedName = null; }

  function onTemperatureChanged() {
    desnap();
    state.temperature = temperatureSlider.value();
    updateDistanceInfo();
    render();
  }
  function onDensityChanged() {
    desnap();
    var r = radiusSlider.value(), d = densitySlider.value();
    var esc = r * 0.0007477 * Math.sqrt(d);
    if (esc < MIN_SPEED) {
      radiusSlider.setValueFromNumber(MIN_SPEED / (0.0007477 * Math.sqrt(d)));
      state.escapeSpeed = MIN_SPEED;
    } else if (esc > MAX_SPEED) {
      radiusSlider.setValueFromNumber(MAX_SPEED / (0.0007477 * Math.sqrt(d)));
      state.escapeSpeed = MAX_SPEED;
    } else {
      state.escapeSpeed = esc;
    }
    updateMassInfo();
    render();
  }
  function onRadiusChanged() {
    desnap();
    var r = radiusSlider.value(), d = densitySlider.value();
    var esc = r * 0.0007477 * Math.sqrt(d);
    if (esc < MIN_SPEED) {
      densitySlider.setValueFromNumber(Math.pow(MIN_SPEED / (r * 0.0007477), 2));
      state.escapeSpeed = MIN_SPEED;
    } else if (esc > MAX_SPEED) {
      densitySlider.setValueFromNumber(Math.pow(MAX_SPEED / (r * 0.0007477), 2));
      state.escapeSpeed = MAX_SPEED;
    } else {
      state.escapeSpeed = esc;
    }
    updateMassInfo();
    render();
  }

  // userObject.onObjectMoved (DoAction_3.as). snappedName: string or null.
  function onObjectMoved(snappedName) {
    temperatureSlider.setValueFromNumber(state.temperature);
    updateDistanceInfo();
    desnap();
    if (typeof snappedName === "string") {
      var planet = findObject(snappedName);
      if (planet) {
        radiusSlider.setValueFromNumber(planet.radius);
        densitySlider.setValueFromNumber(planet.density);
        state.snappedName = snappedName;
      }
    } else {
      var d = densitySlider.value();
      var r = state.escapeSpeed / (0.0007477 * Math.sqrt(d));
      if (r > radiusSlider.maxValue) {
        radiusSlider.setValueFromNumber(radiusSlider.maxValue);
        densitySlider.setValueFromNumber(Math.pow(state.escapeSpeed / (0.0007477 * radiusSlider.maxValue), 2));
      } else if (r < radiusSlider.minValue) {
        radiusSlider.setValueFromNumber(radiusSlider.minValue);
        densitySlider.setValueFromNumber(Math.pow(state.escapeSpeed / (0.0007477 * radiusSlider.minValue), 2));
      } else {
        radiusSlider.setValueFromNumber(r);
      }
    }
    updateMassInfo();
    render();
  }

  function findObject(name) {
    for (var i = 0; i < OBJECTS.length; i++) if (OBJECTS[i].name === name) return OBJECTS[i];
    return null;
  }

  // updateMassInfo (DoAction_3.as). mass in kg from radius[km] & density[g/cm^3].
  function updateMassInfo() {
    var radius = 1000 * radiusSlider.value();     // metres
    var mass = densitySlider.value() * 1.3333333333333333 * Math.PI *
               radius * radius * radius * 100 * 100 * 100 / 1000;
    var sci = toScientificLatex(mass, 2);
    var esc = numToFixed(state.escapeSpeed, 1);
    massLive.set(
      "an object with this radius and density would have<br>" +
      "a mass of \\(" + sci + "\\ \\text{kg}\\) and an escape velocity of " +
      "\\(\\text{" + esc + "}\\ \\text{km/s}\\)");
  }

  // updateDistanceInfo (DoAction_3.as). distance in AU from temperature.
  function updateDistanceInfo() {
    var distanceInAU = Math.pow(278.8 / state.temperature, 2);
    distLive.set(
      "this temperature would be associated with an object about " +
      "\\(\\text{" + formatNumber(distanceInAU, 2) + "}\\ \\text{AU}\\) from the sun");
  }

  /* ------------------------------------------------------------------ *
   * Gas retention band geometry (port of GRP Gas.update)              *
   * ------------------------------------------------------------------ */
  function gasBand(mass) {
    var k = 1.3806503e-23;
    var m = mass * 1.66053886e-27;
    var v1 = Math.sqrt(3 * k * MIN_TEMP / m) / 1000;    // Vavg at min temp
    var v2 = Math.sqrt(3 * k * MAX_TEMP / m) / 1000;    // Vavg at max temp
    return {
      y1: getY(6 * v1),   // 6x Vavg line, left
      y2: getY(6 * v2),   // 6x Vavg line, right
      y3: getY(10 * v2),  // 10x Vavg line, right (dashed-line & label anchor)
      y4: getY(10 * v1)   // 10x Vavg line, left
    };
  }

  /* ------------------------------------------------------------------ *
   * Rendering                                                          *
   * ------------------------------------------------------------------ */
  function objectVisible(o) {
    if (CATEGORIES.gasGiants.indexOf(o.name) !== -1) return state.showGasGiants;
    if (CATEGORIES.terrestrial.indexOf(o.name) !== -1) return state.showTerrestrial;
    if (CATEGORIES.icy.indexOf(o.name) !== -1) return state.showIcy;
    return false;
  }

  function render() {
    drawCanvas();
    positionDot();
    updateGasLabels();
    updatePlotDescription();
    refreshSliderExtras();
  }

  // Escape speed can change from edits to EITHER the radius or density slider
  // (or from dragging/snapping the dot). Re-sync all three sliders' own
  // aria-valuetext here, in the single redraw-from-state function, so a slider
  // the user hasn't touched never reports a stale escape speed.
  function refreshSliderExtras() {
    if (temperatureSlider) temperatureSlider._syncUI();
    if (radiusSlider) radiusSlider._syncUI();
    if (densitySlider) densitySlider._syncUI();
  }

  function drawCanvas() {
    ctx.setTransform(dpr, 0, 0, dpr, 0, 0);
    ctx.clearRect(0, 0, STAGE_W, STAGE_H);

    var x0 = mL, y0 = mT, x1 = mL + PLOT_W, y1 = mT + PLOT_H;

    // Plot background (white)
    ctx.fillStyle = "#ffffff";
    ctx.fillRect(x0, y0, PLOT_W, PLOT_H);

    // --- Gas shading + dashed lines, clipped to the plot rectangle ---
    ctx.save();
    ctx.beginPath();
    ctx.rect(x0, y0, PLOT_W, PLOT_H);
    ctx.clip();
    GASES.forEach(function (g, i) {
      if (!state.gasVisible[i]) return;
      drawGas(g);
    });
    ctx.restore();

    // --- Objects (planets first, then the red custom dot on top) ---
    OBJECTS.forEach(function (o) {
      if (!objectVisible(o)) return;
      drawPlanet(o);
    });
    drawUserDot();

    // --- Border ---
    ctx.lineWidth = 1;
    ctx.strokeStyle = "#000000";
    ctx.strokeRect(x0 + 0.5, y0 + 0.5, PLOT_W - 1, PLOT_H - 1);

    // --- Tick marks ---
    drawTicks();
  }

  function drawGas(g) {
    var b = gasBand(g.mass);
    var w = PLOT_W, h = PLOT_H;
    var color = rgb(g.color);
    // Uniform fills (no gradient): solid region above the 10x line, and a
    // lighter but still uniform band in the 6x-10x transition zone. This keeps
    // the retention region evenly coloured (no washed-out/transparent left edge).
    var aSolid = 0.20, aBand = 0.12;

    // Region above the 10x line (fully retained)
    ctx.fillStyle = color;
    ctx.globalAlpha = aSolid;
    ctx.beginPath();
    if (b.y3 < -h) {
      ctx.moveTo(cX(0), cY(b.y4));
      ctx.lineTo(cX(w), cY(b.y3));
      ctx.lineTo(cX(0), cY(b.y3));
      ctx.closePath();
    } else {
      ctx.moveTo(cX(0), cY(b.y4));
      ctx.lineTo(cX(w), cY(b.y3));
      ctx.lineTo(cX(w), cY(-h));
      ctx.lineTo(cX(0), cY(-h));
      ctx.closePath();
    }
    ctx.fill();

    // Transition band between the 6x and 10x lines (uniform, lighter)
    ctx.globalAlpha = aBand;
    ctx.beginPath();
    ctx.moveTo(cX(0), cY(b.y1));
    ctx.lineTo(cX(w), cY(b.y2));
    ctx.lineTo(cX(w), cY(b.y3));
    ctx.lineTo(cX(0), cY(b.y4));
    ctx.closePath();
    ctx.fill();

    // Dashed line at 10x Vavg (grey), matching drawDashedLine(dash 4, gap 8)
    ctx.globalAlpha = 1;
    ctx.strokeStyle = "#909090";
    ctx.lineWidth = 2;
    drawDashedLine(cX(0), cY(b.y4), cX(w), cY(b.y3), 4, 8);
  }

  // GRP Gas.drawDashedLine
  function drawDashedLine(x0, y0, x1, y1, dashLength, gapLength) {
    var dx = x1 - x0, dy = y1 - y0;
    var length = Math.sqrt(dx * dx + dy * dy);
    var n = Math.round((length - dashLength) / (dashLength + gapLength));
    var f = dashLength / (dashLength + gapLength);
    var mx = dx / (n + f), my = dy / (n + f);
    var lx = f * mx, ly = f * my;
    ctx.beginPath();
    for (var i = 0; i <= n; i++) {
      var x = x0 + i * mx, y = y0 + i * my;
      ctx.moveTo(x, y);
      ctx.lineTo(x + lx, y + ly);
    }
    ctx.stroke();
  }

  function drawPlanet(o) {
    var px = cX(getX(o.temperature));
    var py = cY(getY(o.escapeSpeed));
    // grey dot, radius 3, thin dark outline
    ctx.globalAlpha = 1;
    ctx.beginPath();
    ctx.arc(px, py, 3, 0, 2 * Math.PI);
    ctx.fillStyle = "#909090";
    ctx.fill();
    ctx.lineWidth = 1;
    ctx.strokeStyle = "#000000";
    ctx.stroke();

    // Non-colour cue when snapped: a ring around the dot
    var snapped = (state.snappedName === o.name);
    if (snapped) {
      ctx.beginPath();
      ctx.arc(px, py, 7, 0, 2 * Math.PI);
      ctx.lineWidth = 2;
      ctx.strokeStyle = "#d00000";
      ctx.stroke();
    }

    // Name label (canvas text; contains no math). Red when snapped.
    ctx.fillStyle = snapped ? "#d00000" : "#404040";
    ctx.font = (snapped ? "bold " : "") + "15px Verdana, Geneva, sans-serif";
    ctx.textAlign = "center";
    if (o.textAngle === 180) {
      ctx.textBaseline = "top";
      ctx.fillText(o.name, px, py + 8);
    } else {
      ctx.textBaseline = "bottom";
      ctx.fillText(o.name, px, py - 8);
    }
  }

  function drawUserDot() {
    var px = cX(getX(state.temperature));
    var py = cY(getY(state.escapeSpeed));
    ctx.globalAlpha = 1;
    ctx.beginPath();
    ctx.arc(px, py, 5, 0, 2 * Math.PI);
    ctx.fillStyle = "#ff0000";
    ctx.fill();
    ctx.lineWidth = 1;
    ctx.strokeStyle = "#a00000";
    ctx.stroke();
  }

  function drawTicks() {
    ctx.globalAlpha = 1;
    ctx.strokeStyle = "#000000";
    ctx.lineWidth = 1;
    ctx.beginPath();
    // speed ticks (left of axis)
    SPEED_MAJOR.forEach(function (s) { tickLine(cX(0) - MAJOR_TICK, cY(getY(s)), cX(0), cY(getY(s))); });
    SPEED_MINOR.forEach(function (s) { tickLine(cX(0) - MINOR_TICK, cY(getY(s)), cX(0), cY(getY(s))); });
    // temperature ticks (below axis)
    TEMP_MAJOR.forEach(function (t) { tickLine(cX(getX(t)), cY(0), cX(getX(t)), cY(0) + MAJOR_TICK); });
    TEMP_MINOR.forEach(function (t) { tickLine(cX(getX(t)), cY(0), cX(getX(t)), cY(0) + MINOR_TICK); });
    ctx.stroke();
  }
  function tickLine(x0, y0, x1, y1) { ctx.moveTo(x0, y0); ctx.lineTo(x1, y1); }

  /* ------------------------------------------------------------------ *
   * Overlay positioning (math labels + dot proxy)                      *
   * ------------------------------------------------------------------ */
  function pctLeft(sx) { return (sx / STAGE_W * 100) + "%"; }
  function pctTop(sy) { return (sy / STAGE_H * 100) + "%"; }

  function positionDot() {
    var sx = cX(getX(state.temperature));
    var sy = cY(getY(state.escapeSpeed));
    dotProxy.style.left = pctLeft(sx);
    dotProxy.style.top = pctTop(sy);
    // Keep the accessible name current so focusing the dot reads its position.
    dotProxy.setAttribute("aria-label",
      "Custom object marker at temperature " + Math.round(state.temperature) +
      " kelvin, escape speed " + numToFixed(state.escapeSpeed, 1) +
      " kilometers per second" +
      (state.snappedName ? ", snapped to " + state.snappedName : "") +
      ". Left and Right arrows change temperature; Up and Down arrows change escape speed; " +
      "Page Up and Page Down for larger speed steps; Home and End for minimum and maximum temperature.");
  }

  function updateGasLabels() {
    // Show visible gas-line labels and de-overlap them vertically. Gases with
    // similar molecular mass have nearly-coincident 10x lines, so their labels
    // would otherwise stack on top of each other.
    var visible = [];
    GASES.forEach(function (g, i) {
      var el = document.getElementById("gaslabel-" + i);
      if (!el) return;
      if (state.gasVisible[i]) {
        el.style.display = "block";
        visible.push({ el: el, top: cY(gasBand(g.mass).y3) / STAGE_H * 100 });
      } else {
        el.style.display = "none";
      }
    });
    visible.sort(function (a, b) { return a.top - b.top; });
    var minGapPct = 3.6;   // ~ one label line-height as a share of the plot height
    for (var k = 1; k < visible.length; k++) {
      if (visible[k].top < visible[k - 1].top + minGapPct) {
        visible[k].top = visible[k - 1].top + minGapPct;
      }
    }
    visible.forEach(function (v) { v.el.style.top = v.top + "%"; });
  }

  function updatePlotDescription() {
    var parts = [];
    parts.push("Custom object dot at temperature " + Math.round(state.temperature) +
      " kelvin and escape speed " + numToFixed(state.escapeSpeed, 1) +
      " kilometers per second" + (state.snappedName ? ", snapped to " + state.snappedName + "." : "."));
    var shownGases = GASES.filter(function (g, i) { return state.gasVisible[i]; })
                          .map(function (g) { return g.name; });
    parts.push(shownGases.length
      ? "Gases shown: " + shownGases.join(", ") + "."
      : "No gases selected.");
    var shownObjs = OBJECTS.filter(objectVisible).map(function (o) {
      return o.name + " (" + Math.round(o.temperature) + " kelvin, " +
             numToFixed(o.escapeSpeed, 1) + " kilometers per second)";
    });
    parts.push(shownObjs.length
      ? "Solar system bodies shown: " + shownObjs.join("; ") + "."
      : "No solar system bodies selected.");
    plotDesc.textContent = parts.join(" ");
  }

  function announceDot(fromReset) {
    var msg = (fromReset ? "Reset. " : "") +
      "Custom object: temperature " + Math.round(state.temperature) + " kelvin, escape speed " +
      numToFixed(state.escapeSpeed, 1) + " kilometers per second" +
      (state.snappedName ? ", snapped to " + state.snappedName + "." : ".");
    srStatus.textContent = msg;
  }

  /* ------------------------------------------------------------------ *
   * Pointer drag on the canvas (port of userObject.onMouseMoveFunc)    *
   * ------------------------------------------------------------------ */
  var dragging = false;

  function stageFromEvent(e) {
    var rect = canvas.getBoundingClientRect();
    var sx = (e.clientX - rect.left) * (STAGE_W / rect.width);
    var sy = (e.clientY - rect.top) * (STAGE_H / rect.height);
    return { mx: sx - mL, my: sy - (mT + PLOT_H) };   // plot-internal coords
  }

  var dragOffX = 0, dragOffY = 0;

  function onPointerDown(e) {
    var p = stageFromEvent(e);
    var dotX = getX(state.temperature), dotY = getY(state.escapeSpeed);
    var dx = p.mx - dotX, dy = p.my - dotY;
    if (dx * dx + dy * dy <= 12 * 12) {     // within grab radius of the dot
      dragging = true;
      dragOffX = p.mx - dotX;
      dragOffY = p.my - dotY;
      dotProxy.focus();                     // click-to-focus (keyboard parity)
      try { canvas.setPointerCapture(e.pointerId); } catch (err) {}
      e.preventDefault();
    }
  }
  function onPointerMove(e) {
    if (!dragging) return;
    var p = stageFromEvent(e);
    moveDotTo(p.mx - dragOffX, p.my - dragOffY);
    e.preventDefault();
  }
  function onPointerUp(e) {
    if (!dragging) return;
    dragging = false;
    try { canvas.releasePointerCapture(e.pointerId); } catch (err) {}
    announceDot(false);
  }

  // Core of userObject.onMouseMoveFunc: clamp, snap to nearby visible planet,
  // set temperature/escapeSpeed, then run onObjectMoved.
  function moveDotTo(nx, ny) {
    if (nx < 0) nx = 0; else if (nx > PLOT_W) nx = PLOT_W;
    if (ny > 0) ny = 0; else if (ny < -PLOT_H) ny = -PLOT_H;

    var snapDistance = 8, sD2 = snapDistance * snapDistance;
    var snappedName = null;
    for (var i = 0; i < OBJECTS.length; i++) {
      var o = OBJECTS[i];
      if (!objectVisible(o)) continue;
      var ox = getX(o.temperature), oy = getY(o.escapeSpeed);
      var dx = nx - ox, dy = ny - oy;
      if (dx * dx + dy * dy < sD2) { snappedName = o.name; nx = ox; ny = oy; break; }
    }
    state.temperature = getTemperature(nx);
    state.escapeSpeed = getSpeed(ny);
    onObjectMoved(snappedName);
  }

  /* ------------------------------------------------------------------ *
   * Keyboard operation of the dot (Tab to focus, arrows to move)       *
   * ------------------------------------------------------------------ */
  function onDotKey(e) {
    var stepSmall = 4, stepLarge = 24;   // stage pixels
    var nx = getX(state.temperature), ny = getY(state.escapeSpeed);
    var handled = true;
    switch (e.key) {
      case "ArrowLeft":  nx -= stepSmall; break;
      case "ArrowRight": nx += stepSmall; break;
      case "ArrowUp":    ny -= stepSmall; break;   // up = higher speed (negative-up)
      case "ArrowDown":  ny += stepSmall; break;
      case "PageUp":     ny -= stepLarge; break;
      case "PageDown":   ny += stepLarge; break;
      case "Home":       nx = 0; break;            // min temperature
      case "End":        nx = PLOT_W; break;       // max temperature
      default: handled = false;
    }
    if (!handled) return;
    e.preventDefault();
    moveDotTo(nx, ny);
    announceDot(false);
  }

  /* ------------------------------------------------------------------ *
   * Reset (port of onResetClicked). Also the initial state.            *
   * ------------------------------------------------------------------ */
  function onReset(fromButton) {
    // Uncheck all gases + categories (setValue(false) fired their handlers in AS)
    state.gasVisible = GASES.map(function () { return false; });
    for (var i = 0; i < GASES.length; i++) {
      var cb = document.getElementById("gas-chk-" + i);
      if (cb) cb.checked = false;
    }
    state.showGasGiants = state.showTerrestrial = state.showIcy = false;
    document.getElementById("chk-gasgiants").checked = false;
    document.getElementById("chk-terrestrial").checked = false;
    document.getElementById("chk-icy").checked = false;

    radiusSlider.setValueFromNumber(600);
    densitySlider.setValueFromNumber(5);
    temperatureSlider.setValueFromNumber(70);
    desnap();

    // Precise escape speed from mass (onResetClicked)
    var mass = densitySlider.value() * 1000 *
               Math.pow(radiusSlider.value() * 1000, 3) * 4 * Math.PI / 3;
    state.escapeSpeed = Math.sqrt(1.3346e-10 * mass / (radiusSlider.value() * 1000)) / 1000;
    state.temperature = temperatureSlider.value();

    updateMassInfo();
    updateDistanceInfo();
    render();
    if (fromButton) announceDot(true);
  }

  /* ------------------------------------------------------------------ *
   * DOM construction                                                   *
   * ------------------------------------------------------------------ */
  function buildGasTable() {
    var tbody = document.getElementById("gas-tbody");
    // Display ascending by mass (hydrogen first) -> reverse of the AS array.
    var order = GASES.map(function (g, i) { return i; }).reverse();
    order.forEach(function (i) {
      var g = GASES[i];
      var tr = document.createElement("tr");

      // The chemical symbol is a visual convenience for sighted users; the gas
      // NAME alone is already a complete, unambiguous accessible label for the
      // row, so the symbol is hidden from screen readers (aria-hidden) rather
      // than spoken — it stays visible and MathJax-typeset (right-click still
      // works) for everyone else.
      var tdName = document.createElement("td");
      tdName.className = "gas-td-name";
      tdName.innerHTML = g.name + " <span aria-hidden=\"true\">(\\(" + g.latex + "\\))</span>";

      // "u" (atomic mass unit) is spoken as a bare letter, which can blend into
      // the next thing read (e.g. "u" + "helium" -> "uhelium"). Keep the visual
      // MathJax rendering ("16 u") for sighted/right-click users but hide it from
      // screen readers, and give them a full, punctuated spoken equivalent
      // instead ("16 atomic mass units.") whose trailing period guarantees a
      // clean pause before whatever is read next.
      var massDisplay = numToFixed(g.mass, 0);
      var tdMass = document.createElement("td");
      tdMass.className = "gas-td-mass";
      tdMass.innerHTML =
        "<span aria-hidden=\"true\">\\(\\text{" + massDisplay + "}\\ \\text{u}\\)</span>" +
        "<span class=\"sr-only\">" + massDisplay + " atomic mass units.</span>";

      var tdShow = document.createElement("td");
      tdShow.className = "gas-td-show";
      var cb = document.createElement("input");
      cb.type = "checkbox";
      cb.id = "gas-chk-" + i;
      cb.setAttribute("aria-label", "show " + g.name + " (" + g.symbol + ") in plot");
      cb.addEventListener("change", function () {
        state.gasVisible[i] = cb.checked;
        render();
        srStatus.textContent = g.name + (cb.checked ? " shown." : " hidden.");
      });
      tdShow.appendChild(cb);

      tr.appendChild(tdName);
      tr.appendChild(tdMass);
      tr.appendChild(tdShow);
      tbody.appendChild(tr);
    });
  }

  function buildTickLabels() {
    var layer = document.getElementById("tick-layer");
    SPEED_MAJOR.forEach(function (s) {
      var el = document.createElement("div");
      el.className = "tick-label tick-label--y";
      el.innerHTML = "\\(\\text{" + s + "}\\)";
      el.style.left = pctLeft(cX(0) - MAJOR_TICK - 5);
      el.style.top = pctTop(cY(getY(s)));
      layer.appendChild(el);
    });
    TEMP_MAJOR.forEach(function (t) {
      var el = document.createElement("div");
      el.className = "tick-label tick-label--x";
      el.innerHTML = "\\(\\text{" + t + "}\\)";
      el.style.left = pctLeft(cX(getX(t)));
      el.style.top = pctTop(cY(0) + MAJOR_TICK + 6);
      layer.appendChild(el);
    });
  }

  // Position the two axis titles within the margins (not pinned to the edges),
  // so they clear the panel edge, the tick numbers, and the axis line.
  function positionAxisTitles() {
    var yt = document.getElementById("axis-title-y");
    yt.style.left = pctLeft(28);
    yt.style.top = pctTop(mT + PLOT_H / 2);
    yt.style.transform = "translate(-50%, -50%) rotate(-90deg)";
    var xt = document.getElementById("axis-title-x");
    xt.style.left = pctLeft(mL + PLOT_W / 2);
    xt.style.top = pctTop(cY(0) + 56);
    xt.style.transform = "translate(-50%, 0)";
  }

  function buildGasLabels() {
    var layer = document.getElementById("gaslabel-layer");
    GASES.forEach(function (g, i) {
      var b = gasBand(g.mass);
      var el = document.createElement("div");
      el.className = "gas-line-label";
      el.id = "gaslabel-" + i;
      el.innerHTML = "\\(" + g.latex + "\\text{, 10×V}_{\\text{avg}}\\)";
      el.style.left = pctLeft(cX(PLOT_W) + 5);
      el.style.top = pctTop(cY(b.y3));
      el.style.display = "none";
      layer.appendChild(el);
    });
  }

  /* ------------------------------------------------------------------ *
   * Init                                                               *
   * ------------------------------------------------------------------ */
  function init() {
    canvas = document.getElementById("plot-canvas");
    ctx = canvas.getContext("2d");
    dpr = window.devicePixelRatio || 1;
    canvas.width = Math.round(STAGE_W * dpr);
    canvas.height = Math.round(STAGE_H * dpr);

    plotOverlay = document.getElementById("plot-overlay");
    dotProxy = document.getElementById("dot-proxy");
    srStatus = document.getElementById("sr-status");
    plotDesc = document.getElementById("plot-description");
    massInfoEl = document.getElementById("mass-info");
    distanceInfoEl = document.getElementById("distance-info");
    massLive = new LiveReadout(massInfoEl);
    distLive = new LiveReadout(distanceInfoEl);

    // Sliders (SliderLogicClassV6 significant-digits + init params from the
    // Standard Slider v6 CLIPACTIONRECORDs).
    // Escape speed has no slider of its own (it's derived from radius & density),
    // so without this it would never be spoken while adjusting these controls —
    // append it to all three so every control also reports the custom object's
    // full current location (temperature + escape speed), not just its own axis.
    var speedExtra = function () {
      return ", escape speed " + numToFixed(state.escapeSpeed, 1) + " kilometers per second";
    };
    temperatureSlider = new SigSlider({
      digs: 2, minValue: 30, maxValue: 1000, quantity: "temperature", spokenUnit: "kelvin",
      range: document.getElementById("temperature-range"),
      field: document.getElementById("temperature-field"),
      onUserChange: onTemperatureChanged,
      onCommit: function () { announceDot(false); },
      extra: speedExtra
    });
    radiusSlider = new SigSlider({
      digs: 3, minValue: 300, maxValue: 150000, quantity: "radius", spokenUnit: "kilometers",
      range: document.getElementById("radius-range"),
      field: document.getElementById("radius-field"),
      onUserChange: onRadiusChanged,
      onCommit: function () { announceDot(false); },
      extra: speedExtra
    });
    densitySlider = new SigSlider({
      digs: 2, minValue: 0.3, maxValue: 7, quantity: "density", spokenUnit: "grams per cubic centimeter",
      range: document.getElementById("density-range"),
      field: document.getElementById("density-field"),
      onUserChange: onDensityChanged,
      onCommit: function () { announceDot(false); },
      extra: speedExtra
    });

    // dot-proxy keeps role="application" (from the HTML); positionDot() keeps its
    // accessible name updated with the live position.

    buildGasTable();
    buildTickLabels();
    buildGasLabels();
    positionAxisTitles();

    // Category checkboxes
    document.getElementById("chk-gasgiants").addEventListener("change", function () {
      state.showGasGiants = this.checked; render();
      srStatus.textContent = "Gas giants " + (this.checked ? "shown." : "hidden.");
    });
    document.getElementById("chk-terrestrial").addEventListener("change", function () {
      state.showTerrestrial = this.checked; render();
      srStatus.textContent = "Terrestrial planets " + (this.checked ? "shown." : "hidden.");
    });
    document.getElementById("chk-icy").addEventListener("change", function () {
      state.showIcy = this.checked; render();
      srStatus.textContent = "Icy bodies and moons " + (this.checked ? "shown." : "hidden.");
    });

    // Pointer + keyboard on the plot
    canvas.addEventListener("pointerdown", onPointerDown);
    window.addEventListener("pointermove", onPointerMove);
    window.addEventListener("pointerup", onPointerUp);
    dotProxy.addEventListener("keydown", onDotKey);
    dotProxy.addEventListener("pointerdown", function () { dotProxy.focus(); });

    // Masthead Reset (sim-reset event; do NOT build our own Reset button)
    document.addEventListener("sim-reset", function () { onReset(true); });

    // Initial state == onResetClicked() at the end of AS setup
    onReset(false);

    // Typeset all static + initial dynamic math once MathJax is ready
    mathReady(function () { MathJax.typesetPromise().catch(function () {}); });
  }

  // Redefine the foundation hook so equations/components initialize on load.
  window.klunlInitEqn = function () {
    if (window.MathJax && MathJax.typesetPromise) MathJax.typesetPromise().catch(function () {});
  };

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", init);
  } else {
    init();
  }
})();
