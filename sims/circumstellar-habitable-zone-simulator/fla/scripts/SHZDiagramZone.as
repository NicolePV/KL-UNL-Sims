package
{
   import flash.display.Sprite;
   import flash.text.TextField;
   import flash.text.TextFormat;
   
   public class SHZDiagramZone extends Sprite
   {
      
      protected var _KY1:Number;
      
      protected var _KY2:Number;
      
      public var innerRadius:Number = 1;
      
      public var arrow:SHZDiagramZoneArrow;
      
      public var lineAlpha:Number = 0.75;
      
      protected var _labelCurveX:Number;
      
      public var lineColor:uint = 6324432;
      
      public var labelColor:uint = 6324432;
      
      public var fillAlpha:Number = 0.5;
      
      public var fillColor:uint = 6324432;
      
      protected var _labelMaxX:Number;
      
      protected var _diagram:SHZDiagram;
      
      public var labelField:TextField;
      
      public var lineThickness:Number = 0;
      
      protected var _arrowMaxThreshold:Number;
      
      protected var _arrowMinThreshold:Number;
      
      protected var _labelBaseR:Number;
      
      public var outerRadius:Number = 1.1;
      
      protected var _labelBaseX:Number;
      
      public var label:Sprite;
      
      protected var _labelBaseY:Number;
      
      protected var _KX1:Number;
      
      protected var _KX2:Number;
      
      public function SHZDiagramZone(param1:SHZDiagram, param2:String, param3:Number, param4:Number)
      {
         super();
         _diagram = param1;
         this.name = param2;
         this.innerRadius = param3;
         this.outerRadius = param4;
         _labelBaseX = 200;
         _labelBaseY = -(_diagram.height / 2 - 35);
         _labelBaseR = Math.sqrt(_labelBaseX * _labelBaseX + _labelBaseY * _labelBaseY);
         _labelCurveX = _labelBaseX / 4;
         _KX1 = 2 * _labelCurveX;
         _KX2 = _labelBaseX - 2 * _labelCurveX;
         _KY1 = 2 * _labelBaseY;
         _KY2 = _labelBaseY - 2 * _labelBaseY;
         var _loc5_:TextFormat = new TextFormat("Verdana",10,labelColor,true,false);
         labelField = new TextField();
         labelField.width = 0;
         labelField.height = 0;
         labelField.autoSize = "center";
         labelField.embedFonts = true;
         labelField.defaultTextFormat = _loc5_;
         labelField.text = "Habitable Zone";
         labelField.selectable = false;
         label = new Sprite();
         _labelMaxX = _diagram.width - _diagram.starX - labelField.width - 27;
         label.addChild(labelField);
         _arrowMaxThreshold = _diagram.width - _diagram.starX - 7;
         _arrowMinThreshold = 22;
         arrow = new SHZDiagramZoneArrow();
         label.addChild(arrow);
      }
      
      public function update() : void
      {
         var i:int = 0;
         var ox:Number = NaN;
         var ux:Number = NaN;
         var uy:Number = NaN;
         var ur:Number = NaN;
         var u:Number = NaN;
         var uStep:Number = NaN;
         var r:Number = (innerRadius + (outerRadius - innerRadius) / 2) * _diagram.scale;
         if(r < _labelBaseR)
         {
            u = 0.5;
            uStep = 0.25;
            i = 0;
            while(i < 12)
            {
               ux = u * (_KX1 + u * _KX2);
               uy = u * (_KY1 + u * _KY2);
               ur = Math.sqrt(ux * ux + uy * uy);
               if(ur > r)
               {
                  u -= uStep;
               }
               else
               {
                  u += uStep;
               }
               uStep *= 0.5;
               i++;
            }
            labelField.x = ux - labelField.width / 2;
            labelField.y = uy - (uy - _labelBaseY) / 2.3;
         }
         else
         {
            labelField.x = Math.sqrt(r * r - _labelBaseY * _labelBaseY) - labelField.width / 2;
            labelField.y = _labelBaseY;
            if(labelField.x > _labelMaxX)
            {
               labelField.x = _labelMaxX;
            }
         }
         if(innerRadius * _diagram.scale > _arrowMaxThreshold)
         {
            arrow.x = labelField.x + labelField.width + 5;
            arrow.y = labelField.y + labelField.height / 2;
            arrow.rotation = 0;
            arrow.visible = true;
         }
         else if(outerRadius * _diagram.scale < _arrowMinThreshold)
         {
            arrow.x = labelField.x + labelField.width / 2;
            arrow.y = labelField.y + labelField.height - 2;
            arrow.rotation = 180 + 180 / Math.PI * Math.atan2(arrow.y,arrow.x);
            arrow.visible = true;
         }
         else
         {
            arrow.visible = false;
         }
         graphics.clear();
         if(innerRadius * _diagram.scale > _diagram.safeRadius)
         {
            return;
         }
         with(graphics)
         {
            clear();
            lineStyle(lineThickness,lineColor,lineAlpha);
            beginFill(fillColor,fillAlpha);
            drawCircle(0,0,outerRadius * _diagram.scale);
            drawCircle(0,0,innerRadius * _diagram.scale);
            endFill();
         }
      }
   }
}

