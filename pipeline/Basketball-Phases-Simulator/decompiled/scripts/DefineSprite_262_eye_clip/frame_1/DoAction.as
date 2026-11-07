this.the_eye.onPress = function()
{
   this._parent.active = true;
};
this.the_eye.onRelease = function()
{
   this._parent.active = false;
};
this.the_eye.onReleaseOutside = function()
{
   this._parent.active = false;
};
this.the_eye.onMouseMove = function()
{
   if(this._parent.active)
   {
      var mouseX = this._parent._xmouse;
      var mouseY = this._parent._ymouse;
      var newAngle = this._parent.degrees(Math.atan2(mouseY,mouseX));
      var newX = 250 * Math.cos(this._parent.radians(newAngle));
      var newY = 250 * Math.sin(this._parent.radians(newAngle));
      this._parent.the_eye._x = newX;
      this._parent.the_eye._y = newY;
      this._parent.angle = 180 + newAngle;
      this._parent._time = this._parent.angle;
   }
};
