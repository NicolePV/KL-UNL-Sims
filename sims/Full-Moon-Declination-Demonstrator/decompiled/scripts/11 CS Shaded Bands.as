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
   var id = this._shadedBandFreeID++;
   this[name] = new CSShadedBandClass(this,name,id,linkageNameFront,linkageNameBack,parameters,surface,hemisphere,initObject);
   this._shadedBandList.push({id:id,name:this[name]});
   return this[name];
};
p.updateShadedBands = function(notHorizon)
{
   var start = getTimer();
   var list = this._shadedBandList;
   if(notHorizon)
   {
      var i = 0;
      while(i < list.length)
      {
         var band = list[i].name;
         if(band._sys != 0)
         {
            band.update();
         }
         i++;
      }
   }
   else
   {
      var i = 0;
      while(i < list.length)
      {
         list[i].name.update();
         i++;
      }
   }
   if(this._traceOn)
   {
      trace("shaded bands: " + (getTimer() - start) + " ms");
   }
};
p.showShadedBands = function()
{
   var list = this._shadedBandList;
   var i = 0;
   while(i < list.length)
   {
      list[i].name.visible = true;
      i++;
   }
};
p.hideShadedBands = function()
{
   var list = this._shadedBandList;
   var i = 0;
   while(i < list.length)
   {
      list[i].name.visible = false;
      i++;
   }
};
p.removeShadedBands = function()
{
   var list = this._shadedBandList;
   var i = 0;
   while(i < list.length)
   {
      list[i].name._frontMC.removeMovieClip();
      list[i].name._backMC.removeMovieClip();
      delete this[list[i].name._name];
      i++;
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
      if(doMoveTo)
      {
         var ax = 100 * cos(t1);
         var ay = 100 * sin(t1);
         mc1.moveTo(ax,ay);
         mc2.moveTo(ax,ay);
      }
      var aAngle = t1 + step;
      var cAngle = aAngle - halfStep;
      var i = 0;
      while(i < n)
      {
         var ax = 100 * cos(aAngle);
         var ay = 100 * sin(aAngle);
         var cx = cr * cos(cAngle);
         var cy = cr * sin(cAngle);
         mc1.curveTo(cx,cy,ax,ay);
         mc2.curveTo(cx,cy,ax,ay);
         aAngle += step;
         cAngle += step;
         i++;
      }
   }
   function drawSphericalArc(g1, g2, cl, sl, dir, mc, bmc)
   {
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
      var ax = cl * (v0 * iax + v1 * iay) + sl * v2;
      var ay = cl * (v3 * iax + v4 * iay) + sl * v5;
      if(doMoveTo)
      {
         mc.moveTo(ax,ay);
      }
      bmc.moveTo(ax,ay);
      var aAngle = g1 + step;
      var cAngle = aAngle - halfStep;
      var i = 0;
      while(i < n)
      {
         var iax = cos(aAngle);
         var iay = sin(aAngle);
         var icx = cRad * cos(cAngle);
         var icy = cRad * sin(cAngle);
         var ax = cl * (v0 * iax + v1 * iay) + sl * v2;
         var ay = cl * (v3 * iax + v4 * iay) + sl * v5;
         var cx = cl * (v0 * icx + v1 * icy) + sl * v2;
         var cy = cl * (v3 * icx + v4 * icy) + sl * v5;
         mc.curveTo(cx,cy,ax,ay);
         bmc.curveTo(cx,cy,ax,ay);
         aAngle += step;
         cAngle += step;
         i++;
      }
   }
   var fmc = this._frontMaskMC;
   var bmc = this._backMaskMC;
   var fbmc = this._frontBorderMC;
   var bbmc = this._backBorderMC;
   fmc.clear();
   bmc.clear();
   fbmc.clear();
   bbmc.clear();
   if(!this._visible || this._noDef)
   {
      return undefined;
   }
   fmc.beginFill(16711680);
   bmc.beginFill(255);
   fbmc.lineStyle(this._bThick,this._bColor,this._bAlpha);
   bbmc.lineStyle(this._bThick,this._bColor,this._bAlpha);
   var cos = Math.cos;
   var sin = Math.sin;
   var asin = Math.asin;
   var atan2 = Math.atan2;
   var sqrt = Math.sqrt;
   var cl1 = cos(this._lambda1);
   var sl1 = sin(this._lambda1);
   var cl2 = cos(this._lambda2);
   var sl2 = sin(this._lambda2);
   if(this._sys == 0 && (this._kLastVer != this._kVer || this._aLastVer != this._parent._aVer))
   {
      var tc = this._c;
      var pc = this._parent._c;
      var s = 100 / this._parent._c.r;
      var v0 = tc.v0 = s * (pc.a0 * tc.k0 + pc.a1 * tc.k3);
      var v1 = tc.v1 = s * (pc.a0 * tc.k1 + pc.a1 * tc.k4);
      var v2 = tc.v2 = s * (pc.a0 * tc.k2 + pc.a1 * tc.k5);
      var v3 = tc.v3 = s * (pc.a3 * tc.k0 + pc.a4 * tc.k3);
      var v4 = tc.v4 = s * (pc.a3 * tc.k1 + pc.a4 * tc.k4 + pc.a5 * tc.k7);
      var v5 = tc.v5 = s * (pc.a3 * tc.k2 + pc.a4 * tc.k5 + pc.a5 * tc.k8);
      var v6 = tc.v6 = s * (pc.a6 * tc.k0 + pc.a7 * tc.k3);
      var v7 = tc.v7 = s * (pc.a6 * tc.k1 + pc.a7 * tc.k4 + pc.a8 * tc.k7);
      var v8 = tc.v8 = s * (pc.a6 * tc.k2 + pc.a7 * tc.k5 + pc.a8 * tc.k8);
      this._kLastVer = this._kVer;
      this._aLastVer = this._parent._aVer;
   }
   else if(this._sys == 1 && (this._kLastVer != this._kVer || this._bLastVer != this._parent._bVer))
   {
      var tc = this._c;
      var pc = this._parent._c;
      var s = 100 / this._parent._c.r;
      var v0 = tc.v0 = s * (pc.b0 * tc.k0 + pc.b1 * tc.k3);
      var v1 = tc.v1 = s * (pc.b0 * tc.k1 + pc.b1 * tc.k4 + pc.b2 * tc.k7);
      var v2 = tc.v2 = s * (pc.b0 * tc.k2 + pc.b1 * tc.k5 + pc.b2 * tc.k8);
      var v3 = tc.v3 = s * (pc.b3 * tc.k0 + pc.b4 * tc.k3);
      var v4 = tc.v4 = s * (pc.b3 * tc.k1 + pc.b4 * tc.k4 + pc.b5 * tc.k7);
      var v5 = tc.v5 = s * (pc.b3 * tc.k2 + pc.b4 * tc.k5 + pc.b5 * tc.k8);
      var v6 = tc.v6 = s * (pc.b6 * tc.k0 + pc.b7 * tc.k3);
      var v7 = tc.v7 = s * (pc.b6 * tc.k1 + pc.b7 * tc.k4 + pc.b8 * tc.k7);
      var v8 = tc.v8 = s * (pc.b6 * tc.k2 + pc.b7 * tc.k5 + pc.b8 * tc.k8);
      this._kLastVer = this._kVer;
      this._bLastVer = this._parent._bVer;
   }
   else
   {
      var c = this._c;
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
   var minStep = this._minStep;
   if(loc1 == 0 && loc2 == 0)
   {
      fmc.moveTo(startX,startY);
      bmc.moveTo(startX,startY);
      fbmc.moveTo(startX,startY);
      bbmc.moveTo(startX,startY);
      drawPerimeterArcs(tA1,tA2,1,fmc,bmc);
      drawSphericalArc(gA2,gD2,cl2,sl2,1,fmc,fbmc);
      drawSphericalArc(gA2,gD2,cl2,sl2,-1,bmc,bbmc);
      drawPerimeterArcs(tD2,tD1,1,fmc,bmc);
      drawSphericalArc(gD1,gA1,cl1,sl1,-1,fmc,fbmc);
      drawSphericalArc(gD1,gA1,cl1,sl1,1,bmc,bbmc);
   }
   else if(loc1 == 0 && loc2 == 1)
   {
      fmc.moveTo(startX,startY);
      bmc.moveTo(startX,startY);
      fbmc.moveTo(startX,startY);
      bbmc.moveTo(startX,startY);
      drawSphericalArc(gA1,gD1,cl1,sl1,1,fmc,fbmc);
      drawSphericalArc(gA1,gD1,cl1,sl1,-1,bmc,bbmc);
      drawPerimeterArcs(tD1,tA1,-1,fmc,bmc);
      if(this._type2 == 0)
      {
         drawSphericalArc(0,0,cl2,sl2,-1,fmc,fbmc);
      }
   }
   else if(loc1 == 0 && loc2 == 2)
   {
      fmc.moveTo(startX,startY);
      bmc.moveTo(startX,startY);
      fbmc.moveTo(startX,startY);
      bbmc.moveTo(startX,startY);
      drawSphericalArc(gA1,gD1,cl1,sl1,1,fmc,fbmc);
      drawSphericalArc(gA1,gD1,cl1,sl1,-1,bmc,bbmc);
      drawPerimeterArcs(tD1,tA1,-1,fmc,bmc);
      if(this._type2 == 0)
      {
         drawSphericalArc(0,0,cl2,sl2,1,bmc,bbmc);
      }
   }
   else if(loc1 == 1 && loc2 == 0)
   {
      fmc.moveTo(startX,startY);
      bmc.moveTo(startX,startY);
      fbmc.moveTo(startX,startY);
      bbmc.moveTo(startX,startY);
      drawSphericalArc(gA2,gD2,cl2,sl2,1,fmc,fbmc);
      drawSphericalArc(gA2,gD2,cl2,sl2,-1,bmc,bbmc);
      drawPerimeterArcs(tD2,tA2,1,fmc,bmc);
      if(this._type1 == 0)
      {
         drawSphericalArc(0,0,cl1,sl1,-1,fmc,fbmc);
      }
   }
   else if(loc1 == 1 && loc2 == 1)
   {
      if(this._type1 == 0)
      {
         drawSphericalArc(0,0,cl1,sl1,1,fmc,fbmc);
      }
      if(this._type2 == 0)
      {
         drawSphericalArc(0,0,cl2,sl2,-1,fmc,fbmc);
      }
   }
   else if(loc1 == 1 && loc2 == 2)
   {
      if(this._type1 == 0)
      {
         drawSphericalArc(0,0,cl1,sl1,1,fmc,fbmc);
      }
      if(this._type2 == 0)
      {
         drawSphericalArc(0,0,cl2,sl2,1,bmc,bbmc);
      }
      drawPerimeterArcs(0,0,-1,fmc,bmc);
   }
   else if(loc1 == 2 && loc2 == 0)
   {
      fmc.moveTo(startX,startY);
      bmc.moveTo(startX,startY);
      fbmc.moveTo(startX,startY);
      bbmc.moveTo(startX,startY);
      drawSphericalArc(gA2,gD2,cl2,sl2,1,fmc,fbmc);
      drawSphericalArc(gA2,gD2,cl2,sl2,-1,bmc,bbmc);
      drawPerimeterArcs(tD2,tA2,1,fmc,bmc);
      if(this._type1 == 0)
      {
         drawSphericalArc(0,0,cl1,sl1,1,bmc,bbmc);
      }
   }
   else if(loc1 == 2 && loc2 == 1)
   {
      if(this._type1 == 0)
      {
         drawSphericalArc(0,0,cl1,sl1,1,bmc,bbmc);
      }
      if(this._type2 == 0)
      {
         drawSphericalArc(0,0,cl2,sl2,1,fmc,fbmc);
      }
      drawPerimeterArcs(0,0,1,fmc,bmc);
   }
   else if(loc1 == 2 && loc2 == 2)
   {
      if(this._type1 == 0)
      {
         drawSphericalArc(0,0,cl1,sl1,1,bmc,bbmc);
      }
      if(this._type2 == 0)
      {
         drawSphericalArc(0,0,cl2,sl2,-1,bmc,bbmc);
      }
   }
   fmc.endFill();
   bmc.endFill();
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
   if(this._lambda1 > this._lambda2)
   {
      var tmp = this._lambda2;
      this._lambda2 = this._lambda1;
      this._lambda1 = tmp;
      var tmp = this._type2;
      this._type2 = this._type1;
      this._type1 = tmp;
   }
   this.doK();
};
p.doK = function()
{
   var st = Math.sin(this._tilt);
   var ct = Math.cos(this._tilt);
   var sb = Math.sin(this._beta);
   var cb = Math.cos(this._beta);
   var c = this._c;
   c.k0 = cb;
   c.k1 = (- sb) * ct;
   c.k2 = sb * st;
   c.k3 = sb;
   c.k4 = cb * ct;
   c.k5 = (- cb) * st;
   c.k7 = st;
   c.k8 = ct;
   this._kVer++;
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
   var layer = "";
   if(surface == "inner")
   {
      layer += "I";
   }
   else
   {
      layer += "O";
   }
   layer += "S";
   if(hemisphere == "below")
   {
      layer += "B";
   }
   else if(hemisphere == "above")
   {
      layer += "A";
   }
   else
   {
      layer += "F";
   }
   if(linkageNameFront != null)
   {
      this._initObject._side = "front";
      var mc = this._parent["_f" + layer];
      var depth = 0;
      while(mc["_" + depth] != undefined)
      {
         depth++;
      }
      this._frontMC = mc.createEmptyMovieClip("_" + depth,depth);
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
      var mc = this._parent["_b" + layer];
      var depth = 0;
      while(mc["_" + depth] != undefined)
      {
         depth++;
      }
      this._backMC = mc.createEmptyMovieClip("_" + depth,depth);
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
   var list = this._parent._shadedBandList;
   var i = 0;
   while(i < list.length)
   {
      if(list[i].id == this._id)
      {
         break;
      }
      i++;
   }
   list.splice(i,1);
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
