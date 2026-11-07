function buttonClass()
{
   this._value = false;
   this._restart = false;
}
var p = buttonClass.prototype = new MovieClip();
Object.registerClass("startButton",buttonClass);
p.onEnterFrame = function()
{
   if(this.value)
   {
      this.myButton._visible = false;
   }
   else
   {
      this.myButton._visible = true;
   }
};
p.setVal = function(arg)
{
   this._value = arg;
};
p.getVal = function()
{
   return this._value;
};
p.setRestart = function(arg)
{
   this._restart = arg;
};
p.getRestart = function()
{
   return this._restart;
};
p.addProperty("value",p.getVal,p.setVal);
p.addProperty("restart",p.getRestart,p.setRestart);
