var p = CelestialSphereClass.prototype;
p.addHorizonPlaneClip = function(linkageName, name, side, depth, initObject)
{
   var _loc3_;
   if(side == "below")
   {
      _loc3_ = this._hP._below;
   }
   else
   {
      _loc3_ = this._hP._above;
   }
   if(typeof depth != "number")
   {
      depth = 0;
      while(_loc3_["_" + depth] != undefined)
      {
         depth = depth + 1;
      }
   }
   var _loc4_;
   if(depth < 0)
   {
      _loc4_ = "__" + Math.abs(depth);
   }
   else
   {
      _loc4_ = "_" + depth;
   }
   this[name] = _loc3_.attachMovie(linkageName,_loc4_,depth,initObject);
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
