function SliderV5DefaultBarClass()
{
   this.barWidth = 140.8;
}
var p = SliderV5DefaultBarClass.prototype = new MovieClip();
Object.registerClass("sliderV5DefaultBar",SliderV5DefaultBarClass);
p.updateBar = function()
{
};
