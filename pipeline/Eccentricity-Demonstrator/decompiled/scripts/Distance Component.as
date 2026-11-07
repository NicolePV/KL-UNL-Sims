function DistanceComponentClass()
{
   this.colorObj = new Color(this);
   this.colorObj.setRGB(this.initColor);
   this.labelField.text = this.initLabel;
   this.setLabelPlacement(this.initLabelPlacement);
   this._distance = 90;
   this.update();
}
var p = DistanceComponentClass.prototype = new MovieClip();
Object.registerClass("Distance Component",DistanceComponentClass);
p.setDistance = function(arg)
{
   this._distance = arg;
   this.update();
};
p.setLabelPlacement = function(arg)
{
   if(arg < 0)
   {
      this.labelField._y = arg - this.labelField.textHeight;
   }
   else
   {
      this.labelField._y = arg;
   }
};
p.update = function()
{
   var mc = this;
   mc.clear();
   mc.lineStyle(1,0,100);
   var w = this._distance;
   this.labelField._x = w / 2 - this.labelField._width / 2;
   if(w == 0)
   {
      return undefined;
   }
   var x = 1.2 * Math.sqrt(w);
   var y = 0.5 * x;
   var h = 1.3 * y;
   mc.moveTo(0,0);
   mc.lineTo(w,0);
   mc.moveTo(x,y);
   mc.lineTo(0,0);
   mc.lineTo(x,- y);
   mc.moveTo(w - x,y);
   mc.lineTo(w,0);
   mc.lineTo(w - x,- y);
   mc.moveTo(0,h);
   mc.lineTo(0,- h);
   mc.moveTo(w,h);
   mc.lineTo(w,- h);
};
