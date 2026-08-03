function update()
{
   var m1 = mass1Slider.value;
   var m2 = mass2Slider.value;
   containerMC.mass1MC._xscale = containerMC.mass1MC._yscale = 100 * Math.pow(m1,0.37);
   containerMC.mass2MC._xscale = containerMC.mass2MC._yscale = 100 * Math.pow(m2,0.37);
   var x1 = (- pixelSeparation) * m2 / (m1 + m2);
   var x2 = (- x1) * m1 / m2;
   containerMC.mass1MC._x = x1;
   containerMC.mass2MC._x = x2;
   containerMC.massLabel1._x = x1;
   containerMC.massLabel2._x = x2;
   var mc = containerMC.linesMC;
   mc.clear();
   mc.lineStyle(1,26367,100);
   mc.moveTo(x1,0);
   mc.lineTo(0,0);
   mc.lineStyle(1,16711680,100);
   mc.moveTo(0,0);
   mc.lineTo(x2,0);
   var factor = separationSlider.value / (m1 + m2);
   mc.label1.labelField.text = (m2 * factor).toFixed(2);
   mc.label1._x = x1 / 2 - (mc.label1.labelField.textWidth + mc.label1.labelField._x) / 2;
   mc.label2.labelField.text = (m1 * factor).toFixed(2);
   mc.label2._x = x2 / 2 - (mc.label2.labelField.textWidth + mc.label2.labelField._x) / 2;
   mc.left1MC._x = x1;
   mc.right1MC._x = 0;
   mc.left2MC._x = 0;
   mc.right2MC._x = x2;
   var scale1 = 100 * Math.sqrt((- x1) / pixelSeparation);
   mc.left1MC._xscale = mc.left1MC._yscale = mc.right1MC._xscale = mc.right1MC._yscale = scale1;
   var scale2 = 100 * Math.sqrt(x2 / pixelSeparation);
   mc.left2MC._xscale = mc.left2MC._yscale = mc.right2MC._xscale = mc.right2MC._yscale = scale2;
   var mc = gridMC;
   mc.clear();
   mc.lineStyle(1,14737632,100);
   var gridSpacing = pixelSeparation / separationSlider.value;
   var k = Math.floor(gridHalfWidth / gridSpacing);
   var i = - k;
   while(i <= k)
   {
      mc.moveTo(i * gridSpacing,gridHalfHeight);
      mc.lineTo(i * gridSpacing,- gridHalfHeight);
      i++;
   }
   var k = Math.floor(gridHalfHeight / gridSpacing);
   var i = - k;
   while(i <= k)
   {
      mc.moveTo(- gridHalfWidth,i * gridSpacing);
      mc.lineTo(gridHalfWidth,i * gridSpacing);
      i++;
   }
   if(fixCMCheck.getValue())
   {
      containerMC._x = 0;
   }
   else
   {
      containerMC._x = - (x1 + pixelSeparation / 2);
   }
}
pixelSeparation = 200;
gridWidth = 420;
gridHeight = 160;
gridHalfWidth = gridWidth / 2;
gridHalfHeight = gridHeight / 2;
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
update();
