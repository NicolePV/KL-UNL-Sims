function AnimationSpeedSliderClass()
{
   this.leftExtent = (- this.barMC._width) / 2;
   this.grabberMC.useHandCursor = false;
   this.grabberMC.onPress = function()
   {
      this.xOffset = this._parent._xmouse - this._x;
      this.onMouseMove = this.onMouseMoveFunc;
   };
   this.grabberMC.onMouseMoveFunc = function()
   {
      var _loc3_ = this._parent._xmouse - this.xOffset - this._parent.leftExtent;
      var _loc2_ = this._parent.minValue * Math.exp(this._parent.scaleFactor * _loc3_);
      this._parent._parent.masterMC.setAnimationSpeed(_loc2_);
      updateAfterEvent();
   };
   this.grabberMC.onRelease = this.grabberMC.onReleaseOutside = function()
   {
      delete this.onMouseMove;
   };
   this.barMC.useHandCursor = false;
   this.barMC.onPress = function()
   {
      if(this._parent._xmouse < this._parent.grabberMC._x)
      {
         this._parent.incrementBy(-1);
      }
      else
      {
         this._parent.incrementBy(1);
      }
      this.timeLast = getTimer();
      this.wait = this.timeLast + 750;
      this.onEnterFrame = this.onEnterFrameFunc;
   };
   this.barMC.onEnterFrameFunc = function()
   {
      var _loc2_ = getTimer();
      var _loc4_;
      var _loc3_;
      if(_loc2_ > this.wait)
      {
         _loc4_ = 0.01;
         _loc3_ = Math.ceil(_loc4_ * (_loc2_ - this.timeLast));
         if(this._parent._xmouse < this._parent.grabberMC._x)
         {
            this._parent.incrementBy(- _loc3_);
         }
         else
         {
            this._parent.incrementBy(_loc3_);
         }
      }
      this.timeLast = _loc2_;
   };
   this.barMC.onRelease = this.barMC.onReleaseOutside = function()
   {
      delete this.onEnterFrame;
   };
}
var p = AnimationSpeedSliderClass.prototype = new MovieClip();
Object.registerClass("AnimationSpeedSlider",AnimationSpeedSliderClass);
p.setLimits = function(min, max)
{
   this.minValue = min;
   this.maxValue = max;
   this.scaleFactor = Math.log(this.maxValue / this.minValue) / this.barMC._width;
};
p.regimes = [{unit:"min",precision:0,rightLimit:0.00008333333333333333,ratio:6.944444444444445e-7},{unit:"hr",precision:1,rightLimit:0.00025,ratio:0.000041666666666666665},{unit:"hr",precision:0,rightLimit:0.001,ratio:0.000041666666666666665},{unit:"day",precision:1,rightLimit:0.01,ratio:0.001},{unit:"day",precision:0,rightLimit:0.123,ratio:0.001}];
p.incrementBy = function(arg)
{
   var _loc5_ = this.regimes[this.currentRegimeIndex];
   var _loc6_ = 1 / Math.pow(10,_loc5_.precision);
   var _loc11_ = this.regimeValue + arg * _loc6_;
   var _loc3_ = _loc11_ * _loc5_.ratio;
   var _loc2_ = 0;
   while(_loc3_ > this.regimes[_loc2_].rightLimit - 1e-12 && _loc2_ < this.regimes.length)
   {
      _loc2_ = _loc2_ + 1;
   }
   var _loc4_;
   if(_loc2_ == this.regimes.length)
   {
      _loc4_ = _loc2_ - 1;
   }
   else
   {
      _loc4_ = _loc2_;
   }
   var _loc7_;
   var _loc9_;
   var _loc10_;
   var _loc8_;
   if(_loc4_ < this.currentRegimeIndex)
   {
      _loc4_ = this.currentRegimeIndex - 1;
      _loc7_ = this.regimes[_loc4_];
      _loc9_ = _loc7_.rightLimit / _loc7_.ratio;
      _loc6_ = 1 / Math.pow(10,_loc7_.precision);
      _loc11_ = _loc6_ * Math.ceil(_loc9_ / _loc6_) - _loc6_;
      this._parent.masterMC.setAnimationSpeed(_loc11_ * _loc7_.ratio);
   }
   else if(_loc4_ > this.currentRegimeIndex)
   {
      _loc4_ = this.currentRegimeIndex + 1;
      _loc7_ = this.regimes[_loc4_];
      _loc10_ = _loc5_.rightLimit / _loc7_.ratio;
      _loc8_ = 1 / Math.pow(10,_loc7_.precision);
      _loc11_ = _loc8_ * Math.ceil(_loc10_ / _loc8_);
      this._parent.masterMC.setAnimationSpeed(_loc11_ * _loc7_.ratio);
   }
   else
   {
      this._parent.masterMC.setAnimationSpeed(_loc3_);
   }
};
p.getValue = function()
{
   return this._value;
};
p.setValue = function(arg)
{
   var _loc2_ = 0;
   while(arg > this.regimes[_loc2_].rightLimit - 1e-12 && _loc2_ < this.regimes.length)
   {
      _loc2_ = _loc2_ + 1;
   }
   if(_loc2_ == this.regimes.length)
   {
      this.currentRegimeIndex = _loc2_ - 1;
   }
   else
   {
      this.currentRegimeIndex = _loc2_;
   }
   var _loc4_ = this.regimes[this.currentRegimeIndex];
   var _loc3_ = arg / _loc4_.ratio;
   var _loc7_;
   var _loc6_;
   if(_loc4_.precision > 0)
   {
      _loc7_ = _loc3_.toFixed(_loc4_.precision);
      _loc3_ = parseFloat(_loc7_);
   }
   else
   {
      _loc6_ = Math.pow(10,_loc4_.precision);
      _loc3_ = Math.round(_loc6_ * _loc3_) / _loc6_;
      if(_loc3_ == 0)
      {
         _loc3_ = 1 / _loc6_;
      }
      _loc7_ = String(_loc3_);
   }
   this._value = arg;
   this.regimeValue = _loc3_;
   if(_loc3_ == 1)
   {
      this.speedValueString = _loc7_ + " " + _loc4_.unit + "/sec";
   }
   else
   {
      this.speedValueString = _loc7_ + " " + _loc4_.unit + "s/sec";
   }
   this.grabberMC._x = Math.log(this._value / this.minValue) / this.scaleFactor + this.leftExtent;
};
p.addProperty("value",p.getValue,p.setValue);
