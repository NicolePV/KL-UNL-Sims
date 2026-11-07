function SphereClass()
{
   this.discColor = new Color(this.discMC);
}
var p = SphereClass.prototype = new MovieClip();
Object.registerClass("Sphere",SphereClass);
p.acceptObject = function(arg)
{
   this.discColor.setRGB(this.getColorFromTemp(arg.temp));
};
p.getColorFromTemp = function(temp)
{
   if(temp < 1000)
   {
      temp = 1000;
   }
   else if(temp > 40000)
   {
      temp = 40000;
   }
   var logT = Math.log(temp) / 2.302585092994046;
   var logT2 = logT * logT;
   var logT3 = logT * logT2;
   var r = 22686.34111 - logT * 15082.52755 + logT2 * 3375.333832 - logT3 * 252.4073853;
   if(r < 0)
   {
      r = 0;
   }
   else if(r > 255)
   {
      r = 255;
   }
   if(temp <= 6500)
   {
      var g = -811.6499145 + logT * 36.97365953 + logT2 * 160.7861677 - logT3 * 25.57573664;
   }
   else
   {
      var g = 13836.23586 - logT * 9069.078214 + logT2 * 2015.254756 - logT3 * 149.7766966;
   }
   var b = -11545.34298 + logT * 8529.658165 - logT2 * 2150.198586 + logT3 * 190.0306573;
   if(b < 0)
   {
      b = 0;
   }
   else if(b > 255)
   {
      b = 255;
   }
   return r << 16 | g << 8 | b;
};
