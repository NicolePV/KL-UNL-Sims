function onTimeOfDayCursorPressed()
{
   var _loc1_ = this;
   _loc1_.xOffset = _loc1_._parent._xmouse - _loc1_._x;
   _loc1_.onMouseMove = _loc1_._parent.onTimeOfDayCursorMoved;
   _loc1_.onRelease = _loc1_._parent.onTimeOfDayCursorReleased;
   _loc1_.onReleaseOutside = _loc1_._parent.onTimeOfDayCursorReleased;
}
function onTimeOfDayCursorMoved()
{
   var _loc1_ = this;
   var _loc2_ = _loc1_._parent._xmouse - _loc1_.xOffset;
   var offset = _loc1_._parent.timelineMC._x;
   var _loc3_ = _loc1_._parent.timelineMC._dimensions.width;
   _loc2_ = offset + ((_loc2_ - offset) % _loc3_ + _loc3_) % _loc3_;
   _loc1_._x = _loc2_;
   _loc1_._parent.updateSphere();
   updateAfterEvent();
}
function onTimeOfDayCursorReleased()
{
   var _loc1_ = this;
   delete _loc1_.onMouseMove;
   delete _loc1_.onRelease;
   delete _loc1_.onReleaseOutside;
}
function onLockTimeChanged()
{
   if(lockTimeGroup.getValue() == "noLock")
   {
      timeOfDayCursorColor.setRGB(15736832);
      timeOfDayCursor.onPress = onTimeOfDayCursorPressed;
   }
   else
   {
      timeOfDayCursorColor.setRGB(5263440);
      delete timeOfDayCursor.onPress;
      delete timeOfDayCursor.onMouseMove;
      delete timeOfDayCursor.onRelease;
      delete timeOfDayCursor.onReleaseOutside;
   }
   updateSphere();
}
function updateSphere()
{
   var sunLongitude = (timelineMC.dayOfYearZB - 78) / 365 * 2 * 3.141592653589793;
   var sunDeclination = Math.asin(0.39714789063478056 * Math.sin(sunLongitude));
   var sinSunDec = Math.sin(sunDeclination);
   var sinLat = Math.sin(timelineMC._latitude);
   var cosSunDec = Math.cos(sunDeclination);
   var cosLat = Math.cos(timelineMC._latitude);
   var zTwilight = Math.sin(- timelineMC._twilightAngle);
   var sinProduct = sinSunDec * sinLat;
   var cosProduct = cosSunDec * cosLat;
   var _loc3_ = (zTwilight - sinProduct) / cosProduct;
   var _loc2_ = (- sinProduct) / cosProduct;
   var neverAboveTwilightLimit = _loc3_ >= 1;
   var neverBelowTwilightLimit = _loc3_ <= -1;
   var neverAboveHorizon = _loc2_ >= 1;
   var neverBelowHorizon = _loc2_ <= -1;
   var _loc1_;
   switch(lockTimeGroup.getValue())
   {
      case "twilightStart":
         if(neverAboveTwilightLimit)
         {
            _loc1_ = 0;
            timeOfDayCursor._visible = false;
         }
         else if(neverBelowTwilightLimit)
         {
            _loc1_ = -12;
            timeOfDayCursor._visible = false;
         }
         else
         {
            timeOfDayCursor._visible = true;
            _loc1_ = -3.819718634205488 * Math.acos(_loc3_);
         }
         break;
      case "sunrise":
         if(neverAboveHorizon)
         {
            _loc1_ = 0;
            timeOfDayCursor._visible = false;
         }
         else if(neverBelowHorizon)
         {
            _loc1_ = -12;
            timeOfDayCursor._visible = false;
         }
         else
         {
            timeOfDayCursor._visible = true;
            _loc1_ = -3.819718634205488 * Math.acos(_loc2_);
         }
         break;
      case "noon":
         _loc1_ = 0;
         timeOfDayCursor._visible = true;
         break;
      case "sunset":
         if(neverAboveHorizon)
         {
            _loc1_ = 0;
            timeOfDayCursor._visible = false;
         }
         else if(neverBelowHorizon)
         {
            _loc1_ = -12;
            timeOfDayCursor._visible = false;
         }
         else
         {
            timeOfDayCursor._visible = true;
            _loc1_ = 3.819718634205488 * Math.acos(_loc2_);
         }
         break;
      case "twilightEnd":
         if(neverAboveTwilightLimit)
         {
            _loc1_ = 0;
            timeOfDayCursor._visible = false;
         }
         else if(neverBelowTwilightLimit)
         {
            _loc1_ = -12;
            timeOfDayCursor._visible = false;
         }
         else
         {
            timeOfDayCursor._visible = true;
            _loc1_ = 3.819718634205488 * Math.acos(_loc3_);
         }
         break;
      case "noLock":
         timeOfDayCursor._visible = true;
         _loc1_ = 1.0027397260273974 * (24 * (timeOfDayCursor._x - timelineMC._x) / timelineMC._dimensions.width - 12);
         break;
      case "starRise":
         if(timelineMC.isRiseAndSet)
         {
            timeOfDayCursor._visible = true;
            _loc1_ = 12 + timelineMC.riseAndSetTimes.rise;
         }
         else
         {
            timeOfDayCursor._visible = false;
            _loc1_ = 0;
         }
         break;
      case "starSet":
         if(timelineMC.isRiseAndSet)
         {
            timeOfDayCursor._visible = true;
            _loc1_ = 12 + timelineMC.riseAndSetTimes["set"];
         }
         else
         {
            timeOfDayCursor._visible = false;
            _loc1_ = 0;
         }
   }
   if(lockTimeGroup.getValue() != "noLock")
   {
      timeOfDayCursor._x = timelineMC._x + timelineMC._dimensions.width * (((_loc1_ * 0.9972677595628415 + 12) / 24 % 1 + 1) % 1);
   }
   var sunRightAscension = (3.819718634205488 * Math.atan2(Math.sin(sunLongitude) * 0.9177546256839811,Math.cos(sunLongitude)) % 24 + 24) % 24;
   var eqnOfTime = sunRightAscension - 0.06575342465753424 * (((timelineMC.dayOfYearZB - 78) % 365 + 365) % 365);
   if(lockTimeGroup.getValue() == "starRise" || lockTimeGroup.getValue() == "starSet")
   {
      eqnOfTime = 0;
   }
   sphereMC.siderealTime = timelineMC.siderealTime + _loc1_ + eqnOfTime;
   updateStarDeclinationArc();
}
function updateStarDeclinationArc()
{
   var _loc3_ = Math.sin(timelineMC._declination);
   var sinLat = Math.sin(timelineMC._latitude);
   var cosDec = Math.cos(timelineMC._declination);
   var _loc2_ = Math.cos(timelineMC._latitude);
   var _loc1_ = (- _loc3_) * sinLat / (cosDec * _loc2_);
   if(_loc1_ <= -1)
   {
      sphereMC.declinationArc.setParameters({ra:0,dec:timelineMC.declination,tilt:0});
      sphereMC.declinationArc.visible = true;
   }
   else if(_loc1_ >= 1)
   {
      sphereMC.declinationArc.visible = false;
   }
   else
   {
      var gammaEnd = Math.acos(_loc1_) * 180 / 3.141592653589793;
      var gammaStart = - gammaEnd;
      sphereMC.declinationArc.setParameters({ra:sphereMC.siderealTime,dec:timelineMC.declination,tilt:0,gammaStart:gammaStart,gammaEnd:gammaEnd});
      sphereMC.declinationArc.visible = true;
   }
}
function onDayOfYearZBChanged()
{
   timelineMC.dayOfYearZB = dayOfYearZBSelector.dayOfYearZB;
   sphereMC.sun.dec = timelineMC.sunDeclination;
   sphereMC.sun.ra = timelineMC.sunRightAscension;
   sphereMC.sun.setOrientationType("absolute");
   updateSphere();
}
function onLatitudeChanged()
{
   timelineMC.latitude = latitudeSelector.latitude;
   sphereMC.latitude = timelineMC.latitude;
   updateSphere();
}
function onDeclinationChanged()
{
   timelineMC.declination = declinationSlider.value;
   sphereMC.star.dec = timelineMC.declination;
   sphereMC.star.setOrientationType("absolute");
   sphereMC.declinationCircle.dec = timelineMC.declination;
   updateSphere();
   updateStarPresetsComboBox();
}
function onRightAscensionChanged()
{
   timelineMC.rightAscension = rightAscensionSlider.value;
   sphereMC.star.ra = timelineMC.rightAscension;
   sphereMC.star.setOrientationType("absolute");
   updateSphere();
   updateStarPresetsComboBox();
}
function onStarSelected()
{
   var _loc2_;
   var _loc1_;
   if(starPresetsComboBox.getSelectedIndex() > 0)
   {
      _loc2_ = starPresetsComboBox.getSelectedItem().label;
      _loc1_ = 0;
      while(_loc1_ < starsList.length)
      {
         if(_loc2_ == starsList[_loc1_].name)
         {
            declinationSlider.value = starsList[_loc1_].dec;
            rightAscensionSlider.value = starsList[_loc1_].ra;
            timelineMC.declination = declinationSlider.value;
            timelineMC.rightAscension = rightAscensionSlider.value;
            sphereMC.star.dec = timelineMC.declination;
            sphereMC.star.ra = timelineMC.rightAscension;
            sphereMC.star.setOrientationType("absolute");
            sphereMC.declinationCircle.dec = timelineMC.declination;
            updateSphere();
            break;
         }
         _loc1_ = _loc1_ + 1;
      }
   }
   updateStarPresetsComboBox();
}
function updateStarPresetsComboBox()
{
   var newIndex = 0;
   var _loc2_ = 0;
   var _loc3_;
   var _loc1_;
   while(_loc2_ < starsList.length)
   {
      var raDiff = starsList[_loc2_].ra - timelineMC.rightAscension;
      var decDiff = starsList[_loc2_].dec - timelineMC.declination;
      if(Math.abs(raDiff) < 1e-12 && Math.abs(decDiff) < 1e-12)
      {
         _loc3_ = starPresetsComboBox.dataProvider.items;
         _loc1_ = 1;
         while(_loc1_ < _loc3_.length)
         {
            if(_loc3_[_loc1_].label == starsList[_loc2_].name)
            {
               newIndex = _loc1_;
               break;
            }
            _loc1_ = _loc1_ + 1;
         }
         if(_loc1_ == _loc3_.length)
         {
            trace("WARNING, didn\'t find star");
         }
         break;
      }
      _loc2_ = _loc2_ + 1;
   }
   starPresetsComboBox.setSelectedIndex(newIndex,false);
}
function onReset()
{
   dayOfYearZBSelector.dayOfYearZB = 78;
   latitudeSelector.latitude = 40.8;
   starPresetsComboBox.setSelectedIndex(1);
   sphereMC.setThetaAndPhi(150,35);
   timeOfDayCursor._x = timelineMC._x + timelineMC._dimensions.width / 2;
   lockTimeGroup.setValue("noLock");
   onDayOfYearZBChanged();
   onLatitudeChanged();
}
function init()
{
   timeOfDayCursor.useHandCursor = false;
   timeOfDayCursor.tabEnabled = false;
   timeOfDayCursorColor = new Color(timeOfDayCursor);
   declinationSlider.barMC._visible = false;
   declinationSlider.grabberMC._visible = false;
   rightAscensionSlider.barMC._visible = false;
   rightAscensionSlider.grabberMC._visible = false;
   starPresetsComboBox.setStyleProperty("textSelected",0);
   starPresetsComboBox.setStyleProperty("selection",14540253);
   starPresetsComboBox.setStyleProperty("backgroundDisabled",16777215);
   timelineMC.dayColor = 16641937;
   timelineMC.starVisibilityColor = 3182816;
   timelineMC.twilightAngle = 7;
   timelineMC.setDimensions(690,16);
   timelineMC.timelineLabelsList = timelineMC.timelineLabelsList.concat({hour:1,label:"",fractionalLength:0.5,lineColor:6316128},{hour:2,label:"",fractionalLength:0.5,lineColor:6316128},{hour:3,label:"3<font size=\"-3\">AM</font>"},{hour:4,label:"",fractionalLength:0.5,lineColor:6316128},{hour:5,label:"",fractionalLength:0.5,lineColor:6316128},{hour:7,label:"",fractionalLength:0.5,lineColor:6316128},{hour:8,label:"",fractionalLength:0.5,lineColor:6316128},{hour:9,label:"9<font size=\"-3\">AM</font>"},{hour:10,label:"",fractionalLength:0.5,lineColor:6316128},{hour:11,label:"",fractionalLength:0.5,lineColor:6316128},{hour:13,label:"",fractionalLength:0.5,lineColor:6316128},{hour:14,label:"",fractionalLength:0.5,lineColor:6316128},{hour:15,label:"3<font size=\"-3\">PM</font>"},{hour:16,label:"",fractionalLength:0.5,lineColor:6316128},{hour:17,label:"",fractionalLength:0.5,lineColor:6316128},{hour:19,label:"",fractionalLength:0.5,lineColor:6316128},{hour:20,label:"",fractionalLength:0.5,lineColor:6316128}
   ,{hour:21,label:"9<font size=\"-3\">PM</font>"},{hour:22,label:"",fractionalLength:0.5,lineColor:6316128},{hour:23,label:"",fractionalLength:0.5,lineColor:6316128});
   sphereMC.size = 300;
   sphereMC.minViewerAltitude = 7;
   sphereMC.onMouseUpdate = function()
   {
      updateAfterEvent();
   };
   sphereMC.celestialBowl.removeMovieClip();
   sphereMC.addShadingClip("Shading Layer B","shading1","back","inner","both");
   sphereMC.addShadingClip("Shading Layer A","shading2","front","outer","both");
   sphereMC.addShadingClip("Shading Layer A","shading3","back","outer","both");
   sphereMC.addHorizonPlaneClip("White Direction Labels","directionLabels","above");
   sphereMC.addCircle("meridian1",{thickness:1,color:14737632,alpha:20},{alt:0,az:0,tilt:90});
   sphereMC.addCircle("meridian2",{thickness:1,color:14737632,alpha:20},{alt:0,az:90,tilt:90});
   sphereMC.addCircle("eclipticCircle",{thickness:1,color:14737632,alpha:60},{ra:0,dec:0,tilt:23.4});
   sphereMC.addCircle("zeroHoursCircle",{thickness:1,color:16769909,alpha:100},{ra:0,dec:0,tilt:90,gammaStart:-90,gammaEnd:90});
   sphereMC.addCircle("celestialEquator",{thickness:1,color:16769909,alpha:100},{ra:0,dec:0,tilt:0});
   sphereMC.addCircle("declinationCircle",{thickness:1,color:14737632,alpha:30},{tilt:0,ra:0,dec:45});
   sphereMC.addCircle("declinationArc",{thickness:2,color:timelineMC.starVisibilityColor,alpha:100},{tilt:0,ra:0,dec:45});
   sphereMC.addObject("Star","star",{ra:0,dec:0});
   sphereMC.addObject("Sun","sun",{ra:0,dec:0});
   sphereMC.addObject("Stickfigure","stickfigure",{x:0,y:0,z:0,system:"horizon"},{_xscale:120,_yscale:120});
   sphereMC.stickfigure.setOrientationType("absolute",{x:-1,y:0,z:0,system:"horizon"},{x:0,y:0,z:1,system:"horizon"});
   sphereMC.addLine("ncpAxis",{thickness:2,color:7711231,alpha:100},{x:0,y:0,z:1,system:"celestial"},{x:0,y:0,z:1.2,system:"celestial"});
   sphereMC.addLine("scpAxis",{thickness:2,color:7711231,alpha:100},{x:0,y:0,z:-1,system:"celestial"},{x:0,y:0,z:-1.2,system:"celestial"});
}
starsList = [{name:"Vega",ra:18.6,dec:38.8},{name:"Sirius",ra:6.8,dec:-16.7}];
init();
onReset();
