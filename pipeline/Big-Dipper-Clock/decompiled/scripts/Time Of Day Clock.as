function TimeOfDayClockClass()
{
   var _loc1_ = this;
   _loc1_.minuteHandBlurMC._xscale = _loc1_.minuteHandBlurMC._yscale = _loc1_.minuteHandSteadyBlurMC._xscale;
   _loc1_.hourHandMC.gotoAndStop(1);
   _loc1_.hourHandMC.useHandCursor = false;
   _loc1_.hourHandMC.onRollOver = function()
   {
      this.gotoAndStop(2);
   };
   _loc1_.hourHandMC.onPress = function()
   {
      var _loc1_ = this;
      _loc1_._parent._parent.masterMC.pauseAnimation();
      _loc1_.angleOffset = 0.017453292519943295 * _loc1_._rotation - Math.atan2(_loc1_._parent._ymouse,_loc1_._parent._xmouse);
      _loc1_.onMouseMove = _loc1_.onMouseMoveFunc;
   };
   _loc1_.hourHandMC.onMouseMoveFunc = function()
   {
      var _loc1_ = this;
      var _loc2_ = (_loc1_.angleOffset + Math.atan2(_loc1_._parent._ymouse,_loc1_._parent._xmouse)) / 6.283185307179586;
      _loc2_ = (_loc2_ % 1 + 1) % 1;
      var _loc3_ = 24 * _loc2_;
      if(_loc3_ < 6 && _loc1_._parent._clockHour >= 18)
      {
         var newDay = _loc1_._parent._parent.masterMC.getDayOfYear() + _loc2_ + 1;
         _loc1_._parent._parent.masterMC.setFracDayOfYear(newDay);
      }
      else if(_loc3_ >= 18 && _loc1_._parent._clockHour < 6)
      {
         var newDay = _loc1_._parent._parent.masterMC.getDayOfYear() + _loc2_ - 1;
         _loc1_._parent._parent.masterMC.setFracDayOfYear(newDay);
      }
      else
      {
         _loc1_._parent._parent.masterMC.setTimeOfDay(_loc2_);
      }
      updateAfterEvent();
   };
   _loc1_.hourHandMC.onRelease = function()
   {
      this._parent._parent.masterMC.resumeAnimation();
      delete this.onMouseMove;
   };
   _loc1_.hourHandMC.onReleaseOutside = function()
   {
      var _loc1_ = this;
      _loc1_.gotoAndStop(1);
      _loc1_._parent._parent.masterMC.resumeAnimation();
      delete _loc1_.onMouseMove;
   };
   _loc1_.hourHandMC.onRollOut = function()
   {
      this.gotoAndStop(1);
   };
   _loc1_.pivotMC.useHandCursor = false;
   _loc1_.pivotMC.onPress = function()
   {
   };
   _loc1_.minuteHandMC.gotoAndStop(1);
   _loc1_.minuteHandMC.useHandCursor = false;
   _loc1_.minuteHandMC.onRollOver = function()
   {
      this.gotoAndStop(2);
   };
   _loc1_.minuteHandMC.onPress = function()
   {
      var _loc1_ = this;
      _loc1_._parent._parent.masterMC.pauseAnimation();
      _loc1_.angleOffset = 0.017453292519943295 * _loc1_._rotation - Math.atan2(_loc1_._parent._ymouse,_loc1_._parent._xmouse);
      _loc1_.onMouseMove = _loc1_.onMouseMoveFunc;
   };
   _loc1_.minuteHandMC.onMouseMoveFunc = function()
   {
      var _loc1_ = this;
      var _loc2_ = (_loc1_.angleOffset + Math.atan2(_loc1_._parent._ymouse,_loc1_._parent._xmouse)) / 6.283185307179586;
      _loc2_ = (_loc2_ % 1 + 1) % 1;
      var _loc3_;
      if(_loc1_._parent._clockMinute > 45 && _loc2_ < 0.25)
      {
         if(_loc1_._parent._clockHour == 23)
         {
            _loc3_ = _loc1_._parent._parent.masterMC.getDayOfYear() + _loc2_ / 24 + 1;
            _loc1_._parent._parent.masterMC.setFracDayOfYear(_loc3_);
         }
         else
         {
            _loc1_._parent._parent.masterMC.setTimeOfDay((_loc1_._parent._clockHour + _loc2_ + 1) / 24);
         }
      }
      else if(_loc1_._parent._clockMinute < 15 && _loc2_ > 0.75)
      {
         if(_loc1_._parent._clockHour == 0)
         {
            _loc3_ = _loc1_._parent._parent.masterMC.getDayOfYear() + (23 + _loc2_) / 24 - 1;
            _loc1_._parent._parent.masterMC.setFracDayOfYear(_loc3_);
         }
         else
         {
            _loc1_._parent._parent.masterMC.setTimeOfDay((_loc1_._parent._clockHour + _loc2_ - 1) / 24);
         }
      }
      else
      {
         _loc1_._parent._parent.masterMC.setTimeOfDay((_loc1_._parent._clockHour + _loc2_) / 24);
      }
      updateAfterEvent();
   };
   _loc1_.minuteHandMC.onRelease = function()
   {
      this._parent._parent.masterMC.resumeAnimation();
      delete this.onMouseMove;
   };
   _loc1_.minuteHandMC.onReleaseOutside = function()
   {
      var _loc1_ = this;
      _loc1_.gotoAndStop(1);
      _loc1_._parent._parent.masterMC.resumeAnimation();
      delete _loc1_.onMouseMove;
   };
   _loc1_.minuteHandMC.onRollOut = function()
   {
      this.gotoAndStop(1);
   };
   _loc1_.minuteHandBlurMC._visible = false;
   _loc1_.minuteHandSteadyBlurMC._visible = false;
   _loc1_.minuteHandMC._alpha = 100;
}
var p = TimeOfDayClockClass.prototype = new MovieClip();
Object.registerClass("Time Of Day Clock",TimeOfDayClockClass);
p.setClockTime = function(arg)
{
   var _loc1_ = this;
   var _loc2_ = arg;
   _loc1_._clockHour = Math.floor(24 * _loc2_);
   _loc1_._clockMinute = 60 * (24 * _loc2_ - _loc1_._clockHour);
   _loc1_.hourHandMC._rotation = 360 * _loc2_;
   _loc1_.minuteHandBlurMC._visible = false;
   _loc1_.minuteHandSteadyBlurMC._visible = false;
   _loc1_.minuteHandMC._alpha = 100;
   _loc1_.minuteHandBlurMC._rotation = _loc1_.minuteHandMC._rotation = 6 * _loc1_._clockMinute;
};
