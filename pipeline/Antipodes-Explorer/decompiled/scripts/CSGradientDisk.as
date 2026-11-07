function CSGradientDiskClass()
{
   var _loc1_ = this;
   if(_loc1_.innerColor == undefined)
   {
      _loc1_.innerColor = 16711680;
   }
   if(_loc1_.innerAlpha == undefined)
   {
      _loc1_.innerAlpha = 80;
   }
   if(_loc1_.outerColor == undefined)
   {
      _loc1_.outerColor = 16711935;
   }
   if(_loc1_.outerAlpha == undefined)
   {
      _loc1_.outerAlpha = 40;
   }
   _loc1_.update();
}
var p = CSGradientDiskClass.prototype = new MovieClip();
Object.registerClass("CSGradientDisk",CSGradientDiskClass);
p._nP = 10;
p._step = 6.283185307179586 / p._nP;
p._aP = new Array();
p._cP = new Array();
var halfStep = p._step / 2;
var cRad = 100 / Math.cos(halfStep);
var i = 0;
while(i < p._nP)
{
   var aObj = new Object();
   var aAngle = (i + 1) * p._step;
   aObj.x = 100 * Math.cos(aAngle);
   aObj.y = -100 * Math.sin(aAngle);
   p._aP[i] = aObj;
   var cObj = new Object();
   var cAngle = aAngle - halfStep;
   cObj.x = cRad * Math.cos(cAngle);
   cObj.y = (- cRad) * Math.sin(cAngle);
   p._cP[i] = cObj;
   i++;
}
p.update = function()
{
   var _loc1_ = this;
   _loc1_.clear();
   _loc1_.lineStyle(1,255,0);
   _loc1_.beginGradientFill("radial",[_loc1_.innerColor,_loc1_.outerColor],[_loc1_.innerAlpha,_loc1_.outerAlpha],[0,255],{matrixType:"box",x:-100,y:-100,w:200,h:200,r:0});
   _loc1_.moveTo(_loc1_._aP[_loc1_._nP - 1].x,_loc1_._aP[_loc1_._nP - 1].y);
   var _loc2_ = 0;
   while(_loc2_ < _loc1_._nP)
   {
      _loc1_.curveTo(_loc1_._cP[_loc2_].x,_loc1_._cP[_loc2_].y,_loc1_._aP[_loc2_].x,_loc1_._aP[_loc2_].y);
      _loc2_ = _loc2_ + 1;
   }
   _loc1_.endFill();
};
