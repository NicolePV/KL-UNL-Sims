function MilkyWayComponentClass()
{
   var _loc1_ = this;
   _loc1_.createEmptyMovieClip("discMC",1);
   _loc1_.createEmptyMovieClip("discMaskMC",2);
   _loc1_.discMaskMC.moveTo(-175,-175);
   _loc1_.discMaskMC.beginFill(255,20);
   _loc1_.discMaskMC.lineTo(175,-175);
   _loc1_.discMaskMC.lineTo(175,175);
   _loc1_.discMaskMC.lineTo(-175,175);
   _loc1_.discMaskMC.lineTo(-175,-175);
   _loc1_.discMaskMC.endFill();
   _loc1_.discMC.setMask(_loc1_.discMaskMC);
   _loc1_.precomputePoints(12);
}
var p = MilkyWayComponentClass.prototype = new MovieClip();
Object.registerClass("Milky Way Component",MilkyWayComponentClass);
p.scale = 8.36;
p.setRadius = function(arg)
{
   this.drawDisc(arg * this.scale);
};
p.precomputePoints = function(numPoints)
{
   this.nP = numPoints;
   this.aP = [];
   this.cP = [];
   var step = 6.283185307179586 / this.nP;
   var halfStep = step / 2;
   var cRad = 1 / Math.cos(halfStep);
   var _loc1_ = 0;
   var _loc2_;
   var _loc3_;
   while(_loc1_ < this.nP)
   {
      var aPoint = {};
      _loc2_ = (_loc1_ + 1) * step;
      aPoint.x = Math.cos(_loc2_);
      aPoint.y = - Math.sin(_loc2_);
      this.aP[_loc1_] = aPoint;
      _loc3_ = {};
      var cAngle = _loc2_ - halfStep;
      _loc3_.x = cRad * Math.cos(cAngle);
      _loc3_.y = (- cRad) * Math.sin(cAngle);
      this.cP[_loc1_] = _loc3_;
      _loc1_ = _loc1_ + 1;
   }
   this.sP = {x:this.aP[this.nP - 1].x,y:this.aP[this.nP - 1].y};
};
p.drawDisc = function(radius)
{
   var _loc2_ = this;
   var _loc3_ = radius;
   trace("drawDisc: " + _loc3_);
   _loc2_.discMC.clear();
   _loc2_.discMC.lineStyle(1,16711680,100);
   _loc2_.discMC.moveTo(_loc3_ * _loc2_.sP.x,_loc3_ * _loc2_.sP.y);
   _loc2_.discMC.beginFill(16711680,20);
   var _loc1_ = 0;
   while(_loc1_ < _loc2_.nP)
   {
      _loc2_.discMC.curveTo(_loc3_ * _loc2_.cP[_loc1_].x,_loc3_ * _loc2_.cP[_loc1_].y,_loc3_ * _loc2_.aP[_loc1_].x,_loc3_ * _loc2_.aP[_loc1_].y);
      _loc1_ = _loc1_ + 1;
   }
   _loc2_.discMC.endFill();
};
