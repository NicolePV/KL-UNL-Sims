function ViewWindowClass()
{
}
var p = ViewWindowClass.prototype = new MovieClip();
Object.registerClass("View Window",ViewWindowClass);
p.minBoatScale = 100;
p.maxBoatScale = 130;
p.topBoatPosition = 85;
p.bottomBoatPosition = 95;
p.stripScale = 429.71834634811745;
p.setBoatPosition = function(x, y, z)
{
   this.boatX = x;
   this.boatY = y;
   this.update();
   this.boatMC._y = this.topBoatPosition + z * (this.bottomBoatPosition - this.topBoatPosition);
   this.boatMC._xscale = this.boatMC._yscale = this.minBoatScale + z * (this.maxBoatScale - this.minBoatScale);
};
p.setObserverPosition = function(x, y)
{
   this.observerX = x;
   this.observerY = y;
   this.update();
};
p.update = function()
{
   var _loc3_ = this.boatX - this.observerX;
   var _loc2_ = - (this.boatY - this.observerY);
   var _loc4_ = Math.atan2(_loc2_,_loc3_);
   this.backgroundMC._x = (_loc4_ - 1.5707963267948966) * this.stripScale;
};
