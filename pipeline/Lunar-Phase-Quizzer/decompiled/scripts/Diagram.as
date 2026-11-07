package
{
   import astroUNL.utils.easing.CubicEaser;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   import flash.utils.getTimer;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol104")]
   public class Diagram extends Sprite
   {
      
      public static const SUNLIGHT_DRAGGED:String = "sunlightDragged";
      
      public static const MOON_DRAGGED:String = "moonDragged";
      
      public static const MODE_TRANSITION_STEP:String = "modeTransitionStep";
      
      public static const MODE_FINALIZED:String = "modeFinalized";
      
      public static const HIDE_SUNLIGHT:String = "hideSunlight";
      
      public static const HIDE_MOON:String = "hideMoon";
      
      public static const HIDE_MOON_APPEARANCE:String = "hideMoonAppearance";
      
      public static const SHOW_ALL:String = "showAll";
      
      public var firstRunInstructions:MovieClip;
      
      public var moon:Moon;
      
      protected var _moonAlphaEaser:CubicEaser;
      
      protected var _mode:String;
      
      protected var _modeTransitionStopTime:Number;
      
      protected var _modeTransitionTimer:Timer;
      
      protected var _sunlightAlphaEaser:CubicEaser;
      
      public var sunlightLocationQuestion:MovieClip;
      
      protected var _sunlightAngle:Number = 0;
      
      protected var _modeTransitionDuration:Number = 250;
      
      protected var _firstRunInstructionsTimer:Timer;
      
      protected var _phaseAngle:Number = 0;
      
      protected var _sunlightDistance:Number = 235;
      
      protected var _firstRunInstructionsAlphaEaser:CubicEaser;
      
      protected var _firstRunInstructionsTransitionDuration:Number = 400;
      
      public var sunlight:Sunlight;
      
      protected var _moonAngle:Number = 0;
      
      public var earth:MovieClip;
      
      public var moonLocationQuestion:MovieClip;
      
      protected var _moonDistance:Number = 155;
      
      public function Diagram()
      {
         super();
         this.moonLocationQuestion.alpha = 0;
         this.sunlightLocationQuestion.alpha = 0;
         this._modeTransitionTimer = new Timer(20);
         this._modeTransitionTimer.addEventListener(TimerEvent.TIMER,this.onModeTransitionTimer);
         this._moonAlphaEaser = new CubicEaser(1);
         this._sunlightAlphaEaser = new CubicEaser(1);
         this._mode = "";
         this.setMode(Diagram.SHOW_ALL,true);
         this.sunlight.diagram = this;
         this.sunlight.eventType = Diagram.SUNLIGHT_DRAGGED;
         this.sunlight.propertyName = "sunlightAngle";
         this.moon.diagram = this;
         this.moon.eventType = Diagram.MOON_DRAGGED;
         this.moon.propertyName = "moonAngle";
         this.update();
      }
      
      public function get phaseAngle() : Number
      {
         return this._phaseAngle;
      }
      
      public function get mode() : String
      {
         return this._mode;
      }
      
      public function set moonAngle(param1:Number) : void
      {
         if(this._mode == Diagram.HIDE_MOON)
         {
            return;
         }
         this._moonAngle = (param1 % (2 * Math.PI) + 2 * Math.PI) % (2 * Math.PI);
         if(this._mode == Diagram.SHOW_ALL)
         {
            this._phaseAngle = ((Math.PI + this._sunlightAngle - this._moonAngle) % (2 * Math.PI) + 2 * Math.PI) % (2 * Math.PI);
         }
         this.update();
      }
      
      public function get sunlightAngle() : Number
      {
         return this._sunlightAngle;
      }
      
      public function setMode(param1:String, param2:Boolean = false) : Boolean
      {
         var _loc3_:Number = NaN;
         if((param1 == Diagram.HIDE_SUNLIGHT || param1 == Diagram.HIDE_MOON || param1 == Diagram.HIDE_MOON_APPEARANCE || param1 == Diagram.SHOW_ALL) && param1 != this._mode)
         {
            this._mode = param1;
            if(this._mode == Diagram.HIDE_SUNLIGHT)
            {
               if(stage.focus == this.sunlight)
               {
                  stage.focus = null;
               }
               this.sunlight.mouseEnabled = this.sunlight.tabEnabled = false;
               this.moon.mouseEnabled = this.moon.tabEnabled = true;
               this.firstRunInstructions.instructionsField.text = "Drag the Moon or change the Moon\'s\rphase to change the sunlight direction.";
            }
            else if(this._mode == Diagram.HIDE_MOON)
            {
               if(stage.focus == this.moon)
               {
                  stage.focus = null;
               }
               this.sunlight.mouseEnabled = this.sunlight.tabEnabled = true;
               this.moon.mouseEnabled = this.moon.tabEnabled = false;
               this.firstRunInstructions.instructionsField.text = "Drag the sunlight arrows or change the\rMoon\'s phase to move the Moon.";
            }
            else
            {
               this.sunlight.mouseEnabled = this.sunlight.tabEnabled = true;
               this.moon.mouseEnabled = this.moon.tabEnabled = true;
               this.firstRunInstructions.instructionsField.text = "Drag the Moon or the sunlight arrows\rto change the Moon\'s phase.";
            }
            if(param2)
            {
               this.finalizeMode();
            }
            else
            {
               _loc3_ = getTimer();
               this._modeTransitionStopTime = _loc3_ + this._modeTransitionDuration;
               if(this._mode == Diagram.HIDE_SUNLIGHT)
               {
                  this._sunlightAlphaEaser.setTarget(_loc3_,null,this._modeTransitionStopTime,0);
                  this._moonAlphaEaser.setTarget(_loc3_,null,this._modeTransitionStopTime,1);
               }
               else if(this._mode == Diagram.HIDE_MOON)
               {
                  this._sunlightAlphaEaser.setTarget(_loc3_,null,this._modeTransitionStopTime,1);
                  this._moonAlphaEaser.setTarget(_loc3_,null,this._modeTransitionStopTime,0);
               }
               else
               {
                  this._sunlightAlphaEaser.setTarget(_loc3_,null,this._modeTransitionStopTime,1);
                  this._moonAlphaEaser.setTarget(_loc3_,null,this._modeTransitionStopTime,1);
               }
               if(!this._modeTransitionTimer.running)
               {
                  this._modeTransitionTimer.start();
               }
            }
            return true;
         }
         return false;
      }
      
      public function set phaseAngle(param1:Number) : void
      {
         if(this._mode == Diagram.HIDE_MOON_APPEARANCE)
         {
            return;
         }
         this._phaseAngle = (param1 % (2 * Math.PI) + 2 * Math.PI) % (2 * Math.PI);
         if(this._mode == Diagram.SHOW_ALL)
         {
            this._moonAngle = ((Math.PI + this._sunlightAngle - this._phaseAngle) % (2 * Math.PI) + 2 * Math.PI) % (2 * Math.PI);
         }
         this.update();
      }
      
      public function set mode(param1:String) : void
      {
         this.setMode(param1);
      }
      
      protected function update() : void
      {
         if(this._mode == Diagram.HIDE_SUNLIGHT)
         {
            this._sunlightAngle = ((this._phaseAngle + this._moonAngle - Math.PI) % (2 * Math.PI) + 2 * Math.PI) % (2 * Math.PI);
         }
         else if(this._mode == Diagram.HIDE_MOON)
         {
            this._moonAngle = ((Math.PI + this._sunlightAngle - this._phaseAngle) % (2 * Math.PI) + 2 * Math.PI) % (2 * Math.PI);
         }
         else if(this._mode == Diagram.HIDE_MOON_APPEARANCE)
         {
            this._phaseAngle = ((Math.PI + this._sunlightAngle - this._moonAngle) % (2 * Math.PI) + 2 * Math.PI) % (2 * Math.PI);
         }
         this.moon.x = this._moonDistance * Math.cos(this._moonAngle);
         this.moon.y = -this._moonDistance * Math.sin(this._moonAngle);
         this.moon.rotation = -this._moonAngle * 180 / Math.PI;
         this.sunlight.x = this._sunlightDistance * Math.cos(this._sunlightAngle);
         this.sunlight.y = -this._sunlightDistance * Math.sin(this._sunlightAngle);
         this.sunlight.rotation = -this._sunlightAngle * 180 / Math.PI;
         this.moon.shadow.rotation = this.sunlight.rotation - this.moon.rotation;
         this.earth.shadow.rotation = this.sunlight.rotation - this.earth.rotation;
      }
      
      public function get moonAngle() : Number
      {
         return this._moonAngle;
      }
      
      public function set sunlightAngle(param1:Number) : void
      {
         if(this._mode == Diagram.HIDE_SUNLIGHT)
         {
            return;
         }
         this._sunlightAngle = (param1 % (2 * Math.PI) + 2 * Math.PI) % (2 * Math.PI);
         if(this._mode == Diagram.SHOW_ALL)
         {
            this._phaseAngle = ((Math.PI + this._sunlightAngle - this._moonAngle) % (2 * Math.PI) + 2 * Math.PI) % (2 * Math.PI);
         }
         this.update();
      }
      
      public function hideFirstRunInstructions() : void
      {
         if(this._firstRunInstructionsTimer != null)
         {
            return;
         }
         var _loc1_:Number = getTimer();
         this._firstRunInstructionsAlphaEaser = new CubicEaser(this.firstRunInstructions.alpha);
         this._firstRunInstructionsAlphaEaser.setTarget(_loc1_,null,_loc1_ + this._firstRunInstructionsTransitionDuration,0);
         this._firstRunInstructionsTimer = new Timer(20);
         this._firstRunInstructionsTimer.addEventListener(TimerEvent.TIMER,this.onHideFirstRunInstructionsTimer);
         this._firstRunInstructionsTimer.start();
      }
      
      protected function onHideFirstRunInstructionsTimer(param1:TimerEvent) : void
      {
         var _loc2_:Number = getTimer();
         if(_loc2_ >= this._firstRunInstructionsAlphaEaser.targetTime)
         {
            this._firstRunInstructionsAlphaEaser.init(0);
            this.firstRunInstructions.alpha = 0;
            this._firstRunInstructionsTimer.stop();
         }
         else
         {
            this.firstRunInstructions.alpha = this._firstRunInstructionsAlphaEaser.getValue(_loc2_);
         }
      }
      
      public function get modeTransitionStopTime() : Number
      {
         return this._modeTransitionStopTime;
      }
      
      protected function finalizeMode() : void
      {
         if(this._mode == Diagram.HIDE_SUNLIGHT)
         {
            this._sunlightAlphaEaser.init(0);
            this._moonAlphaEaser.init(1);
            this.earth.shadow.alpha = this.moon.shadow.alpha = this.sunlight.alpha = 0;
            this.moon.alpha = 1;
         }
         else if(this._mode == Diagram.HIDE_MOON)
         {
            this._sunlightAlphaEaser.init(1);
            this._moonAlphaEaser.init(0);
            this.earth.shadow.alpha = this.moon.shadow.alpha = this.sunlight.alpha = 1;
            this.moon.alpha = 0;
         }
         else
         {
            this._sunlightAlphaEaser.init(1);
            this._moonAlphaEaser.init(1);
            this.earth.shadow.alpha = this.moon.shadow.alpha = this.sunlight.alpha = 1;
            this.moon.alpha = 1;
         }
         if(this._modeTransitionTimer.running)
         {
            this._modeTransitionTimer.stop();
         }
         this.moonLocationQuestion.alpha = 1 - this.moon.alpha;
         this.sunlightLocationQuestion.alpha = 1 - this.sunlight.alpha;
         dispatchEvent(new Event(Diagram.MODE_FINALIZED));
      }
      
      protected function onModeTransitionTimer(param1:TimerEvent) : void
      {
         var _loc2_:Number = getTimer();
         if(_loc2_ > this._sunlightAlphaEaser.targetTime)
         {
            this.finalizeMode();
         }
         else
         {
            this.earth.shadow.alpha = this.moon.shadow.alpha = this.sunlight.alpha = this._sunlightAlphaEaser.getValue(_loc2_);
            this.moon.alpha = this._moonAlphaEaser.getValue(_loc2_);
         }
         dispatchEvent(new Event(Diagram.MODE_TRANSITION_STEP));
         this.moonLocationQuestion.alpha = 1 - this.moon.alpha;
         this.sunlightLocationQuestion.alpha = 1 - this.sunlight.alpha;
         param1.updateAfterEvent();
      }
   }
}

