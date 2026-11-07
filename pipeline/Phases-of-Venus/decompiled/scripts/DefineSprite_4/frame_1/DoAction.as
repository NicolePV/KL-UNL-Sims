this.stop();
this.useHandCursor = false;
this.onRollOver = function()
{
   this.gotoAndStop(2);
};
this.onRollOut = function()
{
   this.gotoAndStop(1);
};
this.onPress = function()
{
   this._parent.pause();
   this.offsetAngle = Math.atan2(this._parent._ymouse,this._parent._xmouse) - Math.atan2(this._y,this._x);
   this.onMouseMove = this.onMouseMoveFunc;
};
this.onMouseMoveFunc = function()
{
   this._parent.setEarthAngle(Math.atan2(this._parent._ymouse,this._parent._xmouse) - this.offsetAngle);
   updateAfterEvent();
};
this.onRelease = function()
{
   this._parent.resume();
   delete this.onMouseMove;
};
this.onReleaseOutside = function()
{
   this._parent.resume();
   this.gotoAndStop(1);
   delete this.onMouseMove;
};
