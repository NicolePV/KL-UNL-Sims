function DraggableAreaClass()
{
   this.minXOffset = parseFloat(this.initMinXOffset);
   this.maxXOffset = parseFloat(this.initMaxXOffset);
   this.minYOffset = parseFloat(this.initMinYOffset);
   this.maxYOffset = parseFloat(this.initMaxYOffset);
   var _loc3_ = this.createEmptyMovieClip("mouseAreaMC",1);
   _loc3_.moveTo(0,0);
   _loc3_.beginFill(16711680,0);
   _loc3_.lineTo(this.width,0);
   _loc3_.lineTo(this.width,this.height);
   _loc3_.lineTo(0,this.height);
   _loc3_.lineTo(0,0);
   _loc3_.endFill();
   _loc3_.useHandCursor = false;
   _loc3_.tabEnabled = false;
   _loc3_.handsMC = _root.createEmptyMovieClip("grabberCursorsMC",1039999);
   _loc3_.openedHandMC = _root.grabberCursorsMC.attachMovie("DA Opened Hand","openedHandMC",1);
   _loc3_.closedHandMC = _root.grabberCursorsMC.attachMovie("DA Closed Hand","closedHandMC",2);
   _loc3_.openedHandMC._visible = false;
   _loc3_.closedHandMC._visible = false;
   _loc3_.noDragOnMouseMoveFunc = this.noDragOnMouseMoveFunc;
   _loc3_.dragOnMouseMoveFunc = this.dragOnMouseMoveFunc;
   this.setEnabled(this.initEnabled);
}
var p = DraggableAreaClass.prototype = new MovieClip();
Object.registerClass("Draggable Area",DraggableAreaClass);
p.setEnabled = function(arg)
{
   if(arg)
   {
      this.mouseAreaMC.onRollOver = this.onRollOverFunc;
      this.mouseAreaMC.onRollOut = this.onRollOutFunc;
      this.mouseAreaMC.onPress = this.onPressFunc;
      this.mouseAreaMC.onRelease = this.onReleaseFunc;
      this.mouseAreaMC.onReleaseOutside = this.onReleaseOutsideFunc;
   }
   else
   {
      delete this.mouseAreaMC.onRollOver;
      delete this.mouseAreaMC.onRollOut;
      delete this.mouseAreaMC.onPress;
      delete this.mouseAreaMC.onRelease;
      delete this.mouseAreaMC.onReleaseOutside;
      delete this.mouseAreaMC.onMouseMove;
   }
};
p.onRollOverFunc = function()
{
   Mouse.hide();
   this.handsMC._x = _root._xmouse;
   this.handsMC._y = _root._ymouse;
   this.openedHandMC._visible = true;
   this.closedHandMC._visible = false;
   this.onMouseMove = this.noDragOnMouseMoveFunc;
};
p.onPressFunc = function()
{
   this.openedHandMC._visible = false;
   this.closedHandMC._visible = true;
   this.initX = _root._xmouse;
   this.initXOffset = this._parent.xOffset;
   this.initY = _root._ymouse;
   this.initYOffset = this._parent.yOffset;
   this.onMouseMove = this.dragOnMouseMoveFunc;
};
p.onReleaseFunc = function()
{
   this.openedHandMC._visible = true;
   this.closedHandMC._visible = false;
   this.onMouseMove = this.noDragOnMouseMoveFunc;
};
p.onReleaseOutsideFunc = function()
{
   Mouse.show();
   this.openedHandMC._visible = false;
   this.closedHandMC._visible = false;
   delete this.onMouseMove;
};
p.onRollOutFunc = function()
{
   Mouse.show();
   this.openedHandMC._visible = false;
   this.closedHandMC._visible = false;
   delete this.onMouseMove;
};
p.noDragOnMouseMoveFunc = function()
{
   this.handsMC._x = _root._xmouse;
   this.handsMC._y = _root._ymouse;
   updateAfterEvent();
};
p.dragOnMouseMoveFunc = function()
{
   this.handsMC._x = _root._xmouse;
   this.handsMC._y = _root._ymouse;
   var _loc3_ = this.initYOffset + this._parent.yScaleFactor * (_root._ymouse - this.initY);
   if(!isNaN(this._parent.minYOffset) && _loc3_ < this._parent.minYOffset)
   {
      _loc3_ = this._parent.minYOffset;
   }
   if(!isNaN(this._parent.maxYOffset) && _loc3_ > this._parent.maxYOffset)
   {
      _loc3_ = this._parent.maxYOffset;
   }
   this._parent.yOffset = _loc3_;
   var _loc4_ = this.initXOffset + this._parent.xScaleFactor * (_root._xmouse - this.initX);
   if(!isNaN(this._parent.minXOffset) && _loc4_ < this._parent.minXOffset)
   {
      _loc4_ = this._parent.minXOffset;
   }
   if(!isNaN(this._parent.maxXOffset) && _loc4_ > this._parent.maxXOffset)
   {
      _loc4_ = this._parent.maxXOffset;
   }
   this._parent.xOffset = _loc4_;
   this._parent._parent[this._parent.onDragHandler](this._parent.xOffset,this._parent.yOffset);
   updateAfterEvent();
};
