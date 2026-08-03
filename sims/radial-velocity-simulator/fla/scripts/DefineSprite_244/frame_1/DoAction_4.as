function displayStarInfo(starType, starTemp, starRadius)
{
   var starTypeNum = Math.round(starType.number);
   if(starTypeNum == 10)
   {
      starTypeNum = 9;
   }
   starInfoField.text = "(a main sequence star of this mass would have\n spectral type " + starType.type + starTypeNum + "V" + ", temperature " + getFormattedNumber(starTemp,3,12) + " K" + ",\n and radius " + starRadius.toFixed(1) + " Rsun)";
}
function displayPlotInfo()
{
   amplitudeField.text = getFormattedNumber(radialVelocityPlotMC.amplitude,3,4) + " m/s";
   periodField.text = getFormattedNumber(radialVelocityPlotMC.period,3,12) + " days";
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
function updateRadialVelocityPlot()
{
   radialVelocityPlotMC.setParameters({mass2:planetMassSlider.value * 1.899e+27,mass1:starMassSlider.value * 1.98892e+30,separation:separationSlider.value * 149598000000,eccentricity:eccentricitySlider.value,inclination:inclinationSlider.value,longitude:longitudeSlider.value});
   radialVelocityPlotMC.update();
   displayPlotInfo();
}
function onPlanetMassChanged()
{
   visualizationMC.setPlanetMass(planetMassSlider.value);
   updateRadialVelocityPlot();
   setPresetButton.setEnabled(true);
}
function onStarMassChanged()
{
   var starMass = starMassSlider.value;
   var starLum = getLuminosityFromMass(starMass);
   var starTemp = getTempFromLuminosity(starLum);
   var starRadius = getRadiusFromTempAndLuminosity(starTemp,starLum);
   var starType = getSpectralTypeFromTemp(starTemp);
   displayStarInfo(starType,starTemp,starRadius);
   visualizationMC.setStarMass(starMass);
   visualizationMC.setStarTemperature(starTemp);
   updateRadialVelocityPlot();
   setPresetButton.setEnabled(true);
}
function onEccentricityChanged()
{
   visualizationMC.setEccentricity(eccentricitySlider.value);
   updateRadialVelocityPlot();
   setPresetButton.setEnabled(true);
}
function onSeparationChanged()
{
   visualizationMC.setSeparation(separationSlider.value);
   updateRadialVelocityPlot();
   setPresetButton.setEnabled(true);
}
function onInclinationChanged()
{
   visualizationMC.setInclination(inclinationSlider.value);
   updateRadialVelocityPlot();
   setPresetButton.setEnabled(true);
}
function onLongitudeChanged()
{
   visualizationMC.setLongitude(longitudeSlider.value);
   updateRadialVelocityPlot();
   setPresetButton.setEnabled(true);
}
