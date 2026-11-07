function ConstellationStarClass()
{
   this._xscale = this._yscale = 50;
   this.stop();
}
var p = ConstellationStarClass.prototype = new MovieClip();
Object.registerClass("Constellation Star",ConstellationStarClass);
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
         this._sphere._parent.removeConstellation(this.constellation);
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
      }
   }
   else
   {
      this.starActive = false;
      this._sphere._mouseArea.onPress();
   }
};
