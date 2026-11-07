function changeTrailType()
{
   var _loc1_;
   var _loc2_;
   if(trailTypeGroup.getValue() == "none")
   {
      maxTrailLength = 0;
      _loc1_ = 0;
      while(_loc1_ < starsList.length)
      {
         sphere2[starsList[_loc1_]].setTrailLength(0);
         _loc1_ = _loc1_ + 1;
      }
   }
   else if(trailTypeGroup.getValue() == "short")
   {
      maxTrailLength = 45;
      _loc1_ = 0;
      while(_loc1_ < starsList.length)
      {
         _loc2_ = sphere2[starsList[_loc1_]];
         if(_loc2_.trailLength > maxTrailLength)
         {
            _loc2_.setTrailLength(maxTrailLength);
         }
         _loc1_ = _loc1_ + 1;
      }
   }
   else
   {
      maxTrailLength = 360;
   }
}
function resetTrails()
{
   var _loc1_ = 0;
   while(_loc1_ < starsList.length)
   {
      sphere2[starsList[_loc1_]].setTrailLength(0);
      _loc1_ = _loc1_ + 1;
   }
}
function growStarTrails(delta)
{
   var _loc4_;
   var _loc3_;
   var _loc1_;
   var _loc2_;
   if(trailTypeGroup.getValue() != "none")
   {
      _loc4_ = maxTrailLength;
      _loc3_ = 0;
      while(_loc3_ < starsList.length)
      {
         _loc1_ = sphere2[starsList[_loc3_]];
         _loc2_ = _loc1_.trailLength + delta;
         if(_loc1_.trailLength >= _loc4_)
         {
            if(_loc4_ != 360)
            {
               _loc1_.trailCircle.update();
            }
         }
         else
         {
            if(_loc2_ > _loc4_)
            {
               _loc2_ = _loc4_;
            }
            _loc1_.setTrailLength(_loc2_);
         }
         _loc3_ = _loc3_ + 1;
      }
   }
}
maxTrailLength = 0;
_root.CSObjectsClass.prototype.addTrail = function()
{
   this.trailCircle = this._parent.addCircle("t" + this._name,{thickness:1,color:16777215,alpha:60},{ra:0,dec:0,tilt:0});
   this.trailCircle.visible = false;
};
_root.CSObjectsClass.prototype.updateTrail = function()
{
   var _loc3_ = 57.29577951308232 * Math.asin(this._p.z);
   var _loc2_;
   if(this.trailLength == 360)
   {
      this.trailCircle.setParameters({ra:0,dec:_loc3_,tilt:0});
   }
   else
   {
      _loc2_ = 57.29577951308232 * Math.atan2(this._p.y,this._p.x);
      this.trailCircle.setParameters({ra:0,dec:_loc3_,tilt:0,gammaStart:_loc2_,gammaEnd:_loc2_ + this.trailLength});
   }
};
_root.CSObjectsClass.prototype.removeTrail = function()
{
   this.trailCircle.remove();
};
_root.CSObjectsClass.prototype.setTrailLength = function(arg)
{
   this.trailLength = arg;
   if(arg == 0)
   {
      this.trailCircle.visible = false;
   }
   else
   {
      this.updateTrail();
      this.trailCircle.setVisible(true);
   }
};
