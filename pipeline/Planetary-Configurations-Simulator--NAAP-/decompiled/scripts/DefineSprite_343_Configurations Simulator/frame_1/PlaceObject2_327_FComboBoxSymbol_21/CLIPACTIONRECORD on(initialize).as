on(initialize){
   editable = false;
   labels = [];
   labels[0] = "<presets>";
   labels[1] = "Mercury";
   labels[2] = "Venus";
   labels[3] = "Earth";
   labels[4] = "Mars";
   labels[5] = "Jupiter";
   labels[6] = "Saturn";
   data = [];
   data[0] = 0;
   data[1] = 0.39;
   data[2] = 0.72;
   data[3] = 1;
   data[4] = 1.52;
   data[5] = 5.2;
   data[6] = 9.54;
   rowCount = 8;
   changeHandler = "onSemimajorAxis1ComboBoxChanged";
}
