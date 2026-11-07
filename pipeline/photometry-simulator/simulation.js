/* ==========================================================================
   Photometry Simulator — HTML5 port of the Flash (AS3) original.

   Behavior ground truth: the decompiled ActionScript in scripts/
     - photometrySimulator_fla/MainTimeline.as  (wiring, constants, stats)
     - edu/unl/astro/starField/StarField.as     (noise, chunk shuffle, stars)
     - edu/unl/astro/starField/AiryDisc.as      (PSF, Bessel J1)
     - edu/unl/astro/starField/GammaTransferFunction.as
     - edu/unl/astro/starField/PixelMask.as
     - PixelMaskProxy.as                        (aperture drag + outline trace)
     - PixelDisplay.as                          (zoom windows, active pixel)

   All constants, formulas and number formatting are copied verbatim.
   One plain state object; a single render() redraws everything from state.
   ========================================================================== */
'use strict';

(function () {

  // ======================================================================
  // Constants — verbatim from MainTimeline.frame1()
  // ======================================================================

  var STARS_LIST = [
    { magnitude: 2.5,  x: 132, y: 265 },
    { magnitude: 3.42, x: 113, y: 186 },
    { magnitude: 3.77, x: 279, y: 262 },
    { magnitude: 3.89, x: 170, y: 52  },
    { magnitude: 3.89, x: 359, y: 129 },
    { magnitude: 3.97, x: 41,  y: 72  },
    { magnitude: 4.02, x: 121, y: 26  },
    { magnitude: 4.15, x: 169, y: 204 },
    { magnitude: 4.2,  x: 348, y: 33  },
    { magnitude: 4.23, x: 29,  y: 157 },
    { magnitude: 4.26, x: 195, y: 210 },
    { magnitude: 4.3,  x: 82,  y: 66  },
    { magnitude: 4.46, x: 43,  y: 26  },
    { magnitude: 4.57, x: 287, y: 41  },
    { magnitude: 4.73, x: 129, y: 105 },
    { magnitude: 4.78, x: 239, y: 225 },
    { magnitude: 4.85, x: 301, y: 185 },
    { magnitude: 4.89, x: 62,  y: 255 },
    { magnitude: 4.89, x: 57,  y: 192 },
    { magnitude: 5.02, x: 47,  y: 126 },
    { magnitude: 5.02, x: 342, y: 272 },
    { magnitude: 5.24, x: 278, y: 135 },
    { magnitude: 5.78, x: 217, y: 22  },
    { magnitude: 5.87, x: 259, y: 147 },
    { magnitude: 6.2,  x: 341, y: 215 }
  ];

  var ZOOM_DIMENSIONS   = 23;
  var ZOOM_WINDOW_SIZE  = 8 * ZOOM_DIMENSIONS;                          // 184
  var PSF_RADIUS        = 4;
  var INNER_RADIUS      = 5;
  var OUTER_RADIUS      = 2 * INNER_RADIUS;                             // 10
  var INNER_ZOOM_OFFSET = (ZOOM_DIMENSIONS - (2 * INNER_RADIUS + 1)) / 2; // 6
  var OUTER_ZOOM_OFFSET = (ZOOM_DIMENSIONS - (2 * OUTER_RADIUS + 1)) / 2; // 1

  var FIELD_WIDTH  = 400;   // starField.dimensions
  var FIELD_HEIGHT = 300;
  var NOISE_MEAN   = 2318;
  var NOISE_SIGMA  = 426;
  var SATURATION_MAGNITUDE = 3;
  var BIT_DEPTH    = 16;    // StarField constructor default
  var PEAK_VALUE   = Math.pow(2, BIT_DEPTH) - 1;                       // 65535
  var GAMMA        = 1.8;   // GammaTransferFunction default

  // outOfBoundsColor = 2163931898 = 0x80FAFAFA (ARGB; PixelDisplay draws with
  // alpha = 1 - (a>>24)/255, so the high byte 0x80 means ~50% transparent)
  var OOB_RGB   = 0xFAFAFA;
  var OOB_ALPHA = 1 - ((2163931898 >>> 24) & 0xFF) / 255;

  var AP1_COLOR = 0x60C060; // innerAperture1 outlineColor 6340704
  var AP2_COLOR = 0xF0A000; // innerAperture2 outlineColor 15769600
  var ACTIVE_PIXEL_COLOR = 0x9090FF;  // activePixelOutlineColor 9474303
  var ACTIVE_PIXEL_THICKNESS = 2;     // activePixelOutlineThickness

  // Initial aperture positions: stage (210,250)/(100,100) minus the star
  // field's stage offset (14,62) => field coordinates.
  var AP1_INIT = { cx: 210 - 14, cy: 250 - 62 };  // (196, 188)
  var AP2_INIT = { cx: 100 - 14, cy: 100 - 62 };  // (86, 38)

  var CANVAS_SCALE = 2;   // backing-store multiplier for crisp rendering only

  // ======================================================================
  // AiryDisc PSF — verbatim port of AiryDisc.as (radius 4)
  // ======================================================================

  function makeAiryDisc(radius) {
    // Numerical-Recipes style rational approximation of Bessel J1
    function getJ1(x) {
      var ax = Math.abs(x), y, num, den, ans, z, xx;
      if (ax < 8) {
        y   = x * x;
        num = x * (72362614232 + y * (-7895059235 + y * (242396853.1 + y * (-2972611.439 + y * (15704.4826 + y * -30.16036606)))));
        den = 144725228442 + y * (2300535178 + y * (18583304.74 + y * (99447.43394 + y * (376.9991397 + y * 1))));
        ans = num / den;
      } else {
        z   = 8 / ax;
        y   = z * z;
        xx  = ax - 2.356194491;
        num = 1 + y * (0.00183105 + y * (-0.00003516396496 + y * (0.000002457520174 + y * -2.40337019e-7)));
        den = 0.04687499995 + y * (-0.0002002690873 + y * (0.000008449199096 + y * (-8.8228987e-7 + y * 1.05787412e-7)));
        ans = Math.sqrt(0.636619772 / ax) * (Math.cos(xx) * num - z * Math.sin(xx) * den);
        if (x < 0) { ans = -ans; }
      }
      return ans;
    }

    var size   = 2 * radius - 1;
    var center = radius - 1;
    var data   = [];
    var i, j, r1, r2, rsq, j1, v;
    var k = 3.831705970256774 / radius;   // first zero of J1 over the radius
    for (i = 0; i < size; i++) { data[i] = []; }
    for (i = 0; i < radius; i++) {
      r1 = k * i;
      for (j = 0; j <= i; j++) {
        r2  = k * j;
        rsq = r1 * r1 + r2 * r2;
        if (rsq >= 14.681970642501405) {
          v = 0;
        } else {
          j1 = getJ1(Math.sqrt(rsq));
          v  = 4 * j1 * j1 / rsq;        // Airy pattern: (2 J1(r)/r)^2
        }
        data[center + i][center - j] = v;
        data[center + j][center - i] = v;
        data[center - j][center - i] = v;
        data[center - i][center - j] = v;
        data[center - i][center + j] = v;
        data[center - j][center + i] = v;
        data[center + j][center + i] = v;
        data[center + i][center + j] = v;
      }
    }
    data[center][center] = 1;
    return { data: data, width: size, height: size, x: center, y: center };
  }

  // ======================================================================
  // GammaTransferFunction — verbatim port (gamma 1.8, not inverted)
  // ======================================================================

  var greyTable = (function () {
    var table = new Uint8Array(PEAK_VALUE + 1);
    for (var v = 0; v <= PEAK_VALUE; v++) {
      // int cast in AS truncates: _loc1_:int = 255 * pow(v/peak, 1/gamma)
      table[v] = (255 * Math.pow(v / PEAK_VALUE, 1 / GAMMA)) | 0;
    }
    return table;
  })();

  // ======================================================================
  // PixelMask — verbatim port (boolean disc, includes dx^2+dy^2 <= r^2)
  // ======================================================================

  function makePixelMask(radius) {
    var size = 2 * radius + 1, rsq = radius * radius;
    var data = [], i, j, dx, dy;
    for (i = 0; i < size; i++) {
      dx = -radius + i;
      data[i] = [];
      for (j = 0; j < size; j++) {
        dy = -radius + j;
        data[i][j] = (dx * dx + dy * dy) <= rsq;
      }
    }
    return { radius: radius, width: size, height: size, data: data };
  }

  // ======================================================================
  // Aperture outline trace — verbatim port of PixelMaskProxy.redrawOutline
  // Walks the pixel boundary of the mask, producing lattice points in mask
  // coordinates (0 .. 2r+1). Drawn at (point - radius) around the center.
  // ======================================================================

  function traceOutline(mask) {
    var w = mask.width, h = mask.height, d = mask.data;
    var cx = 0, cy = 0, i;
    outer:
    for (cx = 0; cx < w; cx++) {
      for (cy = 0; cy < h; cy++) {
        if (d[cx][cy]) { break outer; }
      }
    }
    var startX = cx, startY = cy;
    var dir = 0, points = [{ x: cx, y: cy }];
    var ax, ay, bx, by, aIn, bIn, step, turn;
    for (step = 0; step < 1000; step++) {
      dir = (dir + 2) % 4;
      for (turn = 0; turn < 4; turn++) {
        dir = (dir + 1) % 4;
        switch (dir) {
          case 0: ax = cx - 1; ay = cy - 1; bx = cx;     by = cy - 1; break;
          case 1: ax = cx;     ay = cy - 1; bx = cx;     by = cy;     break;
          case 2: ax = cx;     ay = cy;     bx = cx - 1; by = cy;     break;
          default: ax = cx - 1; ay = cy;    bx = cx - 1; by = cy - 1; break;
        }
        aIn = !(ax < 0 || ax >= w || ay < 0 || ay >= h);
        bIn = !(bx < 0 || bx >= w || by < 0 || by >= h);
        if (aIn && bIn && (d[ax][ay] !== d[bx][by])) { break; }
        if (aIn && !bIn && d[ax][ay]) { break; }
        if (!aIn && bIn && d[bx][by]) { break; }
      }
      if (dir === 0)      { cy--; }
      else if (dir === 1) { cx++; }
      else if (dir === 2) { cy++; }
      else                { cx--; }
      points.push({ x: cx, y: cy });
      if (cx === startX && cy === startY) { break; }
    }
    return points;
  }

  // ======================================================================
  // StarField — noise generation, chunk shuffle, star flux (verbatim math).
  // The field never changes after construction in this sim (epoch and
  // noiseSeed are never touched by MainTimeline), so it is computed once.
  // ======================================================================

  var field = (function () {
    // dimensions setter: _numChunks:int = 0.7*width; chunkSize = ceil(w*h/n),
    // bumped to even
    var numChunks = (0.7 * FIELD_WIDTH) | 0;                          // 280
    var chunkSize = Math.ceil(FIELD_WIDTH * FIELD_HEIGHT / numChunks);
    if (chunkSize % 2 === 1) { chunkSize += 1; }                      // 430
    var total = numChunks * chunkSize;

    // generateNoise(): Lehmer LCG (x -> x*16807 mod 2^31-1) starting at 1,
    // polar Box-Muller pairs: value = mean + sigma * v * sqrt(-2 ln s / s)
    var noiseData = new Float64Array(total);
    var seed = 1, v1, v2, s, n = 0;
    while (n < total) {
      do {
        v1 = 2 * (seed / 2147483647) - 1;
        seed = seed * 16807 % 2147483647;
        v2 = 2 * (seed / 2147483647) - 1;
        seed = seed * 16807 % 2147483647;
        s = v1 * v1 + v2 * v2;
      } while (s >= 1);
      s = Math.sqrt(-2 * Math.log(s) / s);
      noiseData[n] = NOISE_MEAN + NOISE_SIGMA * v1 * s;
      n++;
      noiseData[n] = NOISE_MEAN + NOISE_SIGMA * v2 * s;
      n++;
    }

    // shuffleNoise(): permute chunk table with the same LCG, seed 1
    var chunkTable = new Int32Array(numChunks);
    var i, j, t;
    for (i = 0; i < numChunks; i++) { chunkTable[i] = i; }
    var sseed = 1;   // _shuffleSeed (never reseeded in this sim)
    for (i = 0; i < numChunks - 1; i++) {
      j = i + (((numChunks - i) * (sseed / 2147483647)) | 0);
      sseed = sseed * 16807 % 2147483647;
      t = chunkTable[j];
      chunkTable[j] = chunkTable[i];
      chunkTable[i] = t;
    }

    // update(): fieldData = noiseData copy, then add each star's PSF flux
    // through the chunk indirection.
    // flux = peakValue * 10^((saturationMagnitude - magnitude)/2.5)
    var fieldData = Float64Array.from(noiseData);
    var psf = makeAiryDisc(PSF_RADIUS);
    STARS_LIST.forEach(function (star) {
      var flux = PEAK_VALUE * Math.pow(10, (SATURATION_MAGNITUDE - star.magnitude) / 2.5);
      var x0 = star.x - psf.x, y0 = star.y - psf.y;
      var px, py, col, val, idx, chunk, off, ii, jj;
      for (ii = 0; ii < psf.width; ii++) {
        px = x0 + ii;
        if (px >= 0) {
          if (px >= FIELD_WIDTH) { break; }
          col = psf.data[ii];
          for (jj = 0; jj < psf.height; jj++) {
            py = y0 + jj;
            val = col[jj];
            if (!(val <= 0 || py < 0)) {
              if (py >= FIELD_HEIGHT) { break; }
              idx   = px + py * FIELD_WIDTH;
              chunk = (idx / chunkSize) | 0;
              off   = idx - chunk * chunkSize;
              fieldData[off + chunkSize * chunkTable[chunk]] += flux * val;
            }
          }
        }
      }
    });

    // Raw (float, unclamped) value at field pixel (x, y), via indirection
    function rawValue(x, y) {
      var idx   = x + y * FIELD_WIDTH;
      var chunk = (idx / chunkSize) | 0;
      var off   = idx - chunk * chunkSize;
      return fieldData[off + chunkSize * chunkTable[chunk]];
    }

    function clamped(v) {
      if (v < 0) { return 0; }
      if (v > PEAK_VALUE) { return PEAK_VALUE; }
      return v;
    }

    return {
      // StarField.getStatistics(mask at left/top): totals use uint(clamped)
      getStatistics: function (mask, left, top) {
        var totalCounts = 0, totalPixels = 0, clippedFlag = false;
        var i, j, px, py, v;
        for (i = 0; i < mask.width; i++) {
          px = left + i;
          if (px < 0) { clippedFlag = true; continue; }
          if (px >= FIELD_WIDTH) { clippedFlag = true; break; }
          for (j = 0; j < mask.height; j++) {
            py = top + j;
            if (py < 0) { clippedFlag = true; continue; }
            if (py >= FIELD_HEIGHT) { clippedFlag = true; break; }
            if (mask.data[i][j]) {
              v = clamped(rawValue(px, py));
              totalCounts += Math.floor(v);   // uint() cast
              totalPixels++;
            }
          }
        }
        return {
          totalCounts: totalCounts,
          totalPixels: totalPixels,
          clipped: clippedFlag,
          average: totalCounts / totalPixels
        };
      },

      // StarField.getPixelInfo: counts int, -1 out of bounds
      getPixelInfo: function (x, y) {
        if (x < 0 || x >= FIELD_WIDTH || y < 0 || y >= FIELD_HEIGHT) {
          return { counts: -1 };
        }
        return { counts: Math.floor(clamped(rawValue(x, y))) };
      },

      // StarField.getPixelColors equivalent: grey level + alpha per cell
      getCell: function (x, y) {
        if (x < 0 || x >= FIELD_WIDTH || y < 0 || y >= FIELD_HEIGHT) {
          return { grey: -1 };   // out of bounds marker
        }
        return { grey: greyTable[Math.floor(clamped(rawValue(x, y)))] };
      },

      rawValue: rawValue,
      clamped: clamped
    };
  })();

  // ======================================================================
  // Masks and outlines (shared by both apertures)
  // ======================================================================

  var innerMask    = makePixelMask(INNER_RADIUS);
  var outerMask    = makePixelMask(OUTER_RADIUS);
  var innerOutline = traceOutline(innerMask);
  var outerOutline = traceOutline(outerMask);

  // ======================================================================
  // State — single source of truth
  // ======================================================================

  var state = {
    apertures: {
      1: { cx: AP1_INIT.cx, cy: AP1_INIT.cy, color: AP1_COLOR, colorCSS: '#60c060', lum: 1 },
      2: { cx: AP2_INIT.cx, cy: AP2_INIT.cy, color: AP2_COLOR, colorCSS: '#f0a000', lum: 1 }
    },
    zOrder: [1, 2],          // last entry drawn on top (original setChildIndex)
    showLabels: false,       // showLabelsCheckBox.selected = false
    // active pixel per zoom window; (-1,-1) = none (PixelDisplay._activePixel)
    active: {
      1: { x: -1, y: -1 },
      2: { x: -1, y: -1 }
    },
    stats: { 1: null, 2: null }
  };

  // ======================================================================
  // DOM references
  // ======================================================================

  var $ = function (id) { return document.getElementById(id); };

  var fieldCanvas = $('fieldCanvas');
  var fieldCtx    = fieldCanvas.getContext('2d');
  var zoomCanvas  = { 1: $('zoomCanvas1'), 2: $('zoomCanvas2') };
  var zoomCtx     = { 1: zoomCanvas[1].getContext('2d'), 2: zoomCanvas[2].getContext('2d') };
  var zoomProxy   = { 1: $('zoom1Focus'), 2: $('zoom2Focus') };
  var apProxy     = { 1: $('ap1Proxy'), 2: $('ap2Proxy') };
  var apLabel     = { 1: $('ap1Label'), 2: $('ap2Label') };
  var pixelInfoEl = { 1: $('pixelInfo1'), 2: $('pixelInfo2') };
  var checkbox    = $('showLabelsCheckBox');
  var liveRegion  = $('liveRegion');
  var fieldDesc   = $('fieldDesc');

  var infoFields = {
    1: {
      cx: $('ap1cx'), cy: $('ap1cy'),
      innerPixels: $('ap1InnerPixels'), innerCounts: $('ap1InnerCounts'), innerAvg: $('ap1InnerAvg'),
      outerPixels: $('ap1OuterPixels'), outerCounts: $('ap1OuterCounts'), outerAvg: $('ap1OuterAvg'),
      pix: $('pi1x'), piy: $('pi1y'), picounts: $('pi1counts')
    },
    2: {
      cx: $('ap2cx'), cy: $('ap2cy'),
      innerPixels: $('ap2InnerPixels'), innerCounts: $('ap2InnerCounts'), innerAvg: $('ap2InnerAvg'),
      outerPixels: $('ap2OuterPixels'), outerCounts: $('ap2OuterCounts'), outerAvg: $('ap2OuterAvg'),
      pix: $('pi2x'), piy: $('pi2y'), picounts: $('pi2counts')
    }
  };

  // ======================================================================
  // Star field bitmap (computed once — the field itself never changes)
  // ======================================================================

  var fieldBitmap = (function () {
    var off = document.createElement('canvas');
    off.width  = FIELD_WIDTH;
    off.height = FIELD_HEIGHT;
    var ctx = off.getContext('2d');
    var img = ctx.createImageData(FIELD_WIDTH, FIELD_HEIGHT);
    var d = img.data, x, y, g, p = 0;
    for (y = 0; y < FIELD_HEIGHT; y++) {
      for (x = 0; x < FIELD_WIDTH; x++) {
        g = greyTable[Math.floor(field.clamped(field.rawValue(x, y)))];
        d[p++] = g; d[p++] = g; d[p++] = g; d[p++] = 255;
      }
    }
    ctx.putImageData(img, 0, 0);
    return off;
  })();

  // Checkerboard pattern for the zoom-window background
  // (PixelDisplay.redrawBackground: 4x4 bitmap, 2x2 blocks of A0A0A0/DADADA)
  var checkerPattern = (function () {
    var off = document.createElement('canvas');
    off.width = 4; off.height = 4;
    var ctx = off.getContext('2d');
    ctx.fillStyle = '#a0a0a0';
    ctx.fillRect(0, 0, 2, 2); ctx.fillRect(2, 2, 2, 2);
    ctx.fillStyle = '#dadada';
    ctx.fillRect(2, 0, 2, 2); ctx.fillRect(0, 2, 2, 2);
    return off;
  })();

  // ======================================================================
  // Statistics + readouts — verbatim port of MainTimeline.updateAperture
  // ======================================================================

  function computeAperture(id) {
    var ap = state.apertures[id];
    var cx = ap.cx, cy = ap.cy;
    var innerLeft = cx - INNER_RADIUS, innerTop = cy - INNER_RADIUS;
    var outerLeft = cx - OUTER_RADIUS, outerTop = cy - OUTER_RADIUS;

    var innerStats = field.getStatistics(innerMask, innerLeft, innerTop);
    var outerStats = field.getStatistics(outerMask, outerLeft, outerTop);
    outerStats.totalCounts -= innerStats.totalCounts;
    outerStats.totalPixels -= innerStats.totalPixels;
    outerStats.average = outerStats.totalCounts / outerStats.totalPixels;

    // Sky-subtracted flux: lum = counts_disc - numPixels_disc * average_ring
    ap.lum = innerStats.totalCounts - innerStats.totalPixels * outerStats.average;
    state.stats[id] = { cx: cx, cy: cy, inner: innerStats, outer: outerStats };
  }

  function deltaMag() {
    // m1 - m2 = -2.5 * log10(f1 / f2)
    return -2.5 * Math.log(state.apertures[1].lum / state.apertures[2].lum) / Math.LN10;
  }

  // ======================================================================
  // Equations (MathJax via the foundation's klunlShowEquation)
  // ======================================================================

  var lastEqnKey = null;

  function updateEquations(force) {
    var f1 = state.apertures[1].lum.toFixed(2);
    var f2 = state.apertures[2].lum.toFixed(2);
    var dm = deltaMag();
    var dmText = (isNaN(dm) || !isFinite(dm)) ? '...' : dm.toFixed(2);
    var key = f1 + '|' + f2 + '|' + dmText;
    if (!force && key === lastEqnKey) { return; }
    lastEqnKey = key;

    // Words and numbers use MathJax's own sans-serif font (\mathsf): exact
    // glyph metrics (no system-font width guessing, which left uneven gaps),
    // and it visually matches the page's sans-serif UI. Negative values get
    // a real math minus sign (not a short text hyphen). Each equation is a
    // single line, value included, as in the original.
    function latexNum(s) {
      return s.charAt(0) === '-' ? '-\\mathsf{' + s.slice(1) + '}' : '\\mathsf{' + s + '}';
    }
    var dmLatex = dmText === '...' ? '\\ldots' : latexNum(dmText);

    klunlShowEquation(
      ['eqnF1',
       '\\[ \\textit{f}_{\\mathsf{1}} = \\mathsf{counts}_{\\mathsf{disc\\ 1}} - \\mathsf{numPixels}_{\\mathsf{disc\\ 1}} \\times \\mathsf{average}_{\\mathsf{ring\\ 1}} = ' + latexNum(f1) + ' \\]'],
      ['eqnF1SR',
       'f 1 equals counts in disc 1 minus numPixels in disc 1 times average in ring 1, equals ' + f1 + ' counts.']
    );
    klunlShowEquation(
      ['eqnF2',
       '\\[ \\textit{f}_{\\mathsf{2}} = \\mathsf{counts}_{\\mathsf{disc\\ 2}} - \\mathsf{numPixels}_{\\mathsf{disc\\ 2}} \\times \\mathsf{average}_{\\mathsf{ring\\ 2}} = ' + latexNum(f2) + ' \\]'],
      ['eqnF2SR',
       'f 2 equals counts in disc 2 minus numPixels in disc 2 times average in ring 2, equals ' + f2 + ' counts.']
    );
    klunlShowEquation(
      ['eqnDeltaMag',
       '\\[ \\textit{m}_{\\mathsf{1}} - \\textit{m}_{\\mathsf{2}} = -\\mathsf{2.5} \\times \\mathsf{log}_{\\mathsf{10}}\\!\\left(\\frac{\\textit{f}_{\\mathsf{1}}}{\\textit{f}_{\\mathsf{2}}}\\right) = ' + dmLatex + ' \\]'],
      ['eqnDeltaMagSR',
       'm 1 minus m 2 equals negative 2.5 times log base 10 of f 1 over f 2, equals ' +
       (dmText === '...' ? 'not defined (the flux ratio is not positive).' : dmText + ' magnitudes.')]
    );
  }

  // Typeset math is display-only, not a control: keep every mjx-container out
  // of the Tab order, including ones MathJax re-creates on each re-typeset.
  new MutationObserver(function () {
    document.querySelectorAll('mjx-container:not([tabindex="-1"])')
      .forEach(function (el) { el.setAttribute('tabindex', '-1'); });
  }).observe(document.body, { childList: true, subtree: true });

  // Redefine the foundation hook: called by MathJax pageReady once the
  // library is loaded, so equations set before load get typeset.
  window.klunlInitEqn = function () {
    updateEquations(true);
  };

  // ======================================================================
  // Rendering
  // ======================================================================

  function drawOutlinePath(ctx, points, centerX, centerY, radius, scale, xOff, yOff) {
    ctx.beginPath();
    for (var i = 0; i < points.length; i++) {
      var px = (points[i].x + xOff - radius) * scale + centerX;
      var py = (points[i].y + yOff - radius) * scale + centerY;
      if (i === 0) { ctx.moveTo(px, py); } else { ctx.lineTo(px, py); }
    }
    ctx.stroke();
  }

  function renderField() {
    var ctx = fieldCtx;
    ctx.setTransform(CANVAS_SCALE, 0, 0, CANVAS_SCALE, 0, 0);
    ctx.imageSmoothingEnabled = false;
    ctx.clearRect(0, 0, FIELD_WIDTH, FIELD_HEIGHT);
    ctx.drawImage(fieldBitmap, 0, 0);

    // Aperture outlines (inner + outer share one color per aperture);
    // z-order: last dragged on top, matching parent.setChildIndex.
    state.zOrder.forEach(function (id) {
      var ap = state.apertures[id];
      ctx.strokeStyle = ap.colorCSS;
      ctx.lineWidth = 1;   // Flash hairline (lineStyle thickness 0)
      drawOutlinePath(ctx, innerOutline, ap.cx, ap.cy, INNER_RADIUS, 1, 0, 0);
      drawOutlinePath(ctx, outerOutline, ap.cx, ap.cy, OUTER_RADIUS, 1, 0, 0);
    });
  }

  function renderZoom(id) {
    var ctx = zoomCtx[id];
    var ap  = state.apertures[id];
    // Zoom rect origin in field coords (MainTimeline.updateAperture):
    // outerPixelMask.left - outerZoomOffset = cx - 10 - 1 = cx - 11
    var ox = ap.cx - OUTER_RADIUS - OUTER_ZOOM_OFFSET;
    var oy = ap.cy - OUTER_RADIUS - OUTER_ZOOM_OFFSET;
    var cell = ZOOM_WINDOW_SIZE / ZOOM_DIMENSIONS;   // 8

    ctx.setTransform(CANVAS_SCALE, 0, 0, CANVAS_SCALE, 0, 0);

    // Checkerboard background (shows through semi-transparent OOB cells)
    if (!ctx._checker) { ctx._checker = ctx.createPattern(checkerPattern, 'repeat'); }
    ctx.fillStyle = ctx._checker;
    ctx.fillRect(0, 0, ZOOM_WINDOW_SIZE, ZOOM_WINDOW_SIZE);

    // Pixel cells
    var i, j, c, hex;
    for (i = 0; i < ZOOM_DIMENSIONS; i++) {
      for (j = 0; j < ZOOM_DIMENSIONS; j++) {
        c = field.getCell(ox + i, oy + j);
        if (c.grey === -1) {
          ctx.globalAlpha = OOB_ALPHA;
          ctx.fillStyle = '#fafafa';
        } else {
          ctx.globalAlpha = 1;
          hex = c.grey.toString(16).padStart(2, '0');
          ctx.fillStyle = '#' + hex + hex + hex;
        }
        ctx.fillRect(i * cell, j * cell, cell, cell);
      }
    }
    ctx.globalAlpha = 1;

    // Aperture outline markings (drawAperturesInZoomWindows): the zoom rect
    // tracks the aperture, so the outlines sit at fixed offsets.
    ctx.strokeStyle = ap.colorCSS;
    ctx.lineWidth = 1;
    drawOutlinePath(ctx, outerOutline, 0, 0, 0, cell, OUTER_ZOOM_OFFSET, OUTER_ZOOM_OFFSET);
    drawOutlinePath(ctx, innerOutline, 0, 0, 0, cell, INNER_ZOOM_OFFSET, INNER_ZOOM_OFFSET);

    // Active pixel outline (PixelDisplay.drawPixelOutline)
    var apx = state.active[id];
    if (apx.x !== -1) {
      ctx.strokeStyle = '#9090ff';
      ctx.lineWidth = ACTIVE_PIXEL_THICKNESS;
      ctx.strokeRect(apx.x * cell, apx.y * cell, cell, cell);
    }
  }

  function positionProxy(id) {
    var ap = state.apertures[id];
    var proxy = apProxy[id];
    // Proxy box covers the outer disc (21x21 field pixels)
    var size = 2 * OUTER_RADIUS + 1;
    proxy.style.left   = ((ap.cx - OUTER_RADIUS) / FIELD_WIDTH * 100) + '%';
    proxy.style.top    = ((ap.cy - OUTER_RADIUS) / FIELD_HEIGHT * 100) + '%';
    proxy.style.width  = (size / FIELD_WIDTH * 100) + '%';
    proxy.style.height = (size / FIELD_HEIGHT * 100) + '%';
    // last-dragged aperture on top for pointer hits (parent.setChildIndex)
    proxy.style.zIndex = String(2 + state.zOrder.indexOf(id));
    proxy.setAttribute('aria-label',
      'Aperture ' + id + ', center x ' + ap.cx + ', center y ' + ap.cy +
      ' pixels. Use the arrow keys to move it.');
  }

  function updateReadouts(id) {
    var st = state.stats[id];
    var f = infoFields[id];
    // Field text verbatim formatting (toString / toFixed(2))
    f.cx.textContent = String(st.cx);
    f.cy.textContent = String(st.cy);
    f.innerPixels.textContent = String(st.inner.totalPixels);
    f.innerCounts.textContent = String(st.inner.totalCounts);
    f.innerAvg.textContent    = st.inner.average.toFixed(2);
    f.outerPixels.textContent = String(st.outer.totalPixels);
    f.outerCounts.textContent = String(st.outer.totalCounts);
    f.outerAvg.textContent    = st.outer.average.toFixed(2);
  }

  // Port of MainTimeline.updatePixelInfo (tooltip + cross-window clearing)
  function updatePixelInfo(id) {
    var other = id === 1 ? 2 : 1;
    var act = state.active[id];
    if (act.x !== -1) {
      var ap = state.apertures[id];
      // field pixel = innerMask.left - innerZoomOffset + activePixel
      var px = (ap.cx - INNER_RADIUS) - INNER_ZOOM_OFFSET + act.x;
      var py = (ap.cy - INNER_RADIUS) - INNER_ZOOM_OFFSET + act.y;
      var info = field.getPixelInfo(px, py);
      var f = infoFields[id];
      f.pix.textContent = String(px);
      f.piy.textContent = String(py);
      f.picounts.textContent = info.counts !== -1 ? String(info.counts) : '...';

      // Anchor tail tip at (x + 0.5, y) of the active cell, in % of window
      var el = pixelInfoEl[id];
      el.style.left = ((act.x + 0.5) / ZOOM_DIMENSIONS * 100) + '%';
      el.style.top  = (act.y / ZOOM_DIMENSIONS * 100) + '%';
      el.hidden = false;

      // Setting a pixel in one window clears the other (original behavior)
      if (state.active[other].x !== -1) {
        state.active[other] = { x: -1, y: -1 };
        renderZoom(other);
      }
      pixelInfoEl[other].hidden = true;

      announcePixel(id, px, py, info.counts);
    } else if (state.active[other].x === -1) {
      pixelInfoEl[1].hidden = true;
      pixelInfoEl[2].hidden = true;
    } else {
      pixelInfoEl[id].hidden = true;
    }
    updateZoomProxyLabel(id);
  }

  function updateZoomProxyLabel(id) {
    var act = state.active[id];
    var base = 'Aperture ' + id + ' zoom window. Use the arrow keys to inspect individual pixels.';
    if (act.x !== -1) {
      var ap = state.apertures[id];
      var px = (ap.cx - INNER_RADIUS) - INNER_ZOOM_OFFSET + act.x;
      var py = (ap.cy - INNER_RADIUS) - INNER_ZOOM_OFFSET + act.y;
      var info = field.getPixelInfo(px, py);
      base = 'Aperture ' + id + ' zoom window. Selected pixel x ' + px + ', y ' + py + ': ' +
             (info.counts !== -1 ? info.counts + ' counts.' : 'outside the star field, counts not available.');
    }
    zoomProxy[id].setAttribute('aria-label', base);
  }

  function updateFieldDescription() {
    var a1 = state.apertures[1], a2 = state.apertures[2];
    fieldDesc.textContent =
      'A 400 by 300 pixel CCD image of a star field containing 25 stars of different brightnesses on a noisy dark background. ' +
      'Aperture 1 (green) is centered at x ' + a1.cx + ', y ' + a1.cy + ' pixels. ' +
      'Aperture 2 (orange) is centered at x ' + a2.cx + ', y ' + a2.cy + ' pixels. ' +
      'Each aperture is an inner measurement disc of radius 5 pixels inside an outer sky ring of radius 10 pixels.';
  }

  // MainTimeline.updateAperture equivalent (stats + readouts + zoom + eqns)
  function updateAperture(id) {
    computeAperture(id);
    updateReadouts(id);
    renderZoom(id);
    positionProxy(id);
    updatePixelInfo(id);
    updateEquations(false);
  }

  function render() {
    renderField();
    updateAperture(1);
    updateAperture(2);
    updateFieldDescription();
    apLabel[1].hidden = !state.showLabels;
    apLabel[2].hidden = !state.showLabels;
  }

  // ======================================================================
  // Announcements (aria-live, on commit — not per tick)
  // ======================================================================

  var announceTimer = null;
  function announce(text, delay) {
    clearTimeout(announceTimer);
    announceTimer = setTimeout(function () {
      liveRegion.textContent = text;
    }, delay || 0);
  }

  function announceAperture(id) {
    var ap = state.apertures[id];
    var dm = deltaMag();
    var dmText = (isNaN(dm) || !isFinite(dm))
      ? 'Magnitude difference m 1 minus m 2 is not defined.'
      : 'Magnitude difference m 1 minus m 2 is ' + dm.toFixed(2) + ' magnitudes.';
    announce('Aperture ' + id + ' moved to center x ' + ap.cx + ', center y ' + ap.cy +
      ' pixels. Sky-subtracted flux f ' + id + ' is ' + ap.lum.toFixed(2) + ' counts. ' + dmText, 150);
  }

  var pixelAnnounceTimer = null;
  function announcePixel(id, px, py, counts) {
    clearTimeout(pixelAnnounceTimer);
    pixelAnnounceTimer = setTimeout(function () {
      liveRegion.textContent = 'Pixel x ' + px + ', y ' + py + ': ' +
        (counts !== -1 ? counts + ' counts.' : 'outside the star field, counts not available.');
    }, 350);
  }

  // ======================================================================
  // Aperture dragging (pointer) + keyboard — PixelMaskProxy port.
  // Both paths funnel through moveTo (clamp to field bounds + round).
  // ======================================================================

  function moveApertureTo(id, x, y) {
    // bounds = Rectangle(0, 0, width-1, height-1) in field coordinates
    if (x < 0) { x = 0; } else if (x > FIELD_WIDTH - 1)  { x = FIELD_WIDTH - 1; }
    if (y < 0) { y = 0; } else if (y > FIELD_HEIGHT - 1) { y = FIELD_HEIGHT - 1; }
    x = Math.round(x);
    y = Math.round(y);
    var ap = state.apertures[id];
    if (x !== ap.cx || y !== ap.cy) {
      ap.cx = x;
      ap.cy = y;
      renderField();
      updateAperture(id);
      updateFieldDescription();
      return true;
    }
    return false;
  }

  function bringToTop(id) {
    var i = state.zOrder.indexOf(id);
    state.zOrder.splice(i, 1);
    state.zOrder.push(id);
    [1, 2].forEach(function (k) {
      apProxy[k].style.zIndex = String(2 + state.zOrder.indexOf(k));
    });
  }

  function fieldCoordsFromEvent(ev) {
    var rect = fieldCanvas.getBoundingClientRect();
    return {
      x: (ev.clientX - rect.left) / rect.width  * FIELD_WIDTH,
      y: (ev.clientY - rect.top)  / rect.height * FIELD_HEIGHT
    };
  }

  [1, 2].forEach(function (id) {
    var proxy = apProxy[id];
    var dragOffset = null;

    proxy.addEventListener('pointerdown', function (ev) {
      ev.preventDefault();
      proxy.focus();                       // click/tap-to-focus (then arrows work)
      try { proxy.setPointerCapture(ev.pointerId); } catch (e) { /* no-op */ }
      var p = fieldCoordsFromEvent(ev);
      var ap = state.apertures[id];
      dragOffset = { x: ap.cx - p.x, y: ap.cy - p.y };   // _xOffset/_yOffset
      bringToTop(id);
      renderField();
    });

    proxy.addEventListener('pointermove', function (ev) {
      if (dragOffset === null) { return; }
      var p = fieldCoordsFromEvent(ev);
      moveApertureTo(id, dragOffset.x + p.x, dragOffset.y + p.y);
    });

    function endDrag(ev) {
      if (dragOffset === null) { return; }
      dragOffset = null;
      announceAperture(id);
    }
    proxy.addEventListener('pointerup', endDrag);
    proxy.addEventListener('pointercancel', endDrag);

    proxy.addEventListener('keydown', function (ev) {
      var ap = state.apertures[id];
      var step = ev.shiftKey ? 10 : 1;     // original: 1 px per arrow press
      var dx = 0, dy = 0, handled = true;
      switch (ev.key) {
        case 'ArrowLeft':  dx = -step; break;
        case 'ArrowRight': dx =  step; break;
        case 'ArrowUp':    dy = -step; break;
        case 'ArrowDown':  dy =  step; break;
        case 'PageUp':     dy = -10;   break;
        case 'PageDown':   dy =  10;   break;
        default: handled = false;
      }
      if (!handled) { return; }
      ev.preventDefault();
      bringToTop(id);
      moveApertureTo(id, ap.cx + dx, ap.cy + dy);
      announceAperture(id);                // debounced inside announce()
    });
  });

  // ======================================================================
  // Zoom windows: hover/click/keyboard active pixel — PixelDisplay port
  // ======================================================================

  function setActivePixel(id, x, y) {
    // PixelDisplay.activePixel setter: clamp into the grid unless (-1,-1)
    if (!(x === -1 && y === -1)) {
      if (x < 0) { x = 0; } else if (x >= ZOOM_DIMENSIONS) { x = ZOOM_DIMENSIONS - 1; }
      if (y < 0) { y = 0; } else if (y >= ZOOM_DIMENSIONS) { y = ZOOM_DIMENSIONS - 1; }
    }
    state.active[id] = { x: x, y: y };
    renderZoom(id);
    updatePixelInfo(id);
  }

  [1, 2].forEach(function (id) {
    var proxy = zoomProxy[id];
    var canvas = zoomCanvas[id];

    function cellFromEvent(ev) {
      var rect = canvas.getBoundingClientRect();
      var mx = (ev.clientX - rect.left) / rect.width  * ZOOM_WINDOW_SIZE;
      var my = (ev.clientY - rect.top)  / rect.height * ZOOM_WINDOW_SIZE;
      var cell = ZOOM_WINDOW_SIZE / ZOOM_DIMENSIONS;
      // getPixelFromMouseLocation, incl. the exact-right/bottom-edge case
      var cx = mx === ZOOM_WINDOW_SIZE ? ZOOM_DIMENSIONS - 1 : Math.floor(mx / cell);
      var cy = my === ZOOM_WINDOW_SIZE ? ZOOM_DIMENSIONS - 1 : Math.floor(my / cell);
      if (cx < 0 || cx >= ZOOM_DIMENSIONS || cy < 0 || cy >= ZOOM_DIMENSIONS) {
        return { x: -1, y: -1 };
      }
      return { x: cx, y: cy };
    }

    function pointerInspect(ev) {
      var c = cellFromEvent(ev);
      var act = state.active[id];
      if (c.x !== -1 && (c.x !== act.x || c.y !== act.y)) {
        setActivePixel(id, c.x, c.y);
      }
    }

    proxy.addEventListener('pointermove', pointerInspect);
    proxy.addEventListener('pointerdown', function (ev) {
      ev.preventDefault();
      proxy.focus();                       // click/tap-to-focus
      pointerInspect(ev);
    });

    proxy.addEventListener('pointerleave', function () {
      // original: roll-out drops focus, which clears the active pixel;
      // keep the selection when the window is keyboard-focused
      if (document.activeElement !== proxy) {
        setActivePixel(id, -1, -1);
      }
    });

    proxy.addEventListener('focus', function () {
      // onFocusIn: if no active pixel, select the center pixel
      if (state.active[id].x === -1) {
        setActivePixel(id, Math.floor(ZOOM_DIMENSIONS / 2), Math.floor(ZOOM_DIMENSIONS / 2));
      }
    });

    proxy.addEventListener('blur', function () {
      // onFocusOut: clear the active pixel
      setActivePixel(id, -1, -1);
    });

    proxy.addEventListener('keydown', function (ev) {
      var act = state.active[id];
      var dx = 0, dy = 0, handled = true;
      switch (ev.key) {
        case 'ArrowLeft':  dx = -1; break;
        case 'ArrowRight': dx =  1; break;
        case 'ArrowUp':    dy = -1; break;
        case 'ArrowDown':  dy =  1; break;
        case 'PageUp':     dy = -5; break;
        case 'PageDown':   dy =  5; break;
        case 'Home':       dx = -ZOOM_DIMENSIONS; break;
        case 'End':        dx =  ZOOM_DIMENSIONS; break;
        default: handled = false;
      }
      if (!handled) { return; }
      ev.preventDefault();
      setActivePixel(id, act.x + dx, act.y + dy);
    });
  });

  // ======================================================================
  // Checkbox ("label the apertures") + Reset
  // ======================================================================

  checkbox.addEventListener('change', function () {
    state.showLabels = checkbox.checked;
    apLabel[1].hidden = !state.showLabels;
    apLabel[2].hidden = !state.showLabels;
  });

  // Masthead Reset: restore the exact initial state
  document.addEventListener('sim-reset', function () {
    state.apertures[1].cx = AP1_INIT.cx; state.apertures[1].cy = AP1_INIT.cy;
    state.apertures[2].cx = AP2_INIT.cx; state.apertures[2].cy = AP2_INIT.cy;
    state.apertures[1].lum = 1; state.apertures[2].lum = 1;
    state.zOrder = [1, 2];
    state.showLabels = false;
    checkbox.checked = false;
    state.active[1] = { x: -1, y: -1 };
    state.active[2] = { x: -1, y: -1 };
    pixelInfoEl[1].hidden = true;
    pixelInfoEl[2].hidden = true;
    render();
    announce('Simulation reset. Aperture 1 at center x ' + AP1_INIT.cx + ', center y ' + AP1_INIT.cy +
      ' pixels; aperture 2 at center x ' + AP2_INIT.cx + ', center y ' + AP2_INIT.cy + ' pixels.', 100);
  });

  // ======================================================================
  // Boot
  // ======================================================================

  render();

})();
