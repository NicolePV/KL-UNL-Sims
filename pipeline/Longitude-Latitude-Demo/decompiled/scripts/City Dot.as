function CityDotClass()
{
   this.gotoAndStop(1);
}
var p = CityDotClass.prototype = new MovieClip();
Object.registerClass("City Dot",CityDotClass);
p.showLabel = function()
{
   this.gotoAndStop(2);
   this._sphere._parent.cityLabel.currentCityDot = this;
   this._sphere._parent.cityLabel._visible = true;
   this._sphere._parent.cityLabel._x = this._object._sp.x;
   this._sphere._parent.cityLabel._y = this._object._sp.y;
   this._sphere._parent.cityLabel.setLabelText(this.cityName);
};
p.hideLabel = function()
{
   this.gotoAndStop(1);
   this._sphere._parent.cityLabel._visible = false;
};
p.useHandCursor = false;
p.onPress = function()
{
   this._sphere.shores.instance.onPressFunc();
};
p.onRollOver = p.showLabel;
p.onRollOut = p.onReleaseOutside = p.hideLabel;
