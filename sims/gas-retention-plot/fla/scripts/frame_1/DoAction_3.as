function onResetClicked()
{
   var i = 0;
   while(i < gassesList.length)
   {
      this["checkBox" + i].setValue(false);
      i++;
   }
   radiusSlider.value = 600;
   densitySlider.value = 5;
   temperatureSlider.value = 70;
   showGasGiantsCheck.setValue(false);
   showTerrestialPlanetsCheck.setValue(false);
   showIcyBodiesAndMoonsCheck.setValue(false);
   desnapObject();
   var mass = densitySlider.value * 1000 * Math.pow(radiusSlider.value * 1000,3) * 4 * 3.141592653589793 / 3;
   plotMC.userObject.escapeSpeed = Math.sqrt(1.3346e-10 * mass / (radiusSlider.value * 1000)) / 1000;
   plotMC.userObject.temperature = temperatureSlider.value;
   plotMC.userObject.updatePosition();
   updateMassInfo();
   updateDistanceInfo();
}
function updateObjectVisibilities()
{
   plotMC.Jupiter.visible = plotMC.Saturn.visible = plotMC.Uranus.visible = plotMC.Neptune.visible = showGasGiantsCheck.getValue();
   plotMC.Mercury.visible = plotMC.Venus.visible = plotMC.Earth.visible = plotMC.Mars.visible = showTerrestialPlanetsCheck.getValue();
   plotMC.Moon.visible = plotMC.Titan.visible = plotMC.Triton.visible = plotMC.Pluto.visible = plotMC.Ganymede.visible = showIcyBodiesAndMoonsCheck.getValue();
}
function desnapObject()
{
   currentSnappedToObject.textColor = 4210752;
   currentSnappedToObject = undefined;
}
function onTemperatureSliderChanged()
{
   desnapObject();
   plotMC.userObject.temperature = temperatureSlider.value;
   plotMC.userObject.updatePosition();
   updateDistanceInfo();
}
function onDensitySliderChanged()
{
   desnapObject();
   var r = radiusSlider.value;
   var d = densitySlider.value;
   var escapeSpeed = r * 0.0007477 * Math.sqrt(d);
   if(escapeSpeed < plotMC._minSpeed)
   {
      radiusSlider.value = plotMC._minSpeed / (0.0007477 * Math.sqrt(d));
      plotMC.userObject.escapeSpeed = plotMC._minSpeed;
   }
   else if(escapeSpeed > plotMC._maxSpeed)
   {
      radiusSlider.value = plotMC._maxSpeed / (0.0007477 * Math.sqrt(d));
      plotMC.userObject.escapeSpeed = plotMC._maxSpeed;
   }
   else
   {
      plotMC.userObject.escapeSpeed = escapeSpeed;
   }
   plotMC.userObject.updatePosition();
   doubleCheck();
   updateMassInfo();
}
function onRadiusSliderChanged()
{
   desnapObject();
   var r = radiusSlider.value;
   var d = densitySlider.value;
   var escapeSpeed = r * 0.0007477 * Math.sqrt(d);
   if(escapeSpeed < plotMC._minSpeed)
   {
      densitySlider.value = Math.pow(plotMC._minSpeed / (r * 0.0007477),2);
      plotMC.userObject.escapeSpeed = plotMC._minSpeed;
   }
   else if(escapeSpeed > plotMC._maxSpeed)
   {
      densitySlider.value = Math.pow(plotMC._maxSpeed / (r * 0.0007477),2);
      plotMC.userObject.escapeSpeed = plotMC._maxSpeed;
   }
   else
   {
      plotMC.userObject.escapeSpeed = escapeSpeed;
   }
   plotMC.userObject.updatePosition();
   doubleCheck();
   updateMassInfo();
}
function doubleCheck()
{
   trace("double check");
   trace(" " + plotMC.userObject.escapeSpeed);
   var radius = 1000 * radiusSlider.value;
   var mass = densitySlider.value * 1.3333333333333333 * 3.141592653589793 * radius * radius * radius * 100 * 100 * 100 / 1000;
   var escapeSpeed = Math.sqrt(1.3346e-10 * mass / radius) / 1000;
   trace(" " + escapeSpeed);
}
function updateMassInfo()
{
   var radius = 1000 * radiusSlider.value;
   var mass = densitySlider.value * 1.3333333333333333 * 3.141592653589793 * radius * radius * radius * 100 * 100 * 100 / 1000;
   var str = "a mass of " + mass.toScientific(2,true) + " kg and an escape velocity of " + plotMC.userObject.escapeSpeed.toFixed(1) + " km/s";
   displayText(str,{vAlign:"top",x:621,y:625,depth:300,textFormat:listingTextFormat,embedFonts:true});
   massInfoField.text = "an object of this size and density would have a mass of ";
}
function updateDistanceInfo()
{
   var distanceInAU = Math.pow(278.8 / plotMC.userObject.temperature,2);
   distanceInfoField.text = "this temperature would be associated with an object about " + formatNumber(distanceInAU,2) + " AU from the sun";
}
function formatNumber(num, digits)
{
   var L = Math.floor(Math.log(num) / 2.302585092994046) - (digits - 1);
   if(L >= 0)
   {
      var M = Math.pow(10,L);
      return String(M * Math.round(num / M));
   }
   return num.toFixed(- L);
}
onSelectedGasChanged = function(arg)
{
   plotMC[arg.data.name].visible = arg.getValue();
};
createEmptyMovieClip("gasSeparatorLinesMC",10);
gasSeparatorLinesMC.lineStyle(1,0,15);
verticalSpacing = 23;
listingTextFormat = new TextFormat("Verdana",12);
var startY = 293;
var xOffset = 13;
gasSeparatorLinesMC.moveTo(xOffset + 557,startY + verticalSpacing - 4);
gasSeparatorLinesMC.lineTo(xOffset + 836,startY + verticalSpacing - 4);
var i = 0;
while(i < gassesList.length)
{
   var g = gassesList[i];
   plotMC.addGas(g.name,{initVisible:false,shadingColor:g.color,mass:g.mass,labelText:g.symbol + ", 10×V<sub>avg</sub>"});
   var y = startY - i * verticalSpacing;
   attachMovie("FCheckBoxSymbol","checkBox" + i,1000 + i,{initWidth:13,initHeight:13,_x:xOffset + 805,_y:y + 2,label:"",initialState:false,labelPlacement:"right",data:g,changeHandler:"onSelectedGasChanged"});
   var str = g.name + " (" + g.symbol + ")";
   displayText(str,{x:xOffset + 630,y:y,textFormat:listingTextFormat,embedFonts:true,vAlign:"top",hAlign:"center"});
   var str = g.mass.toFixed(0) + " u";
   displayText(str,{x:xOffset + 740,y:y,textFormat:listingTextFormat,embedFonts:true,vAlign:"top",hAlign:"center"});
   gasSeparatorLinesMC.moveTo(xOffset + 557,y - 4);
   gasSeparatorLinesMC.lineTo(xOffset + 836,y - 4);
   i++;
}
var i = 0;
while(i < objectsList.length)
{
   objectsList[i].labelText = objectsList[i].name;
   objectsList[i].textColor = 4210752;
   plotMC.addObject(objectsList[i].name,objectsList[i]);
   i++;
}
plotMC.addObject("userObject",{labelText:"",activeColor:16711680,inactiveColor:16736352,activeRadius:5,inactiveRadius:4,draggable:true,escapeSpeed:1.00314,temperature:70});
plotMC.userObject.onMouseMoveFunc = function()
{
   var nx = this._parent._parent._xmouse - this._xOffset;
   var ny = this._parent._parent._ymouse - this._yOffset;
   if(nx < 0)
   {
      nx = 0;
   }
   else if(nx > this._parent.plotMC._plotWidth)
   {
      nx = this._parent.plotMC._plotWidth;
   }
   if(ny > 0)
   {
      ny = 0;
   }
   else if(ny < - this._parent.plotMC._plotHeight)
   {
      ny = - this._parent.plotMC._plotHeight;
   }
   var snapDistance = 8;
   var sD2 = snapDistance * snapDistance;
   var snappedToObjectName = null;
   var i = 0;
   while(i < this._parent.plotMC.objectsList.length)
   {
      var obj = this._parent.plotMC.objectsList[i];
      if(obj != this._parent && obj._visible)
      {
         var dx = nx - obj._x;
         var dy = ny - obj._y;
         var d2 = dx * dx + dy * dy;
         if(d2 < sD2)
         {
            snappedToObjectName = obj.labelText;
            nx = obj._x;
            ny = obj._y;
            break;
         }
      }
      i++;
   }
   this._parent.temperature = this._parent.plotMC.getTemperature(nx);
   this._parent.escapeSpeed = this._parent.plotMC.getSpeed(ny);
   this._parent.updatePosition();
   this._parent.onObjectMoved.call(this._parent.plotMC._parent,snappedToObjectName);
   updateAfterEvent();
};
plotMC.userObject.onObjectMoved = function(snappedToObjectName)
{
   temperatureSlider.value = plotMC.userObject.temperature;
   updateDistanceInfo();
   desnapObject();
   if(typeof snappedToObjectName == "string")
   {
      var i = 0;
      while(i < objectsList.length)
      {
         if(snappedToObjectName == objectsList[i].name)
         {
            radiusSlider.value = objectsList[i].radius;
            densitySlider.value = objectsList[i].density;
            currentSnappedToObject = plotMC[snappedToObjectName];
            currentSnappedToObject.textColor = 16711680;
         }
         i++;
      }
   }
   else
   {
      var d = densitySlider.value;
      var r = plotMC.userObject.escapeSpeed / (0.0007477 * Math.sqrt(d));
      if(r > radiusSlider.maxValue)
      {
         radiusSlider.value = radiusSlider.maxValue;
         densitySlider.value = Math.pow(plotMC.userObject.escapeSpeed / (0.0007477 * radiusSlider.maxValue),2);
      }
      else if(r < radiusSlider.minValue)
      {
         radiusSlider.value = radiusSlider.minValue;
         densitySlider.value = Math.pow(plotMC.userObject.escapeSpeed / (0.0007477 * radiusSlider.minValue),2);
      }
      else
      {
         radiusSlider.value = r;
      }
   }
   updateMassInfo();
};
titleBar.swapDepths(999999);
onResetClicked();
