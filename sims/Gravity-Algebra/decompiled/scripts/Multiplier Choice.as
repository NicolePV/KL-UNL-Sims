function MultiplierChoiceClass()
{
   this.attachMovie(this.def.link,"iconMC",1);
   this.iconMC.gotoAndStop(2);
   this.gotoAndStop(1);
}
var p = MultiplierChoiceClass.prototype = new MovieClip();
Object.registerClass("Multiplier Choice",MultiplierChoiceClass);
p.setSelected = function(arg)
{
   if(arg)
   {
      this.iconMC.gotoAndStop(1);
   }
   else
   {
      this.iconMC.gotoAndStop(2);
   }
   this.gotoAndStop(1);
};
p.onPress = function()
{
   if(!this._parent._parent.getExpanded())
   {
      delete this.onRelease;
      this._parent._parent.setExpanded(true);
   }
   else
   {
      this.onRelease = this.onReleaseFunc;
   }
};
p.onMouseMove = function()
{
   if(this.hitTest(_root._xmouse,_root._ymouse,true))
   {
      this.gotoAndStop(2);
   }
   else
   {
      this.gotoAndStop(1);
   }
};
p.setActive = function(arg)
{
   if(arg)
   {
      this.onMouseMove = this.onMouseMoveFunc;
      this.onMouseMove();
   }
   else
   {
      delete this.onMouseMove;
   }
};
p.onReleaseFunc = function()
{
   this._parent._parent.setSelected(this.def.index);
};
