var p = CelestialSphereClass.prototype;
p.setThetaAndPhi = function(newTheta, newPhi)
{
   var _loc1_ = this;
   var _loc2_ = newPhi;
   _loc1_._theta = 0.017453292519943295 * ((newTheta % 360 + 360) % 360);
   if(_loc2_ > _loc1_._maxPhi)
   {
      _loc2_ = _loc1_._maxPhi;
   }
   else if(_loc2_ < _loc1_._minPhi)
   {
      _loc2_ = _loc1_._minPhi;
   }
   _loc1_._phi = _loc2_ * 0.017453292519943295;
   if(_loc1_._phi < 0)
   {
      _loc1_._iLA.swapDepths(3 * _loc1_._N - 2);
   }
   else
   {
      _loc1_._iLA.swapDepths(4 * _loc1_._N - 6);
   }
   _loc1_.doA();
   _loc1_.doB();
   _loc1_.updateMasks(true);
   _loc1_.updateMouseArea();
   _loc1_.updateHorizonPlane();
   _loc1_.updateObjects();
   _loc1_.updateCircles();
   _loc1_.updateLines();
};
p.setPhiAndTheta = function(newPhi, newTheta)
{
   var _loc1_ = this;
   var _loc2_ = newPhi;
   _loc1_._theta = 0.017453292519943295 * ((newTheta % 360 + 360) % 360);
   if(_loc2_ > _loc1_._maxPhi)
   {
      _loc2_ = _loc1_._maxPhi;
   }
   else if(_loc2_ < _loc1_._minPhi)
   {
      _loc2_ = _loc1_._minPhi;
   }
   _loc1_._phi = _loc2_ * 0.017453292519943295;
   if(_loc1_._phi < 0)
   {
      _loc1_._iLA.swapDepths(3 * _loc1_._N - 2);
   }
   else
   {
      _loc1_._iLA.swapDepths(4 * _loc1_._N - 6);
   }
   _loc1_.doA();
   _loc1_.doB();
   _loc1_.updateMasks(true);
   _loc1_.updateMouseArea();
   _loc1_.updateHorizonPlane();
   _loc1_.updateObjects();
   _loc1_.updateCircles();
   _loc1_.updateLines();
};
p.getTheta = function()
{
   return 57.29577951308232 * this._theta;
};
p.setTheta = function(arg)
{
   var _loc1_ = this;
   _loc1_._theta = 0.017453292519943295 * ((arg % 360 + 360) % 360);
   _loc1_.doA();
   _loc1_.doB();
   _loc1_.updateHorizonPlane();
   _loc1_.updateObjects();
   _loc1_.updateCircles();
   _loc1_.updateLines();
};
p.getViewerAzimuth = function()
{
   return (360 - this.theta) % 360;
};
p.setViewerAzimuth = function(arg)
{
   this.setTheta(360 - arg);
};
p.getPhi = function()
{
   return 57.29577951308232 * this._phi;
};
p.setPhi = function(newPhi)
{
   var _loc1_ = this;
   var _loc2_ = newPhi;
   if(_loc2_ > _loc1_._maxPhi)
   {
      _loc2_ = _loc1_._maxPhi;
   }
   else if(_loc2_ < _loc1_._minPhi)
   {
      _loc2_ = _loc1_._minPhi;
   }
   _loc1_._phi = _loc2_ * 0.017453292519943295;
   if(_loc1_._phi < 0)
   {
      _loc1_._iLA.swapDepths(3 * _loc1_._N - 2);
   }
   else
   {
      _loc1_._iLA.swapDepths(4 * _loc1_._N - 6);
   }
   _loc1_.doA();
   _loc1_.doB();
   _loc1_.updateMasks(true);
   _loc1_.updateMouseArea();
   _loc1_.updateHorizonPlane();
   _loc1_.updateObjects();
   _loc1_.updateCircles();
   _loc1_.updateLines();
};
p.getSize = function()
{
   return 2 * this._c.r;
};
p.setSize = function(arg)
{
   var _loc1_ = this;
   _loc1_._c.r = arg / 2;
   _loc1_._c.r2 = _loc1_._c.r * _loc1_._c.r;
   _loc1_.doA();
   _loc1_.doB();
   _loc1_.updateMasks();
   _loc1_.updateMouseArea();
   _loc1_.updateShading();
   _loc1_.updateHorizonPlane();
   _loc1_.updateObjects();
   _loc1_.updateCircles();
   _loc1_.updateLines();
};
p.getSiderealTime = function()
{
   return this._sTime * 3.819718634205488;
};
p.setSiderealTime = function(arg)
{
   var _loc1_ = this;
   _loc1_._sTime = (arg % 24 + 24) % 24 * 0.2617993877991494;
   _loc1_.doM();
   _loc1_.doB();
   _loc1_.updateObjects();
   _loc1_.updateCircles(true);
   _loc1_.updateLines(true);
};
p.getLatitude = function()
{
   return 57.29577951308232 * this._lat;
};
p.setLatitude = function(arg)
{
   var _loc1_ = this;
   var _loc2_ = arg;
   if(_loc2_ > 90)
   {
      _loc2_ = 90;
   }
   else if(_loc2_ < -90)
   {
      _loc2_ = -90;
   }
   _loc1_._lat = _loc2_ * 0.017453292519943295;
   _loc1_.doM();
   _loc1_.doB();
   _loc1_.updateObjects();
   _loc1_.updateCircles(true);
   _loc1_.updateLines(true);
};
p.getShowUnder = function()
{
   return this._showUnder;
};
p.setShowUnder = function(arg)
{
   var _loc1_ = this;
   _loc1_._showUnder = Boolean(arg);
   _loc1_.updateLines();
   _loc1_.updateMasks();
   _loc1_.updateMouseArea();
   _loc1_.updateObjects();
};
p.getMinPhi = function()
{
   return this._minPhi;
};
p.setMinPhi = function(arg)
{
   var _loc1_ = this;
   var _loc2_ = arg;
   if(_loc2_ > 90)
   {
      _loc1_._minPhi = 90;
   }
   else if(_loc2_ < -90)
   {
      _loc1_._minPhi = 90;
   }
   else
   {
      _loc1_._minPhi = _loc2_;
   }
};
p.getMaxPhi = function()
{
   return this._maxPhi;
};
p.setMaxPhi = function(arg)
{
   var _loc1_ = this;
   var _loc2_ = arg;
   if(_loc2_ > 90)
   {
      _loc1_._maxPhi = 90;
   }
   else if(_loc2_ < -90)
   {
      _loc1_._maxPhi = 90;
   }
   else
   {
      _loc1_._maxPhi = _loc2_;
   }
};
p.addProperty("theta",p.getTheta,p.setTheta);
p.addProperty("phi",p.getPhi,p.setPhi);
p.addProperty("size",p.getSize,p.setSize);
p.addProperty("viewerAzimuth",p.getViewerAzimuth,p.setViewerAzimuth);
p.addProperty("viewerAltitude",p.getPhi,p.setPhi);
p.addProperty("siderealTime",p.getSiderealTime,p.setSiderealTime);
p.addProperty("latitude",p.getLatitude,p.setLatitude);
p.addProperty("showUnder",p.getShowUnder,p.setShowUnder);
p.addProperty("maxViewerAltitude",p.getMaxPhi,p.setMaxPhi);
p.addProperty("minViewerAltitude",p.getMinPhi,p.setMinPhi);
