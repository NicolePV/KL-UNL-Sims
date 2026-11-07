function onReset()
{
   if(sysMC.animate)
   {
      changeAnimate();
   }
   memoryRecallButton.setEnabled(false);
   sysMC._anomaly = 0;
   sysMC._sunAngle = 0;
   planetListBox.setSelectedIndex(1);
   setPresets();
   var _loc1_ = 100;
   rateSlider.value = _loc1_;
   changeAnimationRate(_loc1_);
   var _loc2_ = 2.5;
   pathDurationSlider.value = _loc2_;
   changePathTime(_loc2_);
   showEpicycleCheck.setValue(true);
   showDeferentCheck.setValue(true);
   showPlanetVectorCheck.setValue(false);
   showEquantVectorCheck.setValue(false);
   showEarthSunLineCheck.setValue(false);
   showEpicyclePlanetLineCheck.setValue(false);
}
function memoryStore()
{
   var _loc1_ = this;
   _loc1_.memoryObject = {};
   _loc1_.memoryObject.eccentricity = eccentricitySlider.value;
   _loc1_.memoryObject.epicycleRadius = epicycleSizeSlider.value;
   _loc1_.memoryObject.apogeeAngle = apogeeAngleSlider.value;
   _loc1_.memoryObject.motionRate = motionRateSlider.value;
   _loc1_.memoryObject.planetType = planetTypeGroup.getValue();
   _loc1_.memoryObject._anomaly = sysMC._anomaly;
   _loc1_.memoryObject._sunAngle = sysMC._sunAngle;
   memoryRecallButton.setEnabled(true);
}
function memoryRecall()
{
   var _loc1_ = this;
   sysMC.animate = false;
   animateButton.setLabel("start animation");
   currentlySettingPresets = true;
   sysMC._anomaly = _loc1_.memoryObject._anomaly;
   sysMC._sunAngle = _loc1_.memoryObject._sunAngle;
   sysMC.setEpicycleRadius(_loc1_.memoryObject.epicycleRadius * 100);
   sysMC.setEccentricity(_loc1_.memoryObject.eccentricity * 100);
   sysMC.setApogeeAngle(_loc1_.memoryObject.apogeeAngle);
   sysMC.setAnomalyRate(_loc1_.memoryObject.motionRate);
   sysMC.setPlanetType(_loc1_.memoryObject.planetType);
   updateSys();
   planetTypeGroup.setValue(_loc1_.memoryObject.planetType);
   eccentricitySlider.value = _loc1_.memoryObject.eccentricity;
   apogeeAngleSlider.value = _loc1_.memoryObject.apogeeAngle;
   motionRateSlider.value = _loc1_.memoryObject.motionRate;
   epicycleSizeSlider.value = _loc1_.memoryObject.epicycleRadius;
   currentlySettingPresets = false;
   setPresetsButton.setEnabled(true);
}
function updateSys()
{
   sysMC.update();
   sysMC.updatePath();
   sysMC.updateZodiacStrip();
}
function enableButton()
{
   setPresetsButton.setEnabled(true);
}
function setPresets()
{
   currentlySettingPresets = true;
   var _loc1_ = planetData[planetListBox.getSelectedIndex()];
   sysMC.setEpicycleRadius(_loc1_.epicycleRadius * 100);
   sysMC.setEccentricity(_loc1_.eccentricity * 100);
   sysMC.setApogeeAngle(_loc1_.apogeeAngle);
   sysMC.setAnomalyRate(_loc1_.motionRate);
   sysMC.setPlanetType(_loc1_.planetType);
   updateSys();
   planetTypeGroup.setValue(_loc1_.planetType);
   eccentricitySlider.value = _loc1_.eccentricity;
   apogeeAngleSlider.value = _loc1_.apogeeAngle;
   motionRateSlider.value = _loc1_.motionRate;
   epicycleSizeSlider.value = _loc1_.epicycleRadius;
   currentlySettingPresets = false;
   setPresetsButton.setEnabled(false);
}
function changeAnimate()
{
   var _loc1_ = !sysMC.animate;
   sysMC.animate = _loc1_;
   if(_loc1_)
   {
      animateButton.setLabel("pause animation");
   }
   else
   {
      animateButton.setLabel("start animation");
   }
}
function changePlanetType()
{
   if(!currentlySettingPresets)
   {
      setPresetsButton.setEnabled(true);
      sysMC.setPlanetType(planetTypeGroup.getValue());
      updateSys();
   }
}
function changeEpicycleSize(arg)
{
   sysMC.setEpicycleRadius(arg * 100);
   setPresetsButton.setEnabled(true);
   updateSys();
}
function changeAnomalyRate(arg)
{
   sysMC.setAnomalyRate(arg);
   setPresetsButton.setEnabled(true);
   updateSys();
}
function changeEccentricity(arg)
{
   sysMC.setEccentricity(arg * 100);
   setPresetsButton.setEnabled(true);
   updateSys();
}
function changeApogeeAngle(arg)
{
   sysMC.setApogeeAngle(arg);
   setPresetsButton.setEnabled(true);
   updateSys();
}
function changeShowDeferent()
{
   sysMC._deferentMC._visible = showDeferentCheck.getValue();
}
function changeShowEpicycle()
{
   sysMC._epicycleMC._visible = showEpicycleCheck.getValue();
}
function changeShowEpicyclePlanetLine()
{
   sysMC._epicyclePlanetLineMC._visible = showEpicyclePlanetLineCheck.getValue();
}
function changeShowEarthSunLine()
{
   sysMC._earthSunLineMC._visible = showEarthSunLineCheck.getValue();
}
function changeShowPlanetVector()
{
   sysMC._earthPlanetVectorMC._visible = showPlanetVectorCheck.getValue();
}
function changeShowEquantVector()
{
   sysMC._equantVectorMC._visible = showEquantVectorCheck.getValue();
}
function changeAnimationRate(arg)
{
   sysMC.animationRate = arg;
}
function changePathTime(arg)
{
   sysMC.setPathTime(arg);
}
function init()
{
   sysMC.setDeferentRadius(100);
}
planetData = [{name:"Venus",epicycleRadius:0.719444,eccentricity:0.020833,apogeeAngle:46.167,motionRate:1.6021,planetType:"inferior"},{name:"Mars",epicycleRadius:0.658333,eccentricity:0.1,apogeeAngle:106.667,motionRate:0.52406,planetType:"superior"},{name:"Jupiter",epicycleRadius:0.191667,eccentricity:0.045833,apogeeAngle:152.15,motionRate:0.0831224,planetType:"superior"},{name:"Saturn",epicycleRadius:0.108333,eccentricity:0.056944,apogeeAngle:224.167,motionRate:0.0334883,planetType:"superior"}];
currentlySettingPresets = false;
init();
onReset();
