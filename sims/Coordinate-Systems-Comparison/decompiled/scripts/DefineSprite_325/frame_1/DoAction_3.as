function updateBands()
{
   if(observerLatitude >= 90)
   {
      sphere2.riseAndSetBand.setParameters(null);
      sphere2.neverRiseBand.setParameters({dec1:-90,dec2:0});
      sphere2.neverSetBand.setParameters({dec1:0,dec2:90});
      sphere1.riseAndSetBand.setParameters(null);
      sphere1.neverRiseBand.setParameters({dec1:-90,dec2:0});
      sphere1.neverSetBand.setParameters({dec1:0,dec2:90});
   }
   else if(observerLatitude <= -90)
   {
      sphere2.riseAndSetBand.setParameters(null);
      sphere2.neverRiseBand.setParameters({dec1:0,dec2:90});
      sphere2.neverSetBand.setParameters({dec1:0,dec2:-90});
      sphere1.riseAndSetBand.setParameters(null);
      sphere1.neverRiseBand.setParameters({dec1:0,dec2:90});
      sphere1.neverSetBand.setParameters({dec1:0,dec2:-90});
   }
   else if(observerLatitude > 0)
   {
      upperLimit = 90 - observerLatitude;
      lowerLimit = - upperLimit;
      sphere2.riseAndSetBand.setParameters({dec1:lowerLimit,dec2:upperLimit});
      sphere2.neverRiseBand.setParameters({dec1:-90,dec2:lowerLimit});
      sphere2.neverSetBand.setParameters({dec1:upperLimit,dec2:90});
      sphere1.riseAndSetBand.setParameters({dec1:lowerLimit,dec2:upperLimit});
      sphere1.neverRiseBand.setParameters({dec1:-90,dec2:lowerLimit});
      sphere1.neverSetBand.setParameters({dec1:upperLimit,dec2:90});
   }
   else if(observerLatitude < 0)
   {
      upperLimit = 90 + observerLatitude;
      lowerLimit = - upperLimit;
      sphere2.riseAndSetBand.setParameters({dec1:lowerLimit,dec2:upperLimit});
      sphere2.neverRiseBand.setParameters({dec1:90,dec2:upperLimit});
      sphere2.neverSetBand.setParameters({dec1:lowerLimit,dec2:-90});
      sphere1.riseAndSetBand.setParameters({dec1:lowerLimit,dec2:upperLimit});
      sphere1.neverRiseBand.setParameters({dec1:90,dec2:upperLimit});
      sphere1.neverSetBand.setParameters({dec1:lowerLimit,dec2:-90});
   }
   else
   {
      sphere2.riseAndSetBand.setParameters({dec1:-90,dec2:90});
      sphere2.neverRiseBand.setParameters(null);
      sphere2.neverSetBand.setParameters(null);
      sphere1.riseAndSetBand.setParameters({dec1:-90,dec2:90});
      sphere1.neverRiseBand.setParameters(null);
      sphere1.neverSetBand.setParameters(null);
   }
   sphere2.updateShadedBands();
   sphere1.updateShadedBands();
}
