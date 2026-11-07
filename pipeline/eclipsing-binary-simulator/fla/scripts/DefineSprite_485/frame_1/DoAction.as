function changeShowMainSequence()
{
   hrDiagramMC.showMainSequenceOverlay = showMainSequenceCheck.getValue();
}
dragBarMC.useHandCursor = false;
closeBoxMC.useHandCursor = false;
backgroundMC.useHandCursor = false;
margin = 5;
lowerXLimit = -425 + margin;
lowerYLimit = -350 + margin;
upperXLimit = 392 - margin - this._width;
upperYLimit = 330 - margin - this._height;
dragBarMC.onPress = function()
{
   this.xOffset = this._parent._parent._xmouse - this._parent._x;
   this.yOffset = this._parent._parent._ymouse - this._parent._y;
   this.onMouseMove = this.onMouseMoveFunc;
};
dragBarMC.onMouseMoveFunc = function()
{
   var newX = this._parent._parent._xmouse - this.xOffset;
   var newY = this._parent._parent._ymouse - this.yOffset;
   if(newX < lowerXLimit)
   {
      newX = lowerXLimit;
   }
   else if(newX > upperXLimit)
   {
      newX = upperXLimit;
   }
   if(newY < lowerYLimit)
   {
      newY = lowerYLimit;
   }
   else if(newY > upperYLimit)
   {
      newY = upperYLimit;
   }
   this._parent._x = newX;
   this._parent._y = newY;
   updateAfterEvent();
};
dragBarMC.onRelease = dragBarMC.onReleaseOutside = function()
{
   delete this.onMouseMove;
};
closeBoxMC.onPress = function()
{
   this._parent._visible = false;
};
backgroundMC.onPress = function()
{
};
