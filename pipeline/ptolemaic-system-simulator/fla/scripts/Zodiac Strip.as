function ZodiacStripClass()
{
   this.planetBarMC.swapDepths(500000);
   var mc = this.createEmptyMovieClip("_constellationLabelsMC",0);
   var symbols = "^_`abcdefghi";
   var names = ["Aries","Taurus","Gemini","Cancer","Leo","Virgo","Libra","Scorpius","Sagittarius","Capricorn","Aquarius","Pisces"];
   var _loc1_ = 0;
   var _loc2_;
   while(_loc1_ < 12)
   {
      _loc2_ = 600 - (15 + _loc1_ * 30) * 1.6666666666666667;
      mc.attachMovie("Zodiac Symbol","_" + _loc1_,_loc1_,{_x:_loc2_,_y:4,symbol:symbols.charAt(_loc1_),name:names[_loc1_],_xscale:65,_yscale:65,symbolColor:0,symbolAlpha:40,nameColor:0,nameAlpha:65});
      _loc1_ = _loc1_ + 1;
   }
   this._samplingInterval = this._parent._samplingInterval;
   this._numSegments = this._parent._numSegments;
   this.clearGhosting();
}
var p = ZodiacStripClass.prototype = new MovieClip();
Object.registerClass("Zodiac Strip",ZodiacStripClass);
p.width = 600;
p.alphaSpread = 50;
p.minAlpha = 5;
p.clearGhosting = function()
{
   var _loc2_ = this;
   _loc2_._segmentsList = [];
   var _loc3_ = _loc2_._numSegments;
   var _loc1_ = 0;
   while(_loc1_ < _loc3_)
   {
      _loc2_._segmentsList[_loc1_] = _loc2_.createEmptyMovieClip("_" + _loc1_,100 + _loc1_);
      _loc1_ = _loc1_ + 1;
   }
   _loc2_.createEmptyMovieClip("_tempSegmentMC",100 + _loc1_);
   _loc2_._tempSegmentMC._alpha = _loc2_.minAlpha + _loc2_.alphaSpread;
   _loc2_._currentSegment = 0;
   _loc2_._timeCounter = 0;
   _loc2_._lastPlanetX = null;
};
p.setSunLongitude = function(lon)
{
   this.sunBarMC._x = (lon * 95.4929658551372 % 600 + 600) % 600;
};
p.setPlanetLongitude = function(lon, lonList)
{
   var _loc3_ = this.width;
   var hw = _loc3_ / 2;
   var cs = this._currentSegment;
   var segList = this._segmentsList;
   var numSegs = this._numSegments;
   var sampInt = this._samplingInterval;
   var timePerSeg = this.ghostingTime / numSegs;
   var n = lonList.length;
   var _loc2_ = this._lastPlanetX;
   if(_loc2_ == null)
   {
      _loc2_ = (lon * (_loc3_ / 6.283185307179586) % _loc3_ + _loc3_) % _loc3_;
   }
   var _loc1_ = 10;
   var q1 = 150;
   var q2 = _loc3_ - q1;
   var timeCounter = this._timeCounter;
   var mc = segList[cs];
   var i = 0;
   while(i < n)
   {
      timeCounter += sampInt;
      if(timeCounter > timePerSeg)
      {
         timeCounter %= timePerSeg;
         cs = (cs + 1) % numSegs;
         mc = segList[cs];
         mc.clear();
      }
      var xNow = (lonList[i] * (_loc3_ / 6.283185307179586) % _loc3_ + _loc3_) % _loc3_;
      var dX = ((xNow - _loc2_) % _loc3_ + _loc3_) % _loc3_;
      if(dX > hw)
      {
         dX = 600 - dX;
      }
      var Z = 1 - dX / 3;
      if(Z < 0)
      {
         Z = 0;
      }
      var C = Math.floor(216 - 112 * Z);
      var newColor = 21 + C << 16 | C << 8 | C;
      mc.beginFill(newColor);
      if(xNow > q2 && _loc2_ < q1)
      {
         mc.moveTo(_loc2_,- _loc1_);
         mc.lineTo(_loc2_,_loc1_);
         mc.lineTo(0,_loc1_);
         mc.lineTo(0,- _loc1_);
         mc.lineTo(_loc2_,- _loc1_);
         mc.moveTo(xNow,- _loc1_);
         mc.lineTo(xNow,_loc1_);
         mc.lineTo(_loc3_,_loc1_);
         mc.lineTo(_loc3_,- _loc1_);
         mc.lineTo(xNow,- _loc1_);
      }
      else if(xNow < q1 && _loc2_ > q2)
      {
         mc.moveTo(xNow,- _loc1_);
         mc.lineTo(xNow,_loc1_);
         mc.lineTo(0,_loc1_);
         mc.lineTo(0,- _loc1_);
         mc.lineTo(xNow,- _loc1_);
         mc.moveTo(_loc2_,- _loc1_);
         mc.lineTo(_loc2_,_loc1_);
         mc.lineTo(_loc3_,_loc1_);
         mc.lineTo(_loc3_,- _loc1_);
         mc.lineTo(_loc2_,- _loc1_);
      }
      else
      {
         mc.moveTo(_loc2_,- _loc1_);
         mc.lineTo(_loc2_,_loc1_);
         mc.lineTo(xNow,_loc1_);
         mc.lineTo(xNow,- _loc1_);
         mc.lineTo(_loc2_,- _loc1_);
      }
      mc.endFill();
      _loc2_ = xNow;
      i++;
   }
   if(newColor == undefined)
   {
      var newColor = this._lastColor;
   }
   else
   {
      this._lastColor = newColor;
   }
   var xNow = (lon * (_loc3_ / 6.283185307179586) % _loc3_ + _loc3_) % _loc3_;
   var mc = this._tempSegmentMC;
   mc.clear();
   mc.beginFill(newColor);
   if(xNow > q2 && _loc2_ < q1)
   {
      mc.moveTo(_loc2_,- _loc1_);
      mc.lineTo(_loc2_,_loc1_);
      mc.lineTo(0,_loc1_);
      mc.lineTo(0,- _loc1_);
      mc.lineTo(_loc2_,- _loc1_);
      mc.moveTo(xNow,- _loc1_);
      mc.lineTo(xNow,_loc1_);
      mc.lineTo(_loc3_,_loc1_);
      mc.lineTo(_loc3_,- _loc1_);
      mc.lineTo(xNow,- _loc1_);
   }
   else if(xNow < q1 && _loc2_ > q2)
   {
      mc.moveTo(xNow,- _loc1_);
      mc.lineTo(xNow,_loc1_);
      mc.lineTo(0,_loc1_);
      mc.lineTo(0,- _loc1_);
      mc.lineTo(xNow,- _loc1_);
      mc.moveTo(_loc2_,- _loc1_);
      mc.lineTo(_loc2_,_loc1_);
      mc.lineTo(_loc3_,_loc1_);
      mc.lineTo(_loc3_,- _loc1_);
      mc.lineTo(_loc2_,- _loc1_);
   }
   else
   {
      mc.moveTo(_loc2_,- _loc1_);
      mc.lineTo(_loc2_,_loc1_);
      mc.lineTo(xNow,_loc1_);
      mc.lineTo(xNow,- _loc1_);
      mc.lineTo(_loc2_,- _loc1_);
   }
   mc.endFill();
   var alphaStep = this.alphaSpread / numSegs;
   var i = 0;
   while(i < numSegs)
   {
      segList[(cs + i + 1) % numSegs]._alpha = this.minAlpha + i * alphaStep;
      i++;
   }
   this._timeCounter = timeCounter;
   this._currentSegment = cs;
   this._lastPlanetX = _loc2_;
   this.planetBarMC._x = xNow;
};
