MovieClip.prototype.drawDashedLine = function(startX, startY, endX, endY, dashLength, gapLength)
{
   var dx = endX - startX;
   var dy = endY - startY;
   var length = Math.sqrt(dx * dx + dy * dy);
   var n = Math.round((length - dashLength) / (dashLength + gapLength));
   var f = dashLength / (dashLength + gapLength);
   var mx = dx / (n + f);
   var my = dy / (n + f);
   var lx = f * mx;
   var ly = f * my;
   var _loc1_ = 0;
   var _loc3_;
   var _loc2_;
   while(_loc1_ <= n)
   {
      _loc3_ = startX + _loc1_ * mx;
      _loc2_ = startY + _loc1_ * my;
      this.moveTo(_loc3_,_loc2_);
      this.lineTo(_loc3_ + lx,_loc2_ + ly);
      _loc1_ = _loc1_ + 1;
   }
};
