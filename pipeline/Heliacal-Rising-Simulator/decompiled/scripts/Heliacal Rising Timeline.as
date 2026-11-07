function HeliacalRisingTimelineClass()
{
   var _loc1_ = this;
   _loc1_._dayOfYearZB = 0;
   _loc1_._latitude = 0.715584993317675;
   _loc1_._declination = 0;
   _loc1_._rightAscension = 0;
   _loc1_._twilightAngle = 0.12217304763960307;
   _loc1_._dimensions = {width:300,height:16};
   _loc1_.labelsTextFormat = _loc1_.fontField.getTextFormat();
   _loc1_.fontField._visible = false;
   _loc1_.createEmptyMovieClip("daylightStripMC",5);
   _loc1_.update();
}
var p = HeliacalRisingTimelineClass.prototype = new MovieClip();
Object.registerClass("Heliacal Rising Timeline",HeliacalRisingTimelineClass);
p.dayColor = 16775129;
p.nightColor = 8421504;
p.starVisibilityColor = 14303232;
p.labelsTextFormat = null;
p.timelineLabelsList = [{hour:0,label:"midnight"},{hour:6,label:"6<font size=\"-3\">AM</font>"},{hour:12,label:"noon"},{hour:18,label:"6<font size=\"-3\">PM</font>"},{hour:24,label:"midnight"}];
p.getSunDeclination = function()
{
   return this._sunDeclination;
};
p.addProperty("sunDeclination",p.getSunDeclination,null);
p.getSunRightAscension = function()
{
   return this._sunRightAscension;
};
p.addProperty("sunRightAscension",p.getSunRightAscension,null);
p.getSiderealTime = function()
{
   return this._siderealTime;
};
p.addProperty("siderealTime",p.getSiderealTime,null);
p.updateDaylightStrip = function()
{
   var w = this._dimensions.width;
   var h = 0.6 * this._dimensions.height / 2;
   var _loc3_ = - h;
   var y2 = h;
   var xNoon = w / 2;
   var dayColor = this.dayColor;
   var nightColor = this.nightColor;
   var _loc1_ = this.daylightStripMC;
   _loc1_.clear();
   var maxGradientSampleSpacing = 4;
   var sunLongitude = (this._dayOfYearZB - 78) / 365 * 2 * 3.141592653589793;
   var sunDeclination = Math.asin(0.39714789063478056 * Math.sin(sunLongitude));
   this._sunDeclination = 57.29577951308232 * sunDeclination;
   this._sunRightAscension = (3.819718634205488 * Math.atan2(Math.sin(sunLongitude) * 0.9177546256839811,Math.cos(sunLongitude)) % 24 + 24) % 24;
   var sinSunDec = Math.sin(sunDeclination);
   var sinLat = Math.sin(this._latitude);
   var cosSunDec = Math.cos(sunDeclination);
   var cosLat = Math.cos(this._latitude);
   var zTwilight = Math.sin(- this._twilightAngle);
   var sinProduct = sinSunDec * sinLat;
   var cosProduct = cosSunDec * cosLat;
   var cosAlphaAtTwilightLimit = (zTwilight - sinProduct) / cosProduct;
   var cosAlphaOnHorizon = (- sinProduct) / cosProduct;
   var neverAboveTwilightLimit = cosAlphaAtTwilightLimit >= 1;
   var neverBelowTwilightLimit = cosAlphaAtTwilightLimit <= -1;
   var neverAboveHorizon = cosAlphaOnHorizon >= 1;
   var neverBelowHorizon = cosAlphaOnHorizon <= -1;
   var _loc2_;
   if(neverBelowHorizon)
   {
      _loc1_.moveTo(0,_loc3_);
      _loc1_.beginFill(dayColor);
      _loc1_.lineTo(w,_loc3_);
      _loc1_.lineTo(w,y2);
      _loc1_.lineTo(0,y2);
      _loc1_.lineTo(0,_loc3_);
      _loc1_.endFill();
   }
   else if(neverAboveTwilightLimit)
   {
      _loc1_.moveTo(0,_loc3_);
      _loc1_.beginFill(nightColor);
      _loc1_.lineTo(w,_loc3_);
      _loc1_.lineTo(w,y2);
      _loc1_.lineTo(0,y2);
      _loc1_.lineTo(0,_loc3_);
      _loc1_.endFill();
   }
   else
   {
      var twilightStartAlpha;
      var twilightEndAlpha;
      if(neverBelowTwilightLimit)
      {
         twilightStartAlpha = 3.141592653589793;
      }
      else
      {
         twilightStartAlpha = Math.acos(cosAlphaAtTwilightLimit);
         var xNightEnds = xNoon * (1 - twilightStartAlpha / 3.141592653589793);
         var xNightStarts = xNoon * (1 + twilightStartAlpha / 3.141592653589793);
         _loc1_.moveTo(0,_loc3_);
         _loc1_.beginFill(nightColor);
         _loc1_.lineTo(xNightEnds,_loc3_);
         _loc1_.lineTo(xNightEnds,y2);
         _loc1_.lineTo(0,y2);
         _loc1_.lineTo(0,_loc3_);
         _loc1_.endFill();
         _loc1_.moveTo(xNightStarts,_loc3_);
         _loc1_.beginFill(nightColor);
         _loc1_.lineTo(w,_loc3_);
         _loc1_.lineTo(w,y2);
         _loc1_.lineTo(xNightStarts,y2);
         _loc1_.lineTo(xNightStarts,_loc3_);
         _loc1_.endFill();
      }
      if(neverAboveHorizon)
      {
         twilightEndAlpha = 0;
      }
      else
      {
         twilightEndAlpha = Math.acos(cosAlphaOnHorizon);
         var xDayStarts = xNoon * (1 - twilightEndAlpha / 3.141592653589793);
         var xDayEnds = xNoon * (1 + twilightEndAlpha / 3.141592653589793);
         _loc1_.moveTo(xDayStarts,_loc3_);
         _loc1_.beginFill(dayColor);
         _loc1_.lineTo(xDayEnds,_loc3_);
         _loc1_.lineTo(xDayEnds,y2);
         _loc1_.lineTo(xDayStarts,y2);
         _loc1_.lineTo(xDayStarts,_loc3_);
         _loc1_.endFill();
      }
      var xTwilightStarts = xNoon * (1 - twilightStartAlpha / 3.141592653589793);
      var xTwilightEnds = xNoon * (1 - twilightEndAlpha / 3.141592653589793);
      var twilightWidth = xTwilightEnds - xTwilightStarts;
      var numSteps = Math.ceil(twilightWidth / maxGradientSampleSpacing);
      var alphaStep = (twilightStartAlpha - twilightEndAlpha) / (numSteps - 1);
      var xStep = (xTwilightEnds - xTwilightStarts) / (numSteps - 1);
      var colorsList = [];
      _loc2_ = 0;
      while(_loc2_ < numSteps)
      {
         var alpha = twilightStartAlpha - _loc2_ * alphaStep;
         var sunAlt = Math.asin(Math.cos(alpha) * cosProduct + sinProduct);
         colorsList.push(this.getInterpolatedColor(dayColor,nightColor,(- sunAlt) / this._twilightAngle));
         _loc2_ = _loc2_ + 1;
      }
      _loc2_ = 1;
      while(_loc2_ < numSteps)
      {
         var x2 = xTwilightStarts + _loc2_ * xStep;
         var x1 = x2 - xStep;
         var x4 = 2 * xNoon - x1;
         var x3 = 2 * xNoon - x2;
         var matrix = {matrixType:"box",x:x1,y:- h,w:xStep,h:2 * h,r:0};
         _loc1_.moveTo(x1,_loc3_);
         _loc1_.beginGradientFill("linear",colorsList.slice(_loc2_ - 1,_loc2_ + 1),[100,100],[0,255],matrix);
         _loc1_.lineTo(x2,_loc3_);
         _loc1_.lineTo(x2,y2);
         _loc1_.lineTo(x1,y2);
         _loc1_.lineTo(x1,_loc3_);
         _loc1_.endFill();
         var matrix = {matrixType:"box",x:x3,y:- h,w:xStep,h:2 * h,r:0};
         _loc1_.moveTo(x3,_loc3_);
         _loc1_.beginGradientFill("linear",colorsList.slice(_loc2_ - 1,_loc2_ + 1).reverse(),[100,100],[0,255],matrix);
         _loc1_.lineTo(x4,_loc3_);
         _loc1_.lineTo(x4,y2);
         _loc1_.lineTo(x3,y2);
         _loc1_.lineTo(x3,_loc3_);
         _loc1_.endFill();
         _loc2_ = _loc2_ + 1;
      }
   }
};
p.updateTickmarksAndLabels = function()
{
   var _loc2_ = this;
   var mc = _loc2_.createEmptyMovieClip("timelineLabelsMC",10);
   var w = _loc2_._dimensions.width;
   var a = _loc2_._dimensions.height / 2;
   var q = w / 4;
   mc.clear();
   mc.lineStyle(1,0);
   var startHTML = "<font face=\"" + _loc2_.labelsTextFormat.font + "\">";
   var endHTML = "</font>";
   if(_loc2_.labelsTextFormat.bold)
   {
      startHTML = "<b>" + startHTML;
      endHTML += "</b>";
   }
   if(_loc2_.labelsTextFormat.italic)
   {
      startHTML = "<i>" + startHTML;
      endHTML += "</i>";
   }
   var _loc1_ = 0;
   var _loc3_;
   while(_loc1_ < _loc2_.timelineLabelsList.length)
   {
      var x = w * (_loc2_.timelineLabelsList[_loc1_].hour / 24);
      var f = _loc2_.timelineLabelsList[_loc1_].fractionalLength == undefined ? 1 : _loc2_.timelineLabelsList[_loc1_].fractionalLength;
      var lineColor = _loc2_.timelineLabelsList[_loc1_].lineColor == undefined ? 0 : _loc2_.timelineLabelsList[_loc1_].lineColor;
      mc.createTextField("_" + _loc1_,_loc1_,x,a,0,0);
      _loc3_ = mc["_" + _loc1_];
      _loc3_.autoSize = "center";
      _loc3_.html = true;
      _loc3_.embedFonts = true;
      _loc3_.selectable = false;
      _loc3_.htmlText = startHTML + _loc2_.timelineLabelsList[_loc1_].label + endHTML;
      mc.lineStyle(1,lineColor);
      mc.moveTo(x,a * f);
      mc.lineTo(x,(- a) * f);
      _loc1_ = _loc1_ + 1;
   }
};
p.updateStarVisibility = function()
{
   var _loc3_ = this;
   var _loc2_ = _loc3_.createEmptyMovieClip("visibiltyMC",15);
   _loc2_.clear();
   var _loc1_ = _loc3_._dimensions.width;
   var y2 = -1.2 * _loc3_._dimensions.height / 2;
   var y1 = y2 - 0.6 * _loc3_._dimensions.height / 2;
   var y3 = y1 - 0.2 * _loc3_._dimensions.height / 2;
   var xNoon = _loc1_ / 2;
   var visibilityColor = _loc3_.starVisibilityColor;
   var sinDec = Math.sin(_loc3_._declination);
   var sinLat = Math.sin(_loc3_._latitude);
   var cosDec = Math.cos(_loc3_._declination);
   var cosLat = Math.cos(_loc3_._latitude);
   var cosAlpha = (- sinDec) * sinLat / (cosDec * cosLat);
   var siderealDay = (_loc3_._dayOfYearZB - 78) * 1.0027397260273974;
   _loc3_._siderealTime = 24 * (siderealDay - Math.floor(siderealDay));
   if(cosAlpha <= -1)
   {
      _loc2_.createTextField("neverSetsTextField",1,xNoon,0,0,0);
      var t = _loc2_.neverSetsTextField;
      t.setNewTextFormat(_loc3_.labelsTextFormat);
      t.autoSize = "center";
      t.embedFonts = true;
      t.selectable = false;
      t.textColor = visibilityColor;
      t.text = "star never sets";
      t._y = y1 - t.textHeight;
      _loc3_.isRiseAndSet = false;
      _loc3_.riseAndSetTimes = null;
   }
   else if(cosAlpha >= 1)
   {
      _loc2_.createTextField("neverRisesTextField",1,xNoon,0,0,0);
      var t = _loc2_.neverRisesTextField;
      t.setNewTextFormat(_loc3_.labelsTextFormat);
      t.autoSize = "center";
      t.embedFonts = true;
      t.selectable = false;
      t.textColor = visibilityColor;
      t.text = "star never rises";
      t._y = y1 - t.textHeight;
      _loc3_.isRiseAndSet = false;
      _loc3_.riseAndSetTimes = null;
   }
   else
   {
      var xHalfVisibility = Math.acos(cosAlpha) * (_loc1_ / 6.283185307179586);
      var earlierTransit;
      var laterTransit;
      var t0 = Math.floor(siderealDay) + _loc3_._rightAscension / 6.283185307179586;
      if(t0 < siderealDay)
      {
         earlierTransit = t0;
         laterTransit = earlierTransit + 1;
      }
      else
      {
         laterTransit = t0;
         earlierTransit = laterTransit - 1;
      }
      var xEarlierTransit = xNoon - (siderealDay - earlierTransit) * 0.9972677595628415 * _loc1_;
      var xLaterTransit = xNoon + (laterTransit - siderealDay) * 0.9972677595628415 * _loc1_;
      var xEarlierTransitStarts = xEarlierTransit - xHalfVisibility;
      if(xEarlierTransitStarts < 0)
      {
         xEarlierTransitStarts = 0;
      }
      else if(xEarlierTransitStarts > _loc1_)
      {
         xEarlierTransitStarts = _loc1_;
      }
      var xEarlierTransitEnds = xEarlierTransit + xHalfVisibility;
      if(xEarlierTransitEnds < 0)
      {
         xEarlierTransitEnds = 0;
      }
      else if(xEarlierTransitEnds > _loc1_)
      {
         xEarlierTransitEnds = _loc1_;
      }
      var xLaterTransitStarts = xLaterTransit - xHalfVisibility;
      if(xLaterTransitStarts < 0)
      {
         xLaterTransitStarts = 0;
      }
      else if(xLaterTransitStarts > _loc1_)
      {
         xLaterTransitStarts = _loc1_;
      }
      var xLaterTransitEnds = xLaterTransit + xHalfVisibility;
      if(xLaterTransitEnds < 0)
      {
         xLaterTransitEnds = 0;
      }
      else if(xLaterTransitEnds > _loc1_)
      {
         xLaterTransitEnds = _loc1_;
      }
      if(xEarlierTransitStarts != xEarlierTransitEnds)
      {
         _loc2_.moveTo(xEarlierTransitStarts,y1);
         _loc2_.beginFill(visibilityColor);
         _loc2_.lineTo(xEarlierTransitEnds,y1);
         _loc2_.lineTo(xEarlierTransitEnds,y2);
         _loc2_.lineTo(xEarlierTransitStarts,y2);
         _loc2_.lineTo(xEarlierTransitStarts,y1);
         _loc2_.endFill();
      }
      if(xLaterTransitStarts != xLaterTransitEnds)
      {
         _loc2_.moveTo(xLaterTransitStarts,y1);
         _loc2_.beginFill(visibilityColor);
         _loc2_.lineTo(xLaterTransitEnds,y1);
         _loc2_.lineTo(xLaterTransitEnds,y2);
         _loc2_.lineTo(xLaterTransitStarts,y2);
         _loc2_.lineTo(xLaterTransitStarts,y1);
         _loc2_.endFill();
      }
      if(xEarlierTransit > 0 && xEarlierTransit < _loc1_)
      {
         var tx = xEarlierTransitStarts + (xEarlierTransitEnds - xEarlierTransitStarts) / 2;
         _loc2_.createTextField("visible1",1,tx,0,0,0);
         var t = _loc2_.visible1;
         t.setNewTextFormat(_loc3_.labelsTextFormat);
         t.autoSize = "center";
         t.embedFonts = true;
         t.selectable = false;
         t.textColor = visibilityColor;
         t.text = "star above horizon";
         t._y = y3 - t.textHeight;
         if(xEarlierTransitStarts > 0)
         {
            var rise = 1.0027397260273974 * (24 * (xEarlierTransitStarts / _loc1_) - 12) - 12;
         }
         else
         {
            var rise = 1.0027397260273974 * (24 * (xLaterTransitStarts / _loc1_) - 12) - 12;
         }
         if(xEarlierTransitEnds > 0)
         {
            var set = 1.0027397260273974 * (24 * (xEarlierTransitEnds / _loc1_) - 12) - 12;
         }
         else
         {
            var set = 1.0027397260273974 * (24 * (xLaterTransitEnds / _loc1_) - 12) - 12;
         }
      }
      else if(xLaterTransit > 0 && xLaterTransit < _loc1_)
      {
         var tx = xLaterTransitStarts + (xLaterTransitEnds - xLaterTransitStarts) / 2;
         _loc2_.createTextField("visible2",2,tx,0,0,0);
         var t = _loc2_.visible2;
         t.setNewTextFormat(_loc3_.labelsTextFormat);
         t.autoSize = "center";
         t.embedFonts = true;
         t.selectable = false;
         t.textColor = visibilityColor;
         t.text = "star above horizon";
         t._y = y3 - t.textHeight;
         if(xLaterTransitStarts < _loc1_)
         {
            var rise = 1.0027397260273974 * (24 * (xLaterTransitStarts / _loc1_) - 12) - 12;
         }
         else
         {
            var rise = 1.0027397260273974 * (24 * (xEarlierTransitStarts / _loc1_) - 12) - 12;
         }
         if(xLaterTransitEnds < _loc1_)
         {
            var set = 1.0027397260273974 * (24 * (xLaterTransitEnds / _loc1_) - 12) - 12;
         }
         else
         {
            var set = 1.0027397260273974 * (24 * (xEarlierTransitEnds / _loc1_) - 12) - 12;
         }
      }
      _loc3_.isRiseAndSet = true;
      _loc3_.riseAndSetTimes = {rise:rise,§set§:eval("set")};
   }
};
p.update = function()
{
   var _loc1_ = this;
   _loc1_.updateTickmarksAndLabels();
   _loc1_.updateDaylightStrip();
   _loc1_.updateStarVisibility();
};
p.getInterpolatedColor = function(color1, color2, x)
{
   var _loc1_ = x;
   if(_loc1_ > 1)
   {
      _loc1_ = 1;
   }
   else if(_loc1_ < 0)
   {
      _loc1_ = 0;
   }
   var _loc2_ = 0xFF & color1 >> 16;
   var g1 = 0xFF & color1 >> 8;
   var _loc3_ = 0xFF & color1;
   var r2 = 0xFF & color2 >> 16;
   var g2 = 0xFF & color2 >> 8;
   var b2 = 0xFF & color2;
   var r = _loc2_ + _loc1_ * (r2 - _loc2_);
   var g = g1 + _loc1_ * (g2 - g1);
   var b = _loc3_ + _loc1_ * (b2 - _loc3_);
   return r << 16 | g << 8 | b;
};
p.monthsList = [{shortName:"Jan",longName:"January",baseDOY:0},{shortName:"Feb",longName:"February",baseDOY:31},{shortName:"Mar",longName:"March",baseDOY:59},{shortName:"Apr",longName:"April",baseDOY:90},{shortName:"May",longName:"May",baseDOY:120},{shortName:"Jun",longName:"June",baseDOY:151},{shortName:"Jul",longName:"July",baseDOY:181},{shortName:"Aug",longName:"August",baseDOY:212},{shortName:"Sep",longName:"September",baseDOY:243},{shortName:"Oct",longName:"October",baseDOY:273},{shortName:"Nov",longName:"November",baseDOY:304},{shortName:"Dec",longName:"December",baseDOY:334}];
p.getCalendarDate = function()
{
   var _loc2_ = this;
   var _loc1_ = 0;
   while(_loc1_ < 12)
   {
      if(_loc2_._dayOfYearZB < _loc2_.monthsList[_loc1_].baseDOY)
      {
         break;
      }
      _loc1_ = _loc1_ + 1;
   }
   var _loc3_ = {};
   _loc3_.dayOfMonth = 1 + _loc2_._dayOfYearZB - _loc2_.monthsList[_loc1_ - 1].baseDOY;
   _loc3_.monthNumber = _loc1_;
   _loc3_.shortMonthName = _loc2_.monthsList[_loc1_ - 1].shortName;
   _loc3_.longMonthName = _loc2_.monthsList[_loc1_ - 1].longName;
   return _loc3_;
};
p.getDayOfYearZB = function()
{
   return this._dayOfYearZB;
};
p.setDayOfYearZB = function(arg)
{
   var _loc1_ = arg;
   _loc1_ = Math.round(_loc1_);
   if(_loc1_ < 0)
   {
      _loc1_ = 0;
   }
   else if(_loc1_ > 364)
   {
      _loc1_ = 364;
   }
   this._dayOfYearZB = _loc1_;
   this.update();
};
p.addProperty("dayOfYearZB",p.getDayOfYearZB,p.setDayOfYearZB);
p.getLatitude = function()
{
   return this._latitude * 180 / 3.141592653589793;
};
p.setLatitude = function(arg)
{
   var _loc1_ = arg;
   if(_loc1_ < -90)
   {
      _loc1_ = -90;
   }
   else if(_loc1_ > 90)
   {
      _loc1_ = 90;
   }
   this._latitude = _loc1_ * 3.141592653589793 / 180;
   this.update();
};
p.addProperty("latitude",p.getLatitude,p.setLatitude);
p.getDeclination = function()
{
   return this._declination * 180 / 3.141592653589793;
};
p.setDeclination = function(arg)
{
   var _loc1_ = arg;
   if(_loc1_ < -90)
   {
      _loc1_ = -90;
   }
   else if(_loc1_ > 90)
   {
      _loc1_ = 90;
   }
   this._declination = _loc1_ * 3.141592653589793 / 180;
   this.update();
};
p.addProperty("declination",p.getDeclination,p.setDeclination);
p.getRightAscension = function()
{
   return this._rightAscension * 12 / 3.141592653589793;
};
p.setRightAscension = function(arg)
{
   var _loc1_ = arg;
   if(_loc1_ < 0)
   {
      _loc1_ = 0;
   }
   else if(_loc1_ >= 24)
   {
      _loc1_ = 0;
   }
   this._rightAscension = _loc1_ * 3.141592653589793 / 12;
   this.update();
};
p.addProperty("rightAscension",p.getRightAscension,p.setRightAscension);
p.getTwilightAngle = function()
{
   return this._twilightAngle * 180 / 3.141592653589793;
};
p.setTwilightAngle = function(arg)
{
   var _loc1_ = arg;
   if(_loc1_ > 30)
   {
      _loc1_ = 30;
   }
   else if(_loc1_ < 0)
   {
      _loc1_ = 0;
   }
   this._twilightAngle = _loc1_ * 3.141592653589793 / 180;
   this.update();
};
p.addProperty("twilightAngle",p.getTwilightAngle,p.setTwilightAngle);
p.setDimensions = function(w, h)
{
   var _loc1_ = h;
   var _loc2_ = w;
   var _loc3_ = this;
   if(_loc2_ < 10)
   {
      _loc2_ = 10;
   }
   else if(_loc2_ > 1000)
   {
      _loc2_ = 1000;
   }
   if(_loc1_ < 10)
   {
      _loc1_ = 10;
   }
   else if(_loc1_ > 1000)
   {
      _loc1_ = 1000;
   }
   _loc3_._dimensions.width = _loc2_;
   _loc3_._dimensions.height = _loc1_;
   _loc3_.update();
};
