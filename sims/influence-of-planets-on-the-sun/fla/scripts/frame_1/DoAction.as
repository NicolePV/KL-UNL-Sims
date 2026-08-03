function activity_Setup()
{
   format1 = new TextFormat();
   format1.font = "Trebuchet MS";
   format1.size = 16;
   format1.align = "left";
   format1.color = 65280;
   gradualChange = 0;
   level = 100;
   sunArray = {radius:695500,onscreenradius:sun.globe._width / 2 * (sun._xscale / 100),mass:{a:1.989,b:30}};
   trace("sun radius (onscreen): " + sunArray.onscreenradius);
   kmPerPixel = sunArray.radius / sunArray.onscreenradius;
   daysPerSecond = 500;
   daysTotal = 0;
   sunpathArray = {counter:0,positionarray:new Array()};
   sunpathSize = 100;
   sunpathSegmentMinimum = 10;
   sunpathcurveArray = new Array();
   planetArray = new Array();
   planetArray.push({planetname:"Mercury",mass:{a:3.3022,b:23},distance:{a:5.7909175,b:7},orbitperiod:87.97});
   planetArray.push({planetname:"Venus",mass:{a:4.8685,b:24},distance:{a:1.0820893,b:8},orbitperiod:224.7});
   planetArray.push({planetname:"Earth",mass:{a:5.9737,b:24},distance:{a:1.4959789,b:8},orbitperiod:365.24});
   planetArray.push({planetname:"Mars",mass:{a:6.4185,b:23},distance:{a:2.2793664,b:8},orbitperiod:686.93});
   planetArray.push({planetname:"Jupiter",mass:{a:1.8987,b:27},distance:{a:7.7841202,b:8},orbitperiod:4330.6});
   planetArray.push({planetname:"Saturn",mass:{a:5.6851,b:26},distance:{a:1.4267254,b:9},orbitperiod:10755.7});
   planetArray.push({planetname:"Uranus",mass:{a:8.6849,b:25},distance:{a:2.8709722,b:9},orbitperiod:30687.2});
   planetArray.push({planetname:"Neptune",mass:{a:1.0244,b:26},distance:{a:4.4982529,b:9},orbitperiod:60190});
   planetArray.push({planetname:"Pluto",mass:{a:1.3,b:22},distance:{a:5.90638,b:9},orbitperiod:90553});
   var i = 0;
   while(i < planetArray.length)
   {
      planetArray[planetArray[i].planetname] = planetArray[i];
      planetArray[i].status = false;
      planetArray[i].anglestarting = Math.random() * 3600;
      planetArray[i].anglecurrent = planetArray[i].anglestarting;
      i++;
   }
   var i = 0;
   while(i < planetArray.length)
   {
      planetArray[i].mass.earthbased = planetArray[i].mass.a / planetArray.Earth.mass.a * Math.pow(10,planetArray[i].mass.b - planetArray.Earth.mass.b);
      planetArray[i].distance.earthbased = planetArray[i].distance.a / planetArray.Earth.distance.a * Math.pow(10,planetArray[i].distance.b - planetArray.Earth.distance.b);
      trace("mass of " + planetArray[i].planetname + " (based on earth): " + planetArray[i].mass.earthbased);
      trace("distance of " + planetArray[i].planetname + " (based on earth): " + planetArray[i].distance.earthbased);
      i++;
   }
   sunArray.mass.earthbased = sunArray.mass.a / planetArray.Earth.mass.a * Math.pow(10,sunArray.mass.b - planetArray.Earth.mass.b);
   myListener = new Object();
   myListener.click = function(eventObject)
   {
      resetSun();
      daysTotal = 0;
      var _loc1_ = Number(eventObject.target._name.split("_")[1]);
      planetArray[_loc1_].status = !planetArray[_loc1_].status;
      gradualChange = 5;
   };
   i = 0;
   while(i < planetArray.length)
   {
      var checkboxName = "checkbox_" + i;
      if(i > 0)
      {
         checkboxObject = checkbox_0.duplicateMovieClip(checkboxName,level++);
         checkboxObject._x = checkbox_0._x;
         checkboxObject._y = checkbox_0._y + 45 * i;
      }
      else
      {
         checkboxObject = eval(checkboxName);
      }
      checkboxObject.color = 16777215;
      checkboxObject.scaleX = 150;
      checkboxObject.scaleY = 150;
      checkboxObject.label = " " + planetArray[i].planetname;
      checkboxObject.selected = false;
      checkboxObject.addEventListener("click",myListener);
      var textfieldName = "distanceTextField_" + i;
      _root.createTextField(textfieldName,level++,checkboxObject._x + 110,checkboxObject._y + 2,15,100);
      var textfieldObject = eval(textfieldName);
      var planetDistance = planetArray[i].distance.earthbased;
      var fixedDigits = planetDistance >= 1 ? 1 : 3;
      planetDistance = math_computeFixedDigits(planetDistance,fixedDigits);
      textfieldObject.text = planetDistance + " AU";
      textfieldObject.setTextFormat(format1);
      textfieldObject.autoSize = "left";
      textfieldObject.embedFonts = true;
      trace(textfieldObject.text);
      i++;
   }
   time_Starting = new Date();
   sun.onEnterFrame = function()
   {
      this._parent.body_Update(this);
   };
}
function body_Update(bodyObject)
{
   var time_Current = new Date();
   var secondsElapsed = (time_Current.getTime() - time_Starting.getTime()) / 1000;
   var daysElapsed = daysPerSecond * secondsElapsed;
   daysTotal += daysElapsed;
   yearsTextField.text = math_computeFixedDigits(daysTotal / 365,1,true);
   var xDelta = 0;
   var yDelta = 0;
   var i = 0;
   while(i < planetArray.length)
   {
      if(planetArray[i].status)
      {
         var periodPortion = daysElapsed / planetArray[i].orbitperiod;
         periodPortion -= Math.floor(periodPortion);
         planetArray[i].anglecurrent = planetArray[i].anglestarting - periodPortion * 360;
         planetArray[i].anglecurrent = planetArray[i].anglecurrent >= 0 ? planetArray[i].anglecurrent : planetArray[i].anglecurrent + 360;
         sunDistanceEarthbased = planetArray[i].mass.earthbased * planetArray[i].distance.earthbased / sunArray.mass.earthbased;
         sunDistanceKM = sunDistanceEarthbased * planetArray.Earth.distance.a * Math.pow(10,planetArray.Earth.distance.b);
         xDelta -= Math.cos(6.283185307179586 * planetArray[i].anglecurrent / 360) * sunDistanceKM / kmPerPixel;
         yDelta -= Math.sin(6.283185307179586 * planetArray[i].anglecurrent / 360) * sunDistanceKM / kmPerPixel;
         planetArray[i].anglestarting = planetArray[i].anglecurrent;
      }
      i++;
   }
   trace("GravityCenter = " + gravityCenter._x + "," + gravityCenter._y);
   trace("Delta = " + xDelta + "," + yDelta);
   sun._x = gravityCenter._x + xDelta;
   sun._y = gravityCenter._y + yDelta;
   time_Starting = new Date();
   var sunpathIndex = sunpathArray.positionarray.length - 2;
   var deltaX = Math.abs(sun._x - sunpathArray.positionarray[sunpathIndex].x);
   var deltaY = Math.abs(sun._y - sunpathArray.positionarray[sunpathIndex].y);
   var distance = Math.sqrt(Math.pow(deltaX,2) + Math.pow(deltaY,2));
   if(distance < sunpathSegmentMinimum)
   {
      sunpathArray.counter--;
      var sunpathName = "sunpath_" + sunpathArray.counter;
      var sunpathClip = eval(sunpathName);
      sunpathClip.removeMovieClip();
      sunpathArray.positionarray.pop();
   }
   else
   {
      sunpathcurveArray = new Array();
   }
   sunpathcurveArray.push({x:sun._x,y:sun._y});
   var sunpathName = "sunpath_" + sunpathArray.counter++;
   this.createEmptyMovieClip(sunpathName,level++);
   var sunpathClip = eval(sunpathName);
   sunpathClip._x = sunpathClip._y = 0;
   sunpathArray.positionarray.push({clip:sunpathClip,x:sun._x,y:sun._y});
   sunpathIndex = sunpathArray.positionarray.length - 1;
   if(sunpathArray.positionarray.length > 1)
   {
      sunpathClip.lineStyle(2,16777215,100);
      sunpathClip.moveTo(sunpathArray.positionarray[sunpathIndex - 1].x,sunpathArray.positionarray[sunpathIndex - 1].y);
      if(gradualChange >= 5)
      {
         gradualChange--;
      }
      else if(sunpathcurveArray.length < 2)
      {
         sunpathClip.lineTo(sunpathArray.positionarray[sunpathIndex].x,sunpathArray.positionarray[sunpathIndex].y);
      }
      else
      {
         var sunpathcurveIndex = Math.floor((sunpathcurveArray.length - 1) / 2);
         if((sunpathcurveArray.length - 1) / 2 == sunpathcurveIndex)
         {
            var curvetoX = (sunpathcurveArray[sunpathcurveIndex].x + sunpathcurveArray[sunpathcurveIndex + 1].x) / 2;
            var curvetoY = (sunpathcurveArray[sunpathcurveIndex].y + sunpathcurveArray[sunpathcurveIndex + 1].y) / 2;
         }
         else
         {
            var curvetoX = sunpathcurveArray[sunpathcurveIndex].x;
            var curvetoY = sunpathcurveArray[sunpathcurveIndex].y;
         }
         sunpathClip.curveTo(curvetoX,curvetoY,sunpathArray.positionarray[sunpathIndex].x,sunpathArray.positionarray[sunpathIndex].y);
      }
   }
   if(distance >= sunpathSegmentMinimum)
   {
      var i = 0;
      while(i < sunpathArray.positionarray.length - 1)
      {
         sunpathArray.positionarray[i].clip._alpha -= 1;
         i++;
      }
   }
   if(sunpathArray.positionarray.length > sunpathSize)
   {
      var sunpathClip_Last = sunpathArray.positionarray.shift();
      sunpathClip_Last.clip.removeMovieClip();
   }
}
function onClick(value1, value2)
{
   trace("value1: " + value1);
   trace("value2: " + value2);
}
function resetSun()
{
   trace("remove path");
   var i = 0;
   while(i < sunpathArray.counter)
   {
      var sunpathName = "sunpath_" + i;
      var sunpathClip = eval(sunpathName);
      sunpathClip.removeMovieClip();
      i++;
   }
}
function onSliderChanged(sliderValue)
{
   daysPerSecond = sliderValue;
}
function math_computeFixedDigits(numInput, numDigits, forceFlag)
{
   numInput *= Math.pow(10,numDigits);
   numInput = Math.round(numInput);
   numInput /= Math.pow(10,numDigits);
   var _loc2_ = String(numInput);
   var _loc6_;
   var _loc3_;
   var _loc1_;
   if(forceFlag)
   {
      _loc6_ = _loc2_.split(".");
      if(_loc6_.length <= 1)
      {
         _loc2_ += ".";
      }
      _loc3_ = _loc6_[1] == undefined ? 0 : _loc6_[1].length;
      _loc1_ = _loc3_;
      while(_loc1_ < numDigits)
      {
         _loc2_ += "0";
         _loc1_ = _loc1_ + 1;
      }
   }
   return _loc2_;
}
