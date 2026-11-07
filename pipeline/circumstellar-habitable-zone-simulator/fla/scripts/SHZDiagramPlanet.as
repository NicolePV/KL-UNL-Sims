package
{
   import flash.display.MovieClip;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol38")]
   public class SHZDiagramPlanet extends MovieClip
   {
      
      protected var _isDestroyed:Boolean = false;
      
      protected var _isTidallyLocked:Boolean = false;
      
      public var diagram:SHZDiagram;
      
      public function SHZDiagramPlanet(param1:SHZDiagram)
      {
         super();
         this.diagram = param1;
         stop();
      }
      
      public function setState(param1:Boolean, param2:Boolean, param3:Number) : void
      {
         if(param1)
         {
            gotoAndStop("destroyed");
         }
         else if(param2)
         {
            gotoAndStop("tidallyLocked");
         }
         else if(param3 < 0)
         {
            gotoAndStop("tooCold");
         }
         else if(param3 > 1)
         {
            gotoAndStop("tooHot");
         }
         else
         {
            gotoAndStop("justRight");
         }
      }
   }
}

