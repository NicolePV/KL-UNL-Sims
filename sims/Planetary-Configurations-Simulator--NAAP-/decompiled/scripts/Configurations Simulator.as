function ConfigurationsSimulatorClass()
{
   this.systemPropertiesListenerList = [];
   this.updateListenerList = [];
   this.resetListenerList = [];
   this.clickToCancelMC.tabEnabled = false;
   this.clickToCancelMC.useHandCursor = true;
   this.clickToCancelMC.onPress = function()
   {
      this._parent.cancelAnimationCountdown();
   };
}
var p = ConfigurationsSimulatorClass.prototype = new MovieClip();
Object.registerClass("Configurations Simulator",ConfigurationsSimulatorClass);
p.slewTime = 650;
p.onReset = function()
{
   this.calculateSystemProperties = function()
   {
   };
   this.calculateAnimationRate = function()
   {
   };
   this.setTime = function()
   {
   };
   this.epochAngle1 = 0;
   this.epochAngle2 = 0;
   this.setSemimajorAxis(1,1,true);
   this.setSemimajorAxis(2,2.4,true);
   this.semimajorAxis1Slider.value = 1;
   this.semimajorAxis2Slider.value = 2.4;
   this.setAnimationState(false);
   this.angularAnimationRateSlider.value = 0.001;
   this.eventActionGroup.setValue("run");
   this.pauseTimeSlider.value = 5;
   delete this.calculateSystemProperties;
   delete this.calculateAnimationRate;
   delete this.setTime;
   this.calculateSystemProperties();
   this.calculateAnimationRate();
   this.setTime(0,true);
   this.semimajorAxis1ComboBox.setSelectedIndex(0,false);
   this.semimajorAxis2ComboBox.setSelectedIndex(0,false);
   var i = 0;
   while(i < this.resetListenerList.length)
   {
      this.resetListenerList[i].onSimulatorReset();
      i++;
   }
};
p.addResetListener = function(arg)
{
   this.resetListenerList.push(arg);
};
p.update = function()
{
   this.angle1 = this.epochAngle1 + 6.283185307179586 * this.time / this.period1;
   this.angle1 = (this.angle1 % 6.283185307179586 + 6.283185307179586) % 6.283185307179586;
   this.angle2 = this.epochAngle2 + 6.283185307179586 * this.time / this.period2;
   this.angle2 = (this.angle2 % 6.283185307179586 + 6.283185307179586) % 6.283185307179586;
   var x1 = this.semimajorAxis1 * Math.cos(this.angle1);
   var y1 = this.semimajorAxis1 * Math.sin(this.angle1);
   var x2 = this.semimajorAxis2 * Math.cos(this.angle2);
   var y2 = this.semimajorAxis2 * Math.sin(this.angle2);
   this.planetLongitude = (Math.atan2(y2 - y1,x2 - x1) % 6.283185307179586 + 6.283185307179586) % 6.283185307179586;
   this.sunLongitude = (Math.atan2(- y1,- x1) % 6.283185307179586 + 6.283185307179586) % 6.283185307179586;
   var elong = ((this.sunLongitude - this.planetLongitude) * 180 / 3.141592653589793 % 360 + 360) % 360;
   if(elong > 180)
   {
      elong -= 360;
   }
   this.elongationString = Math.abs(elong).toFixed(1);
   this.elongationValue = parseFloat(this.elongationString);
   if(elong < 0 && this.elongationValue != 180)
   {
      this.elongationValue *= -1;
   }
   this.elongationString += "°";
   if(this.elongationValue < 0)
   {
      this.elongationString += " E";
   }
   else if(this.elongationValue > 0 && this.elongationValue != 180)
   {
      this.elongationString += " W";
   }
   var i = 0;
   while(i < this.updateListenerList.length)
   {
      this.updateListenerList[i].onSimulatorUpdated();
      i++;
   }
};
p.addUpdateListener = function(arg)
{
   this.updateListenerList.push(arg);
};
p.calculateAnimationRate = function()
{
   this.animationRate = this.angularAnimationRateSlider.value * Math.min(this.period1,this.period2) / 6.283185307179586;
};
p.onPauseTimeChanged = function()
{
   this.eventActionGroup.setValue("pause");
};
p.startAnimationCountdown = function()
{
   this.clickToCancelMC._visible = true;
   this.onEnterFrame = this.animationCountdownOnEnterFrame;
   this.countdownEndsTimer = getTimer() + 1000 * this.pauseTimeSlider.value;
};
p.cancelAnimationCountdown = function()
{
   if(this.onEnterFrame == this.animationCountdownOnEnterFrame)
   {
      delete this.onEnterFrame;
   }
   this.countdownField.text = "";
   this.clickToCancelMC._visible = false;
};
p.animationCountdownOnEnterFrame = function()
{
   var timeNow = getTimer();
   var timeleft = Math.ceil((this.countdownEndsTimer - timeNow) / 1000);
   if(timeleft == 1)
   {
      this.countdownField.text = "paused for " + timeleft + " more second";
   }
   else
   {
      this.countdownField.text = "paused for " + timeleft + " more seconds";
   }
   if(timeNow > this.countdownEndsTimer)
   {
      this.cancelAnimationCountdown();
      this.setAnimationState(true);
   }
};
p.getAnimationState = function()
{
   return this._animationState;
};
p.setAnimationState = function(arg)
{
   this.cancelAnimationCountdown();
   this._animationState = Boolean(arg);
   if(this._animationState)
   {
      this.timerLast = getTimer();
      this.onEnterFrame = this.animateOnEnterFrame;
      this.animationButton.setLabel("stop animation");
   }
   else
   {
      delete this.onEnterFrame;
      this.animationButton.setLabel("start animation");
   }
};
p.addProperty("animationState",p.getAnimationState,p.setAnimationState);
p.toggleAnimation = function()
{
   this.setAnimationState(!this.getAnimationState());
};
p.animateOnEnterFrame = function()
{
   var timerNow = getTimer();
   var newTime = this.time + this.animationRate * (timerNow - this.timerLast);
   if(newTime > this.nextEventTime && this.eventActionGroup.getValue() != "run")
   {
      this.setTimeByCycleAndEventNumbers(this.nextCycleNumber,this.nextEventNumber);
      this.setAnimationState(false);
      if(this.eventActionGroup.getValue() == "pause")
      {
         this.startAnimationCountdown();
      }
   }
   else
   {
      this.setTime(newTime);
   }
   this.timerLast = timerNow;
};
p.freezeAnimation = function()
{
   this.cancelAnimationCountdown();
   delete this.onEnterFrame;
};
p.thawAnimation = function()
{
   if(this._animationState)
   {
      this.timerLast = getTimer();
      this.onEnterFrame = this.animateOnEnterFrame;
   }
};
p.slewToEvent = function(cycleNumber, eventNumber)
{
   if(this.lockedOnEvent && this.lockedCycleNumber == cycleNumber && this.lockedEventNumber == eventNumber)
   {
      return undefined;
   }
   this.cancelAnimationCountdown();
   this.setAnimationState(false);
   this.slewStartTimer = getTimer();
   this.slewTargetCycleNumber = cycleNumber;
   this.slewTargetEventNumber = eventNumber;
   var slewTargetTime = this.cycleOffset + cycleNumber * this.synodicPeriod + this.eventTimesList[eventNumber];
   this.slewStartTime = this.time;
   this.slewDeltaTime = slewTargetTime - this.slewStartTime;
   this.timerLast = this.slewStartTimer;
   this.onEnterFrame = this.slewOnEnterFrame;
};
p.slewOnEnterFrame = function()
{
   var timerNow = getTimer();
   var u = (timerNow - this.slewStartTimer) / this.slewTime;
   if(u < 1)
   {
      var f = 1 - Math.pow(1 - u,3);
      var newTime = this.slewStartTime + f * this.slewDeltaTime;
      this.setTime(newTime);
   }
   else
   {
      this.setTimeByCycleAndEventNumbers(this.slewTargetCycleNumber,this.slewTargetEventNumber);
      delete this.onEnterFrame;
   }
   this.timerLast = timeNow;
};
p.getTime = function()
{
   return this._time;
};
p.setTime = function(newTime, snapToEvents, timeThreshold)
{
   this.cancelAnimationCountdown();
   if(snapToEvents)
   {
      var prevCycleNumber = Math.floor((newTime - this.cycleOffset) / this.synodicPeriod);
      var timeRemainder = newTime - this.cycleOffset - prevCycleNumber * this.synodicPeriod;
      if(timeRemainder < 0)
      {
         timeRemainder = 0;
      }
      var i = 0;
      while(i < 4)
      {
         if(timeRemainder < this.eventTimesList[i])
         {
            break;
         }
         i++;
      }
      var prevEventNumber = i - 1;
      if(i < 4)
      {
         var nextEventNumber = i;
         var nextCycleNumber = prevCycleNumber;
      }
      else
      {
         var nextEventNumber = 0;
         var nextCycleNumber = prevCycleNumber + 1;
      }
      var prevEventTime = this.cycleOffset + prevCycleNumber * this.synodicPeriod + this.eventTimesList[prevEventNumber];
      var nextEventTime = this.cycleOffset + nextCycleNumber * this.synodicPeriod + this.eventTimesList[nextEventNumber];
      var timeToPrevEvent = Math.abs(newTime - prevEventTime);
      var timeToNextEvent = Math.abs(nextEventTime - newTime);
      var nearestEventTime = Math.min(timeToPrevEvent,timeToNextEvent);
      if(timeThreshold == undefined || timeThreshold == null || nearestEventTime < timeThreshold)
      {
         if(nearestEventTime == timeToPrevEvent)
         {
            this.setTimeByCycleAndEventNumbers(prevCycleNumber,prevEventNumber);
         }
         else
         {
            this.setTimeByCycleAndEventNumbers(nextCycleNumber,nextEventNumber);
         }
         return undefined;
      }
   }
   this._time = newTime;
   this.currentCycleNumber = Math.floor((this._time - this.cycleOffset) / this.synodicPeriod);
   var timeRemainder = this._time - this.cycleOffset - this.currentCycleNumber * this.synodicPeriod;
   if(timeRemainder < 0)
   {
      timeRemainder = 0;
   }
   var i = 0;
   while(i < 4)
   {
      if(timeRemainder < this.eventTimesList[i])
      {
         break;
      }
      i++;
   }
   if(i < 4)
   {
      this.nextEventNumber = i;
      this.nextCycleNumber = this.currentCycleNumber;
   }
   else
   {
      this.nextEventNumber = 0;
      this.nextCycleNumber = this.currentCycleNumber + 1;
   }
   this.nextEventTime = this.cycleOffset + this.nextCycleNumber * this.synodicPeriod + this.eventTimesList[this.nextEventNumber];
   this.lockedOnEvent = false;
   this.update();
};
p.addProperty("time",p.getTime,p.setTime);
p.setTimeByCycleAndEventNumbers = function(cycleNumber, eventNumber, noLock)
{
   this.cancelAnimationCountdown();
   this._time = this.cycleOffset + cycleNumber * this.synodicPeriod + this.eventTimesList[eventNumber];
   this.currentCycleNumber = cycleNumber;
   this.nextCycleNumber = cycleNumber;
   this.nextEventNumber = eventNumber + 1;
   if(this.nextEventNumber == 4)
   {
      this.nextEventNumber = 0;
      this.nextCycleNumber += 1;
   }
   this.nextEventTime = this.cycleOffset + this.nextCycleNumber * this.synodicPeriod + this.eventTimesList[this.nextEventNumber];
   this.lockedOnEvent = !noLock;
   if(this.lockedOnEvent)
   {
      this.lockedCycleNumber = cycleNumber;
      this.lockedEventNumber = eventNumber;
   }
   this.update();
};
p.setTimeByPlanetAngle = function(planetID, newAngle, snapToEvents, angleThreshold)
{
   this.cancelAnimationCountdown();
   var epochAngle = this["epochAngle" + planetID];
   var period = this["period" + planetID];
   var oldAngle = epochAngle + 6.283185307179586 * this.time / period;
   oldAngle = (oldAngle % 6.283185307179586 + 6.283185307179586) % 6.283185307179586;
   var deltaAngle = newAngle - oldAngle;
   if(deltaAngle < -3.141592653589793)
   {
      deltaAngle += 6.283185307179586;
   }
   if(deltaAngle > 3.141592653589793)
   {
      deltaAngle -= 6.283185307179586;
   }
   var newTime = this.time + deltaAngle * period / 6.283185307179586;
   if(snapToEvents)
   {
      var prevCycleNumber = Math.floor((newTime - this.cycleOffset) / this.synodicPeriod);
      var timeRemainder = newTime - this.cycleOffset - prevCycleNumber * this.synodicPeriod;
      if(timeRemainder < 0)
      {
         timeRemainder = 0;
      }
      var i = 0;
      while(i < 4)
      {
         if(timeRemainder < this.eventTimesList[i])
         {
            break;
         }
         i++;
      }
      var prevEventNumber = i - 1;
      if(i < 4)
      {
         var nextEventNumber = i;
         var nextCycleNumber = prevCycleNumber;
      }
      else
      {
         var nextEventNumber = 0;
         var nextCycleNumber = prevCycleNumber + 1;
      }
      var prevEventTime = this.cycleOffset + prevCycleNumber * this.synodicPeriod + this.eventTimesList[prevEventNumber];
      var nextEventTime = this.cycleOffset + nextCycleNumber * this.synodicPeriod + this.eventTimesList[nextEventNumber];
      var angleToPrevEvent = (newTime - prevEventTime) * 2 * 3.141592653589793 / period;
      var angleToNextEvent = (nextEventTime - newTime) * 2 * 3.141592653589793 / period;
      var minAngle = Math.min(angleToNextEvent,angleToPrevEvent);
      if(minAngle < angleThreshold)
      {
         if(minAngle == angleToNextEvent)
         {
            this.setTimeByCycleAndEventNumbers(nextCycleNumber,nextEventNumber);
         }
         else
         {
            this.setTimeByCycleAndEventNumbers(prevCycleNumber,prevEventNumber);
         }
      }
      else
      {
         this.setTime(newTime);
      }
   }
   else
   {
      this.setTime(newTime);
   }
};
p.setEpochAngleByPlanetAngle = function(planetID, newAngle, snapToEvents, angleThreshold)
{
   this.cancelAnimationCountdown();
   if(snapToEvents)
   {
      var otherID = 1 + planetID % 2;
      var thisSemimajor = this["semimajorAxis" + planetID];
      var otherSemimajor = this["semimajorAxis" + otherID];
      var otherAngle = this["angle" + otherID];
      var snapAnglesList = [];
      snapAnglesList[0] = otherAngle;
      snapAnglesList[2] = ((otherAngle + 3.141592653589793) % 6.283185307179586 + 6.283185307179586) % 6.283185307179586;
      if(thisSemimajor < otherSemimajor)
      {
         var theta = Math.acos(thisSemimajor / otherSemimajor);
      }
      else
      {
         var theta = - Math.acos(otherSemimajor / thisSemimajor);
      }
      snapAnglesList[1] = ((otherAngle + theta) % 6.283185307179586 + 6.283185307179586) % 6.283185307179586;
      snapAnglesList[3] = ((otherAngle - theta) % 6.283185307179586 + 6.283185307179586) % 6.283185307179586;
      var closestSnapAngleDistance = Infinity;
      var closestSnapAngleEventNumber = null;
      var i = 0;
      while(i < 4)
      {
         var delta = newAngle - snapAnglesList[i];
         if(delta < -3.141592653589793)
         {
            delta += 6.283185307179586;
         }
         else if(delta > 3.141592653589793)
         {
            delta -= 6.283185307179586;
         }
         if(Math.abs(delta) < closestSnapAngleDistance)
         {
            closestSnapAngleDistance = Math.abs(delta);
            closestSnapAngleEventNumber = i;
         }
         i++;
      }
      if(closestSnapAngleDistance < angleThreshold)
      {
         var snapEventNumber = closestSnapAngleEventNumber;
         newAngle = snapAnglesList[snapEventNumber];
         var setTimeByEventDetails = true;
      }
      else
      {
         var setTimeByEventDetails = false;
      }
   }
   else
   {
      var setTimeByEventDetails = false;
   }
   var newEpochAngle = newAngle - 6.283185307179586 * this.time / this["period" + planetID];
   newEpochAngle = (newEpochAngle % 6.283185307179586 + 6.283185307179586) % 6.283185307179586;
   this["epochAngle" + planetID] = newEpochAngle;
   this.calculateSystemProperties();
   if(setTimeByEventDetails)
   {
      var snapCycleNumber = Math.round((this.time - this.cycleOffset - this.eventTimesList[snapEventNumber]) / this.synodicPeriod);
      this.setTimeByCycleAndEventNumbers(snapCycleNumber,snapEventNumber);
   }
   else
   {
      this.setTime(this.time);
   }
};
p.setEpochAngle = function(planetID, epochAngle)
{
   this.cancelAnimationCountdown();
   this["epochAngle" + planetID] = (epochAngle % 6.283185307179586 + 6.283185307179586) % 6.283185307179586;
   this.calculateSystemProperties();
   this.setTime(this.time);
};
p.onSemimajorAxis1ComboBoxChanged = function()
{
   var a = parseFloat(this.semimajorAxis1ComboBox.getValue());
   if(a != 0 && isFinite(a) && !isNaN(a))
   {
      var success = this.setSemimajorAxis(1,a);
      if(success)
      {
         this.semimajorAxis1Slider.value = this.semimajorAxis1;
      }
      else
      {
         this.semimajorAxis1ComboBox.setSelectedIndex(0,false);
      }
   }
   else
   {
      this.semimajorAxis1ComboBox.setSelectedIndex(0,false);
   }
};
p.onSemimajorAxis2ComboBoxChanged = function()
{
   var a = parseFloat(this.semimajorAxis2ComboBox.getValue());
   if(a != 0 && isFinite(a) && !isNaN(a))
   {
      var success = this.setSemimajorAxis(2,a);
      if(success)
      {
         this.semimajorAxis2Slider.value = this.semimajorAxis2;
      }
      else
      {
         this.semimajorAxis2ComboBox.setSelectedIndex(0,false);
      }
   }
   else
   {
      this.semimajorAxis2ComboBox.setSelectedIndex(0,false);
   }
};
p.setSemimajorAxisFromSlider = function(id)
{
   var slider = this["semimajorAxis" + id + "Slider"];
   var newValue = slider.value;
   var success = this.setSemimajorAxis(id,newValue);
   if(!success)
   {
      var oldValue = this["semimajorAxis" + id];
      var otherValue = this["semimajorAxis" + (1 + id % 2)];
      if(newValue == slider.maxValue)
      {
         this.setSemimajorAxis(id,slider.maxValue - slider.controller._minIncrement);
      }
      else if(newValue == slider.minValue)
      {
         this.setSemimajorAxis(id,slider.minValue + slider.controller._minIncrement);
      }
      else if(oldValue < otherValue)
      {
         this.setSemimajorAxis(id,otherValue + slider.controller._minIncrement);
      }
      else
      {
         this.setSemimajorAxis(id,otherValue - slider.controller._minIncrement);
      }
      slider.value = this["semimajorAxis" + id];
   }
   this["semimajorAxis" + id + "ComboBox"].setSelectedIndex(0,false);
};
p.onSemimajorAxis1Changed = function()
{
   this.setSemimajorAxisFromSlider(1);
};
p.onSemimajorAxis2Changed = function()
{
   this.setSemimajorAxisFromSlider(2);
};
p.setSemimajorAxis = function(planetID, semimajorAxis, keepEpochAngleFixed)
{
   this.cancelAnimationCountdown();
   if(Math.abs(semimajorAxis - this["semimajorAxis" + (1 + planetID % 2)]) < 1e-10)
   {
      return false;
   }
   this["semimajorAxis" + planetID] = semimajorAxis;
   var newPeriod = Math.pow(semimajorAxis,1.5);
   if(!keepEpochAngleFixed)
   {
      var positionAngle = this["epochAngle" + planetID] + 6.283185307179586 * this.time / this["period" + planetID];
      var newEpochAngle = positionAngle - 6.283185307179586 * this.time / newPeriod;
      this["epochAngle" + planetID] = (newEpochAngle % 6.283185307179586 + 6.283185307179586) % 6.283185307179586;
   }
   this["period" + planetID] = newPeriod;
   this.calculateSystemProperties();
   this.calculateAnimationRate();
   if(this.lockedOnEvent && this.lockedEventNumber % 2 == 0)
   {
      this.setTime(this.time,true);
   }
   else
   {
      this.setTime(this.time);
   }
   return true;
};
p.calculateSystemProperties = function()
{
   if(this.semimajorAxis1 < this.semimajorAxis2)
   {
      var inferiorSemimajor = this.semimajorAxis1;
      var superiorSemimajor = this.semimajorAxis2;
      var inferiorPeriod = this.period1;
      var superiorPeriod = this.period2;
      var inferiorEpochAngle = this.epochAngle1;
      var superiorEpochAngle = this.epochAngle2;
      this.eventNamesList = ["opposition","quadrature (eastern)","conjunction","quadrature (western)"];
   }
   else
   {
      var inferiorSemimajor = this.semimajorAxis2;
      var superiorSemimajor = this.semimajorAxis1;
      var inferiorPeriod = this.period2;
      var superiorPeriod = this.period1;
      var inferiorEpochAngle = this.epochAngle2;
      var superiorEpochAngle = this.epochAngle1;
      this.eventNamesList = ["inferior conjunction","greatest elongation (western)","superior conjunction","greatest elongation (eastern)"];
   }
   this.synodicPeriod = 1 / (1 / inferiorPeriod - 1 / superiorPeriod);
   var epochAngleOffset = ((superiorEpochAngle - inferiorEpochAngle) % 6.283185307179586 + 6.283185307179586) % 6.283185307179586;
   var catchUpRate = 6.283185307179586 / this.synodicPeriod;
   this.cycleOffset = epochAngleOffset / catchUpRate;
   var deltaTime = Math.acos(inferiorSemimajor / superiorSemimajor) / catchUpRate;
   this.eventTimesList = [0];
   this.eventTimesList.push(deltaTime);
   this.eventTimesList.push(this.synodicPeriod / 2);
   this.eventTimesList.push(this.synodicPeriod - deltaTime);
   var i = 0;
   while(i < this.systemPropertiesListenerList.length)
   {
      this.systemPropertiesListenerList[i].onSystemPropertiesChanged();
      i++;
   }
};
p.addSystemPropertiesListener = function(arg)
{
   this.systemPropertiesListenerList.push(arg);
};
