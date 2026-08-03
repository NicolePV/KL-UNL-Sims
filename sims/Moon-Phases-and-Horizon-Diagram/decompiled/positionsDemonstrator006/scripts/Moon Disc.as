function MoonDiscClass()
{
   this.setShowPhase(false);
}
var p = MoonDiscClass.prototype = new MovieClip();
Object.registerClass("Moon Disc",MoonDiscClass);
p.radius = 12;
p.darkColor = 9474192;
p.lightColor = 13684944;
p.lineColor = 8421504;
p.solidColor = 11053224;
p.setShowPhase = function(arg)
{
   this._showPhase = arg;
   if(!this._showPhase)
   {
      this.drawPhaseDisc(180,{radius:this.radius,lightColor:this.solidColor,darkColor:this.solidColor,lineThickness:0,lineAlpha:100,lineColor:this.lineColor});
   }
   else
   {
      this.update();
   }
};
p.update = function()
{
   if(this._showPhase)
   {
      var phaseAngle = 15 * (this._sphere.sun.ra - this._sphere.moon.ra) + 180;
      this.drawPhaseDisc(phaseAngle,{radius:this.radius,lightColor:this.lightColor,darkColor:this.darkColor,lineThickness:0,lineAlpha:100,lineColor:this.lineColor});
   }
};
