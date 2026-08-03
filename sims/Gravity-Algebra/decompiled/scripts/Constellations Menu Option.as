function ConstellationsMenuOptionClass()
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
      this._parent.doToggle();
   };
   this.backgroundMC.onReleaseOutside = function()
   {
      this._alpha = 0;
   };
   this.attachMovie("Constellations Menu Checkmark","checkmark",2);
   this.textFormat = new TextFormat();
   this.textFormat.font = "Verdana";
   this.textFormat.size = 12;
   this.textFormat.color = 0;
   this.createTextField("nameField",7,0,0,0,0);
   var _loc2_ = this.nameField;
   _loc2_.setNewTextFormat(this.textFormat);
   _loc2_.autoSize = "left";
   _loc2_.embedFonts = true;
   _loc2_.selectable = false;
   _loc2_.text = this.name;
   _loc2_._x = 18;
   this.optionHeight = this.nameField._height;
   this.backgroundMC.clear();
   this.backgroundMC.moveTo(0,0);
   this.backgroundMC.beginFill(13684944);
   this.backgroundMC.lineTo(this.optionWidth,0);
   this.backgroundMC.lineTo(this.optionWidth,this.optionHeight);
   this.backgroundMC.lineTo(0,this.optionHeight);
   this.backgroundMC.lineTo(0,0);
   this.backgroundMC.endFill();
}
var p = ConstellationsMenuOptionClass.prototype = new MovieClip();
Object.registerClass("Constellations Menu Option",ConstellationsMenuOptionClass);
p.setSelected = function(arg)
{
   this.checkmark._visible = arg;
};
p.doToggle = function()
{
   this._parent._parent.onOptionToggled(this.value);
};
