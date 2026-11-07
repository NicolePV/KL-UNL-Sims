function SettingsPanelClass()
{
}
var p = SettingsPanelClass.prototype = new MovieClip();
Object.registerClass("Settings Panel",SettingsPanelClass);
p.showEclipticChanged = function()
{
   this.masterMC.sphereMC.eclipticCircle.visible = this.showEclipticCheck.getValue();
};
p.showSunDecChanged = function()
{
   this.masterMC.sphereMC.decCircle.visible = this.showSunDecCheck.getValue();
};
p.showUndersideChanged = function()
{
   this.masterMC.sphereMC.showUnder = this.showUndersideCheck.getValue();
};
p.showMonthLabelsChanged = function()
{
   var _loc3_ = this.masterMC.sphereMC;
   var _loc4_ = this.masterMC.monthLabels;
   var _loc2_;
   if(this.showMonthLabelsCheck.getValue())
   {
      _loc2_ = 0;
      while(_loc2_ < 12)
      {
         _loc3_[_loc4_[_loc2_]].visible = true;
         _loc2_ = _loc2_ + 1;
      }
      _loc3_.updateObjects();
   }
   else
   {
      _loc2_ = 0;
      while(_loc2_ < 12)
      {
         _loc3_[_loc4_[_loc2_]].visible = false;
         _loc2_ = _loc2_ + 1;
      }
   }
};
p.showStickfigureChanged = function()
{
   if(this.showStickfigureCheck.getValue())
   {
      this.masterMC.sphereMC.stickfigure.visible = true;
      this.masterMC.sphereMC.shadow.visible = true;
      this.masterMC.sphereMC.shadow.instance.setSourcePosition({alt:this.masterMC.altitude,az:this.masterMC.azimuth});
      this.masterMC.sphereMC.updateObjects();
   }
   else
   {
      this.masterMC.sphereMC.stickfigure.visible = false;
      this.masterMC.sphereMC.shadow.visible = false;
   }
};
p.sunDragBehaviorChanged = function()
{
   var _loc2_ = this.sunDragBehaviorGroup.getValue();
   if(typeof _loc2_ == "string")
   {
      this.masterMC.sunDragMode = this.sunDragBehaviorGroup.getValue();
   }
};
