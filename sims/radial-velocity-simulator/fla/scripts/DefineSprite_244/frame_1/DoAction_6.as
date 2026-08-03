function onCursorPhaseChanged(phase)
{
   visualizationMC.setPhase(phase);
   phaseSlider.value = phase;
}
function onShowCurveChanged()
{
   radialVelocityPlotMC.showCurve = showCurveCheck.getValue();
}
function onShowMeasurementsChanged()
{
   if(showMeasurementsCheck.getValue())
   {
      radialVelocityPlotMC.noise = noiseSlider.value;
      radialVelocityPlotMC.update();
      radialVelocityPlotMC.showMeasurements = true;
   }
   else
   {
      radialVelocityPlotMC.noise = noMeasurementsNoise;
      radialVelocityPlotMC.update();
      radialVelocityPlotMC.showMeasurements = false;
   }
   numberOfMeasurementsSlider.userEnabled = noiseSlider.userEnabled = showMeasurementsCheck.getValue();
   numberOfMeasurementsSlider.update();
   noiseSlider.update();
}
function onNumberOfMeasurementsChanged()
{
   radialVelocityPlotMC.numberOfMeasurements = numberOfMeasurementsSlider.value;
   radialVelocityPlotMC.update();
}
function onNoiseChanged()
{
   radialVelocityPlotMC.noise = noiseSlider.value;
   radialVelocityPlotMC.update();
}
radialVelocityPlotMC.minScreenYSpacing = 20;
noMeasurementsNoise = 0.1;
