function SunDiskClass()
{
   this.stop();
}
var p = SunDiskClass.prototype = new MovieClip();
Object.registerClass("Sun Disk",SunDiskClass);
p.useHandCursor = false;
p.onRollOver = function()
{
   this.gotoAndStop(2);
};
p.onPress = function()
{
   var _loc3_;
   var _loc2_;
   if(this._object._sp.z > 0)
   {
      if(this._sphere._parent.sunDragMode == "timeOfDay")
      {
         _loc3_ = {x:this._sphere._xmouse,y:this._sphere._ymouse};
         _loc2_ = {};
         this._sphere.screenToCelestial(_loc3_,_loc2_);
         this.hourOffset = _loc2_.ra - this._sphere._parent.rightAscension;
         this.onMouseMove = this.decCircleOnMouseMoveFunc;
      }
      else
      {
         this.onMouseMove = this.analemmaOnMouseMoveFunc;
      }
   }
};
p.decCircleOnMouseMoveFunc = function()
{
   var _loc4_ = {x:this._sphere._xmouse,y:this._sphere._ymouse};
   var _loc2_ = {};
   this._sphere.screenToCelestial(_loc4_,_loc2_);
   var _loc3_ = (this._sphere.siderealTime - _loc2_.ra + this.hourOffset + 12) / 24;
   var _loc5_ = 0.0006944444444444445 * this._sphere._parent.equationOfTime;
   this._sphere._parent.setTimeOfDay(_loc3_ - _loc5_);
};
p.analemmaOnMouseMoveFunc = function()
{
   this._sphere._parent.analemmaMC.setClosestDay();
};
p.onRollOut = function()
{
   this.gotoAndStop(1);
};
p.onRelease = function()
{
   delete this.onMouseMove;
};
p.onReleaseOutside = function()
{
   this.gotoAndStop(1);
   delete this.onMouseMove;
};
