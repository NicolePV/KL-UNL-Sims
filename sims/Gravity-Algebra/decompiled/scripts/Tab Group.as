function TabGroupClass()
{
   this.setNamesArray(this.initNamesArray);
}
var p = TabGroupClass.prototype = new MovieClip();
Object.registerClass("Tab Group",TabGroupClass);
p.borderLineColor = 6710886;
p.selectedTextColor = 0;
p.selectedBackgroundColor = 16448250;
p.unselectedTextColor = 6710886;
p.unselectedBackgroundColor = 16448250;
p.setNamesArray = function(arg)
{
   var _loc11_ = 0;
   var _loc5_ = 7;
   var _loc8_ = 2;
   var _loc9_ = 20;
   var _loc12_ = this.createEmptyMovieClip("_tabsMC",1);
   this._namesArray = [];
   this._topDepth = arg.length + 10;
   var _loc7_ = 0;
   var _loc3_;
   var _loc6_;
   var _loc4_;
   var _loc2_;
   while(_loc7_ < arg.length)
   {
      _loc3_ = _loc12_.createEmptyMovieClip("_tab" + _loc7_,_loc7_);
      _loc3_._x = _loc11_;
      _loc3_.createTextField("_labelText",10,_loc5_ + _loc8_,- _loc9_ + 1,10,0);
      _loc3_._labelText.embedFonts = true;
      _loc3_._labelText.autoSize = "left";
      _loc3_._labelText.multiline = false;
      _loc3_._labelText.selectable = false;
      _loc3_._labelText.setNewTextFormat(new TextFormat("Verdana",12,0));
      _loc3_._labelText.text = arg[_loc7_];
      _loc6_ = _loc3_._labelText._width;
      _loc11_ += 2 * _loc8_ + _loc6_ + _loc5_;
      _loc4_ = _loc3_.createEmptyMovieClip("_selectedBackgroundMC",1);
      _loc2_ = _loc3_.createEmptyMovieClip("_unselectedBackgroundMC",2);
      _loc4_.clear();
      _loc4_.lineStyle(1,this.borderLineColor,100);
      _loc4_.moveTo(0,0);
      _loc4_.beginFill(this.selectedBackgroundColor,100);
      _loc4_.lineTo(_loc5_,- _loc9_);
      _loc4_.lineTo(_loc5_ + 2 * _loc8_ + _loc6_,- _loc9_);
      _loc4_.lineTo(2 * (_loc5_ + _loc8_) + _loc6_,0);
      _loc4_.lineStyle(1,16711680,0);
      _loc4_.lineTo(2 * (_loc5_ + _loc8_) + _loc6_,3);
      _loc4_.lineTo(0,3);
      _loc4_.lineTo(0,0);
      _loc4_.endFill();
      _loc2_.clear();
      _loc2_.lineStyle(1,16711680,0);
      _loc2_.moveTo(0,0);
      _loc2_.beginFill(this.selectedBackgroundColor,100);
      _loc2_.lineTo(2 * (_loc5_ + _loc8_) + _loc6_,0);
      _loc2_.lineTo(2 * (_loc5_ + _loc8_) + _loc6_,3);
      _loc2_.lineTo(0,3);
      _loc2_.lineTo(0,0);
      _loc2_.endFill();
      _loc2_.lineStyle(1,this.borderLineColor,100);
      _loc2_.moveTo(0,0);
      _loc2_.beginFill(this.unselectedBackgroundColor,100);
      _loc2_.lineTo(_loc5_,- _loc9_);
      _loc2_.lineTo(_loc5_ + 2 * _loc8_ + _loc6_,- _loc9_);
      _loc2_.lineTo(2 * (_loc5_ + _loc8_) + _loc6_,0);
      _loc2_.lineTo(0,0);
      _loc2_.endFill();
      _loc3_._id = _loc7_;
      _loc3_.select = function()
      {
         this.swapDepths(this._parent._parent._topDepth);
         this._parent._parent._topDepth++;
         this._labelText.textColor = this._parent._parent.selectedTextColor;
         this._selectedBackgroundMC._visible = true;
         this._unselectedBackgroundMC._visible = false;
      };
      _loc3_.unselect = function()
      {
         this._labelText.textColor = this._parent._parent.unselectedTextColor;
         this._selectedBackgroundMC._visible = false;
         this._unselectedBackgroundMC._visible = true;
      };
      _loc3_.useHandCursor = false;
      _loc3_.onRelease = function()
      {
         this._parent._parent.setSelected(this._id,true);
      };
      this._namesArray[_loc7_] = arg[_loc7_];
      _loc7_ = _loc7_ + 1;
   }
   this.setSelected(0,false);
};
p.getSelected = function()
{
   return this._namesArray[this._selectedID];
};
p.setSelected = function(arg, callChangeHandler)
{
   var _loc3_;
   switch(typeof arg)
   {
      case "number":
         _loc3_ = arg;
         break;
      case "string":
         _loc3_ = 0;
         while(arg != this._namesArray[_loc3_] && _loc3_ < this._namesArray.length)
         {
            _loc3_ = _loc3_ + 1;
         }
         break;
      default:
         _loc3_ = -1;
   }
   var _loc2_;
   if(isFinite(_loc3_) && !isNaN(_loc3_) && _loc3_ >= 0 && _loc3_ < this._namesArray.length)
   {
      _loc2_ = 0;
      while(_loc2_ < this._namesArray.length)
      {
         if(_loc2_ == _loc3_)
         {
            this._tabsMC["_tab" + _loc2_].select();
         }
         else
         {
            this._tabsMC["_tab" + _loc2_].unselect();
         }
         _loc2_ = _loc2_ + 1;
      }
      this._selectedID = _loc3_;
      if(callChangeHandler)
      {
         this._parent[this.changeHandler](this.getSelected());
      }
   }
};
