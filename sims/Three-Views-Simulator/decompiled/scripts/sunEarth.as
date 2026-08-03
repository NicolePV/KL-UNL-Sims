function revClass()
{
   this.sunArrow._visible = false;
   this.myEarth._speed = this._speed;
   this._sqERadius = 41209;
   this._sqMRadius = 3721;
   this._angMES = this.rads(this.myEarth._frame);
   this._distSM = Math.sqrt(this._sqERadius + this._sqMRadius - 24766 * Math.cos(this._angMES));
}
var p = revClass.prototype = new MovieClip();
Object.registerClass("sunEarth",revClass);
p.onEnterFrame = function()
{
   this.myEarth._speed = this._speed;
   if(this.animate)
   {
      this.myEarth.animate = true;
   }
   else
   {
      this.myEarth.animate = false;
   }
   this._angMES = this.rads((this.myEarth._frame + 180) % 360);
   this._distSM = Math.sqrt(this._sqERadius + this._sqMRadius - 24766 * Math.cos(this._angMES));
};
p.rads = function(deg)
{
   return deg * 0.017453292519943295;
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
