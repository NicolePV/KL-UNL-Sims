function arrowClass()
{
   this._Color = new Color(this.myArrow);
   this._Color.setRGB(this._myColor);
}
var p = arrowClass.prototype = new MovieClip();
Object.registerClass("arrow",arrowClass);
p.onEnterFrame = function()
{
   this._Color = this._myColor;
};
