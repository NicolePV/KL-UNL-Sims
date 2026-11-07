package
{
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.FocusEvent;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   import flash.ui.Keyboard;
   import flash.ui.Mouse;
   import flash.ui.MouseCursor;
   
   public class DraggableDiagramObject extends Sprite
   {
      
      public var propertyName:String;
      
      public var sunlightField:TextField;
      
      public var diagram:Diagram;
      
      protected var _snapInterval:Number = 0.7853981633974483;
      
      protected var _angleOffset:Number;
      
      public var focusIndicator:MovieClip;
      
      public var shadow:MovieClip;
      
      protected var _incrementStep:Number = 0.01;
      
      protected var _initAngle:Number;
      
      protected var _mouseIsOver:Boolean;
      
      protected var _dragIsInProgress:Boolean;
      
      public var eventType:String;
      
      public function DraggableDiagramObject()
      {
         super();
         this.focusIndicator.visible = false;
         addEventListener(MouseEvent.MOUSE_OVER,this.onMouseOverFunc);
         addEventListener(MouseEvent.MOUSE_OUT,this.onMouseOutFunc);
         addEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDownFunc);
         addEventListener(FocusEvent.FOCUS_IN,this.onFocusInFunc);
         addEventListener(FocusEvent.FOCUS_OUT,this.onFocusOutFunc);
         addEventListener(FocusEvent.KEY_FOCUS_CHANGE,this.onKeyFocusChangeFunc);
         addEventListener(FocusEvent.MOUSE_FOCUS_CHANGE,this.onMouseFocusChangeFunc);
         tabEnabled = true;
         mouseEnabled = true;
         focusRect = false;
         tabChildren = false;
         mouseChildren = false;
      }
      
      protected function updateDragIndicators() : void
      {
         if(this._dragIsInProgress)
         {
            Mouse.cursor = MouseCursor.HAND;
         }
         else if(this._mouseIsOver)
         {
            Mouse.cursor = MouseCursor.HAND;
         }
         else
         {
            Mouse.cursor = MouseCursor.AUTO;
         }
      }
      
      protected function onMouseOutFunc(param1:MouseEvent) : void
      {
         this._mouseIsOver = false;
         this.updateDragIndicators();
      }
      
      protected function onMouseMoveFunc(param1:MouseEvent) : void
      {
         var _loc2_:Number = Math.atan2(-this.diagram.mouseY,this.diagram.mouseX) + this._angleOffset;
         if(param1.shiftKey)
         {
            _loc2_ = this._snapInterval * Math.round(_loc2_ / this._snapInterval);
         }
         this.diagram[this.propertyName] = _loc2_;
         this.diagram.dispatchEvent(new Event(this.eventType));
         this.diagram.hideFirstRunInstructions();
         param1.updateAfterEvent();
      }
      
      protected function onFocusInFunc(param1:FocusEvent) : void
      {
         this.focusIndicator.visible = true;
         addEventListener(KeyboardEvent.KEY_DOWN,this.onKeyDownFunc,false,0,true);
      }
      
      protected function onMouseOverFunc(param1:MouseEvent) : void
      {
         this._mouseIsOver = true;
         this.updateDragIndicators();
      }
      
      protected function onKeyFocusChangeFunc(param1:FocusEvent) : void
      {
         if(param1.keyCode == Keyboard.LEFT || param1.keyCode == Keyboard.RIGHT || param1.keyCode == Keyboard.UP || param1.keyCode == Keyboard.DOWN)
         {
            param1.preventDefault();
         }
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
               this.diagram[this.propertyName] = this._snapInterval * (Math.round(this.diagram[this.propertyName] / this._snapInterval) - 1);
            }
            else
            {
               this.diagram[this.propertyName] -= this._incrementStep;
            }
            this.diagram.dispatchEvent(new Event(this.eventType));
            this.diagram.hideFirstRunInstructions();
         }
         else if(param1.keyCode == Keyboard.RIGHT || param1.keyCode == Keyboard.UP)
         {
            if(param1.shiftKey)
            {
               this.diagram[this.propertyName] = this._snapInterval * (Math.round(this.diagram[this.propertyName] / this._snapInterval) + 1);
            }
            else
            {
               this.diagram[this.propertyName] += this._incrementStep;
            }
            this.diagram.dispatchEvent(new Event(this.eventType));
            this.diagram.hideFirstRunInstructions();
         }
      }
      
      protected function onFocusOutFunc(param1:FocusEvent) : void
      {
         this.focusIndicator.visible = false;
         removeEventListener(KeyboardEvent.KEY_DOWN,this.onKeyDownFunc,false);
      }
      
      protected function onMouseDownFunc(param1:MouseEvent) : void
      {
         this._dragIsInProgress = true;
         this.updateDragIndicators();
         this._angleOffset = this.diagram[this.propertyName] - Math.atan2(-this.diagram.mouseY,this.diagram.mouseX);
         stage.addEventListener(MouseEvent.MOUSE_MOVE,this.onMouseMoveFunc,false,0,true);
         stage.addEventListener(MouseEvent.MOUSE_UP,this.onMouseUpFunc,false,0,true);
      }
      
      protected function onMouseUpFunc(param1:MouseEvent) : void
      {
         this._dragIsInProgress = false;
         this.updateDragIndicators();
         stage.removeEventListener(MouseEvent.MOUSE_MOVE,this.onMouseMoveFunc,false);
         stage.removeEventListener(MouseEvent.MOUSE_UP,this.onMouseUpFunc,false);
      }
   }
}

