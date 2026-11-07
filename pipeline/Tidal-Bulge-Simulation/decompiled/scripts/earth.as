function earthClass()
{
   this._oldTime = getTimer();
   this._time = 0;
   this._tideTime = 0;
   this._offset = 0;
}
var p = earthClass.prototype = new MovieClip();
Object.registerClass("earth",earthClass);
p.onEnterFrame = function()
{
   var newTime = getTimer();
   var dt = newTime - this._oldTime;
   if(this.animate)
   {
      this.rotateEarth(this._time);
      this.rotateTide(this._tideTime - this._offset);
   }
   this._oldTime = newTime;
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
p.rotateTide = function(rotAmt)
{
   this.myTide._rotation = rotAmt;
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
