function SimpleBBSciNotNumberClass()
{
   this.coefficientField.autoSize = "none";
   this.coefficientFieldOriginalPosition = this.coefficientField._x;
   this.coefficientFieldTextFormat = this.coefficientField.getTextFormat();
   this.coefficientFieldTextFormat.align = "left";
   this.coefficientField.setTextFormat(this.coefficientFieldTextFormat);
   this.coefficientField.setNewTextFormat(this.coefficientFieldTextFormat);
   this.xPosition = this._x;
   this._justificationType = 3;
   this._sigFigs = 2;
   this.setValue(this.initValue);
}
var p = SimpleBBSciNotNumberClass.prototype = new MovieClip();
Object.registerClass("Simple BB Sci Not Number",SimpleBBSciNotNumberClass);
p.textMargin = 2;
p.getValue = function()
{
   var _loc2_ = {};
   _loc2_.coefficient = this.coefficientField.text;
   _loc2_.exponent = this.exponentField.text;
   _loc2_.numerical = this._value;
   return _loc2_;
};
p.setValue = function(arg)
{
   this._value = arg;
   var _loc2_;
   if(!isFinite(this._value) || isNaN(this._value))
   {
      this.setCoefficientAndExponent("...","...");
   }
   else
   {
      _loc2_ = this.getCoefficientAndExponent(this._value);
      this.setCoefficientAndExponent(_loc2_.coefficient,_loc2_.exponent);
   }
};
p.getWidth = function()
{
   return this.exponentField._x + this.exponentField.textWidth - this.coefficientField._x;
};
p.setCoefficientAndExponent = function(coefficient, exponent)
{
   this.coefficientField.text = coefficient;
   this.exponentField.text = exponent;
   this.updatePosition();
};
p.setPosition = function(arg)
{
   this.xPosition = arg;
   this.updatePosition();
};
p.updatePosition = function()
{
   var _loc2_ = this.coefficientFieldOriginalPosition + this.coefficientField._width - this.coefficientField.textWidth;
   this.coefficientField._x = _loc2_ - this.textMargin;
   switch(this._justificationtype)
   {
      case 0:
         this._x = this.xPosition;
         break;
      case 1:
         this._x = this.xPosition - this.getWidth() / 2 - this.coefficientField._x;
         break;
      case 2:
         this._x = this.xPosition - this.coefficientField._x;
         break;
      case 3:
         this._x = this.xPosition - (this.exponentField._x + this.exponentField.textWidth);
      default:
         return;
   }
};
p.getCoefficientAndExponent = function(arg)
{
   var _loc9_ = arg;
   var _loc11_ = this._sigFigs;
   var _loc5_ = {};
   var _loc4_;
   var _loc7_;
   var _loc3_;
   if(_loc9_ == 0)
   {
      _loc4_ = "0";
      _loc7_ = _loc11_ - 1;
      if(_loc7_ != 0)
      {
         _loc4_ += ".";
         _loc3_ = 0;
         while(_loc3_ < _loc7_)
         {
            _loc4_ += "0";
            _loc3_ = _loc3_ + 1;
         }
      }
      _loc5_.exponent = "0";
      _loc5_.coefficient = _loc4_;
      return _loc5_;
   }
   if(_loc9_ < 0)
   {
      _loc5_.coefficient = "-";
      _loc9_ = Math.abs(_loc9_);
   }
   else
   {
      _loc5_.coefficient = "";
   }
   var _loc10_ = Math.floor(Math.log(_loc9_) / 2.302585092994046);
   var _loc16_ = Math.pow(10,- _loc10_);
   var _loc13_ = Math.pow(10,_loc11_ - 1);
   var _loc12_ = Math.round(_loc13_ * _loc16_ * _loc9_) / _loc13_;
   if(_loc12_ >= 10)
   {
      _loc12_ /= 10;
      _loc10_ = _loc10_ + 1;
   }
   _loc4_ = String(_loc12_);
   var _loc15_ = _loc4_.indexOf(".");
   var _loc14_ = false;
   if(_loc15_ == -1)
   {
      _loc14_ = true;
   }
   var _loc8_ = 0;
   _loc3_ = 0;
   var _loc2_;
   while(_loc3_ < _loc4_.length)
   {
      _loc2_ = _loc4_.charCodeAt(_loc3_);
      if(_loc2_ > 47 && _loc2_ < 58)
      {
         _loc8_ = _loc8_ + 1;
      }
      _loc3_ = _loc3_ + 1;
   }
   var _loc6_ = _loc11_ - _loc8_;
   if(_loc6_ > 0 && _loc14_ == true)
   {
      _loc4_ += ".";
   }
   _loc3_ = 0;
   while(_loc3_ < _loc6_)
   {
      _loc4_ += "0";
      _loc3_ = _loc3_ + 1;
   }
   _loc5_.coefficient += _loc4_;
   _loc5_.exponent = String(_loc10_);
   return _loc5_;
};
