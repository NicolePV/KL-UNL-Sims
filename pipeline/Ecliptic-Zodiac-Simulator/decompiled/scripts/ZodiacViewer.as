function ZodiacViewerClass()
{
   var _loc2_ = this;
   var start = getTimer();
   _loc2_.createEmptyMovieClip("backSurface",45);
   _loc2_.createEmptyMovieClip("backSurfaceMask",50);
   _loc2_.createEmptyMovieClip("frontSurface",145);
   _loc2_.createEmptyMovieClip("frontSurfaceMask",150);
   _loc2_.backSurface.setMask(_loc2_.backSurfaceMask);
   _loc2_.frontSurface.setMask(_loc2_.frontSurfaceMask);
   var _loc1_ = _loc2_.attachMovie("CelestialSphere","celestialSphere",100,{_traceOn:true});
   _loc2_.backConstellations = _loc1_.createEmptyMovieClip("backConstellations",2 * _loc1_._N - 20);
   _loc2_.frontConstellations = _loc1_.createEmptyMovieClip("frontConstellations",5 * _loc1_._N - 20);
   _loc2_.celestialSphere.addObject("Sun Disk","sunDisk",{ra:0,dec:0});
   _loc2_.celestialSphere.theta = 206;
   _loc2_.backSurface.attachMovie("Symbol 64","shading",1);
   _loc2_.frontSurface.attachMovie("Symbol 65","shading",1);
   _loc2_.constellationsColor = 14671839;
   _loc1_.maxViewerAltitude = 50;
   var aqrCenter = {ra:22.2,dec:3.2};
   var scoCenter = {ra:16.9,dec:-22};
   var leoCenter = {ra:10.6,dec:7.6};
   var _loc3_ = {ra:6.7,dec:33.3};
   var sgrCenter = {ra:18.5,dec:-16.1};
   var capCenter = {ra:21.3,dec:-28.6};
   var cncCenter = {ra:8.8,dec:8.6};
   var ariCenter = {ra:2.5,dec:16.3};
   var virCenter = {ra:13.2,dec:-14.7};
   var pscCenter = {ra:0.7,dec:-0.6};
   var tauCenter = {ra:4.1,dec:22.8};
   var libCenter = {ra:14.9,dec:-29.6};
   _loc1_.addObject("Constellation Label","libLabel",libCenter,{labelText:"Libra"});
   _loc1_.libLabel.setOrientationType("absolute",{ra:libCenter.ra + 12,dec:- libCenter.dec},{ra:18,dec:66.56});
   _loc1_.addObject("Constellation Label","tauLabel",tauCenter,{labelText:"Taurus"});
   _loc1_.tauLabel.setOrientationType("absolute",{ra:tauCenter.ra + 12,dec:- tauCenter.dec},{ra:18,dec:66.56});
   _loc1_.addObject("Constellation Label","aqrLabel",aqrCenter,{labelText:"Aquarius"});
   _loc1_.aqrLabel.setOrientationType("absolute",{ra:aqrCenter.ra + 12,dec:- aqrCenter.dec},{ra:18,dec:66.56});
   _loc1_.addObject("Constellation Label","scoLabel",scoCenter,{labelText:"Scorpius"});
   _loc1_.scoLabel.setOrientationType("absolute",{ra:scoCenter.ra + 12,dec:- scoCenter.dec},{ra:18,dec:66.56});
   _loc1_.addObject("Constellation Label","pscLabel",pscCenter,{labelText:"Pisces"});
   _loc1_.pscLabel.setOrientationType("absolute",{ra:pscCenter.ra + 12,dec:- pscCenter.dec},{ra:18,dec:66.56});
   _loc1_.addObject("Constellation Label","ariLabel",ariCenter,{labelText:"Aries"});
   _loc1_.ariLabel.setOrientationType("absolute",{ra:ariCenter.ra + 12,dec:- ariCenter.dec},{ra:18,dec:66.56});
   _loc1_.addObject("Constellation Label","cncLabel",cncCenter,{labelText:"Cancer"});
   _loc1_.cncLabel.setOrientationType("absolute",{ra:cncCenter.ra + 12,dec:- cncCenter.dec},{ra:18,dec:66.56});
   _loc1_.addObject("Constellation Label","leoLabel",leoCenter,{labelText:"Leo"});
   _loc1_.leoLabel.setOrientationType("absolute",{ra:leoCenter.ra + 12,dec:- leoCenter.dec},{ra:18,dec:66.56});
   _loc1_.addObject("Constellation Label","gemLabel",_loc3_,{labelText:"Gemini"});
   _loc1_.gemLabel.setOrientationType("absolute",{ra:_loc3_.ra + 12,dec:- _loc3_.dec},{ra:18,dec:66.56});
   _loc1_.addObject("Constellation Label","sgrLabel",sgrCenter,{labelText:"Sagittarius"});
   _loc1_.sgrLabel.setOrientationType("absolute",{ra:sgrCenter.ra + 12,dec:- sgrCenter.dec},{ra:18,dec:66.56});
   _loc1_.addObject("Constellation Label","capLabel",capCenter,{labelText:"Capricornus"});
   _loc1_.capLabel.setOrientationType("absolute",{ra:capCenter.ra + 12,dec:- capCenter.dec},{ra:18,dec:66.56});
   _loc1_.addObject("Constellation Label","virLabel",virCenter,{labelText:"Virgo"});
   _loc1_.virLabel.setOrientationType("absolute",{ra:virCenter.ra + 12,dec:- virCenter.dec},{ra:18,dec:66.56});
   _loc2_.globeR = _loc2_.initEarthOrbitSize / _loc2_.initZodiacSize;
   _loc1_.addObject("GlobeComponent","globe",{ra:0,dec:0,r:_loc2_.globeR},{_traceOn:false});
   _loc1_.globe.instance._shoreData = _loc2_.shoreData;
   _loc1_.globe.instance.setScale(100 * (_loc2_.initEarthDiskSize / 2 / 40));
   _loc2_.globeAngularRadius = Math.acos(1 - _loc2_.initEarthDiskSize * _loc2_.initEarthDiskSize / (2 * _loc2_.initEarthOrbitSize * _loc2_.initEarthOrbitSize));
   _loc1_._minStep = 0.7853981633974483;
   _loc1_.showHorizonPlane = false;
   _loc1_.celestialBowl.removeMovieClip();
   _loc1_.aboveHorizonPlane.removeMovieClip();
   _loc1_.belowHorizonPlane.removeMovieClip();
   _loc1_.size = _loc2_.initZodiacSize;
   _loc1_.onMouseUpdate = function()
   {
      var _loc1_ = this;
      _loc1_.celestialSphere.globe.instance.update();
      _loc1_.celestialSphere.globe.instance.updateAxes();
      _loc1_.celestialSphere.globe.instance.updateShading();
      _loc1_.updateConstellations();
      _loc1_.updateZodiacBand();
      _loc1_.drawZodiacBandMasks();
   };
   _loc1_.siderealTime = 18;
   _loc1_.latitude = 66.5;
   var zodiacBandHalfAngle = 24;
   _loc1_.addCircle("bandCircle",{thickness:1,color:16711680,alpha:100},{alt:zodiacBandHalfAngle,az:0,tilt:0});
   _loc1_.bandCircle.visible = false;
   _loc2_.zodiacBandHalfAngle = zodiacBandHalfAngle;
   _loc1_.addCircle("ecliptic",{thickness:1,color:5263440,alpha:100},{dec:0,ra:0,tilt:23.5});
   inner.update();
   _loc1_.update();
   _loc2_.setDayOfYear(0);
   _loc2_.updateConstellations();
   _loc2_.drawZodiacBandMasks();
   trace("init time: " + (getTimer() - start));
}
var p = ZodiacViewerClass.prototype = new MovieClip();
Object.registerClass("ZodiacViewer",ZodiacViewerClass);
p.setDayOfYear = function(arg)
{
   var _loc1_ = this;
   _loc1_.dayOfYear = (arg % 365 + 365) % 365;
   _loc1_.updateGlobe(true);
   _loc1_.updateZodiacBand();
};
p.setMonthAndDay = function(month, dayOfMonth)
{
   var _loc2_ = [0,31,59,90,120,151,181,212,243,273,304,334];
   var _loc1_ = ((_loc2_[month - 1] + dayOfMonth - 1) % 365 + 365) % 365;
   this.dayOfYear = _loc1_;
   this.updateGlobe(true);
};
p.updateGlobe = function(dontCallHandler)
{
   var _loc2_ = this;
   var start = getTimer();
   var _loc1_ = _loc2_.celestialSphere.globe;
   var az = -0.9863013698630136 * (_loc2_.dayOfYear + 10.8);
   _loc1_.setPosition({az:az,alt:0,r:0.001});
   _loc2_.celestialSphere.sunDisk.setPosition({az:az + 180,alt:0,r:0.9999});
   _loc2_.celestialSphere.sunDisk.setOrientationType("absolute");
   _loc2_.celestialSphere.updateObjects();
   _loc1_ = _loc1_.instance;
   _loc1_.setSunDirection({az:az + 180,alt:0});
   var _loc3_ = _loc2_.dayOfYear * 1.0027397260273974;
   _loc1_.setRotationAngle(_loc3_ % 1 * 360);
   _loc1_.update();
   _loc1_.updateAxes();
   _loc1_.updateShading();
   if(!dontCallHandler)
   {
      _loc2_.onDayChanged.call(_loc2_._parent,_loc2_.dayOfYear);
   }
   trace("globe update time: " + (getTimer() - start));
};
p.setRotationAngle = function(arg)
{
   this.celestialSphere.globe.instance.setRotationAngle(arg);
   this.celestialSphere.globe.instance.update();
};
p.updateZodiacBand = function()
{
   var start = getTimer();
   var outer = this.celestialSphere;
   var _loc2_ = this.backSurface;
   var _loc3_ = this.frontSurface;
   var az = outer.globe.az - 90;
   var width = 15;
   var sp = {};
   outer.toScreen({alt:0,az:az},sp);
   var inFront = sp.z > 0;
   outer.toScreen({alt:0,az:az - width},sp);
   var darkX = sp.x;
   outer.toScreen({alt:0,az:az + width},sp);
   var lightX = sp.x;
   _loc3_.clear();
   _loc3_.lineStyle(1,16711680,0);
   _loc2_.clear();
   _loc2_.lineStyle(1,16711680,0);
   var size = outer.size;
   var _loc1_ = size / 2;
   var k = 256 / size;
   if(darkX > lightX)
   {
      var colors1 = [11455999,11455999,4671303,4671303];
      var alphas1 = [60,60,60,60];
      var ratios1 = [0,k * (lightX + _loc1_),k * (darkX + _loc1_),255];
      var colors2 = [4671303,4671303,11455999,11455999];
      var alphas2 = [60,60,60,60];
      var ratios2 = [0,k * (lightX + _loc1_),k * (darkX + _loc1_),255];
   }
   else
   {
      var colors1 = [4671303,4671303,11455999,11455999];
      var alphas1 = [60,60,60,60];
      var ratios1 = [0,k * (darkX + _loc1_),k * (lightX + _loc1_),255];
      var colors2 = [11455999,11455999,4671303,4671303];
      var alphas2 = [60,60,60,60];
      var ratios2 = [0,k * (darkX + _loc1_),k * (lightX + _loc1_),255];
   }
   var matrix1 = {matrixType:"box",x:- _loc1_,y:- _loc1_,w:size,h:size,r:3.141592653589793};
   var matrix2 = {matrixType:"box",x:- _loc1_,y:- _loc1_,w:size,h:size,r:0};
   if(inFront)
   {
      _loc2_.beginGradientFill("linear",colors1,alphas1,ratios1,matrix1);
      _loc2_.moveTo(_loc1_,_loc1_);
      _loc2_.lineTo(- _loc1_,_loc1_);
      _loc2_.lineTo(- _loc1_,- _loc1_);
      _loc2_.lineTo(_loc1_,- _loc1_);
      _loc2_.lineTo(_loc1_,_loc1_);
      _loc2_.endFill();
      _loc3_.beginGradientFill("linear",colors2,alphas2,ratios2,matrix2);
      _loc3_.moveTo(_loc1_,_loc1_);
      _loc3_.lineTo(- _loc1_,_loc1_);
      _loc3_.lineTo(- _loc1_,- _loc1_);
      _loc3_.lineTo(_loc1_,- _loc1_);
      _loc3_.lineTo(_loc1_,_loc1_);
      _loc3_.endFill();
   }
   else
   {
      _loc2_.beginGradientFill("linear",colors2,alphas2,ratios2,matrix2);
      _loc2_.moveTo(_loc1_,_loc1_);
      _loc2_.lineTo(- _loc1_,_loc1_);
      _loc2_.lineTo(- _loc1_,- _loc1_);
      _loc2_.lineTo(_loc1_,- _loc1_);
      _loc2_.lineTo(_loc1_,_loc1_);
      _loc2_.endFill();
      _loc3_.beginGradientFill("linear",colors1,alphas1,ratios1,matrix1);
      _loc3_.moveTo(_loc1_,_loc1_);
      _loc3_.lineTo(- _loc1_,_loc1_);
      _loc3_.lineTo(- _loc1_,- _loc1_);
      _loc3_.lineTo(_loc1_,- _loc1_);
      _loc3_.lineTo(_loc1_,_loc1_);
      _loc3_.endFill();
   }
   trace("time to update zodiac band: " + (getTimer() - start));
};
p.updateConstellations = function()
{
   var start = getTimer();
   var c = this.celestialSphere._c;
   var b0 = c.b0;
   var b1 = c.b1;
   var b2 = c.b2;
   var b3 = c.b3;
   var b4 = c.b4;
   var b5 = c.b5;
   var b6 = c.b6;
   var b7 = c.b7;
   var b8 = c.b8;
   var frontMC = this.frontConstellations;
   var backMC = this.backConstellations;
   backMC.clear();
   backMC.lineStyle(1,this.constellationsColor,100);
   frontMC.clear();
   frontMC.lineStyle(1,this.constellationsColor,100);
   var consts = this.constellationsData;
   var i = 0;
   var _loc1_;
   var _loc2_;
   var _loc3_;
   while(i < consts.length)
   {
      var curves = consts[i].path;
      var points = consts[i].stars;
      var j = 0;
      while(j < curves.length)
      {
         var c = curves[j];
         _loc1_ = points[c.m];
         var lx = b0 * _loc1_.x + b1 * _loc1_.y + b2 * _loc1_.z;
         var ly = b3 * _loc1_.x + b4 * _loc1_.y + b5 * _loc1_.z;
         var lif = b6 * _loc1_.x + b7 * _loc1_.y + b8 * _loc1_.z > 0;
         if(lif)
         {
            _loc2_ = frontMC;
         }
         else
         {
            _loc2_ = backMC;
         }
         _loc2_.moveTo(lx,ly);
         var k = c.b;
         while(k < c.e)
         {
            _loc1_ = points[k];
            var tx = b0 * _loc1_.x + b1 * _loc1_.y + b2 * _loc1_.z;
            _loc3_ = b3 * _loc1_.x + b4 * _loc1_.y + b5 * _loc1_.z;
            var tif = b6 * _loc1_.x + b7 * _loc1_.y + b8 * _loc1_.z > 0;
            if(tif != lif)
            {
               if(tif)
               {
                  _loc2_ = frontMC;
               }
               else
               {
                  _loc2_ = backMC;
               }
               _loc2_.moveTo(lx,ly);
               _loc2_.lineTo(tx,_loc3_);
            }
            else
            {
               _loc2_.lineTo(tx,_loc3_);
            }
            lx = tx;
            ly = _loc3_;
            lif = tif;
            k++;
         }
         j++;
      }
      i++;
   }
   trace("time to draw constellations: " + (getTimer() - start));
};
Number.prototype.toFixed = function(fractionDigits)
{
   var _loc2_ = int(fractionDigits);
   if(_loc2_ < 0 || _loc2_ > 20)
   {
      return "Range Error";
   }
   var x = this;
   if(isNaN(x))
   {
      return "NaN";
   }
   var s = "";
   if(x < 0)
   {
      s = "-";
      x = - x;
   }
   var _loc3_ = "";
   var _loc1_;
   if(x < 1e+21)
   {
      var n = Math.round(x * Math.pow(10,_loc2_));
      if(n == 0)
      {
         _loc3_ = "0";
      }
      else
      {
         _loc3_ = n.toString();
      }
      if(_loc2_ > 0)
      {
         var k = _loc3_.length;
         if(k <= _loc2_)
         {
            var z = "";
            _loc1_ = 0;
            while(_loc1_ < _loc2_ + 1 - k)
            {
               z += "0";
               _loc1_ = _loc1_ + 1;
            }
            _loc3_ = z + _loc3_;
            k = _loc2_ + 1;
         }
         var a = _loc3_.substr(0,k - _loc2_);
         var b = _loc3_.substr(k - _loc2_);
         _loc3_ = a + "." + b;
      }
   }
   else
   {
      _loc3_ = x.toString();
   }
   return s + _loc3_;
};
p.drawZodiacBandMasks = function()
{
   function drawArc(g1, g2, mc)
   {
      if(g2 < g1)
      {
         g2 += 6.283185307179586;
      }
      var arc = g2 - g1;
      if(arc == 0)
      {
         arc = 6.283185307179586;
      }
      var n = Math.ceil(arc / minStep);
      var step = arc / n;
      var halfStep = step / 2;
      var cos = Math.cos;
      var sin = Math.sin;
      var cRad = 1 / cos(halfStep);
      var aAngle = g1 + step;
      var cAngle = aAngle - halfStep;
      var i = 0;
      var _loc3_;
      var _loc2_;
      var _loc1_;
      while(i < n)
      {
         var ax = cos(aAngle);
         _loc3_ = sin(aAngle);
         _loc2_ = cRad * cos(cAngle);
         _loc1_ = cRad * sin(cAngle);
         mc.curveTo(v0 * _loc2_ + v1 * _loc1_ + v2,v3 * _loc2_ + v4 * _loc1_ + v5,v0 * ax + v1 * _loc3_ + v2,v3 * ax + v4 * _loc3_ + v5);
         aAngle += step;
         cAngle += step;
         i++;
      }
   }
   var start = getTimer();
   var outer = this.celestialSphere;
   var backMC = this.backSurfaceMask;
   var frontMC = this.frontSurfaceMask;
   frontMC.clear();
   frontMC.lineStyle(0,16711680,0);
   backMC.clear();
   backMC.lineStyle(0,16711680,0);
   var _loc2_ = Math.cos;
   var _loc3_ = Math.sin;
   var atan2 = Math.atan2;
   var ceil = Math.ceil;
   var asin = Math.asin;
   var pc = outer._c;
   var circle = outer.bandCircle;
   if(circle._wLastVer != circle._wVer || circle._aLastVer != outer._aVer)
   {
      var tc = circle._c;
      var v0 = tc.v0 = pc.a0 * tc.w0 + pc.a1 * tc.w3;
      var v1 = tc.v1 = pc.a0 * tc.w1 + pc.a1 * tc.w4;
      var v2 = tc.v2 = pc.a0 * tc.w2 + pc.a1 * tc.w5;
      var v3 = tc.v3 = pc.a3 * tc.w0 + pc.a4 * tc.w3;
      var v4 = tc.v4 = pc.a3 * tc.w1 + pc.a4 * tc.w4 + pc.a5 * tc.w7;
      var v5 = tc.v5 = pc.a3 * tc.w2 + pc.a4 * tc.w5 + pc.a5 * tc.w8;
      var v6 = tc.v6 = pc.a6 * tc.w0 + pc.a7 * tc.w3;
      var v7 = tc.v7 = pc.a6 * tc.w1 + pc.a7 * tc.w4 + pc.a8 * tc.w7;
      var v8 = tc.v8 = pc.a6 * tc.w2 + pc.a7 * tc.w5 + pc.a8 * tc.w8;
      circle._wLastVer = circle._wVer;
      circle._aLastVer = outer._aVer;
   }
   else
   {
      var c = circle._c;
      var v0 = c.v0;
      var v1 = c.v1;
      var v2 = c.v2;
      var v3 = c.v3;
      var v4 = c.v4;
      var v5 = c.v5;
      var v6 = c.v6;
      var v7 = c.v7;
      var v8 = c.v8;
   }
   var minPoints = 10;
   var minStep = 6.283185307179586 / minPoints;
   var A = Math.sqrt(v6 * v6 + v7 * v7);
   var _loc1_;
   if(A == 0)
   {
      if(v8 < 0)
      {
      }
   }
   else
   {
      var sj = (- v8) / A;
      if(sj > -1)
      {
         if(sj < 1)
         {
            var j = asin(sj);
            var t = atan2(v6,v7);
            if(_loc2_(j) < 0)
            {
               var gDesc = ((j - t) % 6.283185307179586 + 6.283185307179586) % 6.283185307179586;
               var gAsc = ((3.141592653589793 - j - t) % 6.283185307179586 + 6.283185307179586) % 6.283185307179586;
            }
            else
            {
               var gDesc = ((3.141592653589793 - j - t) % 6.283185307179586 + 6.283185307179586) % 6.283185307179586;
               var gAsc = ((j - t) % 6.283185307179586 + 6.283185307179586) % 6.283185307179586;
            }
            var p1 = {};
            var points = [];
            var ax = _loc2_(gDesc);
            var ay = _loc3_(gDesc);
            p1.x = v0 * ax + v1 * ay + v2;
            p1.y = v3 * ax + v4 * ay + v5;
            var g1 = gDesc;
            var g2 = gAsc;
            if(g2 < g1)
            {
               g2 += 6.283185307179586;
            }
            var arc = g2 - g1;
            if(arc == 0)
            {
               arc = 6.283185307179586;
            }
            var n = ceil(arc / minStep);
            var step = arc / n;
            var halfStep = step / 2;
            var cRad = 1 / _loc2_(halfStep);
            var aAngle = g1 + step;
            var cAngle = aAngle - halfStep;
            var i = 0;
            while(i < n)
            {
               var ax = _loc2_(aAngle);
               var ay = _loc3_(aAngle);
               var cx = cRad * _loc2_(cAngle);
               var cy = cRad * _loc3_(cAngle);
               points.push({cx:v0 * cx + v1 * cy + v2,cy:v3 * cx + v4 * cy + v5,ax:v0 * ax + v1 * ay + v2,ay:v3 * ax + v4 * ay + v5});
               aAngle += step;
               cAngle += step;
               i++;
            }
            var index2 = points.length;
            var g1 = (atan2(- p1.y,- p1.x) % 6.283185307179586 + 6.283185307179586) % 6.283185307179586;
            var g2 = (atan2(p1.y,- p1.x) % 6.283185307179586 + 6.283185307179586) % 6.283185307179586;
            if(g2 < g1)
            {
               g2 += 6.283185307179586;
            }
            var arc = g2 - g1;
            if(arc == 0)
            {
               arc = 6.283185307179586;
            }
            var n = ceil(arc / minStep);
            var step = arc / n;
            var halfStep = step / 2;
            var r = outer.size / 2;
            var cRad = r / _loc2_(halfStep);
            var aAngle = g1 + step;
            var cAngle = aAngle - halfStep;
            var i = 0;
            while(i < n)
            {
               var ax = r * _loc2_(aAngle);
               var ay = (- r) * _loc3_(aAngle);
               var cx = cRad * _loc2_(cAngle);
               var cy = (- cRad) * _loc3_(cAngle);
               points.push({cx:cx,cy:cy,ax:ax,ay:ay});
               aAngle += step;
               cAngle += step;
               i++;
            }
            var index3 = points.length;
            var g1 = gAsc;
            var g2 = gDesc;
            if(g2 < g1)
            {
               g2 += 6.283185307179586;
            }
            var arc = g2 - g1;
            if(arc == 0)
            {
               arc = 6.283185307179586;
            }
            var n = ceil(arc / minStep);
            var step = arc / n;
            var halfStep = step / 2;
            var cRad = 1 / _loc2_(halfStep);
            var aAngle = g1 + step;
            var cAngle = aAngle - halfStep;
            var i = 0;
            while(i < n)
            {
               var ax = _loc2_(aAngle);
               var ay = _loc3_(aAngle);
               var cx = cRad * _loc2_(cAngle);
               var cy = cRad * _loc3_(cAngle);
               points.push({cx:v0 * cx + v1 * cy + v2,cy:- (v3 * cx + v4 * cy + v5),ax:v0 * ax + v1 * ay + v2,ay:- (v3 * ax + v4 * ay + v5)});
               aAngle += step;
               cAngle += step;
               i++;
            }
            var i = index2;
            while(i < index3)
            {
               _loc1_ = points[i];
               points.push({ax:- _loc1_.ax,ay:- _loc1_.ay,cx:- _loc1_.cx,cy:- _loc1_.cy});
               i++;
            }
            var pl = points.length;
            _loc1_ = points[pl - 1];
            frontMC.moveTo(_loc1_.ax,- _loc1_.ay);
            frontMC.beginFill(16770799,50);
            backMC.moveTo(_loc1_.ax,_loc1_.ay);
            backMC.beginFill(14608111,80);
            var i = 0;
            while(i < pl)
            {
               _loc1_ = points[i];
               frontMC.curveTo(_loc1_.cx,- _loc1_.cy,_loc1_.ax,- _loc1_.ay);
               backMC.curveTo(_loc1_.cx,_loc1_.cy,_loc1_.ax,_loc1_.ay);
               i++;
            }
            frontMC.endFill();
            backMC.endFill();
         }
      }
   }
   trace("time to draw zodiac band: " + (getTimer() - start));
};
p.constellationsData = [{path:[{m:3,b:0,e:9},{m:7,b:9,e:12},{m:9,b:12,e:13},{m:9,b:13,e:15},{m:13,b:0,e:1},{m:13,b:5,e:6},{m:13,b:15,e:16}],stars:[{name:"epsilon",x:-0.7628,y:0.5056,z:0.4031},{name:"lambda",x:-0.7347,y:0.5549,z:0.3902},{name:"kappa",x:-0.699,y:0.5627,z:0.4412},{name:"mu",x:-0.7637,y:0.4738,z:0.4385},{name:"zeta",x:-0.826,y:0.3998,z:0.3974},{name:"gamma1",x:-0.8551,y:0.3988,z:0.3312},{name:"60",x:-0.9091,y:0.2337,z:0.345},{name:"delta",x:-0.9178,y:0.1863,z:0.3506},{name:"beta",x:-0.9667,y:0.0461,z:0.2516},{name:"theta",x:-0.9448,y:0.1913,z:0.266},{name:"iota",x:-0.971,y:0.1541,z:0.1827},{name:"sigma",x:-0.9802,y:0.1679,z:0.105},{name:"rho",x:-0.9163,y:0.3664,z:0.1617},{name:"eta",x:-0.8441,y:0.452,z:0.2884},{name:"alpha",x:-0.8644,y:0.458,z:0.2073},{name:"omicron",x:-0.8098,y:0.561,z:0.1718}]},{path:[{m:0,b:1,e:10},{m:7,b:10,e:12},{m:3,b:12,e:13},{m:4,b:13,e:14},{m:4,b:14,e:16},{m:6,b:16,e:17},{m:6,b:17,e:18}],stars:[{name:"1",x:-0.0166,y:0.9186,z:0.395},{name:"eta",x:-0.0599,y:0.9219,z:0.3828},{name:"mu",x:-0.0925,y:0.9191,z:0.3829},{name:"epsilon",x:-0.1724,y:0.8888,z:0.4247},{name:"tau",x:-0.2639,y:0.8226,z:0.5037},{name:"iota",x:-0.3233,y:0.8234,z:0.4664},{name:"upsilon",x:-0.3625,y:0.8148,z:0.4524},{name:"delta",x:-0.3175,y:0.8712,z:0.3743},{name:"zeta",x:-0.2586,y:0.8998,z:0.3514},{name:"gamma",x:-0.1573,y:0.9463,z:0.2823},{name:"lambda",x:-0.3205,y:0.9035,z:0.2847},{name:"xi",x:-0.1914,y:0.9558,z:0.2232},{name:"nu",x:-0.1183,y:0.9309,z:0.3455},{name:"theta",x:-0.1894,y:0.8075,z:0.5586},{name:"rho",x:-0.3222,y:0.7866,z:0.5267},{name:"alpha",x:-0.3407,y:0.7777,z:0.5283},{name:"beta",x:-0.3915,y:0.7912,z:0.4699},{name:"kappa",x:-0.4009,y:0.8177,z:0.4131}]},{path:[{m:5,b:0,e:11},{m:2,b:5,e:6},{m:11,b:8,e:9},{m:11,b:7,e:8},{m:15,b:12,e:17},{m:14,b:17,e:19},{m:7,b:12,e:13},{m:6,b:13,e:14}],stars:[{name:"epsilon",x:0.0869,y:-0.8207,z:-0.5648},{name:"eta",x:0.0616,y:-0.7988,z:-0.5985},{name:"gamma2",x:0.0219,y:-0.862,z:-0.5064},{name:"mu",x:0.0559,y:-0.9315,z:-0.3593},{name:"lambda",x:0.1099,y:-0.8965,z:-0.4293},{name:"delta",x:0.0794,y:-0.8639,z:-0.4974},{name:"phi",x:0.1764,y:-0.8735,z:-0.4539},{name:"sigma",x:0.2141,y:-0.8706,z:-0.443},{name:"pi",x:0.2798,y:-0.8905,z:-0.3588},{name:"rho1",x:0.332,y:-0.8921,z:-0.3065},{name:"upsilon",x:0.3356,y:-0.901,z:-0.2749},{name:"xi2",x:0.2325,y:-0.9035,z:-0.3601},{name:"tau",x:0.2551,y:-0.8481,z:-0.4644},{name:"zeta",x:0.234,y:-0.8349,z:-0.4982},{name:"alpha",x:0.2717,y:-0.7088,z:-0.651},{name:"theta1",x:0.4074,y:-0.7074,z:-0.5775},{name:"iota",x:0.3589,y:-0.6525,z:-0.6674},{name:"beta1",x:0.2518,y:-0.6679,z:-0.7004},{name:"beta2",x:0.252,y:-0.6633,z:-0.7046}]},{path:[{m:3,b:0,e:6},{m:2,b:6,e:10},{m:2,b:8,e:9},{m:6,b:10,e:11},{m:7,b:11,e:13}],stars:[{name:"36",x:0.7335,y:-0.5692,z:-0.3715},{name:"zeta",x:0.7251,y:-0.5735,z:-0.3812},{name:"theta",x:0.6926,y:-0.6576,z:-0.2963},{name:"iota",x:0.7392,y:-0.608,z:-0.2896},{name:"gamma",x:0.7849,y:-0.5492,z:-0.2867},{name:"delta",x:0.8035,y:-0.5266,z:-0.2778},{name:"eta",x:0.6777,y:-0.6522,z:-0.3396},{name:"rho",x:0.5758,y:-0.7582,z:-0.3059},{name:"beta",x:0.558,y:-0.7896,z:-0.2551},{name:"alpha2",x:0.5531,y:-0.8043,z:-0.2172},{name:"24",x:0.6605,y:-0.6206,z:-0.4227},{name:"psi",x:0.5994,y:-0.6771,z:-0.4269},{name:"omega",x:0.6076,y:-0.6525,z:-0.4527}]},{path:[{m:2,b:0,e:6},{m:5,b:3,e:4},{m:3,b:7,e:8},{m:6,b:7,e:10},{m:8,b:0,e:1}],stars:[{name:"41",x:0.6554,y:0.6005,z:0.458},{name:"39",x:0.6486,y:0.5837,z:0.4886},{name:"35",x:0.6696,y:0.5792,z:0.465},{name:"alpha",x:0.7797,y:0.4832,z:0.3982},{name:"lambda",x:0.7977,y:0.4511,z:0.4003},{name:"beta",x:0.8202,y:0.4484,z:0.3552},{name:"gamma2",x:0.8304,y:0.4486,z:0.3304},{name:"eta",x:0.7801,y:0.5104,z:0.3618},{name:"epsilon",x:0.6609,y:0.6564,z:0.3639},{name:"delta",x:0.631,y:0.6985,z:0.3375}]},{path:[{m:3,b:0,e:5},{m:2,b:5,e:6}],stars:[{name:"zeta",x:-0.5198,y:0.7987,z:0.3032},{name:"beta",x:-0.5538,y:0.8172,z:0.1596},{name:"delta",x:-0.6256,y:0.7152,z:0.3116},{name:"gamma",x:-0.6083,y:0.7043,z:0.366},{name:"iota",x:-0.5828,y:0.6548,z:0.4811},{name:"alpha",x:-0.6875,y:0.6965,z:0.2055}]},{path:[{m:4,b:0,e:13},{m:8,b:14,e:15},{m:9,b:13,e:14},{m:10,b:6,e:7},{m:11,b:4,e:5}],stars:[{name:"omicron",x:-0.9882,y:-0.0225,z:0.1518},{name:"nu",x:-0.9916,y:0.0613,z:0.1137},{name:"beta",x:-0.9987,y:0.0405,z:0.0308},{name:"eta",x:-0.9962,y:-0.0868,z:-0.0116},{name:"gamma",x:-0.9832,y:-0.1806,z:-0.0253},{name:"theta",x:-0.9493,y:-0.2991,z:-0.0965},{name:"alpha",x:-0.9141,y:-0.3564,z:-0.1936},{name:"kappa",x:-0.8231,y:-0.5391,z:-0.1784},{name:"iota",x:-0.8244,y:-0.5562,z:-0.1045},{name:"tau",x:-0.862,y:-0.5062,z:0.0269},{name:"zeta",x:-0.9158,y:-0.4014,z:-0.0104},{name:"delta",x:-0.969,y:-0.2399,z:0.0593},{name:"epsilon",x:-0.9459,y:-0.263,z:0.1901},{name:"109",x:-0.7478,y:-0.6631,z:0.033},{name:"mu",x:-0.7536,y:-0.6498,z:-0.0986}]},{path:[{m:0,b:1,e:15},{m:14,b:10,e:11},{m:12,b:15,e:16}],stars:[{name:"tau",x:0.8233,y:0.2661,z:0.5014},{name:"upsilon",x:0.836,y:0.302,z:0.4581},{name:"phi",x:0.8627,y:0.2876,z:0.416},{name:"eta",x:0.8885,y:0.3749,z:0.2646},{name:"omicron",x:0.8846,y:0.4383,z:0.1592},{name:"alpha",x:0.8605,y:0.5071,z:0.0482},{name:"nu",x:0.8995,y:0.4264,z:0.0956},{name:"epsilon",x:0.9534,y:0.2686,z:0.1373},{name:"delta",x:0.969,y:0.2089,z:0.132},{name:"omega",x:0.9928,y:-0.0029,z:0.1195},{name:"iota",x:0.9914,y:-0.0869,z:0.098},{name:"theta",x:0.9841,y:-0.1385,z:0.1111},{name:"gamma",x:0.981,y:-0.1855,z:0.0573},{name:"kappa",x:0.9894,y:-0.1437,z:0.0219},{name:"lambda",x:0.9965,y:-0.0782,z:0.0311},{name:"beta",x:0.968,y:-0.2418,z:0.0666}]},{path:[{m:0,b:1,e:17},{m:13,b:17,e:20}],stars:[{name:"?1",x:-0.0349,y:-0.7973,z:-0.6025},{name:"lambda",x:-0.0917,y:-0.7923,z:-0.6033},{name:"upsilon",x:-0.1012,y:-0.7891,z:-0.6059},{name:"?2",x:-0.0785,y:-0.7803,z:-0.6205},{name:"kappa",x:-0.0593,y:-0.7745,z:-0.6297},{name:"iota1",x:-0.0414,y:-0.7635,z:-0.6445},{name:"theta",x:-0.0723,y:-0.7278,z:-0.682},{name:"eta",x:-0.1509,y:-0.7127,z:-0.685},{name:"zeta2",x:-0.208,y:-0.709,z:-0.6738},{name:"mu1",x:-0.2308,y:-0.7529,z:-0.6163},{name:"epsilon",x:-0.2479,y:-0.7881,z:-0.5634},{name:"tau",x:-0.3162,y:-0.8225,z:-0.4728},{name:"alpha",x:-0.3448,y:-0.8264,z:-0.4451},{name:"sigma",x:-0.3769,y:-0.8193,z:-0.432},{name:"13",x:-0.4001,y:-0.7878,z:-0.4683},{name:"rho",x:-0.4467,y:-0.7499,z:-0.4881},{name:"pi",x:-0.4528,y:-0.7754,z:-0.4402},{name:"nu",x:-0.4281,y:-0.8401,z:-0.3332},{name:"beta1",x:-0.4509,y:-0.8258,z:-0.3388},{name:"delta",x:-0.4603,y:-0.8001,z:-0.3846}]},{path:[{m:8,b:0,e:14},{m:9,b:14,e:15}],stars:[{name:"phi",x:0.9748,y:-0.1968,z:-0.1054},{name:"psi3",x:0.9702,y:-0.1756,z:-0.167},{name:"omega2",x:0.9652,y:-0.0729,z:-0.2511},{name:"107",x:0.9456,y:-0.0578,z:-0.3203},{name:"99",x:0.9255,y:-0.1382,z:-0.3525},{name:"88",x:0.9099,y:-0.2039,z:-0.3612},{name:"delta",x:0.9233,y:-0.2706,z:-0.2726},{name:"tau2",x:0.9265,y:-0.2938,z:-0.235},{name:"lambda",x:0.9487,y:-0.2873,z:-0.1319},{name:"zeta",x:0.922,y:-0.3873,z:-0.0003},{name:"gamma",x:0.9091,y:-0.4159,z:-0.0242},{name:"omicron",x:0.8725,y:-0.4871,z:-0.0376},{name:"beta",x:0.7937,y:-0.6005,z:-0.0971},{name:"epsilon",x:0.659,y:-0.7338,z:-0.165},{name:"pi",x:0.9155,y:-0.4016,z:0.024}]},{path:[{m:0,b:1,e:9},{m:5,b:9,e:12}],stars:[{name:"beta",x:0.1287,y:0.8684,z:0.4788},{name:"tau",x:0.3065,y:0.8683,z:0.39},{name:"epsilon",x:0.3667,y:0.8704,z:0.3286},{name:"delta3",x:0.3813,y:0.8717,z:0.3078},{name:"delta1",x:0.3919,y:0.8692,z:0.3014},{name:"gamma",x:0.4078,y:0.8724,z:0.2694},{name:"lambda",x:0.4857,y:0.8469,z:0.2163},{name:"xi",x:0.6096,y:0.7745,z:0.1691},{name:"omicron",x:0.6187,y:0.7698,z:0.1569},{name:"theta2",x:0.3732,y:0.8865,z:0.2735},{name:"alpha",x:0.3438,y:0.895,z:0.2842},{name:"zeta",x:0.0907,y:0.9283,z:0.3607}]},{path:[{m:0,b:1,e:6},{m:2,b:4,e:5}],stars:[{name:"tau",x:-0.502,y:-0.708,z:-0.4966},{name:"upsilon",x:-0.5152,y:-0.7157,z:-0.4716},{name:"gamma",x:-0.57,y:-0.781,z:-0.2553},{name:"beta",x:-0.6441,y:-0.7474,z:-0.163},{name:"alpha2",x:-0.7061,y:-0.652,z:-0.2763},{name:"sigma",x:-0.6279,y:-0.6507,z:-0.4271}]}];
p.shoreData = [[{x:-0.2114,y:0.2266,z:0.9508},{x:0.1858,y:0.3188,z:0.9294},{x:0.3333,y:0.1093,z:0.9365},{x:0.5092,y:0.0537,z:0.859},{x:0.5178,y:0.122,z:0.8468},{x:0.3811,y:0.182,z:0.9064},{x:0.5518,y:0.1955,z:0.8107},{x:0.5325,y:0.0913,z:0.8415},{x:0.6521,y:0.0005,z:0.7582},{x:0.6599,y:-0.0552,z:0.7494},{x:0.7263,y:-0.0199,z:0.6871},{x:0.7223,y:-0.1168,z:0.6817},{x:0.7944,y:-0.1191,z:0.5955},{x:0.7857,y:-0.0053,z:0.6186},{x:0.7059,y:0.1082,z:0.7},{x:0.7449,y:0.2227,z:0.6289},{x:0.681,y:0.145,z:0.7178},{x:0.7224,y:0.3147,z:0.6157},{x:0.5977,y:0.3465,z:0.723},{x:0.5499,y:0.4863,z:0.679},{x:0.698,y:0.3537,z:0.6226},{x:0.6462,y:0.4721,z:0.5996},{x:0.707,y:0.463,z:0.5347},{x:0.816,y:0.2808,z:0.5053},{x:0.7832,y:0.1514,z:0.6031},{x:0.8034,y:-0.081,z:0.59},{x:0.8913,y:-0.2764,z:0.3594},{x:0.968,y:-0.2156,z:0.1285},{x:0.9841,y:0.1734,z:0.0387},{x:0.7843,y:0.2596,z:-0.5635},{x:0.7424,y:0.3784,z:-0.5528},{x:0.7322,y:0.6312,z:-0.2559},{x:0.7731,y:0.629,z:-0.0816},{x:0.6185,y:0.7582,z:0.2064},{x:0.7157,y:0.6757,z:0.177},{x:0.731,y:0.4475,z:0.5151},{x:0.709,y:0.6702,z:0.2195},{x:0.4669,y:0.7999,z:0.3771},{x:0.5814,y:0.6426,z:0.4991},{x:0.285,y:0.8918,z:0.3513},{x:0.2137,y:0.9667,z:0.1405},{x:-0.0245,y:0.9218,z:0.3868},{x:-0.2453,y:0.9692,z:0.024},{x:-0.1693,y:0.9583,z:0.2302},{x:-0.2604,y:0.9534,z:0.1521},{x:-0.3239,y:0.9204,z:0.219},{x:-0.2558,y:0.9105,z:0.3249},{x:-0.461,y:0.7336,z:0.4994},{x:-0.4201,y:0.6578,z:0.6251},{x:-0.4979,y:0.6403,z:0.5849},{x:-0.4688,y:0.5737,z:0.6717},{x:-0.4622,y:0.1663,z:0.871},{x:-0.5402,y:0.2121,z:0.8144},{x:-0.4004,y:-0.072,z:0.9135}],[{x:0.3392,y:-0.6758,z:-0.6544},{x:0.5974,y:-0.6792,z:-0.4264},{x:0.6996,y:-0.6096,z:-0.3727},{x:0.8123,y:-0.571,z:-0.1192},{x:0.6662,y:-0.7455,z:0.0175},{x:0.6302,y:-0.767,z:0.1205},{x:0.3556,y:-0.9081,z:0.2212},{x:0.2267,y:-0.9645,z:0.1355},{x:0.0201,y:-0.9619,z:0.2728},{x:0.0499,y:-0.9301,z:0.3639},{x:-0.1023,y:-0.9327,z:0.3458},{x:-0.1031,y:-0.8656,z:0.49},{x:0.0953,y:-0.8597,z:0.5018},{x:0.1497,y:-0.8938,z:0.4228},{x:0.1263,y:-0.8453,z:0.5192},{x:0.2379,y:-0.6864,z:0.6872},{x:0.331,y:-0.6108,z:0.7193},{x:0.2334,y:-0.6318,z:0.7391},{x:0.32,y:-0.4928,z:0.8092},{x:0.0976,y:-0.4563,z:0.8845},{x:0.1089,y:-0.6066,z:0.7875},{x:-0.0263,y:-0.5471,z:0.8366},{x:0.0594,y:-0.3827,z:0.922},{x:-0.0262,y:-0.3095,z:0.9505},{x:-0.0904,y:-0.365,z:0.9266},{x:-0.3301,y:-0.0917,z:0.9395},{x:-0.4597,y:-0.1721,z:0.8712},{x:-0.5529,y:-0.168,z:0.8162},{x:-0.4053,y:-0.2586,z:0.8768},{x:-0.3688,y:-0.5542,z:0.7462},{x:-0.433,y:-0.6465,z:0.6282},{x:-0.3359,y:-0.8584,z:0.3877},{x:-0.3576,y:-0.7715,z:0.5262},{x:-0.2224,y:-0.9127,z:0.3428},{x:0.2151,y:-0.9705,z:0.1093},{x:0.1579,y:-0.9849,z:-0.0705},{x:0.3228,y:-0.8834,z:-0.3398},{x:0.2245,y:-0.7628,z:-0.6064},{x:0.1839,y:-0.575,z:-0.7972}],[{x:0.2665,y:-0.0991,z:0.9587},{x:0.1582,y:-0.0467,z:0.9863},{x:0.0709,y:-0.1896,z:0.9793},{x:0.3541,y:-0.3522,z:0.8663}],[{x:-0.6686,y:0.4442,z:-0.5964},{x:-0.8027,y:0.4056,z:-0.4373},{x:-0.7799,y:0.5977,z:-0.1855},{x:-0.7213,y:0.6338,z:-0.2794},{x:-0.6848,y:0.7032,z:-0.191},{x:-0.6152,y:0.7435,z:-0.2623},{x:-0.5724,y:0.787,z:-0.2303},{x:-0.3773,y:0.8479,z:-0.3725},{x:-0.4027,y:0.7092,z:-0.5787},{x:-0.5643,y:0.6253,z:-0.539}],[{x:0.3616,y:0.0008,z:-0.9323},{x:0.1207,y:-0.2253,z:-0.9668},{x:0.2426,y:-0.377,z:-0.8939},{x:0.0849,y:-0.3383,z:-0.9372},{x:0.0888,y:-0.2744,z:-0.9575},{x:-0.0569,y:-0.3062,z:-0.9503},{x:-0.1779,y:-0.2219,z:-0.9587},{x:-0.2086,y:0.0366,z:-0.9773},{x:-0.3158,y:0.0556,z:-0.9472},{x:-0.2925,y:0.2905,z:-0.9111},{x:0.0418,y:0.4177,z:-0.9076},{x:0.0955,y:0.3336,z:-0.9379},{x:0.2419,y:0.3294,z:-0.9127}],[{x:0.6144,y:0.0008,z:0.789},{x:0.5191,y:-0.045,z:0.8535},{x:0.5882,y:-0.0916,z:0.8035},{x:0.5787,y:-0.0337,z:0.8148},{x:0.6377,y:-0.0634,z:0.7677}],[{x:-0.6171,y:0.5181,z:0.5922},{x:-0.5682,y:0.4253,z:0.7045},{x:-0.5406,y:0.6248,z:0.5634},{x:-0.5873,y:0.6031,z:0.5397}],[{x:0.617,y:0.664,z:-0.4225},{x:0.6136,y:0.7434,z:-0.2664},{x:0.6383,y:0.7414,z:-0.2071},{x:0.6869,y:0.6617,z:-0.3006},{x:0.6624,y:0.6263,z:-0.4111}],[{x:0.4193,y:-0.1148,z:0.9006},{x:0.3867,y:-0.0987,z:0.9169},{x:0.3781,y:-0.1507,z:0.9134},{x:0.4088,y:-0.1714,z:0.8964}],[{x:0.0223,y:-0.7332,z:0.6796},{x:0.0487,y:-0.6887,z:0.7234},{x:-0.0229,y:-0.6822,z:0.7308},{x:0.0178,y:-0.6568,z:0.7539},{x:0.1038,y:-0.6978,z:0.7087},{x:0.0942,y:-0.7242,z:0.6831},{x:0.0629,y:-0.698,z:0.7134},{x:0.0448,y:-0.7453,z:0.6652}],[{x:0.4824,y:0.5331,z:0.6951},{x:0.4116,y:0.5444,z:0.7309},{x:0.4812,y:0.6375,z:0.6017},{x:0.521,y:0.5986,z:0.6085}]];
