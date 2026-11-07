function LCIIComponentXTickmarkLabelClass()
{
   this.setLabel(this.label);
}
var p = LCIIComponentXTickmarkLabelClass.prototype = new MovieClip();
Object.registerClass("LCII Component X Tickmark Label",LCIIComponentXTickmarkLabelClass);
p.setLabel = function(arg)
{
   this.labelField.text = arg;
};
