function eyeClass()
{
   this._oldTime = getTimer();
   this._time = 0;
   this._angle = 0;
   this._active = false;
   this._speed = 0.01;
}
var p = eyeClass.prototype = new MovieClip();
Object.registerClass("eye_clip",eyeClass);
p.onEnterframe = function()
{
   var newTime = getTimer();
   var dt = newTime - this._oldTime;
   if(this._anim)
   {
      this._time += dt * this._speed;
      this.angle = this._time % 360;
      var nextX = -250 * Math.cos(this.radians(this.angle));
      var nextY = -250 * Math.sin(this.radians(this.angle));
      this.the_eye._x = nextX;
      this.the_eye._y = nextY;
   }
   if(this._withShad)
   {
      this.myShadow._visible = true;
   }
   else
   {
      this.myShadow._visible = false;
   }
   this.the_eye._rotation = this.angle;
   this._oldTime = newTime;
};
p.findAngle = function(xPos, yPos)
{
   var theAngle = 3.141592653589793 - Math.atan2(yPos,xPos);
   return theAngle;
};
p.findY = function(xPos, ySign)
{
   var sqRad = 62500;
   var sqX = xPos * xPos;
   var theY;
   if(ySign < 0)
   {
      theY = - Math.sqrt(sqRad - sqX);
   }
   else
   {
      theY = Math.sqrt(sqRad - sqX);
   }
   return theY;
};
p.degrees = function(rad)
{
   return rad * 57.29577951308232;
};
p.radians = function(deg)
{
   return deg * 0.017453292519943295;
};
p.getAngle = function()
{
   return this._angle;
};
p.setAngle = function(arg)
{
   this._angle = arg;
};
p.getAnim = function()
{
   return this._anim;
};
p.setAnim = function(arg)
{
   this._anim = arg;
};
p.getActive = function()
{
   return this._active;
};
p.setActive = function(arg)
{
   this._active = arg;
};
p.addProperty("angle",p.getAngle,p.setAngle);
p.addProperty("animate",p.getAnim,p.setAnim);
p.addProperty("active",p.getActive,p.setActive);
