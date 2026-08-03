function LCIIComponentYTickmarkLabelClass()
{
   this.setValue(this.value);
}
var p = LCIIComponentYTickmarkLabelClass.prototype = new MovieClip();
Object.registerClass("LCII Component Y Tickmark Label",LCIIComponentYTickmarkLabelClass);
p.setValue = function(arg)
{
   this.labelField.text = arg;
};
