function LatitudeSelectorClass()
{
   this.equator = this.mapMC._height / 2;
   this.scale = 180 / this.mapMC._height;
   this.cursorMC.useHandCursor = false;
   this.cursorMC.onPress = function()
   {
      this._parent._parent.masterMC.pauseAnimation();
      this.yOffset = this._parent._ymouse - this._y;
      this.onMouseMove = this.onMouseMoveFunc;
   };
   this.cursorMC.onMouseMoveFunc = function()
   {
      var _loc3_ = this._parent._ymouse - this.yOffset;
      var _loc2_ = this._parent.scale * (this._parent.equator - _loc3_);
      this._parent._parent.masterMC.setLatitude(_loc2_);
      updateAfterEvent();
   };
   this.cursorMC.onRelease = this.cursorMC.onReleaseOutside = function()
   {
      this._parent._parent.masterMC.resumeAnimation();
      delete this.onMouseMove;
   };
   this.mapMC.useHandCursor = false;
   this.mapMC.onPress = function()
   {
      this._parent._parent.masterMC.pauseAnimation();
      if(this._parent._ymouse < this._parent.cursorMC._y)
      {
         this._parent._parent.masterMC.setLatitude(this._parent._parent._panelLatitude + this._parent._parent.minStep);
      }
      else if(this._parent._ymouse > this._parent.cursorMC._y)
      {
         this._parent._parent.masterMC.setLatitude(this._parent._parent._panelLatitude - this._parent._parent.minStep);
      }
      this.timeLast = getTimer();
      this.wait = this.timeLast + 750;
      this.onEnterFrame = this.onEnterFrameFunc;
   };
   this.mapMC.onEnterFrameFunc = function()
   {
      var _loc2_ = getTimer();
      var _loc4_;
      var _loc3_;
      if(_loc2_ > this.wait)
      {
         _loc4_ = 0.005;
         _loc3_ = _loc4_ * (_loc2_ - this.timeLast);
         if(this._parent._ymouse < this._parent.cursorMC._y)
         {
            this._parent._parent.masterMC.setLatitude(this._parent._parent._panelLatitude + _loc3_);
         }
         else if(this._parent._ymouse > this._parent.cursorMC._y)
         {
            this._parent._parent.masterMC.setLatitude(this._parent._parent._panelLatitude - _loc3_);
         }
      }
      this.timeLast = _loc2_;
   };
   this.mapMC.onRelease = this.mapMC.onReleaseOutside = function()
   {
      this._parent._parent.masterMC.resumeAnimation();
      delete this.onEnterFrame;
   };
   this.setCursorLatitude(this._parent._panelLatitude);
}
var p = LatitudeSelectorClass.prototype = new MovieClip();
Object.registerClass("Latitude Selector",LatitudeSelectorClass);
p.setCursorLatitude = function(arg)
{
   this.cursorMC._y = this.equator - arg / this.scale;
};
