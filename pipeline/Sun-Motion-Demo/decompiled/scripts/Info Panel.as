function InfoPanelClass()
{
}
var p = InfoPanelClass.prototype = new MovieClip();
Object.registerClass("Info Panel",InfoPanelClass);
p.showAnalemmaChanged = function()
{
   this.masterMC.analemmaMC.visible = this.showAnalemmaCheck.getValue();
};
p.update = function()
{
   var _loc2_ = this.masterMC;
   var _loc7_ = "The horizon diagram is shown for an observer at latitude " + _loc2_.latitudePanel.latitudeString;
   _loc7_ += " on " + _loc2_.dayOfYearPanel.dayOfMonthString + " " + _loc2_.dayOfYearPanel.monthString;
   _loc7_ += " at " + _loc2_.timeOfDayPanel.timeOfDayString + " (" + _loc2_.timeOfDayPanel.traditionalTimeString + ").";
   this.infoString = _loc7_;
   this.azString = _loc2_.azimuth.toFixed(1) + "°";
   this.altString = _loc2_.altitude.toFixed(1) + "°";
   var _loc3_ = Math.floor;
   var _loc14_ = _loc2_.rightAscension;
   var _loc10_ = _loc3_(_loc14_);
   var _loc20_ = _loc3_(60 * (_loc14_ - _loc10_));
   this.raString = String(_loc10_) + "h " + String(_loc20_) + "m";
   this.decString = _loc2_.declination.toFixed(1) + "°";
   var _loc5_ = _loc2_.equationOfTime;
   var _loc8_;
   if(_loc5_ < 0)
   {
      _loc8_ = "-";
   }
   else
   {
      _loc8_ = "";
   }
   _loc5_ = Math.abs(_loc5_);
   var _loc6_ = _loc3_(_loc5_);
   var _loc9_ = _loc3_(60 * (_loc5_ - _loc6_));
   if(_loc9_ < 10)
   {
      _loc8_ += _loc6_ + ":0" + _loc9_;
   }
   else
   {
      _loc8_ += _loc6_ + ":" + _loc9_;
   }
   this.eqnString = _loc8_;
   var _loc13_ = _loc2_.siderealTime;
   var _loc15_ = _loc3_(_loc13_);
   var _loc18_ = _loc3_(60 * (_loc13_ - _loc15_));
   this.siderealString = String(_loc15_) + "h " + String(_loc18_) + "m";
   var _loc4_ = _loc2_.hourAngle;
   var _loc11_;
   var _loc12_;
   var _loc17_;
   var _loc16_;
   var _loc19_;
   if(_loc4_ > 12)
   {
      _loc4_ -= 24;
      _loc11_ = Math.abs(_loc4_);
      _loc12_ = _loc3_(_loc11_);
      _loc17_ = _loc3_(60 * (_loc11_ - _loc12_));
      this.hourAngleString = "-" + String(_loc12_) + "h " + String(_loc17_) + "m";
   }
   else
   {
      _loc16_ = _loc3_(_loc4_);
      _loc19_ = _loc3_(60 * (_loc4_ - _loc16_));
      this.hourAngleString = String(_loc16_) + "h " + String(_loc19_) + "m";
   }
};
