/**
 * Initializes listeners once the DOM and MathJax are prepared
 */
function initCalculator() {
  const form = document.getElementById('calc-form');
  if (form) {
    form.addEventListener('input', updateEquation);
  }
  // Run an initial calculation on page load
  updateEquation();
}

/**
 * Handles processing input metrics, formatting LaTeX, and syncing live aria alerts.
 */
function updateEquation() {

  // Force L and T to both be non-negative values
  document.getElementById('num1').value = Math.abs( document.getElementById('num1').value );
  document.getElementById('num2').value = Math.abs( document.getElementById('num2').value );

  // Force L to be integer value if larger than or equal to 100
  let npl = 0;
  if        ( document.getElementById('num1').value >= 100 )  { 
    document.getElementById('num1').value = Math.round( document.getElementById('num1').value );
    npl = 0;

  // Force L to run to at most 3 decimal places if larger than or equal to 10
  } else if ( document.getElementById('num1').value >=  10 )  {
    if ( document.getElementById('num1').value.length > 6 )  {
      npl = 3;
      document.getElementById('num1').value = parseFloat(document.getElementById('num1').value).toFixed(npl);
    } else  {
      npl =  Math.max( document.getElementById('num1').value.length - 3, 0 );
    }

  // Force L to run to at most 4 decimal places if larger than or equal to 1
  } else if ( document.getElementById('num1').value >=   1 )  {
    if ( document.getElementById('num1').value.length > 6 )  {
      npl = 4;
      document.getElementById('num1').value = parseFloat(document.getElementById('num1').value).toFixed(npl);
    } else  {
      npl = Math.max( document.getElementById('num1').value.length - 2, 0 );
    }

  // Force L to run to at most 6 decimal places if less than 1
  } else  {
    if ( document.getElementById('num1').value.length > 8 )  { 
      npl = 6;
      document.getElementById('num1').value = parseFloat(document.getElementById('num1').value).toFixed(npl);
    } else  {
      npl = Math.max( document.getElementById('num1').value.length - 2, 0 );
    }
  }
  
  // Force T to be integer value
  document.getElementById('num2').value = Math.round( document.getElementById('num2').value );
  
  const n1 = parseFloat(document.getElementById('num1').value);
  const n2 = parseFloat(document.getElementById('num2').value);

  const n3 = 5800;
  let   np =    0;
  let   s0;

  // Format L and T with commas (or follow other local convention)
  const showL = addCommas( n1, npl );
  const showT = addCommas( n2,   0 );

  // Stop execution gracefully if input elements are currently blank
  if ( isNaN( n1 ) || isNaN( n2 ) ) return;

  // Calculate radius
  let radius  = 0;
  const ratio = n2 / n3;
  if ( ratio !== 0 ) { radius = Math.sqrt( n1 ) / Math.pow( ratio, 2 ); }

  // Sanitize the resulting numeric string
  const frmRadius = Number( radius.toFixed(4) ).toString();

  // 1. Target Visual Element & Format New LaTeX Formula
  const mathContainer = document.getElementById('equation-output');
  if (mathContainer) {
    s0  = `$$\\text{Radius} = `;
    s0 += `\\frac{ \\sqrt{ L } }{ \\left( \\frac{ T }{ T_{\\odot} } \\right)^2 } = `;
    s0 += `\\frac{ \\sqrt{ ${showL} } }{ \\left( \\frac{ ${showT} }{` + addCommas(n3,0) + `} \\right)^2 } = `;
    s0 += `${frmRadius}$$`;

    mathContainer.innerHTML = s0;

    // Fire the asynchronous compilation task through MathJax
    if (window.MathJax && MathJax.typesetPromise) {
      MathJax.typesetPromise([mathContainer]).catch((err) => console.error(err));
    }
  }

  // 2. Sync Screen Reader Live Region Text
  const liveRegion = document.getElementById('sr-live-output');
  if (liveRegion) {
    liveRegion.textContent = `The updated radius value is ${frmRadius}. The equation is: the square root of the fraction with numerator ${showL} (luminosity in solar units) and denominator: the square of the ratio of ${showT} over 5800 (temperature in solar units).`;
  }
}

function addCommas( value, n )  {

  // Add commas before thousand's place (in USA), etc. for readability, 
  // and keep fixed number of places past decimal point.

  let s0;

  s0    = parseFloat(value).toFixed( n );
  s0    = s0.split('.');
  s0[0] = parseInt(s0[0]).toLocaleString();

  return s0.join('.');

}
