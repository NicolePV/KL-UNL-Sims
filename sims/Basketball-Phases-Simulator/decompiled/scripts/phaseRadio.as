function radioClass()
{
   this.value = true;
}
var p = radioClass.prototype = new MovieClip();
Object.registerClass("phaseRadio",radioClass);
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
