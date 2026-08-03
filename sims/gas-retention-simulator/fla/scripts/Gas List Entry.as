function GasListEntryClass()
{
   this.createEmptyMovieClip("fillMC",1);
   this.createEmptyMovieClip("unselectedTextMC",5);
   this.createEmptyMovieClip("selectedTextMC",6);
   this.createEmptyMovieClip("iconMC",10);
   this.createEmptyMovieClip("borderMC",15);
   var w = this._parent.entryWidth;
   var h = this._parent.entryHeight;
   this.fillMC.moveTo(0,0);
   this.fillMC.beginFill(this.fillColor,this.fillAlpha);
   this.fillMC.lineTo(w,0);
   this.fillMC.lineTo(w,h);
   this.fillMC.lineTo(0,h);
   this.fillMC.lineTo(0,0);
   this.fillMC.endFill();
   this.borderMC.lineStyle(this.borderThickness,this.borderColor,this.borderAlpha);
   this.borderMC.moveTo(0,0);
   this.borderMC.lineTo(w,0);
   this.borderMC.lineTo(w,h);
   this.borderMC.lineTo(0,h);
   this.borderMC.lineTo(0,0);
   this.setEntryInfo(this.infoObject);
   this.borderMC._visible = false;
   this.setSelectedState(false);
}
var p = GasListEntryClass.prototype = new MovieClip();
Object.registerClass("Gas List Entry",GasListEntryClass);
p.fillColor = 0;
p.fillAlpha = 10;
p.borderThickness = 1;
p.borderColor = 0;
p.borderAlpha = 50;
p.selectedTextColor = 4210752;
p.unselectedTextColor = 0;
p.setEntryInfo = function(infoObject)
{
   var nameStr = infoObject.name + " (" + infoObject.symbol + ")";
   var massStr = Math.round(infoObject.mass) + " u";
   var tf = new TextFormat("Verdana",12);
   tf.bold = false;
   tf.color = this.unselectedTextColor;
   _global.displayText(nameStr,{x:29,y:this._parent.entryHeight / 2,mc:this.unselectedTextMC,depth:100,vAlign:"center",hAlign:"left",textFormat:tf,embedFonts:true});
   _global.displayText(massStr,{x:195,y:this._parent.entryHeight / 2,mc:this.unselectedTextMC,depth:101,vAlign:"center",hAlign:"center",textFormat:tf,embedFonts:true});
   tf.bold = true;
   tf.color = this.selectedTextColor;
   _global.displayText(nameStr,{x:29,y:this._parent.entryHeight / 2,mc:this.selectedTextMC,depth:100,vAlign:"center",hAlign:"left",textFormat:tf,embedFonts:true});
   _global.displayText(massStr,{x:195,y:this._parent.entryHeight / 2,mc:this.selectedTextMC,depth:101,vAlign:"center",hAlign:"center",textFormat:tf,embedFonts:true});
   if(infoObject.percent != undefined)
   {
      this.setPercent(infoObject.percent);
   }
   if(infoObject.color != undefined)
   {
      this.iconMC.beginFill(infoObject.color);
      this.drawCircle(this.iconMC,14,this._parent.entryHeight / 2,3);
      this.iconMC.endFill();
   }
};
p.setPercent = function(arg)
{
   if(typeof arg == "number" && isFinite(arg) && !isNaN(arg) && arg >= 0 && arg <= 100)
   {
      var percentStr = arg.toFixed(1) + "%";
   }
   else
   {
      var percentStr = "--";
   }
   var tf = new TextFormat("Verdana",12);
   tf.bold = false;
   tf.color = this.unselectedTextColor;
   _global.displayText(percentStr,{x:280,y:this._parent.entryHeight / 2,mc:this.unselectedTextMC,depth:102,vAlign:"center",hAlign:"right",textFormat:tf,embedFonts:true});
   tf.bold = true;
   tf.color = this.selectedTextColor;
   _global.displayText(percentStr,{x:280,y:this._parent.entryHeight / 2,mc:this.selectedTextMC,depth:102,vAlign:"center",hAlign:"right",textFormat:tf,embedFonts:true});
};
p.tabEnabled = false;
p.useHandCursor = false;
p.onPress = function()
{
   this.listMC.setSelectedEntry(this.id,true);
};
p.onRollOver = function()
{
   this.borderMC._visible = true;
};
p.onRollOut = function()
{
   this.borderMC._visible = false;
};
p.onReleaseOutside = function()
{
   this.borderMC._visible = false;
};
p.setSelectedState = function(arg)
{
   if(arg)
   {
      this.selectedTextMC._visible = true;
      this.unselectedTextMC._visible = false;
      this.fillMC._alpha = 100;
   }
   else
   {
      this.selectedTextMC._visible = false;
      this.unselectedTextMC._visible = true;
      this.fillMC._alpha = 0;
   }
};
p.drawCircle = function(mc, x, y, r)
{
   mc.moveTo(x + r,y);
   mc.curveTo(x + r,y - 0.4142 * r,x + 0.7071 * r,y - 0.7071 * r);
   mc.curveTo(x + 0.4142 * r,y - r,x,y - r);
   mc.curveTo(x - 0.4142 * r,y - r,x - 0.7071 * r,y - 0.7071 * r);
   mc.curveTo(x - r,y - 0.4142 * r,x - r,y);
   mc.curveTo(x - r,y + 0.4142 * r,x - 0.7071 * r,y + 0.7071 * r);
   mc.curveTo(x - 0.4142 * r,y + r,x,y + r);
   mc.curveTo(x + 0.4142 * r,y + r,x + 0.7071 * r,y + 0.7071 * r);
   mc.curveTo(x + r,y + 0.4142 * r,x + r,y);
};
