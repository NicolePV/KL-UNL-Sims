function onResetClicked()
{
   planetMassSlider.value = 1;
   separationSlider.value = 1;
   eccentricitySlider.value = 0.2;
   starMassSlider.value = 1;
   inclinationSlider.value = 90;
   longitudeSlider.value = 45;
   noiseSlider.value = 15;
   numberOfMeasurementsSlider.value = 150;
   radialVelocityPlotMC.numberOfMeasurements = numberOfMeasurementsSlider.value;
   visualizationMC.setThetaAndPhi(80,45);
   animateButton.setLabel("start animation");
   delete onEnterFrame;
   animationRateSlider.value = 0.0005;
   showCurveCheck.setValue(true);
   showMeasurementsCheck.setValue(false);
   showPanelsCheck.setValue(false);
   presetsComboBox.setSelectedIndex(0);
   radialVelocityPlotMC.phaseOffset = -0.25;
   phaseSlider.value = 0;
   radialVelocityPlotMC.cursorPhase = phaseSlider.value;
   updateVisualization();
   updateRadialVelocityPlot();
}
onResetClicked();
