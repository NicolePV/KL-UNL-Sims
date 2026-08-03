function SliderV5Class()
{
   var _loc1_ = this;
   var _loc3_ = _root;
   _loc1_.valueField = _loc1_._parent[_loc1_.initValueFieldName];
   _loc1_.barMC = _loc1_._parent[_loc1_.initBarName];
   _loc1_.grabberMC = _loc1_._parent[_loc1_.initGrabberName];
   var _loc2_;
   if(_loc1_.barMC == undefined || _loc1_.grabberMC == undefined)
   {
      trace("**ERROR** bar and/or grabber undefined for slider: " + _loc1_);
   }
   else
   {
      _loc1_._sliderPixelRange = _loc1_.barMC.barWidth;
      _loc1_.valueField.sliderMC = _loc1_;
      _loc1_.valueField.restrict = "0-9.Ee+\\-";
      _loc1_.valueField.onChanged = function()
      {
         var _loc1_ = this;
         _loc1_.setTextFormat(_loc1_.sliderMC.textFormatWhileEditing);
         _loc1_.setNewTextFormat(_loc1_.sliderMC.textFormatWhileEditing);
         Key.addListener(_loc1_.sliderMC);
      };
      _loc1_.valueField.onKillFocus = function()
      {
         var _loc1_ = this;
         var _loc2_ = _root;
         if(_loc1_.sliderMC.grabberMC.hitTest(_loc2_._xmouse,_loc2_._ymouse,true) || _loc1_.sliderMC.barMC.hitTest(_loc2_._xmouse,_loc2_._ymouse,true))
         {
            _loc1_.sliderMC.setValue(NaN);
         }
         else
         {
            _loc1_.sliderMC.setValue(parseFloat(_loc1_.text),true);
         }
      };
      _loc1_.grabberMC.sliderMC = _loc1_;
      _loc1_.grabberMC.useHandCursor = false;
      _loc1_.grabberMC.onPress = function()
      {
         var _loc1_ = this;
         _loc1_._xOffset = _loc1_.sliderMC._xmouse - _loc1_._x;
         _loc1_.onMouseMove = _loc1_.onMouseMoveFunc;
      };
      _loc1_.grabberMC.onMouseMoveFunc = function()
      {
         var _loc1_ = this;
         var _loc2_ = _loc1_.sliderMC.getValueFromPosition(_loc1_.sliderMC._xmouse - _loc1_._xOffset);
         _loc1_.sliderMC.setValue(_loc2_,true);
         updateAfterEvent();
      };
      _loc1_.grabberMC.onRelease = _loc1_.grabberMC.onReleaseOutside = function()
      {
         this.onMouseMove = undefined;
      };
      _loc1_.barMC.sliderMC = _loc1_;
      _loc1_.barMC._holdDelay = 500;
      _loc1_.barMC.useHandCursor = false;
      _loc1_.barMC.onPress = function()
      {
         var _loc1_ = this;
         if(_loc1_.sliderMC._parent._xmouse > _loc1_.sliderMC.grabberMC._x)
         {
            _loc1_.sliderMC.incrementValue(1,true);
         }
         else
         {
            _loc1_.sliderMC.incrementValue(-1,true);
         }
         _loc1_._startAuto = getTimer() + _loc1_._holdDelay;
         _loc1_.onEnterFrame = _loc1_.onEnterFrameFunc;
      };
      _loc1_.barMC.onEnterFrameFunc = function()
      {
         var _loc1_ = this;
         if(getTimer() > _loc1_._startAuto)
         {
            if(_loc1_.sliderMC._parent._xmouse > _loc1_.sliderMC.grabberMC._x)
            {
               _loc1_.sliderMC.incrementValue(1,true);
            }
            else
            {
               _loc1_.sliderMC.incrementValue(-1,true);
            }
         }
      };
      _loc1_.barMC.onRelease = _loc1_.barMC.onReleaseOutside = function()
      {
         delete this.onEnterFrame;
      };
      if(_loc1_.initScaleMode == "linear")
      {
         _loc1_._scaleMode = 0;
      }
      else
      {
         _loc1_._scaleMode = 1;
      }
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
      _loc1_._value = NaN;
      _loc1_.setSliderMin(_loc1_.initMinValue);
      _loc1_.setSliderMax(_loc1_.initMaxValue);
      _loc1_.setValue(_loc1_.initValue);
   }
}
var p = SliderV5Class.prototype = new MovieClip();
Object.registerClass("sliderV5Component",SliderV5Class);
p.textFormatWhileEditing = new TextFormat();
p.textFormatWhileEditing.italic = true;
p.textFormatOtherwise = new TextFormat();
p.textFormatOtherwise.italic = false;
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
      if(_loc2_ < _loc1_._rangeMin)
      {
         _loc2_ = _loc1_._rangeMin;
      }
      else if(_loc2_ > _loc1_._rangeMax)
      {
         _loc2_ = _loc1_._rangeMax;
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
p.setRange = function(min, max)
{
   var _loc1_ = this;
   var _loc2_ = max;
   var _loc3_ = min;
   if(_loc3_ > _loc1_._sliderMax)
   {
      _loc3_ = _loc1_._sliderMax;
   }
   else if(_loc3_ < _loc1_._sliderMin)
   {
      _loc3_ = _loc1_._sliderMin;
   }
   if(_loc2_ > _loc1_._sliderMax)
   {
      _loc2_ = _loc1_._sliderMax;
   }
   else if(_loc2_ < _loc1_._sliderMin)
   {
      _loc2_ = _loc1_._sliderMin;
   }
   if(_loc3_ > _loc2_)
   {
      var tmp = _loc2_;
      _loc2_ = _loc3_;
      _loc3_ = tmp;
   }
   _loc1_._rangeMin = _loc3_;
   _loc1_._rangeMax = _loc2_;
   _loc1_.setValue(_loc1_._value);
   _loc1_.barMC.updateBar();
};
p.getSliderMin = function()
{
   return this._sliderMin;
};
p.setSliderMin = function(arg)
{
   var _loc1_ = this;
   _loc1_._sliderMin = arg;
   _loc1_._rangeMin = arg;
   _loc1_.calculateScale();
   _loc1_.barMC.updateBar();
};
p.addProperty("sliderMin",p.getSliderMin,p.setSliderMin);
p.getSliderMax = function()
{
   return this._sliderMax;
};
p.setSliderMax = function(arg)
{
   var _loc1_ = this;
   _loc1_._sliderMax = arg;
   _loc1_._rangeMax = arg;
   _loc1_.calculateScale();
   _loc1_.barMC.updateBar();
};
p.addProperty("sliderMax",p.getSliderMax,p.setSliderMax);
p.calculateScale = function()
{
   var _loc1_ = this;
   if(_loc1_._scaleMode == 0)
   {
      _loc1_._scale = (_loc1_._sliderMax - _loc1_._sliderMin) / _loc1_._sliderPixelRange;
   }
   else
   {
      _loc1_._logSliderMin = Math.log(_loc1_._sliderMin);
      _loc1_._scale = (Math.log(_loc1_._sliderMax) - _loc1_._logSliderMin) / _loc1_._sliderPixelRange;
   }
   _loc1_.setValue(_loc1_._value);
};
p.getValueFromPosition = function(pos)
{
   var _loc1_ = this;
   if(_loc1_._scaleMode == 0)
   {
      return (pos - _loc1_.barMC._x) * _loc1_._scale + _loc1_._sliderMin;
   }
   return Math.exp((pos - _loc1_.barMC._x) * _loc1_._scale + _loc1_._logSliderMin);
};
p.getPositionFromValue = function(val)
{
   var _loc1_ = this;
   if(_loc1_._scaleMode == 0)
   {
      return _loc1_.barMC._x + (val - _loc1_._sliderMin) / _loc1_._scale;
   }
   return _loc1_.barMC._x + (Math.log(val) - _loc1_._logSliderMin) / _loc1_._scale;
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
