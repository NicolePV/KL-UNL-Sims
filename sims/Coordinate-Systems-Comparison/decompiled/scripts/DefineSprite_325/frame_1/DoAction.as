function onReset()
{
   var _loc1_ = getTimer();
   if(animateButton.getLabel() == "pause animation")
   {
      toggleAnimation();
   }
   removeAllStars();
   animationRateSlider.value = 0.05;
   timedAnimationBox.setSelectedIndex(0);
   trailTypeGroup.setValue("none");
   showLabelsCheck.setValue(false);
   show0hCircleCheck.setValue(true);
   showCelestialEquatorCheck.setValue(true);
   showUnderCheck.setValue(true);
   neverRiseCheck.setValue(false);
   riseSetCheck.setValue(false);
   neverSetCheck.setValue(false);
   showAngleCheck.setValue(false);
   time = 0;
   setLocation({lat:40.8,lon:-96.7});
   sphere1.setThetaAndPhi(100,20);
   sphere2.setThetaAndPhi(145,30);
   sphere1.globeSphere.instance.setThetaAndPhi(sphere1.theta,sphere1.phi);
   update();
   sphere1.update();
   sphere2.update();
   trace("onReset: " + (getTimer() - _loc1_));
}
