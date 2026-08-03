monthArray = new Array([["  January"],[31],[31]],[[" February"],[28],[59]],[["    March"],[31],[90]],[["    April"],[30],[120]],[["      May"],[31],[151]],[["     June"],[30],[181]],[["     July"],[31],[212]],[["   August"],[31],[243]],[["September"],[30],[273]],[["  October"],[31],[304]],[[" November"],[30],[334]],[[" December"],[31],[365]]);
month = 2;
day = 21;
totaldays = 80;
theta = 0;
Start._visible = true;
Stop._visible = false;
Animating = false;
degsym = unescape("%ba");
DateBox.text = "    March 21";
DayBox.day_string = "  Vernal Equinox";
lat_string = "at latitude: 0.0" + degsym;
_root.onEnterFrame = function()
{
   if(Animating == true)
   {
      period = 30;
      old_time = new_time;
      new_time = getTimer();
      theta_inc = (new_time - old_time) * 2 * 3.141592653589793 / (period * 1000);
      theta += theta_inc;
      if(theta > 6.283185307179586)
      {
         theta -= 6.283185307179586;
         totaldays = 80 + theta * 365 / 6.283185307179586;
      }
      totaldays += theta_inc * 365 / 6.283185307179586;
      day += theta_inc * 365 / 6.283185307179586;
      if(totaldays >= parseInt(monthArray[month][2]))
      {
         if(month == 11)
         {
            month = 0;
            day = totaldays - 365;
            totaldays -= 365;
         }
         else
         {
            day = totaldays - parseInt(monthArray[month][2]);
            month += 1;
         }
      }
      date_string = monthArray[month][0] + "  " + Math.ceil(day);
      DateBox.text = date_string;
      tol = 8;
      inc = 100 / tol;
      if(Math.abs(totaldays - 80) < tol)
      {
         DayBox._alpha = 100 - inc * Math.abs(totaldays - 80);
         DayBox.day_string = "  Vernal Equinox";
      }
      else if(Math.abs(totaldays - 172) < tol)
      {
         DayBox._alpha = 100 - inc * Math.abs(totaldays - 172);
         DayBox.day_string = "  Summer Solstice";
      }
      else if(Math.abs(totaldays - 264) < tol)
      {
         DayBox._alpha = 100 - inc * Math.abs(totaldays - 264);
         DayBox.day_string = "Autumnal Equinox";
      }
      else if(Math.abs(totaldays - 355) < tol)
      {
         DayBox._alpha = 100 - inc * Math.abs(totaldays - 355);
         DayBox.day_string = "  Winter Solstice";
      }
      else
      {
         DayBox.day_string = "";
      }
      rotangle = 23.5 * Math.sin(theta);
      LineGroup._rotation = rotangle;
      ShadowBox._rotation = rotangle;
      if(rotangle > 0)
      {
         dir = " N";
      }
      else
      {
         dir = " S";
      }
      lat1 = String(Math.abs(rotangle));
      if(Math.abs(totaldays - 172) < 1 || Math.abs(totaldays - 355) < 1)
      {
         lat1 = "23.5";
      }
      if(lat1 > 10)
      {
         lat2 = lat1.substr(0,4);
      }
      else
      {
         lat2 = lat1.substr(0,3);
      }
      lat_string = "at latitude: " + lat2 + degsym + dir;
   }
};
Start.onRelease = function()
{
   Animating = true;
   Start._visible = false;
   Stop._visible = true;
   new_time = getTimer();
};
Stop.onRelease = function()
{
   Animating = false;
   Start._visible = true;
   Stop._visible = false;
};
Math.radian = function(degrees)
{
   return degrees * 3.141592653589793 / 180;
};
Math.degree = function(radian)
{
   return radian * 180 / 3.141592653589793;
};
stop();
