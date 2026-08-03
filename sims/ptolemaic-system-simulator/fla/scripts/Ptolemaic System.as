function PtolemaicSystemClass()
{
   var _loc3_ = this;
   _loc3_.attachMovie("New Sun","_sunMC",100);
   _loc3_.attachMovie("Circle","_deferentMC",101);
   _loc3_.attachMovie("Deferent Center","_deferentCenterMC",103);
   _loc3_.attachMovie("Earth","_earthMC",102);
   _loc3_.attachMovie("Equant Point","_equantPointMC",106);
   _loc3_.attachMovie("Circle","_epicycleMC",104);
   _loc3_.attachMovie("Planet","_planetMC",105);
   _loc3_.createEmptyMovieClip("_equantVectorMC",22);
   _loc3_.createEmptyMovieClip("_earthPlanetVectorMC",23);
   _loc3_.createEmptyMovieClip("_epicyclePlanetLineMC",24);
   _loc3_.createEmptyMovieClip("_earthSunLineMC",25);
   var mc = _loc3_.createEmptyMovieClip("_referenceMC",20);
   mc.lineStyle(1,0,100);
   var symbols = "^_`abcdefghi";
   var names = ["Aries","Taurus","Gemini","Cancer","Leo","Virgo","Libra","Scorpius","Sagittarius","Capricorn","Aquarius","Pisces"];
   var _loc1_ = 0;
   var _loc2_;
   while(_loc1_ < 12)
   {
      _loc2_ = (15 + _loc1_ * 30) * 3.141592653589793 / 180;
      var r = 260;
      var x = r * Math.cos(_loc2_);
      var y = (- r) * Math.sin(_loc2_);
      mc.attachMovie("Zodiac Symbol","_" + _loc1_,_loc1_,{_x:x,_y:y,symbol:symbols.charAt(_loc1_),name:names[_loc1_],_xscale:70,_yscale:70});
      _loc2_ = _loc1_ * 30 * 3.141592653589793 / 180;
      var r1 = 250;
      var r2 = 270;
      var x1 = r1 * Math.cos(_loc2_);
      var y1 = (- r1) * Math.sin(_loc2_);
      var x2 = r2 * Math.cos(_loc2_);
      var y2 = (- r2) * Math.sin(_loc2_);
      mc.moveTo(x1,y1);
      mc.lineTo(x2,y2);
      _loc1_ = _loc1_ + 1;
   }
   _loc3_._earthX = 0;
   _loc3_._earthY = 0;
   _loc3_._deferentX = -15;
   _loc3_._deferentY = 30;
   _loc3_._equantX = 10;
   _loc3_._equantY = 10;
   _loc3_._deferentRadius = 100;
   _loc3_._epicycleRadius = 60;
   _loc3_._isSuperiorPlanet = true;
   _loc3_._anomaly = 0;
   _loc3_._sunAngle = 0;
   _loc3_._sunRate = 0.0012566370614359172;
   _loc3_._time = 0;
   _loc3_._animationRate = 0.1;
   _loc3_._sunRate = 0.0172025806756283;
   _loc3_._anomalyRate = 0.009146573682278667;
   _loc3_.setPathTime(2.5);
   _loc3_._time = 0;
   _loc3_._timeLast = getTimer();
   _loc3_.onEnterFrame = _loc3_.onEnterFrameFunc;
   _loc3_.updateLayout();
}
var p = PtolemaicSystemClass.prototype = new MovieClip();
Object.registerClass("Ptolemaic System",PtolemaicSystemClass);
p.outerLimit = 0.6;
p.pathColor = 16737894;
p._numSegments = 20;
p._samplingInterval = 1.5;
p.setAnomalyRate = function(arg)
{
   this._anomalyRate = arg * 0.017453292519943295;
   this.clearPath();
};
p.resetPathMC = function()
{
   var _loc2_ = this;
   var _loc3_ = _loc2_.createEmptyMovieClip("_pathMC",110);
   _loc2_._segmentsArray = [];
   var n = _loc2_._numSegments;
   var _loc1_ = 0;
   while(_loc1_ < n)
   {
      _loc2_._segmentsArray.push(_loc3_.createEmptyMovieClip("_" + _loc1_,_loc1_));
      _loc1_ = _loc1_ + 1;
   }
   _loc2_._tempSegmentMC = _loc3_.createEmptyMovieClip("_tempSegmentMC",_loc1_);
   _loc2_._currentSegment = 0;
   _loc2_._lastPathTime = _loc2_._time;
   _loc2_._lastAnomaly = _loc2_._anomaly;
   _loc2_._lastSunAngle = _loc2_._sunAngle;
   _loc2_._lastPathPlanetX = _loc2_._planetMC._x;
   _loc2_._lastPathPlanetY = _loc2_._planetMC._y;
   _loc2_._pathTimeCounter = 0;
};
p.updatePath = function()
{
   var _loc1_ = this;
   var startTimer = getTimer();
   var cos = Math.cos;
   var _loc3_ = Math.sin;
   var asin = Math.asin;
   var atan2 = Math.atan2;
   var sampInt = _loc1_._samplingInterval;
   var numSegs = _loc1_._numSegments;
   var earX = _loc1_._earthX;
   var earY = _loc1_._earthY;
   var defX = _loc1_._deferentX;
   var defY = _loc1_._deferentY;
   var eqAngle = _loc1_._equantAngle;
   var defR = _loc1_._deferentRadius;
   var epiR = _loc1_._epicycleRadius;
   var anomaly = _loc1_._lastAnomaly;
   var sunAngle = _loc1_._lastSunAngle;
   var anomalyStep = sampInt * _loc1_._anomalyRate;
   var sunAngleStep = sampInt * _loc1_._sunRate;
   var timePerSeg = _loc1_._pathTime / _loc1_._numSegments;
   var k = _loc1_._equantDistance / defR;
   var dt = _loc1_._time - _loc1_._lastPathTime;
   var numSteps = Math.floor(dt / sampInt);
   var lastPlaX = _loc1_._lastPathPlanetX;
   var lastPlaY = _loc1_._lastPathPlanetY;
   if(lastPlaX == null)
   {
      lastPlaX = _loc1_._planetMC._x;
      lastPlaY = _loc1_._planetMC._y;
   }
   var lonArray = [];
   var segList = _loc1_._segmentsArray;
   var cs = _loc1_._currentSegment;
   var mc = segList[cs];
   mc.lineStyle(1,_loc1_.pathColor,100);
   mc.moveTo(lastPlaX,lastPlaY);
   var timeCounter = _loc1_._pathTimeCounter;
   var isSup = _loc1_._isSuperiorPlanet;
   var i = 0;
   var _loc2_;
   while(i < numSteps)
   {
      anomaly += anomalyStep;
      sunAngle += sunAngleStep;
      timeCounter += sampInt;
      if(timeCounter > timePerSeg)
      {
         timeCounter %= timePerSeg;
         cs = (cs + 1) % numSegs;
         mc = segList[cs];
         mc.clear();
         mc.lineStyle(1,_loc1_.pathColor,100);
         mc.moveTo(lastPlaX,lastPlaY);
      }
      if(isSup)
      {
         var alpha = anomaly - eqAngle;
         _loc2_ = k * _loc3_(3.141592653589793 - alpha);
         if(_loc2_ < -1)
         {
            _loc2_ = -1;
         }
         else if(_loc2_ > 1)
         {
            _loc2_ = 1;
         }
         var beta = alpha - asin(_loc2_);
         var angle = eqAngle + beta;
         var epiX = defX + defR * cos(angle);
         var epiY = - (defY + defR * _loc3_(angle));
         var plaX = epiX + epiR * cos(sunAngle);
         var plaY = epiY + (- epiR) * _loc3_(sunAngle);
      }
      else
      {
         var alpha = sunAngle - eqAngle;
         _loc2_ = k * _loc3_(3.141592653589793 - alpha);
         if(_loc2_ < -1)
         {
            _loc2_ = -1;
         }
         else if(_loc2_ > 1)
         {
            _loc2_ = 1;
         }
         var beta = alpha - asin(_loc2_);
         var angle = eqAngle + beta;
         var epiX = defX + defR * cos(angle);
         var epiY = - (defY + defR * _loc3_(angle));
         var plaX = epiX + epiR * cos(anomaly);
         var plaY = epiY + (- epiR) * _loc3_(anomaly);
      }
      var lon = atan2(plaY - earY,plaX - earX);
      lonArray.push(lon);
      mc.lineTo(plaX,plaY);
      lastPlaX = plaX;
      lastPlaY = plaY;
      i++;
   }
   _loc1_._lonArray = lonArray;
   _loc1_._lastPathPlanetX = lastPlaX;
   _loc1_._lastPathPlanetY = lastPlaY;
   _loc1_._currentSegment = cs;
   _loc1_._pathTimeCounter = timeCounter;
   var mc = _loc1_._tempSegmentMC;
   mc.clear();
   mc.lineStyle(1,16711680,100);
   mc.moveTo(lastPlaX,lastPlaY);
   mc.lineTo(_loc1_._planetMC._x,_loc1_._planetMC._y);
   var alphaStep = 100 / numSegs;
   var alpha = alphaStep;
   var i = 0;
   while(i < numSegs)
   {
      segList[(cs + i + 1) % numSegs]._alpha = alpha;
      alpha += alphaStep;
      i++;
   }
   _loc1_._lastPathTime += numSteps * sampInt;
   _loc1_._lastAnomaly = anomaly;
   _loc1_._lastSunAngle = sunAngle;
};
p.setPathTime = function(arg)
{
   var _loc1_ = this;
   _loc1_._pathTime = arg * 365.24667;
   _loc1_.zodiacMC.ghostingTime = _loc1_._pathTime;
   _loc1_.clearPath();
};
p.clearPath = function()
{
   this.resetPathMC();
   this.zodiacMC.clearGhosting();
};
p.getAnimationRate = function()
{
   return this._animationRate * 1000;
};
p.setAnimationRate = function(arg)
{
   this._animationRate = arg / 1000;
};
p.addProperty("animationRate",p.getAnimationRate,p.setAnimationRate);
p.getAnimationState = function()
{
   return this.onEnterFrame == this.onEnterFrameFunc;
};
p.setAnimationState = function(arg)
{
   var _loc1_ = this;
   if(arg)
   {
      _loc1_._timeLast = getTimer();
      _loc1_.onEnterFrame = _loc1_.onEnterFrameFunc;
   }
   else
   {
      delete _loc1_.onEnterFrame;
   }
};
p.addProperty("animate",p.getAnimationState,p.setAnimationState);
p.onEnterFrameFunc = function()
{
   var _loc1_ = this;
   var _loc3_ = getTimer();
   var _loc2_ = _loc1_._animationRate * (_loc3_ - _loc1_._timeLast);
   _loc1_._time += _loc2_;
   _loc1_._anomaly += _loc1_._anomalyRate * _loc2_;
   _loc1_._sunAngle += _loc1_._sunRate * _loc2_;
   _loc1_.update();
   _loc1_.updatePath();
   _loc1_.updateZodiacStrip();
   _loc1_._timeLast = _loc3_;
};
p.updateZodiacStrip = function()
{
   var _loc1_ = this;
   _loc1_.zodiacMC.setSunLongitude(- _loc1_._sunAngle);
   _loc1_.zodiacMC.setPlanetLongitude(_loc1_._planetLongitude,_loc1_._lonArray);
};
p.setPlanetType = function(arg)
{
   this._isSuperiorPlanet = arg == "superior";
   this.clearPath();
};
p.update = function()
{
   var _loc1_ = this;
   var startTimer = getTimer();
   var dx = _loc1_._deferentX;
   var dy = _loc1_._deferentY;
   var d = _loc1_._equantDistance;
   var _loc2_;
   if(_loc1_._isSuperiorPlanet)
   {
      var alpha = _loc1_._anomaly - _loc1_._equantAngle;
      var R = _loc1_._deferentRadius;
      _loc2_ = d / R * Math.sin(3.141592653589793 - alpha);
      if(_loc2_ < -1)
      {
         _loc2_ = -1;
      }
      else if(_loc2_ > 1)
      {
         _loc2_ = 1;
      }
      var beta = alpha - Math.asin(_loc2_);
      var angle = _loc1_._equantAngle + beta;
      _loc1_._epicycleMC._x = _loc1_._deferentX + _loc1_._deferentRadius * Math.cos(angle);
      _loc1_._epicycleMC._y = - (_loc1_._deferentY + _loc1_._deferentRadius * Math.sin(angle));
      _loc1_._planetMC._x = _loc1_._epicycleMC._x + _loc1_._epicycleRadius * Math.cos(_loc1_._sunAngle);
      _loc1_._planetMC._y = _loc1_._epicycleMC._y + (- _loc1_._epicycleRadius) * Math.sin(_loc1_._sunAngle);
   }
   else
   {
      var alpha = _loc1_._sunAngle - _loc1_._equantAngle;
      var R = _loc1_._deferentRadius;
      _loc2_ = d / R * Math.sin(3.141592653589793 - alpha);
      if(_loc2_ < -1)
      {
         _loc2_ = -1;
      }
      else if(_loc2_ > 1)
      {
         _loc2_ = 1;
      }
      var beta = alpha - Math.asin(_loc2_);
      var angle = _loc1_._equantAngle + beta;
      _loc1_._epicycleMC._x = _loc1_._deferentX + _loc1_._deferentRadius * Math.cos(angle);
      _loc1_._epicycleMC._y = - (_loc1_._deferentY + _loc1_._deferentRadius * Math.sin(angle));
      _loc1_._planetMC._x = _loc1_._epicycleMC._x + _loc1_._epicycleRadius * Math.cos(_loc1_._anomaly);
      _loc1_._planetMC._y = _loc1_._epicycleMC._y + (- _loc1_._epicycleRadius) * Math.sin(_loc1_._anomaly);
   }
   _loc1_._equantVectorMC.clear();
   _loc1_._equantVectorMC.lineStyle(1,10526880);
   _loc1_._equantVectorMC.moveTo(_loc1_._equantPointMC._x,_loc1_._equantPointMC._y);
   _loc1_._equantVectorMC.lineTo(_loc1_._epicycleMC._x,_loc1_._epicycleMC._y);
   _loc1_._epicyclePlanetLineMC.clear();
   _loc1_._epicyclePlanetLineMC.lineStyle(1,10526880);
   _loc1_._epicyclePlanetLineMC.moveTo(_loc1_._epicycleMC._x,_loc1_._epicycleMC._y);
   _loc1_._epicyclePlanetLineMC.lineTo(_loc1_._planetMC._x,_loc1_._planetMC._y);
   _loc1_._earthSunLineMC.clear();
   _loc1_._earthSunLineMC.lineStyle(1,10526880);
   _loc1_._earthSunLineMC.moveTo(_loc1_._earthMC._x,_loc1_._earthMC._y);
   _loc1_._earthSunLineMC.lineTo(225 * Math.cos(_loc1_._sunAngle),-225 * Math.sin(_loc1_._sunAngle));
   _loc1_._sunMC._x = _loc1_._earthX + 225 * Math.cos(_loc1_._sunAngle);
   _loc1_._sunMC._y = _loc1_._earthY - 225 * Math.sin(_loc1_._sunAngle);
   var _loc3_ = Math.atan2(_loc1_._planetMC._y - _loc1_._earthMC._y,_loc1_._planetMC._x - _loc1_._earthMC._x);
   _loc1_._planetLongitude = _loc3_;
   _loc1_._earthPlanetVectorMC.clear();
   _loc1_._earthPlanetVectorMC.lineStyle(1,10526880);
   _loc1_._earthPlanetVectorMC.moveTo(0,0);
   _loc1_._earthPlanetVectorMC.lineTo(250 * Math.cos(_loc3_),250 * Math.sin(_loc3_));
   _loc1_._lastPlanetX = _loc1_._planetMC._x;
   _loc1_._lastPlanetY = _loc1_._planetMC._y;
};
p.setSunAngle = function(arg)
{
   var _loc1_ = this;
   _loc1_._sunAngle = (arg % 6.283185307179586 + 6.283185307179586) % 6.283185307179586;
   _loc1_.clearPath();
   _loc1_.update();
   _loc1_.updatePath();
   _loc1_.updateZodiacStrip();
};
p.updateLayout = function()
{
   var _loc1_ = this;
   _loc1_._equantPointMC._x = _loc1_._equantX;
   _loc1_._equantPointMC._y = - _loc1_._equantY;
   _loc1_._deferentMC._x = _loc1_._deferentCenterMC._x = _loc1_._deferentX;
   _loc1_._deferentMC._y = _loc1_._deferentCenterMC._y = - _loc1_._deferentY;
   _loc1_._deferentMC._xscale = _loc1_._deferentMC._yscale = _loc1_._deferentRadius;
   _loc1_._epicycleMC._xscale = _loc1_._epicycleMC._yscale = _loc1_._epicycleRadius;
   _loc1_.update();
};
p.setDeferentRadius = function(dr)
{
   var _loc1_ = this;
   var _loc3_ = _loc1_._equantX;
   var _loc2_ = _loc1_._equantY;
   var dx = _loc1_._deferentX;
   var dy = _loc1_._deferentY;
   var r = Math.sqrt((_loc3_ - dx) * (_loc3_ - dx) + (_loc2_ - dy) * (_loc2_ - dy));
   if(r > _loc1_.outerLimit * dr)
   {
      dr = r / _loc1_.outerLimit;
   }
   _loc1_._deferentRadius = dr;
   _loc1_.clearPath();
   _loc1_.updateLayout();
};
p.setDeferentCenter = function(dx, dy)
{
   var _loc1_ = this;
   var ex = _loc1_._equantX;
   var ey = _loc1_._equantY;
   var ox = _loc1_._earthX;
   var oy = _loc1_._earthY;
   var _loc2_ = _loc1_.outerLimit * _loc1_._deferentRadius;
   var ddo = Math.sqrt((dx - ox) * (dx - ox) + (dy - oy) * (dy - oy));
   var dde = Math.sqrt((dx - ex) * (dx - ex) + (dy - ey) * (dy - ey));
   var _loc3_;
   if(ddo > _loc2_ || dde > _loc2_)
   {
      var eox = ex - ox;
      var eoy = ey - oy;
      var cosTheta = 1 - (eox * eox + eoy * eoy) / (2 * _loc2_ * _loc2_);
      if(cosTheta < -1)
      {
         cosTheta = -1;
      }
      else if(cosTheta > 1)
      {
         cosTheta = 1;
      }
      var alpha = Math.acos(cosTheta) / 2;
      var Lx = _loc2_ * Math.sin(alpha);
      if(eox == 0 && eoy == 0)
      {
         var angle = Math.atan2(dy - ey,dx - ex);
         dx = ex + _loc2_ * Math.cos(angle);
         dy = ey + _loc2_ * Math.sin(angle);
      }
      else
      {
         var hx = ox + eox / 2;
         var hy = oy + eoy / 2;
         var theta = Math.atan2(eoy,eox);
         var cosTheta = Math.cos(theta);
         var sinTheta = Math.sin(theta);
         var x_ = dx - hx;
         var y_ = dy - hy;
         var x = x_ * cosTheta + y_ * sinTheta;
         var y = (- x_) * sinTheta + y_ * cosTheta;
         _loc3_ = y / x;
         if(x < 0)
         {
            var xc = Lx;
         }
         else
         {
            var xc = - Lx;
         }
         var a = 1 + _loc3_ * _loc3_;
         var b = 2 * _loc3_ * y - 2 * _loc3_ * _loc3_ * x - 2 * xc;
         var c = xc * xc + _loc3_ * _loc3_ * x * x - 2 * _loc3_ * x * y + y * y - _loc2_ * _loc2_;
         var q = Math.sqrt(b * b - 4 * a * c);
         var x1 = (- b + q) / (2 * a);
         var x2 = (- b - q) / (2 * a);
         if(x < 0)
         {
            if(x1 < 0)
            {
               var newX = x1;
            }
            else
            {
               var newX = x2;
            }
         }
         else if(x1 > 0)
         {
            var newX = x1;
         }
         else
         {
            var newX = x2;
         }
         var newY = _loc3_ * (newX - x) + y;
         var x_ = newX * cosTheta - newY * sinTheta;
         var y_ = newX * sinTheta + newY * cosTheta;
         var dx = x_ + hx;
         var dy = y_ + hy;
      }
   }
   _loc1_._equantAngle = Math.atan2(ey - dy,ex - dx);
   _loc1_._equantDistance = Math.sqrt((ex - dx) * (ex - dx) + (ey - dy) * (ey - dy));
   _loc1_._deferentX = dx;
   _loc1_._deferentY = dy;
   _loc1_.clearPath();
   _loc1_.updateLayout();
};
p.setEquantCenter = function(ex, ey)
{
   var _loc1_ = this;
   var _loc3_ = _loc1_._deferentX;
   var _loc2_ = _loc1_._deferentY;
   var r = Math.sqrt((ex - _loc3_) * (ex - _loc3_) + (ey - _loc2_) * (ey - _loc2_));
   if(r > _loc1_.outerLimit * _loc1_._deferentRadius)
   {
      r = _loc1_.outerLimit * _loc1_._deferentRadius;
      var angle = Math.atan2(ey - _loc2_,ex - _loc3_);
      ex = _loc3_ + r * Math.cos(angle);
      ey = _loc2_ + r * Math.sin(angle);
   }
   _loc1_._equantAngle = Math.atan2(ey - _loc2_,ex - _loc3_);
   _loc1_._equantDistance = Math.sqrt((ex - _loc3_) * (ex - _loc3_) + (ey - _loc2_) * (ey - _loc2_));
   _loc1_._equantX = ex;
   _loc1_._equantY = ey;
   _loc1_.clearPath();
   _loc1_.updateLayout();
};
p.setEccentricity = function(arg)
{
   var _loc1_ = this;
   if(arg > _loc1_.outerLimit * _loc1_._deferentRadius)
   {
      arg = _loc1_.outerLimit * _loc1_._deferentRadius;
   }
   _loc1_._eccentricity = arg;
   var x = _loc1_._eccentricity * Math.cos(_loc1_._apogeeAngle);
   var y = _loc1_._eccentricity * Math.sin(_loc1_._apogeeAngle);
   _loc1_._deferentX = _loc1_._earthX + x;
   _loc1_._deferentY = _loc1_._earthY + y;
   _loc1_._equantX = _loc1_._earthX + 2 * x;
   _loc1_._equantY = _loc1_._earthY + 2 * y;
   var _loc2_ = _loc1_._equantY - _loc1_._deferentY;
   var _loc3_ = _loc1_._equantX - _loc1_._deferentX;
   _loc1_._equantAngle = Math.atan2(_loc2_,_loc3_);
   _loc1_._equantDistance = Math.sqrt(_loc3_ * _loc3_ + _loc2_ * _loc2_);
   _loc1_.clearPath();
   _loc1_.updateLayout();
};
p.setApogeeAngle = function(arg)
{
   var _loc1_ = this;
   _loc1_._apogeeAngle = arg * 0.017453292519943295;
   var x = _loc1_._eccentricity * Math.cos(_loc1_._apogeeAngle);
   var y = _loc1_._eccentricity * Math.sin(_loc1_._apogeeAngle);
   _loc1_._deferentX = _loc1_._earthX + x;
   _loc1_._deferentY = _loc1_._earthY + y;
   _loc1_._equantX = _loc1_._earthX + 2 * x;
   _loc1_._equantY = _loc1_._earthY + 2 * y;
   var _loc2_ = _loc1_._equantY - _loc1_._deferentY;
   var _loc3_ = _loc1_._equantX - _loc1_._deferentX;
   _loc1_._equantAngle = Math.atan2(_loc2_,_loc3_);
   _loc1_._equantDistance = Math.sqrt(_loc3_ * _loc3_ + _loc2_ * _loc2_);
   _loc1_.clearPath();
   _loc1_.updateLayout();
};
p.setEpicycleRadius = function(arg)
{
   var _loc1_ = this;
   _loc1_._epicycleRadius = arg;
   _loc1_.clearPath();
   _loc1_.updateLayout();
};
