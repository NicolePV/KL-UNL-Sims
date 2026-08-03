package variableStarPhotometryAnalyzer_fla
{
   import adobe.utils.*;
   import edu.unl.astro.starField.*;
   import edu.unl.astro.utils.Plot;
   import edu.unl.astro.utils.PlotSeries;
   import fl.controls.Button;
   import fl.controls.CheckBox;
   import fl.controls.RadioButton;
   import fl.controls.RadioButtonGroup;
   import fl.controls.TextInput;
   import fl.data.DataProvider;
   import flash.accessibility.*;
   import flash.display.*;
   import flash.errors.*;
   import flash.events.*;
   import flash.external.*;
   import flash.filters.*;
   import flash.geom.*;
   import flash.media.*;
   import flash.net.*;
   import flash.printing.*;
   import flash.system.*;
   import flash.text.*;
   import flash.ui.*;
   import flash.utils.*;
   import flash.xml.*;
   
   public dynamic class MainTimeline extends MovieClip
   {
      
      public var comparisonStar:Object;
      
      public var settingsLoader:URLLoader;
      
      public var lightcurvePlot:Plot;
      
      public var plotTypeRadioButton0:RadioButton;
      
      public var outOfBoundsCursorPosition:Number;
      
      public var undoLastZoomButton:Button;
      
      public var comparisonStarColor:uint;
      
      public var plotTypeRadioButton1:RadioButton;
      
      public var settingsFile:String;
      
      public var zoomIn3TimesButton:Button;
      
      public var periodLinesColor:uint;
      
      public var clickToBeginMC:MovieClip;
      
      public var periodAtRightMC:MovieClip;
      
      public var periodLinesAlpha:Number;
      
      public var showCrosshairCheckBox:CheckBox;
      
      public var outOfBoundsCursorAlpha:Number;
      
      public var pdmPlotWidth:Number;
      
      public var backgroundMargin:uint;
      
      public var showDifferenceToolCheckBox:CheckBox;
      
      public var pixelMask:PixelMask;
      
      public var periodLinesSP:Sprite;
      
      public var starsList:Array;
      
      public var outOfBoundsSnapMargin:Number;
      
      public var embedItalicVerdanaField:TextField;
      
      public var periodCursorMode:int;
      
      public var periodCursorThickness:Number;
      
      public var activePeriodCursorAlpha:Number;
      
      public var periodCursorModeAtDraggingStart:int;
      
      public var pdmSeries:PlotSeries;
      
      public var periodAtLeftMC:MovieClip;
      
      public var starHalosContainerSP:Sprite;
      
      public var periodDraggingXOffset:Number;
      
      public var periodAtDraggingStart:Number;
      
      public var gammaTF2:GammaTransferFunction;
      
      public var dataGenerationDone:Boolean;
      
      public var observationsList:Array;
      
      public var inactiveTextInputFormat:TextFormat;
      
      public var activeTextInputFormat:TextFormat;
      
      public var gammaTF1:GammaTransferFunction;
      
      public var periodCursorSP:Sprite;
      
      public var loadingInfoMC:MovieClip;
      
      public var maxPDMPeriod:Number;
      
      public var periodCursorColor:uint;
      
      public var settingsXML:XML;
      
      public var periodCursorAlpha:Number;
      
      public var crosshairMC:MovieClip;
      
      public var periodPointer:MovieClip;
      
      public var hiddenStarField:StarField;
      
      public var pdmPlotHeight:Number;
      
      public var comparisonsList:Array;
      
      public var plotTypeRadioButtonGroup:RadioButtonGroup;
      
      public var deltaMagOverlay:DeltaMagOverlay;
      
      public var periodLinesThickness:Number;
      
      public var minEpoch:Number;
      
      public var lightcurveSeries:PlotSeries;
      
      public var pdmPlot:Plot;
      
      public var maxEpoch:Number;
      
      public var minTimePlotValue:Number;
      
      public var zoomOutButton:Button;
      
      public var featuredStar:Object;
      
      public var featuredStarColor:uint;
      
      public const periodPrecision:uint = 4;
      
      public var period:Number;
      
      public var pdmParameters:Object;
      
      public var starField:StarField;
      
      public var maxTimePlotValue:Number;
      
      public var periodTextInput:TextInput;
      
      public var zoomOut3TimesButton:Button;
      
      public var minPDMPeriod:Number;
      
      public var dataGenerationParameters:Object;
      
      public var lastPDMZoomRange:Object;
      
      public var inactivePeriodCursorAlpha:Number;
      
      public function MainTimeline()
      {
         super();
         addFrameScript(0,frame1);
         __setProp_undoLastZoomButton_Scene1_Layer2_1();
         __setProp_showCrosshairCheckBox_Scene1_Layer2_1();
         __setProp_zoomOutButton_Scene1_Layer2_1();
         __setProp_periodTextInput_Scene1_Layer2_1();
         __setProp_plotTypeRadioButton1_Scene1_Layer2_1();
         __setProp_showDifferenceToolCheckBox_Scene1_Layer2_1();
         __setProp_plotTypeRadioButton0_Scene1_Layer2_1();
         __setProp_zoomIn3TimesButton_Scene1_Layer2_1();
         __setProp_zoomOut3TimesButton_Scene1_Layer2_1();
      }
      
      public function onZoomIn3TimesButtonPressed(... rest) : void
      {
         pdmZoomByMultiple(1 / 3);
      }
      
      internal function __setProp_showDifferenceToolCheckBox_Scene1_Layer2_1() : *
      {
         try
         {
            showDifferenceToolCheckBox["componentInspectorSetting"] = true;
         }
         catch(e:Error)
         {
         }
         showDifferenceToolCheckBox.enabled = true;
         showDifferenceToolCheckBox.label = "show difference tool";
         showDifferenceToolCheckBox.labelPlacement = "right";
         showDifferenceToolCheckBox.selected = false;
         showDifferenceToolCheckBox.visible = true;
         try
         {
            showDifferenceToolCheckBox["componentInspectorSetting"] = false;
         }
         catch(e:Error)
         {
         }
      }
      
      public function generateDataFunc(... rest) : void
      {
         var _loc2_:Number = NaN;
         var _loc3_:int = 0;
         var _loc4_:Number = NaN;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:Object = null;
         var _loc8_:Object = null;
         var _loc9_:Object = null;
         _loc2_ = getTimer();
         _loc4_ = dataGenerationParameters.totalTimeTaken / dataGenerationParameters.totalFields;
         if(isNaN(_loc4_) || !isFinite(_loc4_) || _loc4_ <= 0)
         {
            _loc4_ = 20;
         }
         _loc5_ = Math.ceil(dataGenerationParameters.targetTime / _loc4_);
         if(_loc5_ < 0)
         {
            _loc5_ = 1;
         }
         _loc6_ = dataGenerationParameters.currFieldIndex + _loc5_;
         if(_loc6_ > observationsList.length)
         {
            _loc6_ = int(observationsList.length);
         }
         _loc3_ = int(dataGenerationParameters.currFieldIndex);
         while(_loc3_ < _loc6_)
         {
            _loc7_ = observationsList[_loc3_];
            hiddenStarField.setEpochAndNoiseSeed(_loc7_.epoch,_loc7_.noiseSeed);
            for each(_loc8_ in starsList)
            {
               pixelMask.left = _loc8_.x - pixelMask.radius;
               pixelMask.top = _loc8_.y - pixelMask.radius;
               _loc9_ = hiddenStarField.getStatistics(pixelMask);
               _loc8_.dataList.push(_loc9_.totalCounts - _loc9_.totalPixels * starField.noiseMean);
            }
            _loc3_++;
         }
         dataGenerationParameters.currFieldIndex = _loc3_;
         dataGenerationParameters.timeTaken += getTimer() - _loc2_;
         dataGenerationParameters.totalFields += _loc5_;
         if(dataGenerationParameters.currFieldIndex >= observationsList.length)
         {
            dataGenerationDone = true;
            removeEventListener(Event.ENTER_FRAME,generateDataFunc);
            loadingInfoMC.visible = false;
            starField.visible = true;
            updateCrosshair();
         }
         else
         {
            loadingInfoMC.visible = true;
            loadingInfoMC.statusField.text = (100 * dataGenerationParameters.currFieldIndex / observationsList.length).toFixed(1) + "% done";
         }
      }
      
      public function pdmUndoLastZoom(... rest) : void
      {
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc4_:Object = null;
         _loc2_ = Number(lastPDMZoomRange.min);
         _loc3_ = Number(lastPDMZoomRange.max);
         _loc4_ = pdmPlot.getXAxisRange();
         lastPDMZoomRange.min = _loc4_.min;
         lastPDMZoomRange.max = _loc4_.max;
         pdmPlot.setXAxisRange(_loc2_,_loc3_);
         repositionPeriodPointer();
         updateZoomButtonStates();
      }
      
      public function updateZoomButtonStates() : void
      {
         var _loc1_:Object = null;
         _loc1_ = pdmPlot.getXAxisRange();
         zoomOutButton.enabled = zoomOut3TimesButton.enabled = !(_loc1_.min == minPDMPeriod && _loc1_.max == maxPDMPeriod);
         zoomIn3TimesButton.enabled = _loc1_.max - _loc1_.min > pdmPlot.xZoomRangeLimit + 1e-12;
      }
      
      public function updatePeriodAndPhases() : void
      {
         var _loc1_:int = 0;
         var _loc2_:Object = null;
         var _loc3_:Object = null;
         var _loc4_:Number = NaN;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc9_:Number = NaN;
         repositionPeriodPointer();
         periodTextInput.text = period.toFixed(periodPrecision);
         periodTextInput.setSelection(periodTextInput.selectionEndIndex,periodTextInput.selectionEndIndex);
         _loc1_ = 0;
         while(_loc1_ < lightcurveSeries.dataProvider.length)
         {
            _loc2_ = lightcurveSeries.dataProvider.getItemAt(_loc1_);
            _loc2_.phase = (_loc2_.epoch / period % 1 + 1) % 1;
            _loc1_++;
         }
         if(lightcurveSeries.xAxisPropertyName == "phase")
         {
            lightcurvePlot.update();
         }
         periodLinesSP.graphics.clear();
         periodLinesSP.graphics.lineStyle(periodLinesThickness,periodLinesColor,periodLinesAlpha);
         _loc3_ = lightcurvePlot.getPlotDimensions();
         _loc4_ = _loc3_.width / (maxTimePlotValue - minTimePlotValue);
         _loc5_ = Math.ceil(minTimePlotValue / period);
         _loc6_ = _loc5_ + Math.ceil((maxTimePlotValue - minTimePlotValue) / period);
         _loc8_ = lightcurvePlot.y - _loc3_.height;
         _loc9_ = lightcurvePlot.y;
         _loc1_ = _loc5_;
         while(_loc1_ < _loc6_)
         {
            _loc7_ = lightcurvePlot.x + _loc4_ * (_loc1_ * period - minTimePlotValue);
            periodLinesSP.graphics.moveTo(_loc7_,_loc8_);
            periodLinesSP.graphics.lineTo(_loc7_,_loc9_);
            _loc1_++;
         }
      }
      
      internal function frame1() : *
      {
         starField = new StarField();
         hiddenStarField = new StarField();
         starField.visible = false;
         starField.x = 14;
         starField.y = 62;
         starField.lock();
         hiddenStarField.lock();
         starField.dimensions = {
            "width":400,
            "height":300
         };
         hiddenStarField.dimensions = {
            "width":400,
            "height":300
         };
         gammaTF1 = new GammaTransferFunction();
         gammaTF2 = new GammaTransferFunction();
         starField.transferFunction = gammaTF1;
         hiddenStarField.transferFunction = gammaTF2;
         starsList = [];
         pixelMask = new PixelMask();
         backgroundMargin = 3;
         starHalosContainerSP = new Sprite();
         starHalosContainerSP.x = starField.x;
         starHalosContainerSP.y = starField.y;
         dataGenerationDone = false;
         dataGenerationParameters = {};
         dataGenerationParameters.targetTime = 40;
         dataGenerationParameters.totalFields = 0;
         dataGenerationParameters.totalTimeTaken = 0;
         lightcurveSeries = new PlotSeries();
         lightcurveSeries.xAxisPropertyName = "epoch";
         lightcurveSeries.yAxisPropertyName = "delta";
         lightcurveSeries.pointOutlineAlpha = 0;
         lightcurveSeries.pointFillColor = 6316128;
         lightcurvePlot = new Plot();
         lightcurvePlot.setPlotDimensions(380,260);
         lightcurvePlot.x = 493;
         lightcurvePlot.y = 335;
         lightcurvePlot.setXAxisRange(0,10);
         lightcurvePlot.setYAxisRange(-1.5,1.5);
         lightcurvePlot.invertYAxis = true;
         lightcurvePlot.addSeries(lightcurveSeries);
         minPDMPeriod = 0.2;
         maxPDMPeriod = 12;
         pdmSeries = new PlotSeries();
         pdmSeries.showLines = true;
         pdmSeries.showPoints = false;
         pdmPlot = new Plot();
         pdmPlot.setPlotDimensions(650,230);
         pdmPlot.x = 220;
         pdmPlot.y = 673;
         pdmPlot.setXAxisRange(minPDMPeriod,maxPDMPeriod);
         pdmPlot.setYAxisRange(0,1.2);
         pdmPlot.setZoomMode("xZoomOnly");
         pdmPlotWidth = pdmPlot.getPlotDimensions().width;
         pdmPlotHeight = pdmPlot.getPlotDimensions().height;
         pdmPlot.xZoomRangeLimit = pdmPlotWidth * Math.pow(10,-periodPrecision);
         pdmPlot.zoomWindowFillColor = 12897476;
         pdmPlot.zoomWindowFillAlpha = 0.5;
         pdmPlot.zoomWindowBorderThickness = 1;
         pdmPlot.zoomWindowBorderColor = 12897476;
         pdmPlot.addSeries(pdmSeries);
         updateZoomButtonStates();
         deltaMagOverlay = new DeltaMagOverlay(lightcurvePlot);
         minEpoch = Number.POSITIVE_INFINITY;
         maxEpoch = Number.NEGATIVE_INFINITY;
         period = 7;
         lastPDMZoomRange = {
            "min":minPDMPeriod,
            "max":maxPDMPeriod
         };
         comparisonStar = null;
         featuredStar = null;
         comparisonStarColor = 3381759;
         featuredStarColor = 3381504;
         pdmParameters = {};
         pdmParameters.resolution = 12000;
         pdmParameters.Nb = 5;
         pdmParameters.Nc = 2;
         pdmParameters.M = pdmParameters.Nb * pdmParameters.Nc;
         pdmParameters.targetTime = 30;
         pdmParameters.totalTimeTaken = 0;
         pdmParameters.totalCalculations = 0;
         pdmParameters.calculationInProgress = false;
         observationsList = [];
         plotTypeRadioButtonGroup = new RadioButtonGroup("plotTypeGroup");
         plotTypeRadioButton0.group = plotTypeRadioButtonGroup;
         plotTypeRadioButton1.group = plotTypeRadioButtonGroup;
         periodCursorSP = new Sprite();
         periodCursorSP.mouseEnabled = false;
         periodCursorThickness = 1;
         periodCursorColor = 3552858;
         inactivePeriodCursorAlpha = 0.4;
         activePeriodCursorAlpha = 1;
         periodCursorAlpha = inactivePeriodCursorAlpha;
         periodCursorMode = 0;
         periodAtDraggingStart = 7;
         periodCursorModeAtDraggingStart = 0;
         outOfBoundsCursorPosition = 10;
         outOfBoundsSnapMargin = 7;
         outOfBoundsCursorAlpha = 0.4;
         periodLinesSP = new Sprite();
         periodLinesColor = 3552858;
         periodLinesThickness = 1;
         periodLinesAlpha = 0.2;
         embedItalicVerdanaField.visible = false;
         activeTextInputFormat = new TextFormat("Verdana",12);
         inactiveTextInputFormat = new TextFormat("Verdana",12);
         activeTextInputFormat.align = "center";
         inactiveTextInputFormat.align = "center";
         activeTextInputFormat.italic = true;
         periodTextInput.setStyle("embedFonts",true);
         periodTextInput.setStyle("textFormat",inactiveTextInputFormat);
         periodTextInput.addEventListener("enter",onPeriodEntered);
         periodTextInput.addEventListener("focusOut",onPeriodEntered);
         periodTextInput.addEventListener("change",onPeriodTextInputChanged);
         zoomIn3TimesButton.addEventListener(MouseEvent.CLICK,onZoomIn3TimesButtonPressed);
         zoomOut3TimesButton.addEventListener(MouseEvent.CLICK,onZoomOut3TimesButtonPressed);
         zoomOutButton.addEventListener(MouseEvent.CLICK,pdmZoomOut);
         undoLastZoomButton.addEventListener(MouseEvent.CLICK,pdmUndoLastZoom);
         pdmPlot.addEventListener(Plot.ZOOM_START,onZoomStart);
         pdmPlot.addEventListener(Plot.ON_ZOOM_STEP_TAKEN,repositionPeriodPointer);
         pdmPlot.addEventListener(Plot.ZOOM_DONE,onZoomDone);
         showDifferenceToolCheckBox.addEventListener(Event.CHANGE,onShowDifferenceToolToggled);
         showCrosshairCheckBox.addEventListener(Event.CHANGE,updateCrosshair);
         periodPointer.addEventListener(MouseEvent.MOUSE_DOWN,startPeriodDragging);
         plotTypeRadioButtonGroup.addEventListener(Event.CHANGE,onPlotTypeChanged);
         stage.addEventListener(MouseEvent.MOUSE_MOVE,onMouseMoveOverStage);
         crosshairMC.visible = false;
         undoLastZoomButton.enabled = false;
         clickToBeginMC.x = lightcurvePlot.x + lightcurvePlot.getPlotDimensions().width / 2;
         addChild(starField);
         addChild(starHalosContainerSP);
         addChild(pdmPlot);
         addChild(periodCursorSP);
         addChild(lightcurvePlot);
         addChild(periodLinesSP);
         addChild(deltaMagOverlay);
         setChildIndex(crosshairMC,numChildren - 1);
         setChildIndex(clickToBeginMC,numChildren - 1);
         setChildIndex(loadingInfoMC,numChildren - 1);
         onShowDifferenceToolToggled();
         setLightcurveType(plotTypeRadioButtonGroup.selectedData as String);
         updatePeriodAndPhases();
         settingsXML = new XML();
         settingsFile = root.loaderInfo.parameters.settingsFile is String ? root.loaderInfo.parameters.settingsFile : "settings.xml";
         settingsLoader = new URLLoader(new URLRequest(settingsFile));
         settingsLoader.addEventListener("complete",onSettingsLoaded);
      }
      
      public function repositionPeriodPointer(... rest) : void
      {
         var _loc2_:Object = null;
         var _loc3_:Number = NaN;
         _loc2_ = pdmPlot.getXAxisRange();
         _loc3_ = pdmPlot.x + pdmPlotWidth * (period - _loc2_.min) / (_loc2_.max - _loc2_.min);
         if(_loc3_ < pdmPlot.x)
         {
            periodCursorMode = -1;
            _loc3_ = pdmPlot.x - outOfBoundsCursorPosition;
            periodAtLeftMC.visible = true;
            periodAtRightMC.visible = false;
            periodPointer.alpha = outOfBoundsCursorAlpha;
            periodPointer.x = _loc3_;
         }
         else if(_loc3_ > pdmPlot.x + pdmPlotWidth)
         {
            periodCursorMode = 1;
            _loc3_ = pdmPlot.x + pdmPlotWidth + outOfBoundsCursorPosition;
            periodAtLeftMC.visible = false;
            periodAtRightMC.visible = true;
            periodPointer.alpha = outOfBoundsCursorAlpha;
            periodPointer.x = _loc3_;
         }
         else
         {
            periodCursorMode = 0;
            periodAtLeftMC.visible = false;
            periodAtRightMC.visible = false;
            periodPointer.alpha = 1;
            periodPointer.x = _loc3_;
         }
         periodCursorSP.graphics.clear();
         if(periodCursorMode == 0)
         {
            periodCursorSP.graphics.lineStyle(periodCursorThickness,periodCursorColor,periodCursorAlpha);
            periodCursorSP.graphics.moveTo(periodPointer.x,pdmPlot.y - pdmPlotHeight);
            periodCursorSP.graphics.lineTo(periodPointer.x,pdmPlot.y);
         }
      }
      
      public function onPlotTypeChanged(param1:Event) : void
      {
         setLightcurveType(param1.currentTarget.selectedData);
      }
      
      public function continuePeriodDragging(param1:MouseEvent) : void
      {
         var _loc2_:Number = NaN;
         var _loc3_:Object = null;
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         _loc2_ = periodPointer.parent.mouseX - periodDraggingXOffset;
         if(periodCursorModeAtDraggingStart == 1 && _loc2_ > pdmPlot.x + pdmPlotWidth + outOfBoundsSnapMargin)
         {
            period = periodAtDraggingStart;
         }
         else if(periodCursorModeAtDraggingStart == -1 && _loc2_ < pdmPlot.x - outOfBoundsSnapMargin)
         {
            period = periodAtDraggingStart;
         }
         else
         {
            if(_loc2_ < pdmPlot.x)
            {
               _loc2_ = pdmPlot.x;
            }
            else if(_loc2_ > pdmPlot.x + pdmPlotWidth)
            {
               _loc2_ = pdmPlot.x + pdmPlotWidth;
            }
            _loc3_ = pdmPlot.getXAxisRange();
            _loc4_ = _loc3_.min + (_loc3_.max - _loc3_.min) * ((_loc2_ - pdmPlot.x) / pdmPlotWidth);
            _loc5_ = Math.pow(10,periodPrecision);
            if(_loc4_ < minPDMPeriod)
            {
               _loc4_ = minPDMPeriod;
            }
            if(_loc4_ > maxPDMPeriod)
            {
               _loc4_ = maxPDMPeriod;
            }
            period = Math.round(_loc4_ * _loc5_) / _loc5_;
            if(period > _loc3_.max)
            {
               period -= 1 / _loc5_;
            }
            else if(period < _loc3_.min)
            {
               period += 1 / _loc5_;
            }
         }
         updatePeriodAndPhases();
         param1.updateAfterEvent();
      }
      
      internal function __setProp_periodTextInput_Scene1_Layer2_1() : *
      {
         try
         {
            periodTextInput["componentInspectorSetting"] = true;
         }
         catch(e:Error)
         {
         }
         periodTextInput.displayAsPassword = false;
         periodTextInput.editable = true;
         periodTextInput.enabled = true;
         periodTextInput.maxChars = 8;
         periodTextInput.restrict = "0-9.";
         periodTextInput.text = "";
         periodTextInput.visible = true;
         try
         {
            periodTextInput["componentInspectorSetting"] = false;
         }
         catch(e:Error)
         {
         }
      }
      
      internal function __setProp_showCrosshairCheckBox_Scene1_Layer2_1() : *
      {
         try
         {
            showCrosshairCheckBox["componentInspectorSetting"] = true;
         }
         catch(e:Error)
         {
         }
         showCrosshairCheckBox.enabled = true;
         showCrosshairCheckBox.label = "show crosshairs";
         showCrosshairCheckBox.labelPlacement = "right";
         showCrosshairCheckBox.selected = true;
         showCrosshairCheckBox.visible = true;
         try
         {
            showCrosshairCheckBox["componentInspectorSetting"] = false;
         }
         catch(e:Error)
         {
         }
      }
      
      public function stopPeriodDragging(... rest) : void
      {
         stage.removeEventListener(MouseEvent.MOUSE_MOVE,continuePeriodDragging);
         stage.removeEventListener(MouseEvent.MOUSE_UP,stopPeriodDragging);
         periodCursorAlpha = inactivePeriodCursorAlpha;
         repositionPeriodPointer();
      }
      
      public function onPeriodEntered(... rest) : void
      {
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         _loc2_ = parseFloat(periodTextInput.text);
         if(isFinite(_loc2_) && !isNaN(_loc2_) && _loc2_ >= minPDMPeriod && _loc2_ <= maxPDMPeriod)
         {
            _loc3_ = Math.pow(10,periodPrecision);
            period = Math.round(_loc2_ * _loc3_) / _loc3_;
         }
         updatePeriodAndPhases();
         periodTextInput.setStyle("upSkin",TextInput_upSkin);
         periodTextInput.setStyle("textFormat",inactiveTextInputFormat);
      }
      
      public function onHaloClicked(param1:Event) : void
      {
         var _loc2_:* = undefined;
         if(!dataGenerationDone)
         {
            return;
         }
         if(comparisonStar != null && featuredStar != null && (param1.target == comparisonStar.halo || param1.target == featuredStar.halo))
         {
            if(comparisonStar != null && featuredStar != null)
            {
               _loc2_ = comparisonStar;
               comparisonStar = featuredStar;
               featuredStar = _loc2_;
            }
         }
         else if(comparisonStar == null)
         {
            comparisonStar = starsList[param1.target.index];
         }
         else
         {
            if(featuredStar != null)
            {
               featuredStar.halo.drawHalo(1,16711680,0,"circle");
            }
            featuredStar = starsList[param1.target.index];
         }
         if(comparisonStar != null)
         {
            comparisonStar.halo.drawHalo(1,comparisonStarColor,1,"square");
         }
         if(featuredStar != null)
         {
            featuredStar.halo.drawHalo(1.5,featuredStarColor,1,"circle");
         }
         calculateComparisonsList();
         updatePeriodAndPhases();
         pdmZoomOut();
         startPDMCalculation();
         deltaMagOverlay.update();
      }
      
      public function startPDMCalculation() : void
      {
         var _loc1_:Object = null;
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc6_:int = 0;
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc9_:Number = NaN;
         if(pdmParameters.calculationInProgress)
         {
            cancelPDMCalculation();
         }
         if(comparisonStar == null || featuredStar == null)
         {
            pdmSeries.dataProvider = new DataProvider();
            return;
         }
         _loc1_ = pdmPlot.getXAxisRange();
         _loc2_ = comparisonsList.length;
         _loc3_ = Number(pdmParameters.Nb);
         _loc4_ = Number(pdmParameters.Nc);
         _loc5_ = Number(pdmParameters.M);
         _loc8_ = 0;
         _loc9_ = 0;
         _loc6_ = 0;
         while(_loc6_ < _loc2_)
         {
            _loc7_ = Number(comparisonsList[_loc6_].delta);
            _loc8_ += _loc7_;
            _loc9_ += _loc7_ * _loc7_;
            _loc6_++;
         }
         pdmParameters.c1 = (_loc2_ - 1) / ((_loc9_ - _loc8_ * _loc8_ / _loc2_) * (_loc2_ * _loc4_ - _loc5_));
         pdmParameters.c2 = pdmParameters.c1 * _loc4_ * _loc9_;
         pdmParameters.periodStart = _loc1_.min;
         pdmParameters.periodStep = (_loc1_.max - _loc1_.min) / (pdmParameters.resolution - 1);
         pdmParameters.currPeriodIndex = 0;
         pdmSeries.dataProvider = new DataProvider();
         addEventListener(Event.ENTER_FRAME,pdmCalculationFunc);
         pdmParameters.calculationInProgress = true;
      }
      
      internal function __setProp_plotTypeRadioButton0_Scene1_Layer2_1() : *
      {
         try
         {
            plotTypeRadioButton0["componentInspectorSetting"] = true;
         }
         catch(e:Error)
         {
         }
         plotTypeRadioButton0.enabled = true;
         plotTypeRadioButton0.groupName = "plotTypeGroup";
         plotTypeRadioButton0.label = "phase";
         plotTypeRadioButton0.labelPlacement = "right";
         plotTypeRadioButton0.selected = false;
         plotTypeRadioButton0.value = "phase";
         plotTypeRadioButton0.visible = true;
         try
         {
            plotTypeRadioButton0["componentInspectorSetting"] = false;
         }
         catch(e:Error)
         {
         }
      }
      
      public function calculateComparisonsList(... rest) : void
      {
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc5_:int = 0;
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         if(comparisonStar == null || featuredStar == null)
         {
            comparisonsList = null;
            clickToBeginMC.visible = true;
            return;
         }
         clickToBeginMC.visible = false;
         comparisonsList = [];
         _loc3_ = Number.NEGATIVE_INFINITY;
         _loc4_ = Number.POSITIVE_INFINITY;
         _loc5_ = 0;
         while(_loc5_ < observationsList.length)
         {
            _loc2_ = -2.5 * Math.log(featuredStar.dataList[_loc5_] / comparisonStar.dataList[_loc5_]) / Math.LN10;
            comparisonsList[_loc5_] = {
               "epoch":observationsList[_loc5_].epoch,
               "delta":_loc2_
            };
            if(_loc2_ > _loc3_)
            {
               _loc3_ = _loc2_;
            }
            if(_loc2_ < _loc4_)
            {
               _loc4_ = _loc2_;
            }
            _loc5_++;
         }
         _loc6_ = _loc3_ - _loc4_;
         if(_loc6_ < 1)
         {
            _loc8_ = _loc4_ + _loc6_ / 2;
            _loc6_ = 1;
            _loc4_ = _loc8_ - _loc6_ / 2;
            _loc3_ = _loc8_ + _loc6_ / 2;
         }
         _loc7_ = 0.1 * _loc6_;
         lightcurvePlot.setYAxisRange(_loc4_ - _loc7_,_loc3_ + _loc7_);
         lightcurveSeries.dataProvider = new DataProvider(comparisonsList);
      }
      
      public function onZoomStart(... rest) : void
      {
         var _loc2_:Object = null;
         _loc2_ = pdmPlot.getXAxisRange();
         lastPDMZoomRange.min = _loc2_.min;
         lastPDMZoomRange.max = _loc2_.max;
         undoLastZoomButton.enabled = true;
      }
      
      public function cancelPDMCalculation() : void
      {
         removeEventListener(Event.ENTER_FRAME,pdmCalculationFunc);
         pdmParameters.calculationInProgress = false;
      }
      
      public function startPeriodDragging(... rest) : void
      {
         periodCursorModeAtDraggingStart = periodCursorMode;
         periodAtDraggingStart = period;
         periodDraggingXOffset = periodPointer.parent.mouseX - periodPointer.x;
         stage.addEventListener(MouseEvent.MOUSE_MOVE,continuePeriodDragging);
         stage.addEventListener(MouseEvent.MOUSE_UP,stopPeriodDragging);
         periodCursorAlpha = activePeriodCursorAlpha;
         repositionPeriodPointer();
      }
      
      public function pdmZoomByMultiple(param1:Number) : void
      {
         var _loc2_:Object = null;
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         _loc2_ = pdmPlot.getXAxisRange();
         _loc3_ = _loc2_.max - _loc2_.min;
         _loc4_ = param1 * _loc3_;
         if(_loc4_ < pdmPlot.xZoomRangeLimit)
         {
            _loc4_ = pdmPlot.xZoomRangeLimit;
         }
         _loc5_ = period;
         _loc6_ = _loc5_ - _loc4_ / 2;
         _loc7_ = _loc5_ + _loc4_ / 2;
         if(_loc6_ < minPDMPeriod)
         {
            _loc6_ = minPDMPeriod;
            _loc7_ = _loc6_ + _loc4_;
            if(_loc7_ > maxPDMPeriod)
            {
               _loc7_ = maxPDMPeriod;
            }
         }
         else if(_loc7_ > maxPDMPeriod)
         {
            _loc7_ = maxPDMPeriod;
            _loc6_ = _loc7_ - _loc4_;
            if(_loc6_ < minPDMPeriod)
            {
               _loc6_ = minPDMPeriod;
            }
         }
         _loc8_ = Math.pow(10,periodPrecision);
         _loc6_ = Math.round(_loc6_ * _loc8_) / _loc8_;
         _loc7_ = Math.round(_loc7_ * _loc8_) / _loc8_;
         if(_loc6_ == _loc2_.min && _loc7_ == _loc2_.max)
         {
            return;
         }
         lastPDMZoomRange.min = _loc2_.min;
         lastPDMZoomRange.max = _loc2_.max;
         undoLastZoomButton.enabled = true;
         pdmPlot.setXAxisRange(_loc6_,_loc7_);
         repositionPeriodPointer();
         updateZoomButtonStates();
      }
      
      public function pdmCalculationFunc(... rest) : void
      {
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:Array = null;
         var _loc8_:Array = null;
         var _loc9_:Number = NaN;
         _loc2_ = getTimer();
         _loc3_ = pdmParameters.totalTimeTaken / pdmParameters.totalCalculations;
         if(isNaN(_loc3_) || !isFinite(_loc3_) || _loc3_ <= 0)
         {
            _loc3_ = 0.1;
         }
         _loc4_ = Math.ceil(pdmParameters.targetTime / _loc3_);
         if(_loc4_ < 0)
         {
            _loc4_ = 1;
         }
         _loc5_ = pdmParameters.currPeriodIndex + _loc4_;
         if(_loc5_ > pdmParameters.resolution)
         {
            _loc5_ = int(pdmParameters.resolution);
            _loc4_ = _loc5_ - pdmParameters.currPeriodIndex;
         }
         _loc7_ = [];
         _loc8_ = [];
         _loc6_ = int(pdmParameters.currPeriodIndex);
         while(_loc6_ < _loc5_)
         {
            _loc7_.push(pdmParameters.periodStart + pdmParameters.periodStep * _loc6_);
            _loc6_++;
         }
         pdmParameters.currPeriodIndex = _loc6_;
         _loc9_ = doPDMCalculation(_loc7_,_loc8_);
         pdmSeries.dataProvider.addItems(_loc8_);
         pdmParameters.totalTimeTaken += _loc9_;
         pdmParameters.totalCalculations += _loc4_;
         if(pdmParameters.currPeriodIndex >= pdmParameters.resolution)
         {
            cancelPDMCalculation();
         }
      }
      
      public function onShowDifferenceToolToggled(... rest) : void
      {
         deltaMagOverlay.visible = showDifferenceToolCheckBox.selected;
      }
      
      public function pdmZoomOut(... rest) : void
      {
         var _loc2_:Object = null;
         _loc2_ = pdmPlot.getXAxisRange();
         if(_loc2_.min == minPDMPeriod && _loc2_.max == maxPDMPeriod)
         {
            return;
         }
         lastPDMZoomRange.min = _loc2_.min;
         lastPDMZoomRange.max = _loc2_.max;
         undoLastZoomButton.enabled = true;
         pdmPlot.setXAxisRange(minPDMPeriod,maxPDMPeriod);
         repositionPeriodPointer();
         updateZoomButtonStates();
      }
      
      internal function __setProp_plotTypeRadioButton1_Scene1_Layer2_1() : *
      {
         try
         {
            plotTypeRadioButton1["componentInspectorSetting"] = true;
         }
         catch(e:Error)
         {
         }
         plotTypeRadioButton1.enabled = true;
         plotTypeRadioButton1.groupName = "plotTypeGroup";
         plotTypeRadioButton1.label = "time";
         plotTypeRadioButton1.labelPlacement = "right";
         plotTypeRadioButton1.selected = true;
         plotTypeRadioButton1.value = "epoch";
         plotTypeRadioButton1.visible = true;
         try
         {
            plotTypeRadioButton1["componentInspectorSetting"] = false;
         }
         catch(e:Error)
         {
         }
      }
      
      public function onMouseMoveOverStage(param1:MouseEvent) : void
      {
         updateCrosshair();
         if(crosshairMC.visible)
         {
            param1.updateAfterEvent();
         }
      }
      
      public function startDataGeneration() : void
      {
         dataGenerationParameters.currFieldIndex = 0;
         addEventListener(Event.ENTER_FRAME,generateDataFunc);
      }
      
      public function updateCrosshair(... rest) : void
      {
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         if(showCrosshairCheckBox.selected && starField.visible && starField.hitTestPoint(mouseX,mouseY,true))
         {
            _loc2_ = int(mouseX - starField.x);
            _loc3_ = int(mouseY - starField.y);
            if(_loc2_ < 0)
            {
               _loc2_ = 0;
            }
            else if(_loc2_ >= starField.dimensions.width)
            {
               _loc2_ = starField.dimensions.width - 1;
            }
            if(_loc3_ < 0)
            {
               _loc3_ = 0;
            }
            else if(_loc3_ >= starField.dimensions.height)
            {
               _loc3_ = starField.dimensions.height - 1;
            }
            crosshairMC.xField.text = _loc2_.toString();
            crosshairMC.yField.text = _loc3_.toString();
            crosshairMC.x = starField.x + _loc2_;
            crosshairMC.y = starField.y + _loc3_;
            crosshairMC.visible = true;
         }
         else
         {
            crosshairMC.visible = false;
         }
      }
      
      public function setLightcurveType(param1:String) : void
      {
         if(param1 == "epoch")
         {
            lightcurveSeries.xAxisPropertyName = "epoch";
            lightcurvePlot.setXAxisRange(minTimePlotValue,maxTimePlotValue);
            periodLinesSP.visible = true;
         }
         else if(param1 == "phase")
         {
            lightcurveSeries.xAxisPropertyName = "phase";
            lightcurvePlot.setXAxisRange(0,1);
            periodLinesSP.visible = false;
         }
      }
      
      public function onZoomDone(... rest) : void
      {
         repositionPeriodPointer();
         updateZoomButtonStates();
      }
      
      public function onZoomOut3TimesButtonPressed(... rest) : void
      {
         pdmZoomByMultiple(3);
      }
      
      public function doPDMCalculation(param1:Array, param2:Array) : Number
      {
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc10_:int = 0;
         var _loc11_:Number = NaN;
         var _loc12_:Number = NaN;
         var _loc13_:Number = NaN;
         var _loc14_:Number = NaN;
         var _loc15_:Number = NaN;
         var _loc16_:Number = NaN;
         var _loc17_:Number = NaN;
         var _loc18_:Array = null;
         var _loc19_:Array = null;
         var _loc20_:Number = NaN;
         _loc3_ = getTimer();
         _loc4_ = comparisonsList.length;
         _loc5_ = Number(pdmParameters.Nb);
         _loc6_ = Number(pdmParameters.Nc);
         _loc7_ = Number(pdmParameters.M);
         _loc8_ = Number(pdmParameters.c1);
         _loc9_ = Number(pdmParameters.c2);
         _loc18_ = [];
         _loc19_ = [];
         _loc10_ = 0;
         while(_loc10_ < param1.length)
         {
            _loc11_ = Number(param1[_loc10_]);
            _loc12_ = 0;
            while(_loc12_ < _loc7_)
            {
               _loc18_[_loc12_] = _loc19_[_loc12_] = 0;
               _loc12_++;
            }
            _loc13_ = 0;
            while(_loc13_ < _loc4_)
            {
               _loc14_ = comparisonsList[_loc13_].epoch % _loc11_ / _loc11_;
               _loc15_ = 0;
               while(_loc15_ < _loc6_)
               {
                  _loc16_ = Math.floor(_loc5_ * ((_loc14_ + _loc15_ * (1 / _loc7_)) % 1 + _loc15_));
                  _loc18_[_loc16_] += comparisonsList[_loc13_].delta;
                  _loc19_[_loc16_] += 1;
                  _loc15_++;
               }
               _loc13_++;
            }
            _loc17_ = 0;
            _loc12_ = 0;
            while(_loc12_ < _loc7_)
            {
               if(_loc19_[_loc12_] != 0)
               {
                  _loc17_ += _loc18_[_loc12_] * _loc18_[_loc12_] / _loc19_[_loc12_];
               }
               _loc12_++;
            }
            param2[_loc10_] = {
               "x":_loc11_,
               "y":_loc9_ - _loc8_ * _loc17_
            };
            _loc10_++;
         }
         _loc20_ = getTimer() - _loc3_;
         if(_loc20_ <= 0)
         {
            _loc20_ = 1;
         }
         return _loc20_;
      }
      
      internal function __setProp_zoomOut3TimesButton_Scene1_Layer2_1() : *
      {
         try
         {
            zoomOut3TimesButton["componentInspectorSetting"] = true;
         }
         catch(e:Error)
         {
         }
         zoomOut3TimesButton.emphasized = false;
         zoomOut3TimesButton.enabled = true;
         zoomOut3TimesButton.label = "zoom out around period";
         zoomOut3TimesButton.labelPlacement = "right";
         zoomOut3TimesButton.selected = false;
         zoomOut3TimesButton.toggle = false;
         zoomOut3TimesButton.visible = true;
         try
         {
            zoomOut3TimesButton["componentInspectorSetting"] = false;
         }
         catch(e:Error)
         {
         }
      }
      
      internal function __setProp_zoomIn3TimesButton_Scene1_Layer2_1() : *
      {
         try
         {
            zoomIn3TimesButton["componentInspectorSetting"] = true;
         }
         catch(e:Error)
         {
         }
         zoomIn3TimesButton.emphasized = false;
         zoomIn3TimesButton.enabled = true;
         zoomIn3TimesButton.label = "zoom in around period";
         zoomIn3TimesButton.labelPlacement = "right";
         zoomIn3TimesButton.selected = false;
         zoomIn3TimesButton.toggle = false;
         zoomIn3TimesButton.visible = true;
         try
         {
            zoomIn3TimesButton["componentInspectorSetting"] = false;
         }
         catch(e:Error)
         {
         }
      }
      
      internal function __setProp_undoLastZoomButton_Scene1_Layer2_1() : *
      {
         try
         {
            undoLastZoomButton["componentInspectorSetting"] = true;
         }
         catch(e:Error)
         {
         }
         undoLastZoomButton.emphasized = false;
         undoLastZoomButton.enabled = true;
         undoLastZoomButton.label = "undo last zoom";
         undoLastZoomButton.labelPlacement = "right";
         undoLastZoomButton.selected = false;
         undoLastZoomButton.toggle = false;
         undoLastZoomButton.visible = true;
         try
         {
            undoLastZoomButton["componentInspectorSetting"] = false;
         }
         catch(e:Error)
         {
         }
      }
      
      public function onSettingsLoaded(... rest) : void
      {
         var _loc2_:int = 0;
         var _loc3_:StarHalo = null;
         var _loc4_:XML = null;
         var _loc5_:Number = NaN;
         var _loc6_:XML = null;
         settingsXML = XML(settingsLoader.data);
         starField.noiseMean = settingsXML.fieldParameters.@noiseMean;
         starField.noiseSigma = settingsXML.fieldParameters.@noiseSigma;
         starField.saturationMagnitude = settingsXML.fieldParameters.@saturationMagnitude;
         starField.psf = new AiryDisc(settingsXML.fieldParameters.@psfRadius);
         hiddenStarField.noiseMean = settingsXML.fieldParameters.@noiseMean;
         hiddenStarField.noiseSigma = settingsXML.fieldParameters.@noiseSigma;
         hiddenStarField.saturationMagnitude = settingsXML.fieldParameters.@saturationMagnitude;
         hiddenStarField.psf = new AiryDisc(settingsXML.fieldParameters.@psfRadius);
         pixelMask.radius = backgroundMargin + uint(settingsXML.fieldParameters.@psfRadius);
         _loc2_ = 0;
         for each(_loc4_ in settingsXML.starsList.elements())
         {
            switch(String(_loc4_.name()))
            {
               case "constantStar":
                  starField.addStar(new Star({
                     "x":int(_loc4_.@x),
                     "y":int(_loc4_.@y),
                     "magnitude":Number(_loc4_.@magnitude)
                  }));
                  hiddenStarField.addStar(new Star({
                     "x":int(_loc4_.@x),
                     "y":int(_loc4_.@y),
                     "magnitude":Number(_loc4_.@magnitude)
                  }));
                  break;
               case "pulsatingStar":
                  starField.addStar(new PulsatingStar({
                     "x":int(_loc4_.@x),
                     "y":int(_loc4_.@y),
                     "centerMagnitude":Number(_loc4_.@centerMagnitude)
                  },PulsatingStar.PRESETS[String(_loc4_.@prototypeName)]));
                  hiddenStarField.addStar(new PulsatingStar({
                     "x":int(_loc4_.@x),
                     "y":int(_loc4_.@y),
                     "centerMagnitude":Number(_loc4_.@centerMagnitude)
                  },PulsatingStar.PRESETS[String(_loc4_.@prototypeName)]));
                  break;
               case "eclipsingBinary":
                  starField.addStar(new EclipsingBinary({
                     "x":int(_loc4_.@x),
                     "y":int(_loc4_.@y),
                     "peakMagnitude":Number(_loc4_.@peakMagnitude)
                  },EclipsingBinary.PRESETS[String(_loc4_.@prototypeName)]));
                  hiddenStarField.addStar(new EclipsingBinary({
                     "x":int(_loc4_.@x),
                     "y":int(_loc4_.@y),
                     "peakMagnitude":Number(_loc4_.@peakMagnitude)
                  },EclipsingBinary.PRESETS[String(_loc4_.@prototypeName)]));
            }
            _loc3_ = new StarHalo({
               "x":int(_loc4_.@x),
               "y":int(_loc4_.@y),
               "index":_loc2_,
               "radius":pixelMask.radius
            });
            _loc3_.addEventListener("haloClicked",onHaloClicked);
            starsList[_loc2_] = {
               "x":int(_loc4_.@x),
               "y":int(_loc4_.@y),
               "halo":_loc3_,
               "dataList":[]
            };
            starHalosContainerSP.addChild(_loc3_);
            _loc2_++;
         }
         for each(_loc6_ in settingsXML.observationsList.elements())
         {
            _loc5_ = Number(_loc6_.@epoch);
            if(_loc5_ > maxEpoch)
            {
               maxEpoch = _loc5_;
            }
            if(_loc5_ < minEpoch)
            {
               minEpoch = _loc5_;
            }
            observationsList.push({
               "epoch":_loc5_,
               "noiseSeed":uint(_loc6_.@noiseSeed)
            });
         }
         minTimePlotValue = Math.floor(minEpoch - 1);
         maxTimePlotValue = Math.ceil(maxEpoch + 1);
         setLightcurveType(plotTypeRadioButtonGroup.selectedData as String);
         updatePeriodAndPhases();
         starField.setEpochAndNoiseSeed(observationsList[0].epoch,observationsList[0].noiseSeed);
         hiddenStarField.unlock();
         starField.unlock();
         startDataGeneration();
      }
      
      internal function __setProp_zoomOutButton_Scene1_Layer2_1() : *
      {
         try
         {
            zoomOutButton["componentInspectorSetting"] = true;
         }
         catch(e:Error)
         {
         }
         zoomOutButton.emphasized = false;
         zoomOutButton.enabled = true;
         zoomOutButton.label = "zoom out to full range";
         zoomOutButton.labelPlacement = "right";
         zoomOutButton.selected = false;
         zoomOutButton.toggle = false;
         zoomOutButton.visible = true;
         try
         {
            zoomOutButton["componentInspectorSetting"] = false;
         }
         catch(e:Error)
         {
         }
      }
      
      public function onPeriodTextInputChanged(... rest) : void
      {
         periodTextInput.setStyle("upSkin",TextInput_upSkinActive);
         periodTextInput.setStyle("textFormat",activeTextInputFormat);
      }
   }
}

