function objRadioClass()
{
   this._value = 0;
}
var p = objRadioClass.prototype = new MovieClip();
Object.registerClass("objectRadio",objRadioClass);
p.getVal = function()
{
   return this._value;
};
p.setVal = function(arg)
{
   this._value = arg;
};
p.addProperty("objValue",p.getVal,p.setVal);
