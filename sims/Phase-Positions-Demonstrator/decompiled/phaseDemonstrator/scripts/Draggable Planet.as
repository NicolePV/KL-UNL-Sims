function DraggablePlanetClass()
{
   var _loc1_ = this;
   _loc1_.createEmptyMovieClip("discMC",1);
   _loc1_.createEmptyMovieClip("borderMC",2);
   _loc1_.discMC.beginFill(_loc1_.discColor);
   _loc1_.drawCircle(_loc1_.discMC,0,0,_loc1_.discRadius);
   _loc1_.discMC.endFill();
   _loc1_.borderMC.lineStyle(_loc1_.borderThickness,_loc1_.borderColor);
   _loc1_.drawCircle(_loc1_.borderMC,0,0,_loc1_.discRadius);
   _loc1_.borderMC._visible = false;
   _loc1_.discMC.useHandCursor = false;
   _loc1_.discMC.tabEnabled = false;
   _loc1_.discMC.onPress = _loc1_.onPressFunc;
   _loc1_.discMC.onRelease = _loc1_.onReleaseFunc;
   _loc1_.discMC.onReleaseOutside = _loc1_.onReleaseOutsideFunc;
   _loc1_.discMC.onMouseMoveFunc = _loc1_.onMouseMoveFunc;
   _loc1_.discMC.onRollOver = _loc1_.onRollOverFunc;
   _loc1_.discMC.onRollOut = _loc1_.onRollOutFunc;
   _loc1_.labelMC.labelText = _loc1_.labelText;
}
var p = DraggablePlanetClass.prototype = new MovieClip();
Object.registerClass("Draggable Planet",DraggablePlanetClass);
p.topDepth = 10;
p.discRadius = 6;
p.discColor = 9474192;
p.borderColor = 16777215;
p.borderThickness = 2;
p.labelRadius = 20;
p.setLabelAngle = function(arg)
{
   var _loc1_ = this;
   _loc1_.labelMC._x = _loc1_.labelRadius * Math.cos(arg);
   _loc1_.labelMC._y = _loc1_.labelRadius * Math.sin(arg);
};
p.onMouseMoveFunc = function()
{
   var _loc1_ = this;
   var _loc3_ = _loc1_.xOffset + _loc1_._parent._parent._xmouse;
   var _loc2_ = _loc1_.yOffset + _loc1_._parent._parent._ymouse;
   _loc1_._parent._parent._parent.setPlanetPosition(_loc1_._parent.id,_loc3_,_loc2_);
   updateAfterEvent();
};
p.onPressFunc = function()
{
   var _loc1_ = this;
   _loc1_.xOffset = _loc1_._parent._x - _loc1_._parent._parent._xmouse;
   _loc1_.yOffset = _loc1_._parent._y - _loc1_._parent._parent._ymouse;
   _loc1_.onMouseMove = _loc1_.onMouseMoveFunc;
   _loc1_._parent.swapDepths(_loc1_._parent.topDepth);
};
p.onReleaseFunc = function()
{
   delete this.onMouseMove;
};
p.onReleaseOutsideFunc = function()
{
   this._parent.borderMC._visible = false;
   delete this.onMouseMove;
};
p.onRollOverFunc = function()
{
   this._parent.borderMC._visible = true;
};
p.onRollOutFunc = function()
{
   this._parent.borderMC._visible = false;
};
p.drawCircle = function(mc, x, y, r)
{
   var _loc1_ = r;
   var _loc2_ = y;
   var _loc3_ = x;
   mc.moveTo(_loc3_ + _loc1_,_loc2_);
   mc.curveTo(_loc3_ + _loc1_,_loc2_ - 0.4142 * _loc1_,_loc3_ + 0.7071 * _loc1_,_loc2_ - 0.7071 * _loc1_);
   mc.curveTo(_loc3_ + 0.4142 * _loc1_,_loc2_ - _loc1_,_loc3_,_loc2_ - _loc1_);
   mc.curveTo(_loc3_ - 0.4142 * _loc1_,_loc2_ - _loc1_,_loc3_ - 0.7071 * _loc1_,_loc2_ - 0.7071 * _loc1_);
   mc.curveTo(_loc3_ - _loc1_,_loc2_ - 0.4142 * _loc1_,_loc3_ - _loc1_,_loc2_);
   mc.curveTo(_loc3_ - _loc1_,_loc2_ + 0.4142 * _loc1_,_loc3_ - 0.7071 * _loc1_,_loc2_ + 0.7071 * _loc1_);
   mc.curveTo(_loc3_ - 0.4142 * _loc1_,_loc2_ + _loc1_,_loc3_,_loc2_ + _loc1_);
   mc.curveTo(_loc3_ + 0.4142 * _loc1_,_loc2_ + _loc1_,_loc3_ + 0.7071 * _loc1_,_loc2_ + 0.7071 * _loc1_);
   mc.curveTo(_loc3_ + _loc1_,_loc2_ + 0.4142 * _loc1_,_loc3_ + _loc1_,_loc2_);
};
