function onReset()
{
   var _loc1_ = 1;
   var _loc2_ = 0.4;
   var _loc3_ = 0.2;
   clearFeatures();
   if(visualizationMC.animationState)
   {
      changeAnimationState();
   }
   visualizationMC.meanAnomaly = 0;
   visualizationMC._time = 0;
   semimajorAxisSlider.value = _loc1_;
   visualizationMC.setSemimajorAxisNoZoom(_loc1_);
   eccentricitySlider.value = _loc2_;
   visualizationMC.eccentricity = _loc2_;
   animationRateSlider.value = _loc3_;
   visualizationMC.setAnimationRate(1 / _loc3_);
   updateNewtonPlot();
   updatePanelValues();
   okSelectionButton.setEnabled(true);
}
function onShowGridChanged()
{
   visualizationMC.showGrid = showGridCheckBox.getValue();
}
function onTabPressed(tab)
{
   var showK1 = false;
   var _loc3_ = false;
   var _loc2_ = false;
   var _loc1_ = false;
   switch(tab)
   {
      case "k1":
         var showK1 = true;
         break;
      case "k2":
         _loc3_ = true;
         break;
      case "k3":
         _loc2_ = true;
         break;
      default:
         _loc1_ = true;
   }
   kepler1Panel._visible = showK1;
   kepler2Panel._visible = _loc3_;
   kepler3Panel._visible = _loc2_;
   newtonPanel._visible = _loc1_;
   updateNewtonPlot();
   updatePanelValues();
}
function onSweepingStopped()
{
   kepler2Panel.sweepButton.setLabel("start sweeping");
}
function onPositionChanged()
{
   updateNewtonCursorPosition();
   updatePanelValues(true);
}
function onSelectionBoxChanged()
{
   okSelectionButton.setEnabled(true);
}
function setPlanetSelection()
{
   visualizationMC.setParametersToMatch(planetSelectionBox.getSelectedIndex());
   eccentricitySlider.value = visualizationMC.eccentricity;
   semimajorAxisSlider.value = visualizationMC.semimajorAxis;
   updateNewtonPlot();
   updatePanelValues();
   okSelectionButton.setEnabled(false);
}
function changeAnimationRate(arg)
{
   visualizationMC.setAnimationRate(1 / arg);
}
function changeSemimajorAxis(arg)
{
   visualizationMC.semimajorAxis = arg;
   updateNewtonPlot();
   updatePanelValues();
   okSelectionButton.setEnabled(true);
}
function changeEccentricity(arg)
{
   visualizationMC.eccentricity = arg;
   updateNewtonPlot();
   updatePanelValues();
   okSelectionButton.setEnabled(true);
}
function changeAnimationState()
{
   visualizationMC.animationState = !visualizationMC.animationState;
   if(visualizationMC.animationState)
   {
      animateButton.setLabel("pause animation");
   }
   else
   {
      animateButton.setLabel("start animation");
   }
}
function changeShowSSOrbits()
{
   if(showSSOrbitsCheck.getValue())
   {
      visualizationMC.setShowLandmarkOrbits(true);
      labelSSOrbitsCheck.setEnabled(true);
      showSSPlanetsCheck.setEnabled(true);
      kepler3Panel.plotMC.showPlanetPoints(true);
   }
   else
   {
      visualizationMC.setShowLandmarkOrbits(false);
      labelSSOrbitsCheck.setEnabled(false);
      showSSPlanetsCheck.setEnabled(false);
      kepler3Panel.plotMC.showPlanetPoints(false);
   }
}
function changeShowSSPlanets()
{
   visualizationMC.setShowLandmarkPlanetIcons(showSSPlanetsCheck.getValue());
}
function changeLabelSSOrbits()
{
   visualizationMC.setShowLandmarkOrbitLabels(labelSSOrbitsCheck.getValue());
}
function clearFeatures()
{
   showGridCheckBox.setValue(false);
   visualizationMC.setShowLandmarkOrbits(false);
   visualizationMC.setShowLandmarkOrbitLabels(false);
   visualizationMC.setShowLandmarkPlanetIcons(false);
   showSSOrbitsCheck.setValue(false,true);
   labelSSOrbitsCheck.setValue(false,true);
   showSSPlanetsCheck.setValue(false,true);
   labelSSOrbitsCheck.setEnabled(false);
   showSSPlanetsCheck.setEnabled(false);
   visualizationMC.setShowDetails(false);
   kepler1Panel.showEmptyFocusCheck.setValue(false,true);
   kepler1Panel.showCenterCheck.setValue(false,true);
   kepler1Panel.showRadialLinesCheck.setValue(false,true);
   kepler1Panel.showSemiminorAxisCheck.setValue(false,true);
   kepler1Panel.showSemimajorAxisCheck.setValue(false,true);
   visualizationMC.removeAllSweeps();
   visualizationMC.setUseSoundEffect(false);
   kepler2Panel.useSoundEffectCheck.setValue(false,true);
   visualizationMC.sweepContinuously = false;
   kepler2Panel.sweepContinuouslyCheck.setValue(false,true);
   visualizationMC.setSweepDuration(16,true);
   kepler2Panel.sweepDurationSlider.value = 16;
   kepler3Panel.plotMC.showPlanetPoints(false);
   kepler3Panel.plotTypeGroup.setValue("linear");
   visualizationMC.setShowArrows(false);
   visualizationMC.setShowAccelerationLine(false);
   visualizationMC.setShowVelocityTangent(false);
   newtonPanel.showAccelerationArrowCheck.setValue(false,true);
   newtonPanel.showVelocityArrowCheck.setValue(false,true);
   newtonPanel.showAccelerationLineCheck.setValue(false,true);
   newtonPanel.showVelocityTangentCheck.setValue(false,true);
}
function updateNewtonPlot()
{
   if(newtonPanel._visible)
   {
      newtonPanel.plotMC.setProperties({maxEccentricity:0.7,eccentricity:visualizationMC.eccentricity,semimajorAxis:visualizationMC.semimajorAxis,primaryMass:visualizationMC.primaryMass});
   }
}
function updateNewtonCursorPosition()
{
   newtonPanel.plotMC.setPhase(visualizationMC.meanAnomaly);
}
function updatePanelValues(positionChanged)
{
   var startTimer = getTimer();
   var _loc1_;
   var _loc3_;
   var _loc2_;
   if(kepler1Panel._visible)
   {
      var r1 = visualizationMC.radius;
      var c = 2 * visualizationMC.semimajorAxis;
      var r2 = c - r1;
      kepler1Panel.r1Field.text = toThreeSigDigs(r1) + " AU";
      kepler1Panel.r2Field.text = toThreeSigDigs(r2) + " AU";
      kepler1Panel.constantField.text = toThreeSigDigs(c) + " AU";
   }
   else if(newtonPanel._visible)
   {
      var M = visualizationMC.primaryMass;
      var k3 = 1774.53 * M;
      var k4 = (- k3) / (2 * visualizationMC.semimajorAxis);
      var k5 = 0.005931 * M;
      _loc1_ = visualizationMC.radius;
      var v = Math.sqrt(k4 + k3 / _loc1_);
      var ac = k5 / (_loc1_ * _loc1_);
      newtonPanel.angleField.text = visualizationMC.angleBetweenVectors.toFixed(1) + "°";
      newtonPanel.velocityField.text = "v = " + toThreeSigDigs(v) + " km/s";
      newtonPanel.accelerationField.text = "a = " + toThreeSigDigs(ac) + " m/s";
      newtonPanel.squaredMC._x = 2 + newtonPanel.accelerationField._x + newtonPanel.accelerationField.textWidth;
   }
   else if(kepler2Panel._visible && !positionChanged)
   {
      var a = visualizationMC.semimajorAxis;
      var e = visualizationMC.eccentricity;
      var d = kepler2Panel.sweepDurationSlider.value;
      _loc3_ = 1 / d;
      kepler2Panel.timeField.text = toThreeSigDigs(_loc3_ * visualizationMC.period) + " years";
      kepler2Panel.areaField.text = toThreeSigDigs(_loc3_ * (a * a * 3.141592653589793 * Math.sqrt(1 - e * e))) + " sq AU";
      kepler2Panel.denomField.text = d;
      kepler2Panel.percentField.text = (_loc3_ * 100).toFixed(1) + "%)";
   }
   else if(kepler3Panel._visible && !positionChanged)
   {
      _loc2_ = visualizationMC.period;
      kepler3Panel.semimajorField.text = "(" + toThreeSigDigs(visualizationMC.semimajorAxis) + ")";
      kepler3Panel.periodField.text = "(" + toThreeSigDigs(_loc2_) + ")";
      kepler3Panel.squaredMC._x = 3 + kepler3Panel.periodField._x + kepler3Panel.periodField.textWidth;
      kepler3Panel.cubedMC._x = 3 + kepler3Panel.semimajorField._x + kepler3Panel.semimajorField.textWidth;
      kepler3Panel.quantityField.text = toThreeSigDigs(_loc2_ * _loc2_);
      kepler3Panel.plotMC.setSemimajorAxis(visualizationMC.semimajorAxis);
   }
}
onReset();
