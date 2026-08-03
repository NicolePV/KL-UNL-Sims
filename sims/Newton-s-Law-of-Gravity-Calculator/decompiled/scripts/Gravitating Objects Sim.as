function GravitatingObjectsSimClass()
{
}
var p = GravitatingObjectsSimClass.prototype = new MovieClip();
Object.registerClass("Gravitating Objects Sim",GravitatingObjectsSimClass);
p.setObjects = function(obj1, obj2)
{
   this.removeMovieClip(this.object1);
   this.removeMovieClip(this.object2);
   this.attachMovie(obj1.mc,"object1",1);
   this.attachMovie(obj2.mc,"object2",2);
};
