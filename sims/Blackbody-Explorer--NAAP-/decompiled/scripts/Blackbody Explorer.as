function BlackbodyExplorerClass()
{
   this.stop();
}
var p = BlackbodyExplorerClass.prototype = new MovieClip();
Object.registerClass("Blackbody Explorer",BlackbodyExplorerClass);
p.minNumCurves = 1;
p.maxNumCurves = 5;
p.curveColorsList = [15753312,6344800,10526960,15580466,10526880];
p.reset = function()
{
   var _loc1_ = this;
   var _loc2_ = 0;
   var _loc3_;
   while(_loc2_ < _loc1_.curvesList.length)
   {
      _loc3_ = _loc1_.curvesList[_loc2_];
      _loc3_.ref.remove();
      _loc1_.curvesListingMC.removeListing(_loc3_.id);
      _loc2_ = _loc2_ + 1;
   }
   _loc1_.curvesFreeID = 0;
   _loc1_.curvesList = [];
   _loc1_.selectedCurve = null;
   _loc1_.tabGroup.setSelected("curves",true);
   _loc1_.scaleTabGroup.setSelected("vertical scale",true);
   _loc1_.showAreaCheck.setValue(false);
   _loc1_.showPeakCheck.setValue(false);
   _loc1_.removeCurveButton.setEnabled(false);
   _loc1_.addCurveButton.setEnabled(true);
   _loc1_.temperatureSlider.value = 6000;
   _loc1_.filterDetailsPanelMC.minuendBox.setSelectedIndex(0);
   _loc1_.filterDetailsPanelMC.subtrahendBox.setSelectedIndex(0);
   var hScale = 1000;
   _loc1_.hScaleSlider.value = hScale;
   _loc1_.onHScaleChanged(hScale);
   _loc1_.scaleModeGroup.setValue("all");
   _loc1_.addCurve();
};
p.init = function()
{
   var _loc1_ = this;
   _loc1_.curvesFreeID = 0;
   _loc1_.curvesList = [];
   _loc1_.selectedCurve = null;
   _loc1_.removeCurveButton.setEnabled(false);
   _loc1_.addCurve();
   _loc1_.onTabSelectionChanged("curves");
   _loc1_.updateFilterDetails();
   _loc1_.onScaleTabSelectionChanged("vertical scale");
};
p.onHScaleChanged = function(wMax)
{
   var _loc1_ = this;
   _loc1_.blackbodyPlotMC.maxWavelength = 1e-9 * wMax;
   _loc1_.blackbodyPlotMC.update(true);
   _loc1_.filterPlotMC._wMaxPlot = wMax;
   _loc1_.updateFilterDetails();
};
p.onScaleTabSelectionChanged = function(selected)
{
   var _loc2_ = this;
   var _loc1_ = selected == "vertical scale";
   _loc2_.autoscaleAutoButton._visible = _loc1_;
   _loc2_.autoscaleAllButton._visible = _loc1_;
   _loc2_.lockScaleButton._visible = _loc1_;
   _loc2_.hScaleGrabber._visible = !_loc1_;
   _loc2_.hScaleBar._visible = !_loc1_;
   _loc2_.hScaleStuffMC._visible = !_loc1_;
};
p.onScaleModeChanged = function()
{
   var _loc1_ = this;
   switch(_loc1_.scaleModeGroup.getValue())
   {
      case "locked":
         _loc1_.blackbodyPlotMC.setVerticalScalingMode("locked");
         break;
      case "all":
         _loc1_.blackbodyPlotMC.setVerticalScalingMode("autoscale");
         _loc1_.blackbodyPlotMC.update();
         _loc1_.filterPlotMC.yScale = _loc1_.blackbodyPlotMC._vScale;
         _loc1_.filterPlotMC.update();
         break;
      case "selected":
         _loc1_.blackbodyPlotMC.setVerticalScalingMode("autoscale",0.9,_loc1_.selectedCurve.name);
         _loc1_.blackbodyPlotMC.update();
         _loc1_.filterPlotMC.yScale = _loc1_.blackbodyPlotMC._vScale;
         _loc1_.filterPlotMC.update();
      default:
         return;
   }
};
p.onTabSelectionChanged = function(selected)
{
   var _loc3_ = this;
   var _loc2_ = selected == "curves";
   _loc3_.filterDetailsPanelMC._visible = !_loc2_;
   _loc3_.filterPlotMC._visible = !_loc2_;
   _loc3_.removeCurveButton._visible = _loc2_;
   _loc3_.addCurveButton._visible = _loc2_;
   _loc3_.curvesListingMC._visible = _loc2_;
   _loc3_.showAreaCheck._visible = _loc2_;
   _loc3_.showPeakCheck._visible = _loc2_;
   var cL = _loc3_.curvesList;
   var n = cL.length;
   var selectedIndex = _loc3_.getCurveIndexFromID(_loc3_.selectedCurve.id);
   var _loc1_ = 0;
   while(_loc1_ < n)
   {
      if(_loc1_ != selectedIndex)
      {
         cL[_loc1_].ref.visible = _loc2_;
      }
      _loc1_ = _loc1_ + 1;
   }
   _loc3_.blackbodyPlotMC.update();
   _loc3_.updateFilterDetails();
};
p.updateFilterDetails = function()
{
   var _loc1_ = this;
   if(_loc1_.tabGroup.getSelected() == "filters")
   {
      _loc1_.filterPlotMC.temperature = _loc1_.selectedCurve.temperature;
      _loc1_.filterPlotMC.yScale = _loc1_.blackbodyPlotMC._vScale;
      _loc1_.filterDetailsPanelMC.setMagnitudes(_loc1_.filterPlotMC.update());
   }
};
p.onTemperatureChanged = function(temp)
{
   var _loc1_ = this;
   _loc1_.selectedCurve.temperature = temp;
   _loc1_.selectedCurve.ref.temperature = temp;
   _loc1_.blackbodyPlotMC.update();
   _loc1_.updateCurveInformation(_loc1_.selectedCurve.id);
   _loc1_.updateFilterDetails();
   _loc1_.updatePeakWavelengthLabel();
};
p.updatePeakWavelengthLabel = function()
{
   var _loc1_ = "peak at " + (1000000000 * this.selectedCurve.ref.getPeakWavelength()).toFixed(1) + " nm";
   this.selectedCurve.ref.peakLabel.setLabel(_loc1_);
};
p.onShowPeakChanged = function()
{
   this.selectedCurve.ref.peakLabel._visible = this.showPeakCheck.getValue();
};
p.onShowAreaChanged = function()
{
   var _loc1_ = this;
   _loc1_.selectedCurve.ref.showFill = _loc1_.showAreaCheck.getValue();
   _loc1_.blackbodyPlotMC.update();
};
p.selectCurve = function(id)
{
   var _loc1_ = this;
   var _loc2_ = id;
   _loc1_.selectedCurve.ref.showFill = false;
   _loc1_.selectedCurve.ref.peakLabel._visible = false;
   _loc1_.selectedCurve.ref.setStyle({alpha:100,thickness:1});
   _loc1_.curvesListingMC.setAppearance(_loc1_.selectedCurve.id,1,_loc1_.selectedCurve.color,70);
   _loc1_.selectedCurve = _loc1_.curvesList[_loc1_.getCurveIndexFromID(_loc2_)];
   _loc1_.selectedCurve.ref.peakLabel._visible = _loc1_.showPeakCheck.getValue();
   _loc1_.selectedCurve.ref.showFill = _loc1_.showAreaCheck.getValue();
   _loc1_.curvesListingMC.setAppearance(_loc2_,3,_loc1_.selectedCurve.color,100);
   _loc1_.temperatureSlider.value = _loc1_.selectedCurve.temperature;
   _loc1_.selectedCurve.ref.setStyle({alpha:100,thickness:3});
   _loc1_.curvesListingMC.setSelectedListing(_loc2_);
   if(_loc1_.scaleModeGroup.getValue() == "selected")
   {
      _loc1_.blackbodyPlotMC.setVerticalScalingMode("autoscale",0.9,_loc1_.selectedCurve.name);
   }
   _loc1_.blackbodyPlotMC.update();
   _loc1_.updatePeakWavelengthLabel();
   _loc1_.updateFilterDetails();
};
p.updateCurveInformation = function(id)
{
   var _loc2_ = this;
   var _loc1_ = _loc2_.selectedCurve.temperature;
   var _loc3_ = 2897768.2864295086 / _loc1_;
   var area = 5.669e-8 * Math.pow(_loc1_,4);
   _loc2_.curvesListingMC.setListingValues(_loc2_.selectedCurve.id,_loc1_,_loc3_,area);
};
p.addCurve = function()
{
   var _loc1_ = this;
   var _loc3_ = _loc1_.curvesFreeID++;
   _loc1_.blackbodyPlotMC.addCurve("_" + _loc3_);
   var _loc2_ = {};
   _loc2_.name = "_" + _loc3_;
   _loc2_.temperature = _loc1_.temperatureSlider.value;
   _loc2_.id = _loc3_;
   _loc2_.ref = _loc1_.blackbodyPlotMC["_" + _loc3_];
   _loc2_.color = _loc1_.curveColorsList[_loc3_ % _loc1_.curveColorsList.length];
   _loc2_.ref.setStyle({color:_loc2_.color,fillColor:_loc2_.color,fillAlpha:30});
   _loc2_.ref.temperature = _loc2_.temperature;
   _loc1_.curvesList.push(_loc2_);
   _loc2_.ref.addPeakLabel("Peak Wavelength Label");
   _loc1_.curvesListingMC.addListing(_loc3_,_loc2_.name);
   _loc1_.selectCurve(_loc3_);
   _loc1_.updateCurveInformation(_loc3_);
   if(_loc1_.curvesList.length > _loc1_.minNumCurves)
   {
      _loc1_.removeCurveButton.setEnabled(true);
   }
   if(_loc1_.curvesList.length >= _loc1_.maxNumCurves)
   {
      _loc1_.addCurveButton.setEnabled(false);
   }
};
p.removeCurve = function()
{
   var _loc1_ = this;
   var _loc2_ = _loc1_.getCurveIndexFromID(_loc1_.selectedCurve.id);
   _loc1_.selectedCurve.ref.remove();
   _loc1_.curvesListingMC.removeListing(_loc1_.selectedCurve.id);
   _loc1_.curvesList.splice(_loc2_,1);
   if(_loc2_ >= _loc1_.curvesList.length)
   {
      _loc1_.selectCurve(_loc1_.curvesList[_loc1_.curvesList.length - 1].id);
   }
   else
   {
      _loc1_.selectCurve(_loc1_.curvesList[_loc2_].id);
   }
   if(_loc1_.curvesList.length <= _loc1_.minNumCurves)
   {
      _loc1_.removeCurveButton.setEnabled(false);
   }
   if(_loc1_.curvesList.length < _loc1_.maxNumCurves)
   {
      _loc1_.addCurveButton.setEnabled(true);
   }
};
p.getCurveIndexFromID = function(id)
{
   var _loc2_ = this.curvesList;
   var _loc3_ = _loc2_.length;
   var _loc1_ = 0;
   while(_loc1_ < _loc3_)
   {
      if(_loc2_[_loc1_].id == id)
      {
         return _loc1_;
      }
      _loc1_ = _loc1_ + 1;
   }
   return 0;
};
