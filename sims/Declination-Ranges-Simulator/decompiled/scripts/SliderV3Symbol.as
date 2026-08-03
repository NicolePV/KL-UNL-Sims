function SliderV3Class()
{
   var _loc1_ = this;
   _loc1_.attachMovie("SliderV3MinMaxSymbol","_minLabel",1,{_y:14});
   _loc1_.attachMovie("SliderV3MinMaxSymbol","_maxLabel",2,{_y:14});
   _loc1_.attachMovie("SliderV3ValueSymbol","_valueLabel",3,{_y:-35});
   _loc1_.attachMovie("SliderV3TitleSymbol","_titleLabel",4,{_y:-35});
   _loc1_._previewFrame._visible = false;
   _loc1_.setSliderWidth(2 * _loc1_._xscale);
   _loc1_._xscale = 100;
   _loc1_._yscale = 100;
   _loc1_.setTitle(_loc1_.initTitle);
   _loc1_.min = _loc1_.initMin;
   _loc1_.max = _loc1_.initMax;
   _loc1_.setPrecision(_loc1_.initPrecision);
   _loc1_.value = _loc1_.initValue;
}
var p = SliderV3Class.prototype = new MovieClip();
Object.registerClass("SliderV3Symbol",SliderV3Class);
p.setTitle = function(arg)
{
   this._titleLabel.labelText = arg;
};
p.setSliderWidth = function(arg)
{
   var _loc1_ = this;
   var _loc2_ = Math.abs(arg / 2);
   if(_loc2_ > 0)
   {
      _loc1_._bar._xscale = _loc2_;
      _loc1_._minLabel._x = - _loc2_;
      _loc1_._maxLabel._x = _loc2_;
      _loc1_._titleLabel._x = -12 - _loc2_;
      _loc1_._valueLabel._x = 12 + _loc2_;
      _loc1_._hw = _loc2_;
      _loc1_._scale = (_loc1_._max - _loc1_._min) / (2 * _loc1_._hw);
      _loc1_.positionSlider();
   }
};
p.setPrecision = function(arg)
{
   var _loc1_ = parseInt(arg);
   if(isFinite(_loc1_))
   {
      if(_loc1_ > 15)
      {
         _loc1_ = 15;
      }
      this._prec = _loc1_;
      this._minIncrement = Math.pow(10,- _loc1_);
   }
};
p.toFixed = function(x)
{
   var _loc2_ = this._prec;
   var s = "";
   if(x < 0)
   {
      s = "-";
      x = - x;
   }
   var _loc3_ = "";
   var _loc1_;
   if(x < 1e+21)
   {
      var n = Math.round(x * Math.pow(10,_loc2_));
      if(n == 0)
      {
         _loc3_ = "0";
      }
      else
      {
         _loc3_ = n.toString();
      }
      if(_loc2_ > 0)
      {
         var k = _loc3_.length;
         if(k <= _loc2_)
         {
            var z = "";
            _loc1_ = 0;
            while(_loc1_ < _loc2_ + 1 - k)
            {
               z += "0";
               _loc1_ = _loc1_ + 1;
            }
            _loc3_ = z + _loc3_;
            k = _loc2_ + 1;
         }
         var a = _loc3_.substr(0,k - _loc2_);
         var b = _loc3_.substr(k - _loc2_);
         _loc3_ = a + "." + b;
      }
   }
   else
   {
      _loc3_ = x.toString();
   }
   return s + _loc3_;
};
p.positionSlider = function()
{
   var _loc1_ = this;
   _loc1_._grabber._x = (_loc1_._value - _loc1_._min) / _loc1_._scale - _loc1_._hw;
};
p.getMin = function()
{
   return this._min;
};
p.setMin = function(arg)
{
   var _loc1_ = this;
   var _loc2_ = Number(arg);
   if(isFinite(_loc2_))
   {
      _loc1_._min = _loc2_;
      _loc1_._scale = (_loc1_._max - _loc1_._min) / (2 * _loc1_._hw);
      _loc1_._minLabel.labelText = _loc1_._min;
   }
};
p.addProperty("min",p.getMin,p.setMin);
p.getMax = function()
{
   return this._max;
};
p.setMax = function(arg)
{
   var _loc1_ = this;
   var _loc2_ = Number(arg);
   if(isFinite(_loc2_))
   {
      _loc1_._max = _loc2_;
      _loc1_._scale = (_loc1_._max - _loc1_._min) / (2 * _loc1_._hw);
      _loc1_._maxLabel.labelText = _loc1_._max;
   }
};
p.addProperty("max",p.getMax,p.setMax);
p.getValue = function()
{
   return this._value;
};
p.setValue = function(arg)
{
   var _loc1_ = this;
   var _loc3_ = Number(arg);
   var _loc2_;
   if(isFinite(_loc3_))
   {
      _loc2_ = Math.pow(10,_loc1_._prec);
      _loc1_._value = Math.round(_loc2_ * _loc3_) / _loc2_;
      if(_loc1_._value < _loc1_._min)
      {
         _loc1_._value = _loc1_._min;
      }
      else if(_loc1_._value > _loc1_._max)
      {
         _loc1_._value = _loc1_._max;
      }
      if(_loc1_._prec > 0)
      {
         _loc1_._valueLabel.labelText = _loc1_.toFixed(_loc1_._value);
      }
      else
      {
         _loc1_._valueLabel.labelText = _loc1_._value;
      }
      _loc1_.positionSlider();
   }
};
p.addProperty("value",p.getValue,p.setValue);
p.callHandler = function()
{
   var _loc1_ = this;
   _loc1_._parent[_loc1_.changeHandler](_loc1_._value);
};
