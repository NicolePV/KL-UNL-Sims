function SimpleBBSciNotNumberClass()
{
   var _loc1_ = this;
   _loc1_.coefficientField.autoSize = "none";
   _loc1_.coefficientFieldOriginalPosition = _loc1_.coefficientField._x;
   _loc1_.coefficientFieldTextFormat = _loc1_.coefficientField.getTextFormat();
   _loc1_.coefficientFieldTextFormat.align = "left";
   _loc1_.coefficientField.setTextFormat(_loc1_.coefficientFieldTextFormat);
   _loc1_.coefficientField.setNewTextFormat(_loc1_.coefficientFieldTextFormat);
   _loc1_.xPosition = _loc1_._x;
   _loc1_._justificationType = 3;
   _loc1_._sigFigs = 2;
   _loc1_.setValue(_loc1_.initValue);
}
var p = SimpleBBSciNotNumberClass.prototype = new MovieClip();
Object.registerClass("Simple BB Sci Not Number",SimpleBBSciNotNumberClass);
p.textMargin = 2;
p.getValue = function()
{
   var _loc2_ = this;
   var _loc1_ = {};
   _loc1_.coefficient = _loc2_.coefficientField.text;
   _loc1_.exponent = _loc2_.exponentField.text;
   _loc1_.numerical = _loc2_._value;
   return _loc1_;
};
p.setValue = function(arg)
{
   var _loc1_ = this;
   _loc1_._value = arg;
   var _loc2_;
   if(!isFinite(_loc1_._value) || isNaN(_loc1_._value))
   {
      _loc1_.setCoefficientAndExponent("...","...");
   }
   else
   {
      _loc2_ = _loc1_.getCoefficientAndExponent(_loc1_._value);
      _loc1_.setCoefficientAndExponent(_loc2_.coefficient,_loc2_.exponent);
   }
};
p.getWidth = function()
{
   var _loc1_ = this;
   return _loc1_.exponentField._x + _loc1_.exponentField.textWidth - _loc1_.coefficientField._x;
};
p.setCoefficientAndExponent = function(coefficient, exponent)
{
   var _loc1_ = this;
   _loc1_.coefficientField.text = coefficient;
   _loc1_.exponentField.text = exponent;
   _loc1_.updatePosition();
};
p.setPosition = function(arg)
{
   this.xPosition = arg;
   this.updatePosition();
};
p.updatePosition = function()
{
   var _loc1_ = this;
   var _loc2_ = _loc1_.coefficientFieldOriginalPosition + _loc1_.coefficientField._width - _loc1_.coefficientField.textWidth;
   _loc1_.coefficientField._x = _loc2_ - _loc1_.textMargin;
   switch(_loc1_._justificationtype)
   {
      case 0:
         _loc1_._x = _loc1_.xPosition;
         break;
      case 1:
         _loc1_._x = _loc1_.xPosition - _loc1_.getWidth() / 2 - _loc1_.coefficientField._x;
         break;
      case 2:
         _loc1_._x = _loc1_.xPosition - _loc1_.coefficientField._x;
         break;
      case 3:
         _loc1_._x = _loc1_.xPosition - (_loc1_.exponentField._x + _loc1_.exponentField.textWidth);
      default:
         return;
   }
};
p.getCoefficientAndExponent = function(arg)
{
   var num = arg;
   var digs = this._sigFigs;
   var result = {};
   var _loc3_;
   var _loc2_;
   if(num == 0)
   {
      _loc3_ = "0";
      var extra_zeros = digs - 1;
      if(extra_zeros != 0)
      {
         _loc3_ += ".";
         _loc2_ = 0;
         while(_loc2_ < extra_zeros)
         {
            _loc3_ += "0";
            _loc2_ = _loc2_ + 1;
         }
      }
      result.exponent = "0";
      result.coefficient = _loc3_;
      return result;
   }
   if(num < 0)
   {
      result.coefficient = "-";
      num = Math.abs(num);
   }
   else
   {
      result.coefficient = "";
   }
   var expo = Math.floor(Math.log(num) / 2.302585092994046);
   var expo_fact = Math.pow(10,- expo);
   var fact = Math.pow(10,digs - 1);
   var num2 = Math.round(fact * expo_fact * num) / fact;
   if(num2 >= 10)
   {
      num2 /= 10;
      expo++;
   }
   _loc3_ = String(num2);
   var dot = _loc3_.indexOf(".");
   var add_dot = false;
   if(dot == -1)
   {
      add_dot = true;
   }
   var sigfigs = 0;
   _loc2_ = 0;
   var _loc1_;
   while(_loc2_ < _loc3_.length)
   {
      _loc1_ = _loc3_.charCodeAt(_loc2_);
      if(_loc1_ > 47 && _loc1_ < 58)
      {
         sigfigs++;
      }
      _loc2_ = _loc2_ + 1;
   }
   var num_zeros = digs - sigfigs;
   if(num_zeros > 0 && add_dot == true)
   {
      _loc3_ += ".";
   }
   _loc2_ = 0;
   while(_loc2_ < num_zeros)
   {
      _loc3_ += "0";
      _loc2_ = _loc2_ + 1;
   }
   result.coefficient += _loc3_;
   result.exponent = String(expo);
   return result;
};
