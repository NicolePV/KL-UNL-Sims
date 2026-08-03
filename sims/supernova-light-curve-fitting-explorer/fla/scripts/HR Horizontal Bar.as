function HRHorizontalBarClass()
{
   var plotMC = this._parent.plotMC;
   this._x = plotMC._x;
   this._y = plotMC._y;
   var _loc5_ = plotMC.plotWidth;
   var _loc9_ = 2;
   var _loc6_ = 3;
   var _loc7_ = 6316128;
   var _loc8_ = 4210752;
   var _loc2_ = 3;
   this.createEmptyMovieClip("barMC",1);
   this.barMC.plotMC = plotMC;
   this.resetBarPosition();
   this.barMC.attachMovie("HRHB Left Value","leftValueMC",10,{_x:- _loc2_});
   this.barMC.attachMovie("HRHB Right Value","rightValueMC",11,{_x:_loc5_ + _loc2_});
   this.barMC.leftValueMC.valueField.borderColor = 8421504;
   this.barMC.rightValueMC.valueField.borderColor = 8421504;
   this.barMC.leftValueMC.valueField.textColor = 13643824;
   this.barMC.rightValueMC.valueField.textColor = 1924851;
   var _loc3_ = this.barMC.createEmptyMovieClip("inactiveBarMC",1);
   _loc3_.clear();
   _loc3_.lineStyle(_loc9_,_loc7_);
   _loc3_.moveTo(- _loc2_,0);
   _loc3_.lineTo(_loc5_ + _loc2_,0);
   _loc3_ = this.barMC.createEmptyMovieClip("activeBarMC",2);
   _loc3_.clear();
   _loc3_.lineStyle(_loc6_,_loc8_);
   _loc3_.moveTo(- _loc2_,0);
   _loc3_.lineTo(_loc5_ + _loc2_,0);
   _loc3_._alpha = 0;
   this.barMC.tabEnabled = false;
   this.barMC.useHandCursor = false;
   this.barMC.onRollOver = function()
   {
      this.inactiveBarMC._alpha = 0;
      this.activeBarMC._alpha = 100;
   };
   this.barMC.onRollOut = function()
   {
      this.inactiveBarMC._alpha = 100;
      this.activeBarMC._alpha = 0;
   };
   this.barMC.onMouseMoveFunc = function()
   {
      var _loc2_ = this._parent._ymouse + this.yOffset;
      if(_loc2_ > 0)
      {
         _loc2_ = 0;
      }
      else if(_loc2_ < - this.plotMC.plotHeight)
      {
         _loc2_ = - this.plotMC.plotHeight;
      }
      this._y = _loc2_;
      this._parent.updateValues();
      updateAfterEvent();
   };
   this.barMC.onPress = function()
   {
      this.yOffset = this._y - this._parent._ymouse;
      this.onMouseMove = this.onMouseMoveFunc;
   };
   this.barMC.onRelease = function()
   {
      delete this.onMouseMove;
   };
   this.barMC.onReleaseOutside = function()
   {
      this.inactiveBarMC._alpha = 100;
      this.activeBarMC._alpha = 0;
      delete this.onMouseMove;
   };
   this.updateValues();
}
var p = HRHorizontalBarClass.prototype = new MovieClip();
Object.registerClass("HR Horizontal Bar",HRHorizontalBarClass);
p.resetBarPosition = function()
{
   this.barMC._y = (- this.barMC.plotMC.plotHeight) / 2;
};
p.updateValues = function()
{
   var _loc3_ = this._parent.plotMC.plotHeight / (this._parent.plotMC._yAxisMax - this._parent.plotMC._yAxisMin);
   var _loc2_ = this._parent.plotMC._yAxisMax + this.barMC._y / _loc3_;
   var _loc4_ = _loc2_ + this._parent.plotMC.distanceModulus;
   this.barMC.leftValueMC.valueField.text = _loc2_.toFixed(1);
   this.barMC.rightValueMC.valueField.text = _loc4_.toFixed(1);
};
