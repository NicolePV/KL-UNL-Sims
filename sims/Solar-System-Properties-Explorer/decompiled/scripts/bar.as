function barClass()
{
   this.myBar.myOutline.createEmptyMovieClip("myLine",2);
   this.barColor = new Color(this.myBar.myColor);
   this.value._visible = false;
   this.value._x = this.myBar._width / 2 - this.value._width / 2;
   this.value._y = - (this.myBar._height + this.value._height);
}
var p = barClass.prototype = new MovieClip();
Object.registerClass("bar",barClass);
p.onEnterFrame = function()
{
};
p.setColor = function(col)
{
   this.barColor.setRGB(col);
};
p.changeHeight = function(val, newH)
{
   this.myBar.myColor._height = newH;
   this.myBar.myBack._height = newH;
   this.myBar.myOutline.myLine.clear();
   this.myBar.myOutline.myLine.lineStyle(2,3355443,100);
   this.myBar.myOutline.myLine.lineTo(0,- newH);
   this.myBar.myOutline.myLine.lineTo(this.myBar.myColor._width,- newH);
   this.myBar.myOutline.myLine.lineTo(this.myBar.myColor._width,0);
   this.myBar.myOutline.myLine.lineTo(0,0);
   this.value._x = this.myBar._width / 2 - this.value._width / 2;
   this.value._y = - (this.myBar._height + this.value._height);
   this.value.text = val;
};
