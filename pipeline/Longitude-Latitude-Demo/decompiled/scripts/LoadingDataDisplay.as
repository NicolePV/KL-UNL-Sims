function LoadingDataDisplayClass()
{
   this.createEmptyMovieClip("barFillMC",1);
   var mc = this.createEmptyMovieClip("barBorderMC",2);
   var hw = this.barWidth / 2;
   mc.clear();
   mc.lineStyle(this.lineThickness,this.lineColor,100);
   mc.moveTo(- hw,0);
   mc.lineTo(hw,0);
   mc.lineTo(hw,this.barHeight);
   mc.lineTo(- hw,this.barHeight);
   mc.lineTo(- hw,0);
}
var p = LoadingDataDisplayClass.prototype = new MovieClip();
Object.registerClass("LoadingDataDisplay",LoadingDataDisplayClass);
p.barWidth = 100;
p.barHeight = 8;
p.fillColor = 15658734;
p.lineColor = 5263440;
p.lineThickness = 0;
p.setFractionLoaded = function(arg)
{
   if(isNaN(arg) || !isFinite(arg))
   {
      arg = 0;
   }
   var mc = this.barFillMC;
   var hw = this.barWidth / 2;
   var x = this.barWidth * arg - hw;
   mc.clear();
   mc.lineStyle(0,0,0);
   mc.moveTo(- hw,0);
   mc.beginFill(this.fillColor);
   mc.lineTo(x,0);
   mc.lineTo(x,this.barHeight);
   mc.lineTo(- hw,this.barHeight);
   mc.lineTo(- hw,0);
   mc.endFill();
};
