_global.DataProviderClass = function()
{
   this.init();
};
DataProviderClass.prototype.init = function()
{
   this.items = new Array();
   this.uniqueID = 0;
   this.views = new Array();
};
DataProviderClass.prototype.addView = function(viewRef)
{
   this.views.push(viewRef);
   var _loc2_ = {event:"updateAll"};
   viewRef.modelChanged(_loc2_);
};
DataProviderClass.prototype.addItemAt = function(index, value)
{
   if(index < this.getLength())
   {
      this.items.splice(index,0,"tmp");
   }
   this.items[index] = new Object();
   if(typeof value == "object")
   {
      this.items[index] = value;
   }
   else
   {
      this.items[index].label = value;
   }
   this.items[index].__ID__ = this.uniqueID++;
   var _loc4_ = {event:"addRows",firstRow:index,lastRow:index};
   this.updateViews(_loc4_);
};
DataProviderClass.prototype.addItem = function(value)
{
   this.addItemAt(this.getLength(),value);
};
DataProviderClass.prototype.removeItemAt = function(index)
{
   var _loc4_ = this.items[index];
   this.items.splice(index,1);
   var _loc3_ = {event:"deleteRows",firstRow:index,lastRow:index};
   this.updateViews(_loc3_);
   return _loc4_;
};
DataProviderClass.prototype.removeAll = function()
{
   this.items = new Array();
   this.updateViews({event:"deleteRows",firstRow:0,lastRow:this.getLength() - 1});
};
DataProviderClass.prototype.replaceItemAt = function(index, itemObj)
{
   if(index < 0 || index >= this.getLength())
   {
      return undefined;
   }
   var _loc3_ = this.getItemID(index);
   if(typeof itemObj == "object")
   {
      this.items[index] = itemObj;
   }
   else
   {
      this.items[index].label = itemObj;
   }
   this.items[index].__ID__ = _loc3_;
   this.updateViews({event:"updateRows",firstRow:index,lastRow:index});
};
DataProviderClass.prototype.getLength = function()
{
   return this.items.length;
};
DataProviderClass.prototype.getItemAt = function(index)
{
   return this.items[index];
};
DataProviderClass.prototype.getItemID = function(index)
{
   return this.items[index].__ID__;
};
DataProviderClass.prototype.sortItemsBy = function(fieldName, order)
{
   this.items.sortOn(fieldName);
   if(order == "DESC")
   {
      this.items.reverse();
   }
   this.updateViews({event:"sort"});
};
DataProviderClass.prototype.updateViews = function(eventObj)
{
   var _loc2_ = 0;
   while(_loc2_ < this.views.length)
   {
      this.views[_loc2_].modelChanged(eventObj);
      _loc2_ = _loc2_ + 1;
   }
};
