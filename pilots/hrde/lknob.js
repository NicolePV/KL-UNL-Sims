// Setup.......................................................

// Functions...................................................

function windowToCanvasL(x, y) {
  var bboxL = lslider.getBoundingClientRect();

  return { x: x - bboxL.left * (lslider.width  / bboxL.width),
           y: y - bboxL.top  * (lslider.height / bboxL.height)
         };
};

function setLuminosityFromSlider(mouse)  {
  if (yMaxL < mouse.y && mouse.y < yMinL)  {
    y             = yMin - ( (yMin - yMax) * (mouse.x - xmrg) / (xMaxL - xMinL) );
    coords        = convert (x, y, 2);
    lSolar.value  = coords[1];
    newStar(1);
    setTimeout(newStar.bind(null,1), tOff);
  }
};

// Touch Event Handlers........................................

function isDraggingL (e) {
  var changed  = e.changedTouches.length,
      touching = e.touches.length;

  return changed === 1 && touching === 1;
}

lslider.ontouchstart = function (e) { 
  var changed  = e.changedTouches.length,
      touching = e.touches.length,
      touch1, mouse;

  e.preventDefault(e);

  if (isDraggingL(e)) {
    mouseDownOrTouchStartL(windowToCanvasL(e.pageX, e.pageY));
  }

  touch1 = e.touches.item(0);
  if ( (touch1.pageX > 0) && (touch1.pageY > 0) )  {
    mouse = windowToCanvasL(touch1.pageX, touch1.pageY);
    setLuminosityFromSlider(mouse);
  }
};

lslider.ontouchmove = function (e) { 
  var changed  = e.changedTouches.length,
      touching = e.touches.length,
      touch1;

  e.preventDefault(e);

  if (isDraggingL(e)) {
    touch1 = e.touches.item(0);
    mouseMoveOrTouchMoveL(windowToCanvasL(touch1.pageX, touch1.pageY));
  }
};

lslider.ontouchend = function (e) { 
  e.preventDefault(e);
  mouseUpOrTouchEndL(windowToCanvasL(e.pageX, e.pageY));
};

// Mouse Event Handlers........................................

lslider.onmousedown = function (e) { 
  var mouse;
  e.preventDefault(e);
  mouse = windowToCanvasL(e.clientX, e.clientY);
  mouseDownOrTouchStartL(mouse);
  setLuminosityFromSlider(mouse);
};

lslider.onmousemove = function (e) { 
  e.preventDefault(e);
  mouseMoveOrTouchMoveL(windowToCanvasL(e.clientX, e.clientY));
};

lslider.onmouseup = function (e) { 
  e.preventDefault(e);
  mouseUpOrTouchEndL(windowToCanvasL(e.clientX, e.clientY));
};

function mouseDownOrTouchStartL(mouse) {
  mousedown = { x: mouse.x, y: mouse.y, time: (new Date).getTime() };
  allowTrack = true;
};

function mouseMoveOrTouchMoveL(mouse) {
  if ( (yMaxL < mouse.y && mouse.y < yMinL) && (allowTrack || mobile) )  {
    mousemove     = { x: mouse.x, y: mouse.y, time: (new Date).getTime() }; 
    y             = yMin - ( (yMin - yMax) * (mouse.x - xmrg) / (xMaxL - xMinL) );
    coords        = convert (x, y, 2);
    lSolar.value  = coords[1];
    newStar(1);
    setTimeout(newStar.bind(null,1), tOff);
  }
};

function mouseUpOrTouchEndL(mouse) {
  mouseup = { x: mouse.x, y: mouse.y, time: (new Date).getTime() }; 
  allowTrack = false;
};
