function GravitySimulatorClass()
{
}
var p = GravitySimulatorClass.prototype = new MovieClip();
Object.registerClass("Gravity Simulator",GravitySimulatorClass);
p.onTabChanged = function(tabTitle)
{
};
p.reset = function()
{
   this.calcPanel.reset();
};
