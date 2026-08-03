function setRadius(r)
{
   var _loc1_ = r;
   if(_loc1_ < minRadius)
   {
      _loc1_ = minRadius;
   }
   else if(_loc1_ > maxRadius)
   {
      _loc1_ = maxRadius;
   }
   galaxyMC.setCircleRadius(_loc1_);
   riskPlotMC.setCursorRadius(_loc1_);
   metalsPlotMC.setCursorRadius(_loc1_);
}
function onReset()
{
   setRadius(18);
}
var minRadius = 1.2;
var maxRadius = 22;
onReset();
