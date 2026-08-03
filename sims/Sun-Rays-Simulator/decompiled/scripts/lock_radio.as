function lockClass()
{
   this._value = 2;
}
var p = lockClass.prototype = new MovieClip();
Object.registerClass("lock_radio",lockClass);
p.onEnterFrame = function()
{
};
