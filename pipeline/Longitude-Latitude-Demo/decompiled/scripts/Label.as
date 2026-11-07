function LabelClass()
{
   this._color = new Color(this);
   this.setColor(this.labelColor);
}
var p = LabelClass.prototype = new MovieClip();
Object.registerClass("Label",LabelClass);
p.setColor = function(arg)
{
   this._color.setRGB(arg);
};
