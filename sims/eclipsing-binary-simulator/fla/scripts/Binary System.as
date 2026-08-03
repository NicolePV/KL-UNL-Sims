function BinarySystemClass()
{
   this.createEmptyMovieClip("backHalfMC",100);
   this.createEmptyMovieClip("orbitalPlaneMC",200);
   this.createEmptyMovieClip("frontHalfMC",300);
   this.orbitalPlaneMC.createEmptyMovieClip("containerMC",100);
   this.orbitalPlaneMC.containerMC.createEmptyMovieClip("gridMC",100);
   this.orbitalPlaneMC.containerMC.createEmptyMovieClip("path1MC",200);
   this.orbitalPlaneMC.containerMC.createEmptyMovieClip("path2MC",300);
   this.orbitalPlaneMC.containerMC.attachMovie(this.initCoMMarker,"CoMMC",400);
   this.frontHalfMC.createEmptyMovieClip("body1MC",100);
   this.frontHalfMC.createEmptyMovieClip("body2MC",200);
   this.frontHalfMC.createEmptyMovieClip("regionAMC",250);
   this.frontHalfMC.createEmptyMovieClip("regionBMC",150);
   this.frontHalfMC.createEmptyMovieClip("regionCMC",50);
   this.frontHalfMC.body1MC.createEmptyMovieClip("objectEquatorMC",2);
   this.frontHalfMC.body2MC.createEmptyMovieClip("objectEquatorMC",2);
   this.backHalfMC.createEmptyMovieClip("body1MC",100);
   this.backHalfMC.createEmptyMovieClip("body2MC",200);
   this.backHalfMC.createEmptyMovieClip("regionAMC",250);
   this.backHalfMC.createEmptyMovieClip("regionBMC",150);
   this.backHalfMC.createEmptyMovieClip("regionCMC",50);
   this.frontHalfMC.createEmptyMovieClip("mask1MC",500);
   this.frontHalfMC.createEmptyMovieClip("mask2MC",600);
   this._c = {};
   this.setIcon(1,this.initBodyIcon1);
   this.setIcon(2,this.initBodyIcon2);
   var initObject = {phase:0.4,separation:7.5,eccentricity:0.5,mass1:2,mass2:1.9,radius1:1.5,radius2:1.4,phi:23,theta:130,showOrbitalPlane:true,showOrbitalPaths:true,autoScale:true,targetSize:470,linePhi:5,lineTheta:135,showLine:true,lineExtra:10};
   this.initialize(initObject);
}
var p = BinarySystemClass.prototype = new MovieClip();
Object.registerClass("Binary System",BinarySystemClass);
p.orbitalPathStyle = {thickness:1,color:16777215,alpha:70};
p.gridFillStyle = {color:11579568,alpha:40};
p.gridLineStyle = {thickness:1,color:9474192};
p.axisGridLineStyle = {thickness:1,color:5089613,alpha:65};
p.minGridLineAlpha = 5;
p.maxGridLineAlpha = 50;
p.minGridSpacing = 20;
p.objectEquatorStyle = {thickness:1,color:11579568,alpha:80};
p.lineThickness = 2;
p.lineColor = 16744576;
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
   this.frontHalfMC.regionAMC.clear();
   this.frontHalfMC.regionBMC.clear();
   this.frontHalfMC.regionCMC.clear();
   this.backHalfMC.regionAMC.clear();
   this.backHalfMC.regionBMC.clear();
   this.backHalfMC.regionCMC.clear();
   if(!this._showLine)
   {
      return undefined;
   }
   var lineTheta = this._lineTheta * 0.017453292519943295;
   var linePhi = this._linePhi * 0.017453292519943295;
   var lineLength = (this._lineExtra + this._targetSize / 2) / this._scale;
   if(linePhi == 0 || linePhi > 0 && this._phi > 0 || linePhi < 0 && this._phi <= 0)
   {
      var mcA = this.frontHalfMC.regionAMC;
      var mcB = this.frontHalfMC.regionBMC;
      var mcC = this.frontHalfMC.regionCMC;
   }
   else
   {
      var mcA = this.backHalfMC.regionAMC;
      var mcB = this.backHalfMC.regionBMC;
      var mcC = this.backHalfMC.regionCMC;
   }
   mcA.lineStyle(this.lineThickness,this.lineColor,100);
   mcB.lineStyle(this.lineThickness,this.lineColor,100);
   mcC.lineStyle(this.lineThickness,this.lineColor,100);
   var k1 = - Math.sin(lineTheta);
   var k4 = Math.cos(lineTheta);
   var k6 = Math.sin(linePhi);
   var k0 = k4 * Math.cos(linePhi);
   var k3 = (- k1) * Math.cos(linePhi);
   var x = lineLength * k0;
   var y = lineLength * k3;
   var z = lineLength * k6;
   var c = this._c;
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
p.initialize = function(initObject)
{
   if(initObject.autoScale != undefined)
   {
      this._autoScale = Boolean(initObject.autoScale);
   }
   if(initObject.targetSize != undefined)
   {
      this._targetSize = initObject.targetSize;
   }
   if(initObject.showOrbitalPaths != undefined)
   {
      this._showOrbitalPaths = Boolean(initObject.showOrbitalPaths);
   }
   if(initObject.showOrbitalPlane != undefined)
   {
      this._showOrbitalPlane = Boolean(initObject.showOrbitalPlane);
   }
   if(initObject.phi != undefined && !(initObject.phi < -90 || initObject.phi > 90))
   {
      this._phi = initObject.phi * 0.017453292519943295;
   }
   if(initObject.theta != undefined)
   {
      this._theta = initObject.theta * 0.017453292519943295;
   }
   if(initObject.scale != undefined)
   {
      this._scale = initObject.scale;
   }
   if(initObject.phase != undefined)
   {
      this._phase = (initObject.phase % 1 + 1) % 1;
   }
   if(initObject.radius1 != undefined)
   {
      this._radius1 = initObject.radius1;
   }
   if(initObject.radius2 != undefined)
   {
      this._radius2 = initObject.radius2;
   }
   if(initObject.eccentricity != undefined)
   {
      this._eccentricity = initObject.eccentricity;
   }
   if(initObject.mass1 != undefined)
   {
      this._mass1 = initObject.mass1;
   }
   if(initObject.mass2 != undefined)
   {
      this._mass2 = initObject.mass2;
   }
   if(initObject.separation != undefined)
   {
      this._separation = initObject.separation;
   }
   if(initObject.linePhi != undefined)
   {
      this._linePhi = initObject.linePhi;
   }
   if(initObject.lineTheta != undefined)
   {
      this._lineTheta = initObject.lineTheta;
   }
   if(initObject.showLine != undefined)
   {
      this._showLine = Boolean(initObject.showLine);
   }
   if(initObject.lineExtra != undefined)
   {
      this._lineExtra = initObject.lineExtra;
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
p.updatePositions = function()
{
   var sin = Math.sin;
   var abs = Math.abs;
   var ma = this._phase * 6.283185307179586;
   var e = this._eccentricity;
   var ea0 = 0;
   var ea1 = ma + e * sin(ma);
   var c = 0;
   do
   {
      ea0 = ea1;
      ea1 = ma + e * sin(ea0);
      c++;
   }
   while(abs(ea1 - ea0) > 0.001 && c < 100);
   var ta = 2 * Math.atan(Math.sqrt((1 + e) / (1 - e)) * Math.tan(ea1 / 2));
   var cosTa = Math.cos(ta);
   var sinTa = sin(ta);
   var k = (1 - e * e) / (1 + e * cosTa);
   var r1 = this._a1 * k;
   var r2 = this._a2 * k;
   var wx1 = (- r1) * cosTa;
   var wy1 = (- r1) * sinTa;
   var wx2 = r2 * cosTa;
   var wy2 = r2 * sinTa;
   var c = this._c;
   var sx1 = wx1 * c.a0 + wy1 * c.a1;
   var sy1 = wx1 * c.a3 + wy1 * c.a4 + 0 * c.a5;
   var sz1 = wx1 * c.a6 + wy1 * c.a7 + 0 * c.a8;
   var sx2 = wx2 * c.a0 + wy2 * c.a1;
   var sy2 = wx2 * c.a3 + wy2 * c.a4 + 0 * c.a5;
   var sz2 = wx2 * c.a6 + wy2 * c.a7 + 0 * c.a8;
   this._s1 = {x:sx1,y:sy1,z:sz1};
   this._s2 = {x:sx2,y:sy2,z:sz2};
   this.backHalfMC.body1MC._x = this.frontHalfMC.body1MC._x = this.frontHalfMC.mask1MC._x = sx1;
   this.backHalfMC.body1MC._y = this.frontHalfMC.body1MC._y = this.frontHalfMC.mask1MC._y = sy1;
   this.backHalfMC.body2MC._x = this.frontHalfMC.body2MC._x = this.frontHalfMC.mask2MC._x = sx2;
   this.backHalfMC.body2MC._y = this.frontHalfMC.body2MC._y = this.frontHalfMC.mask2MC._y = sy2;
   if(sz1 > sz2)
   {
      this.frontHalfMC.body1MC.swapDepths(200);
      this.backHalfMC.body1MC.swapDepths(200);
   }
   else
   {
      this.frontHalfMC.body2MC.swapDepths(200);
      this.backHalfMC.body2MC.swapDepths(200);
   }
};
p.updateOrbitalPaths = function()
{
   var cos = Math.cos;
   var sin = Math.sin;
   this.orbitalPlaneMC._yscale = 100 * sin(this._phi);
   this.orbitalPlaneMC.containerMC._rotation = 90 + this._theta * 57.29577951308232;
   var path1 = this.orbitalPlaneMC.containerMC.path1MC;
   var path2 = this.orbitalPlaneMC.containerMC.path2MC;
   path1.clear();
   path2.clear();
   if(!this._showOrbitalPaths)
   {
      return undefined;
   }
   path1.lineStyle(this.orbitalPathStyle.thickness,this.orbitalPathStyle.color,this.orbitalPathStyle.alpha);
   path2.lineStyle(this.orbitalPathStyle.thickness,this.orbitalPathStyle.color,this.orbitalPathStyle.alpha);
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
   var grid = this.orbitalPlaneMC.containerMC.gridMC;
   grid.clear();
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
p.setIcon = function(num, name)
{
   var str = "body" + num + "MC";
   this.backHalfMC[str].attachMovie(name,"iconMC",1);
   var fmc = this.frontHalfMC[str];
   fmc.attachMovie(name,"iconMC",1);
   fmc.setMask(this.frontHalfMC["mask" + num + "MC"]);
   this["_icon" + num + "Radius"] = fmc.iconMC._width / 2;
   this.resizeIcon(num);
   this.updatePositions();
};
p.passObjectToIcon = function(num, obj)
{
   var str = "body" + num + "MC";
   this.backHalfMC[str].iconMC.acceptObject(obj);
   this.frontHalfMC[str].iconMC.acceptObject(obj);
};
p.resizeIcon = function(arg)
{
   var bmc = this.backHalfMC["body" + arg + "MC"].iconMC;
   var fmc = this.frontHalfMC["body" + arg + "MC"].iconMC;
   var scalingFactor = 100 * this._scale * this["_radius" + arg] / this["_icon" + arg + "Radius"];
   bmc._xscale = bmc._yscale = fmc._xscale = fmc._yscale = scalingFactor;
};
p.updateMask = function(arg)
{
   var mc = this.frontHalfMC["mask" + arg + "MC"];
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
   var equatorMC = this.frontHalfMC["body" + arg + "MC"].objectEquatorMC;
   equatorMC.clear();
   equatorMC.lineStyle(this.objectEquatorStyle.thickness,this.objectEquatorStyle.color,this.objectEquatorStyle.alpha);
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
   var c = this._c;
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
   var c = this._c;
   sp.x = p.x * c.a0 + p.y * c.a1;
   sp.y = p.x * c.a3 + p.y * c.a4 + p.z * c.a5;
   sp.z = p.x * c.a6 + p.y * c.a7 + p.z * c.a8;
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
   this.frontHalfMC.body1MC.objectEquatorMC._visible = this.frontHalfMC.body2MC.objectEquatorMC._visible = this._showOrbitalPlane;
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
