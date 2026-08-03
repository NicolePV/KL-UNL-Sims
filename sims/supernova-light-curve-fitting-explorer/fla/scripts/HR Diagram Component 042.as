function HRDiagramComponentClass042()
{
   this.createEmptyMovieClip("backgroundMC",0);
   this.createEmptyMovieClip("plotAreaMC",10);
   this.createEmptyMovieClip("plotAreaMaskMC",11);
   this.createEmptyMovieClip("scalesMC",15);
   this.createEmptyMovieClip("borderMC",20);
   this.plotAreaMC.setMask(this.plotAreaMaskMC);
   this.removeAllObjects();
   this.setDimensions(this._width,this._height);
   this._xscale = this._yscale = 100;
   this.placeholderMC._visible = false;
   this.placeholderMC.swapDepths(987654);
   this.placeholderMC.removeMovieClip();
   this.scalesList = {top:{},bottom:{},left:{},right:{}};
   if(this.initXAxisType == "spectral type")
   {
      this.setXAxisType("type");
      this.showScale("type","bottom");
   }
   else if(this.initXAxisType == "B-V color index")
   {
      this.setXAxisType("BV");
      this.showScale("BV","bottom");
   }
   else
   {
      this.setXAxisType("logTemp");
      this.showScale("logTemp","bottom");
   }
   if(this.initYAxisType == "bolometric magnitude")
   {
      this.setYAxisType("absBolMag");
      this.showScale("absBolMag","left");
   }
   else if(this.initYAxisType == "visual magnitude")
   {
      this.setYAxisType("absVisMag");
      this.showScale("absVisMag","left");
   }
   else
   {
      this.setYAxisType("logLum");
      this.showScale("logLum","left");
   }
   this._distModulus = 0;
   this._showIsoradiusLines = this.initShowIsoradiusLines;
   if(this.initDisplayedLuminosityClasses == "main sequence (V)")
   {
      this.setShownLuminosityClasses("V");
   }
   else
   {
      this.setShownLuminosityClasses(this.initDisplayedLuminosityClasses);
   }
   var _loc4_ = this.attachMovie(this.fontsMovieClip,"fontsMC",435435,{_visible:false});
   var _loc2_;
   if(this.isoradiusLabelTextFormat == undefined)
   {
      this.isoradiusLabelTextFormat = new TextFormat();
      _loc2_ = _loc4_.isoradiusLabelField.getNewTextFormat();
      for(var _loc3_ in _loc2_)
      {
         this.isoradiusLabelTextFormat[_loc3_] = _loc2_[_loc3_];
      }
   }
   if(this.tickmarkLabelTextFormat == undefined)
   {
      this.tickmarkLabelTextFormat = new TextFormat();
      _loc2_ = _loc4_.tickmarkLabelField.getNewTextFormat();
      for(_loc3_ in _loc2_)
      {
         this.tickmarkLabelTextFormat[_loc3_] = _loc2_[_loc3_];
      }
   }
   if(this.axisLabelTextFormat == undefined)
   {
      this.axisLabelTextFormat = new TextFormat();
      _loc2_ = _loc4_.axisLabelField.getNewTextFormat();
      for(_loc3_ in _loc2_)
      {
         this.axisLabelTextFormat[_loc3_] = _loc2_[_loc3_];
      }
   }
   this.backgroundColor = this.initBackgroundColor;
   this.borderAndScalesColor = this.initBorderAndScalesColor;
   this.luminosityClassCurvesColor = this.initLuminosityClassCurvesColor;
   this.isoradiusCurvesColor = this.initIsoradiusCurvesColor;
   if(!this.skipInitUpdate)
   {
      this.update();
   }
}
var p = HRDiagramComponentClass042.prototype = new MovieClip();
Object.registerClass("HR Diagram Component 042",HRDiagramComponentClass042);
p.fontsMovieClip = "HR Diagram Fonts";
p.backgroundAlpha = 100;
p.borderAndScalesLineThickness = 1;
p.borderAndScalesAlpha = 100;
p.luminosityClassCurvesLineThickness = 1;
p.luminosityClassCurvesAlpha = 100;
p.isoradiusCurvesLineThickness = 1;
p.isoradiusCurvesAlpha = 100;
p.isoradiusLabelMargin = 5;
p.isoradiusLabelBackgroundAlpha = 80;
p.isoradiusMax = 1000;
p.isoradiusMin = 0.0001;
p.logTempAxisLabel = "Temperature (K)";
p.logTempAxisLabelSpacing = 25;
p.BVAxisLabel = "B-V Color Index";
p.BVAxisLabelSpacing = 25;
p.BVMajorMultiple = 5;
p.BVMinorStep = 0.1;
p.typeAxisLabel = "Spectral Type";
p.typeAxisLabelSpacing = 22;
p.typeShowLabels = true;
p.typeNumTickmarks = 1;
p.typeLabelSpacing = 4;
p.typeTickmarkLengths = [5,3,4];
p.logLumAxisLabel = "Luminosity (L<sol>)";
p.logLumAxisLabelSpacing = 47;
p.logLumLabelSpacing = 10;
p.logLumLabelMultiple = 1;
p.absBolMagAxisLabel = "Absolute Magnitude (M<sub>bol</sub>)";
p.absBolMagAxisLabelSpacing = 40;
p.absBolMagLabelSpacing = 10;
p.absBolMagLabelMultiple = 2;
p.absVisMagAxisLabel = "Absolute Magnitude (M<sub>vis</sub>)";
p.absVisMagAxisLabelSpacing = 40;
p.absVisMagLabelSpacing = 10;
p.absVisMagLabelMultiple = 2;
p.appBolMagAxisLabel = "Apparent Magnitude (m<sub>bol</sub>)";
p.appBolMagAxisLabelSpacing = 40;
p.appBolMagLabelSpacing = 10;
p.appBolMagLabelMultiple = 2;
p.appVisMagAxisLabel = "Apparent Magnitude (m<sub>vis</sub>)";
p.appVisMagAxisLabelSpacing = 40;
p.appVisMagLabelSpacing = 10;
p.appVisMagLabelMultiple = 2;
p.initXAxisType = "log of temperature";
p.initYAxisType = "log of luminosity";
p.initShowIsoradiusLines = true;
p.initDisplayedLuminosityClasses = "main sequence (V)";
p.initBorderAndScalesColor = 0;
p.initBackgroundColor = 16777215;
p.initIsoradiusCurvesColor = 6723891;
p.initLuminosityClassCurvesColor = 16737894;
p.getPlotCoordinates = function(screenPt)
{
   var _loc15_ = this._xAxisMin;
   var _loc14_ = this.plotWidth / (this._xAxisMax - this._xAxisMin);
   var _loc16_ = this._yAxisMin;
   var _loc13_ = (- this.plotHeight) / (this._yAxisMax - this._yAxisMin);
   var _loc19_ = this.plotHeight;
   var _loc18_ = this.plotWidth;
   var _loc5_ = this.xPropertyNamesList;
   var _loc4_ = this.yPropertyNamesList;
   var _loc6_ = this.xPropertyCapNamesList;
   var _loc7_ = this.yPropertyCapNamesList;
   var _loc20_ = _loc5_[this._xAxisType];
   var _loc21_ = _loc4_[this._yAxisType];
   var _loc11_ = _loc6_[this._xAxisType];
   var _loc12_ = _loc7_[this._yAxisType];
   var _loc10_;
   if(this._xAxisType == 0)
   {
      _loc10_ = _loc15_ + (_loc18_ - screenPt.x) / _loc14_;
   }
   else
   {
      _loc10_ = _loc15_ + screenPt.x / _loc14_;
   }
   var _loc9_;
   if(this._yAxisType == 0)
   {
      _loc9_ = _loc16_ + screenPt.y / _loc13_;
   }
   else
   {
      _loc9_ = _loc16_ + (- _loc19_ - screenPt.y) / _loc13_;
   }
   var _loc3_ = {};
   var _loc2_ = 0;
   while(_loc2_ < _loc5_.length)
   {
      _loc3_[_loc5_[_loc2_]] = this["get" + _loc6_[_loc2_] + "From" + _loc11_](_loc10_);
      _loc2_ = _loc2_ + 1;
   }
   var _loc8_ = this.getBCFromLogTemp(_loc3_.logTemp);
   _loc2_ = 0;
   while(_loc2_ < _loc4_.length)
   {
      _loc3_[_loc4_[_loc2_]] = this["get" + _loc7_[_loc2_] + "From" + _loc12_](_loc9_,_loc8_);
      _loc2_ = _loc2_ + 1;
   }
   _loc3_.BC = _loc8_;
   _loc3_.temp = Math.pow(10,_loc3_.logTemp);
   _loc3_.lum = Math.pow(10,_loc3_.logLum);
   return _loc3_;
};
p.update = function()
{
   this.updateBackgroundAndBorder();
   this.updateObjects();
   this.updateScales();
   this.updateIsoradiusLines();
   this.updateLuminosityClassLines();
};
p.setDimensions = function(width, height)
{
   this.plotWidth = width;
   this.plotHeight = height;
   var _loc2_ = this.plotAreaMaskMC;
   _loc2_.clear();
   _loc2_.moveTo(0,0);
   _loc2_.lineStyle(undefined);
   _loc2_.beginFill(16711680,100);
   _loc2_.lineTo(width,0);
   _loc2_.lineTo(width,- height);
   _loc2_.lineTo(0,- height);
   _loc2_.lineTo(0,0);
   _loc2_.endFill();
};
p.updateBackgroundAndBorder = function()
{
   var _loc3_ = this.plotWidth;
   var _loc4_ = this.plotHeight;
   var _loc2_ = this.backgroundMC;
   _loc2_.clear();
   _loc2_.moveTo(0,0);
   _loc2_.lineStyle(undefined);
   _loc2_.beginFill(this.backgroundColor,this.backgroundAlpha);
   _loc2_.lineTo(_loc3_,0);
   _loc2_.lineTo(_loc3_,- _loc4_);
   _loc2_.lineTo(0,- _loc4_);
   _loc2_.lineTo(0,0);
   _loc2_.endFill();
   _loc2_ = this.borderMC;
   _loc2_.clear();
   _loc2_.moveTo(0,0);
   _loc2_.lineStyle(this.borderAndScalesLineThickness,this.borderAndScalesColor,this.borderAndScalesAlpha);
   _loc2_.lineTo(_loc3_,0);
   _loc2_.lineTo(_loc3_,- _loc4_);
   _loc2_.lineTo(0,- _loc4_);
   _loc2_.lineTo(0,0);
};
p.getShowLuminosityClassLines = function()
{
   return this._showLuminosityClassLines;
};
p.setShowLuminosityClassLines = function(arg)
{
   this._showLuminosityClassLines = arg;
   this.updateLuminosityClassLines();
};
p.addProperty("showLuminosityClassLines",p.getShowLuminosityClassLines,p.setShowLuminosityClassLines);
p.setShownLuminosityClasses = function(arg)
{
   if(typeof arg == "string")
   {
      if(arg == "all")
      {
         this._showLuminosityClassLines = true;
         delete this.luminosityClassesList;
      }
      else if(arg == "none")
      {
         this._showLuminosityClassLines = false;
      }
      else
      {
         this._showLuminosityClassLines = true;
         if(this.luminosityClassesList == undefined)
         {
            this.luminosityClassesList = ["V"];
         }
         else
         {
            this.luminosityClassesList.push(arg);
         }
      }
   }
   else if(arg != undefined && arg != null)
   {
      this._showLuminosityClassLines = true;
      this.luminosityClassesList = arg;
   }
};
p.getShowIsoradiusLines = function()
{
   return this._showIsoradiusLines;
};
p.setShowIsoradiusLines = function(arg)
{
   this._showIsoradiusLines = arg;
   this.updateIsoradiusLines();
};
p.addProperty("showIsoradiusLines",p.getShowIsoradiusLines,p.setShowIsoradiusLines);
p.updateScales = function(appMagOnly)
{
   this.tickmarkLabelTextFormat.color = this.borderAndScalesColor;
   this.axisLabelTextFormat.color = this.borderAndScalesColor;
   if(appMagOnly)
   {
      if(this.scalesList.left.scaleType == "AppBolMag" || this.scalesList.left.scaleType == "AppVisMag")
      {
         this.scalesMC.createEmptyMovieClip("leftMC",2);
         this[this.scalesList.left.updateFunction]("left",this.scalesList.left.scaleType);
      }
      if(this.scalesList.right.scaleType == "AppBolMag" || this.scalesList.right.scaleType == "AppVisMag")
      {
         this.scalesMC.createEmptyMovieClip("rightMC",3);
         this[this.scalesList.right.updateFunction]("right",this.scalesList.right.scaleType);
      }
   }
   else
   {
      this.scalesMC.createEmptyMovieClip("bottomMC",1);
      this.scalesMC.createEmptyMovieClip("leftMC",2);
      this.scalesMC.createEmptyMovieClip("rightMC",3);
      this.scalesMC.createEmptyMovieClip("topMC",4);
      for(var _loc2_ in this.scalesList)
      {
         this[this.scalesList[_loc2_].updateFunction](_loc2_,this.scalesList[_loc2_].scaleType);
      }
   }
};
p.addObjectLayer = function(layerName, keepFixed, depth, objectsList, linkageName)
{
   if(typeof depth != "number")
   {
      depth = this.objectLayerFreeDepth++;
   }
   var _loc5_ = this.plotAreaMC.objectLayersMC.createEmptyMovieClip(layerName,depth);
   this[layerName] = _loc5_;
   _loc5_.keepFixed = keepFixed;
   _loc5_.__objectEntriesList = [];
   _loc5_.__incDistModulus = 0;
   this.objectLayersList.push(_loc5_);
   var _loc3_;
   var _loc2_;
   var _loc4_;
   if(objectsList != undefined)
   {
      if(typeof linkageName != "string")
      {
         linkageName = "HR Diagram Dot";
      }
      _loc3_ = 0;
      while(_loc3_ < objectsList.length)
      {
         _loc2_ = _loc5_.attachMovie(linkageName,"__batch" + _loc3_,_loc3_,objectsList[_loc3_]);
         _loc4_ = {refExists:false,name:name,mc:_loc2_,lmc:_loc5_};
         this.objectsList.push(_loc4_);
         _loc2_.__objectEntry = _loc4_;
         _loc5_.__objectEntriesList.push(_loc4_);
         if(_loc2_.temp != undefined)
         {
            _loc2_.logTemp = Math.log(_loc2_.temp) / 2.302585092994046;
         }
         if(_loc2_.lum != undefined)
         {
            _loc2_.logLum = Math.log(_loc2_.lum) / 2.302585092994046;
         }
         _loc3_ = _loc3_ + 1;
      }
   }
};
p.removeObjectLayer = function(layerName)
{
   var _loc4_ = this.plotAreaMC.objectLayersMC[layerName];
   if(_loc4_ == undefined)
   {
      return undefined;
   }
   var _loc7_ = [];
   var _loc6_ = this.objectsList;
   var _loc3_ = 0;
   var _loc2_;
   while(_loc3_ < _loc6_.length)
   {
      _loc2_ = _loc6_[_loc3_];
      if(_loc2_.lmc != _loc4_)
      {
         _loc7_.push(_loc2_);
      }
      else if(_loc2_.refExists)
      {
         delete this[_loc2_.name];
      }
      _loc3_ = _loc3_ + 1;
   }
   this.objectsList = _loc7_;
   var _loc5_ = this.objectLayersList;
   _loc3_ = 0;
   while(_loc3_ < _loc5_.length)
   {
      if(_loc5_[_loc3_] == _loc4_)
      {
         _loc5_.splice(_loc3_,1);
         delete this[_loc4_._name];
         _loc4_.removeMovieClip();
         break;
      }
      _loc3_ = _loc3_ + 1;
   }
};
p.addObject = function(linkageName, name, depth, layerName, initObj)
{
   if(typeof linkageName != "string")
   {
      linkageName = "HR Diagram Dot";
   }
   if(typeof depth != "number")
   {
      depth = this.objectFreeDepth;
   }
   var _loc4_ = typeof name == "string";
   if(!_loc4_)
   {
      name = "__object" + this.objectFreeDepth;
   }
   this.objectFreeDepth = this.objectFreeDepth + 1;
   var _loc6_ = this.plotAreaMC.objectLayersMC[layerName];
   if(_loc6_ == undefined)
   {
      _loc6_ = this.plotAreaMC.objectsMC;
   }
   var _loc2_ = _loc6_.attachMovie(linkageName,name,depth,initObj);
   var _loc3_ = {refExists:_loc4_,name:name,mc:_loc2_,lmc:_loc6_};
   this.objectsList.push(_loc3_);
   _loc2_.__objectEntry = _loc3_;
   _loc6_.__objectEntriesList.push(_loc3_);
   if(_loc2_.temp != undefined)
   {
      _loc2_.logTemp = Math.log(_loc2_.temp) / 2.302585092994046;
   }
   if(_loc2_.lum != undefined)
   {
      _loc2_.logLum = Math.log(_loc2_.lum) / 2.302585092994046;
   }
   if(_loc4_)
   {
      this[name] = _loc2_;
      _loc2_.watch("temp",function(prop, oldVal, newVal)
      {
         this.logTemp = Math.log(newVal) / 2.302585092994046;
         return newVal;
      }
      );
      _loc2_.watch("lum",function(prop, oldVal, newVal)
      {
         this.logLum = Math.log(newVal) / 2.302585092994046;
         return newVal;
      }
      );
   }
   return _loc2_;
};
p.removeObject = function(name)
{
   var _loc6_ = this.objectsList;
   var _loc5_ = 0;
   var _loc3_;
   var _loc4_;
   var _loc2_;
   while(_loc5_ < _loc6_.length)
   {
      _loc3_ = _loc6_[_loc5_];
      if(_loc3_.name == name)
      {
         if(_loc3_.refExists)
         {
            delete this[_loc3_.name];
         }
         if(_loc3_.lmc != this.plotAreaMC.objectsMC)
         {
            _loc4_ = _loc3_.lmc.__objectEntriesList;
            _loc2_ = 0;
            while(_loc2_ < _loc4_.length)
            {
               if(_loc3_ == _loc4_[_loc2_])
               {
                  _loc4_.splice(_loc2_,1);
                  break;
               }
               _loc2_ = _loc2_ + 1;
            }
         }
         _loc3_.mc.removeMovieClip();
         _loc6_.splice(_loc5_,1);
         return undefined;
      }
      _loc5_ = _loc5_ + 1;
   }
};
p.removeAllObjects = function()
{
   var _loc3_ = this.objectsList;
   var _loc2_ = 0;
   while(_loc2_ < _loc3_.length)
   {
      if(_loc3_[_loc2_].refExists)
      {
         delete this[_loc3_[_loc2_].name];
      }
      _loc2_ = _loc2_ + 1;
   }
   var _loc4_ = this.objectLayersList;
   _loc2_ = 0;
   while(_loc2_ < _loc4_.length)
   {
      delete this[_loc4_[_loc2_]._name];
      _loc2_ = _loc2_ + 1;
   }
   this.plotAreaMC.createEmptyMovieClip("objectLayersMC",14);
   this.plotAreaMC.createEmptyMovieClip("objectsMC",15);
   this.objectLayersList = [];
   this.objectsList = [];
   this.objectFreeDepth = 0;
   this.objectLayerFreeDepth = 0;
};
p.updateIsoradiusLines = function()
{
   var imc = this.plotAreaMC.createEmptyMovieClip("isoradiusLinesMC",5);
   if(!this._showIsoradiusLines)
   {
      return undefined;
   }
   imc._alpha = this.isoradiusCurvesAlpha;
   this.isoradiusLabelTextFormat.color = this.isoradiusCurvesColor;
   var _loc20_ = 100;
   var pL = [];
   this.getTemp = this["getLogTempFrom" + this.xPropertyCapNamesList[this._xAxisType]];
   this.getYProp = this["get" + this.yPropertyCapNamesList[this._yAxisType] + "FromLogLum"];
   var xAxisMin = this._xAxisMin;
   var xAxisScale = this.plotWidth / (this._xAxisMax - this._xAxisMin);
   var yAxisMin = this._yAxisMin;
   var yAxisScale = (- this.plotHeight) / (this._yAxisMax - this._yAxisMin);
   var height = this.plotHeight;
   var width = this.plotWidth;
   var _loc27_;
   var _loc23_;
   var _loc29_;
   if(this._xAxisType == 0)
   {
      _loc27_ = -1;
      _loc23_ = _loc20_;
      this.getX = function(xP)
      {
         return width - (xP - xAxisMin) * xAxisScale;
      };
      _loc29_ = this._xAxisMax;
   }
   else
   {
      _loc27_ = 1;
      _loc23_ = 0;
      this.getX = function(xP)
      {
         return (xP - xAxisMin) * xAxisScale;
      };
      _loc29_ = this.getTemp(this._xAxisMin);
   }
   var _loc31_;
   if(this._yAxisType == 0)
   {
      this.getY = function(yP)
      {
         return (yP - yAxisMin) * yAxisScale;
      };
      _loc31_ = yAxisMin;
   }
   else
   {
      this.getY = function(yP)
      {
         return - height - (yP - yAxisMin) * yAxisScale;
      };
      _loc31_ = this["getLogLumFrom" + this.yPropertyCapNamesList[this._yAxisType]](this._yAxisMax,this.getBCFromLogTemp(_loc29_));
   }
   var _loc25_ = (this._xAxisMax - this._xAxisMin) / _loc20_;
   var sxStep = this.plotWidth / _loc20_;
   var _loc21_ = 3.7634279935629364;
   var _loc15_ = imc.createEmptyMovieClip("_0",0);
   _loc15_.lineStyle(this.isoradiusCurvesLineThickness,this.isoradiusCurvesColor);
   var _loc13_ = this._xAxisMin;
   var _loc9_ = this.getTemp(_loc13_);
   var _loc11_ = this.getX(_loc13_);
   var _loc10_ = this.getY(this.getYProp(4 * (_loc9_ - _loc21_),this.getBCFromLogTemp(_loc9_)));
   pL[_loc23_] = {x:_loc11_,y:_loc10_};
   _loc15_.moveTo(_loc11_,_loc10_);
   var _loc4_ = 0;
   while(_loc4_ < _loc20_)
   {
      _loc13_ += _loc25_;
      _loc9_ = this.getTemp(_loc13_);
      _loc11_ = this.getX(_loc13_);
      _loc10_ = this.getY(this.getYProp(4 * (_loc9_ - _loc21_),this.getBCFromLogTemp(_loc9_)));
      pL[_loc23_ + _loc27_ * (_loc4_ + 1)] = {x:_loc11_,y:_loc10_};
      _loc15_.lineTo(_loc11_,_loc10_);
      _loc4_ = _loc4_ + 1;
   }
   var yZero = pL[0].y;
   var yExtent = pL[pL.length - 1].y - yZero;
   var yOffset = this.getY(this.getYProp(0,0)) - this.getY(this.getYProp(2,0));
   var labelMargin = this.isoradiusLabelMargin;
   var tf = this.isoradiusLabelTextFormat;
   var _loc14_ = this.isoradiusLinesList;
   var _loc22_;
   var _loc26_;
   var _loc6_;
   if(_loc14_ == undefined)
   {
      _loc22_ = Math.ceil((_loc31_ - 4 * (_loc29_ - _loc21_)) / 2);
      _loc26_ = 1 + Math.floor((yExtent + height + yZero) / yOffset - _loc22_);
      _loc14_ = [];
      _loc4_ = 0;
      while(_loc4_ < _loc26_)
      {
         _loc6_ = Math.pow(10,_loc4_ + _loc22_);
         if(!(_loc6_ < this.isoradiusMin || _loc6_ > this.isoradiusMax))
         {
            _loc14_.push({radius:_loc6_});
         }
         _loc4_ = _loc4_ + 1;
      }
   }
   var dispText = this.displayText;
   var addText = this.addTextToWrapperMC;
   var drawCircle = this.drawCircle;
   var labelBackgroundColor = this.backgroundColor;
   var labelBackgroundAlpha = this.isoradiusLabelBackgroundAlpha;
   var labelDepth = 10000;
   var _loc24_ = function(lineMC, isoLine)
   {
      var _loc7_ = (- yOffset) * Math.log(isoLine.radius) / 2.302585092994046;
      lineMC._y = _loc7_;
      var _loc11_;
      var _loc12_;
      var _loc1_;
      var _loc10_;
      var _loc13_;
      var _loc6_;
      var _loc9_;
      var _loc3_;
      var _loc5_;
      var _loc4_;
      var _loc2_;
      if(isoLine.hideLabel != true)
      {
         if(isoLine.labelText == undefined)
         {
            _loc11_ = isoLine.radius + " R<sol>";
         }
         else
         {
            _loc11_ = isoLine.labelText;
         }
         _loc12_ = imc.createEmptyMovieClip("_" + labelDepth,labelDepth);
         labelDepth++;
         _loc1_ = addText(_loc12_,_loc11_,tf,dispText,drawCircle,true,true,labelBackgroundColor,labelBackgroundAlpha);
         _loc10_ = _loc7_ + yZero;
         _loc13_ = _loc10_ + yExtent;
         if(_loc10_ < 0)
         {
            _loc6_ = labelMargin + _loc1_._width / 2;
            _loc9_ = _loc6_ / sxStep;
            _loc3_ = pL[Math.floor(_loc9_)];
            _loc5_ = pL[Math.ceil(_loc9_)];
            _loc4_ = _loc7_ + _loc3_.y + (_loc9_ * sxStep - _loc3_.x) * (_loc5_.y - _loc3_.y) / sxStep;
            if(_loc4_ > - labelMargin - _loc1_._height / 2)
            {
               _loc1_._x = 2 + labelMargin;
               _loc1_._y = 4 - _loc1_._height - labelMargin;
            }
            else if(_loc4_ < - height + labelMargin + _loc1_._height / 2)
            {
               _loc4_ = - height + labelMargin + _loc1_._height / 2;
               _loc2_ = 0;
               while(_loc2_ < pL.length)
               {
                  if(_loc7_ + pL[_loc2_].y > _loc4_)
                  {
                     _loc3_ = pL[_loc2_ - 1];
                     _loc5_ = pL[_loc2_];
                     _loc6_ = _loc3_.x + (_loc4_ - _loc7_ - _loc3_.y) * (_loc5_.x - _loc3_.x) / (_loc5_.y - _loc3_.y);
                     if(_loc6_ > width - labelMargin - _loc1_._width / 2)
                     {
                        _loc1_._x = 2 + width - labelMargin - _loc1_._width;
                        _loc1_._y = 2 + _loc4_ - _loc1_._height / 2;
                     }
                     else
                     {
                        _loc1_._x = 2 + _loc6_ - _loc1_._width / 2;
                        _loc1_._y = 2 + _loc4_ - _loc1_._height / 2;
                     }
                     break;
                  }
                  _loc2_ = _loc2_ + 1;
               }
               if(_loc2_ >= pL.length)
               {
                  _loc1_._visible = false;
               }
            }
            else
            {
               _loc1_._x = 2 + labelMargin;
               _loc1_._y = 2 + _loc4_ - _loc1_._height / 2;
            }
         }
         else
         {
            _loc1_._visible = false;
         }
      }
   };
   _loc24_(_loc15_,_loc14_[0]);
   _loc4_ = 1;
   while(_loc4_ < _loc14_.length)
   {
      _loc24_(_loc15_.duplicateMovieClip("_" + _loc4_,_loc4_),_loc14_[_loc4_]);
      _loc4_ = _loc4_ + 1;
   }
   delete this.getTemp;
   delete this.getYProp;
   delete this.getX;
   delete this.getY;
};
p.updateLuminosityClassLines = function()
{
   var _loc20_ = this.plotAreaMC.createEmptyMovieClip("luminosityClassesMC",10);
   if(!this._showLuminosityClassLines)
   {
      return undefined;
   }
   _loc20_._alpha = this.luminosityClassCurvesAlpha;
   var _loc13_ = this.getLogLumFromLogTempAndClass;
   var _loc21_ = 100;
   var _loc22_ = (this._xAxisMax - this._xAxisMin) / _loc21_;
   var _loc5_ = this._xAxisMin;
   this.getTemp = this["getLogTempFrom" + this.xPropertyCapNamesList[this._xAxisType]];
   this.getXProp = this["get" + this.xPropertyCapNamesList[this._xAxisType] + "FromLogTemp"];
   this.getYProp = this["get" + this.yPropertyCapNamesList[this._yAxisType] + "FromLogLum"];
   var xAxisMin = this._xAxisMin;
   var xAxisScale = this.plotWidth / (this._xAxisMax - this._xAxisMin);
   var yAxisMin = this._yAxisMin;
   var yAxisScale = (- this.plotHeight) / (this._yAxisMax - this._yAxisMin);
   var height = this.plotHeight;
   var width = this.plotWidth;
   if(this._xAxisType == 0)
   {
      this.getX = function(xP)
      {
         return width - (xP - xAxisMin) * xAxisScale;
      };
   }
   else
   {
      this.getX = function(xP)
      {
         return (xP - xAxisMin) * xAxisScale;
      };
   }
   if(this._yAxisType == 0)
   {
      this.getY = function(yP)
      {
         return (yP - yAxisMin) * yAxisScale;
      };
   }
   else
   {
      this.getY = function(yP)
      {
         return - height - (yP - yAxisMin) * yAxisScale;
      };
   }
   var _loc7_ = this.getX(_loc5_);
   var _loc9_ = this.getTemp(_loc5_);
   var _loc11_ = this.getBCFromLogTemp(_loc9_);
   var _loc14_ = this.luminosityClassesList;
   if(_loc14_ == undefined)
   {
      _loc14_ = ["I","II","III","IV","V"];
   }
   var _loc3_ = [];
   var _loc12_ = 0;
   var _loc19_;
   while(_loc12_ < _loc14_.length)
   {
      _loc19_ = _loc14_[_loc12_];
      if(_loc19_ == "I" || _loc19_ == "i")
      {
         _loc3_.push({lumClass:1,minLogT:3.39,maxLogT:4.65});
      }
      else if(_loc19_ == "II" || _loc19_ == "ii")
      {
         _loc3_.push({lumClass:2,minLogT:3.39,maxLogT:4.45});
      }
      else if(_loc19_ == "III" || _loc19_ == "iii")
      {
         _loc3_.push({lumClass:3,minLogT:3.38,maxLogT:4.3});
      }
      else if(_loc19_ == "IV" || _loc19_ == "iv")
      {
         _loc3_.push({lumClass:4,minLogT:3.38,maxLogT:4});
      }
      else if(_loc19_ == "V" || _loc19_ == "v")
      {
         _loc3_.push({lumClass:5,minLogT:3.359,maxLogT:4.701});
      }
      _loc12_ = _loc12_ + 1;
   }
   var _loc8_ = [];
   var _loc6_ = [];
   var _loc2_ = 0;
   var _loc10_;
   while(_loc2_ < _loc3_.length)
   {
      if(this._xAxisType == 0)
      {
         _loc6_[_loc2_] = {maxXP:this.getXProp(_loc3_[_loc2_].maxLogT),minXP:this.getXProp(_loc3_[_loc2_].minLogT)};
      }
      else
      {
         _loc6_[_loc2_] = {maxXP:this.getXProp(_loc3_[_loc2_].minLogT),minXP:this.getXProp(_loc3_[_loc2_].maxLogT)};
      }
      _loc10_ = _loc20_.createEmptyMovieClip("_" + _loc2_,_loc2_);
      _loc8_[_loc2_] = _loc10_;
      _loc10_.lineStyle(this.luminosityClassCurvesLineThickness,this.luminosityClassCurvesColor);
      _loc10_.moveTo(_loc7_,this.getY(this.getYProp(_loc13_(_loc9_,_loc3_[_loc2_].lumClass),_loc11_)));
      _loc2_ = _loc2_ + 1;
   }
   _loc12_ = 0;
   var _loc4_;
   while(_loc12_ < _loc21_)
   {
      _loc5_ += _loc22_;
      _loc7_ = this.getX(_loc5_);
      _loc9_ = this.getTemp(_loc5_);
      _loc11_ = this.getBCFromLogTemp(_loc9_);
      _loc2_ = 0;
      while(_loc2_ < _loc3_.length)
      {
         _loc4_ = this.getY(this.getYProp(_loc13_(_loc9_,_loc3_[_loc2_].lumClass),_loc11_));
         if(_loc5_ < _loc6_[_loc2_].minXP)
         {
            _loc8_[_loc2_].moveTo(_loc7_,_loc4_);
         }
         else if(_loc5_ < _loc6_[_loc2_].maxXP)
         {
            _loc8_[_loc2_].lineTo(_loc7_,_loc4_);
         }
         _loc2_ = _loc2_ + 1;
      }
      _loc12_ = _loc12_ + 1;
   }
   delete this.getTemp;
   delete this.getXProp;
   delete this.getYProp;
};
p.getDistanceModulus = function()
{
   return this._distModulus;
};
p.setDistanceModulus = function(arg)
{
   this._distModulus = arg;
   this.updateObjectsOffset();
   this.updateScales(true);
};
p.addProperty("distanceModulus",p.getDistanceModulus,p.setDistanceModulus);
p.updateObjectsOffset = function()
{
   var _loc4_ = (- this.plotHeight) / (this._yAxisMax - this._yAxisMin);
   if(this._yAxisType == 0)
   {
      _loc4_ = 0.4 * _loc4_;
   }
   var _loc3_ = this.objectLayersList;
   var _loc2_ = 0;
   while(_loc2_ < _loc3_.length)
   {
      if(!_loc3_[_loc2_].keepFixed)
      {
         _loc3_[_loc2_]._y = _loc4_ * (this._distModulus - _loc3_[_loc2_].__incDistModulus);
      }
      _loc2_ = _loc2_ + 1;
   }
};
p.updateObjects = function(subset)
{
   var _loc6_ = [];
   var _loc7_;
   var _loc3_;
   var _loc2_;
   var _loc5_;
   if(subset != undefined)
   {
      if(typeof subset == "string")
      {
         _loc7_ = this.plotAreaMC.objectLayersMC[subset];
         if(_loc7_ != undefined)
         {
            _loc6_ = _loc7_.__objectEntriesList;
            _loc7_.__incDistModulus = this._distModulus;
            this.updateObjectsOffset();
         }
         else
         {
            _loc3_ = this[subset].__objectEntry;
            if(_loc3_ != undefined)
            {
               _loc6_.push(_loc3_);
            }
         }
      }
      else if(typeof subset == "object" && subset.length > 0)
      {
         _loc2_ = 0;
         while(_loc2_ < subset.length)
         {
            _loc3_ = this[subset[_loc2_]].__objectEntry;
            if(_loc3_ != undefined)
            {
               _loc6_.push(_loc3_);
            }
            _loc2_ = _loc2_ + 1;
         }
      }
   }
   else
   {
      _loc6_ = this.objectsList;
      _loc5_ = this.objectLayersList;
      _loc2_ = 0;
      while(_loc2_ < _loc5_.length)
      {
         _loc5_[_loc2_].__incDistModulus = this._distModulus;
         _loc2_ = _loc2_ + 1;
      }
      this.updateObjectsOffset();
   }
   if(_loc6_.length > 0)
   {
      this.updateObjectsByList(_loc6_);
   }
};
p.updateObjectsByList = function(oL)
{
   var _loc14_ = this.xPropertyNamesList;
   var _loc13_ = this.yPropertyNamesList;
   var _loc19_ = this.xPropertyCapNamesList;
   var _loc20_ = this.yPropertyCapNamesList;
   var _loc24_ = _loc14_[this._xAxisType];
   var _loc23_ = _loc13_[this._yAxisType];
   var _loc15_ = _loc19_[this._xAxisType];
   var _loc21_ = _loc20_[this._yAxisType];
   var xAxisMin = this._xAxisMin;
   var xAxisScale = this.plotWidth / (this._xAxisMax - this._xAxisMin);
   var yAxisMin = this._yAxisMin;
   var yAxisScale = (- this.plotHeight) / (this._yAxisMax - this._yAxisMin);
   var height = this.plotHeight;
   var width = this.plotWidth;
   var _loc22_ = _loc23_ == "absVisMag" || _loc23_ == "appVisMag";
   if(this._xAxisType == 0)
   {
      this.getX = function(xP)
      {
         return width - (xP - xAxisMin) * xAxisScale;
      };
   }
   else
   {
      this.getX = function(xP)
      {
         return (xP - xAxisMin) * xAxisScale;
      };
   }
   if(this._yAxisType == 0)
   {
      this.getY = function(yP)
      {
         return (yP - yAxisMin) * yAxisScale;
      };
   }
   else
   {
      this.getY = function(yP)
      {
         return - height - (yP - yAxisMin) * yAxisScale;
      };
   }
   var _loc11_ = 0;
   var _loc2_;
   var _loc5_;
   var _loc3_;
   var _loc6_;
   var _loc8_;
   var _loc4_;
   var _loc7_;
   var _loc9_;
   var _loc12_;
   var _loc10_;
   var _loc17_;
   var _loc16_;
   while(_loc11_ < oL.length)
   {
      if(oL[_loc11_].lmc._visible)
      {
         _loc2_ = oL[_loc11_].mc;
         _loc5_ = _loc2_[_loc24_];
         if(_loc5_ == undefined)
         {
            _loc3_ = 0;
            while(_loc3_ < _loc14_.length)
            {
               _loc6_ = _loc2_[_loc14_[_loc3_]];
               if(_loc6_ != undefined)
               {
                  _loc5_ = this["get" + _loc15_ + "From" + _loc19_[_loc3_]](_loc6_);
                  break;
               }
               _loc3_ = _loc3_ + 1;
            }
         }
         _loc8_ = _loc2_[_loc23_];
         if(_loc8_ == undefined)
         {
            _loc3_ = 0;
            while(_loc3_ < _loc13_.length)
            {
               _loc4_ = _loc13_[_loc3_];
               _loc7_ = _loc2_[_loc4_];
               if(_loc7_ != undefined)
               {
                  _loc9_ = _loc4_ == "absVisMag" || _loc4_ == "appVisMag";
                  if(_loc22_ || _loc9_)
                  {
                     if(_loc2_.logTemp == undefined)
                     {
                        _loc12_ = this["getLogTempFrom" + _loc15_](_loc5_);
                     }
                     else
                     {
                        _loc12_ = _loc2_.logTemp;
                     }
                     _loc10_ = this.getBCFromLogTemp(_loc12_);
                  }
                  else
                  {
                     _loc10_ = 0;
                  }
                  _loc8_ = this["get" + _loc21_ + "From" + _loc20_[_loc3_]](_loc7_,_loc10_);
                  break;
               }
               _loc3_ = _loc3_ + 1;
            }
         }
         if(_loc5_ == undefined || _loc8_ == undefined)
         {
            _loc2_._visible = false;
         }
         else
         {
            _loc2_._visible = true;
            _loc17_ = this.getX(_loc5_);
            _loc16_ = this.getY(_loc8_);
            _loc2_._x = _loc17_;
            _loc2_._y = _loc16_;
         }
      }
      _loc11_ = _loc11_ + 1;
   }
   delete this.getX;
   delete this.getY;
};
p.getXAxisTypeNumber = function(type)
{
   var _loc3_ = this.xPropertyNamesList;
   var _loc2_ = 0;
   while(_loc2_ < _loc3_.length)
   {
      if(_loc3_[_loc2_] == type)
      {
         return _loc2_;
      }
      _loc2_ = _loc2_ + 1;
   }
   return null;
};
p.getYAxisTypeNumber = function(type)
{
   var _loc3_ = this.yPropertyNamesList;
   var _loc2_ = 0;
   while(_loc2_ < _loc3_.length)
   {
      if(_loc3_[_loc2_] == type)
      {
         return _loc2_;
      }
      _loc2_ = _loc2_ + 1;
   }
   return null;
};
p.setYAxisType = function(type, min, max)
{
   var _loc2_ = this.getYAxisTypeNumber(type);
   if(_loc2_ == null || _loc2_ > 2)
   {
      return undefined;
   }
   this._yAxisType = _loc2_;
   var _loc5_ = min == undefined || max == undefined;
   var _loc4_;
   var _loc3_;
   if(_loc5_)
   {
      _loc4_ = -5;
      _loc3_ = 6;
      switch(this._yAxisType)
      {
         case 0:
            this._yAxisMin = _loc4_;
            this._yAxisMax = _loc3_;
            break;
         case 1:
            this._yAxisMin = this.getAbsBolMagFromLogLum(_loc3_);
            this._yAxisMax = this.getAbsBolMagFromLogLum(_loc4_);
            break;
         case 2:
            this._yAxisMin = this.getAbsVisMagFromLogLum(_loc3_);
            this._yAxisMax = this.getAbsVisMagFromLogLum(_loc4_);
      }
   }
   else
   {
      this._yAxisMin = min;
      this._yAxisMax = max;
   }
};
p.setXAxisType = function(type, min, max)
{
   var _loc2_ = this.getXAxisTypeNumber(type);
   if(_loc2_ == null)
   {
      return undefined;
   }
   this._xAxisType = _loc2_;
   var _loc3_ = min == undefined || max == undefined;
   if(_loc3_)
   {
      switch(this._xAxisType)
      {
         case 0:
            this._xAxisMin = this.getLogTempFromType(70);
            this._xAxisMax = this.getLogTempFromType(0);
            break;
         case 1:
            this._xAxisMin = 0;
            this._xAxisMax = 70;
            break;
         case 2:
            this._xAxisMin = this.getBVFromType(0);
            this._xAxisMax = this.getBVFromType(70);
      }
   }
   else
   {
      this._xAxisMin = min;
      this._xAxisMax = max;
   }
};
p.showScale = function(type, side)
{
   var _loc3_;
   if(side == "bottom" || side == "top")
   {
      _loc3_ = this.getXAxisTypeNumber(type);
      switch(_loc3_)
      {
         case 0:
            this.scalesList[side].updateFunction = "drawTemperatureScale";
            break;
         case 1:
            this.scalesList[side].updateFunction = "drawSpectralTypeScale";
            break;
         case 2:
            this.scalesList[side].updateFunction = "drawBVScale";
            break;
         default:
            this.scalesList[side].updateFunction = undefined;
      }
   }
   else if(side == "left" || side == "right")
   {
      _loc3_ = this.getYAxisTypeNumber(type);
      if(_loc3_ != null)
      {
         this.scalesList[side].scaleType = this.yPropertyCapNamesList[_loc3_];
         this.scalesList[side].updateFunction = "drawYScale";
      }
      else
      {
         this.scalesList[side].scaleType = undefined;
         this.scalesList[side].updateFunction = undefined;
      }
   }
};
p.drawYScale = function(side, scaleType)
{
   scaleType;
   var _loc17_ = scaleType.charAt(0).toLowerCase() + scaleType.substr(1);
   var _loc25_ = this[_loc17_ + "AxisLabel"];
   var _loc23_ = this[_loc17_ + "LabelSpacing"];
   var _loc14_ = this[_loc17_ + "LabelMultiple"];
   var _loc20_ = this[_loc17_ + "AxisLabelSpacing"];
   var _loc21_ = this.tickmarkLabelTextFormat;
   var _loc26_;
   var _loc8_;
   var _loc19_;
   var _loc5_;
   if(side == "left")
   {
      _loc26_ = - _loc23_;
      _loc8_ = 0;
      _loc19_ = -1;
      _loc5_ = this.scalesMC.leftMC;
      var labelSettings = {mc:_loc5_,textFormat:_loc21_,embedFonts:true,sizeRatio:1.2,x:_loc26_,y:y,vAlign:"center",hAlign:"right",extraSpacing:2};
   }
   else
   {
      if(side != "right")
      {
         return undefined;
      }
      _loc26_ = this.plotWidth + _loc23_;
      _loc8_ = this.plotWidth;
      _loc19_ = 1;
      _loc5_ = this.scalesMC.rightMC;
      var labelSettings = {mc:_loc5_,textFormat:_loc21_,embedFonts:true,sizeRatio:1.2,x:_loc26_,y:y,vAlign:"center",hAlign:"left",extraSpacing:2};
   }
   _loc5_._alpha = this.borderAndScalesAlpha;
   var _loc9_ = 3 * _loc19_ + _loc8_;
   var _loc12_ = 7 * _loc19_ + _loc8_;
   var axisMin = this._yAxisMin;
   var height = this.plotHeight;
   var scale = (- this.plotHeight) / (this._yAxisMax - this._yAxisMin);
   var _loc22_ = this.yPropertyCapNamesList[this._yAxisType];
   this.getScaleType = this["get" + scaleType + "From" + _loc22_];
   this.getAxisType = this["get" + _loc22_ + "From" + scaleType];
   var dispText = this.displayText;
   var _loc27_;
   var _loc29_;
   if(this._yAxisType == 0)
   {
      this.getY = function(z)
      {
         return (this.getAxisType(z,0) - axisMin) * scale;
      };
      if(scaleType == "LogLum")
      {
         _loc27_ = this.getScaleType(this._yAxisMin,0);
         _loc29_ = this.getScaleType(this._yAxisMax,0);
      }
      else
      {
         _loc27_ = this.getScaleType(this._yAxisMax,0);
         _loc29_ = this.getScaleType(this._yAxisMin,0);
      }
   }
   else
   {
      this.getY = function(z)
      {
         return - height - (this.getAxisType(z,0) - axisMin) * scale;
      };
      if(scaleType == "LogLum")
      {
         _loc27_ = this.getScaleType(this._yAxisMax,0);
         _loc29_ = this.getScaleType(this._yAxisMin,0);
      }
      else
      {
         _loc27_ = this.getScaleType(this._yAxisMin,0);
         _loc29_ = this.getScaleType(this._yAxisMax,0);
      }
   }
   var _loc15_;
   var _loc24_;
   if(scaleType == "LogLum")
   {
      _loc15_ = function(lum, y)
      {
         labelSettings.y = y;
         dispText("10<sup>" + lum + "</sup>",labelSettings);
      };
      _loc24_ = 0;
   }
   else
   {
      _loc15_ = function(val, y)
      {
         labelSettings.y = y;
         dispText(val,labelSettings);
      };
      _loc24_ = 1;
   }
   var _loc7_ = [];
   var _loc3_;
   if(_loc24_ == 0)
   {
      _loc3_ = 1;
      while(_loc3_ < 10)
      {
         _loc7_.push(Math.log(_loc3_) / 2.302585092994046);
         _loc3_ = _loc3_ + 1;
      }
   }
   else if(_loc24_ == 1)
   {
      _loc7_.push(0.5);
   }
   var _loc16_ = Math.floor(_loc27_);
   var _loc13_ = Math.ceil(_loc29_);
   var _loc18_;
   if(side == "left")
   {
      _loc18_ = 13643824;
   }
   else
   {
      _loc18_ = 1924851;
   }
   _loc5_.lineStyle(this.borderAndScalesLineThickness,_loc18_);
   this.tickmarkLabelTextFormat.color = _loc18_;
   this.axisLabelTextFormat.color = _loc18_;
   var _loc4_ = _loc16_;
   var _loc2_;
   var _loc6_;
   while(_loc4_ <= _loc13_)
   {
      _loc2_ = this.getY(_loc4_);
      if(_loc2_ <= 0 && _loc2_ >= - height)
      {
         _loc5_.moveTo(_loc8_,_loc2_);
         _loc5_.lineTo(_loc12_,_loc2_);
         if(_loc4_ % _loc14_ == 0)
         {
            _loc15_(_loc4_,_loc2_);
         }
      }
      _loc3_ = 0;
      while(_loc3_ < _loc7_.length)
      {
         _loc6_ = _loc4_ + _loc7_[_loc3_];
         _loc2_ = this.getY(_loc6_);
         if(_loc2_ <= 0 && _loc2_ >= - height)
         {
            _loc5_.moveTo(_loc8_,_loc2_);
            _loc5_.lineTo(_loc9_,_loc2_);
         }
         _loc3_ = _loc3_ + 1;
      }
      _loc4_ = _loc4_ + 1;
   }
   var _loc10_ = _loc5_.createEmptyMovieClip("axisLabelMC",1000);
   this.addTextToWrapperMC(_loc10_,_loc25_,this.axisLabelTextFormat,this.displayText,this.drawCircle,true,false);
   if(_loc19_ < 0)
   {
      _loc10_._y = (- this.plotHeight + _loc10_._width) / 2;
      _loc10_._rotation = -90;
      _loc10_._x = - _loc20_ - _loc10_._width / 2;
   }
   else
   {
      _loc10_._y = (- this.plotHeight - _loc10_._width) / 2;
      _loc10_._rotation = 90;
      _loc10_._x = this.plotWidth + _loc20_ + _loc10_._width / 2;
   }
   this.tickmarkLabelTextFormat.color = this.borderAndScalesColor;
   this.axisLabelTextFormat.color = this.borderAndScalesColor;
   delete this.getY;
   delete this.getAxisType;
   delete this.getScaleType;
};
p.drawBVScale = function(side)
{
   var min = this._xAxisMin;
   var scale = this.plotWidth / (this._xAxisMax - this._xAxisMin);
   var width = this.plotWidth;
   var getTypeFromBV = this.getTypeFromBV;
   var getLogTempFromType = this.getLogTempFromType;
   var _loc6_;
   var _loc22_;
   var _loc21_;
   var _loc9_;
   switch(this._xAxisType)
   {
      case 0:
         if(typeof this.BVLabelsList == "object")
         {
            _loc6_ = this.BVLabelsList;
         }
         else
         {
            _loc6_ = ["-0.3","-0.2","0.0","0.5","1.0","1.5","2.0"];
         }
         _loc22_ = this.getBVFromLogTemp(this._xAxisMax);
         _loc21_ = this.getBVFromLogTemp(this._xAxisMin);
         _loc9_ = function(bv)
         {
            return width - (getLogTempFromType(getTypeFromBV(bv)) - min) * scale;
         };
         break;
      case 1:
         if(typeof this.BVLabelsList == "object")
         {
            _loc6_ = this.BVLabelsList;
         }
         else
         {
            _loc6_ = ["-0.3","0.0","0.5","1.0","2.0"];
         }
         _loc22_ = this.getBVFromType(this._xAxisMin);
         _loc21_ = this.getBVFromType(this._xAxisMax);
         _loc9_ = function(bv)
         {
            return (getTypeFromBV(bv) - min) * scale;
         };
         break;
      case 2:
         if(typeof this.BVLabelsList == "object")
         {
            _loc6_ = this.BVLabelsList;
         }
         else
         {
            _loc6_ = ["0.0","0.5","1.0","1.5","2.0"];
         }
         _loc22_ = this._xAxisMin;
         _loc21_ = this._xAxisMax;
         _loc9_ = function(bv)
         {
            return (bv - min) * scale;
         };
   }
   var _loc8_;
   var _loc11_;
   var _loc4_;
   if(side == "top")
   {
      _loc8_ = - this.plotHeight;
      _loc11_ = -1;
      _loc4_ = this.scalesMC.topMC;
   }
   else
   {
      if(side != "bottom")
      {
         return undefined;
      }
      _loc8_ = 0;
      _loc11_ = 1;
      _loc4_ = this.scalesMC.bottomMC;
   }
   _loc4_._alpha = this.borderAndScalesAlpha;
   var _loc12_ = this.BVMinorStep;
   var _loc15_ = this.BVMajorMultiple;
   var _loc18_ = Math.ceil(_loc22_ / _loc12_);
   var _loc16_ = Math.floor(_loc21_ / _loc12_);
   var _loc23_ = 6;
   var _loc24_ = 4;
   var _loc20_ = 7;
   var _loc10_;
   if(_loc11_ < 0)
   {
      _loc10_ = 2 + _loc8_ - _loc20_;
   }
   else
   {
      _loc10_ = -2 + _loc20_;
   }
   var _loc13_ = this.tickmarkLabelTextFormat;
   _loc4_.lineStyle(this.borderAndScalesLineThickness,this.borderAndScalesColor);
   var _loc17_ = _loc8_ + _loc11_ * _loc23_;
   var _loc14_ = _loc8_ + _loc11_ * _loc24_;
   var _loc3_ = _loc18_;
   var _loc7_;
   var _loc5_;
   while(_loc3_ <= _loc16_)
   {
      _loc7_ = _loc3_ * _loc12_;
      _loc5_ = _loc9_(_loc7_);
      if(!(_loc5_ < 0 || _loc5_ > this.plotWidth))
      {
         if(_loc3_ % _loc15_ == 0)
         {
            _loc4_.moveTo(_loc5_,_loc8_);
            _loc4_.lineTo(_loc5_,_loc17_);
         }
         else
         {
            _loc4_.moveTo(_loc5_,_loc8_);
            _loc4_.lineTo(_loc5_,_loc14_);
         }
      }
      _loc3_ = _loc3_ + 1;
   }
   _loc3_ = 0;
   var _loc2_;
   while(_loc3_ < _loc6_.length)
   {
      _loc5_ = _loc9_(parseFloat(_loc6_[_loc3_]));
      if(!(_loc5_ < 0 || _loc5_ > this.plotWidth))
      {
         _loc4_.createTextField("label" + _loc3_,_loc3_,_loc5_,0,0,0);
         _loc2_ = _loc4_["label" + _loc3_];
         _loc2_.autoSize = "center";
         _loc2_.selectable = false;
         _loc2_.type = "dynamic";
         _loc2_.setNewTextFormat(_loc13_);
         _loc2_.text = _loc6_[_loc3_];
         _loc2_.embedFonts = true;
         if(_loc11_ < 0)
         {
            _loc2_._y = _loc10_ - _loc2_._height;
         }
         else
         {
            _loc2_._y = _loc10_;
         }
      }
      _loc3_ = _loc3_ + 1;
   }
   var _loc19_ = this.BVAxisLabelSpacing;
   _loc13_ = this.axisLabelTextFormat;
   _loc4_.createTextField("axisLabel",_loc3_,this.plotWidth / 2,0,0,0);
   _loc4_.axisLabel.autoSize = "center";
   _loc4_.axisLabel.selectable = false;
   _loc4_.axisLabel.type = "dynamic";
   _loc4_.axisLabel.setNewTextFormat(_loc13_);
   _loc4_.axisLabel.text = this.BVAxisLabel;
   _loc4_.axisLabel.embedFonts = true;
   _loc13_.italic = !_loc13_.italic;
   _loc4_.axisLabel.setTextFormat(0,1,_loc13_);
   _loc4_.axisLabel.setTextFormat(2,3,_loc13_);
   _loc13_.italic = !_loc13_.italic;
   if(_loc11_ < 0)
   {
      _loc4_.axisLabel._y = 2 + _loc8_ - _loc19_ - _loc4_.axisLabel._height;
   }
   else
   {
      _loc4_.axisLabel._y = -2 + _loc19_;
   }
};
p.drawTemperatureScale = function(side)
{
   var min = this._xAxisMin;
   var scale = this.plotWidth / (this._xAxisMax - this._xAxisMin);
   var width = this.plotWidth;
   var getBVFromLogTemp = this.getBVFromLogTemp;
   var getTypeFromBV = this.getTypeFromBV;
   var _loc6_;
   var _loc10_;
   switch(this._xAxisType)
   {
      case 0:
         if(typeof this.logTempLabelsList == "object")
         {
            _loc6_ = this.logTempLabelsList;
         }
         else
         {
            _loc6_ = ["50000","25000","10000","5000","2500"];
         }
         _loc10_ = function(t)
         {
            return width - (t - min) * scale;
         };
         break;
      case 1:
         if(typeof this.logTempLabelsList == "object")
         {
            _loc6_ = this.logTempLabelsList;
         }
         else
         {
            _loc6_ = ["50000","10000","6000","5000","2500"];
         }
         _loc10_ = function(t)
         {
            return (getTypeFromBV(getBVFromLogTemp(t)) - min) * scale;
         };
         break;
      case 2:
         if(typeof this.logTempLabelsList == "object")
         {
            _loc6_ = this.logTempLabelsList;
         }
         else
         {
            _loc6_ = ["50000","8000","6000","5000","4000","2500"];
         }
         _loc10_ = function(t)
         {
            return (getBVFromLogTemp(t) - min) * scale;
         };
   }
   var _loc7_;
   var _loc9_;
   var _loc5_;
   if(side == "top")
   {
      _loc7_ = - this.plotHeight;
      _loc9_ = -1;
      _loc5_ = this.scalesMC.topMC;
   }
   else
   {
      if(side != "bottom")
      {
         return undefined;
      }
      _loc7_ = 0;
      _loc9_ = 1;
      _loc5_ = this.scalesMC.bottomMC;
   }
   _loc5_._alpha = this.borderAndScalesAlpha;
   var _loc15_ = 6;
   var _loc13_ = 7;
   var _loc8_;
   if(_loc9_ < 0)
   {
      _loc8_ = 2 + _loc7_ - _loc13_;
   }
   else
   {
      _loc8_ = -2 + _loc13_;
   }
   var _loc14_ = this.tickmarkLabelTextFormat;
   _loc5_.lineStyle(this.borderAndScalesLineThickness,this.borderAndScalesColor);
   var _loc11_ = _loc9_ * _loc15_;
   var _loc3_ = 0;
   var _loc4_;
   var _loc2_;
   while(_loc3_ < _loc6_.length)
   {
      _loc4_ = _loc10_(Math.log(parseFloat(_loc6_[_loc3_])) / 2.302585092994046);
      if(!(_loc4_ < 0 || _loc4_ > this.plotWidth))
      {
         _loc5_.moveTo(_loc4_,_loc7_);
         _loc5_.lineTo(_loc4_,_loc7_ + _loc11_);
         _loc5_.createTextField("label" + _loc3_,_loc3_,_loc4_,0,0,0);
         _loc2_ = _loc5_["label" + _loc3_];
         _loc2_.autoSize = "center";
         _loc2_.selectable = false;
         _loc2_.type = "dynamic";
         _loc2_.setNewTextFormat(_loc14_);
         _loc2_.text = _loc6_[_loc3_];
         _loc2_.embedFonts = true;
         if(_loc9_ < 0)
         {
            _loc2_._y = _loc8_ - _loc2_._height;
         }
         else
         {
            _loc2_._y = _loc8_;
         }
      }
      _loc3_ = _loc3_ + 1;
   }
   var _loc12_ = this.logTempAxisLabelSpacing;
   _loc14_ = this.axisLabelTextFormat;
   _loc5_.createTextField("axisLabel",_loc3_,this.plotWidth / 2,0,0,0);
   _loc5_.axisLabel.autoSize = "center";
   _loc5_.axisLabel.selectable = false;
   _loc5_.axisLabel.type = "dynamic";
   _loc5_.axisLabel.setNewTextFormat(_loc14_);
   _loc5_.axisLabel.text = this.logTempAxisLabel;
   _loc5_.axisLabel.embedFonts = true;
   if(_loc9_ < 0)
   {
      _loc5_.axisLabel._y = 2 + _loc7_ - _loc12_ - _loc5_.axisLabel._height;
   }
   else
   {
      _loc5_.axisLabel._y = -2 + _loc12_;
   }
};
p.drawSpectralTypeScale = function(side)
{
   var min = this._xAxisMin;
   var scale = this.plotWidth / (this._xAxisMax - this._xAxisMin);
   var width = this.plotWidth;
   var getLogTempFromType = this.getLogTempFromType;
   var getBVFromLogTemp = this.getBVFromLogTemp;
   var _loc4_;
   switch(this._xAxisType)
   {
      case 0:
         _loc4_ = function(s)
         {
            return width - (getLogTempFromType(s) - min) * scale;
         };
         break;
      case 1:
         _loc4_ = function(s)
         {
            return (s - min) * scale;
         };
         break;
      case 2:
         _loc4_ = function(s)
         {
            return (getBVFromLogTemp(getLogTempFromType(s)) - min) * scale;
         };
   }
   var _loc3_;
   var _loc11_;
   var _loc2_;
   if(side == "top")
   {
      _loc3_ = - this.plotHeight;
      _loc11_ = -1;
      _loc2_ = this.scalesMC.topMC;
   }
   else
   {
      if(side != "bottom")
      {
         return undefined;
      }
      _loc3_ = 0;
      _loc11_ = 1;
      _loc2_ = this.scalesMC.bottomMC;
   }
   _loc2_._alpha = this.borderAndScalesAlpha;
   var _loc14_ = this.typeNumTickmarks;
   var _loc18_;
   var _loc16_;
   var _loc10_;
   var _loc8_;
   var _loc9_;
   var _loc5_;
   var _loc15_;
   var _loc7_;
   if(_loc14_ != 0)
   {
      _loc18_ = this.typeTickmarkLengths;
      _loc2_.lineStyle(this.borderAndScalesLineThickness,this.borderAndScalesColor);
      _loc16_ = _loc11_ * _loc18_[0];
      _loc10_ = [];
      _loc8_ = 0;
      while(_loc8_ <= 70)
      {
         _loc9_ = _loc4_(_loc8_);
         if(_loc9_ >= 0 && _loc9_ <= this.plotWidth)
         {
            _loc2_.moveTo(_loc9_,_loc3_);
            _loc2_.lineTo(_loc9_,_loc3_ + _loc16_);
         }
         if(_loc8_ > 0)
         {
            _loc10_.push(lx + (_loc9_ - lx) / 2);
         }
         var lx = _loc9_;
         _loc8_ += 10;
      }
      _loc5_ = _loc11_ * _loc18_[1];
      if(_loc14_ == 2)
      {
         _loc8_ = 0;
         while(_loc8_ < 70)
         {
            _loc9_ = _loc4_(_loc8_ + 5);
            if(_loc9_ >= 0 && _loc9_ <= this.plotWidth)
            {
               _loc2_.moveTo(_loc9_,_loc3_);
               _loc2_.lineTo(_loc9_,_loc3_ + _loc5_);
            }
            _loc8_ += 10;
         }
      }
      else if(_loc14_ == 3)
      {
         _loc8_ = 0;
         while(_loc8_ < 70)
         {
            _loc9_ = _loc4_(_loc8_ + 3.3333333333333335);
            if(_loc9_ >= 0 && _loc9_ <= this.plotWidth)
            {
               _loc2_.moveTo(_loc9_,_loc3_);
               _loc2_.lineTo(_loc9_,_loc3_ + _loc5_);
            }
            _loc9_ = _loc4_(_loc8_ + 6.666666666666667);
            if(_loc9_ >= 0 && _loc9_ <= this.plotWidth)
            {
               _loc2_.moveTo(_loc9_,_loc3_);
               _loc2_.lineTo(_loc9_,_loc3_ + _loc5_);
            }
            _loc8_ += 10;
         }
      }
      else if(_loc14_ == 4)
      {
         _loc8_ = 0;
         while(_loc8_ < 70)
         {
            _loc9_ = _loc4_(_loc8_ + 2.5);
            if(_loc9_ >= 0 && _loc9_ <= this.plotWidth)
            {
               _loc2_.moveTo(_loc9_,_loc3_);
               _loc2_.lineTo(_loc9_,_loc3_ + _loc5_);
            }
            _loc9_ = _loc4_(_loc8_ + 7.5);
            if(_loc9_ >= 0 && _loc9_ <= this.plotWidth)
            {
               _loc2_.moveTo(_loc9_,_loc3_);
               _loc2_.lineTo(_loc9_,_loc3_ + _loc5_);
            }
            _loc8_ += 10;
         }
         _loc15_ = _loc11_ * _loc18_[2];
         _loc8_ = 0;
         while(_loc8_ < 70)
         {
            _loc9_ = _loc4_(_loc8_ + 5);
            if(_loc9_ >= 0 && _loc9_ <= this.plotWidth)
            {
               _loc2_.moveTo(_loc9_,_loc3_);
               _loc2_.lineTo(_loc9_,_loc3_ + _loc15_);
            }
            _loc8_ += 10;
         }
      }
      else if(_loc14_ == 5)
      {
         _loc8_ = 0;
         while(_loc8_ < 70)
         {
            _loc7_ = 2;
            while(_loc7_ < 10)
            {
               _loc9_ = _loc4_(_loc8_ + _loc7_);
               if(_loc9_ >= 0 && _loc9_ <= this.plotWidth)
               {
                  _loc2_.moveTo(_loc9_,_loc3_);
                  _loc2_.lineTo(_loc9_,_loc3_ + _loc5_);
               }
               _loc7_ += 2;
            }
            _loc8_ += 10;
         }
      }
      else if(_loc14_ == 10)
      {
         _loc8_ = 0;
         while(_loc8_ < 70)
         {
            _loc7_ = 1;
            while(_loc7_ < 5)
            {
               _loc9_ = _loc4_(_loc8_ + _loc7_);
               if(_loc9_ >= 0 && _loc9_ <= this.plotWidth)
               {
                  _loc2_.moveTo(_loc9_,_loc3_);
                  _loc2_.lineTo(_loc9_,_loc3_ + _loc5_);
               }
               _loc9_ = _loc4_(_loc8_ + 5 + _loc7_);
               if(_loc9_ >= 0 && _loc9_ <= this.plotWidth)
               {
                  _loc2_.moveTo(_loc9_,_loc3_);
                  _loc2_.lineTo(_loc9_,_loc3_ + _loc5_);
               }
               _loc7_ = _loc7_ + 1;
            }
            _loc8_ += 10;
         }
         _loc15_ = _loc11_ * _loc18_[2];
         _loc8_ = 0;
         while(_loc8_ < 70)
         {
            _loc9_ = _loc4_(_loc8_ + 5);
            if(_loc9_ >= 0 && _loc9_ <= this.plotWidth)
            {
               _loc2_.moveTo(_loc9_,_loc3_);
               _loc2_.lineTo(_loc9_,_loc3_ + _loc15_);
            }
            _loc8_ += 10;
         }
      }
   }
   var _loc13_ = this.tickmarkLabelTextFormat;
   var _loc12_;
   if(_loc11_ < 0)
   {
      _loc12_ = 2 + _loc3_ - this.typeLabelSpacing;
   }
   else
   {
      _loc12_ = -2 + this.typeLabelSpacing;
   }
   var _loc17_;
   var _loc6_;
   if(this.typeShowLabels)
   {
      if(_loc10_ == undefined)
      {
         _loc10_ = [];
         _loc8_ = 0;
         while(_loc8_ <= 70)
         {
            _loc9_ = _loc4_(_loc8_);
            if(_loc8_ > 0)
            {
               _loc10_.push(lx + (_loc9_ - lx) / 2);
            }
            var lx = _loc9_;
            _loc8_ += 10;
         }
      }
      _loc17_ = ["O","B","A","F","G","K","M"];
      _loc7_ = 0;
      while(_loc7_ < 7)
      {
         _loc9_ = _loc10_[_loc7_];
         if(_loc9_ != null && _loc9_ >= 0 && _loc9_ <= this.plotWidth)
         {
            _loc2_.createTextField("label" + _loc7_,_loc7_,_loc9_,0,0,0);
            _loc6_ = _loc2_["label" + _loc7_];
            _loc6_.autoSize = "center";
            _loc6_.selectable = false;
            _loc6_.type = "dynamic";
            _loc6_.setNewTextFormat(_loc13_);
            _loc6_.text = _loc17_[_loc7_];
            _loc6_.embedFonts = true;
            if(_loc11_ < 0)
            {
               _loc6_._y = _loc12_ - _loc6_._height;
            }
            else
            {
               _loc6_._y = _loc12_;
            }
         }
         _loc7_ = _loc7_ + 1;
      }
   }
   var _loc19_ = this.typeAxisLabelSpacing;
   _loc13_ = this.axisLabelTextFormat;
   _loc2_.createTextField("axisLabel",2000,this.plotWidth / 2,0,0,0);
   _loc2_.axisLabel.autoSize = "center";
   _loc2_.axisLabel.selectable = false;
   _loc2_.axisLabel.type = "dynamic";
   _loc2_.axisLabel.setNewTextFormat(_loc13_);
   _loc2_.axisLabel.text = this.typeAxisLabel;
   _loc2_.axisLabel.embedFonts = true;
   if(_loc11_ < 0)
   {
      _loc2_.axisLabel._y = 2 + _loc3_ - _loc19_ - _loc2_.axisLabel._height;
   }
   else
   {
      _loc2_.axisLabel._y = -2 + _loc19_;
   }
};
p.xPropertyNamesList = ["logTemp","type","BV"];
p.yPropertyNamesList = ["logLum","absBolMag","absVisMag","appBolMag","appVisMag"];
p.xPropertyCapNamesList = [];
p.yPropertyCapNamesList = [];
i = 0;
while(i < p.xPropertyNamesList.length)
{
   p.xPropertyCapNamesList[i] = p.xPropertyNamesList[i].substring(0,1).toUpperCase() + p.xPropertyNamesList[i].substring(1);
   i++;
}
i = 0;
while(i < p.yPropertyNamesList.length)
{
   p.yPropertyCapNamesList[i] = p.yPropertyNamesList[i].substring(0,1).toUpperCase() + p.yPropertyNamesList[i].substring(1);
   i++;
}
p.getLogTempFromLogTemp = function(logTemp)
{
   return logTemp;
};
p.getLogTempFromBV = function(BV)
{
   return this.getLogTempFromType(this.getTypeFromBV(BV));
};
p.getBVFromBV = function(BV)
{
   return BV;
};
p.getBVFromType = function(type)
{
   return this.getBVFromLogTemp(this.getLogTempFromType(type));
};
p.getTypeFromLogTemp = function(logTemp)
{
   return this.getTypeFromBV(this.getBVFromLogTemp(logTemp));
};
p.getTypeFromType = function(type)
{
   return type;
};
p.getLogTempFromType = function(x)
{
   if(x < 8.5167)
   {
      return 4.7009 + x * (-0.01 + x * (0.0000392 + x * -0.00014247));
   }
   if(x < 16.1)
   {
      return 4.4348 + x * (0.08374 + x * (-0.010967 + x * 0.000288299));
   }
   if(x < 23.2167)
   {
      return 6.0516 + x * (-0.21754 + x * (0.007746 + x * -0.000099133));
   }
   if(x < 34.1833)
   {
      return 5.0538 + x * (-0.08861 + x * (0.0021924 + x * -0.000019396));
   }
   if(x < 50.5108)
   {
      return 4.7553 + x * (-0.06241 + x * (0.0014259 + x * -0.000011922));
   }
   if(x < 57.9775)
   {
      return 1.1584 + x * (0.15122 + x * (-0.0028034 + x * 0.000015988));
   }
   if(x < 64.3942)
   {
      return 26.4612 + x * (-1.15805 + x * (0.019779 + x * -0.000113846));
   }
   return -115.7858 + x * (5.46896 + x * (-0.0831343 + x * 0.000418879));
};
p.getBVFromLogTemp = function(x)
{
   if(x < 3.4457)
   {
      return 5537.8004 + x * (-4932.0424 + x * (1465.05066 + x * -145.092852));
   }
   if(x < 3.539)
   {
      return -11910.576 + x * (10259.54 + x * (-2943.84429 + x * 281.423057));
   }
   if(x < 3.5903)
   {
      return 24799.8561 + x * (-20859.7864 + x * (5849.40984 + x * -546.800936));
   }
   if(x < 3.6813)
   {
      return -9106.3822 + x * (7471.4869 + x * (-2041.57705 + x * 185.813204));
   }
   if(x < 3.7537)
   {
      return 218.0365 + x * (-127.1883 + x * (22.53246 + x * -1.085521));
   }
   if(x < 3.882)
   {
      return 1859.7977 + x * (-1439.3143 + x * (372.09094 + x * -32.127034));
   }
   if(x < 3.9637)
   {
      return -2864.907 + x * (2211.9259 + x * (-568.46551 + x * 48.635154));
   }
   if(x < 4.1317)
   {
      return 1342.6245 + x * (-972.6493 + x * (234.97622 + x * -18.932059));
   }
   return 11.874 + x * (-6.3924 + x * (1.11008 + x * -0.064278));
};
p.getTypeFromBV = function(x)
{
   if(x < -0.3021)
   {
      return 7009.7558 + x * (69770.6118 + x * (232162.4881 + x * 258039.06485));
   }
   if(x < -0.2623)
   {
      return 217.5991 + x * (2326.7725 + x * (8930.9142 + x * 11748.54064));
   }
   if(x < -0.1723)
   {
      return 29.9994 + x * (181.1411 + x * (750.8478 + x * 1353.23439));
   }
   if(x < -0.0825)
   {
      return 19.8398 + x * (4.2475 + x * (-275.8126 + x * -632.95316));
   }
   if(x < 0.0264)
   {
      return 20.3718 + x * (23.5866 + x * (-41.4702 + x * 313.59799));
   }
   if(x < 0.2766)
   {
      return 20.3763 + x * (23.0727 + x * (-21.9861 + x * 67.35311));
   }
   if(x < 0.439)
   {
      return 20.0065 + x * (27.0848 + x * (-36.4924 + x * 84.83639));
   }
   if(x < 0.6642)
   {
      return 45.9759 + x * (-150.373 + x * (367.7165 + x * -222.06249));
   }
   if(x < 0.8501)
   {
      return -41.1478 + x * (243.1104 + x * (-224.6559 + x * 75.20128));
   }
   if(x < 1.0695)
   {
      return -19.9166 + x * (168.1854 + x * (-136.5193 + x * 40.64197));
   }
   if(x < 1.3622)
   {
      return 6.6348 + x * (93.7057 + x * (-66.8779 + x * 18.93618));
   }
   if(x < 1.4815)
   {
      return -567.6877 + x * (1358.5475 + x * (-995.4066 + x * 246.1492));
   }
   if(x < 1.5305)
   {
      return 5740.3207 + x * (-11415.4409 + x * (7627.2188 + x * -1693.98275));
   }
   if(x < 1.6464)
   {
      return -1788.0326 + x * (3341.2138 + x * (-2014.5026 + x * 405.92391));
   }
   if(x < 1.9479)
   {
      return -36.4698 + x * (149.542 + x * (-75.8971 + x * 13.42411));
   }
   if(x < 2.1121)
   {
      return -1255.211 + x * (2026.574 + x * (-1039.5277 + x * 178.32699));
   }
   return -66110.1638 + x * (94144.6344 + x * (-44653.4522 + x * 7061.43043));
};
p.getLogLumFromLogLum = function(lum)
{
   return lum;
};
p.getLogLumFromAbsBolMag = function(absBol)
{
   return this.getLogLumFromMag(absBol);
};
p.getLogLumFromAbsVisMag = function(absVis, BC)
{
   if(BC == undefined)
   {
      BC = 0;
   }
   return this.getLogLumFromMag(absVis + BC);
};
p.getLogLumFromAppBolMag = function(appBol)
{
   return this.getLogLumFromMag(appBol - this._distModulus);
};
p.getLogLumFromAppVisMag = function(appVis, BC)
{
   if(BC == undefined)
   {
      BC = 0;
   }
   return this.getLogLumFromMag(appVis - this._distModulus + BC);
};
p.getAbsBolMagFromLogLum = function(lum)
{
   return this.getMagFromLogLum(lum);
};
p.getAbsBolMagFromAbsBolMag = function(absBol)
{
   return absBol;
};
p.getAbsBolMagFromAbsVisMag = function(absVis, BC)
{
   if(BC == undefined)
   {
      BC = 0;
   }
   return absVis + BC;
};
p.getAbsBolMagFromAppBolMag = function(appBol)
{
   return appBol - this._distModulus;
};
p.getAbsBolMagFromAppVisMag = function(appVis, BC)
{
   if(BC == undefined)
   {
      BC = 0;
   }
   return appVis - this._distModulus + BC;
};
p.getAbsVisMagFromLogLum = function(lum, BC)
{
   if(BC == undefined)
   {
      BC = 0;
   }
   return this.getMagFromLogLum(lum) - BC;
};
p.getAbsVisMagFromAbsBolMag = function(absBol, BC)
{
   if(BC == undefined)
   {
      BC = 0;
   }
   return absBol - BC;
};
p.getAbsVisMagFromAbsVisMag = function(absVis)
{
   return absVis;
};
p.getAbsVisMagFromAppBolMag = function(appBol, BC)
{
   if(BC == undefined)
   {
      BC = 0;
   }
   return appBol - this._distModulus - BC;
};
p.getAbsVisMagFromAppVisMag = function(appVis)
{
   return appVis - this._distModulus;
};
p.getAppBolMagFromLogLum = function(lum)
{
   return this.getMagFromLogLum(lum) + this._distModulus;
};
p.getAppBolMagFromAbsBolMag = function(absBol)
{
   return absBol + this._distModulus;
};
p.getAppBolMagFromAbsVisMag = function(absVis, BC)
{
   if(BC == undefined)
   {
      BC = 0;
   }
   return absVis + BC + this._distModulus;
};
p.getAppBolMagFromAppBolMag = function(appBol)
{
   return appBol;
};
p.getAppBolMagFromAppVisMag = function(appVis, BC)
{
   if(BC == undefined)
   {
      BC = 0;
   }
   return appVis + BC;
};
p.getAppVisMagFromLogLum = function(lum, BC)
{
   if(BC == undefined)
   {
      BC = 0;
   }
   return this.getMagFromLogLum(lum) - BC + this._distModulus;
};
p.getAppVisMagFromAbsBolMag = function(absBol, BC)
{
   if(BC == undefined)
   {
      BC = 0;
   }
   return absBol - BC + this._distModulus;
};
p.getAppVisMagFromAbsVisMag = function(absVis)
{
   return absVis + this._distModulus;
};
p.getAppVisMagFromAppBolMag = function(appBol, BC)
{
   if(BC == undefined)
   {
      BC = 0;
   }
   return appBol - BC;
};
p.getAppVisMagFromAppVisMag = function(appVis)
{
   return appVis;
};
p.getLogLumFromMag = function(M)
{
   return (4.75 - M) / 2.51189;
};
p.getMagFromLogLum = function(L)
{
   return 4.75 - 2.51189 * L;
};
p.getBCFromLogTemp = function(x)
{
   if(x < 3.588)
   {
      return -1873.0763 + x * (1364.8081 + x * (-328.11949 + x * 25.958485));
   }
   if(x < 3.6978)
   {
      return -4208.8678 + x * (3317.811 + x * (-872.43468 + x * 76.5266));
   }
   if(x < 3.7957)
   {
      return -2920.8124 + x * (2272.8215 + x * (-589.83737 + x * 51.052264));
   }
   if(x < 3.903)
   {
      return 1749.5431 + x * (-1418.5107 + x * (382.67484 + x * -34.353217));
   }
   if(x < 4.1317)
   {
      return -2011.2742 + x * (1472.2021 + x * (-357.96384 + x * 28.900577));
   }
   return 123.5421 + x * (-77.8864 + x * (17.20884 + x * -1.367489));
};
p.getLogLumFromLogTempAndClass = function(x, lumClass)
{
   switch(lumClass)
   {
      case 1:
         if(x < 4.1476)
         {
            return 44.8387 + x * (-30.1309 + x * (7.59468 + x * -0.636977));
         }
         return -459.5864 + x * (334.7205 + x * (-80.37116 + x * 6.432557));
         break;
      case 2:
         if(x < 4.0358)
         {
            return -36.2843 + x * (39.6781 + x * (-12.545 + x * 1.280459));
         }
         return -37.0612 + x * (40.2556 + x * (-12.68811 + x * 1.292279));
         break;
      case 3:
         if(x < 3.9092)
         {
            return -53.8721 + x * (59.2071 + x * (-19.71611 + x * 2.108195));
         }
         return 161.9073 + x * (-106.3856 + x * (22.64341 + x * -1.503738));
         break;
      case 4:
         if(x < 4.1372)
         {
            return -167.256 + x * (125.271 + x * (-31.96691 + x * 2.804002));
         }
         return 54.567 + x * (-35.5787 + x * (6.91186 + x * -0.328444));
         break;
      default:
         if(x < 3.5081)
         {
            return -4686.707 + x * (4157.5332 + x * (-1232.05177 + x * 121.875554));
         }
         if(x < 3.5799)
         {
            return 22801.9307 + x * (-19349.4898 + x * (5468.65774 + x * -514.806626));
         }
         if(x < 3.728)
         {
            return -9950.2659 + x * (8097.5483 + x * (-2198.40972 + x * 199.100683));
         }
         if(x < 3.8287)
         {
            return 10594.1896 + x * (-8435.0942 + x * (2236.33537 + x * -197.427256));
         }
         if(x < 3.9156)
         {
            return -7990.8168 + x * (6127.2576 + x * (-1567.12652 + x * 133.707956));
         }
         if(x < 4.2129)
         {
            return 277.0365 + x * (-207.2491 + x * (50.62412 + x * -4.009536));
         }
         if(x < 4.6015)
         {
            return -280.446 + x * (189.7309 + x * (-43.6049 + x * 3.446011));
         }
         return -9724.5727 + x * (6346.9359 + x * (-1381.69136 + x * 100.377185));
   }
};
p.getSpectralTypeNumber = function(typeStr)
{
   var _loc6_ = typeStr.split(" ");
   var _loc2_ = _loc6_[0];
   var _loc1_ = 1;
   while(_loc1_ < _loc6_.length)
   {
      _loc2_ += _loc6_[_loc1_];
      _loc1_ = _loc1_ + 1;
   }
   _loc2_ = _loc2_.toLowerCase();
   var _loc7_ = _loc2_.charAt(0);
   var _loc9_;
   if(_loc7_ == "o")
   {
      _loc9_ = 0;
   }
   else if(_loc7_ == "b")
   {
      _loc9_ = 10;
   }
   else if(_loc7_ == "a")
   {
      _loc9_ = 20;
   }
   else if(_loc7_ == "f")
   {
      _loc9_ = 30;
   }
   else if(_loc7_ == "g")
   {
      _loc9_ = 40;
   }
   else if(_loc7_ == "k")
   {
      _loc9_ = 50;
   }
   else
   {
      if(_loc7_ != "m")
      {
         return null;
      }
      _loc9_ = 60;
   }
   var _loc4_ = Infinity;
   _loc1_ = 0;
   var _loc3_;
   while(_loc1_ < 10)
   {
      _loc3_ = _loc2_.indexOf(String(_loc1_));
      if(_loc3_ != -1)
      {
         if(_loc3_ < _loc4_)
         {
            _loc4_ = _loc3_;
         }
      }
      _loc1_ = _loc1_ + 1;
   }
   var _loc10_;
   var _loc5_;
   var _loc8_;
   if(_loc4_ == Infinity)
   {
      _loc9_ += 5;
      _loc10_ = _loc2_.slice(1);
   }
   else
   {
      _loc5_ = _loc4_;
      _loc1_ = 0;
      while(_loc1_ < 10)
      {
         _loc3_ = _loc2_.lastIndexOf(String(_loc1_));
         if(_loc3_ > _loc5_)
         {
            _loc5_ = _loc3_;
         }
         _loc1_ = _loc1_ + 1;
      }
      _loc8_ = parseFloat(_loc2_.slice(_loc4_,_loc5_ + 1));
      if(_loc8_ < 0 || _loc8_ >= 10 || isNaN(_loc8_) || !isFinite(_loc8_))
      {
         return null;
      }
      _loc9_ += _loc8_;
      _loc10_ = _loc2_.slice(_loc5_ + 1);
   }
   return _loc9_;
};
p.addTextToWrapperMC = function(wmc, textString, tf, dispTextFunc, drawCircleFunc, embedFonts, showBackground, backgroundColor, backgroundAlpha)
{
   var _loc4_ = {};
   var _loc19_ = tf.getTextExtent("8");
   var _loc7_ = Math.round(tf.size / 4);
   if(_loc7_ < 3)
   {
      _loc7_ = 3;
   }
   var _loc14_;
   if(_loc7_ < 5)
   {
      _loc14_ = 1;
   }
   else
   {
      _loc14_ = 0.3 * _loc7_;
   }
   var _loc8_ = _loc19_.height - _loc7_;
   var _loc9_ = _loc7_ + 2 * _loc14_;
   if(tf.size <= 10)
   {
      _loc4_.sizeRatio = 1.25;
   }
   else if(tf.size <= 12 || tf.size == null)
   {
      _loc4_.sizeRatio = 1.3;
   }
   else if(tf.size <= 14)
   {
      _loc4_.sizeRatio = 1.4;
   }
   else if(tf.size <= 16)
   {
      _loc4_.sizeRatio = 1.5;
   }
   else if(tf.size <= 20)
   {
      _loc4_.sizeRatio = 1.7;
   }
   else if(tf.size >= 30)
   {
      _loc4_.sizeRatio = 2;
   }
   var _loc5_ = textString.split("<sol>");
   _loc4_.mc = wmc;
   _loc4_.hAlign = "left";
   _loc4_.vAlign = "top";
   _loc4_.embedFonts = embedFonts;
   _loc4_.textFormat = tf;
   var _loc3_ = wmc.createEmptyMovieClip("solsMC",10);
   var _loc10_ = tf.color;
   var _loc2_ = 0;
   var _loc6_;
   if(_loc5_[0].length != 0)
   {
      _loc4_.x = 0;
      _loc4_.depth = 100;
      _loc6_ = dispTextFunc(_loc5_[0],_loc4_);
      _loc2_ += _loc6_.textWidth;
   }
   var _loc1_ = 1;
   while(_loc1_ < _loc5_.length)
   {
      _loc2_ += _loc9_;
      _loc3_.lineStyle(1,_loc10_);
      drawCircleFunc(_loc3_,_loc2_,_loc8_,_loc7_);
      _loc3_.lineStyle(undefined);
      _loc3_.beginFill(_loc10_);
      drawCircleFunc(_loc3_,_loc2_,_loc8_,_loc14_);
      _loc3_.endFill();
      _loc2_ += _loc9_;
      if(_loc5_[_loc1_].length != 0)
      {
         _loc4_.x = _loc2_;
         _loc4_.depth = 100 + _loc1_;
         _loc6_ = dispTextFunc(_loc5_[_loc1_],_loc4_);
         _loc2_ += _loc6_.textWidth;
      }
      _loc1_ = _loc1_ + 1;
   }
   wmc.totalWidth = _loc2_;
   var _loc18_;
   var _loc17_;
   var _loc13_;
   if(showBackground)
   {
      _loc18_ = wmc._width;
      _loc17_ = wmc._height - 4;
      _loc13_ = wmc.createEmptyMovieClip("backgroundMC",0);
      _loc13_.lineStyle(undefined);
      _loc13_.beginFill(backgroundColor,backgroundAlpha);
      _loc13_.moveTo(0,0);
      _loc13_.lineTo(_loc18_,0);
      _loc13_.lineTo(_loc18_,_loc17_);
      _loc13_.lineTo(0,_loc17_);
      _loc13_.lineTo(0,0);
      _loc13_.endFill();
   }
   return wmc;
};
p.drawCircle = function(mc, x, y, r)
{
   mc.moveTo(x + r,y);
   mc.curveTo(x + r,y - 0.4142 * r,x + 0.7071 * r,y - 0.7071 * r);
   mc.curveTo(x + 0.4142 * r,y - r,x,y - r);
   mc.curveTo(x - 0.4142 * r,y - r,x - 0.7071 * r,y - 0.7071 * r);
   mc.curveTo(x - r,y - 0.4142 * r,x - r,y);
   mc.curveTo(x - r,y + 0.4142 * r,x - 0.7071 * r,y + 0.7071 * r);
   mc.curveTo(x - 0.4142 * r,y + r,x,y + r);
   mc.curveTo(x + 0.4142 * r,y + r,x + 0.7071 * r,y + 0.7071 * r);
   mc.curveTo(x + r,y + 0.4142 * r,x + r,y);
};
p.displayText = function(textString, options)
{
   textString = String(textString);
   var _loc29_;
   var _loc0_;
   if(options.depth != undefined)
   {
      _loc29_ = options.depth;
   }
   else if(_global._displayedTextLastDepthUsed != undefined)
   {
      _loc29_ = ++_global._displayedTextLastDepthUsed;
   }
   else
   {
      _loc29_ = _global._displayedTextLastDepthUsed = 913001;
   }
   var _loc30_;
   if(options.name != undefined)
   {
      _loc30_ = options.name;
   }
   else
   {
      _loc30_ = "_textWrapper_" + _loc29_;
   }
   var _loc7_;
   if(options.mc != undefined)
   {
      _loc7_ = options.mc.createEmptyMovieClip(_loc30_,_loc29_);
   }
   else
   {
      _loc7_ = this.createEmptyMovieClip(_loc30_,_loc29_);
   }
   if(options.x != undefined)
   {
      _loc7_._x = options.x;
   }
   if(options.y != undefined)
   {
      _loc7_._y = options.y;
   }
   var _loc23_;
   if(options.embedFonts != undefined)
   {
      _loc23_ = options.embedFonts;
   }
   else
   {
      _loc23_ = false;
   }
   var _loc12_;
   if(options.textFormat != undefined)
   {
      _loc12_ = options.textFormat;
   }
   else
   {
      _loc12_ = new TextFormat(null,12);
   }
   var _loc13_ = new TextFormat();
   for(var _loc19_ in _loc12_)
   {
      _loc13_[_loc19_] = _loc12_[_loc19_];
   }
   if(options.sizeRatio != undefined)
   {
      _loc13_.size = _loc12_.size / options.sizeRatio;
   }
   else
   {
      _loc13_.size = _loc12_.size / 1.5;
   }
   _loc7_.createTextField("_0",0,0,0,0,0);
   _loc7_._0.autoSize = "left";
   _loc7_._0.embedFonts = _loc23_;
   _loc7_._0.setNewTextFormat(_loc12_);
   _loc7_._0.text = "X";
   _loc7_._0._visible = false;
   _loc7_.createTextField("_1",1,0,0,0,0);
   _loc7_._1.autoSize = "left";
   _loc7_._1.embedFonts = _loc23_;
   _loc7_._1.setNewTextFormat(_loc13_);
   _loc7_._1.text = "X";
   _loc7_._1._visible = false;
   var _loc28_ = _loc7_._0._height;
   var _loc31_ = _loc7_._1._height;
   var _loc25_;
   if(options.superscriptPosition != undefined)
   {
      _loc25_ = - options.superscriptPosition;
   }
   else
   {
      _loc25_ = 0;
   }
   var _loc26_;
   if(options.subscriptPosition != undefined)
   {
      _loc26_ = _loc28_ - _loc31_ + options.subscriptPosition;
   }
   else
   {
      _loc26_ = _loc28_ - _loc31_;
   }
   var _loc24_;
   if(options.extraSpacing != undefined)
   {
      _loc24_ = options.extraSpacing;
   }
   else
   {
      _loc24_ = 0.5;
   }
   var _loc4_ = [];
   var _loc15_ = 0;
   var _loc17_ = 0;
   var _loc9_ = 0;
   var _loc6_;
   do
   {
      var ind = textString.indexOf("<su",_loc9_);
      if(ind == -1)
      {
         _loc4_.push({pos:_loc15_,str:textString});
      }
      else if(textString.charAt(ind + 3) == "b" && textString.charAt(ind + 4) == ">")
      {
         if(ind != 0)
         {
            _loc4_.push({pos:_loc15_,str:textString.substring(0,ind)});
         }
         textString = textString.slice(ind + 5);
         _loc15_ = -1;
         _loc6_ = textString.indexOf("</sub>");
         if(_loc6_ != -1)
         {
            if(_loc6_ != 0)
            {
               _loc4_.push({pos:_loc15_,str:textString.substring(0,_loc6_)});
            }
            textString = textString.slice(_loc6_ + 6);
            _loc15_ = 0;
         }
         _loc9_ = 0;
      }
      else if(textString.charAt(ind + 3) == "p" && textString.charAt(ind + 4) == ">")
      {
         if(ind != 0)
         {
            _loc4_.push({pos:_loc15_,str:textString.substring(0,ind)});
         }
         textString = textString.slice(ind + 5);
         _loc15_ = 1;
         _loc6_ = textString.indexOf("</sup>");
         if(_loc6_ != -1)
         {
            if(_loc6_ != 0)
            {
               _loc4_.push({pos:_loc15_,str:textString.substring(0,_loc6_)});
            }
            textString = textString.slice(_loc6_ + 6);
            _loc15_ = 0;
         }
         _loc9_ = 0;
      }
      else
      {
         _loc9_ = ind + 3;
      }
      _loc17_ = _loc17_ + 1;
   }
   while(ind != -1 && textString.length > 0 && _loc17_ < 100);
   if(_loc17_ >= 100)
   {
      trace("WARNING: iteration limit reached");
   }
   var _loc14_ = [];
   var _loc22_ = 0;
   var _loc18_ = 2;
   var _loc8_ = 0;
   var _loc11_;
   var _loc16_;
   var _loc21_;
   while(_loc8_ < _loc4_.length)
   {
      _loc11_ = "_" + _loc18_;
      _loc7_.createTextField(_loc11_,_loc18_++,0,0,0,0);
      _loc16_ = _loc7_[_loc11_];
      _loc16_.autoSize = "left";
      _loc16_.embedFonts = _loc23_;
      _loc16_.selectable = false;
      if(_loc4_[_loc8_].pos == 0)
      {
         _loc21_ = 0;
         _loc16_.setNewTextFormat(_loc12_);
      }
      else if(_loc4_[_loc8_].pos == 1)
      {
         _loc21_ = _loc25_;
         _loc16_.setNewTextFormat(_loc13_);
      }
      else
      {
         _loc21_ = _loc26_;
         _loc16_.setNewTextFormat(_loc13_);
      }
      _loc16_.text = _loc4_[_loc8_].str;
      _loc14_.push({tf:_loc16_,dy:_loc21_});
      _loc22_ += _loc16_.textWidth;
      _loc8_ = _loc8_ + 1;
   }
   _loc22_ += _loc24_ * (_loc14_.length - 1);
   var _loc19_;
   if(options.hAlign == "left")
   {
      _loc19_ = -2;
   }
   else if(options.hAlign == "right")
   {
      _loc19_ = -2 - _loc22_;
   }
   else
   {
      _loc19_ = -2 - _loc22_ / 2;
   }
   var _loc27_;
   if(options.vAlign == "top")
   {
      _loc27_ = -2;
   }
   else if(options.vAlign == "bottom")
   {
      _loc27_ = - _loc28_ + 2;
   }
   else
   {
      _loc27_ = (- _loc28_) / 2;
   }
   _loc8_ = 0;
   var _loc5_;
   while(_loc8_ < _loc14_.length)
   {
      _loc5_ = _loc14_[_loc8_];
      _loc5_.tf._x = _loc19_;
      _loc5_.tf._y = _loc27_ + _loc5_.dy;
      _loc19_ += _loc5_.tf.textWidth + _loc24_;
      _loc8_ = _loc8_ + 1;
   }
   _loc7_.textWidth = _loc22_;
   return _loc7_;
};
p.plotStars = function(layerName, linkageName, initObj)
{
   var _loc4_ = this[layerName + "List"];
   if(_loc4_ == undefined)
   {
      return undefined;
   }
   if(typeof linkageName != "string")
   {
      linkageName = "HR Diagram Dot";
   }
   if(typeof initObj != "object")
   {
      switch(layerName)
      {
         case "brightStars":
            initObj = {dotSize:3,dotColor:6316287};
            break;
         case "nearbyStars":
            initObj = {dotSize:3,dotColor:4231232};
            break;
         case "brightAndNearbyStars":
            initObj = {dotSize:4,dotColor:16711680};
            break;
         case "nearbyWhiteDwarfs":
            initObj = {dotSize:3,dotColor:0};
      }
   }
   var _loc6_ = [];
   var _loc5_;
   var _loc3_;
   if(layerName == "nearbyWhiteDwarfs")
   {
      _loc5_ = 0;
      while(_loc5_ < _loc4_.length)
      {
         _loc3_ = {};
         for(var _loc7_ in initObj)
         {
            _loc3_[_loc7_] = initObj[_loc7_];
         }
         _loc3_.BV = _loc4_[_loc5_].BV;
         _loc3_.absVisMag = _loc4_[_loc5_].absVisMag;
         _loc6_.push(_loc3_);
         _loc5_ = _loc5_ + 1;
      }
   }
   else
   {
      _loc5_ = 0;
      while(_loc5_ < _loc4_.length)
      {
         _loc3_ = {};
         for(_loc7_ in initObj)
         {
            _loc3_[_loc7_] = initObj[_loc7_];
         }
         _loc3_.type = _loc4_[_loc5_].type;
         _loc3_.absVisMag = _loc4_[_loc5_].absVisMag;
         _loc6_.push(_loc3_);
         _loc5_ = _loc5_ + 1;
      }
   }
   this.addObjectLayer(layerName,true,null,_loc6_,linkageName);
   return this[layerName];
};
p.brightAndNearbyStarsList = [{sysNum:53,HR:7557,BV:0.22,appVisMag:0.77,absVisMag:2.22,type:27,lumNum:4.5,typeStr:"A7 IV-V",mass:1.71,plx:0.19497,name:"GJ 768",altName:"Altair"},{sysNum:5,HR:2491,BV:0,appVisMag:-1.43,absVisMag:1.47,type:21,lumNum:5,typeStr:"A1 V",mass:1.99,plx:0.38002,name:"GJ 244 A",altName:"Sirius"},{sysNum:13,HR:2943,BV:0.42,appVisMag:0.38,absVisMag:2.66,type:35,lumNum:4.5,typeStr:"F5 IV-V",mass:1.57,plx:0.28605,name:"GJ 280 A",altName:"Procyon"},{sysNum:1,HR:5459,BV:0.71,appVisMag:0.01,absVisMag:4.38,type:42,lumNum:5,typeStr:"G2 V",mass:1.14,plx:0.74723,name:"GJ 559 A",altName:"alpha Centauri A"},{sysNum:1,HR:5460,BV:0.88,appVisMag:1.34,absVisMag:5.71,type:50,lumNum:5,typeStr:"K0 V",mass:0.92,plx:0.74723,name:"GJ 559 B",altName:"alpha Centauri B"}];
p.nearbyWhiteDwarfsList = [{sysNum:5,BV:-0.03,appVisMag:8.44,absVisMag:11.34,lumNum:7,typeStr:"DA2",mass:0.5,plx:0.38002,name:"GJ 244 B",altName:"Sirius B"},{sysNum:13,BV:0,appVisMag:10.7,absVisMag:12.98,lumNum:7,typeStr:"DA",mass:0.5,plx:0.28605,name:"GJ 280 B",altName:"Procyon B"},{sysNum:31,BV:0.56,appVisMag:12.38,absVisMag:14.21,lumNum:7,typeStr:"DZ7",mass:0.5,plx:0.23188,name:"GJ 35",altName:"WD 0046+051"},{sysNum:39,BV:0.18,appVisMag:11.5,absVisMag:13.18,lumNum:7,typeStr:"DQ6",mass:0.5,plx:0.21657,name:"GJ 440",altName:"WD 1142-645"},{sysNum:50,BV:0.11,appVisMag:9.52,absVisMag:11.01,lumNum:7,typeStr:"DA4",mass:0.5,plx:0.199,name:"GJ 166 B",altName:""},{sysNum:60,BV:0.33,appVisMag:12.44,absVisMag:13.72,lumNum:7,typeStr:"DC5",mass:0.5,plx:0.18063,name:"GJ 169.1 B",altName:""},{sysNum:80,BV:0.4,appVisMag:14.12,absVisMag:15.2,lumNum:7,typeStr:"DXP9",mass:0.5,plx:0.1647,name:"GJ 1221",altName:""},{sysNum:94,BV:1.04,appVisMag:14.45,absVisMag:15.4,lumNum:7,typeStr:"DZ9",mass:0.5,plx:0.155,name:"GJ 223.2",altName:"WD 0552-041"}];
p.nearbyStarsList = [{sysNum:1,appVisMag:11.09,absVisMag:15.53,type:65.5,lumNum:5,typeStr:"M5.5 V",mass:0.11,plx:0.76887,name:"GJ 551",altName:"Proxima Centauri"},{sysNum:2,appVisMag:9.53,absVisMag:13.22,type:64,lumNum:5,typeStr:"M4.0 V",mass:0.17,plx:0.54698,name:"GJ 699",altName:"Barnard\'s Star"},{sysNum:3,appVisMag:13.44,absVisMag:16.55,type:66,lumNum:5,typeStr:"M6.0 V",mass:0.09,plx:0.4191,name:"GJ 406",altName:"Wolf 359"},{sysNum:4,appVisMag:7.47,absVisMag:10.44,type:62,lumNum:5,typeStr:"M2.0 V",mass:0.46,plx:0.39342,name:"GJ 411",altName:"Lalande 21185"},{sysNum:6,appVisMag:12.54,absVisMag:15.4,type:65.5,lumNum:5,typeStr:"M5.5 V",mass:0.11,plx:0.3737,name:"GJ 65 A",altName:"BL Ceti"},{sysNum:6,appVisMag:12.99,absVisMag:15.85,type:66,lumNum:5,typeStr:"M6.0 V",mass:0.1,plx:0.3737,name:"GJ 65 B",altName:"UV Ceti"},{sysNum:7,appVisMag:10.43,absVisMag:13.07,type:63.5,lumNum:5,typeStr:"M3.5 V",mass:0.17,plx:0.3369,name:"GJ 729",altName:"Ross 154"},{sysNum:8,appVisMag:12.29,absVisMag:14.79,type:65.5,lumNum:5,typeStr:"M5.5 V",mass:0.12,plx:0.316,name:"GJ 905",altName:"Ross 248"},{sysNum:9,appVisMag:3.73,absVisMag:6.19,type:52,lumNum:5,typeStr:"K2   V",mass:0.85,plx:0.30999,name:"GJ 144",altName:"epsilon Eridani"},{sysNum:10,appVisMag:7.34,absVisMag:9.75,type:61.5,lumNum:5,typeStr:"M1.5 V",mass:0.53,plx:0.30364,name:"GJ 887",altName:"Lacaille 9352"},{sysNum:11,appVisMag:11.13,absVisMag:13.51,type:64,lumNum:5,typeStr:"M4.0 V",mass:0.16,plx:0.29872,name:"GJ 447",altName:"Ross 128"},{sysNum:12,appVisMag:13.33,absVisMag:15.64,type:65,lumNum:5,typeStr:"M5.0 V J",mass:0.11,plx:0.2895,name:"GJ 866 A",altName:"EZ Aquarii A"},{sysNum:12,appVisMag:13.27,absVisMag:15.58,type:65,lumNum:5,typeStr:"M5e",mass:0.11,plx:0.2895,name:"GJ 866 B",altName:"EZ Aquarii B"},{sysNum:14,appVisMag:5.21,absVisMag:7.49,type:55,lumNum:5,typeStr:"K5.0 V",mass:0.7,plx:0.28604,name:"GJ 820 A",altName:"61 Cygni A"},{sysNum:14,appVisMag:6.03,absVisMag:8.31,type:57,lumNum:5,typeStr:"K7.0 V",mass:0.63,plx:0.28604,name:"GJ 820 B",altName:"61 Cygni B"},{sysNum:15,appVisMag:8.9,absVisMag:11.16,type:63,lumNum:5,typeStr:"M3.0 V",mass:0.35,plx:0.283,name:"GJ 725 A",altName:""},{sysNum:15,appVisMag:9.69,absVisMag:11.95,type:63.5,lumNum:5,typeStr:"M3.5 V",mass:0.26,plx:0.283,name:"GJ 725 B",altName:""},{sysNum:16,appVisMag:8.08,absVisMag:10.32,type:61.5,lumNum:5,typeStr:"M1.5 V",mass:0.49,plx:0.28059,name:"GJ 15 A",altName:"GX Andromedae"},{sysNum:16,appVisMag:11.06,absVisMag:13.3,type:63.5,lumNum:5,typeStr:"M3.5 V",mass:0.16,plx:0.28059,name:"GJ 15 B",altName:"GQ Andromedae"},{sysNum:17,appVisMag:4.69,absVisMag:6.89,type:55,lumNum:5,typeStr:"K5   Ve",mass:0.77,plx:0.27584,name:"GJ 845 A",altName:"epsilon Indi A"},{sysNum:18,appVisMag:14.78,absVisMag:16.98,type:66.5,lumNum:5,typeStr:"M6.5 V",mass:0.09,plx:0.2758,name:"GJ 1111",altName:"DX Cancri"},{sysNum:19,appVisMag:3.49,absVisMag:5.68,type:48,lumNum:5,typeStr:"G8   Vp",mass:0.92,plx:0.27439,name:"GJ 71",altName:"tau Ceti"},{sysNum:20,appVisMag:13.09,absVisMag:15.26,type:65.5,lumNum:5,typeStr:"M5.5 V",mass:0.11,plx:0.27201,name:"GJ 1061",altName:"Henry et al. 1997 & 2006"},{sysNum:21,appVisMag:12.02,absVisMag:14.17,type:64.5,lumNum:5,typeStr:"M4.5 V",mass:0.14,plx:0.26884,name:"GJ 54.1",altName:"YZ Ceti"},{sysNum:22,appVisMag:9.86,absVisMag:11.97,type:63.5,lumNum:5,typeStr:"M3.5 V",mass:0.26,plx:0.26376,name:"GJ 273",altName:"Luyten\'s Star"},{sysNum:23,appVisMag:15.14,absVisMag:17.22,type:67,lumNum:5,typeStr:"M7.0 V",mass:0.08,plx:0.26063,name:"SO 0253+1652",altName:"Henry et al. 2006"},{sysNum:24,appVisMag:17.4,absVisMag:19.42,type:68.5,lumNum:5,typeStr:"M8.5 V",mass:0.07,plx:0.25945,name:"SCR 1845-6357",altName:"Henry et al. 2006"},{sysNum:25,appVisMag:8.84,absVisMag:10.87,type:61.5,lumNum:5,typeStr:"M1.5 V",mass:0.39,plx:0.25527,name:"GJ 191",altName:"Kapteyn\'s Star"},{sysNum:26,appVisMag:6.67,absVisMag:8.69,type:60,lumNum:5,typeStr:"M0.0 V",mass:0.6,plx:0.25343,name:"GJ 825",altName:"AX Microscopii"},{sysNum:27,appVisMag:9.79,absVisMag:11.76,type:63,lumNum:5,typeStr:"M3.0 V",mass:0.28,plx:0.24806,name:"GJ 860 A",altName:"Kruger 60 A"},{sysNum:27,appVisMag:11.41,absVisMag:13.38,type:64,lumNum:5,typeStr:"M4.0 V",mass:0.16,plx:0.24806,name:"GJ 860 B",altName:"Kruger 60 B"},{sysNum:28,appVisMag:17.39,absVisMag:19.37,type:68.5,lumNum:5,typeStr:"M8.5 V",mass:0.07,plx:0.24771,name:"DEN 1048-3956",altName:"Jao et al. 2005, Costa et al. 2005"},{sysNum:29,appVisMag:11.15,absVisMag:13.09,type:64.5,lumNum:5,typeStr:"M4.5 V J",mass:0.17,plx:0.24434,name:"GJ 234 A",altName:"Ross 614 A"},{sysNum:29,appVisMag:14.23,absVisMag:16.17,type:68,lumNum:5,typeStr:"M8V",mass:0.1,plx:0.24434,name:"GJ 234 B",altName:"Ross 614 B"},{sysNum:30,appVisMag:10.07,absVisMag:11.93,type:63,lumNum:5,typeStr:"M3.0 V",mass:0.26,plx:0.23601,name:"GJ 628",altName:"Wolf 1061"},{sysNum:32,appVisMag:8.55,absVisMag:10.35,type:63,lumNum:5,typeStr:"M3.0 V",mass:0.48,plx:0.2292,name:"GJ 1",altName:""},{sysNum:33,appVisMag:13.18,absVisMag:14.97,type:65.5,lumNum:5,typeStr:"M5.5 V J",mass:0.12,plx:0.2279,name:"GJ 473 A",altName:"Wolf 424 A"},{sysNum:33,appVisMag:13.17,absVisMag:14.96,type:67,lumNum:5,typeStr:"M7",mass:0.12,plx:0.2279,name:"GJ 473 B",altName:"Wolf 424 B"},{sysNum:34,appVisMag:12.27,absVisMag:14.03,type:64.5,lumNum:5,typeStr:"M4.5 V",mass:0.14,plx:0.2248,name:"GJ 83.1",altName:"TZ Arietis"},{sysNum:35,appVisMag:9.17,absVisMag:10.89,type:63,lumNum:5,typeStr:"M3.0 V",mass:0.39,plx:0.22049,name:"GJ 687",altName:""},{sysNum:36,appVisMag:15.6,absVisMag:17.32,type:66.5,lumNum:5,typeStr:"M6.5 V",mass:0.08,plx:0.2203,name:"LHS 292",altName:""},{sysNum:37,appVisMag:9.38,absVisMag:11.09,type:63,lumNum:5,typeStr:"M3.0 V",mass:0.36,plx:0.22025,name:"GJ 674",altName:""},{sysNum:38,appVisMag:13.46,absVisMag:15.17,type:65.5,lumNum:5,typeStr:"M5.5 V J",mass:0.11,plx:0.2202,name:"GJ 1245 A",altName:"G 208-044 A"},{sysNum:38,appVisMag:14.01,absVisMag:15.72,type:66,lumNum:5,typeStr:"M6.0 V",mass:0.1,plx:0.2202,name:"GJ 1245 B",altName:"G 208-045"},{sysNum:38,appVisMag:16.75,absVisMag:18.46,type:65.5,lumNum:5,typeStr:"M5.5",mass:0.07,plx:0.2202,name:"GJ 1245 C",altName:"G 208-044 B"},{sysNum:40,appVisMag:13.76,absVisMag:15.4,type:65.5,lumNum:5,typeStr:"M5.5 V",mass:0.11,plx:0.213,name:"GJ 1002",altName:""},{sysNum:41,appVisMag:10.17,absVisMag:11.81,type:63.5,lumNum:5,typeStr:"M3.5 V J",mass:0.27,plx:0.21259,name:"GJ 876 A",altName:"Ross 780"},{sysNum:42,appVisMag:13.9,absVisMag:15.51,type:65.5,lumNum:5,typeStr:"M5.5 V",mass:0.11,plx:0.20895,name:"LHS 288",altName:"Henry et al. 2006"},{sysNum:43,appVisMag:8.77,absVisMag:10.34,type:61,lumNum:5,typeStr:"M1.0 V",mass:0.48,plx:0.20602,name:"GJ 412 A",altName:""},{sysNum:43,appVisMag:14.48,absVisMag:16.05,type:65.5,lumNum:5,typeStr:"M5.5 V",mass:0.1,plx:0.20602,name:"GJ 412 B",altName:"WX Ursae Majoris"},{sysNum:44,appVisMag:6.59,absVisMag:8.16,type:57,lumNum:5,typeStr:"K7.0 V",mass:0.64,plx:0.20581,name:"GJ 380",altName:""},{sysNum:45,appVisMag:9.32,absVisMag:10.87,type:63,lumNum:5,typeStr:"M3.0 V",mass:0.39,plx:0.2046,name:"GJ 388",altName:""},{sysNum:46,appVisMag:8.66,absVisMag:10.2,type:63,lumNum:5,typeStr:"M3.0 V",mass:0.5,plx:0.20278,name:"GJ 832",altName:""},{sysNum:47,appVisMag:18.5,absVisMag:20.02,type:69,lumNum:5,typeStr:"M9.0 V",mass:0.07,plx:0.2014,name:"LP 944-020",altName:""},{sysNum:49,appVisMag:10.95,absVisMag:12.45,type:64.5,lumNum:5,typeStr:"M4.5 V",mass:0.21,plx:0.19965,name:"GJ 682",altName:""},{sysNum:50,appVisMag:4.43,absVisMag:5.92,type:51,lumNum:5,typeStr:"K1   Ve",mass:0.89,plx:0.199,name:"GJ 166 A",altName:"omicron 2 Eridani"},{sysNum:50,appVisMag:11.19,absVisMag:12.68,type:64.5,lumNum:5,typeStr:"M4.5 V",mass:0.2,plx:0.199,name:"GJ 166 C",altName:""},{sysNum:51,appVisMag:10.22,absVisMag:11.7,type:63.5,lumNum:5,typeStr:"M3.5 V",mass:0.29,plx:0.19804,name:"GJ 873",altName:"EV Lacertae"},{sysNum:52,appVisMag:4.2,absVisMag:5.66,type:50,lumNum:5,typeStr:"K0   Ve",mass:0.92,plx:0.19596,name:"GJ 702 A",altName:"70 Ophiuchi A"},{sysNum:53,appVisMag:6.05,absVisMag:7.51,type:55,lumNum:5,typeStr:"K5   Ve",mass:0.7,plx:0.19596,name:"GJ 702 B",altName:"70 Ophiuchi B"},{sysNum:54,appVisMag:14.06,absVisMag:15.47,type:65.5,lumNum:5,typeStr:"M5.5 V J",mass:0.11,plx:0.1912,name:"GJ 1116 A",altName:"EI Cancri"},{sysNum:54,appVisMag:14.92,absVisMag:16.33,type:65.5,lumNum:5,typeStr:"M5.5",mass:0.1,plx:0.1912,name:"GJ 1116 B",altName:""},{sysNum:55,appVisMag:11.31,absVisMag:12.71,type:63.5,lumNum:5,typeStr:"M3.5 V",mass:0.19,plx:0.19093,name:"G 099-049",altName:"Henry et al. 2006"},{sysNum:56,appVisMag:12.22,absVisMag:13.59,type:64.5,lumNum:5,typeStr:"M4.5 V",mass:0.15,plx:0.18792,name:"LHS 1723",altName:"Henry et al. 2006"},{sysNum:57,appVisMag:10.79,absVisMag:12.14,type:63.5,lumNum:5,typeStr:"M3.5 V",mass:0.24,plx:0.18584,name:"GJ 445",altName:""},{sysNum:58,appVisMag:8.46,absVisMag:9.79,type:61.5,lumNum:5,typeStr:"M1.5 V",mass:0.53,plx:0.18421,name:"GJ 526",altName:"Wolf 498"},{sysNum:59,appVisMag:11.41,absVisMag:12.71,type:65,lumNum:5,typeStr:"MV",mass:0.19,plx:0.18215,name:"LP 816-060",altName:""},{sysNum:60,appVisMag:11.04,absVisMag:12.32,type:64,lumNum:5,typeStr:"M4.0 V",mass:0.22,plx:0.18063,name:"GJ 169.1 A",altName:"Stein 2051"},{sysNum:61,appVisMag:10.02,absVisMag:11.29,type:63,lumNum:5,typeStr:"M3.0 V",mass:0.33,plx:0.17958,name:"GJ 251",altName:""},{sysNum:62,appVisMag:18.27,absVisMag:19.5,type:68.5,lumNum:5,typeStr:"M8.5 V",mass:0.07,plx:0.1765,name:"2MA 1835+3259",altName:""},{sysNum:63,appVisMag:7.95,absVisMag:9.17,type:61.5,lumNum:5,typeStr:"M1.5 V",mass:0.57,plx:0.17517,name:"GJ 205",altName:"Wolf 1453"},{sysNum:65,appVisMag:4.68,absVisMag:5.88,type:50,lumNum:5,typeStr:"K0   V",mass:0.89,plx:0.17359,name:"GJ 764",altName:"sigma Draconis"},{sysNum:66,appVisMag:8.12,absVisMag:9.31,type:61,lumNum:5,typeStr:"M1.0 V",mass:0.56,plx:0.17317,name:"GJ 229 A",altName:""},{sysNum:67,appVisMag:10.75,absVisMag:11.92,type:64,lumNum:5,typeStr:"M4.0 V",mass:0.26,plx:0.17169,name:"GJ 693",altName:""},{sysNum:68,appVisMag:9.11,absVisMag:10.28,type:63,lumNum:5,typeStr:"M3.0 V",mass:0.49,plx:0.17101,name:"GJ 752 A",altName:"Wolf 1055"},{sysNum:68,appVisMag:17.5,absVisMag:18.67,type:68,lumNum:5,typeStr:"M8.0 V",mass:0.07,plx:0.17101,name:"GJ 752 B",altName:"van Biesbroeck 10"},{sysNum:69,appVisMag:11.51,absVisMag:12.67,type:64,lumNum:5,typeStr:"M4.0 V",mass:0.2,plx:0.17037,name:"GJ 213",altName:"Ross 47"},{sysNum:70,appVisMag:5.75,absVisMag:6.9,type:55,lumNum:5,typeStr:"K5   Ve",mass:0.76,plx:0.16985,name:"GJ 570 A",altName:""},{sysNum:70,appVisMag:8.28,absVisMag:9.43,type:61,lumNum:5,typeStr:"M1.0 V J",mass:0.55,plx:0.16985,name:"GJ 570 B",altName:""},{sysNum:70,appVisMag:10.05,absVisMag:11.2,type:63,lumNum:5,typeStr:"M3V",mass:0.35,plx:0.16985,name:"GJ 570 C",altName:""},{sysNum:71,appVisMag:12.23,absVisMag:13.37,type:64.5,lumNum:5,typeStr:"M4.5 V",mass:0.16,plx:0.16903,name:"GJ 754",altName:"Jao et al. 2005"},{sysNum:72,appVisMag:8.99,absVisMag:10.12,type:61,lumNum:5,typeStr:"M1.0 V",mass:0.51,plx:0.16851,name:"GJ 908",altName:""},{sysNum:73,appVisMag:3.45,absVisMag:4.58,type:43,lumNum:5,typeStr:"G3   V",mass:1.11,plx:0.16838,name:"GJ 34 A",altName:"eta Cassiopei A"},{sysNum:73,appVisMag:7.51,absVisMag:8.64,type:57,lumNum:5,typeStr:"K7.0 V",mass:0.6,plx:0.16838,name:"GJ 34 B",altName:"eta Cassiopei B"},{sysNum:74,appVisMag:9.31,absVisMag:10.44,type:63,lumNum:5,typeStr:"M3.0 V",mass:0.46,plx:0.16836,name:"GJ 588",altName:""},{sysNum:75,appVisMag:11.58,absVisMag:12.93,type:64,lumNum:5,typeStr:"M4.0 V J",mass:0.18,plx:0.16806,name:"GJ 1005 A",altName:""},{sysNum:76,appVisMag:11.19,absVisMag:12.31,type:64,lumNum:5,typeStr:"M4.0 V",mass:0.23,plx:0.16754,name:"GJ 285",altName:"Ross 882"},{sysNum:77,appVisMag:5.07,absVisMag:6.19,type:51,lumNum:5,typeStr:"K1   Ve",mass:0.85,plx:0.16751,name:"GJ 663 A",altName:"36 Ophiuchi A"},{sysNum:77,appVisMag:5.08,absVisMag:6.2,type:51,lumNum:5,typeStr:"K1   Ve",mass:0.85,plx:0.16751,name:"GJ 663 B",altName:"36 Ophiuchi B"},{sysNum:77,appVisMag:6.33,absVisMag:7.45,type:55,lumNum:5,typeStr:"K5   Ve",mass:0.71,plx:0.16751,name:"GJ 664",altName:"36 Ophiuchi C"},{sysNum:78,appVisMag:5.32,absVisMag:6.41,type:53,lumNum:5,typeStr:"K3   V",mass:0.82,plx:0.16533,name:"GJ 783 A",altName:""},{sysNum:78,appVisMag:11.5,absVisMag:12.59,type:64,lumNum:5,typeStr:"M4.0 V",mass:0.2,plx:0.16533,name:"GJ 783 B",altName:""},{sysNum:79,appVisMag:4.26,absVisMag:5.35,type:45,lumNum:5,typeStr:"G5   V",mass:0.97,plx:0.16501,name:"GJ 139",altName:"82 Eridani"},{sysNum:81,appVisMag:3.56,absVisMag:4.63,type:48,lumNum:5,typeStr:"G8   V",mass:1.1,plx:0.16378,name:"GJ 780",altName:"delta Pavonis"},{sysNum:82,appVisMag:12.05,absVisMag:13.11,type:64.5,lumNum:5,typeStr:"M4.5 V J",mass:0.17,plx:0.16293,name:"GJ 268 A",altName:"QY Aurigae A"},{sysNum:82,appVisMag:12.45,absVisMag:13.51,type:66,lumNum:5,typeStr:"M6V",mass:0.16,plx:0.16293,name:"GJ 268 B",altName:"QY Aurigae B"},{sysNum:83,appVisMag:11.31,absVisMag:12.37,type:63.5,lumNum:5,typeStr:"M3.5 V",mass:0.22,plx:0.16286,name:"GJ 555",altName:"HN Librae"},{sysNum:85,appVisMag:7.62,absVisMag:8.67,type:60,lumNum:5,typeStr:"M0.0 V",mass:0.6,plx:0.16213,name:"GJ 338 A",altName:""},{sysNum:85,appVisMag:7.71,absVisMag:8.76,type:57,lumNum:5,typeStr:"K7.0 V",mass:0.6,plx:0.16213,name:"GJ 338 B",altName:""},{sysNum:86,appVisMag:7.96,absVisMag:9,type:60,lumNum:5,typeStr:"M0.0 V",mass:0.58,plx:0.16118,name:"GJ 784",altName:""},{sysNum:87,appVisMag:10.56,absVisMag:11.57,type:62.5,lumNum:5,typeStr:"M2.5 V",mass:0.3,plx:0.15929,name:"GJ 581",altName:"Wolf 562"},{sysNum:88,appVisMag:10.26,absVisMag:11.25,type:63.5,lumNum:5,typeStr:"M3.5 V",mass:0.34,plx:0.15772,name:"GJ 896 A",altName:"EQ Pegasi"},{sysNum:88,appVisMag:12.4,absVisMag:13.39,type:64.5,lumNum:5,typeStr:"M4.5 V",mass:0.16,plx:0.15772,name:"GJ 896 B",altName:""},{sysNum:89,appVisMag:16.1,absVisMag:17.07,type:66,lumNum:5,typeStr:"M6.0 V",mass:0.09,plx:0.15687,name:"LHS 2090",altName:"Henry et al. 2006"},{sysNum:90,appVisMag:12.75,absVisMag:13.73,type:64,lumNum:5,typeStr:"M4.0 V",mass:0.15,plx:0.15678,name:"LHS 337",altName:"Henry et al. 2006"},{sysNum:91,appVisMag:9.93,absVisMag:10.9,type:63,lumNum:5,typeStr:"M3.0 V J",mass:0.39,plx:0.15632,name:"GJ 661 A",altName:""},{sysNum:91,appVisMag:10.35,absVisMag:11.32,type:63,lumNum:5,typeStr:"M3",mass:0.33,plx:0.15632,name:"GJ 661 B",altName:""},{sysNum:92,appVisMag:17.05,absVisMag:18.02,type:67,lumNum:5,typeStr:"M7.0 V",mass:0.08,plx:0.1563,name:"LHS 3003",altName:""},{sysNum:93,appVisMag:14.79,absVisMag:15.76,type:65,lumNum:5,typeStr:"M5",mass:0.1,plx:0.156,name:"G 180-060",altName:""},{sysNum:95,appVisMag:9.72,absVisMag:10.67,type:62.5,lumNum:5,typeStr:"M2.5 V J",mass:0.43,plx:0.15497,name:"GJ 644 A",altName:"Wolf 630 A"},{sysNum:95,appVisMag:10.54,absVisMag:11.49,type:64,lumNum:5,typeStr:"M4",mass:0.31,plx:0.15497,name:"GJ 644 B",altName:"Wolf 630 B"},{sysNum:95,appVisMag:16.8,absVisMag:17.75,type:67,lumNum:5,typeStr:"M7.0 V",mass:0.08,plx:0.15497,name:"GJ 644 C",altName:"van Biesbroeck 8"},{sysNum:95,appVisMag:10.63,absVisMag:11.58,type:66.5,lumNum:5,typeStr:"M6.5",mass:0.3,plx:0.15497,name:"GJ 644 D",altName:"Wolf 630 C"},{sysNum:95,appVisMag:11.74,absVisMag:12.69,type:63.5,lumNum:5,typeStr:"M3.5 V",mass:0.19,plx:0.15497,name:"GJ 643",altName:"Wolf 629"},{sysNum:96,appVisMag:5.56,absVisMag:6.49,type:53,lumNum:5,typeStr:"K3   V",mass:0.81,plx:0.15341,name:"GJ 892",altName:""},{sysNum:97,appVisMag:12.74,absVisMag:13.66,type:64.5,lumNum:5,typeStr:"M4.5 V",mass:0.15,plx:0.15305,name:"GJ 1128",altName:"Jao et al. 2005"},{sysNum:98,appVisMag:13.8,absVisMag:14.72,type:65,lumNum:5,typeStr:"M5.0 V",mass:0.12,plx:0.1529,name:"GJ 1156",altName:"GL Virginis"},{sysNum:99,appVisMag:10.1,absVisMag:11.01,type:61.5,lumNum:5,typeStr:"M1.5 V",mass:0.37,plx:0.15179,name:"GJ 625",altName:""},{sysNum:100,appVisMag:10.02,absVisMag:10.9,type:62.5,lumNum:5,typeStr:"M2.5 V",mass:0.39,plx:0.15016,name:"GJ 408",altName:"Ross 104"}];
p.brightStarsList = [{HR:2326,appVisMag:-0.72,absVisMag:-5.65,plx:10.43,BV:0.15,type:30,lumNum:2,typeStr:"F0II"},{HR:5340,appVisMag:-0.04,absVisMag:-0.3,plx:88.85,BV:1.23,type:51.5,lumNum:3,typeStr:"K1.5IIIFe-0.5"},{HR:7001,appVisMag:0.03,absVisMag:0.58,plx:128.93,BV:0,type:20,lumNum:5,typeStr:"A0Va"},{HR:1708,appVisMag:0.08,absVisMag:-0.48,plx:77.29,BV:0.8,type:45,lumNum:3,typeStr:"G5IIIe+G0III"},{HR:1713,appVisMag:0.12,absVisMag:-6.78,plx:4.22,BV:-0.03,type:18,lumNum:1,typeStr:"B8Ia:"},{HR:472,appVisMag:0.46,absVisMag:-2.77,plx:22.68,BV:-0.16,type:13,lumNum:5,typeStr:"B3Vpe"},{HR:2061,appVisMag:0.5,absVisMag:-5.11,plx:7.63,BV:1.85,type:61.5,lumNum:1.05,typeStr:"M1-2Ia-Iab"},{HR:5267,appVisMag:0.61,absVisMag:-5.45,plx:6.21,BV:-0.23,type:11,lumNum:3,typeStr:"B1III"},{HR:1457,appVisMag:0.85,absVisMag:-0.66,plx:50.09,BV:1.54,type:55,lumNum:3,typeStr:"K5+III"},{HR:6134,appVisMag:0.96,absVisMag:-5.4,plx:5.4,BV:1.83,type:61.5,lumNum:1.05,typeStr:"M1.5Iab-Ib+B4Ve"},{HR:5056,appVisMag:0.98,absVisMag:-3.56,plx:12.44,BV:-0.23,type:11,lumNum:3.5,typeStr:"B1III-IV+B2V"},{HR:2990,appVisMag:1.14,absVisMag:1.07,plx:96.74,BV:1,type:50,lumNum:3,typeStr:"K0IIIb"},{HR:8728,appVisMag:1.16,absVisMag:1.73,plx:130.08,BV:0.09,type:23,lumNum:5,typeStr:"A3V"},{HR:7924,appVisMag:1.25,absVisMag:-8.77,plx:1.01,BV:0.09,type:22,lumNum:1,typeStr:"A2Ia"},{HR:4853,appVisMag:1.25,absVisMag:-3.94,plx:9.25,BV:-0.23,type:10.5,lumNum:3,typeStr:"B0.5III"},{HR:4730,appVisMag:1.33,absVisMag:-4.19,BV:-0.24,type:10.5,lumNum:4,typeStr:"B0.5IV"},{HR:3982,appVisMag:1.35,absVisMag:-0.54,plx:42.09,BV:-0.11,type:17,lumNum:5,typeStr:"B7V"},{HR:2618,appVisMag:1.5,absVisMag:-4.13,plx:7.57,BV:-0.21,type:12,lumNum:2,typeStr:"B2II"},{HR:6527,appVisMag:1.63,absVisMag:-5.06,plx:4.64,BV:-0.22,type:12,lumNum:4,typeStr:"B2IV+B"},{HR:4763,appVisMag:1.63,absVisMag:-0.53,plx:37.09,BV:1.59,type:63.5,lumNum:3,typeStr:"M3.5III"},{HR:1790,appVisMag:1.64,absVisMag:-2.74,plx:13.42,BV:-0.22,type:12,lumNum:3,typeStr:"B2III"},{HR:1791,appVisMag:1.65,absVisMag:-1.38,plx:24.89,BV:-0.13,type:17,lumNum:3,typeStr:"B7III"},{HR:3685,appVisMag:1.68,absVisMag:-0.99,plx:29.34,BV:0,type:22,lumNum:4,typeStr:"A2IV"},{HR:1903,appVisMag:1.7,absVisMag:-6.4,plx:2.43,BV:-0.19,type:10,lumNum:1,typeStr:"B0Ia"},{HR:4731,appVisMag:1.73,absVisMag:-3.79,BV:-0.26,type:11,lumNum:5,typeStr:"B1V"},{HR:8425,appVisMag:1.74,absVisMag:-0.73,plx:32.16,BV:-0.13,type:17,lumNum:4,typeStr:"B7IV"},{HR:4905,appVisMag:1.77,absVisMag:-0.21,plx:40.3,BV:-0.02,type:20,lumNum:5,typeStr:"A0pCr"},{HR:3207,appVisMag:1.78,absVisMag:-5.3,plx:3.88,BV:-0.22,type:9,lumNum:1.05,typeStr:"O9I"},{HR:1017,appVisMag:1.79,absVisMag:-4.53,plx:5.51,BV:0.48,type:35,lumNum:1.1,typeStr:"F5Ib"},{HR:4301,appVisMag:1.79,absVisMag:-1.12,plx:26.38,BV:1.07,type:50,lumNum:3,typeStr:"K0IIIa"},{HR:2693,appVisMag:1.84,absVisMag:-6.89,plx:1.82,BV:0.68,type:38,lumNum:1,typeStr:"F8Ia"},{HR:6879,appVisMag:1.85,absVisMag:-1.4,plx:22.55,BV:-0.03,type:19.5,lumNum:3,typeStr:"B9.5III"},{HR:5191,appVisMag:1.86,absVisMag:-0.6,plx:32.39,BV:-0.19,type:13,lumNum:5,typeStr:"B3V"},{HR:3307,appVisMag:1.86,absVisMag:-4.6,plx:5.16,BV:1.28,type:53,lumNum:3,typeStr:"K3III+B2:V"},{HR:6553,appVisMag:1.87,absVisMag:-2.75,plx:11.99,BV:0.4,type:31,lumNum:2,typeStr:"F1II"},{HR:2088,appVisMag:1.9,absVisMag:-0.11,plx:39.72,BV:0.03,type:22,lumNum:4,typeStr:"A2IV"},{HR:6217,appVisMag:1.92,absVisMag:-3.63,plx:7.85,BV:1.44,type:52,lumNum:2.5,typeStr:"K2IIb-IIIa"},{HR:2421,appVisMag:1.93,absVisMag:-0.61,plx:31.12,BV:0,type:20,lumNum:4,typeStr:"A0IV"},{HR:7790,appVisMag:1.94,absVisMag:-1.82,plx:17.8,BV:-0.2,type:12,lumNum:4,typeStr:"B2IV"},{HR:3485,appVisMag:1.96,absVisMag:0.01,plx:40.9,BV:0.04,type:21,lumNum:5,typeStr:"A1V"},{HR:2891,appVisMag:1.98,absVisMag:1.07,plx:66,BV:0.03,type:21,lumNum:5,typeStr:"A1V"},{HR:2294,appVisMag:1.98,absVisMag:-3.97,plx:6.53,BV:-0.23,type:11,lumNum:2.5,typeStr:"B1II-III"},{HR:3748,appVisMag:1.98,absVisMag:-1.71,plx:18.4,BV:1.44,type:53,lumNum:2.5,typeStr:"K3II-III"},{HR:617,appVisMag:2,absVisMag:0.47,plx:49.48,BV:1.15,type:52,lumNum:3,typeStr:"K2-IIICa-1"},{HR:7121,appVisMag:2.02,absVisMag:-2.18,plx:14.54,BV:-0.22,type:12.5,lumNum:5,typeStr:"B2.5V"},{HR:424,appVisMag:2.02,absVisMag:-3.61,plx:7.56,BV:0.6,type:37,lumNum:1.5,typeStr:"F7:Ib-II"},{HR:188,appVisMag:2.04,absVisMag:-0.31,plx:34.04,BV:1.02,type:49.5,lumNum:3,typeStr:"G9.5IIICH-1"},{HR:1948,appVisMag:2.05,absVisMag:-1.25,plx:22,BV:-0.21,type:9.7,lumNum:1.1,typeStr:"O9.7Ib"},{HR:2004,appVisMag:2.06,absVisMag:-4.69,plx:4.52,BV:-0.17,type:10.5,lumNum:1,typeStr:"B0.5Ia"},{HR:15,appVisMag:2.06,absVisMag:-0.32,plx:33.6,BV:-0.11,type:18,lumNum:4,typeStr:"B8IVpMnHg"},{HR:5288,appVisMag:2.06,absVisMag:0.7,plx:53.52,BV:1.01,type:50,lumNum:3,typeStr:"K0-IIIb"},{HR:337,appVisMag:2.06,absVisMag:-1.89,plx:16.36,BV:1.58,type:60,lumNum:3,typeStr:"M0+IIIa"},{HR:6556,appVisMag:2.08,absVisMag:1.3,plx:69.84,BV:0.15,type:25,lumNum:3,typeStr:"A5III"},{HR:5563,appVisMag:2.08,absVisMag:-0.87,plx:25.79,BV:1.47,type:54,lumNum:3,typeStr:"K4-III"},{HR:8636,appVisMag:2.1,absVisMag:-1.5,plx:19.17,BV:1.6,type:65,lumNum:3,typeStr:"M5III"},{HR:936,appVisMag:2.12,absVisMag:-0.16,plx:35.14,BV:-0.05,type:18,lumNum:5,typeStr:"B8V"},{HR:4534,appVisMag:2.14,absVisMag:1.91,plx:90.16,BV:0.09,type:23,lumNum:5,typeStr:"A3V"},{HR:4819,appVisMag:2.17,absVisMag:-0.85,plx:25.01,BV:-0.01,type:21,lumNum:4,typeStr:"A1IV"},{HR:7796,appVisMag:2.2,absVisMag:-6.18,plx:2.14,BV:0.68,type:38,lumNum:1.1,typeStr:"F8Ib"},{HR:3634,appVisMag:2.21,absVisMag:-4.04,plx:5.69,BV:1.66,type:54.5,lumNum:1.5,typeStr:"K4.5Ib-II"},{HR:5793,appVisMag:2.23,absVisMag:0.42,plx:43.65,BV:-0.02,type:20,lumNum:5,typeStr:"A0V+G5V"},{HR:168,appVisMag:2.23,absVisMag:-2.01,plx:14.27,BV:1.17,type:50,lumNum:3,typeStr:"K0IIIa"},{HR:6705,appVisMag:2.23,absVisMag:-1.06,plx:22.1,BV:1.52,type:55,lumNum:3,typeStr:"K5III"},{HR:1852,appVisMag:2.23,absVisMag:-5.04,plx:3.56,BV:-0.22,type:9.5,lumNum:2,typeStr:"O9.5II"},{HR:3699,appVisMag:2.25,absVisMag:-4.41,plx:4.71,BV:0.18,type:28,lumNum:1.1,typeStr:"A8Ib"},{HR:3165,appVisMag:2.25,absVisMag:-5.95,plx:2.33,BV:-0.26,type:5,lumNum:5,typeStr:"O5f"},{HR:603,appVisMag:2.26,absVisMag:-2.94,plx:9.19,BV:1.37,type:53,lumNum:2,typeStr:"K3-IIb"},{HR:5054,appVisMag:2.27,absVisMag:0.36,plx:41.73,BV:0.02,type:21,lumNum:5,typeStr:"A1VpSrSi"},{HR:21,appVisMag:2.27,absVisMag:1.15,plx:59.89,BV:0.34,type:32,lumNum:3.5,typeStr:"F2III-IV"},{HR:6241,appVisMag:2.29,absVisMag:0.77,plx:49.85,BV:1.15,type:52.5,lumNum:3,typeStr:"K2.5III"},{HR:5469,appVisMag:2.3,absVisMag:-3.85,plx:5.95,BV:-0.2,type:11.5,lumNum:3,typeStr:"B1.5III/Vn"},{HR:5132,appVisMag:2.3,absVisMag:-3.03,plx:8.68,BV:-0.22,type:11,lumNum:3,typeStr:"B1III"},{HR:5440,appVisMag:2.31,absVisMag:-2.59,plx:10.57,BV:-0.19,type:11.5,lumNum:5,typeStr:"B1.5Vne"},{HR:5953,appVisMag:2.32,absVisMag:-3.15,plx:8.12,BV:-0.12,type:10.3,lumNum:4,typeStr:"B0.3IV"},{HR:4295,appVisMag:2.37,absVisMag:0.43,plx:41.07,BV:-0.02,type:21,lumNum:5,typeStr:"A1V"},{HR:99,appVisMag:2.39,absVisMag:0.51,plx:42.14,BV:1.09,type:50,lumNum:3,typeStr:"K0III"},{HR:8308,appVisMag:2.39,absVisMag:-4.21,plx:4.85,BV:1.53,type:52,lumNum:1.1,typeStr:"K2Ib"},{HR:6580,appVisMag:2.41,absVisMag:-3.38,plx:7.03,BV:-0.22,type:11.5,lumNum:3,typeStr:"B1.5III"},{HR:8775,appVisMag:2.42,absVisMag:-1.53,plx:16.37,BV:1.67,type:62.5,lumNum:2.5,typeStr:"M2.5II-III"},{HR:6378,appVisMag:2.43,absVisMag:0.36,plx:38.77,BV:0.06,type:22,lumNum:5,typeStr:"A2V"},{HR:4554,appVisMag:2.44,absVisMag:0.39,plx:38.99,BV:0,type:20,lumNum:5,typeStr:"A0Ve"},{HR:8162,appVisMag:2.44,absVisMag:1.56,plx:66.84,BV:0.22,type:27,lumNum:5,typeStr:"A7V"},{HR:2827,appVisMag:2.45,absVisMag:-7.55,plx:1.02,BV:-0.08,type:15,lumNum:1,typeStr:"B5Ia"},{HR:7949,appVisMag:2.46,absVisMag:0.73,plx:45.26,BV:1.03,type:50,lumNum:3,typeStr:"K0-III"},{HR:264,appVisMag:2.47,absVisMag:-3.93,plx:5.32,BV:-0.15,type:10,lumNum:4,typeStr:"B0IVe"},{HR:8781,appVisMag:2.49,absVisMag:-0.68,plx:23.36,BV:-0.04,type:19,lumNum:5,typeStr:"B9V"},{HR:3734,appVisMag:2.5,absVisMag:-3.62,plx:6.05,BV:-0.18,type:12,lumNum:4.5,typeStr:"B2IV-V"},{HR:911,appVisMag:2.53,absVisMag:-1.63,plx:14.82,BV:1.64,type:61.5,lumNum:3,typeStr:"M1.5IIIa"},{HR:5231,appVisMag:2.55,absVisMag:-2.83,plx:8.48,BV:-0.22,type:12.5,lumNum:4,typeStr:"B2.5IV"},{HR:4357,appVisMag:2.56,absVisMag:1.32,plx:56.52,BV:0.12,type:24,lumNum:5,typeStr:"A4V"},{HR:6175,appVisMag:2.56,absVisMag:-3.2,plx:7.12,BV:0.02,type:9.5,lumNum:5,typeStr:"O9.5Vn"},{HR:1865,appVisMag:2.58,absVisMag:-5.43,plx:2.54,BV:0.21,type:30,lumNum:1.1,typeStr:"F0Ib"},{HR:4662,appVisMag:2.59,absVisMag:-0.94,plx:19.78,BV:-0.11,type:18,lumNum:3,typeStr:"B8IIIpHgMn"},{HR:7194,appVisMag:2.6,absVisMag:0.41,plx:36.61,BV:0.08,type:22,lumNum:3,typeStr:"A2III+A4IV"},{HR:4621,appVisMag:2.6,absVisMag:-2.84,plx:8.25,BV:-0.12,type:12,lumNum:4,typeStr:"B2IVne"},{HR:5685,appVisMag:2.61,absVisMag:-0.86,plx:20.38,BV:-0.11,type:18,lumNum:5,typeStr:"B8V"},{HR:4057,appVisMag:2.61,absVisMag:-0.33,plx:25.96,BV:1.15,type:51,lumNum:3,typeStr:"K1-IIIbFe-0.5"},{HR:2095,appVisMag:2.62,absVisMag:-1.02,plx:18.83,BV:-0.08,type:20,lumNum:5,typeStr:"A0pSi"},{HR:5984,appVisMag:2.62,absVisMag:-3.46,plx:6.15,BV:-0.07,type:11,lumNum:5,typeStr:"B1V"},{HR:553,appVisMag:2.64,absVisMag:1.33,plx:54.74,BV:0.13,type:25,lumNum:5,typeStr:"A5V"},{HR:1956,appVisMag:2.64,absVisMag:-1.95,plx:12.16,BV:-0.12,type:17,lumNum:4,typeStr:"B7IVe"},{HR:4786,appVisMag:2.65,absVisMag:-0.52,plx:23.34,BV:0.89,type:45,lumNum:2,typeStr:"G5II"},{HR:5854,appVisMag:2.65,absVisMag:0.89,plx:44.54,BV:1.17,type:52,lumNum:3,typeStr:"K2IIIbCN1"},{HR:403,appVisMag:2.68,absVisMag:0.25,plx:32.81,BV:0.13,type:25,lumNum:3.5,typeStr:"A5III-IV"},{HR:5571,appVisMag:2.68,absVisMag:-3.37,plx:6.23,BV:-0.22,type:12,lumNum:3.5,typeStr:"B2III/IV"},{HR:5235,appVisMag:2.68,absVisMag:2.41,plx:88.17,BV:0.58,type:40,lumNum:4,typeStr:"G0IV"},{HR:6508,appVisMag:2.69,absVisMag:-3.34,plx:6.29,BV:-0.22,type:12,lumNum:4,typeStr:"B2IV"},{HR:4798,appVisMag:2.69,absVisMag:-2.19,plx:10.67,BV:-0.2,type:12,lumNum:4.5,typeStr:"B2IV-V"},{HR:4216,appVisMag:2.69,absVisMag:-0.07,plx:28.18,BV:0.9,type:45,lumNum:3,typeStr:"G5III+G2V"},{HR:1577,appVisMag:2.69,absVisMag:-3.31,plx:6.37,BV:1.53,type:53,lumNum:2,typeStr:"K3II"},{HR:5506,appVisMag:2.7,absVisMag:-1.75,plx:13,BV:0.97,type:50,lumNum:2.5,typeStr:"K0-II-III"},{HR:2773,appVisMag:2.7,absVisMag:-4.96,plx:2.98,BV:1.62,type:53,lumNum:1.1,typeStr:"K3Ib"},{HR:6859,appVisMag:2.7,absVisMag:-2.18,plx:10.67,BV:1.38,type:53,lumNum:3,typeStr:"K3-IIIa*"},{HR:7525,appVisMag:2.72,absVisMag:-3.05,plx:7.08,BV:1.52,type:53,lumNum:2,typeStr:"K3II"},{HR:6132,appVisMag:2.74,absVisMag:0.58,plx:37.18,BV:0.91,type:48,lumNum:3,typeStr:"G8-IIIab"},{HR:6056,appVisMag:2.74,absVisMag:-0.86,plx:19.16,BV:1.58,type:60.5,lumNum:3,typeStr:"M0.5III"},{HR:5028,appVisMag:2.75,absVisMag:1.47,plx:55.64,BV:0.04,type:22,lumNum:5,typeStr:"A2V"},{HR:5531,appVisMag:2.75,absVisMag:0.87,plx:42.25,BV:0.15,type:23,lumNum:4,typeStr:"A3IV"},{HR:4199,appVisMag:2.76,absVisMag:-2.91,plx:7.43,BV:-0.22,type:10,lumNum:5,typeStr:"B0Vp"},{HR:6148,appVisMag:2.77,absVisMag:-0.52,plx:22.07,BV:0.94,type:47,lumNum:3,typeStr:"G7IIIa"},{HR:6603,appVisMag:2.77,absVisMag:0.76,plx:39.78,BV:1.16,type:52,lumNum:3,typeStr:"K2III"},{HR:1899,appVisMag:2.77,absVisMag:-5.31,plx:2.46,BV:-0.24,type:9,lumNum:3,typeStr:"O9III"},{HR:5776,appVisMag:2.78,absVisMag:-3.45,plx:5.75,BV:-0.2,type:12,lumNum:4,typeStr:"B2IV"},{HR:1666,appVisMag:2.79,absVisMag:0.61,plx:36.71,BV:0.13,type:23,lumNum:3,typeStr:"A3III"},{HR:6536,appVisMag:2.79,absVisMag:-2.45,plx:9.02,BV:0.98,type:42,lumNum:1.5,typeStr:"G2Ib-IIa"},{HR:4656,appVisMag:2.8,absVisMag:-2.46,plx:8.96,BV:-0.23,type:12,lumNum:4,typeStr:"B2IV"},{HR:98,appVisMag:2.8,absVisMag:3.43,plx:133.78,BV:0.62,type:42,lumNum:4,typeStr:"G2IV"},{HR:3185,appVisMag:2.81,absVisMag:1.38,plx:51.99,BV:0.43,type:36,lumNum:2,typeStr:"F6IIpDel Del"},{HR:6212,appVisMag:2.81,absVisMag:2.64,plx:92.64,BV:0.65,type:40,lumNum:4,typeStr:"G0IV"},{HR:6913,appVisMag:2.81,absVisMag:0.93,plx:42.2,BV:1.04,type:51,lumNum:3,typeStr:"K1+IIIb"},{HR:6165,appVisMag:2.82,absVisMag:-2.8,plx:7.59,BV:-0.25,type:10,lumNum:5,typeStr:"B0V"},{HR:39,appVisMag:2.83,absVisMag:-2.24,plx:9.79,BV:-0.23,type:12,lumNum:4,typeStr:"B2IV"},{HR:4932,appVisMag:2.83,absVisMag:0.34,plx:31.9,BV:0.94,type:48,lumNum:3,typeStr:"G8IIIab"},{HR:1829,appVisMag:2.84,absVisMag:-0.62,plx:20.49,BV:0.82,type:45,lumNum:2,typeStr:"G5II"},{HR:1203,appVisMag:2.85,absVisMag:-4.57,plx:3.32,BV:0.12,type:11,lumNum:1.1,typeStr:"B1Ib"},{HR:5897,appVisMag:2.85,absVisMag:2.4,plx:81.24,BV:0.29,type:32,lumNum:3,typeStr:"F2III"},{HR:6461,appVisMag:2.85,absVisMag:-3.51,plx:5.41,BV:1.46,type:53,lumNum:1.5,typeStr:"K3Ib-IIa"},{HR:591,appVisMag:2.86,absVisMag:1.15,plx:45.74,BV:0.28,type:30,lumNum:5,typeStr:"F0V"},{HR:8502,appVisMag:2.86,absVisMag:-1.08,plx:16.42,BV:1.39,type:53,lumNum:3,typeStr:"K3III"},{HR:8322,appVisMag:2.87,absVisMag:2.5,plx:84.58,BV:0.29,type:27,lumNum:3,typeStr:"A7III"},{HR:1165,appVisMag:2.87,absVisMag:-2.41,plx:8.87,BV:-0.09,type:17,lumNum:3,typeStr:"B7IIIe"},{HR:7528,appVisMag:2.87,absVisMag:-0.74,plx:19.07,BV:-0.03,type:19.5,lumNum:4,typeStr:"B9.5IV+F1V"},{HR:2890,appVisMag:2.88,absVisMag:1.97,plx:66,BV:0.04,type:22,lumNum:5,typeStr:"A2Vm"},{HR:2286,appVisMag:2.88,absVisMag:-1.4,plx:14.07,BV:1.64,type:63,lumNum:3,typeStr:"M3IIIab"}];
