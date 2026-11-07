namesList = ["leo","cancer","gemini","taurus","aries","pisces","aquarius","capricornus","sagittarius","scorpius","libra","virgo"];
var i = 0;
while(i < namesList.length)
{
   var mc = this[namesList[i] + "AreaMC"];
   mc.useHandCursor = false;
   mc.tabEnabled = false;
   mc.zodiacStripMC = this._parent._parent._parent;
   mc.name = namesList[i];
   mc.onRollOver = function()
   {
      this.zodiacStripMC.showConstellationName(this.name);
   };
   mc.onRollOut = function()
   {
      this.zodiacStripMC.hideConstellationName(this.name);
   };
   mc.onPress = function()
   {
      this.initX = this.zodiacStripMC.backgroundMC._xmouse;
      this.initOffset = this.zodiacStripMC.offset;
      this.onMouseMove = this.onMouseMoveFunc;
   };
   mc.onMouseMoveFunc = function()
   {
      this.zodiacStripMC.setOffset(this.initOffset + this.zodiacStripMC.backgroundMC._xmouse - this.initX);
      updateAfterEvent();
   };
   mc.onRelease = function()
   {
      delete this.onMouseMove;
   };
   mc.onReleaseOutside = function()
   {
      delete this.onMouseMove;
      this.zodiacStripMC.hideConstellationName(this.name);
   };
   i++;
}
