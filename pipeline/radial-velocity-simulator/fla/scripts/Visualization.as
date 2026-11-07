function VisualizationClass()
{
   var bmc = this.createEmptyMovieClip("backgroundMC",0);
   bmc.beginFill(16777215);
   bmc.moveTo(0,0);
   bmc.lineTo(400,0);
   bmc.lineTo(400,400);
   bmc.lineTo(0,400);
   bmc.lineTo(0,0);
   bmc.endFill();
   var initObj = {};
   initObj.initAllowDragging = false;
   initObj.initShowArrow = false;
   initObj.initShowOrbitalPlane = false;
   initObj.initOrbitalPathsColor = 7368816;
   initObj.initBackgroundColor = 16777215;
   initObj.width = 200;
   initObj.height = 200;
   this.createEmptyMovieClip("sideViewWrapperMC",1);
   this.sideViewWrapperMC._x = 100;
   this.sideViewWrapperMC._y = 100;
   initObj._x = -100;
   initObj._y = -100;
   this.sideViewWrapperMC.attachMovie("Binary System Component","sideViewMC",1,initObj);
   initObj._x = 200;
   initObj._y = 0;
   this.attachMovie("Binary System Component","earthViewMC",2,initObj);
   initObj._x = 0;
   initObj._y = 200;
   this.attachMovie("Binary System Component","orbitViewMC",3,initObj);
   this.attachMovie("Visualization Panel Label","label1MC",21,{_x:1,_y:1,numberLabel:"1",discColor:2805840,labelText:"side view"});
   this.attachMovie("Visualization Panel Label","label2MC",22,{_x:201,_y:1,numberLabel:"2",discColor:16757557,labelText:"earth view"});
   this.attachMovie("Visualization Panel Label","label3MC",23,{_x:1,_y:201,numberLabel:"3",discColor:4955113,labelText:"orbit view"});
   var mc = this.createEmptyMovieClip("freeSpaceViewWrapperMC",4);
   mc.moveTo(-200,-200);
   mc.beginFill(0);
   mc.lineTo(200,-200);
   mc.lineTo(200,200);
   mc.lineTo(-200,200);
   mc.lineTo(-200,-200);
   mc.endFill();
   mc.tabEnabled = false;
   mc.useHandCursor = false;
   mc.onPress = function()
   {
      this.initX = this._xmouse;
      this.initY = this._ymouse;
      this.initPhi = this.freeSpaceViewSphereMC.phi;
      this.initTheta = this.freeSpaceViewSphereMC.theta;
      this.onMouseMove = this.onMouseMoveFunc;
   };
   mc.onMouseMoveFunc = function()
   {
      var theta = this.initTheta - 57.29577951308232 * (this._xmouse - this.initX) / 200;
      var phi = this.initPhi + 57.29577951308232 * (this._ymouse - this.initY) / 200;
      if(phi < -90)
      {
         phi = -90;
      }
      if(phi > 90)
      {
         phi = 90;
      }
      this._parent.setThetaAndPhi(theta,phi);
      updateAfterEvent();
   };
   mc.onRelease = mc.onReleaseOutside = function()
   {
      delete this.onMouseMove;
   };
   var sphereMC = this.freeSpaceViewWrapperMC.attachMovie("CelestialSphere","freeSpaceViewSphereMC",1,{_traceOn:false});
   var maskMC = this.freeSpaceViewWrapperMC.createEmptyMovieClip("maskMC",2);
   maskMC.moveTo(-200,-200);
   maskMC.beginFill(16711680);
   maskMC.lineTo(200,-200);
   maskMC.lineTo(200,200);
   maskMC.lineTo(-200,200);
   maskMC.lineTo(-200,-200);
   maskMC.endFill();
   sphereMC.setMask(maskMC);
   sphereMC.size = 400;
   sphereMC.showHorizonPlane = false;
   sphereMC.celestialBowl.removeMovieClip();
   sphereMC.addObject("Direction Arrow","orbitViewArrow",{x:0,y:0,z:1,system:"horizon"},{numberLabel:"3",arrowColor:4955113,labelText:"orbit view"});
   sphereMC.orbitViewArrow.setOrientationType("absolute",{x:-1,y:0,z:0,system:"horizon"},{x:0,y:0,z:1,system:"horizon"});
   sphereMC.addObject("Direction Arrow","sideViewArrow",{x:0,y:1,z:0,system:"horizon"},{numberLabel:"1",arrowColor:2805840,labelText:"side view"});
   sphereMC.addObject("Direction Arrow","earthViewArrow",{x:0,y:0,z:1,system:"horizon"},{numberLabel:"2",arrowColor:16757557,labelText:"earth view"});
   sphereMC.addObject("Direction Arrow 2","earthViewArrow2",{x:0,y:0,z:1,system:"horizon"},{arrowColor:16757557,labelText:"earth view",_xscale:65,_yscale:65});
   sphereMC.addObject("Empty Movie Clip","freeSpaceViewObject",{x:0,y:0,z:0,system:"horizon"});
   sphereMC.freeSpaceViewObject.instance.attachMovie("Binary System Component","freeSpaceViewMC",1,{initShowArrow:false,initAllowDragging:false,initOrbitalPlaneColor:8421504,initOrbitalPlaneAlpha:45,_margin:40,_x:-200,_y:-200,width:400,height:400});
   sphereMC.setMouseBehavior("none");
   this.freeSpaceViewSphereMC = this.freeSpaceViewWrapperMC.freeSpaceViewSphereMC;
   this.freeSpaceViewMC = this.freeSpaceViewSphereMC.freeSpaceViewObject.instance.freeSpaceViewMC;
   this.freeSpaceViewMC.backgroundStyle.alpha = 0;
   this.freeSpaceViewMC.borderStyle.alpha = 0;
   this.freeSpaceViewMC.updateBackground();
   var mc = this.createEmptyMovieClip("sideViewWrapperMaskMC",10);
   mc.moveTo(0,0);
   mc.beginFill(16711680);
   mc.lineTo(0,200);
   mc.lineTo(200,200);
   mc.lineTo(200,0);
   mc.lineTo(0,0);
   mc.endFill();
   this.sideViewWrapperMC.setMask(this.sideViewWrapperMaskMC);
   var mc = this.createEmptyMovieClip("mullionsMC",19);
   mc.lineStyle(1,10526880);
   mc.moveTo(200,0);
   mc.lineTo(200,400);
   mc.moveTo(0,200);
   mc.lineTo(400,200);
   var mc = this.createEmptyMovieClip("borderMC",20);
   mc.lineStyle(1,6710886);
   mc.moveTo(0,0);
   mc.lineTo(400,0);
   mc.lineTo(400,400);
   mc.lineTo(0,400);
   mc.lineTo(0,0);
   this.sideViewWrapperMC.sideViewMC.borderStyle.alpha = 0;
   this.sideViewWrapperMC.sideViewMC.updateBackground();
   this.earthViewMC.borderStyle.alpha = 0;
   this.earthViewMC.updateBackground();
   this.orbitViewMC.borderStyle.alpha = 0;
   this.orbitViewMC.updateBackground();
   this.sideViewWrapperMC.sideViewMC.color1 = 16769136;
   this.earthViewMC.color1 = 16769136;
   this.orbitViewMC.color1 = 16769136;
   this.sideViewWrapperMC.sideViewMC.color2 = 9474192;
   this.earthViewMC.color2 = 9474192;
   this.orbitViewMC.color2 = 9474192;
   this.freeSpaceViewMC.color2 = 10526880;
}
var p = VisualizationClass.prototype = new MovieClip();
Object.registerClass("Visualization",VisualizationClass);
p.radiusMultiple1 = 0.15;
p.radiusMultiple2 = 0.07;
p.setThetaAndPhi = function(theta, phi)
{
   this.freeSpaceViewSphereMC.setThetaAndPhi(theta,phi);
   this.freeSpaceViewMC.setThetaAndPhi(theta,phi);
};
p.setShowMultiplePanels = function(arg)
{
   if(arg)
   {
      this.freeSpaceViewWrapperMC._xscale = 50;
      this.freeSpaceViewWrapperMC._yscale = 50;
      this.freeSpaceViewWrapperMC._x = 300;
      this.freeSpaceViewWrapperMC._y = 300;
      this.sideViewWrapperMC._visible = true;
      this.earthViewMC._visible = true;
      this.orbitViewMC._visible = true;
      this.label1MC._visible = true;
      this.label2MC._visible = true;
      this.label3MC._visible = true;
      this.mullionsMC._visible = true;
      this.freeSpaceViewSphereMC.orbitViewArrow.instance._visible = true;
      this.freeSpaceViewSphereMC.sideViewArrow.instance._visible = true;
      this.freeSpaceViewSphereMC.earthViewArrow.instance._visible = true;
      this.freeSpaceViewSphereMC.earthViewArrow2.instance._visible = false;
   }
   else
   {
      this.freeSpaceViewWrapperMC._xscale = 100;
      this.freeSpaceViewWrapperMC._yscale = 100;
      this.freeSpaceViewWrapperMC._x = 200;
      this.freeSpaceViewWrapperMC._y = 200;
      this.sideViewWrapperMC._visible = false;
      this.earthViewMC._visible = false;
      this.orbitViewMC._visible = false;
      this.label1MC._visible = false;
      this.label2MC._visible = false;
      this.label3MC._visible = false;
      this.mullionsMC._visible = false;
      this.freeSpaceViewSphereMC.orbitViewArrow.instance._visible = false;
      this.freeSpaceViewSphereMC.sideViewArrow.instance._visible = false;
      this.freeSpaceViewSphereMC.earthViewArrow.instance._visible = false;
      this.freeSpaceViewSphereMC.earthViewArrow2.instance._visible = true;
   }
};
p.setStarTemperature = function(arg)
{
   this.freeSpaceViewMC.temperature1 = arg;
   this.reconcile();
};
p.setPlanetMass = function(arg)
{
   this.freeSpaceViewMC.mass2 = arg / 1047.52;
   this.reconcile();
};
p.setStarMass = function(arg)
{
   this.freeSpaceViewMC.mass1 = arg;
   this.reconcile();
};
p.setEccentricity = function(arg)
{
   this.freeSpaceViewMC.eccentricity = arg;
   this.reconcile();
};
p.setSeparation = function(arg)
{
   this.freeSpaceViewMC.separation = arg;
   this.freeSpaceViewMC.radius1 = arg * this.radiusMultiple1;
   this.freeSpaceViewMC.radius2 = arg * this.radiusMultiple2;
   this.reconcile();
};
p.setPhase = function(arg)
{
   this.freeSpaceViewMC.phase = arg;
   this.reconcile();
};
p.setLongitude = function(arg)
{
   this.freeSpaceViewMC.lineTheta = 90 - arg;
   this.reconcile();
};
p.setInclination = function(arg)
{
   this.freeSpaceViewMC.linePhi = 90 - arg;
   this.reconcile();
};
p.setParameters = function(paramsObj)
{
   var newParamsObj = {phase:paramsObj.phase,separation:paramsObj.separation,eccentricity:paramsObj.eccentricity,mass1:paramsObj.starMass,mass2:paramsObj.planetMass / 1047.52,radius1:paramsObj.separation * this.radiusMultiple1,radius2:paramsObj.separation * this.radiusMultiple2,linePhi:90 - paramsObj.inclination,lineTheta:90 - paramsObj.longitude,temperature1:paramsObj.starTemperature};
   this.freeSpaceViewMC.setParameters(newParamsObj);
   this.reconcile();
};
p.reconcile = function()
{
   var paramsObj = {separation:this.freeSpaceViewMC.separation,radius1:this.freeSpaceViewMC.radius1,radius2:this.freeSpaceViewMC.radius2,mass1:this.freeSpaceViewMC.mass1,mass2:this.freeSpaceViewMC.mass2,eccentricity:this.freeSpaceViewMC.eccentricity,phase:this.freeSpaceViewMC.phase,linePhi:this.freeSpaceViewMC.linePhi,lineTheta:this.freeSpaceViewMC.lineTheta};
   paramsObj.phi = 0;
   paramsObj.theta = this.freeSpaceViewMC.lineTheta - 90;
   this.sideViewWrapperMC.sideViewMC.setParameters(paramsObj);
   this.sideViewWrapperMC._rotation = this.freeSpaceViewMC.linePhi;
   paramsObj.phi = 90;
   paramsObj.theta = 0;
   this.orbitViewMC.setParameters(paramsObj);
   paramsObj.theta = this.freeSpaceViewMC.lineTheta;
   paramsObj.phi = this.freeSpaceViewMC.linePhi;
   this.earthViewMC.setParameters(paramsObj);
   var sideViewPos = {az:90 - this.freeSpaceViewMC.lineTheta,alt:0};
   var u = {};
   var v = {};
   this.freeSpaceViewSphereMC.parsePointInput(sideViewPos,u);
   this.freeSpaceViewSphereMC.parsePointInput({az:- this.freeSpaceViewMC.lineTheta,alt:this.freeSpaceViewMC.linePhi},v);
   var nVect = {system:"horizon"};
   nVect.x = u.y * v.z - u.z * v.y;
   nVect.y = u.z * v.x - u.x * v.z;
   nVect.z = u.x * v.y - u.y * v.x;
   this.freeSpaceViewSphereMC.sideViewArrow.setPosition(sideViewPos);
   this.freeSpaceViewSphereMC.sideViewArrow.setOrientationType("absolute",nVect,sideViewPos);
   var earthViewPos = {az:- this.freeSpaceViewMC.lineTheta,alt:this.freeSpaceViewMC.linePhi};
   this.freeSpaceViewSphereMC.earthViewArrow.setPosition(earthViewPos);
   this.freeSpaceViewSphereMC.earthViewArrow.setOrientationType("absolute",nVect,earthViewPos);
   this.freeSpaceViewSphereMC.earthViewArrow2.setPosition(earthViewPos);
   this.freeSpaceViewSphereMC.earthViewArrow2.setOrientationType("absolute",nVect,earthViewPos);
   this.freeSpaceViewSphereMC.updateObjects();
};
