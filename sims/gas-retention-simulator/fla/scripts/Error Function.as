Math.erf = function(x)
{
   return x >= 0 ? Math.gammp(0.5,x * x) : - Math.gammp(0.5,x * x);
};
Math.gammp = function(a, x)
{
   if(x < 0 || a <= 0)
   {
      trace("*** warning, invalid arguments in gammp ***");
      return 0;
   }
   if(x < a + 1)
   {
      return Math.gser(a,x);
   }
   return 1 - Math.gcf(a,x);
};
Math.gammln = function(xx)
{
   var cof = [76.18009172947146,-86.50532032941678,24.01409824083091,-1.231739572450155,0.001208650973866179,-0.000005395239384953];
   var y = x = xx;
   var tmp = x + 5.5;
   tmp -= (x + 0.5) * Math.log(tmp);
   var ser = 1.000000000190015;
   var j = 0;
   while(j <= 5)
   {
      ser += cof[j] / ++y;
      j++;
   }
   return - tmp + Math.log(2.5066282746310007 * ser / x);
};
Math.gser = function(a, x)
{
   var itmax = 100;
   var eps = 3e-7;
   var gln = Math.gammln(a);
   if(x <= 0)
   {
      if(x < 0)
      {
         trace("*** warning, x < 0 in gser ***");
      }
      return 0;
   }
   var ap = a;
   var del = sum = 1 / a;
   var n = 1;
   while(n <= itmax)
   {
      ap++;
      del *= x / ap;
      sum += del;
      if(Math.abs(del) < Math.abs(sum) * eps)
      {
         return sum * Math.exp(- x + a * Math.log(x) - gln);
      }
      n++;
   }
   trace("*** warning, a too large, itmax too small in gser ***");
   return 0;
};
Math.gcf = function(a, x)
{
   var itmax = 100;
   var eps = 3e-7;
   var fpmin = 1e-30;
   var gln = Math.gammln(a);
   var b = x + 1 - a;
   var c = 1 / fpmin;
   var d = 1 / b;
   var h = d;
   var i = 1;
   while(i <= itmax)
   {
      var an = (- i) * (i - a);
      b += 2;
      d = an * d + b;
      if(Math.abs(d) < fpmin)
      {
         d = fpmin;
      }
      c = b + an / c;
      if(Math.abs(c) < fpmin)
      {
         c = fpmin;
      }
      d = 1 / d;
      var del = d * c;
      h *= del;
      if(Math.abs(del - 1) < eps)
      {
         break;
      }
      i++;
   }
   if(i > itmax)
   {
      trace("*** warning, a too large, itmax too small in gcf ***");
   }
   return Math.exp(- x + a * Math.log(x) - gln) * h;
};
