function TimeOfDayPanelClass()
{
   this.hourTextField.restrict = "0-9";
   this.hourTextField.onChanged = function()
   {
      var _loc2_ = new TextFormat();
      _loc2_.bold = true;
      this.setTextFormat(_loc2_);
      this.setNewTextFormat(_loc2_);
      this._parent.wait = getTimer() + this._parent.delay;
      this._parent.onEnterFrame = this._parent.onEnterFrameFunc;
      Key.addListener(this._parent);
   };
   this.hourTextField.onKillFocus = function()
   {
      if(this._parent.onEnterFrame != undefined)
      {
         this._parent.setTimeByTextFields();
      }
   };
   this.minuteTextField.restrict = "0-9";
   this.minuteTextField.onChanged = function()
   {
      var _loc2_ = new TextFormat();
      _loc2_.bold = true;
      this.setTextFormat(_loc2_);
      this.setNewTextFormat(_loc2_);
      this._parent.wait = getTimer() + this._parent.delay;
      this._parent.onEnterFrame = this._parent.onEnterFrameFunc;
      Key.addListener(this._parent);
   };
   this.minuteTextField.onKillFocus = function()
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
   var _loc4_ = parseInt(this.hourTextField.text);
   var _loc3_ = parseInt(this.minuteTextField.text);
   var _loc2_ = new TextFormat();
   _loc2_.bold = false;
   this.hourTextField.setTextFormat(_loc2_);
   this.minuteTextField.setTextFormat(_loc2_);
   this.hourTextField.setNewTextFormat(_loc2_);
   this.minuteTextField.setNewTextFormat(_loc2_);
   delete this.onEnterFrame;
   Key.removeListener(this);
   if(!isFinite(_loc4_) || isNaN(_loc4_) || !isFinite(_loc3_) || isNaN(_loc3_) || _loc4_ < 0 || _loc4_ > 23 || _loc3_ < 0 || _loc3_ > 59)
   {
      this.update();
      return undefined;
   }
   this.masterMC.setTimeOfDay((_loc4_ + _loc3_ / 60) / 24);
};
p.update = function()
{
   var _loc5_ = this.masterMC.timeOfDay;
   var _loc2_ = Math.floor(24 * _loc5_);
   var _loc7_ = 60 * (24 * _loc5_ - _loc2_);
   var _loc4_ = Math.floor(_loc7_ + 0.5);
   if(_loc4_ == 60)
   {
      _loc2_ = (_loc2_ + 1) % 24;
      _loc4_ = 0;
   }
   var _loc6_;
   if(_loc2_ < 10)
   {
      _loc6_ = "0" + String(_loc2_);
   }
   else
   {
      _loc6_ = String(_loc2_);
   }
   var _loc3_;
   if(_loc4_ < 10)
   {
      _loc3_ = "0" + String(_loc4_);
   }
   else
   {
      _loc3_ = String(_loc4_);
   }
   this.hourTextField.text = _loc6_;
   this.minuteTextField.text = _loc3_;
   this.timeOfDayString = _loc6_ + ":" + _loc3_;
   if(_loc2_ == 0)
   {
      this.traditionalTimeString = "12:" + _loc3_ + " AM";
   }
   else if(_loc2_ == 12)
   {
      this.traditionalTimeString = "12:" + _loc3_ + " PM";
   }
   else if(_loc2_ > 12)
   {
      this.traditionalTimeString = String(_loc2_ - 12) + ":" + _loc3_ + " PM";
   }
   else
   {
      this.traditionalTimeString = _loc6_ + ":" + _loc3_ + " AM";
   }
   this.clockMC.setClockTime(_loc5_);
};
