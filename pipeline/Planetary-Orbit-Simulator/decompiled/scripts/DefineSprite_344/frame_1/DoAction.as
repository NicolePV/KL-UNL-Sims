function toThreeSigDigs(arg)
{
   var _loc1_ = arg;
   if(_loc1_ >= 1000)
   {
      return String(Math.toSigDigits(_loc1_,3));
   }
   if(_loc1_ >= 100)
   {
      return Math.round(_loc1_);
   }
   if(_loc1_ == 0)
   {
      return "0.00";
   }
   return _loc1_.toFixed(2 - Math.floor(Math.log(Math.abs(_loc1_)) / 2.302585092994046));
}
Number.prototype.toFixed = function(fractionDigits)
{
   var _loc2_ = int(fractionDigits);
   if(_loc2_ < 0 || _loc2_ > 20)
   {
      return "Range Error";
   }
   var x = this;
   if(isNaN(x))
   {
      return "NaN";
   }
   var s = "";
   if(x < 0)
   {
      s = "-";
      x = - x;
   }
   var _loc3_ = "";
   var _loc1_;
   if(x < 1e+21)
   {
      var n = Math.round(x * Math.pow(10,_loc2_));
      if(n == 0)
      {
         _loc3_ = "0";
      }
      else
      {
         _loc3_ = n.toString();
      }
      if(_loc2_ > 0)
      {
         var k = _loc3_.length;
         if(k <= _loc2_)
         {
            var z = "";
            _loc1_ = 0;
            while(_loc1_ < _loc2_ + 1 - k)
            {
               z += "0";
               _loc1_ = _loc1_ + 1;
            }
            _loc3_ = z + _loc3_;
            k = _loc2_ + 1;
         }
         var a = _loc3_.substr(0,k - _loc2_);
         var b = _loc3_.substr(k - _loc2_);
         _loc3_ = a + "." + b;
      }
   }
   else
   {
      _loc3_ = x.toString();
   }
   return s + _loc3_;
};
Math.toSigDigits = function()
{
   var _loc1_ = parseFloat(arguments[0]);
   var _loc2_ = Math.abs(parseInt(arguments[1]));
   if(!isFinite(_loc2_) || !isFinite(_loc1_))
   {
      return NaN;
   }
   if(_loc1_ == 0 || _loc2_ == 0)
   {
      return 0;
   }
   if(_loc2_ > 15)
   {
      _loc2_ = 15;
   }
   var _loc3_ = 1;
   if(_loc1_ < 0)
   {
      _loc3_ = -1;
      _loc1_ = Math.abs(_loc1_);
   }
   var tmp = Math.floor(Math.log(_loc1_) / 2.302585092994046);
   var fact = Math.pow(10,_loc2_ - (1 + tmp));
   var num2 = Math.round(fact * _loc1_) / fact;
   return _loc3_ * num2;
};
