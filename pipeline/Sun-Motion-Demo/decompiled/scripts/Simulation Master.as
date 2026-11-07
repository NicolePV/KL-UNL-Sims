function SimulationMasterClass()
{
   var _loc8_ = getTimer();
   this.attachMovie("Panel Shell","panelShellMC",1);
   this.attachMovie("CelestialSphere","sphereMC",2,{_x:220,_y:225,_traceOn:false});
   this.createEmptyMovieClip("balloonsMC",3);
   this.balloonsMC.attachMovie("Analemma Balloon","analemmaBalloon",0,{_visible:false});
   this.balloonsMC.newDepth = 1;
   this.attachMovie("Analemma Curve","analemmaMC",4,{sphere:this.sphereMC});
   this.initializeSphere();
   var _loc2_ = false;
   this.latitudePanel = this.panelShellMC.addPanel("Latitude Panel","Latitude",660,122,_loc2_);
   this.animationControlPanel = this.panelShellMC.addPanel("Animation Control Panel","Animation Controls",449,370,_loc2_);
   this.timeOfDayPanel = this.panelShellMC.addPanel("Time Of Day Panel","Time of Day",458,105,_loc2_);
   this.dayOfYearPanel = this.panelShellMC.addPanel("Day Of Year Panel","Day of Year",442,27,_loc2_);
   this.infoPanel = this.panelShellMC.addPanel("Info Panel","Information",13,474,_loc2_);
   this.settingsPanel = this.panelShellMC.addPanel("Settings Panel","Settings",765,355,_loc2_);
   this.analemmaMC.visible = false;
   this.loopDay = false;
   this._useLowAnimationQuality = false;
   this._animationState = false;
   this.discreteSpeed = 0.015;
   this.continuousSpeed = 0.000125;
   this.setAnimationMode("continuous");
   this.latitude = 40.8;
   this.day = 146.5;
   this.sunDragMode = "timeOfDay";
}
var p = SimulationMasterClass.prototype = new MovieClip();
Object.registerClass("Simulation Master",SimulationMasterClass);
p.monthLabels = ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"];
p.reset = function()
{
   var _loc2_ = getTimer();
   this.animationState = false;
   this.discreteSpeed = 0.015;
   this.continuousSpeed = 0.000125;
   this.animationControlPanel.qualityCheck.setValue(false);
   this.animationControlPanel.animationModeGroup.setValue("continuous");
   this.animationControlPanel.loopDayCheck.setValue(false);
   this.infoPanel.showAnalemmaCheck.setValue(false);
   this.settingsPanel.showSunDecCheck.setValue(true);
   this.settingsPanel.showEclipticCheck.setValue(true);
   this.settingsPanel.showMonthLabelsCheck.setValue(false);
   this.settingsPanel.showUndersideCheck.setValue(true);
   this.settingsPanel.showStickfigureCheck.setValue(true);
   this.settingsPanel.sunDragBehaviorGroup.setValue("timeOfDay");
   this.sphereMC.viewerAzimuth = 215;
   this.sphereMC.viewerAltitude = 35;
   this.latitude = 40.8;
   this.day = 146.5;
};
p.initializeSphere = function()
{
   var _loc3_ = this.sphereMC;
   _loc3_.size = 350;
   _loc3_.viewerAzimuth = 215;
   _loc3_.viewerAltitude = 35;
   _loc3_.minViewerAltitude = 5;
   _loc3_.showUnder = true;
   _loc3_.addObject("Stickfigure","stickfigure",{x:0,y:0,z:0.001,system:"horizon"});
   _loc3_.stickfigure.setOrientationType("absolute",{x:-1,y:0,z:0,system:"horizon"},{x:0,y:0,z:1,system:"horizon"});
   _loc3_.addObject("ShadowMaker","shadow",{x:0,y:0,z:0,system:"horizon"},{shadowClip:"Stickfigure Shadow"});
   _loc3_.shadow.setOrientationType("absolute",{x:0,y:0,z:1,system:"horizon"},{x:1,y:0,z:0,system:"horizon"});
   _loc3_.addObject("Shadow Mask","shadowMask",{x:0,y:0,z:0,system:"horizon"});
   _loc3_.shadowMask.setOrientationType("absolute",{x:0,y:0,z:1,system:"horizon"},{x:1,y:0,z:0,system:"horizon"});
   _loc3_.shadow.instance.setMask(_loc3_.shadowMask.instance);
   _loc3_.addObject("Sun Disk","sunDisk",{ra:0,dec:0});
   var _loc5_ = [{ra:19.92,dec:-20.8,r:1.1},{ra:21.93,dec:-12.59,r:1.1},{ra:23.79,dec:-1.43,r:1.1},{ra:1.64,dec:10.23,r:1.1},{ra:3.59,dec:19.29,r:1.1},{ra:5.66,dec:23.36,r:1.1},{ra:7.76,dec:21.22,r:1.1},{ra:9.77,dec:13.45,r:1.1},{ra:11.61,dec:2.49,r:1.1},{ra:13.46,dec:-9.22,r:1.1},{ra:15.47,dec:-18.85,r:1.1},{ra:17.66,dec:-23.34,r:1.1}];
   var _loc2_ = 0;
   var _loc4_;
   while(_loc2_ < 12)
   {
      _loc4_ = _loc3_.addObject("MonthLabel",this.monthLabels[_loc2_],_loc5_[_loc2_],{monthString:this.monthLabels[_loc2_]});
      _loc4_.setOrientationType("absolute",_loc5_[_loc2_],{ra:18,dec:66.56});
      _loc4_.visible = false;
      _loc2_ = _loc2_ + 1;
   }
   _loc3_.addCircle("meridianCircle1",{thickness:1,color:16777215,alpha:20},{az:0,alt:0,tilt:90});
   _loc3_.addCircle("meridianCircle2",{thickness:1,color:16777215,alpha:20},{az:90,alt:0,tilt:90});
   _loc3_.meridianCircle1.update();
   _loc3_.meridianCircle2.update();
   _loc3_.addCircle("zeroHoursCircle",{thickness:2,color:2915326,alpha:70},{ra:0,dec:0,tilt:90,gammaStart:-90,gammaEnd:90});
   _loc3_.addCircle("celestialEquator",{thickness:2,color:2915326,alpha:70},{ra:0,dec:0,tilt:0});
   _loc3_.addCircle("eclipticCircle",{thickness:2,color:16777215,alpha:70},{ra:0,dec:0,tilt:23.44});
   _loc3_.addCircle("decCircle",{thickness:2,color:16773728,alpha:70},{ra:0,dec:16,tilt:0});
   this.addCircleBalloon("zeroHoursCircle","Zero Hour Circle Balloon");
   this.addCircleBalloon("celestialEquator","Celestial Equator Balloon");
   this.addCircleBalloon("eclipticCircle","Ecliptic Circle Balloon");
   this.addCircleBalloon("decCircle","Sun Declination Balloon");
   _loc3_.addLine("ncpAxis",{thickness:2,color:2915326,alpha:100},{x:0,y:0,z:1,system:"celestial"},{x:0,y:0,z:1.2,system:"celestial"});
   _loc3_.addLine("scpAxis",{thickness:2,color:2915326,alpha:100},{x:0,y:0,z:-1,system:"celestial"},{x:0,y:0,z:-1.2,system:"celestial"});
   _loc3_.addShadingClip("CSGradientDisk","skyFront","front","inner","both",{innerAlpha:10,outerAlpha:20,innerColor:12575999,outerColor:12575999});
   _loc3_.addShadingClip("CSGradientDisk","skyBack","back","inner","above",{innerAlpha:70,outerAlpha:70,innerColor:12575999,outerColor:12575999});
   _loc3_.aboveHorizonPlane.removeMovieClip();
   _loc3_.addHorizonPlaneClip("CSGradientDisk","newHorizonPlane","above",1,{innerAlpha:100,innerColor:5358673,outerAlpha:100,outerColor:3843386});
   this.directionLabels = _loc3_.addHorizonPlaneClip("Direction Labels Light","aboveLabels","above",2);
   _loc3_.addHorizonPlaneClip("CSGradientDisk","horizonShade","above",5,{innerAlpha:0,innerColor:0,outerAlpha:0,outerColor:0});
   _loc3_.onMouseUpdate = function()
   {
      this.analemmaMC.update();
      updateAfterEvent();
   };
};
p.addCircleBalloon = function(circleName, balloonName)
{
   var thisBalloon = this.balloonsMC.attachMovie(balloonName,"_" + this.balloonsMC.newDepth,this.balloonsMC.newDepth,{_visible:false});
   this.balloonsMC.newDepth++;
   var thisCircle = this.sphereMC[circleName];
   thisCircle.setUseMouseFunctions(true,"front only");
   thisCircle.onRollOver = function()
   {
      thisCircle.setStyle(4);
      thisCircle.update();
      thisBalloon._visible = true;
      var _loc3_ = this._xmouse - 5;
      if(_loc3_ < thisBalloon._width)
      {
         _loc3_ = thisBalloon._width;
      }
      var _loc2_ = this._ymouse - 5;
      if(_loc2_ < thisBalloon._height)
      {
         _loc2_ = thisBalloon._height;
      }
      thisBalloon._x = _loc3_;
      thisBalloon._y = _loc2_;
   };
   thisCircle.onRollOut = thisCircle.onReleaseOutside = function()
   {
      thisCircle.setStyle(2);
      thisCircle.update();
      thisBalloon._visible = false;
   };
};
p.updateSky = function()
{
   var _loc3_ = {};
   this.sphereMC.pointToHorizon(this.sphereMC.sunDisk._p,_loc3_);
   this.altitude = _loc3_.alt;
   this.azimuth = _loc3_.az;
   var _loc2_ = this.sphereMC;
   if(_loc2_.shadow.visible)
   {
      _loc2_.shadow.instance.setSourcePosition(_loc3_);
   }
   var _loc4_ = 40 * Math.pow(1 - _loc3_.alt / 90,4);
   if(_loc4_ > 40)
   {
      _loc4_ = 40;
   }
   _loc2_.horizonShade.innerAlpha = _loc2_.horizonShade.outerAlpha = _loc4_;
   _loc2_.horizonShade.update();
   var _loc5_ = 80 * Math.pow(_loc3_.alt / 90,0.15);
   _loc2_.skyBack.innerAlpha = _loc2_.skyBack.outerAlpha = _loc5_;
   _loc2_.skyBack.update();
};
p.updateSphere = function()
{
   var _loc2_ = getPositionAndEqnOfTime(this._day);
   this.sphereMC.sunDisk.setPosition(_loc2_);
   this.sphereMC.sunDisk.setOrientationType("absolute");
   this.sphereMC.decCircle.setCircleParameters({dec:_loc2_.dec,ra:0,tilt:0});
   var _loc3_ = getSiderealTime(this._day);
   this.sphereMC.siderealTime = _loc3_;
   this.hourAngle = ((_loc3_ - _loc2_.ra) % 24 + 24) % 24;
   this.siderealTime = _loc3_;
   this.equationOfTime = _loc2_.eqn;
   this.declination = _loc2_.dec;
   this.rightAscension = _loc2_.ra;
};
p.onMouseDown = function()
{
   var _loc3_ = this._xmouse - this.sphereMC._x;
   var _loc2_ = this._ymouse - this.sphereMC._y;
   var _loc4_ = Math.sqrt(_loc3_ * _loc3_ + _loc2_ * _loc2_);
   if(_loc4_ < this.sphereMC._c.r)
   {
      this.pauseAnimation();
      this.onMouseUp = function()
      {
         this.resumeAnimation();
         delete this.onMouseUp;
      };
   }
};
p.getDay = function()
{
   return this._day;
};
p.setDay = function(arg)
{
   if(isNaN(arg) || !isFinite(arg))
   {
      this.timeOfDayPanel.update();
      this.dayOfYearPanel.update();
      return undefined;
   }
   arg = (arg % 365 + 365) % 365;
   if(arg != this._day)
   {
      this._day = arg;
      this._tod = (arg % 1 + 1) % 1;
      this._doy = Math.floor(arg);
      this.timeOfDayPanel.update();
      this.dayOfYearPanel.update();
      this.updateSphere();
      this.updateSky();
      this.analemmaMC.update();
      this.infoPanel.update();
   }
   else
   {
      this.timeOfDayPanel.update();
      this.dayOfYearPanel.update();
   }
};
p.addProperty("day",p.getDay,p.setDay);
p.getTimeOfDay = function()
{
   return this._tod;
};
p.setTimeOfDay = function(arg)
{
   if(isNaN(arg) || !isFinite(arg))
   {
      trace("called: " + arg);
      this.timeOfDayPanel.update();
      return undefined;
   }
   arg = (arg % 1 + 1) % 1;
   if(arg != this._tod)
   {
      this._tod = arg;
      this._day = this._doy + arg;
      this.timeOfDayPanel.update();
      this.updateSphere();
      this.updateSky();
      this.analemmaMC.update();
      this.infoPanel.update();
   }
   else
   {
      this.timeOfDayPanel.update();
   }
};
p.addProperty("timeOfDay",p.getTimeOfDay,p.setTimeOfDay);
p.getDayOfYear = function()
{
   return this._doy;
};
p.setDayOfYear = function(arg)
{
   if(isNaN(arg) || !isFinite(arg))
   {
      this.dayOfYearPanel.update();
      return undefined;
   }
   arg = (Math.floor(arg) % 365 + 365) % 365;
   if(arg != this._doy)
   {
      this._doy = arg;
      this._day = arg + this._tod;
      this.dayOfYearPanel.update();
      this.updateSphere();
      this.updateSky();
      this.infoPanel.update();
   }
   else
   {
      this.dayOfYearPanel.update();
   }
};
p.addProperty("dayOfYear",p.getDayOfYear,p.setDayOfYear);
p.getLatitude = function()
{
   return this._latitude;
};
p.setLatitude = function(arg)
{
   if(isNaN(arg) || !isFinite(arg))
   {
      this.latitudePanel.update();
      return undefined;
   }
   if(arg > 90)
   {
      arg = 90;
   }
   else if(arg < -90)
   {
      arg = -90;
   }
   if(arg != this._latitude)
   {
      this._latitude = arg;
      if(this._latitude == 90)
      {
         this.directionLabels.northField.text = "S";
         this.directionLabels.southField.text = "S";
         this.directionLabels.eastField.text = "S";
         this.directionLabels.westField.text = "S";
      }
      else if(this._latitude == -90)
      {
         this.directionLabels.northField.text = "N";
         this.directionLabels.southField.text = "N";
         this.directionLabels.eastField.text = "N";
         this.directionLabels.westField.text = "N";
      }
      else
      {
         this.directionLabels.northField.text = "N";
         this.directionLabels.southField.text = "S";
         this.directionLabels.eastField.text = "E";
         this.directionLabels.westField.text = "W";
      }
      this.latitudePanel.update();
      this.sphereMC.latitude = arg;
      this.analemmaMC.update();
      this.updateSky();
      this.infoPanel.update();
   }
   else
   {
      this.latitudePanel.update();
   }
};
p.addProperty("latitude",p.getLatitude,p.setLatitude);
p.continuousMin = 0.000010416666666666666;
p.continuousMax = 0.00075;
p.discreteMin = 0.005;
p.discreteMax = 0.122;
p.setAnimationMode = function(arg)
{
   if(arg == "continuous")
   {
      if(this.stepByDay)
      {
         if(typeof this.oldLoopDay == "boolean")
         {
            this.loopDay = this.oldLoopDay;
         }
         this._animateDay = Math.floor(this._animateDay) + this._tod;
      }
      this.stepByDay = false;
      this._speed = this.continuousSpeed;
   }
   else
   {
      if(!this.stepByDay)
      {
         this.oldLoopDay = this.loopDay;
      }
      this.loopDay = false;
      this.stepByDay = true;
      this._speed = this.discreteSpeed;
   }
   this.timeOfDayPanel.update();
   this.animationControlPanel.update();
};
p.getAnimationSpeed = function()
{
   return this._speed;
};
p.setAnimationSpeed = function(arg)
{
   if(isNaN(arg) || !isFinite(arg))
   {
      return undefined;
   }
   if(this.stepByDay)
   {
      if(arg < this.discreteMin)
      {
         arg = this.discreteMin;
      }
      else if(arg > this.discreteMax)
      {
         arg = this.discreteMax;
      }
      this.discreteSpeed = arg;
   }
   else
   {
      if(arg < this.continuousMin)
      {
         arg = this.continuousMin;
      }
      else if(arg > this.continuousMax)
      {
         arg = this.continuousMax;
      }
      this.continuousSpeed = arg;
   }
   this._speed = arg;
   this.animationControlPanel.update();
};
p.addProperty("animationSpeed",p.getAnimationSpeed,p.setAnimationSpeed);
p.onEnterFrameFunc = function()
{
   var _loc3_ = getTimer();
   var _loc2_ = _loc3_ - this.timeLast;
   this._animateDay += this._speed * _loc2_;
   this.lastDeltaT = _loc2_;
   if(this.stepByDay)
   {
      this.setDayOfYear(this._animateDay);
   }
   else if(this.loopDay)
   {
      this._animateDay = this._doy + this._animateDay % 1;
      this.setTimeOfDay(this._animateDay);
   }
   else
   {
      this.setDay(this._animateDay);
   }
   this.timeLast = _loc3_;
};
p.pauseAnimation = function()
{
   delete this.onEnterFrame;
};
p.resumeAnimation = function()
{
   if(this._animationState)
   {
      this.timeLast = getTimer();
      this._animateDay = this._day;
      this.onEnterFrame = this.onEnterFrameFunc;
   }
};
p.getAnimationState = function()
{
   return this._animationState;
};
p.setAnimationState = function(arg)
{
   this._animationState = Boolean(arg);
   if(this._animationState)
   {
      this.timeLast = getTimer();
      this._animateDay = this._day;
      this.onEnterFrame = this.onEnterFrameFunc;
      if(this._useLowAnimationQuality)
      {
         _quality = "medium";
      }
      else
      {
         _quality = "best";
      }
   }
   else
   {
      delete this.onEnterFrame;
      this.timeOfDayPanel.update();
      _quality = "best";
   }
   this.dayOfYearPanel.setEnableManualInput(!this._animationState);
   this.timeOfDayPanel.setEnableManualInput(!this._animationState);
   this.animationControlPanel.update();
};
p.addProperty("animationState",p.getAnimationState,p.setAnimationState);
p.getUseLowAnimationQuality = function()
{
   this._useLowAnimationQuality;
};
p.setUseLowAnimationQuality = function(arg)
{
   this._useLowAnimationQuality = Boolean(arg);
   if(this._animationState && this._useLowAnimationQuality)
   {
      _quality = "medium";
   }
   else
   {
      _quality = "best";
   }
};
p.addProperty("useLowAnimationQuality",p.getUseLowAnimationQuality,p.setUseLowAnimationQuality);
