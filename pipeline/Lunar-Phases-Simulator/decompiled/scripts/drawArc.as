MovieClip.prototype.maxArcStep = 0.5;
MovieClip.prototype.drawArc = function(x, y, radius, startAngle, endAngle)
{
   if(startAngle < 0)
   {
      startAngle = startAngle % 6.283185307179586 + 6.283185307179586;
   }
   else
   {
      startAngle %= 6.283185307179586;
   }
   if(endAngle < 0)
   {
      endAngle = endAngle % 6.283185307179586 + 6.283185307179586;
   }
   else
   {
      endAngle %= 6.283185307179586;
   }
   var _loc14_ = endAngle - startAngle;
   if(_loc14_ < 0)
   {
      _loc14_ = 6.283185307179586 + _loc14_;
   }
   var _loc13_ = Math.ceil(_loc14_ / this.maxArcStep);
   var _loc8_ = _loc14_ / _loc13_;
   var _loc16_ = _loc8_ / 2;
   var _loc5_ = Math.cos;
   var _loc6_ = Math.sin;
   var _loc9_ = radius / _loc5_(_loc16_);
   var _loc4_ = startAngle;
   var _loc3_ = startAngle - _loc16_;
   this.moveTo(x + radius * _loc5_(startAngle),y - radius * _loc6_(startAngle));
   var _loc2_ = 0;
   while(_loc2_ < _loc13_)
   {
      _loc4_ += _loc8_;
      _loc3_ += _loc8_;
      this.curveTo(x + _loc9_ * _loc5_(_loc3_),y - _loc9_ * _loc6_(_loc3_),x + radius * _loc5_(_loc4_),y - radius * _loc6_(_loc4_));
      _loc2_ = _loc2_ + 1;
   }
};
