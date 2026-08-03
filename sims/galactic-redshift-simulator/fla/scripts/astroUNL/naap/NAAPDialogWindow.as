package astroUNL.naap
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
         this._xDraggingOffset = x - parent.mouseX;
         this._yDraggingOffset = y - parent.mouseY;
         stage.addEventListener("mouseUp",this.onMouseUpFromTitleBar);
         stage.addEventListener("mouseMove",this.onMouseMoveWithTitleBar);
      }
      
      override protected function draw() : void
      {
         var _loc1_:DisplayObject = getDisplayObjectInstance(getStyleValue("titleBarSkin"));
         if(_loc1_ != null && _loc1_ != this._currentTitleBar)
         {
            if(this._currentTitleBar != null)
            {
               this._currentTitleBar.removeEventListener("mouseDown",this.onMouseDownOnTitleBar);
               removeChild(this._currentTitleBar);
            }
            addChild(_loc1_);
            this._currentTitleBar = _loc1_;
            this._currentTitleBar.addEventListener("mouseDown",this.onMouseDownOnTitleBar);
         }
         var _loc2_:DisplayObject = getDisplayObjectInstance(getStyleValue("content"));
         if(_loc2_ != null && _loc2_ != this._currentContent)
         {
            if(this._currentContent != null)
            {
               removeChild(this._currentContent);
            }
            addChild(_loc2_);
            _width = _loc2_.width;
            this._currentContent = _loc2_;
         }
         if(_loc2_ != null)
         {
            _loc2_.y = _loc1_ != null ? _loc1_.height : 0;
         }
         if(_loc2_ != null && _loc1_ != null)
         {
            _loc1_.width = _loc2_.width;
            _height = _loc2_.height + _loc1_.height;
         }
         else
         {
            _loc1_.width = 250;
         }
         var _loc3_:TextFormat = UIComponent.getStyleDefinition().defaultTextFormat as TextFormat;
         var _loc4_:TextFormat = getStyleValue("titleTextFormat") as TextFormat;
         var _loc5_:TextFormat = _loc4_ != null ? _loc4_ : _loc3_;
         var _loc6_:Object = getStyleValue("embedFonts");
         this._titleTextField.height = 0;
         this._titleTextField.width = 0;
         this._titleTextField.text = this._title;
         this._titleTextField.setTextFormat(_loc5_);
         this._titleTextField.defaultTextFormat = _loc5_;
         if(_loc6_ != null)
         {
            this._titleTextField.embedFonts = _loc6_;
         }
         var _loc7_:Number = getStyleValue("titleSpacingMultiplier") as Number;
         this._titleTextField.y = Math.round((_loc1_.height - this._titleTextField.height) / 2);
         this._titleTextField.x = _loc7_ * this._titleTextField.y;
         setChildIndex(this._titleTextField,numChildren - 1);
         setChildIndex(this._closeButton,numChildren - 1);
         var _loc8_:DisplayObject = getDisplayObjectInstance(getStyleValue("closeButtonSkin"));
         var _loc9_:DisplayObject = getDisplayObjectInstance(getStyleValue("closeButtonIcon"));
         var _loc10_:TextFormat = getStyleValue("closeButtonTextFormat") as TextFormat;
         var _loc11_:TextFormat = _loc10_ != null ? _loc10_ : _loc3_;
         var _loc12_:Number = getStyleValue("closeButtonPadding") as Number;
         this._closeButton.setStyle("disabledSkin",_loc8_);
         this._closeButton.setStyle("downSkin",_loc8_);
         this._closeButton.setStyle("emphasizedSkin",_loc8_);
         this._closeButton.setStyle("overSkin",_loc8_);
         this._closeButton.setStyle("selectedDisabledSkin",_loc8_);
         this._closeButton.setStyle("selectedDownSkin",_loc8_);
         this._closeButton.setStyle("selectedOverSkin",_loc8_);
         this._closeButton.setStyle("selectedUpSkin",_loc8_);
         this._closeButton.setStyle("upSkin",_loc8_);
         this._closeButton.setStyle("textFormat",_loc11_);
         this._closeButton.setStyle("embedFonts",_loc6_);
         this._closeButton.setStyle("icon",_loc9_);
         this._closeButton.setStyle("textPadding",_loc12_);
         this._closeButton.setStyle("focusRectPadding",3);
         this._closeButton.drawNow();
         var _loc13_:Number = 2 * Math.floor((_loc9_.height + 2 * _loc12_) / 2) - 2;
         var _loc14_:Number = Math.ceil(_loc9_.width + 3 * _loc12_ + (this._closeButton.textField.textWidth + 4));
         this._closeButton.setSize(_loc14_,_loc13_);
         var _loc15_:Number = (_loc1_.height - _loc13_) / 2;
         this._closeButton.x = _loc1_.width - _loc14_ - _loc15_;
         this._closeButton.y = _loc15_;
         this._closeButton.drawNow();
         this.setPosition(x,y);
         super.draw();
      }
      
      protected function onMouseUpFromTitleBar(... rest) : void
      {
         stage.removeEventListener("mouseUp",this.onMouseUpFromTitleBar);
         stage.removeEventListener("mouseMove",this.onMouseMoveWithTitleBar);
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
         x = this._range.left + this._range.width / 2 - width / 2;
         y = this._range.top + this._range.height / 2 - height / 2;
      }
      
      override protected function configUI() : void
      {
         super.configUI();
         this._titleTextField = new TextField();
         this._titleTextField.mouseEnabled = false;
         this._titleTextField.type = "dynamic";
         this._titleTextField.autoSize = "left";
         this._titleTextField.selectable = false;
         addChild(this._titleTextField);
         this._closeButton = new Button();
         this._closeButton.label = "close";
         this._closeButton.tabIndex = 10;
         this._closeButton.useHandCursor = true;
         addChild(this._closeButton);
         this._closeButton.addEventListener("click",this.onCloseButtonPressed);
      }
      
      public function get title() : String
      {
         return this._title;
      }
      
      protected function onMouseMoveWithTitleBar(param1:MouseEvent) : void
      {
         this.setPosition(parent.mouseX + this._xDraggingOffset,parent.mouseY + this._yDraggingOffset,true);
         param1.updateAfterEvent();
      }
      
      public function setPosition(param1:Number, param2:Number, param3:Boolean = false) : void
      {
         var _loc5_:Number = NaN;
         var _loc4_:Number = 2;
         if(this._range != null && width > this._range.width)
         {
            x = this._range.left + this._range.width / 2 - width / 2;
         }
         else
         {
            if(param1 < this._range.left)
            {
               param1 = this._range.left;
            }
            else if(param1 > this._range.right - width)
            {
               param1 = this._range.right - width;
            }
            if(param3 && (x == this._range.left || x == this._range.right - width))
            {
               this._xDraggingOffset = param1 - parent.mouseX;
               if(this._xDraggingOffset < -width + _loc4_)
               {
                  this._xDraggingOffset = -width + _loc4_;
               }
               else if(this._xDraggingOffset > -_loc4_)
               {
                  this._xDraggingOffset = -_loc4_;
               }
            }
            x = param1;
         }
         if(this._range != null && height > this._range.height)
         {
            y = this._range.top + this._range.height / 2 - height / 2;
         }
         else
         {
            if(param2 < this._range.top)
            {
               param2 = this._range.top;
            }
            else if(param2 > this._range.bottom - height)
            {
               param2 = this._range.bottom - height;
            }
            if(param3 && (y == this._range.top || y == this._range.bottom - height))
            {
               this._yDraggingOffset = param2 - parent.mouseY;
               _loc5_ = this._currentTitleBar != null ? this._currentTitleBar.height : 0;
               if(this._yDraggingOffset < -_loc5_ + _loc4_)
               {
                  this._yDraggingOffset = -_loc5_ + _loc4_;
               }
               else if(this._yDraggingOffset > -_loc4_)
               {
                  this._yDraggingOffset = -_loc4_;
               }
            }
            y = param2;
         }
      }
      
      public function set title(param1:String) : void
      {
         this._title = param1;
         invalidate();
      }
      
      protected function onCloseButtonPressed(... rest) : void
      {
         visible = false;
      }
      
      public function set range(param1:Rectangle) : void
      {
         this._range = param1.clone();
         invalidate();
      }
      
      public function get range() : Rectangle
      {
         return this._range.clone();
      }
   }
}

