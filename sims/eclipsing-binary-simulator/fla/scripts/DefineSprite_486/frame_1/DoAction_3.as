function setEccentricityRange()
{
   var EmaxVis = 1 - (star1.r + star2.r) / sysProps.a;
   Emin = EminSld;
   Emax = Math.min(EmaxSld,EmaxVis);
   eccentricitySlider.setRange(Emin,Emax);
}
function setSeparationRange()
{
   var AminVis = (star1.r + star2.r) / (1 - sysProps.e);
   Amin = Math.max(AminSld,AminVis);
   Amax = AmaxSld;
   separationSlider.setRange(Amin,Amax);
}
function setTempRange(star)
{
   if(star == 1)
   {
      var thisStar = star1;
      var otherStar = star2;
      var thisTempSlider = temp1Slider;
   }
   else
   {
      if(star != 2)
      {
         return undefined;
      }
      var thisStar = star2;
      var otherStar = star1;
      var thisTempSlider = temp2Slider;
   }
   var TminHR = getTfromLR(Lmin,thisStar.r);
   var TmaxHR = getTfromLR(Lmax,thisStar.r);
   Tmin = Math.max(TminSld,TminHR);
   Tmax = Math.min(TmaxSld,TmaxHR);
   thisTempSlider.setRange(Tmin,Tmax);
}
function setRadiusRange(star)
{
   if(star == 1)
   {
      var thisStar = star1;
      var otherStar = star2;
      var thisRadiusSlider = radius1Slider;
   }
   else
   {
      if(star != 2)
      {
         return undefined;
      }
      var thisStar = star2;
      var otherStar = star1;
      var thisRadiusSlider = radius2Slider;
   }
   var RmaxVis = sysProps.a * (1 - sysProps.e) - otherStar.r;
   var RminHR = getRfromTL(thisStar.t,Lmin);
   var RmaxHR = getRfromTL(thisStar.t,Lmax);
   Rmin = Math.max(RminSld,RminHR);
   Rmax = Math.min(Math.min(RmaxSld,RmaxHR),RmaxVis);
   thisRadiusSlider.setRange(Rmin,Rmax);
}
function setMassRange(star)
{
   if(star == 1)
   {
      var thisStar = star1;
      var otherStar = star2;
      var thisMassSlider = mass1Slider;
   }
   else
   {
      if(star != 2)
      {
         return undefined;
      }
      var thisStar = star2;
      var otherStar = star1;
      var thisMassSlider = mass2Slider;
   }
   Mmin = MminSld;
   Mmax = MmaxSld;
   thisMassSlider.setRange(Mmin,Mmax);
}
function setRestrictedStarRanges(star)
{
   if(star == 1)
   {
      var thisStar = star1;
      var otherStar = star2;
      var thisMassSlider = mass1Slider;
      var thisRadiusSlider = radius1Slider;
      var thisTempSlider = temp1Slider;
   }
   else
   {
      if(star != 2)
      {
         return undefined;
      }
      var thisStar = star2;
      var otherStar = star1;
      var thisMassSlider = mass2Slider;
      var thisRadiusSlider = radius2Slider;
      var thisTempSlider = temp2Slider;
   }
   var RmaxVis = sysProps.a * (1 - sysProps.e) - otherStar.r;
   Rmin = RminMS;
   Rmax = Math.min(RmaxMS,RmaxVis);
   var TmaxVis = getTfromR(RmaxVis);
   Tmin = TminSld;
   Tmax = Math.min(TmaxSld,TmaxVis);
   var LmaxVis = getLfromRT(RmaxVis,TmaxVis);
   var MmaxVis = getMfromL(LmaxVis);
   Mmin = MminMS;
   Mmax = Math.min(MmaxMS,MmaxVis);
   thisMassSlider.setRange(Mmin,Mmax);
   thisRadiusSlider.setRange(Rmin,Rmax);
   thisTempSlider.setRange(Tmin,Tmax);
}
function setUnrestrictStar(star)
{
   setMassRange(star);
   setRadiusRange(star);
   setTempRange(star);
}
function setRestrictToMainSequence(star)
{
   if(star == 1)
   {
      var otherStarNumber = 2;
      thisStar = star1;
      otherStar = star2;
   }
   else
   {
      if(star != 2)
      {
         return undefined;
      }
      var otherStarNumber = 1;
      thisStar = star2;
      otherStar = star1;
   }
   var RmaxVis = sysProps.a * (1 - sysProps.e) - otherStar.r;
   var TmaxVis = getTfromR(RmaxVis);
   var Tmin = TminSld;
   var Tmax = Math.min(TmaxSld,TmaxVis);
   if(Tmin > Tmax)
   {
      trace("case where T is too big");
      thisStar.t = Tmin;
      thisStar.l = getLfromT(thisStar.t);
      thisStar.m = getMfromL(thisStar.l);
      thisStar.r = getRfromTL(thisStar.t,thisStar.l);
      var sep = (thisStar.r + otherStar.r) / (1 - sysProps.e);
      if(sep > AmaxSld)
      {
         sysProps.a = AmaxSld;
         sysProps.e = 1 - (thisStar.r + otherStar.r) / sysProps.a;
      }
      else if(sep < AminSld)
      {
         sysProps.a = AminSld;
      }
      else
      {
         sysProps.a = sep;
      }
      eccentricitySlider.value = sysProps.e;
      separationSlider.value = sysProps.a;
      var initObj = {};
      initObj["radius" + star] = thisStar.r;
      initObj["mass" + star] = thisStar.m;
      initObj.eccentricity = sysProps.e;
      initObj.separation = sysProps.a;
      visualizationMC.initialize(initObj);
   }
   else
   {
      var temp = thisStar.t;
      if(temp < Tmin)
      {
         temp = Tmin;
      }
      else if(temp > Tmax)
      {
         temp = Tmax;
      }
      thisStar.t = temp;
      thisStar.l = getLfromT(temp);
      thisStar.r = getRfromTL(temp,thisStar.l);
      thisStar.m = getMfromL(thisStar.l);
      var initObj = {};
      initObj["radius" + star] = thisStar.r;
      initObj["mass" + star] = thisStar.m;
      visualizationMC.initialize(initObj);
   }
   this["mass" + star + "Slider"].value = thisStar.m;
   this["radius" + star + "Slider"].value = thisStar.r;
   this["temp" + star + "Slider"].value = thisStar.t;
   hrDiagramWindowMC.hrDiagramMC.setPointPosition(star,thisStar.t,thisStar.l);
   visualizationMC.passObjectToIcon(star,{temp:thisStar.t});
   drawLightCurve();
   visualizationMC.phase = curveMC._cursorPhase + curveMC._closestIndex / curveMC._numCurvePoints;
   var period = 0.115496 * Math.sqrt(Math.pow(sysProps.a,3) / (star1.m + star2.m));
   systemPeriodField.text = "system period: " + Math.toSigDigits(period,3) + " days";
   if(systemsList.getValue() != " ")
   {
      setParametersToMatchButton.setEnabled(true);
   }
   setSeparationRange();
   setEccentricityRange();
   setRestrictedStarRanges(star);
   var otherRestricted = this["restrict" + otherStarNumber + "Check"].getValue();
   if(otherRestricted)
   {
      setRestrictedStarRanges(otherStarNumber);
   }
   else
   {
      setRadiusRange(otherStarNumber);
   }
}
function setEccentricity(arg)
{
   var EmaxVis = 1 - (star1.r + star2.r) / sysProps.a;
   var Emin = EminSld;
   var Emax = Math.min(EmaxSld,EmaxVis);
   if(arg < Emin)
   {
      arg = Emin;
   }
   else if(arg > Emax)
   {
      arg = Emax;
   }
   sysProps.e = arg;
   visualizationMC.eccentricity = arg;
   eccentricitySlider.value = arg;
   drawLightCurve();
   visualizationMC.phase = curveMC._cursorPhase + curveMC._closestIndex / curveMC._numCurvePoints;
   if(systemsList.getValue() != " ")
   {
      setParametersToMatchButton.setEnabled(true);
   }
   setSeparationRange();
   if(this.restrict1Check.getValue())
   {
      setRestrictedStarRanges(1);
   }
   else
   {
      setRadiusRange(1);
   }
   if(this.restrict2Check.getValue())
   {
      setRestrictedStarRanges(2);
   }
   else
   {
      setRadiusRange(2);
   }
}
function setSeparation(arg)
{
   var AminVis = (star1.r + star2.r) / (1 - sysProps.e);
   var Amin = Math.max(AminSld,AminVis);
   var Amax = AmaxSld;
   if(arg < Amin)
   {
      arg = Amin;
   }
   else if(arg > Amax)
   {
      arg = Amax;
   }
   sysProps.a = arg;
   visualizationMC.separation = arg;
   separationSlider.value = arg;
   drawLightCurve();
   var period = 0.115496 * Math.sqrt(Math.pow(sysProps.a,3) / (star1.m + star2.m));
   systemPeriodField.text = "system period: " + Math.toSigDigits(period,3) + " days";
   if(systemsList.getValue() != " ")
   {
      setParametersToMatchButton.setEnabled(true);
   }
   setEccentricityRange();
   if(this.restrict1Check.getValue())
   {
      setRestrictedStarRanges(1);
   }
   else
   {
      setRadiusRange(1);
   }
   if(this.restrict2Check.getValue())
   {
      setRestrictedStarRanges(2);
   }
   else
   {
      setRadiusRange(2);
   }
}
function setTempAndLuminosity(star, temp, lum)
{
   if(star == 1)
   {
      var otherStarNumber = 2;
      var thisStar = star1;
      var otherStar = star2;
   }
   else
   {
      if(star != 2)
      {
         return undefined;
      }
      var otherStarNumber = 1;
      var thisStar = star2;
      var otherStar = star1;
   }
   if(this["restrict" + star + "Check"].getValue())
   {
      var RmaxVis = sysProps.a * (1 - sysProps.e) - otherStar.r;
      var TmaxVis = getTfromR(RmaxVis);
      var Tmin = TminSld;
      var Tmax = Math.min(TmaxSld,TmaxVis);
      if(temp < Tmin)
      {
         temp = Tmin;
      }
      else if(temp > Tmax)
      {
         temp = Tmax;
      }
      thisStar.t = temp;
      thisStar.l = getLfromT(temp);
      thisStar.r = getRfromTL(temp,thisStar.l);
      thisStar.m = getMfromL(thisStar.l);
      this["mass" + star + "Slider"].value = thisStar.m;
      this["radius" + star + "Slider"].value = thisStar.r;
      this["temp" + star + "Slider"].value = thisStar.t;
      var initObj = {};
      initObj["radius" + star] = thisStar.r;
      initObj["mass" + star] = thisStar.m;
      visualizationMC.initialize(initObj);
      var period = 0.115496 * Math.sqrt(Math.pow(sysProps.a,3) / (star1.m + star2.m));
      systemPeriodField.text = "system period: " + Math.toSigDigits(period,3) + " days";
   }
   else
   {
      if(temp < TminSld)
      {
         temp = TminSld;
      }
      else if(temp > TmaxSld)
      {
         temp = TmaxSld;
      }
      var rad = getRfromTL(temp,lum);
      var RminHR = getRfromTL(temp,Lmin);
      var RmaxHR = getRfromTL(temp,Lmax);
      var RmaxVis = sysProps.a * (1 - sysProps.e) - otherStar.r;
      var Rmin = Math.max(RminSld,RminHR);
      var Rmax = Math.min(Math.min(RmaxSld,RmaxHR),RmaxVis);
      if(Rmin > Rmax + 1e-8)
      {
         rad = RmaxVis;
         temp = getTfromLR(Lmin,rad);
      }
      else if(rad < Rmin)
      {
         rad = Rmin;
      }
      else if(rad > Rmax)
      {
         rad = Rmax;
      }
      thisStar.r = rad;
      thisStar.t = temp;
      thisStar.l = getLFromRT(rad,temp);
      this["radius" + star + "Slider"].value = rad;
      this["temp" + star + "Slider"].value = temp;
      visualizationMC["radius" + star] = rad;
   }
   hrDiagramWindowMC.hrDiagramMC.setPointPosition(star,thisStar.t,thisStar.l);
   visualizationMC.passObjectToIcon(star,{temp:thisStar.t});
   drawLightCurve();
   if(systemsList.getValue() != " ")
   {
      setParametersToMatchButton.setEnabled(true);
   }
   var otherRestricted = this["restrict" + otherStarNumber + "Check"].getValue();
   var thisRestricted = this["restrict" + star + "Check"].getValue();
   setSeparationRange();
   setEccentricityRange();
   if(otherRestricted)
   {
      setRestrictedStarRanges(otherStarNumber);
   }
   else
   {
      setRadiusRange(otherStarNumber);
   }
   if(!thisRestricted)
   {
      setRadiusRange(star);
      setTempRange(star);
   }
}
function setRadius(star, arg)
{
   if(star == 1)
   {
      var otherStarNumber = 2;
      thisStar = star1;
      otherStar = star2;
   }
   else
   {
      if(star != 2)
      {
         return undefined;
      }
      var otherStarNumber = 1;
      thisStar = star2;
      otherStar = star1;
   }
   var RmaxVis = sysProps.a * (1 - sysProps.e) - otherStar.r;
   if(this["restrict" + star + "Check"].getValue())
   {
      var Rmin = RminMS;
      var Rmax = Math.min(RmaxMS,RmaxVis);
      if(arg < Rmin)
      {
         arg = Rmin;
      }
      else if(arg > Rmax)
      {
         arg = Rmax;
      }
      thisStar.r = arg;
      thisStar.t = getTfromR(arg);
      thisStar.l = getLFromRT(arg,thisStar.t);
      thisStar.m = getMfromL(thisStar.l);
      this["mass" + star + "Slider"].value = thisStar.m;
      this["radius" + star + "Slider"].value = thisStar.r;
      this["temp" + star + "Slider"].value = thisStar.t;
      var initObj = {};
      initObj["radius" + star] = thisStar.r;
      initObj["mass" + star] = thisStar.m;
      visualizationMC.initialize(initObj);
      visualizationMC.passObjectToIcon(star,{temp:thisStar.t});
      var period = 0.115496 * Math.sqrt(Math.pow(sysProps.a,3) / (star1.m + star2.m));
      systemPeriodField.text = "system period: " + Math.toSigDigits(period,3) + " days";
   }
   else
   {
      var RminHR = getRfromTL(thisStar.t,Lmin);
      var RmaxHR = getRfromTL(thisStar.t,Lmax);
      var Rmin = Math.max(RminSld,RminHR);
      var Rmax = Math.min(Math.min(RmaxSld,RmaxHR),RmaxVis);
      if(arg < Rmin)
      {
         arg = Rmin;
      }
      else if(arg > Rmax)
      {
         arg = Rmax;
      }
      thisStar.r = arg;
      thisStar.l = getLFromRT(arg,thisStar.t);
      this["radius" + star + "Slider"].value = arg;
      visualizationMC["radius" + star] = arg;
   }
   hrDiagramWindowMC.hrDiagramMC.setPointPosition(star,thisStar.t,thisStar.l);
   drawLightCurve();
   if(systemsList.getValue() != " ")
   {
      setParametersToMatchButton.setEnabled(true);
   }
   var otherRestricted = this["restrict" + otherStarNumber + "Check"].getValue();
   var thisRestricted = this["restrict" + star + "Check"].getValue();
   setSeparationRange();
   setEccentricityRange();
   if(otherRestricted)
   {
      setRestrictedStarRanges(otherStarNumber);
   }
   else
   {
      setRadiusRange(otherStarNumber);
   }
   if(!thisRestricted)
   {
      setTempRange(star);
   }
}
function setTemp(star, arg)
{
   if(star == 1)
   {
      var otherStarNumber = 2;
      thisStar = star1;
      otherStar = star2;
   }
   else
   {
      if(star != 2)
      {
         return undefined;
      }
      var otherStarNumber = 1;
      thisStar = star2;
      otherStar = star1;
   }
   if(this["restrict" + star + "Check"].getValue())
   {
      var RmaxVis = sysProps.a * (1 - sysProps.e) - otherStar.r;
      var TmaxVis = getTfromR(RmaxVis);
      var Tmin = TminSld;
      var Tmax = Math.min(TmaxSld,TmaxVis);
      if(arg < Tmin)
      {
         arg = Tmin;
      }
      else if(arg > Tmax)
      {
         arg = Tmax;
      }
      thisStar.t = arg;
      thisStar.l = getLfromT(arg);
      thisStar.r = getRfromTL(arg,thisStar.l);
      thisStar.m = getMfromL(thisStar.l);
      this["mass" + star + "Slider"].value = thisStar.m;
      this["radius" + star + "Slider"].value = thisStar.r;
      this["temp" + star + "Slider"].value = thisStar.t;
      var initObj = {};
      initObj["radius" + star] = thisStar.r;
      initObj["mass" + star] = thisStar.m;
      visualizationMC.initialize(initObj);
      var period = 0.115496 * Math.sqrt(Math.pow(sysProps.a,3) / (star1.m + star2.m));
      systemPeriodField.text = "system period: " + Math.toSigDigits(period,3) + " days";
   }
   else
   {
      var TminHR = getTfromLR(Lmin,thisStar.r);
      var TmaxHR = getTfromLR(Lmax,thisStar.r);
      var Tmin = Math.max(TminSld,TminHR);
      var Tmax = Math.min(TmaxSld,TmaxHR);
      if(arg < Tmin)
      {
         arg = Tmin;
      }
      else if(arg > Tmax)
      {
         arg = Tmax;
      }
      thisStar.t = arg;
      thisStar.l = getLFromRT(thisStar.r,arg);
      this["temp" + star + "Slider"].value = arg;
   }
   hrDiagramWindowMC.hrDiagramMC.setPointPosition(star,thisStar.t,thisStar.l);
   visualizationMC.passObjectToIcon(star,{temp:thisStar.t});
   drawLightCurve();
   if(systemsList.getValue() != " ")
   {
      setParametersToMatchButton.setEnabled(true);
   }
   var otherRestricted = this["restrict" + otherStarNumber + "Check"].getValue();
   var thisRestricted = this["restrict" + star + "Check"].getValue();
   if(thisRestricted)
   {
      setSeparationRange();
      setEccentricityRange();
      if(otherRestricted)
      {
         setRestrictedStarRanges(otherStarNumber);
      }
      else
      {
         setRadiusRange(otherStarNumber);
      }
   }
   else
   {
      setRadiusRange(star);
   }
}
function setMass(star, arg)
{
   if(star == 1)
   {
      var otherStarNumber = 2;
      thisStar = star1;
      otherStar = star2;
   }
   else
   {
      if(star != 2)
      {
         return undefined;
      }
      var otherStarNumber = 1;
      thisStar = star2;
      otherStar = star1;
   }
   if(this["restrict" + star + "Check"].getValue())
   {
      var RmaxVis = sysProps.a * (1 - sysProps.e) - otherStar.r;
      var TmaxVis = getTfromR(RmaxVis);
      var LmaxVis = getLfromRT(RmaxVis,TmaxVis);
      var MmaxVis = getMfromL(LmaxVis);
      var Mmin = MminMS;
      var Mmax = Math.min(MmaxMS,MmaxVis);
      if(arg < Mmin)
      {
         arg = Mmin;
      }
      else if(arg > Mmax)
      {
         arg = Mmax;
      }
      thisStar.m = arg;
      thisStar.l = getLfromM(arg);
      thisStar.t = getTfromL(thisStar.l);
      thisStar.r = getRfromTL(thisStar.t,thisStar.l);
      this["mass" + star + "Slider"].value = thisStar.m;
      this["radius" + star + "Slider"].value = thisStar.r;
      this["temp" + star + "Slider"].value = thisStar.t;
      var initObj = {};
      initObj["radius" + star] = thisStar.r;
      initObj["mass" + star] = thisStar.m;
      visualizationMC.initialize(initObj);
      visualizationMC.passObjectToIcon(star,{temp:thisStar.t});
      drawLightCurve();
      hrDiagramWindowMC.hrDiagramMC.setPointPosition(star,thisStar.t,thisStar.l);
   }
   else
   {
      var Mmin = MminSld;
      var Mmax = MmaxSld;
      if(arg < Mmin)
      {
         arg = Mmin;
      }
      else if(arg > Mmax)
      {
         arg = Mmax;
      }
      thisStar.m = arg;
      this["mass" + star + "Slider"].value = thisStar.m;
      visualizationMC["mass" + star] = thisStar.m;
   }
   if(systemsList.getValue() != " ")
   {
      setParametersToMatchButton.setEnabled(true);
   }
   var period = 0.115496 * Math.sqrt(Math.pow(sysProps.a,3) / (star1.m + star2.m));
   systemPeriodField.text = "system period: " + Math.toSigDigits(period,3) + " days";
   var otherRestricted = this["restrict" + otherStarNumber + "Check"].getValue();
   var thisRestricted = this["restrict" + star + "Check"].getValue();
   if(thisRestricted)
   {
      setSeparationRange();
      setEccentricityRange();
      if(otherRestricted)
      {
         setRestrictedStarRanges(otherStarNumber);
      }
      else
      {
         setRadiusRange(otherStarNumber);
      }
   }
}
getRfromTL = getRadiusFromTempAndLuminosity;
getLfromRT = getLuminosityFromRadiusAndTemp;
getTfromLR = getTempFromLuminosityAndRadius;
getTfromL = getTempFromLuminosity;
getTfromR = getTempFromRadius;
getLfromT = getLuminosityFromTempAndClass;
getLfromM = getLuminosityFromMass;
getMfromL = getMassFromLuminosity;
star1 = {};
star2 = {};
sysProps = {};
EminSld = eccentricitySlider.sliderMin;
EmaxSld = eccentricitySlider.sliderMax;
AminSld = separationSlider.sliderMin;
AmaxSld = separationSlider.sliderMax;
RminSld = radius1Slider.sliderMin;
RmaxSld = radius1Slider.sliderMax;
MminSld = mass1Slider.sliderMin;
MmaxSld = mass1Slider.sliderMax;
TminSld = temp1Slider.sliderMin;
TmaxSld = temp1Slider.sliderMax;
Lmin = 0.001;
Lmax = 1000000;
LminSqrt = Math.sqrt(Lmin);
LmaxSqrt = Math.sqrt(Lmax);
LminMS = getLFromT(TminSld);
LmaxMS = getLFromT(TmaxSld);
RminMS = getRFromTL(TminSld,LminMS);
RmaxMS = getRFromTL(TmaxSld,LmaxMS);
MminMS = getMFromL(LminMS);
MmaxMS = getMFromL(LmaxMS);
