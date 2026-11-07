function GlobeComponentV2Class()
{
   this.createEmptyMovieClip("backAxisMC",0);
   this.createEmptyMovieClip("mouseAreaMC",5);
   this.createEmptyMovieClip("globeMC",10);
   this.createEmptyMovieClip("shadingMC",15);
   this.createEmptyMovieClip("frontAxisMC",20);
   this.globeMC.createEmptyMovieClip("maskMC",30);
   if(this.isStandalone == undefined)
   {
      this.isStandalone = !(this._sphere != undefined && this._sphere == this._parent._parent && this._object != undefined);
   }
   if(this.isStandalone)
   {
      if(this.initSunPosition == undefined)
      {
         this.initSunPosition = {theta:0,phi:0};
      }
      if(this.initSize == undefined)
      {
         this.initSize = this._width;
      }
   }
   else
   {
      if(this.initSunPosition == undefined)
      {
         this.initSunPosition = {ra:0,dec:0};
      }
      if(this.initSize == undefined)
      {
         this.initSize = 0.2;
      }
      this._sphere.watch("_bVer",this.sphereConstantsWatcher,this);
      this._sphere.showHorizonPlane = false;
      this._sphere.addLine("__PrecessingGlobeV2SouthPoleAxis",{thickness:2,color:255,alpha:100},{az:0,alt:0,r:0},{az:0,alt:0,r:1.5});
      this._sphere.addLine("__PrecessingGlobeV2NorthPoleAxis",{thickness:2,color:16711680,alpha:100},{az:0,alt:0,r:0},{az:0,alt:0,r:1.5});
   }
   this.placeholderMC._visible = false;
   this._xscale = 100;
   this._yscale = 100;
   this.mouseAreaMC.useHandCursor = false;
   this.mouseAreaMC.tabEnabled = false;
   this.mouseAreaMC.clear();
   this.mouseAreaMC.beginFill(16711680,0);
   this.drawCircle(this.mouseAreaMC,0,0,50);
   this.mouseAreaMC.endFill();
   this._c = {};
   if(this.initRotation == undefined)
   {
      this.initRotation = 0;
   }
   if(this.initPrecession == undefined)
   {
      this.initPrecession = 0;
   }
   if(this.initViewerTheta == undefined)
   {
      this.initViewerTheta = 0;
   }
   if(this.initViewerPhi == undefined)
   {
      this.initViewerPhi = 30;
   }
   if(this.initIsDraggable == undefined)
   {
      this.initIsDraggable = true;
   }
   if(this.initShowAxis == undefined)
   {
      this.initShowAxis = true;
   }
   if(this.initAxisLength == undefined)
   {
      this.initAxisLength = 1.4;
   }
   if(this.initAxisThickness == undefined)
   {
      this.initAxisThickness = 1;
   }
   if(this.initAxisColor == undefined)
   {
      this.initAxisColor = 0;
   }
   if(this.initAxisAlpha == undefined)
   {
      this.initAxisAlpha = 100;
   }
   if(this.initShowShading == undefined)
   {
      this.initShowShading = false;
   }
   if(this.initSunTheta != undefined)
   {
      this.initSunPosition.theta = this.initSunTheta;
   }
   if(this.initSunPhi != undefined)
   {
      this.initSunPosition.phi = this.initSunPhi;
   }
   if(this.initShadingColor == undefined)
   {
      this.initShadingColor = 0;
   }
   if(this.initShadingAlpha == undefined)
   {
      this.initShadingAlpha = 40;
   }
   if(this.initWaterLinkageName == undefined)
   {
      this.initWaterLinkageName = "Globe Component v2 Water";
   }
   if(this.initLandLinkageName == undefined)
   {
      this.initLandLinkageName = "Globe Component v2 Land";
   }
   this.updateAxis = function()
   {
   };
   this.updateGlobe = function()
   {
   };
   this.updateShading = function()
   {
   };
   this.setLandLinkageName(this.initLandLinkageName);
   this.setWaterLinkageName(this.initWaterLinkageName);
   this.setAxisStyle(this.initAxisThickness,this.initAxisColor,this.initAxisAlpha);
   this.setShadingStyle(this.initShadingColor,this.initShadingAlpha);
   this.setSunPosition(this.initSunPosition);
   this.setViewerDirection({theta:this.initViewerTheta,phi:this.initViewerPhi});
   this.size = this.initSize;
   this.rotation = this.initRotation;
   this.precession = this.initPrecession;
   this.axisLength = this.initAxisLength;
   this.showAxis = this.initShowAxis;
   this.showShading = this.initShowShading;
   this.isDraggable = this.initIsDraggable;
   delete this.updateAxis;
   delete this.updateGlobe;
   delete this.updateShading;
   this.updateAxis();
   this.updateGlobe();
   this.updateShading();
}
var p = GlobeComponentV2Class.prototype = new MovieClip();
Object.registerClass("Globe Component v2",GlobeComponentV2Class);
p.updateShading = function()
{
   if(!this._showShading)
   {
      return undefined;
   }
   var _loc10_ = this.shadingMC;
   _loc10_.clear();
   var _loc15_ = this._sunPos;
   var _loc16_ = {};
   var _loc19_;
   if(this.isStandalone)
   {
      _loc19_ = this._pc;
      _loc16_.x = _loc15_.x * _loc19_.b0 + _loc15_.y * _loc19_.b1 + _loc15_.z * _loc19_.b2;
      _loc16_.y = _loc15_.x * _loc19_.b3 + _loc15_.y * _loc19_.b4 + _loc15_.z * _loc19_.b5;
      _loc16_.z = _loc15_.x * _loc19_.b6 + _loc15_.y * _loc19_.b7 + _loc15_.z * _loc19_.b8;
   }
   else if(_loc15_.sys == 0 || _loc15_.sys == -1)
   {
      this._sphere.WtoSz(_loc15_,_loc16_);
   }
   else
   {
      if(_loc15_.sys != 1)
      {
         return undefined;
      }
      this._sphere.CtoSz(_loc15_,_loc16_);
   }
   _loc10_._rotation = 57.29577951308232 * Math.atan2(_loc16_.x,- _loc16_.y);
   var _loc18_ = (- _loc16_.z) / Math.sqrt(_loc16_.x * _loc16_.x + _loc16_.y * _loc16_.y + _loc16_.z * _loc16_.z);
   var _loc17_ = 4;
   var _loc4_ = 3.141592653589793 / _loc17_;
   var _loc20_ = _loc4_ / 2;
   var _loc6_ = Math.cos;
   var _loc7_ = Math.sin;
   var _loc5_ = 50;
   var _loc8_ = _loc5_ / _loc6_(_loc20_);
   _loc10_.moveTo(_loc5_,0);
   _loc10_.beginFill(this.shadingColor,this.shadingAlpha);
   var _loc3_ = _loc4_;
   var _loc2_ = _loc4_ - _loc20_;
   var _loc9_ = 0;
   var _loc14_;
   var _loc13_;
   var _loc12_;
   var _loc11_;
   while(_loc9_ < _loc17_)
   {
      _loc14_ = _loc5_ * _loc6_(_loc3_);
      _loc13_ = _loc5_ * _loc7_(_loc3_);
      _loc12_ = _loc8_ * _loc6_(_loc2_);
      _loc11_ = _loc8_ * _loc7_(_loc2_);
      _loc10_.curveTo(_loc12_,_loc11_,_loc14_,_loc13_);
      _loc3_ += _loc4_;
      _loc2_ += _loc4_;
      _loc9_ = _loc9_ + 1;
   }
   _loc9_ = 0;
   while(_loc9_ < _loc17_)
   {
      _loc14_ = _loc5_ * _loc6_(_loc3_);
      _loc13_ = _loc18_ * _loc5_ * _loc7_(_loc3_);
      _loc12_ = _loc8_ * _loc6_(_loc2_);
      _loc11_ = _loc18_ * _loc8_ * _loc7_(_loc2_);
      _loc10_.curveTo(_loc12_,_loc11_,_loc14_,_loc13_);
      _loc3_ += _loc4_;
      _loc2_ += _loc4_;
      _loc9_ = _loc9_ + 1;
   }
   _loc10_.endFill();
};
p.updateAxis = function()
{
   if(!this._showAxis)
   {
      return undefined;
   }
   var _loc6_ = this._c;
   var _loc2_;
   var _loc9_;
   var _loc3_;
   var _loc7_;
   var _loc8_;
   if(this.isStandalone)
   {
      _loc2_ = this._pc;
      _loc9_ = this._axisLength;
      if(_loc9_ < 1)
      {
         _loc9_ = 1;
      }
      _loc3_ = 1;
      _loc7_ = _loc9_;
   }
   else
   {
      _loc9_ = this._axisLength;
      if(_loc9_ < this._size)
      {
         _loc9_ = this._size;
      }
      _loc2_ = this._sphere._c;
      _loc3_ = this._size;
      _loc8_ = _loc9_ / _loc3_;
      if(_loc9_ < 1)
      {
         _loc7_ = _loc9_ / _loc3_;
      }
      else
      {
         _loc7_ = 1 / _loc3_;
      }
   }
   var _loc5_ = _loc3_ * (_loc2_.b0 * _loc6_.q2 + _loc2_.b1 * _loc6_.q5 + _loc2_.b2 * _loc6_.q8);
   var _loc4_ = _loc3_ * (_loc2_.b3 * _loc6_.q2 + _loc2_.b4 * _loc6_.q5 + _loc2_.b5 * _loc6_.q8);
   var _loc11_ = _loc3_ * (_loc2_.b6 * _loc6_.q2 + _loc2_.b7 * _loc6_.q5 + _loc2_.b8 * _loc6_.q8);
   var _loc10_;
   if(_loc11_ > 0)
   {
      _loc10_ = this.frontAxisMC;
      _loc10_.clear();
      _loc10_.lineStyle(this.axisThickness,this.axisColor,this.axisAlpha);
      _loc10_.moveTo(_loc5_,_loc4_);
      _loc10_.lineTo(_loc7_ * _loc5_,_loc7_ * _loc4_);
      _loc10_ = this.backAxisMC;
      _loc10_.clear();
      _loc10_.lineStyle(this.axisThickness,this.axisColor,this.axisAlpha);
      _loc10_.moveTo(- _loc5_,- _loc4_);
      _loc10_.lineTo((- _loc7_) * _loc5_,(- _loc7_) * _loc4_);
   }
   else
   {
      _loc10_ = this.backAxisMC;
      _loc10_.clear();
      _loc10_.lineStyle(this.axisThickness,this.axisColor,this.axisAlpha);
      _loc10_.moveTo(_loc5_,_loc4_);
      _loc10_.lineTo(_loc7_ * _loc5_,_loc7_ * _loc4_);
      _loc10_ = this.frontAxisMC;
      _loc10_.clear();
      _loc10_.lineStyle(this.axisThickness,this.axisColor,this.axisAlpha);
      _loc10_.moveTo(- _loc5_,- _loc4_);
      _loc10_.lineTo((- _loc7_) * _loc5_,(- _loc7_) * _loc4_);
   }
   var _loc15_;
   var _loc14_;
   var _loc13_;
   if(!this.isStandalone)
   {
      _loc15_ = (_loc2_.a0 * _loc5_ + _loc2_.a3 * _loc4_ + _loc2_.a6 * _loc11_) / _loc2_.r2;
      _loc14_ = (_loc2_.a1 * _loc5_ + _loc2_.a4 * _loc4_ + _loc2_.a7 * _loc11_) / _loc2_.r2;
      _loc13_ = (_loc2_.a5 * _loc4_ + _loc2_.a8 * _loc11_) / _loc2_.r2;
      if(_loc9_ < 1)
      {
         this._sphere.__PrecessingGlobeV2NorthPoleAxis.visible = false;
         this._sphere.__PrecessingGlobeV2SouthPoleAxis.visible = false;
      }
      else
      {
         this._sphere.__PrecessingGlobeV2NorthPoleAxis.setPoints({x:_loc15_ / _loc3_,y:_loc14_ / _loc3_,z:_loc13_ / _loc3_,system:"horizon"},{x:_loc15_ * _loc8_,y:_loc14_ * _loc8_,z:_loc13_ * _loc8_,system:"horizon"});
         this._sphere.__PrecessingGlobeV2SouthPoleAxis.setPoints({x:(- _loc15_) / _loc3_,y:(- _loc14_) / _loc3_,z:(- _loc13_) / _loc3_,system:"horizon"},{x:(- _loc15_) * _loc8_,y:(- _loc14_) * _loc8_,z:(- _loc13_) * _loc8_,system:"horizon"});
         this._sphere.__PrecessingGlobeV2NorthPoleAxis.visible = true;
         this._sphere.__PrecessingGlobeV2SouthPoleAxis.visible = true;
      }
   }
};
p.updateGlobe = function()
{
   var _loc32_ = this._c;
   var _loc30_;
   if(this.isStandalone)
   {
      _loc30_ = this._pc;
   }
   else
   {
      _loc30_ = this._sphere._c;
   }
   var _loc40_ = 50 / _loc30_.r;
   var _loc13_ = _loc40_ * (_loc30_.b0 * _loc32_.q0 + _loc30_.b1 * _loc32_.q3 + _loc30_.b2 * _loc32_.q6);
   var _loc12_ = _loc40_ * (_loc30_.b0 * _loc32_.q1 + _loc30_.b1 * _loc32_.q4 + _loc30_.b2 * _loc32_.q7);
   var _loc17_ = _loc40_ * (_loc30_.b0 * _loc32_.q2 + _loc30_.b1 * _loc32_.q5 + _loc30_.b2 * _loc32_.q8);
   var _loc16_ = _loc40_ * (_loc30_.b3 * _loc32_.q0 + _loc30_.b4 * _loc32_.q3 + _loc30_.b5 * _loc32_.q6);
   var _loc15_ = _loc40_ * (_loc30_.b3 * _loc32_.q1 + _loc30_.b4 * _loc32_.q4 + _loc30_.b5 * _loc32_.q7);
   var _loc14_ = _loc40_ * (_loc30_.b3 * _loc32_.q2 + _loc30_.b4 * _loc32_.q5 + _loc30_.b5 * _loc32_.q8);
   var _loc37_ = _loc40_ * (_loc30_.b6 * _loc32_.q0 + _loc30_.b7 * _loc32_.q3 + _loc30_.b8 * _loc32_.q6);
   var _loc36_ = _loc40_ * (_loc30_.b6 * _loc32_.q1 + _loc30_.b7 * _loc32_.q4 + _loc30_.b8 * _loc32_.q7);
   var _loc35_ = _loc40_ * (_loc30_.b6 * _loc32_.q2 + _loc30_.b7 * _loc32_.q5 + _loc30_.b8 * _loc32_.q8);
   var _loc5_ = this.globeMC.maskMC;
   _loc5_.clear();
   var _loc29_ = Math.cos;
   var _loc28_ = Math.sin;
   var _loc34_ = Math.atan2;
   var _loc38_ = Math.ceil;
   var _loc39_ = this._shoreData;
   var _loc41_ = 50;
   var _loc8_ = 1.5 * _loc41_;
   var _loc33_ = 2 * Math.acos(_loc41_ * 1.1 / _loc8_);
   var _loc31_ = 0;
   var _loc23_;
   var _loc10_;
   var _loc18_;
   var _loc6_;
   var _loc2_;
   var _loc22_;
   var _loc9_;
   var _loc19_;
   var _loc21_;
   var _loc20_;
   var _loc25_;
   var _loc3_;
   var _loc11_;
   var _loc24_;
   var _loc4_;
   var _loc7_;
   var _loc27_;
   var _loc26_;
   while(_loc31_ < _loc39_.length)
   {
      _loc23_ = _loc39_[_loc31_];
      _loc10_ = _loc23_.length;
      _loc18_ = false;
      _loc6_ = 0;
      while(_loc6_ < _loc10_)
      {
         _loc2_ = _loc23_[_loc6_];
         if(_loc2_.x * _loc37_ + _loc2_.y * _loc36_ + _loc2_.z * _loc35_ > 0)
         {
            if(_loc18_)
            {
               _loc5_.moveTo(_loc2_.x * _loc13_ + _loc2_.y * _loc12_ + _loc2_.z * _loc17_,_loc2_.x * _loc16_ + _loc2_.y * _loc15_ + _loc2_.z * _loc14_);
               break;
            }
            _loc18_ = true;
         }
         else
         {
            _loc18_ = false;
         }
         _loc6_ = _loc6_ + 1;
      }
      if(_loc6_ != _loc10_)
      {
         _loc22_ = false;
         _loc5_.beginFill(0);
         _loc9_ = 1;
         while(_loc9_ < _loc10_)
         {
            _loc2_ = _loc23_[(_loc6_ + _loc9_) % _loc10_];
            _loc19_ = _loc2_.x * _loc37_ + _loc2_.y * _loc36_ + _loc2_.z * _loc35_ < 0;
            if(!_loc19_)
            {
               if(_loc22_)
               {
                  _loc21_ = _loc2_.x * _loc13_ + _loc2_.y * _loc12_ + _loc2_.z * _loc17_;
                  _loc20_ = _loc2_.x * _loc16_ + _loc2_.y * _loc15_ + _loc2_.z * _loc14_;
                  _loc25_ = _loc34_(_loc20_,_loc21_);
                  _loc3_ = ((_loc25_ - angleLast) % 6.283185307179586 + 6.283185307179586) % 6.283185307179586;
                  if(_loc3_ > 3.141592653589793)
                  {
                     _loc3_ = 6.283185307179586 - _loc3_;
                     _loc11_ = _loc38_(_loc3_ / _loc33_);
                     _loc24_ = (- _loc3_) / _loc11_;
                  }
                  else
                  {
                     _loc11_ = _loc38_(_loc3_ / _loc33_);
                     _loc24_ = _loc3_ / _loc11_;
                  }
                  _loc4_ = 1;
                  while(_loc4_ <= _loc11_)
                  {
                     _loc7_ = angleLast + _loc24_ * _loc4_;
                     _loc5_.lineTo(_loc8_ * _loc29_(_loc7_),_loc8_ * _loc28_(_loc7_));
                     _loc4_ = _loc4_ + 1;
                  }
                  _loc5_.lineTo(_loc21_,_loc20_);
               }
               else
               {
                  _loc5_.lineTo(_loc2_.x * _loc13_ + _loc2_.y * _loc12_ + _loc2_.z * _loc17_,_loc2_.x * _loc16_ + _loc2_.y * _loc15_ + _loc2_.z * _loc14_);
               }
            }
            else if(!_loc22_)
            {
               _loc27_ = _loc2_.x * _loc13_ + _loc2_.y * _loc12_ + _loc2_.z * _loc17_;
               _loc26_ = _loc2_.x * _loc16_ + _loc2_.y * _loc15_ + _loc2_.z * _loc14_;
               var angleLast = _loc34_(_loc26_,_loc27_);
               _loc5_.lineTo(_loc8_ * _loc29_(angleLast),_loc8_ * _loc28_(angleLast));
            }
            _loc22_ = _loc19_;
            _loc9_ = _loc9_ + 1;
         }
         _loc5_.endFill();
      }
      _loc31_ = _loc31_ + 1;
   }
};
p.update = function()
{
   this.updateShading();
   this.updateAxis();
   this.updateGlobe();
};
p.getIsDraggable = function()
{
   return this.mouseAreaMC.onPress == this.onPressFunc;
};
p.setIsDraggable = function(arg)
{
   if(this.isStandalone && arg)
   {
      this.mouseAreaMC.onPress = this.onPressFunc;
      this.mouseAreaMC.onRelease = this.onReleaseFunc;
      this.mouseAreaMC.onReleaseOutside = this.onReleaseOutsideFunc;
      this.mouseAreaMC.onMouseMoveFunc = this.onMouseMoveFunc;
   }
   else
   {
      delete this.mouseAreaMC.onPress;
      delete this.mouseAreaMC.onRelease;
      delete this.mouseAreaMC.onReleaseOutside;
      delete this.mouseAreaMC.onMouseMove;
   }
};
p.addProperty("isDraggable",p.getIsDraggable,p.setIsDraggable);
p.onPressFunc = function()
{
   this.initX = this._xmouse;
   this.initY = this._ymouse;
   this.initTheta = this._parent._viewerTheta;
   this.initPhi = this._parent._viewerPhi;
   this.onMouseMove = this.onMouseMoveFunc;
};
p.onMouseMoveFunc = function()
{
   var _loc2_ = 57.29577951308232 * (this.initTheta - (this._xmouse - this.initX) / 50) - 180;
   var _loc3_ = 57.29577951308232 * (this.initPhi + (this._ymouse - this.initY) / 50);
   this._parent.setViewerDirection({theta:_loc2_,phi:_loc3_},true);
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
   this.globeMC.landMC.removeMovieClip();
   this.globeMC.attachMovie(arg,"landMC",20);
   this.globeMC.landMC.setMask(this.globeMC.maskMC);
};
p.getViewerDirection = function()
{
   var _loc2_ = {};
   _loc2_.theta = ((this._viewerTheta * 180 / 3.141592653589793 - 180) % 360 + 360) % 360;
   _loc2_.phi = this._viewerPhi * 180 / 3.141592653589793;
   return _loc2_;
};
p.setViewerDirection = function(arg, callChangeHandler)
{
   if(this.isStandalone)
   {
      this._viewerTheta = (arg.theta + 180) * 3.141592653589793 / 180;
      this._viewerPhi = arg.phi * 3.141592653589793 / 180;
      if(this._viewerPhi > 1.5707963267948966)
      {
         this._viewerPhi = 1.5707963267948966;
      }
      else if(this._viewerPhi < -1.5707963267948966)
      {
         this._viewerPhi = -1.5707963267948966;
      }
      this.calculateBConstants();
      this.update();
      if(callChangeHandler)
      {
         this._parent[this.viewerDirectionChangeHandler]();
      }
   }
};
p.setSunPosition = function(arg)
{
   this._sunPos = {};
   if(this.isStandalone)
   {
      this._sunTheta = arg.theta * 3.141592653589793 / 180;
      this._sunPhi = arg.phi * 3.141592653589793 / 180;
      this._sunPos.x = Math.cos(this._sunPhi) * Math.cos(this._sunTheta);
      this._sunPos.y = Math.cos(this._sunPhi) * Math.sin(this._sunTheta);
      this._sunPos.z = Math.sin(this._sunPhi);
   }
   else
   {
      this._sphere.parsePointInput(arg,this._sunPos);
   }
   this.updateShading();
};
p.getShowShading = function()
{
   return this._showShading;
};
p.setShowShading = function(arg)
{
   this._showShading = Boolean(arg);
   this.shadingMC._visible = this._showShading;
   this.updateShading();
};
p.addProperty("showShading",p.getShowShading,p.setShowShading);
p.setShadingStyle = function(color, alpha)
{
   this.shadingColor = color;
   this.shadingAlpha = alpha;
   this.updateShading();
};
p.getShowAxis = function()
{
   return this._showAxis;
};
p.setShowAxis = function(arg)
{
   this._showAxis = Boolean(arg);
   this.frontAxisMC._visible = this._showAxis;
   this.backAxisMC._visible = this._showAxis;
   if(!this._showAxis && !this.isStandalone)
   {
      this._sphere.__PrecessingGlobeV2SouthPoleAxis.visible = false;
      this._sphere.__PrecessingGlobeV2NorthPoleAxis.visible = false;
   }
   this.updateAxis();
};
p.addProperty("showAxis",p.getShowAxis,p.setShowAxis);
p.setAxisStyle = function(thickness, color, alpha)
{
   this.axisThickness = thickness;
   this.axisColor = color;
   this.axisAlpha = alpha;
   if(!this.isStandalone)
   {
      this._sphere.__PrecessingGlobeV2SouthPoleAxis.setStyle(this.axisThickness,this.axisColor,this.axisAlpha);
      this._sphere.__PrecessingGlobeV2NorthPoleAxis.setStyle(this.axisThickness,this.axisColor,this.axisAlpha);
   }
   this.updateAxis();
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
   this._precession = (arg % 360 + 360) % 360 * 0.017453292519943295;
   var _loc4_ = Math.cos(this._precession);
   var _loc3_ = Math.sin(this._precession);
   var _loc2_ = this._c;
   _loc2_.p0 = _loc4_;
   _loc2_.p1 = - _loc3_;
   _loc2_.p3 = _loc3_ * 0.91706;
   _loc2_.p4 = _loc4_ * 0.91706;
   _loc2_.p5 = -0.39875;
   _loc2_.p6 = _loc3_ * 0.39875;
   _loc2_.p7 = _loc4_ * 0.39875;
   _loc2_.p8 = 0.91706;
   this.calculateQConstants();
   this.updateGlobe();
   this.updateAxis();
};
p.addProperty("precession",p.getPrecession,p.setPrecession);
p.getRotation = function()
{
   return this._rotationAngle * 57.29577951308232;
};
p.setRotation = function(arg)
{
   this._rotationAngle = (arg % 360 + 360) % 360 * 0.017453292519943295;
   this.calculateRConstants();
   this.calculateQConstants();
   this.updateGlobe();
};
p.addProperty("rotation",p.getRotation,p.setRotation);
p.getSize = function()
{
   return this._size;
};
p.setSize = function(arg)
{
   this._size = arg;
   if(this.isStandalone)
   {
      this.mouseAreaMC._xscale = this.mouseAreaMC._yscale = this.globeMC._xscale = this.globeMC._yscale = this.shadingMC._xscale = this.shadingMC._yscale = this._size;
      this.calculateBConstants();
   }
   else
   {
      if(this._size > 1)
      {
         this._size = 1;
      }
      this.refreshScaling();
   }
   this.updateAxis();
};
p.addProperty("size",p.getSize,p.setSize);
p.refreshScaling = function()
{
   this.mouseAreaMC._xscale = this.mouseAreaMC._yscale = this.globeMC._xscale = this.globeMC._yscale = this.shadingMC._xscale = this.shadingMC._yscale = 2 * this._sphere._c.r * this._size;
};
p.calculateBConstants = function()
{
   var _loc3_ = this._size / 2;
   var _loc5_ = Math.cos(this._viewerTheta);
   var _loc4_ = Math.sin(this._viewerTheta);
   var _loc7_ = Math.cos(this._viewerPhi);
   var _loc6_ = Math.sin(this._viewerPhi);
   var _loc2_ = {};
   _loc2_.r = _loc3_;
   _loc2_.r2 = _loc3_ * _loc3_;
   _loc2_.b0 = _loc3_ * _loc4_;
   _loc2_.b1 = (- _loc3_) * _loc5_;
   _loc2_.b2 = 0;
   _loc2_.b3 = (- _loc3_) * _loc5_ * _loc6_;
   _loc2_.b4 = (- _loc3_) * _loc4_ * _loc6_;
   _loc2_.b5 = (- _loc3_) * _loc7_;
   _loc2_.b6 = (- _loc3_) * _loc5_ * _loc7_;
   _loc2_.b7 = (- _loc3_) * _loc4_ * _loc7_;
   _loc2_.b8 = _loc3_ * _loc6_;
   this._pc = _loc2_;
};
p.calculateRConstants = function()
{
   var _loc5_;
   if(this.isStandalone)
   {
      _loc5_ = this._rotationAngle;
   }
   else
   {
      _loc5_ = this._sphere._sTime + this._rotationAngle;
   }
   var _loc4_ = Math.cos(_loc5_);
   var _loc3_ = Math.sin(_loc5_);
   var _loc2_ = this._c;
   _loc2_.r0 = _loc4_;
   _loc2_.r1 = - _loc3_;
   _loc2_.r3 = _loc3_ * 0.91706;
   _loc2_.r4 = _loc4_ * 0.91706;
   _loc2_.r5 = 0.39875;
   _loc2_.r6 = (- _loc3_) * 0.39875;
   _loc2_.r7 = (- _loc4_) * 0.39875;
   _loc2_.r8 = 0.91706;
};
p.calculateQConstants = function()
{
   var _loc2_ = this._c;
   _loc2_.q0 = _loc2_.p0 * _loc2_.r0 + _loc2_.p1 * _loc2_.r3;
   _loc2_.q1 = _loc2_.p0 * _loc2_.r1 + _loc2_.p1 * _loc2_.r4;
   _loc2_.q2 = _loc2_.p1 * _loc2_.r5;
   _loc2_.q3 = _loc2_.p3 * _loc2_.r0 + _loc2_.p4 * _loc2_.r3 + _loc2_.p5 * _loc2_.r6;
   _loc2_.q4 = _loc2_.p3 * _loc2_.r1 + _loc2_.p4 * _loc2_.r4 + _loc2_.p5 * _loc2_.r7;
   _loc2_.q5 = _loc2_.p4 * _loc2_.r5 + _loc2_.p5 * _loc2_.r8;
   _loc2_.q6 = _loc2_.p6 * _loc2_.r0 + _loc2_.p7 * _loc2_.r3 + _loc2_.p8 * _loc2_.r6;
   _loc2_.q7 = _loc2_.p6 * _loc2_.r1 + _loc2_.p7 * _loc2_.r4 + _loc2_.p8 * _loc2_.r7;
   _loc2_.q8 = _loc2_.p7 * _loc2_.r5 + _loc2_.p8 * _loc2_.r8;
};
p.sphereConstantsWatcher = function(id, oldVal, newVal, globeInstance)
{
   globeInstance.refreshScaling();
   globeInstance.calculateRConstants();
   globeInstance.calculateQConstants();
   globeInstance.update();
   return newVal;
};
p.drawCircle = function(mc, x, y, r)
{
   mc.moveTo(x + r,y);
   mc.curveTo(x + r,y - 0.4142 * r,x + 0.7071 * r,y - 0.7071 * r);
   mc.curveTo(x + 0.4142 * r,y - r,x,y - r);
   mc.curveTo(x - 0.4142 * r,y - r,x - 0.7071 * r,y - 0.7071 * r);
   mc.curveTo(x - r,y - 0.4142 * r,x - r,y);
   mc.curveTo(x - r,y + 0.4142 * r,x - 0.7071 * r,y + 0.7071 * r);
   mc.curveTo(x - 0.4142 * r,y + r,x,y + r);
   mc.curveTo(x + 0.4142 * r,y + r,x + 0.7071 * r,y + 0.7071 * r);
   mc.curveTo(x + r,y + 0.4142 * r,x + r,y);
};
p._shoreData = [[{x:-0.3346,y:0.0459,z:0.9413},{x:-0.3416,y:0.0996,z:0.9346},{x:-0.2114,y:0.2266,z:0.9508},{x:-0.096,y:0.2606,z:0.9607},{x:-0.0754,y:0.2221,z:0.9721},{x:0.1858,y:0.3188,z:0.9294},{x:0.2601,y:0.2689,z:0.9274},{x:0.3333,y:0.1093,z:0.9365},{x:0.5148,y:0.0304,z:0.8568},{x:0.5205,y:0.0699,z:0.851},{x:0.4949,y:0.0935,z:0.8639},{x:0.5415,y:0.1316,z:0.8304},{x:0.4746,y:0.1559,z:0.8663},{x:0.4533,y:0.1428,z:0.8798},{x:0.3811,y:0.182,z:0.9064},{x:0.5518,y:0.1955,z:0.8107},{x:0.5657,y:0.1123,z:0.8169},{x:0.5325,y:0.0913,z:0.8415},{x:0.5788,y:0.0726,z:0.8123},{x:0.6521,y:0.0005,z:0.7582},{x:0.6599,y:-0.0552,z:0.7494},{x:0.6902,y:-0.0128,z:0.7235},{x:0.7263,y:-0.0199,z:0.6871},{x:0.7223,y:-0.1168,z:0.6817},{x:0.7875,y:-0.1261,z:0.6033},{x:0.8049,y:-0.079,z:0.5882},{x:0.7916,y:-0.0099,z:0.611},{x:0.7267,y:0.0424,z:0.6856},{x:0.7059,y:0.1082,z:0.7},{x:0.7406,y:0.2044,z:0.6401},{x:0.761,y:0.2109,z:0.6135},{x:0.7249,y:0.2418,z:0.645},{x:0.7003,y:0.1548,z:0.6969},{x:0.6782,y:0.1634,z:0.7165},{x:0.701,y:0.2505,z:0.6677},{x:0.7398,y:0.316,z:0.5939},{x:0.7024,y:0.2932,z:0.6486},{x:0.6614,y:0.3481,z:0.6644},{x:0.5977,y:0.3465,z:0.723},{x:0.5499,y:0.4863,z:0.679},{x:0.6837,y:0.3491,z:0.6408},{x:0.7121,y:0.3693,z:0.5971},{x:0.6462,y:0.4721,z:0.5996},{x:0.7063,y:0.479,z:0.5213},{x:0.7515,y:0.4162,z:0.5118},{x:0.7804,y:0.3107,z:0.5427},{x:0.816,y:0.2808,z:0.5053},{x:0.8186,y:0.1474,z:0.5552},{x:0.7832,y:0.1514,z:0.6031},{x:0.8072,y:-0.0792,z:0.5849},{x:0.8913,y:-0.2764,z:0.3594},{x:0.9222,y:-0.2913,z:0.2545},{x:0.968,y:-0.2156,z:0.1285},{x:0.996,y:-0.0345,z:0.0829},{x:0.991,y:0.0669,z:0.116},{x:0.9841,y:0.1734,z:0.0387},{x:0.9529,y:0.2358,z:-0.191},{x:0.9216,y:0.199,z:-0.3334},{x:0.7843,y:0.2596,z:-0.5635},{x:0.7424,y:0.3784,z:-0.5528},{x:0.7432,y:0.53,z:-0.4084},{x:0.7742,y:0.5361,z:-0.3363},{x:0.7322,y:0.6312,z:-0.2559},{x:0.7731,y:0.629,z:-0.0816},{x:0.6711,y:0.7371,z:0.0794},{x:0.6185,y:0.7582,z:0.2064},{x:0.7094,y:0.6835,z:0.172},{x:0.7425,y:0.6167,z:0.2616},{x:0.7323,y:0.4634,z:0.499},{x:0.7047,y:0.6485,z:0.288},{x:0.709,y:0.6702,z:0.2195},{x:0.547,y:0.7839,z:0.2936},{x:0.4669,y:0.7999,z:0.3771},{x:0.5075,y:0.7499,z:0.4244},{x:0.5708,y:0.7106,z:0.4113},{x:0.5873,y:0.6439,z:0.4903},{x:0.5637,y:0.6524,z:0.5065},{x:0.4562,y:0.7854,z:0.4183},{x:0.285,y:0.8918,z:0.3513},{x:0.2137,y:0.9667,z:0.1405},{x:0.1742,y:0.9683,z:0.179},{x:0.1617,y:0.9492,z:0.2701},{x:-0.0245,y:0.9218,z:0.3868},{x:-0.0724,y:0.9584,z:0.276},{x:-0.1291,y:0.9498,z:0.2851},{x:-0.1512,y:0.9825,z:0.1087},{x:-0.2453,y:0.9692,z:0.024},{x:-0.2253,y:0.9697,z:0.0943},{x:-0.162,y:0.9742,z:0.1569},{x:-0.1693,y:0.9583,z:0.2302},{x:-0.2604,y:0.9534,z:0.1521},{x:-0.324,y:0.9204,z:0.2189},{x:-0.2558,y:0.9105,z:0.3249},{x:-0.4007,y:0.8273,z:0.3937},{x:-0.461,y:0.7336,z:0.4994},{x:-0.4007,y:0.7145,z:0.5736},{x:-0.428,y:0.6691,z:0.6076},{x:-0.385,y:0.6794,z:0.6247},{x:-0.4476,y:0.6263,z:0.6383},{x:-0.4855,y:0.663,z:0.5698},{x:-0.5161,y:0.6355,z:0.5743},{x:-0.4692,y:0.6094,z:0.6391},{x:-0.5192,y:0.5174,z:0.6803},{x:-0.5026,y:0.4055,z:0.7635},{x:-0.4193,y:0.3708,z:0.8287},{x:-0.4622,y:0.1663,z:0.871},{x:-0.5025,y:0.2226,z:0.8355},{x:-0.5765,y:0.2476,z:0.7787},{x:-0.5338,y:0.1583,z:0.8306},{x:-0.4863,y:0.1283,z:0.8643},{x:-0.4672,y:0.0074,z:0.8841},{x:-0.418,y:0.0021,z:0.9084},{x:-0.4004,y:-0.072,z:0.9135}],[{x:0.206,y:-0.5678,z:-0.797},{x:0.3392,y:-0.6758,z:-0.6544},{x:0.5784,y:-0.6598,z:-0.4797},{x:0.5974,y:-0.6792,z:-0.4264},{x:0.6996,y:-0.6096,z:-0.3727},{x:0.7597,y:-0.612,z:-0.22},{x:0.8105,y:-0.5663,z:-0.1498},{x:0.8141,y:-0.5728,z:-0.0954},{x:0.6662,y:-0.7455,z:0.0175},{x:0.6302,y:-0.767,z:0.1205},{x:0.3556,y:-0.9081,z:0.2212},{x:0.2267,y:-0.9645,z:0.1355},{x:0.1876,y:-0.9681,z:0.1662},{x:0.1322,y:-0.9786,z:0.1575},{x:0.1114,y:-0.9592,z:0.2597},{x:0.0201,y:-0.9619,z:0.2728},{x:0.0499,y:-0.9301,z:0.3639},{x:-0.0045,y:-0.9324,z:0.3614},{x:-0.0268,y:-0.9479,z:0.3173},{x:-0.1023,y:-0.9327,z:0.3458},{x:-0.125,y:-0.8816,z:0.4551},{x:-0.0824,y:-0.8601,z:0.5034},{x:0.0953,y:-0.8597,z:0.5018},{x:0.1497,y:-0.8938,z:0.4228},{x:0.1263,y:-0.8453,z:0.5192},{x:0.1937,y:-0.7964,z:0.5729},{x:0.2105,y:-0.7227,z:0.6583},{x:0.2559,y:-0.7013,z:0.6653},{x:0.2381,y:-0.6877,z:0.6859},{x:0.2978,y:-0.6315,z:0.7159},{x:0.3001,y:-0.6601,z:0.6886},{x:0.3373,y:-0.6187,z:0.7096},{x:0.2658,y:-0.6144,z:0.7428},{x:0.2193,y:-0.6474,z:0.7299},{x:0.2561,y:-0.5848,z:0.7697},{x:0.3205,y:-0.5532,z:0.7689},{x:0.3322,y:-0.4862,z:0.8082},{x:0.284,y:-0.4991,z:0.8187},{x:0.2136,y:-0.4479,z:0.8682},{x:0.195,y:-0.4938,z:0.8474},{x:0.1718,y:-0.4534,z:0.8746},{x:0.0976,y:-0.4563,z:0.8845},{x:0.1089,y:-0.6066,z:0.7875},{x:0.0729,y:-0.5727,z:0.8165},{x:-0.0263,y:-0.5471,z:0.8366},{x:-0.0364,y:-0.4856,z:0.8734},{x:0.0594,y:-0.3827,z:0.922},{x:0.052,y:-0.3518,z:0.9346},{x:0.0091,y:-0.376,z:0.9266},{x:-0.0262,y:-0.3095,z:0.9505},{x:-0.0904,y:-0.365,z:0.9266},{x:-0.2194,y:-0.2788,z:0.9349},{x:-0.2931,y:-0.1264,z:0.9477},{x:-0.3515,y:-0.0852,z:0.9323},{x:-0.3753,y:-0.1338,z:0.9172},{x:-0.407,y:-0.0856,z:0.9094},{x:-0.406,y:-0.1419,z:0.9028},{x:-0.4614,y:-0.1161,z:0.8795},{x:-0.4954,y:-0.1572,z:0.8543},{x:-0.4735,y:-0.2013,z:0.8575},{x:-0.5529,y:-0.168,z:0.8162},{x:-0.4737,y:-0.2264,z:0.8511},{x:-0.4053,y:-0.2586,z:0.8768},{x:-0.3598,y:-0.3663,z:0.8581},{x:-0.3688,y:-0.5542,z:0.7462},{x:-0.433,y:-0.6465,z:0.6282},{x:-0.3806,y:-0.7794,z:0.4977},{x:-0.3212,y:-0.8604,z:0.3956},{x:-0.3576,y:-0.7715,z:0.5262},{x:-0.2197,y:-0.924,z:0.313},{x:0.0463,y:-0.9711,z:0.2343},{x:0.1108,y:-0.9829,z:0.1468},{x:0.1636,y:-0.9786,z:0.125},{x:0.1918,y:-0.9704,z:0.147},{x:0.2199,y:-0.9734,z:0.0637},{x:0.1579,y:-0.9849,z:-0.0705},{x:0.2319,y:-0.939,z:-0.254},{x:0.3228,y:-0.8834,z:-0.3398},{x:0.2626,y:-0.7902,z:-0.5538},{x:0.2245,y:-0.7628,z:-0.6064},{x:0.1743,y:-0.5802,z:-0.7956}],[{x:0.2884,y:-0.169,z:0.9425},{x:0.258,y:-0.135,z:0.9567},{x:0.2665,y:-0.0991,z:0.9587},{x:0.1582,y:-0.0467,z:0.9863},{x:0.0767,y:-0.1085,z:0.9911},{x:0.0709,y:-0.1896,z:0.9793},{x:0.2796,y:-0.3484,z:0.8947},{x:0.3541,y:-0.3522,z:0.8663}],[{x:-0.6199,y:0.4769,z:-0.6232},{x:-0.7027,y:0.3948,z:-0.5919},{x:-0.8027,y:0.4056,z:-0.4373},{x:-0.7799,y:0.5977,z:-0.1855},{x:-0.7366,y:0.6049,z:-0.3026},{x:-0.6881,y:0.6783,z:-0.2577},{x:-0.7106,y:0.6728,z:-0.2059},{x:-0.6562,y:0.7295,z:-0.193},{x:-0.6152,y:0.7435,z:-0.2623},{x:-0.5707,y:0.7852,z:-0.2406},{x:-0.487,y:0.8068,z:-0.3345},{x:-0.3773,y:0.8479,z:-0.3725},{x:-0.3439,y:0.7982,z:-0.4946},{x:-0.4027,y:0.7092,z:-0.5787},{x:-0.5375,y:0.6569,z:-0.5288},{x:-0.616,y:0.5528,z:-0.5612}],[{x:0.195,y:-0.4301,z:0.8815},{x:0.1489,y:-0.3678,z:0.9179},{x:0.1884,y:-0.3839,z:0.9039},{x:0.1903,y:-0.3474,z:0.9182},{x:0.0234,y:-0.286,z:0.9579},{x:0.0282,y:-0.3259,z:0.945},{x:0.1146,y:-0.3675,z:0.9229},{x:0.1043,y:-0.411,z:0.9056}],[{x:0.3616,y:0.0008,z:-0.9323},{x:0.2757,y:-0.095,z:-0.9565},{x:0.1623,y:-0.1217,z:-0.9792},{x:0.1207,y:-0.2253,z:-0.9668},{x:0.2426,y:-0.377,z:-0.8939},{x:0.0849,y:-0.3383,z:-0.9372},{x:0.0888,y:-0.2744,z:-0.9575},{x:-0.0569,y:-0.3062,z:-0.9503},{x:-0.1779,y:-0.2219,z:-0.9587},{x:-0.2086,y:0.0366,z:-0.9773},{x:-0.3158,y:0.0556,z:-0.9472},{x:-0.2925,y:0.2905,z:-0.9111},{x:-0.0938,y:0.4102,z:-0.9072},{x:0.056,y:0.4063,z:-0.912},{x:0.0955,y:0.3336,z:-0.9379},{x:0.2419,y:0.3294,z:-0.9127},{x:0.3116,y:0.1986,z:-0.9292},{x:0.3043,y:0.1373,z:-0.9426}],[{x:-0.8538,y:0.5009,z:-0.1421},{x:-0.7416,y:0.6703,z:-0.0256},{x:-0.709,y:0.7032,z:-0.0528},{x:-0.6683,y:0.7438,z:-0.0045},{x:-0.6686,y:0.741,z:-0.0628},{x:-0.74,y:0.6658,z:-0.0956},{x:-0.7476,y:0.6484,z:-0.1438},{x:-0.7854,y:0.5973,z:-0.1622},{x:-0.8088,y:0.5738,z:-0.129}],[{x:0.412,y:-0.5346,z:0.7379},{x:0.3479,y:-0.5141,z:0.784},{x:0.3439,y:-0.5681,z:0.7477},{x:0.3846,y:-0.5658,z:0.7293}],[{x:-0.476,y:0.8794,z:0.0094},{x:-0.4487,y:0.8918,z:0.0578},{x:-0.4865,y:0.8683,z:0.0968},{x:-0.4544,y:0.8824,z:0.1219},{x:-0.3257,y:0.9452,z:0.0238},{x:-0.3543,y:0.9338,z:-0.0508},{x:-0.4199,y:0.9043,z:-0.0771}],[{x:0.6229,y:-0.0015,z:0.7823},{x:0.5351,y:-0.0161,z:0.8447},{x:0.5191,y:-0.045,z:0.8535},{x:0.5664,y:-0.054,z:0.8224},{x:0.6044,y:-0.0332,z:0.796},{x:0.6377,y:-0.0634,z:0.7677}],[{x:-0.6002,y:0.5602,z:0.5709},{x:-0.63,y:0.5126,z:0.5834},{x:-0.5865,y:0.4671,z:0.6617},{x:-0.5851,y:0.5637,z:0.583},{x:-0.5406,y:0.6248,z:0.5634},{x:-0.5876,y:0.603,z:0.5395}],[{x:0.617,y:0.664,z:-0.4225},{x:0.6136,y:0.7434,z:-0.2664},{x:0.6383,y:0.7414,z:-0.2071},{x:0.6869,y:0.6617,z:-0.3006},{x:0.6624,y:0.6263,z:-0.4111}],[{x:-0.5157,y:0.8519,z:-0.0911},{x:-0.5141,y:0.857,z:-0.0346},{x:-0.5742,y:0.8181,z:0.0314},{x:-0.5062,y:0.8623,z:0.0162},{x:-0.4805,y:0.8757,z:-0.0484}],[{x:0.4193,y:-0.1148,z:0.9006},{x:0.3867,y:-0.0987,z:0.9169},{x:0.3781,y:-0.1507,z:0.9134},{x:0.4088,y:-0.1714,z:0.8964}],[{x:0.6119,y:-0.0864,z:0.7862},{x:0.5713,y:-0.0666,z:0.818},{x:0.5764,y:-0.1031,z:0.8107},{x:0.605,y:-0.1146,z:0.7879}],[{x:-0.7522,y:0.0451,z:-0.6574},{x:-0.8171,y:0.0431,z:-0.5749},{x:-0.8274,y:0.0859,z:-0.555},{x:-0.7623,y:0.0812,z:-0.6421}],[{x:-0.2696,y:0.958,z:-0.0974},{x:-0.2767,y:0.9593,z:-0.0563},{x:-0.2353,y:0.9719,z:0.0031},{x:-0.0907,y:0.9911,z:0.0973}],[{x:0.2428,y:-0.9068,z:0.3446},{x:0.1414,y:-0.9078,z:0.3949},{x:0.0949,y:-0.9173,z:0.3867},{x:0.1925,y:-0.9144,z:0.3562},{x:0.2009,y:-0.9193,z:0.3384}],[{x:0.0223,y:-0.7332,z:0.6796},{x:0.0589,y:-0.6836,z:0.7275},{x:-0.0229,y:-0.6822,z:0.7308},{x:0.0178,y:-0.6568,z:0.7539},{x:0.1038,y:-0.6978,z:0.7087},{x:0.0942,y:-0.7242,z:0.6831},{x:0.0629,y:-0.698,z:0.7134},{x:0.0448,y:-0.7453,z:0.6652}],[{x:0.4824,y:0.5331,z:0.6951},{x:0.4116,y:0.5444,z:0.7309},{x:0.4499,y:0.5682,z:0.689},{x:0.4702,y:0.6478,z:0.5994},{x:0.521,y:0.5986,z:0.6085}],[{x:0.3431,y:-0.8806,z:0.3269},{x:0.2745,y:-0.8987,z:0.3421},{x:0.2662,y:-0.9088,z:0.3212},{x:0.3042,y:-0.8984,z:0.3167}],[{x:-0.5955,y:0.4446,z:0.6691},{x:-0.6012,y:0.4083,z:0.6869},{x:-0.5515,y:0.4322,z:0.7135},{x:-0.5679,y:0.4685,z:0.6767},{x:-0.5955,y:0.4446,z:0.6691},{x:-0.5955,y:0.4446,z:0.6691}]];
