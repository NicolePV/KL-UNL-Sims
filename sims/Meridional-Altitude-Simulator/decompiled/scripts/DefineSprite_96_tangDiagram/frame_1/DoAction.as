this.arrows.onPress = function()
{
   this._parent.active = true;
};
this.arrows.onRelease = function()
{
   this._parent.active = false;
};
this.arrows.onReleaseOutside = function()
{
   this._parent.active = false;
};
this.arrows.onMouseMove = function()
{
   var _loc2_ = this;
   var _loc1_;
   var _loc3_;
   if(_loc2_._parent.active)
   {
      _loc1_ = _loc2_._parent._xmouse;
      _loc3_ = _loc2_._parent._ymouse;
      if(_loc1_ < 0)
      {
         _loc1_ = 0;
      }
      _loc2_._parent.calculatePos(_loc1_,_loc3_);
   }
};
