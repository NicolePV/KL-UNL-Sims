/* ===========================================================================
   Solar System Properties Explorer -- HTML5 port of solarSystemProperties003.swf
   ---------------------------------------------------------------------------
   Behavioural ground truth: the AS1 `histoClass` prototype registered against
   the "histogram_component" symbol (plus the `bar`, `radio_buttons` and
   `check_boxes` classes and the root frame script).  Every constant, data
   table, formula and on-screen string below is copied verbatim from that
   source.  Presentation follows the KL-UNL foundation + WCAG 2.1 AA.

   Architecture: ONE state object; ONE render() that redraws the canvas, syncs
   the DOM overlays, the data table and the live region.  The original polled
   the controls from onEnterFrame and rebuilt the chart whenever `_changed`
   was set; here the control events set state and call render() directly --
   the observable result is identical, without a spinning frame loop.
   =========================================================================== */

(function () {
  'use strict';

  /* ----------------------------------------------------------------------
     1.  DATA AND CONSTANTS -- verbatim from histoClass()
     ---------------------------------------------------------------------- */

  // this.terrestrialPlanets_array / jovianPlanets_array / pluto_array
  // Each entry is [displayName, index into the property arrays].
  var TERRESTRIAL_PLANETS = [['Mercury', 0], ['Venus', 1], ['Earth', 2], ['Mars', 3]];
  var JOVIAN_PLANETS      = [['Jupiter', 4], ['Saturn', 5], ['Uranus', 6], ['Neptune', 7]];
  var PLUTO               = [['Pluto', 8]];

  var MAX_VARS = 9;                                     // this._maxVars

  var semiMajorAxis_array = [0.39, 0.72, 1, 1.52, 5.2, 9.5, 19.2, 30.1, 39.5];
  var orbitalPeriod_array = [0.24, 0.62, 1, 1.9, 11.9, 29.4, 84, 164, 248];
  var mass_array          = [0.055, 0.82, 1, 0.11, 318, 95, 15, 17, 0.002];
  var radius_array        = [0.38, 0.95, 1, 0.53, 11.2, 9.5, 4, 3.9, 0.2];
  var satellites_array    = [0, 0, 1, 2, 28, 30, 21, 8, 1];
  // Present in the original source, but its radio button is hidden by
  // radioClass() (`this.rotation_radio._visible = false`), so the original
  // sim never plots it.  Kept here for fidelity; no control exposes it.
  var rotationPeriod_array = [59, -243, 1, 1, 0.41, 0.44, -0.72, 0.67, -6.4];
  var density_array       = [5.4, 5.2, 5.5, 3.91, 1.3, 0.7, 1.3, 1.6, 2.1];

  // p.terrColor / p.jovColor / p.pluColor -- AS colour ints as hex.
  var TERR_COLOR = '#F58181';                           // 16089473
  var JOV_COLOR  = '#80A9E6';                           //  8432102
  var PLU_COLOR  = '#74CF7C';                           //  7655292

  var BAR_BACK_COLOR    = '#CCCCCC';                    // shape 68, the `myBack` fill
  var BAR_OUTLINE_COLOR = '#333333';                    // lineStyle(2, 3355443, 100)
  var AXIS_COLOR        = '#333333';                    // shapes 112 / 114 stroke

  /* Stage geometry, read out of the SWF placement matrices of the
     `histogram_component` symbol.  All drawing and scale math below runs in
     these ORIGINAL Flash stage units; CSS scales the canvas for display. */
  var PIXEL_HIGH   = -350;                              // this.high_tick._y
  var PIXEL_LOW    = 0;                                 // this.low_tick._y
  var X_OFFSET     = 100.1;                             // this.graphLine._x
  // graphLine wraps a 2-unit stroke drawn from x = 0 to x = 500 (so the symbol
  // measures 502 wide), placed with an x scale of 1.1200103760.
  var AXIS_XSCALE  = 1.1200103760;
  var GRAPH_LENGTH = 502 * AXIS_XSCALE;                 // this.graphLine._width
  var AXIS_LINE_END = X_OFFSET + (500 * AXIS_XSCALE);
  var TICK_X       = 70;                                // high_tick._x / low_tick._x
  var TICK_LENGTH  = 10;                                // shape 112 spans x 0..10
  var STROKE_WIDTH = 2;                                 // shapes 112 / 114 line weight

  // A freshly attached `bar` reports myBar._width = 9 * 8.888885498 (shape 68
  // scaled inside `myBack`); myColor is very slightly narrower.
  var BAR_NATURAL_WIDTH   = 9 * 8.8888854980;
  var BAR_COLOR_WIDTH     = 80 * 0.9994964600;          // myBar.myColor._width

  // Canvas viewport, expressed in the same stage units.
  var STAGE_X0 = 0;
  var STAGE_Y0 = -366;
  var STAGE_W  = 680;
  var STAGE_H  = 372;

  // Right-hand edge of the axis value labels: the `left_label` text field sits
  // at x = -191.5 with a right-aligned box 181.5 wide, i.e. it ends 10 units
  // left of the tick, and Flash insets glyphs by a 2 unit gutter.
  var TICK_LABEL_RIGHT = TICK_X - 10 - 2;

  /* Property table.  `title` is the verbatim on-screen string from
     placeValues(); `latex` is that same string typeset through MathJax; the
     spoken forms give screen readers units-complete wording. */
  var PROPERTIES = {
    axis: {
      title: 'Semi-major Axis (AU)',
      latex: '\\text{Semi-major Axis (AU)}',
      data: semiMajorAxis_array,
      label: 'Semi-Major Axis',
      spokenTitle: 'Semi-major axis in astronomical units',
      unit: 'astronomical units',
      unitOne: 'astronomical unit',
      column: 'Semi-major axis in astronomical units'
    },
    orbital: {
      title: 'Orbital Period (yr)',
      latex: '\\text{Orbital Period (yr)}',
      data: orbitalPeriod_array,
      label: 'Orbital Period',
      spokenTitle: 'Orbital period in years',
      unit: 'years',
      unitOne: 'year',
      column: 'Orbital period in years'
    },
    mass: {
      title: 'Mass (Earth masses)',
      latex: '\\text{Mass (Earth masses)}',
      data: mass_array,
      label: 'Mass',
      spokenTitle: 'Mass in Earth masses',
      unit: 'Earth masses',
      unitOne: 'Earth mass',
      column: 'Mass in Earth masses'
    },
    radius: {
      title: 'Radius (Earth radii)',
      latex: '\\text{Radius (Earth radii)}',
      data: radius_array,
      label: 'Radius',
      spokenTitle: 'Radius in Earth radii',
      unit: 'Earth radii',
      unitOne: 'Earth radius',
      column: 'Radius in Earth radii'
    },
    satellite: {
      title: 'Satellites',
      latex: '\\text{Satellites}',
      data: satellites_array,
      label: 'Satellites',
      spokenTitle: 'Number of satellites',
      unit: 'satellites',
      unitOne: 'satellite',
      column: 'Number of satellites'
    },
    // Unreachable in the original (see rotationPeriod_array above), retained
    // so the port carries the full source table.
    rotation: {
      title: 'Rotation Period (days)',
      latex: '\\text{Rotation Period (days)}',
      data: rotationPeriod_array,
      label: 'Rotation Period',
      spokenTitle: 'Rotation period in days',
      unit: 'days',
      unitOne: 'day',
      column: 'Rotation period in days'
    },
    density: {
      // Original string: 'Density (g/cm<sup>3</sup>)'
      title: 'Density (g/cm\u00B3)',
      latex: '\\text{Density (g/cm}^{3}\\text{)}',
      data: density_array,
      label: 'Density',
      spokenTitle: 'Density in grams per cubic centimeter',
      unit: 'grams per cubic centimeter',
      unitOne: 'gram per cubic centimeter',
      column: 'Density in grams per cubic centimeter'
    }
  };

  var GROUPS = [
    { key: 'terr', planets: TERRESTRIAL_PLANETS, color: TERR_COLOR, type: 'Terrestrial' },
    { key: 'jov',  planets: JOVIAN_PLANETS,      color: JOV_COLOR,  type: 'Jovian'      },
    { key: 'plu',  planets: PLUTO,               color: PLU_COLOR,  type: 'Pluto'       }
  ];

  /* ----------------------------------------------------------------------
     2.  PORTED MATH -- one function per prototype method
     ---------------------------------------------------------------------- */

  // p.logBaseTen: Math.log(num) / 2.302585092994046
  function logBaseTen(num) {
    return Math.log(num) / 2.302585092994046;
  }

  // p.findHighValue / p.findLowValue: scan the FULL nine-element array, so the
  // axis does not rescale when a planet group is hidden.
  function findHighValue(arrayObj) {
    var h = arrayObj[0];
    for (var i = 0; i < arrayObj.length; i++) {
      if (arrayObj[i] > h) { h = arrayObj[i]; }
    }
    return h;
  }

  function findLowValue(arrayObj) {
    var l = arrayObj[0];
    for (var i = 0; i < arrayObj.length; i++) {
      if (arrayObj[i] < l) { l = arrayObj[i]; }
    }
    return l;
  }

  // p.findGoodHigh
  function findGoodHigh(num) {
    if (num > 20) { return Math.ceil(num / 10) * 10; }
    return Math.ceil(num);
  }

  // p.findGoodLow
  function findGoodLow(num, logarithmic) {
    if (logarithmic) {
      return (num < 0.01) ? 0.001 : 0.1;
    }
    if (!(num < 0)) { return 0; }
    if (num < 20) { return Math.floor(num / 10) * 10; }
    return Math.floor(num);
  }

  // p.findPixelVal -- maps a data value onto the stage y axis.
  function findPixelVal(val, graphHigh, graphLow, logBool) {
    if (logBool) {
      return ((PIXEL_HIGH - PIXEL_LOW) /
              (logBaseTen(graphHigh) - logBaseTen(graphLow))) *
             (logBaseTen(val) - logBaseTen(graphHigh)) + PIXEL_HIGH;
    }
    return ((PIXEL_HIGH - PIXEL_LOW) / (graphHigh - graphLow)) *
           (val - graphHigh) + PIXEL_HIGH;
  }

  // p.spaceBars -- halve the bar width until at least 10 units of gap remain.
  function computeBarLayout(num) {
    var barW = BAR_NATURAL_WIDTH;
    var gap  = (GRAPH_LENGTH - (num * barW)) / (num + 1);
    while (gap < 10) {
      barW = barW / 2;
      gap  = (GRAPH_LENGTH - (num * barW)) / (num + 1);
    }
    return { barW: barW, gap: gap };
  }

  function barX(layout, k) {
    return X_OFFSET + layout.gap + ((layout.barW + layout.gap) * k);
  }

  /* ----------------------------------------------------------------------
     3.  STATE  (single source of truth)
     ---------------------------------------------------------------------- */

  var INITIAL_STATE = { showTerr: true, showJov: true, showPlu: true, property: 'axis' };
  var state = Object.assign({}, INITIAL_STATE);

  /* ----------------------------------------------------------------------
     4.  DOM HANDLES
     ---------------------------------------------------------------------- */

  var canvas, ctx, stageEl, plotEl, tickLabelsEl, barLabelsEl;
  var chartDescEl, tableBodyEl, tableValueEl, tableCaptionEl, statusEl;
  var checkboxes = {}, radios = [];
  var displayScale = 1;      // rendered CSS px per stage unit

  /* ----------------------------------------------------------------------
     5.  HELPERS
     ---------------------------------------------------------------------- */

  // Flash printed tick/axis labels with String(number); JS matches for every
  // value this sim can produce.
  function fmt(v) { return String(v); }

  function withUnit(value, prop) {
    return fmt(value) + ' ' + (value === 1 ? prop.unitOne : prop.unit);
  }

  // Rule: typeset math must never be a tab stop (MathJax can add tabindex=0).
  function untabMath(root) {
    if (!root) { return; }
    var nodes = root.querySelectorAll('mjx-container, [tabindex="0"]');
    for (var i = 0; i < nodes.length; i++) {
      nodes[i].setAttribute('tabindex', '-1');
    }
  }

  function typesetLater(el) {
    if (window.MathJax && window.MathJax.typesetPromise) {
      window.MathJax.typesetPromise([el])
        .then(function () { untabMath(el); })
        .catch(function (err) { console.error(err); });
    }
  }

  function visiblePlanets() {
    var out = [];
    for (var g = 0; g < GROUPS.length; g++) {
      var grp = GROUPS[g];
      var shown = (grp.key === 'terr') ? state.showTerr
                : (grp.key === 'jov')  ? state.showJov
                : state.showPlu;
      if (!shown) { continue; }
      for (var i = 0; i < grp.planets.length; i++) {
        out.push({
          name:  grp.planets[i][0],
          index: grp.planets[i][1],
          color: grp.color,
          type:  grp.type
        });
      }
    }
    return out;
  }

  /* ----------------------------------------------------------------------
     6.  CHART MODEL -- everything render() needs, derived from state
     ---------------------------------------------------------------------- */

  function buildModel() {
    var prop    = PROPERTIES[state.property];
    var data    = prop.data;
    var shown   = visiblePlanets();
    var num     = shown.length;
    var layout  = computeBarLayout(num);

    // p.place: the log/linear decision and the axis end points.
    var high    = findHighValue(data);
    var low     = findLowValue(data);
    var logBool = Math.abs(high - low) > 50;
    var graphHigh = findGoodHigh(high);
    var graphLow  = findGoodLow(low, logBool);

    // Bars, in the order the original attaches them.
    var bars = [];
    for (var k = 0; k < num; k++) {
      var value  = data[shown[k].index];
      var pixel  = findPixelVal(value, graphHigh, graphLow, logBool);
      bars.push({
        name:   shown[k].name,
        type:   shown[k].type,
        color:  shown[k].color,
        value:  value,
        height: -pixel,                       // changeHeight(val, 0 - pixelVal)
        x:      barX(layout, k)
      });
    }

    // Intermediate tick marks, ported line for line from p.place().
    var ticks = [];
    var guard = 0;
    var t = graphLow;
    while (t < graphHigh) {
      if (++guard > 1000) { break; }          // safety net; never hit with this data
      if (logBool) { t = t * 10; }
      else if (graphHigh < 15) { t = t + 1; }
      else { t = t + 5; }
      if (t < graphHigh) {
        ticks.push({ value: t, y: findPixelVal(t, graphHigh, graphLow, logBool) });
      }
    }

    return {
      prop: prop, bars: bars, ticks: ticks, layout: layout, num: num,
      graphHigh: graphHigh, graphLow: graphLow, logBool: logBool
    };
  }

  /* ----------------------------------------------------------------------
     7.  CANVAS -- code-drawn geometry only (axis line, tick marks, bars)
     ---------------------------------------------------------------------- */

  function sizeCanvas() {
    var cssW = plotEl.clientWidth;
    if (!cssW) { return false; }
    var dpr  = window.devicePixelRatio || 1;
    var cssH = cssW * STAGE_H / STAGE_W;
    var w = Math.round(cssW * dpr);
    var h = Math.round(cssH * dpr);
    if (canvas.width !== w)  { canvas.width  = w; }
    if (canvas.height !== h) { canvas.height = h; }
    displayScale = cssW / STAGE_W;
    stageEl.style.setProperty('--stage-scale', String(displayScale));
    return true;
  }

  function drawCanvas(model) {
    var dpr = window.devicePixelRatio || 1;
    var s   = (canvas.width / STAGE_W);        // device px per stage unit
    ctx.setTransform(s, 0, 0, s, -STAGE_X0 * s, -STAGE_Y0 * s);
    ctx.clearRect(STAGE_X0, STAGE_Y0, STAGE_W, STAGE_H);

    ctx.lineCap  = 'round';                    // Flash lineStyle defaults
    ctx.lineJoin = 'round';

    // --- axis line (shape 114, 2 unit stroke) and the fixed high/low ticks ---
    ctx.strokeStyle = AXIS_COLOR;
    ctx.lineWidth   = STROKE_WIDTH;
    ctx.beginPath();
    ctx.moveTo(X_OFFSET, PIXEL_LOW);
    ctx.lineTo(AXIS_LINE_END, PIXEL_LOW);
    ctx.stroke();

    drawTick(PIXEL_HIGH);
    drawTick(PIXEL_LOW);
    for (var i = 0; i < model.ticks.length; i++) {
      drawTick(model.ticks[i].y);
    }

    // --- bars ---
    for (var b = 0; b < model.bars.length; b++) {
      drawBar(model.bars[b], model.layout.barW);
    }
  }

  function drawTick(y) {
    ctx.strokeStyle = AXIS_COLOR;
    ctx.lineWidth   = STROKE_WIDTH;
    ctx.beginPath();
    ctx.moveTo(TICK_X, y);
    ctx.lineTo(TICK_X + TICK_LENGTH, y);
    ctx.stroke();
  }

  // barClass.changeHeight(): a light grey backing plate offset one unit up, the
  // tinted bar itself, then a 2 unit outline traced round the tinted bar.  The
  // whole `myBar` clip is x-scaled to bar_w, so the outline's vertical strokes
  // are scaled with it -- reproduced here with a non-uniform transform.
  function drawBar(bar, barW) {
    var sx = barW / BAR_NATURAL_WIDTH;
    var h  = bar.height;

    ctx.save();
    ctx.translate(bar.x, 0);
    ctx.scale(sx, 1);

    ctx.fillStyle = BAR_BACK_COLOR;
    ctx.fillRect(0, -h - 1, BAR_NATURAL_WIDTH, h);

    ctx.fillStyle = bar.color;
    ctx.fillRect(0, -h, BAR_COLOR_WIDTH, h);

    ctx.strokeStyle = BAR_OUTLINE_COLOR;
    ctx.lineWidth   = STROKE_WIDTH;
    ctx.beginPath();
    ctx.moveTo(0, 0);
    ctx.lineTo(0, -h);
    ctx.lineTo(BAR_COLOR_WIDTH, -h);
    ctx.lineTo(BAR_COLOR_WIDTH, 0);
    ctx.lineTo(0, 0);
    ctx.stroke();

    ctx.restore();
  }

  /* ----------------------------------------------------------------------
     8.  HTML OVERLAYS -- all text lives here, so it zooms and (for the
         numeric axis labels) carries real MathJax markup.
     ---------------------------------------------------------------------- */

  function pctY(y) { return ((y - STAGE_Y0) / STAGE_H) * 100; }
  function pctX(x) { return ((x - STAGE_X0) / STAGE_W) * 100; }

  function renderTickLabels(model) {
    // high_label and low_label are attached at the high/low tick positions;
    // every intermediate tick carries its own label.
    var rows = [{ value: model.graphHigh, y: PIXEL_HIGH },
                { value: model.graphLow,  y: PIXEL_LOW }];
    for (var i = 0; i < model.ticks.length; i++) {
      rows.push(model.ticks[i]);
    }

    var html = '';
    for (var r = 0; r < rows.length; r++) {
      html += '<span class="sim-tick-label" style="top:' +
              pctY(rows[r].y).toFixed(4) + '%">\\(' + fmt(rows[r].value) + '\\)</span>';
    }

    // Route the math through the foundation helper (kl-unl.js).
    if (typeof window.klunlShowEquation === 'function') {
      window.klunlShowEquation(['tick-labels', html]);
    } else {
      tickLabelsEl.innerHTML = html;
    }
    // klunlShowEquation kicks off typesetting asynchronously; strip any tab
    // stops MathJax may add once it settles.
    if (window.MathJax && window.MathJax.typesetPromise) {
      window.MathJax.typesetPromise().then(function () { untabMath(tickLabelsEl); });
    }
  }

  function renderBarLabels(model) {
    var html = '';
    for (var i = 0; i < model.bars.length; i++) {
      var bar = model.bars[i];
      var cx  = bar.x + (model.layout.barW / 2);      // myLabel._x = bar_w / 2
      html += '<span class="sim-bar-label" style="left:' + pctX(cx).toFixed(4) + '%">' +
              '<span class="sim-bar-label__text">' + bar.name + '</span></span>';
    }
    barLabelsEl.innerHTML = html;

    // Rotate the names only when they would otherwise collide: compare the
    // per-bar pitch in CSS pixels against the widest rendered label.
    barLabelsEl.classList.remove('sim-bar-labels--rotated');
    var spans = barLabelsEl.querySelectorAll('.sim-bar-label__text');
    if (spans.length > 1) {
      var widest = 0;
      for (var s = 0; s < spans.length; s++) {
        widest = Math.max(widest, spans[s].offsetWidth);
      }
      var pitchPx = (model.layout.barW + model.layout.gap) * displayScale;
      if (widest > pitchPx - 1) {
        barLabelsEl.classList.add('sim-bar-labels--rotated');
      }
    }
  }

  /* ----------------------------------------------------------------------
     9.  TEXT EQUIVALENTS
     ---------------------------------------------------------------------- */

  function renderTitle(model) {
    if (typeof window.klunlShowEquation === 'function') {
      window.klunlShowEquation(
        ['chart-title-math', '\\(' + model.prop.latex + '\\)'],
        ['chart-title-sr',   model.prop.spokenTitle]
      );
      if (window.MathJax && window.MathJax.typesetPromise) {
        window.MathJax.typesetPromise().then(function () {
          untabMath(document.getElementById('chart-title-math'));
        });
      }
    }
  }

  function renderDescription(model) {
    var prop  = model.prop;
    var kinds = [];
    if (state.showTerr) { kinds.push('terrestrial planets'); }
    if (state.showJov)  { kinds.push('jovian planets'); }
    if (state.showPlu)  { kinds.push('Pluto'); }

    var text = 'Bar chart of ' + prop.spokenTitle + '. ' +
               'Vertical axis from ' + withUnit(model.graphLow, prop) + ' to ' +
               withUnit(model.graphHigh, prop) + ', ' +
               (model.logBool ? 'logarithmic' : 'linear') + ' scale. ';

    if (model.num === 0) {
      text += 'No objects are currently shown.';
    } else {
      text += 'Showing ' + model.num + ' of ' + MAX_VARS + ' objects (' +
              kinds.join(', ') + '), left to right: ' +
              model.bars.map(function (b) { return b.name; }).join(', ') + '. ' +
              'A data table with every value follows this chart.';
    }
    chartDescEl.textContent = text;
  }

  function renderTable(model) {
    var prop = model.prop;
    tableValueEl.textContent   = prop.column;
    tableCaptionEl.textContent = 'Data shown in the histogram: ' + prop.spokenTitle;

    var rows = '';
    for (var i = 0; i < model.bars.length; i++) {
      var b = model.bars[i];
      rows += '<tr><th scope="row">' + b.name + '</th><td>' + b.type + '</td><td>' +
              withUnit(b.value, prop) + '</td></tr>';
    }
    tableBodyEl.innerHTML = rows;
  }

  function announce(message) {
    // Re-setting identical text does not re-fire in some screen readers; clear
    // first so every commit is spoken.
    statusEl.textContent = '';
    window.setTimeout(function () { statusEl.textContent = message; }, 30);
  }

  function stateSummary(model) {
    if (model.num === 0) {
      return 'No planet types selected, so no bars are shown.';
    }
    return 'Showing ' + model.num + ' of ' + MAX_VARS + ' objects: ' +
           model.bars.map(function (b) { return b.name; }).join(', ') + '.';
  }

  /* ----------------------------------------------------------------------
     10.  RENDER -- the single redraw path
     ---------------------------------------------------------------------- */

  /* A tab loaded in the background is never laid out, so clientWidth reads 0
     and there is nothing to draw into yet.  Re-arm until a real measurement
     arrives; requestAnimationFrame is suspended while the tab is hidden, so
     this costs nothing until the tab is shown (and is capped in case the panel
     is genuinely zero-width, e.g. inside a display:none container). */
  var sizeRetries = 0;
  var sizeRetryQueued = false;

  function retrySizing() {
    if (sizeRetryQueued || sizeRetries > 60) { return; }
    sizeRetryQueued = true;
    window.requestAnimationFrame(function () {
      sizeRetryQueued = false;
      sizeRetries++;
      render();
    });
  }

  function render(options) {
    options = options || {};
    var model = buildModel();

    if (sizeCanvas()) { sizeRetries = 0; drawCanvas(model); }
    else { retrySizing(); }

    renderTitle(model);
    renderTickLabels(model);
    renderBarLabels(model);
    renderDescription(model);
    renderTable(model);

    canvas.setAttribute('aria-label',
      'Bar chart of ' + model.prop.spokenTitle + ', ' + model.num + ' of ' +
      MAX_VARS + ' objects shown');

    if (options.announce) {
      announce(options.announce + ' ' +
               'Vertical axis from ' + withUnit(model.graphLow, model.prop) + ' to ' +
               withUnit(model.graphHigh, model.prop) + ', ' +
               (model.logBool ? 'logarithmic' : 'linear') + ' scale. ' +
               stateSummary(model));
    }
  }

  /* ----------------------------------------------------------------------
     11.  CONTROLS
     ---------------------------------------------------------------------- */

  function syncControlsToState() {
    checkboxes.terr.checked = state.showTerr;
    checkboxes.jov.checked  = state.showJov;
    checkboxes.plu.checked  = state.showPlu;
    for (var i = 0; i < radios.length; i++) {
      radios[i].checked = (radios[i].value === state.property);
    }
  }

  function wireControls() {
    // check_boxes: terrestrialChanged / jovianChanged / plutoChanged
    var boxes = [
      { el: checkboxes.terr, key: 'showTerr', name: 'Terrestrial planets' },
      { el: checkboxes.jov,  key: 'showJov',  name: 'Jovian planets' },
      { el: checkboxes.plu,  key: 'showPlu',  name: 'Pluto' }
    ];
    boxes.forEach(function (box) {
      box.el.addEventListener('change', function () {
        state[box.key] = box.el.checked;
        render({ announce: box.name + (box.el.checked ? ' shown.' : ' hidden.') });
      });
    });

    // radio_buttons: changeToAxis / changeToOrbital / ... set radio._value
    radios.forEach(function (radio) {
      radio.addEventListener('change', function () {
        if (!radio.checked) { return; }
        state.property = radio.value;
        render({ announce: 'Now plotting ' + PROPERTIES[state.property].label + '.' });
      });
    });

    // Root frame script onReset(), fired by the masthead's Reset button.
    document.addEventListener('sim-reset', function () {
      state = Object.assign({}, INITIAL_STATE);
      syncControlsToState();
      render({ announce: 'Simulation reset.' });
    });
  }

  /* ----------------------------------------------------------------------
     12.  START-UP
     ---------------------------------------------------------------------- */

  function init() {
    canvas         = document.getElementById('chart-canvas');
    ctx            = canvas.getContext('2d');
    stageEl        = document.getElementById('sim-stage');
    plotEl         = document.getElementById('sim-plot');
    tickLabelsEl   = document.getElementById('tick-labels');
    barLabelsEl    = document.getElementById('bar-labels');
    chartDescEl    = document.getElementById('chart-desc');
    tableBodyEl    = document.getElementById('chart-table-body');
    tableValueEl   = document.getElementById('chart-table-value');
    tableCaptionEl = document.getElementById('chart-table-caption');
    statusEl       = document.getElementById('sim-status');

    checkboxes.terr = document.getElementById('show-terrestrial');
    checkboxes.jov  = document.getElementById('show-jovian');
    checkboxes.plu  = document.getElementById('show-pluto');
    radios = Array.prototype.slice.call(
      document.querySelectorAll('input[name="property"]'));

    stageEl.style.setProperty('--stage-aspect', String(STAGE_W / STAGE_H));

    syncControlsToState();
    wireControls();
    window.klunlInitEqn();          // the redefined foundation hook (see below)

    // Re-lay out on any size change (viewport, zoom, orientation).  The
    // observer covers container-driven changes; the window listener and the
    // load/rAF passes cover the case where the first paint happens before the
    // panel has a measurable width.
    if (window.ResizeObserver) {
      new ResizeObserver(function () { render(); }).observe(plotEl);
    }
    window.addEventListener('resize', function () { render(); });
    window.addEventListener('orientationchange', function () { render(); });
    window.addEventListener('load', function () { render(); });
    // A background tab gets no layout and no animation frames; redraw when it
    // is first brought to the front.
    document.addEventListener('visibilitychange', function () {
      if (!document.hidden) { sizeRetries = 0; render(); }
    });
    window.requestAnimationFrame(function () { render(); });

    // Redraw once MathJax has finished booting so the first paint is typeset.
    if (window.MathJax && window.MathJax.startup && window.MathJax.startup.promise) {
      window.MathJax.startup.promise.then(function () { render(); });
    }
  }

  /* kl-unl.js defines klunlInitEqn() as the hook a sim redefines to initialise
     its equations and components; redefining it here makes it this sim's first
     draw, and init() calls it once the DOM is ready. */
  window.klunlInitEqn = function () { render(); };

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();
