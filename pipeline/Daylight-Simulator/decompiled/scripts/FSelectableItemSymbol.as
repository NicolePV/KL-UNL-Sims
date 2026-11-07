function FSelectableItemClass()
{
   this.init();
}
FSelectableItemClass.prototype = new FUIComponentClass();
FSelectableItemClass.prototype.init = function()
{
   if(this._name != "itemAsset")
   {
      this.highlighted = false;
      this.layoutContent(100);
   }
};
FSelectableItemClass.prototype.drawItem = function(itmObj, selected)
{
   this.displayContent(itmObj,selected);
   if(this.highlighted != selected || this.controller.focused != this.oldFocus && selected)
   {
      this.setHighlighted(selected);
   }
   this.oldFocus = this.controller.focused;
};
FSelectableItemClass.prototype.setSize = function(width, height)
{
   var _loc2_ = -16384;
   this.width = width;
   this.layoutContent(width);
   this.attachMovie("FHighlightSymbol","highlight_mc",_loc2_);
   this.highlight_mc._x = 0.5;
   this.highlight_mc._width = width - 0.5;
   this.highlight_mc._height = height;
   this.highlight_mc.controller = this;
   this.highlight_mc._alpha = 0;
   this.highlight_mc.trackAsMenu = true;
   this.highlight_mc.onPress = function()
   {
      if(this.controller.enable)
      {
         this.controller.controller.clickHandler(this.controller.itemNum);
      }
   };
   this.highlight_mc.onDragOver = function()
   {
      if(this.controller.controller.focused)
      {
         this.onPress();
      }
   };
   this.highlight_mc.useHandCursor = false;
   this.highlight_mc.trackAsMenu = true;
};
FSelectableItemClass.prototype.setEnabled = function(enabledFlag)
{
   this.enable = enabledFlag;
   this.fLabel_mc.setEnabled(enabledFlag);
   this.highlight_mc.gotoAndStop(!enabledFlag ? "disabled" : "unfocused");
};
FSelectableItemClass.prototype.layoutContent = function(width)
{
   this.attachMovie("FLabelSymbol","fLabel_mc",2,{hostComponent:this.controller});
   this.fLabel_mc._x = 2;
   this.fLabel_mc._y = 0;
   this.fLabel_mc.setSize(width - 2);
   this.fLabel_mc.labelField.selectable = false;
};
FSelectableItemClass.prototype.displayContent = function(itmObj, selected)
{
   var _loc2_ = "";
   if(itmObj.label != undefined)
   {
      _loc2_ = itmObj.label;
   }
   else if(typeof itmObj == "object")
   {
      for(var _loc4_ in itmObj)
      {
         if(_loc4_ != "__ID__")
         {
            _loc2_ = itmObj[_loc4_] + ", " + _loc2_;
         }
      }
      _loc2_ = _loc2_.substring(0,_loc2_.length - 2);
   }
   else
   {
      _loc2_ = itmObj;
   }
   if(this.fLabel_mc.labelField.text != _loc2_)
   {
      this.fLabel_mc.setLabel(_loc2_);
   }
   var _loc5_ = !selected ? this.controller.styleTable.textColor.value : this.controller.styleTable.textSelected.value;
   if(_loc5_ == undefined)
   {
      _loc5_ = !selected ? 0 : 16777215;
   }
   this.fLabel_mc.setColor(_loc5_);
};
FSelectableItemClass.prototype.getItemIndex = function()
{
   return this.controller.getScrollPosition() + this.itemNum;
};
FSelectableItemClass.prototype.getItemModel = function()
{
   return this.controller.getItemAt(this.getItemIndex());
};
FSelectableItemClass.prototype.getHostDataProvider = function()
{
   return this.controller.dataProvider;
};
FSelectableItemClass.prototype.setHighlighted = function(flag)
{
   fade = this.controller.styleTable.fadeRate.value;
   if(fade == undefined || fade == 0 || !flag)
   {
      this.highlight_mc._alpha = !flag ? 0 : 100;
      delete this.onEnterFrame;
   }
   else
   {
      this.fadeN = fade;
      this.fadeX = 1;
      this.highLight_mc._alpha = 20;
      this.onEnterFrame = function()
      {
         this.highLight_mc._alpha = 60 * Math.sqrt(this.fadeX++ / this.fadeN) + 40;
         if(this.fadeX > this.fadeN)
         {
            delete this.onEnterFrame;
         }
      };
   }
   this.highlighted = flag;
};
