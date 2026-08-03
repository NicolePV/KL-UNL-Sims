var p = CelestialSphereClass.prototype;
p.getMouseAzAlt = p.getMouseAltAz = function(p)
{
   var x = this._xmouse;
   var y = this._ymouse;
   var d = Math.sqrt(x * x + y * y);
   if(d > this._c.r)
   {
      p.alt = null;
      p.az = null;
   }
   else
   {
      this.StoMH({x:x,y:y},p);
      p.alt *= 57.29577951308232;
      p.az = (360 - p.az * 57.29577951308232) % 360;
   }
};
p.getMouseDecRa = p.getMouseRaDec = function(p)
{
   var x = this._xmouse;
   var y = this._ymouse;
   var d = Math.sqrt(x * x + y * y);
   if(d > this._c.r)
   {
      p.ra = null;
      p.dec = null;
   }
   else
   {
      var hp = new Object();
      this.StoMH({x:x,y:y},hp);
      this.MHtoC(hp,p);
      p.ra *= 3.819718634205488;
      p.dec *= 57.29577951308232;
   }
};
p.setMouseBehavior = function(arg)
{
   if(arg == "simple drag")
   {
      this.onPress = this.startSimpleDragging;
   }
   else if(arg == "rotate about zenith")
   {
      this.onPress = this.startZenithRotation;
   }
   else if(arg == "rotate about NCP")
   {
      this.onPress = this.startNCPRotation;
   }
   else
   {
      this.onPress = undefined;
      this.onMouseMove = undefined;
   }
};
p.useHandCursor = false;
p.onRelease = p.onReleaseOutside = function()
{
   this.onMouseMove = undefined;
};
p.startSimpleDragging = function()
{
   this._dragXMouse = this._xmouse;
   this._dragYMouse = this._ymouse;
   this._dragTheta = this._theta;
   this._dragPhi = this._phi;
   this.onMouseMove = this.updateSimpleDragging;
};
p.updateSimpleDragging = function()
{
   this.setThetaAndPhi(57.29577951308232 * (this._dragTheta - (this._xmouse - this._dragXMouse) / this._c.r),57.29577951308232 * (this._dragPhi + (this._ymouse - this._dragYMouse) / this._c.r));
   this.onMouseUpdate();
   updateAfterEvent();
};
p.startZenithRotation = function()
{
   var x = this._xmouse;
   var y = this._ymouse;
   if(Math.sqrt(x * x + y * y) <= this._c.r)
   {
      var hp = new Object();
      this.StoMH({x:x,y:y},hp);
      this._dragAz = hp.az;
      this.onMouseMove = this.updateZenithRotation;
   }
};
p.updateZenithRotation = function()
{
   var hp = new Object();
   this.StoMH({x:this._xmouse,y:this._ymouse},hp);
   this.setTheta(57.29577951308232 * (this._theta + (this._dragAz - hp.az)));
   this.onMouseUpdate();
   updateAfterEvent();
};
p.startNCPRotation = function()
{
   var x = this._xmouse;
   var y = this._ymouse;
   if(Math.sqrt(x * x + y * y) <= this._c.r)
   {
      var hp = new Object();
      var cp = new Object();
      this.StoMH({x:x,y:y},hp);
      this.MHtoC(hp,cp);
      this._dragRA = cp.ra;
      this.onMouseMove = this.updateNCPRotation;
   }
};
p.updateNCPRotation = function()
{
   var hp = new Object();
   var cp = new Object();
   this.StoMH({x:this._xmouse,y:this._ymouse},hp);
   this.MHtoC(hp,cp);
   this.setSiderealTime((this._sTime - cp.ra + this._dragRA) * 3.819718634205488);
   this.onMouseUpdate();
   updateAfterEvent();
};
