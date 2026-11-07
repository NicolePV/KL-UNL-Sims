function SunDiscClass()
{
   this.stop();
}
var p = SunDiscClass.prototype = new MovieClip();
Object.registerClass("Sun Disc",SunDiscClass);
p.useHandCursor = false;
p.onRollOver = function()
{
   var _loc1_ = this;
   if(_loc1_._object._sp.z > 0 && _loc1_._sphere._parent.getSunDiscEnabled())
   {
      _loc1_.gotoAndStop(2);
   }
};
p.onPress = function()
{
   var _loc1_ = this;
   var _loc2_;
   if(_loc1_._object._sp.z > 0 && _loc1_._sphere._parent.getSunDiscEnabled())
   {
      _loc2_ = {};
      _loc1_._sphere.screenToCelestial({x:_loc1_._sphere._xmouse,y:_loc1_._sphere._ymouse},_loc2_);
      _loc1_._offset = _loc2_.ra - _loc1_._object.getRA();
      _loc1_.onMouseMove = _loc1_.onMouseMoveFunc;
   }
};
p.onMouseMoveFunc = function()
{
   var _loc1_ = this;
   var _loc3_ = {};
   _loc1_._sphere.screenToCelestial({x:_loc1_._sphere._xmouse,y:_loc1_._sphere._ymouse},_loc3_);
   var newRa = _loc3_.ra - _loc1_._offset;
   var _loc2_ = 1 + (newRa - 6) / -3;
   _loc2_ = 0.5 + ((_loc2_ - 0.5) % 8 + 8) % 8;
   _loc1_._sphere._parent.sunPositionSlider.setValue(_loc2_,true);
   updateAfterEvent();
};
p.onRollOut = function()
{
   this.gotoAndStop(1);
};
p.onRelease = function()
{
   this._sphere._parent.sunPositionSlider.grabberMC.doTween();
   delete this.onMouseMove;
};
p.onReleaseOutside = function()
{
   this.gotoAndStop(1);
   this.onRelease();
};
