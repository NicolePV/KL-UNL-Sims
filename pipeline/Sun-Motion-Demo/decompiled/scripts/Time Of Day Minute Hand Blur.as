function TimeOfDayMinuteHandBlurClass()
{
   var _loc2_ = this.createEmptyMovieClip("blurMC",1);
   _loc2_._rotation = -90;
   mcMask = this.attachMovie("Time Of Day Minute Hand Steady Blur","maskMC",2);
   _loc2_.setMask(mcMask);
}
var p = TimeOfDayMinuteHandBlurClass.prototype = new MovieClip();
Object.registerClass("Time Of Day Minute Hand Blur",TimeOfDayMinuteHandBlurClass);
p.minStep = 0.06283185307179587;
p.maxN = 30;
p.minN = 10;
p.drawBlur = function(arg)
{
   arg *= 0.017453292519943295;
   var _loc3_ = Math.ceil(arg / this.minStep);
   if(_loc3_ < this.minN)
   {
      _loc3_ = this.minN;
   }
   else if(_loc3_ > this.maxN)
   {
      _loc3_ = this.maxN;
   }
   var _loc8_ = arg / _loc3_;
   var _loc2_ = this.blurMC;
   _loc2_.clear();
   _loc2_.lineStyle(0,16711680,0);
   var _loc4_ = 209 / Math.cos(_loc8_ / 2);
   var _loc10_ = [8421504,10526880];
   var _loc11_ = [0,255];
   var _loc9_ = {matrixType:"box",x:- _loc4_,y:- _loc4_,w:2 * _loc4_,h:2 * _loc4_,r:0};
   i = 0;
   var _loc7_;
   var _loc6_;
   var _loc5_;
   while(i < _loc3_)
   {
      _loc2_.moveTo(0,0);
      _loc7_ = [70 * ((_loc3_ - i - 1) / _loc3_),30 * ((_loc3_ - i - 1) / _loc3_)];
      _loc2_.beginGradientFill("radial",_loc10_,_loc7_,_loc11_,_loc9_);
      _loc6_ = i * _loc8_;
      _loc2_.lineTo(_loc4_ * Math.cos(_loc6_),(- _loc4_) * Math.sin(_loc6_));
      _loc5_ = (i + 1) * _loc8_;
      _loc2_.lineTo(_loc4_ * Math.cos(_loc5_),(- _loc4_) * Math.sin(_loc5_));
      _loc2_.lineTo(0,0);
      _loc2_.endFill();
      i++;
   }
};
