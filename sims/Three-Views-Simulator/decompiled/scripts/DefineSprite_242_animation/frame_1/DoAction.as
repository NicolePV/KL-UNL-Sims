function changeSpeed()
{
   this._speed = this.speedSlider.value;
}
spaceArrow.onPress = function()
{
   this._parent.active = true;
};
spaceArrow.onRelease = function()
{
   this._parent.active = false;
};
spaceArrow.onReleaseOutside = function()
{
   this._parent.active = false;
};
spaceArrow.onMouseMove = function()
{
   if(this._parent.active)
   {
      this._parent._spaceX = this._parent._xmouse;
      this._parent._spaceY = this._parent._ymouse;
      if(this._parent._spaceX < -280)
      {
         this._parent._spaceX = -280;
      }
      else if(this._parent._spaceX > 280)
      {
         this._parent._spaceX = 280;
      }
      if(this._parent._spaceY < -280)
      {
         this._parent._spaceY = -280;
      }
      else if(this._parent._spaceY > 280)
      {
         this._parent._spaceY = 280;
      }
      this._parent.spaceArrow._x = this._parent._spaceX;
      this._parent.spaceArrow._y = this._parent._spaceY;
   }
};
