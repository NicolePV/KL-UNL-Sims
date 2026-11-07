function OrbitsDiagramPlanetClass()
{
   this.discColorObj = new Color(this.discMC);
   this.setDiscColor(this.discColor);
}
var p = OrbitsDiagramPlanetClass.prototype = new MovieClip();
Object.registerClass("Orbits Diagram Planet",OrbitsDiagramPlanetClass);
p.setDiscColor = function(arg)
{
   this.discColorObj.setRGB(arg);
};
p.useHandCursor = false;
p.tabEnabled = false;
p.onPress = function()
{
   var mouseAngle = Math.atan2(- this._parent._ymouse,this._parent._xmouse);
   mouseAngle = (mouseAngle % 6.283185307179586 + 6.283185307179586) % 6.283185307179586;
   this.angleOffset = mouseAngle - this.simulatorMC["angle" + this.id];
   if(this.angleOffset < -3.141592653589793)
   {
      this.angleOffset += 6.283185307179586;
   }
   if(this.angleOffset > 3.141592653589793)
   {
      this.angleOffset -= 6.283185307179586;
   }
   var r = this.diagramMC["screenRadius" + this.id];
   var d = this.diagramMC.snapDistance;
   var cosThreshold = 1 - d * d / (2 * r * r);
   if(cosThreshold < -1)
   {
      trace("*** warning, cosThreshold is less than -1 ***");
      this.angleThreshold = 0;
   }
   else
   {
      this.angleThreshold = Math.acos(cosThreshold);
   }
   if(Key.isDown(16))
   {
      this.onMouseMove = this.epochAngleOnMouseMoveFunc;
   }
   else
   {
      this.onMouseMove = this.timeOnMouseMoveFunc;
   }
   this.simulatorMC.freezeAnimation();
};
p.onRelease = function()
{
   delete this.onMouseMove;
   this.simulatorMC.thawAnimation();
};
p.onReleaseOutside = function()
{
   this.gotoAndStop(1);
   delete this.onMouseMove;
   this.simulatorMC.thawAnimation();
};
p.onRollOver = function()
{
   this.gotoAndStop(2);
};
p.onRollOut = function()
{
   this.gotoAndStop(1);
};
p.epochAngleOnMouseMoveFunc = function()
{
   var mouseAngle = Math.atan2(- this._parent._ymouse,this._parent._xmouse);
   var angle = ((mouseAngle - this.angleOffset) % 6.283185307179586 + 6.283185307179586) % 6.283185307179586;
   this.simulatorMC.setEpochAngleByPlanetAngle(this.id,angle,this.diagramMC.snapToEvents,this.angleThreshold);
   updateAfterEvent();
};
p.timeOnMouseMoveFunc = function()
{
   var mouseAngle = Math.atan2(- this._parent._ymouse,this._parent._xmouse);
   var angle = ((mouseAngle - this.angleOffset) % 6.283185307179586 + 6.283185307179586) % 6.283185307179586;
   this.simulatorMC.setTimeByPlanetAngle(this.id,angle,this.diagramMC.snapToEvents,this.angleThreshold);
   updateAfterEvent();
};
