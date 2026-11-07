function SimpOrbSysClass()
{
   this.createEmptyMovieClip("axes_mc",20);
   this.createEmptyMovieClip("pathBackBack_mc",-10);
   this.createEmptyMovieClip("pathFrontFront_mc",10);
   this.attachMovie(this.primaryLinkage,"primary_mc",0);
   this.attachMovie(this.secondaryLinkage,"secondary_mc",-5);
   this._o = new Object();
   this._phi = 0;
   this._theta = 0;
   this._scale = 250;
   this.precomp();
   this._showPath = true;
   this.setInclination(this.initInclination);
   this.setSecondaryAngle(0);
   this.update();
}
var p = SimpOrbSysClass.prototype = new MovieClip();
Object.registerClass("SimpOrbSys",SimpOrbSysClass);
p._nP = 12;
p._hnP = Math.ceil(p._nP / 2);
p.update = function()
{
   var x = Math.cos(this._sa);
   var y = Math.sin(this._sa);
   var o = this._o;
   var sx = x * o.r1 + y * o.r2;
   var sy = x * o.r4 + y * o.r5;
   var sz = x * o.r7 + y * o.r8;
   this.secondary_mc._x = sx;
   this.secondary_mc._y = sy;
   if(sz > 0)
   {
      this.secondary_mc.swapDepths(15);
   }
   else
   {
      this.secondary_mc.swapDepths(-5);
   }
   this._parent.updateZoomWindow(sx,sy,sz);
};
p.setInclination = function(arg)
{
   if(isFinite(arg))
   {
      this._incl = 0.017453292519943295 * this.mod(arg,360);
      this.precomp();
      this.update();
   }
};
p.getSecondaryAngle = function()
{
   return this._sa * 57.29577951308232;
};
p.setSecondaryAngle = function(arg)
{
   if(isFinite(arg))
   {
      this._sa = 0.017453292519943295 * this.mod(arg,360);
      this.update();
   }
};
p.mod = function(n, m)
{
   if(n < 0)
   {
      return n % m + m;
   }
   return n % m;
};
p.project = function(wp)
{
   var sp = new Object();
   var o = this._o;
   sp.x = wp.x * o.k1 + wp.y * o.k2;
   sp.y = wp.x * o.k4 + wp.y * o.k5 + wp.z * o.k6;
   sp.z = wp.x * o.k7 + wp.y * o.k8 + wp.z * o.k9;
   return sp;
};
p.precomp = function()
{
   var cos = Math.cos;
   var sin = Math.sin;
   var st = sin(this._theta);
   var ct = cos(this._theta);
   var sp = sin(this._phi);
   var cp = cos(this._phi);
   var si = sin(this._incl);
   var ci = cos(this._incl);
   var s = this._scale;
   var o = this._o;
   o.k1 = (- s) * st;
   o.k2 = s * ct;
   o.k3 = 0;
   o.k4 = s * sp * ct;
   o.k5 = s * sp * st;
   o.k6 = (- s) * cp;
   o.k7 = s * cp * ct;
   o.k8 = s * cp * st;
   o.k9 = s * sp;
   o.r1 = (- s) * st;
   o.r2 = s * ct * ci;
   o.r3 = (- s) * ct * si;
   o.r4 = s * sp * ct;
   o.r5 = s * (sp * st * ci - cp * si);
   o.r6 = (- s) * (sp * st * si + cp * ci);
   o.r7 = s * cp * ct;
   o.r8 = s * (cp * st * ci + sp * si);
   o.r9 = s * (cp * st * si + sp * ci);
   if(this._showPath)
   {
      this.drawPath();
   }
};
p.drawPath = function()
{
   var o = this._o;
   var cos = Math.cos;
   var sin = Math.sin;
   var st = sin(this._theta);
   var ct = cos(this._theta);
   var sp = sin(this._phi);
   var cp = cos(this._phi);
   var si = sin(this._incl);
   var ci = cos(this._incl);
   var x = cp * ct;
   var y = cp * st;
   var z = sp;
   var x2 = x;
   var y2 = y * ci + z * si;
   var g = Math.atan2(y2,x2);
   var backStart = this.mod(g + 1.5707963267948966,6.283185307179586);
   var frontStart = this.mod(g - 1.5707963267948966,6.283185307179586);
   var baP = new Array();
   var bcP = new Array();
   var faP = new Array();
   var fcP = new Array();
   var n = this._hnP;
   var step = 3.141592653589793 / (n - 1);
   var halfStep = step / 2;
   var cRad = 1 / cos(halfStep);
   var tx;
   var ty;
   var faAngle;
   var fcAngle;
   var baAngle;
   var bcAngle;
   var i = 0;
   while(i < n)
   {
      var faObj = new Object();
      faAngle = frontStart + i * step;
      tx = cos(faAngle);
      ty = sin(faAngle);
      faObj.x = tx * o.r1 + ty * o.r2;
      faObj.y = tx * o.r4 + ty * o.r5;
      faP[i] = faObj;
      var fcObj = new Object();
      fcAngle = faAngle - halfStep;
      tx = cRad * cos(fcAngle);
      ty = cRad * sin(fcAngle);
      fcObj.x = tx * o.r1 + ty * o.r2;
      fcObj.y = tx * o.r4 + ty * o.r5;
      fcP[i] = fcObj;
      var baObj = new Object();
      baAngle = backStart + i * step;
      tx = cos(baAngle);
      ty = sin(baAngle);
      baObj.x = tx * o.r1 + ty * o.r2;
      baObj.y = tx * o.r4 + ty * o.r5;
      baP[i] = baObj;
      var bcObj = new Object();
      bcAngle = baAngle - halfStep;
      tx = cRad * cos(bcAngle);
      ty = cRad * sin(bcAngle);
      bcObj.x = tx * o.r1 + ty * o.r2;
      bcObj.y = tx * o.r4 + ty * o.r5;
      bcP[i] = bcObj;
      i++;
   }
   var bb_mc = this.pathBackBack_mc;
   var ff_mc = this.pathFrontFront_mc;
   bb_mc.clear();
   ff_mc.clear();
   bb_mc.lineStyle(0,0,10);
   ff_mc.lineStyle(0,0,30);
   bb_mc.moveTo(baP[0].x,baP[0].y);
   ff_mc.moveTo(faP[0].x,faP[0].y);
   var i = 1;
   while(i < n)
   {
      bb_mc.curveTo(bcP[i].x,bcP[i].y,baP[i].x,baP[i].y);
      ff_mc.curveTo(fcP[i].x,fcP[i].y,faP[i].x,faP[i].y);
      i++;
   }
};
p.setRadius = function(arg)
{
   if(isFinite(arg) && arg > 0)
   {
      this._scale = arg;
      this.precomp();
      this.update();
   }
};
p.getTheta = function()
{
   return 57.29577951308232 * this._theta;
};
p.setTheta = function(arg)
{
   if(isFinite(arg))
   {
      this._theta = 0.017453292519943295 * this.mod(arg,360);
      this.precomp();
      this.update();
   }
};
p.getPhi = function()
{
   return 57.29577951308232 * this._phi;
};
p.setPhi = function(arg)
{
   if(isFinite(arg))
   {
      if(arg > 90)
      {
         arg = 90;
      }
      else if(arg < -90)
      {
         arg = -90;
      }
      this._phi = arg * 0.017453292519943295;
      this.precomp();
      this.update();
   }
};
p.getShowPath = function()
{
   return this._showPath;
};
p.setShowPath = function(arg)
{
   this._showPath = Boolean(arg);
   if(this._showPath)
   {
      this.drawPath();
   }
   else
   {
      this.pathBackBack_mc.clear();
      this.pathFrontFront_mc.clear();
   }
};
p.getBodyScaleFactor = function()
{
   return this.primary_mc._xscale / 100;
};
p.setBodyScaleFactor = function(arg)
{
   this.primary_mc._xscale = this.primary_mc._yscale = this.secondary_mc._xscale = this.secondary_mc._yscale = arg * 100;
};
p.addProperty("secondaryAngle",p.getSecondaryAngle,p.setSecondaryAngle);
p.addProperty("theta",p.getTheta,p.setTheta);
p.addProperty("phi",p.getPhi,p.setPhi);
p.addProperty("showPath",p.getShowPath,p.setShowPath);
p.addProperty("bodyScaleFactor",p.getBodyScaleFactor,p.setBodyScaleFactor);
