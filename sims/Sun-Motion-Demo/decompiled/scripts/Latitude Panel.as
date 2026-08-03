function LatitudePanelClass()
{
   this.hemisphereTogglerMC.useHandCursor = false;
   this.hemisphereTogglerMC.onPress = function()
   {
      this._parent.masterMC.setLatitude(- this._parent._panelLatitude);
   };
   this.latitudeTextField.restrict = ".0-9";
   this.latitudeTextField.onChanged = function()
   {
      var _loc3_ = new TextFormat();
      _loc3_.bold = true;
      this.setTextFormat(_loc3_);
      this.setNewTextFormat(_loc3_);
      this._parent.wait = getTimer() + this._parent.delay;
      this._parent.onEnterFrame = function()
      {
         var _loc2_;
         if(getTimer() > this.wait)
         {
            _loc2_ = new TextFormat();
            _loc2_.bold = false;
            this.latitudeTextField.setTextFormat(_loc2_);
            this.latitudeTextField.setNewTextFormat(_loc2_);
            if(this._panelLatitude < 0)
            {
               this.masterMC.setLatitude(- parseFloat(this.latitudeTextField.text));
            }
            else
            {
               this.masterMC.setLatitude(parseFloat(this.latitudeTextField.text));
            }
            delete this.onEnterFrame;
            Key.removeListener(this);
         }
      };
      Key.addListener(this._parent);
   };
   this.latitudeTextField.onKillFocus = function()
   {
      var _loc2_;
      if(this._parent.onEnterFrame != undefined)
      {
         _loc2_ = new TextFormat();
         _loc2_.bold = false;
         this.setTextFormat(_loc2_);
         this.setNewTextFormat(_loc2_);
         if(this._parent._panelLatitude < 0)
         {
            this._parent.masterMC.setLatitude(- parseFloat(this.text));
         }
         else
         {
            this._parent.masterMC.setLatitude(parseFloat(this.text));
         }
         delete this._parent.onEnterFrame;
         Key.removeListener(this._parent);
      }
   };
}
var p = LatitudePanelClass.prototype = new MovieClip();
Object.registerClass("Latitude Panel",LatitudePanelClass);
p.precision = 1;
p.minStep = Math.pow(10,- p.precision);
p.delay = 1250;
p.onKeyUp = function()
{
   var _loc2_;
   if(Key.getCode() == 13)
   {
      _loc2_ = new TextFormat();
      _loc2_.bold = false;
      this.latitudeTextField.setTextFormat(_loc2_);
      this.latitudeTextField.setNewTextFormat(_loc2_);
      if(this._panelLatitude < 0)
      {
         this.masterMC.setLatitude(- parseFloat(this.latitudeTextField.text));
      }
      else
      {
         this.masterMC.setLatitude(parseFloat(this.latitudeTextField.text));
      }
      delete this.onEnterFrame;
      Key.removeListener(this);
   }
};
p.update = function()
{
   this._panelLatitude = this.masterMC.getLatitude();
   this.latitudeSelectorMC.setCursorLatitude(this._panelLatitude);
   var _loc2_;
   if(this._panelLatitude < 0)
   {
      _loc2_ = Math.abs(this._panelLatitude).toFixed(this.precision);
      this._panelLatitude = - parseFloat(_loc2_);
      this.latitudeTextField.text = _loc2_;
      this.hemisphereTextField.text = "° S";
      this.latitudeString = _loc2_ + "° S";
   }
   else
   {
      _loc2_ = this._panelLatitude.toFixed(this.precision);
      this._panelLatitude = parseFloat(_loc2_);
      this.latitudeTextField.text = _loc2_;
      this.hemisphereTextField.text = "° N";
      this.latitudeString = _loc2_ + "° N";
   }
};
