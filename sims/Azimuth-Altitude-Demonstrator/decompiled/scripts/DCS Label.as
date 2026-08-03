function DCSLabelClass()
{
   var _loc1_ = this;
   _loc1_._color = new Color(_loc1_);
   _loc1_.setColor(_loc1_.labelColor);
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
