this.createEmptyMovieClip("line",1);
line.lineStyle(2,16711935,100);
earth._x = 150 - _root.time.temp * 1.3;
mars._x = 135 - _root.time.temp * 1.05;
_root.statusLabel = "";
if(earth._x <= -149)
{
   earth._x = -149;
}
if(mars._x <= -125)
{
   mars._x = -125;
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
