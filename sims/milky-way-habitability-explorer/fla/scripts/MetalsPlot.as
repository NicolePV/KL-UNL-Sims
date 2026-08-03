function MetalsPlotClass()
{
}
var p = MetalsPlotClass.prototype = new MovieClip();
Object.registerClass("MetalsPlot",MetalsPlotClass);
p.scale = 14.7;
p.onCursorDragged = function(arg)
{
   this._parent.setRadius(arg / this.scale);
};
p.setCursorRadius = function(arg)
{
   this.cursorMC._x = arg * this.scale;
};
