function TimelineClass()
{
   var _loc1_ = this;
   _loc1_.attachMovie("TimelineCursor","cursorMC",2000,{_y:-21});
   _loc1_.attachMovie("TimelineShadowCursor","shadowCursorMC",1500,{_y:-21,_visible:false});
   _loc1_.barHeight = 10;
   var _loc2_ = _loc1_.createEmptyMovieClip("backgroundMC",0);
   _loc2_.clear();
   _loc2_.lineStyle(0,16711680,100);
   _loc2_.beginFill(16711680,10);
   _loc2_.moveTo(- _loc1_.barHeight,_loc1_.barHeight + 15);
   _loc2_.lineTo(_loc1_.timelineWidth + _loc1_.barHeight,_loc1_.barHeight + 15);
   _loc2_.lineTo(_loc1_.timelineWidth + _loc1_.barHeight,- _loc1_.barHeight - 5);
   _loc2_.lineTo(- _loc1_.barHeight,- _loc1_.barHeight - 5);
   _loc2_.lineTo(- _loc1_.barHeight,_loc1_.barHeight + 15);
   _loc2_._alpha = 0;
   _loc1_.backgroundMC.incrementRate = 0.01;
   _loc1_.backgroundMC.delayTime = 500;
   _loc1_.backgroundMC.useHandCursor = false;
   _loc1_.backgroundMC.onPress = function()
   {
      var _loc1_ = this;
      _loc1_._parent._parent.setAnimateState(false);
      _loc1_.timeLast = getTimer();
      _loc1_.waitTime = _loc1_.timeLast + _loc1_.delayTime;
      _loc1_.onEnterFrame = _loc1_.onEnterFrameFunc;
      if(_loc1_._xmouse > _loc1_._parent.cursorMC._x)
      {
         _loc1_._parent._parent.incrementUpBy(1);
      }
      else if(_loc1_._xmouse < _loc1_._parent.cursorMC._x)
      {
         _loc1_._parent._parent.incrementDownBy(1);
      }
   };
   _loc1_.backgroundMC.onRelease = _loc1_.backgroundMC.onReleaseOutside = function()
   {
      var _loc1_ = this;
      _loc1_._parent._parent.setAnimateState(_loc1_._parent._parent.animateButton.getLabel() == _loc1_._parent._parent.stopAnimationLabel);
      delete _loc1_.onEnterFrame;
   };
   _loc1_.backgroundMC.onEnterFrameFunc = function()
   {
      var _loc1_ = this;
      var _loc3_ = getTimer();
      var _loc2_;
      if(_loc3_ > _loc1_.waitTime)
      {
         _loc2_ = Math.floor((_loc3_ - _loc1_.timeLast) * _loc1_.incrementRate);
         if(_loc1_._xmouse > _loc1_._parent.cursorMC._x)
         {
            _loc1_._parent._parent.incrementUpBy(_loc2_);
         }
         else if(_loc1_._xmouse < _loc1_._parent.cursorMC._x)
         {
            _loc1_._parent._parent.incrementDownBy(_loc2_);
         }
         _loc1_.timeLast += _loc2_ / _loc1_.incrementRate;
      }
      else
      {
         _loc1_.timeLast = _loc3_;
      }
   };
   _loc1_.cursorMC.useHandCursor = false;
   _loc1_.cursorMC.onPress = function()
   {
      var _loc1_ = this;
      _loc1_._parent._parent.setAnimateState(false);
      _loc1_.offset = _loc1_._parent._xmouse - _loc1_._x;
      _loc1_.onMouseMove = _loc1_.onMouseMoveFunc;
   };
   _loc1_.cursorMC.onMouseMoveFunc = function()
   {
      var _loc1_ = this;
      var _loc2_ = _loc1_._parent.timelineWidth;
      var _loc3_ = Math.floor(((_loc1_._parent._xmouse - _loc1_.offset) % _loc2_ + _loc2_) % _loc2_ / _loc1_._parent.scaleFactor);
      _loc1_._parent.shadowCursorMC._visible = true;
      _loc1_._parent.setShadowCursorDay(_loc3_);
      _loc1_._parent._parent.setDay(_loc3_);
      updateAfterEvent();
   };
   _loc1_.cursorMC.onRelease = _loc1_.cursorMC.onReleaseOutside = function()
   {
      var _loc1_ = this;
      _loc1_._parent.shadowCursorMC._visible = false;
      _loc1_._parent._parent.setAnimateState(_loc1_._parent._parent.animateButton.getLabel() == _loc1_._parent._parent.stopAnimationLabel);
      delete _loc1_.onMouseMove;
   };
}
var p = TimelineClass.prototype = new MovieClip();
Object.registerClass("Timeline",TimelineClass);
p.monthPointsNoLeap = [0,31,59,90,120,151,181,212,243,273,304,334,365];
p.monthPointsLeap = [0,31,60,91,121,152,182,213,244,274,305,335,366];
p.monthLabels = ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"];
p.setCursorDay = function(arg)
{
   var _loc1_ = this;
   _loc1_.cursorMC._x = arg * _loc1_.scaleFactor + _loc1_.scaleFactor / 2;
};
p.setShadowCursorDay = function(arg)
{
   var _loc1_ = this;
   _loc1_.shadowCursorMC._x = arg * _loc1_.scaleFactor + _loc1_.scaleFactor / 2;
};
p.getShowShadowCursor = function()
{
   return this.shadowCursorMC._visible;
};
p.setShowShadowCursor = function(arg)
{
   var _loc1_ = this;
   _loc1_.shadowCursorMC._visible = Boolean(arg);
   if(_loc1_.shadowCursorMC._visible)
   {
      _loc1_.shadowCursorMC._x = _loc1_.cursorMC._x;
   }
};
p.addProperty("showShadowCursor",p.getShowShadowCursor,p.setShowShadowCursor);
p.setExcludeCategory = function(arg)
{
   var _loc1_ = this;
   if(arg == "overcast")
   {
      _loc1_.overcastMC._visible = true;
      _loc1_.missingMC._visible = false;
   }
   else if(arg == "missing")
   {
      _loc1_.overcastMC._visible = false;
      _loc1_.missingMC._visible = true;
   }
   else
   {
      _loc1_.overcastMC._visible = false;
      _loc1_.missingMC._visible = false;
   }
};
p.initialize = function(dayTable)
{
   var _loc2_ = dayTable;
   var len = _loc2_.length;
   var _loc0_;
   var _loc3_ = this.scaleFactor = this.timelineWidth / len;
   var y1 = 16;
   var y2 = 21;
   var fillColor = this.noImageColor;
   var mc = this.createEmptyMovieClip("missingMC",100);
   mc.clear();
   mc.lineStyle(0,16711680,0);
   var _loc1_ = 0;
   while(_loc1_ < len)
   {
      if(_loc2_[_loc1_].missing)
      {
         var lx = _loc3_ * _loc1_;
         while(_loc2_[_loc1_].missing && _loc1_ < len)
         {
            _loc1_ = _loc1_ + 1;
         }
         var rx = _loc3_ * _loc1_;
         mc.moveTo(lx,y2);
         mc.beginFill(fillColor);
         mc.lineTo(rx,y2);
         mc.lineTo(rx,y1);
         mc.lineTo(lx,y1);
         mc.lineTo(lx,y2);
         mc.endFill();
      }
      _loc1_ = _loc1_ + 1;
   }
   mc._visible = false;
   var mc = this.createEmptyMovieClip("overcastMC",200);
   mc.clear();
   mc.lineStyle(0,16711680,0);
   _loc1_ = 0;
   while(_loc1_ < len)
   {
      if(_loc2_[_loc1_].missing || _loc2_[_loc1_].overcast)
      {
         var lx = _loc3_ * _loc1_;
         while((_loc2_[_loc1_].missing || _loc2_[_loc1_].overcast) && _loc1_ < len)
         {
            _loc1_ = _loc1_ + 1;
         }
         var rx = _loc3_ * _loc1_;
         mc.moveTo(lx,y2);
         mc.beginFill(fillColor);
         mc.lineTo(rx,y2);
         mc.lineTo(rx,y1);
         mc.lineTo(lx,y1);
         mc.lineTo(lx,y2);
         mc.endFill();
      }
      _loc1_ = _loc1_ + 1;
   }
   mc._visible = false;
   var mc = this.createEmptyMovieClip("timelineMC",500);
   mc.clear();
   mc.lineStyle(0,0);
   var hh = this.barHeight / 2;
   if(len == 366)
   {
      var monthPoints = this.monthPointsLeap;
   }
   else
   {
      var monthPoints = this.monthPointsNoLeap;
   }
   _loc1_ = 0;
   while(_loc1_ < 13)
   {
      mc.moveTo(_loc3_ * monthPoints[_loc1_],hh);
      mc.lineTo(_loc3_ * monthPoints[_loc1_],- hh);
      if(_loc1_ != 12)
      {
         mc.attachMovie("TimelineLabel",this.monthLabels[_loc1_] + "MC",_loc1_,{_x:_loc3_ * (monthPoints[_loc1_] + (monthPoints[_loc1_ + 1] - monthPoints[_loc1_]) / 2),labelText:this.monthLabels[_loc1_]});
      }
      _loc1_ = _loc1_ + 1;
   }
};
