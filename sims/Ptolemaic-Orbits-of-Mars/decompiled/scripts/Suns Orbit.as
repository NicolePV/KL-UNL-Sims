function SunsOrbitClass()
{
   this.attachMovie("Sun Icon","sunMC",50);
   var scaleFactor = 1.64;
   this.eccentricity = 2.5 * scaleFactor;
   this.deferentRadius = 60 * scaleFactor;
   this.apogee = 65.5;
   this.kappaAtEpoch = 265.25;
   this._rotation = - this.apogee;
   this.createEmptyMovieClip("deferentMC",10);
   this.deferentMC._x = this.eccentricity;
   this.deferentMC.clear();
   this.deferentMC.lineStyle(0,10526880,100);
   this.drawCircle(this.deferentMC,this.deferentRadius);
   this.setTime(0);
}
var p = SunsOrbitClass.prototype = new MovieClip();
Object.registerClass("Suns Orbit",SunsOrbitClass);
p.setTime = function(arg)
{
   var kappa = 0.017453292519943295 * this.kappaAtEpoch + arg * 6.283185307179586;
   this.sunMC._x = this.eccentricity + this.deferentRadius * Math.cos(kappa);
   this.sunMC._y = (- this.deferentRadius) * Math.sin(kappa);
};
p.drawCircle = function(mc, r)
{
   var cos = Math.cos;
   var sin = Math.sin;
   var n = 10;
   var step = 6.283185307179586 / n;
   var halfStep = step / 2;
   var cr = r / cos(halfStep);
   var aAngle = step;
   var cAngle = halfStep;
   mc.moveTo(r,0);
   var i = 0;
   while(i < n)
   {
      mc.curveTo(cr * cos(cAngle),cr * sin(cAngle),r * cos(aAngle),r * sin(aAngle));
      aAngle += step;
      cAngle += step;
      i++;
   }
};
