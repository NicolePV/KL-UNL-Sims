package
{
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol73")]
   public class Pulsar extends MovieClip
   {
      
      protected var _dragOffsetX:Number;
      
      protected var _dragOffsetY:Number;
      
      public function Pulsar()
      {
         super();
      }
      
      public function onMouseUpFunc(... rest) : void
      {
         stage.removeEventListener("mouseMove",onMouseMoveFunc);
         stage.removeEventListener("mouseUp",onMouseUpFunc);
      }
      
      public function onEnterFrameFunc(... rest) : void
      {
         rotation += 16;
      }
      
      public function onMouseMoveFunc(param1:MouseEvent) : void
      {
         x = parent.mouseX - _dragOffsetX;
         y = parent.mouseY - _dragOffsetY;
         param1.updateAfterEvent();
      }
      
      public function onMouseDownFunc(... rest) : void
      {
         _dragOffsetX = parent.mouseX - x;
         _dragOffsetY = parent.mouseY - y;
         stage.addEventListener("mouseMove",onMouseMoveFunc);
         stage.addEventListener("mouseUp",onMouseUpFunc);
      }
   }
}

