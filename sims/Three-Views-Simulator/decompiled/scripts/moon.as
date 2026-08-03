function moonClass()
{
   this._oldTime = getTimer();
   this._angle = 0;
}
var p = moonClass.prototype = new MovieClip();
Object.registerClass("moon",moonClass);
p.onEnterFrame = function()
{
   var newTime = getTimer();
   var da = (newTime - this._oldTime) * 2 * 3.141592653589793 / this._speed;
   if(this.animate)
   {
      this._angle += da;
      var newX = - this._radius + this._radius * Math.cos(6.283185307179586 - this._angle);
      var newY = this._radius * Math.sin(6.283185307179586 - this._angle);
      this.moveMoonTo(newX,newY);
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
p.rotateShadow = function(rotAmt)
{
   if(this.withShad)
   {
      this.myShadow._rotation = rotAmt;
   }
};
p.moveMoonTo = function(xPos, yPos)
{
   this.myShadow._x = xPos;
   this.myMoon._x = xPos;
   this.myShadow._y = yPos;
   this.myMoon._y = yPos;
};
p.getShad = function()
{
   return this._withSun;
};
p.setShad = function(arg)
{
   this._withSun = arg;
};
p.addProperty("withShad",p.getShad,p.setShad);
p.getAnim = function()
{
   return this._anim;
};
p.setAnim = function(arg)
{
   this._anim = arg;
};
p.addProperty("animate",p.getAnim,p.setAnim);
