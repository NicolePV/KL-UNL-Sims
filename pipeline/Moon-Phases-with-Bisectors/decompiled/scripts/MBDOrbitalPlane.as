package
{
   import adobe.utils.*;
   import flash.accessibility.*;
   import flash.display.*;
   import flash.errors.*;
   import flash.events.*;
   import flash.external.*;
   import flash.filters.*;
   import flash.geom.*;
   import flash.media.*;
   import flash.net.*;
   import flash.printing.*;
   import flash.profiler.*;
   import flash.sampler.*;
   import flash.system.*;
   import flash.text.*;
   import flash.ui.*;
   import flash.utils.*;
   import flash.xml.*;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol29")]
   public dynamic class MBDOrbitalPlane extends MovieClip
   {
      
      public var earthSunDirMC:MovieClip;
      
      public var sunAngle:Number;
      
      public var showEarthMoonLine:Boolean;
      
      public var orbit:MovieClip;
      
      public var moonAngle:Number;
      
      public var showSunLines:Boolean;
      
      public var moonSunDirMC:MovieClip;
      
      public function MBDOrbitalPlane()
      {
         super();
         addFrameScript(0,frame1);
      }
      
      public function receiveData(param1:*) : void
      {
         if(param1.moonAngle != undefined)
         {
            moonAngle = param1.moonAngle;
         }
         if(param1.sunAngle != undefined)
         {
            sunAngle = param1.sunAngle;
         }
         if(param1.showEarthMoonLine != undefined)
         {
            showEarthMoonLine = param1.showEarthMoonLine;
         }
         if(param1.showSunLines != undefined)
         {
            showSunLines = param1.showSunLines;
         }
         var _loc2_:Number = Math.cos(moonAngle * Math.PI / 180);
         var _loc3_:Number = Math.sin(moonAngle * Math.PI / 180);
         var _loc4_:Number = Math.cos(sunAngle * Math.PI / 180);
         var _loc5_:Number = Math.sin(sunAngle * Math.PI / 180);
         graphics.clear();
         if(showEarthMoonLine)
         {
            graphics.lineStyle(2,41215,0.6);
            graphics.moveTo(41 * _loc3_,41 * _loc2_);
            graphics.lineTo(199 * _loc3_,199 * _loc2_);
         }
         earthSunDirMC.x = 64 * _loc5_;
         earthSunDirMC.y = 64 * _loc4_;
         earthSunDirMC.rotation = -sunAngle;
         var _loc6_:Number = 220 * _loc3_;
         var _loc7_:Number = 220 * _loc2_;
         moonSunDirMC.x = _loc6_ + 32 * _loc5_;
         moonSunDirMC.y = _loc7_ + 32 * _loc4_;
         moonSunDirMC.rotation = -sunAngle;
         earthSunDirMC.visible = moonSunDirMC.visible = showSunLines;
         orbit.rotation = -moonAngle + 83;
      }
      
      internal function frame1() : *
      {
      }
   }
}

