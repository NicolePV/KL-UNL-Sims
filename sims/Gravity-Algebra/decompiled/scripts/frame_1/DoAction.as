function onChange()
{
   var _loc7_ = m1Multiplier.getSelectedChoice();
   var _loc6_ = m2Multiplier.getSelectedChoice();
   var _loc1_ = rMultiplier.getSelectedChoice();
   var _loc4_ = _loc7_.p2 + _loc6_.p2 - (_loc1_.p2 + _loc1_.p2);
   var _loc3_ = _loc7_.p3 + _loc6_.p3 - (_loc1_.p3 + _loc1_.p3);
   var _loc2_ = 1;
   var _loc5_ = 1;
   if(_loc4_ < 0)
   {
      _loc2_ *= Math.pow(2,- _loc4_);
   }
   else
   {
      _loc5_ *= Math.pow(2,_loc4_);
   }
   if(_loc3_ < 0)
   {
      _loc2_ *= Math.pow(3,- _loc3_);
   }
   else
   {
      _loc5_ *= Math.pow(3,_loc3_);
   }
   if(_loc2_ == 1)
   {
      fraction._visible = false;
      wholeNumber._visible = true;
      wholeNumber.text = _loc5_;
   }
   else
   {
      fraction._visible = true;
      wholeNumber._visible = false;
      fraction.numerator.text = _loc5_.toString();
      fraction.denominator.text = _loc2_.toString();
   }
   var _loc8_ = Math.pow(2,_loc4_) * Math.pow(3,_loc3_);
}
titlebar.swapDepths(1000020);
m1Multiplier.changeHandler = onChange;
m2Multiplier.changeHandler = onChange;
rMultiplier.changeHandler = onChange;
onChange();
