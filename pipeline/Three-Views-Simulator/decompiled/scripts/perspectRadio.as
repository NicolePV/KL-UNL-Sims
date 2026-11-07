function radioClass()
{
}
var p = radioClass.prototype = new MovieClip();
Object.registerClass("perspectRadio",radioClass);
p.onEnterFrame = function()
{
   if(this.perspective == "sun")
   {
      this.sunButton.setState(true);
   }
   else if(this.perspective == "space")
   {
      this.spaceButton.setState(true);
   }
   else if(this.perspective == "earth")
   {
      this.earthButton.setState(true);
   }
};
p.getPerspect = function()
{
   return this._from;
};
p.setPerspect = function(arg)
{
   this._from = arg;
};
p.addProperty("perspective",p.getPerspect,p.setPerspect);
