package stellarHabitableZone004_fla
{
   import adobe.utils.*;
   import fl.controls.Button;
   import fl.controls.CheckBox;
   import fl.controls.ComboBox;
   import fl.controls.RadioButton;
   import fl.controls.RadioButtonGroup;
   import fl.data.DataProvider;
   import fl.data.SimpleCollectionItem;
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
      
      public var distanceField:TextField;
      
      public var j1:*;
      
      public var veil:Veil;
      
      public var loader:URLLoader;
      
      public var solarSystemList:Array;
      
      public var initStarMassSlider:ProtoSimpleSlider;
      
      public var runTimerLastTime:Number;
      
      public const optimisticOuterSHZLimit:Number = 1.5;
      
      public var timePlanetTidallyLocked:Number;
      
      public var timeField:TextField;
      
      public var collObj1:DataProvider;
      
      public var veilFadeTimer:Timer;
      
      public var runPauseButton:Button;
      
      public var timeline:SHZTimeline;
      
      public var showRefOrbitsCheckbox:CheckBox;
      
      public var habitabilityPlot:SHZHabitabilityPlot;
      
      public var pessimisticRadioButton:RadioButton;
      
      public var dragDistance:Number;
      
      public var veilFadeStart:Number;
      
      public var lumField:TextField;
      
      public var defaultDistance:Number;
      
      public var optimisticRadioButton:RadioButton;
      
      public const pessimisticInnerSHZLimit:Number = 0.95;
      
      public var systemHistory:SHZSystemHistory;
      
      public var initDistanceSlider:ProtoSimpleSlider;
      
      public var minPlanetDistanceAtTimeZero:Number;
      
      public var hrDiagram:SHZHRDiagram;
      
      public var innerSHZLimit:Number;
      
      public var massField:TextField;
      
      public var i:int;
      
      public var maxPlanetDistanceAtTimeZero:Number;
      
      public var runSpeedSlider:ProtoSimpleSliderRunSpeed;
      
      public var runTimer:Timer;
      
      public var tempField:TextField;
      
      public var radiusField:TextField;
      
      public var selectedStar:Object;
      
      public var outerSHZLimit:Number;
      
      public const pessimisticOuterSHZLimit:Number = 1.37;
      
      public var veilFadeTime:Number;
      
      public var starsList:Array;
      
      public var collProp1:Object;
      
      public var selectedSystem:Object;
      
      public var systemComboBox:ComboBox;
      
      public var minPlanetDistance:Number;
      
      public var titlebar:NAAPTitleBar;
      
      public var showGridCheckbox:CheckBox;
      
      public var defaultStarMass:Number;
      
      public var itemObj1:SimpleCollectionItem;
      
      public var timePlanetDestroyed:Number;
      
      public var diagram:SHZDiagram;
      
      public var collProps1:Array;
      
      public var loadingDisplay:Loading;
      
      public var i1:int;
      
      public var systemsList:Array;
      
      public var assumptionsRadioGroup:RadioButtonGroup;
      
      public const optimisticInnerSHZLimit:Number = 0.8;
      
      public function MainTimeline()
      {
         super();
         addFrameScript(0,frame1);
         __setProp_showRefOrbitsCheckbox_Scene1_Layer3_0();
         __setProp_showGridCheckbox_Scene1_Layer5_0();
         __setProp_pessimisticRadioButton_Scene1_Layer1_0();
         __setProp_optimisticRadioButton_Scene1_Layer1_0();
         __setProp_runPauseButton_Scene1_Layer11_0();
         __setProp_systemComboBox_Scene1_Layer11_0();
         __setProp_titlebar_Scene1_titlebar_0();
      }
      
      internal function __setProp_systemComboBox_Scene1_Layer11_0() : *
      {
         try
         {
            systemComboBox["componentInspectorSetting"] = true;
         }
         catch(e:Error)
         {
         }
         collObj1 = new DataProvider();
         collProps1 = [];
         i1 = 0;
         while(i1 < collProps1.length)
         {
            itemObj1 = new SimpleCollectionItem();
            collProp1 = collProps1[i1];
            for(j1 in collProp1)
            {
               itemObj1[j1] = collProp1[j1];
            }
            collObj1.addItem(itemObj1);
            ++i1;
         }
         systemComboBox.dataProvider = collObj1;
         systemComboBox.editable = false;
         systemComboBox.enabled = true;
         systemComboBox.prompt = "";
         systemComboBox.restrict = "";
         systemComboBox.rowCount = 15;
         systemComboBox.visible = true;
         try
         {
            systemComboBox["componentInspectorSetting"] = false;
         }
         catch(e:Error)
         {
         }
      }
      
      public function getSHZTemp(param1:Number, param2:Number) : Number
      {
         var _loc4_:int = 0;
         var _loc3_:Array = selectedStar.dataTable;
         _loc4_ = 1;
         while(_loc4_ < _loc3_.length)
         {
            if(param2 < _loc3_[_loc4_].time)
            {
               break;
            }
            _loc4_++;
         }
         if(_loc4_ >= _loc3_.length)
         {
            _loc4_ = _loc3_.length - 1;
         }
         var _loc5_:Object = _loc3_[_loc4_ - 1];
         var _loc6_:Object = _loc3_[_loc4_];
         var _loc7_:Number = (param2 - _loc5_.time) / (_loc6_.time - _loc5_.time);
         if(_loc7_ < -0.0001 || _loc7_ > 1.0001)
         {
            trace("WARNING, invalid u in getSHZTemp, u: " + _loc7_);
         }
         var _loc8_:Number = 1 - (param1 - _loc5_.shzInner) / (_loc5_.shzOuter - _loc5_.shzInner);
         var _loc9_:Number = 1 - (param1 - _loc6_.shzInner) / (_loc6_.shzOuter - _loc6_.shzInner);
         return _loc8_ + _loc7_ * (_loc9_ - _loc8_);
      }
      
      internal function __setProp_pessimisticRadioButton_Scene1_Layer1_0() : *
      {
         try
         {
            pessimisticRadioButton["componentInspectorSetting"] = true;
         }
         catch(e:Error)
         {
         }
         pessimisticRadioButton.enabled = true;
         pessimisticRadioButton.groupName = "assumptionsRadioGroup";
         pessimisticRadioButton.label = "pessimistic";
         pessimisticRadioButton.labelPlacement = "right";
         pessimisticRadioButton.selected = false;
         pessimisticRadioButton.value = "pessimistic";
         pessimisticRadioButton.visible = true;
         try
         {
            pessimisticRadioButton["componentInspectorSetting"] = false;
         }
         catch(e:Error)
         {
         }
      }
      
      internal function __setProp_showGridCheckbox_Scene1_Layer5_0() : *
      {
         try
         {
            showGridCheckbox["componentInspectorSetting"] = true;
         }
         catch(e:Error)
         {
         }
         showGridCheckbox.enabled = true;
         showGridCheckbox.label = "show scale grid";
         showGridCheckbox.labelPlacement = "right";
         showGridCheckbox.selected = false;
         showGridCheckbox.visible = true;
         try
         {
            showGridCheckbox["componentInspectorSetting"] = false;
         }
         catch(e:Error)
         {
         }
      }
      
      public function getData(param1:Number) : Object
      {
         var _loc3_:int = 0;
         var _loc2_:Array = selectedStar.dataTable;
         if(param1 < 0)
         {
            param1 = 0;
         }
         else if(param1 > selectedStar.timespan)
         {
            param1 = Number(selectedStar.timespan);
         }
         _loc3_ = 1;
         while(_loc3_ < _loc2_.length)
         {
            if(param1 < _loc2_[_loc3_].time)
            {
               break;
            }
            _loc3_++;
         }
         if(_loc3_ >= _loc2_.length)
         {
            _loc3_ = _loc2_.length - 1;
         }
         var _loc4_:Object = _loc2_[_loc3_ - 1];
         var _loc5_:Object = _loc2_[_loc3_];
         var _loc6_:Number = (param1 - _loc4_.time) / (_loc5_.time - _loc4_.time);
         if(_loc6_ < -0.0001 || _loc6_ > 1.0001)
         {
            trace("WARNING, invalid u, u: " + _loc6_);
         }
         var _loc7_:Object = {};
         _loc7_.time = param1;
         _loc7_.mass = _loc4_.mass + _loc6_ * (_loc5_.mass - _loc4_.mass);
         _loc7_.logRadius = _loc4_.logRadius + _loc6_ * (_loc5_.logRadius - _loc4_.logRadius);
         _loc7_.logTemp = _loc4_.logTemp + _loc6_ * (_loc5_.logTemp - _loc4_.logTemp);
         _loc7_.logLum = _loc4_.logLum + _loc6_ * (_loc5_.logLum - _loc4_.logLum);
         _loc7_.shzInner = _loc4_.shzInner + _loc6_ * (_loc5_.shzInner - _loc4_.shzInner);
         _loc7_.shzOuter = _loc4_.shzOuter + _loc6_ * (_loc5_.shzOuter - _loc4_.shzOuter);
         _loc7_.shzTemp = _loc4_.shzTemp + _loc6_ * (_loc5_.shzTemp - _loc4_.shzTemp);
         _loc7_.distance = _loc4_.distance + _loc6_ * (_loc5_.distance - _loc4_.distance);
         return _loc7_;
      }
      
      public function doneLoadingData(... rest) : void
      {
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:Array = null;
         var _loc7_:ByteArray = null;
         var _loc8_:Object = null;
         var _loc9_:Number = NaN;
         var _loc10_:Number = NaN;
         var _loc11_:Number = NaN;
         var _loc12_:Number = NaN;
         var _loc13_:Number = NaN;
         var _loc14_:Number = NaN;
         var _loc2_:ByteArray = loader.data;
         _loc2_.position = 0;
         _loc2_.uncompress();
         starsList = _loc2_.readObject() as Array;
         var _loc15_:Array = [];
         _loc3_ = 0;
         while(_loc3_ < starsList.length)
         {
            _loc6_ = [];
            _loc7_ = starsList[_loc3_].rawDataTable;
            _loc5_ = _loc7_.length / 20;
            _loc7_.position = 0;
            _loc9_ = Number.NEGATIVE_INFINITY;
            _loc10_ = Number.POSITIVE_INFINITY;
            _loc11_ = Number.NEGATIVE_INFINITY;
            _loc12_ = Number.POSITIVE_INFINITY;
            _loc13_ = Number.NEGATIVE_INFINITY;
            _loc14_ = Number.POSITIVE_INFINITY;
            _loc4_ = 0;
            while(_loc4_ < _loc5_)
            {
               _loc8_ = {};
               _loc8_.time = _loc7_.readFloat();
               _loc8_.mass = _loc7_.readFloat();
               _loc8_.logLum = _loc7_.readFloat();
               _loc8_.logRadius = _loc7_.readFloat();
               _loc8_.logTemp = _loc7_.readFloat();
               _loc8_.shzInner = 1;
               _loc8_.shzOuter = 1;
               _loc8_.shzTemp = 1;
               _loc8_.distance = 1;
               _loc6_[_loc4_] = _loc8_;
               if(_loc8_.mass > _loc13_)
               {
                  _loc13_ = Number(_loc8_.mass);
               }
               if(_loc8_.mass < _loc14_)
               {
                  _loc14_ = Number(_loc8_.mass);
               }
               if(_loc8_.logLum > _loc9_)
               {
                  _loc9_ = Number(_loc8_.logLum);
               }
               if(_loc8_.logLum < _loc10_)
               {
                  _loc10_ = Number(_loc8_.logLum);
               }
               if(_loc8_.logRadius > _loc11_)
               {
                  _loc11_ = Number(_loc8_.logRadius);
               }
               if(_loc8_.logRadius < _loc12_)
               {
                  _loc12_ = Number(_loc8_.logRadius);
               }
               _loc4_++;
            }
            starsList[_loc3_].dataTable = _loc6_;
            starsList[_loc3_].maxLogLum = _loc9_;
            starsList[_loc3_].minLogLum = _loc10_;
            starsList[_loc3_].maxLogRadius = _loc11_;
            starsList[_loc3_].minLogRadius = _loc12_;
            starsList[_loc3_].maxMass = _loc13_;
            starsList[_loc3_].minMass = _loc14_;
            _loc15_.push(starsList[_loc3_].mass);
            _loc3_++;
         }
         initStarMassSlider.setRangeType("finite set",_loc15_);
         startVeilFade();
         reset();
      }
      
      public function startVeilFade() : void
      {
         veilFadeStart = getTimer();
         veilFadeTimer.start();
         loadingDisplay.visible = false;
      }
      
      public function onPlanetDragged(param1:SHZDiagramEvent) : void
      {
         if(runTimer.running)
         {
            toggleRunningState();
         }
         var _loc2_:Number = selectedStar.mass / getData(timeline.time).mass;
         initDistanceSlider.value = param1.param / _loc2_;
         dragDistance = param1.param;
         completeDataTable2();
         update();
      }
      
      public function findTimeOfHabitabilityCrossing(param1:Object, param2:Object, param3:Number, param4:Number) : Number
      {
         var _loc10_:Number = NaN;
         var _loc11_:Number = NaN;
         var _loc12_:Number = NaN;
         var _loc13_:Number = NaN;
         var _loc5_:Number = param2.mass - param1.mass;
         var _loc6_:Number = param2.shzInner - param1.shzInner;
         var _loc7_:Number = param2.shzOuter - param1.shzOuter;
         var _loc8_:Number = 0.5;
         var _loc9_:Number = 0.25;
         if(param1.shzTemp > param2.shzTemp)
         {
            _loc9_ *= -1;
         }
         var _loc14_:int = 0;
         while(_loc14_ < 16)
         {
            _loc10_ = param3 / (param1.mass + _loc8_ * _loc5_);
            _loc11_ = param1.shzInner + _loc8_ * _loc6_;
            _loc12_ = param1.shzOuter + _loc8_ * _loc7_;
            _loc13_ = 1 - (_loc10_ - _loc11_) / (_loc12_ - _loc11_);
            if(_loc13_ < param4)
            {
               _loc8_ += _loc9_;
            }
            else
            {
               _loc8_ -= _loc9_;
            }
            _loc9_ *= 0.5;
            _loc14_++;
         }
         return param1.time + _loc8_ * (param2.time - param1.time);
      }
      
      public function getNumberString(param1:Number, param2:int) : String
      {
         var _loc4_:Number = NaN;
         var _loc3_:int = Math.floor(Math.log(param1) / Math.LN10) - (param2 - 1);
         if(_loc3_ >= 0)
         {
            _loc4_ = Math.pow(10,_loc3_);
            return String(_loc4_ * Math.round(param1 / _loc4_));
         }
         return param1.toFixed(-_loc3_);
      }
      
      public function onAssumptionsChanged(... rest) : void
      {
         if(assumptionsRadioGroup.selectedData == "optimistic")
         {
            innerSHZLimit = optimisticInnerSHZLimit;
            outerSHZLimit = optimisticOuterSHZLimit;
         }
         else if(assumptionsRadioGroup.selectedData == "pessimistic")
         {
            innerSHZLimit = pessimisticInnerSHZLimit;
            outerSHZLimit = pessimisticOuterSHZLimit;
         }
         else
         {
            trace("WARNING, illegal value in onAssumptionsChanged");
         }
         if(runTimer.running)
         {
            toggleRunningState();
         }
         completeDataTable1();
         update();
      }
      
      public function reset(... rest) : void
      {
         var _loc2_:Number = NaN;
         if(starsList != null)
         {
            _loc2_ = getTimer();
            innerSHZLimit = 1;
            outerSHZLimit = 2;
            systemComboBox.selectedIndex = 0;
            syncToSelectedSystem();
            initDistanceSlider.value = defaultDistance;
            initStarMassSlider.setValue(defaultStarMass,true);
            diagram.setPlanetDistance(defaultDistance,false);
            assumptionsRadioGroup.selectedData = "pessimistic";
            onAssumptionsChanged();
            showGridCheckbox.selected = false;
            onShowGridChanged();
            showRefOrbitsCheckbox.selected = true;
            onShowRefOrbitsChanged();
            runSpeedSlider.value = 12;
            if(runTimer.running)
            {
               toggleRunningState();
            }
            trace("reset: " + (getTimer() - _loc2_));
         }
      }
      
      internal function frame1() : *
      {
         loader = new URLLoader();
         loader.addEventListener("complete",doneLoadingData);
         loader.dataFormat = "binary";
         loader.load(new URLRequest("shzStars.dat"));
         veilFadeTime = 600;
         veilFadeTimer = new Timer(25);
         veilFadeTimer.addEventListener("timer",onVeilFadeTimerEvent);
         selectedStar = null;
         selectedSystem = null;
         timePlanetDestroyed = Number.POSITIVE_INFINITY;
         timePlanetTidallyLocked = Number.POSITIVE_INFINITY;
         minPlanetDistanceAtTimeZero = 0.01;
         maxPlanetDistanceAtTimeZero = 500;
         defaultDistance = 1;
         defaultStarMass = 1;
         minPlanetDistance = 1.5;
         solarSystemList = [{
            "e":0,
            "a":0.387,
            "ma":0.5,
            "label":"Mercury"
         },{
            "e":0,
            "a":0.723,
            "ma":3.5,
            "label":"Venus"
         },{
            "e":0,
            "a":1,
            "ma":5,
            "label":"Earth"
         },{
            "e":0,
            "a":1.524,
            "ma":2,
            "label":"Mars"
         },{
            "e":0,
            "a":5.203,
            "ma":1,
            "label":"Jupiter"
         },{
            "e":0,
            "a":9.54,
            "ma":3.5,
            "label":"Saturn"
         },{
            "e":0,
            "a":19.18,
            "ma":6,
            "label":"Uranus"
         },{
            "e":0,
            "a":30.06,
            "ma":0,
            "label":"Neptune"
         },{
            "e":0,
            "a":39.44,
            "ma":2.5,
            "label":"Pluto"
         }];
         systemsList = [{
            "name":"(none selected)",
            "mass":0,
            "planetsList":[]
         },{
            "name":"Gliese 581",
            "mass":0.31,
            "planetsList":[{
               "label":"e",
               "e":0,
               "a":0.03
            },{
               "label":"b",
               "e":0,
               "a":0.041
            },{
               "label":"c",
               "e":0.16,
               "a":0.073
            },{
               "label":"d",
               "e":0.2,
               "a":0.22
            }]
         },{
            "name":"55 Cancri A",
            "mass":0.95,
            "planetsList":[{
               "label":"e",
               "e":0.2637,
               "a":0.038
            },{
               "label":"b",
               "e":0.0159,
               "a":0.115
            },{
               "label":"c",
               "e":0.053,
               "a":0.241
            },{
               "label":"f",
               "e":0.0002,
               "a":0.785
            },{
               "label":"d",
               "e":0.0633,
               "a":5.901
            }]
         },{
            "name":"51 Pegasi",
            "mass":1.06,
            "planetsList":[{
               "label":"b",
               "e":0,
               "a":0.052
            }]
         },{
            "name":"HD 40307",
            "mass":0.75,
            "planetsList":[{
               "label":"c",
               "e":0,
               "a":0.081
            },{
               "label":"d",
               "e":0,
               "a":0.134
            },{
               "label":"b",
               "e":0,
               "a":0.47
            }]
         },{
            "name":"HD 189733",
            "mass":0.8,
            "planetsList":[{
               "label":"b",
               "e":0,
               "a":0.03099
            }]
         },{
            "name":"HD 93083",
            "mass":0.7,
            "planetsList":[{
               "label":"b",
               "e":0.14,
               "a":0.477
            }]
         }];
         titlebar.addEventListener("reset",reset);
         diagram = new SHZDiagram(966,250);
         diagram.x = 7;
         diagram.y = 37;
         addChild(diagram);
         timeline = new SHZTimeline(870);
         timeline.x = 55;
         timeline.y = 580;
         addChild(timeline);
         habitabilityPlot = new SHZHabitabilityPlot(timeline.timelineWidth,50);
         habitabilityPlot.x = timeline.x;
         habitabilityPlot.y = timeline.y + 42;
         addChild(habitabilityPlot);
         systemHistory = new SHZSystemHistory(timeline.timelineWidth,5);
         systemHistory.x = timeline.x;
         systemHistory.y = habitabilityPlot.y + 93;
         addChild(systemHistory);
         hrDiagram = new SHZHRDiagram();
         hrDiagram.x = 815;
         hrDiagram.y = 326;
         addChild(hrDiagram);
         setChildIndex(titlebar,numChildren - 1);
         veil = new Veil();
         veil.x = -1;
         veil.y = -1;
         addChild(veil);
         loadingDisplay = new Loading();
         loadingDisplay.x = 480;
         loadingDisplay.y = 350;
         addChild(loadingDisplay);
         i = 0;
         while(i < systemsList.length)
         {
            systemComboBox.addItem({
               "label":systemsList[i].name,
               "data":systemsList[i]
            });
            ++i;
         }
         systemComboBox.addEventListener("change",onSystemChanged);
         initStarMassSlider.setScalingMode("logarithmic");
         initStarMassSlider.setValueFormat("significant digits",2);
         initStarMassSlider.addEventListener("sliderChange",onInitStarMassChanged);
         timeline.addEventListener("timeChanged",onTimeChanged);
         initDistanceSlider.setScalingMode("logarithmic");
         initDistanceSlider.setValueFormat("significant digits",3);
         initDistanceSlider.setValueRange(minPlanetDistanceAtTimeZero,maxPlanetDistanceAtTimeZero);
         initDistanceSlider.addEventListener("sliderChange",onInitDistanceChanged);
         diagram.addEventListener("planetDraggingStopped",onPlanetDragged);
         diagram.addEventListener("planetDragged",onPlanetDragged);
         assumptionsRadioGroup = new RadioButtonGroup("assumptionsRadioGroup");
         optimisticRadioButton.groupName = "assumptionsRadioGroup";
         pessimisticRadioButton.groupName = "assumptionsRadioGroup";
         optimisticRadioButton.enabled = false;
         assumptionsRadioGroup.addEventListener("change",onAssumptionsChanged);
         diagram.addZone("habitableZone",1,2);
         diagram.addRefOrbitsGroup("solarSystem");
         diagram.setRefOrbitsGroup("solarSystem",solarSystemList);
         diagram.addRefOrbitsGroup("starSystem",11567104,16763904,42);
         diagram.setShowRefOrbitsGroup("starSystem",false);
         showGridCheckbox.addEventListener("change",onShowGridChanged);
         showRefOrbitsCheckbox.addEventListener("change",onShowRefOrbitsChanged);
         StyleManager.setStyle("disabledTextFormat",new TextFormat("Verdana",12,10066329));
         StyleManager.setStyle("textFormat",new TextFormat("Verdana",12,0));
         StyleManager.setStyle("embedFonts",true);
         StyleManager.setStyle("focusRectSkin",NAAP_focusRectSkin);
         runPauseButton.addEventListener("click",toggleRunningState);
         runTimer = new Timer(30);
         runTimer.addEventListener("timer",onRunTimerEvent);
         runSpeedSlider.setValueRange(0.1,20);
      }
      
      public function onShowGridChanged(... rest) : void
      {
         diagram.showGrid = showGridCheckbox.selected;
      }
      
      public function onInitDistanceChanged(... rest) : void
      {
         if(runTimer.running)
         {
            toggleRunningState();
         }
         completeDataTable2();
         update();
      }
      
      internal function __setProp_showRefOrbitsCheckbox_Scene1_Layer3_0() : *
      {
         try
         {
            showRefOrbitsCheckbox["componentInspectorSetting"] = true;
         }
         catch(e:Error)
         {
         }
         showRefOrbitsCheckbox.enabled = true;
         showRefOrbitsCheckbox.label = "show solar system orbits";
         showRefOrbitsCheckbox.labelPlacement = "right";
         showRefOrbitsCheckbox.selected = false;
         showRefOrbitsCheckbox.visible = true;
         try
         {
            showRefOrbitsCheckbox["componentInspectorSetting"] = false;
         }
         catch(e:Error)
         {
         }
      }
      
      public function completeDataTable2() : void
      {
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         var _loc10_:Number = NaN;
         var _loc11_:Number = NaN;
         var _loc13_:Number = NaN;
         var _loc14_:Number = NaN;
         var _loc16_:Number = NaN;
         var _loc17_:Number = NaN;
         var _loc28_:Object = null;
         var _loc29_:Object = null;
         var _loc30_:Number = NaN;
         var _loc1_:Array = selectedStar.dataTable;
         var _loc2_:Number = Number(selectedStar.mass);
         var _loc3_:Number = initDistanceSlider.value;
         var _loc4_:Number = _loc3_ * _loc2_;
         var _loc5_:int = 0;
         var _loc12_:Number = minPlanetDistance;
         var _loc15_:Number = Number.NaN;
         _loc16_ = _loc4_ / _loc1_[_loc5_].mass;
         _loc1_[_loc5_].distance = _loc16_;
         _loc17_ = 1 - (_loc16_ - _loc1_[_loc5_].shzInner) / (_loc1_[_loc5_].shzOuter - _loc1_[_loc5_].shzInner);
         _loc1_[_loc5_].shzTemp = _loc17_;
         if(_loc17_ < 0)
         {
            _loc6_ = -1;
         }
         else if(_loc17_ > 1)
         {
            _loc6_ = 1;
         }
         else
         {
            _loc6_ = 0;
         }
         var _loc18_:Array = [{
            "start":0,
            "end":selectedStar.timespan,
            "state":_loc6_
         }];
         _loc11_ = 696000000 * Math.pow(10,_loc1_[_loc5_].logRadius);
         _loc10_ = 1.99e+30 * _loc1_[_loc5_].mass / (4 * Math.PI * _loc11_ * _loc11_ * _loc11_ / 3);
         _loc14_ = 2.44 * Math.pow(_loc10_ / 5500,1 / 3);
         if(_loc14_ < _loc12_)
         {
            _loc14_ = _loc12_;
         }
         _loc13_ = 6.685e-12 * _loc11_ * _loc14_;
         if(_loc16_ <= _loc13_)
         {
            _loc15_ = Number(_loc1_[_loc5_].time);
         }
         var _loc19_:Number = 6.67e-11;
         var _loc20_:Number = 149600000000;
         var _loc21_:Number = 100;
         var _loc22_:Number = 2 * Math.PI / (24 * 60 * 60);
         var _loc23_:Number = 6.0e+24;
         var _loc24_:Number = Math.pow(6370000,3);
         var _loc25_:Number = 2e+30 * 2e+30 * _loc2_ * _loc2_;
         var _loc26_:Number = Math.pow(_loc20_ * _loc3_,6);
         var _loc27_:Number = _loc21_ * _loc22_ * _loc23_ * _loc26_ / (_loc19_ * _loc25_ * _loc24_);
         _loc27_ = _loc27_ / (60 * 60 * 24 * 365 * 1000000);
         _loc5_ = 1;
         while(_loc5_ < _loc1_.length)
         {
            _loc16_ = _loc4_ / _loc1_[_loc5_].mass;
            _loc1_[_loc5_].distance = _loc16_;
            _loc17_ = 1 - (_loc16_ - _loc1_[_loc5_].shzInner) / (_loc1_[_loc5_].shzOuter - _loc1_[_loc5_].shzInner);
            _loc1_[_loc5_].shzTemp = _loc17_;
            if(_loc17_ < 0)
            {
               _loc7_ = -1;
            }
            else if(_loc17_ > 1)
            {
               _loc7_ = 1;
            }
            else
            {
               _loc7_ = 0;
            }
            if(isNaN(_loc15_))
            {
               _loc11_ = 696000000 * Math.pow(10,_loc1_[_loc5_].logRadius);
               _loc10_ = 1.99e+30 * _loc1_[_loc5_].mass / (4 * Math.PI * _loc11_ * _loc11_ * _loc11_ / 3);
               _loc14_ = 2.44 * Math.pow(_loc10_ / 5500,1 / 3);
               if(_loc14_ < _loc12_)
               {
                  _loc14_ = _loc12_;
               }
               _loc13_ = 6.685e-12 * _loc11_ * _loc14_;
               if(_loc16_ <= _loc13_)
               {
                  _loc15_ = Number(_loc1_[_loc5_].time);
               }
            }
            if(_loc7_ != _loc6_)
            {
               _loc28_ = _loc1_[_loc5_ - 1];
               _loc29_ = _loc1_[_loc5_];
               if(_loc6_ == 0 && _loc7_ == 1)
               {
                  _loc30_ = findTimeOfHabitabilityCrossing(_loc28_,_loc29_,_loc4_,1);
                  _loc18_[_loc18_.length - 1].end = _loc30_;
                  _loc18_.push({
                     "start":_loc30_,
                     "end":selectedStar.timespan,
                     "state":_loc7_
                  });
               }
               else if(_loc6_ == 0 && _loc7_ == -1)
               {
                  _loc30_ = findTimeOfHabitabilityCrossing(_loc28_,_loc29_,_loc4_,0);
                  _loc18_[_loc18_.length - 1].end = _loc30_;
                  _loc18_.push({
                     "start":_loc30_,
                     "end":selectedStar.timespan,
                     "state":_loc7_
                  });
               }
               else if(_loc6_ == 1 && _loc7_ == 0)
               {
                  _loc30_ = findTimeOfHabitabilityCrossing(_loc28_,_loc29_,_loc4_,1);
                  _loc18_[_loc18_.length - 1].end = _loc30_;
                  _loc18_.push({
                     "start":_loc30_,
                     "end":selectedStar.timespan,
                     "state":_loc7_
                  });
               }
               else if(_loc6_ == -1 && _loc7_ == 0)
               {
                  _loc30_ = findTimeOfHabitabilityCrossing(_loc28_,_loc29_,_loc4_,0);
                  _loc18_[_loc18_.length - 1].end = _loc30_;
                  _loc18_.push({
                     "start":_loc30_,
                     "end":selectedStar.timespan,
                     "state":_loc7_
                  });
               }
               else if(_loc6_ == 1 && _loc7_ == -1)
               {
                  _loc30_ = findTimeOfHabitabilityCrossing(_loc28_,_loc29_,_loc4_,1);
                  _loc18_[_loc18_.length - 1].end = _loc30_;
                  _loc18_.push({
                     "start":_loc30_,
                     "end":selectedStar.timespan,
                     "state":0
                  });
                  _loc30_ = findTimeOfHabitabilityCrossing(_loc28_,_loc29_,_loc4_,0);
                  _loc18_[_loc18_.length - 1].end = _loc30_;
                  _loc18_.push({
                     "start":_loc30_,
                     "end":selectedStar.timespan,
                     "state":_loc7_
                  });
               }
               else if(_loc6_ == -1 && _loc7_ == 1)
               {
                  _loc30_ = findTimeOfHabitabilityCrossing(_loc28_,_loc29_,_loc4_,0);
                  _loc18_[_loc18_.length - 1].end = _loc30_;
                  _loc18_.push({
                     "start":_loc30_,
                     "end":selectedStar.timespan,
                     "state":0
                  });
                  _loc30_ = findTimeOfHabitabilityCrossing(_loc28_,_loc29_,_loc4_,1);
                  _loc18_[_loc18_.length - 1].end = _loc30_;
                  _loc18_.push({
                     "start":_loc30_,
                     "end":selectedStar.timespan,
                     "state":_loc7_
                  });
               }
               else
               {
                  trace("WARNING, impossible case in completeDataTable2");
               }
            }
            _loc6_ = _loc7_;
            _loc5_++;
         }
         timePlanetDestroyed = isNaN(_loc15_) ? Number.POSITIVE_INFINITY : _loc15_;
         timePlanetTidallyLocked = isNaN(_loc27_) ? Number.POSITIVE_INFINITY : _loc27_;
         if(timePlanetTidallyLocked * timeline.timelineWidth / selectedStar.timespan < 4)
         {
            timePlanetTidallyLocked = 0;
         }
         habitabilityPlot.plotDataTable(selectedStar.dataTable,selectedStar.timespan,timePlanetDestroyed);
         systemHistory.update({
            "planetDestroyed":timePlanetDestroyed,
            "planetLocked":timePlanetTidallyLocked,
            "statesList":_loc18_,
            "star":selectedStar
         });
      }
      
      internal function __setProp_runPauseButton_Scene1_Layer11_0() : *
      {
         try
         {
            runPauseButton["componentInspectorSetting"] = true;
         }
         catch(e:Error)
         {
         }
         runPauseButton.emphasized = false;
         runPauseButton.enabled = true;
         runPauseButton.label = "run";
         runPauseButton.labelPlacement = "right";
         runPauseButton.selected = false;
         runPauseButton.toggle = false;
         runPauseButton.visible = true;
         try
         {
            runPauseButton["componentInspectorSetting"] = false;
         }
         catch(e:Error)
         {
         }
      }
      
      public function completeDataTable1() : void
      {
         var _loc2_:Number = NaN;
         var _loc1_:Array = selectedStar.dataTable;
         var _loc3_:int = 0;
         while(_loc3_ < _loc1_.length)
         {
            _loc2_ = Math.sqrt(Math.pow(10,_loc1_[_loc3_].logLum));
            _loc1_[_loc3_].shzInner = _loc2_ * innerSHZLimit;
            _loc1_[_loc3_].shzOuter = _loc2_ * outerSHZLimit;
            _loc3_++;
         }
         completeDataTable2();
      }
      
      public function onRunTimerEvent(param1:TimerEvent) : void
      {
         var _loc2_:Number = getTimer();
         var _loc3_:Number = timeline.time + selectedStar.timespan / 50000000 * runSpeedSlider.value * 1000 * (_loc2_ - runTimerLastTime);
         if(_loc3_ > selectedStar.timespan)
         {
            _loc3_ = Number(selectedStar.timespan);
            toggleRunningState();
         }
         timeline.setTime(_loc3_,true);
         runTimerLastTime = _loc2_;
      }
      
      public function toggleRunningState(... rest) : void
      {
         if(runTimer.running)
         {
            runTimer.stop();
            runPauseButton.label = "run";
         }
         else
         {
            runTimer.start();
            runTimerLastTime = getTimer();
            runPauseButton.label = "pause";
         }
      }
      
      public function onTimeChanged(... rest) : void
      {
         update();
      }
      
      public function update() : void
      {
         var _loc4_:Array = null;
         var _loc5_:int = 0;
         var _loc1_:Object = getData(timeline.time);
         var _loc2_:Number = selectedStar.mass / _loc1_.mass;
         diagram.setPlanetDragLimits(_loc2_ * initDistanceSlider.min,_loc2_ * initDistanceSlider.max);
         diagram.setStarRadiusAndTemperature(Math.pow(10,_loc1_.logRadius),Math.pow(10,_loc1_.logTemp));
         var _loc3_:Object = selectedStar.epochsList[selectedStar.epochsList.length - 1];
         if(timeline.time >= _loc3_.time && _loc3_.type >= 14)
         {
            diagram.showZones = false;
            diagram.showStar = false;
         }
         else
         {
            diagram.setZoneRange("habitableZone",_loc1_.shzInner,_loc1_.shzOuter);
            diagram.showZones = true;
            diagram.showStar = true;
         }
         if(selectedSystem != null && diagram.planetBeingDragged)
         {
            diagram.setPlanetDistance(dragDistance);
            diagram.setPlanetState(timeline.time >= timePlanetDestroyed,timeline.time >= timePlanetTidallyLocked,getSHZTemp(dragDistance,timeline.time));
         }
         else
         {
            diagram.setPlanetDistance(_loc2_ * initDistanceSlider.value);
            diagram.setPlanetState(timeline.time >= timePlanetDestroyed,timeline.time >= timePlanetTidallyLocked,getData(timeline.time).shzTemp);
         }
         if(selectedSystem != null)
         {
            diagram.setShowRefOrbitsGroup("starSystem",true);
            _loc4_ = [];
            _loc5_ = 0;
            while(_loc5_ < selectedSystem.planetsList.length)
            {
               _loc4_[_loc5_] = {
                  "label":selectedSystem.planetsList[_loc5_].label,
                  "e":selectedSystem.planetsList[_loc5_].e,
                  "a":_loc2_ * selectedSystem.planetsList[_loc5_].a
               };
               _loc5_++;
            }
            diagram.setRefOrbitsGroup("starSystem",_loc4_);
            diagram.setHighlightedRefOrbit("starSystem",initDistanceSlider.getValueIndex());
         }
         else
         {
            diagram.setHighlightedRefOrbit("starSystem",-1);
         }
         diagram.update();
         habitabilityPlot.setCursorTime(timeline.time,selectedStar.timespan);
         systemHistory.setCursorTime(timeline.time,selectedStar.timespan);
         timeField.text = timeline.getTimeString();
         massField.text = getNumberString(_loc1_.mass,3) + " Msun";
         if(_loc1_.logLum < -5)
         {
            lumField.text = "0 Lsun";
         }
         else
         {
            lumField.text = getNumberString(Math.pow(10,_loc1_.logLum),3) + " Lsun";
         }
         radiusField.text = getNumberString(Math.pow(10,_loc1_.logRadius),3) + " Rsun";
         tempField.text = getNumberString(Math.pow(10,_loc1_.logTemp),3) + " K";
         distanceField.text = getNumberString(_loc1_.distance,3) + " AU";
         hrDiagram.update(selectedStar,_loc1_);
      }
      
      public function syncToSelectedSystem() : void
      {
         var _loc1_:Array = null;
         var _loc2_:int = 0;
         selectedSystem = systemComboBox.selectedItem.data;
         if(selectedSystem.mass == 0)
         {
            selectedSystem = null;
         }
         if(selectedSystem != null)
         {
            diagram.setShowRefOrbitsGroup("starSystem",true);
            _loc1_ = [];
            _loc2_ = 0;
            while(_loc2_ < selectedSystem.planetsList.length)
            {
               _loc1_[_loc2_] = selectedSystem.planetsList[_loc2_].a * (1 - selectedSystem.planetsList[_loc2_].e);
               _loc2_++;
            }
            initDistanceSlider.setRangeType("finite set",_loc1_);
            initStarMassSlider.setValue(selectedSystem.mass,true);
            initStarMassSlider.setEnabled(false);
         }
         else
         {
            diagram.setShowRefOrbitsGroup("starSystem",false);
            initDistanceSlider.setRangeType("continuous");
            initDistanceSlider.setValueRange(minPlanetDistanceAtTimeZero,maxPlanetDistanceAtTimeZero);
            initStarMassSlider.setEnabled(true);
         }
      }
      
      public function onInitStarMassChanged(... rest) : void
      {
         var _loc2_:int = 0;
         while(_loc2_ < starsList.length)
         {
            if(Math.abs(starsList[_loc2_].mass - initStarMassSlider.value) < 1e-10)
            {
               selectedStar = starsList[_loc2_];
               break;
            }
            _loc2_++;
         }
         if(_loc2_ >= starsList.length)
         {
            selectedStar = null;
            trace("WARNING, couldn\'t find star in onInitStarMassChanged");
            return;
         }
         if(runTimer.running)
         {
            toggleRunningState();
         }
         timeline.reset(selectedStar);
         completeDataTable1();
         update();
      }
      
      public function onVeilFadeTimerEvent(param1:TimerEvent) : void
      {
         var _loc2_:Number = (getTimer() - veilFadeStart) / veilFadeTime;
         if(_loc2_ > 1)
         {
            _loc2_ = 1;
            veil.visible = false;
            veilFadeTimer.stop();
         }
         else
         {
            veil.alpha = 1 - _loc2_;
         }
      }
      
      public function onShowRefOrbitsChanged(... rest) : void
      {
         diagram.setShowRefOrbitsGroup("solarSystem",showRefOrbitsCheckbox.selected);
      }
      
      internal function __setProp_titlebar_Scene1_titlebar_0() : *
      {
         try
         {
            titlebar["componentInspectorSetting"] = true;
         }
         catch(e:Error)
         {
         }
         titlebar.aboutContent = "About";
         titlebar.enabled = true;
         titlebar.helpContent = "";
         titlebar.title = "Circumstellar Habitable Zone Simulator";
         titlebar.visible = true;
         try
         {
            titlebar["componentInspectorSetting"] = false;
         }
         catch(e:Error)
         {
         }
      }
      
      public function onSystemChanged(... rest) : void
      {
         syncToSelectedSystem();
         update();
      }
      
      internal function __setProp_optimisticRadioButton_Scene1_Layer1_0() : *
      {
         try
         {
            optimisticRadioButton["componentInspectorSetting"] = true;
         }
         catch(e:Error)
         {
         }
         optimisticRadioButton.enabled = true;
         optimisticRadioButton.groupName = "assumptionsRadioGroup";
         optimisticRadioButton.label = "optimistic";
         optimisticRadioButton.labelPlacement = "right";
         optimisticRadioButton.selected = false;
         optimisticRadioButton.value = "optimistic";
         optimisticRadioButton.visible = true;
         try
         {
            optimisticRadioButton["componentInspectorSetting"] = false;
         }
         catch(e:Error)
         {
         }
      }
   }
}

