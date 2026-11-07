package pulsarPeriodSim001_fla
{
   import adobe.utils.*;
   import fl.controls.Button;
   import fl.controls.CheckBox;
   import fl.controls.RadioButton;
   import fl.controls.RadioButtonGroup;
   import fl.controls.Slider;
   import fl.managers.StyleManager;
   import flash.accessibility.*;
   import flash.display.*;
   import flash.errors.*;
   import flash.events.*;
   import flash.external.*;
   import flash.filters.*;
   import flash.geom.*;
   import flash.media.*;
   import flash.net.*;
   import flash.printing.*;
   import flash.profiler.*;
   import flash.sampler.*;
   import flash.system.*;
   import flash.text.*;
   import flash.ui.*;
   import flash.utils.*;
   import flash.xml.*;
   
   public dynamic class MainTimeline extends MovieClip
   {
      
      public var timerLast:Number;
      
      public var timeLast:Number;
      
      public var speedSlider:Slider;
      
      public var lastPulseTime:Number;
      
      public var motionModeRadioGroup:RadioButtonGroup;
      
      public var colorCheckBox:CheckBox;
      
      public var grayOrbit:Shape;
      
      public var coloredOrbit:Shape;
      
      public var orbitPeriod:Number;
      
      public var pulseSpeed:Number;
      
      public var stationaryRadioButton:RadioButton;
      
      public var pulsePeriod:Number;
      
      public var earth:MovieClip;
      
      public var time:Number;
      
      public var orbitX:Number;
      
      public var orbitY:Number;
      
      public var pulsarSpeed:Number;
      
      public var animationButton:Button;
      
      public var pulseList:Array;
      
      public var animating:Boolean;
      
      public var lastPulseNum:int;
      
      public var plot:IntervalsPlot;
      
      public var tmpList:Array;
      
      public var circularRadioButton:RadioButton;
      
      public var pulses:Shape;
      
      public var orbitRadius:Number;
      
      public var pulsar:Pulsar;
      
      public function MainTimeline()
      {
         super();
         addFrameScript(0,frame1);
         __setProp_colorCheckBox_Scene1_Layer1_0();
         __setProp_circularRadioButton_Scene1_Layer1_0();
         __setProp_stationaryRadioButton_Scene1_Layer1_0();
         __setProp_animationButton_Scene1_Layer1_0();
         __setProp_speedSlider_Scene1_Layer1_0();
      }
      
      internal function __setProp_circularRadioButton_Scene1_Layer1_0() : *
      {
         try
         {
            circularRadioButton["componentInspectorSetting"] = true;
         }
         catch(e:Error)
         {
         }
         circularRadioButton.enabled = true;
         circularRadioButton.groupName = "RadioButtonGroup";
         circularRadioButton.label = "circular";
         circularRadioButton.labelPlacement = "right";
         circularRadioButton.selected = false;
         circularRadioButton.value = "circular";
         circularRadioButton.visible = true;
         try
         {
            circularRadioButton["componentInspectorSetting"] = false;
         }
         catch(e:Error)
         {
         }
      }
      
      public function updateCircular() : void
      {
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         var _loc10_:uint = 0;
         var _loc11_:Number = NaN;
         var _loc12_:Number = NaN;
         var _loc13_:Number = NaN;
         var _loc14_:Number = NaN;
         var _loc15_:Number = NaN;
         var _loc18_:Number = NaN;
         var _loc19_:Number = NaN;
         var _loc20_:Number = NaN;
         var _loc23_:Number = NaN;
         var _loc24_:Number = NaN;
         var _loc25_:Number = NaN;
         var _loc27_:int = 0;
         var _loc1_:Number = getTimer();
         var _loc2_:Number = _loc1_ - timerLast;
         time += Math.exp(speedSlider.value) * _loc2_;
         var _loc3_:Number = 2 * Math.PI * time / orbitPeriod;
         var _loc4_:Number = orbitX + orbitRadius * Math.cos(_loc3_);
         var _loc5_:Number = orbitY + orbitRadius * Math.sin(_loc3_);
         var _loc6_:int = Math.floor(time / pulsePeriod);
         pulsar.x = _loc4_;
         pulsar.y = _loc5_;
         var _loc16_:Number = _loc4_ - pulsar.x;
         var _loc17_:Number = _loc5_ - pulsar.y;
         var _loc21_:Number = earth.x;
         var _loc22_:Number = earth.y;
         var _loc26_:Array = [];
         _loc27_ = lastPulseNum;
         while(_loc27_ <= _loc6_)
         {
            _loc20_ = _loc27_ * pulsePeriod;
            _loc24_ = _loc20_ - timeLast;
            _loc3_ = 2 * Math.PI * _loc20_ / orbitPeriod;
            _loc11_ = -Math.sin(_loc3_);
            _loc12_ = Math.cos(_loc3_);
            _loc18_ = orbitX + orbitRadius * Math.cos(_loc3_);
            _loc19_ = orbitY + orbitRadius * Math.sin(_loc3_);
            _loc13_ = _loc21_ - _loc18_;
            _loc14_ = _loc22_ - _loc19_;
            _loc15_ = Math.sqrt(_loc13_ * _loc13_ + _loc14_ * _loc14_);
            _loc13_ /= _loc15_;
            _loc14_ /= _loc15_;
            _loc24_ = _loc11_ * _loc13_ + _loc12_ * _loc14_;
            if(_loc24_ < 0)
            {
               _loc8_ = 128 + _loc24_ * 128;
            }
            else
            {
               _loc8_ = 128 - _loc24_ * 128;
            }
            _loc7_ = 255 - (_loc24_ + 1) / 2 * 255;
            _loc9_ = (_loc24_ + 1) / 2 * 255;
            if(_loc8_ < 0)
            {
               _loc8_ = 0;
            }
            else if(_loc8_ > 255)
            {
               _loc8_ = 255;
            }
            if(_loc7_ < 0)
            {
               _loc7_ = 0;
            }
            else if(_loc7_ > 255)
            {
               _loc7_ = 255;
            }
            if(_loc9_ < 0)
            {
               _loc9_ = 0;
            }
            else if(_loc9_ > 255)
            {
               _loc9_ = 255;
            }
            _loc10_ = uint(_loc7_ << 16 | _loc8_ << 8 | _loc9_);
            _loc25_ = Math.sqrt((_loc21_ - _loc18_) * (_loc21_ - _loc18_) + (_loc22_ - _loc19_) * (_loc22_ - _loc19_));
            _loc23_ = _loc20_ + _loc25_ / pulseSpeed;
            _loc3_ = Math.atan2(_loc22_ - _loc19_,_loc21_ - _loc18_);
            pulseList.push({
               "color":_loc10_,
               "waveDx0":3 * Math.cos(_loc3_ + Math.PI / 2),
               "waveDy0":3 * Math.sin(_loc3_ + Math.PI / 2),
               "waveDx1":3 * Math.cos(_loc3_ - Math.PI / 2),
               "waveDy1":3 * Math.sin(_loc3_ - Math.PI / 2),
               "x0":_loc18_,
               "y0":_loc19_,
               "t0":_loc20_,
               "x1":_loc21_,
               "y1":_loc22_,
               "t1":_loc23_,
               "d":_loc25_,
               "mx":(_loc21_ - _loc18_) / (_loc23_ - _loc20_),
               "my":(_loc22_ - _loc19_) / (_loc23_ - _loc20_)
            });
            if(pulseList.length > 1)
            {
               _loc26_.push({
                  "time":_loc23_,
                  "delta":_loc23_ - pulseList[pulseList.length - 2].t1,
                  "color":_loc10_
               });
            }
            _loc27_++;
         }
         plot.addData(_loc26_);
         lastPulseNum = _loc6_ + 1;
         timeLast = time;
         timerLast = _loc1_;
         drawPulses();
         plot.update(time);
      }
      
      public function updateOrbits() : void
      {
         if(motionModeRadioGroup.selectedData == "circular")
         {
            if(colorCheckBox.selected)
            {
               coloredOrbit.visible = true;
               grayOrbit.visible = false;
               plot.useColor = true;
            }
            else
            {
               coloredOrbit.visible = false;
               grayOrbit.visible = true;
               plot.useColor = false;
            }
         }
         else
         {
            coloredOrbit.visible = false;
            grayOrbit.visible = false;
         }
      }
      
      internal function __setProp_speedSlider_Scene1_Layer1_0() : *
      {
         try
         {
            speedSlider["componentInspectorSetting"] = true;
         }
         catch(e:Error)
         {
         }
         speedSlider.direction = "horizontal";
         speedSlider.enabled = true;
         speedSlider.liveDragging = false;
         speedSlider.maximum = 1.1;
         speedSlider.minimum = -2;
         speedSlider.snapInterval = 0.01;
         speedSlider.tickInterval = 0;
         speedSlider.value = -0.4;
         speedSlider.visible = true;
         try
         {
            speedSlider["componentInspectorSetting"] = false;
         }
         catch(e:Error)
         {
         }
      }
      
      public function onColorCheckBoxChanged(... rest) : void
      {
         updateOrbits();
         drawPulses();
         plot.useColor = colorCheckBox.selected;
         plot.update();
      }
      
      internal function __setProp_colorCheckBox_Scene1_Layer1_0() : *
      {
         try
         {
            colorCheckBox["componentInspectorSetting"] = true;
         }
         catch(e:Error)
         {
         }
         colorCheckBox.enabled = true;
         colorCheckBox.label = "use color coding";
         colorCheckBox.labelPlacement = "right";
         colorCheckBox.selected = false;
         colorCheckBox.visible = true;
         try
         {
            colorCheckBox["componentInspectorSetting"] = false;
         }
         catch(e:Error)
         {
         }
      }
      
      public function update(... rest) : void
      {
         if(!animating)
         {
            return;
         }
         if(motionModeRadioGroup.selectedData == "circular")
         {
            updateCircular();
         }
         else if(motionModeRadioGroup.selectedData == "stationary")
         {
            updateStationary();
         }
      }
      
      internal function __setProp_stationaryRadioButton_Scene1_Layer1_0() : *
      {
         try
         {
            stationaryRadioButton["componentInspectorSetting"] = true;
         }
         catch(e:Error)
         {
         }
         stationaryRadioButton.enabled = true;
         stationaryRadioButton.groupName = "RadioButtonGroup";
         stationaryRadioButton.label = "stationary";
         stationaryRadioButton.labelPlacement = "right";
         stationaryRadioButton.selected = true;
         stationaryRadioButton.value = "stationary";
         stationaryRadioButton.visible = true;
         try
         {
            stationaryRadioButton["componentInspectorSetting"] = false;
         }
         catch(e:Error)
         {
         }
      }
      
      public function toggleAnimationState(... rest) : void
      {
         if(animating)
         {
            animating = false;
            animationButton.label = "run";
         }
         else
         {
            animating = true;
            animationButton.label = "pause";
            timerLast = getTimer();
         }
      }
      
      public function updateStationary() : void
      {
         var _loc4_:uint = 0;
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc10_:Number = NaN;
         var _loc13_:Number = NaN;
         var _loc14_:Number = NaN;
         var _loc15_:Number = NaN;
         var _loc16_:Number = NaN;
         var _loc18_:int = 0;
         var _loc1_:Number = getTimer();
         var _loc2_:Number = _loc1_ - timerLast;
         time += Math.exp(speedSlider.value) * _loc2_;
         var _loc3_:int = Math.floor(time / pulsePeriod);
         var _loc11_:Number = earth.x;
         var _loc12_:Number = earth.y;
         var _loc17_:Array = [];
         _loc8_ = orbitX;
         _loc9_ = orbitY;
         _loc5_ = _loc11_ - _loc8_;
         _loc6_ = _loc12_ - _loc9_;
         _loc7_ = Math.sqrt(_loc5_ * _loc5_ + _loc6_ * _loc6_);
         _loc5_ /= _loc7_;
         _loc6_ /= _loc7_;
         _loc16_ = Math.sqrt((_loc11_ - _loc8_) * (_loc11_ - _loc8_) + (_loc12_ - _loc9_) * (_loc12_ - _loc9_));
         _loc14_ = Math.atan2(_loc12_ - _loc9_,_loc11_ - _loc8_);
         _loc4_ = 8421504;
         _loc18_ = lastPulseNum;
         while(_loc18_ <= _loc3_)
         {
            _loc10_ = _loc18_ * pulsePeriod;
            _loc13_ = _loc10_ + _loc16_ / pulseSpeed;
            pulseList.push({
               "color":_loc4_,
               "waveDx0":3 * Math.cos(_loc14_ + Math.PI / 2),
               "waveDy0":3 * Math.sin(_loc14_ + Math.PI / 2),
               "waveDx1":3 * Math.cos(_loc14_ - Math.PI / 2),
               "waveDy1":3 * Math.sin(_loc14_ - Math.PI / 2),
               "x0":_loc8_,
               "y0":_loc9_,
               "t0":_loc10_,
               "x1":_loc11_,
               "y1":_loc12_,
               "t1":_loc13_,
               "d":_loc16_,
               "mx":(_loc11_ - _loc8_) / (_loc13_ - _loc10_),
               "my":(_loc12_ - _loc9_) / (_loc13_ - _loc10_)
            });
            if(pulseList.length > 1)
            {
               _loc17_.push({
                  "time":_loc13_,
                  "delta":_loc13_ - pulseList[pulseList.length - 2].t1,
                  "color":_loc4_
               });
            }
            _loc18_++;
         }
         plot.addData(_loc17_);
         lastPulseNum = _loc3_ + 1;
         timeLast = time;
         timerLast = _loc1_;
         drawPulses();
         plot.update(time);
      }
      
      public function drawPulses() : void
      {
         var _loc2_:Object = null;
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc6_:int = 0;
         pulses.graphics.clear();
         var _loc1_:Number = timeLast;
         var _loc5_:Boolean = colorCheckBox.selected;
         tmpList = [];
         var _loc7_:int = int(pulseList.length);
         _loc6_ = 0;
         while(_loc6_ < _loc7_)
         {
            _loc2_ = pulseList[_loc6_];
            if(_loc1_ < _loc2_.t1)
            {
               _loc3_ = _loc2_.x0 + (_loc1_ - _loc2_.t0) * _loc2_.mx;
               _loc4_ = _loc2_.y0 + (_loc1_ - _loc2_.t0) * _loc2_.my;
               if(_loc5_)
               {
                  pulses.graphics.lineStyle(2,_loc2_.color);
               }
               else
               {
                  pulses.graphics.lineStyle(2,8421504);
               }
               pulses.graphics.moveTo(_loc3_ + _loc2_.waveDx0,_loc4_ + _loc2_.waveDy0);
               pulses.graphics.lineTo(_loc3_ + _loc2_.waveDx1,_loc4_ + _loc2_.waveDy1);
               tmpList[tmpList.length] = _loc2_;
            }
            _loc6_++;
         }
         pulseList = tmpList;
      }
      
      public function drawOrbit() : void
      {
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc10_:Number = NaN;
         var _loc11_:Number = NaN;
         var _loc12_:Number = NaN;
         var _loc13_:int = 0;
         var _loc14_:int = 0;
         var _loc15_:int = 0;
         var _loc16_:int = 0;
         var _loc1_:Number = getTimer();
         grayOrbit.graphics.clear();
         grayOrbit.graphics.lineStyle(0,10526880,0.5);
         grayOrbit.graphics.drawCircle(orbitX,orbitY,orbitRadius);
         var _loc2_:int = 600;
         var _loc3_:Number = 2 * Math.PI / _loc2_;
         var _loc4_:Number = 0;
         coloredOrbit.graphics.clear();
         _loc5_ = orbitX + orbitRadius * Math.cos(_loc4_);
         _loc6_ = orbitY + orbitRadius * Math.sin(_loc4_);
         coloredOrbit.graphics.moveTo(_loc5_,_loc6_);
         _loc16_ = 0;
         while(_loc16_ < _loc2_)
         {
            _loc4_ += _loc3_;
            _loc5_ = orbitX + orbitRadius * Math.cos(_loc4_);
            _loc6_ = orbitY + orbitRadius * Math.sin(_loc4_);
            _loc8_ = -Math.sin(_loc4_);
            _loc9_ = Math.cos(_loc4_);
            _loc10_ = earth.x - _loc5_;
            _loc11_ = earth.y - _loc6_;
            _loc12_ = Math.sqrt(_loc10_ * _loc10_ + _loc11_ * _loc11_);
            _loc10_ /= _loc12_;
            _loc11_ /= _loc12_;
            _loc7_ = _loc8_ * _loc10_ + _loc9_ * _loc11_;
            if(_loc7_ < 0)
            {
               _loc14_ = 128 + _loc7_ * 128;
            }
            else
            {
               _loc14_ = 128 - _loc7_ * 128;
            }
            _loc13_ = 255 - (_loc7_ + 1) / 2 * 255;
            _loc15_ = (_loc7_ + 1) / 2 * 255;
            if(_loc14_ < 0)
            {
               _loc14_ = 0;
            }
            else if(_loc14_ > 255)
            {
               _loc14_ = 255;
            }
            if(_loc13_ < 0)
            {
               _loc13_ = 0;
            }
            else if(_loc13_ > 255)
            {
               _loc13_ = 255;
            }
            if(_loc15_ < 0)
            {
               _loc15_ = 0;
            }
            else if(_loc15_ > 255)
            {
               _loc15_ = 255;
            }
            coloredOrbit.graphics.lineStyle(0,_loc13_ << 16 | _loc14_ << 8 | _loc15_,0.5);
            coloredOrbit.graphics.lineTo(_loc5_,_loc6_);
            _loc16_++;
         }
      }
      
      public function reset(... rest) : void
      {
         animating = false;
         toggleAnimationState();
         onColorCheckBoxChanged();
         onMotionModeChanged();
      }
      
      internal function __setProp_animationButton_Scene1_Layer1_0() : *
      {
         try
         {
            animationButton["componentInspectorSetting"] = true;
         }
         catch(e:Error)
         {
         }
         animationButton.emphasized = false;
         animationButton.enabled = true;
         animationButton.label = "pause";
         animationButton.labelPlacement = "right";
         animationButton.selected = false;
         animationButton.toggle = false;
         animationButton.visible = true;
         try
         {
            animationButton["componentInspectorSetting"] = false;
         }
         catch(e:Error)
         {
         }
      }
      
      internal function frame1() : *
      {
         pulseList = [];
         lastPulseNum = 1;
         time = 0;
         timeLast = 0;
         timerLast = getTimer();
         pulsePeriod = 250;
         pulseSpeed = 0.1;
         orbitRadius = 100;
         orbitX = 120;
         orbitY = 120;
         orbitPeriod = 12000;
         animating = false;
         coloredOrbit = new Shape();
         addChild(coloredOrbit);
         grayOrbit = new Shape();
         addChild(grayOrbit);
         pulses = new Shape();
         addChild(pulses);
         colorCheckBox.addEventListener("change",onColorCheckBoxChanged);
         animationButton.addEventListener("click",toggleAnimationState);
         addEventListener("enterFrame",update);
         motionModeRadioGroup = new RadioButtonGroup("motionModeGroup");
         stationaryRadioButton.groupName = "motionModeGroup";
         circularRadioButton.groupName = "motionModeGroup";
         motionModeRadioGroup.addEventListener("change",onMotionModeChanged);
         tmpList = [];
         drawOrbit();
         plot = new IntervalsPlot(350,180,40000);
         plot.x = 900 - plot.width - 15;
         plot.y = plot.height + 15;
         addChild(plot);
         setChildIndex(pulsar,numChildren - 1);
         pulsarSpeed = 2 * Math.PI * orbitRadius / orbitPeriod;
         plot.minDelta = pulsePeriod * (1 - 1.07 * pulsarSpeed / pulseSpeed);
         plot.maxDelta = pulsePeriod * (1 + 1.07 * pulsarSpeed / pulseSpeed);
         StyleManager.setStyle("disabledTextFormat",new TextFormat("Verdana",12,10066329));
         StyleManager.setStyle("textFormat",new TextFormat("Verdana",12,0));
         StyleManager.setStyle("embedFonts",true);
         reset();
      }
      
      public function onMotionModeChanged(... rest) : void
      {
         pulseList = [];
         lastPulseNum = 1;
         lastPulseTime = 0;
         time = 0;
         timeLast = 0;
         timerLast = getTimer();
         plot.clearData();
         plot.update();
         if(motionModeRadioGroup.selectedData == "circular")
         {
            pulsar.x = orbitX + orbitRadius;
            pulsar.y = orbitY;
         }
         else if(motionModeRadioGroup.selectedData == "stationary")
         {
            pulsar.x = orbitX;
            pulsar.y = orbitY;
         }
         else
         {
            trace("WARNING, motion mode fall-through");
         }
         drawPulses();
         updateOrbits();
         update();
      }
   }
}

