package
{
   import flash.display.MovieClip;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol119")]
   public class FilterStrengthsChart extends MovieClip
   {
      
      public var rBar:MovieClip;
      
      public var bBar:MovieClip;
      
      public var vBar:MovieClip;
      
      public var uBar:MovieClip;
      
      public function FilterStrengthsChart()
      {
         super();
      }
      
      public function setMagnitudes(param1:Object) : void
      {
         var _loc2_:Number = 1;
         var _loc3_:Number = 4.8;
         var _loc4_:Number = _loc3_ - _loc2_;
         this.uBar.scaleY = (-param1.U - _loc2_) / _loc4_;
         this.bBar.scaleY = (-param1.B - _loc2_) / _loc4_;
         this.vBar.scaleY = (-param1.V - _loc2_) / _loc4_;
         this.rBar.scaleY = (-param1.R - _loc2_) / _loc4_;
      }
   }
}

