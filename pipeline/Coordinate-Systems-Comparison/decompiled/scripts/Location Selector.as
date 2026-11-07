function LocationSelectorClass()
{
   var _loc25_ = GlobeComponentClass.prototype._shoreData;
   this.cursorMC.swapDepths(200);
   this.attachMovie("Location Selector Cursor","cursorMC",200);
   var _loc27_ = this.createEmptyMovieClip("cursorMaskMC",210);
   this.createEmptyMovieClip("oceanFillMC",25);
   this.createEmptyMovieClip("landFillMC",50);
   this.createEmptyMovieClip("landMaskMC",100);
   this.createEmptyMovieClip("crossHairsMC",110);
   this.createEmptyMovieClip("borderMC",1000);
   var _loc6_ = this.landMaskMC.createEmptyMovieClip("area1MC",1);
   var _loc5_ = this.landMaskMC.createEmptyMovieClip("area2MC",2);
   var _loc4_ = this.landMaskMC.createEmptyMovieClip("area3MC",3);
   _loc27_.clear();
   _loc27_.lineStyle(1,16711680,100);
   _loc6_.clear();
   _loc6_.lineStyle(1,16711680,100);
   _loc5_.clear();
   _loc5_.lineStyle(1,16711680,100);
   _loc4_.clear();
   _loc4_.lineStyle(1,16711680,100);
   var _loc2_ = this.width;
   var _loc8_ = _loc2_ / 6.283185307179586;
   var _loc7_ = _loc2_ / 2;
   var _loc24_ = _loc2_ / 4;
   var _loc12_ = this.offset;
   var _loc21_ = Math.atan2;
   var _loc22_ = Math.asin;
   _loc27_.beginFill(16711680,50);
   _loc27_.moveTo(0,- _loc24_);
   _loc27_.lineTo(0,_loc24_);
   _loc27_.lineTo(_loc2_,_loc24_);
   _loc27_.lineTo(_loc2_,- _loc24_);
   _loc27_.lineTo(0,- _loc24_);
   _loc27_.endFill();
   this.cursorMC.setMask(_loc27_);
   var _loc20_ = 0;
   var _loc17_;
   var _loc16_;
   var _loc18_;
   var _loc19_;
   var _loc23_;
   var _loc13_;
   var _loc14_;
   var _loc3_;
   var _loc15_;
   var _loc9_;
   var _loc11_;
   var _loc10_;
   while(_loc20_ < _loc25_.length)
   {
      if(_loc20_ == 5)
      {
         _loc17_ = _loc25_[_loc20_];
         _loc16_ = _loc12_ + _loc8_ * _loc21_(_loc17_[0].y,_loc17_[0].x);
         _loc18_ = (- _loc8_) * _loc22_(_loc17_[0].z);
         _loc6_.moveTo(_loc16_,_loc18_);
         _loc5_.moveTo(_loc2_ + _loc16_,_loc18_);
         _loc4_.moveTo(- _loc2_ + _loc16_,_loc18_);
         _loc6_.beginFill(255,20);
         _loc5_.beginFill(255,20);
         _loc4_.beginFill(255,20);
         _loc19_ = _loc16_;
         _loc23_ = _loc18_;
         _loc13_ = 1;
         while(_loc13_ < _loc17_.length)
         {
            _loc14_ = _loc17_[_loc13_];
            _loc3_ = _loc12_ + _loc8_ * _loc21_(_loc14_.y,_loc14_.x);
            _loc15_ = (- _loc8_) * _loc22_(_loc14_.z);
            if(_loc3_ - _loc19_ > _loc7_)
            {
               _loc9_ = _loc12_ - _loc8_ * 3.141592653589793;
               _loc11_ = _loc12_ + _loc8_ * 3.141592653589793;
               _loc10_ = (_loc15_ + _loc23_) / 2;
               _loc6_.lineTo(_loc9_,_loc10_);
               _loc6_.lineTo(_loc9_,_loc7_);
               _loc6_.lineTo(_loc11_,_loc7_);
               _loc6_.lineTo(_loc11_,_loc10_);
               _loc5_.lineTo(_loc2_ + _loc9_,_loc10_);
               _loc5_.lineTo(_loc2_ + _loc9_,_loc7_);
               _loc5_.lineTo(_loc2_ + _loc11_,_loc7_);
               _loc5_.lineTo(_loc2_ + _loc11_,_loc10_);
               _loc4_.lineTo(- _loc2_ + _loc9_,_loc10_);
               _loc4_.lineTo(- _loc2_ + _loc9_,_loc7_);
               _loc4_.lineTo(- _loc2_ + _loc11_,_loc7_);
               _loc4_.lineTo(- _loc2_ + _loc11_,_loc10_);
            }
            _loc6_.lineTo(_loc3_,_loc15_);
            _loc5_.lineTo(_loc2_ + _loc3_,_loc15_);
            _loc4_.lineTo(- _loc2_ + _loc3_,_loc15_);
            _loc19_ = _loc3_;
            _loc23_ = _loc15_;
            _loc13_ = _loc13_ + 1;
         }
         _loc6_.lineTo(_loc16_,_loc18_);
         _loc5_.lineTo(_loc2_ + _loc16_,_loc18_);
         _loc4_.lineTo(- _loc2_ + _loc16_,_loc18_);
      }
      else
      {
         _loc17_ = _loc25_[_loc20_];
         _loc16_ = _loc12_ + _loc8_ * _loc21_(_loc17_[0].y,_loc17_[0].x);
         _loc18_ = (- _loc8_) * _loc22_(_loc17_[0].z);
         _loc6_.moveTo(_loc16_,_loc18_);
         _loc5_.moveTo(_loc2_ + _loc16_,_loc18_);
         _loc4_.moveTo(- _loc2_ + _loc16_,_loc18_);
         _loc6_.beginFill(255,20);
         _loc5_.beginFill(255,20);
         _loc4_.beginFill(255,20);
         _loc19_ = _loc16_;
         _loc13_ = 1;
         while(_loc13_ < _loc17_.length)
         {
            _loc14_ = _loc17_[_loc13_];
            _loc3_ = _loc12_ + _loc8_ * _loc21_(_loc14_.y,_loc14_.x);
            _loc15_ = (- _loc8_) * _loc22_(_loc14_.z);
            if(_loc3_ - _loc19_ > _loc7_)
            {
               _loc3_ -= _loc2_;
            }
            else if(_loc19_ - _loc3_ > _loc7_)
            {
               _loc3_ += _loc2_;
            }
            _loc6_.lineTo(_loc3_,_loc15_);
            _loc5_.lineTo(_loc2_ + _loc3_,_loc15_);
            _loc4_.lineTo(- _loc2_ + _loc3_,_loc15_);
            _loc19_ = _loc3_;
            _loc13_ = _loc13_ + 1;
         }
         _loc6_.lineTo(_loc16_,_loc18_);
         _loc5_.lineTo(_loc2_ + _loc16_,_loc18_);
         _loc4_.lineTo(- _loc2_ + _loc16_,_loc18_);
      }
      _loc20_ = _loc20_ + 1;
   }
   var _loc28_ = this.landFillMC;
   _loc28_.clear();
   _loc28_.lineStyle(1,16711680,0);
   _loc28_.moveTo(0,- _loc24_);
   _loc28_.beginFill(13481116,100);
   _loc28_.lineTo(0,_loc24_);
   _loc28_.lineTo(_loc2_,_loc24_);
   _loc28_.lineTo(_loc2_,- _loc24_);
   _loc28_.lineTo(0,- _loc24_);
   _loc28_.endFill();
   var _loc26_ = this.oceanFillMC;
   _loc26_.clear();
   _loc26_.lineStyle(1,16711680,0);
   _loc26_.moveTo(0,- _loc24_);
   _loc26_.beginFill(15068410,100);
   _loc26_.lineTo(0,_loc24_);
   _loc26_.lineTo(_loc2_,_loc24_);
   _loc26_.lineTo(_loc2_,- _loc24_);
   _loc26_.lineTo(0,- _loc24_);
   _loc26_.endFill();
   _loc26_.useHandCursor = false;
   _loc26_.onPress = function()
   {
      this._parent.moveCursorTo(this._parent._xmouse,this._parent._ymouse);
      this._parent.cursorMC.onRollOver();
      this._parent.cursorMC.onPress();
   };
   _loc26_.onRelease = function()
   {
      this._parent.cursorMC.onRelease();
   };
   _loc26_.onReleaseOutside = function()
   {
      this._parent.cursorMC.onReleaseOutside();
   };
   this.landFillMC.setMask(this.landMaskMC);
   var _loc29_ = this.borderMC;
   _loc29_.clear();
   _loc29_.lineStyle(1,0,100);
   _loc29_.moveTo(0,- _loc24_);
   _loc29_.lineTo(0,_loc24_);
   _loc29_.lineTo(_loc2_,_loc24_);
   _loc29_.lineTo(_loc2_,- _loc24_);
   _loc29_.lineTo(0,- _loc24_);
}
var p = LocationSelectorClass.prototype = new MovieClip();
Object.registerClass("Location Selector",LocationSelectorClass);
p.width = 360;
p.offset = 170;
p.crossHairColor = 8421504;
p.crossHairAlpha = 50;
p.getCursorLocation = function()
{
   var _loc5_ = this.width;
   var _loc3_ = 360 / _loc5_;
   var _loc4_ = this.offset;
   var _loc2_ = {};
   _loc2_.lat = (- _loc3_) * this.cursorMC._y;
   _loc2_.lon = _loc3_ * this.cursorMC._x - _loc4_;
   return _loc2_;
};
p.setCursorLocation = function(pt)
{
   var _loc2_ = this.width;
   var _loc5_ = 360 / _loc2_;
   var _loc6_ = this.offset;
   var _loc4_ = pt.lat;
   if(_loc4_ < -90)
   {
      _loc4_ = -90;
   }
   else if(_loc4_ > 90)
   {
      _loc4_ = 90;
   }
   this.cursorMC._x = ((pt.lon + _loc6_) / _loc5_ % _loc2_ + _loc2_) % _loc2_;
   this.cursorMC._y = (- _loc4_) / _loc5_;
   var _loc3_ = this.crossHairsMC;
   _loc3_.clear();
   _loc3_.lineStyle(1,this.crossHairColor,this.crossHairAlpha);
   _loc3_.moveTo(this.cursorMC._x,_loc2_ / 4);
   _loc3_.lineTo(this.cursorMC._x,(- _loc2_) / 4);
   _loc3_.moveTo(0,this.cursorMC._y);
   _loc3_.lineTo(_loc2_,this.cursorMC._y);
};
p.moveCursorTo = function(x, y)
{
   var _loc4_ = this.width;
   var _loc2_ = 360 / _loc4_;
   var _loc3_ = this.offset;
   var _loc5_ = _loc2_ * x - _loc3_;
   var _loc6_ = (- _loc2_) * y;
   if(_loc6_ < -90)
   {
      _loc6_ = -90;
   }
   else if(_loc6_ > 90)
   {
      _loc6_ = 90;
   }
   this.onCursorMoved({lat:_loc6_,lon:_loc5_});
};
