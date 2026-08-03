function radioClass()
{
   this.value = false;
}
var p = radioClass.prototype = new MovieClip();
Object.registerClass("man_auto",radioClass);
p.onEnterFrame = function()
{
};
p.getVal = function()
{
   return this._value;
};
p.setVal = function(arg)
{
   this._value = arg;
};
p.addProperty("value",p.getVal,p.setVal);
