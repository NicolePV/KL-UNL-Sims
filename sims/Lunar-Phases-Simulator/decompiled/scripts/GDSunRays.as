function GDSunRaysClass()
{
   this.setDraggable(false);
}
var p = GDSunRaysClass.prototype = new MovieClip();
Object.registerClass("GDSunRays",GDSunRaysClass);
p.setDraggable = function(arg)
{
   if(arg)
   {
      this.onPress = this.onPressFunc;
   }
   else
   {
      this.onPress = undefined;
   }
};
p.useHandCursor = false;
p.onPressFunc = function()
{
   this._offset = 57.29577951308232 * Math.atan2(this._parent._ymouse,this._parent._xmouse) - 180 - this._rotation;
   this._parent._startTime = this._parent.time;
   this._parent._startPhase = this._parent.phase;
   this.onMouseMove = this.onMouseMoveFunc;
};
p.onMouseMoveFunc = function()
{
   this._rotation = 57.29577951308232 * Math.atan2(this._parent._ymouse,this._parent._xmouse) - 180 - this._offset;
   this._parent.onSunAngleChanged();
   updateAfterEvent();
};
p.onRelease = p.onReleaseOutside = function()
{
   this.onMouseMove = undefined;
};
