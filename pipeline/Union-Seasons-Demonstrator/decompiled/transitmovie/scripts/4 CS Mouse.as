var p = CelestialSphereClass.prototype;
p.getMouseAzAlt = p.getMouseAltAz = function(p)
{
   var _loc1_ = p;
   var _loc2_ = this;
   var x = _loc2_._xmouse;
   var y = _loc2_._ymouse;
   var _loc3_ = Math.sqrt(x * x + y * y);
   if(_loc3_ > _loc2_._c.r)
   {
      _loc1_.alt = null;
      _loc1_.az = null;
   }
   else
   {
      _loc2_.StoMH({x:x,y:y},_loc1_);
      _loc1_.alt *= 57.29577951308232;
      _loc1_.az = (360 - _loc1_.az * 57.29577951308232) % 360;
   }
};
p.getMouseDecRa = p.getMouseRaDec = function(p)
{
   var _loc1_ = p;
   var _loc2_ = this;
   var x = _loc2_._xmouse;
   var y = _loc2_._ymouse;
   var d = Math.sqrt(x * x + y * y);
   var _loc3_;
   if(d > _loc2_._c.r)
   {
      _loc1_.ra = null;
      _loc1_.dec = null;
   }
   else
   {
      _loc3_ = {};
      _loc2_.StoMH({x:x,y:y},_loc3_);
      _loc2_.MHtoC(_loc3_,_loc1_);
      _loc1_.ra *= 3.819718634205488;
      _loc1_.dec *= 57.29577951308232;
   }
};
p.setMouseBehavior = function(arg)
{
   var _loc1_ = this;
   var _loc2_ = arg;
   if(_loc2_ == "simple drag")
   {
      _loc1_._mouseArea.useHandCursor = false;
      _loc1_._mouseArea.onRelease = _loc1_._mouseArea.onReleaseOutside = function()
      {
         delete this.onMouseMove;
      };
      _loc1_._mouseArea.onPress = _loc1_.startSimpleDragging;
   }
   else if(_loc2_ == "rotate about zenith")
   {
      _loc1_._mouseArea.useHandCursor = false;
      _loc1_._mouseArea.onRelease = _loc1_._mouseArea.onReleaseOutside = function()
      {
         delete this.onMouseMove;
      };
      _loc1_._mouseArea.onPress = _loc1_.startZenithRotation;
   }
   else if(_loc2_ == "rotate about NCP")
   {
      _loc1_._mouseArea.useHandCursor = false;
      _loc1_._mouseArea.onRelease = _loc1_._mouseArea.onReleaseOutside = function()
      {
         delete this.onMouseMove;
      };
      _loc1_._mouseArea.onPress = _loc1_.startNCPRotation;
   }
   else
   {
      delete _loc1_._mouseArea.onRelease;
      delete _loc1_._mouseArea.onReleaseOutside;
      delete _loc1_._mouseArea.onPress;
      delete _loc1_._mouseArea.onMouseMove;
   }
};
p.startSimpleDragging = function()
{
   var _loc1_ = this;
   _loc1_._dragXMouse = _loc1_._parent._xmouse;
   _loc1_._dragYMouse = _loc1_._parent._ymouse;
   _loc1_._dragTheta = _loc1_._parent._theta;
   _loc1_._dragPhi = _loc1_._parent._phi;
   _loc1_.onMouseMove = _loc1_._parent.updateSimpleDragging;
};
p.updateSimpleDragging = function()
{
   var _loc1_ = this;
   _loc1_._parent.setThetaAndPhi(57.29577951308232 * (_loc1_._dragTheta - (_loc1_._parent._xmouse - _loc1_._dragXMouse) / _loc1_._parent._c.r),57.29577951308232 * (_loc1_._dragPhi + (_loc1_._parent._ymouse - _loc1_._dragYMouse) / _loc1_._parent._c.r));
   _loc1_._parent.onMouseUpdate.call(_loc1_._parent.onMouseUpdateInstance);
};
p.startZenithRotation = function()
{
   var _loc1_ = this;
   var x = _loc1_._parent._xmouse;
   var y = _loc1_._parent._ymouse;
   var _loc2_;
   if(Math.sqrt(x * x + y * y) <= _loc1_._parent._c.r)
   {
      _loc2_ = {};
      _loc1_._parent.StoMH({x:x,y:y},_loc2_);
      _loc1_._dragAz = _loc2_.az;
      _loc1_.onMouseMove = _loc1_._parent.updateZenithRotation;
   }
};
p.updateZenithRotation = function()
{
   var _loc1_ = this;
   var _loc2_ = {};
   _loc1_._parent.StoMH({x:_loc1_._parent._xmouse,y:_loc1_._parent._ymouse},_loc2_);
   _loc1_._parent.setTheta(57.29577951308232 * (_loc1_._parent._theta + (_loc1_._dragAz - _loc2_.az)));
   _loc1_._parent.onMouseUpdate.call(_loc1_._parent.onMouseUpdateInstance);
};
p.startNCPRotation = function()
{
   var _loc1_ = this;
   var x = _loc1_._parent._xmouse;
   var y = _loc1_._parent._ymouse;
   var _loc2_;
   var _loc3_;
   if(Math.sqrt(x * x + y * y) <= _loc1_._parent._c.r)
   {
      _loc2_ = {};
      _loc3_ = {};
      _loc1_._parent.StoMH({x:x,y:y},_loc2_);
      _loc1_._parent.MHtoC(_loc2_,_loc3_);
      _loc1_._dragRA = _loc3_.ra;
      _loc1_.onMouseMove = _loc1_._parent.updateNCPRotation;
   }
};
p.updateNCPRotation = function()
{
   var _loc1_ = this;
   var _loc2_ = {};
   var _loc3_ = {};
   _loc1_._parent.StoMH({x:_loc1_._parent._xmouse,y:_loc1_._parent._ymouse},_loc2_);
   _loc1_._parent.MHtoC(_loc2_,_loc3_);
   _loc1_._parent.setSiderealTime((_loc1_._parent._sTime - _loc3_.ra + _loc1_._dragRA) * 3.819718634205488);
   _loc1_._parent.onMouseUpdate.call(_loc1_._parent.onMouseUpdateInstance);
};
p.updateMouseArea = function()
{
   var start = getTimer();
   var _loc2_;
   var _loc3_;
   var _loc1_;
   if(!this._showUnder)
   {
      var hnp = 4;
      var step = 3.141592653589793 / hnp;
      var hstep = step / 2;
      var r = this._c.r;
      var cos = Math.cos;
      var sin = Math.sin;
      var cr = r / cos(hstep);
      var ma = this._mouseArea;
      ma.clear();
      ma.lineStyle(1,16711680,0);
      ma.moveTo(r,0);
      ma.beginFill(255,0);
      _loc2_ = step;
      _loc3_ = _loc2_ - hstep;
      _loc1_ = 0;
      while(_loc1_ < hnp)
      {
         var ax = r * cos(_loc2_);
         var ay = (- r) * sin(_loc2_);
         var cx = cr * cos(_loc3_);
         var cy = (- cr) * sin(_loc3_);
         ma.curveTo(cx,cy,ax,ay);
         _loc2_ += step;
         _loc3_ += step;
         _loc1_ = _loc1_ + 1;
      }
      var sp = sin(Math.abs(this._phi));
      _loc1_ = 0;
      while(_loc1_ < hnp)
      {
         var ax = r * cos(_loc2_);
         var ay = (- sp) * r * sin(_loc2_);
         var cx = cr * cos(_loc3_);
         var cy = (- sp) * cr * sin(_loc3_);
         ma.curveTo(cx,cy,ax,ay);
         _loc2_ += step;
         _loc3_ += step;
         _loc1_ = _loc1_ + 1;
      }
      ma.endFill();
   }
   else
   {
      var np = 8;
      var step = 6.283185307179586 / np;
      var hstep = step / 2;
      var r = this._c.r;
      var cos = Math.cos;
      var sin = Math.sin;
      var cr = r / cos(hstep);
      var ma = this._mouseArea;
      ma.clear();
      ma.lineStyle(1,16711680,0);
      ma.moveTo(r,0);
      ma.beginFill(255,0);
      _loc2_ = step;
      _loc3_ = _loc2_ - hstep;
      _loc1_ = 0;
      while(_loc1_ < np)
      {
         var ax = r * cos(_loc2_);
         var ay = (- r) * sin(_loc2_);
         var cx = cr * cos(_loc3_);
         var cy = (- cr) * sin(_loc3_);
         ma.curveTo(cx,cy,ax,ay);
         _loc2_ += step;
         _loc3_ += step;
         _loc1_ = _loc1_ + 1;
      }
      ma.endFill();
   }
   if(this._traceOn)
   {
      trace("mouse area time: " + (getTimer() - start) + " ms");
   }
};
