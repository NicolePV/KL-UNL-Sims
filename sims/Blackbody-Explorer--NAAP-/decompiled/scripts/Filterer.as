function FiltererClass()
{
   var _loc2_ = this;
   _loc2_.createEmptyMovieClip("filterProfilesMC",1);
   _loc2_.createEmptyMovieClip("maskMC",2);
   _loc2_._filterSet = [_global.U_Filter,_global.B_Filter,_global.V_Filter,_global.R_Filter];
   var i = 0;
   var _loc3_;
   while(i < _loc2_._filterSet.length)
   {
      _loc3_ = _loc2_.filterProfilesMC.createEmptyMovieClip("_" + i,i);
      _loc3_._alpha = _loc2_.inactiveAlpha;
      _loc3_.createEmptyMovieClip("borderMC",1);
      _loc3_.borderMC._visible = false;
      _loc2_._filterSet[i].mc = _loc3_;
      i++;
   }
   _loc2_.filterProfilesMC.topDepth = i;
   var wMin = Infinity;
   var wMax = -Infinity;
   var i = 0;
   var _loc1_;
   while(i < _loc2_._filterSet.length)
   {
      _loc1_ = _loc2_._filterSet[i].data;
      if(_loc1_[0].w < wMin)
      {
         wMin = _loc1_[0].w;
      }
      if(_loc1_[_loc1_.length - 1].w > wMax)
      {
         wMax = _loc1_[_loc1_.length - 1].w;
      }
      i++;
   }
   _loc2_._wMinFilter = wMin;
   _loc2_._wMaxFilter = wMax;
}
var p = FiltererClass.prototype = new MovieClip();
Object.registerClass("Filterer",FiltererClass);
p.inactiveAlpha = 20;
p.activeAlpha = 20;
p.curveOnRollOverFunc = function()
{
   var _loc1_ = this;
   _loc1_._alpha = _loc1_._parent._parent.activeAlpha;
   _loc1_.swapDepths(_loc1_._parent.topDepth);
   _loc1_.borderMC._visible = true;
};
p.curveOnRollOutFunc = function()
{
   this._alpha = this._parent._parent.inactiveAlpha;
};
p.curveOnReleaseFunc = function()
{
};
p.curveOnReleaseOutsideFunc = function()
{
   this._alpha = this._parent._parent.inactiveAlpha;
};
p.curveOnPressFunc = function()
{
};
p.update = function()
{
   var startTimer = getTimer();
   var pow = Math.pow;
   var exp = Math.exp;
   var log = Math.log;
   var T = this.temperature;
   var A = 1.1910425859324616e-16;
   var B = 0.014387750559248378;
   var A_ = A / pow(1e-9,5);
   var B_ = B / (1e-9 * T);
   var wPeak = 0.0028977682864295084 / T;
   var maxBrightness = A / (pow(wPeak,5) * (exp(B / (wPeak * T)) - 1));
   var yScale = this.yScale;
   var filterSet = this._filterSet;
   var numFilters = filterSet.length;
   var wMinPlot = this._wMinPlot;
   var xStep = this._plotWidth / (this._wMaxPlot - wMinPlot);
   var wMax = this._wMaxFilter;
   var wMin = this._wMinFilter;
   var yMin = - this._plotHeight;
   var wLimit = wMax + 1;
   var bArray = [];
   var w = wMin;
   while(w < wLimit)
   {
      bArray[w] = A_ / (pow(w,5) * (exp(B_ / w) - 1));
      w++;
   }
   var mags = [];
   var sums = [];
   var i = 0;
   var _loc2_;
   var _loc1_;
   var _loc3_;
   while(i < numFilters)
   {
      var f = filterSet[i];
      var d = f.data;
      _loc2_ = f.mc;
      var bmc = _loc2_.borderMC;
      _loc2_.clear();
      bmc.clear();
      bmc.lineStyle(1,0);
      var sum = 0;
      var lb = 0;
      var sx = xStep * (d[0].w - wMinPlot);
      _loc1_ = sx;
      _loc2_.moveTo(sx,0);
      bmc.moveTo(sx,0);
      _loc2_.beginFill(f.color,100);
      var bt = true;
      var dLen = d.length;
      var j = 1;
      while(j < dLen)
      {
         var dp = d[j];
         var b = dp.t * bArray[dp.w];
         _loc1_ += xStep;
         _loc3_ = yScale * b;
         if(bt)
         {
            if(_loc3_ < yMin)
            {
               _loc2_.lineTo(_loc1_,yMin);
               bmc.lineTo(_loc1_,yMin);
               bt = false;
            }
            else
            {
               _loc2_.lineTo(_loc1_,_loc3_);
               bmc.lineTo(_loc1_,_loc3_);
            }
         }
         else if(_loc3_ > yMin)
         {
            _loc2_.lineTo(_loc1_,yMin);
            bmc.lineTo(_loc1_,yMin);
            _loc2_.lineTo(_loc1_,_loc3_);
            bmc.lineTo(_loc1_,_loc3_);
            bt = true;
         }
         sum += 1e-9 * (lb + (b - lb) / 2);
         lb = b;
         j++;
      }
      _loc2_.lineStyle();
      _loc2_.lineTo(sx,0);
      _loc2_.endFill();
      mags[f.name] = f.offset - log(sum) * 2.5 / 2.302585092994046;
      sums[f.name] = sum;
      i++;
   }
   this.sums = sums;
   this.magnitudes = mags;
   trace("filterer update time: " + (getTimer() - startTimer));
   return mags;
};
