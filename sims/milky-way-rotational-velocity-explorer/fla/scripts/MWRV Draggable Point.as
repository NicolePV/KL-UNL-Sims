function MWRVDraggablePointClass()
{
   this.stop();
}
var p = MWRVDraggablePointClass.prototype = new MovieClip();
Object.registerClass("MWRV Draggable Point",MWRVDraggablePointClass);
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
   var _loc1_ = this;
   _loc1_.xOffset = _loc1_._parent._xmouse - _loc1_._x;
   _loc1_.yOffset = _loc1_._parent._ymouse - _loc1_._y;
   _loc1_.onMouseMove = _loc1_.onMouseMoveFunc;
};
p.onRelease = function()
{
   delete this.onMouseMove;
};
p.onReleaseOutside = function()
{
   this.gotoAndStop(1);
   delete this.onMouseMove;
};
p.onMouseMoveFunc = function()
{
   var _loc1_ = this;
   _loc1_._x = _loc1_._parent._xmouse - _loc1_.xOffset;
   _loc1_._y = _loc1_._parent._ymouse - _loc1_.yOffset;
   _loc1_._parent.snapPointToCurve();
   updateAfterEvent();
};
