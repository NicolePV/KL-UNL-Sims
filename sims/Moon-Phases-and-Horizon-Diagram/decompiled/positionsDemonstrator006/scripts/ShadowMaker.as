function ShadowMakerClass()
{
   this.createEmptyMovieClip("outer",1);
   this.inner = this.outer.attachMovie(this.shadowClip,"shadow",1);
   this.setSourcePosition({alt:45,az:180});
}
var p = ShadowMakerClass.prototype = new MovieClip();
Object.registerClass("ShadowMaker",ShadowMakerClass);
p.lengthLimit = 15;
p.setSourcePosition = function(pos)
{
   if(pos.alt < 0.1)
   {
      this.inner._visible = false;
      return undefined;
   }
   this.inner._visible = true;
   this.inner._alpha = 100 - 100 / (this.lengthLimit * Math.tan(pos.alt * 0.017453292519943295));
   if(this.inner._alpha <= 0)
   {
      return undefined;
   }
   var xskew = pos.az - 180;
   var yskew = 0;
   var base_xscale = 100;
   var base_yscale = 100 * Math.sin((pos.az - 90) * 0.017453292519943295) / Math.tan(0.017453292519943295 * pos.alt);
   this.inner._rotation = -45;
   var xr = xskew * 0.017453292519943295;
   var yr = yskew * 0.017453292519943295;
   var cosxr = Math.cos(xr);
   var cosyr = Math.cos(yr);
   this.outer._rotation = 45 + (xskew + yskew) / 2;
   var div = Math.sin(this.outer._rotation * 0.017453292519943295) * 0.707106781186547;
   if(!div)
   {
      div = 1e-7;
   }
   this.outer._xscale = 100 * (Math.sin(yr) + cosxr) / div;
   this.outer._yscale = 100 * (Math.sin(xr) + cosyr) / div;
   this.inner._xscale = base_xscale * 0.5 / cosyr;
   this.inner._yscale = base_yscale * 0.5 / cosxr;
};
