function TimelineEventItemClass()
{
   this.createEmptyMovieClip("clickableAreaMC",1);
   this.createEmptyMovieClip("backgroundMC",5);
   this.createTextField("eventNameField",10,this.xShift,0,0,0);
   this.backgroundMC._visible = false;
   this.clickableAreaMC.tabEnabled = false;
   this.clickableAreaMC.onPressFunc = function()
   {
      this._parent._parent.onEventClicked(this._parent.eventNumber);
   };
   this.clickableAreaMC.onPress = this.clickableAreaMC.onPressFunc;
   this.selectedTextFormat = new TextFormat("Verdana",10,16711680,false);
   this.unselectedTextFormat = new TextFormat("Verdana",10,0,false);
   this.eventNameField.selectable = false;
   this.eventNameField.autoSize = "left";
   this.eventNameField.setNewTextFormat(this.unselectedTextFormat);
   this.eventNameField.embedFonts = true;
}
var p = TimelineEventItemClass.prototype = new MovieClip();
Object.registerClass("Timeline Event Item",TimelineEventItemClass);
p.xShift = 10;
p.setEventName = function(arg)
{
   this.eventNameField.text = arg;
   this.eventNameField._y = -2 - this.eventNameField._height / 2;
   var x = this.eventNameField.textWidth;
   var y = this.eventNameField.textHeight / 2;
   var mc = this.clickableAreaMC;
   mc.clear();
   mc.moveTo(this.xShift + 2,- y);
   mc.beginFill(16711680,0);
   mc.lineTo(this.xShift + x + 2,- y);
   mc.lineTo(this.xShift + x + 2,y);
   mc.lineTo(this.xShift + 2,y);
   mc.lineTo(this.xShift + 2,- y);
   mc.endFill();
   var mc = this.backgroundMC;
   mc.clear();
   mc.lineStyle(1,16765136,50);
   mc.moveTo(this.xShift - 1,- y - 3);
   mc.beginFill(16777215,100);
   mc.lineTo(this.xShift + x + 5,- y - 3);
   mc.lineTo(this.xShift + x + 5,y + 1);
   mc.lineTo(this.xShift - 1,y + 1);
   mc.lineTo(this.xShift - 1,- y - 3);
   mc.endFill();
};
p.setSelected = function(arg)
{
   if(arg)
   {
      this.eventNameField.setTextFormat(this.selectedTextFormat);
      this.eventNameField.setNewTextFormat(this.selectedTextFormat);
      delete this.clickableAreaMC.onPress;
      this.backgroundMC._visible = true;
   }
   else
   {
      this.eventNameField.setTextFormat(this.unselectedTextFormat);
      this.eventNameField.setNewTextFormat(this.unselectedTextFormat);
      this.clickableAreaMC.onPress = this.clickableAreaMC.onPressFunc;
      this.backgroundMC._visible = false;
   }
};
