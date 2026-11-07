package
{
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.FocusEvent;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import flash.ui.Keyboard;
   import flash.utils.getTimer;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol71")]
   public class ProtoCyclicSimpleSlider extends MovieClip
   {
      
      protected var _grabberXOffset:Number;
      
      public var valueField:TextField;
      
      protected var _barWaitTime:Number;
      
      public var grabberMC:MovieClip;
      
      protected var _active:Boolean = false;
      
      public var barMC:MovieClip;
      
      protected var _continuousChangeDelay:Number = 500;
      
      protected var _barTimeLast:Number;
      
      public var _controller:ProtoSliderLogic;
      
      protected var _continuousChangeRate:Number = 0.05;
      
      public function ProtoCyclicSimpleSlider()
      {
         super();
         stop();
         valueField.restrict = "0-9.Ee+\\-";
         _controller = new ProtoSliderLogic({
            "scalingMode":"linear",
            "valueFormat":"fixed digits",
            "valueDigits":1,
            "minValue":1,
            "maxValue":10,
            "minParameter":0,
            "maxParameter":120,
            "value":5
         });
         updateSync();
         grabberMC.addEventListener("mouseDown",grabberOnMouseDown);
         barMC.addEventListener("mouseDown",barOnMouseDown);
         barMC.tabEnabled = false;
         barMC.useHandCursor = false;
         valueField.embedFonts = true;
         valueField.addEventListener("change",valueFieldOnChange);
         valueField.addEventListener("focusOut",valueFieldOnFocusOut);
         barMC.focusRect = false;
         grabberMC.focusRect = false;
      }
      
      public function incrementValue(param1:int, param2:Boolean = false) : void
      {
         _controller.incrementValue(param1);
         updateSync();
         if(param2)
         {
            dispatchEvent(new Event("sliderChange"));
         }
      }
      
      public function grabberOnMouseMove(param1:MouseEvent) : void
      {
         var _loc2_:Number = _controller.getValueFromParameter(mouseX - _grabberXOffset);
         var _loc3_:Number = _controller._maxV - _controller._minV;
         _loc2_ = _controller._minV + ((_loc2_ - _controller._minV) % _loc3_ + _loc3_) % _loc3_;
         var _loc4_:Object = _controller.getValueObjectFromValue(_loc2_);
         if(_loc4_.value != _controller.value)
         {
            setValueByValueObject(_loc4_,true);
         }
         param1.updateAfterEvent();
      }
      
      public function updateSync() : void
      {
         grabberMC.x = _controller.parameter;
         valueField.text = _controller.valueString;
      }
      
      public function valueFieldOnFocusOut(param1:FocusEvent) : void
      {
         if(_active)
         {
            setActiveState(false);
            if(stage.focus == grabberMC || stage.focus == barMC)
            {
               updateSync();
            }
            else
            {
               setValue(parseFloat(valueField.text),true);
            }
         }
      }
      
      public function setValueFormat(param1:String, param2:int) : void
      {
         _controller.setValueFormat(param1,param2);
         updateSync();
      }
      
      public function setScalingMode(param1:String) : void
      {
         _controller.setScalingMode(param1);
         updateSync();
      }
      
      public function grabberOnMouseDown(... rest) : void
      {
         stage.focus = grabberMC;
         _grabberXOffset = mouseX - grabberMC.x;
         stage.addEventListener("mouseUp",grabberOnMouseUp);
         stage.addEventListener("mouseMove",grabberOnMouseMove);
      }
      
      public function grabberOnMouseUp(... rest) : void
      {
         stage.removeEventListener("mouseUp",grabberOnMouseUp);
         stage.removeEventListener("mouseMove",grabberOnMouseMove);
      }
      
      public function setValueByValueObject(param1:Object, param2:Boolean = false) : void
      {
         _controller.setValueByValueObject(param1);
         updateSync();
         if(param2)
         {
            dispatchEvent(new Event("sliderChange"));
         }
      }
      
      public function setValueRange(param1:*, param2:*) : void
      {
         _controller.setValueAndParameterRanges(param1,param2,0,120);
         updateSync();
      }
      
      public function getValueIndex() : int
      {
         return _controller.getClosestIndex();
      }
      
      public function valueFieldOnChange(... rest) : void
      {
         setActiveState(true);
      }
      
      public function setRangeType(param1:String, param2:Array = null) : void
      {
         _controller.setRangeType(param1,param2);
         updateSync();
      }
      
      public function set value(param1:Number) : void
      {
         if(!isNaN(param1) && isFinite(param1))
         {
            _controller.value = param1;
         }
         updateSync();
      }
      
      public function get max() : Number
      {
         return _controller._maxV;
      }
      
      public function barOnEnterFrame(... rest) : void
      {
         var _loc3_:int = 0;
         var _loc4_:Object = null;
         var _loc5_:Object = null;
         var _loc2_:Number = getTimer();
         if(_loc2_ > _barWaitTime)
         {
            _loc3_ = _continuousChangeRate * (_loc2_ - _barTimeLast);
            _loc4_ = _controller.getValueObjectFromValue(_controller.getValueFromParameter(mouseX));
            if(_loc4_.value < _controller.value)
            {
               _loc5_ = _controller.getIncrementedValueObject(null,-_loc3_);
               if(_loc5_.value <= _loc4_.value)
               {
                  setValueByValueObject(_loc4_,true);
               }
               else
               {
                  setValueByValueObject(_loc5_,true);
               }
            }
            else if(_loc4_.value > _controller.value)
            {
               _loc5_ = _controller.getIncrementedValueObject(null,_loc3_);
               if(_loc5_.value >= _loc4_.value)
               {
                  setValueByValueObject(_loc4_,true);
               }
               else
               {
                  setValueByValueObject(_loc5_,true);
               }
            }
         }
         _barTimeLast = _loc2_;
      }
      
      public function get min() : Number
      {
         return _controller._minV;
      }
      
      public function setValue(param1:Number, param2:Boolean = false) : void
      {
         if(!isNaN(param1) && isFinite(param1))
         {
            _controller.value = param1;
         }
         updateSync();
         if(param2)
         {
            dispatchEvent(new Event("sliderChange"));
         }
      }
      
      protected function setActiveState(param1:Boolean) : void
      {
         if(param1 == _active)
         {
            return;
         }
         _active = param1;
         var _loc2_:TextFormat = valueField.defaultTextFormat;
         if(_active)
         {
            gotoAndStop(2);
            _loc2_.italic = true;
            valueField.addEventListener("keyDown",valueFieldOnKeyDown);
            valueField.removeEventListener("change",valueFieldOnChange);
            stage.addEventListener("mouseDown",valueFieldOnMouseDown);
         }
         else
         {
            gotoAndStop(1);
            _loc2_.italic = false;
            valueField.removeEventListener("keyDown",valueFieldOnKeyDown);
            valueField.addEventListener("change",valueFieldOnChange);
            stage.removeEventListener("mouseDown",valueFieldOnMouseDown);
         }
         valueField.setTextFormat(_loc2_);
         valueField.defaultTextFormat = _loc2_;
      }
      
      public function get value() : Number
      {
         return _controller.value;
      }
      
      public function barOnMouseDown(... rest) : void
      {
         stage.focus = barMC;
         var _loc2_:Number = Number(_controller.getValueObjectFromValue(_controller.getValueFromParameter(mouseX)).value);
         if(_loc2_ < _controller.value)
         {
            incrementValue(-1,true);
         }
         else if(_loc2_ > _controller.value)
         {
            incrementValue(1,true);
         }
         _barTimeLast = getTimer();
         _barWaitTime = _barTimeLast + _continuousChangeDelay;
         stage.addEventListener("enterFrame",barOnEnterFrame);
         stage.addEventListener("mouseUp",barOnMouseUp);
      }
      
      public function setEnabled(param1:Boolean) : void
      {
         setActiveState(false);
         var _loc2_:TextFormat = valueField.defaultTextFormat;
         if(param1)
         {
            valueField.selectable = true;
            gotoAndStop(1);
            _loc2_.color = 0;
            grabberMC.addEventListener("mouseDown",grabberOnMouseDown);
            barMC.addEventListener("mouseDown",barOnMouseDown);
         }
         else
         {
            valueField.selectable = false;
            gotoAndStop(3);
            _loc2_.color = 3552822;
            grabberMC.removeEventListener("mouseDown",grabberOnMouseDown);
            barMC.removeEventListener("mouseDown",barOnMouseDown);
         }
         valueField.setTextFormat(_loc2_);
         valueField.defaultTextFormat = _loc2_;
      }
      
      public function valueFieldOnKeyDown(param1:KeyboardEvent) : void
      {
         if(param1.keyCode == Keyboard.ENTER)
         {
            setActiveState(false);
            setValue(parseFloat(valueField.text),true);
         }
      }
      
      public function barOnMouseUp(... rest) : void
      {
         stage.removeEventListener("enterFrame",barOnEnterFrame);
         stage.removeEventListener("mouseUp",barOnMouseUp);
      }
      
      public function valueFieldOnMouseDown(... rest) : void
      {
         setActiveState(false);
         setValue(parseFloat(valueField.text),true);
      }
   }
}

