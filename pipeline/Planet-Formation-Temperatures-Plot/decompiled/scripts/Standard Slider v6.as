function StandardSliderClassV6()
{
   var _loc1_ = this;
   _loc1_.createEmptyMovieClip("barMC",15);
   _loc1_.createEmptyMovieClip("grabberMC",16);
   _loc1_.createEmptyMovieClip("fieldMC",17);
   _loc1_.createTextField("valueField",20,0,0,0,0);
   _loc1_.valueField.restrict = "0-9.Ee+\\-";
   _loc1_.valueField.onChangedFunc = function()
   {
      this._parent.activateField();
   };
   _loc1_.valueField.onKillFocus = function()
   {
      var _loc1_ = this;
      var _loc2_ = _root;
      _loc1_._parent.inactivateField();
      if(_loc1_._parent.grabberMC.hitTest(_loc2_._xmouse,_loc2_._ymouse,true) || _loc1_._parent.barMC.hitTest(_loc2_._xmouse,_loc2_._ymouse,true))
      {
         _loc1_._parent.updateSynchronization();
      }
      else
      {
         _loc1_._parent.setValue(parseFloat(_loc1_.text),true);
      }
   };
   _loc1_.valueField.onKeyDown = function()
   {
      var _loc1_ = this;
      if(Key.isDown(13))
      {
         _loc1_._parent.inactivateField();
         _loc1_._parent.setValue(parseFloat(_loc1_.text),true);
      }
   };
   _loc1_.barMC.tabEnabled = false;
   _loc1_.barMC.useHandCursor = false;
   _loc1_.barMC.onPressFunc = function()
   {
      var _loc1_ = this;
      var _loc2_ = _loc1_._parent.controller;
      var _loc3_ = _loc2_.getValueObjectFromValue(_loc2_.getValueFromParameter(_loc1_._parent._xmouse)).value;
      if(_loc3_ < _loc2_.value)
      {
         _loc1_._parent.incrementValue(-1,true);
      }
      else if(_loc3_ > _loc2_.value)
      {
         _loc1_._parent.incrementValue(1,true);
      }
      _loc1_.timeLast = getTimer();
      _loc1_.waitTime = _loc1_.timeLast + _loc1_._parent.continuousChangeDelay;
      _loc1_.onEnterFrame = _loc1_.onEnterFrameFunc;
   };
   _loc1_.barMC.onReleaseOutside = _loc1_.barMC.onRelease = function()
   {
      delete this.onEnterFrame;
   };
   _loc1_.barMC.onEnterFrameFunc = function()
   {
      var _loc1_ = this;
      var timeNow = getTimer();
      var _loc3_;
      var _loc2_;
      if(timeNow > _loc1_.waitTime)
      {
         var ticks = _loc1_._parent.continuousChangeRate * (timeNow - _loc1_.timeLast);
         _loc3_ = _loc1_._parent.controller;
         _loc2_ = _loc3_.getValueObjectFromValue(_loc3_.getValueFromParameter(_loc1_._parent._xmouse));
         if(_loc2_.value < _loc3_.value)
         {
            var nValueObj = _loc3_.getIncrementedValueObject(null,- ticks);
            if(nValueObj.value <= _loc2_.value)
            {
               _loc1_._parent.setValueByValueObject(_loc2_,true);
            }
            else
            {
               _loc1_._parent.setValueByValueObject(nValueObj,true);
            }
         }
         else if(_loc2_.value > _loc3_.value)
         {
            var nValueObj = _loc3_.getIncrementedValueObject(null,ticks);
            if(nValueObj.value >= _loc2_.value)
            {
               _loc1_._parent.setValueByValueObject(_loc2_,true);
            }
            else
            {
               _loc1_._parent.setValueByValueObject(nValueObj,true);
            }
         }
      }
      _loc1_.timeLast = timeNow;
   };
   _loc1_.grabberMC._focusrect = false;
   _loc1_.grabberMC.onSetFocus = function()
   {
      var _loc1_ = this;
      Key.addListener(_loc1_);
      _loc1_.normalBorderMC._visible = false;
      _loc1_.tabbedBorderMC._visible = true;
      _loc1_.onMouseDown = _loc1_.onKillFocus;
   };
   _loc1_.grabberMC.onKillFocus = function()
   {
      var _loc1_ = this;
      Key.removeListener(_loc1_);
      _loc1_.normalBorderMC._visible = true;
      _loc1_.tabbedBorderMC._visible = false;
      delete _loc1_.onMouseDown;
   };
   _loc1_.grabberMC.onKeyDown = function()
   {
      var _loc3_ = this;
      var _loc1_ = _loc3_._parent.controller;
      var _loc2_;
      if(Key.isDown(37))
      {
         _loc2_ = _loc1_.getIncrementedValueObject(null,-1);
         if(_loc2_.value != _loc1_.value)
         {
            _loc3_._parent.setValueByValueObject(_loc2_,true);
         }
      }
      else if(Key.isDown(39))
      {
         _loc2_ = _loc1_.getIncrementedValueObject(null,1);
         if(_loc2_.value != _loc1_.value)
         {
            _loc3_._parent.setValueByValueObject(_loc2_,true);
         }
      }
   };
   _loc1_.grabberMC.useHandCursor = false;
   _loc1_.grabberMC.onPressFunc = function()
   {
      var _loc1_ = this;
      _loc1_.xOffset = _loc1_._parent._xmouse - _loc1_._x;
      _loc1_.onMouseMove = _loc1_.onMouseMoveFunc;
   };
   _loc1_.grabberMC.onMouseMoveFunc = function()
   {
      var _loc2_ = this;
      var _loc1_ = _loc2_._parent.controller;
      var _loc3_ = _loc1_.getValueObjectFromValue(_loc1_.getValueFromParameter(_loc2_._parent._xmouse - _loc2_.xOffset));
      if(_loc3_.value != _loc1_.value)
      {
         _loc2_._parent.setValueByValueObject(_loc3_,true);
      }
      updateAfterEvent();
   };
   _loc1_.grabberMC.onRelease = _loc1_.grabberMC.onReleaseOutside = function()
   {
      delete this.onMouseMove;
   };
   _loc1_.grabberMC.createEmptyMovieClip("tabbedBorderMC",1);
   _loc1_.grabberMC.createEmptyMovieClip("normalBorderMC",2);
   _loc1_.grabberMC.createEmptyMovieClip("fillMC",3);
   _loc1_.grabberMC.tabbedBorderMC._visible = false;
   _loc1_.fieldMC.createEmptyMovieClip("backgroundMC",1);
   _loc1_.fieldMC.createEmptyMovieClip("fillMC",2);
   _loc1_.fieldBackgroundColorObj = new Color(_loc1_.fieldMC.fillMC);
   delete _loc1_.value;
   if(_loc1_.labelText == undefined)
   {
      _loc1_.labelText = "";
   }
   if(_loc1_.unitsText == undefined)
   {
      _loc1_.unitsText = "";
   }
   if(_loc1_.minValue == undefined)
   {
      _loc1_.minValue = 1;
   }
   if(_loc1_.maxValue == undefined)
   {
      _loc1_.maxValue = 10;
   }
   if(_loc1_.initValue == undefined)
   {
      _loc1_.initValue = 5;
   }
   if(_loc1_.scalingMode == undefined)
   {
      _loc1_.scalingMode = "linear";
   }
   if(_loc1_.precisionMode == undefined)
   {
      _loc1_.precisionMode = "fixed digits";
   }
   if(_loc1_.precision == undefined)
   {
      _loc1_.precision = 2;
   }
   if(_loc1_.userEnabled == undefined)
   {
      _loc1_.userEnabled = true;
   }
   if(_loc1_.maxChars == undefined)
   {
      _loc1_.maxChars = 5;
   }
   if(_loc1_.fieldWidth == undefined)
   {
      _loc1_.fieldWidth = 60;
   }
   if(_loc1_.barSpacing == undefined)
   {
      _loc1_.barSpacing = 40;
   }
   if(_loc1_.fontsMovieClip == undefined)
   {
      _loc1_.fontsMovieClip = "Slider Fonts v6";
   }
   if(_loc1_.labelAndUnitsTextColor == undefined)
   {
      _loc1_.labelAndUnitsTextColor = 0;
   }
   if(_loc1_.fieldNormalTextColor == undefined)
   {
      _loc1_.fieldNormalTextColor = 0;
   }
   if(_loc1_.fieldActiveTextColor == undefined)
   {
      _loc1_.fieldActiveTextColor = 0;
   }
   if(_loc1_.fieldDisabledTextColor == undefined)
   {
      _loc1_.fieldDisabledTextColor = 4210752;
   }
   if(_loc1_.fieldMargin == undefined)
   {
      _loc1_.fieldMargin = 5;
   }
   if(_loc1_.fieldRoundedness == undefined)
   {
      _loc1_.fieldRoundedness = 0.4;
   }
   if(_loc1_.fieldBorderThickness == undefined)
   {
      _loc1_.fieldBorderThickness = 1;
   }
   if(_loc1_.fieldBorderColor == undefined)
   {
      _loc1_.fieldBorderColor = 12632256;
   }
   if(_loc1_.fieldNormalBackgroundColor == undefined)
   {
      _loc1_.fieldNormalBackgroundColor = 16777215;
   }
   if(_loc1_.fieldActiveBackgroundColor == undefined)
   {
      _loc1_.fieldActiveBackgroundColor = 16777198;
   }
   if(_loc1_.fieldDisabledBackgroundColor == undefined)
   {
      _loc1_.fieldDisabledBackgroundColor = 16053492;
   }
   if(_loc1_.barMargin == undefined)
   {
      _loc1_.barMargin = 7;
   }
   if(_loc1_.barThickness == undefined)
   {
      _loc1_.barThickness = 6;
   }
   if(_loc1_.barRoundedness == undefined)
   {
      _loc1_.barRoundedness = 0.7;
   }
   if(_loc1_.barBorderThickness == undefined)
   {
      _loc1_.barBorderThickness = 1;
   }
   if(_loc1_.barBorderColor == undefined)
   {
      _loc1_.barBorderColor = 12632256;
   }
   if(_loc1_.barTopColor == undefined)
   {
      _loc1_.barTopColor = 16448250;
   }
   if(_loc1_.barBottomColor == undefined)
   {
      _loc1_.barBottomColor = 13684944;
   }
   if(_loc1_.grabberWidth == undefined)
   {
      _loc1_.grabberWidth = 9;
   }
   if(_loc1_.grabberHeight == undefined)
   {
      _loc1_.grabberHeight = 17;
   }
   if(_loc1_.grabberRoundedness == undefined)
   {
      _loc1_.grabberRoundedness = 0.8;
   }
   if(_loc1_.grabberNormalBorderThickness == undefined)
   {
      _loc1_.grabberNormalBorderThickness = 1;
   }
   if(_loc1_.grabberNormalBorderColor == undefined)
   {
      _loc1_.grabberNormalBorderColor = 12632256;
   }
   if(_loc1_.grabberTabbedBorderThickness == undefined)
   {
      _loc1_.grabberTabbedBorderThickness = 2;
   }
   if(_loc1_.grabberTabbedBorderColor == undefined)
   {
      _loc1_.grabberTabbedBorderColor = 11579568;
   }
   if(_loc1_.grabberMiddleColor == undefined)
   {
      _loc1_.grabberMiddleColor = 16053492;
   }
   if(_loc1_.grabberSideColor == undefined)
   {
      _loc1_.grabberSideColor = 14737632;
   }
   if(_loc1_.continuousChangeDelay == undefined)
   {
      _loc1_.continuousChangeDelay = 500;
   }
   if(_loc1_.continuousChangeRate == undefined)
   {
      _loc1_.continuousChangeRate = 0.05;
   }
   if(_loc1_.sliderRange == undefined)
   {
      _loc1_.sliderRange = _loc1_._width - _loc1_.fieldWidth - _loc1_.barSpacing - 2 * _loc1_.barMargin;
      if(_loc1_.sliderRange < 3 * _loc1_.grabberWidth)
      {
         _loc1_.sliderRange = 3 * _loc1_.grabberWidth;
      }
   }
   _loc1_.placeholderMC._visible = false;
   _loc1_.placeholderMC.swapDepths(121212);
   _loc1_.placeholderMC.removeMovieClip();
   _loc1_._xscale = 100;
   _loc1_._yscale = 100;
   var fL = _loc1_.functionsList;
   var uL = [];
   var _loc2_ = 0;
   while(_loc2_ < fL.length)
   {
      uL.push({name:fL[_loc2_],call:true});
      _loc2_ = _loc2_ + 1;
   }
   _loc1_.updateList = uL;
   var _loc3_ = _loc1_.propertiesList;
   _loc2_ = 0;
   while(_loc2_ < _loc3_.length)
   {
      _loc1_.watch(_loc3_[_loc2_].property,_loc1_.registerChange,_loc3_[_loc2_].functionIndices);
      _loc2_ = _loc2_ + 1;
   }
   _loc1_.update();
   var initObj = {};
   initObj.scalingMode = _loc1_.scalingMode;
   initObj.valueFormat = _loc1_.precisionMode;
   initObj.valueDigits = _loc1_.precision;
   initObj.minValue = _loc1_.minValue;
   initObj.maxValue = _loc1_.maxValue;
   initObj.minParameter = _loc1_.fieldWidth + _loc1_.barSpacing + _loc1_.barMargin;
   initObj.maxParameter = initObj.minParameter + _loc1_.sliderRange;
   initObj.value = _loc1_.initValue;
   _loc1_.controller = new SliderLogicClassV6(initObj);
   _loc1_.updateSynchronization();
   _loc1_.inactivateField();
}
var p = StandardSliderClassV6.prototype = new MovieClip();
Object.registerClass("Standard Slider v6",StandardSliderClassV6);
p.getValue = function()
{
   return this.controller.value;
};
p.setValue = function(arg, callChangeHandler)
{
   var _loc1_ = this;
   var _loc2_ = arg;
   if(typeof _loc2_ == "number" && !isNaN(_loc2_) && isFinite(_loc2_))
   {
      _loc1_.controller.value = _loc2_;
   }
   _loc1_.updateSynchronization();
   if(callChangeHandler)
   {
      _loc1_._parent[_loc1_.changeHandler](_loc1_.controller.value);
   }
};
p.addProperty("value",p.getValue,p.setValue);
p.getValueString = function()
{
   return this.controller.valueString;
};
p.addProperty("valueString",p.getValueString,null);
p.incrementValue = function(ticks, callChangeHandler)
{
   var _loc1_ = this;
   var _loc2_ = ticks;
   if(typeof _loc2_ == "number" && !isNaN(_loc2_) && isFinite(_loc2_))
   {
      _loc1_.controller.incrementValue(_loc2_);
   }
   _loc1_.updateSynchronization();
   if(callChangeHandler)
   {
      _loc1_._parent[_loc1_.changeHandler](_loc1_.controller.value);
   }
};
p.setValueByValueObject = function(vObj, callChangeHandler)
{
   var _loc1_ = this;
   _loc1_.controller.setValueByValueObject(vObj);
   _loc1_.updateSynchronization();
   if(callChangeHandler)
   {
      _loc1_._parent[_loc1_.changeHandler](_loc1_.controller.value);
   }
};
p.activateField = function()
{
   var _loc1_ = this;
   _loc1_.active = true;
   _loc1_.updateFieldBackground();
   _loc1_.updateFieldTextFormat();
   _loc1_.updateActiveState();
};
p.inactivateField = function()
{
   var _loc1_ = this;
   _loc1_.active = false;
   _loc1_.updateFieldBackground();
   _loc1_.updateFieldTextFormat();
   _loc1_.updateActiveState();
};
p.functionsList = ["updateFonts","updateTextColors","updateEnabled","updateField","updateFieldTextFormat","updatePrecision","updateScalingMode","updateSliderRange","updateParameterRange","updateLabelText","updateUnitsText","updateActiveState","updateFieldBackground","updateMaxCharsProperty","updateGrabber","updateBar","updateLabelAndUnitsPositions","updateBarPosition","updateSynchronization"];
iL = [];
i = 0;
while(i < p.functionsList.length)
{
   iL[p.functionsList[i]] = i;
   i++;
}
p.propertiesList = [{property:"grabberWidth",functionIndices:[iL.updateGrabber]},{property:"grabberHeight",functionIndices:[iL.updateGrabber]},{property:"grabberRoundedness",functionIndices:[iL.updateGrabber]},{property:"grabberNormalBorderThickness",functionIndices:[iL.updateGrabber]},{property:"grabberNormalBorderColor",functionIndices:[iL.updateGrabber]},{property:"grabberTabbedBorderThickness",functionIndices:[iL.updateGrabber]},{property:"grabberTabbedBorderColor",functionIndices:[iL.updateGrabber]},{property:"grabberMiddleColor",functionIndices:[iL.updateGrabber]},{property:"grabberSideColor",functionIndices:[iL.updateGrabber]},{property:"sliderRange",functionIndices:[iL.updateParameterRange,iL.updateBar,iL.updateSynchronization]},{property:"labelText",functionIndices:[iL.updateLabelText,iL.updateLabelAndUnitsPositions]},{property:"unitsText",functionIndices:[iL.updateUnitsText,iL.updateLabelAndUnitsPositions]},{property:"minValue",functionIndices:[iL.updateSliderRange,iL.updateSynchronization]},{property:"maxValue",functionIndices:[iL
.updateSliderRange,iL.updateSynchronization]},{property:"scalingMode",functionIndices:[iL.updateScalingMode,iL.updateSynchronization]},{property:"precisionMode",functionIndices:[iL.updatePrecision,iL.updateSynchronization]},{property:"precision",functionIndices:[iL.updatePrecision,iL.updateSynchronization]},{property:"userEnabled",functionIndices:[iL.updateEnabled,iL.updateFieldTextFormat,iL.updateFieldBackground,iL.updateSynchronization]},{property:"maxChars",functionIndices:[iL.updateMaxCharsProperty]},{property:"fieldWidth",functionIndices:[iL.updateField,iL.updateParameterRange,iL.updateBarPosition,iL.updateLabelAndUnitsPositions,iL.updateSynchronization]},{property:"barSpacing",functionIndices:[iL.updateParameterRange,iL.updateBarPosition,iL.updateSynchronization]},{property:"labelAndUnitsTextColor",functionIndices:[iL.updateTextColors,iL.updateLabelText,iL.updateUnitsText,iL.updateLabelAndUnitsPositions]},{property:"fieldNormalTextColor",functionIndices:[iL.updateEnabled,iL.updateFieldTextFormat]},{property:"fieldActiveTextColor",functionIndices:[iL
.updateTextColors,iL.updateFieldTextFormat]},{property:"fieldDisabledTextColor",functionIndices:[iL.updateEnabled,iL.updateFieldTextFormat]},{property:"fieldMargin",functionIndices:[iL.updateLabelAndUnitsPositions]},{property:"fieldRoundedness",functionIndices:[iL.updateField,iL.updateLabelAndUnitsPositions]},{property:"fieldBorderThickness",functionIndices:[iL.updateField,iL.updateLabelAndUnitsPositions]},{property:"fieldBorderColor",functionIndices:[iL.updateField]},{property:"fieldNormalBackgroundColor",functionIndices:[iL.updateFieldBackground]},{property:"fieldActiveBackgroundColor",functionIndices:[iL.updateFieldBackground]},{property:"fieldDisabledBackgroundColor",functionIndices:[iL.updateFieldBackground]},{property:"barMargin",functionIndices:[iL.updateParameterRange,iL.updateBar,iL.updateSynchronization]},{property:"barThickness",functionIndices:[iL.updateBar]},{property:"barRoundedness",functionIndices:[iL.updateBar]},{property:"barBorderThickness",functionIndices:[iL.updateBar]},{property:"barBorderColor",functionIndices:[iL
.updateBar]},{property:"barTopColor",functionIndices:[iL.updateBar]},{property:"barBottomColor",functionIndices:[iL.updateBar]},{property:"fontsMovieClip",functionIndices:[iL.updateFonts,iL.updateTextColors,iL.updateLabelText,iL.updateUnitsText,iL.updateField,iL.updateLabelAndUnitsPositions,iL.updateEnabled,iL.updateFieldTextFormat,iL.updateSynchronization]}];
p.registerChange = function(prop, oldVal, newVal, iL)
{
   var _loc2_ = iL;
   var _loc3_ = this;
   var _loc1_ = 0;
   while(_loc1_ < _loc2_.length)
   {
      _loc3_.updateList[_loc2_[_loc1_]].call = true;
      _loc1_ = _loc1_ + 1;
   }
   return newVal;
};
p.update = function()
{
   var _loc3_ = this;
   var _loc2_ = _loc3_.updateList;
   var _loc1_ = 0;
   while(_loc1_ < _loc2_.length)
   {
      if(_loc2_[_loc1_].call)
      {
         _loc3_[_loc2_[_loc1_].name]();
         _loc2_[_loc1_].call = false;
      }
      _loc1_ = _loc1_ + 1;
   }
};
p.updateSynchronization = function()
{
   var _loc1_ = this;
   _loc1_.grabberMC._x = _loc1_.controller.parameter;
   _loc1_.valueField.text = _loc1_.controller.valueString;
};
p.updateParameterRange = function()
{
   var _loc1_ = this;
   var _loc2_ = _loc1_.fieldWidth + _loc1_.barSpacing + _loc1_.barMargin;
   var _loc3_ = _loc2_ + _loc1_.sliderRange;
   _loc1_.controller.setValueAndParameterRanges(null,null,_loc2_,_loc3_);
};
p.updateSliderRange = function()
{
   var _loc1_ = this;
   _loc1_.controller.setValueAndParameterRanges(_loc1_.minValue,_loc1_.maxValue,null,null);
};
p.updateScalingMode = function()
{
   this.controller.setScalingMode(this.scalingMode);
};
p.updatePrecision = function()
{
   var _loc1_ = this;
   _loc1_.controller.setValueFormat(_loc1_.precisionMode,_loc1_.precision);
};
p.updateBarPosition = function()
{
   var _loc1_ = this;
   _loc1_.barMC._x = _loc1_.fieldWidth + _loc1_.barSpacing;
};
p.updateLabelAndUnitsPositions = function()
{
   var _loc1_ = this;
   _loc1_.labelTextMC._x = - _loc1_.fieldMargin - _loc1_.labelOffset - _loc1_.labelTextMC.totalWidth;
   _loc1_.unitsTextMC._x = _loc1_.fieldMargin + _loc1_.fieldWidth + _loc1_.labelOffset;
};
p.updateBar = function()
{
   var _loc2_ = this;
   var y = _loc2_.barThickness / 2;
   var _loc3_ = y + _loc2_.barBorderThickness;
   var x = _loc2_.sliderRange + 2 * _loc2_.barMargin;
   var rnd = _loc2_.barRoundedness;
   var _loc1_ = _loc2_.barMC;
   _loc1_.clear();
   if(rnd <= 0)
   {
      var bx1 = - _loc2_.barBorderThickness;
      var bx2 = x + _loc2_.barBorderThickness;
      _loc1_.moveTo(bx1,_loc3_);
      _loc1_.beginFill(_loc2_.barBorderColor);
      _loc1_.lineTo(bx2,_loc3_);
      _loc1_.lineTo(bx2,- _loc3_);
      _loc1_.lineTo(bx1,- _loc3_);
      _loc1_.lineTo(bx1,_loc3_);
      _loc1_.endFill();
      _loc1_.moveTo(0,y);
      _loc1_.beginGradientFill("linear",[_loc2_.barTopColor,_loc2_.barBottomColor],[100,100],[0,255],{matrixType:"box",x:0,y:- y,w:1,h:2 * y,r:1.5707963267948966});
      _loc1_.lineTo(x,y);
      _loc1_.lineTo(x,- y);
      _loc1_.lineTo(0,- y);
      _loc1_.lineTo(0,y);
      _loc1_.endFill();
   }
   else if(rnd >= 1)
   {
      _loc1_.moveTo(0,_loc3_);
      _loc1_.beginFill(_loc2_.barBorderColor);
      _loc1_.lineTo(x,_loc3_);
      _loc2_.drawHalfCircle(_loc1_,x,0,_loc3_,3);
      _loc1_.lineTo(0,- _loc3_);
      _loc2_.drawHalfCircle(_loc1_,0,0,_loc3_,1);
      _loc1_.endFill();
      _loc1_.moveTo(0,y);
      _loc1_.beginGradientFill("linear",[_loc2_.barTopColor,_loc2_.barBottomColor],[100,100],[0,255],{matrixType:"box",x:0,y:- y,w:1,h:2 * y,r:1.5707963267948966});
      _loc1_.lineTo(x,y);
      _loc2_.drawHalfCircle(_loc1_,x,0,y,3);
      _loc1_.lineTo(0,- y);
      _loc2_.drawHalfCircle(_loc1_,0,0,y,1);
      _loc1_.endFill();
   }
   else
   {
      var r = y * rnd;
      var br = r + _loc2_.barBorderThickness;
      var dy = y - r;
      _loc1_.moveTo(0,_loc3_);
      _loc1_.beginFill(_loc2_.barBorderColor);
      _loc1_.lineTo(x,_loc3_);
      _loc2_.drawQuarterCircle(_loc1_,x,dy,br,3);
      _loc1_.lineTo(x + br,- dy);
      _loc2_.drawQuarterCircle(_loc1_,x,- dy,br,0);
      _loc1_.lineTo(0,- _loc3_);
      _loc2_.drawQuarterCircle(_loc1_,0,- dy,br,1);
      _loc1_.lineTo(- br,dy);
      _loc2_.drawQuarterCircle(_loc1_,0,dy,br,2);
      _loc1_.endFill();
      _loc1_.moveTo(0,y);
      _loc1_.beginGradientFill("linear",[_loc2_.barTopColor,_loc2_.barBottomColor],[100,100],[0,255],{matrixType:"box",x:0,y:- y,w:1,h:2 * y,r:1.5707963267948966});
      _loc1_.lineTo(x,y);
      _loc2_.drawQuarterCircle(_loc1_,x,dy,r,3);
      _loc1_.lineTo(x + r,- dy);
      _loc2_.drawQuarterCircle(_loc1_,x,- dy,r,0);
      _loc1_.lineTo(0,- y);
      _loc2_.drawQuarterCircle(_loc1_,0,- dy,r,1);
      _loc1_.lineTo(- r,dy);
      _loc2_.drawQuarterCircle(_loc1_,0,dy,r,2);
      _loc1_.endFill();
   }
};
p.updateGrabber = function()
{
   var _loc1_ = this;
   var x = _loc1_.grabberWidth / 2;
   var y = _loc1_.grabberHeight / 2;
   var rnd = _loc1_.grabberRoundedness;
   var tbmc = _loc1_.grabberMC.tabbedBorderMC;
   tbmc.clear();
   var _loc2_ = _loc1_.grabberMC.normalBorderMC;
   _loc2_.clear();
   var _loc3_ = _loc1_.grabberMC.fillMC;
   _loc3_.clear();
   if(rnd <= 0)
   {
      var bx = x + _loc1_.grabberTabbedBorderThickness;
      var by = y + _loc1_.grabberTabbedBorderThickness;
      tbmc.moveTo(bx,by);
      tbmc.beginFill(_loc1_.grabberTabbedBorderColor);
      tbmc.lineTo(bx,- by);
      tbmc.lineTo(- bx,- by);
      tbmc.lineTo(- bx,by);
      tbmc.lineTo(bx,by);
      tbmc.endFill();
      var bx = x + _loc1_.grabberNormalBorderThickness;
      var by = y + _loc1_.grabberNormalBorderThickness;
      _loc2_.moveTo(bx,by);
      _loc2_.beginFill(_loc1_.grabberNormalBorderColor);
      _loc2_.lineTo(bx,- by);
      _loc2_.lineTo(- bx,- by);
      _loc2_.lineTo(- bx,by);
      _loc2_.lineTo(bx,by);
      _loc2_.endFill();
      _loc3_.moveTo(x,y);
      _loc3_.beginGradientFill("linear",[_loc1_.grabberSideColor,_loc1_.grabberMiddleColor,_loc1_.grabberSideColor],[100,100,100],[0,128,255],{matrixType:"box",x:- x,y:- y,w:2 * x,h:1,r:0});
      _loc3_.lineTo(x,- y);
      _loc3_.lineTo(- x,- y);
      _loc3_.lineTo(- x,y);
      _loc3_.lineTo(x,y);
      _loc3_.endFill();
   }
   else if(rnd >= 1)
   {
      var bx = x + _loc1_.grabberTabbedBorderThickness;
      tbmc.moveTo(bx,y);
      tbmc.beginFill(_loc1_.grabberTabbedBorderColor);
      tbmc.lineTo(bx,- y);
      _loc1_.drawHalfCircle(tbmc,0,- y,bx,0);
      tbmc.lineTo(- bx,y);
      _loc1_.drawHalfCircle(tbmc,0,y,bx,2);
      tbmc.endFill();
      var bx = x + _loc1_.grabberNormalBorderThickness;
      _loc2_.moveTo(bx,y);
      _loc2_.beginFill(_loc1_.grabberNormalBorderColor);
      _loc2_.lineTo(bx,- y);
      _loc1_.drawHalfCircle(_loc2_,0,- y,bx,0);
      _loc2_.lineTo(- bx,y);
      _loc1_.drawHalfCircle(_loc2_,0,y,bx,2);
      _loc2_.endFill();
      _loc3_.moveTo(x,y);
      _loc3_.beginGradientFill("linear",[_loc1_.grabberSideColor,_loc1_.grabberMiddleColor,_loc1_.grabberSideColor],[100,100,100],[0,128,255],{matrixType:"box",x:- x,y:- y,w:2 * x,h:1,r:0});
      _loc3_.lineTo(x,- y);
      _loc1_.drawHalfCircle(_loc3_,0,- y,x,0);
      _loc3_.lineTo(- x,y);
      _loc1_.drawHalfCircle(_loc3_,0,y,x,2);
      _loc3_.endFill();
   }
   else
   {
      var r = x * rnd;
      var dx = x - r;
      var bx = x + _loc1_.grabberTabbedBorderThickness;
      var br = r + _loc1_.grabberTabbedBorderThickness;
      tbmc.moveTo(bx,y);
      tbmc.beginFill(_loc1_.grabberTabbedBorderColor);
      tbmc.lineTo(bx,- y);
      _loc1_.drawQuarterCircle(tbmc,dx,- y,br,0);
      tbmc.lineTo(- dx,- y - br);
      _loc1_.drawQuarterCircle(tbmc,- dx,- y,br,1);
      tbmc.lineTo(- bx,y);
      _loc1_.drawQuarterCircle(tbmc,- dx,y,br,2);
      tbmc.lineTo(dx,y + br);
      _loc1_.drawQuarterCircle(tbmc,dx,y,br,3);
      tbmc.endFill();
      var bx = x + _loc1_.grabberNormalBorderThickness;
      var br = r + _loc1_.grabberNormalBorderThickness;
      _loc2_.moveTo(bx,y);
      _loc2_.beginFill(_loc1_.grabberNormalBorderColor);
      _loc2_.lineTo(bx,- y);
      _loc1_.drawQuarterCircle(_loc2_,dx,- y,br,0);
      _loc2_.lineTo(- dx,- y - br);
      _loc1_.drawQuarterCircle(_loc2_,- dx,- y,br,1);
      _loc2_.lineTo(- bx,y);
      _loc1_.drawQuarterCircle(_loc2_,- dx,y,br,2);
      _loc2_.lineTo(dx,y + br);
      _loc1_.drawQuarterCircle(_loc2_,dx,y,br,3);
      _loc2_.endFill();
      _loc3_.moveTo(x,y);
      _loc3_.beginGradientFill("linear",[_loc1_.grabberSideColor,_loc1_.grabberMiddleColor,_loc1_.grabberSideColor],[100,100,100],[0,128,255],{matrixType:"box",x:- x,y:- y,w:2 * x,h:1,r:0});
      _loc3_.lineTo(x,- y);
      _loc1_.drawQuarterCircle(_loc3_,dx,- y,r,0);
      _loc3_.lineTo(- dx,- y - r);
      _loc1_.drawQuarterCircle(_loc3_,- dx,- y,r,1);
      _loc3_.lineTo(- x,y);
      _loc1_.drawQuarterCircle(_loc3_,- dx,y,r,2);
      _loc3_.lineTo(dx,y + r);
      _loc1_.drawQuarterCircle(_loc3_,dx,y,r,3);
      _loc3_.endFill();
   }
};
p.updateField = function()
{
   var _loc1_ = this;
   var oldText = _loc1_.valueField.text;
   _loc1_.valueField.autoSize = "left";
   _loc1_.valueField.setTextFormat(_loc1_.valueTextFormat);
   _loc1_.valueField.embedFonts = _loc1_.embedValueFont;
   _loc1_.valueField.setNewTextFormat(_loc1_.valueTextFormat);
   _loc1_.valueField.text = "8";
   var h = Math.round(_loc1_.valueField._height);
   var x = _loc1_.fieldWidth;
   var y = h / 2;
   _loc1_.valueField.autoSize = "none";
   _loc1_.valueField._y = - y;
   _loc1_.valueField._width = x;
   _loc1_.valueField.text = oldText;
   var t = _loc1_.fieldBorderThickness;
   var bx = x + t;
   var by = y + t;
   var _loc2_ = _loc1_.fieldMC.backgroundMC;
   _loc2_.clear();
   var _loc3_ = _loc1_.fieldMC.fillMC;
   _loc3_.clear();
   var rnd = _loc1_.fieldRoundedness;
   if(rnd <= 0)
   {
      _loc2_.moveTo(- t,by);
      _loc2_.beginFill(_loc1_.fieldBorderColor);
      _loc2_.lineTo(bx,by);
      _loc2_.lineTo(bx,- by);
      _loc2_.lineTo(- t,- by);
      _loc2_.lineTo(- t,by);
      _loc2_.endFill();
      _loc3_.moveTo(0,y);
      _loc3_.beginFill(16711680);
      _loc3_.lineTo(x,y);
      _loc3_.lineTo(x,- y);
      _loc3_.lineTo(0,- y);
      _loc3_.lineTo(0,y);
      _loc3_.endFill();
   }
   else if(rnd >= 1)
   {
      _loc2_.moveTo(0,by);
      _loc2_.beginFill(_loc1_.fieldBorderColor);
      _loc2_.lineTo(x,by);
      _loc1_.drawHalfCircle(_loc2_,x,0,by,3);
      _loc2_.lineTo(0,- by);
      _loc1_.drawHalfCircle(_loc2_,0,0,by,1);
      _loc2_.endFill();
      _loc3_.moveTo(0,y);
      _loc3_.beginFill(16711680);
      _loc3_.lineTo(x,y);
      _loc1_.drawHalfCircle(_loc3_,x,0,y,3);
      _loc3_.lineTo(0,- y);
      _loc1_.drawHalfCircle(_loc3_,0,0,y,1);
      _loc3_.endFill();
   }
   else
   {
      var r = rnd * y;
      var br = r + t;
      var dy = y - r;
      _loc2_.moveTo(0,by);
      _loc2_.beginFill(_loc1_.fieldBorderColor);
      _loc2_.lineTo(x,by);
      _loc1_.drawQuarterCircle(_loc2_,x,dy,br,3);
      _loc2_.lineTo(x + br,- dy);
      _loc1_.drawQuarterCircle(_loc2_,x,- dy,br,0);
      _loc2_.lineTo(0,- by);
      _loc1_.drawQuarterCircle(_loc2_,0,- dy,br,1);
      _loc2_.lineTo(- br,dy);
      _loc1_.drawQuarterCircle(_loc2_,0,dy,br,2);
      _loc2_.endFill();
      _loc3_.moveTo(0,y);
      _loc3_.beginFill(16711680);
      _loc3_.lineTo(x,y);
      _loc1_.drawQuarterCircle(_loc3_,x,dy,r,3);
      _loc3_.lineTo(x + r,- dy);
      _loc1_.drawQuarterCircle(_loc3_,x,- dy,r,0);
      _loc3_.lineTo(0,- y);
      _loc1_.drawQuarterCircle(_loc3_,0,- dy,r,1);
      _loc3_.lineTo(- r,dy);
      _loc1_.drawQuarterCircle(_loc3_,0,dy,r,2);
      _loc3_.endFill();
   }
   _loc1_.labelOffset = t + rnd * y;
};
p.updateEnabled = function()
{
   var _loc1_ = this;
   if(_loc1_.userEnabled)
   {
      _loc1_.grabberMC.tabEnabled = true;
      _loc1_.grabberMC.onPress = _loc1_.grabberMC.onPressFunc;
      _loc1_.barMC.onPress = _loc1_.barMC.onPressFunc;
      _loc1_.valueField.type = "input";
      _loc1_.valueField.selectable = true;
      _loc1_.valueTextFormat.color = _loc1_.fieldNormalTextColor;
   }
   else
   {
      _loc1_.grabberMC.tabEnabled = false;
      _loc1_.grabberMC.onKillFocus();
      delete _loc1_.grabberMC.onPress;
      delete _loc1_.barMC.onPress;
      _loc1_.valueField.type = "dynamic";
      _loc1_.valueField.selectable = false;
      _loc1_.valueTextFormat.color = _loc1_.fieldDisabledTextColor;
   }
};
p.updateMaxCharsProperty = function()
{
   this.valueField.maxChars = this.maxChars;
};
p.updateTextColors = function()
{
   var _loc1_ = this;
   _loc1_.valueWhileEditingTextFormat.color = _loc1_.fieldActiveTextColor;
   _loc1_.labelAndUnitTextFormat.color = _loc1_.labelAndUnitsTextColor;
};
p.updateFieldBackground = function()
{
   var _loc1_ = this;
   if(!_loc1_.userEnabled)
   {
      _loc1_.fieldBackgroundColorObj.setRGB(_loc1_.fieldDisabledBackgroundColor);
   }
   else if(_loc1_.active)
   {
      _loc1_.fieldBackgroundColorObj.setRGB(_loc1_.fieldActiveBackgroundColor);
   }
   else
   {
      _loc1_.fieldBackgroundColorObj.setRGB(_loc1_.fieldNormalBackgroundColor);
   }
};
p.updateFieldTextFormat = function()
{
   var _loc1_ = this;
   if(_loc1_.active)
   {
      _loc1_.valueField.setTextFormat(_loc1_.valueWhileEditingTextFormat);
      _loc1_.valueField.embedFonts = _loc1_.embedValueWhileEditingFont;
      _loc1_.valueField.setNewTextFormat(_loc1_.valueWhileEditingTextFormat);
   }
   else
   {
      _loc1_.valueField.setTextFormat(_loc1_.valueTextFormat);
      _loc1_.valueField.embedFonts = _loc1_.embedValueFont;
      _loc1_.valueField.setNewTextFormat(_loc1_.valueTextFormat);
   }
};
p.updateActiveState = function()
{
   var _loc1_ = this;
   if(_loc1_.active)
   {
      Key.addListener(_loc1_.valueField);
      delete _loc1_.valueField.onChanged;
   }
   else
   {
      Key.removeListener(_loc1_.valueField);
      _loc1_.valueField.onChanged = _loc1_.valueField.onChangedFunc;
   }
};
p.updateLabelText = function()
{
   var _loc1_ = this;
   var _loc2_ = _loc1_.createEmptyMovieClip("labelTextMC",5);
   _loc1_.updateTextMC(_loc2_,_loc1_.labelText);
};
p.updateUnitsText = function()
{
   var _loc1_ = this;
   var _loc2_ = _loc1_.createEmptyMovieClip("unitsTextMC",6);
   _loc1_.updateTextMC(_loc2_,_loc1_.unitsText);
};
p.updateTextMC = function(wmc, textString)
{
   var _loc1_ = wmc;
   var oRad = this.solarSymbolOuterRadius;
   var iRad = this.solarSymbolInnerRadius;
   var yPos = this.solarSymbolYPosition;
   var sp = this.solarSymbolSpacing;
   var tf = this.labelAndUnitTextFormat;
   var ef = this.embedLabelAndUnitFont;
   var sr = this.scriptsSizeRatio;
   var sL = textString.split("<sol>");
   var _loc2_ = 0;
   if(sL[0].length != 0)
   {
      var mc = this.displayText(sL[0],{mc:_loc1_,textFormat:tf,embedFonts:ef,hAlign:"left",vAlign:"center",sizeRatio:sr});
      _loc2_ += mc.textWidth;
   }
   var _loc3_ = 1;
   while(_loc3_ < sL.length)
   {
      _loc2_ += sp;
      _loc1_.lineStyle(1,tf.color);
      this.drawCircle(_loc1_,_loc2_,yPos,oRad);
      _loc1_.lineStyle(undefined);
      _loc1_.beginFill(tf.color);
      this.drawCircle(_loc1_,_loc2_,yPos,iRad);
      _loc1_.endFill();
      _loc2_ += sp;
      if(sL[_loc3_].length != 0)
      {
         var mc = this.displayText(sL[_loc3_],{mc:_loc1_,textFormat:tf,embedFonts:ef,hAlign:"left",vAlign:"center",sizeRatio:sr,x:_loc2_});
         _loc2_ += mc.textWidth;
      }
      _loc3_ = _loc3_ + 1;
   }
   _loc1_.totalWidth = _loc2_;
};
p.updateFonts = function()
{
   var _loc1_ = this;
   var _loc2_ = _loc1_.attachMovie(_loc1_.fontsMovieClip,"fontsMC",123456,{_visible:false});
   if(_loc2_.value != undefined)
   {
      _loc1_.embedValueFont = _loc2_.value.embedFonts;
      _loc1_.valueTextFormat = _loc2_.value.getTextFormat();
   }
   else
   {
      _loc1_.embedValueFont = false;
      _loc1_.valueTextFormat = new TextFormat("Verdana",12,null,null,false);
   }
   _loc1_.valueTextFormat.align = "center";
   if(_loc2_.valueWhileEditing != undefined)
   {
      _loc1_.embedValueWhileEditingFont = _loc2_.valueWhileEditing.embedFonts;
      _loc1_.valueWhileEditingTextFormat = _loc2_.valueWhileEditing.getTextFormat();
   }
   else
   {
      _loc1_.embedValueWhileEditingFont = false;
      _loc1_.valueWhileEditingTextFormat = new TextFormat("Verdana",12,null,null,true);
   }
   _loc1_.valueWhileEditingTextFormat.align = "center";
   if(_loc2_.labelAndUnit != undefined)
   {
      _loc1_.embedLabelAndUnitFont = _loc2_.labelAndUnit.embedFonts;
      _loc1_.labelAndUnitTextFormat = _loc2_.labelAndUnit.getTextFormat();
   }
   else
   {
      _loc1_.embedLabelAndUnitFont = false;
      _loc1_.labelAndUnitTextFormat = new TextFormat("Verdana",12);
   }
   var _loc3_ = _loc1_.labelAndUnitTextFormat;
   var outerRadius = Math.round(_loc3_.size / 4);
   if(outerRadius < 3)
   {
      outerRadius = 3;
   }
   if(outerRadius < 5)
   {
      var innerRadius = 1;
   }
   else
   {
      var innerRadius = 0.3 * outerRadius;
   }
   _loc1_.solarSymbolOuterRadius = outerRadius;
   _loc1_.solarSymbolInnerRadius = innerRadius;
   _loc1_.solarSymbolYPosition = _loc3_.getTextExtent("8").height / 2 - outerRadius;
   _loc1_.solarSymbolSpacing = outerRadius + 2 * innerRadius;
   if(_loc3_.size <= 10)
   {
      _loc1_.scriptsSizeRatio = 1.25;
   }
   else if(_loc3_.size <= 12 || _loc3_.size == null)
   {
      _loc1_.scriptsSizeRatio = 1.3;
   }
   else if(_loc3_.size <= 14)
   {
      _loc1_.scriptsSizeRatio = 1.4;
   }
   else if(_loc3_.size <= 16)
   {
      _loc1_.scriptsSizeRatio = 1.5;
   }
   else if(_loc3_.size <= 20)
   {
      _loc1_.scriptsSizeRatio = 1.7;
   }
   else if(_loc3_.size >= 30)
   {
      _loc1_.scriptsSizeRatio = 2;
   }
};
p.displayText = function(textString, options)
{
   var _loc1_ = textString;
   _loc1_ = String(_loc1_);
   if(options.depth != undefined)
   {
      var mcDepth = options.depth;
   }
   else if(_global._displayedTextLastDepthUsed != undefined)
   {
      var mcDepth = ++_global._displayedTextLastDepthUsed;
   }
   else
   {
      var mcDepth = _global._displayedTextLastDepthUsed = 913001;
   }
   if(options.name != undefined)
   {
      var mcName = options.name;
   }
   else
   {
      var mcName = "_textWrapper_" + mcDepth;
   }
   if(options.mc != undefined)
   {
      var mc = options.mc.createEmptyMovieClip(mcName,mcDepth);
   }
   else
   {
      var mc = this.createEmptyMovieClip(mcName,mcDepth);
   }
   if(options.x != undefined)
   {
      mc._x = options.x;
   }
   if(options.y != undefined)
   {
      mc._y = options.y;
   }
   if(options.embedFonts != undefined)
   {
      var embedFonts = options.embedFonts;
   }
   else
   {
      var embedFonts = false;
   }
   if(options.textFormat != undefined)
   {
      var normalFormat = options.textFormat;
   }
   else
   {
      var normalFormat = new TextFormat(null,12);
   }
   var scriptFormat = new TextFormat();
   for(var x in normalFormat)
   {
      scriptFormat[x] = normalFormat[x];
   }
   if(options.sizeRatio != undefined)
   {
      scriptFormat.size = normalFormat.size / options.sizeRatio;
   }
   else
   {
      scriptFormat.size = normalFormat.size / 1.5;
   }
   mc.createTextField("_0",0,0,0,0,0);
   mc._0.autoSize = "left";
   mc._0.embedFonts = embedFonts;
   mc._0.setNewTextFormat(normalFormat);
   mc._0.text = "X";
   mc._0._visible = false;
   mc.createTextField("_1",1,0,0,0,0);
   mc._1.autoSize = "left";
   mc._1.embedFonts = embedFonts;
   mc._1.setNewTextFormat(scriptFormat);
   mc._1.text = "X";
   mc._1._visible = false;
   var lineHeight = mc._0._height;
   var scriptHeight = mc._1._height;
   if(options.superscriptPosition != undefined)
   {
      var superscriptDelta = - options.superscriptPosition;
   }
   else
   {
      var superscriptDelta = 0;
   }
   if(options.subscriptPosition != undefined)
   {
      var subscriptDelta = lineHeight - scriptHeight + options.subscriptPosition;
   }
   else
   {
      var subscriptDelta = lineHeight - scriptHeight;
   }
   if(options.extraSpacing != undefined)
   {
      var extraSpacing = options.extraSpacing;
   }
   else
   {
      var extraSpacing = 0.5;
   }
   var _loc2_ = [];
   var pos = 0;
   var iLimit = 0;
   var startInd = 0;
   do
   {
      var ind = _loc1_.indexOf("<su",startInd);
      if(ind == -1)
      {
         _loc2_.push({pos:pos,str:_loc1_});
      }
      else if(_loc1_.charAt(ind + 3) == "b" && _loc1_.charAt(ind + 4) == ">")
      {
         if(ind != 0)
         {
            _loc2_.push({pos:pos,str:_loc1_.substring(0,ind)});
         }
         _loc1_ = _loc1_.slice(ind + 5);
         pos = -1;
         var ind2 = _loc1_.indexOf("</sub>");
         if(ind2 != -1)
         {
            if(ind2 != 0)
            {
               _loc2_.push({pos:pos,str:_loc1_.substring(0,ind2)});
            }
            _loc1_ = _loc1_.slice(ind2 + 6);
            pos = 0;
         }
         startInd = 0;
      }
      else if(_loc1_.charAt(ind + 3) == "p" && _loc1_.charAt(ind + 4) == ">")
      {
         if(ind != 0)
         {
            _loc2_.push({pos:pos,str:_loc1_.substring(0,ind)});
         }
         _loc1_ = _loc1_.slice(ind + 5);
         pos = 1;
         var ind2 = _loc1_.indexOf("</sup>");
         if(ind2 != -1)
         {
            if(ind2 != 0)
            {
               _loc2_.push({pos:pos,str:_loc1_.substring(0,ind2)});
            }
            _loc1_ = _loc1_.slice(ind2 + 6);
            pos = 0;
         }
         startInd = 0;
      }
      else
      {
         startInd = ind + 3;
      }
      iLimit++;
   }
   while(ind != -1 && _loc1_.length > 0 && iLimit < 100);
   var tL = [];
   var totalWidth = 0;
   var depth = 2;
   var i = 0;
   while(i < _loc2_.length)
   {
      var name = "_" + depth;
      mc.createTextField(name,depth++,0,0,0,0);
      var tf = mc[name];
      tf.autoSize = "left";
      tf.embedFonts = embedFonts;
      tf.selectable = false;
      if(_loc2_[i].pos == 0)
      {
         var dy = 0;
         tf.setNewTextFormat(normalFormat);
      }
      else if(_loc2_[i].pos == 1)
      {
         var dy = superscriptDelta;
         tf.setNewTextFormat(scriptFormat);
      }
      else
      {
         var dy = subscriptDelta;
         tf.setNewTextFormat(scriptFormat);
      }
      tf.text = _loc2_[i].str;
      tL.push({tf:tf,dy:dy});
      totalWidth += tf.textWidth;
      i++;
   }
   totalWidth += extraSpacing * (tL.length - 1);
   if(options.hAlign == "left")
   {
      var x = -2;
   }
   else if(options.hAlign == "right")
   {
      var x = -2 - totalWidth;
   }
   else
   {
      var x = -2 - totalWidth / 2;
   }
   if(options.vAlign == "top")
   {
      var y = -2;
   }
   else if(options.vAlign == "bottom")
   {
      var y = - lineHeight + 2;
   }
   else
   {
      var y = (- lineHeight) / 2;
   }
   var i = 0;
   var _loc3_;
   while(i < tL.length)
   {
      _loc3_ = tL[i];
      _loc3_.tf._x = x;
      _loc3_.tf._y = y + _loc3_.dy;
      x += _loc3_.tf.textWidth + extraSpacing;
      i++;
   }
   mc.textWidth = totalWidth;
   return mc;
};
p.drawCircle = function(mc, x, y, r)
{
   var _loc1_ = r;
   var _loc2_ = y;
   var _loc3_ = x;
   mc.moveTo(_loc3_ + _loc1_,_loc2_);
   mc.curveTo(_loc3_ + _loc1_,_loc2_ - 0.4142 * _loc1_,_loc3_ + 0.7071 * _loc1_,_loc2_ - 0.7071 * _loc1_);
   mc.curveTo(_loc3_ + 0.4142 * _loc1_,_loc2_ - _loc1_,_loc3_,_loc2_ - _loc1_);
   mc.curveTo(_loc3_ - 0.4142 * _loc1_,_loc2_ - _loc1_,_loc3_ - 0.7071 * _loc1_,_loc2_ - 0.7071 * _loc1_);
   mc.curveTo(_loc3_ - _loc1_,_loc2_ - 0.4142 * _loc1_,_loc3_ - _loc1_,_loc2_);
   mc.curveTo(_loc3_ - _loc1_,_loc2_ + 0.4142 * _loc1_,_loc3_ - 0.7071 * _loc1_,_loc2_ + 0.7071 * _loc1_);
   mc.curveTo(_loc3_ - 0.4142 * _loc1_,_loc2_ + _loc1_,_loc3_,_loc2_ + _loc1_);
   mc.curveTo(_loc3_ + 0.4142 * _loc1_,_loc2_ + _loc1_,_loc3_ + 0.7071 * _loc1_,_loc2_ + 0.7071 * _loc1_);
   mc.curveTo(_loc3_ + _loc1_,_loc2_ + 0.4142 * _loc1_,_loc3_ + _loc1_,_loc2_);
};
p.drawQuarterCircle = function(mc, x, y, r, start, cw)
{
   var _loc1_ = r;
   var _loc2_ = y;
   var _loc3_ = x;
   switch(start)
   {
      case 0:
         if(cw)
         {
            mc.curveTo(_loc3_ + _loc1_,_loc2_ + 0.4142 * _loc1_,_loc3_ + 0.7071 * _loc1_,_loc2_ + 0.7071 * _loc1_);
            mc.curveTo(_loc3_ + 0.4142 * _loc1_,_loc2_ + _loc1_,_loc3_,_loc2_ + _loc1_);
         }
         else
         {
            mc.curveTo(_loc3_ + _loc1_,_loc2_ - 0.4142 * _loc1_,_loc3_ + 0.7071 * _loc1_,_loc2_ - 0.7071 * _loc1_);
            mc.curveTo(_loc3_ + 0.4142 * _loc1_,_loc2_ - _loc1_,_loc3_,_loc2_ - _loc1_);
         }
         break;
      case 1:
         if(cw)
         {
            mc.curveTo(_loc3_ + 0.4142 * _loc1_,_loc2_ - _loc1_,_loc3_ + 0.7071 * _loc1_,_loc2_ - 0.7071 * _loc1_);
            mc.curveTo(_loc3_ + _loc1_,_loc2_ - 0.4142 * _loc1_,_loc3_ + _loc1_,_loc2_);
         }
         else
         {
            mc.curveTo(_loc3_ - 0.4142 * _loc1_,_loc2_ - _loc1_,_loc3_ - 0.7071 * _loc1_,_loc2_ - 0.7071 * _loc1_);
            mc.curveTo(_loc3_ - _loc1_,_loc2_ - 0.4142 * _loc1_,_loc3_ - _loc1_,_loc2_);
         }
         break;
      case 2:
         if(cw)
         {
            mc.curveTo(_loc3_ - _loc1_,_loc2_ - 0.4142 * _loc1_,_loc3_ - 0.7071 * _loc1_,_loc2_ - 0.7071 * _loc1_);
            mc.curveTo(_loc3_ - 0.4142 * _loc1_,_loc2_ - _loc1_,_loc3_,_loc2_ - _loc1_);
         }
         else
         {
            mc.curveTo(_loc3_ - _loc1_,_loc2_ + 0.4142 * _loc1_,_loc3_ - 0.7071 * _loc1_,_loc2_ + 0.7071 * _loc1_);
            mc.curveTo(_loc3_ - 0.4142 * _loc1_,_loc2_ + _loc1_,_loc3_,_loc2_ + _loc1_);
         }
         break;
      case 3:
         if(cw)
         {
            mc.curveTo(_loc3_ - 0.4142 * _loc1_,_loc2_ + _loc1_,_loc3_ - 0.7071 * _loc1_,_loc2_ + 0.7071 * _loc1_);
            mc.curveTo(_loc3_ - _loc1_,_loc2_ + 0.4142 * _loc1_,_loc3_ - _loc1_,_loc2_);
         }
         else
         {
            mc.curveTo(_loc3_ + 0.4142 * _loc1_,_loc2_ + _loc1_,_loc3_ + 0.7071 * _loc1_,_loc2_ + 0.7071 * _loc1_);
            mc.curveTo(_loc3_ + _loc1_,_loc2_ + 0.4142 * _loc1_,_loc3_ + _loc1_,_loc2_);
         }
      default:
         return;
   }
};
p.drawHalfCircle = function(mc, x, y, r, start, cw)
{
   var _loc1_ = r;
   var _loc2_ = y;
   var _loc3_ = x;
   switch(start)
   {
      case 0:
         if(cw)
         {
            mc.curveTo(_loc3_ + _loc1_,_loc2_ + 0.4142 * _loc1_,_loc3_ + 0.7071 * _loc1_,_loc2_ + 0.7071 * _loc1_);
            mc.curveTo(_loc3_ + 0.4142 * _loc1_,_loc2_ + _loc1_,_loc3_,_loc2_ + _loc1_);
            mc.curveTo(_loc3_ - 0.4142 * _loc1_,_loc2_ + _loc1_,_loc3_ - 0.7071 * _loc1_,_loc2_ + 0.7071 * _loc1_);
            mc.curveTo(_loc3_ - _loc1_,_loc2_ + 0.4142 * _loc1_,_loc3_ - _loc1_,_loc2_);
         }
         else
         {
            mc.curveTo(_loc3_ + _loc1_,_loc2_ - 0.4142 * _loc1_,_loc3_ + 0.7071 * _loc1_,_loc2_ - 0.7071 * _loc1_);
            mc.curveTo(_loc3_ + 0.4142 * _loc1_,_loc2_ - _loc1_,_loc3_,_loc2_ - _loc1_);
            mc.curveTo(_loc3_ - 0.4142 * _loc1_,_loc2_ - _loc1_,_loc3_ - 0.7071 * _loc1_,_loc2_ - 0.7071 * _loc1_);
            mc.curveTo(_loc3_ - _loc1_,_loc2_ - 0.4142 * _loc1_,_loc3_ - _loc1_,_loc2_);
         }
         break;
      case 1:
         if(cw)
         {
            mc.curveTo(_loc3_ + 0.4142 * _loc1_,_loc2_ - _loc1_,_loc3_ + 0.7071 * _loc1_,_loc2_ - 0.7071 * _loc1_);
            mc.curveTo(_loc3_ + _loc1_,_loc2_ - 0.4142 * _loc1_,_loc3_ + _loc1_,_loc2_);
            mc.curveTo(_loc3_ + _loc1_,_loc2_ + 0.4142 * _loc1_,_loc3_ + 0.7071 * _loc1_,_loc2_ + 0.7071 * _loc1_);
            mc.curveTo(_loc3_ + 0.4142 * _loc1_,_loc2_ + _loc1_,_loc3_,_loc2_ + _loc1_);
         }
         else
         {
            mc.curveTo(_loc3_ - 0.4142 * _loc1_,_loc2_ - _loc1_,_loc3_ - 0.7071 * _loc1_,_loc2_ - 0.7071 * _loc1_);
            mc.curveTo(_loc3_ - _loc1_,_loc2_ - 0.4142 * _loc1_,_loc3_ - _loc1_,_loc2_);
            mc.curveTo(_loc3_ - _loc1_,_loc2_ + 0.4142 * _loc1_,_loc3_ - 0.7071 * _loc1_,_loc2_ + 0.7071 * _loc1_);
            mc.curveTo(_loc3_ - 0.4142 * _loc1_,_loc2_ + _loc1_,_loc3_,_loc2_ + _loc1_);
         }
         break;
      case 2:
         if(cw)
         {
            mc.curveTo(_loc3_ - _loc1_,_loc2_ - 0.4142 * _loc1_,_loc3_ - 0.7071 * _loc1_,_loc2_ - 0.7071 * _loc1_);
            mc.curveTo(_loc3_ - 0.4142 * _loc1_,_loc2_ - _loc1_,_loc3_,_loc2_ - _loc1_);
            mc.curveTo(_loc3_ + 0.4142 * _loc1_,_loc2_ - _loc1_,_loc3_ + 0.7071 * _loc1_,_loc2_ - 0.7071 * _loc1_);
            mc.curveTo(_loc3_ + _loc1_,_loc2_ - 0.4142 * _loc1_,_loc3_ + _loc1_,_loc2_);
         }
         else
         {
            mc.curveTo(_loc3_ - _loc1_,_loc2_ + 0.4142 * _loc1_,_loc3_ - 0.7071 * _loc1_,_loc2_ + 0.7071 * _loc1_);
            mc.curveTo(_loc3_ - 0.4142 * _loc1_,_loc2_ + _loc1_,_loc3_,_loc2_ + _loc1_);
            mc.curveTo(_loc3_ + 0.4142 * _loc1_,_loc2_ + _loc1_,_loc3_ + 0.7071 * _loc1_,_loc2_ + 0.7071 * _loc1_);
            mc.curveTo(_loc3_ + _loc1_,_loc2_ + 0.4142 * _loc1_,_loc3_ + _loc1_,_loc2_);
         }
         break;
      case 3:
         if(cw)
         {
            mc.curveTo(_loc3_ - 0.4142 * _loc1_,_loc2_ + _loc1_,_loc3_ - 0.7071 * _loc1_,_loc2_ + 0.7071 * _loc1_);
            mc.curveTo(_loc3_ - _loc1_,_loc2_ + 0.4142 * _loc1_,_loc3_ - _loc1_,_loc2_);
            mc.curveTo(_loc3_ - _loc1_,_loc2_ - 0.4142 * _loc1_,_loc3_ - 0.7071 * _loc1_,_loc2_ - 0.7071 * _loc1_);
            mc.curveTo(_loc3_ - 0.4142 * _loc1_,_loc2_ - _loc1_,_loc3_,_loc2_ - _loc1_);
         }
         else
         {
            mc.curveTo(_loc3_ + 0.4142 * _loc1_,_loc2_ + _loc1_,_loc3_ + 0.7071 * _loc1_,_loc2_ + 0.7071 * _loc1_);
            mc.curveTo(_loc3_ + _loc1_,_loc2_ + 0.4142 * _loc1_,_loc3_ + _loc1_,_loc2_);
            mc.curveTo(_loc3_ + _loc1_,_loc2_ - 0.4142 * _loc1_,_loc3_ + 0.7071 * _loc1_,_loc2_ - 0.7071 * _loc1_);
            mc.curveTo(_loc3_ + 0.4142 * _loc1_,_loc2_ - _loc1_,_loc3_,_loc2_ - _loc1_);
         }
      default:
         return;
   }
};
