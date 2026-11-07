package
{
   import flash.display.MovieClip;
   import flash.system.Capabilities;
   import flash.text.TextField;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol38")]
   public dynamic class About extends MovieClip
   {
      
      public var versionName:String;
      
      public var infoField:TextField;
      
      public var versionDate:String;
      
      public function About()
      {
         super();
         addFrameScript(0,this.frame1);
      }
      
      internal function frame1() : *
      {
         this.versionDate = "17 March 2010";
         this.versionName = "galacticRedshift003";
         this.infoField.autoSize = "right";
         this.infoField.text = this.versionName + ", " + this.versionDate + "\nyour player version: " + Capabilities.version;
      }
   }
}

