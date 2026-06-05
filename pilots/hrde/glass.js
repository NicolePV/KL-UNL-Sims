// Setup.......................................................

var mousedown = null, mousemove = null, mouseup = null;

var tOff = 3000;                // maximum time after which dotted lines are removed from between cursor and axes
                                // (unless cursor has not been moved at all and is still at tSun, lSolar)

// Functions...................................................

function windowToCanvas(x, y) {
  var bbox = hrdc.getBoundingClientRect();

  return { x: x - bbox.left * (hrdc.width  / bbox.width),
           y: y - bbox.top  * (hrdc.height / bbox.height)
         };
};

function setCursorFromDiagram(mouse)  {
  if ( (xMin < mouse.x && mouse.x < xMax) && (yMax < mouse.y && mouse.y < yMin) )  {
    coords        = convert (mouse.x, mouse.y, 2);
    tKelvin.value = coords[0];
    lSolar.value  = coords[1];
    newStar(1);
    setTimeout(newStar.bind(null,1), tOff);
  }
};

// Touch Event Handlers........................................

function isDragging (e) {
  var changed  = e.changedTouches.length,
      touching = e.touches.length;

  return changed === 1 && touching === 1;
}

hrdc.ontouchstart = function (e) { 
  var changed  = e.changedTouches.length,
      touching = e.touches.length;

  e.preventDefault(e);

  if (isDragging(e)) {
    mouseDownOrTouchStart(windowToCanvas(e.pageX, e.pageY));
  }

  // Check for valid H-R Diagram coordinates (Android issue)
  // (use touch1.pageX/Y form as Android tablet needs it - iPad fine with e.pageX/Y)
  touch1 = e.touches.item(0);
  if ( (touch1.pageX > 0) && (touch1.pageY > 0) )  {
    setCursorFromDiagram(windowToCanvas(touch1.pageX, touch1.pageY));
  }
};

hrdc.ontouchmove = function (e) { 
  var changed  = e.changedTouches.length,
      touching = e.touches.length,
      touch1;

  e.preventDefault(e);

  if (isDragging(e)) {
    touch1 = e.touches.item(0);
 // mouseMoveOrTouchMove(windowToCanvas(e.pageX, e.pageY));
    mouseMoveOrTouchMove(windowToCanvas(touch1.pageX, touch1.pageY)); // needed for Android and Windows tablets
  }
};

hrdc.ontouchend = function (e) { 
  e.preventDefault(e);
  mouseUpOrTouchEnd(windowToCanvas(e.pageX, e.pageY));
};

// Mouse Event Handlers........................................

hrdc.onmousedown = function (e) { 
  var mouse;
  e.preventDefault(e);
  mouse = windowToCanvas(e.clientX, e.clientY);
  mouseDownOrTouchStart(mouse);
  setCursorFromDiagram(mouse);
};

hrdc.onmousemove = function (e) { 
  e.preventDefault(e);
  mouseMoveOrTouchMove(windowToCanvas(e.clientX, e.clientY));
};

hrdc.onmouseup = function (e) { 
  e.preventDefault(e);
  mouseUpOrTouchEnd(windowToCanvas(e.clientX, e.clientY));
};

function mouseDownOrTouchStart(mouse) {
  mousedown = { x: mouse.x, y: mouse.y, time: (new Date).getTime() };
};

function mouseMoveOrTouchMove(mouse) {
  if ( (xMin < mouse.x && mouse.x < xMax) && (yMax < mouse.y && mouse.y < yMin) && (allowTrack || mobile) )  {
    mousemove     = { x: mouse.x, y: mouse.y, time: (new Date).getTime() }; 
    coords        = convert (mouse.x, mouse.y, 2);
    tKelvin.value = coords[0];
    lSolar.value  = coords[1];
    newStar(1);
    setTimeout(newStar.bind(null,1), tOff);
  }
};

function mouseUpOrTouchEnd(mouse) {
  mouseup = { x: mouse.x, y: mouse.y, time: (new Date).getTime() }; 
};


// Initialization..............................................

hrdc.addEventListener('keydown', function (e) {
  var t = 1.1;
  var l = Math.pow( t, 4);
  if (e.keyCode == 16)  {
    allowTrack = true;                    // Hold down shift key to enable continuous (T,L) updates
  } else if (e.keyCode == 38)  {
    lSolar.value *= l;                    // Up    arrow key increases L
  } else if (e.keyCode == 40)  {
    lSolar.value /= l;                    // Down  arrow key decreases L
  } else if (e.keyCode == 37)  {
    tKelvin.value *= t;                   // Left  arrow key increases T
  } else if (e.keyCode == 39)  {
    tKelvin.value /= t;                   // Right arrow key decreases T
  }
  if (37 <= e.keyCode && e.keyCode <= 40)  {
    coords    = convert (tKelvin.value, lSolar.value, 1);
    mousedown = { x: coords[0], y: coords[1], time: (new Date).getTime() };
    newStar(1);
    setTimeout(newStar.bind(null,1), tOff);
  }
}, false);

hrdc.addEventListener('keyup', function (e) {
  allowTrack = false;
}, false);


/*
 * Copyright (C) 2012 David Geary. The magnifying glass portion of this 
 * code is from the book Core HTML5 Canvas, published by Prentice-Hall 
 * in 2012.
 *
 * License:
 *
 * Permission is hereby granted, free of charge, to any person 
 * obtaining a copy of this software and associated documentation files
 * (the "Software"), to deal in the Software without restriction,
 * including without limitation the rights to use, copy, modify, merge,
 * publish, distribute, sublicense, and/or sell copies of the Software,
 * and to permit persons to whom the Software is furnished to do so,
 * subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * The Software may not be used to create training material of any sort,
 * including courses, books, instructional videos, presentations, etc.
 * without the express written consent of David Geary.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
 */
