function PanelShellClass()
{
   this.topDepth = 1;
   this.newDepth = 0;
}
var p = PanelShellClass.prototype = new MovieClip();
Object.registerClass("Panel Shell",PanelShellClass);
p.margin = 10;
p.addPanel = function(linkageID, title, x, y, isDraggable)
{
   var _loc2_ = this.createEmptyMovieClip("_" + this.newDepth,this.newDepth);
   _loc2_._x = x;
   _loc2_._y = y;
   this.topDepth = this.topDepth + 1;
   this.newDepth = this.newDepth + 1;
   _loc2_.isDraggable = isDraggable;
   var _loc3_ = _loc2_.attachMovie(linkageID,"contentMC",1,{masterMC:this._parent});
   _loc2_.xMin = this.margin;
   _loc2_.xMax = Stage.width - (_loc3_._width + this.margin);
   _loc2_.yMin = this.margin;
   _loc2_.yMax = Stage.height - this.margin;
   return _loc3_;
};
