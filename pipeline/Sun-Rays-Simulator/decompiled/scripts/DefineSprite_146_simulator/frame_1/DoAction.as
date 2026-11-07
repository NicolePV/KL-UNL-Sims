globalStyleFormat.textColor = 16777215;
globalStyleFormat.textBold = true;
globalStyleFormat.applyChanges();
this.myStar.onPress = function()
{
   this._parent.active = true;
};
this.myStar.onRelease = this.myStar.onReleaseOutside = function()
{
   this._parent.active = false;
   this._parent.starMove = false;
};
this.myStar.onMouseMove = function()
{
   var _loc1_ = this;
   var _loc2_;
   var _loc3_;
   if(_loc1_._parent.active)
   {
      if(_loc1_._parent.lock._value != 3)
      {
         _loc2_ = _loc1_._parent._xmouse * 0.007142857142857143;
         _loc3_ = Math.round(Math.pow(10,_loc2_));
         _loc1_._parent.d_slider.value = _loc3_;
         _loc1_._parent.starMove = true;
      }
   }
};
this.myHelp.onRelease = function()
{
   this._parent.myWindow._open = true;
};
