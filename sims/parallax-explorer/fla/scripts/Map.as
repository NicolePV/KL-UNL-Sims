function MapClass()
{
   var _loc4_ = this._width;
   var _loc3_ = this._height;
   this.createEmptyMovieClip("measurementsMC",5);
   this.createEmptyMovieClip("measurementsMaskMC",6);
   this.attachMovie("Ruler","rulerMC",10,{_visible:false,_x:100,_y:this.observerMC._y});
   this.createEmptyMovieClip("observerPositionsMC",15);
   this.observerMC.swapDepths(20);
   this.measurementsMaskMC.moveTo(0,0);
   this.measurementsMaskMC.beginFill(16711680,20);
   this.measurementsMaskMC.lineTo(_loc4_,0);
   this.measurementsMaskMC.lineTo(_loc4_,_loc3_);
   this.measurementsMaskMC.lineTo(0,_loc3_);
   this.measurementsMaskMC.lineTo(0,0);
   this.measurementsMaskMC.endFill();
   this.measurementsMC.setMask(this.measurementsMaskMC);
   this.observerMC.leftArrowMC._visible = false;
   this.observerMC.rightArrowMC._visible = false;
   this.rulerMC.tabEnabled = false;
   this.rulerMC.useHandCursor = false;
   this.rulerMC.onPress = function()
   {
      this.xOffset = this._x - this._parent._xmouse;
      this.onMouseMove = this.onMouseMoveFunc;
   };
   this.rulerMC.onRelease = function()
   {
      delete this.onMouseMove;
   };
   this.rulerMC.onReleaseOutside = function()
   {
      delete this.onMouseMove;
   };
   this.rulerMC.onRollOut = function()
   {
   };
   this.rulerMC.onRollOver = function()
   {
   };
   this.rulerMC.onMouseMoveFunc = function()
   {
      var _loc2_ = this.xOffset + this._parent._xmouse;
      if(_loc2_ < this._parent.rulerLeftLimit)
      {
         _loc2_ = this._parent.rulerLeftLimit;
      }
      if(_loc2_ > this._parent.rulerRightLimit)
      {
         _loc2_ = this._parent.rulerRightLimit;
      }
      this._x = _loc2_;
      updateAfterEvent();
   };
   this.observerMC.tabEnabled = false;
   this.observerMC.useHandCursor = false;
   this.observerMC.onPress = this.observerOnPressFunc;
   this.observerMC.onRelease = this.observerOnReleaseFunc;
   this.observerMC.onReleaseOutside = this.observerOnReleaseOutsideFunc;
   this.observerMC.onRollOut = this.observerOnRollOutFunc;
   this.observerMC.onRollOver = this.observerOnRollOverFunc;
   this.observerMC.onMouseMoveFunc = this.observerOnMouseMoveFunc;
}
var p = MapClass.prototype = new MovieClip();
Object.registerClass("Map",MapClass);
p.observerLeftLimit = 18;
p.observerRightLimit = 442;
p.rulerLeftLimit = 20;
p.rulerRightLimit = 412;
p.setBoatPosition = function(pos)
{
   this.boatMC._x = pos.x;
   this.boatMC._y = pos.y;
};
p.setBoatVisibility = function(arg)
{
   this.boatMC._visible = arg;
};
p.takeMeasurement = function(errorLimit, distributionCutoff)
{
   var _loc12_ = this.boatMC._x;
   var _loc11_ = this.boatMC._y;
   var _loc3_ = this.observerMC._x;
   var _loc2_ = this.observerMC._y;
   var _loc6_ = Math.atan2(_loc11_ - _loc2_,_loc12_ - _loc3_);
   var _loc4_ = 1000;
   var _loc13_;
   var _loc8_;
   var _loc10_;
   var _loc9_;
   if(errorLimit > 0)
   {
      do
      {
         var g = this.getRandomGaussian();
      }
      while(Math.abs(g) > distributionCutoff);
      _loc13_ = g * (errorLimit / distributionCutoff);
      _loc8_ = _loc6_ + _loc13_ * 0.017453292519943295;
      _loc10_ = _loc8_ + errorLimit * 0.017453292519943295;
      _loc9_ = _loc8_ - errorLimit * 0.017453292519943295;
      this.measurementsMC.moveTo(_loc3_,_loc2_);
      this.measurementsMC.lineStyle(1,16711680,40);
      this.measurementsMC.beginFill(16711680,8);
      this.measurementsMC.lineTo(_loc3_ + _loc4_ * Math.cos(_loc10_),_loc2_ + _loc4_ * Math.sin(_loc10_));
      this.measurementsMC.lineTo(_loc3_ + _loc4_ * Math.cos(_loc9_),_loc2_ + _loc4_ * Math.sin(_loc9_));
      this.measurementsMC.lineTo(_loc3_,_loc2_);
      this.measurementsMC.endFill();
   }
   else
   {
      this.measurementsMC.moveTo(_loc3_,_loc2_);
      this.measurementsMC.lineStyle(1,16711680,100);
      this.measurementsMC.lineTo(_loc3_ + _loc4_ * Math.cos(_loc6_),_loc2_ + _loc4_ * Math.sin(_loc6_));
   }
};
p.getRandomGaussian = function()
{
   var _loc2_ = Math;
   var _loc0_;
   var _loc1_ = x1 = x2 = 0;
   do
   {
      x1 = 2 * _loc2_.random() - 1;
      x2 = 2 * _loc2_.random() - 1;
      _loc1_ = x1 * x1 + x2 * x2;
   }
   while(_loc1_ >= 1);
   _loc1_ = _loc2_.sqrt(-2 * _loc2_.log(_loc1_) / _loc1_);
   return x1 * _loc1_;
};
p.clearMeasurements = function()
{
   this.measurementsMC.clear();
};
p.refresh = function()
{
   this.measurementsMC.clear();
   this.createEmptyMovieClip("observerPositionsMC",15);
   var _loc2_ = 0;
   while(_loc2_ < this.observerPositionsList.length)
   {
      this.observerPositionsMC.attachMovie("Observer Position Marker","_" + _loc2_,_loc2_,{_y:this.observerMC._y,_x:this.observerPositionsList[_loc2_],label:String.fromCharCode(65 + _loc2_)});
      _loc2_ = _loc2_ + 1;
   }
};
p.observerOnPressFunc = function()
{
   this.xOffset = this._x - this._parent._xmouse;
   this.onMouseMove = this.onMouseMoveFunc;
};
p.observerOnReleaseFunc = function()
{
   delete this.onMouseMove;
};
p.observerOnReleaseOutsideFunc = function()
{
   delete this.onMouseMove;
   this.leftArrowMC._visible = false;
   this.rightArrowMC._visible = false;
};
p.observerOnRollOutFunc = function()
{
   this.leftArrowMC._visible = false;
   this.rightArrowMC._visible = false;
};
p.observerOnRollOverFunc = function()
{
   var _loc4_;
   var _loc5_;
   var _loc2_;
   var _loc3_;
   if(this._parent.observerPositionsList.length > 0)
   {
      _loc4_ = false;
      _loc5_ = false;
      _loc2_ = 0;
      while(_loc2_ < this._parent.observerPositionsList.length)
      {
         _loc3_ = this._parent.observerPositionsList[_loc2_];
         if(_loc3_ < this._x)
         {
            _loc4_ = true;
         }
         if(_loc3_ > this._x)
         {
            _loc5_ = true;
         }
         _loc2_ = _loc2_ + 1;
      }
      this.leftArrowMC._visible = _loc4_;
      this.rightArrowMC._visible = _loc5_;
   }
   else
   {
      this.leftArrowMC._visible = this._x != this._parent.observerLeftLimit;
      this.rightArrowMC._visible = this._x != this._parent.observerRightLimit;
   }
};
p.observerOnMouseMoveFunc = function()
{
   var _loc4_ = this.xOffset + this._parent._xmouse;
   if(_loc4_ < this._parent.observerLeftLimit)
   {
      _loc4_ = this._parent.observerLeftLimit;
   }
   if(_loc4_ > this._parent.observerRightLimit)
   {
      _loc4_ = this._parent.observerRightLimit;
   }
   var _loc5_;
   var _loc6_;
   var _loc2_;
   var _loc3_;
   if(this._parent.observerPositionsList.length > 0)
   {
      _loc5_ = Infinity;
      _loc6_ = _loc4_;
      _loc2_ = 0;
      while(_loc2_ < this._parent.observerPositionsList.length)
      {
         _loc3_ = Math.abs(_loc4_ - this._parent.observerPositionsList[_loc2_]);
         if(_loc3_ < _loc5_)
         {
            _loc5_ = _loc3_;
            _loc6_ = this._parent.observerPositionsList[_loc2_];
         }
         _loc2_ = _loc2_ + 1;
      }
      _loc4_ = _loc6_;
   }
   this._parent.setObserverPosition(_loc4_,true);
   this.onRollOver();
   updateAfterEvent();
};
p.setObserverPosition = function(x, callHandler)
{
   this.observerMC._x = x;
   if(callHandler)
   {
      this._parent.onObserverPositionChanged(x);
   }
};
