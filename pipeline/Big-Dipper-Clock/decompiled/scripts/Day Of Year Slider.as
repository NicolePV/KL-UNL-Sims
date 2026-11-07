function DayOfYearSliderClass()
{
   var _loc1_ = this;
   var bh = _loc1_.barMC._height;
   var hh = bh / 2;
   _loc1_.timelineWidth = _loc1_.barMC._width;
   var tw = _loc1_.timelineWidth;
   var sF = _loc1_.scaleFactor = tw / 365;
   _loc1_.barMC._visible = false;
   var mc = _loc1_.createEmptyMovieClip("timelineMC",0);
   mc.clear();
   mc.lineStyle(0,0);
   var _loc2_ = 0;
   var _loc3_;
   while(_loc2_ < 13)
   {
      _loc3_ = _loc1_.monthPoints[_loc2_];
      mc.moveTo(sF * _loc3_,hh);
      mc.lineTo(sF * _loc3_,- hh);
      if(_loc2_ != 12)
      {
         mc.attachMovie("Day Of Year Label",_loc1_.monthLabels[_loc2_] + "MC",_loc2_,{_x:sF * (_loc3_ + (_loc1_.monthPoints[_loc2_ + 1] - _loc3_) / 2),labelText:_loc1_.monthLabels[_loc2_]});
      }
      _loc2_ = _loc2_ + 1;
   }
   var mc = _loc1_.createEmptyMovieClip("backgroundMC",10);
   mc.clear();
   mc.lineStyle(0,16711680,100);
   mc.beginFill(0,10);
   mc.moveTo(- bh,bh + 5);
   mc.lineTo(tw + bh,bh + 5);
   mc.lineTo(tw + bh,- bh - 5);
   mc.lineTo(- bh,- bh - 5);
   mc.lineTo(- bh,bh + 5);
   mc._alpha = 0;
   mc.useHandCursor = false;
   mc.onPress = function()
   {
      var _loc1_ = this;
      _loc1_._parent._parent.masterMC.pauseAnimation();
      if(_loc1_._xmouse > _loc1_._parent.cursorMC._x)
      {
         _loc1_._parent.incrementBy(1);
      }
      else
      {
         _loc1_._parent.incrementBy(-1);
      }
      _loc1_.timeLast = getTimer();
      _loc1_.wait = _loc1_.timeLast + 750;
      _loc1_.onEnterFrame = _loc1_.onEnterFrameFunc;
   };
   mc.onEnterFrameFunc = function()
   {
      var _loc1_ = this;
      var _loc2_ = getTimer();
      var _loc3_;
      if(_loc2_ > _loc1_.wait)
      {
         var rate = 0.01;
         _loc3_ = Math.ceil(rate * (_loc2_ - _loc1_.timeLast));
         if(_loc1_._xmouse > _loc1_._parent.cursorMC._x)
         {
            _loc1_._parent.incrementBy(_loc3_);
         }
         else
         {
            _loc1_._parent.incrementBy(- _loc3_);
         }
      }
      _loc1_.timeLast = _loc2_;
   };
   mc.onRelease = _loc1_.backgroundMC.onReleaseOutside = function()
   {
      this._parent._parent.masterMC.resumeAnimation();
      delete this.onEnterFrame;
   };
   var mc = _loc1_.attachMovie("Day Of Year Cursor","cursorMC",20,{_y:-22});
   mc.useHandCursor = false;
   mc.onPress = function()
   {
      var _loc1_ = this;
      _loc1_._parent._parent.masterMC.pauseAnimation();
      _loc1_.offset = _loc1_._parent._xmouse - _loc1_._x;
      _loc1_.onMouseMove = _loc1_.onMouseMoveFunc;
   };
   mc.onMouseMoveFunc = function()
   {
      var _loc1_ = this;
      _loc1_._parent._parent.masterMC.setDayOfYear((_loc1_._parent._xmouse - _loc1_.offset) / _loc1_._parent.scaleFactor);
      updateAfterEvent();
   };
   mc.onRelease = _loc1_.cursorMC.onReleaseOutside = function()
   {
      this._parent._parent.masterMC.resumeAnimation();
      delete this.onMouseMove;
   };
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
