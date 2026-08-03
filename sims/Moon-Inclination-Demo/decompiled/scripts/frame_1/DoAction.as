function update()
{
   var timeNow = getTimer();
   if(animate)
   {
      dateNow += speed * (timeNow - timeLast);
   }
   system.theta = 360 * mod(dateNow,_global.eclipseYear) / _global.eclipseYear;
   system.secondaryAngle = 360 * mod(dateNow,_global.siderealPeriod) / _global.siderealPeriod;
   timeStrip.date = dateNow;
   timeLast = timeNow;
}
function updateZoomWindow(x, y, z)
{
   var zf = 5.786;
   zoomWindow.moon._x = zf * x;
   zoomWindow.moon._y = zf * y;
   if(z < 0)
   {
      zoomWindow.moon.swapDepths(zoomWindow.earth);
   }
   else
   {
      zoomWindow.moon.swapDepths(1);
   }
}
function setDate(arg)
{
   dateNow = arg;
   timeLast = getTimer();
   update();
}
function mod(n, m)
{
   if(n < 0)
   {
      return n % m + m;
   }
   return n % m;
}
function pause()
{
   animate = false;
}
function resume()
{
   animate = animateCheck.getValue();
}
function updateAnimation()
{
   animate = animateCheck.getValue();
}
function changeShowEcliptic()
{
   eclipticPlane._visible = showEclipticCheck.getValue();
}
function changeShowPath()
{
   system.showPath = showPathCheck.getValue();
}
function changeBodySizes()
{
   if(bodySizesCheck.getValue())
   {
      system.bodyScaleFactor = 3;
      caveat._visible = true;
   }
   else
   {
      system.bodyScaleFactor = 1;
      caveat._visible = false;
   }
}
function changeSpeed(arg)
{
   speed = arg / 1000;
}
_global.siderealPeriod = 27.3;
this.onEnterFrame = update;
changeSpeed(2.5);
animate = true;
caveat._visible = false;
