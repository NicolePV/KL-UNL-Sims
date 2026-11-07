function SunDiskClass()
{
   this.stop();
}
var p = SunDiskClass.prototype = new MovieClip();
Object.registerClass("SunDisk",SunDiskClass);
p.useHandCursor = false;
p.onRollOver = function()
{
   var _loc2_ = this;
   var _loc3_ = {};
   var _loc1_ = {};
   _loc2_._object.getPosition(_loc1_);
   _loc2_._sphere.toScreen(_loc1_,_loc3_);
   if(_loc3_.z > 0)
   {
      _loc2_.setShowOutline(true);
   }
   else
   {
      _loc2_.setShowOutline(false);
   }
};
p.onPress = function()
{
   var _loc1_ = this;
   _loc1_._sphere._parent.setAnimateState(false);
   var sp = {};
   var _loc2_ = {};
   _loc1_._object.getPosition(_loc2_);
   _loc1_._sphere.toScreen(_loc2_,sp);
   var _loc3_;
   if(sp.z > 0)
   {
      _loc3_ = {};
      _loc1_._sphere.getMouseRaDec(_loc3_);
      _loc1_.decOffset = _loc3_.dec - _loc1_._object.dec;
      _loc1_.onMouseMove = _loc1_.onMouseMoveFunc;
   }
};
p.onMouseMoveFunc = function()
{
   var _loc2_ = this;
   var _loc1_ = {};
   _loc2_._sphere.getMouseRaDec(_loc1_);
   if(_loc1_.dec != null)
   {
      _loc2_._sphere._parent.setSunDec(_loc1_.dec - _loc2_.decOffset);
      _loc2_._object.setOrientationType("absolute");
      _loc2_._sphere.updateObjects();
   }
};
p.onRollOut = function()
{
   this.setShowOutline(false);
};
p.onReleaseOutside = function()
{
   var _loc1_ = this;
   _loc1_._sphere._parent.setAnimateState(_loc1_._sphere._parent.animateButton.getLabel() == _loc1_._sphere._parent.stopAnimationLabel);
   _loc1_.setShowOutline(false);
   delete _loc1_.onMouseMove;
};
p.onRelease = function()
{
   var _loc1_ = this;
   _loc1_._sphere._parent.setAnimateState(_loc1_._sphere._parent.animateButton.getLabel() == _loc1_._sphere._parent.stopAnimationLabel);
   delete _loc1_.onMouseMove;
};
p.setShowOutline = function(arg)
{
   if(arg)
   {
      this.gotoAndStop(2);
   }
   else
   {
      this.gotoAndStop(1);
   }
};
