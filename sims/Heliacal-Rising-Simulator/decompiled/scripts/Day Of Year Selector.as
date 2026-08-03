function DayOfYearSelectorClass()
{
}
var p = DayOfYearSelectorClass.prototype = new MovieClip();
Object.registerClass("Day Of Year Selector",DayOfYearSelectorClass);
p.monthPoints = [0,31,59,90,120,151,181,212,243,273,304,334,365];
p.monthLabels = ["January","February","March","April","May","June","July","August","September","October","November","December"];
p._dayOfYearZB = 0;
p.getDayOfYearZB = function()
{
   return this._dayOfYearZB;
};
p.setDayOfYearZB = function(arg, callChangeHandler)
{
   var _loc1_ = this;
   _loc1_._dayOfYearZB = (Math.floor(arg) % 365 + 365) % 365;
   _loc1_.update();
   if(callChangeHandler)
   {
      _loc1_._parent[_loc1_.changeHandler](_loc1_._dayOfYearZB);
   }
};
p.addProperty("dayOfYearZB",p.getDayOfYearZB,p.setDayOfYearZB);
p.onChangeViaUserInterface = function()
{
   var _loc1_ = this;
   var _loc3_ = _loc1_.dayOfMonthSlider.value;
   var month = _loc1_.monthComboBox.getSelectedIndex();
   var monthLength = _loc1_.monthPoints[month + 1] - _loc1_.monthPoints[month];
   if(_loc3_ > monthLength)
   {
      _loc3_ = monthLength;
      _loc1_.dayOfMonthSlider.value = _loc3_;
   }
   var _loc2_ = _loc3_ + _loc1_.monthPoints[month] - 1;
   if(_loc2_ == undefined || !isFinite(_loc2_) || isNaN(_loc2_) || _loc2_ < 0 || dayOfYear >= 365)
   {
      _loc1_.update();
   }
   else
   {
      _loc1_._dayOfYearZB = _loc2_;
      _loc1_.updateSlider();
      _loc1_._parent[_loc1_.changeHandler](_loc1_._dayOfYearZB);
   }
};
p.updateSlider = function()
{
   this.dayOfYearSliderMC.setCursorDay(this._dayOfYearZB);
};
p.update = function()
{
   var _loc2_ = this;
   var _loc1_ = 0;
   while(_loc2_._dayOfYearZB >= _loc2_.monthPoints[_loc1_] && _loc1_ < 13)
   {
      _loc1_ = _loc1_ + 1;
   }
   _loc1_ = _loc1_ - 1;
   _loc2_.dayOfMonthSlider.value = _loc2_._dayOfYearZB - _loc2_.monthPoints[_loc1_] + 1;
   _loc2_.monthComboBox.setSelectedIndex(_loc1_,false);
   _loc2_.updateSlider();
};
