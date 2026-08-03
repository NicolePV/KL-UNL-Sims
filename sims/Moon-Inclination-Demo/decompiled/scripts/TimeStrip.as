function TimeStripClass()
{
   this.calendar1._y = 0;
   this.calendar2._y = 0;
   this.calendar3._y = 0;
   var i = 1;
   while(i <= 6)
   {
      this["season" + i]._y = 0;
      i++;
   }
   this.setDate(0);
}
_global.eclipseYear = 346.62;
var p = TimeStripClass.prototype = new MovieClip();
Object.registerClass("TimeStrip",TimeStripClass);
p.halfWidth = 240;
p.seasonSpacing = _global.eclipseYear / 2;
p.onEnterFrame = function()
{
   var timeNow = getTimer();
   this._date += this._speed * (timeNow - this._timeLast);
   this.update();
   this._timeLast = timeNow;
};
p.update = function()
{
};
p.useHandCursor = false;
p.onPress = function()
{
   this._parent.pause();
   this.onMouseMove = this.onMouseMoveFunc;
   this._dragDate = this._date + this._xmouse;
};
p.onMouseMoveFunc = function()
{
   this._parent.setDate(this._dragDate - this._xmouse);
};
p.onRelease = p.onReleaseOutside = function()
{
   this._parent.resume();
   this.onMouseMove = null;
};
p.getDate = function()
{
   return this._date;
};
p.setDate = function(arg)
{
   this._date = arg;
   var k = - this.mod(arg,365);
   this.calendar1._x = k - 365;
   this.calendar2._x = k;
   this.calendar3._x = k + 365;
   var ss = this.seasonSpacing;
   var m = - this.mod(arg,ss);
   this.season1._x = m - 2 * ss;
   this.season2._x = m - ss;
   this.season3._x = m;
   this.season4._x = m + ss;
   this.season5._x = m + 2 * ss;
   this.season6._x = m + 3 * ss;
};
p.mod = function(n, m)
{
   if(n < 0)
   {
      return n % m + m;
   }
   return n % m;
};
p.addProperty("date",p.getDate,p.setDate);
