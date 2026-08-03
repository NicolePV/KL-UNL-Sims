function GRPObjectClass()
{
   this.plotMC = this._parent._parent;
   this.createEmptyMovieClip("inactiveDiscMC",1);
   this.createEmptyMovieClip("activeDiscMC",2);
   this.activeDiscMC._alpha = 0;
   this.createTextField("labelField",3,0,0,0,0);
   this.labelField.selectable = false;
   this.labelField.autoSize = true;
   this.labelField.embedFonts = true;
   this.labelField.align = "left";
   this.labelField.setTextFormat(this._parent._parent.objectLabelTextFormat);
   this.labelField.setNewTextFormat(this._parent._parent.objectLabelTextFormat);
   if(this.activeRadius == undefined)
   {
      this.activeRadius = 4;
   }
   if(this.inactiveRadius == undefined)
   {
      this.inactiveRadius = 3;
   }
   if(this.activeColor == undefined)
   {
      this.activeColor = 13684944;
   }
   if(this.activeAlpha == undefined)
   {
      this.activeAlpha = 100;
   }
   if(this.activeBorderThickness == undefined)
   {
      this.activeBorderThickness = 1;
   }
   if(this.activeBorderColor == undefined)
   {
      this.activeBorderColor = 13684944;
   }
   if(this.activeBorderAlpha == undefined)
   {
      this.activeBorderAlpha = 0;
   }
   if(this.inactiveColor == undefined)
   {
      this.inactiveColor = 9474192;
   }
   if(this.inactiveAlpha == undefined)
   {
      this.inactiveAlpha = 100;
   }
   if(this.inactiveBorderThickness == undefined)
   {
      this.inactiveBorderThickness = 1;
   }
   if(this.inactiveBorderColor == undefined)
   {
      this.inactiveBorderColor = 0;
   }
   if(this.inactiveBorderAlpha == undefined)
   {
      this.inactiveBorderAlpha = 100;
   }
   if(this.textAngle == undefined)
   {
      this.textAngle = 0;
   }
   if(this.textRadius == undefined)
   {
      this.textRadius = 7;
   }
   if(this.labelText == undefined)
   {
      this.labelText = "";
   }
   if(this.draggable == undefined)
   {
      this.draggable = false;
   }
   if(this.textColor == undefined)
   {
      this.textColor = 0;
   }
   this.watch("draggable",function(prop, oldval, newval)
   {
      this.updateDraggable();
      return newval;
   }
   );
   this.watch("labelText",function(prop, oldval, newval)
   {
      this.updateLabel();
      return newval;
   }
   );
   this.watch("textColor",function(prop, oldval, newval)
   {
      this.labelField.textColor = newval;
      return newval;
   }
   );
   this.labelField.textColor = this.textColor;
   if(typeof this.escapeSpeed != "number" || isNaN(this.escapeSpeed) || !isFinite(this.escapeSpeed) || this.escapeSpeed <= 0)
   {
      this.escapeSpeed = null;
   }
   if(typeof this.temperature != "number" || isNaN(this.temperature) || !isFinite(this.temperature) || this.temperature <= 0)
   {
      this.temperature = null;
   }
   this.updateDraggable();
   this.updateDisc();
   this.updateLabel();
   this.updatePosition();
}
var p = GRPObjectClass.prototype = new MovieClip();
Object.registerClass("GRP Object",GRPObjectClass);
p.updateDraggable = function()
{
   if(this.draggable)
   {
      this.activeDiscMC.useHandCursor = false;
      this.activeDiscMC.onPress = this.onPressFunc;
      this.activeDiscMC.onReleaseOutside = this.onReleaseOutsideFunc;
      this.activeDiscMC.onRelease = this.onReleaseFunc;
      this.activeDiscMC.onRollOver = this.onRollOverFunc;
      this.activeDiscMC.onRollOut = this.onRollOutFunc;
   }
   else
   {
      delete this.activeDiscMC.onPress;
      delete this.activeDiscMC.onReleaseOutside;
      delete this.activeDiscMC.onRelease;
      delete this.activeDiscMC.onRollOver;
      delete this.activeDiscMC.onRollOut;
   }
};
p.updatePosition = function()
{
   if(this.escapeSpeed == null || this.temperature == null)
   {
      this._visible = false;
      return undefined;
   }
   this._visible = true;
   this._x = this.plotMC.getX(this.temperature);
   this._y = this.plotMC.getY(this.escapeSpeed);
};
p.updateDisc = function()
{
   this.activeDiscMC.clear();
   this.activeDiscMC.lineStyle(this.activeBorderThickness,this.activeBorderColor,this.activeBorderAlpha);
   this.activeDiscMC.beginFill(this.activeColor,this.activeAlpha);
   this.drawCircle(this.activeDiscMC,0,0,this.activeRadius);
   this.activeDiscMC.endFill();
   this.inactiveDiscMC.clear();
   this.activeDiscMC.lineStyle(this.inactiveBorderThickness,this.inactiveBorderColor,this.inactiveBorderAlpha);
   this.inactiveDiscMC.beginFill(this.inactiveColor,this.inactiveAlpha);
   this.drawCircle(this.inactiveDiscMC,0,0,this.inactiveRadius);
   this.inactiveDiscMC.endFill();
};
p.updateLabel = function()
{
   this.labelField.text = this.labelText;
   var wh = (this.labelField._width - 4) / 2;
   var hh = (this.labelField._height - 10) / 2;
   var angle = 0.017453292519943295 * (this.textAngle - 90);
   this.labelField._x = -2 + (this.textRadius + wh) * Math.cos(angle) - wh;
   this.labelField._y = -5 + (this.textRadius + hh) * Math.sin(angle) - hh;
};
p.onRollOverFunc = function()
{
   this._parent.activeDiscMC._alpha = 100;
   this._parent.inactiveDiscMC._visible = false;
};
p.onRollOutFunc = function()
{
   this._parent.activeDiscMC._alpha = 0;
   this._parent.inactiveDiscMC._visible = true;
};
p.onReleaseOutsideFunc = function()
{
   delete this.onMouseMove;
   this._parent.activeDiscMC._alpha = 0;
   this._parent.inactiveDiscMC._visible = true;
};
p.onReleaseFunc = function()
{
   delete this.onMouseMove;
};
p.onPressFunc = function()
{
   this._xOffset = this._parent._parent._xmouse - this._parent._x;
   this._yOffset = this._parent._parent._ymouse - this._parent._y;
   this.onMouseMove = this._parent.onMouseMoveFunc;
};
p.onMouseMoveFunc = function()
{
   var nx = this._parent._parent._xmouse - this._xOffset;
   var ny = this._parent._parent._ymouse - this._yOffset;
   if(nx < 0)
   {
      nx = 0;
   }
   else if(nx > this._parent.plotMC._plotWidth)
   {
      nx = this._parent.plotMC._plotWidth;
   }
   if(ny > 0)
   {
      ny = 0;
   }
   else if(ny < - this._parent.plotMC._plotHeight)
   {
      ny = - this._parent.plotMC._plotHeight;
   }
   this._parent.temperature = this._parent.plotMC.getTemperature(nx);
   this._parent.escapeSpeed = this._parent.plotMC.getSpeed(ny);
   this._parent.updatePosition();
   this._parent.onObjectMoved.call(this._parent.plotMC._parent);
   updateAfterEvent();
};
p.getVisible = function()
{
   return this._visible;
};
p.setVisible = function(arg)
{
   this._visible = arg;
};
p.addProperty("visible",p.getVisible,p.setVisible);
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
