function MoonPositionsDemonstratorClass()
{
}
var p = MoonPositionsDemonstratorClass.prototype = new MovieClip();
Object.registerClass("Moon Positions Demonstrator",MoonPositionsDemonstratorClass);
p.init = function()
{
   var _loc1_ = this;
   _loc1_.hackSlider(_loc1_.sunPositionSlider);
   _loc1_.hackSlider(_loc1_.moonPositionSlider);
   _loc1_.sphereMC.siderealTime = 0;
   _loc1_.sphereMC.viewerAzimuth = 200;
   _loc1_.sphereMC.latitude = _loc1_.latitudeSlider.value;
   _loc1_.sphereMC.size = 320;
   _loc1_.sphereMC.minViewerAltitude = 7;
   _loc1_.sphereMC.onMouseUpdate = function()
   {
      updateAfterEvent();
   };
   _loc1_.sphereMC.addHorizonPlaneClip("Direction Labels Light","aboveLabels","above");
   _loc1_.sphereMC.addHorizonPlaneClip("CSGradientDisk","horizonShade","above",5,{innerAlpha:0,innerColor:0,outerAlpha:0,outerColor:0});
   _loc1_.sphereMC.addObject("Stickfigure","stickfigure",{x:0,y:0,z:0.0001,system:"horizon"});
   _loc1_.sphereMC.stickfigure.setOrientationType("absolute",{x:-1,y:0,z:0,system:"horizon"},{x:0,y:0,z:1,system:"horizon"});
   _loc1_.sphereMC.addObject("ShadowMaker","shadow",{x:0,y:0,z:0,system:"horizon"},{shadowClip:"Stickfigure Shadow"});
   _loc1_.sphereMC.shadow.setOrientationType("absolute",{x:0,y:0,z:1,system:"horizon"},{x:1,y:0,z:0,system:"horizon"});
   _loc1_.sphereMC.addObject("Shadow Mask","shadowMask",{x:0,y:0,z:0,system:"horizon"});
   _loc1_.sphereMC.shadowMask.setOrientationType("absolute",{x:0,y:0,z:1,system:"horizon"},{x:1,y:0,z:0,system:"horizon"});
   _loc1_.sphereMC.shadow.instance.setMask(_loc1_.sphereMC.shadowMask.instance);
   _loc1_.sphereMC.addCircle("meridian1",{thickness:1,color:14737632,alpha:70},{dec:0,ra:0,tilt:90});
   _loc1_.sphereMC.addCircle("meridian2",{thickness:1,color:14737632,alpha:70},{dec:0,ra:90,tilt:90});
   _loc1_.sphereMC.addCircle("celestialEquator",{thickness:2,color:15259800,alpha:100},{dec:0,ra:0,tilt:0});
   _loc1_.sphereMC.addLine("ncpAxis",{thickness:2,color:2192638,alpha:100},{x:0,y:0,z:1,system:"celestial"},{x:0,y:0,z:1.2,system:"celestial"});
   _loc1_.sphereMC.addLine("scpAxis",{thickness:2,color:2192638,alpha:100},{x:0,y:0,z:-1,system:"celestial"},{x:0,y:0,z:-1.2,system:"celestial"});
   _loc1_.sphereMC.addObject("Moon Disc","moon",{ra:0,dec:0});
   _loc1_.sphereMC.addObject("Sun Disc","sun",{ra:4,dec:0,r:1.00001});
   var _loc2_ = 1;
   while(_loc2_ <= 8)
   {
      _loc1_.sphereMC.addObject("Position Dot","dot" + _loc2_,{ra:9 - _loc2_ * 3,dec:0,r:1.00005});
      _loc1_.sphereMC["dot" + _loc2_].setOrientationType("absolute");
      _loc2_ = _loc2_ + 1;
   }
   var labelR = 1;
   var labelDec = 12;
   _loc2_ = 1;
   while(_loc2_ <= 8)
   {
      _loc1_.sphereMC.addObject("Position Label","label" + _loc2_,{ra:9 - _loc2_ * 3,dec:labelDec,r:labelR},{labelText:_loc2_});
      _loc1_.sphereMC["label" + _loc2_].setOrientationType("absolute");
      _loc2_ = _loc2_ + 1;
   }
   _loc1_.sphereMC.addShadedBand("Band Disc","Band Disc","eclipticBand",{dec1:-30,dec2:30},"inner","full");
   _loc1_.sphereMC.eclipticBand.setBorderStyle(1,11579568,50);
   _loc1_.sphereMC.eclipticBand.showBorder = true;
   _loc1_.onShowPositionLabelsChanged();
   _loc1_.onShowEclipticBandChanged();
   _loc1_.onShowTimeChanged();
   _loc1_.onSunPositionChanged(null,true);
   _loc1_.onShowMoonPhaseChanged();
   _loc1_.onEnableMoonChanged();
   _loc1_.onShowPhaseOnDiscChanged();
   _loc1_.onMoonPositionChanged(null,true);
   _loc1_.updateShadow();
   _loc1_.updateTimeOfDay();
   _loc1_.updateMoonPhase();
   _loc1_.sphereMC.update();
};
p.updateTimeOfDay = function()
{
   var _loc2_ = ((6 + 3 * (this.sunPositionSlider.value - 1)) % 24 + 24) % 24;
   if(_loc2_ < 12)
   {
      var timeStr = "AM";
   }
   else
   {
      _loc2_ -= 12;
      var timeStr = "PM";
   }
   var _loc1_ = Math.floor(_loc2_);
   var _loc3_ = Math.floor(60 * (_loc2_ - _loc1_));
   if(_loc1_ == 0)
   {
      _loc1_ = 12;
   }
   if(_loc1_ < 10)
   {
      var hourStr = " " + String(_loc1_);
   }
   else
   {
      var hourStr = String(_loc1_);
   }
   if(_loc3_ < 10)
   {
      var minStr = "0" + String(_loc3_);
   }
   else
   {
      var minStr = String(_loc3_);
   }
   this.timeOfDayField.text = hourStr + ":" + minStr + " " + timeStr;
};
p.updateShadow = function()
{
   var _loc1_ = this;
   var _loc3_;
   var _loc2_;
   if(_loc1_.showSunCheckBox.getValue())
   {
      _loc3_ = {};
      _loc1_.sphereMC.sun.getPositionHorizon(_loc3_);
      _loc1_.sphereMC.shadow.instance.setSourcePosition(_loc3_);
      _loc2_ = 40 * Math.pow(1 - _loc3_.alt / 90,4);
      if(_loc2_ > 40)
      {
         _loc2_ = 40;
      }
      _loc1_.sphereMC.horizonShade.innerAlpha = _loc1_.sphereMC.horizonShade.outerAlpha = _loc2_;
      _loc1_.sphereMC.horizonShade.update();
   }
   else
   {
      _loc1_.sphereMC.shadow.instance.setSourcePosition({alt:-10,az:0});
      _loc1_.sphereMC.horizonShade.innerAlpha = _loc1_.sphereMC.horizonShade.outerAlpha = 0;
      _loc1_.sphereMC.horizonShade.update();
   }
};
p.updateMoonPhase = function()
{
   this.sphereMC.moon.instance.update();
   var phaseAngle = 15 * (this.sphereMC.sun.ra - this.sphereMC.moon.ra) + 180;
   this.phaseDiscMC.drawPhaseDisc(phaseAngle,{radius:30,lightColor:13684944,darkColor:9474192,lineThickness:0,lineColor:9474192,lineAlpha:100});
   var descriptorsList = ["New Moon","Waxing Crescent","First Quarter","Waxing Gibbous","Full Moon","Waning Gibbous","Third Quarter","Waning Crescent"];
   var _loc3_ = 5;
   var _loc2_ = 12;
   var _loc1_ = ((180 - phaseAngle) % 360 + 360) % 360;
   if(_loc1_ <= _loc2_)
   {
      var descriptorID = 0;
   }
   else if(_loc1_ <= 90 - _loc3_)
   {
      var descriptorID = 1;
   }
   else if(_loc1_ <= 90 + _loc3_)
   {
      var descriptorID = 2;
   }
   else if(_loc1_ <= 180 - _loc2_)
   {
      var descriptorID = 3;
   }
   else if(_loc1_ <= 180 + _loc2_)
   {
      var descriptorID = 4;
   }
   else if(_loc1_ <= 270 - _loc3_)
   {
      var descriptorID = 5;
   }
   else if(_loc1_ <= 270 + _loc3_)
   {
      var descriptorID = 6;
   }
   else if(_loc1_ <= 360 - _loc2_)
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
   var _loc2_ = this;
   var _loc3_ = -3 * (_loc2_.moonPositionSlider.value - 1) + 6;
   _loc2_.sphereMC.moon.setPosition({ra:_loc3_,dec:0});
   var _loc1_ = {};
   _loc2_.sphereMC.moon.getPosition(_loc1_);
   _loc1_.x = - _loc1_.x;
   _loc1_.y = - _loc1_.y;
   _loc1_.z = - _loc1_.z;
   _loc2_.sphereMC.moon.setOrientationType("absolute",_loc1_,{ra:0,dec:90});
   if(!skipUpdate)
   {
      _loc2_.sphereMC.updateObjects();
      _loc2_.updateMoonPhase();
   }
};
p.onShowPhaseOnDiscChanged = function()
{
   this.sphereMC.moon.instance.setShowPhase(this.showPhaseOnDiscCheckBox.getValue());
};
p.onShowMoonChanged = function()
{
   var _loc1_ = this;
   if(_loc1_.showMoonCheckBox.getValue())
   {
      _loc1_.sphereMC.moon.visible = true;
      _loc1_.sphereMC.updateObjects();
   }
   else
   {
      _loc1_.sphereMC.moon.visible = false;
   }
};
p.onShowMoonPhaseChanged = function()
{
   var _loc2_ = this;
   var _loc1_ = _loc2_.showMoonPhaseCheckBox.getValue();
   _loc2_.moonPhaseLabelField.textColor = !_loc1_ ? 9474192 : 0;
   _loc2_.moonPhaseField._visible = _loc1_;
   _loc2_.phaseDiscMC._visible = _loc1_;
};
p.onShowSunChanged = function()
{
   var _loc1_ = this;
   if(_loc1_.showSunCheckBox.getValue())
   {
      _loc1_.sphereMC.sun.visible = true;
      _loc1_.sphereMC.updateObjects();
   }
   else
   {
      _loc1_.sphereMC.sun.visible = false;
   }
   _loc1_.updateShadow();
};
p.onSunPositionChanged = function(notUsed, skipUpdate)
{
   var _loc1_ = this;
   var _loc2_ = -3 * (_loc1_.sunPositionSlider.value - 1) + 6;
   _loc1_.sphereMC.sun.setPosition({ra:_loc2_,dec:0,r:1.00001});
   _loc1_.sphereMC.sun.setOrientationType("absolute");
   if(!skipUpdate)
   {
      _loc1_.sphereMC.updateObjects();
      _loc1_.updateShadow();
      _loc1_.updateTimeOfDay();
      _loc1_.updateMoonPhase();
   }
};
p.onShowTimeChanged = function()
{
   var _loc1_ = this;
   if(_loc1_.showTimeCheckBox.getValue())
   {
      _loc1_.timeOfDayLabelField.textColor = 0;
      _loc1_.timeOfDayField._visible = true;
   }
   else
   {
      _loc1_.timeOfDayLabelField.textColor = 9474192;
      _loc1_.timeOfDayField._visible = false;
   }
};
p.onShowPositionLabelsChanged = function()
{
   var _loc3_ = this;
   var _loc2_ = _loc3_.showPositionLabelsCheckBox.getValue();
   var _loc1_ = 1;
   while(_loc1_ <= 8)
   {
      _loc3_.sphereMC["dot" + _loc1_].visible = _loc2_;
      _loc3_.sphereMC["label" + _loc1_].visible = _loc2_;
      _loc1_ = _loc1_ + 1;
   }
   if(_loc2_)
   {
      _loc3_.sphereMC.updateObjects();
   }
};
p.onLatitudeChanged = function()
{
   var _loc1_ = this;
   _loc1_.sphereMC.latitude = _loc1_.latitudeSlider.value;
   _loc1_.updateShadow();
};
p.onShowEclipticBandChanged = function()
{
   this.sphereMC.eclipticBand.visible = this.showEclipticBandCheckBox.getValue();
};
p.getSunDiscEnabled = function()
{
   return this.sunPositionSlider.userEnabled;
};
p.getMoonDiscEnabled = function()
{
   return this.moonPositionSlider.userEnabled;
};
p.hackSlider = function(sliderMC)
{
   var _loc1_ = this;
   var _loc2_ = sliderMC;
   _loc2_.grabberMC.onRelease = _loc2_.grabberMC.onReleaseOutside = function()
   {
      var _loc1_ = this;
      if(_loc1_._parent.userEnabled)
      {
         _loc1_.doTween();
      }
      delete _loc1_.onMouseMove;
   };
   _loc2_.grabberMC.doTween = function()
   {
      var _loc1_ = this;
      _loc1_.animStartValue = _loc1_._parent.controller.value;
      _loc1_.animEndValue = Math.round(_loc1_._parent.controller.value);
      _loc1_.animStartTimer = getTimer();
      _loc1_.animTime = 200;
      _loc1_._parent.userEnabled = false;
      _loc1_._parent.update();
      _loc1_.onEnterFrame = _loc1_.onEnterFrameFunc;
   };
   _loc2_.grabberMC.onMouseMoveFunc = function()
   {
      var _loc3_ = this;
      var _loc1_ = _loc3_._parent.controller;
      var _loc2_ = _loc1_._maxP - _loc1_._minP;
      var p = _loc1_._minP + ((_loc3_._parent._xmouse - _loc3_.xOffset - _loc1_._minP) % _loc2_ + _loc2_) % _loc2_;
      var vObj = _loc1_.getValueObjectFromValue(_loc1_.getValueFromParameter(p));
      if(vObj.value != _loc1_.value)
      {
         _loc3_._parent.setValueByValueObject(vObj,true);
      }
      updateAfterEvent();
   };
   _loc2_.grabberMC.onEnterFrameFunc = function()
   {
      var _loc1_ = this;
      var _loc2_ = (getTimer() - _loc1_.animStartTimer) / _loc1_.animTime;
      var _loc3_;
      if(_loc2_ >= 1)
      {
         _loc1_._parent.setValue(_loc1_.animEndValue,true);
         _loc1_._parent.userEnabled = true;
         _loc1_._parent.update();
         delete _loc1_.onEnterFrame;
      }
      else
      {
         _loc3_ = _loc1_.animStartValue + (_loc1_.animEndValue - _loc1_.animStartValue) * Math.pow(_loc2_,0.3);
         _loc1_._parent.setValue(_loc3_,true);
      }
   };
   _loc2_.grabberMC.onKeyDownFunc = function()
   {
      var _loc1_ = this;
      var c = _loc1_._parent.controller;
      if(Key.isDown(37))
      {
         _loc1_._parent.incrementValue(-1,true);
      }
      else if(Key.isDown(39))
      {
         _loc1_._parent.incrementValue(1,true);
      }
   };
   delete _loc2_.barMC.onEnterFrameFunc;
   _loc2_.incrementValue = function(ticks, callChangeHandler)
   {
      var _loc1_ = this;
      var _loc2_ = ticks;
      if(typeof _loc2_ == "number" && !isNaN(_loc2_) && isFinite(_loc2_))
      {
         if(_loc2_ < 0 && _loc1_.controller.value == 1)
         {
            _loc1_.controller.value = 8;
         }
         else if(_loc2_ > 0 && _loc1_.controller.value == 8)
         {
            _loc1_.controller.value = 1;
         }
         else if(_loc2_ < 0 && _loc1_.controller.value > 1)
         {
            _loc1_.controller.value = Math.round(_loc1_.controller.value - 1);
         }
         else if(_loc2_ > 0 && _loc1_.controller.value < 8)
         {
            _loc1_.controller.value = Math.round(_loc1_.controller.value + 1);
         }
         else
         {
            _loc1_.controller.value = Math.round(_loc1_.controller.value);
         }
      }
      _loc1_.updateSynchronization();
      if(callChangeHandler)
      {
         _loc1_._parent[_loc1_.changeHandler](_loc1_.controller.value);
      }
   };
   _loc2_.updateSynchronization = function()
   {
      var _loc1_ = this;
      _loc1_.grabberMC._x = _loc1_.controller.parameter;
      _loc1_.valueField.text = Math.round(_loc1_.controller.value);
   };
   _loc2_.maxChars = 1;
   _loc2_.minValue = 0.51;
   _loc2_.maxValue = 8.49;
   _loc2_.precision = 3;
   _loc2_.fieldDisabledBackgroundColor = 16777215;
   _loc2_.fieldDisabledTextColor = 0;
   _loc2_.update();
};
