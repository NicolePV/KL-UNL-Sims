package
{
   import flash.display.MovieClip;
   import flash.system.Capabilities;
   import flash.text.TextField;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol21")]
   public dynamic class About extends MovieClip
   {
      
      public var versionName:String;
      
      public var infoField:TextField;
      
      public var versionDate:String;
      
      public function About()
      {
         super();
         addFrameScript(0,frame1);
      }
      
      internal function frame1() : *
      {
         versionDate = "26 July 2010";
         versionName = "moonBisector";
         infoField.autoSize = "right";
         infoField.text = versionName + ", " + versionDate + "\nyour player version: " + Capabilities.version;
      }
   }
}

