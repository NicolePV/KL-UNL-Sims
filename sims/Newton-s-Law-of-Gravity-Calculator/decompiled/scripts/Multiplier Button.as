function MultiplierButtonClass()
{
   this.placeholderMC._visible = false;
   var _loc3_ = this._width / 2;
   var _loc2_ = this._height / 2;
   var _loc5_ = _loc3_ - this.borderThickness;
   var _loc4_ = _loc2_ - this.borderThickness;
   var _loc7_ = _loc5_ - this.innerShadowThickness;
   var _loc8_ = _loc4_ - this.innerShadowThickness;
   this._xscale = 100;
   this._yscale = 100;
   var _loc6_ = this.createEmptyMovieClip("activeFillMC",100);
   _loc6_.moveTo(_loc3_,_loc2_);
   _loc6_.beginFill(this.activeFillColor);
   _loc6_.lineTo(_loc3_,- _loc2_);
   _loc6_.lineTo(- _loc3_,- _loc2_);
   _loc6_.lineTo(- _loc3_,_loc2_);
   _loc6_.lineTo(_loc3_,_loc2_);
   _loc6_.endFill();
   _loc6_._visible = false;
   _loc6_ = this.createEmptyMovieClip("inactiveFillMC",101);
   _loc6_.moveTo(_loc3_,_loc2_);
   _loc6_.beginFill(this.inactiveFillColor);
   _loc6_.lineTo(_loc3_,- _loc2_);
   _loc6_.lineTo(- _loc3_,- _loc2_);
   _loc6_.lineTo(- _loc3_,_loc2_);
   _loc6_.lineTo(_loc3_,_loc2_);
   _loc6_.endFill();
   this.attachMovie(this.labelSymbol,"labelMC",200,{label:this.label});
   _loc6_ = this.createEmptyMovieClip("innerShadowMC",300);
   _loc6_.moveTo(_loc5_,_loc4_);
   _loc6_.beginFill(this.innerShadowColor);
   _loc6_.lineTo(_loc5_,- _loc4_);
   _loc6_.lineTo(- _loc5_,- _loc4_);
   _loc6_.lineTo(- _loc5_,_loc4_);
   _loc6_.lineTo(_loc5_,_loc4_);
   _loc6_.moveTo(_loc7_,_loc8_);
   _loc6_.lineTo(_loc7_,- _loc8_);
   _loc6_.lineTo(- _loc7_,- _loc8_);
   _loc6_.lineTo(- _loc7_,_loc8_);
   _loc6_.lineTo(_loc7_,_loc8_);
   _loc6_.endFill();
   _loc6_._visible = false;
   _loc6_ = this.createEmptyMovieClip("normalBorderMC",400);
   _loc6_.moveTo(_loc3_,_loc2_);
   _loc6_.beginFill(this.normalBorderColor);
   _loc6_.lineTo(_loc3_,- _loc2_);
   _loc6_.lineTo(- _loc3_,- _loc2_);
   _loc6_.lineTo(- _loc3_,_loc2_);
   _loc6_.lineTo(_loc3_,_loc2_);
   _loc6_.moveTo(_loc5_,_loc4_);
   _loc6_.lineTo(_loc5_,- _loc4_);
   _loc6_.lineTo(- _loc5_,- _loc4_);
   _loc6_.lineTo(- _loc5_,_loc4_);
   _loc6_.lineTo(_loc5_,_loc4_);
   _loc6_.endFill();
   _loc6_ = this.createEmptyMovieClip("mouseOverBorderMC",401);
   _loc6_.moveTo(_loc3_,_loc2_);
   _loc6_.beginFill(this.mouseOverBorderColor);
   _loc6_.lineTo(_loc3_,- _loc2_);
   _loc6_.lineTo(- _loc3_,- _loc2_);
   _loc6_.lineTo(- _loc3_,_loc2_);
   _loc6_.lineTo(_loc3_,_loc2_);
   _loc6_.moveTo(_loc5_,_loc4_);
   _loc6_.lineTo(_loc5_,- _loc4_);
   _loc6_.lineTo(- _loc5_,- _loc4_);
   _loc6_.lineTo(- _loc5_,_loc4_);
   _loc6_.lineTo(_loc5_,_loc4_);
   _loc6_.endFill();
   _loc6_._visible = false;
   this.setEnabled(true);
}
var p = MultiplierButtonClass.prototype = new MovieClip();
Object.registerClass("Multiplier Button",MultiplierButtonClass);
p.borderThickness = 1;
p.innerShadowThickness = 1;
p.mouseOverBorderColor = 11579568;
p.normalBorderColor = 13158600;
p.innerShadowColor = 10526880;
p.activeFillColor = 15132390;
p.inactiveFillColor = 15395562;
p.xShift = 1;
p.yShift = 1;
p.setShowNormalBorder = function(arg)
{
   this.mouseOverBorderMC._visible = !arg;
   this.normalBorderMC._visible = arg;
};
p.setShowInactiveFill = function(arg)
{
   this.activeFillMC._visible = !arg;
   this.inactiveFillMC._visible = arg;
};
p.setShowDepressedButton = function(arg)
{
   this.innerShadowMC._visible = this.buttonDepressed = arg;
   if(arg)
   {
      this.labelMC._x = this.xShift;
      this.labelMC._y = this.yShift;
   }
   else
   {
      this.labelMC._x = 0;
      this.labelMC._y = 0;
   }
};
p.onPress = function()
{
   if(this.enabled)
   {
      this.setShowDepressedButton(true);
   }
};
p.onRollOver = function()
{
   if(this.enabled)
   {
      this.setShowNormalBorder(false);
   }
};
p.onRelease = function()
{
   if(this.enabled)
   {
      this._parent._parent.onMultiplierButtonPressed(this.power,this.increment);
      this.setShowDepressedButton(false);
   }
};
p.setEnabled = function(arg)
{
   this.enabled = arg;
   if(this.enabled)
   {
      this.setShowInactiveFill(false);
      this.labelMC.gotoAndStop(1);
      this.useHandCursor = true;
   }
   else
   {
      this.setShowInactiveFill(true);
      this.labelMC.gotoAndStop(2);
      this.useHandCursor = false;
      this.setShowNormalBorder(true);
      this.setShowDepressedButton(false);
   }
};
p.onRollOut = function()
{
   this.setShowNormalBorder(true);
};
p.onReleaseOutside = function()
{
   this.setShowNormalBorder(true);
   this.setShowDepressedButton(false);
};
