function ClusterFittingExplorerClass()
{
}
var p = ClusterFittingExplorerClass.prototype = new MovieClip();
Object.registerClass("Cluster Fitting Explorer",ClusterFittingExplorerClass);
p.onReset = function()
{
   this.showHorizontalBarCheckBox.setValue(false);
   this.barMC.resetBarPosition();
   this.selectorComboBox.setSelectedIndex(0);
   this.draggableAreaMC.offset = 0;
   this.onDrag(0);
   this.calculatorMC.appMagField.text = "";
   this.calculatorMC.absMagField.text = "";
   this.calculatorMC.update();
};
p.onShowHorizontalBarChanged = function()
{
   this.barMC._visible = this.showHorizontalBarCheckBox.getValue();
};
p.onDrag = function(offset)
{
   this.diagramMC.distanceModulus = offset;
   this.barMC.updateValues();
};
p.onSelectorChanged = function()
{
   var _loc4_ = this.selectorComboBox.getValue();
   var _loc3_ = _global.clusterDataSetsList;
   for(var _loc5_ in _loc3_)
   {
      this.diagramMC[_loc5_ + "Layer"]._visible = _loc5_ == _loc4_;
   }
};
p.onDistanceModulusChanged = function()
{
   this.diagramMC.distanceModulus = this.distanceModulusSlider.value;
};
p.init = function()
{
   this.selectorComboBox.addItem("select cluster","topLine");
   this.diagramMC.logTempLabelsList = ["2500","5000","10000","20000"];
   this.diagramMC.setXAxisType("logTemp",3.397939,4.3013);
   var _loc4_ = _global.clusterDataSetsList;
   var _loc3_;
   for(var _loc5_ in _loc4_)
   {
      this.selectorComboBox.addItem(_loc4_[_loc5_].name,_loc5_);
      _loc3_ = _loc5_ + "Layer";
      this.diagramMC.addObjectLayer(_loc3_,false,null,_loc4_[_loc5_].starList);
      this.diagramMC.updateObjects(_loc3_);
      this.diagramMC[_loc3_]._visible = false;
   }
   this.diagramMC.absBolMagAxisLabel = "Absolute Magnitude (M)";
   this.diagramMC.appBolMagAxisLabel = "Apparent Magnitude (m)";
   this.diagramMC.showScale("appBolMag","right");
   this.diagramMC.distanceModulus = 0;
   this.diagramMC.update();
   this.draggableAreaMC.scaleFactor = (- (this.diagramMC._yAxisMax - this.diagramMC._yAxisMin)) / this.draggableAreaMC.height;
   this.draggableAreaMC.offset = 0;
   this.onShowHorizontalBarChanged();
};
