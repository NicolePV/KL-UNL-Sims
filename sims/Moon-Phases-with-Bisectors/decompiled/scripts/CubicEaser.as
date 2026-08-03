package
{
   public class CubicEaser
   {
      
      public var targetValue:Number;
      
      public var slope0:Number = 0;
      
      public var slope1:Number = 0;
      
      public var parametersList:Array;
      
      public var splinePointsList:Array;
      
      public var targetTime:Number;
      
      public function CubicEaser(param1:Number)
      {
         super();
         init(param1);
      }
      
      protected function doComputations() : void
      {
         var _loc1_:int = 0;
         var _loc2_:* = 0;
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc16_:Object = null;
         var _loc17_:Object = null;
         var _loc18_:Number = NaN;
         var _loc19_:Number = NaN;
         var _loc20_:Number = NaN;
         var _loc21_:Number = NaN;
         var _loc22_:Number = NaN;
         var _loc23_:Number = NaN;
         var _loc24_:Number = NaN;
         var _loc25_:Number = NaN;
         var _loc26_:Number = NaN;
         var _loc27_:Number = NaN;
         var _loc28_:Number = NaN;
         splinePointsList.sortOn("x",Array.NUMERIC);
         var _loc5_:Array = splinePointsList;
         var _loc6_:int = int(_loc5_.length);
         var _loc7_:int = _loc6_ - 1;
         var _loc8_:int = _loc6_ - 2;
         var _loc9_:Number = this.slope0;
         var _loc10_:Number = this.slope1;
         var _loc11_:Array = [];
         var _loc12_:Array = [];
         _loc5_[0].d2 = -0.5;
         _loc11_[0] = 3 / (_loc5_[1].x - _loc5_[0].x) * ((_loc5_[1].y - _loc5_[0].y) / (_loc5_[1].x - _loc5_[0].x) - _loc9_);
         _loc1_ = 1;
         while(_loc1_ < _loc7_)
         {
            _loc3_ = (_loc5_[_loc1_].x - _loc5_[_loc1_ - 1].x) / (_loc5_[_loc1_ + 1].x - _loc5_[_loc1_ - 1].x);
            _loc4_ = _loc3_ * _loc5_[_loc1_ - 1].d2 + 2;
            _loc5_[_loc1_].d2 = (_loc3_ - 1) / _loc4_;
            _loc11_[_loc1_] = (_loc5_[_loc1_ + 1].y - _loc5_[_loc1_].y) / (_loc5_[_loc1_ + 1].x - _loc5_[_loc1_].x) - (_loc5_[_loc1_].y - _loc5_[_loc1_ - 1].y) / (_loc5_[_loc1_].x - _loc5_[_loc1_ - 1].x);
            _loc11_[_loc1_] = (6 * _loc11_[_loc1_] / (_loc5_[_loc1_ + 1].x - _loc5_[_loc1_ - 1].x) - _loc3_ * _loc11_[_loc1_ - 1]) / _loc4_;
            _loc1_++;
         }
         var _loc13_:Number = 0.5;
         var _loc14_:Number = 3 / (_loc5_[_loc7_].x - _loc5_[_loc8_].x) * (_loc10_ - (_loc5_[_loc7_].y - _loc5_[_loc8_].y) / (_loc5_[_loc7_].x - _loc5_[_loc8_].x));
         _loc5_[_loc7_].d2 = (_loc14_ - _loc13_ * _loc11_[_loc8_]) / (_loc13_ * _loc5_[_loc8_].d2 + 1);
         _loc2_ = _loc8_;
         while(_loc2_ >= 0)
         {
            _loc5_[_loc2_].d2 = _loc5_[_loc2_].d2 * _loc5_[_loc2_ + 1].d2 + _loc11_[_loc2_];
            _loc2_--;
         }
         var _loc15_:Array = [];
         _loc1_ = 0;
         while(_loc1_ < _loc7_)
         {
            _loc16_ = _loc5_[_loc1_];
            _loc17_ = _loc5_[_loc1_ + 1];
            _loc18_ = Number(_loc16_.d2);
            _loc19_ = Number(_loc17_.d2);
            _loc20_ = Number(_loc16_.x);
            _loc21_ = Number(_loc17_.x);
            _loc22_ = Number(_loc16_.y);
            _loc23_ = Number(_loc17_.y);
            _loc24_ = _loc21_ - _loc20_;
            _loc25_ = (_loc19_ - _loc18_) / (6 * _loc24_);
            _loc26_ = (3 * _loc21_ * _loc18_ - 3 * _loc19_ * _loc20_) / (6 * _loc24_);
            _loc27_ = (-6 * _loc22_ + 2 * _loc21_ * _loc19_ * _loc20_ - _loc21_ * _loc21_ * _loc19_ - 2 * _loc21_ * _loc18_ * _loc20_ + _loc18_ * _loc20_ * _loc20_ - 2 * _loc21_ * _loc21_ * _loc18_ + 6 * _loc23_ + 2 * _loc19_ * _loc20_ * _loc20_) / (6 * _loc24_);
            _loc28_ = (-2 * _loc19_ * _loc21_ * _loc20_ * _loc20_ + 2 * _loc18_ * _loc21_ * _loc21_ * _loc20_ + _loc19_ * _loc21_ * _loc21_ * _loc20_ - 6 * _loc23_ * _loc20_ + 6 * _loc22_ * _loc21_ - _loc18_ * _loc21_ * _loc20_ * _loc20_) / (6 * _loc24_);
            _loc15_.push({
               "xUpper":_loc21_,
               "a":_loc25_,
               "b":_loc26_,
               "c":_loc27_,
               "d":_loc28_
            });
            _loc1_++;
         }
         parametersList = _loc15_;
      }
      
      public function getTargetValue() : Number
      {
         return targetValue;
      }
      
      public function getTargetTime() : Number
      {
         return targetTime;
      }
      
      public function init(param1:Number) : void
      {
         setTarget(0,param1,1,param1);
      }
      
      public function setTarget(param1:Number, param2:*, param3:Number, param4:Number) : Object
      {
         if(!(param2 is Number))
         {
            param2 = getValue(param1);
            slope0 = getDerivative(param1);
         }
         else
         {
            slope0 = 0;
         }
         splinePointsList = [{
            "x":param1,
            "y":param2
         },{
            "x":param3,
            "y":param4
         }];
         doComputations();
         targetTime = param3;
         targetValue = param4;
         return {
            "a":parametersList[0].a,
            "b":parametersList[0].b,
            "c":parametersList[0].c,
            "d":parametersList[0].d
         };
      }
      
      public function getValue(param1:Number) : Number
      {
         var _loc2_:Array = parametersList;
         var _loc3_:int = int(_loc2_.length);
         var _loc4_:int = 0;
         while(_loc4_ < _loc3_)
         {
            if(param1 < _loc2_[_loc4_].xUpper)
            {
               break;
            }
            _loc4_++;
         }
         if(_loc4_ < _loc3_)
         {
            return _loc2_[_loc4_].d + param1 * (_loc2_[_loc4_].c + param1 * (_loc2_[_loc4_].b + param1 * _loc2_[_loc4_].a));
         }
         return targetValue;
      }
      
      public function getDerivative(param1:Number) : Number
      {
         var _loc2_:Array = parametersList;
         var _loc3_:int = int(_loc2_.length);
         var _loc4_:int = 0;
         while(_loc4_ < _loc3_)
         {
            if(param1 < _loc2_[_loc4_].xUpper)
            {
               break;
            }
            _loc4_++;
         }
         if(_loc4_ < _loc3_)
         {
            return _loc2_[_loc4_].c + param1 * (2 * _loc2_[_loc4_].b + 3 * param1 * _loc2_[_loc4_].a);
         }
         return 0;
      }
   }
}

