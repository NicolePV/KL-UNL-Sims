function tideAnimClass()
{
   this.moon._speed /= this._speed;
   this.toSunArrow._visible = false;
   this._offset = 20;
   this.sunVectors._visible = false;
   this.moon._visible = false;
   this.moonVectors.arrow_1._visible = false;
   this.moonVectors.arrow_2._visible = false;
   this.moonVectors.arrow_3._visible = false;
}
var p = tideAnimClass.prototype = new MovieClip();
Object.registerClass("tideAnim",tideAnimClass);
p.onEnterFrame = function()
{
   if(this.animate)
   {
      this.earth.myTide._frame = this.degrees(this.moon._angle);
      this.earth._tideTime = 360 - this.earth.myTide._frame;
      this.earth._time = this.earth._tideTime * 28;
      this.moonVectors._rotation = this.earth._tideTime;
      this.moonVectors.visMoon._rotation = - this.earth._tideTime;
      this.moon.animate = true;
      this.earth.animate = true;
      this.earth.myTide.animate = true;
      if(this._earthEffects)
      {
         this.earth._offset = this._offset;
      }
      else
      {
         this.earth._offset = 0;
      }
      if(this._withSun)
      {
         this.earth.withShad = true;
         this.moonVectors.visMoon.withShad = true;
         this.toSunArrow._visible = true;
         this.earth.myTide._playing = true;
      }
      else
      {
         this.toSunArrow._visible = false;
         this.earth.withShad = false;
         this.moonVectors.visMoon.withShad = false;
         this.earth.myTide._playing = false;
      }
   }
   else
   {
      this.moon.animate = false;
      this.earth.animate = false;
      this.earth.myTide.animate = false;
      if(this._withSun)
      {
         this.earth.withShad = true;
         this.moonVectors.visMoon.withShad = true;
         this.toSunArrow._visible = true;
         this.earth.myTide.gotoAndStop(this.earth.myTide._frame);
      }
      else
      {
         this.toSunArrow._visible = false;
         this.earth.withShad = false;
         this.moonVectors.visMoon.withShad = false;
         this.earth.myTide.gotoAndStop(1);
      }
      if(this._earthEffects)
      {
         this.earth.rotateTide(this.earth._tideTime - this._offset);
      }
      else
      {
         this.earth.rotateTide(this.earth._tideTime);
      }
   }
   if(this._withArrows)
   {
      this.moonVectors.arrow_1._visible = true;
      this.moonVectors.arrow_2._visible = true;
      this.moonVectors.arrow_3._visible = true;
      if(this._withSun)
      {
         this.sunVectors._visible = true;
      }
      else
      {
         this.sunVectors._visible = false;
      }
   }
   else
   {
      this.moonVectors.arrow_1._visible = false;
      this.moonVectors.arrow_2._visible = false;
      this.moonVectors.arrow_3._visible = false;
      this.sunVectors._visible = false;
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
