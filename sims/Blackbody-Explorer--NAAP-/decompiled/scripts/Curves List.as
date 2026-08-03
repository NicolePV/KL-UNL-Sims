function CurvesListClass()
{
   this.mcList = [];
   this.selectedListingMC = null;
}
var p = CurvesListClass.prototype = new MovieClip();
Object.registerClass("Curves List",CurvesListClass);
p.setAppearance = function(id, thickness, color, alpha)
{
   this.getMCFromID(id).setAppearance(thickness,color,alpha);
};
p.setSelectedListing = function(id)
{
   var _loc1_ = this;
   _loc1_.selectedListingMC.setSelectedState(false);
   _loc1_.selectedListingMC = _loc1_.getMCFromID(id);
   _loc1_.selectedListingMC.setSelectedState(true);
};
p.setListingName = function(id, name)
{
   this.getMCFromID(id).setName(name);
};
p.setListingValues = function(id, temp, peak, area)
{
   this.getMCFromID(id).setValues(temp,peak,area);
};
p.addListing = function(id, name)
{
   var _loc1_ = this;
   var mc = _loc1_.attachMovie("Curve List Entry","_" + id,id,{mainMC:_loc1_._parent,curveID:id,initName:name});
   _loc1_.mcList.push({id:id,mc:mc});
   _loc1_.refreshList();
};
p.removeListing = function(id)
{
   var _loc2_ = this;
   var _loc1_ = _loc2_.getIndexFromID(id);
   _loc2_.mcList[_loc1_].mc.removeMovieClip();
   _loc2_.mcList.splice(_loc1_,1);
   _loc2_.refreshList();
};
p.refreshList = function()
{
   var _loc2_ = this.mcList;
   var _loc3_ = _loc2_.length;
   var _loc1_ = 0;
   while(_loc1_ < _loc3_)
   {
      _loc2_[_loc1_].mc._y = _loc1_ * 21;
      _loc1_ = _loc1_ + 1;
   }
};
p.getIndexFromID = function(id)
{
   var _loc2_ = this.mcList;
   var _loc3_ = _loc2_.length;
   var _loc1_ = 0;
   while(_loc1_ < _loc3_)
   {
      if(_loc2_[_loc1_].id == id)
      {
         return _loc1_;
      }
      _loc1_ = _loc1_ + 1;
   }
   return null;
};
p.getMCFromID = function(id)
{
   var _loc2_ = this.mcList;
   var _loc3_ = _loc2_.length;
   var _loc1_ = 0;
   while(_loc1_ < _loc3_)
   {
      if(_loc2_[_loc1_].id == id)
      {
         return _loc2_[_loc1_].mc;
      }
      _loc1_ = _loc1_ + 1;
   }
   return null;
};
