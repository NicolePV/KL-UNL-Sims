function ConstellationsMenuClass()
{
   this.attachMovie("Constellations Menu Title","titleMC",200);
   this.closedWidth = this.titleMC._width;
   this.closedHeight = this.titleMC._height;
   this.openedWidth = this.closedWidth;
   this.createEmptyMovieClip("closedStateMC",5);
   this.createEmptyMovieClip("openedStateMC",6);
   this.prepareClosedState();
   this.prepareOpenedState();
   this.setOpened(false);
}
var p = ConstellationsMenuClass.prototype = new MovieClip();
Object.registerClass("Constellations Menu",ConstellationsMenuClass);
p.borderThickness = 1;
p.innerShadowThickness = 1;
p.mouseOverBorderColor = 10066329;
p.normalBorderColor = 10066329;
p.innerShadowColor = 13421772;
p.openedFillColor = 15790320;
p.notOpenedFillColor = 15263976;
p.xShift = 1;
p.yShift = 1;
p.setOpened = function(arg)
{
   this.opened = arg;
   this.closedStateMC._visible = !this.opened;
   this.openedStateMC._visible = this.opened;
   this.titleMC.gotoAndStop(!this.opened ? 2 : 1);
};
p.setSelected = function(value, selected)
{
   var _loc2_ = 0;
   while(_loc2_ < this.optionsList.length)
   {
      if(this.optionsList[_loc2_].value == value)
      {
         this.optionsList[_loc2_].setSelected(selected);
         break;
      }
      _loc2_ = _loc2_ + 1;
   }
};
p.deselectAll = function()
{
   var _loc2_ = 0;
   while(_loc2_ < this.optionsList.length)
   {
      this.optionsList[_loc2_].setSelected(false);
      _loc2_ = _loc2_ + 1;
   }
};
p.setShowNormalBorder = function(arg)
{
   this.closedStateMC.mouseOverBorderMC._visible = !arg;
   this.closedStateMC.normalBorderMC._visible = arg;
   this.openedStateMC.mouseOverBorderMC._visible = !arg;
   this.openedStateMC.normalBorderMC._visible = arg;
};
p.setShowDepressedButton = function(arg)
{
   if(arg)
   {
      this.titleMC._x = this.xShift;
      this.titleMC._y = this.yShift;
   }
   else
   {
      this.titleMC._x = 0;
      this.titleMC._y = 0;
   }
};
p.toggleState = function()
{
   this.setOpened(!this.opened);
};
p.onOptionToggled = function(value, selected)
{
   this.setOpened(false);
   this._parent[this._changeHandler].call(this._parent,value);
};
p.onMouseDown = function()
{
   if(!this.hitTest(_xmouse,_ymouse,true) && this.opened)
   {
      this.setOpened(false);
   }
};
p.prepareOpenedState = function()
{
   this.optionsList = [];
   var _loc6_ = 3;
   var _loc18_ = _loc6_ - this.openedWidth / 2;
   var _loc8_ = _loc6_ + this.closedHeight / 2;
   var _loc2_ = 0;
   var _loc3_;
   while(_loc2_ < this._valuesList.length)
   {
      _loc3_ = this.openedStateMC.attachMovie("Constellations Menu Option","option" + _loc2_,1000 + _loc2_,{_x:_loc18_,_y:_loc8_,optionWidth:this.openedWidth - 2 * _loc6_,name:this._namesList[_loc2_],value:this._valuesList[_loc2_]});
      _loc8_ += _loc3_.optionHeight + _loc6_;
      this.optionsList.push(_loc3_);
      _loc2_ = _loc2_ + 1;
   }
   var _loc5_ = this.openedWidth / 2;
   var _loc4_ = _loc5_ - this.borderThickness;
   var _loc19_ = _loc4_ - this.innerShadowThickness;
   var _loc16_ = (- this.closedHeight) / 2;
   var _loc12_ = _loc8_;
   var _loc13_ = _loc12_ - this.borderThickness;
   var _loc17_ = _loc16_ + this.borderThickness;
   var _loc20_ = _loc13_ - this.innerShadowThickness;
   var _loc21_ = _loc17_ + this.innerShadowThickness;
   var _loc7_ = this.openedStateMC.createEmptyMovieClip("fillMC",100);
   _loc7_.moveTo(_loc5_,_loc12_);
   _loc7_.beginFill(this.openedFillColor);
   _loc7_.lineTo(_loc5_,_loc16_);
   _loc7_.lineTo(- _loc5_,_loc16_);
   _loc7_.lineTo(- _loc5_,_loc12_);
   _loc7_.lineTo(_loc5_,_loc12_);
   _loc7_.endFill();
   _loc7_ = this.openedStateMC.createEmptyMovieClip("innerShadowMC",300);
   _loc7_.moveTo(_loc4_,_loc13_);
   _loc7_.beginFill(this.innerShadowColor);
   _loc7_.lineTo(_loc4_,_loc17_);
   _loc7_.lineTo(- _loc4_,_loc17_);
   _loc7_.lineTo(- _loc4_,_loc13_);
   _loc7_.lineTo(_loc4_,_loc13_);
   _loc7_.moveTo(_loc19_,_loc20_);
   _loc7_.lineTo(_loc19_,_loc21_);
   _loc7_.lineTo(- _loc19_,_loc21_);
   _loc7_.lineTo(- _loc19_,_loc20_);
   _loc7_.lineTo(_loc19_,_loc20_);
   _loc7_.endFill();
   _loc7_ = this.openedStateMC.createEmptyMovieClip("normalBorderMC",400);
   _loc7_.moveTo(_loc5_,_loc12_);
   _loc7_.beginFill(this.normalBorderColor);
   _loc7_.lineTo(_loc5_,_loc16_);
   _loc7_.lineTo(- _loc5_,_loc16_);
   _loc7_.lineTo(- _loc5_,_loc12_);
   _loc7_.lineTo(_loc5_,_loc12_);
   _loc7_.moveTo(_loc4_,_loc13_);
   _loc7_.lineTo(_loc4_,_loc17_);
   _loc7_.lineTo(- _loc4_,_loc17_);
   _loc7_.lineTo(- _loc4_,_loc13_);
   _loc7_.lineTo(_loc4_,_loc13_);
   _loc7_.endFill();
   _loc7_ = this.openedStateMC.createEmptyMovieClip("mouseOverBorderMC",401);
   _loc7_.moveTo(_loc5_,_loc12_);
   _loc7_.beginFill(this.mouseOverBorderColor);
   _loc7_.lineTo(_loc5_,_loc16_);
   _loc7_.lineTo(- _loc5_,_loc16_);
   _loc7_.lineTo(- _loc5_,_loc12_);
   _loc7_.lineTo(_loc5_,_loc12_);
   _loc7_.moveTo(_loc4_,_loc13_);
   _loc7_.lineTo(_loc4_,_loc17_);
   _loc7_.lineTo(- _loc4_,_loc17_);
   _loc7_.lineTo(- _loc4_,_loc13_);
   _loc7_.lineTo(_loc4_,_loc13_);
   _loc7_.endFill();
   _loc7_._visible = false;
};
p.prepareClosedState = function()
{
   var _loc5_ = this.closedWidth / 2;
   var _loc3_ = this.closedHeight / 2;
   var _loc4_ = _loc5_ - this.borderThickness;
   var _loc2_ = _loc3_ - this.borderThickness;
   var _loc7_ = _loc4_ - this.innerShadowThickness;
   var _loc8_ = _loc2_ - this.innerShadowThickness;
   var _loc6_ = this.closedStateMC.createEmptyMovieClip("fillMC",100);
   _loc6_.moveTo(_loc5_,_loc3_);
   _loc6_.beginFill(this.notOpenedFillColor);
   _loc6_.lineTo(_loc5_,- _loc3_);
   _loc6_.lineTo(- _loc5_,- _loc3_);
   _loc6_.lineTo(- _loc5_,_loc3_);
   _loc6_.lineTo(_loc5_,_loc3_);
   _loc6_.endFill();
   _loc6_ = this.closedStateMC.createEmptyMovieClip("innerShadowMC",300);
   _loc6_.moveTo(_loc4_,_loc2_);
   _loc6_.beginFill(this.innerShadowColor);
   _loc6_.lineTo(_loc4_,- _loc2_);
   _loc6_.lineTo(- _loc4_,- _loc2_);
   _loc6_.lineTo(- _loc4_,_loc2_);
   _loc6_.lineTo(_loc4_,_loc2_);
   _loc6_.moveTo(_loc7_,_loc8_);
   _loc6_.lineTo(_loc7_,- _loc8_);
   _loc6_.lineTo(- _loc7_,- _loc8_);
   _loc6_.lineTo(- _loc7_,_loc8_);
   _loc6_.lineTo(_loc7_,_loc8_);
   _loc6_.endFill();
   _loc6_ = this.closedStateMC.createEmptyMovieClip("normalBorderMC",400);
   _loc6_.moveTo(_loc5_,_loc3_);
   _loc6_.beginFill(this.normalBorderColor);
   _loc6_.lineTo(_loc5_,- _loc3_);
   _loc6_.lineTo(- _loc5_,- _loc3_);
   _loc6_.lineTo(- _loc5_,_loc3_);
   _loc6_.lineTo(_loc5_,_loc3_);
   _loc6_.moveTo(_loc4_,_loc2_);
   _loc6_.lineTo(_loc4_,- _loc2_);
   _loc6_.lineTo(- _loc4_,- _loc2_);
   _loc6_.lineTo(- _loc4_,_loc2_);
   _loc6_.lineTo(_loc4_,_loc2_);
   _loc6_.endFill();
   _loc6_ = this.closedStateMC.createEmptyMovieClip("mouseOverBorderMC",401);
   _loc6_.moveTo(_loc5_,_loc3_);
   _loc6_.beginFill(this.mouseOverBorderColor);
   _loc6_.lineTo(_loc5_,- _loc3_);
   _loc6_.lineTo(- _loc5_,- _loc3_);
   _loc6_.lineTo(- _loc5_,_loc3_);
   _loc6_.lineTo(_loc5_,_loc3_);
   _loc6_.moveTo(_loc4_,_loc2_);
   _loc6_.lineTo(_loc4_,- _loc2_);
   _loc6_.lineTo(- _loc4_,- _loc2_);
   _loc6_.lineTo(- _loc4_,_loc2_);
   _loc6_.lineTo(_loc4_,_loc2_);
   _loc6_.endFill();
   _loc6_._visible = false;
};
