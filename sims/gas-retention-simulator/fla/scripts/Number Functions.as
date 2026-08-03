Number.prototype.toScientific = function(digits, useTags)
{
   var x = this;
   if(!isFinite(x) || isNaN(x))
   {
      return null;
   }
   if(x == 0)
   {
      var s = 0.toFixed(digits - 1);
      var m = 0;
   }
   else
   {
      if(x < 0)
      {
         var sign = "-";
         x = - x;
      }
      else
      {
         var sign = "";
      }
      var m = Math.floor(Math.log(x) / 2.302585092994046);
      var s = (x / Math.pow(10,m)).toFixed(digits - 1);
      if(s == "Range Error")
      {
         return null;
      }
      var ns = Number(s);
      if(ns >= 10)
      {
         s = (1).toFixed(digits - 1);
         m += 1;
      }
      s = sign + s;
   }
   if(useTags)
   {
      var str = s + "×10<sup>" + m + "</sup>";
   }
   else
   {
      var str = s + "e" + m;
   }
   var obj = {};
   obj.toString = function()
   {
      return str;
   };
   obj.string = str;
   obj.significand = s;
   obj.magnitude = m;
   return obj;
};
Number.prototype.toFixed = function(fractionDigits)
{
   var f = int(fractionDigits);
   if(f < 0 || f > 20)
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
   var m = "";
   if(x < 1e+21)
   {
      var n = Math.round(x * Math.pow(10,f));
      if(n == 0)
      {
         m = "0";
      }
      else
      {
         m = n.toString();
      }
      if(f > 0)
      {
         var k = m.length;
         if(k <= f)
         {
            var z = "";
            var i = 0;
            while(i < f + 1 - k)
            {
               z += "0";
               i++;
            }
            m = z + m;
            k = f + 1;
         }
         var a = m.substr(0,k - f);
         var b = m.substr(k - f);
         m = a + "." + b;
      }
   }
   else
   {
      m = x.toString();
   }
   return s + m;
};
