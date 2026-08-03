function drawLightCurve()
{
   var dataObj = {eccentricity:sysProps.e,separation:sysProps.a,theta:getSystemTheta(),phi:getSystemPhi(),radius1:star1.r,radius2:star2.r,temperature1:star1.t,temperature2:star2.t};
   curveMC.setParameters(dataObj);
}
function setViewThetaAndPhi(theta, phi)
{
   visualizationMC.setThetaAndPhi(theta,phi);
}
function getViewTheta()
{
   return visualizationMC.theta;
}
function getViewPhi()
{
   return visualizationMC.phi;
}
function getSystemTheta()
{
   return ((90 - longitudeSlider.value) % 360 + 360) % 360;
}
function getSystemPhi()
{
   return 90 - inclinationSlider.value;
}
function setLongitudeAndInclination(arg1, arg2)
{
   trace("is this function ever called?");
   var newTheta = 90 - arg1;
   var newPhi = 90 - arg2;
   visualizationMC._lineTheta = newTheta;
   visualizationMC._linePhi = newPhi;
   if(perspectiveLockCheck.getValue())
   {
      visualizationMC.setThetaAndPhi(newTheta,newPhi);
   }
   else
   {
      visualizationMC.updateLine();
   }
   longitudeSlider.value = arg1;
   inclinationSlider.value = arg2;
   drawLightCurve();
   visualizationMC.phase = curveMC._cursorPhase + curveMC._closestIndex / curveMC._numCurvePoints;
   if(systemsList.getValue() != " ")
   {
      setParametersToMatchButton.setEnabled(true);
   }
}
function changeLongitude(arg)
{
   var newTheta = 90 - arg;
   visualizationMC._lineTheta = newTheta;
   if(perspectiveLockCheck.getValue())
   {
      visualizationMC.setTheta(newTheta);
   }
   else
   {
      visualizationMC.updateLine();
   }
   drawLightCurve();
   visualizationMC.phase = curveMC._cursorPhase + curveMC._closestIndex / curveMC._numCurvePoints;
   if(systemsList.getValue() != " ")
   {
      setParametersToMatchButton.setEnabled(true);
   }
}
function changeInclination(arg)
{
   var newPhi = 90 - arg;
   visualizationMC._linePhi = newPhi;
   if(perspectiveLockCheck.getValue())
   {
      visualizationMC.setPhi(newPhi);
   }
   else
   {
      visualizationMC.updateLine();
   }
   drawLightCurve();
   visualizationMC.phase = curveMC._cursorPhase + curveMC._closestIndex / curveMC._numCurvePoints;
   if(systemsList.getValue() != " ")
   {
      setParametersToMatchButton.setEnabled(true);
   }
}
function changePerspectiveLock()
{
   if(perspectiveLockCheck.getValue())
   {
      delete visualizationBackgroundMC.onPress;
      setViewThetaAndPhi(getSystemTheta(),getSystemPhi());
      visualizationMC.showLine = false;
      windowTitleString = "perspective from earth";
   }
   else
   {
      visualizationBackgroundMC.onPress = visualizationBackgroundMC.onPressFunc;
      visualizationMC.showLine = true;
      windowTitleString = "click and drag to change perspective";
   }
}
function initialize()
{
   hrDiagramWindowMC._visible = false;
   sysProps.a = separationSlider.value;
   sysProps.e = eccentricitySlider.value;
   star1.r = radius1Slider.value;
   star1.m = mass1Slider.value;
   star1.t = temp1Slider.value;
   star1.l = getLfromRT(star1.r,star1.t);
   star2.r = radius2Slider.value;
   star2.m = mass2Slider.value;
   star2.t = temp2Slider.value;
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
   var period = 0.115496 * Math.sqrt(Math.pow(sysProps.a,3) / (star1.m + star2.m));
   systemPeriodField.text = "system period: " + Math.toSigDigits(period,3) + " days";
   var initObject = {phase:0,separation:separationSlider.value,eccentricity:eccentricitySlider.value,mass1:mass1Slider.value,mass2:mass2Slider.value,radius1:radius1Slider.value,radius2:radius2Slider.value,phi:getSystemPhi(),theta:getSystemTheta(),showOrbitalPlane:true,showOrbitalPaths:true,autoScale:true,targetSize:360,lineTheta:getSystemTheta(),linePhi:getSystemPhi(),showLine:false,lineExtra:20};
   this.initParamsObj = initObject;
   this.initParamsObj.temperature1 = temp1Slider.value;
   this.initParamsObj.temperature2 = temp2Slider.value;
   this.initParamsObj.inclination = inclinationSlider.value;
   this.initParamsObj.longitude = longitudeSlider.value;
   visualizationMC.initialize(initObject);
   visualizationMC.passObjectToIcon(1,{temp:temp1Slider.value});
   visualizationMC.passObjectToIcon(2,{temp:temp2Slider.value});
   hrDiagramWindowMC.hrDiagramMC.setPointPosition(1,star1.t,star1.l);
   hrDiagramWindowMC.hrDiagramMC.setPointPosition(2,star2.t,star2.l);
   curveMC.phaseOffset = 1.5;
   curveMC.dataType = "visual flux";
   drawLightCurve();
   setPhase(0.7);
   windowTitleString = "perspective from earth";
   systemsList.addItem("- select a preset -"," ");
   systemsList.addItem(" "," ");
   systemsList.addItem("Student Guide Examples"," ");
   var i = 0;
   while(i < completeSystemsStart)
   {
      systemsList.addItem("  " + (i + 1) + ". " + systemsArray[i].name,i);
      i++;
   }
   systemsList.addItem(" "," ");
   systemsList.addItem("Datasets with Complete Parameters"," ");
   var i = completeSystemsStart;
   while(i < incompleteSystemsStart)
   {
      systemsList.addItem("  " + (i + 1) + ". " + systemsArray[i].name,i);
      i++;
   }
   systemsList.addItem(" "," ");
   systemsList.addItem("Datasets with Incomplete Parameters"," ");
   var i = incompleteSystemsStart;
   while(i < extraSystemsStart)
   {
      systemsList.addItem("  " + (i + 1) + ". " + systemsArray[i].name,i);
      i++;
   }
   systemsList.addItem(" "," ");
   systemsList.addItem("More Datasets"," ");
   var i = extraSystemsStart;
   while(i < systemsArray.length)
   {
      systemsList.addItem("  " + (i + 1) + ". " + systemsArray[i].name,i);
      i++;
   }
   changeSelectedSystem();
}
visualizationBackgroundMC.useHandCursor = false;
visualizationBackgroundMC.onPressFunc = function()
{
   this.initX = this._xmouse;
   this.initY = this._ymouse;
   this.dragPhi = this._parent.getViewPhi();
   this.dragTheta = this._parent.getViewTheta();
   this.onMouseMove = this.onMouseMoveFunc;
};
visualizationBackgroundMC.onMouseMoveFunc = function()
{
   var newPhi = this.dragPhi - 57.29577951308232 * (this.initY - this._ymouse) / 400;
   var newTheta = this.dragTheta - 57.29577951308232 * (this._xmouse - this.initX) / 400;
   if(newPhi > 90)
   {
      newPhi = 90;
   }
   else if(newPhi < -90)
   {
      newPhi = -90;
   }
   this._parent.setViewThetaAndPhi(newTheta,newPhi);
   updateAfterEvent();
};
visualizationBackgroundMC.onRelease = visualizationBackgroundMC.onReleaseOutside = function()
{
   delete this.onMouseMove;
};
Math.toSigDigits = function()
{
   var num = parseFloat(arguments[0]);
   var digs = Math.abs(parseInt(arguments[1]));
   if(!isFinite(digs) || !isFinite(num))
   {
      return NaN;
   }
   if(num == 0 || digs == 0)
   {
      return 0;
   }
   if(digs > 15)
   {
      digs = 15;
   }
   var sign = 1;
   if(num < 0)
   {
      sign = -1;
      num = Math.abs(num);
   }
   var tmp = Math.floor(Math.log(num) / 2.302585092994046);
   var fact = Math.pow(10,digs - (1 + tmp));
   var num2 = Math.round(fact * num) / fact;
   return sign * num2;
};
initialize();
