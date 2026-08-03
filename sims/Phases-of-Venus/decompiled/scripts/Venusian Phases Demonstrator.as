function VenusianPhasesDemonstratorClass()
{
   this.createEmptyMovieClip("phaseMC",1);
   this.phaseMC._x = 434;
   this.phaseMC._y = -65;
   var r = Math.sqrt(this.earthMC._x * this.earthMC._x + this.earthMC._y * this.earthMC._y);
   this.earthOrbitalRadius = r;
   this.venusOrbitalRadius = 0.723 * r;
   this.animationRate = 10;
   this.setVenusAngle(0.5);
   this.setEarthAngle(0);
}
var p = VenusianPhasesDemonstratorClass.prototype = new MovieClip();
Object.registerClass("Venusian Phases Demonstrator",VenusianPhasesDemonstratorClass);
p.pause = function()
{
   this.animatingAtPause = this.onEnterFrame == this.animateOnEnterFrame;
   delete this.onEnterFrame;
};
p.resume = function()
{
   if(this.animatingAtPause)
   {
      this.startAnimation();
   }
   else
   {
      this.stopAnimation();
   }
};
p.toggleAnimation = function()
{
   if(this.onEnterFrame == this.animateOnEnterFrame)
   {
      this.stopAnimation();
   }
   else
   {
      this.startAnimation();
   }
};
p.startAnimation = function()
{
   this.animationButton.setLabel("stop animation");
   this.timeLast = getTimer();
   this.onEnterFrame = this.animateOnEnterFrame;
};
p.stopAnimation = function()
{
   this.animationButton.setLabel("start animation");
   delete this.onEnterFrame;
};
p.animateOnEnterFrame = function()
{
   var timeNow = getTimer();
   var dt = (timeNow - this.timeLast) / (1000 * this.animationRate);
   var venusAngle = (- dt) * 10.220506756884017 + Math.atan2(this.venusMC._y,this.venusMC._x);
   var earthAngle = (- dt) * 6.283185307179586 + Math.atan2(this.earthMC._y,this.earthMC._x);
   this.venusMC._rotation = 270 + venusAngle * 57.29577951308232;
   this.venusLabelMC._x = this.venusMC._x = this.venusOrbitalRadius * Math.cos(venusAngle);
   this.venusLabelMC._y = this.venusMC._y = this.venusOrbitalRadius * Math.sin(venusAngle);
   this.earthMC._rotation = 270 + earthAngle * 57.29577951308232;
   this.earthLabelMC._x = this.earthMC._x = this.earthOrbitalRadius * Math.cos(earthAngle);
   this.earthLabelMC._y = this.earthMC._y = this.earthOrbitalRadius * Math.sin(earthAngle);
   this.drawPhasePicture();
   this.timeLast = timeNow;
};
p.setVenusAngle = function(venusAngle)
{
   this.venusMC._rotation = 270 + venusAngle * 57.29577951308232;
   this.venusLabelMC._x = this.venusMC._x = this.venusOrbitalRadius * Math.cos(venusAngle);
   this.venusLabelMC._y = this.venusMC._y = this.venusOrbitalRadius * Math.sin(venusAngle);
   this.drawPhasePicture();
};
p.setEarthAngle = function(earthAngle)
{
   this.earthMC._rotation = 270 + earthAngle * 57.29577951308232;
   this.earthLabelMC._x = this.earthMC._x = this.earthOrbitalRadius * Math.cos(earthAngle);
   this.earthLabelMC._y = this.earthMC._y = this.earthOrbitalRadius * Math.sin(earthAngle);
   this.drawPhasePicture();
};
p.drawPhasePicture = function()
{
   var sin = Math.sin;
   var cos = Math.cos;
   var venusAngle = Math.atan2(this.venusMC._y,this.venusMC._x);
   var earthAngle = Math.atan2(this.earthMC._y,this.earthMC._x);
   var theta = 6.283185307179586 * (((earthAngle - venusAngle) / 6.283185307179586 % 1 + 1) % 1);
   var ct = cos(theta);
   var re = this.earthOrbitalRadius;
   var rv = this.venusOrbitalRadius;
   var d = Math.sqrt(re * re + rv * rv - 2 * re * rv * ct);
   var ca0 = (rv - re * ct) / d;
   if(ca0 > 1)
   {
      ca0 = 1;
   }
   else if(ca0 < -1)
   {
      ca0 = -1;
   }
   var a0 = Math.acos(ca0);
   if(theta < 3.141592653589793)
   {
      var a = 6.283185307179586 - a0;
      var e = (a - theta - 3.141592653589793) * 57.29577951308232;
   }
   else
   {
      var a = a0;
      var e = (- (theta - a - 3.141592653589793)) * 57.29577951308232;
   }
   this.distanceString = (d / re).toFixed(2) + " AU";
   if(e < 0)
   {
      this.elongationString = Math.abs(e).toFixed(1) + "° E";
   }
   else
   {
      this.elongationString = e.toFixed(1) + "° W";
   }
   if(a < 3.141592653589793)
   {
      var f = -1;
   }
   else
   {
      var f = 1;
   }
   var n = 4;
   var r = 100;
   var s = r * cos(a);
   var step = 3.141592653589793 / n;
   var halfStep = step / 2;
   var kr = r / cos(halfStep);
   var ks = s / cos(halfStep);
   var mc = this.phaseMC;
   mc._xscale = mc._yscale = 100 * (re - rv) / d;
   mc.clear();
   mc.lineStyle(1,16711680,0);
   mc.moveTo(0,- r);
   mc.beginFill(3158064,100);
   var i = 1;
   while(i <= n)
   {
      var angle = i * step;
      var ax = r * sin(angle);
      var ay = (- r) * cos(angle);
      var cAngle = angle - halfStep;
      var cx = kr * sin(cAngle);
      var cy = (- kr) * cos(cAngle);
      mc.curveTo(f * cx,cy,f * ax,ay);
      i++;
   }
   var i = n - 1;
   while(i >= 0)
   {
      var angle = i * step;
      var ax = s * sin(angle);
      var ay = (- r) * cos(angle);
      var cAngle = angle + halfStep;
      var cx = ks * sin(cAngle);
      var cy = (- kr) * cos(cAngle);
      mc.curveTo(f * cx,cy,f * ax,ay);
      i--;
   }
   mc.endFill();
   mc.moveTo(0,- r);
   mc.beginFill(16777215,100);
   var i = 1;
   while(i <= n)
   {
      var angle = i * step;
      var ax = (- r) * sin(angle);
      var ay = (- r) * cos(angle);
      var cAngle = angle - halfStep;
      var cx = (- kr) * sin(cAngle);
      var cy = (- kr) * cos(cAngle);
      mc.curveTo(f * cx,cy,f * ax,ay);
      i++;
   }
   var i = n - 1;
   while(i >= 0)
   {
      var angle = i * step;
      var ax = s * sin(angle);
      var ay = (- r) * cos(angle);
      var cAngle = angle + halfStep;
      var cx = ks * sin(cAngle);
      var cy = (- kr) * cos(cAngle);
      mc.curveTo(f * cx,cy,f * ax,ay);
      i--;
   }
   mc.endFill();
};
Number.prototype.toFixed = function(fractionDigits)
{
   var f = int(fractionDigits);
   if(f < 0 || f > 20)
   {
      return "Range Error";
   }
   var x = this;
   if(isNaN(x))
   {
      return "NaN";
   }
   var s = "";
   if(x < 0)
   {
      s = "-";
      x = - x;
   }
   var m = "";
   if(x < 1e+21)
   {
      var n = Math.round(x * Math.pow(10,f));
      if(n == 0)
      {
         m = "0";
      }
      else
      {
         m = n.toString();
      }
      if(f > 0)
      {
         var k = m.length;
         if(k <= f)
         {
            var z = "";
            var i = 0;
            while(i < f + 1 - k)
            {
               z += "0";
               i++;
            }
            m = z + m;
            k = f + 1;
         }
         var a = m.substr(0,k - f);
         var b = m.substr(k - f);
         m = a + "." + b;
      }
   }
   else
   {
      m = x.toString();
   }
   return s + m;
};
