function TimeOfDayClockClass()
{
   this.minuteHandBlurMC._xscale = this.minuteHandBlurMC._yscale = this.minuteHandSteadyBlurMC._xscale;
   this.hourHandMC.gotoAndStop(1);
   this.hourHandMC.useHandCursor = false;
   this.hourHandMC.onRollOver = function()
   {
      this.gotoAndStop(2);
   };
   this.hourHandMC.onPress = function()
   {
      this._parent._parent.masterMC.pauseAnimation();
      this.angleOffset = 0.017453292519943295 * this._rotation - Math.atan2(this._parent._ymouse,this._parent._xmouse);
      this.onMouseMove = this.onMouseMoveFunc;
   };
   this.hourHandMC.onMouseMoveFunc = function()
   {
      var _loc2_ = (this.angleOffset + Math.atan2(this._parent._ymouse,this._parent._xmouse)) / 6.283185307179586;
      _loc2_ = (_loc2_ % 1 + 1) % 1;
      var _loc3_ = 24 * _loc2_;
      var _loc4_;
      if(_loc3_ < 6 && this._parent._clockHour >= 18)
      {
         _loc4_ = this._parent._parent.masterMC.getDayOfYear() + _loc2_ + 1;
         this._parent._parent.masterMC.setDay(_loc4_);
      }
      else if(_loc3_ >= 18 && this._parent._clockHour < 6)
      {
         _loc4_ = this._parent._parent.masterMC.getDayOfYear() + _loc2_ - 1;
         this._parent._parent.masterMC.setDay(_loc4_);
      }
      else
      {
         this._parent._parent.masterMC.setTimeOfDay(_loc2_);
      }
      updateAfterEvent();
   };
   this.hourHandMC.onRelease = function()
   {
      this._parent._parent.masterMC.resumeAnimation();
      delete this.onMouseMove;
   };
   this.hourHandMC.onReleaseOutside = function()
   {
      this.gotoAndStop(1);
      this._parent._parent.masterMC.resumeAnimation();
      delete this.onMouseMove;
   };
   this.hourHandMC.onRollOut = function()
   {
      this.gotoAndStop(1);
   };
   this.pivotMC.useHandCursor = false;
   this.pivotMC.onPress = function()
   {
   };
   this.minuteHandMC.gotoAndStop(1);
   this.minuteHandMC.useHandCursor = false;
   this.minuteHandMC.onRollOver = function()
   {
      this.gotoAndStop(2);
   };
   this.minuteHandMC.onPress = function()
   {
      this._parent._parent.masterMC.pauseAnimation();
      this.angleOffset = 0.017453292519943295 * this._rotation - Math.atan2(this._parent._ymouse,this._parent._xmouse);
      this.onMouseMove = this.onMouseMoveFunc;
   };
   this.minuteHandMC.onMouseMoveFunc = function()
   {
      var _loc2_ = (this.angleOffset + Math.atan2(this._parent._ymouse,this._parent._xmouse)) / 6.283185307179586;
      _loc2_ = (_loc2_ % 1 + 1) % 1;
      var _loc3_;
      if(this._parent._clockMinute > 45 && _loc2_ < 0.25)
      {
         if(this._parent._clockHour == 23)
         {
            _loc3_ = this._parent._parent.masterMC.getDayOfYear() + _loc2_ / 24 + 1;
            this._parent._parent.masterMC.setDay(_loc3_);
         }
         else
         {
            this._parent._parent.masterMC.setTimeOfDay((this._parent._clockHour + _loc2_ + 1) / 24);
         }
      }
      else if(this._parent._clockMinute < 15 && _loc2_ > 0.75)
      {
         if(this._parent._clockHour == 0)
         {
            _loc3_ = this._parent._parent.masterMC.getDayOfYear() + (23 + _loc2_) / 24 - 1;
            this._parent._parent.masterMC.setDay(_loc3_);
         }
         else
         {
            this._parent._parent.masterMC.setTimeOfDay((this._parent._clockHour + _loc2_ - 1) / 24);
         }
      }
      else
      {
         this._parent._parent.masterMC.setTimeOfDay((this._parent._clockHour + _loc2_) / 24);
      }
      updateAfterEvent();
   };
   this.minuteHandMC.onRelease = function()
   {
      this._parent._parent.masterMC.resumeAnimation();
      delete this.onMouseMove;
   };
   this.minuteHandMC.onReleaseOutside = function()
   {
      this.gotoAndStop(1);
      this._parent._parent.masterMC.resumeAnimation();
      delete this.onMouseMove;
   };
   this.minuteHandMC.onRollOut = function()
   {
      this.gotoAndStop(1);
   };
   this.setClockTime(this._parent.masterMC.getTimeOfDay());
}
var p = TimeOfDayClockClass.prototype = new MovieClip();
Object.registerClass("Time Of Day Clock",TimeOfDayClockClass);
p.setClockTime = function(arg)
{
   this._clockHour = Math.floor(24 * arg);
   this._clockMinute = 60 * (24 * arg - this._clockHour);
   this.hourHandMC._rotation = 360 * arg;
   var _loc6_;
   var _loc5_;
   var _loc4_;
   var _loc3_;
   var _loc2_;
   if(this._parent.masterMC.animationState && !this._parent.masterMC.stepByDay)
   {
      _loc6_ = this._parent.masterMC._speed * this._parent.masterMC.lastDeltaT;
      _loc5_ = 0.012499999999999999;
      if(_loc6_ > _loc5_)
      {
         this.minuteHandBlurMC._visible = true;
         this.minuteHandSteadyBlurMC._visible = true;
         this.minuteHandBlurMC._alpha = this.minuteHandMC._alpha = 50 - 1000 * (_loc6_ - _loc5_);
         this.minuteHandSteadyBlurMC._alpha = 100 - this.minuteHandMC._alpha;
         this.minuteHandBlurMC.drawBlur(360);
      }
      else
      {
         this.minuteHandBlurMC._visible = true;
         this.minuteHandSteadyBlurMC._visible = false;
         this.minuteHandBlurMC._alpha = this.minuteHandMC._alpha = 100;
         _loc4_ = 6 * this._clockMinute;
         _loc3_ = this.minuteHandMC._rotation;
         _loc4_ = (_loc4_ % 360 + 360) % 360;
         _loc3_ = (_loc3_ % 360 + 360) % 360;
         _loc2_ = _loc4_ - _loc3_;
         if(_loc2_ < 0)
         {
            _loc2_ = 360 + _loc2_;
         }
         this.minuteHandBlurMC.drawBlur(_loc2_);
      }
   }
   else
   {
      this.minuteHandBlurMC._visible = false;
      this.minuteHandSteadyBlurMC._visible = false;
      this.minuteHandMC._alpha = 100;
   }
   this.minuteHandBlurMC._rotation = this.minuteHandMC._rotation = 6 * this._clockMinute;
};
