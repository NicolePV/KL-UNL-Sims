function changeLatitude(arg)
{
   sphere.latitude = arg;
   setShadow();
   setSkyColor();
}
function setShadow()
{
   if(sphere._sunObject.alt > 0)
   {
      var maxscale = 400;
      var newscale = 100 / Math.tan(0.017453292519943295 * sphere._sunObject.alt);
      if(newscale > maxscale)
      {
         newscale = maxscale;
      }
      if(sphere._sunObject.az < 90 || sphere._sunObject.az > 270)
      {
         newscale = - newscale;
      }
      sphere.stickmanShadow.instance._alpha = (maxscale - Math.abs(newscale)) * (100 / maxscale);
      sphere.stickmanShadow.instance._yscale = newscale;
      sphere.stickmanShadow.instance._visible = true;
   }
   else
   {
      sphere.stickmanShadow.instance._visible = false;
   }
}
function setSkyColor()
{
   var intensity = sphere._sunObject.alt / 10 + 0.5;
   if(intensity > 1)
   {
      intensity = 1;
   }
   else if(intensity < 0)
   {
      intensity = 0;
   }
   sphere.backSky.innerAlpha = intensity * backInnerAlphaRange + nightBackInnerAlpha;
   sphere.backSky.outerAlpha = intensity * backOuterAlphaRange + nightBackOuterAlpha;
   sphere.backSky.update();
   sphere.frontSky.innerAlpha = intensity * frontInnerAlphaRange + nightFrontInnerAlpha;
   sphere.frontSky.outerAlpha = intensity * frontOuterAlphaRange + nightFrontOuterAlpha;
   sphere.frontSky.update();
}
sphere.size = 240;
sphere.addCircle("celestialEquator",{thickness:1,color:5263440,alpha:100},{ra:0,dec:0,tilt:0});
sphere.addCircle("sunsPath",{thickness:1,color:16777152,alpha:100},{ra:0,dec:0,tilt:0});
sphere.addCircle("meridian",{thickness:1,color:12632256,alpha:100},{az:0,alt:0,tilt:90});
sphere.addCircle("ecliptic",{thickness:1,color:16732240,alpha:100},{ra:0,dec:0,tilt:23.5});
sphere.showUnder = false;
this.onEnterFrame = function()
{
   if(animateCheck.getValue())
   {
      sphere.setDay(sphere._day + 1);
      sphere.sunsPath.setCircleParameters({ra:0,dec:sphere._sunObject.dec,tilt:0});
      setSkyColor();
      setShadow();
   }
   dateString = sphere.getDateString();
};
sphere.addHorizonPlaneClip("direction labels dark","darkLabels","below");
sphere.addHorizonPlaneClip("direction labels light","lightLabels");
sphere.addShadingClip("CSGradientDisk","underSky","front","inner","below",{innerAlpha:20,innerColor:8702975,outerAlpha:30,outerColor:8702975});
sphere.celestialBowl.removeMovieClip();
sphere.addShadingClip("CSGradientDisk","frontSky","front","inner","above",{innerColor:8702975,outerColor:8702975});
sphere.addShadingClip("CSGradientDisk","backSky","back","outer","above",{innerColor:8702975,outerColor:8702975});
sphere.addObject("Stickman","stickman",{x:0,y:0,z:0.001,system:"horizon"});
sphere.stickman.setOrientationType("absolute",{alt:0,az:180},{alt:90,az:0});
sphere.addObject("StickmanShadow","stickmanShadow",{x:0,y:0,z:0,system:"horizon"});
sphere.stickmanShadow.setOrientationType("absolute",{alt:90,az:0},{alt:0,az:0});
sphere.minViewerAltitude = 7;
dayBackInnerAlpha = 100;
dayBackOuterAlpha = 80;
nightBackInnerAlpha = 30;
nightBackOuterAlpha = 20;
backInnerAlphaRange = dayBackInnerAlpha - nightBackInnerAlpha;
backOuterAlphaRange = dayBackOuterAlpha - nightBackOuterAlpha;
dayFrontInnerAlpha = 10;
dayFrontOuterAlpha = 40;
nightFrontInnerAlpha = 0;
nightFrontOuterAlpha = 15;
frontInnerAlphaRange = dayFrontInnerAlpha - nightFrontInnerAlpha;
frontOuterAlphaRange = dayFrontOuterAlpha - nightFrontOuterAlpha;
sphere.viewerAzimuth = 200;
sphere.update();
setSkyColor();
setShadow();
