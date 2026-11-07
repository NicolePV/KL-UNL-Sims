function MoonRotatorClass()
{
   this.attachMovie("MoonSequence","_sequence",1);
   this._sequence.stop();
   this.createEmptyMovieClip("_mask_mc",2);
   if(isFinite(this.initDarkAlpha))
   {
      this._darkAlpha = this.initDarkAlpha;
   }
   else
   {
      this._darkAlpha = 70;
   }
   this.setSunAngle(this.initSunAngle);
   if(this._phase == undefined)
   {
      this.setSunAngle(0);
   }
   this.setLongitude(this.initLongitude);
   if(this._long == undefined)
   {
      this.setLongitude(0);
   }
}
var p = MoonRotatorClass.prototype = new MovieClip();
Object.registerClass("MoonRotator",MoonRotatorClass);
p._frames = 59;
p._stepSize = 6.283185307179586 / p._frames;
p._margin = 10;
p._radius = 71;
p._N = 5;
p._taP = new Array();
p._tcP = new Array();
var step = 3.141592653589793 / (p._N - 1);
var cRad = p._radius / Math.cos(step / 2);
var i = 0;
while(i < p._N)
{
   var obj = new Object();
   var angle = i * step;
   obj.x = p._radius * Math.sin(angle);
   obj.y = (- p._radius) * Math.cos(angle);
   p._taP[i] = obj;
   var obj2 = new Object();
   var angle2 = step / 2 + (i - 1) * step;
   obj2.x = cRad * Math.sin(angle2);
   obj2.y = (- cRad) * Math.cos(angle2);
   p._tcP[i] = obj2;
   i++;
}
p.updateMask = function()
{
   var boxDirection = 1;
   if(this._phase < 3.141592653589793)
   {
      boxDirection = -1;
   }
   var boxSide = this._radius + this._margin;
   this._mask_mc.clear();
   this._mask_mc.moveTo(0,this._radius);
   this._mask_mc.beginFill(0,this._darkAlpha);
   this._mask_mc.lineTo(0,boxSide);
   this._mask_mc.lineTo(boxDirection * boxSide,boxSide);
   this._mask_mc.lineTo(boxDirection * boxSide,- boxSide);
   this._mask_mc.lineTo(0,- boxSide);
   this._mask_mc.lineTo(0,- this._radius);
   var cp = Math.cos(this.mod(this._phase,3.141592653589793));
   var i = 0;
   while(i < this._N)
   {
      this._mask_mc.curveTo(cp * this._tcP[i].x,this._tcP[i].y,cp * this._taP[i].x,this._taP[i].y);
      i++;
   }
   this._mask_mc.endFill();
};
p.mod = function(n, m)
{
   if(n < 0)
   {
      return n % m + m;
   }
   return n % m;
};
p.getLongitude = function()
{
   return this._long * 57.29577951308232;
};
p.setLongitude = function(arg)
{
   if(isFinite(arg))
   {
      this._long = this.mod(arg,360) * 0.017453292519943295;
      var frame = 1 + this.mod(Math.floor(this._long / this._stepSize),this._frames);
      this._sequence.gotoAndStop(frame);
   }
};
p.getDarkAlpha = function()
{
   return this._darkAlpha;
};
p.setDarkAlpha = function(arg)
{
   var tmp = Number(arg);
   if(isFinite(tmp))
   {
      this._darkAlpha = tmp;
      this.updateMask();
   }
};
p.getSunAngle = function()
{
   return this.mod(180 - this._phase * 57.29577951308232,360);
};
p.setSunAngle = function(arg)
{
   if(isFinite(arg))
   {
      this._phase = 0.017453292519943295 * this.mod(- arg + 180,360);
      this.updateMask();
   }
};
p.addProperty("longitude",p.getLongitude,p.setLongitude);
p.addProperty("darkAlpha",p.getDarkAlpha,p.setDarkAlpha);
p.addProperty("sunAngle",p.getSunAngle,p.setSunAngle);
