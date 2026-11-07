function LatitudePanelClass()
{
   this._latitude = 0;
}
var p = LatitudePanelClass.prototype = new MovieClip();
Object.registerClass("Latitude Panel",LatitudePanelClass);
p.onLocationSelected = function()
{
   var _loc1_ = this;
   if(_loc1_.locationComboBox.getSelectedIndex() > 0)
   {
      _loc1_._latitude = _loc1_.locationComboBox.getValue();
   }
   _loc1_.update();
   _loc1_._parent[_loc1_.changeHandler](_loc1_._latitude);
};
p.getLatitude = function()
{
   return this._latitude;
};
p.setLatitude = function(arg)
{
   var _loc1_ = this;
   _loc1_._latitude = 1;
   _loc1_.latitudeSlider.value = arg;
   _loc1_.onLatitudeSliderChanged(arg,true);
};
p.addProperty("latitude",p.getLatitude,p.setLatitude);
p.onLatitudeSliderChanged = function(ignored, skipChangeHandlerCall)
{
   var _loc1_ = this;
   if(_loc1_._latitude >= 0)
   {
      _loc1_._latitude = _loc1_.latitudeSlider.value;
   }
   else
   {
      _loc1_._latitude = - Math.abs(_loc1_.latitudeSlider.value);
   }
   _loc1_.update();
   if(!skipChangeHandlerCall)
   {
      _loc1_._parent[_loc1_.changeHandler](_loc1_._latitude);
   }
};
p.onHemisphereChanged = function()
{
   var _loc1_ = this;
   if(_loc1_.hemisphereComboBox.getValue() == "N")
   {
      _loc1_._latitude = Math.abs(_loc1_._latitude);
   }
   else
   {
      _loc1_._latitude = - Math.abs(_loc1_._latitude);
   }
   _loc1_.update();
   _loc1_._parent[_loc1_.changeHandler](_loc1_._latitude);
};
p.onLatitudeChangedViaMap = function(arg)
{
   var _loc1_ = this;
   _loc1_._latitude = 1;
   _loc1_.latitudeSlider.value = arg;
   _loc1_.onLatitudeSliderChanged();
   _loc1_._parent[_loc1_.changeHandler](_loc1_._latitude);
};
p.update = function()
{
   var _loc3_ = this;
   _loc3_.latitudeSlider.value = Math.abs(_loc3_._latitude);
   if(_loc3_._latitude >= 0)
   {
      _loc3_.hemisphereComboBox.setSelectedIndex(0,false);
   }
   else
   {
      _loc3_.hemisphereComboBox.setSelectedIndex(1,false);
   }
   _loc3_.mapMC.setCursorLatitude(_loc3_._latitude);
   var list = _loc3_.locationComboBox.dataProvider.items;
   var newIndex = 0;
   var _loc1_ = 1;
   var _loc2_;
   while(_loc1_ < list.length)
   {
      _loc2_ = _loc3_._latitude - list[_loc1_].data;
      if(Math.abs(_loc2_) < 1e-12)
      {
         newIndex = _loc1_;
         break;
      }
      _loc1_ = _loc1_ + 1;
   }
   _loc3_.locationComboBox.setSelectedIndex(newIndex,false);
};
