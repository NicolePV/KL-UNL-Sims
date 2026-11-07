function CubicEasingClass(initValue)
{
   this.slope1 = 0;
   this.init(initValue);
}
var p = CubicEasingClass.prototype = new Object();
p.init = function(initValue)
{
   this.setTarget(0,initValue,1,initValue);
};
p.setTarget = function(xStart, yStart, xTarget, yTarget)
{
   if(yStart == null)
   {
      yStart = this.getValue(xStart);
      this.slope0 = this.getDerivative(xStart);
   }
   else
   {
      this.slope0 = 0;
   }
   this.splinePointsList = [{x:xStart,y:yStart},{x:xTarget,y:yTarget}];
   this.doComputations();
   this.targetValue = yTarget;
};
p.getValue = function(x)
{
   var _loc3_ = this.parametersList;
   var _loc4_ = _loc3_.length;
   var _loc2_ = 0;
   while(_loc2_ < _loc4_)
   {
      if(x < _loc3_[_loc2_].xUpper)
      {
         break;
      }
      _loc2_ = _loc2_ + 1;
   }
   var _loc6_;
   if(_loc2_ < _loc4_)
   {
      _loc6_ = _loc3_[_loc2_].d + x * (_loc3_[_loc2_].c + x * (_loc3_[_loc2_].b + x * _loc3_[_loc2_].a));
   }
   else
   {
      _loc6_ = this.targetValue;
   }
   return _loc6_;
};
p.getDerivative = function(x)
{
   var _loc3_ = this.parametersList;
   var _loc4_ = _loc3_.length;
   var _loc2_ = 0;
   while(_loc2_ < _loc4_)
   {
      if(x < _loc3_[_loc2_].xUpper)
      {
         break;
      }
      _loc2_ = _loc2_ + 1;
   }
   if(_loc2_ < _loc4_)
   {
      return _loc3_[_loc2_].c + x * (2 * _loc3_[_loc2_].b + 3 * x * _loc3_[_loc2_].a);
   }
   return 0;
};
p.doComputations = function()
{
   var _loc2_ = this.splinePointsList;
   _loc2_.sort(this.pointsCompareFunc);
   var _loc26_ = _loc2_.length;
   var _loc17_ = _loc26_ - 1;
   var _loc18_ = _loc26_ - 2;
   var _loc28_ = this.slope0;
   var _loc27_ = this.slope1;
   var _loc10_ = [];
   var _loc30_ = [];
   _loc2_[0].d2 = -0.5;
   _loc10_[0] = 3 / (_loc2_[1].x - _loc2_[0].x) * ((_loc2_[1].y - _loc2_[0].y) / (_loc2_[1].x - _loc2_[0].x) - _loc28_);
   var _loc8_ = 1;
   var _loc11_;
   var _loc15_;
   while(_loc8_ < _loc17_)
   {
      _loc11_ = (_loc2_[_loc8_].x - _loc2_[_loc8_ - 1].x) / (_loc2_[_loc8_ + 1].x - _loc2_[_loc8_ - 1].x);
      _loc15_ = _loc11_ * _loc2_[_loc8_ - 1].d2 + 2;
      _loc2_[_loc8_].d2 = (_loc11_ - 1) / _loc15_;
      _loc10_[_loc8_] = (_loc2_[_loc8_ + 1].y - _loc2_[_loc8_].y) / (_loc2_[_loc8_ + 1].x - _loc2_[_loc8_].x) - (_loc2_[_loc8_].y - _loc2_[_loc8_ - 1].y) / (_loc2_[_loc8_].x - _loc2_[_loc8_ - 1].x);
      _loc10_[_loc8_] = (6 * _loc10_[_loc8_] / (_loc2_[_loc8_ + 1].x - _loc2_[_loc8_ - 1].x) - _loc11_ * _loc10_[_loc8_ - 1]) / _loc15_;
      _loc8_ = _loc8_ + 1;
   }
   var _loc25_ = 0.5;
   var _loc29_ = 3 / (_loc2_[_loc17_].x - _loc2_[_loc18_].x) * (_loc27_ - (_loc2_[_loc17_].y - _loc2_[_loc18_].y) / (_loc2_[_loc17_].x - _loc2_[_loc18_].x));
   _loc2_[_loc17_].d2 = (_loc29_ - _loc25_ * _loc10_[_loc18_]) / (_loc25_ * _loc2_[_loc18_].d2 + 1);
   var _loc7_ = _loc18_;
   while(_loc7_ >= 0)
   {
      _loc2_[_loc7_].d2 = _loc2_[_loc7_].d2 * _loc2_[_loc7_ + 1].d2 + _loc10_[_loc7_];
      _loc7_ = _loc7_ - 1;
   }
   var _loc24_ = [];
   _loc8_ = 0;
   var _loc13_;
   var _loc12_;
   var _loc5_;
   var _loc6_;
   var _loc4_;
   var _loc3_;
   var _loc14_;
   var _loc16_;
   var _loc9_;
   var _loc22_;
   var _loc21_;
   var _loc20_;
   var _loc19_;
   while(_loc8_ < _loc17_)
   {
      _loc13_ = _loc2_[_loc8_];
      _loc12_ = _loc2_[_loc8_ + 1];
      _loc5_ = _loc13_.d2;
      _loc6_ = _loc12_.d2;
      _loc4_ = _loc13_.x;
      _loc3_ = _loc12_.x;
      _loc14_ = _loc13_.y;
      _loc16_ = _loc12_.y;
      _loc9_ = _loc3_ - _loc4_;
      _loc22_ = (_loc6_ - _loc5_) / (6 * _loc9_);
      _loc21_ = (3 * _loc3_ * _loc5_ - 3 * _loc6_ * _loc4_) / (6 * _loc9_);
      _loc20_ = (-6 * _loc14_ + 2 * _loc3_ * _loc6_ * _loc4_ - _loc3_ * _loc3_ * _loc6_ - 2 * _loc3_ * _loc5_ * _loc4_ + _loc5_ * _loc4_ * _loc4_ - 2 * _loc3_ * _loc3_ * _loc5_ + 6 * _loc16_ + 2 * _loc6_ * _loc4_ * _loc4_) / (6 * _loc9_);
      _loc19_ = (-2 * _loc6_ * _loc3_ * _loc4_ * _loc4_ + 2 * _loc5_ * _loc3_ * _loc3_ * _loc4_ + _loc6_ * _loc3_ * _loc3_ * _loc4_ - 6 * _loc16_ * _loc4_ + 6 * _loc14_ * _loc3_ - _loc5_ * _loc3_ * _loc4_ * _loc4_) / (6 * _loc9_);
      _loc24_.push({xUpper:_loc3_,a:_loc22_,b:_loc21_,c:_loc20_,d:_loc19_});
      _loc8_ = _loc8_ + 1;
   }
   this.parametersList = _loc24_;
};
p.pointsCompareFunc = function(a, b)
{
   if(a.x < b.x)
   {
      return -1;
   }
   if(a.x > b.x)
   {
      return 1;
   }
   return 0;
};
