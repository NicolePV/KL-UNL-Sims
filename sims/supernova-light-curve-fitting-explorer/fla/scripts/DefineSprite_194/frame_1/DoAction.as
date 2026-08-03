function update()
{
   var _loc4_ = parseFloat(appMagField.text);
   var _loc5_ = parseFloat(absMagField.text);
   var _loc3_;
   var _loc2_;
   if(isNaN(_loc4_) || isNaN(_loc5_))
   {
      _global.displayText("...",distanceTextOptions);
      _global.displayText("...",modulusTextOptions);
   }
   else
   {
      _loc3_ = _loc4_ - _loc5_;
      _loc2_ = Math.pow(10,(_loc3_ + 5) / 5);
      if(!isFinite(_loc3_))
      {
         _global.displayText("...",modulusTextOptions);
      }
      else
      {
         _global.displayText(_loc3_,modulusTextOptions);
      }
      if(!isFinite(_loc2_))
      {
         _global.displayText("...",distanceTextOptions);
      }
      else if(_loc2_ == 0)
      {
         _global.displayText("0 pc",distanceTextOptions);
      }
      else if(_loc2_ < 0.001 || _loc2_ > 100000)
      {
         _global.displayText((_loc2_ / 1000000).toFixed(1) + " Mpc",distanceTextOptions);
      }
      else
      {
         _global.displayText(formatNumber(_loc2_,3) + " pc",distanceTextOptions);
      }
   }
}
function formatNumber(num, digits)
{
   var _loc1_ = Math.floor(Math.log(num) / 2.302585092994046) - (digits - 1);
   var _loc2_;
   if(_loc1_ >= 0)
   {
      _loc2_ = Math.pow(10,_loc1_);
      return String(_loc2_ * Math.round(num / _loc2_));
   }
   return num.toFixed(- _loc1_);
}
distanceTextOptions = {};
distanceTextOptions.mc = this;
distanceTextOptions.depth = 100;
distanceTextOptions.x = 173;
distanceTextOptions.y = -18;
distanceTextOptions.hAlign = "left";
distanceTextOptions.vAlign = "center";
distanceTextOptions.embedFonts = true;
distanceTextOptions.textFormat = new TextFormat("Verdana",14);
modulusTextOptions = {};
modulusTextOptions.mc = this;
modulusTextOptions.depth = 101;
modulusTextOptions.x = 63;
modulusTextOptions.y = -18;
modulusTextOptions.hAlign = "right";
modulusTextOptions.vAlign = "center";
modulusTextOptions.embedFonts = true;
modulusTextOptions.textFormat = new TextFormat("Verdana",14);
appMagField.restrict = "0-9.+\\-";
absMagField.restrict = "0-9.+\\-";
appMagField.onChanged = update;
absMagField.onChanged = update;
update();
