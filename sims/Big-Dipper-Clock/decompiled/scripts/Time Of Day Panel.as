function TimeOfDayPanelClass()
{
   var _loc1_ = this;
   _loc1_.hourTextField.restrict = "0-9";
   _loc1_.hourTextField.onChanged = function()
   {
      var _loc1_ = this;
      var _loc2_ = new TextFormat();
      _loc2_.bold = true;
      _loc1_.setTextFormat(_loc2_);
      _loc1_.setNewTextFormat(_loc2_);
      _loc1_._parent.wait = getTimer() + _loc1_._parent.delay;
      _loc1_._parent.onEnterFrame = _loc1_._parent.onEnterFrameFunc;
      Key.addListener(_loc1_._parent);
   };
   _loc1_.hourTextField.onKillFocus = function()
   {
      if(this._parent.onEnterFrame != undefined)
      {
         this._parent.setTimeByTextFields();
      }
   };
   _loc1_.minuteTextField.restrict = "0-9";
   _loc1_.minuteTextField.onChanged = function()
   {
      var _loc1_ = this;
      var _loc2_ = new TextFormat();
      _loc2_.bold = true;
      _loc1_.setTextFormat(_loc2_);
      _loc1_.setNewTextFormat(_loc2_);
      _loc1_._parent.wait = getTimer() + _loc1_._parent.delay;
      _loc1_._parent.onEnterFrame = _loc1_._parent.onEnterFrameFunc;
      Key.addListener(_loc1_._parent);
   };
   _loc1_.minuteTextField.onKillFocus = function()
   {
      if(this._parent.onEnterFrame != undefined)
      {
         this._parent.setTimeByTextFields();
      }
   };
}
var p = TimeOfDayPanelClass.prototype = new MovieClip();
Object.registerClass("Time Of Day Panel",TimeOfDayPanelClass);
p.delay = 1250;
p.setEnableManualInput = function(arg)
{
   this.hourTextField.selectable = arg;
   this.minuteTextField.selectable = arg;
};
p.onKeyUp = function()
{
   if(Key.getCode() == 13)
   {
      this.setTimeByTextFields();
   }
};
p.onEnterFrameFunc = function()
{
   if(getTimer() > this.wait)
   {
      this.setTimeByTextFields();
   }
};
p.setTimeByTextFields = function()
{
   var _loc1_ = this;
   var hour = parseInt(_loc1_.hourTextField.text);
   var _loc3_ = parseInt(_loc1_.minuteTextField.text);
   var _loc2_ = new TextFormat();
   _loc2_.bold = false;
   _loc1_.hourTextField.setTextFormat(_loc2_);
   _loc1_.minuteTextField.setTextFormat(_loc2_);
   _loc1_.hourTextField.setNewTextFormat(_loc2_);
   _loc1_.minuteTextField.setNewTextFormat(_loc2_);
   delete _loc1_.onEnterFrame;
   Key.removeListener(_loc1_);
   if(!isFinite(hour) || isNaN(hour) || !isFinite(_loc3_) || isNaN(_loc3_) || hour < 0 || hour > 23 || _loc3_ < 0 || _loc3_ > 59)
   {
      _loc1_.update();
   }
   else
   {
      _loc1_.masterMC.setTimeOfDay(((hour + _loc3_ / 60) / 24 % 1 + 1) % 1);
   }
};
p.update = function()
{
   var _loc2_ = this;
   var tod = _loc2_.masterMC.getTimeOfDay();
   var _loc1_ = Math.floor(24 * tod);
   var minf = 60 * (24 * tod - _loc1_);
   var min = Math.floor(minf + 0.5);
   if(min == 60)
   {
      _loc1_ = (_loc1_ + 1) % 24;
      min = 0;
   }
   if(_loc1_ < 10)
   {
      var hourStr = "0" + String(_loc1_);
   }
   else
   {
      var hourStr = String(_loc1_);
   }
   var _loc3_;
   if(min < 10)
   {
      _loc3_ = "0" + String(min);
   }
   else
   {
      _loc3_ = String(min);
   }
   _loc2_.hourTextField.text = hourStr;
   _loc2_.minuteTextField.text = _loc3_;
   _loc2_.timeOfDayString = hourStr + ":" + _loc3_;
   if(_loc1_ == 0)
   {
      _loc2_.traditionalTimeString = "12:" + _loc3_ + " AM";
   }
   else if(_loc1_ == 12)
   {
      _loc2_.traditionalTimeString = "12:" + _loc3_ + " PM";
   }
   else if(_loc1_ > 12)
   {
      _loc2_.traditionalTimeString = String(_loc1_ - 12) + ":" + _loc3_ + " PM";
   }
   else
   {
      _loc2_.traditionalTimeString = hourStr + ":" + _loc3_ + " AM";
   }
   _loc2_.clockMC.setClockTime(tod);
};
