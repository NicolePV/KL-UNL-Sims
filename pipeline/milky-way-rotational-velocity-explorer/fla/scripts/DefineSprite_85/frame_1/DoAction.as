plotMC.onPointDragged = function()
{
   this._parent.milkyWayMC.setRadius(this.distance);
};
this.milkyWayMC.setRadius(this.plotMC.distance);
