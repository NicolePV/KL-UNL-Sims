function update()
{
   var _loc2_ = Math.sin(bodiesMC._rotation * 0.017453292519943295);
   this.spectrometerMC.linesMC._x = linesX + _loc2_ * linesRange;
}
function animOnEnterFrame()
{
   var _loc2_ = getTimer();
   this.bodiesMC._rotation = (this.bodiesMC._rotation + this.animRate * (_loc2_ - this.timeLast)) % 360;
   this.timeLast = _loc2_;
   this.update();
}
function toggleAnimation()
{
   if(this.onEnterFrame == this.animOnEnterFrame)
   {
      delete this.onEnterFrame;
      this.toggleAnimationButton.setLabel("start animation");
   }
   else
   {
      this.onEnterFrame = this.animOnEnterFrame;
      this.timeLast = getTimer();
      this.toggleAnimationButton.setLabel("pause animation");
   }
   this.update();
}
animRate = 0.04;
linesX = this.spectrometerMC.linesMC._x;
linesRange = 20;
update();
