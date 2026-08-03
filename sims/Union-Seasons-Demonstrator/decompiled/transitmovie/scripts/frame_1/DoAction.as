onEnterFrame = function()
{
   var _loc1_ = Math.floor(parseInt(_root.wheelDelta) / 120);
   if(!isNaN(_loc1_) && isFinite(_loc1_))
   {
      if(transitImageExplorer.animateButton.getLabel() != "Stop" && transitImageExplorer.timelineMC.backgroundMC.onEnterFrame == undefined && transitImageExplorer.timelineMC.cursorMC.onMouseMove == undefined && transitImageExplorer.horizonDiagram.sun.instance.onMouseMove == undefined)
      {
         if(_loc1_ > 0)
         {
            transitImageExplorer.incrementUpBy(_loc1_);
         }
         else if(_loc1_ < 0)
         {
            transitImageExplorer.incrementDownBy(Math.abs(_loc1_));
         }
      }
   }
   delete _root.wheelDelta;
};
