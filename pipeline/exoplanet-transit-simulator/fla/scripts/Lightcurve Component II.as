function LightcurveComponentIIClass()
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
   this.createEmptyMovieClip("xTickmarksMC",15);
   this.attachMovie("LCII Component X Axis Label","xAxisLabelMC",16);
   this.createEmptyMovieClip("yTickmarksMC",20);
   this.attachMovie("LCII Component Y Axis Label","yAxisLabelMC",21);
   this.createEmptyMovieClip("borderMC",25);
   this.createEmptyMovieClip("phaseCursorMC",30);
   this.createEmptyMovieClip("phaseCursorMaskMC",35);
   this.xAxisLabelColorObject = new Color(this.xAxisLabelMC);
   this.yAxisLabelColorObject = new Color(this.yAxisLabelMC);
   this.xTickmarksColorObject = new Color(this.xTickmarksMC);
   this.yTickmarksColorObject = new Color(this.yTickmarksMC);
   this.borderColorObject = new Color(this.borderMC);
   this.plotAreaMC.setMask(this.plotAreaMaskMC);
   this.phaseCursorMC.setMask(this.phaseCursorMaskMC);
   this.plotAreaMC.createEmptyMovieClip("measurementsMC",5);
   this.plotAreaMC.createEmptyMovieClip("curveMC",10);
   this.plotAreaMC.measurementsMC.createEmptyMovieClip("mc1",1);
   this.plotAreaMC.curveMC.createEmptyMovieClip("mc1",1);
   this.phaseCursorMC.createEmptyMovieClip("normalMC",1);
   this.phaseCursorMC.normalMC._visible = true;
   this.phaseCursorMC.createEmptyMovieClip("activeMC",2);
   this.phaseCursorMC.activeMC._visible = false;
   this.backgroundMC.useHandCursor = false;
   this.backgroundMC.tabEnabled = false;
   this.backgroundMC.onPressFunc = function()
   {
      if(this._parent._regionShown == 0)
      {
         this.xOffset = this._xmouse - this._parent.plotAreaMC._x;
         this.onMouseMove = this.onMouseMoveFunc;
      }
   };
   this.backgroundMC.onMouseMoveFunc = function()
   {
      this._parent.setPhaseOffset((this._xmouse - this.xOffset) / this._parent._plotWidth,true);
      updateAfterEvent();
   };
   this.backgroundMC.onRelease = this.backgroundMC.onReleaseOutside = function()
   {
      delete this.onMouseMove;
   };
   this.phaseCursorMC.useHandCursor = false;
   this.phaseCursorMC.tabEnabled = false;
   this.phaseCursorMC.onRollOver = function()
   {
      this.activeMC._visible = true;
      this.normalMC._visible = false;
   };
   this.phaseCursorMC.onRollOut = function()
   {
      this.activeMC._visible = false;
      this.normalMC._visible = true;
   };
   this.phaseCursorMC.onReleaseOutside = function()
   {
      this.activeMC._visible = false;
      this.normalMC._visible = true;
      delete this.onMouseMove;
   };
   this.phaseCursorMC.onRelease = function()
   {
      delete this.onMouseMove;
   };
   this.phaseCursorMC.onPress = function()
   {
      this.xOffset = this._parent._xmouse - this._x;
      this.onMouseMove = this.onMouseMoveFunc;
   };
   this.phaseCursorMC.onMouseMoveFunc = function()
   {
      this._parent.setCPhase((this._parent._xmouse - this.xOffset) / this._parent._plotWidth,true);
      updateAfterEvent();
   };
   this._yLabelCount = 0;
   if(this.initRegionShown == undefined)
   {
      this.initRegionShown = "full curve";
   }
   if(this.initDataType == undefined)
   {
      this.initDataType = "visual flux";
   }
   if(this.resolution == undefined)
   {
      this.resolution = 2;
   }
   if(this.horizontalMargin == undefined)
   {
      this.horizontalMargin = 0.15;
   }
   if(this.fluxMargin == undefined)
   {
      this.fluxMargin = 2.5;
   }
   if(this.minFluxDifference == undefined)
   {
      this.minFluxDifference = 0.000001;
   }
   if(this.minFluxMarginPx == undefined)
   {
      this.minFluxMarginPx = 30;
   }
   if(this.magnitudeMargin == undefined)
   {
      this.magnitudeMargin = 2.5;
   }
   if(this.minMagnitudeDifference == undefined)
   {
      this.minMagnitudeDifference = 0.0001;
   }
   if(this.minMagnitudeMarginPx == undefined)
   {
      this.minMagnitudeMarginPx = 30;
   }
   if(this.magNoise == undefined)
   {
      this.magNoise = 0.1;
   }
   if(this.fluxNoise == undefined)
   {
      this.fluxNoise = 0.1;
   }
   if(this.initShowMeasurements == undefined)
   {
      this.initShowMeasurements = true;
   }
   if(this.numberOfMeasurements == undefined)
   {
      this.numberOfMeasurements = 150;
   }
   if(this.measurementDotSize == undefined)
   {
      this.measurementDotSize = 4;
   }
   if(this.measurementDotColor == undefined)
   {
      this.measurementDotColor = 10066329;
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
   this._curveParams = {};
   this._curveParams.temperature1 = null;
   this._curveParams.temperature2 = null;
   this._curveParams.radius1 = null;
   this._curveParams.radius2 = null;
   this._curveParams.separation = null;
   this._curveParams.eccentricity = null;
   this._curveParams.argument = null;
   this._curveParams.inclination = null;
   this._curveParams.mass1 = null;
   this._curveParams.mass2 = null;
   var LPSeparation = parseFloat(this.initSeparation);
   var LPEccentricity = parseFloat(this.initEccentricity);
   var LPLongitude = parseFloat(this.initLongitude);
   var LPInclination = parseFloat(this.initInclination);
   var LPMass1 = parseFloat(this.initMass1);
   var LPMass2 = parseFloat(this.initMass2);
   var LPRadius1 = parseFloat(this.initRadius1);
   var LPRadius2 = parseFloat(this.initRadius2);
   var LPTemperature1 = parseFloat(this.initTemperature1);
   var LPTemperature2 = parseFloat(this.initTemperature2);
   var paramsObj = {};
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
   if(isFinite(LPMass1) && !isNaN(LPMass1))
   {
      paramsObj.mass1 = LPMass1;
   }
   if(isFinite(LPMass2) && !isNaN(LPMass2))
   {
      paramsObj.mass2 = LPMass2;
   }
   if(isFinite(LPRadius1) && !isNaN(LPRadius1))
   {
      paramsObj.radius1 = LPRadius1;
   }
   if(isFinite(LPRadius2) && !isNaN(LPRadius2))
   {
      paramsObj.radius2 = LPRadius2;
   }
   if(isFinite(LPTemperature1) && !isNaN(LPTemperature1))
   {
      paramsObj.temperature1 = LPTemperature1;
   }
   if(isFinite(LPTemperature2) && !isNaN(LPTemperature2))
   {
      paramsObj.temperature2 = LPTemperature2;
   }
   this.setParameters(paramsObj);
   this.initializePhaseCursor();
   this.initializeHorizontalScale();
   this.updateAxesColor();
   this.setPlotDimensions(this.width,this.height);
   this.setPlotAxes(this.initRegionShown,this.initDataType);
   this.allowDragging = this.initAllowDragging;
   this.phaseOffset = this.initPhaseOffset;
   this.cursorPhase = this.initCursorPhase;
   this.showCurve = this.initShowCurve;
   this.showPhaseCursor = this.initShowPhaseCursor;
   this.showMeasurements = this.initShowMeasurements;
}
var p = LightcurveComponentIIClass.prototype = new MovieClip();
Object.registerClass("Lightcurve Component II",LightcurveComponentIIClass);
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
   var cP = this.getCursorPhase();
   this._phaseOffset = (arg % 1 + 1) % 1;
   if(this._regionShown == 0)
   {
      this.plotAreaMC._x = this._phaseOffset * this._plotWidth;
      this.setCursorPhase(cP,false);
      if(callChangeHandler)
      {
         this._parent[this.phaseOffsetChangeHandler](this._phaseOffset);
      }
   }
   else
   {
      this.plotAreaMC._x = 0;
   }
   this.updateCursorPosition();
   this.updateHorizontalScale();
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
};
p.addProperty("showMeasurements",p.getShowMeasurements,p.setShowMeasurements);
p.getShowPhaseCursor = function()
{
   return this.phaseCursorMC._visible;
};
p.setShowPhaseCursor = function(arg)
{
   this.phaseCursorMC._visible = arg;
};
p.addProperty("showPhaseCursor",p.getShowPhaseCursor,p.setShowPhaseCursor);
p.getCursorPhase = function()
{
   if(this._minPhase == null)
   {
      return null;
   }
   if(this._regionShown == 0)
   {
      return ((this._cPhase - this._phaseOffset) % 1 + 1) % 1;
   }
   var range = this._maxPhase - this._minPhase;
   if(range < 0)
   {
      range += 1;
   }
   return (this._minPhase + this._cPhase * range) % 1;
};
p.setCursorPhase = function(arg, callChangeHandler)
{
   arg = (arg % 1 + 1) % 1;
   if(this._minPhase == null)
   {
      this.setCPhase(arg,callChangeHandler);
   }
   else if(this._regionShown == 0)
   {
      var newCPhase = arg + this._phaseOffset;
      this.setCPhase(newCPhase,callChangeHandler);
   }
   else
   {
      var range = this._maxPhase - this._minPhase;
      if(range < 0)
      {
         range += 1;
      }
      var u = arg - this._minPhase;
      var newCPhase = u / range;
      if(newCPhase < 0)
      {
         newCPhase = 0;
      }
      else if(newCPhase > 1)
      {
         newCPhase = 1;
      }
      if(u < 0)
      {
         u += 1;
      }
      this.setCPhase(newCPhase,callChangeHandler);
   }
};
p.addProperty("cursorPhase",p.getCursorPhase,p.setCursorPhase);
p.setCPhase = function(arg, callChangeHandler)
{
   this._cPhase = (arg % 1 + 1) % 1;
   this.updateCursorPosition();
   if(callChangeHandler)
   {
      this._parent[this.phaseChangeHandler](this.cursorPhase);
   }
};
p.updateCursorPosition = function()
{
   this.phaseCursorMC._x = this._cPhase * this._plotWidth;
};
p.updateHorizontalScale = function()
{
   if(this._regionShown == 0)
   {
      this.xAxisLabelMC.axisLabel = "Phase";
   }
   else if(this._regionShown == 1)
   {
      this.xAxisLabelMC.axisLabel = "";
   }
   else if(this._regionShown == 2)
   {
      this.xAxisLabelMC.axisLabel = "";
   }
};
p.updateVerticalScale = function()
{
   var startTimer = getTimer();
   if(this._dataType == 0)
   {
      var min = this._minVisFluxNormed;
      var max = this._maxVisFluxNormed;
      var yScale = this.__yScaleNormed;
      var yStep = -1;
   }
   else
   {
      var min = this._minVisMag;
      var max = this._maxVisMag;
      var yScale = this.__yScale;
      var yStep = 1;
   }
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
   yStep *= minorSpacing * yScale;
   var startTickNum = Math.ceil(min / minorSpacing);
   var tickNumLimit = 1 + Math.floor(max / minorSpacing);
   if(this._dataType == 0)
   {
      var y = this._plotHeight - yScale * (minorSpacing * startTickNum - min);
   }
   else
   {
      var y = yScale * (minorSpacing * startTickNum - min);
   }
   var f = - Math.floor(log(majorSpacing) / 2.302585092994046);
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
            mc.attachMovie("LCII Component Y Tickmark Label","_" + this._yLabelCount,this._yLabelCount,{_x:- majorExtent,_y:y,value:this.toFixed(value,f)});
            this._yLabelCount++;
         }
         labelIndex++;
      }
      else
      {
         mc.moveTo(- minorExtent,y);
         mc.lineTo(0,y);
      }
      y += yStep;
      i++;
   }
   var i = labelIndex;
   while(i < this._yLabelCount)
   {
      mc["_" + i]._visible = false;
      i++;
   }
};
p.initializePhaseCursor = function()
{
   var mc = this.phaseCursorMC.activeMC;
   mc.clear();
   mc.lineStyle(this.phaseCursorActiveWidth,this.phaseCursorActiveColor,100);
   mc.moveTo(0,0);
   mc.lineTo(0,this._plotHeight);
   mc.moveTo(- this._plotWidth,0);
   mc.lineTo(- this._plotWidth,this._plotHeight);
   mc.moveTo(this._plotWidth,0);
   mc.lineTo(this._plotWidth,this._plotHeight);
   var mc = this.phaseCursorMC.normalMC;
   mc.clear();
   mc.lineStyle(this.phaseCursorNormalWidth,this.phaseCursorNormalColor,100);
   mc.moveTo(0,0);
   mc.lineTo(0,this._plotHeight);
   mc.moveTo(- this._plotWidth,0);
   mc.lineTo(- this._plotWidth,this._plotHeight);
   mc.moveTo(this._plotWidth,0);
   mc.lineTo(this._plotWidth,this._plotHeight);
};
p.initializeBackgroundAndBorder = function()
{
   this.backgroundMC.clear();
   this.backgroundMC.beginFill(this.backgroundColor,this.backgroundAlpha);
   this.backgroundMC.moveTo(0,0);
   this.backgroundMC.lineTo(this._plotWidth,0);
   this.backgroundMC.lineTo(this._plotWidth,this._plotHeight);
   this.backgroundMC.lineTo(0,this._plotHeight);
   this.backgroundMC.lineTo(0,0);
   this.backgroundMC.endFill();
   this.borderMC.clear();
   this.borderMC.lineStyle(1,0);
   this.borderMC.moveTo(0,0);
   this.borderMC.lineTo(this._plotWidth,0);
   this.borderMC.lineTo(this._plotWidth,this._plotHeight);
   this.borderMC.lineTo(0,this._plotHeight);
   this.borderMC.lineTo(0,0);
   this.plotAreaMaskMC.clear();
   this.plotAreaMaskMC.beginFill(16711680,3);
   this.plotAreaMaskMC.moveTo(0,0);
   this.plotAreaMaskMC.lineTo(this._plotWidth,0);
   this.plotAreaMaskMC.lineTo(this._plotWidth,this._plotHeight);
   this.plotAreaMaskMC.lineTo(0,this._plotHeight);
   this.plotAreaMaskMC.lineTo(0,0);
   this.plotAreaMaskMC.endFill();
   this.phaseCursorMaskMC.clear();
   this.phaseCursorMaskMC.beginFill(255,3);
   this.phaseCursorMaskMC.moveTo(0,0);
   this.phaseCursorMaskMC.lineTo(this._plotWidth,0);
   this.phaseCursorMaskMC.lineTo(this._plotWidth,this._plotHeight);
   this.phaseCursorMaskMC.lineTo(0,this._plotHeight);
   this.phaseCursorMaskMC.lineTo(0,0);
   this.phaseCursorMaskMC.endFill();
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
   this._plotWidth = width;
   this._plotHeight = height;
   this.initializeBackgroundAndBorder();
   this.initializePhaseCursor();
   this.update();
   this.setPhaseOffset(this._phaseOffset,false);
   this.updateCursorPosition();
   this.xTickmarksMC._y = this._plotHeight;
   this.yAxisLabelMC._y = this._plotHeight / 2;
   this.xAxisLabelMC._y = this._plotHeight;
   this.xAxisLabelMC._x = this._plotWidth / 2;
};
p.setParameters = function(params)
{
   if(params.separation != undefined)
   {
      this._curveParams.separation = params.separation;
   }
   if(params.eccentricity != undefined)
   {
      this._curveParams.eccentricity = params.eccentricity;
   }
   if(params.longitude != undefined)
   {
      this._curveParams.argument = params.longitude * 3.141592653589793 / 180;
   }
   if(params.inclination != undefined)
   {
      this._curveParams.inclination = params.inclination * 3.141592653589793 / 180;
   }
   if(params.mass1 != undefined)
   {
      this._curveParams.mass1 = params.mass1;
   }
   if(params.mass2 != undefined)
   {
      this._curveParams.mass2 = params.mass2;
   }
   if(params.radius1 != undefined)
   {
      this._curveParams.radius1 = params.radius1;
   }
   if(params.radius2 != undefined)
   {
      this._curveParams.radius2 = params.radius2;
   }
   if(params.temperature1 != undefined)
   {
      this._curveParams.temperature1 = params.temperature1;
   }
   if(params.temperature2 != undefined)
   {
      this._curveParams.temperature2 = params.temperature2;
   }
   this.systemIsDefined = this._curveParams.temperature1 != null && this._curveParams.temperature2 != null && this._curveParams.radius1 != null && this._curveParams.radius2 != null && this._curveParams.separation != null && this._curveParams.eccentricity != null && this._curveParams.argument != null && this._curveParams.inclination != null;
   this.systemPeriod = null;
   this.eclipseOfBody1Duration = null;
   this.eclipseOfBody2Duration = null;
   this.systemIsInOvercontact = this.checkForOvercontant(this._curveParams);
   if(this.systemIsDefined)
   {
      this._curveEvents = this.getCurveEventsObject(this._curveParams);
      if(this._curveParams.mass1 != null && this._curveParams.mass2 != null)
      {
         var a = this._curveParams.separation;
         this.systemPeriod = Math.sqrt(39.47841760435743 * a * a * a / (6.673e-11 * (this._curveParams.mass1 + this._curveParams.mass2)));
         if(this._curveEvents.eclipseOfBody1.occurs)
         {
            this.eclipseOfBody1Duration = this.systemPeriod * this._curveEvents.eclipseOfBody1.duration.phase;
         }
         else
         {
            this.eclipseOfBody1Duration = 0;
         }
         if(this._curveEvents.eclipseOfBody2.occurs)
         {
            this.eclipseOfBody2Duration = this.systemPeriod * this._curveEvents.eclipseOfBody2.duration.phase;
         }
         else
         {
            this.eclipseOfBody2Duration = 0;
         }
      }
   }
};
p.checkForOvercontact = function(params)
{
   var minSep = (params.radius1 + params.radius2) / (1 - params.eccentricity);
   return params.separation < minSep;
};
p.setPlotAxes = function(regionShown, dataType)
{
   if(dataType == "visual flux" || dataType == "flux")
   {
      this._dataType = 0;
      this.yAxisLabelMC.axisLabel = "Normalized Flux";
   }
   else if(dataType == "visual magnitude" || dataType == "magnitude")
   {
      this._dataType = 1;
      this.yAxisLabelMC.axisLabel = "Absolute Magnitude";
   }
   if(regionShown == "full" || regionShown == "full curve" || regionShown == "all")
   {
      this._regionShown = 0;
   }
   else if(regionShown == "eclipse of body 1")
   {
      this._regionShown = 1;
   }
   else if(regionShown == "eclipse of body 2")
   {
      this._regionShown = 2;
   }
   this.setPhaseOffset(this._phaseOffset,false);
};
p.update = function()
{
   var startTimer = getTimer();
   if(this.systemIsDefined)
   {
      if(this._regionShown == 0)
      {
         this.__xScale = this._plotWidth;
         this._minPhase = 0;
         this._maxPhase = 1;
      }
      else
      {
         var eclipse = this._curveEvents["eclipseOfBody" + this._regionShown];
         if(eclipse.occurs)
         {
            this.__xScale = this._plotWidth * (1 - 2 * this.horizontalMargin) / eclipse.duration.phase;
            this._minPhase = ((eclipse.start.phase - this.horizontalMargin * this._plotWidth / this.__xScale) % 1 + 1) % 1;
            this._maxPhase = (this._minPhase + this._plotWidth / this.__xScale) % 1;
         }
         else
         {
            var w = this._curveParams.argument;
            var e = this._curveParams.eccentricity;
            if(this._regionShown == 1)
            {
               var _TA = 1.5707963267948966 - w;
            }
            else
            {
               var _TA = 4.71238898038469 - w;
            }
            var _EA = 2 * Math.atan(Math.tan(0.5 * _TA) / Math.sqrt((1 + e) / (1 - e)));
            var _MA = _EA - e * Math.sin(_EA);
            var centerPhase = (_MA / 6.283185307179586 % 1 + 1) % 1;
            var delta = 0.001;
            this._maxPhase = (centerPhase + delta) % 1;
            this._minPhase = ((centerPhase - delta) % 1 + 1) % 1;
            this.__xScale = this._plotWidth / (2 * delta);
         }
      }
   }
   else
   {
      this.__xScale = null;
      this._minPhase = null;
      this._maxPhase = null;
   }
   this.updateCurve();
   this.updateMeasurements();
   this.updateVerticalScale();
};
p.updateCurve = function()
{
   var startTimer = getTimer();
   this.plotAreaMC.curveMC.mc2.removeMovieClip();
   this.plotAreaMC.curveMC.mc3.removeMovieClip();
   var mc = this.plotAreaMC.curveMC.mc1;
   mc.clear();
   mc.lineStyle(this.curveThickness,this.curveColor);
   if(!this.systemIsDefined)
   {
      this._maxVisFluxNormed = null;
      this._minVisFluxNormed = null;
      this.__yScaleNormed = null;
      this._minVisMag = null;
      this._maxVisMag = null;
      this.__yScale = null;
      this._yOffset = null;
      return undefined;
   }
   var minPhase = this._minPhase;
   var maxPhase = this._maxPhase;
   var xScale = this.__xScale;
   var res = xScale / this.resolution;
   var addPhases = function(pL, eclipse)
   {
      if(!eclipse.occurs)
      {
         return undefined;
      }
      var start = eclipse.start.phase;
      var middle = eclipse.maxDepth.phase;
      var end = eclipse.end.phase;
      var half1 = middle - start;
      if(half1 < 0)
      {
         half1 += 1;
      }
      var half2 = end - middle;
      if(half2 < 0)
      {
         half2 += 1;
      }
      var n1 = 1 + Math.ceil(half1 * res);
      var step1 = half1 / (n1 - 1);
      var n2 = 1 + Math.ceil(half2 * res);
      var step2 = half2 / (n2 - 1);
      var i = 0;
      while(i < n1)
      {
         pL.push({phase:(start + i * step1) % 1});
         i++;
      }
      var i = 1;
      while(i < n2)
      {
         pL.push({phase:(middle + i * step2) % 1});
         i++;
      }
   };
   var pL = [];
   if(this._regionShown == 0)
   {
      addPhases(pL,this._curveEvents.eclipseOfBody1);
      addPhases(pL,this._curveEvents.eclipseOfBody2);
      if(pL.length == 0)
      {
         pL.push({phase:minPhase});
      }
      pL.push({phase:pL[0].phase + 1});
   }
   else
   {
      pL.push({phase:minPhase});
      addPhases(pL,this._curveEvents["eclipseOfBody" + this._regionShown]);
      pL.push({phase:maxPhase});
   }
   this.addVisFluxAndVisMagProperties(pL,this._curveParams,this._curveEvents);
   var startPhase = pL[0].phase;
   var maxVisFlux = pL[0].visFlux;
   var minVisMag = pL[0].visMag;
   var minVisFlux = Infinity;
   var maxVisMag = -Infinity;
   var i = 0;
   while(i < pL.length)
   {
      var p = pL[i];
      if(p.visFlux < minVisFlux)
      {
         minVisFlux = p.visFlux;
         maxVisMag = p.visMag;
      }
      if(p.phase < startPhase)
      {
         p.phase += 1;
      }
      i++;
   }
   this._minPlottedVisMag = minVisMag;
   this._maxPlottedVisMag = maxVisMag;
   this.plottedVisualFluxDepth = (maxVisFlux - minVisFlux) / maxVisFlux;
   if(this._dataType == 0)
   {
      var noiseMargin = maxVisFlux * this.fluxNoise * this.fluxMargin;
      var halfVisFluxDiff = (maxVisFlux - minVisFlux) / 2;
      var centerFlux = minVisFlux + halfVisFluxDiff;
      if(halfVisFluxDiff == 0 && noiseMargin == 0)
      {
         var yScale = (- this._plotHeight) / (maxVisFlux * this.minFluxDifference);
      }
      else
      {
         var yScale = (- this._plotHeight / 2) / (halfVisFluxDiff + noiseMargin);
      }
      if((- yScale) * noiseMargin < this.minFluxMarginPx)
      {
         var yScale = (- (this._plotHeight / 2 - this.minFluxMarginPx)) / halfVisFluxDiff;
      }
      if((- this._plotHeight) / yScale < maxVisFlux * this.minFluxDifference)
      {
         var yScale = (- this._plotHeight) / (maxVisFlux * this.minFluxDifference);
      }
      var topFlux = centerFlux - 0.5 * this._plotHeight / yScale;
      var botFlux = centerFlux + 0.5 * this._plotHeight / yScale;
      var yOffset = (- yScale) * topFlux;
      this.__yScale = yScale;
      this._yOffset = yOffset;
      this._maxVisFluxNormed = topFlux / maxVisFlux;
      this._minVisFluxNormed = botFlux / maxVisFlux;
      this.__yScaleNormed = this._plotHeight * maxVisFlux / (topFlux - botFlux);
      var x = xScale * (pL[0].phase - minPhase);
      var y = yOffset + yScale * pL[0].visFlux;
      mc.moveTo(x,y);
      var i = 1;
      while(i < pL.length)
      {
         var x = xScale * (pL[i].phase - minPhase);
         var y = yOffset + yScale * pL[i].visFlux;
         mc.lineTo(x,y);
         i++;
      }
   }
   else
   {
      var noiseMargin = this.magNoise * this.magnitudeMargin;
      var halfVisMagDiff = (maxVisMag - minVisMag) / 2;
      var centerMag = minVisMag + halfVisMagDiff;
      if(halfVisMagDiff == 0 && noiseMargin == 0)
      {
         var yScale = this._plotHeight / this.minMagnitudeDifference;
      }
      else
      {
         var yScale = this._plotHeight / 2 / (halfVisMagDiff + noiseMargin);
      }
      if(yScale * noiseMargin < this.minMagnitudeMarginPx)
      {
         var yScale = (this._plotHeight / 2 - this.minMagnitudeMarginPx) / (centerMag - minVisMag);
      }
      if(this._plotHeight / yScale < this.minMagnitudeDifference)
      {
         var yScale = this._plotHeight / this.minMagnitudeDifference;
      }
      var topMag = centerMag - 0.5 * this._plotHeight / yScale;
      var botMag = centerMag + 0.5 * this._plotHeight / yScale;
      var yOffset = (- yScale) * topMag;
      this._minVisMag = topMag;
      this._maxVisMag = botMag;
      this.__yScale = yScale;
      this._yOffset = yOffset;
      var x = xScale * (pL[0].phase - minPhase);
      var y = yOffset + yScale * pL[0].visMag;
      mc.moveTo(x,y);
      var i = 1;
      while(i < pL.length)
      {
         var x = xScale * (pL[i].phase - minPhase);
         var y = yOffset + yScale * pL[i].visMag;
         mc.lineTo(x,y);
         i++;
      }
   }
   duplicateMovieClip(this.plotAreaMC.curveMC.mc1,"mc2",16386);
   duplicateMovieClip(this.plotAreaMC.curveMC.mc1,"mc3",16387);
   this.plotAreaMC.curveMC.mc1._x = -2 * this._plotWidth;
   this.plotAreaMC.curveMC.mc2._x = - this._plotWidth;
   this.plotAreaMC.curveMC.mc3._x = 0;
};
p.updateMeasurements = function()
{
   var startTimer = getTimer();
   this.plotAreaMC.measurementsMC.mc2.removeMovieClip();
   var mc = this.plotAreaMC.measurementsMC.mc1;
   mc.clear();
   if(!this.systemIsDefined)
   {
      return undefined;
   }
   var magNoise = this.magNoise;
   var fluxNoise = this.fluxNoise;
   var n = this.numberOfMeasurements;
   var xScale = this.__xScale;
   var minPhase = this._minPhase;
   var yScale = this.__yScale;
   var yOffset = this._yOffset;
   var phaseRange = this._plotWidth / xScale;
   var rand = Math.random;
   var log = Math.log;
   var pow = Math.pow;
   var sqrt = Math.sqrt;
   var pL = [];
   var i = 0;
   while(i < n)
   {
      pL.push({phase:(minPhase + phaseRange * rand()) % 1});
      i++;
   }
   this.addVisFluxAndVisMagProperties(pL,this._curveParams,this._curveEvents);
   var maxVisFlux = pL[0].visFlux;
   var nL = [];
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
      var p = pL[i];
      p.visMag += magNoise * x1 * o;
      p.visFlux = maxVisFlux * (p.visFlux / maxVisFlux + fluxNoise * x1 * o);
      var p = pL[i + 1];
      p.visMag += magNoise * x2 * o;
      p.visFlux = maxVisFlux * (p.visFlux / maxVisFlux + fluxNoise * x2 * o);
      i += 2;
   }
   var r = this.measurementDotSize / 2;
   var fc = this.measurementDotColor;
   if(this._dataType == 0)
   {
      var i = 0;
      while(i < n)
      {
         var u = pL[i].phase - minPhase;
         if(u < 0)
         {
            u += 1;
         }
         var x = xScale * u;
         var y = yOffset + yScale * pL[i].visFlux;
         mc.moveTo(x + r,y);
         mc.beginFill(fc);
         mc.curveTo(x + r,y - r,x,y - r);
         mc.curveTo(x - r,y - r,x - r,y);
         mc.curveTo(x - r,y + r,x,y + r);
         mc.curveTo(x + r,y + r,x + r,y);
         mc.endFill();
         i++;
      }
   }
   else
   {
      var i = 0;
      while(i < n)
      {
         var u = pL[i].phase - minPhase;
         if(u < 0)
         {
            u += 1;
         }
         var x = xScale * u;
         var y = yOffset + yScale * pL[i].visMag;
         mc.moveTo(x + r,y);
         mc.beginFill(fc);
         mc.curveTo(x + r,y - r,x,y - r);
         mc.curveTo(x - r,y - r,x - r,y);
         mc.curveTo(x - r,y + r,x,y + r);
         mc.curveTo(x + r,y + r,x + r,y);
         mc.endFill();
         i++;
      }
   }
   duplicateMovieClip(this.plotAreaMC.measurementsMC.mc1,"mc2",16386);
   this.plotAreaMC.measurementsMC.mc1._x = 0;
   this.plotAreaMC.measurementsMC.mc2._x = - this._plotWidth;
};
p.getBolometricCorrection = function(T)
{
   var logTeff = Math.log(T) / 2.302585092994046;
   if(logTeff > 3.9)
   {
      var k = {a:-100139.4991,b:116264.1842,c:-53931.97541,d:12495.04227,e:-1445.868048,f:66.84924471};
   }
   else if(logTeff < 3.7)
   {
      var k = {a:-13884.14899,b:8595.127427,c:-488.3425525,d:-627.0092238,e:137.4608131,f:-7.549572042};
   }
   else
   {
      var k = {a:1439.981506,b:-151.9002581,c:-995.1089203,d:582.5176671,e:-123.3293641,f:9.160761128};
   }
   var BC = k.a + logTeff * (k.b + logTeff * (k.c + logTeff * (k.d + logTeff * (k.e + k.f * logTeff))));
   return BC;
};
p.getCurveEventsObject = function(params)
{
   var startTimer = getTimer();
   var curveEvents = {eclipseOfBody1:{occurs:false},eclipseOfBody2:{occurs:false}};
   var sin = Math.sin;
   var cos = Math.cos;
   var tan = Math.tan;
   var atan = Math.atan;
   var a = params.separation;
   var e = params.eccentricity;
   var i = params.inclination;
   var w = params.argument;
   var r1 = params.radius1;
   var r2 = params.radius2;
   var R = (r1 + r2) / a;
   var C1 = Math.sqrt((1 + e) / (1 - e));
   var S2 = cos(i) * cos(i);
   var S1 = 1 - S2;
   var K1 = (1 - e * e) * (1 - e * e) * S1;
   var K2 = (- e) * e * R * R;
   var K3 = -2 * e * R * R;
   var K4 = (1 - e * e) * (1 - e * e) * S2 - R * R;
   var L1 = - K1;
   var L2 = 2 * K2;
   var L3 = K3;
   var tempList = [];
   var n = 100;
   var vStep = 6.283185307179586 / n;
   var v = - vStep;
   var vLast = v;
   var derLast = L1 * sin(2 * (v + w)) - sin(v) * (L2 * cos(v) + L3);
   var negLast = derLast < 0;
   var j = 0;
   while(j < n)
   {
      var v = j * vStep;
      var der = L1 * sin(2 * (v + w)) - sin(v) * (L2 * cos(v) + L3);
      var neg = der < 0;
      if(neg != negLast)
      {
         var a = vLast;
         var b = v;
         var c = a;
         var counter = 0;
         do
         {
            var fa = L1 * sin(2 * (a + w)) - sin(a) * (L2 * cos(a) + L3);
            var fb = L1 * sin(2 * (b + w)) - sin(b) * (L2 * cos(b) + L3);
            var fc = L1 * sin(2 * (c + w)) - sin(c) * (L2 * cos(c) + L3);
            if(fa != fc && fb != fc)
            {
               var d = a * fb * fc / ((fa - fb) * (fa - fc)) + b * fa * fc / ((fb - fa) * (fb - fc)) + c * fa * fb / ((fc - fa) * (fc - fb));
            }
            else
            {
               var d = b - fb * ((b - a) / (fb - fa));
            }
            var m = (a + b) / 2;
            if(m < b && (d > b || d < m) || m > b && (d < b || d > m))
            {
               d = m;
            }
            var fd = L1 * sin(2 * (d + w)) - sin(d) * (L2 * cos(d) + L3);
            if(fb * fd < 0)
            {
               a = b;
            }
            c = b;
            b = d;
            counter++;
         }
         while((fd < -5e-15 || fd > 5e-15) && counter < 200);
         if(counter >= 200)
         {
            trace("*** warning, iteration limit reached at point A ***");
         }
         var f = K1 * cos(d + w) * cos(d + w) + K2 * cos(d) * cos(d) + K3 * cos(d) + K4;
         if(f < 0)
         {
            tempList.push({min:((d + w) % 6.283185307179586 + 6.283185307179586) % 6.283185307179586 - w});
         }
      }
      negLast = neg;
      derLast = der;
      vLast = v;
      j++;
   }
   if(tempList.length > 2)
   {
      trace("*** warning, more than two minimums of f found ***");
   }
   else
   {
      var i = 0;
      while(i < tempList.length)
      {
         tempList[i].endPoints = [];
         var min = tempList[i].min;
         if(min + w < 3.141592653589793)
         {
            var endsList = [- w,3.141592653589793 - w];
         }
         else
         {
            var endsList = [3.141592653589793 - w,6.283185307179586 - w];
         }
         var j = 0;
         while(j < 2)
         {
            var a = min;
            var b = endsList[j];
            var c = a;
            var counter = 0;
            do
            {
               var fa = K1 * cos(a + w) * cos(a + w) + K2 * cos(a) * cos(a) + K3 * cos(a) + K4;
               var fb = K1 * cos(b + w) * cos(b + w) + K2 * cos(b) * cos(b) + K3 * cos(b) + K4;
               var fc = K1 * cos(c + w) * cos(c + w) + K2 * cos(c) * cos(c) + K3 * cos(c) + K4;
               if(fa != fc && fb != fc)
               {
                  var d = a * fb * fc / ((fa - fb) * (fa - fc)) + b * fa * fc / ((fb - fa) * (fb - fc)) + c * fa * fb / ((fc - fa) * (fc - fb));
               }
               else
               {
                  var d = b - fb * ((b - a) / (fb - fa));
               }
               var m = (a + b) / 2;
               if(m < b && (d > b || d < m) || m > b && (d < b || d > m))
               {
                  d = m;
               }
               var fd = K1 * cos(d + w) * cos(d + w) + K2 * cos(d) * cos(d) + K3 * cos(d) + K4;
               if(fb * fd < 0)
               {
                  a = b;
               }
               c = b;
               b = d;
               counter++;
            }
            while((fd < -5e-15 || fd > 5e-15) && counter < 200);
            if(counter >= 200)
            {
               trace("*** warning, iteration limit reached at point B ***");
            }
            tempList[i].endPoints.push(((d + w) % 6.283185307179586 + 6.283185307179586) % 6.283185307179586 - w);
            j++;
         }
         i++;
      }
      var getPhaseFromTrueAnomaly = function(_TA)
      {
         var _EA = 2 * atan(tan(0.5 * _TA) / C1);
         var _MA = _EA - e * sin(_EA);
         return (_MA / 6.283185307179586 % 1 + 1) % 1;
      };
      var i = 0;
      while(i < tempList.length)
      {
         var u = tempList[i].min + w;
         if(u < 3.141592653589793)
         {
            var eclipse = curveEvents.eclipseOfBody1;
         }
         else
         {
            var eclipse = curveEvents.eclipseOfBody2;
         }
         eclipse.occurs = true;
         eclipse.start = {};
         eclipse.start.trueAnomaly = tempList[i].endPoints[0];
         eclipse.start.phase = getPhaseFromTrueAnomaly(eclipse.start.trueAnomaly);
         eclipse.end = {};
         eclipse.end.trueAnomaly = tempList[i].endPoints[1];
         eclipse.end.phase = getPhaseFromTrueAnomaly(eclipse.end.trueAnomaly);
         eclipse.duration = {};
         eclipse.duration.phase = eclipse.end.phase - eclipse.start.phase;
         if(eclipse.duration.phase < 0)
         {
            eclipse.duration.phase += 1;
         }
         eclipse.duration.trueAnomaly = eclipse.end.trueAnomaly - eclipse.start.trueAnomaly;
         if(eclipse.duration.trueAnomaly < 0)
         {
            eclipse.duration.trueAnomaly += 6.283185307179586;
         }
         var vMid = eclipse.start.trueAnomaly + eclipse.duration.trueAnomaly / 2;
         var n = 50;
         var vStep = 3.141592653589793 / (2 * n);
         var counter = 0;
         var v = vMid;
         do
         {
            v -= vStep;
            var S3 = cos(v + w);
            var S4 = 1 + e * cos(v);
            var f = ((S1 * S3 * S3 + S2) * e * sin(v) / S4 - S1 * S3 * sin(v + w)) / (S4 * S4);
            counter++;
         }
         while(f >= 0 && counter <= n);
         if(counter > n)
         {
            trace("*** warning, problem at point C ***");
         }
         var vLeft = v;
         var counter = 0;
         var v = vMid;
         do
         {
            v += vStep;
            var S3 = cos(v + w);
            var S4 = 1 + e * cos(v);
            var f = ((S1 * S3 * S3 + S2) * e * sin(v) / S4 - S1 * S3 * sin(v + w)) / (S4 * S4);
            counter++;
         }
         while(f <= 0 && counter <= n);
         if(counter > n)
         {
            trace("*** warning, problem at point D ***");
         }
         var vRight = v;
         var a = vLeft;
         var b = vRight;
         var c = a;
         var counter = 0;
         do
         {
            var S3 = cos(a + w);
            var S4 = 1 + e * cos(a);
            var fa = ((S1 * S3 * S3 + S2) * e * sin(a) / S4 - S1 * S3 * sin(a + w)) / (S4 * S4);
            var S3 = cos(b + w);
            var S4 = 1 + e * cos(b);
            var fb = ((S1 * S3 * S3 + S2) * e * sin(b) / S4 - S1 * S3 * sin(b + w)) / (S4 * S4);
            var S3 = cos(c + w);
            var S4 = 1 + e * cos(c);
            var fc = ((S1 * S3 * S3 + S2) * e * sin(c) / S4 - S1 * S3 * sin(c + w)) / (S4 * S4);
            if(fa != fc && fb != fc)
            {
               var d = a * fb * fc / ((fa - fb) * (fa - fc)) + b * fa * fc / ((fb - fa) * (fb - fc)) + c * fa * fb / ((fc - fa) * (fc - fb));
            }
            else
            {
               var d = b - fb * ((b - a) / (fb - fa));
            }
            var m = (a + b) / 2;
            if(m < b && (d > b || d < m) || m > b && (d < b || d > m))
            {
               d = m;
            }
            var S3 = cos(d + w);
            var S4 = 1 + e * cos(d);
            var fd = ((S1 * S3 * S3 + S2) * e * sin(d) / S4 - S1 * S3 * sin(d + w)) / (S4 * S4);
            if(fb * fd < 0)
            {
               a = b;
            }
            c = b;
            b = d;
            counter++;
         }
         while((fd < -5e-15 || fd > 5e-15) && counter < 200);
         if(counter >= 200)
         {
            trace("*** warning, iteration limit reached at point E ***");
         }
         eclipse.maxDepth = {};
         eclipse.maxDepth.trueAnomaly = ((d + w) % 6.283185307179586 + 6.283185307179586) % 6.283185307179586 - w;
         eclipse.maxDepth.phase = getPhaseFromTrueAnomaly(eclipse.maxDepth.trueAnomaly);
         i++;
      }
   }
   return curveEvents;
};
p.addVisFluxAndVisMagProperties = function(pointList, params, curveEvents)
{
   var startTimer = getTimer();
   var cos = Math.cos;
   var sin = Math.sin;
   var abs = Math.abs;
   var atan = Math.atan;
   var acos = Math.acos;
   var tan = Math.tan;
   var sqrt = Math.sqrt;
   var log = Math.log;
   var eclipse1 = curveEvents.eclipseOfBody1;
   var eclipse2 = curveEvents.eclipseOfBody2;
   var a = params.separation;
   var e = params.eccentricity;
   var i = params.inclination;
   var w = params.argument;
   var r1 = params.radius1;
   var r2 = params.radius2;
   var t1 = params.temperature1;
   var t2 = params.temperature2;
   var C1 = sqrt((1 + e) / (1 - e));
   var J0 = a * (1 - e * e);
   var J1 = J0 * J0 * (1 - cos(i) * cos(i));
   var J2 = J0 * J0 * cos(i) * cos(i);
   var J3 = 2 * e;
   var J4 = e * e;
   var R12 = r1 * r1;
   var R22 = r2 * r2;
   var Z0 = 1 / (2 * r2);
   var Z1 = (R22 - R12) * Z0;
   var Z2 = 1 / (2 * r1);
   var Z3 = (R12 - R22) * Z2;
   var BC1 = this.getBolometricCorrection(t1);
   var BC2 = this.getBolometricCorrection(t2);
   var H1 = 1.89553328524593e-43 * Math.pow(t1,4) * Math.pow(10,BC1 / 2.5);
   var H2 = 1.89553328524593e-43 * Math.pow(t2,4) * Math.pow(10,BC2 / 2.5);
   var maxVisFlux = (R12 * H1 + R22 * H2) * 3.141592653589793;
   var minVisMag = -18.9669559998301 - 1.0857362047581294 * log(maxVisFlux);
   if(eclipse1.occurs && eclipse2.occurs)
   {
      var end1 = eclipse1.end.phase;
      var start1 = eclipse1.start.phase;
      var end2 = eclipse2.end.phase;
      var start2 = eclipse2.start.phase;
      if(end1 < start1)
      {
         var getRegion = function(phase)
         {
            if(phase < end1 || phase > start1)
            {
               return 1;
            }
            if(phase > start2 && phase < end2)
            {
               return 2;
            }
            return 0;
         };
      }
      else if(end2 < start2)
      {
         var getRegion = function(phase)
         {
            if(phase > start1 && phase < end1)
            {
               return 1;
            }
            if(phase < end2 || phase > start2)
            {
               return 2;
            }
            return 0;
         };
      }
      else
      {
         var getRegion = function(phase)
         {
            if(phase > start1 && phase < end1)
            {
               return 1;
            }
            if(phase > start2 && phase < end2)
            {
               return 2;
            }
            return 0;
         };
      }
   }
   else if(eclipse1.occurs)
   {
      var end = eclipse1.end.phase;
      var start = eclipse1.start.phase;
      if(end < start)
      {
         var getRegion = function(phase)
         {
            if(phase < end || phase > start)
            {
               return 1;
            }
            return 0;
         };
      }
      else
      {
         var getRegion = function(phase)
         {
            if(phase > start && phase < end)
            {
               return 1;
            }
            return 0;
         };
      }
   }
   else if(eclipse2.occurs)
   {
      var end = eclipse2.end.phase;
      var start = eclipse2.start.phase;
      if(end < start)
      {
         var getRegion = function(phase)
         {
            if(phase < end || phase > start)
            {
               return 2;
            }
            return 0;
         };
      }
      else
      {
         var getRegion = function(phase)
         {
            if(phase > start && phase < end)
            {
               return 2;
            }
            return 0;
         };
      }
   }
   else
   {
      var getRegion = function(phase)
      {
         return 0;
      };
   }
   var i = 0;
   while(i < pointList.length)
   {
      var pt = pointList[i];
      var region = getRegion(pt.phase);
      if(region == 0)
      {
         pt.visMag = minVisMag;
         pt.visFlux = maxVisFlux;
      }
      else
      {
         var ma = pt.phase * 2 * 3.141592653589793;
         var ea0 = 0;
         var ea1 = ma;
         var counter = 0;
         do
         {
            ea0 = ea1;
            ea1 = ea0 + (ma + e * sin(ea0) - ea0) / (1 - e * cos(ea0));
            counter++;
         }
         while(abs(ea1 - ea0) > 0.001 && counter < 100);
         if(counter >= 100)
         {
            trace("*** warning, iteration limit reached ***");
         }
         var v = 2 * atan(C1 * tan(ea1 / 2));
         var d = sqrt((J1 * cos(w + v) * cos(w + v) + J2) / (1 + J3 * cos(v) + J4 * cos(v) * cos(v)));
         if(d == 0)
         {
            d = 1e-8;
         }
         var ca = Z0 * d + Z1 / d;
         var cb = Z2 * d + Z3 / d;
         if(ca < -1)
         {
            ca = -1;
         }
         else if(ca > 1)
         {
            ca = 1;
         }
         if(cb < -1)
         {
            cb = -1;
         }
         else if(cb > 1)
         {
            cb = 1;
         }
         var alpha = acos(ca);
         var beta = acos(cb);
         var overlap = R22 * (alpha - ca * sin(alpha)) + R12 * (beta - cb * sin(beta));
         if(region == 1)
         {
            pt.visFlux = maxVisFlux - H1 * overlap;
         }
         else
         {
            pt.visFlux = maxVisFlux - H2 * overlap;
         }
         pt.visMag = -18.9669559998301 - 1.0857362047581294 * log(pt.visFlux);
      }
      i++;
   }
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
