function setStarLocByRaDec()
{
   var _loc4_;
   var _loc3_;
   var _loc2_;
   if(raDecFieldsChanged)
   {
      _loc4_ = parseFloat(rightAscensionField.text);
      _loc3_ = parseFloat(declinationField.text);
      if(!isNaN(_loc4_) && isFinite(_loc4_) && !isNaN(_loc3_) && isFinite(_loc3_))
      {
         if(_loc3_ > 90)
         {
            _loc3_ = 90;
         }
         else if(_loc3_ < -90)
         {
            _loc3_ = -90;
         }
         this._parent.moveStar(this._parent.selectedStar,{ra:_loc4_,dec:_loc3_});
      }
      else
      {
         _loc2_ = {};
         this._parent.sphere1[this._parent.selectedStar].getPositionCelestial(_loc2_);
         this._parent.moveStar(this._parent.selectedStar,_loc2_);
      }
      rightAscensionField.setTextFormat(textFormatOtherwise);
      rightAscensionField.setNewTextFormat(textFormatOtherwise);
      declinationField.setTextFormat(textFormatOtherwise);
      declinationField.setNewTextFormat(textFormatOtherwise);
   }
   raDecFieldsChanged = false;
}
function setStarLocByAzAlt()
{
   var _loc4_;
   var _loc3_;
   var _loc2_;
   if(azAltFieldsChanged)
   {
      _loc4_ = parseFloat(azimuthField.text);
      _loc3_ = parseFloat(altitudeField.text);
      if(!isNaN(_loc4_) && isFinite(_loc4_) && !isNaN(_loc3_) && isFinite(_loc3_))
      {
         if(_loc3_ > 90)
         {
            _loc3_ = 90;
         }
         else if(_loc3_ < -90)
         {
            _loc3_ = -90;
         }
         _loc2_ = {};
         this._parent.sphere2.pointToCelestial({az:_loc4_,alt:_loc3_},_loc2_);
         this._parent.moveStar(this._parent.selectedStar,_loc2_);
      }
      else
      {
         _loc2_ = {};
         this._parent.sphere1[this._parent.selectedStar].getPositionCelestial(_loc2_);
         this._parent.moveStar(this._parent.selectedStar,_loc2_);
      }
      azimuthField.setTextFormat(textFormatOtherwise);
      azimuthField.setNewTextFormat(textFormatOtherwise);
      altitudeField.setTextFormat(textFormatOtherwise);
      altitudeField.setNewTextFormat(textFormatOtherwise);
   }
   azAltFieldsChanged = false;
}
textFormatWhileEditing = new TextFormat();
textFormatWhileEditing.italic = true;
textFormatOtherwise = new TextFormat();
textFormatOtherwise.italic = false;
focusOn = null;
rightAscensionField.restrict = "0-9.+\\-";
rightAscensionField.backgroundColor = 16448250;
rightAscensionField.borderColor = 6710886;
rightAscensionField.onChanged = function()
{
   this._parent.raDecFieldsChanged = true;
   this.setTextFormat(this._parent.textFormatWhileEditing);
   this.setNewTextFormat(this._parent.textFormatWhileEditing);
};
rightAscensionField.onSetFocus = function()
{
   this._parent.focusOn = "raDec";
};
rightAscensionField.onKillFocus = function()
{
   this._parent.focusOn = null;
   this._parent.setStarLocByRaDec();
};
declinationField.restrict = "0-9.+\\-";
declinationField.backgroundColor = 16448250;
declinationField.borderColor = 6710886;
declinationField.onChanged = function()
{
   this._parent.raDecFieldsChanged = true;
   this.setTextFormat(this._parent.textFormatWhileEditing);
   this.setNewTextFormat(this._parent.textFormatWhileEditing);
};
declinationField.onSetFocus = function()
{
   this._parent.focusOn = "raDec";
};
declinationField.onKillFocus = function()
{
   this._parent.focusOn = null;
   this._parent.setStarLocByRaDec();
};
azimuthField.restrict = "0-9.+\\-";
azimuthField.backgroundColor = 16448250;
azimuthField.borderColor = 6710886;
azimuthField.onChanged = function()
{
   this._parent.azAltFieldsChanged = true;
   this.setTextFormat(this._parent.textFormatWhileEditing);
   this.setNewTextFormat(this._parent.textFormatWhileEditing);
};
azimuthField.onSetFocus = function()
{
   this._parent.focusOn = "azAlt";
};
azimuthField.onKillFocus = function()
{
   this._parent.focusOn = null;
   this._parent.setStarLocByAzAlt();
};
altitudeField.restrict = "0-9.+\\-";
altitudeField.backgroundColor = 16448250;
altitudeField.borderColor = 6710886;
altitudeField.onChanged = function()
{
   this._parent.azAltFieldsChanged = true;
   this.setTextFormat(this._parent.textFormatWhileEditing);
   this.setNewTextFormat(this._parent.textFormatWhileEditing);
};
altitudeField.onSetFocus = function()
{
   this._parent.focusOn = "azAlt";
};
altitudeField.onKillFocus = function()
{
   this._parent.focusOn = null;
   this._parent.setStarLocByAzAlt();
};
onKeyDown = function()
{
   if(Key.isDown(13))
   {
      if(focusOn == "raDec")
      {
         setStarLocByRaDec();
      }
      else if(focusOn == "azAlt")
      {
         setStarLocByAzAlt();
      }
   }
};
Key.addListener(this);
