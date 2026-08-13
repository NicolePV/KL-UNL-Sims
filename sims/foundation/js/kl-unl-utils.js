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

export const D2R     =  0.017453292519943295;  // Degrees → radians
export const R2D     = 57.29577951308232;      // Radians → degrees
export const H2R     =  0.2617993877991494;    // Hours   → radians (15° per hour)
export const R2H     =  3.819718634205488;     // Radians → hours

export const PI      =  3.141592653589793;
export const TWO_PI  =  6.283185307179586;
export const HALF_PI =  1.5707963267948966;
export const QURT_PI =  0.7853981633974483;
export const SXTH_PI =  0.5235987755982989;

export function pMod(n, m) {
  // Positive modulo
  return ((n % m) + m) % m;
};

export function clamp(x, xmin, xmax) {
  return Math.min(Math.max(x, xmin), xmax);
};

export function snapFixed(x, digits, xmin=0, xmax=0) {
  // Quantize values with step size via precision
  if ( xmin != xmax )  {
    x = clamp(x, xmin, xmax);
  }
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
  const min = Number(slider.min)   ||   0;
  const max = Number(slider.max)   || 100;
  const val = Number(slider.value) ||   0;
  const span = max - min;
  const pct = span === 0 ? 0 : ((val - min) / span) * 100;
  slider.style.setProperty('--slider-progress', `${pct}%`);
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
