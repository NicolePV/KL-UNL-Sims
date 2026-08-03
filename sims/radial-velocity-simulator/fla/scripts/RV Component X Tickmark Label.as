function RVComponentXTickmarkLabelClass()
{
   this.setLabel(this.label);
}
var p = RVComponentXTickmarkLabelClass.prototype = new MovieClip();
Object.registerClass("RV Component X Tickmark Label",RVComponentXTickmarkLabelClass);
p.setLabel = function(arg)
{
   this.labelField.text = arg;
};
