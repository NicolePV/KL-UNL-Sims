function DraggablePlanetClass()
{
   this.createEmptyMovieClip("discMC",1);
   this.createEmptyMovieClip("borderMC",2);
   this.discMC.beginFill(this.discColor);
   this.drawCircle(this.discMC,0,0,this.discRadius);
   this.discMC.endFill();
   this.borderMC.lineStyle(this.borderThickness,this.borderColor);
   this.drawCircle(this.borderMC,0,0,this.discRadius);
   this.borderMC._visible = false;
   this.discMC.useHandCursor = false;
   this.discMC.tabEnabled = false;
   this.discMC.onPress = this.onPressFunc;
   this.discMC.onRelease = this.onReleaseFunc;
   this.discMC.onReleaseOutside = this.onReleaseOutsideFunc;
   this.discMC.onMouseMoveFunc = this.onMouseMoveFunc;
   this.discMC.onRollOver = this.onRollOverFunc;
   this.discMC.onRollOut = this.onRollOutFunc;
   this.labelMC.labelText = this.labelText;
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
   this.labelMC._x = this.labelRadius * Math.cos(arg);
   this.labelMC._y = this.labelRadius * Math.sin(arg);
};
p.onMouseMoveFunc = function()
{
   var nx = this.xOffset + this._parent._parent._xmouse;
   var ny = this.yOffset + this._parent._parent._ymouse;
   this._parent._parent._parent.setPlanetPosition(this._parent.id,nx,ny);
   updateAfterEvent();
};
p.onPressFunc = function()
{
   this.xOffset = this._parent._x - this._parent._parent._xmouse;
   this.yOffset = this._parent._y - this._parent._parent._ymouse;
   this.onMouseMove = this.onMouseMoveFunc;
   this._parent.swapDepths(this._parent.topDepth);
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
   mc.moveTo(x + r,y);
   mc.curveTo(x + r,y - 0.4142 * r,x + 0.7071 * r,y - 0.7071 * r);
   mc.curveTo(x + 0.4142 * r,y - r,x,y - r);
   mc.curveTo(x - 0.4142 * r,y - r,x - 0.7071 * r,y - 0.7071 * r);
   mc.curveTo(x - r,y - 0.4142 * r,x - r,y);
   mc.curveTo(x - r,y + 0.4142 * r,x - 0.7071 * r,y + 0.7071 * r);
   mc.curveTo(x - 0.4142 * r,y + r,x,y + r);
   mc.curveTo(x + 0.4142 * r,y + r,x + 0.7071 * r,y + 0.7071 * r);
   mc.curveTo(x + r,y + 0.4142 * r,x + r,y);
};
