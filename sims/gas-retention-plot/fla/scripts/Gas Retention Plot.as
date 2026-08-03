function GasRetentionPlotClass()
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
   this.placeholderMC.swapDepths(987654);
   this.placeholderMC.removeMovieClip();
   if(typeof this.initTemperatureMajorTickmarks == "string")
   {
      this.temperatureMajorTickmarksList = [];
      var tmpList = this.initTemperatureMajorTickmarks.split(",");
      var i = 0;
      while(i < tmpList.length)
      {
         var temp = parseFloat(tmpList[i]);
         if(!isNaN(temp))
         {
            this.temperatureMajorTickmarksList.push(temp);
         }
         i++;
      }
   }
   if(typeof this.initTemperatureMinorTickmarks == "string")
   {
      this.temperatureMinorTickmarksList = [];
      var tmpList = this.initTemperatureMinorTickmarks.split(",");
      var i = 0;
      while(i < tmpList.length)
      {
         var temp = parseFloat(tmpList[i]);
         if(!isNaN(temp))
         {
            this.temperatureMinorTickmarksList.push(temp);
         }
         i++;
      }
   }
   if(typeof this.initSpeedMajorTickmarks == "string")
   {
      this.speedMajorTickmarksList = [];
      var tmpList = this.initSpeedMajorTickmarks.split(",");
      var i = 0;
      while(i < tmpList.length)
      {
         var temp = parseFloat(tmpList[i]);
         if(!isNaN(temp))
         {
            this.speedMajorTickmarksList.push(temp);
         }
         i++;
      }
   }
   if(typeof this.initSpeedMinorTickmarks == "string")
   {
      this.speedMinorTickmarksList = [];
      var tmpList = this.initSpeedMinorTickmarks.split(",");
      var i = 0;
      while(i < tmpList.length)
      {
         var temp = parseFloat(tmpList[i]);
         if(!isNaN(temp))
         {
            this.speedMinorTickmarksList.push(temp);
         }
         i++;
      }
   }
   if(this.initMinTemperature != undefined && this.initMaxTemperature != undefined)
   {
      this.setTemperatureRange(this.initMinTemperature,this.initMaxTemperature);
   }
   if(this.initMinSpeed != undefined && this.initMaxSpeed != undefined)
   {
      this.setSpeedRange(this.initMinSpeed,this.initMaxSpeed);
   }
   this.attachMovie("GRP Fonts","fontsMC",999999,{_visible:false});
   this.objectLabelTextFormat = this.fontsMC.objectLabelField.getTextFormat();
   this.axisLabelTextFormat = this.fontsMC.axisLabelField.getTextFormat();
   this.gasLabelTextFormat = this.fontsMC.gasLabelField.getTextFormat();
   this.createEmptyMovieClip("backgroundMC",1);
   this.createEmptyMovieClip("gassesMC",5);
   this.createEmptyMovieClip("gassesMaskMC",6);
   this.createEmptyMovieClip("gasLabelsMC",7);
   this.createEmptyMovieClip("objectsMC",10);
   this.createEmptyMovieClip("borderMC",20);
   this.gassesMC.setMask(this.gassesMaskMC);
   this.objectsTopDepth = 1;
   this.objectsList = [];
   this.gassesTopDepth = 1;
   this.gassesList = [];
   this.updateEverything();
}
var p = GasRetentionPlotClass.prototype = new MovieClip();
Object.registerClass("Gas Retention Plot",GasRetentionPlotClass);
p.borderThickness = 1;
p.borderColor = 0;
p.borderAlpha = 100;
p.backgroundColor = 16777215;
p.backgroundAlpha = 100;
p.tickmarkThickness = 1;
p.tickmarkColor = 0;
p.tickmarkAlpha = 100;
p.majorTickmarkLength = 6;
p.minorTickmarkLength = 3;
p.temperatureMajorTickmarksList = [30,50,100,200,500,1000];
p.temperatureMinorTickmarksList = [40,60,70,80,90,300,400,500,600,700,800,900];
p.speedMajorTickmarksList = [2,4,6,10,20,40,60,100];
p.speedMinorTickmarksList = [3,5,7,8,9,30,50,70,80,90];
p.updateEverything = function()
{
   this.updateBorder();
   this.updateBackground();
   this.updateSpeedScale();
   this.updateTemperatureScale();
   this.updateObjects();
   this.updateGasses();
};
p.setDimensions = function(width, height)
{
   if(width != undefined && width != null)
   {
      this._plotWidth = width;
   }
   if(height != undefined && height != null)
   {
      this._plotHeight = height;
   }
   this.updateEverything();
};
p.getTemperature = function(x)
{
   var min = Math.log(this._minTemp) / 2.302585092994046;
   var scale = this._plotWidth / (Math.log(this._maxTemp) / 2.302585092994046 - min);
   var temperature = Math.pow(10,x / scale + min);
   return temperature;
};
p.getSpeed = function(y)
{
   var min = Math.log(this._minSpeed) / 2.302585092994046;
   var scale = (- this._plotHeight) / (Math.log(this._maxSpeed) / 2.302585092994046 - min);
   var speed = Math.pow(10,y / scale + min);
   return speed;
};
p.getX = function(temperature)
{
   var min = Math.log(this._minTemp) / 2.302585092994046;
   var scale = this._plotWidth / (Math.log(this._maxTemp) / 2.302585092994046 - min);
   var x = scale * (Math.log(temperature) / 2.302585092994046 - min);
   return x;
};
p.getY = function(speed)
{
   var min = Math.log(this._minSpeed) / 2.302585092994046;
   var scale = (- this._plotHeight) / (Math.log(this._maxSpeed) / 2.302585092994046 - min);
   var y = scale * (Math.log(speed) / 2.302585092994046 - min);
   return y;
};
p.addGas = function(name, defObj)
{
   var depth = this.gassesTopDepth++;
   if(typeof defObj != "object")
   {
      defObj = {};
   }
   defObj.labelMC = this.gasLabelsMC.createEmptyMovieClip("_" + depth,depth);
   this[name] = this.gassesMC.attachMovie("GRP Gas","_" + depth,depth,defObj);
   this.gassesList.push(this[name]);
};
p.addObject = function(name, defObj)
{
   var depth = this.objectsTopDepth++;
   this[name] = this.objectsMC.attachMovie("GRP Object","_" + depth,depth,defObj);
   this.objectsList.push(this[name]);
};
p.setTemperatureRange = function(min, max)
{
   if(typeof min == "number" && !isNaN(min) && isFinite(min) && min > 0)
   {
      this._minTemp = min;
   }
   if(typeof max == "number" && !isNaN(max) && isFinite(max) && max > 0)
   {
      this._maxTemp = max;
   }
   if(this._minTemp > this._maxTemp)
   {
      var tmp = this._minTemp;
      this._minTemp = this._maxTemp;
      this._maxTemp = tmp;
   }
   if(this._minTemp == this._maxTemp)
   {
      this._maxTemp = 10 * this._minTemp;
   }
   this.updateEverything();
};
p.setSpeedRange = function(min, max)
{
   if(typeof min == "number" && !isNaN(min) && isFinite(min) && min > 0)
   {
      this._minSpeed = min;
   }
   if(typeof max == "number" && !isNaN(max) && isFinite(max) && max > 0)
   {
      this._maxSpeed = max;
   }
   if(this._minSpeed > this._maxSpeed)
   {
      var tmp = this._minSpeed;
      this._minSpeed = this._maxSpeed;
      this._maxSpeed = tmp;
   }
   if(this._minSpeed == this._maxSpeed)
   {
      this._maxSpeed = 10 * this._minSpeed;
   }
   this.updateEverything();
};
p.updateGasses = function()
{
   var gL = this.gassesList;
   var i = 0;
   while(i < gL.length)
   {
      gL[i].update();
      i++;
   }
};
p.updateObjects = function()
{
   var oL = this.objectsList;
   var i = 0;
   while(i < oL.length)
   {
      oL[i].updatePosition();
      i++;
   }
};
p.updateSpeedScale = function()
{
   var mc = this.createEmptyMovieClip("speedScaleMC",16);
   var min = Math.log(this._minSpeed) / 2.302585092994046;
   var scale = (- this._plotHeight) / (Math.log(this._maxSpeed) / 2.302585092994046 - min);
   var x = - this.majorTickmarkLength;
   var tf = this.axisLabelTextFormat;
   mc.lineStyle(this.tickmarkThickness,this.tickmarkColor,this.tickmarkAlpha);
   var tL = this.speedMajorTickmarksList;
   var i = 0;
   while(i < tL.length)
   {
      var speed = tL[i];
      if(!(speed < this._minSpeed || speed > this._maxSpeed))
      {
         var y = scale * (Math.log(speed) / 2.302585092994046 - min);
         mc.moveTo(x,y);
         mc.lineTo(0,y);
         mc.createTextField("label" + i,i,x,0,0,0);
         var labelField = mc["label" + i];
         labelField.autoSize = "right";
         labelField.selectable = false;
         labelField.type = "dynamic";
         labelField.embedFonts = true;
         labelField.setNewTextFormat(tf);
         labelField.text = tL[i];
         labelField._y = y - labelField._height / 2;
      }
      i++;
   }
   var x = - this.minorTickmarkLength;
   var tL = this.speedMinorTickmarksList;
   var i = 0;
   while(i < tL.length)
   {
      var speed = tL[i];
      if(!(speed < this._minSpeed || speed > this._maxSpeed))
      {
         var y = scale * (Math.log(speed) / 2.302585092994046 - min);
         mc.moveTo(x,y);
         mc.lineTo(0,y);
      }
      i++;
   }
};
p.updateTemperatureScale = function()
{
   var mc = this.createEmptyMovieClip("temperatureScaleMC",15);
   var min = Math.log(this._minTemp) / 2.302585092994046;
   var scale = this._plotWidth / (Math.log(this._maxTemp) / 2.302585092994046 - min);
   var y = this.majorTickmarkLength;
   var tf = this.axisLabelTextFormat;
   mc.lineStyle(this.tickmarkThickness,this.tickmarkColor,this.tickmarkAlpha);
   var tL = this.temperatureMajorTickmarksList;
   var i = 0;
   while(i < tL.length)
   {
      var temp = tL[i];
      if(!(temp < this._minTemp || temp > this._maxTemp))
      {
         var x = scale * (Math.log(temp) / 2.302585092994046 - min);
         mc.moveTo(x,0);
         mc.lineTo(x,y);
         mc.createTextField("label" + i,i,x,y,0,0);
         var labelField = mc["label" + i];
         labelField.autoSize = "center";
         labelField.selectable = false;
         labelField.type = "dynamic";
         labelField.embedFonts = true;
         labelField.setNewTextFormat(tf);
         labelField.text = tL[i];
      }
      i++;
   }
   var y = this.minorTickmarkLength;
   var tL = this.temperatureMinorTickmarksList;
   var i = 0;
   while(i < tL.length)
   {
      var temp = tL[i];
      if(!(temp < this._minTemp || temp > this._maxTemp))
      {
         var x = scale * (Math.log(temp) / 2.302585092994046 - min);
         mc.moveTo(x,0);
         mc.lineTo(x,y);
      }
      i++;
   }
};
p.updateBackground = function()
{
   var w = this._plotWidth;
   var h = this._plotHeight;
   this.backgroundMC.clear();
   this.backgroundMC.moveTo(0,0);
   this.backgroundMC.beginFill(this.backgroundColor,this.backgroundAlpha);
   this.backgroundMC.lineTo(w,0);
   this.backgroundMC.lineTo(w,- h);
   this.backgroundMC.lineTo(0,- h);
   this.backgroundMC.lineTo(0,0);
   this.backgroundMC.endFill();
   this.gassesMaskMC.clear();
   this.gassesMaskMC.moveTo(0,0);
   this.gassesMaskMC.beginFill(16711680,30);
   this.gassesMaskMC.lineTo(w,0);
   this.gassesMaskMC.lineTo(w,- h);
   this.gassesMaskMC.lineTo(0,- h);
   this.gassesMaskMC.lineTo(0,0);
   this.gassesMaskMC.endFill();
};
p.updateBorder = function()
{
   var w = this._plotWidth;
   var h = this._plotHeight;
   this.borderMC.clear();
   this.borderMC.lineStyle(this.borderThickness,this.borderColor,this.borderAlpha);
   this.borderMC.moveTo(0,0);
   this.borderMC.lineTo(w,0);
   this.borderMC.lineTo(w,- h);
   this.borderMC.lineTo(0,- h);
   this.borderMC.lineTo(0,0);
};
