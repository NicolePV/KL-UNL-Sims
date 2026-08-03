function initializeHorizonDiagram()
{
   var _loc1_ = this;
   horizonDiagram.size = 260;
   horizonDiagram.latitude = 40.8;
   horizonDiagram.showUnder = false;
   horizonDiagram.viewerAzimuth = 200;
   horizonDiagram.viewerAltitude = 40;
   horizonDiagram.minViewerAltitude = 7;
   horizonDiagram.addObject("Stickman","stickman",{x:0,y:0,z:0.001,system:"horizon"});
   horizonDiagram.stickman.setOrientationType("absolute",{x:-1,y:0,z:0,system:"horizon"},{x:0,y:0,z:1,system:"horizon"});
   horizonDiagram.addObject("ShadowMaker","shadow",{x:0,y:0,z:0,system:"horizon"},{shadowClip:"StickmanShadow"});
   horizonDiagram.shadow.setOrientationType("absolute",{x:0,y:0,z:1,system:"horizon"},{x:1,y:0,z:0,system:"horizon"});
   horizonDiagram.addObject("SunDisk","sun",{ra:0,dec:0});
   horizonDiagram.addCircle("meridianCircle1",{thickness:1,color:16777215,alpha:20},{az:0,alt:0,tilt:90});
   horizonDiagram.addCircle("meridianCircle2",{thickness:1,color:16777215,alpha:20},{az:90,alt:0,tilt:90});
   horizonDiagram.addCircle("maxDeclinationCircle",{thickness:1,color:16777215,alpha:50},{ra:0,dec:23.44,tilt:0});
   horizonDiagram.addCircle("minDeclinationCircle",{thickness:1,color:16777215,alpha:50},{ra:0,dec:-23.44,tilt:0});
   horizonDiagram.addCircle("celestialEquator",{thickness:2,color:2915326,alpha:60},{ra:0,dec:0,tilt:0});
   horizonDiagram.addCircle("decCircle",{thickness:2,color:16763904,alpha:70},{ra:0,dec:0,tilt:90});
   horizonDiagram.updateCircles();
   horizonDiagram.sun.visible = false;
   horizonDiagram.shadow.visible = false;
   horizonDiagram.decCircle.visible = false;
   attachMovie("Celestial Equator Label","celestialEquatorLabel",101,{_visible:false});
   attachMovie("Declination Circle Label","declinationCircleLabel",102,{_visible:false});
   attachMovie("Max Declination Circle Label","maxDeclinationCircleLabel",103,{_visible:false});
   attachMovie("Min Declination Circle Label","minDeclinationCircleLabel",104,{_visible:false});
   horizonDiagram.minDeclinationCircle.setUseMouseFunctions(true,"front only");
   horizonDiagram.minDeclinationCircle.onRollOver = function(side)
   {
      horizonDiagram.minDeclinationCircle.setStyle(3,16777215,70);
      horizonDiagram.minDeclinationCircle.update();
      minDeclinationCircleLabel._visible = true;
      minDeclinationCircleLabel._x = this._xmouse - 5;
      minDeclinationCircleLabel._y = this._ymouse - 5;
   };
   horizonDiagram.minDeclinationCircle.onRollOut = horizonDiagram.minDeclinationCircle.onReleaseOutside = function()
   {
      horizonDiagram.minDeclinationCircle.setStyle(1,16777215,50);
      horizonDiagram.minDeclinationCircle.update();
      minDeclinationCircleLabel._visible = false;
   };
   horizonDiagram.maxDeclinationCircle.setUseMouseFunctions(true,"front only");
   horizonDiagram.maxDeclinationCircle.onRollOver = function(side)
   {
      horizonDiagram.maxDeclinationCircle.setStyle(3,16777215,70);
      horizonDiagram.maxDeclinationCircle.update();
      maxDeclinationCircleLabel._visible = true;
      maxDeclinationCircleLabel._x = this._xmouse - 5;
      maxDeclinationCircleLabel._y = this._ymouse - 5;
   };
   horizonDiagram.maxDeclinationCircle.onRollOut = horizonDiagram.maxDeclinationCircle.onReleaseOutside = function()
   {
      horizonDiagram.maxDeclinationCircle.setStyle(1,16777215,50);
      horizonDiagram.maxDeclinationCircle.update();
      maxDeclinationCircleLabel._visible = false;
   };
   horizonDiagram.celestialEquator.setUseMouseFunctions(true,"front only");
   horizonDiagram.celestialEquator.onRollOver = function(side)
   {
      horizonDiagram.celestialEquator.setStyle(3,2915326,90);
      horizonDiagram.celestialEquator.update();
      celestialEquatorLabel._visible = true;
      celestialEquatorLabel._x = this._xmouse - 5;
      celestialEquatorLabel._y = this._ymouse - 5;
   };
   horizonDiagram.celestialEquator.onRollOut = horizonDiagram.celestialEquator.onReleaseOutside = function()
   {
      horizonDiagram.celestialEquator.setStyle(2,2915326,60);
      horizonDiagram.celestialEquator.update();
      celestialEquatorLabel._visible = false;
   };
   horizonDiagram.decCircle.setUseMouseFunctions(true,"front only");
   horizonDiagram.decCircle.onRollOver = function(side)
   {
      horizonDiagram.decCircle.setStyle(3,16763904,90);
      horizonDiagram.decCircle.update();
      declinationCircleLabel._visible = true;
      declinationCircleLabel._x = this._xmouse - 5;
      declinationCircleLabel._y = this._ymouse - 5;
   };
   horizonDiagram.decCircle.onRollOut = horizonDiagram.decCircle.onReleaseOutside = function()
   {
      horizonDiagram.decCircle.setStyle(2,16763904,70);
      horizonDiagram.decCircle.update();
      declinationCircleLabel._visible = false;
   };
   horizonDiagram.addShadingClip("CSGradientDisk","skyBack","back","inner","above",{innerAlpha:15,outerAlpha:35,innerColor:12575999,outerColor:12575999});
   horizonDiagram.addShadingClip("CSGradientDisk","skyFront","front","inner","above",{innerAlpha:10,outerAlpha:30,innerColor:12575999,outerColor:12575999});
   horizonDiagram.addShadingClip("CSGradientDisk","skyBackDark","back","outer","both",{innerAlpha:100,outerAlpha:100,innerColor:11719654,outerColor:11719654});
   horizonDiagram.addHorizonPlaneClip("direction labels dark","belowLabels","below");
   horizonDiagram.addHorizonPlaneClip("direction labels light","aboveLabels","above");
   horizonDiagram.onMouseUpdate = function()
   {
      updateAfterEvent();
   };
   horizonDiagram.update();
}
initializeHorizonDiagram();
