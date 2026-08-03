function DayOfYearPanelClass()
{
   var _loc1_ = this;
   _loc1_.attachMovie("FComboBoxSymbol","monthComboBox",1,{_x:380,_y:-8.3,editable:false,labels:_loc1_.monthLabels,data:[],rowCount:12,changeHandler:"setDayOfYearManually"});
   _loc1_.monthComboBox.setStyleProperty("textSelected",0);
   _loc1_.monthComboBox.setStyleProperty("selection",14540253);
   _loc1_.monthComboBox.setStyleProperty("backgroundDisabled",16777215);
   _loc1_.attachMovie("Month Combo Box Blocker","monthBlockerMC",2,{_x:291,_y:9.5,_visible:false});
   _loc1_.monthBlockerMC.useHandCursor = false;
   _loc1_.monthBlockerMC.onPress = function()
   {
   };
   _loc1_.dayOfMonthTextField.restrict = "0-9";
   _loc1_.dayOfMonthTextField.onChanged = function()
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
   _loc1_.dayOfMonthTextField.onKillFocus = function()
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
   var _loc1_ = this;
   var dayOfMonth = parseInt(_loc1_.dayOfMonthTextField.text);
   var month = _loc1_.monthComboBox.getSelectedIndex();
   var _loc2_ = dayOfMonth + _loc1_.monthPoints[month] - 1;
   var _loc3_ = new TextFormat();
   _loc3_.bold = false;
   _loc1_.dayOfMonthTextField.setTextFormat(_loc3_);
   _loc1_.dayOfMonthTextField.setNewTextFormat(_loc3_);
   delete _loc1_.onEnterFrame;
   Key.removeListener(_loc1_);
   if(_loc2_ == undefined || !isFinite(_loc2_) || isNaN(_loc2_) || _loc2_ < _loc1_.monthPoints[month] || _loc2_ >= _loc1_.monthPoints[month + 1])
   {
      _loc1_.update();
   }
   else
   {
      _loc1_.masterMC.setDayOfYear(_loc2_);
   }
};
p.update = function()
{
   var _loc2_ = this;
   var _loc3_ = _loc2_.masterMC.getDayOfYear();
   var _loc1_ = 0;
   while(_loc3_ >= _loc2_.monthPoints[_loc1_] && _loc1_ < 13)
   {
      _loc1_ = _loc1_ + 1;
   }
   _loc1_ = _loc1_ - 1;
   _loc2_.monthString = _loc2_.monthLabels[_loc1_];
   _loc2_.dayOfMonthString = String(_loc3_ - _loc2_.monthPoints[_loc1_] + 1);
   _loc2_.monthComboBox.setSelectedIndex(_loc1_,false);
   _loc2_.dayOfMonthTextField.text = _loc2_.dayOfMonthString;
   _loc2_.dayOfYearSliderMC.setCursorDay(_loc3_);
};
