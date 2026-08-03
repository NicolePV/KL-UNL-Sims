function changeShowLightcurve()
{
   curveMC.curveMC._visible = showLightcurveCheck.getValue();
}
function changeRestrict1()
{
   if(restrict1Check.getValue())
   {
      setRestrictToMainSequence(1);
   }
   else
   {
      setUnrestrictStar(1);
   }
}
function changeRestrict2()
{
   if(restrict2Check.getValue())
   {
      setRestrictToMainSequence(2);
   }
   else
   {
      setUnrestrictStar(2);
   }
}
function changeEccentricity(arg)
{
   setEccentricity(arg);
}
function changeSeparation(arg)
{
   setSeparation(arg);
}
function changeShowOrbitalPaths()
{
   visualizationMC.showOrbitalPaths = showOrbitalPathsCheck.getValue();
}
function changeShowOrbitalPlane()
{
   visualizationMC.showOrbitalPlane = showOrbitalPlaneCheck.getValue();
}
function changeSelectedSystem()
{
   if(systemsList.getValue() == " ")
   {
      commentField.text = "\n\n                                - select a preset -";
      openInfoPageButton.setEnabled(false);
      setParametersToMatchButton.setEnabled(false);
      curveMC.displayDataset(null);
   }
   else
   {
      var sys = systemsArray[systemsList.getValue()];
      if(typeof sys.comment == "string")
      {
         commentField.text = sys.comment;
      }
      else
      {
         commentField.text = "comments for this preset go here";
      }
      if(sys.id == null)
      {
         openInfoPageButton.setEnabled(false);
      }
      else
      {
         openInfoPageButton.setEnabled(true);
      }
      curveMC.displayDataset(sys.name);
      setParametersToMatch();
   }
}
function openInfoPage()
{
   var i = systemsList.getValue();
   if(i == " ")
   {
      return undefined;
   }
   var url = "http://ebola.eastern.edu/star_summary.php?star_id=" + systemsArray[i].id;
   getURL(url,"_blank");
}
function setParametersToMatch()
{
   var i = systemsList.getValue();
   if(i == " ")
   {
      return undefined;
   }
   var dataObject = systemsArray[i];
   sysProps.a = dataObject.a;
   sysProps.e = dataObject.e;
   star1.m = dataObject.m1;
   star2.m = dataObject.m2;
   var period = 0.115496 * Math.sqrt(Math.pow(sysProps.a,3) / (star1.m + star2.m));
   systemPeriodField.text = "system period: " + Math.toSigDigits(period,3) + " days";
   infoString = "";
   if(dataObject.r1 == -1)
   {
      star1.r = 0.1;
      infoString = "r1 = -1, ";
   }
   else
   {
      star1.r = dataObject.a * dataObject.r1;
   }
   if(dataObject.r2 == -1)
   {
      star2.r = 0.1;
      infoString += "r2 = -1";
   }
   else
   {
      star2.r = dataObject.a * dataObject.r2;
   }
   star1.t = dataObject.t1;
   star2.t = dataObject.t2;
   star1.l = getLfromRT(star1.r,star1.t);
   star2.l = getLfromRT(star2.r,star2.t);
   var startTimer = getTimer();
   setMassRange(1);
   setRadiusRange(1);
   setTempRange(1);
   setMassRange(2);
   setRadiusRange(2);
   setTempRange(2);
   setSeparationRange();
   setEccentricityRange();
   trace("range setting: " + (getTimer() - startTimer));
   if(restrict1Check.getValue())
   {
      restrict1Check.setValue(false);
   }
   if(restrict2Check.getValue())
   {
      restrict2Check.setValue(false);
   }
   longitudeSlider.value = dataObject.w;
   inclinationSlider.value = dataObject.i;
   separationSlider.value = sysProps.a;
   eccentricitySlider.value = sysProps.e;
   mass1Slider.value = star1.m;
   radius1Slider.value = star1.r;
   temp1Slider.value = star1.t;
   mass2Slider.value = star2.m;
   radius2Slider.value = star2.r;
   temp2Slider.value = star2.t;
   hrDiagramWindowMC.hrDiagramMC.setPointPosition(1,star1.t,star1.l);
   hrDiagramWindowMC.hrDiagramMC.setPointPosition(2,star2.t,star2.l);
   var initObject = {separation:sysProps.a,eccentricity:sysProps.e,linePhi:getSystemPhi(),lineTheta:getSystemTheta(),mass1:star1.m,mass2:star2.m,radius1:star1.r,radius2:star2.r};
   if(perspectiveLockCheck.getValue())
   {
      initObject.phi = initObject.linePhi;
      initObject.theta = initObject.lineTheta;
   }
   visualizationMC.initialize(initObject);
   visualizationMC.passObjectToIcon(1,{temp:star1.t});
   visualizationMC.passObjectToIcon(2,{temp:star2.t});
   drawLightCurve();
   setPhase(curveMC.cursorPhase);
   setParametersToMatchButton.setEnabled(false);
}
function changeMass1(arg)
{
   setMass(1,arg);
}
function changeMass2(arg)
{
   setMass(2,arg);
}
function changeRadius1(arg)
{
   setRadius(1,arg);
}
function changeRadius2(arg)
{
   setRadius(2,arg);
}
function changeTemp1(arg)
{
   setTemp(1,arg);
}
function changeTemp2(arg)
{
   setTemp(2,arg);
}
showLightcurveCheck.setStyleProperty("textSize",10);
