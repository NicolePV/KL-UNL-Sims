function BinarySystemComponentClass()
{
   if(this.initAnimate == undefined)
   {
      this.initAnimate = false;
   }
   if(this.initAnimationRate == undefined)
   {
      this.initAnimationRate = 0.3;
   }
   if(this.initAllowDragging == undefined)
   {
      this.initAllowDragging = true;
   }
   if(this.initTheta == undefined)
   {
      this.initTheta = 45;
   }
   if(this.initPhi == undefined)
   {
      this.initPhi = 35;
   }
   if(this.initPhase == undefined)
   {
      this.initPhase = 0;
   }
   if(this.initSeparation == undefined)
   {
      this.initSeparation = 10;
   }
   if(this.initEccentricity == undefined)
   {
      this.initEccentricity = 0.3;
   }
   if(this.initMass1 == undefined)
   {
      this.initMass1 = 3;
   }
   if(this.initRadius1 == undefined)
   {
      this.initRadius1 = 4.8;
   }
   if(this.initTemp1 == undefined)
   {
      this.initTemp1 = 4900;
   }
   if(this.initMass2 == undefined)
   {
      this.initMass2 = 1.2;
   }
   if(this.initRadius2 == undefined)
   {
      this.initRadius2 = 2;
   }
   if(this.initTemp2 == undefined)
   {
      this.initTemp2 = 12000;
   }
   if(this.initShowOrbitalPaths == undefined)
   {
      this.initShowOrbitalPaths = true;
   }
   if(this.initOrbitalPathsColor == undefined)
   {
      this.initOrbitalPathsColor = 16777215;
   }
   if(this.initShowOrbitalPlane == undefined)
   {
      this.initShowOrbitalPlane = true;
   }
   if(this.initOrbitalPlaneColor == undefined)
   {
      this.initOrbitalPlaneColor = 11579568;
   }
   if(this.initOrbitalPlaneAlpha == undefined)
   {
      this.initOrbitalPlaneAlpha = 40;
   }
   if(this.initShowArrow == undefined)
   {
      this.initShowArrow = true;
   }
   if(this.initArrowTheta == undefined)
   {
      this.initArrowTheta = 0;
   }
   if(this.initArrowPhi == undefined)
   {
      this.initArrowPhi = 0;
   }
   if(this.initArrowColor == undefined)
   {
      this.initArrowColor = 16744576;
   }
   if(this.initBorderColor == undefined)
   {
      this.initBorderColor = 6710886;
   }
   if(this.initBackgroundColor == undefined)
   {
      this.initBackgroundColor = 0;
   }
   this.placeholderMC._visible = false;
   if(this.width == undefined && this.height == undefined)
   {
      this.windowWidth = this._width;
      this.windowHeight = this._height;
   }
   else
   {
      this.windowWidth = this.width;
      this.windowHeight = this.height;
   }
   this._xscale = 100;
   this._yscale = 100;
   this.createEmptyMovieClip("backgroundMC",10);
   this.createEmptyMovieClip("windowMC",20);
   this.createEmptyMovieClip("maskMC",30);
   this.createEmptyMovieClip("borderMC",40);
   this.windowMC.setMask(this.maskMC);
   this.backgroundMC.useHandCursor = false;
   this.backgroundMC.onPressFunc = function()
   {
      this.initX = this._xmouse;
      this.initY = this._ymouse;
      this.dragPhi = this._parent.phi;
      this.dragTheta = this._parent.theta;
      this.onMouseMove = this.onMouseMoveFunc;
   };
   this.backgroundMC.onMouseMoveFunc = function()
   {
      var newPhi = this.dragPhi - 57.29577951308232 * (this.initY - this._ymouse) / this._parent._targetSize;
      var newTheta = this.dragTheta - 57.29577951308232 * (this._xmouse - this.initX) / this._parent._targetSize;
      if(newPhi > 90)
      {
         newPhi = 90;
      }
      else if(newPhi < -90)
      {
         newPhi = -90;
      }
      this._parent.setThetaAndPhi(newTheta,newPhi);
      updateAfterEvent();
   };
   this.backgroundMC.onReleaseFunc = function()
   {
      delete this.onMouseMove;
   };
   this.windowMC.createEmptyMovieClip("backHalfMC",100);
   this.windowMC.createEmptyMovieClip("orbitalPlaneMC",200);
   this.windowMC.createEmptyMovieClip("frontHalfMC",300);
   this.windowMC.orbitalPlaneMC.createEmptyMovieClip("containerMC",100);
   this.windowMC.orbitalPlaneMC.containerMC.createEmptyMovieClip("gridMC",100);
   this.windowMC.orbitalPlaneMC.containerMC.createEmptyMovieClip("path1MC",200);
   this.windowMC.orbitalPlaneMC.containerMC.createEmptyMovieClip("path2MC",300);
   this.windowMC.frontHalfMC.createEmptyMovieClip("body1MC",100);
   this.windowMC.frontHalfMC.createEmptyMovieClip("body2MC",200);
   this.windowMC.frontHalfMC.createEmptyMovieClip("regionAMC",250);
   this.windowMC.frontHalfMC.createEmptyMovieClip("regionBMC",150);
   this.windowMC.frontHalfMC.createEmptyMovieClip("regionCMC",50);
   this.windowMC.frontHalfMC.body1MC.createEmptyMovieClip("objectEquatorMC",2);
   this.windowMC.frontHalfMC.body2MC.createEmptyMovieClip("objectEquatorMC",2);
   this.windowMC.frontHalfMC.createEmptyMovieClip("mask1MC",500);
   this.windowMC.frontHalfMC.createEmptyMovieClip("mask2MC",600);
   this.windowMC.backHalfMC.createEmptyMovieClip("body1MC",100);
   this.windowMC.backHalfMC.createEmptyMovieClip("body2MC",200);
   this.windowMC.backHalfMC.createEmptyMovieClip("regionAMC",250);
   this.windowMC.backHalfMC.createEmptyMovieClip("regionBMC",150);
   this.windowMC.backHalfMC.createEmptyMovieClip("regionCMC",50);
   this._constants = {};
   this.setIcon(1,null);
   this.setIcon(2,null);
   this.backgroundStyle = {color:this.initBackgroundColor,alpha:100};
   this.orbitalPathsStyle = {thickness:1,color:this.initOrbitalPathsColor,alpha:100};
   this.arrowStyle = {thickness:2,color:this.initArrowColor,alpha:100};
   this.borderStyle = {thickness:1,color:this.initBorderColor,alpha:100};
   this.gridFillStyle = {color:this.initOrbitalPlaneColor,alpha:this.initOrbitalPlaneAlpha};
   this.gridLineStyle = {thickness:1,color:9474192};
   this.axisGridLineStyle = {thickness:1,color:5089613,alpha:65};
   this.minGridLineAlpha = 5;
   this.maxGridLineAlpha = 50;
   this.minGridSpacing = 20;
   var initObject = {phase:this.initPhase,separation:this.initSeparation,eccentricity:this.initEccentricity,mass1:this.initMass1,mass2:this.initMass2,radius1:this.initRadius1,radius2:this.initRadius2,temperature1:this.initTemp1,temperature2:this.initTemp2,phi:this.initPhi,theta:this.initTheta,showOrbitalPlane:this.initShowOrbitalPlane,showOrbitalPaths:this.initShowOrbitalPaths,autoScale:true,targetSize:this.windowWidth - 2 * this._margin,margin:this._margin,linePhi:this.initArrowPhi,lineTheta:this.initArrowTheta,showLine:this.initShowArrow,allowDragging:this.initAllowDragging,lineExtra:10};
   this.setParameters(initObject);
   this.updateBackground();
   this.animationRate = this.initAnimationRate;
   this.animate = this.initAnimate;
}
var p = BinarySystemComponentClass.prototype = new MovieClip();
Object.registerClass("Binary System Component",BinarySystemComponentClass);
p._margin = 15;
p.updateLine = function()
{
   function getRegion(u)
   {
      var mx = u * xe;
      var my = u * ye;
      var mz = u * ze;
      if(pow(mx - xf,2) + pow(my - yf,2) + pow(mz - zf,2) < rf2)
      {
         return null;
      }
      if(pow(mx - xb,2) + pow(my - yb,2) + pow(mz - zb,2) < rb2)
      {
         return null;
      }
      if(mz >= zf)
      {
         return mcA;
      }
      if(mz >= zb)
      {
         return mcB;
      }
      return mcC;
   }
   function sortArr(a, b)
   {
      if(a < b)
      {
         return -1;
      }
      if(a > b)
      {
         return 1;
      }
      return 0;
   }
   this.windowMC.frontHalfMC.regionAMC.clear();
   this.windowMC.frontHalfMC.regionBMC.clear();
   this.windowMC.frontHalfMC.regionCMC.clear();
   this.windowMC.backHalfMC.regionAMC.clear();
   this.windowMC.backHalfMC.regionBMC.clear();
   this.windowMC.backHalfMC.regionCMC.clear();
   if(!this._showLine)
   {
      return undefined;
   }
   var lineTheta = this._lineTheta * 0.017453292519943295;
   var linePhi = this._linePhi * 0.017453292519943295;
   var lineLength = (this._lineExtra + this._targetSize / 2) / this._scale;
   if(linePhi == 0 || linePhi > 0 && this._phi > 0 || linePhi < 0 && this._phi <= 0)
   {
      var mcA = this.windowMC.frontHalfMC.regionAMC;
      var mcB = this.windowMC.frontHalfMC.regionBMC;
      var mcC = this.windowMC.frontHalfMC.regionCMC;
   }
   else
   {
      var mcA = this.windowMC.backHalfMC.regionAMC;
      var mcB = this.windowMC.backHalfMC.regionBMC;
      var mcC = this.windowMC.backHalfMC.regionCMC;
   }
   mcA.lineStyle(this.arrowStyle.thickness,this.arrowStyle.color,this.arrowStyle.alpha);
   mcB.lineStyle(this.arrowStyle.thickness,this.arrowStyle.color,this.arrowStyle.alpha);
   mcC.lineStyle(this.arrowStyle.thickness,this.arrowStyle.color,this.arrowStyle.alpha);
   var k1 = - Math.sin(lineTheta);
   var k4 = Math.cos(lineTheta);
   var k6 = Math.sin(linePhi);
   var k0 = k4 * Math.cos(linePhi);
   var k3 = (- k1) * Math.cos(linePhi);
   var x = lineLength * k0;
   var y = lineLength * k3;
   var z = lineLength * k6;
   var c = this._constants;
   var xe = x * c.a0 + y * c.a1;
   var ye = x * c.a3 + y * c.a4 + z * c.a5;
   var ze = x * c.a6 + y * c.a7 + z * c.a8;
   var r1 = this._radius1 * this._scale;
   var r2 = this._radius2 * this._scale;
   var x1 = this._s1.x;
   var y1 = this._s1.y;
   var z1 = this._s1.z;
   var x2 = this._s2.x;
   var y2 = this._s2.y;
   var z2 = this._s2.z;
   if(z1 > z2)
   {
      var xf = x1;
      var yf = y1;
      var zf = z1;
      var xb = x2;
      var yb = y2;
      var zb = z2;
      var rf2 = r1 * r1;
      var rb2 = r2 * r2;
   }
   else
   {
      var xf = x2;
      var yf = y2;
      var zf = z2;
      var xb = x1;
      var yb = y1;
      var zb = z1;
      var rf2 = r2 * r2;
      var rb2 = r1 * r1;
   }
   var sqrt = Math.sqrt;
   var pow = Math.pow;
   var uArr = [0,1];
   var a = xe * xe + ye * ye + ze * ze;
   var bf = -2 * (xe * xf + ye * yf + ze * zf);
   var cf = xf * xf + yf * yf + zf * zf - rf2;
   var bb = -2 * (xe * xb + ye * yb + ze * zb);
   var cb = xb * xb + yb * yb + zb * zb - rb2;
   var df = bf * bf - 4 * a * cf;
   var db = bb * bb - 4 * a * cb;
   if(df > 0)
   {
      uArr.push((- bf + sqrt(df)) / (2 * a));
      uArr.push((- bf - sqrt(df)) / (2 * a));
   }
   if(db > 0)
   {
      uArr.push((- bb + sqrt(db)) / (2 * a));
      uArr.push((- bb - sqrt(db)) / (2 * a));
   }
   if(ze != 0)
   {
      uArr.push(zf / ze);
      uArr.push(zb / ze);
   }
   uArr.sort(sortArr);
   var ux = 0;
   var uy = 0;
   var lu = 0;
   var nu = uArr[0];
   var i = 0;
   while(uArr[i] != 1 && i < uArr.length)
   {
      lu = nu;
      var nu = uArr[i + 1];
      if(lu >= 0)
      {
         var mc = getRegion(lu + (nu - lu) / 2);
         mc.moveTo(ux,uy);
         var ux = nu * xe;
         var uy = nu * ye;
         mc.lineTo(ux,uy);
      }
      i++;
   }
   var arrowX = (this._lineExtra + this._targetSize / 2 - 0.6666666666666666 * this._lineExtra) / this._scale;
   var arrowY1 = 0.25 * this._lineExtra / this._scale;
   var arrowY2 = - arrowY1;
   var a1x = k0 * arrowX + k1 * arrowY1;
   var a1y = k3 * arrowX + k4 * arrowY1;
   var a2x = k0 * arrowX + k1 * arrowY2;
   var a2y = k3 * arrowX + k4 * arrowY2;
   var az = k6 * arrowX;
   var x1 = a1x * c.a0 + a1y * c.a1;
   var y1 = a1x * c.a3 + a1y * c.a4 + az * c.a5;
   var z1 = a1x * c.a6 + a1y * c.a7 + az * c.a8;
   var x2 = a2x * c.a0 + a2y * c.a1;
   var y2 = a2x * c.a3 + a2y * c.a4 + az * c.a5;
   var z2 = a2x * c.a6 + a2y * c.a7 + az * c.a8;
   var mc = getRegion(1);
   mc.moveto(x1,y1);
   mc.lineTo(xe,ye);
   mc.lineto(x2,y2);
};
p.setParameters = function(paramsObject)
{
   if(paramsObject.autoScale != undefined)
   {
      this._autoScale = Boolean(paramsObject.autoScale);
   }
   if(paramsObject.targetSize != undefined)
   {
      this._targetSize = paramsObject.targetSize;
   }
   if(paramsObject.margin != undefined)
   {
      this._margin = paramsObject.margin;
   }
   if(paramsObject.showOrbitalPaths != undefined)
   {
      this._showOrbitalPaths = Boolean(paramsObject.showOrbitalPaths);
   }
   if(paramsObject.showOrbitalPlane != undefined)
   {
      this._showOrbitalPlane = Boolean(paramsObject.showOrbitalPlane);
   }
   if(paramsObject.phi != undefined && !(paramsObject.phi < -90 || paramsObject.phi > 90))
   {
      this._phi = paramsObject.phi * 0.017453292519943295;
   }
   if(paramsObject.theta != undefined)
   {
      this._theta = paramsObject.theta * 0.017453292519943295;
   }
   if(paramsObject.scale != undefined)
   {
      this._scale = paramsObject.scale;
   }
   if(paramsObject.phase != undefined)
   {
      this._phase = (paramsObject.phase % 1 + 1) % 1;
   }
   if(paramsObject.radius1 != undefined)
   {
      this._radius1 = paramsObject.radius1;
   }
   if(paramsObject.radius2 != undefined)
   {
      this._radius2 = paramsObject.radius2;
   }
   if(paramsObject.eccentricity != undefined)
   {
      this._eccentricity = paramsObject.eccentricity;
   }
   if(paramsObject.mass1 != undefined)
   {
      this._mass1 = paramsObject.mass1;
   }
   if(paramsObject.mass2 != undefined)
   {
      this._mass2 = paramsObject.mass2;
   }
   if(paramsObject.temperature1 != undefined)
   {
      this.temperature1 = paramsObject.temperature1;
   }
   if(paramsObject.temperature2 != undefined)
   {
      this.temperature2 = paramsObject.temperature2;
   }
   if(paramsObject.separation != undefined)
   {
      this._separation = paramsObject.separation;
   }
   if(paramsObject.linePhi != undefined)
   {
      this._linePhi = paramsObject.linePhi;
   }
   if(paramsObject.lineTheta != undefined)
   {
      this._lineTheta = paramsObject.lineTheta;
   }
   if(paramsObject.showLine != undefined)
   {
      this._showLine = Boolean(paramsObject.showLine);
   }
   if(paramsObject.allowDragging != undefined)
   {
      this.allowDragging = paramsObject.allowDragging;
   }
   if(paramsObject.lineExtra != undefined)
   {
      this._lineExtra = paramsObject.lineExtra;
   }
   this._massTotal = this._mass1 + this._mass2;
   this._a1 = this._separation * this._mass2 / this._massTotal;
   this._a2 = this._separation * this._mass1 / this._massTotal;
   if(this._autoScale)
   {
      this.rescale();
   }
   else
   {
      this.doA();
      this.resizeIcon(1);
      this.resizeIcon(2);
      this.updateMask(1);
      this.updateMask(2);
      this.updateOrbitalPaths();
      this.updateOrbitalPlane();
      this.updatePositions();
      this.updateLine();
   }
};
p.updateBackground = function()
{
   var w = this.windowWidth;
   var h = this.windowHeight;
   this.windowMC._x = w / 2;
   this.windowMC._y = h / 2;
   var mc = this.backgroundMC;
   mc.clear();
   mc.moveTo(0,0);
   mc.beginFill(this.backgroundStyle.color,this.backgroundStyle.alpha);
   mc.lineTo(w,0);
   mc.lineTo(w,h);
   mc.lineTo(0,h);
   mc.lineTo(0,0);
   mc.endFill();
   var mc = this.maskMC;
   mc.clear();
   mc.moveTo(0,0);
   mc.beginFill(16711680,100);
   mc.lineTo(w,0);
   mc.lineTo(w,h);
   mc.lineTo(0,h);
   mc.lineTo(0,0);
   mc.endFill();
   var mc = this.borderMC;
   mc.clear();
   mc.lineStyle(this.borderStyle.thickness,this.borderStyle.color,this.borderStyle.alpha);
   mc.moveTo(0,0);
   mc.lineTo(w,0);
   mc.lineTo(w,h);
   mc.lineTo(0,h);
   mc.lineTo(0,0);
};
p.updatePositions = function()
{
   var sin = Math.sin;
   var cos = Math.cos;
   var abs = Math.abs;
   var ma = this._phase * 6.283185307179586;
   var e = this._eccentricity;
   var ea0 = 0;
   var ea1 = ma;
   var iCount = 0;
   do
   {
      ea0 = ea1;
      ea1 = ea0 + (ma + e * sin(ea0) - ea0) / (1 - e * cos(ea0));
      iCount++;
   }
   while(abs(ea1 - ea0) > 0.001 && iCount < 100);
   var ta = 2 * Math.atan(Math.sqrt((1 + e) / (1 - e)) * Math.tan(ea1 / 2));
   var cosTa = cos(ta);
   var sinTa = sin(ta);
   var k = (1 - e * e) / (1 + e * cosTa);
   var r1 = this._a1 * k;
   var r2 = this._a2 * k;
   var wx1 = (- r1) * cosTa;
   var wy1 = (- r1) * sinTa;
   var wx2 = r2 * cosTa;
   var wy2 = r2 * sinTa;
   var c = this._constants;
   var sx1 = wx1 * c.a0 + wy1 * c.a1;
   var sy1 = wx1 * c.a3 + wy1 * c.a4 + 0 * c.a5;
   var sz1 = wx1 * c.a6 + wy1 * c.a7 + 0 * c.a8;
   var sx2 = wx2 * c.a0 + wy2 * c.a1;
   var sy2 = wx2 * c.a3 + wy2 * c.a4 + 0 * c.a5;
   var sz2 = wx2 * c.a6 + wy2 * c.a7 + 0 * c.a8;
   this._s1 = {x:sx1,y:sy1,z:sz1};
   this._s2 = {x:sx2,y:sy2,z:sz2};
   this.windowMC.backHalfMC.body1MC._x = this.windowMC.frontHalfMC.body1MC._x = this.windowMC.frontHalfMC.mask1MC._x = sx1;
   this.windowMC.backHalfMC.body1MC._y = this.windowMC.frontHalfMC.body1MC._y = this.windowMC.frontHalfMC.mask1MC._y = sy1;
   this.windowMC.backHalfMC.body2MC._x = this.windowMC.frontHalfMC.body2MC._x = this.windowMC.frontHalfMC.mask2MC._x = sx2;
   this.windowMC.backHalfMC.body2MC._y = this.windowMC.frontHalfMC.body2MC._y = this.windowMC.frontHalfMC.mask2MC._y = sy2;
   if(sz1 > sz2)
   {
      this.windowMC.frontHalfMC.body1MC.swapDepths(200);
      this.windowMC.backHalfMC.body1MC.swapDepths(200);
   }
   else
   {
      this.windowMC.frontHalfMC.body2MC.swapDepths(200);
      this.windowMC.backHalfMC.body2MC.swapDepths(200);
   }
};
p.updateOrbitalPaths = function()
{
   var cos = Math.cos;
   var sin = Math.sin;
   this.windowMC.orbitalPlaneMC._yscale = 100 * sin(this._phi);
   this.windowMC.orbitalPlaneMC.containerMC._rotation = 90 + this._theta * 57.29577951308232;
   var path1 = this.windowMC.orbitalPlaneMC.containerMC.path1MC;
   var path2 = this.windowMC.orbitalPlaneMC.containerMC.path2MC;
   path1.clear();
   path2.clear();
   if(!this._showOrbitalPaths)
   {
      return undefined;
   }
   path1.lineStyle(this.orbitalPathsStyle.thickness,this.orbitalPathsStyle.color,this.orbitalPathsStyle.alpha);
   path2.lineStyle(this.orbitalPathsStyle.thickness,this.orbitalPathsStyle.color,this.orbitalPathsStyle.alpha);
   var s = this._scale;
   var e = this._eccentricity;
   var n = 12;
   var step = 6.283185307179586 / n;
   var a1 = this._a1;
   var a2 = this._a2;
   var k = Math.sqrt(1 - e * e);
   var b1 = a1 * k;
   var b2 = a2 * k;
   var aa1 = s * a1;
   var ab1 = s * b1;
   var aa2 = s * a2;
   var ab2 = s * b2;
   var k = 1 / cos(step / 2);
   var ca1 = aa1 * k;
   var cb1 = ab1 * k;
   var ca2 = aa2 * k;
   var cb2 = ab2 * k;
   var dx1 = aa1 * e;
   var dx2 = (- aa2) * e;
   var aAngle = 0;
   var cAngle = (- step) / 2;
   var ax1 = aa1 * cos(aAngle) + dx1;
   var ay1 = ab1 * sin(aAngle);
   var ax2 = aa2 * cos(aAngle) + dx2;
   var ay2 = ab2 * sin(aAngle);
   path1.moveTo(ax1,ay1);
   path2.moveTo(ax2,ay2);
   var i = 0;
   while(i < n)
   {
      aAngle += step;
      cAngle += step;
      var ccA = cos(cAngle);
      var scA = sin(cAngle);
      var caA = cos(aAngle);
      var saA = sin(aAngle);
      path1.curveTo(ca1 * ccA + dx1,cb1 * scA,aa1 * caA + dx1,ab1 * saA);
      path2.curveTo(ca2 * ccA + dx2,cb2 * scA,aa2 * caA + dx2,ab2 * saA);
      i++;
   }
};
p.updateOrbitalPlane = function()
{
   var grid = this.windowMC.orbitalPlaneMC.containerMC.gridMC;
   grid.clear();
   this.windowMC.frontHalfMC.body1MC.objectEquatorMC._visible = this.windowMC.frontHalfMC.body2MC.objectEquatorMC._visible = this._showOrbitalPlane;
   if(!this._showOrbitalPlane)
   {
      return undefined;
   }
   var ceil = Math.ceil;
   var s = this._scale;
   var e = this._eccentricity;
   var a1 = this._a1;
   var a2 = this._a2;
   var k = Math.sqrt(1 - e * e);
   var b1 = a1 * k;
   var b2 = a2 * k;
   var r1 = this._radius1;
   var r2 = this._radius2;
   var leftFillExtent = - Math.max(a2 * (1 + e) + 1.75 * r2,a1 * (1 - e) + 1.75 * r1);
   var rightFillExtent = Math.max(a1 * (1 + e) + 1.75 * r1,a2 * (1 - e) + 1.75 * r2);
   var topFillExtent = Math.max(b1 + 1.75 * r1,b2 + 1.75 * r2);
   var bottomFillExtent = - topFillExtent;
   var leftX = s * leftFillExtent;
   var rightX = s * rightFillExtent;
   var topY = s * topFillExtent;
   var bottomY = s * bottomFillExtent;
   grid.moveTo(leftX,bottomY);
   grid.lineStyle(1,16711680,0);
   grid.beginFill(this.gridFillStyle.color,this.gridFillStyle.alpha);
   grid.lineTo(leftX,topY);
   grid.lineTo(rightX,topY);
   grid.lineTo(rightX,bottomY);
   grid.lineTo(leftX,bottomY);
   grid.endFill();
   var m = this.minGridSpacing / s;
   var lg = Math.log(m) / 2.302585092994046;
   var k = ceil(lg);
   if(k - lg > 0.30102999566398114)
   {
      var belowSpacing = Math.pow(10,k - 1);
      var spacing = 5 * belowSpacing;
      var majorMultiple = 2;
   }
   else
   {
      var spacing = Math.pow(10,k);
      var belowSpacing = 0.5 * spacing;
      var majorMultiple = 5;
   }
   var leftGridExtent = ceil(leftFillExtent / spacing);
   var rightGridLimit = ceil(rightFillExtent / spacing);
   var topGridLimit = ceil(topFillExtent / spacing);
   var bottomGridExtent = ceil(bottomFillExtent / spacing);
   var minorAlpha = this.minGridLineAlpha + (this.maxGridLineAlpha - this.minGridLineAlpha) * (spacing - m) / (spacing - belowSpacing);
   var majorAlpha = this.maxGridLineAlpha;
   var gridThickness = this.gridLineStyle.thickness;
   var gridColor = this.gridLineStyle.color;
   var originThickness = this.axisGridLineStyle.thickness;
   var originColor = this.axisGridLineStyle.color;
   var originAlpha = this.axisGridLineStyle.alpha;
   var i = leftGridExtent;
   while(i < rightGridLimit)
   {
      var x = i * spacing * s;
      if(i == 0)
      {
         grid.lineStyle(originThickness,originColor,originAlpha);
      }
      else if(i % majorMultiple == 0)
      {
         grid.lineStyle(gridThickness,gridColor,majorAlpha);
      }
      else
      {
         grid.lineStyle(gridThickness,gridColor,minorAlpha);
      }
      grid.moveTo(x,bottomY);
      grid.lineTo(x,topY);
      i++;
   }
   var i = bottomGridExtent;
   while(i < topGridLimit)
   {
      var y = i * spacing * s;
      if(i == 0)
      {
         grid.lineStyle(originThickness,originColor,originAlpha);
      }
      else if(i % majorMultiple == 0)
      {
         grid.lineStyle(gridThickness,gridColor,majorAlpha);
      }
      else
      {
         grid.lineStyle(gridThickness,gridColor,minorAlpha);
      }
      grid.moveTo(leftX,y);
      grid.lineto(rightX,y);
      i++;
   }
};
p.updateMask = function(arg)
{
   var mc = this.windowMC.frontHalfMC["mask" + arg + "MC"];
   var aRad = this._scale * this["_radius" + arg];
   mc.clear();
   var cos = Math.cos;
   var sin = Math.sin;
   var n = 12;
   var hn = n / 2;
   var step = 6.283185307179586 / n;
   var cRad = aRad / cos(step / 2);
   var aAngle = 0;
   var cAngle = (- step) / 2;
   mc.moveTo(aRad * cos(aAngle),(- aRad) * sin(aAngle));
   mc.beginFill(16711680,100);
   if(this._phi > 0)
   {
      var ak = - aRad;
      var ck = - cRad;
   }
   else
   {
      var ak = aRad;
      var ck = cRad;
   }
   var i = 0;
   while(i < hn)
   {
      aAngle += step;
      cAngle += step;
      mc.curveTo(cRad * cos(cAngle),ck * sin(cAngle),aRad * cos(aAngle),ak * sin(aAngle));
      i++;
   }
   var ak = (- aRad) * sin(this._phi);
   var ck = (- cRad) * sin(this._phi);
   var equatorMC = this.windowMC.frontHalfMC["body" + arg + "MC"].objectEquatorMC;
   equatorMC.clear();
   equatorMC.lineStyle(1,this.gridFillStyle.color,2 * this.gridFillStyle.alpha);
   equatorMC.moveTo(- aRad,0);
   var i = hn;
   while(i < n)
   {
      aAngle += step;
      cAngle += step;
      var cx = cRad * cos(cAngle);
      var cy = ck * sin(cAngle);
      var ax = aRad * cos(aAngle);
      var ay = ak * sin(aAngle);
      mc.curveTo(cx,cy,ax,ay);
      equatorMC.curveTo(cx,cy,ax,ay);
      i++;
   }
   mc.endFill();
};
p.rescale = function()
{
   var h = Math.max(this._a1 * (1 + this._eccentricity) + this._radius1,this._a2 * (1 + this._eccentricity) + this._radius2);
   this.setScale(this._targetSize / (2 * h));
};
p.doA = function()
{
   var c = this._constants;
   var ct = Math.cos(this._theta);
   var st = Math.sin(this._theta);
   var cp = Math.cos(this._phi);
   var sp = Math.sin(this._phi);
   var s = this._scale;
   c.a0 = (- s) * st;
   c.a1 = s * ct;
   c.a3 = s * ct * sp;
   c.a4 = s * st * sp;
   c.a5 = (- s) * cp;
   c.a6 = s * ct * cp;
   c.a7 = s * st * cp;
   c.a8 = s * sp;
};
p.WtoSz = function(p, sp)
{
   var c = this._constants;
   sp.x = p.x * c.a0 + p.y * c.a1;
   sp.y = p.x * c.a3 + p.y * c.a4 + p.z * c.a5;
   sp.z = p.x * c.a6 + p.y * c.a7 + p.z * c.a8;
};
p.pauseAnimation = function()
{
   this.setAnimate(false);
};
p.startAnimation = function()
{
   this.setAnimate(true);
};
p.getAnimate = function()
{
   return this.onEnterFrame != undefined;
};
p.setAnimate = function(arg)
{
   if(arg)
   {
      this.timeLast = getTimer();
      this.onEnterFrame = this.onEnterFrameFunc;
   }
   else
   {
      delete this.onEnterFrame;
   }
};
p.addProperty("animate",p.getAnimate,p.setAnimate);
p.onEnterFrameFunc = function()
{
   var timeNow = getTimer();
   this.phase = (this._phase + this.animationRate * (timeNow - this.timeLast) / 1000) % 1;
   this.timeLast = timeNow;
};
p.getPhase = function()
{
   return this._phase;
};
p.setPhase = function(arg)
{
   this._phase = (arg % 1 + 1) % 1;
   this.updatePositions();
   this.updateLine();
};
p.addProperty("phase",p.getPhase,p.setPhase);
p.getSeparation = function()
{
   return this._separation;
};
p.setSeparation = function(arg)
{
   this._separation = arg;
   this._a1 = this._separation * this._mass2 / this._massTotal;
   this._a2 = this._separation * this._mass1 / this._massTotal;
   if(this._autoScale)
   {
      this.rescale();
   }
   else
   {
      this.updateOrbitalPaths();
      this.updateOrbitalPlane();
      this.updatePositions();
      this.updateLine();
   }
};
p.addProperty("separation",p.getSeparation,p.setSeparation);
p.getEccentricity = function()
{
   return this._eccentricity;
};
p.setEccentricity = function(arg)
{
   this._eccentricity = arg;
   if(this._autoScale)
   {
      this.rescale();
   }
   else
   {
      this.updateOrbitalPaths();
      this.updateOrbitalPlane();
      this.updatePositions();
      this.updateLine();
   }
};
p.addProperty("eccentricity",p.getEccentricity,p.setEccentricity);
p.getMass1 = function()
{
   return this._mass1;
};
p.setMass1 = function(arg)
{
   this._mass1 = arg;
   this._massTotal = this._mass1 + this._mass2;
   this._a1 = this._separation * this._mass2 / this._massTotal;
   this._a2 = this._separation * this._mass1 / this._massTotal;
   if(this._autoScale)
   {
      this.rescale();
   }
   else
   {
      this.updateOrbitalPaths();
      this.updateOrbitalPlane();
      this.updatePositions();
      this.updateLine();
   }
};
p.addProperty("mass1",p.getMass1,p.setMass1);
p.getMass2 = function()
{
   return this._mass2;
};
p.setMass2 = function(arg)
{
   this._mass2 = arg;
   this._massTotal = this._mass1 + this._mass2;
   this._a1 = this._separation * this._mass2 / this._massTotal;
   this._a2 = this._separation * this._mass1 / this._massTotal;
   if(this._autoScale)
   {
      this.rescale();
   }
   else
   {
      this.updateOrbitalPaths();
      this.updateOrbitalPlane();
      this.updatePositions();
      this.updateLine();
   }
};
p.addProperty("mass2",p.getMass2,p.setMass2);
p.getRadius1 = function()
{
   return this._radius1;
};
p.setRadius1 = function(arg)
{
   this._radius1 = arg;
   if(this._autoScale)
   {
      this.rescale();
   }
   else
   {
      this.updateOrbitalPlane();
      this.resizeIcon(1);
      this.updateMask(1);
      this.updateLine();
   }
};
p.addProperty("radius1",p.getRadius1,p.setRadius1);
p.getRadius2 = function()
{
   return this._radius2;
};
p.setRadius2 = function(arg)
{
   this._radius2 = arg;
   if(this._autoScale)
   {
      this.rescale();
   }
   else
   {
      this.updateOrbitalPlane();
      this.resizeIcon(2);
      this.updateMask(2);
      this.updateLine();
   }
};
p.addProperty("radius2",p.getRadius2,p.setRadius2);
p.getTemperature1 = function()
{
   return this._temp1;
};
p.setTemperature1 = function(arg)
{
   this._temp1 = arg;
   this.color1 = this.getColorFromTemp(this._temp1);
};
p.addProperty("temperature1",p.getTemperature1,p.setTemperature1);
p.getColor1 = function()
{
   return this._color1;
};
p.setColor1 = function(arg)
{
   this._color1 = arg;
   this.passObjectToIcon(1,{color:this._color1});
};
p.addProperty("color1",p.getColor1,p.setColor1);
p.getTemperature2 = function()
{
   return this._temp2;
};
p.setTemperature2 = function(arg)
{
   this._temp2 = arg;
   this.color2 = this.getColorFromTemp(this._temp2);
};
p.addProperty("temperature2",p.getTemperature2,p.setTemperature2);
p.getColor2 = function()
{
   return this._color2;
};
p.setColor2 = function(arg)
{
   this._color2 = arg;
   this.passObjectToIcon(2,{color:this._color2});
};
p.addProperty("color2",p.getColor2,p.setColor2);
p.setThetaAndPhi = function(arg1, arg2)
{
   this._theta = arg1 * 0.017453292519943295;
   this._phi = arg2 * 0.017453292519943295;
   this.doA();
   this.updateMask(1);
   this.updateMask(2);
   this.updateOrbitalPaths();
   this.updatePositions();
   this.updateLine();
};
p.getPhi = function()
{
   return this._phi * 57.29577951308232;
};
p.setPhi = function(arg)
{
   if(arg < -90 || arg > 90)
   {
      return undefined;
   }
   this._phi = arg * 0.017453292519943295;
   this.doA();
   this.updateMask(1);
   this.updateMask(2);
   this.updateOrbitalPaths();
   this.updatePositions();
   this.updateLine();
};
p.addProperty("phi",p.getPhi,p.setPhi);
p.getTheta = function()
{
   return this._theta * 57.29577951308232;
};
p.setTheta = function(arg)
{
   this._theta = arg * 0.017453292519943295;
   this.doA();
   this.updateOrbitalPaths();
   this.updatePositions();
   this.updateLine();
};
p.addProperty("theta",p.getTheta,p.setTheta);
p.getAllowDragging = function()
{
   return this.backgroundMC.onPress != undefined;
};
p.setAllowDragging = function(arg)
{
   if(arg)
   {
      this.backgroundMC.onPress = this.backgroundMC.onPressFunc;
      this.backgroundMC.onRelease = this.backgroundMC.onReleaseFunc;
      this.backgroundMC.onReleaseOutside = this.backgroundMC.onReleaseFunc;
   }
   else
   {
      delete this.backgroundMC.onPress;
      delete this.backgroundMC.onRelease;
      delete this.backgroundMC.onReleaseOutside;
   }
};
p.addProperty("allowDragging",p.getAllowDragging,p.setAllowDragging);
p.getScale = function()
{
   return this._scale;
};
p.setScale = function(arg)
{
   this._scale = arg;
   this.doA();
   this.resizeIcon(1);
   this.resizeIcon(2);
   this.updateMask(1);
   this.updateMask(2);
   this.updateOrbitalPaths();
   this.updateOrbitalPlane();
   this.updatePositions();
   this.updateLine();
};
p.addProperty("scale",p.getScale,p.setScale);
p.getAutoScale = function()
{
   return this._autoScale;
};
p.setAutoScale = function(arg)
{
   this._autoScale = Boolean(arg);
   if(this._autoScale)
   {
      this.rescale();
   }
};
p.addProperty("autoScale",p.getAutoScale,p.setAutoScale);
p.getTargetSize = function()
{
   return this._targetSize;
};
p.setTargetSize = function(arg)
{
   this._targetSize = arg;
   if(this._autoScale)
   {
      this.rescale();
   }
   else
   {
      this.updateLine();
   }
};
p.addProperty("targetSize",p.getTargetSize,p.setTargetSize);
p.getShowOrbitalPlane = function()
{
   return this._showOrbitalPlane;
};
p.setShowOrbitalPlane = function(arg)
{
   this._showOrbitalPlane = Boolean(arg);
   this.updateOrbitalPlane();
};
p.addProperty("showOrbitalPlane",p.getShowOrbitalPlane,p.setShowOrbitalPlane);
p.getShowOrbitalPaths = function()
{
   return this._showOrbitalPaths;
};
p.setShowOrbitalPaths = function(arg)
{
   this._showOrbitalPaths = Boolean(arg);
   this.updateOrbitalPaths();
};
p.addProperty("showOrbitalPaths",p.getShowOrbitalPaths,p.setShowOrbitalPaths);
p.getLineExtra = function()
{
   return this._lineExtra;
};
p.setLineExtra = function(arg)
{
   this._lineExtra = arg;
   this.updateLine();
};
p.addProperty("lineExtra",p.getLineExtra,p.setLineExtra);
p.getLineTheta = function()
{
   return this._lineTheta;
};
p.setLineTheta = function(arg)
{
   this._lineTheta = arg;
   this.updateLine();
};
p.addProperty("lineTheta",p.getLineTheta,p.setLineTheta);
p.addProperty("arrowTheta",p.getLineTheta,p.setLineTheta);
p.getLinePhi = function()
{
   return this._linePhi;
};
p.setLinePhi = function(arg)
{
   this._linePhi = arg;
   this.updateLine();
};
p.addProperty("linePhi",p.getLinePhi,p.setLinePhi);
p.addProperty("arrowPhi",p.getLinePhi,p.setLinePhi);
p.getShowLine = function()
{
   return this._showLine;
};
p.setShowLine = function(arg)
{
   this._showLine = Boolean(arg);
   this.updateLine();
};
p.addProperty("showLine",p.getShowLine,p.setShowLine);
p.addProperty("showArrow",p.getShowLine,p.setShowLine);
p.setIcon = function(num, name)
{
   var str = "body" + num + "MC";
   if(name != null && name != undefined)
   {
      this.windowMC.backHalfMC[str].attachMovie(name,"iconMC",1);
      var fmc = this.windowMC.frontHalfMC[str];
      fmc.attachMovie(name,"iconMC",1);
   }
   else
   {
      var bmc = this.windowMC.backHalfMC[str];
      bmc.createEmptyMovieClip("iconMC",1);
      bmc.iconMC.createEmptyMovieClip("diskMC",1);
      bmc.iconMC.createEmptyMovieClip("shadingMC",2);
      bmc.iconMC.diskMC.beginFill(10551200,100);
      this.drawCircle(bmc.iconMC.diskMC,0,0,100);
      bmc.iconMC.diskMC.endFill();
      bmc.iconMC.shadingMC.beginGradientFill("radial",[16777215,16777215,16777215],[55,45,10],[0,170,255],{matrixType:"box",x:-100,y:-100,w:200,h:200,r:0});
      this.drawCircle(bmc.iconMC.shadingMC,0,0,100);
      bmc.iconMC.shadingMC.endFill();
      bmc.iconMC.diskColorObj = new Color(bmc.iconMC.diskMC);
      bmc.iconMC.acceptObject = function(arg)
      {
         this.diskColorObj.setRGB(arg.color);
      };
      var fmc = this.windowMC.frontHalfMC[str];
      fmc.createEmptyMovieClip("iconMC",1);
      fmc.iconMC.createEmptyMovieClip("diskMC",1);
      fmc.iconMC.createEmptyMovieClip("shadingMC",2);
      fmc.iconMC.diskMC.beginFill(10526975,100);
      this.drawCircle(fmc.iconMC.diskMC,0,0,100);
      fmc.iconMC.diskMC.endFill();
      fmc.iconMC.shadingMC.beginGradientFill("radial",[16777215,16777215,16777215],[55,45,10],[0,170,255],{matrixType:"box",x:-100,y:-100,w:200,h:200,r:0});
      this.drawCircle(fmc.iconMC.shadingMC,0,0,100);
      fmc.iconMC.shadingMC.endFill();
      fmc.iconMC.diskColorObj = new Color(fmc.iconMC.diskMC);
      fmc.iconMC.acceptObject = function(arg)
      {
         this.diskColorObj.setRGB(arg.color);
      };
   }
   fmc.setMask(this.windowMC.frontHalfMC["mask" + num + "MC"]);
   this["_icon" + num + "Radius"] = fmc.iconMC._width / 2;
   this.resizeIcon(num);
   this.updatePositions();
};
p.passObjectToIcon = function(num, obj)
{
   var str = "body" + num + "MC";
   this.windowMC.backHalfMC[str].iconMC.acceptObject(obj);
   this.windowMC.frontHalfMC[str].iconMC.acceptObject(obj);
};
p.resizeIcon = function(arg)
{
   var bmc = this.windowMC.backHalfMC["body" + arg + "MC"].iconMC;
   var fmc = this.windowMC.frontHalfMC["body" + arg + "MC"].iconMC;
   var scalingFactor = 100 * this._scale * this["_radius" + arg] / this["_icon" + arg + "Radius"];
   bmc._xscale = bmc._yscale = fmc._xscale = fmc._yscale = scalingFactor;
};
p.getColorFromTemp = function(temp)
{
   if(temp < 1000)
   {
      temp = 1000;
   }
   else if(temp > 40000)
   {
      temp = 40000;
   }
   var logT = Math.log(temp) / 2.302585092994046;
   var logT2 = logT * logT;
   var logT3 = logT * logT2;
   var r = 22686.34111 - logT * 15082.52755 + logT2 * 3375.333832 - logT3 * 252.4073853;
   if(r < 0)
   {
      r = 0;
   }
   else if(r > 255)
   {
      r = 255;
   }
   if(temp <= 6500)
   {
      var g = -811.6499145 + logT * 36.97365953 + logT2 * 160.7861677 - logT3 * 25.57573664;
   }
   else
   {
      var g = 13836.23586 - logT * 9069.078214 + logT2 * 2015.254756 - logT3 * 149.7766966;
   }
   var b = -11545.34298 + logT * 8529.658165 - logT2 * 2150.198586 + logT3 * 190.0306573;
   if(b < 0)
   {
      b = 0;
   }
   else if(b > 255)
   {
      b = 255;
   }
   return r << 16 | g << 8 | b;
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
p.checkForOvercontact = function()
{
   var minSep = (this._radius1 + this._radius2) / (1 - this._eccentricity);
   return this._separation < minSep;
};
