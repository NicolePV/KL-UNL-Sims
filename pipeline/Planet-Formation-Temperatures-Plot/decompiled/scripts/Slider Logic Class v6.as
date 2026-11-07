function SliderLogicClassV6(initObject)
{
   var _loc1_ = this;
   var _loc2_ = initObject;
   _loc1_.refresh = function()
   {
   };
   var s = _loc1_.setScalingMode(_loc2_.scalingMode);
   if(!s)
   {
      _loc1_.setScalingMode("linear");
   }
   var s = _loc1_.setValueFormat(_loc2_.valueFormat,_loc2_.valueDigits);
   if(!s)
   {
      _loc1_.setValueFormat("fixed digits",1);
   }
   var s = _loc1_.setValueAndParameterRanges(_loc2_.minValue,_loc2_.maxValue,_loc2_.minParameter,_loc2_.maxParameter);
   if(!s)
   {
      _loc1_.setValueAndParameterRanges(1,100,0,1);
   }
   delete _loc1_.refresh;
   var _loc3_ = Number(_loc2_.value);
   if(isFinite(_loc3_) && !isNaN(_loc3_))
   {
      _loc1_.setValue(_loc3_);
   }
   else
   {
      _loc1_.setValue(_loc1_._minV + (_loc1_._maxV - _loc1_._minV) / 2);
   }
}
var p = SliderLogicClassV6.prototype = new Object();
p.setScalingMode = function(mode)
{
   var _loc2_ = this;
   var _loc1_ = false;
   if(mode == "linear")
   {
      _loc2_._sMode = 0;
      _loc1_ = true;
   }
   else if(mode == "logarithmic")
   {
      _loc2_._sMode = 1;
      _loc1_ = true;
   }
   if(_loc1_)
   {
      _loc2_.calculateScale();
      _loc2_.refresh();
   }
   return _loc1_;
};
p.setValueFormat = function(mode, digits)
{
   var _loc1_ = this;
   var _loc3_ = false;
   var _loc2_;
   if(mode == "significant digits")
   {
      _loc1_._pMode = 0;
      _loc2_ = Math.abs(parseInt(digits));
      if(!isFinite(_loc2_) || isNaN(_loc2_) || _loc2_ == 0)
      {
         _loc2_ = 1;
      }
      _loc1_._digs = _loc2_;
      _loc1_._lowerSigLimit = Math.pow(10,_loc2_ - 1);
      _loc1_._upperSigLimit = Math.pow(10,_loc2_);
      _loc1_._ticksPerMag = 9 * _loc1_._lowerSigLimit;
      _loc3_ = true;
   }
   else if(mode == "fixed digits")
   {
      _loc1_._pMode = 1;
      _loc2_ = parseInt(digits);
      if(!isFinite(_loc2_) || isNaN(_loc2_))
      {
         _loc2_ = 1;
      }
      _loc1_._digs = _loc2_;
      _loc1_._minIncrement = Math.pow(10,- _loc2_);
      _loc3_ = true;
   }
   if(_loc3_)
   {
      _loc1_.refresh();
   }
   return _loc3_;
};
p.setValueAndParameterRanges = function(minValue, maxValue, minParameter, maxParameter)
{
   var _loc1_ = this;
   var _loc2_ = minValue;
   var _loc3_ = minParameter;
   if(_loc2_ == null)
   {
      _loc2_ = _loc1_._minV;
   }
   else
   {
      _loc2_ = Number(_loc2_);
   }
   if(maxValue == null)
   {
      var maxValue = _loc1_._maxV;
   }
   else
   {
      var maxValue = Number(maxValue);
   }
   if(_loc3_ == null)
   {
      _loc3_ = _loc1_._minP;
   }
   else
   {
      _loc3_ = Number(_loc3_);
   }
   if(maxParameter == null)
   {
      var maxParameter = _loc1_._maxP;
   }
   else
   {
      var maxParameter = Number(maxParameter);
   }
   if(_loc2_ >= maxValue || _loc3_ >= maxParameter || isNaN(_loc2_) || isNaN(maxValue) || isNaN(_loc3_) || isNaN(maxParameter) || !isFinite(_loc2_) || !isFinite(maxValue) || !isFinite(_loc3_) || !isFinite(maxParameter))
   {
      return false;
   }
   _loc1_._minV = _loc2_;
   _loc1_._maxV = maxValue;
   _loc1_._minP = _loc3_;
   _loc1_._maxP = maxParameter;
   _loc1_.calculateScale();
   _loc1_.refresh();
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
   var _loc1_ = this.getIncrementedValueObject(null,numTicks);
   this.setValueByValueObject(_loc1_);
};
p.getValueString = function()
{
   return this.getValueStringFromValueObject(this._valueObject);
};
p.addProperty("valueString",p.getValueString,null);
p.getValueStringFromValueObject = function(valueObj)
{
   var _loc1_ = this;
   var _loc3_ = valueObj;
   var _loc2_;
   if(_loc1_._pMode == 0)
   {
      _loc2_ = _loc1_._digs - _loc3_.mag - 1;
   }
   else
   {
      _loc2_ = _loc1_._digs;
   }
   if(_loc2_ > 0)
   {
      return _loc1_.toFixed(_loc3_.value,_loc2_);
   }
   return String(_loc3_.value);
};
p.getValueObjectFromValue = function(x)
{
   var _loc1_ = this;
   var _loc3_ = x;
   var _loc2_ = {};
   if(_loc3_ < _loc1_._minV)
   {
      _loc3_ = _loc1_._minV;
   }
   else if(_loc3_ > _loc1_._maxV)
   {
      _loc3_ = _loc1_._maxV;
   }
   if(_loc1_._pMode == 0)
   {
      var mag = Math.floor(Math.log(_loc3_) / 2.302585092994046);
      var sig = Math.round(_loc3_ * _loc1_._lowerSigLimit / Math.pow(10,mag));
      if(sig >= _loc1_._upperSigLimit)
      {
         sig = _loc1_._lowerSigLimit;
         mag++;
      }
      _loc2_.value = sig / _loc1_._lowerSigLimit * Math.pow(10,mag);
      _loc2_.mag = mag;
      _loc2_.sig = sig;
   }
   else
   {
      _loc2_.value = _loc1_._minIncrement * Math.round(_loc3_ / _loc1_._minIncrement);
   }
   return _loc2_;
};
p.getIncrementedValueObject = function(valueObj, numTicks)
{
   var _loc1_ = this;
   if(typeof valueObj != "object")
   {
      valueObj = _loc1_._valueObject;
   }
   numTicks = Math.round(numTicks);
   var _loc2_ = {};
   var _loc3_;
   if(_loc1_._pMode == 0)
   {
      var fracMags = numTicks / _loc1_._ticksPerMag;
      if(fracMags >= 1)
      {
         var deltaMag = Math.floor(fracMags);
         var deltaSig = numTicks - deltaMag * _loc1_._ticksPerMag;
      }
      else if(fracMags <= -1)
      {
         var deltaMag = Math.ceil(fracMags);
         var deltaSig = numTicks - deltaMag * _loc1_._ticksPerMag;
      }
      else
      {
         var deltaMag = 0;
         var deltaSig = numTicks;
      }
      _loc3_ = valueObj.sig + deltaSig;
      var newMag = valueObj.mag + deltaMag;
      if(_loc3_ >= _loc1_._upperSigLimit)
      {
         _loc3_ -= _loc1_._ticksPerMag;
         newMag++;
      }
      else if(_loc3_ < _loc1_._lowerSigLimit)
      {
         _loc3_ += _loc1_._ticksPerMag;
         newMag--;
      }
      _loc2_.value = _loc3_ / _loc1_._lowerSigLimit * Math.pow(10,newMag);
      _loc2_.sig = _loc3_;
      _loc2_.mag = newMag;
   }
   else
   {
      _loc2_.value = _loc1_._minIncrement * Math.round(numTicks + valueObj.value / _loc1_._minIncrement);
   }
   if(_loc2_.value < _loc1_._minV)
   {
      _loc2_ = _loc1_.getValueObjectFromValue(_loc1_._minV);
   }
   else if(_loc2_.value > _loc1_._maxV)
   {
      _loc2_ = _loc1_.getValueObjectFromValue(_loc1_._maxV);
   }
   return _loc2_;
};
p.calculateScale = function()
{
   var _loc1_ = this;
   if(_loc1_._sMode == 0)
   {
      _loc1_._scale = (_loc1_._maxV - _loc1_._minV) / (_loc1_._maxP - _loc1_._minP);
   }
   else
   {
      _loc1_._logMinV = Math.log(_loc1_._minV);
      _loc1_._scale = (Math.log(_loc1_._maxV) - _loc1_._logMinV) / (_loc1_._maxP - _loc1_._minP);
   }
};
p.getValueFromParameter = function(parameter)
{
   var _loc1_ = this;
   if(_loc1_._sMode == 0)
   {
      return (parameter - _loc1_._minP) * _loc1_._scale + _loc1_._minV;
   }
   return Math.exp((parameter - _loc1_._minP) * _loc1_._scale + _loc1_._logMinV);
};
p.getParameterFromValue = function(value)
{
   var _loc1_ = this;
   if(_loc1_._sMode == 0)
   {
      return _loc1_._minP + (value - _loc1_._minV) / _loc1_._scale;
   }
   return _loc1_._minP + (Math.log(value) - _loc1_._logMinV) / _loc1_._scale;
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
   var _loc2_ = "";
   var _loc3_;
   var _loc1_;
   if(x < 1e+21)
   {
      var n = Math.round(x * Math.pow(10,f));
      if(n == 0)
      {
         _loc2_ = "0";
      }
      else
      {
         _loc2_ = n.toString();
      }
      if(f > 0)
      {
         _loc3_ = _loc2_.length;
         if(_loc3_ <= f)
         {
            var z = "";
            _loc1_ = 0;
            while(_loc1_ < f + 1 - _loc3_)
            {
               z += "0";
               _loc1_ = _loc1_ + 1;
            }
            _loc2_ = z + _loc2_;
            _loc3_ = f + 1;
         }
         var a = _loc2_.substr(0,_loc3_ - f);
         var b = _loc2_.substr(_loc3_ - f);
         _loc2_ = a + "." + b;
      }
   }
   else
   {
      _loc2_ = x.toString();
   }
   return s + _loc2_;
};
