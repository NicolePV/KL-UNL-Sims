function SliderV3Class()
{
   this.attachMovie("SliderV3MinMaxSymbol","_minLabel",1,{_y:14});
   this.attachMovie("SliderV3MinMaxSymbol","_maxLabel",2,{_y:14});
   this.attachMovie("SliderV3ValueSymbol","_valueLabel",3,{_y:-35});
   this.attachMovie("SliderV3TitleSymbol","_titleLabel",4,{_y:-35});
   this._previewFrame._visible = false;
   this.setSliderWidth(2 * this._xscale);
   this._xscale = 100;
   this._yscale = 100;
   this.setTitle(this.initTitle);
   this.min = this.initMin;
   this.max = this.initMax;
   this.setPrecision(this.initPrecision);
   this.value = this.initValue;
}
var p = SliderV3Class.prototype = new MovieClip();
Object.registerClass("SliderV3Symbol",SliderV3Class);
p.setTitle = function(arg)
{
   this._titleLabel.labelText = arg;
};
p.setSliderWidth = function(arg)
{
   var _loc2_ = Math.abs(arg / 2);
   if(_loc2_ > 0)
   {
      this._bar._xscale = _loc2_;
      this._minLabel._x = - _loc2_;
      this._maxLabel._x = _loc2_;
      this._titleLabel._x = -12 - _loc2_;
      this._valueLabel._x = 12 + _loc2_;
      this._hw = _loc2_;
      this._scale = (this._max - this._min) / (2 * this._hw);
      this.positionSlider();
   }
};
p.setPrecision = function(arg)
{
   var _loc2_ = parseInt(arg);
   if(isFinite(_loc2_))
   {
      if(_loc2_ > 15)
      {
         _loc2_ = 15;
      }
      this._prec = _loc2_;
      this._minIncrement = Math.pow(10,- _loc2_);
   }
};
p.toFixed = function(x)
{
   var _loc3_ = this._prec;
   var _loc8_ = "";
   if(x < 0)
   {
      _loc8_ = "-";
      x = - x;
   }
   var _loc4_ = "";
   var _loc9_;
   var _loc5_;
   var _loc6_;
   var _loc2_;
   var _loc11_;
   var _loc10_;
   if(x < 1e+21)
   {
      _loc9_ = Math.round(x * Math.pow(10,_loc3_));
      if(_loc9_ == 0)
      {
         _loc4_ = "0";
      }
      else
      {
         _loc4_ = _loc9_.toString();
      }
      if(_loc3_ > 0)
      {
         _loc5_ = _loc4_.length;
         if(_loc5_ <= _loc3_)
         {
            _loc6_ = "";
            _loc2_ = 0;
            while(_loc2_ < _loc3_ + 1 - _loc5_)
            {
               _loc6_ += "0";
               _loc2_ = _loc2_ + 1;
            }
            _loc4_ = _loc6_ + _loc4_;
            _loc5_ = _loc3_ + 1;
         }
         _loc11_ = _loc4_.substr(0,_loc5_ - _loc3_);
         _loc10_ = _loc4_.substr(_loc5_ - _loc3_);
         _loc4_ = _loc11_ + "." + _loc10_;
      }
   }
   else
   {
      _loc4_ = x.toString();
   }
   return _loc8_ + _loc4_;
};
p.positionSlider = function()
{
   this._grabber._x = (this._value - this._min) / this._scale - this._hw;
};
p.getMin = function()
{
   return this._min;
};
p.setMin = function(arg)
{
   var _loc2_ = Number(arg);
   if(isFinite(_loc2_))
   {
      this._min = _loc2_;
      this._scale = (this._max - this._min) / (2 * this._hw);
      this._minLabel.labelText = this._min;
   }
};
p.addProperty("min",p.getMin,p.setMin);
p.getMax = function()
{
   return this._max;
};
p.setMax = function(arg)
{
   var _loc2_ = Number(arg);
   if(isFinite(_loc2_))
   {
      this._max = _loc2_;
      this._scale = (this._max - this._min) / (2 * this._hw);
      this._maxLabel.labelText = this._max;
   }
};
p.addProperty("max",p.getMax,p.setMax);
p.getValue = function()
{
   return this._value;
};
p.setValue = function(arg)
{
   var _loc3_ = Number(arg);
   var _loc2_;
   if(isFinite(_loc3_))
   {
      _loc2_ = Math.pow(10,this._prec);
      this._value = Math.round(_loc2_ * _loc3_) / _loc2_;
      if(this._value < this._min)
      {
         this._value = this._min;
      }
      else if(this._value > this._max)
      {
         this._value = this._max;
      }
      if(this._prec > 0)
      {
         this._valueLabel.labelText = this.toFixed(this._value);
      }
      else
      {
         this._valueLabel.labelText = this._value;
      }
      this.positionSlider();
   }
};
p.addProperty("value",p.getValue,p.setValue);
p.callHandler = function()
{
   this._parent[this.changeHandler](this._value);
};
