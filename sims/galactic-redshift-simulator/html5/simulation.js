/* ==========================================================================
   Galactic Redshift Simulator — HTML5 port of the Flash (AS3) original.

   Behaviour is a direct port of the decompiled ActionScript in
   scripts/GalacticRedshift.as, Spectrum.as, SpectrumGraph.as,
   SpectrumVisualization.as, FilterStrengthsChart.as, ProtoSliderLogic.as and
   astroUNL/utils/easing/CubicEaser.as. Every constant, table and formula is
   copied verbatim; the presentation is rebuilt on the KL-UNL foundation.

   Single source of truth: the `state` object below. One render() redraws the
   canvases, syncs the DOM and refreshes the screen-reader descriptions.
   ========================================================================== */

(function () {
  'use strict';

  // ======================================================================
  // Constants — all verbatim from GalacticRedshift.as unless noted
  // ======================================================================

  // GalacticRedshift.GalacticRedshift()
  var REDSHIFT_OFFSET   = 0.000684;   // _redshiftOffset
  var MIN_WAVELENGTH    = 250;        // _minWavelength (nm)
  var MAX_WAVELENGTH    = 950;        // _maxWavelength (nm)
  var GRAPH_WIDTH       = 700;        // _loc1_
  var GRAPH_HEIGHT      = 300;        // _loc2_
  var VIS_HEIGHT        = 30;         // _loc3_
  var GRAPH_MAX_F       = 1.05;       // maxF passed to SpectrumGraph
  var FILTERS_EASE_MS   = 200;        // _filtersEaseDuration

  // SpectrumVisualization
  var VIS_MIN           = 400;        // SpectrumVisualization.visualMin (nm)
  var VIS_MAX           = 700;        // SpectrumVisualization.visualMax (nm)
  var VIS_MAX_F         = 1;          // maxF passed to SpectrumVisualization
  // _loc4_ = (visualMax - visualMin) * (graphWidth / (maxW - minW))
  var VIS_WIDTH         = (VIS_MAX - VIS_MIN) * (GRAPH_WIDTH / (MAX_WAVELENGTH - MIN_WAVELENGTH));

  // Spectrum.as
  var MIN_F             = 0;          // _minF
  var BORDER_COLOR      = '#000000';  // _borderColor  = 0
  var BACKGROUND_COLOR  = '#ffffff';  // _backgroundColor = 16777215
  var LINE_COLOR        = '#000000';  // _lineColor    = 0
  var FILTER_FILL_ALPHA = 0.3;        // beginFill(color, 0.3) in redrawFilters

  // SpectrumGraph
  var OBS_RESOLUTION    = 1;          // _observedWavelengthResolution (nm)

  // FilterStrengthsChart.setMagnitudes
  var BAR_MIN_MAG       = 1;          // _loc2_
  var BAR_MAX_MAG       = 4.8;        // _loc3_
  var BAR_MAG_RANGE     = BAR_MAX_MAG - BAR_MIN_MAG;   // _loc4_ = 3.8

  // ProtoSliderLogic, configured by setValueFormat("fixed digits", 2)
  // and setValueRange(0, 1).
  var Z_MIN             = 0;
  var Z_MAX             = 1;
  var Z_DIGITS          = 2;
  var Z_INCREMENT       = Math.pow(10, -Z_DIGITS);     // _minIncrement = 0.01

  // Tick marks, verbatim from _graph.addTickmarks([...])
  var TICKMARKS = [
    { w: 250 }, { w: 300, label: '300 nm' }, { w: 350 }, { w: 400, label: '400 nm' },
    { w: 450 }, { w: 500, label: '500 nm' }, { w: 550 }, { w: 600, label: '600 nm' },
    { w: 650 }, { w: 700, label: '700 nm' }, { w: 750 }, { w: 800, label: '800 nm' },
    { w: 850 }, { w: 900, label: '900 nm' }, { w: 950 }
  ];

  // _filterSet = [_uFilter, _bFilter, _vFilter, _rFilter]
  var FILTER_ORDER = ['U', 'B', 'V', 'R'];

  // colorFromWavelengthAndIntensity() colour ramp (SpectrumVisualization)
  var RAMP_COLORS = [0, 255, 65535, 65280, 16776960, 16711680, 0];
  var RAMP_STOPS  = [0, 48, 96, 128, 160, 207, 256];
  // Names for the same six segments, used only for the screen-reader text so
  // that colour is never the sole carrier of meaning.
  var RAMP_NAMES  = ['deep violet', 'blue', 'cyan', 'green', 'yellow', 'red'];

  // ======================================================================
  // Data (extracted verbatim into assets/spectrum-data.js)
  // ======================================================================

  var DATA     = window.GRS_DATA;
  var SPECTRUM = DATA.spectrum;                 // flat [w, f, w, f, ...]
  var N_POINTS = SPECTRUM.length / 2;

  function specW(i) { return SPECTRUM[i * 2]; }
  function specF(i) { return SPECTRUM[i * 2 + 1]; }

  // ======================================================================
  // CubicEaser — verbatim port of astroUNL.utils.easing.CubicEaser
  // ======================================================================

  function CubicEaser(value) {
    this.slope0 = 0;
    this.slope1 = 0;
    this.init(value);
  }

  CubicEaser.prototype.init = function (value) {
    this.setTarget(0, value, 1, value);
  };

  CubicEaser.prototype.setTarget = function (startTime, startValue, targetTime, targetValue) {
    if (typeof startValue !== 'number') {
      startValue  = this.getValue(startTime);
      this.slope0 = this.getDerivative(startTime);
    } else {
      this.slope0 = 0;
    }
    this.startTime        = startTime;
    this.startValue       = startValue;
    this.splinePointsList = [{ x: startTime, y: startValue }, { x: targetTime, y: targetValue }];
    this.doComputations();
    this.targetTime  = targetTime;
    this.targetValue = targetValue;
  };

  CubicEaser.prototype.doComputations = function () {
    var i, j, sig, p;
    this.splinePointsList.sort(function (a, b) { return a.x - b.x; });
    var pts   = this.splinePointsList;
    var n     = pts.length;
    var last  = n - 1;
    var last2 = n - 2;
    var s0    = this.slope0;
    var s1    = this.slope1;
    var u     = [];

    pts[0].d2 = -0.5;
    u[0] = 3 / (pts[1].x - pts[0].x) * ((pts[1].y - pts[0].y) / (pts[1].x - pts[0].x) - s0);

    for (i = 1; i < last; i++) {
      sig = (pts[i].x - pts[i - 1].x) / (pts[i + 1].x - pts[i - 1].x);
      p   = sig * pts[i - 1].d2 + 2;
      pts[i].d2 = (sig - 1) / p;
      u[i] = (pts[i + 1].y - pts[i].y) / (pts[i + 1].x - pts[i].x) -
             (pts[i].y - pts[i - 1].y) / (pts[i].x - pts[i - 1].x);
      u[i] = (6 * u[i] / (pts[i + 1].x - pts[i - 1].x) - sig * u[i - 1]) / p;
    }

    var qn = 0.5;
    var un = 3 / (pts[last].x - pts[last2].x) *
             (s1 - (pts[last].y - pts[last2].y) / (pts[last].x - pts[last2].x));
    pts[last].d2 = (un - qn * u[last2]) / (qn * pts[last2].d2 + 1);

    for (j = last2; j >= 0; j--) {
      pts[j].d2 = pts[j].d2 * pts[j + 1].d2 + u[j];
    }

    var params = [];
    for (i = 0; i < last; i++) {
      var p0 = pts[i], p1 = pts[i + 1];
      var y2a = p0.d2, y2b = p1.d2;
      var xa = p0.x,  xb = p1.x;
      var ya = p0.y,  yb = p1.y;
      var h  = xb - xa;
      var a  = (y2b - y2a) / (6 * h);
      var b  = (3 * xb * y2a - 3 * y2b * xa) / (6 * h);
      var c  = (-6 * ya + 2 * xb * y2b * xa - xb * xb * y2b - 2 * xb * y2a * xa +
                y2a * xa * xa - 2 * xb * xb * y2a + 6 * yb + 2 * y2b * xa * xa) / (6 * h);
      var d  = (-2 * y2b * xb * xa * xa + 2 * y2a * xb * xb * xa + y2b * xb * xb * xa -
                6 * yb * xa + 6 * ya * xb - y2a * xb * xa * xa) / (6 * h);
      params.push({ xUpper: xb, a: a, b: b, c: c, d: d });
    }
    this.parametersList = params;
  };

  CubicEaser.prototype.getValue = function (t) {
    var list = this.parametersList, n = list.length, i = 0;
    while (i < n) { if (t < list[i].xUpper) { break; } i++; }
    if (i < n) { return list[i].d + t * (list[i].c + t * (list[i].b + t * list[i].a)); }
    return this.targetValue;
  };

  CubicEaser.prototype.getDerivative = function (t) {
    var list = this.parametersList, n = list.length, i = 0;
    while (i < n) { if (t < list[i].xUpper) { break; } i++; }
    if (i < n) { return list[i].c + t * (2 * list[i].b + 3 * t * list[i].a); }
    return 0;
  };

  // ======================================================================
  // State — the single source of truth
  // ======================================================================

  var state = {
    z: 0,                 // zSlider.value, 0..1 in steps of 0.01
    showFilters: false,   // target of the show/hide transition
    filtersAlpha: 0       // eased 0..1, drives the filter overlay + chart
  };

  var easer        = new CubicEaser(0);   // _filtersEaser
  var easeTimer    = null;                // _filtersTimer (Timer(10) in the AS)
  var startTime    = (typeof performance !== 'undefined' && performance.now)
                        ? performance.now() : Date.now();

  // getTimer() in Flash counts milliseconds since the movie started.
  function getTimer() {
    var now = (typeof performance !== 'undefined' && performance.now)
                ? performance.now() : Date.now();
    return now - startTime;
  }

  var reduceMotion = window.matchMedia
    ? window.matchMedia('(prefers-reduced-motion: reduce)')
    : { matches: false };

  // ======================================================================
  // Derived quantities: observed spectrum, filter geometry, magnitudes
  // ======================================================================

  // SpectrumGraph resamples the redshifted spectrum onto a fixed 1 nm grid
  // spanning the plotted range, so the filter integrals can look flux up by
  // wavelength. Verbatim from the SpectrumGraph constructor.
  var OBS_MIN_W  = Math.floor(MIN_WAVELENGTH / OBS_RESOLUTION) * OBS_RESOLUTION;   // 250
  var OBS_COUNT  = Math.ceil(MAX_WAVELENGTH / OBS_RESOLUTION) -
                   Math.floor(MIN_WAVELENGTH / OBS_RESOLUTION) + 1;                // 701
  var observedFluxes = new Float64Array(OBS_COUNT);

  var magnitudes = { U: 0, B: 0, V: 0, R: 0 };   // _mags

  // SpectrumGraph.valueAt()
  function valueAt(w) {
    var idx = Math.round((w - OBS_MIN_W) / OBS_RESOLUTION);
    if (idx < 0 || idx >= OBS_COUNT) { return 0; }
    return observedFluxes[idx];
  }

  // The observed-flux resampling half of SpectrumGraph.redraw().
  function computeObservedFluxes(redshift) {
    var i, idx, shifted;
    var z1 = redshift + 1;

    for (i = 0; i < OBS_COUNT; i++) { observedFluxes[i] = NaN; }

    for (i = 0; i < N_POINTS; i++) {
      shifted = z1 * specW(i);                                   // lambda_obs = (1+z) * lambda_emit
      idx = Math.round((shifted - OBS_MIN_W) / OBS_RESOLUTION);
      if (idx >= 0 && idx < OBS_COUNT) { observedFluxes[idx] = specF(i); }
    }

    // Zero the gaps outside the covered range, then any interior gaps —
    // exactly the three clean-up passes at the end of SpectrumGraph.redraw().
    var lastIdx = 0, firstIdx = 0;
    for (i = OBS_COUNT - 1; i >= 0; i--) {
      if (!isNaN(observedFluxes[i])) { lastIdx = i; break; }
      observedFluxes[i] = 0;
    }
    for (i = 0; i < lastIdx; i++) {
      if (!isNaN(observedFluxes[i])) { firstIdx = i; break; }
      observedFluxes[i] = 0;
    }
    for (i = firstIdx; i <= lastIdx; i++) {
      if (isNaN(observedFluxes[i])) { observedFluxes[i] = 0; }
    }
  }

  // The geometry + integral half of SpectrumGraph.redrawFilters(). The filter
  // bandpasses do not move with z (they are fixed in observed wavelength); it
  // is the flux underneath them that shifts.
  var filterPaths = [];   // one {color, points:[[x,y],...]} per filter

  function computeFilters() {
    var xScale = GRAPH_WIDTH / (MAX_WAVELENGTH - MIN_WAVELENGTH);
    var yScale = -GRAPH_HEIGHT / (GRAPH_MAX_F - MIN_F);
    var k, j, filter, data, n, w, x, product, area, prevW, prevProduct, pts;

    filterPaths.length = 0;

    for (k = 0; k < FILTER_ORDER.length; k++) {
      filter = DATA.filters[FILTER_ORDER[k]];
      data   = filter.data;                       // flat [w, t, w, t, ...]
      n      = data.length / 2;
      pts    = [];

      w       = data[0];
      x       = xScale * (w - MIN_WAVELENGTH);
      product = data[1] * valueAt(w);             // transmittance * observed flux
      pts.push([x, yScale * (product - MIN_F)]);

      area        = 0;
      prevW       = w;
      prevProduct = product;

      for (j = 1; j < n; j++) {
        w       = data[j * 2];
        x       = xScale * (w - MIN_WAVELENGTH);
        product = data[j * 2 + 1] * valueAt(w);
        pts.push([x, yScale * (product - MIN_F)]);
        // Trapezoid rule: area += dLambda * (f_prev + f_now) / 2
        area += (w - prevW) * (prevProduct + product) / 2;
        prevW       = w;
        prevProduct = product;
      }

      filterPaths.push({ color: filter.color, points: pts });
      magnitudes[filter.name] = -Math.log(area);   // m = -ln( integral T*F dLambda )
    }
  }

  // ======================================================================
  // Canvas rendering
  // ======================================================================

  var graphCanvas = document.getElementById('graphCanvas');
  var visCanvas   = document.getElementById('visCanvas');
  var graphCtx    = graphCanvas.getContext('2d');
  var visCtx      = visCanvas.getContext('2d');

  // Offscreen buffer for the filter overlay. Flash composites the four 30%
  // fills into one Shape and then applies the Shape's alpha to the result, so
  // the overlaps must be flattened before the ease alpha is applied.
  var filterBuffer    = document.createElement('canvas');
  var filterBufferCtx = filterBuffer.getContext('2d');

  var BORDER_PAD = 1;   // room for the 1 px border around the 700x300 plot

  // Back the canvases at device resolution for crisp lines, while the CSS
  // keeps them fluid. All drawing maths stays in original stage coordinates.
  function sizeCanvases() {
    var dpr = Math.max(1, Math.min(3, window.devicePixelRatio || 1));

    graphCanvas.width  = Math.round((GRAPH_WIDTH  + 2 * BORDER_PAD) * dpr);
    graphCanvas.height = Math.round((GRAPH_HEIGHT + 2 * BORDER_PAD) * dpr);
    visCanvas.width    = Math.round(VIS_WIDTH  * dpr);
    visCanvas.height   = Math.round(VIS_HEIGHT * dpr);

    filterBuffer.width  = graphCanvas.width;
    filterBuffer.height = graphCanvas.height;

    graphCanvas.__dpr = dpr;
    visCanvas.__dpr   = dpr;
  }

  // Establishes the original AS coordinate system: the graph's origin is its
  // bottom-left corner and y grows downward on screen but the plot is drawn at
  // negative y (drawRect(0, -height, width, height)). The extra half pixel
  // keeps 1 px strokes on exact device pixels.
  function useStageTransform(ctx, dpr) {
    ctx.setTransform(dpr, 0, 0, dpr, 0, 0);
    ctx.translate(BORDER_PAD + 0.5, BORDER_PAD + GRAPH_HEIGHT + 0.5);
  }

  function drawFilterBuffer() {
    var dpr = graphCanvas.__dpr;
    var ctx = filterBufferCtx;
    var i, j, path, pts;

    ctx.setTransform(1, 0, 0, 1, 0, 0);
    ctx.clearRect(0, 0, filterBuffer.width, filterBuffer.height);
    useStageTransform(ctx, dpr);

    for (i = 0; i < filterPaths.length; i++) {
      path = filterPaths[i];
      pts  = path.points;
      if (!pts.length) { continue; }

      ctx.beginPath();
      ctx.moveTo(pts[0][0], 0);              // start on the baseline
      ctx.lineTo(pts[0][0], pts[0][1]);
      for (j = 1; j < pts.length; j++) { ctx.lineTo(pts[j][0], pts[j][1]); }
      ctx.lineTo(pts[pts.length - 1][0], 0); // back down to the baseline
      ctx.closePath();

      ctx.fillStyle   = rgbaFromInt(path.color, FILTER_FILL_ALPHA);
      ctx.fill();
    }
  }

  function drawGraph() {
    var dpr = graphCanvas.__dpr;
    var ctx = graphCtx;
    var i, shifted, x, y;
    var redshift = state.z + REDSHIFT_OFFSET;
    var xScale   = GRAPH_WIDTH / (MAX_WAVELENGTH - MIN_WAVELENGTH);
    var yScale   = -GRAPH_HEIGHT / (GRAPH_MAX_F - MIN_F);
    var z1       = redshift + 1;

    ctx.setTransform(1, 0, 0, 1, 0, 0);
    ctx.clearRect(0, 0, graphCanvas.width, graphCanvas.height);
    useStageTransform(ctx, dpr);

    // Spectrum.redraw(): white background over the plot area
    ctx.fillStyle = BACKGROUND_COLOR;
    ctx.fillRect(0, -GRAPH_HEIGHT, GRAPH_WIDTH, GRAPH_HEIGHT);

    // _content.mask — everything plotted is clipped to the plot rectangle
    ctx.save();
    ctx.beginPath();
    ctx.rect(0, -GRAPH_HEIGHT, GRAPH_WIDTH, GRAPH_HEIGHT);
    ctx.clip();

    // Filter overlay sits behind the curve (added to _content first)
    if (state.filtersAlpha > 0) {
      ctx.save();
      ctx.globalAlpha = state.filtersAlpha;
      ctx.setTransform(1, 0, 0, 1, 0, 0);
      ctx.drawImage(filterBuffer, 0, 0);
      ctx.restore();
    }

    // The spectrum curve itself
    ctx.beginPath();
    ctx.lineWidth   = 1;              // lineStyle(0, ...) is a hairline in Flash
    ctx.strokeStyle = LINE_COLOR;
    ctx.lineJoin    = 'round';
    ctx.lineCap     = 'round';

    shifted = z1 * specW(0);
    ctx.moveTo(xScale * (shifted - MIN_WAVELENGTH), yScale * (specF(0) - MIN_F));

    for (i = 1; i < N_POINTS; i++) {
      shifted = z1 * specW(i);
      x = xScale * (shifted - MIN_WAVELENGTH);
      y = yScale * (specF(i) - MIN_F);
      if (x < 0) {
        ctx.moveTo(x, y);
      } else if (x >= GRAPH_WIDTH) {
        ctx.lineTo(x, y);
        break;
      } else {
        ctx.lineTo(x, y);
      }
    }
    ctx.stroke();
    ctx.restore();

    // Border last, on top of the clipped content
    ctx.lineWidth   = 1;
    ctx.strokeStyle = BORDER_COLOR;
    ctx.strokeRect(0, -GRAPH_HEIGHT, GRAPH_WIDTH, GRAPH_HEIGHT);
  }

  // SpectrumVisualization.colorFromWavelengthAndIntensity(), verbatim.
  // `int(x)` in ActionScript truncates toward zero, which is what `| 0` does.
  function colorFromWavelengthAndIntensity(wavelength, intensity) {
    var t = (wavelength - 400) / 300;
    if (t < 0 || t > 1) { return 0; }
    t *= 256;

    var color = 0, k, frac, r, g, b;
    for (k = 1; k < RAMP_STOPS.length; k++) {
      if (t <= RAMP_STOPS[k]) {
        frac = (t - RAMP_STOPS[k - 1]) / (RAMP_STOPS[k] - RAMP_STOPS[k - 1]);

        r = (intensity * (((RAMP_COLORS[k - 1] >> 16) & 0xFF) +
              frac * (((RAMP_COLORS[k] >> 16) & 0xFF) - ((RAMP_COLORS[k - 1] >> 16) & 0xFF)))) | 0;
        if (r < 0) { r = 0; } else if (r > 255) { r = 255; }

        g = (intensity * (((RAMP_COLORS[k - 1] >> 8) & 0xFF) +
              frac * (((RAMP_COLORS[k] >> 8) & 0xFF) - ((RAMP_COLORS[k - 1] >> 8) & 0xFF)))) | 0;
        if (g < 0) { g = 0; } else if (g > 255) { g = 255; }

        b = (intensity * ((RAMP_COLORS[k - 1] & 0xFF) +
              frac * ((RAMP_COLORS[k] & 0xFF) - (RAMP_COLORS[k - 1] & 0xFF)))) | 0;
        if (b < 0) { b = 0; } else if (b > 255) { b = 255; }

        color = ((r << 16) | (g << 8) | b) >>> 0;
        break;
      }
    }
    return color;
  }

  // Kept so the screen-reader description can name the brightest colour band
  // without re-deriving the ramp.
  function rampSegmentName(wavelength) {
    var t = (wavelength - 400) / 300;
    if (t < 0 || t > 1) { return 'outside the visible band'; }
    t *= 256;
    for (var k = 1; k < RAMP_STOPS.length; k++) {
      if (t <= RAMP_STOPS[k]) { return RAMP_NAMES[k - 1]; }
    }
    return RAMP_NAMES[RAMP_NAMES.length - 1];
  }

  var visIntensities = new Float64Array(Math.round(VIS_WIDTH));
  var visBrightestW  = VIS_MIN;

  // SpectrumVisualization.redraw(), verbatim. Each spectrum sample is spread
  // over the pixel columns it covers, the columns are normalised to the
  // brightest one, and each column is painted with its wavelength's colour.
  function drawVisualization() {
    var W   = visIntensities.length;
    var ctx = visCtx;
    var dpr = visCanvas.__dpr;
    var i, k;

    var xScale = VIS_WIDTH / (VIS_MAX - VIS_MIN);
    var z1     = state.z + REDSHIFT_OFFSET + 1;
    var fRange = VIS_MAX_F - MIN_F;

    var cur = 0, next = 0, left = 0, right = 0;
    var value, width, floorL, floorR, perUnit;

    for (i = 0; i < W; i++) { visIntensities[i] = 0; }

    for (i = 0; i < N_POINTS; i++) {
      if (i === 0) {
        cur   = xScale * (z1 * specW(0) - VIS_MIN);
        next  = xScale * (z1 * specW(1) - VIS_MIN);
        right = (cur + next) / 2;
        left  = cur - (right - cur) / 2;
      } else if (i === N_POINTS - 1) {
        cur   = next;
        left  = right;
        right = cur + (cur - left) / 2;
      } else {
        cur   = next;
        left  = right;
        next  = xScale * (z1 * specW(i + 1) - VIS_MIN);
        right = (cur + next) / 2;
      }

      value = fRange * (specF(i) - MIN_F);
      if (value > 1) { value = 1; } else if (value < 0) { value = 0; }

      width   = right - left;
      floorL  = Math.floor(left);
      floorR  = Math.floor(right);
      perUnit = value / width;

      if (!(floorR < 0 || floorL >= W)) {
        if (floorL === floorR) {
          if (floorL >= 0 && floorL < W) { visIntensities[floorL] += value; }
        } else {
          if (floorL >= 0 && floorL < W) { visIntensities[floorL] += (1 - (left - floorL)) * perUnit; }
          if (floorR >= 0 && floorR < W) { visIntensities[floorR] += (right - floorR) * perUnit; }
          for (k = floorL + 1; k < floorR; k++) {
            if (k >= 0 && k < W) { visIntensities[k] += perUnit; }
          }
        }
      }
    }

    var max = Number.NEGATIVE_INFINITY, maxIdx = 0;
    for (i = 0; i < W; i++) {
      if (visIntensities[i] > max) { max = visIntensities[i]; maxIdx = i; }
    }

    var step   = (VIS_MAX - VIS_MIN) / W;
    var centre = VIS_MIN + step / 2;
    visBrightestW = VIS_MIN + step * (maxIdx + 0.5);

    ctx.setTransform(1, 0, 0, 1, 0, 0);
    ctx.clearRect(0, 0, visCanvas.width, visCanvas.height);
    ctx.setTransform(dpr, 0, 0, dpr, 0, 0);

    for (i = 0; i < W; i++) {
      var rgb = colorFromWavelengthAndIntensity(centre, visIntensities[i] / max);
      ctx.fillStyle = rgbaFromInt(rgb, 1);
      // A hair of overlap prevents seams between columns when CSS scales the
      // canvas up on a high-density display.
      ctx.fillRect(i, 0, 1.02, VIS_HEIGHT);
      centre += step;
    }
  }

  // AS colour ints are plain decimal RGB.
  function rgbaFromInt(value, alpha) {
    var r = (value >> 16) & 0xFF;
    var g = (value >> 8) & 0xFF;
    var b = value & 0xFF;
    return 'rgba(' + r + ',' + g + ',' + b + ',' + alpha + ')';
  }

  // ======================================================================
  // DOM references
  // ======================================================================

  var zSlider      = document.getElementById('zSlider');
  var zInput       = document.getElementById('zInput');
  var filtersBtn   = document.getElementById('showHideFiltersButton');
  var filterChart  = document.getElementById('filterChart');
  var tickStrip    = document.getElementById('tickStrip');
  var liveStatus   = document.getElementById('liveStatus');
  var graphDesc    = document.getElementById('graphDesc');
  var visDesc      = document.getElementById('visDesc');
  var chartDesc    = document.getElementById('filterChartDesc');

  var bars = {
    U: document.getElementById('barU'),
    B: document.getElementById('barB'),
    V: document.getElementById('barV'),
    R: document.getElementById('barR')
  };

  // ======================================================================
  // Value handling — ProtoSliderLogic with "fixed digits", 2
  // ======================================================================

  // getValueObjectFromValue(): clamp into range, then snap to the increment.
  function normaliseZ(value) {
    if (isNaN(value) || !isFinite(value)) { return null; }
    if (value < Z_MIN) { value = Z_MIN; } else if (value > Z_MAX) { value = Z_MAX; }
    return Z_INCREMENT * Math.round(value / Z_INCREMENT);
  }

  // getValueStringFromValueObject(): _digs > 0, so toFixed(_digs)
  function zString() {
    return state.z.toFixed(Z_DIGITS);
  }

  // ======================================================================
  // Show / hide filters — GalacticRedshift.setShowFilters / showFilters
  // ======================================================================

  // GalacticRedshift's showFilters getter is derived from the easer's target,
  // not stored separately: `return _filtersEaser.targetValue == 1`.
  function isShowFilters() {
    return easer.targetValue === 1;
  }

  function setShowFilters(value, animate) {
    if (animate === undefined) { animate = true; }

    // setShowFilters(v, false): stop the timer, snap the easer, update.
    if (!animate || reduceMotion.matches) {
      stopEaseLoop();
      easer.init(value ? 1 : 0);
      updateFiltersButtonLabel();
      updateFiltersTransition();
      return;
    }

    // The animated path is the AS `set showFilters` setter.
    if (value !== isShowFilters()) {
      var t = getTimer();
      easer.setTarget(t, null, t + FILTERS_EASE_MS, value ? 1 : 0);
      startEaseLoop();
    }
    updateFiltersButtonLabel();
    updateFiltersTransition();
  }

  // The original drives this transition from `new Timer(10)`, not from the
  // frame loop. An interval is used here for the same reason it works there:
  // it keeps ticking when requestAnimationFrame is suspended (background tab,
  // a pane that is not compositing), so the fade can never be left stranded
  // part-way. If a tick is delayed past the target time, updateFiltersTransition
  // snaps straight to the end state and stops the timer.
  function startEaseLoop() {
    if (easeTimer !== null) { return; }
    easeTimer = window.setInterval(updateFiltersTransition, 10);
  }

  function stopEaseLoop() {
    if (easeTimer !== null) { window.clearInterval(easeTimer); easeTimer = null; }
  }

  // GalacticRedshift.updateFiltersTransition()
  function updateFiltersTransition() {
    var now = getTimer();
    var value;

    if (now > easer.targetTime) {
      value = easer.targetValue;
      easer.init(easer.targetValue);
      stopEaseLoop();
    } else {
      value = easer.getValue(now);
    }

    if (value < 0) { value = 0; } else if (value > 1) { value = 1; }

    state.filtersAlpha  = value;
    state.showFilters   = isShowFilters();
    render();
  }

  // GalacticRedshift.updateFiltersButtonLabel()
  function updateFiltersButtonLabel() {
    var showing = isShowFilters();
    var label   = showing ? 'hide' : 'show filter details';
    if (filtersBtn.textContent !== label) { filtersBtn.textContent = label; }
    filtersBtn.setAttribute('aria-pressed', showing ? 'true' : 'false');
  }

  // ======================================================================
  // GalacticRedshift.onZChanged()
  // ======================================================================

  function onZChanged() {
    var redshift = state.z + REDSHIFT_OFFSET;   // _redshiftOffset added here in the AS
    computeObservedFluxes(redshift);
    computeFilters();
    drawVisualization();
    drawFilterBuffer();
    render();
  }

  // ======================================================================
  // render() — redraws the canvas and syncs every DOM mirror of the state
  // ======================================================================

  function render() {
    drawGraph();

    // Filter strengths chart. FilterStrengthsChart.setMagnitudes():
    //   scaleY = (-magnitude - barMin) / (barMax - barMin)
    var k, name, scale;
    for (k = 0; k < FILTER_ORDER.length; k++) {
      name  = FILTER_ORDER[k];
      scale = (-magnitudes[name] - BAR_MIN_MAG) / BAR_MAG_RANGE;
      if (!isFinite(scale)) { scale = 0; }
      bars[name].style.transform = 'scaleY(' + scale + ')';
    }
    filterChart.style.opacity = String(state.filtersAlpha);
    // Hidden bars carry no information, so keep them out of the a11y tree.
    if (state.filtersAlpha <= 0) {
      filterChart.setAttribute('aria-hidden', 'true');
    } else {
      filterChart.removeAttribute('aria-hidden');
    }

    // Slider + numeric field (ProtoSimpleSlider.updateSync())
    var text = zString();
    if (zInput.value !== text && document.activeElement !== zInput) { zInput.value = text; }
    if (parseFloat(zSlider.value) !== state.z) { zSlider.value = String(state.z); }
    zSlider.setAttribute('aria-valuetext', 'Redshift z equals ' + text);

    updateDescriptions();
  }

  // ======================================================================
  // Screen-reader descriptions — the text equivalent of the two canvases
  // ======================================================================

  function nm(value, digits) {
    return value.toFixed(digits === undefined ? 0 : digits) + ' nanometers';
  }

  function barPercent(name) {
    var scale = (-magnitudes[name] - BAR_MIN_MAG) / BAR_MAG_RANGE;
    if (!isFinite(scale)) { scale = 0; }
    return Math.round(scale * 100);
  }

  function filterSentence() {
    var parts = [];
    for (var k = 0; k < FILTER_ORDER.length; k++) {
      parts.push(FILTER_ORDER[k] + ' ' + barPercent(FILTER_ORDER[k]) + ' percent');
    }
    return 'Relative brightness through the filters, as a percentage of full scale: ' +
           parts.join(', ') + '.';
  }

  function updateDescriptions() {
    var z1   = state.z + REDSHIFT_OFFSET + 1;
    var text = zString();

    // Where the emitted 400 nm break and the emitted 656 nm H-alpha land now.
    var break400 = 400 * z1;
    var shown    = state.filtersAlpha > 0;

    graphDesc.textContent =
      'Flux plotted against observed wavelength. The horizontal axis runs from ' +
      nm(MIN_WAVELENGTH) + ' to ' + nm(MAX_WAVELENGTH) +
      ', labelled every 100 nanometers from 300 to 900 nanometers; the vertical axis is ' +
      'relative flux from 0 to 1.05. At redshift z equals ' + text +
      ', observed wavelengths are ' + z1.toFixed(4) + ' times the emitted wavelengths, so the ' +
      'sharp rise emitted at 400 nanometers now appears at ' + nm(break400, 1) + '. ' +
      'The galaxy spectrum spans ' + nm(specW(0) * z1, 0) + ' to ' +
      nm(specW(N_POINTS - 1) * z1, 0) + ' as observed. ' +
      'Filter bandpass curves for U, B, V and R are ' + (shown ? 'shown.' : 'hidden.');

    visDesc.textContent =
      'A strip showing how the galaxy\'s light appears across the visible band, ' +
      nm(VIS_MIN) + ' to ' + nm(VIS_MAX) + '. At redshift z equals ' + text +
      ', the strip is brightest near ' + nm(visBrightestW, 0) +
      ', in the ' + rampSegmentName(visBrightestW) + ' part of the visible band.';

    chartDesc.textContent = shown
      ? 'Bar chart of filter strengths. ' + filterSentence()
      : 'Bar chart of filter strengths. Hidden; select the show filter details button to reveal it.';
  }

  var lastAnnouncement = '';

  function announce(message) {
    // Nudge the live region when the text repeats so the reading is not skipped.
    if (message === lastAnnouncement) { message += ' '; }
    lastAnnouncement = message;
    liveStatus.textContent = message;
  }

  function zAnnouncement() {
    var z1 = state.z + REDSHIFT_OFFSET + 1;
    var msg = 'Redshift z equals ' + zString() +
              '. Light emitted at 400 nanometers is now observed at ' + nm(400 * z1, 1) + '.';
    if (state.filtersAlpha > 0 || state.showFilters) { msg += ' ' + filterSentence(); }
    return msg;
  }

  // ======================================================================
  // Controls
  // ======================================================================

  // Compared against on commit. A drag fires many `input` events and then one
  // `change`, so by the time `change` arrives state.z already holds the final
  // value — the announcement has to be gated on what was last SPOKEN, not on
  // whether this particular event changed the state.
  var lastAnnouncedZ = null;

  function setZ(value, announceChange) {
    var normalised = normaliseZ(value);
    if (normalised === null) { render(); return; }   // AS keeps the old value
    state.z = normalised;
    onZChanged();
    if (announceChange && normalised !== lastAnnouncedZ) {
      lastAnnouncedZ = normalised;
      announce(zAnnouncement());
    }
  }

  // Native range input: pointer, touch and the full keyboard set (arrows,
  // Page Up / Page Down, Home / End) all come for free and all land here.
  // `input` fires continuously during a drag and on every arrow press.
  zSlider.addEventListener('input', function () {
    setZ(parseFloat(zSlider.value), false);
  });

  // `change` is the commit: end of a drag, and each keyboard adjustment.
  // Announcing here rather than on every `input` keeps audio from flooding.
  zSlider.addEventListener('change', function () {
    setZ(parseFloat(zSlider.value), true);
  });

  // Numeric field: the original commits on Enter, on blur and on a click
  // elsewhere, and silently restores the old value for unparseable input.
  zInput.addEventListener('keydown', function (event) {
    if (event.key === 'Enter') {
      event.preventDefault();
      setZ(parseFloat(zInput.value), true);
      zInput.value = zString();
    }
  });
  zInput.addEventListener('blur', function () {
    setZ(parseFloat(zInput.value), true);
    zInput.value = zString();
  });

  filtersBtn.addEventListener('click', function () {
    setShowFilters(!isShowFilters(), true);           // GalacticRedshift.onShowHideFilters
    announce(isShowFilters()
      ? 'Filter details shown. ' + filterSentence()
      : 'Filter details hidden.');
  });

  // GalacticRedshift.reset() — wired to the masthead's bubbling sim-reset event.
  function reset(announceReset) {
    setShowFilters(false, false);
    state.z = 0;
    lastAnnouncedZ = 0;
    onZChanged();
    if (announceReset) {
      announce('Simulation reset. Redshift z equals 0.00. Filter details hidden.');
    }
  }

  document.addEventListener('sim-reset', function () { reset(true); });

  // ======================================================================
  // Tick marks — built in HTML so they zoom and can be MathJax-typeset
  // ======================================================================

  function buildTickmarks() {
    var scale     = 100 / (MAX_WAVELENGTH - MIN_WAVELENGTH);   // percent per nm
    var html      = '';
    var labelSeq  = 0;
    for (var i = 0; i < TICKMARKS.length; i++) {
      var tick    = TICKMARKS[i];
      var percent = scale * (tick.w - MIN_WAVELENGTH);
      var major   = tick.label !== undefined;
      html += '<span class="grs-tick' + (major ? ' grs-tick--major' : '') +
              '" style="left:' + percent + '%"></span>';
      if (major) {
        // "300 nm" etc. typeset by MathJax, matching the original's labels.
        // Every other label is tagged --minor so the narrow-screen stylesheet
        // can thin them out (300/500/700/900 survive) without losing any ticks.
        var minor = (labelSeq % 2 === 1) ? ' grs-tick__label--minor' : '';
        labelSeq++;
        html += '<span class="grs-tick__label' + minor + '" style="left:' + percent + '%">' +
                '\\(' + tick.w + '\\,\\mathrm{nm}\\)</span>';
      }
    }
    tickStrip.innerHTML = html;
  }

  // ======================================================================
  // Equation — rendered through the foundation's kl-unl.js helper
  // ======================================================================

  var EQN_LATEX =
    '\\[ z \\;=\\; \\frac{\\lambda_{\\text{observed}} - \\lambda_{\\text{emitted}}}' +
    '{\\lambda_{\\text{emitted}}} \\]';

  var EQN_SPOKEN =
    'The redshift z equals the observed wavelength minus the emitted wavelength, ' +
    'all divided by the emitted wavelength.';

  // Typeset the two things this file injects into the DOM: the equation, and
  // the wavelength tick labels built by buildTickmarks().
  //
  // Load order between the async MathJax bundle and this deferred script is
  // NOT guaranteed. If MathJax's pageReady hook wins the race it calls
  // kl-unl.js's *stub* klunlInitEqn (so this file's equation is never set) and
  // its initial page typeset happens before the tick strip exists (so the
  // labels are left showing raw "\(300\,\mathrm{nm}\)"). Both symptoms were
  // observed. The fix is to be driven by MathJax's own startup promise as well
  // as by the pageReady call, and to make the work idempotent so whichever
  // fires first — or both — leaves the same result.
  // Only the tick strip is typeset here. The equation is left to
  // klunlShowEquation, which sets its LaTeX and typesets it itself — running a
  // second typesetPromise over the same container while the first is still in
  // flight makes MathJax render the equation twice.
  function typesetTickmarks() {
    var mj = window.MathJax;
    if (!mj || typeof mj.typesetPromise !== 'function') { return; }
    // Only hand MathJax the labels it has not already done. Which labels those
    // are depends on who won the load-order race: if this script ran first the
    // labels were in the DOM for MathJax's own page-wide pass and are already
    // typeset, and running them again renders every label twice.
    var pending = [].slice.call(tickStrip.querySelectorAll('.grs-tick__label'))
      .filter(function (el) { return !el.querySelector('mjx-container'); });
    if (!pending.length) { return; }
    mj.typesetPromise(pending).catch(function (err) { console.error(err); });
  }

  // kl-unl.js defines klunlInitEqn as a stub and index.html calls it from
  // MathJax's pageReady hook; redefining it here supersedes that stub.
  //
  // Both the pageReady hook and the startup.promise fallback at the bottom of
  // this file may call it — whichever wins the load-order race — so it must run
  // exactly once. Without the guard the equation is typeset twice over.
  var mathInitDone = false;

  window.klunlInitEqn = function () {
    if (mathInitDone) { return; }
    mathInitDone = true;
    if (typeof window.klunlShowEquation === 'function') {
      window.klunlShowEquation(['eqnRedshift', EQN_LATEX], ['eqnRedshiftSR', EQN_SPOKEN]);
    }
    typesetTickmarks();
  };

  // Typeset math is display-only. MathJax containers created after the initial
  // page typeset (the equation above) must also stay out of the Tab order.
  if (window.MutationObserver) {
    new window.MutationObserver(function (records) {
      for (var i = 0; i < records.length; i++) {
        var added = records[i].addedNodes;
        for (var j = 0; j < added.length; j++) {
          var node = added[j];
          if (node.nodeType !== 1) { continue; }
          if (node.tagName && node.tagName.toLowerCase() === 'mjx-container') {
            node.setAttribute('tabindex', '-1');
          } else if (node.querySelectorAll) {
            var inner = node.querySelectorAll('mjx-container');
            for (var k = 0; k < inner.length; k++) { inner[k].setAttribute('tabindex', '-1'); }
          }
        }
      }
    }).observe(document.body, { childList: true, subtree: true });
  }

  // ======================================================================
  // Start-up
  // ======================================================================

  function redrawEverything() {
    sizeCanvases();
    drawVisualization();
    drawFilterBuffer();
    render();
  }

  buildTickmarks();
  sizeCanvases();
  reset(false);        // addEventListener(Event.ADDED_TO_STAGE, this.reset)

  // If MathJax already finished starting up (its pageReady ran before this
  // deferred script), startup.promise exists and pageReady has already called
  // the stub — so drive the equation and the tick labels from here instead.
  // If MathJax has not loaded yet, window.MathJax is still just the config
  // object with no startup, and the pageReady hook will call klunlInitEqn.
  if (window.MathJax && window.MathJax.startup && window.MathJax.startup.promise) {
    window.MathJax.startup.promise
      .then(function () { window.klunlInitEqn(); })
      .catch(function (err) { console.error(err); });
  }

  // Keep the backing resolution matched to the display when the page is
  // resized, zoomed, or moved between screens of different densities.
  var resizeTimer = null;
  window.addEventListener('resize', function () {
    if (resizeTimer !== null) { window.clearTimeout(resizeTimer); }
    resizeTimer = window.setTimeout(function () {
      resizeTimer = null;
      redrawEverything();
    }, 150);
  });

  // If the user turns reduced motion on mid-session, land on the end state.
  if (reduceMotion.addEventListener) {
    reduceMotion.addEventListener('change', function () {
      if (reduceMotion.matches) { setShowFilters(state.showFilters, false); }
    });
  }
})();
