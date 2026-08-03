function CursorClass()
{
   this.stop();
}
var p = CursorClass.prototype = new MovieClip();
Object.registerClass("Cursor",CursorClass);
p.onRollOver = function()
{
   this.gotoAndStop(2);
};
p.onRollOut = function()
{
   this.gotoAndStop(1);
};
p.onMouseMoveFunc = function()
{
   var _loc1_ = this;
   var _loc2_ = _loc1_._parent._xmouse - _loc1_.xOffset;
   _loc1_._parent.onCursorDragged(_loc2_);
   updateAfterEvent();
};
p.onPress = function()
{
   var _loc1_ = this;
   _loc1_.xOffset = _loc1_._parent._xmouse - _loc1_._x;
   _loc1_.onMouseMove = _loc1_.onMouseMoveFunc;
};
p.onRelease = function()
{
   delete this.onMouseMove;
};
p.onReleaseOutside = function()
{
   delete this.onMouseMove;
   this.gotoAndStop(1);
};
