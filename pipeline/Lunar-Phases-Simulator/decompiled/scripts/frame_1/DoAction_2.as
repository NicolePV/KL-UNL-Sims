function onLangChanged(lang)
{
   var _loc3_ = 121;
   var _loc2_ = 718.5;
   var _loc5_;
   var _loc4_;
   if(lang.langCode == "nl")
   {
      _loc5_ = 125;
      animationButton.setSize(_loc5_,27);
      animationButton._x = _loc3_ - _loc5_ / 2;
      _loc4_ = 148;
      phaseComboBox.setSize(_loc4_,17);
      phaseComboBox._x = _loc2_ - _loc4_ / 2;
      showAngleCheck.setSize(100,13);
      showLunarLandmarkCheck.setSize(200,13);
      showTimeTicksCheck.setSize(100,13);
      showTimeTicksCheck._x = showLunarLandmarkCheck._x = showAngleCheck._x = 395;
      showAngleCheck._y = 572;
      showLunarLandmarkCheck._y = 599;
      showTimeTicksCheck._y = 626;
      showMoonPhaseButton.setSize(67,20);
      showHorizonDiagramButton.setSize(67,20);
      showMoonPhaseButton._x = showHorizonDiagramButton._x = 758;
      timeLabelField._x = 614;
      timeLabelField._y = 604;
      timeField._x = 750;
   }
   else if(lang.langCode == "el")
   {
      _loc5_ = 125;
      animationButton.setSize(_loc5_,27);
      animationButton._x = _loc3_ - _loc5_ / 2;
      _loc4_ = 148;
      phaseComboBox.setSize(_loc4_,17);
      phaseComboBox._x = _loc2_ - _loc4_ / 2;
      showAngleCheck.setSize(70,13);
      showLunarLandmarkCheck.setSize(155,13);
      showTimeTicksCheck.setSize(175,13);
      showTimeTicksCheck._x = showLunarLandmarkCheck._x = showAngleCheck._x = 419;
      showAngleCheck._y = 585;
      showLunarLandmarkCheck._y = 612;
      showTimeTicksCheck._y = 639;
      showMoonPhaseButton.setSize(80,20);
      showHorizonDiagramButton.setSize(80,20);
      showMoonPhaseButton._x = showHorizonDiagramButton._x = 745;
      timeLabelField._x = 610;
      timeLabelField._y = 621;
      timeField._x = 766;
   }
   else if(lang.langCode == "tr")
   {
      _loc5_ = 155;
      animationButton.setSize(_loc5_,27);
      animationButton._x = _loc3_ - _loc5_ / 2;
      _loc4_ = 166;
      phaseComboBox.setSize(_loc4_,17);
      phaseComboBox._x = _loc2_ - _loc4_ / 2;
      showAngleCheck.setSize(100,13);
      showLunarLandmarkCheck.setSize(155,13);
      showTimeTicksCheck.setSize(177,13);
      showTimeTicksCheck._x = showLunarLandmarkCheck._x = showAngleCheck._x = 407;
      showAngleCheck._y = 572;
      showLunarLandmarkCheck._y = 599;
      showTimeTicksCheck._y = 626;
      showMoonPhaseButton.setSize(67,20);
      showHorizonDiagramButton.setSize(67,20);
      showMoonPhaseButton._x = showHorizonDiagramButton._x = 758;
      timeLabelField._x = 612;
      timeLabelField._y = 621;
      timeField._x = 760;
   }
   else if(lang.langCode == "sl")
   {
      _loc5_ = 140;
      animationButton.setSize(_loc5_,27);
      animationButton._x = _loc3_ - _loc5_ / 2;
      _loc4_ = 148;
      phaseComboBox.setSize(_loc4_,17);
      phaseComboBox._x = _loc2_ - _loc4_ / 2;
      showAngleCheck.setSize(100,13);
      showLunarLandmarkCheck.setSize(165,13);
      showTimeTicksCheck.setSize(150,13);
      showTimeTicksCheck._x = showLunarLandmarkCheck._x = showAngleCheck._x = 412;
      showAngleCheck._y = 572;
      showLunarLandmarkCheck._y = 599;
      showTimeTicksCheck._y = 626;
      showMoonPhaseButton.setSize(67,20);
      showHorizonDiagramButton.setSize(67,20);
      showMoonPhaseButton._x = showHorizonDiagramButton._x = 758;
      timeLabelField._x = 616;
      timeLabelField._y = 621;
      timeField._x = 760;
   }
   else
   {
      _loc5_ = 125;
      animationButton.setSize(_loc5_,27);
      animationButton._x = _loc3_ - _loc5_ / 2;
      _loc4_ = 148;
      phaseComboBox.setSize(_loc4_,17);
      phaseComboBox._x = _loc2_ - _loc4_ / 2;
      showAngleCheck.setSize(100,13);
      showLunarLandmarkCheck.setSize(155,13);
      showTimeTicksCheck.setSize(150,13);
      showTimeTicksCheck._x = showLunarLandmarkCheck._x = showAngleCheck._x = 417;
      showAngleCheck._y = 572;
      showLunarLandmarkCheck._y = 599;
      showTimeTicksCheck._y = 626;
      showMoonPhaseButton.setSize(67,20);
      showHorizonDiagramButton.setSize(67,20);
      showMoonPhaseButton._x = showHorizonDiagramButton._x = 758;
      timeLabelField._x = 616;
      timeLabelField._y = 621;
      timeField._x = 754;
   }
   selectedLanguage = lang;
   use24HourClock = lang.use24HourClock;
   titleBar.title = lang.title;
   titleBar.resetLabel = lang.reset;
   titleBar.helpLabel = lang.help;
   titleBar.aboutLabel = lang.about;
   titleBar.update();
   titleBar.helpWindow.contentMC.setText(lang.helpPanelText);
   titleBar.helpWindow.setTitle(lang.helpTitle);
   titleBar.aboutWindow.setTitle(lang.aboutTitle);
   geometryDiagram._sunRays.sunlightField.text = lang.sunlight;
   geometryDiagram._earthShadow._timeTicks.sunriseField.text = lang.sunrise;
   geometryDiagram._earthShadow._timeTicks.noonField.text = lang.noon;
   geometryDiagram._earthShadow._timeTicks.sunsetField.text = lang.sunset;
   geometryDiagram._earthShadow._timeTicks.midnightField.text = lang.midnight;
   animTimeControlsPanel.title = lang.animTimeControlsPanelTitle;
   animTimeControlsPanel.update();
   animationRateField.text = lang.animationRate + ":";
   animDayField.text = lang.animDay + ":";
   animHourField.text = lang.animHour + ":";
   animMinuteField.text = lang.animMinute + ":";
   incrementAnimationField.text = lang.incrementAnimation + ":";
   updateAnimationButtonText();
   diagramOptionsPanel.title = lang.diagramOptionsPanelTitle;
   diagramOptionsPanel.update();
   showField.text = lang.show;
   showAngleCheck.setLabel(" " + lang.showAngle);
   showLunarLandmarkCheck.setLabel(" " + lang.showLunarLandmark);
   showTimeTicksCheck.setLabel(" " + lang.showTimeTickmarks);
   horizonDiagramPanel.title = lang.horizonDiagramPanelTitle;
   horizonDiagramPanel.update();
   sphere.directionLabels.northField.text = lang.northLetter;
   sphere.directionLabels.southField.text = lang.southLetter;
   sphere.directionLabels.eastField.text = lang.eastLetter;
   sphere.directionLabels.westField.text = lang.westLetter;
   timeLabelField.htmlText = lang.observersLocalTime + ": ";
   updateShowHorizonDiagramButtonText();
   moonPhasePanel.title = lang.moonPhasePanelTitle;
   moonPhasePanel.update();
   phaseComboBox.replaceItemAt(0,lang.newMoon,0);
   phaseComboBox.replaceItemAt(1,lang.waxingCrescent,45);
   phaseComboBox.replaceItemAt(2,lang.firstQuarter,90);
   phaseComboBox.replaceItemAt(3,lang.waxingGibbous,135);
   phaseComboBox.replaceItemAt(4,lang.fullMoon,180);
   phaseComboBox.replaceItemAt(5,lang.waningGibbous,225);
   phaseComboBox.replaceItemAt(6,lang.thirdQuarter,270);
   phaseComboBox.replaceItemAt(7,lang.waningCrescent,315);
   phaseComboBox.topLabel = phaseComboBox.getSelectedItem();
   phaseComboBox.fLabel_mc.drawItem(phaseComboBox.topLabel);
   updateShowMoonPhaseButtonText();
   updatePercentIlluminated();
   updateTimeSinceNew();
   timeSinceNewLabelField.text = lang.timeSinceNewMoonLabel + ":";
   updateLocalTime();
}
function onReset()
{
   stopAnimation();
   geometryDiagram.setTime(12);
   geometryDiagram.setPhase(0);
   animationSpeedSlider.value = 0.0003;
   moonPhaseDiagram._visible = false;
   toggleMoonPhaseVisible();
   sphere._visible = false;
   toggleHorizonDiagramVisible();
   showAngleCheck.setValue(false);
   showLunarLandmarkCheck.setValue(false);
   showTimeTicksCheck.setValue(false);
   timeAndPhaseChanged();
   sphere.setThetaAndPhi(90,17);
}
function toggleHorizonDiagramVisible()
{
   var _loc1_ = !sphere._visible;
   timeLabelField._visible = _loc1_;
   timeField._visible = _loc1_;
   sphere._visible = _loc1_;
   sphereBackgroundMC._visible = _loc1_;
   updateShowHorizonDiagramButtonText();
}
function updateShowHorizonDiagramButtonText()
{
   if(sphere._visible)
   {
      showHorizonDiagramButton.setLabel(this.selectedLanguage.hideButtonText);
   }
   else
   {
      showHorizonDiagramButton.setLabel(this.selectedLanguage.showButtonText);
   }
}
function toggleMoonPhaseVisible()
{
   var _loc1_ = !moonPhaseDiagram._visible;
   phaseComboBox._visible = _loc1_;
   percentIlluminatedField._visible = _loc1_;
   moonPhaseDiagram._visible = _loc1_;
   timeSinceNewLabelField._visible = _loc1_;
   timeSinceNewField._visible = _loc1_;
   updateShowMoonPhaseButtonText();
}
function updateShowMoonPhaseButtonText()
{
   if(moonPhaseDiagram._visible)
   {
      showMoonPhaseButton.setLabel(this.selectedLanguage.hideButtonText);
   }
   else
   {
      showMoonPhaseButton.setLabel(this.selectedLanguage.showButtonText);
   }
}
function changeShowLunarLandmark()
{
   var _loc1_ = showLunarLandmarkCheck.getValue();
   geometryDiagram.setShowLunarLandmark(_loc1_);
   moonPhaseDiagram.lunarLandmarkMC._visible = _loc1_;
}
function setSkyColor()
{
   var _loc1_ = sphere.sun.alt / 10 + 0.5;
   if(_loc1_ > 1)
   {
      _loc1_ = 1;
   }
   else if(_loc1_ < 0)
   {
      _loc1_ = 0;
   }
   sphere.backSky.innerAlpha = _loc1_ * backInnerAlphaRange + nightBackInnerAlpha;
   sphere.backSky.outerAlpha = _loc1_ * backOuterAlphaRange + nightBackOuterAlpha;
   sphere.backSky.update();
   sphere.frontSky.innerAlpha = _loc1_ * frontInnerAlphaRange + nightFrontInnerAlpha;
   sphere.frontSky.outerAlpha = _loc1_ * frontOuterAlphaRange + nightFrontOuterAlpha;
   sphere.frontSky.update();
}
function mod(n, m)
{
   if(n < 0)
   {
      return n % m + m;
   }
   return n % m;
}
function timeAndPhaseChanged()
{
   var _loc1_ = geometryDiagram.phase;
   moonPhaseDiagram.setPhase(_loc1_);
   updatePercentIlluminated();
   updateTimeSinceNew();
   if(_loc1_ <= fTol)
   {
      phaseComboBox.setSelectedIndex(0,false);
   }
   else if(_loc1_ <= 90 - qTol)
   {
      phaseComboBox.setSelectedIndex(1,false);
   }
   else if(_loc1_ <= 90 + qTol)
   {
      phaseComboBox.setSelectedIndex(2,false);
   }
   else if(_loc1_ <= 180 - fTol)
   {
      phaseComboBox.setSelectedIndex(3,false);
   }
   else if(_loc1_ <= 180 + fTol)
   {
      phaseComboBox.setSelectedIndex(4,false);
   }
   else if(_loc1_ <= 270 - qTol)
   {
      phaseComboBox.setSelectedIndex(5,false);
   }
   else if(_loc1_ <= 270 + qTol)
   {
      phaseComboBox.setSelectedIndex(6,false);
   }
   else if(_loc1_ <= 360 - fTol)
   {
      phaseComboBox.setSelectedIndex(7,false);
   }
   else
   {
      phaseComboBox.setSelectedIndex(0,false);
   }
   var _loc2_ = sunRA();
   sphere.sun.ra = _loc2_;
   sphere.sun.setOrientationType("absolute");
   sphere.moon.ra = _loc2_ + _loc1_ * 0.06666666666666667;
   sphere.moon.setOrientationType("absolute");
   sphere.updateObjects();
   updateElongationAngle();
   updateLocalTime();
   setSkyColor();
}
function phaseChanged()
{
   var _loc1_ = geometryDiagram.phase;
   moonPhaseDiagram.setPhase(_loc1_);
   updatePercentIlluminated();
   updateTimeSinceNew();
   if(_loc1_ <= fTol)
   {
      phaseComboBox.setSelectedIndex(0,false);
   }
   else if(_loc1_ <= 90 - qTol)
   {
      phaseComboBox.setSelectedIndex(1,false);
   }
   else if(_loc1_ <= 90 + qTol)
   {
      phaseComboBox.setSelectedIndex(2,false);
   }
   else if(_loc1_ <= 180 - fTol)
   {
      phaseComboBox.setSelectedIndex(3,false);
   }
   else if(_loc1_ <= 180 + fTol)
   {
      phaseComboBox.setSelectedIndex(4,false);
   }
   else if(_loc1_ <= 270 - qTol)
   {
      phaseComboBox.setSelectedIndex(5,false);
   }
   else if(_loc1_ <= 270 + qTol)
   {
      phaseComboBox.setSelectedIndex(6,false);
   }
   else if(_loc1_ <= 360 - fTol)
   {
      phaseComboBox.setSelectedIndex(7,false);
   }
   else
   {
      phaseComboBox.setSelectedIndex(0,false);
   }
   sphere.moon.ra = sunRA() + geometryDiagram.phase * 0.06666666666666667;
   sphere.moon.setOrientationType("absolute");
   sphere.updateObjects();
   updateElongationAngle();
}
function timeChanged()
{
   var _loc1_ = sunRA();
   sphere.sun.ra = _loc1_;
   sphere.sun.setOrientationType("absolute");
   sphere.moon.ra = _loc1_ + geometryDiagram.phase * 0.06666666666666667;
   sphere.moon.setOrientationType("absolute");
   sphere.updateObjects();
   updateElongationAngle();
   updateLocalTime();
   setSkyColor();
}
function sunRA()
{
   return 12 - geometryDiagram.time;
}
function toggleAnimation()
{
   if(onEnterFrame == onEnterFrameFunc)
   {
      stopAnimation();
   }
   else
   {
      startAnimation();
   }
}
function startAnimation()
{
   comboBlocker._visible = true;
   onEnterFrame = onEnterFrameFunc;
   timeLast = getTimer();
   updateAnimationButtonText();
}
function stopAnimation()
{
   comboBlocker._visible = false;
   delete onEnterFrame;
   updateAnimationButtonText();
}
function updateAnimationButtonText()
{
   if(onEnterFrame == onEnterFrameFunc)
   {
      animationButton.setLabel(selectedLanguage.pauseAnimation);
   }
   else
   {
      animationButton.setLabel(selectedLanguage.startAnimation);
   }
}
function onEnterFrameFunc()
{
   var _loc2_ = getTimer();
   var _loc1_ = animationSpeedSlider.value * (_loc2_ - timeLast);
   geometryDiagram.time += _loc1_ * 24;
   geometryDiagram.phase += _loc1_ / synodicPeriod * 360;
   timeAndPhaseChanged();
   timeLast = _loc2_;
}
function goDayForward()
{
   geometryDiagram.time += 24;
   geometryDiagram.phase += 360 / synodicPeriod;
   timeAndPhaseChanged();
}
function goDayBack()
{
   geometryDiagram.time -= 24;
   geometryDiagram.phase -= 360 / synodicPeriod;
   timeAndPhaseChanged();
}
function goHourForward()
{
   geometryDiagram.time += 1;
   geometryDiagram.phase += 360 / (24 * synodicPeriod);
   timeAndPhaseChanged();
}
function goHourBack()
{
   geometryDiagram.time -= 1;
   geometryDiagram.phase -= 360 / (24 * synodicPeriod);
   timeAndPhaseChanged();
}
function goMinuteForward()
{
   geometryDiagram.time += 0.016666666666666666;
   geometryDiagram.phase += 360 / (1440 * synodicPeriod);
   timeAndPhaseChanged();
}
function goMinuteBack()
{
   geometryDiagram.time -= 0.016666666666666666;
   geometryDiagram.phase -= 360 / (1440 * synodicPeriod);
   timeAndPhaseChanged();
}
function changeShowTimeTicks()
{
   geometryDiagram.showTimeTicks = showTimeTicksCheck.getValue();
}
function phaseComboBoxChanged()
{
   if(onEnterFrame == undefined)
   {
      geometryDiagram.phase = phaseComboBox.getSelectedItem().data;
      moonPhaseDiagram.setPhase(geometryDiagram.phase);
      updatePercentIlluminated();
      updateTimeSinceNew();
      sphere.moon.ra = sunRA() + geometryDiagram.phase * 0.06666666666666667;
      sphere.moon.setOrientationType("absolute");
      sphere.updateObjects();
      updateElongationAngle();
   }
}
function updateLocalTime()
{
   var _loc1_ = ((12 - sunRA()) % 24 + 24) % 24;
   var _loc2_;
   var _loc4_;
   var _loc3_;
   if(use24HourClock)
   {
      _loc2_ = Math.floor(_loc1_);
      _loc4_ = Math.floor(60 * (_loc1_ % 1));
      if(_loc2_ < 10)
      {
         timeString = String(_loc2_);
      }
      else
      {
         timeString = String(_loc2_);
      }
      if(_loc4_ < 10)
      {
         timeString += ":0" + _loc4_ + "h";
      }
      else
      {
         timeString += ":" + _loc4_ + "h";
      }
   }
   else
   {
      if(_loc1_ < 12)
      {
         _loc3_ = selectedLanguage.am;
      }
      else
      {
         _loc3_ = selectedLanguage.pm;
      }
      _loc2_ = Math.floor(_loc1_) % 12;
      if(_loc2_ == 0)
      {
         _loc2_ = 12;
      }
      _loc4_ = Math.floor(60 * (_loc1_ % 1));
      if(_loc2_ < 10)
      {
         timeString = String(_loc2_);
      }
      else
      {
         timeString = String(_loc2_);
      }
      if(_loc4_ < 10)
      {
         timeString += ":0" + _loc4_ + " " + _loc3_;
      }
      else
      {
         timeString += ":" + _loc4_ + " " + _loc3_;
      }
   }
}
function updatePercentIlluminated()
{
   var _loc2_ = Math.round(500 * (1 - Math.cos(geometryDiagram.phase * 0.017453292519943295)));
   if(_loc2_ % 10 == 0)
   {
      percentIlluminated = _loc2_ / 10 + ".0% " + this.selectedLanguage.illuminated;
   }
   else
   {
      percentIlluminated = _loc2_ / 10 + "% " + this.selectedLanguage.illuminated;
   }
}
function updateTimeSinceNew()
{
   var _loc2_ = synodicPeriod * (mod(geometryDiagram.phase,360) / 360);
   var _loc3_ = (_loc2_ - Math.floor(_loc2_)) * 24;
   var _loc4_ = (_loc3_ - Math.floor(_loc3_)) * 60;
   timeSinceNew = "";
   if(_loc2_ >= 1 && _loc2_ < 2)
   {
      timeSinceNew = "1 " + this.selectedLanguage.daySingular + ", ";
   }
   else if(_loc2_ >= 2)
   {
      timeSinceNew = Math.floor(_loc2_) + " " + this.selectedLanguage.daysPlural + ", ";
   }
   if(_loc3_ >= 1 && _loc3_ < 2)
   {
      timeSinceNew += "1 " + this.selectedLanguage.hourSingular;
   }
   else
   {
      timeSinceNew += Math.floor(_loc3_) + " " + this.selectedLanguage.hoursPlural;
   }
}
function changeShowAngle()
{
   if(showAngleCheck.getValue())
   {
      sphere.stickman.visible = false;
      sphere.moonLine.visible = true;
      sphere.sunLine.visible = true;
      geometryDiagram.angleLabelMC._visible = true;
      updateElongationAngle();
   }
   else
   {
      sphere.stickman.visible = true;
      sphere.updateObjects();
      sphere.elongationArc.visible = false;
      sphere.lowerPlane.instance.maskMC.clear();
      sphere.upperPlane.instance.maskMC.clear();
      sphere.moonLine.visible = false;
      sphere.sunLine.visible = false;
      geometryDiagram.maskMC.clear();
      geometryDiagram.linesMC.removeMovieClip();
      geometryDiagram.angleLabelMC._visible = false;
   }
}
function updateElongationAngle()
{
   if(!showAngleCheck.getValue())
   {
      return undefined;
   }
   var _loc14_;
   if(sphere.moon._p.x == sphere.sun._p.x && sphere.moon._p.y == sphere.sun._p.y)
   {
      sphere.elongationArc.visible = false;
   }
   else
   {
      sphere.elongationArc.setArcPoints("moon","sun");
      _loc14_ = sphere.elongationArc.getTilt();
      if(_loc14_ != 0 && _loc14_ != 180)
      {
         sphere.elongationArc.setTilt(180);
      }
      sphere.elongationArc.visible = true;
   }
   var _loc9_ = {};
   sphere.moon.getPosition(_loc9_);
   sphere.moonLine.setHeadPoint(_loc9_);
   sphere.sun.getPosition(_loc9_);
   sphere.sunLine.setHeadPoint(_loc9_);
   sphere.updateLines();
   var _loc2_ = geometryDiagram._orbitRadius;
   var _loc5_ = - Math.atan2(geometryDiagram._moon._y,geometryDiagram._moon._x);
   var _loc6_ = geometryDiagram.maskMC;
   _loc6_.clear();
   _loc6_.beginFill(16711680,100);
   var _loc8_ = geometryDiagram.createEmptyMovieClip("linesMC",8);
   _loc8_.lineStyle(2,16768868,100);
   _loc8_.moveTo(- _loc2_,0);
   _loc8_.lineTo(0,0);
   _loc8_.lineTo(geometryDiagram._moon._x,geometryDiagram._moon._y);
   var _loc10_ = ((180 - _loc5_ * 180 / 3.141592653589793) % 360 + 360) % 360;
   if(_loc10_ > 180)
   {
      _loc10_ = 360 - _loc10_;
   }
   geometryDiagram.angleLabelMC.labelField.text = _loc10_.toFixed(1) + "°";
   var _loc15_;
   if(_loc5_ > 0)
   {
      _loc8_.drawArc(0,0,_loc2_,_loc5_,3.141592653589793);
      _loc6_.moveTo(0,0);
      _loc6_.lineTo(geometryDiagram._moon._x,geometryDiagram._moon._y);
      _loc6_.drawArc(0,0,_loc2_,_loc5_,3.141592653589793);
      _loc6_.lineTo(0,0);
      _loc15_ = 23 - 7 * Math.cos(_loc5_);
      geometryDiagram.angleLabelMC._x = (_loc15_ + _loc2_) * Math.cos(1.5707963267948966 + _loc5_ / 2);
      geometryDiagram.angleLabelMC._y = (- (_loc15_ + _loc2_)) * Math.sin(1.5707963267948966 + _loc5_ / 2);
   }
   else
   {
      _loc8_.drawArc(0,0,_loc2_,3.141592653589793,_loc5_);
      _loc6_.moveTo(0,0);
      _loc6_.lineTo(- _loc2_,0);
      _loc6_.drawArc(0,0,_loc2_,3.141592653589793,_loc5_);
      _loc6_.lineTo(0,0);
      _loc15_ = 23 - 7 * Math.cos(_loc5_);
      geometryDiagram.angleLabelMC._x = (_loc15_ + _loc2_) * Math.cos(1.5707963267948966 - _loc5_ / 2);
      geometryDiagram.angleLabelMC._y = (_loc15_ + _loc2_) * Math.sin(1.5707963267948966 - _loc5_ / 2);
   }
   _loc6_.endFill();
   var _loc11_ = sunRA();
   var _loc13_ = _loc11_ + geometryDiagram.phase * 0.06666666666666667;
   var _loc1_;
   var _loc7_;
   if(((_loc11_ - _loc13_) % 24 + 24) % 24 < 12)
   {
      _loc1_ = _loc13_;
      _loc7_ = _loc11_;
   }
   else
   {
      _loc1_ = _loc11_;
      _loc7_ = _loc13_;
   }
   _loc1_ = (_loc1_ % 24 + 24) % 24;
   _loc7_ = (_loc7_ % 24 + 24) % 24;
   _loc1_ *= 0.2617993877991494;
   _loc7_ *= 0.2617993877991494;
   var _loc12_;
   if(_loc1_ < 1.5707963267948966 || _loc1_ > 4.71238898038469)
   {
      _loc12_ = true;
   }
   else
   {
      _loc12_ = false;
   }
   _loc2_ = 100;
   var _loc3_ = sphere.lowerPlane.instance.maskMC;
   var _loc4_ = sphere.upperPlane.instance.maskMC;
   _loc3_.clear();
   _loc3_.lineStyle(1,16711680,100);
   _loc3_.beginFill(16711680,80);
   _loc4_.clear();
   _loc4_.lineStyle(1,16711680,100);
   _loc4_.beginFill(16711680,80);
   if(_loc7_ < 1.5707963267948966 || _loc7_ > 4.71238898038469)
   {
      if(_loc12_)
      {
         _loc4_.moveTo(0,0);
         _loc4_.lineTo(_loc2_ * Math.cos(_loc1_),(- _loc2_) * Math.sin(_loc1_));
         _loc4_.drawArc(0,0,_loc2_,_loc1_,_loc7_);
         _loc4_.lineTo(0,0);
      }
      else
      {
         _loc3_.moveTo(0,0);
         _loc3_.lineTo(_loc2_ * Math.cos(_loc1_),(- _loc2_) * Math.sin(_loc1_));
         _loc3_.drawArc(0,0,_loc2_,_loc1_,4.71238898038469);
         _loc3_.lineTo(0,0);
         _loc4_.moveTo(0,0);
         _loc4_.lineTo(0,_loc2_);
         _loc4_.drawArc(0,0,_loc2_,4.71238898038469,_loc7_);
         _loc4_.lineTo(0,0);
      }
   }
   else if(_loc12_)
   {
      _loc4_.moveTo(0,0);
      _loc4_.lineTo(_loc2_ * Math.cos(_loc1_),(- _loc2_) * Math.sin(_loc1_));
      _loc4_.drawArc(0,0,_loc2_,_loc1_,1.5707963267948966);
      _loc4_.lineTo(0,0);
      _loc3_.moveTo(0,0);
      _loc3_.lineTo(0,- _loc2_);
      _loc3_.drawArc(0,0,_loc2_,1.5707963267948966,_loc7_);
      _loc3_.lineTo(0,0);
   }
   else
   {
      _loc3_.moveTo(0,0);
      _loc3_.lineTo(_loc2_ * Math.cos(_loc1_),(- _loc2_) * Math.sin(_loc1_));
      _loc3_.drawArc(0,0,_loc2_,_loc1_,_loc7_);
      _loc3_.lineTo(0,0);
   }
   _loc3_.endFill();
   _loc4_.endFill();
}
function init()
{
   geometryDiagram.attachMovie("Equatorial Plane Disc","discMC",6);
   geometryDiagram.createEmptyMovieClip("maskMC",7);
   geometryDiagram.discMC.setMask(geometryDiagram.maskMC);
   geometryDiagram.discMC._yscale = geometryDiagram.discMC._xscale = geometryDiagram._orbitRadius;
   sphere.siderealTime = 0;
   sphere.showUnder = true;
   sphere.minViewerAltitude = 10;
   sphere.size = 200;
   sphere.addObject("Equatorial Plane Disc","upperPlane",{x:0,y:0,z:0.001,system:"horizon"});
   sphere.upperPlane.setOrientationType("absolute",{ra:0,dec:90},{ra:6,dec:0});
   sphere.addObject("Equatorial Plane Disc","lowerPlane",{x:0,y:0,z:-0.001,system:"horizon"});
   sphere.lowerPlane.setOrientationType("absolute",{ra:0,dec:90},{ra:6,dec:0});
   mc = sphere.upperPlane.instance.createEmptyMovieClip("maskMC",1);
   sphere.upperPlane.instance.fullDiscMC.setMask(mc);
   mc = sphere.lowerPlane.instance.createEmptyMovieClip("maskMC",1);
   sphere.lowerPlane.instance.fullDiscMC.setMask(mc);
   sphere.addObject("Stickman","stickman",{alt:0,az:0,r:0});
   sphere.stickman.setOrientationType("skewed",{alt:90,az:0});
   sphere.celestialBowl.removeMovieClip();
   sphere.addHorizonPlaneClip("direction labels light","directionLabels");
   sphere.addObject("MoonSymbol","moon",{ra:0,dec:0});
   sphere.addObject("SunSymbol","sun",{ra:0,dec:0});
   sphere.addShadingClip("CSGradientDisk","blackBackgroundAbove","back","outer","above",{innerColor:0,outerColor:0,innerAlpha:100,outerAlpha:100});
   sphere.addShadingClip("CSGradientDisk","blackBackgroundBelow","back","outer","below",{innerColor:0,outerColor:0,innerAlpha:100,outerAlpha:100});
   sphere.addShadingClip("CSGradientDisk","belowSky1","back","outer","below",{innerColor:16777215,outerColor:16777215,innerAlpha:35,outerAlpha:35});
   sphere.addShadingClip("CSGradientDisk","belowSky2","front","outer","below",{innerColor:0,outerColor:0,innerAlpha:55,outerAlpha:35});
   sphere.addShadingClip("CSGradientDisk","frontSky","front","inner","above",{innerColor:8702975,outerColor:8702975});
   sphere.addShadingClip("CSGradientDisk","backSky","back","outer","above",{innerColor:8702975,outerColor:8702975});
   sphere.addLine("sunLine",{thickness:2,color:16768868,alpha:100},{system:"celestial",x:0,y:0,z:1},{system:"celestial",x:0,y:0,z:0});
   sphere.addLine("moonLine",{thickness:2,color:16768868,alpha:100},{system:"celestial",x:0,y:0,z:1},{system:"celestial",x:0,y:0,z:0});
   sphere.addCircle("elongationArc",{thickness:2,color:16768868,alpha:100},{ra:0,dec:0,tilt:0},50);
   sphere.addCircle("meridian1",{thickness:1,color:15658734,alpha:50},{az:0,alt:0,tilt:90});
   sphere.addCircle("meridian2",{thickness:1,color:15658734,alpha:50},{az:90,alt:0,tilt:90});
   sphere.addCircle("celestialEquator",{thickness:0,color:16777215,alpha:100},{ra:0,dec:0,tilt:0});
   sphere.onMouseUpdate = function()
   {
      updateAfterEvent();
   };
   var _loc1_;
   if(lang != undefined)
   {
      _loc1_ = 0;
      while(_loc1_ < languages.length)
      {
         if(languages[_loc1_].langCode == lang)
         {
            titleBar.selectLanguage(languages[_loc1_]);
            break;
         }
         _loc1_ = _loc1_ + 1;
      }
      if(_loc1_ >= languages.length)
      {
         titleBar.selectLanguage(languages[0]);
      }
   }
   else
   {
      titleBar.selectLanguage(languages[0]);
   }
}
synodicPeriod = 29.5;
selectedLanguage = null;
use24HourClock = false;
dayBackInnerAlpha = 100;
dayBackOuterAlpha = 80;
nightBackInnerAlpha = 30;
nightBackOuterAlpha = 20;
backInnerAlphaRange = dayBackInnerAlpha - nightBackInnerAlpha;
backOuterAlphaRange = dayBackOuterAlpha - nightBackOuterAlpha;
dayFrontInnerAlpha = 10;
dayFrontOuterAlpha = 40;
nightFrontInnerAlpha = 0;
nightFrontOuterAlpha = 15;
frontInnerAlphaRange = dayFrontInnerAlpha - nightFrontInnerAlpha;
frontOuterAlphaRange = dayFrontOuterAlpha - nightFrontOuterAlpha;
qTol = 5;
fTol = 12;
init();
onReset();
