function FSelectableListClass()
{
   this.init();
}
FSelectableListClass.prototype = new FUIComponentClass();
FSelectableListClass.prototype.init = function()
{
   super.init();
   this.enable = true;
   this.selected = new Array();
   this.topDisplayed = this.numDisplayed = 0;
   this.lastSelected = 0;
   this.tabChildren = false;
   if(this._name != undefined)
   {
      this.dataProvider = new DataProviderClass();
      this.dataProvider.addView(this);
   }
};
FSelectableListClass.prototype.addItemAt = function(index, label, data)
{
   if(index < 0 || !this.enable)
   {
      return undefined;
   }
   this.dataProvider.addItemAt(index,{label:label,data:data});
};
FSelectableListClass.prototype.addItem = function(label, data)
{
   if(!this.enable)
   {
      return undefined;
   }
   this.dataProvider.addItem({label:label,data:data});
};
FSelectableListClass.prototype.removeItemAt = function(index)
{
   this.selectHolder = this.getSelectedIndex();
   var _loc2_ = this.getItemAt(index);
   this.dataProvider.removeItemAt(index);
   return _loc2_;
};
FSelectableListClass.prototype.removeAll = function()
{
   this.dataProvider.removeAll();
};
FSelectableListClass.prototype.replaceItemAt = function(index, newLabel, newData)
{
   this.dataProvider.replaceItemAt(index,{label:newLabel,data:newData});
};
FSelectableListClass.prototype.sortItemsBy = function(fieldName, order)
{
   this.lastSelID = this.dataProvider.getItemID(this.lastSelected);
   this.dataProvider.sortItemsBy(fieldName,order);
};
FSelectableListClass.prototype.getLength = function()
{
   return this.dataProvider.getLength();
};
FSelectableListClass.prototype.getSelectedIndex = function()
{
   var _loc2_;
   for(var _loc3_ in this.selected)
   {
      _loc2_ = this.selected[_loc3_].sIndex;
      if(_loc2_ != undefined)
      {
         return _loc2_;
      }
   }
};
FSelectableListClass.prototype.getSelectedItem = function()
{
   return this.getItemAt(this.getSelectedIndex());
};
FSelectableListClass.prototype.getItemAt = function(index)
{
   return this.dataProvider.getItemAt(index);
};
FSelectableListClass.prototype.getEnabled = function()
{
   return this.enable;
};
FSelectableListClass.prototype.getValue = function()
{
   var _loc2_ = this.getSelectedItem();
   return _loc2_.data != undefined ? _loc2_.data : _loc2_.label;
};
FSelectableListClass.prototype.setSelectedIndex = function(index, flag)
{
   if(index >= 0 && index < this.getLength() && this.enable)
   {
      this.clearSelected();
      this.selectItem(index,true);
      this.lastSelected = index;
      this.invalidate("updateControl");
      if(flag != false)
      {
         this.executeCallBack();
      }
   }
};
FSelectableListClass.prototype.setDataProvider = function(obj)
{
   this.setScrollPosition(0);
   this.clearSelected();
   var _loc2_;
   var _loc4_;
   if(obj instanceof Array)
   {
      this.dataProvider = new DataProviderClass();
      _loc2_ = 0;
      while(_loc2_ < obj.length)
      {
         _loc4_ = typeof obj[_loc2_] != "string" ? obj[_loc2_] : {label:obj[_loc2_]};
         this.dataProvider.addItem(_loc4_);
         _loc2_ = _loc2_ + 1;
      }
   }
   else
   {
      this.dataProvider = obj;
   }
   this.dataProvider.addView(this);
};
FSelectableListClass.prototype.setItemSymbol = function(linkID)
{
   this.tmpPos = this.getScrollPosition();
   this.itemSymbol = linkID;
   this.invalidate("setSize");
   this.setScrollPosition(this.tmpPos);
};
FSelectableListClass.prototype.setEnabled = function(enabledFlag)
{
   this.cleanUI();
   super.setEnabled(enabledFlag);
   this.enable = enabledFlag;
   this.boundingBox_mc.gotoAndStop(!this.enable ? "disabled" : "enabled");
   var _loc4_ = Math.min(this.numDisplayed,this.getLength());
   var _loc3_ = 0;
   while(_loc3_ < _loc4_)
   {
      this.container_mc["fListItem" + _loc3_ + "_mc"].setEnabled(this.enable);
      _loc3_ = _loc3_ + 1;
   }
   if(this.enable)
   {
      this.invalidate("updateControl");
   }
};
FSelectableListClass.prototype.updateControl = function()
{
   var _loc2_ = 0;
   while(_loc2_ < this.numDisplayed)
   {
      this.container_mc["fListItem" + _loc2_ + "_mc"].drawItem(this.getItemAt(this.topDisplayed + _loc2_),this.isSelected(this.topDisplayed + _loc2_));
      _loc2_ = _loc2_ + 1;
   }
};
FSelectableListClass.prototype.setSize = function(w, h)
{
   super.setSize(w,h);
   this.boundingBox_mc._xscale = this.boundingBox_mc._yscale = 100;
   this.boundingBox_mc._xscale = this.width * 100 / this.boundingBox_mc._width;
   this.boundingBox_mc._yscale = this.height * 100 / this.boundingBox_mc._height;
   var _loc3_ = 0;
   var _loc4_;
   var _loc5_;
   while(_loc3_ < this.numDisplayed)
   {
      this.container_mc.attachMovie(this.itemSymbol,"fListItem" + _loc3_ + "_mc",10 + _loc3_,{controller:this,itemNum:_loc3_});
      _loc4_ = this.container_mc["fListItem" + _loc3_ + "_mc"];
      _loc5_ = this.scrollOffset != undefined ? this.scrollOffset : 0;
      _loc4_.setSize(this.width - _loc5_,this.itmHgt);
      _loc4_._y = (this.itmHgt - 2) * _loc3_;
      _loc3_ = _loc3_ + 1;
   }
   this.updateControl();
};
FSelectableListClass.prototype.modelChanged = function(eventObj)
{
   var _loc4_ = eventObj.firstRow;
   var _loc6_ = eventObj.lastRow;
   var _loc8_ = eventObj.event;
   var _loc5_;
   var _loc7_;
   var _loc2_;
   var _loc3_;
   if(_loc8_ == "addRows")
   {
      for(var _loc2_ in this.selected)
      {
         if(this.selected[_loc2_].sIndex != undefined && this.selected[_loc2_].sIndex >= _loc4_)
         {
            this.selected[_loc2_].sIndex += _loc6_ - _loc4_ + 1;
            this.setSelectedIndex(this.selected[_loc2_].sIndex,false);
         }
      }
   }
   else if(_loc8_ == "deleteRows")
   {
      if(_loc4_ == _loc6_)
      {
         _loc5_ = _loc4_;
         if(this.selectHolder == _loc5_)
         {
            this.selectionDeleted = true;
         }
         if(this.topDisplayed + this.numDisplayed >= this.getLength() && this.topDisplayed > 0)
         {
            this.topDisplayed = this.topDisplayed - 1;
            if(this.selectionDeleted && _loc5_ - 1 >= 0)
            {
               this.setSelectedIndex(_loc5_ - 1,false);
            }
         }
         else if(this.selectionDeleted)
         {
            _loc7_ = this.getLength();
            if(_loc5_ == _loc7_ - 1 && _loc7_ > 1 || _loc5_ > _loc7_ / 2)
            {
               this.setSelectedIndex(_loc5_ - 1,false);
            }
            else
            {
               this.setSelectedIndex(_loc5_,false);
            }
         }
         for(_loc2_ in this.selected)
         {
            if(this.selected[_loc2_].sIndex > _loc4_)
            {
               this.selected[_loc2_].sIndex--;
            }
         }
      }
      else
      {
         this.clearSelected();
         this.topDisplayed = 0;
      }
   }
   else if(_loc8_ == "sort")
   {
      _loc7_ = this.getLength();
      _loc2_ = 0;
      while(_loc2_ < _loc7_)
      {
         if(this.isSelected(_loc2_))
         {
            _loc3_ = this.dataProvider.getItemID(_loc2_);
            if(_loc3_ == this.lastSelID)
            {
               this.lastSelected = _loc2_;
            }
            this.selected[String(_loc3_)].sIndex = _loc2_;
         }
         _loc2_ = _loc2_ + 1;
      }
   }
   this.invalidate("updateControl");
};
FSelectableListClass.prototype.measureItmHgt = function()
{
   this.attachMovie(this.itemSymbol,"tmpItem_mc",0,{controller:this});
   this.tmpItem_mc.drawItem({label:"Sizer: PjtTopg"},false);
   this.itmHgt = this.tmpItem_mc._height;
   this.tmpItem_mc.removeMovieClip();
};
FSelectableListClass.prototype.selectItem = function(index, selectedFlag)
{
   if(selectedFlag && !this.isSelected(index))
   {
      this.selected[String(this.dataProvider.getItemID(index))] = {sIndex:index};
   }
   else if(!selectedFlag)
   {
      delete this.selected[String(this.dataProvider.getItemID(index))];
   }
};
FSelectableListClass.prototype.isSelected = function(index)
{
   return this.selected[String(this.dataProvider.getItemID(index))].sIndex != undefined;
};
FSelectableListClass.prototype.clearSelected = function()
{
   var _loc2_;
   for(var _loc3_ in this.selected)
   {
      _loc2_ = this.selected[_loc3_].sIndex;
      if(_loc2_ != undefined && this.topDisplayed <= _loc2_ && _loc2_ < this.topDisplayed + this.numDisplayed)
      {
         this.container_mc["fListItem" + (_loc2_ - this.topDisplayed) + "_mc"].drawItem(this.getItemAt(_loc2_),false);
      }
   }
   delete this.selected;
   this.selected = new Array();
};
FSelectableListClass.prototype.selectionHandler = function(itemNum)
{
   var _loc2_ = this.topDisplayed + itemNum;
   if(this.getItemAt(_loc2_ == undefined))
   {
      this.changeFlag = false;
      return undefined;
   }
   this.changeFlag = true;
   this.clearSelected();
   this.selectItem(_loc2_,true);
   this.container_mc["fListItem" + itemNum + "_mc"].drawItem(this.getItemAt(_loc2_),this.isSelected(_loc2_));
};
FSelectableListClass.prototype.moveSelBy = function(incr)
{
   var _loc3_ = this.getSelectedIndex();
   var _loc2_ = _loc3_ + incr;
   _loc2_ = Math.max(0,_loc2_);
   _loc2_ = Math.min(this.getLength() - 1,_loc2_);
   if(_loc2_ == _loc3_)
   {
      return undefined;
   }
   if(_loc3_ < this.topDisplayed || _loc3_ >= this.topDisplayed + this.numDisplayed)
   {
      this.setScrollPosition(_loc3_);
   }
   if(_loc2_ >= this.topDisplayed + this.numDisplayed || _loc2_ < this.topDisplayed)
   {
      this.setScrollPosition(this.topDisplayed + incr);
   }
   this.selectionHandler(_loc2_ - this.topDisplayed);
};
FSelectableListClass.prototype.clickHandler = function(itmNum)
{
   this.focusRect.removeMovieClip();
   if(!this.focused)
   {
      this.pressFocus();
   }
   this.selectionHandler(itmNum);
   this.onMouseUp = this.releaseHandler;
};
FSelectableListClass.prototype.releaseHandler = function()
{
   if(this.changeFlag)
   {
      this.executeCallBack();
   }
   this.changeFlag = false;
   this.onMouseUp = undefined;
};
FSelectableListClass.prototype.myOnSetFocus = function()
{
   super.myOnSetFocus();
   var _loc3_ = 0;
   while(_loc3_ < this.numDisplayed)
   {
      this.container_mc["fListItem" + _loc3_ + "_mc"].highlight_mc.gotoAndStop("enabled");
      _loc3_ = _loc3_ + 1;
   }
};
FSelectableListClass.prototype.myOnKillFocus = function()
{
   super.myOnKillFocus();
   var _loc3_ = 0;
   while(_loc3_ < this.numDisplayed)
   {
      this.container_mc["fListItem" + _loc3_ + "_mc"].highlight_mc.gotoAndStop("unfocused");
      _loc3_ = _loc3_ + 1;
   }
};
