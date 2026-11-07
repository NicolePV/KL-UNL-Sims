function CSShadedBandClass(parent, name, id, linkageNameFront, linkageNameBack, parameters, surface, hemisphere, initObject)
{
   this._parent = parent;
   this._name = name;
   this._id = id;
   this._kVer = -1;
   this._c = {};
   this._visible = true;
   this._showBorder = false;
   this.setLinkageNames(linkageNameFront,linkageNameBack,surface,hemisphere,initObject);
   this.setParameters(parameters);
}
var p = CelestialSphereClass.prototype;
p.addShadedBand = function(linkageNameFront, linkageNameBack, name, parameters, surface, hemisphere, initObject)
{
   var _loc3_ = this._shadedBandFreeID++;
   this[name] = new CSShadedBandClass(this,name,_loc3_,linkageNameFront,linkageNameBack,parameters,surface,hemisphere,initObject);
   this._shadedBandList.push({id:_loc3_,name:this[name]});
   return this[name];
};
p.updateShadedBands = function(notHorizon)
{
   var _loc5_ = getTimer();
   var _loc3_ = this._shadedBandList;
   var _loc2_;
   var _loc4_;
   if(notHorizon)
   {
      _loc2_ = 0;
      while(_loc2_ < _loc3_.length)
      {
         _loc4_ = _loc3_[_loc2_].name;
         if(_loc4_._sys != 0)
         {
            _loc4_.update();
         }
         _loc2_ = _loc2_ + 1;
      }
   }
   else
   {
      _loc2_ = 0;
      while(_loc2_ < _loc3_.length)
      {
         _loc3_[_loc2_].name.update();
         _loc2_ = _loc2_ + 1;
      }
   }
   if(this._traceOn)
   {
      trace("shaded bands: " + (getTimer() - _loc5_) + " ms");
   }
};
p.showShadedBands = function()
{
   var _loc3_ = this._shadedBandList;
   var _loc2_ = 0;
   while(_loc2_ < _loc3_.length)
   {
      _loc3_[_loc2_].name.visible = true;
      _loc2_ = _loc2_ + 1;
   }
};
p.hideShadedBands = function()
{
   var _loc3_ = this._shadedBandList;
   var _loc2_ = 0;
   while(_loc2_ < _loc3_.length)
   {
      _loc3_[_loc2_].name.visible = false;
      _loc2_ = _loc2_ + 1;
   }
};
p.removeShadedBands = function()
{
   var _loc3_ = this._shadedBandList;
   var _loc2_ = 0;
   while(_loc2_ < _loc3_.length)
   {
      _loc3_[_loc2_].name._frontMC.removeMovieClip();
      _loc3_[_loc2_].name._backMC.removeMovieClip();
      delete this[_loc3_[_loc2_].name._name];
      _loc2_ = _loc2_ + 1;
   }
   this._shadedBandFreeID = 0;
   this._shadedBandList = [];
};
var p = CSShadedBandClass.prototype = new Object();
p._bThick = 0;
p._bColor = 0;
p._bAlpha = 100;
p._minStep = 0.5235987755982988;
p.update = function()
{
   function drawPerimeterArcs(t1, t2, dir, mc1, mc2)
   {
      var _loc15_;
      var _loc18_;
      var _loc12_;
      var _loc9_;
      if(dir == 1)
      {
         _loc15_ = ((t2 - t1) % 6.283185307179586 + 6.283185307179586) % 6.283185307179586;
         if(_loc15_ == 0)
         {
            _loc15_ = 6.283185307179586;
            _loc18_ = true;
         }
         else
         {
            _loc18_ = false;
         }
         _loc12_ = Math.ceil(_loc15_ / minStep);
         _loc9_ = _loc15_ / _loc12_;
      }
      else
      {
         _loc15_ = ((t1 - t2) % 6.283185307179586 + 6.283185307179586) % 6.283185307179586;
         if(_loc15_ == 0)
         {
            _loc15_ = 6.283185307179586;
            _loc18_ = true;
         }
         else
         {
            _loc18_ = false;
         }
         _loc12_ = Math.ceil(_loc15_ / minStep);
         _loc9_ = (- _loc15_) / _loc12_;
      }
      var _loc17_ = _loc9_ / 2;
      var _loc8_ = Math.cos;
      var _loc10_ = Math.sin;
      var _loc11_ = 100 / _loc8_(_loc17_);
      var _loc4_;
      var _loc3_;
      if(_loc18_)
      {
         _loc4_ = 100 * _loc8_(t1);
         _loc3_ = 100 * _loc10_(t1);
         mc1.moveTo(_loc4_,_loc3_);
         mc2.moveTo(_loc4_,_loc3_);
      }
      var _loc6_ = t1 + _loc9_;
      var _loc7_ = _loc6_ - _loc17_;
      var _loc5_ = 0;
      var _loc2_;
      var _loc1_;
      while(_loc5_ < _loc12_)
      {
         _loc4_ = 100 * _loc8_(_loc6_);
         _loc3_ = 100 * _loc10_(_loc6_);
         _loc2_ = _loc11_ * _loc8_(_loc7_);
         _loc1_ = _loc11_ * _loc10_(_loc7_);
         mc1.curveTo(_loc2_,_loc1_,_loc4_,_loc3_);
         mc2.curveTo(_loc2_,_loc1_,_loc4_,_loc3_);
         _loc6_ += _loc9_;
         _loc7_ += _loc9_;
         _loc5_ = _loc5_ + 1;
      }
   }
   function drawSphericalArc(g1, g2, cl, sl, dir, mc, bmc)
   {
      var _loc21_;
      var _loc24_;
      var _loc18_;
      var _loc15_;
      if(dir == 1)
      {
         _loc21_ = ((g2 - g1) % 6.283185307179586 + 6.283185307179586) % 6.283185307179586;
         if(_loc21_ == 0)
         {
            _loc21_ = 6.283185307179586;
            _loc24_ = true;
         }
         else
         {
            _loc24_ = false;
         }
         _loc18_ = Math.ceil(_loc21_ / minStep);
         _loc15_ = _loc21_ / _loc18_;
      }
      else
      {
         _loc21_ = ((g1 - g2) % 6.283185307179586 + 6.283185307179586) % 6.283185307179586;
         if(_loc21_ == 0)
         {
            _loc21_ = 6.283185307179586;
            _loc24_ = true;
         }
         else
         {
            _loc24_ = false;
         }
         _loc18_ = Math.ceil(_loc21_ / minStep);
         _loc15_ = (- _loc21_) / _loc18_;
      }
      var _loc23_ = _loc15_ / 2;
      var _loc14_ = Math.cos;
      var _loc16_ = Math.sin;
      var _loc17_ = 1 / _loc14_(_loc23_);
      var _loc6_ = _loc14_(g1);
      var _loc5_ = _loc16_(g1);
      var _loc10_ = cl * (v0 * _loc6_ + v1 * _loc5_) + sl * v2;
      var _loc9_ = cl * (v3 * _loc6_ + v4 * _loc5_) + sl * v5;
      if(_loc24_)
      {
         mc.moveTo(_loc10_,_loc9_);
      }
      bmc.moveTo(_loc10_,_loc9_);
      var _loc12_ = g1 + _loc15_;
      var _loc13_ = _loc12_ - _loc23_;
      var _loc11_ = 0;
      var _loc4_;
      var _loc3_;
      var _loc8_;
      var _loc7_;
      while(_loc11_ < _loc18_)
      {
         _loc6_ = _loc14_(_loc12_);
         _loc5_ = _loc16_(_loc12_);
         _loc4_ = _loc17_ * _loc14_(_loc13_);
         _loc3_ = _loc17_ * _loc16_(_loc13_);
         _loc10_ = cl * (v0 * _loc6_ + v1 * _loc5_) + sl * v2;
         _loc9_ = cl * (v3 * _loc6_ + v4 * _loc5_) + sl * v5;
         _loc8_ = cl * (v0 * _loc4_ + v1 * _loc3_) + sl * v2;
         _loc7_ = cl * (v3 * _loc4_ + v4 * _loc3_) + sl * v5;
         mc.curveTo(_loc8_,_loc7_,_loc10_,_loc9_);
         bmc.curveTo(_loc8_,_loc7_,_loc10_,_loc9_);
         _loc12_ += _loc15_;
         _loc13_ += _loc15_;
         _loc11_ = _loc11_ + 1;
      }
   }
   var _loc4_ = this._frontMaskMC;
   var _loc2_ = this._backMaskMC;
   var _loc21_ = this._frontBorderMC;
   var _loc18_ = this._backBorderMC;
   _loc4_.clear();
   _loc2_.clear();
   _loc21_.clear();
   _loc18_.clear();
   if(!this._visible || this._noDef)
   {
      return undefined;
   }
   _loc4_.beginFill(16711680);
   _loc2_.beginFill(255);
   _loc21_.lineStyle(this._bThick,this._bColor,this._bAlpha);
   _loc18_.lineStyle(this._bThick,this._bColor,this._bAlpha);
   var _loc25_ = Math.cos;
   var _loc27_ = Math.sin;
   var _loc55_ = Math.asin;
   var _loc38_ = Math.atan2;
   var _loc54_ = Math.sqrt;
   var _loc24_ = _loc25_(this._lambda1);
   var _loc23_ = _loc27_(this._lambda1);
   var _loc20_ = _loc25_(this._lambda2);
   var _loc17_ = _loc27_(this._lambda2);
   var _loc3_;
   var _loc7_;
   var _loc31_;
   var _loc0_;
   var _loc41_;
   var _loc40_;
   var _loc45_;
   var _loc30_;
   if(this._sys == 0 && (this._kLastVer != this._kVer || this._aLastVer != this._parent._aVer))
   {
      _loc3_ = this._c;
      _loc7_ = this._parent._c;
      _loc31_ = 100 / this._parent._c.r;
      var v0 = _loc3_.v0 = _loc31_ * (_loc7_.a0 * _loc3_.k0 + _loc7_.a1 * _loc3_.k3);
      var v1 = _loc3_.v1 = _loc31_ * (_loc7_.a0 * _loc3_.k1 + _loc7_.a1 * _loc3_.k4);
      var v2 = _loc3_.v2 = _loc31_ * (_loc7_.a0 * _loc3_.k2 + _loc7_.a1 * _loc3_.k5);
      var v3 = _loc3_.v3 = _loc31_ * (_loc7_.a3 * _loc3_.k0 + _loc7_.a4 * _loc3_.k3);
      var v4 = _loc3_.v4 = _loc31_ * (_loc7_.a3 * _loc3_.k1 + _loc7_.a4 * _loc3_.k4 + _loc7_.a5 * _loc3_.k7);
      var v5 = _loc3_.v5 = _loc31_ * (_loc7_.a3 * _loc3_.k2 + _loc7_.a4 * _loc3_.k5 + _loc7_.a5 * _loc3_.k8);
      _loc41_ = _loc3_.v6 = _loc31_ * (_loc7_.a6 * _loc3_.k0 + _loc7_.a7 * _loc3_.k3);
      _loc40_ = _loc3_.v7 = _loc31_ * (_loc7_.a6 * _loc3_.k1 + _loc7_.a7 * _loc3_.k4 + _loc7_.a8 * _loc3_.k7);
      _loc45_ = _loc3_.v8 = _loc31_ * (_loc7_.a6 * _loc3_.k2 + _loc7_.a7 * _loc3_.k5 + _loc7_.a8 * _loc3_.k8);
      this._kLastVer = this._kVer;
      this._aLastVer = this._parent._aVer;
   }
   else if(this._sys == 1 && (this._kLastVer != this._kVer || this._bLastVer != this._parent._bVer))
   {
      _loc3_ = this._c;
      _loc7_ = this._parent._c;
      _loc31_ = 100 / this._parent._c.r;
      var v0 = _loc3_.v0 = _loc31_ * (_loc7_.b0 * _loc3_.k0 + _loc7_.b1 * _loc3_.k3);
      var v1 = _loc3_.v1 = _loc31_ * (_loc7_.b0 * _loc3_.k1 + _loc7_.b1 * _loc3_.k4 + _loc7_.b2 * _loc3_.k7);
      var v2 = _loc3_.v2 = _loc31_ * (_loc7_.b0 * _loc3_.k2 + _loc7_.b1 * _loc3_.k5 + _loc7_.b2 * _loc3_.k8);
      var v3 = _loc3_.v3 = _loc31_ * (_loc7_.b3 * _loc3_.k0 + _loc7_.b4 * _loc3_.k3);
      var v4 = _loc3_.v4 = _loc31_ * (_loc7_.b3 * _loc3_.k1 + _loc7_.b4 * _loc3_.k4 + _loc7_.b5 * _loc3_.k7);
      var v5 = _loc3_.v5 = _loc31_ * (_loc7_.b3 * _loc3_.k2 + _loc7_.b4 * _loc3_.k5 + _loc7_.b5 * _loc3_.k8);
      _loc41_ = _loc3_.v6 = _loc31_ * (_loc7_.b6 * _loc3_.k0 + _loc7_.b7 * _loc3_.k3);
      _loc40_ = _loc3_.v7 = _loc31_ * (_loc7_.b6 * _loc3_.k1 + _loc7_.b7 * _loc3_.k4 + _loc7_.b8 * _loc3_.k7);
      _loc45_ = _loc3_.v8 = _loc31_ * (_loc7_.b6 * _loc3_.k2 + _loc7_.b7 * _loc3_.k5 + _loc7_.b8 * _loc3_.k8);
      this._kLastVer = this._kVer;
      this._bLastVer = this._parent._bVer;
   }
   else
   {
      _loc30_ = this._c;
      var v0 = _loc30_.v0;
      var v1 = _loc30_.v1;
      var v2 = _loc30_.v2;
      var v3 = _loc30_.v3;
      var v4 = _loc30_.v4;
      var v5 = _loc30_.v5;
      _loc41_ = _loc30_.v6;
      _loc40_ = _loc30_.v7;
      _loc45_ = _loc30_.v8;
   }
   var _loc5_ = null;
   var _loc6_ = null;
   var _loc53_ = _loc24_ * _loc54_(_loc41_ * _loc41_ + _loc40_ * _loc40_);
   var _loc33_;
   var _loc48_;
   var _loc42_;
   var _loc44_;
   var _loc37_;
   var _loc35_;
   var _loc47_;
   var _loc46_;
   var _loc52_;
   var _loc50_;
   if(_loc53_ == 0)
   {
      if(_loc23_ * _loc45_ < 0)
      {
         _loc33_ = 2;
      }
      else
      {
         _loc33_ = 1;
      }
   }
   else
   {
      _loc48_ = (- _loc23_) * _loc45_ / _loc53_;
      if(_loc48_ <= -1)
      {
         _loc33_ = 1;
      }
      else if(_loc48_ >= 1)
      {
         _loc33_ = 2;
      }
      else
      {
         _loc33_ = 0;
         _loc42_ = _loc55_(_loc48_);
         _loc44_ = _loc38_(_loc41_,_loc40_);
         if(_loc25_(_loc42_) < 0)
         {
            _loc37_ = _loc42_ - _loc44_;
            _loc35_ = 3.141592653589793 - _loc42_ - _loc44_;
         }
         else
         {
            _loc37_ = 3.141592653589793 - _loc42_ - _loc44_;
            _loc35_ = _loc42_ - _loc44_;
         }
         _loc47_ = _loc25_(_loc37_);
         _loc46_ = _loc27_(_loc37_);
         _loc52_ = _loc38_(_loc24_ * (v3 * _loc47_ + v4 * _loc46_) + _loc23_ * v5,_loc24_ * (v0 * _loc47_ + v1 * _loc46_) + _loc23_ * v2);
         _loc47_ = _loc25_(_loc35_);
         _loc46_ = _loc27_(_loc35_);
         _loc5_ = _loc24_ * (v0 * _loc47_ + v1 * _loc46_) + _loc23_ * v2;
         _loc6_ = _loc24_ * (v3 * _loc47_ + v4 * _loc46_) + _loc23_ * v5;
         _loc50_ = _loc38_(_loc6_,_loc5_);
      }
   }
   _loc53_ = _loc20_ * _loc54_(_loc41_ * _loc41_ + _loc40_ * _loc40_);
   var _loc32_;
   var _loc36_;
   var _loc34_;
   var _loc51_;
   var _loc49_;
   if(_loc53_ == 0)
   {
      if(_loc17_ * _loc45_ < 0)
      {
         _loc32_ = 2;
      }
      else
      {
         _loc32_ = 1;
      }
   }
   else
   {
      _loc48_ = (- _loc17_) * _loc45_ / _loc53_;
      if(_loc48_ <= -1)
      {
         _loc32_ = 1;
      }
      else if(_loc48_ >= 1)
      {
         _loc32_ = 2;
      }
      else
      {
         _loc32_ = 0;
         _loc42_ = _loc55_(_loc48_);
         _loc44_ = _loc38_(_loc41_,_loc40_);
         if(_loc25_(_loc42_) < 0)
         {
            _loc36_ = _loc42_ - _loc44_;
            _loc34_ = 3.141592653589793 - _loc42_ - _loc44_;
         }
         else
         {
            _loc36_ = 3.141592653589793 - _loc42_ - _loc44_;
            _loc34_ = _loc42_ - _loc44_;
         }
         _loc47_ = _loc25_(_loc36_);
         _loc46_ = _loc27_(_loc36_);
         _loc51_ = _loc38_(_loc20_ * (v3 * _loc47_ + v4 * _loc46_) + _loc17_ * v5,_loc20_ * (v0 * _loc47_ + v1 * _loc46_) + _loc17_ * v2);
         _loc47_ = _loc25_(_loc34_);
         _loc46_ = _loc27_(_loc34_);
         if(_loc5_ == null)
         {
            _loc5_ = _loc20_ * (v0 * _loc47_ + v1 * _loc46_) + _loc17_ * v2;
            _loc6_ = _loc20_ * (v3 * _loc47_ + v4 * _loc46_) + _loc17_ * v5;
            _loc49_ = _loc38_(_loc6_,_loc5_);
         }
         else
         {
            _loc49_ = _loc38_(_loc20_ * (v3 * _loc47_ + v4 * _loc46_) + _loc17_ * v5,_loc20_ * (v0 * _loc47_ + v1 * _loc46_) + _loc17_ * v2);
         }
      }
   }
   var minStep = this._minStep;
   if(_loc33_ == 0 && _loc32_ == 0)
   {
      _loc4_.moveTo(_loc5_,_loc6_);
      _loc2_.moveTo(_loc5_,_loc6_);
      _loc21_.moveTo(_loc5_,_loc6_);
      _loc18_.moveTo(_loc5_,_loc6_);
      drawPerimeterArcs(_loc50_,_loc49_,1,_loc4_,_loc2_);
      drawSphericalArc(_loc34_,_loc36_,_loc20_,_loc17_,1,_loc4_,_loc21_);
      drawSphericalArc(_loc34_,_loc36_,_loc20_,_loc17_,-1,_loc2_,_loc18_);
      drawPerimeterArcs(_loc51_,_loc52_,1,_loc4_,_loc2_);
      drawSphericalArc(_loc37_,_loc35_,_loc24_,_loc23_,-1,_loc4_,_loc21_);
      drawSphericalArc(_loc37_,_loc35_,_loc24_,_loc23_,1,_loc2_,_loc18_);
   }
   else if(_loc33_ == 0 && _loc32_ == 1)
   {
      _loc4_.moveTo(_loc5_,_loc6_);
      _loc2_.moveTo(_loc5_,_loc6_);
      _loc21_.moveTo(_loc5_,_loc6_);
      _loc18_.moveTo(_loc5_,_loc6_);
      drawSphericalArc(_loc35_,_loc37_,_loc24_,_loc23_,1,_loc4_,_loc21_);
      drawSphericalArc(_loc35_,_loc37_,_loc24_,_loc23_,-1,_loc2_,_loc18_);
      drawPerimeterArcs(_loc52_,_loc50_,-1,_loc4_,_loc2_);
      if(this._type2 == 0)
      {
         drawSphericalArc(0,0,_loc20_,_loc17_,-1,_loc4_,_loc21_);
      }
   }
   else if(_loc33_ == 0 && _loc32_ == 2)
   {
      _loc4_.moveTo(_loc5_,_loc6_);
      _loc2_.moveTo(_loc5_,_loc6_);
      _loc21_.moveTo(_loc5_,_loc6_);
      _loc18_.moveTo(_loc5_,_loc6_);
      drawSphericalArc(_loc35_,_loc37_,_loc24_,_loc23_,1,_loc4_,_loc21_);
      drawSphericalArc(_loc35_,_loc37_,_loc24_,_loc23_,-1,_loc2_,_loc18_);
      drawPerimeterArcs(_loc52_,_loc50_,-1,_loc4_,_loc2_);
      if(this._type2 == 0)
      {
         drawSphericalArc(0,0,_loc20_,_loc17_,1,_loc2_,_loc18_);
      }
   }
   else if(_loc33_ == 1 && _loc32_ == 0)
   {
      _loc4_.moveTo(_loc5_,_loc6_);
      _loc2_.moveTo(_loc5_,_loc6_);
      _loc21_.moveTo(_loc5_,_loc6_);
      _loc18_.moveTo(_loc5_,_loc6_);
      drawSphericalArc(_loc34_,_loc36_,_loc20_,_loc17_,1,_loc4_,_loc21_);
      drawSphericalArc(_loc34_,_loc36_,_loc20_,_loc17_,-1,_loc2_,_loc18_);
      drawPerimeterArcs(_loc51_,_loc49_,1,_loc4_,_loc2_);
      if(this._type1 == 0)
      {
         drawSphericalArc(0,0,_loc24_,_loc23_,-1,_loc4_,_loc21_);
      }
   }
   else if(_loc33_ == 1 && _loc32_ == 1)
   {
      if(this._type1 == 0)
      {
         drawSphericalArc(0,0,_loc24_,_loc23_,1,_loc4_,_loc21_);
      }
      if(this._type2 == 0)
      {
         drawSphericalArc(0,0,_loc20_,_loc17_,-1,_loc4_,_loc21_);
      }
   }
   else if(_loc33_ == 1 && _loc32_ == 2)
   {
      if(this._type1 == 0)
      {
         drawSphericalArc(0,0,_loc24_,_loc23_,1,_loc4_,_loc21_);
      }
      if(this._type2 == 0)
      {
         drawSphericalArc(0,0,_loc20_,_loc17_,1,_loc2_,_loc18_);
      }
      drawPerimeterArcs(0,0,-1,_loc4_,_loc2_);
   }
   else if(_loc33_ == 2 && _loc32_ == 0)
   {
      _loc4_.moveTo(_loc5_,_loc6_);
      _loc2_.moveTo(_loc5_,_loc6_);
      _loc21_.moveTo(_loc5_,_loc6_);
      _loc18_.moveTo(_loc5_,_loc6_);
      drawSphericalArc(_loc34_,_loc36_,_loc20_,_loc17_,1,_loc4_,_loc21_);
      drawSphericalArc(_loc34_,_loc36_,_loc20_,_loc17_,-1,_loc2_,_loc18_);
      drawPerimeterArcs(_loc51_,_loc49_,1,_loc4_,_loc2_);
      if(this._type1 == 0)
      {
         drawSphericalArc(0,0,_loc24_,_loc23_,1,_loc2_,_loc18_);
      }
   }
   else if(_loc33_ == 2 && _loc32_ == 1)
   {
      if(this._type1 == 0)
      {
         drawSphericalArc(0,0,_loc24_,_loc23_,1,_loc2_,_loc18_);
      }
      if(this._type2 == 0)
      {
         drawSphericalArc(0,0,_loc20_,_loc17_,1,_loc4_,_loc21_);
      }
      drawPerimeterArcs(0,0,1,_loc4_,_loc2_);
   }
   else if(_loc33_ == 2 && _loc32_ == 2)
   {
      if(this._type1 == 0)
      {
         drawSphericalArc(0,0,_loc24_,_loc23_,1,_loc2_,_loc18_);
      }
      if(this._type2 == 0)
      {
         drawSphericalArc(0,0,_loc20_,_loc17_,-1,_loc2_,_loc18_);
      }
   }
   _loc4_.endFill();
   _loc2_.endFill();
};
p.setParameters = function(arg)
{
   if(arg.dec1 != undefined && arg.dec2 != undefined)
   {
      this._sys = 1;
      if(arg.ra != undefined)
      {
         this._beta = 0.2617993877991494 * ((arg.ra % 24 + 24) % 24);
      }
      else
      {
         this._beta = 0;
      }
      if(arg.tilt != undefined)
      {
         if(arg.tilt < 0)
         {
            this._tilt = 0;
         }
         else if(arg.tilt > 180)
         {
            this._tilt = 3.141592653589793;
         }
         else
         {
            this._tilt = arg.tilt * 0.017453292519943295;
         }
      }
      else
      {
         this._tilt = 0;
      }
      if(arg.dec1 <= -90)
      {
         this._lambda1 = -1.5707963267948966;
         this._type1 = 1;
      }
      else if(arg.dec1 >= 90)
      {
         this._lambda1 = 1.5707963267948966;
         this._type1 = 1;
      }
      else
      {
         this._lambda1 = arg.dec1 * 0.017453292519943295;
         this._type1 = 0;
      }
      if(arg.dec2 <= -90)
      {
         this._lambda2 = -1.5707963267948966;
         this._type2 = 1;
      }
      else if(arg.dec2 >= 90)
      {
         this._lambda2 = 1.5707963267948966;
         this._type2 = 1;
      }
      else
      {
         this._lambda2 = arg.dec2 * 0.017453292519943295;
         this._type2 = 0;
      }
      this._noDef = false;
   }
   else if(arg.alt1 != undefined && arg.alt2 != undefined)
   {
      this._sys = 0;
      if(arg.az != undefined)
      {
         this._beta = 0.017453292519943295 * (((- arg.az) % 360 + 360) % 360);
      }
      else
      {
         this._beta = 0;
      }
      if(arg.tilt != undefined)
      {
         if(arg.tilt < 0)
         {
            this._tilt = 0;
         }
         else if(arg.tilt > 180)
         {
            this._tilt = 3.141592653589793;
         }
         else
         {
            this._tilt = arg.tilt * 0.017453292519943295;
         }
      }
      else
      {
         this._tilt = 0;
      }
      if(arg.alt1 <= -90)
      {
         this._lambda1 = -1.5707963267948966;
         this._type1 = 1;
      }
      else if(arg.alt1 >= 90)
      {
         this._lambda1 = 1.5707963267948966;
         this._type1 = 1;
      }
      else
      {
         this._lambda1 = arg.alt1 * 0.017453292519943295;
         this._type1 = 0;
      }
      if(arg.alt2 <= -90)
      {
         this._lambda2 = -1.5707963267948966;
         this._type2 = 1;
      }
      else if(arg.alt2 >= 90)
      {
         this._lambda2 = 1.5707963267948966;
         this._type2 = 1;
      }
      else
      {
         this._lambda2 = arg.alt2 * 0.017453292519943295;
         this._type2 = 0;
      }
      this._noDef = false;
   }
   else
   {
      this._noDef = true;
   }
   var _loc3_;
   if(this._lambda1 > this._lambda2)
   {
      _loc3_ = this._lambda2;
      this._lambda2 = this._lambda1;
      this._lambda1 = _loc3_;
      _loc3_ = this._type2;
      this._type2 = this._type1;
      this._type1 = _loc3_;
   }
   this.doK();
};
p.doK = function()
{
   var _loc3_ = Math.sin(this._tilt);
   var _loc4_ = Math.cos(this._tilt);
   var _loc5_ = Math.sin(this._beta);
   var _loc6_ = Math.cos(this._beta);
   var _loc2_ = this._c;
   _loc2_.k0 = _loc6_;
   _loc2_.k1 = (- _loc5_) * _loc4_;
   _loc2_.k2 = _loc5_ * _loc3_;
   _loc2_.k3 = _loc5_;
   _loc2_.k4 = _loc6_ * _loc4_;
   _loc2_.k5 = (- _loc6_) * _loc3_;
   _loc2_.k7 = _loc3_;
   _loc2_.k8 = _loc4_;
   this._kVer = this._kVer + 1;
};
p.setLinkageNames = function(linkageNameFront, linkageNameBack, surface, hemisphere, initObject)
{
   this._frontMC.removeMovieClip();
   this._backMC.removeMovieClip();
   if(typeof initObject != "object")
   {
      this._initObject = {};
      this._initObject._sphere = this._parent;
      this._initObject._shadedBand = this;
   }
   else
   {
      this._initObject = initObject;
      this._initObject._sphere = this._parent;
      this._initObject._shadedBand = this;
   }
   var _loc3_ = "";
   if(surface == "inner")
   {
      _loc3_ += "I";
   }
   else
   {
      _loc3_ += "O";
   }
   _loc3_ += "S";
   if(hemisphere == "below")
   {
      _loc3_ += "B";
   }
   else if(hemisphere == "above")
   {
      _loc3_ += "A";
   }
   else
   {
      _loc3_ += "F";
   }
   var _loc4_;
   var _loc2_;
   if(linkageNameFront != null)
   {
      this._initObject._side = "front";
      _loc4_ = this._parent["_f" + _loc3_];
      _loc2_ = 0;
      while(_loc4_["_" + _loc2_] != undefined)
      {
         _loc2_ = _loc2_ + 1;
      }
      this._frontMC = _loc4_.createEmptyMovieClip("_" + _loc2_,_loc2_);
      this._frontMC.attachMovie(linkageNameFront,"clipMC",0,this._initObject);
      this._frontMaskMC = this._frontMC.createEmptyMovieClip("maskMC",1);
      this._frontBorderMC = this._frontMC.createEmptyMovieClip("borderMC",2);
      this._frontMC.clipMC.setMask(this._frontMC.maskMC);
   }
   else
   {
      this._frontMaskMC = null;
   }
   if(linkageNameBack != null)
   {
      this._initObject._side = "back";
      _loc4_ = this._parent["_b" + _loc3_];
      _loc2_ = 0;
      while(_loc4_["_" + _loc2_] != undefined)
      {
         _loc2_ = _loc2_ + 1;
      }
      this._backMC = _loc4_.createEmptyMovieClip("_" + _loc2_,_loc2_);
      this._backMC.attachMovie(linkageNameBack,"clipMC",0,this._initObject);
      this._backMaskMC = this._backMC.createEmptyMovieClip("maskMC",1);
      this._backBorderMC = this._backMC.createEmptyMovieClip("borderMC",2);
      this._backMC.clipMC.setMask(this._backMC.maskMC);
   }
   else
   {
      this._backMaskMC = null;
   }
   this._backMC.borderMC._visible = this._showBorder;
   this._frontMC.borderMC._visible = this._showBorder;
};
p.toString = function()
{
   return String(this._parent) + "." + this._name + " (shaded band)";
};
p.remove = function()
{
   var _loc3_ = this._parent._shadedBandList;
   var _loc2_ = 0;
   while(_loc2_ < _loc3_.length)
   {
      if(_loc3_[_loc2_].id == this._id)
      {
         break;
      }
      _loc2_ = _loc2_ + 1;
   }
   _loc3_.splice(_loc2_,1);
   this._backMC.removeMovieClip();
   this._frontMC.removeMovieClip();
   delete this._parent[this._name];
};
p.setBorderStyle = function(t, c, a)
{
   if(t != undefined)
   {
      this._bThick = t;
   }
   if(c != undefined)
   {
      this._bColor = c;
   }
   if(a != undefined)
   {
      this._bAlpha = a;
   }
};
p.getShowBorder = function()
{
   return this._showBorder;
};
p.setShowBorder = function(arg)
{
   this._showBorder = Boolean(arg);
   this._backMC.borderMC._visible = this._showBorder;
   this._frontMC.borderMC._visible = this._showBorder;
};
p.addProperty("showBorder",p.getShowBorder,p.setShowBorder);
p.getVisible = function()
{
   return this._visible;
};
p.setVisible = function(arg)
{
   this._visible = Boolean(arg);
   this.update();
};
p.addProperty("visible",p.getVisible,p.setVisible);
