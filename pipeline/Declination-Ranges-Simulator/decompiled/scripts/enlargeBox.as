function enlargeClass()
{
   this._enlarge = false;
}
var p = enlargeClass.prototype = new MovieClip();
Object.registerClass("enlargeBox",enlargeClass);
p.onEnterFrame = function()
{
};
p.getEnlarge = function()
{
   return this._enlarge;
};
p.setEnlarge = function(arg)
{
   this._enlarge = arg;
};
p.addProperty("enlarge",p.getEnlarge,p.setEnlarge);
