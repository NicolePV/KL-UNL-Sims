package
{
   import fl.controls.Button;
   import fl.core.UIComponent;
   import flash.display.DisplayObject;
   import flash.events.MouseEvent;
   import flash.geom.Rectangle;
   import flash.text.TextField;
   import flash.text.TextFormat;
   
   public class NAAPDialogWindow extends UIComponent
   {
      
      private static var defaultStyles:Object = {
         "titleBarSkin":"NAAPDialogWindow_titleBarSkin",
         "titleTextFormat":new TextFormat("Verdana",12,16777215,true),
         "closeButtonIcon":"NAAPDialogWindow_closeButtonIcon",
         "closeButtonSkin":"NAAPDialogWindow_closeButtonSkin",
         "closeButtonTextFormat":new TextFormat("Verdana",10,6710886,true),
         "closeButtonPadding":4,
         "titleSpacingMultiplier":1.6,
         "content":null,
         "embedFonts":false,
         "focusRectSkin":null,
         "focusRectPadding":null,
         "textFormat":null
      };
      
      protected var _closeButton:Button;
      
      protected var _title:String = "";
      
      protected var _xDraggingOffset:Number;
      
      protected var _yDraggingOffset:Number;
      
      protected var _currentContent:DisplayObject;
      
      protected var _titleTextField:TextField;
      
      protected var _currentTitleBar:DisplayObject;
      
      protected var _range:Rectangle;
      
      public function NAAPDialogWindow()
      {
         super();
      }
      
      public static function getStyleDefinition() : Object
      {
         return defaultStyles;
      }
      
      protected function onMouseDownOnTitleBar(... rest) : void
      {
         parent.setChildIndex(this,parent.numChildren - 1);
         _xDraggingOffset = x - parent.mouseX;
         _yDraggingOffset = y - parent.mouseY;
         stage.addEventListener("mouseUp",onMouseUpFromTitleBar);
         stage.addEventListener("mouseMove",onMouseMoveWithTitleBar);
      }
      
      override protected function draw() : void
      {
         var _loc1_:DisplayObject = getDisplayObjectInstance(getStyleValue("titleBarSkin"));
         if(_loc1_ != null && _loc1_ != _currentTitleBar)
         {
            if(_currentTitleBar != null)
            {
               _currentTitleBar.removeEventListener("mouseDown",onMouseDownOnTitleBar);
               removeChild(_currentTitleBar);
            }
            addChild(_loc1_);
            _currentTitleBar = _loc1_;
            _currentTitleBar.addEventListener("mouseDown",onMouseDownOnTitleBar);
         }
         var _loc2_:DisplayObject = getDisplayObjectInstance(getStyleValue("content"));
         if(_loc2_ != null && _loc2_ != _currentContent)
         {
            if(_currentContent != null)
            {
               removeChild(_currentContent);
            }
            addChild(_loc2_);
            _width = _loc2_.width;
            _currentContent = _loc2_;
         }
         if(_loc2_ != null)
         {
            _loc2_.y = _loc1_ != null ? _loc1_.height : 0;
         }
         if(_loc1_ != null)
         {
            _loc1_.width = width;
         }
         if(_loc2_ != null && _loc1_ != null)
         {
            _height = _loc2_.height + _loc1_.height;
         }
         var _loc3_:TextFormat = UIComponent.getStyleDefinition().defaultTextFormat as TextFormat;
         var _loc4_:TextFormat = getStyleValue("titleTextFormat") as TextFormat;
         var _loc5_:TextFormat = _loc4_ != null ? _loc4_ : _loc3_;
         var _loc6_:Object = getStyleValue("embedFonts");
         _titleTextField.height = 0;
         _titleTextField.width = 0;
         _titleTextField.text = _title;
         _titleTextField.setTextFormat(_loc5_);
         _titleTextField.defaultTextFormat = _loc5_;
         if(_loc6_ != null)
         {
            _titleTextField.embedFonts = _loc6_;
         }
         var _loc7_:Number = getStyleValue("titleSpacingMultiplier") as Number;
         _titleTextField.y = Math.round((_loc1_.height - _titleTextField.height) / 2);
         _titleTextField.x = _loc7_ * _titleTextField.y;
         setChildIndex(_titleTextField,numChildren - 1);
         setChildIndex(_closeButton,numChildren - 1);
         var _loc8_:DisplayObject = getDisplayObjectInstance(getStyleValue("closeButtonSkin"));
         var _loc9_:DisplayObject = getDisplayObjectInstance(getStyleValue("closeButtonIcon"));
         var _loc10_:TextFormat = getStyleValue("closeButtonTextFormat") as TextFormat;
         var _loc11_:TextFormat = _loc10_ != null ? _loc10_ : _loc3_;
         var _loc12_:Number = getStyleValue("closeButtonPadding") as Number;
         _closeButton.setStyle("disabledSkin",_loc8_);
         _closeButton.setStyle("downSkin",_loc8_);
         _closeButton.setStyle("emphasizedSkin",_loc8_);
         _closeButton.setStyle("overSkin",_loc8_);
         _closeButton.setStyle("selectedDisabledSkin",_loc8_);
         _closeButton.setStyle("selectedDownSkin",_loc8_);
         _closeButton.setStyle("selectedOverSkin",_loc8_);
         _closeButton.setStyle("selectedUpSkin",_loc8_);
         _closeButton.setStyle("upSkin",_loc8_);
         _closeButton.setStyle("textFormat",_loc11_);
         _closeButton.setStyle("embedFonts",_loc6_);
         _closeButton.setStyle("icon",_loc9_);
         _closeButton.setStyle("textPadding",_loc12_);
         _closeButton.setStyle("focusRectPadding",3);
         _closeButton.drawNow();
         var _loc13_:Number = 2 * Math.floor((_loc9_.height + 2 * _loc12_) / 2) - 2;
         var _loc14_:Number = Math.ceil(_loc9_.width + 3 * _loc12_ + (_closeButton.textField.textWidth + 4));
         _closeButton.setSize(_loc14_,_loc13_);
         var _loc15_:Number = (_loc1_.height - _loc13_) / 2;
         _closeButton.x = _loc1_.width - _loc14_ - _loc15_;
         _closeButton.y = _loc15_;
         _closeButton.drawNow();
         setPosition(x,y);
         super.draw();
      }
      
      protected function onMouseUpFromTitleBar(... rest) : void
      {
         stage.removeEventListener("mouseUp",onMouseUpFromTitleBar);
         stage.removeEventListener("mouseMove",onMouseMoveWithTitleBar);
      }
      
      override public function set width(param1:Number) : void
      {
         throw new Error("width is read-only");
      }
      
      override public function set height(param1:Number) : void
      {
         throw new Error("height is read-only");
      }
      
      public function center() : void
      {
         x = _range.left + _range.width / 2 - width / 2;
         y = _range.top + _range.height / 2 - height / 2;
      }
      
      override protected function configUI() : void
      {
         super.configUI();
         _titleTextField = new TextField();
         _titleTextField.mouseEnabled = false;
         _titleTextField.type = "dynamic";
         _titleTextField.autoSize = "left";
         _titleTextField.selectable = false;
         addChild(_titleTextField);
         _closeButton = new Button();
         _closeButton.label = "close";
         _closeButton.tabIndex = 10;
         _closeButton.useHandCursor = true;
         addChild(_closeButton);
         _closeButton.addEventListener("click",onCloseButtonPressed);
      }
      
      public function get title() : String
      {
         return _title;
      }
      
      protected function onMouseMoveWithTitleBar(param1:MouseEvent) : void
      {
         setPosition(parent.mouseX + _xDraggingOffset,parent.mouseY + _yDraggingOffset,true);
         param1.updateAfterEvent();
      }
      
      public function setPosition(param1:Number, param2:Number, param3:Boolean = false) : void
      {
         var _loc5_:Number = NaN;
         var _loc4_:Number = 2;
         if(_range != null && width > _range.width)
         {
            x = _range.left + _range.width / 2 - width / 2;
         }
         else
         {
            if(param1 < _range.left)
            {
               param1 = _range.left;
            }
            else if(param1 > _range.right - width)
            {
               param1 = _range.right - width;
            }
            if(param3 && (x == _range.left || x == _range.right - width))
            {
               _xDraggingOffset = param1 - parent.mouseX;
               if(_xDraggingOffset < -width + _loc4_)
               {
                  _xDraggingOffset = -width + _loc4_;
               }
               else if(_xDraggingOffset > -_loc4_)
               {
                  _xDraggingOffset = -_loc4_;
               }
            }
            x = param1;
         }
         if(_range != null && height > _range.height)
         {
            y = _range.top + _range.height / 2 - height / 2;
         }
         else
         {
            if(param2 < _range.top)
            {
               param2 = _range.top;
            }
            else if(param2 > _range.bottom - height)
            {
               param2 = _range.bottom - height;
            }
            if(param3 && (y == _range.top || y == _range.bottom - height))
            {
               _yDraggingOffset = param2 - parent.mouseY;
               _loc5_ = _currentTitleBar != null ? _currentTitleBar.height : 0;
               if(_yDraggingOffset < -_loc5_ + _loc4_)
               {
                  _yDraggingOffset = -_loc5_ + _loc4_;
               }
               else if(_yDraggingOffset > -_loc4_)
               {
                  _yDraggingOffset = -_loc4_;
               }
            }
            y = param2;
         }
      }
      
      public function set title(param1:String) : void
      {
         _title = param1;
         invalidate();
      }
      
      protected function onCloseButtonPressed(... rest) : void
      {
         visible = false;
      }
      
      public function set range(param1:Rectangle) : void
      {
         _range = param1.clone();
         invalidate();
      }
      
      public function get range() : Rectangle
      {
         return _range.clone();
      }
   }
}

