function TangentPlaneClass()
{
   this.stop();
}
var p = TangentPlaneClass.prototype = new MovieClip();
Object.registerClass("Tangent Plane",TangentPlaneClass);
p.update = function(arg)
{
   this._xscale = this._yscale = this._sphere.size * (1 - arg) / 2;
   this._alpha = 40 + 0.6 * this._xscale;
   if(this._object._sp.z >= 0)
   {
      this.gotoAndStop(1);
   }
   else
   {
      this.gotoAndStop(2);
   }
};
