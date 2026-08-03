function GravCalcClass()
{
   this.selectedItemFormat = new TextFormat("Verdana",12,3507709,false);
   this.m2Slider.minValue = this.m1Slider.minValue = 9.10999e-31;
   this.m2Slider.maxValue = this.m1Slider.maxValue = 1.15001e+42;
   this.m1Slider.update();
   this.m2Slider.update();
   this.rSlider.minValue = 9.9999e-16;
   this.rSlider.maxValue = 8.80001e+26;
   this.rSlider.update();
   this.createEmptyMovieClip("centerlineText",1);
   this.createEmptyMovieClip("numeratorWithValues",10);
   this.createEmptyMovieClip("denominatorWithValues",11);
   this.createEmptyMovieClip("accelerationValues",12);
   this.attachMovie("Stored Values Table","storedValuesTable",50,{_visible:false,_y:-45});
   this.accelerationValues.attachMovie("a1 line","a1Line",1);
   this.accelerationValues.attachMovie("a2 line","a2Line",2);
}
var p = GravCalcClass.prototype = new MovieClip();
Object.registerClass("Grav Calc",GravCalcClass);
p.xCenter = 353;
p.G = 6.67e-11;
p.y1 = 17;
p.y2 = 56;
p.specialSeparations = [{text:"proton",icon:"Proton",y:p.y1,xShift:0,v:1e-15,unit:"m"},{text:"typical atom radius",icon:"Atom",y:p.y1,xShift:0,v:1e-10,unit:"m"},{text:"1 meter",icon:"1 m",y:p.y2,xShift:0,v:1,unit:"m"},{text:"social spacing",icon:"Human Spacing",y:p.y1,xShift:0,v:2,unit:"m"},{text:"radius of Earth",icon:"Earth",y:p.y1,xShift:-4.3,v:6370000,unit:"m"},{text:"distance to Moon",icon:"Moon",y:p.y1,xShift:4,v:384000000,unit:"m"},{text:"closest approach to Mars",icon:"Mars",y:p.y2,xShift:-10,v:57000000000,unit:"m"},{text:"distance to Sun",icon:"Sun",y:p.y1,xShift:0,v:150000000000,unit:"m"},{text:"closest approach to Jupiter",icon:"Jupiter",y:p.y2,xShift:10,v:590000000000,unit:"m"},{text:"distance to nearest star",icon:"Nearest Star",y:p.y1,xShift:0,v:41000000000000000,unit:"m"},{text:"radius of Milky Way",icon:"Milky Way",y:p.y1,xShift:0,v:470000000000000000000,unit:"m"},{text:"radius of observable universe",icon:"Universe",y:p.y1,xShift:0,v:4.4e+26,unit:"m"}];
p.specialMasses = [{text:"electron",icon:"Electron",y:p.y1,xShift:-3.5,v:9.11e-31,unit:"kg"},{text:"proton",icon:"Proton",y:p.y1,xShift:3.5,v:1.67e-27,unit:"kg"},{text:"small apple",icon:"Apple",y:p.y1,xShift:-5.3,v:0.102,unit:"kg"},{text:"1 kilogram",icon:"1 kg",y:p.y2,xShift:0,v:1,unit:"kg"},{text:"person",icon:"Person",y:p.y1,xShift:5.3,v:72,unit:"kg"},{text:"large mountain",icon:"Mountain",y:p.y1,xShift:-4.5,v:1000000000000000,unit:"kg"},{text:"large asteroid",icon:"Asteroid",y:p.y1,xShift:4.5,v:1000000000000000000,unit:"kg"},{text:"Moon",icon:"Moon",y:p.y2,xShift:-10,v:7.35e+22,unit:"kg"},{text:"Mars",icon:"Mars",y:p.y1,xShift:-6,v:6.42e+23,unit:"kg"},{text:"Earth",icon:"Earth",y:p.y2,xShift:10,v:5.97e+24,unit:"kg"},{text:"Jupiter",icon:"Jupiter",y:p.y1,xShift:-1,v:1.9e+27,unit:"kg"},{text:"Sun",icon:"Sun",y:p.y1,xShift:9,v:1.99e+30,unit:"kg"},{text:"Milky Way",icon:"Milky Way",y:p.y1,xShift:0,v:1.15e+42,unit:"kg"}];
p.onToggleShowStoredValues = function()
{
   this.setShowStoredValues(!this.storedValuesTable._visible);
};
p.setShowStoredValues = function(arg)
{
   this.storedValuesTable._visible = arg;
   if(arg)
   {
      this.showStoredValuesButton.setLabel("hide");
   }
   else
   {
      this.showStoredValuesButton.setLabel("show");
   }
};
p.onStore = function()
{
   this.storedValuesTable.store({f:this.fString,a1:this.a1String,a2:this.a2String,m1:this.m1String,m2:this.m2String,r:this.rString});
   this.storeButton.setEnabled(false);
};
p.onClear = function()
{
   this.storedValuesTable.clearAll();
   this.storeButton.setEnabled(true);
};
p.init = function()
{
   this.addSpecials(this.rSlider,this.specialSeparations);
   this.addSpecials(this.m1Slider,this.specialMasses);
   this.addSpecials(this.m2Slider,this.specialMasses);
   this.reset();
};
p.addSpecials = function(slider, specials)
{
   slider.createEmptyMovieClip("specialLinesMC",12);
   var _loc10_ = slider.createEmptyMovieClip("specialsMC",212);
   var _loc9_ = [];
   var _loc2_ = 0;
   while(_loc2_ < specials.length)
   {
      specials[_loc2_].x = slider.controller.getParameterFromValue(specials[_loc2_].v);
      specialMC = _loc10_.attachMovie("Special Button","_" + _loc2_,_loc2_,{slider:slider,calc:this,def:specials[_loc2_],_x:specials[_loc2_].x + specials[_loc2_].xShift,_y:specials[_loc2_].y});
      _loc9_.push(specialMC);
      _loc2_ = _loc2_ + 1;
   }
   slider.createEmptyMovieClip("selectedText",211);
   slider.specials = _loc9_;
};
p.reset = function()
{
   this.storedValuesTable.clearAll();
   this.setShowStoredValues(false);
   this.storeButton.setEnabled(true);
   this.onSpecialSelected(this.rSlider,this.rSlider.specials[4]);
   this.onSpecialSelected(this.m1Slider,this.m1Slider.specials[2]);
   this.onSpecialSelected(this.m2Slider,this.m2Slider.specials[9]);
};
p.onM1SliderDragged = function()
{
   this.onSliderDragged(this.m1Slider);
};
p.onM2SliderDragged = function()
{
   this.onSliderDragged(this.m2Slider);
};
p.onRSliderDragged = function()
{
   this.onSliderDragged(this.rSlider);
};
p.onSliderDragged = function(slider)
{
   var _loc4_ = null;
   var _loc2_ = 0;
   while(_loc2_ < slider.specials.length)
   {
      if(Math.abs(slider.specials[_loc2_].def.v - slider.value) < Math.min(slider.specials[_loc2_].def.v,slider.value) * 1e-8)
      {
         _loc4_ = slider.specials[_loc2_];
         break;
      }
      _loc2_ = _loc2_ + 1;
   }
   this.onSpecialSelected(slider,_loc4_);
};
p.onSpecialSelected = function(slider, specialMC)
{
   var _loc7_ = slider.specialLinesMC;
   _loc7_.clear();
   _loc7_.lineStyle(1,13684944);
   var _loc2_ = 0;
   while(_loc2_ < slider.specials.length)
   {
      if(slider.specials[_loc2_] != specialMC)
      {
         slider.specials[_loc2_].setSelected(false);
         _loc7_.moveTo(slider.specials[_loc2_].def.x,0);
         _loc7_.lineTo(slider.specials[_loc2_].def.x,slider.specials[_loc2_].def.y + 10);
      }
      _loc2_ = _loc2_ + 1;
   }
   var _loc5_;
   var _loc6_;
   if(specialMC != null)
   {
      specialMC.setSelected(true);
      _loc7_.lineStyle(2,11259390);
      _loc7_.moveTo(specialMC.def.x,-17);
      _loc7_.lineTo(specialMC.def.x,specialMC.def.y + 10);
      slider.setValue(specialMC.def.v);
      slider.selectedText._visible = true;
      _loc5_ = this.displayText(specialMC.def.text,{mc:slider.selectedText,depth:1,x:specialMC.def.x,y:-25,textFormat:this.selectedItemFormat,embedFonts:true,vAlign:"center",hAlign:"bottom"});
      _loc6_ = 30;
      if(_loc5_._x + _loc5_.textWidth / 2 > slider.controller._maxP + _loc6_)
      {
         _loc5_._x = slider.controller._maxP + _loc6_ - _loc5_.textWidth / 2;
      }
   }
   else
   {
      slider.selectedText._visible = false;
   }
   this.update();
};
p.update = function()
{
   this.storeButton.setEnabled(true);
   var _loc41_ = this.G * this.m1Slider.fullValue * this.m2Slider.fullValue / (this.rSlider.fullValue * this.rSlider.fullValue);
   var _loc13_ = Math.floor(Math.log(_loc41_) / 2.302585092994046);
   var _loc15_ = (_loc41_ / Math.pow(10,_loc13_)).toFixed(2);
   var _loc8_ = parseFloat(_loc15_);
   if(_loc8_ >= 10)
   {
      _loc8_ /= 10;
      _loc15_ = _loc8_.toFixed(2);
      _loc13_ = _loc13_ + 1;
   }
   _loc13_ = _loc13_.toString();
   var _loc7_ = _loc13_ != "0" ? _loc15_ + "×10<sup>" + _loc13_ + "</sup>" : _loc15_;
   var _loc38_ = _loc41_ / this.m1Slider.fullValue;
   _loc13_ = Math.floor(Math.log(_loc38_) / 2.302585092994046);
   _loc15_ = (_loc38_ / Math.pow(10,_loc13_)).toFixed(2);
   _loc8_ = parseFloat(_loc15_);
   if(_loc8_ >= 10)
   {
      _loc8_ /= 10;
      _loc15_ = _loc8_.toFixed(2);
      _loc13_ = _loc13_ + 1;
   }
   _loc13_ = _loc13_.toString();
   var _loc17_ = _loc13_ != "0" ? _loc15_ + "×10<sup>" + _loc13_ + "</sup>" : _loc15_;
   var _loc36_ = _loc41_ / this.m2Slider.fullValue;
   _loc13_ = Math.floor(Math.log(_loc36_) / 2.302585092994046);
   _loc15_ = (_loc36_ / Math.pow(10,_loc13_)).toFixed(2);
   _loc8_ = parseFloat(_loc15_);
   if(_loc8_ >= 10)
   {
      _loc8_ /= 10;
      _loc15_ = _loc8_.toFixed(2);
      _loc13_ = _loc13_ + 1;
   }
   _loc13_ = _loc13_.toString();
   var _loc16_ = _loc13_ != "0" ? _loc15_ + "×10<sup>" + _loc13_ + "</sup>" : _loc15_;
   var _loc6_ = this.m1Slider.controller;
   _loc15_ = (_loc6_._valueObject.sig / Math.pow(10,_loc6_._digs - 1)).toFixed(_loc6_._digs - 1);
   _loc13_ = _loc6_._valueObject.mag.toString();
   var _loc10_ = (_loc13_ != "0" ? _loc15_ + "×10<sup>" + _loc13_ + "</sup>" : _loc15_) + " kg";
   _loc6_ = this.m2Slider.controller;
   _loc15_ = (_loc6_._valueObject.sig / Math.pow(10,_loc6_._digs - 1)).toFixed(_loc6_._digs - 1);
   _loc13_ = _loc6_._valueObject.mag.toString();
   var _loc9_ = (_loc13_ != "0" ? _loc15_ + "×10<sup>" + _loc13_ + "</sup>" : _loc15_) + " kg";
   _loc6_ = this.rSlider.controller;
   _loc15_ = (_loc6_._valueObject.sig / Math.pow(10,_loc6_._digs - 1)).toFixed(_loc6_._digs - 1);
   _loc13_ = _loc6_._valueObject.mag.toString();
   var _loc11_ = (_loc13_ != "0" ? _loc15_ + "×10<sup>" + _loc13_ + "</sup>" : _loc15_) + " m";
   var _loc18_ = this.G.toScientific(3,true).string + " m<sup>3</sup> kg<sup>-1</sup> s<sup>-2</sup>";
   var _loc42_ = "(" + _loc18_ + ") (" + _loc10_ + ") (" + _loc9_ + ")";
   var _loc37_ = "(" + _loc11_ + ")<sup>2</sup>";
   var _loc3_ = new TextFormat("Verdana",20,0,false);
   this.fString = _loc7_ + " N";
   this.a1String = _loc17_ + " m s<sup>-2</sup>";
   this.a2String = _loc16_ + " m s<sup>-2</sup>";
   this.m1String = _loc10_;
   this.m2String = _loc9_;
   this.rString = _loc11_;
   this.storedValuesTable.setCurrentValues({f:this.fString,a1:this.a1String,a2:this.a2String,m1:this.m1String,m2:this.m2String,r:this.rString});
   var _loc19_ = 20;
   var _loc14_ = 4;
   var _loc26_ = -4;
   var _loc22_ = 2.5;
   var _loc20_ = 193;
   var _loc5_ = 0;
   var _loc25_ = 67;
   var _loc24_ = 132;
   var _loc2_ = _loc20_;
   var _loc23_ = _loc22_;
   var _loc12_ = _loc26_;
   var _loc4_ = 0;
   var _loc27_ = this.displayText("(" + _loc18_ + ")",{mc:this.numeratorWithValues,depth:1,x:_loc4_,y:_loc5_ + _loc12_,hAlign:"left",vAlign:"bottom",embedFonts:true,textFormat:_loc3_,sizeRatio:this.m1Slider.scriptsSizeRatio});
   _loc4_ += _loc27_.textWidth + _loc14_;
   _loc27_ = this.displayText("(" + _loc10_ + ")",{mc:this.numeratorWithValues,depth:2,x:_loc4_,y:_loc5_ + _loc12_,hAlign:"left",vAlign:"bottom",embedFonts:true,textFormat:_loc3_,sizeRatio:this.m1Slider.scriptsSizeRatio});
   _loc4_ += _loc27_.textWidth + _loc14_;
   _loc27_ = this.displayText("(" + _loc9_ + ")",{mc:this.numeratorWithValues,depth:3,x:_loc4_,y:_loc5_ + _loc12_,hAlign:"left",vAlign:"bottom",embedFonts:true,textFormat:_loc3_,sizeRatio:this.m1Slider.scriptsSizeRatio});
   _loc4_ += _loc27_.textWidth;
   this.displayText("(" + _loc11_ + ")<sup>2</sup>",{mc:this.denominatorWithValues,depth:1,x:0,y:_loc5_ + _loc23_,hAlign:"center",vAlign:"top",embedFonts:true,textFormat:_loc3_,sizeRatio:this.m1Slider.scriptsSizeRatio});
   this.numeratorWithValues._x = _loc2_;
   this.denominatorWithValues._x = _loc2_ + _loc4_ / 2;
   this.clear();
   this.lineStyle(1,0);
   this.moveTo(this.numeratorWithValues._x,_loc5_);
   this.lineTo(this.numeratorWithValues._x + _loc4_,_loc5_);
   _loc2_ = _loc20_;
   yCenter = _loc25_;
   _loc27_ = this.displayText(_loc7_ + " kg m s<sup>-2</sup>",{mc:this.centerlineText,depth:5,x:_loc2_,y:yCenter,hAlign:"left",vAlign:"center",embedFonts:true,textFormat:_loc3_,sizeRatio:this.m1Slider.scriptsSizeRatio});
   _loc2_ += _loc27_.textWidth + _loc19_;
   _loc27_ = this.displayText("=",{mc:this.centerlineText,depth:6,x:_loc2_,y:yCenter,hAlign:"left",vAlign:"center",embedFonts:true,textFormat:_loc3_,sizeRatio:this.m1Slider.scriptsSizeRatio});
   _loc2_ += _loc27_.textWidth + _loc19_;
   _loc27_ = this.displayText(_loc7_ + " N",{mc:this.centerlineText,depth:7,x:_loc2_,y:yCenter,hAlign:"left",vAlign:"center",embedFonts:true,textFormat:_loc3_,sizeRatio:this.m1Slider.scriptsSizeRatio});
   yCenter = 0;
   _loc2_ = this.accelerationValues.a1Line._width;
   var _loc21_ = 50;
   _loc27_ = this.displayText(_loc17_ + " m s<sup>-2</sup>",{mc:this.accelerationValues,depth:100,x:_loc2_,y:yCenter,hAlign:"left",vAlign:"center",embedFonts:true,textFormat:_loc3_,sizeRatio:this.m1Slider.scriptsSizeRatio});
   _loc2_ += _loc27_.textWidth + _loc21_;
   _loc27_ = this.displayText(",",{mc:this.accelerationValues,depth:101,x:_loc2_,y:yCenter,hAlign:"left",vAlign:"center",embedFonts:true,textFormat:_loc3_,sizeRatio:this.m1Slider.scriptsSizeRatio});
   _loc2_ += _loc27_.textWidth + _loc21_;
   this.accelerationValues.a2Line._x = _loc2_;
   _loc2_ += this.accelerationValues.a2Line._width;
   _loc27_ = this.displayText(_loc16_ + " m s<sup>-2</sup>",{mc:this.accelerationValues,depth:102,x:_loc2_,y:yCenter,hAlign:"left",vAlign:"center",embedFonts:true,textFormat:_loc3_,sizeRatio:this.m1Slider.scriptsSizeRatio});
   _loc2_ += _loc27_.textWidth;
   this.accelerationValues._x = this.xCenter - _loc2_ / 2 - 20;
   this.accelerationValues._y = _loc24_;
};
