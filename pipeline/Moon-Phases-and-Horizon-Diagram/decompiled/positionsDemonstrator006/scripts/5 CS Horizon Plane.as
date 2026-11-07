var p = CelestialSphereClass.prototype;
p.addHorizonPlaneClip = function(linkageName, name, side, depth, initObject)
{
   if(side == "below")
   {
      var mc = this._hP._below;
   }
   else
   {
      var mc = this._hP._above;
   }
   if(typeof depth != "number")
   {
      var depth = 0;
      while(mc["_" + depth] != undefined)
      {
         depth++;
      }
   }
   if(depth < 0)
   {
      var intName = "__" + Math.abs(depth);
   }
   else
   {
      var intName = "_" + depth;
   }
   this[name] = mc.attachMovie(linkageName,intName,depth,initObject);
   return this[name];
};
p.updateHorizonPlane = function()
{
   this._hP._xscale = this._c.r;
   this._hP._yscale = this._c.r * Math.sin(this._phi);
   if(this._phi > 0)
   {
      this._hP._below._visible = false;
      this._hP._above._visible = true;
      this._hP._above._rotation = 180 + this._theta * 57.29577951308232;
   }
   else
   {
      this._hP._above._visible = false;
      this._hP._below._visible = true;
      this._hP._below._rotation = 180 + this._theta * 57.29577951308232;
   }
};
p.getShowHPlane = function()
{
   return this._hP._visible;
};
p.setShowHPlane = function(arg)
{
   arg = Boolean(arg);
   if(arg && !this._hP._visible)
   {
      this.updateHorizonPlane();
   }
   this._hP._visible = arg;
};
p.addProperty("showHorizonPlane",p.getShowHPlane,p.setShowHPlane);
