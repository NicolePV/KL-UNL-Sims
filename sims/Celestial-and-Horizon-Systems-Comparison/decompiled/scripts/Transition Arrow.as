function TransitionArrowClass()
{
   this.attachMovie("Arrow Head","leftArrowHeadMC",1,{_x:- this.halfWidth,_rotation:180});
   this.attachMovie("Arrow Head","rightArrowHeadMC",2,{_x:this.halfWidth});
   this.leftLabelColor = new Color(this.leftLabel);
   this.rightLabelColor = new Color(this.rightLabel);
   this.leftArrowHeadColor = new Color(this.leftArrowHeadMC);
   this.rightArrowHeadColor = new Color(this.rightArrowHeadMC);
   var maxR = (this.maxColor & 0xFF0000) >> 16;
   var maxG = (this.maxColor & 0xFF00) >> 8;
   var maxB = this.maxColor & 0xFF;
   var minR = (this.minColor & 0xFF0000) >> 16;
   var minG = (this.minColor & 0xFF00) >> 8;
   var minB = this.minColor & 0xFF;
   this.halfRangeR = (maxR - minR) / 2;
   this.halfRangeG = (maxG - minG) / 2;
   this.halfRangeB = (maxB - minB) / 2;
   this.halfPointR = minR + this.halfRangeR;
   this.halfPointG = minG + this.halfRangeG;
   this.halfPointB = minB + this.halfRangeB;
}
var p = TransitionArrowClass.prototype = new MovieClip();
Object.registerClass("Transition Arrow",TransitionArrowClass);
p.halfWidth = 76;
p.maxColor = 0;
p.minColor = 14737632;
p.minFactor = 0.001;
p.maxFactor = 1;
p.halfRange = (p.maxFactor - p.minFactor) / 2;
p.halfPoint = p.minFactor + p.halfRange;
p.setTransitionFactor = function(arg)
{
   var u = (arg - this.halfPoint) / this.halfRange;
   var r1 = u * this.halfRangeR + this.halfPointR;
   var g1 = u * this.halfRangeG + this.halfPointG;
   var b1 = u * this.halfRangeB + this.halfPointB;
   var r2 = (- u) * this.halfRangeR + this.halfPointR;
   var g2 = (- u) * this.halfRangeG + this.halfPointG;
   var b2 = (- u) * this.halfRangeB + this.halfPointB;
   var leftColor = r1 << 16 | g1 << 8 | b1;
   var rightColor = r2 << 16 | g2 << 8 | b2;
   var mc = this;
   mc.clear();
   mc.lineStyle(1,16711680,0);
   mc.beginGradientFill("linear",[leftColor,rightColor],[100,100],[0,255],{matrixType:"box",x:- this.halfWidth,y:-1,w:2 * this.halfWidth,h:2,r:0});
   mc.moveTo(- this.halfWidth,1);
   mc.lineTo(- this.halfWidth,-1);
   mc.lineTo(this.halfWidth,-1);
   mc.lineTo(this.halfWidth,1);
   mc.lineTo(- this.halfWidth,1);
   mc.endFill();
   this.leftArrowHeadColor.setRGB(leftColor);
   this.rightArrowHeadColor.setRGB(rightColor);
   this.leftLabelColor.setRGB(leftColor);
   this.rightLabelColor.setRGB(rightColor);
};
