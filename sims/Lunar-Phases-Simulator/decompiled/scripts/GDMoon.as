function GDMoonClass()
{
   this.stop();
}
var p = GDMoonClass.prototype = new MovieClip();
Object.registerClass("GDMoon",GDMoonClass);
p.useHandCursor = false;
p.onRollOver = function()
{
   this.gotoAndStop(2);
};
p.onRollOut = function()
{
   this.gotoAndStop(1);
};
p.onPress = function()
{
   this._offset = this.rawMoonAngle - Math.atan2(this._parent._ymouse,this._parent._xmouse);
   this.onMouseMove = this.onMouseMoveFunc;
   this._root.stopAnimation();
};
p.onRelease = function()
{
   this.onMouseMove = undefined;
   this._root.changeAnimate();
};
p.onReleaseOutside = function()
{
   this.onMouseMove = undefined;
   this.gotoAndStop(1);
   this._root.changeAnimate();
};
p.onMouseMoveFunc = function()
{
   this.rawMoonAngle = Math.atan2(this._parent._ymouse,this._parent._xmouse) + this._offset;
   this._parent.onPhaseChanged();
   updateAfterEvent();
};
p.getRawMoonAngle = function(arg)
{
   return this._rotation * 0.017453292519943295;
};
p.setRawMoonAngle = function(arg)
{
   this._parent._moonShadow._x = this._x = this._parent._orbitRadius * Math.cos(arg);
   this._parent._moonShadow._y = this._y = this._parent._orbitRadius * Math.sin(arg);
   this._rotation = 57.29577951308232 * arg;
};
p.addProperty("rawMoonAngle",p.getRawMoonAngle,p.setRawMoonAngle);
