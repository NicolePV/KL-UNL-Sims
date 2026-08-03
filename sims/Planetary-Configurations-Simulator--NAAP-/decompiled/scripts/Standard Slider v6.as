function StandardSliderClassV6()
{
   this.createEmptyMovieClip("barMC",15);
   this.createEmptyMovieClip("grabberMC",16);
   this.createEmptyMovieClip("fieldMC",17);
   this.createTextField("valueField",20,0,0,0,0);
   this.valueField.restrict = "0-9.Ee+\\-";
   this.valueField.onChangedFunc = function()
   {
      this._parent.activateField();
   };
   this.valueField.onKillFocus = function()
   {
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
   };
   this.valueField.onKeyDown = function()
   {
      if(Key.isDown(13))
      {
         this._parent.inactivateField();
         this._parent.setValue(parseFloat(this.text),true);
      }
   };
   this.barMC.tabEnabled = false;
   this.barMC.useHandCursor = false;
   this.barMC.onPressFunc = function()
   {
      var c = this._parent.controller;
      var mValue = c.getValueObjectFromValue(c.getValueFromParameter(this._parent._xmouse)).value;
      if(mValue < c.value)
      {
         this._parent.incrementValue(-1,true);
      }
      else if(mValue > c.value)
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
      var timeNow = getTimer();
      if(timeNow > this.waitTime)
      {
         var ticks = this._parent.continuousChangeRate * (timeNow - this.timeLast);
         var c = this._parent.controller;
         var mValueObj = c.getValueObjectFromValue(c.getValueFromParameter(this._parent._xmouse));
         if(mValueObj.value < c.value)
         {
            var nValueObj = c.getIncrementedValueObject(null,- ticks);
            if(nValueObj.value <= mValueObj.value)
            {
               this._parent.setValueByValueObject(mValueObj,true);
            }
            else
            {
               this._parent.setValueByValueObject(nValueObj,true);
            }
         }
         else if(mValueObj.value > c.value)
         {
            var nValueObj = c.getIncrementedValueObject(null,ticks);
            if(nValueObj.value >= mValueObj.value)
            {
               this._parent.setValueByValueObject(mValueObj,true);
            }
            else
            {
               this._parent.setValueByValueObject(nValueObj,true);
            }
         }
      }
      this.timeLast = timeNow;
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
      var c = this._parent.controller;
      if(Key.isDown(37))
      {
         var vObj = c.getIncrementedValueObject(null,-1);
         if(vObj.value != c.value)
         {
            this._parent.setValueByValueObject(vObj,true);
         }
      }
      else if(Key.isDown(39))
      {
         var vObj = c.getIncrementedValueObject(null,1);
         if(vObj.value != c.value)
         {
            this._parent.setValueByValueObject(vObj,true);
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
      var c = this._parent.controller;
      var vObj = c.getValueObjectFromValue(c.getValueFromParameter(this._parent._xmouse - this.xOffset));
      if(vObj.value != c.value)
      {
         this._parent.setValueByValueObject(vObj,true);
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
   var fL = this.functionsList;
   var uL = [];
   var i = 0;
   while(i < fL.length)
   {
      uL.push({name:fL[i],call:true});
      i++;
   }
   this.updateList = uL;
   var pL = this.propertiesList;
   var i = 0;
   while(i < pL.length)
   {
      this.watch(pL[i].property,this.registerChange,pL[i].functionIndices);
      i++;
   }
   this.update();
   var initObj = {};
   initObj.scalingMode = this.scalingMode;
   initObj.valueFormat = this.precisionMode;
   initObj.valueDigits = this.precision;
   initObj.minValue = this.minValue;
   initObj.maxValue = this.maxValue;
   if(this.showField)
   {
      initObj.minParameter = this.fieldWidth + this.barSpacing + this.barMargin;
   }
   else
   {
      initObj.minParameter = this.barSpacing + this.barMargin;
   }
   initObj.maxParameter = initObj.minParameter + this.sliderRange;
   initObj.value = this.initValue;
   this.controller = new SliderLogicClassV6(initObj);
   this.updateSynchronization();
   this.inactivateField();
}
var p = StandardSliderClassV6.prototype = new MovieClip();
Object.registerClass("Standard Slider v6",StandardSliderClassV6);
p.getValue = function()
{
   return this.controller.value;
};
p.setValue = function(arg, callChangeHandler)
{
   if(typeof arg == "number" && !isNaN(arg) && isFinite(arg))
   {
      this.controller.value = arg;
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
   this.updateSynchronization();
   if(callChangeHandler)
   {
      this._parent[this.changeHandler](this.controller.value);
   }
};
p.setValueByValueObject = function(vObj, callChangeHandler)
{
   this.controller.setValueByValueObject(vObj);
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
   var i = 0;
   while(i < iL.length)
   {
      this.updateList[iL[i]].call = true;
      i++;
   }
   return newVal;
};
p.update = function()
{
   var uL = this.updateList;
   var i = 0;
   while(i < uL.length)
   {
      if(uL[i].call)
      {
         this[uL[i].name]();
         uL[i].call = false;
      }
      i++;
   }
};
p.updateSynchronization = function()
{
   this.grabberMC._x = this.controller.parameter;
   this.valueField.text = this.controller.valueString;
};
p.updateParameterRange = function()
{
   if(this.showField)
   {
      var minP = this.fieldWidth + this.barSpacing + this.barMargin;
   }
   else
   {
      var minP = this.barSpacing + this.barMargin;
   }
   var maxP = minP + this.sliderRange;
   this.controller.setValueAndParameterRanges(null,null,minP,maxP);
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
   var y = this.barThickness / 2;
   var by = y + this.barBorderThickness;
   var x = this.sliderRange + 2 * this.barMargin;
   var rnd = this.barRoundedness;
   var mc = this.barMC;
   mc.clear();
   if(rnd <= 0)
   {
      var bx1 = - this.barBorderThickness;
      var bx2 = x + this.barBorderThickness;
      mc.moveTo(bx1,by);
      mc.beginFill(this.barBorderColor);
      mc.lineTo(bx2,by);
      mc.lineTo(bx2,- by);
      mc.lineTo(bx1,- by);
      mc.lineTo(bx1,by);
      mc.endFill();
      mc.moveTo(0,y);
      mc.beginGradientFill("linear",[this.barTopColor,this.barBottomColor],[100,100],[0,255],{matrixType:"box",x:0,y:- y,w:1,h:2 * y,r:1.5707963267948966});
      mc.lineTo(x,y);
      mc.lineTo(x,- y);
      mc.lineTo(0,- y);
      mc.lineTo(0,y);
      mc.endFill();
   }
   else if(rnd >= 1)
   {
      mc.moveTo(0,by);
      mc.beginFill(this.barBorderColor);
      mc.lineTo(x,by);
      this.drawHalfCircle(mc,x,0,by,3);
      mc.lineTo(0,- by);
      this.drawHalfCircle(mc,0,0,by,1);
      mc.endFill();
      mc.moveTo(0,y);
      mc.beginGradientFill("linear",[this.barTopColor,this.barBottomColor],[100,100],[0,255],{matrixType:"box",x:0,y:- y,w:1,h:2 * y,r:1.5707963267948966});
      mc.lineTo(x,y);
      this.drawHalfCircle(mc,x,0,y,3);
      mc.lineTo(0,- y);
      this.drawHalfCircle(mc,0,0,y,1);
      mc.endFill();
   }
   else
   {
      var r = y * rnd;
      var br = r + this.barBorderThickness;
      var dy = y - r;
      mc.moveTo(0,by);
      mc.beginFill(this.barBorderColor);
      mc.lineTo(x,by);
      this.drawQuarterCircle(mc,x,dy,br,3);
      mc.lineTo(x + br,- dy);
      this.drawQuarterCircle(mc,x,- dy,br,0);
      mc.lineTo(0,- by);
      this.drawQuarterCircle(mc,0,- dy,br,1);
      mc.lineTo(- br,dy);
      this.drawQuarterCircle(mc,0,dy,br,2);
      mc.endFill();
      mc.moveTo(0,y);
      mc.beginGradientFill("linear",[this.barTopColor,this.barBottomColor],[100,100],[0,255],{matrixType:"box",x:0,y:- y,w:1,h:2 * y,r:1.5707963267948966});
      mc.lineTo(x,y);
      this.drawQuarterCircle(mc,x,dy,r,3);
      mc.lineTo(x + r,- dy);
      this.drawQuarterCircle(mc,x,- dy,r,0);
      mc.lineTo(0,- y);
      this.drawQuarterCircle(mc,0,- dy,r,1);
      mc.lineTo(- r,dy);
      this.drawQuarterCircle(mc,0,dy,r,2);
      mc.endFill();
   }
};
p.updateGrabber = function()
{
   var x = this.grabberWidth / 2;
   var y = this.grabberHeight / 2;
   var rnd = this.grabberRoundedness;
   var tbmc = this.grabberMC.tabbedBorderMC;
   tbmc.clear();
   var nbmc = this.grabberMC.normalBorderMC;
   nbmc.clear();
   var fmc = this.grabberMC.fillMC;
   fmc.clear();
   if(rnd <= 0)
   {
      var bx = x + this.grabberTabbedBorderThickness;
      var by = y + this.grabberTabbedBorderThickness;
      tbmc.moveTo(bx,by);
      tbmc.beginFill(this.grabberTabbedBorderColor);
      tbmc.lineTo(bx,- by);
      tbmc.lineTo(- bx,- by);
      tbmc.lineTo(- bx,by);
      tbmc.lineTo(bx,by);
      tbmc.endFill();
      var bx = x + this.grabberNormalBorderThickness;
      var by = y + this.grabberNormalBorderThickness;
      nbmc.moveTo(bx,by);
      nbmc.beginFill(this.grabberNormalBorderColor);
      nbmc.lineTo(bx,- by);
      nbmc.lineTo(- bx,- by);
      nbmc.lineTo(- bx,by);
      nbmc.lineTo(bx,by);
      nbmc.endFill();
      fmc.moveTo(x,y);
      fmc.beginGradientFill("linear",[this.grabberSideColor,this.grabberMiddleColor,this.grabberSideColor],[100,100,100],[0,128,255],{matrixType:"box",x:- x,y:- y,w:2 * x,h:1,r:0});
      fmc.lineTo(x,- y);
      fmc.lineTo(- x,- y);
      fmc.lineTo(- x,y);
      fmc.lineTo(x,y);
      fmc.endFill();
   }
   else if(rnd >= 1)
   {
      var bx = x + this.grabberTabbedBorderThickness;
      tbmc.moveTo(bx,y);
      tbmc.beginFill(this.grabberTabbedBorderColor);
      tbmc.lineTo(bx,- y);
      this.drawHalfCircle(tbmc,0,- y,bx,0);
      tbmc.lineTo(- bx,y);
      this.drawHalfCircle(tbmc,0,y,bx,2);
      tbmc.endFill();
      var bx = x + this.grabberNormalBorderThickness;
      nbmc.moveTo(bx,y);
      nbmc.beginFill(this.grabberNormalBorderColor);
      nbmc.lineTo(bx,- y);
      this.drawHalfCircle(nbmc,0,- y,bx,0);
      nbmc.lineTo(- bx,y);
      this.drawHalfCircle(nbmc,0,y,bx,2);
      nbmc.endFill();
      fmc.moveTo(x,y);
      fmc.beginGradientFill("linear",[this.grabberSideColor,this.grabberMiddleColor,this.grabberSideColor],[100,100,100],[0,128,255],{matrixType:"box",x:- x,y:- y,w:2 * x,h:1,r:0});
      fmc.lineTo(x,- y);
      this.drawHalfCircle(fmc,0,- y,x,0);
      fmc.lineTo(- x,y);
      this.drawHalfCircle(fmc,0,y,x,2);
      fmc.endFill();
   }
   else
   {
      var r = x * rnd;
      var dx = x - r;
      var bx = x + this.grabberTabbedBorderThickness;
      var br = r + this.grabberTabbedBorderThickness;
      tbmc.moveTo(bx,y);
      tbmc.beginFill(this.grabberTabbedBorderColor);
      tbmc.lineTo(bx,- y);
      this.drawQuarterCircle(tbmc,dx,- y,br,0);
      tbmc.lineTo(- dx,- y - br);
      this.drawQuarterCircle(tbmc,- dx,- y,br,1);
      tbmc.lineTo(- bx,y);
      this.drawQuarterCircle(tbmc,- dx,y,br,2);
      tbmc.lineTo(dx,y + br);
      this.drawQuarterCircle(tbmc,dx,y,br,3);
      tbmc.endFill();
      var bx = x + this.grabberNormalBorderThickness;
      var br = r + this.grabberNormalBorderThickness;
      nbmc.moveTo(bx,y);
      nbmc.beginFill(this.grabberNormalBorderColor);
      nbmc.lineTo(bx,- y);
      this.drawQuarterCircle(nbmc,dx,- y,br,0);
      nbmc.lineTo(- dx,- y - br);
      this.drawQuarterCircle(nbmc,- dx,- y,br,1);
      nbmc.lineTo(- bx,y);
      this.drawQuarterCircle(nbmc,- dx,y,br,2);
      nbmc.lineTo(dx,y + br);
      this.drawQuarterCircle(nbmc,dx,y,br,3);
      nbmc.endFill();
      fmc.moveTo(x,y);
      fmc.beginGradientFill("linear",[this.grabberSideColor,this.grabberMiddleColor,this.grabberSideColor],[100,100,100],[0,128,255],{matrixType:"box",x:- x,y:- y,w:2 * x,h:1,r:0});
      fmc.lineTo(x,- y);
      this.drawQuarterCircle(fmc,dx,- y,r,0);
      fmc.lineTo(- dx,- y - r);
      this.drawQuarterCircle(fmc,- dx,- y,r,1);
      fmc.lineTo(- x,y);
      this.drawQuarterCircle(fmc,- dx,y,r,2);
      fmc.lineTo(dx,y + r);
      this.drawQuarterCircle(fmc,dx,y,r,3);
      fmc.endFill();
   }
};
p.updateField = function()
{
   var oldText = this.valueField.text;
   this.valueField.autoSize = "left";
   this.valueField.setTextFormat(this.valueTextFormat);
   this.valueField.embedFonts = this.embedValueFont;
   this.valueField.setNewTextFormat(this.valueTextFormat);
   this.valueField.text = "8";
   var h = Math.round(this.valueField._height);
   var x = this.fieldWidth;
   var y = h / 2;
   this.valueField.autoSize = "none";
   this.valueField._y = - y;
   this.valueField._width = x;
   this.valueField.text = oldText;
   var t = this.fieldBorderThickness;
   var bx = x + t;
   var by = y + t;
   var bmc = this.fieldMC.backgroundMC;
   bmc.clear();
   var fmc = this.fieldMC.fillMC;
   fmc.clear();
   var rnd = this.fieldRoundedness;
   if(rnd <= 0)
   {
      bmc.moveTo(- t,by);
      bmc.beginFill(this.fieldBorderColor);
      bmc.lineTo(bx,by);
      bmc.lineTo(bx,- by);
      bmc.lineTo(- t,- by);
      bmc.lineTo(- t,by);
      bmc.endFill();
      fmc.moveTo(0,y);
      fmc.beginFill(16711680);
      fmc.lineTo(x,y);
      fmc.lineTo(x,- y);
      fmc.lineTo(0,- y);
      fmc.lineTo(0,y);
      fmc.endFill();
   }
   else if(rnd >= 1)
   {
      bmc.moveTo(0,by);
      bmc.beginFill(this.fieldBorderColor);
      bmc.lineTo(x,by);
      this.drawHalfCircle(bmc,x,0,by,3);
      bmc.lineTo(0,- by);
      this.drawHalfCircle(bmc,0,0,by,1);
      bmc.endFill();
      fmc.moveTo(0,y);
      fmc.beginFill(16711680);
      fmc.lineTo(x,y);
      this.drawHalfCircle(fmc,x,0,y,3);
      fmc.lineTo(0,- y);
      this.drawHalfCircle(fmc,0,0,y,1);
      fmc.endFill();
   }
   else
   {
      var r = rnd * y;
      var br = r + t;
      var dy = y - r;
      bmc.moveTo(0,by);
      bmc.beginFill(this.fieldBorderColor);
      bmc.lineTo(x,by);
      this.drawQuarterCircle(bmc,x,dy,br,3);
      bmc.lineTo(x + br,- dy);
      this.drawQuarterCircle(bmc,x,- dy,br,0);
      bmc.lineTo(0,- by);
      this.drawQuarterCircle(bmc,0,- dy,br,1);
      bmc.lineTo(- br,dy);
      this.drawQuarterCircle(bmc,0,dy,br,2);
      bmc.endFill();
      fmc.moveTo(0,y);
      fmc.beginFill(16711680);
      fmc.lineTo(x,y);
      this.drawQuarterCircle(fmc,x,dy,r,3);
      fmc.lineTo(x + r,- dy);
      this.drawQuarterCircle(fmc,x,- dy,r,0);
      fmc.lineTo(0,- y);
      this.drawQuarterCircle(fmc,0,- dy,r,1);
      fmc.lineTo(- r,dy);
      this.drawQuarterCircle(fmc,0,dy,r,2);
      fmc.endFill();
   }
   this.labelOffset = t + rnd * y;
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
   var wmc = this.createEmptyMovieClip("labelTextMC",5);
   this.updateTextMC(wmc,this.labelText);
};
p.updateUnitsText = function()
{
   var wmc = this.createEmptyMovieClip("unitsTextMC",6);
   this.updateTextMC(wmc,this.unitsText);
};
p.updateTextMC = function(wmc, textString)
{
   var oRad = this.solarSymbolOuterRadius;
   var iRad = this.solarSymbolInnerRadius;
   var yPos = this.solarSymbolYPosition;
   var sp = this.solarSymbolSpacing;
   var tf = this.labelAndUnitTextFormat;
   var ef = this.embedLabelAndUnitFont;
   var sr = this.scriptsSizeRatio;
   var sL = textString.split("<sol>");
   var xCursor = 0;
   if(sL[0].length != 0)
   {
      var mc = this.displayText(sL[0],{mc:wmc,textFormat:tf,embedFonts:ef,hAlign:"left",vAlign:"center",sizeRatio:sr});
      xCursor += mc.textWidth;
   }
   var i = 1;
   while(i < sL.length)
   {
      xCursor += sp;
      wmc.lineStyle(1,tf.color);
      this.drawCircle(wmc,xCursor,yPos,oRad);
      wmc.lineStyle(undefined);
      wmc.beginFill(tf.color);
      this.drawCircle(wmc,xCursor,yPos,iRad);
      wmc.endFill();
      xCursor += sp;
      if(sL[i].length != 0)
      {
         var mc = this.displayText(sL[i],{mc:wmc,textFormat:tf,embedFonts:ef,hAlign:"left",vAlign:"center",sizeRatio:sr,x:xCursor});
         xCursor += mc.textWidth;
      }
      i++;
   }
   wmc.totalWidth = xCursor;
};
p.updateFonts = function()
{
   var mc = this.attachMovie(this.fontsMovieClip,"fontsMC",123456,{_visible:false});
   if(mc.value != undefined)
   {
      this.embedValueFont = mc.value.embedFonts;
      this.valueTextFormat = mc.value.getTextFormat();
   }
   else
   {
      this.embedValueFont = false;
      this.valueTextFormat = new TextFormat("Verdana",12,null,null,false);
   }
   this.valueTextFormat.align = "center";
   if(mc.valueWhileEditing != undefined)
   {
      this.embedValueWhileEditingFont = mc.valueWhileEditing.embedFonts;
      this.valueWhileEditingTextFormat = mc.valueWhileEditing.getTextFormat();
   }
   else
   {
      this.embedValueWhileEditingFont = false;
      this.valueWhileEditingTextFormat = new TextFormat("Verdana",12,null,null,true);
   }
   this.valueWhileEditingTextFormat.align = "center";
   if(mc.labelAndUnit != undefined)
   {
      this.embedLabelAndUnitFont = mc.labelAndUnit.embedFonts;
      this.labelAndUnitTextFormat = mc.labelAndUnit.getTextFormat();
   }
   else
   {
      this.embedLabelAndUnitFont = false;
      this.labelAndUnitTextFormat = new TextFormat("Verdana",12);
   }
   var tf = this.labelAndUnitTextFormat;
   var outerRadius = Math.round(tf.size / 4);
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
   this.solarSymbolOuterRadius = outerRadius;
   this.solarSymbolInnerRadius = innerRadius;
   this.solarSymbolYPosition = tf.getTextExtent("8").height / 2 - outerRadius;
   this.solarSymbolSpacing = outerRadius + 2 * innerRadius;
   if(tf.size <= 10)
   {
      this.scriptsSizeRatio = 1.25;
   }
   else if(tf.size <= 12 || tf.size == null)
   {
      this.scriptsSizeRatio = 1.3;
   }
   else if(tf.size <= 14)
   {
      this.scriptsSizeRatio = 1.4;
   }
   else if(tf.size <= 16)
   {
      this.scriptsSizeRatio = 1.5;
   }
   else if(tf.size <= 20)
   {
      this.scriptsSizeRatio = 1.7;
   }
   else if(tf.size >= 30)
   {
      this.scriptsSizeRatio = 2;
   }
};
p.displayText = function(textString, options)
{
   textString = String(textString);
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
   var aL = [];
   var pos = 0;
   var iLimit = 0;
   var startInd = 0;
   do
   {
      var ind = textString.indexOf("<su",startInd);
      if(ind == -1)
      {
         aL.push({pos:pos,str:textString});
      }
      else if(textString.charAt(ind + 3) == "b" && textString.charAt(ind + 4) == ">")
      {
         if(ind != 0)
         {
            aL.push({pos:pos,str:textString.substring(0,ind)});
         }
         textString = textString.slice(ind + 5);
         pos = -1;
         var ind2 = textString.indexOf("</sub>");
         if(ind2 != -1)
         {
            if(ind2 != 0)
            {
               aL.push({pos:pos,str:textString.substring(0,ind2)});
            }
            textString = textString.slice(ind2 + 6);
            pos = 0;
         }
         startInd = 0;
      }
      else if(textString.charAt(ind + 3) == "p" && textString.charAt(ind + 4) == ">")
      {
         if(ind != 0)
         {
            aL.push({pos:pos,str:textString.substring(0,ind)});
         }
         textString = textString.slice(ind + 5);
         pos = 1;
         var ind2 = textString.indexOf("</sup>");
         if(ind2 != -1)
         {
            if(ind2 != 0)
            {
               aL.push({pos:pos,str:textString.substring(0,ind2)});
            }
            textString = textString.slice(ind2 + 6);
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
   while(ind != -1 && textString.length > 0 && iLimit < 100);
   var tL = [];
   var totalWidth = 0;
   var depth = 2;
   var i = 0;
   while(i < aL.length)
   {
      var name = "_" + depth;
      mc.createTextField(name,depth++,0,0,0,0);
      var tf = mc[name];
      tf.autoSize = "left";
      tf.embedFonts = embedFonts;
      tf.selectable = false;
      if(aL[i].pos == 0)
      {
         var dy = 0;
         tf.setNewTextFormat(normalFormat);
      }
      else if(aL[i].pos == 1)
      {
         var dy = superscriptDelta;
         tf.setNewTextFormat(scriptFormat);
      }
      else
      {
         var dy = subscriptDelta;
         tf.setNewTextFormat(scriptFormat);
      }
      tf.text = aL[i].str;
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
   while(i < tL.length)
   {
      var t = tL[i];
      t.tf._x = x;
      t.tf._y = y + t.dy;
      x += t.tf.textWidth + extraSpacing;
      i++;
   }
   mc.textWidth = totalWidth;
   return mc;
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
