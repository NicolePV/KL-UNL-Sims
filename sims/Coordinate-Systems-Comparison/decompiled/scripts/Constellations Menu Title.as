function ConstellationsMenuTitleClass()
{
   this.stop();
}
var p = ConstellationsMenuTitleClass.prototype = new MovieClip();
Object.registerClass("Constellations Menu Title",ConstellationsMenuTitleClass);
p.onPress = function()
{
   this._parent.setShowDepressedButton(true);
};
p.onRollOver = function()
{
   this._parent.setShowNormalBorder(false);
};
p.onRelease = function()
{
   this._parent.toggleState();
   this._parent.setShowDepressedButton(false);
};
p.onRollOut = function()
{
   this._parent.setShowNormalBorder(true);
};
p.onReleaseOutside = function()
{
   this._parent.setShowNormalBorder(true);
   this._parent.setShowDepressedButton(false);
};
