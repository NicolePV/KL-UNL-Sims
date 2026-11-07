function DefaultXTickmarkLabelClass()
{
   this.colorObj = new Color(this);
   this.colorObj.setRGB(this.labelColor);
}
var p = DefaultXTickmarkLabelClass.prototype = new MovieClip();
Object.registerClass("Default X Tickmark Label",DefaultXTickmarkLabelClass);
p.setLabelColor = function(arg)
{
   this.colorObj.setRGB(arg);
};
