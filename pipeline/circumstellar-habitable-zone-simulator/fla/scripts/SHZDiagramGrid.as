package
{
   import flash.display.Shape;
   
   public class SHZDiagramGrid extends Shape
   {
      
      public var lineThickness:Number = 1;
      
      public var maxLineAlpha:Number = 0.2;
      
      public var lineColor:uint = 14737632;
      
      public var minSpacing:Number = 15;
      
      protected var _diagram:SHZDiagram;
      
      public var minLineAlpha:Number = 0.05;
      
      public function SHZDiagramGrid(param1:SHZDiagram)
      {
         super();
         _diagram = param1;
      }
      
      public function update() : void
      {
         var _loc9_:Number = NaN;
         var _loc10_:Number = NaN;
         var _loc11_:uint = 0;
         var _loc14_:int = 0;
         var _loc15_:Number = NaN;
         var _loc16_:Number = NaN;
         var _loc1_:Number = -_diagram.starX;
         var _loc2_:Number = _diagram.width - _diagram.starX;
         var _loc3_:Number = -_diagram.height / 2;
         var _loc4_:Number = _diagram.height / 2;
         var _loc5_:Number = _diagram.scale;
         var _loc6_:Number = minSpacing / _loc5_;
         var _loc7_:Number = Math.log(_loc6_) / Math.LN10;
         var _loc8_:int = Math.ceil(_loc7_);
         if(_loc8_ - _loc7_ > Math.log(2) / Math.LN10)
         {
            _loc10_ = Math.pow(10,_loc8_ - 1);
            _loc9_ = 5 * _loc10_;
            _loc11_ = 2;
         }
         else
         {
            _loc9_ = Math.pow(10,_loc8_);
            _loc10_ = 0.5 * _loc9_;
            _loc11_ = 5;
         }
         var _loc12_:Number = minLineAlpha + (maxLineAlpha - minLineAlpha) * (_loc9_ - _loc6_) / (_loc9_ - _loc10_);
         var _loc13_:Number = maxLineAlpha;
         graphics.clear();
         var _loc17_:int = Math.ceil(_loc2_ / _loc5_ / _loc9_);
         _loc14_ = Math.ceil(_loc1_ / _loc5_ / _loc9_);
         while(_loc14_ < _loc17_)
         {
            _loc15_ = _loc14_ * _loc9_ * _loc5_;
            if(_loc14_ % _loc11_ == 0)
            {
               graphics.lineStyle(lineThickness,lineColor,_loc13_);
            }
            else
            {
               graphics.lineStyle(lineThickness,lineColor,_loc12_);
            }
            graphics.moveTo(_loc15_,_loc3_);
            graphics.lineTo(_loc15_,_loc4_);
            _loc14_++;
         }
         var _loc18_:int = Math.ceil(_loc4_ / _loc5_ / _loc9_);
         _loc14_ = Math.ceil(_loc3_ / _loc5_ / _loc9_);
         while(_loc14_ < _loc18_)
         {
            _loc16_ = _loc14_ * _loc9_ * _loc5_;
            if(_loc14_ % _loc11_ == 0)
            {
               graphics.lineStyle(lineThickness,lineColor,_loc13_);
            }
            else
            {
               graphics.lineStyle(lineThickness,lineColor,_loc12_);
            }
            graphics.moveTo(_loc1_,_loc16_);
            graphics.lineTo(_loc2_,_loc16_);
            _loc14_++;
         }
      }
   }
}

