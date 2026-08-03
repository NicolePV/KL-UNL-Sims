function GlobeComponentClass()
{
   var _loc1_ = this;
   _loc1_.createEmptyMovieClip("backAxis",0);
   _loc1_.createEmptyMovieClip("globe",10);
   _loc1_.createEmptyMovieClip("nightSide",15);
   _loc1_.createEmptyMovieClip("frontAxis",20);
   _loc1_.globe.attachMovie("GlobeComponentWater","water",10);
   _loc1_.globe.attachMovie("GlobeComponentLand","land",20);
   _loc1_.globe.createEmptyMovieClip("shores",30);
   _loc1_.globe.land.setMask(_loc1_.globe.shores);
   _loc1_.globe.useHandCursor = false;
   _loc1_.setAxisStyle(2,15683664,100);
   _loc1_._c = {};
   _loc1_.setRotationAngle(0);
   _loc1_.setPrecessionAngle(0);
}
var p = GlobeComponentClass.prototype = new MovieClip();
Object.registerClass("GlobeComponent",GlobeComponentClass);
p._radius = 40;
p.axisExtent = 1.5;
p.setSunDirection = function(arg)
{
   var _loc1_ = this;
   _loc1_._sunDir = {};
   _loc1_._parent._parent.parsePointInput(arg,_loc1_._sunDir);
};
p.updateShading = function()
{
   var mc = this.nightSide;
   mc.clear();
   var sd = this._sunDir;
   var sp = {};
   if(sd.sys == 0 || sd.sys == -1)
   {
      this._parent._parent.WtoSz(sd,sp);
   }
   else if(sd.sys == 1)
   {
      this._parent._parent.CtoSz(sd,sp);
   }
   else
   {
      return;
   }
   mc._rotation = 57.29577951308232 * Math.atan2(sp.x,- sp.y);
   var s = (- sp.z) / Math.sqrt(sp.x * sp.x + sp.y * sp.y + sp.z * sp.z);
   var hnp = 4;
   var _loc3_ = 3.141592653589793 / hnp;
   var halfStep = _loc3_ / 2;
   var cos = Math.cos;
   var sin = Math.sin;
   var r = this._radius;
   var cr = r / cos(halfStep);
   mc.moveTo(r,0);
   mc.lineStyle(1,16711680,0);
   mc.beginFill(0,60);
   var _loc2_ = _loc3_;
   var _loc1_ = _loc3_ - halfStep;
   var i = 0;
   while(i < hnp)
   {
      var ax = r * cos(_loc2_);
      var ay = r * sin(_loc2_);
      var cx = cr * cos(_loc1_);
      var cy = cr * sin(_loc1_);
      mc.curveTo(cx,cy,ax,ay);
      _loc2_ += _loc3_;
      _loc1_ += _loc3_;
      i++;
   }
   var i = 0;
   while(i < hnp)
   {
      var ax = r * cos(_loc2_);
      var ay = s * r * sin(_loc2_);
      var cx = cr * cos(_loc1_);
      var cy = s * cr * sin(_loc1_);
      mc.curveTo(cx,cy,ax,ay);
      _loc2_ += _loc3_;
      _loc1_ += _loc3_;
      i++;
   }
   mc.endFill();
};
p.setAxisStyle = function(thickness, color, alpha)
{
   var _loc1_ = this;
   _loc1_.axisThickness = thickness;
   _loc1_.axisColor = color;
   _loc1_.axisAlpha = alpha;
   _loc1_._parent._parent.PrecessingGlobeSouthPoleAxis.setStyle(_loc1_.axisThickness,_loc1_.axisColor,_loc1_.axisAlpha);
   _loc1_._parent._parent.PrecessingGlobeNorthPoleAxis.setStyle(_loc1_.axisThickness,_loc1_.axisColor,_loc1_.axisAlpha);
};
p.updateAxes = function()
{
   var _loc1_ = this;
};
p.update = function()
{
   var start = getTimer();
   if(this._parent._parent._sTime != this._lastSTime)
   {
      this.setRotationAngle(this.rotationAngle);
   }
   this._lastSTime = this._parent._parent._sTime;
   var tc = this._c;
   var pc = this._parent._parent._c;
   var sf = this._radius / pc.r;
   var k0 = sf * (pc.b0 * tc.q0 + pc.b1 * tc.q3 + pc.b2 * tc.q6);
   var k1 = sf * (pc.b0 * tc.q1 + pc.b1 * tc.q4 + pc.b2 * tc.q7);
   var k2 = sf * (pc.b0 * tc.q2 + pc.b1 * tc.q5 + pc.b2 * tc.q8);
   var k3 = sf * (pc.b3 * tc.q0 + pc.b4 * tc.q3 + pc.b5 * tc.q6);
   var k4 = sf * (pc.b3 * tc.q1 + pc.b4 * tc.q4 + pc.b5 * tc.q7);
   var k5 = sf * (pc.b3 * tc.q2 + pc.b4 * tc.q5 + pc.b5 * tc.q8);
   var k6 = sf * (pc.b6 * tc.q0 + pc.b7 * tc.q3 + pc.b8 * tc.q6);
   var k7 = sf * (pc.b6 * tc.q1 + pc.b7 * tc.q4 + pc.b8 * tc.q7);
   var k8 = sf * (pc.b6 * tc.q2 + pc.b7 * tc.q5 + pc.b8 * tc.q8);
   var mc = this.globe.shores;
   mc.clear();
   mc.lineStyle(0,0);
   var cos = Math.cos;
   var sin = Math.sin;
   var atan2 = Math.atan2;
   var ceil = Math.ceil;
   var s = this._shoreData;
   var r = this._radius;
   var d = 1.5 * r;
   var minStep = 2 * Math.acos(r * 1.1 / d);
   var i = 0;
   var _loc1_;
   var _loc2_;
   var _loc3_;
   while(i < s.length)
   {
      var p = s[i];
      var pl = p.length;
      var lastInFront = false;
      var sj = 0;
      while(sj < pl)
      {
         _loc1_ = p[sj];
         if(_loc1_.x * k6 + _loc1_.y * k7 + _loc1_.z * k8 > 0)
         {
            if(lastInFront)
            {
               mc.moveTo(_loc1_.x * k0 + _loc1_.y * k1 + _loc1_.z * k2,_loc1_.x * k3 + _loc1_.y * k4 + _loc1_.z * k5);
               break;
            }
            lastInFront = true;
         }
         else
         {
            lastInFront = false;
         }
         sj++;
      }
      if(sj != pl)
      {
         var ibLast = false;
         mc.beginFill(0);
         var j = 1;
         while(j < pl)
         {
            _loc1_ = p[(sj + j) % pl];
            var ibNow = _loc1_.x * k6 + _loc1_.y * k7 + _loc1_.z * k8 < 0;
            if(!ibNow)
            {
               if(ibLast)
               {
                  var sx = _loc1_.x * k0 + _loc1_.y * k1 + _loc1_.z * k2;
                  var sy = _loc1_.x * k3 + _loc1_.y * k4 + _loc1_.z * k5;
                  var angleNow = atan2(sy,sx);
                  _loc2_ = ((angleNow - angleLast) % 6.283185307179586 + 6.283185307179586) % 6.283185307179586;
                  if(_loc2_ > 3.141592653589793)
                  {
                     _loc2_ = 6.283185307179586 - _loc2_;
                     var n = ceil(_loc2_ / minStep);
                     var step = (- _loc2_) / n;
                  }
                  else
                  {
                     var n = ceil(_loc2_ / minStep);
                     var step = _loc2_ / n;
                  }
                  _loc3_ = 1;
                  while(_loc3_ <= n)
                  {
                     var angle = angleLast + step * _loc3_;
                     mc.lineTo(d * cos(angle),d * sin(angle));
                     _loc3_ = _loc3_ + 1;
                  }
                  mc.lineTo(sx,sy);
               }
               else
               {
                  mc.lineTo(_loc1_.x * k0 + _loc1_.y * k1 + _loc1_.z * k2,_loc1_.x * k3 + _loc1_.y * k4 + _loc1_.z * k5);
               }
            }
            else if(!ibLast)
            {
               var x = _loc1_.x * k0 + _loc1_.y * k1 + _loc1_.z * k2;
               var y = _loc1_.x * k3 + _loc1_.y * k4 + _loc1_.z * k5;
               var angleLast = atan2(y,x);
               mc.lineTo(d * cos(angleLast),d * sin(angleLast));
            }
            ibLast = ibNow;
            j++;
         }
         mc.endFill();
      }
      i++;
   }
   if(this._traceOn)
   {
      trace("globe time: " + (getTimer() - start));
   }
};
p.setPrecessionAngle = function(arg)
{
   var _loc2_ = arg;
   this.precessionAngle = _loc2_;
   _loc2_ *= 0.017453292519943295;
   var cp = Math.cos(_loc2_);
   var _loc3_ = Math.sin(_loc2_);
   var _loc1_ = this._c;
   _loc1_.p0 = cp;
   _loc1_.p1 = - _loc3_;
   _loc1_.p3 = _loc3_ * 0.91706;
   _loc1_.p4 = cp * 0.91706;
   _loc1_.p5 = -0.39875;
   _loc1_.p6 = _loc3_ * 0.39875;
   _loc1_.p7 = cp * 0.39875;
   _loc1_.p8 = 0.91706;
   _loc1_.q0 = _loc1_.p0 * _loc1_.r0 + _loc1_.p1 * _loc1_.r3;
   _loc1_.q1 = _loc1_.p0 * _loc1_.r1 + _loc1_.p1 * _loc1_.r4;
   _loc1_.q2 = _loc1_.p1 * _loc1_.r5;
   _loc1_.q3 = _loc1_.p3 * _loc1_.r0 + _loc1_.p4 * _loc1_.r3 + _loc1_.p5 * _loc1_.r6;
   _loc1_.q4 = _loc1_.p3 * _loc1_.r1 + _loc1_.p4 * _loc1_.r4 + _loc1_.p5 * _loc1_.r7;
   _loc1_.q5 = _loc1_.p4 * _loc1_.r5 + _loc1_.p5 * _loc1_.r8;
   _loc1_.q6 = _loc1_.p6 * _loc1_.r0 + _loc1_.p7 * _loc1_.r3 + _loc1_.p8 * _loc1_.r6;
   _loc1_.q7 = _loc1_.p6 * _loc1_.r1 + _loc1_.p7 * _loc1_.r4 + _loc1_.p8 * _loc1_.r7;
   _loc1_.q8 = _loc1_.p7 * _loc1_.r5 + _loc1_.p8 * _loc1_.r8;
};
p.setRotationAngle = function(arg)
{
   this.rotationAngle = arg;
   arg = this._parent._parent._sTime + arg * 0.017453292519943295;
   var _loc3_ = Math.cos(arg);
   var _loc2_ = Math.sin(arg);
   var _loc1_ = this._c;
   _loc1_.r0 = _loc3_;
   _loc1_.r1 = - _loc2_;
   _loc1_.r3 = _loc2_ * 0.91706;
   _loc1_.r4 = _loc3_ * 0.91706;
   _loc1_.r5 = 0.39875;
   _loc1_.r6 = (- _loc2_) * 0.39875;
   _loc1_.r7 = (- _loc3_) * 0.39875;
   _loc1_.r8 = 0.91706;
   _loc1_.q0 = _loc1_.p0 * _loc1_.r0 + _loc1_.p1 * _loc1_.r3;
   _loc1_.q1 = _loc1_.p0 * _loc1_.r1 + _loc1_.p1 * _loc1_.r4;
   _loc1_.q2 = _loc1_.p1 * _loc1_.r5;
   _loc1_.q3 = _loc1_.p3 * _loc1_.r0 + _loc1_.p4 * _loc1_.r3 + _loc1_.p5 * _loc1_.r6;
   _loc1_.q4 = _loc1_.p3 * _loc1_.r1 + _loc1_.p4 * _loc1_.r4 + _loc1_.p5 * _loc1_.r7;
   _loc1_.q5 = _loc1_.p4 * _loc1_.r5 + _loc1_.p5 * _loc1_.r8;
   _loc1_.q6 = _loc1_.p6 * _loc1_.r0 + _loc1_.p7 * _loc1_.r3 + _loc1_.p8 * _loc1_.r6;
   _loc1_.q7 = _loc1_.p6 * _loc1_.r1 + _loc1_.p7 * _loc1_.r4 + _loc1_.p8 * _loc1_.r7;
   _loc1_.q8 = _loc1_.p7 * _loc1_.r5 + _loc1_.p8 * _loc1_.r8;
};
p.setScale = function(arg)
{
   var _loc1_ = this;
   _loc1_.nightSide._yscale = _loc1_.nightSide._xscale = _loc1_.globe._yscale = _loc1_.globe._xscale = arg;
};
