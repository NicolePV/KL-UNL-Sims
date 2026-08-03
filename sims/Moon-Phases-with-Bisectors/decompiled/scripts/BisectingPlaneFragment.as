package
{
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   
   public class BisectingPlaneFragment extends Sprite implements IScene3DObject
   {
      
      protected var _worldX:Number = 0;
      
      protected var _worldY:Number = 0;
      
      protected var _worldZ:Number = 0;
      
      protected var _screenX:Number = 0;
      
      protected var _screenY:Number = 0;
      
      protected var _screenZ:Number = 0;
      
      public function BisectingPlaneFragment()
      {
         super();
      }
      
      public function get worldX() : Number
      {
         return _worldX;
      }
      
      public function get worldZ() : Number
      {
         return _worldZ;
      }
      
      public function set worldX(param1:Number) : void
      {
         _worldX = param1;
      }
      
      public function get displayObj() : DisplayObject
      {
         return this;
      }
      
      public function get worldY() : Number
      {
         return _worldY;
      }
      
      public function set worldZ(param1:Number) : void
      {
         _worldZ = param1;
      }
      
      public function set screenX(param1:Number) : void
      {
         _screenX = param1;
      }
      
      public function set screenY(param1:Number) : void
      {
         _screenY = param1;
      }
      
      public function set screenZ(param1:Number) : void
      {
         _screenZ = param1;
      }
      
      public function get screenX() : Number
      {
         return _screenX;
      }
      
      public function set worldY(param1:Number) : void
      {
         _worldY = param1;
      }
      
      public function get screenY() : Number
      {
         return _screenY;
      }
      
      public function get screenZ() : Number
      {
         return _screenZ;
      }
   }
}

