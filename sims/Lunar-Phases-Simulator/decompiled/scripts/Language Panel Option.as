function LanguagePanelOptionClass()
{
   this.createEmptyMovieClip("backgroundMC",1);
   this.backgroundMC._alpha = 0;
   this.backgroundMC.onRollOver = function()
   {
      this._alpha = 100;
   };
   this.backgroundMC.onRollOut = function()
   {
      this._alpha = 0;
   };
   this.backgroundMC.onRelease = function()
   {
      this._parent._parent._parent._parent.onLanguageSelectedViaPanel(this._parent.option);
   };
   this.backgroundMC.onReleaseOutside = function()
   {
      this._alpha = 0;
   };
   this.attachMovie("Language Panel Checkmark","checkmark",2);
   this.createTextField("nameField",7,0,0,0,0);
   var _loc2_ = this.nameField;
   _loc2_.setNewTextFormat(this.textFormat);
   _loc2_.autoSize = "left";
   _loc2_.embedFonts = true;
   _loc2_.selectable = false;
   _loc2_.text = this.option.langName;
   this.checkmark._x = - this.checkmark._width;
   this.leftExtent = this.checkmark._x;
   this.rightExtent = _loc2_._width;
   this.backgroundLeft = 0;
   this.backgroundRight = 0;
}
var p = LanguagePanelOptionClass.prototype = new MovieClip();
Object.registerClass("Language Panel Option",LanguagePanelOptionClass);
p.drawBackground = function()
{
   this.backgroundMC.clear();
   this.backgroundMC.moveTo(this.backgroundLeft,0);
   this.backgroundMC.beginFill(13684944);
   this.backgroundMC.lineTo(this.backgroundRight,0);
   this.backgroundMC.lineTo(this.backgroundRight,this.nameField._height);
   this.backgroundMC.lineTo(this.backgroundLeft,this.nameField._height);
   this.backgroundMC.lineTo(this.backgroundLeft,0);
   this.backgroundMC.endFill();
};
