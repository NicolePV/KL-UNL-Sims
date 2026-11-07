function HRDiagramDotClassRev1()
{
   this.createEmptyMovieClip("discMC",1);
   this.update();
}
var p = HRDiagramDotClassRev1.prototype = new MovieClip();
Object.registerClass("HR Diagram Dot",HRDiagramDotClassRev1);
p.dotColor = 1924851;
p.dotAlpha = 100;
p.dotSize = 2;
p.outlineThickness = 0;
p.outlineColor = 6316128;
p.outlineAlpha = 0;
p.setSize = function(arg)
{
   this.dotSize = arg;
   this.update();
};
p.setColor = function(arg)
{
   this.dotColor = arg;
   this.update();
};
p.update = function()
{
   this.discMC.clear();
   this.discMC.lineStyle(this.outlineThickness,this.outlineColor,this.outlineAlpha);
   this.discMC.beginFill(this.dotColor,this.dotAlpha);
   this.drawCircle(this.discMC,0,0,this.dotSize / 2);
   this.discMC.endFill();
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
