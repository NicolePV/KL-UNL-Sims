p_txt.restrict = "0-9.e";
a_txt.restrict = "0-9.e";
p_txt.onChanged = function()
{
   var _loc1_ = parseFloat(p_txt.text);
   if(_loc1_ > 0 && isFinite(_loc1_))
   {
      a_txt.text = Math.round(1000 * Math.pow(_loc1_,0.6666666666666666)) / 1000;
   }
   else if(_loc1_ == 0)
   {
      a_txt.text = 0;
   }
   else
   {
      a_txt.text = "";
   }
};
a_txt.onChanged = function()
{
   var _loc1_ = parseFloat(a_txt.text);
   if(_loc1_ > 0 && isFinite(_loc1_))
   {
      p_txt.text = Math.round(1000 * Math.pow(_loc1_,1.5)) / 1000;
   }
   else if(_loc1_ == 0)
   {
      p_txt.text = 0;
   }
   else
   {
      p_txt.text = "";
   }
};
