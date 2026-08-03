function DayOfYearSliderClass()
{
   var _loc6_ = this.barMC._height;
   var _loc5_ = _loc6_ / 2;
   this.timelineWidth = this.barMC._width;
   var _loc10_ = this.timelineWidth;
   var _loc0_;
   var _loc4_ = this.scaleFactor = _loc10_ / 365;
   this.barMC._visible = false;
   var _loc8_ = this.createEmptyMovieClip("timelineMC",0);
   _loc8_.clear();
   _loc8_.lineStyle(0,0);
   var _loc2_ = 0;
   var _loc3_;
   while(_loc2_ < 13)
   {
      _loc3_ = this.monthPoints[_loc2_];
      _loc8_.moveTo(_loc4_ * _loc3_,_loc5_);
      _loc8_.lineTo(_loc4_ * _loc3_,- _loc5_);
      if(_loc2_ != 12)
      {
         _loc8_.attachMovie("Day Of Year Label",this.monthLabels[_loc2_] + "MC",_loc2_,{_x:_loc4_ * (_loc3_ + (this.monthPoints[_loc2_ + 1] - _loc3_) / 2),labelText:this.monthLabels[_loc2_]});
      }
      _loc2_ = _loc2_ + 1;
   }
   _loc8_ = this.createEmptyMovieClip("backgroundMC",10);
   _loc8_.clear();
   _loc8_.lineStyle(0,16711680,100);
   _loc8_.beginFill(0,10);
   _loc8_.moveTo(- _loc6_,_loc6_ + 5);
   _loc8_.lineTo(_loc10_ + _loc6_,_loc6_ + 5);
   _loc8_.lineTo(_loc10_ + _loc6_,- _loc6_ - 5);
   _loc8_.lineTo(- _loc6_,- _loc6_ - 5);
   _loc8_.lineTo(- _loc6_,_loc6_ + 5);
   _loc8_._alpha = 0;
   _loc8_.useHandCursor = false;
   _loc8_.onPress = function()
   {
      this._parent._parent.masterMC.pauseAnimation();
      if(this._xmouse > this._parent.cursorMC._x)
      {
         this._parent.incrementBy(1);
      }
      else
      {
         this._parent.incrementBy(-1);
      }
      this.timeLast = getTimer();
      this.wait = this.timeLast + 750;
      this.onEnterFrame = this.onEnterFrameFunc;
   };
   _loc8_.onEnterFrameFunc = function()
   {
      var _loc2_ = getTimer();
      var _loc4_;
      var _loc3_;
      if(_loc2_ > this.wait)
      {
         _loc4_ = 0.01;
         _loc3_ = Math.ceil(_loc4_ * (_loc2_ - this.timeLast));
         if(this._xmouse > this._parent.cursorMC._x)
         {
            this._parent.incrementBy(_loc3_);
         }
         else
         {
            this._parent.incrementBy(- _loc3_);
         }
      }
      this.timeLast = _loc2_;
   };
   _loc8_.onRelease = this.backgroundMC.onReleaseOutside = function()
   {
      this._parent._parent.masterMC.resumeAnimation();
      delete this.onEnterFrame;
   };
   _loc8_ = this.attachMovie("Day Of Year Cursor","cursorMC",20,{_y:-22});
   _loc8_.useHandCursor = false;
   _loc8_.onPress = function()
   {
      this._parent._parent.masterMC.pauseAnimation();
      this.offset = this._parent._xmouse - this._x;
      this.onMouseMove = this.onMouseMoveFunc;
   };
   _loc8_.onMouseMoveFunc = function()
   {
      this._parent._parent.masterMC.setDayOfYear((this._parent._xmouse - this.offset) / this._parent.scaleFactor);
      updateAfterEvent();
   };
   _loc8_.onRelease = this.cursorMC.onReleaseOutside = function()
   {
      this._parent._parent.masterMC.resumeAnimation();
      delete this.onMouseMove;
   };
   this.setCursorDay(this._parent.masterMC.getDayOfYear());
}
var p = DayOfYearSliderClass.prototype = new MovieClip();
Object.registerClass("Day Of Year Slider",DayOfYearSliderClass);
p.monthPoints = [0,31,59,90,120,151,181,212,243,273,304,334,365];
p.monthLabels = ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"];
p.incrementBy = function(arg)
{
   this._parent.masterMC.setDayOfYear(this._parent.masterMC.getDayOfYear() + arg);
};
p.setCursorDay = function(arg)
{
   this.cursorMC._x = this.scaleFactor * (arg + 0.5);
};
