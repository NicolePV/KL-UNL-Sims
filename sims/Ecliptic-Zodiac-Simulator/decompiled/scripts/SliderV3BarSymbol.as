function SliderV3BarClass()
{
}
var p = SliderV3BarClass.prototype = new MovieClip();
Object.registerClass("SliderV3BarSymbol",SliderV3BarClass);
p.useHandCursor = false;
p._holdDelay = 500;
p.onPress = function()
{
   var _loc1_ = this;
   if(_loc1_._parent._xmouse < _loc1_._parent._grabber._x)
   {
      _loc1_._parent.value -= _loc1_._parent._minIncrement;
   }
   else
   {
      _loc1_._parent.value += _loc1_._parent._minIncrement;
   }
   _loc1_._parent.callHandler();
   _loc1_._startAuto = getTimer() + _loc1_._holdDelay;
   _loc1_.onEnterFrame = _loc1_.onEnterFrameFunc;
};
p.onEnterFrameFunc = function()
{
   var _loc1_ = this;
   if(getTimer() > _loc1_._startAuto)
   {
      if(_loc1_._parent._xmouse < _loc1_._parent._grabber._x)
      {
         _loc1_._parent.value -= _loc1_._parent._minIncrement;
      }
      else
      {
         _loc1_._parent.value += _loc1_._parent._minIncrement;
      }
      _loc1_._parent.callHandler();
   }
};
p.onRelease = p.onReleaseOutside = function()
{
   this.onEnterFrame = undefined;
};
