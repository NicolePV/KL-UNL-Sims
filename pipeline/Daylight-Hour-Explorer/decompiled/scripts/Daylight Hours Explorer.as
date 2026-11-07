function DaylightHoursExplorerClass()
{
}
var p = DaylightHoursExplorerClass.prototype = new MovieClip();
Object.registerClass("Daylight Hours Explorer",DaylightHoursExplorerClass);
p.init = function()
{
   this.sphereMC.size = 170;
   this.sphereMC.sortObjects = true;
   this.sphereMC.celestialBowl.removeMovieClip();
   this.sphereMC.addCircle("equator",{thickness:1,color:3182640,alpha:70},{ra:0,dec:0,tilt:0});
   this.sphereMC.addCircle("dayArc",{thickness:2,color:16448128,alpha:100},{ra:0,dec:0,tilt:0});
   this.sphereMC.addCircle("nightArc",{thickness:1,color:10000536,alpha:100},{ra:0,dec:0,tilt:0});
   this.sphereMC.maxViewerAltitude = 89.9;
   this.sphereMC.minViewerAltitude = -89.9;
   this.sphereMC.addObject("Globe Component v2","globe");
   this.sphereMC.latitude = 90;
   this.sphereMC.globe.instance.showShading = true;
   this.sphereMC.globe.instance.size = 1;
   this.sphereMC.globe.instance.rotation = 40;
   this.sphereMC.globe.instance.axisLength = 1.15;
   this.sphereMC.globe.instance.setAxisStyle(2);
   this.plotMC.labelsMC.vernalEquinox.onPress = this.onLabelClicked;
   this.plotMC.labelsMC.summerSolstice.onPress = this.onLabelClicked;
   this.plotMC.labelsMC.autumnalEquinox.onPress = this.onLabelClicked;
   this.plotMC.labelsMC.winterSolstice.onPress = this.onLabelClicked;
   this.doySlider.grabberMC.onMouseMoveFunc = function()
   {
      var _loc2_ = this._parent.controller;
      var _loc3_ = _loc2_._maxP - _loc2_._minP;
      var _loc5_ = _loc2_._minP + ((this._parent._xmouse - this.xOffset - _loc2_._minP) % _loc3_ + _loc3_) % _loc3_;
      var _loc4_ = _loc2_.getValueObjectFromValue(_loc2_.getValueFromParameter(_loc5_));
      if(_loc4_.value != _loc2_.value)
      {
         this._parent.setValueByValueObject(_loc4_,true);
      }
      updateAfterEvent();
   };
   this.doySlider.barMC.onEnterFrameFunc = function()
   {
      var _loc4_ = getTimer();
      var _loc5_;
      var _loc3_;
      var _loc2_;
      var _loc6_;
      if(_loc4_ > this.waitTime)
      {
         _loc5_ = this._parent.continuousChangeRate * (_loc4_ - this.timeLast);
         _loc3_ = this._parent.controller;
         _loc2_ = _loc3_.getValueObjectFromValue(_loc3_.getValueFromParameter(this._parent._xmouse));
         if(_loc2_.value == 0 && _loc3_.value == 0)
         {
            this._parent.setValue(364,true);
         }
         else if(_loc2_.value == 364 && _loc3_.value == 364)
         {
            this._parent.setValue(0,true);
         }
         else if(_loc2_.value < _loc3_.value)
         {
            _loc6_ = _loc3_.getIncrementedValueObject(null,- _loc5_);
            if(_loc6_.value <= _loc2_.value)
            {
               this._parent.setValueByValueObject(_loc2_,true);
            }
            else
            {
               this._parent.setValueByValueObject(_loc6_,true);
            }
         }
         else if(_loc2_.value > _loc3_.value)
         {
            _loc6_ = _loc3_.getIncrementedValueObject(null,_loc5_);
            if(_loc6_.value >= _loc2_.value)
            {
               this._parent.setValueByValueObject(_loc2_,true);
            }
            else
            {
               this._parent.setValueByValueObject(_loc6_,true);
            }
         }
      }
      this.timeLast = _loc4_;
   };
   this.doySlider.barMC.onPress = function()
   {
      var _loc2_ = this._parent.controller;
      var _loc3_ = _loc2_.getValueObjectFromValue(_loc2_.getValueFromParameter(this._parent._xmouse)).value;
      if(_loc3_ == 0 && _loc2_.value == 0)
      {
         this._parent.setValue(364,true);
      }
      else if(_loc3_ == 364 && _loc2_.value == 364)
      {
         this._parent.setValue(0,true);
      }
      else if(_loc3_ < _loc2_.value)
      {
         this._parent.incrementValue(-1,true);
      }
      else if(_loc3_ > _loc2_.value)
      {
         this._parent.incrementValue(1,true);
      }
      this.timeLast = getTimer();
      this.waitTime = this.timeLast + this._parent.continuousChangeDelay;
      this.onEnterFrame = this.onEnterFrameFunc;
   };
   this.reset();
};
p.reset = function()
{
   this.showAverageCheckBox.setValue(false);
   this.showCursorCheckBox.setValue(true);
   this.sphereMC.setThetaAndPhi(140,0);
   this.latitudeSlider.value = 41;
   this.update = function()
   {
   };
   this.onLatitudeChanged();
   delete this.update;
   this.setDoy(121);
};
p.onLatitudeChanged = function()
{
   this.plotMC.latitude = this.latitudeSlider.value;
   if(this.latitudeSlider.value > 0)
   {
      this.latString = this.latitudeSlider.value.toFixed(1) + "° N";
   }
   else if(this.latitudeSlider.value < 0)
   {
      this.latString = (- this.latitudeSlider.value).toFixed(1) + "° S";
   }
   else
   {
      this.latString = "0.0°";
   }
   this.update();
};
p.onLabelClicked = function()
{
   this._parent._parent._parent.setDoy(this.eventDoy);
};
p.onDoySliderChanged = function()
{
   this.doy = this.doySlider.value + this.plotMC.vernalEquinoxDoy;
   this.onDoyChanged();
};
p.setDoy = function(doy)
{
   this.doy = doy;
   this.onDoyChanged();
   this.doySlider.value = this.doy - this.plotMC.vernalEquinoxDoy;
};
p.onDoyChanged = function()
{
   var _loc3_ = Math.round(this.doy) % 365;
   var _loc2_ = 1;
   while(_loc2_ < 12)
   {
      if(_loc3_ < this.plotMC.monthsList[_loc2_].doy)
      {
         break;
      }
      _loc2_ = _loc2_ + 1;
   }
   _loc2_ = _loc2_ - 1;
   this.longDoyString = this.plotMC.monthsList[_loc2_].longName + " " + String(1 + _loc3_ - this.plotMC.monthsList[_loc2_].doy);
   this.shortDoyString = this.plotMC.monthsList[_loc2_].shortName + " " + String(1 + _loc3_ - this.plotMC.monthsList[_loc2_].doy);
   this.update();
};
p.update = function()
{
   this.sunDec = this.plotMC.getSunDeclination(this.doy);
   this.hours = this.plotMC.getDaylightHours(this.latitudeSlider.value * 3.141592653589793 / 180,this.sunDec);
   this.hoursString = this.hours.toFixed(1);
   this.updateGlobe();
   this.updateTextfields();
   this.updateCursor();
};
p.updateGlobe = function()
{
   this.sphereMC.globe.instance.setSunPosition({ra:0,dec:this.sunDec * 180 / 3.141592653589793});
   var _loc3_;
   if(this.latitudeSlider.value < -89)
   {
      _loc3_ = -89;
   }
   else if(this.latitudeSlider.value > 89)
   {
      _loc3_ = 89;
   }
   else
   {
      _loc3_ = this.latitudeSlider.value;
   }
   var _loc2_ = this.hours / 2 * 15;
   this.sphereMC.dayArc.setParameters({ra:0,dec:_loc3_,tilt:0,gammaStart:- _loc2_,gammaEnd:_loc2_});
   this.sphereMC.dayArc.update();
   this.sphereMC.nightArc.setParameters({ra:0,dec:_loc3_,tilt:0,gammaStart:_loc2_,gammaEnd:- _loc2_});
   this.sphereMC.nightArc.update();
   if(this.hours >= 24)
   {
      this.sphereMC.nightArc.visible = false;
      this.sphereMC.dayArc.visible = true;
   }
   else if(this.hours <= 0)
   {
      this.sphereMC.nightArc.visible = true;
      this.sphereMC.dayArc.visible = false;
   }
   else
   {
      this.sphereMC.nightArc.visible = true;
      this.sphereMC.dayArc.visible = true;
   }
};
p.updateTextfields = function()
{
   this.outputField.text = "an observer at a latitude of " + this.latString + "\rwill receive " + this.hoursString + " hours of\rdaylight on " + this.longDoyString;
   this.titleField.text = "Hours of Daylight per Day at " + this.latString;
   this.doyField.text = this.longDoyString;
};
p.updateCursor = function()
{
   this.cursorMC.update();
};
p.onShowCursorChanged = function()
{
   this.cursorMC._visible = this.showCursorCheckBox.getValue();
};
p.onShowAverageChanged = function()
{
   this.plotMC.showAverage = this.showAverageCheckBox.getValue();
};
