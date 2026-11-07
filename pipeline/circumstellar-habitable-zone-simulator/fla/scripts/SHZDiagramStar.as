package
{
   import flash.display.Graphics;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.filters.BlurFilter;
   import flash.geom.Matrix;
   
   public class SHZDiagramStar extends Sprite
   {
      
      public var temperature:Number = 5808.3;
      
      protected var _blur:BlurFilter;
      
      public const AUperSolarRadius:Number = 0.00465;
      
      public var radius:Number = 1;
      
      public const SolarTemperature:Number = 5808;
      
      protected var _diagram:SHZDiagram;
      
      protected var disc:Shape;
      
      public const MinDiscSize:Number = 1.2;
      
      protected var halo:Shape;
      
      public function SHZDiagramStar(param1:SHZDiagram)
      {
         super();
         _diagram = param1;
         halo = new Shape();
         addChild(halo);
         disc = new Shape();
         addChild(disc);
         _blur = new BlurFilter(4,4,1);
      }
      
      public function update() : void
      {
         var _loc9_:Array = null;
         var _loc10_:Array = null;
         var _loc11_:Array = null;
         var _loc13_:uint = 0;
         var _loc14_:uint = 0;
         var _loc15_:uint = 0;
         var _loc16_:uint = 0;
         var _loc23_:Number = NaN;
         var _loc1_:uint = getColorFromTemp(temperature);
         var _loc2_:Number = radius * AUperSolarRadius * _diagram.scale;
         if(_loc2_ < MinDiscSize)
         {
            _loc2_ = MinDiscSize;
         }
         var _loc3_:Number = _loc2_;
         if(_loc3_ > _diagram.safeRadius)
         {
            _loc3_ = _diagram.safeRadius;
         }
         var _loc4_:Number = 2;
         _loc4_ = 1.2 + 1.4 * (Math.log(temperature) - Math.log(1000)) / (Math.log(40000) - Math.log(1000));
         var _loc5_:Number;
         var _loc6_:Number = _loc5_ = _loc4_ * _loc2_;
         var _loc7_:Number = 0.6;
         var _loc8_:Number = 0.3 + 0.2 * (Math.log(temperature) - Math.log(1000)) / (Math.log(40000) - Math.log(1000));
         if(_loc8_ > 0.7)
         {
            _loc8_ = 0.7;
         }
         var _loc12_:Matrix = new Matrix();
         halo.graphics.clear();
         graphics.clear();
         if(_loc3_ != _diagram.safeRadius)
         {
            if(_loc6_ > _diagram.safeRadius)
            {
               _loc6_ = _diagram.safeRadius;
            }
            _loc12_.createGradientBox(2 * _loc5_,2 * _loc5_,0,-_loc5_,-_loc5_);
            _loc11_ = [0,int(255 / _loc4_) - 1,255];
            _loc13_ = uint(_loc1_ >> 16 & 0xFF);
            _loc14_ = uint(_loc1_ >> 8 & 0xFF);
            _loc15_ = uint(_loc1_ & 0xFF);
            _loc13_ += _loc7_ * (255 - _loc13_);
            _loc14_ += _loc7_ * (255 - _loc14_);
            _loc15_ += _loc7_ * (255 - _loc15_);
            if(_loc13_ > 255)
            {
               _loc13_ = 255;
            }
            if(_loc14_ > 255)
            {
               _loc14_ = 255;
            }
            if(_loc15_ > 255)
            {
               _loc15_ = 255;
            }
            _loc16_ = uint(_loc13_ << 16 | _loc14_ << 8 | _loc15_);
            _loc9_ = [_loc16_,_loc16_,16777215];
            _loc10_ = [_loc8_,_loc8_,0];
            halo.graphics.beginGradientFill("radial",_loc9_,_loc10_,_loc11_,_loc12_);
            halo.graphics.drawCircle(0,0,_loc6_);
            halo.graphics.endFill();
         }
         var _loc17_:Number = 2 + 3 * (_loc3_ - 2) / (_diagram.safeRadius - 2);
         if(_loc17_ > 5)
         {
            _loc17_ = 5;
         }
         _blur.blurX = _blur.blurY = _loc17_;
         disc.filters = [_blur];
         disc.graphics.clear();
         var _loc18_:Number = 5;
         var _loc19_:Number = _loc18_ + _diagram.starX;
         var _loc20_:Number = _diagram.width - _diagram.starX + _loc18_;
         var _loc21_:Number = _loc18_ + _diagram.height / 2;
         var _loc22_:Number = Math.sqrt(_loc2_ * _loc2_ - _loc21_ * _loc21_);
         if(isNaN(_loc22_))
         {
            disc.graphics.beginFill(_loc1_);
            disc.graphics.drawCircle(0,0,_loc2_);
            disc.graphics.endFill();
            _loc9_ = [16777215,16777215,16777215];
            _loc10_ = [0.95,0.8,0.6];
            _loc11_ = [0,170,255];
            _loc12_.createGradientBox(2 * _loc2_,2 * _loc2_,0,-_loc2_,-_loc2_);
            disc.graphics.beginGradientFill("radial",_loc9_,_loc10_,_loc11_,_loc12_);
            disc.graphics.drawCircle(0,0,_loc3_);
            disc.graphics.endFill();
         }
         else
         {
            _loc23_ = Math.asin(_loc21_ / _loc2_);
            disc.graphics.beginFill(_loc1_);
            disc.graphics.moveTo(Math.min(_loc22_,_loc20_),_loc21_);
            if(_loc22_ < _loc20_)
            {
               drawArc(disc.graphics,0,0,_loc2_,-_loc23_,_loc23_);
            }
            else
            {
               disc.graphics.lineTo(_loc20_,-_loc21_);
            }
            disc.graphics.lineTo(Math.max(-_loc22_,-_loc19_),-_loc21_);
            if(-_loc22_ > -_loc19_)
            {
               drawArc(disc.graphics,0,0,_loc2_,Math.PI - _loc23_,Math.PI + _loc23_);
            }
            else
            {
               disc.graphics.lineTo(-_loc19_,_loc21_);
            }
            disc.graphics.lineTo(Math.min(_loc22_,_loc20_),_loc21_);
            disc.graphics.endFill();
            _loc9_ = [16777215,16777215,16777215];
            _loc10_ = [0.95,0.8,0.6];
            _loc11_ = [0,170,255];
            _loc12_.createGradientBox(2 * _loc2_,2 * _loc2_,0,-_loc2_,-_loc2_);
            disc.graphics.beginGradientFill("radial",_loc9_,_loc10_,_loc11_,_loc12_);
            disc.graphics.moveTo(Math.min(_loc22_,_loc20_),_loc21_);
            if(_loc22_ < _loc20_)
            {
               drawArc(disc.graphics,0,0,_loc2_,-_loc23_,_loc23_);
            }
            else
            {
               disc.graphics.lineTo(_loc20_,-_loc21_);
            }
            disc.graphics.lineTo(Math.max(-_loc22_,-_loc19_),-_loc21_);
            if(-_loc22_ > -_loc19_)
            {
               drawArc(disc.graphics,0,0,_loc2_,Math.PI - _loc23_,Math.PI + _loc23_);
            }
            else
            {
               disc.graphics.lineTo(-_loc19_,_loc21_);
            }
            disc.graphics.lineTo(Math.min(_loc22_,_loc20_),_loc21_);
            disc.graphics.endFill();
         }
      }
      
      protected function getColorFromTemp(param1:Number) : uint
      {
         var _loc6_:Number = NaN;
         if(param1 < 1000)
         {
            param1 = 1000;
         }
         else if(param1 > 40000)
         {
            param1 = 40000;
         }
         var _loc2_:Number = Math.log(param1) / Math.LN10;
         var _loc3_:Number = _loc2_ * _loc2_;
         var _loc4_:Number = _loc2_ * _loc3_;
         var _loc5_:Number = 22686.34111 - _loc2_ * 15082.52755 + _loc3_ * 3375.333832 - _loc4_ * 252.4073853;
         if(_loc5_ < 0)
         {
            _loc5_ = 0;
         }
         else if(_loc5_ > 255)
         {
            _loc5_ = 255;
         }
         if(param1 <= 6500)
         {
            _loc6_ = -811.6499145 + _loc2_ * 36.97365953 + _loc3_ * 160.7861677 - _loc4_ * 25.57573664;
         }
         else
         {
            _loc6_ = 13836.23586 - _loc2_ * 9069.078214 + _loc3_ * 2015.254756 - _loc4_ * 149.7766966;
         }
         var _loc7_:Number = -11545.34298 + _loc2_ * 8529.658165 - _loc3_ * 2150.198586 + _loc4_ * 190.0306573;
         if(_loc7_ < 0)
         {
            _loc7_ = 0;
         }
         else if(_loc7_ > 255)
         {
            _loc7_ = 255;
         }
         return uint(_loc5_) << 16 | uint(_loc6_) << 8 | uint(_loc7_);
      }
      
      protected function drawArc(param1:Graphics, param2:Number, param3:Number, param4:Number, param5:Number = 0, param6:Number = 6.283185307179586, param7:Boolean = true) : void
      {
         var _loc8_:Number = 0.5;
         if(param5 < 0)
         {
            param5 = param5 % (2 * Math.PI) + 2 * Math.PI;
         }
         else
         {
            param5 %= 2 * Math.PI;
         }
         if(param6 < 0)
         {
            param6 = param6 % (2 * Math.PI) + 2 * Math.PI;
         }
         else
         {
            param6 %= 2 * Math.PI;
         }
         var _loc9_:Number = param6 - param5;
         if(_loc9_ < 0)
         {
            _loc9_ = 2 * Math.PI + _loc9_;
         }
         var _loc10_:int = Math.ceil(_loc9_ / _loc8_);
         var _loc11_:Number = _loc9_ / _loc10_;
         var _loc12_:Number = _loc11_ / 2;
         var _loc13_:Number = param4 / Math.cos(_loc12_);
         var _loc14_:Number = param5;
         var _loc15_:Number = param5 - _loc12_;
         if(!param7)
         {
            param1.moveTo(param2 + param4 * Math.cos(param5),param3 - param4 * Math.sin(param5));
         }
         var _loc16_:int = 0;
         while(_loc16_ < _loc10_)
         {
            _loc14_ += _loc11_;
            _loc15_ += _loc11_;
            param1.curveTo(param2 + _loc13_ * Math.cos(_loc15_),param3 - _loc13_ * Math.sin(_loc15_),param2 + param4 * Math.cos(_loc14_),param3 - param4 * Math.sin(_loc14_));
            _loc16_++;
         }
      }
   }
}

