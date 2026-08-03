/* ==========================================================================
   Eclipsing Binary Simulator - HTML5 port of binSys097.swf (NAAP).
   Behavior is ported from the decompiled ActionScript; every physical
   constant, table and formula is copied verbatim from the source files
   (see CONVERSION_NOTES.md for the mapping).
   ========================================================================== */
(function () {
  'use strict';

  var LN10 = 2.302585092994046;       // from the AS source (Math.log(x)/LN10)
  var DEG2RAD = 0.017453292519943295; // from the AS source
  var RAD2DEG = 57.29577951308232;    // from the AS source
  var TWO_PI = 6.283185307179586;     // from the AS source

  /* ========================================================================
     Number formatting - ports of Math.toSigDigits and the toFixed polyfill
     ======================================================================== */

  // Math.toSigDigits from DoAction_7.as
  function toSigDigits(numArg, digsArg) {
    var num = parseFloat(numArg);
    var digs = Math.abs(parseInt(digsArg, 10));
    if (!isFinite(digs) || !isFinite(num)) { return NaN; }
    if (num === 0 || digs === 0) { return 0; }
    if (digs > 15) { digs = 15; }
    var sign = 1;
    if (num < 0) { sign = -1; num = Math.abs(num); }
    var tmp = Math.floor(Math.log(num) / LN10);
    var fact = Math.pow(10, digs - (1 + tmp));
    var num2 = Math.round(fact * num) / fact;
    return sign * num2;
  }

  // toFixed polyfill from sliderV5Component.as (identical in Lightcurve.as)
  function asToFixed(x, f) {
    var s = '';
    if (x < 0) { s = '-'; x = -x; }
    var m = '';
    if (x < 1e21) {
      var n = Math.round(x * Math.pow(10, f));
      if (n === 0) { m = '0'; } else { m = n.toString(); }
      if (f > 0) {
        var k = m.length;
        if (k <= f) {
          var z = '';
          for (var i = 0; i < f + 1 - k; i++) { z += '0'; }
          m = z + m;
          k = f + 1;
        }
        var a = m.substr(0, k - f);
        var b = m.substr(k - f);
        m = a + '.' + b;
      }
    } else {
      m = x.toString();
    }
    return s + m;
  }

  /* ========================================================================
     H-R relations - verbatim ports from DoAction_2.as
     ======================================================================== */

  // R = 33736108.2311059 * sqrt(L) / T^2  (solar radii, L in L_sun, T in K)
  function getRfromTL(temp, luminosity) {
    return 33736108.2311059 * Math.sqrt(luminosity) / (temp * temp);
  }

  // L = R^2 (T / 5808.27928315314)^4
  function getLfromRT(radius, temp) {
    return radius * radius * Math.pow(temp / 5808.27928315314, 4);
  }

  // T = 5808.27928315314 * (L / R^2)^(1/4)
  function getTfromLR(luminosity, radius) {
    return 5808.27928315314 * Math.pow(luminosity / (radius * radius), 0.25);
  }

  // main-sequence (luminosity class V) L(T) polynomial in log10 T
  function getLfromT(temp) {
    // coefficients for class "v" from getLuminosityFromTempAndClass
    var k = { a: -321.9678859, b: 224.0898712, c: -52.79524902, d: 4.246993586 };
    var logT = Math.log(temp) / LN10;
    var logL = k.a + logT * (k.b + logT * (k.c + logT * k.d));
    return Math.pow(10, logL);
  }

  // piecewise T(L) polynomial, from getTempFromLuminosity
  function getTfromL(lum) {
    var logL = Math.log(lum) / LN10;
    var a, b, c, d, e, f, g;
    if (logL < -1.61) {
      a = 3.76424847491303; b = 0.140316436337353; c = 0.0139709648834783;
      d = 0.00146257952166353; e = 0.000114203991057792; f = 0.00000534009520193973;
      g = 1.00897501873505e-7;
    } else if (logL < 0.22) {
      a = 3.76404749064937; b = 0.139720836051662; c = 0.0131949471107482;
      d = 0.000878016217920958; e = -0.00016087678534046; f = -0.0000718923778642037;
      g = -0.0000098430921759891;
    } else if (logL < 1.48) {
      a = 3.76404935999916; b = 0.139700505514371; c = 0.0132834512392025;
      d = 0.000681148684168764; e = 0.0000515647954029831; f = -0.000230931527900807;
      g = 0.0000134429776870977;
    } else if (logL < 2.61) {
      a = 3.76208682178285; b = 0.14541668375348; c = 0.00684584757963743;
      d = 0.00396076543835346; e = -0.000464655201610208; f = -0.000381007438333072;
      g = 0.0000623586254118745;
    } else if (logL < 3.62) {
      a = 3.7785507438146; b = 0.129897095940252; c = 0.00142810707728862;
      d = 0.0167045399494531; e = -0.00693250229182094; f = 0.00103845665508301;
      g = -0.000055992055857869;
    } else if (logL < 5.43) {
      a = 3.94943146036608; b = -0.154281251321452; c = 0.1979230342627;
      d = -0.055596100619304; e = 0.00799539610207913; f = -0.000600846748510063;
      g = 0.0000187770530697032;
    } else {
      a = 4.36797099518548; b = -0.314871178456464; c = 0.143399968097621;
      d = -0.0130740129137381; e = -0.00159255369850374; f = 0.000357973227398207;
      g = -0.000017804556980593;
    }
    var logT = a + logL * (b + logL * (c + logL * (d + logL * (e + logL * (f + logL * g)))));
    return Math.pow(10, logT);
  }

  // mass-luminosity relation, from getLuminosityFromMass
  function getLfromM(mass) {
    if (mass < 0.43) {
      return 0.232220431737728 * Math.pow(mass, 2.26); // L = 0.2322 M^2.26
    }
    return Math.pow(mass, 3.99);                        // L = M^3.99
  }

  // inverse mass-luminosity relation, from getMassFromLuminosity
  function getMfromL(lum) {
    if (lum < 0.0344777675857638) {
      return Math.pow(lum / 0.232220431737728, 0.4424778761061947);
    }
    return Math.pow(lum, 0.2506265664160401);
  }

  // piecewise main-sequence T(R) polynomial, from getTempFromRadius
  function getTfromR(rad) {
    var k;
    if (rad < 0.1) {
      k = [1352.16767530322, 33599.1047540922, -784198.011084895, 16084379.1353831,
        -233546502.088928, 2298017687.04881, -14552788534.6067, 53476567699.742,
        -86617728028.9296];
    } else if (rad < 0.25) {
      k = [1525.16132828771, 18333.8872452162, -170530.36030984, 1453772.44649421,
        -8738576.74889584, 35514001.1950461, -92682674.163536, 140073163.212459,
        -93147429.5856531];
    } else if (rad < 0.5) {
      k = [1905.04347520874, 6714.56204915616, -1775.75414728806, -61182.7619320228,
        328539.718494933, -866771.158598654, 1306672.55560276, -1075768.59606073,
        376757.353242932];
    } else if (rad < 1) {
      k = [2068.1175248258, 5563.86215687474, -4852.07640731762, 3656.26261362536,
        2735.87826571229, -8446.1036677512, 8146.78388274811, -3772.88831587521,
        708.443007026755];
    } else if (rad < 1.5) {
      k = [2391.70045019689, 3732.07819320879, -920.732506126424, 833.719762271331,
        -697.869242020044, 900.79650486637, -629.925154622845, 233.347167059884,
        -34.8361815464883];
    } else if (rad < 2) {
      k = [4141.93022494891, -970.771725704677, 3494.67527970946, -709.49458977827,
        -236.674138156599, -17.1181302729852, 169.38213634057, -49.064027102312,
        1.60669025246778];
    } else if (rad < 2.5) {
      k = [1812.82345082759, -6513.01709915503, 19391.5804118, -8882.33700262244,
        -4895.02018375962, 6184.02162389691, -2175.41097965753, 299.146683378343,
        -10.8871559946344];
    } else if (rad < 3) {
      k = [25844.8346447308, -20435.2395029571, 3334.17958306922, 740.803686348806,
        1806.7649033149, -661.450322470812, -150.375374980598, 88.281593744638,
        -9.71161474200204];
    } else if (rad < 4) {
      k = [15026.8625643326, -20930.6383130535, 9871.33267137623, 2324.05843595319,
        -1682.03371129649, 78.1143467429274, 97.2909691798511, -21.3075228503785,
        1.37252141155517];
    } else if (rad < 8) {
      k = [-34982.164652471, 35035.5306654001, -8355.50619523595, 1051.42469467884,
        -10.0887308658571, -16.8558151492651, 2.45675359616782, -0.152663903517068,
        0.00371044364840495];
    } else {
      k = [-8589.58631132264, 14473.4609040126, -1960.43390021823, 178.497762275493,
        -9.8622726858782, 0.274253985981647, -0.0000669016182108453, -0.00019859563247206,
        0.00000363643667031929];
    }
    return k[0] + rad * (k[1] + rad * (k[2] + rad * (k[3] + rad * (k[4] + rad *
      (k[5] + rad * (k[6] + rad * (k[7] + rad * k[8])))))));
  }

  /* ========================================================================
     Star disc color - verbatim port of Sphere.as getColorFromTemp
     ======================================================================== */
  function getColorFromTemp(temp) {
    if (temp < 1000) { temp = 1000; }
    else if (temp > 40000) { temp = 40000; }
    var logT = Math.log(temp) / LN10;
    var logT2 = logT * logT;
    var logT3 = logT * logT2;
    var r = 22686.34111 - logT * 15082.52755 + logT2 * 3375.333832 - logT3 * 252.4073853;
    if (r < 0) { r = 0; } else if (r > 255) { r = 255; }
    var g;
    if (temp <= 6500) {
      g = -811.6499145 + logT * 36.97365953 + logT2 * 160.7861677 - logT3 * 25.57573664;
    } else {
      g = 13836.23586 - logT * 9069.078214 + logT2 * 2015.254756 - logT3 * 149.7766966;
    }
    var b = -11545.34298 + logT * 8529.658165 - logT2 * 2150.198586 + logT3 * 190.0306573;
    if (b < 0) { b = 0; } else if (b > 255) { b = 255; }
    return 'rgb(' + (r & 255 | 0) + ',' + (Math.max(0, Math.min(255, g)) | 0) + ',' + (b & 255 | 0) + ')';
  }

  /* ========================================================================
     Preset systems - verbatim from DoAction_5.as
     ======================================================================== */
  var completeSystemsStart = 8;
  var incompleteSystemsStart = 17;
  var extraSystemsStart = 24;
  var systemsArray = [
    { name: "Example 1", id: null, m1: 1, r1: 0.16667, t1: 6000, m2: 1, r2: 0.16667, t2: 6000, a: 6, e: 0, i: 90, w: 0, comment: "Discuss Flat Top of Light Curve, Partial Eclipses (Flat Bottoms)" },
    { name: "Example 2", id: null, m1: 1, r1: 0.33333, t1: 6000, m2: 1, r2: 0.16667, t2: 6000, a: 6, e: 0, i: 90, w: 0, comment: "Total Eclipses" },
    { name: "Example 3", id: null, m1: 1, r1: 0.16667, t1: 8000, m2: 1, r2: 0.16667, t2: 6000, a: 6, e: 0, i: 90, w: 0, comment: "Uneven Eclipse Depths" },
    { name: "Example 4", id: null, m1: 2, r1: 0.16667, t1: 6000, m2: 1, r2: 0.16667, t2: 6000, a: 6, e: 0, i: 90, w: 0, comment: "Different Masses - (Change viewpoint to looking down on plane)" },
    { name: "Example 5", id: null, m1: 1, r1: 0.16667, t1: 6000, m2: 1, r2: 0.16667, t2: 6000, a: 6, e: 0.4, i: 90, w: 0, comment: "Non-zero Eccentricity - Masses Equal" },
    { name: "Example 6", id: null, m1: 2, r1: 0.16667, t1: 6000, m2: 1, r2: 0.16667, t2: 6000, a: 6, e: 0.4, i: 90, w: 0, comment: "Non-zero Eccentricity - Masses Not Equal - Tie to Kepler's Second Law" },
    { name: "Example 7", id: null, m1: 3, r1: 0.5, t1: 6000, m2: 1, r2: 0.16667, t2: 6000, a: 6, e: 0, i: 90, w: 0, comment: "Conditions for Eclipses (Return to Earth Viewpoint) - Slowly Decrease inclination - when do eclipses become partial/nonexistent" },
    { name: "Example 8", id: null, m1: 3, r1: 0.12, t1: 6000, m2: 1, r2: 0.04, t2: 6000, a: 25, e: 0, i: 90, w: 0, comment: "Conditions for Eclipses (Earth Viewpoint) - Slowly Decrease inclination - when do eclipses become partial/nonexistent" },
    { name: "KP Aql", id: 42, V: 9.42, par: 0, parErr: 0, type: "F0V/F0V", m: 0.988, m1: 1.5, m2: 1.48, a: 13.61, r1: 0.134, r2: 0.128, t1: 7400, t2: 7400, i: 90, w: 0, e: 0 },
    { name: "EW Ori", id: 124, V: 9.94, par: 0, parErr: 0, type: "G0V/G5V", m: 0.97, m1: 1.05, m2: 1.02, a: 19.5, r1: 0.0561, r2: 0.0536, t1: 5970, t2: 5781, i: 89.65, w: 314, e: 0.068 },
    { name: "FL Lyr", id: 126, V: 9.33, par: 7.69, parErr: 0.89, type: "F8V/?", m: 0.786, m1: 1.11, m2: 0.87, a: 8.87, r1: 0.14, r2: 0.105, t1: 6152, t2: 5297, i: 86.3, w: 0, e: 0 },
    { name: "EK Cep", id: 122, V: 7.85, par: 6.53, parErr: 0.58, type: "A1.5V/?", m: 0.55, m1: 2.02, m2: 1.11, a: 16.58, r1: 0.095, r2: 0.0791, t1: 8995, t2: 5689, i: 89.16, w: 49.8, e: 0.109 },
    { name: "TW Cas", id: 171, V: 8.32, par: 3.99, parErr: 0.93, type: "A0V/?", m: 0.432, m1: 2.51, m2: 1.08, a: 8.17, r1: 0.25, r2: 0.3182, t1: 10500, t2: 5400, i: 74.7, w: 0, e: 0 },
    { name: "AD Her", id: 41, V: 9.36, par: -0.18, parErr: 2.28, type: "A4V/K2", m: 0.33, m1: 1.89, m2: 0.62, a: 26.14, r1: 0.085041, r2: 0.312003, t1: 8610, t2: 3900, i: 84.1, w: 0, e: 0 },
    { name: "AW UMa", id: 45, V: 6.84, par: 15.13, parErr: 0.9, type: "F0/?", m: 0.0803, m1: 1.43, m2: 0.11, a: 2.81, r1: 0.660024, r2: 0.275627, t1: 7175, t2: 7022, i: 78.3, w: 0, e: 0 },
    { name: "AW Lac", id: 18, V: 10.6, par: -0.57, parErr: 0.71, type: "B2V?/?", m: 1, m1: 6.22, m2: 6.22, a: 10.65, r1: 0.497003, r2: 0.497003, t1: 20500, t2: 17300, i: 78.9, w: 0, e: 0 },
    { name: "DM Del", id: 8, V: 8.65, par: 0, parErr: 0, type: "A2V/G8", m: 0.26, m1: 1.94, m2: 0.5, a: 5.07, r1: 0.528004, r2: 0.293378, t1: 8770, t2: 5200, i: 87.4, w: 0, e: 0 },
    { name: "RT CrB", id: 149, m2: 0.78, m1: 0.79, a: 14.5, r2: 0.1707, r1: 0.007, t2: 5075, t1: 5781, i: 84.9, w: 0, e: 0 },
    { name: "V478 Cyg", id: 195, V: 8.73, par: 0, parErr: 0.92, type: "B0V/B0V", m: 0.9717, m1: 11.76, m2: 11.43, a: 24.29, r1: 0.286, r2: 0.271, t1: 30900, t2: 30308, i: 0, w: 65, e: 0.0295 },
    { name: "V477 Cyg", id: 196, V: 8.55, par: 5.22, parErr: 1.05, type: "A3V/F5V", m: 0.749, m1: 1.93, m2: 1.44, a: 60, r1: 0.027762, r2: 0.024739, t1: 8727, t2: 6528, i: 85.66, w: 162.8, e: 0.331 },
    { name: "DI Her", id: 110, V: 8.42, par: 1.47, parErr: 1.11, type: "B5III/?", m: 0.88, m1: 4.8, m2: 4.22, a: 42.12, r1: 0.0621, r2: 0.0574, t1: 17000, t2: 15100, i: 89.3, w: 329.9, e: 0 },
    { name: "AG Phe", id: 95, V: 8.98, par: 4.76, parErr: 1.15, type: "A9V/?", m: 0.1559, m1: 1.53, m2: 0.24, a: 4.22, r1: 0.413152, r2: 0.247057, t1: 7500, t2: 3000, i: 87.624, w: 0, e: 0 },
    { name: "RZ Cas", id: 155, V: 6.18, par: 15.99, parErr: 0.62, type: "A3V/K0IV", m: 0.3311, m1: 1.89, m2: 0.62, a: 6.44, r1: 0.249291, r2: 0.312262, t1: 8600, t2: 3000, i: 0, w: 0, e: 0 },
    { name: "AF Gem", id: 92, V: 10.54, par: 0, parErr: 0, type: "B9.5V/G0III-", m: 0.342, m1: 2.34, m2: 0.8, a: 7.13, r1: 0.32975, r2: 0.0142, t1: 10000, t2: 3300, i: 87.4, w: 0, e: 0 },
    { name: "CW CMa", id: 109, V: 8.58, par: 0, parErr: 0, type: "A0V/?", m: 0.944, m1: 2.61, m2: 2.46, a: 11.92, r1: 0.176215, r2: 0.156894, t1: 10800, t2: 10300, i: 83.3, w: 0, e: 0 },
    { name: "RX Ari", id: 152, V: 9.48, par: 0, parErr: 0, type: "F2V/?", m: 0.2749, m1: 1.31, m2: 0.36, a: 5.09, r1: 0.393886, r2: 0.228586, t1: 6800, t2: 3520, i: 81.88, w: 0, e: 0 },
    { name: "MR Cyg", id: 138, V: 8.95, par: 1.32, parErr: 0.87, type: "B3V/?", m: 0.399, m1: 6.39, m2: 2.55, a: 12.33, r1: 0.360635, r2: 0.32667, t1: 20900, t2: 13900, i: 84.4, w: 0, e: 0 },
    { name: "TX UMa", id: 44, V: 7.06, par: 4.74, parErr: 1.08, type: "B8V/G0III", m: 0.247, m1: 3.31, m2: 0.82, a: 14.24, r1: 0.176, r2: 0.253, t1: 12900, t2: 5500, i: 83.5, w: 0, e: 0 },
    { name: "V442 Cyg", id: 191, V: 9.713, par: 0, parErr: 0, type: "F1V/F2V", m: 0.902, m1: 1.34, m2: 1.21, a: 10.27, r1: 0.192, r2: 0.154, t1: 6900, t2: 6725, i: 86, w: 0, e: 0 },
    { name: "AD Boo", id: 5, V: 9.45, par: 0, parErr: 0, type: "F6V/G0V", m: 0.86, m1: 1.18, m2: 1.01, a: 8.88, r1: 0.1702, r2: 0.1277, t1: 6383, t2: 5930, i: 87.8, w: 0, e: 0 },
    { name: "UZ Dra", id: 180, V: 9.58, par: 0, parErr: 0, type: "F7V/G0V", m: 0.92, m1: 1.09, m2: 1, a: 11.84, r1: 0.104601, r2: 0.0897, t1: 6100, t2: 5844, i: 89.32, w: 0, e: 0 },
    { name: "AR Aur", id: 97, V: 6.14, par: 8.2, parErr: 0.78, type: "B9.5V/?", m: 0.925, m1: 2.71, m2: 2.51, a: 18.81, r1: 0.0977, r2: 0.0996, t1: 11125, t2: 10600, i: 88.52, w: 0, e: 0 },
    { name: "HS Aur", id: 127, V: 10.16, par: 10.05, parErr: 2.21, type: "G8V/K0V", m: 0.977, m1: 0.86, m2: 0.84, a: 23.01, r1: 0.043, r2: 0.037, t1: 5346, t2: 5200, i: 89.7, w: 0, e: 0 },
    { name: "AY Cam", id: 204, V: 9.683, par: 0, parErr: 0, type: "A9V/F1V", m: 0.8972, m1: 1.45, m2: 1.3, a: 11.54, r1: 0.222022, r2: 0.161294, t1: 7250, t2: 7395, i: 88.465, w: 0, e: 0 },
    { name: "CD Tau", id: 35, V: 6.8, par: 13.66, parErr: 1.64, type: "F6V/F6V", m: 0.948, m1: 1.12, m2: 1.06, a: 12.43, r1: 0.133, r2: 0.1172, t1: 6200, t2: 6200, i: 87.7, w: 0, e: 0 },
    { name: "FS Mon", id: 21, V: 9.601, par: 0, parErr: 0, type: "F2V/F4V", m: 0.8959, m1: 1.28, m2: 1.15, a: 8.7, r1: 0.2177, r2: 0.1729, t1: 6715, t2: 6550, i: 87.7, w: 0, e: 0 },
    { name: "BP Vul", id: 31, V: 9.803, par: 1.03, parErr: 1.51, type: "A7m/F2m", m: 0.8105, m1: 1.6, m2: 1.3, a: 9.33, r1: 0.1931, r2: 0.1553, t1: 7709, t2: 6775, i: 87.67, w: 154.7, e: 0.0355 },
    { name: "V459 Cas", id: 206, V: 10.34, par: 0, parErr: 0, type: "A1V/A1V", m: 0.974, m1: 2.06, m2: 2.01, a: 27.89, r1: 0.0726, r2: 0.071, t1: 9141, t2: 9099, i: 89.465, w: 240.1, e: 0.0243 },
    { name: "V364 Lac", id: 185, m2: 1.77, m1: 1.8, a: 24.33, r2: 0.12572, r1: 0.113222, t2: 8251, t1: 8500, i: 89.19, w: 85.265, e: 0.2873 },
    { name: "V526 Sgr", id: 208, V: 9.708, par: 0, parErr: 0, type: "B9.5V/A2V", m: 0.74, m1: 2.38, m2: 1.76, a: 10.43, r1: 0.1843, r2: 0.1521, t1: 10100, t2: 8450, i: 87.3, w: 254.76, e: 0.2194 },
    { name: "GG Ori", id: 131, V: 10.385, par: 0, parErr: 0, type: "B9.5V/B9.5V", m: 0.9982, m1: 2.33, m2: 2.32, a: 24.78, r1: 0.071891, r2: 0.071778, t1: 9950, t2: 9950, i: 89.24, w: 122.76, e: 0.2218 },
    { name: "SW CMa", id: 163, V: 9.126, par: 2.33, parErr: 1.13, type: "A5V/A5V", m: 0.914, m1: 1.85, m2: 1.7, a: 29.97, r1: 0.09458, r2: 0.0775, t1: 8500, t2: 8500, i: 88.72, w: 162.4, e: 0.3179 },
    { name: "V541 Cyg", id: 209, V: 10.35, par: 0, parErr: 0, type: "B9.5V/B9.5V", m: 1, m1: 2.31, m2: 2.31, a: 43.23, r1: 0.044, r2: 0.0419, t1: 9885, t2: 9954, i: 89.88, w: 262.82, e: 0.479 },
    { name: "IQ Per", id: 19, V: 7.73, par: 2.99, parErr: 1.08, type: "B7.5/A6", m: 0.493, m1: 3.11, m2: 1.53, a: 10.17, r1: 0.231, r2: 0.142, t1: 12300, t2: 8100, i: 89.3, w: 70, e: 0.075 },
    { name: "IM Aur", id: 136, V: 7.94, par: 0, parErr: 0, type: "B7V/?", m: 0.353, m1: 2.46, m2: 0.87, a: 7.28, r1: 0.371908, r2: 0.279333, t1: 10350, t2: 5095, i: 78, w: 0, e: 0 },
    { name: "TT Lyr", id: 169, V: 9.2, par: 0, parErr: 0, type: "A0V/G5?", m: 0.27, m1: 2.18, m2: 0.59, a: 17.83, r1: 0.167, r2: 0.27, t1: 9500, t2: 4900, i: 83.7, w: 0, e: 0 },
    { name: "T LMi", id: 168, V: 10.87, par: 1.87, parErr: 2.05, type: "A3V/G5III", m: 0.1, m1: 2.3, m2: 0.23, a: 11.97, r1: 0.158, r2: 0.2, t1: 9860, t2: 5055, i: 86.3, w: 0, e: 0 },
    { name: "SW Cyg", id: 164, V: 9.24, par: 0.81, parErr: 0.96, type: "A2e/K0", m: 0.3664, m1: 2.04, m2: 0.75, a: 16.31, r1: 0.171295, r2: 0.320215, t1: 9070, t2: 3813, i: 82.7, w: 0, e: 0 },
    { name: "V380 Cyg", id: 187, V: 5.68, par: 1.27, parErr: 0.49, type: "B1.5II/B2V", m: 0.626, m1: 6.59, m2: 4.13, a: 49.76, r1: 0.2478, r2: 0.0631, t1: 21350, t2: 20500, i: 82.4, w: 132.7, e: 0.234 },
    { name: "NN Cep", id: 139, V: 8.1, par: 3.31, parErr: 0.92, type: "A5/?", m: 1.39, m1: 1.78, m2: 2.47, a: 11.03, r1: 0.340992, r2: 0.177005, t1: 8262, t2: 8500, i: 80.3, w: 0, e: 0 },
    { name: "AE Phe", id: 39, V: 7.79, par: 20.49, parErr: 0.81, type: "G1V/G2V", m: 2.5006, m1: 1.06, m2: 2.65, a: 3.31, r1: 0.502069, r2: 0.343278, t1: 6000, t2: 6145, i: 87.99, w: 0, e: 0 },
    { name: "V885 Cyg", id: 207, V: 9.96, par: 0, parErr: 0, type: "A3mV/A4mV", m: 1.938, m1: 0.58, m2: 1.13, a: 7.15, r1: 0.476368, r2: 0.360782, t1: 4400, t2: 4730, i: 84, w: 0, e: 0 },
    { name: "RS Ind", id: 146, V: 9.37, par: 0, parErr: 0, type: "F0-F2/?", m: 0.322, m1: 1.44, m2: 0.46, a: 3.81, r1: 0.4983, r2: 0.3039, t1: 7200, t2: 4659, i: 90, w: 0, e: 0 },
    { name: "EF Dra", id: 120, V: 10.8, par: 0, parErr: 0, type: "F9V/?", m: 0.16, m1: 1.06, m2: 0.17, a: 2.54, r1: 0.594226, r2: 0.292257, t1: 6000, t2: 6054, i: 78.13, w: 0, e: 0 }
  ];

  /* ========================================================================
     Live region + helpers
     ======================================================================== */
  var liveStatus = null;
  function announce(text) {
    if (!liveStatus) { return; }
    // clear first so repeating the same message is still announced
    liveStatus.textContent = '';
    requestAnimationFrame(function () { liveStatus.textContent = text; });
  }

  // Typeset any math the sim built after page load (slider units, HR-diagram
  // mass labels). MathJax is loaded async, so it may finish either before or
  // after this script builds the controls: waiting on MathJax.startup.promise
  // covers the first case, and the pageReady hook in index.html (which calls
  // klunlInitEqn -> here) covers the second.
  function typesetMath(el) {
    if (!window.MathJax) { return; }
    var run = function () {
      if (!MathJax.typesetPromise) { return; }
      return MathJax.typesetPromise(el ? [el] : undefined).then(function () {
        document.querySelectorAll('mjx-container').forEach(function (m) {
          m.setAttribute('tabindex', '-1');   // display-only: not a tab stop
        });
      });
    };
    var startup = MathJax.startup;
    if (startup && startup.promise) {
      startup.promise.then(run).catch(function () { /* typeset again later */ });
    } else {
      Promise.resolve().then(run).catch(function () { /* pageReady will typeset */ });
    }
  }

  /* ========================================================================
     SliderV5 - port of sliderV5Component.as value/snapping logic wrapped in
     an accessible custom control (label + numeric field + unit + track).
     The dark shading on the track marks the excluded parts of the range,
     exactly like sliderV5DefaultBar's left/right shading clips.
     ======================================================================== */

  var CONTINUOUS_DELAY = 500;   // ms, barMC._holdDelay from the source

  function SliderV5(mountId, opts) {
    var self = this;
    this.opts = opts;
    this.changeHandler = opts.changeHandler || null;

    // ---- value logic state (sliderV5Component.as) ----
    this._scaleMode = (opts.scaleMode === 'linear') ? 0 : 1;
    if (opts.precisionMode === 'significant digits') {
      this._precisionMode = 0;
      var x = Math.abs(parseInt(opts.precision, 10));
      if (!isFinite(x) || isNaN(x) || x === 0) { x = 1; }
      this._sigs = x;
      this._tickResolution = Math.pow(10, x);
    } else {
      this._precisionMode = 1;
      var x2 = parseInt(opts.precision, 10);
      if (!isFinite(x2) || isNaN(x2)) { x2 = 1; }
      this._prec = x2;
      this._minIncrement = Math.pow(10, -x2);
    }
    this._value = NaN;

    // ---- DOM ----
    var mount = document.getElementById(mountId);
    var root = document.createElement('div');
    root.className = 'ebs-slider' + (opts.showField === false ? ' ebs-slider--nofield' : '');
    var fieldId = mountId + '-field';

    var label = null, field = null, units = null;
    if (opts.showField !== false) {
      label = document.createElement('label');
      label.className = 'ebs-slider__label';
      label.textContent = opts.labelText;
      label.htmlFor = fieldId;

      field = document.createElement('input');
      field.className = 'ebs-slider__field';
      field.type = 'text';
      field.id = fieldId;
      field.autocomplete = 'off';
      field.inputMode = 'decimal';
      field.spellcheck = false;
      field.setAttribute('aria-label',
        opts.quantityName + (opts.unitWords ? ' in ' + opts.unitWords : ''));

      // The unit symbol is MathJax-typeset; the spoken unit comes from the
      // field's aria-label and the thumb's aria-valuetext, so this is hidden
      // from assistive technology. Unitless sliders keep the empty column so
      // the value fields still line up down the panel.
      units = document.createElement('span');
      units.className = 'ebs-slider__units';
      units.setAttribute('aria-hidden', 'true');
      if (opts.unitsTeX) { units.textContent = '\\(' + opts.unitsTeX + '\\)'; }
      else { units.setAttribute('data-empty', 'true'); }
    }

    var track = document.createElement('div');
    track.className = 'ebs-slider__track';
    var shadeL = document.createElement('div');
    shadeL.className = 'ebs-slider__shade';
    var shadeR = document.createElement('div');
    shadeR.className = 'ebs-slider__shade';
    var thumb = document.createElement('div');
    thumb.className = 'ebs-slider__thumb';
    thumb.setAttribute('role', 'slider');
    thumb.tabIndex = 0;
    thumb.setAttribute('aria-label',
      opts.quantityName + (opts.unitWords ? ' in ' + opts.unitWords : ''));
    thumb.setAttribute('aria-valuemin', String(opts.minValue));
    thumb.setAttribute('aria-valuemax', String(opts.maxValue));
    thumb.setAttribute('aria-orientation', 'horizontal');
    track.appendChild(shadeL);
    track.appendChild(shadeR);
    track.appendChild(thumb);

    if (label) { root.appendChild(label); }
    if (field) { root.appendChild(field); }
    if (units) { root.appendChild(units); }
    root.appendChild(track);
    mount.appendChild(root);

    this.root = root;
    this.field = field;
    this.track = track;
    this.thumb = thumb;
    this.shadeL = shadeL;
    this.shadeR = shadeR;

    // slider min/max and (initially unrestricted) range
    this.setSliderMin(opts.minValue);
    this.setSliderMax(opts.maxValue);

    // ticks per arrow press: the original moved 1 internal tick per bar click,
    // which is far too fine for keyboard use on the high-resolution sliders;
    // scale so ~150 presses cross the whole range (Shift+Arrow = 1 tick).
    this.arrowTicks = this.computeArrowTicks();

    // ---- pointer: thumb drag (grabberMC.onPress offset math) ----
    var dragOffsetPx = null;
    thumb.addEventListener('pointerdown', function (e) {
      e.preventDefault();
      thumb.focus();
      var rect = track.getBoundingClientRect();
      var thumbX = self.fracFromValue(self._value) * rect.width;
      dragOffsetPx = (e.clientX - rect.left) - thumbX;
      thumb.setPointerCapture(e.pointerId);
    });
    thumb.addEventListener('pointermove', function (e) {
      if (dragOffsetPx === null) { return; }
      var rect = track.getBoundingClientRect();
      var frac = ((e.clientX - rect.left) - dragOffsetPx) / rect.width;
      self.setValue(self.valueFromFrac(frac), true);
    });
    function endThumbDrag() {
      if (dragOffsetPx !== null) {
        dragOffsetPx = null;
        self.announceCommit();
      }
    }
    thumb.addEventListener('pointerup', endThumbDrag);
    thumb.addEventListener('pointercancel', endThumbDrag);

    // ---- pointer: bar press + 500 ms hold auto-repeat (barMC handlers) ----
    var barHold = null;
    track.addEventListener('pointerdown', function (e) {
      if (e.target === thumb) { return; }
      e.preventDefault();
      thumb.focus();
      var dir = (self.fracFromClientX(e.clientX) > self.fracFromValue(self._value)) ? 1 : -1;
      self.incrementValue(dir * self.arrowTicks, true);
      track.setPointerCapture(e.pointerId);
      barHold = { clientX: e.clientX, startAuto: performance.now() + CONTINUOUS_DELAY, raf: 0 };
      var step = function () {
        if (!barHold) { return; }
        if (performance.now() > barHold.startAuto) {
          var frac = self.fracFromClientX(barHold.clientX);
          var cur = self.fracFromValue(self._value);
          if (frac > cur) { self.incrementValue(self.arrowTicks, true); }
          else if (frac < cur) { self.incrementValue(-self.arrowTicks, true); }
        }
        barHold.raf = requestAnimationFrame(step);
      };
      barHold.raf = requestAnimationFrame(step);
    });
    track.addEventListener('pointermove', function (e) {
      if (barHold) { barHold.clientX = e.clientX; }
    });
    function endBarHold() {
      if (barHold) {
        cancelAnimationFrame(barHold.raf);
        barHold = null;
        self.announceCommit();
      }
    }
    track.addEventListener('pointerup', endBarHold);
    track.addEventListener('pointercancel', endBarHold);

    // ---- keyboard on thumb ----
    var keyAnnounceTimer = 0;
    thumb.addEventListener('keydown', function (e) {
      var handled = true;
      var step = e.shiftKey ? 1 : self.arrowTicks;
      var pageStep = self.arrowTicks * 10;
      switch (e.key) {
        case 'ArrowLeft':
        case 'ArrowDown': self.incrementValue(-step, true); break;
        case 'ArrowRight':
        case 'ArrowUp': self.incrementValue(step, true); break;
        case 'PageDown': self.incrementValue(-pageStep, true); break;
        case 'PageUp': self.incrementValue(pageStep, true); break;
        case 'Home': self.setValue(self._sliderMin, true); break;
        case 'End': self.setValue(self._sliderMax, true); break;
        default: handled = false;
      }
      if (handled) {
        e.preventDefault();
        clearTimeout(keyAnnounceTimer);
        keyAnnounceTimer = setTimeout(function () { self.announceCommit(); }, 600);
      }
    });

    // ---- numeric field (valueField behavior; commit on Enter/blur) ----
    if (field) {
      field.addEventListener('input', function () {
        var cleaned = field.value.replace(/[^0-9.Ee+\-]/g, ''); // restrict = "0-9.Ee+\-"
        if (cleaned !== field.value) { field.value = cleaned; }
      });
      field.addEventListener('keydown', function (e) {
        if (e.key === 'Enter') { e.preventDefault(); self.commitField(); }
      });
      field.addEventListener('blur', function () { self.commitField(); });
    }

    this.setValue(opts.initValue, false);
  }

  // internal ticks moved by one arrow press
  SliderV5.prototype.computeArrowTicks = function () {
    var TARGET = 150;
    if (this._precisionMode === 1) {
      var step = (this._sliderMax - this._sliderMin) / TARGET;
      var mag = Math.pow(10, Math.floor(Math.log(Math.abs(step) || 1) / LN10));
      var norm = step / mag;
      var nice = (norm < 1.5) ? 1 : (norm < 3.5) ? 2 : (norm < 7.5) ? 5 : 10;
      step = nice * mag;
      if (!(step > this._minIncrement)) { step = this._minIncrement; }
      return Math.max(1, Math.round(step / this._minIncrement));
    }
    var decades = Math.log(this._sliderMax / this._sliderMin) / LN10;
    return Math.max(1, Math.round(0.9 * this._tickResolution * decades / TARGET));
  };

  SliderV5.prototype.setSliderMin = function (arg) {
    this._sliderMin = arg;
    this._rangeMin = arg;
    this.calculateScale();
  };

  SliderV5.prototype.setSliderMax = function (arg) {
    this._sliderMax = arg;
    this._rangeMax = arg;
    this.calculateScale();
  };

  SliderV5.prototype.calculateScale = function () {
    if (this._scaleMode === 1 && this._sliderMin > 0) {
      this._logSliderMin = Math.log(this._sliderMin);
      this._logSpan = Math.log(this._sliderMax) - this._logSliderMin;
    }
  };

  // value <-> track fraction (0..1), replacing pixel positions
  SliderV5.prototype.fracFromValue = function (val) {
    if (this._scaleMode === 0) {
      return (val - this._sliderMin) / (this._sliderMax - this._sliderMin);
    }
    return (Math.log(val) - this._logSliderMin) / this._logSpan;
  };

  SliderV5.prototype.valueFromFrac = function (frac) {
    if (this._scaleMode === 0) {
      return this._sliderMin + frac * (this._sliderMax - this._sliderMin);
    }
    return Math.exp(this._logSliderMin + frac * this._logSpan);
  };

  SliderV5.prototype.fracFromClientX = function (clientX) {
    var rect = this.track.getBoundingClientRect();
    return (clientX - rect.left) / rect.width;
  };

  // setValue - verbatim snapping from sliderV5Component.setValue
  SliderV5.prototype.setValue = function (arg, callHandler) {
    var x = Number(arg);
    if (isFinite(x) && !isNaN(x)) {
      if (x < this._sliderMin) { x = this._sliderMin; }
      else if (x > this._sliderMax) { x = this._sliderMax; }
      if (this._precisionMode === 0) {
        this._valueDecade = 1 + Math.floor(Math.log(x) / LN10);
        this._valuePow = Math.pow(10, this._valueDecade);
        this._valueTick = Math.round(x * this._tickResolution / this._valuePow);
        if (this._valueTick === this._tickResolution) {
          this._valueTick = this._tickResolution / 10;
          this._valueDecade++;
          this._valuePow = Math.pow(10, this._valueDecade);
        }
        this._value = this._valueTick / this._tickResolution * this._valuePow;
        this._prec = this._sigs - this._valueDecade;
      } else {
        this._value = this._minIncrement * Math.round(x / this._minIncrement);
      }
      this.updateDisplay();
      if (callHandler && this.changeHandler) { this.changeHandler(this._value); }
    } else {
      this.updateDisplay();
    }
  };

  Object.defineProperty(SliderV5.prototype, 'value', {
    get: function () { return this._value; },
    set: function (arg) { this.setValue(arg, false); }
  });

  Object.defineProperty(SliderV5.prototype, 'sliderMin', {
    get: function () { return this._sliderMin; }
  });

  Object.defineProperty(SliderV5.prototype, 'sliderMax', {
    get: function () { return this._sliderMax; }
  });

  // incrementValue - verbatim from sliderV5Component.incrementValue
  SliderV5.prototype.incrementValue = function (deltaTicks, callHandler) {
    if (this._precisionMode === 0) {
      var ticksPerDecade = 0.9 * this._tickResolution;
      var fracDecades = deltaTicks / ticksPerDecade;
      var deltaDecade = 0;
      if (fracDecades >= 1) {
        deltaDecade = Math.floor(fracDecades);
        deltaTicks -= deltaDecade * ticksPerDecade;
      } else if (fracDecades <= -1) {
        deltaDecade = Math.ceil(fracDecades);
        deltaTicks -= deltaDecade * ticksPerDecade;
      }
      var newTick = this._valueTick + deltaTicks;
      var newDecade = this._valueDecade + deltaDecade;
      if (newTick >= this._tickResolution) {
        newTick -= ticksPerDecade;
        newDecade++;
      } else if (newTick < 0.1 * this._tickResolution) {
        newTick += ticksPerDecade;
        newDecade--;
      }
      this.setValue(Math.pow(10, newDecade) * newTick / this._tickResolution, callHandler);
    } else {
      this.setValue(this._value + deltaTicks * this._minIncrement, callHandler);
    }
  };

  SliderV5.prototype.getRange = function () {
    return { min: this._rangeMin, max: this._rangeMax };
  };

  // setRange - verbatim clamping from sliderV5Component.setRange; the range is
  // purely visual (dark shading): value clamping happens in the sim handlers.
  SliderV5.prototype.setRange = function (min, max) {
    if (min > this._sliderMax) { min = this._sliderMax; }
    else if (min < this._sliderMin) { min = this._sliderMin; }
    if (max > this._sliderMax) { max = this._sliderMax; }
    else if (max < this._sliderMin) { max = this._sliderMin; }
    if (min > max) { var tmp = max; max = min; min = tmp; }
    this._rangeMin = min;
    this._rangeMax = max;
    this.setValue(this._value, false);
    this.updateBar();
  };

  // sliderV5DefaultBar.updateBar - shade the excluded parts of the track
  SliderV5.prototype.updateBar = function () {
    var fMin = this.fracFromValue(this._rangeMin) * 100;
    var fMax = this.fracFromValue(this._rangeMax) * 100;
    this.shadeL.style.left = '0%';
    this.shadeL.style.width = Math.max(0, fMin) + '%';
    this.shadeR.style.left = Math.min(100, fMax) + '%';
    this.shadeR.style.width = Math.max(0, 100 - fMax) + '%';
  };

  SliderV5.prototype.valueString = function () {
    if (this._prec > 0) { return asToFixed(this._value, this._prec); }
    return String(this._value);
  };

  SliderV5.prototype.spokenValue = function () {
    var s = this.opts.quantityName + ' ' + this.valueString();
    if (this.opts.unitWords) { s += ' ' + this.opts.unitWords; }
    return s;
  };

  SliderV5.prototype.announceCommit = function () {
    if (this.opts.announce) { this.opts.announce(this); }
  };

  SliderV5.prototype.updateDisplay = function () {
    var pct = this.fracFromValue(this._value) * 100;
    this.thumb.style.left = Math.max(0, Math.min(100, pct)) + '%';
    this.thumb.setAttribute('aria-valuenow', String(this._value));
    this.thumb.setAttribute('aria-valuetext',
      this.opts.quantityName + ' ' + this.valueString() +
      (this.opts.unitWords ? ' ' + this.opts.unitWords : ''));
    if (this.field) { this.field.value = this.valueString(); }
  };

  SliderV5.prototype.commitField = function () {
    if (!this.field) { return; }
    var v = parseFloat(this.field.value);
    if (typeof v === 'number' && isFinite(v) && !isNaN(v)) {
      this.setValue(v, true);
    } else {
      this.updateDisplay();
    }
    this.announceCommit();
  };

  /* ========================================================================
     The rest of the sim is assembled in ebs-main.js style below: the
     visualization, lightcurve, HR diagram and controller are attached to
     this closure in the sections that follow.
     ======================================================================== */

  window.__EBS__ = {
    LN10: LN10, DEG2RAD: DEG2RAD, RAD2DEG: RAD2DEG, TWO_PI: TWO_PI,
    toSigDigits: toSigDigits, asToFixed: asToFixed,
    getRfromTL: getRfromTL, getLfromRT: getLfromRT, getTfromLR: getTfromLR,
    getLfromT: getLfromT, getTfromL: getTfromL, getLfromM: getLfromM,
    getMfromL: getMfromL, getTfromR: getTfromR,
    getColorFromTemp: getColorFromTemp,
    systemsArray: systemsArray,
    completeSystemsStart: completeSystemsStart,
    incompleteSystemsStart: incompleteSystemsStart,
    extraSystemsStart: extraSystemsStart,
    SliderV5: SliderV5,
    announce: announce,
    typesetMath: typesetMath,
    setLiveRegion: function (el) { liveStatus = el; }
  };
})();

/* ==========================================================================
   PART 2 - Binary System visualization: canvas port of "Binary System.as".
   All drawing keeps the original stage coordinate system (400 x 400 canvas,
   origin at the center); CSS scales the canvas element.
   ========================================================================== */
(function () {
  'use strict';
  var E = window.__EBS__;
  var DEG2RAD = E.DEG2RAD;
  var RAD2DEG = E.RAD2DEG;
  var TWO_PI = E.TWO_PI;

  function BinarySystem(canvas) {
    this.canvas = canvas;
    this.ctx = canvas.getContext('2d');
    this.cx = 200;                       // stage center
    this.cy = 200;

    // styles - verbatim from Binary System.as prototype constants
    this.orbitalPathStyle = { thickness: 1, color: '#ffffff', alpha: 0.7 };
    this.gridFillStyle = { color: '#b0b0b0', alpha: 0.4 };       // 11579568
    this.gridLineStyle = { thickness: 1, color: '#909090' };     // 9474192
    this.axisGridLineStyle = { thickness: 1, color: '#4da94d', alpha: 0.65 }; // 5089613
    this.minGridLineAlpha = 0.05;   // 5/100
    this.maxGridLineAlpha = 0.5;    // 50/100
    this.minGridSpacing = 20;
    this.objectEquatorStyle = { thickness: 1, color: '#b0b0b0', alpha: 0.8 };
    this.lineThickness = 2;
    this.lineColor = '#ff8080';     // 16744576

    this._c = {};
    this._s1 = { x: 0, y: 0, z: 0 };
    this._s2 = { x: 0, y: 0, z: 0 };
    this.color1 = '#ffffff';
    this.color2 = '#ffffff';
    this.comImg = null;             // reused exported Center of Mass Marker
  }

  var p = BinarySystem.prototype;

  // initialize(initObject) - verbatim option handling
  p.initialize = function (o) {
    if (o.autoScale !== undefined) { this._autoScale = Boolean(o.autoScale); }
    if (o.targetSize !== undefined) { this._targetSize = o.targetSize; }
    if (o.showOrbitalPaths !== undefined) { this._showOrbitalPaths = Boolean(o.showOrbitalPaths); }
    if (o.showOrbitalPlane !== undefined) { this._showOrbitalPlane = Boolean(o.showOrbitalPlane); }
    if (o.phi !== undefined && !(o.phi < -90 || o.phi > 90)) { this._phi = o.phi * DEG2RAD; }
    if (o.theta !== undefined) { this._theta = o.theta * DEG2RAD; }
    if (o.scale !== undefined) { this._scale = o.scale; }
    if (o.phase !== undefined) { this._phase = ((o.phase % 1) + 1) % 1; }
    if (o.radius1 !== undefined) { this._radius1 = o.radius1; }
    if (o.radius2 !== undefined) { this._radius2 = o.radius2; }
    if (o.eccentricity !== undefined) { this._eccentricity = o.eccentricity; }
    if (o.mass1 !== undefined) { this._mass1 = o.mass1; }
    if (o.mass2 !== undefined) { this._mass2 = o.mass2; }
    if (o.separation !== undefined) { this._separation = o.separation; }
    if (o.linePhi !== undefined) { this._linePhi = o.linePhi; }
    if (o.lineTheta !== undefined) { this._lineTheta = o.lineTheta; }
    if (o.showLine !== undefined) { this._showLine = Boolean(o.showLine); }
    if (o.lineExtra !== undefined) { this._lineExtra = o.lineExtra; }
    this._massTotal = this._mass1 + this._mass2;
    this._a1 = this._separation * this._mass2 / this._massTotal;
    this._a2 = this._separation * this._mass1 / this._massTotal;
    if (this._autoScale) { this.rescale(); }
    this.requestRender();
  };

  // rescale() - fit the system into targetSize
  p.rescale = function () {
    var h = Math.max(this._a1 * (1 + this._eccentricity) + this._radius1,
      this._a2 * (1 + this._eccentricity) + this._radius2);
    this._scale = this._targetSize / (2 * h);
  };

  // doA() - view matrix including scale (verbatim)
  p.doA = function () {
    var c = this._c;
    var ct = Math.cos(this._theta);
    var st = Math.sin(this._theta);
    var cp = Math.cos(this._phi);
    var sp = Math.sin(this._phi);
    var s = this._scale;
    c.a0 = -s * st;
    c.a1 = s * ct;
    c.a3 = s * ct * sp;
    c.a4 = s * st * sp;
    c.a5 = -s * cp;
    c.a6 = s * ct * cp;
    c.a7 = s * st * cp;
    c.a8 = s * sp;
  };

  // updatePositions() - Kepler solve + world->screen (verbatim math)
  p.updatePositions = function () {
    var sin = Math.sin, abs = Math.abs;
    var ma = this._phase * TWO_PI;
    var e = this._eccentricity;
    var ea0 = 0;
    var ea1 = ma + e * sin(ma);
    var c = 0;
    do {
      ea0 = ea1;
      ea1 = ma + e * sin(ea0);
      c++;
    } while (abs(ea1 - ea0) > 0.001 && c < 100);
    var ta = 2 * Math.atan(Math.sqrt((1 + e) / (1 - e)) * Math.tan(ea1 / 2));
    var cosTa = Math.cos(ta);
    var sinTa = sin(ta);
    var k = (1 - e * e) / (1 + e * cosTa);
    var r1 = this._a1 * k;
    var r2 = this._a2 * k;
    var wx1 = -r1 * cosTa, wy1 = -r1 * sinTa;
    var wx2 = r2 * cosTa, wy2 = r2 * sinTa;
    var m = this._c;
    this._s1 = {
      x: wx1 * m.a0 + wy1 * m.a1,
      y: wx1 * m.a3 + wy1 * m.a4,
      z: wx1 * m.a6 + wy1 * m.a7
    };
    this._s2 = {
      x: wx2 * m.a0 + wy2 * m.a1,
      y: wx2 * m.a3 + wy2 * m.a4,
      z: wx2 * m.a6 + wy2 * m.a7
    };
  };

  // plane-space (world z=0) -> screen
  p.planeToScreen = function (x, y) {
    var c = this._c;
    return { x: x * c.a0 + y * c.a1, y: x * c.a3 + y * c.a4 };
  };

  /* ---------------- drawing helpers (each mirrors an AS method) --------- */

  // updateOrbitalPlane(): grid fill + grid lines (verbatim geometry)
  p.drawOrbitalPlane = function (ctx) {
    if (!this._showOrbitalPlane) { return; }
    var ceil = Math.ceil;
    var s = this._scale;
    var e = this._eccentricity;
    var a1 = this._a1, a2 = this._a2;
    var k = Math.sqrt(1 - e * e);
    var b1 = a1 * k, b2 = a2 * k;
    var r1 = this._radius1, r2 = this._radius2;
    var leftFillExtent = -Math.max(a2 * (1 + e) + 1.75 * r2, a1 * (1 - e) + 1.75 * r1);
    var rightFillExtent = Math.max(a1 * (1 + e) + 1.75 * r1, a2 * (1 - e) + 1.75 * r2);
    var topFillExtent = Math.max(b1 + 1.75 * r1, b2 + 1.75 * r2);
    var bottomFillExtent = -topFillExtent;

    var self = this;
    function moveLine(x1, y1, x2, y2) {
      var p1 = self.planeToScreen(x1, y1);
      var p2 = self.planeToScreen(x2, y2);
      ctx.moveTo(p1.x, p1.y);
      ctx.lineTo(p2.x, p2.y);
    }

    // translucent plane fill (grid rectangle becomes a parallelogram on screen)
    var c1 = this.planeToScreen(leftFillExtent, bottomFillExtent);
    var c2 = this.planeToScreen(leftFillExtent, topFillExtent);
    var c3 = this.planeToScreen(rightFillExtent, topFillExtent);
    var c4 = this.planeToScreen(rightFillExtent, bottomFillExtent);
    ctx.globalAlpha = this.gridFillStyle.alpha;
    ctx.fillStyle = this.gridFillStyle.color;
    ctx.beginPath();
    ctx.moveTo(c1.x, c1.y);
    ctx.lineTo(c2.x, c2.y);
    ctx.lineTo(c3.x, c3.y);
    ctx.lineTo(c4.x, c4.y);
    ctx.closePath();
    ctx.fill();
    ctx.globalAlpha = 1;

    // grid spacing (verbatim: 20 screen px minimum -> 1/2/5 decades)
    var m = this.minGridSpacing / s;
    var lg = Math.log(m) / E.LN10;
    var kk = ceil(lg);
    var spacing, belowSpacing, majorMultiple;
    if (kk - lg > 0.30102999566398114) {
      belowSpacing = Math.pow(10, kk - 1);
      spacing = 5 * belowSpacing;
      majorMultiple = 2;
    } else {
      spacing = Math.pow(10, kk);
      belowSpacing = 0.5 * spacing;
      majorMultiple = 5;
    }
    var leftGridExtent = ceil(leftFillExtent / spacing);
    var rightGridLimit = ceil(rightFillExtent / spacing);
    var topGridLimit = ceil(topFillExtent / spacing);
    var bottomGridExtent = ceil(bottomFillExtent / spacing);
    var minorAlpha = this.minGridLineAlpha + (this.maxGridLineAlpha - this.minGridLineAlpha) *
      (spacing - m) / (spacing - belowSpacing);
    var majorAlpha = this.maxGridLineAlpha;

    function strokeLine(alpha, color, width, x1, y1, x2, y2) {
      ctx.globalAlpha = alpha;
      ctx.strokeStyle = color;
      ctx.lineWidth = width;
      ctx.beginPath();
      moveLine(x1, y1, x2, y2);
      ctx.stroke();
      ctx.globalAlpha = 1;
    }

    var gs = this.gridLineStyle, as = this.axisGridLineStyle;
    var i, alpha, color, width;
    // vertical (constant-x) lines
    for (i = leftGridExtent; i < rightGridLimit; i++) {
      alpha = (i === 0) ? as.alpha : (i % majorMultiple === 0) ? majorAlpha : minorAlpha;
      color = (i === 0) ? as.color : gs.color;
      width = (i === 0) ? as.thickness : gs.thickness;
      strokeLine(alpha, color, width, i * spacing, bottomFillExtent, i * spacing, topFillExtent);
    }
    // horizontal (constant-y) lines
    for (i = bottomGridExtent; i < topGridLimit; i++) {
      alpha = (i === 0) ? as.alpha : (i % majorMultiple === 0) ? majorAlpha : minorAlpha;
      color = (i === 0) ? as.color : gs.color;
      width = (i === 0) ? as.thickness : gs.thickness;
      strokeLine(alpha, color, width, leftFillExtent, i * spacing, rightFillExtent, i * spacing);
    }
  };

  // updateOrbitalPaths(): two ellipses drawn with 12 quadratic segments
  p.drawOrbitalPaths = function (ctx) {
    if (!this._showOrbitalPaths) { return; }
    var cos = Math.cos, sin = Math.sin;
    var e = this._eccentricity;
    var n = 12;
    var step = TWO_PI / n;
    var a1 = this._a1, a2 = this._a2;
    var k = Math.sqrt(1 - e * e);
    var b1 = a1 * k, b2 = a2 * k;
    var kc = 1 / cos(step / 2);
    var self = this;

    ctx.globalAlpha = this.orbitalPathStyle.alpha;
    ctx.strokeStyle = this.orbitalPathStyle.color;
    ctx.lineWidth = this.orbitalPathStyle.thickness;

    function drawPath(aa, ab, dx) {
      var ca = aa * kc, cb = ab * kc;
      var aAngle = 0;
      var cAngle = -step / 2;
      var p0 = self.planeToScreen(aa * cos(aAngle) + dx, ab * sin(aAngle));
      ctx.beginPath();
      ctx.moveTo(p0.x, p0.y);
      for (var i = 0; i < n; i++) {
        aAngle += step;
        cAngle += step;
        var cp = self.planeToScreen(ca * cos(cAngle) + dx, cb * sin(cAngle));
        var ap = self.planeToScreen(aa * cos(aAngle) + dx, ab * sin(aAngle));
        ctx.quadraticCurveTo(cp.x, cp.y, ap.x, ap.y);
      }
      ctx.stroke();
    }
    drawPath(a1, b1, a1 * e);
    drawPath(a2, b2, -a2 * e);
    ctx.globalAlpha = 1;
  };

  // updateMask() geometry: front-cap clip path for one body, in screen px
  // relative to the body center. Verbatim 12-segment tessellation.
  p.buildMaskPath = function (ctx, num) {
    var aRad = this._scale * ((num === 1) ? this._radius1 : this._radius2);
    var cos = Math.cos, sin = Math.sin;
    var n = 12;
    var hn = n / 2;
    var step = TWO_PI / n;
    var cRad = aRad / cos(step / 2);
    var aAngle = 0;
    var cAngle = -step / 2;
    ctx.moveTo(aRad * cos(aAngle), -aRad * sin(aAngle));
    var ak, ck;
    if (this._phi > 0) { ak = -aRad; ck = -cRad; }
    else { ak = aRad; ck = cRad; }
    var i;
    for (i = 0; i < hn; i++) {
      aAngle += step;
      cAngle += step;
      ctx.quadraticCurveTo(cRad * cos(cAngle), ck * sin(cAngle),
        aRad * cos(aAngle), ak * sin(aAngle));
    }
    ak = -aRad * sin(this._phi);
    ck = -cRad * sin(this._phi);
    for (i = hn; i < n; i++) {
      aAngle += step;
      cAngle += step;
      ctx.quadraticCurveTo(cRad * cos(cAngle), ck * sin(cAngle),
        aRad * cos(aAngle), ak * sin(aAngle));
    }
  };

  // the equator half-ellipse stroked on the front hemisphere
  p.drawEquator = function (ctx, num) {
    if (!this._showOrbitalPlane) { return; }
    var aRad = this._scale * ((num === 1) ? this._radius1 : this._radius2);
    var cos = Math.cos, sin = Math.sin;
    var n = 12;
    var hn = n / 2;
    var step = TWO_PI / n;
    var cRad = aRad / cos(step / 2);
    var ak = -aRad * sin(this._phi);
    var ck = -cRad * sin(this._phi);
    var aAngle = Math.PI;         // continue from angle pi like the source
    var cAngle = Math.PI - step / 2;
    ctx.globalAlpha = this.objectEquatorStyle.alpha;
    ctx.strokeStyle = this.objectEquatorStyle.color;
    ctx.lineWidth = this.objectEquatorStyle.thickness;
    ctx.beginPath();
    ctx.moveTo(-aRad, 0);
    for (var i = hn; i < n; i++) {
      aAngle += step;
      cAngle += step;
      ctx.quadraticCurveTo(cRad * cos(cAngle), ck * sin(cAngle),
        aRad * cos(aAngle), ak * sin(aAngle));
    }
    ctx.stroke();
    ctx.globalAlpha = 1;
  };

  // star disc: flat temperature color (discMC tinted via Color.setRGB) with
  // the reused highlight gradient (shape 172: white 70% -> 45% -> 10% alpha)
  p.drawStarDisc = function (ctx, num) {
    var aRad = this._scale * ((num === 1) ? this._radius1 : this._radius2);
    var color = (num === 1) ? this.color1 : this.color2;
    ctx.beginPath();
    ctx.arc(0, 0, aRad, 0, TWO_PI);
    ctx.fillStyle = color;
    ctx.fill();
    var g = ctx.createRadialGradient(0, 0, 0, 0, 0, aRad * 1.014); // 819.2*0.1238/100
    g.addColorStop(0, 'rgba(255,255,255,0.7019608)');
    g.addColorStop(0.6666666666666666, 'rgba(255,255,255,0.4509804)');
    g.addColorStop(1, 'rgba(255,255,255,0.101960786)');
    ctx.fillStyle = g;
    ctx.fill();
  };

  // updateLine(): earth-direction line, split into region segments (verbatim)
  p.computeLine = function () {
    var result = { half: 'front', A: [], B: [], C: [] };
    if (!this._showLine) { return null; }
    var pow = Math.pow, sqrt = Math.sqrt;
    var lineTheta = this._lineTheta * DEG2RAD;
    var linePhi = this._linePhi * DEG2RAD;
    var lineLength = (this._lineExtra + this._targetSize / 2) / this._scale;
    if (!(linePhi === 0 || (linePhi > 0 && this._phi > 0) || (linePhi < 0 && this._phi <= 0))) {
      result.half = 'back';
    }
    var k1 = -Math.sin(lineTheta);
    var k4 = Math.cos(lineTheta);
    var k6 = Math.sin(linePhi);
    var k0 = k4 * Math.cos(linePhi);
    var k3 = -k1 * Math.cos(linePhi);
    var x = lineLength * k0;
    var y = lineLength * k3;
    var z = lineLength * k6;
    var c = this._c;
    var xe = x * c.a0 + y * c.a1;
    var ye = x * c.a3 + y * c.a4 + z * c.a5;
    var ze = x * c.a6 + y * c.a7 + z * c.a8;
    var r1 = this._radius1 * this._scale;
    var r2 = this._radius2 * this._scale;
    var s1 = this._s1, s2 = this._s2;
    var xf, yf, zf, xb, yb, zb, rf2, rb2;
    if (s1.z > s2.z) {
      xf = s1.x; yf = s1.y; zf = s1.z; xb = s2.x; yb = s2.y; zb = s2.z;
      rf2 = r1 * r1; rb2 = r2 * r2;
    } else {
      xf = s2.x; yf = s2.y; zf = s2.z; xb = s1.x; yb = s1.y; zb = s1.z;
      rf2 = r2 * r2; rb2 = r1 * r1;
    }
    function getRegion(u) {
      var mx = u * xe, my = u * ye, mz = u * ze;
      if (pow(mx - xf, 2) + pow(my - yf, 2) + pow(mz - zf, 2) < rf2) { return null; }
      if (pow(mx - xb, 2) + pow(my - yb, 2) + pow(mz - zb, 2) < rb2) { return null; }
      if (mz >= zf) { return result.A; }
      if (mz >= zb) { return result.B; }
      return result.C;
    }
    var uArr = [0, 1];
    var a = xe * xe + ye * ye + ze * ze;
    var bf = -2 * (xe * xf + ye * yf + ze * zf);
    var cf = xf * xf + yf * yf + zf * zf - rf2;
    var bb = -2 * (xe * xb + ye * yb + ze * zb);
    var cb = xb * xb + yb * yb + zb * zb - rb2;
    var df = bf * bf - 4 * a * cf;
    var db = bb * bb - 4 * a * cb;
    if (df > 0) {
      uArr.push((-bf + sqrt(df)) / (2 * a));
      uArr.push((-bf - sqrt(df)) / (2 * a));
    }
    if (db > 0) {
      uArr.push((-bb + sqrt(db)) / (2 * a));
      uArr.push((-bb - sqrt(db)) / (2 * a));
    }
    if (ze !== 0) {
      uArr.push(zf / ze);
      uArr.push(zb / ze);
    }
    uArr.sort(function (q, w) { return q - w; });
    var ux = 0, uy = 0;
    var lu = 0;
    var nu = uArr[0];
    var i = 0;
    while (uArr[i] !== 1 && i < uArr.length) {
      lu = nu;
      nu = uArr[i + 1];
      if (lu >= 0) {
        var seg = getRegion(lu + (nu - lu) / 2);
        var sx = ux, sy = uy;
        ux = nu * xe;
        uy = nu * ye;
        if (seg) { seg.push([sx, sy, ux, uy]); }
      }
      i++;
    }
    // arrow head (verbatim)
    var arrowX = (this._lineExtra + this._targetSize / 2 - 0.6666666666666666 * this._lineExtra) / this._scale;
    var arrowY1 = 0.25 * this._lineExtra / this._scale;
    var arrowY2 = -arrowY1;
    var a1x = k0 * arrowX + k1 * arrowY1;
    var a1y = k3 * arrowX + k4 * arrowY1;
    var a2x = k0 * arrowX + k1 * arrowY2;
    var a2y = k3 * arrowX + k4 * arrowY2;
    var az = k6 * arrowX;
    var ax1 = a1x * c.a0 + a1y * c.a1;
    var ay1 = a1x * c.a3 + a1y * c.a4 + az * c.a5;
    var ax2 = a2x * c.a0 + a2y * c.a1;
    var ay2 = a2x * c.a3 + a2y * c.a4 + az * c.a5;
    var tip = getRegion(1);
    if (tip) {
      tip.push([ax1, ay1, xe, ye]);
      tip.push([xe, ye, ax2, ay2]);
    }
    return result;
  };

  p.drawLineRegion = function (ctx, segs) {
    if (!segs || !segs.length) { return; }
    ctx.strokeStyle = this.lineColor;
    ctx.lineWidth = this.lineThickness;
    ctx.beginPath();
    for (var i = 0; i < segs.length; i++) {
      ctx.moveTo(segs[i][0], segs[i][1]);
      ctx.lineTo(segs[i][2], segs[i][3]);
    }
    ctx.stroke();
  };

  /* ------------------------- full frame render -------------------------- */
  p.render = function () {
    var ctx = this.ctx;
    var dpr = this.dpr || 1;
    ctx.setTransform(dpr, 0, 0, dpr, 0, 0);
    ctx.fillStyle = '#000000';
    ctx.fillRect(0, 0, 400, 400);
    ctx.save();
    ctx.translate(this.cx, this.cy);

    this.doA();
    this.updatePositions();
    var line = this.computeLine();

    var s1 = this._s1, s2 = this._s2;
    // body order by screen z: higher z drawn later (swapDepths(200))
    var lowNum = (s1.z > s2.z) ? 2 : 1;
    var highNum = (s1.z > s2.z) ? 1 : 2;
    var lowPos = (lowNum === 1) ? s1 : s2;
    var highPos = (highNum === 1) ? s1 : s2;
    var self = this;

    function drawBodyFull(num, pos) {
      ctx.save();
      ctx.translate(pos.x, pos.y);
      self.drawStarDisc(ctx, num);
      ctx.restore();
    }

    function drawBodyMasked(num, pos) {
      ctx.save();
      ctx.translate(pos.x, pos.y);
      ctx.beginPath();
      self.buildMaskPath(ctx, num);
      ctx.clip();
      self.drawStarDisc(ctx, num);
      self.drawEquator(ctx, num);
      ctx.restore();
    }

    var backLine = (line && line.half === 'back') ? line : null;
    var frontLine = (line && line.half === 'front') ? line : null;

    // ---- back half: regionC, low body, regionB, high body, regionA ----
    if (backLine) { this.drawLineRegion(ctx, backLine.C); }
    drawBodyFull(lowNum, lowPos);
    if (backLine) { this.drawLineRegion(ctx, backLine.B); }
    drawBodyFull(highNum, highPos);
    if (backLine) { this.drawLineRegion(ctx, backLine.A); }

    // ---- orbital plane: grid fill/lines, paths, CoM marker ----
    this.drawOrbitalPlane(ctx);
    this.drawOrbitalPaths(ctx);
    // reused exported asset: Center of Mass Marker sprite (green cross).
    // It sits inside the orbital-plane container in the original, so it
    // inherits the plane rotation and sin(phi) squash (but not the zoom).
    if (this.comImg && this.comImg.complete && this.comImg.naturalWidth > 0) {
      var st = Math.sin(this._theta), ct = Math.cos(this._theta), sp = Math.sin(this._phi);
      ctx.save();
      ctx.transform(-st, ct * sp, ct, st * sp, 0, 0);
      ctx.drawImage(this.comImg, -this.comImg.naturalWidth / 2, -this.comImg.naturalHeight / 2);
      ctx.restore();
    }

    // ---- front half: masked upper hemispheres + equators + line ----
    if (frontLine) { this.drawLineRegion(ctx, frontLine.C); }
    drawBodyMasked(lowNum, lowPos);
    if (frontLine) { this.drawLineRegion(ctx, frontLine.B); }
    drawBodyMasked(highNum, highPos);
    if (frontLine) { this.drawLineRegion(ctx, frontLine.A); }

    ctx.restore();
  };

  p.requestRender = function () {
    this.needsRender = true;
  };

  /* ------------ property setters mirroring addProperty pairs ------------ */
  Object.defineProperty(p, 'phase', {
    get: function () { return this._phase; },
    set: function (arg) {
      this._phase = ((arg % 1) + 1) % 1;
      this.requestRender();
    }
  });
  Object.defineProperty(p, 'separation', {
    get: function () { return this._separation; },
    set: function (arg) {
      this._separation = arg;
      this._a1 = this._separation * this._mass2 / this._massTotal;
      this._a2 = this._separation * this._mass1 / this._massTotal;
      if (this._autoScale) { this.rescale(); }
      this.requestRender();
    }
  });
  Object.defineProperty(p, 'eccentricity', {
    get: function () { return this._eccentricity; },
    set: function (arg) {
      this._eccentricity = arg;
      if (this._autoScale) { this.rescale(); }
      this.requestRender();
    }
  });
  Object.defineProperty(p, 'mass1', {
    get: function () { return this._mass1; },
    set: function (arg) {
      this._mass1 = arg;
      this._massTotal = this._mass1 + this._mass2;
      this._a1 = this._separation * this._mass2 / this._massTotal;
      this._a2 = this._separation * this._mass1 / this._massTotal;
      if (this._autoScale) { this.rescale(); }
      this.requestRender();
    }
  });
  Object.defineProperty(p, 'mass2', {
    get: function () { return this._mass2; },
    set: function (arg) {
      this._mass2 = arg;
      this._massTotal = this._mass1 + this._mass2;
      this._a1 = this._separation * this._mass2 / this._massTotal;
      this._a2 = this._separation * this._mass1 / this._massTotal;
      if (this._autoScale) { this.rescale(); }
      this.requestRender();
    }
  });
  Object.defineProperty(p, 'radius1', {
    get: function () { return this._radius1; },
    set: function (arg) {
      this._radius1 = arg;
      if (this._autoScale) { this.rescale(); }
      this.requestRender();
    }
  });
  Object.defineProperty(p, 'radius2', {
    get: function () { return this._radius2; },
    set: function (arg) {
      this._radius2 = arg;
      if (this._autoScale) { this.rescale(); }
      this.requestRender();
    }
  });
  Object.defineProperty(p, 'showOrbitalPaths', {
    get: function () { return this._showOrbitalPaths; },
    set: function (arg) {
      this._showOrbitalPaths = Boolean(arg);
      this.requestRender();
    }
  });
  Object.defineProperty(p, 'showOrbitalPlane', {
    get: function () { return this._showOrbitalPlane; },
    set: function (arg) {
      this._showOrbitalPlane = Boolean(arg);
      this.requestRender();
    }
  });
  Object.defineProperty(p, 'showLine', {
    get: function () { return this._showLine; },
    set: function (arg) {
      this._showLine = Boolean(arg);
      this.requestRender();
    }
  });
  Object.defineProperty(p, 'theta', {
    get: function () { return this._theta * RAD2DEG; },
    set: function (arg) {
      this._theta = arg * DEG2RAD;
      this.requestRender();
    }
  });
  Object.defineProperty(p, 'phi', {
    get: function () { return this._phi * RAD2DEG; },
    set: function (arg) {
      if (arg < -90 || arg > 90) { return; }
      this._phi = arg * DEG2RAD;
      this.requestRender();
    }
  });

  p.setThetaAndPhi = function (t, ph) {
    this._theta = t * DEG2RAD;
    this._phi = ph * DEG2RAD;
    this.requestRender();
  };
  p.setTheta = function (t) { this.theta = t; };
  p.setPhi = function (ph) { this.phi = ph; };

  p.passObjectToIcon = function (num, obj) {
    if (obj && obj.temp !== undefined) {
      if (num === 1) { this.color1 = E.getColorFromTemp(obj.temp); }
      else { this.color2 = E.getColorFromTemp(obj.temp); }
    }
    this.requestRender();
  };

  E.BinarySystem = BinarySystem;
})();

/* ==========================================================================
   PART 3 - Lightcurve: canvas port of "Lightcurve.as".
   Original plot geometry: plotWidth 320, plotHeight 200, top margin 17,
   bottom margin 5, x margin 1  ->  canvas 322 x 222, plot origin at
   canvas (1, 217). CSS scales the canvas element.
   ========================================================================== */
(function () {
  'use strict';
  var E = window.__EBS__;
  var TWO_PI = E.TWO_PI;
  var LN10 = E.LN10;

  function Lightcurve(canvas) {
    this.canvas = canvas;
    this.ctx = canvas.getContext('2d');

    // constants - verbatim from LightcurveClass constructor
    this.plotWidth = 320;
    this.plotHeight = 200;
    this.minMagDiff = 0.01;
    this.yTopMargin = 17;
    this.yBottomMargin = 5;
    this.xMargin = 1;
    this.totalHeight = this.plotHeight + this.yTopMargin + this.yBottomMargin;

    this._numCurvePoints = 300;
    this._positionTable = [];
    for (var i = 0; i < this._numCurvePoints; i++) { this._positionTable[i] = {}; }
    this._dataType = 'visual flux';
    this._c = {};
    this._cursorPhase = 0;
    this._phaseOffset = 0;
    this._closestIndex = 0;
    this.curveVisible = true;      // curveMC.curveMC._visible
    this.cursorHot = false;        // cursor hover/focus state (frame 2)
    this.datasetImg = null;        // reused exported flux-data bitmap
    this.needsRender = true;
  }

  var p = Lightcurve.prototype;
  p.solarRadius = 696000000;       // verbatim

  // setParameters(dataObj) - verbatim dirty-checking cascade
  p.setParameters = function (dataObj) {
    var currObj = this._c;
    if (dataObj.eccentricity !== currObj.eccentricity) {
      this._c = dataObj;
      this.generatePositionTable();
      this.generateOverlapTable();
      this.generateMagnitudeTable();
    } else if (dataObj.separation !== currObj.separation || dataObj.theta !== currObj.theta ||
      dataObj.phi !== currObj.phi || dataObj.radius1 !== currObj.radius1 ||
      dataObj.radius2 !== currObj.radius2) {
      this._c = dataObj;
      this.generateOverlapTable();
      this.generateMagnitudeTable();
    } else if (dataObj.temperature1 !== currObj.temperature1 ||
      dataObj.temperature2 !== currObj.temperature2) {
      this._c = dataObj;
      this.generateMagnitudeTable();
    }
    this.needsRender = true;
  };

  Object.defineProperty(p, 'cursorPhase', {
    get: function () { return this._cursorPhase; },
    set: function (arg) {
      this._cursorPhase = ((arg % 1) + 1) % 1;
      this.needsRender = true;
    }
  });
  p.setCursorPhase = function (arg) { this.cursorPhase = arg; };

  Object.defineProperty(p, 'phaseOffset', {
    get: function () { return this._phaseOffset; },
    set: function (arg) {
      this._phaseOffset = ((arg % 1) + 1) % 1;
      this.needsRender = true;
    }
  });
  p.setPhaseOffset = function (arg) { this.phaseOffset = arg; };

  // displayDataset(name or null): reuse the exported flux bitmap for the
  // preset (Examples have no dataset -> nothing shown, like the original
  // attachMovie of a non-existent linkage).
  p.displayDataset = function (arg) {
    var self = this;
    this.datasetImg = null;
    if (arg) {
      var img = new Image();
      img.onload = function () { self.needsRender = true; };
      img.onerror = function () { self.datasetImg = null; self.needsRender = true; };
      img.src = 'assets/data/' + encodeURIComponent(arg) + '.png';
      this.datasetImg = img;
    }
    this.needsRender = true;
  };

  // generatePositionTable() - verbatim Kepler table (relative orbit)
  p.generatePositionTable = function () {
    var cos = Math.cos, sin = Math.sin, tan = Math.tan, atan = Math.atan, abs = Math.abs;
    var pT = this._positionTable;
    var np = this._numCurvePoints;
    var n = np / 2;
    var step = TWO_PI / np;
    var e = this._c.eccentricity;
    if (isNaN(e) || !isFinite(e) || e >= 1 || e < 0) {
      e = 0;
      this._c.eccentricity = e;
    }
    var k1 = Math.sqrt((1 + e) / (1 - e));
    var k2 = this.solarRadius * (1 - e * e);
    pT[0] = { x: k2 / (1 + e), y: 0 };
    pT[n] = { x: -k2 / (1 - e), y: 0 };
    for (var i = 1; i < n; i++) {
      var ma = i * step;
      var ea0 = 0;
      var ea1 = ma + e * sin(ma);
      do {
        ea0 = ea1;
        ea1 = ma + e * sin(ea0);
      } while (abs(ea1 - ea0) > 0.001);
      var ta = 2 * atan(k1 * tan(ea1 / 2));
      var k3 = k2 / (1 + e * cos(ta));
      var fpT = pT[i] = {};
      var spT = pT[np - i] = {};
      spT.x = fpT.x = k3 * cos(ta);
      fpT.y = k3 * sin(ta);
      spT.y = -fpT.y;
    }
  };

  // generateOverlapTable() - verbatim lens-overlap areas + closest index
  p.generateOverlapTable = function () {
    var acos = Math.acos, sin = Math.sin, sqrt = Math.sqrt;
    this._overlapTable = [];
    var oT = this._overlapTable;
    var pT = this._positionTable;
    var c = this._c;
    var a = c.separation;
    var _ct = a * Math.cos(0.017453292519943295 * c.theta);
    var _st = a * sin(0.017453292519943295 * c.theta);
    var cp = Math.cos(0.017453292519943295 * c.phi);
    var sp = sin(0.017453292519943295 * c.phi);
    var k0 = -_st;
    var k1 = _ct;
    var k3 = _ct * sp;
    var k4 = _st * sp;
    var k6 = _ct * cp;
    var k7 = _st * cp;
    var r1 = this.solarRadius * c.radius1;
    var r2 = this.solarRadius * c.radius2;
    var r12 = r1 * r1;
    var r22 = r2 * r2;
    var R = r1 + r2;
    var RSQRD = R * R;
    var j0 = 1 / (2 * r2);
    var j1 = (r22 - r12) * j0;
    var j2 = 1 / (2 * r1);
    var j3 = (r12 - r22) * j2;
    var np = this._numCurvePoints;
    var closestIndex = 0;
    var minD2 = Infinity;
    for (var i = 0; i < np; i++) {
      var pp = pT[i];
      var dx = k0 * pp.x + k1 * pp.y;
      var dy = k3 * pp.x + k4 * pp.y;
      var dz = k6 * pp.x + k7 * pp.y;
      var d2 = dx * dx + dy * dy;
      if (dz > 0 && d2 < minD2) {
        minD2 = d2;
        closestIndex = i;
      }
      if (d2 >= RSQRD) {
        oT.push(0);
      } else {
        var d = sqrt(d2);
        if (d === 0) { d = 1e-8; }
        var ca = j0 * d + j1 / d;
        var cb = j2 * d + j3 / d;
        if (ca < -1) { ca = -1; } else if (ca > 1) { ca = 1; }
        if (cb < -1) { cb = -1; } else if (cb > 1) { cb = 1; }
        var alpha = acos(ca);
        var beta = acos(cb);
        var o = r22 * (alpha - ca * sin(alpha)) + r12 * (beta - cb * sin(beta));
        if (dz < 0) { oT.push(o); } else { oT.push(-o); }
      }
    }
    // refinement of the closest-approach index (verbatim)
    var refinement = 15;
    var cos = Math.cos, tan = Math.tan, atan = Math.atan, abs = Math.abs;
    var e = c.eccentricity;
    var q1 = sqrt((1 + e) / (1 - e));
    var q2 = this.solarRadius * (1 - e * e);
    var q4 = np / TWO_PI;
    var step = 2 / (q4 * refinement);
    var start = (closestIndex - 1) / q4;
    var refinedIndex = closestIndex;
    for (var ii = 1; ii < refinement; ii++) {
      var ma = start + ii * step;
      var ea0 = 0;
      var ea1 = ma + e * sin(ma);
      do {
        ea0 = ea1;
        ea1 = ma + e * sin(ea0);
      } while (abs(ea1 - ea0) > 0.001);
      var ta = 2 * atan(q1 * tan(ea1 / 2));
      var q3 = q2 / (1 + e * cos(ta));
      var px = q3 * cos(ta);
      var py = q3 * sin(ta);
      var dx2 = k0 * px + k1 * py;
      var dy2 = k3 * px + k4 * py;
      var dd2 = dx2 * dx2 + dy2 * dy2;
      if (dd2 < minD2) {
        minD2 = dd2;
        refinedIndex = ma * q4;
      }
    }
    this._closestIndex = ((refinedIndex % np) + np) % np;
  };

  // generateMagnitudeTable() - verbatim bolometric-correction polynomials
  // and visual flux / magnitude tables
  p.generateMagnitudeTable = function () {
    var log = Math.log;
    this._visualMagnitudeTable = [];
    this._visualFluxTable = [];
    var vMT = this._visualMagnitudeTable;
    var vFT = this._visualFluxTable;
    var oT = this._overlapTable;
    var c = this._c;
    var np = this._numCurvePoints;
    var k;
    var logTeff = log(c.temperature1) / LN10;
    if (logTeff > 3.9) {
      k = { a: -100139.4991, b: 116264.1842, c: -53931.97541, d: 12495.04227, e: -1445.868048, f: 66.84924471 };
    } else if (logTeff < 3.7) {
      k = { a: -13884.14899, b: 8595.127427, c: -488.3425525, d: -627.0092238, e: 137.4608131, f: -7.549572042 };
    } else {
      k = { a: 1439.981506, b: -151.9002581, c: -995.1089203, d: 582.5176671, e: -123.3293641, f: 9.160761128 };
    }
    var BC1 = k.a + logTeff * (k.b + logTeff * (k.c + logTeff * (k.d + logTeff * (k.e + k.f * logTeff))));
    logTeff = log(c.temperature2) / LN10;
    if (logTeff > 3.9) {
      k = { a: -100139.4991, b: 116264.1842, c: -53931.97541, d: 12495.04227, e: -1445.868048, f: 66.84924471 };
    } else if (logTeff < 3.7) {
      k = { a: -13884.14899, b: 8595.127427, c: -488.3425525, d: -627.0092238, e: 137.4608131, f: -7.549572042 };
    } else {
      k = { a: 1439.981506, b: -151.9002581, c: -995.1089203, d: 582.5176671, e: -123.3293641, f: 9.160761128 };
    }
    var BC2 = k.a + logTeff * (k.b + logTeff * (k.c + logTeff * (k.d + logTeff * (k.e + k.f * logTeff))));
    var j1 = 1.89553328524593e-43 * Math.pow(c.temperature1, 4) * Math.pow(10, BC1 / 2.5);
    var j2 = -1.89553328524593e-43 * Math.pow(c.temperature2, 4) * Math.pow(10, BC2 / 2.5);
    var fullVisFlux = (c.radius1 * c.radius1 * j1 - c.radius2 * c.radius2 * j2) * 1521837746881349890;
    var minVisFlux = Infinity;
    for (var i = 0; i < np; i++) {
      var o = oT[i];
      var visFlux;
      if (o < 0) { visFlux = fullVisFlux + j1 * o; }
      else { visFlux = fullVisFlux + j2 * o; }
      if (visFlux < minVisFlux) { minVisFlux = visFlux; }
      var visMag = -18.9669559998301 - 1.0857362047581294 * log(visFlux);
      vFT.push(visFlux);
      vMT.push(visMag);
    }
    this._noEclipse = (fullVisFlux === minVisFlux);
    this._maxVisFlux = fullVisFlux;
    this._minVisFlux = minVisFlux;
    if (this._noEclipse) {
      this._minVisMag = -18.9669559998301 - 1.0857362047581294 * log(this._maxVisFlux);
      this._maxVisMag = this._minVisMag + 3;
    } else {
      this._minVisMag = -18.9669559998301 - 1.0857362047581294 * log(this._maxVisFlux);
      this._maxVisMag = -18.9669559998301 - 1.0857362047581294 * log(this._minVisFlux);
      if (this._maxVisMag - this._minVisMag < this.minMagDiff) {
        this._maxVisMag = this._minVisMag + this.minMagDiff;
      }
    }
  };

  // Build the theoretical-curve points in plot coordinates (plotCurve math,
  // "visual flux" branch - the only dataType this sim ever displays).
  p.buildCurvePoints = function () {
    var pts = [];
    if (this._noEclipse) {
      pts.push([0, -this.plotHeight]);
      pts.push([this.plotWidth, -this.plotHeight]);
      return pts;
    }
    var dT = this._visualFluxTable;
    if (!dT) { return pts; }
    var yScale = -this.plotHeight / this._maxVisFlux;
    var yOffset = 0;
    var w = this.plotWidth;
    var si = Math.floor(this._closestIndex);
    var xOffset = (-w / this._numCurvePoints) * (this._closestIndex - si);
    var y0 = yOffset + yScale * dT[si];
    pts.push([0, y0]);
    var len = dT.length;
    var xScale = w / len;
    for (var i = 0; i < len; i++) {
      pts.push([xOffset + i * xScale, yOffset + yScale * dT[(i + si) % len]]);
    }
    pts.push([w, y0]);
    return pts;
  };

  /* ------------------------- full frame render -------------------------- */
  p.render = function () {
    var ctx = this.ctx;
    var dpr = this.dpr || 1;
    ctx.setTransform(dpr, 0, 0, dpr, 0, 0);
    ctx.clearRect(0, 0, 322, 222);
    ctx.save();
    // plot origin: x=0 at canvas x=1, flux-0 line at canvas y=217
    // (canvas 322 x 222 = plotWidth + 2*xMargin by totalHeight)
    ctx.translate(1, 217);

    var w = this.plotWidth;
    var top = -this.plotHeight - this.yTopMargin;   // -217
    var bottom = this.yBottomMargin;                // +5

    // white background box
    ctx.fillStyle = '#ffffff';
    ctx.fillRect(-this.xMargin, top, w + 2 * this.xMargin, this.totalHeight);

    // clip everything to the plot box (mask1MC/mask2MC/mask3MC)
    ctx.beginPath();
    ctx.rect(-this.xMargin, top, w + 2 * this.xMargin, this.totalHeight);
    ctx.clip();

    var offX = this._phaseOffset * w;

    // ---- observed dataset bitmap (reused exported asset), depth 5 ----
    var img = this.datasetImg;
    if (img && img.complete && img.naturalWidth > 0) {
      // dataMC._x = offX (or offX - w); copies at -w, 0, +w cover the wrap
      var dataX = (this._phaseOffset < 0.5) ? offX : offX - w;
      ctx.drawImage(img, dataX - w, -220);
      ctx.drawImage(img, dataX, -220);
      ctx.drawImage(img, dataX + w, -220);
    }

    // ---- theoretical curve (3 wrapped copies), depth 10 ----
    if (this.curveVisible && this._visualFluxTable) {
      var pts = this.buildCurvePoints();
      ctx.strokeStyle = '#000000';
      ctx.lineWidth = 2;
      var copies = (this._phaseOffset < 0.5) ?
        [offX - w, offX, offX + w] : [offX - 2 * w, offX - w, offX];
      for (var ci = 0; ci < copies.length; ci++) {
        ctx.save();
        ctx.translate(copies[ci], 0);
        ctx.beginPath();
        for (var i = 0; i < pts.length; i++) {
          if (i === 0) { ctx.moveTo(pts[i][0], pts[i][1]); }
          else { ctx.lineTo(pts[i][0], pts[i][1]); }
        }
        ctx.stroke();
        ctx.restore();
      }
    }

    // ---- flux axis ticks (left edge) ----
    ctx.strokeStyle = '#000000';
    ctx.lineWidth = 1;
    ctx.beginPath();
    for (var f = 0; f <= 4; f++) {
      var fy = -this.plotHeight * (f / 4);
      ctx.moveTo(0, fy + 0.5);
      ctx.lineTo(6, fy + 0.5);
    }
    ctx.stroke();

    // ---- phase (time) tick marks along the bottom, moving with offset ----
    ctx.beginPath();
    for (var t = 0; t < 10; t++) {
      var tx = w * (((this._phaseOffset + t / 10) % 1));
      ctx.moveTo(tx + 0.5, this.yBottomMargin);
      ctx.lineTo(tx + 0.5, this.yBottomMargin - 6);
    }
    ctx.stroke();

    // ---- phase cursor (red line), depth 15 ----
    var cx = w * ((this._phaseOffset + this._cursorPhase) % 1);
    ctx.strokeStyle = '#ff0000';
    ctx.lineWidth = this.cursorHot ? 2.5 : 1.5;
    ctx.beginPath();
    ctx.moveTo(cx, top);
    ctx.lineTo(cx, bottom);
    ctx.stroke();

    ctx.restore();

    // ---- border box (boxMC), unclipped ----
    ctx.strokeStyle = '#000000';
    ctx.lineWidth = 1;
    ctx.strokeRect(0.5, 0.5, 321, 221);
  };

  // cursor x position as a fraction of the plot width (for the HTML proxy)
  p.cursorFraction = function () {
    return (this._phaseOffset + this._cursorPhase) % 1;
  };

  E.Lightcurve = Lightcurve;
})();

/* ==========================================================================
   PART 4 - Mini HR Diagram: canvas port of "Mini HR Diagram.as" inside the
   floating HR Diagram window ("DefineSprite_485" dialog).
   graphW 300, graphH 200; T axis 45000..3000 K (log, reversed),
   L axis 0.001..1000000 L_sun (log). Canvas 300 x 200, plot origin at the
   BOTTOM-LEFT corner (canvas y 200), matching the AS y-up-negative frame.
   ========================================================================== */
(function () {
  'use strict';
  var E = window.__EBS__;

  function MiniHRDiagram(canvas) {
    this.canvas = canvas;
    this.ctx = canvas.getContext('2d');
    // constants - verbatim from MiniHRDiagramClass
    this.tMin = 3000;
    this.tMax = 45000;
    this.lMin = 0.001;
    this.lMax = 1000000;
    this.graphW = 300;
    this.graphH = 200;
    this.xScale = this.graphW / Math.log(this.tMax / this.tMin);
    this.yScale = this.graphH / Math.log(this.lMax / this.lMin);

    // Canvas box: the 300 x 200 plot inset by the margin that holds the
    // outward tick marks and the 1 px border (from exported shapes 224/230).
    this.plotX = 4.5;
    this.plotY = 0.5;
    this.canvasW = 305;
    this.canvasH = 205;

    this.msLabelPoints = [];             // anchors of the mass labels
    this.showMainSequenceOverlay = false;
    this.point1 = { x: 0, y: 0 };        // plot coords (y negative up)
    this.point2 = { x: 0, y: 0 };
    this.rangesStar = 0;                 // 0 = hidden, 1 or 2 = shown
    this.cloudImg = null;                // reused exported HR background
    this.needsRender = true;
  }

  var p = MiniHRDiagram.prototype;

  // findX/findY/findT/findL - verbatim
  p.findX = function (t) { return this.graphW - this.xScale * Math.log(t / this.tMin); };
  p.findY = function (l) { return -this.yScale * Math.log(l / this.lMin); };
  p.findT = function (x) { return this.tMin * Math.exp((this.graphW - x) / this.xScale); };
  p.findL = function (y) { return this.lMin * Math.exp(-y / this.yScale); };

  // setPointPosition - verbatim, including the label-avoidance offsets
  p.setPointPosition = function (id, t, l) {
    var thisPoint = (id === 1) ? this.point1 : this.point2;
    var otherPoint = (id === 1) ? this.point2 : this.point1;
    var nx = this.findX(t);
    var ny = this.findY(l);
    thisPoint.x = nx;
    thisPoint.y = ny;
    var dx = otherPoint.x - nx;
    var dy = otherPoint.y - ny;
    var s = 14 / Math.sqrt(dx * dx + dy * dy);
    thisPoint.labelX = -s * dx;
    thisPoint.labelY = -s * dy;
    otherPoint.labelX = -thisPoint.labelX;
    otherPoint.labelY = -thisPoint.labelY;
    this.needsRender = true;
  };

  // showRanges(star) - the grey overlay marking the reachable region while a
  // point is dragged. Ported verbatim from MiniHRDiagramClass.showRanges;
  // the slider ranges are read through the controller hooks set below.
  p.showRanges = function (star) {
    this.rangesStar = star;
    this.needsRender = true;
  };

  p.hideRanges = function () {
    this.rangesStar = 0;
    this.needsRender = true;
  };

  p.render = function (hooks) {
    var ctx = this.ctx;
    var dpr = this.dpr || 1;
    ctx.setTransform(dpr, 0, 0, dpr, 0, 0);
    ctx.clearRect(0, 0, this.canvasW, this.canvasH);

    // Plot origin at the bottom-left corner of the plot area, y negative up.
    // The plot sits at (4.5, 0.5)-(304.5, 200.5) inside the 305 x 205 canvas;
    // the margin holds the outward tick marks drawn by shape 224 / 230.
    ctx.save();
    ctx.translate(this.plotX, this.plotY + this.graphH);

    ctx.save();
    ctx.beginPath();                    // the original's plotAreaMC / ranges masks
    ctx.rect(0, -this.graphH, this.graphW, this.graphH);
    ctx.clip();

    ctx.fillStyle = '#ffffff';
    ctx.fillRect(0, -this.graphH, this.graphW, this.graphH);

    // reused exported asset: the HR star-cloud background bitmap (image 223)
    if (this.cloudImg && this.cloudImg.complete && this.cloudImg.naturalWidth > 0) {
      ctx.drawImage(this.cloudImg, 0, -this.graphH, this.graphW, this.graphH);
    }

    // main-sequence track: dashed line through the sim's own L(T) relation,
    // with the short perpendicular mass ticks the exported track sprite drew
    // (the labels themselves are MathJax-typeset HTML over the canvas)
    if (this.showMainSequenceOverlay) {
      ctx.strokeStyle = '#666666';
      ctx.lineWidth = 1;
      ctx.setLineDash([5, 4]);
      ctx.beginPath();
      var first = true;
      for (var tt = this.tMin; tt <= this.tMax * 1.0001; tt *= 1.03) {
        var ll = E.getLfromT(tt);
        if (ll < this.lMin || ll > this.lMax) { continue; }
        var x = this.findX(tt);
        var y = this.findY(ll);
        if (first) { ctx.moveTo(x, y); first = false; }
        else { ctx.lineTo(x, y); }
      }
      ctx.stroke();
      ctx.setLineDash([]);

      ctx.beginPath();
      for (var mi = 0; mi < this.msLabelPoints.length; mi++) {
        var mp = this.msLabelPoints[mi];
        ctx.moveTo(mp.x - 4, mp.y + 4);
        ctx.lineTo(mp.x + 4, mp.y - 4);
      }
      ctx.stroke();
    }

    // ranges overlay (showRanges) - verbatim geometry, even-odd fill
    if (this.rangesStar && hooks) {
      var star = this.rangesStar;
      var radiusRange = hooks.getRadiusRange(star);
      var tempRange = hooks.getTempRange(star);
      if (!hooks.getRestrictChecked(star)) {
        tempRange.max = hooks.getTmaxSld();
      }
      var k1 = Math.pow(tempRange.max / 5808.3, 4);
      var k2 = 0.071168672;             // (3000 / 5808.3)^4, verbatim constant
      var x1 = this.findX(tempRange.max);
      var x2 = this.graphW;
      var y1 = this.findY(radiusRange.min * radiusRange.min * k1);
      var y2 = this.findY(radiusRange.max * radiusRange.max * k1);
      var y3 = this.findY(radiusRange.max * radiusRange.max * k2);
      var y4 = this.findY(radiusRange.min * radiusRange.min * k2);
      ctx.fillStyle = 'rgba(102,102,102,0.3)';   // 10066329, alpha 30
      if (radiusRange.min === radiusRange.max) {
        ctx.fillRect(-10, -this.graphH - 10, this.graphW + 20, this.graphH + 20);
        ctx.strokeStyle = '#ffffff';
        ctx.lineWidth = 1;
        ctx.beginPath();
        ctx.moveTo(x1, y1);
        ctx.lineTo(x2, y4);
        ctx.stroke();
      } else {
        ctx.beginPath();
        ctx.moveTo(x1, y1);
        ctx.lineTo(x1, y2);
        ctx.lineTo(x2, y3);
        ctx.lineTo(x2, y4);
        ctx.closePath();
        ctx.rect(-10, 10 - (this.graphH + 20), this.graphW + 20, this.graphH + 20);
        ctx.fill('evenodd');
      }
    }

    ctx.restore();                       // end plot-area clip

    // Plot border and outward tick marks, reproduced from exported shapes
    // 224 (border + temperature ticks) and 230 (luminosity ticks).
    ctx.strokeStyle = '#000000';
    ctx.lineWidth = 1;
    ctx.beginPath();
    ctx.rect(0, -this.graphH, this.graphW, this.graphH);
    var i, ty;
    for (i = 0; i < 10; i++) {           // luminosity ticks, 4 px to the left
      ty = -this.graphH + (this.graphH / 9) * i;
      ctx.moveTo(-4, ty);
      ctx.lineTo(0, ty);
    }
    var temps = [45000, 20000, 10000, 5000, 3000];
    for (i = 0; i < temps.length; i++) { // temperature ticks, 4 px below
      var tx = this.findX(temps[i]);
      ctx.moveTo(tx, 0);
      ctx.lineTo(tx, 4);
    }
    ctx.stroke();

    ctx.restore();
  };

  E.MiniHRDiagram = MiniHRDiagram;
})();

/* ==========================================================================
   PART 5 - Controller and wiring: port of the main simulator scripts
   (DefineSprite_486 DoAction 1-7 and DefineSprite_485), plus the
   accessibility layer (keyboard paths, live region, descriptions).
   ========================================================================== */
(function () {
  'use strict';
  var E = window.__EBS__;
  var toSigDigits = E.toSigDigits;
  var getRfromTL = E.getRfromTL;
  var getLfromRT = E.getLfromRT;
  var getTfromLR = E.getTfromLR;
  var getLfromT = E.getLfromT;
  var getTfromL = E.getTfromL;
  var getLfromM = E.getLfromM;
  var getMfromL = E.getMfromL;
  var getTfromR = E.getTfromR;
  var systemsArray = E.systemsArray;

  document.addEventListener('DOMContentLoaded', function () {

    /* ------------------------------ DOM refs --------------------------- */
    var $ = function (id) { return document.getElementById(id); };
    E.setLiveRegion($('liveStatus'));
    var announce = E.announce;

    var visCanvas = $('visCanvas');
    var lcCanvas = $('lcCanvas');
    var hrCanvas = $('hrCanvas');
    var visTitleField = $('visTitleField');
    var systemPeriodField = $('systemPeriodField');
    var visDesc = $('visDesc');
    var lcDesc = $('lcDesc');
    var visDragProxy = $('visDragProxy');
    var visWrap = $('visWrap');
    var lcCursorProxy = $('lcCursorProxy');
    var lcXTicks = $('lcXTicks');
    var lcPlotWrap = $('lcPlotWrap');
    var commentField = $('commentField');
    var systemsList = $('systemsList');
    var setParametersToMatchButton = $('setParametersToMatchButton');
    var animationButton = $('animationButton');
    var showHRDiagramButton = $('showHRDiagramButton');
    var hrWindow = $('hrDiagramWindow');
    var hrDragBar = $('hrDragBar');
    var hrCloseButton = $('hrCloseButton');
    var hrPlotWrap = $('hrPlotWrap');
    var hrPointEls = { 1: $('hrPoint1'), 2: $('hrPoint2') };
    var hrMSLabels = $('hrMSLabels');
    var checks = {
      showLightcurve: $('showLightcurveCheck'),
      perspectiveLock: $('perspectiveLockCheck'),
      showOrbitalPaths: $('showOrbitalPathsCheck'),
      showOrbitalPlane: $('showOrbitalPlaneCheck'),
      restrict1: $('restrict1Check'),
      restrict2: $('restrict2Check'),
      showMainSequence: $('showMainSequenceCheck')
    };

    /* ------------------------- canvas DPR setup ------------------------- */
    function setupCanvas(canvas, w, h) {
      var dpr = Math.min(window.devicePixelRatio || 1, 2);
      canvas.width = Math.round(w * dpr);
      canvas.height = Math.round(h * dpr);
      return dpr;
    }

    var visualizationMC = new E.BinarySystem(visCanvas);
    visualizationMC.dpr = setupCanvas(visCanvas, 400, 400);
    var curveMC = new E.Lightcurve(lcCanvas);
    curveMC.dpr = setupCanvas(lcCanvas, 322, 222);
    var hrDiagramMC = new E.MiniHRDiagram(hrCanvas);
    hrDiagramMC.dpr = setupCanvas(hrCanvas, hrDiagramMC.canvasW, hrDiagramMC.canvasH);

    // plot coords (x 0..300, y -200..0) -> percentage of the HR canvas box,
    // for the HTML overlays that sit on top of it
    function hrLeftPct(x) {
      return (hrDiagramMC.plotX + x) / hrDiagramMC.canvasW * 100;
    }
    function hrTopPct(y) {
      return (hrDiagramMC.plotY + hrDiagramMC.graphH + y) / hrDiagramMC.canvasH * 100;
    }

    // reused exported bitmaps
    var comImg = new Image();
    comImg.onload = function () { visualizationMC.requestRender(); };
    comImg.src = 'assets/com-marker.png';
    visualizationMC.comImg = comImg;
    var cloudImg = new Image();
    cloudImg.onload = function () { hrDiagramMC.needsRender = true; };
    cloudImg.src = 'assets/hr-cloud.png';
    hrDiagramMC.cloudImg = cloudImg;

    /* ------------------------------ state ------------------------------- */
    var star1 = {};
    var star2 = {};
    var sysProps = {};
    var initParamsObj = null;
    var playing = false;
    var timeLast = 0;
    var reducedMotion = window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches;
    var reducedAccum = 0;

    /* -------------------------- slider creation ------------------------- */
    // configs are verbatim from the on(initialize) clip actions
    function announceSlider(slider) {
      var msg = slider.spokenValue();
      if (slider.opts.announcePeriod) { msg += '. ' + periodSpoken(); }
      announce(msg + '.');
    }

    var sliders = {};

    function makeSlider(mountId, cfg) {
      cfg.announce = announceSlider;
      sliders[mountId] = new E.SliderV5(mountId, cfg);
      return sliders[mountId];
    }

    var separationSlider = makeSlider('separationSlider', {
      initValue: 10, minValue: 0.5, maxValue: 60, scaleMode: 'logarithmic',
      precision: 2, precisionMode: 'fixed decimal places',
      changeHandler: function (v) { changeSeparation(v); },
      labelText: 'separation:', unitsTeX: 'R_\\odot',
      quantityName: 'Separation', unitWords: 'solar radii', announcePeriod: true
    });
    var eccentricitySlider = makeSlider('eccentricitySlider', {
      initValue: 0.3, minValue: 0, maxValue: 0.6, scaleMode: 'linear',
      precision: 2, precisionMode: 'fixed decimal places',
      changeHandler: function (v) { changeEccentricity(v); },
      labelText: 'eccentricity:', unitsTeX: '',
      quantityName: 'Eccentricity', unitWords: ''
    });
    var mass1Slider = makeSlider('mass1Slider', {
      initValue: 1, minValue: 0.1, maxValue: 85, scaleMode: 'logarithmic',
      precision: 2, precisionMode: 'significant digits',
      changeHandler: function (v) { changeMass1(v); },
      labelText: 'mass:', unitsTeX: 'M_\\odot',
      quantityName: 'Star 1 mass', unitWords: 'solar masses', announcePeriod: true
    });
    var radius1Slider = makeSlider('radius1Slider', {
      initValue: 1.5, minValue: 0.1, maxValue: 50, scaleMode: 'logarithmic',
      precision: 2, precisionMode: 'significant digits',
      changeHandler: function (v) { changeRadius1(v); },
      labelText: 'radius:', unitsTeX: 'R_\\odot',
      quantityName: 'Star 1 radius', unitWords: 'solar radii'
    });
    var temp1Slider = makeSlider('temp1Slider', {
      initValue: 8700, minValue: 3000, maxValue: 45000, scaleMode: 'logarithmic',
      precision: 3, precisionMode: 'significant digits',
      changeHandler: function (v) { changeTemp1(v); },
      labelText: 'temperature:', unitsTeX: '\\mathrm{K}',
      quantityName: 'Star 1 temperature', unitWords: 'kelvin'
    });
    var mass2Slider = makeSlider('mass2Slider', {
      initValue: 1, minValue: 0.1, maxValue: 85, scaleMode: 'logarithmic',
      precision: 2, precisionMode: 'significant digits',
      changeHandler: function (v) { changeMass2(v); },
      labelText: 'mass:', unitsTeX: 'M_\\odot',
      quantityName: 'Star 2 mass', unitWords: 'solar masses', announcePeriod: true
    });
    var radius2Slider = makeSlider('radius2Slider', {
      initValue: 1.5, minValue: 0.1, maxValue: 50, scaleMode: 'logarithmic',
      precision: 2, precisionMode: 'significant digits',
      changeHandler: function (v) { changeRadius2(v); },
      labelText: 'radius:', unitsTeX: 'R_\\odot',
      quantityName: 'Star 2 radius', unitWords: 'solar radii'
    });
    var temp2Slider = makeSlider('temp2Slider', {
      initValue: 5000, minValue: 3000, maxValue: 45000, scaleMode: 'logarithmic',
      precision: 3, precisionMode: 'significant digits',
      changeHandler: function (v) { changeTemp2(v); },
      labelText: 'temperature:', unitsTeX: '\\mathrm{K}',
      quantityName: 'Star 2 temperature', unitWords: 'kelvin'
    });
    var phaseSlider = makeSlider('phaseSlider', {
      initValue: 0, minValue: 0, maxValue: 1, scaleMode: 'linear',
      precision: 2, precisionMode: 'fixed decimal places',
      changeHandler: function (v) { setPhase(v); },
      labelText: 'phase:', unitsTeX: '',
      quantityName: 'Phase', unitWords: ''
    });
    var longitudeSlider = makeSlider('longitudeSlider', {
      initValue: 150, minValue: 0, maxValue: 360, scaleMode: 'linear',
      precision: 1, precisionMode: 'fixed decimal places',
      changeHandler: function (v) { changeLongitude(v); },
      labelText: 'longitude:', unitsTeX: '{}^\\circ',
      quantityName: 'Longitude', unitWords: 'degrees'
    });
    var inclinationSlider = makeSlider('inclinationSlider', {
      initValue: 80, minValue: 0, maxValue: 90, scaleMode: 'linear',
      precision: 2, precisionMode: 'fixed decimal places',
      changeHandler: function (v) { changeInclination(v); },
      labelText: 'inclination:', unitsTeX: '{}^\\circ',
      quantityName: 'Inclination', unitWords: 'degrees'
    });
    var animationSpeedSlider = makeSlider('animationSpeedSlider', {
      initValue: 0.0001, minValue: 0.00002, maxValue: 0.001, scaleMode: 'logarithmic',
      precision: 3, precisionMode: 'significant digits',
      changeHandler: null, showField: false,
      labelText: '', unitsTeX: '',
      quantityName: 'Animation speed', unitWords: 'phase per millisecond'
    });

    /* --------------------- range constants (DoAction_3) ----------------- */
    var EminSld = eccentricitySlider.sliderMin;
    var EmaxSld = eccentricitySlider.sliderMax;
    var AminSld = separationSlider.sliderMin;
    var AmaxSld = separationSlider.sliderMax;
    var RminSld = radius1Slider.sliderMin;
    var RmaxSld = radius1Slider.sliderMax;
    var MminSld = mass1Slider.sliderMin;
    var MmaxSld = mass1Slider.sliderMax;
    var TminSld = temp1Slider.sliderMin;
    var TmaxSld = temp1Slider.sliderMax;
    var Lmin = 0.001;
    var Lmax = 1000000;
    var LminMS = getLfromT(TminSld);
    var LmaxMS = getLfromT(TmaxSld);
    var RminMS = getRfromTL(TminSld, LminMS);
    var RmaxMS = getRfromTL(TmaxSld, LmaxMS);
    var MminMS = getMfromL(LminMS);
    var MmaxMS = getMfromL(LmaxMS);

    function starSlider(kind, star) { return sliders[kind + star + 'Slider']; }
    function restrictChecked(star) { return checks['restrict' + star].checked; }

    /* ------------------- period readout (shared string) ------------------ */
    // system period in days: P = 0.115496 * sqrt(a^3 / (m1 + m2))
    function updatePeriod() {
      var period = 0.115496 * Math.sqrt(Math.pow(sysProps.a, 3) / (star1.m + star2.m));
      systemPeriodField.textContent = 'system period: ' + toSigDigits(period, 3) + ' days';
    }
    function periodSpoken() {
      var period = 0.115496 * Math.sqrt(Math.pow(sysProps.a, 3) / (star1.m + star2.m));
      return 'System period ' + toSigDigits(period, 3) + ' days';
    }

    /* -------------------- range setters (DoAction_3) --------------------- */
    function setEccentricityRange() {
      var EmaxVis = 1 - (star1.r + star2.r) / sysProps.a;
      var Emin = EminSld;
      var Emax = Math.min(EmaxSld, EmaxVis);
      eccentricitySlider.setRange(Emin, Emax);
    }

    function setSeparationRange() {
      var AminVis = (star1.r + star2.r) / (1 - sysProps.e);
      var Amin = Math.max(AminSld, AminVis);
      var Amax = AmaxSld;
      separationSlider.setRange(Amin, Amax);
    }

    function setTempRange(star) {
      var thisStar = (star === 1) ? star1 : star2;
      var thisTempSlider = starSlider('temp', star);
      var TminHR = getTfromLR(Lmin, thisStar.r);
      var TmaxHR = getTfromLR(Lmax, thisStar.r);
      var Tmin = Math.max(TminSld, TminHR);
      var Tmax = Math.min(TmaxSld, TmaxHR);
      thisTempSlider.setRange(Tmin, Tmax);
    }

    function setRadiusRange(star) {
      var thisStar = (star === 1) ? star1 : star2;
      var otherStar = (star === 1) ? star2 : star1;
      var thisRadiusSlider = starSlider('radius', star);
      var RmaxVis = sysProps.a * (1 - sysProps.e) - otherStar.r;
      var RminHR = getRfromTL(thisStar.t, Lmin);
      var RmaxHR = getRfromTL(thisStar.t, Lmax);
      var Rmin = Math.max(RminSld, RminHR);
      var Rmax = Math.min(Math.min(RmaxSld, RmaxHR), RmaxVis);
      thisRadiusSlider.setRange(Rmin, Rmax);
    }

    function setMassRange(star) {
      starSlider('mass', star).setRange(MminSld, MmaxSld);
    }

    function setRestrictedStarRanges(star) {
      var otherStar = (star === 1) ? star2 : star1;
      var thisMassSlider = starSlider('mass', star);
      var thisRadiusSlider = starSlider('radius', star);
      var thisTempSlider = starSlider('temp', star);
      var RmaxVis = sysProps.a * (1 - sysProps.e) - otherStar.r;
      var Rmin = RminMS;
      var Rmax = Math.min(RmaxMS, RmaxVis);
      var TmaxVis = getTfromR(RmaxVis);
      var Tmin = TminSld;
      var Tmax = Math.min(TmaxSld, TmaxVis);
      var LmaxVis = getLfromRT(RmaxVis, TmaxVis);
      var MmaxVis = getMfromL(LmaxVis);
      var Mmin = MminMS;
      var Mmax = Math.min(MmaxMS, MmaxVis);
      thisMassSlider.setRange(Mmin, Mmax);
      thisRadiusSlider.setRange(Rmin, Rmax);
      thisTempSlider.setRange(Tmin, Tmax);
    }

    function setUnrestrictStar(star) {
      setMassRange(star);
      setRadiusRange(star);
      setTempRange(star);
    }

    /* ------------------ lightcurve + view glue (DoAction_7) -------------- */
    function drawLightCurve() {
      curveMC.setParameters({
        eccentricity: sysProps.e, separation: sysProps.a,
        theta: getSystemTheta(), phi: getSystemPhi(),
        radius1: star1.r, radius2: star2.r,
        temperature1: star1.t, temperature2: star2.t
      });
      updateLcDesc();
    }

    function getSystemTheta() {
      return (((90 - longitudeSlider.value) % 360) + 360) % 360;
    }

    function getSystemPhi() {
      return 90 - inclinationSlider.value;
    }

    function setViewThetaAndPhi(theta, phi) {
      visualizationMC.setThetaAndPhi(theta, phi);
    }

    function matchButtonMaybeEnable() {
      if (systemsListValue() !== ' ') { setEnabled(setParametersToMatchButton, true); }
    }

    function realignVisualizationPhase() {
      visualizationMC.phase = curveMC._cursorPhase + curveMC._closestIndex / curveMC._numCurvePoints;
    }

    /* ------------------- phase + animation (DoAction_4) ------------------ */
    function setPhase(arg) {
      arg = ((arg % 1) + 1) % 1;
      curveMC.setCursorPhase(arg);
      phaseSlider.value = arg;
      visualizationMC.phase = arg + curveMC._closestIndex / curveMC._numCurvePoints;
      updateVisDesc();
    }

    function changeAnimateState() {
      if (playing) {
        playing = false;
        animationButton.textContent = 'start animation';
        announce('Animation paused. ' + 'Phase ' + phaseSlider.valueString() + '.');
      } else {
        playing = true;
        animationButton.textContent = 'pause animation';
        timeLast = performance.now();
        reducedAccum = 0;
        announce('Animation started.');
      }
    }

    /* ------------------ core parameter setters (DoAction_3) -------------- */
    function setEccentricity(arg) {
      var EmaxVis = 1 - (star1.r + star2.r) / sysProps.a;
      var Emin = EminSld;
      var Emax = Math.min(EmaxSld, EmaxVis);
      if (arg < Emin) { arg = Emin; }
      else if (arg > Emax) { arg = Emax; }
      sysProps.e = arg;
      visualizationMC.eccentricity = arg;
      eccentricitySlider.value = arg;
      drawLightCurve();
      realignVisualizationPhase();
      matchButtonMaybeEnable();
      setSeparationRange();
      if (restrictChecked(1)) { setRestrictedStarRanges(1); } else { setRadiusRange(1); }
      if (restrictChecked(2)) { setRestrictedStarRanges(2); } else { setRadiusRange(2); }
    }

    function setSeparation(arg) {
      var AminVis = (star1.r + star2.r) / (1 - sysProps.e);
      var Amin = Math.max(AminSld, AminVis);
      var Amax = AmaxSld;
      if (arg < Amin) { arg = Amin; }
      else if (arg > Amax) { arg = Amax; }
      sysProps.a = arg;
      visualizationMC.separation = arg;
      separationSlider.value = arg;
      drawLightCurve();
      updatePeriod();
      matchButtonMaybeEnable();
      setEccentricityRange();
      if (restrictChecked(1)) { setRestrictedStarRanges(1); } else { setRadiusRange(1); }
      if (restrictChecked(2)) { setRestrictedStarRanges(2); } else { setRadiusRange(2); }
    }

    function setRestrictToMainSequence(star) {
      var otherStarNumber = (star === 1) ? 2 : 1;
      var thisStar = (star === 1) ? star1 : star2;
      var otherStar = (star === 1) ? star2 : star1;
      var RmaxVis = sysProps.a * (1 - sysProps.e) - otherStar.r;
      var TmaxVis = getTfromR(RmaxVis);
      var Tmin = TminSld;
      var Tmax = Math.min(TmaxSld, TmaxVis);
      var initObj = {};
      if (Tmin > Tmax) {
        // case where T is too big (verbatim fallback)
        thisStar.t = Tmin;
        thisStar.l = getLfromT(thisStar.t);
        thisStar.m = getMfromL(thisStar.l);
        thisStar.r = getRfromTL(thisStar.t, thisStar.l);
        var sep = (thisStar.r + otherStar.r) / (1 - sysProps.e);
        if (sep > AmaxSld) {
          sysProps.a = AmaxSld;
          sysProps.e = 1 - (thisStar.r + otherStar.r) / sysProps.a;
        } else if (sep < AminSld) {
          sysProps.a = AminSld;
        } else {
          sysProps.a = sep;
        }
        eccentricitySlider.value = sysProps.e;
        separationSlider.value = sysProps.a;
        initObj['radius' + star] = thisStar.r;
        initObj['mass' + star] = thisStar.m;
        initObj.eccentricity = sysProps.e;
        initObj.separation = sysProps.a;
        visualizationMC.initialize(initObj);
      } else {
        var temp = thisStar.t;
        if (temp < Tmin) { temp = Tmin; }
        else if (temp > Tmax) { temp = Tmax; }
        thisStar.t = temp;
        thisStar.l = getLfromT(temp);
        thisStar.r = getRfromTL(temp, thisStar.l);
        thisStar.m = getMfromL(thisStar.l);
        initObj['radius' + star] = thisStar.r;
        initObj['mass' + star] = thisStar.m;
        visualizationMC.initialize(initObj);
      }
      starSlider('mass', star).value = thisStar.m;
      starSlider('radius', star).value = thisStar.r;
      starSlider('temp', star).value = thisStar.t;
      hrDiagramMC.setPointPosition(star, thisStar.t, thisStar.l);
      visualizationMC.passObjectToIcon(star, { temp: thisStar.t });
      drawLightCurve();
      realignVisualizationPhase();
      updatePeriod();
      matchButtonMaybeEnable();
      setSeparationRange();
      setEccentricityRange();
      setRestrictedStarRanges(star);
      if (restrictChecked(otherStarNumber)) {
        setRestrictedStarRanges(otherStarNumber);
      } else {
        setRadiusRange(otherStarNumber);
      }
    }

    function setTempAndLuminosity(star, temp, lum) {
      var otherStarNumber = (star === 1) ? 2 : 1;
      var thisStar = (star === 1) ? star1 : star2;
      var otherStar = (star === 1) ? star2 : star1;
      if (restrictChecked(star)) {
        var RmaxVis = sysProps.a * (1 - sysProps.e) - otherStar.r;
        var TmaxVis = getTfromR(RmaxVis);
        var Tmin = TminSld;
        var Tmax = Math.min(TmaxSld, TmaxVis);
        if (temp < Tmin) { temp = Tmin; }
        else if (temp > Tmax) { temp = Tmax; }
        thisStar.t = temp;
        thisStar.l = getLfromT(temp);
        thisStar.r = getRfromTL(temp, thisStar.l);
        thisStar.m = getMfromL(thisStar.l);
        starSlider('mass', star).value = thisStar.m;
        starSlider('radius', star).value = thisStar.r;
        starSlider('temp', star).value = thisStar.t;
        var initObj = {};
        initObj['radius' + star] = thisStar.r;
        initObj['mass' + star] = thisStar.m;
        visualizationMC.initialize(initObj);
        updatePeriod();
      } else {
        if (temp < TminSld) { temp = TminSld; }
        else if (temp > TmaxSld) { temp = TmaxSld; }
        var rad = getRfromTL(temp, lum);
        var RminHR = getRfromTL(temp, Lmin);
        var RmaxHR = getRfromTL(temp, Lmax);
        var RmaxVis2 = sysProps.a * (1 - sysProps.e) - otherStar.r;
        var Rmin = Math.max(RminSld, RminHR);
        var Rmax = Math.min(Math.min(RmaxSld, RmaxHR), RmaxVis2);
        if (Rmin > Rmax + 1e-8) {
          rad = RmaxVis2;
          temp = getTfromLR(Lmin, rad);
        } else if (rad < Rmin) {
          rad = Rmin;
        } else if (rad > Rmax) {
          rad = Rmax;
        }
        thisStar.r = rad;
        thisStar.t = temp;
        thisStar.l = getLfromRT(rad, temp);
        starSlider('radius', star).value = rad;
        starSlider('temp', star).value = temp;
        visualizationMC['radius' + star] = rad;
      }
      hrDiagramMC.setPointPosition(star, thisStar.t, thisStar.l);
      visualizationMC.passObjectToIcon(star, { temp: thisStar.t });
      drawLightCurve();
      matchButtonMaybeEnable();
      var otherRestricted = restrictChecked(otherStarNumber);
      var thisRestricted = restrictChecked(star);
      setSeparationRange();
      setEccentricityRange();
      if (otherRestricted) { setRestrictedStarRanges(otherStarNumber); }
      else { setRadiusRange(otherStarNumber); }
      if (!thisRestricted) {
        setRadiusRange(star);
        setTempRange(star);
      }
    }

    function setRadius(star, arg) {
      var otherStarNumber = (star === 1) ? 2 : 1;
      var thisStar = (star === 1) ? star1 : star2;
      var otherStar = (star === 1) ? star2 : star1;
      var RmaxVis = sysProps.a * (1 - sysProps.e) - otherStar.r;
      if (restrictChecked(star)) {
        var Rmin = RminMS;
        var Rmax = Math.min(RmaxMS, RmaxVis);
        if (arg < Rmin) { arg = Rmin; }
        else if (arg > Rmax) { arg = Rmax; }
        thisStar.r = arg;
        thisStar.t = getTfromR(arg);
        thisStar.l = getLfromRT(arg, thisStar.t);
        thisStar.m = getMfromL(thisStar.l);
        starSlider('mass', star).value = thisStar.m;
        starSlider('radius', star).value = thisStar.r;
        starSlider('temp', star).value = thisStar.t;
        var initObj = {};
        initObj['radius' + star] = thisStar.r;
        initObj['mass' + star] = thisStar.m;
        visualizationMC.initialize(initObj);
        visualizationMC.passObjectToIcon(star, { temp: thisStar.t });
        updatePeriod();
      } else {
        var RminHR = getRfromTL(thisStar.t, Lmin);
        var RmaxHR = getRfromTL(thisStar.t, Lmax);
        var Rmin2 = Math.max(RminSld, RminHR);
        var Rmax2 = Math.min(Math.min(RmaxSld, RmaxHR), RmaxVis);
        if (arg < Rmin2) { arg = Rmin2; }
        else if (arg > Rmax2) { arg = Rmax2; }
        thisStar.r = arg;
        thisStar.l = getLfromRT(arg, thisStar.t);
        starSlider('radius', star).value = arg;
        visualizationMC['radius' + star] = arg;
      }
      hrDiagramMC.setPointPosition(star, thisStar.t, thisStar.l);
      drawLightCurve();
      matchButtonMaybeEnable();
      var otherRestricted = restrictChecked(otherStarNumber);
      var thisRestricted = restrictChecked(star);
      setSeparationRange();
      setEccentricityRange();
      if (otherRestricted) { setRestrictedStarRanges(otherStarNumber); }
      else { setRadiusRange(otherStarNumber); }
      if (!thisRestricted) { setTempRange(star); }
    }

    function setTemp(star, arg) {
      var otherStarNumber = (star === 1) ? 2 : 1;
      var thisStar = (star === 1) ? star1 : star2;
      var otherStar = (star === 1) ? star2 : star1;
      if (restrictChecked(star)) {
        var RmaxVis = sysProps.a * (1 - sysProps.e) - otherStar.r;
        var TmaxVis = getTfromR(RmaxVis);
        var Tmin = TminSld;
        var Tmax = Math.min(TmaxSld, TmaxVis);
        if (arg < Tmin) { arg = Tmin; }
        else if (arg > Tmax) { arg = Tmax; }
        thisStar.t = arg;
        thisStar.l = getLfromT(arg);
        thisStar.r = getRfromTL(arg, thisStar.l);
        thisStar.m = getMfromL(thisStar.l);
        starSlider('mass', star).value = thisStar.m;
        starSlider('radius', star).value = thisStar.r;
        starSlider('temp', star).value = thisStar.t;
        var initObj = {};
        initObj['radius' + star] = thisStar.r;
        initObj['mass' + star] = thisStar.m;
        visualizationMC.initialize(initObj);
        updatePeriod();
      } else {
        var TminHR = getTfromLR(Lmin, thisStar.r);
        var TmaxHR = getTfromLR(Lmax, thisStar.r);
        var Tmin2 = Math.max(TminSld, TminHR);
        var Tmax2 = Math.min(TmaxSld, TmaxHR);
        if (arg < Tmin2) { arg = Tmin2; }
        else if (arg > Tmax2) { arg = Tmax2; }
        thisStar.t = arg;
        thisStar.l = getLfromRT(thisStar.r, arg);
        starSlider('temp', star).value = arg;
      }
      hrDiagramMC.setPointPosition(star, thisStar.t, thisStar.l);
      visualizationMC.passObjectToIcon(star, { temp: thisStar.t });
      drawLightCurve();
      matchButtonMaybeEnable();
      var otherRestricted = restrictChecked(otherStarNumber);
      var thisRestricted = restrictChecked(star);
      if (thisRestricted) {
        setSeparationRange();
        setEccentricityRange();
        if (otherRestricted) { setRestrictedStarRanges(otherStarNumber); }
        else { setRadiusRange(otherStarNumber); }
      } else {
        setRadiusRange(star);
      }
    }

    function setMass(star, arg) {
      var otherStarNumber = (star === 1) ? 2 : 1;
      var thisStar = (star === 1) ? star1 : star2;
      var otherStar = (star === 1) ? star2 : star1;
      if (restrictChecked(star)) {
        var RmaxVis = sysProps.a * (1 - sysProps.e) - otherStar.r;
        var TmaxVis = getTfromR(RmaxVis);
        var LmaxVis = getLfromRT(RmaxVis, TmaxVis);
        var MmaxVis = getMfromL(LmaxVis);
        var Mmin = MminMS;
        var Mmax = Math.min(MmaxMS, MmaxVis);
        if (arg < Mmin) { arg = Mmin; }
        else if (arg > Mmax) { arg = Mmax; }
        thisStar.m = arg;
        thisStar.l = getLfromM(arg);
        thisStar.t = getTfromL(thisStar.l);
        thisStar.r = getRfromTL(thisStar.t, thisStar.l);
        starSlider('mass', star).value = thisStar.m;
        starSlider('radius', star).value = thisStar.r;
        starSlider('temp', star).value = thisStar.t;
        var initObj = {};
        initObj['radius' + star] = thisStar.r;
        initObj['mass' + star] = thisStar.m;
        visualizationMC.initialize(initObj);
        visualizationMC.passObjectToIcon(star, { temp: thisStar.t });
        drawLightCurve();
        hrDiagramMC.setPointPosition(star, thisStar.t, thisStar.l);
      } else {
        var Mmin2 = MminSld;
        var Mmax2 = MmaxSld;
        if (arg < Mmin2) { arg = Mmin2; }
        else if (arg > Mmax2) { arg = Mmax2; }
        thisStar.m = arg;
        starSlider('mass', star).value = thisStar.m;
        visualizationMC['mass' + star] = thisStar.m;
      }
      matchButtonMaybeEnable();
      updatePeriod();
      var otherRestricted = restrictChecked(otherStarNumber);
      var thisRestricted = restrictChecked(star);
      if (thisRestricted) {
        setSeparationRange();
        setEccentricityRange();
        if (otherRestricted) { setRestrictedStarRanges(otherStarNumber); }
        else { setRadiusRange(otherStarNumber); }
      }
    }

    /* --------------------- change handlers (DoAction_6) ------------------ */
    function changeShowLightcurve() {
      curveMC.curveVisible = checks.showLightcurve.checked;
      curveMC.needsRender = true;
    }

    function changeRestrict1() {
      if (checks.restrict1.checked) { setRestrictToMainSequence(1); }
      else { setUnrestrictStar(1); }
    }

    function changeRestrict2() {
      if (checks.restrict2.checked) { setRestrictToMainSequence(2); }
      else { setUnrestrictStar(2); }
    }

    function changeEccentricity(arg) { setEccentricity(arg); }
    function changeSeparation(arg) { setSeparation(arg); }
    function changeMass1(arg) { setMass(1, arg); }
    function changeMass2(arg) { setMass(2, arg); }
    function changeRadius1(arg) { setRadius(1, arg); }
    function changeRadius2(arg) { setRadius(2, arg); }
    function changeTemp1(arg) { setTemp(1, arg); }
    function changeTemp2(arg) { setTemp(2, arg); }

    function changeShowOrbitalPaths() {
      visualizationMC.showOrbitalPaths = checks.showOrbitalPaths.checked;
    }

    function changeShowOrbitalPlane() {
      visualizationMC.showOrbitalPlane = checks.showOrbitalPlane.checked;
    }

    /* -------------------- view control (DoAction_7) ---------------------- */
    function changeLongitude(arg) {
      var newTheta = 90 - arg;
      visualizationMC._lineTheta = newTheta;
      if (checks.perspectiveLock.checked) {
        visualizationMC.setTheta(newTheta);
      } else {
        visualizationMC.requestRender();     // updateLine()
      }
      drawLightCurve();
      realignVisualizationPhase();
      matchButtonMaybeEnable();
    }

    function changeInclination(arg) {
      var newPhi = 90 - arg;
      visualizationMC._linePhi = newPhi;
      if (checks.perspectiveLock.checked) {
        visualizationMC.setPhi(newPhi);
      } else {
        visualizationMC.requestRender();     // updateLine()
      }
      drawLightCurve();
      realignVisualizationPhase();
      matchButtonMaybeEnable();
    }

    function changePerspectiveLock() {
      if (checks.perspectiveLock.checked) {
        setViewThetaAndPhi(getSystemTheta(), getSystemPhi());
        visualizationMC.showLine = false;
        visTitleField.textContent = 'perspective from earth';
        visDragProxy.hidden = true;
        visDragProxy.tabIndex = -1;
      } else {
        visualizationMC.showLine = true;
        visTitleField.textContent = 'click and drag to change perspective';
        visDragProxy.hidden = false;
        visDragProxy.tabIndex = 0;
      }
      updateVisDesc();
    }

    /* -------------------- presets (DoAction_6) --------------------------- */
    function systemsListValue() {
      var v = systemsList.value;
      if (v === '' || v === ' ') { return ' '; }
      return parseInt(v, 10);
    }

    function setEnabled(button, enabled) {
      button.disabled = !enabled;
    }

    function changeSelectedSystem() {
      if (systemsListValue() === ' ') {
        // the drop-down already reads "- select a preset -", so the comment
        // line stays empty (and collapses) until a preset is chosen
        commentField.textContent = '';
        setEnabled(setParametersToMatchButton, false);
        curveMC.displayDataset(null);
      } else {
        var sys = systemsArray[systemsListValue()];
        // Only the eight Student Guide examples carry comment text. The
        // original showed its unfinished "comments for this preset go here"
        // placeholder for the 46 catalog systems; here the line stays empty
        // and collapses instead.
        commentField.textContent = (typeof sys.comment === 'string') ? sys.comment : '';
        curveMC.displayDataset(sys.name);
        setParametersToMatch();
        announce('Preset ' + sys.name + ' loaded. ' + periodSpoken() + '.');
      }
    }

    function setParametersToMatch() {
      var i = systemsListValue();
      if (i === ' ') { return; }
      var dataObject = systemsArray[i];
      sysProps.a = dataObject.a;
      sysProps.e = dataObject.e;
      star1.m = dataObject.m1;
      star2.m = dataObject.m2;
      updatePeriod();
      if (dataObject.r1 === -1) { star1.r = 0.1; }
      else { star1.r = dataObject.a * dataObject.r1; }
      if (dataObject.r2 === -1) { star2.r = 0.1; }
      else { star2.r = dataObject.a * dataObject.r2; }
      star1.t = dataObject.t1;
      star2.t = dataObject.t2;
      star1.l = getLfromRT(star1.r, star1.t);
      star2.l = getLfromRT(star2.r, star2.t);
      setMassRange(1);
      setRadiusRange(1);
      setTempRange(1);
      setMassRange(2);
      setRadiusRange(2);
      setTempRange(2);
      setSeparationRange();
      setEccentricityRange();
      if (checks.restrict1.checked) { checks.restrict1.checked = false; }
      if (checks.restrict2.checked) { checks.restrict2.checked = false; }
      longitudeSlider.value = dataObject.w;
      inclinationSlider.value = dataObject.i;
      separationSlider.value = sysProps.a;
      eccentricitySlider.value = sysProps.e;
      mass1Slider.value = star1.m;
      radius1Slider.value = star1.r;
      temp1Slider.value = star1.t;
      mass2Slider.value = star2.m;
      radius2Slider.value = star2.r;
      temp2Slider.value = star2.t;
      hrDiagramMC.setPointPosition(1, star1.t, star1.l);
      hrDiagramMC.setPointPosition(2, star2.t, star2.l);
      var initObject = {
        separation: sysProps.a, eccentricity: sysProps.e,
        linePhi: getSystemPhi(), lineTheta: getSystemTheta(),
        mass1: star1.m, mass2: star2.m, radius1: star1.r, radius2: star2.r
      };
      if (checks.perspectiveLock.checked) {
        initObject.phi = initObject.linePhi;
        initObject.theta = initObject.lineTheta;
      }
      visualizationMC.initialize(initObject);
      visualizationMC.passObjectToIcon(1, { temp: star1.t });
      visualizationMC.passObjectToIcon(2, { temp: star2.t });
      drawLightCurve();
      setPhase(curveMC.cursorPhase);
      setEnabled(setParametersToMatchButton, false);
    }

    /* -------------------- HR diagram window ------------------------------ */
    var hrOpenedFrom = null;

    function openHRDiagramWindow() {
      hrWindow.hidden = false;
      hrOpenedFrom = document.activeElement;
      hrDiagramMC.needsRender = true;
      hrCloseButton.focus();
      announce('HR diagram window opened. ' + hrPointSpoken(1) + ' ' + hrPointSpoken(2));
    }

    function closeHRDiagramWindow() {
      hrWindow.hidden = true;
      if (hrOpenedFrom && hrOpenedFrom.focus) { hrOpenedFrom.focus(); }
      else { showHRDiagramButton.focus(); }
      announce('HR diagram window closed.');
    }

    function hrPointSpoken(star) {
      var s = (star === 1) ? star1 : star2;
      return 'Star ' + star + ': temperature ' + toSigDigits(s.t, 3) + ' kelvin, luminosity ' +
        toSigDigits(s.l, 3) + ' solar luminosities.';
    }

    function changeShowMainSequence() {
      hrDiagramMC.showMainSequenceOverlay = checks.showMainSequence.checked;
      hrMSLabels.hidden = !checks.showMainSequence.checked;
      hrDiagramMC.needsRender = true;
      announce(checks.showMainSequence.checked ?
        'Main sequence track shown.' : 'Main sequence track hidden.');
    }

    // hooks so the ranges overlay can read the current slider ranges
    var hrHooks = {
      getRadiusRange: function (star) { return starSlider('radius', star).getRange(); },
      getTempRange: function (star) { return starSlider('temp', star).getRange(); },
      getRestrictChecked: restrictChecked,
      getTmaxSld: function () { return TmaxSld; }
    };

    // build the main-sequence mass labels (reusing the original label values;
    // positions come from the sim's own mass-luminosity-temperature relations)
    (function buildMSLabels() {
      var masses = [20, 12, 8, 5, 3, 2, 1, 0.5, 0.2];
      for (var i = 0; i < masses.length; i++) {
        var m = masses[i];
        var l = getLfromM(m);
        var t = getTfromL(l);
        var x = hrDiagramMC.findX(t);
        var y = hrDiagramMC.findY(l);           // negative up from bottom
        if (x < 0 || x > hrDiagramMC.graphW) { continue; }
        hrDiagramMC.msLabelPoints.push({ x: x, y: y });
        // positionMSLabels() places it once its typeset size is known
        var span = document.createElement('span');
        span.appendChild(document.createTextNode(m + ' '));
        var math = document.createElement('span');
        math.textContent = '\\(M_\\odot\\)';
        span.appendChild(math);
        hrMSLabels.appendChild(span);
      }
    })();

    // window dragging (dragBarMC behavior, constrained to the shell)
    (function () {
      var drag = null;
      hrDragBar.addEventListener('pointerdown', function (e) {
        if (e.target === hrCloseButton) { return; }
        e.preventDefault();
        drag = {
          startX: e.clientX, startY: e.clientY,
          origX: hrWindow.offsetLeft, origY: hrWindow.offsetTop
        };
        hrDragBar.setPointerCapture(e.pointerId);
      });
      hrDragBar.addEventListener('pointermove', function (e) {
        if (!drag) { return; }
        var shell = hrWindow.offsetParent;
        var newX = drag.origX + (e.clientX - drag.startX);
        var newY = drag.origY + (e.clientY - drag.startY);
        var maxX = shell.clientWidth - hrWindow.offsetWidth;
        var maxY = shell.clientHeight - hrWindow.offsetHeight;
        newX = Math.max(0, Math.min(maxX, newX));
        newY = Math.max(0, Math.min(maxY, newY));
        hrWindow.style.left = newX + 'px';
        hrWindow.style.top = newY + 'px';
      });
      function endDrag() { drag = null; }
      hrDragBar.addEventListener('pointerup', endDrag);
      hrDragBar.addEventListener('pointercancel', endDrag);
    })();

    hrCloseButton.addEventListener('click', closeHRDiagramWindow);
    hrWindow.addEventListener('keydown', function (e) {
      if (e.key === 'Escape') { e.preventDefault(); closeHRDiagramWindow(); }
    });

    // draggable HR points: pointer drag + keyboard arrows, same state path
    function wireHRPoint(star) {
      var el = hrPointEls[star];
      var drag = null;
      var announceTimer = 0;

      // pointer -> plot coords, mapped back through the canvas scale so the
      // drag math stays in the original 300 x 200 plot coordinate system
      function plotCoordsFromEvent(e) {
        var rect = hrPlotWrap.getBoundingClientRect();
        var cw = hrDiagramMC.canvasW, ch = hrDiagramMC.canvasH;
        return {
          x: (e.clientX - rect.left) / rect.width * cw - hrDiagramMC.plotX,
          y: (e.clientY - rect.top) / rect.height * ch
             - hrDiagramMC.plotY - hrDiagramMC.graphH        // y negative up
        };
      }

      el.addEventListener('pointerdown', function (e) {
        e.preventDefault();
        el.focus();
        var pt = (star === 1) ? hrDiagramMC.point1 : hrDiagramMC.point2;
        var m = plotCoordsFromEvent(e);
        drag = { xOffset: pt.x - m.x, yOffset: pt.y - m.y };
        el.setPointerCapture(e.pointerId);
        hrDiagramMC.showRanges(star);
      });
      el.addEventListener('pointermove', function (e) {
        if (!drag) { return; }
        var m = plotCoordsFromEvent(e);
        setTempAndLuminosity(star,
          hrDiagramMC.findT(drag.xOffset + m.x),
          hrDiagramMC.findL(drag.yOffset + m.y));
      });
      function endDrag() {
        if (drag) {
          drag = null;
          hrDiagramMC.hideRanges();
          announce(hrPointSpoken(star));
        }
      }
      el.addEventListener('pointerup', endDrag);
      el.addEventListener('pointercancel', endDrag);

      el.addEventListener('focus', function () {
        if (!hrWindow.hidden) { hrDiagramMC.showRanges(star); }
      });
      el.addEventListener('blur', function () { hrDiagramMC.hideRanges(); });

      el.addEventListener('keydown', function (e) {
        var pt = (star === 1) ? hrDiagramMC.point1 : hrDiagramMC.point2;
        var stepPx = (e.key === 'PageUp' || e.key === 'PageDown') ? 10 : 2;
        var dx = 0, dy = 0;
        var handled = true;
        switch (e.key) {
          case 'ArrowLeft': dx = -stepPx; break;      // cooler is to the right
          case 'ArrowRight': dx = stepPx; break;
          case 'ArrowUp': dy = -stepPx; break;        // brighter is up
          case 'ArrowDown': dy = stepPx; break;
          case 'PageUp': dy = -stepPx; break;
          case 'PageDown': dy = stepPx; break;
          default: handled = false;
        }
        if (handled) {
          e.preventDefault();
          setTempAndLuminosity(star,
            hrDiagramMC.findT(pt.x + dx),
            hrDiagramMC.findL(pt.y + dy));
          clearTimeout(announceTimer);
          announceTimer = setTimeout(function () { announce(hrPointSpoken(star)); }, 500);
        }
      });
    }
    wireHRPoint(1);
    wireHRPoint(2);

    /* ------------------ lightcurve interactions -------------------------- */
    // maps a pointer event to plot x (0..320) in original stage coordinates
    function lcPlotX(e) {
      var rect = lcCanvas.getBoundingClientRect();
      return (e.clientX - rect.left) / rect.width * 322 - 1;
    }

    (function () {
      var mode = null;   // {type:'cursor'|'offset', ...}
      function startCursorDrag(e) {
        mode = {
          type: 'cursor',
          initCursorPhase: curveMC._cursorPhase,
          initX: lcPlotX(e)
        };
      }
      lcCanvas.addEventListener('pointerdown', function (e) {
        e.preventDefault();
        var x = lcPlotX(e);
        var cursorX = curveMC.plotWidth * curveMC.cursorFraction();
        if (Math.abs(x - cursorX) <= 8) {
          startCursorDrag(e);
          lcCursorProxy.focus();
        } else {
          // backgroundMC.onPress: drag the phase axis offset
          mode = { type: 'offset', initPhaseOffset: curveMC._phaseOffset, initX: x };
          lcXTicks.focus();
        }
        lcCanvas.setPointerCapture(e.pointerId);
      });
      lcCanvas.addEventListener('pointermove', function (e) {
        if (!mode) { return; }
        var x = lcPlotX(e);
        if (mode.type === 'cursor') {
          setPhase(mode.initCursorPhase + (x - mode.initX) / curveMC.plotWidth);
        } else {
          var newOffset = (((mode.initPhaseOffset + (x - mode.initX) / curveMC.plotWidth) % 1) + 1) % 1;
          curveMC.setPhaseOffset(newOffset);
        }
      });
      function endLcDrag() {
        if (mode) {
          if (mode.type === 'cursor') { announce('Phase ' + phaseSlider.valueString() + '.'); }
          else { announce('Phase axis offset ' + E.asToFixed(curveMC._phaseOffset, 2) + '.'); }
          mode = null;
        }
      }
      lcCanvas.addEventListener('pointerup', endLcDrag);
      lcCanvas.addEventListener('pointercancel', endLcDrag);

      // the cursor proxy strip also starts a cursor drag directly
      lcCursorProxy.addEventListener('pointerdown', function (e) {
        e.preventDefault();
        lcCursorProxy.focus();
        startCursorDrag(e);
        lcCursorProxy.setPointerCapture(e.pointerId);
      });
      lcCursorProxy.addEventListener('pointermove', function (e) {
        if (mode && mode.type === 'cursor') {
          var x = lcPlotX(e);
          setPhase(mode.initCursorPhase + (x - mode.initX) / curveMC.plotWidth);
        }
      });
      lcCursorProxy.addEventListener('pointerup', endLcDrag);
      lcCursorProxy.addEventListener('pointercancel', endLcDrag);
      lcCursorProxy.addEventListener('pointerenter', function () { curveMC.cursorHot = true; curveMC.needsRender = true; });
      lcCursorProxy.addEventListener('pointerleave', function () { curveMC.cursorHot = false; curveMC.needsRender = true; });
    })();

    // keyboard: cursor proxy = phase; tick strip = phase-axis offset
    (function () {
      var t1 = 0, t2 = 0;
      lcCursorProxy.addEventListener('keydown', function (e) {
        var step = (e.key === 'PageUp' || e.key === 'PageDown') ? 0.1 : 0.01;
        var handled = true;
        switch (e.key) {
          case 'ArrowLeft':
          case 'ArrowDown': setPhase(curveMC._cursorPhase - step); break;
          case 'ArrowRight':
          case 'ArrowUp': setPhase(curveMC._cursorPhase + step); break;
          case 'PageDown': setPhase(curveMC._cursorPhase - step); break;
          case 'PageUp': setPhase(curveMC._cursorPhase + step); break;
          case 'Home': setPhase(0); break;
          case 'End': setPhase(0.99); break;
          default: handled = false;
        }
        if (handled) {
          e.preventDefault();
          clearTimeout(t1);
          t1 = setTimeout(function () { announce('Phase ' + phaseSlider.valueString() + '.'); }, 500);
        }
      });
      lcXTicks.addEventListener('keydown', function (e) {
        var step = (e.key === 'PageUp' || e.key === 'PageDown') ? 0.1 : 0.01;
        var handled = true;
        switch (e.key) {
          case 'ArrowLeft':
          case 'ArrowDown': curveMC.setPhaseOffset(curveMC._phaseOffset - step); break;
          case 'ArrowRight':
          case 'ArrowUp': curveMC.setPhaseOffset(curveMC._phaseOffset + step); break;
          case 'PageDown': curveMC.setPhaseOffset(curveMC._phaseOffset - step); break;
          case 'PageUp': curveMC.setPhaseOffset(curveMC._phaseOffset + step); break;
          case 'Home': curveMC.setPhaseOffset(0); break;
          case 'End': curveMC.setPhaseOffset(0.5); break;
          default: handled = false;
        }
        if (handled) {
          e.preventDefault();
          clearTimeout(t2);
          t2 = setTimeout(function () {
            announce('Phase axis offset ' + E.asToFixed(curveMC._phaseOffset, 2) + '.');
          }, 500);
        }
      });
    })();

    // build the moving phase tick labels (0.0 .. 0.9)
    var lcTickSpans = [];
    (function () {
      for (var t = 0; t < 10; t++) {
        var span = document.createElement('span');
        span.textContent = (t / 10).toFixed(1);
        lcXTicks.appendChild(span);
        lcTickSpans.push(span);
      }
    })();

    function syncLcOverlays() {
      // cursor proxy tracks the red line
      var frac = curveMC.cursorFraction();
      lcCursorProxy.style.left = ((1 + frac * 320) / 322 * 100) + '%';
      lcCursorProxy.setAttribute('aria-valuenow', String(curveMC._cursorPhase));
      lcCursorProxy.setAttribute('aria-valuetext', 'Phase ' + phaseSlider.valueString());
      lcXTicks.setAttribute('aria-valuenow', String(curveMC._phaseOffset));
      lcXTicks.setAttribute('aria-valuetext',
        'Phase axis offset ' + E.asToFixed(curveMC._phaseOffset, 2));
      // moving tick labels
      for (var t = 0; t < 10; t++) {
        var f = (curveMC._phaseOffset + t / 10) % 1;
        lcTickSpans[t].style.left = ((1 + f * 320) / 322 * 100) + '%';
      }
    }

    // Each mass label sits just above and left of its tick, as the exported
    // main-sequence sprite drew it, but is kept inside the plot box so it can
    // never cover the axis numbers. Recomputed on every render, so it stays
    // correct after MathJax typesets and at any zoom level.
    function positionMSLabels() {
      var scale = hrPlotWrap.clientWidth / hrDiagramMC.canvasW;
      if (!scale) { return; }
      var d = hrDiagramMC;
      var pts = d.msLabelPoints;
      var spans = hrMSLabels.children;
      for (var i = 0; i < spans.length && i < pts.length; i++) {
        var el = spans[i];
        var w = el.offsetWidth;
        var h = el.offsetHeight;
        var left = (d.plotX + pts[i].x - 4) * scale - w;
        var top = (d.plotY + d.graphH + pts[i].y - 4) * scale - h;
        var minLeft = (d.plotX + 2) * scale;
        var minTop = (d.plotY + 2) * scale;
        var maxLeft = (d.plotX + d.graphW - 2) * scale - w;
        var maxTop = (d.plotY + d.graphH - 2) * scale - h;
        el.style.left = Math.max(minLeft, Math.min(maxLeft, left)) + 'px';
        el.style.top = Math.max(minTop, Math.min(maxTop, top)) + 'px';
      }
    }

    function syncHrOverlays() {
      positionMSLabels();
      var scale = hrPlotWrap.clientWidth / hrDiagramMC.canvasW;
      [1, 2].forEach(function (star) {
        var pt = (star === 1) ? hrDiagramMC.point1 : hrDiagramMC.point2;
        var el = hrPointEls[star];
        el.style.left = hrLeftPct(pt.x) + '%';
        el.style.top = hrTopPct(pt.y) + '%';
        var label = el.querySelector('span');
        if (label && isFinite(pt.labelX)) {
          // centred on the point, then pushed 14 plot-pixels away from the
          // other point (the original's labelMC offset)
          label.style.transform = 'translate(calc(-50% + ' + (pt.labelX * scale) +
            'px), calc(-50% + ' + (pt.labelY * scale) + 'px))';
        }
      });
    }

    /* ------------------ visualization perspective drag ------------------- */
    (function () {
      var drag = null;
      function stageCoords(e) {
        var rect = visCanvas.getBoundingClientRect();
        return {
          x: (e.clientX - rect.left) / rect.width * 400,
          y: (e.clientY - rect.top) / rect.height * 400
        };
      }
      function down(e) {
        if (checks.perspectiveLock.checked) { return; }
        e.preventDefault();
        var m = stageCoords(e);
        drag = {
          initX: m.x, initY: m.y,
          dragPhi: visualizationMC.phi,
          dragTheta: visualizationMC.theta
        };
        visDragProxy.focus();
        visDragProxy.setPointerCapture(e.pointerId);
      }
      function move(e) {
        if (!drag) { return; }
        var m = stageCoords(e);
        // verbatim drag math: 57.29577951308232 * dpx / 400 degrees
        var newPhi = drag.dragPhi - 57.29577951308232 * (drag.initY - m.y) / 400;
        var newTheta = drag.dragTheta - 57.29577951308232 * (m.x - drag.initX) / 400;
        if (newPhi > 90) { newPhi = 90; }
        else if (newPhi < -90) { newPhi = -90; }
        setViewThetaAndPhi(newTheta, newPhi);
        updateVisDesc();
      }
      function up() {
        if (drag) {
          drag = null;
          announceView();
        }
      }
      visDragProxy.addEventListener('pointerdown', down);
      visDragProxy.addEventListener('pointermove', move);
      visDragProxy.addEventListener('pointerup', up);
      visDragProxy.addEventListener('pointercancel', up);

      var announceTimer = 0;
      visDragProxy.addEventListener('keydown', function (e) {
        var step = e.shiftKey ? 0.5 : 2;
        var handled = true;
        var theta = visualizationMC.theta;
        var phi = visualizationMC.phi;
        switch (e.key) {
          case 'ArrowLeft': theta += step; break;
          case 'ArrowRight': theta -= step; break;
          case 'ArrowUp': phi = Math.min(90, phi + step); break;
          case 'ArrowDown': phi = Math.max(-90, phi - step); break;
          case 'PageUp': phi = Math.min(90, phi + 15); break;
          case 'PageDown': phi = Math.max(-90, phi - 15); break;
          default: handled = false;
        }
        if (handled) {
          e.preventDefault();
          setViewThetaAndPhi(theta, phi);
          updateVisDesc();
          clearTimeout(announceTimer);
          announceTimer = setTimeout(announceView, 500);
        }
      });

      function announceView() {
        announce('View rotated. Viewing direction ' +
          toSigDigits(visualizationMC.theta, 3) + ' degrees, viewing height ' +
          toSigDigits(visualizationMC.phi, 3) + ' degrees.');
      }
    })();

    /* --------------------- text descriptions ----------------------------- */
    function updateVisDesc() {
      var locked = checks.perspectiveLock.checked;
      var text = 'Binary system visualization, ' +
        (locked ? 'seen from earth. ' : 'seen from a user-chosen direction; a red arrow points toward earth. ') +
        'Phase ' + E.asToFixed(curveMC._cursorPhase, 2) + '. ' +
        'Star 1: temperature ' + toSigDigits(star1.t, 3) + ' kelvin, radius ' +
        toSigDigits(star1.r, 3) + ' solar radii. ' +
        'Star 2: temperature ' + toSigDigits(star2.t, 3) + ' kelvin, radius ' +
        toSigDigits(star2.r, 3) + ' solar radii. ' +
        'Separation ' + toSigDigits(sysProps.a, 3) + ' solar radii, eccentricity ' +
        E.asToFixed(sysProps.e, 2) + '. ' +
        systemPeriodField.textContent + '.';
      visDesc.textContent = text;
    }

    function updateLcDesc() {
      var text;
      if (curveMC._noEclipse) {
        text = 'Light curve of normalized visual flux versus phase. No eclipses occur: the flux stays at 1.0 for all phases.';
      } else {
        var minFrac = curveMC._minVisFlux / curveMC._maxVisFlux;
        text = 'Light curve of normalized visual flux versus phase. Full brightness is 1.0. ' +
          'The deepest eclipse drops the flux to ' + E.asToFixed(minFrac, 2) +
          ' near phase 0.';
      }
      lcDesc.textContent = text;
    }

    /* --------------------- initialize (DoAction_7) ------------------------ */
    function initialize() {
      hrWindow.hidden = true;
      sysProps.a = separationSlider.value;
      sysProps.e = eccentricitySlider.value;
      star1.r = radius1Slider.value;
      star1.m = mass1Slider.value;
      star1.t = temp1Slider.value;
      star1.l = getLfromRT(star1.r, star1.t);
      star2.r = radius2Slider.value;
      star2.m = mass2Slider.value;
      star2.t = temp2Slider.value;
      star2.l = getLfromRT(star2.r, star2.t);
      setMassRange(1);
      setRadiusRange(1);
      setTempRange(1);
      setMassRange(2);
      setRadiusRange(2);
      setTempRange(2);
      setSeparationRange();
      setEccentricityRange();
      updatePeriod();
      var initObject = {
        phase: 0, separation: separationSlider.value, eccentricity: eccentricitySlider.value,
        mass1: mass1Slider.value, mass2: mass2Slider.value,
        radius1: radius1Slider.value, radius2: radius2Slider.value,
        phi: getSystemPhi(), theta: getSystemTheta(),
        showOrbitalPlane: true, showOrbitalPaths: true,
        autoScale: true, targetSize: 360,
        lineTheta: getSystemTheta(), linePhi: getSystemPhi(),
        showLine: false, lineExtra: 20
      };
      initParamsObj = initObject;
      initParamsObj.temperature1 = temp1Slider.value;
      initParamsObj.temperature2 = temp2Slider.value;
      initParamsObj.inclination = inclinationSlider.value;
      initParamsObj.longitude = longitudeSlider.value;
      visualizationMC.initialize(initObject);
      visualizationMC.passObjectToIcon(1, { temp: temp1Slider.value });
      visualizationMC.passObjectToIcon(2, { temp: temp2Slider.value });
      hrDiagramMC.setPointPosition(1, star1.t, star1.l);
      hrDiagramMC.setPointPosition(2, star2.t, star2.l);
      curveMC.phaseOffset = 1.5;
      drawLightCurve();
      setPhase(0.7);
      visTitleField.textContent = 'perspective from earth';

      // populate the presets list (grouping mirrors the original headings)
      var opt = document.createElement('option');
      opt.value = '';
      opt.textContent = '- select a preset -';
      systemsList.appendChild(opt);
      function addGroup(label, from, to) {
        var group = document.createElement('optgroup');
        group.label = label;
        for (var i = from; i < to; i++) {
          var o = document.createElement('option');
          o.value = String(i);
          o.textContent = (i + 1) + '. ' + systemsArray[i].name;
          group.appendChild(o);
        }
        systemsList.appendChild(group);
      }
      addGroup('Student Guide Examples', 0, E.completeSystemsStart);
      addGroup('Datasets with Complete Parameters', E.completeSystemsStart, E.incompleteSystemsStart);
      addGroup('Datasets with Incomplete Parameters', E.incompleteSystemsStart, E.extraSystemsStart);
      addGroup('More Datasets', E.extraSystemsStart, systemsArray.length);
      changeSelectedSystem();
      updateVisDesc();
    }

    /* ------------------------- onReset (DoAction) ------------------------- */
    function onReset() {
      hrWindow.hidden = true;
      if (playing) { changeAnimateState(); }
      animationSpeedSlider.value = 0.0001;
      checks.showLightcurve.checked = true;
      changeShowLightcurve();
      sysProps.a = initParamsObj.separation;
      sysProps.e = initParamsObj.eccentricity;
      star1.r = initParamsObj.radius1;
      star1.m = initParamsObj.mass1;
      star1.t = initParamsObj.temperature1;
      star1.l = getLfromRT(star1.r, star1.t);
      star2.r = initParamsObj.radius2;
      star2.m = initParamsObj.mass2;
      star2.t = initParamsObj.temperature2;
      star2.l = getLfromRT(star2.r, star2.t);
      checks.restrict1.checked = false;
      checks.restrict2.checked = false;
      setMassRange(1);
      setRadiusRange(1);
      setTempRange(1);
      setMassRange(2);
      setRadiusRange(2);
      setTempRange(2);
      setSeparationRange();
      setEccentricityRange();
      inclinationSlider.value = initParamsObj.inclination;
      longitudeSlider.value = initParamsObj.longitude;
      separationSlider.value = sysProps.a;
      eccentricitySlider.value = sysProps.e;
      mass1Slider.value = star1.m;
      radius1Slider.value = star1.r;
      temp1Slider.value = star1.t;
      mass2Slider.value = star2.m;
      radius2Slider.value = star2.r;
      temp2Slider.value = star2.t;
      updatePeriod();
      visualizationMC.initialize(initParamsObj);
      visualizationMC.passObjectToIcon(1, { temp: star1.t });
      visualizationMC.passObjectToIcon(2, { temp: star2.t });
      hrDiagramMC.setPointPosition(1, star1.t, star1.l);
      hrDiagramMC.setPointPosition(2, star2.t, star2.l);
      curveMC.phaseOffset = 1.5;
      drawLightCurve();
      setPhase(0.7);
      checks.perspectiveLock.checked = true;
      changePerspectiveLock();
      checks.showOrbitalPaths.checked = true;
      changeShowOrbitalPaths();
      checks.showOrbitalPlane.checked = true;
      changeShowOrbitalPlane();
      checks.showMainSequence.checked = false;
      changeShowMainSequence();
      systemsList.value = '';
      changeSelectedSystem();
      announce('Simulation reset to its initial state. ' + periodSpoken() + '.');
    }

    /* --------------------------- wiring ---------------------------------- */
    checks.showLightcurve.addEventListener('change', function () {
      changeShowLightcurve();
      announce(checks.showLightcurve.checked ? 'Light curve shown.' : 'Light curve hidden.');
    });
    checks.perspectiveLock.addEventListener('change', function () {
      changePerspectiveLock();
      announce(checks.perspectiveLock.checked ?
        'Perspective locked on the view from earth.' :
        'Perspective unlocked. Drag the visualization or focus it and use arrow keys to rotate; the red arrow points toward earth.');
    });
    checks.showOrbitalPaths.addEventListener('change', function () {
      changeShowOrbitalPaths();
      announce(checks.showOrbitalPaths.checked ? 'Orbital paths shown.' : 'Orbital paths hidden.');
    });
    checks.showOrbitalPlane.addEventListener('change', function () {
      changeShowOrbitalPlane();
      announce(checks.showOrbitalPlane.checked ? 'Orbital plane shown.' : 'Orbital plane hidden.');
    });
    checks.restrict1.addEventListener('change', function () {
      changeRestrict1();
      announce((checks.restrict1.checked ?
        'Star 1 restricted to the main sequence. ' : 'Star 1 no longer restricted to the main sequence. ') +
        hrPointSpoken(1));
    });
    checks.restrict2.addEventListener('change', function () {
      changeRestrict2();
      announce((checks.restrict2.checked ?
        'Star 2 restricted to the main sequence. ' : 'Star 2 no longer restricted to the main sequence. ') +
        hrPointSpoken(2));
    });
    checks.showMainSequence.addEventListener('change', changeShowMainSequence);

    animationButton.addEventListener('click', changeAnimateState);
    showHRDiagramButton.addEventListener('click', openHRDiagramWindow);
    setParametersToMatchButton.addEventListener('click', function () {
      setParametersToMatch();
      announce('Parameters reset to match the selected preset. ' + periodSpoken() + '.');
    });
    systemsList.addEventListener('change', changeSelectedSystem);

    // masthead Reset (the component dispatches a bubbling "sim-reset" event)
    document.addEventListener('sim-reset', onReset);

    // the HR mass labels are placed in pixels, so re-place them whenever the
    // canvas is rescaled (window resize or browser zoom)
    window.addEventListener('resize', function () {
      hrDiagramMC.needsRender = true;
    });

    /* --------------------- main animation/render loop --------------------- */
    function tick(now) {
      if (playing) {
        // onEnterFrameFunc: setPhase(cursorPhase + (now - last) * speed)
        var dt = now - timeLast;
        timeLast = now;
        if (reducedMotion) {
          // prefers-reduced-motion: step the phase at a slow, discrete rate
          reducedAccum += dt;
          if (reducedAccum >= 500) {
            setPhase(curveMC.cursorPhase + reducedAccum * animationSpeedSlider.value);
            reducedAccum = 0;
          }
        } else {
          setPhase(curveMC.cursorPhase + dt * animationSpeedSlider.value);
        }
      }
      if (visualizationMC.needsRender) {
        visualizationMC.needsRender = false;
        visualizationMC.render();
      }
      if (curveMC.needsRender) {
        curveMC.needsRender = false;
        curveMC.render();
        syncLcOverlays();
      }
      if (hrDiagramMC.needsRender && !hrWindow.hidden) {
        hrDiagramMC.needsRender = false;
        hrDiagramMC.render(hrHooks);
        syncHrOverlays();
      }
      requestAnimationFrame(tick);
    }

    /* ------------------------------ boot ---------------------------------- */
    initialize();
    changePerspectiveLock();     // apply initial lock state (hides drag proxy)
    requestAnimationFrame(tick);

    // The unit symbols and HR mass labels are built above, i.e. after the
    // page's initial typeset, so typeset them now.
    E.typesetMath();

    // Equation hook: this sim displays no standalone equations; all inline
    // math (unit symbols, HR-diagram labels) is typeset by MathJax when the
    // page loads. klunlInitEqn just re-runs the tab-order cleanup for any
    // math built after load.
    window.klunlInitEqn = function () {
      E.typesetMath();
    };

    // Internal handles used by automated tests; not part of the public UI.
    window.__EBS_DEBUG__ = {
      visualizationMC: visualizationMC,
      curveMC: curveMC,
      hrDiagramMC: hrDiagramMC,
      sliders: sliders,
      star1: star1, star2: star2, sysProps: sysProps,
      setPhase: setPhase,
      onReset: onReset,
      hrHooks: hrHooks,
      syncLcOverlays: syncLcOverlays,
      syncHrOverlays: syncHrOverlays
    };
  });
})();
