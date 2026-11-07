function onReset()
{
   explorer.checkBox.terrestrial_box.setValue(true);
   explorer.checkBox.jovian_box.setValue(true);
   explorer.checkBox.pluto_box.setValue(true);
   explorer.checkBox._changed = true;
   explorer.radio.axis_radio.setValue(true);
   explorer.radio.changeToAxis();
}
