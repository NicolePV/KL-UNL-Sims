package
{
   import flash.display.Graphics;
   import flash.display.Sprite;
   
   public class SHZSystemHistory extends Sprite
   {
      
      protected var _cursorSP:Sprite;
      
      protected var _height:Number;
      
      protected var _width:Number;
      
      protected var _margin:Number = 2;
      
      protected var _barSP:Sprite;
      
      protected var _starDeathTag:SHZSystemHistoryTag;
      
      protected var _planetDestroyedTag:SHZSystemHistoryTag;
      
      protected var _planetLockedTag:SHZSystemHistoryTag;
      
      protected var _endMainSeqTag:SHZSystemHistoryTag;
      
      public function SHZSystemHistory(param1:Number, param2:Number)
      {
         super();
         _width = param1;
         _height = param2;
         _planetLockedTag = new SHZSystemHistoryTag("below","planet becomes\ntidally locked");
         _planetLockedTag.y = _height + _margin;
         addChild(_planetLockedTag);
         _planetDestroyedTag = new SHZSystemHistoryTag("below","planet is\ndestroyed");
         _planetDestroyedTag.y = _height + _margin;
         addChild(_planetDestroyedTag);
         _starDeathTag = new SHZSystemHistoryTag("above","star ist\nkaputt");
         _starDeathTag.y = -_margin;
         addChild(_starDeathTag);
         _endMainSeqTag = new SHZSystemHistoryTag("above","star stops\nfusing H");
         _endMainSeqTag.y = -_margin;
         addChild(_endMainSeqTag);
         _barSP = new Sprite();
         addChild(_barSP);
         _cursorSP = new Sprite();
         addChild(_cursorSP);
         _cursorSP.graphics.clear();
         _cursorSP.graphics.lineStyle(2,14692400,0.5);
         _cursorSP.graphics.moveTo(0,-1);
         _cursorSP.graphics.lineTo(0,param2 + 1);
      }
      
      public function setCursorTime(param1:Number, param2:Number) : void
      {
         _cursorSP.x = param1 * _width / param2;
      }
      
      public function update(param1:Object) : void
      {
         var _loc4_:int = 0;
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc14_:Number = NaN;
         var _loc15_:Number = NaN;
         var _loc2_:Array = param1.statesList;
         var _loc3_:Number = Number(param1.planetDestroyed);
         var _loc5_:Number = _width / param1.star.timespan;
         var _loc6_:Graphics = _barSP.graphics;
         _loc6_.clear();
         var _loc9_:uint = 10526880;
         var _loc10_:Array = [10268139,6324432,16437932];
         var _loc11_:Array = [0.3,0.9,0.3];
         _loc4_ = 0;
         while(_loc4_ < _loc2_.length)
         {
            _loc7_ = _loc5_ * _loc2_[_loc4_].start;
            if(_loc2_[_loc4_].end > _loc3_)
            {
               _loc8_ = _loc5_ * _loc3_ - _loc7_;
               _loc6_.beginFill(_loc10_[_loc2_[_loc4_].state + 1],_loc11_[_loc2_[_loc4_].state + 1]);
               _loc6_.drawRect(_loc7_,0,_loc8_,_height);
               _loc6_.endFill();
               _loc7_ = _loc5_ * _loc3_;
               _loc8_ = _width - _loc7_;
               _loc6_.beginFill(_loc9_);
               _loc6_.drawRect(_loc7_,0,_loc8_,_height);
               _loc6_.endFill();
               break;
            }
            _loc8_ = _loc5_ * _loc2_[_loc4_].end - _loc7_;
            _loc6_.beginFill(_loc10_[_loc2_[_loc4_].state + 1],_loc11_[_loc2_[_loc4_].state + 1]);
            _loc6_.drawRect(_loc7_,0,_loc8_,_height);
            _loc6_.endFill();
            _loc4_++;
         }
         var _loc12_:Array = param1.star.epochsList;
         _endMainSeqTag.x = _loc12_[1].time * _loc5_;
         _starDeathTag.x = _loc12_[_loc12_.length - 1].time * _loc5_;
         var _loc13_:int = int(_loc12_[_loc12_.length - 1].type);
         if(_loc13_ >= 10 && _loc13_ <= 12)
         {
            _starDeathTag.text = "star becomes\nwhite dwarf";
            _starDeathTag.update();
            _starDeathTag.visible = true;
         }
         else if(_loc13_ == 13)
         {
            _starDeathTag.text = "star becomes\na neutron star";
            _starDeathTag.update();
            _starDeathTag.visible = true;
         }
         else if(_loc13_ == 14)
         {
            _starDeathTag.text = "star becomes\na black hole";
            _starDeathTag.update();
            _starDeathTag.visible = true;
         }
         else if(_loc13_ == 15)
         {
            _starDeathTag.text = "star destroyed\nin supernova";
            _starDeathTag.update();
            _starDeathTag.visible = true;
         }
         else
         {
            trace("WARNING, invalid end state in SHZSystemHistory.update");
            _starDeathTag.visible = false;
         }
         if(param1.planetDestroyed < param1.star.timespan)
         {
            _planetDestroyedTag.x = param1.planetDestroyed * _loc5_;
            _planetDestroyedTag.visible = true;
         }
         else
         {
            _planetDestroyedTag.visible = false;
         }
         if(param1.planetLocked < param1.star.timespan && param1.planetLocked < param1.planetDestroyed)
         {
            _planetLockedTag.x = param1.planetLocked * _loc5_;
            _planetLockedTag.visible = true;
         }
         else
         {
            _planetLockedTag.visible = false;
         }
         var _loc16_:Number = 7;
         _loc15_ = Math.min(_loc16_,_starDeathTag.x - _endMainSeqTag.x);
         _loc14_ = _starDeathTag.x - _endMainSeqTag.x - (_endMainSeqTag.width / 2 + _starDeathTag.width / 2);
         if(_loc14_ < _loc15_)
         {
            _starDeathTag.offsetText(_starDeathTag.width / (_starDeathTag.width + _endMainSeqTag.width) * (_loc15_ - _loc14_));
            _endMainSeqTag.offsetText(-(_endMainSeqTag.width / (_starDeathTag.width + _endMainSeqTag.width)) * (_loc15_ - _loc14_));
         }
         else
         {
            _starDeathTag.offsetText(0);
            _endMainSeqTag.offsetText(0);
         }
         _loc15_ = Math.min(_loc16_,Math.abs(_planetLockedTag.x - _planetDestroyedTag.x));
         _loc14_ = Math.abs(_planetLockedTag.x - _planetDestroyedTag.x) - (_planetLockedTag.width / 2 + _planetDestroyedTag.width / 2);
         if(_planetDestroyedTag.visible && _planetLockedTag.visible && _loc14_ < _loc15_)
         {
            if(_planetLockedTag.x < _planetDestroyedTag.x)
            {
               _planetDestroyedTag.offsetText(_planetDestroyedTag.width / (_planetDestroyedTag.width + _planetLockedTag.width) * (_loc15_ - _loc14_));
               _planetLockedTag.offsetText(-(_planetLockedTag.width / (_planetDestroyedTag.width + _planetLockedTag.width)) * (_loc15_ - _loc14_));
            }
            else
            {
               _planetDestroyedTag.offsetText(-(_planetDestroyedTag.width / (_planetDestroyedTag.width + _planetLockedTag.width)) * (_loc15_ - _loc14_));
               _planetLockedTag.offsetText(_planetLockedTag.width / (_planetDestroyedTag.width + _planetLockedTag.width) * (_loc15_ - _loc14_));
            }
         }
         else
         {
            _planetDestroyedTag.offsetText(0);
            _planetLockedTag.offsetText(0);
         }
      }
   }
}

