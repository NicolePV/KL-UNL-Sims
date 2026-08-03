function animClass()
{
   this._moonSpeed = this.moon._speed;
   this.moon._speed = this._moonSpeed / this._speed;
   this.moon._visible = false;
   this._frame = 0;
}
var p = animClass.prototype = new MovieClip();
Object.registerClass("tideAnim",animClass);
p.onEnterFrame = function()
{
   this.moon._speed = this._moonSpeed / this._speed;
   if(this.animate)
   {
      this._frame = this.degrees(this.moon._angle);
      this._moonTime = 360 - this._frame;
      this.earth._time = this._moonTime * 28;
      this.moon2._rotation = this._moonTime;
      this.moon2.visMoon._rotation = - this._moonTime;
      this.moon.animate = true;
      this.earth.animate = true;
      if(this._withSun)
      {
         this.earth.withShad = true;
         this.moon2.visMoon.withShad = true;
      }
      else
      {
         this.earth.withShad = false;
         this.moon2.visMoon.withShad = false;
      }
   }
   else
   {
      this.moon.animate = false;
      this.earth.animate = false;
      if(this._withSun)
      {
         this.earth.withShad = true;
         this.moon2.visMoon.withShad = true;
      }
      else
      {
         this.earth.withShad = false;
         this.moon2.visMoon.withShad = false;
      }
   }
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
p.degrees = function(radians)
{
   var deg = radians * 57.29577951308232;
   return deg;
};
