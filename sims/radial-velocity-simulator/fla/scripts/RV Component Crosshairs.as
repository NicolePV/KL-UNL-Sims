function RVComponentCrosshairsClass()
{
   this.createTextField("outputField",10,0,-32,0,0);
   this.outputField._width = 0;
   this.outputField.autoSize = "center";
   this.outputField.background = true;
   this.outputField.border = true;
   this.outputField.borderColor = 9474192;
   this.outputField.embedFonts = true;
   var tf = new TextFormat("Verdana",10);
   tf.align = "center";
   this.outputField.setNewTextFormat(tf);
}
var p = RVComponentCrosshairsClass.prototype = new MovieClip();
Object.registerClass("RV Component Crosshairs",RVComponentCrosshairsClass);
p.update = function()
{
   var newX = this._parent._xmouse;
   var newY = this._parent._ymouse;
   if(newX < 0)
   {
      newX = 0;
   }
   else if(newX > this._parent.plotWidth)
   {
      newX = this._parent.plotWidth;
   }
   if(newY < 0)
   {
      newY = 0;
   }
   else if(newY > this._parent.plotHeight)
   {
      newY = this._parent.plotHeight;
   }
   this._parent.crosshairsMC._x = newX;
   this._parent.crosshairsMC._y = newY;
   var velocity = this._parent.yAxisMax + newY / this._parent.yScale;
   var k = - Math.floor(Math.log(1 / this._parent.plotWidth * (this._parent.yAxisMax - this._parent.yAxisMin)) / 2.302585092994046);
   if(k <= 0)
   {
      var f = Math.pow(10,- k);
      var velocityString = String(f * Math.round(velocity / f));
   }
   else
   {
      var velocityString = velocity.toFixed(k);
   }
   this.outputField.text = velocityString + " m/s";
};
