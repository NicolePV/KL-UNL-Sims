globalStyleFormat.textColor = 16777215;
globalStyleFormat.textBold = true;
globalStyleFormat.applyChanges();
this.pers_tan.onPress = function()
{
   this._parent._active = true;
};
this.pers_tan.onRelease = function()
{
   this._parent._active = false;
};
this.pers_tan.onReleaseOutside = function()
{
   this._parent._active = false;
};
this.pers_tan.onMouseMove = function()
{
   var _loc2_ = this;
   var _loc3_;
   var _loc1_;
   if(_loc2_._parent._active)
   {
      var x = _loc2_._parent._xmouse - _loc2_._parent.pers_tan._x;
      _loc3_ = _loc2_._parent._ymouse - _loc2_._parent.pers_tan._y;
      _loc1_ = - _loc2_._parent.degree(Math.atan2(_loc3_,x)) - 90;
      if(_loc1_ > 90)
      {
         _loc1_ -= 90;
      }
      else if(_loc1_ < -90)
      {
         _loc1_ = 180 + _loc1_;
      }
      _loc2_._parent.lat = _loc1_;
   }
};
