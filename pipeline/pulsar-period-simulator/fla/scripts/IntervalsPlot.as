package
{
   import flash.display.Graphics;
   import flash.display.Shape;
   import flash.display.Sprite;
   
   public class IntervalsPlot extends Sprite
   {
      
      protected var _time:Number = 0;
      
      public var minDelta:Number = 1;
      
      protected var _plotHeight:Number;
      
      protected var _data:Shape;
      
      protected var _border:Shape;
      
      protected var _background:Shape;
      
      protected var _backgroundAlpha:Number = 1;
      
      protected var _dataMask:Shape;
      
      protected var _backgroundColor:uint = 16777215;
      
      protected var _borderColor:uint = 13684944;
      
      public var useColor:Boolean = true;
      
      protected var _dataList:Array = [];
      
      protected var _dataColor:uint = 8421504;
      
      protected var _tmpList:Array = [];
      
      protected var _plotWidth:Number;
      
      protected var _borderThickness:Number = 1;
      
      protected var _plotTimespan:Number;
      
      public var maxDelta:Number = 500;
      
      public function IntervalsPlot(param1:Number = 300, param2:Number = 170, param3:Number = 60000)
      {
         super();
         _plotWidth = param1;
         _plotHeight = param2;
         _plotTimespan = param3;
         _background = new Shape();
         addChild(_background);
         _data = new Shape();
         addChild(_data);
         _dataMask = new Shape();
         addChild(_dataMask);
         _border = new Shape();
         addChild(_border);
         _data.mask = _dataMask;
         _background.graphics.clear();
         _background.graphics.beginFill(_backgroundColor,_backgroundAlpha);
         _background.graphics.drawRect(0,-_plotHeight,_plotWidth,_plotHeight);
         _background.graphics.endFill();
         _dataMask.graphics.clear();
         _dataMask.graphics.beginFill(16711680);
         _dataMask.graphics.drawRect(0,-_plotHeight,_plotWidth,_plotHeight);
         _dataMask.graphics.endFill();
         _border.graphics.clear();
         _border.graphics.lineStyle(_borderThickness,_borderColor);
         _border.graphics.drawRect(0,-_plotHeight,_plotWidth,_plotHeight);
      }
      
      public function update(param1:Number = -1) : void
      {
         var _loc6_:Object = null;
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc9_:int = 0;
         if(param1 < 0)
         {
            param1 = _time;
         }
         else
         {
            _time = param1;
         }
         var _loc2_:Number = _time - _plotTimespan;
         var _loc3_:Number = _plotWidth / _plotTimespan;
         var _loc4_:Number = -_plotHeight / (maxDelta - minDelta);
         var _loc5_:Graphics = _data.graphics;
         _loc5_.clear();
         _tmpList = [];
         var _loc10_:int = int(_dataList.length);
         _loc9_ = 0;
         while(_loc9_ < _loc10_)
         {
            _loc6_ = _dataList[_loc9_];
            if(_loc6_.time >= _loc2_)
            {
               _tmpList[_tmpList.length] = _loc6_;
               if(_loc6_.time < _time)
               {
                  if(useColor)
                  {
                     _loc5_.beginFill(_loc6_.color);
                  }
                  else
                  {
                     _loc5_.beginFill(_dataColor);
                  }
                  _loc5_.drawCircle(_loc3_ * (_loc6_.time - _loc2_),_loc4_ * (_loc6_.delta - minDelta),2);
                  _loc5_.endFill();
               }
            }
            _loc9_++;
         }
         _dataList = _tmpList;
      }
      
      public function clearData() : void
      {
         _dataList = [];
      }
      
      override public function set width(param1:Number) : void
      {
         trace("fail - set plot width with constructor");
      }
      
      override public function get width() : Number
      {
         return _plotWidth;
      }
      
      public function addData(param1:Array) : void
      {
         var _loc2_:int = 0;
         while(_loc2_ < param1.length)
         {
            _dataList[_dataList.length] = param1[_loc2_];
            _loc2_++;
         }
      }
      
      override public function set height(param1:Number) : void
      {
         trace("fail - set plot width with constructor");
      }
      
      override public function get height() : Number
      {
         return _plotHeight;
      }
   }
}

