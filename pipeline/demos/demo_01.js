// Simulation Name
// KL-UNL
// Lead name
// 2026-06-01
// Major Updates: 2026-06-01 (Flash --> HTML5)
//                2026-06-01 (WCAG AA accessibility)

//////////////////////////////////////////////////////////////////////////////
// Initialize
//////////////////////////////////////////////////////////////////////////////

// Global variables
let dist = 50;
let diam = 40;

// Update figure on window resize event
window.addEventListener('resize', updateFigure);

function klunlInitEqn()  { 

  // Initialize displayed equation (tied to MathJax in HTML); 
  // Note that this version of the function will over-ride default
  // version in demo_01.js
  
  newSetup( 0 );

};

//////////////////////////////////////////////////////////////////////////////
// Update Display
//////////////////////////////////////////////////////////////////////////////

function newSetup()  {

  updateFigure();

};

function updateFigure()  {

  // Update primary figure in response to user action
  //
  // Note that number boxes, sliders, and buttons are not connected to each
  // other or to the variable valuess, as this is just a formatting demonstration. 

  // Update displayed equation with current values
  // (populated with small angle approximation equation for demonstration purposes)

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
