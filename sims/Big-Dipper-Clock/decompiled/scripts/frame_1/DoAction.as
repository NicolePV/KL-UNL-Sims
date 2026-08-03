function getTimeOfDay()
{
   return timeOfDay;
}
function setTimeOfDay(tod)
{
   var _loc1_ = tod;
   if(typeof _loc1_ == "number" && !isNaN(_loc1_) && isFinite(_loc1_))
   {
      timeOfDay = (_loc1_ % 1 + 1) % 1;
   }
   else
   {
      trace("skipped setting the time of day, tod: " + _loc1_);
   }
   update();
}
function getDayOfYear()
{
   return dayOfYear;
}
function setDayOfYear(doy)
{
   var _loc1_ = doy;
   if(typeof _loc1_ == "number" && !isNaN(_loc1_) && isFinite(_loc1_))
   {
      dayOfYear = (Math.floor(_loc1_) % 365 + 365) % 365;
   }
   else
   {
      trace("skipped setting the day of year, doy: " + _loc1_);
   }
   update();
}
function setFracDayOfYear(fdoy)
{
   var _loc1_ = fdoy;
   if(typeof _loc1_ == "number" && !isNaN(_loc1_) && isFinite(_loc1_))
   {
      dayOfYear = (Math.floor(_loc1_) % 365 + 365) % 365;
      timeOfDay = (_loc1_ % 1 + 1) % 1;
   }
   else
   {
      trace("skipped setting the fractional day of year, fdoy: " + _loc1_);
   }
   update();
}
function update()
{
   timeOfDayPanel.update();
   dayOfYearPanel.update();
   var _loc1_ = 0;
   while(_loc1_ < 12)
   {
      if(dayOfYear < monthPoints[_loc1_])
      {
         break;
      }
      _loc1_ = _loc1_ + 1;
   }
   _loc1_ = _loc1_ - 1;
   var dateNum = dayOfYear - monthPoints[_loc1_] + 1;
   var fhour = timeOfDay * 24;
   var hour = Math.floor(fhour);
   var _loc2_ = 60 * (fhour - hour);
   var _loc3_ = Math.floor(_loc2_);
   var second = Math.floor(60 * (_loc2_ - _loc3_));
   var d = new Date(currentYear,_loc1_,dateNum,hour,_loc3_,second);
   dstPlacard._visible = d.getTimezoneOffset() == daylightSavingOffset;
   var delta = !dstPlacard._visible ? 0 : daylightSavingDelta;
   skyMC.setSolarDaysSinceZero(dayOfYear + timeOfDay - 78.5 + delta);
}
function reset()
{
   showLabelsCheckBox.setValue(true);
   timeOfDay = 0.05;
   dayOfYear = 78;
   update();
}
function setToNow()
{
   var _loc1_ = new Date();
   var _loc3_ = _loc1_.getMonth();
   var _loc2_ = _loc1_.getDate();
   if(_loc3_ == 1 && _loc2_ == 29)
   {
      _loc2_ = 28;
   }
   var fdoy = monthPoints[_loc3_] + _loc2_ - 1 + (_loc1_.getHours() + (_loc1_.getMinutes() + _loc1_.getSeconds() / 60) / 60) / 24;
   setFracDayOfYear(fdoy);
}
function onShowLabelsChanged()
{
   skyMC.setShowLabels(showLabelsCheckBox.getValue());
}
var now = new Date();
currentYear = now.getYear();
monthPoints = [0,31,59,90,120,151,181,212,243,273,304,334,365];
var jan1 = new Date(currentYear,0,1);
var jul1 = new Date(currentYear,6,1);
standardOffset = jan1.getTimezoneOffset();
daylightSavingOffset = jul1.getTimezoneOffset();
daylightSavingDelta = (daylightSavingOffset - standardOffset) / 1440;
timeOfDayPanel.masterMC = this;
dayOfYearPanel.masterMC = this;
reset();
