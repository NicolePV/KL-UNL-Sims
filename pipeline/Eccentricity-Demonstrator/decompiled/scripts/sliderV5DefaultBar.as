function SliderV5DefaultBarClass()
{
   this.barWidth = 100;
}
var p = SliderV5DefaultBarClass.prototype = new MovieClip();
Object.registerClass("sliderV5DefaultBar",SliderV5DefaultBarClass);
p.updateBar = function()
{
   this.leftShadingMC._x = this.sliderMC.getPositionFromValue(this.sliderMC._rangeMin) - this.leftShadingMC._width - this._x;
   this.rightShadingMC._x = this.sliderMC.getPositionFromValue(this.sliderMC._rangeMax) - this._x;
};
