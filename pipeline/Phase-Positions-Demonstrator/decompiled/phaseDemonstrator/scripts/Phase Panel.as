function PhasePanelClass()
{
   var _loc1_ = this;
   _loc1_.createEmptyMovieClip("phaseMC",1);
   _loc1_.buttonStyle = new FStyleFormat();
   _loc1_.buttonStyle.face = 5263440;
   _loc1_.buttonStyle.textColor = 15790320;
   _loc1_.buttonStyle.textBold = true;
   _loc1_.buttonStyle.embedFonts = true;
   _loc1_.buttonStyle.textSize = 10;
}
var p = PhasePanelClass.prototype = new MovieClip();
Object.registerClass("Phase Panel",PhasePanelClass);
p.discRadius = 70;
p.darkColor = 4210752;
p.lightColor = 14737632;
p.init = function()
{
   this.buttonStyle.addListener(this.showHideButton);
};
p.toggleVisibility = function()
{
   var _loc1_ = this;
   _loc1_.phaseMC._visible = !_loc1_.phaseMC._visible;
   if(_loc1_.phaseMC._visible)
   {
      _loc1_.showHideButton.setLabel("hide");
   }
   else
   {
      _loc1_.showHideButton.setLabel("show");
   }
};
p.setPhaseAngle = function(angle)
{
   var _loc2_ = Math.sin;
   var _loc1_ = Math.cos;
   angle = (angle % 6.283185307179586 + 6.283185307179586) % 6.283185307179586;
   var _loc3_;
   if(angle < 3.141592653589793)
   {
      _loc3_ = -1;
   }
   else
   {
      _loc3_ = 1;
   }
   var n = 4;
   var r = this.discRadius;
   var s = r * _loc1_(angle);
   var step = 3.141592653589793 / n;
   var halfStep = step / 2;
   var kr = r / _loc1_(halfStep);
   var ks = s / _loc1_(halfStep);
   var mc = this.phaseMC;
   mc.clear();
   mc.lineStyle(1,16711680,0);
   mc.moveTo(0,- r);
   mc.beginFill(this.darkColor,100);
   var i = 1;
   while(i <= n)
   {
      var angle = i * step;
      var ax = r * _loc2_(angle);
      var ay = (- r) * _loc1_(angle);
      var cAngle = angle - halfStep;
      var cx = kr * _loc2_(cAngle);
      var cy = (- kr) * _loc1_(cAngle);
      mc.curveTo(_loc3_ * cx,cy,_loc3_ * ax,ay);
      i++;
   }
   var i = n - 1;
   while(i >= 0)
   {
      var angle = i * step;
      var ax = s * _loc2_(angle);
      var ay = (- r) * _loc1_(angle);
      var cAngle = angle + halfStep;
      var cx = ks * _loc2_(cAngle);
      var cy = (- kr) * _loc1_(cAngle);
      mc.curveTo(_loc3_ * cx,cy,_loc3_ * ax,ay);
      i--;
   }
   mc.endFill();
   mc.moveTo(0,- r);
   mc.beginFill(this.lightColor,100);
   var i = 1;
   while(i <= n)
   {
      var angle = i * step;
      var ax = (- r) * _loc2_(angle);
      var ay = (- r) * _loc1_(angle);
      var cAngle = angle - halfStep;
      var cx = (- kr) * _loc2_(cAngle);
      var cy = (- kr) * _loc1_(cAngle);
      mc.curveTo(_loc3_ * cx,cy,_loc3_ * ax,ay);
      i++;
   }
   var i = n - 1;
   while(i >= 0)
   {
      var angle = i * step;
      var ax = s * _loc2_(angle);
      var ay = (- r) * _loc1_(angle);
      var cAngle = angle + halfStep;
      var cx = ks * _loc2_(cAngle);
      var cy = (- kr) * _loc1_(cAngle);
      mc.curveTo(_loc3_ * cx,cy,_loc3_ * ax,ay);
      i--;
   }
   mc.endFill();
};
