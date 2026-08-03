function DaylightHoursPlotClass()
{
   this.init();
}
var p = DaylightHoursPlotClass.prototype = new MovieClip();
Object.registerClass("Daylight Hours Plot",DaylightHoursPlotClass);
p.plotWidth = 500;
p.plotHeight = 300;
p.borderThickness = 1;
p.borderColor = 0;
p.borderAlpha = 100;
p.backgroundColor = 11579568;
p.backgroundAlpha = 100;
p.curveThickness = 1;
p.curveColor = 4210752;
p.curveAlpha = 100;
p.curveFillColor = 15790272;
p.curveFillAlpha = 100;
p.averageLineThickness = 2;
p.averageLineColor = 6316287;
p.averageLineAlpha = 100;
p.averageLineDashLength = 5;
p.averageLineGapLength = 5;
p.averageLabel = "yearly average";
p.averageLabelColor = 3158256;
p.monthTickmarkLength = 7;
p.monthLabelPlacement = 4;
p.hourTickmarkLength = 6;
p.hourLabelPlacement = 10;
p.hourTickmarksStep = 1;
p.hourTickmarkLabelsList = [0,6,12,18,24];
p.monthAxisLabel = "Day of Year";
p.monthAxisLabelSpacing = 27;
p.hourAxisLabel = "Number of Daylight Hours";
p.hourAxisLabelSpacing = 37;
p.monthsList = [{shortName:"Jan",longName:"January",doy:0},{shortName:"Feb",longName:"February",doy:31},{shortName:"Mar",longName:"March",doy:59},{shortName:"Apr",longName:"April",doy:90},{shortName:"May",longName:"May",doy:120},{shortName:"Jun",longName:"June",doy:151},{shortName:"Jul",longName:"July",doy:181},{shortName:"Aug",longName:"August",doy:212},{shortName:"Sep",longName:"September",doy:243},{shortName:"Oct",longName:"October",doy:273},{shortName:"Nov",longName:"November",doy:304},{shortName:"Dec",longName:"December",doy:334}];
p.doyOffset = -0.3;
p.vernalEquinoxDoy = 78.2440148725013 + p.doyOffset;
p.summerSolsticeDoy = 170.941194534302 + p.doyOffset;
p.autumnalEquinoxDoy = 264.516526602426 + p.doyOffset;
p.winterSolsticeDoy = 354.318929672241 + p.doyOffset;
p.eventLabelSpacing = 23;
p.eventTickmarkLength = 6;
p.eventLabelsList = ["vernal\nequinox","summer\nsolstice","autumnal\nequinox","winter\nsolstice"];
p.eventLabelNames = ["vernalEquinox","summerSolstice","autumnalEquinox","winterSolstice"];
p.eventLabelDoys = [p.vernalEquinoxDoy,p.summerSolsticeDoy,p.autumnalEquinoxDoy,p.winterSolsticeDoy];
p.labelFormat = new TextFormat("Verdana",12,p.borderColor);
p.eventLabelFormat = new TextFormat("Verdana",11,p.borderColor,false,true);
p.eventLabelFormat.align = "center";
p.axisLabelFormat = new TextFormat("Verdana",13,p.borderColor,true);
p.averageLabelFormat = new TextFormat("Verdana",11,p.averageLabelColor,false,true);
p.update = function()
{
   var _loc2_ = this.plotAreaMC;
   _loc2_.clear();
   var _loc9_;
   var _loc24_;
   var _loc6_;
   var _loc22_;
   var _loc10_;
   var _loc21_;
   var _loc15_;
   var _loc20_;
   var _loc18_;
   var _loc17_;
   var _loc23_;
   var _loc3_;
   var _loc19_;
   var _loc4_;
   var _loc26_;
   var _loc25_;
   var _loc5_;
   var _loc16_;
   var _loc12_;
   var _loc13_;
   var _loc14_;
   var _loc8_;
   var _loc11_;
   var _loc7_;
   if(this._latitude == -90)
   {
      _loc9_ = (this.plotWidth / 365 * (this.autumnalEquinoxDoy - this.vernalEquinoxDoy) % this.plotWidth + this.plotWidth) % this.plotWidth;
      _loc2_.moveTo(_loc9_,0);
      _loc2_.beginFill(this.curveFillColor,this.curveFillAlpha);
      _loc2_.lineStyle(this.curveThickness,this.curveColor,this.curveAlpha);
      _loc2_.lineTo(_loc9_,- this.plotHeight);
      _loc2_.lineStyle();
      _loc2_.lineTo(this.plotWidth,- this.plotHeight);
      _loc2_.lineTo(this.plotWidth,0);
      _loc2_.lineTo(_loc9_,0);
      _loc2_.endFill();
   }
   else if(this._latitude == 90)
   {
      _loc9_ = (this.plotWidth / 365 * (this.autumnalEquinoxDoy - this.vernalEquinoxDoy) % this.plotWidth + this.plotWidth) % this.plotWidth;
      _loc2_.moveTo(0,0);
      _loc2_.beginFill(this.curveFillColor,this.curveFillAlpha);
      _loc2_.lineTo(0,- this.plotHeight);
      _loc2_.lineTo(_loc9_,- this.plotHeight);
      _loc2_.lineStyle(this.curveThickness,this.curveColor,this.curveAlpha);
      _loc2_.lineTo(_loc9_,0);
      _loc2_.lineStyle();
      _loc2_.lineTo(0,0);
      _loc2_.endFill();
   }
   else
   {
      _loc24_ = Math.tan;
      _loc6_ = Math.sin;
      _loc22_ = Math.asin;
      _loc10_ = Math.cos;
      _loc21_ = Math.atan2;
      _loc15_ = this._latitude * 0.017453292519943295;
      _loc20_ = Math.tan(_loc15_);
      _loc18_ = (- this.plotHeight) / 24;
      _loc17_ = this.plotWidth;
      _loc9_ = 0;
      _loc23_ = this.plotWidth / _loc17_;
      _loc3_ = this.vernalEquinoxDoy - this.doyOffset;
      _loc19_ = 365 / _loc17_;
      _loc4_ = this.getDaylightHours(_loc15_,this.getSunDeclination(_loc3_ + this.doyOffset));
      _loc26_ = _loc9_;
      _loc25_ = _loc18_ * _loc4_;
      _loc2_.moveTo(_loc26_,_loc25_);
      _loc2_.beginFill(this.curveFillColor,this.curveFillAlpha);
      _loc5_ = _loc4_ != 0 && _loc4_ != 24;
      if(_loc5_)
      {
         _loc2_.lineStyle(this.curveThickness,this.curveColor,this.curveAlpha);
      }
      _loc16_ = _loc4_;
      _loc12_ = 0;
      while(_loc12_ < _loc17_)
      {
         _loc9_ += _loc23_;
         _loc3_ += _loc19_;
         _loc13_ = -0.0000043796019 + 0.001830724 * _loc10_(0.017214206 * _loc3_) - 0.032070267 * _loc6_(0.017214206 * _loc3_) - 0.015952904 * _loc10_(0.034428413 * _loc3_) - 0.04026479 * _loc6_(0.034428413 * _loc3_) - 0.00044373354 * _loc10_(0.051642619 * _loc3_) - 0.0013114725 * _loc6_(0.051642619 * _loc3_) - 0.00064591583 * _loc10_(0.068856825 * _loc3_) - 0.00070547099 * _loc6_(0.068856825 * _loc3_);
         _loc14_ = 0.01721421 * _loc3_ - 1.3793799796 - _loc13_;
         _loc8_ = _loc21_(_loc6_(_loc14_),2.30644456403329);
         _loc11_ = _loc22_((- _loc20_) * _loc24_(_loc8_));
         if(isNaN(_loc11_))
         {
            _loc4_ = !(_loc8_ > 0 && _loc15_ > 0 || _loc8_ < 0 && _loc15_ < 0) ? 0 : 24;
         }
         else
         {
            _loc4_ = 24 * (-2 * _loc11_ + 3.141592653589793) / 6.283185307179586;
         }
         _loc7_ = _loc18_ * _loc4_;
         if(_loc4_ == 24 || _loc4_ == 0)
         {
            if(_loc4_ != _loc16_)
            {
               _loc5_ = true;
               _loc2_.lineStyle(this.curveThickness,this.curveColor,this.curveAlpha);
            }
            _loc2_.lineTo(_loc9_,_loc7_);
            if(_loc5_)
            {
               _loc5_ = false;
               _loc2_.lineStyle();
            }
         }
         else if(!_loc5_)
         {
            _loc5_ = true;
            _loc2_.lineStyle(this.curveThickness,this.curveColor,this.curveAlpha);
            _loc2_.lineTo(_loc9_,_loc7_);
         }
         else
         {
            _loc2_.lineTo(_loc9_,_loc7_);
         }
         _loc16_ = _loc4_;
         _loc12_ = _loc12_ + 1;
      }
      _loc2_.lineStyle();
      _loc2_.lineTo(this.plotWidth,0);
      _loc2_.lineTo(0,0);
      _loc2_.lineTo(_loc26_,_loc25_);
      _loc2_.endFill();
   }
};
p.getShowAverage = function()
{
   return this.averageMC._visible;
};
p.setShowAverage = function(arg)
{
   this.averageMC._visible = arg;
};
p.addProperty("showAverage",p.getShowAverage,p.setShowAverage);
p.getLatitude = function()
{
   return this._latitude;
};
p.setLatitude = function(arg)
{
   this._latitude = arg;
   this.update();
};
p.addProperty("latitude",p.getLatitude,p.setLatitude);
p.getSunDeclination = function(doy)
{
   doy -= this.doyOffset;
   var _loc3_ = Math.sin;
   var _loc4_ = Math.cos;
   var _loc5_ = -0.0000043796019 + 0.001830724 * _loc4_(0.017214206 * doy) - 0.032070267 * _loc3_(0.017214206 * doy) - 0.015952904 * _loc4_(0.034428413 * doy) - 0.04026479 * _loc3_(0.034428413 * doy) - 0.00044373354 * _loc4_(0.051642619 * doy) - 0.0013114725 * _loc3_(0.051642619 * doy) - 0.00064591583 * _loc4_(0.068856825 * doy) - 0.00070547099 * _loc3_(0.068856825 * doy);
   var _loc6_ = 0.01721421 * doy - 1.3793799796 - _loc5_;
   return Math.atan2(_loc3_(_loc6_),2.30644456403329);
};
p.getDaylightHours = function(latitude, sunDeclination)
{
   var _loc4_ = (- Math.tan(latitude)) * Math.tan(sunDeclination);
   var _loc2_ = Math.asin(_loc4_);
   var _loc5_;
   if(isNaN(_loc2_))
   {
      if(Math.abs(sunDeclination) < 0.000001)
      {
         _loc5_ = 12;
      }
      else
      {
         _loc5_ = !(sunDeclination > 0 && latitude > 0 || sunDeclination < 0 && latitude < 0) ? 0 : 24;
      }
   }
   else
   {
      _loc5_ = 24 * (-2 * _loc2_ + 3.141592653589793) / 6.283185307179586;
   }
   return _loc5_;
};
p.init = function()
{
   this.createEmptyMovieClip("backgroundMC",1);
   this.createEmptyMovieClip("labelsMC",5);
   this.createEmptyMovieClip("plotAreaMC",10);
   this.createEmptyMovieClip("plotAreaMaskMC",11);
   this.createEmptyMovieClip("averageMC",15);
   this.createEmptyMovieClip("borderMC",20);
   this.averageMC._visible = false;
   this.plotAreaMC.setMask(this.plotAreaMaskMC);
   this.borderMC.lineStyle(this.borderThickness,this.borderColor,this.borderAlpha);
   this.borderMC.moveTo(0,0);
   this.borderMC.lineTo(this.plotWidth,0);
   this.borderMC.lineTo(this.plotWidth,- this.plotHeight);
   this.borderMC.lineTo(0,- this.plotHeight);
   this.borderMC.lineTo(0,0);
   this.backgroundMC.moveTo(0,0);
   this.backgroundMC.beginFill(this.backgroundColor,this.backgroundAlpha);
   this.backgroundMC.lineTo(this.plotWidth,0);
   this.backgroundMC.lineTo(this.plotWidth,- this.plotHeight);
   this.backgroundMC.lineTo(0,- this.plotHeight);
   this.backgroundMC.lineTo(0,0);
   this.backgroundMC.endFill();
   this.plotAreaMaskMC.moveTo(0,0);
   this.plotAreaMaskMC.beginFill(16711680);
   this.plotAreaMaskMC.lineTo(this.plotWidth,0);
   this.plotAreaMaskMC.lineTo(this.plotWidth,- this.plotHeight);
   this.plotAreaMaskMC.lineTo(0,- this.plotHeight);
   this.plotAreaMaskMC.lineTo(0,0);
   this.plotAreaMaskMC.endFill();
   var _loc7_ = this.plotWidth / 365;
   this.labelsMC.lineStyle(this.borderThickness,this.borderColor,this.borderAlpha);
   this.averageMC.lineStyle(this.averageLineThickness,this.averageLineColor,this.averageLineAlpha);
   this.drawDashedLine.call(this.averageMC,0,(- this.plotHeight) / 2,this.plotWidth,(- this.plotHeight) / 2,this.averageLineDashLength,this.averageLineGapLength);
   this.displayText(this.averageLabel,{mc:this.averageMC,depth:100,x:8,y:- this.plotHeight / 2 + 4,vAlign:"top",hAlign:"left",embedFonts:true,textFormat:this.averageLabelFormat});
   var _loc2_ = 0;
   var _loc17_;
   while(_loc2_ < 4)
   {
      _loc17_ = (_loc7_ * (this.eventLabelDoys[_loc2_] - this.vernalEquinoxDoy) % this.plotWidth + this.plotWidth) % this.plotWidth;
      this.labelsMC.moveTo(_loc17_,- this.plotHeight);
      this.labelsMC.lineTo(_loc17_,- this.plotHeight - this.eventTickmarkLength);
      this.displayText(this.eventLabelsList[_loc2_],{name:this.eventLabelNames[_loc2_],mc:this.labelsMC,depth:5000 + _loc2_,x:_loc17_,y:- this.plotHeight - this.eventLabelSpacing,vAlign:"bottom",hAlign:"center",embedFonts:true,textFormat:this.eventLabelFormat});
      this.labelsMC[this.eventLabelNames[_loc2_]].eventDoy = this.eventLabelDoys[_loc2_];
      _loc2_ = _loc2_ + 1;
   }
   var _loc3_ = (_loc7_ * (this.monthsList[0].doy - this.vernalEquinoxDoy) % this.plotWidth + this.plotWidth) % this.plotWidth;
   _loc2_ = this.monthsList.length - 1;
   var _loc4_;
   var _loc6_;
   while(_loc2_ >= 0)
   {
      _loc4_ = this.monthsList[_loc2_];
      _loc17_ = (_loc7_ * (_loc4_.doy - this.vernalEquinoxDoy) % this.plotWidth + this.plotWidth) % this.plotWidth;
      this.labelsMC.moveTo(_loc17_,0);
      this.labelsMC.lineTo(_loc17_,this.monthTickmarkLength);
      if(_loc17_ > _loc3_)
      {
         _loc6_ = _loc17_ + (this.plotWidth + _loc3_ - _loc17_) / 2;
      }
      else
      {
         _loc6_ = _loc17_ + (_loc3_ - _loc17_) / 2;
      }
      this.displayText(_loc4_.shortName,{mc:this.labelsMC,depth:1000 + _loc2_,x:_loc6_,y:this.monthLabelPlacement,vAlign:"top",hAlign:"center",embedFonts:true,textFormat:this.labelFormat});
      _loc3_ = _loc17_;
      _loc2_ = _loc2_ - 1;
   }
   var _loc10_ = 1 + 24 / this.hourTickmarksStep;
   var _loc8_ = (- this.plotHeight) / 24;
   var _loc5_ = 0;
   _loc2_ = 0;
   var _loc16_;
   while(_loc2_ < _loc10_)
   {
      _loc16_ = _loc8_ * _loc5_;
      this.labelsMC.moveTo(0,_loc16_);
      this.labelsMC.lineTo(- this.hourTickmarkLength,_loc16_);
      _loc5_ += this.hourTickmarksStep;
      _loc2_ = _loc2_ + 1;
   }
   _loc2_ = 0;
   while(_loc2_ < this.hourTickmarkLabelsList.length)
   {
      _loc5_ = this.hourTickmarkLabelsList[_loc2_];
      _loc16_ = _loc8_ * _loc5_;
      this.displayText(_loc5_,{mc:this.labelsMC,depth:2000 + _loc2_,x:- this.hourLabelPlacement,y:_loc16_,vAlign:"center",hAlign:"right",embedFonts:true,textFormat:this.labelFormat});
      _loc2_ = _loc2_ + 1;
   }
   this.displayText(this.monthAxisLabel,{mc:this.labelsMC,depth:3000,x:this.plotWidth / 2,y:this.monthAxisLabelSpacing,vAlign:"top",hAlign:"center",embedFonts:true,textFormat:this.axisLabelFormat});
   this.displayText(this.hourAxisLabel,{mc:this.labelsMC,depth:4000,x:- this.hourAxisLabelSpacing,y:(- this.plotHeight) / 2,vAlign:"bottom",hAlign:"center",embedFonts:true,textFormat:this.axisLabelFormat})._rotation = -90;
};
p.drawDashedLine = function(startX, startY, endX, endY, dashLength, gapLength)
{
   var _loc14_ = endX - startX;
   var _loc13_ = endY - startY;
   var _loc16_ = Math.sqrt(_loc14_ * _loc14_ + _loc13_ * _loc13_);
   var _loc5_ = Math.round((_loc16_ - dashLength) / (dashLength + gapLength));
   var _loc12_ = dashLength / (dashLength + gapLength);
   var _loc7_ = _loc14_ / (_loc5_ + _loc12_);
   var _loc6_ = _loc13_ / (_loc5_ + _loc12_);
   var _loc9_ = _loc12_ * _loc7_;
   var _loc8_ = _loc12_ * _loc6_;
   var _loc2_ = 0;
   var _loc4_;
   var _loc3_;
   while(_loc2_ <= _loc5_)
   {
      _loc4_ = startX + _loc2_ * _loc7_;
      _loc3_ = startY + _loc2_ * _loc6_;
      this.moveTo(_loc4_,_loc3_);
      this.lineTo(_loc4_ + _loc9_,_loc3_ + _loc8_);
      _loc2_ = _loc2_ + 1;
   }
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
