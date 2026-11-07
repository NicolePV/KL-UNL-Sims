function FlatMapComponent007Class()
{
   this.mapHeight = this._height == 0 ? this.defaultMapHeight : this._height;
   this._xscale = 100;
   this._yscale = 100;
   this.placeholderMC._visible = false;
   this.placeholderMC.swapDepths(987789);
   this.placeholderMC.removeMovieClip();
   this.initialize();
}
var p = FlatMapComponent007Class.prototype = new MovieClip();
Object.registerClass("Flat Map Component 007",FlatMapComponent007Class);
p.initOffset = 180;
p.initAllowDragging = false;
p.initShowIDL = false;
p.initShowLatitudeGrid = false;
p.initShowLongitudeGrid = false;
p.initShowBorderLabels = true;
p.initShowDayAndNightRegions = false;
p.initSunDeclination = 10;
p.initSunLongitude = 0;
p.initSunLatitude = 0;
p.terminatorThickness = 1;
p.terminatorColor = 9474192;
p.terminatorAlpha = 100;
p.nightSideFillColor = 16711680;
p.nightSideFillAlpha = 100;
p.daySideFillColor = 0;
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
p.mapLinkageNameDay = "FMC Map Rev 1 Day";
p.mapLinkageNameNight = "FMC Map Rev 1 Night";
p.defaultMapHeight = 225;
p.removeAllLines = function()
{
   this.maskedAreaMC.createEmptyMovieClip("linesMC",12);
};
p.addLine = function(definition)
{
   var _loc8_ = definition.thickness == undefined ? this.defaultLineThickness : definition.thickness;
   var _loc7_ = definition.mycolor == undefined ? this.defaultLineColor : definition.mycolor;
   var _loc9_ = definition.alpha == undefined ? this.defaultLineAlpha : definition.alpha;
   var _loc4_ = this.maskedAreaMC.linesMC;
   _loc4_.clear();
   _loc4_.lineStyle(_loc8_,_loc7_,_loc9_);
   var _loc6_;
   if(definition.lat != undefined)
   {
      _loc6_ = (90 - definition.lat) * (this.mapWidth / 360);
      _loc4_.moveTo(0,_loc6_);
      _loc4_.lineTo(2 * this.mapWidth,_loc6_);
   }
   var _loc3_;
   var _loc2_;
   if(definition.lon != undefined)
   {
      _loc3_ = this.mapWidth * (((definition.lon + 180) / 360 % 1 + 1) % 1) - this.mapWidth;
      _loc2_ = 0;
      while(_loc2_ < 4)
      {
         _loc4_.moveTo(_loc3_,0);
         _loc4_.lineTo(_loc3_,this.mapHeight);
         _loc3_ += this.mapWidth;
         _loc2_ = _loc2_ + 1;
      }
   }
};
p.removeObject = function(name)
{
   var _loc2_ = 0;
   while(_loc2_ < this.objectsList.length)
   {
      if(this.objectsList[_loc2_].name == name)
      {
         this.objectsList[_loc2_].mc.removeMovieClip();
         this.objectsList.splice(_loc2_,1);
         break;
      }
      _loc2_ = _loc2_ + 1;
   }
};
p.addObject = function(linkageName, name, position, initObj)
{
   var _loc2_ = this.objectsFreeDepth;
   this.objectsFreeDepth = this.objectsFreeDepth + 1;
   var _loc6_ = this.maskedAreaMC.objectsMC.createEmptyMovieClip("_" + _loc2_ + "MC",_loc2_);
   _loc6_.attachMovie(linkageName,"_1MC",1,initObj);
   _loc6_.attachMovie(linkageName,"_2MC",2,initObj);
   _loc6_.attachMovie(linkageName,"_3MC",3,initObj);
   _loc6_.attachMovie(linkageName,"_4MC",4,initObj);
   this.objectsList.push({name:name,mc:_loc6_});
   this.setObjectPosition(name,position);
};
p.passDataToObject = function(name, dataObj)
{
   var _loc2_ = 0;
   while(_loc2_ < this.objectsList.length)
   {
      if(this.objectsList[_loc2_].name == name)
      {
         this.objectsList[_loc2_].mc._1MC.receiveData(dataObj);
         this.objectsList[_loc2_].mc._2MC.receiveData(dataObj);
         this.objectsList[_loc2_].mc._3MC.receiveData(dataObj);
         this.objectsList[_loc2_].mc._4MC.receiveData(dataObj);
         break;
      }
      _loc2_ = _loc2_ + 1;
   }
};
p.setObjectPosition = function(name, position)
{
   var _loc4_ = 0;
   var _loc2_;
   var _loc3_;
   while(_loc4_ < this.objectsList.length)
   {
      if(this.objectsList[_loc4_].name == name)
      {
         _loc2_ = this.objectsList[_loc4_].mc;
         _loc3_ = this.getScreenPointFromPosition(position);
         _loc2_._1MC._x = _loc3_.x - this.mapWidth;
         _loc2_._2MC._x = _loc3_.x;
         _loc2_._3MC._x = _loc3_.x + this.mapWidth;
         _loc2_._4MC._x = _loc3_.x + 2 * this.mapWidth;
         _loc2_._1MC._y = _loc3_.y;
         _loc2_._2MC._y = _loc3_.y;
         _loc2_._3MC._y = _loc3_.y;
         _loc2_._4MC._y = _loc3_.y;
         break;
      }
      _loc4_ = _loc4_ + 1;
   }
};
p.removeAllObjects = function()
{
   this.objectsList = [];
   this.objectsFreeDepth = 1;
   this.maskedAreaMC.createEmptyMovieClip("objectsMC",15);
};
p.getScreenPointFromPosition = function(position)
{
   var _loc2_ = {};
   _loc2_.x = this.mapWidth * (((position.lon + 180) / 360 % 1 + 1) % 1);
   _loc2_.y = (90 - position.lat) * (this.mapWidth / 360);
   return _loc2_;
};
p.initialize = function()
{
   this.createEmptyMovieClip("maskMC",1);
   this.createEmptyMovieClip("maskedAreaMC",2);
   this.maskedAreaMC.setMask(this.maskMC);
   this.attachMovie(this.fontLinkageName,"fontsMC",424242,{_visible:false});
   this.borderLabelsTextFormat = this.fontsMC.borderLabelsField.getTextFormat();
   this.maskedAreaMC.attachMovie(this.mapLinkageNameDay,"mapMC_Day",1);
   this.maskedAreaMC.attachMovie(this.mapLinkageNameNight,"mapMC_Night",2);
   this.maskedAreaMC.createEmptyMovieClip("longitudeGridMC",5);
   this.maskedAreaMC.createEmptyMovieClip("latitudeGridMC",6);
   this.maskedAreaMC.createEmptyMovieClip("IDLMC",10);
   this.mapWidth = 2 * this.mapHeight;
   this.maskedAreaMC.mapMC_Day._xscale = this.maskedAreaMC.mapMC_Day._yscale = 100 * (this.mapHeight / this.maskedAreaMC.mapMC_Day._height);
   this.maskedAreaMC.mapMC_Night._xscale = this.maskedAreaMC.mapMC_Night._yscale = 100 * (this.mapHeight / this.maskedAreaMC.mapMC_Night._height);
   this.maskMC.moveTo(0,0);
   this.maskMC.beginFill(16711680);
   this.maskMC.lineTo(this.mapWidth,0);
   this.maskMC.lineTo(this.mapWidth,this.mapHeight);
   this.maskMC.lineTo(0,this.mapHeight);
   this.maskMC.lineTo(0,0);
   this.maskMC.endFill();
   var _loc3_ = 0;
   var _loc2_;
   while(_loc3_ < this.IDLList_withKiribati.length)
   {
      _loc2_ = this.IDLList_withKiribati[_loc3_];
      _loc2_.x = this.mapWidth * (((_loc2_.lon + 180) / 360 % 1 + 1) % 1);
      _loc2_.y = (90 - _loc2_.lat) * (this.mapWidth / 360);
      _loc3_ = _loc3_ + 1;
   }
   _loc3_ = 0;
   while(_loc3_ < this.IDLList_withoutKiribati.length)
   {
      _loc2_ = this.IDLList_withoutKiribati[_loc3_];
      _loc2_.x = this.mapWidth * (((_loc2_.lon + 180) / 360 % 1 + 1) % 1);
      _loc2_.y = (90 - _loc2_.lat) * (this.mapWidth / 360);
      _loc3_ = _loc3_ + 1;
   }
   this.removeAllLines();
   this.removeAllObjects();
   this.updateBorder();
   this.updateIDL();
   this.updateLatitudeGrid();
   this.updateLongitudeGrid();
   this.setLongitudeOffset(this.initOffset);
   this.setAllowDragging(this.initAllowDragging);
   this.setShowBorderLabels(this.initShowBorderLabels);
   this.setShowIDL(this.initShowIDL);
   this.setShowLongitudeGrid(this.initShowLongitudeGrid);
   this.setShowLatitudeGrid(this.initShowLatitudeGrid);
   this.setShowDayAndNightRegions(this.initShowDayAndNightRegions);
   this.setSunLongitude(this.initSunLongitude);
   this.setSunLatitude(this.initSunLatitude);
   this.setSunDeclination(this.initSunDeclination);
};
p.updateGrid = function()
{
   this.updateLatitudeGrid();
   this.updateLongitudeGrid();
};
p.updateLatitudeGrid = function()
{
   var _loc4_ = this.maskedAreaMC.latitudeGridMC;
   _loc4_.clear();
   _loc4_.lineStyle(this.gridThickness,this.gridColor,this.gridAlpha);
   var _loc7_ = 0;
   var _loc6_ = 2 * this.mapWidth;
   var _loc5_ = this.mapHeight / this.numberOfLatitudeDivisions;
   var _loc3_ = _loc5_;
   var _loc2_ = 1;
   while(_loc2_ < this.numberOfLatitudeDivisions)
   {
      _loc4_.moveTo(_loc7_,_loc3_);
      _loc4_.lineTo(_loc6_,_loc3_);
      _loc3_ += _loc5_;
      _loc2_ = _loc2_ + 1;
   }
};
p.updateLongitudeGrid = function()
{
   var _loc4_ = this.maskedAreaMC.longitudeGridMC;
   _loc4_.clear();
   _loc4_.lineStyle(this.gridThickness,this.gridColor,this.gridAlpha);
   var _loc6_ = 0;
   var _loc5_ = this.mapHeight;
   var _loc7_ = this.mapWidth / this.numberOfLongitudeDivisions;
   var _loc3_ = 0;
   var _loc2_ = 0;
   while(_loc2_ <= 2 * this.numberOfLongitudeDivisions)
   {
      _loc4_.moveTo(_loc3_,_loc6_);
      _loc4_.lineTo(_loc3_,_loc5_);
      _loc3_ += _loc7_;
      _loc2_ = _loc2_ + 1;
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
   if(arg)
   {
      this.attachBorderLabels();
      this.updateBorderLabels();
   }
   else
   {
      this.removeBorderLabels();
   }
};
p.addProperty("showBorderLabels",p.getShowBorderLabels,p.setShowBorderLabels);
p.updateBorderAndLabels = function()
{
   this.updateBorder();
   if(this.showBorderLabels)
   {
      this.attachBorderLabels();
      this.updateBorderLabels();
   }
};
p.updateBorderLabels = function()
{
   if(this.latitudeLabelsMC == undefined)
   {
      return undefined;
   }
   var _loc3_ = this._offset != 0 ? this.mapWidth * (1 - this._offset / 360) : 0;
   var _loc6_ = this.mapWidth / this.numberOfLongitudeDivisions;
   var _loc2_ = 0;
   var _loc4_;
   var _loc5_;
   while(_loc2_ < this.numberOfLongitudeDivisions)
   {
      _loc4_ = this.longitudeLabelsMC["top" + _loc2_];
      _loc5_ = this.longitudeLabelsMC["bottom" + _loc2_];
      this.longitudeLabelsMC["bottom" + _loc2_]._x = this.longitudeLabelsMC["top" + _loc2_]._x = _loc3_ - this.longitudeLabelsMC["top" + _loc2_]._width / 2;
      _loc3_ = (_loc3_ + _loc6_) % this.mapWidth;
      _loc2_ = _loc2_ + 1;
   }
};
p.attachBorderLabels = function()
{
   this.createEmptyMovieClip("longitudeLabelsMC",200);
   this.createEmptyMovieClip("latitudeLabelsMC",201);
   var _loc19_ = this.fontsMC.borderLabelsField._height;
   this.borderLabelsTextFormat.color = this.borderDarkColor;
   var _loc13_ = - this.borderWidth - this.borderLabelMargin - _loc19_;
   var _loc12_ = this.mapHeight + this.borderWidth + this.borderLabelMargin;
   var _loc18_ = 360 / this.numberOfLongitudeDivisions;
   var _loc2_ = 0;
   var _loc3_;
   var _loc7_;
   var _loc5_;
   var _loc9_;
   while(_loc2_ < this.numberOfLongitudeDivisions)
   {
      this.longitudeLabelsMC.createTextField("top" + _loc2_,_loc2_,0,_loc13_,0,0);
      this.longitudeLabelsMC.createTextField("bottom" + _loc2_,1000 + _loc2_,0,_loc12_,0,0);
      _loc3_ = this.longitudeLabelsMC["top" + _loc2_];
      _loc7_ = this.longitudeLabelsMC["bottom" + _loc2_];
      _loc5_ = Math.round(_loc2_ * _loc18_);
      if(_loc5_ == 0)
      {
         _loc9_ = "0°";
      }
      else if(_loc5_ == 180)
      {
         _loc9_ = "180°";
      }
      else if(_loc5_ < 180)
      {
         _loc9_ = _loc5_ + "° E";
      }
      else
      {
         _loc9_ = 360 - _loc5_ + "° W";
      }
      _loc3_.setNewTextFormat(this.borderLabelsTextFormat);
      _loc3_.autoSize = "left";
      _loc3_.embedFonts = true;
      _loc3_.selectable = false;
      _loc3_.text = _loc9_;
      _loc7_.setNewTextFormat(this.borderLabelsTextFormat);
      _loc7_.autoSize = "left";
      _loc7_.embedFonts = true;
      _loc7_.selectable = false;
      _loc7_.text = _loc9_;
      _loc2_ = _loc2_ + 1;
   }
   var _loc15_ = - this.borderWidth - this.borderLabelMargin;
   var _loc16_ = this.mapWidth + this.borderWidth + this.borderLabelMargin;
   var _loc11_ = (- _loc19_) / 2;
   var _loc17_ = this.mapHeight / this.numberOfLatitudeDivisions;
   var _loc14_ = 180 / this.numberOfLatitudeDivisions;
   _loc2_ = 0;
   var _loc8_;
   var _loc10_;
   var _loc4_;
   var _loc6_;
   while(_loc2_ <= this.numberOfLatitudeDivisions)
   {
      this.latitudeLabelsMC.createTextField("left" + _loc2_,_loc2_,_loc15_,_loc11_,0,0);
      this.latitudeLabelsMC.createTextField("right" + _loc2_,1000 + _loc2_,_loc16_,_loc11_,0,0);
      _loc11_ += _loc17_;
      _loc8_ = Math.round(90 - _loc2_ * _loc14_);
      if(_loc8_ > 0)
      {
         _loc10_ = _loc8_ + "° N";
      }
      else if(_loc8_ < 0)
      {
         _loc10_ = - _loc8_ + "° S";
      }
      else
      {
         _loc10_ = "0°";
      }
      _loc4_ = this.latitudeLabelsMC["left" + _loc2_];
      _loc6_ = this.latitudeLabelsMC["right" + _loc2_];
      _loc4_.setNewTextFormat(this.borderLabelsTextFormat);
      _loc4_.autoSize = "right";
      _loc4_.embedFonts = true;
      _loc4_.selectable = false;
      _loc4_.text = _loc10_;
      _loc6_.setNewTextFormat(this.borderLabelsTextFormat);
      _loc6_.autoSize = "left";
      _loc6_.embedFonts = true;
      _loc6_.selectable = false;
      _loc6_.text = _loc10_;
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
   var _loc3_ = this.createEmptyMovieClip("horizontalBorderMC",100);
   var _loc17_ = this.createEmptyMovieClip("horizontalBorderMaskMC",101);
   var _loc2_ = this.createEmptyMovieClip("borderMC",102);
   _loc3_.setMask(_loc17_);
   var _loc18_ = this.borderWidth;
   var _loc10_ = this.mapHeight / this.numberOfLatitudeDivisions;
   var _loc9_ = this.mapWidth / this.numberOfLongitudeDivisions;
   var _loc7_ = - _loc18_;
   var _loc15_ = 0;
   var _loc11_ = this.mapHeight;
   var _loc13_ = this.mapHeight + _loc18_;
   var _loc14_ = - _loc18_;
   var _loc8_ = 0;
   var _loc6_ = this.mapWidth;
   var _loc16_ = this.mapWidth + _loc18_;
   _loc17_.beginFill(16711680);
   _loc17_.moveTo(_loc8_,_loc7_ - 5);
   _loc17_.lineTo(_loc6_,_loc7_ - 5);
   _loc17_.lineTo(_loc6_,_loc13_ + 5);
   _loc17_.lineTo(_loc8_,_loc13_ + 5);
   _loc17_.lineTo(_loc8_,_loc7_ - 5);
   _loc17_.endFill();
   _loc2_.lineStyle(1,this.borderDarkColor);
   _loc2_.moveTo(_loc14_,_loc7_);
   _loc2_.beginFill(this.borderLightColor);
   _loc2_.lineTo(_loc8_,_loc7_);
   _loc2_.lineTo(_loc8_,_loc13_);
   _loc2_.lineTo(_loc14_,_loc13_);
   _loc2_.lineTo(_loc14_,_loc7_);
   _loc2_.endFill();
   _loc2_.lineStyle(1,this.borderDarkColor);
   _loc2_.moveTo(_loc6_,_loc7_);
   _loc2_.beginFill(this.borderLightColor);
   _loc2_.lineTo(_loc16_,_loc7_);
   _loc2_.lineTo(_loc16_,_loc13_);
   _loc2_.lineTo(_loc6_,_loc13_);
   _loc2_.lineTo(_loc6_,_loc7_);
   _loc2_.endFill();
   _loc2_.lineStyle(1,this.borderDarkColor);
   _loc2_.moveTo(_loc14_,_loc15_);
   _loc2_.lineTo(_loc8_,_loc15_);
   _loc2_.moveTo(_loc6_,_loc15_);
   _loc2_.lineTo(_loc16_,_loc15_);
   _loc2_.moveTo(_loc14_,_loc11_);
   _loc2_.lineTo(_loc8_,_loc11_);
   _loc2_.moveTo(_loc6_,_loc11_);
   _loc2_.lineTo(_loc16_,_loc11_);
   _loc2_.lineStyle(1,this.borderDarkColor);
   _loc2_.moveTo(_loc8_,_loc7_);
   _loc2_.lineTo(_loc6_,_loc7_);
   _loc2_.moveTo(_loc8_,_loc15_);
   _loc2_.lineTo(_loc6_,_loc15_);
   _loc2_.moveTo(_loc8_,_loc11_);
   _loc2_.lineTo(_loc6_,_loc11_);
   _loc2_.moveTo(_loc8_,_loc13_);
   _loc2_.lineTo(_loc6_,_loc13_);
   _loc2_.lineStyle(1,this.borderDarkColor);
   _loc2_.moveTo(_loc8_,_loc7_);
   _loc2_.lineTo(_loc6_,_loc7_);
   _loc2_.moveTo(_loc8_,_loc15_);
   _loc2_.lineTo(_loc6_,_loc15_);
   _loc2_.moveTo(_loc8_,_loc11_);
   _loc2_.lineTo(_loc6_,_loc11_);
   _loc2_.moveTo(_loc8_,_loc13_);
   _loc2_.lineTo(_loc6_,_loc13_);
   _loc3_.lineStyle();
   _loc3_.moveTo(_loc8_,_loc7_);
   _loc3_.beginFill(this.borderLightColor);
   _loc3_.lineTo(2 * _loc6_,_loc7_);
   _loc3_.lineTo(2 * _loc6_,_loc15_);
   _loc3_.lineTo(_loc8_,_loc15_);
   _loc3_.lineTo(_loc8_,_loc7_);
   _loc3_.endFill();
   _loc3_.moveTo(_loc8_,_loc11_);
   _loc3_.beginFill(this.borderLightColor);
   _loc3_.lineTo(2 * _loc6_,_loc11_);
   _loc3_.lineTo(2 * _loc6_,_loc13_);
   _loc3_.lineTo(_loc8_,_loc13_);
   _loc3_.lineTo(_loc8_,_loc11_);
   _loc3_.endFill();
   var _loc12_ = 0;
   var _loc5_;
   while(_loc12_ < 2 * this.numberOfLongitudeDivisions)
   {
      _loc5_ = _loc12_ * _loc9_;
      _loc3_.beginFill(this.borderDarkColor);
      _loc3_.moveTo(_loc5_,_loc7_);
      _loc3_.lineTo(_loc5_ + _loc9_,_loc7_);
      _loc3_.lineTo(_loc5_ + _loc9_,_loc15_);
      _loc3_.lineTo(_loc5_,_loc15_);
      _loc3_.lineTo(_loc5_,_loc7_);
      _loc3_.endFill();
      _loc3_.beginFill(this.borderDarkColor);
      _loc3_.moveTo(_loc5_,_loc11_);
      _loc3_.lineTo(_loc5_ + _loc9_,_loc11_);
      _loc3_.lineTo(_loc5_ + _loc9_,_loc13_);
      _loc3_.lineTo(_loc5_,_loc13_);
      _loc3_.lineTo(_loc5_,_loc11_);
      _loc3_.endFill();
      _loc12_ += 2;
   }
   _loc2_.lineStyle();
   _loc12_ = 0;
   var _loc4_;
   while(_loc12_ < this.numberOfLatitudeDivisions)
   {
      _loc4_ = _loc12_ * _loc10_;
      _loc2_.beginFill(this.borderDarkColor);
      _loc2_.moveTo(_loc14_,_loc4_);
      _loc2_.lineTo(_loc8_,_loc4_);
      _loc2_.lineTo(_loc8_,_loc4_ + _loc10_);
      _loc2_.lineTo(_loc14_,_loc4_ + _loc10_);
      _loc2_.lineTo(_loc14_,_loc4_);
      _loc2_.endFill();
      _loc2_.beginFill(this.borderDarkColor);
      _loc2_.moveTo(_loc6_,_loc4_);
      _loc2_.lineTo(_loc16_,_loc4_);
      _loc2_.lineTo(_loc16_,_loc4_ + _loc10_);
      _loc2_.lineTo(_loc6_,_loc4_ + _loc10_);
      _loc2_.lineTo(_loc6_,_loc4_);
      _loc2_.endFill();
      _loc12_ += 2;
   }
   this.horizontalBorderMC._x = this.maskedAreaMC._x;
};
p.updateIDL = function()
{
   var _loc4_ = this.maskedAreaMC.IDLMC.createEmptyMovieClip("_1MC",1);
   _loc4_.lineStyle(this.IDLLineThickness,this.IDLLineColor,this.IDLLineAlpha);
   var _loc5_ = !this.useKiribatiIDL ? this.IDLList_withoutKiribati : this.IDLList_withKiribati;
   var _loc6_ = 0.5 * this.mapWidth;
   var _loc2_ = _loc5_[0];
   if(_loc2_.x < _loc6_)
   {
      _loc4_.moveTo(_loc2_.x,_loc2_.y);
   }
   else
   {
      _loc4_.moveTo(_loc2_.x - this.mapWidth,_loc2_.y);
   }
   var _loc3_ = 1;
   while(_loc3_ < _loc5_.length)
   {
      _loc2_ = _loc5_[_loc3_];
      if(_loc2_.x < _loc6_)
      {
         _loc4_.lineTo(_loc2_.x,_loc2_.y);
      }
      else
      {
         _loc4_.lineTo(_loc2_.x - this.mapWidth,_loc2_.y);
      }
      _loc3_ = _loc3_ + 1;
   }
   _loc4_.duplicateMovieClip("_2MC",2,{_x:this.mapWidth});
   _loc4_.duplicateMovieClip("_3MC",3,{_x:2 * this.mapWidth});
};
p.updateDayAndNightRegions = function()
{
   this.maskedAreaMC.dayAndNightRegionsMC.removeMovieClip();
   if(!this._showTerminator)
   {
      return undefined;
   }
   this.maskedAreaMC.createEmptyMovieClip("dayAndNightRegionsMC",20);
   this.maskedAreaMC.createEmptyMovieClip("nightMask",30);
   var _loc3_ = this.maskedAreaMC.nightMask.createEmptyMovieClip("n0",100);
   var _loc5_ = this.maskedAreaMC.dayAndNightRegionsMC.createEmptyMovieClip("d0",200);
   var _loc8_ = this.maskedAreaMC.dayAndNightRegionsMC.createEmptyMovieClip("t0",300);
   var _loc10_ = this.mapWidth;
   this.maskedAreaMC.dayAndNightRegionsMC._y = _loc10_ / 4;
   var _loc17_ = _loc10_ / 6.283185307179586;
   var _loc36_ = this.terminatorThickness;
   var _loc35_ = this.terminatorColor;
   var _loc37_ = this.terminatorAlpha;
   var _loc33_ = this.nightSideFillColor;
   var _loc34_ = this.nightSideFillAlpha;
   var _loc39_ = this.daySideFillColor;
   var _loc40_ = this.daySideFillAlpha;
   var _loc26_ = Math.cos;
   var _loc23_ = Math.sin;
   var _loc27_ = Math.atan;
   var _loc31_ = this._sunDeclination;
   var _loc32_ = Math.abs(_loc31_);
   var _loc28_;
   if(_loc32_ > 30)
   {
      _loc28_ = 10;
   }
   else if(_loc32_ > 10)
   {
      _loc28_ = 15;
   }
   else if(_loc32_ > 1.5)
   {
      _loc28_ = 30;
   }
   else if(_loc32_ > 0.5)
   {
      _loc28_ = 40;
   }
   else
   {
      _loc28_ = 50;
   }
   var _loc21_ = 1 / Math.tan(_loc31_ * 3.141592653589793 / 180);
   var _loc25_ = - _loc21_;
   var _loc24_ = _loc21_ * _loc21_;
   var _loc9_;
   var _loc2_;
   var _loc6_;
   var _loc11_;
   var _loc20_;
   var _loc19_;
   var _loc22_;
   var _loc4_;
   var _loc7_;
   var _loc16_;
   var _loc13_;
   var _loc12_;
   var _loc38_;
   var _loc41_;
   var _loc30_;
   var _loc29_;
   var _loc18_;
   var _loc15_;
   var _loc14_;
   if(!isFinite(_loc21_) || isNaN(_loc21_))
   {
      _loc9_ = _loc10_ / 4;
      _loc3_.moveTo(0,_loc9_);
      _loc3_.beginFill(_loc33_,_loc34_);
      _loc3_.lineTo(_loc9_,_loc9_);
      _loc3_.lineTo(_loc9_,- _loc9_);
      _loc3_.lineTo(0,- _loc9_);
      _loc3_.lineTo(0,_loc9_);
      _loc3_.endFill();
      _loc3_.moveTo(_loc10_,_loc9_);
      _loc3_.beginFill(_loc33_,_loc34_);
      _loc3_.lineTo(_loc10_,- _loc9_);
      _loc3_.lineTo(_loc10_ - _loc9_,- _loc9_);
      _loc3_.lineTo(_loc10_ - _loc9_,_loc9_);
      _loc3_.lineTo(_loc10_,_loc9_);
      _loc3_.endFill();
      _loc5_.moveTo(_loc9_,_loc9_);
      _loc5_.beginFill(_loc39_,_loc40_);
      _loc5_.lineTo(_loc10_ - _loc9_,_loc9_);
      _loc5_.lineTo(_loc10_ - _loc9_,- _loc9_);
      _loc5_.lineTo(_loc9_,- _loc9_);
      _loc5_.lineTo(_loc9_,_loc9_);
      _loc5_.endFill();
      _loc8_.lineStyle(_loc36_,_loc35_,_loc37_);
      _loc8_.moveTo(_loc9_,_loc9_);
      _loc8_.lineTo(_loc9_,- _loc9_);
      _loc8_.lineStyle(_loc36_,_loc35_,_loc37_);
      _loc8_.moveTo(_loc10_ - _loc9_,_loc9_);
      _loc8_.lineTo(_loc10_ - _loc9_,- _loc9_);
   }
   else
   {
      _loc2_ = [];
      _loc6_ = 0;
      _loc11_ = _loc26_(_loc6_);
      _loc20_ = _loc27_(_loc21_ * _loc11_);
      _loc19_ = _loc25_ * _loc23_(_loc6_) / (1 + _loc24_ * (_loc11_ * _loc11_));
      _loc22_ = 3.141592653589793 / (2 * _loc28_);
      _loc2_.push({ax:_loc17_ * _loc6_,ay:(- _loc17_) * _loc20_});
      _loc4_ = 0;
      while(_loc4_ < _loc28_)
      {
         _loc6_ += _loc22_;
         _loc11_ = _loc26_(_loc6_);
         _loc7_ = _loc27_(_loc21_ * _loc11_);
         _loc16_ = _loc25_ * _loc23_(_loc6_) / (1 + _loc24_ * (_loc11_ * _loc11_));
         _loc13_ = _loc6_ + (_loc20_ - _loc7_ + _loc19_ * _loc22_) / (_loc16_ - _loc19_);
         _loc12_ = _loc16_ * (_loc13_ - _loc6_) + _loc7_;
         _loc2_.push({cx:_loc17_ * _loc13_,cy:(- _loc17_) * _loc12_});
         _loc2_.push({ax:_loc17_ * _loc6_,ay:(- _loc17_) * _loc7_});
         _loc20_ = _loc7_;
         _loc19_ = _loc16_;
         _loc4_ = _loc4_ + 1;
      }
      _loc38_ = _loc31_ <= 0 ? _loc10_ / 4 : (- _loc10_) / 4;
      _loc41_ = _loc31_ >= 0 ? _loc10_ / 4 : (- _loc10_) / 4;
      _loc30_ = _loc2_[0].ax;
      _loc29_ = _loc2_[0].ay;
      _loc18_ = _loc10_ / 2;
      _loc8_.moveTo(_loc30_,_loc29_);
      _loc8_.lineStyle(_loc36_,_loc35_,_loc37_);
      _loc3_.moveTo(_loc30_,_loc29_);
      _loc3_.beginFill(_loc33_,_loc34_);
      _loc5_.moveTo(_loc30_,_loc29_);
      _loc5_.beginFill(_loc39_,_loc40_);
      _loc4_ = 1;
      while(_loc4_ < _loc2_.length)
      {
         _loc13_ = _loc2_[_loc4_].cx;
         _loc12_ = _loc2_[_loc4_].cy;
         _loc15_ = _loc2_[_loc4_ + 1].ax;
         _loc14_ = _loc2_[_loc4_ + 1].ay;
         _loc8_.curveTo(_loc13_,_loc12_,_loc15_,_loc14_);
         _loc3_.curveTo(_loc13_,_loc12_,_loc15_,_loc14_);
         _loc5_.curveTo(_loc13_,_loc12_,_loc15_,_loc14_);
         _loc4_ += 2;
      }
      _loc4_ = _loc2_.length - 2;
      while(_loc4_ > 0)
      {
         _loc13_ = _loc18_ - _loc2_[_loc4_].cx;
         _loc12_ = - _loc2_[_loc4_].cy;
         _loc15_ = _loc18_ - _loc2_[_loc4_ - 1].ax;
         _loc14_ = - _loc2_[_loc4_ - 1].ay;
         _loc8_.curveTo(_loc13_,_loc12_,_loc15_,_loc14_);
         _loc3_.curveTo(_loc13_,_loc12_,_loc15_,_loc14_);
         _loc5_.curveTo(_loc13_,_loc12_,_loc15_,_loc14_);
         _loc4_ -= 2;
      }
      _loc4_ = 1;
      while(_loc4_ < _loc2_.length)
      {
         _loc13_ = _loc18_ + _loc2_[_loc4_].cx;
         _loc12_ = - _loc2_[_loc4_].cy;
         _loc15_ = _loc18_ + _loc2_[_loc4_ + 1].ax;
         _loc14_ = - _loc2_[_loc4_ + 1].ay;
         _loc8_.curveTo(_loc13_,_loc12_,_loc15_,_loc14_);
         _loc3_.curveTo(_loc13_,_loc12_,_loc15_,_loc14_);
         _loc5_.curveTo(_loc13_,_loc12_,_loc15_,_loc14_);
         _loc4_ += 2;
      }
      _loc4_ = _loc2_.length - 2;
      while(_loc4_ > 0)
      {
         _loc13_ = _loc10_ - _loc2_[_loc4_].cx;
         _loc12_ = _loc2_[_loc4_].cy;
         _loc15_ = _loc10_ - _loc2_[_loc4_ - 1].ax;
         _loc14_ = _loc2_[_loc4_ - 1].ay;
         _loc8_.curveTo(_loc13_,_loc12_,_loc15_,_loc14_);
         _loc3_.curveTo(_loc13_,_loc12_,_loc15_,_loc14_);
         _loc5_.curveTo(_loc13_,_loc12_,_loc15_,_loc14_);
         _loc4_ -= 2;
      }
      _loc3_.lineTo(_loc10_,_loc41_);
      _loc3_.lineTo(0,_loc41_);
      _loc3_.lineTo(_loc30_,_loc29_);
      _loc3_.endFill();
      _loc5_.lineTo(_loc10_,_loc38_);
      _loc5_.lineTo(0,_loc38_);
      _loc5_.lineTo(_loc30_,_loc29_);
      _loc5_.endFill();
   }
   _loc3_.duplicateMovieClip("n1",101);
   _loc3_.duplicateMovieClip("n2",102);
   _loc5_.duplicateMovieClip("d1",201);
   _loc5_.duplicateMovieClip("d2",202);
   _loc8_.duplicateMovieClip("t1",301);
   _loc8_.duplicateMovieClip("t2",302);
   this.updateDayAndNightRegionsOffset();
   this.maskedAreaMC.mapMC_Night.setMask(this.maskedAreaMC.nightMask);
};
p.updateDayAndNightRegionsOffset = function()
{
   var _loc4_;
   if(this.allowDragging)
   {
      _loc4_ = 0;
   }
   else
   {
      _loc4_ = this._sunLatitude;
   }
   var _loc3_ = this.mapWidth;
   var _loc2_ = _loc3_ * ((this._sunLongitude / 360 % 1 + 1) % 1) + _loc4_;
   this.maskedAreaMC.nightMask.n0._x = _loc2_ - _loc3_;
   this.maskedAreaMC.nightMask.n1._x = _loc2_;
   this.maskedAreaMC.nightMask.n2._x = _loc2_ + _loc3_;
   this.maskedAreaMC.nightMask._y += this.mapheight / 2;
   this.maskedAreaMC.dayAndNightRegionsMC.d0._x = _loc2_ - _loc3_;
   this.maskedAreaMC.dayAndNightRegionsMC.d1._x = _loc2_;
   this.maskedAreaMC.dayAndNightRegionsMC.d2._x = _loc2_ + _loc3_;
   this.maskedAreaMC.dayAndNightRegionsMC.t0._x = _loc2_ - _loc3_;
   this.maskedAreaMC.dayAndNightRegionsMC.t1._x = _loc2_;
   this.maskedAreaMC.dayAndNightRegionsMC.t2._x = _loc2_ + _loc3_;
   trace("Night1=" + this.maskedAreaMC.nightMask.n0._x);
   trace("Night2=" + this.maskedAreaMC.dayAndNightRegionsMC.d1._x);
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
   if(!isNaN(arg) && isFinite(arg))
   {
      this._sunLongitude = arg;
      this.updateDayAndNightRegionsOffset();
   }
};
p.addProperty("sunLongitude",p.getSunLongitude,p.setSunLongitude);
p.getSunLatitude = function()
{
   return this._sunLatitude;
};
p.setSunLatitude = function(arg)
{
   if(!isNaN(arg) && isFinite(arg))
   {
      this._sunLatitude = arg;
      this.updateDayAndNightRegionsOffset();
   }
};
p.addProperty("sunLatitude",p.getSunLatitude,p.setSunLatitude);
p.getSunDeclination = function()
{
   return this._sunDeclination;
};
p.setSunDeclination = function(arg)
{
   if(!isNaN(arg) && isFinite(arg))
   {
      this._sunDeclination = arg;
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
   if(!isNaN(arg) && isFinite(arg))
   {
      trace("Drag OFFset" + arg);
      this._offset = (arg % 360 + 360) % 360;
      trace("Drag OFFset" + this._offset);
      this.maskedAreaMC._x = (- (this._offset + 180)) * (this.mapWidth / 360) % this.mapWidth;
      trace("Drag OFFset" + this.maskedAreaMC._x);
      trace("Latitiude" + this._sunLatitude);
      this.horizontalBorderMC._x = this.maskedAreaMC._x;
      this.updateDayAndNightRegions();
      this.updateBorderLabels();
   }
};
p.addProperty("longitudeOffset",p.getLongitudeOffset,p.setLongitudeOffset);
p.getAllowDragging = function()
{
   return this.maskMC.onPress == this.dragOnPress;
};
p.setAllowDragging = function(arg)
{
   this.maskMC.useHandCursor = false;
   this.maskMC.tabEnabled = false;
   if(arg)
   {
      this.maskMC.onPress = this.dragOnPress;
      this.maskMC.onRelease = this.dragOnRelease;
      this.maskMC.onReleaseOutside = this.dragOnRelease;
      this.maskMC.onMouseMoveFunc = this.dragOnMouseMoveFunc;
   }
   else
   {
      delete this.maskMC.onPress;
      delete this.maskMC.onRelease;
      delete this.maskMC.onReleaseOutside;
      delete this.maskMC.onMouseMoveFunc;
   }
};
p.addProperty("allowDragging",p.getAllowDragging,p.setAllowDragging);
p.dragOnPress = function()
{
   this.initXMouse = this._xmouse;
   this.initOffset = this._parent._offset;
   this.onMouseMove = this.onMouseMoveFunc;
};
p.dragOnMouseMoveFunc = function()
{
   var _loc2_ = this.initOffset - (this._xmouse - this.initXMouse) * (360 / this._parent.mapWidth);
   this._parent.setLongitudeOffset(_loc2_);
   this._parent._parent[this._parent.onDragHandler](this._parent._offset);
   updateAfterEvent();
};
p.dragOnRelease = function()
{
   delete this.onMouseMove;
};
p.IDLList_withKiribati = [{lat:90,lon:180},{lat:75,lon:180},{lat:72,lon:-169},{lat:65.5,lon:-169},{lat:64,lon:-175},{lat:50.5,lon:167},{lat:48,lon:180},{lat:2,lon:180},{lat:0,lon:-179},{lat:0,lon:-165},{lat:-3,lon:-165},{lat:-3,lon:-160},{lat:2,lon:-160},{lat:2,lon:-162},{lat:5,lon:-162},{lat:5,lon:-154},{lat:-8,lon:-151},{lat:-12,lon:-151},{lat:-12,lon:-157},{lat:-9,lon:-157},{lat:-9,lon:-178},{lat:-15,lon:-175.5},{lat:-44.75,lon:-175.5},{lat:-51.5,lon:180},{lat:-90,lon:180}];
p.IDLList_withoutKiribati = [{lat:90,lon:180},{lat:75,lon:180},{lat:72,lon:-169},{lat:65.5,lon:-169},{lat:64,lon:-175},{lat:50.5,lon:167},{lat:48,lon:180},{lat:-5,lon:180},{lat:-15,lon:-175.5},{lat:-44.75,lon:-175.5},{lat:-51.5,lon:180},{lat:-90,lon:180}];
