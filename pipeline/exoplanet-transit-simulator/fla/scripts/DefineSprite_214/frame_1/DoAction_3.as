function updateEclipseTimeField()
{
   var period = lightcurveMC.systemPeriod;
   var duration = lightcurveMC.eclipseOfBody1Duration;
   if(duration == 0 || duration == null)
   {
      eclipseDurationArrowMC._visible = false;
      eclipseTimeField.text = "(no eclipse)";
      eclipseDepthField.text = "(no eclipse)";
   }
   else
   {
      eclipseDurationArrowMC._visible = true;
      eclipseTimeField.text = "eclipse takes " + getTimeString(lightcurveMC.eclipseOfBody1Duration) + "s of " + getTimeString(lightcurveMC.systemPeriod) + " orbit";
      eclipseDepthField.text = formatNumber(lightcurveMC.plottedVisualFluxDepth,3);
   }
}
function getTimeString(time)
{
   if(time > 47335104)
   {
      time /= 31556736;
      var str = " year";
   }
   else if(time > 86400)
   {
      time /= 86400;
      var str = " day";
   }
   else if(time > 5400)
   {
      time /= 3600;
      var str = " hour";
   }
   else if(time > 60)
   {
      time /= 60;
      var str = " minute";
   }
   else
   {
      var str = " second";
   }
   var timeStr = formatNumber(time,3) + str;
   return timeStr;
}
function formatNumber(num, digits)
{
   var L = Math.floor(Math.log(num) / 2.302585092994046) - (digits - 1);
   if(L >= 0)
   {
      var M = Math.pow(10,L);
      return String(M * Math.round(num / M));
   }
   return num.toFixed(- L);
}
function getFormattedNumber(x, digits, kLimit)
{
   var m = Math.floor(Math.log(x) / 2.302585092994046);
   var k = digits - 1 - m;
   if(k <= 0)
   {
      return Math.toSigDigits(x,digits);
   }
   if(k > kLimit)
   {
      k = kLimit;
   }
   return x.toFixed(k);
}
function displayStarInfo(starType, starTemp, starRadius)
{
   var starTypeNum = Math.round(starType.number);
   if(starTypeNum == 10)
   {
      starTypeNum = 9;
   }
   starInfoField.text = "a main sequence star of this mass\n would have spectral type " + starType.type + starTypeNum + "V" + ",\n temperature " + getFormattedNumber(starTemp,3,12) + " K" + ",\n and radius " + starRadius.toFixed(1) + " Rsun";
}
function updateParameters()
{
   var starMass = starMassSlider.value;
   var starLum = getLuminosityFromMass(starMass);
   var starTemp = getTempFromLuminosity(starLum);
   var starRadius = getRadiusFromTempAndLuminosity(starTemp,starLum);
   var starType = getSpectralTypeFromTemp(starTemp);
   var num = Math.round(starType.number);
   if(num == 10)
   {
      num = 9;
   }
   displayStarInfo(starType,starTemp,starRadius);
   var params = {};
   params.mass1 = starMass * 1.98892e+30;
   params.radius1 = starRadius * 695500000;
   params.temperature1 = starTemp;
   params.mass2 = planetMassSlider.value * 1.8987e+27;
   params.radius2 = planetRadiusSlider.value * 71492000;
   params.temperature2 = 500;
   params.inclination = inclinationSlider.value;
   params.longitude = longitudeSlider.value;
   params.eccentricity = eccentricitySlider.value;
   params.separation = separationSlider.value * 149598000000;
   lightcurveMC.setParameters(params);
   lightcurveMC.update();
   params.minPhase = lightcurveMC._minPhase;
   params.maxPhase = lightcurveMC._maxPhase;
   params.phase = lightcurveMC.cursorPhase;
   visualizationMC.setParameters(params);
   updateEclipseTimeField();
   setPresetButton.setEnabled(true);
}
function onPhaseChangedViaSlider()
{
   lightcurveMC.setCPhase(phaseSlider.value);
   visualizationMC.setPhase(lightcurveMC.cursorPhase);
}
function onPhaseChangedViaLightcurve()
{
   phaseSlider.value = lightcurveMC._cPhase;
   visualizationMC.setPhase(lightcurveMC.cursorPhase);
}
function onNoiseChanged()
{
   lightcurveMC.fluxNoise = noiseSlider.value;
   lightcurveMC.update();
}
function onNumberOfMeasurementsChanged()
{
   lightcurveMC.numberOfMeasurements = numberOfMeasurementsSlider.value;
   lightcurveMC.update();
}
function onShowCurveChanged()
{
   lightcurveMC.showCurve = showCurveCheck.getValue();
}
function onShowMeasurementsChanged()
{
   if(showMeasurementsCheck.getValue())
   {
      lightcurveMC.fluxNoise = noiseSlider.value;
      lightcurveMC.update();
      lightcurveMC.showMeasurements = true;
   }
   else
   {
      lightcurveMC.fluxNoise = noMeasurementsNoise;
      lightcurveMC.update();
      lightcurveMC.showMeasurements = false;
   }
   numberOfMeasurementsSlider.userEnabled = noiseSlider.userEnabled = showMeasurementsCheck.getValue();
   numberOfMeasurementsSlider.update();
   noiseSlider.update();
}
function initializeComboBox()
{
   var i = 0;
   while(i < presetsList.length)
   {
      presetsComboBox.addItem(presetsList[i].name,presetsList[i]);
      i++;
   }
}
function onPresetChanged()
{
   setPresetButton.setEnabled(true);
}
function setPreset()
{
   var preset = presetsComboBox.getValue();
   planetMassSlider.value = preset.planetMass;
   planetRadiusSlider.value = preset.planetRadius;
   starMassSlider.value = preset.starMass;
   separationSlider.value = preset.separation;
   eccentricitySlider.value = preset.eccentricity;
   inclinationSlider.value = preset.inclination;
   longitudeSlider.value = preset.longitude;
   updateParameters();
   setPresetButton.setEnabled(false);
}
function onResetClicked()
{
   planetMassSlider.value = 0.657;
   planetRadiusSlider.value = 1.32;
   starMassSlider.value = 1.09;
   separationSlider.value = 0.047;
   eccentricitySlider.value = 0;
   inclinationSlider.value = 86.929;
   longitudeSlider.value = 0;
   noiseSlider.value = 0.1;
   numberOfMeasurementsSlider.value = 50;
   phaseSlider.value = 0.5;
   numberOfMeasurementsSlider.userEnabled = false;
   numberOfMeasurementsSlider.update();
   noiseSlider.userEnabled = false;
   noiseSlider.update();
   showCurveCheck.setValue(true,true);
   showMeasurementsCheck.setValue(false,true);
   lightcurveMC.showCurve = true;
   lightcurveMC.showMeasurements = false;
   lightcurveMC.numberOfMeasurements = numberOfMeasurementsSlider.value;
   lightcurveMC.fluxNoise = noMeasurementsNoise;
   lightcurveMC.setCPhase(phaseSlider.value);
   visualizationMC.setPhase(lightcurveMC.cursorPhase);
   presetsComboBox.setSelectedIndex(0);
   updateParameters();
}
noMeasurementsNoise = 0.00001;
initializeComboBox();
onResetClicked();
