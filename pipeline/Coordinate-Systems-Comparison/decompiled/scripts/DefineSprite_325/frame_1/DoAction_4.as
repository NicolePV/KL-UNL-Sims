function setLonByTextField()
{
   var _loc1_;
   if(longitudeFieldChanged)
   {
      _loc1_ = parseFloat(longitudeField.text);
      if(!isNaN(_loc1_) && isFinite(_loc1_))
      {
         if(lonDirectionBox.getValue() == "W" && _loc1_ > 0)
         {
            _loc1_ = 360 - _loc1_;
         }
         setLocation({lat:observerLatitude,lon:_loc1_});
      }
      else
      {
         setLocation({lat:observerLatitude,lon:observerLongitude});
      }
      longitudeField.setTextFormat(textFormatOtherwise);
      longitudeField.setNewTextFormat(textFormatOtherwise);
   }
   longitudeFieldChanged = false;
}
function setLatByTextField()
{
   var _loc2_;
   if(latitudeFieldChanged)
   {
      _loc2_ = parseFloat(latitudeField.text);
      if(!isNaN(_loc2_) && isFinite(_loc2_) && _loc2_ >= -90 && _loc2_ <= 90)
      {
         if(latDirectionBox.getValue() == "S" && _loc2_ > 0)
         {
            _loc2_ = - _loc2_;
         }
         setLocation({lat:_loc2_,lon:observerLongitude});
      }
      else
      {
         setLocation({lat:observerLatitude,lon:observerLongitude});
      }
      latitudeField.setTextFormat(textFormatOtherwise);
      latitudeField.setNewTextFormat(textFormatOtherwise);
   }
   latitudeFieldChanged = false;
}
function changePosIntervalFunc()
{
   if(longitudeFieldChanged)
   {
      longitudeField.setTextFormat(textFormatOtherwise);
      longitudeField.setNewTextFormat(textFormatOtherwise);
   }
   else if(latitudeFieldChanged)
   {
      latitudeField.setTextFormat(textFormatOtherwise);
      latitudeField.setNewTextFormat(textFormatOtherwise);
   }
   if(waitTill == null)
   {
      setLocation({lat:observerLatitude + deltaLat,lon:observerLongitude + deltaLon});
   }
   else if(getTimer() > waitTill)
   {
      waitTill = null;
      setLocation({lat:observerLatitude + deltaLat,lon:observerLongitude + deltaLon});
   }
}
function changeLatDirection()
{
   if(latDirectionBox.getValue() == "N")
   {
      setLocation({lat:Math.abs(observerLatitude),lon:observerLongitude});
   }
   else
   {
      setLocation({lat:- Math.abs(observerLatitude),lon:observerLongitude});
   }
}
function changeLonDirection()
{
   if(lonDirectionBox.getValue() == "E")
   {
      if(observerLongitude > 180)
      {
         setLocation({lat:observerLatitude,lon:- observerLongitude});
      }
      else
      {
         setLocation({lat:observerLatitude,lon:observerLongitude});
      }
   }
   else if(observerLongitude > 180)
   {
      setLocation({lat:observerLatitude,lon:observerLongitude});
   }
   else
   {
      setLocation({lat:observerLatitude,lon:- observerLongitude});
   }
}
function setLocation(pt)
{
   var _loc1_ = pt.lat;
   var _loc2_ = pt.lon;
   if(_loc1_ > 90)
   {
      _loc1_ = 90;
   }
   else if(_loc1_ < -90)
   {
      _loc1_ = -90;
   }
   _loc2_ = (_loc2_ % 360 + 360) % 360;
   observerLatitude = _loc1_;
   observerLongitude = _loc2_;
   if(observerLongitude > 180)
   {
      longitudeField.text = Math.abs(observerLongitude - 360).toFixed(1);
      lonDirectionBox.setSelectedIndex(1,false);
   }
   else
   {
      longitudeField.text = observerLongitude.toFixed(1);
      lonDirectionBox.setSelectedIndex(0,false);
   }
   if(observerLatitude < 0)
   {
      latitudeField.text = Math.abs(observerLatitude).toFixed(1);
      latDirectionBox.setSelectedIndex(1,false);
   }
   else
   {
      latitudeField.text = observerLatitude.toFixed(1);
      latDirectionBox.setSelectedIndex(0,false);
   }
   locationSelectorMC.setCursorLocation({lat:observerLatitude,lon:observerLongitude});
   updateAngle();
   sphere1.globeSphere.instance.latitudeCircle.setParameters({ra:0,tilt:0,dec:observerLatitude});
   sphere1.globeSphere.instance.latitudeCircle.update();
   sphere1.globeSphere.instance.observerDot.setPosition({ra:0,dec:observerLatitude});
   sphere1.globeSphere.instance.observerDot.setOrientationType("absolute");
   var _loc3_ = time % 1 * 360;
   var _loc4_ = (observerLongitude + _loc3_) / 15;
   sphere1.globeSphere.instance.customSetSiderealTime(- _loc4_);
   sphere1.globeSphere.instance.globe.instance.setRotationAngle(_loc3_);
   sphere2.setSTimeAndLatDelayedUpdate(_loc4_,observerLatitude);
   if(selectedStar != null)
   {
      updateHorizonArcs();
   }
   sphere2.doSTimeAndLatUpdate();
   updateBands();
}
textFormatWhileEditing = new TextFormat();
textFormatWhileEditing.italic = true;
textFormatOtherwise = new TextFormat();
textFormatOtherwise.italic = false;
focusOn = null;
latitudeField.restrict = "0-9.+\\-";
latitudeField.onChanged = function()
{
   this._parent.latitudeFieldChanged = true;
   this.setTextFormat(this._parent.textFormatWhileEditing);
   this.setNewTextFormat(this._parent.textFormatWhileEditing);
};
latitudeField.onSetFocus = function()
{
   this._parent.focusOn = "lat";
};
latitudeField.onKillFocus = function()
{
   this._parent.focusOn = null;
   this._parent.setLatByTextField();
};
longitudeField.restrict = "0-9.+\\-";
longitudeField.onChanged = function()
{
   this._parent.longitudeFieldChanged = true;
   this.setTextFormat(this._parent.textFormatWhileEditing);
   this.setNewTextFormat(this._parent.textFormatWhileEditing);
};
longitudeField.onSetFocus = function()
{
   this._parent.focusOn = "lon";
};
longitudeField.onKillFocus = function()
{
   this._parent.focusOn = null;
   this._parent.setLonByTextField();
};
posChangeInterval = null;
deltaPos = 5;
deltaLon = 0;
deltaLat = 0;
onKeyDown = function()
{
   if(Key.isDown(13))
   {
      if(focusOn == "lat")
      {
         setLatByTextField();
      }
      else if(focusOn == "lon")
      {
         setLonByTextField();
      }
   }
   var _loc1_ = true;
   if(focusOn == null && starLocationMC.focusOn == null)
   {
      if(Key.isDown(39))
      {
         _loc1_ = false;
         deltaLon = deltaPos;
      }
      else if(Key.isDown(37))
      {
         _loc1_ = false;
         deltaLon = - deltaPos;
      }
      else
      {
         deltaLon = 0;
      }
      if(Key.isDown(38))
      {
         _loc1_ = false;
         deltaLat = deltaPos;
      }
      else if(Key.isDown(40))
      {
         _loc1_ = false;
         deltaLat = - deltaPos;
      }
      else
      {
         deltaLat = 0;
      }
   }
   if(_loc1_)
   {
      clearInterval(posChangeInterval);
      posChangeInterval = null;
   }
   else if(posChangeInterval == null)
   {
      waitTill = null;
      changePosIntervalFunc();
      waitTill = getTimer() + delayTime;
      posChangeInterval = setInterval(changePosIntervalFunc,10);
   }
};
waitTill = null;
delayTime = 400;
onKeyUp = function()
{
   var _loc1_ = true;
   if(Key.isDown(39))
   {
      _loc1_ = false;
      deltaLon = deltaPos;
   }
   else if(Key.isDown(37))
   {
      _loc1_ = false;
      deltaLon = - deltaPos;
   }
   else
   {
      deltaLon = 0;
   }
   if(Key.isDown(38))
   {
      _loc1_ = false;
      deltaLat = deltaPos;
   }
   else if(Key.isDown(40))
   {
      _loc1_ = false;
      deltaLat = - deltaPos;
   }
   else
   {
      deltaLat = 0;
   }
   if(_loc1_)
   {
      clearInterval(posChangeInterval);
      posChangeInterval = null;
   }
};
Key.addListener(this);
locationSelectorMC.onCursorMoved = setLocation;
