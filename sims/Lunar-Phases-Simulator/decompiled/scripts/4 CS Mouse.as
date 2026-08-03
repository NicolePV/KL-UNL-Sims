var p = CelestialSphereClass.prototype;
p.getMouseAzAlt = p.getMouseAltAz = function(p)
{
   var _loc5_ = this._xmouse;
   var _loc4_ = this._ymouse;
   var _loc3_ = Math.sqrt(_loc5_ * _loc5_ + _loc4_ * _loc4_);
   if(_loc3_ > this._c.r)
   {
      p.alt = null;
      p.az = null;
   }
   else
   {
      this.StoMH({x:_loc5_,y:_loc4_},p);
      p.alt *= 57.29577951308232;
      p.az = (360 - p.az * 57.29577951308232) % 360;
   }
};
p.getMouseDecRa = p.getMouseRaDec = function(p)
{
   var _loc6_ = this._xmouse;
   var _loc5_ = this._ymouse;
   var _loc4_ = Math.sqrt(_loc6_ * _loc6_ + _loc5_ * _loc5_);
   var _loc3_;
   if(_loc4_ > this._c.r)
   {
      p.ra = null;
      p.dec = null;
   }
   else
   {
      _loc3_ = {};
      this.StoMH({x:_loc6_,y:_loc5_},_loc3_);
      this.MHtoC(_loc3_,p);
      p.ra *= 3.819718634205488;
      p.dec *= 57.29577951308232;
   }
};
p.setMouseBehavior = function(arg)
{
   if(arg == "simple drag")
   {
      this._mouseArea.useHandCursor = false;
      this._mouseArea.onRelease = this._mouseArea.onReleaseOutside = function()
      {
         delete this.onMouseMove;
      };
      this._mouseArea.onPress = this.startSimpleDragging;
   }
   else if(arg == "rotate about zenith")
   {
      this._mouseArea.useHandCursor = false;
      this._mouseArea.onRelease = this._mouseArea.onReleaseOutside = function()
      {
         delete this.onMouseMove;
      };
      this._mouseArea.onPress = this.startZenithRotation;
   }
   else if(arg == "rotate about NCP")
   {
      this._mouseArea.useHandCursor = false;
      this._mouseArea.onRelease = this._mouseArea.onReleaseOutside = function()
      {
         delete this.onMouseMove;
      };
      this._mouseArea.onPress = this.startNCPRotation;
   }
   else
   {
      delete this._mouseArea.onRelease;
      delete this._mouseArea.onReleaseOutside;
      delete this._mouseArea.onPress;
      delete this._mouseArea.onMouseMove;
   }
};
p.startSimpleDragging = function()
{
   this._dragXMouse = this._parent._xmouse;
   this._dragYMouse = this._parent._ymouse;
   this._dragTheta = this._parent._theta;
   this._dragPhi = this._parent._phi;
   this.onMouseMove = this._parent.updateSimpleDragging;
};
p.updateSimpleDragging = function()
{
   this._parent.setThetaAndPhi(57.29577951308232 * (this._dragTheta - (this._parent._xmouse - this._dragXMouse) / this._parent._c.r),57.29577951308232 * (this._dragPhi + (this._parent._ymouse - this._dragYMouse) / this._parent._c.r));
   this._parent.onMouseUpdate.call(this._parent.onMouseUpdateInstance);
};
p.startZenithRotation = function()
{
   var _loc4_ = this._parent._xmouse;
   var _loc3_ = this._parent._ymouse;
   var _loc2_;
   if(Math.sqrt(_loc4_ * _loc4_ + _loc3_ * _loc3_) <= this._parent._c.r)
   {
      _loc2_ = {};
      this._parent.StoMH({x:_loc4_,y:_loc3_},_loc2_);
      this._dragAz = _loc2_.az;
      this.onMouseMove = this._parent.updateZenithRotation;
   }
};
p.updateZenithRotation = function()
{
   var _loc2_ = {};
   this._parent.StoMH({x:this._parent._xmouse,y:this._parent._ymouse},_loc2_);
   this._parent.setTheta(57.29577951308232 * (this._parent._theta + (this._dragAz - _loc2_.az)));
   this._parent.onMouseUpdate.call(this._parent.onMouseUpdateInstance);
};
p.startNCPRotation = function()
{
   var _loc5_ = this._parent._xmouse;
   var _loc4_ = this._parent._ymouse;
   var _loc2_;
   var _loc3_;
   if(Math.sqrt(_loc5_ * _loc5_ + _loc4_ * _loc4_) <= this._parent._c.r)
   {
      _loc2_ = {};
      _loc3_ = {};
      this._parent.StoMH({x:_loc5_,y:_loc4_},_loc2_);
      this._parent.MHtoC(_loc2_,_loc3_);
      this._dragRA = _loc3_.ra;
      this.onMouseMove = this._parent.updateNCPRotation;
   }
};
p.updateNCPRotation = function()
{
   var _loc2_ = {};
   var _loc3_ = {};
   this._parent.StoMH({x:this._parent._xmouse,y:this._parent._ymouse},_loc2_);
   this._parent.MHtoC(_loc2_,_loc3_);
   this._parent.setSiderealTime((this._parent._sTime - _loc3_.ra + this._dragRA) * 3.819718634205488);
   this._parent.onMouseUpdate.call(this._parent.onMouseUpdateInstance);
};
p.updateMouseArea = function()
{
   var _loc19_ = getTimer();
   var _loc11_;
   var _loc10_;
   var _loc18_;
   var _loc9_;
   var _loc12_;
   var _loc13_;
   var _loc14_;
   var _loc16_;
   var _loc3_;
   var _loc4_;
   var _loc2_;
   var _loc8_;
   var _loc7_;
   var _loc6_;
   var _loc5_;
   var _loc15_;
   var _loc17_;
   if(!this._showUnder)
   {
      _loc11_ = 4;
      _loc10_ = 3.141592653589793 / _loc11_;
      _loc18_ = _loc10_ / 2;
      _loc9_ = this._c.r;
      _loc12_ = Math.cos;
      _loc13_ = Math.sin;
      _loc14_ = _loc9_ / _loc12_(_loc18_);
      _loc16_ = this._mouseArea;
      _loc16_.clear();
      _loc16_.lineStyle(1,16711680,0);
      _loc16_.moveTo(_loc9_,0);
      _loc16_.beginFill(255,0);
      _loc3_ = _loc10_;
      _loc4_ = _loc3_ - _loc18_;
      _loc2_ = 0;
      while(_loc2_ < _loc11_)
      {
         _loc8_ = _loc9_ * _loc12_(_loc3_);
         _loc7_ = (- _loc9_) * _loc13_(_loc3_);
         _loc6_ = _loc14_ * _loc12_(_loc4_);
         _loc5_ = (- _loc14_) * _loc13_(_loc4_);
         _loc16_.curveTo(_loc6_,_loc5_,_loc8_,_loc7_);
         _loc3_ += _loc10_;
         _loc4_ += _loc10_;
         _loc2_ = _loc2_ + 1;
      }
      _loc15_ = _loc13_(Math.abs(this._phi));
      _loc2_ = 0;
      while(_loc2_ < _loc11_)
      {
         _loc8_ = _loc9_ * _loc12_(_loc3_);
         _loc7_ = (- _loc15_) * _loc9_ * _loc13_(_loc3_);
         _loc6_ = _loc14_ * _loc12_(_loc4_);
         _loc5_ = (- _loc15_) * _loc14_ * _loc13_(_loc4_);
         _loc16_.curveTo(_loc6_,_loc5_,_loc8_,_loc7_);
         _loc3_ += _loc10_;
         _loc4_ += _loc10_;
         _loc2_ = _loc2_ + 1;
      }
      _loc16_.endFill();
   }
   else
   {
      _loc17_ = 8;
      _loc10_ = 6.283185307179586 / _loc17_;
      _loc18_ = _loc10_ / 2;
      _loc9_ = this._c.r;
      _loc12_ = Math.cos;
      _loc13_ = Math.sin;
      _loc14_ = _loc9_ / _loc12_(_loc18_);
      _loc16_ = this._mouseArea;
      _loc16_.clear();
      _loc16_.lineStyle(1,16711680,0);
      _loc16_.moveTo(_loc9_,0);
      _loc16_.beginFill(255,0);
      _loc3_ = _loc10_;
      _loc4_ = _loc3_ - _loc18_;
      _loc2_ = 0;
      while(_loc2_ < _loc17_)
      {
         _loc8_ = _loc9_ * _loc12_(_loc3_);
         _loc7_ = (- _loc9_) * _loc13_(_loc3_);
         _loc6_ = _loc14_ * _loc12_(_loc4_);
         _loc5_ = (- _loc14_) * _loc13_(_loc4_);
         _loc16_.curveTo(_loc6_,_loc5_,_loc8_,_loc7_);
         _loc3_ += _loc10_;
         _loc4_ += _loc10_;
         _loc2_ = _loc2_ + 1;
      }
      _loc16_.endFill();
   }
   if(!this._traceOn)
   {
   }
};
