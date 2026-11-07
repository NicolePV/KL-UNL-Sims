function SunIconClass()
{
   this.stop();
}
var p = SunIconClass.prototype = new MovieClip();
Object.registerClass("Sun Icon",SunIconClass);
p.setDraggable = function(arg)
{
   if(arg)
   {
      this.onRollOver = this.onRollOverFunc;
      this.onRollOut = this.onRollOutFunc;
      this.onRelease = this.onReleaseFunc;
      this.onReleaseOutside = this.onReleaseOutsideFunc;
      this.onPress = this.onPressFunc;
      delete this.onMouseMove;
   }
   else
   {
      delete this.onRollOver;
      delete this.onRollOut;
      delete this.onRelease;
      delete this.onReleaseOutside;
      delete this.onPress;
      delete this.onMouseMove;
   }
};
p.useHandCursor = false;
p.onRollOverFunc = function()
{
   this.gotoAndStop(2);
   this._sphere._parent.showSunArcs();
};
p.onRollOutFunc = function()
{
   this.gotoAndStop(1);
   this._sphere._parent.hideSunArcs();
};
p.onPressFunc = function()
{
   var _loc3_ = this._sphere._c;
   var _loc4_ = _loc3_.r;
   var _loc6_ = this._sphere._xmouse;
   var _loc5_ = this._sphere._ymouse;
   var _loc2_ = Math.sqrt(_loc6_ * _loc6_ + _loc5_ * _loc5_);
   var _loc7_;
   if(_loc2_ > _loc4_)
   {
      _loc6_ *= _loc4_ / _loc2_;
      _loc5_ *= _loc4_ / _loc2_;
      _loc7_ = 0;
      this.sideLast = 0;
   }
   else if(this._object._sp.z > 0)
   {
      _loc7_ = Math.sqrt(_loc4_ * _loc4_ - _loc2_ * _loc2_);
      this.sideLast = 1;
   }
   else
   {
      _loc7_ = - Math.sqrt(_loc4_ * _loc4_ - _loc2_ * _loc2_);
      this.sideLast = 0;
   }
   var _loc8_ = 3.819718634205488 * Math.atan2(_loc3_.b1 * _loc6_ + _loc3_.b4 * _loc5_ + _loc3_.b7 * _loc7_,_loc3_.b0 * _loc6_ + _loc3_.b3 * _loc5_ + _loc3_.b6 * _loc7_);
   this.transitionMade = false;
   this.raOffset = _loc8_ - this._object.ra;
   this.onMouseMove = this.onMouseMoveFunc;
};
p.onMouseMoveFunc = function()
{
   var _loc3_ = this._sphere._c;
   var _loc4_ = _loc3_.r;
   var _loc6_ = this._sphere._xmouse;
   var _loc5_ = this._sphere._ymouse;
   var _loc2_ = Math.sqrt(_loc6_ * _loc6_ + _loc5_ * _loc5_);
   var _loc7_;
   if(_loc2_ > _loc4_)
   {
      _loc6_ *= _loc4_ / _loc2_;
      _loc5_ *= _loc4_ / _loc2_;
      _loc7_ = 0;
      if(!this.transitionMade)
      {
         this.sideLast = (this.sideLast + 1) % 2;
      }
      this.transitionMade = true;
   }
   else if(this.sideLast == 1)
   {
      _loc7_ = Math.sqrt(_loc4_ * _loc4_ - _loc2_ * _loc2_);
      this.transitionMade = false;
   }
   else
   {
      _loc7_ = - Math.sqrt(_loc4_ * _loc4_ - _loc2_ * _loc2_);
      this.transitionMade = false;
   }
   var _loc9_ = 3.819718634205488 * Math.atan2(_loc3_.b1 * _loc6_ + _loc3_.b4 * _loc5_ + _loc3_.b7 * _loc7_,_loc3_.b0 * _loc6_ + _loc3_.b3 * _loc5_ + _loc3_.b6 * _loc7_) - this.raOffset;
   var _loc10_ = (15 * (_loc9_ - 12) - 270) * 1.0138888888888888;
   var _loc8_ = ((Math.round(_loc10_) - 286) % 365 + 365) % 365;
   this._sphere._parent.changeDayOfYear(_loc8_);
   this._sphere._parent.daySlider.value = _loc8_;
   updateAfterEvent();
};
p.onReleaseFunc = function()
{
   delete this.onMouseMove;
};
p.onReleaseOutsideFunc = function()
{
   this.gotoAndStop(1);
   this._sphere._parent.hideSunArcs();
   delete this.onMouseMove;
};
