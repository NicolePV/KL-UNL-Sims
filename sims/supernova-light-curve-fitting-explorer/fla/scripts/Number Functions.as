Number.prototype.toScientific = function(digits, useTags)
{
   var _loc3_ = this;
   if(!isFinite(_loc3_) || isNaN(_loc3_))
   {
      return null;
   }
   var _loc2_;
   var _loc5_;
   var _loc7_;
   var _loc8_;
   if(_loc3_ == 0)
   {
      _loc2_ = 0.toFixed(digits - 1);
      _loc5_ = 0;
   }
   else
   {
      if(_loc3_ < 0)
      {
         _loc7_ = "-";
         _loc3_ = - _loc3_;
      }
      else
      {
         _loc7_ = "";
      }
      _loc5_ = Math.floor(Math.log(_loc3_) / 2.302585092994046);
      _loc2_ = (_loc3_ / Math.pow(10,_loc5_)).toFixed(digits - 1);
      if(_loc2_ == "Range Error")
      {
         return null;
      }
      _loc8_ = Number(_loc2_);
      if(_loc8_ >= 10)
      {
         _loc2_ = (1).toFixed(digits - 1);
         _loc5_ += 1;
      }
      _loc2_ = _loc7_ + _loc2_;
   }
   if(useTags)
   {
      var str = _loc2_ + "×10<sup>" + _loc5_ + "</sup>";
   }
   else
   {
      var str = _loc2_ + "e" + _loc5_;
   }
   var _loc4_ = {};
   _loc4_.toString = function()
   {
      return str;
   };
   _loc4_.string = str;
   _loc4_.significand = _loc2_;
   _loc4_.magnitude = _loc5_;
   return _loc4_;
};
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
