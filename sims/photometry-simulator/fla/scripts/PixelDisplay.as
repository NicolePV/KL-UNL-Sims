package
{
   import flash.display.BitmapData;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.FocusEvent;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   
   public class PixelDisplay extends Sprite
   {
      
      private var _displayWidth:Number = 100;
      
      private var _pixelArray:Array = null;
      
      private var _displaySP:Sprite;
      
      private var _mouseIsDown:Boolean = false;
      
      private var _activePixel:Point;
      
      public var focusRectLineColor:uint = 9474303;
      
      private var _mouseIsOver:Boolean = false;
      
      private var _pixelWidth:uint = 0;
      
      private var _displayHeight:Number = 100;
      
      public var activePixelOutlineColor:uint = 9474303;
      
      public var focusRectLineThickness:Number = 3;
      
      private var _pixelHeight:uint = 0;
      
      private var _activePixelSP:Sprite;
      
      public var activePixelOutlineThickness:Number = 2;
      
      private var _focusRectSP:Sprite;
      
      public var focusRectMargin:Number = 5;
      
      private var _customMarkingsMaskSP:Sprite;
      
      private var _customMarkingsSP:Sprite;
      
      public function PixelDisplay(... rest)
      {
         super();
         _activePixel = new Point(-1,-1);
         _displaySP = new Sprite();
         addChild(_displaySP);
         _customMarkingsSP = new Sprite();
         addChild(_customMarkingsSP);
         _customMarkingsMaskSP = new Sprite();
         addChild(_customMarkingsMaskSP);
         _activePixelSP = new Sprite();
         addChild(_activePixelSP);
         _focusRectSP = new Sprite();
         addChild(_focusRectSP);
         _customMarkingsSP.mask = _customMarkingsMaskSP;
         if(rest.length > 0)
         {
            loadSettingsFromObjectsList(rest);
         }
         tabEnabled = false;
         tabChildren = false;
         mouseChildren = false;
         focusRect = {};
         _focusRectSP.visible = false;
      }
      
      private function getPixelFromMouseLocation() : Point
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         _loc1_ = mouseX == _displayWidth ? int(_pixelWidth - 1) : int(mouseX / xPixelSize);
         _loc2_ = mouseY == _displayHeight ? int(_pixelHeight - 1) : int(mouseY / yPixelSize);
         if(_loc1_ < 0 || _loc1_ >= _pixelWidth || _loc2_ < 0 || _loc2_ >= _pixelHeight)
         {
            _loc1_ = -1;
            _loc2_ = -1;
         }
         return new Point(_loc1_,_loc2_);
      }
      
      public function get displaySize() : Number
      {
         return _displayWidth;
      }
      
      public function get xPixelSize() : Number
      {
         return _displayWidth / _pixelWidth;
      }
      
      public function addCustomMarking(param1:Object) : void
      {
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc4_:int = 0;
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc7_:Boolean = false;
         var _loc8_:Array = null;
         var _loc9_:Number = NaN;
         var _loc10_:Number = NaN;
         _loc2_ = _displayWidth / _pixelWidth;
         _loc3_ = _displayHeight / _pixelHeight;
         _loc7_ = false;
         _loc8_ = [];
         if(param1.pointsList is Array)
         {
            _loc9_ = param1.xOffset is Number ? Number(param1.xOffset) : 0;
            _loc10_ = param1.yOffset is Number ? Number(param1.yOffset) : 0;
            _loc4_ = 0;
            while(_loc4_ < param1.pointsList.length)
            {
               _loc5_ = param1.pointsList[_loc4_].x + _loc9_;
               _loc6_ = param1.pointsList[_loc4_].y + _loc10_;
               _loc8_.push({
                  "x":_loc5_,
                  "y":_loc6_
               });
               if(_loc5_ >= 0 && _loc6_ >= 0 && _loc5_ <= _pixelWidth && _loc6_ <= _pixelHeight)
               {
                  _loc7_ = true;
               }
               _loc4_++;
            }
         }
         if(_loc7_)
         {
            if(param1.lineStyle is Object)
            {
               _customMarkingsSP.graphics.lineStyle(param1.lineStyle.thickness,param1.lineStyle.color,param1.lineStyle.alpha);
            }
            if(param1.fillStyle is Object)
            {
               _customMarkingsSP.graphics.beginFill(param1.fillStyle.color,param1.fillStyle.alpha);
            }
            _customMarkingsSP.graphics.moveTo(_loc2_ * _loc8_[0].x,_loc3_ * _loc8_[0].y);
            _loc4_ = 1;
            while(_loc4_ < _loc8_.length)
            {
               _customMarkingsSP.graphics.lineTo(_loc2_ * _loc8_[_loc4_].x,_loc3_ * _loc8_[_loc4_].y);
               _loc4_++;
            }
            if(param1.fillStyle is Object)
            {
               _customMarkingsSP.graphics.endFill();
            }
         }
      }
      
      private function onStageKeyDownFunc(param1:KeyboardEvent) : void
      {
         if(param1.keyCode == 37)
         {
            activePixel = new Point(_activePixel.x - 1,_activePixel.y);
            param1.updateAfterEvent();
         }
         else if(param1.keyCode == 38)
         {
            activePixel = new Point(_activePixel.x,_activePixel.y - 1);
            param1.updateAfterEvent();
         }
         else if(param1.keyCode == 39)
         {
            activePixel = new Point(_activePixel.x + 1,_activePixel.y);
            param1.updateAfterEvent();
         }
         else if(param1.keyCode == 40)
         {
            activePixel = new Point(_activePixel.x,_activePixel.y + 1);
            param1.updateAfterEvent();
         }
      }
      
      public function loadSettings(... rest) : void
      {
         if(rest.length > 0)
         {
            loadSettingsFromObjectsList(rest);
         }
      }
      
      private function onDisplayRollOut(... rest) : void
      {
         _mouseIsOver = false;
         if(stage.focus == this)
         {
            stage.focus = null;
         }
      }
      
      public function set displayHeight(param1:Number) : void
      {
         if(param1 <= 0 || param1 > 1000)
         {
            return;
         }
         _displayHeight = param1;
         redrawBackground();
      }
      
      public function get yPixelSize() : Number
      {
         return _displayHeight / _pixelHeight;
      }
      
      public function get activePixel() : Point
      {
         return _activePixel.clone();
      }
      
      public function get displayWidth() : Number
      {
         return _displayHeight;
      }
      
      private function onFocusIn(... rest) : void
      {
         if(_activePixel.x == -1)
         {
            activePixel = new Point(int(_pixelWidth / 2),int(_pixelHeight / 2));
            _focusRectSP.visible = true;
         }
         stage.addEventListener("keyDown",onStageKeyDownFunc);
         stage.addEventListener(MouseEvent.MOUSE_MOVE,onStageMouseMoveFunc);
      }
      
      public function get enabled() : Boolean
      {
         return tabEnabled;
      }
      
      private function checkMouseForActivePixelChange(... rest) : void
      {
         var _loc2_:Point = null;
         _loc2_ = getPixelFromMouseLocation();
         if(_loc2_.x != -1 && (_loc2_.x != _activePixel.x || _loc2_.y != _activePixel.y))
         {
            activePixel = _loc2_;
         }
      }
      
      private function onStageMouseDown(... rest) : void
      {
         _mouseIsDown = true;
      }
      
      private function onDisplayRollOver(... rest) : void
      {
         _mouseIsOver = true;
         if(!_mouseIsDown)
         {
            checkMouseForActivePixelChange();
            stage.focus = this;
         }
         else if(stage.focus == null)
         {
            checkMouseForActivePixelChange();
            stage.focus = this;
         }
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
         checkMouseForActivePixelChange();
         redrawDisplay();
      }
      
      public function clearCustomMarkings(... rest) : void
      {
         _customMarkingsSP.graphics.clear();
      }
      
      public function set displayWidth(param1:Number) : void
      {
         if(param1 <= 0 || param1 > 1000)
         {
            return;
         }
         _displayWidth = param1;
         redrawBackground();
      }
      
      private function onFocusOut(param1:FocusEvent) : void
      {
         clearActivePixel();
         _focusRectSP.visible = false;
         stage.removeEventListener("keyDown",onStageKeyDownFunc);
         stage.removeEventListener(MouseEvent.MOUSE_MOVE,onStageMouseMoveFunc);
      }
      
      public function set enabled(param1:Boolean) : void
      {
         if(!tabEnabled && param1)
         {
            stage.addEventListener(MouseEvent.MOUSE_DOWN,onStageMouseDown);
            stage.addEventListener(MouseEvent.MOUSE_UP,onStageMouseUp);
            addEventListener(MouseEvent.ROLL_OVER,onDisplayRollOver);
            addEventListener(MouseEvent.ROLL_OUT,onDisplayRollOut);
            addEventListener(FocusEvent.FOCUS_IN,onFocusIn);
            addEventListener(FocusEvent.FOCUS_OUT,onFocusOut);
            addEventListener(FocusEvent.KEY_FOCUS_CHANGE,onKeyFocusChanged);
         }
         else if(tabEnabled && !param1)
         {
            stage.removeEventListener(MouseEvent.MOUSE_DOWN,onStageMouseDown);
            stage.removeEventListener(MouseEvent.MOUSE_UP,onStageMouseUp);
            removeEventListener(MouseEvent.ROLL_OVER,onDisplayRollOver);
            removeEventListener(MouseEvent.ROLL_OUT,onDisplayRollOut);
            removeEventListener(FocusEvent.FOCUS_IN,onFocusIn);
            removeEventListener(FocusEvent.FOCUS_OUT,onFocusOut);
            removeEventListener(FocusEvent.KEY_FOCUS_CHANGE,onKeyFocusChanged);
         }
         tabEnabled = param1;
      }
      
      public function get displayHeight() : Number
      {
         return _displayHeight;
      }
      
      public function clearActivePixel() : void
      {
         activePixel = new Point(-1,-1);
      }
      
      public function redrawBackground() : void
      {
         var _loc1_:BitmapData = null;
         var _loc2_:Number = NaN;
         _loc1_ = new BitmapData(4,4);
         _loc1_.setPixel(0,0,10526880);
         _loc1_.setPixel(0,1,10526880);
         _loc1_.setPixel(1,0,10526880);
         _loc1_.setPixel(1,1,10526880);
         _loc1_.setPixel(2,2,10526880);
         _loc1_.setPixel(2,3,10526880);
         _loc1_.setPixel(3,2,10526880);
         _loc1_.setPixel(3,3,10526880);
         _loc1_.setPixel(2,0,14342874);
         _loc1_.setPixel(2,1,14342874);
         _loc1_.setPixel(3,0,14342874);
         _loc1_.setPixel(3,1,14342874);
         _loc1_.setPixel(0,2,14342874);
         _loc1_.setPixel(1,2,14342874);
         _loc1_.setPixel(0,3,14342874);
         _loc1_.setPixel(1,3,14342874);
         graphics.clear();
         graphics.beginBitmapFill(_loc1_);
         graphics.drawRect(0,0,_displayWidth,_displayHeight);
         graphics.endFill();
         _customMarkingsMaskSP.graphics.clear();
         _customMarkingsMaskSP.graphics.beginFill(16711680,1);
         _customMarkingsMaskSP.graphics.drawRect(0,0,_displayWidth,_displayHeight);
         _customMarkingsMaskSP.graphics.endFill();
         _loc2_ = focusRectMargin;
         _focusRectSP.graphics.clear();
         _focusRectSP.graphics.lineStyle(focusRectLineThickness,focusRectLineColor);
         _focusRectSP.graphics.drawRect(-_loc2_,-_loc2_,_displayWidth + 2 * _loc2_,_displayHeight + 2 * _loc2_);
      }
      
      public function set activePixel(param1:Point) : void
      {
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         _loc2_ = param1.x;
         _loc3_ = param1.y;
         if(!isFinite(_loc2_) || !isFinite(_loc3_) || isNaN(_loc2_) || isNaN(_loc3_))
         {
            return;
         }
         if(!(_loc2_ == -1 && _loc3_ == -1))
         {
            if(_loc2_ < 0)
            {
               _loc2_ = 0;
            }
            else if(_loc2_ >= _pixelWidth)
            {
               _loc2_ = _pixelWidth - 1;
            }
            if(_loc3_ < 0)
            {
               _loc3_ = 0;
            }
            else if(_loc3_ >= _pixelHeight)
            {
               _loc3_ = _pixelHeight - 1;
            }
         }
         _activePixel.x = int(_loc2_);
         _activePixel.y = int(_loc3_);
         drawPixelOutline();
         dispatchEvent(new Event("activePixelChanged"));
      }
      
      private function onStageMouseUp(... rest) : void
      {
         _mouseIsDown = false;
         if(stage.focus != this && _mouseIsOver)
         {
            checkMouseForActivePixelChange();
            stage.focus = this;
         }
      }
      
      public function set displaySize(param1:Number) : void
      {
         if(param1 <= 0 || param1 > 1000)
         {
            return;
         }
         _displayWidth = param1;
         _displayHeight = param1;
         redrawBackground();
      }
      
      public function redrawDisplay(... rest) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         _displaySP.graphics.clear();
         if(_pixelArray == null)
         {
            return;
         }
         _loc4_ = _displayWidth / _pixelWidth;
         _loc5_ = _displayHeight / _pixelHeight;
         _loc2_ = 0;
         while(_loc2_ < _pixelWidth)
         {
            _loc3_ = 0;
            while(_loc3_ < _pixelHeight)
            {
               _loc6_ = 1 - ((_pixelArray[_loc2_][_loc3_] & 0xFF000000) >> 24 & 0xFF) / 255;
               _displaySP.graphics.beginFill(0xFFFFFF & _pixelArray[_loc2_][_loc3_],_loc6_);
               _displaySP.graphics.drawRect(_loc2_ * _loc4_,_loc3_ * _loc5_,_loc4_,_loc5_);
               _displaySP.graphics.endFill();
               _loc3_++;
            }
            _loc2_++;
         }
      }
      
      public function drawPixelOutline(... rest) : void
      {
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         _activePixelSP.graphics.clear();
         if(_activePixel.x == -1)
         {
            return;
         }
         _loc2_ = _displayWidth / _pixelWidth;
         _loc3_ = _displayHeight / _pixelHeight;
         _activePixelSP.graphics.lineStyle(activePixelOutlineThickness,activePixelOutlineColor,1);
         _activePixelSP.graphics.drawRect(_loc2_ * _activePixel.x,_loc3_ * _activePixel.y,_loc2_,_loc3_);
      }
      
      private function onStageMouseMoveFunc(param1:MouseEvent) : void
      {
         checkMouseForActivePixelChange();
         param1.updateAfterEvent();
      }
      
      public function set pixelArray(param1:Array) : void
      {
         var _loc2_:uint = 0;
         var _loc3_:uint = 0;
         var _loc4_:uint = 0;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:Array = null;
         if(!(param1 is Array) || param1.length == 0)
         {
            trace("error setting pixelArray, type 1: argument must be non-empty array");
            return;
         }
         _loc2_ = param1.length;
         if(!(param1[0] is Array) || param1[0].length == 0)
         {
            trace("error setting pixelArray, type 2: argument must be non-empty 2D array");
            return;
         }
         _loc3_ = uint(param1[0].length);
         _loc7_ = [];
         _loc5_ = 0;
         while(_loc5_ < _loc2_)
         {
            if(!(param1[_loc5_] is Array) || param1[_loc5_].length != _loc3_)
            {
               trace("error setting pixelArray, type 3: varying dimensions or invalid types in array");
               return;
            }
            _loc7_[_loc5_] = [];
            _loc6_ = 0;
            while(_loc6_ < _loc3_)
            {
               _loc7_[_loc5_][_loc6_] = uint(param1[_loc5_][_loc6_]);
               _loc6_++;
            }
            _loc5_++;
         }
         _pixelWidth = _loc2_;
         _pixelHeight = _loc3_;
         _pixelArray = _loc7_;
         redrawDisplay();
      }
      
      private function onKeyFocusChanged(param1:FocusEvent) : void
      {
         if(param1.keyCode >= 37 && param1.keyCode <= 40)
         {
            param1.preventDefault();
         }
      }
   }
}

