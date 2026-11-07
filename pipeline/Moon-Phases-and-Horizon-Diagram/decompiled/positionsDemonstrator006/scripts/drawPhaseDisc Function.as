MovieClip.prototype.drawPhaseDisc = function(definition, optionsObj)
{
   if(typeof definition == "number")
   {
      var phaseAngle = definition * 3.141592653589793 / 180;
   }
   else if(typeof definition == "object")
   {
      var x1 = definition.x1 - definition.x0;
      var y1 = definition.y1 - definition.y0;
      var x2 = definition.x2 - definition.x0;
      var y2 = definition.y2 - definition.y0;
      var r1 = Math.sqrt(x1 * x1 + y1 * y1);
      var r2 = Math.sqrt(x2 * x2 + y2 * y2);
      var angle1 = Math.atan2(y1,x1);
      var angle2 = Math.atan2(y2,x2);
      var theta = 6.283185307179586 * (((angle2 - angle1) / 6.283185307179586 % 1 + 1) % 1);
      var cosTheta = Math.cos(theta);
      var d = Math.sqrt(r1 * r1 + r2 * r2 - 2 * r1 * r2 * cosTheta);
      var cosBeta = (r2 - r1 * cosTheta) / d;
      if(cosBeta > 1)
      {
         cosBeta = 1;
      }
      else if(cosBeta < -1)
      {
         cosBeta = -1;
      }
      var beta = Math.acos(cosBeta);
      if(theta < 3.141592653589793)
      {
         var phaseAngle = beta;
      }
      else
      {
         var phaseAngle = 6.283185307179586 - beta;
      }
   }
   var radius = 70;
   var lightColor = 14737632;
   var darkColor = 4210752;
   var x = 0;
   var y = 0;
   var lineThickness = 1;
   var lineColor = 2105376;
   var lineAlpha = 0;
   var doClear = true;
   if(typeof optionsObj.radius == "number")
   {
      radius = optionsObj.radius;
   }
   if(typeof optionsObj.lightColor == "number")
   {
      lightColor = optionsObj.lightColor;
   }
   if(typeof optionsObj.darkColor == "number")
   {
      darkColor = optionsObj.darkColor;
   }
   if(typeof optionsObj.x == "number")
   {
      x = optionsObj.x;
   }
   if(typeof optionsObj.y == "number")
   {
      y = optionsObj.y;
   }
   if(typeof optionsObj.lineThickness == "number")
   {
      lineThickness = optionsObj.lineThickness;
   }
   if(typeof optionsObj.lineColor == "number")
   {
      lineColor = optionsObj.lineColor;
   }
   if(typeof optionsObj.lineAlpha == "number")
   {
      lineAlpha = optionsObj.lineAlpha;
   }
   if(optionsObj.doClear != undefined)
   {
      doClear = optionsObj.doClear;
   }
   if(doClear)
   {
      this.clear();
   }
   if(typeof phaseAngle != "number" || isNaN(phaseAngle) || !isFinite(phaseAngle))
   {
      trace("hey, angle not valid in drawPhaseDisc");
      return undefined;
   }
   phaseAngle = (phaseAngle % 6.283185307179586 + 6.283185307179586) % 6.283185307179586;
   if(phaseAngle < 3.141592653589793)
   {
      var f = -1;
   }
   else
   {
      var f = 1;
   }
   var sin = Math.sin;
   var cos = Math.cos;
   var n = 4;
   var r = radius;
   var s = r * cos(phaseAngle);
   var step = 3.141592653589793 / n;
   var halfStep = step / 2;
   var kr = r / cos(halfStep);
   var ks = s / cos(halfStep);
   this.lineStyle(lineThickness,lineColor,lineAlpha);
   this.moveTo(x,y - r);
   this.beginFill(darkColor,100);
   var i = 1;
   while(i <= n)
   {
      var angle = i * step;
      var ax = r * sin(angle);
      var ay = (- r) * cos(angle);
      var cAngle = angle - halfStep;
      var cx = kr * sin(cAngle);
      var cy = (- kr) * cos(cAngle);
      this.curveTo(x + f * cx,y + cy,x + f * ax,y + ay);
      i++;
   }
   var i = n - 1;
   while(i >= 0)
   {
      var angle = i * step;
      var ax = s * sin(angle);
      var ay = (- r) * cos(angle);
      var cAngle = angle + halfStep;
      var cx = ks * sin(cAngle);
      var cy = (- kr) * cos(cAngle);
      this.curveTo(x + f * cx,y + cy,x + f * ax,y + ay);
      i--;
   }
   this.endFill();
   this.moveTo(x,y - r);
   this.beginFill(lightColor,100);
   var i = 1;
   while(i <= n)
   {
      var angle = i * step;
      var ax = (- r) * sin(angle);
      var ay = (- r) * cos(angle);
      var cAngle = angle - halfStep;
      var cx = (- kr) * sin(cAngle);
      var cy = (- kr) * cos(cAngle);
      this.curveTo(x + f * cx,y + cy,x + f * ax,y + ay);
      i++;
   }
   var i = n - 1;
   while(i >= 0)
   {
      var angle = i * step;
      var ax = s * sin(angle);
      var ay = (- r) * cos(angle);
      var cAngle = angle + halfStep;
      var cx = ks * sin(cAngle);
      var cy = (- kr) * cos(cAngle);
      this.curveTo(x + f * cx,y + cy,x + f * ax,y + ay);
      i--;
   }
   this.endFill();
   return phaseAngle * 180 / 3.141592653589793;
};
