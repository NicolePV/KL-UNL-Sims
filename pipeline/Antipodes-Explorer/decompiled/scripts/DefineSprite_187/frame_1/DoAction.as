function init()
{
   mapMC.addObject("AntipodeDot","redDot",{lon:0,lat:0},{name:"redDot",fillColor:15753312});
   mapMC.addObject("AntipodeDot","blueDot",{lon:0,lat:0},{name:"blueDot",fillColor:8421631});
   var _loc1_ = 175;
   sphereMC.latitude = 90;
   sphereMC.showHorizonPlane = false;
   sphereMC.addObject("Globe Component v2","globeBack",{ra:0,dec:0,r:0},{isStandalone:true,initSize:_loc1_,initShowAxis:false,initIsDraggable:false,initRotation:180,initWaterLinkageName:"BackWater",initLandLinkageName:"BackLand"});
   sphereMC.addObject("Globe Component v2","globeFront",{ra:0,dec:0,r:0},{isStandalone:true,initSize:_loc1_,initShowAxis:false,initIsDraggable:false,initRotation:180,initWaterLinkageName:"FrontWater2",initLandLinkageName:"FrontLand2"});
   sphereMC.addObject("EmptyMovieClip","connectingLine",{ra:0,dec:0,r:0});
   sphereMC.addLine("ncpLine",{thickness:2,color:3182640,alpha:50},{x:0,y:0,z:1,system:"horizon"},{x:0,y:0,z:1.15,system:"horizon"});
   sphereMC.addLine("scpLine",{thickness:2,color:3182640,alpha:50},{x:0,y:0,z:-1,system:"horizon"},{x:0,y:0,z:-1.15,system:"horizon"});
   sphereMC.addCircle("equator",{thickness:1,color:3182640,alpha:50},{az:0,alt:0,tilt:0});
   sphereMC.globeBack.instance._xscale = -100;
   sphereMC.addObject("AntipodeDotForSphere","redDot",{ra:0,dec:0},{dotName:"redDot",fillColor:15753312});
   sphereMC.addObject("AntipodeDotForSphere","blueDot",{ra:0,dec:0},{dotName:"blueDot",fillColor:8421631});
   sphereMC.size = _loc1_;
   sphereMC.onMouseUpdate = function()
   {
      updateGlobes();
      updateAfterEvent();
   };
}
function reset()
{
   mapMC.longitudeOffset = 100;
   snapCheckbox.setValue(false);
   restrictCheckbox.setValue(false);
   restrictGroup.setValue("longitude");
   var _loc1_ = {lon:-5,lat:42};
   sphereMC.setThetaAndPhi(_loc1_.lon + 15 + 180,_loc1_.lat <= 0 ? _loc1_.lat + 5 : _loc1_.lat - 5);
   updateGlobeOrientations();
   setObjectPosition("redDot",_loc1_);
}
function updateGlobes()
{
   updateGlobeOrientations();
   updateGlobeOrdering();
   updateConnectingLine();
}
function updateGlobeOrientations()
{
   sphereMC.globeFront.instance.setViewerDirection({theta:sphereMC.theta,phi:sphereMC.phi});
   sphereMC.globeBack.instance.setViewerDirection({theta:180 + sphereMC.theta,phi:- sphereMC.phi});
}
function updateGlobeOrdering()
{
   sphereMC.globeFront.shell.swapDepths(Math.max(Math.max(sphereMC.globeBack.shell.getDepth(),sphereMC.globeFront.shell.getDepth()),sphereMC.connectingLine.shell.getDepth()));
   sphereMC.connectingLine.shell.swapDepths(Math.max(sphereMC.globeBack.shell.getDepth(),sphereMC.connectingLine.shell.getDepth()));
}
function updateConnectingLine()
{
   with(sphereMC.connectingLine.instance)
   {
      clear();
      lineStyle(2,4210752,20);
      moveTo(sphereMC.redDot.shell._x,sphereMC.redDot.shell._y);
      lineTo(sphereMC.blueDot.shell._x,sphereMC.blueDot.shell._y);
   }
}
function onRestrictChanged()
{
   restrictGroup.setEnabled(restrictCheckbox.getValue());
   var _loc1_ = !restrictCheckbox.getValue() ? {restrictTo:"none"} : {restrictTo:restrictGroup.getValue()};
   mapMC.passDataToObject("redDot",_loc1_);
   mapMC.passDataToObject("blueDot",_loc1_);
   sphereMC.redDot.instance.restrictTo = _loc1_.restrictTo;
   sphereMC.blueDot.instance.restrictTo = _loc1_.restrictTo;
}
function onSnapChanged()
{
   var _loc1_ = {snap:snapCheckbox.getValue()};
   mapMC.passDataToObject("redDot",_loc1_);
   mapMC.passDataToObject("blueDot",_loc1_);
   sphereMC.redDot.instance.snap = _loc1_.snap;
   sphereMC.blueDot.instance.snap = _loc1_.snap;
   var _loc2_;
   if(_loc1_.snap)
   {
      _loc2_ = {lat:5 * Math.round(sphereMC.redDot.instance.lat / 5),lon:5 * Math.round(sphereMC.redDot.instance.lon / 5)};
      setObjectPosition("redDot",_loc2_);
   }
}
function setObjectPosition(name, pos)
{
   var _loc2_ = pos;
   var _loc3_ = name != "redDot" ? "redDot" : "blueDot";
   var _loc1_ = {lon:180 + _loc2_.lon,lat:- _loc2_.lat};
   _loc2_.lon = ((_loc2_.lon + 180) % 360 + 360) % 360 - 180;
   _loc1_.lon = ((_loc1_.lon + 180) % 360 + 360) % 360 - 180;
   mapMC.setObjectPosition(name,_loc2_);
   mapMC.setObjectPosition(_loc3_,_loc1_);
   mapMC.passDataToObject(name,_loc2_);
   mapMC.passDataToObject(_loc3_,_loc1_);
   sphereMC[name].setPosition({ra:_loc2_.lon / 15,dec:_loc2_.lat});
   sphereMC[name].setOrientationType("absolute");
   sphereMC[_loc3_].setPosition({ra:_loc1_.lon / 15,dec:_loc1_.lat});
   sphereMC[_loc3_].setOrientationType("absolute");
   sphereMC[name].instance.lat = _loc2_.lat;
   sphereMC[name].instance.lon = _loc2_.lon;
   sphereMC[_loc3_].instance.lat = _loc1_.lat;
   sphereMC[_loc3_].instance.lon = _loc1_.lon;
   sphereMC.update();
   updateGlobeOrdering();
   updateConnectingLine();
   if(_loc2_.lat < 0)
   {
      this[name + "LatField"].text = Math.round(- _loc2_.lat) + "° S";
   }
   else
   {
      this[name + "LatField"].text = Math.round(_loc2_.lat) + "° N";
   }
   if(_loc2_.lon < 0)
   {
      this[name + "LonField"].text = Math.round(- _loc2_.lon) + "° W";
   }
   else
   {
      this[name + "LonField"].text = Math.round(_loc2_.lon) + "° E";
   }
   if(_loc1_.lat < 0)
   {
      this[_loc3_ + "LatField"].text = Math.round(- _loc1_.lat) + "° S";
   }
   else
   {
      this[_loc3_ + "LatField"].text = Math.round(_loc1_.lat) + "° N";
   }
   if(_loc1_.lon < 0)
   {
      this[_loc3_ + "LonField"].text = Math.round(- _loc1_.lon) + "° W";
   }
   else
   {
      this[_loc3_ + "LonField"].text = Math.round(_loc1_.lon) + "° E";
   }
}
init();
reset();
