function GenericTabClass()
{
   this.labelField.text = this.name;
}
var p = GenericTabClass.prototype = new MovieClip();
Object.registerClass("Generic Tab",GenericTabClass);
p.useHandCursor = false;
p.onPress = function()
{
   this._parent.bringToFront(this);
};
