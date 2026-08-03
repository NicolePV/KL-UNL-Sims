function CSCirclesClass(parent, name, id, depth)
{
   this._parent = parent;
   this._name = name;
   this._id = id;
   this._depth = depth;
   this._c = new Object();
   this._gS = 0;
   this._gE = 0;
   this._beta = 0;
   this._tilt = 0;
   this._lambda = 0;
   this._sys = 0;
   this.visible = true;
   this.setCircleStyle(1,16711680,80);
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
         depth++;
      }
   }
   var id = this._circleFreeID++;
   this[name] = new CSCirclesClass(this,name,id,depth);
   this._circleList.push({id:id,name:this[name]});
   if(typeof style == "object")
   {
      this[name].setCircleStyle(style.thickness,style.color,style.alpha);
   }
   if(typeof definition == "object")
   {
      this[name].setCircleParameters(definition);
   }
};
p.updateCircles = function(notHorizon)
{
   var start = getTimer();
   if(notHorizon)
   {
      var i = 0;
      while(i < this._circleList.length)
      {
         var circle = this._circleList[i].name;
         if(!circle._sys == 0)
         {
            circle.update();
         }
         i++;
      }
   }
   else
   {
      var i = 0;
      while(i < this._circleList.length)
      {
         this._circleList[i].name.update();
         i++;
      }
   }
   trace("circles: " + (getTimer() - start) + " ms");
};
var p = CSCirclesClass.prototype = new Object();
p._nP = 10;
p._step = 6.283185307179586 / p._nP;
p._uaP = new Array();
p._ucP = new Array();
var halfStep = p._step / 2;
var cRad = 1 / Math.cos(halfStep);
var i = 0;
while(i < p._nP)
{
   var aObj = new Object();
   var aAngle = (i + 1) * p._step;
   aObj.x = Math.cos(aAngle);
   aObj.y = Math.sin(aAngle);
   p._uaP[i] = aObj;
   var cObj = new Object();
   var cAngle = aAngle - halfStep;
   cObj.x = cRad * Math.cos(cAngle);
   cObj.y = cRad * Math.sin(cAngle);
   p._ucP[i] = cObj;
   i++;
}
p.removeCircle = function()
{
   var list = this._parent._circleList;
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
   this._back.removeMovieClip();
   this._front.removeMovieClip();
   delete this;
};
p.update = function()
{
   var frontMC = this._front;
   var backMC = this._back;
   frontMC.clear();
   backMC.clear();
   if(!this.visible)
   {
      return undefined;
   }
   frontMC.lineStyle(this._thick,this._color,this._alpha);
   backMC.lineStyle(this._thick,this._color,this._alpha);
   var tc = this._c;
   var pc = this._parent._c;
   if(this._sys == 0)
   {
      var k1 = tc.w0 * pc.a6 + tc.w3 * pc.a7;
      var k2 = tc.w1 * pc.a6 + tc.w4 * pc.a7 + tc.w7 * pc.a8;
      var k3 = tc.w2 * pc.a6 + tc.w5 * pc.a7 + tc.w8 * pc.a8;
   }
   else if(this._sys == 1)
   {
      var k1 = tc.w0 * pc.b6 + tc.w3 * pc.b7;
      var k2 = tc.w1 * pc.b6 + tc.w4 * pc.b7 + tc.w7 * pc.b8;
      var k3 = tc.w2 * pc.b6 + tc.w5 * pc.b7 + tc.w8 * pc.b8;
   }
   var A = Math.sqrt(k1 * k1 + k2 * k2);
   if(A == 0)
   {
      if(k3 < 0)
      {
         this.drawArc(this._gS,this._gE,backMC);
      }
      else
      {
         this.drawArc(this._gS,this._gE,frontMC);
      }
   }
   else
   {
      var sj = (- k3) / A;
      if(sj <= -1)
      {
         this.drawArc(this._gS,this._gE,frontMC);
      }
      else if(sj >= 1)
      {
         this.drawArc(this._gS,this._gE,backMC);
      }
      else
      {
         var j = Math.asin(sj);
         var t = Math.atan2(k1,k2);
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
         if(this._gS == this._gE)
         {
            this.drawArc(gAsc,gDesc,frontMC);
            this.drawArc(gDesc,gAsc,backMC);
         }
         else
         {
            var gArray = [[gAsc,0],[gDesc,1],[this._gS,2],[this._gE,3]];
            gArray.sort(this.gSort);
            var draw = false;
            var front = true;
            var s = 0;
            while(s < 4)
            {
               if(gArray[s][1] == 0)
               {
                  front = true;
               }
               else if(gArray[s][1] == 1)
               {
                  front = false;
               }
               else if(gArray[s][1] == 2)
               {
                  draw = true;
               }
               else
               {
                  draw = false;
               }
               s++;
            }
            var g2 = gArray[3];
            var i = 0;
            while(i < 4)
            {
               g1 = g2;
               g2 = gArray[i];
               if(draw && g1[0] != g2[0])
               {
                  if(front)
                  {
                     this.drawArc(g1[0],g2[0],frontMC);
                  }
                  else
                  {
                     this.drawArc(g1[0],g2[0],backMC);
                  }
               }
               if(g2[1] == 0)
               {
                  front = true;
               }
               else if(g2[1] == 1)
               {
                  front = false;
               }
               else if(g2[1] == 2)
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
p.drawArc = function(g1, g2, mc)
{
   var start = getTimer();
   var saP = {};
   var scP = {};
   if(this._sys == 0)
   {
      this._parent._arcFunc = this._parent.WtoS;
   }
   else if(this._sys == 1)
   {
      this._parent._arcFunc = this._parent.CtoS;
   }
   if(g2 < g1)
   {
      g2 += 6.283185307179586;
   }
   var arc = g2 - g1;
   if(arc == 0)
   {
      this._parent._arcFunc(this._sP,saP);
      mc.moveTo(saP.x,saP.y);
      var nP = this._nP;
      var i = 0;
      while(i < nP)
      {
         this._parent._arcFunc(this._aP[i],saP);
         this._parent._arcFunc(this._cP[i],scP);
         mc.curveTo(scP.x,scP.y,saP.x,saP.y);
         i++;
      }
   }
   else if(arc <= this._step)
   {
      var aP = {};
      var cP = {};
      var icP = {};
      this.CGtoSYS(g1,aP);
      this._parent._arcFunc(aP,saP);
      mc.moveTo(saP.x,saP.y);
      var half = arc / 2;
      var cRad = 1 / Math.cos(half);
      icP.x = cRad * Math.cos(g1 + half);
      icP.y = cRad * Math.sin(g1 + half);
      this.CPtoSYS(icP,cP);
      this.CGtoSYS(g2,aP);
      this._parent._arcFunc(aP,saP);
      this._parent._arcFunc(cP,scP);
      mc.curveTo(scP.x,scP.y,saP.x,saP.y);
   }
   else
   {
      var nP = this._nP;
      var aP = this._aP;
      var cP = this._cP;
      var naP = {};
      var ncP = {};
      var icP = {};
      var a1 = this.mod(Math.ceil(g1 / this._step) - 1,nP);
      var a2 = this.mod(Math.floor(g2 / this._step) - 1,nP);
      var angle = (a1 + 1) * this._step - g1;
      if(angle == 0)
      {
         this._parent._arcFunc(aP[a1],saP);
         mc.moveTo(saP.x,saP.y);
      }
      else
      {
         this.CGtoSYS(g1,naP);
         this._parent._arcFunc(naP,saP);
         mc.moveTo(saP.x,saP.y);
         var half = angle / 2;
         var cRad = 1 / Math.cos(half);
         icP.x = cRad * Math.cos(g1 + half);
         icP.y = cRad * Math.sin(g1 + half);
         this.CPtoSYS(icP,ncP);
         this._parent._arcFunc(ncP,scP);
         this._parent._arcFunc(aP[a1],saP);
         mc.curveTo(scP.x,scP.y,saP.x,saP.y);
      }
      var lim = a2;
      if(lim < a1)
      {
         lim += nP;
      }
      var i = a1 + 1;
      while(i <= lim)
      {
         this._parent._arcFunc(aP[i % nP],saP);
         this._parent._arcFunc(cP[i % nP],scP);
         mc.curveTo(scP.x,scP.y,saP.x,saP.y);
         i++;
      }
      angle = g2 % 6.283185307179586 - (a2 + 1) * this._step;
      if(angle != 0)
      {
         var half = angle / 2;
         var cRad = 1 / Math.cos(half);
         icP.x = cRad * Math.cos(g2 - half);
         icP.y = cRad * Math.sin(g2 - half);
         this.CPtoSYS(icP,ncP);
         this._parent._arcFunc(ncP,scP);
         this.CGtoSYS(g2,naP);
         this._parent._arcFunc(naP,saP);
         mc.curveTo(scP.x,scP.y,saP.x,saP.y);
      }
   }
};
p.setCircleStyle = function(thickness, circleColor, alpha)
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
   if(typeof p1 == "string")
   {
      var obj = this._parent[p1];
      if(!(obj instanceof HDObjectsClass))
      {
         return false;
      }
      this._sys = obj._sys;
      if(this._sys == 0)
      {
         var theta1 = (360 - obj.az) * 0.017453292519943295;
         var phi1 = obj.alt * 0.017453292519943295;
      }
      else
      {
         if(this._sys != 1)
         {
            return false;
         }
         var theta1 = obj.ra * 0.2617993877991494;
         var phi1 = obj.dec * 0.017453292519943295;
      }
   }
   else if(p1.az != undefined && p1.alt != undefined)
   {
      this._sys = 0;
      var theta1 = (360 - p1.az) * 0.017453292519943295;
      var phi1 = p1.alt * 0.017453292519943295;
   }
   else
   {
      if(!(p1.ra != undefined && p1.dec != undefined))
      {
         return false;
      }
      this._sys = 1;
      var theta1 = p1.ra * 0.2617993877991494;
      var phi1 = p1.dec * 0.017453292519943295;
   }
   if(typeof p2 == "string")
   {
      var obj = this._parent[p2];
      if(!(obj instanceof HDObjectsClass))
      {
         return false;
      }
      if(this._sys == 0)
      {
         var theta2 = (360 - obj.az) * 0.017453292519943295;
         var phi2 = obj.alt * 0.017453292519943295;
      }
      else
      {
         if(this._sys != 1)
         {
            return false;
         }
         var theta2 = obj.ra * 0.2617993877991494;
         var phi2 = obj.dec * 0.017453292519943295;
      }
   }
   else if(p2.az != undefined && p2.alt != undefined)
   {
      if(this._sys == 0)
      {
         var theta2 = (360 - p2.az) * 0.017453292519943295;
         var phi2 = p2.alt * 0.017453292519943295;
      }
      else if(this._sys == 1)
      {
         var cp = new Object();
         this._parent.MHtoC({az:(360 - p2.az) * 0.017453292519943295,alt:p2.alt * 0.017453292519943295},cp);
         var theta2 = cp.ra;
         var phi2 = cp.dec;
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
         var hp = new Object();
         this._parent.CtoMH({ra:p2.ra * 0.2617993877991494,dec:p2.dec * 0.017453292519943295},hp);
         var theta2 = hp.az;
         var phi2 = hp.alt;
      }
      else if(this._sys == 1)
      {
         var theta2 = p2.ra * 0.2617993877991494;
         var phi2 = p2.dec * 0.017453292519943295;
      }
   }
   var cp1 = Math.cos(phi1);
   var sp1 = z1 = Math.sin(phi1);
   var x1 = cp1 * Math.cos(theta1);
   var y1 = cp1 * Math.sin(theta1);
   var cp2 = Math.cos(phi2);
   var sp2 = z2 = Math.sin(phi2);
   var x2 = cp2 * Math.cos(theta2);
   var y2 = cp2 * Math.sin(theta2);
   var ax = y1 * z2 - y2 * z1;
   var ay = x2 * z1 - x1 * z2;
   var az = x1 * y2 - x2 * y1;
   var aN = Math.sqrt(ax * ax + ay * ay + az * az);
   if(aN < 0.000001)
   {
      if(x1 == x2 && y1 == y2 && z1 == z2)
      {
         return false;
      }
      this._lambda = 0;
      this._tilt = 1.5707963267948966;
      this._beta = Math.atan2(y1,x1);
      this._gS = Math.acos(Math.sqrt(x1 * x1 + y1 * y1));
      if(z1 < 0)
      {
         this._gS = - this._gS;
      }
      this._gS = this.mod(this._gS,6.283185307179586);
      this._gE = (this._gS + 3.141592653589793) % 6.283185307179586;
      this.doW();
      this.prerender();
      return true;
   }
   this._lambda = 0;
   this._tilt = Math.acos(az / aN);
   if(this._tilt == 0)
   {
      this._beta = 0;
      this._gS = this.mod(Math.atan2(y1,x1),6.283185307179586);
      this._gE = this.mod(Math.atan2(y2,x2),6.283185307179586);
   }
   else if(this._tilt == 3.141592653589793)
   {
      this._beta = 0;
      this._gS = this.mod(Math.atan2(- y1,x1),6.283185307179586);
      this._gE = this.mod(Math.atan2(- y2,x2),6.283185307179586);
   }
   else
   {
      this._beta = Math.atan2(ax,- ay);
      var st = Math.sin(this._tilt);
      this._gS = this.mod(Math.atan2(sp1 / st,cp1 * Math.cos(theta1 - this._beta)),6.283185307179586);
      this._gE = this.mod(Math.atan2(sp2 / st,cp2 * Math.cos(theta2 - this._beta)),6.283185307179586);
   }
   this.doW();
   this.prerender();
   return true;
};
p.setCircleParameters = function(arg)
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
   this.prerender();
};
p.mod = function(n, m)
{
   return (n % m + m) % m;
};
p.prerender = function()
{
   this._aP = new Array();
   this._cP = new Array();
   var i = 0;
   while(i < this._nP)
   {
      var aP = new Object();
      var cP = new Object();
      this.CPtoSYS(this._uaP[i],aP);
      this.CPtoSYS(this._ucP[i],cP);
      this._aP[i] = aP;
      this._cP[i] = cP;
      i++;
   }
   this._sP = {x:this._aP[this._nP - 1].x,y:this._aP[this._nP - 1].y,z:this._aP[this._nP - 1].z};
};
p.CPtoSYS = function(cp, sys)
{
   var c = this._c;
   sys.x = cp.x * c.w0 + cp.y * c.w1 + c.w2;
   sys.y = cp.x * c.w3 + cp.y * c.w4 + c.w5;
   sys.z = cp.y * c.w7 + c.w8;
};
p.CGtoSYS = function(g, sys)
{
   var x = Math.cos(g);
   var y = Math.sin(g);
   var c = this._c;
   sys.x = x * c.w0 + y * c.w1 + c.w2;
   sys.y = x * c.w3 + y * c.w4 + c.w5;
   sys.z = y * c.w7 + c.w8;
};
p.doW = function()
{
   var st = Math.sin(this._tilt);
   var ct = Math.cos(this._tilt);
   var sb = Math.sin(this._beta);
   var cb = Math.cos(this._beta);
   var cl = Math.cos(this._lambda);
   var sl = Math.sin(this._lambda);
   var c = this._c;
   c.w0 = cl * cb;
   c.w1 = (- cl) * sb * ct;
   c.w2 = sl * sb * st;
   c.w3 = cl * sb;
   c.w4 = cl * cb * ct;
   c.w5 = (- sl) * cb * st;
   c.w7 = cl * st;
   c.w8 = sl * ct;
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
      this.prerender();
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
      this.prerender();
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
      this.prerender();
      return true;
   }
};
p.getAz = function()
{
   return this.mod(- this.beta,360);
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
   return this.beta / 15;
};
p.setRa = function(arg)
{
   if(this.setBeta(15 * arg))
   {
      this._sys = 1;
   }
};
p.addProperty("gammaStart",p.getGammaStart,p.setGammaStart);
p.addProperty("gammaEnd",p.getGammaEnd,p.setGammaEnd);
p.addProperty("tilt",p.getTilt,p.setTilt);
p.addProperty("alt",p.getLambda,p.setAlt);
p.addProperty("dec",p.getLambda,p.setDec);
p.addProperty("az",p.getAz,p.setAz);
p.addProperty("ra",p.getRa,p.setRa);
