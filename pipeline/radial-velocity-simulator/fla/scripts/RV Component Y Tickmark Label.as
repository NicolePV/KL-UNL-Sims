function RVComponentYTickmarkLabelClass()
{
   this.setValue(this.value);
}
var p = RVComponentYTickmarkLabelClass.prototype = new MovieClip();
Object.registerClass("RV Component Y Tickmark Label",RVComponentYTickmarkLabelClass);
p.setValue = function(arg)
{
   this.labelField.text = arg;
};
