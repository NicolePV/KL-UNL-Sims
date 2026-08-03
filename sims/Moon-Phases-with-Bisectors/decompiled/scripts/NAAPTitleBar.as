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
   
   [Embed(source="/_assets/assets.swf", symbol="symbol109")]
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
         _helpWindow.setStyle("content",_loc2_);
         _aboutWindow.setStyle("content",_loc3_);
         var _loc4_:Number = getStyleValue("dialogWindowMargin") as Number;
         var _loc5_:* = new Rectangle(_loc4_,height + _loc4_,stage.stageWidth - 2 * _loc4_,stage.stageHeight - height - 2 * _loc4_);
         _helpWindow.range = _loc5_;
         _aboutWindow.range = _loc5_;
         _helpWindow.drawNow();
         _aboutWindow.drawNow();
         _helpWindow.center();
         _aboutWindow.center();
         if(_loc2_ == null)
         {
            if(contains(_helpButton))
            {
               removeChild(_helpButton);
            }
         }
         else if(!contains(_helpButton))
         {
            addChild(_helpButton);
         }
         if(_loc3_ == null)
         {
            if(contains(_aboutButton))
            {
               removeChild(_aboutButton);
            }
         }
         else if(!contains(_aboutButton))
         {
            addChild(_aboutButton);
         }
         if(_allowReset)
         {
            addChild(_resetButton);
         }
         else if(contains(_resetButton))
         {
            removeChild(_resetButton);
         }
         var _loc6_:TextFormat = UIComponent.getStyleDefinition().defaultTextFormat as TextFormat;
         var _loc7_:TextFormat = getStyleValue("titleTextFormat") as TextFormat;
         var _loc8_:TextFormat = _loc7_ != null ? _loc7_ : _loc6_;
         var _loc9_:TextFormat = getStyleValue("optionsTextFormat") as TextFormat;
         var _loc10_:TextFormat = _loc9_ != null ? _loc9_ : _loc6_;
         var _loc11_:Object = getStyleValue("embedFonts");
         _titleTextField.height = 0;
         _titleTextField.width = 0;
         _titleTextField.text = _title;
         _titleTextField.setTextFormat(_loc8_);
         _titleTextField.defaultTextFormat = _loc8_;
         if(_loc11_ != null)
         {
            _titleTextField.embedFonts = _loc11_;
         }
         var _loc12_:Number = getStyleValue("sideSpacingMultiplier") as Number;
         _titleTextField.y = Math.round((height - _titleTextField.textHeight) / 2) - 2;
         var _loc13_:Number = _loc12_ * _titleTextField.y;
         _titleTextField.x = _loc13_;
         var _loc14_:Number = getStyleValue("optionsSpacing") as Number;
         var _loc15_:Number = width - _loc13_;
         var _loc19_:uint = _loc10_.color != null ? _loc10_.color as uint : 0;
         var _loc20_:Array = [_aboutButton,_helpButton,_resetButton];
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
         _resetButton.y = _helpButton.y = _aboutButton.y = Math.round((height - _loc17_) / 2);
         if(_background != null)
         {
            removeChild(_background);
         }
         _background = getDisplayObjectInstance(getStyleValue("backgroundSkin"));
         if(_background != null)
         {
            addChildAt(_background,0);
            _background.width = width;
            _background.height = height;
         }
         super.draw();
      }
      
      public function get allowReset() : Boolean
      {
         return _allowReset;
      }
      
      public function set allowReset(param1:Boolean) : void
      {
         _allowReset = param1;
      }
      
      override protected function configUI() : void
      {
         var _loc1_:Sprite = null;
         var _loc3_:* = undefined;
         super.configUI();
         _helpWindow = new NAAPDialogWindow();
         _aboutWindow = new NAAPDialogWindow();
         _aboutWindow.visible = false;
         _helpWindow.visible = false;
         addChild(_helpWindow);
         addChild(_aboutWindow);
         _helpWindow.title = "Help";
         _aboutWindow.title = "About";
         _resetButton = new Button();
         _helpButton = new Button();
         _aboutButton = new Button();
         _resetButton.label = "reset";
         _helpButton.label = "help";
         _aboutButton.label = "about";
         _resetButton.tabIndex = 1;
         _helpButton.tabIndex = 2;
         _aboutButton.tabIndex = 3;
         var _loc2_:Array = [_aboutButton,_helpButton,_resetButton];
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
            _loc3_.addEventListener("click",onOptionSelected);
         }
         _titleTextField = new TextField();
         _titleTextField.type = "dynamic";
         _titleTextField.autoSize = "left";
         _titleTextField.selectable = false;
         addChild(_titleTextField);
      }
      
      public function get title() : String
      {
         return _title;
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
            case _resetButton:
               dispatchEvent(new Event(NAAPTitleBar.RESET));
               _aboutWindow.visible = false;
               _helpWindow.visible = false;
               _helpWindow.center();
               _aboutWindow.center();
               break;
            case _helpButton:
               _aboutWindow.visible = false;
               _helpWindow.visible = true;
               break;
            case _aboutButton:
               _aboutWindow.visible = true;
               _helpWindow.visible = false;
         }
      }
      
      public function set title(param1:String) : void
      {
         _title = param1;
         _titleTextField.text = _title;
      }
      
      public function set helpContent(param1:String) : void
      {
         clearStyle("helpContent");
         setStyle("helpContent",param1);
      }
   }
}

