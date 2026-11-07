function TransitVisualizationClass()
{
   this._scale = this.initScale;
   this.createEmptyMovieClip("backgroundMC",1);
   this.createEmptyMovieClip("maskedAreaMC",2);
   this.createEmptyMovieClip("maskMC",3);
   this.createEmptyMovieClip("borderMC",4);
   this.maskedAreaMC.createEmptyMovieClip("starMC",1);
   this.maskedAreaMC.createEmptyMovieClip("orbitMC",2);
   this.maskedAreaMC.createEmptyMovieClip("planetMC",3);
   this.maskedAreaMC.attachMovie("Transit Visualization Arrow","arrowMC",5);
   this.maskedAreaMC.setMask(this.maskMC);
   var mc = this.maskedAreaMC.starMC;
   mc.createEmptyMovieClip("diskMC",1);
   mc.createEmptyMovieClip("shadingMC",2);
   mc.diskMC.beginFill(10551200,100);
   this.drawCircle(mc.diskMC,0,0,100);
   mc.diskMC.endFill();
   mc.shadingMC.beginGradientFill("radial",[16777215,16777215,16777215],[55,45,10],[0,170,255],{matrixType:"box",x:-100,y:-100,w:200,h:200,r:0});
   this.drawCircle(mc.shadingMC,0,0,100);
   mc.shadingMC.endFill();
   mc.diskColorObj = new Color(mc.diskMC);
   mc.setColor = function(arg)
   {
      this.diskColorObj.setRGB(arg);
   };
   var mc = this.maskedAreaMC.planetMC;
   mc.createEmptyMovieClip("diskMC",1);
   mc.createEmptyMovieClip("shadingMC",2);
   mc.diskMC.beginFill(10551200,100);
   this.drawCircle(mc.diskMC,0,0,100);
   mc.diskMC.endFill();
   mc.shadingMC.beginGradientFill("radial",[16777215,16777215,16777215],[55,45,10],[0,170,255],{matrixType:"box",x:-100,y:-100,w:200,h:200,r:0});
   this.drawCircle(mc.shadingMC,0,0,100);
   mc.shadingMC.endFill();
   mc.diskColorObj = new Color(mc.diskMC);
   mc.setColor = function(arg)
   {
      this.diskColorObj.setRGB(arg);
   };
   this._c = {};
   this.setSize(this.initSize);
   this.setPlanetColor(this.initPlanetColor);
}
var p = TransitVisualizationClass.prototype = new MovieClip();
Object.registerClass("Transit Visualization",TransitVisualizationClass);
p.setSize = function(size)
{
   this._size = size;
   this._centerX = size / 2;
   this._centerY = size / 2;
   this.maskedAreaMC.starMC._x = this._centerX;
   this.maskedAreaMC.starMC._y = this._centerY;
   var mc = this.maskMC;
   mc.clear();
   mc.moveTo(0,0);
   mc.beginFill(16711680);
   mc.lineTo(size,0);
   mc.lineTo(size,size);
   mc.lineTo(0,size);
   mc.lineTo(0,0);
   mc.endFill();
   var mc = this.borderMC;
   mc.clear();
   mc.moveTo(0,0);
   mc.lineStyle(this.borderThickness,this.borderColor);
   mc.lineTo(size,0);
   mc.lineTo(size,size);
   mc.lineTo(0,size);
   mc.lineTo(0,0);
   var mc = this.backgroundMC;
   mc.clear();
   mc.moveTo(0,0);
   mc.beginFill(this.backgroundColor);
   mc.lineTo(size,0);
   mc.lineTo(size,size);
   mc.lineTo(0,size);
   mc.lineTo(0,0);
   mc.endFill();
   this.updatePositions();
   this.updateOrbitalPath();
};
p.setPhase = function(arg)
{
   this._phase = arg;
   this.updatePositions();
};
p.setParameters = function(params)
{
   if(params.scale != undefined)
   {
      this._scale = params.scale;
   }
   if(params.eccentricity != undefined)
   {
      this._eccentricity = params.eccentricity;
   }
   if(params.separation != undefined)
   {
      this._separation = params.separation;
   }
   if(params.inclination != undefined)
   {
      this._phi = (90 - params.inclination) * 3.141592653589793 / 180;
   }
   if(params.longitude != undefined)
   {
      this._theta = (90 - params.longitude) * 3.141592653589793 / 180;
   }
   if(params.mass1 != undefined)
   {
      this._mass1 = params.mass1;
   }
   if(params.mass2 != undefined)
   {
      this._mass2 = params.mass2;
   }
   if(params.radius1 != undefined)
   {
      this._radius1 = params.radius1;
   }
   if(params.radius2 != undefined)
   {
      this._radius2 = params.radius2;
   }
   if(params.temperature1 != undefined)
   {
      this.setStarTemperature(params.temperature1);
   }
   if(params.minPhase != undefined)
   {
      this._minPhase = params.minPhase;
   }
   if(params.maxPhase != undefined)
   {
      this._maxPhase = params.maxPhase;
   }
   if(params.phase != undefined)
   {
      this._phase = params.phase;
   }
   this._massTotal = this._mass1 + this._mass2;
   this._a1 = this._separation * this._mass2 / this._massTotal;
   this._a2 = this._separation * this._mass1 / this._massTotal;
   this.maskedAreaMC.starMC._xscale = this.maskedAreaMC.starMC._yscale = this._scale * this._radius1;
   this.maskedAreaMC.planetMC._xscale = this.maskedAreaMC.planetMC._yscale = this._scale * this._radius2;
   this.doA();
   this.updateOrbitalPath();
   this.updatePositions();
};
p.updateOrbitalPath = function()
{
   var startTimer = getTimer();
   var sin = Math.sin;
   var cos = Math.cos;
   var abs = Math.abs;
   var a1 = this._a1;
   var a2 = this._a2;
   var e = this._eccentricity;
   var cx = this._centerX;
   var cy = this._centerY;
   var mc = this.maskedAreaMC.orbitMC;
   mc.clear();
   mc.lineStyle(this.orbitPathThickness,this.orbitPathColor,this.orbitPathAlpha);
   var ma = this._minPhase * 2 * 3.141592653589793;
   var ea0 = 0;
   var ea1 = ma;
   var iCount = 0;
   do
   {
      ea0 = ea1;
      ea1 = ea0 + (ma + e * sin(ea0) - ea0) / (1 - e * cos(ea0));
      iCount++;
   }
   while(abs(ea1 - ea0) > 0.001 && iCount < 100);
   var minEA = ea1;
   var ma = this._maxPhase * 2 * 3.141592653589793;
   var ea0 = 0;
   var ea1 = ma;
   var iCount = 0;
   do
   {
      ea0 = ea1;
      ea1 = ea0 + (ma + e * sin(ea0) - ea0) / (1 - e * cos(ea0));
      iCount++;
   }
   while(abs(ea1 - ea0) > 0.001 && iCount < 100);
   var maxEA = ea1;
   var diffEA = maxEA - minEA;
   if(diffEA < 0)
   {
      diffEA += 6.283185307179586;
   }
   var n = 40;
   var step = diffEA / n;
   var B = Math.sqrt(1 - e * e);
   var aAngle = minEA;
   var k0 = this._c.a0;
   var k1 = this._c.a1;
   var k3 = this._c.a3;
   var k4 = this._c.a4;
   var maxD2 = 5 * this._size * this._size;
   var wx = cos(aAngle) - e;
   var wy = B * sin(aAngle);
   var wx1 = (- a1) * wx;
   var wy1 = (- a1) * wy;
   var wx2 = a2 * wx;
   var wy2 = a2 * wy;
   var sx1 = wx1 * k0 + wy1 * k1;
   var sy1 = wx1 * k3 + wy1 * k4;
   var sx2 = wx2 * k0 + wy2 * k1;
   var sy2 = wx2 * k3 + wy2 * k4;
   var sx = cx + sx2 - sx1;
   var sy = cy + sy2 - sy1;
   mc.moveTo(sx,sy);
   var i = 0;
   while(i < n)
   {
      aAngle += step;
      var wx = cos(aAngle) - e;
      var wy = B * sin(aAngle);
      var wx1 = (- a1) * wx;
      var wy1 = (- a1) * wy;
      var wx2 = a2 * wx;
      var wy2 = a2 * wy;
      var sx1 = wx1 * k0 + wy1 * k1;
      var sy1 = wx1 * k3 + wy1 * k4;
      var sx2 = wx2 * k0 + wy2 * k1;
      var sy2 = wx2 * k3 + wy2 * k4;
      var sx = cx + sx2 - sx1;
      var sy = cy + sy2 - sy1;
      if(sx * sx + sy * sy <= maxD2)
      {
         mc.lineTo(sx,sy);
      }
      i++;
   }
   trace("updateOrbitalPath: " + (getTimer() - startTimer));
};
p.updatePositions = function()
{
   var startTimer = getTimer();
   var sin = Math.sin;
   var cos = Math.cos;
   var abs = Math.abs;
   var ma = this._phase * 6.283185307179586;
   var e = this._eccentricity;
   var ea0 = 0;
   var ea1 = ma;
   var iCount = 0;
   do
   {
      ea0 = ea1;
      ea1 = ea0 + (ma + e * sin(ea0) - ea0) / (1 - e * cos(ea0));
      iCount++;
   }
   while(abs(ea1 - ea0) > 0.001 && iCount < 100);
   var ta = 2 * Math.atan(Math.sqrt((1 + e) / (1 - e)) * Math.tan(ea1 / 2));
   var cosTa = cos(ta);
   var sinTa = sin(ta);
   var k = (1 - e * e) / (1 + e * cosTa);
   var r1 = this._a1 * k;
   var r2 = this._a2 * k;
   var wx1 = (- r1) * cosTa;
   var wy1 = (- r1) * sinTa;
   var wx2 = r2 * cosTa;
   var wy2 = r2 * sinTa;
   var c = this._c;
   var sx1 = wx1 * c.a0 + wy1 * c.a1;
   var sy1 = wx1 * c.a3 + wy1 * c.a4;
   var sz1 = wx1 * c.a6 + wy1 * c.a7;
   var sx2 = wx2 * c.a0 + wy2 * c.a1;
   var sy2 = wx2 * c.a3 + wy2 * c.a4;
   var sz2 = wx2 * c.a6 + wy2 * c.a7;
   this.maskedAreaMC.planetMC._x = this._centerX + sx2 - sx1;
   this.maskedAreaMC.planetMC._y = this._centerY + sy2 - sy1;
   if(this.maskedAreaMC.planetMC._yscale < 3)
   {
      this.maskedAreaMC.arrowMC._visible = true;
      this.maskedAreaMC.arrowMC._x = this.maskedAreaMC.planetMC._x;
      this.maskedAreaMC.arrowMC._y = this.maskedAreaMC.planetMC._y + 5 + this.maskedAreaMC.planetMC._yscale;
   }
   else
   {
      this.maskedAreaMC.arrowMC._visible = false;
   }
   trace("updatePositions: " + (getTimer() - startTimer));
};
p.setStarTemperature = function(temp)
{
   this.maskedAreaMC.starMC.setColor(this.getColorFromTemp(temp));
};
p.setPlanetColor = function(pColor)
{
   this.maskedAreaMC.planetMC.setColor(pColor);
};
p.doA = function()
{
   var c = this._c;
   var ct = Math.cos(this._theta);
   var st = Math.sin(this._theta);
   var cp = Math.cos(this._phi);
   var sp = Math.sin(this._phi);
   var s = this._scale;
   c.a0 = (- s) * st;
   c.a1 = s * ct;
   c.a2 = 0;
   c.a3 = s * ct * sp;
   c.a4 = s * st * sp;
   c.a5 = (- s) * cp;
   c.a6 = s * ct * cp;
   c.a7 = s * st * cp;
   c.a8 = s * sp;
};
p.getColorFromTemp = function(temp)
{
   if(temp < 1000)
   {
      temp = 1000;
   }
   else if(temp > 40000)
   {
      temp = 40000;
   }
   var logT = Math.log(temp) / 2.302585092994046;
   var logT2 = logT * logT;
   var logT3 = logT * logT2;
   var r = 22686.34111 - logT * 15082.52755 + logT2 * 3375.333832 - logT3 * 252.4073853;
   if(r < 0)
   {
      r = 0;
   }
   else if(r > 255)
   {
      r = 255;
   }
   if(temp <= 6500)
   {
      var g = -811.6499145 + logT * 36.97365953 + logT2 * 160.7861677 - logT3 * 25.57573664;
   }
   else
   {
      var g = 13836.23586 - logT * 9069.078214 + logT2 * 2015.254756 - logT3 * 149.7766966;
   }
   var b = -11545.34298 + logT * 8529.658165 - logT2 * 2150.198586 + logT3 * 190.0306573;
   if(b < 0)
   {
      b = 0;
   }
   else if(b > 255)
   {
      b = 255;
   }
   return r << 16 | g << 8 | b;
};
p.drawCircle = function(mc, x, y, r)
{
   mc.moveTo(x + r,y);
   mc.curveTo(x + r,y - 0.4142 * r,x + 0.7071 * r,y - 0.7071 * r);
   mc.curveTo(x + 0.4142 * r,y - r,x,y - r);
   mc.curveTo(x - 0.4142 * r,y - r,x - 0.7071 * r,y - 0.7071 * r);
   mc.curveTo(x - r,y - 0.4142 * r,x - r,y);
   mc.curveTo(x - r,y + 0.4142 * r,x - 0.7071 * r,y + 0.7071 * r);
   mc.curveTo(x - 0.4142 * r,y + r,x,y + r);
   mc.curveTo(x + 0.4142 * r,y + r,x + 0.7071 * r,y + 0.7071 * r);
   mc.curveTo(x + r,y + 0.4142 * r,x + r,y);
};
