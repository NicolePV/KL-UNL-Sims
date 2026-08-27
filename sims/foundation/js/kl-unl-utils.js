/* ===========================================================================
   KL-UNL shared utilities
   =========================================================================== */

/* ===========================================================================
   Format functions
   =========================================================================== */

export function legToFixed(x, fractionDigits=0) {
  // Legacy version of modern toFixed (checks value, number of digits)
  const loLim =  0;
  const hiLim = 20;
  const f     = Math.trunc(fractionDigits);
  const nmb   = Number(x);
  
  if ( f < loLim || hiLim < f || !Number.isFinite(nmb) ) { return 'Input Error';  }
  else                                                   { return nmb.toFixed(f); }
};

export function speak( value, prec=0, unit='' )  {
  // Create screen reader text for value and unit for variable, 
  // such as "7.0 mass units" or "1 meter" or "minus 4.56"
  
  let name = legToFixed(value, prec);
  // Force voice to say each digit after decimal point ("4" "5" rather than "45")
  // Turn 23.45 from twenty-three point forty-five into twenty-three point four five
  if ( name.includes(".") )  {
    let i = name.indexOf(".");
    for ( let j = name.length - 1; j >= i+1; j-- )  {
      name = name.substring(0, j) + ' ' + name.substring(j);
     }
    name = name.substring(0, i ) + ' point ' + name.substring(i+1).trimStart();
  }
  // Spell out "minus" for minus sign
  if ( value < 0 )  { name = 'minus ' + name.slice(1).trimStart(); }
  // Don't pluralize unit for integer values of unity
  if (unit != '')  { 
    const uname = ( (Math.abs(parseFloat(value)) == 1) && (prec == 0) ) ? unit : unit + 's';
    name += ' ' + uname;
  }
  return name;
};


/* ===========================================================================
   Math functions
   =========================================================================== */

export function pMod(n, m) {
  // Positive modulo
  return ((n % m) + m) % m;
};

export function clamp(x, xmin, xmax) {
  // Apply limits to value
  return Math.min(Math.max(x, xmin), xmax);
};

export function snapFixed(x, digits, xmin=0, xmax=0) {
  // Quantize values with step size via precision
  if ( xmin != xmax )  { x = clamp(x, xmin, xmax); }
  const step = Math.pow(10, -digits);
  return step * Math.round(x / step);
};


/* ===========================================================================
   Keyboard functions
   =========================================================================== */

export function amplifyArrowKey(event, element, fctr)  {
  // Amplify slider (or similar) arrow-key steps by fctr when Shift is held.
  // Caps Lock also amplifies for users who leave it on while arrowing.
  if (!['ArrowUp', 'ArrowDown', 'ArrowLeft', 'ArrowRight'].includes(event.key)) { return; }
  if ( (event.shiftKey) || (event.getModifierState('CapsLock')) )  {
    const step = parseFloat(element.step) || 0.1;
    const min  = parseFloat(element.min);
    const max  = parseFloat(element.max);
    const delt = fctr * step;
    let   val  = parseFloat(element.value);

    if      ( (event.key === 'ArrowUp'  ) || (event.key === 'ArrowRight') )  { val += delt; }
    else if ( (event.key === 'ArrowDown') || (event.key === 'ArrowLeft' ) )  { val -= delt; }

    element.value = Math.min( Math.max( val, min + step ), max - step );
  }
};


/* ===========================================================================
   Style functions
   =========================================================================== */

export function updateSliderProgress(slider) {
  // Fill in slider bar to left of thumb
  const min  = Number(slider.min)   ||   0;
  const max  = Number(slider.max)   || 100;
  const val  = Number(slider.value) ||   0;
  const span = max - min;
  const pct  = span === 0 ? 0 : ((val - min) / span) * 100;
  slider.style.setProperty('--slider-progress', `${pct}%`);
};

export function decToHex(n) {
  // Convert decimal color to hex ( 10893123 --> #a63743 )
  return '#' + ('000000' + (n >>> 0).toString(16)).slice(-6);
};

export function hexToRGBA(hexVal='#ffffff', alpha=1.0)  {
  // Convert hex color and optional transparency value to RGBA format
  // ( #a1b3fe --> rgba(161, 179, 254, 1) )
  // 
  // Defaults to white and full transparency if neither hex nor dec
  let clr, nmb;

  // Examine hex color
  clr = hexVal.toString().replace( '#', '' );
  if ( clr.length === 3 )  clr = clr.split('').map(char => char + char).join('');  // abd --> aabbdd

  // Examine transparency
  if ( !Number.isFinite( alpha ) )  { alpha  =   1; }
  if ( 1 < alpha && alpha <= 100 )  { alpha /= 100; }
  alpha = Math.min( Math.max( alpha, 0 ), 1 );
  
  // Treat 6-char values as hex
  if ( clr.length === 6 )  {
    nmb = parseInt( clr, 16 );
  // Otherwise attempt to treat as decimal value
  } else if ( ( Number.isFinite( parseInt(clr) ) ) &&
              ( 0 <= parseInt(clr) ) && ( parseInt(clr) <= 16777215 ) )  {
    nmb = parseInt( clr );
  // Otherwise treat as white
  } else  {
    nmb = 'ffffff';
  }
  
  return `rgba(${nmb >> 16}, ${(nmb >> 8) & 255}, ${nmb & 255}, ${alpha})`;
};


/* ===========================================================================
   Scheduling and live regions
   =========================================================================== */

export function soon(callback, timeoutMs=60) {
  // Run once on the sooner of the next animation frame or a short timer.
  // requestAnimationFrame alone may never fire in a background / uncomposited tab.
  let done = false;
  const run = function () {
    if (done) { return; }
    done = true;
    callback();
  };
  window.requestAnimationFrame(run);
  window.setTimeout(run, timeoutMs);
};

export function announceLive(liveEl, message, delayMs=100) {
  // Flush a polite live region so identical consecutive strings still announce.
  if (!liveEl) { return; }
  liveEl.setAttribute('aria-hidden', 'true');
  liveEl.textContent = '';
  window.setTimeout(function () {
    liveEl.removeAttribute('aria-hidden');
    liveEl.textContent = message;
  }, delayMs);
};


/* ===========================================================================
   Drawing functions
   =========================================================================== */

export function drawArrowhead(ctx, tip, delta, fcolor='', scolor='')  {
  // Draw horizontal arrowhead as filled triangle between tip(x1,y1), 
  // tip + delta(x2,y2), and tip + delta(x2,-y2). Default to current color.
  if (fcolor != '')  { ctx.fillStyle   = fcolor; }
  if (scolor != '')  { ctx.strokeStyle = scolor; }
  ctx.beginPath();
  ctx.moveTo(tip[0],tip[1]);
  ctx.lineTo(tip[0] + delta[0], tip[1] + delta[1]);
  ctx.lineTo(tip[0] + delta[0], tip[1] - delta[1]);
  ctx.lineTo(tip[0],tip[1]);
  ctx.fill();
  ctx.stroke();
};


/* ===========================================================================
   GEAS logging function
   =========================================================================== */

export function logAct( s0 )  {

  // Load tiny (4KB) image to create entry in server access log
  const tstamp = Math.round( 0.001 * Date.now() );
  let s1       = "../foundation/images/klunl_ping.png" + "?" + s0 + "_" + tstamp;
  let image    = new Image();
  image.src    = s1;

  // Insert log entry into server access logs as tiny image request once per session 
  //  - Identify web browser
  //  - Identify platform
  //  - Check for mobile device
  //  - Log os+browser and window and screen size information

  let navAgent = 'Safari', windowsBox = false, mobile = false;

  let i;
  let s2, s3, s4, s5;

  // Identify web browser (relevant when saving data file on local disk)
  s0       = navigator.userAgent;
  if      (s0.indexOf('Opera'  ) != -1)  {navAgent = 'Opera'  }
  else if (s0.indexOf('OPR'    ) != -1)  {navAgent = 'Opera'  }
  else if (s0.indexOf('Firefox') != -1)  {navAgent = 'Firefox'}
  else if (s0.indexOf('Chrome' ) != -1)  {navAgent = 'Chrome' } // note Chrome broadcasts Safari as well
  else if (s0.indexOf('MSIE'   ) != -1)  {navAgent = 'IE'     }
  else if (s0.indexOf('NET'    ) != -1)  {navAgent = 'IE'     }
       if (s0.indexOf('Android') != -1)  {navAgent = 'Android'} // Android tablet records as Chrome otherwise

  // Identify platform (relevant when saving data file on local disk)
  if (s0.match(/Windows/i))  { windowsBox = true; }

  // Check for mobile device (added entries for tablets)
  (function(a){if(/(android|bb\d+|meego).+mobile|android|ipad|playbook|silk|avantgo|bada\/|blackberry|blazer|compal|elaine|fennec|hiptop|iemobile|ip(hone|od)|iris|kindle|lge |maemo|midp|mmp|mobile.+firefox|netfront|opera m(ob|in)i|palm( os)?|phone|p(ixi|re)\/|plucker|pocket|psp|series(4|6)0|symbian|treo|up\.(browser|link)|vodafone|wap|windows ce|xda|xiino/i.test(a)||/1207|6310|6590|3gso|4thp|50[1-6]i|770s|802s|a wa|abac|ac(er|oo|s\-)|ai(ko|rn)|al(av|ca|co)|amoi|an(ex|ny|yw)|aptu|ar(ch|go)|as(te|us)|attw|au(di|\-m|r |s )|avan|be(ck|ll|nq)|bi(lb|rd)|bl(ac|az)|br(e|v)w|bumb|bw\-(n|u)|c55\/|capi|ccwa|cdm\-|cell|chtm|cldc|cmd\-|co(mp|nd)|craw|da(it|ll|ng)|dbte|dc\-s|devi|dica|dmob|do(c|p)o|ds(12|\-d)|el(49|ai)|em(l2|ul)|er(ic|k0)|esl8|ez([4-7]0|os|wa|ze)|fetc|fly(\-|_)|g1 u|g560|gene|gf\-5|g\-mo|go(\.w|od)|gr(ad|un)|haie|hcit|hd\-(m|p|t)|hei\-|hi(pt|ta)|hp( i|ip)|hs\-c|ht(c(\-| |_|a|g|p|s|t)|tp)|hu(aw|tc)|i\-(20|go|ma)|i230|iac( |\-|\/)|ibro|idea|ig01|ikom|im1k|inno|ipaq|iris|ja(t|v)a|jbro|jemu|jigs|kddi|keji|kgt( |\/)|klon|kpt |kwc\-|kyo(c|k)|le(no|xi)|lg( g|\/(k|l|u)|50|54|\-[a-w])|libw|lynx|m1\-w|m3ga|m50\/|ma(te|ui|xo)|mc(01|21|ca)|m\-cr|me(rc|ri)|mi(o8|oa|ts)|mmef|mo(01|02|bi|de|do|t(\-| |o|v)|zz)|mt(50|p1|v )|mwbp|mywa|n10[0-2]|n20[2-3]|n30(0|2)|n50(0|2|5)|n7(0(0|1)|10)|ne((c|m)\-|on|tf|wf|wg|wt)|nok(6|i)|nzph|o2im|op(ti|wv)|oran|owg1|p800|pan(a|d|t)|pdxg|pg(13|\-([1-8]|c))|phil|pire|pl(ay|uc)|pn\-2|po(ck|rt|se)|prox|psio|pt\-g|qa\-a|qc(07|12|21|32|60|\-[2-7]|i\-)|qtek|r380|r600|raks|rim9|ro(ve|zo)|s55\/|sa(ge|ma|mm|ms|ny|va)|sc(01|h\-|oo|p\-)|sdk\/|se(c(\-|0|1)|47|mc|nd|ri)|sgh\-|shar|sie(\-|m)|sk\-0|sl(45|id)|sm(al|ar|b3|it|t5)|so(ft|ny)|sp(01|h\-|v\-|v )|sy(01|mb)|t2(18|50)|t6(00|10|18)|ta(gt|lk)|tcl\-|tdg\-|tel(i|m)|tim\-|t\-mo|to(pl|sh)|ts(70|m\-|m3|m5)|tx\-9|up(\.b|g1|si)|utst|v400|v750|veri|vi(rg|te)|vk(40|5[0-3]|\-v)|vm40|voda|vulc|vx(52|53|60|61|70|80|81|83|85|98)|w3c(\-| )|webc|whit|wi(g |nc|nw)|wmlb|wonu|x700|yas\-|your|zeto|zte\-/i.test(a.substr(0,4))) mobile = true;})(navigator.userAgent||navigator.vendor||window.opera);
  
  // Insert log entry into server logs as tiny image request once per session 
  // with os+browser and window and screen size information to help better match available display resources
  if ( mobile )  { i = 1; } else  { i = 0; }
  s0 = navigator.platform || "unk";
  s1 = navigator.appName  || "unk";
  s2 = window.innerWidth  || document.documentElement.clientWidth  || document.body.clientWidth  || "unk";
  s3 = window.screen.availWidth  || "unk";
  s4 = window.innerHeight || document.documentElement.clientHeight || document.body.clientHeight || "unk";
  s5 = window.screen.availHeight || "unk";
  s0 = "INIT_PL" + s0 + "_MB" + i + "_AP" + s1 + "_WDU" + s2 + "_WDA" + s3 + "_HTU" + s4 + "_HTA" + s5 + "_NV" + navAgent;

  s1        = "../foundation/images/klunl_ping.png" + "?" + s0 + "_" + tstamp;
  image     = new Image();
  image.src = s1;

};
