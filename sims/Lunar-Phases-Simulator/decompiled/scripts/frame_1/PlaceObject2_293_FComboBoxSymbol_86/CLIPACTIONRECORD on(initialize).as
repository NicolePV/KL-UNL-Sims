on(initialize){
   editable = false;
   labels = [];
   labels[0] = "New Moon";
   labels[1] = "Waxing Crescent";
   labels[2] = "First Quarter";
   labels[3] = "Waxing Gibbous";
   labels[4] = "Full Moon";
   labels[5] = "Waning Gibbous";
   labels[6] = "Third Quarter";
   labels[7] = "Waning Crescent";
   data = [];
   data[0] = 0;
   data[1] = 45;
   data[2] = 90;
   data[3] = 135;
   data[4] = 180;
   data[5] = 225;
   data[6] = 270;
   data[7] = 315;
   rowCount = 8;
   changeHandler = "phaseComboBoxChanged";
}
