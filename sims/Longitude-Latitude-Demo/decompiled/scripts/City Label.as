function CityLabelClass()
{
   this.labelField.autoSize = "left";
}
var p = CityLabelClass.prototype = new MovieClip();
Object.registerClass("City Label",CityLabelClass);
p.setLabelText = function(arg)
{
   this.labelField.text = arg;
   var y1 = -36;
   var y2 = -57;
   var x1 = 25;
   var x2 = this.labelField._x + this.labelField.textWidth + 8;
   var mc = this;
   mc.clear();
   mc.lineStyle(1,0,100);
   mc.moveTo(5,-5);
   mc.lineTo(x1,y1);
   mc.moveTo(x1,y1);
   mc.beginFill(16777215,100);
   mc.lineTo(x1,y2);
   mc.lineTo(x2,y2);
   mc.lineTo(x2,y1);
   mc.lineTo(x1,y1);
   mc.endFill();
};
