function histoClass()
{
   this.createEmptyMovieClip("titleMC",20023);
   this._titleTextFormat = new TextFormat("Verdana",14,0,true);
   this.terrestrialPlanets_array = new Array(["Mercury",0],["Venus",1],["Earth",2],["Mars",3]);
   this.jovianPlanets_array = new Array(["Jupiter",4],["Saturn",5],["Uranus",6],["Neptune",7]);
   this.pluto_array = new Array(["Pluto",8]);
   this._maxVars = 9;
   this.semiMajorAxis_array = new Array(0.39,0.72,1,1.52,5.2,9.5,19.2,30.1,39.5);
   this.orbitalPeriod_array = new Array(0.24,0.62,1,1.9,11.9,29.4,84,164,248);
   this.mass_array = new Array(0.055,0.82,1,0.11,318,95,15,17,0.002);
   this.radius_array = new Array(0.38,0.95,1,0.53,11.2,9.5,4,3.9,0.2);
   this.satellites_array = new Array(0,0,1,2,28,30,21,8,1);
   this.rotationPeriod_array = new Array(59,-243,1,1,0.41,0.44,-0.72,0.67,-6.4);
   this.density_array = new Array(5.4,5.2,5.5,3.91,1.3,0.7,1.3,1.6,2.1);
   this.bars_array = new Array(this._maxVars);
   this._numVars = this._maxVars;
   this._graphLength = this.graphLine._width;
   this._pixelHigh = this.high_tick._y;
   this._pixelLow = this.low_tick._y;
   this.bar_w;
   this._xOffset = this.graphLine._x;
   this._showTerr = true;
   this._showJov = true;
   this._showPlu = true;
   this._itemCount = this._maxVars;
   this.attachMovie("left_label","high_label",this._itemCount++);
   this.high_label._x = this.high_tick._x;
   this.high_label._y = this.high_tick._y;
   this.attachMovie("left_label","low_label",this._itemCount++);
   this.low_label._x = this.low_tick._x;
   this.low_label._y = this.low_tick._y;
   this.placeBars(this._numVars);
}
var p = histoClass.prototype = new MovieClip();
Object.registerClass("histogram_component",histoClass);
p.terrColor = 16089473;
p.jovColor = 8432102;
p.pluColor = 7655292;
p.onEnterFrame = function()
{
   this._showTerr = this.checkBox.terrestrial_box.getValue();
   this._showJov = this.checkBox.jovian_box.getValue();
   this._showPlu = this.checkBox.pluto_box.getValue();
   this._numVars = this._maxVars;
   if(!this._showTerr)
   {
      this._numVars -= this.terrestrialPlanets_array.length;
   }
   if(!this._showJov)
   {
      this._numVars -= this.jovianPlanets_array.length;
   }
   if(!this._showPlu)
   {
      this._numVars -= this.pluto_array.length;
   }
   if(this.checkBox._changed || this.radio._changed)
   {
      this.placeBars(this._numVars);
      this.checkBox._changed = false;
      this.radio._changed = false;
   }
};
p.placeBars = function(num)
{
   i = 0;
   while(i < this._maxVars)
   {
      this.bars_array[i].removeMovieClip();
      i++;
   }
   j = 0;
   while(j < num)
   {
      this.bars_array[j] = this.attachMovie("bar","bar_" + j,j);
      j++;
   }
   this.spaceBars(num);
};
p.spaceBars = function(num)
{
   this.bar_w = this.bars_array[0].myBar._width;
   var bar_w = this.bar_w;
   var _loc3_ = (this._graphLength - num * bar_w) / (num + 1);
   while(_loc3_ < 10)
   {
      bar_w /= 2;
      _loc3_ = (this._graphLength - num * bar_w) / (num + 1);
   }
   this.bar_w = bar_w;
   k = 0;
   while(k < num)
   {
      this.bars_array[k].myBar._width = bar_w;
      this.bars_array[k]._x = this._xOffset + _loc3_ + (bar_w + _loc3_) * k;
      k++;
   }
   var _loc2_ = 0;
   if(this._showTerr)
   {
      i = 0;
      while(i < this.terrestrialPlanets_array.length)
      {
         this.placeLabel(this.terrestrialPlanets_array[i][0],_loc2_);
         _loc2_ = _loc2_ + 1;
         i++;
      }
   }
   if(this._showJov)
   {
      i = 0;
      while(i < this.jovianPlanets_array.length)
      {
         this.placeLabel(this.jovianPlanets_array[i][0],_loc2_);
         _loc2_ = _loc2_ + 1;
         i++;
      }
   }
   if(this._showPlu)
   {
      i = 0;
      while(i < this.pluto_array.length)
      {
         this.placeLabel(this.pluto_array[i][0],_loc2_);
         _loc2_ = _loc2_ + 1;
         i++;
      }
   }
   if(this.radio._value != null)
   {
      this.placeValues(this.radio._value);
   }
   else
   {
      this.placeValues("axis");
   }
};
p.placeLabel = function(label, index)
{
   var _loc2_ = this.bars_array[index].attachMovie("misc_label","myLabel",1);
   _loc2_.labelText = label;
   _loc2_._x = this.bar_w / 2;
};
p.placeValues = function(radio_value)
{
   var _loc3_ = "";
   switch(radio_value)
   {
      case "axis":
         _loc3_ = "Semi-major Axis (AU)";
         this.place(this.semiMajorAxis_array);
         break;
      case "orbital":
         _loc3_ = "Orbital Period (yr)";
         this.place(this.orbitalPeriod_array);
         break;
      case "mass":
         _loc3_ = "Mass (Earth masses)";
         this.place(this.mass_array);
         break;
      case "radius":
         _loc3_ = "Radius (Earth radii)";
         this.place(this.radius_array);
         break;
      case "satellite":
         _loc3_ = "Satellites";
         this.place(this.satellites_array);
         break;
      case "rotation":
         _loc3_ = "Rotation Period (days)";
         this.place(this.rotationPeriod_array);
         break;
      case "density":
         _loc3_ = "Density (g/cm<sup>3</sup>)";
         this.place(this.density_array);
   }
   trace(_global.displayText);
   _global.displayText(_loc3_,{mc:this.titleMC,depth:1,x:375,y:-374,embedFonts:true,textFormat:this._titleTextFormat});
};
p.logBaseTen = function(num)
{
   return Math.log(num) / 2.302585092994046;
};
p.findHighValue = function(arrayObj)
{
   var _loc2_ = arrayObj[0];
   h = 0;
   while(h < arrayObj.length)
   {
      if(arrayObj[h] > _loc2_)
      {
         _loc2_ = arrayObj[h];
      }
      h++;
   }
   return _loc2_;
};
p.findLowValue = function(arrayObj)
{
   var _loc2_ = arrayObj[0];
   l = 0;
   while(l < arrayObj.length)
   {
      if(arrayObj[l] < _loc2_)
      {
         _loc2_ = arrayObj[l];
      }
      l++;
   }
   return _loc2_;
};
p.place = function(array_obj)
{
   var _loc13_ = this.findHighValue(array_obj);
   var _loc12_ = this.findLowValue(array_obj);
   var _loc6_ = false;
   if(Math.abs(_loc13_ - _loc12_) > 50)
   {
      _loc6_ = true;
   }
   var _loc4_ = this.findGoodHigh(_loc13_);
   this.high_label.labelText = _loc4_;
   var _loc7_ = this.findGoodLow(_loc12_,_loc6_);
   this.low_label.labelText = _loc7_;
   var _loc2_ = 0;
   var _loc8_;
   var _loc11_;
   if(this._showTerr)
   {
      i = 0;
      while(i < this.terrestrialPlanets_array.length)
      {
         _loc8_ = this.terrestrialPlanets_array[i][1];
         _loc11_ = this.findPixelVal(array_obj[_loc8_],_loc4_,_loc7_,_loc6_);
         this.bars_array[_loc2_].changeHeight(array_obj[_loc8_],- _loc11_);
         this.bars_array[_loc2_].setColor(this.terrColor);
         _loc2_ = _loc2_ + 1;
         i++;
      }
   }
   if(this._showJov)
   {
      i = 0;
      while(i < this.jovianPlanets_array.length)
      {
         _loc8_ = this.jovianPlanets_array[i][1];
         _loc11_ = this.findPixelVal(array_obj[_loc8_],_loc4_,_loc7_,_loc6_);
         this.bars_array[_loc2_].changeHeight(array_obj[_loc8_],- _loc11_);
         this.bars_array[_loc2_].setColor(this.jovColor);
         _loc2_ = _loc2_ + 1;
         i++;
      }
   }
   if(this._showPlu)
   {
      i = 0;
      while(i < this.pluto_array.length)
      {
         _loc8_ = this.pluto_array[i][1];
         _loc11_ = this.findPixelVal(array_obj[_loc8_],_loc4_,_loc7_,_loc6_);
         this.bars_array[_loc2_].changeHeight(array_obj[_loc8_],- _loc11_);
         this.bars_array[_loc2_].setColor(this.pluColor);
         _loc2_ = _loc2_ + 1;
         i++;
      }
   }
   this.createEmptyMovieClip("tick",this._itemCount + 1);
   this.tick._x = this.low_tick._x;
   var _loc10_ = 0;
   var _loc3_ = _loc7_;
   var _loc9_;
   while(_loc3_ < _loc4_)
   {
      _loc10_ = _loc10_ + 1;
      if(_loc6_)
      {
         _loc3_ *= 10;
      }
      else if(_loc4_ < 15)
      {
         _loc3_ += 1;
      }
      else
      {
         _loc3_ += 5;
      }
      if(_loc3_ < _loc4_)
      {
         _loc9_ = this.tick.attachMovie("tick_mark_label","tick" + _loc10_,_loc10_);
         _loc9_.tickLabel.labelText = _loc3_;
         _loc9_._y = this.findPixelVal(_loc3_,_loc4_,_loc7_,_loc6_);
      }
   }
};
p.findPixelVal = function(val, graphHigh, graphLow, logBool)
{
   var _loc3_;
   if(logBool)
   {
      _loc3_ = (this._pixelHigh - this._pixelLow) / (this.logBaseTen(graphHigh) - this.logBaseTen(graphLow)) * (this.logBaseTen(val) - this.logBaseTen(graphHigh)) + this._pixelHigh;
   }
   else
   {
      _loc3_ = (this._pixelHigh - this._pixelLow) / (graphHigh - graphLow) * (val - graphHigh) + this._pixelHigh;
   }
   return _loc3_;
};
p.findGoodHigh = function(num)
{
   var _loc1_ = num;
   if(_loc1_ > 20)
   {
      _loc1_ = Math.ceil(num / 10) * 10;
   }
   else
   {
      _loc1_ = Math.ceil(num);
   }
   return _loc1_;
};
p.findGoodLow = function(num, logrithmic)
{
   var _loc1_ = num;
   if(logrithmic)
   {
      if(_loc1_ < 0.01)
      {
         _loc1_ = 0.001;
      }
      else
      {
         _loc1_ = 0.1;
      }
   }
   else if(_loc1_ >= 0)
   {
      _loc1_ = 0;
   }
   else if(_loc1_ < 20)
   {
      _loc1_ = Math.floor(_loc1_ / 10) * 10;
   }
   else
   {
      _loc1_ = Math.floor(_loc1_);
   }
   return _loc1_;
};
