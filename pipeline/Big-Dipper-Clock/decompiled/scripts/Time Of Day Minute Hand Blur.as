function TimeOfDayMinuteHandBlurClass()
{
   var _loc1_ = this.createEmptyMovieClip("blurMC",1);
   _loc1_._rotation = -90;
   mcMask = this.attachMovie("Time Of Day Minute Hand Steady Blur","maskMC",2);
   _loc1_.setMask(mcMask);
}
var p = TimeOfDayMinuteHandBlurClass.prototype = new MovieClip();
Object.registerClass("Time Of Day Minute Hand Blur",TimeOfDayMinuteHandBlurClass);
p.minStep = 0.06283185307179587;
p.maxN = 30;
p.minN = 10;
p.drawBlur = function(arg)
{
   arg *= 0.017453292519943295;
   var _loc2_ = Math.ceil(arg / this.minStep);
   if(_loc2_ < this.minN)
   {
      _loc2_ = this.minN;
   }
   else if(_loc2_ > this.maxN)
   {
      _loc2_ = this.maxN;
   }
   var step = arg / _loc2_;
   var _loc1_ = this.blurMC;
   _loc1_.clear();
   _loc1_.lineStyle(0,16711680,0);
   var _loc3_ = 209 / Math.cos(step / 2);
   var colors = [8421504,10526880];
   var ratios = [0,255];
   var matrix = {matrixType:"box",x:- _loc3_,y:- _loc3_,w:2 * _loc3_,h:2 * _loc3_,r:0};
   i = 0;
   while(i < _loc2_)
   {
      _loc1_.moveTo(0,0);
      var alphas = [70 * ((_loc2_ - i - 1) / _loc2_),30 * ((_loc2_ - i - 1) / _loc2_)];
      _loc1_.beginGradientFill("radial",colors,alphas,ratios,matrix);
      var a1 = i * step;
      _loc1_.lineTo(_loc3_ * Math.cos(a1),(- _loc3_) * Math.sin(a1));
      var a2 = (i + 1) * step;
      _loc1_.lineTo(_loc3_ * Math.cos(a2),(- _loc3_) * Math.sin(a2));
      _loc1_.lineTo(0,0);
      _loc1_.endFill();
      i++;
   }
};
