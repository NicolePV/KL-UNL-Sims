package
{
   import flash.display.Graphics;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import flash.utils.Timer;
   import flash.utils.getTimer;
   
   public class SHZTimeline extends Sprite
   {
      
      protected var _minorMargin:Number = 1.5;
      
      public var timelineWidth:Number = 750;
      
      protected var _time:Number = 0;
      
      protected var _incrementTimerStart:Number;
      
      protected var _incrementTimer:Timer;
      
      protected var _range:Number;
      
      protected var _dataTable:Array;
      
      public var timelineHeight:Number = 5;
      
      protected var _incrementTimerWait:Number = 500;
      
      protected var _labelFormat:TextFormat;
      
      protected var _marksColor:uint = 5263440;
      
      public const backgroundMarginY:Number = 2;
      
      public const backgroundMarginX:Number = 0;
      
      protected var _marksSP:Sprite;
      
      protected var _lastIncrementTime:Number;
      
      protected var _incrementRate:Number = 0.0625;
      
      protected var _backgroundSP:Sprite;
      
      protected var _cursor:SHZTimelineCursor;
      
      protected var _labelsSP:Sprite;
      
      protected var _timespan:Number = 0;
      
      public function SHZTimeline(param1:Number = 750, param2:Number = 6)
      {
         super();
         timelineWidth = param1;
         timelineHeight = param2;
         _labelFormat = new TextFormat("Verdana",12,_marksColor,false);
         _backgroundSP = new Sprite();
         addChild(_backgroundSP);
         _backgroundSP.addEventListener("mouseDown",onBackgroundMouseDown);
         _marksSP = new Sprite();
         addChild(_marksSP);
         _labelsSP = new Sprite();
         addChild(_labelsSP);
         _cursor = new SHZTimelineCursor(0,timelineWidth,this);
         _cursor.y = timelineHeight / 2;
         addChild(_cursor);
         _cursor.addEventListener("cursorDragged",onCursorDragged);
         _incrementTimer = new Timer(40);
         _incrementTimer.stop();
         _incrementTimer.addEventListener("timer",onIncrementTimer);
      }
      
      public function updateTickmarks() : void
      {
         var _loc1_:Graphics = null;
         var _loc2_:TextField = null;
         var _loc10_:int = 0;
         var _loc11_:Number = NaN;
         _loc1_ = _backgroundSP.graphics;
         _loc1_.clear();
         _loc1_.lineStyle(1,15395562);
         _loc1_.beginFill(16777215);
         _loc1_.drawRect(-backgroundMarginX,-backgroundMarginY,timelineWidth + 2 * backgroundMarginX,timelineHeight + 2 * backgroundMarginY);
         _loc1_.endFill();
         _loc1_ = _marksSP.graphics;
         _loc1_.clear();
         var _loc3_:Number = timelineWidth / _timespan;
         var _loc4_:Number = 15;
         var _loc5_:Number = 80;
         var _loc6_:Number = Math.pow(10,Math.ceil(Math.log(_loc4_ / _loc3_) / Math.LN10));
         if(_loc6_ / 2 * _loc3_ > _loc4_)
         {
            _loc6_ /= 2;
         }
         var _loc7_:* = int(Math.ceil(Math.log(_loc5_ / _loc3_) / Math.LN10));
         var _loc8_:Number = Math.pow(10,_loc7_);
         if(_loc8_ / 2 * _loc3_ > _loc5_)
         {
            _loc8_ /= 2;
            _loc7_--;
         }
         var _loc9_:int = _loc8_ / _loc6_;
         var _loc12_:Number = 0;
         _loc1_.lineStyle(1,_marksColor);
         var _loc13_:Array = [{
            "x":0,
            "label":"0"
         }];
         while(_loc12_ < _timespan)
         {
            _loc11_ = _loc3_ * _loc12_;
            if(_loc12_ % _loc8_ == 0)
            {
               if(_loc12_ != 0)
               {
                  if(_loc12_ >= 1000)
                  {
                     _loc13_.push({
                        "x":_loc11_,
                        "label":getFormattedNumber(_loc12_ / 1000,_loc7_ - 3) + " Gy"
                     });
                  }
                  else if(_loc12_ >= 1000000)
                  {
                     _loc13_.push({
                        "x":_loc11_,
                        "label":getFormattedNumber(_loc12_ / 1000000,_loc7_ - 6) + " Ty"
                     });
                  }
                  else
                  {
                     _loc13_.push({
                        "x":_loc11_,
                        "label":getFormattedNumber(_loc12_,_loc7_) + " My"
                     });
                  }
               }
               _loc1_.moveTo(_loc11_,0);
               _loc1_.lineTo(_loc11_,timelineHeight);
            }
            else
            {
               _loc1_.moveTo(_loc11_,_minorMargin);
               _loc1_.lineTo(_loc11_,timelineHeight - _minorMargin);
            }
            _loc12_ += _loc6_;
         }
         while(_labelsSP.numChildren < _loc13_.length)
         {
            _loc2_ = new TextField();
            _loc2_.defaultTextFormat = _labelFormat;
            _loc2_.selectable = false;
            _loc2_.embedFonts = false;
            _loc2_.autoSize = "left";
            _loc2_.y = timelineHeight + 3;
            _labelsSP.addChild(_loc2_);
         }
         _loc10_ = 0;
         while(_loc10_ < _loc13_.length)
         {
            _loc2_ = _labelsSP.getChildAt(_loc10_) as TextField;
            _loc2_.width = 0;
            _loc2_.height = 0;
            _loc2_.text = _loc13_[_loc10_].label;
            _loc2_.x = _loc13_[_loc10_].x - _loc2_.width / 2;
            _loc2_.visible = true;
            _loc10_++;
         }
         while(_loc10_ < _labelsSP.numChildren)
         {
            _labelsSP.getChildAt(_loc10_).visible = false;
            _loc10_++;
         }
      }
      
      public function set time(param1:Number) : void
      {
         _time = param1;
         updateCursor();
      }
      
      public function getTimeString() : String
      {
         var _loc1_:Number = _time;
         var _loc2_:Number = Math.floor(Math.log(_loc1_) / Math.LN10);
         if(_loc2_ >= 3)
         {
            return getFormattedNumber(_loc1_ / 1000,_loc2_ - 3 - 2) + " Gy";
         }
         if(_loc2_ >= 6)
         {
            return getFormattedNumber(_loc1_ / 1000000,_loc2_ - 6 - 2) + " Ty";
         }
         return getFormattedNumber(_loc1_,_loc2_ - 2) + " My";
      }
      
      public function onCursorDragged(... rest) : void
      {
         _time = _cursor.x * _timespan / timelineWidth;
         dispatchEvent(new Event("timeChanged"));
      }
      
      public function get time() : Number
      {
         return _time;
      }
      
      public function reset(param1:Object) : void
      {
         _timespan = param1.timespan;
         _dataTable = param1.dataTable;
         _time = 0;
         updateCursor();
         updateTickmarks();
      }
      
      public function onIncrementTimer(param1:TimerEvent) : void
      {
         var _loc2_:Number = getTimer();
         var _loc3_:Number = _incrementRate * (_loc2_ - _lastIncrementTime);
         if(mouseX < _cursor.x)
         {
            _loc3_ *= -1;
         }
         _lastIncrementTime = _loc2_;
         if(getTimer() < _incrementTimerStart)
         {
            return;
         }
         var _loc4_:Number = mouseX * _timespan / timelineWidth;
         if(_loc4_ < 0)
         {
            _loc4_ = 0;
         }
         else if(_loc4_ > _timespan)
         {
            _loc4_ = _timespan;
         }
         increment(_loc3_,true,_loc4_);
         param1.updateAfterEvent();
      }
      
      public function setTime(param1:Number, param2:Boolean = false) : void
      {
         _time = param1;
         updateCursor();
         dispatchEvent(new Event("timeChanged"));
      }
      
      public function increment(param1:int, param2:Boolean = false, param3:Number = 0) : void
      {
         var _loc7_:int = 0;
         var _loc11_:Number = NaN;
         if(param1 == 0)
         {
            return;
         }
         var _loc4_:Number = _timespan / timelineWidth;
         var _loc5_:Number = _time + param1 * _loc4_;
         if(_loc5_ < 0)
         {
            _loc5_ = 0;
         }
         else if(_loc5_ > _timespan)
         {
            _loc5_ = _timespan;
         }
         var _loc6_:Number = _loc5_ - _time;
         _loc7_ = 1;
         while(_loc7_ < _dataTable.length)
         {
            if(_time < _dataTable[_loc7_].time)
            {
               break;
            }
            _loc7_++;
         }
         if(--_loc7_ == _dataTable.length - 1)
         {
            if(param1 < 0)
            {
               _loc7_ += param1;
            }
         }
         else
         {
            _loc11_ = 0.1 * (_dataTable[_loc7_ + 1].time - _dataTable[_loc7_].time);
            if(_time < _dataTable[_loc7_].time + _loc11_)
            {
               _loc7_ += param1;
            }
            else if(_loc7_ < _dataTable.length - 1 && _time > _dataTable[_loc7_ + 1].time - _loc11_)
            {
               _loc7_ += param1 + 1;
            }
            else if(_loc7_ < _dataTable.length - 1)
            {
               _loc7_ += param1;
               if(param1 < 0)
               {
                  _loc7_++;
               }
            }
         }
         if(_loc7_ < 0)
         {
            _loc7_ = 0;
         }
         else if(_loc7_ >= _dataTable.length)
         {
            _loc7_ = _dataTable.length - 1;
         }
         var _loc8_:Number = Number(_dataTable[_loc7_].time);
         var _loc9_:Number = _loc8_ - _time;
         var _loc10_:Number = Math.abs(_loc6_) < Math.abs(_loc9_) ? _loc5_ : _loc8_;
         if(param2)
         {
            if(_loc10_ - 1e-12 < param3 && _time + 1e-12 > param3 || _loc10_ + 1e-12 > param3 && _time - 1e-12 < param3)
            {
               _loc10_ = param3;
            }
         }
         _time = _loc10_;
         updateCursor();
         dispatchEvent(new Event("timeChanged"));
      }
      
      public function onBackgroundMouseUp(... rest) : void
      {
         stage.removeEventListener("mouseUp",onBackgroundMouseUp);
         _incrementTimer.stop();
      }
      
      public function onBackgroundMouseDown(... rest) : void
      {
         stage.addEventListener("mouseUp",onBackgroundMouseUp);
         _incrementTimerStart = getTimer() + _incrementTimerWait;
         _incrementTimer.start();
         if(mouseX > _cursor.x)
         {
            increment(1);
         }
         else if(mouseX < _cursor.x)
         {
            increment(-1);
         }
      }
      
      protected function getFormattedNumber(param1:Number, param2:int) : String
      {
         var _loc3_:Number = NaN;
         if(param2 >= 0)
         {
            _loc3_ = Math.pow(10,param2);
            return String(_loc3_ * Math.round(param1 / _loc3_));
         }
         return param1.toFixed(-param2);
      }
      
      public function updateCursor() : void
      {
         _cursor.x = _time * timelineWidth / _timespan;
      }
   }
}

