package
{
   import flash.display.MovieClip;
   import flash.display.Sprite;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol46")]
   public class SHZHRDiagram extends MovieClip
   {
      
      public var minLogTemp:Number = Math.log(2500) / Math.LN10;
      
      protected var _curveSP:Sprite;
      
      public var minLogLum:Number = -4;
      
      public var backgroundColor:uint = 16777215;
      
      public var borderColor:uint = 8421504;
      
      public const diagramHeight:Number = 140;
      
      protected var _borderSP:Sprite;
      
      protected var _backgroundSP:Sprite;
      
      public var maxLogLum:Number = 7;
      
      public var borderThickness:Number = 1;
      
      public var maxLogTemp:Number = Math.log(50000) / Math.LN10;
      
      protected var _maskSP:Sprite;
      
      public const diagramWidth:Number = 130;
      
      protected var _labelsSP:Sprite;
      
      public function SHZHRDiagram()
      {
         super();
         _curveSP = new Sprite();
         addChild(_curveSP);
         _maskSP = new Sprite();
         addChild(_maskSP);
         _borderSP = new Sprite();
         addChild(_borderSP);
         _curveSP.mask = _maskSP;
         drawBorderAndBackground();
      }
      
      public function update(param1:Object, param2:Object) : void
      {
         var _loc3_:int = 0;
         var _loc8_:Number = NaN;
         var _loc9_:Number = NaN;
         _curveSP.graphics.clear();
         var _loc4_:Array = param1.dataTable;
         var _loc5_:Number = Number(param2.time);
         var _loc6_:Number = diagramWidth / (maxLogTemp - minLogTemp);
         var _loc7_:Number = -diagramHeight / (maxLogLum - minLogLum);
         _curveSP.graphics.clear();
         _curveSP.graphics.lineStyle(1,12105912);
         _loc3_ = 0;
         _loc8_ = minLogTemp + (maxLogTemp - minLogTemp) * (1 - _loc3_ / diagramWidth);
         _loc9_ = getLogLumFromLogTempAndClass(_loc8_);
         _curveSP.graphics.lineTo(diagramWidth - _loc6_ * (_loc8_ - minLogTemp),diagramHeight + _loc7_ * (_loc9_ - minLogLum));
         _loc3_ = 1;
         while(_loc3_ <= diagramWidth)
         {
            _loc8_ = minLogTemp + (maxLogTemp - minLogTemp) * (1 - _loc3_ / diagramWidth);
            _loc9_ = getLogLumFromLogTempAndClass(_loc8_);
            _curveSP.graphics.lineTo(diagramWidth - _loc6_ * (_loc8_ - minLogTemp),diagramHeight + _loc7_ * (_loc9_ - minLogLum));
            _loc3_++;
         }
         _curveSP.graphics.lineStyle(1,16748688);
         _curveSP.graphics.moveTo(diagramWidth - _loc6_ * (_loc4_[0].logTemp - minLogTemp),diagramHeight + _loc7_ * (_loc4_[0].logLum - minLogLum));
         _loc3_ = 1;
         while(_loc3_ < _loc4_.length)
         {
            _curveSP.graphics.lineTo(diagramWidth - _loc6_ * (_loc4_[_loc3_].logTemp - minLogTemp),diagramHeight + _loc7_ * (_loc4_[_loc3_].logLum - minLogLum));
            if(_loc4_[_loc3_].time >= _loc5_)
            {
               _curveSP.graphics.lineTo(diagramWidth - _loc6_ * (param2.logTemp - minLogTemp),diagramHeight + _loc7_ * (param2.logLum - minLogLum));
               _curveSP.graphics.moveTo(diagramWidth - _loc6_ * (param2.logTemp - minLogTemp),diagramHeight + _loc7_ * (param2.logLum - minLogLum));
               _curveSP.graphics.lineStyle();
               _curveSP.graphics.beginFill(14692400);
               _curveSP.graphics.drawCircle(diagramWidth - _loc6_ * (param2.logTemp - minLogTemp),diagramHeight + _loc7_ * (param2.logLum - minLogLum),3);
               _curveSP.graphics.endFill();
               break;
            }
            _loc3_++;
         }
      }
      
      public function drawBorderAndBackground() : void
      {
         _maskSP.graphics.clear();
         _maskSP.graphics.beginFill(16711680);
         _maskSP.graphics.drawRect(0,0,diagramWidth,diagramHeight);
         _maskSP.graphics.endFill();
         _borderSP.graphics.clear();
         _borderSP.graphics.lineStyle(borderThickness,borderColor);
         _borderSP.graphics.drawRect(0,0,diagramWidth,diagramHeight);
      }
      
      public function getLogLumFromLogTempAndClass(param1:Number, param2:uint = 5) : Number
      {
         switch(param2)
         {
            case 1:
               if(param1 < 4.1476)
               {
                  return 44.8387 + param1 * (-30.1309 + param1 * (7.59468 + param1 * -0.636977));
               }
               return -459.5864 + param1 * (334.7205 + param1 * (-80.37116 + param1 * 6.432557));
               break;
            case 2:
               if(param1 < 4.0358)
               {
                  return -36.2843 + param1 * (39.6781 + param1 * (-12.545 + param1 * 1.280459));
               }
               return -37.0612 + param1 * (40.2556 + param1 * (-12.68811 + param1 * 1.292279));
               break;
            case 3:
               if(param1 < 3.9092)
               {
                  return -53.8721 + param1 * (59.2071 + param1 * (-19.71611 + param1 * 2.108195));
               }
               return 161.9073 + param1 * (-106.3856 + param1 * (22.64341 + param1 * -1.503738));
               break;
            case 4:
               if(param1 < 4.1372)
               {
                  return -167.256 + param1 * (125.271 + param1 * (-31.96691 + param1 * 2.804002));
               }
               return 54.567 + param1 * (-35.5787 + param1 * (6.91186 + param1 * -0.328444));
               break;
            default:
               if(param1 < 3.5081)
               {
                  return -4686.707 + param1 * (4157.5332 + param1 * (-1232.05177 + param1 * 121.875554));
               }
               if(param1 < 3.5799)
               {
                  return 22801.9307 + param1 * (-19349.4898 + param1 * (5468.65774 + param1 * -514.806626));
               }
               if(param1 < 3.728)
               {
                  return -9950.2659 + param1 * (8097.5483 + param1 * (-2198.40972 + param1 * 199.100683));
               }
               if(param1 < 3.8287)
               {
                  return 10594.1896 + param1 * (-8435.0942 + param1 * (2236.33537 + param1 * -197.427256));
               }
               if(param1 < 3.9156)
               {
                  return -7990.8168 + param1 * (6127.2576 + param1 * (-1567.12652 + param1 * 133.707956));
               }
               if(param1 < 4.2129)
               {
                  return 277.0365 + param1 * (-207.2491 + param1 * (50.62412 + param1 * -4.009536));
               }
               if(param1 < 4.6015)
               {
                  return -280.446 + param1 * (189.7309 + param1 * (-43.6049 + param1 * 3.446011));
               }
               return -9724.5727 + param1 * (6346.9359 + param1 * (-1381.69136 + param1 * 100.377185));
         }
      }
   }
}

