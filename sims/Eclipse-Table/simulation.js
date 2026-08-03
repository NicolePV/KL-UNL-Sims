/* =============================================================================
   Eclipse Table  --  accessible HTML5 port of eclipse_table010.swf (Flash / AS1)
   -----------------------------------------------------------------------------
   Behaviour is identical to the original: a static plot of every solar and lunar
   eclipse from 2000 through 2029, positioned by year (x) and month (y). Pointing
   at (or, here, focusing) an eclipse pops an information panel next to it. There
   is no animation, drag, or timing in the original, so none is added.

   Ground truth for behaviour is the decompiled ActionScript:
     - scripts/DefineSprite_50/frame_1/DoAction.as  (data tables + info panels)
     - scripts/SolarEclipseIcon.as / LunarEclipseIcon.as  (icon placement + hover)
   The data arrays and on-screen strings below are copied VERBATIM from that source.
   ========================================================================== */

'use strict';

/* -----------------------------------------------------------------------------
   1. VERBATIM DATA (from DefineSprite_50/frame_1/DoAction.as)
   -----------------------------------------------------------------------------
   Each eclipse record is:
     [ x, y, type, month, day, year, saros, magnitude, duration, visibility ]
       x,y       : original Flash stage coordinates of the dot (reused as-is)
       type      : type index (meaning differs for solar vs lunar, see below)
       month     : 0..11 index into months[]
       day, year : calendar date
       saros     : Saros series number
       magnitude : eclipse magnitude (present in source; not shown by the original
                   info panel, so not displayed here either)
       duration  : duration string, exactly as in the source ("-" when none)
       visibility: region-of-visibility string
--------------------------------------------------------------------------------*/

var months = ["January","February","March","April","May","June","July","August","September","October","November","December"];
var margin = 15;

var solarEclipses = [[2,-405.6,3,1,5,2000,150,0.579,"-","Antarctica"],[10,-225.6,3,6,1,2000,117,0.477,"-","S Pacific Ocean, s S. America"],[11.6,-188.6,3,6,31,2000,155,0.603,"-","n Asia, nw N. America"],[19.7,-7.4,3,11,25,2000,122,0.723,"-","N. & C. America"],[29.4,-237.9,0,5,21,2001,127,1.05,"04m57s","e S. America, Africa (Total: s Atlantic, s Africa, Madagascar)"],[39.1,-21,1,11,14,2001,132,0.968,"03m53s","N. & C. America, nw S. America (Annular: c Pacific, Costa Rica)"],[48.8,-251.5,1,5,10,2002,137,0.996,"00m23s","e Asia, Australia, w N. America (Annular: n Pacific, w Mexico)"],[58.5,-33.3,0,11,4,2002,142,1.024,"02m04s","s Africa, Antarctica, Indonesia, Australia (Total: s Africa, s Indian, s Australia)"],[68.3,-263.8,1,4,31,2003,147,0.938,"03m37s","Europe, Asia, nw N. America (Annular: Iceland, Greenland)"],[77.9,-46.8,0,10,23,2003,152,1.038,"01m57s","Australia, N. Z., Antarctica, s S. America (Total: Antarctica)"],[86,-315.6,3,3,19,2004,119,0.736,"-","Antarctica, s Africa"],[95.7,-96.2,3,9,14,2004,124,0.927,"-","ne Asia, Hawaii, Alaska"],[105.4,-329.2,2,3,8,2005,129,1.007,"00m42s","N. Zealand, N. & S. America (Hybrid: s Pacific, Panama, Colombia, Venezuela)"],[115.1,-109.7,1,9,3,2005,134,0.958,"04m32s","Europe, Africa, s Asia (Annular: Portugal, Spain, Libia, Sudan, Kenya)"],[124.8,-341.5,0,2,29,2006,139,1.052,"04m07s","Africa, Europe, w Asia (Total: c Africa, Turkey, Russia)"],[134.5,-123.3,1,8,22,2006,144,0.935,"07m09s","S. America, w Africa, Antarctica (Annular: Guyana, Suriname, F. Guiana, s Atlantic)"],[144.3,-353.8,3,2,19,2007,149,0.874,"-","Asia, Alaska"],[153.9,-136.8,3,8,11,2007,154,0.749,"-","S. America, Antarctica"],[162.1,-403.2,1,1,7,2008,121,0.965,"02m12s","Antarctica, e Australia, N. Zealand (Annular: Antarctica)"],[171.7,-187.4,0,7,1,2008,126,1.039,"02m27s","ne N. America, Europe, Asia (Total: n Canada, Greenland, Siberia, Mongolia, China)"],[181.4,-417.9,1,0,26,2009,131,0.928,"07m54s","s Africa, Antarctica, se Asia, Australia (Annular: s Indian, Sumatra, Borneo)"],[191.1,-199.7,0,6,22,2009,136,1.08,"06m39s","e Asia, Pacific Ocean, Hawaii (Total: India, Nepal, China, c Pacific)"],[200.8,-431.5,1,0,15,2010,141,0.919,"11m08s","Africa, Asia (Annular: c Africa, India, Malymar, China)"],[210.5,-213.3,0,6,11,2010,146,1.058,"05m20s","s S. America (Total: s Pacific, Easter Is., Chile, Argentina)"],[220.2,-445.1,3,0,4,2011,151,0.857,"-","Europe, Africa, c Asia"],[228.3,-262.6,3,5,1,2011,118,0.601,"-","e Asia, n N. America, Iceland"],[230,-225.6,3,6,1,2011,156,0.096,"-","s Indian Ocean"],[238,-44.4,3,10,25,2011,123,0.905,"-","s Africa, Antarctica, Tasmania, N.Z."],[247.7,-277.4,1,4,20,2012,128,0.944,"05m46s","Asia, Pacific, N. America (Annular: China, Japan, Pacific, w U.S.)"],[257.4,-59.2,0,10,13,2012,133,1.05,"04m02s","Australia, N.Z., s Pacific, s S. America (Total: n Australia, s Pacific)"],[267.1,-289.7,1,4,10,2013,138,0.954,"06m03s","Australia, N.Z., c Pacific (Annular: n Australia, Solomon Is., c Pacific)"],[276.8,-71.5,2,10,3,2013,143,1.016,"01m40s","e Americas, s Europe, Africa (Hybrid: Atlantic, c Africa)"],[286.5,-303.3,1,3,29,2014,148,0.984,"Non-Central","s Indian, Australia, Antarctica (Annular: Antarctica)"],[296.2,-85.1,3,9,23,2014,153,0.811,"-","n Pacific, N. America"],[304.3,-352.6,0,2,20,2015,120,1.045,"02m47s","Iceland, Europe, n Africa, n Asia (Total: n Atlantic, Faeroe Is, Svalbard)"],[314,-134.4,3,8,13,2015,125,0.787,"-","s Africa, s Indian, Antarctica"],[323.7,-366.2,0,2,9,2016,130,1.045,"04m09s","e Asia, Australia, Pacific (Total: Sumatra, Borneo, Sulawesi, Pacific)"],[333.4,-149.2,1,8,1,2016,135,0.974,"03m06s","Africa, Indian Ocean (Annular: Atlantic, c Africa, Madagascar, Indian)"],[343.1,-379.7,1,1,26,2017,140,0.992,"00m44s","s S. America, Atlantic, Africa, Antarctica (Annular: Pacific, Chile, Argentina, Atlantic, Africa)"],[352.8,-162.7,0,7,21,2017,145,1.031,"02m40s","N. America, n S. America (Total: n Pacific, U.S., s Atlantic)"],[362.5,-393.3,3,1,15,2018,150,0.599,"-","Antarctica, s S. America"],[370.6,-210.8,3,6,13,2018,117,0.337,"-","s Australia"],[372.2,-175.1,3,7,11,2018,155,0.736,"-","n Europe, ne Asia"],[380.3,-442.6,3,0,6,2019,122,0.715,"-","ne Asia, n Pacific"],[390,-224.4,0,6,2,2019,127,1.046,"04m33s","s Pacific, S. America (Total: s Pacific, Chile, Argentina)"],[399.7,-6.2,1,11,26,2019,132,0.97,"03m40s","Asia, Australia (Annular: Saudi Arabia, India, Sumatra, Borneo)"],[409.4,-237.9,1,5,21,2020,137,0.994,"00m38s","Africa, se Europe, Asia (Annular: c Africa, s Asia, China, Pacific)"],[419.1,-21,0,11,14,2020,142,1.025,"02m10s","Pacific, s S. America, Antarctica (Total: s Pacific, Chile, Argentina, s Atlantic)"],[428.8,-251.5,1,5,10,2021,147,0.943,"03m51s","n N. America, Europe, Asia (Annular: n Canada, Greenland, Russia)"],[438.5,-33.3,0,11,4,2021,152,1.037,"01m54s","Antarctica, S. Africa, s Atlantic (Total: Antarctca)"],[446.6,-302.1,3,3,30,2022,119,0.639,"-","se Pacific, s S. America"],[456.3,-82.6,3,9,25,2022,124,0.861,"-","Europe, ne Africa, Mid East, w Asia"],[466,-314.4,2,3,20,2023,129,1.013,"01m16s","se Asia, E. Indies, Australia, Philippines. N.Z. (Hybrid: Indonesia, Australia, Papua New Guinea)"],[475.7,-96.2,1,9,14,2023,134,0.952,"05m17s","N. America, C. America, S. America (Annular: w US, C. America, Columbia, Brazil)"],[485.4,-329.2,0,3,8,2024,139,1.057,"04m28s","N. America, C. America (Total: Mexico, c US, e Canada)"],[495.1,-111,1,9,2,2024,144,0.933,"07m25s","Pacific, s S. America (Annular: s Chile, s Argentina)"],[504.8,-341.5,3,2,29,2025,149,0.936,"-","nw Africa, Europe, n Russia"],[514.5,-124.5,3,8,21,2025,154,0.853,"-","s Pacific, N.Z., Antarctica"],[522.6,-390.8,1,1,17,2026,121,0.963,"02m20s","s Argentina & Chile, s Africa, Antarctica (Annular: Antarctica)"],[532.3,-173.8,0,7,12,2026,126,1.039,"02m18s","n N. America, w Africa, Europe (Total: Arctic, Greenland, Iceland, Spain)"],[542,-404.4,1,1,6,2027,131,0.928,"07m51s","S. America, Antarctica, w & s Africa (Annular: Chile, Argentina, Atlantic)"],[551.7,-186.2,0,7,2,2027,136,1.079,"06m23s","Africa, Europe, Mid East, w & s Asia (Total: Morocco, Spain, Algeria, Libya, Egypt, Saudi Arabia, Yemen, Somalia)"],[561.4,-417.9,1,0,26,2028,141,0.921,"10m27s","e N. America, C. & S. America, w Europe, nw Africa (Annular: Ecuador, Peru, Brazil, Suriname, Spain, Portugal)"],[571.1,-199.7,0,6,22,2028,146,1.056,"05m10s","SE Asia, E. Indies, Australia, N.Z. (Total: Australia, N.Z.)"],[580.8,-432.7,3,0,14,2029,151,0.871,"-","N. America, C. America"],[588.9,-249,3,5,12,2029,118,0.458,"-","Arctic, Scandanavia, Alaska, n Asia, n Canada"],[590.5,-213.3,3,6,11,2029,156,0.23,"-","s Chile, s Argentina"],[598.6,-32.1,3,11,5,2029,123,0.891,"-","s Argentina, s Chile, Antarctica"]];

var lunarEclipses = [[1.2,-424.1,0,0,21,2000,124,1.33,"03h24m (01h18m)","Pacific, Americas, Europe, Africa"],[10.8,-207.1,0,6,16,2000,129,1.773,"03h57m (01h47m)","Asia, Pacific, w Americas"],[20.5,-438.9,0,0,9,2001,134,1.195,"03h17m (01h02m)","e Americas, Europe, Africa, Asia"],[30.2,-220.7,2,6,5,2001,139,0.499,"02h40m","e Africa, Asia, Aus., Pacific"],[39.9,-1.2,1,11,30,2001,144,-0.11,"-","e Asia, Aus., Pacific, Americas"],[48,-270,1,4,26,2002,111,-0.283,"-","e Asia, Aus., Pacific, w Americas"],[49.6,-234.2,1,5,24,2002,149,-0.788,"-","S. America, Europe, Africa, c Asia, Aus."],[57.8,-50.5,1,10,20,2002,116,-0.222,"-","Americas, Europe, Africa, e Asia"],[67.5,-282.3,0,4,16,2003,121,1.134,"03h15m (00h53m)","c Pacific, Americas, Europe, Africa"],[77.2,-64.1,0,10,9,2003,126,1.022,"03h32m (00h24m)","Americas, Europe, Africa, c Asia"],[86.8,-297.1,0,4,4,2004,131,1.309,"03h24m (01h16m)","S. America, Europe, Africa, Asia, Aus."],[96.5,-78.9,0,9,28,2004,136,1.313,"03h39m (01h21m)","Americas, Europe, Africa, c Asia"],[106.2,-309.5,1,3,24,2005,141,-0.139,"-","e Asia, Aus., Pacific, Americas"],[115.9,-92.5,2,9,17,2005,146,0.068,"00h58m","Asia, Aus., Pacific, North America"],[124,-360,1,2,14,2006,113,-0.055,"-","Americas, Europe, Africa, Asia"],[133.7,-141.8,2,8,7,2006,118,0.189,"01h33m","Europe, Africa, Asia, Aus."],[143.4,-373.6,0,2,3,2007,123,1.238,"03h42m (01h14m)","Americas, Europe, Africa, Asia"],[153.2,-154.1,0,7,28,2007,128,1.481,"03h33m (01h31m)","e Asia, Aus., Pacific, Americas"],[162.8,-385.9,0,1,21,2008,133,1.111,"03h26m (00h51m)","c Pacific, Americas, Europe, Africa"],[172.5,-168.9,2,7,16,2008,138,0.813,"03h09m","S. America, Europe, Africa, Asia, Aus."],[182.2,-400.7,1,1,9,2009,143,-0.083,"-","e Europe, Asia, Aus., Pacific, w N.A."],[190.3,-218.2,1,6,7,2009,110,-0.909,"-","Aus., Pacific, Americas"],[191.9,-181.2,1,7,6,2009,148,-0.661,"-","Americas, Europe, Africa, w Asia"],[200,0,2,11,31,2009,115,0.082,"01h02m","Europe, Africa, Asia, Aus."],[209.7,-231.8,2,5,26,2010,120,0.542,"02h44m","e Asia, Aus., Pacific, w Americas"],[219.5,-12.3,0,11,21,2010,125,1.262,"03h29m (01h13m)","e Asia, Aus., Pacific, Americas, Europe"],[229.1,-245.3,0,5,15,2011,130,1.705,"03h40m (01h41m)","S.America, Europe, Africa, Asia, Aus."],[238.8,-25.9,0,11,10,2011,135,1.11,"03h33m (00h52m)","Europe, e Africa, Asia, Aus., Pacific, N.A."],[248.5,-258.9,2,5,4,2012,140,0.376,"02h08m","Asia, Aus., Pacific, Americas"],[258.2,-40.7,1,10,28,2012,145,-0.184,"-","Europe, e Africa, Asia, Aus., Pacific, N.A."],[266.3,-308.2,2,3,25,2013,112,0.02,"00h32m","Europe, Africa, Asia, Aus."],[267.9,-271.2,1,4,25,2013,150,-0.928,"-","Americas, Africa"],[275.9,-91.2,1,9,18,2013,117,-0.266,"-","Americas, Europe, Africa, Asia"],[285.8,-320.5,0,3,15,2014,122,1.296,"03h35m (01h19m)","Aus., Pacific, Americas"],[295.4,-103.6,0,9,8,2014,127,1.172,"03h20m (01h00m)","Asia, Aus., Pacific, Americas"],[305.2,-334.1,0,3,4,2015,132,1.006,"03h30m (00h12m)","Asia, Aus., Pacific, Americas"],[314.8,-115.9,0,8,28,2015,137,1.282,"03h21m (01h13m)","e Pacific, Americas, Europe, Africa, w Asia"],[324.5,-348.9,1,2,23,2016,142,-0.307,"-","Asia, Aus., Pacific, w Americas"],[332.6,-166.4,1,7,18,2016,109,-0.992,"-","Aus., Pacific, Americas"],[334.2,-130.7,1,8,16,2016,147,-0.058,"-","Europe, Africa, Asia, Aus., w Pacific"],[342.3,-398.2,1,1,11,2017,114,-0.031,"-","Americas, Europe, Africa, Asia"],[352,-180,2,7,7,2017,119,0.252,"01h57m","Europe, Africa, Asia, Aus."],[361.7,-411.8,0,0,31,2018,124,1.321,"03h23m (01h17m)","Asia, Aus., Pacific, w N. America"],[371.4,-193.6,0,6,27,2018,129,1.614,"03h55m (01h44m)","S.America, Europe, Africa, Asia, Aus."],[381.2,-424.1,0,0,21,2019,134,1.201,"03h17m (01h03m)","c Pacific, Americas, Europe, Africa"],[390.8,-207.1,2,6,16,2019,139,0.657,"02h59m","S.America, Europe, Africa, Asia, Aus."],[400.5,-437.7,1,0,10,2020,144,-0.111,"-","Europe, Africa, Asia, Aus."],[408.5,-257.7,1,5,5,2020,111,-0.399,"-","Europe, Africa, Asia, Aus."],[410.2,-220.7,1,6,5,2020,149,-0.639,"-","Americas, sw Europe, Africa"],[418.3,-38.2,1,10,30,2020,116,-0.258,"-","Asia, Aus., Pacific, Americas"],[428,-270,0,4,26,2021,121,1.016,"03h08m (00h19m)","e Asia, Australia, Pacific, Americas"],[437.7,-51.8,2,10,19,2021,126,0.978,"03h29m","Americas, n Europe, e Asia, Australia, Pacific"],[447.5,-282.3,0,4,16,2022,131,1.419,"03h28m (01h26m)","Americas, Europe, Africa"],[457.1,-65.3,0,10,8,2022,136,1.364,"03h40m (01h26m)","Asia, Australia, Pacific, Americas"],[466.8,-295.9,1,4,5,2023,141,-0.041,"-","Africa, Asia, Australia"],[476.5,-78.9,2,9,28,2023,146,0.128,"01h19m","e Americas, Europe, Africa, Asia, Australia"],[484.6,-346.4,1,2,25,2024,113,-0.127,"-","Americas"],[494.3,-128.2,2,8,18,2024,118,0.09,"01h05m","Americas, Europe, Africa"],[504,-360,0,2,14,2025,123,1.183,"03h39m (01h06m)","Pacific, Americas, w Europe, w Africa"],[513.7,-141.8,0,8,7,2025,128,1.367,"03h30m (01h23m)","Europe, Africa, Asia, Australia"],[523.4,-373.6,0,2,3,2026,133,1.155,"03h28m (00h59m)","e Asia, Australia, Pacific, Americas"],[533.2,-154.1,2,7,28,2026,138,0.935,"03h19m","e Pacific, Americas, Europe, Africa"],[542.8,-387.1,1,1,20,2027,143,-0.052,"-","Americas, Europe, Africa, Asia"],[550.9,-204.7,1,6,18,2027,110,-1.063,"-","e Africa, Asia, Australia, Pacific"],[552.5,-167.7,1,7,17,2027,148,-0.521,"-","Pacific, Americas"],[560.7,-435.2,2,0,12,2028,115,0.072,"00h59m","Americas, Europe, Africa"],[570.2,-219.5,2,6,6,2028,120,0.394,"02h23m","Europe, Africa, Asia, Australia"],[580,0,0,11,31,2028,125,1.252,"03h30m (01h12m)","Europe, Africa, Asia, Australia, Pacific"],[589.7,-231.8,0,5,26,2029,130,1.849,"03h40m (01h43m)","Americas, Europe, Africa, Mid East"],[599.4,-13.6,0,11,20,2029,135,1.121,"03h34m (00h55m)","Americas, Europe, Africa, Asia"]];

/* Type-name tables (verbatim from the switch statements in DoAction.as) */
var SOLAR_TYPES = ["Total", "Annular", "Hybrid", "Partial"];   // solar switch: 0..3
var LUNAR_TYPES = ["Total", "Penumbral", "Partial"];           // lunar switch: 0..2

/* Static info-panel labels (verbatim from texts/ 20,19,16,14) */
var LBL_TYPE = "Eclipse Type:";
var LBL_SAROS = "Saros:";
var LBL_DURATION = "Duration:";
var LBL_VISIBILITY = "Visibility:";
var CREDIT_TEXT = "Eclipse Predictions by Fred Espenak, NASA/GSFC";  // texts/52

/* -----------------------------------------------------------------------------
   2. LAYOUT  (original Flash stage units; the canvas keeps these coordinates and
      is scaled by CSS. The grid shape is 600 x 450; the plotted dot coordinates
      above are in the grid's own coordinate space, y running -450 (top) .. 0.)
--------------------------------------------------------------------------------*/
var STAGE_W = 700, STAGE_H = 550;      // canvas backing coordinate system
var GRID_LEFT = 52, GRID_TOP = 30;     // top-left of the 600x450 grid on the stage
var GRID_W = 600, GRID_H = 450;
var GRID_RIGHT = GRID_LEFT + GRID_W;   // 652
var GRID_BOTTOM = GRID_TOP + GRID_H;   // 480

var DOT_SIZE = 15;    // dot art is 15x15 (shapes/3.svg, shapes/7.svg)
var GLOW_SIZE = 26;   // highlight art is 26x26 (shapes/1.svg, shapes/5.svg)

// data (x,y) -> stage pixel. x is already grid-local 0..600; y is -450..0.
function toStageX(dataX) { return GRID_LEFT + dataX; }
function toStageY(dataY) { return GRID_TOP + GRID_H + dataY; }

/* -----------------------------------------------------------------------------
   3. BUILD A UNIFIED, DATE-ORDERED LIST OF ECLIPSE OBJECTS
--------------------------------------------------------------------------------*/
function makeItem(kind, id, rec) {
  var typeName = (kind === "solar" ? SOLAR_TYPES : LUNAR_TYPES)[rec[2]];
  return {
    kind: kind,                 // "solar" | "lunar"
    id: id,                     // index within its own array (matches AS "s"+i / "l"+k)
    typeName: typeName,
    month: rec[3], day: rec[4], year: rec[5],
    saros: rec[6],
    duration: rec[8],
    visibility: rec[9],
    dataX: rec[0], dataY: rec[1],
    px: toStageX(rec[0]), py: toStageY(rec[1]),
    sortKey: rec[5] * 10000 + rec[3] * 100 + rec[4],   // year, month, day
    el: null                    // its overlay button (assigned later)
  };
}

var items = [];
(function buildItems() {
  var i;
  for (i = 0; i < solarEclipses.length; i++) items.push(makeItem("solar", i, solarEclipses[i]));
  for (i = 0; i < lunarEclipses.length; i++) items.push(makeItem("lunar", i, lunarEclipses[i]));
  items.sort(function (a, b) { return a.sortKey - b.sortKey; });
})();

/* -----------------------------------------------------------------------------
   4. TEXT / SPEECH HELPERS
--------------------------------------------------------------------------------*/
function titleFor(item) {
  // matches AS: "Solar Eclipse of " + months[m] + " " + day + ", " + year
  var lead = (item.kind === "solar" ? "Solar" : "Lunar") + " Eclipse of ";
  return lead + months[item.month] + " " + item.day + ", " + item.year;
}

// Expand a duration string into a spoken form with units (for aria).
// Solar look like "04m57s"; lunar like "03h24m (01h18m)"; "-" means none.
function durationSpeech(str) {
  if (!str || str === "-") return "no central duration listed";
  if (str === "Non-Central") return "non-central eclipse";
  var out = str
    .replace(/(\d+)h/g, function (_, n) { return " " + Number(n) + " hour" + (Number(n) === 1 ? "" : "s"); })
    .replace(/(\d+)m/g, function (_, n) { return " " + Number(n) + " minute" + (Number(n) === 1 ? "" : "s"); })
    .replace(/(\d+)s/g, function (_, n) { return " " + Number(n) + " second" + (Number(n) === 1 ? "" : "s"); });
  return out.replace(/\s+/g, " ").trim();
}

// Full, units-complete accessible name / announcement for one eclipse.
function speechFor(item) {
  var parts = [];
  parts.push((item.kind === "solar" ? "Solar" : "Lunar") + " eclipse");
  parts.push(item.typeName + " type");
  parts.push(months[item.month] + " " + item.day + ", " + item.year);
  parts.push("Saros series " + item.saros);
  parts.push("Duration " + durationSpeech(item.duration));
  parts.push("Visible from " + item.visibility);
  return parts.join(". ") + ".";
}

/* -----------------------------------------------------------------------------
   5. STATE  (single source of truth; render() redraws everything from it)
--------------------------------------------------------------------------------*/
var state = {
  active: null   // the eclipse item currently highlighted / shown, or null
};

/* -----------------------------------------------------------------------------
   6. DOM + CANVAS SETUP
--------------------------------------------------------------------------------*/
var canvas = document.getElementById("et-canvas");
var ctx = canvas.getContext("2d");
var overlay = document.getElementById("et-overlay");
var liveRegion = document.getElementById("et-live");
var tableBody = document.getElementById("et-table-body");

// Crisp rendering on high-DPI screens: scale the backing store, keep the drawing
// code in original stage units.
function setupCanvasResolution() {
  var dpr = window.devicePixelRatio || 1;
  canvas.width = Math.round(STAGE_W * dpr);
  canvas.height = Math.round(STAGE_H * dpr);
  ctx.setTransform(dpr, 0, 0, dpr, 0, 0);
}

/* --- asset images (exported vector shapes, reused as-is) --- */
var assets = { grid: null, dotSolar: null, dotLunar: null, glowSolar: null, glowLunar: null };
var assetsLoaded = 0, assetsTotal = 5;

function loadAsset(key, src) {
  var img = new Image();
  img.onload = function () {
    assets[key] = img;
    assetsLoaded++;
    if (assetsLoaded === assetsTotal) render();
  };
  img.onerror = function () {
    assetsLoaded++;                    // don't wedge if one asset is missing
    if (assetsLoaded === assetsTotal) render();
  };
  img.src = src;
}

/* -----------------------------------------------------------------------------
   7. RENDER  (canvas: grid background + all dots + glow for the active dot)
--------------------------------------------------------------------------------*/
function drawDot(item) {
  var img = (item.kind === "solar") ? assets.dotSolar : assets.dotLunar;
  if (img) {
    ctx.drawImage(img, item.px - DOT_SIZE / 2, item.py - DOT_SIZE / 2, DOT_SIZE, DOT_SIZE);
  } else {
    // Fallback if the SVG failed to load: draw an equivalent radial dot.
    var g = ctx.createRadialGradient(item.px, item.py, 1, item.px, item.py, DOT_SIZE / 2);
    if (item.kind === "solar") { g.addColorStop(0, "#ffe9c4"); g.addColorStop(1, "#feb316"); }
    else { g.addColorStop(0, "#dadada"); g.addColorStop(1, "#8a8a8a"); }
    ctx.fillStyle = g;
    ctx.beginPath(); ctx.arc(item.px, item.py, DOT_SIZE / 2, 0, Math.PI * 2); ctx.fill();
  }
}

function render() {
  ctx.clearRect(0, 0, STAGE_W, STAGE_H);

  // grid background (shapes/31.svg) at the grid origin
  if (assets.grid) {
    ctx.drawImage(assets.grid, GRID_LEFT, GRID_TOP, GRID_W, GRID_H);
  } else {
    ctx.fillStyle = "#ffffff";
    ctx.fillRect(GRID_LEFT, GRID_TOP, GRID_W, GRID_H);
  }

  // highlight glow beneath the active dot (matches original: highlight child shown)
  if (state.active) {
    var a = state.active;
    var glow = (a.kind === "solar") ? assets.glowSolar : assets.glowLunar;
    if (glow) ctx.drawImage(glow, a.px - GLOW_SIZE / 2, a.py - GLOW_SIZE / 2, GLOW_SIZE, GLOW_SIZE);
  }

  // all dots
  for (var i = 0; i < items.length; i++) drawDot(items[i]);

  // redraw the active dot on top of its glow so it stays crisp
  if (state.active) drawDot(state.active);
}

/* -----------------------------------------------------------------------------
   8. INFO PANEL  (HTML, not canvas -- accessible + zoomable). Positioned next to
      the dot using the SAME quadrant logic as the original AS displayEclipseInfo.
--------------------------------------------------------------------------------*/
var infoPanel = document.createElement("div");
infoPanel.className = "et-info";
infoPanel.setAttribute("aria-hidden", "true");   // duplicate of the focused control's name
infoPanel.hidden = true;
infoPanel.innerHTML =
  '<p class="et-info__title"></p>' +
  '<div class="et-info__grid">' +
    '<span class="et-info__label"></span><span class="et-info__type"></span>' +
    '<span class="et-info__label"></span><span class="et-info__saros"></span>' +
  '</div>' +
  '<p class="et-info__row"><span class="et-info__label"></span> <span class="et-info__duration"></span></p>' +
  '<p class="et-info__row"><span class="et-info__label"></span> <span class="et-info__vis"></span></p>';
overlay.appendChild(infoPanel);

var infoEls = {
  title: infoPanel.querySelector(".et-info__title"),
  labels: infoPanel.querySelectorAll(".et-info__label"),
  type: infoPanel.querySelector(".et-info__type"),
  saros: infoPanel.querySelector(".et-info__saros"),
  duration: infoPanel.querySelector(".et-info__duration"),
  vis: infoPanel.querySelector(".et-info__vis")
};
infoEls.labels[0].textContent = LBL_TYPE;
infoEls.labels[1].textContent = LBL_SAROS;
infoEls.labels[2].textContent = LBL_DURATION;
infoEls.labels[3].textContent = LBL_VISIBILITY;

function positionInfoPanel(item) {
  // Original thresholds: x < 300 (left half of the 600-wide grid), y < -225 (upper
  // half, y being negative). Panel is offset by `margin` and flipped to stay in view.
  var leftHalf = item.dataX < 300;
  var upperHalf = item.dataY < -225;

  // Anchor the panel at the dot centre (as a % of the stage) and use transforms to
  // grow it into the correct quadrant with a small gap -- this reproduces the
  // "x - width" / "y - height" placement without measuring the panel.
  infoPanel.style.left = (item.px / STAGE_W * 100) + "%";
  infoPanel.style.top = (item.py / STAGE_H * 100) + "%";

  var tx = leftHalf ? margin + "px" : "calc(-100% - " + margin + "px)";
  var ty = upperHalf ? margin + "px" : "calc(-100% - " + margin + "px)";
  infoPanel.style.transform = "translate(" + tx + ", " + ty + ")";
}

function fillInfoPanel(item) {
  infoPanel.classList.toggle("et-info--solar", item.kind === "solar");
  infoPanel.classList.toggle("et-info--lunar", item.kind === "lunar");
  infoEls.title.textContent = titleFor(item);
  infoEls.type.textContent = item.typeName;
  infoEls.saros.textContent = item.saros;
  infoEls.duration.textContent = item.duration;
  infoEls.vis.textContent = item.visibility;
}

/* -----------------------------------------------------------------------------
   9. SHOW / HIDE  (single entry points; keep canvas, panel and live region in sync)
--------------------------------------------------------------------------------*/
function showInfo(item, viaPointer) {
  state.active = item;
  fillInfoPanel(item);
  positionInfoPanel(item);
  infoPanel.hidden = false;
  render();
  // Announce only for pointer users (keyboard focus already voices the button's
  // accessible name, so we avoid a double read).
  if (viaPointer) liveRegion.textContent = speechFor(item);
}

function hideInfo(item) {
  // ignore stale hide from an element that is no longer the active one
  if (item && state.active && item !== state.active) return;
  state.active = null;
  infoPanel.hidden = true;
  render();
}

/* -----------------------------------------------------------------------------
   10. OVERLAY: axis labels, logo, credit, and one focusable button per eclipse
--------------------------------------------------------------------------------*/
function pctLeft(px) { return (px / STAGE_W * 100) + "%"; }
function pctTop(py) { return (py / STAGE_H * 100) + "%"; }

function buildAxisLabels() {
  // Year labels centred over the shaded bands: band centre dataX = (year-2000)*20 + 10
  var years = [2000, 2005, 2010, 2015, 2020, 2025];
  years.forEach(function (yr) {
    var lab = document.createElement("span");
    lab.className = "et-axis et-axis--year";
    lab.textContent = yr;
    lab.setAttribute("aria-hidden", "true");
    lab.style.left = pctLeft(toStageX((yr - 2000) * 20 + 10));
    lab.style.top = pctTop(GRID_TOP - 14);
    overlay.appendChild(lab);
  });

  // Month labels down the left axis, one per 1/12 band, vertically centred.
  var monthAbbr = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
  monthAbbr.forEach(function (m, idx) {
    var lab = document.createElement("span");
    lab.className = "et-axis et-axis--month";
    lab.textContent = m;
    lab.setAttribute("aria-hidden", "true");
    lab.style.left = pctLeft(GRID_LEFT - 12);
    lab.style.top = pctTop(GRID_TOP + (idx + 0.5) * (GRID_H / 12));
    overlay.appendChild(lab);
  });
}

function buildBranding() {
  var logo = document.createElement("img");
  logo.className = "et-logo";
  logo.src = "assets/classaction-logo.png";
  logo.alt = "ClassAction";
  logo.style.left = pctLeft(GRID_LEFT - 42);
  logo.style.top = pctTop(GRID_BOTTOM + 6);
  overlay.appendChild(logo);

  var credit = document.createElement("span");
  credit.className = "et-credit";
  credit.textContent = CREDIT_TEXT;
  credit.style.left = pctLeft(GRID_RIGHT);
  credit.style.top = pctTop(GRID_BOTTOM + 20);
  overlay.appendChild(credit);
}

function buildEclipseButtons() {
  items.forEach(function (item) {
    var btn = document.createElement("button");
    btn.type = "button";
    btn.className = "et-point et-point--" + item.kind;
    btn.style.left = pctLeft(item.px);
    btn.style.top = pctTop(item.py);
    btn.setAttribute("aria-label", speechFor(item));

    // Focus (keyboard) shows + highlights; blur hides.
    btn.addEventListener("focus", function () { showInfo(item, false); });
    btn.addEventListener("blur", function () { hideInfo(item); });

    // Pointer / touch: hover shows (mouse), tap focuses so the panel stays.
    btn.addEventListener("pointerenter", function () { showInfo(item, true); });
    btn.addEventListener("pointerleave", function () {
      // keep it shown if this control has keyboard focus
      if (document.activeElement !== btn) hideInfo(item);
    });
    btn.addEventListener("pointerdown", function () { btn.focus(); });

    item.el = btn;
    overlay.appendChild(btn);
  });
}

/* -----------------------------------------------------------------------------
   11. DATA TABLE  (comprehensive, screen-reader friendly; no extra tab stops)
--------------------------------------------------------------------------------*/
function buildTable() {
  var frag = document.createDocumentFragment();
  items.forEach(function (item) {
    var tr = document.createElement("tr");
    tr.className = "et-trow et-trow--" + item.kind;

    function td(text, cls) {
      var c = document.createElement("td");
      c.textContent = text;
      if (cls) c.className = cls;
      return c;
    }
    tr.appendChild(td(months[item.month] + " " + item.day + ", " + item.year));
    tr.appendChild(td(item.kind === "solar" ? "Solar" : "Lunar"));
    tr.appendChild(td(item.typeName));
    tr.appendChild(td(String(item.saros), "et-num"));
    tr.appendChild(td(item.duration === "-" ? "—" : item.duration));
    tr.appendChild(td(item.visibility));

    // Pointing at a row highlights the matching dot on the plot (mouse nicety).
    tr.addEventListener("pointerenter", function () { showInfo(item, false); });
    tr.addEventListener("pointerleave", function () { hideInfo(item); });

    frag.appendChild(tr);
  });
  tableBody.appendChild(frag);
}

/* -----------------------------------------------------------------------------
   12. COUNTS in the description paragraph
--------------------------------------------------------------------------------*/
function fillCounts() {
  var s = document.getElementById("et-solar-count");
  var l = document.getElementById("et-lunar-count");
  var t = document.getElementById("et-total-count");
  if (s) s.textContent = solarEclipses.length;
  if (l) l.textContent = lunarEclipses.length;
  if (t) t.textContent = items.length;
}

/* -----------------------------------------------------------------------------
   13. RESET  (wired to the masthead's "sim-reset" event) -> initial state
--------------------------------------------------------------------------------*/
document.addEventListener("sim-reset", function () {
  // Initial state = nothing selected, no panel shown, keyboard focus released.
  if (state.active && state.active.el && document.activeElement === state.active.el) {
    state.active.el.blur();
  }
  hideInfo();
  // return the reading position to the top of the plot
  var heading = document.getElementById("et-chart-heading");
  if (heading) { heading.setAttribute("tabindex", "-1"); heading.focus(); }
});

/* -----------------------------------------------------------------------------
   14. Redefine the foundation equation initialiser. This sim contains no
       mathematical notation (only calendar dates and catalogue numbers), so there
       is nothing for MathJax to typeset; this just satisfies the pipeline hook.
--------------------------------------------------------------------------------*/
window.klunlInitEqn = function () { /* no equations in the Eclipse Table */ };

/* -----------------------------------------------------------------------------
   15. INIT
--------------------------------------------------------------------------------*/
function init() {
  setupCanvasResolution();
  fillCounts();
  buildAxisLabels();
  buildBranding();
  buildEclipseButtons();
  buildTable();

  loadAsset("grid", "assets/grid.svg");
  loadAsset("dotSolar", "assets/dot-solar.svg");
  loadAsset("dotLunar", "assets/dot-lunar.svg");
  loadAsset("glowSolar", "assets/glow-solar.svg");
  loadAsset("glowLunar", "assets/glow-lunar.svg");

  render();  // draw immediately (fallbacks) then again as assets arrive

  // Keep the backing resolution correct if the device pixel ratio changes
  // (e.g. moving the window between monitors / browser zoom).
  window.addEventListener("resize", function () {
    setupCanvasResolution();
    render();
  });
}

if (document.readyState === "loading") {
  document.addEventListener("DOMContentLoaded", init);
} else {
  init();
}
