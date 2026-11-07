function hideShowClass()
{
   this.hideValue = false;
}
var p = hideShowClass.prototype = new MovieClip();
Object.registerClass("hide_show",hideShowClass);
p.onEnterFrame = function()
{
   this.hideButton._visible = !this.hideValue;
};
