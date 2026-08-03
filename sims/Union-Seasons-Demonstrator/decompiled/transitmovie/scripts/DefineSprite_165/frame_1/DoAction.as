function attemptToLoad()
{
   trace("attempt to load, " + imageLocationsIndex + ", " + imageLocationsList[imageLocationsIndex % imageLocationsList.length]);
   frameCount = 0;
   if(imageLocationsIndex > imageLocationsList.length)
   {
      warningString = "The images file could not be loaded. Please check that it exists and is accessible.";
      if(imageLocationsIndex > 3 * imageLocationsList.length)
      {
         trace("giving up");
         delete onEnterFrame;
      }
   }
   imagesMC.loadMovie(imageLocationsList[imageLocationsIndex % imageLocationsList.length]);
   imageLocationsIndex++;
}
stop();
imageLocationsList = ["transitimages.swf","animations/coordsmotion/transitimages.swf","transitImages.swf","animations/coordsmotion/transitImages.swf"];
imageLocationsIndex = 0;
createEmptyMovieClip("imagesMC",1);
imagesMC._xscale = imagesMC._yscale = 150;
imagesMC._x = -383;
imagesMC._y = -258;
createEmptyMovieClip("barFillMC",1000);
createEmptyMovieClip("barBorderMC",1001);
barCenterX = -143;
barTopY = -60;
barWidth = 120;
halfBarWidth = barWidth / 2;
barHeight = 12;
fillColor = 10987431;
lineColor = 5263440;
lineThickness = 0;
frameCount = 0;
countLimit = 5;
warningString = "";
onEnterFrame = function()
{
   var imageBytes = imagesMC.getBytesTotal();
   if(imageBytes > 0)
   {
      var totalBytes = _root.getBytesTotal() + imageBytes;
      var loadedBytes = _root.getBytesLoaded() + imagesMC.getBytesLoaded();
      var frac = loadedBytes / totalBytes;
      if(frac >= 1)
      {
         barFillMC.removeMovieClip();
         barBorderMC.removeMovieClip();
         gotoAndStop(2);
         delete onEnterFrame;
         return undefined;
      }
      progressString = "please wait while the images load\n\n\n" + (loadedBytes / 1048576).toFixed(1) + " MB of " + (totalBytes / 1048576).toFixed(1) + " MB loaded so far";
      var x = barWidth * frac - halfBarWidth;
      with(barBorderMC)
      {
         clear();
         lineStyle(lineThickness,lineColor,100);
         moveTo(barCenterX - halfBarWidth,barTopY);
         lineTo(barCenterX + halfBarWidth,barTopY);
         lineTo(barCenterX + halfBarWidth,barTopY + barHeight);
         lineTo(barCenterX - halfBarWidth,barTopY + barHeight);
         lineTo(barCenterX - halfBarWidth,barTopY);
      }
      with(barFillMC)
      {
         clear();
         lineStyle(0,0,0);
         moveTo(barCenterX - halfBarWidth,barTopY);
         beginFill(fillColor);
         lineTo(barCenterX + x,barTopY);
         lineTo(barCenterX + x,barTopY + barHeight);
         lineTo(barCenterX - halfBarWidth,barTopY + barHeight);
         lineTo(barCenterX - halfBarWidth,barTopY);
         endFill();
      }
   }
   else if(imageBytes == -1)
   {
      frameCount++;
      if(frameCount > countLimit)
      {
         attemptToLoad();
      }
   }
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
attemptToLoad();
