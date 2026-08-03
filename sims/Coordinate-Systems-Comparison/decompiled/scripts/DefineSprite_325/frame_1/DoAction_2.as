function init()
{
   sphere2.size = 350;
   sphere1.size = 350;
   sphere1.latitude = 90;
   sphere1.siderealTime = 0;
   sphere1.showHorizonPlane = false;
   sphere2.setTheta(145);
   sphere1.setThetaAndPhi(100,20);
   sphere2.addShadedBand("CSGradientDisk","CSGradientDisk","neverRiseBand",null,"inner","full",{innerAlpha:30,innerColor:6316256,outerAlpha:30,outerColor:6316256});
   sphere2.addShadedBand("CSGradientDisk","CSGradientDisk","neverSetBand",null,"inner","full",{innerAlpha:30,innerColor:14704736,outerAlpha:30,outerColor:14704736});
   sphere2.addShadedBand("CSGradientDisk","CSGradientDisk","riseAndSetBand",null,"inner","full",{innerAlpha:30,innerColor:14737632,outerAlpha:30,outerColor:14737632});
   sphere1.addShadedBand("CSGradientDisk","CSGradientDisk","neverRiseBand",null,"inner","full",{innerAlpha:30,innerColor:6316256,outerAlpha:30,outerColor:6316256});
   sphere1.addShadedBand("CSGradientDisk","CSGradientDisk","neverSetBand",null,"inner","full",{innerAlpha:30,innerColor:14704736,outerAlpha:30,outerColor:14704736});
   sphere1.addShadedBand("CSGradientDisk","CSGradientDisk","riseAndSetBand",null,"inner","full",{innerAlpha:30,innerColor:14737632,outerAlpha:30,outerColor:14737632});
   sphere2.neverRiseBand.setBorderStyle(1,8421504,100);
   sphere2.neverSetBand.setBorderStyle(1,8421504,100);
   sphere2.riseAndSetBand.setBorderStyle(1,8421504,100);
   sphere2.neverRiseBand.showBorder = true;
   sphere2.neverSetBand.showBorder = true;
   sphere2.riseAndSetBand.showBorder = true;
   sphere1.neverRiseBand.setBorderStyle(1,8421504,100);
   sphere1.neverSetBand.setBorderStyle(1,8421504,100);
   sphere1.riseAndSetBand.setBorderStyle(1,8421504,100);
   sphere1.neverRiseBand.showBorder = true;
   sphere1.neverSetBand.showBorder = true;
   sphere1.riseAndSetBand.showBorder = true;
   sphere1.celestialBowl.removeMovieClip();
   sphere1.addShadingClip("Shading Layer B","shading1","back","inner","both");
   sphere1.addShadingClip("Shading Layer A","shading2","front","outer","both");
   sphere1.addShadingClip("Shading Layer A","shading3","back","outer","both");
   sphere2.celestialBowl.removeMovieClip();
   sphere2.addShadingClip("Shading Layer B","shading1","back","inner","both");
   sphere2.addShadingClip("Shading Layer A","shading2","front","outer","both");
   sphere2.addShadingClip("Shading Layer A","shading3","back","outer","both");
   sphere2.minViewerAltitude = 7;
   sphere2.addHorizonPlaneClip("Direction Labels Light","aboveLabels","above");
   sphere1.globeSphere.instance.sortObjects = false;
   sphere1.sortObjects = false;
   sphere2.sortObjects = false;
   sphere2.setSTimeAndLatDelayedUpdate = function(time, lat)
   {
      this._sTime = (time % 24 + 24) % 24 * 0.2617993877991494;
      if(lat > 90)
      {
         lat = 90;
      }
      else if(lat < -90)
      {
         lat = -90;
      }
      this._lat = lat * 0.017453292519943295;
      this.doM();
      this.doB();
   };
   sphere2.doSTimeAndLatUpdate = function()
   {
      this.updateObjects();
      this.updateCircles(true);
      this.updateLines(true);
      this.updateDeclinationTrails(true);
   };
   sphere1.setMouseBehavior("none");
   sphere1._mouseArea.onPress = function()
   {
      var _loc2_;
      var _loc3_;
      if(Key.isDown(16))
      {
         this.animationPaused = false;
         this.mouseMoved = true;
         _loc2_ = {};
         this._parent.getMouseRaDec(_loc2_);
         _loc3_ = this._parent._parent.addStar(_loc2_);
         if(_loc3_ != null)
         {
            this._parent._parent.selectStar(_loc3_);
         }
      }
      else
      {
         this.animationPaused = true;
         this._parent._parent.pauseAnimation();
         this.mouseMoved = false;
         this._dragXMouse = this._parent._xmouse;
         this._dragYMouse = this._parent._ymouse;
         this._dragTheta = this._parent._theta;
         this._dragPhi = this._parent._phi;
         this.onMouseMove = this.onMouseMoveFunc;
      }
   };
   sphere1._mouseArea.onMouseMoveFunc = function()
   {
      this.mouseMoved = true;
      this._parent.setThetaAndPhi(57.29577951308232 * (this._dragTheta - (this._parent._xmouse - this._dragXMouse) / this._parent._c.r),57.29577951308232 * (this._dragPhi + (this._parent._ymouse - this._dragYMouse) / this._parent._c.r));
      this._parent.onMouseUpdate.call(this._parent.onMouseUpdateInstance);
   };
   sphere1._mouseArea.onRelease = function()
   {
      if(this.animationPaused)
      {
         this._parent._parent.resumeAnimation();
      }
      if(!this.mouseMoved)
      {
         this._parent._parent.deselectSelectedStar();
      }
      delete this.onMouseMove;
   };
   sphere1._mouseArea.onReleaseOutside = function()
   {
      if(this.animationPaused)
      {
         this._parent._parent.resumeAnimation();
      }
      delete this.onMouseMove;
   };
   sphere2.setMouseBehavior("none");
   sphere2._mouseArea.onPress = sphere1._mouseArea.onPress;
   sphere2._mouseArea.onMouseMoveFunc = sphere1._mouseArea.onMouseMoveFunc;
   sphere2._mouseArea.onRelease = sphere1._mouseArea.onRelease;
   sphere2._mouseArea.onReleaseOutside = sphere1._mouseArea.onReleaseOutside;
   sphere2.setSiderealTimeDelayedUpdate = function(arg)
   {
      this._sTime = (arg % 24 + 24) % 24 * 0.2617993877991494;
      this.doM();
      this.doB();
   };
   sphere2.doSiderealTimeUpdate = function()
   {
      this.updateObjects();
      this.zeroHoursCircle.update();
      this.updateLines(true);
      this.updateDeclinationTrails(true);
   };
   sphere1.addCircle("meridian1",{thickness:1,color:14737632,alpha:30},{alt:0,az:0,tilt:90});
   sphere1.addCircle("meridian2",{thickness:1,color:14737632,alpha:30},{alt:0,az:90,tilt:90});
   sphere1.addCircle("meridian3",{thickness:1,color:14737632,alpha:30},{alt:0,az:0,tilt:0});
   sphere2.addCircle("meridian1",{thickness:1,color:14737632,alpha:30},{alt:0,az:0,tilt:90});
   sphere2.addCircle("meridian2",{thickness:1,color:14737632,alpha:30},{alt:0,az:90,tilt:90});
   sphere1.addCircle("zeroHoursCircle",{thickness:1,color:16769909,alpha:100},{ra:0,dec:0,tilt:90,gammaStart:-90,gammaEnd:90});
   sphere1.addCircle("celestialEquator",{thickness:1,color:16769909,alpha:100},{ra:0,dec:0,tilt:0});
   sphere2.addCircle("zeroHoursCircle",{thickness:1,color:16769909,alpha:100},{ra:0,dec:0,tilt:90,gammaStart:-90,gammaEnd:90});
   sphere2.addCircle("celestialEquator",{thickness:1,color:16769909,alpha:100},{ra:0,dec:0,tilt:0});
   raColor = 16756912;
   decColor = 16777136;
   azColor = 12632319;
   altColor = 16777215;
   sphere1.addObject("CS Label","raLabel",{ra:0,dec:0},{labelColor:raColor});
   sphere1.addObject("CS Label","decLabel",{ra:0,dec:0},{labelColor:decColor});
   sphere1.addCircle("raArc",{thickness:3,color:raColor,alpha:100},{ra:0,dec:0,tilt:0});
   sphere1.addCircle("decArc",{thickness:3,color:decColor,alpha:100},{ra:0,dec:0,tilt:0});
   sphere2.addObject("CS Label","azLabel",{alt:0,az:0},{labelColor:azColor});
   sphere2.addObject("CS Label","altLabel",{alt:0,az:0},{labelColor:altColor});
   sphere2.addCircle("azArc",{thickness:3,color:azColor,alpha:100},{az:0,alt:0,tilt:0});
   sphere2.addCircle("altArc",{thickness:3,color:altColor,alpha:100},{az:0,alt:0,tilt:0});
   var _loc2_ = 13684944;
   sphere2.addObject("CS Label","angle1Label",{alt:0,az:0},{labelColor:_loc2_});
   sphere2.addObject("CS Label","angle2Label",{alt:0,az:0},{labelColor:_loc2_});
   sphere2.addCircle("angle1Circle",{thickness:2,color:_loc2_,alpha:100},{alt:0,az:0,tilt:0});
   sphere2.addCircle("angle2Circle",{thickness:2,color:_loc2_,alpha:100},{alt:0,az:0,tilt:0});
   sphere1.raLabel.visible = false;
   sphere1.decLabel.visible = false;
   sphere2.azLabel.visible = false;
   sphere2.altLabel.visible = false;
   sphere1.addObject("CelestialSphere","globeSphere",{x:0,y:0,z:0,system:"celestial"},{_traceOn:false});
   sphere1.globeSphere.instance.showHorizonPlane = false;
   sphere1.globeSphere.instance.size = 60;
   sphere1.globeSphere.instance.latitude = 90;
   sphere1.globeSphere.instance.siderealTime = 0;
   sphere1.globeSphere.instance.setThetaAndPhi(sphere1.theta,sphere1.phi);
   sphere1.globeSphere.instance.customSetSiderealTime = function(arg)
   {
      this._sTime = (arg % 24 + 24) % 24 * 0.2617993877991494;
      this.doM();
      this.doB();
      this.updateObjects();
      this.longitudeCircle.update();
   };
   sphere1.addObject("NCP Label","ncpLabel",{ra:0,dec:85,r:1.13});
   sphere1.addObject("SCP Label","scpLabel",{ra:0,dec:-85,r:1.13});
   sphere2.addObject("NCP Label","ncpLabel",{ra:0,dec:85,r:1.16});
   sphere2.ncpLabel.setOrientationType("skewed",{ra:0,dec:90});
   sphere2.addObject("SCP Label","scpLabel",{ra:0,dec:-85,r:1.16});
   sphere2.scpLabel.setOrientationType("skewed",{ra:0,dec:90});
   sphere1.addObject("Celestial Equator Label","celestialEquatorLabel",{ra:3,dec:0,r:1.1});
   sphere1.celestialEquatorLabel.setOrientationType("absolute");
   sphere2.addObject("Celestial Equator Label","celestialEquatorLabel",{ra:3,dec:0,r:1.1});
   sphere2.celestialEquatorLabel.setOrientationType("absolute");
   sphere1.addObject("Zero Hours Label","zeroHoursLabel",{ra:0,dec:45,r:1.1});
   sphere1.zeroHoursLabel.setOrientationType("absolute",{ra:0,dec:45},{ra:18,dec:0});
   sphere2.addObject("Zero Hours Label","zeroHoursLabel",{ra:0,dec:45,r:1.1});
   sphere2.zeroHoursLabel.setOrientationType("absolute",{ra:0,dec:45},{ra:18,dec:0});
   sphere2.addObject("Meridian Label","meridianLabel",{az:180,alt:45,r:1.1});
   sphere2.meridianLabel.setOrientationType("absolute",{az:180,alt:45},{az:270,alt:0});
   sphere2.addObject("Zenith Label","zenithLabel",{az:0,alt:90,r:1.09});
   sphere2.zenithLabel.setOrientationType("skewed",{az:0,alt:90});
   sphere2.addObject("Nadir Label","nadirLabel",{az:0,alt:-90,r:1.09});
   sphere2.nadirLabel.setOrientationType("skewed",{az:0,alt:90});
   sphere2.addObject("Small Gray Dot","zenithDot",{az:0,alt:90});
   sphere2.zenithDot.setOrientationType("absolute");
   sphere2.addObject("Small Gray Dot","nadirDot",{az:0,alt:-90});
   sphere2.nadirDot.setOrientationType("absolute");
   sphere1.ncpLabel.visible = false;
   sphere1.scpLabel.visible = false;
   sphere1.celestialEquatorLabel.visible = false;
   sphere1.zeroHoursLabel.visible = false;
   sphere2.ncpLabel.visible = false;
   sphere2.scpLabel.visible = false;
   sphere2.celestialEquatorLabel.visible = false;
   sphere2.zeroHoursLabel.visible = false;
   sphere2.meridianLabel.visible = false;
   sphere2.zenithLabel.visible = false;
   sphere2.nadirLabel.visible = false;
   sphere2.zenithDot.visible = false;
   sphere2.nadirDot.visible = false;
   sphere1.globeSphere.instance.celestialBowl.removeMovieClip();
   sphere1.globeSphere.instance.addObject("GlobeComponent","globe",{x:0,y:0,z:0,system:"celestial"},{_traceOn:false});
   sphere1.globeSphere.instance.globe.instance.setScale(75);
   sphere1.addLine("ncpAxis",{thickness:2,color:7711231,alpha:100},{x:0,y:0,z:1,system:"celestial"},{x:0,y:0,z:1.2,system:"celestial"});
   sphere1.addLine("scpAxis",{thickness:2,color:7711231,alpha:100},{x:0,y:0,z:-1,system:"celestial"},{x:0,y:0,z:-1.2,system:"celestial"});
   sphere1.updateLines();
   sphere2.addLine("ncpAxis",{thickness:2,color:7711231,alpha:100},{x:0,y:0,z:1,system:"celestial"},{x:0,y:0,z:1.2,system:"celestial"});
   sphere2.addLine("scpAxis",{thickness:2,color:7711231,alpha:100},{x:0,y:0,z:-1,system:"celestial"},{x:0,y:0,z:-1.2,system:"celestial"});
   sphere2.updateLines();
   sphere2.addObject("Stickfigure","stickfigure",{x:0,y:0,z:0,system:"horizon"},{_xscale:120,_yscale:120});
   sphere2.stickfigure.setOrientationType("absolute",{x:-1,y:0,z:0,system:"horizon"},{x:0,y:0,z:1,system:"horizon"});
   sphere1.globeSphere.instance.addObject("Observer Dot","observerDot",{ra:0,dec:0});
   sphere1.globeSphere.instance.addCircle("latitudeCircle",{thickness:0,color:0,alpha:30},{ra:0,dec:0,tilt:0});
   sphere1.globeSphere.instance.addCircle("longitudeCircle",{thickness:0,color:0,alpha:30},{ra:0,dec:0,tilt:90,gammaStart:-90,gammaEnd:90});
   sphere1.globeSphere.instance.setMouseBehavior("none");
   sphere1.onMouseUpdate = function()
   {
      sphere1.globeSphere.instance.setThetaAndPhi(sphere1.theta,sphere1.phi);
      sphere1.globeSphere.instance.globe.instance.update();
      updateAfterEvent();
   };
   sphere2.onMouseUpdate = function()
   {
      updateAfterEvent();
   };
}
