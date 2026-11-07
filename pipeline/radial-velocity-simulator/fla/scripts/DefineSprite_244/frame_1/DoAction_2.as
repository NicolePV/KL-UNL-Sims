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
   separationSlider.value = preset.separation;
   eccentricitySlider.value = preset.eccentricity;
   starMassSlider.value = preset.starMass;
   inclinationSlider.value = preset.inclination;
   longitudeSlider.value = preset.longitude;
   updateVisualization();
   updateRadialVelocityPlot();
   setPresetButton.setEnabled(false);
}
presetsList = [{name:"1. Option A",starMass:1,planetMass:1,eccentricity:0,separation:1,inclination:90,longitude:0},{name:"2. Option B",starMass:1,planetMass:1,eccentricity:0.4,separation:1,inclination:90,longitude:0},{name:"3. Option C",starMass:1,planetMass:0.05,eccentricity:0,separation:1,inclination:90,longitude:0},{name:"4. Option D",starMass:1,planetMass:0.00315,eccentricity:0,separation:1,inclination:90,longitude:0},{name:"5. HD 68988 b",starMass:1.2,planetMass:1.9,eccentricity:0.14,separation:0.071,inclination:90,longitude:40},{name:"6. HD 33564 b",starMass:1.25,planetMass:9.1,eccentricity:0.34,separation:1.1,inclination:90,longitude:205},{name:"7. HD 39091 b",starMass:1.1,planetMass:10.35,eccentricity:0.62,separation:3.29,inclination:90,longitude:331}];
initializeComboBox();
