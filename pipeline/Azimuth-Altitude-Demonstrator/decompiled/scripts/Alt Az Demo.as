function AltAzDemoClass()
{
}
var p = AltAzDemoClass.prototype = new MovieClip();
Object.registerClass("Alt Az Demo",AltAzDemoClass);
p.azColor = 5654005;
p.altColor = 10893123;
p.reset = function()
{
   var _loc1_ = this;
   _loc1_.setStarLocation({az:140,alt:45});
   _loc1_.sphereMC.setThetaAndPhi(190,28);
   _loc1_.onSphereOrientationChanged();
   _loc1_.hideAllLabels();
};
p.onSphereOrientationChanged = function()
{
   var _loc1_ = this;
   _loc1_.sphereMC.horizonLabel.setPosition({alt:0,az:394 - _loc1_.sphereMC.theta,r:1});
   _loc1_.sphereMC.updateObjects();
};
p.updateLabels = function()
{
   var _loc1_ = this;
   _loc1_.sphereMC.zenithLabel.visible = _loc1_.zenithCheckbox.getValue();
   _loc1_.sphereMC.horizonLabel.visible = _loc1_.horizonCheckbox.getValue();
   _loc1_.sphereMC.nadirLabel.visible = _loc1_.nadirCheckbox.getValue();
   _loc1_.sphereMC.meridianLabel.visible = _loc1_.meridianCheckbox.getValue();
   _loc1_.sphereMC.updateObjects();
};
p.setAllLabelsVisibility = function(arg)
{
   var _loc1_ = this;
   var _loc2_ = arg;
   _loc1_.zenithCheckbox.setValue(_loc2_);
   _loc1_.horizonCheckbox.setValue(_loc2_);
   _loc1_.nadirCheckbox.setValue(_loc2_);
   _loc1_.meridianCheckbox.setValue(_loc2_);
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
   _loc1_.sphereMC.minViewerAltitude = 7;
   _loc1_.sphereMC.addShadingClip("CSGradientDisk","sphereBack","back","inner","both",{innerAlpha:50,outerAlpha:60,innerColor:16777215,outerColor:16777215});
   _loc1_.sphereMC.addShadingClip("CSGradientDisk","sphereFront","front","inner","both",{innerAlpha:5,outerAlpha:20,innerColor:16777215,outerColor:16777215});
   _loc1_.sphereMC.addObject("DCS Label","azLabel",{az:0,alt:0},{labelColor:_loc1_.azColor});
   _loc1_.sphereMC.addObject("DCS Label","altLabel",{az:0,alt:0},{labelColor:_loc1_.altColor});
   _loc1_.sphereMC.addObject("Stickfigure","stickfigure",{x:0,y:0,z:0,system:"horizon"},{_xscale:120,_yscale:120});
   _loc1_.sphereMC.stickfigure.setOrientationType("absolute",{x:-1,y:0,z:0,system:"horizon"},{x:0,y:0,z:1,system:"horizon"});
   _loc1_.sphereMC.minViewerAltitude = 1;
   _loc1_.sphereMC.addHorizonPlaneClip("Direction Labels Light","aboveLabels","above");
   _loc1_.sphereMC.addObject("Marker","zenithMarker",{az:0,alt:90},{labelText:""});
   _loc1_.sphereMC.zenithMarker.setOrientationType("absolute");
   _loc1_.sphereMC.addObject("Marker","nadirMarker",{az:0,alt:-90},{labelText:""});
   _loc1_.sphereMC.nadirMarker.setOrientationType("absolute");
   _loc1_.sphereMC.addLine("npLine",{thickness:2,color:5263440,alpha:100},{az:0,alt:90,r:1},{az:0,alt:90,r:1.2});
   _loc1_.sphereMC.addLine("spLine",{thickness:2,color:5263440,alpha:100},{az:0,alt:-90,r:1},{az:0,alt:-90,r:1.2});
   _loc1_.sphereMC.addObject("Zenith Label","zenithLabel",{x:0,y:0,z:1,system:"horizon"});
   _loc1_.sphereMC.addObject("Nadir Label","nadirLabel",{x:0,y:0,z:-1,system:"horizon"});
   _loc1_.sphereMC.addObject("Horizon Plane Label","horizonLabel",{x:0,y:0,z:0,system:"horizon"});
   _loc1_.sphereMC.addObject("Meridian Label","meridianLabel",{alt:35,az:180,r:1});
   _loc1_.sphereMC.addCircle("meridian2",{thickness:1,color:0,alpha:10},{az:90,alt:0,tilt:90});
   _loc1_.sphereMC.addCircle("azCircle",{thickness:1,color:10526880,alpha:100},{az:0,alt:0,tilt:90});
   _loc1_.sphereMC.addCircle("altCircle",{thickness:1,color:10526880,alpha:100},{az:0,alt:0,tilt:90});
   _loc1_.sphereMC.addCircle("meridian",{thickness:2,color:2188081,alpha:100},{az:0,alt:0,tilt:90});
   _loc1_.sphereMC.addCircle("azArc",{thickness:3,color:_loc1_.azColor,alpha:100},{az:0,alt:0,tilt:0});
   _loc1_.sphereMC.addCircle("altArc",{thickness:3,color:_loc1_.altColor,alpha:100},{az:0,alt:0,tilt:90});
   _loc1_.sphereMC.addObject("AzAlt Draggable Star","star",{az:0,alt:0});
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
   _loc1_.setStarLocation({az:_loc1_.azSlider.value,alt:_loc1_.altSlider.value},true);
};
p.setStarLocation = function(pt, skipSliderSync)
{
   var _loc1_ = this;
   var _loc2_ = pt;
   if(_loc2_.az != 360)
   {
      _loc2_.az = (_loc2_.az % 360 + 360) % 360;
   }
   _loc1_.sphereMC.azLabel.instance.labelText = _loc2_.az.toFixed(1) + "°";
   _loc1_.sphereMC.azLabel.setPosition({az:_loc2_.az - 13,alt:5,r:1.001});
   _loc1_.sphereMC.azLabel.setOrientationType("absolute");
   _loc1_.sphereMC.altLabel.instance.labelText = _loc2_.alt.toFixed(1) + "°";
   _loc1_.sphereMC.altLabel.setPosition({az:_loc2_.az + 13,alt:_loc2_.alt / 2,r:1.001});
   _loc1_.sphereMC.altLabel.setOrientationType("absolute");
   _loc1_.sphereMC.star.setPosition(_loc2_);
   _loc1_.sphereMC.star.setOrientationType("absolute");
   if(_loc2_.az != 0)
   {
      _loc1_.sphereMC.azArc.setParameters({az:0,alt:0,tilt:0,gammaStart:360 - _loc2_.az,gammaEnd:0});
      _loc1_.sphereMC.azArc._visible = true;
   }
   else
   {
      _loc1_.sphereMC.azArc._visible = false;
   }
   _loc1_.sphereMC.azCircle.setParameters({az:_loc2_.az,alt:0,tilt:90,gammaStart:-90,gammaEnd:90});
   if(_loc2_.alt < 0)
   {
      _loc1_.sphereMC.altArc.setParameters({az:_loc2_.az,alt:0,tilt:90,gammaStart:_loc2_.alt,gammaEnd:0});
      _loc1_.sphereMC.altArc._visible = true;
   }
   else if(_loc2_.alt > 0)
   {
      _loc1_.sphereMC.altArc.setParameters({az:_loc2_.az,alt:0,tilt:90,gammaStart:0,gammaEnd:_loc2_.alt});
      _loc1_.sphereMC.altArc._visible = true;
   }
   else
   {
      _loc1_.sphereMC.altArc._visible = false;
   }
   _loc1_.sphereMC.altCircle.setParameters({az:0,alt:_loc2_.alt,tilt:0});
   _loc1_.sphereMC.updateObjects();
   _loc1_.sphereMC.updateCircles();
   if(!skipSliderSync)
   {
      _loc1_.azSlider.value = _loc2_.az;
      _loc1_.altSlider.value = _loc2_.alt;
   }
};
