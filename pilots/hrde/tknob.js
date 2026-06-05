// Setup.......................................................

// Functions...................................................

function windowToCanvasT(x, y) {
  var bboxT = tslider.getBoundingClientRect();

  return { x: x - bboxT.left * (tslider.width  / bboxT.width),
           y: y - bboxT.top  * (tslider.height / bboxT.height)
         };
};

function setTemperatureFromSlider(mouse)  {
  if (yMaxT < mouse.y && mouse.y < yMinT)  {
    x             = xMax - ( (xMax - xMin) * (mouse.x - xmrg) / (xMaxT - xMinT) );
    coords        = convert (x, mouse.y, 2);
    tKelvin.value = coords[0];
    newStar(1);
    setTimeout(newStar.bind(null,1), tOff);
  }
};

// Touch Event Handlers........................................

function isDraggingT (e) {
  var changed  = e.changedTouches.length,
      touching = e.touches.length;

  return changed === 1 && touching === 1;
}

tslider.ontouchstart = function (e) { 
  var changed  = e.changedTouches.length,
      touching = e.touches.length,
      touch1, mouse;

  e.preventDefault(e);

  if (isDraggingT(e)) {
    mouseDownOrTouchStartT(windowToCanvasT(e.pageX, e.pageY));
  }

  touch1 = e.touches.item(0);
  if ( (touch1.pageX > 0) && (touch1.pageY > 0) )  {
    mouse = windowToCanvasT(touch1.pageX, touch1.pageY);
    setTemperatureFromSlider(mouse);
  }
};

tslider.ontouchmove = function (e) { 
  var changed  = e.changedTouches.length,
      touching = e.touches.length,
      touch1;

  e.preventDefault(e);

  if (isDraggingT(e)) {
    touch1 = e.touches.item(0);
    mouseMoveOrTouchMoveT(windowToCanvasT(touch1.pageX, touch1.pageY));
  }
};

tslider.ontouchend = function (e) { 
  e.preventDefault(e);
  mouseUpOrTouchEndT(windowToCanvasT(e.pageX, e.pageY));
};

// Mouse Event Handlers........................................

tslider.onmousedown = function (e) { 
  var mouse;
  e.preventDefault(e);
  mouse = windowToCanvasT(e.clientX, e.clientY);
  mouseDownOrTouchStartT(mouse);
  setTemperatureFromSlider(mouse);
};

tslider.onmousemove = function (e) { 
  e.preventDefault(e);
  mouseMoveOrTouchMoveT(windowToCanvasT(e.clientX, e.clientY));
};

tslider.onmouseup = function (e) { 
  e.preventDefault(e);
  mouseUpOrTouchEndT(windowToCanvasT(e.clientX, e.clientY));
};

function mouseDownOrTouchStartT(mouse) {
  mousedown = { x: mouse.x, y: mouse.y, time: (new Date).getTime() };
  allowTrack = true;
};

function mouseMoveOrTouchMoveT(mouse) {
  if ( (yMaxT < mouse.y && mouse.y < yMinT) && (allowTrack || mobile) )  {
    mousemove     = { x: mouse.x, y: mouse.y, time: (new Date).getTime() }; 
    x             = xMax - ( (xMax - xMin) * (mouse.x - xmrg) / (xMaxT - xMinT) );
    coords        = convert (x, mouse.y, 2);
    tKelvin.value = coords[0];
    newStar(1);
    setTimeout(newStar.bind(null,1), tOff);
  }
};

function mouseUpOrTouchEndT(mouse) {
  mouseup = { x: mouse.x, y: mouse.y, time: (new Date).getTime() }; 
  allowTrack = false;
};
