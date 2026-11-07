function CSCirclesClass(parent, name, id, depth)
{
   var _loc1_ = this;
   var _loc2_ = depth;
   _loc1_._parent = parent;
   _loc1_._name = name;
   _loc1_._id = id;
   _loc1_._depth = _loc2_;
   _loc1_._c = {};
   _loc1_._wVer = -1;
   _loc1_._gS = 0;
   _loc1_._gE = 0;
   _loc1_._beta = 0;
   _loc1_._tilt = 0;
   _loc1_._lambda = 0;
   _loc1_._sys = 0;
   _loc1_._visible = true;
   _loc1_._useMouseFunctions = false;
   _loc1_._color = 16711680;
   _loc1_._thick = 1;
   _loc1_._alpha = 80;
   _loc1_._back = _loc1_._parent._bC.createEmptyMovieClip("_" + _loc2_,_loc2_);
   _loc1_._front = _loc1_._parent._fC.createEmptyMovieClip("_" + _loc2_,_loc2_);
}
var p = CelestialSphereClass.prototype;
p.addCircle = function(name, style, definition, depth)
{
   var _loc1_ = depth;
   var _loc2_ = this;
   var _loc3_ = name;
   if(_loc1_ == undefined)
   {
      _loc1_ = 0;
      while(_loc2_._fC["_" + _loc1_] != undefined)
      {
         _loc1_ = _loc1_ + 1;
      }
   }
   var id = _loc2_._circleFreeID++;
   _loc2_[_loc3_] = new CSCirclesClass(_loc2_,_loc3_,id,_loc1_);
   _loc2_._circleList.push({id:id,name:_loc2_[_loc3_]});
   if(typeof style == "object")
   {
      _loc2_[_loc3_].setStyle(style.thickness,style.color,style.alpha);
   }
   if(typeof definition == "object")
   {
      _loc2_[_loc3_].setParameters(definition);
   }
   return _loc2_[_loc3_];
};
p.updateCircles = function(notHorizon)
{
   var _loc2_ = this;
   var start = getTimer();
   var _loc1_;
   var _loc3_;
   if(notHorizon)
   {
      _loc1_ = 0;
      while(_loc1_ < _loc2_._circleList.length)
      {
         _loc3_ = _loc2_._circleList[_loc1_].name;
         if(!_loc3_._sys == 0)
         {
            _loc3_.update();
         }
         _loc1_ = _loc1_ + 1;
      }
   }
   else
   {
      _loc1_ = 0;
      while(_loc1_ < _loc2_._circleList.length)
      {
         _loc2_._circleList[_loc1_].name.update();
         _loc1_ = _loc1_ + 1;
      }
   }
   if(_loc2_._traceOn)
   {
      trace("circles: " + (getTimer() - start) + " ms");
   }
};
p.showCircles = function()
{
   var _loc2_ = this._circleList;
   var _loc1_ = 0;
   while(_loc1_ < _loc2_.length)
   {
      _loc2_[_loc1_].name.visible = true;
      _loc1_ = _loc1_ + 1;
   }
};
p.hideCircles = function()
{
   var _loc2_ = this._circleList;
   var _loc1_ = 0;
   while(_loc1_ < _loc2_.length)
   {
      _loc2_[_loc1_].name.visible = false;
      _loc1_ = _loc1_ + 1;
   }
};
p.removeCircles = function()
{
   var _loc3_ = this;
   var _loc2_ = _loc3_._circleList;
   var _loc1_ = 0;
   while(_loc1_ < _loc2_.length)
   {
      _loc2_[_loc1_].name._back.removeMovieClip();
      _loc2_[_loc1_].name._front.removeMovieClip();
      delete _loc3_[_loc2_[_loc1_].name._name];
      _loc1_ = _loc1_ + 1;
   }
   _loc3_._circleFreeID = 0;
   _loc3_._circleList = [];
};
var p = CSCirclesClass.prototype = new Object();
p._minStep = 0.7853981633974483;
p.toString = function()
{
   return String(this._parent) + "." + this._name + " (circle)";
};
p.remove = function()
{
   var _loc3_ = this;
   var _loc2_ = _loc3_._parent._circleList;
   var _loc1_ = 0;
   while(_loc1_ < _loc2_.length)
   {
      if(_loc2_[_loc1_].id == _loc3_._id)
      {
         break;
      }
      _loc1_ = _loc1_ + 1;
   }
   _loc2_.splice(_loc1_,1);
   _loc3_._back.removeMovieClip();
   _loc3_._front.removeMovieClip();
   delete _loc3_._parent[_loc3_._name];
};
p.update = function()
{
   var _loc2_ = this;
   function drawArc(g1, g2, mc)
   {
      if(g2 < g1)
      {
         g2 += 6.283185307179586;
      }
      var arc = g2 - g1;
      if(arc == 0)
      {
         arc = 6.283185307179586;
      }
      var n = Math.ceil(arc / minStep);
      var step = arc / n;
      var halfStep = step / 2;
      var cos = Math.cos;
      var sin = Math.sin;
      var cRad = 1 / cos(halfStep);
      var ax = cos(g1);
      var _loc3_ = sin(g1);
      mc.moveTo(v0 * ax + v1 * _loc3_ + v2,v3 * ax + v4 * _loc3_ + v5);
      var aAngle = g1 + step;
      var cAngle = aAngle - halfStep;
      var i = 0;
      var _loc2_;
      var _loc1_;
      while(i < n)
      {
         var ax = cos(aAngle);
         _loc3_ = sin(aAngle);
         _loc2_ = cRad * cos(cAngle);
         _loc1_ = cRad * sin(cAngle);
         mc.curveTo(v0 * _loc2_ + v1 * _loc1_ + v2,v3 * _loc2_ + v4 * _loc1_ + v5,v0 * ax + v1 * _loc3_ + v2,v3 * ax + v4 * _loc3_ + v5);
         aAngle += step;
         cAngle += step;
         i++;
      }
   }
   var frontMC = _loc2_._front;
   var backMC = _loc2_._back;
   frontMC.clear();
   backMC.clear();
   var _loc3_;
   var _loc1_;
   if(_loc2_._visible)
   {
      frontMC.lineStyle(_loc2_._thick,_loc2_._color,_loc2_._alpha);
      backMC.lineStyle(_loc2_._thick,_loc2_._color,_loc2_._alpha);
      if(_loc2_._sys == 0 && (_loc2_._wLastVer != _loc2_._wVer || _loc2_._aLastVer != _loc2_._parent._aVer))
      {
         var tc = _loc2_._c;
         var pc = _loc2_._parent._c;
         var v0 = tc.v0 = pc.a0 * tc.w0 + pc.a1 * tc.w3;
         var v1 = tc.v1 = pc.a0 * tc.w1 + pc.a1 * tc.w4;
         var v2 = tc.v2 = pc.a0 * tc.w2 + pc.a1 * tc.w5;
         var v3 = tc.v3 = pc.a3 * tc.w0 + pc.a4 * tc.w3;
         var v4 = tc.v4 = pc.a3 * tc.w1 + pc.a4 * tc.w4 + pc.a5 * tc.w7;
         var v5 = tc.v5 = pc.a3 * tc.w2 + pc.a4 * tc.w5 + pc.a5 * tc.w8;
         var v6 = tc.v6 = pc.a6 * tc.w0 + pc.a7 * tc.w3;
         var v7 = tc.v7 = pc.a6 * tc.w1 + pc.a7 * tc.w4 + pc.a8 * tc.w7;
         var v8 = tc.v8 = pc.a6 * tc.w2 + pc.a7 * tc.w5 + pc.a8 * tc.w8;
         _loc2_._wLastVer = _loc2_._wVer;
         _loc2_._aLastVer = _loc2_._parent._aVer;
      }
      else if(_loc2_._sys == 1 && (_loc2_._wLastVer != _loc2_._wVer || _loc2_._bLastVer != _loc2_._parent._bVer))
      {
         var tc = _loc2_._c;
         var pc = _loc2_._parent._c;
         var v0 = tc.v0 = pc.b0 * tc.w0 + pc.b1 * tc.w3;
         var v1 = tc.v1 = pc.b0 * tc.w1 + pc.b1 * tc.w4 + pc.b2 * tc.w7;
         var v2 = tc.v2 = pc.b0 * tc.w2 + pc.b1 * tc.w5 + pc.b2 * tc.w8;
         var v3 = tc.v3 = pc.b3 * tc.w0 + pc.b4 * tc.w3;
         var v4 = tc.v4 = pc.b3 * tc.w1 + pc.b4 * tc.w4 + pc.b5 * tc.w7;
         var v5 = tc.v5 = pc.b3 * tc.w2 + pc.b4 * tc.w5 + pc.b5 * tc.w8;
         var v6 = tc.v6 = pc.b6 * tc.w0 + pc.b7 * tc.w3;
         var v7 = tc.v7 = pc.b6 * tc.w1 + pc.b7 * tc.w4 + pc.b8 * tc.w7;
         var v8 = tc.v8 = pc.b6 * tc.w2 + pc.b7 * tc.w5 + pc.b8 * tc.w8;
         _loc2_._wLastVer = _loc2_._wVer;
         _loc2_._bLastVer = _loc2_._parent._bVer;
      }
      else
      {
         var c = _loc2_._c;
         var v0 = c.v0;
         var v1 = c.v1;
         var v2 = c.v2;
         var v3 = c.v3;
         var v4 = c.v4;
         var v5 = c.v5;
         var v6 = c.v6;
         var v7 = c.v7;
         var v8 = c.v8;
      }
      var minStep = _loc2_._minStep;
      var A = Math.sqrt(v6 * v6 + v7 * v7);
      if(A == 0)
      {
         if(v8 < 0)
         {
            drawArc(_loc2_._gS,_loc2_._gE,backMC);
         }
         else
         {
            drawArc(_loc2_._gS,_loc2_._gE,frontMC);
         }
      }
      else
      {
         var sj = (- v8) / A;
         if(sj <= -1)
         {
            drawArc(_loc2_._gS,_loc2_._gE,frontMC);
         }
         else if(sj >= 1)
         {
            drawArc(_loc2_._gS,_loc2_._gE,backMC);
         }
         else
         {
            var j = Math.asin(sj);
            var t = Math.atan2(v6,v7);
            if(Math.cos(j) < 0)
            {
               var gDesc = ((j - t) % 6.283185307179586 + 6.283185307179586) % 6.283185307179586;
               var gAsc = ((3.141592653589793 - j - t) % 6.283185307179586 + 6.283185307179586) % 6.283185307179586;
            }
            else
            {
               var gDesc = ((3.141592653589793 - j - t) % 6.283185307179586 + 6.283185307179586) % 6.283185307179586;
               var gAsc = ((j - t) % 6.283185307179586 + 6.283185307179586) % 6.283185307179586;
            }
            if(_loc2_._gS == _loc2_._gE)
            {
               drawArc(gAsc,gDesc,frontMC);
               drawArc(gDesc,gAsc,backMC);
            }
            else
            {
               var gArray = [[gAsc,0],[gDesc,1],[_loc2_._gS,2],[_loc2_._gE,3]];
               gArray.sort(_loc2_.gSort);
               var draw = false;
               var front = true;
               _loc3_ = 0;
               while(_loc3_ < 4)
               {
                  if(gArray[_loc3_][1] == 0)
                  {
                     front = true;
                  }
                  else if(gArray[_loc3_][1] == 1)
                  {
                     front = false;
                  }
                  else if(gArray[_loc3_][1] == 2)
                  {
                     draw = true;
                  }
                  else
                  {
                     draw = false;
                  }
                  _loc3_ = _loc3_ + 1;
               }
               _loc1_ = gArray[3];
               var i = 0;
               while(i < 4)
               {
                  g1 = _loc1_;
                  _loc1_ = gArray[i];
                  if(draw && g1[0] != _loc1_[0])
                  {
                     if(front)
                     {
                        drawArc(g1[0],_loc1_[0],frontMC);
                     }
                     else
                     {
                        drawArc(g1[0],_loc1_[0],backMC);
                     }
                  }
                  if(_loc1_[1] == 0)
                  {
                     front = true;
                  }
                  else if(_loc1_[1] == 1)
                  {
                     front = false;
                  }
                  else if(_loc1_[1] == 2)
                  {
                     draw = true;
                  }
                  else
                  {
                     draw = false;
                  }
                  i++;
               }
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
   var _loc1_ = this;
   if(thickness != undefined)
   {
      _loc1_._thick = thickness;
   }
   if(circleColor != undefined)
   {
      _loc1_._color = circleColor;
   }
   if(alpha != undefined)
   {
      _loc1_._alpha = alpha;
   }
};
p.setArcPoints = function(p1, p2)
{
   var _loc1_ = this;
   var _loc2_ = p2;
   if(typeof p1 == "string")
   {
      var obj = _loc1_._parent[p1];
      if(!(obj instanceof CSObjectsClass))
      {
         return false;
      }
      _loc1_._sys = obj._sys;
      if(_loc1_._sys == 0)
      {
         var theta1 = (360 - obj.az) * 0.017453292519943295;
         var phi1 = obj.alt * 0.017453292519943295;
      }
      else
      {
         if(_loc1_._sys != 1)
         {
            return false;
         }
         var theta1 = obj.ra * 0.2617993877991494;
         var phi1 = obj.dec * 0.017453292519943295;
      }
   }
   else if(p1.az != undefined && p1.alt != undefined)
   {
      _loc1_._sys = 0;
      var theta1 = (360 - p1.az) * 0.017453292519943295;
      var phi1 = p1.alt * 0.017453292519943295;
   }
   else
   {
      if(!(p1.ra != undefined && p1.dec != undefined))
      {
         return false;
      }
      _loc1_._sys = 1;
      var theta1 = p1.ra * 0.2617993877991494;
      var phi1 = p1.dec * 0.017453292519943295;
   }
   if(typeof _loc2_ == "string")
   {
      var obj = _loc1_._parent[_loc2_];
      if(!(obj instanceof CSObjectsClass))
      {
         return false;
      }
      if(_loc1_._sys == 0)
      {
         var theta2 = (360 - obj.az) * 0.017453292519943295;
         var phi2 = obj.alt * 0.017453292519943295;
      }
      else
      {
         if(_loc1_._sys != 1)
         {
            return false;
         }
         var theta2 = obj.ra * 0.2617993877991494;
         var phi2 = obj.dec * 0.017453292519943295;
      }
   }
   else if(_loc2_.az != undefined && _loc2_.alt != undefined)
   {
      if(_loc1_._sys == 0)
      {
         var theta2 = (360 - _loc2_.az) * 0.017453292519943295;
         var phi2 = _loc2_.alt * 0.017453292519943295;
      }
      else if(_loc1_._sys == 1)
      {
         var cp = new Object();
         _loc1_._parent.MHtoC({az:(360 - _loc2_.az) * 0.017453292519943295,alt:_loc2_.alt * 0.017453292519943295},cp);
         var theta2 = cp.ra;
         var phi2 = cp.dec;
      }
   }
   else
   {
      if(!(_loc2_.ra != undefined && _loc2_.dec != undefined))
      {
         return false;
      }
      if(_loc1_._sys == 0)
      {
         var hp = new Object();
         _loc1_._parent.CtoMH({ra:_loc2_.ra * 0.2617993877991494,dec:_loc2_.dec * 0.017453292519943295},hp);
         var theta2 = hp.az;
         var phi2 = hp.alt;
      }
      else if(_loc1_._sys == 1)
      {
         var theta2 = _loc2_.ra * 0.2617993877991494;
         var phi2 = _loc2_.dec * 0.017453292519943295;
      }
   }
   var cp1 = Math.cos(phi1);
   var sp1 = z1 = Math.sin(phi1);
   var x1 = cp1 * Math.cos(theta1);
   var _loc3_ = cp1 * Math.sin(theta1);
   var cp2 = Math.cos(phi2);
   var sp2 = z2 = Math.sin(phi2);
   var x2 = cp2 * Math.cos(theta2);
   var y2 = cp2 * Math.sin(theta2);
   var ax = _loc3_ * z2 - y2 * z1;
   var ay = x2 * z1 - x1 * z2;
   var az = x1 * y2 - x2 * _loc3_;
   var aN = Math.sqrt(ax * ax + ay * ay + az * az);
   if(aN < 0.000001)
   {
      if(x1 == x2 && _loc3_ == y2 && z1 == z2)
      {
         return false;
      }
      _loc1_._lambda = 0;
      _loc1_._tilt = 1.5707963267948966;
      _loc1_._beta = Math.atan2(_loc3_,x1);
      _loc1_._gS = Math.acos(Math.sqrt(x1 * x1 + _loc3_ * _loc3_));
      if(z1 < 0)
      {
         _loc1_._gS = - _loc1_._gS;
      }
      _loc1_._gS = _loc1_.mod(_loc1_._gS,6.283185307179586);
      _loc1_._gE = (_loc1_._gS + 3.141592653589793) % 6.283185307179586;
      _loc1_.doW();
      return true;
   }
   _loc1_._lambda = 0;
   _loc1_._tilt = Math.acos(az / aN);
   if(_loc1_._tilt == 0)
   {
      _loc1_._beta = 0;
      _loc1_._gS = _loc1_.mod(Math.atan2(_loc3_,x1),6.283185307179586);
      _loc1_._gE = _loc1_.mod(Math.atan2(y2,x2),6.283185307179586);
   }
   else if(_loc1_._tilt == 3.141592653589793)
   {
      _loc1_._beta = 0;
      _loc1_._gS = _loc1_.mod(Math.atan2(- _loc3_,x1),6.283185307179586);
      _loc1_._gE = _loc1_.mod(Math.atan2(- y2,x2),6.283185307179586);
   }
   else
   {
      _loc1_._beta = Math.atan2(ax,- ay);
      var st = Math.sin(_loc1_._tilt);
      _loc1_._gS = _loc1_.mod(Math.atan2(sp1 / st,cp1 * Math.cos(theta1 - _loc1_._beta)),6.283185307179586);
      _loc1_._gE = _loc1_.mod(Math.atan2(sp2 / st,cp2 * Math.cos(theta2 - _loc1_._beta)),6.283185307179586);
   }
   _loc1_.doW();
   return true;
};
p.setCircleParameters = p.setParameters = function(arg)
{
   var _loc1_ = arg;
   var _loc2_ = this;
   if(_loc1_.az != undefined && _loc1_.alt != undefined && _loc1_.tilt != undefined)
   {
      _loc2_._sys = 0;
      if(isFinite(_loc1_.tilt))
      {
         if(_loc1_.tilt < 0)
         {
            _loc2_._tilt = 0;
         }
         else if(_loc1_.tilt > 180)
         {
            _loc2_._tilt = 3.141592653589793;
         }
         else
         {
            _loc2_._tilt = _loc1_.tilt * 0.017453292519943295;
         }
      }
      if(isFinite(_loc1_.alt))
      {
         if(_loc1_.alt < -90)
         {
            _loc2_._lambda = -3.141592653589793;
         }
         else if(_loc1_.alt > 90)
         {
            _loc2_._lambda = 3.141592653589793;
         }
         else
         {
            _loc2_._lambda = _loc1_.alt * 0.017453292519943295;
         }
      }
      if(isFinite(_loc1_.az))
      {
         _loc2_._beta = 0.017453292519943295 * _loc2_.mod(- _loc1_.az,360);
      }
      if(isFinite(_loc1_.gammaStart))
      {
         _loc2_._gS = 0.017453292519943295 * _loc2_.mod(_loc1_.gammaStart,360);
      }
      if(isFinite(_loc1_.gammaEnd))
      {
         _loc2_._gE = 0.017453292519943295 * _loc2_.mod(_loc1_.gammaEnd,360);
      }
   }
   else if(_loc1_.ra != undefined && _loc1_.dec != undefined && _loc1_.tilt != undefined)
   {
      _loc2_._sys = 1;
      if(isFinite(_loc1_.tilt))
      {
         if(_loc1_.tilt < 0)
         {
            _loc2_._tilt = 0;
         }
         else if(_loc1_.tilt > 180)
         {
            _loc2_._tilt = 3.141592653589793;
         }
         else
         {
            _loc2_._tilt = _loc1_.tilt * 0.017453292519943295;
         }
      }
      if(isFinite(_loc1_.dec))
      {
         if(_loc1_.dec < -90)
         {
            _loc2_._lambda = -3.141592653589793;
         }
         else if(_loc1_.dec > 90)
         {
            _loc2_._lambda = 3.141592653589793;
         }
         else
         {
            _loc2_._lambda = _loc1_.dec * 0.017453292519943295;
         }
      }
      if(isFinite(_loc1_.ra))
      {
         _loc2_._beta = 0.2617993877991494 * _loc2_.mod(_loc1_.ra,24);
      }
      if(isFinite(_loc1_.gammaStart))
      {
         _loc2_._gS = 0.017453292519943295 * _loc2_.mod(_loc1_.gammaStart,360);
      }
      if(isFinite(_loc1_.gammaEnd))
      {
         _loc2_._gE = 0.017453292519943295 * _loc2_.mod(_loc1_.gammaEnd,360);
      }
   }
   _loc2_.doW();
};
p.doW = function()
{
   var _loc2_ = this;
   var st = Math.sin(_loc2_._tilt);
   var ct = Math.cos(_loc2_._tilt);
   var sb = Math.sin(_loc2_._beta);
   var cb = Math.cos(_loc2_._beta);
   var _loc3_ = Math.cos(_loc2_._lambda);
   var sl = Math.sin(_loc2_._lambda);
   var _loc1_ = _loc2_._c;
   _loc1_.w0 = _loc3_ * cb;
   _loc1_.w1 = (- _loc3_) * sb * ct;
   _loc1_.w2 = sl * sb * st;
   _loc1_.w3 = _loc3_ * sb;
   _loc1_.w4 = _loc3_ * cb * ct;
   _loc1_.w5 = (- sl) * cb * st;
   _loc1_.w7 = _loc3_ * st;
   _loc1_.w8 = sl * ct;
   _loc2_._wVer = _loc2_._wVer + 1;
};
p.mod = function(n, m)
{
   var _loc1_ = m;
   return (n % _loc1_ + _loc1_) % _loc1_;
};
p.getUseMouseFunctions = function()
{
   return this._useMouseFunctions;
};
p.setUseMouseFunctions = function(arg, options)
{
   var _loc1_ = this;
   _loc1_._useMouseFunctions = Boolean(arg);
   var _loc0_;
   var _loc2_ = enableBack = _loc1_._useMouseFunctions;
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
      _loc1_._front.useHandCursor = false;
      _loc1_._front._thisCircle = _loc1_;
      _loc1_._front._callInst = _loc1_._parent._parent;
      _loc1_._front.onRollOver = function()
      {
         this._thisCircle.onRollOver.call(this._callInst,"front");
      };
      _loc1_._front.onRollOut = function()
      {
         this._thisCircle.onRollOut.call(this._callInst,"front");
      };
      _loc1_._front.onRelease = function()
      {
         this._thisCircle.onRelease.call(this._callInst,"front");
      };
      _loc1_._front.onReleaseOutside = function()
      {
         this._thisCircle.onReleaseOutside.call(this._callInst,"front");
      };
      _loc1_._front.onPress = function()
      {
         this._thisCircle.onPress.call(this._callInst,"front");
      };
   }
   else
   {
      delete _loc1_._front.onRollOver;
      delete _loc1_._front.onRollOut;
      delete _loc1_._front.onRelease;
      delete _loc1_._front.onReleaseOutside;
      delete _loc1_._front.onPress;
   }
   if(enableBack)
   {
      _loc1_._back.useHandCursor = false;
      _loc1_._back._thisCircle = _loc1_;
      _loc1_._back._callInst = _loc1_._parent._parent;
      _loc1_._back.onRollOver = function()
      {
         this._thisCircle.onRollOver.call(this._callInst,"back");
      };
      _loc1_._back.onRollOut = function()
      {
         this._thisCircle.onRollOut.call(this._callInst,"back");
      };
      _loc1_._back.onRelease = function()
      {
         this._thisCircle.onRelease.call(this._callInst,"back");
      };
      _loc1_._back.onReleaseOutside = function()
      {
         this._thisCircle.onReleaseOutside.call(this._callInst,"back");
      };
      _loc1_._back.onPress = function()
      {
         this._thisCircle.onPress.call(this._callInst,"back");
      };
   }
   else
   {
      delete _loc1_._back.onRollOver;
      delete _loc1_._back.onRollOut;
      delete _loc1_._back.onRelease;
      delete _loc1_._back.onReleaseOutside;
      delete _loc1_._back.onPress;
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
   var _loc1_ = this;
   var _loc2_ = arg;
   if(isFinite(_loc2_))
   {
      if(_loc2_ < 0)
      {
         _loc1_._tilt = 0;
      }
      else if(_loc2_ > 180)
      {
         _loc1_._tilt = 3.141592653589793;
      }
      else
      {
         _loc1_._tilt = _loc2_ * 0.017453292519943295;
      }
      _loc1_.doW();
   }
};
p.getLambda = function()
{
   return this._lambda * 57.29577951308232;
};
p.setLambda = function(arg)
{
   var _loc1_ = this;
   var _loc2_ = arg;
   if(isFinite(_loc2_))
   {
      if(_loc2_ < -90)
      {
         _loc1_._lambda = -3.141592653589793;
      }
      else if(_loc2_ > 90)
      {
         _loc1_._lambda = 3.141592653589793;
      }
      else
      {
         _loc1_._lambda = _loc2_ * 0.017453292519943295;
      }
      _loc1_.doW();
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
   var _loc1_ = this;
   if(isFinite(arg))
   {
      _loc1_._beta = 0.017453292519943295 * _loc1_.mod(arg,360);
      _loc1_.doW();
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
