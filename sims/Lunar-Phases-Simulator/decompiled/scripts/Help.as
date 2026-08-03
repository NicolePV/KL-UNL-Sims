function HelpPanelClass()
{
   this.createEmptyMovieClip("backgroundMC",1);
}
var p = HelpPanelClass.prototype = new MovieClip();
Object.registerClass("Help",HelpPanelClass);
p.panelWidth = 575;
p.panelMargin = 10;
p.setText = function(arg)
{
   if(this.helpText != undefined)
   {
      this.helpText.removeTextField();
   }
   this.createTextField("helpText",2,this.panelMargin,this.panelMargin,this.panelWidth - 2 * this.panelMargin,1000);
   this.helpText.embedFonts = true;
   this.helpText.selectable = false;
   this.helpText.html = true;
   this.helpText.multiline = true;
   this.helpText.wordWrap = true;
   this.helpText.autoSize = "left";
   this.helpText.htmlText = "<FONT FACE=\"Verdana\" SIZE=\"12\">" + arg + "</FONT>";
   this.panelHeight = this.helpText._height + 2.3 * this.panelMargin;
   this.backgroundMC.clear();
   this.backgroundMC.moveTo(0,0);
   this.backgroundMC.beginFill(16448250);
   this.backgroundMC.lineTo(this.panelWidth,0);
   this.backgroundMC.lineTo(this.panelWidth,this.panelHeight);
   this.backgroundMC.lineTo(0,this.panelHeight);
   this.backgroundMC.lineTo(0,0);
   this.backgroundMC.endFill();
   this._parent.recenter();
};
