function MaxwellPlotCursorOverlayClass()
{
   this.createEmptyMovieClip("mouseAreaMC",1);
   this.createEmptyMovieClip("normalMC",2);
   this.createEmptyMovieClip("activeMC",3);
   this.isVisible = false;
   this.infoIsVisible = true;
   this._visible = false;
   this.activeMC._visible = false;
   var y = this._parent.plotMC._plotHeight + 15;
   var x1 = this.cursorNormalWidth / 2;
   var x2 = this.cursorActiveWidth / 2;
   this.mouseAreaMC.moveTo(- x2,0);
   this.mouseAreaMC.beginFill(0,0);
   this.mouseAreaMC.lineTo(x2,0);
   this.mouseAreaMC.lineTo(x2,y);
   this.mouseAreaMC.lineTo(- x2,y);
   this.mouseAreaMC.lineTo(- x2,0);
   this.mouseAreaMC.endFill();
   this.normalMC.moveTo(- x1,0);
   this.normalMC.beginFill(this.cursorNormalColor);
   this.normalMC.lineTo(x1,0);
   this.normalMC.lineTo(x1,y);
   this.normalMC.lineTo(- x1,y);
   this.normalMC.lineTo(- x1,0);
   this.normalMC.endFill();
   this.activeMC.moveTo(- x2,0);
   this.activeMC.beginFill(this.cursorActiveColor);
   this.activeMC.lineTo(x2,0);
   this.activeMC.lineTo(x2,y);
   this.activeMC.lineTo(- x2,y);
   this.activeMC.lineTo(- x2,0);
   this.activeMC.endFill();
   this.mouseAreaMC.useHandCursor = false;
   this.mouseAreaMC.tabEnabled = false;
   this.mouseAreaMC.onRollOver = function()
   {
      this._parent.activeMC._visible = true;
      this._parent.normalMC._visible = false;
   };
   this.mouseAreaMC.onRollOut = function()
   {
      this._parent.activeMC._visible = false;
      this._parent.normalMC._visible = true;
   };
   this.mouseAreaMC.onPress = function()
   {
      this.xOffset = this._parent._parent._xmouse - this._parent._x;
      this.onMouseMove = this.onMouseMoveFunc;
   };
   this.mouseAreaMC.onMouseMoveFunc = function()
   {
      var plotX = this._parent._parent.plotMC._x;
      var plotWidth = this._parent._parent.plotMC._plotWidth;
      var newX = this._parent._parent._xmouse - this.xOffset;
      if(newX < plotX)
      {
         newX = plotX;
      }
      else if(newX > plotX + plotWidth)
      {
         newX = plotX + plotWidth;
      }
      this._parent._x = newX;
      this._parent.update();
      updateAfterEvent();
   };
   this.mouseAreaMC.onRelease = function()
   {
      delete this.onMouseMove;
   };
   this.mouseAreaMC.onReleaseOutside = function()
   {
      this._parent.activeMC._visible = false;
      this._parent.normalMC._visible = true;
      delete this.onMouseMove;
   };
   this._y = this._parent.plotMC._y - this._parent.plotMC._plotHeight;
   this._x = this._parent.plotMC._x + this._parent.plotMC._plotWidth / 2;
}
var p = MaxwellPlotCursorOverlayClass.prototype = new MovieClip();
Object.registerClass("Maxwell Plot Cursor Overlay",MaxwellPlotCursorOverlayClass);
p.cursorNormalColor = 15634576;
p.cursorNormalWidth = 3;
p.cursorActiveColor = 16732240;
p.cursorActiveWidth = 4;
p.textX = 5;
p.textY = 1;
p.getCDF = function(a, x)
{
   return Math.erf(x / (a * 1.4142135623730951)) - 0.7978845608028654 * x * Math.exp((- x) * x / (2 * a * a)) / a;
};
p.update = function()
{
   this.leftBackgroundMC.removeMovieClip();
   this.rightBackgroundMC.removeMovieClip();
   this.leftValueTextField.removeTextField();
   this.rightValueTextField.removeTextField();
   this.speedTextField.removeTextField();
   var v = this._parent.plotMC._xMin + (this._x - this._parent.plotMC._x) / this._parent.plotMC.__xScale;
   var tf = new TextFormat("Verdana",11);
   tf.align = "center";
   this.createTextField("speedTextField",100,0,this._parent.plotMC._plotHeight + 8,0,0);
   this.speedTextField.background = true;
   this.speedTextField.border = true;
   this.speedTextField.borderColor = this.cursorNormalColor;
   this.speedTextField.autoSize = "center";
   this.speedTextField.embedFonts = true;
   this.speedTextField.selectable = false;
   this.speedTextField.setNewTextFormat(tf);
   this.speedTextField.text = Math.round(v) + " m/s";
   this.leftExtraTextField._visible = this.infoIsVisible;
   this.leftSymbolMC._visible = this.infoIsVisible;
   this.rightExtraTextField._visible = this.infoIsVisible;
   this.rightSymbolMC._visible = this.infoIsVisible;
   if(!this.infoIsVisible || typeof this.selectedGas != "string")
   {
      return undefined;
   }
   var kT = this._parent.temperatureSlider.value * 1.3806503e-23;
   var a = Math.sqrt(kT / (1.66053886e-27 * this._parent.gassesList[this.selectedGas].mass));
   var cdf = this.getCDF(a,v);
   if(cdf == 0)
   {
      var leftStr = "0.0%";
      var rightStr = "100.0%";
   }
   else
   {
      var cdfPercent = (cdf * 100).toFixed(1);
      var num = parseFloat(cdfPercent);
      if(num == 0)
      {
         leftStr = "<0.1%";
         rightStr = ">99.9%";
      }
      else if(num == 100)
      {
         leftStr = ">99.9%";
         rightStr = "<0.1%";
      }
      else
      {
         leftStr = cdfPercent + "%";
         rightStr = (100 - num).toFixed(1) + "%";
      }
   }
   this.createTextField("leftValueTextField",200,- this.textX,this.textY,0,0);
   this.leftValueTextField.autoSize = "right";
   this.leftValueTextField.embedFonts = true;
   this.leftValueTextField.selectable = false;
   this.leftValueTextField.setNewTextFormat(tf);
   this.leftValueTextField.text = leftStr;
   this.createTextField("rightValueTextField",300,this.textX,this.textY,0,0);
   this.rightValueTextField.autoSize = "left";
   this.rightValueTextField.embedFonts = true;
   this.rightValueTextField.selectable = false;
   this.rightValueTextField.setNewTextFormat(tf);
   this.rightValueTextField.text = rightStr;
   var leftWidth = Math.max(this.leftValueTextField._width,this.leftExtraTextField._width);
   var leftHeight = this.leftExtraTextField._y - this.textY + this.leftExtraTextField._height;
   this.createEmptyMovieClip("leftBackgroundMC",150);
   this.leftBackgroundMC.moveTo(- this.textX,this.textY);
   this.leftBackgroundMC.beginFill(16777215,85);
   this.leftBackgroundMC.lineTo(- this.textX - leftWidth,this.textY);
   this.leftBackgroundMC.lineTo(- this.textX - leftWidth,this.textY + leftHeight);
   this.leftBackgroundMC.lineTo(- this.textX,this.textY + leftHeight);
   this.leftBackgroundMC.lineTo(- this.textX,this.textY);
   this.leftBackgroundMC.endFill();
   var rightWidth = Math.max(this.rightValueTextField._width,this.rightExtraTextField._width);
   var rightHeight = this.rightExtraTextField._y - this.textY + this.rightExtraTextField._height;
   this.createEmptyMovieClip("rightBackgroundMC",151);
   this.rightBackgroundMC.moveTo(this.textX,this.textY);
   this.rightBackgroundMC.beginFill(16777215,85);
   this.rightBackgroundMC.lineTo(this.textX + rightWidth,this.textY);
   this.rightBackgroundMC.lineTo(this.textX + rightWidth,this.textY + rightHeight);
   this.rightBackgroundMC.lineTo(this.textX,this.textY + rightHeight);
   this.rightBackgroundMC.lineTo(this.textX,this.textY);
   this.rightBackgroundMC.endFill();
};
p.setSelectedGas = function(id)
{
   var startTimer = getTimer();
   this.selectedGas = id;
   this.leftExtraTextField.removeTextField();
   this.leftSymbolMC.removeMovieClip();
   this.rightExtraTextField.removeTextField();
   this.rightSymbolMC.removeMovieClip();
   if(this.selectedGas != null)
   {
      var tf = new TextFormat("Verdana",10);
      tf.color = 0;
      tf.align = "left";
      this.createTextField("rightExtraTextField",301,this.textX,this.textY + 15,0,0);
      this.rightExtraTextField.autoSize = "left";
      this.rightExtraTextField.embedFonts = true;
      this.rightExtraTextField.selectable = false;
      this.rightExtraTextField.setNewTextFormat(tf);
      this.rightExtraTextField.text = "of\n\nmoves\nfaster";
      _global.displayText(this._parent.gassesList[this.selectedGas].symbol,{x:this.textX + 2,y:this.textY + 30,sizeRatio:1.3,vAlign:"top",hAlign:"left",mc:this,name:"rightSymbolMC",depth:302,textFormat:tf,embedFonts:true});
      tf.align = "right";
      this.createTextField("leftExtraTextField",201,- this.textX,this.textY + 15,0,0);
      this.leftExtraTextField.autoSize = "right";
      this.leftExtraTextField.embedFonts = true;
      this.leftExtraTextField.selectable = false;
      this.leftExtraTextField.setNewTextFormat(tf);
      this.leftExtraTextField.text = "of\n\nmoves\nslower";
      _global.displayText(this._parent.gassesList[this.selectedGas].symbol,{x:- (this.textX + 2),y:this.textY + 30,sizeRatio:1.3,vAlign:"top",hAlign:"right",mc:this,name:"leftSymbolMC",depth:202,textFormat:tf,embedFonts:true});
   }
   this.update();
};
p.setInfoVisible = function(arg)
{
   this.infoIsVisible = arg;
   this.update();
};
p.setVisible = function(arg)
{
   this.isVisible = arg;
   this._visible = arg;
};
p.formatNumber = function(num, digits)
{
   var L = Math.floor(Math.log(num) / 2.302585092994046) - (digits - 1);
   if(L >= 0)
   {
      var M = Math.pow(10,L);
      return String(M * Math.round(num / M));
   }
   return num.toFixed(- L);
};
