package
{
   import flash.display.Sprite;
   
   public class PhaseDisc extends Sprite
   {
      
      public var lineThickness:Number = 1;
      
      protected var _darkArea:Sprite;
      
      public var lineAlpha:Number = 0;
      
      public var darkColor:uint = 4210752;
      
      public var lineColor:uint = 2105376;
      
      public var radius:Number = 100;
      
      protected var _lightArea:Sprite;
      
      public var lightColor:uint = 14737632;
      
      protected var _phaseAngle:Number = 0;
      
      public function PhaseDisc(param1:Object = null)
      {
         super();
         _darkArea = new Sprite();
         addChild(_darkArea);
         _lightArea = new Sprite();
         addChild(_lightArea);
         if(param1 != null)
         {
            if(param1.radius is Number)
            {
               radius = param1.radius;
            }
            if(param1.lightColor is Number)
            {
               lightColor = param1.lightColor;
            }
            if(param1.darkColor is Number)
            {
               darkColor = param1.darkColor;
            }
            if(param1.lineThickness is Number)
            {
               lineThickness = param1.lineThickness;
            }
            if(param1.lineColor is Number)
            {
               lineColor = param1.lineColor;
            }
            if(param1.lineAlpha is Number)
            {
               lineAlpha = param1.lineAlpha;
            }
            if(param1.phaseAngle is Number)
            {
               phaseAngle = param1.phaseAngle;
            }
            else if(param1.positions is Object)
            {
               setPositions(param1.positions);
            }
            else
            {
               update();
            }
         }
         else
         {
            update();
         }
      }
      
      public function update(... rest) : void
      {
         var _loc9_:* = 0;
         var _loc10_:Number = NaN;
         var _loc11_:Number = NaN;
         var _loc12_:Number = NaN;
         var _loc13_:Number = NaN;
         var _loc14_:Number = NaN;
         var _loc15_:Number = NaN;
         var _loc2_:Number = _phaseAngle < Math.PI ? -1 : 1;
         var _loc3_:int = 4;
         var _loc4_:Number = radius * Math.cos(_phaseAngle);
         var _loc5_:Number = Math.PI / _loc3_;
         var _loc6_:Number = _loc5_ / 2;
         var _loc7_:Number = radius / Math.cos(_loc6_);
         var _loc8_:Number = _loc4_ / Math.cos(_loc6_);
         _darkArea.graphics.clear();
         _darkArea.graphics.lineStyle(lineThickness,lineColor,lineAlpha);
         _darkArea.graphics.moveTo(0,-radius);
         _darkArea.graphics.beginFill(darkColor);
         _loc9_ = 1;
         while(_loc9_ <= _loc3_)
         {
            _loc10_ = _loc9_ * _loc5_;
            _loc12_ = radius * Math.sin(_loc10_);
            _loc13_ = -radius * Math.cos(_loc10_);
            _loc11_ = _loc10_ - _loc6_;
            _loc14_ = _loc7_ * Math.sin(_loc11_);
            _loc15_ = -_loc7_ * Math.cos(_loc11_);
            _darkArea.graphics.curveTo(_loc2_ * _loc14_,_loc15_,_loc2_ * _loc12_,_loc13_);
            _loc9_++;
         }
         _loc9_ = int(_loc3_ - 1);
         while(_loc9_ >= 0)
         {
            _loc10_ = _loc9_ * _loc5_;
            _loc12_ = _loc4_ * Math.sin(_loc10_);
            _loc13_ = -radius * Math.cos(_loc10_);
            _loc11_ = _loc10_ + _loc6_;
            _loc14_ = _loc8_ * Math.sin(_loc11_);
            _loc15_ = -_loc7_ * Math.cos(_loc11_);
            _darkArea.graphics.curveTo(_loc2_ * _loc14_,_loc15_,_loc2_ * _loc12_,_loc13_);
            _loc9_--;
         }
         _darkArea.graphics.endFill();
         _lightArea.graphics.clear();
         _lightArea.graphics.lineStyle(lineThickness,lineColor,lineAlpha);
         _lightArea.graphics.moveTo(0,-radius);
         _lightArea.graphics.beginFill(lightColor);
         _loc9_ = 1;
         while(_loc9_ <= _loc3_)
         {
            _loc10_ = _loc9_ * _loc5_;
            _loc12_ = -radius * Math.sin(_loc10_);
            _loc13_ = -radius * Math.cos(_loc10_);
            _loc11_ = _loc10_ - _loc6_;
            _loc14_ = -_loc7_ * Math.sin(_loc11_);
            _loc15_ = -_loc7_ * Math.cos(_loc11_);
            _lightArea.graphics.curveTo(_loc2_ * _loc14_,_loc15_,_loc2_ * _loc12_,_loc13_);
            _loc9_++;
         }
         _loc9_ = int(_loc3_ - 1);
         while(_loc9_ >= 0)
         {
            _loc10_ = _loc9_ * _loc5_;
            _loc12_ = _loc4_ * Math.sin(_loc10_);
            _loc13_ = -radius * Math.cos(_loc10_);
            _loc11_ = _loc10_ + _loc6_;
            _loc14_ = _loc8_ * Math.sin(_loc11_);
            _loc15_ = -_loc7_ * Math.cos(_loc11_);
            _lightArea.graphics.curveTo(_loc2_ * _loc14_,_loc15_,_loc2_ * _loc12_,_loc13_);
            _loc9_--;
         }
         _lightArea.graphics.endFill();
      }
      
      public function setPhaseAngleDeg(param1:Number) : void
      {
         phaseAngle = param1 * Math.PI / 180;
      }
      
      public function set phaseAngle(param1:Number) : void
      {
         _phaseAngle = (param1 % (2 * Math.PI) + 2 * Math.PI) % (2 * Math.PI);
         update();
      }
      
      public function get phaseAngle() : Number
      {
         return _phaseAngle;
      }
      
      public function setPositions(param1:Object) : Number
      {
         var _loc2_:Number = param1.x1 - param1.x0;
         var _loc3_:Number = param1.y1 - param1.y0;
         var _loc4_:Number = param1.x2 - param1.x0;
         var _loc5_:Number = param1.y2 - param1.y0;
         var _loc6_:Number = Math.sqrt(_loc2_ * _loc2_ + _loc3_ * _loc3_);
         var _loc7_:Number = Math.sqrt(_loc4_ * _loc4_ + _loc5_ * _loc5_);
         var _loc8_:Number = Math.atan2(_loc3_,_loc2_);
         var _loc9_:Number = Math.atan2(_loc5_,_loc4_);
         var _loc10_:Number = 2 * Math.PI * (((_loc9_ - _loc8_) / (2 * Math.PI) % 1 + 1) % 1);
         var _loc11_:Number = Math.cos(_loc10_);
         var _loc12_:Number = Math.sqrt(_loc6_ * _loc6_ + _loc7_ * _loc7_ - 2 * _loc6_ * _loc7_ * _loc11_);
         var _loc13_:Number = (_loc7_ - _loc6_ * _loc11_) / _loc12_;
         if(_loc13_ > 1)
         {
            _loc13_ = 1;
         }
         else if(_loc13_ < -1)
         {
            _loc13_ = -1;
         }
         var _loc14_:Number = Math.acos(_loc13_);
         phaseAngle = _loc10_ < Math.PI ? _loc14_ : 2 * Math.PI - _loc14_;
         return phaseAngle;
      }
      
      public function getPhaseAngleDeg() : Number
      {
         return _phaseAngle * 180 / Math.PI;
      }
   }
}

