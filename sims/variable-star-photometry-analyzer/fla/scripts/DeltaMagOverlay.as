package
{
   import edu.unl.astro.utils.Plot;
   import flash.display.BitmapData;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.text.TextField;
   import flash.text.TextFormat;
   
   public class DeltaMagOverlay extends Sprite
   {
      
      private var _limit1:Number = -50;
      
      private var _enabled:Boolean = true;
      
      public var normalBarAlpha:Number = 1;
      
      public var normalBarColor:uint = 9474192;
      
      private var _plotHeight:Number;
      
      private var _yOffset:Number = 0;
      
      public var activeBarAlpha:Number = 1;
      
      public var checkeredPatternColor2:uint = 1354809536;
      
      public var activeBarColor:uint = 9474192;
      
      public var normalBarThickness:Number = 1;
      
      private var _checkeredPatternBMD:BitmapData;
      
      public var checkeredPatternSize:uint = 4;
      
      private var _linkedPlot:Plot;
      
      public var checkeredPatternColor1:uint = 1357967600;
      
      public var textBorderColor:* = 2155905152;
      
      private var _barBeingDragged:Boolean = false;
      
      private var _differenceTextField:TextField;
      
      private var _checkeredPatternMaskSP:Sprite;
      
      public var textFormat:TextFormat;
      
      private var _deltaMagBar2SP:Sprite;
      
      private var _activeBar:Sprite = null;
      
      public var activeBarThickness:Number = 3;
      
      private var _deltaMagDefined:Boolean = false;
      
      private var _deltaMagBar1SP:Sprite;
      
      private var _plotWidth:Number;
      
      public var textBackgroundColor:* = 2164260863;
      
      private var _mouseAreaSP:Sprite;
      
      private var _checkeredPatternSP:Sprite;
      
      private var _limit2:Number = -100;
      
      public function DeltaMagOverlay(... rest)
      {
         super();
         _mouseAreaSP = new Sprite();
         _checkeredPatternSP = new Sprite();
         _checkeredPatternMaskSP = new Sprite();
         _deltaMagBar1SP = new Sprite();
         _deltaMagBar2SP = new Sprite();
         textFormat = new TextFormat("Verdana",12,0);
         addChild(_checkeredPatternSP);
         addChild(_checkeredPatternMaskSP);
         addChild(_mouseAreaSP);
         addChild(_deltaMagBar1SP);
         addChild(_deltaMagBar2SP);
         _checkeredPatternSP.mask = _checkeredPatternMaskSP;
         setEnabled(true);
         _deltaMagBar1SP.addEventListener(MouseEvent.MOUSE_DOWN,onMouseDownOnBar);
         _deltaMagBar1SP.addEventListener(MouseEvent.ROLL_OVER,onRollOverBar);
         _deltaMagBar1SP.addEventListener(MouseEvent.ROLL_OUT,onRollOutFromBar);
         _deltaMagBar2SP.addEventListener(MouseEvent.MOUSE_DOWN,onMouseDownOnBar);
         _deltaMagBar2SP.addEventListener(MouseEvent.ROLL_OVER,onRollOverBar);
         _deltaMagBar2SP.addEventListener(MouseEvent.ROLL_OUT,onRollOutFromBar);
         if(rest.length > 0)
         {
            setLinkedPlot(rest[0]);
         }
      }
      
      private function onRollOutFromBar(param1:MouseEvent) : void
      {
         if(_barBeingDragged)
         {
            return;
         }
         _activeBar = null;
         update();
      }
      
      private function onRollOverBar(param1:MouseEvent) : void
      {
         if(_barBeingDragged)
         {
            return;
         }
         _activeBar = param1.target as Sprite;
         update();
      }
      
      public function setEnabled(param1:Boolean) : void
      {
         _enabled = param1;
         if(_enabled)
         {
            _mouseAreaSP.addEventListener(MouseEvent.MOUSE_DOWN,onMouseDownOverMouseArea);
         }
         else
         {
            _mouseAreaSP.removeEventListener(MouseEvent.MOUSE_DOWN,onMouseDownOverMouseArea);
         }
         update();
      }
      
      private function onMouseUpFromBar(... rest) : void
      {
         var _loc2_:Point = null;
         _barBeingDragged = false;
         stage.removeEventListener(MouseEvent.MOUSE_UP,onMouseUpFromBar);
         stage.removeEventListener(MouseEvent.MOUSE_MOVE,onMouseMoveWithBar);
         _loc2_ = _activeBar.localToGlobal(new Point(_activeBar.mouseX,_activeBar.mouseY));
         if(!_activeBar.hitTestPoint(_loc2_.x,_loc2_.y,true))
         {
            _activeBar = null;
            update();
         }
      }
      
      private function onMouseDownOverMouseArea(... rest) : void
      {
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         _loc2_ = Math.abs(mouseY - _limit1);
         _loc3_ = Math.abs(mouseY - _limit2);
         if(_loc2_ < _loc3_)
         {
            _limit1 = mouseY;
            _activeBar = _deltaMagBar1SP;
         }
         else
         {
            _limit2 = mouseY;
            _activeBar = _deltaMagBar2SP;
         }
         startBarDragging(_activeBar);
      }
      
      private function onMouseMoveWithBar(param1:MouseEvent) : void
      {
         var _loc2_:Number = NaN;
         _loc2_ = mouseY - _yOffset;
         if(_loc2_ > 0)
         {
            _loc2_ = 0;
         }
         else if(_loc2_ < -_plotHeight)
         {
            _loc2_ = -_plotHeight;
         }
         if(_activeBar == _deltaMagBar1SP)
         {
            _limit1 = _loc2_;
         }
         else
         {
            _limit2 = _loc2_;
         }
         update();
         param1.updateAfterEvent();
      }
      
      public function setLinkedPlot(param1:Plot) : void
      {
         var _loc2_:Object = null;
         var _loc3_:Rectangle = null;
         var _loc4_:BitmapData = null;
         _linkedPlot = param1;
         x = _linkedPlot.x;
         y = _linkedPlot.y;
         _loc2_ = _linkedPlot.getPlotDimensions();
         _plotWidth = _loc2_.width;
         _plotHeight = _loc2_.height;
         _mouseAreaSP.graphics.clear();
         _mouseAreaSP.graphics.moveTo(0,0);
         _mouseAreaSP.graphics.beginFill(16711680,0);
         _mouseAreaSP.graphics.lineTo(0,-_plotHeight);
         _mouseAreaSP.graphics.lineTo(_plotWidth,-_plotHeight);
         _mouseAreaSP.graphics.lineTo(_plotWidth,0);
         _mouseAreaSP.graphics.lineTo(0,0);
         _mouseAreaSP.graphics.endFill();
         _loc3_ = new Rectangle(0,0,checkeredPatternSize,checkeredPatternSize);
         _loc4_ = new BitmapData(2 * checkeredPatternSize,2 * checkeredPatternSize,true);
         _loc4_.fillRect(_loc3_,checkeredPatternColor1);
         _loc3_.x = checkeredPatternSize;
         _loc4_.fillRect(_loc3_,checkeredPatternColor2);
         _loc3_.y = checkeredPatternSize;
         _loc4_.fillRect(_loc3_,checkeredPatternColor1);
         _loc3_.x = 0;
         _loc4_.fillRect(_loc3_,checkeredPatternColor2);
         _checkeredPatternSP.graphics.clear();
         _checkeredPatternSP.graphics.moveTo(0,0);
         _checkeredPatternSP.graphics.beginBitmapFill(_loc4_);
         _checkeredPatternSP.graphics.lineTo(0,-_plotHeight);
         _checkeredPatternSP.graphics.lineTo(_plotWidth,-_plotHeight);
         _checkeredPatternSP.graphics.lineTo(_plotWidth,0);
         _checkeredPatternSP.graphics.lineTo(0,0);
         _checkeredPatternSP.graphics.endFill();
         update();
      }
      
      public function update() : void
      {
         var _loc1_:Number = NaN;
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc5_:Object = null;
         var _loc6_:Number = NaN;
         _deltaMagBar1SP.graphics.clear();
         _deltaMagBar2SP.graphics.clear();
         _checkeredPatternMaskSP.graphics.clear();
         if(_differenceTextField != null)
         {
            removeChild(_differenceTextField);
         }
         _deltaMagBar1SP.graphics.lineStyle(normalBarThickness,normalBarColor,normalBarAlpha,false,"normal","none");
         _deltaMagBar2SP.graphics.lineStyle(normalBarThickness,normalBarColor,normalBarAlpha,false,"normal","none");
         if(_activeBar != null)
         {
            _activeBar.graphics.lineStyle(activeBarThickness,activeBarColor,activeBarAlpha,false,"normal","none");
         }
         if(_linkedPlot != null && !isNaN(_limit1) && !isNaN(_limit2))
         {
            _deltaMagBar1SP.graphics.moveTo(0,_limit1);
            _deltaMagBar1SP.graphics.lineTo(_plotWidth,_limit1);
            _deltaMagBar2SP.graphics.moveTo(0,_limit2);
            _deltaMagBar2SP.graphics.lineTo(_plotWidth,_limit2);
            _loc1_ = -_plotHeight;
            _loc2_ = Math.min(_limit1,_limit2);
            _loc3_ = Math.max(_limit1,_limit2);
            _loc4_ = _plotWidth;
            _checkeredPatternMaskSP.graphics.moveTo(0,_loc1_);
            _checkeredPatternMaskSP.graphics.beginFill(255,1);
            _checkeredPatternMaskSP.graphics.lineTo(_loc4_,_loc1_);
            _checkeredPatternMaskSP.graphics.lineTo(_loc4_,_loc2_);
            _checkeredPatternMaskSP.graphics.lineTo(0,_loc2_);
            _checkeredPatternMaskSP.graphics.lineTo(0,_loc1_);
            _checkeredPatternMaskSP.graphics.endFill();
            _checkeredPatternMaskSP.graphics.moveTo(0,_loc3_);
            _checkeredPatternMaskSP.graphics.beginFill(65280,1);
            _checkeredPatternMaskSP.graphics.lineTo(_loc4_,_loc3_);
            _checkeredPatternMaskSP.graphics.lineTo(_loc4_,0);
            _checkeredPatternMaskSP.graphics.lineTo(0,0);
            _checkeredPatternMaskSP.graphics.lineTo(0,_loc3_);
            _checkeredPatternMaskSP.graphics.endFill();
            _loc5_ = _linkedPlot.getYAxisRange();
            _loc6_ = (_loc5_.max - _loc5_.min) * ((_loc3_ - _loc2_) / _plotHeight);
            _differenceTextField = new TextField();
            _differenceTextField.autoSize = "left";
            _differenceTextField.defaultTextFormat = textFormat;
            _differenceTextField.embedFonts = true;
            _differenceTextField.text = " " + _loc6_.toFixed(2) + " mag ";
            _differenceTextField.selectable = false;
            _differenceTextField.background = true;
            _differenceTextField.border = true;
            _differenceTextField.borderColor = textBorderColor;
            _differenceTextField.backgroundColor = textBackgroundColor;
            _differenceTextField.x = _plotWidth / 2 - _differenceTextField.width / 2;
            _differenceTextField.y = _loc2_ - 1.3 * _differenceTextField.height;
            addChild(_differenceTextField);
         }
      }
      
      private function onMouseDownOnBar(param1:MouseEvent) : void
      {
         startBarDragging(param1.target as Sprite);
      }
      
      private function startBarDragging(param1:Sprite) : void
      {
         var _loc2_:Number = NaN;
         _loc2_ = _activeBar == _deltaMagBar1SP ? _limit1 : _limit2;
         _yOffset = mouseY - _loc2_;
         _activeBar = param1;
         _barBeingDragged = true;
         update();
         stage.addEventListener(MouseEvent.MOUSE_UP,onMouseUpFromBar);
         stage.addEventListener(MouseEvent.MOUSE_MOVE,onMouseMoveWithBar);
      }
   }
}

