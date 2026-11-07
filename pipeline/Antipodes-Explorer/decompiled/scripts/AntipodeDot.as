function AntipodeDotClass()
{
   var _loc1_ = this;
   _loc1_.clear();
   _loc1_.lineStyle(_loc1_.borderThickness,_loc1_.borderColor,_loc1_.borderAlpha);
   _loc1_.beginFill(_loc1_.fillColor,_loc1_.fillAlpha);
   _loc1_.drawCircle(_loc1_,0,0,_loc1_.radius);
   _loc1_.restrictTo = "none";
   _loc1_.snap = false;
   _loc1_.mapMC = _loc1_._parent._parent._parent._parent;
}
var p = AntipodeDotClass.prototype = new MovieClip();
Object.registerClass("AntipodeDot",AntipodeDotClass);
p.radius = 5;
p.fillColor = 10526880;
p.fillAlpha = 100;
p.borderThickness = 1;
p.borderColor = 0;
p.borderAlpha = 100;
p.receiveData = function(dataObj)
{
   var _loc1_ = dataObj;
   var _loc2_ = this;
   if(_loc1_.lat != undefined)
   {
      _loc2_.lat = _loc1_.lat;
   }
   if(_loc1_.lon != undefined)
   {
      _loc2_.lon = _loc1_.lon;
   }
   if(_loc1_.restrictTo != undefined)
   {
      _loc2_.restrictTo = _loc1_.restrictTo;
   }
   if(_loc1_.snap != undefined)
   {
      _loc2_.snap = _loc1_.snap;
   }
};
p.onPress = function()
{
   var _loc1_ = this;
   _loc1_.xOffset = _loc1_._parent._xmouse - _loc1_._x;
   _loc1_.yOffset = _loc1_._parent._ymouse - _loc1_._y;
   _loc1_.onMouseMove = _loc1_.onMouseMoveFunc;
};
p.onMouseMoveFunc = function()
{
   var _loc1_ = this;
   var newX = _loc1_._parent._xmouse - _loc1_.xOffset;
   var _loc3_ = _loc1_._parent._ymouse - _loc1_.yOffset;
   var _loc2_ = _loc1_.mapMC.getPositionFromScreenPoint({x:newX,y:_loc3_});
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
   _loc1_.mapMC._parent.setObjectPosition(_loc1_.name,_loc2_);
   updateAfterEvent();
};
p.onRelease = p.onReleaseOutside = function()
{
   delete this.onMouseMove;
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
