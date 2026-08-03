function GRPGasClass()
{
   if(this.initVisible != undefined)
   {
      this.setVisible(this.initVisible);
   }
   if(this.initShowShading != undefined)
   {
      this.setShowShading(this.initShowShading);
   }
   this.createEmptyMovieClip("shadingMC",10);
   this.createEmptyMovieClip("lineMC",20);
   if(typeof this.mass != "number" || isNaN(this.mass) || !isFinite(this.mass) || this.mass <= 0)
   {
      this.mass = null;
   }
   this.update();
}
var p = GRPGasClass.prototype = new MovieClip();
Object.registerClass("GRP Gas",GRPGasClass);
p.shadingColor = 255;
p.shadingAlpha = 20;
p.update = function()
{
   if(this.mass == null)
   {
      return undefined;
   }
   var k = 1.3806503e-23;
   var m = this.mass * 1.66053886e-27;
   this._parent._parent._minTemp;
   var v1 = Math.sqrt(3 * k * this._parent._parent._minTemp / m) / 1000;
   var v2 = Math.sqrt(3 * k * this._parent._parent._maxTemp / m) / 1000;
   var w = this._parent._parent._plotWidth;
   var h = this._parent._parent._plotHeight;
   var y1 = this._parent._parent.getY(6 * v1);
   var y2 = this._parent._parent.getY(6 * v2);
   var y3 = this._parent._parent.getY(10 * v2);
   var y4 = this._parent._parent.getY(10 * v1);
   var theta = Math.atan2(Math.abs(y2 - y1),w);
   var cos = Math.cos(1.5707963267948966 - theta);
   var sin = Math.sin(1.5707963267948966 - theta);
   var sx = (y1 - y4) * Math.sin(1.5707963267948966 - theta);
   var sy = 100;
   var tx = w / 2;
   var ty = y1 + (y3 - y1) / 2;
   var color1 = this.shadingColor;
   var alpha1 = this.shadingAlpha;
   var color2 = color1;
   var alpha2 = 0;
   var colors = [color1,color2];
   var alphas = [alpha1,alpha2];
   var ratios = [0,255];
   var matrix = {};
   matrix.a = sx * cos;
   matrix.b = sx * sin;
   matrix.c = 0;
   matrix.d = (- sy) * sin;
   matrix.e = sy * cos;
   matrix.f = 0;
   matrix.g = tx;
   matrix.h = ty;
   matrix.i = 1;
   this.shadingMC.clear();
   this.shadingMC.lineStyle();
   this.shadingMC.moveTo(0,y1);
   this.shadingMC.beginGradientFill("linear",colors,alphas,ratios,matrix);
   this.shadingMC.lineTo(w,y2);
   this.shadingMC.lineTo(w,y3);
   this.shadingMC.lineTo(0,y4);
   this.shadingMC.lineTo(0,y1);
   this.shadingMC.endFill();
   if(y3 < - h)
   {
      this.shadingMC.moveTo(0,y4);
      this.shadingMC.beginFill(color1,alpha1);
      this.shadingMC.lineTo(w,y3);
      this.shadingMC.lineTo(0,y3);
      this.shadingMC.lineTo(0,y4);
      this.shadingMC.endFill();
   }
   else
   {
      this.shadingMC.moveTo(0,y4);
      this.shadingMC.beginFill(color1,alpha1);
      this.shadingMC.lineTo(w,y3);
      this.shadingMC.lineTo(w,- h);
      this.shadingMC.lineTo(0,- h);
      this.shadingMC.lineTo(0,y4);
      this.shadingMC.endFill();
   }
   this.lineMC.clear();
   this.lineMC.lineStyle(2,9474192,100);
   this.drawDashedLine.call(this.lineMC,0,y4,w,y3,4,8);
   if(typeof this.labelText == "string")
   {
      this.displayText(this.labelText,{mc:this.labelMC,depth:10,x:w + 5,y:y3,vAlign:"center",hAlign:"left",embedFonts:true,sizeRatio:1.25,textFormat:this._parent._parent.gasLabelTextFormat});
   }
};
p.setMass = function(arg)
{
   this.mass = arg;
   this.update();
};
p.setShowShading = function(arg)
{
   this.shadingMC._visible = arg;
};
p.getVisible = function()
{
   return this._visible;
};
p.setVisible = function(arg)
{
   this._visible = arg;
   this.labelMC._visible = arg;
};
p.addProperty("visible",p.getVisible,p.setVisible);
p.drawDashedLine = function(startX, startY, endX, endY, dashLength, gapLength)
{
   var dx = endX - startX;
   var dy = endY - startY;
   var length = Math.sqrt(dx * dx + dy * dy);
   var n = Math.round((length - dashLength) / (dashLength + gapLength));
   var f = dashLength / (dashLength + gapLength);
   var mx = dx / (n + f);
   var my = dy / (n + f);
   var lx = f * mx;
   var ly = f * my;
   var i = 0;
   while(i <= n)
   {
      var x = startX + i * mx;
      var y = startY + i * my;
      this.moveTo(x,y);
      this.lineTo(x + lx,y + ly);
      i++;
   }
};
p.displayText = function(textString, options)
{
   textString = String(textString);
   if(options.depth != undefined)
   {
      var mcDepth = options.depth;
   }
   else if(_global._displayedTextLastDepthUsed != undefined)
   {
      var mcDepth = ++_global._displayedTextLastDepthUsed;
   }
   else
   {
      var mcDepth = _global._displayedTextLastDepthUsed = 913001;
   }
   if(options.name != undefined)
   {
      var mcName = options.name;
   }
   else
   {
      var mcName = "_textWrapper_" + mcDepth;
   }
   if(options.mc != undefined)
   {
      var mc = options.mc.createEmptyMovieClip(mcName,mcDepth);
   }
   else
   {
      var mc = this.createEmptyMovieClip(mcName,mcDepth);
   }
   if(options.x != undefined)
   {
      mc._x = options.x;
   }
   if(options.y != undefined)
   {
      mc._y = options.y;
   }
   if(options.embedFonts != undefined)
   {
      var embedFonts = options.embedFonts;
   }
   else
   {
      var embedFonts = false;
   }
   if(options.textFormat != undefined)
   {
      var normalFormat = options.textFormat;
   }
   else
   {
      var normalFormat = new TextFormat(null,12);
   }
   var scriptFormat = new TextFormat();
   for(var x in normalFormat)
   {
      scriptFormat[x] = normalFormat[x];
   }
   if(options.sizeRatio != undefined)
   {
      scriptFormat.size = normalFormat.size / options.sizeRatio;
   }
   else
   {
      scriptFormat.size = normalFormat.size / 1.5;
   }
   mc.createTextField("_0",0,0,0,0,0);
   mc._0.autoSize = "left";
   mc._0.embedFonts = embedFonts;
   mc._0.setNewTextFormat(normalFormat);
   mc._0.text = "X";
   mc._0._visible = false;
   mc.createTextField("_1",1,0,0,0,0);
   mc._1.autoSize = "left";
   mc._1.embedFonts = embedFonts;
   mc._1.setNewTextFormat(scriptFormat);
   mc._1.text = "X";
   mc._1._visible = false;
   var lineHeight = mc._0._height;
   var scriptHeight = mc._1._height;
   if(options.superscriptPosition != undefined)
   {
      var superscriptDelta = - options.superscriptPosition;
   }
   else
   {
      var superscriptDelta = 0;
   }
   if(options.subscriptPosition != undefined)
   {
      var subscriptDelta = lineHeight - scriptHeight + options.subscriptPosition;
   }
   else
   {
      var subscriptDelta = lineHeight - scriptHeight;
   }
   if(options.extraSpacing != undefined)
   {
      var extraSpacing = options.extraSpacing;
   }
   else
   {
      var extraSpacing = 0.5;
   }
   var aL = [];
   var pos = 0;
   var iLimit = 0;
   var startInd = 0;
   do
   {
      var ind = textString.indexOf("<su",startInd);
      if(ind == -1)
      {
         aL.push({pos:pos,str:textString});
      }
      else if(textString.charAt(ind + 3) == "b" && textString.charAt(ind + 4) == ">")
      {
         if(ind != 0)
         {
            aL.push({pos:pos,str:textString.substring(0,ind)});
         }
         textString = textString.slice(ind + 5);
         pos = -1;
         var ind2 = textString.indexOf("</sub>");
         if(ind2 != -1)
         {
            if(ind2 != 0)
            {
               aL.push({pos:pos,str:textString.substring(0,ind2)});
            }
            textString = textString.slice(ind2 + 6);
            pos = 0;
         }
         startInd = 0;
      }
      else if(textString.charAt(ind + 3) == "p" && textString.charAt(ind + 4) == ">")
      {
         if(ind != 0)
         {
            aL.push({pos:pos,str:textString.substring(0,ind)});
         }
         textString = textString.slice(ind + 5);
         pos = 1;
         var ind2 = textString.indexOf("</sup>");
         if(ind2 != -1)
         {
            if(ind2 != 0)
            {
               aL.push({pos:pos,str:textString.substring(0,ind2)});
            }
            textString = textString.slice(ind2 + 6);
            pos = 0;
         }
         startInd = 0;
      }
      else
      {
         startInd = ind + 3;
      }
      iLimit++;
   }
   while(ind != -1 && textString.length > 0 && iLimit < 100);
   if(iLimit >= 100)
   {
      trace("WARNING: iteration limit reached");
   }
   var tL = [];
   var totalWidth = 0;
   var depth = 2;
   var i = 0;
   while(i < aL.length)
   {
      var name = "_" + depth;
      mc.createTextField(name,depth++,0,0,0,0);
      var tf = mc[name];
      tf.autoSize = "left";
      tf.embedFonts = embedFonts;
      tf.selectable = false;
      if(aL[i].pos == 0)
      {
         var dy = 0;
         tf.setNewTextFormat(normalFormat);
      }
      else if(aL[i].pos == 1)
      {
         var dy = superscriptDelta;
         tf.setNewTextFormat(scriptFormat);
      }
      else
      {
         var dy = subscriptDelta;
         tf.setNewTextFormat(scriptFormat);
      }
      tf.text = aL[i].str;
      tL.push({tf:tf,dy:dy});
      totalWidth += tf.textWidth;
      i++;
   }
   totalWidth += extraSpacing * (tL.length - 1);
   if(options.hAlign == "left")
   {
      var x = -2;
   }
   else if(options.hAlign == "right")
   {
      var x = -2 - totalWidth;
   }
   else
   {
      var x = -2 - totalWidth / 2;
   }
   if(options.vAlign == "top")
   {
      var y = -2;
   }
   else if(options.vAlign == "bottom")
   {
      var y = - lineHeight + 2;
   }
   else
   {
      var y = (- lineHeight) / 2;
   }
   var i = 0;
   while(i < tL.length)
   {
      var t = tL[i];
      t.tf._x = x;
      t.tf._y = y + t.dy;
      x += t.tf.textWidth + extraSpacing;
      i++;
   }
   mc.textWidth = totalWidth;
   return mc;
};
