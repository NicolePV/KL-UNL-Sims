this.createEmptyMovieClip("line",1);
line.lineStyle(2,16711935,100);
earth._x += -1.3;
mars._x += -1.05;
count = 135 - mars._x;
if(earth._x <= -149)
{
   earth._x = -149;
}
if(mars._x <= -125)
{
   mars._x = -125;
   yy = -1 * Math.sqrt(19600 * (1 - Math.pow(mars._x,2) / 40000));
   mars._y = yy;
   _root.startstop.gotoAndStop(1);
   gotoAndPlay(2);
}
_root.time._x = _root.time.left + count / 1.05;
if(_root.time.temp < 20)
{
   _root.statusLabel = "The planet is initially moving \neastward relative to the background stars";
}
else if(_root.time.temp >= 26 && _root.time.temp < 70)
{
   _root.statusLabel = "The planet slows, stops and begins moving \nwestward relative to the background stars";
}
else if(_root.time.temp >= 137 && _root.time.temp < 200)
{
   _root.statusLabel = "The planet now slows, stops and begins \nmoving eastward again";
}
else
{
   _root.statusLabel = "";
}
yy = -1 * Math.sqrt(19600 * (1 - Math.pow(mars._x,2) / 40000));
y = -1 * Math.sqrt(11025 * (1 - Math.pow(earth._x,2) / 22500));
earth._y = y;
mars._y = yy;
var m = (mars._y - earth._y) / (mars._x - earth._x);
var b = earth._y - m * earth._x;
var x = (-400 - b) / m;
line.moveTo(earth._x,earth._y);
marsretro._x = x;
marsretro._y = -400;
line.lineTo(marsretro._x,marsretro._y);
