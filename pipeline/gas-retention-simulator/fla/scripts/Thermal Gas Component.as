function ThermalGasComponentClass()
{
   if(this.initWidth == undefined)
   {
      this.initWidth = this._width;
   }
   if(this.initHeight == undefined)
   {
      this.initHeight = this._height;
   }
   this._xscale = 100;
   this._yscale = 100;
   this.placeholderMC._visible = false;
   this._boundaryWidth = this.initWidth;
   this._boundaryHeight = this.initHeight;
   if(this._scale == undefined)
   {
      this._scale = 0.001;
   }
   this.createEmptyMovieClip("backgroundMC",1);
   this.createEmptyMovieClip("particlesMC",10);
   this.createEmptyMovieClip("particlesMaskMC",11);
   this.createEmptyMovieClip("escapeesMC",15);
   this.createEmptyMovieClip("boundaryMC",20);
   this.particlesMC.setMask(this.particlesMaskMC);
   this.depthOffsetsList = [];
   var i = 0;
   while(i < this.MAXGASSES)
   {
      this.depthOffsetsList.push(i);
      i++;
   }
   this.depthOffsetsList.reverse();
   this.gassesList = [];
   if(this.initEscapeeTravelDistance != undefined)
   {
      this._escapeeTravelDistance = this.initEscapeeTravelDistance;
   }
   else
   {
      this._escapeeTravelDistance = 100;
   }
   if(this.initAllowEscape != undefined)
   {
      this._allowEscape = this.initAllowEscape;
   }
   else
   {
      this._allowEscape = false;
   }
   if(this.initEscapeSpeed != undefined)
   {
      this.setEscapeSpeed(this.initEscapeSpeed);
   }
   else
   {
      this.setEscapeSpeed(1000);
   }
   if(this.initTemperature == undefined || isNaN(this.initTemperature) || !isFinite(this.initTemperature))
   {
      this._temperature = 300;
   }
   else
   {
      this._temperature = this.initTemperature;
   }
   if(this.animationRate == undefined || isNaN(this.animationRate) || !isFinite(this.animationRate))
   {
      this.animationRate = 0.0001;
   }
   this.updateBoundary();
   this.updateMask();
}
var p = ThermalGasComponentClass.prototype = new MovieClip();
Object.registerClass("Thermal Gas Component",ThermalGasComponentClass);
p.STARTDEPTH = 1000000;
p.MAXGASSES = 100;
p.getTemperature = function()
{
   return this._temperature;
};
p.setTemperature = function(arg)
{
   this._temperature = arg;
   var gL = this.gassesList;
   var gLlen = gL.length;
   var i = 0;
   while(i < gLlen)
   {
      gL[i].calculateSpeeds();
      i++;
   }
};
p.addProperty("temperature",p.getTemperature,p.setTemperature);
p.addGas = function(name, initObject)
{
   if(this.gassesList.length >= this.MAXGASSES)
   {
      return undefined;
   }
   this[name] = new TGCGasClass(this,name,this.depthOffsetsList.pop(),initObject);
   this.gassesList.push(this[name]);
};
p.clearEscapees = function()
{
   var gL = this.gassesList;
   var gLlen = gL.length;
   var i = 0;
   while(i < gLlen)
   {
      gL[i].clearEscapees();
      i++;
   }
};
p.getAllowEscape = function()
{
   return this._allowEscape;
};
p.setAllowEscape = function(arg)
{
   this._allowEscape = arg;
   this.clearEscapees();
};
p.addProperty("allowEscape",p.getAllowEscape,p.setAllowEscape);
p.getAnimationState = function()
{
   return this.onEnterFrame == this.animateOnEnterFrame;
};
p.setAnimationState = function(arg)
{
   if(arg)
   {
      this._timeLast = getTimer();
      this.onEnterFrame = this.animateOnEnterFrame;
   }
   else
   {
      delete this.onEnterFrame;
   }
};
p.addProperty("animationState",p.getAnimationState,p.setAnimationState);
p.animateOnEnterFrame = function()
{
   var timeNow = getTimer();
   var deltaAge = timeNow - this._timeLast;
   if(deltaAge > 100)
   {
      deltaAge = 100;
   }
   var deltaTime = this.animationRate * deltaAge / 1000;
   var gL = this.gassesList;
   var gLlen = gL.length;
   var i = 0;
   while(i < gLlen)
   {
      gL[i].advanceParticles(deltaTime,deltaAge);
      i++;
   }
   this._timeLast = timeNow;
};
p.getEscapeSpeed = function()
{
   return this._escapeSpeed;
};
p.setEscapeSpeed = function(arg)
{
   this._escapeSpeed = arg;
   this._escapeSpeedPxPerSimSec = this._escapeSpeed / this._scale;
};
p.addProperty("escapeSpeed",p.getEscapeSpeed,p.setEscapeSpeed);
p.boundaryThickness = 1;
p.boundaryColor = 9474192;
p.boundaryAlpha = 100;
p.getShowBoundary = function()
{
   return this.boundaryMC._visible;
};
p.setShowBoundary = function(arg)
{
   this.boundaryMC._visible = arg;
};
p.addProperty("showBoundary",p.getShowBoundary,p.setShowBoundary);
p.setBoundaryStyle = function(thickness, color, alpha)
{
   if(thickness != undefined && thickness != null)
   {
      this.boundaryThickness = thickness;
   }
   if(color != undefined && color != null)
   {
      this.boundaryColor = color;
   }
   if(alpha != undefined && alpha != null)
   {
      this.boundaryAlpha = alpha;
   }
   this.updateBoundary();
};
p.updateBoundary = function()
{
   var w = this._boundaryWidth;
   var h = this._boundaryHeight;
   this.boundaryMC.clear();
   this.boundaryMC.lineStyle(this.boundaryThickness,this.boundaryColor,this.boundaryAlpha);
   this.boundaryMC.moveTo(0,0);
   this.boundaryMC.lineTo(w,0);
   this.boundaryMC.lineTo(w,h);
   this.boundaryMC.lineTo(0,h);
   this.boundaryMC.lineTo(0,0);
};
p.updateMask = function()
{
   var w = this._boundaryWidth;
   var h = this._boundaryHeight;
   this.particlesMaskMC.clear();
   this.particlesMaskMC.moveTo(0,0);
   this.particlesMaskMC.beginFill(16711680,20);
   this.particlesMaskMC.lineTo(w,0);
   this.particlesMaskMC.lineTo(w,h);
   this.particlesMaskMC.lineTo(0,h);
   this.particlesMaskMC.lineTo(0,0);
   this.particlesMaskMC.endFill();
};
