function onPressFunc()
{
   this.yOffset = this._parent._ymouse - this._y;
   this.xOffset = this._parent._xmouse - this._x;
   this.onMouseMove = this.onMouseMoveFunc;
}
function onMouseMoveFuncFunc()
{
   var newX = this._parent._xmouse - this.xOffset;
   var newY = this._parent._ymouse - this.yOffset;
   var xs = newX - this._parent.sunMC._x;
   var ys = newY - this._parent.sunMC._y;
   var ds = Math.sqrt(xs * xs + ys * ys);
   var margin = 20;
   if(ds < (this._parent.sunMC._width + this._width) / 2 + margin)
   {
      var as = Math.atan2(ys,xs);
      var ds = (this._parent.sunMC._width + this._width) / 2 + margin;
      xs = ds * Math.cos(as);
      ys = ds * Math.sin(as);
      newX = xs + this._parent.sunMC._x;
      newY = ys + this._parent.sunMC._y;
   }
   if(newX < 0)
   {
      newX = 0;
      var delta = Math.sqrt(Math.pow((this._parent.sunMC._width + this._width) / 2 + margin,2) - Math.pow(this._parent.sunMC._x,2));
      if(newY < this._parent.sunMC._y && newY > this._parent.sunMC._y - delta)
      {
         newY = this._parent.sunMC._y - delta;
      }
      else if(newY >= this._parent.sunMC._y && newY < this._parent.sunMC._y + delta)
      {
         newY = this._parent.sunMC._y + delta;
      }
   }
   else if(newX > 900)
   {
      newX = 900;
   }
   if(newY < 0)
   {
      newY = 0;
   }
   else if(newY > 500)
   {
      newY = 500;
   }
   this._x = newX;
   this._y = newY;
   this.thisShadow.setIlluminantPosition(newX,newY);
   updateAfterEvent();
}
function onReleaseFunc()
{
   delete this.onMouseMove;
}
earthMC.useHandCursor = false;
earthMC.onPress = onPressFunc;
earthMC.onMouseMoveFunc = onMouseMoveFuncFunc;
earthMC.onRelease = onReleaseFunc;
earthMC.onReleaseOutside = onReleaseFunc;
moonMC.useHandCursor = false;
moonMC.onPress = onPressFunc;
moonMC.onMouseMoveFunc = onMouseMoveFuncFunc;
moonMC.onRelease = onReleaseFunc;
moonMC.onReleaseOutside = onReleaseFunc;
earthShadow.objectRadius = earthMC._width / 2;
earthShadow.illuminantRadius = sunMC._width / 2;
moonShadow.objectRadius = moonMC._width / 2;
moonShadow.illuminantRadius = sunMC._width / 2;
earthMC.thisShadow = earthShadow;
moonMC.thisShadow = moonShadow;
earthShadow.setIlluminantPosition(earthMC._x,earthMC._y);
moonShadow.setIlluminantPosition(moonMC._x,moonMC._y);
