function simClass()
{
   var _loc1_ = this;
   _loc1_.active = false;
   _loc1_.starMove = false;
   _loc1_._littleM = _loc1_.little_m_slider.initValue;
   _loc1_._bigM = _loc1_.big_M_slider.initValue;
   _loc1_._dist = _loc1_.d_slider.initValue;
   _loc1_.myEquation.d_box.textColor = _loc1_.d_slider.txtColor;
   _loc1_.myEquation.d_ly_box.textColor = _loc1_.d_slider.txtColor;
   _loc1_.littleText = new TextFormat();
   _loc1_.littleText.color = _loc1_.little_m_slider.txtColor;
   _loc1_.bigText = new TextFormat();
   _loc1_.bigText.color = _loc1_.big_M_slider.txtColor;
}
var p = simClass.prototype = new MovieClip();
Object.registerClass("simulator",simClass);
p.onEnterFrame = function()
{
   var _loc1_ = this;
   if(_loc1_.lock._value == 1)
   {
      _loc1_.little_m_slider.active = false;
      _loc1_.little_m_slider._grabber._alpha = 50;
      _loc1_.little_m_slider._bar._alpha = 50;
      _loc1_.big_M_slider.active = true;
      _loc1_.big_M_slider._grabber._alpha = 100;
      _loc1_.big_M_slider._bar._alpha = 100;
      _loc1_.d_slider.active = true;
      _loc1_.d_slider._grabber._alpha = 100;
      _loc1_.d_slider._bar._alpha = 100;
   }
   else if(_loc1_.lock._value == 2)
   {
      _loc1_.little_m_slider.active = true;
      _loc1_.little_m_slider._grabber._alpha = 100;
      _loc1_.little_m_slider._bar._alpha = 100;
      _loc1_.big_M_slider.active = false;
      _loc1_.big_M_slider._grabber._alpha = 50;
      _loc1_.big_M_slider._bar._alpha = 50;
      _loc1_.d_slider.active = true;
      _loc1_.d_slider._grabber._alpha = 100;
      _loc1_.d_slider._bar._alpha = 100;
   }
   else if(_loc1_.lock._value == 3)
   {
      _loc1_.little_m_slider.active = true;
      _loc1_.little_m_slider._grabber._alpha = 100;
      _loc1_.little_m_slider._bar._alpha = 100;
      _loc1_.big_M_slider.active = true;
      _loc1_.big_M_slider._grabber._alpha = 100;
      _loc1_.big_M_slider._bar._alpha = 100;
      _loc1_.d_slider.active = false;
      _loc1_.d_slider._grabber._alpha = 50;
      _loc1_.d_slider._bar._alpha = 50;
   }
   _loc1_.changeRange();
   _loc1_.calculateValues();
   _loc1_.moveStar();
   if(_loc1_.myWindow._open)
   {
      _loc1_.myWindow._x = 20;
   }
   else
   {
      _loc1_.myWindow._x = -475;
   }
};
p.changeRange = function()
{
   var _loc1_ = this;
   var _loc2_;
   var _loc3_;
   if(_loc1_.lock._value == 1)
   {
      var log_max = Math.log(_loc1_.d_slider.max) / 2.302585092994046;
      var log_min = Math.log(_loc1_.d_slider.min) / 2.302585092994046;
      var m_min = -13;
      var m_max = 28;
      _loc2_ = _loc1_.little_m_slider.value - (-5 + 5 * log_max);
      _loc3_ = _loc1_.little_m_slider.value - (-5 + 5 * log_min);
   }
   else if(_loc1_.lock._value == 2)
   {
      var log_max = Math.log(_loc1_.d_slider.max) / 2.302585092994046;
      var log_min = Math.log(_loc1_.d_slider.min) / 2.302585092994046;
      var m_max = -5 + 5 * log_max + _loc1_.big_M_slider.value;
      var m_min = -5 + 5 * log_min + _loc1_.big_M_slider.value;
      _loc3_ = 18;
      _loc2_ = -8;
   }
   else if(_loc1_.lock._value == 3)
   {
      var log = Math.log(_loc1_.d_slider.value) / 2.302585092994046;
      var m_max = -5 + 5 * log + _loc1_.big_M_slider.max;
      var m_min = -5 + 5 * log + _loc1_.big_M_slider.min;
      _loc3_ = 18;
      _loc2_ = -8;
   }
   _loc1_.little_m_slider.max = Math.round(10 * m_max) / 10;
   _loc1_.little_m_slider.min = Math.round(10 * m_min) / 10;
   _loc1_.big_M_slider.max = Math.round(10 * _loc3_) / 10;
   _loc1_.big_M_slider.min = Math.round(10 * _loc2_) / 10;
   if(_loc1_.little_m_slider.value > m_max)
   {
      _loc1_.little_m_slider.value = m_max;
   }
   else if(_loc1_.little_m_slider.value < m_min)
   {
      _loc1_.little_m_slider.value = m_min;
   }
   else
   {
      _loc1_.little_m_slider.value = _loc1_.little_m_slider.value;
   }
   if(_loc1_.big_M_slider.value > _loc3_)
   {
      _loc1_.big_M_slider.value = _loc3_;
   }
   else if(_loc1_.big_M_slider.value < _loc2_)
   {
      _loc1_.big_M_slider.value = _loc2_;
   }
   else
   {
      _loc1_.big_M_slider.value = _loc1_.big_M_slider.value;
   }
};
p.calculateValues = function()
{
   var _loc1_ = this;
   var _loc3_;
   var _loc2_;
   if(_loc1_.lock._value == 1)
   {
      _loc3_ = _loc1_.little_m_slider.value;
      var m_M;
      var d;
      if(_loc1_.big_M_slider.inUse)
      {
         _loc2_ = _loc1_.big_M_slider.value;
         m_M = _loc3_ - _loc2_;
         d = Math.pow(10,(m_M + 5) / 5);
         _loc1_.d_slider.value = d;
      }
      else if(_loc1_.d_slider.inUse || _loc1_.starMove)
      {
         d = _loc1_.d_slider.value;
         _loc2_ = _loc3_ - (-5 + 5 * (Math.log(d) / 2.302585092994046));
         _loc1_.big_M_slider.value = _loc2_;
         m_M = _loc3_ - _loc2_;
      }
      else
      {
         d = _loc1_.d_slider.value;
         _loc2_ = _loc1_.big_M_slider.value;
         m_M = _loc3_ - _loc2_;
      }
   }
   else if(_loc1_.lock._value == 2)
   {
      _loc2_ = _loc1_.big_M_slider.value;
      var m_M;
      var d;
      if(_loc1_.little_m_slider.inUse)
      {
         _loc3_ = _loc1_.little_m_slider.value;
         m_M = _loc3_ - _loc2_;
         d = Math.pow(10,(m_M + 5) / 5);
         _loc1_.d_slider.value = d;
      }
      else if(_loc1_.d_slider.inUse || _loc1_.starMove)
      {
         d = _loc1_.d_slider.value;
         _loc3_ = -5 + 5 * (Math.log(d) / 2.302585092994046) + _loc2_;
         _loc1_.little_m_slider.value = _loc3_;
         m_M = _loc3_ - _loc2_;
      }
      else
      {
         d = _loc1_.d_slider.value;
         _loc3_ = _loc1_.little_m_slider.value;
         m_M = _loc3_ - _loc2_;
      }
   }
   else if(_loc1_.lock._value == 3)
   {
      var d = _loc1_.d_slider.value;
      var m_M = -5 + 5 * (Math.log(d) / 2.302585092994046);
      if(_loc1_.little_m_slider.inUse)
      {
         _loc3_ = _loc1_.little_m_slider.value;
         _loc2_ = _loc3_ - m_M;
         _loc1_.big_M_slider.value = _loc2_;
      }
      else if(_loc1_.big_M_slider.inUse)
      {
         _loc2_ = _loc1_.big_M_slider.value;
         _loc3_ = m_M + _loc2_;
         _loc1_.little_M_slider.value = _loc3_;
      }
      else
      {
         _loc2_ = _loc1_.big_M_slider.value;
         _loc3_ = _loc1_.little_m_slider.value;
      }
   }
   d = Math.round(d);
   _loc3_ = Math.round(10 * _loc3_) / 10 + "";
   _loc1_.changeStar(_loc2_);
   _loc2_ = Math.round(10 * _loc2_) / 10 + "";
   m_M = Math.round(10 * m_M) / 10 + "";
   var lStartPt = 0;
   var lStopPt = _loc3_.length;
   var bStartPt;
   if(_loc2_ >= 0)
   {
      bStartPt = lStopPt + 3;
      _loc1_.myEquation.equation.text = _loc3_ + " - " + _loc2_ + " = " + m_M;
   }
   else
   {
      bStartPt = lStopPt + 4;
      _loc1_.myEquation.equation.text = _loc3_ + " - (" + _loc2_ + ") = " + m_M;
   }
   var bStopPt = bStartPt + _loc2_.length;
   _loc1_.myEquation.equation.setTextFormat(lStartPt,lStopPt,_loc1_.littleText);
   _loc1_.myEquation.equation.setTextFormat(bStartPt,bStopPt,_loc1_.bigText);
   _loc1_.myEquation.d_box.text = d + " pc";
   _loc1_.myEquation.d_ly_box.text = "(" + _loc1_.lightyears(d) + " ly)";
};
p.moveStar = function()
{
   var _loc2_ = Math.log(this.d_slider.value) / 2.302585092994046;
   var _loc1_ = _loc2_ * 140;
   this.myStar._x = _loc1_;
};
p.changeStar = function(bigM)
{
   var _loc3_ = 18;
   var _loc1_ = -8;
   var alpha = 100 - (bigM - _loc1_) * (30 / (_loc3_ - _loc1_));
   var _loc2_ = 100 - (bigM - _loc1_) * (20 / (_loc3_ - _loc1_)) + 20;
   this.myStar._alpha = alpha;
   this.myStar._xscale = _loc2_;
   this.myStar._yscale = _loc2_;
};
p.lightyears = function(parsecs)
{
   return Math.round(parsecs * 3.2616344375571);
};
