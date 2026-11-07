function DefaultYTickmarkLabelClass()
{
   var _loc1_ = this;
   _loc1_.colorObj = new Color(_loc1_);
   _loc1_.colorObj.setRGB(_loc1_.labelColor);
   if(_loc1_.value != 0)
   {
      _loc1_.attachMovie("Simple BB Sci Not Number","_numberMC",1,{_x:-7,initValue:_loc1_.value});
      _loc1_.zeroField._visible = false;
   }
}
var p = DefaultYTickmarkLabelClass.prototype = new MovieClip();
Object.registerClass("Default Y Tickmark Label",DefaultYTickmarkLabelClass);
p.setValue = function(arg)
{
   this._numberMC.setValue(arg);
};
p.setLabelColor = function(arg)
{
   this.colorObj.setRGB(arg);
};
