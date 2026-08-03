function animChanged(val)
{
   speed = val / 5;
   trace("speed" + speed);
}
function latitudeChanged(val)
{
   mapMC._sunLatitude = val * 1.4333333333333333;
   mapMC.setLongitudeOffset(val + 180);
   longitudeSlider.value = val + 180;
   if(!animateStatus)
   {
      mapMC.updateDayAndNightRegionsOffset();
      mapMC.sunDeclination = sunDec;
   }
   trace(val);
}
function longitudeChanged(val)
{
   mapMC.setLongitudeOffset(val);
   trace(val);
}
function long1Changed(val)
{
   trace(val);
   mapMC.maskedAreaMC.mapMC_Night.uHere1._x = 225 + val * 450 / 360;
   mapMC.maskedAreaMC.mapMC_Night.uHere2._x = 675 + val * 450 / 360;
   mapMC.maskedAreaMC.mapMC_Day.uHere1._x = 225 + val * 450 / 360;
   mapMC.maskedAreaMC.mapMC_Day.uHere2._x = 675 + val * 450 / 360;
   long1 = - val;
   if(long1 <= 0)
   {
      longNow = Math.abs(long1) + 1;
   }
   else
   {
      longNow = 181 + (180 - long1);
   }
   longNow = Math.floor(count1 * speed + longNow);
   if(longNow > 360)
   {
      longNow -= 360;
   }
   timeNow1 = Math.floor(longNow / 15);
   if(timeNow1 > 12)
   {
      if(longNow - timeNow1 * 15 < 3)
      {
         timeNow.text = timeNow1 - 12 + ":0" + longNow % 15 * 4;
      }
      else
      {
         timeNow.text = timeNow1 - 12 + ":" + longNow % 15 * 4;
      }
      if(timeNow1 - 12 == 12)
      {
         timeNow.text += " PM";
      }
      else
      {
         timeNow.text += " AM";
      }
   }
   else if(timeNow1 == 0)
   {
      if(longNow % 15 < 3)
      {
         timeNow.text = "12:0" + longNow % 15 * 4 + " PM";
      }
      else
      {
         timeNow.text = "12:" + longNow % 15 * 4 + " PM";
      }
   }
   else
   {
      if(longNow % 15 < 3)
      {
         timeNow.text = timeNow1 + ":0" + longNow % 15 * 4;
      }
      else
      {
         timeNow.text = timeNow1 + ":" + longNow % 15 * 4;
      }
      if(timeNow1 == 12)
      {
         timeNow.text += " AM";
      }
      else
      {
         timeNow.text += " PM";
      }
   }
}
function lat1Changed(val)
{
   trace(val);
   mapMC.maskedAreaMC.mapMC_Night.uHere1._y = 112.5 + (- val) * 225 / 180;
   mapMC.maskedAreaMC.mapMC_Night.uHere2._y = 112.5 + (- val) * 225 / 180;
   mapMC.maskedAreaMC.mapMC_Day.uHere1._y = 112.5 + (- val) * 225 / 180;
   mapMC.maskedAreaMC.mapMC_Day.uHere2._y = 112.5 + (- val) * 225 / 180;
   uHere._y = (- val + 90) / 180 * 255 + 37;
   lat1 = - val;
   time2 = Math.asin(0.39795 * Math.cos(0.2163108 + 2 * Math.atan(0.9671396 * Math.tan(0.0086 * (count2 - 186)))));
   trace("time2=" + time2 + count2);
   time1 = 24 - 7.639437268410976 * Math.acos((0.014543315936696234 + Math.sin((- lat1) * 3.141592653589793 / 180) * Math.sin(time2)) / (Math.cos((- lat1) * 3.141592653589793 / 180) * Math.cos(time2)));
   trace("time1=" + Number(time1));
   if(isNaN(time1))
   {
      if(sunDec > 0 && - lat1 > 0 || sunDec < 0 && - lat1 < 0)
      {
         time1 = 24;
      }
      else
      {
         time1 = 0;
      }
   }
   daylightHours.text = Math.round(time1 * 100) / 100 + " hours";
}
function resetChanged()
{
   mapMC.maskedAreaMC.mapMC_Night.uHere1._x = 225;
   mapMC.maskedAreaMC.mapMC_Night.uHere2._x = 675;
   mapMC.maskedAreaMC.mapMC_Day.uHere1._x = 225;
   mapMC.maskedAreaMC.mapMC_Day.uHere2._x = 675;
   mapMC.maskedAreaMC.mapMC_Night.uHere1._y = 112.5;
   mapMC.maskedAreaMC.mapMC_Night.uHere2._y = 112.5;
   mapMC.maskedAreaMC.mapMC_Day.uHere1._y = 112.5;
   mapMC.maskedAreaMC.mapMC_Day.uHere2._y = 112.5;
   longit1.setValue(0);
   latit1.setValue(0);
   long1 = 0;
   lat1 = 0;
   if(long1 <= 0)
   {
      longNow = Math.abs(long1) + 1;
   }
   else
   {
      longNow = 181 + (180 - long1);
   }
   longNow = Math.floor(count1 * speed + longNow);
   if(longNow > 360)
   {
      longNow -= 360;
   }
   timeNow1 = Math.floor(longNow / 15);
   if(timeNow1 > 12)
   {
      if(longNow - timeNow1 * 15 < 3)
      {
         timeNow.text = timeNow1 - 12 + ":0" + longNow % 15 * 4;
      }
      else
      {
         timeNow.text = timeNow1 - 12 + ":" + longNow % 15 * 4;
      }
      if(timeNow1 - 12 == 12)
      {
         timeNow.text += " PM";
      }
      else
      {
         timeNow.text += " AM";
      }
   }
   else if(timeNow1 == 0)
   {
      if(longNow % 15 < 3)
      {
         timeNow.text = "12:0" + longNow % 15 * 4 + " PM";
      }
      else
      {
         timeNow.text = "12:" + longNow % 15 * 4 + " PM";
      }
   }
   else
   {
      if(longNow % 15 < 3)
      {
         timeNow.text = timeNow1 + ":0" + longNow % 15 * 4;
      }
      else
      {
         timeNow.text = timeNow1 + ":" + longNow % 15 * 4;
      }
      if(timeNow1 == 12)
      {
         timeNow.text += " AM";
      }
      else
      {
         timeNow.text += " PM";
      }
   }
   time2 = Math.asin(0.39795 * Math.cos(0.2163108 + 2 * Math.atan(0.9671396 * Math.tan(0.0086 * (count2 - 186)))));
   trace("time2=" + time2 + count2);
   time1 = 24 - 7.639437268410976 * Math.acos((0.014543315936696234 + Math.sin((- lat1) * 3.141592653589793 / 180) * Math.sin(time2)) / (Math.cos((- lat1) * 3.141592653589793 / 180) * Math.cos(time2)));
   trace("time1=" + Number(time1));
   if(isNaN(time1))
   {
      if(sunDec > 0 && lat1 > 0 || sunDec < 0 && lat1 < 0)
      {
         time1 = 24;
      }
      else
      {
         time1 = 0;
      }
   }
   daylightHours.text = Math.round(time1 * 100) / 100 + " hours";
}
function animationChanged()
{
   if(animationButton.getLabel() == "Stop Animation")
   {
      component_Animate(false);
      animationButton.setLabel("Start Animation");
      animateStatus = false;
   }
   else
   {
      component_Animate(true);
      animationButton.setLabel("Stop Animation");
      animateStatus = true;
   }
}
function component_Animate(animateStatus)
{
   if(animateStatus)
   {
      pause_currrentTime = getTimer();
      if(pause_startTime != null)
      {
         pauseTime += pause_currrentTime - pause_startTime;
      }
      else
      {
         pauseTime = 0;
      }
      mapMC.onEnterFrame = function()
      {
         mapMC.setAllowDragging(false);
         if(radioGroup.getValue() == "Day")
         {
            time = getTimer() - startTime - pauseTime;
            time = count1 * timePeriod;
            mapMC._sunLatitude = (- count1) * 1.4375 * speed;
            mapMC.setLongitudeOffset(- (count1 * speed + 180));
            lat = count1 + 180;
            if(lat > 360)
            {
               longitudeSlider.value = count1 / 365 * 360 - 180;
            }
            else
            {
               longitudeSlider.value = count1 / 365 * 360 + 180;
            }
            uHere._x = (long1.value - (mapMC._offset - 180) + 180) / 360 * 515 + 133;
            mapMC.sunDeclination = sunDec;
            count1++;
            if(count1 * speed >= 361)
            {
               count1 = 1;
            }
            if(long1 <= 0)
            {
               longNow = Math.abs(long1) - 1;
            }
            else
            {
               longNow = 180 + (180 - long1);
            }
            longNow = Math.floor(count1 * speed + longNow);
            if(longNow > 360)
            {
               longNow -= 360;
            }
            timeNow1 = Math.floor(longNow / 15);
            if(timeNow1 > 12)
            {
               if(longNow - timeNow1 * 15 < 3)
               {
                  timeNow.text = timeNow1 - 12 + ":0" + longNow % 15 * 4;
               }
               else
               {
                  timeNow.text = timeNow1 - 12 + ":" + longNow % 15 * 4;
               }
               if(timeNow1 - 12 == 12)
               {
                  timeNow.text += " PM";
               }
               else
               {
                  timeNow.text += " AM";
               }
            }
            else if(timeNow1 == 0)
            {
               if(longNow % 15 < 3)
               {
                  timeNow.text = "12:0" + longNow % 15 * 4 + " PM";
               }
               else
               {
                  timeNow.text = "12:" + longNow % 15 * 4 + " PM";
               }
            }
            else
            {
               if(longNow % 15 < 3)
               {
                  timeNow.text = timeNow1 + ":0" + longNow % 15 * 4;
               }
               else
               {
                  timeNow.text = timeNow1 + ":" + longNow % 15 * 4;
               }
               if(timeNow1 == 12)
               {
                  timeNow.text += " AM";
               }
               else
               {
                  timeNow.text += " PM";
               }
            }
            trace("off=" + mapMC._offset + " , " + count1 + " , " + timeNow1 + " , " + longNow);
            trace(timeNow.text);
         }
         else
         {
            trace("radio" + radioGroup.getValue());
            time = getTimer() - startTime - pauseTime;
            time = count2 * timePeriod;
            count3 = count2 * speed;
            trace(time + " , " + time / period + " , " + math.cos(6.283185307179586 * time / period) + " , " + sunDec + " , " + dateNow.text);
            sunDec = amp * math.cos(0.01721420632103996 * (count3 + 10));
            mapMC.sunDeclination = sunDec;
            sunDecText.text = Math.round(sunDec * 100) / 100;
            if(sunDec < 0)
            {
               latRaysText.text = Math.abs(Math.round(sunDec * 100) / 100) + "° S";
            }
            else
            {
               latRaysText.text = Math.round(sunDec * 100) / 100 + "° N";
               sunDecText.text = "+" + Math.round(sunDec * 100) / 100;
            }
            time2 = Math.asin(0.39795 * Math.cos(0.2163108 + 2 * Math.atan(0.9671396 * Math.tan(0.0086 * (count3 - 186)))));
            trace("time2=" + time2 + count2);
            time1 = 24 - 7.639437268410976 * Math.acos((0.014543315936696234 + Math.sin((- lat1) * 3.141592653589793 / 180) * Math.sin(time2)) / (Math.cos((- lat1) * 3.141592653589793 / 180) * Math.cos(time2)));
            trace("time1=" + Number(time1));
            if(isNaN(time1))
            {
               if(sunDec > 0 && - lat1 > 0 || sunDec < 0 && - lat1 < 0)
               {
                  time1 = 24;
               }
               else
               {
                  time1 = 0;
               }
            }
            daylightHours.text = Math.round(time1 * 100) / 100 + " hours";
            count2++;
            if(count3 == 366)
            {
               count2 = 0;
            }
            if(changeMD % speed < 2)
            {
               dateNow.text = dMonth[m1] + " " + (day + 1);
               day++;
               if(day >= dayPerMonth[m1])
               {
                  m1++;
                  day = 0;
                  if(m1 > dMonth.length - 1)
                  {
                     m1 = 0;
                  }
               }
               changeMD++;
            }
            else
            {
               changeMD = 0;
            }
         }
      };
   }
   else
   {
      mapMC.setAllowDragging(true);
      pause_startTime = getTimer();
      delete mapMC.onEnterFrame;
   }
}
delete mapMC.onEnterFrame;
mapMC.showDayAndNightRegions = true;
period = 21900;
timePeriod = period / 730;
lat1 = 0;
long1 = 0;
amp = -23.26;
speed = 1;
startTime = getTimer();
pause_startTime = null;
component_Animate(true);
animateStatus = true;
longit1.setminLabel(" W");
latit1.setminLabel(" S");
longit1.setmaxLabel(" E");
latit1.setmaxLabel(" N");
lSlider = eval(latitudeSlider);
trace(latitudeSlider.initValue);
trace(lSlider);
trace(lSlider.value);
trace(latitudeSlider.valueString);
m1 = 0;
day = 0;
dMonth = ["January","February","March","April","May","June","July","August","September","October","November","December"];
dayPerMonth = [31,28,31,30,31,30,31,31,30,31,30,31];
changeMD = 0;
var count1 = 359;
var count2 = 1;
