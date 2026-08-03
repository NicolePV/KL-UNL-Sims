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
Math.toScientific = function()
{
   var num = parseFloat(arguments[0]);
   var digs = Math.abs(parseInt(arguments[1]));
   if(!isFinite(digs))
   {
      digs = 4;
   }
   else
   {
      if(digs == 0)
      {
         return "0";
      }
      if(digs > 15)
      {
         digs = 15;
      }
   }
   if(!isFinite(num))
   {
      return "<error>";
   }
   var _loc1_;
   var _loc3_;
   if(num == 0)
   {
      _loc1_ = "0";
      var extra_zeros = digs - 1;
      if(extra_zeros != 0)
      {
         _loc1_ += ".";
         _loc3_ = 0;
         while(_loc3_ < extra_zeros)
         {
            _loc1_ += "0";
            _loc3_ = _loc3_ + 1;
         }
      }
      return _loc1_;
   }
   var sign = 1;
   if(num < 0)
   {
      sign = -1;
      num = Math.abs(num);
   }
   var expo = Math.floor(Math.log(num) / 2.302585092994046);
   var expo_fact = Math.pow(10,- expo);
   var fact = Math.pow(10,digs - 1);
   var num2 = Math.round(fact * expo_fact * num) / fact;
   if(num2 >= 10)
   {
      num2 /= 10;
      expo++;
   }
   _loc1_ = String(num2);
   var dot = _loc1_.indexOf(".");
   var add_dot = false;
   if(dot == -1)
   {
      add_dot = true;
   }
   var sigfigs = 0;
   _loc3_ = 0;
   var _loc2_;
   while(_loc3_ < _loc1_.length)
   {
      _loc2_ = _loc1_.charCodeAt(_loc3_);
      if(_loc2_ > 47 && _loc2_ < 58)
      {
         sigfigs++;
      }
      _loc3_ = _loc3_ + 1;
   }
   var num_zeros = digs - sigfigs;
   if(num_zeros > 0 && add_dot == true)
   {
      _loc1_ += ".";
   }
   _loc3_ = 0;
   while(_loc3_ < num_zeros)
   {
      _loc1_ += "0";
      _loc3_ = _loc3_ + 1;
   }
   if(expo > 0)
   {
      _loc1_ += "e+" + String(expo);
   }
   else if(expo < 0)
   {
      _loc1_ += "e" + String(expo);
   }
   if(sign == -1)
   {
      _loc1_ = "-" + _loc1_;
   }
   return _loc1_;
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
