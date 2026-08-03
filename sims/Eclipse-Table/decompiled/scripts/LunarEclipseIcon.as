function LunarEclipseIconClass()
{
   this.highlight._visible = false;
   this.gotoAndStop(1 + this._parent.lunarEclipses[this.id][2]);
   this._x = this._parent.lunarEclipses[this.id][0];
   this._y = this._parent.lunarEclipses[this.id][1];
}
var p = LunarEclipseIconClass.prototype = new MovieClip();
Object.registerClass("LunarEclipseIcon",LunarEclipseIconClass);
p.useHandCursor = false;
p.onRollOver = function()
{
   this.highlight._visible = true;
   this._parent.displayLunarEclipseInfo(this.id,this._x,this._y);
};
p.onRollOut = p.onReleaseOutside = function()
{
   this.highlight._visible = false;
   this._parent.hideLunarEclipseInfo();
};
