function HRDiagramDiscClassRev1()
{
   this.labelField.autoSize = "center";
   this.update();
}
var p = HRDiagramDiscClassRev1.prototype = new MovieClip();
Object.registerClass("HR Diagram Disc",HRDiagramDiscClassRev1);
p.labelText = "";
p.labelColor = 16777215;
p.discColor = 16711680;
p.discAlpha = 100;
p.discRadius = 8;
p.outlineThickness = 0;
p.outlineColor = 9474192;
p.outlineAlpha = 0;
p.setDiscColor = function(arg)
{
   this.discColor = arg;
   this.updateDisc();
};
p.setLabelText = function(arg)
{
   this.labelText = arg;
   this.updateLabel();
};
p.setLabelColor = function(arg)
{
   this.labelColor = arg;
   this.updateLabel();
};
p.update = function()
{
   this.updateDisc();
   this.updateLabel();
};
p.updateDisc = function()
{
   this.clear();
   this.lineStyle(this.outlineThickness,this.outlineColor,this.outlineAlpha);
   this.beginFill(this.discColor,this.discAlpha);
   this.drawCircle(this,0,0,this.discRadius);
   this.endFill();
};
p.updateLabel = function()
{
   this.labelField.text = this.labelText;
   this.labelField.textColor = this.labelColor;
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
