function earthClass()
{
   this._time = 0;
   this.earthArrow._visible = false;
}
var p = earthClass.prototype = new MovieClip();
Object.registerClass("earth",earthClass);
p.onEnterFrame = function()
{
   if(this.animate)
   {
      this.rotateEarth(this._time);
   }
   if(this.withShad)
   {
      this.myShadow._visible = true;
   }
   else
   {
      this.myShadow._visible = false;
   }
};
p.rotateEarth = function(rotAmt)
{
   this.myEarth._rotation = rotAmt;
};
p.getAnim = function()
{
   return this._anim;
};
p.setAnim = function(arg)
{
   this._anim = arg;
};
p.addProperty("animate",p.getAnim,p.setAnim);
p.getShad = function()
{
   return this._withSun;
};
p.setShad = function(arg)
{
   this._withSun = arg;
};
p.addProperty("withShad",p.getShad,p.setShad);
