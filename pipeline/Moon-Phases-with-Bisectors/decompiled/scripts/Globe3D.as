package
{
   import flash.display.DisplayObject;
   
   public class Globe3D extends Globe implements IScene3DObject
   {
      
      protected var _lastViewerPhi:Number;
      
      protected var _scene:Scene3D;
      
      public var earthBackHack:Boolean = false;
      
      protected var _worldX:Number = 0;
      
      protected var _worldY:Number = 0;
      
      protected var _worldZ:Number = 0;
      
      protected var _screenX:Number = 0;
      
      protected var _screenY:Number = 0;
      
      protected var _screenZ:Number = 0;
      
      protected var _lastViewerTheta:Number;
      
      protected var _sceneRadius:Number = 1;
      
      public function Globe3D(param1:Scene3D)
      {
         _scene = param1;
         _scene.addEventListener("postUpdate",onPostUpdate);
         _scene.addObject(this);
         super();
      }
      
      public function get worldX() : Number
      {
         return _worldX;
      }
      
      public function get worldY() : Number
      {
         return _worldY;
      }
      
      public function get worldZ() : Number
      {
         return _worldZ;
      }
      
      public function get scene() : Scene3D
      {
         return _scene;
      }
      
      public function set worldZ(param1:Number) : void
      {
         _worldZ = param1;
      }
      
      public function set worldX(param1:Number) : void
      {
         _worldX = param1;
      }
      
      override public function get radius() : Number
      {
         return _sceneRadius;
      }
      
      public function set worldY(param1:Number) : void
      {
         _worldY = param1;
      }
      
      public function get screenRadius() : Number
      {
         return _sceneRadius * _scene.scale;
      }
      
      override public function set radius(param1:Number) : void
      {
         _sceneRadius = param1;
      }
      
      protected function onPostUpdate(... rest) : void
      {
         if(earthBackHack)
         {
            setViewerThetaAndPhi(_scene.viewerTheta + 180,-_scene.viewerPhi);
            scaleX = -1;
         }
         else
         {
            setViewerThetaAndPhi(_scene.viewerTheta,_scene.viewerPhi);
         }
      }
      
      override public function update() : void
      {
         var _loc1_:* = _sceneRadius * _scene.scale;
         if(_loc1_ != _radius)
         {
            _radius = _loc1_;
            calculateBConstants();
         }
         super.update();
      }
      
      public function get displayObj() : DisplayObject
      {
         return this;
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

