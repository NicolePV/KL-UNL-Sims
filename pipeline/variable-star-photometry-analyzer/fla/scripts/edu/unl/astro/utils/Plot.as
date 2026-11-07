package edu.unl.astro.utils
{
   import fl.data.DataProvider;
   import fl.events.DataChangeEvent;
   import fl.motion.easing.Cubic;
   import flash.display.Graphics;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import flash.utils.getTimer;
   
   public class Plot extends Sprite
   {
      
      public static const ZOOM_START:String = "zoomStart";
      
      public static const ZOOM_DONE:String = "zoomDone";
      
      public static const ON_ZOOM_STEP_TAKEN:String = "onZoomStepTaken";
      
      protected var _xAxisTickmarkLabelsSP:Sprite;
      
      protected var _xAxisGridlinesSP:Sprite;
      
      public var doZoomAnimation:Boolean = true;
      
      protected var _locked:Boolean = false;
      
      protected var _dataMaskSP:Sprite;
      
      protected var _zoomAnimationInProgess:Boolean = false;
      
      protected var _dataPointsSP:Sprite;
      
      protected var _showXAxisGridlines:Boolean = false;
      
      protected var _yAxisSP:Sprite;
      
      public var zoomWindowBorderThickness:Number = 1;
      
      public var borderColor:uint = 0;
      
      public var borderAlpha:Number = 1;
      
      protected var _dataSP:Sprite;
      
      public var borderThickness:Number = 1;
      
      public var tickmarkLabelsPosition:Number = 7;
      
      protected var _dataLinesSP:Sprite;
      
      public var backgroundColor:uint = 16777215;
      
      public var xAxisPropertyName:String = "x";
      
      public var yAxisPropertyName:String = "y";
      
      public var backgroundAlpha:Number = 1;
      
      public var tickmarkLabelsTextFormat:TextFormat;
      
      public var zoomWindowBorderAlpha:Number = 0.5;
      
      protected var _borderSP:Sprite;
      
      protected var _mouseAreaSP:Sprite;
      
      public var tickmarkLengths:Object = {
         "long":6,
         "medium":4,
         "short":2
      };
      
      protected var _xAxisSP:Sprite;
      
      protected var _zoomWindowSP:Sprite;
      
      public var zoomWindowBorderColor:uint = 4220992;
      
      public var zoomWindowFillAlpha:Number = 0.1;
      
      protected var _zoomAnimationParams:Object = null;
      
      public var zoomWindowFillColor:uint = 4220992;
      
      public var xZoomRangeLimit:Number = Number.NaN;
      
      protected var _seriesList:Array = [];
      
      public var zoomAnimationTime:uint = 1000;
      
      protected var _zoomWindowParams:Object = null;
      
      public var zoomAnimationEasingFunction:Function = Cubic.easeInOut;
      
      protected var _zoomMode:String = "none";
      
      protected var _xAxisSettings:AxisSettingsObject;
      
      protected var _yAxisTickmarkLabelsSP:Sprite;
      
      public var yZoomRangeLimit:Number = Number.NaN;
      
      public var gridlineStyles:Object = {
         "long":{
            "visible":true,
            "thickness":1,
            "color":14540784,
            "alpha":1
         },
         "medium":{
            "visible":true,
            "thickness":1,
            "color":14540784,
            "alpha":0.5
         },
         "short":{
            "visible":true,
            "thickness":1,
            "color":14540784,
            "alpha":0.2
         }
      };
      
      protected var _yAxisGridlinesSP:Sprite;
      
      protected var _showYAxisGridlines:Boolean = false;
      
      protected var _backgroundSP:Sprite;
      
      protected var _yAxisSettings:AxisSettingsObject;
      
      public function Plot(... rest)
      {
         super();
         tickmarkLabelsTextFormat = new TextFormat("Verdana",12);
         _xAxisSettings = new AxisSettingsObject();
         _xAxisSettings.length = 350;
         _xAxisSettings.minSpacingForTickmarks = 9;
         _xAxisSettings.minSpacingForLabels = 34;
         _yAxisSettings = new AxisSettingsObject();
         _yAxisSettings.length = 250;
         _yAxisSettings.minSpacingForTickmarks = 9;
         _yAxisSettings.minSpacingForLabels = 25;
         _backgroundSP = new Sprite();
         _xAxisSP = new Sprite();
         _yAxisSP = new Sprite();
         _xAxisGridlinesSP = new Sprite();
         _yAxisGridlinesSP = new Sprite();
         _dataSP = new Sprite();
         _dataMaskSP = new Sprite();
         _borderSP = new Sprite();
         _mouseAreaSP = new Sprite();
         _zoomWindowSP = new Sprite();
         _xAxisTickmarkLabelsSP = new Sprite();
         _yAxisTickmarkLabelsSP = new Sprite();
         _xAxisSP.addChild(_xAxisTickmarkLabelsSP);
         _yAxisSP.addChild(_yAxisTickmarkLabelsSP);
         _dataLinesSP = new Sprite();
         _dataPointsSP = new Sprite();
         _dataSP.addChild(_dataLinesSP);
         _dataSP.addChild(_dataPointsSP);
         addChild(_backgroundSP);
         addChild(_xAxisSP);
         addChild(_yAxisSP);
         addChild(_xAxisGridlinesSP);
         addChild(_yAxisGridlinesSP);
         addChild(_dataSP);
         addChild(_dataMaskSP);
         addChild(_borderSP);
         addChild(_mouseAreaSP);
         addChild(_zoomWindowSP);
         setZoomMode("none");
         _dataSP.mask = _dataMaskSP;
         if(rest.length > 0)
         {
            loadSettingsFromObjectsList(rest);
         }
         updateBackgroundAndBorder();
      }
      
      public function get invertXAxis() : Boolean
      {
         return _xAxisSettings.inverted;
      }
      
      public function set invertXAxis(param1:Boolean) : void
      {
         _xAxisSettings.inverted = param1;
         update();
      }
      
      public function get zoomMode() : String
      {
         return _zoomMode;
      }
      
      public function removeSeries(param1:PlotSeries) : void
      {
         var _loc2_:int = 0;
         _loc2_ = 0;
         while(_loc2_ < _seriesList.length)
         {
            if(_seriesList[_loc2_].series == param1)
            {
               removeSeriesDebris(_seriesList[_loc2_]);
               _seriesList.splice(_loc2_,1);
               break;
            }
            _loc2_++;
         }
      }
      
      protected function renderYAxisGridlines(param1:Array) : void
      {
         var _loc2_:* = undefined;
         for each(_loc2_ in param1)
         {
            _yAxisGridlinesSP.graphics.moveTo(0,-_loc2_.position);
            _yAxisGridlinesSP.graphics.lineTo(_xAxisSettings.length,-_loc2_.position);
         }
      }
      
      public function set locked(param1:Boolean) : void
      {
         _locked = param1;
         if(!_locked)
         {
            update();
         }
      }
      
      public function get yMax() : Number
      {
         return _yAxisSettings.max;
      }
      
      public function set zoomMode(param1:String) : void
      {
         setZoomMode(param1);
      }
      
      public function set yMin(param1:Number) : void
      {
         if(!isFinite(param1) || isNaN(param1) || param1 >= yMax)
         {
            return;
         }
         clearZoomWindow();
         cancelZoomAnimation();
         _yAxisSettings.min = param1;
         update();
      }
      
      public function set yMax(param1:Number) : void
      {
         if(!isFinite(param1) || isNaN(param1) || param1 <= yMin)
         {
            return;
         }
         clearZoomWindow();
         cancelZoomAnimation();
         _yAxisSettings.max = param1;
         update();
      }
      
      protected function getTickmarksInfo(param1:AxisSettingsObject) : Object
      {
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc5_:int = 0;
         var _loc6_:Number = NaN;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         var _loc10_:int = 0;
         var _loc11_:int = 0;
         var _loc12_:int = 0;
         var _loc13_:Array = null;
         var _loc14_:Array = null;
         var _loc15_:Array = null;
         var _loc16_:Array = null;
         var _loc17_:Object = null;
         var _loc18_:Object = null;
         _loc2_ = param1.length / (param1.max - param1.min);
         _loc3_ = param1.minSpacingForTickmarks / _loc2_;
         _loc4_ = param1.minSpacingForLabels / _loc2_;
         _loc5_ = Math.ceil(Math.log(_loc3_) / Math.LN10);
         _loc6_ = Math.pow(10,_loc5_);
         if(_loc6_ / 2 >= _loc3_)
         {
            _loc6_ /= 2;
            _loc8_ = 20;
            _loc9_ = 2;
            _loc7_ = 1;
            while(_loc7_ <= 100000)
            {
               if(_loc4_ <= _loc7_ * _loc6_)
               {
                  _loc10_ = _loc7_;
                  _loc5_--;
                  break;
               }
               if(_loc4_ <= 2 * _loc7_ * _loc6_)
               {
                  _loc10_ = 2 * _loc7_;
                  break;
               }
               _loc5_ += 1;
               _loc7_ *= 10;
            }
         }
         else
         {
            _loc8_ = 10;
            _loc9_ = 5;
            _loc7_ = 1;
            while(_loc7_ <= 100000)
            {
               if(_loc4_ <= _loc7_ * _loc6_)
               {
                  _loc10_ = _loc7_;
                  break;
               }
               if(_loc4_ <= 5 * _loc7_ * _loc6_)
               {
                  _loc10_ = 5 * _loc7_;
                  break;
               }
               _loc5_ += 1;
               _loc7_ *= 10;
            }
         }
         _loc11_ = Math.ceil(param1.min / _loc6_);
         _loc12_ = 1 + Math.floor(param1.max / _loc6_);
         _loc13_ = [];
         _loc14_ = [];
         _loc15_ = [];
         _loc16_ = [];
         _loc7_ = _loc11_;
         while(_loc7_ < _loc12_)
         {
            _loc17_ = {};
            _loc17_.value = _loc7_ * _loc6_;
            _loc17_.position = _loc2_ * (_loc17_.value - param1.min);
            if(param1.inverted)
            {
               _loc17_.position = param1.length - _loc17_.position;
            }
            if(_loc7_ % _loc8_ == 0)
            {
               _loc13_.push(_loc17_);
            }
            else if(_loc7_ % _loc9_ == 0)
            {
               _loc14_.push(_loc17_);
            }
            else
            {
               _loc15_.push(_loc17_);
            }
            if(_loc7_ % _loc10_ == 0)
            {
               _loc16_.push({
                  "position":_loc17_.position,
                  "label":getFormattedNumber(_loc17_.value,_loc5_)
               });
            }
            _loc7_++;
         }
         _loc18_ = {};
         _loc18_.longTickmarksList = _loc13_;
         _loc18_.mediumTickmarksList = _loc14_;
         _loc18_.shortTickmarksList = _loc15_;
         _loc18_.tickmarkLabelsList = _loc16_;
         return _loc18_;
      }
      
      protected function renderYAxisTickmarks(param1:Object) : void
      {
         var _loc2_:* = undefined;
         for each(_loc2_ in param1.tickmarksList)
         {
            _yAxisSP.graphics.moveTo(0,-_loc2_.position);
            _yAxisSP.graphics.lineTo(-param1.length,-_loc2_.position);
         }
      }
      
      protected function onMouseDownOnBackground(... rest) : void
      {
         if(_zoomAnimationInProgess)
         {
            return;
         }
         clearZoomWindow();
         _zoomWindowParams = {};
         _zoomWindowParams.startPointInPixels = {
            "x":_mouseAreaSP.mouseX,
            "y":_mouseAreaSP.mouseY
         };
         _zoomWindowParams.isValid = false;
         _zoomWindowParams.isListening = false;
         _zoomWindowParams.draggingInProgress = true;
         stage.addEventListener(MouseEvent.MOUSE_MOVE,updateZoomWindowDragging);
         stage.addEventListener(MouseEvent.MOUSE_UP,stopZoomWindowDragging);
      }
      
      protected function updateYAxis() : void
      {
         var _loc1_:Object = null;
         _loc1_ = getTickmarksInfo(_yAxisSettings);
         _yAxisSP.graphics.clear();
         _yAxisSP.graphics.lineStyle(borderThickness,borderColor,borderAlpha);
         _yAxisSP.removeChild(_yAxisTickmarkLabelsSP);
         _yAxisTickmarkLabelsSP = new Sprite();
         _yAxisSP.addChild(_yAxisTickmarkLabelsSP);
         renderYAxisTickmarks({
            "tickmarksList":_loc1_.longTickmarksList,
            "length":tickmarkLengths.long
         });
         renderYAxisTickmarks({
            "tickmarksList":_loc1_.mediumTickmarksList,
            "length":tickmarkLengths.medium
         });
         renderYAxisTickmarks({
            "tickmarksList":_loc1_.shortTickmarksList,
            "length":tickmarkLengths.short
         });
         renderYAxisTickmarkLabels(_loc1_.tickmarkLabelsList);
         _yAxisGridlinesSP.graphics.clear();
         if(_showYAxisGridlines)
         {
            if(gridlineStyles.long.visible)
            {
               _yAxisGridlinesSP.graphics.lineStyle(gridlineStyles.long.thickness,gridlineStyles.long.color,gridlineStyles.long.alpha,false,"normal","none");
               renderYAxisGridlines(_loc1_.longTickmarksList);
            }
            if(gridlineStyles.medium.visible)
            {
               _yAxisGridlinesSP.graphics.lineStyle(gridlineStyles.medium.thickness,gridlineStyles.medium.color,gridlineStyles.medium.alpha,false,"normal","none");
               renderYAxisGridlines(_loc1_.mediumTickmarksList);
            }
            if(gridlineStyles.short.visible)
            {
               _yAxisGridlinesSP.graphics.lineStyle(gridlineStyles.short.thickness,gridlineStyles.short.color,gridlineStyles.short.alpha,false,"normal","none");
               renderYAxisGridlines(_loc1_.shortTickmarksList);
            }
         }
      }
      
      protected function renderXAxisGridlines(param1:Array) : void
      {
         var _loc2_:* = undefined;
         for each(_loc2_ in param1)
         {
            _xAxisGridlinesSP.graphics.moveTo(_loc2_.position,0);
            _xAxisGridlinesSP.graphics.lineTo(_loc2_.position,-_yAxisSettings.length);
         }
      }
      
      public function getPlotDimensions() : Object
      {
         return {
            "width":_xAxisSettings.length,
            "height":_yAxisSettings.length
         };
      }
      
      public function setXAxisRange(param1:Number, param2:Number) : void
      {
         var _loc3_:Number = NaN;
         if(!isFinite(param1) || isNaN(param1) || !isFinite(param2) || isNaN(param2) || param1 == param2)
         {
            return;
         }
         clearZoomWindow();
         cancelZoomAnimation();
         if(param1 > param2)
         {
            _loc3_ = param1;
            param1 = param2;
            param2 = _loc3_;
         }
         _xAxisSettings.min = param1;
         _xAxisSettings.max = param2;
         update();
      }
      
      public function addSeries(param1:PlotSeries) : PlotSeries
      {
         var _loc2_:Object = null;
         _loc2_ = {};
         _loc2_.series = param1;
         _loc2_.series.addEventListener(PlotSeries.REFRESH_REQUESTED,onRefreshSeriesRequested);
         _loc2_.series.addEventListener(DataChangeEvent.DATA_CHANGE,onRefreshSeriesRequested);
         _loc2_.linesSP = new Sprite();
         _loc2_.pointsSP = new Sprite();
         _dataLinesSP.addChild(_loc2_.linesSP);
         _dataPointsSP.addChild(_loc2_.pointsSP);
         _seriesList.push(_loc2_);
         updateSeries(_loc2_);
         return param1;
      }
      
      public function setPlotDimensions(param1:Number, param2:Number) : void
      {
         if(!isFinite(param1) || isNaN(param1) || !isFinite(param1) || isNaN(param1) || param1 <= 0 || param2 <= 0)
         {
            return;
         }
         _xAxisSettings.length = param1;
         _yAxisSettings.length = param2;
         updateBackgroundAndBorder();
         update();
      }
      
      public function setZoomMode(param1:String) : void
      {
         clearZoomWindow();
         if(param1 == "xZoomOnly")
         {
            if(_zoomMode == "none")
            {
               _mouseAreaSP.addEventListener(MouseEvent.MOUSE_DOWN,onMouseDownOnBackground);
            }
            _zoomMode = param1;
         }
         else if(param1 == "yZoomOnly")
         {
            if(_zoomMode == "none")
            {
               _mouseAreaSP.addEventListener(MouseEvent.MOUSE_DOWN,onMouseDownOnBackground);
            }
            _zoomMode = param1;
         }
         else if(param1 == "xyZoom")
         {
            if(_zoomMode == "none")
            {
               _mouseAreaSP.addEventListener(MouseEvent.MOUSE_DOWN,onMouseDownOnBackground);
            }
            _zoomMode = param1;
         }
         else
         {
            if(_zoomMode != "none")
            {
               _mouseAreaSP.removeEventListener(MouseEvent.MOUSE_DOWN,onMouseDownOnBackground);
            }
            _zoomMode = "none";
         }
      }
      
      protected function zoomAnimationOnEnterFrameFunc(... rest) : void
      {
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         _loc2_ = getTimer() - _zoomAnimationParams.startTime;
         _loc3_ = _loc2_ >= zoomAnimationTime ? 1 : Number(zoomAnimationEasingFunction(_loc2_,0,1,zoomAnimationTime));
         if(_zoomAnimationParams.xMinAtStart != undefined)
         {
            _loc4_ = _zoomAnimationParams.xMinAtStart + _loc3_ * _zoomAnimationParams.xMinRange;
            _xAxisSettings.min = _loc4_;
         }
         if(_zoomAnimationParams.xMaxAtStart != undefined)
         {
            _loc5_ = _zoomAnimationParams.xMaxAtStart + _loc3_ * _zoomAnimationParams.xMaxRange;
            _xAxisSettings.max = _loc5_;
         }
         if(_zoomAnimationParams.yMinAtStart != undefined)
         {
            _loc6_ = _zoomAnimationParams.yMinAtStart + _loc3_ * _zoomAnimationParams.yMinRange;
            _yAxisSettings.min = _loc6_;
         }
         if(_zoomAnimationParams.yMaxAtStart != undefined)
         {
            _loc7_ = _zoomAnimationParams.yMaxAtStart + _loc3_ * _zoomAnimationParams.yMaxRange;
            _yAxisSettings.max = _loc7_;
         }
         update();
         if(_loc3_ >= 1)
         {
            cancelZoomAnimation();
         }
         else
         {
            dispatchEvent(new Event(Plot.ON_ZOOM_STEP_TAKEN));
         }
      }
      
      public function getXAxisRange() : Object
      {
         return {
            "min":_xAxisSettings.min,
            "max":_xAxisSettings.max
         };
      }
      
      protected function updateSeries(param1:Object) : void
      {
         var _loc2_:Number = NaN;
         var _loc3_:Graphics = null;
         var _loc4_:Graphics = null;
         var _loc5_:PlotSeries = null;
         var _loc6_:DataProvider = null;
         var _loc7_:Object = null;
         var _loc8_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc10_:Number = NaN;
         var _loc11_:Number = NaN;
         var _loc12_:String = null;
         var _loc13_:String = null;
         var _loc14_:Number = NaN;
         var _loc15_:Number = NaN;
         var _loc16_:Number = NaN;
         var _loc17_:Number = NaN;
         var _loc18_:Number = NaN;
         var _loc19_:int = 0;
         var _loc20_:int = 0;
         var _loc21_:int = 0;
         _loc2_ = getTimer();
         _loc3_ = param1.linesSP.graphics;
         _loc4_ = param1.pointsSP.graphics;
         _loc5_ = param1.series;
         _loc6_ = param1.series.dataProvider;
         _loc10_ = _xAxisSettings.length / (_xAxisSettings.max - _xAxisSettings.min);
         _loc11_ = -_yAxisSettings.length / (_yAxisSettings.max - _yAxisSettings.min);
         _loc12_ = _loc5_.xAxisPropertyName == "" ? xAxisPropertyName : _loc5_.xAxisPropertyName;
         _loc13_ = _loc5_.yAxisPropertyName == "" ? yAxisPropertyName : _loc5_.yAxisPropertyName;
         _loc3_.clear();
         _loc3_.lineStyle(_loc5_.lineThickness,_loc5_.lineColor,_loc5_.lineAlpha);
         _loc4_.clear();
         _loc4_.lineStyle(_loc5_.pointOutlineThickness,_loc5_.pointOutlineColor,_loc5_.pointOutlineAlpha);
         if(_loc6_ == null || _loc6_.length == 0)
         {
            return;
         }
         _loc14_ = _loc5_.pointRadius;
         _loc15_ = -_loc14_;
         _loc16_ = -_yAxisSettings.length - _loc14_;
         _loc17_ = _loc14_;
         _loc18_ = _xAxisSettings.length + _loc14_;
         _loc7_ = _loc6_.getItemAt(0);
         _loc8_ = _loc10_ * (_loc7_[_loc12_] - _xAxisSettings.min);
         _loc9_ = _loc11_ * (_loc7_[_loc13_] - _yAxisSettings.min);
         if(_xAxisSettings.inverted)
         {
            _loc8_ = _xAxisSettings.length - _loc8_;
         }
         if(_yAxisSettings.inverted)
         {
            _loc9_ = -_yAxisSettings.length - _loc9_;
         }
         if(_loc8_ < _loc15_)
         {
            _loc20_ = 0;
         }
         else if(_loc9_ < _loc16_)
         {
            _loc20_ = 1;
         }
         else if(_loc9_ > _loc17_)
         {
            _loc20_ = 2;
         }
         else if(_loc8_ > _loc18_)
         {
            _loc20_ = 3;
         }
         else
         {
            _loc20_ = 4;
         }
         if(_loc5_.showLines)
         {
            _loc3_.moveTo(_loc8_,_loc9_);
         }
         if(_loc20_ == 4)
         {
            if(_loc5_.showPoints)
            {
               _loc4_.beginFill(_loc5_.pointFillColor,_loc5_.pointFillAlpha);
               _loc4_.drawCircle(_loc8_,_loc9_,_loc5_.pointRadius);
               _loc4_.endFill();
            }
         }
         _loc19_ = _loc20_;
         _loc21_ = 1;
         while(_loc21_ < _loc6_.length)
         {
            _loc7_ = _loc6_.getItemAt(_loc21_);
            _loc8_ = _loc10_ * (_loc7_[_loc12_] - _xAxisSettings.min);
            _loc9_ = _loc11_ * (_loc7_[_loc13_] - _yAxisSettings.min);
            if(_xAxisSettings.inverted)
            {
               _loc8_ = _xAxisSettings.length - _loc8_;
            }
            if(_yAxisSettings.inverted)
            {
               _loc9_ = -_yAxisSettings.length - _loc9_;
            }
            if(_loc8_ < _loc15_)
            {
               _loc20_ = 0;
            }
            else if(_loc9_ < _loc16_)
            {
               _loc20_ = 1;
            }
            else if(_loc9_ > _loc17_)
            {
               _loc20_ = 2;
            }
            else if(_loc8_ > _loc18_)
            {
               _loc20_ = 3;
            }
            else
            {
               _loc20_ = 4;
            }
            if(_loc20_ == 4)
            {
               if(_loc5_.showLines)
               {
                  _loc3_.lineTo(_loc8_,_loc9_);
               }
               if(_loc5_.showPoints)
               {
                  _loc4_.beginFill(_loc5_.pointFillColor,_loc5_.pointFillAlpha);
                  _loc4_.drawCircle(_loc8_,_loc9_,_loc5_.pointRadius);
                  _loc4_.endFill();
               }
            }
            else if(_loc20_ != _loc19_)
            {
               if(_loc5_.showLines)
               {
                  _loc3_.lineTo(_loc8_,_loc9_);
               }
            }
            else if(_loc5_.showLines)
            {
               _loc3_.moveTo(_loc8_,_loc9_);
            }
            _loc19_ = _loc20_;
            _loc21_++;
         }
         trace("updateSeries: " + (getTimer() - _loc2_));
      }
      
      public function cancelZoomAnimation() : void
      {
         if(!_zoomAnimationInProgess)
         {
            return;
         }
         _zoomAnimationInProgess = false;
         _zoomAnimationParams = null;
         removeEventListener(Event.ENTER_FRAME,zoomAnimationOnEnterFrameFunc);
         dispatchEvent(new Event(Plot.ZOOM_DONE));
      }
      
      public function get xMin() : Number
      {
         return _xAxisSettings.min;
      }
      
      protected function updateZoomWindowDragging(param1:MouseEvent) : void
      {
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         _loc2_ = _mouseAreaSP.mouseX;
         _loc3_ = _mouseAreaSP.mouseY;
         if(_loc2_ < 0)
         {
            _loc2_ = 0;
         }
         else if(_loc2_ > _xAxisSettings.length)
         {
            _loc2_ = _xAxisSettings.length;
         }
         if(_loc3_ > 0)
         {
            _loc3_ = 0;
         }
         else if(_loc3_ < -_yAxisSettings.length)
         {
            _loc3_ = -_yAxisSettings.length;
         }
         if(_zoomMode == "xZoomOnly")
         {
            _zoomWindowParams.isValid = _zoomWindowParams.startPointInPixels.x != _loc2_;
         }
         else if(_zoomMode == "yZoomOnly")
         {
            _zoomWindowParams.isValid = _zoomWindowParams.startPointInPixels.y != _loc3_;
         }
         else if(_zoomMode == "xyZoom")
         {
            _zoomWindowParams.isValid = _zoomWindowParams.startPointInPixels.x != _loc2_ && _zoomWindowParams.startPointInPixels.y != _loc3_;
         }
         _zoomWindowParams.endPointInPixels = {};
         _zoomWindowParams.endPointInPixels.x = _loc2_;
         _zoomWindowParams.endPointInPixels.y = _loc3_;
         updateZoomWindowAppearance();
         param1.updateAfterEvent();
      }
      
      protected function updateAllSeries() : void
      {
         var _loc1_:* = undefined;
         for each(_loc1_ in _seriesList)
         {
            updateSeries(_loc1_);
         }
      }
      
      protected function renderXAxisTickmarks(param1:Object) : void
      {
         var _loc2_:* = undefined;
         for each(_loc2_ in param1.tickmarksList)
         {
            _xAxisSP.graphics.moveTo(_loc2_.position,0);
            _xAxisSP.graphics.lineTo(_loc2_.position,param1.length);
         }
      }
      
      public function update() : void
      {
         var _loc1_:Number = NaN;
         if(_locked)
         {
            trace("skipped update due to lock");
            return;
         }
         _loc1_ = getTimer();
         updateXAxis();
         updateYAxis();
         updateAllSeries();
         trace("plot update: " + (getTimer() - _loc1_));
      }
      
      public function set plotWidth(param1:Number) : void
      {
         if(!isFinite(param1) || isNaN(param1) || param1 <= 0)
         {
            return;
         }
         _xAxisSettings.length = param1;
         updateBackgroundAndBorder();
         update();
      }
      
      protected function updateZoomWindowAppearance() : void
      {
         _zoomWindowSP.graphics.clear();
         if(_zoomWindowParams == null || _zoomWindowParams.endPointInPixels == undefined)
         {
            return;
         }
         if(_zoomMode == "xZoomOnly")
         {
            _zoomWindowSP.graphics.lineStyle(zoomWindowBorderThickness,zoomWindowBorderColor,zoomWindowBorderAlpha,false,"normal","none");
            _zoomWindowSP.graphics.moveTo(_zoomWindowParams.startPointInPixels.x,0);
            _zoomWindowSP.graphics.beginFill(zoomWindowFillColor,zoomWindowFillAlpha);
            _zoomWindowSP.graphics.lineTo(_zoomWindowParams.startPointInPixels.x,-_yAxisSettings.length);
            _zoomWindowSP.graphics.lineStyle();
            _zoomWindowSP.graphics.lineTo(_zoomWindowParams.endPointInPixels.x,-_yAxisSettings.length);
            _zoomWindowSP.graphics.lineStyle(zoomWindowBorderThickness,zoomWindowBorderColor,zoomWindowBorderAlpha,false,"normal","none");
            _zoomWindowSP.graphics.lineTo(_zoomWindowParams.endPointInPixels.x,0);
            _zoomWindowSP.graphics.lineStyle();
            _zoomWindowSP.graphics.lineTo(_zoomWindowParams.startPointInPixels.x,0);
            _zoomWindowSP.graphics.endFill();
         }
         else if(_zoomMode == "yZoomOnly")
         {
            _zoomWindowSP.graphics.lineStyle(zoomWindowBorderThickness,zoomWindowBorderColor,zoomWindowBorderAlpha,false,"normal","none");
            _zoomWindowSP.graphics.moveTo(0,_zoomWindowParams.startPointInPixels.y);
            _zoomWindowSP.graphics.beginFill(zoomWindowFillColor,zoomWindowFillAlpha);
            _zoomWindowSP.graphics.lineTo(_xAxisSettings.length,_zoomWindowParams.startPointInPixels.y);
            _zoomWindowSP.graphics.lineStyle();
            _zoomWindowSP.graphics.lineTo(_xAxisSettings.length,_zoomWindowParams.endPointInPixels.y);
            _zoomWindowSP.graphics.lineStyle(zoomWindowBorderThickness,zoomWindowBorderColor,zoomWindowBorderAlpha,false,"normal","none");
            _zoomWindowSP.graphics.lineTo(0,_zoomWindowParams.endPointInPixels.y);
            _zoomWindowSP.graphics.lineStyle();
            _zoomWindowSP.graphics.lineTo(0,_zoomWindowParams.startPointInPixels.y);
            _zoomWindowSP.graphics.endFill();
         }
         else if(_zoomMode == "xyZoom")
         {
            _zoomWindowSP.graphics.lineStyle(zoomWindowBorderThickness,zoomWindowBorderColor,zoomWindowBorderAlpha);
            _zoomWindowSP.graphics.moveTo(_zoomWindowParams.startPointInPixels.x,_zoomWindowParams.startPointInPixels.y);
            _zoomWindowSP.graphics.beginFill(zoomWindowFillColor,zoomWindowFillAlpha);
            _zoomWindowSP.graphics.lineTo(_zoomWindowParams.startPointInPixels.x,_zoomWindowParams.endPointInPixels.y);
            _zoomWindowSP.graphics.lineTo(_zoomWindowParams.endPointInPixels.x,_zoomWindowParams.endPointInPixels.y);
            _zoomWindowSP.graphics.lineTo(_zoomWindowParams.endPointInPixels.x,_zoomWindowParams.startPointInPixels.y);
            _zoomWindowSP.graphics.lineTo(_zoomWindowParams.startPointInPixels.x,_zoomWindowParams.startPointInPixels.y);
            _zoomWindowSP.graphics.endFill();
         }
      }
      
      protected function onZoomWindowClicked(param1:Event) : void
      {
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc4_:Object = null;
         var _loc5_:Object = null;
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc10_:Number = NaN;
         var _loc11_:Number = NaN;
         _loc2_ = _xAxisSettings.length / (_xAxisSettings.max - _xAxisSettings.min);
         _loc3_ = -_yAxisSettings.length / (_yAxisSettings.max - _yAxisSettings.min);
         _loc4_ = {};
         _loc4_.x = _xAxisSettings.min + _zoomWindowParams.startPointInPixels.x / _loc2_;
         _loc4_.y = _yAxisSettings.min + _zoomWindowParams.startPointInPixels.y / _loc3_;
         _loc5_ = {};
         _loc5_.x = _xAxisSettings.min + _zoomWindowParams.endPointInPixels.x / _loc2_;
         _loc5_.y = _yAxisSettings.min + _zoomWindowParams.endPointInPixels.y / _loc3_;
         _loc6_ = Math.min(_loc4_.x,_loc5_.x);
         _loc7_ = Math.max(_loc4_.x,_loc5_.x);
         _loc8_ = Math.min(_loc4_.y,_loc5_.y);
         _loc9_ = Math.max(_loc4_.y,_loc5_.y);
         if(!isNaN(xZoomRangeLimit) && isFinite(xZoomRangeLimit) && _loc7_ - _loc6_ < xZoomRangeLimit)
         {
            _loc10_ = _loc6_ + (_loc7_ - _loc6_) / 2;
            _loc6_ = _loc10_ - xZoomRangeLimit / 2;
            _loc7_ = _loc10_ + xZoomRangeLimit / 2;
         }
         if(!isNaN(yZoomRangeLimit) && isFinite(yZoomRangeLimit) && _loc9_ - _loc8_ < yZoomRangeLimit)
         {
            _loc11_ = _loc8_ + (_loc9_ - _loc8_) / 2;
            _loc8_ = _loc11_ - yZoomRangeLimit / 2;
            _loc9_ = _loc11_ + yZoomRangeLimit / 2;
         }
         if(doZoomAnimation)
         {
            if(_zoomMode == "xZoomOnly")
            {
               zoomTo({
                  "xMin":_loc6_,
                  "xMax":_loc7_
               });
            }
            else if(_zoomMode == "yZoomOnly")
            {
               zoomTo({
                  "yMin":_loc8_,
                  "yMax":_loc9_
               });
            }
            else if(_zoomMode == "xyZoom")
            {
               zoomTo({
                  "xMin":_loc6_,
                  "xMax":_loc7_,
                  "yMin":_loc8_,
                  "yMax":_loc9_
               });
            }
         }
         else
         {
            if(_zoomMode == "xZoomOnly")
            {
               setXAxisRange(_loc6_,_loc7_);
            }
            else if(_zoomMode == "yZoomOnly")
            {
               setYAxisRange(_loc8_,_loc9_);
            }
            else if(_zoomMode == "xyZoom")
            {
               lock();
               setXAxisRange(_loc6_,_loc7_);
               setYAxisRange(_loc8_,_loc9_);
               unlock();
            }
            clearZoomWindow();
            dispatchEvent(new Event(Plot.ZOOM_DONE));
         }
      }
      
      protected function getFormattedNumber(param1:Number, param2:int) : String
      {
         var _loc3_:Number = NaN;
         if(param2 >= 0)
         {
            _loc3_ = Math.pow(10,param2);
            return String(_loc3_ * Math.round(param1 / _loc3_));
         }
         return param1.toFixed(-param2);
      }
      
      public function set plotHeight(param1:Number) : void
      {
         if(!isFinite(param1) || isNaN(param1) || param1 <= 0)
         {
            return;
         }
         _yAxisSettings.length = param1;
         updateBackgroundAndBorder();
         update();
      }
      
      protected function updateXAxis() : void
      {
         var _loc1_:Object = null;
         _loc1_ = getTickmarksInfo(_xAxisSettings);
         _xAxisSP.graphics.clear();
         _xAxisSP.graphics.lineStyle(borderThickness,borderColor,borderAlpha);
         _xAxisSP.removeChild(_xAxisTickmarkLabelsSP);
         _xAxisTickmarkLabelsSP = new Sprite();
         _xAxisSP.addChild(_xAxisTickmarkLabelsSP);
         renderXAxisTickmarks({
            "tickmarksList":_loc1_.longTickmarksList,
            "length":tickmarkLengths.long
         });
         renderXAxisTickmarks({
            "tickmarksList":_loc1_.mediumTickmarksList,
            "length":tickmarkLengths.medium
         });
         renderXAxisTickmarks({
            "tickmarksList":_loc1_.shortTickmarksList,
            "length":tickmarkLengths.short
         });
         renderXAxisTickmarkLabels(_loc1_.tickmarkLabelsList);
         _xAxisGridlinesSP.graphics.clear();
         if(_showXAxisGridlines)
         {
            if(gridlineStyles.long.visible)
            {
               _xAxisGridlinesSP.graphics.lineStyle(gridlineStyles.long.thickness,gridlineStyles.long.color,gridlineStyles.long.alpha,false,"normal","none");
               renderXAxisGridlines(_loc1_.longTickmarksList);
            }
            if(gridlineStyles.medium.visible)
            {
               _xAxisGridlinesSP.graphics.lineStyle(gridlineStyles.medium.thickness,gridlineStyles.medium.color,gridlineStyles.medium.alpha,false,"normal","none");
               renderXAxisGridlines(_loc1_.mediumTickmarksList);
            }
            if(gridlineStyles.short.visible)
            {
               _xAxisGridlinesSP.graphics.lineStyle(gridlineStyles.short.thickness,gridlineStyles.short.color,gridlineStyles.short.alpha,false,"normal","none");
               renderXAxisGridlines(_loc1_.shortTickmarksList);
            }
         }
      }
      
      public function get showGridlines() : Boolean
      {
         return _showXAxisGridlines;
      }
      
      public function get locked() : Boolean
      {
         return _locked;
      }
      
      protected function onRefreshSeriesRequested(param1:Event) : void
      {
         var _loc2_:* = undefined;
         for each(_loc2_ in _seriesList)
         {
            if(_loc2_.series == param1.target)
            {
               updateSeries(_loc2_);
               break;
            }
         }
      }
      
      public function get yMin() : Number
      {
         return _yAxisSettings.min;
      }
      
      public function loadSettings(... rest) : void
      {
         loadSettingsFromObjectsList(rest);
      }
      
      public function set invertYAxis(param1:Boolean) : void
      {
         _yAxisSettings.inverted = param1;
         update();
      }
      
      public function lock() : void
      {
         locked = true;
      }
      
      protected function createNewTextField(param1:Object) : TextField
      {
         var _loc2_:TextField = null;
         _loc2_ = new TextField();
         _loc2_.x = param1.x;
         _loc2_.y = param1.y;
         _loc2_.width = 0;
         _loc2_.height = 0;
         _loc2_.selectable = false;
         _loc2_.embedFonts = true;
         _loc2_.defaultTextFormat = param1.format;
         _loc2_.autoSize = param1.autoSize;
         _loc2_.text = param1.text;
         return _loc2_;
      }
      
      public function unlock() : void
      {
         locked = false;
      }
      
      public function removeAllSeries() : void
      {
         var _loc1_:* = undefined;
         for each(_loc1_ in _seriesList)
         {
            removeSeriesDebris(_loc1_);
         }
         _seriesList = [];
      }
      
      protected function loadSettingsFromObjectsList(param1:Array) : void
      {
         var _loc2_:String = null;
         var _loc3_:* = undefined;
         for each(_loc3_ in param1)
         {
            if(_loc3_ is Object)
            {
               for(_loc2_ in _loc3_)
               {
                  this[_loc2_] = _loc3_[_loc2_];
               }
            }
         }
      }
      
      protected function renderYAxisTickmarkLabels(param1:Array) : void
      {
         var _loc2_:TextField = null;
         var _loc3_:* = undefined;
         for each(_loc3_ in param1)
         {
            _loc2_ = createNewTextField({
               "x":-tickmarkLabelsPosition,
               "y":-_loc3_.position,
               "text":_loc3_.label,
               "format":tickmarkLabelsTextFormat,
               "autoSize":"right"
            });
            _loc2_.y -= _loc2_.height / 2;
            _yAxisTickmarkLabelsSP.addChild(_loc2_);
         }
      }
      
      protected function removeSeriesDebris(param1:Object) : void
      {
         param1.series.removeEventListener(PlotSeries.REFRESH_REQUESTED,onRefreshSeriesRequested);
         param1.series.removeEventListener(DataChangeEvent.DATA_CHANGE,onRefreshSeriesRequested);
         _dataLinesSP.removeChild(param1.linesSP);
         _dataPointsSP.removeChild(param1.pointsSP);
      }
      
      public function get plotHeight() : Number
      {
         return _yAxisSettings.length;
      }
      
      public function set xMin(param1:Number) : void
      {
         if(!isFinite(param1) || isNaN(param1) || param1 >= xMax)
         {
            return;
         }
         clearZoomWindow();
         cancelZoomAnimation();
         _xAxisSettings.min = param1;
         update();
      }
      
      public function get invertYAxis() : Boolean
      {
         return _yAxisSettings.inverted;
      }
      
      public function get plotWidth() : Number
      {
         return _xAxisSettings.length;
      }
      
      public function set xMax(param1:Number) : void
      {
         if(!isFinite(param1) || isNaN(param1) || param1 <= xMin)
         {
            return;
         }
         clearZoomWindow();
         cancelZoomAnimation();
         _xAxisSettings.max = param1;
         update();
      }
      
      public function getYAxisRange() : Object
      {
         return {
            "min":_yAxisSettings.min,
            "max":_yAxisSettings.max
         };
      }
      
      protected function renderXAxisTickmarkLabels(param1:Array) : void
      {
         var _loc2_:TextField = null;
         var _loc3_:* = undefined;
         for each(_loc3_ in param1)
         {
            _loc2_ = createNewTextField({
               "x":_loc3_.position,
               "text":_loc3_.label,
               "format":tickmarkLabelsTextFormat,
               "autoSize":"center"
            });
            _loc2_.y = tickmarkLabelsPosition;
            _xAxisTickmarkLabelsSP.addChild(_loc2_);
         }
      }
      
      public function zoomTo(param1:Object) : void
      {
         var _loc2_:Boolean = false;
         var _loc3_:Boolean = false;
         var _loc4_:Boolean = false;
         var _loc5_:Boolean = false;
         if(_zoomAnimationInProgess)
         {
            return;
         }
         _loc2_ = param1.xMin is Number && !isNaN(param1.xMin) && isFinite(param1.xMin);
         _loc3_ = param1.xMax is Number && !isNaN(param1.xMax) && isFinite(param1.xMax);
         _loc4_ = param1.yMin is Number && !isNaN(param1.yMin) && isFinite(param1.yMin);
         _loc5_ = param1.yMax is Number && !isNaN(param1.yMax) && isFinite(param1.yMax);
         if(!_loc2_ && !_loc3_ && !_loc4_ && !_loc5_)
         {
            return;
         }
         clearZoomWindow();
         _zoomAnimationParams = {};
         if(_loc2_)
         {
            _zoomAnimationParams.xMinAtStart = _xAxisSettings.min;
            _zoomAnimationParams.xMinRange = param1.xMin - _xAxisSettings.min;
         }
         if(_loc3_)
         {
            _zoomAnimationParams.xMaxAtStart = _xAxisSettings.max;
            _zoomAnimationParams.xMaxRange = param1.xMax - _xAxisSettings.max;
         }
         if(_loc4_)
         {
            _zoomAnimationParams.yMinAtStart = _yAxisSettings.min;
            _zoomAnimationParams.yMinRange = param1.yMin - _yAxisSettings.min;
         }
         if(_loc5_)
         {
            _zoomAnimationParams.yMaxAtStart = _yAxisSettings.max;
            _zoomAnimationParams.yMaxRange = param1.yMax - _yAxisSettings.max;
         }
         _zoomAnimationParams.startTime = getTimer();
         dispatchEvent(new Event(Plot.ZOOM_START));
         _zoomAnimationInProgess = true;
         addEventListener(Event.ENTER_FRAME,zoomAnimationOnEnterFrameFunc);
      }
      
      protected function stopZoomWindowDragging(... rest) : void
      {
         if(!_zoomWindowParams.isValid)
         {
            clearZoomWindow();
            return;
         }
         updateZoomWindowAppearance();
         _zoomWindowParams.isListening = true;
         _zoomWindowSP.addEventListener(MouseEvent.CLICK,onZoomWindowClicked);
         _zoomWindowParams.draggingInProgress = false;
         stage.removeEventListener(MouseEvent.MOUSE_MOVE,updateZoomWindowDragging);
         stage.removeEventListener(MouseEvent.MOUSE_UP,stopZoomWindowDragging);
      }
      
      public function setYAxisRange(param1:Number, param2:Number) : void
      {
         var _loc3_:Number = NaN;
         if(!isFinite(param1) || isNaN(param1) || !isFinite(param2) || isNaN(param2) || param1 == param2)
         {
            return;
         }
         clearZoomWindow();
         cancelZoomAnimation();
         if(param1 > param2)
         {
            _loc3_ = param1;
            param1 = param2;
            param2 = _loc3_;
         }
         _yAxisSettings.min = param1;
         _yAxisSettings.max = param2;
         update();
      }
      
      protected function updateBackgroundAndBorder() : void
      {
         _backgroundSP.graphics.clear();
         _backgroundSP.graphics.moveTo(0,0);
         _backgroundSP.graphics.beginFill(backgroundColor,backgroundAlpha);
         _backgroundSP.graphics.lineTo(_xAxisSettings.length,0);
         _backgroundSP.graphics.lineTo(_xAxisSettings.length,-_yAxisSettings.length);
         _backgroundSP.graphics.lineTo(0,-_yAxisSettings.length);
         _backgroundSP.graphics.lineTo(0,0);
         _backgroundSP.graphics.endFill();
         _borderSP.graphics.clear();
         _borderSP.graphics.moveTo(0,0);
         _borderSP.graphics.lineStyle(borderThickness,borderColor,borderAlpha);
         _borderSP.graphics.lineTo(_xAxisSettings.length,0);
         _borderSP.graphics.lineTo(_xAxisSettings.length,-_yAxisSettings.length);
         _borderSP.graphics.lineTo(0,-_yAxisSettings.length);
         _borderSP.graphics.lineTo(0,0);
         _dataMaskSP.graphics.clear();
         _dataMaskSP.graphics.moveTo(0,0);
         _dataMaskSP.graphics.beginFill(16711680);
         _dataMaskSP.graphics.lineTo(_xAxisSettings.length,0);
         _dataMaskSP.graphics.lineTo(_xAxisSettings.length,-_yAxisSettings.length);
         _dataMaskSP.graphics.lineTo(0,-_yAxisSettings.length);
         _dataMaskSP.graphics.lineTo(0,0);
         _dataMaskSP.graphics.endFill();
         _mouseAreaSP.graphics.clear();
         _mouseAreaSP.graphics.moveTo(0,0);
         _mouseAreaSP.graphics.beginFill(255,0);
         _mouseAreaSP.graphics.lineTo(_xAxisSettings.length,0);
         _mouseAreaSP.graphics.lineTo(_xAxisSettings.length,-_yAxisSettings.length);
         _mouseAreaSP.graphics.lineTo(0,-_yAxisSettings.length);
         _mouseAreaSP.graphics.lineTo(0,0);
         _mouseAreaSP.graphics.endFill();
      }
      
      public function get xMax() : Number
      {
         return _xAxisSettings.max;
      }
      
      protected function clearZoomWindow() : void
      {
         _zoomWindowSP.graphics.clear();
         if(_zoomWindowParams != null)
         {
            if(_zoomWindowParams.isListening)
            {
               _zoomWindowSP.removeEventListener(MouseEvent.CLICK,onZoomWindowClicked);
            }
            if(_zoomWindowParams.draggingInProgress)
            {
               stage.removeEventListener(MouseEvent.MOUSE_MOVE,updateZoomWindowDragging);
               stage.removeEventListener(MouseEvent.MOUSE_UP,stopZoomWindowDragging);
            }
         }
         _zoomWindowParams = null;
      }
      
      public function set showGridlines(param1:Boolean) : void
      {
         _showXAxisGridlines = _showYAxisGridlines = param1;
         updateXAxis();
         updateYAxis();
      }
   }
}

class AxisSettingsObject
{
   
   public var max:Number = 10;
   
   public var length:Number = 300;
   
   public var minSpacingForTickmarks:Number = 10;
   
   public var min:Number = 0;
   
   public var inverted:Boolean = false;
   
   public var minSpacingForLabels:Number = 30;
   
   public function AxisSettingsObject()
   {
      super();
   }
}
