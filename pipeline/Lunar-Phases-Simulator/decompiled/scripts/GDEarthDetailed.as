function GDEarthDetailedClass()
{
   this.stop();
}
var p = GDEarthDetailedClass.prototype = new MovieClip();
Object.registerClass("GDEarthDetailed",GDEarthDetailedClass);
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
   this._offset = 57.29577951308232 * Math.atan2(this._parent._ymouse,this._parent._xmouse) - this._rotation;
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
   this._rotation = 57.29577951308232 * Math.atan2(this._parent._ymouse,this._parent._xmouse) - this._offset;
   this._parent.onTimeChanged();
   updateAfterEvent();
};
p.mod = function(n, m)
{
   if(n < 0)
   {
      return n % m + m;
   }
   return n % m;
};
