function GasRetentionSimulatorClass()
{
   this.gassesList = {xenon:{particleSize:6,color:6710944,name:"xenon",symbol:"Xe",mass:131.293},carbonDioxide:{particleSize:4.5,color:11579392,name:"carbon dioxide",symbol:"CO<sub>2</sub>",mass:44.0095},oxygen:{particleSize:4,color:53488,name:"oxygen",symbol:"O<sub>2</sub>",mass:31.9988},nitrogen:{particleSize:3.5,color:12090177,name:"nitrogen",symbol:"N<sub>2</sub>",mass:28.0134},water:{particleSize:3,color:20735,name:"water",symbol:"H<sub>2</sub>O",mass:18.01528},ammonia:{particleSize:3,color:10506495,name:"ammonia",symbol:"NH<sub>3</sub>",mass:17.03052},methane:{particleSize:3,color:16737792,name:"methane",symbol:"CH<sub>4</sub>",mass:16.04246},helium:{particleSize:2.5,color:43520,name:"helium",symbol:"He",mass:4.002602},hydrogen:{particleSize:2.5,color:16711680,name:"hydrogen",symbol:"H<sub>2</sub>",mass:2.01588}};
   for(var x in this.gassesList)
   {
      this.gassesList[x].inUse = false;
      var color = this.gassesList[x].color;
      this.gassesList[x].curveColor = color;
      this.gassesList[x].outlineColor = color;
      this.gassesList[x].fillColor = color;
      this.gassesList[x].initObject = {particleColor:color,particleSize:this.gassesList[x].particleSize};
   }
}
var p = GasRetentionSimulatorClass.prototype = new MovieClip();
Object.registerClass("Gas Retention Simulator",GasRetentionSimulatorClass);
p.gasLimit = 3;
p.numParticlesMultiplier = 160;
p.onReset = function()
{
   if(this.chamberMC.animationState)
   {
      this.onStartSimulationButtonPressed();
   }
   for(var id in this.gassesList)
   {
      var g = this.gassesList[id];
      if(g.inUse)
      {
         g.inUse = false;
         this.listMC.removeEntry(id);
         this.plotMC[id].remove();
         this.chamberMC[id].remove();
         this.proportionsMC[id].remove();
      }
   }
   this.cursorMC.setSelectedGas(null);
   this.proportionsMC.update();
   this.refreshGassesComboBox();
   this.removeGasButton.setEnabled(false);
   this.temperatureSlider.value = this.defaultTemperature;
   this.onTemperatureChanged();
   this.escapeSpeedSlider.value = this.defaultEscapeSpeed;
   this.allowEscapeCheck.setValue(false);
   this.showCursorCheck.setValue(false);
   this.showSelectedInfoCheck.setValue(true);
};
p.resetProportions = function()
{
   for(var id in this.gassesList)
   {
      if(this.gassesList[id].inUse)
      {
         this.gassesList[id].fraction = 1;
         this.plotMC[id].fraction = 1;
         this.proportionsMC[id].fraction = 1;
         this.chamberMC[id].numberOfParticles = this.numParticlesMultiplier;
      }
   }
   this.proportionsMC.update();
   this.plotMC.update();
   this.refreshPercentages();
};
p.onShowSelectedInfoChanged = function()
{
   this.cursorMC.setInfoVisible(this.showSelectedInfoCheck.getValue());
};
p.onShowCursorChanged = function()
{
   var showCursor = this.showCursorCheck.getValue();
   this.cursorMC.setVisible(showCursor);
   this.cursorMC.update();
   this.showSelectedInfoCheck.setEnabled(showCursor);
};
p.recalculatePlotScale = function()
{
   var cL = this.plotMC._curvesList;
   var C = 0.5870506526949597;
   var maxPeak = -Infinity;
   var i = 0;
   while(i < cL.length)
   {
      var g = cL[i];
      if(!g.getIsInvalid())
      {
         var a = Math.sqrt(8314.47147 * this.temperatureSlider.minValue / g.mass);
         var peak = C / a;
         if(peak > maxPeak)
         {
            maxPeak = peak;
         }
      }
      i++;
   }
   this.plotMC.__yScale = (- this.plotMC.peakHeight) * this.plotMC._plotHeight / maxPeak;
};
p.init = function()
{
   this.defaultEscapeSpeed = this.escapeSpeedSlider.value;
   this.defaultTemperature = this.temperatureSlider.value;
   this.showSelectedInfoCheck.setEnabled(false);
   this.plotMC.lockYScale = true;
   this.refreshGassesComboBox();
   this.onEscapeSpeedSliderChanged();
   this.removeGasButton.setEnabled(false);
   this.onAllowEscapeChanged();
};
p.doPseudoCollisions = function()
{
   var startTimer = getTimer();
   var F = 0.1;
   var fractionalSum = 0;
   for(var x in this.gassesList)
   {
      if(this.gassesList[x].inUse)
      {
         fractionalSum += this.gassesList[x].fraction;
      }
   }
   F *= fractionalSum / this.gasLimit;
   F *= Math.sqrt(this.temperatureSlider.value / this.temperatureSlider.maxValue);
   var rand = Math.random;
   var gL = this.chamberMC.gassesList;
   var i = 0;
   while(i < gL.length)
   {
      var pL = gL[i].particlesList;
      var uL = [];
      var j = 0;
      while(j < pL.length)
      {
         if(rand() < F)
         {
            var p = pL[j];
            var u = rand();
            var speed = (0.0335009738566387 + u * (324.499855174808 + u * (67952.3527878137 + u * (1649609.82033456 + u * (2184252.22113819 + u * (-21058874.6332882 + u * (26738095.9605488 + u * (769197.569308745 + u * (-21394748.7073447 + u * (13624855.3507324 + u * -2580664.4615644)))))))))) / (1 + u * (1632.61962771862 + u * (155759.053592243 + u * (1790252.45942473 + u * (-3060237.16137971 + u * (-9765674.6273682 + u * (28452708.8769605 + u * (-25616300.7710808 + u * (7698980.62184725 + u * (1037426.91742616 + u * -694548.98898973))))))))));
            var angle = 6.283185307179586 * rand();
            p.unscaledV = speed;
            p.unscaledVX = speed * Math.cos(angle);
            p.unscaledVY = speed * Math.sin(angle);
            uL.push(p);
         }
         j++;
      }
      if(uL.length > 0)
      {
         gL[i].calculateSpeeds(uL);
      }
      i++;
   }
};
p.simulationOnEnterFrameFunc = function()
{
   this.doPseudoCollisions();
   if(this.allowEscapeCheck.getValue())
   {
      var dt = getTimer() - this.initialTime;
      var gL = this.gassesList;
      for(var x in gL)
      {
         if(gL[x].inUse)
         {
            var fraction = gL[x].initialFraction * Math.exp((- gL[x].decayConstant) * dt);
            gL[x].fraction = fraction;
            this.plotMC[x].fraction = fraction;
            this.proportionsMC[x].fraction = fraction;
            this.chamberMC[x].numberOfParticles = Math.round(this.numParticlesMultiplier * fraction);
         }
      }
      this.proportionsMC.update();
      this.plotMC.update();
      this.refreshPercentages();
   }
};
p.onStartSimulationButtonPressed = function()
{
   var s = !this.chamberMC.animationState;
   if(s)
   {
      this.startSimulationButton.setLabel("stop simulation");
      if(this.allowEscapeCheck.getValue())
      {
         var vesc = this.escapeSpeedSlider.value;
         var kT = this.temperatureSlider.value * 1.3806503e-23;
         var K = 0.001;
         var C1 = vesc / 1.4142135623730951;
         var C2 = 0.7978845608028654 * vesc;
         var C3 = (- vesc) * vesc / 2;
         var gL = this.gassesList;
         for(var x in gL)
         {
            if(gL[x].inUse)
            {
               var a = Math.sqrt(kT / (1.66053886e-27 * gL[x].mass));
               var fesc = 1 - (Math.erf(C1 / a) - C2 * Math.exp(C3 / (a * a)) / a);
               gL[x].decayConstant = K * fesc;
               gL[x].initialFraction = gL[x].fraction;
            }
         }
      }
      this.proportionsMC.enabled = false;
      this.temperatureSlider.userEnabled = false;
      this.temperatureSlider.update();
      this.escapeSpeedSlider.userEnabled = false;
      this.escapeSpeedSlider.update();
      this.gassesComboBox.setEnabled(false);
      this.allowEscapeCheck.setEnabled(false);
      this.removeGasButton.setEnabled(false);
      this.resetProportionsButton.setEnabled(false);
      this.initialTime = getTimer();
      this.onEnterFrame = this.simulationOnEnterFrameFunc;
   }
   else
   {
      this.startSimulationButton.setLabel("start simulation");
      delete this.onEnterFrame;
      this.proportionsMC.enabled = true;
      this.temperatureSlider.userEnabled = true;
      this.temperatureSlider.update();
      this.escapeSpeedSlider.userEnabled = this.allowEscapeCheck.getValue();
      this.escapeSpeedSlider.update();
      if(this.listMC.entriesList.length >= this.gasLimit)
      {
         this.gassesComboBox.setEnabled(false);
      }
      else
      {
         this.gassesComboBox.setEnabled(true);
      }
      this.allowEscapeCheck.setEnabled(true);
      if(this.listMC.getSelectedEntry() != null)
      {
         this.removeGasButton.setEnabled(true);
      }
      else
      {
         this.removeGasButton.setEnabled(false);
      }
      this.resetProportionsButton.setEnabled(true);
   }
   this.chamberMC.animationState = s;
};
p.onGassesComboBoxChanged = function()
{
   var id = this.gassesComboBox.getValue();
   if(id != "topLine")
   {
      this.gassesList[id].fraction = 1;
      this.gassesList[id].numberOfParticles = this.numParticlesMultiplier;
      this.gassesList[id].inUse = true;
      this.listMC.addEntry(id,this.gassesList[id]);
      this.plotMC.addCurve(id,this.gassesList[id]);
      this.recalculatePlotScale();
      this.plotMC.update();
      this.chamberMC.addGas(id,this.gassesList[id]);
      this.proportionsMC.addBar(id,this.gassesList[id]);
      this.proportionsMC.update();
      this.refreshGassesComboBox();
      this.refreshPercentages();
      this.selectGas(id);
   }
};
p.refreshPercentages = function()
{
   var sum = 0;
   var gL = this.gassesList;
   for(var x in gL)
   {
      if(gL[x].inUse)
      {
         sum += gL[x].fraction;
      }
   }
   for(var x in gL)
   {
      if(gL[x].inUse)
      {
         this.listMC[x].setPercent(100 * gL[x].fraction / sum);
      }
   }
};
p.refreshGassesComboBox = function()
{
   if(this.listMC.entriesList.length >= this.gasLimit)
   {
      this.gassesComboBox.setEnabled(true);
      this.gassesComboBox.removeAll();
      this.gassesComboBox.addItem("(limit reached)","topLine");
      this.gassesComboBox.setEnabled(false);
   }
   else
   {
      this.gassesComboBox.setEnabled(true);
      this.gassesComboBox.removeAll();
      this.gassesComboBox.addItem("select gas to add","topLine");
      for(var x in this.gassesList)
      {
         if(!this.gassesList[x].inUse)
         {
            this.gassesComboBox.addItem(this.gassesList[x].name,x);
         }
      }
   }
};
p.onRemoveGasButtonPressed = function()
{
   var id = this.listMC.getSelectedEntry();
   if(id != null)
   {
      this.gassesList[id].inUse = false;
      var oldListIndex = this.listMC.getIndexFromID(id);
      this.listMC.removeEntry(id);
      this.plotMC[id].remove();
      this.recalculatePlotScale();
      this.plotMC.update();
      this.chamberMC[id].remove();
      this.proportionsMC[id].remove();
      this.proportionsMC.update();
      this.refreshGassesComboBox();
      this.refreshPercentages();
      if(this.listMC.entriesList.length == 0)
      {
         this.selectGas(null);
      }
      else if(oldListIndex < this.listMC.entriesList.length)
      {
         this.selectGas(this.listMC.entriesList[oldListIndex].id);
      }
      else
      {
         this.selectGas(this.listMC.entriesList[this.listMC.entriesList.length - 1].id);
      }
   }
};
p.selectGas = function(id)
{
   this.plotMC[this.selectedGas].showFill = false;
   this.selectedGas = id;
   this.cursorMC.setSelectedGas(this.selectedGas);
   this.proportionsMC.setSelectedBar(this.selectedGas);
   this.listMC.setSelectedEntry(this.selectedGas);
   if(this.selectedGas != null)
   {
      this.plotMC[this.selectedGas].showFill = true;
      if(!this.chamberMC.animationState)
      {
         this.removeGasButton.setEnabled(true);
      }
   }
   else
   {
      this.removeGasButton.setEnabled(false);
   }
   this.plotMC.update();
};
p.onGasSelectedViaProportions = function(id)
{
   this.plotMC[this.selectedGas].showFill = false;
   this.selectedGas = id;
   this.cursorMC.setSelectedGas(this.selectedGas);
   this.listMC.setSelectedEntry(this.selectedGas);
   if(this.selectedGas != null)
   {
      this.plotMC[this.selectedGas].showFill = true;
      if(!this.chamberMC.animationState)
      {
         this.removeGasButton.setEnabled(true);
      }
   }
   else
   {
      this.removeGasButton.setEnabled(false);
   }
   this.plotMC.update();
};
p.onGasSelectedViaList = function(id)
{
   this.plotMC[this.selectedGas].showFill = false;
   this.selectedGas = id;
   this.cursorMC.setSelectedGas(this.selectedGas);
   this.proportionsMC.setSelectedBar(this.selectedGas);
   if(this.selectedGas != null)
   {
      this.plotMC[this.selectedGas].showFill = true;
      if(!this.chamberMC.animationState)
      {
         this.removeGasButton.setEnabled(true);
      }
   }
   else
   {
      this.removeGasButton.setEnabled(false);
   }
   this.plotMC.update();
};
p.onProportionsChanged = function(id, fraction)
{
   this.gassesList[id].fraction = fraction;
   this.plotMC[id].fraction = fraction;
   this.plotMC.update();
   this.chamberMC[id].numberOfParticles = Math.round(this.numParticlesMultiplier * fraction);
   this.refreshPercentages();
};
p.onTemperatureChanged = function()
{
   this.chamberMC.temperature = this.temperatureSlider.value;
   this.plotMC.temperature = this.temperatureSlider.value;
   this.plotMC.update();
   this.cursorMC.update();
};
p.onAllowEscapeChanged = function()
{
   var allowEscape = this.allowEscapeCheck.getValue();
   this.chamberMC.allowEscape = allowEscape;
   if(allowEscape)
   {
      this.escapeSpeedSlider.userEnabled = true;
      this.escapeSpeedSlider.update();
      this.escapeSpeedLabelMC._visible = true;
      this.onEscapeSpeedSliderChanged();
   }
   else
   {
      this.escapeSpeedSlider.userEnabled = false;
      this.escapeSpeedSlider.update();
      this.escapeSpeedLabelMC._visible = false;
      this.plotMC.escapeSpeedLineMC.removeMovieClip();
   }
};
p.onEscapeSpeedSliderChanged = function()
{
   this.chamberMC.escapeSpeed = this.escapeSpeedSlider.value;
   var x = (this.escapeSpeedSlider.value - this.plotMC._xMin) * this.plotMC.__xScale;
   this.plotMC.createEmptyMovieClip("escapeSpeedLineMC",325648);
   this.plotMC.escapeSpeedLineMC.lineStyle(1,9474192,100);
   this.plotMC.escapeSpeedLineMC.drawDashedLine(x,0,x,- this.plotMC._plotHeight,5,5);
   this.escapeSpeedLabelMC._x = this.plotMC._x + x;
};
