function tidalClass()
{
   this._frame = 2;
}
var p = tidalClass.prototype = new MovieClip();
Object.registerClass("tidalBulge",tidalClass);
p.onEnterFrame = function()
{
   if(this.animate)
   {
      this._frame = Math.round(this._frame);
      if(this._frame == 1)
      {
         this._frame = 2;
      }
      if(!this._playing)
      {
         this.gotoAndStop(1);
      }
      else if(this._playing)
      {
         this.gotoAndStop(this._frame);
      }
   }
};
p.startAnim = function(frame)
{
   gotoAndPlay(frame);
   this._playing = true;
};
p.stopAnim = function()
{
   stop();
   this._playing = false;
};
p.getLongLength = function()
{
   return this.myTide._width;
};
p.setLongLength = function(w)
{
   this.myTide._width = w;
};
p.addProperty("longLength",p.getLongLength,p.setLongLength);
p.getShortLength = function()
{
   return this.myTide._height;
};
p.setShortLength = function(h)
{
   this.myTide._height = h;
};
p.addProperty("shortLength",p.getShortLength,p.setShortLength);
p.getAnim = function()
{
   return this._anim;
};
p.setAnim = function(arg)
{
   this._anim = arg;
};
p.addProperty("animate",p.getAnim,p.setAnim);
