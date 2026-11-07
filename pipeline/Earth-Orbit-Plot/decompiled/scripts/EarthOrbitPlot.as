package
{
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   import flash.utils.getTimer;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol91")]
   public class EarthOrbitPlot extends Sprite
   {
      
      protected var _plotHeight:Number = 400;
      
      protected var _readoutEaser:CubicEaser;
      
      protected var _xTickmarksList:Array = [];
      
      protected var _minP:Number;
      
      protected var _minR:Number;
      
      protected var _specialPointsSP:Sprite;
      
      protected var _tickmarksSP:Sprite;
      
      protected var _yTickmarksList:Array = [];
      
      protected var _readout:Readout;
      
      protected var _specialPointsList:Array = [];
      
      public const minR:Number = 6378000;
      
      protected var _xIsLog:Boolean = false;
      
      protected var _yMargin:Number = 0.05;
      
      protected var _curveSP:Sprite;
      
      protected var _xScale:Number;
      
      protected var _timer:Timer;
      
      protected var _curveColor:uint = 3316223;
      
      protected var _logMinP:Number;
      
      protected var _curveThickness:Number = 2;
      
      protected var _logMinR:Number;
      
      public const GM:Number = 398378100000000;
      
      protected var _yIsLog:Boolean = false;
      
      protected var _plotWidth:Number = 600;
      
      public const maxR:Number = 450000000;
      
      protected var _yScale:Number;
      
      public function EarthOrbitPlot()
      {
         super();
         this._readoutEaser = new CubicEaser(0);
         this.xIsLog = true;
         this.yIsLog = false;
         this._tickmarksSP = new Sprite();
         addChild(this._tickmarksSP);
         this._curveSP = new Sprite();
         addChild(this._curveSP);
         this._readout = new Readout();
         this._readout.alpha = 0;
         addChild(this._readout);
         this._specialPointsSP = new Sprite();
         addChild(this._specialPointsSP);
         stage.addEventListener(MouseEvent.MOUSE_MOVE,this.onMouseMove);
         this._timer = new Timer(30);
         this._timer.addEventListener(TimerEvent.TIMER,this.onTimerEvent);
         this._timer.start();
         this.addXTickmark(6378000);
         this.addXTickmark(10000000);
         this.addXTickmark(20000000);
         this.addXTickmark(40000000);
         this.addXTickmark(100000000);
         this.addXTickmark(200000000);
         this.addXTickmark(400000000);
         this.addYTickmark(7);
         this.addYTickmark(14);
         this.addYTickmark(21);
         this.addYTickmark(28);
         this.addYTickmark(35);
         this.addSpecialPoint(6378000,new NewtonsCannon());
         this.addSpecialPoint(6730000,new ISS());
         this.addSpecialPoint(26600000,new GPS());
         this.addSpecialPoint(42164000,new Geosynch());
         this.addSpecialPoint(384000000,new Moon());
         this.update();
      }
      
      public function set yIsLog(param1:Boolean) : void
      {
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         this._yIsLog = param1;
         var _loc2_:Number = 2 * Math.PI * Math.sqrt(this.maxR * this.maxR * this.maxR / this.GM);
         var _loc3_:Number = 2 * Math.PI * Math.sqrt(this.minR * this.minR * this.minR / this.GM);
         if(this._yIsLog)
         {
            _loc4_ = (Math.log(_loc2_) - Math.log(_loc3_)) / (1 - 2 * this._yMargin);
            this._logMinP = Math.log(_loc3_) - _loc4_ * this._yMargin;
            _loc5_ = Math.log(_loc2_) + _loc4_ * this._yMargin;
            this._yScale = -this._plotHeight / (_loc5_ - this._logMinP);
         }
         else
         {
            _loc4_ = (_loc2_ - _loc3_) / (1 - 2 * this._yMargin);
            this._minP = _loc3_ - _loc4_ * this._yMargin;
            if(this._minP < 0)
            {
               this._minP = 0;
            }
            _loc6_ = _loc2_ + _loc4_ * this._yMargin;
            this._yScale = -this._plotHeight / (_loc6_ - this._minP);
         }
      }
      
      protected function onTimerEvent(param1:TimerEvent) : void
      {
         var _loc2_:Number = getTimer();
         this._readout.alpha = this._readoutEaser.getValue(_loc2_);
         var _loc3_:int = 0;
         while(_loc3_ < this._specialPointsList.length)
         {
            this._specialPointsList[_loc3_].obj.alpha = this._specialPointsList[_loc3_].easer.getValue(_loc2_);
            _loc3_++;
         }
         param1.updateAfterEvent();
      }
      
      public function addSpecialPoint(param1:Number, param2:MovieClip) : void
      {
         var _loc6_:Number = NaN;
         this._specialPointsSP.addChild(param2);
         var _loc3_:Number = this._xIsLog ? this._xScale * (Math.log(param1) - this._logMinR) : this._xScale * (param1 - this.minR);
         var _loc4_:Number = 2 * Math.PI * Math.sqrt(param1 * param1 * param1 / this.GM);
         var _loc5_:Number = this._yIsLog ? this._yScale * (Math.log(_loc4_) - this._logMinP) : this._yScale * (_loc4_ - this._minP);
         param2.x = _loc3_;
         param2.y = _loc5_;
         param2.alpha = 0;
         graphics.lineStyle();
         graphics.beginFill(16711680);
         graphics.drawCircle(_loc3_,_loc5_,3);
         if(param2.radiusField != null)
         {
            param2.radiusField.text = (parseFloat(param1.toPrecision(3)) / 1000).toString() + " km";
         }
         if(param2.periodField != null)
         {
            if(_loc4_ <= 10800)
            {
               param2.periodField.text = parseFloat((_loc4_ / 60).toPrecision(3)).toString() + " minutes";
            }
            else if(_loc4_ <= 86400)
            {
               param2.periodField.text = parseFloat((_loc4_ / 3600).toPrecision(3)).toString() + " hours";
            }
            else
            {
               param2.periodField.text = parseFloat((_loc4_ / 86400).toPrecision(3)).toString() + " days";
            }
         }
         if(param2.velocityField != null)
         {
            _loc6_ = Math.sqrt(this.GM / param1);
            param2.velocityField.text = (parseFloat(_loc6_.toPrecision(3)) / 1000).toString() + " km/s";
         }
         this._specialPointsList.push({
            "R":param1,
            "P":_loc4_,
            "obj":param2,
            "easer":new CubicEaser(0)
         });
      }
      
      public function get xIsLog() : Boolean
      {
         return this._xIsLog;
      }
      
      public function set xIsLog(param1:Boolean) : void
      {
         this._xIsLog = param1;
         if(this._xIsLog)
         {
            this._logMinR = Math.log(this.minR);
            this._xScale = this._plotWidth / (Math.log(this.maxR) - this._logMinR);
         }
         else
         {
            this._xScale = this._plotWidth / (this.maxR - this.minR);
         }
      }
      
      public function update() : void
      {
         var _loc1_:int = 0;
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc6_:int = 0;
         this._curveSP.graphics.clear();
         this._curveSP.graphics.lineStyle(this._curveThickness,this._curveColor,1);
         _loc1_ = 0;
         _loc4_ = this._xIsLog ? Math.exp(this._logMinR + _loc1_ / this._xScale) : this.minR + _loc1_ / this._xScale;
         _loc3_ = 2 * Math.PI * Math.sqrt(_loc4_ * _loc4_ * _loc4_ / this.GM);
         _loc2_ = this._yIsLog ? this._yScale * (Math.log(_loc3_) - this._logMinP) : this._yScale * (_loc3_ - this._minP);
         this._curveSP.graphics.moveTo(_loc1_,_loc2_);
         _loc1_ = 1;
         while(_loc1_ <= this._plotWidth)
         {
            _loc4_ = this._xIsLog ? Math.exp(this._logMinR + _loc1_ / this._xScale) : this.minR + _loc1_ / this._xScale;
            _loc3_ = 2 * Math.PI * Math.sqrt(_loc4_ * _loc4_ * _loc4_ / this.GM);
            _loc2_ = this._yIsLog ? this._yScale * (Math.log(_loc3_) - this._logMinP) : this._yScale * (_loc3_ - this._minP);
            this._curveSP.graphics.lineTo(_loc1_,_loc2_);
            _loc1_++;
         }
         this._curveSP.graphics.lineStyle();
         this._curveSP.graphics.beginFill(16711680);
         _loc6_ = 0;
         while(_loc6_ < this._specialPointsList.length)
         {
            _loc4_ = Number(this._specialPointsList[_loc6_].R);
            _loc1_ = this._xIsLog ? int(this._xScale * (Math.log(_loc4_) - this._logMinR)) : int(this._xScale * (_loc4_ - this.minR));
            _loc3_ = Number(this._specialPointsList[_loc6_].P);
            _loc2_ = this._yIsLog ? this._yScale * (Math.log(_loc3_) - this._logMinP) : this._yScale * (_loc3_ - this._minP);
            this._specialPointsList[_loc6_].obj.x = _loc1_;
            this._specialPointsList[_loc6_].obj.y = _loc2_;
            this._curveSP.graphics.drawCircle(_loc1_,_loc2_,3);
            _loc6_++;
         }
         _loc6_ = 0;
         while(_loc6_ < this._yTickmarksList.length)
         {
            _loc3_ = Number(this._yTickmarksList[_loc6_].P);
            _loc2_ = this._yIsLog ? this._yScale * (Math.log(_loc3_) - this._logMinP) : this._yScale * (_loc3_ - this._minP);
            this._yTickmarksList[_loc6_].tickmark.y = _loc2_;
            _loc6_++;
         }
         _loc6_ = 0;
         while(_loc6_ < this._xTickmarksList.length)
         {
            _loc4_ = Number(this._xTickmarksList[_loc6_].R);
            _loc1_ = this._xIsLog ? int(this._xScale * (Math.log(_loc4_) - this._logMinR)) : int(this._xScale * (_loc4_ - this.minR));
            this._xTickmarksList[_loc6_].tickmark.x = _loc1_;
            _loc6_++;
         }
      }
      
      public function get yIsLog() : Boolean
      {
         return this._yIsLog;
      }
      
      public function addYTickmark(param1:Number) : void
      {
         var _loc2_:* = param1 * 24 * 60 * 60;
         var _loc3_:Number = this._yIsLog ? this._yScale * (Math.log(_loc2_) - this._logMinP) : this._yScale * (_loc2_ - this._minP);
         var _loc4_:YTickmark = new YTickmark();
         _loc4_.labelField.text = param1.toString();
         _loc4_.y = _loc3_;
         this._tickmarksSP.addChild(_loc4_);
         this._yTickmarksList.push({
            "P":_loc2_,
            "tickmark":_loc4_
         });
      }
      
      public function addXTickmark(param1:Number) : void
      {
         var _loc2_:Number = this._xIsLog ? this._xScale * (Math.log(param1) - this._logMinR) : this._xScale * (param1 - this.minR);
         var _loc3_:XTickmark = new XTickmark();
         _loc3_.labelField.text = (param1 / 1000).toString();
         _loc3_.x = _loc2_;
         this._tickmarksSP.addChild(_loc3_);
         this._xTickmarksList.push({
            "R":param1,
            "tickmark":_loc3_
         });
      }
      
      protected function onMouseMove(param1:MouseEvent) : void
      {
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc10_:Number = NaN;
         var _loc11_:Number = NaN;
         var _loc12_:Number = NaN;
         var _loc13_:Number = NaN;
         var _loc15_:Sprite = null;
         var _loc16_:int = 0;
         var _loc17_:MovieClip = null;
         var _loc20_:Number = NaN;
         var _loc9_:Number = Number.POSITIVE_INFINITY;
         _loc3_ = 0;
         while(_loc3_ <= this._plotWidth)
         {
            _loc2_ = this._xIsLog ? Math.exp(this._logMinR + _loc3_ / this._xScale) : this.minR + _loc3_ / this._xScale;
            _loc5_ = 2 * Math.PI * Math.sqrt(_loc2_ * _loc2_ * _loc2_ / this.GM);
            _loc4_ = this._yIsLog ? this._yScale * (Math.log(_loc5_) - this._logMinP) : this._yScale * (_loc5_ - this._minP);
            _loc6_ = mouseX - _loc3_;
            _loc7_ = mouseY - _loc4_;
            _loc8_ = _loc6_ * _loc6_ + _loc7_ * _loc7_;
            if(_loc8_ < _loc9_)
            {
               _loc9_ = _loc8_;
               _loc10_ = _loc3_;
               _loc12_ = _loc4_;
               _loc11_ = _loc2_;
               _loc13_ = _loc5_;
            }
            _loc3_++;
         }
         var _loc14_:Number = Number.POSITIVE_INFINITY;
         _loc16_ = 0;
         while(_loc16_ < this._specialPointsList.length)
         {
            _loc17_ = this._specialPointsList[_loc16_].obj;
            _loc6_ = _loc10_ - _loc17_.x;
            _loc7_ = _loc12_ - _loc17_.y;
            _loc8_ = _loc6_ * _loc6_ + _loc7_ * _loc7_;
            if(_loc8_ < _loc14_)
            {
               _loc14_ = _loc8_;
               _loc15_ = _loc17_;
            }
            _loc16_++;
         }
         var _loc18_:Number = getTimer();
         var _loc19_:Number = _loc18_ + 200;
         if(_loc9_ < 10000)
         {
            if(_loc14_ < 200)
            {
               this._specialPointsSP.setChildIndex(_loc15_,this._specialPointsSP.numChildren - 1);
               _loc16_ = 0;
               while(_loc16_ < this._specialPointsList.length)
               {
                  if(this._specialPointsList[_loc16_].obj != _loc15_ && this._specialPointsList[_loc16_].easer.targetValue != 0)
                  {
                     this._specialPointsList[_loc16_].easer.setTarget(_loc18_,null,_loc19_,0);
                  }
                  else if(this._specialPointsList[_loc16_].obj == _loc15_ && this._specialPointsList[_loc16_].easer.targetValue != 1)
                  {
                     this._specialPointsList[_loc16_].easer.setTarget(_loc18_,null,_loc19_,1);
                  }
                  _loc16_++;
               }
               if(this._readoutEaser.targetValue != 0)
               {
                  this._readoutEaser.setTarget(_loc18_,null,_loc19_,0);
               }
            }
            else
            {
               _loc16_ = 0;
               while(_loc16_ < this._specialPointsList.length)
               {
                  if(this._specialPointsList[_loc16_].easer.targetValue != 0)
                  {
                     this._specialPointsList[_loc16_].easer.setTarget(_loc18_,null,_loc19_,0);
                  }
                  _loc16_++;
               }
               if(this._readoutEaser.targetValue != 1)
               {
                  this._readoutEaser.setTarget(_loc18_,null,_loc19_,1);
               }
               this._readout.x = _loc10_;
               this._readout.y = _loc12_;
               this._readout.radiusField.text = (parseFloat(_loc11_.toPrecision(3)) / 1000).toString() + " km";
               if(_loc13_ <= 10800)
               {
                  this._readout.periodField.text = parseFloat((_loc13_ / 60).toPrecision(3)).toString() + " minutes";
               }
               else if(_loc13_ <= 86400)
               {
                  this._readout.periodField.text = parseFloat((_loc13_ / 3600).toPrecision(3)).toString() + " hours";
               }
               else
               {
                  this._readout.periodField.text = parseFloat((_loc13_ / 86400).toPrecision(3)).toString() + " days";
               }
               _loc20_ = Math.sqrt(this.GM / _loc11_);
               this._readout.velocityField.text = (parseFloat(_loc20_.toPrecision(3)) / 1000).toString() + " km/s";
            }
         }
         else
         {
            _loc16_ = 0;
            while(_loc16_ < this._specialPointsList.length)
            {
               if(this._specialPointsList[_loc16_].easer.targetValue != 0)
               {
                  this._specialPointsList[_loc16_].easer.setTarget(_loc18_,null,_loc19_,0);
               }
               _loc16_++;
            }
            if(this._readoutEaser.targetValue != 0)
            {
               this._readoutEaser.setTarget(_loc18_,null,_loc19_,0);
            }
         }
         param1.updateAfterEvent();
      }
   }
}

