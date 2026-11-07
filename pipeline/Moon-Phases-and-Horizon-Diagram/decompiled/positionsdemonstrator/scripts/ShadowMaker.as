function ShadowMakerClass()
{
   var _loc1_ = this;
   _loc1_.createEmptyMovieClip("outer",1);
   _loc1_.inner = _loc1_.outer.attachMovie(_loc1_.shadowClip,"shadow",1);
   _loc1_.setSourcePosition({alt:45,az:180});
}
var p = ShadowMakerClass.prototype = new MovieClip();
Object.registerClass("ShadowMaker",ShadowMakerClass);
p.lengthLimit = 15;
p.setSourcePosition = function(pos)
{
   var _loc1_ = this;
   var _loc3_ = pos;
   var _loc2_;
   if(_loc3_.alt < 0.1)
   {
      _loc1_.inner._visible = false;
   }
   else
   {
      _loc1_.inner._visible = true;
      _loc1_.inner._alpha = 100 - 100 / (_loc1_.lengthLimit * Math.tan(_loc3_.alt * 0.017453292519943295));
      if(_loc1_.inner._alpha > 0)
      {
         var xskew = _loc3_.az - 180;
         var yskew = 0;
         var base_xscale = 100;
         var base_yscale = 100 * Math.sin((_loc3_.az - 90) * 0.017453292519943295) / Math.tan(0.017453292519943295 * _loc3_.alt);
         _loc1_.inner._rotation = -45;
         var xr = xskew * 0.017453292519943295;
         var yr = yskew * 0.017453292519943295;
         var cosxr = Math.cos(xr);
         var cosyr = Math.cos(yr);
         _loc1_.outer._rotation = 45 + (xskew + yskew) / 2;
         _loc2_ = Math.sin(_loc1_.outer._rotation * 0.017453292519943295) * 0.707106781186547;
         if(!_loc2_)
         {
            _loc2_ = 1e-7;
         }
         _loc1_.outer._xscale = 100 * (Math.sin(yr) + cosxr) / _loc2_;
         _loc1_.outer._yscale = 100 * (Math.sin(xr) + cosyr) / _loc2_;
         _loc1_.inner._xscale = base_xscale * 0.5 / cosyr;
         _loc1_.inner._yscale = base_yscale * 0.5 / cosxr;
      }
   }
};
