function onReset()
{
   skipUpdate = true;
   if(onEnterFrame == onEnterFrameFunc)
   {
      toggleAnimation();
   }
   hideSunArcs();
   observerFeatureGroup.setValue("angle");
   viewTypeGroup.setValue("side");
   centeredObjectGroup.setValue("sun");
   showOrbitViewLabelsCheck.setValue(false);
   showEarthViewLabelsCheck.setValue(false);
   showSubSolarPointCheck.setValue(true);
   changeDayOfYear(40);
   daySlider.value = 40;
   changeLatitude(10);
   latitudeSelector.setLatitude(10);
   orbitViewMC.viewerAzimuth = 270;
   orbitViewMC.viewerAltitude = 30;
   orbitViewMC.onMouseUpdate.call(this);
   skipUpdate = false;
   update();
}
function changeObserverFeature()
{
   sunlightAngleViewMC._visible = observerFeatureGroup.getValue() == "angle";
   sunbeamSpreadDirectionLabelsMC._visible = sunbeamViewMC._visible = !sunlightAngleViewMC._visible;
   update();
}
function showSunArcs()
{
   orbitViewMC.sunRaArc.visible = true;
   orbitViewMC.sunDecArc.visible = true;
   orbitViewMC.raLabel.visible = true;
   orbitViewMC.decLabel.visible = true;
   orbitViewMC.updateObjects();
}
function hideSunArcs()
{
   orbitViewMC.sunRaArc.visible = false;
   orbitViewMC.sunDecArc.visible = false;
   orbitViewMC.raLabel.visible = false;
   orbitViewMC.decLabel.visible = false;
}
function onEnterFrameFunc()
{
   var _loc1_ = getTimer();
   daysSinceVE += animateRate * (_loc1_ - timeLast);
   daySlider.value = ((Math.round(daysSinceVE) - 286) % 365 + 365) % 365;
   dayOfYearField.text = getDayString(daySlider.value);
   update();
   timeLast = _loc1_;
}
function toggleAnimation()
{
   if(onEnterFrame == onEnterFrameFunc)
   {
      delete onEnterFrame;
      animateButton.setLabel("start animation");
   }
   else
   {
      timeLast = getTimer();
      onEnterFrame = onEnterFrameFunc;
      animateButton.setLabel("stop animation");
   }
}
function changeDayOfYear(arg)
{
   dayOfYearField.text = getDayString(arg);
   daysSinceVE = arg + 286;
   update();
}
function changeShowSubsolarPoint()
{
   if(showSubSolarPointCheck.getValue())
   {
      orbitViewMC.globeSphere.instance.subSolarPoint.visible = true;
      orbitViewMC.globeSphere.instance.updateObjects();
      earthViewSubSolarPointMC._visible = viewTypeGroup.getValue() == "sun";
      earthViewSideSubSolarPointMC._visible = !earthViewSubSolarPointMC._visible;
   }
   else
   {
      orbitViewMC.globeSphere.instance.subSolarPoint.visible = false;
      earthViewSubSolarPointMC._visible = false;
      earthViewSideSubSolarPointMC._visible = false;
   }
}
function changeLatitude(arg)
{
   observerLatitude = arg;
   latitudeField2.text = Math.abs(observerLatitude).toFixed(1) + "°";
   if(observerLatitude < 0)
   {
      latitudeField2.text += " S";
   }
   else if(observerLatitude > 0)
   {
      latitudeField2.text += " N";
   }
   latitudeField.text = "observer latitude: " + latitudeField2.text;
   latitudeSelector.setLatitude(arg);
   earthViewMC.latitudeCircle.setParameters({dec:arg,ra:0,tilt:0});
   earthViewMC.latitudeCircle.update();
   orbitViewMC.globeSphere.instance.latitudeCircle.setParameters({dec:arg,ra:0,tilt:0});
   orbitViewMC.globeSphere.instance.latitudeCircle.update();
   update();
}
function update()
{
   if(skipUpdate)
   {
      return undefined;
   }
   var _loc16_ = getTimer();
   var _loc1_ = 270 + daysSinceVE * 360 / 365;
   var _loc3_;
   var _loc5_;
   var _loc6_;
   var _loc7_;
   var _loc8_;
   if(centeredObjectGroup.getValue() == "sun")
   {
      orbitViewMC.globeSphere.setPosition({alt:0,az:180 - _loc1_});
      orbitViewMC.ray.setPosition({alt:0,az:180 - _loc1_,r:0.7});
      orbitViewMC.ray.setOrientationType("skewed",{alt:0,az:180 - _loc1_});
      orbitViewMC.globeSphere.instance.subSolarPoint.setPosition({alt:0,az:360 - _loc1_});
      orbitViewMC.globeSphere.instance.subSolarPoint.setOrientationType("absolute");
      orbitViewMC.globeSphere.instance.globe.instance.setSunDirection({alt:0,az:360 - _loc1_});
      orbitViewMC.globeSphere.instance.globe.instance.updateShading();
      _loc3_ = {};
      orbitViewMC.globeSphere.instance.pointToHorizon({dec:0,ra:12 + _loc1_ / 15},_loc3_);
      _loc5_ = ((-6 - _loc3_.az / 15) % 24 + 24) % 24;
      if(_loc5_ > 23.94)
      {
         _loc5_ = 23.94;
      }
      _loc6_ = _loc5_.toFixed(1) + "h";
      _loc7_ = _loc3_.alt.toFixed(1) + "°";
      raField.text = _loc6_;
      decField.text = _loc7_;
   }
   else
   {
      _loc8_ = 12 + _loc1_ / 15;
      orbitViewMC.sun.setPosition({dec:0,ra:_loc8_});
      orbitViewMC.sun.setOrientationType("absolute");
      orbitViewMC.ray.setPosition({dec:0,ra:12 + _loc1_ / 15,r:0.25});
      orbitViewMC.ray.setOrientationType("skewed",{dec:0,ra:_loc1_ / 15});
      _loc3_ = {};
      orbitViewMC.pointToHorizon({dec:0,ra:12 + _loc1_ / 15},_loc3_);
      _loc5_ = ((-6 - _loc3_.az / 15) % 24 + 24) % 24;
      if(_loc5_ > 23.94)
      {
         _loc5_ = 23.94;
      }
      _loc6_ = _loc5_.toFixed(1) + "h";
      _loc7_ = _loc3_.alt.toFixed(1) + "°";
      raField.text = _loc6_;
      decField.text = _loc7_;
      orbitViewMC.raLabel.setPosition({alt:4,az:_loc3_.az + 12});
      orbitViewMC.raLabel.instance.labelText = _loc6_;
      orbitViewMC.raLabel.setOrientationType("absolute");
      orbitViewMC.decLabel.setPosition({az:_loc3_.az - 9,alt:_loc3_.alt / 2});
      orbitViewMC.decLabel.instance.labelText = _loc7_;
      orbitViewMC.decLabel.setOrientationType("absolute");
      orbitViewMC.sunRaArc.setParameters({alt:0,az:0,tilt:180,gammaStart:_loc3_.az,gammaEnd:-90});
      if(_loc3_.alt < 0)
      {
         orbitViewMC.sunDecArc.setParameters({alt:0,az:_loc3_.az,tilt:90,gammaStart:_loc3_.alt,gammaEnd:0});
      }
      else
      {
         orbitViewMC.sunDecArc.setParameters({alt:0,az:_loc3_.az,tilt:90,gammaStart:0,gammaEnd:_loc3_.alt});
      }
      orbitViewMC.sunDecArc.update();
      orbitViewMC.sunRaArc.update();
      orbitViewMC.globeSphere.instance.subSolarPoint.setPosition(_loc3_);
      orbitViewMC.globeSphere.instance.subSolarPoint.setOrientationType("absolute");
      orbitViewMC.globeSphere.instance.globe.instance.setSunDirection(_loc3_);
      orbitViewMC.globeSphere.instance.globe.instance.updateShading();
   }
   orbitViewMC.globeSphere.instance.updateObjects();
   orbitViewMC.updateObjects();
   _loc3_ = {};
   orbitViewMC.pointToHorizon({dec:0,ra:12 + _loc1_ / 15},_loc3_);
   var _loc2_ = 90 - observerLatitude + _loc3_.alt;
   if(observerFeatureGroup.getValue() == "angle")
   {
      if(_loc2_ > 90)
      {
         _loc2_ = 180 - _loc2_;
         sunlightAngleViewMC.sunDirection = "N";
      }
      else
      {
         sunlightAngleViewMC.sunDirection = "S";
      }
      sunlightAngleViewMC.sunAltitude = _loc2_;
      sunlightAngleViewMC.update();
   }
   else
   {
      if(_loc2_ > 90)
      {
         _loc2_ = 180 - _loc2_;
      }
      sunbeamViewMC.sunAltitude = _loc2_;
      sunbeamViewMC.update();
   }
   altitudeField.text = "sun\'s altitude: " + _loc2_.toFixed(1) + "°";
   var _loc4_;
   if(viewTypeGroup.getValue() == "sun")
   {
      _loc4_ = 6 + _loc1_ / 15;
      earthViewMC.tropicOfCancerLabel.setPosition({dec:23.4,ra:_loc4_,r:1.05});
      earthViewMC.tropicOfCapricornLabel.setPosition({dec:-23.4,ra:_loc4_,r:1.05});
      earthViewMC.equatorLabel.setPosition({dec:0,ra:_loc4_,r:1.05});
      earthViewMC.arcticCircleLabel.setPosition({dec:66.6,ra:_loc4_,r:1.05});
      earthViewMC.antarcticCircleLabel.setPosition({dec:-66.6,ra:_loc4_,r:1.05});
      earthViewMC.setThetaAndPhi(_loc1_,0);
   }
   else
   {
      _loc4_ = _loc1_ / 15;
      earthViewMC.tropicOfCancerLabel.setPosition({dec:23.4,ra:_loc4_,r:1.05});
      earthViewMC.tropicOfCapricornLabel.setPosition({dec:-23.4,ra:_loc4_,r:1.05});
      earthViewMC.equatorLabel.setPosition({dec:0,ra:_loc4_,r:1.05});
      earthViewMC.arcticCircleLabel.setPosition({dec:66.6,ra:_loc4_,r:1.05});
      earthViewMC.antarcticCircleLabel.setPosition({dec:-66.6,ra:_loc4_,r:1.05});
      earthViewMC.setThetaAndPhi(_loc1_ - 90,0);
      _loc3_ = {};
      orbitViewMC.pointToHorizon({dec:0,ra:12 + _loc1_ / 15},_loc3_);
      raysMC._rotation = - _loc3_.alt;
      earthViewSideSubSolarPointMC._x = earthViewMC._x + 75 * Math.cos(_loc3_.alt * 3.141592653589793 / 180);
      earthViewSideSubSolarPointMC._y = earthViewMC._y - 75 * Math.sin(_loc3_.alt * 3.141592653589793 / 180);
      earthViewSideSubSolarPointMC._rotation = - _loc3_.alt;
      _loc3_.az += 180;
      earthViewMC.globe.instance.setSunDirection(_loc3_);
      earthViewMC.globe.instance.updateShading();
   }
   earthViewMC.globe.instance.update();
   earthViewMC.globe.instance.updateAxes();
   updateOrbitalPlane();
}
function updateOrbitalPlane()
{
   var _loc3_ = 2;
   var _loc2_ = 9474192;
   var _loc5_ = orbitViewMC.createEmptyMovieClip("orbitalPlaneBehindOutsideMC",orbitViewMC._N - 123);
   var _loc11_ = orbitViewMC.createEmptyMovieClip("orbitalPlaneBehindInsideMC",2 * orbitViewMC._N - 123);
   var _loc9_ = orbitViewMC.createEmptyMovieClip("orbitalPlaneInFrontInsideMC",4 * orbitViewMC._N - 123);
   var _loc4_ = orbitViewMC.createEmptyMovieClip("orbitalPlaneInFrontOutsideMC",6 * orbitViewMC._N - 123);
   var _loc8_;
   var _loc10_;
   var _loc12_;
   var _loc6_;
   var _loc7_;
   var _loc1_;
   if(centeredObjectGroup.getValue() == "sun")
   {
      _loc5_._yscale = _loc11_._yscale = _loc9_._yscale = _loc4_._yscale = 100 * Math.sin(orbitViewMC._phi);
      _loc8_ = 0.017453292519943295 * (orbitViewMC.viewerAzimuth - 90 - orbitViewMC.globeSphere.az);
      _loc8_ = (_loc8_ % 6.283185307179586 + 6.283185307179586) % 6.283185307179586;
      _loc10_ = 1 - orbitViewMC.globeSphere.instance._c.r2 / (2 * orbitViewMC._c.r2);
      if(_loc10_ > 1)
      {
         _loc10_ = 1;
      }
      else if(_loc10_ < -1)
      {
         _loc10_ = -1;
      }
      _loc12_ = Math.acos(_loc10_);
      _loc6_ = ((_loc8_ - _loc12_) % 6.283185307179586 + 6.283185307179586) % 6.283185307179586;
      _loc7_ = ((_loc8_ + _loc12_) % 6.283185307179586 + 6.283185307179586) % 6.283185307179586;
      _loc1_ = orbitViewMC._c.r;
      if(_loc6_ > _loc7_)
      {
         _loc5_.lineStyle(_loc3_,_loc2_);
         _loc5_.drawArc(0,0,_loc1_,_loc7_,3.141592653589793);
         _loc4_.lineStyle(_loc3_,_loc2_);
         _loc4_.drawArc(0,0,_loc1_,3.141592653589793,_loc6_);
      }
      else if(_loc6_ < 3.141592653589793 && _loc7_ > 3.141592653589793)
      {
         _loc5_.lineStyle(_loc3_,_loc2_);
         _loc5_.drawArc(0,0,_loc1_,0,_loc6_);
         _loc4_.lineStyle(_loc3_,_loc2_);
         _loc4_.drawArc(0,0,_loc1_,_loc7_,6.283185307179586);
      }
      else if(_loc6_ < 3.141592653589793)
      {
         if(_loc8_ < 1.5707963267948966)
         {
            _loc11_.lineStyle(_loc3_,_loc2_);
            _loc11_.drawArc(0,0,_loc1_,0,_loc6_);
            _loc5_.lineStyle(_loc3_,_loc2_);
            _loc5_.drawArc(0,0,_loc1_,_loc7_,3.141592653589793);
         }
         else
         {
            _loc5_.lineStyle(_loc3_,_loc2_);
            _loc5_.drawArc(0,0,_loc1_,0,_loc6_);
            _loc11_.lineStyle(_loc3_,_loc2_);
            _loc11_.drawArc(0,0,_loc1_,_loc7_,3.141592653589793);
         }
         _loc4_.lineStyle(_loc3_,_loc2_);
         _loc4_.drawArc(0,0,_loc1_,3.141592653589793,6.283185307179586);
      }
      else
      {
         if(_loc8_ < 4.71238898038469)
         {
            _loc9_.lineStyle(_loc3_,_loc2_);
            _loc9_.drawArc(0,0,_loc1_,3.141592653589793,_loc6_);
            _loc4_.lineStyle(_loc3_,_loc2_);
            _loc4_.drawArc(0,0,_loc1_,_loc7_,6.283185307179586);
         }
         else
         {
            _loc4_.lineStyle(_loc3_,_loc2_);
            _loc4_.drawArc(0,0,_loc1_,3.141592653589793,_loc6_);
            _loc9_.lineStyle(_loc3_,_loc2_);
            _loc9_.drawArc(0,0,_loc1_,_loc7_,6.283185307179586);
         }
         _loc5_.lineStyle(_loc3_,_loc2_);
         _loc5_.drawArc(0,0,_loc1_,0,3.141592653589793);
      }
   }
}
function changeShowOrbitViewLabels()
{
   if(showOrbitViewLabelsCheck.getValue())
   {
      orbitViewMC.toAELabel.visible = true;
      orbitViewMC.toWSLabel.visible = true;
      orbitViewMC.toVELabel.visible = true;
      orbitViewMC.toSSLabel.visible = true;
      if(centeredObjectGroup.getValue() == "sun")
      {
         orbitViewMC.celestialEquatorLabel.visible = false;
         orbitViewMC.eclipticLabel.visible = false;
         orbitViewMC.ncpLabel.visible = false;
         orbitViewMC.scpLabel.visible = false;
         orbitViewMC.orbitPathLabel.visible = true;
         orbitViewMC.toAELabel.setPosition({x:0,y:toLabelsDistSunCentered,z:0,system:"horizon"});
         orbitViewMC.toWSLabel.setPosition({x:- toLabelsDistSunCentered,y:0,z:0,system:"horizon"});
         orbitViewMC.toVELabel.setPosition({x:0,y:- toLabelsDistSunCentered,z:0,system:"horizon"});
         orbitViewMC.toSSLabel.setPosition({x:toLabelsDistSunCentered,y:0,z:0,system:"horizon"});
         orbitViewMC.toAELabel.setOrientationType("absolute",{x:0,y:0,z:1,system:"horizon"},{x:0,y:1,z:0,system:"horizon"});
         orbitViewMC.toWSLabel.setOrientationType("absolute",{x:0,y:0,z:1,system:"horizon"},{x:-1,y:0,z:0,system:"horizon"});
         orbitViewMC.toVELabel.setOrientationType("absolute",{x:0,y:0,z:1,system:"horizon"},{x:0,y:-1,z:0,system:"horizon"});
         orbitViewMC.toSSLabel.setOrientationType("absolute",{x:0,y:0,z:1,system:"horizon"},{x:1,y:0,z:0,system:"horizon"});
      }
      else
      {
         orbitViewMC.celestialEquatorLabel.visible = true;
         orbitViewMC.eclipticLabel.visible = true;
         orbitViewMC.ncpLabel.visible = true;
         orbitViewMC.scpLabel.visible = true;
         orbitViewMC.orbitPathLabel.visible = false;
         orbitViewMC.toAELabel.setPosition({x:0,y:- toLabelsDistEarthCentered,z:0,system:"celestial"});
         orbitViewMC.toWSLabel.setPosition({x:toLabelsDistEarthCentered,y:0,z:0,system:"celestial"});
         orbitViewMC.toVELabel.setPosition({x:0,y:toLabelsDistEarthCentered,z:0,system:"celestial"});
         orbitViewMC.toSSLabel.setPosition({x:- toLabelsDistEarthCentered,y:0,z:0,system:"celestial"});
         orbitViewMC.toAELabel.setOrientationType("absolute",{x:0,y:0,z:1,system:"celestial"},{x:0,y:-1,z:0,system:"celestial"});
         orbitViewMC.toWSLabel.setOrientationType("absolute",{x:0,y:0,z:1,system:"celestial"},{x:1,y:0,z:0,system:"celestial"});
         orbitViewMC.toVELabel.setOrientationType("absolute",{x:0,y:0,z:1,system:"celestial"},{x:0,y:1,z:0,system:"celestial"});
         orbitViewMC.toSSLabel.setOrientationType("absolute",{x:0,y:0,z:1,system:"celestial"},{x:-1,y:0,z:0,system:"celestial"});
      }
      orbitViewMC.onMouseUpdate.call(this);
   }
   else
   {
      orbitViewMC.celestialEquatorLabel.visible = false;
      orbitViewMC.eclipticLabel.visible = false;
      orbitViewMC.ncpLabel.visible = false;
      orbitViewMC.scpLabel.visible = false;
      orbitViewMC.orbitPathLabel.visible = false;
      orbitViewMC.toAELabel.visible = false;
      orbitViewMC.toWSLabel.visible = false;
      orbitViewMC.toVELabel.visible = false;
      orbitViewMC.toSSLabel.visible = false;
   }
}
function changeShowEarthViewLabels()
{
   if(showEarthViewLabelsCheck.getValue())
   {
      earthViewMC.tropicOfCancerLabel.visible = true;
      earthViewMC.tropicOfCapricornLabel.visible = true;
      earthViewMC.equatorLabel.visible = true;
      earthViewMC.arcticCircleLabel.visible = true;
      earthViewMC.antarcticCircleLabel.visible = true;
      earthViewMC.southPoleLabel.visible = true;
      earthViewMC.northPoleLabel.visible = true;
      earthViewMC.updateObjects();
   }
   else
   {
      earthViewMC.tropicOfCancerLabel.visible = false;
      earthViewMC.tropicOfCapricornLabel.visible = false;
      earthViewMC.equatorLabel.visible = false;
      earthViewMC.arcticCircleLabel.visible = false;
      earthViewMC.antarcticCircleLabel.visible = false;
      earthViewMC.southPoleLabel.visible = false;
      earthViewMC.northPoleLabel.visible = false;
   }
}
function changeCenteredObject()
{
   if(centeredObjectGroup.getValue() == "sun")
   {
      instructions1MC._visible = false;
      instructions4MC._visible = true;
      orbitViewMC.globeSphere.instance.globe.instance.setRotationAngle(0);
      orbitViewMC.meridian1.visible = false;
      orbitViewMC.meridian2.visible = false;
      orbitViewMC.outsideOfSphere._visible = false;
      orbitViewMC.sun.setPosition({x:0,y:0,z:0,system:"horizon"});
      orbitViewMC.scpMarker.visible = false;
      orbitViewMC.ncpMarker.visible = false;
      orbitViewMC.orbitalPath.visible = false;
      orbitViewMC.celestialEquator.visible = false;
      orbitViewMC.sun.setOrientationType("flat");
      orbitViewMC.sun.instance._xscale = 87;
      orbitViewMC.sun.instance._yscale = 87;
      orbitViewMC.globeSphere.instance.latitude = 66.6;
      orbitViewMC.sun.instance.setDraggable(false);
      orbitViewMC.globeSphere.instance.globe.instance.setDraggable(true);
      orbitViewBackgroundMC.setDraggable(true);
      orbitViewMC.size = sizeSunCentered;
   }
   else
   {
      orbitViewMC.orbitalPath.visible = true;
      instructions1MC._visible = true;
      instructions4MC._visible = false;
      orbitViewMC.globeSphere.instance.globe.instance.setRotationAngle(180);
      orbitViewMC.meridian1.visible = true;
      orbitViewMC.meridian2.visible = true;
      orbitViewMC.celestialEquator.visible = true;
      orbitViewMC.outsideOfSphere._visible = true;
      orbitViewMC.globeSphere.setPosition({x:0,y:0,z:0,system:"horizon"});
      orbitViewMC.sun.instance._xscale = 50;
      orbitViewMC.sun.instance._yscale = 50;
      orbitViewMC.scpMarker.visible = true;
      orbitViewMC.ncpMarker.visible = true;
      orbitViewMC.orbitalPath.setStyle(1,4688176,100);
      orbitViewMC.celestialEquator.setStyle(1,10526880,100);
      orbitViewMC.globeSphere.instance.latitude = 90;
      orbitViewMC.sun.instance.setDraggable(true);
      orbitViewMC.globeSphere.instance.globe.instance.setDraggable(false);
      orbitViewBackgroundMC.setDraggable(false);
      orbitViewMC.size = sizeEarthCentered;
   }
   changeShowOrbitViewLabels();
   orbitViewMC.globeSphere.instance.globe.instance.update();
   orbitViewMC.globeSphere.instance.globe.instance.updateAxes();
   orbitViewMC.updateCircles();
   update();
}
function setEarthViewType()
{
   if(viewTypeGroup.getValue() == "sun")
   {
      instructions3MC._visible = true;
      instructions2MC._visible = false;
      raysMC._visible = false;
      earthViewMC.globe.instance.setFills("GlobeComponentWater","GlobeComponentWater");
      earthViewMC.latitude = 66.6;
      earthViewMC.globe.instance.setSunDirection(null);
      earthViewMC.globe.instance.updateShading();
      earthViewSubSolarPointMC._visible = showSubSolarPointCheck.getValue();
      earthViewSideSubSolarPointMC._visible = false;
      latitudeSelector._visible = false;
      earthViewMC._x = sunViewX;
   }
   else
   {
      instructions3MC._visible = false;
      instructions2MC._visible = true;
      raysMC._visible = true;
      earthViewMC.globe.instance.setFills("Side View","Side View");
      earthViewMC.latitude = 90;
      earthViewSubSolarPointMC._visible = false;
      earthViewSideSubSolarPointMC._visible = showSubSolarPointCheck.getValue();
      latitudeSelector._visible = true;
      earthViewMC._x = sideViewX;
   }
   changeShowEarthViewLabels();
   update();
}
function init()
{
   earthViewMC.siderealTime = 0;
   earthViewMC.size = 150;
   earthViewMC.latitude = 66.6;
   earthViewMC.celestialBowl.removeMovieClip();
   earthViewMC.showHorizonPlane = false;
   earthViewMC.setMouseBehavior("none");
   earthViewMC.addCircle("lat_0",{thickness:1,color:4688176,alpha:60},{ra:0,dec:0,tilt:0});
   earthViewMC.addCircle("lat_66N",{thickness:1,color:4688176,alpha:60},{ra:0,dec:66.6,tilt:0});
   earthViewMC.addCircle("lat_66S",{thickness:1,color:4688176,alpha:60},{ra:0,dec:-66.6,tilt:0});
   earthViewMC.addCircle("lat_23N",{thickness:1,color:4688176,alpha:60},{ra:0,dec:23.4,tilt:0});
   earthViewMC.addCircle("lat_23S",{thickness:1,color:4688176,alpha:60},{ra:0,dec:-23.4,tilt:0});
   earthViewMC.addObject("Antarctic Circle Label","antarcticCircleLabel",{ra:0,dec:23.4});
   earthViewMC.addObject("Arctic Circle Label","arcticCircleLabel",{ra:0,dec:23.4});
   earthViewMC.addObject("Tropic of Cancer Label","tropicOfCancerLabel",{ra:0,dec:23.4});
   earthViewMC.addObject("Equator Label","equatorLabel",{ra:0,dec:23.4});
   earthViewMC.addObject("Tropic of Capricorn Label","tropicOfCapricornLabel",{ra:0,dec:23.4});
   earthViewMC.addObject("North Pole Label","northPoleLabel",{ra:0,dec:90,r:1});
   earthViewMC.addObject("South Pole Label","southPoleLabel",{ra:0,dec:-90,r:1});
   latitudeCircleColor = 16711680;
   earthViewMC.addCircle("latitudeCircle",{thickness:2,color:latitudeCircleColor,alpha:50},{ra:0,dec:0,tilt:0});
   earthViewMC.latitudeCircle.setUseMouseFunctions(true,"front only");
   earthViewMC.latitudeCircle.onRollOver = function()
   {
      redUpDownArrowsMC._visible = true;
      earthViewMC.latitudeCircle.setStyle(3,latitudeCircleColor,100);
      earthViewMC.latitudeCircle.update();
   };
   earthViewMC.latitudeCircle.onRollOut = function()
   {
      redUpDownArrowsMC._visible = false;
      earthViewMC.latitudeCircle.setStyle(2,latitudeCircleColor,50);
      earthViewMC.latitudeCircle.update();
   };
   earthViewMC.latitudeCircle.onReleaseOutside = function()
   {
      redUpDownArrowsMC._visible = false;
      earthViewMC.latitudeCircle.setStyle(2,latitudeCircleColor,50);
      earthViewMC.latitudeCircle.update();
      delete earthViewMC.latitudeCircle._front.onMouseMove;
   };
   earthViewMC.latitudeCircle.onRelease = function()
   {
      delete earthViewMC.latitudeCircle._front.onMouseMove;
   };
   earthViewMC.latitudeCircle.onPress = function()
   {
      earthViewMC.latitudeCircle._front.onMouseMove = earthViewMC.latitudeCircle.onMouseMoveFunc;
   };
   earthViewMC.latitudeCircle.onMouseMoveFunc = function()
   {
      var _loc2_ = {};
      this._thisCircle._parent.getMouseRaDec(_loc2_);
      if(_loc2_.ra == null)
      {
         return undefined;
      }
      this._thisCircle._parent._parent.changeLatitude(_loc2_.dec);
      updateAfterEvent();
   };
   earthViewMC.addObject("GlobeComponent","globe",{x:0,y:0,z:0,system:"celestial"},{_traceOn:false});
   earthViewMC.globe.instance.setScale(187.5);
   earthViewMC.globe.instance.update();
   earthViewMC.globe.instance.updateAxes();
   orbitViewMC.siderealTime = 12;
   orbitViewMC.size = sizeSunCentered;
   orbitViewMC.latitude = 66.6;
   orbitViewMC.celestialBowl.removeMovieClip();
   orbitViewMC.addShadingClip("sphere outside","outsideOfSphere","front","inner","both");
   orbitViewMC.showHorizonPlane = false;
   orbitViewMC.addCircle("meridian1",{thickness:1,color:9474192,alpha:30},{alt:0,az:0,tilt:90});
   orbitViewMC.addCircle("meridian2",{thickness:1,color:9474192,alpha:30},{alt:0,az:90,tilt:90});
   orbitViewMC.addCircle("orbitalPath",{thickness:1,color:16777215,alpha:100},{alt:0,az:0,tilt:0});
   orbitViewMC.addCircle("celestialEquator",{thickness:1,color:4688176,alpha:100},{ra:18,dec:0,tilt:0});
   orbitViewMC.updateCircles();
   var _loc11_ = 16777215;
   var _loc10_ = 16665419;
   orbitViewMC.addObject("CS Label","raLabel",{ra:0,dec:0},{labelColor:_loc11_});
   orbitViewMC.addObject("CS Label","decLabel",{ra:0,dec:0},{labelColor:_loc10_});
   orbitViewMC.addCircle("sunRaArc",{thickness:3,color:_loc11_,alpha:100},{alt:0,az:0,tilt:90});
   orbitViewMC.addCircle("sunDecArc",{thickness:3,color:_loc10_,alpha:100},{alt:0,az:0,tilt:90});
   orbitViewMC.addObject("CelestialSphere","globeSphere",{x:0,y:0,z:0,system:"celestial"},{_traceOn:false});
   orbitViewMC.globeSphere.instance.setMouseBehavior("none");
   orbitViewMC.globeSphere.instance.siderealTime = 12;
   orbitViewMC.globeSphere.instance.size = 52;
   orbitViewMC.globeSphere.instance.latitude = 66.6;
   orbitViewMC.globeSphere.instance.showHorizonPlane = false;
   orbitViewMC.globeSphere.instance.celestialBowl.removeMovieClip();
   orbitViewMC.globeSphere.instance.addCircle("lat_0",{thickness:1,color:4688176,alpha:60},{ra:0,dec:0,tilt:0});
   orbitViewMC.globeSphere.instance.addCircle("lat_66N",{thickness:1,color:4688176,alpha:60},{ra:0,dec:66.6,tilt:0});
   orbitViewMC.globeSphere.instance.addCircle("lat_66S",{thickness:1,color:4688176,alpha:60},{ra:0,dec:-66.6,tilt:0});
   orbitViewMC.globeSphere.instance.addCircle("lat_23N",{thickness:1,color:4688176,alpha:60},{ra:0,dec:23.4,tilt:0});
   orbitViewMC.globeSphere.instance.addCircle("lat_23S",{thickness:1,color:4688176,alpha:60},{ra:0,dec:-23.4,tilt:0});
   orbitViewMC.globeSphere.instance.addCircle("latitudeCircle",{thickness:1,color:latitudeCircleColor,alpha:40},{ra:0,dec:0,tilt:0});
   orbitViewMC.globeSphere.instance.addObject("GlobeComponent","globe",{x:0,y:0,z:0,system:"horizon"},{_traceOn:false});
   orbitViewMC.globeSphere.instance.globe.instance.setScale(100 * orbitViewMC.globeSphere.instance.size / 80);
   orbitViewMC.globeSphere.instance.globe.instance.setFills("Land Simple","Water Simple");
   orbitViewMC.globeSphere.instance.globe.instance.update();
   orbitViewMC.globeSphere.instance.globe.instance.updateAxes();
   var _loc3_ = orbitViewMC.globeSphere.instance.globe.instance;
   _loc3_.useHandCursor = false;
   _loc3_.setDraggable = function(arg)
   {
      if(arg)
      {
         this.onPress = this.onPressFunc;
         this.onRelease = this.onReleaseFunc;
         this.onReleaseOutside = this.onReleaseOutsideFunc;
      }
      else
      {
         delete this.onPress;
         delete this.onRelease;
         delete this.onReleaseOutside;
         delete this.onMouseMove;
      }
   };
   _loc3_.onPressFunc = function()
   {
      this.xOffset = this._sphere._parent._x - this._sphere._sphere._xmouse;
      this.yOffset = this._sphere._parent._y - this._sphere._sphere._ymouse;
      this.onMouseMove = this.onMouseMoveFunc;
   };
   _loc3_.onReleaseFunc = function()
   {
      delete this.onMouseMove;
   };
   _loc3_.onReleaseOutsideFunc = function()
   {
      delete this.onMouseMove;
   };
   _loc3_.onMouseMoveFunc = function()
   {
      var _loc5_ = this.xOffset + this._sphere._sphere._xmouse;
      var _loc3_ = this.yOffset + this._sphere._sphere._ymouse;
      var _loc2_ = this._sphere._sphere._c;
      var _loc7_ = _loc2_.r * _loc2_.r - _loc5_ * _loc5_ - _loc3_ * _loc3_;
      if(_loc7_ < 0)
      {
         _loc7_ = 0;
      }
      var _loc4_ = Math.sqrt(_loc7_);
      if(this._sphere._sphere._phi > 0 && _loc3_ < 0 || this._sphere._sphere._phi < 0 && _loc3_ > 0)
      {
         _loc4_ = - _loc4_;
      }
      var _loc8_ = -57.29577951308232 * Math.atan2(_loc2_.a1 * _loc5_ + _loc2_.a4 * _loc3_ + _loc2_.a7 * _loc4_,_loc2_.a0 * _loc5_ + _loc2_.a3 * _loc3_ + _loc2_.a6 * _loc4_);
      var _loc6_ = (- _loc8_) * 1.0138888888888888 - 377.25;
      _loc6_ = (Math.round(_loc6_) % 365 + 365) % 365;
      this._sphere._sphere._parent.changeDayOfYear(_loc6_);
      this._sphere._sphere._parent.daySlider.value = _loc6_;
      updateAfterEvent();
   };
   orbitViewMC.addObject("Sun Icon","sun",{x:0,y:0,z:0,system:"horizon"});
   orbitViewMC.addObject("Ray Component","ray",{alt:0,az:45,r:0.05},{length:95});
   orbitViewMC.globeSphere.instance.addObject("Symbol 113","subSolarPoint",{x:0,y:0,z:0,system:"horizon"});
   orbitViewMC.globeSphere.instance.update();
   orbitViewMC.addObject("Celestial Equator Label","celestialEquatorLabel",{ra:0,dec:0});
   orbitViewMC.addObject("Ecliptic Label","eclipticLabel",{ra:0,dec:0});
   orbitViewMC.addObject("NCP Label","ncpLabel",{az:0,alt:90});
   orbitViewMC.addObject("SCP Label","scpLabel",{az:0,alt:-90});
   orbitViewMC.addObject("Orbit Path Label","orbitPathLabel",{az:0,alt:0});
   orbitViewMC.addObject("toAELabel","toAELabel",{x:0,y:toLabelsDistSunCentered,z:0,system:"horizon"});
   orbitViewMC.addObject("toWSLabel","toWSLabel",{x:- toLabelsDistSunCentered,y:0,z:0,system:"horizon"});
   orbitViewMC.addObject("toVELabel","toVELabel",{x:0,y:- toLabelsDistSunCentered,z:0,system:"horizon"});
   orbitViewMC.addObject("toSSLabel","toSSLabel",{x:toLabelsDistSunCentered,y:0,z:0,system:"horizon"});
   orbitViewMC.toAELabel.setOrientationType("absolute",{x:0,y:0,z:1,system:"horizon"},{x:0,y:1,z:0,system:"horizon"});
   orbitViewMC.toWSLabel.setOrientationType("absolute",{x:0,y:0,z:1,system:"horizon"},{x:-1,y:0,z:0,system:"horizon"});
   orbitViewMC.toVELabel.setOrientationType("absolute",{x:0,y:0,z:1,system:"horizon"},{x:0,y:-1,z:0,system:"horizon"});
   orbitViewMC.toSSLabel.setOrientationType("absolute",{x:0,y:0,z:1,system:"horizon"},{x:1,y:0,z:0,system:"horizon"});
   orbitViewMC.addObject("Marker","ncpMarker",{az:0,alt:90});
   orbitViewMC.addObject("Marker","scpMarker",{az:0,alt:-90});
   orbitViewMC.ncpMarker.setOrientationType("absolute");
   orbitViewMC.scpMarker.setOrientationType("absolute");
}
function getDayString(doy)
{
   var _loc1_ = 0;
   while(doy >= monthPoints[_loc1_] && _loc1_ < 13)
   {
      _loc1_ = _loc1_ + 1;
   }
   _loc1_ = _loc1_ - 1;
   return String(doy - monthPoints[_loc1_] + 1) + " " + monthLabels[_loc1_];
}
skipUpdate = false;
animateRate = 0.005;
daysSinceVE = 286;
sideViewX = 264;
sunViewX = 293.5;
latitudeSelector._visible = false;
raysMC._visible = false;
earthViewMC._x = sunViewX;
raysMC._x = sideViewX;
latitudeSelector._x = sideViewX;
earthViewSubSolarPointMC._x = sunViewX;
raysMC._y = latitudeSelector._y = earthViewSubSolarPointMC._y = earthViewMC._y;
earthViewSubSolarPointMC._xscale = 200;
earthViewSubSolarPointMC._yscale = 200;
earthViewSideSubSolarPointMC._visible = false;
earthViewSideSubSolarPointMC._xscale = 200;
earthViewSideSubSolarPointMC._yscale = 200;
sunbeamSpreadDirectionLabelsMC._visible = false;
showOrbitViewLabelsCheck.setStyleProperty("textColor",16777215);
showEarthViewLabelsCheck.setStyleProperty("textColor",16777215);
sunbeamViewMC._visible = false;
orbitViewMC.onMouseUpdate = function()
{
   if(centeredObjectGroup.getValue() != "sun")
   {
      orbitViewMC.celestialEquatorLabel.setPosition({alt:0,az:orbitViewMC.viewerAzimuth + 30});
      orbitViewMC.eclipticLabel.setPosition({dec:0,ra:- orbitViewMC.viewerAzimuth / 15 + 2});
   }
   else
   {
      orbitViewMC.orbitPathLabel.setPosition({alt:0,az:orbitViewMC.viewerAzimuth - 30,r:1.15});
      orbitViewMC.orbitPathLabel.setOrientationType("absolute",{alt:0,az:orbitViewMC.viewerAzimuth},{alt:90,az:0});
   }
   orbitViewMC.updateObjects();
   orbitViewMC.globeSphere.instance.setThetaAndPhi(orbitViewMC.theta,orbitViewMC.phi);
   orbitViewMC.globeSphere.instance.globe.instance.update();
   orbitViewMC.globeSphere.instance.globe.instance.updateShading();
   updateOrbitalPlane();
   updateAfterEvent();
};
observerLatitude = 0;
sizeEarthCentered = 510;
sizeSunCentered = 450;
toLabelsDistEarthCentered = 0.75;
toLabelsDistSunCentered = 1.16;
monthPoints = [0,31,59,90,120,151,181,212,243,273,304,334,365];
monthLabels = ["January","February","March","April","May","June","July","August","September","October","November","December"];
orbitViewBackgroundMC.setDraggable = function(arg)
{
   if(arg)
   {
      this.onPress = this.onPressFunc;
      this.onRelease = this.onReleaseFunc;
      this.onReleaseOutside = this.onReleaseFunc;
   }
   else
   {
      delete this.onPress;
      delete this.onRelease;
      delete this.onReleaseOutside;
      delete this.onMouseMove;
   }
};
orbitViewBackgroundMC.useHandCursor = false;
orbitViewBackgroundMC.onPressFunc = function()
{
   this._dragXMouse = this._xmouse;
   this._dragYMouse = this._ymouse;
   this._dragTheta = this._parent.orbitViewMC._theta;
   this._dragPhi = this._parent.orbitViewMC._phi;
   this.onMouseMove = this.onMouseMoveFunc;
};
orbitViewBackgroundMC.onMouseMoveFunc = function()
{
   this._parent.orbitViewMC.setThetaAndPhi(57.29577951308232 * (this._dragTheta - (this._xmouse - this._dragXMouse) / this._parent.orbitViewMC._c.r),57.29577951308232 * (this._dragPhi + (this._ymouse - this._dragYMouse) / this._parent.orbitViewMC._c.r));
   this._parent.orbitViewMC.onMouseUpdate.call(this._parent.onMouseUpdateInstance);
   this._parent.updateOrbitalPlane();
   updateAfterEvent();
};
orbitViewBackgroundMC.onReleaseFunc = function()
{
   delete this.onMouseMove;
};
init();
onReset();
