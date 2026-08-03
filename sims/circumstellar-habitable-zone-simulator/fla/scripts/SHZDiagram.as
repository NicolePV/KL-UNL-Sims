package
{
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   import flash.utils.getTimer;
   
   public class SHZDiagram extends Sprite
   {
      
      protected var _planetDragRightXHardMargin:Number = 30;
      
      protected var _zoomerFactor:Number = 1.3;
      
      protected var _easingTimer:Timer;
      
      protected var _safeRadius:Number;
      
      protected var _planetDragXOffset:Number;
      
      protected var _grid:SHZDiagramGrid;
      
      protected var _planetRightXSoftMargin:Number = 0.35;
      
      protected var _planetDragX:Number;
      
      protected var _planetTargetX:Number;
      
      protected var _star:SHZDiagramStar;
      
      protected var _easingTime:Number = 500;
      
      protected var _easer:CubicEaser;
      
      public const starX:Number = 130;
      
      protected var _zoneLabelsSP:Sprite;
      
      protected var _scale:Number = NaN;
      
      protected var _refOrbits:Sprite;
      
      protected var _maskSH:Shape;
      
      protected var _planetDragMinX:Number;
      
      protected var _planetDragTimer:Timer;
      
      protected var _planetDragLeftXHardMargin:Number = 135;
      
      protected var _zoomerSP:Sprite;
      
      protected var _maxZoomerScale:Number = 25000;
      
      protected var _planetZoomMinX:Number;
      
      public var borderAlpha:Number = 1;
      
      public var borderColor:uint = 9474192;
      
      protected var _planetDragMaxX:Number;
      
      protected var _zonesSP:Sprite;
      
      protected var _zoomerTimer:Timer;
      
      public var borderThickness:Number = 1;
      
      protected var _planet:SHZDiagramPlanet;
      
      protected var _planetZoomMaxX:Number;
      
      protected var _planetDistance:Number = 2;
      
      public var backgroundAlpha:Number = 1;
      
      public var backgroundColor:uint = 0;
      
      protected var _planetLeftXSoftMargin:Number = 0.15;
      
      protected var _minZoomerScale:Number = 0.25;
      
      protected var _borderSH:Shape;
      
      protected var _planetDragMinDistance:Number = 0.01;
      
      protected var _scalebar:SHZDiagramScalebar;
      
      protected var _easeStopTime:Number;
      
      protected var _planetDragMaxDistance:Number = 300;
      
      protected var _h:Number;
      
      protected var _diagramSP:Sprite;
      
      protected var _zoomerDeadSpace:Number = 95;
      
      protected var _zoomerStartX:Number;
      
      protected var _backgroundSH:Shape;
      
      protected var _w:Number;
      
      public function SHZDiagram(param1:Number, param2:Number)
      {
         super();
         _w = param1;
         _h = param2;
         _planetTargetX = _w / 2;
         _safeRadius = 1.1 * Math.sqrt(_h * _h / 4 + _w * _w);
         _planetDragMinX = starX + _planetDragLeftXHardMargin;
         _planetDragMaxX = _w - _planetDragRightXHardMargin;
         _planetZoomMinX = _planetDragMinX + _planetLeftXSoftMargin * (_planetDragMaxX - _planetDragMinX);
         _planetZoomMaxX = _planetDragMinX + (1 - _planetRightXSoftMargin) * (_planetDragMaxX - _planetDragMinX);
         _backgroundSH = new Shape();
         _diagramSP = new Sprite();
         _maskSH = new Shape();
         _borderSH = new Shape();
         addChild(_backgroundSH);
         addChild(_diagramSP);
         addChild(_maskSH);
         addChild(_borderSH);
         _grid = new SHZDiagramGrid(this);
         _grid.x = starX;
         _grid.y = _h / 2;
         _grid.visible = false;
         _diagramSP.addChild(_grid);
         _zonesSP = new Sprite();
         _zonesSP.x = starX;
         _zonesSP.y = _h / 2;
         _diagramSP.addChild(_zonesSP);
         _refOrbits = new Sprite();
         _refOrbits.x = starX;
         _refOrbits.y = _h / 2;
         _diagramSP.addChild(_refOrbits);
         _star = new SHZDiagramStar(this);
         _star.x = starX;
         _star.y = _h / 2;
         _diagramSP.addChild(_star);
         _zoneLabelsSP = new Sprite();
         _zoneLabelsSP.x = starX;
         _zoneLabelsSP.y = _h / 2;
         _diagramSP.addChild(_zoneLabelsSP);
         _zoomerSP = new Sprite();
         _diagramSP.addChild(_zoomerSP);
         _planet = new SHZDiagramPlanet(this);
         _planet.x = _w / 2;
         _planet.y = _h / 2;
         _diagramSP.addChild(_planet);
         _scalebar = new SHZDiagramScalebar(this);
         _scalebar.x = _w - 85;
         _scalebar.y = 23;
         _diagramSP.addChild(_scalebar);
         _diagramSP.mask = _maskSH;
         _zoomerTimer = new Timer(20);
         _zoomerTimer.stop();
         _zoomerTimer.addEventListener("timer",onZoomerTimerEvent);
         _easingTimer = new Timer(20);
         _easingTimer.stop();
         _easingTimer.addEventListener("timer",onEasingTimerEvent);
         _planetDragTimer = new Timer(20);
         _planetDragTimer.stop();
         _planetDragTimer.addEventListener("timer",onPlanetDragTimerEvent);
         _easer = new CubicEaser(_planetDistance);
         _zoomerSP.addEventListener("mouseDown",onZoomerMouseDown);
         drawBackgroundAndBorder();
         setPlanetDistance(2,false);
         setPlanetDraggable(true);
      }
      
      public function addRefOrbitsGroup(param1:String, param2:uint = 0, param3:uint = 0, param4:Number = 25) : void
      {
         var _loc5_:SHZDiagramRefOrbits = new SHZDiagramRefOrbits(this,param2,param3,param4);
         _loc5_.name = param1;
         _refOrbits.addChild(_loc5_);
      }
      
      public function setRefOrbitsGroup(param1:String, param2:Array) : void
      {
         (_refOrbits.getChildByName(param1) as SHZDiagramRefOrbits).setList(param2);
      }
      
      protected function setScale(param1:Number) : void
      {
         _scale = param1;
         update();
      }
      
      public function setStarTemperature(param1:Number) : void
      {
         _star.temperature = param1;
         _star.update();
      }
      
      public function setPlanetDraggable(param1:Boolean) : void
      {
         if(param1)
         {
            _planet.addEventListener("mouseDown",onPlanetMouseDown);
         }
         else
         {
            _planet.removeEventListener("mouseDown",onPlanetMouseDown);
         }
      }
      
      public function setPlanetState(param1:Boolean, param2:Boolean, param3:Number) : void
      {
         _planet.setState(param1,param2,param3);
      }
      
      protected function onZoomerMouseDown(... rest) : void
      {
         if(_easingTimer.running)
         {
            _easingTimer.stop();
         }
         _easer.init(Math.log(_scale));
         setScale(_scale);
         _zoomerStartX = mouseX;
         _zoomerTimer.start();
         stage.addEventListener("mouseUp",onZoomerMouseUp);
      }
      
      public function setHighlightedRefOrbit(param1:String, param2:int) : void
      {
         (_refOrbits.getChildByName(param1) as SHZDiagramRefOrbits).highlightedOrbit = param2;
      }
      
      protected function onZoomerTimerEvent(param1:TimerEvent) : void
      {
         var _loc2_:Number = NaN;
         if(mouseX > _zoomerStartX)
         {
            _loc2_ = (mouseX - (_zoomerStartX + _zoomerDeadSpace)) / _w;
            if(_loc2_ < 0)
            {
               _loc2_ = 0;
            }
            else if(_loc2_ > 1)
            {
               _loc2_ = 1;
            }
         }
         else
         {
            _loc2_ = (mouseX - (_zoomerStartX - _zoomerDeadSpace)) / _w;
            if(_loc2_ > 0)
            {
               _loc2_ = 0;
            }
            else if(_loc2_ < -1)
            {
               _loc2_ = -1;
            }
         }
         var _loc3_:Number = _scale * Math.pow(_zoomerFactor,-_loc2_);
         if(_loc3_ < _minZoomerScale)
         {
            _loc3_ = _minZoomerScale;
         }
         else if(_loc3_ > _maxZoomerScale)
         {
            _loc3_ = _maxZoomerScale;
         }
         _easer.init(Math.log(_loc3_));
         setScale(_loc3_);
         param1.updateAfterEvent();
      }
      
      override public function get height() : Number
      {
         return _h;
      }
      
      public function setStarRadiusAndTemperature(param1:Number, param2:Number) : void
      {
         _star.radius = param1;
         _star.temperature = param2;
         _star.update();
      }
      
      protected function onPlanetMouseDown(... rest) : void
      {
         _planetDragXOffset = _planet.x - mouseX;
         _planetDragX = starX + _planetDistance * _scale;
         stage.addEventListener("mouseUp",onPlanetMouseUp);
         _planetDragTimer.start();
      }
      
      public function get scale() : Number
      {
         return _scale;
      }
      
      public function get showRefOrbits() : Boolean
      {
         return _refOrbits.visible;
      }
      
      public function setShowRefOrbitsGroup(param1:String, param2:Boolean) : void
      {
         _refOrbits.getChildByName(param1).visible = param2;
         if(param2 && _refOrbits.visible)
         {
            (_refOrbits.getChildByName(param1) as SHZDiagramRefOrbits).update();
         }
      }
      
      public function get showZones() : Boolean
      {
         return _zonesSP.visible;
      }
      
      protected function processMouse() : Number
      {
         _planetDragX = mouseX + _planetDragXOffset;
         if(_planetDragX < _planetDragMinX)
         {
            _planetDragX = _planetDragMinX;
         }
         else if(_planetDragX > _planetDragMaxX)
         {
            _planetDragX = _planetDragMaxX;
         }
         var _loc1_:Number = (_planetDragX - starX) / scale;
         if(_loc1_ > _planetDragMaxDistance)
         {
            _loc1_ = _planetDragMaxDistance;
            _planetDragX = -1;
         }
         else if(_loc1_ < _planetDragMinDistance)
         {
            _loc1_ = _planetDragMinDistance;
            _planetDragX = -1;
         }
         return _loc1_;
      }
      
      protected function drawBackgroundAndBorder() : void
      {
         with(_backgroundSH.graphics)
         {
            clear();
            beginFill(backgroundColor,backgroundAlpha);
            drawRect(0,0,_w,_h);
            endFill();
         }
         with(_zoomerSP.graphics)
         {
            clear();
            beginFill(65280,0);
            drawRect(0,0,_w,_h);
            endFill();
         }
         with(_maskSH.graphics)
         {
            clear();
            beginFill(16711680);
            drawRect(0,0,_w,_h);
            endFill();
         }
         with(_borderSH.graphics)
         {
            clear();
            lineStyle(borderThickness,borderColor,borderAlpha);
            drawRect(0,0,_w,_h);
         }
      }
      
      public function get safeRadius() : Number
      {
         return _safeRadius;
      }
      
      public function get planetBeingDragged() : Boolean
      {
         return _planetDragTimer.running;
      }
      
      public function setStarRadius(param1:Number) : void
      {
         _star.radius = param1;
         _star.update();
      }
      
      public function set showZones(param1:Boolean) : void
      {
         _zoneLabelsSP.visible = param1;
         _zonesSP.visible = param1;
      }
      
      protected function onZoomerMouseUp(... rest) : void
      {
         _zoomerTimer.stop();
         _planetTargetX = _w / 2;
         var _loc2_:Number = (_planetTargetX - starX) / _planetDistance;
         easeToScale(_loc2_);
         stage.removeEventListener("mouseUp",onZoomerMouseUp);
      }
      
      public function getPlanetDistance() : Number
      {
         return _planetDistance;
      }
      
      public function setPlanetDragLimits(param1:Number, param2:Number) : void
      {
         _planetDragMinDistance = param1;
         _planetDragMaxDistance = param2;
      }
      
      public function setZoneRange(param1:String, param2:Number, param3:Number) : void
      {
         var _loc5_:SHZDiagramZone = null;
         var _loc4_:int = 0;
         while(_loc4_ < _zonesSP.numChildren)
         {
            if(_zonesSP.getChildAt(_loc4_).name == param1)
            {
               _loc5_ = _zonesSP.getChildAt(_loc4_) as SHZDiagramZone;
               _loc5_.innerRadius = param2;
               _loc5_.outerRadius = param3;
               _loc5_.update();
               break;
            }
            _loc4_++;
         }
      }
      
      public function setPlanetDistance(param1:Number, param2:Boolean = true) : void
      {
         var _loc4_:Number = NaN;
         _planetDistance = param1;
         if(param2)
         {
            _loc4_ = _planetDistance * scale + starX;
            if(_loc4_ < _planetZoomMinX)
            {
               _planetTargetX = _planetZoomMinX;
            }
            else if(_loc4_ > _planetZoomMaxX)
            {
               _planetTargetX = _planetZoomMaxX;
            }
            else
            {
               _planetTargetX = _loc4_;
               param2 = false;
            }
         }
         else
         {
            _planetTargetX = _w / 2;
         }
         var _loc3_:Number = (_planetTargetX - starX) / _planetDistance;
         if(param2)
         {
            easeToScale(_loc3_);
         }
         else
         {
            if(_easingTimer.running)
            {
               _easingTimer.stop();
            }
            _easer.init(Math.log(_loc3_));
            setScale(_loc3_);
         }
      }
      
      protected function easeToScale(param1:Number) : void
      {
         var _loc2_:* = undefined;
         if(param1 != _scale)
         {
            _loc2_ = getTimer();
            _easeStopTime = _loc2_ + _easingTime;
            _easer.setTarget(_loc2_,Number.NaN,_easeStopTime,Math.log(param1));
            if(!_easingTimer.running)
            {
               _easingTimer.start();
            }
         }
         else
         {
            if(_easingTimer.running)
            {
               _easingTimer.stop();
            }
            setScale(param1);
         }
      }
      
      public function set showRefOrbits(param1:Boolean) : void
      {
         var _loc2_:int = 0;
         _refOrbits.visible = param1;
         if(_refOrbits.visible)
         {
            _loc2_ = 0;
            while(_loc2_ < _refOrbits.numChildren)
            {
               if(_refOrbits.getChildAt(_loc2_).visible)
               {
                  (_refOrbits.getChildAt(_loc2_) as SHZDiagramRefOrbits).update();
               }
               _loc2_++;
            }
         }
      }
      
      override public function get width() : Number
      {
         return _w;
      }
      
      protected function updatePlanet() : void
      {
         if(_planetDragTimer.running && _planetDragX > 0)
         {
            _planet.x = _planetDragX;
         }
         else
         {
            _planet.x = starX + _planetDistance * _scale;
         }
         _planet.scaleX = _planet.scaleY = _planet.x >= _planetDragMinX ? 1 : Math.pow((_planet.x - starX) / (_planetDragMinX - starX),0.4);
      }
      
      protected function onPlanetMouseUp(... rest) : void
      {
         stage.removeEventListener("mouseUp",onPlanetMouseUp);
         _planetDragTimer.stop();
         dispatchEvent(new SHZDiagramEvent("planetDraggingStopped",processMouse()));
         updatePlanet();
      }
      
      public function update() : void
      {
         var _loc1_:int = 0;
         if(_grid.visible)
         {
            _grid.update();
         }
         if(_refOrbits.visible)
         {
            _loc1_ = 0;
            while(_loc1_ < _refOrbits.numChildren)
            {
               if(_refOrbits.getChildAt(_loc1_).visible)
               {
                  (_refOrbits.getChildAt(_loc1_) as SHZDiagramRefOrbits).update();
               }
               _loc1_++;
            }
         }
         _scalebar.update();
         _loc1_ = 0;
         while(_loc1_ < _zonesSP.numChildren)
         {
            (_zonesSP.getChildAt(_loc1_) as SHZDiagramZone).update();
            _loc1_++;
         }
         _star.update();
         updatePlanet();
      }
      
      protected function onEasingTimerEvent(param1:TimerEvent) : void
      {
         var _loc2_:Number = getTimer();
         if(_loc2_ > _easeStopTime)
         {
            _loc2_ = _easeStopTime;
         }
         var _loc3_:Number = Math.exp(_easer.getValue(_loc2_));
         if(_loc2_ >= _easeStopTime)
         {
            _easingTimer.stop();
            _easer.init(Math.log(_loc3_));
         }
         setScale(_loc3_);
         param1.updateAfterEvent();
      }
      
      public function set showStar(param1:Boolean) : void
      {
         _star.visible = param1;
      }
      
      protected function onPlanetDragTimerEvent(param1:TimerEvent) : void
      {
         dispatchEvent(new SHZDiagramEvent("planetDragged",processMouse()));
         param1.updateAfterEvent();
      }
      
      public function addZone(param1:String, param2:Number, param3:Number) : void
      {
         var _loc4_:SHZDiagramZone = new SHZDiagramZone(this,param1,param2,param3);
         _zonesSP.addChild(_loc4_);
         _zoneLabelsSP.addChild(_loc4_.label);
      }
      
      public function get showStar() : Boolean
      {
         return _star.visible;
      }
      
      public function set showGrid(param1:Boolean) : void
      {
         _grid.visible = param1;
         if(param1)
         {
            _grid.update();
         }
      }
      
      public function get showGrid() : Boolean
      {
         return _grid.visible;
      }
   }
}

