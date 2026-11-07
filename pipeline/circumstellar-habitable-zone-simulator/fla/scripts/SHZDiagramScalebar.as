package
{
   import flash.display.Sprite;
   import flash.filters.BlurFilter;
   import flash.text.TextField;
   import flash.text.TextFormat;
   
   public class SHZDiagramScalebar extends Sprite
   {
      
      protected var _labelField:TextField;
      
      protected var _labelField2:TextField;
      
      protected var _barAndLabelSP:Sprite;
      
      public const barColor:uint = 16777215;
      
      public var minSpacing:Number = 15;
      
      protected var _barAndLabelHaloSP:Sprite;
      
      public const barHeight:Number = 5;
      
      protected var _diagram:SHZDiagram;
      
      public function SHZDiagramScalebar(param1:SHZDiagram)
      {
         super();
         _diagram = param1;
         var _loc2_:TextFormat = new TextFormat("Verdana",12,barColor,true);
         _loc2_.align = "center";
         _barAndLabelHaloSP = new Sprite();
         _barAndLabelSP = new Sprite();
         _labelField = new TextField();
         _labelField.width = 105;
         _labelField.height = 0;
         _labelField.autoSize = "center";
         _labelField.embedFonts = true;
         _labelField.defaultTextFormat = _loc2_;
         _labelField.selectable = false;
         _labelField.text = "AU";
         _labelField.x = -_labelField.width / 2;
         _labelField.y = -_labelField.height;
         _barAndLabelSP.addChild(_labelField);
         _loc2_.color = 0;
         _labelField2 = new TextField();
         _labelField2.width = 105;
         _labelField2.height = 0;
         _labelField2.autoSize = "center";
         _labelField2.embedFonts = true;
         _labelField2.defaultTextFormat = _loc2_;
         _labelField2.selectable = false;
         _labelField2.text = "AU";
         _labelField2.x = -_labelField2.width / 2;
         _labelField2.y = -_labelField2.height;
         _barAndLabelHaloSP.addChild(_labelField2);
         _barAndLabelHaloSP.filters = [new BlurFilter()];
         addChild(_barAndLabelHaloSP);
         addChild(_barAndLabelSP);
      }
      
      public function update() : void
      {
         var halfBarWidth:Number;
         var spacing:Number = NaN;
         var belowSpacing:Number = NaN;
         var majorMultiple:uint = 0;
         var minX:Number = -_diagram.starX;
         var maxX:Number = _diagram.width - _diagram.starX;
         var minY:Number = -_diagram.height / 2;
         var maxY:Number = _diagram.height / 2;
         var m:Number = minSpacing / _diagram.scale;
         var lg:Number = Math.log(m) / Math.LN10;
         var k:int = Math.ceil(lg);
         if(k - lg > Math.log(2) / Math.LN10)
         {
            belowSpacing = Math.pow(10,k - 1);
            spacing = 5 * belowSpacing;
            majorMultiple = 2;
         }
         else
         {
            spacing = Math.pow(10,k);
            belowSpacing = 0.5 * spacing;
            majorMultiple = 5;
         }
         halfBarWidth = majorMultiple * spacing * _diagram.scale / 2;
         with(_barAndLabelSP.graphics)
         {
            clear();
            moveTo(-halfBarWidth,0);
            beginFill(barColor);
            lineTo(halfBarWidth,0);
            lineTo(halfBarWidth,barHeight);
            lineTo(-halfBarWidth,barHeight);
            lineTo(-halfBarWidth,0);
            endFill();
         }
         with(_barAndLabelHaloSP.graphics)
         {
            clear();
            moveTo(-halfBarWidth,0);
            beginFill(0);
            lineTo(halfBarWidth,0);
            lineTo(halfBarWidth,barHeight);
            lineTo(-halfBarWidth,barHeight);
            lineTo(-halfBarWidth,0);
            endFill();
         }
         _labelField.text = String(majorMultiple * spacing) + " AU";
         _labelField2.text = String(majorMultiple * spacing) + " AU";
      }
   }
}

