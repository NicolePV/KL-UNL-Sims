function TimelineClass()
{
   this.areaWidth = 260;
   this.areaHeight = 200;
   this.placeholderMC._visible = false;
   if(this.simulatorMC == undefined)
   {
      this.simulatorMC = this._parent;
   }
   this.initialize();
}
var p = TimelineClass.prototype = new MovieClip();
Object.registerClass("Timeline",TimelineClass);
p.borderThickness = 1;
p.borderColor = 10066329;
p.backgroundColor = 16777215;
p.cycleHeight = 150;
p.snapDistance = 1;
p.snapToEvents = true;
p.minUnitSize = 20;
p.timeScaleLineThickness = 1;
p.timeScaleLineColor = 15395562;
p.timeScaleFillColor = 16316664;
p.timeScaleFillAlpha = 100;
p.initialize = function()
{
   this.simulatorMC.addUpdateListener(this);
   this.simulatorMC.addSystemPropertiesListener(this);
   this.simulatorMC.addResetListener(this);
   var w = this.areaWidth;
   var h = this.areaHeight;
   this.createEmptyMovieClip("backgroundMC",10);
   this.createEmptyMovieClip("timelineAreaMC",15);
   this.createEmptyMovieClip("timelineAreaMaskMC",16);
   this.attachMovie("Timeline Cursor","cursorMC",20,{_x:w / 2,_y:h / 2});
   this.attachMovie("Timeline Event Item","selectedEventMC",22,{_x:0,_y:h / 2});
   this.attachMovie("Timeline Past Label","pastLabelMC",25);
   this.attachMovie("Timeline Future Label","futureLabelMC",26,{_y:this.areaHeight});
   this.createEmptyMovieClip("borderMC",30);
   this.selectedEventMC.setSelected(true);
   this.timelineAreaMC.createEmptyMovieClip("timeScaleMC",1);
   this.timelineAreaMC.createEmptyMovieClip("cyclesMC",2);
   this.timeScaleLabelsList = [];
   var n = 4 + Math.ceil(this.areaHeight / this.minUnitSize);
   if(n % 2 == 1)
   {
      n += 1;
   }
   var i = 0;
   while(i < n)
   {
      this.timeScaleLabelsList.push(this.timelineAreaMC.timeScaleMC.attachMovie("Timeline Scale Field","label" + i + "MC",i,{_x:w}));
      i++;
   }
   this.timelineAreaMC.setMask(this.timelineAreaMaskMC);
   this.timelineAreaMaskMC.lineStyle();
   this.timelineAreaMaskMC.moveTo(0,0);
   this.timelineAreaMaskMC.beginFill(16711680,30);
   this.timelineAreaMaskMC.lineTo(w,0);
   this.timelineAreaMaskMC.lineTo(w,h);
   this.timelineAreaMaskMC.lineTo(0,h);
   this.timelineAreaMaskMC.lineTo(0,0);
   this.timelineAreaMaskMC.endFill();
   this.backgroundMC.lineStyle();
   this.backgroundMC.moveTo(0,0);
   this.backgroundMC.beginFill(this.backgroundColor);
   this.backgroundMC.lineTo(w,0);
   this.backgroundMC.lineTo(w,h);
   this.backgroundMC.lineTo(0,h);
   this.backgroundMC.lineTo(0,0);
   this.backgroundMC.endFill();
   this.borderMC.lineStyle(this.borderThickness,this.borderColor);
   this.borderMC.moveTo(0,0);
   this.borderMC.lineTo(w,0);
   this.borderMC.lineTo(w,h);
   this.borderMC.lineTo(0,h);
   this.borderMC.lineTo(0,0);
   var n = 2 + Math.ceil(this.areaHeight / this.cycleHeight);
   if(n % 2 == 0)
   {
      n += 1;
   }
   this.numberOfPeripheryCycles = (n - 1) / 2;
   this.cyclesList = [];
   var i = 0;
   while(i < n)
   {
      var y = this.cycleHeight * i;
      this.cyclesList.push(this.timelineAreaMC.cyclesMC.attachMovie("Timeline Event Cycle","cycle" + i + "MC",i,{_y:y,timelineMC:this}));
      i++;
   }
   this.centralCycleMC = this.cyclesList[this.numberOfPeripheryCycles];
   this.backgroundMC.useHandCursor = false;
   this.backgroundMC.tabEnabled = false;
   this.backgroundMC.onPress = function()
   {
      this.timeThreshold = this._parent.snapDistance / this._parent.scale;
      this.initY = this._ymouse;
      this.initTime = this._parent.simulatorMC.time;
      this._parent.simulatorMC.freezeAnimation();
      this.onMouseMove = this.onMouseMoveFunc;
   };
   this.backgroundMC.onMouseMoveFunc = function()
   {
      var newTime = this.initTime + (this.initY - this._ymouse) / this._parent.scale;
      this._parent.simulatorMC.setTime(newTime,this._parent.snapToEvents,this.timeThreshold);
      updateAfterEvent();
   };
   this.backgroundMC.onRelease = this.backgroundMC.onReleaseOutside = function()
   {
      delete this.onMouseMove;
      this._parent.simulatorMC.thawAnimation();
   };
};
p.zeroTimelineTime = function()
{
   this.timelineTimeOffset = - this.simulatorMC.time;
   this.updateTimeScale();
};
p.updateTimeScale = function()
{
   var timelineTime = this.simulatorMC.time + this.timelineTimeOffset;
   var absTimelineTime = Math.abs(timelineTime);
   var n = this.numUnitIntervals;
   var f = this.precision;
   var K = Math.floor(timelineTime / this.unitTime);
   var J = (K % 2 + 2) % 2;
   var U = K + J;
   var H = U - n / 2;
   this.timelineAreaMC.timeScaleMC._y = this.areaHeight / 2 - this.scale * (timelineTime - U * this.unitTime);
   if(f <= 0)
   {
      var m = Math.pow(10,- f);
   }
   var i = 0;
   while(i < n + 1)
   {
      var value = this.unitTime * (H + i);
      if(f < 0)
      {
         var valueString = String(m * Math.round(value / m));
      }
      else
      {
         valueString = value.toFixed(f);
      }
      this.timeScaleLabelsList[i].timeField.text = valueString + " yr";
      i++;
   }
   var daysInYear = 365.24;
   var decimalYearsString = timelineTime.toFixed(3);
   var decimalYears = parseFloat(decimalYearsString);
   var absTimeInDays = daysInYear * absTimelineTime;
   var counterYears = Math.floor(absTimeInDays / daysInYear);
   var counterDays = absTimeInDays - counterYears * daysInYear;
   var counterDaysString = counterDays.toFixed(1);
   var counterString = "" + decimalYearsString + " years";
   if(counterYears != 0 || counterDays != 0)
   {
      if(timelineTime < 0)
      {
         counterString += ", (";
         if(counterYears == 1)
         {
            counterString += "-" + counterYears + " year, ";
         }
         else if(counterYears > 1)
         {
            counterString += "-" + counterYears + " years, ";
         }
         counterString += "-" + counterDays.toFixed(1) + " days";
         counterString += ")";
      }
      else
      {
         counterString += ", (";
         if(counterYears == 1)
         {
            counterString += counterYears + " year, ";
         }
         else if(counterYears > 1)
         {
            counterString += counterYears + " years, ";
         }
         counterString += counterDays.toFixed(1) + " days";
         counterString += ")";
      }
   }
   this.timeField.text = counterString;
};
p.onSimulatorReset = function()
{
   this.zeroTimelineTime();
};
p.onSystemPropertiesChanged = function()
{
   this.scale = this.cycleHeight / this.simulatorMC.synodicPeriod;
   var yList = [];
   var i = 0;
   while(i < 4)
   {
      yList.push(this.scale * this.simulatorMC.eventTimesList[i]);
      i++;
   }
   yList.push(this.cycleHeight);
   var i = 0;
   while(i < this.cyclesList.length)
   {
      this.cyclesList[i].setLabelNamesAndPositions(this.simulatorMC.eventNamesList,yList);
      i++;
   }
   var minUnitTime = this.minUnitSize / this.scale;
   var logUnitTime = Math.ceil(Math.log(minUnitTime) / 2.302585092994046);
   var unitTime = Math.pow(10,logUnitTime);
   var precision = - logUnitTime;
   if(unitTime / 4 > minUnitTime)
   {
      unitTime /= 4;
      precision += 2;
   }
   else if(unitTime / 2 > minUnitTime)
   {
      unitTime /= 2;
      precision += 1;
   }
   var areaTime = this.areaHeight / this.scale;
   var n = 4 + Math.ceil(areaTime / unitTime);
   if(n % 2 == 1)
   {
      n += 1;
   }
   var K = (n / 2 + 1) % 2;
   var w = this.areaWidth;
   var unitY = unitTime * this.scale;
   var mc = this.timelineAreaMC.timeScaleMC;
   mc.clear();
   var lineThickness = this.timeScaleLineThickness;
   var lineColor = this.timeScaleLineColor;
   var fillColor = this.timeScaleFillColor;
   var fillAlpha = this.timeScaleFillAlpha;
   var labelsList = this.timeScaleLabelsList;
   var lastY = (- unitY) * n / 2;
   labelsList[0]._y = lastY;
   labelsList[0]._visible = true;
   if(K == 1)
   {
      mc.lineStyle(lineThickness,lineColor);
      mc.moveTo(0,lastY);
      mc.lineTo(w,lastY);
   }
   var i = 0;
   while(i < n)
   {
      var newY = lastY + unitY;
      labelsList[i + 1]._y = newY;
      labelsList[i + 1]._visible = true;
      if(i % 2 == K)
      {
         mc.moveTo(0,lastY);
         mc.beginFill(fillColor,fillAlpha);
         mc.lineStyle(lineThickness,lineColor);
         mc.lineTo(w,lastY);
         mc.lineStyle();
         mc.lineTo(w,newY);
         mc.lineStyle(lineThickness,lineColor);
         mc.lineTo(0,newY);
         mc.lineStyle();
         mc.lineTo(0,lastY);
         mc.endFill();
      }
      lastY = newY;
      i++;
   }
   i;
   while(i < labelsList.length - 1)
   {
      labelsList[i + 1]._visible = false;
      i++;
   }
   if(K == 0)
   {
      mc.lineStyle(lineThickness,lineColor);
      mc.moveTo(0,lastY);
      mc.lineTo(w,lastY);
   }
   this.numUnitIntervals = n;
   this.unitTime = unitTime;
   this.precision = precision;
};
p.onSimulatorUpdated = function()
{
   var startNumber = this.simulatorMC.currentCycleNumber - this.numberOfPeripheryCycles;
   var i = 0;
   while(i < this.cyclesList.length)
   {
      this.cyclesList[i].cycleNumber = startNumber + i;
      i++;
   }
   var delta = this.simulatorMC.synodicPeriod * this.numberOfPeripheryCycles + this.simulatorMC.time - (this.simulatorMC.cycleOffset + this.simulatorMC.currentCycleNumber * this.simulatorMC.synodicPeriod);
   this.timelineAreaMC.cyclesMC._y = this.areaHeight / 2 - delta * this.scale;
   if(this.simulatorMC.lockedOnEvent)
   {
      this.selectedEventMC._visible = true;
      this.selectedEventMC.setEventName(this.simulatorMC.eventNamesList[this.simulatorMC.lockedEventNumber]);
   }
   else
   {
      this.selectedEventMC._visible = false;
   }
   this.updateTimeScale();
};
