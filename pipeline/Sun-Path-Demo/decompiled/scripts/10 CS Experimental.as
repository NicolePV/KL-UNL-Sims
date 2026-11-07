var p = CelestialSphereClass.prototype;
p.setDay = function(arg)
{
   this._day = arg % 365;
   this.updateSun();
   this._sTime = 6.283185307179586 * (1.0027397260273974 * this._day % 1);
   this.doM();
   this.doB();
   this.updateObjects();
   this.updateCircles(true);
   this.updateLines(true);
};
p.updateSun = function()
{
   var raNow = this._day * 0.06575342465753424;
   var decNow = 23.5 * Math.sin(this._day * 0.01721420632103996);
   trace("decNow: " + decNow);
   this._sunObject.setPosition({ra:raNow,dec:decNow});
   this.updateObjects();
};
p.getSiderealTime = function()
{
   return this._sTime * 3.819718634205488;
};
p.setSiderealTime = function(arg)
{
   this._sTime = (arg % 24 + 24) % 24 * 0.2617993877991494;
   this.doM();
   this.doB();
   this.updateObjects();
   this.updateCircles(true);
   this.updateLines(true);
};
p.addProperty("siderealTime",p.getSiderealTime,p.setSiderealTime);
p._months = [[31,"January"],[59,"February"],[90,"March"],[120,"April"],[151,"May"],[181,"June"],[212,"July"],[243,"August"],[273,"September"],[304,"October"],[334,"November"],[365,"December"]];
p.getDateString = function()
{
   var today = (this._day + 79.5) % 365;
   var i = 0;
   while(i < 12)
   {
      if(today < this._months[i][0])
      {
         break;
      }
      i++;
   }
   if(i != 0)
   {
      today = today - this._months[i - 1][0] + 1;
   }
   else
   {
      today += 1;
   }
   var hour = 24 * (today % 1);
   var minute = Math.floor(60 * (hour % 1));
   if(minute < 10)
   {
      minute = "0" + minute;
   }
   var hour = Math.floor(hour);
   if(hour >= 12)
   {
      var amPm = "pm";
   }
   else
   {
      var amPm = "am";
   }
   trace(hour);
   hour = ((hour - 1) % 12 + 12) % 12 + 1;
   return this._months[i][1] + " " + Math.floor(today);
};
