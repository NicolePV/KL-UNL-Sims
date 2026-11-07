function DayOfYearPanelClass()
{
   this.attachMovie("FComboBoxSymbol","monthComboBox",1,{_x:293,_y:11.5,editable:false,labels:this.monthLabels,data:[],rowCount:12,changeHandler:"setDayOfYearManually"});
   this.monthComboBox.setStyleProperty("textSelected",0);
   this.monthComboBox.setStyleProperty("selection",14540253);
   this.monthComboBox.setStyleProperty("backgroundDisabled",16777215);
   this.attachMovie("Month Combo Box Blocker","monthBlockerMC",2,{_x:291,_y:9.5,_visible:false});
   this.monthBlockerMC.useHandCursor = false;
   this.monthBlockerMC.onPress = function()
   {
   };
   this.dayOfMonthTextField.restrict = "0-9";
   this.dayOfMonthTextField.onChanged = function()
   {
      var _loc2_ = new TextFormat();
      _loc2_.bold = true;
      this.setTextFormat(_loc2_);
      this.setNewTextFormat(_loc2_);
      this._parent.wait = getTimer() + this._parent.delay;
      this._parent.onEnterFrame = this._parent.onEnterFrameFunc;
      Key.addListener(this._parent);
   };
   this.dayOfMonthTextField.onKillFocus = function()
   {
      if(this._parent.onEnterFrame != undefined)
      {
         this._parent.setDayOfYearManually();
      }
   };
}
var p = DayOfYearPanelClass.prototype = new MovieClip();
Object.registerClass("Day Of Year Panel",DayOfYearPanelClass);
p.monthPoints = [0,31,59,90,120,151,181,212,243,273,304,334,365];
p.monthLabels = ["January","February","March","April","May","June","July","August","September","October","November","December"];
p.delay = 1250;
p.setEnableManualInput = function(arg)
{
   this.monthBlockerMC._visible = !arg;
   this.dayOfMonthTextField.selectable = arg;
};
p.onKeyUp = function()
{
   if(Key.getCode() == 13)
   {
      this.setDayOfYearManually();
   }
};
p.onEnterFrameFunc = function()
{
   if(getTimer() > this.wait)
   {
      this.setDayOfYearManually();
   }
};
p.setDayOfYearManually = function()
{
   var _loc5_ = parseInt(this.dayOfMonthTextField.text);
   var _loc4_ = this.monthComboBox.getSelectedIndex();
   var _loc2_ = _loc5_ + this.monthPoints[_loc4_] - 1;
   var _loc3_ = new TextFormat();
   _loc3_.bold = false;
   this.dayOfMonthTextField.setTextFormat(_loc3_);
   this.dayOfMonthTextField.setNewTextFormat(_loc3_);
   delete this.onEnterFrame;
   Key.removeListener(this);
   if(_loc2_ == undefined || !isFinite(_loc2_) || isNaN(_loc2_) || _loc2_ < this.monthPoints[_loc4_] || _loc2_ >= this.monthPoints[_loc4_ + 1])
   {
      this.update();
      return undefined;
   }
   this.masterMC.setDayOfYear(_loc2_);
};
p.update = function()
{
   var _loc3_ = this.masterMC.dayOfYear;
   var _loc2_ = 0;
   while(_loc3_ >= this.monthPoints[_loc2_] && _loc2_ < 13)
   {
      _loc2_ = _loc2_ + 1;
   }
   _loc2_ = _loc2_ - 1;
   this.monthString = this.monthLabels[_loc2_];
   this.dayOfMonthString = String(_loc3_ - this.monthPoints[_loc2_] + 1);
   this.monthComboBox.setSelectedIndex(_loc2_,false);
   this.dayOfMonthTextField.text = this.dayOfMonthString;
   this.dayOfYearSliderMC.setCursorDay(_loc3_);
};
