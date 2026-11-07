package
{
   import astroUNL.utils.PhaseDisc;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.FocusEvent;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.ui.Keyboard;
   import flash.utils.getTimer;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol29")]
   public class ProtoSimpleSliderMoonPhase extends MovieClip
   {
      
      protected var _grabberXOffset:Number;
      
      protected var _snapInterval:Number = 0.7853981633974483;
      
      public var focusIndicator:MovieClip;
      
      public var grabberMC:MovieClip;
      
      protected const _minValue:Number = 0;
      
      protected var _continuousChangeDelay:Number = 500;
      
      protected var _focusIndicator:NAAP_focusRectSkin;
      
      public var _controller:ProtoSliderLogicCyclic;
      
      protected const _maxValue:Number = 6.283185307179586;
      
      protected var _barWaitTime:Number;
      
      protected const _maxParam:Number = 200;
      
      public var barMC:Bar;
      
      protected var _barTimeLast:Number;
      
      protected var _continuousChangeRate:Number = 0.05;
      
      public function ProtoSimpleSliderMoonPhase()
      {
         var _loc1_:int = 0;
         var _loc4_:Number = NaN;
         var _loc5_:PhaseDisc = null;
         super();
         stop();
         this.focusIndicator.visible = false;
         this._controller = new ProtoSliderLogicCyclic({
            "scalingMode":"linear",
            "valueFormat":"fixed digits",
            "valueDigits":2,
            "minValue":this._minValue,
            "maxValue":this._maxValue,
            "minParameter":0,
            "maxParameter":this._maxParam,
            "value":0
         });
         this.updateSync();
         this.grabberMC.addEventListener("mouseDown",this.grabberOnMouseDown);
         this.barMC.addEventListener("mouseDown",this.barOnMouseDown);
         tabEnabled = true;
         mouseEnabled = true;
         tabChildren = false;
         this.barMC.tabEnabled = false;
         this.grabberMC.tabEnabled = false;
         focusRect = false;
         this.barMC.focusRect = false;
         this.grabberMC.focusRect = false;
         var _loc2_:Object = {
            "radius":4.5,
            "lightColor":12105912,
            "darkColor":0
         };
         var _loc3_:Number = 19;
         _loc1_ = 0;
         while(_loc1_ < 8)
         {
            _loc4_ = _loc1_ / 8 * 2 * Math.PI;
            _loc2_.phaseAngle = Math.PI - _loc4_;
            _loc5_ = new PhaseDisc(_loc2_);
            _loc5_.x = this._controller.getParameterFromValue(_loc4_);
            _loc5_.y = _loc3_;
            _loc5_.buttonMode = true;
            _loc5_.tabEnabled = false;
            _loc5_.addEventListener(MouseEvent.CLICK,this.onPhaseDiscClicked);
            addChild(_loc5_);
            _loc1_++;
         }
         _loc4_ = 2 * Math.PI;
         _loc2_.phaseAngle = Math.PI - _loc4_;
         _loc5_ = new PhaseDisc(_loc2_);
         _loc5_.x = this._maxParam;
         _loc5_.y = _loc3_;
         _loc5_.buttonMode = true;
         _loc5_.tabEnabled = false;
         _loc5_.addEventListener(MouseEvent.CLICK,this.onPhaseDiscClicked);
         addChild(_loc5_);
         addEventListener(FocusEvent.FOCUS_IN,this.onFocusInFunc);
         addEventListener(FocusEvent.FOCUS_OUT,this.onFocusOutFunc);
         addEventListener(FocusEvent.KEY_FOCUS_CHANGE,this.onKeyFocusChangeFunc);
         addEventListener(FocusEvent.MOUSE_FOCUS_CHANGE,this.onMouseFocusChangeFunc);
      }
      
      public function updateSync() : void
      {
         this.grabberMC.x = this._controller.parameter;
      }
      
      public function grabberOnMouseDown(... rest) : void
      {
         this._grabberXOffset = mouseX - this.grabberMC.x;
         stage.addEventListener("mouseUp",this.grabberOnMouseUp);
         stage.addEventListener("mouseMove",this.grabberOnMouseMove);
      }
      
      public function setValueFormat(param1:String, param2:int) : void
      {
         this._controller.setValueFormat(param1,param2);
         this.updateSync();
      }
      
      protected function onFocusInFunc(param1:FocusEvent) : void
      {
         this.focusIndicator.visible = true;
         addEventListener(KeyboardEvent.KEY_DOWN,this.onKeyDownFunc,false,0,true);
      }
      
      protected function onMouseFocusChangeFunc(param1:FocusEvent) : void
      {
         if(stage.focus == this)
         {
            stage.focus = null;
         }
      }
      
      protected function onKeyDownFunc(param1:KeyboardEvent) : void
      {
         if(param1.keyCode == Keyboard.LEFT || param1.keyCode == Keyboard.DOWN)
         {
            if(param1.shiftKey)
            {
               this.setValue(this._snapInterval * (Math.round(this._controller.value / this._snapInterval) - 1),true);
            }
            else
            {
               this.incrementValue(-1,true);
            }
         }
         else if(param1.keyCode == Keyboard.RIGHT || param1.keyCode == Keyboard.UP)
         {
            if(param1.shiftKey)
            {
               this.setValue(this._snapInterval * (Math.round(this._controller.value / this._snapInterval) + 1),true);
            }
            else
            {
               this.incrementValue(1,true);
            }
         }
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
            dispatchEvent(new Event(Event.CHANGE));
         }
      }
      
      public function grabberOnMouseMove(param1:MouseEvent) : void
      {
         var _loc2_:Object = null;
         var _loc3_:Number = NaN;
         if(param1.shiftKey)
         {
            _loc2_ = this._controller.getValueObjectFromValue(this._controller.getValueFromParameter(mouseX));
            _loc3_ = this._snapInterval * Math.round(_loc2_.value / this._snapInterval);
            if(_loc3_ != this._controller.value)
            {
               this.setValue(_loc3_,true);
            }
         }
         else
         {
            _loc2_ = this._controller.getValueObjectFromValue(this._controller.getValueFromParameter(mouseX - this._grabberXOffset));
            if(_loc2_.value != this._controller.value)
            {
               this.setValueByValueObject(_loc2_,true);
            }
         }
         param1.updateAfterEvent();
      }
      
      public function barOnMouseDown(... rest) : void
      {
         var _loc2_:Number = NaN;
         if(this._controller._cyclic && (mouseX <= this._controller._minP || mouseX >= this._controller._maxP))
         {
            if(mouseX <= this._controller._minP)
            {
               this.incrementValue(-1,true);
            }
            else
            {
               this.incrementValue(1,true);
            }
         }
         else
         {
            _loc2_ = Number(this._controller.getValueObjectFromValue(this._controller.getValueFromParameter(mouseX)).value);
            if(_loc2_ < this._controller.value)
            {
               this.incrementValue(-1,true);
            }
            else if(_loc2_ > this._controller.value)
            {
               this.incrementValue(1,true);
            }
         }
         this._barTimeLast = getTimer();
         this._barWaitTime = this._barTimeLast + this._continuousChangeDelay;
         stage.addEventListener("enterFrame",this.barOnEnterFrame);
         stage.addEventListener("mouseUp",this.barOnMouseUp);
      }
      
      protected function onFocusOutFunc(param1:FocusEvent) : void
      {
         this.focusIndicator.visible = false;
         removeEventListener(KeyboardEvent.KEY_DOWN,this.onKeyDownFunc,false);
      }
      
      public function grabberOnMouseUp(... rest) : void
      {
         stage.removeEventListener("mouseUp",this.grabberOnMouseUp);
         stage.removeEventListener("mouseMove",this.grabberOnMouseMove);
      }
      
      public function incrementValue(param1:int, param2:Boolean = false) : void
      {
         this._controller.incrementValue(param1);
         this.updateSync();
         if(param2)
         {
            dispatchEvent(new Event(Event.CHANGE));
         }
      }
      
      public function setValueByValueObject(param1:Object, param2:Boolean = false) : void
      {
         this._controller.setValueByValueObject(param1);
         this.updateSync();
         if(param2)
         {
            dispatchEvent(new Event(Event.CHANGE));
         }
      }
      
      public function getValueIndex() : int
      {
         return this._controller.getClosestIndex();
      }
      
      public function get min() : Number
      {
         return this._controller._minV;
      }
      
      protected function onPhaseDiscClicked(param1:MouseEvent) : void
      {
         this.setValue(Math.PI - (param1.target as PhaseDisc).phaseAngle,true);
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
            if(this._controller._cyclic && (mouseX <= this._controller._minP || mouseX >= this._controller._maxP))
            {
               if(mouseX <= this._controller._minP)
               {
                  this.incrementValue(-_loc3_,true);
               }
               else
               {
                  this.incrementValue(_loc3_,true);
               }
            }
            else
            {
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
         }
         this._barTimeLast = _loc2_;
      }
      
      protected function onKeyFocusChangeFunc(param1:FocusEvent) : void
      {
         if(param1.keyCode == Keyboard.LEFT || param1.keyCode == Keyboard.RIGHT || param1.keyCode == Keyboard.UP || param1.keyCode == Keyboard.DOWN)
         {
            param1.preventDefault();
         }
      }
      
      public function barOnMouseUp(... rest) : void
      {
         stage.removeEventListener("enterFrame",this.barOnEnterFrame);
         stage.removeEventListener("mouseUp",this.barOnMouseUp);
      }
      
      public function get value() : Number
      {
         return this._controller.value;
      }
      
      public function setEnabled(param1:Boolean) : void
      {
         if(param1)
         {
            tabEnabled = true;
            mouseEnabled = true;
            mouseChildren = true;
            this.grabberMC.addEventListener("mouseDown",this.grabberOnMouseDown);
            this.barMC.addEventListener("mouseDown",this.barOnMouseDown);
         }
         else
         {
            if(stage.focus == this)
            {
               stage.focus = null;
            }
            tabEnabled = false;
            mouseEnabled = false;
            mouseChildren = false;
            this.grabberMC.removeEventListener("mouseDown",this.grabberOnMouseDown);
            this.barMC.removeEventListener("mouseDown",this.barOnMouseDown);
         }
      }
   }
}

