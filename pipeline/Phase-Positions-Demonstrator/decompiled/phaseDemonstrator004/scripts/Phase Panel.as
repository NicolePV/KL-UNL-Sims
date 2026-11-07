function PhasePanelClass()
{
   this.createEmptyMovieClip("phaseMC",1);
   this.buttonStyle = new FStyleFormat();
   this.buttonStyle.face = 5263440;
   this.buttonStyle.textColor = 15790320;
   this.buttonStyle.textBold = true;
   this.buttonStyle.embedFonts = true;
   this.buttonStyle.textSize = 10;
}
var p = PhasePanelClass.prototype = new MovieClip();
Object.registerClass("Phase Panel",PhasePanelClass);
p.discRadius = 70;
p.darkColor = 4210752;
p.lightColor = 14737632;
p.init = function()
{
   this.buttonStyle.addListener(this.showHideButton);
};
p.toggleVisibility = function()
{
   this.phaseMC._visible = !this.phaseMC._visible;
   if(this.phaseMC._visible)
   {
      this.showHideButton.setLabel("hide");
   }
   else
   {
      this.showHideButton.setLabel("show");
   }
};
p.setPhaseAngle = function(angle)
{
   var sin = Math.sin;
   var cos = Math.cos;
   angle = (angle % 6.283185307179586 + 6.283185307179586) % 6.283185307179586;
   if(angle < 3.141592653589793)
   {
      var f = -1;
   }
   else
   {
      var f = 1;
   }
   var n = 4;
   var r = this.discRadius;
   var s = r * cos(angle);
   var step = 3.141592653589793 / n;
   var halfStep = step / 2;
   var kr = r / cos(halfStep);
   var ks = s / cos(halfStep);
   var mc = this.phaseMC;
   mc.clear();
   mc.lineStyle(1,16711680,0);
   mc.moveTo(0,- r);
   mc.beginFill(this.darkColor,100);
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
   mc.beginFill(this.lightColor,100);
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
