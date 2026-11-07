function RiskPlotClass()
{
}
var p = RiskPlotClass.prototype = new MovieClip();
Object.registerClass("RiskPlot",RiskPlotClass);
p.scale = 14.7;
p.onCursorDragged = function(arg)
{
   this._parent.setRadius(arg / this.scale);
};
p.setCursorRadius = function(arg)
{
   this.cursorMC._x = arg * this.scale;
};
