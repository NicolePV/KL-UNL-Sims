package
{
   import flash.display.Sprite;
   
   public class PlaneRotator extends Sprite
   {
      
      protected var _useSeparateBack:Boolean = false;
      
      protected var _frontWrapper:Sprite;
      
      public var _front:Sprite;
      
      protected var _phi:Number = 0;
      
      protected var _theta:Number = 0;
      
      public function PlaneRotator(param1:Class)
      {
         super();
         _frontWrapper = new Sprite();
         _front = new param1();
         addChild(_frontWrapper);
         _frontWrapper.addChild(_front);
      }
      
      public function set phi(param1:Number) : void
      {
         _phi = ((param1 + 180) % 360 + 360) % 360 - 180;
         _frontWrapper.scaleY = Math.sin(_phi * (Math.PI / 180));
      }
      
      public function get theta() : Number
      {
         return _theta;
      }
      
      public function get phi() : Number
      {
         return _phi;
      }
      
      public function set theta(param1:Number) : void
      {
         _theta = (param1 % 360 + 360) % 360;
         _front.rotation = _theta;
      }
   }
}

