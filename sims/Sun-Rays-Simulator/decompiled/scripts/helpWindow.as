function windowClass()
{
   this._open = false;
}
var p = windowClass.prototype = new MovieClip();
Object.registerClass("helpWindow",windowClass);
p.onEnterFrame = function()
{
};
