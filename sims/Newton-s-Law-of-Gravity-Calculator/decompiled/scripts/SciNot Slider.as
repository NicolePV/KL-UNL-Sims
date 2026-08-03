function SciNotSliderClass()
{
   this.createEmptyMovieClip("barMC",15);
   this.createEmptyMovieClip("grabberMC",16);
   this.createEmptyMovieClip("fieldMC",17);
   this.createEmptyMovieClip("valueDisplay",19);
   this.createTextField("valueField",20,0,0,0,0);
   this.attachMovie("Multiplier Buttons","multiplierButtons",49359);
   this.valueField.restrict = "0-9.Ee+\\-";
   this.valueField.hasFocus = false;
   this.valueField.onChangedFunc = function()
   {
      this._parent.activateField();
   };
   this.valueField.onKillFocus = function()
   {
      this.hasFocus = false;
      if(this._parent.active)
      {
         this._parent.inactivateField();
         if(this._parent.grabberMC.hitTest(_root._xmouse,_root._ymouse,true) || this._parent.barMC.hitTest(_root._xmouse,_root._ymouse,true))
         {
            this._parent.updateSynchronization();
         }
         else
         {
            this._parent.setValue(parseFloat(this.text),true);
         }
      }
      else
      {
         this._parent.updateSynchronization();
      }
   };
   this.valueField.onKeyDown = function()
   {
      if(Key.isDown(13))
      {
         this._parent.inactivateField();
         this._parent.setValue(parseFloat(this.text),true);
      }
   };
   this.valueField.onSetFocus = function()
   {
      this.hasFocus = true;
      this._parent.updateSynchronization();
   };
   this.barMC.tabEnabled = false;
   this.barMC.useHandCursor = false;
   this.barMC.onPressFunc = function()
   {
      var _loc2_ = this._parent.controller;
      var _loc3_ = _loc2_.getValueObjectFromValue(_loc2_.getValueFromParameter(this._parent._xmouse)).value;
      if(_loc3_ < _loc2_.value)
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
   this.barMC.onReleaseOutside = this.barMC.onRelease = function()
   {
      delete this.onEnterFrame;
   };
   this.barMC.onEnterFrameFunc = function()
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
         if(_loc2_.value < _loc3_.value)
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
   this.grabberMC._focusrect = false;
   this.grabberMC.onSetFocus = function()
   {
      this.normalBorderMC._visible = false;
      this.tabbedBorderMC._visible = true;
      this.onMouseDown = this.onKillFocus;
      this.onMouseMove = this.onKillFocus;
      this.onKeyDown = this.onKeyDownFunc;
   };
   this.grabberMC.onKillFocus = function()
   {
      this.normalBorderMC._visible = true;
      this.tabbedBorderMC._visible = false;
      delete this.onMouseDown;
      delete this.onMouseMove;
      delete this.onKeyDown;
   };
   this.grabberMC.onKeyDownFunc = function()
   {
      var _loc2_ = this._parent.controller;
      var _loc3_;
      if(Key.isDown(37))
      {
         _loc3_ = _loc2_.getIncrementedValueObject(null,-1);
         if(_loc3_.value != _loc2_.value)
         {
            this._parent.setValueByValueObject(_loc3_,true);
         }
      }
      else if(Key.isDown(39))
      {
         _loc3_ = _loc2_.getIncrementedValueObject(null,1);
         if(_loc3_.value != _loc2_.value)
         {
            this._parent.setValueByValueObject(_loc3_,true);
         }
      }
   };
   this.grabberMC.useHandCursor = false;
   this.grabberMC.onPressFunc = function()
   {
      this.xOffset = this._parent._xmouse - this._x;
      this.onMouseMove = this.onMouseMoveFunc;
   };
   this.grabberMC.onMouseMoveFunc = function()
   {
      var _loc2_ = this._parent.controller;
      var _loc3_ = _loc2_.getValueObjectFromValue(_loc2_.getValueFromParameter(this._parent._xmouse - this.xOffset));
      if(_loc3_.value != _loc2_.value)
      {
         this._parent.setValueByValueObject(_loc3_,true);
      }
      updateAfterEvent();
   };
   this.grabberMC.onRelease = this.grabberMC.onReleaseOutside = function()
   {
      delete this.onMouseMove;
   };
   this.grabberMC.createEmptyMovieClip("tabbedBorderMC",1);
   this.grabberMC.createEmptyMovieClip("normalBorderMC",2);
   this.grabberMC.createEmptyMovieClip("fillMC",3);
   this.grabberMC.tabbedBorderMC._visible = false;
   this.fieldMC.createEmptyMovieClip("backgroundMC",1);
   this.fieldMC.createEmptyMovieClip("fillMC",2);
   this.fieldBackgroundColorObj = new Color(this.fieldMC.fillMC);
   delete this.value;
   if(this.showField == undefined)
   {
      this.showField = true;
   }
   if(this.labelText == undefined)
   {
      this.labelText = "";
   }
   if(this.unitsText == undefined)
   {
      this.unitsText = "";
   }
   if(this.minValue == undefined)
   {
      this.minValue = 1;
   }
   if(this.maxValue == undefined)
   {
      this.maxValue = 10;
   }
   if(this.initValue == undefined)
   {
      this.initValue = 5;
   }
   if(this.scalingMode == undefined)
   {
      this.scalingMode = "linear";
   }
   if(this.precisionMode == undefined)
   {
      this.precisionMode = "fixed digits";
   }
   if(this.precision == undefined)
   {
      this.precision = 2;
   }
   if(this.userEnabled == undefined)
   {
      this.userEnabled = true;
   }
   if(this.maxChars == undefined)
   {
      this.maxChars = 5;
   }
   if(this.fieldWidth == undefined)
   {
      this.fieldWidth = 60;
   }
   if(this.barSpacing == undefined)
   {
      this.barSpacing = 40;
   }
   if(this.fontsMovieClip == undefined)
   {
      this.fontsMovieClip = "Slider Fonts v6";
   }
   if(this.labelAndUnitsTextColor == undefined)
   {
      this.labelAndUnitsTextColor = 0;
   }
   if(this.fieldNormalTextColor == undefined)
   {
      this.fieldNormalTextColor = 0;
   }
   if(this.fieldActiveTextColor == undefined)
   {
      this.fieldActiveTextColor = 0;
   }
   if(this.fieldDisabledTextColor == undefined)
   {
      this.fieldDisabledTextColor = 4210752;
   }
   if(this.fieldMargin == undefined)
   {
      this.fieldMargin = 5;
   }
   if(this.fieldRoundedness == undefined)
   {
      this.fieldRoundedness = 0.4;
   }
   if(this.fieldBorderThickness == undefined)
   {
      this.fieldBorderThickness = 1;
   }
   if(this.fieldBorderColor == undefined)
   {
      this.fieldBorderColor = 12632256;
   }
   if(this.fieldNormalBackgroundColor == undefined)
   {
      this.fieldNormalBackgroundColor = 16777215;
   }
   if(this.fieldActiveBackgroundColor == undefined)
   {
      this.fieldActiveBackgroundColor = 16777198;
   }
   if(this.fieldDisabledBackgroundColor == undefined)
   {
      this.fieldDisabledBackgroundColor = 16053492;
   }
   if(this.barMargin == undefined)
   {
      this.barMargin = 7;
   }
   if(this.barThickness == undefined)
   {
      this.barThickness = 6;
   }
   if(this.barRoundedness == undefined)
   {
      this.barRoundedness = 0.7;
   }
   if(this.barBorderThickness == undefined)
   {
      this.barBorderThickness = 1;
   }
   if(this.barBorderColor == undefined)
   {
      this.barBorderColor = 12632256;
   }
   if(this.barTopColor == undefined)
   {
      this.barTopColor = 16448250;
   }
   if(this.barBottomColor == undefined)
   {
      this.barBottomColor = 13684944;
   }
   if(this.grabberWidth == undefined)
   {
      this.grabberWidth = 9;
   }
   if(this.grabberHeight == undefined)
   {
      this.grabberHeight = 17;
   }
   if(this.grabberRoundedness == undefined)
   {
      this.grabberRoundedness = 0.8;
   }
   if(this.grabberNormalBorderThickness == undefined)
   {
      this.grabberNormalBorderThickness = 1;
   }
   if(this.grabberNormalBorderColor == undefined)
   {
      this.grabberNormalBorderColor = 12632256;
   }
   if(this.grabberTabbedBorderThickness == undefined)
   {
      this.grabberTabbedBorderThickness = 2;
   }
   if(this.grabberTabbedBorderColor == undefined)
   {
      this.grabberTabbedBorderColor = 11579568;
   }
   if(this.grabberMiddleColor == undefined)
   {
      this.grabberMiddleColor = 16053492;
   }
   if(this.grabberSideColor == undefined)
   {
      this.grabberSideColor = 14737632;
   }
   if(this.continuousChangeDelay == undefined)
   {
      this.continuousChangeDelay = 500;
   }
   if(this.continuousChangeRate == undefined)
   {
      this.continuousChangeRate = 0.05;
   }
   if(this.sliderRange == undefined)
   {
      if(this.showField)
      {
         this.sliderRange = this._width - this.fieldWidth - this.barSpacing - 2 * this.barMargin;
      }
      else
      {
         this.sliderRange = this._width - this.barSpacing - 2 * this.barMargin;
      }
      if(this.sliderRange < 3 * this.grabberWidth)
      {
         this.sliderRange = 3 * this.grabberWidth;
      }
   }
   this.placeholderMC._visible = false;
   this.placeholderMC.swapDepths(121212);
   this.placeholderMC.removeMovieClip();
   this._xscale = 100;
   this._yscale = 100;
   var _loc5_ = this.functionsList;
   var _loc9_ = [];
   var _loc3_ = 0;
   while(_loc3_ < _loc5_.length)
   {
      _loc9_.push({name:_loc5_[_loc3_],call:true});
      _loc3_ = _loc3_ + 1;
   }
   this.updateList = _loc9_;
   var _loc4_ = this.propertiesList;
   _loc3_ = 0;
   while(_loc3_ < _loc4_.length)
   {
      this.watch(_loc4_[_loc3_].property,this.registerChange,_loc4_[_loc3_].functionIndices);
      _loc3_ = _loc3_ + 1;
   }
   this.update();
   var _loc6_ = {};
   _loc6_.scalingMode = this.scalingMode;
   _loc6_.valueFormat = this.precisionMode;
   _loc6_.valueDigits = this.precision;
   _loc6_.minValue = this.minValue;
   _loc6_.maxValue = this.maxValue;
   if(this.showField)
   {
      _loc6_.minParameter = this.fieldWidth + this.barSpacing + this.barMargin;
   }
   else
   {
      _loc6_.minParameter = this.barSpacing + this.barMargin;
   }
   _loc6_.maxParameter = _loc6_.minParameter + this.sliderRange;
   _loc6_.value = this.initValue;
   this.controller = new SliderLogicClassV6(_loc6_);
   this.updateSynchronization();
   this.inactivateField();
}
var p = SciNotSliderClass.prototype = new MovieClip();
Object.registerClass("SciNot Slider",SciNotSliderClass);
p.doMultiplierReset = function()
{
   this.fullValue = this.multiplierBaseValue = this.controller.value;
   this.multiplier2Counter = 0;
   this.multiplier3Counter = 0;
};
p.getValue = function()
{
   return this.controller.value;
};
p.setValue = function(arg, callChangeHandler, skipMultiplierReset)
{
   if(typeof arg == "number" && !isNaN(arg) && isFinite(arg))
   {
      this.controller.value = arg;
   }
   if(!skipMultiplierReset)
   {
      this.doMultiplierReset();
   }
   this.updateSynchronization();
   if(callChangeHandler)
   {
      this._parent[this.changeHandler](this.controller.value);
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
   if(typeof ticks == "number" && !isNaN(ticks) && isFinite(ticks))
   {
      this.controller.incrementValue(ticks);
   }
   this.doMultiplierReset();
   this.updateSynchronization();
   if(callChangeHandler)
   {
      this._parent[this.changeHandler](this.controller.value);
   }
};
p.setValueByValueObject = function(vObj, callChangeHandler)
{
   this.controller.setValueByValueObject(vObj);
   this.doMultiplierReset();
   this.updateSynchronization();
   if(callChangeHandler)
   {
      this._parent[this.changeHandler](this.controller.value);
   }
};
p.activateField = function()
{
   this.active = true;
   this.updateFieldBackground();
   this.updateFieldTextFormat();
   this.updateActiveState();
};
p.inactivateField = function()
{
   this.active = false;
   this.updateFieldBackground();
   this.updateFieldTextFormat();
   this.updateActiveState();
};
p.functionsList = ["updateFonts","updateTextColors","updateEnabled","updateField","updateFieldTextFormat","updatePrecision","updateScalingMode","updateSliderRange","updateParameterRange","updateLabelText","updateUnitsText","updateActiveState","updateFieldBackground","updateMaxCharsProperty","updateGrabber","updateBar","updateLabelAndUnitsPositions","updateBarPosition","updateSynchronization","updateFieldVisibility"];
iL = [];
i = 0;
while(i < p.functionsList.length)
{
   iL[p.functionsList[i]] = i;
   i++;
}
p.propertiesList = [{property:"grabberWidth",functionIndices:[iL.updateGrabber]},{property:"grabberHeight",functionIndices:[iL.updateGrabber]},{property:"grabberRoundedness",functionIndices:[iL.updateGrabber]},{property:"grabberNormalBorderThickness",functionIndices:[iL.updateGrabber]},{property:"grabberNormalBorderColor",functionIndices:[iL.updateGrabber]},{property:"grabberTabbedBorderThickness",functionIndices:[iL.updateGrabber]},{property:"grabberTabbedBorderColor",functionIndices:[iL.updateGrabber]},{property:"grabberMiddleColor",functionIndices:[iL.updateGrabber]},{property:"grabberSideColor",functionIndices:[iL.updateGrabber]},{property:"sliderRange",functionIndices:[iL.updateParameterRange,iL.updateBar,iL.updateSynchronization]},{property:"labelText",functionIndices:[iL.updateLabelText,iL.updateLabelAndUnitsPositions]},{property:"unitsText",functionIndices:[iL.updateUnitsText,iL.updateLabelAndUnitsPositions]},{property:"minValue",functionIndices:[iL.updateSliderRange,iL.updateSynchronization]},{property:"maxValue",functionIndices:[iL
.updateSliderRange,iL.updateSynchronization]},{property:"scalingMode",functionIndices:[iL.updateScalingMode,iL.updateSynchronization]},{property:"precisionMode",functionIndices:[iL.updatePrecision,iL.updateSynchronization]},{property:"precision",functionIndices:[iL.updatePrecision,iL.updateSynchronization]},{property:"userEnabled",functionIndices:[iL.updateEnabled,iL.updateFieldTextFormat,iL.updateFieldBackground,iL.updateSynchronization]},{property:"maxChars",functionIndices:[iL.updateMaxCharsProperty]},{property:"fieldWidth",functionIndices:[iL.updateField,iL.updateParameterRange,iL.updateBarPosition,iL.updateLabelAndUnitsPositions,iL.updateSynchronization]},{property:"showField",functionIndices:[iL.updateParameterRange,iL.updateBarPosition,iL.updateLabelAndUnitsPositions,iL.updateSynchronization,iL.updateFieldVisibility]},{property:"barSpacing",functionIndices:[iL.updateParameterRange,iL.updateBarPosition,iL.updateSynchronization]},{property:"labelAndUnitsTextColor",functionIndices:[iL
.updateTextColors,iL.updateLabelText,iL.updateUnitsText,iL.updateLabelAndUnitsPositions]},{property:"fieldNormalTextColor",functionIndices:[iL.updateEnabled,iL.updateFieldTextFormat]},{property:"fieldActiveTextColor",functionIndices:[iL.updateTextColors,iL.updateFieldTextFormat]},{property:"fieldDisabledTextColor",functionIndices:[iL.updateEnabled,iL.updateFieldTextFormat]},{property:"fieldMargin",functionIndices:[iL.updateLabelAndUnitsPositions]},{property:"fieldRoundedness",functionIndices:[iL.updateField,iL.updateLabelAndUnitsPositions]},{property:"fieldBorderThickness",functionIndices:[iL.updateField,iL.updateLabelAndUnitsPositions]},{property:"fieldBorderColor",functionIndices:[iL.updateField]},{property:"fieldNormalBackgroundColor",functionIndices:[iL.updateFieldBackground]},{property:"fieldActiveBackgroundColor",functionIndices:[iL.updateFieldBackground]},{property:"fieldDisabledBackgroundColor",functionIndices:[iL.updateFieldBackground]},{property:"barMargin",functionIndices:[iL
.updateParameterRange,iL.updateBar,iL.updateSynchronization]},{property:"barThickness",functionIndices:[iL.updateBar]},{property:"barRoundedness",functionIndices:[iL.updateBar]},{property:"barBorderThickness",functionIndices:[iL.updateBar]},{property:"barBorderColor",functionIndices:[iL.updateBar]},{property:"barTopColor",functionIndices:[iL.updateBar]},{property:"barBottomColor",functionIndices:[iL.updateBar]},{property:"fontsMovieClip",functionIndices:[iL.updateFonts,iL.updateTextColors,iL.updateLabelText,iL.updateUnitsText,iL.updateField,iL.updateLabelAndUnitsPositions,iL.updateEnabled,iL.updateFieldTextFormat,iL.updateSynchronization]}];
p.registerChange = function(prop, oldVal, newVal, iL)
{
   var _loc2_ = 0;
   while(_loc2_ < iL.length)
   {
      this.updateList[iL[_loc2_]].call = true;
      _loc2_ = _loc2_ + 1;
   }
   return newVal;
};
p.update = function()
{
   var _loc3_ = this.updateList;
   var _loc2_ = 0;
   while(_loc2_ < _loc3_.length)
   {
      if(_loc3_[_loc2_].call)
      {
         this[_loc3_[_loc2_].name]();
         _loc3_[_loc2_].call = false;
      }
      _loc2_ = _loc2_ + 1;
   }
};
p.onMultiplierButtonPressed = function(power, increment)
{
   var _loc4_ = this.multiplier2Counter;
   var _loc3_ = this.multiplier3Counter;
   if(power == 2)
   {
      this.multiplier2Counter += increment;
   }
   else
   {
      if(power != 3)
      {
         trace("Warning, error in onMultiplierButtonPress");
         return undefined;
      }
      this.multiplier3Counter += increment;
   }
   var _loc2_ = Math.pow(3,this.multiplier3Counter) * Math.pow(2,this.multiplier2Counter) * this.multiplierBaseValue;
   if(_loc2_ > this.controller._maxV || _loc2_ < this.controller._minV)
   {
      trace("Warning, out of bounds in onMultiplierButtonPress");
      this.multiplier2Counter = _loc4_;
      this.multiplier3Counter = _loc3_;
   }
   else
   {
      this.fullValue = _loc2_;
      this.setValue(_loc2_,true,true);
   }
};
p.updateSynchronization = function()
{
   this.grabberMC._x = this.controller.parameter;
   var _loc7_ = Math.pow(3,this.multiplier3Counter) * Math.pow(2,this.multiplier2Counter + 1) * this.multiplierBaseValue;
   var _loc5_ = Math.pow(3,this.multiplier3Counter + 1) * Math.pow(2,this.multiplier2Counter) * this.multiplierBaseValue;
   var _loc4_ = Math.pow(3,this.multiplier3Counter) * Math.pow(2,this.multiplier2Counter - 1) * this.multiplierBaseValue;
   var _loc6_ = Math.pow(3,this.multiplier3Counter - 1) * Math.pow(2,this.multiplier2Counter) * this.multiplierBaseValue;
   this.multiplierButtons.timesTwoButton.setEnabled(_loc7_ <= this.controller._maxV);
   this.multiplierButtons.timesThreeButton.setEnabled(_loc5_ <= this.controller._maxV);
   this.multiplierButtons.oneHalfButton.setEnabled(_loc4_ >= this.controller._minV);
   this.multiplierButtons.oneThirdButton.setEnabled(_loc6_ >= this.controller._minV);
   var _loc2_ = (this.controller._valueObject.sig / Math.pow(10,this.controller._digs - 1)).toFixed(this.controller._digs - 1);
   var _loc3_ = this.controller._valueObject.mag.toString();
   if(this.valueField.hasFocus)
   {
      this.valueField.text = _loc3_ != "0" ? _loc2_ + "e" + _loc3_ : _loc2_;
      this.valueDisplay._visible = false;
   }
   else
   {
      this.valueDisplay._visible = true;
      this.displayText(_loc3_ != "0" ? _loc2_ + "×10<sup>" + _loc3_ + "</sup>" : _loc2_,{mc:this.valueDisplay,depth:10,textFormat:this.valueTextFormat,embedFonts:this.embedValueFont,hAlign:"center",vAlign:"center",sizeRatio:this.scriptsSizeRatio,x:this.valueField._x + this.valueField._width / 2});
      this.valueField.text = "";
   }
};
p.updateParameterRange = function()
{
   var _loc2_;
   if(this.showField)
   {
      _loc2_ = this.fieldWidth + this.barSpacing + this.barMargin;
   }
   else
   {
      _loc2_ = this.barSpacing + this.barMargin;
   }
   var _loc3_ = _loc2_ + this.sliderRange;
   this.controller.setValueAndParameterRanges(null,null,_loc2_,_loc3_);
};
p.updateSliderRange = function()
{
   this.controller.setValueAndParameterRanges(this.minValue,this.maxValue,null,null);
};
p.updateScalingMode = function()
{
   this.controller.setScalingMode(this.scalingMode);
};
p.updatePrecision = function()
{
   this.controller.setValueFormat(this.precisionMode,this.precision);
};
p.updateBarPosition = function()
{
   if(this.showField)
   {
      this.barMC._x = this.fieldWidth + this.barSpacing;
   }
   else
   {
      this.barMC._x = this.barSpacing;
   }
};
p.updateLabelAndUnitsPositions = function()
{
   if(this.showField)
   {
      this.labelTextMC._x = - this.fieldMargin - this.labelOffset - this.labelTextMC.totalWidth;
      this.unitsTextMC._x = this.fieldMargin + this.fieldWidth + this.labelOffset;
   }
   else
   {
      this.labelTextMC._x = - this.labelTextMC.totalWidth;
      this.unitsTextMC._x = 0;
   }
};
p.updateFieldVisibility = function()
{
   this.fieldMC._visible = this.showField;
   this.valueField._visible = this.showField;
};
p.updateBar = function()
{
   var _loc10_ = this.barThickness / 2;
   var _loc3_ = _loc10_ + this.barBorderThickness;
   var _loc7_ = this.sliderRange + 2 * this.barMargin;
   var _loc8_ = this.barRoundedness;
   var _loc2_ = this.barMC;
   _loc2_.clear();
   var _loc9_;
   var _loc11_;
   var _loc5_;
   var _loc6_;
   var _loc4_;
   if(_loc8_ <= 0)
   {
      _loc9_ = - this.barBorderThickness;
      _loc11_ = _loc7_ + this.barBorderThickness;
      _loc2_.moveTo(_loc9_,_loc3_);
      _loc2_.beginFill(this.barBorderColor);
      _loc2_.lineTo(_loc11_,_loc3_);
      _loc2_.lineTo(_loc11_,- _loc3_);
      _loc2_.lineTo(_loc9_,- _loc3_);
      _loc2_.lineTo(_loc9_,_loc3_);
      _loc2_.endFill();
      _loc2_.moveTo(0,_loc10_);
      _loc2_.beginGradientFill("linear",[this.barTopColor,this.barBottomColor],[100,100],[0,255],{matrixType:"box",x:0,y:- _loc10_,w:1,h:2 * _loc10_,r:1.5707963267948966});
      _loc2_.lineTo(_loc7_,_loc10_);
      _loc2_.lineTo(_loc7_,- _loc10_);
      _loc2_.lineTo(0,- _loc10_);
      _loc2_.lineTo(0,_loc10_);
      _loc2_.endFill();
   }
   else if(_loc8_ >= 1)
   {
      _loc2_.moveTo(0,_loc3_);
      _loc2_.beginFill(this.barBorderColor);
      _loc2_.lineTo(_loc7_,_loc3_);
      this.drawHalfCircle(_loc2_,_loc7_,0,_loc3_,3);
      _loc2_.lineTo(0,- _loc3_);
      this.drawHalfCircle(_loc2_,0,0,_loc3_,1);
      _loc2_.endFill();
      _loc2_.moveTo(0,_loc10_);
      _loc2_.beginGradientFill("linear",[this.barTopColor,this.barBottomColor],[100,100],[0,255],{matrixType:"box",x:0,y:- _loc10_,w:1,h:2 * _loc10_,r:1.5707963267948966});
      _loc2_.lineTo(_loc7_,_loc10_);
      this.drawHalfCircle(_loc2_,_loc7_,0,_loc10_,3);
      _loc2_.lineTo(0,- _loc10_);
      this.drawHalfCircle(_loc2_,0,0,_loc10_,1);
      _loc2_.endFill();
   }
   else
   {
      _loc5_ = _loc10_ * _loc8_;
      _loc6_ = _loc5_ + this.barBorderThickness;
      _loc4_ = _loc10_ - _loc5_;
      _loc2_.moveTo(0,_loc3_);
      _loc2_.beginFill(this.barBorderColor);
      _loc2_.lineTo(_loc7_,_loc3_);
      this.drawQuarterCircle(_loc2_,_loc7_,_loc4_,_loc6_,3);
      _loc2_.lineTo(_loc7_ + _loc6_,- _loc4_);
      this.drawQuarterCircle(_loc2_,_loc7_,- _loc4_,_loc6_,0);
      _loc2_.lineTo(0,- _loc3_);
      this.drawQuarterCircle(_loc2_,0,- _loc4_,_loc6_,1);
      _loc2_.lineTo(- _loc6_,_loc4_);
      this.drawQuarterCircle(_loc2_,0,_loc4_,_loc6_,2);
      _loc2_.endFill();
      _loc2_.moveTo(0,_loc10_);
      _loc2_.beginGradientFill("linear",[this.barTopColor,this.barBottomColor],[100,100],[0,255],{matrixType:"box",x:0,y:- _loc10_,w:1,h:2 * _loc10_,r:1.5707963267948966});
      _loc2_.lineTo(_loc7_,_loc10_);
      this.drawQuarterCircle(_loc2_,_loc7_,_loc4_,_loc5_,3);
      _loc2_.lineTo(_loc7_ + _loc5_,- _loc4_);
      this.drawQuarterCircle(_loc2_,_loc7_,- _loc4_,_loc5_,0);
      _loc2_.lineTo(0,- _loc10_);
      this.drawQuarterCircle(_loc2_,0,- _loc4_,_loc5_,1);
      _loc2_.lineTo(- _loc5_,_loc4_);
      this.drawQuarterCircle(_loc2_,0,_loc4_,_loc5_,2);
      _loc2_.endFill();
   }
};
p.updateGrabber = function()
{
   var _loc12_ = this.grabberWidth / 2;
   var _loc6_ = this.grabberHeight / 2;
   var _loc10_ = this.grabberRoundedness;
   var _loc4_ = this.grabberMC.tabbedBorderMC;
   _loc4_.clear();
   var _loc2_ = this.grabberMC.normalBorderMC;
   _loc2_.clear();
   var _loc3_ = this.grabberMC.fillMC;
   _loc3_.clear();
   var _loc11_;
   var _loc9_;
   var _loc7_;
   var _loc5_;
   var _loc8_;
   if(_loc10_ <= 0)
   {
      _loc11_ = _loc12_ + this.grabberTabbedBorderThickness;
      _loc9_ = _loc6_ + this.grabberTabbedBorderThickness;
      _loc4_.moveTo(_loc11_,_loc9_);
      _loc4_.beginFill(this.grabberTabbedBorderColor);
      _loc4_.lineTo(_loc11_,- _loc9_);
      _loc4_.lineTo(- _loc11_,- _loc9_);
      _loc4_.lineTo(- _loc11_,_loc9_);
      _loc4_.lineTo(_loc11_,_loc9_);
      _loc4_.endFill();
      _loc11_ = _loc12_ + this.grabberNormalBorderThickness;
      _loc9_ = _loc6_ + this.grabberNormalBorderThickness;
      _loc2_.moveTo(_loc11_,_loc9_);
      _loc2_.beginFill(this.grabberNormalBorderColor);
      _loc2_.lineTo(_loc11_,- _loc9_);
      _loc2_.lineTo(- _loc11_,- _loc9_);
      _loc2_.lineTo(- _loc11_,_loc9_);
      _loc2_.lineTo(_loc11_,_loc9_);
      _loc2_.endFill();
      _loc3_.moveTo(_loc12_,_loc6_);
      _loc3_.beginGradientFill("linear",[this.grabberSideColor,this.grabberMiddleColor,this.grabberSideColor],[100,100,100],[0,128,255],{matrixType:"box",x:- _loc12_,y:- _loc6_,w:2 * _loc12_,h:1,r:0});
      _loc3_.lineTo(_loc12_,- _loc6_);
      _loc3_.lineTo(- _loc12_,- _loc6_);
      _loc3_.lineTo(- _loc12_,_loc6_);
      _loc3_.lineTo(_loc12_,_loc6_);
      _loc3_.endFill();
   }
   else if(_loc10_ >= 1)
   {
      _loc11_ = _loc12_ + this.grabberTabbedBorderThickness;
      _loc4_.moveTo(_loc11_,_loc6_);
      _loc4_.beginFill(this.grabberTabbedBorderColor);
      _loc4_.lineTo(_loc11_,- _loc6_);
      this.drawHalfCircle(_loc4_,0,- _loc6_,_loc11_,0);
      _loc4_.lineTo(- _loc11_,_loc6_);
      this.drawHalfCircle(_loc4_,0,_loc6_,_loc11_,2);
      _loc4_.endFill();
      _loc11_ = _loc12_ + this.grabberNormalBorderThickness;
      _loc2_.moveTo(_loc11_,_loc6_);
      _loc2_.beginFill(this.grabberNormalBorderColor);
      _loc2_.lineTo(_loc11_,- _loc6_);
      this.drawHalfCircle(_loc2_,0,- _loc6_,_loc11_,0);
      _loc2_.lineTo(- _loc11_,_loc6_);
      this.drawHalfCircle(_loc2_,0,_loc6_,_loc11_,2);
      _loc2_.endFill();
      _loc3_.moveTo(_loc12_,_loc6_);
      _loc3_.beginGradientFill("linear",[this.grabberSideColor,this.grabberMiddleColor,this.grabberSideColor],[100,100,100],[0,128,255],{matrixType:"box",x:- _loc12_,y:- _loc6_,w:2 * _loc12_,h:1,r:0});
      _loc3_.lineTo(_loc12_,- _loc6_);
      this.drawHalfCircle(_loc3_,0,- _loc6_,_loc12_,0);
      _loc3_.lineTo(- _loc12_,_loc6_);
      this.drawHalfCircle(_loc3_,0,_loc6_,_loc12_,2);
      _loc3_.endFill();
   }
   else
   {
      _loc7_ = _loc12_ * _loc10_;
      _loc5_ = _loc12_ - _loc7_;
      _loc11_ = _loc12_ + this.grabberTabbedBorderThickness;
      _loc8_ = _loc7_ + this.grabberTabbedBorderThickness;
      _loc4_.moveTo(_loc11_,_loc6_);
      _loc4_.beginFill(this.grabberTabbedBorderColor);
      _loc4_.lineTo(_loc11_,- _loc6_);
      this.drawQuarterCircle(_loc4_,_loc5_,- _loc6_,_loc8_,0);
      _loc4_.lineTo(- _loc5_,- _loc6_ - _loc8_);
      this.drawQuarterCircle(_loc4_,- _loc5_,- _loc6_,_loc8_,1);
      _loc4_.lineTo(- _loc11_,_loc6_);
      this.drawQuarterCircle(_loc4_,- _loc5_,_loc6_,_loc8_,2);
      _loc4_.lineTo(_loc5_,_loc6_ + _loc8_);
      this.drawQuarterCircle(_loc4_,_loc5_,_loc6_,_loc8_,3);
      _loc4_.endFill();
      _loc11_ = _loc12_ + this.grabberNormalBorderThickness;
      _loc8_ = _loc7_ + this.grabberNormalBorderThickness;
      _loc2_.moveTo(_loc11_,_loc6_);
      _loc2_.beginFill(this.grabberNormalBorderColor);
      _loc2_.lineTo(_loc11_,- _loc6_);
      this.drawQuarterCircle(_loc2_,_loc5_,- _loc6_,_loc8_,0);
      _loc2_.lineTo(- _loc5_,- _loc6_ - _loc8_);
      this.drawQuarterCircle(_loc2_,- _loc5_,- _loc6_,_loc8_,1);
      _loc2_.lineTo(- _loc11_,_loc6_);
      this.drawQuarterCircle(_loc2_,- _loc5_,_loc6_,_loc8_,2);
      _loc2_.lineTo(_loc5_,_loc6_ + _loc8_);
      this.drawQuarterCircle(_loc2_,_loc5_,_loc6_,_loc8_,3);
      _loc2_.endFill();
      _loc3_.moveTo(_loc12_,_loc6_);
      _loc3_.beginGradientFill("linear",[this.grabberSideColor,this.grabberMiddleColor,this.grabberSideColor],[100,100,100],[0,128,255],{matrixType:"box",x:- _loc12_,y:- _loc6_,w:2 * _loc12_,h:1,r:0});
      _loc3_.lineTo(_loc12_,- _loc6_);
      this.drawQuarterCircle(_loc3_,_loc5_,- _loc6_,_loc7_,0);
      _loc3_.lineTo(- _loc5_,- _loc6_ - _loc7_);
      this.drawQuarterCircle(_loc3_,- _loc5_,- _loc6_,_loc7_,1);
      _loc3_.lineTo(- _loc12_,_loc6_);
      this.drawQuarterCircle(_loc3_,- _loc5_,_loc6_,_loc7_,2);
      _loc3_.lineTo(_loc5_,_loc6_ + _loc7_);
      this.drawQuarterCircle(_loc3_,_loc5_,_loc6_,_loc7_,3);
      _loc3_.endFill();
   }
};
p.updateField = function()
{
   var _loc13_ = this.valueField.text;
   this.valueField.autoSize = "left";
   this.valueField.setTextFormat(this.valueTextFormat);
   this.valueField.embedFonts = this.embedValueFont;
   this.valueField.setNewTextFormat(this.valueTextFormat);
   this.valueField.text = "8";
   var _loc14_ = Math.round(this.valueField._height);
   var _loc5_ = this.fieldWidth;
   var _loc4_ = _loc14_ / 2;
   this.valueField.autoSize = "none";
   this.valueField._y = - _loc4_;
   this.valueField._width = _loc5_;
   this.valueField.text = _loc13_;
   var _loc9_ = this.fieldBorderThickness;
   var _loc12_ = _loc5_ + _loc9_;
   var _loc6_ = _loc4_ + _loc9_;
   var _loc2_ = this.fieldMC.backgroundMC;
   _loc2_.clear();
   var _loc3_ = this.fieldMC.fillMC;
   _loc3_.clear();
   var _loc11_ = this.fieldRoundedness;
   var _loc8_;
   var _loc10_;
   var _loc7_;
   if(_loc11_ <= 0)
   {
      _loc2_.moveTo(- _loc9_,_loc6_);
      _loc2_.beginFill(this.fieldBorderColor);
      _loc2_.lineTo(_loc12_,_loc6_);
      _loc2_.lineTo(_loc12_,- _loc6_);
      _loc2_.lineTo(- _loc9_,- _loc6_);
      _loc2_.lineTo(- _loc9_,_loc6_);
      _loc2_.endFill();
      _loc3_.moveTo(0,_loc4_);
      _loc3_.beginFill(16711680);
      _loc3_.lineTo(_loc5_,_loc4_);
      _loc3_.lineTo(_loc5_,- _loc4_);
      _loc3_.lineTo(0,- _loc4_);
      _loc3_.lineTo(0,_loc4_);
      _loc3_.endFill();
   }
   else if(_loc11_ >= 1)
   {
      _loc2_.moveTo(0,_loc6_);
      _loc2_.beginFill(this.fieldBorderColor);
      _loc2_.lineTo(_loc5_,_loc6_);
      this.drawHalfCircle(_loc2_,_loc5_,0,_loc6_,3);
      _loc2_.lineTo(0,- _loc6_);
      this.drawHalfCircle(_loc2_,0,0,_loc6_,1);
      _loc2_.endFill();
      _loc3_.moveTo(0,_loc4_);
      _loc3_.beginFill(16711680);
      _loc3_.lineTo(_loc5_,_loc4_);
      this.drawHalfCircle(_loc3_,_loc5_,0,_loc4_,3);
      _loc3_.lineTo(0,- _loc4_);
      this.drawHalfCircle(_loc3_,0,0,_loc4_,1);
      _loc3_.endFill();
   }
   else
   {
      _loc8_ = _loc11_ * _loc4_;
      _loc10_ = _loc8_ + _loc9_;
      _loc7_ = _loc4_ - _loc8_;
      _loc2_.moveTo(0,_loc6_);
      _loc2_.beginFill(this.fieldBorderColor);
      _loc2_.lineTo(_loc5_,_loc6_);
      this.drawQuarterCircle(_loc2_,_loc5_,_loc7_,_loc10_,3);
      _loc2_.lineTo(_loc5_ + _loc10_,- _loc7_);
      this.drawQuarterCircle(_loc2_,_loc5_,- _loc7_,_loc10_,0);
      _loc2_.lineTo(0,- _loc6_);
      this.drawQuarterCircle(_loc2_,0,- _loc7_,_loc10_,1);
      _loc2_.lineTo(- _loc10_,_loc7_);
      this.drawQuarterCircle(_loc2_,0,_loc7_,_loc10_,2);
      _loc2_.endFill();
      _loc3_.moveTo(0,_loc4_);
      _loc3_.beginFill(16711680);
      _loc3_.lineTo(_loc5_,_loc4_);
      this.drawQuarterCircle(_loc3_,_loc5_,_loc7_,_loc8_,3);
      _loc3_.lineTo(_loc5_ + _loc8_,- _loc7_);
      this.drawQuarterCircle(_loc3_,_loc5_,- _loc7_,_loc8_,0);
      _loc3_.lineTo(0,- _loc4_);
      this.drawQuarterCircle(_loc3_,0,- _loc7_,_loc8_,1);
      _loc3_.lineTo(- _loc8_,_loc7_);
      this.drawQuarterCircle(_loc3_,0,_loc7_,_loc8_,2);
      _loc3_.endFill();
   }
   this.labelOffset = _loc9_ + _loc11_ * _loc4_;
};
p.updateEnabled = function()
{
   if(this.userEnabled)
   {
      this.grabberMC.tabEnabled = true;
      this.grabberMC.onPress = this.grabberMC.onPressFunc;
      this.barMC.onPress = this.barMC.onPressFunc;
      this.valueField.type = "input";
      this.valueField.selectable = true;
      this.valueTextFormat.color = this.fieldNormalTextColor;
   }
   else
   {
      this.grabberMC.tabEnabled = false;
      this.grabberMC.onKillFocus();
      delete this.grabberMC.onPress;
      delete this.barMC.onPress;
      this.valueField.type = "dynamic";
      this.valueField.selectable = false;
      this.valueTextFormat.color = this.fieldDisabledTextColor;
   }
};
p.updateMaxCharsProperty = function()
{
   this.valueField.maxChars = this.maxChars;
};
p.updateTextColors = function()
{
   this.valueWhileEditingTextFormat.color = this.fieldActiveTextColor;
   this.labelAndUnitTextFormat.color = this.labelAndUnitsTextColor;
};
p.updateFieldBackground = function()
{
   if(!this.userEnabled)
   {
      this.fieldBackgroundColorObj.setRGB(this.fieldDisabledBackgroundColor);
   }
   else if(this.active)
   {
      this.fieldBackgroundColorObj.setRGB(this.fieldActiveBackgroundColor);
   }
   else
   {
      this.fieldBackgroundColorObj.setRGB(this.fieldNormalBackgroundColor);
   }
};
p.updateFieldTextFormat = function()
{
   if(this.active)
   {
      this.valueField.setTextFormat(this.valueWhileEditingTextFormat);
      this.valueField.embedFonts = this.embedValueWhileEditingFont;
      this.valueField.setNewTextFormat(this.valueWhileEditingTextFormat);
   }
   else
   {
      this.valueField.setTextFormat(this.valueTextFormat);
      this.valueField.embedFonts = this.embedValueFont;
      this.valueField.setNewTextFormat(this.valueTextFormat);
   }
};
p.updateActiveState = function()
{
   if(this.active)
   {
      Key.addListener(this.valueField);
      delete this.valueField.onChanged;
   }
   else
   {
      Key.removeListener(this.valueField);
      this.valueField.onChanged = this.valueField.onChangedFunc;
   }
};
p.updateLabelText = function()
{
   var _loc2_ = this.createEmptyMovieClip("labelTextMC",5);
   this.updateTextMC(_loc2_,this.labelText);
};
p.updateUnitsText = function()
{
   var _loc2_ = this.createEmptyMovieClip("unitsTextMC",6);
   this.updateTextMC(_loc2_,this.unitsText);
};
p.updateTextMC = function(wmc, textString)
{
   var _loc18_ = this.solarSymbolOuterRadius;
   var _loc19_ = this.solarSymbolInnerRadius;
   var _loc8_ = this.solarSymbolYPosition;
   var _loc9_ = this.solarSymbolSpacing;
   var _loc6_ = this.labelAndUnitTextFormat;
   var _loc16_ = this.embedLabelAndUnitFont;
   var _loc17_ = this.scriptsSizeRatio;
   var _loc5_ = textString.split("<sol>");
   var _loc3_ = 0;
   var _loc7_;
   if(_loc5_[0].length != 0)
   {
      _loc7_ = this.displayText(_loc5_[0],{mc:wmc,textFormat:_loc6_,embedFonts:_loc16_,hAlign:"left",vAlign:"center",sizeRatio:_loc17_});
      _loc3_ += _loc7_.textWidth;
   }
   var _loc4_ = 1;
   while(_loc4_ < _loc5_.length)
   {
      _loc3_ += _loc9_;
      wmc.lineStyle(1,_loc6_.color);
      this.drawCircle(wmc,_loc3_,_loc8_,_loc18_);
      wmc.lineStyle(undefined);
      wmc.beginFill(_loc6_.color);
      this.drawCircle(wmc,_loc3_,_loc8_,_loc19_);
      wmc.endFill();
      _loc3_ += _loc9_;
      if(_loc5_[_loc4_].length != 0)
      {
         _loc7_ = this.displayText(_loc5_[_loc4_],{mc:wmc,textFormat:_loc6_,embedFonts:_loc16_,hAlign:"left",vAlign:"center",sizeRatio:_loc17_,x:_loc3_});
         _loc3_ += _loc7_.textWidth;
      }
      _loc4_ = _loc4_ + 1;
   }
   wmc.totalWidth = _loc3_;
};
p.updateFonts = function()
{
   var _loc2_ = this.attachMovie(this.fontsMovieClip,"fontsMC",123456,{_visible:false});
   if(_loc2_.value != undefined)
   {
      this.embedValueFont = _loc2_.value.embedFonts;
      this.valueTextFormat = _loc2_.value.getTextFormat();
   }
   else
   {
      this.embedValueFont = false;
      this.valueTextFormat = new TextFormat("Verdana",12,null,null,false);
   }
   this.valueTextFormat.align = "center";
   if(_loc2_.valueWhileEditing != undefined)
   {
      this.embedValueWhileEditingFont = _loc2_.valueWhileEditing.embedFonts;
      this.valueWhileEditingTextFormat = _loc2_.valueWhileEditing.getTextFormat();
   }
   else
   {
      this.embedValueWhileEditingFont = false;
      this.valueWhileEditingTextFormat = new TextFormat("Verdana",12,null,null,true);
   }
   this.valueWhileEditingTextFormat.align = "center";
   if(_loc2_.labelAndUnit != undefined)
   {
      this.embedLabelAndUnitFont = _loc2_.labelAndUnit.embedFonts;
      this.labelAndUnitTextFormat = _loc2_.labelAndUnit.getTextFormat();
   }
   else
   {
      this.embedLabelAndUnitFont = false;
      this.labelAndUnitTextFormat = new TextFormat("Verdana",12);
   }
   var _loc4_ = this.labelAndUnitTextFormat;
   var _loc3_ = Math.round(_loc4_.size / 4);
   if(_loc3_ < 3)
   {
      _loc3_ = 3;
   }
   var _loc5_;
   if(_loc3_ < 5)
   {
      _loc5_ = 1;
   }
   else
   {
      _loc5_ = 0.3 * _loc3_;
   }
   this.solarSymbolOuterRadius = _loc3_;
   this.solarSymbolInnerRadius = _loc5_;
   this.solarSymbolYPosition = _loc4_.getTextExtent("8").height / 2 - _loc3_;
   this.solarSymbolSpacing = _loc3_ + 2 * _loc5_;
   this.scriptsSizeRatio = 1.4;
};
p.displayText = function(textString, options)
{
   textString = String(textString);
   var _loc29_;
   var _loc0_;
   if(options.depth != undefined)
   {
      _loc29_ = options.depth;
   }
   else if(_global._displayedTextLastDepthUsed != undefined)
   {
      _loc29_ = ++_global._displayedTextLastDepthUsed;
   }
   else
   {
      _loc29_ = _global._displayedTextLastDepthUsed = 913001;
   }
   var _loc30_;
   if(options.name != undefined)
   {
      _loc30_ = options.name;
   }
   else
   {
      _loc30_ = "_textWrapper_" + _loc29_;
   }
   var _loc7_;
   if(options.mc != undefined)
   {
      _loc7_ = options.mc.createEmptyMovieClip(_loc30_,_loc29_);
   }
   else
   {
      _loc7_ = this.createEmptyMovieClip(_loc30_,_loc29_);
   }
   if(options.x != undefined)
   {
      _loc7_._x = options.x;
   }
   if(options.y != undefined)
   {
      _loc7_._y = options.y;
   }
   var _loc23_;
   if(options.embedFonts != undefined)
   {
      _loc23_ = options.embedFonts;
   }
   else
   {
      _loc23_ = false;
   }
   var _loc12_;
   if(options.textFormat != undefined)
   {
      _loc12_ = options.textFormat;
   }
   else
   {
      _loc12_ = new TextFormat(null,12);
   }
   var _loc13_ = new TextFormat();
   for(var _loc19_ in _loc12_)
   {
      _loc13_[_loc19_] = _loc12_[_loc19_];
   }
   if(options.sizeRatio != undefined)
   {
      _loc13_.size = _loc12_.size / options.sizeRatio;
   }
   else
   {
      _loc13_.size = _loc12_.size / 1.5;
   }
   _loc7_.createTextField("_0",0,0,0,0,0);
   _loc7_._0.autoSize = "left";
   _loc7_._0.embedFonts = _loc23_;
   _loc7_._0.setNewTextFormat(_loc12_);
   _loc7_._0.text = "X";
   _loc7_._0._visible = false;
   _loc7_.createTextField("_1",1,0,0,0,0);
   _loc7_._1.autoSize = "left";
   _loc7_._1.embedFonts = _loc23_;
   _loc7_._1.setNewTextFormat(_loc13_);
   _loc7_._1.text = "X";
   _loc7_._1._visible = false;
   var _loc28_ = _loc7_._0._height;
   var _loc31_ = _loc7_._1._height;
   var _loc25_;
   if(options.superscriptPosition != undefined)
   {
      _loc25_ = - options.superscriptPosition;
   }
   else
   {
      _loc25_ = 0;
   }
   var _loc26_;
   if(options.subscriptPosition != undefined)
   {
      _loc26_ = _loc28_ - _loc31_ + options.subscriptPosition;
   }
   else
   {
      _loc26_ = _loc28_ - _loc31_;
   }
   var _loc24_;
   if(options.extraSpacing != undefined)
   {
      _loc24_ = options.extraSpacing;
   }
   else
   {
      _loc24_ = 0.5;
   }
   var _loc4_ = [];
   var _loc15_ = 0;
   var _loc18_ = 0;
   var _loc9_ = 0;
   var _loc6_;
   do
   {
      var ind = textString.indexOf("<su",_loc9_);
      if(ind == -1)
      {
         _loc4_.push({pos:_loc15_,str:textString});
      }
      else if(textString.charAt(ind + 3) == "b" && textString.charAt(ind + 4) == ">")
      {
         if(ind != 0)
         {
            _loc4_.push({pos:_loc15_,str:textString.substring(0,ind)});
         }
         textString = textString.slice(ind + 5);
         _loc15_ = -1;
         _loc6_ = textString.indexOf("</sub>");
         if(_loc6_ != -1)
         {
            if(_loc6_ != 0)
            {
               _loc4_.push({pos:_loc15_,str:textString.substring(0,_loc6_)});
            }
            textString = textString.slice(_loc6_ + 6);
            _loc15_ = 0;
         }
         _loc9_ = 0;
      }
      else if(textString.charAt(ind + 3) == "p" && textString.charAt(ind + 4) == ">")
      {
         if(ind != 0)
         {
            _loc4_.push({pos:_loc15_,str:textString.substring(0,ind)});
         }
         textString = textString.slice(ind + 5);
         _loc15_ = 1;
         _loc6_ = textString.indexOf("</sup>");
         if(_loc6_ != -1)
         {
            if(_loc6_ != 0)
            {
               _loc4_.push({pos:_loc15_,str:textString.substring(0,_loc6_)});
            }
            textString = textString.slice(_loc6_ + 6);
            _loc15_ = 0;
         }
         _loc9_ = 0;
      }
      else
      {
         _loc9_ = ind + 3;
      }
      _loc18_ = _loc18_ + 1;
   }
   while(ind != -1 && textString.length > 0 && _loc18_ < 100);
   var _loc14_ = [];
   var _loc22_ = 0;
   var _loc17_ = 2;
   var _loc8_ = 0;
   var _loc11_;
   var _loc16_;
   var _loc21_;
   while(_loc8_ < _loc4_.length)
   {
      _loc11_ = "_" + _loc17_;
      _loc7_.createTextField(_loc11_,_loc17_++,0,0,0,0);
      _loc16_ = _loc7_[_loc11_];
      _loc16_.autoSize = "left";
      _loc16_.embedFonts = _loc23_;
      _loc16_.selectable = false;
      if(_loc4_[_loc8_].pos == 0)
      {
         _loc21_ = 0;
         _loc16_.setNewTextFormat(_loc12_);
      }
      else if(_loc4_[_loc8_].pos == 1)
      {
         _loc21_ = _loc25_;
         _loc16_.setNewTextFormat(_loc13_);
      }
      else
      {
         _loc21_ = _loc26_;
         _loc16_.setNewTextFormat(_loc13_);
      }
      _loc16_.text = _loc4_[_loc8_].str;
      _loc14_.push({tf:_loc16_,dy:_loc21_});
      _loc22_ += _loc16_.textWidth;
      _loc8_ = _loc8_ + 1;
   }
   _loc22_ += _loc24_ * (_loc14_.length - 1);
   var _loc19_;
   if(options.hAlign == "left")
   {
      _loc19_ = -2;
   }
   else if(options.hAlign == "right")
   {
      _loc19_ = -2 - _loc22_;
   }
   else
   {
      _loc19_ = -2 - _loc22_ / 2;
   }
   var _loc27_;
   if(options.vAlign == "top")
   {
      _loc27_ = -2;
   }
   else if(options.vAlign == "bottom")
   {
      _loc27_ = - _loc28_ + 2;
   }
   else
   {
      _loc27_ = (- _loc28_) / 2;
   }
   _loc8_ = 0;
   var _loc5_;
   while(_loc8_ < _loc14_.length)
   {
      _loc5_ = _loc14_[_loc8_];
      _loc5_.tf._x = _loc19_;
      _loc5_.tf._y = _loc27_ + _loc5_.dy;
      _loc19_ += _loc5_.tf.textWidth + _loc24_;
      _loc8_ = _loc8_ + 1;
   }
   _loc7_.textWidth = _loc22_;
   return _loc7_;
};
p.drawCircle = function(mc, x, y, r)
{
   mc.moveTo(x + r,y);
   mc.curveTo(x + r,y - 0.4142 * r,x + 0.7071 * r,y - 0.7071 * r);
   mc.curveTo(x + 0.4142 * r,y - r,x,y - r);
   mc.curveTo(x - 0.4142 * r,y - r,x - 0.7071 * r,y - 0.7071 * r);
   mc.curveTo(x - r,y - 0.4142 * r,x - r,y);
   mc.curveTo(x - r,y + 0.4142 * r,x - 0.7071 * r,y + 0.7071 * r);
   mc.curveTo(x - 0.4142 * r,y + r,x,y + r);
   mc.curveTo(x + 0.4142 * r,y + r,x + 0.7071 * r,y + 0.7071 * r);
   mc.curveTo(x + r,y + 0.4142 * r,x + r,y);
};
p.drawQuarterCircle = function(mc, x, y, r, start, cw)
{
   switch(start)
   {
      case 0:
         if(cw)
         {
            mc.curveTo(x + r,y + 0.4142 * r,x + 0.7071 * r,y + 0.7071 * r);
            mc.curveTo(x + 0.4142 * r,y + r,x,y + r);
         }
         else
         {
            mc.curveTo(x + r,y - 0.4142 * r,x + 0.7071 * r,y - 0.7071 * r);
            mc.curveTo(x + 0.4142 * r,y - r,x,y - r);
         }
         break;
      case 1:
         if(cw)
         {
            mc.curveTo(x + 0.4142 * r,y - r,x + 0.7071 * r,y - 0.7071 * r);
            mc.curveTo(x + r,y - 0.4142 * r,x + r,y);
         }
         else
         {
            mc.curveTo(x - 0.4142 * r,y - r,x - 0.7071 * r,y - 0.7071 * r);
            mc.curveTo(x - r,y - 0.4142 * r,x - r,y);
         }
         break;
      case 2:
         if(cw)
         {
            mc.curveTo(x - r,y - 0.4142 * r,x - 0.7071 * r,y - 0.7071 * r);
            mc.curveTo(x - 0.4142 * r,y - r,x,y - r);
         }
         else
         {
            mc.curveTo(x - r,y + 0.4142 * r,x - 0.7071 * r,y + 0.7071 * r);
            mc.curveTo(x - 0.4142 * r,y + r,x,y + r);
         }
         break;
      case 3:
         if(cw)
         {
            mc.curveTo(x - 0.4142 * r,y + r,x - 0.7071 * r,y + 0.7071 * r);
            mc.curveTo(x - r,y + 0.4142 * r,x - r,y);
         }
         else
         {
            mc.curveTo(x + 0.4142 * r,y + r,x + 0.7071 * r,y + 0.7071 * r);
            mc.curveTo(x + r,y + 0.4142 * r,x + r,y);
         }
      default:
         return;
   }
};
p.drawHalfCircle = function(mc, x, y, r, start, cw)
{
   switch(start)
   {
      case 0:
         if(cw)
         {
            mc.curveTo(x + r,y + 0.4142 * r,x + 0.7071 * r,y + 0.7071 * r);
            mc.curveTo(x + 0.4142 * r,y + r,x,y + r);
            mc.curveTo(x - 0.4142 * r,y + r,x - 0.7071 * r,y + 0.7071 * r);
            mc.curveTo(x - r,y + 0.4142 * r,x - r,y);
         }
         else
         {
            mc.curveTo(x + r,y - 0.4142 * r,x + 0.7071 * r,y - 0.7071 * r);
            mc.curveTo(x + 0.4142 * r,y - r,x,y - r);
            mc.curveTo(x - 0.4142 * r,y - r,x - 0.7071 * r,y - 0.7071 * r);
            mc.curveTo(x - r,y - 0.4142 * r,x - r,y);
         }
         break;
      case 1:
         if(cw)
         {
            mc.curveTo(x + 0.4142 * r,y - r,x + 0.7071 * r,y - 0.7071 * r);
            mc.curveTo(x + r,y - 0.4142 * r,x + r,y);
            mc.curveTo(x + r,y + 0.4142 * r,x + 0.7071 * r,y + 0.7071 * r);
            mc.curveTo(x + 0.4142 * r,y + r,x,y + r);
         }
         else
         {
            mc.curveTo(x - 0.4142 * r,y - r,x - 0.7071 * r,y - 0.7071 * r);
            mc.curveTo(x - r,y - 0.4142 * r,x - r,y);
            mc.curveTo(x - r,y + 0.4142 * r,x - 0.7071 * r,y + 0.7071 * r);
            mc.curveTo(x - 0.4142 * r,y + r,x,y + r);
         }
         break;
      case 2:
         if(cw)
         {
            mc.curveTo(x - r,y - 0.4142 * r,x - 0.7071 * r,y - 0.7071 * r);
            mc.curveTo(x - 0.4142 * r,y - r,x,y - r);
            mc.curveTo(x + 0.4142 * r,y - r,x + 0.7071 * r,y - 0.7071 * r);
            mc.curveTo(x + r,y - 0.4142 * r,x + r,y);
         }
         else
         {
            mc.curveTo(x - r,y + 0.4142 * r,x - 0.7071 * r,y + 0.7071 * r);
            mc.curveTo(x - 0.4142 * r,y + r,x,y + r);
            mc.curveTo(x + 0.4142 * r,y + r,x + 0.7071 * r,y + 0.7071 * r);
            mc.curveTo(x + r,y + 0.4142 * r,x + r,y);
         }
         break;
      case 3:
         if(cw)
         {
            mc.curveTo(x - 0.4142 * r,y + r,x - 0.7071 * r,y + 0.7071 * r);
            mc.curveTo(x - r,y + 0.4142 * r,x - r,y);
            mc.curveTo(x - r,y - 0.4142 * r,x - 0.7071 * r,y - 0.7071 * r);
            mc.curveTo(x - 0.4142 * r,y - r,x,y - r);
         }
         else
         {
            mc.curveTo(x + 0.4142 * r,y + r,x + 0.7071 * r,y + 0.7071 * r);
            mc.curveTo(x + r,y + 0.4142 * r,x + r,y);
            mc.curveTo(x + r,y - 0.4142 * r,x + 0.7071 * r,y - 0.7071 * r);
            mc.curveTo(x + 0.4142 * r,y - r,x,y - r);
         }
      default:
         return;
   }
};
