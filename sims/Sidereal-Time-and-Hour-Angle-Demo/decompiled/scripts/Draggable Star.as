function DraggableStarClass()
{
   this.stop();
}
var p = DraggableStarClass.prototype = new MovieClip();
Object.registerClass("Draggable Star",DraggableStarClass);
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
   this.gotoAndStop(1);
   delete this.onMouseMove;
   delete this._sphere._mouseArea.onMouseMove;
};
p.onRelease = function()
{
   delete this.onMouseMove;
   delete this._sphere._mouseArea.onMouseMove;
};
p.onPress = function()
{
   if(this._object._sp.z > 0)
   {
      this.onMouseMove = this.onMouseMoveFunc;
   }
   else
   {
      this._sphere._mouseArea.onPress();
   }
};
p.onMouseMoveFunc = function()
{
   var _loc2_ = {};
   this._sphere.getMouseRaDec(_loc2_);
   if(_loc2_.ra != null)
   {
      this._sphere._parent.setStarLocation(_loc2_);
   }
   updateAfterEvent();
};
