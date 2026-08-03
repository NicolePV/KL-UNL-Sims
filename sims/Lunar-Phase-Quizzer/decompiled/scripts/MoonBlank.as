package
{
   import flash.display.Shape;
   import flash.display.Sprite;
   
   public class MoonBlank extends Sprite
   {
      
      protected var _background:Shape;
      
      public function MoonBlank(param1:Number)
      {
         super();
         this._background = new Shape();
         this._background.graphics.beginFill(1052688);
         this._background.graphics.lineStyle(1,6316128);
         this._background.graphics.drawCircle(0,0,param1);
         this._background.graphics.endFill();
         addChild(this._background);
      }
   }
}

