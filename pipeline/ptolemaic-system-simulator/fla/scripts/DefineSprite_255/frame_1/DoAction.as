createEmptyMovieClip("extraLevel",100);
icons.swapDepths(200);
info = ["The earth. In Ptolemy\'s model the earth is stationary at the center.","The planet, which in this model orbits the earth using a circle on circle construction. The large circle is the deferent and the small one is the epicycle.","The sun. Note that this icon indicates the sun\'s direction with respect to the earth, not its absolute position in space.","The center of the deferent (the larger circle on which the epicycle moves). ","The equant, which is the center of uniform motion of the epicycle around the deferent."];
tab1.swapDepths(100);
infoField.text = info[0];
tab1.onPress = function()
{
   var _loc1_ = this;
   _loc1_.swapDepths(100);
   _loc1_._parent.infoField.text = _loc1_._parent.info[0];
};
tab2.onPress = function()
{
   var _loc1_ = this;
   _loc1_.swapDepths(100);
   _loc1_._parent.infoField.text = _loc1_._parent.info[1];
};
tab3.onPress = function()
{
   var _loc1_ = this;
   _loc1_.swapDepths(100);
   _loc1_._parent.infoField.text = _loc1_._parent.info[2];
};
tab4.onPress = function()
{
   var _loc1_ = this;
   _loc1_.swapDepths(100);
   _loc1_._parent.infoField.text = _loc1_._parent.info[3];
};
tab5.onPress = function()
{
   var _loc1_ = this;
   _loc1_.swapDepths(100);
   _loc1_._parent.infoField.text = _loc1_._parent.info[4];
};
tab1.useHandCursor = false;
tab2.useHandCursor = false;
tab3.useHandCursor = false;
tab4.useHandCursor = false;
tab5.useHandCursor = false;
