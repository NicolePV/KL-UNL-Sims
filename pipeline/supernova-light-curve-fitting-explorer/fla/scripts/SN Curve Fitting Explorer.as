function SNCurveFittingExplorerClass()
{
}
var p = SNCurveFittingExplorerClass.prototype = new MovieClip();
Object.registerClass("SN Curve Fitting Explorer",SNCurveFittingExplorerClass);
p.peakAbsMag = -19.5;
p.timeRange = 450;
p.timeAtLeft = -50;
p.labelledTimeTickmarksList = [-50,0,50,100,150,200,250,300,350,400];
p.unlabelledTimeTickmarksList = [-25,25,75,125,175,225,275,325,375];
p.onReset = function()
{
   this.showHorizontalBarCheckBox.setValue(false);
   this.barMC.resetBarPosition();
   this.selectorComboBox.setSelectedIndex(0,true);
   this.draggableAreaMC.xOffset = 0;
   this.draggableAreaMC.yOffset = 0;
   this.onDrag(0,0);
   this.calculatorMC.absMagField.text = "";
   this.calculatorMC.appMagField.text = "";
   this.calculatorMC.update();
};
p.init = function()
{
   var _loc26_ = getTimer();
   HRDiagramDotClassRev1.prototype.dotColor = 1924851;
   HRDiagramDotClassRev1.prototype.dotSize = 3;
   this.selectorComboBox.addItem("select a supernova...",-1);
   this.plotMC.typeLabelsList = ["0.0","0.25","0.5","0.75","2.0"];
   this.plotMC.setXAxisType("type",0,1);
   this.plotMC.showScale("none","bottom");
   this.plotMC.absBolMagAxisLabel = "Absolute Magnitude (M<sub>B</sub>)";
   this.plotMC.appBolMagAxisLabel = "Apparent Magnitude (m<sub>B</sub>)";
   this.plotMC.showScale("appBolMag","right");
   this.plotMC.setYAxisType("absBolMag",-22,-10);
   this.plotMC.distanceModulus = 0;
   this.plotMC.addObject("Empty Movie Clip","curve",null,null,{type:(- this.timeAtLeft) / this.timeRange,absBolMag:this.peakAbsMag});
   this.plotMC.update();
   var _loc10_ = _global.snList;
   var _loc13_ = this.plotMC.plotWidth / this.timeRange;
   var _loc7_;
   var _loc6_;
   var _loc11_;
   var _loc5_;
   var _loc4_;
   var _loc9_;
   var _loc3_;
   for(var _loc22_ in _loc10_)
   {
      this.selectorComboBox.addItem(_loc10_[_loc22_].name,_loc22_);
      _loc7_ = "_" + _loc22_ + "Layer";
      _loc6_ = _loc10_[_loc22_].observationsList;
      _loc11_ = _loc10_[_loc22_].observationsList[0].JD;
      _loc5_ = Infinity;
      _loc4_ = -Infinity;
      _loc9_ = 0;
      while(_loc9_ < _loc6_.length)
      {
         _loc3_ = _loc6_[_loc9_];
         _loc3_.type = _loc13_ * (_loc3_.JD - _loc11_) * (1 / this.plotMC.plotWidth);
         _loc3_.absBolMag = _loc3_.B;
         if(_loc3_.B < _loc5_)
         {
            _loc5_ = _loc3_.B;
         }
         if(_loc3_.B > _loc4_)
         {
            _loc4_ = _loc3_.B;
         }
         _loc9_ = _loc9_ + 1;
      }
      this.plotMC.addObjectLayer(_loc7_,false,null,_loc6_);
      this.plotMC.updateObjects(_loc7_);
      this.plotMC[_loc7_]._visible = false;
      this.plotMC[_loc7_].minMag = _loc5_;
      this.plotMC[_loc7_].maxMag = _loc4_;
   }
   this.draggableAreaMC._x = this.plotMC._x;
   this.draggableAreaMC._y = this.plotMC._y - this.draggableAreaMC.height;
   this.draggableAreaMC.yScaleFactor = (- (this.plotMC._yAxisMax - this.plotMC._yAxisMin)) / this.draggableAreaMC.height;
   this.draggableAreaMC.yOffset = 0;
   this.draggableAreaMC.xScaleFactor = 1;
   this.draggableAreaMC.xOffset = 0;
   this.draggableAreaMC.minXOffset = 0;
   this.draggableAreaMC.maxXOffset = 200;
   _loc13_ = 1.205141938939475 * (this.plotMC.plotWidth / this.timeRange);
   var _loc12_ = 0.0330760749724366 * (this.plotMC.plotHeight / (this.plotMC._yAxisMax - this.plotMC._yAxisMin));
   var _loc14_ = 0;
   var _loc15_ = 0.1;
   var _loc25_ = {x:-11.5,y:108.25};
   var _loc16_ = [{cx:-12.9,cy:70.6,ax:-8.8,ay:30},{cx:-5.7,cy:0.2,ax:0,ay:0.1},{cx:5.1,cy:-0.1,ax:12.9,ay:28.4},{cx:17,cy:43.3,ax:20.1,ay:58.2},{cx:21.5,cy:64.8,ax:27.7,ay:79},{cx:30.4,cy:85.2,ax:35.8,ay:90.9},{cx:42.2,cy:97.5,ax:73.8,ay:112.6},{cx:112.5,cy:131,ax:314.3,ay:233.3}];
   var _loc17_ = this.plotMC.curve;
   _loc17_.clear();
   _loc17_.lineStyle(1,13643824);
   _loc17_.moveTo(_loc13_ * (_loc25_.x - _loc14_),_loc12_ * (_loc25_.y - _loc15_));
   _loc9_ = 0;
   var _loc8_;
   while(_loc9_ < _loc16_.length)
   {
      _loc8_ = _loc16_[_loc9_];
      _loc17_.curveTo(_loc13_ * (_loc8_.cx - _loc14_),_loc12_ * (_loc8_.cy - _loc15_),_loc13_ * (_loc8_.ax - _loc14_),_loc12_ * (_loc8_.ay - _loc15_));
      _loc9_ = _loc9_ + 1;
   }
   var _loc24_ = this.plotMC.tickmarkLabelTextFormat;
   _loc17_ = this.plotMC.scalesMC.bottomMC;
   _loc17_.lineStyle(1,0,100);
   _loc9_ = 0;
   var _loc22_;
   while(_loc9_ < this.unlabelledTimeTickmarksList.length)
   {
      _loc22_ = this.plotMC.plotWidth * ((this.unlabelledTimeTickmarksList[_loc9_] - this.timeAtLeft) / this.timeRange);
      _loc17_.moveTo(_loc22_,0);
      _loc17_.lineTo(_loc22_,3);
      _loc9_ = _loc9_ + 1;
   }
   _loc9_ = 0;
   while(_loc9_ < this.labelledTimeTickmarksList.length)
   {
      _loc22_ = this.plotMC.plotWidth * ((this.labelledTimeTickmarksList[_loc9_] - this.timeAtLeft) / this.timeRange);
      _loc17_.moveTo(_loc22_,0);
      _loc17_.lineTo(_loc22_,6);
      this.plotMC.displayText(this.labelledTimeTickmarksList[_loc9_],{mc:_loc17_,x:_loc22_,y:9,vAlign:"top",hAlign:"center",embedFonts:true,textFormat:_loc24_});
      _loc9_ = _loc9_ + 1;
   }
   this.barMC.updateValues();
   this.onShowHorizontalBarChanged();
   trace("init time: " + (getTimer() - _loc26_));
};
p.onSelectorChanged = function()
{
   var _loc6_ = this.selectorComboBox.getValue();
   var _loc5_ = _global.snList;
   var _loc3_;
   var _loc4_;
   for(var _loc7_ in _loc5_)
   {
      if(_loc7_ == _loc6_)
      {
         _loc3_ = this.plotMC["_" + _loc7_ + "Layer"];
         _loc3_._visible = true;
         _loc4_ = 1;
         this.draggableAreaMC.minYOffset = _loc3_.minMag + _loc4_ - this.plotMC._yAxisMax;
         this.draggableAreaMC.maxYOffset = _loc3_.maxMag - _loc4_ - this.plotMC._yAxisMin;
         if(this.draggableAreaMC.yOffset < this.draggableAreaMC.minYOffset)
         {
            this.draggableAreaMC.yOffset = this.draggableAreaMC.minYOffset;
         }
         if(this.draggableAreaMC.yOffset > this.draggableAreaMC.maxYOffset)
         {
            this.draggableAreaMC.yOffset = this.draggableAreaMC.maxYOffset;
         }
         this.plotMC.distanceModulus = this.draggableAreaMC.yOffset;
         this.barMC.updateValues();
      }
      else
      {
         this.plotMC["_" + _loc7_ + "Layer"]._visible = false;
      }
   }
};
p.onShowHorizontalBarChanged = function()
{
   this.barMC._visible = this.showHorizontalBarCheckBox.getValue();
};
p.onDrag = function(xOffset, yOffset)
{
   this.plotMC.plotAreaMC.objectLayersMC._x = xOffset;
   this.plotMC.distanceModulus = yOffset;
   this.barMC.updateValues();
};
