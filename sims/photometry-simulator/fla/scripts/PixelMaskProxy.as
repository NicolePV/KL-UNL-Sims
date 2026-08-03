package
{
   import edu.unl.astro.starField.PixelMask;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.FocusEvent;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.text.TextField;
   import flash.text.TextFormat;
   
   public class PixelMaskProxy extends Sprite
   {
      
      private var _xOffset:Number;
      
      public var outlinePointsList:Array;
      
      private var _pixelMask:PixelMask;
      
      private var _outlineColor:uint = 16763904;
      
      private var _yOffset:Number;
      
      public var label:String = "";
      
      private var _labelTextField:TextField;
      
      public var focusRectLineThickness:Number = 3;
      
      private var _mouseDown:Boolean = false;
      
      public var focusRectLineColor:uint = 9474303;
      
      public var labelTextFormat:TextFormat;
      
      private var _focusRectSP:Sprite;
      
      public var focusRectMargin:Number = 3;
      
      private var _discSP:Sprite;
      
      private var _boundsRect:Rectangle;
      
      public function PixelMaskProxy(... rest)
      {
         super();
         labelTextFormat = new TextFormat("Verdana",16,null,true);
         _labelTextField = new TextField();
         addChild(_labelTextField);
         _discSP = new Sprite();
         addChild(_discSP);
         _focusRectSP = new Sprite();
         addChild(_focusRectSP);
         _labelTextField.visible = false;
         loadSettingsFromObjectsList(rest);
         tabEnabled = false;
         tabChildren = false;
         _focusRectSP.mouseEnabled = false;
         focusRect = {};
         _focusRectSP.visible = false;
      }
      
      private function onStageMouseUpFunc(... rest) : void
      {
         _mouseDown = false;
         stage.removeEventListener(MouseEvent.MOUSE_UP,onStageMouseUpFunc);
         stage.removeEventListener(MouseEvent.MOUSE_MOVE,onStageMouseMoveFunc);
         if(stage.focus == this && !hitTestPoint(stage.mouseX,stage.mouseY,true))
         {
            stage.focus = null;
         }
      }
      
      public function loadSettings(... rest) : void
      {
         if(rest.length > 0)
         {
            loadSettingsFromObjectsList(rest);
         }
      }
      
      public function set pixelMask(param1:PixelMask) : *
      {
         _pixelMask = param1;
         redrawOutline();
      }
      
      public function moveTo(param1:Point) : void
      {
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         _loc2_ = param1.x;
         _loc3_ = param1.y;
         if(_boundsRect != null)
         {
            if(_loc2_ < _boundsRect.left)
            {
               _loc2_ = _boundsRect.left;
            }
            else if(_loc2_ > _boundsRect.right)
            {
               _loc2_ = _boundsRect.right;
            }
            if(_loc3_ < _boundsRect.top)
            {
               _loc3_ = _boundsRect.top;
            }
            else if(_loc3_ > _boundsRect.bottom)
            {
               _loc3_ = _boundsRect.bottom;
            }
         }
         _loc2_ = Math.round(_loc2_);
         _loc3_ = Math.round(_loc3_);
         if(_loc2_ != x || _loc3_ != y)
         {
            x = _loc2_;
            y = _loc3_;
            dispatchEvent(new Event("pixelMaskProxyMoved"));
         }
      }
      
      private function onFocusIn(param1:FocusEvent) : void
      {
         _focusRectSP.visible = !_mouseDown;
         stage.addEventListener("keyDown",onKeyDownFunc);
      }
      
      public function get enabled() : Boolean
      {
         return tabEnabled;
      }
      
      public function get outlineColor() : uint
      {
         return _outlineColor;
      }
      
      private function redrawOutline() : void
      {
         var _loc1_:* = 0;
         var _loc2_:* = 0;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         var _loc10_:int = 0;
         var _loc11_:int = 0;
         var _loc12_:int = 0;
         var _loc13_:int = 0;
         var _loc14_:Boolean = false;
         var _loc15_:Boolean = false;
         var _loc16_:Number = NaN;
         _discSP.graphics.clear();
         _focusRectSP.graphics.clear();
         outlinePointsList = [];
         if(_pixelMask == null)
         {
            return;
         }
         _loc3_ = int(_pixelMask.width);
         _loc4_ = int(_pixelMask.height);
         _loc1_ = 0;
         loop0:
         while(_loc1_ < _loc3_)
         {
            _loc2_ = 0;
            while(_loc2_ < _loc4_)
            {
               if(_pixelMask.data[_loc1_][_loc2_])
               {
                  break loop0;
               }
               _loc2_++;
            }
            _loc1_++;
         }
         _loc5_ = _loc1_;
         _loc6_ = _loc2_;
         _loc8_ = 0;
         _discSP.graphics.lineStyle(0,_outlineColor,1);
         _discSP.graphics.moveTo(_loc1_ - _pixelMask.radius,_loc2_ - _pixelMask.radius);
         _discSP.graphics.beginFill(16777215,0);
         outlinePointsList.push({
            "x":_loc1_,
            "y":_loc2_
         });
         _loc7_ = 0;
         while(_loc7_ < 1000)
         {
            _loc8_ = (_loc8_ + 2) % 4;
            _loc9_ = 0;
            while(_loc9_ < 4)
            {
               _loc8_ = (_loc8_ + 1) % 4;
               switch(_loc8_)
               {
                  case 0:
                     _loc10_ = _loc1_ - 1;
                     _loc11_ = _loc2_ - 1;
                     _loc12_ = _loc1_;
                     _loc13_ = _loc2_ - 1;
                     break;
                  case 1:
                     _loc10_ = _loc1_;
                     _loc11_ = _loc2_ - 1;
                     _loc12_ = _loc1_;
                     _loc13_ = _loc2_;
                     break;
                  case 2:
                     _loc10_ = _loc1_;
                     _loc11_ = _loc2_;
                     _loc12_ = _loc1_ - 1;
                     _loc13_ = _loc2_;
                     break;
                  case 3:
                     _loc10_ = _loc1_ - 1;
                     _loc11_ = _loc2_;
                     _loc12_ = _loc1_ - 1;
                     _loc13_ = _loc2_ - 1;
               }
               _loc14_ = !(_loc10_ < 0 || _loc10_ >= _loc3_ || _loc11_ < 0 || _loc11_ >= _loc4_);
               _loc15_ = !(_loc12_ < 0 || _loc12_ >= _loc3_ || _loc13_ < 0 || _loc13_ >= _loc4_);
               if(_loc14_ && _loc15_ && Boolean(_pixelMask.data[_loc10_][_loc11_] ^ _pixelMask.data[_loc12_][_loc13_]))
               {
                  break;
               }
               if(_loc14_ && !_loc15_ && Boolean(_pixelMask.data[_loc10_][_loc11_]))
               {
                  break;
               }
               if(!_loc14_ && _loc15_ && Boolean(_pixelMask.data[_loc12_][_loc13_]))
               {
                  break;
               }
               _loc9_++;
            }
            if(_loc8_ == 0)
            {
               _loc2_--;
            }
            else if(_loc8_ == 1)
            {
               _loc1_++;
            }
            else if(_loc8_ == 2)
            {
               _loc2_++;
            }
            else
            {
               _loc1_--;
            }
            _discSP.graphics.lineTo(_loc1_ - _pixelMask.radius,_loc2_ - _pixelMask.radius);
            outlinePointsList.push({
               "x":_loc1_,
               "y":_loc2_
            });
            if(_loc1_ == _loc5_ && _loc2_ == _loc6_)
            {
               break;
            }
            _loc7_++;
         }
         _discSP.graphics.endFill();
         _loc16_ = focusRectMargin;
         _focusRectSP.graphics.lineStyle(focusRectLineThickness,focusRectLineColor);
         _focusRectSP.graphics.drawRect(-(_pixelMask.width / 2) - _loc16_,-(_pixelMask.height / 2) - _loc16_,_pixelMask.width + 2 * _loc16_,_pixelMask.height + 2 * _loc16_);
         labelTextFormat.color = _outlineColor;
         _labelTextField.embedFonts = true;
         _labelTextField.defaultTextFormat = labelTextFormat;
         _labelTextField.autoSize = "left";
         _labelTextField.text = label;
         _labelTextField.x = -(_labelTextField.width / 2) + (_labelTextField.width - _labelTextField.textWidth) / 4;
         _labelTextField.y = -(_pixelMask.width / 2) - _loc16_ - _labelTextField.textHeight - 2;
         _labelTextField.selectable = false;
         _labelTextField.tabEnabled = false;
         _labelTextField.mouseEnabled = false;
      }
      
      private function loadSettingsFromObjectsList(param1:*) : void
      {
         var _loc2_:String = null;
         var _loc3_:* = undefined;
         for each(_loc3_ in param1)
         {
            if(_loc3_ is Object)
            {
               for(_loc2_ in _loc3_)
               {
                  this[_loc2_] = _loc3_[_loc2_];
               }
            }
         }
         redrawOutline();
      }
      
      public function set bounds(param1:Rectangle) : void
      {
         _boundsRect = param1.clone();
         moveTo(new Point(x,y));
      }
      
      private function onFocusOut(... rest) : void
      {
         _focusRectSP.visible = false;
         stage.removeEventListener("keyDown",onKeyDownFunc);
      }
      
      public function set enabled(param1:Boolean) : void
      {
         if(!tabEnabled && param1)
         {
            addEventListener(FocusEvent.FOCUS_IN,onFocusIn);
            addEventListener(FocusEvent.FOCUS_OUT,onFocusOut);
            addEventListener(FocusEvent.KEY_FOCUS_CHANGE,onKeyFocusChanged);
            _discSP.addEventListener(MouseEvent.MOUSE_DOWN,onDiscMouseDownFunc);
         }
         else if(tabEnabled && !param1)
         {
            removeEventListener(FocusEvent.FOCUS_IN,onFocusIn);
            removeEventListener(FocusEvent.FOCUS_OUT,onFocusOut);
            removeEventListener(FocusEvent.KEY_FOCUS_CHANGE,onKeyFocusChanged);
            _discSP.removeEventListener(MouseEvent.MOUSE_DOWN,onDiscMouseDownFunc);
         }
         tabEnabled = param1;
      }
      
      public function set outlineColor(param1:uint) : void
      {
         _outlineColor = param1;
         redrawOutline();
      }
      
      private function onDiscMouseDownFunc(... rest) : void
      {
         _mouseDown = true;
         _focusRectSP.visible = false;
         stage.focus = this;
         _xOffset = x - parent.mouseX;
         _yOffset = y - parent.mouseY;
         stage.addEventListener(MouseEvent.MOUSE_UP,onStageMouseUpFunc);
         stage.addEventListener(MouseEvent.MOUSE_MOVE,onStageMouseMoveFunc);
         parent.setChildIndex(this,parent.numChildren - 1);
      }
      
      public function get pixelMask() : PixelMask
      {
         return _pixelMask;
      }
      
      private function onKeyDownFunc(param1:KeyboardEvent) : void
      {
         if(param1.keyCode == 37)
         {
            moveTo(new Point(x - 1,y));
            param1.updateAfterEvent();
         }
         else if(param1.keyCode == 38)
         {
            moveTo(new Point(x,y - 1));
            param1.updateAfterEvent();
         }
         else if(param1.keyCode == 39)
         {
            moveTo(new Point(x + 1,y));
            param1.updateAfterEvent();
         }
         else if(param1.keyCode == 40)
         {
            moveTo(new Point(x,y + 1));
            param1.updateAfterEvent();
         }
      }
      
      public function get bounds() : Rectangle
      {
         return _boundsRect.clone();
      }
      
      private function onStageMouseMoveFunc(param1:MouseEvent) : void
      {
         moveTo(new Point(_xOffset + parent.mouseX,_yOffset + parent.mouseY));
         param1.updateAfterEvent();
      }
      
      private function onKeyFocusChanged(param1:FocusEvent) : void
      {
         if(param1.keyCode >= 37 && param1.keyCode <= 40)
         {
            param1.preventDefault();
         }
      }
      
      public function set showLabel(param1:Boolean) : void
      {
         _labelTextField.visible = param1;
      }
      
      public function get showLabel() : Boolean
      {
         return _labelTextField.visible;
      }
   }
}

