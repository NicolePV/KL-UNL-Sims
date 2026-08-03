function DraggableStarClass()
{
   this.stop();
}
var p = DraggableStarClass.prototype = new MovieClip();
Object.registerClass("Draggable Star",DraggableStarClass);
p.useHandCursor = false;
p.onRollOver = function()
{
   if(this._object._sp.z > 0)
   {
      this.gotoAndStop(2);
   }
};
p.onRollOut = function()
{
   this.gotoAndStop(1);
};
p.onReleaseOutside = function()
{
   if(this.starActive)
   {
      this._sphere._parent.resumeAnimation();
      this.gotoAndStop(1);
      delete this.onMouseMove;
   }
   else
   {
      this._sphere._mouseArea.onRelease();
   }
};
p.onRelease = function()
{
   if(this.starActive)
   {
      this._sphere._parent.resumeAnimation();
      if(this.starAlreadySelected && !this.mouseMoved)
      {
         this._sphere._parent.deselectSelectedStar();
      }
      delete this.onMouseMove;
   }
   else
   {
      this._sphere._mouseArea.onRelease();
   }
};
p.onPress = function()
{
   if(this._object._sp.z > 0)
   {
      if(Key.isDown(46))
      {
         this._sphere._parent.removeStar(this.starID);
      }
      else
      {
         this.starActive = true;
         this.mouseMoved = false;
         this._sphere._parent.pauseAnimation();
         if(this._sphere._parent.selectedStar == this.starID)
         {
            this.starAlreadySelected = true;
         }
         else
         {
            this.starAlreadySelected = false;
            this._sphere._parent.selectStar(this.starID);
         }
         this.onMouseMove = this.onMouseMoveFunc;
      }
   }
   else
   {
      this.starActive = false;
      this._sphere._mouseArea.onPress();
   }
};
p.onMouseMoveFunc = function()
{
   this.mouseMoved = true;
   var _loc2_ = {};
   this._sphere.getMouseRaDec(_loc2_);
   if(_loc2_.ra != null)
   {
      this._sphere._parent.moveStar(this.starID,_loc2_);
      updateAfterEvent();
   }
};
