function SweepTimeSliderClass()
{
   var _loc1_ = this;
   _loc1_._prec = 1;
   _loc1_.grabberMC.useHandCursor = false;
   _loc1_.grabberMC.onPress = function()
   {
      var _loc1_ = this;
      _loc1_._xOffset = _loc1_._parent._xmouse - _loc1_._x;
      _loc1_.onMouseMove = _loc1_.onMouseMoveFunc;
   };
   _loc1_.grabberMC.onMouseMoveFunc = function()
   {
      var _loc1_ = this;
      var _loc2_ = _loc1_._parent.getValueFromPosition(_loc1_._parent._xmouse - _loc1_._xOffset);
      _loc1_._parent.setValue(_loc2_,true);
      updateAfterEvent();
   };
   _loc1_.grabberMC.onRelease = _loc1_.grabberMC.onReleaseOutside = function()
   {
      this.onMouseMove = undefined;
   };
   _loc1_.barMC._holdDelay = 500;
   _loc1_.barMC.useHandCursor = false;
   _loc1_.barMC.onPress = function()
   {
      var _loc1_ = this;
      if(_loc1_._parent._xmouse > _loc1_._parent.grabberMC._x)
      {
         _loc1_._parent.incrementValue(1,true);
      }
      else
      {
         _loc1_._parent.incrementValue(-1,true);
      }
      _loc1_._startAuto = getTimer() + _loc1_._holdDelay;
      _loc1_.onEnterFrame = _loc1_.onEnterFrameFunc;
   };
   _loc1_.barMC.onEnterFrameFunc = function()
   {
      var _loc1_ = this;
      if(getTimer() > _loc1_._startAuto)
      {
         if(_loc1_._parent._xmouse > _loc1_._parent.grabberMC._x)
         {
            _loc1_._parent.incrementValue(1,true);
         }
         else
         {
            _loc1_._parent.incrementValue(-1,true);
         }
      }
   };
   _loc1_.barMC.onRelease = _loc1_.barMC.onReleaseOutside = function()
   {
      this.onEnterFrame = undefined;
   };
   _loc1_._range = _loc1_.barMC._width + 2 * _loc1_.barMC._x;
   _loc1_.setMin(_loc1_.initMinDenom);
   _loc1_.setMax(_loc1_.initMaxDenom);
   _loc1_.setValue(_loc1_.initDenom);
}
var p = SweepTimeSliderClass.prototype = new MovieClip();
Object.registerClass("Sweep Time Slider",SweepTimeSliderClass);
p.textColorWhileEditing = 16711680;
p.textColorOtherwise = 0;
p.onKeyDown = function()
{
   if(Key.isDown(13))
   {
      this.setValue(parseFloat(this.valueField.text),true);
   }
};
p.getValue = function()
{
   return this._value;
};
p.setValue = function(arg, callHandler)
{
   var _loc1_ = this;
   var _loc2_ = Number(arg);
   if(isFinite(_loc2_) && !isNaN(_loc2_))
   {
      if(_loc2_ < _loc1_._min)
      {
         _loc2_ = _loc1_._min;
      }
      else if(_loc2_ > _loc1_._max)
      {
         _loc2_ = _loc1_._max;
      }
      _loc1_._value = Math.round(_loc2_);
      _loc1_.grabberMC._x = _loc1_.getPositionFromValue(_loc1_._value);
      if(callHandler)
      {
         _loc1_._parent[_loc1_.changeHandler](_loc1_._value);
      }
   }
   _loc1_.valueField.text = _loc1_._value;
};
p.addProperty("value",p.getValue,p.setValue);
p.incrementValue = function(deltaTicks, callHandler)
{
   this.setValue(this._value + 2 * deltaTicks,callHandler);
};
p.getMin = function()
{
   return this._min;
};
p.setMin = function(arg)
{
   var _loc1_ = this;
   _loc1_._min = arg;
   _loc1_._scale = (_loc1_._max - _loc1_._min) / _loc1_._range;
};
p.addProperty("min",p.getMin,p.setMin);
p.getMax = function()
{
   return this._max;
};
p.setMax = function(arg)
{
   var _loc1_ = this;
   _loc1_._max = arg;
   _loc1_._scale = (_loc1_._max - _loc1_._min) / _loc1_._range;
};
p.addProperty("max",p.getMax,p.setMax);
p.getValueFromPosition = function(pos)
{
   var _loc1_ = this;
   return _loc1_._scale * (_loc1_._range - pos) + _loc1_._min;
};
p.getPositionFromValue = function(val)
{
   var _loc1_ = this;
   return _loc1_._range - (val - _loc1_._min) / _loc1_._scale;
};
p.toFixed = function(x)
{
   var _loc2_ = this._prec;
   var s = "";
   if(x < 0)
   {
      s = "-";
      x = - x;
   }
   var _loc3_ = "";
   var _loc1_;
   if(x < 1e+21)
   {
      var n = Math.round(x * Math.pow(10,_loc2_));
      if(n == 0)
      {
         _loc3_ = "0";
      }
      else
      {
         _loc3_ = n.toString();
      }
      if(_loc2_ > 0)
      {
         var k = _loc3_.length;
         if(k <= _loc2_)
         {
            var z = "";
            _loc1_ = 0;
            while(_loc1_ < _loc2_ + 1 - k)
            {
               z += "0";
               _loc1_ = _loc1_ + 1;
            }
            _loc3_ = z + _loc3_;
            k = _loc2_ + 1;
         }
         var a = _loc3_.substr(0,k - _loc2_);
         var b = _loc3_.substr(k - _loc2_);
         _loc3_ = a + "." + b;
      }
   }
   else
   {
      _loc3_ = x.toString();
   }
   return s + _loc3_;
};
