package
{
   import fl.controls.Button;
   import fl.core.UIComponent;
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.geom.Rectangle;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import flash.utils.getTimer;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol108")]
   public class NAAPTitleBar extends UIComponent
   {
      
      public static const RESET:String = "reset";
      
      private static var defaultStyles:Object = {
         "backgroundSkin":"NAAPTitleBar_backgroundSkin",
         "dialogWindowMargin":7,
         "helpContent":null,
         "aboutContent":null,
         "embedFonts":true,
         "sideSpacingMultiplier":1.6,
         "optionsSpacing":13,
         "titleTextFormat":new TextFormat("Verdana",14),
         "optionsTextFormat":new TextFormat("Verdana",12),
         "focusRectSkin":null,
         "focusRectPadding":null,
         "textFormat":null
      };
      
      protected var _background:DisplayObject;
      
      protected var _title:String = "Title";
      
      protected var _aboutWindow:NAAPDialogWindow;
      
      protected var _aboutButton:Button;
      
      protected var _resetButton:Button;
      
      protected var _allowReset:Boolean = true;
      
      protected var _helpContentClassName:String = "";
      
      protected var _helpWindow:NAAPDialogWindow;
      
      protected var _helpButton:Button;
      
      protected var _titleTextField:TextField;
      
      public function NAAPTitleBar()
      {
         super();
      }
      
      public static function getStyleDefinition() : Object
      {
         return defaultStyles;
      }
      
      override protected function draw() : void
      {
         var _loc16_:Number = NaN;
         var _loc17_:Number = NaN;
         var _loc18_:Sprite = null;
         var _loc21_:* = undefined;
         var _loc1_:Number = getTimer();
         var _loc2_:DisplayObject = getDisplayObjectInstance(getStyleValue("helpContent"));
         var _loc3_:DisplayObject = getDisplayObjectInstance(getStyleValue("aboutContent"));
         this._helpWindow.setStyle("content",_loc2_);
         this._aboutWindow.setStyle("content",_loc3_);
         var _loc4_:Number = getStyleValue("dialogWindowMargin") as Number;
         var _loc5_:* = new Rectangle(_loc4_,height + _loc4_,stage.stageWidth - 2 * _loc4_,stage.stageHeight - height - 2 * _loc4_);
         this._helpWindow.range = _loc5_;
         this._aboutWindow.range = _loc5_;
         this._helpWindow.drawNow();
         this._aboutWindow.drawNow();
         this._helpWindow.center();
         this._aboutWindow.center();
         if(_loc2_ == null)
         {
            if(contains(this._helpButton))
            {
               removeChild(this._helpButton);
            }
         }
         else if(!contains(this._helpButton))
         {
            addChild(this._helpButton);
         }
         if(_loc3_ == null)
         {
            if(contains(this._aboutButton))
            {
               removeChild(this._aboutButton);
            }
         }
         else if(!contains(this._aboutButton))
         {
            addChild(this._aboutButton);
         }
         if(this._allowReset)
         {
            addChild(this._resetButton);
         }
         else if(contains(this._resetButton))
         {
            removeChild(this._resetButton);
         }
         var _loc6_:TextFormat = UIComponent.getStyleDefinition().defaultTextFormat as TextFormat;
         var _loc7_:TextFormat = getStyleValue("titleTextFormat") as TextFormat;
         var _loc8_:TextFormat = _loc7_ != null ? _loc7_ : _loc6_;
         var _loc9_:TextFormat = getStyleValue("optionsTextFormat") as TextFormat;
         var _loc10_:TextFormat = _loc9_ != null ? _loc9_ : _loc6_;
         var _loc11_:Object = getStyleValue("embedFonts");
         this._titleTextField.height = 0;
         this._titleTextField.width = 0;
         this._titleTextField.text = this._title;
         this._titleTextField.setTextFormat(_loc8_);
         this._titleTextField.defaultTextFormat = _loc8_;
         if(_loc11_ != null)
         {
            this._titleTextField.embedFonts = _loc11_;
         }
         var _loc12_:Number = getStyleValue("sideSpacingMultiplier") as Number;
         this._titleTextField.y = Math.round((height - this._titleTextField.textHeight) / 2) - 2;
         var _loc13_:Number = _loc12_ * this._titleTextField.y;
         this._titleTextField.x = _loc13_;
         var _loc14_:Number = getStyleValue("optionsSpacing") as Number;
         var _loc15_:Number = width - _loc13_;
         var _loc19_:uint = _loc10_.color != null ? _loc10_.color as uint : 0;
         var _loc20_:Array = [this._aboutButton,this._helpButton,this._resetButton];
         for each(_loc21_ in _loc20_)
         {
            if(contains(_loc21_))
            {
               _loc21_.setStyle("textFormat",_loc10_);
               _loc21_.setStyle("embedFonts",_loc11_);
               _loc21_.drawNow();
               _loc16_ = _loc21_.textField.textWidth + 4;
               _loc17_ = _loc21_.textField.textHeight + 4;
               _loc21_.setSize(_loc16_,_loc17_);
               _loc15_ -= _loc16_;
               _loc21_.x = _loc15_;
               _loc15_ -= _loc14_;
               _loc18_ = new Sprite();
               _loc18_.graphics.lineStyle();
               _loc18_.graphics.moveTo(0,0);
               _loc18_.graphics.beginFill(16711680,0);
               _loc18_.graphics.lineTo(0,_loc17_);
               _loc18_.graphics.lineStyle(0,_loc19_);
               _loc18_.graphics.lineTo(_loc16_,_loc17_);
               _loc18_.graphics.lineStyle();
               _loc18_.graphics.lineTo(_loc16_,0);
               _loc18_.graphics.lineTo(0,0);
               _loc18_.graphics.endFill();
               _loc21_.setStyle("overSkin",_loc18_);
               _loc21_.drawNow();
            }
         }
         this._resetButton.y = this._helpButton.y = this._aboutButton.y = Math.round((height - _loc17_) / 2);
         if(this._background != null)
         {
            removeChild(this._background);
         }
         this._background = getDisplayObjectInstance(getStyleValue("backgroundSkin"));
         if(this._background != null)
         {
            addChildAt(this._background,0);
            this._background.width = width;
            this._background.height = height;
         }
         super.draw();
      }
      
      public function get allowReset() : Boolean
      {
         return this._allowReset;
      }
      
      public function set allowReset(param1:Boolean) : void
      {
         this._allowReset = param1;
      }
      
      override protected function configUI() : void
      {
         var _loc1_:Sprite = null;
         var _loc3_:* = undefined;
         super.configUI();
         this._helpWindow = new NAAPDialogWindow();
         this._aboutWindow = new NAAPDialogWindow();
         this._aboutWindow.visible = false;
         this._helpWindow.visible = false;
         addChild(this._helpWindow);
         addChild(this._aboutWindow);
         this._helpWindow.title = "Help";
         this._aboutWindow.title = "About";
         this._resetButton = new Button();
         this._helpButton = new Button();
         this._aboutButton = new Button();
         this._resetButton.label = "reset";
         this._helpButton.label = "help";
         this._aboutButton.label = "about";
         this._resetButton.tabIndex = 1;
         this._helpButton.tabIndex = 2;
         this._aboutButton.tabIndex = 3;
         var _loc2_:Array = [this._aboutButton,this._helpButton,this._resetButton];
         for each(_loc3_ in _loc2_)
         {
            _loc3_.useHandCursor = true;
            _loc3_.textField.autoSize = "left";
            _loc3_.textField.width = 0;
            _loc3_.textField.height = 0;
            _loc1_ = new Sprite();
            _loc3_.setStyle("disabledSkin",_loc1_);
            _loc3_.setStyle("downSkin",_loc1_);
            _loc3_.setStyle("emphasizedSkin",_loc1_);
            _loc3_.setStyle("overSkin",_loc1_);
            _loc3_.setStyle("selectedDisabledSkin",_loc1_);
            _loc3_.setStyle("selectedDownSkin",_loc1_);
            _loc3_.setStyle("selectedOverSkin",_loc1_);
            _loc3_.setStyle("selectedUpSkin",_loc1_);
            _loc3_.setStyle("upSkin",_loc1_);
            _loc3_.setStyle("textPadding",0);
            _loc3_.setStyle("focusRectPadding",1);
            _loc3_.addEventListener("click",this.onOptionSelected);
         }
         this._titleTextField = new TextField();
         this._titleTextField.type = "dynamic";
         this._titleTextField.autoSize = "left";
         this._titleTextField.selectable = false;
         addChild(this._titleTextField);
      }
      
      public function get title() : String
      {
         return this._title;
      }
      
      public function set aboutContent(param1:String) : void
      {
         clearStyle("aboutContent");
         setStyle("aboutContent",param1);
      }
      
      protected function onOptionSelected(param1:Event) : void
      {
         switch(param1.target)
         {
            case this._resetButton:
               dispatchEvent(new Event(NAAPTitleBar.RESET));
               this._aboutWindow.visible = false;
               this._helpWindow.visible = false;
               this._helpWindow.center();
               this._aboutWindow.center();
               break;
            case this._helpButton:
               this._aboutWindow.visible = false;
               this._helpWindow.visible = true;
               break;
            case this._aboutButton:
               this._aboutWindow.visible = true;
               this._helpWindow.visible = false;
         }
      }
      
      public function set title(param1:String) : void
      {
         this._title = param1;
         this._titleTextField.text = this._title;
      }
      
      public function set helpContent(param1:String) : void
      {
         clearStyle("helpContent");
         setStyle("helpContent",param1);
      }
   }
}

