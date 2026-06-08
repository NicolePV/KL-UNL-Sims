// Small-Angle Approximation Demonstrator 
// KL-UNL
// Nicole P. Vogt
// 2026-05-30
// Major Updates: 2026-05-30 (Flash --> HTML5)
//                2026-05-30 (WCAG AA accessibility)

//////////////////////////////////////////////////////////////////////////////
// Initialize
//////////////////////////////////////////////////////////////////////////////

// Canvas for angle display
const saa_ct = document.getElementById('angle-diagram').getContext('2d');

// Global variables
let dist;      // Distance from viewer to object
let diam;      // Diameter of object

// Update figure on window resize event
window.addEventListener('resize', updateFigure);

function klunlInitEqn()  { 

  // Update figure 
  dist = 40;
  diam =  2;
  newSetup( 40, 2 );

  // Initialize display equation label (static LaTeX)
  // angleLabel();
  klunlShowEquation( [ 'angle-label', `$$\\alpha$$` ] );

  // Initialize equation contents, associated screen reader content
  updateEqnContents();

};


function updateEqnContents()  {

  // Update equation contents and associated screen reader content

  // Define angle from distance to and size of object
  const angle    = 206265 * diam / dist;
  const angleFmt = angle.toLocaleString( undefined, { minimumFractionDigits: 1, maximumFractionDigits: 1 });

  // Define display equation in LaTeX-format
  const s0 = 
    `$$\\alpha \\,=\\, ` + 
    `206,265 \\times \\frac{ \\text{linear diameter} }{ \\text{distance} } \\,=\\, ` + 
        angleFmt + `\\;\\text{arcsec}$$`;

  // Define text of screen reader message (same for both equation and associated figure)
  let s1 =
    `Alpha equals 206,265 times linear diameter divided by distance, equal to ${angleFmt} arcseconds. ` + 
    `Distance ${dist} units, diameter ${diam} unit`;
  
  if ( diam > 1 ) { s1 += `s.` } 
  else            { s1 += `.`  }

  klunlShowEquation( [ 'equation-output', s0 ], [ 'sr-live-output', s1 ], [ 'figure-description', s1 ] );

};


//////////////////////////////////////////////////////////////////////////////
// Update
//////////////////////////////////////////////////////////////////////////////

function newSetup( distFlag, diamFlag )  {

  // Update distance to or diameter of object, and update figure

  // Update object distance via number value, slider bar, or preset buttons
  if        ( distFlag == -1 )  {
    
    dist = parseFloat( document.getElementById('distBox').value );
    document.getElementById('distSlider').value = dist;
    document.getElementById('distSlider').setAttribute( 'aria-valuetext', String(dist) );
    
  } else if ( distFlag == -2 )  {
    
    dist = parseFloat( document.getElementById('distSlider').value );
    document.getElementById('distSlider').setAttribute( 'aria-valuetext', String(dist) );
    document.getElementById('distBox').value    = dist;
    
  } else if ( ( 20 <= distFlag ) && ( distFlag <= 60 ) )  {
    
    dist = parseFloat( distFlag );
    document.getElementById('distBox').value    = dist;
    document.getElementById('distSlider').value = dist;
    document.getElementById('distSlider').setAttribute( 'aria-valuetext', String(dist) );
    
  }

  // Update object diameter via number value, slider bar, or preset buttons
  if ( diamFlag == -1 )  {
    
    diam = parseFloat( document.getElementById('diamBox').value );
    document.getElementById('diamSlider').value = diam;
    document.getElementById('diamSlider').setAttribute( 'aria-valuetext', String(diam) );
    
  } else if ( diamFlag == -2 )  {
    
    diam = parseFloat( document.getElementById('diamSlider').value );
    document.getElementById('diamSlider').setAttribute( 'aria-valuetext', String(diam) );
    document.getElementById('diamBox').value    = diam;
    
  } else if ( ( 1 <= diamFlag ) && ( diamFlag <= 3 ) )  {
    
    diam = parseFloat( diamFlag );
    document.getElementById('diamBox').value    = diam;
    document.getElementById('diamSlider').value = diam;
    document.getElementById('diamSlider').setAttribute( 'aria-valuetext', String(diam) );
    
  }

  // Update figure 
  updateFigure();

  // Update display equation and screen reader content 
  updateEqnContents()

};


function updateFigure()  {

  // Shift object towards and away from viewer, and increase or decrease diameter.
  // Update angle diagram to match.

  // Define figure constants
  const distMax  =   60;
  const maxWidth = 1000;

  // Identify changing elements of figure
  const saa  = document.getElementById('angle-diagram');
  const ball = document.getElementById('object-image');
  const labl = document.getElementById('angle-label');

  // Set width to diagram to match screen window
  saa.width  = Math.min( window.innerWidth, maxWidth );

  // Define x-range and y-range of angle diagram,
  // and location of angle label, within figure
  const  Scl =  10;                                               // Scale object size to be easily visible
  const xArc = 125;                                               // Label         distance from  vertex
  const xMin =  39;                                               // Angle diagram distance from  left  edge
  const yMid =  50;                                               // Angle diagram distance below upper edge
  const xMax = xMin + ( saa.width - 2 * xMin ) * dist / distMax;  // Angle diagram distance from  right edge
  const yDel =  Scl * diam * 0.96;                                // 96% shifts ends of angle rays into ball

  // Shift object to correct distance and update diameter
  ball.style.height = 2 * Scl * diam      + "px";
  ball.style.top    = yMid - ball.height/2 + "px";
  ball.style.left   = xMax - ball.height/2 + "px";

  // Shift arc label
  const r0 = Math.atan( yDel / (xMax - xMin) );
  labl.style.left = xMin + xArc - Scl + "px";  
  labl.style.top  = yMid - 3*Scl - xArc * Math.tan( r0 ) + "px";

  // Redraw angle rays
  saa_ct.strokeStyle = "#000000";
  saa_ct.clearRect(0, 0, window.innerWidth, saa.height);
  saa_ct.beginPath();
  saa_ct.moveTo(xMax, yMid + yDel);
  saa_ct.lineTo(xMin, yMid);
  saa_ct.lineTo(xMax, yMid - yDel);
  saa_ct.stroke();

  // Redraw angle label arc (subtending angle)
  saa_ct.beginPath();
  saa_ct.arc( xMin, yMid, xArc, -r0, r0 );
  saa_ct.stroke();

};
