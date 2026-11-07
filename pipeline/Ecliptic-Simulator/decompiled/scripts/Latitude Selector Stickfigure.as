function LatitudeSelectorStickfigureClass()
{
   this.stop();
}
var p = LatitudeSelectorStickfigureClass.prototype = new MovieClip();
Object.registerClass("Latitude Selector Stickfigure",LatitudeSelectorStickfigureClass);
p.useHandCursor = false;
p.onRollOver = function()
{
   if(this._parent._parent.observerLatitude >= 90)
   {
      this.gotoAndStop(4);
   }
   else if(this._parent._parent.observerLatitude <= -90)
   {
      this.gotoAndStop(3);
   }
   else
   {
      this.gotoAndStop(2);
   }
};
p.onRollOut = function()
{
   this.gotoAndStop(1);
};
p.onPress = function()
{
   this.angleOffset = Math.atan2(this._parent._ymouse,this._parent._xmouse) - Math.atan2(this._y,this._x);
   this.onMouseMove = this.onMouseMoveFunc;
};
p.onMouseMoveFunc = function()
{
   var _loc2_ = -57.29577951308232 * (Math.atan2(this._parent._ymouse,this._parent._xmouse) - this.angleOffset);
   if(_loc2_ >= 90)
   {
      _loc2_ = 90;
      this.gotoAndStop(4);
   }
   else if(_loc2_ <= -90)
   {
      _loc2_ = -90;
      this.gotoAndStop(3);
   }
   else
   {
      this.gotoAndStop(2);
   }
   this._parent._parent[this._parent.changeHandler](_loc2_);
   updateAfterEvent();
};
p.onRelease = function()
{
   delete this.onMouseMove;
};
p.onReleaseOutside = function()
{
   delete this.onMouseMove;
   this.gotoAndStop(1);
};
