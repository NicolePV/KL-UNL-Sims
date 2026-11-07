function changePlanets(obj)
{
   var _loc1_ = obj.getValue();
   if(_loc1_ == "Superior")
   {
      pmode = 1;
      e1_txt._visible = true;
      e2_txt._visible = false;
      p1_txt._visible = false;
      p2_txt._visible = true;
      eq1._visible = true;
      eq2._visible = false;
      p1_txt.text = "";
      p2_txt.text = "";
      s_txt.text = "";
   }
   else if(_loc1_ == "Inferior")
   {
      pmode = 2;
      e1_txt._visible = false;
      e2_txt._visible = true;
      p1_txt._visible = true;
      p2_txt._visible = false;
      eq1._visible = false;
      eq2._visible = true;
      p1_txt.text = "";
      p2_txt.text = "";
      s_txt.text = "";
   }
}
function changeUnits(obj)
{
   var _loc1_ = obj.getValue();
   if(_loc1_ == "Years")
   {
      umode = 1;
      e1_txt.text = "1.00";
      e2_txt.text = "1.00";
      p1_txt.text = "";
      p2_txt.text = "";
      s_txt.text = "";
   }
   else if(_loc1_ == "Days")
   {
      umode = 2;
      e1_txt.text = "365.25";
      e2_txt.text = "365.25";
      p1_txt.text = "";
      p2_txt.text = "";
      s_txt.text = "";
   }
}
s_txt.restrict = "0-9.e";
p1_txt.restrict = "0-9.e";
p2_txt.restrict = "0-9.e";
var pmode = 1;
var umode = 1;
e1_txt.text = "1.00";
e2_txt.text = "1.00";
e1_txt._visible = true;
e2_txt._visible = false;
p1_txt._visible = false;
p2_txt._visible = true;
eq1._visible = true;
eq2._visible = false;
p2_txt.onChanged = function()
{
   var _loc1_ = parseFloat(p2_txt.text);
   if(_loc1_ > 0 && isFinite(_loc1_))
   {
      if(umode == 1)
      {
         if(_loc1_ > 1)
         {
            s_txt.textColor = 1579263;
            s_txt.text = Math.round(100 * (1 / (1 - 1 / _loc1_))) / 100;
         }
         else
         {
            s_txt.textColor = 16253183;
            s_txt.text = "Ouch!";
         }
      }
      else if(umode == 2)
      {
         if(_loc1_ > 365.25)
         {
            s_txt.textColor = 1579263;
            s_txt.text = Math.round(100 * (1 / (0.0027378507871321013 - 1 / _loc1_))) / 100;
         }
         else
         {
            s_txt.textColor = 16253183;
            s_txt.text = "Ouch!";
         }
      }
   }
   else
   {
      s_txt.text = "";
   }
};
p1_txt.onChanged = function()
{
   var _loc1_ = parseFloat(p1_txt.text);
   if(_loc1_ > 0 && isFinite(_loc1_))
   {
      if(umode == 1)
      {
         if(_loc1_ < 1)
         {
            s_txt.textColor = 1579263;
            s_txt.text = Math.round(100 * (1 / (1 / _loc1_ - 1))) / 100;
         }
         else
         {
            s_txt.textColor = 16253183;
            s_txt.text = "Ouch!";
         }
      }
      else if(umode == 2)
      {
         if(_loc1_ < 365.25)
         {
            s_txt.textColor = 1579263;
            s_txt.text = Math.round(100 * (1 / (1 / _loc1_ - 0.0027378507871321013))) / 100;
         }
         else
         {
            s_txt.textColor = 16253183;
            s_txt.text = "Ouch!";
         }
      }
   }
   else
   {
      s_txt.text = "";
   }
};
s_txt.onChanged = function()
{
   var _loc1_ = parseFloat(s_txt.text);
   if(_loc1_ > 0 && isFinite(_loc1_))
   {
      if(pmode == 1 & umode == 1)
      {
         tmp2 = Math.round(100 * (1 / (1 - 1 / _loc1_))) / 100;
         if(tmp2 > 0)
         {
            p2_txt.textColor = 1579263;
            p2_txt.text = tmp2;
         }
         else
         {
            p2_txt.textColor = 16253183;
            p2_txt.text = "Ouch!";
         }
      }
      else if(pmode == 1 & umode == 2)
      {
         tmp2 = Math.round(100 * (1 / (0.0027378507871321013 - 1 / _loc1_))) / 100;
         if(tmp2 > 0)
         {
            p2_txt.textColor = 1579263;
            p2_txt.text = tmp2;
         }
         else
         {
            p2_txt.textColor = 16253183;
            p2_txt.text = "Ouch!";
         }
      }
      else if(pmode == 2 & umode == 1)
      {
         tmp2 = Math.round(100 * (1 / (1 / _loc1_ + 1))) / 100;
         if(tmp2 > 0)
         {
            p1_txt.text = tmp2;
         }
         else
         {
            p1_txt.textColor = 16253183;
            p1_txt.text = "Ouch!";
         }
      }
      else if(pmode == 2 & umode == 2)
      {
         tmp2 = Math.round(100 * (1 / (1 / _loc1_ + 0.0027378507871321013))) / 100;
         if(tmp2 > 0)
         {
            p1_txt.textColor = 1579263;
            p1_txt.text = tmp2;
         }
         else
         {
            p1_txt.textColor = 16253183;
            p1_txt.text = "Ouch!";
         }
      }
   }
   else
   {
      p1_txt.text = "";
      p2_txt.text = "";
   }
};
