package
{
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.ui.Keyboard;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol27")]
   public class SHZTimelineCursor extends MovieClip
   {
      
      protected var _timeline:SHZTimeline;
      
      protected var _maxX:Number;
      
      protected var _minX:Number;
      
      protected var _offsetX:Number;
      
      public function SHZTimelineCursor(param1:Number, param2:Number, param3:SHZTimeline)
      {
         super();
         _minX = param1;
         _maxX = param2;
         _timeline = param3;
         focusRect = false;
         addEventListener("addedToStage",onAddedToStage);
         addEventListener("focusOut",onFocusOut);
      }
      
      protected function onMouseUp(... rest) : void
      {
         stage.removeEventListener(MouseEvent.MOUSE_MOVE,onMouseMove);
         stage.removeEventListener(MouseEvent.MOUSE_UP,onMouseUp);
      }
      
      protected function onMouseOut(... rest) : void
      {
         gotoAndStop(1);
      }
      
      protected function onAddedToStage(... rest) : void
      {
         addEventListener(MouseEvent.MOUSE_OVER,onMouseOver);
         addEventListener(MouseEvent.MOUSE_OUT,onMouseOut);
         addEventListener(MouseEvent.MOUSE_DOWN,onMouseDown);
      }
      
      protected function onMouseDown(... rest) : void
      {
         stage.focus = this;
         addEventListener("keyDown",onKeyDown);
         _offsetX = parent.mouseX - x;
         stage.addEventListener(MouseEvent.MOUSE_MOVE,onMouseMove);
         stage.addEventListener(MouseEvent.MOUSE_UP,onMouseUp);
      }
      
      protected function onKeyDown(param1:KeyboardEvent) : void
      {
         if(param1.keyCode == Keyboard.LEFT)
         {
            _timeline.increment(-1);
         }
         else if(param1.keyCode == Keyboard.RIGHT)
         {
            _timeline.increment(1);
         }
      }
      
      protected function onFocusOut(... rest) : void
      {
         removeEventListener("keyDown",onKeyDown);
      }
      
      protected function onMouseMove(param1:MouseEvent) : void
      {
         var _loc2_:Number = parent.mouseX - _offsetX;
         if(_loc2_ < _minX)
         {
            _loc2_ = _minX;
         }
         else if(_loc2_ > _maxX)
         {
            _loc2_ = _maxX;
         }
         x = _loc2_;
         dispatchEvent(new Event("cursorDragged"));
         param1.updateAfterEvent();
      }
      
      protected function onMouseOver(... rest) : void
      {
         gotoAndStop(2);
      }
   }
}

