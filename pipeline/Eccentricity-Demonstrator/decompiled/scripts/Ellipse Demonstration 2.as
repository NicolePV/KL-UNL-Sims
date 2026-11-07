function EllipseDemo2Class()
{
   this.attachMovie("Distance Component","semimajorAxisLabelMC",1,{_y:10,initLabel:"a",initColor:9474303,initLabelPlacement:4});
   this.attachMovie("Distance Component","focalDistanceLabelMC",2,{_y:-10,initLabel:"c",initColor:16748688,initLabelPlacement:-7});
}
var p = EllipseDemo2Class.prototype = new MovieClip();
Object.registerClass("Ellipse Demonstration 2",EllipseDemo2Class);
p.semimajorAxis = 100;
p.eccentricity = 0.4;
p.update = function()
{
   var a = this.semimajorAxis;
   var e = this.eccentricity;
   var b = a * Math.sqrt(1 - e * e);
   var offset = 0;
   var mc = this;
   mc.clear();
   mc.lineStyle(1,0,100);
   var cos = Math.cos;
   var sin = Math.sin;
   var n = 12;
   var step = 6.283185307179586 / n;
   var c = 1 / cos(step / 2);
   mc.moveTo(offset + a,0);
   var cAngle = step / 2;
   var aAngle = step;
   var i = 0;
   while(i < n)
   {
      var cx = offset + a * c * cos(cAngle);
      var cy = b * c * sin(cAngle);
      var ax = offset + a * cos(aAngle);
      var ay = b * sin(aAngle);
      mc.curveTo(cx,cy,ax,ay);
      cAngle += step;
      aAngle += step;
      i++;
   }
   this.semimajorAxisLabelMC.setDistance(a);
   this.focalDistanceLabelMC.setDistance(a * e);
   this.leftFocusMC._x = (- a) * e;
   this.rightFocusMC._x = a * e;
};
