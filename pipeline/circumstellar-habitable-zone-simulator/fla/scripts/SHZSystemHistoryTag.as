package
{
   import flash.display.Graphics;
   import flash.display.Sprite;
   import flash.text.TextField;
   import flash.text.TextFormat;
   
   public class SHZSystemHistoryTag extends Sprite
   {
      
      public var color:uint = 3158064;
      
      protected var _position:String = "below";
      
      protected var _arrow:Sprite;
      
      protected var _text:TextField;
      
      public var text:String = "";
      
      public var margin:Number = 1;
      
      protected var _tf:TextFormat;
      
      public var delta:Number = 3;
      
      public function SHZSystemHistoryTag(param1:String = "below", param2:String = "", param3:uint = 3158064)
      {
         super();
         _position = param1;
         this.text = param2;
         this.color = param3;
         _arrow = new Sprite();
         addChild(_arrow);
         _tf = new TextFormat("Verdana",10,param3);
         _tf.align = "center";
         _text = new TextField();
         _text.selectable = false;
         _text.autoSize = "center";
         _text.embedFonts = true;
         _text.multiline = true;
         addChild(_text);
         update();
      }
      
      public function offsetText(param1:Number) : void
      {
         _text.x = param1 - _text.width / 2;
      }
      
      public function update() : void
      {
         _text.text = "";
         _text.defaultTextFormat = _tf;
         _text.width = 0;
         _text.height = 0;
         _text.text = text;
         var _loc1_:Graphics = _arrow.graphics;
         _loc1_.clear();
         _loc1_.moveTo(0,0);
         _loc1_.beginFill(color);
         if(_position == "above")
         {
            _loc1_.lineTo(delta,-delta);
            _loc1_.lineTo(-delta,-delta);
            _text.y = -_text.height - delta - margin;
         }
         else
         {
            _loc1_.lineTo(-delta,delta);
            _loc1_.lineTo(delta,delta);
            _text.y = delta + margin - 2;
         }
         _loc1_.lineTo(0,0);
         _loc1_.endFill();
         offsetText(0);
      }
   }
}

