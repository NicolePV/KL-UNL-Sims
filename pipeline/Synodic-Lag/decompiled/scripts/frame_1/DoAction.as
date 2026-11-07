function init()
{
   time = 0;
   update();
   earthShadow._x = earth._x;
   earthShadow._y = earth._y;
   earthShadow._rotation = earth._rotation;
}
function setposition(object, theta)
{
   var _loc1_ = theta;
   _loc1_ = _loc1_ * 3.141592653589793 / 180;
   object._x = r0 * Math.cos(_loc1_) + x0;
   object._y = (- r0) * Math.sin(_loc1_) + y0;
}
function update(time)
{
   var _loc2_ = time;
   var day = factorGroup.getValue();
   var _loc3_ = 360;
   var _loc1_ = 360 * year / day;
   if(mode == 1 && _loc2_ > 360 / _loc1_)
   {
      _loc2_ = 360 / _loc1_;
      var test = true;
   }
   else if(mode == 2 && _loc2_ > 360 / (_loc1_ - _loc3_))
   {
      _loc2_ = 360 / (_loc1_ - _loc3_);
      var test = true;
   }
   theta = _loc3_ * _loc2_ + theta0;
   phi = _loc1_ * _loc2_ + phi0;
   if(test == true)
   {
      stopAnimation();
   }
   setposition(earth,theta);
   line._rotation = - theta;
   earth._rotation = - phi;
   updatetext();
}
function updatetext()
{
   var _loc1_ = phi % 360 - theta % 360;
   if(_loc1_ < 0)
   {
      _loc1_ = 360 + _loc1_;
   }
   if(_loc1_ == 360)
   {
      _loc1_ = 0;
   }
   hourField.text = _loc1_.toFixed(2) + "°";
}
function onEnterFrameFunc()
{
   var _loc1_ = getTimer();
   var _loc2_ = delayGroup.getValue();
   time += (_loc1_ - timeLast) / 1000 / 50 / _loc2_;
   timeLast = _loc1_;
   update(time);
}
function animateSidereal()
{
   if(onEnterFrame != onEnterFrameFunc)
   {
      earthShadow._x = earth._x;
      earthShadow._y = earth._y;
      earthShadow._rotation = earth._rotation;
      time = 0;
      timeLast = getTimer();
      mode = 1;
      onEnterFrame = onEnterFrameFunc;
      disableButtons();
   }
}
function animateSynodic()
{
   if(onEnterFrame != onEnterFrameFunc)
   {
      earthShadow._x = earth._x;
      earthShadow._y = earth._y;
      earthShadow._rotation = earth._rotation;
      time = 0;
      timeLast = getTimer();
      mode = 2;
      onEnterFrame = onEnterFrameFunc;
      disableButtons();
   }
}
function stopAnimation()
{
   if(onEnterFrame == onEnterFrameFunc)
   {
      theta0 = theta;
      phi0 = phi;
      delete onEnterFrame;
      test = false;
      enableButtons();
   }
}
function disableButtons()
{
   var _loc1_ = this;
   _loc1_.toggleNoonButton.setEnabled(false);
   _loc1_.toggleSiderealButton.setEnabled(false);
   _loc1_.toggleSynodicButton.setEnabled(false);
   _loc1_.factorGroup.setEnabled(false);
}
function enableButtons()
{
   var _loc1_ = this;
   _loc1_.toggleNoonButton.setEnabled(true);
   _loc1_.toggleSiderealButton.setEnabled(true);
   _loc1_.toggleSynodicButton.setEnabled(true);
   _loc1_.factorGroup.setEnabled(true);
}
function toggleNoon()
{
   phi0 = theta0 + Math.floor(phi0 / 360) * 360;
   setposition(earth,theta0);
   line._rotation = - theta0;
   earth._rotation = - phi0;
   theta = theta0;
   phi = phi0;
   updatetext();
}
function showShadow()
{
   if(shadowButton.getValue() == true)
   {
      earthShadow._visible = true;
   }
   else
   {
      earthShadow._visible = false;
   }
}
var x0 = 150;
var y0 = 150;
var r0 = 125;
var theta = 0;
var theta0 = 0;
var phi = 0;
var phi0 = 0;
var mode = 0;
var test = false;
var year = 8766.15271;
earth.swapDepths(100);
earth.duplicateMovieClip("earthShadow",50);
earthShadow._alpha = 25;
init();
var time;
var timeLast = getTimer();
