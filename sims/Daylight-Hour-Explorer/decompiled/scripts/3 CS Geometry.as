var p = CelestialSphereClass.prototype;
p.screenToHorizon = function(sp, hp)
{
   this.StoMH(sp,hp);
   hp.az = (360 - hp.az * 57.29577951308232) % 360;
   hp.alt *= 57.29577951308232;
};
p.screenToCelestial = function(sp, cp)
{
   var _loc3_ = new Object();
   this.StoMH(sp,_loc3_);
   this.MHtoC(_loc3_,cp);
   cp.ra *= 3.819718634205488;
   cp.dec *= 57.29577951308232;
};
p.toScreen = function(up, sp)
{
   var _loc2_ = new Object();
   this.parsePointInput(up,_loc2_);
   if(_loc2_.sys == 0 || _loc2_.sys == -1)
   {
      this.WtoSz(_loc2_,sp);
   }
   else if(_loc2_.sys == 1)
   {
      this.CtoSz(_loc2_,sp);
   }
   else
   {
      sp.x = null;
      sp.y = null;
      sp.z = null;
   }
};
p.pointToHorizon = function(up, hp)
{
   var _loc2_ = {};
   this.parsePointInput(up,_loc2_);
   var _loc4_;
   var _loc5_;
   if(_loc2_.sys == 0 || _loc2_.sys == -1)
   {
      _loc4_ = _loc2_.z / _loc2_.r;
      if(_loc4_ < -1)
      {
         _loc4_ = -1;
      }
      else if(_loc4_ > 1)
      {
         _loc4_ = 1;
      }
      hp.az = this.mod(-57.29577951308232 * Math.atan2(_loc2_.y,_loc2_.x),360);
      hp.alt = 57.29577951308232 * Math.asin(_loc4_);
      hp.r = _loc2_.r;
   }
   else if(_loc2_.sys == 1)
   {
      _loc5_ = {};
      this.CtoW(_loc2_,_loc5_);
      _loc4_ = _loc5_.z / _loc2_.r;
      if(_loc4_ < -1)
      {
         _loc4_ = -1;
      }
      else if(_loc4_ > 1)
      {
         _loc4_ = 1;
      }
      hp.az = this.mod(-57.29577951308232 * Math.atan2(_loc5_.y,_loc5_.x),360);
      hp.alt = 57.29577951308232 * Math.asin(_loc4_);
      hp.r = _loc2_.r;
   }
   else
   {
      hp.az = null;
      hp.alt = null;
      hp.r = null;
   }
};
p.pointToCelestial = function(up, cp)
{
   var _loc2_ = {};
   this.parsePointInput(up,_loc2_);
   var _loc5_;
   var _loc4_;
   if(_loc2_.sys == 0 || _loc2_.sys == -1)
   {
      _loc5_ = {};
      this.WtoC(_loc2_,_loc5_);
      _loc4_ = _loc5_.z / _loc2_.r;
      if(_loc4_ > 1)
      {
         _loc4_ = 1;
      }
      else if(_loc4_ < -1)
      {
         _loc4_ = -1;
      }
      cp.ra = this.mod(3.819718634205488 * Math.atan2(_loc5_.y,_loc5_.x),24);
      cp.dec = 57.29577951308232 * Math.asin(_loc4_);
      cp.r = _loc2_.r;
   }
   else if(_loc2_.sys == 1)
   {
      _loc4_ = _loc2_.z / _loc2_.r;
      if(_loc4_ > 1)
      {
         _loc4_ = 1;
      }
      else if(_loc4_ < -1)
      {
         _loc4_ = -1;
      }
      cp.ra = this.mod(3.819718634205488 * Math.atan2(_loc2_.y,_loc2_.x),24);
      cp.dec = 57.29577951308232 * Math.asin(_loc4_);
      cp.r = _loc2_.r;
   }
   else
   {
      cp.ra = null;
      cp.dec = null;
      cp.r = null;
   }
};
p.parsePointInput = function(p1, p2)
{
   var _loc3_;
   var _loc4_;
   if(p1.az != undefined && p1.alt != undefined)
   {
      p2.sys = 0;
      p2.system = "horizon";
      _loc3_ = 1;
      if(p1.r != undefined)
      {
         _loc3_ = p1.r;
      }
      _loc4_ = _loc3_ * Math.cos(p1.alt * 0.017453292519943295);
      p2.x = _loc4_ * Math.cos(p1.az * 0.017453292519943295);
      p2.y = _loc4_ * Math.sin((- p1.az) * 0.017453292519943295);
      p2.z = _loc3_ * Math.sin(p1.alt * 0.017453292519943295);
      p2.r = Math.abs(_loc3_);
   }
   else if(p1.ra != undefined && p1.dec != undefined)
   {
      p2.sys = 1;
      p2.system = "celestial";
      _loc3_ = 1;
      if(p1.r != undefined)
      {
         _loc3_ = p1.r;
      }
      _loc4_ = _loc3_ * Math.cos(p1.dec * 0.017453292519943295);
      p2.x = _loc4_ * Math.cos(p1.ra * 0.2617993877991494);
      p2.y = _loc4_ * Math.sin(p1.ra * 0.2617993877991494);
      p2.z = _loc3_ * Math.sin(p1.dec * 0.017453292519943295);
      p2.r = Math.abs(_loc3_);
   }
   else if(p1.x != undefined && p1.y != undefined && p1.z != undefined)
   {
      if(p1.system == "horizon")
      {
         p2.sys = 0;
         p2.system = "horizon";
      }
      else if(p1.system == "celestial")
      {
         p2.sys = 1;
         p2.system = "celestial";
      }
      else
      {
         p2.sys = -1;
         p2.system = "unknown";
      }
      p2.x = p1.x;
      p2.y = p1.y;
      p2.z = p1.z;
      p2.r = Math.sqrt(p2.x * p2.x + p2.y * p2.y + p2.z * p2.z);
      if(p2.r < 1.000001 && p2.r > 0.999999)
      {
         p2.r = 1;
      }
   }
   else
   {
      p2.sys = null;
      p2.system = null;
      p2.x = null;
      p2.y = null;
      p2.z = null;
      p2.r = null;
   }
};
p.WtoS = function(p, sp)
{
   var _loc2_ = this._c;
   sp.x = p.x * _loc2_.a0 + p.y * _loc2_.a1;
   sp.y = p.x * _loc2_.a3 + p.y * _loc2_.a4 + p.z * _loc2_.a5;
};
p.WtoSz = function(p, sp)
{
   var _loc2_ = this._c;
   sp.x = p.x * _loc2_.a0 + p.y * _loc2_.a1;
   sp.y = p.x * _loc2_.a3 + p.y * _loc2_.a4 + p.z * _loc2_.a5;
   sp.z = p.x * _loc2_.a6 + p.y * _loc2_.a7 + p.z * _loc2_.a8;
};
p.CtoS = function(p, sp)
{
   var _loc2_ = this._c;
   sp.x = p.x * _loc2_.b0 + p.y * _loc2_.b1 + p.z * _loc2_.b2;
   sp.y = p.x * _loc2_.b3 + p.y * _loc2_.b4 + p.z * _loc2_.b5;
};
p.CtoSz = function(p, sp)
{
   var _loc2_ = this._c;
   sp.x = p.x * _loc2_.b0 + p.y * _loc2_.b1 + p.z * _loc2_.b2;
   sp.y = p.x * _loc2_.b3 + p.y * _loc2_.b4 + p.z * _loc2_.b5;
   sp.z = p.x * _loc2_.b6 + p.y * _loc2_.b7 + p.z * _loc2_.b8;
};
p.CtoW = function(p, wp)
{
   var _loc2_ = this._c;
   wp.x = p.x * _loc2_.m0 + p.y * _loc2_.m1 + p.z * _loc2_.m2;
   wp.y = p.x * _loc2_.m3 + p.y * _loc2_.m4;
   wp.z = p.x * _loc2_.m6 + p.y * _loc2_.m7 + p.z * _loc2_.m8;
};
p.WtoC = function(p, cp)
{
   var _loc2_ = this._c;
   cp.x = p.x * _loc2_.m0 + p.y * _loc2_.m3 + p.z * _loc2_.m6;
   cp.y = p.x * _loc2_.m1 + p.y * _loc2_.m4 + p.z * _loc2_.m7;
   cp.z = p.x * _loc2_.m2 + p.z * _loc2_.m8;
};
p.CtoMH = function(cp, hp)
{
   var _loc6_ = Math.sin(cp.dec);
   var _loc2_ = Math.cos(cp.dec);
   var _loc3_ = Math.sin(this._lat);
   var _loc4_ = Math.cos(this._lat);
   var _loc8_ = this._sTime - cp.ra;
   var _loc5_ = Math.cos(_loc8_);
   var _loc7_ = _loc6_ * _loc4_ - _loc2_ * _loc5_ * _loc3_;
   var _loc11_ = _loc2_ * Math.sin(_loc8_);
   if(_loc7_ == 0)
   {
      hp.az = 0;
   }
   else
   {
      hp.az = this.mod(Math.atan2(_loc11_,_loc7_),6.283185307179586);
   }
   hp.alt = Math.asin(_loc6_ * _loc3_ + _loc2_ * _loc5_ * _loc4_);
};
p.MHtoC = function(hp, cp)
{
   var _loc8_ = Math.sin(hp.alt);
   var _loc2_ = Math.cos(hp.alt);
   var _loc11_ = Math.sin(hp.az);
   var _loc7_ = Math.cos(hp.az);
   var _loc3_ = Math.sin(this._lat);
   var _loc4_ = Math.cos(this._lat);
   var _loc9_ = _loc2_ * _loc11_;
   var _loc5_ = _loc8_ * _loc4_ - _loc2_ * _loc3_ * _loc7_;
   if(_loc5_ == 0)
   {
      cp.ra = 0;
   }
   else
   {
      cp.ra = this.mod(this._sTime - Math.atan2(_loc9_,_loc5_),6.283185307179586);
   }
   cp.dec = Math.asin(_loc8_ * _loc3_ + _loc2_ * _loc7_ * _loc4_);
};
p.StoMH = function(sp, hp)
{
   var _loc2_ = Math;
   var _loc7_ = _loc2_.sqrt(sp.x * sp.x + sp.y * sp.y) / this._c.r;
   if(_loc7_ > 1)
   {
      _loc7_ = 1;
   }
   var _loc4_ = _loc2_.asin(_loc7_);
   var _loc5_ = _loc2_.atan2(sp.x,- sp.y);
   var _loc8_;
   var _loc10_;
   var _loc9_;
   var _loc12_;
   var _loc11_;
   var _loc13_;
   if(this._phi == 1.5707963267948966)
   {
      hp.alt = 1.5707963267948966 - _loc4_;
      hp.az = this._theta + 3.141592653589793 - _loc5_;
   }
   else if(this._phi == -1.5707963267948966)
   {
      hp.alt = -1.5707963267948966 + _loc4_;
      hp.az = this._theta + _loc5_;
   }
   else
   {
      _loc8_ = 1.5707963267948966 - this._phi;
      _loc10_ = _loc2_.cos(_loc8_);
      _loc9_ = _loc2_.sin(_loc8_);
      _loc12_ = _loc2_.cos(_loc4_);
      _loc11_ = _loc2_.sin(_loc4_);
      _loc13_ = _loc12_ * _loc10_ + _loc11_ * _loc9_ * _loc2_.cos(_loc5_);
      hp.alt = 1.5707963267948966 - _loc2_.acos(_loc13_);
      hp.az = this._theta + _loc2_.atan2(_loc11_ * _loc2_.sin(_loc5_),(_loc12_ - _loc13_ * _loc10_) / _loc9_);
   }
   hp.az = this.mod(hp.az,6.283185307179586);
};
p.doA = function()
{
   var _loc2_ = this._c;
   var _loc4_ = Math.cos(this._theta);
   var _loc3_ = Math.sin(this._theta);
   var _loc6_ = Math.cos(this._phi);
   var _loc5_ = Math.sin(this._phi);
   _loc2_.a0 = (- _loc2_.r) * _loc3_;
   _loc2_.a1 = _loc2_.r * _loc4_;
   _loc2_.a3 = _loc2_.r * _loc4_ * _loc5_;
   _loc2_.a4 = _loc2_.r * _loc3_ * _loc5_;
   _loc2_.a5 = (- _loc2_.r) * _loc6_;
   _loc2_.a6 = _loc2_.r * _loc4_ * _loc6_;
   _loc2_.a7 = _loc2_.r * _loc3_ * _loc6_;
   _loc2_.a8 = _loc2_.r * _loc5_;
   this._aVer = this._aVer + 1;
};
p.doM = function()
{
   var _loc2_ = this._c;
   _loc2_.m2 = Math.cos(this._lat);
   _loc2_.m3 = Math.sin(this._sTime);
   _loc2_.m4 = - Math.cos(this._sTime);
   _loc2_.m8 = Math.sin(this._lat);
   _loc2_.m0 = _loc2_.m4 * _loc2_.m8;
   _loc2_.m1 = (- _loc2_.m3) * _loc2_.m8;
   _loc2_.m6 = (- _loc2_.m2) * _loc2_.m4;
   _loc2_.m7 = _loc2_.m2 * _loc2_.m3;
};
p.doB = function()
{
   var _loc2_ = this._c;
   _loc2_.b0 = _loc2_.a0 * _loc2_.m0 + _loc2_.a1 * _loc2_.m3;
   _loc2_.b1 = _loc2_.a0 * _loc2_.m1 + _loc2_.a1 * _loc2_.m4;
   _loc2_.b2 = _loc2_.a0 * _loc2_.m2;
   _loc2_.b3 = _loc2_.a3 * _loc2_.m0 + _loc2_.a4 * _loc2_.m3 + _loc2_.a5 * _loc2_.m6;
   _loc2_.b4 = _loc2_.a3 * _loc2_.m1 + _loc2_.a4 * _loc2_.m4 + _loc2_.a5 * _loc2_.m7;
   _loc2_.b5 = _loc2_.a3 * _loc2_.m2 + _loc2_.a5 * _loc2_.m8;
   _loc2_.b6 = _loc2_.a6 * _loc2_.m0 + _loc2_.a7 * _loc2_.m3 + _loc2_.a8 * _loc2_.m6;
   _loc2_.b7 = _loc2_.a6 * _loc2_.m1 + _loc2_.a7 * _loc2_.m4 + _loc2_.a8 * _loc2_.m7;
   _loc2_.b8 = _loc2_.a6 * _loc2_.m2 + _loc2_.a8 * _loc2_.m8;
   this._bVer = this._bVer + 1;
};
