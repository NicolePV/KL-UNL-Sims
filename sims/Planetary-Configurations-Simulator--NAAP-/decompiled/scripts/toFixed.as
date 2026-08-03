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
