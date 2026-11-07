function PlotClass()
{
   var _loc1_ = this;
   _loc1_.velocityColor = 5263536;
   _loc1_.accelerationColor = 11554896;
   _loc1_.radiusColor = 65280;
   _loc1_.plotHeight = 180;
   _loc1_.plotWidth = 315;
   _loc1_.plotVerticalMargin = 10;
   _loc1_.minTickSpacing = 20;
   _loc1_.minMinorTickSpacing = 7;
   _loc1_.maxNumberOfTicks = Math.ceil(_loc1_.plotHeight / _loc1_.minTickSpacing);
   _loc1_.maxNumberOfMinorTicks = _loc1_.maxNumberOfTicks * 11;
   _loc1_.createEmptyMovieClip("vMajorTicksMC",100);
   _loc1_.vMajorTicksMC.createEmptyMovieClip("minorTicksMC",1000);
   _loc1_.createEmptyMovieClip("aMajorTicksMC",200);
   _loc1_.aMajorTicksMC.createEmptyMovieClip("minorTicksMC",1000);
   var _loc2_ = 0;
   var _loc3_;
   while(_loc2_ < _loc1_.maxNumberOfTicks)
   {
      _loc3_ = _loc1_.vMajorTicksMC.attachMovie("Velocity Major Tick","tick" + _loc2_,_loc2_,{_visible:false});
      _loc3_.labelField.textExtent;
      _loc1_.aMajorTicksMC.attachMovie("Acceleration Major Tick","tick" + _loc2_,_loc2_,{_x:_loc1_.plotWidth,_visible:true});
      _loc2_ = _loc2_ + 1;
   }
   _loc2_ = 0;
   while(_loc2_ < _loc1_.maxNumberOfMinorTicks)
   {
      _loc1_.vMajorTicksMC.minorTicksMC.attachMovie("Velocity Minor Tick","minorTick" + _loc2_,_loc2_,{_visible:true});
      _loc1_.aMajorTicksMC.minorTicksMC.attachMovie("Acceleration Minor Tick","minorTick" + _loc2_,_loc2_,{_x:_loc1_.plotWidth,_visible:true});
      _loc2_ = _loc2_ + 1;
   }
   _loc1_.setPhase(0);
}
var p = PlotClass.prototype = new MovieClip();
Object.registerClass("Plot Component",PlotClass);
p.setProperties = function(arg)
{
   var _loc1_ = arg;
   var _loc2_ = this;
   for(var _loc3_ in _loc1_)
   {
      _loc2_[_loc3_] = _loc1_[_loc3_];
   }
   _loc2_.update();
};
p.update = function()
{
   var _loc1_ = this;
   var startTimer = getTimer();
   var floor = Math.floor;
   var ceil = Math.ceil;
   var round = Math.round;
   var abs = Math.abs;
   var log = Math.log;
   var pow = Math.pow;
   var sqrt = Math.sqrt;
   var atan = Math.atan;
   var tan = Math.tan;
   var sin = Math.sin;
   var cos = Math.cos;
   var e = _loc1_.eccentricity;
   var a = _loc1_.semimajorAxis;
   var k1 = sqrt((1 + e) / (1 - e));
   var k2 = a * (1 - e * e);
   var k3 = 1774.53 * _loc1_.primaryMass;
   var k4 = (- k3) / (2 * a);
   var k5 = 0.005931 * _loc1_.primaryMass;
   var t = 50;
   var h = _loc1_.plotHeight;
   var w = _loc1_.plotWidth;
   var m = _loc1_.plotVerticalMargin;
   var minTickSpacing = _loc1_.minTickSpacing;
   var minMinorTickSpacing = _loc1_.minMinorTickSpacing;
   var rMin = a * (1 - _loc1_.maxEccentricity);
   var rMax = a * (1 + _loc1_.maxEccentricity);
   var vMin = sqrt(k4 + k3 / rMax);
   var vMax = sqrt(k4 + k3 / rMin);
   var aMin = k5 / pow(rMax,2);
   var aMax = k5 / pow(rMin,2);
   var vScale = (h - 2 * m) / (vMax - vMin);
   var aScale = (h - 2 * m) / (aMax - aMin);
   var rScale = (h - 2 * m) / (rMax - rMin);
   var xScale = w / (2 * (t - 1));
   var vMC = _loc1_.createEmptyMovieClip("leftVMC",1);
   var aMC = _loc1_.createEmptyMovieClip("leftAMC",10);
   vMC.clear();
   vMC.lineStyle(1,_loc1_.velocityColor,100);
   aMC.clear();
   aMC.lineStyle(1,_loc1_.accelerationColor,100);
   rMC.clear();
   rMC.lineStyle(1,_loc1_.radiusColor,100);
   var r = a * (1 - e);
   rMC.moveTo(0,(- rScale) * (r - rMin));
   var v = sqrt(k4 + k3 / r);
   vMC.moveTo(0,(- vScale) * (v - vMin));
   var ac = k5 / pow(r,2);
   aMC.moveTo(0,(- aScale) * (ac - aMin));
   var maStep = 3.141592653589793 / (t - 1);
   var ma = maStep;
   var _loc2_ = 1;
   var _loc3_;
   while(_loc2_ < t)
   {
      var ea0 = 0;
      _loc3_ = ma + e * sin(ma);
      var c = 0;
      do
      {
         ea0 = _loc3_;
         _loc3_ = ma + e * sin(ea0);
         c++;
      }
      while(abs(_loc3_ - ea0) > 0.001 && c < 100);
      var r = k2 / (1 + e * cos(2 * atan(k1 * tan(_loc3_ / 2))));
      var v = sqrt(k4 + k3 / r);
      var ac = k5 / pow(r,2);
      vMC.lineTo(_loc2_ * xScale,(- vScale) * (v - vMin));
      aMC.lineTo(_loc2_ * xScale,(- aScale) * (ac - aMin));
      rMC.lineTo(_loc2_ * xScale,(- rScale) * (r - rMin));
      ma += maStep;
      _loc2_ = _loc2_ + 1;
   }
   var vMC2 = vMC.duplicateMovieClip("rightVMC",2);
   vMC2._xscale = -100;
   vMC2._x = w;
   var aMC2 = aMC.duplicateMovieClip("rightAMC",11);
   aMC2._xscale = -100;
   aMC2._x = w;
   var rMC2 = rMC.duplicateMovieClip("rightRMC",21);
   rMC2._xscale = -100;
   rMC2._x = w;
   var fvRange = h / vScale;
   var fvMin = vMin - m / vScale;
   var fvMax = fvMin + fvRange;
   var lg = log(minTickSpacing / vScale) / 2.302585092994046;
   var f = floor(lg);
   if(f == lg)
   {
      var majorTickSpacing = pow(10,f);
      var minorTickSpacing = 5 * pow(10,f - 1);
      var p = f;
   }
   else if(lg <= f + 0.698970004336019)
   {
      var majorTickSpacing = 5 * pow(10,f);
      var minorTickSpacing = pow(10,f);
      var p = f;
   }
   else
   {
      var majorTickSpacing = pow(10,f + 1);
      var minorTickSpacing = 5 * pow(10,f);
      var p = f + 1;
   }
   var min = fvMin;
   var max = fvMax;
   var s = 1 / vScale;
   if(minorTickSpacing > minMinorTickSpacing / vScale)
   {
      var majorMC = _loc1_.vMajorTicksMC;
      var minorMC = _loc1_.vMajorTicksMC.minorTicksMC;
      minorMC._visible = true;
      var startTick = minorTickSpacing * ceil(min / minorTickSpacing);
      var numTicks = 1 + floor((max - startTick) / minorTickSpacing);
      var majorCounter = 0;
      var minorCounter = 0;
      var format = _loc1_.formatNumber;
      _loc2_ = 0;
      while(_loc2_ < numTicks)
      {
         var tickValue = startTick + minorTickSpacing * _loc2_;
         var k = tickValue / majorTickSpacing;
         if(abs(k - round(k)) < 1e-9)
         {
            var mc = majorMC["tick" + majorCounter];
            mc.labelField.text = format(tickValue,p);
            majorCounter++;
         }
         else
         {
            var mc = minorMC["minorTick" + minorCounter];
            minorCounter++;
         }
         mc._visible = true;
         mc._y = m - (tickValue - min) / s;
         _loc2_ = _loc2_ + 1;
      }
      _loc2_ = majorCounter;
      while(_loc2_ < _loc1_.maxNumberOfTicks)
      {
         majorMC["tick" + _loc2_]._visible = false;
         _loc2_ = _loc2_ + 1;
      }
      _loc2_ = minorCounter;
      while(_loc2_ < _loc1_.maxNumberOfMinorTicks)
      {
         minorMC["minorTick" + _loc2_]._visible = false;
         _loc2_ = _loc2_ + 1;
      }
   }
   else
   {
      var majorMC = _loc1_.vMajorTicksMC;
      var minorMC = _loc1_.vMajorTicksMC.minorTicksMC;
      minorMC._visible = false;
      var startTick = majorTickSpacing * ceil(min / majorTickSpacing);
      var numTicks = 1 + floor((max - startTick) / majorTickSpacing);
      _loc2_ = 0;
      while(_loc2_ < numTicks)
      {
         var mc = majorMC["tick" + _loc2_];
         mc._visible = true;
         var tickValue = startTick + majorTickSpacing * _loc2_;
         mc.labelField.text = _loc1_.formatNumber(tickValue,p);
         mc._y = m - (tickValue - min) / s;
         _loc2_ = _loc2_ + 1;
      }
      _loc2_ = numTicks;
      while(_loc2_ < _loc1_.maxNumberOfTicks)
      {
         majorMC["tick" + _loc2_]._visible = false;
         _loc2_ = _loc2_ + 1;
      }
   }
   var faRange = h / aScale;
   var faMin = aMin - m / aScale;
   var faMax = faMin + faRange;
   var lg = log(minTickSpacing / aScale) / 2.302585092994046;
   var f = floor(lg);
   if(f == lg)
   {
      var majorTickSpacing = pow(10,f);
      var minorTickSpacing = 5 * pow(10,f - 1);
      var p = f;
   }
   else if(lg <= f + 0.698970004336019)
   {
      var majorTickSpacing = 5 * pow(10,f);
      var minorTickSpacing = pow(10,f);
      var p = f;
   }
   else
   {
      var majorTickSpacing = pow(10,f + 1);
      var minorTickSpacing = 5 * pow(10,f);
      var p = f + 1;
   }
   var min = faMin;
   var max = faMax;
   var s = 1 / aScale;
   if(minorTickSpacing > minMinorTickSpacing * s)
   {
      var majorMC = _loc1_.aMajorTicksMC;
      var minorMC = _loc1_.aMajorTicksMC.minorTicksMC;
      minorMC._visible = true;
      var startTick = minorTickSpacing * ceil(min / minorTickSpacing);
      var numTicks = 1 + floor((max - startTick) / minorTickSpacing);
      var majorCounter = 0;
      var minorCounter = 0;
      var format = _loc1_.formatNumber;
      _loc2_ = 0;
      while(_loc2_ < numTicks)
      {
         var tickValue = startTick + minorTickSpacing * _loc2_;
         var k = tickValue / majorTickSpacing;
         if(abs(k - round(k)) < 1e-9)
         {
            var mc = majorMC["tick" + majorCounter];
            mc.labelField.text = format(tickValue,p);
            majorCounter++;
         }
         else
         {
            var mc = minorMC["minorTick" + minorCounter];
            minorCounter++;
         }
         mc._visible = true;
         mc._y = m - (tickValue - min) / s;
         _loc2_ = _loc2_ + 1;
      }
      _loc2_ = majorCounter;
      while(_loc2_ < _loc1_.maxNumberOfTicks)
      {
         majorMC["tick" + _loc2_]._visible = false;
         _loc2_ = _loc2_ + 1;
      }
      _loc2_ = minorCounter;
      while(_loc2_ < _loc1_.maxNumberOfMinorTicks)
      {
         minorMC["minorTick" + _loc2_]._visible = false;
         _loc2_ = _loc2_ + 1;
      }
   }
   else
   {
      var majorMC = _loc1_.aMajorTicksMC;
      var minorMC = _loc1_.aMajorTicksMC.minorTicksMC;
      minorMC._visible = false;
      var startTick = majorTickSpacing * ceil(min / majorTickSpacing);
      var numTicks = 1 + floor((max - startTick) / majorTickSpacing);
      _loc2_ = 0;
      while(_loc2_ < numTicks)
      {
         var mc = majorMC["tick" + _loc2_];
         mc._visible = true;
         var tickValue = startTick + majorTickSpacing * _loc2_;
         mc.labelField.text = _loc1_.formatNumber(tickValue,p);
         mc._y = m - (tickValue - min) / s;
         _loc2_ = _loc2_ + 1;
      }
      _loc2_ = numTicks;
      while(_loc2_ < _loc1_.maxNumberOfTicks)
      {
         majorMC["tick" + _loc2_]._visible = false;
         _loc2_ = _loc2_ + 1;
      }
   }
   _loc1_.accelerationAxisLabel._x = 10 + _loc1_.aMajorTicksMC.tick1._x + _loc1_.aMajorTicksMC.tick1.labelField._x + _loc1_.aMajorTicksMC.tick1.labelField.textWidth;
};
p.setPhase = function(ma)
{
   this.phaseCursorMC._x = this.plotWidth * ((ma / 6.283185307179586 % 1 + 1) % 1);
};
p.formatNumber = function(x, place)
{
   var _loc2_ = - place;
   if(_loc2_ <= 0)
   {
      var p = Math.pow(10,place);
      return String(Math.round(p * x) / p);
   }
   if(_loc2_ > 14)
   {
      _loc2_ = 14;
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
