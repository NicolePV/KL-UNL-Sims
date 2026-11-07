function NewSunClass()
{
}
var p = NewSunClass.prototype = new MovieClip();
Object.registerClass("New Sun",NewSunClass);
p.tabEnabled = false;
p.useHandCursor = false;
p.onPress = function()
{
   var _loc1_ = this;
   _loc1_.angleOffset = Math.atan2(- _loc1_._parent._ymouse,_loc1_._parent._xmouse) - _loc1_._parent._sunAngle;
   _loc1_.onMouseMove = _loc1_.onMouseMoveFunc;
};
p.onMouseMoveFunc = function()
{
   var _loc1_ = this;
   var _loc2_ = Math.atan2(- _loc1_._parent._ymouse,_loc1_._parent._xmouse) - _loc1_.angleOffset;
   _loc1_._parent.setSunAngle(_loc2_);
   updateAfterEvent();
};
p.onRollOver = function()
{
   this.gotoAndStop(2);
};
p.onRollOut = function()
{
   this.gotoAndStop(1);
};
p.onReleaseOutside = function()
{
   this.gotoAndStop(1);
   delete this.onMouseMove;
};
p.onRelease = function()
{
   delete this.onMouseMove;
};
