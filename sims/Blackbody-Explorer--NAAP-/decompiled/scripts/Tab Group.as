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
   var _loc1_ = this;
   var xCursor = 0;
   var gap = 7;
   var margin = 2;
   var height = 20;
   var mc = _loc1_.createEmptyMovieClip("_tabsMC",1);
   _loc1_._namesArray = [];
   _loc1_._topDepth = arg.length + 10;
   var i = 0;
   var _loc3_;
   var _loc2_;
   while(i < arg.length)
   {
      _loc3_ = mc.createEmptyMovieClip("_tab" + i,i);
      _loc3_._x = xCursor;
      _loc3_.createTextField("_labelText",10,gap + margin,- height + 1,10,0);
      _loc3_._labelText.embedFonts = true;
      _loc3_._labelText.autoSize = "left";
      _loc3_._labelText.multiline = false;
      _loc3_._labelText.selectable = false;
      _loc3_._labelText.setNewTextFormat(new TextFormat("Verdana",12,0));
      _loc3_._labelText.text = arg[i];
      var width = _loc3_._labelText._width;
      xCursor += 2 * margin + width + gap;
      var smc = _loc3_.createEmptyMovieClip("_selectedBackgroundMC",1);
      _loc2_ = _loc3_.createEmptyMovieClip("_unselectedBackgroundMC",2);
      smc.clear();
      smc.lineStyle(1,_loc1_.borderLineColor,100);
      smc.moveTo(0,0);
      smc.beginFill(_loc1_.selectedBackgroundColor,100);
      smc.lineTo(gap,- height);
      smc.lineTo(gap + 2 * margin + width,- height);
      smc.lineTo(2 * (gap + margin) + width,0);
      smc.lineStyle(1,16711680,0);
      smc.lineTo(2 * (gap + margin) + width,3);
      smc.lineTo(0,3);
      smc.lineTo(0,0);
      smc.endFill();
      _loc2_.clear();
      _loc2_.lineStyle(1,16711680,0);
      _loc2_.moveTo(0,0);
      _loc2_.beginFill(_loc1_.selectedBackgroundColor,100);
      _loc2_.lineTo(2 * (gap + margin) + width,0);
      _loc2_.lineTo(2 * (gap + margin) + width,3);
      _loc2_.lineTo(0,3);
      _loc2_.lineTo(0,0);
      _loc2_.endFill();
      _loc2_.lineStyle(1,_loc1_.borderLineColor,100);
      _loc2_.moveTo(0,0);
      _loc2_.beginFill(_loc1_.unselectedBackgroundColor,100);
      _loc2_.lineTo(gap,- height);
      _loc2_.lineTo(gap + 2 * margin + width,- height);
      _loc2_.lineTo(2 * (gap + margin) + width,0);
      _loc2_.lineTo(0,0);
      _loc2_.endFill();
      _loc3_._id = i;
      _loc3_.select = function()
      {
         var _loc1_ = this;
         _loc1_.swapDepths(_loc1_._parent._parent._topDepth);
         _loc1_._parent._parent._topDepth++;
         _loc1_._labelText.textColor = _loc1_._parent._parent.selectedTextColor;
         _loc1_._selectedBackgroundMC._visible = true;
         _loc1_._unselectedBackgroundMC._visible = false;
      };
      _loc3_.unselect = function()
      {
         var _loc1_ = this;
         _loc1_._labelText.textColor = _loc1_._parent._parent.unselectedTextColor;
         _loc1_._selectedBackgroundMC._visible = false;
         _loc1_._unselectedBackgroundMC._visible = true;
      };
      _loc3_.useHandCursor = false;
      _loc3_.onRelease = function()
      {
         this._parent._parent.setSelected(this._id,true);
      };
      _loc1_._namesArray[i] = arg[i];
      i++;
   }
   _loc1_.setSelected(0,false);
};
p.getSelected = function()
{
   return this._namesArray[this._selectedID];
};
p.setSelected = function(arg, callChangeHandler)
{
   var _loc2_ = this;
   var _loc3_;
   switch(typeof arg)
   {
      case "number":
         _loc3_ = arg;
         break;
      case "string":
         _loc3_ = 0;
         while(arg != _loc2_._namesArray[_loc3_] && _loc3_ < _loc2_._namesArray.length)
         {
            _loc3_ = _loc3_ + 1;
         }
         break;
      default:
         _loc3_ = -1;
   }
   var _loc1_;
   if(isFinite(_loc3_) && !isNaN(_loc3_) && _loc3_ >= 0 && _loc3_ < _loc2_._namesArray.length)
   {
      _loc1_ = 0;
      while(_loc1_ < _loc2_._namesArray.length)
      {
         if(_loc1_ == _loc3_)
         {
            _loc2_._tabsMC["_tab" + _loc1_].select();
         }
         else
         {
            _loc2_._tabsMC["_tab" + _loc1_].unselect();
         }
         _loc1_ = _loc1_ + 1;
      }
      _loc2_._selectedID = _loc3_;
      if(callChangeHandler)
      {
         _loc2_._parent[_loc2_.changeHandler](_loc2_.getSelected());
      }
   }
};
