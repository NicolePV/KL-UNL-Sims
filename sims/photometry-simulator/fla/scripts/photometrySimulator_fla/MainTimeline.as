package photometrySimulator_fla
{
   import adobe.utils.*;
   import edu.unl.astro.starField.*;
   import fl.controls.CheckBox;
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
   import flash.system.*;
   import flash.text.*;
   import flash.ui.*;
   import flash.utils.*;
   import flash.xml.*;
   
   public dynamic class MainTimeline extends MovieClip
   {
      
      public var lum2Field:TextField;
      
      public var aperture2InfoMC:MovieClip;
      
      public var innerAperture1:PixelMaskProxy;
      
      public var innerAperture2:PixelMaskProxy;
      
      public var zoomDimensions:uint;
      
      public var showLabelsCheckBox:CheckBox;
      
      public var outerZoomOffset:uint;
      
      public var psfRadius:uint;
      
      public var innerZoomOffset:uint;
      
      public var deltaMagField:TextField;
      
      public var zoomWindowSize:uint;
      
      public var outerAperture1:PixelMaskProxy;
      
      public var gammaTF:GammaTransferFunction;
      
      public var embeddedFontsField:TextField;
      
      public var starsList:Array;
      
      public var lum1Field:TextField;
      
      public var outerAperture2:PixelMaskProxy;
      
      public var starParams:Object;
      
      public var innerRadius:uint;
      
      public var outerPixelMask1:PixelMask;
      
      public var outerPixelMask2:PixelMask;
      
      public var lum2:Number;
      
      public var aperture1InfoMC:MovieClip;
      
      public var starField:StarField;
      
      public var innerPixelMask1:PixelMask;
      
      public var innerPixelMask2:PixelMask;
      
      public var lum1:Number;
      
      public var outerRadius:uint;
      
      public var zoomWindow1:PixelDisplay;
      
      public var zoomWindow2:PixelDisplay;
      
      public var pixelInfoMC:MovieClip;
      
      public function MainTimeline()
      {
         super();
         addFrameScript(0,frame1);
         __setProp_showLabelsCheckBox_Scene1_Layer6_1();
      }
      
      public function onApertureMoved(param1:Event) : void
      {
         if(param1.target == outerAperture1)
         {
            innerAperture1.x = outerAperture1.x;
            innerAperture1.y = outerAperture1.y;
            updateAperture(1);
         }
         else
         {
            innerAperture2.x = outerAperture2.x;
            innerAperture2.y = outerAperture2.y;
            updateAperture(2);
         }
      }
      
      public function onShowLabelsToggled(... rest) : void
      {
         outerAperture1.showLabel = outerAperture2.showLabel = showLabelsCheckBox.selected;
      }
      
      public function updateDeltaMag() : void
      {
         var _loc1_:Number = NaN;
         _loc1_ = -2.5 * Math.log(lum1 / lum2) / Math.LN10;
         lum1Field.text = lum1.toFixed(2);
         lum2Field.text = lum2.toFixed(2);
         deltaMagField.text = isNaN(_loc1_) || !isFinite(_loc1_) ? "..." : _loc1_.toFixed(2);
      }
      
      public function updateAperture(param1:int) : void
      {
         var innerPixelMask:PixelMask = null;
         var outerPixelMask:PixelMask = null;
         var cx:Number = NaN;
         var cy:Number = NaN;
         var innerStats:Object = null;
         var outerStats:Object = null;
         var apertureID:int = param1;
         innerPixelMask = this["innerPixelMask" + apertureID];
         outerPixelMask = this["outerPixelMask" + apertureID];
         cx = this["outerAperture" + apertureID].x - starField.x;
         cy = this["outerAperture" + apertureID].y - starField.y;
         innerPixelMask.left = cx - innerRadius;
         innerPixelMask.top = cy - innerRadius;
         outerPixelMask.left = cx - outerRadius;
         outerPixelMask.top = cy - outerRadius;
         this["zoomWindow" + apertureID].pixelArray = starField.getPixelColors(new Rectangle(outerPixelMask.left - outerZoomOffset,outerPixelMask.top - outerZoomOffset,zoomDimensions,zoomDimensions));
         innerStats = starField.getStatistics(innerPixelMask);
         outerStats = starField.getStatistics(outerPixelMask);
         outerStats.totalCounts -= innerStats.totalCounts;
         outerStats.totalPixels -= innerStats.totalPixels;
         outerStats.average = outerStats.totalCounts / outerStats.totalPixels;
         this["lum" + apertureID] = innerStats.totalCounts - innerStats.totalPixels * outerStats.average;
         with(this["aperture" + apertureID + "InfoMC"])
         {
            centerXField.text = cx.toString();
            centerYField.text = cy.toString();
            innerTotalPixelsField.text = innerStats.totalPixels.toString();
            innerTotalCountsField.text = innerStats.totalCounts.toString();
            innerAvgCountField.text = innerStats.average.toFixed(2);
            outerTotalPixelsField.text = outerStats.totalPixels.toString();
            outerTotalCountsField.text = outerStats.totalCounts.toString();
            outerAvgCountField.text = outerStats.average.toFixed(2);
         }
         updatePixelInfo(apertureID);
         updateDeltaMag();
      }
      
      public function updateEverything() : void
      {
         updateAperture(1);
         updateAperture(2);
      }
      
      internal function frame1() : *
      {
         embeddedFontsField.visible = false;
         starsList = [{
            "magnitude":2.5,
            "x":132,
            "y":265
         },{
            "magnitude":3.42,
            "x":113,
            "y":186
         },{
            "magnitude":3.77,
            "x":279,
            "y":262
         },{
            "magnitude":3.89,
            "x":170,
            "y":52
         },{
            "magnitude":3.89,
            "x":359,
            "y":129
         },{
            "magnitude":3.97,
            "x":41,
            "y":72
         },{
            "magnitude":4.02,
            "x":121,
            "y":26
         },{
            "magnitude":4.15,
            "x":169,
            "y":204
         },{
            "magnitude":4.2,
            "x":348,
            "y":33
         },{
            "magnitude":4.23,
            "x":29,
            "y":157
         },{
            "magnitude":4.26,
            "x":195,
            "y":210
         },{
            "magnitude":4.3,
            "x":82,
            "y":66
         },{
            "magnitude":4.46,
            "x":43,
            "y":26
         },{
            "magnitude":4.57,
            "x":287,
            "y":41
         },{
            "magnitude":4.73,
            "x":129,
            "y":105
         },{
            "magnitude":4.78,
            "x":239,
            "y":225
         },{
            "magnitude":4.85,
            "x":301,
            "y":185
         },{
            "magnitude":4.89,
            "x":62,
            "y":255
         },{
            "magnitude":4.89,
            "x":57,
            "y":192
         },{
            "magnitude":5.02,
            "x":47,
            "y":126
         },{
            "magnitude":5.02,
            "x":342,
            "y":272
         },{
            "magnitude":5.24,
            "x":278,
            "y":135
         },{
            "magnitude":5.78,
            "x":217,
            "y":22
         },{
            "magnitude":5.87,
            "x":259,
            "y":147
         },{
            "magnitude":6.2,
            "x":341,
            "y":215
         }];
         zoomDimensions = 23;
         zoomWindowSize = 8 * zoomDimensions;
         psfRadius = 4;
         innerRadius = 5;
         outerRadius = 2 * innerRadius;
         innerZoomOffset = (zoomDimensions - (2 * innerRadius + 1)) / 2;
         outerZoomOffset = (zoomDimensions - (2 * outerRadius + 1)) / 2;
         zoomWindow1 = new PixelDisplay({"displaySize":zoomWindowSize});
         zoomWindow1.x = 450;
         zoomWindow1.y = 74;
         zoomWindow2 = new PixelDisplay({"displaySize":zoomWindowSize});
         zoomWindow2.x = 450;
         zoomWindow2.y = 355;
         zoomWindow1.addEventListener("activePixelChanged",onActivePixelChanged);
         zoomWindow2.addEventListener("activePixelChanged",onActivePixelChanged);
         starField = new StarField();
         starField.x = 14;
         starField.y = 62;
         starField.lock();
         starField.outOfBoundsColor = 2163931898;
         starField.dimensions = {
            "width":400,
            "height":300
         };
         gammaTF = new GammaTransferFunction();
         starField.transferFunction = gammaTF;
         starField.noiseMean = 2318;
         starField.noiseSigma = 426;
         starField.saturationMagnitude = 3;
         starField.psf = new AiryDisc(psfRadius);
         for each(starParams in starsList)
         {
            starField.addStar(new Star(starParams));
         }
         starField.unlock();
         innerPixelMask1 = new PixelMask(innerRadius);
         innerPixelMask2 = new PixelMask(innerRadius);
         outerPixelMask1 = new PixelMask(outerRadius);
         outerPixelMask2 = new PixelMask(outerRadius);
         innerAperture1 = new PixelMaskProxy({
            "pixelMask":innerPixelMask1,
            "outlineColor":6340704
         });
         innerAperture1.x = 210;
         innerAperture1.y = 250;
         outerAperture1 = new PixelMaskProxy({
            "label":"1",
            "pixelMask":outerPixelMask1,
            "outlineColor":innerAperture1.outlineColor
         });
         outerAperture1.x = innerAperture1.x;
         outerAperture1.y = innerAperture1.y;
         innerAperture2 = new PixelMaskProxy({
            "pixelMask":innerPixelMask2,
            "outlineColor":15769600
         });
         innerAperture2.x = 100;
         innerAperture2.y = 100;
         outerAperture2 = new PixelMaskProxy({
            "label":"2",
            "pixelMask":outerPixelMask2,
            "outlineColor":innerAperture2.outlineColor
         });
         outerAperture2.x = innerAperture2.x;
         outerAperture2.y = innerAperture2.y;
         outerAperture1.enabled = true;
         outerAperture2.enabled = true;
         outerAperture1.bounds = new Rectangle(starField.x,starField.y,starField.width - 1,starField.height - 1);
         outerAperture2.bounds = new Rectangle(starField.x,starField.y,starField.width - 1,starField.height - 1);
         outerAperture1.addEventListener("pixelMaskProxyMoved",onApertureMoved);
         outerAperture2.addEventListener("pixelMaskProxyMoved",onApertureMoved);
         lum1 = 1;
         lum2 = 1;
         addChild(starField);
         addChild(zoomWindow1);
         addChild(zoomWindow2);
         addChild(innerAperture1);
         addChild(innerAperture2);
         addChild(outerAperture1);
         addChild(outerAperture2);
         setChildIndex(pixelInfoMC,numChildren - 1);
         pixelInfoMC.mouseEnabled = false;
         pixelInfoMC.mouseChildren = false;
         zoomWindow1.enabled = true;
         zoomWindow2.enabled = true;
         zoomWindow1.tabIndex = 1;
         zoomWindow2.tabIndex = 2;
         outerAperture1.tabIndex = 3;
         outerAperture2.tabIndex = 4;
         updateEverything();
         drawAperturesInZoomWindows();
         showLabelsCheckBox.addEventListener(Event.CHANGE,onShowLabelsToggled);
      }
      
      public function onActivePixelChanged(param1:Event) : void
      {
         if(param1.target == zoomWindow1)
         {
            updatePixelInfo(1);
         }
         else
         {
            updatePixelInfo(2);
         }
      }
      
      internal function __setProp_showLabelsCheckBox_Scene1_Layer6_1() : *
      {
         try
         {
            showLabelsCheckBox["componentInspectorSetting"] = true;
         }
         catch(e:Error)
         {
         }
         showLabelsCheckBox.enabled = true;
         showLabelsCheckBox.label = "label the apertures";
         showLabelsCheckBox.labelPlacement = "right";
         showLabelsCheckBox.selected = false;
         showLabelsCheckBox.visible = true;
         try
         {
            showLabelsCheckBox["componentInspectorSetting"] = false;
         }
         catch(e:Error)
         {
         }
      }
      
      public function drawAperturesInZoomWindows(... rest) : void
      {
         var _loc2_:Object = null;
         zoomWindow1.clearCustomMarkings();
         zoomWindow2.clearCustomMarkings();
         _loc2_ = {"lineStyle":{
            "thickness":0,
            "color":16711680,
            "alpha":1
         }};
         _loc2_.lineStyle.color = outerAperture1.outlineColor;
         _loc2_.pointsList = outerAperture1.outlinePointsList;
         _loc2_.xOffset = outerZoomOffset;
         _loc2_.yOffset = outerZoomOffset;
         zoomWindow1.addCustomMarking(_loc2_);
         _loc2_.lineStyle.color = outerAperture2.outlineColor;
         _loc2_.pointsList = outerAperture2.outlinePointsList;
         _loc2_.xOffset = outerZoomOffset;
         _loc2_.yOffset = outerZoomOffset;
         zoomWindow2.addCustomMarking(_loc2_);
         _loc2_.lineStyle.color = innerAperture1.outlineColor;
         _loc2_.pointsList = innerAperture1.outlinePointsList;
         _loc2_.xOffset = innerZoomOffset;
         _loc2_.yOffset = innerZoomOffset;
         zoomWindow1.addCustomMarking(_loc2_);
         _loc2_.lineStyle.color = innerAperture2.outlineColor;
         _loc2_.pointsList = innerAperture2.outlinePointsList;
         _loc2_.xOffset = innerZoomOffset;
         _loc2_.yOffset = innerZoomOffset;
         zoomWindow2.addCustomMarking(_loc2_);
      }
      
      public function updatePixelInfo(param1:uint) : void
      {
         var _loc2_:PixelDisplay = null;
         var _loc3_:PixelDisplay = null;
         var _loc4_:PixelMask = null;
         var _loc5_:Point = null;
         var _loc6_:Object = null;
         _loc2_ = this["zoomWindow" + param1];
         _loc3_ = this["zoomWindow" + String(2 - (param1 + 1) % 2)];
         _loc4_ = this["innerPixelMask" + param1];
         if(_loc2_.activePixel.x != -1)
         {
            _loc5_ = new Point();
            _loc5_.x = int(_loc4_.left - innerZoomOffset + _loc2_.activePixel.x);
            _loc5_.y = int(_loc4_.top - innerZoomOffset + _loc2_.activePixel.y);
            _loc6_ = starField.getPixelInfo(_loc5_);
            pixelInfoMC.visible = true;
            pixelInfoMC.x = _loc2_.x + _loc2_.xPixelSize * (_loc2_.activePixel.x + 0.5);
            pixelInfoMC.y = _loc2_.y + _loc2_.xPixelSize * _loc2_.activePixel.y;
            pixelInfoMC.xField.text = _loc5_.x.toString();
            pixelInfoMC.yField.text = _loc5_.y.toString();
            pixelInfoMC.countsField.text = _loc6_.counts != -1 ? _loc6_.counts.toString() : "...";
            _loc3_.clearActivePixel();
         }
         else if(_loc3_.activePixel.x == -1)
         {
            pixelInfoMC.visible = false;
         }
      }
   }
}

