function MarsOrbitClass()
{
   this.attachMovie("Mars Icon","marsMC",50);
   var scaleFactor = 2.5;
   this.eccentricity = 6 * scaleFactor;
   this.deferentRadius = 60 * scaleFactor;
   this.epicycleRadius = 39.5 * scaleFactor;
   this.apogee = 106.67;
   this.kappaAtEpoch = 3.53;
   this.alphaAtEpoch = 327.22;
   this.period = 1.881;
   this._rotation = - this.apogee;
   this.createEmptyMovieClip("deferentMC",10);
   this.createEmptyMovieClip("epicycleMC",20);
   this.deferentMC._x = this.eccentricity;
   this.deferentMC.clear();
   this.deferentMC.lineStyle(0,0,100);
   this.drawCircle(this.deferentMC,this.deferentRadius);
   this.epicycleMC.clear();
   this.epicycleMC.lineStyle(0,0,100);
   this.drawCircle(this.epicycleMC,this.epicycleRadius);
   this.lineSegments = 175;
   this.createEmptyMovieClip("orbitPathMC",5);
   this.pathSegmentsArray = [];
   var i = 0;
   while(i < this.lineSegments)
   {
      this.pathSegmentsArray.push(this.orbitPathMC.createEmptyMovieClip("_" + i,i));
      i++;
   }
   this.currentSegment = 0;
   this.kappa0 = 0.017453292519943295 * (this.kappaAtEpoch - this.apogee);
   this.gamma0 = 0.017453292519943295 * (this.alphaAtEpoch + this.kappaAtEpoch - this.apogee);
   this.timeLast = -0.002;
   this.setTime(0);
}
var p = MarsOrbitClass.prototype = new MovieClip();
Object.registerClass("Mars Orbit",MarsOrbitClass);
p.setTime = function(arg)
{
   var start = getTimer();
   var maxTimeStep = 0.02;
   var minTimeStep = 0.002;
   var deltaT = arg - this.timeLast;
   if(Math.abs(deltaT) < minTimeStep)
   {
      return undefined;
   }
   var numSteps = Math.ceil(Math.abs(deltaT / maxTimeStep));
   var stepSize = deltaT / numSteps;
   var kappa0 = this.kappa0;
   var gamma0 = this.gamma0;
   var kappaRate = 6.283185307179586 / this.period;
   var dR = this.deferentRadius;
   var eR = this.epicycleRadius;
   var e = this.eccentricity;
   var cos = Math.cos;
   var sin = Math.sin;
   var sqrt = Math.sqrt;
   var t0 = this.timeLast;
   var lx = this.lastX;
   var ly = this.lastY;
   var cs = this.currentSegment;
   var ls = this.lineSegments;
   var segments = this.pathSegmentsArray;
   var i = 0;
   while(i < numSteps)
   {
      var t = t0 + i * stepSize;
      var kappa = kappa0 + t * kappaRate;
      var sk = sin(kappa);
      var ck = cos(kappa);
      var m = (- e) * ck + sqrt(dR * dR - e * e * sk * sk);
      var cx = 2 * e + m * ck;
      var cy = m * sk;
      var gamma = gamma0 + 6.283185307179586 * t;
      var cpx = eR * cos(gamma);
      var cpy = eR * sin(gamma);
      var px = cx + cpx;
      var py = - (cy + cpy);
      if(lx != undefined)
      {
         cs = (cs + 1) % ls;
         var mc = segments[cs];
         mc.clear();
         mc.lineStyle(1,16711680,100);
         mc.moveTo(lx,ly);
         mc.lineTo(px,py);
      }
      lx = px;
      ly = py;
      i++;
   }
   this.marsMC._x = px;
   this.marsMC._y = py;
   this.epicycleMC._x = cx;
   this.epicycleMC._y = - cy;
   this.lastX = lx;
   this.lastY = ly;
   this.timeLast = arg;
   this.currentSegment = cs;
   var alphaStep = 100 / ls;
   var i = 0;
   while(i < ls)
   {
      if(i > cs)
      {
         segments[i]._alpha = 100 - alphaStep * (cs - i + ls);
      }
      else
      {
         segments[i]._alpha = 100 - alphaStep * (cs - i);
      }
      i++;
   }
   trace("time: " + (getTimer() - start));
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
