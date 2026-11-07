function KeplerianSystemClass()
{
   var _loc1_ = this;
   _loc1_._screenSemimajorAxis = (_loc1_._windowWidth - 2 * _loc1_._margin) / (2 + _loc1_._maxEccentricity);
   _loc1_._safeRadius = 1.5 * (1 + _loc1_._maxEccentricity) * _loc1_._screenSemimajorAxis;
   _loc1_._superSafeRadius = 2 * _loc1_._windowWidth;
   _loc1_._windowHeight = 2 * _loc1_._margin + 2 * _loc1_._screenSemimajorAxis;
   _loc1_._zoomIntervalID = null;
   var _loc2_ = _loc1_.createEmptyMovieClip("systemMC",1);
   _loc2_._x = _loc1_._margin + _loc1_._screenSemimajorAxis;
   var _loc3_ = _loc1_.createEmptyMovieClip("systemMaskMC",2);
   _loc3_.clear();
   _loc3_.beginFill(16711680,50);
   _loc3_.moveTo(0,_loc1_._windowHeight / 2);
   _loc3_.lineTo(0,(- _loc1_._windowHeight) / 2);
   _loc3_.lineTo(_loc1_._windowWidth,(- _loc1_._windowHeight) / 2);
   _loc3_.lineTo(_loc1_._windowWidth,_loc1_._windowHeight / 2);
   _loc3_.lineTo(0,_loc1_._windowHeight / 2);
   _loc3_.endFill();
   _loc2_.setMask(_loc3_);
   var bMC = _loc2_.createEmptyMovieClip("backgroundMC",9);
   bmc._x = - _loc2_._x;
   bMC.beginFill(0);
   bMC.moveTo(0,_loc1_._windowHeight / 2);
   bMC.lineTo(0,(- _loc1_._windowHeight) / 2);
   bMC.lineTo(_loc1_._windowWidth,(- _loc1_._windowHeight) / 2);
   bMC.lineTo(_loc1_._windowWidth,_loc1_._windowHeight / 2);
   bMC.lineTo(0,_loc1_._windowHeight / 2);
   bMC.endFill();
   _loc2_.createEmptyMovieClip("gridMC",10);
   _loc2_.attachMovie("Primary Halo","haloMC",15);
   _loc2_.createEmptyMovieClip("orbitalInteriorMC",20);
   _loc2_.createEmptyMovieClip("orbitalInteriorMaskMC",25);
   _loc2_.orbitalInteriorMC.setMask(_loc2_.orbitalInteriorMaskMC);
   _loc2_.attachMovie("Scale Bar","scaleBarMC",29,{_x:520 - _loc2_._x,_y:-205});
   _loc2_.createEmptyMovieClip("landmarkOrbitsMC",30);
   _loc2_.createEmptyMovieClip("orbitMC",40);
   _loc2_.createEmptyMovieClip("radialLinesMC",45);
   _loc2_.attachMovie("Radial Label 1","radialLabel1MC",46);
   _loc2_.attachMovie("Radial Label 2","radialLabel2MC",47);
   _loc2_.createEmptyMovieClip("accelerationLineMC",50);
   _loc2_.createEmptyMovieClip("velocityTangentMC",51);
   _loc2_.createEmptyMovieClip("detailsMC",60);
   _loc2_.detailsMC.attachMovie("Empty Focus Label","emptyFocusMC",1);
   _loc2_.detailsMC.attachMovie("Center Label","centerMC",2);
   _loc2_.detailsMC.attachMovie("Curly Brace Component","semimajorBraceMC",3,{initLabel:"semimajor axis",_y:-18,initBraceColor:39423});
   _loc2_.detailsMC.attachMovie("Curly Brace Component","semiminorBraceMC",4,{initLabel:"semiminor axis",_rotation:-90,initBraceColor:16751001});
   _loc2_.attachMovie("Secondary Icon","secondaryMC",100);
   _loc2_.attachMovie("Primary Icon","primaryMC",110,{_x:0,_y:0});
   _loc2_.createEmptyMovieClip("arrowsMC",150);
   _loc2_.arrowsMC.attachMovie("Arrow Component","accelerationArrowMC",1);
   _loc2_.arrowsMC.attachMovie("Arrow Component","velocityArrowMC",2);
   _loc1_.initializeArrows();
   _loc1_._primaryMass = 1;
   _loc1_.initializeLandmarkOrbits();
   _loc1_.removeAllSweeps();
   _loc1_._sweepContinuously = false;
   _loc1_.setSweepDuration(16,true);
   _loc1_._time = 0;
   _loc1_._meanAnomaly = 0;
   _loc1_.setAnimationRate(5);
   _loc1_.setAnimationState(false);
   _loc1_.setEccentricity(0.4);
   _loc1_.setSemimajorAxis(1);
   _loc1_.setPrimaryMass(1);
   _loc1_.setShowDetails(false);
   _loc1_.setShowArrows(false);
   _loc1_.setShowLandmarkOrbits(false);
   _loc1_.setShowLandmarkPlanetIcons(false);
   _loc1_.setShowLandmarkOrbitLabels(false);
   _loc1_.setSecondaryDraggability(true);
   _loc1_.soundObj = new Sound();
   _loc1_.soundObj.attachSound("click");
}
var p = KeplerianSystemClass.prototype = new MovieClip();
Object.registerClass("Keplerian System",KeplerianSystemClass);
var p = KeplerianSystemClass.prototype;
p.zoomDuration = 750;
p.zoomIntervalFunc = function(thisObj)
{
   var _loc1_ = thisObj;
   var _loc2_ = getTimer();
   if(_loc2_ > _loc1_.zoomEnd)
   {
      _loc2_ = _loc1_.zoomEnd;
   }
   var _loc3_ = Math.exp(_loc1_.zoomEaser.getValue(_loc2_));
   _loc1_.setScale(_loc3_);
   if(_loc2_ >= _loc1_.zoomEnd)
   {
      _loc1_.zoomEaser.init(Math.log(_loc3_));
      clearInterval(_loc1_._zoomIntervalID);
      _loc1_._zoomIntervalID = null;
   }
   updateAfterEvent();
};
p.setScale = function(arg)
{
   var _loc1_ = this;
   _loc1_._scale = arg;
   _loc1_.updateOrbit();
   _loc1_.updatePosition();
   _loc1_.updateGrid();
   _loc1_.updateLandmarkOrbits();
   _loc1_.updateLandmarkPlanetPositions();
   _loc1_.updateAllSweeps();
   _loc1_.updateDetails();
   _loc1_.updateRadialLines();
};
p.calculateScaleAndUpdate = function(skipZoom)
{
   var _loc1_ = this;
   var _loc3_ = _loc1_._scale;
   var _loc2_ = (_loc1_._windowWidth - 2 * _loc1_._margin) / (_loc1_._semimajorAxis * (2 + _loc1_._maxEccentricity));
   if(skipZoom || _loc3_ == undefined)
   {
      if(_loc1_._zoomIntervalID != null)
      {
         clearInterval(_loc1_._zoomIntervalID);
         _loc1_._zoomIntervalID = null;
      }
      _loc1_.setScale(_loc2_);
      _loc1_.zoomEaser = new CubicEasingClass(Math.log(_loc2_));
   }
   else if(_loc2_ != _loc3_)
   {
      var timeNow = getTimer();
      _loc1_.zoomEnd = timeNow + _loc1_.zoomDuration;
      _loc1_.zoomEaser.setTarget(timeNow,null,_loc1_.zoomEnd,Math.log(_loc2_));
      if(_loc1_._zoomIntervalID == null)
      {
         _loc1_._zoomIntervalID = setInterval(_loc1_.zoomIntervalFunc,30,_loc1_);
      }
      _loc1_.zoomIntervalFunc(_loc1_);
   }
   else
   {
      _loc1_.setScale(_loc1_._scale);
   }
};
p.getShowGrid = function()
{
   return this.systemMC.gridMC._visible;
};
p.setShowGrid = function(arg)
{
   this.systemMC.gridMC._visible = arg;
};
p.addProperty("showGrid",p.getShowGrid,p.setShowGrid);
p.getPrimaryMass = function()
{
   return this._primaryMass;
};
p.setPrimaryMass = function(arg)
{
   var _loc1_ = this;
   _loc1_._primaryMass = arg;
   _loc1_.calculatePeriod();
   _loc1_.systemMC.primaryMC.setPrimaryMass(arg);
};
p.addProperty("primaryMass",p.getPrimaryMass,p.setPrimaryMass);
p.getSemimajorAxis = function()
{
   return this._semimajorAxis;
};
p.setSemimajorAxis = function(arg)
{
   var _loc1_ = this;
   _loc1_._semimajorAxis = arg;
   _loc1_.calculatePeriod();
   _loc1_.calculateScaleAndUpdate();
};
p.addProperty("semimajorAxis",p.getSemimajorAxis,p.setSemimajorAxis);
p.setSemimajorAxisNoZoom = function(arg)
{
   var _loc1_ = this;
   _loc1_._semimajorAxis = arg;
   _loc1_.calculatePeriod();
   _loc1_.calculateScaleAndUpdate(true);
};
p.getEccentricity = function()
{
   return this._eccentricity;
};
p.setEccentricity = function(arg)
{
   var _loc1_ = this;
   var _loc2_ = arg;
   _loc1_._eccentricity = _loc2_;
   _loc1_._k1 = Math.sqrt((1 + _loc2_) / (1 - _loc2_));
   _loc1_.updateOrbit();
   _loc1_.updatePosition();
   _loc1_.updateAllSweeps();
   _loc1_.updateDetails();
   _loc1_.updateRadialLines();
};
p.addProperty("eccentricity",p.getEccentricity,p.setEccentricity);
p.getAnimationState = function()
{
   return this.onEnterFrame == this.onEnterFrameFunc;
};
p.setAnimationState = function(arg)
{
   var _loc1_ = this;
   if(arg)
   {
      _loc1_._timeLast = getTimer();
      _loc1_.onEnterFrame = _loc1_.onEnterFrameFunc;
   }
   else
   {
      delete _loc1_.onEnterFrame;
   }
};
p.addProperty("animationState",p.getAnimationState,p.setAnimationState);
p.setAnimationRate = function(arg)
{
   this._timeRate = 1 / (1000 * arg);
   this.calculateMeanAnomalyRate();
};
p.getPeriod = function()
{
   return this._period;
};
p.addProperty("period",p.getPeriod,null);
p.calculatePeriod = function()
{
   var _loc1_ = this;
   _loc1_._period = Math.sqrt(Math.pow(_loc1_._semimajorAxis,3) / _loc1_._primaryMass);
   _loc1_.calculateMeanAnomalyRate();
};
p.calculateMeanAnomalyRate = function()
{
   var _loc1_ = this;
   _loc1_._meanAnomalyRate = 6.283185307179586 * _loc1_._timeRate / _loc1_._period;
};
p.onEnterFrameFunc = function()
{
   var _loc1_ = this;
   var _loc2_ = getTimer();
   var _loc3_ = _loc2_ - _loc1_._timeLast;
   _loc1_._time += _loc1_._timeRate * _loc3_;
   _loc1_._meanAnomaly += _loc1_._meanAnomalyRate * _loc3_;
   _loc1_.updatePosition();
   _loc1_.updateLandmarkPlanetPositions();
   _loc1_.updateActiveSweep();
   _loc1_._timeLast = _loc2_;
};
var p = KeplerianSystemClass.prototype;
p.getMeanAnomaly = function()
{
   return this._meanAnomaly;
};
p.setMeanAnomaly = function(arg)
{
   var _loc1_ = this;
   _loc1_._meanAnomaly = arg;
   _loc1_.updatePosition();
   _loc1_.updateArrows();
   _loc1_.cancelSweeping();
};
p.addProperty("meanAnomaly",p.getMeanAnomaly,p.setMeanAnomaly);
p.getRadius = function()
{
   return this._radius / this._scale;
};
p.addProperty("radius",p.getRadius,null);
p.updatePosition = function()
{
   var _loc3_ = this;
   var sin = Math.sin;
   var abs = Math.abs;
   var e = _loc3_._eccentricity;
   var ma = _loc3_._meanAnomaly;
   var k1 = _loc3_._k1;
   var k2 = _loc3_._semimajorAxis * _loc3_._scale * (1 - e * e);
   var _loc2_ = 0;
   var _loc1_ = ma + e * sin(ma);
   var c = 0;
   do
   {
      _loc2_ = _loc1_;
      _loc1_ = ma + e * sin(_loc2_);
      c++;
   }
   while(abs(_loc1_ - _loc2_) > 0.001 && c < 100);
   var ta = 2 * Math.atan(k1 * Math.tan(_loc1_ / 2));
   var r = k2 / (1 + e * Math.cos(ta));
   _loc3_._trueAnomaly = ta;
   _loc3_._radius = r;
   var tx = (- r) * Math.cos(ta);
   var ty = r * sin(ta);
   _loc3_.systemMC.secondaryMC.trueX = tx;
   _loc3_.systemMC.secondaryMC.trueY = ty;
   if(r > _loc3_._superSafeRadius)
   {
      _loc3_.systemMC.secondaryMC._x = (- _loc3_._superSafeRadius) * Math.cos(ta);
      _loc3_.systemMC.secondaryMC._y = _loc3_._superSafeRadius * sin(ta);
   }
   else
   {
      _loc3_.systemMC.secondaryMC._x = tx;
      _loc3_.systemMC.secondaryMC._y = ty;
   }
   _loc3_.updateArrows();
   _loc3_.updateRadialLines();
   _loc3_._parent.onPositionChanged();
};
p.setSecondaryDraggability = function(arg)
{
   var _loc2_ = this;
   var _loc1_ = _loc2_.systemMC.secondaryMC;
   _loc1_.useHandCursor = false;
   if(arg)
   {
      _loc1_.onPress = _loc2_.secondaryOnPressFunc;
      _loc1_.onRelease = _loc2_.secondaryOnReleaseFunc;
      _loc1_.onReleaseOutside = _loc2_.secondaryOnReleaseOutsideFunc;
      _loc1_.onRollOver = _loc2_.secondaryOnRollOverFunc;
      _loc1_.onRollOut = _loc2_.secondaryOnRollOutFunc;
      _loc1_.onMouseMoveFunc = _loc2_.secondaryOnMouseMoveFunc;
   }
   else
   {
      delete _loc1_.onPress;
      delete _loc1_.onRelease;
      delete _loc1_.onReleaseOutside;
      delete _loc1_.onRollOver;
      delete _loc1_.onRollOut;
      delete _loc1_.onMouseMove;
      delete _loc1_.onMouseMoveFunc;
   }
};
p.secondaryOnPressFunc = function()
{
   var _loc2_ = this;
   var _loc1_ = _loc2_._parent._parent;
   var _loc3_ = _loc1_.systemMC;
   var ta = 3.141592653589793 - Math.atan2(_loc3_._ymouse,_loc3_._xmouse);
   var ea = 2 * Math.atan(Math.tan(ta / 2) / _loc1_._k1);
   var ma = ea - _loc1_._eccentricity * Math.sin(ea);
   _loc2_.dragOffset = ma - _loc1_._meanAnomaly;
   _loc2_.wasAnimating = _loc1_.getAnimationState();
   _loc1_.setAnimationState(false);
   _loc2_.onMouseMove = _loc2_.onMouseMoveFunc;
};
p.secondaryOnMouseMoveFunc = function()
{
   var _loc1_ = this._parent._parent;
   var _loc2_ = _loc1_.systemMC;
   var ta = 3.141592653589793 - Math.atan2(_loc2_._ymouse,_loc2_._xmouse);
   var _loc3_ = 2 * Math.atan(Math.tan(ta / 2) / _loc1_._k1);
   var ma = _loc3_ - _loc1_._eccentricity * Math.sin(_loc3_);
   _loc1_.setMeanAnomaly(ma - this.dragOffset);
   updateAfterEvent();
};
p.secondaryOnRollOverFunc = function()
{
   this.gotoAndStop(2);
};
p.secondaryOnRollOutFunc = function()
{
   this.gotoAndStop(1);
};
p.secondaryOnReleaseFunc = function()
{
   var _loc1_ = this;
   delete _loc1_.onMouseMove;
   _loc1_._parent._parent.setAnimationState(_loc1_.wasAnimating);
};
p.secondaryOnReleaseOutsideFunc = function()
{
   var _loc1_ = this;
   _loc1_.gotoAndStop(1);
   delete _loc1_.onMouseMove;
   _loc1_._parent._parent.setAnimationState(_loc1_.wasAnimating);
};
var p = KeplerianSystemClass.prototype;
p.setShowDetails = function(arg)
{
   var _loc1_ = this;
   var _loc2_ = arg;
   _loc1_.setShowEmptyFocus(_loc2_);
   _loc1_.setShowCenter(_loc2_);
   _loc1_.setShowRadialLines(_loc2_);
   _loc1_.setShowSemimajorAxis(_loc2_);
   _loc1_.setShowSemiminorAxis(_loc2_);
};
p.setShowEmptyFocus = function(arg)
{
   this.systemMC.detailsMC.emptyFocusMC._visible = arg;
};
p.setShowCenter = function(arg)
{
   this.systemMC.detailsMC.centerMC._visible = arg;
};
p.setShowRadialLines = function(arg)
{
   var _loc1_ = this;
   var _loc2_ = arg;
   _loc1_.systemMC.radialLinesMC._visible = _loc2_;
   _loc1_.systemMC.radialLabel1MC._visible = _loc2_;
   _loc1_.systemMC.radialLabel2MC._visible = _loc2_;
};
p.setShowSemimajorAxis = function(arg)
{
   this.systemMC.detailsMC.semimajorBraceMC._visible = arg;
};
p.setShowSemiminorAxis = function(arg)
{
   this.systemMC.detailsMC.semiminorBraceMC._visible = arg;
};
p.getCroppedLinePoints = function(sx, sy, fx, fy, r)
{
   var _loc1_ = sy;
   var _loc2_ = sx;
   var ax = fx * fx - 2 * _loc2_ * fx + _loc2_ * _loc2_;
   var bx = 2 * _loc2_ * fx - 2 * _loc2_ * _loc2_;
   var ay = fy * fy - 2 * _loc1_ * fy + _loc1_ * _loc1_;
   var by = 2 * _loc1_ * fy - 2 * _loc1_ * _loc1_;
   var a = ax + ay;
   var b = bx + by;
   var c = _loc2_ * _loc2_ + _loc1_ * _loc1_ - r * r;
   var D = b * b - 4 * a * c;
   if(D <= 0)
   {
      return null;
   }
   var sqrtD = Math.sqrt(D);
   var u0 = (- b + sqrtD) / (2 * a);
   var _loc3_ = (- b - sqrtD) / (2 * a);
   if(_loc3_ < u0)
   {
      var u0_ = u0;
      u0 = _loc3_;
      _loc3_ = u0_;
   }
   if(_loc3_ <= 0 || u0 >= 1)
   {
      return null;
   }
   if(u0 < 0)
   {
      u0 = 0;
   }
   if(_loc3_ > 1)
   {
      _loc3_ = 1;
   }
   return [{x:_loc2_ + (fx - _loc2_) * u0,y:_loc1_ + (fy - _loc1_) * u0},{x:_loc2_ + (fx - _loc2_) * _loc3_,y:_loc1_ + (fy - _loc1_) * _loc3_}];
};
p.updateRadialLines = function()
{
   var _loc1_ = this;
   var _loc3_ = _loc1_.systemMC.secondaryMC;
   var fmc = _loc1_.systemMC.detailsMC.emptyFocusMC;
   var _loc2_ = _loc1_.systemMC.radialLinesMC;
   _loc2_.clear();
   _loc2_.lineStyle(2,8978312,100);
   var r1Pts = _loc1_.getCroppedLinePoints(0,0,_loc3_.trueX,_loc3_.trueY,_loc1_._superSafeRadius);
   if(r1Pts != null)
   {
      _loc2_.moveTo(r1Pts[0].x,r1Pts[0].y);
      _loc2_.lineTo(r1Pts[1].x,r1Pts[1].y);
   }
   var r2Pts = _loc1_.getCroppedLinePoints(fmc.trueX,0,_loc3_.trueX,_loc3_.trueY,_loc1_._superSafeRadius);
   if(r2Pts != null)
   {
      _loc2_.moveTo(r2Pts[0].x,r2Pts[0].y);
      _loc2_.lineTo(r2Pts[1].x,r2Pts[1].y);
   }
   var d = 20;
   var r1 = _loc1_._radius;
   var angle = _loc1_._trueAnomaly - Math.atan(d / r1);
   var r1x = (- r1) * 0.5 * Math.cos(angle);
   var r1y = r1 * 0.5 * Math.sin(angle);
   var r1d = Math.sqrt(r1x * r1x + r1y * r1y);
   if(r1d > _loc1_._superSafeRadius)
   {
      _loc1_.systemMC.radialLabel1MC._x = _loc1_._superSafeRadius;
      _loc1_.systemMC.radialLabel1MC._y = _loc1_._superSafeRadius;
   }
   else
   {
      _loc1_.systemMC.radialLabel1MC._x = r1x;
      _loc1_.systemMC.radialLabel1MC._y = r1y;
   }
   var r2 = 2 * _loc1_._semimajorAxis * _loc1_._scale - r1;
   var angle = Math.atan2(_loc3_.trueY,_loc3_.trueX - fmc.trueX) - Math.atan(d / r2);
   var r2x = fmc.trueX + r2 * 0.5 * Math.cos(angle);
   var r2y = r2 * 0.5 * Math.sin(angle);
   var r2d = Math.sqrt(r2x * r2x + r2y * r2y);
   if(r2d > _loc1_._superSafeRadius)
   {
      _loc1_.systemMC.radialLabel2MC._x = _loc1_._superSafeRadius;
      _loc1_.systemMC.radialLabel2MC._y = _loc1_._superSafeRadius;
   }
   else
   {
      _loc1_.systemMC.radialLabel2MC._x = r2x;
      _loc1_.systemMC.radialLabel2MC._y = r2y;
   }
};
p.updateDetails = function()
{
   var _loc2_ = this;
   var _loc1_ = _loc2_.systemMC.detailsMC;
   var _loc3_ = _loc2_._semimajorAxis * _loc2_._scale;
   var e = _loc2_._eccentricity;
   var ae = _loc3_ * e;
   _loc1_.centerMC.trueX = ae;
   if(_loc1_.centerMC.trueX > _loc2_._superSafeRadius)
   {
      _loc1_.centerMC._x = _loc2_._superSafeRadius;
   }
   else
   {
      _loc1_.centerMC._x = _loc1_.centerMC.trueX;
   }
   _loc1_.emptyFocusMC.trueX = 2 * ae;
   if(_loc1_.emptyFocusMC.trueX > _loc2_._superSafeRadius)
   {
      _loc1_.emptyFocusMC._x = _loc2_._superSafeRadius;
   }
   else
   {
      _loc1_.emptyFocusMC._x = _loc1_.emptyFocusMC.trueX;
   }
   var b = Math.sqrt(_loc3_ * _loc3_ * (1 - e * e));
   if(_loc3_ > _loc2_._superSafeRadius)
   {
      _loc3_ = _loc2_._superSafeRadius;
   }
   _loc1_.semimajorBraceMC._x = _loc1_.centerMC._x + _loc3_ * 0.5;
   _loc1_.semimajorBraceMC.setBraceWidth(_loc3_);
   if(b > _loc2_._superSafeRadius)
   {
      b = _loc2_._superSafeRadius;
   }
   _loc1_.semiminorBraceMC._y = (- b) / 2;
   _loc1_.semiminorBraceMC._x = -18 + _loc1_.centerMC._x;
   _loc1_.semiminorBraceMC.setBraceWidth(b);
};
var p = KeplerianSystemClass.prototype;
p.landmarkOrbitStyle = {thickness:1,color:16737792,alpha:80};
p.landmarkOrbitData = [{e:0.206,a:0.387,ma:0.5,name:"Mercury"},{e:0.007,a:0.723,ma:3.5,name:"Venus"},{e:0.017,a:1,ma:5,name:"Earth"},{e:0.093,a:1.524,ma:2,name:"Mars"},{e:0.048,a:5.203,ma:1,name:"Jupiter"},{e:0.056,a:9.54,ma:3.5,name:"Saturn"},{e:0.047,a:19.18,ma:6,name:"Uranus"},{e:0.009,a:30.06,ma:0,name:"Neptune"},{e:0.249,a:39.44,ma:2.5,name:"Pluto"}];
p.setParametersToMatch = function(arg)
{
   var _loc1_ = this;
   _loc1_._semimajorAxis = _loc1_.landmarkOrbitData[arg].a;
   _loc1_._eccentricity = _loc1_.landmarkOrbitData[arg].e;
   _loc1_._k1 = Math.sqrt((1 + _loc1_._eccentricity) / (1 - _loc1_._eccentricity));
   _loc1_.calculatePeriod();
   _loc1_.calculateScaleAndUpdate();
};
p.setShowLandmarkOrbits = function(arg)
{
   var _loc2_ = this.landmarkOrbitData.length;
   var _loc3_ = this.systemMC.landmarkOrbitsMC;
   var _loc1_ = 0;
   while(_loc1_ < _loc2_)
   {
      _loc3_["_" + _loc1_]._visible = arg;
      _loc1_ = _loc1_ + 1;
   }
};
p.setShowLandmarkPlanetIcons = function(arg)
{
   var _loc2_ = this.landmarkOrbitData.length;
   var _loc3_ = this.systemMC.landmarkOrbitsMC;
   var _loc1_ = 0;
   while(_loc1_ < _loc2_)
   {
      _loc3_["_" + _loc1_].planetMC._visible = arg;
      _loc1_ = _loc1_ + 1;
   }
};
p.setShowLandmarkOrbitLabels = function(arg)
{
   var _loc2_ = this.landmarkOrbitData.length;
   var _loc3_ = this.systemMC.landmarkOrbitsMC;
   var _loc1_ = 0;
   while(_loc1_ < _loc2_)
   {
      _loc3_["_" + _loc1_].labelMC._visible = arg;
      _loc1_ = _loc1_ + 1;
   }
};
p.setShowLandmarkOrbit = function(index, showOrbit)
{
   this.systemMC.landmarkOrbitsMC["_" + index]._visible = showOrbit;
};
p.setShowLandmarkPlanetIcon = function(index, showIcon)
{
   this.systemMC.landmarkOrbitsMC["_" + index].planetMC._visible = showIcon;
};
p.setShowLandmarkOrbitLabel = function(index, showLabel)
{
   this.systemMC.landmarkOrbitsMC["_" + index].labelMC._visible = showLabel;
};
p.initializeLandmarkOrbits = function()
{
   var planets = this.landmarkOrbitData;
   var landmarksMC = this.systemMC.landmarkOrbitsMC;
   var cos = Math.cos;
   var sin = Math.sin;
   var abs = Math.abs;
   var atan = Math.atan;
   var tan = Math.tan;
   var sqrt = Math.sqrt;
   var n = 12;
   var step = 6.283185307179586 / n;
   var c = 1 / cos(step / 2);
   var _loc1_ = 0;
   var _loc2_;
   var _loc3_;
   while(_loc1_ < planets.length)
   {
      _loc2_ = planets[_loc1_].a;
      _loc3_ = planets[_loc1_].e;
      var b = _loc2_ * sqrt(1 - _loc3_ * _loc3_);
      var o = _loc3_ * _loc2_;
      var pts = [];
      var cAngle = step / 2;
      var aAngle = step;
      var j = 0;
      while(j < n)
      {
         var cx = o + _loc2_ * c * cos(cAngle);
         var cy = b * c * sin(cAngle);
         var ax = o + _loc2_ * cos(aAngle);
         var ay = b * sin(aAngle);
         pts.push({cx:cx,cy:cy,ax:ax,ay:ay});
         cAngle += step;
         aAngle += step;
         j++;
      }
      planets[_loc1_].pts = pts;
      planets[_loc1_].period = sqrt(Math.pow(_loc2_,3) / this._primaryMass);
      var ta = 2.443460952792061;
      var r = this._screenSemimajorAxis * (1 - _loc3_ * _loc3_) / (1 + _loc3_ * cos(ta));
      planets[_loc1_].optimalLabelRadius = r;
      landmarksMC.createEmptyMovieClip("_" + _loc1_,_loc1_);
      landmarksMC["_" + _loc1_].attachMovie("Landmark Planet Icon","planetMC",1);
      landmarksMC["_" + _loc1_].attachMovie("Landmark Orbit Label","labelMC",2,{labelString:planets[_loc1_].name});
      _loc1_ = _loc1_ + 1;
   }
};
p.updateLandmarkPlanetPositions = function()
{
   var startTimer = getTimer();
   var landmarksMC = this.systemMC.landmarkOrbitsMC;
   var s = this._scale;
   var data = this.landmarkOrbitData;
   var cos = Math.cos;
   var sin = Math.sin;
   var tan = Math.tan;
   var atan = Math.atan;
   var abs = Math.abs;
   var sqrt = Math.sqrt;
   var time = this._time;
   var width = this._windowWidth;
   var i = 0;
   var _loc1_;
   var _loc3_;
   var _loc2_;
   while(i < data.length)
   {
      var planet = data[i];
      _loc1_ = planet.e;
      var a = s * planet.a;
      var k1 = sqrt((1 + _loc1_) / (1 - _loc1_));
      var k2 = a * (1 - _loc1_ * _loc1_);
      var ma = planet.ma + 6.283185307179586 * time / planet.period;
      _loc3_ = 0;
      _loc2_ = ma + _loc1_ * sin(ma);
      var c = 0;
      do
      {
         _loc3_ = _loc2_;
         _loc2_ = ma + _loc1_ * sin(_loc3_);
         c++;
      }
      while(abs(_loc2_ - _loc3_) > 0.001 && c < 100);
      var ta = 2 * atan(k1 * tan(_loc2_ / 2));
      var r = k2 / (1 + _loc1_ * cos(ta));
      var mc = landmarksMC["_" + i].planetMC;
      if(r > width)
      {
         mc._x = width;
         mc._y = width;
      }
      else
      {
         mc._x = (- r) * cos(ta);
         mc._y = r * sin(ta);
      }
      i++;
   }
};
p.updateLandmarkOrbits = function()
{
   var startTimer = getTimer();
   var landmarksMC = this.systemMC.landmarkOrbitsMC;
   var style = this.landmarkOrbitStyle;
   var _loc2_ = this._scale;
   var data = this.landmarkOrbitData;
   var width = this._windowWidth;
   var cos = Math.cos;
   var sin = Math.sin;
   var i = 0;
   var _loc1_;
   var _loc3_;
   while(i < data.length)
   {
      var planet = data[i];
      _loc1_ = landmarksMC["_" + i];
      _loc1_.clear();
      _loc1_.lineStyle(style.thickness,style.color,style.alpha);
      var labelMC = _loc1_.labelMC;
      var ta = 2.443460952792061;
      var r = _loc2_ * planet.a * (1 - planet.e * planet.e) / (1 + planet.e * cos(ta));
      if(r > width)
      {
         _loc1_.labelMC._x = width;
         _loc1_.labelMC._y = width;
      }
      else
      {
         var ratio = r / planet.optimalLabelRadius;
         if(ratio > 1)
         {
            ratio = 1;
         }
         _loc1_.labelMC._xscale = _loc1_.labelMC._yscale = Math.pow(ratio,0.5) * 100;
         r += 2 * ratio;
         _loc1_.labelMC._x = (- r) * cos(ta);
         _loc1_.labelMC._y = r * sin(ta);
      }
      if(_loc2_ * planet.a * (1 - planet.e) <= this._windowWidth)
      {
         var pts = planet.pts;
         var n = pts.length;
         _loc1_.moveTo(_loc2_ * pts[n - 1].ax,_loc2_ * pts[n - 1].ay);
         var j = 0;
         while(j < n)
         {
            _loc3_ = pts[j];
            _loc1_.curveTo(_loc2_ * _loc3_.cx,_loc2_ * _loc3_.cy,_loc2_ * _loc3_.ax,_loc2_ * _loc3_.ay);
            j++;
         }
      }
      i++;
   }
};
var p = KeplerianSystemClass.prototype;
p.maxArrowLengthForReal = 200;
p.maxAccelerationArrowLength = 100;
p.minAccelerationArrowLength = 20;
p.maxVelocityArrowLength = 100;
p.minVelocityArrowLength = 20;
p.velocityArrowColor = 10000600;
p.accelerationArrowColor = 14194840;
p.velocityTangentColor = 6316192;
p.accelerationLineColor = 10510432;
p.velocityTangentLength = 240;
p.initializeArrows = function()
{
   var _loc1_ = this;
   var aColor = new Color(_loc1_.systemMC.arrowsMC.accelerationArrowMC);
   aColor.setRGB(_loc1_.accelerationArrowColor);
   var vColor = new Color(_loc1_.systemMC.arrowsMC.velocityArrowMC);
   vColor.setRGB(_loc1_.velocityArrowColor);
   var _loc2_ = _loc1_._screenSemimajorAxis;
   var e = _loc1_._maxEccentricity;
   var rMin = _loc2_ * (1 - e);
   var _loc3_ = _loc2_ * (1 + e);
   var maxScreenAcceleration = 1 / (rMin * rMin);
   var minScreenAcceleration = 1 / (_loc3_ * _loc3_);
   _loc1_._accelerationArrowScale = (_loc1_.maxAccelerationArrowLength - _loc1_.minAccelerationArrowLength) / (maxScreenAcceleration - minScreenAcceleration);
   _loc1_._minScreenAcceleration = minScreenAcceleration;
   var maxScreenVelocity = Math.sqrt(2 / rMin - 1 / _loc2_);
   var minScreenVelocity = Math.sqrt(2 / _loc3_ - 1 / _loc2_);
   _loc1_._velocityArrowScale = (_loc1_.maxVelocityArrowLength - _loc1_.minVelocityArrowLength) / (maxScreenVelocity - minScreenVelocity);
   _loc1_._minScreenVelocity = minScreenVelocity;
};
p.setShowArrows = function(arg)
{
   this.systemMC.arrowsMC.velocityArrowMC._visible = arg;
   this.systemMC.arrowsMC.accelerationArrowMC._visible = arg;
};
p.setShowVelocityArrow = function(arg)
{
   this.systemMC.arrowsMC.velocityArrowMC._visible = arg;
};
p.setShowAccelerationArrow = function(arg)
{
   this.systemMC.arrowsMC.accelerationArrowMC._visible = arg;
};
p.setShowAccelerationLine = function(arg)
{
   this.systemMC.accelerationLineMC._visible = arg;
};
p.setShowVelocityTangent = function(arg)
{
   this.systemMC.velocityTangentMC._visible = arg;
};
p.updateArrows = function()
{
   var _loc1_ = this;
   var r = _loc1_._radius;
   var screenAcceleration = 1 / (r * r);
   var aArrowLength = _loc1_.minAccelerationArrowLength + (screenAcceleration - _loc1_._minScreenAcceleration) * _loc1_._accelerationArrowScale;
   var screenVelocity = Math.sqrt(2 / r - 1 / (_loc1_._semimajorAxis * _loc1_._scale));
   var vArrowLength = _loc1_.minVelocityArrowLength + (screenVelocity - _loc1_._minScreenVelocity) * _loc1_._velocityArrowScale;
   var secMC = _loc1_.systemMC.secondaryMC;
   var arrowsMC = _loc1_.systemMC.arrowsMC;
   var aMC = arrowsMC.accelerationArrowMC;
   var vMC = arrowsMC.velocityArrowMC;
   var aLineMC = _loc1_.systemMC.accelerationLineMC;
   var _loc3_ = _loc1_.systemMC.velocityTangentMC;
   arrowsMC._x = secMC._x;
   arrowsMC._y = secMC._y;
   if(aArrowLength > _loc1_.maxArrowLengthForReal)
   {
      aArrowLength = _loc1_.maxArrowLengthForReal;
   }
   if(vArrowLength > _loc1_.maxArrowLengthForReal)
   {
      vArrowLength = _loc1_.maxArrowLengthForReal;
   }
   aMC.arrowShaftMC._xscale = aMC.arrowHeadMC._x = aArrowLength;
   vMC.arrowShaftMC._xscale = vMC.arrowHeadMC._x = vArrowLength;
   var aRot = -57.29577951308232 * _loc1_._trueAnomaly;
   aMC._rotation = aRot;
   aLineMC.clear();
   aLineMC.lineStyle(2,_loc1_.accelerationLineColor);
   aLineMC.drawDashedLine(0,0,secMC._x,secMC._y,3,4);
   aLineMC.lineTo();
   var _loc2_ = _loc1_._semimajorAxis * _loc1_._scale;
   var e = _loc1_._eccentricity;
   var b = Math.sqrt(_loc2_ * _loc2_ * (1 - e * e));
   var x = (- _loc1_._radius) * Math.cos(_loc1_._trueAnomaly) - _loc2_ * e;
   var Q = 1 - x * x / (_loc2_ * _loc2_);
   if(Q < 0)
   {
      Q = 0;
   }
   var angle = -57.29577951308232 * Math.atan(b * x / (_loc2_ * _loc2_ * Math.sqrt(Q)));
   var vRot = _loc1_.systemMC.secondaryMC._y >= 0 ? angle : 180 - angle;
   vMC._rotation = vRot;
   _loc3_._rotation = vRot;
   _loc3_.clear();
   _loc3_.lineStyle(2,_loc1_.velocityTangentColor);
   _loc3_.drawDashedLine((- _loc1_.velocityTangentLength) / 2,0,_loc1_.velocityTangentLength / 2,0,3,4);
   _loc3_._x = secMC._x;
   _loc3_._y = secMC._y;
   _loc3_.lineTo();
   var angleBetweenVectors = ((aRot - vRot) % 360 + 360) % 360;
   if(angleBetweenVectors > 180)
   {
      angleBetweenVectors = 360 - angleBetweenVectors;
   }
   _loc1_.angleBetweenVectors = angleBetweenVectors;
};
var p = KeplerianSystemClass.prototype;
p.orbitPathStyle = {thickness:1,color:12632256};
p.updateOrbit = function()
{
   var startTimer = getTimer();
   var orbitMC = this.systemMC.orbitMC;
   orbitMC.clear();
   orbitMC.lineStyle(this.orbitPathStyle.thickness,this.orbitPathStyle.color,100);
   var maskMC = this.systemMC.orbitalInteriorMaskMC;
   maskMC.clear();
   maskMC.lineStyle(1,16711680);
   var cos = Math.cos;
   var sin = Math.sin;
   var n = 12;
   var step = 6.283185307179586 / n;
   var a = this._semimajorAxis * this._scale;
   if(a > this._superSafeRadius)
   {
      a = this._superSafeRadius;
   }
   var e = this._eccentricity;
   var b = Math.sqrt(a * a * (1 - e * e));
   var c = 1 / cos(step / 2);
   orbitMC.moveTo(a,0);
   maskMC.moveTo(a,0);
   maskMC.beginFill(255);
   var cAngle = step / 2;
   var aAngle = step;
   var i = 0;
   var _loc2_;
   var _loc1_;
   var _loc3_;
   while(i < n)
   {
      _loc2_ = a * c * cos(cAngle);
      _loc1_ = b * c * sin(cAngle);
      var ax = a * cos(aAngle);
      _loc3_ = b * sin(aAngle);
      orbitMC.curveTo(_loc2_,_loc1_,ax,_loc3_);
      maskMC.curveTo(_loc2_,_loc1_,ax,_loc3_);
      cAngle += step;
      aAngle += step;
      i++;
   }
   maskMC.endFill();
   maskMC._x = orbitMC._x = e * a;
};
var p = KeplerianSystemClass.prototype;
p.sweepColors = [39423,16768256,16711833,65433];
p.snapGap = 6;
p.sweepsLimit = 45;
p.getSweepingInProgress = function()
{
   return this._activeSweep != undefined;
};
p.addProperty("sweepingInProgress",p.getSweepingInProgress,null);
p.startSweeping = function(ma)
{
   var _loc2_ = this;
   var _loc3_ = _loc2_._sweepCount;
   var _loc1_ = {};
   _loc1_.allowDragging = false;
   _loc1_.outlineThickness = 0;
   _loc1_.outlineColor = 0;
   _loc1_.mouseOverAlpha = 80;
   _loc1_.mouseOutAlpha = 50;
   _loc1_.fillColor = _loc2_.sweepColors[_loc3_ % _loc2_.sweepColors.length];
   if(ma == undefined)
   {
      _loc2_.cancelSweeping();
      _loc2_._continuousSweepsCount = 0;
      _loc1_.sweepStart = _loc2_._meanAnomaly;
      _loc1_.sweepDuration = 0;
   }
   else
   {
      _loc1_.sweepStart = ma;
      _loc1_.sweepDuration = ((_loc2_._meanAnomaly - ma) % 6.283185307179586 + 6.283185307179586) % 6.283185307179586;
   }
   _loc2_._sweepActiveTill = _loc1_.sweepStart + _loc2_._sweepDuration;
   _loc2_.addSweep(_loc3_,_loc1_);
   _loc2_._activeSweep = _loc3_;
   _loc2_._sweepCount = _loc2_._sweepCount + 1;
};
p.cancelSweeping = function()
{
   var _loc1_ = this;
   if(_loc1_._activeSweep != undefined)
   {
      _loc1_.removeSweep(_loc1_._activeSweep);
      delete _loc1_._activeSweep;
      _loc1_._parent.onSweepingStopped();
   }
};
p.getSweepDuration = function()
{
   return this._sweepDuration;
};
p.setSweepDuration = function(arg, asDenominator)
{
   if(asDenominator)
   {
      if(isNaN(arg) || !isFinite(arg) || arg <= 0)
      {
         return;
      }
      var newDur = 6.283185307179586 / arg;
      this._continuousSweepsLimit = arg;
   }
   else
   {
      if(isNaN(arg) || !isFinite(arg) || arg <= 0 || arg > 6.283185307179586)
      {
         return;
      }
      var newDur = arg;
      this._continuousSweepsLimit = Math.floor(6.283185307179586 / newDur);
   }
   this._sweepDuration = newDur;
   this.cancelSweeping();
   var startTimer = getTimer();
   var _loc2_ = this._newSweepsArray;
   var _loc1_ = 0;
   while(_loc1_ < _loc2_.length)
   {
      this.setSweepDefinition(_loc2_[_loc1_].id,{sweepDuration:newDur});
      _loc1_ = _loc1_ + 1;
   }
};
p.addProperty("sweepDuration",p.getSweepDuration,p.setSweepDuration);
p.setUseSoundEffect = function(arg)
{
   this._useSoundEffect = Boolean(arg);
};
p.addCompletedSweep = function(ma)
{
   var _loc2_ = this;
   var _loc3_ = _loc2_._sweepCount;
   var _loc1_ = {};
   _loc1_.allowDragging = true;
   _loc1_.outlineThickness = 0;
   _loc1_.outlineColor = 0;
   _loc1_.mouseOverAlpha = 80;
   _loc1_.mouseOutAlpha = 50;
   _loc1_.fillColor = _loc2_.sweepColors[_loc3_ % _loc2_.sweepColors.length];
   _loc1_.sweepStart = ma;
   _loc1_.sweepDuration = _loc2_._sweepDuration;
   _loc2_.addSweep(_loc3_,_loc1_);
   _loc2_._sweepCount = _loc2_._sweepCount + 1;
};
p.updateActiveSweep = function()
{
   var _loc1_ = this;
   var id = _loc1_._activeSweep;
   var _loc3_;
   var _loc2_;
   if(id != undefined)
   {
      if(_loc1_._meanAnomaly > _loc1_._sweepActiveTill)
      {
         var defObj = {};
         defObj.sweepDuration = _loc1_._sweepDuration;
         defObj.allowDragging = true;
         _loc1_.setSweepDefinition(id,defObj);
         if(_loc1_._useSoundEffect)
         {
            _loc1_.soundObj.start();
         }
         _loc1_._continuousSweepsCount = _loc1_._continuousSweepsCount + 1;
         if(_loc1_.sweepContinuously)
         {
            var dur = _loc1_._sweepDuration;
            var extraSweeps = (_loc1_._meanAnomaly - _loc1_._sweepActiveTill) / dur;
            var completeExtraSweeps = Math.floor(extraSweeps);
            _loc3_ = _loc1_._sweepActiveTill;
            _loc2_ = 0;
            while(_loc2_ < completeExtraSweeps)
            {
               if(_loc1_._continuousSweepsCount >= _loc1_._continuousSweepsLimit)
               {
                  break;
               }
               _loc1_.addCompletedSweep(_loc3_);
               _loc3_ += dur;
               _loc1_._continuousSweepsCount = _loc1_._continuousSweepsCount + 1;
               _loc2_ = _loc2_ + 1;
            }
            if(_loc1_._continuousSweepsCount < _loc1_._continuousSweepsLimit)
            {
               _loc1_.startSweeping(_loc3_);
            }
            else
            {
               delete _loc1_._activeSweep;
               _loc1_._parent.onSweepingStopped();
            }
         }
         else
         {
            delete _loc1_._activeSweep;
            _loc1_._parent.onSweepingStopped();
         }
      }
      else
      {
         var sweep = _loc1_._newSweepsArray[_loc1_.getIndexFromID(id)].mc;
         var defObj = {};
         defObj.sweepDuration = ((_loc1_._meanAnomaly - sweep.sweepStart) % 6.283185307179586 + 6.283185307179586) % 6.283185307179586;
         _loc1_.setSweepDefinition(id,defObj);
      }
   }
};
p.addSweep = function(id, definitionObject)
{
   var _loc1_ = this;
   var _loc3_ = id;
   var mc = _loc1_.systemMC.orbitalInteriorMC.sweepsMC.createEmptyMovieClip("_" + _loc1_._topSweepDepth,_loc1_._topSweepDepth);
   mc.createEmptyMovieClip("outlineMC",1);
   mc.systemComponent = _loc1_;
   mc._alpha = definitionObject.mouseOutAlpha;
   mc.id = _loc3_;
   _loc1_._newSweepsArray.push({depth:_loc1_._topSweepDepth,id:_loc3_,mc:mc});
   _loc1_._topSweepDepth = _loc1_._topSweepDepth + 1;
   _loc1_.setSweepDefinition(_loc3_,definitionObject);
   var _loc2_ = _loc1_._newSweepsArray;
   if(_loc2_.length - _loc1_.sweepsLimit > 0)
   {
      if(_loc1_._sortingNeeded)
      {
         _loc2_.sort(_loc1_.sortByDepth);
         _loc1_._sortingNeeded = false;
      }
      _loc1_.removeSweep(_loc2_[0].id);
   }
};
p.getIndexFromID = function(id)
{
   var _loc3_ = id;
   var _loc2_ = this._newSweepsArray;
   var _loc1_ = _loc2_.length - 1;
   while(_loc1_ >= 0)
   {
      if(_loc2_[_loc1_].id == _loc3_)
      {
         return _loc1_;
      }
      _loc1_ = _loc1_ - 1;
   }
};
p.sortByDepth = function(a, b)
{
   if(a.depth < b.depth)
   {
      return -1;
   }
   if(a.depth > b.depth)
   {
      return 1;
   }
   return 0;
};
p.setSweepDefinition = function(id, definitionObject)
{
   var _loc2_ = definitionObject;
   var _loc3_ = this;
   var _loc1_ = _loc3_._newSweepsArray[_loc3_.getIndexFromID(id)].mc;
   for(var x in _loc2_)
   {
      _loc1_[x] = _loc2_[x];
   }
   _loc1_.useHandCursor = false;
   if(_loc1_.allowDragging && _loc1_.onPress != _loc3_.sweepOnPressFunc)
   {
      _loc1_.onPress = _loc3_.sweepOnPressFunc;
      _loc1_.onRelease = _loc3_.sweepOnReleaseFunc;
      _loc1_.onReleaseOutside = _loc3_.sweepOnReleaseOutsideFunc;
      _loc1_.onRollOver = _loc3_.sweepOnRollOverFunc;
      _loc1_.onRollOut = _loc3_.sweepOnRollOutFunc;
      _loc1_.onMouseMoveFunc = _loc3_.sweepOnMouseMoveFunc;
   }
   else if(!_loc1_.allowDragging)
   {
      delete _loc1_.onPress;
      delete _loc1_.onRelease;
      delete _loc1_.onReleaseOutside;
      delete _loc1_.onRollOver;
      delete _loc1_.onRollOut;
      delete _loc1_.onMouseMove;
      delete _loc1_.onMouseMoveFunc;
   }
   _loc3_.updateSweep(id);
};
p.updateAllSweeps = function()
{
   var _loc3_ = this;
   var _loc2_ = _loc3_._newSweepsArray;
   var _loc1_ = 0;
   while(_loc1_ < _loc2_.length)
   {
      _loc3_.updateSweep(_loc2_[_loc1_].id);
      _loc1_ = _loc1_ + 1;
   }
};
p.updateSweep = function(id)
{
   var _loc1_ = this._newSweepsArray[this.getIndexFromID(id)].mc;
   var lineMC = _loc1_.outlineMC;
   var cos = Math.cos;
   var sin = Math.sin;
   var abs = Math.abs;
   var r = this._safeRadius;
   var e = this._eccentricity;
   var k1 = Math.sqrt((1 + e) / (1 - e));
   var k2 = this._semimajorAxis * this._scale * (1 - e * e);
   var ma = _loc1_.sweepStart;
   var ea0 = 0;
   var ea1 = ma + e * sin(ma);
   var c = 0;
   do
   {
      ea0 = ea1;
      ea1 = ma + e * sin(ea0);
      c++;
   }
   while(abs(ea1 - ea0) > 0.001 && c < 100);
   var sta = 2 * Math.atan(k1 * Math.tan(ea1 / 2));
   ma += _loc1_.sweepDuration;
   var ea0 = 0;
   var ea1 = ma + e * sin(ma);
   var c = 0;
   do
   {
      ea0 = ea1;
      ea1 = ma + e * sin(ea0);
      c++;
   }
   while(abs(ea1 - ea0) > 0.001 && c < 100);
   var eta = 2 * Math.atan(k1 * Math.tan(ea1 / 2));
   _loc1_.startTrueAnomaly = (sta % 6.283185307179586 + 6.283185307179586) % 6.283185307179586;
   _loc1_.endTrueAnomaly = (eta % 6.283185307179586 + 6.283185307179586) % 6.283185307179586;
   _loc1_.startRadius = k2 / (1 + e * cos(sta));
   _loc1_.endRadius = k2 / (1 + e * cos(eta));
   var arc = ((eta - sta) % 6.283185307179586 + 6.283185307179586) % 6.283185307179586;
   var n = Math.ceil(arc * 2 / 3.141592653589793);
   var step = arc / n;
   _loc1_.clear();
   lineMC.clear();
   _loc1_.lineStyle(1,16711680,0);
   lineMC.lineStyle(_loc1_.outlineThickness,_loc1_.outlineColor,100);
   _loc1_.moveTo(0,0);
   lineMC.moveTo(0,0);
   _loc1_.beginFill(_loc1_.fillColor,100);
   var angle = sta;
   var x = (- r) * cos(angle);
   var _loc3_ = r * sin(angle);
   _loc1_.lineTo(x,_loc3_);
   lineMC.lineTo(x,_loc3_);
   var _loc2_ = 0;
   while(_loc2_ < n)
   {
      angle += step;
      var x = (- r) * cos(angle);
      _loc3_ = r * sin(angle);
      _loc1_.lineTo(x,_loc3_);
      lineMC.lineTo(x,_loc3_);
      _loc2_ = _loc2_ + 1;
   }
   _loc1_.lineTo(0,0);
   lineMC.lineTo(0,0);
   _loc1_.endFill();
};
p.removeSweep = function(id)
{
   var _loc2_ = this;
   var _loc1_ = _loc2_.getIndexFromID(id);
   _loc2_._newSweepsArray[_loc1_].mc.removeMovieClip();
   _loc2_._newSweepsArray.splice(_loc1_,1);
};
p.removeAllSweeps = function()
{
   var _loc1_ = this;
   _loc1_._newSweepsArray = [];
   delete _loc1_._activeSweep;
   _loc1_._parent.onSweepingStopped();
   _loc1_.systemMC.orbitalInteriorMC.createEmptyMovieClip("sweepsMC",20);
   _loc1_._topSweepDepth = 1;
   _loc1_._sweepCount = 1;
};
p.sweepOnPressFunc = function()
{
   var _loc2_ = this;
   var _loc3_;
   var _loc1_;
   if(Key.isDown(46))
   {
      _loc2_.systemComponent.removeSweep(_loc2_.id);
   }
   else
   {
      var atan = Math.atan;
      _loc3_ = _loc2_.systemComponent;
      var sysMC = _loc3_.systemMC;
      var lower = [];
      var upper = [];
      var dur = _loc3_._sweepDuration;
      var k = _loc3_.snapGap;
      var sa = _loc3_._newSweepsArray;
      for(var x in sa)
      {
         _loc1_ = sa[x].mc;
         if(_loc1_ != _loc2_)
         {
            lower.push({ta:_loc1_.startTrueAnomaly,m:atan(k / _loc1_.startRadius),ma:_loc1_.sweepStart - dur});
            upper.push({ta:_loc1_.endTrueAnomaly,m:atan(k / _loc1_.endRadius),ma:_loc1_.sweepStart + dur});
         }
      }
      lower.sort(_loc3_.sortOnTrueAnomaly);
      upper.sort(_loc3_.sortOnTrueAnomaly);
      _loc2_.lowerEdges = lower;
      _loc2_.upperEdges = upper;
      _loc2_.swapDepths(_loc3_._topSweepDepth);
      _loc3_._newSweepsArray[_loc3_.getIndexFromID(_loc2_.id)].depth = _loc3_._topSweepDepth;
      _loc3_._sortingNeeded = true;
      _loc3_._topSweepDepth = _loc3_._topSweepDepth + 1;
      var ta = 3.141592653589793 - Math.atan2(sysMC._ymouse,sysMC._xmouse);
      var ea = 2 * atan(Math.tan(ta / 2) / _loc3_._k1);
      var ma = ea - _loc3_._eccentricity * Math.sin(ea);
      _loc2_.dragOffset = ma - _loc2_.sweepStart;
      _loc2_.onMouseMove = _loc2_.onMouseMoveFunc;
   }
};
p.sortOnTrueAnomaly = function(a, b)
{
   if(a.ta < b.ta)
   {
      return -1;
   }
   if(a.ta > b.ta)
   {
      return 1;
   }
   return 0;
};
p.sweepOnMouseMoveFunc = function()
{
   var cos = Math.cos;
   var sin = Math.sin;
   var _loc2_ = Math.abs;
   var lower = this.lowerEdges;
   var upper = this.upperEdges;
   var componentMC = this.systemComponent;
   var sysMC = componentMC.systemMC;
   var dur = componentMC._sweepDuration;
   var e = componentMC._eccentricity;
   var k1 = componentMC._k1;
   var ta = 3.141592653589793 - Math.atan2(sysMC._ymouse,sysMC._xmouse);
   var ea = 2 * Math.atan(Math.tan(ta / 2) / componentMC._k1);
   var sma = ea - componentMC._eccentricity * Math.sin(ea) - this.dragOffset;
   var ma = sma;
   var ea0 = 0;
   var _loc3_ = ma + e * sin(ma);
   var c = 0;
   do
   {
      ea0 = _loc3_;
      _loc3_ = ma + e * sin(ea0);
      c++;
   }
   while(_loc2_(_loc3_ - ea0) > 0.001 && c < 100);
   var sta = 2 * Math.atan(k1 * Math.tan(_loc3_ / 2));
   ma += dur;
   var ea0 = 0;
   _loc3_ = ma + e * sin(ma);
   var c = 0;
   do
   {
      ea0 = _loc3_;
      _loc3_ = ma + e * sin(ea0);
      c++;
   }
   while(_loc2_(_loc3_ - ea0) > 0.001 && c < 100);
   var eta = 2 * Math.atan(k1 * Math.tan(_loc3_ / 2));
   sta = (sta % 6.283185307179586 + 6.283185307179586) % 6.283185307179586;
   eta = (eta % 6.283185307179586 + 6.283185307179586) % 6.283185307179586;
   var upperD = 1000000;
   var upperI = -1;
   var _loc1_ = 0;
   while(_loc1_ < upper.length)
   {
      var newD = _loc2_(sta - upper[_loc1_].ta);
      if(newD < upperD)
      {
         upperI = _loc1_;
         upperD = newD;
      }
      _loc1_ = _loc1_ + 1;
   }
   var newD = _loc2_(upper[upper.length - 1].ta - (sta + 6.283185307179586));
   if(newD < upperD)
   {
      upperI = upper.length - 1;
      upperD = newD;
   }
   var newD = _loc2_(sta - (upper[0].ta + 6.283185307179586));
   if(newD < upperD)
   {
      upperI = 0;
      upperD = newD;
   }
   var lowerD = 1000000;
   var lowerI = -1;
   _loc1_ = 0;
   while(_loc1_ < lower.length)
   {
      var newD = _loc2_(eta - lower[_loc1_].ta);
      if(newD < lowerD)
      {
         lowerI = _loc1_;
         lowerD = newD;
      }
      _loc1_ = _loc1_ + 1;
   }
   var newD = _loc2_(lower[lower.length - 1].ta - (eta + 6.283185307179586));
   if(newD < lowerD)
   {
      lowerI = lower.length - 1;
      lowerD = newD;
   }
   var newD = _loc2_(eta - (lower[0].ta + 6.283185307179586));
   if(newD < lowerD)
   {
      lowerI = 0;
      lowerD = newD;
   }
   if(upperD < lowerD)
   {
      if(upperD < upper[upperI].m)
      {
         var ma = upper[upperI].ma;
      }
      else
      {
         var ma = sma;
      }
   }
   else if(lowerD < lower[lowerI].m)
   {
      var ma = lower[lowerI].ma;
   }
   else
   {
      var ma = sma;
   }
   componentMC.setSweepDefinition(this.id,{sweepStart:ma});
   updateAfterEvent();
};
p.sweepOnReleaseFunc = function()
{
   delete this.onMouseMove;
};
p.sweepOnReleaseOutsideFunc = function()
{
   var _loc1_ = this;
   delete _loc1_.onMouseMove;
   _loc1_._alpha = _loc1_.mouseOutAlpha;
};
p.sweepOnRollOverFunc = function()
{
   var _loc1_ = this;
   if(_loc1_.allowDragging)
   {
      _loc1_._alpha = _loc1_.mouseOverAlpha;
   }
};
p.sweepOnRollOutFunc = function()
{
   this._alpha = this.mouseOutAlpha;
};
var p = KeplerianSystemClass.prototype;
p.minGridSpacing = 15;
p.gridFillStyle = {color:0,alpha:100};
p.gridLineStyle = {thickness:1,color:16777215};
p.axisGridLineStyle = {thickness:1,color:5089613,alpha:65};
p.minGridLineAlpha = 5;
p.maxGridLineAlpha = 25;
p.updateGrid = function()
{
   var startTimer = getTimer();
   var _loc1_ = this.systemMC.gridMC;
   _loc1_.clear();
   var ceil = Math.ceil;
   var s = this._scale;
   var leftX = - this.systemMC._x;
   var rightX = this._windowWidth + leftX;
   var topY = this._windowHeight / 2;
   var bottomY = - topY;
   _loc1_.moveTo(leftX,bottomY);
   _loc1_.lineStyle(1,16711680,0);
   _loc1_.beginFill(this.gridFillStyle.color,this.gridFillStyle.alpha);
   _loc1_.lineTo(leftX,topY);
   _loc1_.lineTo(rightX,topY);
   _loc1_.lineTo(rightX,bottomY);
   _loc1_.lineTo(leftX,bottomY);
   _loc1_.endFill();
   var m = this.minGridSpacing / s;
   var lg = Math.log(m) / 2.302585092994046;
   var k = ceil(lg);
   if(k - lg > 0.30102999566398114)
   {
      var belowSpacing = Math.pow(10,k - 1);
      var spacing = 5 * belowSpacing;
      var majorMultiple = 2;
   }
   else
   {
      var spacing = Math.pow(10,k);
      var belowSpacing = 0.5 * spacing;
      var majorMultiple = 5;
   }
   this.systemMC.scaleBarMC.update(majorMultiple * spacing * this._scale,majorMultiple * spacing + " AU");
   var leftFillExtent = leftX / s;
   var rightFillExtent = rightX / s;
   var topFillExtent = topY / s;
   var bottomFillExtent = bottomY / s;
   var leftGridExtent = ceil(leftFillExtent / spacing);
   var rightGridLimit = ceil(rightFillExtent / spacing);
   var topGridLimit = ceil(topFillExtent / spacing);
   var bottomGridExtent = ceil(bottomFillExtent / spacing);
   var minorAlpha = this.minGridLineAlpha + (this.maxGridLineAlpha - this.minGridLineAlpha) * (spacing - m) / (spacing - belowSpacing);
   var majorAlpha = this.maxGridLineAlpha;
   var _loc3_ = this.gridLineStyle.thickness;
   var gridColor = this.gridLineStyle.color;
   var originThickness = this.axisGridLineStyle.thickness;
   var originColor = this.axisGridLineStyle.color;
   var originAlpha = this.axisGridLineStyle.alpha;
   var _loc2_ = leftGridExtent;
   while(_loc2_ < rightGridLimit)
   {
      var x = _loc2_ * spacing * s;
      if(_loc2_ == 0)
      {
         _loc1_.lineStyle(originThickness,originColor,originAlpha);
      }
      else if(_loc2_ % majorMultiple == 0)
      {
         _loc1_.lineStyle(_loc3_,gridColor,majorAlpha);
      }
      else
      {
         _loc1_.lineStyle(_loc3_,gridColor,minorAlpha);
      }
      _loc1_.moveTo(x,bottomY);
      _loc1_.lineTo(x,topY);
      _loc2_ = _loc2_ + 1;
   }
   _loc2_ = bottomGridExtent;
   while(_loc2_ < topGridLimit)
   {
      var y = _loc2_ * spacing * s;
      if(_loc2_ == 0)
      {
         _loc1_.lineStyle(originThickness,originColor,originAlpha);
      }
      else if(_loc2_ % majorMultiple == 0)
      {
         _loc1_.lineStyle(_loc3_,gridColor,majorAlpha);
      }
      else
      {
         _loc1_.lineStyle(_loc3_,gridColor,minorAlpha);
      }
      _loc1_.moveTo(leftX,y);
      _loc1_.lineTo(rightX,y);
      _loc2_ = _loc2_ + 1;
   }
};
