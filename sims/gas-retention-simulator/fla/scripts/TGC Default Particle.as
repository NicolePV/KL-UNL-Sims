function TGCDefaultParticleClass()
{
   this.colorObj = new Color(this);
   if(this.particleColor != undefined)
   {
      this.setColor(this.particleColor);
   }
   if(this.particleSize != undefined)
   {
      this.setSize(this.particleSize);
   }
}
var p = TGCDefaultParticleClass.prototype = new MovieClip();
Object.registerClass("TGC Default Particle",TGCDefaultParticleClass);
p.setSize = function(arg)
{
   this._xscale = this._yscale = 100 * (arg / 3);
};
p.setColor = function(arg)
{
   this.colorObj.setRGB(arg);
};
p.receiveObject = function(obj)
{
   if(obj.particleColor != undefined)
   {
      this.setColor(obj.particleColor);
   }
   if(obj.particleSize != undefined)
   {
      this.setSize(obj.particleSize);
   }
};
