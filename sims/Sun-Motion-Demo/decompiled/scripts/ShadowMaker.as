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
   var _loc7_ = pos.az - 180;
   var _loc8_ = 0;
   var _loc11_ = 100;
   var _loc10_ = 100 * Math.sin((pos.az - 90) * 0.017453292519943295) / Math.tan(0.017453292519943295 * pos.alt);
   this.inner._rotation = -45;
   var _loc6_ = _loc7_ * 0.017453292519943295;
   var _loc5_ = _loc8_ * 0.017453292519943295;
   var _loc4_ = Math.cos(_loc6_);
   var _loc9_ = Math.cos(_loc5_);
   this.outer._rotation = 45 + (_loc7_ + _loc8_) / 2;
   var _loc2_ = Math.sin(this.outer._rotation * 0.017453292519943295) * 0.707106781186547;
   if(!_loc2_)
   {
      _loc2_ = 1e-7;
   }
   this.outer._xscale = 100 * (Math.sin(_loc5_) + _loc4_) / _loc2_;
   this.outer._yscale = 100 * (Math.sin(_loc6_) + _loc9_) / _loc2_;
   this.inner._xscale = _loc11_ * 0.5 / _loc9_;
   this.inner._yscale = _loc10_ * 0.5 / _loc4_;
};
