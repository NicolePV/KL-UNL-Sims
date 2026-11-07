package
{
   import flash.events.Event;
   
   public class SHZDiagramEvent extends Event
   {
      
      public var param:* = null;
      
      public var message:String;
      
      public function SHZDiagramEvent(param1:String, param2:* = null)
      {
         super(param1);
         this.param = param2;
         this.message = param1;
      }
      
      override public function clone() : Event
      {
         return new SHZDiagramEvent(message,param);
      }
   }
}

