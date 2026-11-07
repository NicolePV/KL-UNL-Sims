function PanelBarClass()
{
}
var p = PanelBarClass.prototype = new MovieClip();
Object.registerClass("Panel Bar",PanelBarClass);
p.useHandCursor = false;
p.onPress = function()
{
   this.xOffset = this._parent._x - this._parent._parent._xmouse;
   this.yOffset = this._parent._y - this._parent._parent._ymouse;
   this._parent.swapDepths(this._parent._parent.topDepth++);
   this.onMouseMove = this.onMouseMoveFunc;
};
p.onMouseMoveFunc = function()
{
   var _loc3_;
   var _loc2_;
   if(this._parent.isDraggable)
   {
      _loc3_ = this._parent._parent._xmouse + this.xOffset;
      _loc2_ = this._parent._parent._ymouse + this.yOffset;
      if(_loc3_ < this._parent.xMin)
      {
         _loc3_ = this._parent.xMin;
      }
      else if(_loc3_ > this._parent.xMax)
      {
         _loc3_ = this._parent.xMax;
      }
      if(_loc2_ < this._parent.yMin)
      {
         _loc2_ = this._parent.yMin;
      }
      else if(_loc2_ > this._parent.yMax)
      {
         _loc2_ = this._parent.yMax;
      }
      this._parent._x = _loc3_;
      this._parent._y = _loc2_;
      trace(this._parent.titleMC.titleString + ", _x: " + _loc3_ + ", _y: " + _loc2_);
      updateAfterEvent();
   }
};
p.onRelease = p.onReleaseOutside = function()
{
   delete this.onMouseMove;
};
