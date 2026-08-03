function DoyCursorClass()
{
   this.plot = this._parent[this.plotName];
   this._x = this.plot._x;
   this._y = this.plot._y;
}
var p = DoyCursorClass.prototype = new MovieClip();
Object.registerClass("DoyCursor",DoyCursorClass);
p.update = function()
{
   var _loc3_ = this.plot.plotWidth * (this._parent.doy - this.plot.vernalEquinoxDoy) / 365;
   var _loc2_ = (- this.plot.plotHeight) * this._parent.hours / 24;
   this.clear();
   this.lineStyle(2,16732240);
   this.drawDashedLine(0,_loc2_,_loc3_,_loc2_,2,4);
   this.drawDashedLine(_loc3_,0,_loc3_,_loc2_,2,4);
   this.dayTab._x = _loc3_;
   this.dayTab._y = 1;
   this.dayTab.dayField.text = this._parent.shortDoyString;
   this.hoursTab.hoursField.text = this._parent.hoursString;
   this.hoursTab._x = -1;
   this.hoursTab._y = _loc2_;
   this.dot._x = _loc3_;
   this.dot._y = _loc2_;
};
