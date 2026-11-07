function shoreDemoClass()
{
   this.attachMovie("globe background","backgroundMC",1);
   this.createEmptyMovieClip("shoresMC",2);
   this._c = new Object();
   this.size = 300;
   this.theta = 0;
   this.phi = 45;
   this.polyLimit = 25;
}
var p = shoreDemoClass.prototype = new MovieClip();
Object.registerClass("shoreDemo",shoreDemoClass);
p.update = function()
{
   this.startTime = getTimer();
   this.shoresMC.clear();
   this.shoresMC.lineStyle(1,12632256,100);
   this.currPoly = 0;
   this.numFrames = 0;
   this.updateOnEnterFunc();
   this.onEnterFrame = this.updateOnEnterFunc;
};
p.updateOnEnterFunc = function()
{
   var a0 = this._c.a0;
   var a1 = this._c.a1;
   var a3 = this._c.a3;
   var a4 = this._c.a4;
   var a5 = this._c.a5;
   var a6 = this._c.a6;
   var a7 = this._c.a7;
   var a8 = this._c.a8;
   var mc = this.shoresMC;
   var s = _root.shoreData;
   var stopTime = getTimer() + 65;
   var i = this.currPoly;
   while(getTimer() < stopTime)
   {
      if(i > this.polyLimit)
      {
         this.onEnterFrame = undefined;
         break;
      }
      var p = s[i];
      var pl = p.length;
      var pt = p[pl - 1];
      var ib = pt.x * a6 + pt.y * a7 + pt.z * a8 < 0;
      if(!ib)
      {
         mc.moveTo(pt.x * a0 + pt.y * a1,pt.x * a3 + pt.y * a4 + pt.z * a5);
      }
      var k = 0;
      while(k < pl)
      {
         var pt = p[k];
         if(pt.x * a6 + pt.y * a7 + pt.z * a8 < 0)
         {
            ib = true;
         }
         else
         {
            if(ib)
            {
               mc.moveTo(pt.x * a0 + pt.y * a1,pt.x * a3 + pt.y * a4 + pt.z * a5);
            }
            else
            {
               mc.lineTo(pt.x * a0 + pt.y * a1,pt.x * a3 + pt.y * a4 + pt.z * a5);
            }
            ib = false;
         }
         k++;
      }
      i++;
   }
   this.numFrames++;
   this.currPoly = i;
};
p.useHandCursor = false;
p.onMouseUp = p.onRelease = p.onReleaseOutside = function()
{
   delete this.onMouseMove;
};
p.onPressFunc = function()
{
   this._sphere._parent.cityLabel._visible = false;
   this._sphere._parent.cityLabel.currentCityDot.gotoAndStop(1);
   if(Key.isDown(16))
   {
      this._dragXMouse = this._xmouse;
      this._dragYMouse = this._ymouse;
      this._dragTheta = this._theta;
      this._dragPhi = this._phi;
      this.onMouseMove = this.updateSimpleDragging;
   }
   else
   {
      this.updateMoveCursor();
      this.onMouseMove = this.updateMoveCursor;
   }
};
p.onPress = p.onPressFunc;
p.updateMoveCursor = function()
{
   var pt = {};
   this._sphere.getMouseAltAz(pt);
   this.moveCursor(pt);
   var n = this._sphere._parent.cityList.length;
   var showingLabel = false;
   var i = 0;
   while(i < n)
   {
      var cityObj = this._sphere["city" + i];
      if(cityObj.instance.hitTest(_root._xmouse,_root._ymouse,true) && cityObj._sp.z > 0 && cityObj.visible)
      {
         showingLabel = true;
         if(cityObj.instance != this.lastCityLabelShown)
         {
            this.lastCityLabelShown.hideLabel();
         }
         cityObj.instance.showLabel();
         this.lastCityLabelShown = cityObj.instance;
         break;
      }
      i++;
   }
   if(!showingLabel)
   {
      this.lastCityLabelShown.hideLabel();
   }
   updateAfterEvent();
};
p.moveCursor = function(pt)
{
   if(pt.alt != null)
   {
      this._sphere.cursor.setPosition(pt);
      this._sphere.cursor.setOrientationType("absolute");
      this.cursorPosition = {};
      if(pt.az > 180)
      {
         this.cursorPosition.lonValStr = this.toFixed(360 - pt.az,1);
         this.cursorPosition.lonDirStr = "E";
         this._sphere.longArc.setCircleParameters({alt:0,az:0,tilt:0,gammaStart:0,gammaEnd:- pt.az});
         this._sphere.longArc.update();
      }
      else
      {
         this.cursorPosition.lonValStr = this.toFixed(pt.az,1);
         this.cursorPosition.lonDirStr = "W";
         this._sphere.longArc.setCircleParameters({alt:0,az:0,tilt:180,gammaStart:0,gammaEnd:pt.az});
         this._sphere.longArc.update();
      }
      if(pt.alt > 0)
      {
         this.cursorPosition.latValStr = this.toFixed(pt.alt,1);
         this.cursorPosition.latDirStr = "N";
         this._sphere.longLabel.setPosition({az:pt.az,alt:-6});
      }
      else
      {
         this.cursorPosition.latValStr = this.toFixed(Math.abs(pt.alt),1);
         this.cursorPosition.latDirStr = "S";
         this._sphere.longLabel.setPosition({az:pt.az,alt:6});
      }
      var fdeg = Math.abs(pt.alt);
      var ideg = Math.floor(fdeg);
      var fmin = 60 * (fdeg - ideg);
      var imin = Math.floor(fmin);
      var fsec = 60 * (fmin - imin);
      var isec = Math.floor(fsec);
      var str = ideg + "° ";
      if(imin < 10)
      {
         str += "0" + imin + "\' ";
      }
      else
      {
         str += imin + "\' ";
      }
      this.cursorPosition.latitudeDMSString = str + this.cursorPosition.latDirStr;
      if(pt.az > 180)
      {
         var fdeg = 360 - pt.az;
      }
      else
      {
         var fdeg = pt.az;
      }
      var ideg = Math.floor(fdeg);
      var fmin = 60 * (fdeg - ideg);
      var imin = Math.floor(fmin);
      var fsec = 60 * (fmin - imin);
      var isec = Math.floor(fsec);
      var str = ideg + "° ";
      if(imin < 10)
      {
         str += "0" + imin + "\' ";
      }
      else
      {
         str += imin + "\' ";
      }
      this.cursorPosition.longitudeDMSString = str + this.cursorPosition.lonDirStr;
      this._sphere._parent.updateStrings();
      this._sphere.longLabel.setOrientationType("absolute");
      this._sphere.latLabel.setPosition({az:pt.az + 16,alt:pt.alt / 2});
      this._sphere.latLabel.setOrientationType("absolute");
      this._sphere.updateObjects();
      if(pt.alt > 0)
      {
         this._sphere.latArc.setCircleParameters({alt:0,az:pt.az,tilt:90,gammaStart:0,gammaEnd:pt.alt});
         this._sphere.latArc.update();
      }
      else
      {
         this._sphere.latArc.setCircleParameters({alt:0,az:pt.az,tilt:90,gammaStart:pt.alt,gammaEnd:0});
         this._sphere.latArc.update();
      }
      this._sphere.longCircle.setCircleParameters({alt:0,az:pt.az,tilt:90,gammaStart:-90,gammaEnd:90});
      this._sphere.longCircle.update();
      this._sphere.latCircle.setCircleParameters({alt:pt.alt,az:0,tilt:0});
      this._sphere.latCircle.update();
   }
};
p.updateSimpleDragging = function()
{
   var newTheta = 57.29577951308232 * (this._dragTheta - (this._xmouse - this._dragXMouse) / this._c.r);
   var newPhi = 57.29577951308232 * (this._dragPhi + (this._ymouse - this._dragYMouse) / this._c.r);
   newTheta = (newTheta % 360 + 360) % 360;
   newPhi = ((newPhi + 180) % 360 + 360) % 360 - 180;
   if(newPhi > 90)
   {
      newPhi = 90;
   }
   else if(newPhi < -90)
   {
      newPhi = -90;
   }
   this.setThetaAndPhi(newTheta,newPhi);
   this._sphere.setThetaAndPhi(newTheta,newPhi);
   this._sphere.equatorLabel.az = this._sphere.viewerAzimuth;
   this._sphere.equatorLabel.setOrientationType("absolute");
   updateAfterEvent();
};
p.setThetaAndPhi = function(newTheta, newPhi)
{
   this._theta = 0.017453292519943295 * newTheta;
   this._phi = 0.017453292519943295 * newPhi;
   this.doA();
   this.update();
};
p.getTheta = function()
{
   return 57.29577951308232 * this._theta;
};
p.setTheta = function(arg)
{
   this._theta = 0.017453292519943295 * ((arg % 360 + 360) % 360);
   this.doA();
   this.update();
};
p.getPhi = function()
{
   return 57.29577951308232 * this._phi;
};
p.setPhi = function(newPhi)
{
   this._phi = 0.017453292519943295 * (((newPhi + 180) % 360 + 360) % 360 - 180);
   this.doA();
   this.update();
};
p.getSize = function()
{
   return 2 * this._c.r;
};
p.setSize = function(arg)
{
   if(isFinite(arg) && arg > 0)
   {
      this._c.r = arg / 2;
      this.backgroundMC._xscale = this.backgroundMC._yscale = this._c.r;
      this.doA();
      this.update();
   }
};
p.addProperty("theta",p.getTheta,p.setTheta);
p.addProperty("phi",p.getPhi,p.setPhi);
p.addProperty("size",p.getSize,p.setSize);
p.doA = function()
{
   var c = this._c;
   var ct = Math.cos(this._theta);
   var st = Math.sin(this._theta);
   var cp = Math.cos(this._phi);
   var sp = Math.sin(this._phi);
   c.a0 = (- c.r) * st;
   c.a1 = c.r * ct;
   c.a3 = c.r * ct * sp;
   c.a4 = c.r * st * sp;
   c.a5 = (- c.r) * cp;
   c.a6 = c.r * ct * cp;
   c.a7 = c.r * st * cp;
   c.a8 = c.r * sp;
};
p.toFixed = function(x, f)
{
   var s = "";
   if(x < 0)
   {
      s = "-";
      x = - x;
   }
   var m = "";
   if(x < 1e+21)
   {
      var n = Math.round(x * Math.pow(10,f));
      if(n == 0)
      {
         m = "0";
      }
      else
      {
         m = n.toString();
      }
      if(f > 0)
      {
         var k = m.length;
         if(k <= f)
         {
            var z = "";
            var i = 0;
            while(i < f + 1 - k)
            {
               z += "0";
               i++;
            }
            m = z + m;
            k = f + 1;
         }
         var a = m.substr(0,k - f);
         var b = m.substr(k - f);
         m = a + "." + b;
      }
   }
   else
   {
      m = x.toString();
   }
   return s + m;
};
