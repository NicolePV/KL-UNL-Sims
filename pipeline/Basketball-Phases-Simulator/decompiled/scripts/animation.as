function rotatorClass()
{
}
var p = rotatorClass.prototype = new MovieClip();
Object.registerClass("animation",rotatorClass);
p.onEnterFrame = function()
{
   this.eyeball._speed = this.mySlider.value;
   this.eyeball.animate = this.animRadio.value;
   this.eyeball._withShad = this.phRadio.value;
   if(this.eyeball._withShad)
   {
      this.rotator.setSunAngle(this.eyeball.angle);
      this.myLight._visible = true;
   }
   else
   {
      this.rotator.setSunAngle(0);
      this.myLight._visible = false;
   }
   this.rotator.setLongitude(this.eyeball.angle);
   this.rotator._sequence._visible = !this.hide_show.hideValue;
};
