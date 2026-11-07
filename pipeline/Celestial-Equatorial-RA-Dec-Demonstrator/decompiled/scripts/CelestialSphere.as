function CelestialSphereClass()
{
   var _loc1_ = this;
   _loc1_._c = new Object();
   _loc1_._aVer = -1;
   _loc1_._bVer = -1;
   _loc1_._objectFreeID = 0;
   _loc1_._objectList = [];
   _loc1_._circleFreeID = 0;
   _loc1_._circleList = [];
   _loc1_._lineFreeID = 0;
   _loc1_._lineList = [];
   _loc1_._decTrailFreeID = 0;
   _loc1_._decTrailList = [];
   _loc1_._shadedBandFreeID = 0;
   _loc1_._shadedBandList = [];
   _loc1_._maxPhi = 90;
   _loc1_._minPhi = -90;
   _loc1_._c.r = 150;
   _loc1_._c.r2 = _loc1_._c.r * _loc1_._c.r;
   _loc1_._showUnder = true;
   _loc1_._phi = 0.5235987755982988;
   var _loc2_ = _loc1_._N;
   _loc1_.createEmptyMovieClip("_mouseArea",-1);
   _loc1_.createEmptyMovieClip("_bEL",_loc2_ - 7);
   _loc1_.createEmptyMovieClip("_bOSB",_loc2_ - 6);
   _loc1_.createEmptyMovieClip("_bOSA",_loc2_ - 5);
   _loc1_.createEmptyMovieClip("_bOSF",_loc2_ - 4);
   _loc1_.createEmptyMovieClip("_bF",_loc2_ - 3);
   _loc1_.createEmptyMovieClip("_bDT",_loc2_ - 2);
   _loc1_.createEmptyMovieClip("_bC",_loc2_ - 1);
   _loc1_.createEmptyMovieClip("_bISB",2 * _loc2_ - 4);
   _loc1_.createEmptyMovieClip("_bISA",2 * _loc2_ - 3);
   _loc1_.createEmptyMovieClip("_bISF",2 * _loc2_ - 2);
   _loc1_.createEmptyMovieClip("_iLB",3 * _loc2_ - 2);
   _loc1_.createEmptyMovieClip("_hP",3 * _loc2_ - 1);
   _loc1_.createEmptyMovieClip("_iLA",4 * _loc2_ - 7);
   _loc1_.createEmptyMovieClip("_fISB",4 * _loc2_ - 6);
   _loc1_.createEmptyMovieClip("_fISA",4 * _loc2_ - 5);
   _loc1_.createEmptyMovieClip("_fISF",4 * _loc2_ - 4);
   _loc1_.createEmptyMovieClip("_fF",4 * _loc2_ - 3);
   _loc1_.createEmptyMovieClip("_fDT",4 * _loc2_ - 2);
   _loc1_.createEmptyMovieClip("_fC",4 * _loc2_ - 1);
   _loc1_.createEmptyMovieClip("_fOSB",5 * _loc2_ - 4);
   _loc1_.createEmptyMovieClip("_fOSA",5 * _loc2_ - 3);
   _loc1_.createEmptyMovieClip("_fOSF",5 * _loc2_ - 2);
   _loc1_.createEmptyMovieClip("_fEL",6 * _loc2_ - 1);
   _loc1_._hP.createEmptyMovieClip("_below",0);
   _loc1_._hP.createEmptyMovieClip("_above",1);
   _loc1_.setThetaAndPhi(90,30);
   _loc1_.setLatitude(41);
   _loc1_.setSiderealTime(0);
   _loc1_.createMasks();
   _loc1_.addHorizonPlaneClip("CSAboveHorizonPlane","aboveHorizonPlane","above",0);
   _loc1_.addHorizonPlaneClip("CSBelowHorizonPlane","belowHorizonPlane","below",0);
   _loc1_.addShadingClip("CSGradientDisk","celestialBowl","front","inner","both",{innerAlpha:0,innerColor:16777215,outerAlpha:20,outerColor:0});
   _loc1_.setMouseBehavior("simple drag");
   _loc1_.onMouseUpdateInstance = _loc1_._parent;
   _loc1_.sortObjects = true;
   _loc1_.update();
}
var p = CelestialSphereClass.prototype = new MovieClip();
Object.registerClass("CelestialSphere",CelestialSphereClass);
p._traceOn = false;
p._N = 10000;
p.update = function()
{
   var _loc1_ = this;
   _loc1_.updateMasks(true);
   _loc1_.updateShading();
   _loc1_.updateHorizonPlane();
   _loc1_.updateObjects();
   _loc1_.updateCircles();
   _loc1_.updateLines();
   _loc1_.updateDeclinationTrails();
   _loc1_.updateShadedBands();
};
p.mod = function(n, m)
{
   var _loc1_ = n;
   var _loc2_ = m;
   if(_loc1_ < 0)
   {
      return _loc1_ % _loc2_ + _loc2_;
   }
   return _loc1_ % _loc2_;
};
