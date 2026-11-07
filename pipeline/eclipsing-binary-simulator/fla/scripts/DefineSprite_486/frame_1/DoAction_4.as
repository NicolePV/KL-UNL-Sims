function openHRDiagramWindow()
{
   hrDiagramWindowMC._visible = true;
}
function changeAnimateState()
{
   if(onEnterFrame == onEnterFrameFunc)
   {
      animationButton.setLabel("start animation");
      delete onEnterFrame;
   }
   else
   {
      animationButton.setLabel("pause animation");
      timeLast = getTimer();
      onEnterFrameFunc();
      onEnterFrame = onEnterFrameFunc;
   }
}
function onEnterFrameFunc()
{
   var timeNow = getTimer();
   setPhase(curveMC.cursorPhase + (timeNow - timeLast) * animationSpeedSlider.value);
   timeLast = timeNow;
}
function setPhase(arg)
{
   arg = (arg % 1 + 1) % 1;
   curveMC.setCursorPhase(arg);
   phaseSlider.value = arg;
   visualizationMC.phase = arg + curveMC._closestIndex / curveMC._numCurvePoints;
}
