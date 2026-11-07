package
{
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   
   public class Spectrum extends Sprite
   {
      
      protected var _maxF:Number;
      
      protected var _height:Number;
      
      protected var _width:Number;
      
      protected var _data:Array;
      
      protected var _border:Shape;
      
      protected var _background:Shape;
      
      protected var _backgroundAlpha:Number = 1;
      
      protected var _maxW:Number;
      
      protected const _minF:Number = 0;
      
      protected var _backgroundColor:uint = 16777215;
      
      protected var _borderColor:uint = 0;
      
      protected var _mask:Shape;
      
      protected var _minW:Number;
      
      protected var _borderThickness:Number = 1;
      
      protected var _borderAlpha:Number = 1;
      
      protected var _redshift:Number = 0;
      
      protected var _content:Sprite;
      
      public function Spectrum(param1:Number, param2:Number, param3:Array, param4:Number, param5:Number, param6:Number)
      {
         super();
         this._width = param1;
         this._height = param2;
         this._data = param3;
         this._minW = param4;
         this._maxW = param5;
         this._maxF = param6;
         this._background = new Shape();
         addChild(this._background);
         this._content = new Sprite();
         addChild(this._content);
         this._mask = new Shape();
         addChild(this._mask);
         this._border = new Shape();
         addChild(this._border);
         addEventListener(MouseEvent.MOUSE_MOVE,this.onMouseMoveFunc);
         this._content.mask = this._mask;
      }
      
      public function redraw() : void
      {
         this._background.graphics.clear();
         this._background.graphics.beginFill(this._backgroundColor,this._backgroundAlpha);
         this._background.graphics.drawRect(0,-this._height,this._width,this._height);
         this._background.graphics.endFill();
         this._mask.graphics.clear();
         this._mask.graphics.beginFill(16711680);
         this._mask.graphics.drawRect(0,-this._height,this._width,this._height);
         this._mask.graphics.endFill();
         this._border.graphics.clear();
         this._border.graphics.lineStyle(this._borderThickness,this._borderColor,this._borderAlpha);
         this._border.graphics.drawRect(0,-this._height,this._width,this._height);
      }
      
      protected function onMouseMoveFunc(param1:MouseEvent) : void
      {
         var _loc2_:Number = this._minW + mouseX * (this._maxW - this._minW) / this._width;
      }
      
      public function set redshift(param1:Number) : void
      {
         this._redshift = param1;
         this.redraw();
      }
      
      public function get redshift() : Number
      {
         return this._redshift;
      }
   }
}

