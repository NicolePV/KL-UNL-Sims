function DefaultYTickmarkLabelClass()
{
   this.colorObj = new Color(this);
   this.colorObj.setRGB(this.labelColor);
   if(this.value != 0)
   {
      this.attachMovie("Simple BB Sci Not Number","_numberMC",1,{_x:-7,initValue:this.value});
      this.zeroField._visible = false;
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
