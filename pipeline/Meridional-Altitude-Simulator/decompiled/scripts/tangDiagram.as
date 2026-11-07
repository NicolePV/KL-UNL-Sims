function diagClass()
{
   var _loc1_ = this;
   _loc1_.setPos();
   _loc1_._active = false;
   _loc1_.arrows.poleArrow.equ_arrow1._visible = false;
   _loc1_.arrows.poleArrow.equ_arrow2._visible = false;
   _loc1_.arrows.poleArrow.right1._visible = false;
   _loc1_.arrows.poleArrow.right2._visible = false;
}
var p = diagClass.prototype = new MovieClip();
Object.registerClass("tangDiagram",diagClass);
p.onEnterFrame = function()
{
   var _loc1_ = this;
   _loc1_.arrows._x = _loc1_._arrowX;
   _loc1_.arrows._y = _loc1_._arrowY;
   _loc1_.arrows._rotation = _loc1_.angle;
   if(_loc1_.angle <= 90)
   {
      _loc1_._poleAng = 270 - _loc1_.angle;
   }
   else
   {
      _loc1_._poleAng = 90 - _loc1_.angle;
   }
   _loc1_.arrows.poleArrow._rotation = _loc1_._poleAng;
   _loc1_.createEmptyMovieClip("zenithLine",1);
   _loc1_.zenithLine.lineStyle(2);
   _loc1_.zenithLine.moveTo(0,0);
   _loc1_.zenithLine.lineStyle(2,16777215,90);
   _loc1_.zenithLine.lineTo(_loc1_._arrowX,_loc1_._arrowY);
};
p.calculatePos = function(xPos, yPos)
{
   var _loc2_ = this;
   var _loc1_ = Math.atan2(yPos,xPos);
   _loc2_.angle = _loc2_.degrees(_loc1_) + 90;
   _loc2_._arrowX = 60 * Math.cos(_loc1_);
   _loc2_._arrowY = 60 * Math.sin(_loc1_);
};
p.setPos = function()
{
   var _loc1_ = this;
   if(_loc1_._lat > 90 || _loc1_._lat < -90)
   {
      _loc1_._lat = 90;
   }
   _loc1_.angle = - _loc1_._lat + 90;
   _loc1_._arrowX = 60 * Math.cos(_loc1_.radians(- _loc1_._lat));
   _loc1_._arrowY = 60 * Math.sin(_loc1_.radians(- _loc1_._lat));
};
p.degrees = function(rad)
{
   return rad * 57.29577951308232;
};
p.radians = function(deg)
{
   return deg * 0.017453292519943295;
};
p.getActive = function()
{
   return this._active;
};
p.setActive = function(arg)
{
   this._active = arg;
};
p.getAngle = function()
{
   return this._angle;
};
p.setAngle = function(arg)
{
   this._angle = arg;
};
p.addProperty("active",p.getActive,p.setActive);
p.addProperty("angle",p.getAngle,p.setAngle);
