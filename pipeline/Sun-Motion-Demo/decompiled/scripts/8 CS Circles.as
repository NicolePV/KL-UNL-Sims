function CSCirclesClass(parent, name, id, depth)
{
   this._parent = parent;
   this._name = name;
   this._id = id;
   this._depth = depth;
   this._c = {};
   this._wVer = -1;
   this._gS = 0;
   this._gE = 0;
   this._beta = 0;
   this._tilt = 0;
   this._lambda = 0;
   this._sys = 0;
   this._visible = true;
   this._useMouseFunctions = false;
   this._color = 16711680;
   this._thick = 1;
   this._alpha = 80;
   this._back = this._parent._bC.createEmptyMovieClip("_" + depth,depth);
   this._front = this._parent._fC.createEmptyMovieClip("_" + depth,depth);
}
var p = CelestialSphereClass.prototype;
p.addCircle = function(name, style, definition, depth)
{
   if(depth == undefined)
   {
      depth = 0;
      while(this._fC["_" + depth] != undefined)
      {
         depth = depth + 1;
      }
   }
   var _loc6_ = this._circleFreeID++;
   this[name] = new CSCirclesClass(this,name,_loc6_,depth);
   this._circleList.push({id:_loc6_,name:this[name]});
   if(typeof style == "object")
   {
      this[name].setStyle(style.thickness,style.color,style.alpha);
   }
   if(typeof definition == "object")
   {
      this[name].setParameters(definition);
   }
   return this[name];
};
p.updateCircles = function(notHorizon)
{
   var _loc4_ = getTimer();
   var _loc2_;
   var _loc3_;
   if(notHorizon)
   {
      _loc2_ = 0;
      while(_loc2_ < this._circleList.length)
      {
         _loc3_ = this._circleList[_loc2_].name;
         if(!_loc3_._sys == 0)
         {
            _loc3_.update();
         }
         _loc2_ = _loc2_ + 1;
      }
   }
   else
   {
      _loc2_ = 0;
      while(_loc2_ < this._circleList.length)
      {
         this._circleList[_loc2_].name.update();
         _loc2_ = _loc2_ + 1;
      }
   }
   if(this._traceOn)
   {
      trace("circles: " + (getTimer() - _loc4_) + " ms");
   }
};
p.showCircles = function()
{
   var _loc3_ = this._circleList;
   var _loc2_ = 0;
   while(_loc2_ < _loc3_.length)
   {
      _loc3_[_loc2_].name.visible = true;
      _loc2_ = _loc2_ + 1;
   }
};
p.hideCircles = function()
{
   var _loc3_ = this._circleList;
   var _loc2_ = 0;
   while(_loc2_ < _loc3_.length)
   {
      _loc3_[_loc2_].name.visible = false;
      _loc2_ = _loc2_ + 1;
   }
};
p.removeCircles = function()
{
   var _loc3_ = this._circleList;
   var _loc2_ = 0;
   while(_loc2_ < _loc3_.length)
   {
      _loc3_[_loc2_].name._back.removeMovieClip();
      _loc3_[_loc2_].name._front.removeMovieClip();
      delete this[_loc3_[_loc2_].name._name];
      _loc2_ = _loc2_ + 1;
   }
   this._circleFreeID = 0;
   this._circleList = [];
};
var p = CSCirclesClass.prototype = new Object();
p._minStep = 0.7853981633974483;
p.toString = function()
{
   return String(this._parent) + "." + this._name + " (circle)";
};
p.remove = function()
{
   var _loc3_ = this._parent._circleList;
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
   this._back.removeMovieClip();
   this._front.removeMovieClip();
   delete this._parent[this._name];
};
p.update = function()
{
   function drawArc(g1, g2, mc)
   {
      if(g2 < g1)
      {
         g2 += 6.283185307179586;
      }
      var _loc14_ = g2 - g1;
      if(_loc14_ == 0)
      {
         _loc14_ = 6.283185307179586;
      }
      var _loc12_ = Math.ceil(_loc14_ / minStep);
      var _loc9_ = _loc14_ / _loc12_;
      var _loc16_ = _loc9_ / 2;
      var _loc8_ = Math.cos;
      var _loc10_ = Math.sin;
      var _loc11_ = 1 / _loc8_(_loc16_);
      var _loc4_ = _loc8_(g1);
      var _loc3_ = _loc10_(g1);
      mc.moveTo(v0 * _loc4_ + v1 * _loc3_ + v2,v3 * _loc4_ + v4 * _loc3_ + v5);
      var _loc6_ = g1 + _loc9_;
      var _loc7_ = _loc6_ - _loc16_;
      var _loc5_ = 0;
      var _loc2_;
      var _loc1_;
      while(_loc5_ < _loc12_)
      {
         _loc4_ = _loc8_(_loc6_);
         _loc3_ = _loc10_(_loc6_);
         _loc2_ = _loc11_ * _loc8_(_loc7_);
         _loc1_ = _loc11_ * _loc10_(_loc7_);
         mc.curveTo(v0 * _loc2_ + v1 * _loc1_ + v2,v3 * _loc2_ + v4 * _loc1_ + v5,v0 * _loc4_ + v1 * _loc3_ + v2,v3 * _loc4_ + v4 * _loc3_ + v5);
         _loc6_ += _loc9_;
         _loc7_ += _loc9_;
         _loc5_ = _loc5_ + 1;
      }
   }
   var _loc21_ = this._front;
   var _loc20_ = this._back;
   _loc21_.clear();
   _loc20_.clear();
   if(!this._visible)
   {
      return undefined;
   }
   _loc21_.lineStyle(this._thick,this._color,this._alpha);
   _loc20_.lineStyle(this._thick,this._color,this._alpha);
   var _loc4_;
   var _loc9_;
   var _loc0_;
   var _loc31_;
   var _loc29_;
   var _loc33_;
   var _loc22_;
   if(this._sys == 0 && (this._wLastVer != this._wVer || this._aLastVer != this._parent._aVer))
   {
      _loc4_ = this._c;
      _loc9_ = this._parent._c;
      var v0 = _loc4_.v0 = _loc9_.a0 * _loc4_.w0 + _loc9_.a1 * _loc4_.w3;
      var v1 = _loc4_.v1 = _loc9_.a0 * _loc4_.w1 + _loc9_.a1 * _loc4_.w4;
      var v2 = _loc4_.v2 = _loc9_.a0 * _loc4_.w2 + _loc9_.a1 * _loc4_.w5;
      var v3 = _loc4_.v3 = _loc9_.a3 * _loc4_.w0 + _loc9_.a4 * _loc4_.w3;
      var v4 = _loc4_.v4 = _loc9_.a3 * _loc4_.w1 + _loc9_.a4 * _loc4_.w4 + _loc9_.a5 * _loc4_.w7;
      var v5 = _loc4_.v5 = _loc9_.a3 * _loc4_.w2 + _loc9_.a4 * _loc4_.w5 + _loc9_.a5 * _loc4_.w8;
      _loc31_ = _loc4_.v6 = _loc9_.a6 * _loc4_.w0 + _loc9_.a7 * _loc4_.w3;
      _loc29_ = _loc4_.v7 = _loc9_.a6 * _loc4_.w1 + _loc9_.a7 * _loc4_.w4 + _loc9_.a8 * _loc4_.w7;
      _loc33_ = _loc4_.v8 = _loc9_.a6 * _loc4_.w2 + _loc9_.a7 * _loc4_.w5 + _loc9_.a8 * _loc4_.w8;
      this._wLastVer = this._wVer;
      this._aLastVer = this._parent._aVer;
   }
   else if(this._sys == 1 && (this._wLastVer != this._wVer || this._bLastVer != this._parent._bVer))
   {
      _loc4_ = this._c;
      _loc9_ = this._parent._c;
      var v0 = _loc4_.v0 = _loc9_.b0 * _loc4_.w0 + _loc9_.b1 * _loc4_.w3;
      var v1 = _loc4_.v1 = _loc9_.b0 * _loc4_.w1 + _loc9_.b1 * _loc4_.w4 + _loc9_.b2 * _loc4_.w7;
      var v2 = _loc4_.v2 = _loc9_.b0 * _loc4_.w2 + _loc9_.b1 * _loc4_.w5 + _loc9_.b2 * _loc4_.w8;
      var v3 = _loc4_.v3 = _loc9_.b3 * _loc4_.w0 + _loc9_.b4 * _loc4_.w3;
      var v4 = _loc4_.v4 = _loc9_.b3 * _loc4_.w1 + _loc9_.b4 * _loc4_.w4 + _loc9_.b5 * _loc4_.w7;
      var v5 = _loc4_.v5 = _loc9_.b3 * _loc4_.w2 + _loc9_.b4 * _loc4_.w5 + _loc9_.b5 * _loc4_.w8;
      _loc31_ = _loc4_.v6 = _loc9_.b6 * _loc4_.w0 + _loc9_.b7 * _loc4_.w3;
      _loc29_ = _loc4_.v7 = _loc9_.b6 * _loc4_.w1 + _loc9_.b7 * _loc4_.w4 + _loc9_.b8 * _loc4_.w7;
      _loc33_ = _loc4_.v8 = _loc9_.b6 * _loc4_.w2 + _loc9_.b7 * _loc4_.w5 + _loc9_.b8 * _loc4_.w8;
      this._wLastVer = this._wVer;
      this._bLastVer = this._parent._bVer;
   }
   else
   {
      _loc22_ = this._c;
      var v0 = _loc22_.v0;
      var v1 = _loc22_.v1;
      var v2 = _loc22_.v2;
      var v3 = _loc22_.v3;
      var v4 = _loc22_.v4;
      var v5 = _loc22_.v5;
      _loc31_ = _loc22_.v6;
      _loc29_ = _loc22_.v7;
      _loc33_ = _loc22_.v8;
   }
   var minStep = this._minStep;
   var _loc32_ = Math.sqrt(_loc31_ * _loc31_ + _loc29_ * _loc29_);
   var _loc27_;
   var _loc24_;
   var _loc26_;
   var _loc28_;
   var _loc30_;
   var _loc8_;
   var _loc6_;
   var _loc5_;
   var _loc3_;
   var _loc2_;
   var _loc7_;
   if(_loc32_ == 0)
   {
      if(_loc33_ < 0)
      {
         drawArc(this._gS,this._gE,_loc20_);
      }
      else
      {
         drawArc(this._gS,this._gE,_loc21_);
      }
   }
   else
   {
      _loc27_ = (- _loc33_) / _loc32_;
      if(_loc27_ <= -1)
      {
         drawArc(this._gS,this._gE,_loc21_);
      }
      else if(_loc27_ >= 1)
      {
         drawArc(this._gS,this._gE,_loc20_);
      }
      else
      {
         _loc24_ = Math.asin(_loc27_);
         _loc26_ = Math.atan2(_loc31_,_loc29_);
         if(Math.cos(_loc24_) < 0)
         {
            _loc28_ = ((_loc24_ - _loc26_) % 6.283185307179586 + 6.283185307179586) % 6.283185307179586;
            _loc30_ = ((3.141592653589793 - _loc24_ - _loc26_) % 6.283185307179586 + 6.283185307179586) % 6.283185307179586;
         }
         else
         {
            _loc28_ = ((3.141592653589793 - _loc24_ - _loc26_) % 6.283185307179586 + 6.283185307179586) % 6.283185307179586;
            _loc30_ = ((_loc24_ - _loc26_) % 6.283185307179586 + 6.283185307179586) % 6.283185307179586;
         }
         if(this._gS == this._gE)
         {
            drawArc(_loc30_,_loc28_,_loc21_);
            drawArc(_loc28_,_loc30_,_loc20_);
         }
         else
         {
            _loc8_ = [[_loc30_,0],[_loc28_,1],[this._gS,2],[this._gE,3]];
            _loc8_.sort(this.gSort);
            _loc6_ = false;
            _loc5_ = true;
            _loc3_ = 0;
            while(_loc3_ < 4)
            {
               if(_loc8_[_loc3_][1] == 0)
               {
                  _loc5_ = true;
               }
               else if(_loc8_[_loc3_][1] == 1)
               {
                  _loc5_ = false;
               }
               else if(_loc8_[_loc3_][1] == 2)
               {
                  _loc6_ = true;
               }
               else
               {
                  _loc6_ = false;
               }
               _loc3_ = _loc3_ + 1;
            }
            _loc2_ = _loc8_[3];
            _loc7_ = 0;
            while(_loc7_ < 4)
            {
               g1 = _loc2_;
               _loc2_ = _loc8_[_loc7_];
               if(_loc6_ && g1[0] != _loc2_[0])
               {
                  if(_loc5_)
                  {
                     drawArc(g1[0],_loc2_[0],_loc21_);
                  }
                  else
                  {
                     drawArc(g1[0],_loc2_[0],_loc20_);
                  }
               }
               if(_loc2_[1] == 0)
               {
                  _loc5_ = true;
               }
               else if(_loc2_[1] == 1)
               {
                  _loc5_ = false;
               }
               else if(_loc2_[1] == 2)
               {
                  _loc6_ = true;
               }
               else
               {
                  _loc6_ = false;
               }
               _loc7_ = _loc7_ + 1;
            }
         }
      }
   }
};
p.gSort = function(a, b)
{
   if(a[0] < b[0])
   {
      return -1;
   }
   if(a[0] > b[0])
   {
      return 1;
   }
   return 0;
};
p.setStyle = function(thickness, circleColor, alpha)
{
   if(thickness != undefined)
   {
      this._thick = thickness;
   }
   if(circleColor != undefined)
   {
      this._color = circleColor;
   }
   if(alpha != undefined)
   {
      this._alpha = alpha;
   }
};
p.setArcPoints = function(p1, p2)
{
   var _loc8_;
   var _loc17_;
   var _loc21_;
   if(typeof p1 == "string")
   {
      _loc8_ = this._parent[p1];
      if(!(_loc8_ instanceof CSObjectsClass))
      {
         return false;
      }
      this._sys = _loc8_._sys;
      if(this._sys == 0)
      {
         _loc17_ = (360 - _loc8_.az) * 0.017453292519943295;
         _loc21_ = _loc8_.alt * 0.017453292519943295;
      }
      else
      {
         if(this._sys != 1)
         {
            return false;
         }
         _loc17_ = _loc8_.ra * 0.2617993877991494;
         _loc21_ = _loc8_.dec * 0.017453292519943295;
      }
   }
   else if(p1.az != undefined && p1.alt != undefined)
   {
      this._sys = 0;
      _loc17_ = (360 - p1.az) * 0.017453292519943295;
      _loc21_ = p1.alt * 0.017453292519943295;
   }
   else
   {
      if(!(p1.ra != undefined && p1.dec != undefined))
      {
         return false;
      }
      this._sys = 1;
      _loc17_ = p1.ra * 0.2617993877991494;
      _loc21_ = p1.dec * 0.017453292519943295;
   }
   var _loc15_;
   var _loc19_;
   var _loc16_;
   var _loc13_;
   if(typeof p2 == "string")
   {
      _loc8_ = this._parent[p2];
      if(!(_loc8_ instanceof CSObjectsClass))
      {
         return false;
      }
      if(this._sys == 0)
      {
         _loc15_ = (360 - _loc8_.az) * 0.017453292519943295;
         _loc19_ = _loc8_.alt * 0.017453292519943295;
      }
      else
      {
         if(this._sys != 1)
         {
            return false;
         }
         _loc15_ = _loc8_.ra * 0.2617993877991494;
         _loc19_ = _loc8_.dec * 0.017453292519943295;
      }
   }
   else if(p2.az != undefined && p2.alt != undefined)
   {
      if(this._sys == 0)
      {
         _loc15_ = (360 - p2.az) * 0.017453292519943295;
         _loc19_ = p2.alt * 0.017453292519943295;
      }
      else if(this._sys == 1)
      {
         _loc16_ = new Object();
         this._parent.MHtoC({az:(360 - p2.az) * 0.017453292519943295,alt:p2.alt * 0.017453292519943295},_loc16_);
         _loc15_ = _loc16_.ra;
         _loc19_ = _loc16_.dec;
      }
   }
   else
   {
      if(!(p2.ra != undefined && p2.dec != undefined))
      {
         return false;
      }
      if(this._sys == 0)
      {
         _loc13_ = new Object();
         this._parent.CtoMH({ra:p2.ra * 0.2617993877991494,dec:p2.dec * 0.017453292519943295},_loc13_);
         _loc15_ = _loc13_.az;
         _loc19_ = _loc13_.alt;
      }
      else if(this._sys == 1)
      {
         _loc15_ = p2.ra * 0.2617993877991494;
         _loc19_ = p2.dec * 0.017453292519943295;
      }
   }
   var _loc10_ = Math.cos(_loc21_);
   var _loc0_;
   var _loc23_ = z1 = Math.sin(_loc21_);
   var _loc4_ = _loc10_ * Math.cos(_loc17_);
   var _loc3_ = _loc10_ * Math.sin(_loc17_);
   var _loc9_ = Math.cos(_loc19_);
   var _loc22_ = z2 = Math.sin(_loc19_);
   var _loc7_ = _loc9_ * Math.cos(_loc15_);
   var _loc6_ = _loc9_ * Math.sin(_loc15_);
   var _loc14_ = _loc3_ * z2 - _loc6_ * z1;
   var _loc12_ = _loc7_ * z1 - _loc4_ * z2;
   var _loc11_ = _loc4_ * _loc6_ - _loc7_ * _loc3_;
   var _loc18_ = Math.sqrt(_loc14_ * _loc14_ + _loc12_ * _loc12_ + _loc11_ * _loc11_);
   if(_loc18_ < 0.000001)
   {
      if(_loc4_ == _loc7_ && _loc3_ == _loc6_ && z1 == z2)
      {
         return false;
      }
      this._lambda = 0;
      this._tilt = 1.5707963267948966;
      this._beta = Math.atan2(_loc3_,_loc4_);
      this._gS = Math.acos(Math.sqrt(_loc4_ * _loc4_ + _loc3_ * _loc3_));
      if(z1 < 0)
      {
         this._gS = - this._gS;
      }
      this._gS = this.mod(this._gS,6.283185307179586);
      this._gE = (this._gS + 3.141592653589793) % 6.283185307179586;
      this.doW();
      return true;
   }
   this._lambda = 0;
   this._tilt = Math.acos(_loc11_ / _loc18_);
   var _loc20_;
   if(this._tilt == 0)
   {
      this._beta = 0;
      this._gS = this.mod(Math.atan2(_loc3_,_loc4_),6.283185307179586);
      this._gE = this.mod(Math.atan2(_loc6_,_loc7_),6.283185307179586);
   }
   else if(this._tilt == 3.141592653589793)
   {
      this._beta = 0;
      this._gS = this.mod(Math.atan2(- _loc3_,_loc4_),6.283185307179586);
      this._gE = this.mod(Math.atan2(- _loc6_,_loc7_),6.283185307179586);
   }
   else
   {
      this._beta = Math.atan2(_loc14_,- _loc12_);
      _loc20_ = Math.sin(this._tilt);
      this._gS = this.mod(Math.atan2(_loc23_ / _loc20_,_loc10_ * Math.cos(_loc17_ - this._beta)),6.283185307179586);
      this._gE = this.mod(Math.atan2(_loc22_ / _loc20_,_loc9_ * Math.cos(_loc15_ - this._beta)),6.283185307179586);
   }
   this.doW();
   return true;
};
p.setCircleParameters = p.setParameters = function(arg)
{
   if(arg.az != undefined && arg.alt != undefined && arg.tilt != undefined)
   {
      this._sys = 0;
      if(isFinite(arg.tilt))
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
      if(isFinite(arg.alt))
      {
         if(arg.alt < -90)
         {
            this._lambda = -3.141592653589793;
         }
         else if(arg.alt > 90)
         {
            this._lambda = 3.141592653589793;
         }
         else
         {
            this._lambda = arg.alt * 0.017453292519943295;
         }
      }
      if(isFinite(arg.az))
      {
         this._beta = 0.017453292519943295 * this.mod(- arg.az,360);
      }
      if(isFinite(arg.gammaStart))
      {
         this._gS = 0.017453292519943295 * this.mod(arg.gammaStart,360);
      }
      if(isFinite(arg.gammaEnd))
      {
         this._gE = 0.017453292519943295 * this.mod(arg.gammaEnd,360);
      }
   }
   else if(arg.ra != undefined && arg.dec != undefined && arg.tilt != undefined)
   {
      this._sys = 1;
      if(isFinite(arg.tilt))
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
      if(isFinite(arg.dec))
      {
         if(arg.dec < -90)
         {
            this._lambda = -3.141592653589793;
         }
         else if(arg.dec > 90)
         {
            this._lambda = 3.141592653589793;
         }
         else
         {
            this._lambda = arg.dec * 0.017453292519943295;
         }
      }
      if(isFinite(arg.ra))
      {
         this._beta = 0.2617993877991494 * this.mod(arg.ra,24);
      }
      if(isFinite(arg.gammaStart))
      {
         this._gS = 0.017453292519943295 * this.mod(arg.gammaStart,360);
      }
      if(isFinite(arg.gammaEnd))
      {
         this._gE = 0.017453292519943295 * this.mod(arg.gammaEnd,360);
      }
   }
   this.doW();
};
p.doW = function()
{
   var _loc5_ = Math.sin(this._tilt);
   var _loc6_ = Math.cos(this._tilt);
   var _loc7_ = Math.sin(this._beta);
   var _loc8_ = Math.cos(this._beta);
   var _loc3_ = Math.cos(this._lambda);
   var _loc4_ = Math.sin(this._lambda);
   var _loc2_ = this._c;
   _loc2_.w0 = _loc3_ * _loc8_;
   _loc2_.w1 = (- _loc3_) * _loc7_ * _loc6_;
   _loc2_.w2 = _loc4_ * _loc7_ * _loc5_;
   _loc2_.w3 = _loc3_ * _loc7_;
   _loc2_.w4 = _loc3_ * _loc8_ * _loc6_;
   _loc2_.w5 = (- _loc4_) * _loc8_ * _loc5_;
   _loc2_.w7 = _loc3_ * _loc5_;
   _loc2_.w8 = _loc4_ * _loc6_;
   this._wVer = this._wVer + 1;
};
p.mod = function(n, m)
{
   return (n % m + m) % m;
};
p.getUseMouseFunctions = function()
{
   return this._useMouseFunctions;
};
p.setUseMouseFunctions = function(arg, options)
{
   this._useMouseFunctions = Boolean(arg);
   var _loc0_;
   var _loc2_ = enableBack = this._useMouseFunctions;
   if(options == "back only")
   {
      _loc2_ = false;
   }
   else if(options == "front only")
   {
      enableBack = false;
   }
   if(_loc2_)
   {
      this._front.useHandCursor = false;
      this._front._thisCircle = this;
      this._front._callInst = this._parent._parent;
      this._front.onRollOver = function()
      {
         this._thisCircle.onRollOver.call(this._callInst,"front");
      };
      this._front.onRollOut = function()
      {
         this._thisCircle.onRollOut.call(this._callInst,"front");
      };
      this._front.onRelease = function()
      {
         this._thisCircle.onRelease.call(this._callInst,"front");
      };
      this._front.onReleaseOutside = function()
      {
         this._thisCircle.onReleaseOutside.call(this._callInst,"front");
      };
      this._front.onPress = function()
      {
         this._thisCircle.onPress.call(this._callInst,"front");
      };
   }
   else
   {
      delete this._front.onRollOver;
      delete this._front.onRollOut;
      delete this._front.onRelease;
      delete this._front.onReleaseOutside;
      delete this._front.onPress;
   }
   if(enableBack)
   {
      this._back.useHandCursor = false;
      this._back._thisCircle = this;
      this._back._callInst = this._parent._parent;
      this._back.onRollOver = function()
      {
         this._thisCircle.onRollOver.call(this._callInst,"back");
      };
      this._back.onRollOut = function()
      {
         this._thisCircle.onRollOut.call(this._callInst,"back");
      };
      this._back.onRelease = function()
      {
         this._thisCircle.onRelease.call(this._callInst,"back");
      };
      this._back.onReleaseOutside = function()
      {
         this._thisCircle.onReleaseOutside.call(this._callInst,"back");
      };
      this._back.onPress = function()
      {
         this._thisCircle.onPress.call(this._callInst,"back");
      };
   }
   else
   {
      delete this._back.onRollOver;
      delete this._back.onRollOut;
      delete this._back.onRelease;
      delete this._back.onReleaseOutside;
      delete this._back.onPress;
   }
};
p.getGammaStart = function()
{
   return 57.29577951308232 * this._gS;
};
p.setGammaStart = function(arg)
{
   if(isFinite(arg))
   {
      this._gS = 0.017453292519943295 * this.mod(arg,360);
   }
};
p.getGammaEnd = function()
{
   return 57.29577951308232 * this._gE;
};
p.setGammaEnd = function(arg)
{
   if(isFinite(arg))
   {
      this._gE = 0.017453292519943295 * this.mod(arg,360);
   }
};
p.getTilt = function()
{
   return this._tilt * 57.29577951308232;
};
p.setTilt = function(arg)
{
   if(isFinite(arg))
   {
      if(arg < 0)
      {
         this._tilt = 0;
      }
      else if(arg > 180)
      {
         this._tilt = 3.141592653589793;
      }
      else
      {
         this._tilt = arg * 0.017453292519943295;
      }
      this.doW();
   }
};
p.getLambda = function()
{
   return this._lambda * 57.29577951308232;
};
p.setLambda = function(arg)
{
   if(isFinite(arg))
   {
      if(arg < -90)
      {
         this._lambda = -3.141592653589793;
      }
      else if(arg > 90)
      {
         this._lambda = 3.141592653589793;
      }
      else
      {
         this._lambda = arg * 0.017453292519943295;
      }
      this.doW();
      return true;
   }
};
p.setAlt = function(arg)
{
   if(this.setLambda(arg))
   {
      this._sys = 0;
   }
};
p.setDec = function(arg)
{
   if(this.setLambda(arg))
   {
      this._sys = 1;
   }
};
p.getBeta = function()
{
   return this._beta * 57.29577951308232;
};
p.setBeta = function(arg)
{
   if(isFinite(arg))
   {
      this._beta = 0.017453292519943295 * this.mod(arg,360);
      this.doW();
      return true;
   }
};
p.getAz = function()
{
   return this.mod(- this.getBeta(),360);
};
p.setAz = function(arg)
{
   if(this.setBeta(- arg))
   {
      this._sys = 0;
   }
};
p.getRa = function()
{
   return this.getBeta() / 15;
};
p.setRa = function(arg)
{
   if(this.setBeta(15 * arg))
   {
      this._sys = 1;
   }
};
p.getVisible = function()
{
   return this._visible;
};
p.setVisible = function(arg)
{
   this._visible = Boolean(arg);
   this.update();
};
p.addProperty("useMouseFunctions",p.getUseMouseFunctions,p.setUseMouseFunctions);
p.addProperty("gammaStart",p.getGammaStart,p.setGammaStart);
p.addProperty("gammaEnd",p.getGammaEnd,p.setGammaEnd);
p.addProperty("tilt",p.getTilt,p.setTilt);
p.addProperty("alt",p.getLambda,p.setAlt);
p.addProperty("dec",p.getLambda,p.setDec);
p.addProperty("az",p.getAz,p.setAz);
p.addProperty("ra",p.getRa,p.setRa);
p.addProperty("visible",p.getVisible,p.setVisible);
