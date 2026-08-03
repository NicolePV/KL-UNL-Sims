function YearSliderGrabberClass()
{
   this.stop();
}
var p = YearSliderGrabberClass.prototype = new MovieClip();
Object.registerClass("YearSliderGrabber",YearSliderGrabberClass);
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
   this._offset = this._parent._xmouse - this._x;
   this.onMouseMove = this.onMouseMoveFunc;
};
p.onMouseMoveFunc = function()
{
   var _loc2_ = this._parent._min + this._parent._scale * (this._parent._xmouse - this._offset + this._parent._hw);
   _loc2_ = (_loc2_ % 365 + 365) % 365;
   this._parent.value = _loc2_;
   this._parent.callHandler();
   updateAfterEvent();
};
p.onRelease = function()
{
   this.onMouseMove = undefined;
};
p.onReleaseOutside = function()
{
   this.onMouseMove = undefined;
   this.gotoAndStop(1);
};
