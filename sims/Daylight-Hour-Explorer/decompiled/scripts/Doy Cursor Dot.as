function DoyCursorDotClass()
{
   this.stop();
}
var p = DoyCursorDotClass.prototype = new MovieClip();
Object.registerClass("Doy Cursor Dot",DoyCursorDotClass);
p.onPress = function()
{
   this.xOffset = this._x - this._parent._xmouse;
   this.onMouseMove = this.onMouseMoveFunc;
};
p.onRollOver = function()
{
   this.gotoAndStop(2);
};
p.onRollOut = function()
{
   this.gotoAndStop(1);
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
p.onMouseMoveFunc = function()
{
   var _loc3_ = this._parent._xmouse + this.xOffset;
   var _loc2_ = this._parent.plot.plotWidth;
   _loc3_ = (_loc3_ % _loc2_ + _loc2_) % _loc2_;
   this._parent._parent.setDoy(365 * _loc3_ / _loc2_ + this._parent.plot.vernalEquinoxDoy);
   updateAfterEvent();
};
