function animClass()
{
   this._angle = 0;
   this._active = false;
   this.myAnim._speed = this._speed;
   this._revAngle = 0;
   this.spaceView._visible = false;
   this.spaceArrow._visible = false;
   this.spaceArrow._x = 260;
   this.spaceArrow._y = -260;
   this._spaceX = 260;
   this._spaceY = -260;
}
var p = animClass.prototype = new MovieClip();
Object.registerClass("animation",animClass);
p.onEnterFrame = function()
{
   this.myAnim._speed = this._speed;
   this._revAngle = this.myAnim.myEarth._frame;
   this.animate = this.aButton.myRun.value;
   if(this.myAnim.myEarth.earth._time == 0)
   {
      this._angle = 0;
   }
   else
   {
      this._angle = this.myAnim.myEarth.earth._time / 365 - 27.6;
   }
   if(this.animate)
   {
      this.myAnim.animate = true;
      this.rotateAll(this._angle);
   }
   else
   {
      this.myAnim.animate = false;
   }
   var distSM = this.myAnim._distSM;
   var angESM = Math.asin(61 * Math.sin(this.myAnim._angMES) / distSM);
   var angMS0 = Math.abs(angESM + this.radians(this._angle)) % 6.283185307179586;
   var moonX = distSM * Math.cos(angMS0);
   var moonY = distSM * Math.sin(angMS0);
   var earthX = 203 * Math.cos(this.radians(this._angle));
   var earthY = 203 * Math.sin(this.radians(this._angle));
   var v1 = this._spaceX - moonX;
   var v2 = - this._spaceY - moonY;
   var w1 = - moonX;
   var w2 = - moonY;
   var angSMA = Math.atan2(w2,w1) - Math.atan2(v2,v1);
   var u1 = moonX - this._spaceX;
   var u2 = moonY + this._spaceY;
   var angMA0 = - Math.atan2(u2,u1);
   if(this.radio.perspective == "earth")
   {
      this.earthView._visible = true;
      this.spaceView._visible = false;
      this.earthView.setPhase(180 + this._revAngle);
      this.myAnim.myEarth.earth.earthArrow._visible = true;
      this.myAnim.myEarth.earth.earthArrow._rotation = - this._revAngle;
      this.sunArrow._visible = false;
      this.spaceArrow._visible = false;
   }
   else if(this.radio.perspective == "sun")
   {
      this.earthView._visible = false;
      this.spaceView._visible = true;
      this.spaceView.setSunAngle(0);
      this.spaceView.setLongitude(45 + this._revAngle);
      this.myAnim.myEarth.earth.earthArrow._visible = false;
      this.spaceArrow._visible = false;
      this.sunArrow._visible = true;
      var ang = - Math.atan2(moonY,moonX);
      this.sunArrow._rotation = this.deg(ang);
   }
   else if(this.radio.perspective == "space")
   {
      this.earthView._visible = false;
      this.spaceView._visible = true;
      this.spaceArrow._visible = true;
      this.spaceArrow._rotation = this.deg(angMA0);
      this.spaceView.setSunAngle(this.deg(angSMA));
      var angAM0 = Math.atan2(v2,v1);
      this.spaceView.setLongitude(this.deg(angAM0 + this.myAnim._angMES) + 45);
      this.myAnim.myEarth.earth.earthArrow._visible = false;
      this.sunArrow._visible = false;
   }
   if(this.aButton.myRun.restart)
   {
      this.myAnim.animate = false;
      this.animate = false;
      this._angle = 0;
      this._revAngle = 0;
      this.myAnim.myEarth.earth._time = 0;
      this.myAnim.myEarth._frame = 0;
      this.myAnim.myEarth.moon2.visMoon._rotation = 0;
      this.myAnim.myEarth.moon._angle = 0;
      this.myAnim.myEarth.moon2._rotation = 0;
      this.myAnim.myEarth.earth.earthArrow._rotation = 0;
      this.sunArrow._rotation = 0;
      this.rotateAll(0);
   }
   this.spaceView._sequence._visible = !this.hide_button.hideValue;
   this.earthView._moon_mc._visible = !this.hide_button.hideValue;
};
p.radians = function(deg)
{
   return deg * 0.017453292519943295;
};
p.deg = function(rad)
{
   return rad * 57.29577951308232;
};
p.rotateAll = function(rotAmt)
{
   this.myAnim._rotation = rotAmt;
};
p.setAnim = function(arg)
{
   this._anim = arg;
};
p.getAnim = function()
{
   return this._anim;
};
p.setActive = function(arg)
{
   this._active = arg;
};
p.getActive = function()
{
   return this._active;
};
p.addProperty("animate",p.getAnim,p.setAnim);
p.addProperty("active",p.getActive,p.setActive);
