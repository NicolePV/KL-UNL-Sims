function AnimationControlPanelClass()
{
   this.attachMovie("FPushButtonSymbol","animateButton",1,{label:"hey",clickHandler:"toggleAnimation",_x:80,_y:15});
   this.animateButton.setSize(115,28);
   this.attachMovie("AnimationSpeedSlider","speedSliderMC",3,{_x:137.5,_y:180});
}
var p = AnimationControlPanelClass.prototype = new MovieClip();
Object.registerClass("Animation Control Panel",AnimationControlPanelClass);
p.changeAnimationGroup = function()
{
   var _loc2_ = this.animationModeGroup.getValue();
   if(typeof _loc2_ == "string")
   {
      this.masterMC.setAnimationMode(_loc2_);
   }
};
p.toggleQuality = function()
{
   this.masterMC.useLowAnimationQuality = this.qualityCheck.getValue();
};
p.toggleAnimation = function()
{
   this.masterMC.setAnimationState(!this.masterMC.getAnimationState());
};
p.toggleLoopDay = function()
{
   this.masterMC.loopDay = this.loopDayCheck.getValue();
};
p.update = function()
{
   if(this.masterMC.getAnimationState())
   {
      this.animateButton.setLabel("stop animation");
   }
   else
   {
      this.animateButton.setLabel("start animation");
   }
   if(this.masterMC.stepByDay)
   {
      this.speedSliderMC.setLimits(this.masterMC.discreteMin,this.masterMC.discreteMax);
      this.speedSliderMC.setValue(this.masterMC.discreteSpeed);
   }
   else
   {
      this.speedSliderMC.setLimits(this.masterMC.continuousMin,this.masterMC.continuousMax);
      this.speedSliderMC.setValue(this.masterMC.continuousSpeed);
   }
   this.loopDayCheck.setValue(this.masterMC.loopDay);
   this.loopDayCheck.setEnabled(!this.masterMC.stepByDay);
};
