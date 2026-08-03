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
   var _loc1_ = {};
   this._sphere.getMouseRaDec(_loc1_);
   if(_loc1_.ra != null)
   {
      this._sphere._parent.setStarLocation(_loc1_);
   }
   updateAfterEvent();
};
