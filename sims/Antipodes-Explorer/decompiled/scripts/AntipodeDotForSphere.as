function AntipodeDotForSphereClass()
{
   var _loc1_ = this;
   _loc1_.clear();
   _loc1_.lineStyle(_loc1_.borderThickness,_loc1_.borderColor,_loc1_.borderAlpha);
   _loc1_.beginFill(_loc1_.fillColor,_loc1_.fillAlpha);
   _loc1_.drawCircle(_loc1_,0,0,_loc1_.radius);
   _loc1_.restrictTo = "none";
   _loc1_.snap = false;
}
var p = AntipodeDotForSphereClass.prototype = new MovieClip();
Object.registerClass("AntipodeDotForSphere",AntipodeDotForSphereClass);
p.radius = 5;
p.fillColor = 10526880;
p.fillAlpha = 100;
p.borderThickness = 1;
p.borderColor = 0;
p.borderAlpha = 100;
p.onPress = function()
{
   var _loc1_ = this;
   if(_loc1_._object._sp.z > 0)
   {
      _loc1_.active = true;
      _loc1_.onMouseMove = _loc1_.onMouseMoveFunc;
   }
   else
   {
      _loc1_.active = false;
      _loc1_._sphere._mouseArea.onPress();
   }
};
p.onReleaseOutside = function()
{
   var _loc1_ = this;
   if(_loc1_.active)
   {
      delete _loc1_.onMouseMove;
   }
   else
   {
      _loc1_._sphere._mouseArea.onRelease();
   }
};
p.onRelease = function()
{
   var _loc1_ = this;
   if(_loc1_.active)
   {
      delete _loc1_.onMouseMove;
   }
   else
   {
      _loc1_._sphere._mouseArea.onRelease();
   }
};
p.onMouseMoveFunc = function()
{
   var _loc1_ = this;
   var mhp = {};
   _loc1_._sphere.StoMH({x:_loc1_._sphere._xmouse,y:_loc1_._sphere._ymouse},mhp);
   var _loc3_ = {};
   _loc1_._sphere.MHtoC(mhp,_loc3_);
   var _loc2_ = {lon:_loc3_.ra * 57.29577951308232,lat:_loc3_.dec * 57.29577951308232};
   if(_loc1_.snap)
   {
      _loc2_.lat = 5 * Math.round(_loc2_.lat / 5);
      _loc2_.lon = 5 * Math.round(_loc2_.lon / 5);
   }
   if(_loc1_.restrictTo == "latitude")
   {
      _loc2_.lat = _loc1_.lat;
   }
   else if(_loc1_.restrictTo == "longitude")
   {
      _loc2_.lon = _loc1_.lon;
   }
   _loc1_._sphere._parent.setObjectPosition(_loc1_.dotName,_loc2_);
   updateAfterEvent();
};
p.drawCircle = function(mc, x, y, r)
{
   var _loc1_ = r;
   var _loc2_ = y;
   var _loc3_ = x;
   mc.moveTo(_loc3_ + _loc1_,_loc2_);
   mc.curveTo(_loc3_ + _loc1_,_loc2_ - 0.4142 * _loc1_,_loc3_ + 0.7071 * _loc1_,_loc2_ - 0.7071 * _loc1_);
   mc.curveTo(_loc3_ + 0.4142 * _loc1_,_loc2_ - _loc1_,_loc3_,_loc2_ - _loc1_);
   mc.curveTo(_loc3_ - 0.4142 * _loc1_,_loc2_ - _loc1_,_loc3_ - 0.7071 * _loc1_,_loc2_ - 0.7071 * _loc1_);
   mc.curveTo(_loc3_ - _loc1_,_loc2_ - 0.4142 * _loc1_,_loc3_ - _loc1_,_loc2_);
   mc.curveTo(_loc3_ - _loc1_,_loc2_ + 0.4142 * _loc1_,_loc3_ - 0.7071 * _loc1_,_loc2_ + 0.7071 * _loc1_);
   mc.curveTo(_loc3_ - 0.4142 * _loc1_,_loc2_ + _loc1_,_loc3_,_loc2_ + _loc1_);
   mc.curveTo(_loc3_ + 0.4142 * _loc1_,_loc2_ + _loc1_,_loc3_ + 0.7071 * _loc1_,_loc2_ + 0.7071 * _loc1_);
   mc.curveTo(_loc3_ + _loc1_,_loc2_ + 0.4142 * _loc1_,_loc3_ + _loc1_,_loc2_);
};
