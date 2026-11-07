function onEnterFrameFunc()
{
   var _loc1_ = getTimer();
   var _loc2_ = time;
   time += animationRateSlider.value * (_loc1_ - timeLast) / 1000;
   if(animateTill != null && time > animateTill)
   {
      time = animateTill;
      toggleAnimation();
   }
   timeLast = _loc1_;
   update();
   growStarTrails(360 * (time - _loc2_));
}
function pauseAnimation()
{
   delete onEnterFrame;
}
function resumeAnimation()
{
   if(animateButton.getLabel() == "pause animation")
   {
      timeLast = getTimer();
      onEnterFrame = onEnterFrameFunc;
      startSiderealTime = sphere2.siderealTime;
   }
}
function toggleAnimation()
{
   var _loc1_;
   if(animateButton.getLabel() == "pause animation")
   {
      animateButton.setLabel("start animation");
      timedAnimationBox.setEnabled(true);
      pauseAnimation();
   }
   else
   {
      _loc1_ = parseInt(timedAnimationBox.getValue());
      if(_loc1_ == 0)
      {
         animateTill = null;
      }
      else
      {
         animateTill = time + _loc1_ / 24;
      }
      timedAnimationBox.setEnabled(false);
      animateButton.setLabel("pause animation");
      resumeAnimation();
   }
}
timedAnimationBox.setStyleProperty("backgroundDisabled",14737632);
timedAnimationBox.setStyleProperty("textDisabled",6316128);
