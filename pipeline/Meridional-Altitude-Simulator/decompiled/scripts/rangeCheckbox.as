function checkClass()
{
   this._showSun = false;
   this._showMoon = false;
}
var p = checkClass.prototype = new MovieClip();
Object.registerClass("rangeCheckbox",checkClass);
p.onEnterFrame = function()
{
};
p.setSun = function(arg)
{
   this._showSun = arg;
};
p.getSun = function()
{
   return this._showSun;
};
p.getMoon = function()
{
   return this._showMoon;
};
p.setMoon = function(arg)
{
   this._showMoon = arg;
};
p.addProperty("showSunRange",p.getSun,p.setSun);
p.addProperty("showMoonRange",p.getMoon,p.setMoon);
