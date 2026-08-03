package
{
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.utils.getTimer;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol127")]
   public class ProtoSimpleSliderRunSpeed extends MovieClip
   {
      
      protected var _grabberXOffset:Number;
      
      protected var _barWaitTime:Number;
      
      public var grabberMC:MovieClip;
      
      protected var _active:Boolean = false;
      
      public var barMC:MovieClip;
      
      protected var _continuousChangeDelay:Number = 500;
      
      protected var _barTimeLast:Number;
      
      protected var _controller:ProtoSliderLogic;
      
      protected var _continuousChangeRate:Number = 0.05;
      
      public function ProtoSimpleSliderRunSpeed()
      {
         super();
         stop();
         _controller = new ProtoSliderLogic({
            "scalingMode":"linear",
            "valueFormat":"fixed digits",
            "valueDigits":1,
            "minValue":1,
            "maxValue":10,
            "minParameter":0,
            "maxParameter":70,
            "value":5
         });
         updateSync();
         grabberMC.addEventListener("mouseDown",grabberOnMouseDown);
         barMC.addEventListener("mouseDown",barOnMouseDown);
         barMC.tabEnabled = false;
         barMC.useHandCursor = false;
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
         var _loc2_:Object = _controller.getValueObjectFromValue(_controller.getValueFromParameter(mouseX - _grabberXOffset));
         if(_loc2_.value != _controller.value)
         {
            setValueByValueObject(_loc2_,true);
         }
         param1.updateAfterEvent();
      }
      
      public function updateSync() : void
      {
         grabberMC.x = _controller.parameter;
      }
      
      public function grabberOnMouseDown(... rest) : void
      {
         stage.focus = grabberMC;
         _grabberXOffset = mouseX - grabberMC.x;
         stage.addEventListener("mouseUp",grabberOnMouseUp);
         stage.addEventListener("mouseMove",grabberOnMouseMove);
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
      
      public function grabberOnMouseUp(... rest) : void
      {
         stage.removeEventListener("mouseUp",grabberOnMouseUp);
         stage.removeEventListener("mouseMove",grabberOnMouseMove);
      }
      
      public function setValueRange(param1:*, param2:*) : void
      {
         _controller.setValueAndParameterRanges(param1,param2,0,70);
         updateSync();
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
      
      public function barOnMouseUp(... rest) : void
      {
         stage.removeEventListener("enterFrame",barOnEnterFrame);
         stage.removeEventListener("mouseUp",barOnMouseUp);
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
            trace("WARNING, redundant setting of active state");
            return;
         }
         _active = param1;
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
   }
}

