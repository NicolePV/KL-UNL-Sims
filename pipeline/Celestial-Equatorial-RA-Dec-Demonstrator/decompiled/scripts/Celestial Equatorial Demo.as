function CelestialEquatorialDemoClass()
{
}
var p = CelestialEquatorialDemoClass.prototype = new MovieClip();
Object.registerClass("Celestial Equatorial Demo",CelestialEquatorialDemoClass);
p.raColor = 4934654;
p.decColor = 16665419;
p.reset = function()
{
   var _loc1_ = this;
   _loc1_.setStarLocation({ra:4,dec:60});
   _loc1_.sphereMC.setThetaAndPhi(217,32);
   _loc1_.onSphereOrientationChanged();
   _loc1_.hideAllLabels();
};
p.onSphereOrientationChanged = function()
{
   var _loc1_ = this;
   _loc1_.sphereMC.innerSphere.instance.setThetaAndPhi(_loc1_.sphereMC.theta,_loc1_.sphereMC.phi);
   _loc1_.sphereMC.equatorLabel.setPosition({alt:0,az:394 - _loc1_.sphereMC.theta,r:0.2});
   var _loc2_ = -34 - _loc1_.sphereMC.theta;
   var _loc3_ = Math.atan(Math.sin(_loc2_ * 3.141592653589793 / 180) * 0.4348123749609336) * 57.29577951308232;
   _loc1_.sphereMC.eclipticLabel.setPosition({alt:_loc3_,az:_loc2_,r:1.01});
   _loc1_.sphereMC.ceLabel.setPosition({alt:0,az:394 - _loc1_.sphereMC.theta,r:1.01});
   _loc1_.sphereMC.eastArrow.setPosition({alt:0,az:- _loc1_.sphereMC.theta,r:1.15});
   _loc1_.sphereMC.eastArrow.setOrientationType("absolute");
   _loc1_.sphereMC.updateObjects();
};
p.updateLabels = function()
{
   var _loc1_ = this;
   _loc1_.sphereMC.eastArrow.visible = _loc1_.eastArrowCheckbox.getValue();
   _loc1_.sphereMC.ecliptic.visible = _loc1_.eclipticCheckbox.getValue();
   _loc1_.sphereMC.eclipticLabel.visible = _loc1_.eclipticCheckbox.getValue();
   _loc1_.sphereMC.northPoleLabel.visible = _loc1_.earthPolesCheckbox.getValue();
   _loc1_.sphereMC.southPoleLabel.visible = _loc1_.earthPolesCheckbox.getValue();
   _loc1_.sphereMC.equatorLabel.visible = _loc1_.equatorCheckbox.getValue();
   _loc1_.sphereMC.ncpLabel.visible = _loc1_.celestialPolesCheckbox.getValue();
   _loc1_.sphereMC.scpLabel.visible = _loc1_.celestialPolesCheckbox.getValue();
   _loc1_.sphereMC.ceLabel.visible = _loc1_.celestialEquatorCheckbox.getValue();
   _loc1_.sphereMC.zeroHoursLabel.visible = _loc1_.zeroHoursCheckbox.getValue();
   _loc1_.sphereMC.updateObjects();
};
p.setAllLabelsVisibility = function(arg)
{
   var _loc1_ = this;
   var _loc2_ = arg;
   _loc1_.eastArrowCheckbox.setValue(_loc2_);
   _loc1_.eclipticCheckbox.setValue(_loc2_);
   _loc1_.earthPolesCheckbox.setValue(_loc2_);
   _loc1_.equatorCheckbox.setValue(_loc2_);
   _loc1_.celestialPolesCheckbox.setValue(_loc2_);
   _loc1_.celestialEquatorCheckbox.setValue(_loc2_);
   _loc1_.zeroHoursCheckbox.setValue(_loc2_);
   _loc1_.updateLabels();
};
p.showAllLabels = function()
{
   this.setAllLabelsVisibility(true);
};
p.hideAllLabels = function()
{
   this.setAllLabelsVisibility(false);
};
p.init = function()
{
   var _loc1_ = this;
   _loc1_.sphereMC.size = 320;
   _loc1_.sphereMC.latitude = 90;
   _loc1_.sphereMC.showHorizonPlane = false;
   _loc1_.sphereMC.addShadingClip("CSGradientDisk","sphereBack","back","inner","both",{innerAlpha:50,outerAlpha:60,innerColor:16777215,outerColor:16777215});
   _loc1_.sphereMC.addShadingClip("CSGradientDisk","sphereFront","front","inner","both",{innerAlpha:5,outerAlpha:20,innerColor:16777215,outerColor:16777215});
   _loc1_.sphereMC.addShadingClip("Sphere Edge Shading","sphereEdge","front","inner","both");
   _loc1_.sphereMC.addObject("CelestialSphere","innerSphere",{x:0,y:0,z:0,system:"celestial"},{_traceOn:false});
   _loc1_.sphereMC.addObject("DCS Label","raLabel",{ra:0,dec:0},{labelColor:_loc1_.raColor});
   _loc1_.sphereMC.addObject("DCS Label","decLabel",{ra:0,dec:0},{labelColor:_loc1_.decColor});
   _loc1_.sphereMC.innerSphere.instance.size = 60;
   _loc1_.sphereMC.innerSphere.instance.latitude = 90;
   _loc1_.sphereMC.innerSphere.instance.showHorizonPlane = false;
   _loc1_.sphereMC.innerSphere.instance.celestialBowl.removeMovieClip();
   _loc1_.sphereMC.innerSphere.instance.setMouseBehavior("none");
   _loc1_.sphereMC.innerSphere.instance.addObject("Globe Component v2","globe",{x:0,y:0,z:0,system:"celestial"},{initSize:75});
   _loc1_.sphereMC.innerSphere.instance.addCircle("equator",{thickness:1,color:2188081,alpha:100},{ra:0,dec:0,tilt:0});
   _loc1_.sphereMC.addObject("Marker","ncpMarker",{ra:0,dec:90},{labelText:""});
   _loc1_.sphereMC.ncpMarker.setOrientationType("absolute");
   _loc1_.sphereMC.addObject("Marker","scpMarker",{ra:0,dec:-90},{labelText:""});
   _loc1_.sphereMC.scpMarker.setOrientationType("absolute");
   _loc1_.sphereMC.addObject("Rotation Arrow","rotationArrow",{ra:0,dec:90,r:0.4});
   _loc1_.sphereMC.rotationArrow.setOrientationType("absolute");
   _loc1_.sphereMC.addObject("North Pole Label","northPoleLabel",{x:0,y:0,z:0.2,system:"horizon"});
   _loc1_.sphereMC.addObject("South Pole Label","southPoleLabel",{x:0,y:0,z:-0.2,system:"horizon"});
   _loc1_.sphereMC.addObject("Equator Label","equatorLabel",{x:0,y:0,z:0,system:"horizon"});
   _loc1_.sphereMC.addObject("NCP Label","ncpLabel",{x:0,y:0,z:1,system:"horizon"});
   _loc1_.sphereMC.addObject("SCP Label","scpLabel",{x:0,y:0,z:-1,system:"horizon"});
   _loc1_.sphereMC.addObject("Ecliptic Label","eclipticLabel",{x:0,y:0,z:0,system:"horizon"});
   _loc1_.sphereMC.addObject("CE Label","ceLabel",{x:0,y:0,z:0,system:"horizon"});
   _loc1_.sphereMC.addObject("East Arrow","eastArrow",{x:0,y:0,z:0,r:1.2});
   _loc1_.sphereMC.addObject("Zero Hours Label","zeroHoursLabel",{dec:35,ra:0,r:1});
   _loc1_.sphereMC.addObject("Draggable Star","star",{ra:0,dec:0});
   _loc1_.sphereMC.addLine("ncpLineExtension",{thickness:2,color:5263440,alpha:100},{ra:0,dec:90,r:1},{ra:0,dec:90,r:1.3});
   _loc1_.sphereMC.addLine("scpLineExtension",{thickness:2,color:5263440,alpha:100},{ra:0,dec:-90,r:1},{ra:0,dec:-90,r:1.3});
   _loc1_.sphereMC.addCircle("celestialEquator",{thickness:2,color:2188081,alpha:100},{ra:0,dec:0,tilt:0});
   _loc1_.sphereMC.addCircle("meridian1",{thickness:1,color:0,alpha:10},{ra:0,dec:0,tilt:90,gammaStart:90,gammaEnd:-90});
   _loc1_.sphereMC.addCircle("meridian2",{thickness:1,color:0,alpha:10},{ra:6,dec:0,tilt:90});
   _loc1_.sphereMC.addCircle("zeroHoursCircle",{thickness:2,color:2188081,alpha:100},{ra:0,dec:0,tilt:90,gammaStart:-90,gammaEnd:90});
   _loc1_.sphereMC.addCircle("ecliptic",{thickness:2,color:10039775,alpha:100},{ra:0,dec:0,tilt:23.5});
   _loc1_.sphereMC.addCircle("raCircle",{thickness:1,color:10526880,alpha:100},{ra:0,dec:0,tilt:90});
   _loc1_.sphereMC.addCircle("decCircle",{thickness:1,color:10526880,alpha:100},{ra:0,dec:0,tilt:90});
   _loc1_.sphereMC.addCircle("raArc",{thickness:3,color:_loc1_.raColor,alpha:100},{ra:0,dec:0,tilt:0});
   _loc1_.sphereMC.addCircle("decArc",{thickness:3,color:_loc1_.decColor,alpha:100},{ra:0,dec:0,tilt:90});
   _loc1_.sphereMC.onMouseUpdate = function()
   {
      this.onSphereOrientationChanged();
      updateAfterEvent();
   };
   _loc1_.reset();
};
p.onPositionSliderChanged = function()
{
   var _loc1_ = this;
   _loc1_.setStarLocation({ra:_loc1_.raSlider.value,dec:_loc1_.decSlider.value},true);
};
p.setStarLocation = function(pt, skipSliderSync)
{
   var _loc1_ = this;
   var _loc2_ = pt;
   _loc1_.sphereMC.raLabel.instance.labelText = _loc2_.ra.toFixed(1) + "h";
   _loc1_.sphereMC.raLabel.setPosition({ra:_loc2_.ra - 0.9,dec:5,r:1.001});
   _loc1_.sphereMC.raLabel.setOrientationType("absolute");
   _loc1_.sphereMC.decLabel.instance.labelText = _loc2_.dec.toFixed(1) + "°";
   _loc1_.sphereMC.decLabel.setPosition({ra:_loc2_.ra + 0.9,dec:_loc2_.dec / 2,r:1.001});
   _loc1_.sphereMC.decLabel.setOrientationType("absolute");
   _loc1_.sphereMC.star.setPosition(_loc2_);
   _loc1_.sphereMC.star.setOrientationType("absolute");
   if(_loc2_.ra != 0)
   {
      _loc1_.sphereMC.raArc.setParameters({ra:0,dec:0,tilt:0,gammaStart:0,gammaEnd:15 * _loc2_.ra});
      _loc1_.sphereMC.raArc._visible = true;
   }
   else
   {
      _loc1_.sphereMC.raArc._visible = false;
   }
   _loc1_.sphereMC.raCircle.setParameters({ra:_loc2_.ra,dec:0,tilt:90,gammaStart:-90,gammaEnd:90});
   if(_loc2_.dec < 0)
   {
      _loc1_.sphereMC.decArc.setParameters({ra:_loc2_.ra,dec:0,tilt:90,gammaStart:_loc2_.dec,gammaEnd:0});
      _loc1_.sphereMC.decArc._visible = true;
   }
   else if(_loc2_.dec > 0)
   {
      _loc1_.sphereMC.decArc.setParameters({ra:_loc2_.ra,dec:0,tilt:90,gammaStart:0,gammaEnd:_loc2_.dec});
      _loc1_.sphereMC.decArc._visible = true;
   }
   else
   {
      _loc1_.sphereMC.decArc._visible = false;
   }
   _loc1_.sphereMC.decCircle.setParameters({ra:0,dec:_loc2_.dec,tilt:0});
   _loc1_.sphereMC.updateObjects();
   _loc1_.sphereMC.updateCircles();
   if(!skipSliderSync)
   {
      _loc1_.raSlider.value = _loc2_.ra;
      _loc1_.decSlider.value = _loc2_.dec;
   }
};
