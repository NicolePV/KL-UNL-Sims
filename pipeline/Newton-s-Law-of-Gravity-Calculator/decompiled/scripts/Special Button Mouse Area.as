function SpecialButtonMouseAreaClass()
{
}
var p = SpecialButtonMouseAreaClass.prototype = new MovieClip();
Object.registerClass("Special Button Mouse Area",SpecialButtonMouseAreaClass);
p.onRollOver = function()
{
   if(!this._parent.selected)
   {
      this._parent.icon.gotoAndStop(2);
   }
   this._parent.label._visible = true;
   this._parent.swapDepths(1000);
};
p.onRollOut = function()
{
   if(!this._parent.selected)
   {
      this._parent.icon.gotoAndStop(1);
   }
   this._parent.label._visible = false;
};
p.onRelease = function()
{
   this._parent.calc.onSpecialSelected(this._parent.slider,this._parent);
};
p.onReleaseOutside = function()
{
   if(!this._parent.selected)
   {
      this._parent.icon.gotoAndStop(1);
   }
   this._parent.label._visible = false;
};
