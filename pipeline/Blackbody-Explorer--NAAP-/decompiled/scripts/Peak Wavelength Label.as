function PeakWavelengthLabelClass()
{
   this.labelField.autoSize = "center";
}
var p = PeakWavelengthLabelClass.prototype = new MovieClip();
Object.registerClass("Peak Wavelength Label",PeakWavelengthLabelClass);
p.setLabel = function(arg)
{
   var _loc1_ = this;
   _loc1_.labelField.text = arg;
   var pw = _loc1_._parent._parent._parent.width;
   var _loc3_ = _loc1_.labelField.textWidth;
   var _loc2_ = _loc1_._x;
   var m = 3;
   if(_loc2_ < m + _loc3_ / 2)
   {
      _loc1_.labelField._x = m - _loc2_;
   }
   else if(_loc2_ > pw - m - _loc3_ / 2)
   {
      _loc1_.labelField._x = pw - m - _loc2_ - _loc3_;
   }
   else
   {
      _loc1_.labelField._x = (- _loc3_) / 2;
   }
};
