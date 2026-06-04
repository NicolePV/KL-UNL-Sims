// Simulation Name
// KL-UNL
// Lead name
// 2026-06-01
// Major Updates: 2026-06-01 (Flash --> HTML5)
//                2026-06-01 (WCAG AA accessibility)

//////////////////////////////////////////////////////////////////////////////
// Initialize
//////////////////////////////////////////////////////////////////////////////

// Set up canvas for primary display

// Global variables
let dist = 50;
let diam = 50;

// Attach figure update function to window resize event
window.addEventListener('resize', updateFigure);

function initEqn()  { 

  // Initialize displayed equation (tied to MathJax in HTML)
  
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

  // Update displayed equation with current values
  // (populated with small angle approximation equation for demonstration purposes)
  const mathContainer = document.getElementById('equation-output');
  if (mathContainer) {

    let angleVal = 206265 * diam / dist;
    
    mathContainer.innerHTML =
      `$$\\alpha \\,=\\, ` + 
      `206,265 \\times \\frac{ \\text{linear diameter} }{ \\text{distance} } \\,=\\, ` + 
      angleVal.toLocaleString( undefined, { minimumFractionDigits: 1, maximumFractionDigits: 1 }) +
      `\\;\\text{arcsec}$$`;

    // Fire the asynchronous compilation task through MathJax
    if (window.MathJax && MathJax.typesetPromise) {
      MathJax.typesetPromise([mathContainer]).catch((err) => console.error(err));
    }

    updateAccessibleOutput(angleVal, dist, diam);
  }

};


function updateAccessibleOutput(angleVal, distVal, diamVal) {

  const live       = document.getElementById('sr-live-output');
  const figureDesc = document.getElementById('figure-description');
  const formatted  = angleVal.toLocaleString(undefined, {
    minimumFractionDigits: 1,
    maximumFractionDigits: 1
  });

  let message = 
    `Alpha equals 206,265 times linear diameter divided by distance, equal to ${formatted} arcseconds. ` + 
    `Distance ${distVal} units, diameter ${diamVal} unit`;
  if ( diamVal == 1 ) { message += `s.` } 
  else                { message += `.`  }

  if (live) {
    live.textContent       = message;
  }
  if (figureDesc) {
    figureDesc.textContent = message;
  }
}


