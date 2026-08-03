function CSDeclinationTrailsClass(parent, name, id, style, head, depth)
{
   var _loc1_ = this;
   var _loc2_ = depth;
   _loc1_._parent = parent;
   _loc1_._name = name;
   _loc1_._id = id;
   _loc1_._fwmc = _loc1_._parent._fDT.createEmptyMovieClip("_" + _loc2_,_loc2_);
   _loc1_._fimc = _loc1_._fwmc.createEmptyMovieClip("innerMC",1);
   _loc1_._bwmc = _loc1_._parent._bDT.createEmptyMovieClip("_" + _loc2_,_loc2_);
   _loc1_._bimc = _loc1_._bwmc.createEmptyMovieClip("innerMC",1);
   _loc1_._fmmc = _loc1_._parent._fDT.createEmptyMovieClip("m" + _loc2_,500000 + _loc2_);
   _loc1_._bmmc = _loc1_._parent._bDT.createEmptyMovieClip("m" + _loc2_,500000 + _loc2_);
   _loc1_._fwmc.setMask(_loc1_._fmmc);
   _loc1_._bwmc.setMask(_loc1_._bmmc);
   _loc1_._style = {};
   _loc1_.setStyle(style);
   _loc1_._head = {};
   _loc1_.setHeadPoint(head);
   _loc1_._visible = true;
   _loc1_.updateMasks();
}
var p = CelestialSphereClass.prototype;
p.addDeclinationTrail = function(name, style, head, depth)
{
   var _loc1_ = depth;
   var _loc2_ = this;
   var _loc3_ = name;
   if(_loc2_._fDT._ir == undefined)
   {
      _loc2_._fDT._ir = 0;
   }
   if(_loc1_ == undefined)
   {
      _loc1_ = 0;
      while(_loc2_._fDT["_" + _loc1_] != undefined)
      {
         _loc1_ = _loc1_ + 1;
      }
   }
   var id = _loc2_._decTrailFreeID++;
   _loc2_[_loc3_] = new CSDeclinationTrailsClass(_loc2_,_loc3_,id,style,head,_loc1_);
   _loc2_._decTrailList.push({id:id,name:_loc2_[_loc3_]});
   return _loc2_[_loc3_];
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
   var _loc2_ = this._decTrailList;
   var _loc1_ = 0;
   while(_loc1_ < _loc2_.length)
   {
      _loc2_[_loc1_].name.updateArcs();
      _loc1_ = _loc1_ + 1;
   }
};
p.updateTrailMasks = function()
{
   var _loc2_ = this._decTrailList;
   var _loc1_ = 0;
   while(_loc1_ < _loc2_.length)
   {
      _loc2_[_loc1_].name.updateMasks();
      _loc1_ = _loc1_ + 1;
   }
};
p.updateDeclinationTrails = function(arg)
{
   var start = getTimer();
   var _loc1_;
   var _loc2_;
   var _loc3_;
   if(arg)
   {
      var st = this._sTime * 180 / 3.141592653589793;
      var ir = this._fDT._ir;
      var list = this._decTrailList;
      var i = list.length - 1;
      _loc1_ = list[i].name;
      while(i >= 0)
      {
         _loc1_._bimc._rotation = _loc1_._fimc._rotation = ir + st - _loc1_._rot;
         _loc1_ = list[--i].name;
      }
   }
   else
   {
      var c = this._c;
      var b0 = c.b0;
      var b1 = c.b1;
      var b2 = c.b2;
      var b3 = c.b3;
      var b4 = c.b4;
      var b5 = c.b5;
      var b6 = c.b6;
      var b7 = c.b7;
      var b8 = c.b8;
      var sqrt = Math.sqrt;
      var atan2 = Math.atan2;
      var asin = Math.asin;
      var cos = Math.cos;
      var sin = Math.sin;
      var ir = -57.29577951308232 * atan2(c.a7,c.a8 * c.m2 - c.a6 * c.m8);
      this._fDT._ir = ir;
      var wr = -57.29577951308232 * atan2(b2,b5);
      var ws = 100 * b8 / c.r;
      var st = this._sTime * 180 / 3.141592653589793;
      var list = this._decTrailList;
      var i = list.length - 1;
      _loc1_ = list[i].name;
      while(i >= 0)
      {
         _loc2_ = _loc1_._cd;
         var sd = _loc1_._sd;
         if(_loc2_ != null)
         {
            var x = b2 * sd;
            var y = b5 * sd;
            var tr = st - _loc1_._rot;
            _loc1_._fwmc._rotation = wr;
            _loc1_._fwmc._yscale = ws;
            _loc1_._fwmc._x = x;
            _loc1_._fwmc._y = y;
            _loc1_._fimc._rotation = ir + tr;
            _loc1_._bwmc._rotation = wr;
            _loc1_._bwmc._yscale = ws;
            _loc1_._bwmc._x = x;
            _loc1_._bwmc._y = y;
            _loc1_._bimc._rotation = ir + tr;
            var k1 = b6 * _loc2_;
            var k2 = b7 * _loc2_;
            var k3 = b8 * sd;
            var A = sqrt(k1 * k1 + k2 * k2);
            if(A == 0)
            {
               if(k3 < 0)
               {
                  _loc1_._fmmc._rotation = 0;
                  _loc1_._fmmc._x = 0;
                  _loc1_._fmmc._y = - _loc1_._yOffset;
                  _loc1_._bmmc._rotation = 0;
                  _loc1_._bmmc._x = 0;
                  _loc1_._bmmc._y = _loc1_._yOffset;
               }
               else
               {
                  _loc1_._fmmc._rotation = 0;
                  _loc1_._fmmc._x = 0;
                  _loc1_._fmmc._y = _loc1_._yOffset;
                  _loc1_._bmmc._rotation = 0;
                  _loc1_._bmmc._x = 0;
                  _loc1_._bmmc._y = - _loc1_._yOffset;
               }
            }
            else
            {
               var sj = (- k3) / A;
               if(sj <= -1)
               {
                  _loc1_._fmmc._rotation = 0;
                  _loc1_._fmmc._x = 0;
                  _loc1_._fmmc._y = _loc1_._yOffset;
                  _loc1_._bmmc._rotation = 0;
                  _loc1_._bmmc._x = 0;
                  _loc1_._bmmc._y = - _loc1_._yOffset;
               }
               else if(sj >= 1)
               {
                  _loc1_._fmmc._rotation = 0;
                  _loc1_._fmmc._x = 0;
                  _loc1_._fmmc._y = - _loc1_._yOffset;
                  _loc1_._bmmc._rotation = 0;
                  _loc1_._bmmc._x = 0;
                  _loc1_._bmmc._y = _loc1_._yOffset;
               }
               else
               {
                  var j = asin(sj);
                  var t = atan2(k1,k2);
                  var g1 = j - t;
                  var g2 = 3.141592653589793 - j - t;
                  var ix = cos(g1);
                  var iy = sin(g1);
                  var x1 = (ix * b0 + iy * b1) * _loc2_ + x;
                  var y1 = (ix * b3 + iy * b4) * _loc2_ + y;
                  var ix = cos(g2);
                  var iy = sin(g2);
                  var x2 = (ix * b0 + iy * b1) * _loc2_ + x;
                  var y2 = (ix * b3 + iy * b4) * _loc2_ + y;
                  var mx = x2 + (x1 - x2) / 2;
                  var my = y2 + (y1 - y2) / 2;
                  _loc1_._fmmc._x = mx;
                  _loc1_._fmmc._y = my;
                  _loc1_._bmmc._x = mx;
                  _loc1_._bmmc._y = my;
                  _loc3_ = atan2(my,mx) * 180 / 3.141592653589793;
                  if(k3 > 0)
                  {
                     _loc1_._fmmc._rotation = _loc3_ - 90;
                     _loc1_._bmmc._rotation = _loc3_ + 90;
                  }
                  else if(k3 < 0)
                  {
                     _loc1_._fmmc._rotation = _loc3_ + 90;
                     _loc1_._bmmc._rotation = _loc3_ - 90;
                  }
               }
            }
         }
         _loc1_ = list[--i].name;
      }
   }
};
p.showDeclinationTrails = function()
{
   var _loc2_ = this._decTrailList;
   var _loc1_ = 0;
   while(_loc1_ < _loc2_.length)
   {
      _loc2_[_loc1_].name.visible = true;
      _loc1_ = _loc1_ + 1;
   }
};
p.hideDeclinationTrails = function()
{
   var _loc2_ = this._decTrailList;
   var _loc1_ = 0;
   while(_loc1_ < _loc2_.length)
   {
      _loc2_[_loc1_].name.visible = false;
      _loc1_ = _loc1_ + 1;
   }
};
p.removeDeclinationTrails = function()
{
   var _loc3_ = this;
   var _loc2_ = _loc3_._decTrailList;
   var _loc1_ = 0;
   while(_loc1_ < _loc2_.length)
   {
      _loc1_ = _loc1_ + 1;
   }
   _loc3_._decTrailFreeID = 0;
   _loc3_._decTrailList = [];
};
var p = CSDeclinationTrailsClass.prototype = new Object();
p.setHeadPoint = function(arg)
{
   var _loc1_ = this;
   _loc1_._parent.pointToCelestial(arg,_loc1_._head);
   if(_loc1_._head.dec != null)
   {
      _loc1_._cd = Math.cos(_loc1_._head.dec * 3.141592653589793 / 180);
      _loc1_._sd = Math.sin(_loc1_._head.dec * 3.141592653589793 / 180);
      _loc1_._rot = _loc1_._head.ra * 15;
      _loc1_.updateArcs();
   }
   else
   {
      _loc1_._cd = null;
      _loc1_._sd = null;
      _loc1_._rot = null;
   }
};
p.updateArcs = function()
{
   var cos = Math.cos;
   var sin = Math.sin;
   var r = this._parent._c.r * this._cd;
   var fmc = this._fimc;
   var bmc = this._bimc;
   fmc.clear();
   bmc.clear();
   var n = 50;
   var angleStep = (- this._parent._decTrailAngle) / n;
   var alphaStep = -100 / n;
   var angle = 4.71238898038469;
   var alpha = 100;
   fmc.lineStyle(1,0,alpha);
   bmc.lineStyle(1,0,alpha);
   var _loc3_ = r * cos(angle);
   var _loc2_ = r * sin(angle);
   fmc.moveTo(_loc3_,_loc2_);
   bmc.moveTo(_loc3_,_loc2_);
   var _loc1_ = 0;
   while(_loc1_ < n)
   {
      angle += angleStep;
      alpha += alphaStep;
      fmc.lineStyle(1,0,alpha);
      bmc.lineStyle(1,0,alpha);
      _loc3_ = r * cos(angle);
      _loc2_ = r * sin(angle);
      fmc.lineTo(_loc3_,_loc2_);
      bmc.lineTo(_loc3_,_loc2_);
      _loc1_ = _loc1_ + 1;
   }
};
p.updateMasks = function()
{
   var _loc1_ = 1.3 * this._parent._c.r;
   var h = -2.3 * this._parent._c.r;
   this._yOffset = (- h) / 2;
   var _loc3_ = this._fmmc;
   _loc3_.clear();
   _loc3_.beginFill(16711680,100);
   _loc3_.moveTo(_loc1_,0);
   _loc3_.lineTo(_loc1_,h);
   _loc3_.lineTo(- _loc1_,h);
   _loc3_.lineTo(- _loc1_,0);
   _loc3_.lineTo(_loc1_,0);
   _loc3_.endFill();
   var _loc2_ = this._bmmc;
   _loc2_.clear();
   _loc2_.beginFill(255,100);
   _loc2_.moveTo(_loc1_,0);
   _loc2_.lineTo(_loc1_,h);
   _loc2_.lineTo(- _loc1_,h);
   _loc2_.lineTo(- _loc1_,0);
   _loc2_.lineTo(_loc1_,0);
   _loc2_.endFill();
};
