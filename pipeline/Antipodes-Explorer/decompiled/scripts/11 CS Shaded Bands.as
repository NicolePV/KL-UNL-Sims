function CSShadedBandClass(parent, name, id, linkageNameFront, linkageNameBack, parameters, surface, hemisphere, initObject)
{
   var _loc1_ = this;
   _loc1_._parent = parent;
   _loc1_._name = name;
   _loc1_._id = id;
   _loc1_._kVer = -1;
   _loc1_._c = {};
   _loc1_._visible = true;
   _loc1_._showBorder = false;
   _loc1_.setLinkageNames(linkageNameFront,linkageNameBack,surface,hemisphere,initObject);
   _loc1_.setParameters(parameters);
}
var p = CelestialSphereClass.prototype;
p.addShadedBand = function(linkageNameFront, linkageNameBack, name, parameters, surface, hemisphere, initObject)
{
   var _loc1_ = this;
   var _loc2_ = name;
   var id = _loc1_._shadedBandFreeID++;
   _loc1_[_loc2_] = new CSShadedBandClass(_loc1_,_loc2_,id,linkageNameFront,linkageNameBack,parameters,surface,hemisphere,initObject);
   _loc1_._shadedBandList.push({id:id,name:_loc1_[_loc2_]});
   return _loc1_[_loc2_];
};
p.updateShadedBands = function(notHorizon)
{
   var start = getTimer();
   var _loc2_ = this._shadedBandList;
   var _loc1_;
   var _loc3_;
   if(notHorizon)
   {
      _loc1_ = 0;
      while(_loc1_ < _loc2_.length)
      {
         _loc3_ = _loc2_[_loc1_].name;
         if(_loc3_._sys != 0)
         {
            _loc3_.update();
         }
         _loc1_ = _loc1_ + 1;
      }
   }
   else
   {
      _loc1_ = 0;
      while(_loc1_ < _loc2_.length)
      {
         _loc2_[_loc1_].name.update();
         _loc1_ = _loc1_ + 1;
      }
   }
   if(this._traceOn)
   {
      trace("shaded bands: " + (getTimer() - start) + " ms");
   }
};
p.showShadedBands = function()
{
   var _loc2_ = this._shadedBandList;
   var _loc1_ = 0;
   while(_loc1_ < _loc2_.length)
   {
      _loc2_[_loc1_].name.visible = true;
      _loc1_ = _loc1_ + 1;
   }
};
p.hideShadedBands = function()
{
   var _loc2_ = this._shadedBandList;
   var _loc1_ = 0;
   while(_loc1_ < _loc2_.length)
   {
      _loc2_[_loc1_].name.visible = false;
      _loc1_ = _loc1_ + 1;
   }
};
p.removeShadedBands = function()
{
   var _loc3_ = this;
   var _loc2_ = _loc3_._shadedBandList;
   var _loc1_ = 0;
   while(_loc1_ < _loc2_.length)
   {
      _loc2_[_loc1_].name._frontMC.removeMovieClip();
      _loc2_[_loc1_].name._backMC.removeMovieClip();
      delete _loc3_[_loc2_[_loc1_].name._name];
      _loc1_ = _loc1_ + 1;
   }
   _loc3_._shadedBandFreeID = 0;
   _loc3_._shadedBandList = [];
};
var p = CSShadedBandClass.prototype = new Object();
p._bThick = 0;
p._bColor = 0;
p._bAlpha = 100;
p._minStep = 0.5235987755982988;
p.update = function()
{
   var _loc1_ = this;
   function drawPerimeterArcs(t1, t2, dir, mc1, mc2)
   {
      if(dir == 1)
      {
         var arc = ((t2 - t1) % 6.283185307179586 + 6.283185307179586) % 6.283185307179586;
         if(arc == 0)
         {
            arc = 6.283185307179586;
            var doMoveTo = true;
         }
         else
         {
            var doMoveTo = false;
         }
         var n = Math.ceil(arc / minStep);
         var step = arc / n;
      }
      else
      {
         var arc = ((t1 - t2) % 6.283185307179586 + 6.283185307179586) % 6.283185307179586;
         if(arc == 0)
         {
            arc = 6.283185307179586;
            var doMoveTo = true;
         }
         else
         {
            var doMoveTo = false;
         }
         var n = Math.ceil(arc / minStep);
         var step = (- arc) / n;
      }
      var halfStep = step / 2;
      var cos = Math.cos;
      var sin = Math.sin;
      var cr = 100 / cos(halfStep);
      var _loc3_;
      if(doMoveTo)
      {
         var ax = 100 * cos(t1);
         _loc3_ = 100 * sin(t1);
         mc1.moveTo(ax,_loc3_);
         mc2.moveTo(ax,_loc3_);
      }
      var aAngle = t1 + step;
      var cAngle = aAngle - halfStep;
      var i = 0;
      var _loc2_;
      var _loc1_;
      while(i < n)
      {
         var ax = 100 * cos(aAngle);
         _loc3_ = 100 * sin(aAngle);
         _loc2_ = cr * cos(cAngle);
         _loc1_ = cr * sin(cAngle);
         mc1.curveTo(_loc2_,_loc1_,ax,_loc3_);
         mc2.curveTo(_loc2_,_loc1_,ax,_loc3_);
         aAngle += step;
         cAngle += step;
         i++;
      }
   }
   function drawSphericalArc(g1, g2, cl, sl, dir, mc, bmc)
   {
      var _loc1_ = sl;
      var _loc2_ = cl;
      if(dir == 1)
      {
         var arc = ((g2 - g1) % 6.283185307179586 + 6.283185307179586) % 6.283185307179586;
         if(arc == 0)
         {
            arc = 6.283185307179586;
            var doMoveTo = true;
         }
         else
         {
            var doMoveTo = false;
         }
         var n = Math.ceil(arc / minStep);
         var step = arc / n;
      }
      else
      {
         var arc = ((g1 - g2) % 6.283185307179586 + 6.283185307179586) % 6.283185307179586;
         if(arc == 0)
         {
            arc = 6.283185307179586;
            var doMoveTo = true;
         }
         else
         {
            var doMoveTo = false;
         }
         var n = Math.ceil(arc / minStep);
         var step = (- arc) / n;
      }
      var halfStep = step / 2;
      var cos = Math.cos;
      var sin = Math.sin;
      var cRad = 1 / cos(halfStep);
      var iax = cos(g1);
      var iay = sin(g1);
      var ax = _loc2_ * (v0 * iax + v1 * iay) + _loc1_ * v2;
      var ay = _loc2_ * (v3 * iax + v4 * iay) + _loc1_ * v5;
      if(doMoveTo)
      {
         mc.moveTo(ax,ay);
      }
      bmc.moveTo(ax,ay);
      var aAngle = g1 + step;
      var cAngle = aAngle - halfStep;
      var i = 0;
      var _loc3_;
      while(i < n)
      {
         var iax = cos(aAngle);
         var iay = sin(aAngle);
         var icx = cRad * cos(cAngle);
         _loc3_ = cRad * sin(cAngle);
         var ax = _loc2_ * (v0 * iax + v1 * iay) + _loc1_ * v2;
         var ay = _loc2_ * (v3 * iax + v4 * iay) + _loc1_ * v5;
         var cx = _loc2_ * (v0 * icx + v1 * _loc3_) + _loc1_ * v2;
         var cy = _loc2_ * (v3 * icx + v4 * _loc3_) + _loc1_ * v5;
         mc.curveTo(cx,cy,ax,ay);
         bmc.curveTo(cx,cy,ax,ay);
         aAngle += step;
         cAngle += step;
         i++;
      }
   }
   var fmc = _loc1_._frontMaskMC;
   var _loc2_ = _loc1_._backMaskMC;
   var fbmc = _loc1_._frontBorderMC;
   var bbmc = _loc1_._backBorderMC;
   fmc.clear();
   _loc2_.clear();
   fbmc.clear();
   bbmc.clear();
   var _loc3_;
   if(!(!_loc1_._visible || _loc1_._noDef))
   {
      fmc.beginFill(16711680);
      _loc2_.beginFill(255);
      fbmc.lineStyle(_loc1_._bThick,_loc1_._bColor,_loc1_._bAlpha);
      bbmc.lineStyle(_loc1_._bThick,_loc1_._bColor,_loc1_._bAlpha);
      var cos = Math.cos;
      var sin = Math.sin;
      var asin = Math.asin;
      var atan2 = Math.atan2;
      var sqrt = Math.sqrt;
      var cl1 = cos(_loc1_._lambda1);
      var sl1 = sin(_loc1_._lambda1);
      var cl2 = cos(_loc1_._lambda2);
      var sl2 = sin(_loc1_._lambda2);
      if(_loc1_._sys == 0 && (_loc1_._kLastVer != _loc1_._kVer || _loc1_._aLastVer != _loc1_._parent._aVer))
      {
         _loc3_ = _loc1_._c;
         var pc = _loc1_._parent._c;
         var s = 100 / _loc1_._parent._c.r;
         var v0 = _loc3_.v0 = s * (pc.a0 * _loc3_.k0 + pc.a1 * _loc3_.k3);
         var v1 = _loc3_.v1 = s * (pc.a0 * _loc3_.k1 + pc.a1 * _loc3_.k4);
         var v2 = _loc3_.v2 = s * (pc.a0 * _loc3_.k2 + pc.a1 * _loc3_.k5);
         var v3 = _loc3_.v3 = s * (pc.a3 * _loc3_.k0 + pc.a4 * _loc3_.k3);
         var v4 = _loc3_.v4 = s * (pc.a3 * _loc3_.k1 + pc.a4 * _loc3_.k4 + pc.a5 * _loc3_.k7);
         var v5 = _loc3_.v5 = s * (pc.a3 * _loc3_.k2 + pc.a4 * _loc3_.k5 + pc.a5 * _loc3_.k8);
         var v6 = _loc3_.v6 = s * (pc.a6 * _loc3_.k0 + pc.a7 * _loc3_.k3);
         var v7 = _loc3_.v7 = s * (pc.a6 * _loc3_.k1 + pc.a7 * _loc3_.k4 + pc.a8 * _loc3_.k7);
         var v8 = _loc3_.v8 = s * (pc.a6 * _loc3_.k2 + pc.a7 * _loc3_.k5 + pc.a8 * _loc3_.k8);
         _loc1_._kLastVer = _loc1_._kVer;
         _loc1_._aLastVer = _loc1_._parent._aVer;
      }
      else if(_loc1_._sys == 1 && (_loc1_._kLastVer != _loc1_._kVer || _loc1_._bLastVer != _loc1_._parent._bVer))
      {
         _loc3_ = _loc1_._c;
         var pc = _loc1_._parent._c;
         var s = 100 / _loc1_._parent._c.r;
         var v0 = _loc3_.v0 = s * (pc.b0 * _loc3_.k0 + pc.b1 * _loc3_.k3);
         var v1 = _loc3_.v1 = s * (pc.b0 * _loc3_.k1 + pc.b1 * _loc3_.k4 + pc.b2 * _loc3_.k7);
         var v2 = _loc3_.v2 = s * (pc.b0 * _loc3_.k2 + pc.b1 * _loc3_.k5 + pc.b2 * _loc3_.k8);
         var v3 = _loc3_.v3 = s * (pc.b3 * _loc3_.k0 + pc.b4 * _loc3_.k3);
         var v4 = _loc3_.v4 = s * (pc.b3 * _loc3_.k1 + pc.b4 * _loc3_.k4 + pc.b5 * _loc3_.k7);
         var v5 = _loc3_.v5 = s * (pc.b3 * _loc3_.k2 + pc.b4 * _loc3_.k5 + pc.b5 * _loc3_.k8);
         var v6 = _loc3_.v6 = s * (pc.b6 * _loc3_.k0 + pc.b7 * _loc3_.k3);
         var v7 = _loc3_.v7 = s * (pc.b6 * _loc3_.k1 + pc.b7 * _loc3_.k4 + pc.b8 * _loc3_.k7);
         var v8 = _loc3_.v8 = s * (pc.b6 * _loc3_.k2 + pc.b7 * _loc3_.k5 + pc.b8 * _loc3_.k8);
         _loc1_._kLastVer = _loc1_._kVer;
         _loc1_._bLastVer = _loc1_._parent._bVer;
      }
      else
      {
         var c = _loc1_._c;
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
      var startX = null;
      var startY = null;
      var A = cl1 * sqrt(v6 * v6 + v7 * v7);
      if(A == 0)
      {
         if(sl1 * v8 < 0)
         {
            var loc1 = 2;
         }
         else
         {
            var loc1 = 1;
         }
      }
      else
      {
         var sj = (- sl1) * v8 / A;
         if(sj <= -1)
         {
            var loc1 = 1;
         }
         else if(sj >= 1)
         {
            var loc1 = 2;
         }
         else
         {
            var loc1 = 0;
            var j = asin(sj);
            var t = atan2(v6,v7);
            if(cos(j) < 0)
            {
               var gD1 = j - t;
               var gA1 = 3.141592653589793 - j - t;
            }
            else
            {
               var gD1 = 3.141592653589793 - j - t;
               var gA1 = j - t;
            }
            var x = cos(gD1);
            var y = sin(gD1);
            var tD1 = atan2(cl1 * (v3 * x + v4 * y) + sl1 * v5,cl1 * (v0 * x + v1 * y) + sl1 * v2);
            var x = cos(gA1);
            var y = sin(gA1);
            startX = cl1 * (v0 * x + v1 * y) + sl1 * v2;
            startY = cl1 * (v3 * x + v4 * y) + sl1 * v5;
            var tA1 = atan2(startY,startX);
         }
      }
      var A = cl2 * sqrt(v6 * v6 + v7 * v7);
      if(A == 0)
      {
         if(sl2 * v8 < 0)
         {
            var loc2 = 2;
         }
         else
         {
            var loc2 = 1;
         }
      }
      else
      {
         var sj = (- sl2) * v8 / A;
         if(sj <= -1)
         {
            var loc2 = 1;
         }
         else if(sj >= 1)
         {
            var loc2 = 2;
         }
         else
         {
            var loc2 = 0;
            var j = asin(sj);
            var t = atan2(v6,v7);
            if(cos(j) < 0)
            {
               var gD2 = j - t;
               var gA2 = 3.141592653589793 - j - t;
            }
            else
            {
               var gD2 = 3.141592653589793 - j - t;
               var gA2 = j - t;
            }
            var x = cos(gD2);
            var y = sin(gD2);
            var tD2 = atan2(cl2 * (v3 * x + v4 * y) + sl2 * v5,cl2 * (v0 * x + v1 * y) + sl2 * v2);
            var x = cos(gA2);
            var y = sin(gA2);
            if(startX == null)
            {
               startX = cl2 * (v0 * x + v1 * y) + sl2 * v2;
               startY = cl2 * (v3 * x + v4 * y) + sl2 * v5;
               var tA2 = atan2(startY,startX);
            }
            else
            {
               var tA2 = atan2(cl2 * (v3 * x + v4 * y) + sl2 * v5,cl2 * (v0 * x + v1 * y) + sl2 * v2);
            }
         }
      }
      var minStep = _loc1_._minStep;
      if(loc1 == 0 && loc2 == 0)
      {
         fmc.moveTo(startX,startY);
         _loc2_.moveTo(startX,startY);
         fbmc.moveTo(startX,startY);
         bbmc.moveTo(startX,startY);
         drawPerimeterArcs(tA1,tA2,1,fmc,_loc2_);
         drawSphericalArc(gA2,gD2,cl2,sl2,1,fmc,fbmc);
         drawSphericalArc(gA2,gD2,cl2,sl2,-1,_loc2_,bbmc);
         drawPerimeterArcs(tD2,tD1,1,fmc,_loc2_);
         drawSphericalArc(gD1,gA1,cl1,sl1,-1,fmc,fbmc);
         drawSphericalArc(gD1,gA1,cl1,sl1,1,_loc2_,bbmc);
      }
      else if(loc1 == 0 && loc2 == 1)
      {
         fmc.moveTo(startX,startY);
         _loc2_.moveTo(startX,startY);
         fbmc.moveTo(startX,startY);
         bbmc.moveTo(startX,startY);
         drawSphericalArc(gA1,gD1,cl1,sl1,1,fmc,fbmc);
         drawSphericalArc(gA1,gD1,cl1,sl1,-1,_loc2_,bbmc);
         drawPerimeterArcs(tD1,tA1,-1,fmc,_loc2_);
         if(_loc1_._type2 == 0)
         {
            drawSphericalArc(0,0,cl2,sl2,-1,fmc,fbmc);
         }
      }
      else if(loc1 == 0 && loc2 == 2)
      {
         fmc.moveTo(startX,startY);
         _loc2_.moveTo(startX,startY);
         fbmc.moveTo(startX,startY);
         bbmc.moveTo(startX,startY);
         drawSphericalArc(gA1,gD1,cl1,sl1,1,fmc,fbmc);
         drawSphericalArc(gA1,gD1,cl1,sl1,-1,_loc2_,bbmc);
         drawPerimeterArcs(tD1,tA1,-1,fmc,_loc2_);
         if(_loc1_._type2 == 0)
         {
            drawSphericalArc(0,0,cl2,sl2,1,_loc2_,bbmc);
         }
      }
      else if(loc1 == 1 && loc2 == 0)
      {
         fmc.moveTo(startX,startY);
         _loc2_.moveTo(startX,startY);
         fbmc.moveTo(startX,startY);
         bbmc.moveTo(startX,startY);
         drawSphericalArc(gA2,gD2,cl2,sl2,1,fmc,fbmc);
         drawSphericalArc(gA2,gD2,cl2,sl2,-1,_loc2_,bbmc);
         drawPerimeterArcs(tD2,tA2,1,fmc,_loc2_);
         if(_loc1_._type1 == 0)
         {
            drawSphericalArc(0,0,cl1,sl1,-1,fmc,fbmc);
         }
      }
      else if(loc1 == 1 && loc2 == 1)
      {
         if(_loc1_._type1 == 0)
         {
            drawSphericalArc(0,0,cl1,sl1,1,fmc,fbmc);
         }
         if(_loc1_._type2 == 0)
         {
            drawSphericalArc(0,0,cl2,sl2,-1,fmc,fbmc);
         }
      }
      else if(loc1 == 1 && loc2 == 2)
      {
         if(_loc1_._type1 == 0)
         {
            drawSphericalArc(0,0,cl1,sl1,1,fmc,fbmc);
         }
         if(_loc1_._type2 == 0)
         {
            drawSphericalArc(0,0,cl2,sl2,1,_loc2_,bbmc);
         }
         drawPerimeterArcs(0,0,-1,fmc,_loc2_);
      }
      else if(loc1 == 2 && loc2 == 0)
      {
         fmc.moveTo(startX,startY);
         _loc2_.moveTo(startX,startY);
         fbmc.moveTo(startX,startY);
         bbmc.moveTo(startX,startY);
         drawSphericalArc(gA2,gD2,cl2,sl2,1,fmc,fbmc);
         drawSphericalArc(gA2,gD2,cl2,sl2,-1,_loc2_,bbmc);
         drawPerimeterArcs(tD2,tA2,1,fmc,_loc2_);
         if(_loc1_._type1 == 0)
         {
            drawSphericalArc(0,0,cl1,sl1,1,_loc2_,bbmc);
         }
      }
      else if(loc1 == 2 && loc2 == 1)
      {
         if(_loc1_._type1 == 0)
         {
            drawSphericalArc(0,0,cl1,sl1,1,_loc2_,bbmc);
         }
         if(_loc1_._type2 == 0)
         {
            drawSphericalArc(0,0,cl2,sl2,1,fmc,fbmc);
         }
         drawPerimeterArcs(0,0,1,fmc,_loc2_);
      }
      else if(loc1 == 2 && loc2 == 2)
      {
         if(_loc1_._type1 == 0)
         {
            drawSphericalArc(0,0,cl1,sl1,1,_loc2_,bbmc);
         }
         if(_loc1_._type2 == 0)
         {
            drawSphericalArc(0,0,cl2,sl2,-1,_loc2_,bbmc);
         }
      }
      fmc.endFill();
      _loc2_.endFill();
   }
};
p.setParameters = function(arg)
{
   var _loc1_ = this;
   var _loc2_ = arg;
   if(_loc2_.dec1 != undefined && _loc2_.dec2 != undefined)
   {
      _loc1_._sys = 1;
      if(_loc2_.ra != undefined)
      {
         _loc1_._beta = 0.2617993877991494 * ((_loc2_.ra % 24 + 24) % 24);
      }
      else
      {
         _loc1_._beta = 0;
      }
      if(_loc2_.tilt != undefined)
      {
         if(_loc2_.tilt < 0)
         {
            _loc1_._tilt = 0;
         }
         else if(_loc2_.tilt > 180)
         {
            _loc1_._tilt = 3.141592653589793;
         }
         else
         {
            _loc1_._tilt = _loc2_.tilt * 0.017453292519943295;
         }
      }
      else
      {
         _loc1_._tilt = 0;
      }
      if(_loc2_.dec1 <= -90)
      {
         _loc1_._lambda1 = -1.5707963267948966;
         _loc1_._type1 = 1;
      }
      else if(_loc2_.dec1 >= 90)
      {
         _loc1_._lambda1 = 1.5707963267948966;
         _loc1_._type1 = 1;
      }
      else
      {
         _loc1_._lambda1 = _loc2_.dec1 * 0.017453292519943295;
         _loc1_._type1 = 0;
      }
      if(_loc2_.dec2 <= -90)
      {
         _loc1_._lambda2 = -1.5707963267948966;
         _loc1_._type2 = 1;
      }
      else if(_loc2_.dec2 >= 90)
      {
         _loc1_._lambda2 = 1.5707963267948966;
         _loc1_._type2 = 1;
      }
      else
      {
         _loc1_._lambda2 = _loc2_.dec2 * 0.017453292519943295;
         _loc1_._type2 = 0;
      }
      _loc1_._noDef = false;
   }
   else if(_loc2_.alt1 != undefined && _loc2_.alt2 != undefined)
   {
      _loc1_._sys = 0;
      if(_loc2_.az != undefined)
      {
         _loc1_._beta = 0.017453292519943295 * (((- _loc2_.az) % 360 + 360) % 360);
      }
      else
      {
         _loc1_._beta = 0;
      }
      if(_loc2_.tilt != undefined)
      {
         if(_loc2_.tilt < 0)
         {
            _loc1_._tilt = 0;
         }
         else if(_loc2_.tilt > 180)
         {
            _loc1_._tilt = 3.141592653589793;
         }
         else
         {
            _loc1_._tilt = _loc2_.tilt * 0.017453292519943295;
         }
      }
      else
      {
         _loc1_._tilt = 0;
      }
      if(_loc2_.alt1 <= -90)
      {
         _loc1_._lambda1 = -1.5707963267948966;
         _loc1_._type1 = 1;
      }
      else if(_loc2_.alt1 >= 90)
      {
         _loc1_._lambda1 = 1.5707963267948966;
         _loc1_._type1 = 1;
      }
      else
      {
         _loc1_._lambda1 = _loc2_.alt1 * 0.017453292519943295;
         _loc1_._type1 = 0;
      }
      if(_loc2_.alt2 <= -90)
      {
         _loc1_._lambda2 = -1.5707963267948966;
         _loc1_._type2 = 1;
      }
      else if(_loc2_.alt2 >= 90)
      {
         _loc1_._lambda2 = 1.5707963267948966;
         _loc1_._type2 = 1;
      }
      else
      {
         _loc1_._lambda2 = _loc2_.alt2 * 0.017453292519943295;
         _loc1_._type2 = 0;
      }
      _loc1_._noDef = false;
   }
   else
   {
      _loc1_._noDef = true;
   }
   var _loc3_;
   if(_loc1_._lambda1 > _loc1_._lambda2)
   {
      _loc3_ = _loc1_._lambda2;
      _loc1_._lambda2 = _loc1_._lambda1;
      _loc1_._lambda1 = _loc3_;
      _loc3_ = _loc1_._type2;
      _loc1_._type2 = _loc1_._type1;
      _loc1_._type1 = _loc3_;
   }
   _loc1_.doK();
};
p.doK = function()
{
   var _loc2_ = this;
   var _loc3_ = Math.sin(_loc2_._tilt);
   var ct = Math.cos(_loc2_._tilt);
   var sb = Math.sin(_loc2_._beta);
   var cb = Math.cos(_loc2_._beta);
   var _loc1_ = _loc2_._c;
   _loc1_.k0 = cb;
   _loc1_.k1 = (- sb) * ct;
   _loc1_.k2 = sb * _loc3_;
   _loc1_.k3 = sb;
   _loc1_.k4 = cb * ct;
   _loc1_.k5 = (- cb) * _loc3_;
   _loc1_.k7 = _loc3_;
   _loc1_.k8 = ct;
   _loc2_._kVer = _loc2_._kVer + 1;
};
p.setLinkageNames = function(linkageNameFront, linkageNameBack, surface, hemisphere, initObject)
{
   var _loc1_ = this;
   _loc1_._frontMC.removeMovieClip();
   _loc1_._backMC.removeMovieClip();
   if(typeof initObject != "object")
   {
      _loc1_._initObject = {};
      _loc1_._initObject._sphere = _loc1_._parent;
      _loc1_._initObject._shadedBand = _loc1_;
   }
   else
   {
      _loc1_._initObject = initObject;
      _loc1_._initObject._sphere = _loc1_._parent;
      _loc1_._initObject._shadedBand = _loc1_;
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
   var _loc2_;
   if(linkageNameFront != null)
   {
      _loc1_._initObject._side = "front";
      var mc = _loc1_._parent["_f" + _loc3_];
      _loc2_ = 0;
      while(mc["_" + _loc2_] != undefined)
      {
         _loc2_ = _loc2_ + 1;
      }
      _loc1_._frontMC = mc.createEmptyMovieClip("_" + _loc2_,_loc2_);
      _loc1_._frontMC.attachMovie(linkageNameFront,"clipMC",0,_loc1_._initObject);
      _loc1_._frontMaskMC = _loc1_._frontMC.createEmptyMovieClip("maskMC",1);
      _loc1_._frontBorderMC = _loc1_._frontMC.createEmptyMovieClip("borderMC",2);
      _loc1_._frontMC.clipMC.setMask(_loc1_._frontMC.maskMC);
   }
   else
   {
      _loc1_._frontMaskMC = null;
   }
   if(linkageNameBack != null)
   {
      _loc1_._initObject._side = "back";
      var mc = _loc1_._parent["_b" + _loc3_];
      _loc2_ = 0;
      while(mc["_" + _loc2_] != undefined)
      {
         _loc2_ = _loc2_ + 1;
      }
      _loc1_._backMC = mc.createEmptyMovieClip("_" + _loc2_,_loc2_);
      _loc1_._backMC.attachMovie(linkageNameBack,"clipMC",0,_loc1_._initObject);
      _loc1_._backMaskMC = _loc1_._backMC.createEmptyMovieClip("maskMC",1);
      _loc1_._backBorderMC = _loc1_._backMC.createEmptyMovieClip("borderMC",2);
      _loc1_._backMC.clipMC.setMask(_loc1_._backMC.maskMC);
   }
   else
   {
      _loc1_._backMaskMC = null;
   }
   _loc1_._backMC.borderMC._visible = _loc1_._showBorder;
   _loc1_._frontMC.borderMC._visible = _loc1_._showBorder;
};
p.toString = function()
{
   return String(this._parent) + "." + this._name + " (shaded band)";
};
p.remove = function()
{
   var _loc3_ = this;
   var _loc2_ = _loc3_._parent._shadedBandList;
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
   _loc3_._backMC.removeMovieClip();
   _loc3_._frontMC.removeMovieClip();
   delete _loc3_._parent[_loc3_._name];
};
p.setBorderStyle = function(t, c, a)
{
   var _loc1_ = this;
   if(t != undefined)
   {
      _loc1_._bThick = t;
   }
   if(c != undefined)
   {
      _loc1_._bColor = c;
   }
   if(a != undefined)
   {
      _loc1_._bAlpha = a;
   }
};
p.getShowBorder = function()
{
   return this._showBorder;
};
p.setShowBorder = function(arg)
{
   var _loc1_ = this;
   _loc1_._showBorder = Boolean(arg);
   _loc1_._backMC.borderMC._visible = _loc1_._showBorder;
   _loc1_._frontMC.borderMC._visible = _loc1_._showBorder;
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
