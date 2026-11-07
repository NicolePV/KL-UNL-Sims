function update()
{
   var _loc1_ = time % 1 * 360;
   var _loc2_ = (observerLongitude + _loc1_) / 15;
   sphere1.globeSphere.instance.customSetSiderealTime(- _loc2_);
   sphere1.globeSphere.instance.globe.instance.setRotationAngle(_loc1_);
   sphere1.globeSphere.instance.globe.instance.update();
   sphere2.setSiderealTimeDelayedUpdate(_loc2_);
   if(selectedStar != null)
   {
      updateHorizonArcs();
   }
   updateConstellationArcs();
   sphere2.doSiderealTimeUpdate();
}
function updateConstellationArcs()
{
   var _loc2_;
   var _loc1_;
   for(var _loc3_ in constellations)
   {
      _loc2_ = constellations[_loc3_];
      if(!(_loc2_ == undefined || !_loc2_.inUse))
      {
         _loc1_ = 0;
         while(_loc1_ < _loc2_.arcNames.length)
         {
            sphere2[_loc2_.arcNames[_loc1_]].update();
            _loc1_ = _loc1_ + 1;
         }
      }
   }
}
function updateCelestialArcs()
{
   var _loc1_ = {};
   sphere1[selectedStar].getPositionCelestial(_loc1_);
   if(_loc1_.dec < -0.0001)
   {
      sphere1.decArc.setParameters({ra:_loc1_.ra,dec:0,tilt:90,gammaStart:_loc1_.dec,gammaEnd:0});
   }
   else if(_loc1_.dec > 0.0001)
   {
      sphere1.decArc.setParameters({ra:_loc1_.ra,dec:0,tilt:90,gammaStart:0,gammaEnd:_loc1_.dec});
   }
   else
   {
      sphere1.decArc.setParameters({ra:_loc1_.ra,dec:0,tilt:90,gammaStart:0,gammaEnd:0.001});
   }
   if(_loc1_.ra < 0.000001)
   {
      sphere1.raArc.setParameters({ra:0,dec:0,tilt:0,gammaStart:0,gammaEnd:0.001});
   }
   else
   {
      sphere1.raArc.setParameters({ra:0,dec:0,tilt:0,gammaStart:0,gammaEnd:15 * _loc1_.ra});
   }
   sphere1.decArc.update();
   sphere1.raArc.update();
   var _loc2_ = _loc1_.ra.toFixed(1);
   var _loc3_ = _loc1_.dec.toFixed(1);
   starLocationMC.rightAscensionField.text = _loc2_;
   starLocationMC.declinationField.text = _loc3_;
   raString = _loc2_ + "h";
   decString = _loc3_ + "°";
   sphere1.decLabel.instance.labelText = decString;
   sphere1.decLabel.setPosition({ra:_loc1_.ra + 0.9,dec:_loc1_.dec / 2,r:1.001});
   sphere1.decLabel.setOrientationType("absolute");
   sphere1.raLabel.instance.labelText = raString;
   sphere1.raLabel.setPosition({ra:_loc1_.ra - 0.9,dec:5,r:1.001});
   sphere1.raLabel.setOrientationType("absolute");
}
function updateHorizonArcs()
{
   var _loc1_ = {};
   sphere2[selectedStar].getPositionHorizon(_loc1_);
   if(_loc1_.alt < -0.0001)
   {
      sphere2.altArc.setParameters({az:_loc1_.az,alt:0,tilt:90,gammaStart:_loc1_.alt,gammaEnd:0});
   }
   else if(_loc1_.alt > 0.0001)
   {
      sphere2.altArc.setParameters({az:_loc1_.az,alt:0,tilt:90,gammaStart:0,gammaEnd:_loc1_.alt});
   }
   else
   {
      sphere2.altArc.setParameters({az:_loc1_.az,alt:0,tilt:90,gammaStart:0,gammaEnd:0.001});
   }
   if(_loc1_.az < 0.0001)
   {
      sphere2.azArc.setParameters({az:0,alt:0,tilt:0,gammaStart:0,gammaEnd:0.001});
   }
   else
   {
      sphere2.azArc.setParameters({az:0,alt:0,tilt:0,gammaStart:360 - _loc1_.az,gammaEnd:0});
   }
   sphere2.altArc.update();
   sphere2.azArc.update();
   var _loc3_ = _loc1_.az.toFixed(1);
   var _loc2_ = _loc1_.alt.toFixed(1);
   starLocationMC.azimuthField.text = _loc3_;
   starLocationMC.altitudeField.text = _loc2_;
   azString = _loc3_ + "°";
   altString = _loc2_ + "°";
   sphere2.altLabel.instance.labelText = altString;
   sphere2.altLabel.setPosition({az:_loc1_.az + 13,alt:_loc1_.alt / 2,r:1.001});
   sphere2.altLabel.setOrientationType("absolute");
   sphere2.azLabel.instance.labelText = azString;
   sphere2.azLabel.setPosition({az:_loc1_.az - 13,alt:5,r:1.001});
   sphere2.azLabel.setOrientationType("absolute");
}
function updateAngle()
{
   if(!showAngleCheck.getValue())
   {
      return undefined;
   }
   var _loc7_ = 0.4363323129985824;
   var _loc1_ = 20;
   var _loc3_ = 90 - _loc1_;
   var _loc8_;
   var _loc2_;
   var _loc4_;
   if(observerLatitude >= 90)
   {
      _loc8_ = "0°";
      sphere2.angle1Circle.setParameters({az:0,tilt:0,alt:0,gammaStart:270 - _loc1_,gammaEnd:270});
      sphere2.angle2Circle.setParameters({az:0,tilt:0,alt:0,gammaStart:90,gammaEnd:90 + _loc1_});
      _loc2_ = 0;
      _loc4_ = 1;
   }
   else if(observerLatitude >= 0)
   {
      _loc8_ = (90 - observerLatitude).toFixed(1) + "°";
      sphere2.angle1Circle.setParameters({az:0,tilt:90,alt:_loc3_,gammaStart:90 + observerLatitude,gammaEnd:180});
      sphere2.angle2Circle.setParameters({az:0,tilt:90,alt:- _loc3_,gammaStart:90 + observerLatitude,gammaEnd:180});
      _loc2_ = (90 - observerLatitude) / 2 * 3.141592653589793 / 180;
      _loc4_ = 1;
   }
   else if(observerLatitude > -90)
   {
      _loc8_ = (90 + observerLatitude).toFixed(1) + "°";
      sphere2.angle1Circle.setParameters({az:0,tilt:90,alt:_loc3_,gammaStart:0,gammaEnd:90 + observerLatitude});
      sphere2.angle2Circle.setParameters({az:0,tilt:90,alt:- _loc3_,gammaStart:0,gammaEnd:90 + observerLatitude});
      _loc2_ = (90 + observerLatitude) / 2 * 3.141592653589793 / 180;
      _loc4_ = -1;
   }
   else
   {
      _loc8_ = "0°";
      sphere2.angle1Circle.setParameters({az:0,tilt:0,alt:0,gammaStart:270,gammaEnd:270 + _loc1_});
      sphere2.angle2Circle.setParameters({az:0,tilt:0,alt:0,gammaStart:90 - _loc1_,gammaEnd:90});
      _loc2_ = 0;
      _loc4_ = -1;
   }
   sphere2.angle1Circle.update();
   sphere2.angle2Circle.update();
   var _loc11_ = 57.29577951308232 * Math.asin(Math.sin(_loc2_) * Math.sin(_loc7_));
   var _loc5_ = 57.29577951308232 * Math.atan(Math.cos(_loc2_) * Math.tan(_loc7_));
   var _loc10_ = {alt:_loc11_,az:90 + _loc4_ * _loc5_};
   var _loc9_ = {alt:_loc11_,az:270 - _loc4_ * _loc5_};
   var _loc6_;
   if(_loc4_ == -1)
   {
      _loc6_ = {az:0,alt:_loc2_ * 180 / 3.141592653589793};
   }
   else
   {
      _loc6_ = {az:180,alt:_loc2_ * 180 / 3.141592653589793};
   }
   sphere2.angle1Label.setPosition(_loc10_);
   sphere2.angle2Label.setPosition(_loc9_);
   sphere2.angle1Label.setOrientationType("absolute",_loc10_,_loc6_);
   sphere2.angle2Label.setOrientationType("absolute",_loc9_,_loc6_);
   sphere2.angle1Label.instance.setLabelText(_loc8_);
   sphere2.angle2Label.instance.setLabelText(_loc8_);
}
