function MoonDecPlotClass()
{
   this.createEmptyMovieClip("bandMC",1);
   this.createEmptyMovieClip("curveMC",2);
   this.init();
}
var p = MoonDecPlotClass.prototype = new MovieClip();
Object.registerClass("Moon Dec Plot",MoonDecPlotClass);
p.width = 400;
p.height = 275;
p.maxDec = 40;
p.init = function()
{
   var mc = this.curveMC;
   var bmc = this.bandMC;
   var w = this.width;
   var h = this.height;
   var n = w;
   var maxDec = this.maxDec;
   var yScale = (- h / 2) / maxDec;
   var xScale = w / 365;
   var doyStep = 365 / n;
   var doy = 0;
   var sunLongitude = (doy - 78.5) / 365 * 2 * 3.141592653589793;
   var sunDeclination = Math.asin(0.39714789063478056 * Math.sin(sunLongitude));
   var moonDec = -57.29577951308232 * sunDeclination;
   var dy = 7 * yScale;
   mc.clear();
   mc.lineStyle(0,10502208);
   mc.moveTo(0,moonDec * yScale);
   var bsy = moonDec * yScale + dy;
   var pL = [moonDec * yScale - dy];
   bmc.clear();
   bmc.moveTo(0,moonDec * yScale + dy);
   bmc.beginFill(13664384,30);
   var i = 0;
   while(i < n)
   {
      doy += doyStep;
      var sunLongitude = (doy - 78.5) / 365 * 2 * 3.141592653589793;
      var sunDeclination = Math.asin(0.39714789063478056 * Math.sin(sunLongitude));
      var moonDec = -57.29577951308232 * sunDeclination;
      var x = doy * xScale;
      var y = moonDec * yScale;
      mc.lineTo(x,y);
      bmc.lineTo(x,y + dy);
      pL.push(y - dy);
      i++;
   }
   var x = w;
   var xStep = w / n;
   var i = n;
   while(i >= 0)
   {
      bmc.lineTo(x,pL[i]);
      x -= xStep;
      i--;
   }
   bmc.lineTo(0,bsy);
   bmc.endFill();
};
