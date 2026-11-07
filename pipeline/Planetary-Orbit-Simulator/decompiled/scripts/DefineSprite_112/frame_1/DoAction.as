function bringToFront(frontMC)
{
   var _loc3_ = frontMC;
   _loc3_.swapDepths(topDepth);
   var _loc2_ = 0;
   var _loc1_;
   while(_loc2_ < numTabs)
   {
      _loc1_ = this["tab" + _loc2_];
      if(_loc1_ == _loc3_)
      {
         _loc1_.labelField.textColor = 0;
      }
      else
      {
         _loc1_.labelField.textColor = 6710886;
      }
      _loc2_ = _loc2_ + 1;
   }
   this._parent.onTabPressed(_loc3_.value);
}
numTabs = 4;
topDepth = -Infinity;
var i = 0;
while(i < numTabs)
{
   var d = this["tab" + i].getDepth();
   if(d > topDepth)
   {
      topDepth = d;
   }
   i++;
}
bringToFront(tab0);
