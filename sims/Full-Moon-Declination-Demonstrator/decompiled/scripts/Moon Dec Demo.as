function MoonDecDemoClass()
{
   this.init();
   this.setDayOfYear(90);
}
var p = MoonDecDemoClass.prototype = new MovieClip();
Object.registerClass("Moon Dec Demo",MoonDecDemoClass);
p.setDayOfYear = function(arg)
{
   this._dayOfYear = (arg % 365 + 365) % 365;
   this.update();
};
p.setThetaAndPhi = function(theta, phi)
{
   this.sphereMC.setThetaAndPhi(theta,phi);
};
p.update = function()
{
   var sunLongitude = (this._dayOfYear - 78) / 365 * 2 * 3.141592653589793;
   var sunDeclination = Math.asin(0.39714789063478056 * Math.sin(sunLongitude));
   var sunDec = 57.29577951308232 * sunDeclination;
   var sunRA = (3.819718634205488 * Math.atan2(Math.sin(sunLongitude) * 0.9177546256839811,Math.cos(sunLongitude)) % 24 + 24) % 24;
   this.sphereMC.sun.setPosition({ra:sunRA,dec:sunDec});
   this.sphereMC.sun.setOrientationType("absolute");
   this.sphereMC.moon.setPosition({ra:sunRA + 12,dec:- sunDec});
   this.sphereMC.moon.setOrientationType("absolute");
   this.sphereMC.siderealTime = sunRA + 12;
};
p.init = function()
{
   this.attachMovie("CelestialSphere","sphereMC",1,{_traceOn:false});
   this.sphereMC.minViewerAltitude = 7;
   this.sphereMC.addShadedBand("Symbol 204","Symbol 204","testBand",{dec1:-5.1,dec2:5.1,tilt:23.4},"inner","full");
   this.sphereMC.testBand.setBorderStyle(1,16711680,40);
   this.sphereMC.size = 300;
   this.sphereMC.onMouseUpdate = function()
   {
      updateAfterEvent();
   };
   this.sphereMC.addHorizonPlaneClip("Symbol 169","directionLabels","above");
   this.sphereMC.addObject("Sun Disc","sun",{ra:0,dec:0});
   this.sphereMC.addObject("Moon Disc","moon",{ra:12,dec:0});
   this.sphereMC.addCircle("ecliptic",{thickness:1,color:10502208,alpha:50},{ra:0,dec:0,tilt:23.4});
   this.sphereMC.addCircle("meridian",{thickness:1,color:16769909,alpha:70},{az:0,alt:0,tilt:90});
   this.sphereMC.addCircle("celestialEquator",{thickness:1,color:16769909,alpha:70},{ra:0,dec:0,tilt:0});
   this.sphereMC.addLine("ncpAxis",{thickness:2,color:7711231,alpha:100},{x:0,y:0,z:1,system:"celestial"},{x:0,y:0,z:1.2,system:"celestial"});
   this.sphereMC.addLine("scpAxis",{thickness:2,color:7711231,alpha:100},{x:0,y:0,z:-1,system:"celestial"},{x:0,y:0,z:-1.2,system:"celestial"});
   this.sphereMC.update();
};
