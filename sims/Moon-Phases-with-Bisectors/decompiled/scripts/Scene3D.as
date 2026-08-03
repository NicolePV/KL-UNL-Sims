package
{
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class Scene3D extends Sprite
   {
      
      protected var _viewerPhi:Number = 0;
      
      protected var _initPhi:Number;
      
      protected var _objectsList:Array = [];
      
      public const sceneWidth:Number = 600;
      
      protected var _initMouseX:Number;
      
      protected var _initMouseY:Number;
      
      public var t0:Number;
      
      public var t1:Number;
      
      public var t2:Number;
      
      public var t3:Number;
      
      public var t4:Number;
      
      public var t5:Number;
      
      public var t6:Number;
      
      public var t7:Number;
      
      public var t8:Number;
      
      public var backgroundAlpha:Number = 1;
      
      public const sceneHeight:Number = 600;
      
      public var backgroundColor:uint = 0;
      
      public var _containerSP:Sprite;
      
      protected var _scale:Number = 100;
      
      public var it0:Number;
      
      public var it1:Number;
      
      public var it2:Number;
      
      public var it3:Number;
      
      public var it4:Number;
      
      public var it5:Number;
      
      public var it6:Number;
      
      public var it7:Number;
      
      public var it8:Number;
      
      protected var _initTheta:Number;
      
      protected var _backgroundSP:Sprite;
      
      protected var _viewerTheta:Number = 0;
      
      public function Scene3D()
      {
         super();
         _backgroundSP = new Sprite();
         _containerSP = new Sprite();
         _containerSP.mouseEnabled = false;
         _containerSP.mouseChildren = false;
         addChild(_backgroundSP);
         addChild(_containerSP);
         init();
         _backgroundSP.addEventListener("mouseDown",onMouseDownFunc);
         setViewerThetaAndPhi(150,20);
      }
      
      public function init() : void
      {
         _backgroundSP.graphics.moveTo(-sceneWidth / 2,-sceneHeight / 2);
         _backgroundSP.graphics.beginFill(backgroundColor,backgroundAlpha);
         _backgroundSP.graphics.lineTo(-sceneWidth / 2,sceneHeight / 2);
         _backgroundSP.graphics.lineTo(sceneWidth / 2,sceneHeight / 2);
         _backgroundSP.graphics.lineTo(sceneWidth / 2,-sceneHeight / 2);
         _backgroundSP.graphics.lineTo(-sceneWidth / 2,-sceneHeight / 2);
         _backgroundSP.graphics.endFill();
      }
      
      public function getWorldPoint(param1:Point3D) : Point3D
      {
         return new Point3D(it0 * param1.x + it1 * param1.y + it2 * param1.z,it3 * param1.x + it4 * param1.y + it5 * param1.z,it6 * param1.x + it7 * param1.y + it8 * param1.z);
      }
      
      public function calculateConstants() : void
      {
         var _loc1_:Number = Math.cos(_viewerTheta);
         var _loc2_:Number = Math.sin(_viewerTheta);
         var _loc3_:Number = Math.cos(_viewerPhi);
         var _loc4_:Number = Math.sin(_viewerPhi);
         t0 = _scale * _loc2_;
         t1 = -_scale * _loc1_;
         t2 = 0;
         t3 = -_scale * _loc1_ * _loc4_;
         t4 = -_scale * _loc2_ * _loc4_;
         t5 = -_scale * _loc3_;
         t6 = -_scale * _loc1_ * _loc3_;
         t7 = -_scale * _loc2_ * _loc3_;
         t8 = _scale * _loc4_;
         it0 = t0 / (_scale * _scale);
         it1 = t3 / (_scale * _scale);
         it2 = t6 / (_scale * _scale);
         it3 = t1 / (_scale * _scale);
         it4 = t4 / (_scale * _scale);
         it5 = t7 / (_scale * _scale);
         it6 = t2 / (_scale * _scale);
         it7 = t5 / (_scale * _scale);
         it8 = t8 / (_scale * _scale);
      }
      
      public function set scale(param1:Number) : void
      {
         _scale = param1;
         calculateConstants();
         update();
      }
      
      public function setViewerThetaAndPhi(param1:Number, param2:Number) : void
      {
         _viewerTheta = (param1 + 180) * Math.PI / 180;
         _viewerPhi = param2 * Math.PI / 180;
         if(_viewerPhi > Math.PI / 2)
         {
            _viewerPhi = Math.PI / 2;
         }
         else if(_viewerPhi < -Math.PI / 2)
         {
            _viewerPhi = -Math.PI / 2;
         }
         calculateConstants();
         update();
      }
      
      protected function onMouseUpFunc(... rest) : void
      {
         stage.removeEventListener("mouseUp",onMouseUpFunc);
         stage.removeEventListener("mouseMove",onMouseMoveFunc);
      }
      
      public function get viewerTheta() : Number
      {
         return _viewerTheta * 180 / Math.PI - 180;
      }
      
      protected function onMouseDownFunc(... rest) : void
      {
         _initMouseX = mouseX;
         _initMouseY = mouseY;
         _initTheta = _viewerTheta;
         _initPhi = _viewerPhi;
         stage.addEventListener("mouseUp",onMouseUpFunc);
         stage.addEventListener("mouseMove",onMouseMoveFunc);
      }
      
      public function addObject(param1:IScene3DObject) : void
      {
         _objectsList.push(param1);
         _containerSP.addChild(param1.displayObj);
      }
      
      public function update() : void
      {
         var _loc1_:int = 0;
         var _loc2_:IScene3DObject = null;
         dispatchEvent(new Event("preUpdate"));
         _loc1_ = 0;
         while(_loc1_ < _objectsList.length)
         {
            _loc2_ = _objectsList[_loc1_];
            _loc2_.screenX = t0 * _loc2_.worldX + t1 * _loc2_.worldY + t2 * _loc2_.worldZ;
            _loc2_.screenY = t3 * _loc2_.worldX + t4 * _loc2_.worldY + t5 * _loc2_.worldZ;
            _loc2_.screenZ = t6 * _loc2_.worldX + t7 * _loc2_.worldY + t8 * _loc2_.worldZ;
            _loc2_.displayObj.x = _loc2_.screenX;
            _loc2_.displayObj.y = _loc2_.screenY;
            _loc1_++;
         }
         _objectsList.sortOn("screenZ",Array.NUMERIC);
         _loc1_ = 0;
         while(_loc1_ < _objectsList.length)
         {
            _containerSP.setChildIndex(_objectsList[_loc1_].displayObj,_loc1_);
            _loc1_++;
         }
         dispatchEvent(new Event("prePostUpdate"));
         dispatchEvent(new Event("postUpdate"));
      }
      
      public function get scale() : Number
      {
         return _scale;
      }
      
      public function getScreenPoint(param1:Point3D) : Point3D
      {
         return new Point3D(t0 * param1.x + t1 * param1.y + t2 * param1.z,t3 * param1.x + t4 * param1.y + t5 * param1.z,t6 * param1.x + t7 * param1.y + t8 * param1.z);
      }
      
      protected function onMouseMoveFunc(param1:MouseEvent) : void
      {
         var _loc2_:Number = 180 / Math.PI * (_initTheta - (mouseX - _initMouseX) / _scale) - 180;
         var _loc3_:Number = 180 / Math.PI * (_initPhi + (mouseY - _initMouseY) / _scale);
         setViewerThetaAndPhi(_loc2_,_loc3_);
         dispatchEvent(new Event("mouseDrag"));
         param1.updateAfterEvent();
      }
      
      public function get viewerPhi() : Number
      {
         return _viewerPhi * 180 / Math.PI;
      }
   }
}

