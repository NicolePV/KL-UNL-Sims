function checkClass()
{
   this._changed = false;
}
var p = checkClass.prototype = new MovieClip();
Object.registerClass("check_boxes",checkClass);
p.onEnterFrame = function()
{
};
