function SkyDiagramClass()
{
}
var p = SkyDiagramClass.prototype = new MovieClip();
Object.registerClass("Sky Diagram",SkyDiagramClass);
p.setShowLabels = function(arg)
{
   var _loc1_ = this;
   var _loc2_ = arg;
   _loc1_.starsMC.northStarLineMC._visible = _loc2_;
   _loc1_.starsMC.northStarLabelMC._visible = _loc2_;
   _loc1_.starsMC.bigDipperLabelMC._visible = _loc2_;
   _loc1_.starsMC.littleDipperLabelMC._visible = _loc2_;
   _loc1_.starsMC.cassiopeiaLabelMC._visible = _loc2_;
};
p.setSolarDaysSinceZero = function(solDaysSinceZero)
{
   var _loc1_ = this;
   _loc1_.starsMC._rotation = (102.5 - 360 * (solDaysSinceZero * 366 / 365 - 0.49583333333333335)) % 360;
   _loc1_.starsMC.northStarLabelMC._rotation = - _loc1_.starsMC._rotation;
   _loc1_.starsMC.bigDipperLabelMC._rotation = - _loc1_.starsMC._rotation;
   _loc1_.starsMC.littleDipperLabelMC._rotation = - _loc1_.starsMC._rotation;
   _loc1_.starsMC.cassiopeiaLabelMC._rotation = - _loc1_.starsMC._rotation;
   var _loc3_ = ((solDaysSinceZero - 0.5) % 1 + 1) % 1;
   var twilightAngle = 0.12217304763960307;
   var latitude = 0.7155849933176751;
   var sunLongitude = solDaysSinceZero / 365 * 2 * 3.141592653589793;
   var sunDeclination = Math.asin(0.39714789063478056 * Math.sin(sunLongitude));
   var sinSunDec = Math.sin(sunDeclination);
   var sinLat = Math.sin(latitude);
   var cosSunDec = Math.cos(sunDeclination);
   var cosLat = Math.cos(latitude);
   var zTwilight = Math.sin(- twilightAngle);
   var sinProduct = sinSunDec * sinLat;
   var cosProduct = cosSunDec * cosLat;
   var cosAlphaAtTwilightLimit = (zTwilight - sinProduct) / cosProduct;
   var cosAlphaOnHorizon = (- sinProduct) / cosProduct;
   var neverAboveTwilightLimit = cosAlphaAtTwilightLimit >= 1;
   var neverBelowTwilightLimit = cosAlphaAtTwilightLimit <= -1;
   var neverAboveHorizon = cosAlphaOnHorizon >= 1;
   var neverBelowHorizon = cosAlphaOnHorizon <= -1;
   var _loc2_;
   if(neverBelowHorizon)
   {
      trace("something that shouldn\'t happen has happened! (case 1)");
   }
   else if(neverAboveTwilightLimit)
   {
      trace("something that shouldn\'t happen has happened! (case 2)");
   }
   else
   {
      var twilightStartAlpha;
      var twilightEndAlpha;
      if(neverBelowTwilightLimit)
      {
         trace("something that shouldn\'t happen has happened! (cases 3 or 4)");
      }
      else
      {
         twilightStartAlpha = Math.acos(cosAlphaAtTwilightLimit);
         var nightEnds = 0.5 * (1 - twilightStartAlpha / 3.141592653589793);
         var nightStarts = 0.5 * (1 + twilightStartAlpha / 3.141592653589793);
         if(neverAboveHorizon)
         {
            trace("something that shouldn\'t happen has happened! (cases 3 or 5)");
         }
         else
         {
            twilightEndAlpha = Math.acos(cosAlphaOnHorizon);
            var dayStarts = 0.5 * (1 - twilightEndAlpha / 3.141592653589793);
            var dayEnds = 0.5 * (1 + twilightEndAlpha / 3.141592653589793);
            var twilightFraction = dayStarts - nightEnds;
            if(_loc3_ > 0.5)
            {
               _loc3_ = 1 - _loc3_;
            }
            _loc2_ = (_loc3_ - nightEnds) / twilightFraction;
            if(_loc2_ < 0)
            {
               _loc2_ = 0;
            }
            else if(_loc2_ > 1)
            {
               _loc2_ = 1;
            }
            _loc1_.skyMC._alpha = _loc2_ * 100;
         }
      }
   }
};
