var p = CelestialSphereClass.prototype;
p.addHorizonPlaneClip = function(linkageName, name, side, depth, initObject)
{
   var _loc1_ = depth;
   var _loc3_ = this;
   var _loc2_;
   if(side == "below")
   {
      _loc2_ = _loc3_._hP._below;
   }
   else
   {
      _loc2_ = _loc3_._hP._above;
   }
   if(typeof _loc1_ != "number")
   {
      _loc1_ = 0;
      while(_loc2_["_" + _loc1_] != undefined)
      {
         _loc1_ = _loc1_ + 1;
      }
   }
   if(_loc1_ < 0)
   {
      var intName = "__" + Math.abs(_loc1_);
   }
   else
   {
      var intName = "_" + _loc1_;
   }
   _loc3_[name] = _loc2_.attachMovie(linkageName,intName,_loc1_,initObject);
   return _loc3_[name];
};
p.updateHorizonPlane = function()
{
   var _loc1_ = this;
   _loc1_._hp._xscale = _loc1_._c.r;
   _loc1_._hp._yscale = _loc1_._c.r * Math.sin(_loc1_._phi);
   if(_loc1_._phi > 0)
   {
      _loc1_._hp._below._visible = false;
      _loc1_._hp._above._visible = true;
      _loc1_._hp._above._rotation = 180 + _loc1_._theta * 57.29577951308232;
   }
   else
   {
      _loc1_._hp._above._visible = false;
      _loc1_._hp._below._visible = true;
      _loc1_._hp._below._rotation = 180 + _loc1_._theta * 57.29577951308232;
   }
};
p.getShowHPlane = function()
{
   return this._hp._visible;
};
p.setShowHPlane = function(arg)
{
   var _loc1_ = arg;
   var _loc2_ = this;
   _loc1_ = Boolean(_loc1_);
   if(_loc1_ && !_loc2_._hp._visible)
   {
      _loc2_.updateHorizonPlane();
   }
   _loc2_._hp._visible = _loc1_;
};
p.addProperty("showHorizonPlane",p.getShowHPlane,p.setShowHPlane);
