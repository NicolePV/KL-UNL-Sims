function DefaultXTickmarkLabelClass()
{
   var _loc1_ = this;
   _loc1_.colorObj = new Color(_loc1_);
   _loc1_.colorObj.setRGB(_loc1_.labelColor);
}
var p = DefaultXTickmarkLabelClass.prototype = new MovieClip();
Object.registerClass("Default X Tickmark Label",DefaultXTickmarkLabelClass);
p.setLabelColor = function(arg)
{
   this.colorObj.setRGB(arg);
};
