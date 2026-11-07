var p = CelestialSphereClass.prototype;
p.screenToHorizon = function(sp, hp)
{
   var _loc1_ = hp;
   this.StoMH(sp,_loc1_);
   _loc1_.az = (360 - _loc1_.az * 57.29577951308232) % 360;
   _loc1_.alt *= 57.29577951308232;
};
p.screenToCelestial = function(sp, cp)
{
   var _loc1_ = cp;
   var _loc2_ = new Object();
   this.StoMH(sp,_loc2_);
   this.MHtoC(_loc2_,_loc1_);
   _loc1_.ra *= 3.819718634205488;
   _loc1_.dec *= 57.29577951308232;
};
p.toScreen = function(up, sp)
{
   var _loc2_ = sp;
   var _loc3_ = this;
   var _loc1_ = new Object();
   _loc3_.parsePointInput(up,_loc1_);
   if(_loc1_.sys == 0 || _loc1_.sys == -1)
   {
      _loc3_.WtoSz(_loc1_,_loc2_);
   }
   else if(_loc1_.sys == 1)
   {
      _loc3_.CtoSz(_loc1_,_loc2_);
   }
   else
   {
      _loc2_.x = null;
      _loc2_.y = null;
      _loc2_.z = null;
   }
};
p.pointToHorizon = function(up, hp)
{
   var _loc2_ = hp;
   var _loc1_ = {};
   this.parsePointInput(up,_loc1_);
   var _loc3_;
   if(_loc1_.sys == 0 || _loc1_.sys == -1)
   {
      _loc3_ = _loc1_.z / _loc1_.r;
      if(_loc3_ < -1)
      {
         _loc3_ = -1;
      }
      else if(_loc3_ > 1)
      {
         _loc3_ = 1;
      }
      _loc2_.az = this.mod(-57.29577951308232 * Math.atan2(_loc1_.y,_loc1_.x),360);
      _loc2_.alt = 57.29577951308232 * Math.asin(_loc3_);
      _loc2_.r = _loc1_.r;
   }
   else if(_loc1_.sys == 1)
   {
      var hpt = {};
      this.CtoW(_loc1_,hpt);
      _loc3_ = hpt.z / _loc1_.r;
      if(_loc3_ < -1)
      {
         _loc3_ = -1;
      }
      else if(_loc3_ > 1)
      {
         _loc3_ = 1;
      }
      _loc2_.az = this.mod(-57.29577951308232 * Math.atan2(hpt.y,hpt.x),360);
      _loc2_.alt = 57.29577951308232 * Math.asin(_loc3_);
      _loc2_.r = _loc1_.r;
   }
   else
   {
      _loc2_.az = null;
      _loc2_.alt = null;
      _loc2_.r = null;
   }
};
p.pointToCelestial = function(up, cp)
{
   var _loc2_ = cp;
   var _loc1_ = {};
   this.parsePointInput(up,_loc1_);
   var _loc3_;
   if(_loc1_.sys == 0 || _loc1_.sys == -1)
   {
      var cpt = {};
      this.WtoC(_loc1_,cpt);
      _loc3_ = cpt.z / _loc1_.r;
      if(_loc3_ > 1)
      {
         _loc3_ = 1;
      }
      else if(_loc3_ < -1)
      {
         _loc3_ = -1;
      }
      _loc2_.ra = this.mod(3.819718634205488 * Math.atan2(cpt.y,cpt.x),24);
      _loc2_.dec = 57.29577951308232 * Math.asin(_loc3_);
      _loc2_.r = _loc1_.r;
   }
   else if(_loc1_.sys == 1)
   {
      _loc3_ = _loc1_.z / _loc1_.r;
      if(_loc3_ > 1)
      {
         _loc3_ = 1;
      }
      else if(_loc3_ < -1)
      {
         _loc3_ = -1;
      }
      _loc2_.ra = this.mod(3.819718634205488 * Math.atan2(_loc1_.y,_loc1_.x),24);
      _loc2_.dec = 57.29577951308232 * Math.asin(_loc3_);
      _loc2_.r = _loc1_.r;
   }
   else
   {
      _loc2_.ra = null;
      _loc2_.dec = null;
      _loc2_.r = null;
   }
};
p.parsePointInput = function(p1, p2)
{
   var _loc1_ = p2;
   var _loc2_ = p1;
   var _loc3_;
   if(_loc2_.az != undefined && _loc2_.alt != undefined)
   {
      _loc1_.sys = 0;
      _loc1_.system = "horizon";
      _loc3_ = 1;
      if(_loc2_.r != undefined)
      {
         _loc3_ = _loc2_.r;
      }
      var d = _loc3_ * Math.cos(_loc2_.alt * 0.017453292519943295);
      _loc1_.x = d * Math.cos(_loc2_.az * 0.017453292519943295);
      _loc1_.y = d * Math.sin((- _loc2_.az) * 0.017453292519943295);
      _loc1_.z = _loc3_ * Math.sin(_loc2_.alt * 0.017453292519943295);
      _loc1_.r = Math.abs(_loc3_);
   }
   else if(_loc2_.ra != undefined && _loc2_.dec != undefined)
   {
      _loc1_.sys = 1;
      _loc1_.system = "celestial";
      _loc3_ = 1;
      if(_loc2_.r != undefined)
      {
         _loc3_ = _loc2_.r;
      }
      var d = _loc3_ * Math.cos(_loc2_.dec * 0.017453292519943295);
      _loc1_.x = d * Math.cos(_loc2_.ra * 0.2617993877991494);
      _loc1_.y = d * Math.sin(_loc2_.ra * 0.2617993877991494);
      _loc1_.z = _loc3_ * Math.sin(_loc2_.dec * 0.017453292519943295);
      _loc1_.r = Math.abs(_loc3_);
   }
   else if(_loc2_.x != undefined && _loc2_.y != undefined && _loc2_.z != undefined)
   {
      if(_loc2_.system == "horizon")
      {
         _loc1_.sys = 0;
         _loc1_.system = "horizon";
      }
      else if(_loc2_.system == "celestial")
      {
         _loc1_.sys = 1;
         _loc1_.system = "celestial";
      }
      else
      {
         _loc1_.sys = -1;
         _loc1_.system = "unknown";
      }
      _loc1_.x = _loc2_.x;
      _loc1_.y = _loc2_.y;
      _loc1_.z = _loc2_.z;
      _loc1_.r = Math.sqrt(_loc1_.x * _loc1_.x + _loc1_.y * _loc1_.y + _loc1_.z * _loc1_.z);
      if(_loc1_.r < 1.000001 && _loc1_.r > 0.999999)
      {
         _loc1_.r = 1;
      }
   }
   else
   {
      _loc1_.sys = null;
      _loc1_.system = null;
      _loc1_.x = null;
      _loc1_.y = null;
      _loc1_.z = null;
      _loc1_.r = null;
   }
};
p.WtoS = function(p, sp)
{
   var _loc2_ = p;
   var _loc1_ = this._c;
   sp.x = _loc2_.x * _loc1_.a0 + _loc2_.y * _loc1_.a1;
   sp.y = _loc2_.x * _loc1_.a3 + _loc2_.y * _loc1_.a4 + _loc2_.z * _loc1_.a5;
};
p.WtoSz = function(p, sp)
{
   var _loc2_ = p;
   var _loc3_ = sp;
   var _loc1_ = this._c;
   _loc3_.x = _loc2_.x * _loc1_.a0 + _loc2_.y * _loc1_.a1;
   _loc3_.y = _loc2_.x * _loc1_.a3 + _loc2_.y * _loc1_.a4 + _loc2_.z * _loc1_.a5;
   _loc3_.z = _loc2_.x * _loc1_.a6 + _loc2_.y * _loc1_.a7 + _loc2_.z * _loc1_.a8;
};
p.CtoS = function(p, sp)
{
   var _loc2_ = p;
   var _loc1_ = this._c;
   sp.x = _loc2_.x * _loc1_.b0 + _loc2_.y * _loc1_.b1 + _loc2_.z * _loc1_.b2;
   sp.y = _loc2_.x * _loc1_.b3 + _loc2_.y * _loc1_.b4 + _loc2_.z * _loc1_.b5;
};
p.CtoSz = function(p, sp)
{
   var _loc2_ = p;
   var _loc3_ = sp;
   var _loc1_ = this._c;
   _loc3_.x = _loc2_.x * _loc1_.b0 + _loc2_.y * _loc1_.b1 + _loc2_.z * _loc1_.b2;
   _loc3_.y = _loc2_.x * _loc1_.b3 + _loc2_.y * _loc1_.b4 + _loc2_.z * _loc1_.b5;
   _loc3_.z = _loc2_.x * _loc1_.b6 + _loc2_.y * _loc1_.b7 + _loc2_.z * _loc1_.b8;
};
p.CtoW = function(p, wp)
{
   var _loc2_ = p;
   var _loc3_ = wp;
   var _loc1_ = this._c;
   _loc3_.x = _loc2_.x * _loc1_.m0 + _loc2_.y * _loc1_.m1 + _loc2_.z * _loc1_.m2;
   _loc3_.y = _loc2_.x * _loc1_.m3 + _loc2_.y * _loc1_.m4;
   _loc3_.z = _loc2_.x * _loc1_.m6 + _loc2_.y * _loc1_.m7 + _loc2_.z * _loc1_.m8;
};
p.WtoC = function(p, cp)
{
   var _loc2_ = p;
   var _loc3_ = cp;
   var _loc1_ = this._c;
   _loc3_.x = _loc2_.x * _loc1_.m0 + _loc2_.y * _loc1_.m3 + _loc2_.z * _loc1_.m6;
   _loc3_.y = _loc2_.x * _loc1_.m1 + _loc2_.y * _loc1_.m4 + _loc2_.z * _loc1_.m7;
   _loc3_.z = _loc2_.x * _loc1_.m2 + _loc2_.z * _loc1_.m8;
};
p.CtoMH = function(cp, hp)
{
   var sd = Math.sin(cp.dec);
   var _loc1_ = Math.cos(cp.dec);
   var _loc2_ = Math.sin(this._lat);
   var _loc3_ = Math.cos(this._lat);
   var h = this._sTime - cp.ra;
   var ch = Math.cos(h);
   var caz = sd * _loc3_ - _loc1_ * ch * _loc2_;
   var saz = _loc1_ * Math.sin(h);
   if(caz == 0)
   {
      hp.az = 0;
   }
   else
   {
      hp.az = this.mod(Math.atan2(saz,caz),6.283185307179586);
   }
   hp.alt = Math.asin(sd * _loc2_ + _loc1_ * ch * _loc3_);
};
p.MHtoC = function(hp, cp)
{
   var salt = Math.sin(hp.alt);
   var _loc1_ = Math.cos(hp.alt);
   var saz = Math.sin(hp.az);
   var caz = Math.cos(hp.az);
   var _loc2_ = Math.sin(this._lat);
   var _loc3_ = Math.cos(this._lat);
   var sh = _loc1_ * saz;
   var ch = salt * _loc3_ - _loc1_ * _loc2_ * caz;
   if(ch == 0)
   {
      cp.ra = 0;
   }
   else
   {
      cp.ra = this.mod(this._sTime - Math.atan2(sh,ch),6.283185307179586);
   }
   cp.dec = Math.asin(salt * _loc2_ + _loc1_ * caz * _loc3_);
};
p.StoMH = function(sp, hp)
{
   var _loc2_ = hp;
   var _loc3_ = this;
   var _loc1_ = Math;
   var d = _loc1_.sqrt(sp.x * sp.x + sp.y * sp.y) / _loc3_._c.r;
   if(d > 1)
   {
      d = 1;
   }
   var b = _loc1_.asin(d);
   var A = _loc1_.atan2(sp.x,- sp.y);
   if(_loc3_._phi == 1.5707963267948966)
   {
      _loc2_.alt = 1.5707963267948966 - b;
      _loc2_.az = _loc3_._theta + 3.141592653589793 - A;
   }
   else if(_loc3_._phi == -1.5707963267948966)
   {
      _loc2_.alt = -1.5707963267948966 + b;
      _loc2_.az = _loc3_._theta + A;
   }
   else
   {
      var c = 1.5707963267948966 - _loc3_._phi;
      var cc = _loc1_.cos(c);
      var sc = _loc1_.sin(c);
      var cb = _loc1_.cos(b);
      var sb = _loc1_.sin(b);
      var ca = cb * cc + sb * sc * _loc1_.cos(A);
      _loc2_.alt = 1.5707963267948966 - _loc1_.acos(ca);
      _loc2_.az = _loc3_._theta + _loc1_.atan2(sb * _loc1_.sin(A),(cb - ca * cc) / sc);
   }
   _loc2_.az = _loc3_.mod(_loc2_.az,6.283185307179586);
};
p.doA = function()
{
   var _loc2_ = this;
   var _loc1_ = _loc2_._c;
   var ct = Math.cos(_loc2_._theta);
   var _loc3_ = Math.sin(_loc2_._theta);
   var cp = Math.cos(_loc2_._phi);
   var sp = Math.sin(_loc2_._phi);
   _loc1_.a0 = (- _loc1_.r) * _loc3_;
   _loc1_.a1 = _loc1_.r * ct;
   _loc1_.a3 = _loc1_.r * ct * sp;
   _loc1_.a4 = _loc1_.r * _loc3_ * sp;
   _loc1_.a5 = (- _loc1_.r) * cp;
   _loc1_.a6 = _loc1_.r * ct * cp;
   _loc1_.a7 = _loc1_.r * _loc3_ * cp;
   _loc1_.a8 = _loc1_.r * sp;
   _loc2_._aVer = _loc2_._aVer + 1;
};
p.doM = function()
{
   var _loc2_ = this;
   var _loc1_ = _loc2_._c;
   _loc1_.m2 = Math.cos(_loc2_._lat);
   _loc1_.m3 = Math.sin(_loc2_._sTime);
   _loc1_.m4 = - Math.cos(_loc2_._sTime);
   _loc1_.m8 = Math.sin(_loc2_._lat);
   _loc1_.m0 = _loc1_.m4 * _loc1_.m8;
   _loc1_.m1 = (- _loc1_.m3) * _loc1_.m8;
   _loc1_.m6 = (- _loc1_.m2) * _loc1_.m4;
   _loc1_.m7 = _loc1_.m2 * _loc1_.m3;
};
p.doB = function()
{
   var _loc1_ = this._c;
   _loc1_.b0 = _loc1_.a0 * _loc1_.m0 + _loc1_.a1 * _loc1_.m3;
   _loc1_.b1 = _loc1_.a0 * _loc1_.m1 + _loc1_.a1 * _loc1_.m4;
   _loc1_.b2 = _loc1_.a0 * _loc1_.m2;
   _loc1_.b3 = _loc1_.a3 * _loc1_.m0 + _loc1_.a4 * _loc1_.m3 + _loc1_.a5 * _loc1_.m6;
   _loc1_.b4 = _loc1_.a3 * _loc1_.m1 + _loc1_.a4 * _loc1_.m4 + _loc1_.a5 * _loc1_.m7;
   _loc1_.b5 = _loc1_.a3 * _loc1_.m2 + _loc1_.a5 * _loc1_.m8;
   _loc1_.b6 = _loc1_.a6 * _loc1_.m0 + _loc1_.a7 * _loc1_.m3 + _loc1_.a8 * _loc1_.m6;
   _loc1_.b7 = _loc1_.a6 * _loc1_.m1 + _loc1_.a7 * _loc1_.m4 + _loc1_.a8 * _loc1_.m7;
   _loc1_.b8 = _loc1_.a6 * _loc1_.m2 + _loc1_.a8 * _loc1_.m8;
   this._bVer++;
};
