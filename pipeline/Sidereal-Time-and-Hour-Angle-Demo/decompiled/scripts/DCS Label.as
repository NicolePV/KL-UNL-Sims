function DCSLabelClass()
{
   this._color = new Color(this);
   this.setColor(this.labelColor);
}
var p = DCSLabelClass.prototype = new MovieClip();
Object.registerClass("DCS Label",DCSLabelClass);
p.setColor = function(arg)
{
   this._color.setRGB(arg);
};
p.setLabelText = function(arg)
{
   this._labelString = arg;
};
p.getLabelText = function()
{
   return this._labelString;
};
p.addProperty("labelText",p.getLabelText,p.setLabelText);
