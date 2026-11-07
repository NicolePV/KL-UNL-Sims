function FlatMapComponent007ClassModified()
{
   var _loc1_ = this;
   _loc1_.mapHeight = _loc1_._height == 0 ? _loc1_.defaultMapHeight : _loc1_._height;
   _loc1_._xscale = 100;
   _loc1_._yscale = 100;
   _loc1_.placeholderMC._visible = false;
   _loc1_.placeholderMC.swapDepths(987789);
   _loc1_.placeholderMC.removeMovieClip();
   _loc1_.initialize();
}
var p = FlatMapComponent007ClassModified.prototype = new MovieClip();
Object.registerClass("Flat Map Component 007 modified",FlatMapComponent007ClassModified);
p.getPositionFromScreenPoint = function(pt)
{
   var _loc1_ = {};
   _loc1_.lon = pt.x * (360 / this.mapWidth) - 180;
   _loc1_.lat = 90 - pt.y * (360 / this.mapWidth);
   if(_loc1_.lat > 90)
   {
      _loc1_.lat = 90;
   }
   else if(_loc1_.lat < -90)
   {
      _loc1_.lat = -90;
   }
   return _loc1_;
};
p.initOffset = 180;
p.initAllowDragging = false;
p.initShowIDL = false;
p.initShowLatitudeGrid = false;
p.initShowLongitudeGrid = false;
p.initShowBorderLabels = true;
p.initShowDayAndNightRegions = false;
p.initSunDeclination = 10;
p.initSunLongitude = 0;
p.terminatorThickness = 1;
p.terminatorColor = 9474192;
p.terminatorAlpha = 100;
p.nightSideFillColor = 0;
p.nightSideFillAlpha = 16;
p.daySideFillColor = 16777215;
p.daySideFillAlpha = 0;
p.numberOfLatitudeDivisions = 6;
p.numberOfLongitudeDivisions = 8;
p.borderWidth = 6;
p.borderLightColor = 16777215;
p.borderDarkColor = 0;
p.borderLabelMargin = 5;
p.useKiribatiIDL = true;
p.IDLLineThickness = 1;
p.IDLLineColor = 16711680;
p.IDLLineAlpha = 100;
p.gridThickness = 1;
p.gridColor = 9474192;
p.gridAlpha = 100;
p.defaultLineThickness = 1;
p.defaultLineColor = 255;
p.defaultLineAlpha = 100;
p.fontLinkageName = "FMC Embedded Font Rev 1";
p.mapLinkageName = "FMC Map Rev 1 modified";
p.defaultMapHeight = 225;
p.removeAllLines = function()
{
   this.maskedAreaMC.createEmptyMovieClip("linesMC",12);
};
p.addLine = function(definition)
{
   var _loc2_ = this;
   var thickness = definition.thickness == undefined ? _loc2_.defaultLineThickness : definition.thickness;
   var color = definition.color == undefined ? _loc2_.defaultLineColor : definition.color;
   var alpha = definition.alpha == undefined ? _loc2_.defaultLineAlpha : definition.alpha;
   var mc = _loc2_.maskedAreaMC.linesMC;
   mc.clear();
   mc.lineStyle(thickness,color,alpha);
   if(definition.lat != undefined)
   {
      var y = (90 - definition.lat) * (_loc2_.mapWidth / 360);
      mc.moveTo(0,y);
      mc.lineTo(2 * _loc2_.mapWidth,y);
   }
   var _loc3_;
   var _loc1_;
   if(definition.lon != undefined)
   {
      _loc3_ = _loc2_.mapWidth * (((definition.lon + 180) / 360 % 1 + 1) % 1) - _loc2_.mapWidth;
      _loc1_ = 0;
      while(_loc1_ < 4)
      {
         mc.moveTo(_loc3_,0);
         mc.lineTo(_loc3_,_loc2_.mapHeight);
         _loc3_ += _loc2_.mapWidth;
         _loc1_ = _loc1_ + 1;
      }
   }
};
p.removeObject = function(name)
{
   var _loc2_ = this;
   var _loc3_ = name;
   var _loc1_ = 0;
   while(_loc1_ < _loc2_.objectsList.length)
   {
      if(_loc2_.objectsList[_loc1_].name == _loc3_)
      {
         _loc2_.objectsList[_loc1_].mc.removeMovieClip();
         _loc2_.objectsList.splice(_loc1_,1);
         break;
      }
      _loc1_ = _loc1_ + 1;
   }
};
p.addObject = function(linkageName, name, position, initObj)
{
   var _loc1_ = this;
   var _loc3_ = initObj;
   var _loc2_ = _loc1_.objectsFreeDepth;
   _loc1_.objectsFreeDepth = _loc1_.objectsFreeDepth + 1;
   var mc = _loc1_.maskedAreaMC.objectsMC.createEmptyMovieClip("_" + _loc2_ + "MC",_loc2_);
   mc.attachMovie(linkageName,"_1MC",1,_loc3_);
   mc.attachMovie(linkageName,"_2MC",2,_loc3_);
   mc.attachMovie(linkageName,"_3MC",3,_loc3_);
   mc.attachMovie(linkageName,"_4MC",4,_loc3_);
   _loc1_.objectsList.push({name:name,mc:mc});
   _loc1_.setObjectPosition(name,position);
};
p.passDataToObject = function(name, dataObj)
{
   var _loc2_ = this;
   var _loc3_ = dataObj;
   var _loc1_ = 0;
   while(_loc1_ < _loc2_.objectsList.length)
   {
      if(_loc2_.objectsList[_loc1_].name == name)
      {
         _loc2_.objectsList[_loc1_].mc._1MC.receiveData(_loc3_);
         _loc2_.objectsList[_loc1_].mc._2MC.receiveData(_loc3_);
         _loc2_.objectsList[_loc1_].mc._3MC.receiveData(_loc3_);
         _loc2_.objectsList[_loc1_].mc._4MC.receiveData(_loc3_);
         break;
      }
      _loc1_ = _loc1_ + 1;
   }
};
p.setObjectPosition = function(name, position)
{
   var _loc3_ = this;
   var i = 0;
   var _loc1_;
   var _loc2_;
   while(i < _loc3_.objectsList.length)
   {
      if(_loc3_.objectsList[i].name == name)
      {
         _loc1_ = _loc3_.objectsList[i].mc;
         _loc2_ = _loc3_.getScreenPointFromPosition(position);
         _loc1_._1MC._x = _loc2_.x - _loc3_.mapWidth;
         _loc1_._2MC._x = _loc2_.x;
         _loc1_._3MC._x = _loc2_.x + _loc3_.mapWidth;
         _loc1_._4MC._x = _loc2_.x + 2 * _loc3_.mapWidth;
         _loc1_._1MC._y = _loc2_.y;
         _loc1_._2MC._y = _loc2_.y;
         _loc1_._3MC._y = _loc2_.y;
         _loc1_._4MC._y = _loc2_.y;
         break;
      }
      i++;
   }
};
p.removeAllObjects = function()
{
   var _loc1_ = this;
   _loc1_.objectsList = [];
   _loc1_.objectsFreeDepth = 1;
   _loc1_.maskedAreaMC.createEmptyMovieClip("objectsMC",15);
};
p.getScreenPointFromPosition = function(position)
{
   var _loc1_ = {};
   _loc1_.x = this.mapWidth * (((position.lon + 180) / 360 % 1 + 1) % 1);
   _loc1_.y = (90 - position.lat) * (this.mapWidth / 360);
   return _loc1_;
};
p.initialize = function()
{
   var _loc1_ = this;
   _loc1_.createEmptyMovieClip("maskMC",1);
   _loc1_.createEmptyMovieClip("maskedAreaMC",2);
   _loc1_.maskedAreaMC.setMask(_loc1_.maskMC);
   _loc1_.attachMovie(_loc1_.fontLinkageName,"fontsMC",424242,{_visible:false});
   _loc1_.borderLabelsTextFormat = _loc1_.fontsMC.borderLabelsField.getTextFormat();
   _loc1_.maskedAreaMC.attachMovie(_loc1_.mapLinkageName,"mapMC",1);
   _loc1_.maskedAreaMC.createEmptyMovieClip("longitudeGridMC",5);
   _loc1_.maskedAreaMC.createEmptyMovieClip("latitudeGridMC",6);
   _loc1_.maskedAreaMC.createEmptyMovieClip("IDLMC",10);
   _loc1_.mapWidth = 2 * _loc1_.mapHeight;
   _loc1_.maskedAreaMC.mapMC._xscale = _loc1_.maskedAreaMC.mapMC._yscale = 100 * (_loc1_.mapHeight / _loc1_.maskedAreaMC.mapMC._height);
   _loc1_.maskMC.moveTo(0,0);
   _loc1_.maskMC.beginFill(16711680);
   _loc1_.maskMC.lineTo(_loc1_.mapWidth,0);
   _loc1_.maskMC.lineTo(_loc1_.mapWidth,_loc1_.mapHeight);
   _loc1_.maskMC.lineTo(0,_loc1_.mapHeight);
   _loc1_.maskMC.lineTo(0,0);
   _loc1_.maskMC.endFill();
   var _loc3_ = 0;
   var _loc2_;
   while(_loc3_ < _loc1_.IDLList_withKiribati.length)
   {
      _loc2_ = _loc1_.IDLList_withKiribati[_loc3_];
      _loc2_.x = _loc1_.mapWidth * (((_loc2_.lon + 180) / 360 % 1 + 1) % 1);
      _loc2_.y = (90 - _loc2_.lat) * (_loc1_.mapWidth / 360);
      _loc3_ = _loc3_ + 1;
   }
   _loc3_ = 0;
   while(_loc3_ < _loc1_.IDLList_withoutKiribati.length)
   {
      _loc2_ = _loc1_.IDLList_withoutKiribati[_loc3_];
      _loc2_.x = _loc1_.mapWidth * (((_loc2_.lon + 180) / 360 % 1 + 1) % 1);
      _loc2_.y = (90 - _loc2_.lat) * (_loc1_.mapWidth / 360);
      _loc3_ = _loc3_ + 1;
   }
   _loc1_.removeAllLines();
   _loc1_.removeAllObjects();
   _loc1_.updateBorder();
   _loc1_.updateIDL();
   _loc1_.updateLatitudeGrid();
   _loc1_.updateLongitudeGrid();
   _loc1_.setLongitudeOffset(_loc1_.initOffset);
   _loc1_.setAllowDragging(_loc1_.initAllowDragging);
   _loc1_.setShowBorderLabels(_loc1_.initShowBorderLabels);
   _loc1_.setShowIDL(_loc1_.initShowIDL);
   _loc1_.setShowLongitudeGrid(_loc1_.initShowLongitudeGrid);
   _loc1_.setShowLatitudeGrid(_loc1_.initShowLatitudeGrid);
   _loc1_.setShowDayAndNightRegions(_loc1_.initShowDayAndNightRegions);
   _loc1_.setSunLongitude(_loc1_.initSunLongitude);
   _loc1_.setSunDeclination(_loc1_.initSunDeclination);
};
p.updateGrid = function()
{
   this.updateLatitudeGrid();
   this.updateLongitudeGrid();
};
p.updateLatitudeGrid = function()
{
   var _loc3_ = this.maskedAreaMC.latitudeGridMC;
   _loc3_.clear();
   _loc3_.lineStyle(this.gridThickness,this.gridColor,this.gridAlpha);
   var x1 = 0;
   var x2 = 2 * this.mapWidth;
   var yStep = this.mapHeight / this.numberOfLatitudeDivisions;
   var _loc2_ = yStep;
   var _loc1_ = 1;
   while(_loc1_ < this.numberOfLatitudeDivisions)
   {
      _loc3_.moveTo(x1,_loc2_);
      _loc3_.lineTo(x2,_loc2_);
      _loc2_ += yStep;
      _loc1_ = _loc1_ + 1;
   }
};
p.updateLongitudeGrid = function()
{
   var _loc3_ = this.maskedAreaMC.longitudeGridMC;
   _loc3_.clear();
   _loc3_.lineStyle(this.gridThickness,this.gridColor,this.gridAlpha);
   var y1 = 0;
   var y2 = this.mapHeight;
   var xStep = this.mapWidth / this.numberOfLongitudeDivisions;
   var _loc2_ = 0;
   var _loc1_ = 0;
   while(_loc1_ <= 2 * this.numberOfLongitudeDivisions)
   {
      _loc3_.moveTo(_loc2_,y1);
      _loc3_.lineTo(_loc2_,y2);
      _loc2_ += xStep;
      _loc1_ = _loc1_ + 1;
   }
};
p.getShowLongitudeGrid = function()
{
   return this.maskedAreaMC.longitudeGridMC._visible;
};
p.setShowLongitudeGrid = function(arg)
{
   this.maskedAreaMC.longitudeGridMC._visible = arg;
};
p.addProperty("showLongitudeGrid",p.getShowLongitudeGrid,p.setShowLongitudeGrid);
p.getShowLatitudeGrid = function()
{
   return this.maskedAreaMC.latitudeGridMC._visible;
};
p.setShowLatitudeGrid = function(arg)
{
   this.maskedAreaMC.latitudeGridMC._visible = arg;
};
p.addProperty("showLatitudeGrid",p.getShowLatitudeGrid,p.setShowLatitudeGrid);
p.getShowIDL = function()
{
   return this.maskedAreaMC.IDLMC._visible;
};
p.setShowIDL = function(arg)
{
   this.maskedAreaMC.IDLMC._visible = arg;
};
p.addProperty("showIDL",p.getShowIDL,p.setShowIDL);
p.getShowBorderLabels = function()
{
   return this.longitudeLabelsMC != undefined;
};
p.setShowBorderLabels = function(arg)
{
   var _loc1_ = this;
   if(arg)
   {
      _loc1_.attachBorderLabels();
      _loc1_.updateBorderLabels();
   }
   else
   {
      _loc1_.removeBorderLabels();
   }
};
p.addProperty("showBorderLabels",p.getShowBorderLabels,p.setShowBorderLabels);
p.updateBorderAndLabels = function()
{
   var _loc1_ = this;
   _loc1_.updateBorder();
   if(_loc1_.showBorderLabels)
   {
      _loc1_.attachBorderLabels();
      _loc1_.updateBorderLabels();
   }
};
p.updateBorderLabels = function()
{
   var _loc2_ = this;
   var _loc3_;
   var _loc1_;
   if(_loc2_.latitudeLabelsMC != undefined)
   {
      _loc3_ = _loc2_._offset != 0 ? _loc2_.mapWidth * (1 - _loc2_._offset / 360) : 0;
      var xStep = _loc2_.mapWidth / _loc2_.numberOfLongitudeDivisions;
      _loc1_ = 0;
      while(_loc1_ < _loc2_.numberOfLongitudeDivisions)
      {
         var topField = _loc2_.longitudeLabelsMC["top" + _loc1_];
         var bottomField = _loc2_.longitudeLabelsMC["bottom" + _loc1_];
         _loc2_.longitudeLabelsMC["bottom" + _loc1_]._x = _loc2_.longitudeLabelsMC["top" + _loc1_]._x = _loc3_ - _loc2_.longitudeLabelsMC["top" + _loc1_]._width / 2;
         _loc3_ = (_loc3_ + xStep) % _loc2_.mapWidth;
         _loc1_ = _loc1_ + 1;
      }
   }
};
p.attachBorderLabels = function()
{
   var _loc1_ = this;
   _loc1_.createEmptyMovieClip("longitudeLabelsMC",200);
   _loc1_.createEmptyMovieClip("latitudeLabelsMC",201);
   var textHeight = _loc1_.fontsMC.borderLabelsField._height;
   _loc1_.borderLabelsTextFormat.color = _loc1_.borderDarkColor;
   var topY = - _loc1_.borderWidth - _loc1_.borderLabelMargin - textHeight;
   var bottomY = _loc1_.mapHeight + _loc1_.borderWidth + _loc1_.borderLabelMargin;
   var lonStep = 360 / _loc1_.numberOfLongitudeDivisions;
   var _loc2_ = 0;
   var _loc3_;
   while(_loc2_ < _loc1_.numberOfLongitudeDivisions)
   {
      _loc1_.longitudeLabelsMC.createTextField("top" + _loc2_,_loc2_,0,topY,0,0);
      _loc1_.longitudeLabelsMC.createTextField("bottom" + _loc2_,1000 + _loc2_,0,bottomY,0,0);
      _loc3_ = _loc1_.longitudeLabelsMC["top" + _loc2_];
      var bottomField = _loc1_.longitudeLabelsMC["bottom" + _loc2_];
      var lon = Math.round(_loc2_ * lonStep);
      if(lon == 0)
      {
         var lonStr = "0°";
      }
      else if(lon == 180)
      {
         var lonStr = "180°";
      }
      else if(lon < 180)
      {
         var lonStr = lon + "° E";
      }
      else
      {
         var lonStr = 360 - lon + "° W";
      }
      _loc3_.setNewTextFormat(_loc1_.borderLabelsTextFormat);
      _loc3_.autoSize = "left";
      _loc3_.embedFonts = true;
      _loc3_.selectable = false;
      _loc3_.text = lonStr;
      bottomField.setNewTextFormat(_loc1_.borderLabelsTextFormat);
      bottomField.autoSize = "left";
      bottomField.embedFonts = true;
      bottomField.selectable = false;
      bottomField.text = lonStr;
      _loc2_ = _loc2_ + 1;
   }
   var leftX = - _loc1_.borderWidth - _loc1_.borderLabelMargin;
   var rightX = _loc1_.mapWidth + _loc1_.borderWidth + _loc1_.borderLabelMargin;
   var y = (- textHeight) / 2;
   var yStep = _loc1_.mapHeight / _loc1_.numberOfLatitudeDivisions;
   var latStep = 180 / _loc1_.numberOfLatitudeDivisions;
   _loc2_ = 0;
   while(_loc2_ <= _loc1_.numberOfLatitudeDivisions)
   {
      _loc1_.latitudeLabelsMC.createTextField("left" + _loc2_,_loc2_,leftX,y,0,0);
      _loc1_.latitudeLabelsMC.createTextField("right" + _loc2_,1000 + _loc2_,rightX,y,0,0);
      y += yStep;
      var lat = Math.round(90 - _loc2_ * latStep);
      if(lat > 0)
      {
         var latStr = lat + "° N";
      }
      else if(lat < 0)
      {
         var latStr = - lat + "° S";
      }
      else
      {
         var latStr = "0°";
      }
      var leftField = _loc1_.latitudeLabelsMC["left" + _loc2_];
      var rightField = _loc1_.latitudeLabelsMC["right" + _loc2_];
      leftField.setNewTextFormat(_loc1_.borderLabelsTextFormat);
      leftField.autoSize = "right";
      leftField.embedFonts = true;
      leftField.selectable = false;
      leftField.text = latStr;
      rightField.setNewTextFormat(_loc1_.borderLabelsTextFormat);
      rightField.autoSize = "left";
      rightField.embedFonts = true;
      rightField.selectable = false;
      rightField.text = latStr;
      _loc2_ = _loc2_ + 1;
   }
};
p.removeBorderLabels = function()
{
   this.longitudeLabelsMC.removeMovieClip();
   this.latitudeLabelsMC.removeMovieClip();
};
p.updateBorder = function()
{
   var _loc2_ = this.createEmptyMovieClip("horizontalBorderMC",100);
   var hbmMC = this.createEmptyMovieClip("horizontalBorderMaskMC",101);
   var _loc1_ = this.createEmptyMovieClip("borderMC",102);
   _loc2_.setMask(hbmMC);
   var b = this.borderWidth;
   var vd = this.mapHeight / this.numberOfLatitudeDivisions;
   var hd = this.mapWidth / this.numberOfLongitudeDivisions;
   var y1 = - b;
   var y2 = 0;
   var y3 = this.mapHeight;
   var y4 = this.mapHeight + b;
   var x1 = - b;
   var x2 = 0;
   var x3 = this.mapWidth;
   var x4 = this.mapWidth + b;
   hbmMC.beginFill(16711680);
   hbmMC.moveTo(x2,y1 - 5);
   hbmMC.lineTo(x3,y1 - 5);
   hbmMC.lineTo(x3,y4 + 5);
   hbmMC.lineTo(x2,y4 + 5);
   hbmMC.lineTo(x2,y1 - 5);
   hbmMC.endFill();
   _loc1_.lineStyle(1,this.borderDarkColor);
   _loc1_.moveTo(x1,y1);
   _loc1_.beginFill(this.borderLightColor);
   _loc1_.lineTo(x2,y1);
   _loc1_.lineTo(x2,y4);
   _loc1_.lineTo(x1,y4);
   _loc1_.lineTo(x1,y1);
   _loc1_.endFill();
   _loc1_.lineStyle(1,this.borderDarkColor);
   _loc1_.moveTo(x3,y1);
   _loc1_.beginFill(this.borderLightColor);
   _loc1_.lineTo(x4,y1);
   _loc1_.lineTo(x4,y4);
   _loc1_.lineTo(x3,y4);
   _loc1_.lineTo(x3,y1);
   _loc1_.endFill();
   _loc1_.lineStyle(1,this.borderDarkColor);
   _loc1_.moveTo(x1,y2);
   _loc1_.lineTo(x2,y2);
   _loc1_.moveTo(x3,y2);
   _loc1_.lineTo(x4,y2);
   _loc1_.moveTo(x1,y3);
   _loc1_.lineTo(x2,y3);
   _loc1_.moveTo(x3,y3);
   _loc1_.lineTo(x4,y3);
   _loc1_.lineStyle(1,this.borderDarkColor);
   _loc1_.moveTo(x2,y1);
   _loc1_.lineTo(x3,y1);
   _loc1_.moveTo(x2,y2);
   _loc1_.lineTo(x3,y2);
   _loc1_.moveTo(x2,y3);
   _loc1_.lineTo(x3,y3);
   _loc1_.moveTo(x2,y4);
   _loc1_.lineTo(x3,y4);
   _loc1_.lineStyle(1,this.borderDarkColor);
   _loc1_.moveTo(x2,y1);
   _loc1_.lineTo(x3,y1);
   _loc1_.moveTo(x2,y2);
   _loc1_.lineTo(x3,y2);
   _loc1_.moveTo(x2,y3);
   _loc1_.lineTo(x3,y3);
   _loc1_.moveTo(x2,y4);
   _loc1_.lineTo(x3,y4);
   _loc2_.lineStyle();
   _loc2_.moveTo(x2,y1);
   _loc2_.beginFill(this.borderLightColor);
   _loc2_.lineTo(2 * x3,y1);
   _loc2_.lineTo(2 * x3,y2);
   _loc2_.lineTo(x2,y2);
   _loc2_.lineTo(x2,y1);
   _loc2_.endFill();
   _loc2_.moveTo(x2,y3);
   _loc2_.beginFill(this.borderLightColor);
   _loc2_.lineTo(2 * x3,y3);
   _loc2_.lineTo(2 * x3,y4);
   _loc2_.lineTo(x2,y4);
   _loc2_.lineTo(x2,y3);
   _loc2_.endFill();
   var i = 0;
   while(i < 2 * this.numberOfLongitudeDivisions)
   {
      var x = i * hd;
      _loc2_.beginFill(this.borderDarkColor);
      _loc2_.moveTo(x,y1);
      _loc2_.lineTo(x + hd,y1);
      _loc2_.lineTo(x + hd,y2);
      _loc2_.lineTo(x,y2);
      _loc2_.lineTo(x,y1);
      _loc2_.endFill();
      _loc2_.beginFill(this.borderDarkColor);
      _loc2_.moveTo(x,y3);
      _loc2_.lineTo(x + hd,y3);
      _loc2_.lineTo(x + hd,y4);
      _loc2_.lineTo(x,y4);
      _loc2_.lineTo(x,y3);
      _loc2_.endFill();
      i += 2;
   }
   _loc1_.lineStyle();
   var i = 0;
   var _loc3_;
   while(i < this.numberOfLatitudeDivisions)
   {
      _loc3_ = i * vd;
      _loc1_.beginFill(this.borderDarkColor);
      _loc1_.moveTo(x1,_loc3_);
      _loc1_.lineTo(x2,_loc3_);
      _loc1_.lineTo(x2,_loc3_ + vd);
      _loc1_.lineTo(x1,_loc3_ + vd);
      _loc1_.lineTo(x1,_loc3_);
      _loc1_.endFill();
      _loc1_.beginFill(this.borderDarkColor);
      _loc1_.moveTo(x3,_loc3_);
      _loc1_.lineTo(x4,_loc3_);
      _loc1_.lineTo(x4,_loc3_ + vd);
      _loc1_.lineTo(x3,_loc3_ + vd);
      _loc1_.lineTo(x3,_loc3_);
      _loc1_.endFill();
      i += 2;
   }
   this.horizontalBorderMC._x = this.maskedAreaMC._x;
};
p.updateIDL = function()
{
   var _loc3_ = this.maskedAreaMC.IDLMC.createEmptyMovieClip("_1MC",1);
   _loc3_.lineStyle(this.IDLLineThickness,this.IDLLineColor,this.IDLLineAlpha);
   var list = !this.useKiribatiIDL ? this.IDLList_withoutKiribati : this.IDLList_withKiribati;
   var xLim = 0.5 * this.mapWidth;
   var _loc1_ = list[0];
   if(_loc1_.x < xLim)
   {
      _loc3_.moveTo(_loc1_.x,_loc1_.y);
   }
   else
   {
      _loc3_.moveTo(_loc1_.x - this.mapWidth,_loc1_.y);
   }
   var _loc2_ = 1;
   while(_loc2_ < list.length)
   {
      _loc1_ = list[_loc2_];
      if(_loc1_.x < xLim)
      {
         _loc3_.lineTo(_loc1_.x,_loc1_.y);
      }
      else
      {
         _loc3_.lineTo(_loc1_.x - this.mapWidth,_loc1_.y);
      }
      _loc2_ = _loc2_ + 1;
   }
   _loc3_.duplicateMovieClip("_2MC",2,{_x:this.mapWidth});
   _loc3_.duplicateMovieClip("_3MC",3,{_x:2 * this.mapWidth});
};
p.updateDayAndNightRegions = function()
{
   this.maskedAreaMC.dayAndNightRegionsMC.removeMovieClip();
   var _loc2_;
   var _loc1_;
   var _loc3_;
   if(this._showTerminator)
   {
      this.maskedAreaMC.createEmptyMovieClip("dayAndNightRegionsMC",20);
      _loc2_ = this.maskedAreaMC.dayAndNightRegionsMC.createEmptyMovieClip("n0",100);
      var dmc = this.maskedAreaMC.dayAndNightRegionsMC.createEmptyMovieClip("d0",200);
      var tmc = this.maskedAreaMC.dayAndNightRegionsMC.createEmptyMovieClip("t0",300);
      var w = this.mapWidth;
      this.maskedAreaMC.dayAndNightRegionsMC._y = w / 4;
      var k = w / 6.283185307179586;
      var thickness = this.terminatorThickness;
      var color = this.terminatorColor;
      var alpha = this.terminatorAlpha;
      var nightFillColor = this.nightSideFillColor;
      var nightFillAlpha = this.nightSideFillAlpha;
      var dayFillColor = this.daySideFillColor;
      var dayFillAlpha = this.daySideFillAlpha;
      var cos = Math.cos;
      var sin = Math.sin;
      var atan = Math.atan;
      var phi = this._sunDeclination;
      var absPhi = Math.abs(phi);
      if(absPhi > 30)
      {
         var n = 10;
      }
      else if(absPhi > 10)
      {
         var n = 15;
      }
      else if(absPhi > 1.5)
      {
         var n = 30;
      }
      else if(absPhi > 0.5)
      {
         var n = 40;
      }
      else
      {
         var n = 50;
      }
      var C = 1 / Math.tan(phi * 3.141592653589793 / 180);
      var A = - C;
      var B = C * C;
      if(!isFinite(C) || isNaN(C))
      {
         var f = w / 4;
         _loc2_.moveTo(0,f);
         _loc2_.beginFill(nightFillColor,nightFillAlpha);
         _loc2_.lineTo(f,f);
         _loc2_.lineTo(f,- f);
         _loc2_.lineTo(0,- f);
         _loc2_.lineTo(0,f);
         _loc2_.endFill();
         _loc2_.moveTo(w,f);
         _loc2_.beginFill(nightFillColor,nightFillAlpha);
         _loc2_.lineTo(w,- f);
         _loc2_.lineTo(w - f,- f);
         _loc2_.lineTo(w - f,f);
         _loc2_.lineTo(w,f);
         _loc2_.endFill();
         dmc.moveTo(f,f);
         dmc.beginFill(dayFillColor,dayFillAlpha);
         dmc.lineTo(w - f,f);
         dmc.lineTo(w - f,- f);
         dmc.lineTo(f,- f);
         dmc.lineTo(f,f);
         dmc.endFill();
         tmc.lineStyle(thickness,color,alpha);
         tmc.moveTo(f,f);
         tmc.lineTo(f,- f);
         tmc.lineStyle(thickness,color,alpha);
         tmc.moveTo(w - f,f);
         tmc.lineTo(w - f,- f);
      }
      else
      {
         _loc1_ = [];
         var x = 0;
         var cosX = cos(x);
         var yLast = atan(C * cosX);
         var mLast = A * sin(x) / (1 + B * (cosX * cosX));
         var step = 3.141592653589793 / (2 * n);
         _loc1_.push({ax:k * x,ay:(- k) * yLast});
         _loc3_ = 0;
         while(_loc3_ < n)
         {
            x += step;
            var cosX = cos(x);
            var yNow = atan(C * cosX);
            var mNow = A * sin(x) / (1 + B * (cosX * cosX));
            var cx = x + (yLast - yNow + mLast * step) / (mNow - mLast);
            var cy = mNow * (cx - x) + yNow;
            _loc1_.push({cx:k * cx,cy:(- k) * cy});
            _loc1_.push({ax:k * x,ay:(- k) * yNow});
            yLast = yNow;
            mLast = mNow;
            _loc3_ = _loc3_ + 1;
         }
         var dy = phi <= 0 ? w / 4 : (- w) / 4;
         var ny = phi >= 0 ? w / 4 : (- w) / 4;
         var sx = _loc1_[0].ax;
         var sy = _loc1_[0].ay;
         var h = w / 2;
         tmc.moveTo(sx,sy);
         tmc.lineStyle(thickness,color,alpha);
         _loc2_.moveTo(sx,sy);
         _loc2_.beginFill(nightFillColor,nightFillAlpha);
         dmc.moveTo(sx,sy);
         dmc.beginFill(dayFillColor,dayFillAlpha);
         _loc3_ = 1;
         while(_loc3_ < _loc1_.length)
         {
            var cx = _loc1_[_loc3_].cx;
            var cy = _loc1_[_loc3_].cy;
            var ax = _loc1_[_loc3_ + 1].ax;
            var ay = _loc1_[_loc3_ + 1].ay;
            tmc.curveTo(cx,cy,ax,ay);
            _loc2_.curveTo(cx,cy,ax,ay);
            dmc.curveTo(cx,cy,ax,ay);
            _loc3_ += 2;
         }
         _loc3_ = _loc1_.length - 2;
         while(_loc3_ > 0)
         {
            var cx = h - _loc1_[_loc3_].cx;
            var cy = - _loc1_[_loc3_].cy;
            var ax = h - _loc1_[_loc3_ - 1].ax;
            var ay = - _loc1_[_loc3_ - 1].ay;
            tmc.curveTo(cx,cy,ax,ay);
            _loc2_.curveTo(cx,cy,ax,ay);
            dmc.curveTo(cx,cy,ax,ay);
            _loc3_ -= 2;
         }
         _loc3_ = 1;
         while(_loc3_ < _loc1_.length)
         {
            var cx = h + _loc1_[_loc3_].cx;
            var cy = - _loc1_[_loc3_].cy;
            var ax = h + _loc1_[_loc3_ + 1].ax;
            var ay = - _loc1_[_loc3_ + 1].ay;
            tmc.curveTo(cx,cy,ax,ay);
            _loc2_.curveTo(cx,cy,ax,ay);
            dmc.curveTo(cx,cy,ax,ay);
            _loc3_ += 2;
         }
         _loc3_ = _loc1_.length - 2;
         while(_loc3_ > 0)
         {
            var cx = w - _loc1_[_loc3_].cx;
            var cy = _loc1_[_loc3_].cy;
            var ax = w - _loc1_[_loc3_ - 1].ax;
            var ay = _loc1_[_loc3_ - 1].ay;
            tmc.curveTo(cx,cy,ax,ay);
            _loc2_.curveTo(cx,cy,ax,ay);
            dmc.curveTo(cx,cy,ax,ay);
            _loc3_ -= 2;
         }
         _loc2_.lineTo(w,ny);
         _loc2_.lineTo(0,ny);
         _loc2_.lineTo(sx,sy);
         _loc2_.endFill();
         dmc.lineTo(w,dy);
         dmc.lineTo(0,dy);
         dmc.lineTo(sx,sy);
         dmc.endFill();
      }
      _loc2_.duplicateMovieClip("n1",101);
      _loc2_.duplicateMovieClip("n2",102);
      dmc.duplicateMovieClip("d1",201);
      dmc.duplicateMovieClip("d2",202);
      tmc.duplicateMovieClip("t1",301);
      tmc.duplicateMovieClip("t2",302);
      this.updateDayAndNightRegionsOffset();
   }
};
p.updateDayAndNightRegionsOffset = function()
{
   var _loc1_ = this;
   var _loc3_ = _loc1_.mapWidth;
   var _loc2_ = _loc3_ * ((_loc1_._sunLongitude / 360 % 1 + 1) % 1);
   _loc1_.maskedAreaMC.dayAndNightRegionsMC.n0._x = _loc2_ - _loc3_;
   _loc1_.maskedAreaMC.dayAndNightRegionsMC.n1._x = _loc2_;
   _loc1_.maskedAreaMC.dayAndNightRegionsMC.n2._x = _loc2_ + _loc3_;
   _loc1_.maskedAreaMC.dayAndNightRegionsMC.d0._x = _loc2_ - _loc3_;
   _loc1_.maskedAreaMC.dayAndNightRegionsMC.d1._x = _loc2_;
   _loc1_.maskedAreaMC.dayAndNightRegionsMC.d2._x = _loc2_ + _loc3_;
   _loc1_.maskedAreaMC.dayAndNightRegionsMC.t0._x = _loc2_ - _loc3_;
   _loc1_.maskedAreaMC.dayAndNightRegionsMC.t1._x = _loc2_;
   _loc1_.maskedAreaMC.dayAndNightRegionsMC.t2._x = _loc2_ + _loc3_;
};
p.getShowDayAndNightRegions = function()
{
   return this._showTerminator;
};
p.setShowDayAndNightRegions = function(arg)
{
   this._showTerminator = Boolean(arg);
   this.updateDayAndNightRegions();
};
p.addProperty("showDayAndNightRegions",p.getShowDayAndNightRegions,p.setShowDayAndNightRegions);
p.getSunLongitude = function()
{
   return this._sunLongitude;
};
p.setSunLongitude = function(arg)
{
   var _loc1_ = arg;
   if(!isNaN(_loc1_) && isFinite(_loc1_))
   {
      this._sunLongitude = _loc1_;
      this.updateDayAndNightRegionsOffset();
   }
};
p.addProperty("sunLongitude",p.getSunLongitude,p.setSunLongitude);
p.getSunDeclination = function()
{
   return this._sunDeclination;
};
p.setSunDeclination = function(arg)
{
   var _loc1_ = arg;
   if(!isNaN(_loc1_) && isFinite(_loc1_))
   {
      this._sunDeclination = _loc1_;
      this.updateDayAndNightRegions();
   }
};
p.addProperty("sunDeclination",p.getSunDeclination,p.setSunDeclination);
p.getLongitudeOffset = function()
{
   return this._offset;
};
p.setLongitudeOffset = function(arg)
{
   var _loc1_ = this;
   var _loc2_ = arg;
   if(!isNaN(_loc2_) && isFinite(_loc2_))
   {
      _loc1_._offset = (_loc2_ % 360 + 360) % 360;
      _loc1_.maskedAreaMC._x = (- (_loc1_._offset + 180)) * (_loc1_.mapWidth / 360) % _loc1_.mapWidth;
      _loc1_.horizontalBorderMC._x = _loc1_.maskedAreaMC._x;
      _loc1_.updateBorderLabels();
   }
};
p.addProperty("longitudeOffset",p.getLongitudeOffset,p.setLongitudeOffset);
p.getAllowDragging = function()
{
   return this.maskMC.onPress == this.dragOnPress;
};
p.setAllowDragging = function(arg)
{
   var _loc1_ = this;
   _loc1_.maskMC.useHandCursor = false;
   _loc1_.maskMC.tabEnabled = false;
   if(arg)
   {
      _loc1_.maskMC.onPress = _loc1_.dragOnPress;
      _loc1_.maskMC.onRelease = _loc1_.dragOnRelease;
      _loc1_.maskMC.onReleaseOutside = _loc1_.dragOnRelease;
      _loc1_.maskMC.onMouseMoveFunc = _loc1_.dragOnMouseMoveFunc;
   }
   else
   {
      delete _loc1_.maskMC.onPress;
      delete _loc1_.maskMC.onRelease;
      delete _loc1_.maskMC.onReleaseOutside;
      delete _loc1_.maskMC.onMouseMoveFunc;
   }
};
p.addProperty("allowDragging",p.getAllowDragging,p.setAllowDragging);
p.dragOnPress = function()
{
   var _loc1_ = this;
   _loc1_.initXMouse = _loc1_._xmouse;
   _loc1_.initOffset = _loc1_._parent._offset;
   _loc1_.onMouseMove = _loc1_.onMouseMoveFunc;
};
p.dragOnMouseMoveFunc = function()
{
   var _loc1_ = this;
   var _loc2_ = _loc1_.initOffset - (_loc1_._xmouse - _loc1_.initXMouse) * (360 / _loc1_._parent.mapWidth);
   _loc1_._parent.setLongitudeOffset(_loc2_);
   _loc1_._parent._parent[_loc1_._parent.onDragHandler](_loc1_._parent._offset);
   updateAfterEvent();
};
p.dragOnRelease = function()
{
   delete this.onMouseMove;
};
p.IDLList_withKiribati = [{lat:90,lon:180},{lat:75,lon:180},{lat:72,lon:-169},{lat:65.5,lon:-169},{lat:64,lon:-175},{lat:50.5,lon:167},{lat:48,lon:180},{lat:2,lon:180},{lat:0,lon:-179},{lat:0,lon:-165},{lat:-3,lon:-165},{lat:-3,lon:-160},{lat:2,lon:-160},{lat:2,lon:-162},{lat:5,lon:-162},{lat:5,lon:-154},{lat:-8,lon:-151},{lat:-12,lon:-151},{lat:-12,lon:-157},{lat:-9,lon:-157},{lat:-9,lon:-178},{lat:-15,lon:-175.5},{lat:-44.75,lon:-175.5},{lat:-51.5,lon:180},{lat:-90,lon:180}];
p.IDLList_withoutKiribati = [{lat:90,lon:180},{lat:75,lon:180},{lat:72,lon:-169},{lat:65.5,lon:-169},{lat:64,lon:-175},{lat:50.5,lon:167},{lat:48,lon:180},{lat:-5,lon:180},{lat:-15,lon:-175.5},{lat:-44.75,lon:-175.5},{lat:-51.5,lon:180},{lat:-90,lon:180}];
