function ProportionsAdjusterClass()
{
   this.enabled = true;
   this.createEmptyMovieClip("backgroundMC",0);
   this.createEmptyMovieClip("borderMC",5);
   var w = this.barSpacing + this._parent.gasLimit * (this.barWidth + this.barSpacing);
   var h = this.barSpacing + this.maxBarHeight;
   var x = w / 2;
   var y = - h;
   this.backgroundMC.moveTo(- x,0);
   this.backgroundMC.beginFill(this.backgroundColor);
   this.backgroundMC.lineTo(x,0);
   this.backgroundMC.lineTo(x,y);
   this.backgroundMC.lineTo(- x,y);
   this.backgroundMC.lineTo(- x,0);
   this.backgroundMC.endFill();
   this.borderMC.lineStyle(this.borderThickness,this.borderColor);
   this.borderMC.moveTo(- x,0);
   this.borderMC.lineTo(x,0);
   this.borderMC.lineTo(x,y);
   this.borderMC.lineTo(- x,y);
   this.borderMC.lineTo(- x,0);
   this.removeAllBars();
}
var p = ProportionsAdjusterClass.prototype = new MovieClip();
Object.registerClass("Proportions Adjuster",ProportionsAdjusterClass);
p.barWidth = 20;
p.barSpacing = 13;
p.maxBarHeight = 100;
p.backgroundColor = 16777215;
p.borderThickness = 1;
p.borderColor = 12632256;
p.setSelectedBar = function(name, callChangeHandler)
{
   this.selectedBar = name;
   var i = 0;
   while(i < this.barsList.length)
   {
      if(this.barsList[i].name == name)
      {
         this.barsList[i].inSelectedState = true;
      }
      else
      {
         this.barsList[i].inSelectedState = false;
      }
      i++;
   }
   if(callChangeHandler)
   {
      this._parent[this.selectionChangeHandler](this.selectedBar);
   }
   this.update();
};
p.update = function()
{
   var i = 0;
   while(i < this.barsList.length)
   {
      this.barsList[i].update();
      i++;
   }
};
p.removeAllBars = function()
{
   var i = 0;
   while(i < this.barsList.length)
   {
      delete this[this.barsList[i].name];
      i++;
   }
   this.createEmptyMovieClip("barsMC",1);
   this.createEmptyMovieClip("labelsMC",2);
   this.barsList = [];
   this.nextFreeDepth = 1;
};
p.addBar = function(name, initObj)
{
   var depth = this.nextFreeDepth++;
   var mc = this.barsMC.createEmptyMovieClip("_" + depth,depth);
   if(initObj.fraction != undefined)
   {
      mc.fraction = initObj.fraction;
   }
   else
   {
      mc.fraction = 1;
   }
   if(initObj.symbol != undefined)
   {
      mc.symbol = initObj.symbol;
   }
   else
   {
      mc.symbol = "";
   }
   if(initObj.fillColor != undefined)
   {
      mc.fillColor = initObj.fillColor;
   }
   else
   {
      mc.fillColor = 16711680;
   }
   if(initObj.outlineColor != undefined)
   {
      mc.outlineColor = initObj.outlineColor;
   }
   else
   {
      mc.outlineColor = 16711680;
   }
   if(initObj.unselectedFillAlpha != undefined)
   {
      mc.unselectedFillAlpha = initObj.unselectedFillAlpha;
   }
   else
   {
      mc.unselectedFillAlpha = 40;
   }
   if(initObj.selectedFillAlpha != undefined)
   {
      mc.selectedFillAlpha = initObj.selectedFillAlpha;
   }
   else
   {
      mc.selectedFillAlpha = 70;
   }
   if(initObj.unselectedTextColor != undefined)
   {
      mc.unselectedTextColor = initObj.unselectedTextColor;
   }
   else
   {
      mc.unselectedTextColor = 0;
   }
   if(initObj.selectedTextColor != undefined)
   {
      mc.selectedTextColor = initObj.selectedTextColor;
   }
   else
   {
      mc.selectedTextColor = 4210752;
   }
   var tf = new TextFormat("Verdana",12);
   tf.bold = false;
   tf.color = mc.unselectedTextColor;
   mc.unselectedLabelMC = _global.displayText(mc.symbol,{y:4,vAlign:"top",hAlign:"center",mc:this.labelsMC,depth:2 * depth,textFormat:tf,embedFonts:true});
   tf.bold = true;
   tf.color = mc.selectedTextColor;
   mc.selectedLabelMC = _global.displayText(mc.symbol,{y:4,vAlign:"top",hAlign:"center",mc:this.labelsMC,depth:2 * depth + 1,textFormat:tf,embedFonts:true});
   mc.selectedLabelMC._visible = false;
   mc.inMouseOverState = false;
   mc.inSelectedState = false;
   mc.attachMovie("PA Arrows","arrowsMC",1);
   mc.arrowsColorObject = new Color(mc.arrowsMC);
   mc.arrowsColorObject.setRGB(mc.fillColor);
   mc.useHandCursor = false;
   mc.tabEnabled = false;
   mc.remove = this.barRemoveFunc;
   mc.update = this.barUpdateFunc;
   mc.onPress = this.barOnPressFunc;
   mc.onRelease = this.barOnReleaseFunc;
   mc.onReleaseOutside = this.barOnReleaseOutsideFunc;
   mc.onMouseMoveFunc = this.barOnMouseMoveFunc;
   mc.onRollOver = this.barOnRollOverFunc;
   mc.onRollOut = this.barOnRollOutFunc;
   mc.name = name;
   this[name] = mc;
   this.barsList.push(mc);
};
p.getBarNumberFromName = function(name)
{
   var i = 0;
   while(i < this.barsList.length)
   {
      if(this.barsList[i].name == name)
      {
         return i;
      }
      i++;
   }
   return null;
};
p.barOnPressFunc = function()
{
   if(this._parent._parent.enabled)
   {
      this.initY = this._ymouse;
      this.initFraction = this.fraction;
      this.onMouseMove = this.onMouseMoveFunc;
   }
   this._parent._parent.setSelectedBar(this.name,true);
};
p.barOnRollOutFunc = function()
{
   this.inMouseOverState = false;
   this.update();
};
p.barOnRollOverFunc = function()
{
   if(this._parent._parent.enabled)
   {
      this.inMouseOverState = true;
      this.update();
   }
};
p.barOnReleaseFunc = function()
{
   delete this.onMouseMove;
};
p.barOnReleaseOutsideFunc = function()
{
   delete this.onMouseMove;
   this.inMouseOverState = false;
   this.update();
};
p.barOnMouseMoveFunc = function()
{
   var newFraction = this.initFraction - (this._ymouse - this.initY) / this._parent._parent.maxBarHeight;
   if(newFraction < 0)
   {
      newFraction = 0;
   }
   else if(newFraction > 1)
   {
      newFraction = 1;
   }
   this.fraction = newFraction;
   this.update();
   this._parent._parent._parent[this._parent._parent.proportionsChangeHandler](this.name,this.fraction);
   updateAfterEvent();
};
p.barRemoveFunc = function()
{
   this.selectedLabelMC.removeMovieClip();
   this.unselectedLabelMC.removeMovieClip();
   var i = this._parent._parent.getBarNumberFromName(this.name);
   this._parent._parent.barsList.splice(i,1);
   this.removeMovieClip();
   delete this._parent._parent[this.name];
};
p.barUpdateFunc = function()
{
   var p = this._parent._parent;
   var xOffset = (p.barsList.length * (p.barWidth + p.barSpacing) - p.barSpacing) / 2;
   var x1 = p.getBarNumberFromName(this.name) * (p.barWidth + p.barSpacing) - xOffset;
   var x2 = x1 + p.barWidth;
   var midX = x1 + (x2 - x1) / 2;
   var y = (- this.fraction) * p.maxBarHeight;
   this.selectedLabelMC._x = midX;
   this.unselectedLabelMC._x = midX;
   this.selectedLabelMC._visible = this.inSelectedState;
   this.unselectedLabelMC._visible = !this.inSelectedState;
   this.clear();
   var excess = 2;
   this.moveTo(x1 - excess,y - excess);
   this.beginFill(267386880,0);
   this.lineTo(x2 + excess,y - excess);
   this.lineTo(x2 + excess,y + excess);
   this.lineTo(x1 - excess,y + excess);
   this.lineTo(x1 - excess,y - excess);
   this.endFill();
   if(this.inMouseOverState)
   {
      this.arrowsMC.upMC._visible = this.fraction < 1;
      this.arrowsMC.downMC._visible = this.fraction > 0;
      this.arrowsMC._visible = true;
      this.arrowsMC._x = midX;
      this.arrowsMC._y = y;
      this.lineStyle(1,this.outlineColor,100);
   }
   else
   {
      this.arrowsMC._visible = false;
      this.lineStyle(1,this.outlineColor,50);
   }
   if(this.inSelectedState)
   {
      this.moveTo(x1,0);
      this.beginFill(this.fillColor,this.selectedFillAlpha);
      this.lineTo(x2,0);
      this.lineTo(x2,y);
      this.lineTo(x1,y);
      this.lineTo(x1,0);
      this.endFill();
   }
   else
   {
      this.moveTo(x1,0);
      this.beginFill(this.fillColor,this.unselectedFillAlpha);
      this.lineTo(x2,0);
      this.lineTo(x2,y);
      this.lineTo(x1,y);
      this.lineTo(x1,0);
      this.endFill();
   }
};
