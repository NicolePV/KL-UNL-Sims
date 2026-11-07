package
{
   public class ProtoSliderLogicCyclic
   {
      
      public var _lowerSigLimit:int;
      
      public var _digs:int;
      
      public var _minIncrement:Number;
      
      public var _minP:Number;
      
      public var _minV:Number;
      
      public var _upperSigLimit:int;
      
      public var _pMode:int;
      
      public var _sMode:int;
      
      public var _finiteSet:Array;
      
      public var _scale:Number;
      
      public var _ticksPerMag:int;
      
      public var _maxV:Number;
      
      public var _maxP:Number;
      
      public var refresh:Function;
      
      public const _cyclic:Boolean = true;
      
      public var _valueObject:Object;
      
      public var _logMinV:Number;
      
      public function ProtoSliderLogicCyclic(param1:Object)
      {
         var initValue:Number;
         var s:Boolean = false;
         var initObject:Object = param1;
         super();
         this.refresh = function():void
         {
         };
         s = this.setScalingMode(initObject.scalingMode);
         if(!s)
         {
            this.setScalingMode("linear");
         }
         s = this.setValueFormat(initObject.valueFormat,initObject.valueDigits);
         if(!s)
         {
            this.setValueFormat("fixed digits",1);
         }
         s = this.setValueAndParameterRanges(initObject.minValue,initObject.maxValue,initObject.minParameter,initObject.maxParameter);
         if(!s)
         {
            this.setValueAndParameterRanges(1,100,0,1);
         }
         this.refresh = this.refreshFunc;
         initValue = Number(initObject.value);
         if(isFinite(initValue) && !isNaN(initValue))
         {
            this.value = initValue;
         }
         else
         {
            this.value = this._minV + (this._maxV - this._minV) / 2;
         }
      }
      
      public function calculateScale() : void
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
      }
      
      public function setValueFormat(param1:String, param2:int) : Boolean
      {
         var _loc4_:int = 0;
         var _loc3_:Boolean = false;
         if(param1 == "significant digits")
         {
            this._pMode = 0;
            _loc4_ = Math.abs(param2);
            if(_loc4_ == 0)
            {
               _loc4_ = 1;
            }
            this._digs = _loc4_;
            this._lowerSigLimit = Math.pow(10,_loc4_ - 1);
            this._upperSigLimit = Math.pow(10,_loc4_);
            this._ticksPerMag = 9 * this._lowerSigLimit;
            _loc3_ = true;
         }
         else if(param1 == "fixed digits")
         {
            this._pMode = 1;
            _loc4_ = param2;
            this._digs = _loc4_;
            this._minIncrement = Math.pow(10,-_loc4_);
            _loc3_ = true;
         }
         if(_loc3_)
         {
            this.refresh();
         }
         return _loc3_;
      }
      
      public function setScalingMode(param1:String) : Boolean
      {
         var _loc2_:Boolean = false;
         if(param1 == "linear")
         {
            this._sMode = 0;
            _loc2_ = true;
         }
         else if(param1 == "logarithmic")
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
      }
      
      public function setValueAndParameterRanges(param1:* = null, param2:* = null, param3:* = null, param4:* = null) : Boolean
      {
         if(!(param1 is Number))
         {
            param1 = this._minV;
         }
         if(!(param2 is Number))
         {
            param2 = this._maxV;
         }
         if(!(param3 is Number))
         {
            param3 = this._minP;
         }
         if(!(param4 is Number))
         {
            param4 = this._maxP;
         }
         if(param1 >= param2 || param3 >= param4 || isNaN(param1) || isNaN(param2) || isNaN(param3) || isNaN(param4) || !isFinite(param1) || !isFinite(param2) || !isFinite(param3) || !isFinite(param4))
         {
            return false;
         }
         this._minV = param1;
         this._maxV = param2;
         this._minP = param3;
         this._maxP = param4;
         this.calculateScale();
         this.refresh();
         return true;
      }
      
      public function getValueFromParameter(param1:Number) : Number
      {
         if(this._sMode == 0)
         {
            return (param1 - this._minP) * this._scale + this._minV;
         }
         return Math.exp((param1 - this._minP) * this._scale + this._logMinV);
      }
      
      public function get parameter() : Number
      {
         return this.getParameterFromValue(this._valueObject.value);
      }
      
      public function getValueObjectFromValue(param1:Number) : Object
      {
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:Number = NaN;
         var _loc2_:Object = {};
         if(this._cyclic)
         {
            _loc5_ = this._maxV - this._minV;
            param1 = this._minV + ((param1 - this._minV) % _loc5_ + _loc5_) % _loc5_;
         }
         else if(param1 < this._minV)
         {
            param1 = this._minV;
         }
         else if(param1 > this._maxV)
         {
            param1 = this._maxV;
         }
         if(this._pMode == 0)
         {
            _loc3_ = Math.floor(Math.log(param1) / Math.LN10);
            _loc4_ = Math.round(param1 * this._lowerSigLimit / Math.pow(10,_loc3_));
            if(_loc4_ >= this._upperSigLimit)
            {
               _loc4_ = this._lowerSigLimit;
               _loc3_++;
            }
            _loc2_.value = _loc4_ / this._lowerSigLimit * Math.pow(10,_loc3_);
            _loc2_.mag = _loc3_;
            _loc2_.sig = _loc4_;
         }
         else
         {
            _loc2_.value = this._minIncrement * Math.round(param1 / this._minIncrement);
         }
         return _loc2_;
      }
      
      public function refreshFunc() : void
      {
         this.value = this._valueObject.value;
      }
      
      public function getValueStringFromValueObject(param1:Object) : String
      {
         var _loc2_:int = 0;
         if(this._pMode == 0)
         {
            _loc2_ = this._digs - param1.mag - 1;
         }
         else
         {
            _loc2_ = this._digs;
         }
         if(_loc2_ > 0)
         {
            return param1.value.toFixed(_loc2_);
         }
         return String(Math.round(param1.value));
      }
      
      public function incrementValue(param1:int) : void
      {
         var _loc2_:Object = this.getIncrementedValueObject(null,param1);
         this.setValueByValueObject(_loc2_);
      }
      
      public function getParameterFromValue(param1:Number) : Number
      {
         if(this._sMode == 0)
         {
            return this._minP + (param1 - this._minV) / this._scale;
         }
         return this._minP + (Math.log(param1) - this._logMinV) / this._scale;
      }
      
      public function setValueByValueObject(param1:Object) : void
      {
         this._valueObject = param1;
      }
      
      public function getIncrementedValueObject(param1:*, param2:int) : Object
      {
         var _loc4_:Number = NaN;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc8_:* = 0;
         if(!(param1 is Object))
         {
            param1 = this._valueObject;
         }
         var _loc3_:Object = {};
         if(this._pMode == 0)
         {
            _loc4_ = param2 / this._ticksPerMag;
            if(_loc4_ >= 1)
            {
               _loc5_ = Math.floor(_loc4_);
               _loc6_ = param2 - _loc5_ * this._ticksPerMag;
            }
            else if(_loc4_ <= -1)
            {
               _loc5_ = Math.ceil(_loc4_);
               _loc6_ = param2 - _loc5_ * this._ticksPerMag;
            }
            else
            {
               _loc5_ = 0;
               _loc6_ = param2;
            }
            _loc7_ = param1.sig + _loc6_;
            _loc8_ = int(param1.mag + _loc5_);
            if(_loc7_ >= this._upperSigLimit)
            {
               _loc7_ -= this._ticksPerMag;
               _loc8_++;
            }
            else if(_loc7_ < this._lowerSigLimit)
            {
               _loc7_ += this._ticksPerMag;
               _loc8_--;
            }
            _loc3_.value = _loc7_ / this._lowerSigLimit * Math.pow(10,_loc8_);
            _loc3_.sig = _loc7_;
            _loc3_.mag = _loc8_;
         }
         else
         {
            _loc3_.value = this._minIncrement * Math.round(param2 + param1.value / this._minIncrement);
         }
         if(this._cyclic)
         {
            if(_loc3_.value < this._minV || _loc3_.value > this._maxV)
            {
               _loc3_ = this.getValueObjectFromValue(_loc3_.value);
            }
         }
         else if(_loc3_.value < this._minV)
         {
            _loc3_ = this.getValueObjectFromValue(this._minV);
         }
         else if(_loc3_.value > this._maxV)
         {
            _loc3_ = this.getValueObjectFromValue(this._maxV);
         }
         return _loc3_;
      }
      
      public function set parameter(param1:Number) : void
      {
         this.value = this.getValueFromParameter(param1);
      }
      
      public function set value(param1:Number) : void
      {
         this.setValueByValueObject(this.getValueObjectFromValue(param1));
      }
      
      public function get valueString() : String
      {
         return this.getValueStringFromValueObject(this._valueObject);
      }
      
      public function toString() : String
      {
         var _loc1_:String = "ProtoSliderLogic instance:\n";
         _loc1_ += " _sMode: " + String(this._sMode) + "\n";
         _loc1_ += " _pMode: " + String(this._pMode) + "\n";
         _loc1_ += " _digs: " + String(this._digs) + "\n";
         _loc1_ += " _lowerSigLimit: " + String(this._lowerSigLimit) + "\n";
         _loc1_ += " _upperSigLimit: " + String(this._upperSigLimit) + "\n";
         _loc1_ += " _ticksPerMag: " + String(this._ticksPerMag) + "\n";
         _loc1_ += " _minIncrement: " + String(this._minIncrement) + "\n";
         _loc1_ += " _minV: " + String(this._minV) + "\n";
         _loc1_ += " _maxV: " + String(this._maxV) + "\n";
         _loc1_ += " _minP: " + String(this._minP) + "\n";
         _loc1_ += " _maxP: " + String(this._maxP) + "\n";
         _loc1_ += " _logMinV: " + String(this._logMinV) + "\n";
         _loc1_ += " _scale: " + String(this._scale) + "\n";
         _loc1_ += " value: " + String(this.value) + "\n";
         return _loc1_ + (" valueString: " + this.valueString + "\n");
      }
      
      public function get value() : Number
      {
         return this._valueObject.value;
      }
      
      public function getClosestIndex() : int
      {
         if(this._valueObject.closestIndex is int)
         {
            return this._valueObject.closestIndex;
         }
         return -1;
      }
   }
}

