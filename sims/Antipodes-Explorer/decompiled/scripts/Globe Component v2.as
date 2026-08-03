function GlobeComponentV2Class()
{
   var _loc1_ = this;
   _loc1_.createEmptyMovieClip("backAxisMC",0);
   _loc1_.createEmptyMovieClip("mouseAreaMC",5);
   _loc1_.createEmptyMovieClip("globeMC",10);
   _loc1_.createEmptyMovieClip("shadingMC",15);
   _loc1_.createEmptyMovieClip("frontAxisMC",20);
   _loc1_.globeMC.createEmptyMovieClip("maskMC",30);
   if(_loc1_.isStandalone == undefined)
   {
      _loc1_.isStandalone = !(_loc1_._sphere != undefined && _loc1_._sphere == _loc1_._parent._parent && _loc1_._object != undefined);
   }
   if(_loc1_.isStandalone)
   {
      if(_loc1_.initSunPosition == undefined)
      {
         _loc1_.initSunPosition = {theta:0,phi:0};
      }
      if(_loc1_.initSize == undefined)
      {
         _loc1_.initSize = _loc1_._width;
      }
   }
   else
   {
      if(_loc1_.initSunPosition == undefined)
      {
         _loc1_.initSunPosition = {ra:0,dec:0};
      }
      if(_loc1_.initSize == undefined)
      {
         _loc1_.initSize = 0.2;
      }
      _loc1_._sphere.watch("_bVer",_loc1_.sphereConstantsWatcher,_loc1_);
      _loc1_._sphere.showHorizonPlane = false;
      _loc1_._sphere.addLine("__PrecessingGlobeV2SouthPoleAxis",{thickness:2,color:255,alpha:100},{az:0,alt:0,r:0},{az:0,alt:0,r:1.5});
      _loc1_._sphere.addLine("__PrecessingGlobeV2NorthPoleAxis",{thickness:2,color:16711680,alpha:100},{az:0,alt:0,r:0},{az:0,alt:0,r:1.5});
   }
   _loc1_.placeholderMC._visible = false;
   _loc1_._xscale = 100;
   _loc1_._yscale = 100;
   _loc1_.mouseAreaMC.useHandCursor = false;
   _loc1_.mouseAreaMC.tabEnabled = false;
   _loc1_.mouseAreaMC.clear();
   _loc1_.mouseAreaMC.beginFill(16711680,0);
   _loc1_.drawCircle(_loc1_.mouseAreaMC,0,0,50);
   _loc1_.mouseAreaMC.endFill();
   _loc1_._c = {};
   if(_loc1_.initRotation == undefined)
   {
      _loc1_.initRotation = 0;
   }
   if(_loc1_.initPrecession == undefined)
   {
      _loc1_.initPrecession = 0;
   }
   if(_loc1_.initViewerTheta == undefined)
   {
      _loc1_.initViewerTheta = 0;
   }
   if(_loc1_.initViewerPhi == undefined)
   {
      _loc1_.initViewerPhi = 30;
   }
   if(_loc1_.initIsDraggable == undefined)
   {
      _loc1_.initIsDraggable = true;
   }
   if(_loc1_.initShowAxis == undefined)
   {
      _loc1_.initShowAxis = true;
   }
   if(_loc1_.initAxisLength == undefined)
   {
      _loc1_.initAxisLength = 1.4;
   }
   if(_loc1_.initAxisThickness == undefined)
   {
      _loc1_.initAxisThickness = 1;
   }
   if(_loc1_.initAxisColor == undefined)
   {
      _loc1_.initAxisColor = 0;
   }
   if(_loc1_.initAxisAlpha == undefined)
   {
      _loc1_.initAxisAlpha = 100;
   }
   if(_loc1_.initShowShading == undefined)
   {
      _loc1_.initShowShading = false;
   }
   if(_loc1_.initSunTheta != undefined)
   {
      _loc1_.initSunPosition.theta = _loc1_.initSunTheta;
   }
   if(_loc1_.initSunPhi != undefined)
   {
      _loc1_.initSunPosition.phi = _loc1_.initSunPhi;
   }
   if(_loc1_.initShadingColor == undefined)
   {
      _loc1_.initShadingColor = 0;
   }
   if(_loc1_.initShadingAlpha == undefined)
   {
      _loc1_.initShadingAlpha = 40;
   }
   if(_loc1_.initWaterLinkageName == undefined)
   {
      _loc1_.initWaterLinkageName = "Globe Component v2 Water";
   }
   if(_loc1_.initLandLinkageName == undefined)
   {
      _loc1_.initLandLinkageName = "Globe Component v2 Land";
   }
   _loc1_.updateAxis = function()
   {
   };
   _loc1_.updateGlobe = function()
   {
   };
   _loc1_.updateShading = function()
   {
   };
   _loc1_.setLandLinkageName(_loc1_.initLandLinkageName);
   _loc1_.setWaterLinkageName(_loc1_.initWaterLinkageName);
   _loc1_.setAxisStyle(_loc1_.initAxisThickness,_loc1_.initAxisColor,_loc1_.initAxisAlpha);
   _loc1_.setShadingStyle(_loc1_.initShadingColor,_loc1_.initShadingAlpha);
   _loc1_.setSunPosition(_loc1_.initSunPosition);
   _loc1_.setViewerDirection({theta:_loc1_.initViewerTheta,phi:_loc1_.initViewerPhi});
   _loc1_.size = _loc1_.initSize;
   _loc1_.rotation = _loc1_.initRotation;
   _loc1_.precession = _loc1_.initPrecession;
   _loc1_.axisLength = _loc1_.initAxisLength;
   _loc1_.showAxis = _loc1_.initShowAxis;
   _loc1_.showShading = _loc1_.initShowShading;
   _loc1_.isDraggable = _loc1_.initIsDraggable;
   delete _loc1_.updateAxis;
   delete _loc1_.updateGlobe;
   delete _loc1_.updateShading;
   _loc1_.updateAxis();
   _loc1_.updateGlobe();
   _loc1_.updateShading();
}
var p = GlobeComponentV2Class.prototype = new MovieClip();
Object.registerClass("Globe Component v2",GlobeComponentV2Class);
p.updateShading = function()
{
   var _loc3_;
   var _loc2_;
   var _loc1_;
   if(this._showShading)
   {
      var mc = this.shadingMC;
      mc.clear();
      var sd = this._sunPos;
      var sp = {};
      if(this.isStandalone)
      {
         var pc = this._pc;
         sp.x = sd.x * pc.b0 + sd.y * pc.b1 + sd.z * pc.b2;
         sp.y = sd.x * pc.b3 + sd.y * pc.b4 + sd.z * pc.b5;
         sp.z = sd.x * pc.b6 + sd.y * pc.b7 + sd.z * pc.b8;
      }
      else if(sd.sys == 0 || sd.sys == -1)
      {
         this._sphere.WtoSz(sd,sp);
      }
      else if(sd.sys == 1)
      {
         this._sphere.CtoSz(sd,sp);
      }
      else
      {
         return;
      }
      mc._rotation = 57.29577951308232 * Math.atan2(sp.x,- sp.y);
      var s = (- sp.z) / Math.sqrt(sp.x * sp.x + sp.y * sp.y + sp.z * sp.z);
      var hnp = 4;
      _loc3_ = 3.141592653589793 / hnp;
      var halfStep = _loc3_ / 2;
      var cos = Math.cos;
      var sin = Math.sin;
      var r = 50;
      var cr = r / cos(halfStep);
      mc.moveTo(r,0);
      mc.beginFill(this.shadingColor,this.shadingAlpha);
      _loc2_ = _loc3_;
      _loc1_ = _loc3_ - halfStep;
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
   }
};
p.updateAxis = function()
{
   var _loc1_ = this;
   var _loc2_;
   var _loc3_;
   if(_loc1_._showAxis)
   {
      var tc = _loc1_._c;
      if(_loc1_.isStandalone)
      {
         _loc2_ = _loc1_._pc;
         var aLen = _loc1_._axisLength;
         if(aLen < 1)
         {
            aLen = 1;
         }
         _loc3_ = 1;
         var s3 = aLen;
      }
      else
      {
         var aLen = _loc1_._axisLength;
         if(aLen < _loc1_._size)
         {
            aLen = _loc1_._size;
         }
         _loc2_ = _loc1_._sphere._c;
         _loc3_ = _loc1_._size;
         var s2 = aLen / _loc3_;
         if(aLen < 1)
         {
            var s3 = aLen / _loc3_;
         }
         else
         {
            var s3 = 1 / _loc3_;
         }
      }
      var k2 = _loc3_ * (_loc2_.b0 * tc.q2 + _loc2_.b1 * tc.q5 + _loc2_.b2 * tc.q8);
      var k5 = _loc3_ * (_loc2_.b3 * tc.q2 + _loc2_.b4 * tc.q5 + _loc2_.b5 * tc.q8);
      var k8 = _loc3_ * (_loc2_.b6 * tc.q2 + _loc2_.b7 * tc.q5 + _loc2_.b8 * tc.q8);
      if(k8 > 0)
      {
         var mc = _loc1_.frontAxisMC;
         mc.clear();
         mc.lineStyle(_loc1_.axisThickness,_loc1_.axisColor,_loc1_.axisAlpha);
         mc.moveTo(k2,k5);
         mc.lineTo(s3 * k2,s3 * k5);
         var mc = _loc1_.backAxisMC;
         mc.clear();
         mc.lineStyle(_loc1_.axisThickness,_loc1_.axisColor,_loc1_.axisAlpha);
         mc.moveTo(- k2,- k5);
         mc.lineTo((- s3) * k2,(- s3) * k5);
      }
      else
      {
         var mc = _loc1_.backAxisMC;
         mc.clear();
         mc.lineStyle(_loc1_.axisThickness,_loc1_.axisColor,_loc1_.axisAlpha);
         mc.moveTo(k2,k5);
         mc.lineTo(s3 * k2,s3 * k5);
         var mc = _loc1_.frontAxisMC;
         mc.clear();
         mc.lineStyle(_loc1_.axisThickness,_loc1_.axisColor,_loc1_.axisAlpha);
         mc.moveTo(- k2,- k5);
         mc.lineTo((- s3) * k2,(- s3) * k5);
      }
      if(!_loc1_.isStandalone)
      {
         var x = (_loc2_.a0 * k2 + _loc2_.a3 * k5 + _loc2_.a6 * k8) / _loc2_.r2;
         var y = (_loc2_.a1 * k2 + _loc2_.a4 * k5 + _loc2_.a7 * k8) / _loc2_.r2;
         var z = (_loc2_.a5 * k5 + _loc2_.a8 * k8) / _loc2_.r2;
         if(aLen < 1)
         {
            _loc1_._sphere.__PrecessingGlobeV2NorthPoleAxis.visible = false;
            _loc1_._sphere.__PrecessingGlobeV2SouthPoleAxis.visible = false;
         }
         else
         {
            _loc1_._sphere.__PrecessingGlobeV2NorthPoleAxis.setPoints({x:x / _loc3_,y:y / _loc3_,z:z / _loc3_,system:"horizon"},{x:x * s2,y:y * s2,z:z * s2,system:"horizon"});
            _loc1_._sphere.__PrecessingGlobeV2SouthPoleAxis.setPoints({x:(- x) / _loc3_,y:(- y) / _loc3_,z:(- z) / _loc3_,system:"horizon"},{x:(- x) * s2,y:(- y) * s2,z:(- z) * s2,system:"horizon"});
            _loc1_._sphere.__PrecessingGlobeV2NorthPoleAxis.visible = true;
            _loc1_._sphere.__PrecessingGlobeV2SouthPoleAxis.visible = true;
         }
      }
   }
};
p.updateGlobe = function()
{
   var tc = this._c;
   if(this.isStandalone)
   {
      var pc = this._pc;
   }
   else
   {
      var pc = this._sphere._c;
   }
   var sf = 50 / pc.r;
   var k0 = sf * (pc.b0 * tc.q0 + pc.b1 * tc.q3 + pc.b2 * tc.q6);
   var k1 = sf * (pc.b0 * tc.q1 + pc.b1 * tc.q4 + pc.b2 * tc.q7);
   var k2 = sf * (pc.b0 * tc.q2 + pc.b1 * tc.q5 + pc.b2 * tc.q8);
   var k3 = sf * (pc.b3 * tc.q0 + pc.b4 * tc.q3 + pc.b5 * tc.q6);
   var k4 = sf * (pc.b3 * tc.q1 + pc.b4 * tc.q4 + pc.b5 * tc.q7);
   var k5 = sf * (pc.b3 * tc.q2 + pc.b4 * tc.q5 + pc.b5 * tc.q8);
   var k6 = sf * (pc.b6 * tc.q0 + pc.b7 * tc.q3 + pc.b8 * tc.q6);
   var k7 = sf * (pc.b6 * tc.q1 + pc.b7 * tc.q4 + pc.b8 * tc.q7);
   var k8 = sf * (pc.b6 * tc.q2 + pc.b7 * tc.q5 + pc.b8 * tc.q8);
   var mc = this.globeMC.maskMC;
   mc.clear();
   var cos = Math.cos;
   var sin = Math.sin;
   var atan2 = Math.atan2;
   var ceil = Math.ceil;
   var s = this._shoreData;
   var r = 50;
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
};
p.update = function()
{
   var _loc1_ = this;
   _loc1_.updateShading();
   _loc1_.updateAxis();
   _loc1_.updateGlobe();
};
p.getIsDraggable = function()
{
   return this.mouseAreaMC.onPress == this.onPressFunc;
};
p.setIsDraggable = function(arg)
{
   var _loc1_ = this;
   if(_loc1_.isStandalone && arg)
   {
      _loc1_.mouseAreaMC.onPress = _loc1_.onPressFunc;
      _loc1_.mouseAreaMC.onRelease = _loc1_.onReleaseFunc;
      _loc1_.mouseAreaMC.onReleaseOutside = _loc1_.onReleaseOutsideFunc;
      _loc1_.mouseAreaMC.onMouseMoveFunc = _loc1_.onMouseMoveFunc;
   }
   else
   {
      delete _loc1_.mouseAreaMC.onPress;
      delete _loc1_.mouseAreaMC.onRelease;
      delete _loc1_.mouseAreaMC.onReleaseOutside;
      delete _loc1_.mouseAreaMC.onMouseMove;
   }
};
p.addProperty("isDraggable",p.getIsDraggable,p.setIsDraggable);
p.onPressFunc = function()
{
   var _loc1_ = this;
   _loc1_.initX = _loc1_._xmouse;
   _loc1_.initY = _loc1_._ymouse;
   _loc1_.initTheta = _loc1_._parent._viewerTheta;
   _loc1_.initPhi = _loc1_._parent._viewerPhi;
   _loc1_.onMouseMove = _loc1_.onMouseMoveFunc;
};
p.onMouseMoveFunc = function()
{
   var _loc1_ = this;
   var theta = 57.29577951308232 * (_loc1_.initTheta - (_loc1_._xmouse - _loc1_.initX) / 50) - 180;
   var phi = 57.29577951308232 * (_loc1_.initPhi + (_loc1_._ymouse - _loc1_.initY) / 50);
   _loc1_._parent.setViewerDirection({theta:theta,phi:phi},true);
   updateAfterEvent();
};
p.onReleaseFunc = function()
{
   delete this.onMouseMove;
};
p.onReleaseOutsideFunc = function()
{
   delete this.onMouseMove;
};
p.setWaterLinkageName = function(arg)
{
   this.globeMC.waterMC.removeMovieClip();
   this.globeMC.attachMovie(arg,"waterMC",10);
};
p.setLandLinkageName = function(arg)
{
   var _loc1_ = this;
   _loc1_.globeMC.landMC.removeMovieClip();
   _loc1_.globeMC.attachMovie(arg,"landMC",20);
   _loc1_.globeMC.landMC.setMask(_loc1_.globeMC.maskMC);
};
p.getViewerDirection = function()
{
   var _loc1_ = {};
   _loc1_.theta = ((this._viewerTheta * 180 / 3.141592653589793 - 180) % 360 + 360) % 360;
   _loc1_.phi = this._viewerPhi * 180 / 3.141592653589793;
   return _loc1_;
};
p.setViewerDirection = function(arg, callChangeHandler)
{
   var _loc1_ = this;
   if(_loc1_.isStandalone)
   {
      _loc1_._viewerTheta = (arg.theta + 180) * 3.141592653589793 / 180;
      _loc1_._viewerPhi = arg.phi * 3.141592653589793 / 180;
      if(_loc1_._viewerPhi > 1.5707963267948966)
      {
         _loc1_._viewerPhi = 1.5707963267948966;
      }
      else if(_loc1_._viewerPhi < -1.5707963267948966)
      {
         _loc1_._viewerPhi = -1.5707963267948966;
      }
      _loc1_.calculateBConstants();
      _loc1_.update();
      if(callChangeHandler)
      {
         _loc1_._parent[_loc1_.viewerDirectionChangeHandler]();
      }
   }
};
p.setSunPosition = function(arg)
{
   var _loc1_ = this;
   var _loc2_ = arg;
   _loc1_._sunPos = {};
   if(_loc1_.isStandalone)
   {
      _loc1_._sunTheta = _loc2_.theta * 3.141592653589793 / 180;
      _loc1_._sunPhi = _loc2_.phi * 3.141592653589793 / 180;
      _loc1_._sunPos.x = Math.cos(_loc1_._sunPhi) * Math.cos(_loc1_._sunTheta);
      _loc1_._sunPos.y = Math.cos(_loc1_._sunPhi) * Math.sin(_loc1_._sunTheta);
      _loc1_._sunPos.z = Math.sin(_loc1_._sunPhi);
   }
   else
   {
      _loc1_._sphere.parsePointInput(_loc2_,_loc1_._sunPos);
   }
   _loc1_.updateShading();
};
p.getShowShading = function()
{
   return this._showShading;
};
p.setShowShading = function(arg)
{
   var _loc1_ = this;
   _loc1_._showShading = Boolean(arg);
   _loc1_.shadingMC._visible = _loc1_._showShading;
   _loc1_.updateShading();
};
p.addProperty("showShading",p.getShowShading,p.setShowShading);
p.setShadingStyle = function(color, alpha)
{
   var _loc1_ = this;
   _loc1_.shadingColor = color;
   _loc1_.shadingAlpha = alpha;
   _loc1_.updateShading();
};
p.getShowAxis = function()
{
   return this._showAxis;
};
p.setShowAxis = function(arg)
{
   var _loc1_ = this;
   _loc1_._showAxis = Boolean(arg);
   _loc1_.frontAxisMC._visible = _loc1_._showAxis;
   _loc1_.backAxisMC._visible = _loc1_._showAxis;
   if(!_loc1_._showAxis && !_loc1_.isStandalone)
   {
      _loc1_._sphere.__PrecessingGlobeV2SouthPoleAxis.visible = false;
      _loc1_._sphere.__PrecessingGlobeV2NorthPoleAxis.visible = false;
   }
   _loc1_.updateAxis();
};
p.addProperty("showAxis",p.getShowAxis,p.setShowAxis);
p.setAxisStyle = function(thickness, color, alpha)
{
   var _loc1_ = this;
   _loc1_.axisThickness = thickness;
   _loc1_.axisColor = color;
   _loc1_.axisAlpha = alpha;
   if(!_loc1_.isStandalone)
   {
      _loc1_._sphere.__PrecessingGlobeV2SouthPoleAxis.setStyle(_loc1_.axisThickness,_loc1_.axisColor,_loc1_.axisAlpha);
      _loc1_._sphere.__PrecessingGlobeV2NorthPoleAxis.setStyle(_loc1_.axisThickness,_loc1_.axisColor,_loc1_.axisAlpha);
   }
   _loc1_.updateAxis();
};
p.getAxisLength = function()
{
   return this._axisLength;
};
p.setAxisLength = function(arg)
{
   this._axisLength = arg;
   this.updateAxis();
};
p.addProperty("axisLength",p.getAxisLength,p.setAxisLength);
p.getPrecession = function()
{
   return this._precession * 57.29577951308232;
};
p.setPrecession = function(arg)
{
   var _loc2_ = this;
   _loc2_._precession = (arg % 360 + 360) % 360 * 0.017453292519943295;
   var cp = Math.cos(_loc2_._precession);
   var _loc3_ = Math.sin(_loc2_._precession);
   var _loc1_ = _loc2_._c;
   _loc1_.p0 = cp;
   _loc1_.p1 = - _loc3_;
   _loc1_.p3 = _loc3_ * 0.91706;
   _loc1_.p4 = cp * 0.91706;
   _loc1_.p5 = -0.39875;
   _loc1_.p6 = _loc3_ * 0.39875;
   _loc1_.p7 = cp * 0.39875;
   _loc1_.p8 = 0.91706;
   _loc2_.calculateQConstants();
   _loc2_.updateGlobe();
   _loc2_.updateAxis();
};
p.addProperty("precession",p.getPrecession,p.setPrecession);
p.getRotation = function()
{
   return this._rotationAngle * 57.29577951308232;
};
p.setRotation = function(arg)
{
   var _loc1_ = this;
   _loc1_._rotationAngle = (arg % 360 + 360) % 360 * 0.017453292519943295;
   _loc1_.calculateRConstants();
   _loc1_.calculateQConstants();
   _loc1_.updateGlobe();
};
p.addProperty("rotation",p.getRotation,p.setRotation);
p.getSize = function()
{
   return this._size;
};
p.setSize = function(arg)
{
   var _loc1_ = this;
   _loc1_._size = arg;
   if(_loc1_.isStandalone)
   {
      _loc1_.mouseAreaMC._xscale = _loc1_.mouseAreaMC._yscale = _loc1_.globeMC._xscale = _loc1_.globeMC._yscale = _loc1_.shadingMC._xscale = _loc1_.shadingMC._yscale = _loc1_._size;
      _loc1_.calculateBConstants();
   }
   else
   {
      if(_loc1_._size > 1)
      {
         _loc1_._size = 1;
      }
      _loc1_.refreshScaling();
   }
   _loc1_.updateAxis();
};
p.addProperty("size",p.getSize,p.setSize);
p.refreshScaling = function()
{
   var _loc1_ = this;
   _loc1_.mouseAreaMC._xscale = _loc1_.mouseAreaMC._yscale = _loc1_.globeMC._xscale = _loc1_.globeMC._yscale = _loc1_.shadingMC._xscale = _loc1_.shadingMC._yscale = 2 * _loc1_._sphere._c.r * _loc1_._size;
};
p.calculateBConstants = function()
{
   var _loc3_ = this;
   var _loc2_ = _loc3_._size / 2;
   var ct = Math.cos(_loc3_._viewerTheta);
   var st = Math.sin(_loc3_._viewerTheta);
   var cp = Math.cos(_loc3_._viewerPhi);
   var sp = Math.sin(_loc3_._viewerPhi);
   var _loc1_ = {};
   _loc1_.r = _loc2_;
   _loc1_.r2 = _loc2_ * _loc2_;
   _loc1_.b0 = _loc2_ * st;
   _loc1_.b1 = (- _loc2_) * ct;
   _loc1_.b2 = 0;
   _loc1_.b3 = (- _loc2_) * ct * sp;
   _loc1_.b4 = (- _loc2_) * st * sp;
   _loc1_.b5 = (- _loc2_) * cp;
   _loc1_.b6 = (- _loc2_) * ct * cp;
   _loc1_.b7 = (- _loc2_) * st * cp;
   _loc1_.b8 = _loc2_ * sp;
   _loc3_._pc = _loc1_;
};
p.calculateRConstants = function()
{
   var _loc2_ = this;
   if(_loc2_.isStandalone)
   {
      var angle = _loc2_._rotationAngle;
   }
   else
   {
      var angle = _loc2_._sphere._sTime + _loc2_._rotationAngle;
   }
   var cr = Math.cos(angle);
   var _loc3_ = Math.sin(angle);
   var _loc1_ = _loc2_._c;
   _loc1_.r0 = cr;
   _loc1_.r1 = - _loc3_;
   _loc1_.r3 = _loc3_ * 0.91706;
   _loc1_.r4 = cr * 0.91706;
   _loc1_.r5 = 0.39875;
   _loc1_.r6 = (- _loc3_) * 0.39875;
   _loc1_.r7 = (- cr) * 0.39875;
   _loc1_.r8 = 0.91706;
};
p.calculateQConstants = function()
{
   var _loc1_ = this._c;
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
p.sphereConstantsWatcher = function(id, oldVal, newVal, globeInstance)
{
   var _loc1_ = globeInstance;
   _loc1_.refreshScaling();
   _loc1_.calculateRConstants();
   _loc1_.calculateQConstants();
   _loc1_.update();
   return newVal;
};
p.drawCircle = function(mc, x, y, r)
{
   var _loc1_ = r;
   var _loc2_ = y;
   var _loc3_ = x;
   mc.moveTo(_loc3_ + _loc1_,_loc2_);
   mc.curveTo(_loc3_ + _loc1_,_loc2_ - 0.4142 * _loc1_,_loc3_ + 0.7071 * _loc1_,_loc2_ - 0.7071 * _loc1_);
   mc.curveTo(_loc3_ + 0.4142 * _loc1_,_loc2_ - _loc1_,_loc3_,_loc2_ - _loc1_);
   mc.curveTo(_loc3_ - 0.4142 * _loc1_,_loc2_ - _loc1_,_loc3_ - 0.7071 * _loc1_,_loc2_ - 0.7071 * _loc1_);
   mc.curveTo(_loc3_ - _loc1_,_loc2_ - 0.4142 * _loc1_,_loc3_ - _loc1_,_loc2_);
   mc.curveTo(_loc3_ - _loc1_,_loc2_ + 0.4142 * _loc1_,_loc3_ - 0.7071 * _loc1_,_loc2_ + 0.7071 * _loc1_);
   mc.curveTo(_loc3_ - 0.4142 * _loc1_,_loc2_ + _loc1_,_loc3_,_loc2_ + _loc1_);
   mc.curveTo(_loc3_ + 0.4142 * _loc1_,_loc2_ + _loc1_,_loc3_ + 0.7071 * _loc1_,_loc2_ + 0.7071 * _loc1_);
   mc.curveTo(_loc3_ + _loc1_,_loc2_ + 0.4142 * _loc1_,_loc3_ + _loc1_,_loc2_);
};
p._shoreData = [[{x:-0.3346,y:0.0459,z:0.9413},{x:-0.3416,y:0.0996,z:0.9346},{x:-0.2114,y:0.2266,z:0.9508},{x:-0.096,y:0.2606,z:0.9607},{x:-0.0754,y:0.2221,z:0.9721},{x:0.1858,y:0.3188,z:0.9294},{x:0.2601,y:0.2689,z:0.9274},{x:0.3333,y:0.1093,z:0.9365},{x:0.5148,y:0.0304,z:0.8568},{x:0.5205,y:0.0699,z:0.851},{x:0.4949,y:0.0935,z:0.8639},{x:0.5415,y:0.1316,z:0.8304},{x:0.4746,y:0.1559,z:0.8663},{x:0.4533,y:0.1428,z:0.8798},{x:0.3811,y:0.182,z:0.9064},{x:0.5518,y:0.1955,z:0.8107},{x:0.5657,y:0.1123,z:0.8169},{x:0.5325,y:0.0913,z:0.8415},{x:0.5788,y:0.0726,z:0.8123},{x:0.6521,y:0.0005,z:0.7582},{x:0.6599,y:-0.0552,z:0.7494},{x:0.6902,y:-0.0128,z:0.7235},{x:0.7263,y:-0.0199,z:0.6871},{x:0.7223,y:-0.1168,z:0.6817},{x:0.7875,y:-0.1261,z:0.6033},{x:0.8049,y:-0.079,z:0.5882},{x:0.7916,y:-0.0099,z:0.611},{x:0.7267,y:0.0424,z:0.6856},{x:0.7059,y:0.1082,z:0.7},{x:0.7406,y:0.2044,z:0.6401},{x:0.761,y:0.2109,z:0.6135},{x:0.7249,y:0.2418,z:0.645},{x:0.7003,y:0.1548,z:0.6969},{x:0.6782,y:0.1634,z:0.7165},{x:0.701,y:0.2505,z:0.6677},{x:0.7398,y:0.316,z:0.5939},{x:0.7024,y:0.2932,z:0.6486},{x:0.6614,y:0.3481,z:0.6644},{x:0.5977,y:0.3465,z:0.723},{x:0.5499,y:0.4863,z:0.679},{x:0.6837,y:0.3491,z:0.6408},{x:0.7121,y:0.3693,z:0.5971},{x:0.6462,y:0.4721,z:0.5996},{x:0.7063,y:0.479,z:0.5213},{x:0.7515,y:0.4162,z:0.5118},{x:0.7804,y:0.3107,z:0.5427},{x:0.816,y:0.2808,z:0.5053},{x:0.8186,y:0.1474,z:0.5552},{x:0.7832,y:0.1514,z:0.6031},{x:0.8072,y:-0.0792,z:0.5849},{x:0.8913,y:-0.2764,z:0.3594},{x:0.9222,y:-0.2913,z:0.2545},{x:0.968,y:-0.2156,z:0.1285},{x:0.996,y:-0.0345,z:0.0829},{x:0.991,y:0.0669,z:0.116},{x:0.9841,y:0.1734,z:0.0387},{x:0.9529,y:0.2358,z:-0.191},{x:0.9216,y:0.199,z:-0.3334},{x:0.7843,y:0.2596,z:-0.5635},{x:0.7424,y:0.3784,z:-0.5528},{x:0.7432,y:0.53,z:-0.4084},{x:0.7742,y:0.5361,z:-0.3363},{x:0.7322,y:0.6312,z:-0.2559},{x:0.7731,y:0.629,z:-0.0816},{x:0.6711,y:0.7371,z:0.0794},{x:0.6185,y:0.7582,z:0.2064},{x:0.7094,y:0.6835,z:0.172},{x:0.7425,y:0.6167,z:0.2616},{x:0.7323,y:0.4634,z:0.499},{x:0.7047,y:0.6485,z:0.288},{x:0.709,y:0.6702,z:0.2195},{x:0.547,y:0.7839,z:0.2936},{x:0.4669,y:0.7999,z:0.3771},{x:0.5075,y:0.7499,z:0.4244},{x:0.5708,y:0.7106,z:0.4113},{x:0.5873,y:0.6439,z:0.4903},{x:0.5637,y:0.6524,z:0.5065},{x:0.4562,y:0.7854,z:0.4183},{x:0.285,y:0.8918,z:0.3513},{x:0.2137,y:0.9667,z:0.1405},{x:0.1742,y:0.9683,z:0.179},{x:0.1617,y:0.9492,z:0.2701},{x:-0.0245,y:0.9218,z:0.3868},{x:-0.0724,y:0.9584,z:0.276},{x:-0.1291,y:0.9498,z:0.2851},{x:-0.1512,y:0.9825,z:0.1087},{x:-0.2453,y:0.9692,z:0.024},{x:-0.2253,y:0.9697,z:0.0943},{x:-0.162,y:0.9742,z:0.1569},{x:-0.1693,y:0.9583,z:0.2302},{x:-0.2604,y:0.9534,z:0.1521},{x:-0.324,y:0.9204,z:0.2189},{x:-0.2558,y:0.9105,z:0.3249},{x:-0.4007,y:0.8273,z:0.3937},{x:-0.461,y:0.7336,z:0.4994},{x:-0.4007,y:0.7145,z:0.5736},{x:-0.428,y:0.6691,z:0.6076},{x:-0.385,y:0.6794,z:0.6247},{x:-0.4476,y:0.6263,z:0.6383},{x:-0.4855,y:0.663,z:0.5698},{x:-0.5161,y:0.6355,z:0.5743},{x:-0.4692,y:0.6094,z:0.6391},{x:-0.5192,y:0.5174,z:0.6803},{x:-0.5026,y:0.4055,z:0.7635},{x:-0.4193,y:0.3708,z:0.8287},{x:-0.4622,y:0.1663,z:0.871},{x:-0.5025,y:0.2226,z:0.8355},{x:-0.5765,y:0.2476,z:0.7787},{x:-0.5338,y:0.1583,z:0.8306},{x:-0.4863,y:0.1283,z:0.8643},{x:-0.4672,y:0.0074,z:0.8841},{x:-0.418,y:0.0021,z:0.9084},{x:-0.4004,y:-0.072,z:0.9135}],[{x:0.206,y:-0.5678,z:-0.797},{x:0.3392,y:-0.6758,z:-0.6544},{x:0.5784,y:-0.6598,z:-0.4797},{x:0.5974,y:-0.6792,z:-0.4264},{x:0.6996,y:-0.6096,z:-0.3727},{x:0.7597,y:-0.612,z:-0.22},{x:0.8105,y:-0.5663,z:-0.1498},{x:0.8141,y:-0.5728,z:-0.0954},{x:0.6662,y:-0.7455,z:0.0175},{x:0.6302,y:-0.767,z:0.1205},{x:0.3556,y:-0.9081,z:0.2212},{x:0.2267,y:-0.9645,z:0.1355},{x:0.1876,y:-0.9681,z:0.1662},{x:0.1322,y:-0.9786,z:0.1575},{x:0.1114,y:-0.9592,z:0.2597},{x:0.0201,y:-0.9619,z:0.2728},{x:0.0499,y:-0.9301,z:0.3639},{x:-0.0045,y:-0.9324,z:0.3614},{x:-0.0268,y:-0.9479,z:0.3173},{x:-0.1023,y:-0.9327,z:0.3458},{x:-0.125,y:-0.8816,z:0.4551},{x:-0.0824,y:-0.8601,z:0.5034},{x:0.0953,y:-0.8597,z:0.5018},{x:0.1497,y:-0.8938,z:0.4228},{x:0.1263,y:-0.8453,z:0.5192},{x:0.1937,y:-0.7964,z:0.5729},{x:0.2105,y:-0.7227,z:0.6583},{x:0.2559,y:-0.7013,z:0.6653},{x:0.2381,y:-0.6877,z:0.6859},{x:0.2978,y:-0.6315,z:0.7159},{x:0.3001,y:-0.6601,z:0.6886},{x:0.3373,y:-0.6187,z:0.7096},{x:0.2658,y:-0.6144,z:0.7428},{x:0.2193,y:-0.6474,z:0.7299},{x:0.2561,y:-0.5848,z:0.7697},{x:0.3205,y:-0.5532,z:0.7689},{x:0.3322,y:-0.4862,z:0.8082},{x:0.284,y:-0.4991,z:0.8187},{x:0.2136,y:-0.4479,z:0.8682},{x:0.195,y:-0.4938,z:0.8474},{x:0.1718,y:-0.4534,z:0.8746},{x:0.0976,y:-0.4563,z:0.8845},{x:0.1089,y:-0.6066,z:0.7875},{x:0.0729,y:-0.5727,z:0.8165},{x:-0.0263,y:-0.5471,z:0.8366},{x:-0.0364,y:-0.4856,z:0.8734},{x:0.0594,y:-0.3827,z:0.922},{x:0.052,y:-0.3518,z:0.9346},{x:0.0091,y:-0.376,z:0.9266},{x:-0.0262,y:-0.3095,z:0.9505},{x:-0.0904,y:-0.365,z:0.9266},{x:-0.2194,y:-0.2788,z:0.9349},{x:-0.2931,y:-0.1264,z:0.9477},{x:-0.3515,y:-0.0852,z:0.9323},{x:-0.3753,y:-0.1338,z:0.9172},{x:-0.407,y:-0.0856,z:0.9094},{x:-0.406,y:-0.1419,z:0.9028},{x:-0.4614,y:-0.1161,z:0.8795},{x:-0.4954,y:-0.1572,z:0.8543},{x:-0.4735,y:-0.2013,z:0.8575},{x:-0.5529,y:-0.168,z:0.8162},{x:-0.4737,y:-0.2264,z:0.8511},{x:-0.4053,y:-0.2586,z:0.8768},{x:-0.3598,y:-0.3663,z:0.8581},{x:-0.3688,y:-0.5542,z:0.7462},{x:-0.433,y:-0.6465,z:0.6282},{x:-0.3806,y:-0.7794,z:0.4977},{x:-0.3212,y:-0.8604,z:0.3956},{x:-0.3576,y:-0.7715,z:0.5262},{x:-0.2197,y:-0.924,z:0.313},{x:0.0463,y:-0.9711,z:0.2343},{x:0.1108,y:-0.9829,z:0.1468},{x:0.1636,y:-0.9786,z:0.125},{x:0.1918,y:-0.9704,z:0.147},{x:0.2199,y:-0.9734,z:0.0637},{x:0.1579,y:-0.9849,z:-0.0705},{x:0.2319,y:-0.939,z:-0.254},{x:0.3228,y:-0.8834,z:-0.3398},{x:0.2626,y:-0.7902,z:-0.5538},{x:0.2245,y:-0.7628,z:-0.6064},{x:0.1743,y:-0.5802,z:-0.7956}],[{x:0.2884,y:-0.169,z:0.9425},{x:0.258,y:-0.135,z:0.9567},{x:0.2665,y:-0.0991,z:0.9587},{x:0.1582,y:-0.0467,z:0.9863},{x:0.0767,y:-0.1085,z:0.9911},{x:0.0709,y:-0.1896,z:0.9793},{x:0.2796,y:-0.3484,z:0.8947},{x:0.3541,y:-0.3522,z:0.8663}],[{x:-0.6199,y:0.4769,z:-0.6232},{x:-0.7027,y:0.3948,z:-0.5919},{x:-0.8027,y:0.4056,z:-0.4373},{x:-0.7799,y:0.5977,z:-0.1855},{x:-0.7366,y:0.6049,z:-0.3026},{x:-0.6881,y:0.6783,z:-0.2577},{x:-0.7106,y:0.6728,z:-0.2059},{x:-0.6562,y:0.7295,z:-0.193},{x:-0.6152,y:0.7435,z:-0.2623},{x:-0.5707,y:0.7852,z:-0.2406},{x:-0.487,y:0.8068,z:-0.3345},{x:-0.3773,y:0.8479,z:-0.3725},{x:-0.3439,y:0.7982,z:-0.4946},{x:-0.4027,y:0.7092,z:-0.5787},{x:-0.5375,y:0.6569,z:-0.5288},{x:-0.616,y:0.5528,z:-0.5612}],[{x:0.195,y:-0.4301,z:0.8815},{x:0.1489,y:-0.3678,z:0.9179},{x:0.1884,y:-0.3839,z:0.9039},{x:0.1903,y:-0.3474,z:0.9182},{x:0.0234,y:-0.286,z:0.9579},{x:0.0282,y:-0.3259,z:0.945},{x:0.1146,y:-0.3675,z:0.9229},{x:0.1043,y:-0.411,z:0.9056}],[{x:0.3616,y:0.0008,z:-0.9323},{x:0.2757,y:-0.095,z:-0.9565},{x:0.1623,y:-0.1217,z:-0.9792},{x:0.1207,y:-0.2253,z:-0.9668},{x:0.2426,y:-0.377,z:-0.8939},{x:0.0849,y:-0.3383,z:-0.9372},{x:0.0888,y:-0.2744,z:-0.9575},{x:-0.0569,y:-0.3062,z:-0.9503},{x:-0.1779,y:-0.2219,z:-0.9587},{x:-0.2086,y:0.0366,z:-0.9773},{x:-0.3158,y:0.0556,z:-0.9472},{x:-0.2925,y:0.2905,z:-0.9111},{x:-0.0938,y:0.4102,z:-0.9072},{x:0.056,y:0.4063,z:-0.912},{x:0.0955,y:0.3336,z:-0.9379},{x:0.2419,y:0.3294,z:-0.9127},{x:0.3116,y:0.1986,z:-0.9292},{x:0.3043,y:0.1373,z:-0.9426}],[{x:-0.8538,y:0.5009,z:-0.1421},{x:-0.7416,y:0.6703,z:-0.0256},{x:-0.709,y:0.7032,z:-0.0528},{x:-0.6683,y:0.7438,z:-0.0045},{x:-0.6686,y:0.741,z:-0.0628},{x:-0.74,y:0.6658,z:-0.0956},{x:-0.7476,y:0.6484,z:-0.1438},{x:-0.7854,y:0.5973,z:-0.1622},{x:-0.8088,y:0.5738,z:-0.129}],[{x:0.412,y:-0.5346,z:0.7379},{x:0.3479,y:-0.5141,z:0.784},{x:0.3439,y:-0.5681,z:0.7477},{x:0.3846,y:-0.5658,z:0.7293}],[{x:-0.476,y:0.8794,z:0.0094},{x:-0.4487,y:0.8918,z:0.0578},{x:-0.4865,y:0.8683,z:0.0968},{x:-0.4544,y:0.8824,z:0.1219},{x:-0.3257,y:0.9452,z:0.0238},{x:-0.3543,y:0.9338,z:-0.0508},{x:-0.4199,y:0.9043,z:-0.0771}],[{x:0.6229,y:-0.0015,z:0.7823},{x:0.5351,y:-0.0161,z:0.8447},{x:0.5191,y:-0.045,z:0.8535},{x:0.5664,y:-0.054,z:0.8224},{x:0.6044,y:-0.0332,z:0.796},{x:0.6377,y:-0.0634,z:0.7677}],[{x:-0.6002,y:0.5602,z:0.5709},{x:-0.63,y:0.5126,z:0.5834},{x:-0.5865,y:0.4671,z:0.6617},{x:-0.5851,y:0.5637,z:0.583},{x:-0.5406,y:0.6248,z:0.5634},{x:-0.5876,y:0.603,z:0.5395}],[{x:0.617,y:0.664,z:-0.4225},{x:0.6136,y:0.7434,z:-0.2664},{x:0.6383,y:0.7414,z:-0.2071},{x:0.6869,y:0.6617,z:-0.3006},{x:0.6624,y:0.6263,z:-0.4111}],[{x:-0.5157,y:0.8519,z:-0.0911},{x:-0.5141,y:0.857,z:-0.0346},{x:-0.5742,y:0.8181,z:0.0314},{x:-0.5062,y:0.8623,z:0.0162},{x:-0.4805,y:0.8757,z:-0.0484}],[{x:0.4193,y:-0.1148,z:0.9006},{x:0.3867,y:-0.0987,z:0.9169},{x:0.3781,y:-0.1507,z:0.9134},{x:0.4088,y:-0.1714,z:0.8964}],[{x:0.6119,y:-0.0864,z:0.7862},{x:0.5713,y:-0.0666,z:0.818},{x:0.5764,y:-0.1031,z:0.8107},{x:0.605,y:-0.1146,z:0.7879}],[{x:-0.7522,y:0.0451,z:-0.6574},{x:-0.8171,y:0.0431,z:-0.5749},{x:-0.8274,y:0.0859,z:-0.555},{x:-0.7623,y:0.0812,z:-0.6421}],[{x:-0.2696,y:0.958,z:-0.0974},{x:-0.2767,y:0.9593,z:-0.0563},{x:-0.2353,y:0.9719,z:0.0031},{x:-0.0907,y:0.9911,z:0.0973}],[{x:0.2428,y:-0.9068,z:0.3446},{x:0.1414,y:-0.9078,z:0.3949},{x:0.0949,y:-0.9173,z:0.3867},{x:0.1925,y:-0.9144,z:0.3562},{x:0.2009,y:-0.9193,z:0.3384}],[{x:0.0223,y:-0.7332,z:0.6796},{x:0.0589,y:-0.6836,z:0.7275},{x:-0.0229,y:-0.6822,z:0.7308},{x:0.0178,y:-0.6568,z:0.7539},{x:0.1038,y:-0.6978,z:0.7087},{x:0.0942,y:-0.7242,z:0.6831},{x:0.0629,y:-0.698,z:0.7134},{x:0.0448,y:-0.7453,z:0.6652}],[{x:0.4824,y:0.5331,z:0.6951},{x:0.4116,y:0.5444,z:0.7309},{x:0.4499,y:0.5682,z:0.689},{x:0.4702,y:0.6478,z:0.5994},{x:0.521,y:0.5986,z:0.6085}],[{x:0.3431,y:-0.8806,z:0.3269},{x:0.2745,y:-0.8987,z:0.3421},{x:0.2662,y:-0.9088,z:0.3212},{x:0.3042,y:-0.8984,z:0.3167}],[{x:-0.5955,y:0.4446,z:0.6691},{x:-0.6012,y:0.4083,z:0.6869},{x:-0.5515,y:0.4322,z:0.7135},{x:-0.5679,y:0.4685,z:0.6767},{x:-0.5955,y:0.4446,z:0.6691},{x:-0.5955,y:0.4446,z:0.6691}]];
