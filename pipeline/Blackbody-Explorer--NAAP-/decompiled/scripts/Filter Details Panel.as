function FilterDetailsPanelClass()
{
}
var p = FilterDetailsPanelClass.prototype = new MovieClip();
Object.registerClass("Filter Details Panel",FilterDetailsPanelClass);
p.setMagnitudes = function(mL)
{
   this.magnitudesList = mL;
   this.update();
};
p.update = function()
{
   var _loc1_ = this;
   var _loc3_ = 1.288659793814433;
   var r = 0.37037037037037035;
   var _loc2_ = 2.5 * Math.log(_loc3_ * _loc3_ / (r * r)) / 2.302585092994046;
   _loc1_.uField.text = (_loc2_ + _loc1_.magnitudesList.U).toFixed(2);
   _loc1_.bField.text = (_loc2_ + _loc1_.magnitudesList.B).toFixed(2);
   _loc1_.vField.text = (_loc2_ + _loc1_.magnitudesList.V).toFixed(2);
   _loc1_.rField.text = (_loc2_ + _loc1_.magnitudesList.R).toFixed(2);
   _loc1_.onColorIndexChanged();
   _loc1_.updateBarGraph();
};
p.onColorIndexChanged = function()
{
   var _loc1_ = this;
   var _loc2_ = _loc1_.magnitudesList[_loc1_.minuendBox.getValue()] - _loc1_.magnitudesList[_loc1_.subtrahendBox.getValue()];
   _loc1_.colorIndexField.text = _loc2_.toFixed(2);
};
p.updateBarGraph = function()
{
   var _loc1_ = this._parent.filterPlotMC.sums;
   var _loc3_ = 5.669e-8 * Math.pow(this._parent.filterPlotMC.temperature,4);
   var _loc2_ = 32500;
   this.barGraphMC.uBar._height = _loc2_ * (3.141592653589793 * _loc1_.U / _loc3_) / 101.6;
   this.barGraphMC.bBar._height = _loc2_ * (3.141592653589793 * _loc1_.B / _loc3_) / 70.45;
   this.barGraphMC.vBar._height = _loc2_ * (3.141592653589793 * _loc1_.V / _loc3_) / 47.7;
   this.barGraphMC.rBar._height = _loc2_ * (3.141592653589793 * _loc1_.R / _loc3_) / 60.65;
};
