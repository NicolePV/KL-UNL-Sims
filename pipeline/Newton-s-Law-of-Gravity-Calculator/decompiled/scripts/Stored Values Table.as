function StoredValuesTableClass()
{
   this.clearAll();
   this.valuesHeadingFormat = new TextFormat("Verdana",12,0,true,true);
   this.valuesTextFormat = new TextFormat("Verdana",14,0);
   this.createEmptyMovieClip("gridMC",2);
   var _loc2_ = this.createEmptyMovieClip("rowHeadingsMC",5);
   this.createEmptyMovieClip("tableLinesMC",8);
   this.closeButton.onPress = function()
   {
      this._parent._parent.setShowStoredValues(false);
   };
}
var p = StoredValuesTableClass.prototype = new MovieClip();
Object.registerClass("Stored Values Table",StoredValuesTableClass);
p.rowSpacing = 31;
p.columnSpacing = 180;
p.maxColumns = 3;
p.x0 = 165;
p.y0 = 25;
p.setCurrentValues = function(valuesObj)
{
   this.currentValuesObj = valuesObj;
   this.refreshCurrentValues();
};
p.refreshCurrentValues = function()
{
   var _loc3_ = this.createEmptyMovieClip("currentValuesMC",16);
   var _loc2_ = this.y0;
   this.displayText("current values",{mc:_loc3_,textFormat:this.valuesHeadingFormat,embedFonts:true,vAlign:"center",hAlign:"center",x:this.currentValuesX,y:_loc2_});
   _loc2_ += this.rowSpacing;
   this.displayText(this.currentValuesObj.m1,{mc:_loc3_,textFormat:this.valuesTextFormat,embedFonts:true,vAlign:"center",hAlign:"center",x:this.currentValuesX,y:_loc2_});
   _loc2_ += this.rowSpacing;
   this.displayText(this.currentValuesObj.m2,{mc:_loc3_,textFormat:this.valuesTextFormat,embedFonts:true,vAlign:"center",hAlign:"center",x:this.currentValuesX,y:_loc2_});
   _loc2_ += this.rowSpacing;
   this.displayText(this.currentValuesObj.r,{mc:_loc3_,textFormat:this.valuesTextFormat,embedFonts:true,vAlign:"center",hAlign:"center",x:this.currentValuesX,y:_loc2_});
   _loc2_ += this.rowSpacing;
   this.displayText(this.currentValuesObj.f,{mc:_loc3_,textFormat:this.valuesTextFormat,embedFonts:true,vAlign:"center",hAlign:"center",x:this.currentValuesX,y:_loc2_});
   _loc2_ += this.rowSpacing;
   this.displayText(this.currentValuesObj.a1,{mc:_loc3_,textFormat:this.valuesTextFormat,embedFonts:true,vAlign:"center",hAlign:"center",x:this.currentValuesX,y:_loc2_});
   _loc2_ += this.rowSpacing;
   this.displayText(this.currentValuesObj.a2,{mc:_loc3_,textFormat:this.valuesTextFormat,embedFonts:true,vAlign:"center",hAlign:"center",x:this.currentValuesX,y:_loc2_});
   this.update();
};
p.store = function(valuesObj)
{
   var _loc5_ = this.valuesMC.createEmptyMovieClip("_" + this.numColumns,this.numColumns);
   var _loc3_ = this.x0 + this.numColumns * this.columnSpacing;
   var _loc2_ = this.y0;
   this.displayText("stored values #" + this.setNumber,{mc:_loc5_,textFormat:this.valuesHeadingFormat,embedFonts:true,vAlign:"center",hAlign:"center",x:_loc3_,y:_loc2_});
   _loc2_ += this.rowSpacing;
   this.displayText(valuesObj.m1,{mc:_loc5_,textFormat:this.valuesTextFormat,embedFonts:true,vAlign:"center",hAlign:"center",x:_loc3_,y:_loc2_});
   _loc2_ += this.rowSpacing;
   this.displayText(valuesObj.m2,{mc:_loc5_,textFormat:this.valuesTextFormat,embedFonts:true,vAlign:"center",hAlign:"center",x:_loc3_,y:_loc2_});
   _loc2_ += this.rowSpacing;
   this.displayText(valuesObj.r,{mc:_loc5_,textFormat:this.valuesTextFormat,embedFonts:true,vAlign:"center",hAlign:"center",x:_loc3_,y:_loc2_});
   _loc2_ += this.rowSpacing;
   this.displayText(valuesObj.f,{mc:_loc5_,textFormat:this.valuesTextFormat,embedFonts:true,vAlign:"center",hAlign:"center",x:_loc3_,y:_loc2_});
   _loc2_ += this.rowSpacing;
   this.displayText(valuesObj.a1,{mc:_loc5_,textFormat:this.valuesTextFormat,embedFonts:true,vAlign:"center",hAlign:"center",x:_loc3_,y:_loc2_});
   _loc2_ += this.rowSpacing;
   this.displayText(valuesObj.a2,{mc:_loc5_,textFormat:this.valuesTextFormat,embedFonts:true,vAlign:"center",hAlign:"center",x:_loc3_,y:_loc2_});
   this.currentValuesX = Math.max(this.currentValuesX,_loc3_ + this.columnSpacing);
   this.numColumns = (this.numColumns + 1) % this.maxColumns;
   this.setNumber = this.setNumber + 1;
   this.refreshCurrentValues();
};
p.clearAll = function()
{
   this.createEmptyMovieClip("valuesMC",10);
   this.currentValuesX = this.x0;
   this.setNumber = 1;
   this.numColumns = 0;
   this.refreshCurrentValues();
};
p.update = function()
{
   var _loc5_ = 15;
   var _loc3_ = this.y0 + this.rowSpacing / 2;
   var _loc6_ = _loc5_;
   var _loc4_ = this.currentValuesX + 0.5 * this.columnSpacing;
   this.gridMC.clear();
   this.gridMC.lineStyle(1,14211288);
   var _loc2_ = 0;
   while(_loc2_ < 6)
   {
      this.gridMC.moveTo(_loc6_,_loc3_);
      this.gridMC.lineTo(_loc4_,_loc3_);
      _loc3_ += this.rowSpacing;
      _loc2_ = _loc2_ + 1;
   }
   _loc3_ += _loc5_ / 2;
   var _loc7_ = 0;
   this.clear();
   this.moveTo(0,_loc7_);
   this.beginFill(16777200);
   this.lineStyle(1,10526880);
   this.lineTo(_loc4_ + _loc5_,_loc7_);
   this.lineTo(_loc4_ + _loc5_,_loc3_);
   this.lineTo(0,_loc3_);
   this.lineTo(0,_loc7_);
   this.endFill();
   this.closeButton._x = _loc4_;
   this.closeButton._y = _loc5_;
   this._x = this._parent.xCenter - (_loc4_ + _loc5_) / 2 - 45;
};
