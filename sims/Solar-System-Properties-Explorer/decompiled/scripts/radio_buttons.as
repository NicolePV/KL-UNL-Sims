function radioClass()
{
   this._value = "axis";
   this._changed = false;
   this.rotation_radio._visible = false;
}
var p = radioClass.prototype = new MovieClip();
Object.registerClass("radio_buttons",radioClass);
p.onEnterFrame = function()
{
};
