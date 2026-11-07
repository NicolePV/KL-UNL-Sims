Number.prototype.toFixed = function(fractionDigits)
{
   var _loc3_ = int(fractionDigits);
   if(_loc3_ < 0 || _loc3_ > 20)
   {
      return "Range Error";
   }
   var _loc7_ = this;
   if(isNaN(_loc7_))
   {
      return "NaN";
   }
   var _loc8_ = "";
   if(_loc7_ < 0)
   {
      _loc8_ = "-";
      _loc7_ = - _loc7_;
   }
   var _loc4_ = "";
   var _loc9_;
   var _loc5_;
   var _loc6_;
   var _loc2_;
   var _loc11_;
   var _loc10_;
   if(_loc7_ < 1e+21)
   {
      _loc9_ = Math.round(_loc7_ * Math.pow(10,_loc3_));
      if(_loc9_ == 0)
      {
         _loc4_ = "0";
      }
      else
      {
         _loc4_ = _loc9_.toString();
      }
      if(_loc3_ > 0)
      {
         _loc5_ = _loc4_.length;
         if(_loc5_ <= _loc3_)
         {
            _loc6_ = "";
            _loc2_ = 0;
            while(_loc2_ < _loc3_ + 1 - _loc5_)
            {
               _loc6_ += "0";
               _loc2_ = _loc2_ + 1;
            }
            _loc4_ = _loc6_ + _loc4_;
            _loc5_ = _loc3_ + 1;
         }
         _loc11_ = _loc4_.substr(0,_loc5_ - _loc3_);
         _loc10_ = _loc4_.substr(_loc5_ - _loc3_);
         _loc4_ = _loc11_ + "." + _loc10_;
      }
   }
   else
   {
      _loc4_ = _loc7_.toString();
   }
   return _loc8_ + _loc4_;
};
