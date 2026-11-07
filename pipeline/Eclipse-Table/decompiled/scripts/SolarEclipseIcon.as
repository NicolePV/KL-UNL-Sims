function SolarEclipseIconClass()
{
   this.highlight._visible = false;
   this.gotoAndStop(1 + this._parent.solarEclipses[this.id][2]);
   this._x = this._parent.solarEclipses[this.id][0];
   this._y = this._parent.solarEclipses[this.id][1];
}
var p = SolarEclipseIconClass.prototype = new MovieClip();
Object.registerClass("SolarEclipseIcon",SolarEclipseIconClass);
p.useHandCursor = false;
p.onRollOver = function()
{
   this.highlight._visible = true;
   this._parent.displaySolarEclipseInfo(this.id,this._x,this._y);
};
p.onRollOut = p.onReleaseOutside = function()
{
   this.highlight._visible = false;
   this._parent.hideSolarEclipseInfo();
};
