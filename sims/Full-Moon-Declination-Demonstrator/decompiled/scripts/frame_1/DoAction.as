function reset()
{
   demoMC.setThetaAndPhi(200,20);
   setDayOfYear(45);
}
function setDayOfYear(arg)
{
   demoMC.setDayOfYear(arg);
   doyCursor._x = plotMC._x + demoMC._dayOfYear * (plotMC.width / 365);
}
doyCursor.useHandCursor = false;
doyCursor.tabEnabled = false;
doyCursor.onPress = function()
{
   this.xOffset = this._x - this._parent._xmouse;
   this.onMouseMove = this.onMouseMoveFunc;
};
doyCursor.onRelease = doyCursor.onReleaseOutside = function()
{
   delete this.onMouseMove;
};
doyCursor.onMouseMoveFunc = function()
{
   var newX = this._parent._xmouse + this.xOffset;
   this._parent.setDayOfYear(365 * (newX - this._parent.plotMC._x) / this._parent.plotMC.width);
   updateAfterEvent();
};
reset();
