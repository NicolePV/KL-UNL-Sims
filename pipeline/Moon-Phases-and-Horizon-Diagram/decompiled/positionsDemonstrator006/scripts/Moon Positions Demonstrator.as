function MoonPositionsDemonstratorClass()
{
}
var p = MoonPositionsDemonstratorClass.prototype = new MovieClip();
Object.registerClass("Moon Positions Demonstrator",MoonPositionsDemonstratorClass);
p.init = function()
{
   this.hackSlider(this.sunPositionSlider);
   this.hackSlider(this.moonPositionSlider);
   this.sphereMC.siderealTime = 0;
   this.sphereMC.viewerAzimuth = 200;
   this.sphereMC.latitude = this.latitudeSlider.value;
   this.sphereMC.size = 320;
   this.sphereMC.minViewerAltitude = 7;
   this.sphereMC.onMouseUpdate = function()
   {
      updateAfterEvent();
   };
   this.sphereMC.addHorizonPlaneClip("Direction Labels Light","aboveLabels","above");
   this.sphereMC.addHorizonPlaneClip("CSGradientDisk","horizonShade","above",5,{innerAlpha:0,innerColor:0,outerAlpha:0,outerColor:0});
   this.sphereMC.addObject("Stickfigure","stickfigure",{x:0,y:0,z:0.0001,system:"horizon"});
   this.sphereMC.stickfigure.setOrientationType("absolute",{x:-1,y:0,z:0,system:"horizon"},{x:0,y:0,z:1,system:"horizon"});
   this.sphereMC.addObject("ShadowMaker","shadow",{x:0,y:0,z:0,system:"horizon"},{shadowClip:"Stickfigure Shadow"});
   this.sphereMC.shadow.setOrientationType("absolute",{x:0,y:0,z:1,system:"horizon"},{x:1,y:0,z:0,system:"horizon"});
   this.sphereMC.addObject("Shadow Mask","shadowMask",{x:0,y:0,z:0,system:"horizon"});
   this.sphereMC.shadowMask.setOrientationType("absolute",{x:0,y:0,z:1,system:"horizon"},{x:1,y:0,z:0,system:"horizon"});
   this.sphereMC.shadow.instance.setMask(this.sphereMC.shadowMask.instance);
   this.sphereMC.addCircle("meridian1",{thickness:1,color:14737632,alpha:70},{dec:0,ra:0,tilt:90});
   this.sphereMC.addCircle("meridian2",{thickness:1,color:14737632,alpha:70},{dec:0,ra:90,tilt:90});
   this.sphereMC.addCircle("celestialEquator",{thickness:2,color:15259800,alpha:100},{dec:0,ra:0,tilt:0});
   this.sphereMC.addLine("ncpAxis",{thickness:2,color:2192638,alpha:100},{x:0,y:0,z:1,system:"celestial"},{x:0,y:0,z:1.2,system:"celestial"});
   this.sphereMC.addLine("scpAxis",{thickness:2,color:2192638,alpha:100},{x:0,y:0,z:-1,system:"celestial"},{x:0,y:0,z:-1.2,system:"celestial"});
   this.sphereMC.addObject("Moon Disc","moon",{ra:0,dec:0});
   this.sphereMC.addObject("Sun Disc","sun",{ra:4,dec:0,r:1.00001});
   var i = 1;
   while(i <= 8)
   {
      this.sphereMC.addObject("Position Dot","dot" + i,{ra:9 - i * 3,dec:0,r:1.00005});
      this.sphereMC["dot" + i].setOrientationType("absolute");
      i++;
   }
   var labelR = 1;
   var labelDec = 12;
   var i = 1;
   while(i <= 8)
   {
      this.sphereMC.addObject("Position Label","label" + i,{ra:9 - i * 3,dec:labelDec,r:labelR},{labelText:i});
      this.sphereMC["label" + i].setOrientationType("absolute");
      i++;
   }
   this.sphereMC.addShadedBand("Band Disc","Band Disc","eclipticBand",{dec1:-30,dec2:30},"inner","full");
   this.sphereMC.eclipticBand.setBorderStyle(1,11579568,50);
   this.sphereMC.eclipticBand.showBorder = true;
   this.onShowPositionLabelsChanged();
   this.onShowEclipticBandChanged();
   this.onShowTimeChanged();
   this.onSunPositionChanged(null,true);
   this.onShowMoonPhaseChanged();
   this.onEnableMoonChanged();
   this.onShowPhaseOnDiscChanged();
   this.onMoonPositionChanged(null,true);
   this.updateShadow();
   this.updateTimeOfDay();
   this.updateMoonPhase();
   this.sphereMC.update();
};
p.updateTimeOfDay = function()
{
   var time = ((6 + 3 * (this.sunPositionSlider.value - 1)) % 24 + 24) % 24;
   if(time < 12)
   {
      var timeStr = "AM";
   }
   else
   {
      time -= 12;
      var timeStr = "PM";
   }
   var hour = Math.floor(time);
   var min = Math.floor(60 * (time - hour));
   if(hour == 0)
   {
      hour = 12;
   }
   if(hour < 10)
   {
      var hourStr = " " + String(hour);
   }
   else
   {
      var hourStr = String(hour);
   }
   if(min < 10)
   {
      var minStr = "0" + String(min);
   }
   else
   {
      var minStr = String(min);
   }
   this.timeOfDayField.text = hourStr + ":" + minStr + " " + timeStr;
};
p.updateShadow = function()
{
   var hpos = {};
   this.sphereMC.sun.getPositionHorizon(hpos);
   this.sphereMC.shadow.instance.setSourcePosition(hpos);
   var horizonAlpha = 40 * Math.pow(1 - hpos.alt / 90,4);
   if(horizonAlpha > 40)
   {
      horizonAlpha = 40;
   }
   this.sphereMC.horizonShade.innerAlpha = this.sphereMC.horizonShade.outerAlpha = horizonAlpha;
   this.sphereMC.horizonShade.update();
};
p.updateMoonPhase = function()
{
   this.sphereMC.moon.instance.update();
   var phaseAngle = 15 * (this.sphereMC.sun.ra - this.sphereMC.moon.ra) + 180;
   this.phaseDiscMC.drawPhaseDisc(phaseAngle,{radius:30,lightColor:13684944,darkColor:9474192,lineThickness:0,lineColor:9474192,lineAlpha:100});
   var descriptorsList = ["New Moon","Waxing Cresent","First Quarter","Waxing Gibbous","Full Moon","Waning Gibbous","Third Quarter","Waning Crescent"];
   var qTol = 5;
   var fTol = 12;
   var positionAngle = ((180 - phaseAngle) % 360 + 360) % 360;
   if(positionAngle <= fTol)
   {
      var descriptorID = 0;
   }
   else if(positionAngle <= 90 - qTol)
   {
      var descriptorID = 1;
   }
   else if(positionAngle <= 90 + qTol)
   {
      var descriptorID = 2;
   }
   else if(positionAngle <= 180 - fTol)
   {
      var descriptorID = 3;
   }
   else if(positionAngle <= 180 + fTol)
   {
      var descriptorID = 4;
   }
   else if(positionAngle <= 270 - qTol)
   {
      var descriptorID = 5;
   }
   else if(positionAngle <= 270 + qTol)
   {
      var descriptorID = 6;
   }
   else if(positionAngle <= 360 - fTol)
   {
      var descriptorID = 7;
   }
   else
   {
      var descriptorID = 0;
   }
   this.moonPhaseField.text = descriptorsList[descriptorID];
};
p.onMoonPositionChanged = function(notUsed, skipUpdate)
{
   var newRA = -3 * (this.moonPositionSlider.value - 1) + 6;
   this.sphereMC.moon.setPosition({ra:newRA,dec:0});
   var moonPos = {};
   this.sphereMC.moon.getPosition(moonPos);
   moonPos.x = - moonPos.x;
   moonPos.y = - moonPos.y;
   moonPos.z = - moonPos.z;
   this.sphereMC.moon.setOrientationType("absolute",moonPos,{ra:0,dec:90});
   if(!skipUpdate)
   {
      this.sphereMC.updateObjects();
      this.updateMoonPhase();
   }
};
p.onShowPhaseOnDiscChanged = function()
{
   this.sphereMC.moon.instance.setShowPhase(this.showPhaseOnDiscCheckBox.getValue());
};
p.onEnableMoonChanged = function()
{
   var enabled = this.enableMoonCheckBox.getValue();
   if(enabled)
   {
      this.onShowMoonPhaseChanged();
      this.moonPositionSlider.labelAndUnitsTextColor = 0;
      this.moonPositionSlider.fieldDisabledBackgroundColor = 16777215;
      this.moonPositionSlider.fieldDisabledTextColor = 0;
      this.sphereMC.moon.visible = true;
      this.sphereMC.updateObjects();
   }
   else
   {
      this.moonPhaseLabelField.textColor = 9474192;
      this.moonPhaseField._visible = false;
      this.phaseDiscMC._visible = false;
      this.moonPositionSlider.labelAndUnitsTextColor = 9474192;
      this.moonPositionSlider.fieldDisabledBackgroundColor = 15921906;
      this.moonPositionSlider.fieldDisabledTextColor = 9474192;
      this.sphereMC.moon.visible = false;
   }
   this.showMoonPhaseCheckBox.setEnabled(enabled);
   this.showPhaseOnDiscCheckBox.setEnabled(enabled);
   this.moonPositionSlider.userEnabled = enabled;
   this.moonPositionSlider.update();
};
p.onShowMoonPhaseChanged = function()
{
   var show = this.showMoonPhaseCheckBox.getValue();
   this.moonPhaseLabelField.textColor = !show ? 9474192 : 0;
   this.moonPhaseField._visible = show;
   this.phaseDiscMC._visible = show;
};
p.onSunPositionChanged = function(notUsed, skipUpdate)
{
   var newRA = -3 * (this.sunPositionSlider.value - 1) + 6;
   this.sphereMC.sun.setPosition({ra:newRA,dec:0,r:1.00001});
   this.sphereMC.sun.setOrientationType("absolute");
   if(!skipUpdate)
   {
      this.sphereMC.updateObjects();
      this.updateShadow();
      this.updateTimeOfDay();
      this.updateMoonPhase();
   }
};
p.onShowTimeChanged = function()
{
   if(this.showTimeCheckBox.getValue())
   {
      this.timeOfDayLabelField.textColor = 0;
      this.timeOfDayField._visible = true;
   }
   else
   {
      this.timeOfDayLabelField.textColor = 9474192;
      this.timeOfDayField._visible = false;
   }
};
p.onShowPositionLabelsChanged = function()
{
   var visible = this.showPositionLabelsCheckBox.getValue();
   var i = 1;
   while(i <= 8)
   {
      this.sphereMC["dot" + i].visible = visible;
      this.sphereMC["label" + i].visible = visible;
      i++;
   }
   if(visible)
   {
      this.sphereMC.updateObjects();
   }
};
p.onLatitudeChanged = function()
{
   this.sphereMC.latitude = this.latitudeSlider.value;
   this.updateShadow();
};
p.onShowEclipticBandChanged = function()
{
   this.sphereMC.eclipticBand.visible = this.showEclipticBandCheckBox.getValue();
};
p.hackSlider = function(sliderMC)
{
   sliderMC.grabberMC.onRelease = sliderMC.grabberMC.onReleaseOutside = function()
   {
      if(this._parent.userEnabled)
      {
         this.animStartValue = this._parent.controller.value;
         this.animEndValue = Math.round(this._parent.controller.value);
         this.animStartTimer = getTimer();
         this.animTime = 200;
         this._parent.userEnabled = false;
         this._parent.update();
         this.onEnterFrame = this.onEnterFrameFunc;
      }
      delete this.onMouseMove;
   };
   sliderMC.grabberMC.onEnterFrameFunc = function()
   {
      var u = (getTimer() - this.animStartTimer) / this.animTime;
      if(u >= 1)
      {
         this._parent.setValue(this.animEndValue,true);
         this._parent.userEnabled = true;
         this._parent.update();
         delete this.onEnterFrame;
      }
      else
      {
         var newValue = this.animStartValue + (this.animEndValue - this.animStartValue) * Math.pow(u,0.3);
         this._parent.setValue(newValue,true);
      }
   };
   sliderMC.grabberMC.onKeyDownFunc = function()
   {
      var c = this._parent.controller;
      if(Key.isDown(37))
      {
         this._parent.incrementValue(-1,true);
      }
      else if(Key.isDown(39))
      {
         this._parent.incrementValue(1,true);
      }
   };
   delete sliderMC.barMC.onEnterFrameFunc;
   sliderMC.incrementValue = function(ticks, callChangeHandler)
   {
      if(typeof ticks == "number" && !isNaN(ticks) && isFinite(ticks))
      {
         if(ticks < 0 && this.controller.value > 1)
         {
            this.controller.value = Math.round(this.controller.value - 1);
         }
         else if(ticks > 0 && this.controller.value < 8)
         {
            this.controller.value = Math.round(this.controller.value + 1);
         }
         else
         {
            this.controller.value = Math.round(this.controller.value);
         }
      }
      this.updateSynchronization();
      if(callChangeHandler)
      {
         this._parent[this.changeHandler](this.controller.value);
      }
   };
   sliderMC.updateSynchronization = function()
   {
      this.grabberMC._x = this.controller.parameter;
      this.valueField.text = Math.round(this.controller.value);
   };
   sliderMC.maxChars = 1;
   sliderMC.minValue = 0.51;
   sliderMC.maxValue = 8.49;
   sliderMC.precision = 3;
   sliderMC.fieldDisabledBackgroundColor = 16777215;
   sliderMC.fieldDisabledTextColor = 0;
   sliderMC.update();
};
