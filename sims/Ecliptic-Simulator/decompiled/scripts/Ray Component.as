function RayComponentClass()
{
   this.drawRay();
}
var p = RayComponentClass.prototype = new MovieClip();
Object.registerClass("Ray Component",RayComponentClass);
p.drawRay = function()
{
   var _loc3_ = this.length;
   var _loc2_ = this.createEmptyMovieClip("rayMC",1);
   _loc2_.clear();
   _loc2_.lineStyle(1,10066329,50);
   _loc2_.moveTo(0,0);
   _loc2_.beginFill(16777164,85);
   _loc2_.lineTo(9,16);
   _loc2_.lineTo(2,12);
   _loc2_.lineTo(2,_loc3_);
   _loc2_.lineTo(-2,_loc3_);
   _loc2_.lineTo(-2,12);
   _loc2_.lineTo(-9,16);
   _loc2_.lineTo(0,0);
   _loc2_.endFill();
};
