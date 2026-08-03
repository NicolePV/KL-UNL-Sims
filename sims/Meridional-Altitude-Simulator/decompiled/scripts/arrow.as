function arrowClass()
{
   var _loc1_ = this;
   _loc1_._Color = new Color(_loc1_.myArrow);
   _loc1_._Color.setRGB(_loc1_._myColor);
}
var p = arrowClass.prototype = new MovieClip();
Object.registerClass("arrow",arrowClass);
p.onEnterFrame = function()
{
   this._Color = this._myColor;
};
