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
   
   [Embed(source="/_assets/assets.swf", symbol="symbol96")]
   public class ProtoSimpleSlider extends MovieClip
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
      
      public function ProtoSimpleSlider()
      {
         super();
         stop();
         this.valueField.restrict = "0-9.Ee+\\-";
         this._controller = new ProtoSliderLogic({
            "scalingMode":"linear",
            "valueFormat":"fixed digits",
            "valueDigits":1,
            "minValue":1,
            "maxValue":10,
            "minParameter":0,
            "maxParameter":120,
            "value":5
         });
         this.updateSync();
         this.grabberMC.addEventListener("mouseDown",this.grabberOnMouseDown);
         this.barMC.addEventListener("mouseDown",this.barOnMouseDown);
         this.barMC.tabEnabled = false;
         this.barMC.useHandCursor = false;
         this.valueField.embedFonts = true;
         this.valueField.addEventListener("change",this.valueFieldOnChange);
         this.valueField.addEventListener("focusOut",this.valueFieldOnFocusOut);
         this.barMC.focusRect = false;
         this.grabberMC.focusRect = false;
      }
      
      public function incrementValue(param1:int, param2:Boolean = false) : void
      {
         this._controller.incrementValue(param1);
         this.updateSync();
         if(param2)
         {
            dispatchEvent(new Event("sliderChange"));
         }
      }
      
      public function grabberOnMouseMove(param1:MouseEvent) : void
      {
         var _loc2_:Object = this._controller.getValueObjectFromValue(this._controller.getValueFromParameter(mouseX - this._grabberXOffset));
         if(_loc2_.value != this._controller.value)
         {
            this.setValueByValueObject(_loc2_,true);
         }
         param1.updateAfterEvent();
      }
      
      public function updateSync() : void
      {
         this.grabberMC.x = this._controller.parameter;
         this.valueField.text = this._controller.valueString;
      }
      
      public function valueFieldOnFocusOut(param1:FocusEvent) : void
      {
         if(this._active)
         {
            this.setActiveState(false);
            if(stage.focus == this.grabberMC || stage.focus == this.barMC)
            {
               this.updateSync();
            }
            else
            {
               this.setValue(parseFloat(this.valueField.text),true);
            }
         }
      }
      
      public function setValueFormat(param1:String, param2:int) : void
      {
         this._controller.setValueFormat(param1,param2);
         this.updateSync();
      }
      
      public function setScalingMode(param1:String) : void
      {
         this._controller.setScalingMode(param1);
         this.updateSync();
      }
      
      public function grabberOnMouseDown(... rest) : void
      {
         stage.focus = this.grabberMC;
         this._grabberXOffset = mouseX - this.grabberMC.x;
         stage.addEventListener("mouseUp",this.grabberOnMouseUp);
         stage.addEventListener("mouseMove",this.grabberOnMouseMove);
      }
      
      public function grabberOnMouseUp(... rest) : void
      {
         stage.removeEventListener("mouseUp",this.grabberOnMouseUp);
         stage.removeEventListener("mouseMove",this.grabberOnMouseMove);
      }
      
      public function setValueByValueObject(param1:Object, param2:Boolean = false) : void
      {
         this._controller.setValueByValueObject(param1);
         this.updateSync();
         if(param2)
         {
            dispatchEvent(new Event("sliderChange"));
         }
      }
      
      public function setValueRange(param1:*, param2:*) : void
      {
         this._controller.setValueAndParameterRanges(param1,param2,0,120);
         this.updateSync();
      }
      
      public function getValueIndex() : int
      {
         return this._controller.getClosestIndex();
      }
      
      public function valueFieldOnChange(... rest) : void
      {
         this.setActiveState(true);
      }
      
      public function setRangeType(param1:String, param2:Array = null) : void
      {
         this._controller.setRangeType(param1,param2);
         this.updateSync();
      }
      
      public function set value(param1:Number) : void
      {
         if(!isNaN(param1) && isFinite(param1))
         {
            this._controller.value = param1;
         }
         this.updateSync();
      }
      
      public function get max() : Number
      {
         return this._controller._maxV;
      }
      
      public function barOnEnterFrame(... rest) : void
      {
         var _loc3_:int = 0;
         var _loc4_:Object = null;
         var _loc5_:Object = null;
         var _loc2_:Number = getTimer();
         if(_loc2_ > this._barWaitTime)
         {
            _loc3_ = this._continuousChangeRate * (_loc2_ - this._barTimeLast);
            _loc4_ = this._controller.getValueObjectFromValue(this._controller.getValueFromParameter(mouseX));
            if(_loc4_.value < this._controller.value)
            {
               _loc5_ = this._controller.getIncrementedValueObject(null,-_loc3_);
               if(_loc5_.value <= _loc4_.value)
               {
                  this.setValueByValueObject(_loc4_,true);
               }
               else
               {
                  this.setValueByValueObject(_loc5_,true);
               }
            }
            else if(_loc4_.value > this._controller.value)
            {
               _loc5_ = this._controller.getIncrementedValueObject(null,_loc3_);
               if(_loc5_.value >= _loc4_.value)
               {
                  this.setValueByValueObject(_loc4_,true);
               }
               else
               {
                  this.setValueByValueObject(_loc5_,true);
               }
            }
         }
         this._barTimeLast = _loc2_;
      }
      
      public function get min() : Number
      {
         return this._controller._minV;
      }
      
      public function setValue(param1:Number, param2:Boolean = false) : void
      {
         if(!isNaN(param1) && isFinite(param1))
         {
            this._controller.value = param1;
         }
         this.updateSync();
         if(param2)
         {
            dispatchEvent(new Event("sliderChange"));
         }
      }
      
      protected function setActiveState(param1:Boolean) : void
      {
         if(param1 == this._active)
         {
            return;
         }
         this._active = param1;
         var _loc2_:TextFormat = this.valueField.defaultTextFormat;
         if(this._active)
         {
            gotoAndStop(2);
            _loc2_.italic = true;
            this.valueField.addEventListener("keyDown",this.valueFieldOnKeyDown);
            this.valueField.removeEventListener("change",this.valueFieldOnChange);
            stage.addEventListener("mouseDown",this.valueFieldOnMouseDown);
         }
         else
         {
            gotoAndStop(1);
            _loc2_.italic = false;
            this.valueField.removeEventListener("keyDown",this.valueFieldOnKeyDown);
            this.valueField.addEventListener("change",this.valueFieldOnChange);
            stage.removeEventListener("mouseDown",this.valueFieldOnMouseDown);
         }
         this.valueField.setTextFormat(_loc2_);
         this.valueField.defaultTextFormat = _loc2_;
      }
      
      public function get value() : Number
      {
         return this._controller.value;
      }
      
      public function barOnMouseDown(... rest) : void
      {
         stage.focus = this.barMC;
         var _loc2_:Number = Number(this._controller.getValueObjectFromValue(this._controller.getValueFromParameter(mouseX)).value);
         if(_loc2_ < this._controller.value)
         {
            this.incrementValue(-1,true);
         }
         else if(_loc2_ > this._controller.value)
         {
            this.incrementValue(1,true);
         }
         this._barTimeLast = getTimer();
         this._barWaitTime = this._barTimeLast + this._continuousChangeDelay;
         stage.addEventListener("enterFrame",this.barOnEnterFrame);
         stage.addEventListener("mouseUp",this.barOnMouseUp);
      }
      
      public function setEnabled(param1:Boolean) : void
      {
         this.setActiveState(false);
         var _loc2_:TextFormat = this.valueField.defaultTextFormat;
         if(param1)
         {
            this.valueField.selectable = true;
            gotoAndStop(1);
            _loc2_.color = 0;
            this.grabberMC.addEventListener("mouseDown",this.grabberOnMouseDown);
            this.barMC.addEventListener("mouseDown",this.barOnMouseDown);
         }
         else
         {
            this.valueField.selectable = false;
            gotoAndStop(3);
            _loc2_.color = 3552822;
            this.grabberMC.removeEventListener("mouseDown",this.grabberOnMouseDown);
            this.barMC.removeEventListener("mouseDown",this.barOnMouseDown);
         }
         this.valueField.setTextFormat(_loc2_);
         this.valueField.defaultTextFormat = _loc2_;
      }
      
      public function valueFieldOnKeyDown(param1:KeyboardEvent) : void
      {
         if(param1.keyCode == Keyboard.ENTER)
         {
            this.setActiveState(false);
            this.setValue(parseFloat(this.valueField.text),true);
         }
      }
      
      public function barOnMouseUp(... rest) : void
      {
         stage.removeEventListener("enterFrame",this.barOnEnterFrame);
         stage.removeEventListener("mouseUp",this.barOnMouseUp);
      }
      
      public function valueFieldOnMouseDown(... rest) : void
      {
         this.setActiveState(false);
         this.setValue(parseFloat(this.valueField.text),true);
      }
   }
}

