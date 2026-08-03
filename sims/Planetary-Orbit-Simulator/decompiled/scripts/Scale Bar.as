function ScaleBarClass()
{
}
var p = ScaleBarClass.prototype = new MovieClip();
Object.registerClass("Scale Bar",ScaleBarClass);
p.barHeight = 5;
p.barColor = 16777215;
p.update = function(barWidth, label)
{
   var _loc1_ = this;
   var _loc2_ = barWidth;
   _loc1_.clear();
   _loc1_.moveTo((- _loc2_) / 2,0);
   _loc1_.beginFill(_loc1_.barColor);
   _loc1_.lineTo(_loc2_ / 2,0);
   _loc1_.lineTo(_loc2_ / 2,_loc1_.barHeight);
   _loc1_.lineTo((- _loc2_) / 2,_loc1_.barHeight);
   _loc1_.lineTo((- _loc2_) / 2,0);
   _loc1_.endFill();
   _loc1_.labelField.text = label;
};
