package
{
   public class GlobeLayer
   {
      
      public var color:uint = 16777215;
      
      public var fillsList:Array = [];
      
      public var alpha:Number = 1;
      
      public function GlobeLayer(param1:uint = 16777215, param2:Number = 1, param3:Array = null)
      {
         super();
         this.color = param1;
         this.alpha = param2;
         if(param3 != null)
         {
            this.fillsList = param3;
         }
      }
   }
}

