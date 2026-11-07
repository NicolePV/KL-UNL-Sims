function doTransition()
{
   if(direction == 1)
   {
      startTime = getTimer() - transitionTime * (1 - transitionParameter);
   }
   else
   {
      startTime = getTimer() - transitionTime * (transitionParameter - 0.001);
   }
   direction *= -1;
   onEnterFrame = onEnterFrameFunc;
   updateCelestialDiagram();
}
function onEnterFrameFunc()
{
   var u = (getTimer() - startTime) / transitionTime;
   if(u > 1)
   {
      u = 1;
      delete onEnterFrame;
   }
   if(direction != 1)
   {
      u = 1 - u;
   }
   if(u < 0.001)
   {
      u = 0.001;
   }
   transitionParameter = u;
   updateCelestialDiagram();
}
function updateCelestialDiagram()
{
   var t = transitionParameter;
   arrowMC.setTransitionFactor(t);
   var scale = t * 100;
   celestialSphere.globeSphere.instance._xscale = scale;
   celestialSphere.globeSphere.instance._yscale = scale;
   var pt = {az:180,alt:latitudeSlider.value,r:t * maxGlobeSize / celestialSphere.size};
   celestialSphere.tangentPlane.setPosition(pt);
   celestialSphere.tangentPlane.setOrientationType("absolute");
   celestialSphere.tangentPlane.instance.update(t);
   pt.r += 0.001;
   celestialSphere.stickfigure.setPosition(pt);
   celestialSphere.stickfigure.setOrientationType("skewed",pt);
   celestialSphere.stickfigure.instance._xscale = 100 - scale;
   celestialSphere.stickfigure.instance._yscale = 100 - scale;
   celestialSphere.updateObjects();
}
function changeLatitude()
{
   var lat = latitudeSlider.value;
   celestialSphere.globeSphere.instance.latitudeCircle.setParameters({alt:lat,az:0,tilt:0});
   celestialSphere.globeSphere.instance.latitudeCircle.update();
   celestialSphere.globeSphere.instance.dot.setPosition({az:180,alt:lat});
   celestialSphere.globeSphere.instance.dot.setOrientationType("absolute");
   celestialSphere.globeSphere.instance.updateObjects();
   if(lat < 0)
   {
      celestialSphere.globeSphere.setPosition({x:0,y:0,z:-0.001,system:"horizon"});
      celestialSphere.meridianCircle1.setParameters({alt:0,az:180,tilt:90,gammaStart:lat - 90,gammaEnd:lat + 90});
      celestialSphere.meridianCircle2.setParameters({alt:0,az:90,tilt:- lat,gammaStart:180,gammaEnd:0});
      celestialSphere.meridianCircle1.update();
      celestialSphere.meridianCircle2.update();
   }
   else
   {
      celestialSphere.globeSphere.setPosition({x:0,y:0,z:0.001,system:"horizon"});
      celestialSphere.meridianCircle1.setParameters({alt:0,az:180,tilt:90,gammaStart:lat - 90,gammaEnd:lat + 90});
      celestialSphere.meridianCircle2.setParameters({alt:0,az:90,tilt:180 - lat,gammaStart:0,gammaEnd:180});
      celestialSphere.meridianCircle1.update();
      celestialSphere.meridianCircle2.update();
   }
   celestialSphere.horizonCircle.setParameters({alt:0,az:90,tilt:90 - lat});
   celestialSphere.horizonCircle.update();
   updateCelestialDiagram();
}
function initSphere()
{
   celestialSphere.latitude = 90;
   celestialSphere.siderealTime = 0;
   celestialSphere.showHorizonPlane = false;
   celestialSphere.addShadingClip("Sphere Shading","sphereShadingFront","front","inner","both");
   celestialSphere.addShadingClip("Sphere Shading","sphereShadingBack","back","inner","both");
   celestialSphere.addCircle("horizonCircle",{thickness:1,color:16777215,alpha:30},{az:0,alt:0,tilt:0});
   celestialSphere.addCircle("meridianCircle1",{thickness:1,color:16777215,alpha:30},{az:0,alt:0,tilt:0});
   celestialSphere.addCircle("meridianCircle2",{thickness:1,color:16777215,alpha:30},{az:0,alt:0,tilt:0});
   celestialSphere.addCircle("zeroHoursCircle",{thickness:1,color:16769909,alpha:70},{ra:0,dec:0,tilt:90,gammaStart:-90,gammaEnd:90});
   celestialSphere.addCircle("celestialEquator",{thickness:1,color:16769909,alpha:70},{ra:0,dec:0,tilt:0});
   celestialSphere.zeroHoursCircle.update();
   celestialSphere.celestialEquator.update();
   celestialSphere.addLine("ncpAxis",{thickness:2,color:7711231,alpha:100},{x:0,y:0,z:1,system:"celestial"},{x:0,y:0,z:1.2,system:"celestial"});
   celestialSphere.addLine("scpAxis",{thickness:2,color:7711231,alpha:100},{x:0,y:0,z:-1,system:"celestial"},{x:0,y:0,z:-1.2,system:"celestial"});
   celestialSphere.updateLines();
   celestialSphere.addObject("Tangent Plane","tangentPlane",{x:0,y:0,z:0,system:"horizon"});
   celestialSphere.addObject("Stickfigure","stickfigure",{x:0,y:0,z:0,system:"horizon"});
   celestialSphere.addObject("CelestialSphere","globeSphere",{x:0,y:0,z:0.001,system:"horizon"},{_traceOn:false});
   celestialSphere.globeSphere.instance.size = 80;
   celestialSphere.globeSphere.instance.latitude = 90;
   celestialSphere.globeSphere.instance.siderealTime = 0;
   celestialSphere.globeSphere.instance.showHorizonPlane = false;
   celestialSphere.globeSphere.instance.setMouseBehavior("none");
   celestialSphere.globeSphere.instance.addCircle("longitudeCircle",{thickness:1,color:7368816,alpha:100},{alt:0,az:0,tilt:90,gammaStart:90,gammaEnd:-90});
   celestialSphere.globeSphere.instance.addCircle("latitudeCircle",{thickness:1,color:7368816,alpha:100},{alt:0,az:0,tilt:0});
   celestialSphere.globeSphere.instance.longitudeCircle.update();
   celestialSphere.globeSphere.instance.addObject("Observer Dot","dot",{x:0,y:0,z:0,system:"horizon"});
   celestialSphere.globeSphere.instance.addObject("GlobeComponent","globe",{x:0,y:0,z:0,system:"horizon"},{_traceOn:false});
   celestialSphere.globeSphere.instance.globe.instance.setScale(100);
   celestialSphere.globeSphere.instance.globe.instance.update();
   celestialSphere.onMouseUpdate = function()
   {
      celestialSphere.globeSphere.instance.setThetaAndPhi(celestialSphere.theta,celestialSphere.phi);
      celestialSphere.globeSphere.instance.globe.instance.update();
      celestialSphere.tangentPlane.instance.update(transitionParameter);
      updateAfterEvent();
   };
   changeLatitude();
}
transitionTime = 3000;
maxGlobeSize = 80;
transitionParameter = 1;
direction = 1;
latitudeField.restrict = "0-9\\-.";
initSphere();
