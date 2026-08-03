function SliderLogicClassV6(initObject)
{
   this.refresh = function()
   {
   };
   var _loc4_ = this.setScalingMode(initObject.scalingMode);
   if(!_loc4_)
   {
      this.setScalingMode("linear");
   }
   _loc4_ = this.setValueFormat(initObject.valueFormat,initObject.valueDigits);
   if(!_loc4_)
   {
      this.setValueFormat("fixed digits",1);
   }
   _loc4_ = this.setValueAndParameterRanges(initObject.minValue,initObject.maxValue,initObject.minParameter,initObject.maxParameter);
   if(!_loc4_)
   {
      this.setValueAndParameterRanges(1,100,0,1);
   }
   delete this.refresh;
   var _loc3_ = Number(initObject.value);
   if(isFinite(_loc3_) && !isNaN(_loc3_))
   {
      this.setValue(_loc3_);
   }
   else
   {
      this.setValue(this._minV + (this._maxV - this._minV) / 2);
   }
}
var p = SliderLogicClassV6.prototype = new Object();
p.setScalingMode = function(mode)
{
   var _loc2_ = false;
   if(mode == "linear")
   {
      this._sMode = 0;
      _loc2_ = true;
   }
   else if(mode == "logarithmic")
   {
      this._sMode = 1;
      _loc2_ = true;
   }
   if(_loc2_)
   {
      this.calculateScale();
      this.refresh();
   }
   return _loc2_;
};
p.setValueFormat = function(mode, digits)
{
   var _loc3_ = false;
   var _loc2_;
   if(mode == "significant digits")
   {
      this._pMode = 0;
      _loc2_ = Math.abs(parseInt(digits));
      if(!isFinite(_loc2_) || isNaN(_loc2_) || _loc2_ == 0)
      {
         _loc2_ = 1;
      }
      this._digs = _loc2_;
      this._lowerSigLimit = Math.pow(10,_loc2_ - 1);
      this._upperSigLimit = Math.pow(10,_loc2_);
      this._ticksPerMag = 9 * this._lowerSigLimit;
      _loc3_ = true;
   }
   else if(mode == "fixed digits")
   {
      this._pMode = 1;
      _loc2_ = parseInt(digits);
      if(!isFinite(_loc2_) || isNaN(_loc2_))
      {
         _loc2_ = 1;
      }
      this._digs = _loc2_;
      this._minIncrement = Math.pow(10,- _loc2_);
      _loc3_ = true;
   }
   if(_loc3_)
   {
      this.refresh();
   }
   return _loc3_;
};
p.setValueAndParameterRanges = function(minValue, maxValue, minParameter, maxParameter)
{
   if(minValue == null)
   {
      minValue = this._minV;
   }
   else
   {
      minValue = Number(minValue);
   }
   if(maxValue == null)
   {
      maxValue = this._maxV;
   }
   else
   {
      maxValue = Number(maxValue);
   }
   if(minParameter == null)
   {
      minParameter = this._minP;
   }
   else
   {
      minParameter = Number(minParameter);
   }
   if(maxParameter == null)
   {
      maxParameter = this._maxP;
   }
   else
   {
      maxParameter = Number(maxParameter);
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
   var _loc2_ = this.getIncrementedValueObject(null,numTicks);
   this.setValueByValueObject(_loc2_);
};
p.getValueString = function()
{
   return this.getValueStringFromValueObject(this._valueObject);
};
p.addProperty("valueString",p.getValueString,null);
p.getValueStringFromValueObject = function(valueObj)
{
   var _loc2_;
   if(this._pMode == 0)
   {
      _loc2_ = this._digs - valueObj.mag - 1;
   }
   else
   {
      _loc2_ = this._digs;
   }
   if(_loc2_ > 0)
   {
      return this.toFixed(valueObj.value,_loc2_);
   }
   return String(valueObj.value);
};
p.getValueObjectFromValue = function(x)
{
   var _loc2_ = {};
   if(x < this._minV)
   {
      x = this._minV;
   }
   else if(x > this._maxV)
   {
      x = this._maxV;
   }
   var _loc5_;
   var _loc4_;
   if(this._pMode == 0)
   {
      _loc5_ = Math.floor(Math.log(x) / 2.302585092994046);
      _loc4_ = Math.round(x * this._lowerSigLimit / Math.pow(10,_loc5_));
      if(_loc4_ >= this._upperSigLimit)
      {
         _loc4_ = this._lowerSigLimit;
         _loc5_ = _loc5_ + 1;
      }
      _loc2_.value = _loc4_ / this._lowerSigLimit * Math.pow(10,_loc5_);
      _loc2_.mag = _loc5_;
      _loc2_.sig = _loc4_;
   }
   else
   {
      _loc2_.value = this._minIncrement * Math.round(x / this._minIncrement);
   }
   return _loc2_;
};
p.getIncrementedValueObject = function(valueObj, numTicks)
{
   if(typeof valueObj != "object")
   {
      valueObj = this._valueObject;
   }
   numTicks = Math.round(numTicks);
   var _loc2_ = {};
   var _loc6_;
   var _loc9_;
   var _loc8_;
   var _loc3_;
   var _loc5_;
   if(this._pMode == 0)
   {
      _loc6_ = numTicks / this._ticksPerMag;
      if(_loc6_ >= 1)
      {
         _loc9_ = Math.floor(_loc6_);
         _loc8_ = numTicks - _loc9_ * this._ticksPerMag;
      }
      else if(_loc6_ <= -1)
      {
         _loc9_ = Math.ceil(_loc6_);
         _loc8_ = numTicks - _loc9_ * this._ticksPerMag;
      }
      else
      {
         _loc9_ = 0;
         _loc8_ = numTicks;
      }
      _loc3_ = valueObj.sig + _loc8_;
      _loc5_ = valueObj.mag + _loc9_;
      if(_loc3_ >= this._upperSigLimit)
      {
         _loc3_ -= this._ticksPerMag;
         _loc5_ = _loc5_ + 1;
      }
      else if(_loc3_ < this._lowerSigLimit)
      {
         _loc3_ += this._ticksPerMag;
         _loc5_ = _loc5_ - 1;
      }
      _loc2_.value = _loc3_ / this._lowerSigLimit * Math.pow(10,_loc5_);
      _loc2_.sig = _loc3_;
      _loc2_.mag = _loc5_;
   }
   else
   {
      _loc2_.value = this._minIncrement * Math.round(numTicks + valueObj.value / this._minIncrement);
   }
   if(_loc2_.value < this._minV)
   {
      _loc2_ = this.getValueObjectFromValue(this._minV);
   }
   else if(_loc2_.value > this._maxV)
   {
      _loc2_ = this.getValueObjectFromValue(this._maxV);
   }
   return _loc2_;
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
   var _loc7_ = "";
   if(x < 0)
   {
      _loc7_ = "-";
      x = - x;
   }
   var _loc2_ = "";
   var _loc8_;
   var _loc3_;
   var _loc5_;
   var _loc1_;
   var _loc10_;
   var _loc9_;
   if(x < 1e+21)
   {
      _loc8_ = Math.round(x * Math.pow(10,f));
      if(_loc8_ == 0)
      {
         _loc2_ = "0";
      }
      else
      {
         _loc2_ = _loc8_.toString();
      }
      if(f > 0)
      {
         _loc3_ = _loc2_.length;
         if(_loc3_ <= f)
         {
            _loc5_ = "";
            _loc1_ = 0;
            while(_loc1_ < f + 1 - _loc3_)
            {
               _loc5_ += "0";
               _loc1_ = _loc1_ + 1;
            }
            _loc2_ = _loc5_ + _loc2_;
            _loc3_ = f + 1;
         }
         _loc10_ = _loc2_.substr(0,_loc3_ - f);
         _loc9_ = _loc2_.substr(_loc3_ - f);
         _loc2_ = _loc10_ + "." + _loc9_;
      }
   }
   else
   {
      _loc2_ = x.toString();
   }
   return _loc7_ + _loc2_;
};
