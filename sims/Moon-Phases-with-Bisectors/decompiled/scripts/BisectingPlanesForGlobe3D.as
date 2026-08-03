package
{
   import flash.display.Graphics;
   
   public class BisectingPlanesForGlobe3D
   {
      
      public var thickness2:Number = 1;
      
      public var size1:Number = 1.4;
      
      public var size2:Number = 1.4;
      
      public var alpha1:Number = 0.5;
      
      public var alpha2:Number = 0.5;
      
      public var show2:Boolean = true;
      
      public var show1:Boolean = true;
      
      protected var _scene:Scene3D;
      
      public var lineAlpha1:Number = 0.8;
      
      protected var _fragmentsList:Array = [];
      
      public var color1:uint = 16752640;
      
      public var color2:uint = 41215;
      
      protected var _fragmentIndex:int;
      
      protected var _anglesList1:Array;
      
      protected var _globe:Globe3D;
      
      public var lineAlpha2:Number = 0.8;
      
      protected var _anglesList2:Array;
      
      public var thickness1:Number = 1;
      
      public var angle1:Number = 0;
      
      public var angle2:Number = 0;
      
      public function BisectingPlanesForGlobe3D(param1:Globe3D)
      {
         super();
         _globe = param1;
         _scene = param1.scene;
         _scene.addEventListener("preUpdate",onPreUpdate);
         _scene.addEventListener("postUpdate",onPostUpdate);
         var _loc2_:int = 0;
         while(_loc2_ < 12)
         {
            _fragmentsList[_loc2_] = new BisectingPlaneFragment();
            _scene.addObject(_fragmentsList[_loc2_]);
            _loc2_++;
         }
      }
      
      protected function positionPlane(param1:Number) : Array
      {
         var _loc2_:int = 0;
         var _loc3_:Array = null;
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc9_:BisectingPlaneFragment = null;
         var _loc10_:Number = Math.cos(param1);
         var _loc11_:Number = Math.sin(param1);
         var _loc12_:Number = _scene.t6 * _loc10_ - _scene.t7 * _loc11_;
         var _loc13_:Number = _scene.t8;
         param1 = (-Math.atan2(_loc12_,_loc13_) % (2 * Math.PI) + 2 * Math.PI) % (2 * Math.PI);
         if(_scene.viewerPhi == 0)
         {
            _loc3_ = [{"angle":0},{"angle":Math.PI / 2},{"angle":Math.PI},{"angle":3 * Math.PI / 2}];
         }
         else
         {
            _loc3_ = [{"angle":0},{"angle":Math.PI / 2},{"angle":Math.PI},{"angle":3 * Math.PI / 2},{"angle":param1},{"angle":((param1 + Math.PI) % (2 * Math.PI) + 2 * Math.PI) % (2 * Math.PI)}];
         }
         _loc3_.sortOn("angle",Array.NUMERIC);
         _loc2_ = 0;
         while(_loc2_ < _loc3_.length)
         {
            _loc4_ = Number(_loc3_[_loc2_].angle);
            _loc5_ = Number(_loc3_[(_loc2_ + 1) % _loc3_.length].angle);
            if(_loc5_ > _loc4_)
            {
               _loc6_ = _loc4_ + (_loc5_ - _loc4_) / 2;
            }
            else
            {
               _loc6_ = _loc4_ + (_loc5_ - _loc4_ + 2 * Math.PI) / 2;
            }
            _loc8_ = Math.sin(_loc6_);
            _loc7_ = Math.cos(_loc6_);
            _loc9_ = _fragmentsList[_fragmentIndex++];
            _loc9_.worldX = _globe.worldX + _globe.radius * _loc10_ * _loc7_;
            _loc9_.worldY = _globe.worldY + -_globe.radius * _loc11_ * _loc7_;
            _loc9_.worldZ = _globe.worldZ + _globe.radius * _loc8_;
            _loc3_[_loc2_].fragment = _loc9_;
            _loc2_++;
         }
         return _loc3_;
      }
      
      protected function onPostUpdate(... rest) : void
      {
         redraw();
      }
      
      public function redraw(... rest) : void
      {
         var _loc2_:int = 0;
         while(_loc2_ < _fragmentsList.length)
         {
            _fragmentsList[_loc2_].graphics.clear();
            _loc2_++;
         }
         if(show1)
         {
            drawPlane(-angle1 * Math.PI / 180,_anglesList1,size1,color1,alpha1,thickness1,lineAlpha1);
         }
         if(show2)
         {
            drawPlane(-angle2 * Math.PI / 180,_anglesList2,size2,color2,alpha2,thickness2,lineAlpha2);
         }
      }
      
      protected function getArcPoints(param1:Number, param2:Number, param3:Number, param4:Number, param5:Number) : Array
      {
         var _loc6_:Array = [];
         param4 = (param4 % (2 * Math.PI) + 2 * Math.PI) % (2 * Math.PI);
         param5 = (param5 % (2 * Math.PI) + 2 * Math.PI) % (2 * Math.PI);
         var _loc7_:Number = param5 - param4;
         if(_loc7_ < 0)
         {
            _loc7_ = 2 * Math.PI + _loc7_;
         }
         var _loc8_:int = Math.ceil(_loc7_ / 0.4);
         var _loc9_:Number = _loc7_ / _loc8_;
         var _loc10_:Number = _loc9_ / 2;
         var _loc11_:Number = param3 / Math.cos(_loc10_);
         var _loc12_:Number = param4;
         var _loc13_:Number = param4 - _loc10_;
         _loc6_.push({
            "ax":param1 + param3 * Math.cos(param4),
            "az":param2 + param3 * Math.sin(param4)
         });
         var _loc14_:int = 0;
         while(_loc14_ < _loc8_)
         {
            _loc12_ += _loc9_;
            _loc13_ += _loc9_;
            _loc6_.push({
               "cx":param1 + _loc11_ * Math.cos(_loc13_),
               "cz":param2 + _loc11_ * Math.sin(_loc13_),
               "ax":param1 + param3 * Math.cos(_loc12_),
               "az":param2 + param3 * Math.sin(_loc12_)
            });
            _loc14_++;
         }
         return _loc6_;
      }
      
      protected function onPreUpdate(... rest) : void
      {
         if(angle1 == angle2)
         {
            angle1 += 0.000001;
         }
         _fragmentIndex = 0;
         _anglesList1 = positionPlane(-angle1 * Math.PI / 180);
         _anglesList2 = positionPlane(-angle2 * Math.PI / 180);
      }
      
      protected function drawPlane(param1:Number, param2:Array, param3:Number, param4:uint, param5:Number, param6:Number, param7:Number) : void
      {
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         var _loc10_:Number = NaN;
         var _loc11_:Number = NaN;
         var _loc12_:Number = NaN;
         var _loc13_:Number = NaN;
         var _loc14_:Number = NaN;
         var _loc15_:Number = NaN;
         var _loc16_:Number = NaN;
         var _loc17_:Number = NaN;
         var _loc18_:int = 0;
         var _loc19_:int = 0;
         var _loc20_:int = 0;
         var _loc21_:BisectingPlaneFragment = null;
         var _loc22_:Object = null;
         var _loc23_:Array = null;
         var _loc24_:Graphics = null;
         var _loc25_:Number = Math.cos(param1);
         var _loc26_:Number = Math.sin(param1);
         var _loc27_:* = param3 * _globe.radius;
         var _loc28_:Number = _scene.t0 * _loc25_ - _scene.t1 * _loc26_;
         var _loc29_:Number = _scene.t2;
         var _loc30_:Number = _scene.t3 * _loc25_ - _scene.t4 * _loc26_;
         var _loc31_:Number = _scene.t5;
         var _loc32_:Number = _scene.t6 * _loc25_ - _scene.t7 * _loc26_;
         var _loc33_:Number = _scene.t8;
         var _loc34_:Array = [{
            "x":Math.SQRT2 * _loc27_ * Math.cos(7 * Math.PI / 4),
            "z":Math.SQRT2 * _loc27_ * Math.sin(7 * Math.PI / 4)
         },{
            "x":Math.SQRT2 * _loc27_ * Math.cos(Math.PI / 4),
            "z":Math.SQRT2 * _loc27_ * Math.sin(Math.PI / 4)
         },{
            "x":Math.SQRT2 * _loc27_ * Math.cos(3 * Math.PI / 4),
            "z":Math.SQRT2 * _loc27_ * Math.sin(3 * Math.PI / 4)
         },{
            "x":Math.SQRT2 * _loc27_ * Math.cos(5 * Math.PI / 4),
            "z":Math.SQRT2 * _loc27_ * Math.sin(5 * Math.PI / 4)
         }];
         var _loc35_:Number = _globe.x;
         var _loc36_:Number = _globe.y;
         _loc8_ = 0;
         while(_loc8_ < param2.length)
         {
            _loc10_ = Number(param2[_loc8_].angle);
            _loc11_ = Number(param2[(_loc8_ + 1) % param2.length].angle);
            _loc21_ = param2[_loc8_].fragment;
            _loc21_.x = 0;
            _loc21_.y = 0;
            _loc23_ = getArcPoints(0,0,_globe.radius,_loc10_,_loc11_);
            _loc19_ = Math.floor((_loc11_ + Math.PI / 4) / (Math.PI / 2)) % 4;
            if(_loc19_ == 1)
            {
               _loc14_ = _loc27_ / Math.tan(_loc11_);
               _loc15_ = _loc27_;
            }
            else if(_loc19_ == 2)
            {
               _loc14_ = -_loc27_;
               _loc15_ = -_loc27_ * Math.tan(_loc11_);
            }
            else if(_loc19_ == 3)
            {
               _loc14_ = -_loc27_ / Math.tan(_loc11_);
               _loc15_ = -_loc27_;
            }
            else
            {
               _loc14_ = _loc27_;
               _loc15_ = _loc27_ * Math.tan(_loc11_);
            }
            _loc18_ = Math.floor((_loc10_ + Math.PI / 4) / (Math.PI / 2)) % 4;
            if(_loc18_ == 1)
            {
               _loc12_ = _loc27_ / Math.tan(_loc10_);
               _loc13_ = _loc27_;
            }
            else if(_loc18_ == 2)
            {
               _loc12_ = -_loc27_;
               _loc13_ = -_loc27_ * Math.tan(_loc10_);
            }
            else if(_loc18_ == 3)
            {
               _loc12_ = -_loc27_ / Math.tan(_loc10_);
               _loc13_ = -_loc27_;
            }
            else
            {
               _loc12_ = _loc27_;
               _loc13_ = _loc27_ * Math.tan(_loc10_);
            }
            _loc20_ = ((_loc19_ - _loc18_) % 4 + 4) % 4;
            _loc22_ = _loc23_[0];
            _loc16_ = _loc35_ + _loc28_ * _loc22_.ax + _loc29_ * _loc22_.az;
            _loc17_ = _loc36_ + _loc30_ * _loc22_.ax + _loc31_ * _loc22_.az;
            _loc24_ = _loc21_.graphics;
            _loc24_.moveTo(_loc16_,_loc17_);
            _loc24_.lineStyle(param6,param4,param7);
            _loc24_.beginFill(param4,param5);
            _loc9_ = 1;
            while(_loc9_ < _loc23_.length)
            {
               _loc22_ = _loc23_[_loc9_];
               _loc24_.curveTo(_loc35_ + _loc28_ * _loc22_.cx + _loc29_ * _loc22_.cz,_loc36_ + _loc30_ * _loc22_.cx + _loc31_ * _loc22_.cz,_loc35_ + _loc28_ * _loc22_.ax + _loc29_ * _loc22_.az,_loc36_ + _loc30_ * _loc22_.ax + _loc31_ * _loc22_.az);
               _loc9_++;
            }
            _loc24_.lineStyle();
            _loc24_.lineTo(_loc35_ + _loc28_ * _loc14_ + _loc29_ * _loc15_,_loc36_ + _loc30_ * _loc14_ + _loc31_ * _loc15_);
            _loc24_.lineStyle(param6,param4,param7);
            _loc9_ = 0;
            while(_loc9_ < _loc20_)
            {
               _loc22_ = _loc34_[((_loc19_ - _loc9_) % 4 + 4) % 4];
               _loc24_.lineTo(_loc35_ + _loc28_ * _loc22_.x + _loc29_ * _loc22_.z,_loc36_ + _loc30_ * _loc22_.x + _loc31_ * _loc22_.z);
               _loc9_++;
            }
            _loc24_.lineTo(_loc35_ + _loc28_ * _loc12_ + _loc29_ * _loc13_,_loc36_ + _loc30_ * _loc12_ + _loc31_ * _loc13_);
            _loc24_.lineStyle();
            _loc24_.lineTo(_loc16_,_loc17_);
            _loc24_.endFill();
            _loc8_++;
         }
      }
   }
}

