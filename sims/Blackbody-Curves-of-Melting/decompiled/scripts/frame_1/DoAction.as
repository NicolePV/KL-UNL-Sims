function pauseAnimation()
{
   delete onEnterFrame;
   state = "paused";
   update();
}
function startAnimation()
{
   onEnterFrame = animateOnEnterFrame;
   state = "animating";
   update();
}
function stopAnimation()
{
   delete onEnterFrame;
   frameSlider.value = frameSlider.maxValue;
   state = "atEnd";
   update();
}
function restartAnimation()
{
   onEnterFrame = animateOnEnterFrame;
   frameSlider.value = 1;
   state = "animating";
   update();
}
function resetAnimation()
{
   delete onEnterFrame;
   frameSlider.value = 1;
   state = "atStart";
   update();
}
function onFrameChangedViaSlider()
{
   if(frameSlider.value == 1)
   {
      resetAnimation();
   }
   else if(frameSlider.value >= frameSlider.maxValue)
   {
      stopAnimation();
   }
   else
   {
      pauseAnimation();
   }
}
function onAnimationButtonPressed()
{
   if(state == "atStart" || state == "paused")
   {
      startAnimation();
   }
   else if(state == "animating")
   {
      pauseAnimation();
   }
   else
   {
      restartAnimation();
   }
}
function animateOnEnterFrame()
{
   frameSlider.value++;
   if(frameSlider.value >= frameSlider.maxValue)
   {
      stopAnimation();
   }
   else
   {
      update();
   }
}
function update()
{
   nailMovie.gotoAndStop(frameSlider.value);
   if(state == "atStart")
   {
      animationButton.setLabel("start");
   }
   else if(state == "animating")
   {
      animationButton.setLabel("pause");
   }
   else if(state == "paused")
   {
      animationButton.setLabel("resume");
   }
   else
   {
      animationButton.setLabel("restart");
   }
   var _loc1_;
   if(frameSlider.value == 1)
   {
      _loc1_ = 300;
   }
   else if(frameSlider.value <= snapFrame)
   {
      _loc1_ = 800 + 1000 / snapFrame * frameSlider.value;
   }
   else if(frameSlider.value < frameSlider.maxValue)
   {
      _loc1_ = 1800 - 1000 / (frameSlider.maxValue - snapFrame) * (frameSlider.value - snapFrame);
   }
   else
   {
      _loc1_ = 300;
   }
   temperatureField.text = Math.floor(_loc1_) + " K";
   if(_loc1_ <= 800)
   {
      bbPlotInset.bbCurve.peakHeight = 0;
   }
   else
   {
      bbPlotInset.bbCurve.peakHeight = (_loc1_ - 800) / 1000;
   }
   bbPlotInset.bbCurve.temperature = _loc1_;
   bbPlotInset.update();
   bbPlot.bbCurve.temperature = _loc1_;
   bbPlot.update();
}
function init()
{
   bbPlotInset.setVerticalScalingMode("custom");
   bbPlotInset.bbCurve.showFill = true;
   bbPlotInset.bbCurve.setStyle({fillColor:12632256});
   bbPlot.setVerticalScalingMode("locked");
   bbPlot.maxBrightness = 183955504.96;
   bbPlot.bbCurve.showFill = true;
   bbPlot.bbCurve.setStyle({fillColor:12632256});
   frameSlider.maxValue = nailMovie._totalframes;
   frameSlider.update();
   resetAnimation();
}
snapFrame = 429;
init();
