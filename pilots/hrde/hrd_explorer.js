// Hertzsprung-Russell Diagram Exploration Tool for GEAS Laboratory Exercise #6
// Nicole P. Vogt
// August 11, 2017
// Major Updates: 2026-05-24 (WCAG AA accessibility)

// Credit: This is an HTML5+Canvs translation of the classic NAAP H-R Diagram Explorer
// (which was only available in Flash format)

//////////////////////////////////////////////////////////////////////////////
// Initialize
//////////////////////////////////////////////////////////////////////////////


// Set true after initial figure setup (suppresses live region on first load)
var figureInitialized = false;

// Canvases for GUI and spectra
var hrdc_ct     = document.getElementById('hrdc'    ).getContext('2d'),
    sizecmpc_ct = document.getElementById('sizecmpc').getContext('2d');
  //tslider_ct  = document.getElementById('tslider' ).getContext('2d'),
  //lslider_ct  = document.getElementById('lslider' ).getContext('2d'),
  //reqn_ct     = document.getElementById('reqn'    ).getContext('2d'),
  //screenc_ct  = document.getElementById('screenc' ).getContext('2d');

  // Print variable "x" on the screen (for debugging)
  // string01 = x.toString();
  // context.fillText  (string01, 100, 100);

// Define values for key text strings and sample data sets
function initFigure()  {

  // Identify platform
  navPlat  = navigator.platform;
  if ((navPlat == 'iPad') || (navPlat == 'iPhone') || (navPlat == 'Android'))  {
    mobile = true;
  } else  {
    mobile = false;
  }
  
  /*
  // Set up help screens
  helpText   = "Help: Q "; 
  helpText  += "This tool introduces the Hertzsprung-Russell (H-R) Diagram, a plot showing the "; 
  helpText  += "relationship between luminosity and temperature for stars. Q "; 
  helpText  += "The H-R Diagram is shown in the upper-right panel. The cursor (the red "; 
  helpText  += "\'X\' symbol) represents a star with the temperature and luminosity shown in the Cursor "; 
  helpText  += "Properties panel (lower-left). The cursor's location can be changed by ";
  if (mobile)  {
    helpText  += "tapping on the figure, by dragging the cursor around";
  } else  {
    helpText  += "clicking on the figure, by dragging the cursor around (with the shift key ";
    helpText  += "depressed), by using the arrow keys";
  }
  helpText  += ", or by adjusting the cursor slider or stepper controls. The Size Comparison panel "; 
  helpText  += "(upper-left) shows what a star at the cursor's location would look like next to the Sun. Q "; 
  helpText  += "One can mark features on the H-R Diagram like the Main Sequence (where young, "; 
  helpText  += "unevolved stars are found), isoradius lines (lines along which all stars have "; 
  helpText  += "the same radius), luminosity classes, and the Instability Strip (where "; 
  helpText  += "pulsating stars are found). The X axis can be labeled with either the intrinsic "; 
  helpText  += "property of temperature or the observable properties of color or type, and the "; 
  helpText  += "Y axis can be labeled with either luminosity or absolute magnitude. Q "; 
  helpText  += "One can also show the nearest and brightest stars on the H-R Diagram. "; 
  helpText  += "The are 140 bright stars (selected from the Bright Star Catalog), 98 nearby  "; 
  helpText  += "stars (assembled by the Research Consortium on Nearby Stars), and 5 stars "; 
  helpText  += "which belong to both groups. "; 

  aboutText  = "About: Q ";
  aboutText += "This web application was created by Nicole Vogt, \u00A9 2017, and is based ";
  aboutText += "on part of the Hertzsprung-Russell Diagram Module of the Nebraska Astronomy ";
  aboutText += "Applet Project. Our goal is to allow continued usage of their excellent ";
  aboutText += "tool as Adobe Flash becomes less and less available. Q ";
  aboutText += "You can explore their astronomy education resources at http://astro.unl.edu. ";
//aboutText += " ";
  */
  
//screenc.style.display = 'none';
  mbox_frame.style.top  =  '20%';
  showText(0);

    
  // Set up range of temperature and luminosity values for H-R Diagram
  tMin          =          2300;       // Kelvin
  tSun          =          5800;       // use rather than 5780 to match lab manual
  tMax          =         40000;
  lMin          =             0.0001;  // Solar
  lMax          =       1000000;

  tKelvin.value =          tSun;
  lSolar.value  =             1;

  // Set up range of x and y values for H-R Diagram plotting box
  del  =                     20;
  xMin =                  4*del;
  xMax = hrdc.width   -     del;
  yMin = hrdc.height  - 2.5*del;
  yMax =                    del;

  // Set up range of x and y values for luminosity slider
  xmrg  =                    10;
  xMinL =                  xmrg;
  xMaxL = lslider.width  - xmrg;
  yMinL = lslider.height;
  yMaxL =                     0;

  // Set up range of x and y values for temperature slider
  xMinT =                 xMinL;
  xMaxT =                 xMaxL;
  yMinT =                 yMinL;
  yMaxT =                 yMaxL;

  // Define files holding temperatures and luminosities for stellar data sets
  nearFile = 'near_tl.txt';
  brgtFile = 'brgt_tl.txt';
  olapFile = 'olap_tl.txt';

  // Location of stellar data (locally, during development phase, or on server)
  // First path is for local disk, and second is for server
  if (window.location.protocol == 'file:')  {
    xhttpStatus =    0;
  } else  {
    xhttpStatus =  200;
  }
  xhttpStatusISE = 500;            // Internal Server Error (SDSS API can throw these)
  starPath = 'catalog/';

  // Update temperature and luminosity as mouse or touch moves across H-R Diagram if shift key is depressed
  allowTrack = false;


  // Set up size comparison panel
  sizecmpc_ct.font         = '14px Helvetica';
  sizecmpc_ct.fillStyle    = '#ffffff';

  // Draw black box to hold Sun and star
  sizecmpc_ct.fillStyle    = '#000000';
  sizecmpc_ct.fillRect(0, 0, 360, 380);

  // Draw Sun
  sizecmpc_ct.fillStyle    = '#ffffff';
  sizecmpc_ct.beginPath();
  sizecmpc_ct.arc(270, 190, 80, 0, 2*Math.PI)
  sizecmpc_ct.fill();
  sizecmpc_ct.globalAlpha  = 0.5;
  sizecmpc_ct.fillStyle    = colorTemp(tSun);
  sizecmpc_ct.beginPath();
  sizecmpc_ct.arc(270, 190, 80, 0, 2*Math.PI)
  sizecmpc_ct.fill();
  sizecmpc_ct.globalAlpha = 1;

  // Label Sun
  sizecmpc_ct.fillStyle    = '#ffffff';
  sizecmpc_ct.textAlign    = 'end';
  sizecmpc_ct.textBaseline = 'bottom';
  sizecmpc_ct.fillText("Sun", 350, 370);

  newStar(0);
  figureInitialized = true;

}

// Update H-R Diagram and star size figure
function newStar(mode)  {

  // Key events only fire on canvas if it holds focus
  hrdc.focus();
    
  // Reset plot to initial setup
  if (mode == 0)  {
    tKelvin.value = tSun;
    lSolar.value  =    1;
    lSolarX       =    1;

    /*
    screenc.style.display = 'none';
    screenb.style.display = 'none';
    */

    xlabel.value = 0;
    ylabel.value = 0;
     
    irad.checked = true;
    lcls.checked = false;
    istr.checked = false;
    mase.checked = true;

    (document.getElementById("none").checked) = true;
    (document.getElementById("near").checked) = false;
    (document.getElementById("brgt").checked) = false;
    (document.getElementById("both").checked) = false;
    (document.getElementById("olap").checked) = false;

    mousedown = null;
    mousemove = null;
  }

  // Display temperature to nearest ten's place (xx,xx0)
  tKelvin.value = Math.max(tMin, tKelvin.value);
  tKelvin.value = Math.min(tMax, tKelvin.value);
  tKelvin.value = 10*Math.round(0.1*tKelvin.value);

  // Vary step size with order of magnitude of luminosity when stepper used
  // (correct when stepping up for power of ten boundary cases: for up double; for down, decrement)
  if ( ( Math.abs( parseFloat(lSolar.value) - parseFloat(lSolarX) ) - parseFloat(lSolar.step) < 1e-9 ) && 
       ( Number.isInteger( Math.log10( parseFloat(lSolarX) ) ) ) && 
       ( parseFloat(lSolar.value) > parseFloat(lSolarX) ) ) {
    lSolar.value = 2 * parseFloat(lSolarX);
  }
  lSolarX = lSolar.value;

  // Display luminosity to nearest ten's place above 1000, (1,000       to 1,000,000), 
  // show three significant digits at intermediate values, (    0.00100 to     1,000),
  // show two   significant digits at lowest       values  (    0.00010 to         0.00100)
  lSolar.value  = Math.max(lMin, lSolar.value);
  lSolar.value  = Math.min(lMax, lSolar.value);
  var r0 = Number(lSolar.value);
  if (r0 >= 1000)  {
    lSolar.value = 10*Math.round(0.1*lSolar.value);
  } else if (r0 >= 0.01)  {
    lSolar.value = r0.toPrecision(3);
  } else  {
    lSolar.value = r0.toFixed(5);
  }
  lSolar.value = Number(lSolar.value);  // removes trailing zeroes on string formated values

  // Set step size for luminosity (vary with order of magnitude of luminosity), 
  // as luminosity axis is logarithmic
  lSolar.step = Math.pow( 10, Math.floor( Math.log10( r0 ) - 1e-9 ) );

  // Update temperature and luminosity sliders
  //tslide();
  //lslide();

  // Update new temperature and luminosity sliders
  tslider();
  lslider();

  // Update radius equation
  requation();

  // Update star size   for new temperature or luminosity
  showSize();

  // Update H-R Diagram for new temperature or luminosity
  fillPlot();

  if (figureInitialized && mode !== 0)  {
    announceStarProperties();
  }

}


//////////////////////////////////////////////////////////////////////////////
// Draw primary screen components (H-R diagram, size and cursor panels)
//////////////////////////////////////////////////////////////////////////////


// Draw H-R Diagram
function fillPlot()  {

  var tK = tKelvin.value;
  var lS = lSolar.value;
    
  var s0, s1, s2;
  var r0, r1;
  var x1, x2, x3, x4, x5;
  var y1, y2, dy;
  var x, y, z;
  var del, del2, del3, del4;
  var scale01, scale02;
  var color;
  var t;
    
  var coords = [ tK, 1 ];  // Holds either temperature and luminosity or x and y

  var tOn = 2000;          // Minimum time before dotted lines are removed from between cursor and axes

  // Define astronomical values
  var lum, lumSun = 4.83;  // Solar luminosity (in magnitudes)
  var pos1 = [ 20000, 12000, 10000, 9200, 8500, 7800, 7100, 6500, 6060, 5720, 5380, 5040 ];  // NAAP app scale, w/5 better spaced 
  var pos2 = [  4800,  4550,  4350, 4150, 3950, 3750, 3550, 3300, 3100, 2950, 2800, 2600 ];  // intervals between labeled T points
  var posC = pos1.concat(pos2);                               // B-V Color Index tickmark temperatures (-0.2 to 2.1)
  var typ  = [ 'O',   'B',   'A',  'F',  'G',  'K',  'M'  ];  // Stellar Type labels
  var posN = [ 39000, 17000, 8600, 6500, 5500, 4500, 3100 ];  // Stellar Type label temperatures
  var posT = [ 29000, 10000, 7000, 6000, 5100, 3900,    0 ];  // Stellar Type label separation temperatures

  // Define shape of Instability Strip
  // Start at begining of upper-right corner and extend to begining of lower-left corner (T increases throughout top half)
  //      Upper-right corner         Upper-left corner        (Lower-left corner)
  isT1 = [ 5000, 5040, 5100, 5300, 5700, 6100,  6900, 7200, 7400,  7900,  8400 ];
  isL1 = [ 1000, 1240, 1450, 1700, 1770, 1770,  1700, 1400, 1000,   200,    33 ];
  // 
  // Start at begining of lower-left corner and extend to begining of upper-right corner (T decreases throughout bottom half)
  //      Lower-left corner                  Lower-right corner       (Upper-right corner)
  isT2 = [ 8400, 8370, 8300, 8100,  7700, 7200,  6700,  6200, 5900, 5700,  5350,  5000 ];
  isL2 = [   33,   28,   23,   20,    19,   19,    19,    20,   23,   33,   160,  1000 ];

  // Define shape of White Dwarf region
  wdT1 = [ 5400, 5410, 5420, 5500, 5600, 5700, 5900, 6300, 6900, 8200, 10000, 13000, 16000, 19000, 21000, 23000, 24000, 24500, 25000 ];
  wdL1 = [ 0.00015, 0.00020, 0.00022, 0.00027, 0.00031, 0.00034, 0.00038, 0.00047, 0.00064, 0.0011, 0.0020, 0.0046, 0.0094, 0.016, 0.021, 0.026, 0.024, 0.022, 0.019 ];
  wdT2 = [ 25000, 24960, 24830, 24500, 24300, 23700, 23000, 20000, 17000, 14000, 12000, 10000, 8900, 7900, 7100, 6400, 5800, 5600, 5400 ];
  wdL2 = [ 0.019, 0.015, 0.012, 0.010, 0.0094, 0.0082, 0.0074, 0.0048, 0.0030, 0.0017, 0.00105, 0.00060, 0.00041, 0.00028, 0.00020, 0.00015, 0.000125, 0.00013, 0.00015 ];
      
  // Define shape of Red Giant region
  rgT1 = [ 2700, 2703, 2720,  2745,  2800,  2900,  3000,  3300,  3500, 3900, 4300, 5000, 6000, 6200, 6500, 6750, 6800 ];
  rgL1 = [ 3000, 3500, 4800,  5700,  6950,  8900, 11000, 13000, 12000, 8000, 4800, 1620,  250,  175,   99,   50,   40 ];
  rgT2 = [ 6800, 6700,  6450,  6100, 5500, 4900, 4400, 4200, 3900, 3300, 3000, 2800, 2700 ];
  rgL2 = [   40,   26,    17,    13,   11,   13,   17,   21,   36,  170,  500, 1500, 3000 ];

  // Define shape of Blue Giant region
  bgT1 = [  3310,   3350,   3400,   3700,   4000,   5000,   5500,   7200,  12000,  19000,  24000,  29000,  31000,  32500 ];
  bgL1 = [ 26000,  55000,  75000, 140000, 190000, 320000, 380000, 580000, 760000, 790000, 680000, 520000, 390000, 260000 ];
  bgT2 = [ 32500,  32000,  31000,  27000,  22000,  14000,   9400,   6300,   4400,   3310 ];
  bgL2 = [260000, 150000, 100000,  40000,  18000,   9000,   6300,   6000,  10000,  26000 ];

  // Define shape of Main Sequence region
  msT1 = [ 2300,      2700,      3700,    5000,   5800,   7900, 12000, 20000, 29000,  35000,  40000 ];
  msL1 = [    0.0014,    0.0054,    0.20,    2.7,    7.2,   42,   290,  5300, 50000, 170000, 380000 ];
  msT2 = [ 40000, 16000, 11000, 8400,   7200,   6000,   4900,    4300,     3300,      2900,      2600,       2300       ];
  msL2 = [ 88000,   240,    34,    9.1,    3.6,    1,      0.17,    0.052,    0.0027,    0.0010,    0.00043,    0.00021 ];

  // Define shape of Main Sequence proper
  msT3 = [  40000, 33000, 24000, 12000,  9000, 7300,   6100,  5500,   4900,    4200,    3800,     3600,     3200,     2900,      2600,       2300       ];
  msL3 = [ 120000, 30000,  4200,    87,    16,    5.5,    1.4,   0.60,   0.30,     0.11,   0.038,    0.017,    0.0025,   0.00098,   0.00049,    0.00025 ];

    
  // Set up H-R Diagram box
  del = 20, del2 = 8, del3 = 4;
  hrdc_ct.fillStyle   = '#000000';
  hrdc_ct.strokeStyle = hrdc_ct.fillStyle;
  hrdc_ct.clearRect(0, 0, hrdc.width, hrdc.height);
  hrdc_ct.beginPath();
  hrdc_ct.moveTo(xMin, yMax);
  hrdc_ct.lineTo(xMin, yMin);
  hrdc_ct.lineTo(xMax, yMin);
  hrdc_ct.lineTo(xMax, yMax);
  hrdc_ct.lineTo(xMin, yMax);
  hrdc_ct.stroke();

  // X-axis is log(T); label x-axis
  if (xlabel.value == 0)  {
    s0 = "Temperature (K)";
  } else if (xlabel.value == 1)  {
    s0 = "B-V Color Index";
  } else if (xlabel.value == 2)  {
    s0 = "Spectral Type";
  }
  hrdc_ct.font         = '16px Helvetica';
  hrdc_ct.textAlign    = 'center';
  hrdc_ct.textBaseline = 'bottom';
  hrdc_ct.fillText(s0, (xMin+xMax)/2, hrdc.height);  // center within plot box (without y-axis label or margin)

  // Add tickmarks and values to x-axis
  hrdc_ct.font         = '16px Helvetica';
  hrdc_ct.textAlign    = 'center';
  hrdc_ct.textBaseline = 'middle';
  x2      = hrdc.width - del;
  y2      = yMin + del2;
  y3      = yMin + del3;
  y4      = yMin + del;
  scale01 = Math.log(tMax)/Math.LN10;
  scale02 = Math.log(tMin)/Math.LN10;
  // Temperature (logarithmic distribution, marks at major values and end-points)
  if (xlabel.value == 0)  {
    for (i = tMax; i >= tMin; i /= 2)  {
      j = Math.log(i)/Math.LN10;
      x = xMax - (xMax - xMin) / ( scale01 - scale02 ) * ( j - scale02 );
      hrdc_ct.beginPath();
      hrdc_ct.moveTo(x, yMin);
      hrdc_ct.lineTo(x, yMin + del2);
      hrdc_ct.stroke();
      hrdc_ct.fillText (i, x, y4);
    }
  // B-V Color Index
  } else if (xlabel.value == 1)  {
    for (i = 0; i <= posC.length-1; i++)  {
      j  = -0.2 + 0.1*i;
      k  = Math.log(posC[i])/Math.LN10;
      x  = xMax - (xMax - xMin) / ( scale01 - scale02 ) * ( k - scale02 );
      hrdc_ct.beginPath();
      hrdc_ct.moveTo(x, yMin);
      // Add long mark every half-integer increment in color
      if ( (i == 2) || (i == 7) || (i == 12) || (i == 17) || (i == 22) || (i == 27) )  {
        hrdc_ct.lineTo(x, yMin + del2);
      // Add short mark every tenth-integer increment in color
      } else  {
        hrdc_ct.lineTo(x, yMin + del3);
      }
      hrdc_ct.stroke();
      // Add label every half-integer increment in color, and every tenth increment below zero
      if ( (i == 0) || (i == 1) || (i == 2) || (i == 7) || (i == 12) || (i == 22) )  {
        hrdc_ct.fillText (j.toPrecision(1), x, yMin + del);
      } else if (i == 17)  {
        hrdc_ct.fillText (j.toPrecision(2), x, yMin + del);
      }
    }
  // Spectral Type
  } else if (xlabel.value == 2)  {
    for (i = 0; i <= posN.length-1; i++)  {
      j = Math.log(posT[i])/Math.LN10;
      x = xMax - (xMax - xMin) / ( scale01 - scale02 ) * ( j - scale02 );
      // Add long mark between each pair of stellar type labels
      hrdc_ct.beginPath();
      hrdc_ct.moveTo(x, yMin);
      hrdc_ct.lineTo(x, yMin + del2);
      hrdc_ct.stroke();
      // Add stellar type labels
      j = Math.log(posN[i])/Math.LN10;
      x = xMax - (xMax - xMin) / ( scale01 - scale02 ) * ( j - scale02 );
      hrdc_ct.fillText (typ[i], x, yMin + del);
    }
  }

  // Y-axis is log(L); label y-axis
  if (ylabel.value == 0)  {
    s0 = "Luminosity (L";
    s1 = "\u2609";  // use solar symbol within luminosity unit
    s2 = ")";
  } else if (ylabel.value == 1)  {
    s0 = "Absolute Magnitude (M)";
  }
  hrdc_ct.save();
  hrdc_ct.translate(del, (yMin+yMax)/2);
  hrdc_ct.rotate(-Math.PI/2);
  hrdc_ct.fillText (s0, 0, 0);
  if (ylabel.value == 0)  {
    r0 = hrdc_ct.measureText(s0).width;
    hrdc_ct.translate(r0/2, 0);
    hrdc_ct.font         = '11px Helvetica';
    hrdc_ct.textAlign    = 'start';
    hrdc_ct.textBaseline = 'hanging';
    hrdc_ct.fillText (s1, 0, 0);
    r1 = hrdc_ct.measureText(s1).width;
    hrdc_ct.translate(r1, 0);
    hrdc_ct.font         = '16px Helvetica';
    hrdc_ct.textBaseline = 'middle';
    hrdc_ct.fillText (s2, 0, 0);
  }
  hrdc_ct.restore();

  // Add logarithmic (luminosity) or linear (magnitude) tickmarks and values to y-axis
  hrdc_ct.font = '16px Helvetica';
  dy = (yMin - yMax)/10;
  // Luminosity (logarithmic marks from 1e-4 to 1e6)
  if (ylabel.value == 0)  {
    hrdc_ct.textAlign = 'start';
    s0 = 10;
    r0 = hrdc_ct.measureText(s0).width;
    for (y = yMin; y >= yMax; y -= dy)  {
      // Add long mark every power of 10
      hrdc_ct.beginPath();
      hrdc_ct.moveTo(xMin,        y);
      hrdc_ct.lineTo(xMin - del2, y);
      hrdc_ct.stroke();
      // Add short marks from +0.1 to +0.9 for every power of 10
      for (i = 1; i <= 9; i++)  {
        z = y + dy * ( Math.pow(10, i/10) - 1 ) / 10;
        if (yMax <= z && z <= yMin)  {       
          hrdc_ct.beginPath();
          hrdc_ct.moveTo(xMin,        z);
          hrdc_ct.lineTo(xMin - del3, z);
          hrdc_ct.stroke();
        }
      }
      // Add label (10 raised to power, from -4 to 6)
      hrdc_ct.font         = '16px Helvetica';
      hrdc_ct.textBaseline = 'middle';
      hrdc_ct.fillText (s0, 2*del,    y);
      s1 = ( (yMin - y) / dy ) + Math.log(lMin)/Math.LN10;
      hrdc_ct.font         = '11px Helvetica';
      hrdc_ct.textBaseline = 'bottom';
      hrdc_ct.fillText (s1.toFixed(0), 2*del+r0, y);
    }
  // Magnitude (linear marks from roughly 15 to -10)
  } else if (ylabel.value == 1)  {
    hrdc_ct.textAlign = 'end';
    for (i = 15; i >= -11; i -= 0.5)  {
      lum = (lumSun - i) / 2.5;  // log10 of luminosity; runs from roughly -4 to 6
      y   = yMin + (yMax-yMin) * (lum + 4) / 10;
      if (yMax <= y && y <= yMin)  {
        hrdc_ct.beginPath();
        hrdc_ct.moveTo(xMin, y);
        // Add long mark every integer increment in magnitude
        if (i % 1 == 0)  {
          hrdc_ct.lineTo(xMin - del2, y);
        // Add short mark every half-integer increment in magnitude
        } else  {
          hrdc_ct.lineTo(xMin - del3, y);
        }
        hrdc_ct.stroke();
        // Add label every two-integer increment in magnitude
        if (i % 2 == 0)  {
          hrdc_ct.fillText (i, 3*del, y);
        }
      }
    }
  }

  // Label requested regions
  //  - Isoradius lines
  if (irad.checked)  {
    hrdc_ct.fillStyle   = '#52be80';
    hrdc_ct.fillStyle   = '#527d80';
    hrdc_ct.fillStyle   = '#005a9c';  // blue
    hrdc_ct.strokeStyle = hrdc_ct.fillStyle;
    hrdc_ct.textAlign   = 'start';

    // Isoradius lines cover from 0.001 to 1000 solar radii
    for (i = -3; i <= 3; i++)  {
      r      = Math.pow(10, i);
      l1     = (r*r) * Math.pow( (tMax/tSun), 4 );
      l1     = Math.min( l1, lMax );
      l1     = Math.max( l1, lMin );
      t1     = tSun * Math.pow( l1 / ( r*r), 0.25 );
      coords = convert (t1, l1, 1);
      x1     = coords[0];
      y1     = coords[1];
      l2     = (r*r) * Math.pow( (tMin/tSun), 4 );
      l2     = Math.min( l2, lMax );
      l2     = Math.max( l2, lMin );
      t2     = tSun * Math.pow( l2 / ( r*r), 0.25 );
      coords = convert (t2, l2, 1);
      x2     = coords[0];
      y2     = coords[1];
      hrdc_ct.beginPath();
      hrdc_ct.moveTo(x1, y1);
      hrdc_ct.lineTo(x2, y2);
      hrdc_ct.stroke();

      // Label Isoradius lines
      hrdc_ct.font = '14px Helvetica';
      j  = Math.min(i, 0); 
      s0 = r.toFixed(Math.abs(j)) + " R";
      s1 = "\u2609";  // solar symbol
      r0 = hrdc_ct.measureText(s0).width;
      hrdc_ct.clearRect(x1+del/2, y1+del/3, 4*del, del)
    //hrdc_ct.fillRect (x1+del/2, y1+del/3, 4*del, del)
      hrdc_ct.fillText (s0, x1+del, y1+del);
      hrdc_ct.font = '10px Helvetica';
      hrdc_ct.fillText (s1, x1+del+r0, y1+del+del3);
    }
  }
      
  //  - Luminosity classes
  if (lcls.checked)  {
    //  - White Dwarfs
    color                = '#b6b6b4';
    // Define region with cubic splines fit to series of points
  //smoothFit(wdT1, wdL1,  0.5, color, false);
  //smoothFit(wdT2, wdL2,  0,   color, false);
    // Define region with ellipse
    coords = convert (24800, 0.0174, 1);
    drawEllipse( 0.992, 1.7, coords[0], coords[1], -23, color );  // eccentricity, focal parameter, focal point x and y, rotation
    hrdc_ct.textAlign    = 'center';
    hrdc_ct.textBaseline = 'middle';
    hrdc_ct.font         = '12px Helvetica';
    hrdc_ct.fillStyle    = '#736f6e';
    hrdc_ct.save();
  //hrdc_ct.translate(300, 430);
  //hrdc_ct.rotate(Math.PI/8);
    coords = convert (10570, 0.012, 1);
    hrdc_ct.fillText ('White Dwarfs', coords[0], coords[1]);
    hrdc_ct.restore();

    //  - Red Giants
    color             = '#ffe5b4';
  //smoothFit(rgT1, rgL1,  1, color, false);
  //smoothFit(rgT2, rgL2,  0, color, false);
    coords = convert (6000, 25, 1);
    drawEllipse( 0.85, 25, coords[0], coords[1], 48, color );  // e, p, x0, y0, t0
    hrdc_ct.fillStyle = '#c04000';
    coords = convert (3900, 370, 1);
    hrdc_ct.fillText ('Giants (III)', coords[0], coords[1]);
    hrdc_ct.fillStyle = '#000000';
    coords = convert (3580, 2820, 1);
    hrdc_ct.fillText ('red giants',   coords[0], coords[1]);

    //  - Blue Giants
    color             = '#82cafa';
  //smoothFit(bgT1, bgL1,  1, color, false);
  //smoothFit(bgT2, bgL2, -1, color, false);
    coords = convert (31000, 187000, 1);
    drawEllipse( 0.965, 10, coords[0], coords[1], -5, color);  // e, p, x0, y0, t0
    hrdc_ct.fillStyle = '#2b65e6';
    coords = convert (10770, 25810, 1);
    hrdc_ct.fillText ('Supergiants (I)', coords[0], coords[1]);
    hrdc_ct.fillStyle = '#000000';
    coords = convert (20000, 179850, 1);
    hrdc_ct.fillText ('blue giants',     coords[0], coords[1]);

    //  - Main Sequence region
    color             = '#64e986';
    smoothFit2(msT1, msL1,  msT2, msL2, color, false);
    hrdc_ct.fillStyle = '#3ea055';
    coords = convert (20750, 2820, 1);
    hrdc_ct.fillText ('Dwarfs (V)', coords[0], coords[1]);
    hrdc_ct.fillStyle = '#000000';
    coords = convert (3330, 0.0144, 1);
    hrdc_ct.fillText ('red dwarfs', coords[0], coords[1]);
}

  //  - Instability Strip
  if (istr.checked)  {
    color                = '#ff2400';
    hrdc_ct.textAlign    = 'center';
    hrdc_ct.textBaseline = 'middle';
    hrdc_ct.font         = '12px Helvetica';
    hrdc_ct.fillStyle    = color;
    coords = convert (7190, 3540, 1);
    hrdc_ct.fillText ('Instability Strip', coords[0], coords[1]);
    smoothFit(isT1, isL1,  1, color, false);
    smoothFit(isT2, isL2, -1, color, false);
  }

  //  - Main Sequence
  if (mase.checked)  {
    //  - Main Sequence proper
    // Invert order of tempearture and luminosity marks
    // and fit combined set up and down Main Sequence
    list = [], msT4 = [], msL4 = [];
    for (i in msT3)
      list.push( {'T': msT3[i], 'L': msL3[i]} );
    list.sort(function(a, b)  {
      return ( (a.T < b.T) ? -1 : ( (a.T == b.T) ? 0 : 1) );
    });
    for (i = 0; i < list.length; i++)  {
      msT4[i] = list[i].T;
      msL4[i] = list[i].L;
    }
    // Add background for contrast at intersection with isoradius line (for R = 1)
    // (not needed as contrast level of 3 or more is acceptable for crossing lines)
    /*
    coords = convert (tSun, 1, 1);
    hrdc_ct.fillStyle = '#cc6600';
    hrdc_ct.beginPath();
    hrdc_ct.arc(coords[0], coords[1], 10, 0, 2 * Math.PI); 
    hrdc_ct.fill();
    */
    color = '#cc6600';  // brown
    color = '#9fb700';  // appple green
    hrdc_ct.lineWidth = 3;
    smoothFit2(msT3, msL3, msT4, msL4, color, false);
    hrdc_ct.lineWidth = 1;
  }

  // Plot nearest stars (solid green circles)
  if ((document.getElementById("near").checked) || ((document.getElementById("both").checked)))  {
    if (typeof nearStarsTL === 'undefined' || nearStarsTL === null)  {
      s0 = starPath.concat(nearFile);
      nearStarsTL = [ [], [], 0 ];
      nearStarsTL = readCatalog(s0);
    } else if (nearStarsTL[2] != 0)  {
      string01 = "Warning: Unable to display sample of nearest stars.";
      mbox_text.innerHTML      = string01;
      mbox_frame.style.display = 'inline';  
      document.getElementById("none").checked = true;
    }
    starPoints(nearStarsTL, '#3ea055', 2, 1);
  }
  // Plot brightest stars (open blue squares)
  if ((document.getElementById("brgt").checked) || ((document.getElementById("both").checked)))  {
    if (typeof brgtStarsTL === 'undefined' || brgtStarsTL === null)  {
      s0 = starPath.concat(brgtFile);
      brgtStarsTL = [ [], [], 0 ];
      brgtStarsTL = readCatalog(s0);
    } else if (brgtStarsTL[2] != 0)  {
      string01 = "Warning: Unable to display sample of brightest stars.";
      mbox_text.innerHTML      = string01;
      mbox_frame.style.display = 'inline';  
      document.getElementById("none").checked = true;
    }
    starPoints(brgtStarsTL, '#0000a0', 4, 5);
  }
  // Plot stars which are both nearest and brightest (red, larger filled triangles)
  if ((document.getElementById("olap").checked) || ((document.getElementById("both").checked)))  {
    if (typeof olapStarsTL === 'undefined' || olapStarsTL === null)  {
      s0 = starPath.concat(olapFile);
      olapStarsTL = [ [], [], 0 ];
      olapStarsTL = readCatalog(s0);
    } else if (olapStarsTL[2] != 0)  {
      string01 = "Warning: Unable to display sample of stars which are nearest and brightest (overlap sample).";
      mbox_text.innerHTML      = string01;
      mbox_frame.style.display = 'inline';  
      document.getElementById("none").checked = true;
    }
    starPoints(olapStarsTL, '#d6001a', 10, 3);  // previous color was #8c001a
  }
      
  // Mark temperature and luminosity with small red arrows on axes
  hrdc_ct.fillStyle   = '#ff0000';
  hrdc_ct.strokeStyle = hrdc_ct.fillStyle;
  coords = convert (tK, lS, 1);
  t = (new Date).getTime();
  if ( (mousedown == null) || (t - mousedown.time < tOn) || ( (mousemove != null) && (t - mousemove.time < tOn) ) )  {
    // Small dots from cursor to horizontal arrow on temperature axis
    if ( (del3 < yMin - coords[1]) && (del3 < coords[1] - yMax) )  {
      for (i = coords[0] - del; i >= xMin+del; i -= del)  {
        hrdc_ct.beginPath();
        hrdc_ct.arc(i, coords[1], 1, 0, 2*Math.PI);
        hrdc_ct.fill();
        hrdc_ct.stroke();
      }
    }
    // Small dots from cursor to vertical arrow on luminosity axis
    if ( (del3 < coords[0] - xMin) && (del3 < xMax - coords[0]) )  {
      for (i = coords[1] + del; i <= yMin-del; i += del)  {
        hrdc_ct.beginPath();
        hrdc_ct.arc(coords[0], i, 1, 0, 2*Math.PI);
        hrdc_ct.fill();
        hrdc_ct.stroke();
      }
    }
  }
  // Horizontal arrow on temperature axis
  hrdc_ct.beginPath();
  x1 = Math.min( xMin+del,                 coords[0]-del2);  // Arrow shaft
  if (x1 > xMin)  {
    hrdc_ct.moveTo(x1,                     coords[1]);
    hrdc_ct.lineTo(xMin,                   coords[1]);
  }
  x1 = Math.min( xMin+del2,                coords[0]-del2);  // Arrow head
  x2 = Math.max( x1-xMin,                  0);
  if (x1 > xMin)  {
    hrdc_ct.moveTo(x1,                     coords[1]-del3*x2/del2);
    hrdc_ct.lineTo(xMin,                   coords[1]);
    hrdc_ct.lineTo(x1,                     coords[1]+del3*x2/del2);
  }
  // Vertical arrow on luminosity axis
  y1 = Math.max( yMin-del,                 coords[1]+del2);  // Arrow shaft
  if (y1 < yMin)  {
    hrdc_ct.moveTo(coords[0],              y1);
    hrdc_ct.lineTo(coords[0],              yMin);
  }
  y1 = Math.max( yMin-del2,                coords[1]+del2);  // Arrow head
  y2 = Math.max( yMin-y1,                  0);
  if (y1 < yMin)  {
    hrdc_ct.moveTo(coords[0]-del3*y2/del2, y1);
    hrdc_ct.lineTo(coords[0],              yMin);
    hrdc_ct.lineTo(coords[0]+del3*y2/del2, y1);
  }
  hrdc_ct.fill();
  hrdc_ct.stroke();
    
  // Show cursor as red X
  del4                = 5;
  hrdc_ct.lineWidth   = 2;
  hrdc_ct.fillStyle   = '#ff0000';
  hrdc_ct.strokeStyle = hrdc_ct.fillStyle;
  coords = convert (tK, lS, 1);
  hrdc_ct.beginPath();
  hrdc_ct.moveTo(coords[0]-del4, coords[1]-del4);
  hrdc_ct.lineTo(coords[0]+del4, coords[1]+del4);
  hrdc_ct.moveTo(coords[0]-del4, coords[1]+del4);
  hrdc_ct.lineTo(coords[0]+del4, coords[1]-del4);
  hrdc_ct.fill();
  hrdc_ct.stroke();
  hrdc_ct.lineWidth   = 1;

}


//////////////////////////////////////////////////////////////////////////////
// H-R Diagram functions
//////////////////////////////////////////////////////////////////////////////


// Convert between temperature and luminosity and x and y on H-R Diagram
function convert(var1, var2, mode)  {

  // Convert from temperature and luminosity to x and y
  if (mode == 1)  {
    t      = Math.log(var1)/Math.LN10;
    l      = Math.log(var2)/Math.LN10;
    x      = xMin + (xMax - xMin) * ( t - Math.log(tMax)/Math.LN10 ) / ( Math.log(tMin)/Math.LN10 - Math.log(tMax)/Math.LN10 );
    y      = yMin + (yMax - yMin) * ( l - Math.log(lMin)/Math.LN10 ) / ( Math.log(lMax)/Math.LN10 - Math.log(lMin)/Math.LN10 );
    coords = [ x, y ];

  // Convert from x and y to temperature and luminosity
  } else  {
    t       = (var1 - xMin)/(xMax - xMin) * ( Math.log(tMin)/Math.LN10 - Math.log(tMax)/Math.LN10 ) + Math.log(tMax)/Math.LN10;
    l       = (var2 - yMin)/(yMax - yMin) * ( Math.log(lMax)/Math.LN10 - Math.log(lMin)/Math.LN10 ) + Math.log(lMin)/Math.LN10;
    t       = Math.pow( 10, t );
    l       = Math.pow( 10, l );
    coords  = [ t, l ];
  }

  return coords;

}


// Fit set of n+1 (L,T) points with n cubic splines
function smoothFit(xfit, yfit, olap, color, debug)  {
    
  // Convert set of points from (L,T) to (x,y)
  var x = [];
  var y = [];
  var n = xfit.length;
  for (i = 0; i < n; i++)  {
    coords = convert( xfit[i], yfit[i], 1);
    x.push(coords[0]);
    y.push(coords[1]);
  }
  // Set to olap 1 and then -1 to form single region from two sets of data (1 for top of shape, -1 for bottom of shape)
  y[0]   += olap;
  y[n-1] += olap;
    
  // Show points being fit in debug mode
  if (debug)  {
    console.log('(x,y) for cubic spline:', x, y);
    // Connect defining points
    hrdc_ct.strokeStyle = '#000000';
    for (i = 0; i < n; i++)  {
      if (i == 0)  {
        hrdc_ct.beginPath();
        hrdc_ct.moveTo(x[i], y[i]);
      } else  {
        hrdc_ct.lineTo(x[i], y[i]);
      }
    }
    hrdc_ct.stroke();

    // Draw defining points
    hrdc_ct.fillStyle   = '#000000';
    hrdc_ct.strokeStyle = '#000000';
    for (i = 0; i < n; i++)  {
      hrdc_ct.beginPath();
      hrdc_ct.arc(x[i], y[i], 1, 0, 2*Math.PI);
      hrdc_ct.fill();
      hrdc_ct.stroke();
    }
  }

  // Fit with cubic splines
  cspline    = new Array(4);
  cspline[0] = new Array(n-1);
  cspline[1] = new Array(n-1);
  cspline[2] = new Array(n-1);
  cspline[3] = new Array(n-1);
  cspline    = cubicSpline(x,y);

  // Draw cubic splines (each spline running between two defining points)
  hrdc_ct.globalAlpha = 0.5;
  hrdc_ct.fillStyle   = color;
  hrdc_ct.strokeStyle = hrdc_ct.fillStyle;
  hrdc_ct.beginPath();
  hrdc_ct.moveTo(x[0], y[0]);
  nseg = 20;
  for (i = 0; i < n-1; i++)  {
    for (j = 0; j < nseg; j++)  {
      dx = (x[i+1] - x[i]) * j / nseg;
      nx = x[i] + dx;
      ny = cspline[0][i] + cspline[1][i] * dx + cspline[2][i] * dx * dx + cspline[3][i] * dx * dx * dx;
      hrdc_ct.lineTo(nx, ny);
    }
  }
  hrdc_ct.lineTo(x[n], y[n]);
  hrdc_ct.fill();
  hrdc_ct.stroke();
  hrdc_ct.globalAlpha = 1;

}


// Fit set of n+1 (L,T) points with n cubic splines, to 2 data sets,
// filling region between them
function smoothFit2(xfit1, yfit1, xfit2, yfit2, color, debug)  {
    
  // Convert sets of points from (L,T) to (x,y)
  var x1 = [], x2 = [];
  var y1 = [], y2 = [];
  var n1 = xfit1.length, n2 = xfit2.length;
  for (i = 0; i < n1; i++)  {
    coords = convert( xfit1[i], yfit1[i], 1);
    x1.push(coords[0]);
    y1.push(coords[1]);
  }
  for (i = 0; i < n2; i++)  {
    coords = convert( xfit2[i], yfit2[i], 1);
    x2.push(coords[0]);
    y2.push(coords[1]);
  }
    
  // Show points being fit in debug mode
  if (debug)  {
    console.log('(x,y) for first cubic spline:',  x1, y1);
    console.log('(x,y) for second cubic spline:', x2, y2);
    // Connect defining points
    hrdc_ct.strokeStyle = '#000000';
    for (i = 0; i < n1; i++)  {
      if (i == 0)  {
        hrdc_ct.beginPath();
        hrdc_ct.moveTo(x1[i], y1[i]);
      } else  {
        hrdc_ct.lineTo(x1[i], y1[i]);
      }
    }
    hrdc_ct.stroke();
    for (i = 0; i < n2; i++)  {
      if (i == 0)  {
        hrdc_ct.beginPath();
        hrdc_ct.moveTo(x2[i], y2[i]);
      } else  {
        hrdc_ct.lineTo(x2[i], y2[i]);
      }
    }
    hrdc_ct.stroke();

    // Draw defining points
    hrdc_ct.fillStyle   = '#000000';
    hrdc_ct.strokeStyle = '#000000';
    for (i = 0; i < n1; i++)  {
      hrdc_ct.beginPath();
      hrdc_ct.arc(x1[i], y1[i], 1, 0, 2*Math.PI);
      hrdc_ct.fill();
      hrdc_ct.stroke();
    }
    for (i = 0; i < n2; i++)  {
      hrdc_ct.beginPath();
      hrdc_ct.arc(x2[i], y2[i], 1, 0, 2*Math.PI);
      hrdc_ct.fill();
      hrdc_ct.stroke();
    }
  }

  // Fit both data sets with cubic splines
  cspline1    = new Array(4);
  cspline2    = new Array(4);
  cspline1[0] = new Array(n1-1);
  cspline1[1] = new Array(n1-1);
  cspline1[2] = new Array(n1-1);
  cspline1[3] = new Array(n1-1);
  cspline2[0] = new Array(n2-1);
  cspline2[1] = new Array(n2-1);
  cspline2[2] = new Array(n2-1);
  cspline2[3] = new Array(n2-1);
  cspline1    = cubicSpline(x1,y1);
  cspline2    = cubicSpline(x2,y2);

  // Connect cubic splines to form a single shape
  hrdc_ct.globalAlpha = 0.5;
  hrdc_ct.fillStyle   = color;
  hrdc_ct.strokeStyle = hrdc_ct.fillStyle;
  hrdc_ct.beginPath();
  hrdc_ct.moveTo(x1[0], y1[0]);
  nseg = 20;
  for (i = 0; i < n1-1; i++)  {
    for (j = 0; j < nseg; j++)  {
      dx = (x1[i+1] - x1[i]) * j / nseg;
      nx = x1[i] + dx;
      ny = cspline1[0][i] + cspline1[1][i] * dx + cspline1[2][i] * dx * dx + cspline1[3][i] * dx * dx * dx;
      hrdc_ct.lineTo(nx, ny);
    }
  }
  hrdc_ct.lineTo(x1[n1], y1[n1]);
  for (i = 0; i < n2-1; i++)  {
    for (j = 0; j < nseg; j++)  {
      dx = (x2[i+1] - x2[i]) * j / nseg;
      nx = x2[i] + dx;
      ny = cspline2[0][i] + cspline2[1][i] * dx + cspline2[2][i] * dx * dx + cspline2[3][i] * dx * dx * dx;
      hrdc_ct.lineTo(nx, ny);
    }
  }
  hrdc_ct.lineTo(x2[n2], y2[n2]);
  hrdc_ct.lineTo(x1[0], y1[0]);
  hrdc_ct.fill();
  hrdc_ct.stroke();
  hrdc_ct.globalAlpha = 1;

}


// Fit set of n+1 points with n cubic splines
function cubicSpline(x, y)  {

  var i, n = x.length - 1;
  var a = y.slice(), b = [], c = [], d = [];  // Fit coefficients for cubic splines (one spline between each set of two points)
  var h = [], alpha = [];
  var l = [], u = [], z = [];
    
  for (i = 0; i < n; i++)  {
    b.push( 0 );
    d.push( 0 );
    h.push( x[i+1] - x[i] );
    if (i == 0)  {
      alpha.push( 0 );
    } else  {
      alpha.push( 3*(a[i+1] - a[i]) / h[i] - 3*(a[i] - a[i-1]) / h[i-1] );
    }
  }
  for (i = 0; i <= n; i++)  {
    c.push( 0 );
    if (i == 0)  {
      l.push( 1 );
      u.push( 0 );
      z.push( 0 );
    } else if (i < n) {
      l.push( 2*(x[i+1] - x[i-1]) - h[i-1] * u[i-1] );
      u.push( h[i]/l[i] );
      z.push( (alpha[i] - h[i-1] * z[i-1]) / l[i] );
    } else  {
      l.push( 1 );
      u.push( 0 );
      z.push( 0 );
    }
  }
  for (i = n-1; i >= 0; i--)  {
    c[i] = z[i] - u[i] * c[i+1];
    b[i] = (a[i+1] - a[i]) / h[i] - h[i] * (c[i+1] + 2*c[i]) / 3;
    d[i] = (c[i+1] - c[i]) / (3*h[i]);
  }
  // 
  // Fill array with n cubic spline coefficients
  // 
  // For a set of n+1 points (x_0,y_0), (x_1,y_1), ... (x_n,y_n),
  // 
  // we define n cubic splines where for i = 0, ..., n-1, 
  // 
  //   S_i(x) = a_i + b_i * (x - x_i) + c_i * (x - x_i)^2 + d_i * (x - x_i)^3
  // 
  // where x is defined within the range x_i <= x <= x_i+1. 
  // 
  var coefficients = [ [], [], [], [] ];
  for (i = 0; i < n; i++)  {
    coefficients[0].push( a[i] );
    coefficients[1].push( b[i] );
    coefficients[2].push( c[i] );
    coefficients[3].push( d[i] );
  }

  return coefficients;

}


// Draw ellipse
function drawEllipse(e, p, x0, y0, t0, color)  {

  // e: 0 <= e < 1  // eccentricity, such that e^2 = 1 - (b/a)^2 where a is major-axis and b is minor-axis
  // p              // focal parameter, such that p = a*(1 - e^2)/e
  // x0             // focal point x  (screen coordinates)
  // y0             // focal point y  (screen coordinates)
  // t0             // rotate ellipse (degrees ccw)

  var t, r, x, y;

  hrdc_ct.globalAlpha = 0.45;
  hrdc_ct.fillStyle   = color;
  hrdc_ct.strokeStyle = color;
  for (i = 0; i <= 720; i++)  {
    t = i * Math.PI/360;
    r = e*p / ( 1 - e * Math.cos(t) );
    x = x0 + r * Math.cos(t - t0 * Math.PI/180);
    y = y0 + r * Math.sin(t - t0 * Math.PI/180);
    if (i == 0)  {
      hrdc_ct.beginPath();
      hrdc_ct.moveTo(x, y);
    } else  {
      hrdc_ct.lineTo(x, y);
    }
  }
  hrdc_ct.fill();
  hrdc_ct.stroke();
  hrdc_ct.globalAlpha = 1;

}


// Read in pairs of stellar temperatures and luminosities for a set of stars
function readCatalog(filename)  {

  var stellarTL = [ [], [], 0 ];
    
  // Use AJAX to request and receive file from server in text format
  xhttp = new XMLHttpRequest();
  xhttp.onreadystatechange = function() {
    // At state 4 the request is finished and the response is ready
    if (xhttp.readyState == 4)  {
      // Status of 0 is for local disk, and 200 is for HTTP request to server
      if (xhttp.status == xhttpStatus)  {
        string01 = xhttp.responseText;
        array01  = string01.split(/[\r\n]+/);
        for (i = 0; i < array01.length; i++)  {
          string01 = array01[i];
          // Ignore commented-out lines
          if ( (string01.substring(0,1) == '#' ) || (string01.substring(0,1) == '!' ) || 
               (string01.substring(0,2) == '//') || (string01.substring(0,2) == '/*') )  {
            continue;
          }
          array02 = string01.trim();
          array02 = array02.split(/[\s,]+/);
          // Require two numeric values (temperature and luminosity) per line
          if ( (array02.length == 2) && (!isNaN(parseFloat(array02[0]))) && (isFinite(array02[0])) &&
                                        (!isNaN(parseFloat(array02[1]))) && (isFinite(array02[1])) )  {
            stellarTL[0].push (Number(array02[0]));  // stellar temperature in Kelvin
            stellarTL[1].push (Number(array02[1]));  // stellar luminosity in solar luminosities
          }
        }
        // Check that at least one set of stellar values was read
        if (stellarTL[0].length == 0)  {
          string01 = "Warning: Requested stellar catalog " + filename + " was not read correctly.";
          mbox_text.innerHTML      = string01;
          mbox_frame.style.display = 'inline';  
          document.getElementById("none").checked = true;
          stellarTL[2] = 1;
        }
      } else  {
        // Check that file was readable
        string01 = "Warning: Requested stellar catalog " + filename + " was not accessible.";
        mbox_text.innerHTML      = string01;
        mbox_frame.style.display = 'inline';  
        document.getElementById("none").checked = true;
        stellarTL[2] = 2;
      }
    }
  };
  // Read file in synchronously (this is discouraged)
  xhttp.open("GET", filename, false);
  xhttp.send();

  return stellarTL;
    
}


// Plot stellar points on H-R Diagram
function starPoints(stellarTL, color, size, shape)  {

  // Shape creates different point shapes
  // 
  //   1 - filled circle
  //   2 - filled square
  //   3 - filled triangle
  //   4 - open   circle
  //   5 - open   square
  //   6 - open   triangle
  // 

  hrdc_ct.fillStyle   = color;
  hrdc_ct.strokeStyle = hrdc_ct.fillStyle;
  for (i = 0; i < stellarTL[0].length; i++)  {
    coords = convert (stellarTL[0][i], stellarTL[1][i], 1);
    hrdc_ct.beginPath();
    if (      ( shape % 3 ) == 1 )  { hrdc_ct.arc( coords[0], coords[1], size, 0, 2*Math.PI) }
    else if ( ( shape % 3 ) == 2 )  { hrdc_ct.rect(coords[0], coords[1], size, size)         }
    else if ( ( shape % 3 ) == 0 )  { 
      hrdc_ct.moveTo(coords[0] - size/2, coords[1]);
      hrdc_ct.lineTo(coords[0] + size/2, coords[1]);
      hrdc_ct.lineTo(coords[0], coords[1] - 0.5 * Math.sqrt(3) * size);
      hrdc_ct.lineTo(coords[0] - size/2, coords[1]);
      hrdc_ct.closePath();
    }
    if ( shape < 4 )  { hrdc_ct.fill(); }
    hrdc_ct.stroke();
  }
}


// Close text box (containing warning that stellar catalog not read)

mbox_closer.onclick = function()  {
  mbox_frame.style.display   = 'none';
}

window.onclick = function(event)  {
  if (event.target == mbox_frame)  {
    mbox_frame.style.display = 'none';
  }
}


//////////////////////////////////////////////////////////////////////////////
// Size comparison panel functions
//////////////////////////////////////////////////////////////////////////////


// Draw size comparison panel
function showSize()  {

  // Determine star radius from temperature and luminosity
  var tK = tKelvin.value;
  var t  = tKelvin.value / tSun;
  var r  = Math.sqrt(lSolar.value) / (t*t);
    
  // Draw black box to hold star
  sizecmpc_ct.fillStyle = '#000000';
  sizecmpc_ct.fillRect(0, 0, 180, 380);

  // Draw star
  var xc = 170 - 80*r;
  var yc = 190;
  sizecmpc_ct.fillStyle    = '#ffffff';
  sizecmpc_ct.beginPath();
  sizecmpc_ct.arc(xc, yc, 80*r, 0, 2*Math.PI)
  sizecmpc_ct.fill();
  sizecmpc_ct.fillStyle    = colorTemp(tK);
  sizecmpc_ct.globalAlpha  = 0.5;
  sizecmpc_ct.beginPath();
  sizecmpc_ct.arc(xc, yc, 80*r, 0, 2*Math.PI)
  sizecmpc_ct.fill();
  sizecmpc_ct.globalAlpha = 1;

  // Label star
  sizecmpc_ct.fillStyle    = '#000000';
  sizecmpc_ct.fillRect(0, 346, 45, 34);
  sizecmpc_ct.fillStyle    = '#ffffff';
  sizecmpc_ct.textAlign    = 'start';
  sizecmpc_ct.textBaseline = 'bottom';
  sizecmpc_ct.fillText("star", 10, 370);

}

function colorTemp(tK)  {

  // Adjust star color from red to blue to match temperature
  if      (tK <  3700)  { clr   = '#ff0000'; }  // red
  else if (tK <  5200)  { clr   = '#ffa500'; }  // orange
  else if (tK <  6000)  { clr   = '#f1c40f'; }  // yellow
  else if (tK <  7500)  { clr   = '#f7dc6f'; }  // yellow-white
//else if (tK < 10000)  { clr   = '#aed6f1'; }  // white-blue
  else if (tK < 18000)  { clr   = '#aed6f1'; }  // white-blue (cut back on blue)
  else if (tK < 30000)  { clr   = '#9ce8e7'; }  // ice-blue
  else                  { clr   = '#0000ff'; }  // blue

  // Interpolate between 7 colors above chosen by eye
  var tmprtT    = [ tMin, 3700, 5200, 6000, 7500, 10000, 30000, tMax ];
  var colorT    = [ [255,   0,   0], [255,   0,   0], [255, 165,   0], [241, 196,  15], [247, 220, 111], [174, 214, 241], [156, 232, 231], [  0,   0, 255] ];
  j = 0;
  for (i = 0; i < tmprtT.length-1; i++)  {
    if (tK >= tmprtT[i])  {
      j = i+1;
    }
  }
  r   = Math.round( colorT[j-1][0] + (colorT[j][0] - colorT[j-1][0]) * (tK - tmprtT[j-1]) / (tmprtT[j] - tmprtT[j-1]) );
  g   = Math.round( colorT[j-1][1] + (colorT[j][1] - colorT[j-1][1]) * (tK - tmprtT[j-1]) / (tmprtT[j] - tmprtT[j-1]) );
  b   = Math.round( colorT[j-1][2] + (colorT[j][2] - colorT[j-1][2]) * (tK - tmprtT[j-1]) / (tmprtT[j] - tmprtT[j-1]) );
  a   = 1.0;
  clr = 'rgba(' + r + ',' + g + ',' + b + ',' + a + ')';

  return (clr);

}


//////////////////////////////////////////////////////////////////////////////
// Slider bars for temperature and luminosity controls
//////////////////////////////////////////////////////////////////////////////


// Adjust new temperature slider bar
function tslider()  {

  const slider = document.getElementById('tRange');
  
  slider.value = 100 * ( tKelvin.value - tKelvin.min ) / ( tKelvin.max - tKelvin.min );

}


// Adjust new luminosity slider bar
function lslider()  {

  const slider = document.getElementById('lRange');
  
  const r0 = -4;
  slider.value = 100 * ( Math.log10(lSolar.value) - r0 ) / ( Math.log10(lSolar.max) - r0);

}


// Draw temperature slider bar
function tslide()  {

  tslider_ct.clearRect(0, 0, tslider.width, tslider.height);
  /*
  tslider_ct.fillStyle = '#dddddd';
  tslider_ct.fillRect (0, 0, tslider.width, tslider.height);
  */

  // Draw bar, filled with stellar colors matching colors used for star in size comparison
  var y1 = 8;                                                        // y-height    of bar
  var r1 = 2;                                                        // half-height of bar (thin)
  // Define color gradient to match colors used for star in size comparison
  var i,j;
  var gradientT = tslider_ct.createLinearGradient(xmrg, y1, tslider.width-2*xmrg, y1);
  var tmprtT    = [ 3700, 5200, 6000, 7500, 10000, 30000, tMax ];
  var colorT    = [ 'rgba(255,   0,   0, 0.5)', 'rgba(255, 165,   0, 0.9)', 'rgba(241, 196,  15, 0.9)', 'rgba(247, 220, 111, 0.9)', 'rgba(174, 214, 241, 0.9)', 'rgba(156, 232, 231, 0.9)', 'rgba(  0,   0, 255, 0.5)' ];
  for (i = 0; i < tmprtT.length; i++)  {
    j = (Math.log(tmprtT[i]) - Math.log(tMin)) / (Math.log(tMax) - Math.log(tMin));
    gradientT.addColorStop(j, colorT[i]);  // red, orange, yellow, yellow-white, white-blue, ice-blue, blue
  }
  tslider_ct.strokeStyle = '#000000';
//tslider_ct.fillStyle   = '#52be80';
  tslider_ct.fillStyle     = gradientT;
  tslider_ct.beginPath();
  tslider_ct.moveTo(xMinT, y1-r1);
  tslider_ct.lineTo(xMaxT, y1-r1);                                   // bottom line
  tslider_ct.arc   (xMaxT, y1, r1, 3*Math.PI/2,   Math.PI/2, false); // right side arc
  tslider_ct.lineTo(xMinT, y1+r1);                                   // top   line
  tslider_ct.arc   (xMinT, y1, r1,   Math.PI/2, 3*Math.PI/2, false); // left  side arc
  tslider_ct.closePath();
  tslider_ct.fill();
  tslider_ct.stroke();

  // Calculate position of knob based on luminosity
  coords = convert (tKelvin.value, lSolar.value, 1);
  tsx    = xMaxT - (xMaxT - xMinT) * ( (coords[0] - xMin) / (xMax - xMin) );  // x-position of knob center

  // Draw knob as teardrop shape
  var ty  =  3;                                                      // y-coordinate of teardrop tip
  var cy  = 20;                                                      // y-coordinate of teardrop arc center
  var tr  =  7;                                                      // radius       of teardrop arc
  var da  =  0.2      * Math.PI                                      // angular shift above horizontal for ends of teardrop arc
  var x1  =        tr * Math.cos(Math.PI+da);                        // upper-left corner of teardrop arc offset from center
  var y1  =        tr * Math.sin(Math.PI+da);
  var d1  =  0.5 * tr;                                               // offsets for Bezier curves
  var d2  =  0.2 * tr;
  tslider_ct.beginPath();
  tslider_ct.lineJoin      = 'miter';
  tslider_ct.arc          (tsx, cy, tr, 2*Math.PI-da, Math.PI+da, false);
  tslider_ct.bezierCurveTo(tsx+x1+d1, cy+y1-d2, tsx-d2,    ty+d1,    tsx,    ty);
  tslider_ct.bezierCurveTo(tsx+d2,    ty+d1,    tsx-x1-d1, cy+y1-d2, tsx-x1, cy+y1);
  tslider_ct.closePath();
  tslider_ct.lineWidth     = 1;
  tslider_ct.shadowOffsetX = 2;
  tslider_ct.shadowOffsetY = 2;
  tslider_ct.shadowBlur    = 2;
  tslider_ct.shadowColor   = "rgba(50, 50, 50, 0.5)";    
  tslider_ct.fillStyle     = gradientT;
  tslider_ct.fill();
  tslider_ct.stroke();

  // Add dot in center of teardrop (for users to target with mouse)
  tslider_ct.beginPath();
  tslider_ct.arc(tsx, cy, 0.1*tr, 0, 2*Math.PI, false);
  tslider_ct.closePath();
  tslider_ct.stroke();

}

// Draw luminosity slider bar, with knob
function lslide()  {

  lslider_ct.clearRect(0, 0, lslider.width, lslider.height);
  /*
  lslider_ct.fillStyle = '#dddddd';
  lslider_ct.fillRect (0, 0, lslider.width, lslider.height);
  */

  // Draw bar, filled with black through white colors to mimic brightness of star
  var y1 = 8;                                                        // y-height    of bar
  var r1 = 2;                                                        // half-height of bar (thin)
  // Define color gradient to match colors used for star in size comparison
  var i,j;
  var gradientL = lslider_ct.createLinearGradient(xmrg, y1, lslider.width-2*xmrg, y1);
  var luminL    = [ lMin, lMax ];
  var colorL    = [ 'rgba(  0,   0,   0, 1)', 'rgba(255, 255, 255, 1)' ];
  for (i = 0; i < luminL.length; i++)  {
    j = (Math.log(luminL[i]) - Math.log(lMin)) / (Math.log(lMax) - Math.log(lMin));
    gradientL.addColorStop(j, colorL[i]);  // black, white
  }
  lslider_ct.strokeStyle = '#000000';
  lslider_ct.fillStyle   = '#52be80';
  lslider_ct.fillStyle   = gradientL;
  lslider_ct.beginPath();
  lslider_ct.moveTo(xMinL, y1-r1);
  lslider_ct.lineTo(xMaxL, y1-r1);                                   // bottom line
  lslider_ct.arc   (xMaxL, y1, r1, 3*Math.PI/2,   Math.PI/2, false); // right side arc
  lslider_ct.lineTo(xMinL, y1+r1);                                   // top   line
  lslider_ct.arc   (xMinL, y1, r1,   Math.PI/2, 3*Math.PI/2, false); // left  side arc
  lslider_ct.closePath();
  lslider_ct.fill();
  lslider_ct.stroke();

  // Calculate position of knob based on luminosity
  coords = convert (tKelvin.value, lSolar.value, 1);
  lsx    = xMaxL - (xMaxL - xMinL) * ( (coords[1] - yMax) / (yMin - yMax) );  // x-position of knob center

  // Draw knob as teardrop shape
  var ty  =  3;                                                      // y-coordinate of teardrop tip
  var cy  = 20;                                                      // y-coordinate of teardrop arc center
  var tr  =  7;                                                      // radius       of teardrop arc
  var da  =  0.2      * Math.PI                                      // angular shift above horizontal for ends of teardrop arc
  var x1  =        tr * Math.cos(Math.PI+da);                        // upper-left corner of teardrop arc offset from center
  var y1  =        tr * Math.sin(Math.PI+da);
  var d1  =  0.5 * tr;                                               // offsets for Bezier curves
  var d2  =  0.2 * tr;
  lslider_ct.beginPath();
  lslider_ct.lineJoin      = 'miter';
  lslider_ct.arc          (lsx, cy, tr, 2*Math.PI-da, Math.PI+da, false);
  lslider_ct.bezierCurveTo(lsx+x1+d1, cy+y1-d2, lsx-d2,    ty+d1,    lsx,    ty);
  lslider_ct.bezierCurveTo(lsx+d2,    ty+d1,    lsx-x1-d1, cy+y1-d2, lsx-x1, cy+y1);
  lslider_ct.closePath();
  lslider_ct.lineWidth     = 1;
  lslider_ct.shadowOffsetX = 2;
  lslider_ct.shadowOffsetY = 2;
  lslider_ct.shadowBlur    = 2;
  lslider_ct.shadowColor   = "rgba(50, 50, 50, 0.5)";    
  lslider_ct.fillStyle     = gradientL;
  lslider_ct.fill();
  lslider_ct.stroke();

  // Add dot in center of teardrop (for users to target with mouse)
  lslider_ct.beginPath();
  lslider_ct.arc(lsx, cy, 0.1*tr, 0, 2*Math.PI, false);
  lslider_ct.closePath();
  lslider_ct.stroke();
    
}


//////////////////////////////////////////////////////////////////////////////
// Equation for radius
//////////////////////////////////////////////////////////////////////////////


// Format calculated radius for display and screen reader announcements
function formatRadiusDisplay()  {

  var r0 = Math.sqrt(lSolar.value) / Math.pow( (tKelvin.value / tSun), 2 );
  var r1;
  if (r0 >= 1000)  {
    r1 = 10*Math.round(0.1*r0);
  } else if (r0 >= 0.01)  {
    r1 = r0.toPrecision(3);
  } else  {
    r1 = r0.toFixed(5);
  }
  return formatNumber(r1.toString());

}


// Announce temperature, luminosity, and radius to screen readers
function announceStarProperties()  {

  var announcer = document.getElementById('star-props-announcer');
  if (!announcer)  {
    return;
  }
  var r = formatRadiusDisplay();
  announcer.textContent =
    'Temperature ' + tKelvin.value + ' kelvin. ' +
    'Luminosity ' + lSolar.value + ' solar luminosities. ' +
    'Calculated star radius is now ' + r + ' solar radii. Visual comparison updated.';

}


// Draw equation for radius
function requation()  {

  /*
  reqn_ct.clearRect(0, 0, reqn.width, reqn.height);
  //
  reqn_ct.fillStyle = '#dddddd';
//reqn_ct.fillRect (0, 0, reqn.width, reqn.height);
  //

  // Display radius R to nearest ten's place above 1000,   (1,000       to 6,000), 
  // show three significant digits at intermediate values, (    0.00100 to     1,000),
  // show two   significant digits at lowest       values  (    0.00020 to         0.00100)
  r0 = Math.sqrt(lSolar.value) / Math.pow( (tKelvin.value / tSun), 2 );
  if (r0 >= 1000)  {
    r1 = 10*Math.round(0.1*r0);
  } else if (r0 >= 0.01)  {
    r1 = r0.toPrecision(3);
  } else  {
    r1 = r0.toFixed(5);
  }
  // Add comma's as appropriate for readability for thousands and millions places in L, R, and T values
  r2  = formatNumber(r1.toString());
  l2  = formatNumber(lSolar.value.toString());
  t2  = formatNumber(tKelvin.value.toString());
  t0  = formatNumber(tSun.toString());

  // Place text elements along center of equation
  reqn_ct.textAlign    = 'center';
  reqn_ct.textBaseline = 'middle';
  reqn_ct.font         = '16px Sans-Serif';
  reqn_ct.fillStyle    = '#000000';
  reqn_ct.strokeStyle  = '#000000';

  // First equals sign
  var midy = reqn.height / 2;
  var x    =  0;
  var y    = midy - 18;
  reqn_ct.beginPath();
  reqn_ct.moveTo(x,      y     );
  reqn_ct.lineTo(x + 10, y     );
  reqn_ct.moveTo(x,      y +  4);
  reqn_ct.lineTo(x + 10, y +  4);
  reqn_ct.stroke();

  // Square-root symbol around L symbol
  // (x,y) approximates lower-left corner of symbol
  x += 25;
  reqn_ct.beginPath();
  reqn_ct.moveTo(x -  3, y -  8);
  reqn_ct.lineTo(x -  1,  y - 10);
  reqn_ct.lineTo(x +  1, y     );
  reqn_ct.lineTo(x +  8, y - 20);
  reqn_ct.lineTo(x + 21, y - 20);
  reqn_ct.stroke();
  // Dividing line between L and T / T_solar symbols
  reqn_ct.beginPath();
  reqn_ct.moveTo(x -  8, y +  3);
  reqn_ct.lineTo(x + 40, y +  3);
  reqn_ct.stroke();
  // Left and right parentheses around T / T_solar symbols
  reqn_ct.beginPath();
  reqn_ct.arc(x + 51, y + 34, 55, Math.PI-30*Math.PI/180, Math.PI+30*Math.PI/180, false);
  reqn_ct.stroke();
  reqn_ct.beginPath();
  reqn_ct.arc(x - 25, y + 34, 55,        -30*Math.PI/180,         30*Math.PI/180, false);
  reqn_ct.stroke();
  // Power of two around T / T_solar symbols
  reqn_ct.font         = '10px Sans-Serif';
  reqn_ct.fillText('2', x + 34, y +  9);
  reqn_ct.font         = '16px Sans-Serif';
  // Dividing line between T and T_solar symbols
  reqn_ct.beginPath();
  reqn_ct.moveTo(x +  4, y + 33);
  reqn_ct.lineTo(x + 22, y + 33);
  reqn_ct.stroke();
  // L, T and T_solar symbols
  reqn_ct.fillText('L', x + 14, midy - 26);
  reqn_ct.fillText('T', x + 13, y + 23);
  reqn_ct.fillText('T', x + 10, y + 43);
  reqn_ct.font         = '11px Sans-Serif';
  reqn_ct.fillText('\u2609', x + 17, y + 48);
  reqn_ct.font         = '16px Sans-Serif';

  // Second equals sign
  x += 47;
  reqn_ct.beginPath();
  reqn_ct.moveTo(x,      y     );
  reqn_ct.lineTo(x + 10, y     );
  reqn_ct.moveTo(x,      y +  4);
  reqn_ct.lineTo(x + 10, y +  4);
  reqn_ct.stroke();

  // Square-root symbol around lSolar
  // (x,y) approximates lower-left corner of symbol
  x += 19;
  reqn_ct.beginPath();
  reqn_ct.moveTo(x -  2, y -  8);
  reqn_ct.lineTo(x,      y - 10);
  reqn_ct.lineTo(x +  2, y     );
  reqn_ct.lineTo(x +  9, y - 20);
  reqn_ct.lineTo(x + 82, y - 20);
  reqn_ct.stroke();
  // Dividing line between lSolar and tKelvin / tSun
  reqn_ct.beginPath();
  reqn_ct.moveTo(x -  4, y +  3);
  reqn_ct.lineTo(x + 90, y +  3);
  reqn_ct.stroke();
  // Left and right parentheses around tKelvin / tSun
  reqn_ct.beginPath();
  reqn_ct.arc(x + 64, y + 34, 55, Math.PI-30*Math.PI/180, Math.PI+30*Math.PI/180, false);
  reqn_ct.stroke();
  reqn_ct.beginPath();
  reqn_ct.arc(x + 23, y + 34, 55,        -30*Math.PI/180,         30*Math.PI/180, false);
  reqn_ct.stroke();
  // Power of two around tKelvin / tSun
  reqn_ct.font         = '10px Sans-Serif';
  reqn_ct.fillText('2', x + 82, y +  9);
  reqn_ct.font         = '16px Sans-Serif';
  // Dividing line between tKelvin and tSun
  reqn_ct.beginPath();
  if (tKelvin.value < 10000)  {
    reqn_ct.moveTo(x + 24, y + 33);
    reqn_ct.lineTo(x + 67, y + 33);
  } else  {
    reqn_ct.moveTo(x + 17, y + 33);  // Extend line leftwards when tKelvin >= 10,000
    reqn_ct.lineTo(x + 67, y + 33);
  }
  reqn_ct.stroke();

  // lSolar, tKelvin, and tSun values
  reqn_ct.fillText(l2, x + 44, midy-26);
  reqn_ct.textAlign    = 'right';
  reqn_ct.fillText(t2, x + 67, midy+  4);  // Line up decimal point for two temperature values
  reqn_ct.fillText(t0, x + 67, midy+ 24);

  // Third equals sign
  x +=  96;
  reqn_ct.beginPath();
  reqn_ct.moveTo(x,      y     );
  reqn_ct.lineTo(x + 10, y     );
  reqn_ct.moveTo(x,      y +  4);
  reqn_ct.lineTo(x + 10, y +  4);
  reqn_ct.stroke();

  // Add solar symbol to units for radius at end of equation
  x  += 16;
  r2 += ' R';
  reqn_ct.textAlign    = 'left';
  reqn_ct.fillText(r2, x, midy - 16);
  rwid = reqn_ct.measureText(r2)
  reqn_ct.font         = '11px Sans-Serif';
  reqn_ct.fillText('\u2609', x + rwid.width, midy - 16 + 5);  // place solar symbol according to length of R value
  reqn_ct.font         = '16px Sans-Serif';

  reqn.setAttribute('aria-label',
    'Radius equals the square root of Luminosity, divided by the square of the ratio of the star\'s temperature to the Sun\'s temperature. Current value is ' +
    formatRadiusDisplay() + ' solar radii.');
  */

  // Format L, T, and R values for equation display
  const s0 = formatNumber(tSun.toString());
  const s1 = formatNumber(lSolar.value.toString());
  const s2 = formatNumber(tKelvin.value.toString());

  // Update equation output container with current values
  const mathContainer = document.getElementById('equation-output');
  if (mathContainer) {

    mathContainer.innerHTML = 
      `$$\\text{Radius} = ` + 
      `\\frac{ \\sqrt{ L } }{ \\left( \\frac{ T }{ T_{\\odot} } \\right)^2 } = ` + 
      `\\frac{ \\sqrt{` + s1 + `} }{ \\left( \\frac{` + s2 + `}{` + s0 + `} \\right)^2 } = ` + 
      formatRadiusDisplay() + `\\,R_{\\odot}$$`;

    // Fire the asynchronous compilation task through MathJax
    if (window.MathJax && MathJax.typesetPromise) {
      MathJax.typesetPromise([mathContainer]).catch((err) => console.error(err));
    }
  }

  // Update the screen reader live output
  document.getElementById('sr-live-output').textContent =
    'Radius equals the square root of luminosity, divided by the square of the ratio of the star\'s temperature to the Sun\'s temperature. Current value is ' +
    formatRadiusDisplay() + ' solar radii.';  

}


// Add commas to large numbers in labels, for readability
function formatNumber(sval) {

  var words = sval.split(".");

  words[0]  = words[0].replace(/\B(?=(\d{3})+(?!\d))/g, ",");

  return words.join(".");

}


//////////////////////////////////////////////////////////////////////////////
// Helpful screens (for help or credits)
//////////////////////////////////////////////////////////////////////////////


// Show help screens on top of H-R diagram and associated panels
function showText(msg)  {

  var screenText;
  var del = 2;

  /*
  if (msg == 1)  {
    help.style.color = '#000000';  // Help button text is red till viewed
    screenc.height   = 320;
    screenText       = helpText;
  } else if (msg == 2)  {
    screenc.height   = 130;
    screenText       = aboutText;
  }

  if (msg != 0)  {
    screenc_ct.clearRect(0, 0, screenc.width, screenc.height);
    screenc_ct.beginPath();
    screenc_ct.moveTo(del,               del);
    screenc_ct.lineTo(screenc.width-del, del);
    screenc_ct.lineTo(screenc.width-del, screenc.height-del);
    screenc_ct.lineTo(del,               screenc.height-del);
    screenc_ct.lineTo(del,               del);
    screenc_ct.stroke();

    screenc_ct.font       = '14px Helvetica';
    wrapText(screenc_ct, screenText, 920, 20, 20, 25);

    screenc.style.display = 'inline';
    screenb.style.display = 'inline';
  } else  {
    screenc.style.display = 'none';
    screenb.style.display = 'none';
    hrdc.focus();
  }
  */

  return;
}

// Wrap blocks of text to fit across screen
function wrapText(context, textBlock, maxWidth, lineHeight, xmargin, ymargin) {
  var words = textBlock.split(' ');
  var line  = '', testLine, metrics, testWidth;
  var x     = xmargin;
  var y     = ymargin;

  // Write text; a " Q " indicates a paragraph break in the text. 
  for (var i = 0; i < words.length; i++) {
    if (words[i] != "Q")  {
      testLine  = line + words[i] + ' ';
      metrics   = context.measureText(testLine);
      testWidth = metrics.width;
      if (testWidth > maxWidth) {
        context.fillText (line, x, y);
        line = words[i] + ' ';
        y += lineHeight;
      }  else {
        line = testLine;
      }
    }  else  {
      context.fillText (line, x, y);
      line = '';
      y += 1.7*lineHeight;
    }
  }
  context.fillText  (line, x, y);

}


//////////////////////////////////////////////////////////////////////////////
