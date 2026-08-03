package
{
   import flash.display.DisplayObject;
   
   public interface IScene3DObject
   {
      
      function get displayObj() : DisplayObject;
      
      function get worldX() : Number;
      
      function get worldY() : Number;
      
      function get worldZ() : Number;
      
      function get screenX() : Number;
      
      function get screenY() : Number;
      
      function get screenZ() : Number;
      
      function set worldZ(param1:Number) : void;
      
      function set worldX(param1:Number) : void;
      
      function set worldY(param1:Number) : void;
      
      function set screenX(param1:Number) : void;
      
      function set screenY(param1:Number) : void;
      
      function set screenZ(param1:Number) : void;
   }
}

