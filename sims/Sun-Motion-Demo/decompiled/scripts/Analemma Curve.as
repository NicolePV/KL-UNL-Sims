function AnalemmaCurveClass()
{
   this.init(60);
   this.lineThickness = 2;
   this.frontMC = this.sphere._fC.createEmptyMovieClip("analemmaFrontMC",12345);
   this.backMC = this.sphere._bC.createEmptyMovieClip("analemmaBackMC",12345);
   var thisBalloon = this._parent.balloonsMC.analemmaBalloon;
   var thisCurve = this;
   var thisParent = this._parent;
   this.frontMC.useHandCursor = false;
   this.frontMC.onRollOver = function()
   {
      thisBalloon._visible = true;
      thisCurve.lineThickness = 4;
      thisCurve.update();
      var _loc2_ = thisParent._xmouse - 5;
      if(_loc2_ < thisBalloon._width)
      {
         _loc2_ = thisBalloon._width;
      }
      var _loc1_ = thisParent._ymouse - 5;
      if(_loc1_ < thisBalloon._height)
      {
         _loc1_ = thisBalloon._height;
      }
      thisBalloon._x = _loc2_;
      thisBalloon._y = _loc1_;
   };
   this.frontMC.onRollOut = this.frontMC.onReleaseOutside = function()
   {
      thisBalloon._visible = false;
      thisCurve.lineThickness = 2;
      thisCurve.update();
   };
   this._c = {};
   this.clatLast = null;
   this.itodLast = null;
   this.visible = true;
}
var p = AnalemmaCurveClass.prototype = new MovieClip();
Object.registerClass("Analemma Curve",AnalemmaCurveClass);
p.limitA = 22;
p.limitB = -22;
p.init = function(N)
{
   var _loc14_ = 365 / N;
   var _loc9_ = Math.sin;
   var _loc10_ = Math.cos;
   this.points = [];
   var _loc4_ = this.points;
   var _loc16_ = this.limitA;
   var _loc15_ = this.limitB;
   var _loc2_ = 0;
   var _loc3_;
   var _loc5_;
   var _loc7_;
   var _loc6_;
   var _loc8_;
   while(_loc2_ < N)
   {
      _loc3_ = _loc2_ * _loc14_;
      _loc5_ = getPosition(_loc3_);
      _loc7_ = - getEqnOfTime(_loc3_);
      _loc6_ = 0.017453292519943295 * _loc5_.dec;
      _loc8_ = _loc10_(_loc6_);
      _loc4_[_loc2_] = {x:_loc8_ * _loc10_(_loc7_),y:_loc8_ * _loc9_(_loc7_),z:_loc9_(_loc6_)};
      if(_loc5_.dec >= _loc16_)
      {
         _loc4_[_loc2_].interval = 1;
      }
      else if(_loc5_.dec <= _loc15_)
      {
         _loc4_[_loc2_].interval = 3;
      }
      else if(_loc3_ > 354.318929563686 || _loc3_ < 170.941195869382)
      {
         _loc4_[_loc2_].interval = 0;
      }
      else
      {
         _loc4_[_loc2_].interval = 2;
      }
      _loc2_ = _loc2_ + 1;
   }
};
p.update = function()
{
   var _loc29_ = getTimer();
   var _loc10_ = this.frontMC;
   _loc10_.clear();
   var _loc8_ = this.backMC;
   _loc8_.clear();
   if(!this._vis)
   {
      return undefined;
   }
   var _loc5_ = this._c;
   var _loc9_ = this.sphere._c;
   var _loc12_ = this.points;
   var _loc16_ = _loc12_.length;
   _loc10_.lineStyle(this.lineThickness,16720932,70);
   _loc8_.lineStyle(this.lineThickness,16720932,70);
   var _loc23_ = 0.017453292519943295 * (90 - this.sphere.latitude);
   var _loc24_ = -6.283185307179586 * (this._parent.day % 1);
   var _loc28_;
   var _loc27_;
   var _loc26_;
   var _loc25_;
   if(_loc23_ != this.clatLast || _loc24_ != this.itodLast)
   {
      _loc28_ = Math.sin(_loc23_);
      _loc27_ = Math.cos(_loc23_);
      _loc26_ = Math.sin(_loc24_);
      _loc25_ = Math.cos(_loc24_);
      _loc5_.k0 = _loc27_ * _loc25_;
      _loc5_.k1 = (- _loc27_) * _loc26_;
      _loc5_.k2 = _loc28_;
      _loc5_.k3 = _loc26_;
      _loc5_.k4 = _loc25_;
      _loc5_.k5 = 0;
      _loc5_.k6 = (- _loc28_) * _loc25_;
      _loc5_.k7 = _loc28_ * _loc26_;
      _loc5_.k8 = _loc27_;
      this.clatLast = _loc23_;
      this.itodLast = _loc24_;
   }
   var _loc22_ = _loc9_.a0 * _loc5_.k0 + _loc9_.a1 * _loc5_.k3;
   var _loc21_ = _loc9_.a0 * _loc5_.k1 + _loc9_.a1 * _loc5_.k4;
   var _loc20_ = _loc9_.a0 * _loc5_.k2;
   var _loc19_ = _loc9_.a3 * _loc5_.k0 + _loc9_.a4 * _loc5_.k3 + _loc9_.a5 * _loc5_.k6;
   var _loc18_ = _loc9_.a3 * _loc5_.k1 + _loc9_.a4 * _loc5_.k4 + _loc9_.a5 * _loc5_.k7;
   var _loc17_ = _loc9_.a3 * _loc5_.k2 + _loc9_.a5 * _loc5_.k8;
   var _loc15_ = _loc9_.a6 * _loc5_.k0 + _loc9_.a7 * _loc5_.k3 + _loc9_.a8 * _loc5_.k6;
   var _loc14_ = _loc9_.a6 * _loc5_.k1 + _loc9_.a7 * _loc5_.k4 + _loc9_.a8 * _loc5_.k7;
   var _loc13_ = _loc9_.a6 * _loc5_.k2 + _loc9_.a8 * _loc5_.k8;
   var _loc2_ = _loc12_[_loc16_ - 1];
   var _loc4_ = _loc22_ * _loc2_.x + _loc21_ * _loc2_.y + _loc20_ * _loc2_.z;
   var _loc3_ = _loc19_ * _loc2_.x + _loc18_ * _loc2_.y + _loc17_ * _loc2_.z;
   var _loc11_ = _loc15_ * _loc2_.x + _loc14_ * _loc2_.y + _loc13_ * _loc2_.z;
   var _loc7_;
   if(_loc11_ > 0)
   {
      _loc7_ = true;
      _loc10_.moveTo(_loc4_,_loc3_);
   }
   else
   {
      _loc7_ = false;
      _loc8_.moveTo(_loc4_,_loc3_);
   }
   var _loc6_ = 0;
   while(_loc6_ < _loc16_)
   {
      _loc2_ = _loc12_[_loc6_];
      _loc4_ = _loc22_ * _loc2_.x + _loc21_ * _loc2_.y + _loc20_ * _loc2_.z;
      _loc3_ = _loc19_ * _loc2_.x + _loc18_ * _loc2_.y + _loc17_ * _loc2_.z;
      _loc11_ = _loc15_ * _loc2_.x + _loc14_ * _loc2_.y + _loc13_ * _loc2_.z;
      if(_loc11_ > 0)
      {
         if(_loc7_)
         {
            _loc10_.lineTo(_loc4_,_loc3_);
         }
         else
         {
            _loc8_.lineTo(_loc4_,_loc3_);
            _loc10_.moveTo(_loc4_,_loc3_);
         }
         _loc7_ = true;
      }
      else
      {
         if(_loc7_)
         {
            _loc10_.lineTo(_loc4_,_loc3_);
            _loc8_.moveTo(_loc4_,_loc3_);
         }
         else
         {
            _loc8_.lineTo(_loc4_,_loc3_);
         }
         _loc7_ = false;
      }
      _loc6_ = _loc6_ + 1;
   }
   trace("analemma time: " + (getTimer() - _loc29_));
};
p.setClosestDay = function()
{
   var _loc14_ = this.sphere._c.r;
   var _loc25_ = this.sphere._xmouse;
   var _loc24_ = this.sphere._ymouse;
   var _loc13_ = Math.sqrt(_loc25_ * _loc25_ + _loc24_ * _loc24_);
   if(_loc13_ > _loc14_)
   {
      _loc14_ = _loc13_;
   }
   var _loc29_ = Math.atan2(_loc24_,_loc25_);
   var _loc43_ = _loc13_ * Math.cos(_loc29_);
   var _loc31_ = _loc13_ * Math.sin(_loc29_);
   var _loc30_ = Math.sqrt(_loc14_ * _loc14_ - _loc13_ * _loc13_);
   var _loc3_ = this._c;
   var _loc5_ = this.sphere._c;
   var _loc9_ = this.points;
   var _loc7_ = _loc9_.length;
   var _loc19_ = 0.017453292519943295 * (90 - this.sphere.latitude);
   var _loc20_ = -6.283185307179586 * (this._parent.day % 1);
   var _loc27_;
   var _loc26_;
   var _loc22_;
   var _loc21_;
   if(_loc19_ != this.clatLast || _loc20_ != this.itodLast)
   {
      _loc27_ = Math.sin(_loc19_);
      _loc26_ = Math.cos(_loc19_);
      _loc22_ = Math.sin(_loc20_);
      _loc21_ = Math.cos(_loc20_);
      _loc3_.k0 = _loc26_ * _loc21_;
      _loc3_.k1 = (- _loc26_) * _loc22_;
      _loc3_.k2 = _loc27_;
      _loc3_.k3 = _loc22_;
      _loc3_.k4 = _loc21_;
      _loc3_.k5 = 0;
      _loc3_.k6 = (- _loc27_) * _loc21_;
      _loc3_.k7 = _loc27_ * _loc22_;
      _loc3_.k8 = _loc26_;
      this.clatLast = _loc19_;
      this.itodLast = _loc20_;
   }
   var _loc42_ = _loc5_.a0 * _loc3_.k0 + _loc5_.a1 * _loc3_.k3;
   var _loc40_ = _loc5_.a0 * _loc3_.k1 + _loc5_.a1 * _loc3_.k4;
   var _loc38_ = _loc5_.a0 * _loc3_.k2;
   var _loc37_ = _loc5_.a3 * _loc3_.k0 + _loc5_.a4 * _loc3_.k3 + _loc5_.a5 * _loc3_.k6;
   var _loc36_ = _loc5_.a3 * _loc3_.k1 + _loc5_.a4 * _loc3_.k4 + _loc5_.a5 * _loc3_.k7;
   var _loc35_ = _loc5_.a3 * _loc3_.k2 + _loc5_.a5 * _loc3_.k8;
   var _loc34_ = _loc5_.a6 * _loc3_.k0 + _loc5_.a7 * _loc3_.k3 + _loc5_.a8 * _loc3_.k6;
   var _loc33_ = _loc5_.a6 * _loc3_.k1 + _loc5_.a7 * _loc3_.k4 + _loc5_.a8 * _loc3_.k7;
   var _loc32_ = _loc5_.a6 * _loc3_.k2 + _loc5_.a8 * _loc3_.k8;
   var _loc39_ = 1 / (_loc14_ * _loc14_);
   var _loc11_ = _loc39_ * (_loc42_ * _loc43_ + _loc37_ * _loc31_ + _loc34_ * _loc30_);
   var _loc10_ = _loc39_ * (_loc40_ * _loc43_ + _loc36_ * _loc31_ + _loc33_ * _loc30_);
   var _loc12_ = _loc39_ * (_loc38_ * _loc43_ + _loc35_ * _loc31_ + _loc32_ * _loc30_);
   var _loc16_ = this._parent.day;
   var _loc28_ = this._parent.declination;
   var _loc15_;
   if(_loc28_ >= this.limitA)
   {
      _loc15_ = 3;
   }
   else if(_loc28_ <= this.limitB)
   {
      _loc15_ = 1;
   }
   else if(_loc16_ > 354.318929563686 || _loc16_ < 170.941195869382)
   {
      _loc15_ = 2;
   }
   else
   {
      _loc15_ = 0;
   }
   var _loc6_ = 4;
   var _loc8_ = 0;
   var _loc2_ = 0;
   var _loc23_;
   var _loc4_;
   while(_loc2_ < _loc7_)
   {
      _loc23_ = _loc9_[_loc2_];
      if(_loc23_.interval != _loc15_)
      {
         _loc43_ = _loc11_ - _loc23_.x;
         _loc31_ = _loc10_ - _loc23_.y;
         _loc30_ = _loc12_ - _loc23_.z;
         _loc4_ = _loc43_ * _loc43_ + _loc31_ * _loc31_ + _loc30_ * _loc30_;
         if(_loc4_ < _loc6_)
         {
            _loc6_ = _loc4_;
            _loc8_ = _loc2_;
         }
      }
      _loc2_ = _loc2_ + 1;
   }
   _loc23_ = _loc9_[((_loc8_ - 1) % _loc7_ + _loc7_) % _loc7_];
   _loc43_ = _loc11_ - _loc23_.x;
   _loc31_ = _loc10_ - _loc23_.y;
   _loc30_ = _loc12_ - _loc23_.z;
   var _loc18_ = _loc43_ * _loc43_ + _loc31_ * _loc31_ + _loc30_ * _loc30_;
   _loc23_ = _loc9_[(_loc8_ + 1) % _loc7_];
   _loc43_ = _loc11_ - _loc23_.x;
   _loc31_ = _loc10_ - _loc23_.y;
   _loc30_ = _loc12_ - _loc23_.z;
   var _loc17_ = _loc43_ * _loc43_ + _loc31_ * _loc31_ + _loc30_ * _loc30_;
   var _loc41_;
   if(_loc18_ <= _loc6_)
   {
      _loc41_ = Math.floor(365 * ((_loc8_ - 1) / _loc7_)) + (_loc16_ % 1 + 1) % 1;
   }
   else if(_loc17_ <= _loc6_)
   {
      _loc41_ = Math.floor(365 * ((_loc8_ + 1) / _loc7_)) + (_loc16_ % 1 + 1) % 1;
   }
   else
   {
      if(_loc18_ > _loc17_)
      {
         _loc39_ = _loc18_ - _loc6_;
      }
      else
      {
         _loc39_ = _loc17_ - _loc6_;
      }
      _loc43_ = (_loc18_ - _loc17_) / (2 * _loc39_);
      _loc41_ = Math.floor(365 * ((_loc8_ + _loc43_) / _loc7_)) + (_loc16_ % 1 + 1) % 1;
   }
   this._parent.setDay(_loc41_);
};
p.getVisible = function()
{
   return this._vis;
};
p.setVisible = function(arg)
{
   this._vis = Boolean(arg);
   this.update();
};
p.addProperty("visible",p.getVisible,p.setVisible);
