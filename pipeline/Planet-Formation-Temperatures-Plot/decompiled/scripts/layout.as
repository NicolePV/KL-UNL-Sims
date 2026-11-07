function layoutClass()
{
   var _loc1_ = this;
   _loc1_._currTemp = _loc1_.mySlider.initValue;
   _loc1_.myGraph._currTemp = _loc1_._currTemp;
   _loc1_.pixel_high = _loc1_.metalO_label._y + _loc1_.metalO_label._height / 2;
   _loc1_.pixel_low = _loc1_.ArNe_label._y + _loc1_.ArNe_label._height / 2;
   _loc1_.temp_high = 1500;
   _loc1_.temp_low = 65;
   _loc1_.myOverlay._y = _loc1_.findOverlayY(_loc1_._currTemp);
}
var p = layoutClass.prototype = new MovieClip();
Object.registerClass("layout",layoutClass);
p.update = function()
{
   var _loc1_ = this;
   _loc1_._currTemp = _loc1_.mySlider.value;
   _loc1_.myOverlay._y = _loc1_.findOverlayY(_loc1_._currTemp);
   _loc1_.myGraph.setTemp(_loc1_._currTemp);
};
p.findOverlayY = function(k)
{
   var _loc1_ = this;
   return (_loc1_.pixel_high - _loc1_.pixel_low) / (_loc1_.temp_high - _loc1_.temp_low) * (k - _loc1_.temp_high) + _loc1_.pixel_high;
};
