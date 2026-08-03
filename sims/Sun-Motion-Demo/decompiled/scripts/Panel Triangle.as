function PanelTriangleClass()
{
}
var p = PanelTriangleClass.prototype = new MovieClip();
Object.registerClass("Panel Triangle",PanelTriangleClass);
p.useHandCursor = false;
p.onPress = function()
{
   this._parent.swapDepths(this._parent._parent.topDepth++);
};
p.onRelease = function()
{
   this._parent.backgroundMC._visible = this._parent.contentMC._visible = !this._parent.contentMC._visible;
   if(!this._parent.contentMC._visible)
   {
      this._rotation = -90;
   }
   else
   {
      this._rotation = 0;
   }
};
