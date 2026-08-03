function RadialVelocityComponentClass()
{
   if(this.width == undefined || this.height == undefined)
   {
      this.width = this._width;
      this.height = this._height;
   }
   this.placeholderMC._visible = false;
   this.placeholderMC.swapDepths(121212);
   this.placeholderMC.removeMovieClip();
   this._xscale = 100;
   this._yscale = 100;
   this.createEmptyMovieClip("backgroundMC",1);
   this.createEmptyMovieClip("plotAreaMC",5);
   this.createEmptyMovieClip("plotAreaMaskMC",10);
   this.attachMovie("RV Component X Axis Label","xAxisLabelMC",16);
   this.createEmptyMovieClip("yTickmarksMC",20);
   this.attachMovie("RV Component Y Axis Label","yAxisLabelMC",21);
   this.createEmptyMovieClip("borderMC",25);
   this.attachMovie("RV Component Crosshairs","crosshairsMC",51,{_visible:false});
   this.xAxisLabelColorObject = new Color(this.xAxisLabelMC);
   this.yAxisLabelColorObject = new Color(this.yAxisLabelMC);
   this.yTickmarksColorObject = new Color(this.yTickmarksMC);
   this.borderColorObject = new Color(this.borderMC);
   this.plotAreaMC.setMask(this.plotAreaMaskMC);
   this.plotAreaMC.createEmptyMovieClip("curveMC",10);
   this.plotAreaMC.createEmptyMovieClip("phaseCursorMC",15);
   this.plotAreaMC.phaseCursorMC.createEmptyMovieClip("normalMC",1);
   this.plotAreaMC.phaseCursorMC.normalMC._visible = true;
   this.plotAreaMC.phaseCursorMC.createEmptyMovieClip("activeMC",2);
   this.plotAreaMC.phaseCursorMC.activeMC._visible = false;
   this.backgroundMC.useHandCursor = false;
   this.backgroundMC.tabEnabled = false;
   this.backgroundMC.onPressFunc = function()
   {
      this._parent.crosshairsMC._visible = false;
      this.xOffset = this._xmouse - this._parent.plotAreaMC._x;
      this.onMouseMove = this.dragPhaseOffsetOnMouseMoveFunc;
   };
   this.backgroundMC.dragPhaseOffsetOnMouseMoveFunc = function()
   {
      this._parent.setPhaseOffset((this._xmouse - this.xOffset) / this._parent.plotWidth,true);
      updateAfterEvent();
   };
   this.backgroundMC.crosshairsOnMouseMoveFunc = function()
   {
      this._parent.crosshairsMC.update();
      updateAfterEvent();
   };
   this.backgroundMC.onRelease = function()
   {
      this._parent.crosshairsMC.update();
      this._parent.crosshairsMC._visible = true;
      this.onMouseMove = this.crosshairsOnMouseMoveFunc;
   };
   this.backgroundMC.onReleaseOutside = function()
   {
      this._parent.crosshairsMC._visible = false;
      delete this.onMouseMove;
   };
   this.backgroundMC.onRollOut = function()
   {
      this._parent.crosshairsMC._visible = false;
      delete this.onMouseMove;
   };
   this.backgroundMC.onRollOver = function()
   {
      this._parent.crosshairsMC.update();
      this._parent.crosshairsMC._visible = true;
      this.onMouseMove = this.crosshairsOnMouseMoveFunc;
   };
   this.plotAreaMC.phaseCursorMC.useHandCursor = false;
   this.plotAreaMC.phaseCursorMC.tabEnabled = false;
   this.plotAreaMC.phaseCursorMC.onRollOver = function()
   {
      this.activeMC._visible = true;
      this.normalMC._visible = false;
   };
   this.plotAreaMC.phaseCursorMC.onRollOut = function()
   {
      this.activeMC._visible = false;
      this.normalMC._visible = true;
   };
   this.plotAreaMC.phaseCursorMC.onReleaseOutside = function()
   {
      this.activeMC._visible = false;
      this.normalMC._visible = true;
      delete this.onMouseMove;
   };
   this.plotAreaMC.phaseCursorMC.onRelease = function()
   {
      delete this.onMouseMove;
   };
   this.plotAreaMC.phaseCursorMC.onPress = function()
   {
      this.xOffset = this._parent._xmouse - this._x;
      this.onMouseMove = this.onMouseMoveFunc;
   };
   this.plotAreaMC.phaseCursorMC.onMouseMoveFunc = function()
   {
      this._parent._parent.setCursorPhase((this._parent._xmouse - this.xOffset) / this._parent._parent.plotWidth,true);
      updateAfterEvent();
   };
   this._yLabelCount = 0;
   if(this.minMarginPx == undefined)
   {
      this.minMarginPx = 25;
   }
   if(this.margin == undefined)
   {
      this.margin = 2;
   }
   if(this.noise == undefined)
   {
      this.noise = 10;
   }
   if(this.initShowMeasurements == undefined)
   {
      this.initShowMeasurements = true;
   }
   if(this.numberOfMeasurements == undefined)
   {
      this.numberOfMeasurements = 150;
   }
   if(this.numFreshMeasurements == undefined)
   {
      this.numFreshMeasurements = 40;
   }
   if(this.measurementDotSize == undefined)
   {
      this.measurementDotSize = 4;
   }
   if(this.measurementDotColor == undefined)
   {
      this.measurementDotColor = 10066329;
   }
   if(this.numCurveSteps == undefined)
   {
      this.numCurveSteps = 32;
   }
   if(this.initShowCurve == undefined)
   {
      this.initShowCurve = true;
   }
   if(this.curveThickness == undefined)
   {
      this.curveThickness = 1;
   }
   if(this.curveColor == undefined)
   {
      this.curveColor = 16711680;
   }
   if(this.axesColor == undefined)
   {
      this.axesColor = 0;
   }
   if(this.backgroundColor == undefined)
   {
      this.backgroundColor = 16777215;
   }
   if(this.backgroundAlpha == undefined)
   {
      this.backgroundAlpha = 100;
   }
   if(this.initPhaseOffset == undefined)
   {
      this.initPhaseOffset = -0.25;
   }
   if(this.initAllowDragging == undefined)
   {
      this.initAllowDragging = true;
   }
   if(this.cursorPhase == undefined)
   {
      this.cursorPhase = 0;
   }
   if(this.initShowPhaseCursor == undefined)
   {
      this.initShowPhaseCursor = false;
   }
   if(this.phaseCursorNormalColor == undefined)
   {
      this.phaseCursorNormalColor = 15634576;
   }
   if(this.phaseCursorNormalWidth == undefined)
   {
      this.phaseCursorNormalWidth = 3;
   }
   if(this.phaseCursorActiveColor == undefined)
   {
      this.phaseCursorActiveColor = 16732240;
   }
   if(this.phaseCursorActiveWidth == undefined)
   {
      this.phaseCursorActiveWidth = 4;
   }
   if(this.initCursorPhase == undefined)
   {
      this.initCursorPhase = 0.5;
   }
   if(this.xAxisTickmarksList == undefined)
   {
      var a = 7;
      var b = 4;
      this.xAxisTickmarksList = [{value:0,extent:a,labelText:"0.0"},{value:0.1,extent:b},{value:0.2,extent:a,labelText:"0.2"},{value:0.3,extent:b},{value:0.4,extent:a,labelText:"0.4"},{value:0.5,extent:b},{value:0.6,extent:a,labelText:"0.6"},{value:0.7,extent:b},{value:0.8,extent:a,labelText:"0.8"},{value:0.9,extent:b}];
   }
   if(this.minScreenYSpacing == undefined)
   {
      this.minScreenYSpacing = 25;
   }
   if(this.minorTickmarkExtent == undefined)
   {
      this.minorTickmarkExtent = 4;
   }
   if(this.majorTickmarkExtent == undefined)
   {
      this.majorTickmarkExtent = 7;
   }
   this._eccentricity = null;
   this._argument = null;
   this._inclination = null;
   this._separation = null;
   this._mass1 = null;
   this._mass2 = null;
   var LPMass1 = parseFloat(this.initMass1) * 1.98892e+30;
   var LPMass2 = parseFloat(this.initMass2) * 1.899e+27;
   var LPSeparation = parseFloat(this.initSeparation) * 149598000000;
   var LPEccentricity = parseFloat(this.initEccentricity);
   var LPLongitude = parseFloat(this.initLongitude);
   var LPInclination = parseFloat(this.initInclination);
   var paramsObj = {};
   if(isFinite(LPMass1) && !isNaN(LPMass1))
   {
      paramsObj.mass1 = LPMass1;
   }
   if(isFinite(LPMass2) && !isNaN(LPMass2))
   {
      paramsObj.mass2 = LPMass2;
   }
   if(isFinite(LPSeparation) && !isNaN(LPSeparation))
   {
      paramsObj.separation = LPSeparation;
   }
   if(isFinite(LPEccentricity) && !isNaN(LPEccentricity))
   {
      paramsObj.eccentricity = LPEccentricity;
   }
   if(isFinite(LPLongitude) && !isNaN(LPLongitude))
   {
      paramsObj.longitude = LPLongitude;
   }
   if(isFinite(LPInclination) && !isNaN(LPInclination))
   {
      paramsObj.inclination = LPInclination;
   }
   this.setParameters(paramsObj);
   this.initializePhaseCursor();
   this.initializeHorizontalScale();
   this.updateAxesColor();
   this.setPlotDimensions(this.width,this.height);
   this.allowDragging = this.initAllowDragging;
   this.phaseOffset = this.initPhaseOffset;
   this.cursorPhase = this.initCursorPhase;
   this.showCurve = this.initShowCurve;
   this.showPhaseCursor = this.initShowPhaseCursor;
   this.showMeasurements = this.initShowMeasurements;
}
var p = RadialVelocityComponentClass.prototype = new MovieClip();
Object.registerClass("Radial Velocity Component",RadialVelocityComponentClass);
p.getAllowDragging = function()
{
   return this.backgroundMC.onPress == this.backgroundMC.onPressFunc;
};
p.setAllowDragging = function(arg)
{
   if(arg)
   {
      this.backgroundMC.onPress = this.backgroundMC.onPressFunc;
   }
   else
   {
      delete this.backgroundMC.onPress;
   }
};
p.addProperty("allowDragging",p.getAllowDragging,p.setAllowDragging);
p.getPhaseOffset = function()
{
   return this._phaseOffset;
};
p.setPhaseOffset = function(arg, callChangeHandler)
{
   this._phaseOffset = (arg % 1 + 1) % 1;
   this.plotAreaMC._x = this._phaseOffset * this.plotWidth;
   this.updateHorizontalScale();
   if(callChangeHandler)
   {
      this._parent[this.phaseOffsetChangeHandler](this._phaseOffset);
   }
};
p.addProperty("phaseOffset",p.getPhaseOffset,p.setPhaseOffset);
p.getShowCurve = function()
{
   return this.plotAreaMC.curveMC._visible;
};
p.setShowCurve = function(arg)
{
   this.plotAreaMC.curveMC._visible = arg;
};
p.addProperty("showCurve",p.getShowCurve,p.setShowCurve);
p.getShowMeasurements = function()
{
   return this._showMeasurements;
};
p.setShowMeasurements = function(arg)
{
   this._showMeasurements = Boolean(arg);
   this.plotAreaMC.measurementsMC._visible = this._showMeasurements;
   this.updateMeasurements();
};
p.addProperty("showMeasurements",p.getShowMeasurements,p.setShowMeasurements);
p.getShowPhaseCursor = function()
{
   return this.plotAreaMC.phaseCursorMC._visible;
};
p.setShowPhaseCursor = function(arg)
{
   this.plotAreaMC.phaseCursorMC._visible = arg;
};
p.addProperty("showPhaseCursor",p.getShowPhaseCursor,p.setShowPhaseCursor);
p.getCursorPhase = function(arg)
{
   return this._cPhase;
};
p.setCursorPhase = function(arg, callChangeHandler)
{
   this._cPhase = (arg % 1 + 1) % 1;
   this.plotAreaMC.phaseCursorMC._x = this._cPhase * this.plotWidth;
   if(callChangeHandler)
   {
      this._parent[this.phaseChangeHandler](this._cPhase);
   }
};
p.addProperty("cursorPhase",p.getCursorPhase,p.setCursorPhase);
p.setParameters = function(dataObj)
{
   if(dataObj.eccentricity != undefined)
   {
      this._eccentricity = dataObj.eccentricity;
   }
   if(dataObj.separation != undefined)
   {
      this._separation = dataObj.separation;
   }
   if(dataObj.longitude != undefined)
   {
      this._argument = dataObj.longitude * 3.141592653589793 / 180;
   }
   if(dataObj.inclination != undefined)
   {
      this._inclination = dataObj.inclination * 3.141592653589793 / 180;
   }
   if(dataObj.mass1 != undefined)
   {
      this._mass1 = dataObj.mass1;
   }
   if(dataObj.mass2 != undefined)
   {
      this._mass2 = dataObj.mass2;
   }
};
p.update = function()
{
   if(this._separation == null || this._eccentricity == null || this._inclination == null || this._mass1 == null || this._mass2 == null || this._argument == null)
   {
      this.centerVelocity = null;
      this.amplitude = null;
      this.period = null;
      var h = this.margin * this.noise;
      this.yScale = (- this.halfPlotHeight) / h;
      this.yAxisMin = - h;
      this.yAxisMax = h;
   }
   else
   {
      var a2 = this._separation;
      var a1 = this._mass2 / this._mass1 * this._separation;
      var P = Math.sqrt(39.47841760435743 * a2 * a2 * a2 / (6.673e-11 * (this._mass1 + this._mass2)));
      var K = 6.283185307179586 / P * a1 * Math.sin(this._inclination) / Math.sqrt(1 - this._eccentricity * this._eccentricity);
      this.centerVelocity = K * this._eccentricity * Math.cos(this._argument);
      this.amplitude = K;
      this.period = P / 86400;
      var m = this.margin * this.noise;
      var b = this.halfPlotHeight * (m / (K + m));
      if(b < this.minMarginPx)
      {
         var actualMargin = this.minMarginPx * K / (this.halfPlotHeight - this.minMarginPx);
      }
      else
      {
         var actualMargin = m;
      }
      var h = this.amplitude + actualMargin;
      this.yScale = (- this.halfPlotHeight) / h;
      this.yAxisMin = this.centerVelocity - h;
      this.yAxisMax = this.centerVelocity + h;
   }
   this.updateCurve();
   this.updateVerticalScale();
   this.updateMeasurements();
};
p.initializePhaseCursor = function()
{
   var mc = this.plotAreaMC.phaseCursorMC.activeMC;
   mc.clear();
   mc.lineStyle(this.phaseCursorActiveWidth,this.phaseCursorActiveColor,100);
   mc.moveTo(0,this.halfPlotHeight);
   mc.lineTo(0,- this.halfPlotHeight);
   mc.moveTo(- this.plotWidth,this.halfPlotHeight);
   mc.lineTo(- this.plotWidth,- this.halfPlotHeight);
   var mc = this.plotAreaMC.phaseCursorMC.normalMC;
   mc.clear();
   mc.lineStyle(this.phaseCursorNormalWidth,this.phaseCursorNormalColor,100);
   mc.moveTo(0,this.halfPlotHeight);
   mc.lineTo(0,- this.halfPlotHeight);
   mc.moveTo(- this.plotWidth,this.halfPlotHeight);
   mc.lineTo(- this.plotWidth,- this.halfPlotHeight);
};
p.initializeBackgroundAndBorder = function()
{
   this.backgroundMC.clear();
   this.backgroundMC.beginFill(this.backgroundColor,this.backgroundAlpha);
   this.backgroundMC.moveTo(0,0);
   this.backgroundMC.lineTo(this.plotWidth,0);
   this.backgroundMC.lineTo(this.plotWidth,this.plotHeight);
   this.backgroundMC.lineTo(0,this.plotHeight);
   this.backgroundMC.lineTo(0,0);
   this.backgroundMC.endFill();
   this.borderMC.clear();
   this.borderMC.lineStyle(1,0);
   this.borderMC.moveTo(0,0);
   this.borderMC.lineTo(this.plotWidth,0);
   this.borderMC.lineTo(this.plotWidth,this.plotHeight);
   this.borderMC.lineTo(0,this.plotHeight);
   this.borderMC.lineTo(0,0);
   this.plotAreaMaskMC.clear();
   this.plotAreaMaskMC.beginFill(16711680);
   this.plotAreaMaskMC.moveTo(0,0);
   this.plotAreaMaskMC.lineTo(this.plotWidth,0);
   this.plotAreaMaskMC.lineTo(this.plotWidth,this.plotHeight);
   this.plotAreaMaskMC.lineTo(0,this.plotHeight);
   this.plotAreaMaskMC.lineTo(0,0);
   this.plotAreaMaskMC.endFill();
   this.plotAreaMC._y = this.halfPlotHeight;
};
p.updateAxesColor = function()
{
   this.xAxisLabelColorObject.setRGB(this.axesColor);
   this.yAxisLabelColorObject.setRGB(this.axesColor);
   this.xTickmarksColorObject.setRGB(this.axesColor);
   this.yTickmarksColorObject.setRGB(this.axesColor);
   this.borderColorObject.setRGB(this.axesColor);
};
p.setPlotDimensions = function(width, height)
{
   this.plotWidth = width;
   this.plotHeight = height;
   this.halfPlotHeight = height / 2;
   this.initializeBackgroundAndBorder();
   this.initializePhaseCursor();
   this.update();
   this.updateHorizontalScale();
   this.plotAreaMC._x = this._phaseOffset * this.plotWidth;
   this.plotAreaMC.phaseCursorMC._x = this._cPhase * this.plotWidth;
   this.xTickmarksMC._y = this.plotHeight;
   this.yAxisLabelMC._y = this.halfPlotHeight;
   this.xAxisLabelMC._y = this.plotHeight;
   this.xAxisLabelMC._x = this.plotWidth / 2;
};
p.updateHorizontalScale = function()
{
   var tmc = this.xTickmarksMC;
   var tL = this.xAxisTickmarksList;
   tmc.clear();
   tmc.lineStyle(1,0);
   var i = 0;
   while(i < tL.length)
   {
      var tick = tL[i];
      var x = this.plotWidth * (((this._phaseOffset + tick.value) % 1 + 1) % 1);
      tmc.lineStyle(1,0);
      tmc.moveTo(x,0);
      tmc.lineTo(x,tick.extent);
      if(tick.mc != undefined)
      {
         tick.mc._x = x;
      }
      i++;
   }
};
p.initializeHorizontalScale = function()
{
   var tmc = this.createEmptyMovieClip("xTickmarksMC",15);
   var tL = this.xAxisTickmarksList;
   var i = 0;
   while(i < tL.length)
   {
      var tick = tL[i];
      if(tick.labelText != undefined)
      {
         tick.mc = tmc.attachMovie("RV Component X Tickmark Label","_" + i,i,{label:tick.labelText});
      }
      i++;
   }
   this.xTickmarksColorObject = new Color(this.xTickmarksMC);
   this.xTickmarksColorObject.setRGB(this.axesColor);
};
p.updateVerticalScale = function()
{
   var min = this.yAxisMin;
   var max = this.yAxisMax;
   var yScale = - this.yScale;
   var mc = this.yTickmarksMC;
   mc._visible = true;
   mc.clear();
   mc.lineStyle(1,0);
   var pow = Math.pow;
   var log = Math.log;
   var majorExtent = this.majorTickmarkExtent;
   var minorExtent = this.minorTickmarkExtent;
   var labelIndex = 0;
   var minimumSpacing = this.minScreenYSpacing / yScale;
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
   var startTickNum = Math.ceil(min / minorSpacing);
   var tickNumLimit = 1 + Math.floor(max / minorSpacing);
   var y = this.plotHeight - yScale * (minorSpacing * startTickNum - min);
   var f = - Math.floor(Math.log(majorSpacing) / 2.302585092994046);
   var i = startTickNum;
   while(i < tickNumLimit)
   {
      if(i % multiple == 0)
      {
         mc.moveTo(- majorExtent,y);
         mc.lineTo(0,y);
         var value = minorSpacing * i;
         if(labelIndex < this._yLabelCount)
         {
            var labelMC = mc["_" + labelIndex];
            labelMC.setValue(this.toFixed(value,f));
            labelMC._visible = true;
            labelMC._x = - majorExtent;
            labelMC._y = y;
         }
         else
         {
            mc.attachMovie("RV Component Y Tickmark Label","_" + this._yLabelCount,this._yLabelCount,{_x:- majorExtent,_y:y,value:this.toFixed(value,f)});
            this._yLabelCount++;
         }
         labelIndex++;
      }
      else
      {
         mc.moveTo(- minorExtent,y);
         mc.lineTo(0,y);
      }
      y -= yStep;
      i++;
   }
   var i = labelIndex;
   while(i < this._yLabelCount)
   {
      mc["_" + i]._visible = false;
      i++;
   }
};
p.updateCurve = function()
{
   var mc = this.plotAreaMC.curveMC.createEmptyMovieClip("_0",0);
   mc.lineStyle(this.curveThickness,this.curveColor);
   if(this.amplitude == null)
   {
      return undefined;
   }
   var pL = [];
   var atan = Math.atan;
   var sin = Math.sin;
   var cos = Math.cos;
   var tan = Math.tan;
   var xScale = this.plotWidth / 6.283185307179586;
   var yScale = this.yScale;
   var A = this.amplitude;
   var w = this._argument;
   var e = this._eccentricity;
   var k = Math.sqrt((1 + e) / (1 - e));
   var n = this.numCurveSteps;
   var taStep = 6.283185307179586 / n;
   var ta = 0;
   var lv = A * cos(w);
   var lma = 0;
   var lm = A * k * sin(w) / (e - 1);
   mc.moveTo(0,yScale * lv);
   var i = 0;
   while(i < n)
   {
      ta += taStep;
      var j = tan(0.5 * ta);
      var ea = 2 * atan(j / k);
      var ma = ea - e * sin(ea);
      if(ma < lma)
      {
         ma += 6.283185307179586;
      }
      var v = A * cos(w + ta);
      var m = A * sin(w + ta) * (k + j * j / k) / ((e * cos(ea) - 1) * (1 + j * j));
      var cma = (lv - v - lm * lma + m * ma) / (m - lm);
      if(cma > ma || cma < lma)
      {
         mc.lineTo(xScale * ma,yScale * v);
      }
      else
      {
         mc.curveTo(xScale * cma,yScale * (m * (cma - ma) + v),xScale * ma,yScale * v);
      }
      lm = m;
      lma = ma;
      lv = v;
      i++;
   }
   mc.duplicateMovieClip("_1",1);
   this.plotAreaMC.curveMC._1._x = - this.plotWidth;
};
p.updateMeasurements = function()
{
   this.plotAreaMC.createEmptyMovieClip("measurementsMC",5);
   this.plotAreaMC.measurementsMC._visible = this._showMeasurements;
   if(this.amplitude == null || !this._showMeasurements)
   {
      return undefined;
   }
   var mc = this.plotAreaMC.measurementsMC.createEmptyMovieClip("_0",0);
   this.doKeplersEquation();
   var n = this.numberOfMeasurements;
   var pw = this.plotWidth;
   var yScale = this.yScale;
   var A = this.amplitude;
   var e = this._eccentricity;
   var w = this._argument;
   var sin = Math.sin;
   var cos = Math.cos;
   var abs = Math.abs;
   var rand = Math.random;
   var tan = Math.tan;
   var sqrt = Math.sqrt;
   var atan = Math.atan;
   var log = Math.log;
   var k = sqrt((1 + e) / (1 - e));
   var d = 0;
   var pL = this.measurementsPointsList;
   var k2 = this.noise;
   var k3 = pw / 6.283185307179586;
   var k4 = pL.length / 2;
   n = Math.ceil(n / 2);
   var m = this.numFreshMeasurements / 2;
   if(n < m)
   {
      m = n;
   }
   var r = this.measurementDotSize / 2;
   var fc = this.measurementDotColor;
   var i = 0;
   while(i < m)
   {
      var o = x1 = x2 = 0;
      do
      {
         x1 = 2 * rand() - 1;
         x2 = 2 * rand() - 1;
         o = x1 * x1 + x2 * x2;
      }
      while(o >= 1);
      o = sqrt(-2 * log(o) / o);
      var error1 = k2 * x1 * o;
      var error2 = k2 * x2 * o;
      var ma = rand() * 2 * 3.141592653589793;
      var ea0 = 0;
      var ea1 = ma;
      do
      {
         ea0 = ea1;
         ea1 = ea0 + (ma + e * sin(ea0) - ea0) / (1 - e * cos(ea0));
      }
      while(abs(ea1 - ea0) > 0.001);
      var ta = 2 * atan(k * tan(ea1 / 2));
      var v = A * cos(w + ta) + error1;
      var x = ma * k3;
      var y = yScale * v;
      mc.moveTo(x + r,y);
      mc.beginFill(fc);
      mc.curveTo(x + r,y - r,x,y - r);
      mc.curveTo(x - r,y - r,x - r,y);
      mc.curveTo(x - r,y + r,x,y + r);
      mc.curveTo(x + r,y + r,x + r,y);
      mc.endFill();
      var ma = rand() * 2 * 3.141592653589793;
      var ea0 = 0;
      var ea1 = ma;
      do
      {
         ea0 = ea1;
         ea1 = ea0 + (ma + e * sin(ea0) - ea0) / (1 - e * cos(ea0));
      }
      while(abs(ea1 - ea0) > 0.001);
      var ta = 2 * atan(k * tan(ea1 / 2));
      var v = A * cos(w + ta) + error2;
      var x = ma * k3;
      var y = yScale * v;
      mc.moveTo(x + r,y);
      mc.beginFill(fc);
      mc.curveTo(x + r,y - r,x,y - r);
      mc.curveTo(x - r,y - r,x - r,y);
      mc.curveTo(x - r,y + r,x,y + r);
      mc.curveTo(x + r,y + r,x + r,y);
      mc.endFill();
      i++;
   }
   n -= m;
   var i = 0;
   while(i < n)
   {
      var o = x1 = x2 = 0;
      do
      {
         x1 = 2 * rand() - 1;
         x2 = 2 * rand() - 1;
         o = x1 * x1 + x2 * x2;
      }
      while(o >= 1);
      o = sqrt(-2 * log(o) / o);
      var error1 = k2 * x1 * o;
      var error2 = k2 * x2 * o;
      var p = pL[i];
      var v = A * cos(w + p.ta) + error1;
      var x = p.ma * k3;
      var y = yScale * v;
      mc.moveTo(x + r,y);
      mc.beginFill(fc);
      mc.curveTo(x + r,y - r,x,y - r);
      mc.curveTo(x - r,y - r,x - r,y);
      mc.curveTo(x - r,y + r,x,y + r);
      mc.curveTo(x + r,y + r,x + r,y);
      mc.endFill();
      var p = pL[k4 + i];
      var v = A * cos(w + p.ta) + error2;
      var x = p.ma * k3;
      var y = yScale * v;
      mc.moveTo(x + r,y);
      mc.beginFill(fc);
      mc.curveTo(x + r,y - r,x,y - r);
      mc.curveTo(x - r,y - r,x - r,y);
      mc.curveTo(x - r,y + r,x,y + r);
      mc.curveTo(x + r,y + r,x + r,y);
      mc.endFill();
      i++;
   }
   mc.duplicateMovieClip("_1",1);
   mc._x = - this.plotWidth;
};
p.doKeplersEquation = function()
{
   var n = 2 * Math.ceil(this.numberOfMeasurements / 2) - this.numFreshMeasurements;
   if(this._eccentricity == this._lastEccentricity && n <= this.measurementsPointsList.length)
   {
      return undefined;
   }
   this._lastEccentricity = this._eccentricity;
   var sin = Math.sin;
   var cos = Math.cos;
   var abs = Math.abs;
   var rand = Math.random;
   var tan = Math.tan;
   var atan = Math.atan;
   var e = this._eccentricity;
   var k = Math.sqrt((1 + e) / (1 - e));
   var pL = [];
   var i = 0;
   while(i < n)
   {
      var ma = rand() * 2 * 3.141592653589793;
      var ea0 = 0;
      var ea1 = ma;
      do
      {
         ea0 = ea1;
         ea1 = ea0 + (ma + e * sin(ea0) - ea0) / (1 - e * cos(ea0));
      }
      while(abs(ea1 - ea0) > 0.001);
      var ta = 2 * atan(k * tan(ea1 / 2));
      pL.push({ma:ma,ta:ta});
      i++;
   }
   this.measurementsPointsList = pL;
};
p.toFixed = function(x, f)
{
   if(isNaN(x) || !isFinite(x))
   {
      return "error";
   }
   var f = int(f);
   if(isNaN(f) || !isFinite(f))
   {
      return "error";
   }
   if(f <= 0)
   {
      var k = Math.pow(10,- f);
      return String(k * Math.round(x / k));
   }
   if(f > 20)
   {
      f = 20;
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
