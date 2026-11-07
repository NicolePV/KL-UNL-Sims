function Slider4Class()
{
   var _loc1_ = this;
   var _loc3_ = _root;
   _loc1_.valueField.restrict = "0-9.Ee+\\-";
   _loc1_.valueField.onChanged = function()
   {
      var _loc1_ = this;
      _loc1_.setTextFormat(_loc1_._parent.textFormatWhileEditing);
      _loc1_.setNewTextFormat(_loc1_._parent.textFormatWhileEditing);
      Key.addListener(_loc1_._parent);
   };
   _loc1_.valueField.onKillFocus = function()
   {
      var _loc1_ = this;
      var _loc2_ = _root;
      if(_loc1_._parent.grabberMC.hitTest(_loc2_._xmouse,_loc2_._ymouse,true) || _loc1_._parent.barMC.hitTest(_loc2_._xmouse,_loc2_._ymouse,true))
      {
         _loc1_._parent.setValue(NaN);
      }
      else
      {
         _loc1_._parent.setValue(parseFloat(_loc1_.text),true);
      }
   };
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
      delete this.onEnterFrame;
   };
   _loc1_._range = _loc1_.barMC._width + 2 * _loc1_.barMC._x;
   if(_loc1_.initScaleMode == "linear")
   {
      _loc1_._scaleMode = 0;
   }
   else
   {
      _loc1_._scaleMode = 1;
   }
   var _loc2_;
   if(_loc1_.initPrecisionMode == "significant digits")
   {
      _loc1_._precisionMode = 0;
      _loc2_ = Math.abs(parseInt(_loc1_.initPrecision));
      if(!isFinite(_loc2_) || isNaN(_loc2_) || _loc2_ == 0)
      {
         _loc2_ = 1;
      }
      _loc1_._sigs = _loc2_;
      _loc1_._tickResolution = Math.pow(10,_loc2_);
   }
   else
   {
      _loc1_._precisionMode = 1;
      _loc2_ = parseInt(_loc1_.initPrecision);
      if(!isFinite(_loc2_) || isNaN(_loc2_))
      {
         _loc2_ = 1;
      }
      _loc1_._prec = _loc2_;
      _loc1_._minIncrement = Math.pow(10,- _loc2_);
   }
   _loc1_.setMin(_loc1_.initMinValue);
   _loc1_.setMax(_loc1_.initMaxValue);
   _loc1_.setValue(_loc1_.initValue);
}
var p = Slider4Class.prototype = new MovieClip();
Object.registerClass("Slider v4 Component",Slider4Class);
p.textFormatWhileEditing = new TextFormat("Verdana",12,0,false,true);
p.textFormatOtherwise = new TextFormat("Verdana",12,0,false,false);
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
      if(_loc1_._precisionMode == 0)
      {
         _loc1_._valueDecade = 1 + Math.floor(Math.log(_loc2_) / 2.302585092994046);
         _loc1_._valuePow = Math.pow(10,_loc1_._valueDecade);
         _loc1_._valueTick = Math.round(_loc2_ * _loc1_._tickResolution / _loc1_._valuePow);
         if(_loc1_._valueTick == _loc1_._tickResolution)
         {
            _loc1_._valueTick = _loc1_._tickResolution / 10;
            _loc1_._valueDecade = _loc1_._valueDecade + 1;
            _loc1_._valuePow = Math.pow(10,_loc1_._valueDecade);
         }
         _loc1_._value = _loc1_._valueTick / _loc1_._tickResolution * _loc1_._valuePow;
         _loc1_._prec = _loc1_._sigs - _loc1_._valueDecade;
      }
      else
      {
         _loc1_._value = _loc1_._minIncrement * Math.round(_loc2_ / _loc1_._minIncrement);
      }
      _loc1_.grabberMC._x = _loc1_.getPositionFromValue(_loc1_._value);
      if(callHandler)
      {
         _loc1_._parent[_loc1_.changeHandler](_loc1_._value);
      }
   }
   _loc1_.valueField.setTextFormat(_loc1_.textFormatOtherwise);
   _loc1_.valueField.setNewTextFormat(_loc1_.textFormatOtherwise);
   Key.removeListener(_loc1_);
   if(_loc1_._prec > 0)
   {
      _loc1_.valueField.text = _loc1_.toFixed(_loc1_._value);
   }
   else
   {
      _loc1_.valueField.text = _loc1_._value;
   }
};
p.addProperty("value",p.getValue,p.setValue);
p.incrementValue = function(deltaTicks, callHandler)
{
   var _loc1_ = this;
   var _loc3_ = deltaTicks;
   var _loc2_;
   if(_loc1_._precisionMode == 0)
   {
      var ticksPerDecade = 0.9 * _loc1_._tickResolution;
      var fracDecades = _loc3_ / ticksPerDecade;
      var deltaDecade = 0;
      if(fracDecades >= 1)
      {
         deltaDecade = Math.floor(fracDecades);
         _loc3_ -= deltaDecade * ticksPerDecade;
      }
      else if(fracDecades <= -1)
      {
         deltaDecade = Math.ceil(fracDecades);
         _loc3_ -= deltaDecade * ticksPerDecade;
      }
      _loc2_ = _loc1_._valueTick + _loc3_;
      var newDecade = _loc1_._valueDecade + deltaDecade;
      if(_loc2_ >= _loc1_._tickResolution)
      {
         _loc2_ -= ticksPerDecade;
         newDecade++;
      }
      else if(_loc2_ < 0.1 * _loc1_._tickResolution)
      {
         _loc2_ += ticksPerDecade;
         newDecade--;
      }
      _loc1_.setValue(Math.pow(10,newDecade) * _loc2_ / _loc1_._tickResolution,callHandler);
   }
   else
   {
      _loc1_.setValue(_loc1_._value + _loc3_ * _loc1_._minIncrement,callHandler);
   }
};
p.getMin = function()
{
   return this._min;
};
p.setMin = function(arg)
{
   var _loc1_ = this;
   _loc1_._min = arg;
   if(_loc1_._scaleMode == 0)
   {
      _loc1_._scale = (_loc1_._max - _loc1_._min) / _loc1_._range;
   }
   else
   {
      _loc1_._logMin = Math.log(_loc1_._min);
      _loc1_._scale = (Math.log(_loc1_._max) - _loc1_._logMin) / _loc1_._range;
   }
   _loc1_.setValue(NaN);
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
   if(_loc1_._scaleMode == 0)
   {
      _loc1_._scale = (_loc1_._max - _loc1_._min) / _loc1_._range;
   }
   else
   {
      _loc1_._scale = (Math.log(_loc1_._max) - _loc1_._logMin) / _loc1_._range;
   }
   _loc1_.setValue(NaN);
};
p.addProperty("max",p.getMax,p.setMax);
p.getValueFromPosition = function(pos)
{
   var _loc1_ = this;
   if(_loc1_._scaleMode == 0)
   {
      return pos * _loc1_._scale + _loc1_._min;
   }
   return Math.exp(pos * _loc1_._scale + _loc1_._logMin);
};
p.getPositionFromValue = function(val)
{
   var _loc1_ = this;
   if(_loc1_._scaleMode == 0)
   {
      return (val - _loc1_._min) / _loc1_._scale;
   }
   return (Math.log(val) - _loc1_._logMin) / _loc1_._scale;
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
