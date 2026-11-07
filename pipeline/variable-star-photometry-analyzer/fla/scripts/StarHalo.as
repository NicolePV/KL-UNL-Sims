package
{
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class StarHalo extends Sprite
   {
      
      private var _radius:Number;
      
      private var _haloSP:Sprite;
      
      private var _index:uint;
      
      public function StarHalo(param1:*)
      {
         super();
         x = param1.x;
         y = param1.y;
         _index = param1.index;
         _radius = param1.radius;
         graphics.clear();
         graphics.beginFill(16711680,0);
         graphics.drawCircle(0.5,0.5,_radius);
         graphics.endFill();
         _haloSP = new Sprite();
         addChild(_haloSP);
         addEventListener(MouseEvent.MOUSE_DOWN,onMouseDownFunc);
      }
      
      public function drawHalo(param1:Number, param2:uint, param3:Number, param4:String) : void
      {
         if(param4 == "circle")
         {
            _haloSP.graphics.clear();
            _haloSP.graphics.lineStyle(param1,param2,param3);
            _haloSP.graphics.drawCircle(0.5,0.5,_radius);
         }
         else if(param4 == "square")
         {
            _haloSP.graphics.clear();
            _haloSP.graphics.lineStyle(param1,param2,param3);
            _haloSP.graphics.moveTo(-_radius,-_radius);
            _haloSP.graphics.lineTo(-_radius,_radius);
            _haloSP.graphics.lineTo(_radius,_radius);
            _haloSP.graphics.lineTo(_radius,-_radius);
            _haloSP.graphics.lineTo(-_radius,-_radius);
         }
      }
      
      private function onMouseDownFunc(... rest) : void
      {
         dispatchEvent(new Event("haloClicked"));
      }
      
      public function get index() : uint
      {
         return _index;
      }
   }
}

