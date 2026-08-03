function onReset()
{
   class5_radio.setValue(true);
   magSlider.value = 1;
   spectralClassUpdate();
   setCursorPosition(268);
}
function init()
{
   createLineArrays();
   x_start = 58;
   x_width = 350;
   x_inc = x_width / 70;
   cursorMC.onPress = onPressFunc;
   cursorMC.onReleaseOutside = cursorMC.onRelease = onReleaseFunc;
   cursorMC.useHandCursor = false;
   hrDiagramMC.addObject(null,"dot",null,null,{dotSize:6,dotColor:0});
   var _loc2_ = 0.3758787878787879 * (hrDiagramMC.plotWidth / (hrDiagramMC._xAxisMax - hrDiagramMC._xAxisMin));
   var _loc1_ = 2.7027027027027026 * (hrDiagramMC.plotHeight / (hrDiagramMC._yAxisMax - hrDiagramMC._yAxisMin));
   hrDiagramMC.addObject("Luminosity Classes Overlay","luminosityClasses",null,null,{logTemp:4.6021,logLum:6,_xscale:_loc2_,_yscale:_loc1_});
   setCursorPosition(268);
   classChange();
}
function formatNumber(num, digits)
{
   var _loc1_ = Math.floor(Math.log(num) / 2.302585092994046) - (digits - 1);
   var _loc2_;
   if(_loc1_ >= 0)
   {
      _loc2_ = Math.pow(10,_loc1_);
      return String(_loc2_ * Math.round(num / _loc2_));
   }
   return num.toFixed(- _loc1_);
}
function onPressFunc()
{
   this.xOffset = this._x - this._parent._xmouse;
   this.onMouseMove = this._parent.onMouseMoveFunc;
}
function onReleaseFunc()
{
   delete this.onMouseMove;
}
function onMouseMoveFunc()
{
   this._parent.setCursorPosition(this.xOffset + this._parent._xmouse);
   updateAfterEvent();
}
function setCursorPosition(newX)
{
   numST = Math.floor((newX - x_start + 0.5 * x_inc) / x_inc);
   if(numST < 0)
   {
      numST = 0;
   }
   if(numST > 69)
   {
      numST = 69;
   }
   newX = numST * x_inc + x_start;
   cursorMC._x = newX;
   spectralClassUpdate();
   makeSpectrum();
}
function spectralClassUpdate()
{
   var _loc2_ = ["very strong ionized helium, moderate helium lines","very strong ionized helium, moderate helium lines","very strong ionized helium, moderate helium lines","strong ionized helium, moderate helium lines","strong ionized helium, strong helium lines","strong ionized helium, strong helium lines","moderate ionized helium, very strong helium lines","moderate ionized helium, very strong helium lines","weak ionized helium, very strong helium lines","very weak ionized helium, very strong helium, very weak hydrogen lines","very strong helium, very weak hydrogen lines","very strong helium, weak hydrogen lines","very strong helium, weak hydrogen lines","very strong helium, moderate hydrogen lines","strong helium, moderate hydrogen lines","strong helium, moderate hydrogen lines","moderate helium, moderate hydrogen lines","moderate helium, moderate hydrogen lines","moderate helium, strong hydrogen, very weak ionized metal lines","weak helium, strong hydrogen, very weak ionized metal lines","very weak helium, very strong hydrogen, weak ionized metal lines","very weak helium, very strong hydrogen, weak ionized metal lines","very strong hydrogen, weak ionized metal lines","very strong hydrogen, weak ionized metal lines","strong hydrogen, moderate ionized metal lines","strong hydrogen, moderate ionized metal lines","strong hydrogen, moderate ionized metal lines","strong hydrogen, moderate ionized metal lines","moderate hydrogen, moderate ionized metal lines","moderate hydrogen, strong ionized metal lines","moderate hydrogen, strong ionized metal lines","moderate hydrogen, strong ionized metal lines","moderate hydrogen, strong ionized metal, very weak neutral metal lines","moderate hydrogen, strong ionized metal, very weak neutral metal lines","moderate hydrogen, strong ionized metal, weak neutral metal lines","moderate hydrogen, very strong ionized metal, weak neutral metal lines","moderate hydrogen, very strong ionized metal, weak neutral metal lines","moderate hydrogen, very strong ionized metal, weak neutral metal lines","weak hydrogen, very strong ionized metal, weak neutral metal lines","weak hydrogen, very strong ionized metal, weak neutral metal lines","weak hydrogen, very strong ionized metal, moderate neutral metal lines","weak hydrogen, very strong ionized metal, moderate neutral metal lines","weak hydrogen, strong ionized metal, moderate neutral metal lines","weak hydrogen, strong ionized metal, moderate neutral metal lines","weak hydrogen, strong ionized metal, strong neutral metal lines","weak hydrogen, strong ionized metal, strong neutral metal lines","weak hydrogen, strong ionized metal, strong neutral metal lines","weak hydrogen, moderate ionized metal, very strong neutral metal lines","weak hydrogen, moderate ionized metal, very strong neutral metal lines","very weak hydrogen, moderate ionized metal, very strong neutral metal lines","very weak hydrogen, weak ionized metal, very strong neutral metal lines","very weak hydrogen, weak ionized metal, very strong neutral metal lines","very weak ionized metal, very strong neutral metal lines","very weak ionized metal, very strong neutral metal lines","very weak ionized metal, strong neutral metal lines","strong neutral metal lines","strong neutral metal, very weak molecular lines","moderate neutral metal, weak molecular lines","moderate neutral metal, weak molecular lines","weak neutral metal, weak molecular lines","weak neutral metal, weak molecular lines","very weak neutral metal, moderate molecular lines","very weak neutral metal, moderate molecular lines","moderate molecular lines","moderate molecular lines","strong molecular lines","strong molecular lines","very strong molecular lines","very strong molecular lines","very strong molecular lines"];
   stDecade = Math.floor(numST / 10);
   stNumber = numST % 10;
   if(stDecade == 0)
   {
      stLetter = "O";
   }
   else if(stDecade == 1)
   {
      stLetter = "B";
   }
   else if(stDecade == 2)
   {
      stLetter = "A";
   }
   else if(stDecade == 3)
   {
      stLetter = "F";
   }
   else if(stDecade == 4)
   {
      stLetter = "G";
   }
   else if(stDecade == 5)
   {
      stLetter = "K";
   }
   else
   {
      stLetter = "M";
   }
   st = stLetter + stNumber;
   temp = Math.pow(10,hrDiagramMC.getLogTempFromType(hrDiagramMC.getSpectralTypeNumber(st)));
   var _loc1_ = formatNumber(temp,3);
   stOutput.text = "Spectral Type : " + st + "     Temperature : " + _loc1_ + " K";
   spectralTypeField.text = st;
   temperatureField.text = _loc1_ + " K";
   logTemp = Math.log(temp) / 2.302585092994046;
   logLum = hrDiagramMC.getLogLumFromLogTempAndClass(logTemp,classGroup.getValue());
   hrDiagramMC.dot.logTemp = logTemp;
   hrDiagramMC.dot.logLum = logLum;
   hrDiagramMC.updateObjects();
   app_mag_text.text = magSlider.valueString;
   absM = hrDiagramMC.getAbsVisMagFromLogLum(logLum,hrDiagramMC.getBCFromLogTemp(logTemp));
   abs_mag_text.text = absM.toFixed(1);
   dist_text.text = formatNumber(getDistanceFromAbsAndApp(absM,magSlider.value),3);
   lineDescription.text = "(" + _loc2_[numST] + ")";
}
function getDistanceFromAbsAndApp(absMag, appMag)
{
   var _loc2_ = appMag - absMag;
   var _loc3_ = (_loc2_ + 5) / 5;
   var _loc1_ = Math.pow(10,_loc3_);
   return _loc1_;
}
function classChange()
{
   spectralClassUpdate();
   numlumClass = classGroup.getValue();
   if(numlumClass == 1)
   {
      lineThickness = 1;
   }
   else if(numlumClass == 2)
   {
      lineThickness = 1.5;
   }
   else if(numlumClass == 3)
   {
      lineThickness = 2;
   }
   else if(numlumClass == 4)
   {
      lineThickness = 2.5;
   }
   else
   {
      lineThickness = 3;
   }
   makeSpectrum();
}
function makeSpectrum()
{
   mySpectra.deleteSpectra();
   mySpectra.createSpectra(0,0);
   createArrays();
   mySpectra.drawContinuous();
   mySpectra.drawColorSet(elementArray,alphaArray,colorArray);
}
function createArrays()
{
   elementArray = [];
   alphaArray = [];
   colorArray = [];
   numlumClass = classGroup.getValue();
   if(numlumClass == 1)
   {
      lumClass = "I";
   }
   else if(numlumClass == 2)
   {
      lumClass = "II";
   }
   else if(numlumClass == 3)
   {
      lumClass = "III";
   }
   else if(numlumClass == 4)
   {
      lumClass = "IV";
   }
   else
   {
      lumClass = "V";
   }
   spectralTypeNumber = numST;
   iheliumArray = new Array(433.9,454.2,468.6);
   i = 0;
   while(i < iheliumArray.length)
   {
      elementArray.push(iheliumArray[i]);
      if(emission_radio.getState())
      {
         colorArray.push(mySpectra.colorFromLength(iheliumArray[i]));
      }
      else
      {
         colorArray.push(0);
      }
      alphaArray.push(iHeLineArray[spectralTypeNumber]);
      i++;
   }
   heliumArray = new Array(402.6,438.8,447.1,706.5);
   i = 0;
   while(i < heliumArray.length)
   {
      elementArray.push(heliumArray[i]);
      if(emission_radio.getState())
      {
         colorArray.push(mySpectra.colorFromLength(heliumArray[i]));
      }
      else
      {
         colorArray.push(0);
      }
      alphaArray.push(HeLineArray[spectralTypeNumber]);
      i++;
   }
   hydrogenArray = new Array(397,410.1,434,486.1,656.3);
   i = 0;
   while(i < hydrogenArray.length)
   {
      elementArray.push(hydrogenArray[i]);
      if(emission_radio.getState())
      {
         colorArray.push(mySpectra.colorFromLength(hydrogenArray[i]));
      }
      else
      {
         colorArray.push(0);
      }
      alphaArray.push(HLineArray[spectralTypeNumber]);
      i++;
   }
   imetalsArray = new Array(393.3,396.8,407.7,417.5,421.5,423.3,424.6,426.7,430,444.4,448.1);
   i = 0;
   while(i < imetalsArray.length)
   {
      elementArray.push(imetalsArray[i]);
      if(emission_radio.getState())
      {
         colorArray.push(mySpectra.colorFromLength(imetalsArray[i]));
      }
      else
      {
         colorArray.push(0);
      }
      alphaArray.push(imetLineArray[spectralTypeNumber]);
      i++;
   }
   metalsArray = new Array(403.2,404.5,432.5,422.6,589);
   i = 0;
   while(i < metalsArray.length)
   {
      elementArray.push(metalsArray[i]);
      if(emission_radio.getState())
      {
         colorArray.push(mySpectra.colorFromLength(metalsArray[i]));
      }
      else
      {
         colorArray.push(0);
      }
      alphaArray.push(metLineArray[spectralTypeNumber]);
      i++;
   }
   moleculesArray = new Array(421.5,430,458.4,462.5,467,469.7,467,478);
   i = 0;
   while(i < moleculesArray.length)
   {
      elementArray.push(moleculesArray[i]);
      if(emission_radio.getState())
      {
         colorArray.push(mySpectra.colorFromLength(moleculesArray[i]));
      }
      else
      {
         colorArray.push(0);
      }
      alphaArray.push(molLineArray[spectralTypeNumber]);
      i++;
   }
}
function createLineArrays()
{
   iHeLineArray = [];
   HeLineArray = [];
   HLineArray = [];
   imetLineArray = [];
   metLineArray = [];
   molLineArray = [];
   i = 0;
   while(i < 70)
   {
      if(i < 8)
      {
         iHeLineArray[i] = Math.floor(-12.5 * i + 100);
      }
      else
      {
         iHeLineArray[i] = 0;
      }
      i++;
   }
   i = 0;
   while(i < 70)
   {
      if(i < 8)
      {
         HeLineArray[i] = Math.floor(3.75 * i + 70);
      }
      else if(i < 21)
      {
         HeLineArray[i] = Math.floor(-7.7 * i + 161.7);
      }
      else
      {
         HeLineArray[i] = 0;
      }
      i++;
   }
   i = 0;
   while(i < 70)
   {
      if(i < 7)
      {
         HLineArray[i] = 0;
      }
      else if(i < 20)
      {
         HLineArray[i] = Math.floor(7.7 * i - 53.9);
      }
      else if(i < 54)
      {
         HLineArray[i] = Math.floor(-2.94 * i + 158.7);
      }
      else
      {
         HLineArray[i] = 0;
      }
      i++;
   }
   i = 0;
   while(i < 70)
   {
      if(i < 11)
      {
         imetLineArray[i] = 0;
      }
      else if(i < 38)
      {
         imetLineArray[i] = Math.floor(3.7 * i - 40.7);
      }
      else if(i < 52)
      {
         imetLineArray[i] = Math.floor(-7.14 * i + 371.3);
      }
      else
      {
         imetLineArray[i] = 0;
      }
      i++;
   }
   i = 0;
   while(i < 70)
   {
      if(i < 30)
      {
         metLineArray[i] = 0;
      }
      else if(i < 49)
      {
         metLineArray[i] = Math.floor(5.26 * i - 157.8);
      }
      else if(i < 62)
      {
         metLineArray[i] = Math.floor(-7.7 * i + 477.4);
      }
      else
      {
         metLineArray[i] = 0;
      }
      i++;
   }
   i = 0;
   while(i < 70)
   {
      if(i < 50)
      {
         molLineArray[i] = 0;
      }
      else
      {
         molLineArray[i] = Math.floor(5.26 * i - 263.16);
      }
      i++;
   }
}
init();
