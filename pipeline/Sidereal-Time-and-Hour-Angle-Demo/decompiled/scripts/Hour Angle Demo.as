function HourAngleDemoClass()
{
}
var p = HourAngleDemoClass.prototype = new MovieClip();
Object.registerClass("Hour Angle Demo",HourAngleDemoClass);
p.raColor = 16777215;
p.decColor = 16728128;
p.hourAngleColor = 16763749;
p.init = function()
{
   this.makeSliderCyclic(this.siderealTimeSlider);
   this.makeSliderCyclic(this.raSlider);
   this.sphereMC.size = 320;
   this.sphereMC.minViewerAltitude = 7;
   this.sphereMC.addHorizonPlaneClip("Direction Labels Light","aboveLabels","above");
   this.sphereMC.addShadingClip("sphere outside","outsideOfSphere","front","inner","both");
   this.sphereMC.addShadingClip("sphere outside2","outsideOfSphere2","front","outer","below");
   this.sphereMC.addObject("Stickfigure","stickfigure",{x:0,y:0,z:0,system:"horizon"},{_xscale:95,_yscale:95});
   this.sphereMC.stickfigure.setOrientationType("absolute",{x:-1,y:0,z:0,system:"horizon"},{x:0,y:0,z:1,system:"horizon"});
   this.sphereMC.addObject("DCS Label","raLabel",{ra:0,dec:0},{labelColor:this.raColor});
   this.sphereMC.addObject("DCS Label","decLabel",{ra:0,dec:0},{labelColor:this.decColor});
   this.sphereMC.addObject("DCS Label","hourAngleLabel",{ra:0,dec:0},{labelColor:this.hourAngleColor});
   this.sphereMC.addObject("Draggable Star","star",{ra:0,dec:0});
   this.sphereMC.addLine("ncpAxis",{thickness:2,color:7711231,alpha:100},{x:0,y:0,z:1,system:"celestial"},{x:0,y:0,z:1.2,system:"celestial"});
   this.sphereMC.addLine("scpAxis",{thickness:2,color:7711231,alpha:100},{x:0,y:0,z:-1,system:"celestial"},{x:0,y:0,z:-1.2,system:"celestial"});
   this.sphereMC.addCircle("observerMeridian",{thickness:2,color:7711231,alpha:100},{az:0,alt:0,tilt:90,gammaStart:0,gammaEnd:180});
   this.sphereMC.addCircle("meridian1",{thickness:1,color:16777215,alpha:10},{ra:0,dec:0,tilt:90});
   this.sphereMC.addCircle("meridian2",{thickness:1,color:16777215,alpha:10},{ra:6,dec:0,tilt:90});
   this.sphereMC.addCircle("zeroHoursCircle",{thickness:1,color:16769909,alpha:70},{ra:0,dec:0,tilt:90,gammaStart:-90,gammaEnd:90});
   this.sphereMC.addCircle("celestialEquator",{thickness:1,color:16769909,alpha:70},{ra:0,dec:0,tilt:0});
   this.sphereMC.addCircle("raCircle",{thickness:1,color:16777215,alpha:30},{ra:0,dec:0,tilt:90});
   this.sphereMC.addCircle("decCircle",{thickness:1,color:16777215,alpha:30},{ra:0,dec:0,tilt:90});
   this.sphereMC.addCircle("raArc",{thickness:3,color:this.raColor,alpha:100},{ra:0,dec:0,tilt:0});
   this.sphereMC.addCircle("decArc",{thickness:3,color:this.decColor,alpha:100},{ra:0,dec:0,tilt:90});
   this.sphereMC.addCircle("hourAngleArc",{thickness:3,color:this.hourAngleColor,alpha:100},{ra:0,dec:0});
   this.sphereMC.onMouseUpdate = function()
   {
      updateAfterEvent();
   };
   this.reset();
};
p.onPositionSliderChanged = function()
{
   this.setStarLocation({ra:this.raSlider.value,dec:this.decSlider.value},true);
};
p.setStarLocation = function(pt, skipSliderSync)
{
   this.sphereMC.raLabel.instance.labelText = pt.ra.toFixed(1) + "h";
   this.sphereMC.raLabel.setPosition({ra:pt.ra - 0.9,dec:5,r:1.001});
   this.sphereMC.raLabel.setOrientationType("absolute");
   this.sphereMC.decLabel.instance.labelText = pt.dec.toFixed(1) + "°";
   this.sphereMC.decLabel.setPosition({ra:pt.ra + 0.9,dec:pt.dec / 2,r:1.001});
   this.sphereMC.decLabel.setOrientationType("absolute");
   this.sphereMC.star.setPosition(pt);
   this.sphereMC.star.setOrientationType("absolute");
   if(pt.ra != 0)
   {
      this.sphereMC.raArc.setParameters({ra:0,dec:0,tilt:0,gammaStart:0,gammaEnd:15 * pt.ra});
      this.sphereMC.raArc._visible = true;
   }
   else
   {
      this.sphereMC.raArc._visible = false;
   }
   this.sphereMC.raCircle.setParameters({ra:pt.ra,dec:0,tilt:90,gammaStart:-90,gammaEnd:90});
   if(pt.dec < 0)
   {
      this.sphereMC.decArc.setParameters({ra:pt.ra,dec:0,tilt:90,gammaStart:pt.dec,gammaEnd:0});
      this.sphereMC.decArc._visible = true;
   }
   else if(pt.dec > 0)
   {
      this.sphereMC.decArc.setParameters({ra:pt.ra,dec:0,tilt:90,gammaStart:0,gammaEnd:pt.dec});
      this.sphereMC.decArc._visible = true;
   }
   else
   {
      this.sphereMC.decArc._visible = false;
   }
   this.sphereMC.decCircle.setParameters({ra:0,dec:pt.dec,tilt:0});
   if(!skipSliderSync)
   {
      this.raSlider.value = pt.ra;
      this.decSlider.value = pt.dec;
   }
   this.updateHourAngle();
};
p.updateHourAngle = function()
{
   var _loc2_ = (this.siderealTimeSlider.value - this.raSlider.value + 24) % 24;
   if(_loc2_ > 12)
   {
      _loc2_ -= 24;
   }
   this.hourAngleField.text = _loc2_.toFixed(2) + " h";
   var _loc3_;
   if(this.showHourAngleArcCheckBox.getValue())
   {
      _loc3_ = this.siderealTimeSlider.value;
      this.sphereMC.hourAngleLabel.visible = true;
      this.sphereMC.hourAngleLabel.instance.labelText = _loc2_.toFixed(1) + "h";
      this.sphereMC.hourAngleLabel.setPosition({ra:_loc3_ - _loc2_ / 2,dec:this.decSlider.value + 5});
      this.sphereMC.hourAngleLabel.setOrientationType("absolute");
      if(_loc2_ < 0)
      {
         this.sphereMC.hourAngleArc.setParameters({ra:_loc3_,dec:this.decSlider.value,tilt:0,gammaStart:0,gammaEnd:360 - 15 * _loc2_});
         this.sphereMC.hourAngleArc._visible = true;
      }
      else if(_loc2_ > 0)
      {
         this.sphereMC.hourAngleArc.setParameters({ra:_loc3_,dec:this.decSlider.value,tilt:0,gammaStart:-15 * _loc2_,gammaEnd:0});
         this.sphereMC.hourAngleArc._visible = true;
      }
      else
      {
         this.sphereMC.hourAngleArc._visible = false;
      }
   }
   else
   {
      this.sphereMC.hourAngleLabel.visible = false;
      this.sphereMC.hourAngleArc._visible = false;
   }
   this.sphereMC.updateObjects();
   this.sphereMC.updateCircles();
};
p.onLatitudeChanged = function()
{
   this.sphereMC.observerMeridian.gammaStart = this.latitudeSlider.value;
   this.sphereMC.observerMeridian.gammaEnd = this.sphereMC.observerMeridian.gammaStart + 180;
   this.sphereMC.observerMeridian.update();
   this.sphereMC.latitude = this.latitudeSlider.value;
};
p.onSiderealTimeChanged = function()
{
   this.sphereMC.siderealTime = this.siderealTimeSlider.value;
   this.updateHourAngle();
};
p.reset = function()
{
   this.showHourAngleArcCheckBox.setValue(false);
   this.sphereMC.viewerAzimuth = 160;
   this.sphereMC.viewerAltitude = 35;
   this.latitudeSlider.value = 41;
   this.onLatitudeChanged();
   this.siderealTimeSlider.value = 2;
   this.onSiderealTimeChanged();
   this.setStarLocation({ra:4,dec:30},false);
};
p.makeSliderCyclic = function(slider)
{
   slider.grabberMC.onMouseMoveFunc = function()
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
   slider.barMC.onEnterFrameFunc = function()
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
            this._parent.setValue(this._parent.maxValue,true);
         }
         else if(Math.abs(_loc2_.value - this._parent.maxValue) < 1e-12 && Math.abs(_loc3_.value - this._parent.maxValue) < 1e-12)
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
   slider.barMC.onPress = function()
   {
      var _loc2_ = this._parent.controller;
      var _loc3_ = _loc2_.getValueObjectFromValue(_loc2_.getValueFromParameter(this._parent._xmouse)).value;
      if(_loc3_ == 0 && _loc2_.value == 0)
      {
         this._parent.setValue(this._parent.maxValue,true);
      }
      else if(Math.abs(_loc3_ - this._parent.maxValue) < 1e-12 && Math.abs(_loc2_.value - this._parent.maxValue) < 1e-12)
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
};
