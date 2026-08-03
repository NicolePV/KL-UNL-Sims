package
{
   public class ProtoSliderLogic
   {
      
      public var _lowerSigLimit:int;
      
      public var _digs:int;
      
      public var _minIncrement:Number;
      
      public var _minP:Number;
      
      public var _minV:Number;
      
      public var _upperSigLimit:int;
      
      public var _pMode:int;
      
      public var _rMode:int = 0;
      
      public var _sMode:int;
      
      public var _finiteSet:Array;
      
      public var _scale:Number;
      
      public var _ticksPerMag:int;
      
      public var _maxV:Number;
      
      public var _maxP:Number;
      
      public var refresh:Function;
      
      public var _valueObject:Object;
      
      public var _logMinV:Number;
      
      public function ProtoSliderLogic(param1:Object)
      {
         var initValue:Number;
         var s:Boolean = false;
         var initObject:Object = param1;
         super();
         refresh = function():void
         {
         };
         s = setScalingMode(initObject.scalingMode);
         if(!s)
         {
            setScalingMode("linear");
         }
         s = setValueFormat(initObject.valueFormat,initObject.valueDigits);
         if(!s)
         {
            setValueFormat("fixed digits",1);
         }
         s = setValueAndParameterRanges(initObject.minValue,initObject.maxValue,initObject.minParameter,initObject.maxParameter);
         if(!s)
         {
            setValueAndParameterRanges(1,100,0,1);
         }
         refresh = refreshFunc;
         initValue = Number(initObject.value);
         if(isFinite(initValue) && !isNaN(initValue))
         {
            value = initValue;
         }
         else
         {
            value = _minV + (_maxV - _minV) / 2;
         }
      }
      
      public function calculateScale() : void
      {
         if(_sMode == 0)
         {
            _scale = (_maxV - _minV) / (_maxP - _minP);
         }
         else
         {
            _logMinV = Math.log(_minV);
            _scale = (Math.log(_maxV) - _logMinV) / (_maxP - _minP);
         }
      }
      
      public function setValueFormat(param1:String, param2:int) : Boolean
      {
         var _loc4_:int = 0;
         var _loc3_:Boolean = false;
         if(param1 == "significant digits")
         {
            _pMode = 0;
            _loc4_ = Math.abs(param2);
            if(_loc4_ == 0)
            {
               _loc4_ = 1;
            }
            _digs = _loc4_;
            _lowerSigLimit = Math.pow(10,_loc4_ - 1);
            _upperSigLimit = Math.pow(10,_loc4_);
            _ticksPerMag = 9 * _lowerSigLimit;
            _loc3_ = true;
         }
         else if(param1 == "fixed digits")
         {
            _pMode = 1;
            _loc4_ = param2;
            _digs = _loc4_;
            _minIncrement = Math.pow(10,-_loc4_);
            _loc3_ = true;
         }
         if(_loc3_)
         {
            refresh();
         }
         return _loc3_;
      }
      
      public function setScalingMode(param1:String) : Boolean
      {
         var _loc2_:Boolean = false;
         if(param1 == "linear")
         {
            _sMode = 0;
            _loc2_ = true;
         }
         else if(param1 == "logarithmic")
         {
            _sMode = 1;
            _loc2_ = true;
         }
         if(_loc2_)
         {
            calculateScale();
            refresh();
         }
         return _loc2_;
      }
      
      public function setValueAndParameterRanges(param1:* = null, param2:* = null, param3:* = null, param4:* = null) : Boolean
      {
         if(!(param1 is Number))
         {
            param1 = _minV;
         }
         if(!(param2 is Number))
         {
            param2 = _maxV;
         }
         if(!(param3 is Number))
         {
            param3 = _minP;
         }
         if(!(param4 is Number))
         {
            param4 = _maxP;
         }
         if(param1 >= param2 || param3 >= param4 || isNaN(param1) || isNaN(param2) || isNaN(param3) || isNaN(param4) || !isFinite(param1) || !isFinite(param2) || !isFinite(param3) || !isFinite(param4))
         {
            return false;
         }
         _minV = param1;
         _maxV = param2;
         _minP = param3;
         _maxP = param4;
         calculateScale();
         refresh();
         return true;
      }
      
      public function getValueFromParameter(param1:Number) : Number
      {
         if(_sMode == 0)
         {
            return (param1 - _minP) * _scale + _minV;
         }
         return Math.exp((param1 - _minP) * _scale + _logMinV);
      }
      
      public function get parameter() : Number
      {
         return getParameterFromValue(_valueObject.value);
      }
      
      public function getValueStringFromValueObject(param1:Object) : String
      {
         var _loc2_:int = 0;
         if(_pMode == 0)
         {
            _loc2_ = _digs - param1.mag - 1;
         }
         else
         {
            _loc2_ = _digs;
         }
         if(_loc2_ > 0)
         {
            return param1.value.toFixed(_loc2_);
         }
         return String(Math.round(param1.value));
      }
      
      public function getValueObjectFromValue(param1:Number) : Object
      {
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc7_:int = 0;
         var _loc8_:Number = NaN;
         var _loc9_:int = 0;
         var _loc2_:Object = {};
         if(_rMode == 0)
         {
            if(param1 < _minV)
            {
               param1 = _minV;
            }
            else if(param1 > _maxV)
            {
               param1 = _maxV;
            }
         }
         else
         {
            _loc6_ = Number.NaN;
            _loc7_ = 0;
            _loc8_ = Number.POSITIVE_INFINITY;
            _loc9_ = 0;
            while(_loc9_ < _finiteSet.length)
            {
               _loc5_ = Math.abs(_finiteSet[_loc9_] - param1);
               if(_loc5_ < _loc8_)
               {
                  _loc6_ = Number(_finiteSet[_loc9_]);
                  _loc7_ = _loc9_;
                  _loc8_ = _loc5_;
               }
               _loc9_++;
            }
            param1 = _loc6_;
            _loc2_.closestIndex = _loc7_;
         }
         if(_pMode == 0)
         {
            _loc3_ = Math.floor(Math.log(param1) / Math.LN10);
            _loc4_ = Math.round(param1 * _lowerSigLimit / Math.pow(10,_loc3_));
            if(_loc4_ >= _upperSigLimit)
            {
               _loc4_ = _lowerSigLimit;
               _loc3_++;
            }
            _loc2_.value = _loc4_ / _lowerSigLimit * Math.pow(10,_loc3_);
            _loc2_.mag = _loc3_;
            _loc2_.sig = _loc4_;
         }
         else
         {
            _loc2_.value = _minIncrement * Math.round(param1 / _minIncrement);
         }
         return _loc2_;
      }
      
      public function refreshFunc() : void
      {
         value = _valueObject.value;
      }
      
      public function incrementValue(param1:int) : void
      {
         var _loc2_:Object = getIncrementedValueObject(null,param1);
         setValueByValueObject(_loc2_);
      }
      
      public function getParameterFromValue(param1:Number) : Number
      {
         if(_sMode == 0)
         {
            return _minP + (param1 - _minV) / _scale;
         }
         return _minP + (Math.log(param1) - _logMinV) / _scale;
      }
      
      public function setValueByValueObject(param1:Object) : void
      {
         _valueObject = param1;
      }
      
      public function getIncrementedValueObject(param1:*, param2:int) : Object
      {
         var _loc4_:Number = NaN;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc8_:* = 0;
         var _loc9_:int = 0;
         var _loc10_:Number = NaN;
         var _loc11_:int = 0;
         var _loc12_:Number = NaN;
         if(!(param1 is Object))
         {
            param1 = _valueObject;
         }
         var _loc3_:Object = {};
         if(_rMode == 0)
         {
            if(_pMode == 0)
            {
               _loc4_ = param2 / _ticksPerMag;
               if(_loc4_ >= 1)
               {
                  _loc5_ = Math.floor(_loc4_);
                  _loc6_ = param2 - _loc5_ * _ticksPerMag;
               }
               else if(_loc4_ <= -1)
               {
                  _loc5_ = Math.ceil(_loc4_);
                  _loc6_ = param2 - _loc5_ * _ticksPerMag;
               }
               else
               {
                  _loc5_ = 0;
                  _loc6_ = param2;
               }
               _loc7_ = param1.sig + _loc6_;
               _loc8_ = int(param1.mag + _loc5_);
               if(_loc7_ >= _upperSigLimit)
               {
                  _loc7_ -= _ticksPerMag;
                  _loc8_++;
               }
               else if(_loc7_ < _lowerSigLimit)
               {
                  _loc7_ += _ticksPerMag;
                  _loc8_--;
               }
               _loc3_.value = _loc7_ / _lowerSigLimit * Math.pow(10,_loc8_);
               _loc3_.sig = _loc7_;
               _loc3_.mag = _loc8_;
            }
            else
            {
               _loc3_.value = _minIncrement * Math.round(param2 + param1.value / _minIncrement);
            }
            if(_loc3_.value < _minV)
            {
               _loc3_ = getValueObjectFromValue(_minV);
            }
            else if(_loc3_.value > _maxV)
            {
               _loc3_ = getValueObjectFromValue(_maxV);
            }
         }
         else if(_rMode == 1)
         {
            _loc11_ = 0;
            _loc12_ = Number.POSITIVE_INFINITY;
            _loc9_ = 0;
            while(_loc9_ < _finiteSet.length)
            {
               _loc10_ = Math.abs(_finiteSet[_loc9_] - param1.value);
               if(_loc10_ < _loc12_)
               {
                  _loc11_ = _loc9_;
                  _loc12_ = _loc10_;
               }
               _loc9_++;
            }
            _loc9_ = _loc11_ + param2;
            if(_loc9_ < 0)
            {
               _loc9_ = 0;
            }
            else if(_loc9_ >= _finiteSet.length)
            {
               _loc9_ = _finiteSet.length - 1;
            }
            _loc3_ = getValueObjectFromValue(_finiteSet[_loc9_]);
         }
         return _loc3_;
      }
      
      public function setRangeType(param1:String, param2:Array = null) : void
      {
         var _loc3_:int = 0;
         if(param1 == "continuous")
         {
            _rMode = 0;
         }
         else if(param1 == "finite set")
         {
            _rMode = 1;
            _finiteSet = [];
            _loc3_ = 0;
            while(_loc3_ < param2.length)
            {
               _finiteSet.push(param2[_loc3_]);
               _loc3_++;
            }
            _finiteSet.sort(Array.NUMERIC);
            _minV = _finiteSet[0];
            _maxV = _finiteSet[_finiteSet.length - 1];
            calculateScale();
         }
         refresh();
      }
      
      public function set parameter(param1:Number) : void
      {
         value = getValueFromParameter(param1);
      }
      
      public function get valueString() : String
      {
         return getValueStringFromValueObject(_valueObject);
      }
      
      public function set value(param1:Number) : void
      {
         setValueByValueObject(getValueObjectFromValue(param1));
      }
      
      public function get value() : Number
      {
         return _valueObject.value;
      }
      
      public function toString() : String
      {
         var _loc1_:String = "ProtoSliderLogic instance:\n";
         _loc1_ += " _sMode: " + String(_sMode) + "\n";
         _loc1_ += " _pMode: " + String(_pMode) + "\n";
         _loc1_ += " _rMode: " + String(_rMode) + "\n";
         _loc1_ += " _digs: " + String(_digs) + "\n";
         _loc1_ += " _lowerSigLimit: " + String(_lowerSigLimit) + "\n";
         _loc1_ += " _upperSigLimit: " + String(_upperSigLimit) + "\n";
         _loc1_ += " _ticksPerMag: " + String(_ticksPerMag) + "\n";
         _loc1_ += " _minIncrement: " + String(_minIncrement) + "\n";
         _loc1_ += " _minV: " + String(_minV) + "\n";
         _loc1_ += " _maxV: " + String(_maxV) + "\n";
         _loc1_ += " _minP: " + String(_minP) + "\n";
         _loc1_ += " _maxP: " + String(_maxP) + "\n";
         _loc1_ += " _logMinV: " + String(_logMinV) + "\n";
         _loc1_ += " _scale: " + String(_scale) + "\n";
         _loc1_ += " value: " + String(value) + "\n";
         return _loc1_ + (" valueString: " + valueString + "\n");
      }
      
      public function getClosestIndex() : int
      {
         if(_valueObject.closestIndex is int)
         {
            return _valueObject.closestIndex;
         }
         return -1;
      }
   }
}

