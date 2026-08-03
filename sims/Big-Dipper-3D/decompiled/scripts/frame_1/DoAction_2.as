dragArea.useHandCursor = false;
dragArea.onPress = function()
{
   this.initX = this._xmouse;
   this.initY = this._ymouse;
   this.initTheta = sphere.theta;
   this.initPhi = sphere.phi;
   this.onMouseMove = function()
   {
      var r = sphere.size / 2;
      var deltaX = this._xmouse - this.initX;
      var newTheta = this.initTheta + 57.29577951308232 * (1 / r) * deltaX;
      newTheta = (newTheta % 360 + 360) % 360;
      if(newTheta < 122)
      {
         newTheta = 122;
      }
      else if(newTheta > 247)
      {
         newTheta = 247;
      }
      var deltaY = this._ymouse - this.initY;
      newPhi = this.initPhi - 57.29577951308232 * (1 / r) * deltaY;
      if(newPhi > 36)
      {
         newPhi = 36;
      }
      else if(newPhi < -36)
      {
         newPhi = -36;
      }
      setSphereOrientation(newTheta,newPhi);
   };
};
dragArea.onRelease = dragArea.onReleaseOutside = function()
{
   delete this.onMouseMove;
};
sphere.size = 1000;
sphere.latitude = 35;
sphere.celestialBowl.removeMovieClip();
sphere.showHorizonPlane = false;
sphere.setMouseBehavior("none");
sphere.sortObjects = true;
sphereUnitRadius = 250;
bigDipperStars = [{name:"Dubhe",pos:{dec:61.75092,ra:11.06215,r:123.6 / sphereUnitRadius,error:2.5 / sphereUnitRadius}},{name:"Merak",pos:{dec:56.38236,ra:11.03068,r:79.4 / sphereUnitRadius,error:1.2 / sphereUnitRadius}},{name:"Phecda",pos:{dec:53.69475,ra:11.89717,r:83.7 / sphereUnitRadius,error:1.5 / sphereUnitRadius}},{name:"Megrez",pos:{dec:57.03258,ra:12.25709,r:81.4 / sphereUnitRadius,error:1.2 / sphereUnitRadius}},{name:"Alioth",pos:{dec:55.95989,ra:12.90048,r:80.9 / sphereUnitRadius,error:1.2 / sphereUnitRadius}},{name:"Mizar",pos:{dec:54.92539,ra:13.39875,r:78.2 / sphereUnitRadius,error:1.1 / sphereUnitRadius}},{name:"Alkaid",pos:{dec:49.31336,ra:13.79235,r:100.7 / sphereUnitRadius,error:2.3 / sphereUnitRadius}}];
var i = 0;
while(i < bigDipperStars.length)
{
   sphere.addObject("star point",bigDipperStars[i].name,bigDipperStars[i].pos);
   sphere.addObject("CS Star","star" + i,{ra:bigDipperStars[i].pos.ra,dec:bigDipperStars[i].pos.dec});
   sphere["star" + i].setOrientationType("absolute");
   sphere.addLine("line" + i,{thickness:1,color:0,alpha:15},{x:0,y:0,z:0,system:"celestial"},{ra:bigDipperStars[i].pos.ra,dec:bigDipperStars[i].pos.dec,r:1});
   i++;
}
sphere.addCircle("arc1",{thickness:1,color:0,alpha:0},{ra:0,dec:-64,tilt:180,gammaStart:147,gammaEnd:198});
sphere.addCircle("arc2",{thickness:1,color:0,alpha:0},{ra:22.8,dec:0,tilt:90,gammaStart:116,gammaEnd:133});
sphere.addCircle("arc3",{thickness:1,color:0,alpha:0},{ra:0,dec:47,tilt:0,gammaStart:162,gammaEnd:213});
sphere.addCircle("arc4",{thickness:1,color:0,alpha:0},{ra:14.2,dec:0,tilt:90,gammaStart:47,gammaEnd:64});
sphere.addCircle("dec50",{thickness:1,color:14737632,alpha:100},{ra:0,dec:50,tilt:0,gammaStart:162,gammaEnd:213});
sphere.addCircle("dec55",{thickness:1,color:14737632,alpha:100},{ra:0,dec:55,tilt:0,gammaStart:162,gammaEnd:213});
sphere.addCircle("dec60",{thickness:1,color:14737632,alpha:100},{ra:0,dec:60,tilt:0,gammaStart:162,gammaEnd:213});
sphere.addCircle("ra14",{thickness:1,color:14737632,alpha:100},{ra:14,dec:0,tilt:90,gammaStart:47,gammaEnd:64});
sphere.addCircle("ra13",{thickness:1,color:14737632,alpha:100},{ra:13,dec:0,tilt:90,gammaStart:47,gammaEnd:64});
sphere.addCircle("ra12",{thickness:1,color:14737632,alpha:100},{ra:12,dec:0,tilt:90,gammaStart:47,gammaEnd:64});
sphere.addCircle("ra11",{thickness:1,color:14737632,alpha:100},{ra:11,dec:0,tilt:90,gammaStart:47,gammaEnd:64});
sphere.addObject("a label","dec50_label",{ra:10.55,dec:50},{labelText:"50°"});
sphere.dec50_label.setOrientationType("absolute",{ra:22.55,dec:-50},{ra:0,dec:90});
sphere.addObject("a label","dec55_label",{ra:10.55,dec:55},{labelText:"55°"});
sphere.dec55_label.setOrientationType("absolute",{ra:22.55,dec:-55},{ra:0,dec:90});
sphere.addObject("a label","dec60_label",{ra:10.55,dec:60},{labelText:"60°"});
sphere.dec60_label.setOrientationType("absolute",{ra:22.55,dec:-60},{ra:0,dec:90});
sphere.addObject("a label","ra11_label",{ra:11,dec:65.3},{labelText:"11h"});
sphere.ra11_label.setOrientationType("absolute",{ra:23,dec:-65.3},{ra:0,dec:90});
sphere.addObject("a label","ra12_label",{ra:12,dec:65.3},{labelText:"12h"});
sphere.ra12_label.setOrientationType("absolute",{ra:0,dec:-65.3},{ra:0,dec:90});
sphere.addObject("a label","ra13_label",{ra:13,dec:65.3},{labelText:"13h"});
sphere.ra13_label.setOrientationType("absolute",{ra:1,dec:-65.3},{ra:0,dec:90});
sphere.addObject("a label","ra14_label",{ra:14,dec:65.3},{labelText:"14h"});
sphere.ra14_label.setOrientationType("absolute",{ra:2,dec:-65.3},{ra:0,dec:90});
sphere.addObject("earth label","earth_label",{ra:12.5,dec:55,r:0});
setSphereOrientation(221.2,-8.6);
