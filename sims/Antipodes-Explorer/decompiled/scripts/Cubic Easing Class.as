function CubicEasingClass(initValue)
{
   this.slope1 = 0;
   this.setTarget(0,initValue,1,initValue);
}
var p = CubicEasingClass.prototype = new Object();
p.setTarget = function(xStart, yStart, xTarget, yTarget)
{
   var _loc1_ = this;
   var _loc2_ = xStart;
   var _loc3_ = yStart;
   if(_loc3_ == null)
   {
      _loc3_ = _loc1_.getValue(_loc2_);
      _loc1_.slope0 = _loc1_.getDerivative(_loc2_);
   }
   else
   {
      _loc1_.slope0 = 0;
   }
   _loc1_.splinePointsList = [{x:_loc2_,y:_loc3_},{x:xTarget,y:yTarget}];
   _loc1_.doComputations();
   _loc1_.targetValue = yTarget;
};
p.getValue = function(x)
{
   var _loc2_ = this.parametersList;
   var _loc3_ = _loc2_.length;
   var _loc1_ = 0;
   while(_loc1_ < _loc3_)
   {
      if(x < _loc2_[_loc1_].xUpper)
      {
         break;
      }
      _loc1_ = _loc1_ + 1;
   }
   if(_loc1_ < _loc3_)
   {
      return _loc2_[_loc1_].d + x * (_loc2_[_loc1_].c + x * (_loc2_[_loc1_].b + x * _loc2_[_loc1_].a));
   }
   return this.targetValue;
};
p.getDerivative = function(x)
{
   var _loc2_ = this.parametersList;
   var _loc3_ = _loc2_.length;
   var _loc1_ = 0;
   while(_loc1_ < _loc3_)
   {
      if(x < _loc2_[_loc1_].xUpper)
      {
         break;
      }
      _loc1_ = _loc1_ + 1;
   }
   if(_loc1_ < _loc3_)
   {
      return _loc2_[_loc1_].c + x * (2 * _loc2_[_loc1_].b + 3 * x * _loc2_[_loc1_].a);
   }
   return 0;
};
p.doComputations = function()
{
   var _loc1_ = this.splinePointsList;
   _loc1_.sort(this.pointsCompareFunc);
   var n = _loc1_.length;
   var n_1 = n - 1;
   var n_2 = n - 2;
   var m0 = this.slope0;
   var m1 = this.slope1;
   var uL = [];
   var y2L = [];
   _loc1_[0].d2 = -0.5;
   uL[0] = 3 / (_loc1_[1].x - _loc1_[0].x) * ((_loc1_[1].y - _loc1_[0].y) / (_loc1_[1].x - _loc1_[0].x) - m0);
   var i = 1;
   while(i < n_1)
   {
      var sig = (_loc1_[i].x - _loc1_[i - 1].x) / (_loc1_[i + 1].x - _loc1_[i - 1].x);
      var p = sig * _loc1_[i - 1].d2 + 2;
      _loc1_[i].d2 = (sig - 1) / p;
      uL[i] = (_loc1_[i + 1].y - _loc1_[i].y) / (_loc1_[i + 1].x - _loc1_[i].x) - (_loc1_[i].y - _loc1_[i - 1].y) / (_loc1_[i].x - _loc1_[i - 1].x);
      uL[i] = (6 * uL[i] / (_loc1_[i + 1].x - _loc1_[i - 1].x) - sig * uL[i - 1]) / p;
      i++;
   }
   var qn = 0.5;
   var un = 3 / (_loc1_[n_1].x - _loc1_[n_2].x) * (m1 - (_loc1_[n_1].y - _loc1_[n_2].y) / (_loc1_[n_1].x - _loc1_[n_2].x));
   _loc1_[n_1].d2 = (un - qn * uL[n_2]) / (qn * _loc1_[n_2].d2 + 1);
   var k = n_2;
   while(k >= 0)
   {
      _loc1_[k].d2 = _loc1_[k].d2 * _loc1_[k + 1].d2 + uL[k];
      k--;
   }
   var cL = [];
   var i = 0;
   var _loc3_;
   var _loc2_;
   while(i < n_1)
   {
      var p1 = _loc1_[i];
      var p2 = _loc1_[i + 1];
      var p1d2 = p1.d2;
      var p2d2 = p2.d2;
      _loc3_ = p1.x;
      _loc2_ = p2.x;
      var p1y = p1.y;
      var p2y = p2.y;
      var h = _loc2_ - _loc3_;
      var a = (p2d2 - p1d2) / (6 * h);
      var b = (3 * _loc2_ * p1d2 - 3 * p2d2 * _loc3_) / (6 * h);
      var c = (-6 * p1y + 2 * _loc2_ * p2d2 * _loc3_ - _loc2_ * _loc2_ * p2d2 - 2 * _loc2_ * p1d2 * _loc3_ + p1d2 * _loc3_ * _loc3_ - 2 * _loc2_ * _loc2_ * p1d2 + 6 * p2y + 2 * p2d2 * _loc3_ * _loc3_) / (6 * h);
      var d = (-2 * p2d2 * _loc2_ * _loc3_ * _loc3_ + 2 * p1d2 * _loc2_ * _loc2_ * _loc3_ + p2d2 * _loc2_ * _loc2_ * _loc3_ - 6 * p2y * _loc3_ + 6 * p1y * _loc2_ - p1d2 * _loc2_ * _loc3_ * _loc3_) / (6 * h);
      cL.push({xUpper:_loc2_,a:a,b:b,c:c,d:d});
      i++;
   }
   this.parametersList = cL;
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
