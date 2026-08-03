function SimpleBlackbodyClass()
{
   var _loc1_ = this;
   _loc1_._placeholderMC._visible = false;
   _loc1_.width = _loc1_._width;
   _loc1_.height = _loc1_._height;
   _loc1_._xscale = 100;
   _loc1_._yscale = 100;
   _loc1_.createEmptyMovieClip("_backgroundMC",10);
   _loc1_.createEmptyMovieClip("_curvesMC",20);
   _loc1_.createEmptyMovieClip("_curvesMaskMC",30);
   _loc1_.createEmptyMovieClip("_borderMC",40);
   _loc1_.createEmptyMovieClip("_axesMC",50);
   _loc1_._axesMC.createEmptyMovieClip("_visSpectrumMC",1);
   _loc1_._axesMC.createEmptyMovieClip("_yAxisMC",3);
   _loc1_._curvesMC.setMask(_loc1_._curvesMaskMC);
   _loc1_._topCurveDepth = 0;
   _loc1_._curvesList = [];
   _loc1_._yLabelCount = 0;
   _loc1_.minScreenXSpacing = 45;
   _loc1_.minScreenYSpacing = 30;
   _loc1_.maxBrightness = 1000000000000;
   _loc1_.setVerticalScalingMode("autoscale");
   var _loc2_ = parseFloat(_loc1_.bbCurveTemp);
   if(!isNaN(_loc2_) && isFinite(_loc2_) && _loc2_ > 0)
   {
      _loc1_.addCurve("bbCurve",_loc2_,{thickness:_loc1_.bbCurveThickness,color:_loc1_.bbCurveColor,alpha:_loc1_.bbCurveAlpha});
   }
   _loc1_.update(true);
   _loc1_.setAxesLabelColor(_loc1_.initAxesLabelColor);
}
function SimpleBlackbodyCurveClass(parent, id, mc, name, temp, style)
{
   var _loc1_ = this;
   _loc1_._parent = parent;
   _loc1_._id = id;
   _loc1_._mc = mc;
   _loc1_._name = name;
   _loc1_.showFill = false;
   _loc1_.setTemperature(temp);
   _loc1_.peakHeight = 0.9;
   _loc1_._thick = 1;
   _loc1_._color = 0;
   _loc1_._alpha = 100;
   _loc1_._fillColor = 16711680;
   _loc1_._fillAlpha = 20;
   _loc1_.setStyle(style);
}
var p = SimpleBlackbodyClass.prototype = new MovieClip();
Object.registerClass("Simple Blackbody",SimpleBlackbodyClass);
p.addCurve = function(name, temp, style)
{
   var _loc1_ = this;
   var _loc3_ = name;
   var id = _loc1_._curvesList.length;
   var _loc2_ = _loc1_._topCurveDepth++;
   var mc = _loc1_._curvesMC.createEmptyMovieClip("_" + _loc2_,_loc2_);
   _loc1_[_loc3_] = new SimpleBlackbodyCurveClass(_loc1_,id,mc,_loc3_,temp,style);
   _loc1_._curvesList.push(_loc1_[_loc3_]);
};
p.setVerticalScalingMode = function(mode, targetHeight, curves)
{
   var _loc2_ = this;
   var _loc3_ = curves;
   var _loc1_;
   if(mode == "locked")
   {
      _loc2_._vScaleMode = 0;
   }
   else if(mode == "autoscale")
   {
      _loc2_._vScaleMode = 1;
      if(_loc3_ != undefined)
      {
         if(typeof _loc3_ == "string")
         {
            _loc2_._vScaleCurves = [_loc2_[_loc3_]];
         }
         else
         {
            _loc2_._vScaleCurves = [];
            _loc1_ = 0;
            while(_loc1_ < _loc3_.length)
            {
               _loc2_._vScaleCurves.push(_loc2_[_loc3_[_loc1_]]);
               _loc1_ = _loc1_ + 1;
            }
         }
      }
      else
      {
         _loc2_._vScaleCurves = _loc2_._curvesList;
      }
      if(typeof targetHeight == "number")
      {
         _loc2_._vTarget = targetHeight;
      }
      else
      {
         _loc2_._vTarget = 0.9;
      }
   }
   else if(mode == "custom")
   {
      _loc2_._vScaleMode = 2;
   }
};
p.update = function(updateEverything)
{
   var _loc1_ = this;
   _loc1_.updateScale();
   if(updateEverything)
   {
      _loc1_.updateLayout();
      _loc1_.updateHorizontalAxis();
   }
   _loc1_.updateVerticalAxis();
   _loc1_.updateCurves();
};
p.updateLayout = function()
{
   var _loc1_ = this;
   var w = _loc1_.width;
   var h = - _loc1_.height;
   var _loc3_ = _loc1_._backgroundMC;
   _loc3_.clear();
   _loc3_.moveTo(0,0);
   _loc3_.beginFill(_loc1_.backgroundColor,_loc1_.backgroundAlpha);
   _loc3_.lineTo(w,0);
   _loc3_.lineTo(w,h);
   _loc3_.lineTo(0,h);
   _loc3_.lineTo(0,0);
   _loc3_.endFill();
   var _loc2_ = _loc1_._curvesMaskMC;
   _loc2_.clear();
   _loc2_.moveTo(0,0);
   _loc2_.beginFill(16711680);
   _loc2_.lineTo(w,0);
   _loc2_.lineTo(w,h);
   _loc2_.lineTo(0,h);
   _loc2_.lineTo(0,0);
   _loc2_.endFill();
   var bdMC = _loc1_._borderMC;
   bdMC.clear();
   if(_loc1_.showBorder)
   {
      bdMC.lineStyle(_loc1_.borderThickness,_loc1_.borderColor,_loc1_.borderAlpha);
      bdMC.moveTo(0,0);
      bdMC.lineTo(w,0);
      bdMC.lineTo(w,h);
      bdMC.lineTo(0,h);
      bdMC.lineTo(0,0);
   }
};
p.updateScale = function()
{
   var _loc3_ = this;
   var _loc2_;
   var _loc1_;
   if(_loc3_._vScaleMode == 1)
   {
      var curves = _loc3_._vScaleCurves;
      var maxT = 0;
      _loc2_ = 0;
      while(_loc2_ < curves.length)
      {
         _loc1_ = curves[_loc2_]._temp;
         if(_loc1_ != null && _loc1_ > maxT)
         {
            maxT = _loc1_;
         }
         _loc2_ = _loc2_ + 1;
      }
      var A = 1.1910425859324616e-16;
      var B = 0.014387750559248378;
      var W = 0.0028977682864295084;
      var wPeak = W / maxT;
      if(wPeak < _loc3_.minWavelength)
      {
         wPeak = _loc3_.minWavelength;
      }
      else if(wPeak > _loc3_.maxWavelength)
      {
         wPeak = _loc3_.maxWavelength;
      }
      _loc3_.maxBrightness = A / (Math.pow(wPeak,5) * (Math.exp(B / (wPeak * maxT)) - 1)) / _loc3_._vTarget;
   }
   _loc3_._vScale = (- _loc3_.height) / _loc3_.maxBrightness;
   _loc3_._hRange = _loc3_.maxWavelength - _loc3_.minWavelength;
   _loc3_._hScale = _loc3_.width / _loc3_._hRange;
};
p.updateVerticalAxis = function()
{
   var _loc1_ = this;
   var pow = Math.pow;
   var log = Math.log;
   var majorExtent = _loc1_.majorTickmarkExtent;
   var minorExtent = _loc1_.minorTickmarkExtent;
   var maxBrightness = _loc1_.maxBrightness;
   var yScale = _loc1_.height / maxBrightness;
   var _loc2_ = _loc1_._axesMC._yAxisMC;
   _loc2_.clear();
   _loc2_.lineStyle(_loc1_.axesThickness,_loc1_.axesColor,_loc1_.axesAlpha);
   var labelIndex = 0;
   var _loc3_;
   if(_loc1_.showYAxis && yScale > 0)
   {
      if(_loc1_._vScaleMode != 2)
      {
         var minimumSpacing = _loc1_.minScreenYSpacing / yScale;
         var majorSpacing = pow(10,Math.ceil(log(minimumSpacing) / 2.302585092994046));
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
         var yStep = minorSpacing * yScale;
         var tickNumLimit = 1 + Math.floor(maxBrightness / minorSpacing);
         var i = 0;
         while(i < tickNumLimit)
         {
            _loc3_ = (- i) * yStep;
            if(i % multiple == 0)
            {
               _loc2_.moveTo(- majorExtent,_loc3_);
               _loc2_.lineTo(0,_loc3_);
               var value = minorSpacing * i;
               if(labelIndex < _loc1_._yLabelCount)
               {
                  var labelMC = _loc2_["_" + labelIndex];
                  labelMC.setValue(value);
                  labelMC._visible = true;
                  labelMC._x = - majorExtent;
                  labelMC._y = _loc3_;
               }
               else
               {
                  _loc2_.attachMovie(_loc1_.yTickLabelSymbol,"_" + _loc1_._yLabelCount,_loc1_._yLabelCount,{labelColor:_loc1_._axesLabelColor,_x:- majorExtent,_y:_loc3_,value:value});
                  _loc1_._yLabelCount = _loc1_._yLabelCount + 1;
               }
               labelIndex++;
            }
            else
            {
               _loc2_.moveTo(- minorExtent,_loc3_);
               _loc2_.lineTo(0,_loc3_);
            }
            i++;
         }
      }
      _loc2_.moveTo(0,0);
      _loc2_.lineTo(0,- _loc1_.height);
   }
   var i = labelIndex;
   while(i < _loc1_._yLabelCount)
   {
      _loc2_["_" + i]._visible = false;
      i++;
   }
};
p.updateHorizontalAxis = function()
{
   var pow = Math.pow;
   var log = Math.log;
   var majorExtent = this.majorTickmarkExtent;
   var minorExtent = this.minorTickmarkExtent;
   var minWavelength = this.minWavelength;
   var maxWavelength = this.maxWavelength;
   var xScale = this.width / (maxWavelength - minWavelength);
   var mc = this._axesMC.createEmptyMovieClip("_xAxisMC",2);
   var _loc3_;
   var _loc2_;
   var _loc1_;
   if(this.showXAxis && xScale > 0)
   {
      var minimumSpacing = this.minScreenXSpacing / xScale;
      var majorSpacing = pow(10,Math.ceil(log(minimumSpacing) / 2.302585092994046));
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
      var startTickNum = Math.ceil(minWavelength / minorSpacing);
      var tickNumLimit = 1 + Math.floor(maxWavelength / minorSpacing);
      _loc3_ = this.SIPrefixesTable;
      var lastIndex = _loc3_.length - 1;
      var depth = 0;
      var labelSymbol = this.xTickLabelSymbol;
      mc.lineStyle(this.axesThickness,this.axesColor,this.axesAlpha);
      var x = xScale * (minorSpacing * startTickNum - minWavelength);
      _loc2_ = startTickNum;
      while(_loc2_ < tickNumLimit)
      {
         if(_loc2_ % multiple == 0)
         {
            var value = minorSpacing * _loc2_;
            var logValue = log(value) / 2.302585092994046;
            if(_loc3_[lastIndex].power > logValue)
            {
               _loc1_ = lastIndex;
            }
            else
            {
               _loc1_ = 0;
               while(_loc3_[_loc1_].power > logValue)
               {
                  _loc1_ = _loc1_ + 1;
               }
            }
            if(value <= 0)
            {
               var label = "0";
            }
            else
            {
               var label = String(value / pow(10,_loc3_[_loc1_].power)) + " " + _loc3_[_loc1_].prefix + "m";
            }
            mc.moveTo(x,0);
            mc.lineTo(x,majorExtent);
            mc.attachMovie(labelSymbol,"_" + depth,depth,{labelColor:this._axesLabelColor,_x:x,_y:majorExtent,labelText:label});
            depth++;
         }
         else
         {
            mc.moveTo(x,0);
            mc.lineTo(x,minorExtent);
         }
         x += xStep;
         _loc2_ = _loc2_ + 1;
      }
      mc.moveTo(0,0);
      mc.lineTo(this.width,0);
   }
   var mc = this._axesMC._visSpectrumMC;
   mc.clear();
   if(this.showVisibleSpectrum && 7e-7 > minWavelength && 4e-7 < maxWavelength)
   {
      var colorsArray = [9044223,5905407,1087455,65472,2424576,15330304,16717568,16711738];
      var ratiosArray = [0,62,73,107,129,141,174,255];
      var alphasArray = [0,100,100,100,100,100,100,0];
      var transformMatrix = {matrixType:"box",x:xScale * (3.8e-7 - minWavelength),y:0,w:xScale * 3.4e-7,h:100,r:0};
      mc.beginGradientFill("linear",colorsArray,alphasArray,ratiosArray,transformMatrix);
      mc.moveTo(0,0);
      mc.lineTo(this.width,0);
      mc.lineTo(this.width,minorExtent);
      mc.lineTo(0,minorExtent);
      mc.lineTo(0,0);
      mc.endFill();
   }
};
p.updateCurves = function()
{
   var _loc2_ = this._curvesList;
   var _loc3_ = this._vScaleMode == 2;
   var _loc1_ = 0;
   while(_loc1_ < _loc2_.length)
   {
      _loc2_[_loc1_].redraw(_loc3_);
      _loc1_ = _loc1_ + 1;
   }
};
p.setAxesLabelColor = function(arg)
{
   var _loc3_ = this;
   _loc3_._axesLabelColor = arg;
   var i = 0;
   while(i < _loc3_._yLabelCount)
   {
      _loc3_._axesMC._yAxisMC["_" + i].setLabelColor(arg);
      i++;
   }
   var i = 0;
   var _loc2_ = _loc3_._axesMC._xAxisMC;
   var _loc1_ = _loc2_._0;
   while(_loc1_ != undefined)
   {
      _loc1_.setLabelColor(arg);
      _loc1_ = _loc2_["_" + ++i];
   }
};
p.SIPrefixesTable = [{power:24,name:"yotta",prefix:"Y"},{power:21,name:"zetta",prefix:"Z"},{power:18,name:"exa",prefix:"E"},{power:15,name:"peta",prefix:"P"},{power:12,name:"tera",prefix:"T"},{power:9,name:"giga",prefix:"G"},{power:6,name:"mega",prefix:"M"},{power:3,name:"kilo",prefix:"k"},{power:0,name:"",prefix:""},{power:-2,name:"centi",prefix:"c"},{power:-3,name:"milli",prefix:"m"},{power:-6,name:"micro",prefix:"µ"},{power:-9,name:"nano",prefix:"n"},{power:-12,name:"pico",prefix:"p"},{power:-15,name:"femto",prefix:"f"},{power:-18,name:"atto",prefix:"a"},{power:-21,name:"zepto",prefix:"z"},{power:-24,name:"yocto",prefix:"y"}];
var p = SimpleBlackbodyCurveClass.prototype = new Object();
p.remove = function()
{
   var _loc3_ = this;
   _loc3_._mc.removeMovieClip();
   var _loc2_ = _loc3_._parent._curvesList;
   var n = _loc2_.length;
   var _loc1_ = 0;
   while(_loc1_ < n)
   {
      if(_loc2_[_loc1_] == _loc3_)
      {
         _loc2_.splice(_loc1_,1);
         break;
      }
      _loc1_ = _loc1_ + 1;
   }
   var vL = _loc3_._parent._vScaleCurves;
   if(vL != _loc2_)
   {
      var n = vL.length;
      _loc1_ = 0;
      if(_loc1_ < n)
      {
         vL.splice(_loc1_,1);
      }
      if(vL.length == 0)
      {
         _loc3_._parent._vScaleCurves = _loc3_._parent._curvesList;
      }
   }
   delete _loc3_._parent[_loc3_._name];
};
p.addPeakLabel = function(linkageName, initObject)
{
   var _loc1_ = this;
   _loc1_.peakLabel = _loc1_._mc.attachMovie(linkageName,"_labelMC",1,initObject);
   return _loc1_.peakLabel;
};
p.getPeakWavelength = function()
{
   return 0.0028977682864295084 / this._temp;
};
p.redraw = function(useCustomScaling)
{
   var mc = this._mc;
   mc.clear();
   var _loc2_;
   var _loc3_;
   var _loc1_;
   if(mc._visible)
   {
      var T = this._temp;
      if(T != null)
      {
         var pow = Math.pow;
         var exp = Math.exp;
         var ceil = Math.ceil;
         var sqrt = Math.sqrt;
         var A = 1.1910425859324616e-16;
         var B = 0.014387750559248378;
         _loc2_ = 0.0028977682864295084;
         var wMin = this._parent.minWavelength;
         var wMax = this._parent.maxWavelength;
         var yMin = - this._parent.height - 100;
         var n = 10;
         var wTargetStep = (wMax - wMin) / n;
         var wPeak = _loc2_ / T;
         var i1 = wPeak - 1000 / T * 0.0000011939748395787048;
         var i2 = wPeak + 1000 / T * 0.0000011848609132537307;
         if(useCustomScaling)
         {
            var maxBrightness = A / (pow(wPeak,5) * (exp(B / (wPeak * T)) - 1));
            var yScale = (- this._parent.height) * this.peakHeight / maxBrightness;
         }
         else
         {
            var yScale = this._parent._vScale;
         }
         var xScale = this._parent._hScale;
         if(mc._labelMC != undefined)
         {
            if(maxBrightness == undefined)
            {
               var wPeak = 0.0028977682864295084 / T;
               var maxBrightness = A / (Math.pow(wPeak,5) * (Math.exp(B / (wPeak * T)) - 1));
            }
            var yLabel = yScale * maxBrightness;
            if(yLabel < yMin)
            {
               mc._labelMC._y = yMin;
            }
            else
            {
               mc._labelMC._y = yLabel;
            }
            mc._labelMC._x = xScale * (wPeak - this._parent.minWavelength);
         }
         _loc3_ = 0;
         _loc2_ = wMin;
         var e = exp(B / (_loc2_ * T)) - 1;
         var p = pow(_loc2_,5);
         var f = A / (p * e);
         var d = A / (e * _loc2_ * p) * (-5 + B * (e + 1) / (_loc2_ * T * e));
         var lw = _loc2_;
         var lf = f;
         var ld = d;
         var initY = f * yScale;
         var bt = true;
         if(initY < yMin)
         {
            initY = yMin;
            bt = false;
         }
         mc.lineStyle(this._thick,this._color,this._alpha);
         mc.moveTo(_loc3_,initY);
         if(this.showFill)
         {
            mc.beginFill(this._fillColor,this._fillAlpha);
         }
         var lx = _loc3_;
         var ly = initY;
         var s0 = 0.4 * i1;
         var s1 = 0.7 * i1;
         var s2 = 1.5 * i2;
         var s3 = 3.2 * i2;
         var stopPoints = [];
         if(s0 > wMin && s0 < wMax)
         {
            stopPoints.push(s0);
         }
         if(s1 > wMin && s1 < wMax)
         {
            stopPoints.push(s1);
         }
         if(i1 > wMin && i1 < wMax)
         {
            stopPoints.push(i1);
         }
         if(wPeak > wMin && wPeak < wMax)
         {
            stopPoints.push(wPeak);
         }
         if(i2 > wMin && i2 < wMax)
         {
            stopPoints.push(i2);
         }
         if(s2 > wMin && s2 < wMax)
         {
            stopPoints.push(s2);
         }
         if(s3 > wMin && s3 < wMax)
         {
            stopPoints.push(s3);
         }
         stopPoints.push(wMax);
         var j = 0;
         while(j < stopPoints.length)
         {
            var interval = stopPoints[j] - _loc2_;
            var numSteps = ceil(interval / wTargetStep);
            if(numSteps < 3)
            {
               numSteps = 3;
            }
            var wStep = interval / numSteps;
            var xStep = wStep * xScale;
            var i = 0;
            while(i < numSteps)
            {
               _loc2_ += wStep;
               _loc3_ += xStep;
               var e = exp(B / (_loc2_ * T)) - 1;
               var p = pow(_loc2_,5);
               var f = A / (p * e);
               var d = A / (e * _loc2_ * p) * (-5 + B * (e + 1) / (_loc2_ * T * e));
               _loc1_ = f * yScale;
               var cw = (f - lf + ld * lw - d * _loc2_) / (ld - d);
               var cf = d * (cw - _loc2_) + f;
               var cx = xScale * (cw - wMin);
               var cy = yScale * cf;
               if(bt)
               {
                  if(_loc1_ < yMin)
                  {
                     var a_ = ly - 2 * cy + _loc1_;
                     var b_ = 2 * cy - 2 * ly;
                     var c_ = ly - yMin;
                     var ts = (- b_ - sqrt(b_ * b_ - 4 * a_ * c_)) / (2 * a_);
                     if(ts < 0 || ts > 1)
                     {
                        var ts = (- b_ + sqrt(b_ * b_ - 4 * a_ * c_)) / (2 * a_);
                     }
                     var k0 = 1 - ts;
                     var nx = k0 * k0 * lx + 2 * ts * k0 * cx + ts * ts * _loc3_;
                     var cx = k0 * lx + ts * cx;
                     var cy = k0 * ly + ts * cy;
                     mc.curveTo(cx,cy,nx,yMin);
                     bt = false;
                  }
                  else
                  {
                     mc.curveTo(cx,cy,_loc3_,_loc1_);
                  }
               }
               else if(_loc1_ > yMin)
               {
                  var a_ = ly - 2 * cy + _loc1_;
                  var b_ = 2 * cy - 2 * ly;
                  var c_ = ly - yMin;
                  var ts = (- b_ + sqrt(b_ * b_ - 4 * a_ * c_)) / (2 * a_);
                  if(ts < 0 || ts > 1)
                  {
                     var ts = (- b_ - sqrt(b_ * b_ - 4 * a_ * c_)) / (2 * a_);
                  }
                  var k0 = 1 - ts;
                  var nx = k0 * k0 * lx + 2 * ts * k0 * cx + ts * ts * _loc3_;
                  var cx = ts * _loc3_ + k0 * cx;
                  var cy = ts * _loc1_ + k0 * cy;
                  mc.lineTo(nx,yMin);
                  mc.curveTo(cx,cy,_loc3_,_loc1_);
                  bt = true;
               }
               else
               {
                  mc.lineTo(_loc3_,yMin);
               }
               var lx = _loc3_;
               var ly = _loc1_;
               var lw = _loc2_;
               var lf = f;
               var ld = d;
               i++;
            }
            j++;
         }
         if(this.showFill)
         {
            mc.lineStyle(undefined);
            mc.lineTo(_loc3_,0);
            mc.lineTo(0,0);
            mc.lineTo(0,initY);
            mc.endFill();
         }
      }
   }
};
p.setStyle = function(arg)
{
   var _loc1_ = arg;
   var _loc2_ = this;
   if(_loc1_.thickness != undefined)
   {
      _loc2_._thick = _loc1_.thickness;
   }
   if(_loc1_.color != undefined)
   {
      _loc2_._color = _loc1_.color;
   }
   if(_loc1_.alpha != undefined)
   {
      _loc2_._alpha = _loc1_.alpha;
   }
   if(_loc1_.fillColor != undefined)
   {
      _loc2_._fillColor = _loc1_.fillColor;
   }
   if(_loc1_.fillAlpha != undefined)
   {
      _loc2_._fillAlpha = _loc1_.fillAlpha;
   }
};
p.getTemperature = function()
{
   return this._temp;
};
p.setTemperature = function(arg)
{
   var _loc1_ = arg;
   if(typeof _loc1_ == "number" && isFinite(_loc1_) && _loc1_ > 0)
   {
      this._temp = _loc1_;
   }
   else
   {
      this._temp = null;
   }
};
p.addProperty("temperature",p.getTemperature,p.setTemperature);
p.addProperty("temp",p.getTemperature,p.setTemperature);
p.getVisible = function()
{
   return this._mc._visible;
};
p.setVisible = function(arg)
{
   this._mc._visible = Boolean(arg);
};
p.addProperty("visible",p.getVisible,p.setVisible);
