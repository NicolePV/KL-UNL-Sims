function MiniHRDiagramClass()
{
   this.tMin = 3000;
   this.tMax = 45000;
   this.lMin = 0.001;
   this.lMax = 1000000;
   this.graphW = 300;
   this.graphH = 200;
   this.xScale = this.graphW / Math.log(this.tMax / this.tMin);
   this.yScale = this.graphH / Math.log(this.lMax / this.lMin);
   var mc = this.createEmptyMovieClip("plotAreaMC",5);
   mc.attachMovie("Mini HR Diagram Main Sequence","mainSequenceMC",1,{_visible:false});
   mc.attachMovie("Mini HR Diagram Point","point1MC",2,{id:1});
   mc.attachMovie("Mini HR Diagram Point","point2MC",3,{id:2});
   var mc = this.createEmptyMovieClip("maskMC",10);
   mc.clear();
   mc.moveTo(0,0);
   mc.beginFill(16711680);
   mc.lineTo(this.graphW,0);
   mc.lineTo(this.graphW,- this.graphH);
   mc.lineTo(0,- this.graphH);
   mc.lineTo(0,0);
   mc.endFill();
   this.plotAreaMC.setMask(this.maskMC);
   this.plotAreaMC.point1MC.useHandCursor = false;
   this.plotAreaMC.point1MC.onRollOver = this.pointOnRollOver;
   this.plotAreaMC.point1MC.onPress = this.pointOnPress;
   this.plotAreaMC.point1MC.onMouseMoveFunc = this.pointOnMouseMoveFunc;
   this.plotAreaMC.point1MC.onRollOut = this.pointOnRollOut;
   this.plotAreaMC.point1MC.onReleaseOutside = this.pointOnReleaseOutside;
   this.plotAreaMC.point1MC.onRelease = this.pointOnRelease;
   this.plotAreaMC.point2MC.useHandCursor = false;
   this.plotAreaMC.point2MC.onRollOver = this.pointOnRollOver;
   this.plotAreaMC.point2MC.onPress = this.pointOnPress;
   this.plotAreaMC.point2MC.onMouseMoveFunc = this.pointOnMouseMoveFunc;
   this.plotAreaMC.point2MC.onRollOut = this.pointOnRollOut;
   this.plotAreaMC.point2MC.onReleaseOutside = this.pointOnReleaseOutside;
   this.plotAreaMC.point2MC.onRelease = this.pointOnRelease;
   this.plotAreaMC.point1MC.labelMC.labelField.text = "1";
   this.plotAreaMC.point2MC.labelMC.labelField.text = "2";
   this.lowerRadiusLimitMC._x = this.graphW;
   this.upperRadiusLimitMC._x = 0;
   this.createEmptyMovieClip("rangesMC",1);
   var mc = this.createEmptyMovieClip("rangesMaskMC",2);
   mc.clear();
   mc.lineStyle(1,16711680);
   mc.beginFill(16711935,30);
   mc.moveTo(0,0);
   mc.lineTo(this.graphW,0);
   mc.lineTo(this.graphW,- this.graphH);
   mc.lineTo(0,- this.graphH);
   mc.lineTo(0,0);
   mc.endFill();
   this.rangesMC.setMask(mc);
   this.hideRanges();
}
var p = MiniHRDiagramClass.prototype = new MovieClip();
Object.registerClass("Mini HR Diagram",MiniHRDiagramClass);
p.pointOnRollOver = function()
{
   this.gotoAndStop(2);
};
p.pointOnPress = function()
{
   this.xOffset = this._x - this._parent._xmouse;
   this.yOffset = this._y - this._parent._ymouse;
   this.onMouseMove = this.onMouseMoveFunc;
   this._parent._parent.showRanges(this.id);
};
p.pointOnMouseMoveFunc = function()
{
   var newX = this.xOffset + this._parent._xmouse;
   var newY = this.yOffset + this._parent._ymouse;
   this._parent._parent._parent._parent.setTempAndLuminosity(this.id,this._parent._parent.findT(newX),this._parent._parent.findL(newY));
   updateAfterEvent();
};
p.pointOnRollOut = function()
{
   this.gotoAndStop(1);
};
p.pointOnReleaseOutside = function()
{
   this.gotoAndStop(1);
   delete this.onMouseMove;
   this._parent._parent.hideRanges();
};
p.pointOnRelease = function()
{
   delete this.onMouseMove;
   this._parent._parent.hideRanges();
};
p.setPointPosition = function(id, t, l)
{
   if(id == 1)
   {
      var thisPoint = this.plotAreaMC.point1MC;
      var otherPoint = this.plotAreaMC.point2MC;
   }
   else
   {
      var thisPoint = this.plotAreaMC.point2MC;
      var otherPoint = this.plotAreaMC.point1MC;
   }
   var nx = this.findX(t);
   var ny = this.findY(l);
   thisPoint._x = nx;
   thisPoint._y = ny;
   var dx = otherPoint._x - nx;
   var dy = otherPoint._y - ny;
   var s = 14 / Math.sqrt(dx * dx + dy * dy);
   thisPoint.labelMC._x = (- s) * dx;
   thisPoint.labelMC._y = (- s) * dy;
   otherPoint.labelMC._x = - thisPoint.labelMC._x;
   otherPoint.labelMC._y = - thisPoint.labelMC._y;
};
p.getShowMainSequenceOverlay = function()
{
   return this.plotAreaMC.mainSequenceMC._visible;
};
p.setShowMainSequenceOverlay = function(arg)
{
   this.plotAreaMC.mainSequenceMC._visible = arg;
};
p.addProperty("showMainSequenceOverlay",p.getShowMainSequenceOverlay,p.setShowMainSequenceOverlay);
p.showRanges = function(star)
{
   var radiusRange = this._parent._parent["radius" + star + "Slider"].getRange();
   var tempRange = this._parent._parent["temp" + star + "Slider"].getRange();
   if(!this._parent._parent["restrict" + star + "Check"].getValue())
   {
      tempRange.max = this._parent._parent.TmaxSld;
   }
   var k1 = Math.pow(tempRange.max / 5808.3,4);
   var k2 = 0.071168672;
   var x1 = this.findX(tempRange.max);
   var x2 = this.graphW;
   var y1 = this.findY(radiusRange.min * radiusRange.min * k1);
   var y2 = this.findY(radiusRange.max * radiusRange.max * k1);
   var y3 = this.findY(radiusRange.max * radiusRange.max * k2);
   var y4 = this.findY(radiusRange.min * radiusRange.min * k2);
   var mc = this.rangesMC;
   mc.clear();
   if(radiusRange.min == radiusRange.max)
   {
      mc.beginFill(10066329,30);
      mc.lineStyle(1,16777215,0);
      mc.moveTo(-10,10);
      mc.lineTo(-10,- this.graphH - 10);
      mc.lineTo(this.graphW + 10,- this.graphH - 10);
      mc.lineTo(this.graphW + 10,10);
      mc.lineTo(-10,10);
      mc.endFill();
      mc.lineStyle(0,16777215,100);
      mc.moveTo(x1,y1);
      mc.lineTo(x2,y4);
   }
   else
   {
      mc.beginFill(10066329,30);
      mc.lineStyle(1,16777215,0);
      mc.moveTo(x1,y1);
      mc.lineTo(x1,y2);
      mc.lineTo(x2,y3);
      mc.lineTo(x2,y4);
      mc.lineTo(x1,y1);
      mc.moveTo(-10,10);
      mc.lineTo(-10,- this.graphH - 10);
      mc.lineTo(this.graphW + 10,- this.graphH - 10);
      mc.lineTo(this.graphW + 10,10);
      mc.lineTo(-10,10);
      mc.endFill();
   }
};
p.hideRanges = function()
{
   this.rangesMC.clear();
};
p.findX = function(t)
{
   return this.graphW - this.xScale * Math.log(t / this.tMin);
};
p.findY = function(l)
{
   return (- this.yScale) * Math.log(l / this.lMin);
};
p.findT = function(x)
{
   return this.tMin * Math.exp((this.graphW - x) / this.xScale);
};
p.findL = function(y)
{
   return this.lMin * Math.exp((- y) / this.yScale);
};
