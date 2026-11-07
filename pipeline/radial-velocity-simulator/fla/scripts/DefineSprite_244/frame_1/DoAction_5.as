function onShowPanelsChanged()
{
   visualizationMC.setShowMultiplePanels(showPanelsCheck.getValue());
}
function updateVisualization()
{
   var starMass = starMassSlider.value;
   var starLum = getLuminosityFromMass(starMass);
   var starTemp = getTempFromLuminosity(starLum);
   var starRadius = getRadiusFromTempAndLuminosity(starTemp,starLum);
   var starType = getSpectralTypeFromTemp(starTemp);
   displayStarInfo(starType,starTemp,starRadius);
   visualizationMC.setParameters({starMass:starMass,starTemperature:starTemp,planetMass:planetMassSlider.value,separation:separationSlider.value,eccentricity:eccentricitySlider.value,phase:phaseSlider.value,inclination:inclinationSlider.value,longitude:longitudeSlider.value});
}
