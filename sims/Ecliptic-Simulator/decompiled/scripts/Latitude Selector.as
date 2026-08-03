function LatitudeSelectorClass()
{
   this.setLatitude(this.initLat);
}
var p = LatitudeSelectorClass.prototype = new MovieClip();
Object.registerClass("Latitude Selector",LatitudeSelectorClass);
p.setLatitude = function(arg)
{
   this.stickfigureMC._x = this.radius * Math.cos(arg * 3.141592653589793 / 180);
   this.stickfigureMC._y = (- this.radius) * Math.sin(arg * 3.141592653589793 / 180);
   this.stickfigureMC._rotation = 90 + 57.29577951308232 * Math.atan2(this.stickfigureMC._y,this.stickfigureMC._x);
};
