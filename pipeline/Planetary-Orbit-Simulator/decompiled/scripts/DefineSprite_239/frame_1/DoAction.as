function changeUseSoundEffect()
{
   this._parent.visualizationMC.setUseSoundEffect(useSoundEffectCheck.getValue());
}
function changeSweepDuration(arg)
{
   this._parent.visualizationMC.setSweepDuration(arg,true);
   this._parent.updatePanelValues();
}
function changeSweepContinuously()
{
   this._parent.visualizationMC.sweepContinuously = sweepContinuouslyCheck.getValue();
}
function sweepButtonPressed()
{
   var _loc1_ = this;
   if(_loc1_._parent.visualizationMC.sweepingInProgress)
   {
      _loc1_._parent.visualizationMC.cancelSweeping();
   }
   else
   {
      _loc1_._parent.visualizationMC.startSweeping();
      if(!_loc1_._parent.visualizationMC.animationState)
      {
         _loc1_._parent.changeAnimationState();
      }
      _loc1_.sweepButton.setLabel("stop sweeping");
   }
}
function eraseSweeps()
{
   this._parent.visualizationMC.removeAllSweeps();
}
