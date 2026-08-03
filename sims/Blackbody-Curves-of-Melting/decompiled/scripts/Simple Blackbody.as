function SimpleBlackbodyClass()
{
   if(this.width == undefined)
   {
      this.width = this._width;
   }
   if(this.height == undefined)
   {
      this.height = this._height;
   }
   this._xscale = 100;
   this._yscale = 100;
   this._placeholderMC._visible = false;
   this._placeholderMC.swapDepths(121212);
   this._placeholderMC.removeMovieClip();
   this.createEmptyMovieClip("_backgroundMC",10);
   this.createEmptyMovieClip("_curvesMC",20);
   this.createEmptyMovieClip("_curvesMaskMC",30);
   this.createEmptyMovieClip("_borderMC",40);
   this.createEmptyMovieClip("_axesMC",50);
   this._axesMC.createEmptyMovieClip("_visSpectrumMC",1);
   this._axesMC.createEmptyMovieClip("_yAxisMC",3);
   this._curvesMC.setMask(this._curvesMaskMC);
   this._topCurveDepth = 0;
   this._curvesList = [];
   this._yLabelCount = 0;
   if(this.minWavelength == undefined)
   {
      this.minWavelength = 1e-7;
   }
   if(this.maxWavelength == undefined)
   {
      this.maxWavelength = 9e-7;
   }
   if(this.bbCurveTemp == undefined)
   {
      this.bbCurveTemp = "";
   }
   if(this.bbCurveThickness == undefined)
   {
      this.bbCurveThickness = 1;
   }
   if(this.bbCurveColor == undefined)
   {
      this.bbCurveColor = 0;
   }
   if(this.bbCurveAlpha == undefined)
   {
      this.bbCurveAlpha = 100;
   }
   if(this.showVisibleSpectrum == undefined)
   {
      this.showVisibleSpectrum = true;
   }
   if(this.showXAxis == undefined)
   {
      this.showXAxis = true;
   }
   if(this.showYAxis == undefined)
   {
      this.showYAxis = true;
   }
   if(this.axesThickness == undefined)
   {
      this.axesThickness = 1;
   }
   if(this.axesColor == undefined)
   {
      this.axesColor = 0;
   }
   if(this.axesAlpha == undefined)
   {
      this.axesAlpha = 100;
   }
   if(this.initAxesLabelColor == undefined)
   {
      this.initAxesLabelColor = 0;
   }
   if(this.showBorder == undefined)
   {
      this.showBorder = false;
   }
   if(this.borderThickness == undefined)
   {
      this.borderThickness = 1;
   }
   if(this.borderColor == undefined)
   {
      this.borderColor = 13421772;
   }
   if(this.borderAlpha == undefined)
   {
      this.borderAlpha = 100;
   }
   if(this.majorTickmarkExtent == undefined)
   {
      this.majorTickmarkExtent = 10;
   }
   if(this.minorTickmarkExtent == undefined)
   {
      this.minorTickmarkExtent = 7;
   }
   if(this.xTickLabelSymbol == undefined)
   {
      this.xTickLabelSymbol = "Default X Tickmark Label";
   }
   if(this.yTickLabelSymbol == undefined)
   {
      this.yTickLabelSymbol = "Default Y Tickmark Label";
   }
   if(this.backgroundColor == undefined)
   {
      this.backgroundColor = 16777215;
   }
   if(this.backgroundAlpha == undefined)
   {
      this.backgroundAlpha = 100;
   }
   if(this.minScreenXSpacing == undefined)
   {
      this.minScreenXSpacing = 45;
   }
   if(this.minScreenYSpacing == undefined)
   {
      this.minScreenYSpacing = 30;
   }
   this.maxBrightness = 1000000000000;
   this.setVerticalScalingMode("autoscale");
   var _loc2_ = parseFloat(this.bbCurveTemp);
   if(!isNaN(_loc2_) && isFinite(_loc2_) && _loc2_ > 0)
   {
      this.addCurve("bbCurve",_loc2_,{thickness:this.bbCurveThickness,color:this.bbCurveColor,alpha:this.bbCurveAlpha});
   }
   this.update(true);
   this.setAxesLabelColor(this.initAxesLabelColor);
}
function SimpleBlackbodyCurveClass(parent, id, mc, name, temp, style)
{
   this._parent = parent;
   this._id = id;
   this._mc = mc;
   this._name = name;
   this.showFill = false;
   this.setTemperature(temp);
   this.peakHeight = 0.9;
   this._thick = 1;
   this._color = 0;
   this._alpha = 100;
   this._fillColor = 16711680;
   this._fillAlpha = 20;
   this.setStyle(style);
}
var p = SimpleBlackbodyClass.prototype = new MovieClip();
Object.registerClass("Simple Blackbody",SimpleBlackbodyClass);
p.addCurve = function(name, temp, style)
{
   var _loc5_ = this._curvesList.length;
   var _loc2_ = this._topCurveDepth++;
   var _loc4_ = this._curvesMC.createEmptyMovieClip("_" + _loc2_,_loc2_);
   this[name] = new SimpleBlackbodyCurveClass(this,_loc5_,_loc4_,name,temp,style);
   this._curvesList.push(this[name]);
};
p.setVerticalScalingMode = function(mode, targetHeight, curves)
{
   var _loc2_;
   if(mode == "locked")
   {
      this._vScaleMode = 0;
   }
   else if(mode == "autoscale")
   {
      this._vScaleMode = 1;
      if(curves != undefined)
      {
         if(typeof curves == "string")
         {
            this._vScaleCurves = [this[curves]];
         }
         else
         {
            this._vScaleCurves = [];
            _loc2_ = 0;
            while(_loc2_ < curves.length)
            {
               this._vScaleCurves.push(this[curves[_loc2_]]);
               _loc2_ = _loc2_ + 1;
            }
         }
      }
      else
      {
         this._vScaleCurves = this._curvesList;
      }
      if(typeof targetHeight == "number")
      {
         this._vTarget = targetHeight;
      }
      else
      {
         this._vTarget = 0.9;
      }
   }
   else if(mode == "custom")
   {
      this._vScaleMode = 2;
   }
};
p.update = function(updateEverything)
{
   this.updateScale();
   if(updateEverything)
   {
      this.updateLayout();
      this.updateHorizontalAxis();
   }
   this.updateVerticalAxis();
   this.updateCurves();
};
p.updateLayout = function()
{
   var _loc6_ = this.width;
   var _loc5_ = - this.height;
   var _loc3_ = this._backgroundMC;
   _loc3_.clear();
   _loc3_.moveTo(0,0);
   _loc3_.beginFill(this.backgroundColor,this.backgroundAlpha);
   _loc3_.lineTo(_loc6_,0);
   _loc3_.lineTo(_loc6_,_loc5_);
   _loc3_.lineTo(0,_loc5_);
   _loc3_.lineTo(0,0);
   _loc3_.endFill();
   var _loc2_ = this._curvesMaskMC;
   _loc2_.clear();
   _loc2_.moveTo(0,0);
   _loc2_.beginFill(16711680);
   _loc2_.lineTo(_loc6_,0);
   _loc2_.lineTo(_loc6_,_loc5_);
   _loc2_.lineTo(0,_loc5_);
   _loc2_.lineTo(0,0);
   _loc2_.endFill();
   var _loc4_ = this._borderMC;
   _loc4_.clear();
   if(this.showBorder)
   {
      _loc4_.lineStyle(this.borderThickness,this.borderColor,this.borderAlpha);
      _loc4_.moveTo(0,0);
      _loc4_.lineTo(_loc6_,0);
      _loc4_.lineTo(_loc6_,_loc5_);
      _loc4_.lineTo(0,_loc5_);
      _loc4_.lineTo(0,0);
   }
};
p.updateScale = function()
{
   var _loc5_;
   var _loc4_;
   var _loc3_;
   var _loc2_;
   var _loc8_;
   var _loc7_;
   var _loc9_;
   var _loc6_;
   if(this._vScaleMode == 1)
   {
      _loc5_ = this._vScaleCurves;
      _loc4_ = 0;
      _loc3_ = 0;
      while(_loc3_ < _loc5_.length)
      {
         _loc2_ = _loc5_[_loc3_]._temp;
         if(_loc2_ != null && _loc2_ > _loc4_)
         {
            _loc4_ = _loc2_;
         }
         _loc3_ = _loc3_ + 1;
      }
      _loc8_ = 1.1910425859324616e-16;
      _loc7_ = 0.014387750559248378;
      _loc9_ = 0.0028977682864295084;
      _loc6_ = _loc9_ / _loc4_;
      if(_loc6_ < this.minWavelength)
      {
         _loc6_ = this.minWavelength;
      }
      else if(_loc6_ > this.maxWavelength)
      {
         _loc6_ = this.maxWavelength;
      }
      this.maxBrightness = _loc8_ / (Math.pow(_loc6_,5) * (Math.exp(_loc7_ / (_loc6_ * _loc4_)) - 1)) / this._vTarget;
   }
   this._vScale = (- this.height) / this.maxBrightness;
   this._hRange = this.maxWavelength - this.minWavelength;
   this._hScale = this.width / this._hRange;
};
p.updateVerticalAxis = function()
{
   var _loc21_ = Math.pow;
   var _loc22_ = Math.log;
   var _loc7_ = this.majorTickmarkExtent;
   var _loc14_ = this.minorTickmarkExtent;
   var _loc20_ = this.maxBrightness;
   var _loc18_ = this.height / _loc20_;
   var _loc2_ = this._axesMC._yAxisMC;
   _loc2_.clear();
   _loc2_.lineStyle(this.axesThickness,this.axesColor,this.axesAlpha);
   var _loc6_ = 0;
   var _loc19_;
   var _loc17_;
   var _loc13_;
   var _loc12_;
   var _loc16_;
   var _loc15_;
   var _loc5_;
   var _loc3_;
   var _loc8_;
   var _loc4_;
   if(this.showYAxis && _loc18_ > 0)
   {
      if(this._vScaleMode != 2)
      {
         _loc19_ = this.minScreenYSpacing / _loc18_;
         _loc17_ = _loc21_(10,Math.ceil(_loc22_(_loc19_) / 2.302585092994046));
         if(_loc17_ / 2 > _loc19_)
         {
            _loc17_ /= 2;
            _loc13_ = 5;
         }
         else
         {
            _loc13_ = 2;
         }
         _loc12_ = _loc17_ / _loc13_;
         _loc16_ = _loc12_ * _loc18_;
         _loc15_ = 1 + Math.floor(_loc20_ / _loc12_);
         _loc5_ = 0;
         while(_loc5_ < _loc15_)
         {
            _loc3_ = (- _loc5_) * _loc16_;
            if(_loc5_ % _loc13_ == 0)
            {
               _loc2_.moveTo(- _loc7_,_loc3_);
               _loc2_.lineTo(0,_loc3_);
               _loc8_ = _loc12_ * _loc5_;
               if(_loc6_ < this._yLabelCount)
               {
                  _loc4_ = _loc2_["_" + _loc6_];
                  _loc4_.setValue(_loc8_);
                  _loc4_._visible = true;
                  _loc4_._x = - _loc7_;
                  _loc4_._y = _loc3_;
               }
               else
               {
                  _loc2_.attachMovie(this.yTickLabelSymbol,"_" + this._yLabelCount,this._yLabelCount,{labelColor:this._axesLabelColor,_x:- _loc7_,_y:_loc3_,value:_loc8_});
                  this._yLabelCount = this._yLabelCount + 1;
               }
               _loc6_ = _loc6_ + 1;
            }
            else
            {
               _loc2_.moveTo(- _loc14_,_loc3_);
               _loc2_.lineTo(0,_loc3_);
            }
            _loc5_ = _loc5_ + 1;
         }
      }
      _loc2_.moveTo(0,0);
      _loc2_.lineTo(0,- this.height);
   }
   _loc5_ = _loc6_;
   while(_loc5_ < this._yLabelCount)
   {
      _loc2_["_" + _loc5_]._visible = false;
      _loc5_ = _loc5_ + 1;
   }
};
p.updateHorizontalAxis = function()
{
   var _loc18_ = Math.pow;
   var _loc21_ = Math.log;
   var _loc9_ = this.majorTickmarkExtent;
   var _loc17_ = this.minorTickmarkExtent;
   var _loc26_ = this.minWavelength;
   var _loc28_ = this.maxWavelength;
   var _loc22_ = this.width / (_loc28_ - _loc26_);
   var _loc16_ = this._axesMC.createEmptyMovieClip("_xAxisMC",2);
   var _loc29_;
   var _loc27_;
   var _loc20_;
   var _loc12_;
   var _loc25_;
   var _loc19_;
   var _loc24_;
   var _loc4_;
   var _loc10_;
   var _loc7_;
   var _loc23_;
   var _loc38_;
   var _loc3_;
   var _loc5_;
   var _loc6_;
   var _loc2_;
   var _loc8_;
   if(this.showXAxis && _loc22_ > 0)
   {
      _loc29_ = this.minScreenXSpacing / _loc22_;
      _loc27_ = _loc18_(10,Math.ceil(_loc21_(_loc29_) / 2.302585092994046));
      if(_loc27_ / 2 > _loc29_)
      {
         _loc27_ /= 2;
         _loc20_ = 5;
      }
      else
      {
         _loc20_ = 2;
      }
      _loc12_ = _loc27_ / _loc20_;
      _loc25_ = _loc12_ * _loc22_;
      _loc19_ = Math.ceil(_loc26_ / _loc12_);
      _loc24_ = 1 + Math.floor(_loc28_ / _loc12_);
      _loc4_ = this.SIPrefixesTable;
      _loc10_ = _loc4_.length - 1;
      _loc7_ = 0;
      _loc23_ = this.xTickLabelSymbol;
      _loc16_.lineStyle(this.axesThickness,this.axesColor,this.axesAlpha);
      _loc38_ = _loc22_ * (_loc12_ * _loc19_ - _loc26_);
      _loc3_ = _loc19_;
      while(_loc3_ < _loc24_)
      {
         if(_loc3_ % _loc20_ == 0)
         {
            _loc5_ = _loc12_ * _loc3_;
            _loc6_ = _loc21_(_loc5_) / 2.302585092994046;
            if(_loc4_[_loc10_].power > _loc6_)
            {
               _loc2_ = _loc10_;
            }
            else
            {
               _loc2_ = 0;
               while(_loc4_[_loc2_].power > _loc6_)
               {
                  _loc2_ = _loc2_ + 1;
               }
            }
            if(_loc5_ <= 0)
            {
               _loc8_ = "0";
            }
            else
            {
               _loc8_ = String(_loc5_ / _loc18_(10,_loc4_[_loc2_].power)) + " " + _loc4_[_loc2_].prefix + "m";
            }
            _loc16_.moveTo(_loc38_,0);
            _loc16_.lineTo(_loc38_,_loc9_);
            _loc16_.attachMovie(_loc23_,"_" + _loc7_,_loc7_,{labelColor:this._axesLabelColor,_x:_loc38_,_y:_loc9_,labelText:_loc8_});
            _loc7_ = _loc7_ + 1;
         }
         else
         {
            _loc16_.moveTo(_loc38_,0);
            _loc16_.lineTo(_loc38_,_loc17_);
         }
         _loc38_ += _loc25_;
         _loc3_ = _loc3_ + 1;
      }
      _loc16_.moveTo(0,0);
      _loc16_.lineTo(this.width,0);
   }
   _loc16_ = this._axesMC._visSpectrumMC;
   _loc16_.clear();
   var _loc32_;
   var _loc31_;
   var _loc33_;
   var _loc30_;
   if(this.showVisibleSpectrum && 7e-7 > _loc26_ && 4e-7 < _loc28_)
   {
      _loc32_ = [0,255,65535,65280,16776960,16711680,0];
      _loc31_ = [0,90,90,90,90,90,0];
      _loc33_ = [0,48,96,128,160,207,255];
      _loc30_ = {matrixType:"box",x:_loc22_ * (4e-7 - _loc26_),y:0,w:_loc22_ * 3e-7,h:100,r:0};
      _loc16_.beginGradientFill("linear",_loc32_,_loc31_,_loc33_,_loc30_);
      _loc16_.moveTo(0,0);
      _loc16_.lineTo(this.width,0);
      _loc16_.lineTo(this.width,_loc17_);
      _loc16_.lineTo(0,_loc17_);
      _loc16_.lineTo(0,0);
      _loc16_.endFill();
   }
};
p.updateCurves = function()
{
   var _loc3_ = this._curvesList;
   var _loc4_ = this._vScaleMode == 2;
   var _loc2_ = 0;
   while(_loc2_ < _loc3_.length)
   {
      _loc3_[_loc2_].redraw(_loc4_);
      _loc2_ = _loc2_ + 1;
   }
};
p.setAxesLabelColor = function(arg)
{
   this._axesLabelColor = arg;
   var _loc5_ = 0;
   while(_loc5_ < this._yLabelCount)
   {
      this._axesMC._yAxisMC["_" + _loc5_].setLabelColor(arg);
      _loc5_ = _loc5_ + 1;
   }
   _loc5_ = 0;
   var _loc3_ = this._axesMC._xAxisMC;
   var _loc2_ = _loc3_._0;
   while(_loc2_ != undefined)
   {
      _loc2_.setLabelColor(arg);
      _loc2_ = _loc3_["_" + (_loc5_ = _loc5_ + 1)];
   }
};
p.SIPrefixesTable = [{power:24,name:"yotta",prefix:"Y"},{power:21,name:"zetta",prefix:"Z"},{power:18,name:"exa",prefix:"E"},{power:15,name:"peta",prefix:"P"},{power:12,name:"tera",prefix:"T"},{power:9,name:"giga",prefix:"G"},{power:6,name:"mega",prefix:"M"},{power:3,name:"kilo",prefix:"k"},{power:0,name:"",prefix:""},{power:-2,name:"centi",prefix:"c"},{power:-3,name:"milli",prefix:"m"},{power:-6,name:"micro",prefix:"µ"},{power:-9,name:"nano",prefix:"n"},{power:-12,name:"pico",prefix:"p"},{power:-15,name:"femto",prefix:"f"},{power:-18,name:"atto",prefix:"a"},{power:-21,name:"zepto",prefix:"z"},{power:-24,name:"yocto",prefix:"y"}];
var p = SimpleBlackbodyCurveClass.prototype = new Object();
p.remove = function()
{
   this._mc.removeMovieClip();
   var _loc3_ = this._parent._curvesList;
   var _loc5_ = _loc3_.length;
   var _loc2_ = 0;
   while(_loc2_ < _loc5_)
   {
      if(_loc3_[_loc2_] == this)
      {
         _loc3_.splice(_loc2_,1);
         break;
      }
      _loc2_ = _loc2_ + 1;
   }
   var _loc4_ = this._parent._vScaleCurves;
   if(_loc4_ != _loc3_)
   {
      _loc5_ = _loc4_.length;
      _loc2_ = 0;
      if(_loc2_ < _loc5_)
      {
         _loc4_.splice(_loc2_,1);
      }
      if(_loc4_.length == 0)
      {
         this._parent._vScaleCurves = this._parent._curvesList;
      }
   }
   delete this._parent[this._name];
};
p.addPeakLabel = function(linkageName, initObject)
{
   this.peakLabel = this._mc.attachMovie(linkageName,"_labelMC",1,initObject);
   return this.peakLabel;
};
p.getPeakWavelength = function()
{
   return 0.0028977682864295084 / this._temp;
};
p.redraw = function(useCustomScaling)
{
   var _loc9_ = this._mc;
   _loc9_.clear();
   if(!_loc9_._visible)
   {
      return undefined;
   }
   var _loc25_ = this._temp;
   if(_loc25_ == null)
   {
      return undefined;
   }
   var _loc41_ = Math.pow;
   var _loc42_ = Math.exp;
   var _loc45_ = Math.ceil;
   var _loc14_ = Math.sqrt;
   var _loc27_ = 1.1910425859324616e-16;
   var _loc26_ = 0.014387750559248378;
   var _loc53_ = 0.0028977682864295084;
   var _loc39_ = this._parent.minWavelength;
   var _loc47_ = this._parent.maxWavelength;
   var _loc7_ = - this._parent.height - 100;
   var _loc52_ = 12;
   var _loc43_ = (_loc47_ - _loc39_) / _loc52_;
   var _loc44_ = _loc53_ / _loc25_;
   var _loc49_ = _loc44_ - 1000 / _loc25_ * 0.0000011939748395787048;
   var _loc48_ = _loc44_ + 1000 / _loc25_ * 0.0000011848609132537307;
   var _loc51_;
   var _loc30_;
   if(useCustomScaling)
   {
      _loc51_ = _loc27_ / (_loc41_(_loc44_,5) * (_loc42_(_loc26_ / (_loc44_ * _loc25_)) - 1));
      _loc30_ = (- this._parent.height) * this.peakHeight / _loc51_;
   }
   else
   {
      _loc30_ = this._parent._vScale;
   }
   var _loc38_ = this._parent._hScale;
   var _loc50_;
   if(_loc9_._labelMC != undefined)
   {
      if(_loc51_ == undefined)
      {
         _loc44_ = 0.0028977682864295084 / _loc25_;
         _loc51_ = _loc27_ / (Math.pow(_loc44_,5) * (Math.exp(_loc26_ / (_loc44_ * _loc25_)) - 1));
      }
      _loc50_ = _loc30_ * _loc51_;
      if(_loc50_ < _loc7_)
      {
         _loc9_._labelMC._y = _loc7_;
      }
      else
      {
         _loc9_._labelMC._y = _loc50_;
      }
      _loc9_._labelMC._x = _loc38_ * (_loc44_ - this._parent.minWavelength);
   }
   var _loc4_ = 0;
   var _loc3_ = _loc39_;
   var _loc10_ = _loc42_(_loc26_ / (_loc3_ * _loc25_)) - 1;
   var _loc16_ = _loc41_(_loc3_,5);
   var _loc12_ = _loc27_ / (_loc16_ * _loc10_);
   var _loc11_ = _loc27_ / (_loc10_ * _loc3_ * _loc16_) * (-5 + _loc26_ * (_loc10_ + 1) / (_loc3_ * _loc25_ * _loc10_));
   var _loc34_ = _loc3_;
   var _loc35_ = _loc12_;
   var _loc37_ = _loc11_;
   var _loc46_ = _loc12_ * _loc30_;
   var _loc20_ = true;
   if(_loc46_ < _loc7_)
   {
      _loc46_ = _loc7_;
      _loc20_ = false;
   }
   _loc9_.lineStyle(this._thick,this._color,this._alpha);
   _loc9_.moveTo(_loc4_,_loc46_);
   if(this.showFill)
   {
      _loc9_.beginFill(this._fillColor,this._fillAlpha);
   }
   var _loc31_ = _loc4_;
   var _loc33_ = _loc46_;
   var _loc40_ = [];
   if(_loc49_ > _loc39_ && _loc49_ < _loc47_)
   {
      _loc40_.push(_loc49_);
   }
   if(_loc44_ > _loc39_ && _loc44_ < _loc47_)
   {
      _loc40_.push(_loc44_);
   }
   if(_loc48_ > _loc39_ && _loc48_ < _loc47_)
   {
      _loc40_.push(_loc48_);
   }
   _loc40_.push(_loc47_);
   var _loc29_ = 0;
   var _loc32_;
   var _loc19_;
   var _loc28_;
   var _loc36_;
   var _loc18_;
   var _loc2_;
   var _loc17_;
   var _loc23_;
   var _loc22_;
   var _loc21_;
   var _loc13_;
   var _loc5_;
   var _loc15_;
   var _loc6_;
   var _loc8_;
   var _loc24_;
   while(_loc29_ < _loc40_.length)
   {
      _loc32_ = _loc40_[_loc29_] - _loc3_;
      _loc19_ = _loc45_(_loc32_ / _loc43_);
      if(_loc19_ < 3)
      {
         _loc19_ = 3;
      }
      _loc28_ = _loc32_ / _loc19_;
      _loc36_ = _loc28_ * _loc38_;
      _loc18_ = 0;
      while(_loc18_ < _loc19_)
      {
         _loc3_ += _loc28_;
         _loc4_ += _loc36_;
         _loc10_ = _loc42_(_loc26_ / (_loc3_ * _loc25_)) - 1;
         _loc16_ = _loc41_(_loc3_,5);
         _loc12_ = _loc27_ / (_loc16_ * _loc10_);
         _loc11_ = _loc27_ / (_loc10_ * _loc3_ * _loc16_) * (-5 + _loc26_ * (_loc10_ + 1) / (_loc3_ * _loc25_ * _loc10_));
         _loc2_ = _loc12_ * _loc30_;
         _loc17_ = (_loc12_ - _loc35_ + _loc37_ * _loc34_ - _loc11_ * _loc3_) / (_loc37_ - _loc11_);
         _loc23_ = _loc11_ * (_loc17_ - _loc3_) + _loc12_;
         _loc22_ = _loc38_ * (_loc17_ - _loc39_);
         _loc21_ = _loc30_ * _loc23_;
         if(_loc20_)
         {
            if(_loc2_ < _loc7_)
            {
               _loc13_ = _loc33_ - 2 * _loc21_ + _loc2_;
               _loc5_ = 2 * _loc21_ - 2 * _loc33_;
               _loc15_ = _loc33_ - _loc7_;
               _loc6_ = (- _loc5_ - _loc14_(_loc5_ * _loc5_ - 4 * _loc13_ * _loc15_)) / (2 * _loc13_);
               if(_loc6_ < 0 || _loc6_ > 1)
               {
                  _loc6_ = (- _loc5_ + _loc14_(_loc5_ * _loc5_ - 4 * _loc13_ * _loc15_)) / (2 * _loc13_);
               }
               _loc8_ = 1 - _loc6_;
               _loc24_ = _loc8_ * _loc8_ * _loc31_ + 2 * _loc6_ * _loc8_ * _loc22_ + _loc6_ * _loc6_ * _loc4_;
               _loc22_ = _loc8_ * _loc31_ + _loc6_ * _loc22_;
               _loc21_ = _loc8_ * _loc33_ + _loc6_ * _loc21_;
               _loc9_.curveTo(_loc22_,_loc21_,_loc24_,_loc7_);
               _loc20_ = false;
            }
            else
            {
               _loc9_.curveTo(_loc22_,_loc21_,_loc4_,_loc2_);
            }
         }
         else if(_loc2_ > _loc7_)
         {
            _loc13_ = _loc33_ - 2 * _loc21_ + _loc2_;
            _loc5_ = 2 * _loc21_ - 2 * _loc33_;
            _loc15_ = _loc33_ - _loc7_;
            _loc6_ = (- _loc5_ + _loc14_(_loc5_ * _loc5_ - 4 * _loc13_ * _loc15_)) / (2 * _loc13_);
            if(_loc6_ < 0 || _loc6_ > 1)
            {
               _loc6_ = (- _loc5_ - _loc14_(_loc5_ * _loc5_ - 4 * _loc13_ * _loc15_)) / (2 * _loc13_);
            }
            _loc8_ = 1 - _loc6_;
            _loc24_ = _loc8_ * _loc8_ * _loc31_ + 2 * _loc6_ * _loc8_ * _loc22_ + _loc6_ * _loc6_ * _loc4_;
            _loc22_ = _loc6_ * _loc4_ + _loc8_ * _loc22_;
            _loc21_ = _loc6_ * _loc2_ + _loc8_ * _loc21_;
            _loc9_.lineTo(_loc24_,_loc7_);
            _loc9_.curveTo(_loc22_,_loc21_,_loc4_,_loc2_);
            _loc20_ = true;
         }
         else
         {
            _loc9_.lineTo(_loc4_,_loc7_);
         }
         _loc31_ = _loc4_;
         _loc33_ = _loc2_;
         _loc34_ = _loc3_;
         _loc35_ = _loc12_;
         _loc37_ = _loc11_;
         _loc18_ = _loc18_ + 1;
      }
      _loc29_ = _loc29_ + 1;
   }
   if(this.showFill)
   {
      _loc9_.lineStyle(undefined);
      if(!_loc20_)
      {
         _loc9_.lineTo(_loc31_,_loc7_);
      }
      _loc9_.lineTo(_loc4_,0);
      _loc9_.lineTo(0,0);
      _loc9_.lineTo(0,_loc46_);
      _loc9_.endFill();
   }
};
p.setStyle = function(arg)
{
   if(arg.thickness != undefined)
   {
      this._thick = arg.thickness;
   }
   if(arg.color != undefined)
   {
      this._color = arg.color;
   }
   if(arg.alpha != undefined)
   {
      this._alpha = arg.alpha;
   }
   if(arg.fillColor != undefined)
   {
      this._fillColor = arg.fillColor;
   }
   if(arg.fillAlpha != undefined)
   {
      this._fillAlpha = arg.fillAlpha;
   }
};
p.getTemperature = function()
{
   return this._temp;
};
p.setTemperature = function(arg)
{
   if(typeof arg == "number" && isFinite(arg) && arg > 0)
   {
      this._temp = arg;
   }
   else
   {
      this._temp = null;
   }
};
p.addProperty("temperature",p.getTemperature,p.setTemperature);
p.addProperty("temp",p.getTemperature,p.setTemperature);
p.getVisible = function()
{
   return this._mc._visible;
};
p.setVisible = function(arg)
{
   this._mc._visible = Boolean(arg);
};
p.addProperty("visible",p.getVisible,p.setVisible);
