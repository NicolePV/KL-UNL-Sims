function Kepler3rdPlotClass()
{
   var mc = this.createEmptyMovieClip("linearPlotMC",1);
   mc.createEmptyMovieClip("curveMC",2);
   mc.createEmptyMovieClip("dotsMC",3);
   mc.createEmptyMovieClip("linesMC",4);
   mc.attachMovie("Kepler 3rd Plot User Planet Dot","userPlanetDotMC",5);
   var _loc2_ = this.planetData;
   var _loc1_ = 0;
   var _loc3_;
   while(_loc1_ < _loc2_.length)
   {
      _loc2_[_loc1_].P = Math.pow(_loc2_[_loc1_].a,1.5);
      _loc3_ = mc.dotsMC.attachMovie("Kepler 3rd Plot Dot","_" + _loc1_,_loc1_);
      _loc3_.labelMC.labelField.text = _loc2_[_loc1_].label;
      _loc1_ = _loc1_ + 1;
   }
   var mc = this.createEmptyMovieClip("logPlotMC",2);
   mc.createEmptyMovieClip("dotsMC",2);
   mc.createEmptyMovieClip("linesMC",3);
   mc.attachMovie("Kepler 3rd Plot User Planet Dot","userPlanetDotMC",4);
   this.showPlanetPoints(false);
   this.initializeLinearPlot();
   this.initializeLogPlot();
   this.setSemimajorAxis(1);
   this.setPlotType("linear");
}
var p = Kepler3rdPlotClass.prototype = new MovieClip();
Object.registerClass("Kepler 3rd Plot",Kepler3rdPlotClass);
p.curveThickness = 0;
p.curveColor = 0;
p.curveAlpha = 100;
p.plotHeight = 150;
p.plotWidth = 230;
p.tickmarkLength = 5;
p.minSemimajorForLog = 0.095;
p.maxSemimajorForLog = 105;
p.minPeriodForLog = 0.025;
p.maxPeriodForLog = 1300;
p.preferredCursorPosition = 0.7;
p.minMaximumSemimajor = 0.75;
p.linearPlotYMargin = 15;
p.planetData = [{a:0.387,label:"M"},{a:0.723,label:"V"},{a:1,label:"E"},{a:1.524,label:"M"},{a:5.203,label:"J"},{a:9.54,label:"S"},{a:19.18,label:"U"},{a:30.06,label:"N"},{a:39.44,label:"P"}];
p.showPlanetPoints = function(arg)
{
   var _loc1_ = this;
   if(arg)
   {
      _loc1_.logPlotMC.dotsMC._visible = true;
      _loc1_.linearPlotMC.dotsMC._visible = true;
   }
   else
   {
      _loc1_.logPlotMC.dotsMC._visible = false;
      _loc1_.linearPlotMC.dotsMC._visible = false;
   }
};
p.setPlotType = function(arg)
{
   var _loc1_ = this;
   if(arg == "linear")
   {
      _loc1_.logPlotMC._visible = false;
      _loc1_.linearPlotMC._visible = true;
   }
   else if(arg == "log")
   {
      _loc1_.logPlotMC._visible = true;
      _loc1_.linearPlotMC._visible = false;
   }
};
p.setSemimajorAxis = function(arg)
{
   var _loc1_ = this;
   _loc1_._semimajorAxis = arg;
   _loc1_.updateLogPlot();
   _loc1_.updateLinearPlot();
};
p.updateLogPlot = function()
{
   var _loc1_ = this;
   var startTimer = getTimer();
   var _loc2_ = Math.log;
   var a = _loc1_._semimajorAxis;
   var P = Math.pow(a,1.5);
   var logMaxA = _loc2_(_loc1_.maxSemimajorForLog);
   var logMinA = _loc2_(_loc1_.minSemimajorForLog);
   var logMinP = _loc2_(_loc1_.minPeriodForLog);
   var yScale = (- _loc1_.plotHeight) / (_loc2_(_loc1_.maxPeriodForLog) - logMinP);
   var xScale = _loc1_.plotWidth / (logMaxA - logMinA);
   var logDot = _loc1_.logPlotMC.userPlanetDotMC;
   var x = xScale * (_loc2_(a) - logMinA);
   var y = yScale * (_loc2_(P) - logMinP);
   logDot._x = x;
   logDot._y = y;
   var _loc3_ = _loc1_.logPlotMC.linesMC;
   _loc3_.clear();
   _loc3_.lineStyle(1,13421772,100);
   _loc3_.moveTo(x,0);
   _loc3_.lineTo(x,y);
   _loc3_.lineTo(0,y);
};
p.updateLinearPlot = function()
{
   var startTimer = getTimer();
   var pow = Math.pow;
   var a = this._semimajorAxis;
   var maxA = a / this.preferredCursorPosition;
   if(maxA < this.minMaximumSemimajor)
   {
      maxA = this.minMaximumSemimajor;
   }
   var maxP = pow(maxA,1.5);
   var yScale = (- (this.plotHeight - this.linearPlotYMargin)) / maxP;
   var xScale = this.plotWidth / maxA;
   var _loc2_ = this.linearPlotMC.userPlanetDotMC;
   var x = a * xScale;
   var y = pow(a,1.5) * yScale;
   _loc2_._x = x;
   _loc2_._y = y;
   _loc2_ = this.linearPlotMC.linesMC;
   _loc2_.clear();
   _loc2_.lineStyle(1,13421772,100);
   _loc2_.moveTo(x,0);
   _loc2_.lineTo(x,y);
   _loc2_.lineTo(0,y);
   var dotsMC = this.linearPlotMC.dotsMC;
   var w = this.plotWidth;
   var planets = this.planetData;
   var i = 0;
   while(i < planets.length)
   {
      var x = xScale * planets[i].a;
      var y = yScale * planets[i].P;
      _loc2_ = dotsMC["_" + i];
      if(x >= w)
      {
         _loc2_._visible = false;
      }
      else
      {
         _loc2_._visible = true;
         _loc2_._x = x;
         _loc2_._y = y;
      }
      i++;
   }
   var xLabelMargin = 0;
   var yLabelMargin = 7;
   var yLabelVerticalOffset = -2;
   var xLabelHorizontalOffset = -2;
   var tickLength = this.tickmarkLength;
   var _loc3_ = 1;
   _loc2_ = this.linearPlotMC.createEmptyMovieClip("axisMC",1);
   _loc2_.clear();
   _loc2_.lineStyle(0,0,100);
   var flooredLogMaxA = Math.floor(Math.log(maxA) / 2.302585092994046);
   var majorStep = pow(10,flooredLogMaxA);
   var numMajors = 1 + Math.floor(maxA / majorStep);
   if(numMajors == 2)
   {
      majorStep /= 5;
      var numMajors = 1 + Math.floor(maxA / majorStep);
   }
   var i = 0;
   var _loc1_;
   while(i < numMajors)
   {
      var x = i * majorStep * xScale;
      _loc2_.moveTo(x,0);
      _loc2_.lineTo(x,tickLength);
      _loc2_.createTextField("_" + _loc3_,_loc3_,0,0,0,0);
      _loc1_ = _loc2_["_" + _loc3_];
      _loc3_ = _loc3_ + 1;
      _loc1_.autoSize = "center";
      _loc1_.embedFonts = true;
      _loc1_.type = "dynamic";
      _loc1_.selectable = false;
      _loc1_.setNewTextFormat(new TextFormat("Verdana",10,0));
      _loc1_.text = i * majorStep;
      _loc1_._x = x - _loc1_.textWidth / 2 + xLabelHorizontalOffset;
      _loc1_._y = tickLength + xLabelMargin;
      i++;
   }
   var maxP = (- this.plotHeight) / yScale;
   var flooredLogMaxP = Math.floor(Math.log(maxP) / 2.302585092994046);
   var majorStep = pow(10,flooredLogMaxP);
   var numMajors = 1 + Math.floor(maxP / majorStep);
   if(numMajors == 2)
   {
      majorStep /= 5;
      var numMajors = 1 + Math.floor(maxP / majorStep);
   }
   var i = 0;
   while(i < numMajors)
   {
      var y = i * majorStep * yScale;
      _loc2_.moveTo(0,y);
      _loc2_.lineTo(- tickLength,y);
      _loc2_.createTextField("_" + _loc3_,_loc3_,0,0,0,0);
      _loc1_ = _loc2_["_" + _loc3_];
      _loc3_ = _loc3_ + 1;
      _loc1_.autoSize = "center";
      _loc1_.embedFonts = true;
      _loc1_.type = "dynamic";
      _loc1_.selectable = false;
      _loc1_.setNewTextFormat(new TextFormat("Verdana",10,0));
      _loc1_.text = i * majorStep;
      _loc1_._y = y - _loc1_.textHeight / 2 + yLabelVerticalOffset;
      _loc1_._x = - (tickLength + _loc1_.textWidth + yLabelMargin);
      i++;
   }
};
p.initializeLinearPlot = function()
{
   var sqrt = Math.sqrt;
   var pow = Math.pow;
   var yScale = - (this.plotHeight - this.linearPlotYMargin);
   var xScale = this.plotWidth;
   var n = 6;
   var step = 1 / n;
   var _loc3_ = 0;
   var a0_sqrt = 0;
   var mc = this.linearPlotMC.curveMC;
   mc.clear();
   mc.lineStyle(this.curveThickness,this.curveColor,this.curveAlpha);
   mc.moveTo(0,0);
   var i = 0;
   var _loc1_;
   var _loc2_;
   while(i < n)
   {
      _loc1_ = _loc3_ + step;
      _loc2_ = sqrt(_loc1_);
      var P1 = _loc1_ * _loc2_;
      var ac = 0.3333333333333333 * (_loc3_ + _loc1_ + a0_sqrt * _loc2_);
      var Pc = a0_sqrt * (1.5 * ac - 0.5 * _loc3_);
      mc.curveTo(ac * xScale,Pc * yScale,_loc1_ * xScale,P1 * yScale);
      _loc3_ = _loc1_;
      a0_sqrt = _loc2_;
      i++;
   }
};
p.initializeLogPlot = function()
{
   var startTimer = getTimer();
   var log = Math.log;
   var _loc1_ = this.logPlotMC;
   _loc1_.clear();
   _loc1_.lineStyle(this.curveThickness,this.curveColor,this.curveAlpha);
   var logMaxA = log(this.maxSemimajorForLog);
   var logMinA = log(this.minSemimajorForLog);
   var logMaxP = log(this.maxPeriodForLog);
   var logMinP = log(this.minPeriodForLog);
   var yScale = (- this.plotHeight) / (logMaxP - logMinP);
   var xScale = this.plotWidth / (logMaxA - logMinA);
   var y = yScale * (1.5 * logMinA - logMinP);
   _loc1_.moveTo(0,y);
   var y = yScale * (1.5 * logMaxA - logMinP);
   _loc1_.lineTo(this.plotWidth,y);
   var planets = this.planetData;
   var i = 0;
   while(i < planets.length)
   {
      var logA = log(planets[i].a);
      var logX = xScale * (logA - logMinA);
      var logY = yScale * (1.5 * logA - logMinP);
      var dot = _loc1_.dotsMC.attachMovie("Kepler 3rd Plot Dot","_" + i,i,{_x:logX,_y:logY});
      dot.labelMC.labelField.text = planets[i].label;
      i++;
   }
   var xLabelMargin = 0;
   var yLabelMargin = 7;
   var yLabelVerticalOffset = -2;
   var xLabelHorizontalOffset = -2;
   var _loc3_ = this.tickmarkLength;
   var _loc2_ = 1;
   _loc1_ = this.logPlotMC.createEmptyMovieClip("axisMC",1);
   _loc1_.clear();
   _loc1_.lineStyle(0,0,100);
   var pLower = Math.floor(logMinA / 2.302585092994046);
   var nLower = Math.pow(10,pLower);
   var mLower = Math.ceil(this.minSemimajorForLog / nLower);
   var pUpper = Math.floor(logMaxA / 2.302585092994046);
   var nUpper = Math.pow(10,pUpper);
   var mUpper = Math.floor(this.maxSemimajorForLog / nUpper);
   var r = pUpper - pLower;
   if(r == 0)
   {
      trace("*** warning, case r=0 not expected in Kepler 3 plot, case 1 ***");
   }
   var m = mLower;
   while(m < 10)
   {
      var x = xScale * (log(m * nLower) - logMinA);
      _loc1_.moveTo(x,0);
      _loc1_.lineTo(x,_loc3_);
      if(m == 1)
      {
         _loc1_.createTextField("_" + _loc2_,_loc2_,0,0,0,0);
         var labelMC = _loc1_["_" + _loc2_];
         _loc2_ = _loc2_ + 1;
         labelMC.autoSize = "center";
         labelMC.embedFonts = true;
         labelMC.type = "dynamic";
         labelMC.selectable = false;
         labelMC.setNewTextFormat(new TextFormat("Verdana",10,0));
         labelMC.text = m * nLower;
         labelMC._x = x - labelMC.textWidth / 2 + xLabelHorizontalOffset;
         labelMC._y = _loc3_ + xLabelMargin;
      }
      m++;
   }
   var p = pLower + 1;
   while(p < pUpper)
   {
      var n = Math.pow(10,p);
      var m = 1;
      while(m < 10)
      {
         var x = xScale * (log(m * n) - logMinA);
         _loc1_.moveTo(x,0);
         _loc1_.lineTo(x,_loc3_);
         if(m == 1)
         {
            _loc1_.createTextField("_" + _loc2_,_loc2_,0,0,0,0);
            var labelMC = _loc1_["_" + _loc2_];
            _loc2_ = _loc2_ + 1;
            labelMC.autoSize = "center";
            labelMC.embedFonts = true;
            labelMC.type = "dynamic";
            labelMC.selectable = false;
            labelMC.setNewTextFormat(new TextFormat("Verdana",10,0));
            labelMC.text = m * n;
            labelMC._x = x - labelMC.textWidth / 2 + xLabelHorizontalOffset;
            labelMC._y = _loc3_ + xLabelMargin;
         }
         m++;
      }
      p++;
   }
   var m = 1;
   while(m <= mUpper)
   {
      var x = xScale * (log(m * nUpper) - logMinA);
      _loc1_.moveTo(x,0);
      _loc1_.lineTo(x,_loc3_);
      if(m == 1)
      {
         _loc1_.createTextField("_" + _loc2_,_loc2_,0,0,0,0);
         var labelMC = _loc1_["_" + _loc2_];
         _loc2_ = _loc2_ + 1;
         labelMC.autoSize = "center";
         labelMC.embedFonts = true;
         labelMC.type = "dynamic";
         labelMC.selectable = false;
         labelMC.setNewTextFormat(new TextFormat("Verdana",10,0));
         labelMC.text = m * nUpper;
         labelMC._x = x - labelMC.textWidth / 2 + xLabelHorizontalOffset;
         labelMC._y = _loc3_ + xLabelMargin;
      }
      m++;
   }
   var pLower = Math.floor(logMinP / 2.302585092994046);
   var nLower = Math.pow(10,pLower);
   var mLower = Math.ceil(this.minPeriodForLog / nLower);
   var pUpper = Math.floor(logMaxP / 2.302585092994046);
   var nUpper = Math.pow(10,pUpper);
   var mUpper = Math.floor(this.maxPeriodForLog / nUpper);
   var r = pUpper - pLower;
   if(r == 0)
   {
      trace("*** warning, case r=0 not expected in Kepler 3 plot, case 2 ***");
   }
   var m = mLower;
   while(m < 10)
   {
      var y = yScale * (log(m * nLower) - logMinP);
      _loc1_.moveTo(0,y);
      _loc1_.lineTo(- _loc3_,y);
      if(m == 1)
      {
         _loc1_.createTextField("_" + _loc2_,_loc2_,0,0,0,0);
         var labelMC = _loc1_["_" + _loc2_];
         _loc2_ = _loc2_ + 1;
         labelMC.autoSize = "center";
         labelMC.embedFonts = true;
         labelMC.type = "dynamic";
         labelMC.selectable = false;
         labelMC.setNewTextFormat(new TextFormat("Verdana",10,0));
         labelMC.text = m * nLower;
         labelMC._y = y - labelMC.textHeight / 2 + yLabelVerticalOffset;
         labelMC._x = - (_loc3_ + labelMC.textWidth + yLabelMargin);
      }
      m++;
   }
   var p = pLower + 1;
   while(p < pUpper)
   {
      var n = Math.pow(10,p);
      var m = 1;
      while(m < 10)
      {
         var y = yScale * (log(m * n) - logMinP);
         _loc1_.moveTo(0,y);
         _loc1_.lineTo(- _loc3_,y);
         if(m == 1)
         {
            _loc1_.createTextField("_" + _loc2_,_loc2_,0,0,0,0);
            var labelMC = _loc1_["_" + _loc2_];
            _loc2_ = _loc2_ + 1;
            labelMC.autoSize = "center";
            labelMC.embedFonts = true;
            labelMC.type = "dynamic";
            labelMC.selectable = false;
            labelMC.setNewTextFormat(new TextFormat("Verdana",10,0));
            labelMC.text = m * n;
            labelMC._y = y - labelMC.textHeight / 2 + yLabelVerticalOffset;
            labelMC._x = - (_loc3_ + labelMC.textWidth + yLabelMargin);
         }
         m++;
      }
      p++;
   }
   var m = 1;
   while(m <= mUpper)
   {
      var y = yScale * (log(m * nUpper) - logMinP);
      _loc1_.moveTo(0,y);
      _loc1_.lineTo(- _loc3_,y);
      if(m == 1)
      {
         _loc1_.createTextField("_" + _loc2_,_loc2_,0,0,0,0);
         var labelMC = _loc1_["_" + _loc2_];
         _loc2_ = _loc2_ + 1;
         labelMC.autoSize = "center";
         labelMC.embedFonts = true;
         labelMC.type = "dynamic";
         labelMC.selectable = false;
         labelMC.setNewTextFormat(new TextFormat("Verdana",10,0));
         labelMC.text = m * nUpper;
         labelMC._y = y - labelMC.textHeight / 2 + yLabelVerticalOffset;
         labelMC._x = - (_loc3_ + labelMC.textWidth + yLabelMargin);
      }
      m++;
   }
};
