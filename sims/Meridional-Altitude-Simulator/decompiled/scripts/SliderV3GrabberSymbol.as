function SliderV3GrabberClass()
{
}
var p = SliderV3GrabberClass.prototype = new MovieClip();
Object.registerClass("SliderV3GrabberSymbol",SliderV3GrabberClass);
p.useHandCursor = false;
p.onPress = function()
{
   var _loc1_ = this;
   _loc1_._offset = _loc1_._parent._xmouse - _loc1_._x;
   _loc1_.onMouseMove = _loc1_.onMouseMoveFunc;
};
p.onMouseMoveFunc = function()
{
   var _loc1_ = this;
   var _loc2_ = _loc1_._parent._min + _loc1_._parent._scale * (_loc1_._parent._xmouse - _loc1_._offset + _loc1_._parent._hw);
   _loc1_._parent.value = _loc2_;
   _loc1_._parent.callHandler();
   updateAfterEvent();
};
p.onRelease = p.onReleaseOutside = function()
{
   this.onMouseMove = undefined;
};
