function changeShowLabels()
{
   var _loc1_ = showLabelsCheck.getValue();
   var _loc2_ = _loc1_ && show0hCircleCheck.getValue();
   var _loc3_ = _loc1_ && showCelestialEquatorCheck.getValue();
   sphere1.celestialEquatorLabel.visible = _loc3_;
   sphere2.celestialEquatorLabel.visible = _loc3_;
   sphere1.zeroHoursLabel.visible = _loc2_;
   sphere2.zeroHoursLabel.visible = _loc2_;
   sphere1.ncpLabel.visible = _loc1_;
   sphere1.scpLabel.visible = _loc1_;
   sphere2.ncpLabel.visible = _loc1_;
   sphere2.scpLabel.visible = _loc1_;
   sphere2.meridianLabel.visible = _loc1_;
   sphere2.zenithLabel.visible = _loc1_;
   sphere2.nadirLabel.visible = _loc1_;
   sphere2.zenithDot.visible = _loc1_;
   sphere2.nadirDot.visible = _loc1_;
   if(_loc1_)
   {
      sphere1.updateObjects();
      sphere2.updateObjects();
   }
}
function changeShow0hCircle()
{
   var _loc1_ = show0hCircleCheck.getValue();
   var _loc2_ = _loc1_ && showLabelsCheck.getValue();
   sphere1.zeroHoursCircle.visible = _loc1_;
   sphere2.zeroHoursCircle.visible = _loc1_;
   sphere1.zeroHoursLabel.visible = _loc2_;
   sphere2.zeroHoursLabel.visible = _loc2_;
   if(_loc2_)
   {
      sphere1.updateObjects();
      sphere2.updateObjects();
   }
}
function changeShowCelestialEquator()
{
   var _loc1_ = showCelestialEquatorCheck.getValue();
   var _loc2_ = _loc1_ && showLabelsCheck.getValue();
   sphere1.celestialEquator.visible = _loc1_;
   sphere2.celestialEquator.visible = _loc1_;
   sphere1.celestialEquatorLabel.visible = _loc2_;
   sphere2.celestialEquatorLabel.visible = _loc2_;
   if(_loc2_)
   {
      sphere1.updateObjects();
      sphere2.updateObjects();
   }
}
function changeShowUnder()
{
   sphere2.showUnder = showUnderCheck.getValue();
}
function changeShowRiseSet()
{
   sphere2.riseAndSetBand.visible = riseSetCheck.getValue();
   sphere1.riseAndSetBand.visible = riseSetCheck.getValue();
}
function changeShowNeverSet()
{
   sphere2.neverSetBand.visible = neverSetCheck.getValue();
   sphere1.neverSetBand.visible = neverSetCheck.getValue();
}
function changeShowNeverRise()
{
   sphere2.neverRiseBand.visible = neverRiseCheck.getValue();
   sphere1.neverRiseBand.visible = neverRiseCheck.getValue();
}
function changeShowAngle()
{
   var _loc1_ = showAngleCheck.getValue();
   if(_loc1_)
   {
      updateAngle();
   }
   sphere2.angle1Label.visible = _loc1_;
   sphere2.angle2Label.visible = _loc1_;
   sphere2.angle1Circle.visible = _loc1_;
   sphere2.angle2Circle.visible = _loc1_;
   if(_loc1_)
   {
      sphere2.updateObjects();
   }
}
showLabelsCheck.setStyleProperty("textSize",11);
show0hCircleCheck.setStyleProperty("textSize",11);
showCelestialEquatorCheck.setStyleProperty("textSize",11);
showUnderCheck.setStyleProperty("textSize",11);
neverRiseCheck.setStyleProperty("textSize",11);
riseSetCheck.setStyleProperty("textSize",11);
neverSetCheck.setStyleProperty("textSize",11);
showAngleCheck.setStyleProperty("textSize",11);
