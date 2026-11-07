function SliderLogicClassV6(initObject)
{
   this.refresh = function()
   {
   };
   var s = this.setScalingMode(initObject.scalingMode);
   if(!s)
   {
      this.setScalingMode("linear");
   }
   var s = this.setValueFormat(initObject.valueFormat,initObject.valueDigits);
   if(!s)
   {
      this.setValueFormat("fixed digits",1);
   }
   var s = this.setValueAndParameterRanges(initObject.minValue,initObject.maxValue,initObject.minParameter,initObject.maxParameter);
   if(!s)
   {
      this.setValueAndParameterRanges(1,100,0,1);
   }
   delete this.refresh;
   var initValue = Number(initObject.value);
   if(isFinite(initValue) && !isNaN(initValue))
   {
      this.setValue(initValue);
   }
   else
   {
      this.setValue(this._minV + (this._maxV - this._minV) / 2);
   }
}
var p = SliderLogicClassV6.prototype = new Object();
p.setScalingMode = function(mode)
{
   var success = false;
   if(mode == "linear")
   {
      this._sMode = 0;
      success = true;
   }
   else if(mode == "logarithmic")
   {
      this._sMode = 1;
      success = true;
   }
   if(success)
   {
      this.calculateScale();
      this.refresh();
   }
   return success;
};
p.setValueFormat = function(mode, digits)
{
   var success = false;
   if(mode == "significant digits")
   {
      this._pMode = 0;
      var x = Math.abs(parseInt(digits));
      if(!isFinite(x) || isNaN(x) || x == 0)
      {
         x = 1;
      }
      this._digs = x;
      this._lowerSigLimit = Math.pow(10,x - 1);
      this._upperSigLimit = Math.pow(10,x);
      this._ticksPerMag = 9 * this._lowerSigLimit;
      success = true;
   }
   else if(mode == "fixed digits")
   {
      this._pMode = 1;
      var x = parseInt(digits);
      if(!isFinite(x) || isNaN(x))
      {
         x = 1;
      }
      this._digs = x;
      this._minIncrement = Math.pow(10,- x);
      success = true;
   }
   if(success)
   {
      this.refresh();
   }
   return success;
};
p.setValueAndParameterRanges = function(minValue, maxValue, minParameter, maxParameter)
{
   if(minValue == null)
   {
      var minValue = this._minV;
   }
   else
   {
      var minValue = Number(minValue);
   }
   if(maxValue == null)
   {
      var maxValue = this._maxV;
   }
   else
   {
      var maxValue = Number(maxValue);
   }
   if(minParameter == null)
   {
      var minParameter = this._minP;
   }
   else
   {
      var minParameter = Number(minParameter);
   }
   if(maxParameter == null)
   {
      var maxParameter = this._maxP;
   }
   else
   {
      var maxParameter = Number(maxParameter);
   }
   if(minValue >= maxValue || minParameter >= maxParameter || isNaN(minValue) || isNaN(maxValue) || isNaN(minParameter) || isNaN(maxParameter) || !isFinite(minValue) || !isFinite(maxValue) || !isFinite(minParameter) || !isFinite(maxParameter))
   {
      return false;
   }
   this._minV = minValue;
   this._maxV = maxValue;
   this._minP = minParameter;
   this._maxP = maxParameter;
   this.calculateScale();
   this.refresh();
   return true;
};
p.getParameter = function()
{
   return this.getParameterFromValue(this._valueObject.value);
};
p.setParameter = function(parameter)
{
   this.setValue(this.getValueFromParameter(parameter));
};
p.addProperty("parameter",p.getParameter,p.setParameter);
p.getValue = function()
{
   return this._valueObject.value;
};
p.setValue = function(x)
{
   this.setValueByValueObject(this.getValueObjectFromValue(x));
};
p.addProperty("value",p.getValue,p.setValue);
p.setValueByValueObject = function(valueObj)
{
   this._valueObject = valueObj;
};
p.incrementValue = function(numTicks)
{
   var vObj = this.getIncrementedValueObject(null,numTicks);
   this.setValueByValueObject(vObj);
};
p.getValueString = function()
{
   return this.getValueStringFromValueObject(this._valueObject);
};
p.addProperty("valueString",p.getValueString,null);
p.getValueStringFromValueObject = function(valueObj)
{
   if(this._pMode == 0)
   {
      var f = this._digs - valueObj.mag - 1;
   }
   else
   {
      var f = this._digs;
   }
   if(f > 0)
   {
      return this.toFixed(valueObj.value,f);
   }
   return String(valueObj.value);
};
p.getValueObjectFromValue = function(x)
{
   var vObj = {};
   if(x < this._minV)
   {
      x = this._minV;
   }
   else if(x > this._maxV)
   {
      x = this._maxV;
   }
   if(this._pMode == 0)
   {
      var mag = Math.floor(Math.log(x) / 2.302585092994046);
      var sig = Math.round(x * this._lowerSigLimit / Math.pow(10,mag));
      if(sig >= this._upperSigLimit)
      {
         sig = this._lowerSigLimit;
         mag++;
      }
      vObj.value = sig / this._lowerSigLimit * Math.pow(10,mag);
      vObj.mag = mag;
      vObj.sig = sig;
   }
   else
   {
      vObj.value = this._minIncrement * Math.round(x / this._minIncrement);
   }
   return vObj;
};
p.getIncrementedValueObject = function(valueObj, numTicks)
{
   if(typeof valueObj != "object")
   {
      valueObj = this._valueObject;
   }
   numTicks = Math.round(numTicks);
   var vObj = {};
   if(this._pMode == 0)
   {
      var fracMags = numTicks / this._ticksPerMag;
      if(fracMags >= 1)
      {
         var deltaMag = Math.floor(fracMags);
         var deltaSig = numTicks - deltaMag * this._ticksPerMag;
      }
      else if(fracMags <= -1)
      {
         var deltaMag = Math.ceil(fracMags);
         var deltaSig = numTicks - deltaMag * this._ticksPerMag;
      }
      else
      {
         var deltaMag = 0;
         var deltaSig = numTicks;
      }
      var newSig = valueObj.sig + deltaSig;
      var newMag = valueObj.mag + deltaMag;
      if(newSig >= this._upperSigLimit)
      {
         newSig -= this._ticksPerMag;
         newMag++;
      }
      else if(newSig < this._lowerSigLimit)
      {
         newSig += this._ticksPerMag;
         newMag--;
      }
      vObj.value = newSig / this._lowerSigLimit * Math.pow(10,newMag);
      vObj.sig = newSig;
      vObj.mag = newMag;
   }
   else
   {
      vObj.value = this._minIncrement * Math.round(numTicks + valueObj.value / this._minIncrement);
   }
   if(vObj.value < this._minV)
   {
      vObj = this.getValueObjectFromValue(this._minV);
   }
   else if(vObj.value > this._maxV)
   {
      vObj = this.getValueObjectFromValue(this._maxV);
   }
   return vObj;
};
p.calculateScale = function()
{
   if(this._sMode == 0)
   {
      this._scale = (this._maxV - this._minV) / (this._maxP - this._minP);
   }
   else
   {
      this._logMinV = Math.log(this._minV);
      this._scale = (Math.log(this._maxV) - this._logMinV) / (this._maxP - this._minP);
   }
};
p.getValueFromParameter = function(parameter)
{
   if(this._sMode == 0)
   {
      return (parameter - this._minP) * this._scale + this._minV;
   }
   return Math.exp((parameter - this._minP) * this._scale + this._logMinV);
};
p.getParameterFromValue = function(value)
{
   if(this._sMode == 0)
   {
      return this._minP + (value - this._minV) / this._scale;
   }
   return this._minP + (Math.log(value) - this._logMinV) / this._scale;
};
p.refresh = function()
{
   this.setValue(this._valueObject.value);
};
p.toFixed = function(x, f)
{
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
