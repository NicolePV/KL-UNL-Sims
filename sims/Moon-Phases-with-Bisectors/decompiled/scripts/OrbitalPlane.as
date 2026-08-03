package
{
   import flash.display.Shape;
   
   public class OrbitalPlane
   {
      
      public var _planeRotatorsList:Array;
      
      protected var _fragmentsList:Array;
      
      protected var _globesList:Array;
      
      protected var _scene:Scene3D;
      
      public var show1:Boolean = true;
      
      public var show2:Boolean = true;
      
      public var _masksList:Array;
      
      public function OrbitalPlane(param1:Globe3D, param2:Globe3D, param3:Class)
      {
         var _loc4_:int = 0;
         _globesList = [];
         _fragmentsList = [];
         super();
         _scene = param1.scene;
         _scene.addEventListener("preUpdate",onPreUpdate);
         _scene.addEventListener("postUpdate",onPostUpdate);
         _globesList[0] = param1;
         _globesList[1] = param2;
         _planeRotatorsList = [];
         _masksList = [];
         _loc4_ = 0;
         while(_loc4_ <= 2)
         {
            _fragmentsList[_loc4_] = new BisectingPlaneFragment();
            _planeRotatorsList[_loc4_] = new PlaneRotator(param3);
            _masksList[_loc4_] = new Shape();
            _fragmentsList[_loc4_].addChild(_planeRotatorsList[_loc4_]);
            _fragmentsList[_loc4_].addChild(_masksList[_loc4_]);
            _planeRotatorsList[_loc4_].mask = _masksList[_loc4_];
            _scene.addObject(_fragmentsList[_loc4_]);
            _loc4_++;
         }
      }
      
      protected function onPostUpdate(... rest) : void
      {
         var _loc2_:int = 0;
         var _loc3_:BisectingPlaneFragment = null;
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         _globesList.sortOn("screenZ",Array.NUMERIC);
         var _loc4_:Number = _scene.sceneWidth / 2;
         var _loc5_:Number = _scene.sceneHeight / 2;
         if(_scene.viewerPhi > 0)
         {
            _loc7_ = -_loc5_;
         }
         else
         {
            _loc7_ = _loc5_;
         }
         _loc2_ = 0;
         while(_loc2_ < 3)
         {
            _planeRotatorsList[_loc2_].theta = _scene.viewerTheta;
            _planeRotatorsList[_loc2_].phi = _scene.viewerPhi;
            _loc2_++;
         }
         _loc2_ = 0;
         while(_loc2_ < 2)
         {
            _loc3_ = _fragmentsList[_loc2_];
            _loc6_ = Number(_globesList[_loc2_].screenY);
            _loc3_.x = 0;
            _loc3_.y = 0;
            _masksList[_loc2_].graphics.clear();
            _masksList[_loc2_].graphics.moveTo(-_loc4_,_loc7_);
            _masksList[_loc2_].graphics.beginFill(16777215 * Math.random(),0.6);
            _masksList[_loc2_].graphics.lineTo(_loc4_,_loc7_);
            _masksList[_loc2_].graphics.lineTo(_loc4_,_loc6_);
            _masksList[_loc2_].graphics.lineTo(-_loc4_,_loc6_);
            _masksList[_loc2_].graphics.lineTo(-_loc4_,_loc7_);
            _masksList[_loc2_].graphics.endFill();
            _loc7_ = _loc6_;
            _loc2_++;
         }
         if(_scene.viewerPhi > 0)
         {
            _loc6_ = _loc5_;
         }
         else
         {
            _loc6_ = -_loc5_;
         }
         _loc3_ = _fragmentsList[_loc2_];
         _loc3_.x = 0;
         _loc3_.y = 0;
         _masksList[_loc2_].graphics.clear();
         _masksList[_loc2_].graphics.moveTo(-_loc4_,_loc7_);
         _masksList[_loc2_].graphics.beginFill(16777215 * Math.random(),0.6);
         _masksList[_loc2_].graphics.lineTo(_loc4_,_loc7_);
         _masksList[_loc2_].graphics.lineTo(_loc4_,_loc6_);
         _masksList[_loc2_].graphics.lineTo(-_loc4_,_loc6_);
         _masksList[_loc2_].graphics.lineTo(-_loc4_,_loc7_);
         _masksList[_loc2_].graphics.endFill();
      }
      
      protected function drawMask() : void
      {
      }
      
      public function passData(param1:Object) : void
      {
         var _loc2_:int = 0;
         while(_loc2_ < 3)
         {
            _planeRotatorsList[_loc2_]._front.receiveData(param1);
            _loc2_++;
         }
      }
      
      protected function onPreUpdate(... rest) : void
      {
         var _loc2_:int = 0;
         var _loc3_:Number = NaN;
         var _loc5_:Point3D = null;
         var _loc6_:Globe3D = null;
         var _loc7_:BisectingPlaneFragment = null;
         var _loc4_:Point3D = new Point3D();
         _loc6_ = _globesList[0];
         _loc4_.x = _loc6_.screenX;
         _loc4_.y = _loc6_.screenY;
         _loc4_.z = _loc6_.screenZ - _loc6_.screenRadius;
         _loc5_ = _scene.getWorldPoint(_loc4_);
         _loc7_ = _fragmentsList[0];
         _loc7_.worldX = _loc5_.x;
         _loc7_.worldY = _loc5_.y;
         _loc7_.worldZ = _loc5_.z;
         var _loc8_:Number = Math.cos(_scene.viewerPhi * Math.PI / 180);
         var _loc9_:Number = Math.sin(_scene.viewerPhi * Math.PI / 180);
         _loc2_ = 0;
         while(_loc2_ < _globesList.length)
         {
            _loc6_ = _globesList[_loc2_];
            _loc4_.x = _loc6_.screenX;
            _loc4_.y = _loc6_.screenY - _loc6_.screenRadius * _loc9_;
            _loc4_.z = _loc6_.screenZ + _loc6_.screenRadius * _loc8_;
            _loc5_ = _scene.getWorldPoint(_loc4_);
            _loc7_ = _fragmentsList[_loc2_ + 1];
            _loc7_.worldX = _loc5_.x;
            _loc7_.worldY = _loc5_.y;
            _loc7_.worldZ = _loc5_.z;
            _loc2_++;
         }
      }
   }
}

