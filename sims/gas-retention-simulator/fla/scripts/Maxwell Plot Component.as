function MaxwellPlotComponentClass()
{
   if(this.initWidth != undefined)
   {
      this._plotWidth = this.initWidth;
   }
   else
   {
      this._plotWidth = this._width;
   }
   if(this.initHeight != undefined)
   {
      this._plotHeight = this.initHeight;
   }
   else
   {
      this._plotHeight = this._height;
   }
   this._xscale = this._yscale = 100;
   this.placeholderMC._visible = false;
   this.placeholderMC.swapDepths(121212);
   this.placeholderMC.removeMovieClip();
   this.createEmptyMovieClip("backgroundMC",5);
   this.createEmptyMovieClip("curvesMC",10);
   this.createEmptyMovieClip("curvesMaskMC",11);
   this.createEmptyMovieClip("borderMC",15);
   this.createEmptyMovieClip("yAxisMC",25);
   this.curvesMC.setMask(this.curvesMaskMC);
   this._xMin = 0;
   this._xMax = 2000;
   this.__yScale = -50000;
   this.axesTextFormat = new TextFormat("Verdana",12);
   this.lockYScale = false;
   this.temperature = 300;
   this._topCurveDepth = 1;
   this._curvesList = [];
   this.updateScale();
   this.updateBorderAndBackground();
   this.update();
}
function MPCCurveClass(parent, mc, name, initObject)
{
   this._parent = parent;
   this._mc = mc;
   this._name = name;
   this.fillMC = this._mc.createEmptyMovieClip("fillMC",1);
   this.fillMaskMC = this._mc.createEmptyMovieClip("fillMaskMC",2);
   this.curveMC = this._mc.createEmptyMovieClip("curveMC",10);
   this.fillMC.setMask(this.fillMaskMC);
   this.mass = null;
   this.fraction = 1;
   this.showFill = false;
   this.fillDirection = "left";
   this.fillLimit = null;
   this.curveThickness = 0;
   this.curveColor = 16711680;
   this.curveAlpha = 100;
   this.fillColor = 16711680;
   this.fillAlpha = 20;
   for(var x in initObject)
   {
      this[x] = initObject[x];
   }
   this.setFillLimit("none");
}
var p = MaxwellPlotComponentClass.prototype = new MovieClip();
Object.registerClass("Maxwell Plot Component",MaxwellPlotComponentClass);
p.borderThickness = 1;
p.borderColor = 5263440;
p.borderAlpha = 100;
p.backgroundColor = 16777215;
p.backgroundAlpha = 100;
p.peakHeight = 0.95;
p.minScreenXSpacing = 45;
p.minScreenYSpacing = 30;
p.axesThickness = 1;
p.axesColor = 5263440;
p.axesAlpha = 100;
p.majorTickmarkExtent = 6;
p.minorTickmarkExtent = 3;
p.setSpeedRange = function(min, max)
{
   if(typeof min == "number")
   {
      this._xMin = min;
   }
   if(typeof max == "number")
   {
      this._xMax = max;
   }
   this.updateScale();
   this.update();
};
p.updateScale = function()
{
   this.__xScale = this._plotWidth / (this._xMax - this._xMin);
};
p.updateBorderAndBackground = function()
{
   var w = this._plotWidth;
   var h = this._plotHeight;
   this.backgroundMC.clear();
   this.backgroundMC.lineStyle();
   this.backgroundMC.moveTo(0,0);
   this.backgroundMC.beginFill(this.backgroundColor,this.backgroundAlpha);
   this.backgroundMC.lineTo(w,0);
   this.backgroundMC.lineTo(w,- h);
   this.backgroundMC.lineTo(0,- h);
   this.backgroundMC.lineTo(0,0);
   this.backgroundMC.endFill();
   this.curvesMaskMC.clear();
   this.curvesMaskMC.lineStyle();
   this.curvesMaskMC.moveTo(0,0);
   this.curvesMaskMC.beginFill(16711680);
   this.curvesMaskMC.lineTo(w,0);
   this.curvesMaskMC.lineTo(w,- h);
   this.curvesMaskMC.lineTo(0,- h);
   this.curvesMaskMC.lineTo(0,0);
   this.curvesMaskMC.endFill();
   this.borderMC.clear();
   this.borderMC.lineStyle(this.borderThickness,this.borderColor,this.borderAlpha);
   this.borderMC.moveTo(0,0);
   this.borderMC.lineTo(w,0);
   this.borderMC.lineTo(w,- h);
   this.borderMC.lineTo(0,- h);
   this.borderMC.lineTo(0,0);
};
p.updateXAxis = function()
{
   var xScale = this.__xScale;
   var min = this._xMin;
   var max = this._xMax;
   var majorExtent = this.majorTickmarkExtent;
   var minorExtent = this.minorTickmarkExtent;
   var minimumSpacing = this.minScreenXSpacing / xScale;
   var majorSpacing = Math.pow(10,Math.ceil(Math.log(minimumSpacing) / 2.302585092994046));
   if(majorSpacing / 2 > minimumSpacing)
   {
      majorSpacing /= 2;
      var multiple = 5;
   }
   else
   {
      var multiple = 2;
   }
   var minorSpacing = majorSpacing / multiple;
   var xStep = minorSpacing * xScale;
   var startTickNum = Math.ceil(min / minorSpacing);
   var tickNumLimit = 1 + Math.floor(max / minorSpacing);
   var x = xScale * (minorSpacing * startTickNum - min);
   var mc = this.createEmptyMovieClip("xAxisMC",20);
   mc.lineStyle(this.axesThickness,this.axesColor,this.axesAlpha);
   var tf = this.axesTextFormat;
   var depthCounter = 1000;
   var i = startTickNum;
   while(i < tickNumLimit)
   {
      if(i % multiple == 0)
      {
         mc.moveTo(x,0);
         mc.lineTo(x,majorExtent);
         var value = minorSpacing * i;
         var optionsObject = {x:x,y:majorExtent + 2,depth:depthCounter,vAlign:"top",hAlign:"center",mc:mc,embedFonts:true,textFormat:tf};
         this.displayText(value,optionsObject);
         depthCounter++;
      }
      else
      {
         mc.moveTo(x,0);
         mc.lineTo(x,minorExtent);
      }
      x += xStep;
      i++;
   }
};
p.update = function()
{
   var startTimer = getTimer();
   var cL = this._curvesList;
   var C = 0.5870506526949597;
   var maxPeak = -Infinity;
   var i = 0;
   while(i < cL.length)
   {
      var g = cL[i];
      if(!g.getIsInvalid())
      {
         g._a = Math.sqrt(8314.47147 * this.temperature / g.mass);
         var peak = C * g.fraction / g._a;
         if(peak > maxPeak)
         {
            maxPeak = peak;
         }
      }
      i++;
   }
   if(!this.lockYScale)
   {
      this.__yScale = (- this.peakHeight) * this._plotHeight / maxPeak;
   }
   var i = 0;
   while(i < cL.length)
   {
      cL[i].update();
      i++;
   }
   this.updateXAxis();
};
p.addCurve = function(name, initObject)
{
   var depth = this._topCurveDepth++;
   var mc = this.curvesMC.createEmptyMovieClip("_" + depth,depth);
   this[name] = new MPCCurveClass(this,mc,name,initObject);
   this._curvesList.push(this[name]);
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
var q = MPCCurveClass.prototype = new Object();
q.getIsInvalid = function()
{
   return !this._mc._visible || typeof this.mass != "number" || !isFinite(this.mass) || isNaN(this.mass) || this.mass <= 0;
};
q.setFillLimit = function(limit, direction)
{
   var mc = this.fillMaskMC;
   mc.clear();
   var w = this._parent._plotWidth;
   var h = - this._parent._plotHeight;
   if(typeof limit != "number")
   {
      mc.moveTo(0,0);
      mc.beginFill(16711680,100);
      mc.lineTo(w,0);
      mc.lineTo(w,h);
      mc.lineTo(0,h);
      mc.lineTo(0,0);
      mc.endFill();
   }
   else
   {
      var x = (limit - this._parent._xMin) / this._parent.__xScale;
      if(direction == "left")
      {
         mc.moveTo(0,0);
         mc.beginFill(16711680,100);
         mc.lineTo(x,0);
         mc.lineTo(x,h);
         mc.lineTo(0,h);
         mc.lineTo(0,0);
         mc.endFill();
      }
      else
      {
         mc.moveTo(x,0);
         mc.beginFill(16711680,100);
         mc.lineTo(w,0);
         mc.lineTo(w,h);
         mc.lineTo(x,h);
         mc.lineTo(x,0);
         mc.endFill();
      }
   }
};
q.update = function()
{
   var startTimer = getTimer();
   this.curveMC.clear();
   this.fillMC.clear();
   if(this.getIsInvalid())
   {
      return undefined;
   }
   var paramsObj = {};
   paramsObj.a = this._a;
   paramsObj.xMin = this._parent._xMin;
   paramsObj.xMax = this._parent._xMax;
   paramsObj.xScale = this._parent.__xScale;
   paramsObj.yScale = this.fraction * this._parent.__yScale;
   paramsObj.mc = this.curveMC;
   this.curveMC.lineStyle(this.curveThickness,this.curveColor,this.curveAlpha);
   this.drawMaxwell(paramsObj);
   if(this.showFill)
   {
      paramsObj.mc = this.fillMC;
      this.fillMC.beginFill(this.fillColor,this.fillAlpha);
      var startPt = this.drawMaxwell(paramsObj);
      this.fillMC.lineStyle();
      this.fillMC.lineTo(this._parent._plotWidth,0);
      this.fillMC.lineTo(0,0);
      this.fillMC.lineTo(startPt.x,startPt.y);
      this.fillMC.endFill();
   }
};
q.drawMaxwell = function(paramsObj)
{
   var exp = Math.exp;
   var mc = paramsObj.mc;
   var a = paramsObj.a;
   var xMin = paramsObj.xMin;
   var xMax = paramsObj.xMax;
   var xScale = paramsObj.xScale;
   var yScale = paramsObj.yScale;
   var K0 = 0.7978845608028654 / (a * a * a);
   var K1 = 2 * a * a;
   var K2 = 2 * (yScale / xScale);
   if(paramsObj.numSegments != undefined)
   {
      var nTotal = paramsObj.numSegments;
   }
   else
   {
      var nTotal = 8;
   }
   var lim = 5 * a;
   if(lim < xMin)
   {
      var startPt = {x:0,y:0};
      mc.moveTo(0,0);
      mc.lineTo(xScale * (xMax - xMin),0);
   }
   else
   {
      var maL = [];
      var inf1 = a * 0.6621534468619564;
      if(inf1 > xMin && inf1 < xMax)
      {
         maL.push(inf1);
      }
      var xMode = a * 1.4142135623730951;
      if(xMode > xMin && xMode < xMax)
      {
         maL.push(xMode);
      }
      var inf2 = a * 2.135779205069857;
      if(inf2 > xMin && inf2 < xMax)
      {
         maL.push(inf2);
      }
      if(lim < xMax)
      {
         maL.push(lim);
         var range = lim - xMin;
         var limitPassed = true;
      }
      else
      {
         maL.push(xMax);
         var range = xMax - xMin;
         var limitPassed = false;
      }
      var x = xMin;
      var J0 = K0 * x * exp((- x) * x / K1);
      var m = J0 * K2 * (1 - x * x / K1);
      var ax = 0;
      var ay = yScale * x * J0;
      var startPt = {x:ax,y:ay};
      mc.moveTo(ax,ay);
      var i = 0;
      while(i < maL.length)
      {
         var n = Math.ceil(nTotal * (maL[i] - x) / range);
         var xStep = (maL[i] - x) / n;
         var j = 0;
         while(j < n)
         {
            var lax = ax;
            var lay = ay;
            var lm = m;
            x += xStep;
            var J0 = K0 * x * exp((- x) * x / K1);
            var m = J0 * K2 * (1 - x * x / K1);
            var ax = xScale * (x - xMin);
            var ay = yScale * x * J0;
            var cx = (lay - ay - lm * lax + m * ax) / (m - lm);
            var cy = m * (cx - ax) + ay;
            mc.curveTo(cx,cy,ax,ay);
            j++;
         }
         i++;
      }
      if(limitPassed)
      {
         mc.lineTo(xScale * (xMax - xMin),0);
      }
   }
   return startPt;
};
q.remove = function()
{
   this._mc.removeMovieClip();
   var cL = this._parent._curvesList;
   var n = cL.length;
   var i = 0;
   while(i < n)
   {
      if(cL[i] == this)
      {
         cL.splice(i,1);
         break;
      }
      i++;
   }
   delete this._parent[this._name];
};
q.setStyle = function(arg)
{
   if(arg.thickness != undefined)
   {
      this._thick = arg.thickness;
   }
   if(arg.color != undefined)
   {
      this._color = arg.color;
   }
   if(arg.alpha != undefined)
   {
      this._alpha = arg.alpha;
   }
   if(arg.fillColor != undefined)
   {
      this._fillColor = arg.fillColor;
   }
   if(arg.fillAlpha != undefined)
   {
      this._fillAlpha = arg.fillAlpha;
   }
};
q.getVisible = function()
{
   return this._mc._visible;
};
q.setVisible = function(arg)
{
   this._mc._visible = Boolean(arg);
};
q.addProperty("visible",p.getVisible,p.setVisible);
