function AzAltDraggableStarClass()
{
   this.stop();
}
var p = AzAltDraggableStarClass.prototype = new MovieClip();
Object.registerClass("AzAlt Draggable Star",AzAltDraggableStarClass);
p.useHandCursor = false;
p.onRollOver = function()
{
   if(this._object._sp.z > 0)
   {
      this.gotoAndStop(2);
   }
};
p.onRollOut = function()
{
   this.gotoAndStop(1);
};
p.onReleaseOutside = function()
{
   var _loc1_ = this;
   _loc1_.gotoAndStop(1);
   delete _loc1_.onMouseMove;
   delete _loc1_._sphere._mouseArea.onMouseMove;
};
p.onRelease = function()
{
   delete this.onMouseMove;
   delete this._sphere._mouseArea.onMouseMove;
};
p.onPress = function()
{
   var _loc1_ = this;
   if(_loc1_._object._sp.z > 0)
   {
      _loc1_.onMouseMove = _loc1_.onMouseMoveFunc;
   }
   else
   {
      _loc1_._sphere._mouseArea.onPress();
   }
};
p.onMouseMoveFunc = function()
{
   var _loc2_ = this;
   var _loc1_ = {};
   _loc2_._sphere.StoMH({x:_loc2_._sphere._xmouse,y:_loc2_._sphere._ymouse},_loc1_);
   _loc2_._sphere._parent.setStarLocation({az:(- _loc1_.az) * 180 / 3.141592653589793,alt:_loc1_.alt * 180 / 3.141592653589793});
   updateAfterEvent();
};
