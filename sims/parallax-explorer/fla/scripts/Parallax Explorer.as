function ParallaxExplorerClass()
{
}
var p = ParallaxExplorerClass.prototype = new MovieClip();
Object.registerClass("Parallax Explorer",ParallaxExplorerClass);
p.presetsList = [{name:"Preset A",showBoat:true,boatVisibilityIsAdjustable:true,error:0,cutoff:2,errorIsAdjustable:true,boatPosition:{x:395,y:190},observerPosition:200,observerPositionsList:[]},{name:"Preset B",showBoat:false,boatVisibilityIsAdjustable:true,error:3,cutoff:2,errorIsAdjustable:false,boatPosition:{x:220,y:220},observerPosition:300,observerPositionsList:[]},{name:"Preset C",showBoat:false,boatVisibilityIsAdjustable:false,error:5,cutoff:2,errorIsAdjustable:false,boatPosition:{x:180,y:150},observerPosition:100,observerPositionsList:[100,130]}];
p.init = function()
{
   var _loc2_ = 0;
   while(_loc2_ < this.presetsList.length)
   {
      this.presetsComboBox.addItem(this.presetsList[_loc2_].name,this.presetsList[_loc2_]);
      _loc2_ = _loc2_ + 1;
   }
   this.onPresetSelected();
};
p.onReset = function()
{
   this.presetsComboBox.setSelectedIndex(0,true);
};
p.onPresetSelected = function()
{
   var _loc2_ = this.presetsComboBox.getValue();
   this.showRulerCheckBox.setValue(false);
   this.showBoatCheckBox.setValue(_loc2_.showBoat);
   this.showBoatCheckBox.setEnabled(_loc2_.boatVisibilityIsAdjustable);
   this.mapMC.setBoatPosition(_loc2_.boatPosition);
   this.mapMC.setBoatVisibility(_loc2_.showBoat);
   this.errorSlider.value = _loc2_.error;
   this.errorSlider.userEnabled = _loc2_.errorIsAdjustable;
   this.errorSlider.update();
   this.mapMC.setObserverPosition(_loc2_.observerPosition);
   this.mapMC.observerPositionsList = _loc2_.observerPositionsList;
   this.mapMC.refresh();
   this.viewMC.setBoatPosition(_loc2_.boatPosition.x,_loc2_.boatPosition.y,(_loc2_.boatPosition.y - 30) / 370);
   this.viewMC.setObserverPosition(_loc2_.observerPosition,this.mapMC.observerMC._y);
};
p.onObserverPositionChanged = function(observerX)
{
   this.viewMC.setObserverPosition(observerX,this.mapMC.observerMC._y);
};
p.onShowBoatChanged = function()
{
   this.mapMC.setBoatVisibility(this.showBoatCheckBox.getValue());
};
p.onShowRulerChanged = function()
{
   this.mapMC.rulerMC._visible = this.showRulerCheckBox.getValue();
};
p.takeMeasurement = function()
{
   var _loc2_ = this.presetsComboBox.getValue();
   this.mapMC.takeMeasurement(this.errorSlider.value,_loc2_.cutoff);
};
p.clearMeasurements = function()
{
   this.mapMC.clearMeasurements();
};
