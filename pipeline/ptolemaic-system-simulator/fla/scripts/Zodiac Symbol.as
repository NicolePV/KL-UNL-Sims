function ZodiacSymbolClass()
{
   var _loc1_ = this;
   if(_loc1_.symbolAlpha != undefined)
   {
      _loc1_.symbolField._alpha = _loc1_.symbolAlpha;
   }
   if(_loc1_.symbolColor != undefined)
   {
      _loc1_.symbolField.textColor = _loc1_.symbolColor;
   }
   if(_loc1_.nameAlpha != undefined)
   {
      _loc1_.nameField._alpha = _loc1_.nameAlpha;
   }
   if(_loc1_.nameColor != undefined)
   {
      _loc1_.nameField.textColor = _loc1_.nameColor;
   }
}
var p = ZodiacSymbolClass.prototype = new MovieClip();
Object.registerClass("Zodiac Symbol",ZodiacSymbolClass);
