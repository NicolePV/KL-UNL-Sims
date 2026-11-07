function LocationSelectorCursorClass()
{
   this.stop();
}
var p = LocationSelectorCursorClass.prototype = new MovieClip();
Object.registerClass("Location Selector Cursor",LocationSelectorCursorClass);
p.useHandCursor = false;
p.onRollOver = function()
{
   this.gotoAndStop(2);
};
p.onRollOut = function()
{
   this.gotoAndStop(1);
};
p.onPress = function()
{
   this._parent._parent.pauseAnimation();
   this.onMouseMove = this.onMouseMoveFunc;
   this.xOffset = this._parent._xmouse - this._x;
   this.yOffset = this._parent._ymouse - this._y;
};
p.onMouseMoveFunc = function()
{
   var _loc3_ = this._parent._xmouse - this.xOffset;
   var _loc2_ = this._parent._ymouse - this.yOffset;
   this._parent.moveCursorTo(_loc3_,_loc2_);
   updateAfterEvent();
};
p.onRelease = function()
{
   this._parent._parent.resumeAnimation();
   delete this.onMouseMove;
};
p.onReleaseOutside = function()
{
   this._parent._parent.resumeAnimation();
   this.gotoAndStop(1);
   delete this.onMouseMove;
};
