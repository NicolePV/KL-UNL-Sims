function CSDeclinationTrailsClass(parent, name, id, style, head, depth)
{
   this._parent = parent;
   this._name = name;
   this._id = id;
   this._fwmc = this._parent._fDT.createEmptyMovieClip("_" + depth,depth);
   this._fimc = this._fwmc.createEmptyMovieClip("innerMC",1);
   this._bwmc = this._parent._bDT.createEmptyMovieClip("_" + depth,depth);
   this._bimc = this._bwmc.createEmptyMovieClip("innerMC",1);
   this._fmmc = this._parent._fDT.createEmptyMovieClip("m" + depth,500000 + depth);
   this._bmmc = this._parent._bDT.createEmptyMovieClip("m" + depth,500000 + depth);
   this._fwmc.setMask(this._fmmc);
   this._bwmc.setMask(this._bmmc);
   this._style = {};
   this.setStyle(style);
   this._head = {};
   this.setHeadPoint(head);
   this._visible = true;
   this.updateMasks();
}
var p = CelestialSphereClass.prototype;
p.addDeclinationTrail = function(name, style, head, depth)
{
   if(this._fDT._ir == undefined)
   {
      this._fDT._ir = 0;
   }
   if(depth == undefined)
   {
      depth = 0;
      while(this._fDT["_" + depth] != undefined)
      {
         depth = depth + 1;
      }
   }
   var _loc4_ = this._decTrailFreeID++;
   this[name] = new CSDeclinationTrailsClass(this,name,_loc4_,style,head,depth);
   this._decTrailList.push({id:_loc4_,name:this[name]});
   return this[name];
};
p._decTrailAngle = 1.0471975511965976;
p.getDeclinationTrailLength = function()
{
   return this._decTrailAngle * 180 / 3.141592653589793;
};
p.setDeclinationTrailLength = function(arg)
{
   this._decTrailAngle = (arg % 360 + 360) % 360 * 3.141592653589793 / 180;
   this.updateTrailArcs();
};
p.addProperty("declinationTrailLengths",p.getDeclinationTrailLengths,p.setDeclinationTrailLengths);
p.updateTrailArcs = function()
{
   var _loc3_ = this._decTrailList;
   var _loc2_ = 0;
   while(_loc2_ < _loc3_.length)
   {
      _loc3_[_loc2_].name.updateArcs();
      _loc2_ = _loc2_ + 1;
   }
};
p.updateTrailMasks = function()
{
   var _loc3_ = this._decTrailList;
   var _loc2_ = 0;
   while(_loc2_ < _loc3_.length)
   {
      _loc3_[_loc2_].name.updateMasks();
      _loc2_ = _loc2_ + 1;
   }
};
p.updateDeclinationTrails = function(arg)
{
   var _loc47_ = getTimer();
   var _loc45_;
   var _loc29_;
   var _loc30_;
   var _loc24_;
   var _loc2_;
   var _loc27_;
   var _loc38_;
   var _loc37_;
   var _loc41_;
   var _loc36_;
   var _loc34_;
   var _loc40_;
   var _loc43_;
   var _loc42_;
   var _loc39_;
   var _loc44_;
   var _loc28_;
   var _loc46_;
   var _loc32_;
   var _loc31_;
   var _loc35_;
   var _loc33_;
   var _loc3_;
   var _loc10_;
   var _loc6_;
   var _loc5_;
   var _loc18_;
   var _loc8_;
   var _loc13_;
   var _loc7_;
   var _loc17_;
   var _loc9_;
   var _loc19_;
   var _loc16_;
   var _loc21_;
   var _loc20_;
   var _loc23_;
   var _loc22_;
   var _loc26_;
   var _loc25_;
   var _loc15_;
   var _loc14_;
   var _loc12_;
   var _loc11_;
   var _loc4_;
   if(arg)
   {
      _loc45_ = this._sTime * 180 / 3.141592653589793;
      _loc29_ = this._fDT._ir;
      _loc30_ = this._decTrailList;
      _loc24_ = _loc30_.length - 1;
      _loc2_ = _loc30_[_loc24_].name;
      while(_loc24_ >= 0)
      {
         _loc2_._bimc._rotation = _loc2_._fimc._rotation = _loc29_ + _loc45_ - _loc2_._rot;
         _loc2_ = _loc30_[_loc24_ = _loc24_ - 1].name;
      }
   }
   else
   {
      _loc27_ = this._c;
      _loc38_ = _loc27_.b0;
      _loc37_ = _loc27_.b1;
      _loc41_ = _loc27_.b2;
      _loc36_ = _loc27_.b3;
      _loc34_ = _loc27_.b4;
      _loc40_ = _loc27_.b5;
      _loc43_ = _loc27_.b6;
      _loc42_ = _loc27_.b7;
      _loc39_ = _loc27_.b8;
      _loc44_ = Math.sqrt;
      _loc28_ = Math.atan2;
      _loc46_ = Math.asin;
      _loc32_ = Math.cos;
      _loc31_ = Math.sin;
      _loc29_ = -57.29577951308232 * _loc28_(_loc27_.a7,_loc27_.a8 * _loc27_.m2 - _loc27_.a6 * _loc27_.m8);
      this._fDT._ir = _loc29_;
      _loc35_ = -57.29577951308232 * _loc28_(_loc41_,_loc40_);
      _loc33_ = 100 * _loc39_ / _loc27_.r;
      _loc45_ = this._sTime * 180 / 3.141592653589793;
      _loc30_ = this._decTrailList;
      _loc24_ = _loc30_.length - 1;
      _loc2_ = _loc30_[_loc24_].name;
      while(_loc24_ >= 0)
      {
         _loc3_ = _loc2_._cd;
         _loc10_ = _loc2_._sd;
         if(_loc3_ != null)
         {
            _loc6_ = _loc41_ * _loc10_;
            _loc5_ = _loc40_ * _loc10_;
            _loc18_ = _loc45_ - _loc2_._rot;
            _loc2_._fwmc._rotation = _loc35_;
            _loc2_._fwmc._yscale = _loc33_;
            _loc2_._fwmc._x = _loc6_;
            _loc2_._fwmc._y = _loc5_;
            _loc2_._fimc._rotation = _loc29_ + _loc18_;
            _loc2_._bwmc._rotation = _loc35_;
            _loc2_._bwmc._yscale = _loc33_;
            _loc2_._bwmc._x = _loc6_;
            _loc2_._bwmc._y = _loc5_;
            _loc2_._bimc._rotation = _loc29_ + _loc18_;
            _loc8_ = _loc43_ * _loc3_;
            _loc13_ = _loc42_ * _loc3_;
            _loc7_ = _loc39_ * _loc10_;
            _loc17_ = _loc44_(_loc8_ * _loc8_ + _loc13_ * _loc13_);
            if(_loc17_ == 0)
            {
               if(_loc7_ < 0)
               {
                  _loc2_._fmmc._rotation = 0;
                  _loc2_._fmmc._x = 0;
                  _loc2_._fmmc._y = - _loc2_._yOffset;
                  _loc2_._bmmc._rotation = 0;
                  _loc2_._bmmc._x = 0;
                  _loc2_._bmmc._y = _loc2_._yOffset;
               }
               else
               {
                  _loc2_._fmmc._rotation = 0;
                  _loc2_._fmmc._x = 0;
                  _loc2_._fmmc._y = _loc2_._yOffset;
                  _loc2_._bmmc._rotation = 0;
                  _loc2_._bmmc._x = 0;
                  _loc2_._bmmc._y = - _loc2_._yOffset;
               }
            }
            else
            {
               _loc9_ = (- _loc7_) / _loc17_;
               if(_loc9_ <= -1)
               {
                  _loc2_._fmmc._rotation = 0;
                  _loc2_._fmmc._x = 0;
                  _loc2_._fmmc._y = _loc2_._yOffset;
                  _loc2_._bmmc._rotation = 0;
                  _loc2_._bmmc._x = 0;
                  _loc2_._bmmc._y = - _loc2_._yOffset;
               }
               else if(_loc9_ >= 1)
               {
                  _loc2_._fmmc._rotation = 0;
                  _loc2_._fmmc._x = 0;
                  _loc2_._fmmc._y = - _loc2_._yOffset;
                  _loc2_._bmmc._rotation = 0;
                  _loc2_._bmmc._x = 0;
                  _loc2_._bmmc._y = _loc2_._yOffset;
               }
               else
               {
                  _loc19_ = _loc46_(_loc9_);
                  _loc16_ = _loc28_(_loc8_,_loc13_);
                  _loc21_ = _loc19_ - _loc16_;
                  _loc20_ = 3.141592653589793 - _loc19_ - _loc16_;
                  _loc23_ = _loc32_(_loc21_);
                  _loc22_ = _loc31_(_loc21_);
                  _loc26_ = (_loc23_ * _loc38_ + _loc22_ * _loc37_) * _loc3_ + _loc6_;
                  _loc25_ = (_loc23_ * _loc36_ + _loc22_ * _loc34_) * _loc3_ + _loc5_;
                  _loc23_ = _loc32_(_loc20_);
                  _loc22_ = _loc31_(_loc20_);
                  _loc15_ = (_loc23_ * _loc38_ + _loc22_ * _loc37_) * _loc3_ + _loc6_;
                  _loc14_ = (_loc23_ * _loc36_ + _loc22_ * _loc34_) * _loc3_ + _loc5_;
                  _loc12_ = _loc15_ + (_loc26_ - _loc15_) / 2;
                  _loc11_ = _loc14_ + (_loc25_ - _loc14_) / 2;
                  _loc2_._fmmc._x = _loc12_;
                  _loc2_._fmmc._y = _loc11_;
                  _loc2_._bmmc._x = _loc12_;
                  _loc2_._bmmc._y = _loc11_;
                  _loc4_ = _loc28_(_loc11_,_loc12_) * 180 / 3.141592653589793;
                  if(_loc7_ > 0)
                  {
                     _loc2_._fmmc._rotation = _loc4_ - 90;
                     _loc2_._bmmc._rotation = _loc4_ + 90;
                  }
                  else if(_loc7_ < 0)
                  {
                     _loc2_._fmmc._rotation = _loc4_ + 90;
                     _loc2_._bmmc._rotation = _loc4_ - 90;
                  }
               }
            }
         }
         _loc2_ = _loc30_[_loc24_ = _loc24_ - 1].name;
      }
   }
};
p.showDeclinationTrails = function()
{
   var _loc3_ = this._decTrailList;
   var _loc2_ = 0;
   while(_loc2_ < _loc3_.length)
   {
      _loc3_[_loc2_].name.visible = true;
      _loc2_ = _loc2_ + 1;
   }
};
p.hideDeclinationTrails = function()
{
   var _loc3_ = this._decTrailList;
   var _loc2_ = 0;
   while(_loc2_ < _loc3_.length)
   {
      _loc3_[_loc2_].name.visible = false;
      _loc2_ = _loc2_ + 1;
   }
};
p.removeDeclinationTrails = function()
{
   var _loc3_ = this._decTrailList;
   var _loc2_ = 0;
   while(_loc2_ < _loc3_.length)
   {
      _loc2_ = _loc2_ + 1;
   }
   this._decTrailFreeID = 0;
   this._decTrailList = [];
};
var p = CSDeclinationTrailsClass.prototype = new Object();
p.setHeadPoint = function(arg)
{
   this._parent.pointToCelestial(arg,this._head);
   if(this._head.dec != null)
   {
      this._cd = Math.cos(this._head.dec * 3.141592653589793 / 180);
      this._sd = Math.sin(this._head.dec * 3.141592653589793 / 180);
      this._rot = this._head.ra * 15;
      this.updateArcs();
   }
   else
   {
      this._cd = null;
      this._sd = null;
      this._rot = null;
   }
};
p.updateArcs = function()
{
   var _loc12_ = Math.cos;
   var _loc11_ = Math.sin;
   var _loc9_ = this._parent._c.r * this._cd;
   var _loc8_ = this._fimc;
   var _loc7_ = this._bimc;
   _loc8_.clear();
   _loc7_.clear();
   var _loc10_ = 50;
   var _loc14_ = (- this._parent._decTrailAngle) / _loc10_;
   var _loc13_ = -100 / _loc10_;
   var _loc5_ = 4.71238898038469;
   var _loc6_ = 100;
   _loc8_.lineStyle(1,0,_loc6_);
   _loc7_.lineStyle(1,0,_loc6_);
   var _loc4_ = _loc9_ * _loc12_(_loc5_);
   var _loc3_ = _loc9_ * _loc11_(_loc5_);
   _loc8_.moveTo(_loc4_,_loc3_);
   _loc7_.moveTo(_loc4_,_loc3_);
   var _loc2_ = 0;
   while(_loc2_ < _loc10_)
   {
      _loc5_ += _loc14_;
      _loc6_ += _loc13_;
      _loc8_.lineStyle(1,0,_loc6_);
      _loc7_.lineStyle(1,0,_loc6_);
      _loc4_ = _loc9_ * _loc12_(_loc5_);
      _loc3_ = _loc9_ * _loc11_(_loc5_);
      _loc8_.lineTo(_loc4_,_loc3_);
      _loc7_.lineTo(_loc4_,_loc3_);
      _loc2_ = _loc2_ + 1;
   }
};
p.updateMasks = function()
{
   var _loc2_ = 1.3 * this._parent._c.r;
   var _loc5_ = -2.3 * this._parent._c.r;
   this._yOffset = (- _loc5_) / 2;
   var _loc4_ = this._fmmc;
   _loc4_.clear();
   _loc4_.beginFill(16711680,100);
   _loc4_.moveTo(_loc2_,0);
   _loc4_.lineTo(_loc2_,_loc5_);
   _loc4_.lineTo(- _loc2_,_loc5_);
   _loc4_.lineTo(- _loc2_,0);
   _loc4_.lineTo(_loc2_,0);
   _loc4_.endFill();
   var _loc3_ = this._bmmc;
   _loc3_.clear();
   _loc3_.beginFill(255,100);
   _loc3_.moveTo(_loc2_,0);
   _loc3_.lineTo(_loc2_,_loc5_);
   _loc3_.lineTo(- _loc2_,_loc5_);
   _loc3_.lineTo(- _loc2_,0);
   _loc3_.lineTo(_loc2_,0);
   _loc3_.endFill();
};
