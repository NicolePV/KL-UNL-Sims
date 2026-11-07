function GeometryDiagramClass()
{
   this.attachMovie("GDSunRays","_sunRays",0);
   this.attachMovie("GDEarthSimple","_simpleEarth",10);
   this.attachMovie("GDEarthDetailed","_detailedEarth",11);
   this.attachMovie("GDShadowMask","_earthShadow",20);
   this._earthShadow.attachMovie("GDTimeTicks","_timeTicks",2);
   this.attachMovie("GDMoon","_moon",50);
   this.attachMovie("GDShadowMask","_moonShadow",55);
   this.attachMovie("GDAngleLabel","angleLabelMC",314);
   this.setEarthSize(70);
   this.setMoonSize(20);
   this._orbitRadius = 200;
   this.time = 0;
   this.phase = 0;
   this.sunLocked = false;
}
var p = GeometryDiagramClass.prototype = new MovieClip();
Object.registerClass("GeometryDiagram",GeometryDiagramClass);
p.getPhase = function()
{
   return this.mod(180 - 57.29577951308232 * this._moon.rawMoonAngle + this._sunRays._rotation,360);
};
p.setPhase = function(arg)
{
   this._moon.rawMoonAngle = 0.017453292519943295 * (180 + this._sunRays._rotation - arg);
};
p.addProperty("phase",p.getPhase,p.setPhase);
p.getTime = function()
{
   return 0.06666666666666667 * this.mod(360 - (this._detailedEarth._rotation - this._sunRays._rotation),360);
};
p.setTime = function(arg)
{
   this._detailedEarth._rotation = 360 - arg * 15 + this._sunRays._rotation;
};
p.addProperty("time",p.getTime,p.setTime);
p.setShowLunarLandmark = function(arg)
{
   this._moon.lunarLandmarkMC._visible = arg;
};
p.setShowObserver = function(arg)
{
   this._detailedEarth.observerMC._visible = arg;
};
p.setEarthSize = function(arg)
{
   this._earthShadow._xscale = this._earthShadow._yscale = this._detailedEarth._xscale = this._detailedEarth._yscale = this._simpleEarth._xscale = this._simpleEarth._yscale = arg;
};
p.setMoonSize = function(arg)
{
   this._moonShadow._xscale = this._moonShadow._yscale = this._moon._xscale = this._moon._yscale = arg;
};
p.onSunAngleChanged = function()
{
   if(this.sunLocked)
   {
      this.time = this._startTime;
      this.phase = this._startPhase;
   }
   else
   {
      this.onPhaseChanged();
      this.onTimeChanged();
   }
   this._earthShadow._rotation = this._moonShadow._rotation = this._sunRays._rotation;
};
p.onPhaseChanged = function()
{
   this._parent[this._phaseChangeHandler]();
};
p.onTimeChanged = function()
{
   this._parent[this._timeChangeHandler]();
};
p.getShowTimeTicks = function()
{
   return this._earthShadow._timeTicks._visible;
};
p.setShowTimeTicks = function(arg)
{
   this._earthShadow._timeTicks._visible = arg;
};
p.addProperty("showTimeTicks",p.getShowTimeTicks,p.setShowTimeTicks);
p.mod = function(n, m)
{
   if(n < 0)
   {
      return n % m + m;
   }
   return n % m;
};
