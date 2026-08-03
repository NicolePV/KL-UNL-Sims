function changeShowDirections()
{
   directionLabelsMC._visible = showDirectionsCheckBox.getValue();
}
function onAnimateRateChanged()
{
   animateRate = animateRateSlider.value;
}
function toggleAnimateButton()
{
   if(getAnimateState())
   {
      setAnimateState(false);
      animateButton.setLabel("start animation");
   }
   else
   {
      setAnimateState(true);
      animateButton.setLabel(stopAnimationLabel);
   }
}
function getAnimateState()
{
   if(onEnterFrame == animateOnEnterFrame)
   {
      return true;
   }
   return false;
}
function setAnimateState(arg)
{
   if(arg)
   {
      timeLast = getTimer();
      animateDay = currentDay;
      timelineMC.showShadowCursor = true;
      onEnterFrame = animateOnEnterFrame;
   }
   else
   {
      timelineMC.showShadowCursor = false;
      delete onEnterFrame;
   }
}
function animateOnEnterFrame()
{
   var _loc2_ = getTimer();
   var _loc1_ = sequenceMC.dayTable.length;
   animateDay = ((animateDay + animateRate * (_loc2_ - timeLast)) % _loc1_ + _loc1_) % _loc1_;
   var _loc3_ = Math.floor(animateDay);
   setDay(_loc3_);
   timelineMC.setShadowCursorDay(_loc3_);
   timeLast = _loc2_;
}
function onExcludeOvercastChange()
{
   if(excludeOvercastCheck.getValue())
   {
      timelineMC.setExcludeCategory("overcast");
      setDay(currentDay);
   }
   else
   {
      timelineMC.setExcludeCategory("missing");
      setDay(currentDay);
   }
}
function incrementUpBy(count)
{
   var _loc2_ = sequenceMC.dayTable.length;
   var _loc1_ = currentDay;
   var _loc3_ = count;
   while(_loc3_ > 0)
   {
      if(excludeOvercastCheck.getValue())
      {
         do
         {
            _loc1_ = (_loc1_ + 1) % _loc2_;
         }
         while(sequenceMC.dayTable[_loc1_].overcast || sequenceMC.dayTable[_loc1_].missing);
      }
      else
      {
         do
         {
            _loc1_ = (_loc1_ + 1) % _loc2_;
         }
         while(sequenceMC.dayTable[_loc1_].missing);
      }
      _loc3_ = _loc3_ - 1;
   }
   setDay(_loc1_);
}
function incrementDownBy(count)
{
   var _loc2_ = sequenceMC.dayTable.length;
   var _loc1_ = currentDay;
   var _loc3_ = count;
   while(_loc3_ > 0)
   {
      if(excludeOvercastCheck.getValue())
      {
         do
         {
            _loc1_ = ((_loc1_ - 1) % _loc2_ + _loc2_) % _loc2_;
         }
         while(sequenceMC.dayTable[_loc1_].overcast || sequenceMC.dayTable[_loc1_].missing);
      }
      else
      {
         do
         {
            _loc1_ = ((_loc1_ - 1) % _loc2_ + _loc2_) % _loc2_;
         }
         while(sequenceMC.dayTable[_loc1_].missing);
      }
      _loc3_ = _loc3_ - 1;
   }
   setDay(_loc1_);
}
function setSunDec(arg)
{
   var _loc2_ = parseFloat(arg);
   var _loc3_;
   var _loc1_;
   if(!(isNaN(_loc2_) || !isFinite(_loc2_)))
   {
      if(_loc2_ <= sequenceMC.minDec)
      {
         if(excludeOvercastCheck.getValue())
         {
            setDay(clearWinterSolstice);
         }
         else
         {
            setDay(overcastWinterSolstice);
         }
      }
      else if(_loc2_ >= sequenceMC.maxDec)
      {
         if(excludeOvercastCheck.getValue())
         {
            setDay(clearSummerSolstice);
         }
         else
         {
            setDay(overcastSummerSolstice);
         }
      }
      else
      {
         if(atSolstice)
         {
            thisInterval = (lastInterval + 1) % 2;
         }
         else
         {
            thisInterval = lastInterval;
         }
         if(excludeOvercastCheck.getValue())
         {
            _loc3_ = decLookupTable.clear[thisInterval];
         }
         else
         {
            _loc3_ = decLookupTable.overcast[thisInterval];
         }
         var len = _loc3_.length;
         _loc1_ = 0;
         if(thisInterval == 0)
         {
            while(_loc2_ < _loc3_[_loc1_].dec && _loc1_ < len)
            {
               _loc1_ = _loc1_ + 1;
            }
         }
         else
         {
            while(_loc2_ > _loc3_[_loc1_].dec && _loc1_ < len)
            {
               _loc1_ = _loc1_ + 1;
            }
         }
         if(_loc1_ != 0)
         {
            _loc1_ = _loc1_ - 1;
         }
         setDay(_loc3_[_loc1_].day);
      }
   }
}
function setDay(arg, id)
{
   var start = getTimer();
   var _loc1_ = sequenceMC.dayTable.length;
   currentDay = (arg % _loc1_ + _loc1_) % _loc1_;
   if(excludeOvercastCheck.getValue())
   {
      while(sequenceMC.dayTable[currentDay].overcast || sequenceMC.dayTable[currentDay].missing)
      {
         currentDay = ((currentDay - 1) % _loc1_ + _loc1_) % _loc1_;
      }
      if(currentDay > clearSummerSolstice && currentDay < clearWinterSolstice)
      {
         lastInterval = 0;
         atSolstice = false;
      }
      else if(currentDay > clearWinterSolstice || currentDay < clearSummerSolstice)
      {
         lastInterval = 1;
         atSolstice = false;
      }
      else
      {
         atSolstice = true;
      }
   }
   else
   {
      while(sequenceMC.dayTable[currentDay].missing)
      {
         currentDay = ((currentDay - 1) % _loc1_ + _loc1_) % _loc1_;
      }
      if(currentDay > overcastSummerSolstice && currentDay < overcastWinterSolstice)
      {
         lastInterval = 0;
         atSolstice = false;
      }
      else if(currentDay > overcastWinterSolstice || currentDay < overcastSummerSolstice)
      {
         lastInterval = 1;
         atSolstice = false;
      }
      else
      {
         atSolstice = true;
      }
   }
   sequenceMC.imageDay = currentDay;
   timelineMC.setCursorDay(currentDay);
   dayInfo = sequenceMC.dayTable[currentDay];
   var sunPos = {az:180,alt:dayInfo.alt};
   horizonDiagram.sun.setPosition(sunPos);
   horizonDiagram.sun.setOrientationType("absolute");
   horizonDiagram.updateObjects();
   horizonDiagram.shadow.instance.setSourcePosition({alt:horizonDiagram.sun.alt,az:horizonDiagram.sun.az});
   horizonDiagram.decCircle.setCircleParameters({ra:0,dec:dayInfo.dec,tilt:0});
   horizonDiagram.decCircle.update();
   var _loc2_ = new Date();
   _loc2_.setTime(dayInfo.time);
   var month = ["January","February","March","April","May","June","July","August","September","October","November","December"];
   var daysOfWeek = ["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"];
   dayOfWeekString = daysOfWeek[_loc2_.getUTCDay()];
   dayOfMonthString = _loc2_.getUTCDate();
   monthString = month[_loc2_.getUTCMonth()];
   yearString = _loc2_.getUTCFullYear();
   var _loc3_ = _loc2_.getUTCHours();
   var minutes = _loc2_.getUTCMinutes();
   var seconds = _loc2_.getUTCSeconds();
   if(seconds >= 30)
   {
      if(minutes == 59)
      {
         _loc3_ = _loc3_ + 1;
         minutes = 0;
      }
      else
      {
         minutes++;
      }
   }
   _loc3_ %= 12;
   if(_loc3_ == 0)
   {
      _loc3_ = 12;
   }
   timeString = _loc3_ + ":";
   if(minutes < 10)
   {
      timeString += "0" + minutes;
   }
   else
   {
      timeString += minutes;
   }
   timeString += " pm " + dayInfo.timeZone;
   var hour = Math.floor(dayInfo.ra);
   var minute = Math.floor((dayInfo.ra - hour) * 60);
   raString = hour + "h " + minute + "m";
   decString = dayInfo.dec.toFixed(1) + "°";
   altString = dayInfo.alt.toFixed(1) + "°";
}
function analyzeDayTable()
{
   var _loc1_ = sequenceMC.dayTable;
   var len = _loc1_.length;
   clearWinterSolstice = sequenceMC.winterSolstice;
   clearSummerSolstice = sequenceMC.summerSolstice;
   overcastWinterSolstice = sequenceMC.winterSolstice;
   overcastSummerSolstice = sequenceMC.summerSolstice;
   while(_loc1_[clearWinterSolstice].overcast || _loc1_[clearWinterSolstice].missing)
   {
      clearWinterSolstice--;
   }
   while(_loc1_[overcastWinterSolstice].missing)
   {
      overcastWinterSolstice--;
   }
   while(_loc1_[clearSummerSolstice].overcast || _loc1_[clearSummerSolstice].missing)
   {
      clearSummerSolstice--;
   }
   while(_loc1_[overcastSummerSolstice].missing)
   {
      overcastSummerSolstice--;
   }
   var cSS = clearSummerSolstice;
   var cWS = clearWinterSolstice;
   var oSS = overcastSummerSolstice;
   var oWS = overcastWinterSolstice;
   decLookupTable = [];
   decLookupTable.overcast = [];
   decLookupTable.clear = [];
   var tmpArray = [];
   var _loc2_ = cSS + 1;
   while(_loc2_ < cWS)
   {
      if(!(_loc1_[_loc2_].missing || _loc1_[_loc2_].overcast))
      {
         tmpArray.push({day:_loc2_,dec:_loc1_[_loc2_].dec});
      }
      _loc2_ = _loc2_ + 1;
   }
   decLookupTable.clear[0] = tmpArray;
   var tmpArray = [];
   var count = cSS + (len - cWS);
   _loc2_ = 1;
   var _loc3_;
   while(_loc2_ < count)
   {
      _loc3_ = (cWS + _loc2_) % len;
      if(!(_loc1_[_loc3_].missing || _loc1_[_loc3_].overcast))
      {
         tmpArray.push({day:_loc3_,dec:_loc1_[_loc3_].dec});
      }
      _loc2_ = _loc2_ + 1;
   }
   decLookupTable.clear[1] = tmpArray;
   var tmpArray = [];
   _loc2_ = oSS + 1;
   while(_loc2_ < oWS)
   {
      if(!_loc1_[_loc2_].missing)
      {
         tmpArray.push({day:_loc2_,dec:_loc1_[_loc2_].dec});
      }
      _loc2_ = _loc2_ + 1;
   }
   decLookupTable.overcast[0] = tmpArray;
   var tmpArray = [];
   var count = oSS + (len - oWS);
   _loc2_ = 1;
   while(_loc2_ < count)
   {
      _loc3_ = (oWS + _loc2_) % len;
      if(!_loc1_[_loc3_].missing)
      {
         tmpArray.push({day:_loc3_,dec:_loc1_[_loc3_].dec});
      }
      _loc2_ = _loc2_ + 1;
   }
   decLookupTable.overcast[1] = tmpArray;
}
stopAnimationLabel = "pause animation";
attachMovie("Image Direction Labels","directionLabelsMC",2,{_x:-140,_y:-60});
lastInterval = 0;
atSolstice = false;
defaultStartDay = 282;
sequenceMC = imagesMC.imageSequence;
timelineMC.initialize(sequenceMC.dayTable);
analyzeDayTable();
horizonDiagram.sun.visible = true;
horizonDiagram.shadow.visible = true;
horizonDiagram.decCircle.visible = true;
horizonDiagram.update();
changeShowDirections();
onAnimateRateChanged();
onExcludeOvercastChange();
if(_root.startDay == undefined)
{
   setDay(defaultStartDay);
}
else
{
   var len = sequenceMC.dayTable.length;
   startDay = (parseInt(_root.startDay) % len + len) % len;
   if(!isFinite(startDay) || isNaN(startDay))
   {
      startDay = defaultStartDay;
   }
   setDay(startDay);
}
stop();
