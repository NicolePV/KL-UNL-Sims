function LatitudeSelectorClass()
{
   var _loc1_ = this;
   _loc1_.equator = _loc1_.mapMC._height / 2;
   _loc1_.scale = 180 / _loc1_.mapMC._height;
   _loc1_.cursorMC.tabEnabled = false;
   _loc1_.cursorMC.useHandCursor = false;
   _loc1_.cursorMC.onPress = function()
   {
      var _loc1_ = this;
      _loc1_.yOffset = _loc1_._parent._ymouse - _loc1_._y;
      _loc1_.onMouseMove = _loc1_.onMouseMoveFunc;
   };
   _loc1_.cursorMC.onMouseMoveFunc = function()
   {
      var _loc1_ = this;
      var _loc3_ = _loc1_._parent._ymouse - _loc1_.yOffset;
      var _loc2_ = _loc1_._parent.scale * (_loc1_._parent.equator - _loc3_);
      _loc1_._parent._parent.onLatitudeChangedViaMap(_loc2_);
      updateAfterEvent();
   };
   _loc1_.cursorMC.onRelease = _loc1_.cursorMC.onReleaseOutside = function()
   {
      delete this.onMouseMove;
   };
   _loc1_.mapMC.tabEnabled = false;
   _loc1_.mapMC.useHandCursor = false;
   _loc1_.mapMC.onPress = function()
   {
      var _loc1_ = this;
      if(_loc1_._parent._ymouse < _loc1_._parent.cursorMC._y)
      {
         _loc1_._parent._parent.onLatitudeChangedViaMap(_loc1_._parent._parent.latitude + 0.1);
      }
      else if(_loc1_._parent._ymouse > _loc1_._parent.cursorMC._y)
      {
         _loc1_._parent._parent.onLatitudeChangedViaMap(_loc1_._parent._parent.latitude - 0.1);
      }
      _loc1_.timeLast = getTimer();
      _loc1_.wait = _loc1_.timeLast + 750;
      _loc1_.onEnterFrame = _loc1_.onEnterFrameFunc;
   };
   _loc1_.mapMC.onEnterFrameFunc = function()
   {
      var _loc1_ = this;
      var _loc2_ = getTimer();
      var _loc3_;
      if(_loc2_ > _loc1_.wait)
      {
         var rate = 0.01;
         _loc3_ = rate * (_loc2_ - _loc1_.timeLast);
         if(_loc1_._parent._ymouse < _loc1_._parent.cursorMC._y)
         {
            _loc1_._parent._parent.onLatitudeChangedViaMap(_loc1_._parent._parent.latitude + _loc3_);
         }
         else if(_loc1_._parent._ymouse > _loc1_._parent.cursorMC._y)
         {
            _loc1_._parent._parent.onLatitudeChangedViaMap(_loc1_._parent._parent.latitude - _loc3_);
         }
      }
      _loc1_.timeLast = _loc2_;
   };
   _loc1_.mapMC.onRelease = _loc1_.mapMC.onReleaseOutside = function()
   {
      delete this.onEnterFrame;
   };
}
var p = LatitudeSelectorClass.prototype = new MovieClip();
Object.registerClass("Latitude Selector",LatitudeSelectorClass);
p.setCursorLatitude = function(arg)
{
   var _loc1_ = this;
   _loc1_.cursorMC._y = _loc1_.equator - arg / _loc1_.scale;
};
