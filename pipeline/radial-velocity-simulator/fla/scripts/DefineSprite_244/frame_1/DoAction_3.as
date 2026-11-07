function onSliderPhaseChanged(phase)
{
   radialVelocityPlotMC.cursorPhase = phase;
   visualizationMC.setPhase(phase);
}
function toggleAnimationState()
{
   if(onEnterFrame == undefined)
   {
      animateButton.setLabel("pause animation");
      timeLast = getTimer();
      onEnterFrame = animationFunc;
   }
   else
   {
      animateButton.setLabel("start animation");
      delete onEnterFrame;
   }
}
function animationFunc()
{
   var timeNow = getTimer();
   var newPhase = ((phaseSlider.value + animationRateSlider.value * (timeNow - timeLast)) % 1 + 1) % 1;
   phaseSlider.value = newPhase;
   radialVelocityPlotMC.cursorPhase = newPhase;
   visualizationMC.setPhase(newPhase);
   timeLast = timeNow;
}
