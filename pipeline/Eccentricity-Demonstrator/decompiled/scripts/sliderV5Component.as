function SliderV5Class()
{
   this.valueField = this._parent[this.initValueFieldName];
   this.barMC = this._parent[this.initBarName];
   this.grabberMC = this._parent[this.initGrabberName];
   if(this.barMC == undefined || this.grabberMC == undefined)
   {
      trace("**ERROR** bar and/or grabber undefined for slider: " + this);
      return undefined;
   }
   this._sliderPixelRange = this.barMC.barWidth;
   if(this._sliderPixelRange == undefined)
   {
      trace("**ERROR** barWidth undefined for slider: " + this);
      return undefined;
   }
   this.valueField.sliderMC = this;
   this.valueField.restrict = "0-9.Ee+\\-";
   this.valueField.onChanged = function()
   {
      this.setTextFormat(this.sliderMC.textFormatWhileEditing);
      this.setNewTextFormat(this.sliderMC.textFormatWhileEditing);
      Key.addListener(this.sliderMC);
   };
   this.valueField.onKillFocus = function()
   {
      if(this.sliderMC.grabberMC.hitTest(_root._xmouse,_root._ymouse,true) || this.sliderMC.barMC.hitTest(_root._xmouse,_root._ymouse,true))
      {
         this.sliderMC.setValue(NaN);
      }
      else
      {
         this.sliderMC.setValue(parseFloat(this.text),true);
      }
   };
   this.grabberMC.sliderMC = this;
   this.grabberMC.useHandCursor = false;
   this.grabberMC.onPress = function()
   {
      this._xOffset = this.sliderMC._xmouse - this._x;
      this.onMouseMove = this.onMouseMoveFunc;
   };
   this.grabberMC.onMouseMoveFunc = function()
   {
      var newValue = this.sliderMC.getValueFromPosition(this.sliderMC._xmouse - this._xOffset);
      this.sliderMC.setValue(newValue,true);
      updateAfterEvent();
   };
   this.grabberMC.onRelease = this.grabberMC.onReleaseOutside = function()
   {
      this.onMouseMove = undefined;
   };
   this.barMC.sliderMC = this;
   this.barMC._holdDelay = 500;
   this.barMC.useHandCursor = false;
   this.barMC.onPress = function()
   {
      if(this.sliderMC._parent._xmouse > this.sliderMC.grabberMC._x)
      {
         this.sliderMC.incrementValue(1,true);
      }
      else
      {
         this.sliderMC.incrementValue(-1,true);
      }
      this._startAuto = getTimer() + this._holdDelay;
      this.onEnterFrame = this.onEnterFrameFunc;
   };
   this.barMC.onEnterFrameFunc = function()
   {
      if(getTimer() > this._startAuto)
      {
         if(this.sliderMC._parent._xmouse > this.sliderMC.grabberMC._x)
         {
            this.sliderMC.incrementValue(1,true);
         }
         else
         {
            this.sliderMC.incrementValue(-1,true);
         }
      }
   };
   this.barMC.onRelease = this.barMC.onReleaseOutside = function()
   {
      delete this.onEnterFrame;
   };
   if(this.initScaleMode == "linear")
   {
      this._scaleMode = 0;
   }
   else
   {
      this._scaleMode = 1;
   }
   if(this.initPrecisionMode == "significant digits")
   {
      this._precisionMode = 0;
      var x = Math.abs(parseInt(this.initPrecision));
      if(!isFinite(x) || isNaN(x) || x == 0)
      {
         x = 1;
      }
      this._sigs = x;
      this._tickResolution = Math.pow(10,x);
   }
   else
   {
      this._precisionMode = 1;
      var x = parseInt(this.initPrecision);
      if(!isFinite(x) || isNaN(x))
      {
         x = 1;
      }
      this._prec = x;
      this._minIncrement = Math.pow(10,- x);
   }
   this._value = NaN;
   this.setSliderMin(this.initMinValue);
   this.setSliderMax(this.initMaxValue);
   this.setValue(this.initValue);
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
   var x = Number(arg);
   if(isFinite(x) && !isNaN(x))
   {
      if(x < this._rangeMin)
      {
         x = this._rangeMin;
      }
      else if(x > this._rangeMax)
      {
         x = this._rangeMax;
      }
      if(x < this._sliderMin)
      {
         x = this._sliderMin;
      }
      else if(x > this._sliderMax)
      {
         x = this._sliderMax;
      }
      if(this._precisionMode == 0)
      {
         this._valueDecade = 1 + Math.floor(Math.log(x) / 2.302585092994046);
         this._valuePow = Math.pow(10,this._valueDecade);
         this._valueTick = Math.round(x * this._tickResolution / this._valuePow);
         if(this._valueTick == this._tickResolution)
         {
            this._valueTick = this._tickResolution / 10;
            this._valueDecade++;
            this._valuePow = Math.pow(10,this._valueDecade);
         }
         this._value = this._valueTick / this._tickResolution * this._valuePow;
         this._prec = this._sigs - this._valueDecade;
      }
      else
      {
         this._value = this._minIncrement * Math.round(x / this._minIncrement);
      }
      this.grabberMC._x = this.getPositionFromValue(this._value);
      if(callHandler)
      {
         this._parent[this.changeHandler](this._value);
      }
   }
   this.valueField.setTextFormat(this.textFormatOtherwise);
   this.valueField.setNewTextFormat(this.textFormatOtherwise);
   Key.removeListener(this);
   if(this._prec > 0)
   {
      this.valueField.text = this.toFixed(this._value);
   }
   else
   {
      this.valueField.text = this._value;
   }
};
p.addProperty("value",p.getValue,p.setValue);
p.incrementValue = function(deltaTicks, callHandler)
{
   if(this._precisionMode == 0)
   {
      var ticksPerDecade = 0.9 * this._tickResolution;
      var fracDecades = deltaTicks / ticksPerDecade;
      var deltaDecade = 0;
      if(fracDecades >= 1)
      {
         deltaDecade = Math.floor(fracDecades);
         deltaTicks -= deltaDecade * ticksPerDecade;
      }
      else if(fracDecades <= -1)
      {
         deltaDecade = Math.ceil(fracDecades);
         deltaTicks -= deltaDecade * ticksPerDecade;
      }
      var newTick = this._valueTick + deltaTicks;
      var newDecade = this._valueDecade + deltaDecade;
      if(newTick >= this._tickResolution)
      {
         newTick -= ticksPerDecade;
         newDecade++;
      }
      else if(newTick < 0.1 * this._tickResolution)
      {
         newTick += ticksPerDecade;
         newDecade--;
      }
      this.setValue(Math.pow(10,newDecade) * newTick / this._tickResolution,callHandler);
   }
   else
   {
      this.setValue(this._value + deltaTicks * this._minIncrement,callHandler);
   }
};
p.getRange = function()
{
   return {min:this._rangeMin,max:this._rangeMax};
};
p.setRange = function(min, max)
{
   if(min > this._sliderMax)
   {
      min = this._sliderMax;
   }
   else if(min < this._sliderMin)
   {
      min = this._sliderMin;
   }
   if(max > this._sliderMax)
   {
      max = this._sliderMax;
   }
   else if(max < this._sliderMin)
   {
      max = this._sliderMin;
   }
   if(min > max)
   {
      var tmp = max;
      max = min;
      min = tmp;
   }
   this._rangeMin = min;
   this._rangeMax = max;
   this.setValue(this._value);
   this.barMC.updateBar();
};
p.getSliderMin = function()
{
   return this._sliderMin;
};
p.setSliderMin = function(arg)
{
   this._sliderMin = arg;
   this._rangeMin = arg;
   this.calculateScale();
   this.barMC.updateBar();
};
p.addProperty("sliderMin",p.getSliderMin,p.setSliderMin);
p.getSliderMax = function()
{
   return this._sliderMax;
};
p.setSliderMax = function(arg)
{
   this._sliderMax = arg;
   this._rangeMax = arg;
   this.calculateScale();
   this.barMC.updateBar();
};
p.addProperty("sliderMax",p.getSliderMax,p.setSliderMax);
p.calculateScale = function()
{
   if(this._scaleMode == 0)
   {
      this._scale = (this._sliderMax - this._sliderMin) / this._sliderPixelRange;
   }
   else
   {
      this._logSliderMin = Math.log(this._sliderMin);
      this._scale = (Math.log(this._sliderMax) - this._logSliderMin) / this._sliderPixelRange;
   }
   this.setValue(this._value);
};
p.getValueFromPosition = function(pos)
{
   if(this._scaleMode == 0)
   {
      return (pos - this.barMC._x) * this._scale + this._sliderMin;
   }
   return Math.exp((pos - this.barMC._x) * this._scale + this._logSliderMin);
};
p.getPositionFromValue = function(val)
{
   if(this._scaleMode == 0)
   {
      return this.barMC._x + (val - this._sliderMin) / this._scale;
   }
   return this.barMC._x + (Math.log(val) - this._logSliderMin) / this._scale;
};
p.toFixed = function(x)
{
   var f = this._prec;
   var s = "";
   if(x < 0)
   {
      s = "-";
      x = - x;
   }
   var m = "";
   if(x < 1e+21)
   {
      var n = Math.round(x * Math.pow(10,f));
      if(n == 0)
      {
         m = "0";
      }
      else
      {
         m = n.toString();
      }
      if(f > 0)
      {
         var k = m.length;
         if(k <= f)
         {
            var z = "";
            var i = 0;
            while(i < f + 1 - k)
            {
               z += "0";
               i++;
            }
            m = z + m;
            k = f + 1;
         }
         var a = m.substr(0,k - f);
         var b = m.substr(k - f);
         m = a + "." + b;
      }
   }
   else
   {
      m = x.toString();
   }
   return s + m;
};
