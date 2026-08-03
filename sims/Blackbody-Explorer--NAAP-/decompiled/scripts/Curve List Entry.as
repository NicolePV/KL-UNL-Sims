function CurveListEntryClass()
{
   var _loc1_ = this;
   _loc1_.attachMovie("Scientific Notation Number","areaNumber",55,{_x:184.5,_y:21.8,initValue:3140000,initSigFigs:3,initJustification:"center"});
   _loc1_.swatchColor = new Color(_loc1_.swatchMC);
   _loc1_.stop();
   _loc1_.setName(_loc1_.initName);
   _loc1_.borderMC._visible = false;
}
var p = CurveListEntryClass.prototype = new MovieClip();
Object.registerClass("Curve List Entry",CurveListEntryClass);
p.useHandCursor = false;
p.onPress = function()
{
   this.mainMC.selectCurve(this.curveID);
};
p.onRollOver = function()
{
   this.borderMC._visible = true;
};
p.onRollOut = function()
{
   this.borderMC._visible = false;
};
p.onReleaseOutside = function()
{
   this.borderMC._visible = false;
};
p.setSelectedState = function(arg)
{
   var _loc1_ = this;
   if(arg)
   {
      _loc1_.gotoAndStop(2);
      _loc1_.areaNumber.coefficientField.textColor = 0;
      _loc1_.areaNumber.exponentField.textColor = 0;
      _loc1_.areaNumber.timesTenField.textColor = 0;
   }
   else
   {
      _loc1_.gotoAndStop(1);
      _loc1_.areaNumber.coefficientField.textColor = 8421504;
      _loc1_.areaNumber.exponentField.textColor = 8421504;
      _loc1_.areaNumber.timesTenField.textColor = 8421504;
   }
};
p.setAppearance = function(thickness, color, alpha)
{
   this.swatchColor.setRGB(color);
};
p.setValues = function(temp, peak, area)
{
   var _loc1_ = this;
   _loc1_.tempField.text = Math.toSigDigits(temp,3) + " K";
   _loc1_.peakField.text = peak.toFixed(1) + " nm";
   _loc1_.areaNumber.setValue(area);
};
