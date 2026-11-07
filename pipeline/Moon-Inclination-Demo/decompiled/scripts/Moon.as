function MoonClass()
{
   this.radius = 8;
}
var p = MoonClass.prototype = new MovieClip();
Object.registerClass("Moon",MoonClass);
p.update = function(zLevel)
{
};
