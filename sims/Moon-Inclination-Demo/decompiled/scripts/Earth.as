function EarthClass()
{
   this.radius = 8;
}
var p = EarthClass.prototype = new MovieClip();
Object.registerClass("Earth",EarthClass);
p.update = function(zLevel)
{
};
