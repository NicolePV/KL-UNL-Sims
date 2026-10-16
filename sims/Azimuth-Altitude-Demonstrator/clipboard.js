function buildURL( flag )  {
  // Construct URL for user to use in future, to initialize simulation in
  // current state. 

  // Note that function cannot run asynchronously or build URL using hidden
  // elements due to security concerns, and under MacOS+Safari temporary
  // textArea must be readonly (to prevent a mobile keyboard pop-up).

  // http://astronomy.nmsu.edu/geas/klunl/sims/Azimuth-Altitude-Demonstrator/index.html?
  // theta=190&phi=28&alt=140&azi=45&labels=[0,0,0,0]&clean=1

  let i;
  let s0;

  const R2D   = 57.29577951308232;

  // URL parameters are theta and phi for celestial sphere, azimuth and altitude
  // for star, and visibility of four labels.
  const theta = Math.round( R2D*window.altAzApp.S.theta );
  const phi   = Math.round( R2D*window.altAzApp.S.phi   );
  const azi   = Math.round( document.getElementById('azNumber').value  );
  const alt   = Math.round( document.getElementById('altNumber').value );
  const zen   =            +document.getElementById('chkZenith').checked;
  const ndr   =            +document.getElementById('chkNadir').checked;
  const hor   =            +document.getElementById('chkHorizon').checked;
  const mrd   =            +document.getElementById('chkMeridian').checked;

  i = (window.location.href).indexOf('/sims/');
  if ( i > -1 )  { s0 = (window.location.href).substring( 0, i+6 );   }
  else           { s0 = 'http://astronomy.nmsu.edu/geas/klunl/sims/'; }

  s0 += 'Azimuth-Altitude-Demonstrator/index.html';    
  s0 += '?theta=' + theta + '&phi=' + phi;
  s0 += '&alt='   + alt   + '&azi=' + azi;
  s0 += '&labels=\[' + zen + ',' + ndr + ',' + hor + ',' + mrd + '\]';

  // User may show compete simulation, or only figure
  if ( flag === 1 )  { s0 += '&clean=1'; }

  // Create a temporary off-screen textarea for reliable selection of text
  const tempInput          = document.createElement('textarea');
  tempInput.value          = s0;
  tempInput.setAttribute('aria-hidden', 'true');
  tempInput.setAttribute('readonly', '');
  tempInput.style.position = 'fixed';
  tempInput.style.left     = '-9999px';
  tempInput.style.top      = '0';

  // Append textarea to modal dialog if it is open, otherwise fallback to body
  let container  = document.body;
  const masthead = document.querySelector('kl-unl-masthead');
  
  if (masthead && masthead.shadowRoot) {
    const dialog = masthead.shadowRoot.getElementById('settingsDialog-mh');
    if (dialog && dialog.hasAttribute('open')) {
      container = dialog;
    }
  }
  container.appendChild(tempInput);

  // Explicit focus is required by MacOS+Safari before select()
  tempInput.focus();
  tempInput.select();
  tempInput.setSelectionRange(0, 99999);
  
  // Select and copy synchronously within the active user gesture
  i = document.execCommand('copy');

  // Indicate successful placement of link on clipboard by disabling button
  if ( i )  {
    if      ( flag === 2 )  {
      masthead.shadowRoot.getElementById('urlConfirmAll').disabled = true;
      masthead.shadowRoot.getElementById('urlConfirmFig').disabled = false;
    } else if ( flag === 1 )  {
      masthead.shadowRoot.getElementById('urlConfirmAll').disabled = false;
      masthead.shadowRoot.getElementById('urlConfirmFig').disabled = true;
    }
  } else  {
      masthead.shadowRoot.getElementById('urlConfirmAll').disabled = false;
      masthead.shadowRoot.getElementById('urlConfirmFig').disabled = false;
  }

  // Clean up DOM
  container.removeChild(tempInput);

}
