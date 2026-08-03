on(release){
   if(startstop._currentframe != 2)
   {
      if(retrograde._currentframe == 2 || startstop._currentframe == 1)
      {
         time._x = time.left;
         retrograde.gotoAndStop(1);
      }
   }
}
