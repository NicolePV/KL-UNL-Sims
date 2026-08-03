function onReset()
{
   var startTimer = getTimer();
   hrDiagramWindowMC._visible = false;
   if(onEnterFrame == onEnterFrameFunc)
   {
      changeAnimateState();
   }
   animationSpeedSlider.value = 0.0001;
   showLightcurveCheck.setValue(true);
   sysProps.a = this.initParamsObj.separation;
   sysProps.e = this.initParamsObj.eccentricity;
   star1.r = this.initParamsObj.radius1;
   star1.m = this.initParamsObj.mass1;
   star1.t = this.initParamsObj.temperature1;
   star1.l = getLfromRT(star1.r,star1.t);
   star2.r = this.initParamsObj.radius2;
   star2.m = this.initParamsObj.mass2;
   star2.t = this.initParamsObj.temperature2;
   star2.l = getLfromRT(star2.r,star2.t);
   setMassRange(1);
   setRadiusRange(1);
   setTempRange(1);
   setMassRange(2);
   setRadiusRange(2);
   setTempRange(2);
   setSeparationRange();
   setEccentricityRange();
   inclinationSlider.value = this.initParamsObj.inclination;
   longitudeSlider.value = this.initParamsObj.longitude;
   separationSlider.value = sysProps.a;
   eccentricitySlider.value = sysProps.e;
   mass1Slider.value = star1.m;
   radius1Slider.value = star1.r;
   temp1Slider.value = star1.t;
   mass2Slider.value = star2.m;
   radius2Slider.value = star2.r;
   temp2Slider.value = star2.t;
   var period = 0.115496 * Math.sqrt(Math.pow(sysProps.a,3) / (star1.m + star2.m));
   systemPeriodField.text = "system period: " + Math.toSigDigits(period,3) + " days";
   visualizationMC.initialize(this.initParamsObj);
   visualizationMC.passObjectToIcon(1,{temp:star1.t});
   visualizationMC.passObjectToIcon(2,{temp:star2.t});
   hrDiagramWindowMC.hrDiagramMC.setPointPosition(1,star1.t,star1.l);
   hrDiagramWindowMC.hrDiagramMC.setPointPosition(2,star2.t,star2.l);
   curveMC.phaseOffset = 1.5;
   drawLightCurve();
   setPhase(0.7);
   perspectiveLockCheck.setValue(true);
   showOrbitalPathsCheck.setValue(true);
   showOrbitalPlaneCheck.setValue(true);
   systemsList.setSelectedIndex(0);
   trace("onReset: " + (getTimer() - startTimer));
}
