package edu.unl.astro.starField
{
   public class PixelMask implements IPixelMask
   {
      
      protected var _height:uint;
      
      protected var _data:Array;
      
      protected var _width:uint;
      
      protected var _top:int = 0;
      
      protected var _left:int = 0;
      
      protected var _radius:uint;
      
      public function PixelMask(param1:uint = 6)
      {
         super();
         radius = param1;
      }
      
      public function get width() : uint
      {
         return _width;
      }
      
      public function get radius() : uint
      {
         return _radius;
      }
      
      public function get left() : int
      {
         return _left;
      }
      
      public function set radius(param1:uint) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc8_:Number = NaN;
         _radius = param1;
         _loc2_ = 2 * _radius + 1;
         _loc8_ = _radius * _radius;
         _data = [];
         _loc3_ = 0;
         while(_loc3_ < _loc2_)
         {
            _loc5_ = -_radius + _loc3_;
            _data[_loc3_] = [];
            _loc4_ = 0;
            while(_loc4_ < _loc2_)
            {
               _loc6_ = -_radius + _loc4_;
               _loc7_ = _loc5_ * _loc5_ + _loc6_ * _loc6_;
               if(_loc7_ > _loc8_)
               {
                  _data[_loc3_][_loc4_] = false;
               }
               else
               {
                  _data[_loc3_][_loc4_] = true;
               }
               _loc4_++;
            }
            _loc3_++;
         }
         _width = _loc2_;
         _height = _loc2_;
      }
      
      public function get height() : uint
      {
         return _height;
      }
      
      public function set top(param1:int) : void
      {
         _top = param1;
      }
      
      public function get top() : int
      {
         return _top;
      }
      
      public function set left(param1:int) : void
      {
         _left = param1;
      }
      
      public function get data() : Array
      {
         return _data;
      }
   }
}

