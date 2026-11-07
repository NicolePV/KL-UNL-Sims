function CelestialSphereClass()
{
   this._c = new Object();
   this._objectFreeID = 0;
   this._objectList = [];
   this._circleFreeID = 0;
   this._circleList = [];
   this._lineFreeID = 0;
   this._lineList = [];
   this._maxPhi = 90;
   this._minPhi = -90;
   this._c.r = 150;
   this._c.r2 = this._c.r * this._c.r;
   this._showUnder = true;
   this._phi = 0.5235987755982988;
   var N = this._N;
   this.createEmptyMovieClip("_bEL",-1);
   this.createEmptyMovieClip("_bOSB",N - 5);
   this.createEmptyMovieClip("_bOSA",N - 4);
   this.createEmptyMovieClip("_bOSF",N - 3);
   this.createEmptyMovieClip("_bF",N - 2);
   this.createEmptyMovieClip("_bC",N - 1);
   this.createEmptyMovieClip("_bISB",2 * N - 4);
   this.createEmptyMovieClip("_bISA",2 * N - 3);
   this.createEmptyMovieClip("_bISF",2 * N - 2);
   this.createEmptyMovieClip("_iLB",2 * N - 1);
   this.createEmptyMovieClip("_hP",3 * N - 2);
   this.createEmptyMovieClip("_iLA",3 * N - 1);
   this.createEmptyMovieClip("_fISB",4 * N - 5);
   this.createEmptyMovieClip("_fISA",4 * N - 4);
   this.createEmptyMovieClip("_fISF",4 * N - 3);
   this.createEmptyMovieClip("_fF",4 * N - 2);
   this.createEmptyMovieClip("_fC",4 * N - 1);
   this.createEmptyMovieClip("_fOSB",5 * N - 4);
   this.createEmptyMovieClip("_fOSA",5 * N - 3);
   this.createEmptyMovieClip("_fOSF",5 * N - 2);
   this.createEmptyMovieClip("_fEL",5 * N - 1);
   this._hP.createEmptyMovieClip("_below",0);
   this._hP.createEmptyMovieClip("_above",1);
   this.setThetaAndPhi(90,30);
   this.setLatitude(41);
   this.setSiderealTime(0);
   this.createMasks();
   this.addObject("experi sun","_sunObject",{ra:0,dec:0});
   this._day = 0;
   this.addHorizonPlaneClip("CSAboveHorizonPlane","aboveHorizonPlane","above",0);
   this.addHorizonPlaneClip("CSBelowHorizonPlane","belowHorizonPlane","below",0);
   this.addShadingClip("CSGradientDisk","celestialBowl","front","inner","both",{innerAlpha:0,innerColor:16777215,outerAlpha:20,outerColor:0});
   this.setMouseBehavior("simple drag");
   this.sortObjects = true;
   this.update();
}
var p = CelestialSphereClass.prototype = new MovieClip();
Object.registerClass("CelestialSphere",CelestialSphereClass);
p._N = 2000;
p._nP = 10;
p._step = 6.283185307179586 / p._nP;
p._aP = new Array();
p._cP = new Array();
var halfStep = p._step / 2;
var cRad = 100 / Math.cos(halfStep);
var i = 0;
while(i < p._nP)
{
   var aObj = new Object();
   var aAngle = (i + 1) * p._step;
   aObj.x = 100 * Math.cos(aAngle);
   aObj.y = -100 * Math.sin(aAngle);
   p._aP[i] = aObj;
   var cObj = new Object();
   var cAngle = aAngle - halfStep;
   cObj.x = cRad * Math.cos(cAngle);
   cObj.y = (- cRad) * Math.sin(cAngle);
   p._cP[i] = cObj;
   i++;
}
p._sP = {x:p._aP[p._nP - 1].x,y:p._aP[p._nP - 1].y};
p.update = function()
{
   this.updateMasks(true);
   this.updateShading();
   this.updateHorizonPlane();
   this.updateObjects();
   this.updateCircles();
   this.updateLines();
};
p.mod = function(n, m)
{
   if(n < 0)
   {
      return n % m + m;
   }
   return n % m;
};
p.parsePointInput = function(p1, p2)
{
   if(p1.az != undefined && p1.alt != undefined)
   {
      p2.sys = 0;
      var r = 1;
      if(p1.r != undefined)
      {
         r = p1.r;
      }
      var d = r * Math.cos(p1.alt * 0.017453292519943295);
      p2.x = d * Math.cos(p1.az * 0.017453292519943295);
      p2.y = d * Math.sin((- p1.az) * 0.017453292519943295);
      p2.z = r * Math.sin(p1.alt * 0.017453292519943295);
      p2.r = Math.abs(r);
   }
   else if(p1.ra != undefined && p1.dec != undefined)
   {
      p2.sys = 1;
      var r = 1;
      if(p1.r != undefined)
      {
         r = p1.r;
      }
      var d = r * Math.cos(p1.dec * 0.017453292519943295);
      p2.x = d * Math.cos(p1.ra * 0.2617993877991494);
      p2.y = d * Math.sin(p1.ra * 0.2617993877991494);
      p2.z = r * Math.sin(p1.dec * 0.017453292519943295);
      p2.r = Math.abs(r);
   }
   else if(p1.x != undefined && p1.y != undefined && p1.z != undefined)
   {
      if(p1.system == "horizon")
      {
         p2.sys = 0;
      }
      else if(p1.system == "celestial")
      {
         p2.sys = 1;
      }
      else
      {
         p2.sys = -1;
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
      p2.x = null;
      p2.y = null;
      p2.z = null;
      p2.r = null;
   }
};
