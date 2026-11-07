MovieClip.prototype.drawDashedLine = function(startX, startY, endX, endY, dashLength, gapLength)
{
   var _loc14_ = endX - startX;
   var _loc13_ = endY - startY;
   var _loc16_ = Math.sqrt(_loc14_ * _loc14_ + _loc13_ * _loc13_);
   var _loc5_ = Math.round((_loc16_ - dashLength) / (dashLength + gapLength));
   var _loc12_ = dashLength / (dashLength + gapLength);
   var _loc7_ = _loc14_ / (_loc5_ + _loc12_);
   var _loc6_ = _loc13_ / (_loc5_ + _loc12_);
   var _loc9_ = _loc12_ * _loc7_;
   var _loc8_ = _loc12_ * _loc6_;
   var _loc2_ = 0;
   var _loc4_;
   var _loc3_;
   while(_loc2_ <= _loc5_)
   {
      _loc4_ = startX + _loc2_ * _loc7_;
      _loc3_ = startY + _loc2_ * _loc6_;
      this.moveTo(_loc4_,_loc3_);
      this.lineTo(_loc4_ + _loc9_,_loc3_ + _loc8_);
      _loc2_ = _loc2_ + 1;
   }
};
