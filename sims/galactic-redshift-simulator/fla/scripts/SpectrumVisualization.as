package
{
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.geom.Rectangle;
   
   public class SpectrumVisualization extends Spectrum
   {
      
      public static const visualMin:Number = 400;
      
      public static const visualMax:Number = 700;
      
      protected var _bmd:BitmapData;
      
      protected var _intensities:Vector.<Number>;
      
      protected var _bm:Bitmap;
      
      protected var _contentRect:Rectangle;
      
      public function SpectrumVisualization(param1:Number, param2:Number, param3:Array, param4:Number, param5:Number, param6:Number)
      {
         super(param1,param2,param3,param4,param5,param6);
         this._bmd = new BitmapData(_width,_height,false,0);
         this._bm = new Bitmap(this._bmd);
         this._bm.y = -_height;
         _content.addChild(this._bm);
         this._intensities = new Vector.<Number>(this._bmd.width);
         this._contentRect = new Rectangle(0,-_height,_width,_height);
         this.redraw();
      }
      
      override public function redraw() : void
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc10_:Number = NaN;
         var _loc12_:Number = NaN;
         var _loc13_:Number = NaN;
         var _loc14_:Number = NaN;
         var _loc15_:Number = NaN;
         var _loc16_:Number = NaN;
         var _loc17_:Number = NaN;
         var _loc18_:Number = NaN;
         super.redraw();
         this._bmd.fillRect(this._contentRect,0);
         _loc1_ = 0;
         while(_loc1_ < this._intensities.length)
         {
            this._intensities[_loc1_] = 0;
            _loc1_++;
         }
         var _loc3_:Number = (_maxW - _minW) / this._bmd.width;
         var _loc4_:Number = _width / (_maxW - _minW);
         var _loc5_:Number = _redshift + 1;
         var _loc11_:Number = _maxF - _minF;
         var _loc19_:int = 0;
         var _loc20_:int = 0;
         _loc1_ = 0;
         while(_loc1_ < _data.length)
         {
            if(_loc1_ == 0)
            {
               _loc6_ = _loc4_ * (_loc5_ * _data[_loc1_].w - _minW);
               _loc7_ = _loc4_ * (_loc5_ * _data[_loc1_ + 1].w - _minW);
               _loc9_ = (_loc6_ + _loc7_) / 2;
               _loc8_ = _loc6_ - (_loc9_ - _loc6_) / 2;
            }
            else if(_loc1_ == _data.length - 1)
            {
               _loc6_ = _loc7_;
               _loc8_ = _loc9_;
               _loc9_ = _loc6_ + (_loc6_ - _loc8_) / 2;
            }
            else
            {
               _loc6_ = _loc7_;
               _loc8_ = _loc9_;
               _loc7_ = _loc4_ * (_loc5_ * _data[_loc1_ + 1].w - _minW);
               _loc9_ = (_loc6_ + _loc7_) / 2;
            }
            _loc10_ = _loc11_ * (_data[_loc1_].f - _minF);
            if(_loc10_ > 1)
            {
               _loc10_ = 1;
            }
            else if(_loc10_ < 0)
            {
               _loc10_ = 0;
            }
            _loc12_ = _loc9_ - _loc8_;
            _loc13_ = Math.floor(_loc8_);
            _loc14_ = Math.floor(_loc9_);
            _loc18_ = _loc10_ / _loc12_;
            if(!(_loc14_ < 0 || _loc13_ >= this._intensities.length))
            {
               if(_loc13_ == _loc14_)
               {
                  _loc19_++;
                  if(_loc13_ >= 0 && _loc13_ < this._intensities.length)
                  {
                     this._intensities[_loc13_] += _loc10_;
                  }
               }
               else
               {
                  _loc20_++;
                  if(_loc13_ >= 0 && _loc13_ < this._intensities.length)
                  {
                     this._intensities[_loc13_] += (1 - (_loc8_ - _loc13_)) * _loc18_;
                  }
                  if(_loc14_ >= 0 && _loc14_ < this._intensities.length)
                  {
                     this._intensities[_loc14_] += (_loc9_ - _loc14_) * _loc18_;
                  }
                  _loc17_ = _loc13_ + 1;
                  while(_loc17_ < _loc14_)
                  {
                     if(_loc17_ >= 0 && _loc17_ < this._intensities.length)
                     {
                        this._intensities[_loc17_] += _loc18_;
                     }
                     _loc17_++;
                  }
               }
            }
            _loc1_++;
         }
         var _loc21_:Rectangle = new Rectangle(0,0,1,this._bmd.height);
         var _loc22_:Number = Number.NEGATIVE_INFINITY;
         _loc1_ = 0;
         while(_loc1_ < this._intensities.length)
         {
            if(this._intensities[_loc1_] > _loc22_)
            {
               _loc22_ = this._intensities[_loc1_];
            }
            _loc1_++;
         }
         var _loc23_:Number = (_maxW - _minW) / this._bmd.width;
         var _loc24_:Number = _minW + _loc23_ / 2;
         _loc1_ = 0;
         while(_loc1_ < this._intensities.length)
         {
            _loc21_.x = _loc1_;
            this._bmd.fillRect(_loc21_,this.colorFromWavelengthAndIntensity(_loc24_,this._intensities[_loc1_] / _loc22_));
            _loc24_ += _loc23_;
            _loc1_++;
         }
      }
      
      protected function colorFromWavelengthAndIntensity(param1:Number, param2:Number) : uint
      {
         var _loc7_:Number = NaN;
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         var _loc10_:int = 0;
         var _loc11_:int = 0;
         var _loc3_:Number = (param1 - 400) / 300;
         if(_loc3_ < 0 || _loc3_ > 1)
         {
            return 0;
         }
         _loc3_ *= 256;
         var _loc4_:Array = [0,255,65535,65280,16776960,16711680,0];
         var _loc5_:Array = [0,48,96,128,160,207,256];
         var _loc6_:uint = 0;
         _loc11_ = 1;
         while(_loc11_ < _loc5_.length)
         {
            if(_loc3_ <= _loc5_[_loc11_])
            {
               _loc7_ = (_loc3_ - _loc5_[_loc11_ - 1]) / (_loc5_[_loc11_] - _loc5_[_loc11_ - 1]);
               _loc8_ = int(param2 * ((_loc4_[_loc11_ - 1] >> 16 & 0xFF) + _loc7_ * ((_loc4_[_loc11_] >> 16 & 0xFF) - (_loc4_[_loc11_ - 1] >> 16 & 0xFF))));
               if(_loc8_ < 0)
               {
                  _loc8_ = 0;
               }
               else if(_loc8_ > 255)
               {
                  _loc8_ = 255;
               }
               _loc9_ = int(param2 * ((_loc4_[_loc11_ - 1] >> 8 & 0xFF) + _loc7_ * ((_loc4_[_loc11_] >> 8 & 0xFF) - (_loc4_[_loc11_ - 1] >> 8 & 0xFF))));
               if(_loc9_ < 0)
               {
                  _loc9_ = 0;
               }
               else if(_loc9_ > 255)
               {
                  _loc9_ = 255;
               }
               _loc10_ = int(param2 * ((_loc4_[_loc11_ - 1] & 0xFF) + _loc7_ * ((_loc4_[_loc11_] & 0xFF) - (_loc4_[_loc11_ - 1] & 0xFF))));
               if(_loc10_ < 0)
               {
                  _loc10_ = 0;
               }
               else if(_loc10_ > 255)
               {
                  _loc10_ = 255;
               }
               _loc6_ = uint(_loc8_ << 16 | _loc9_ << 8 | _loc10_);
               break;
            }
            _loc11_++;
         }
         return _loc6_;
      }
   }
}

