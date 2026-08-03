function LightcurveClass()
{
   this.plotWidth = 320;
   this.plotHeight = 200;
   this.minMagDiff = 0.01;
   this.yTopMargin = 17;
   this.yBottomMargin = 5;
   this.xMargin = 1;
   this.totalHeight = this.plotHeight + this.yTopMargin + this.yBottomMargin;
   this.minMagTickSpacing = 20;
   this.minMagMinorTickSpacing = 7;
   this.createEmptyMovieClip("backgroundMC",0);
   this.createEmptyMovieClip("dataMC",5);
   this.createEmptyMovieClip("curveMC",10);
   this.attachMovie("Lightcurve Cursor","cursorMC",15);
   this.attachMovie("Time Ticks","timeTicksMC",20,{_y:5});
   this.createEmptyMovieClip("magTicksMC",25);
   this.attachMovie("Flux Ticks and Labels","fluxTicksMC",30,{_x:-51.5,_y:-208.3});
   this.createEmptyMovieClip("boxMC",50);
   this.magTicksMC.createEmptyMovieClip("minorTicksMC",1000);
   this.magTicksMC.attachMovie("Mag Axis Label","axisLabel",2000,{_x:-51.5,_y:-150.4});
   this.maxNumberOfMagTicks = Math.ceil(this.totalHeight / this.minMagTickSpacing);
   var i = 0;
   while(i < this.maxNumberOfMagTicks)
   {
      this.magTicksMC.attachMovie("Mag Tick And Label","tick" + i,i,{_visible:false});
      i++;
   }
   this.maxNumberOfMagMinorTicks = this.maxNumberOfMagTicks * 11;
   var i = 0;
   while(i < this.maxNumberOfMagMinorTicks)
   {
      this.magTicksMC.minorTicksMC.attachMovie("Mag Minor Tick","minorTick" + i,i,{_visible:false});
      i++;
   }
   var mc = this.backgroundMC;
   mc.clear();
   mc.lineStyle(1,16711680,0);
   mc.beginFill(16777215,100);
   mc.moveTo(- this.xMargin,this.yBottomMargin);
   mc.lineTo(this.plotWidth + this.xMargin,this.yBottomMargin);
   mc.lineTo(this.plotWidth + this.xMargin,- this.plotHeight - this.yTopMargin);
   mc.lineTo(- this.xMargin,- this.plotHeight - this.yTopMargin);
   mc.lineTo(- this.xMargin,this.yBottomMargin);
   mc.endFill();
   mc.useHandCursor = false;
   mc.onPress = function()
   {
      this.initX = this._xmouse;
      this.initPhaseOffset = this._parent._phaseOffset;
      this.onMouseMove = this.onMouseMoveFunc;
   };
   mc.onMouseMoveFunc = function()
   {
      var newPhaseOffset = ((this.initPhaseOffset + (this._xmouse - this.initX) / this._parent.plotWidth) % 1 + 1) % 1;
      this._parent.setPhaseOffset(newPhaseOffset);
      updateAfterEvent();
   };
   mc.onRelease = mc.onReleaseOutside = function()
   {
      delete this.onMouseMove;
   };
   var mc = this.boxMC;
   mc.clear();
   mc.lineStyle(1,0,100);
   mc.moveTo(- this.xMargin,this.yBottomMargin);
   mc.lineTo(this.plotWidth + this.xMargin,this.yBottomMargin);
   mc.lineTo(this.plotWidth + this.xMargin,- this.plotHeight - this.yTopMargin);
   mc.lineTo(- this.xMargin,- this.plotHeight - this.yTopMargin);
   mc.lineTo(- this.xMargin,this.yBottomMargin);
   var mc = this.cursorMC;
   mc.useHandCursor = false;
   mc.onRollOver = function()
   {
      this.gotoAndStop(2);
   };
   mc.onRollOut = function()
   {
      this.gotoAndStop(1);
   };
   mc.onPress = function()
   {
      this.initCursorPhase = this._parent._cursorPhase;
      this.initX = this._parent._xmouse;
      this.onMouseMove = this.onMouseMoveFunc;
   };
   mc.onMouseMoveFunc = function()
   {
      var newPhase = this.initCursorPhase + (this._parent._xmouse - this.initX) / this._parent.plotWidth;
      this._parent._parent.setPhase(newPhase);
      updateAfterEvent();
   };
   mc.onRelease = function()
   {
      delete this.onMouseMove;
   };
   mc.onReleaseOutside = function()
   {
      this.gotoAndStop(1);
      delete this.onMouseMove;
   };
   var mc = this.createEmptyMovieClip("mask1MC",100);
   mc.clear();
   mc.lineStyle(1,16711680,100);
   mc.beginFill(16711680,10);
   mc.moveTo(- this.xMargin,this.yBottomMargin);
   mc.lineTo(this.plotWidth + this.xMargin,this.yBottomMargin);
   mc.lineTo(this.plotWidth + this.xMargin,- this.plotHeight - this.yTopMargin);
   mc.lineTo(- this.xMargin,- this.plotHeight - this.yTopMargin);
   mc.lineTo(- this.xMargin,this.yBottomMargin);
   mc.endFill();
   duplicateMovieClip(this.mask1MC,"mask2MC",16485);
   duplicateMovieClip(this.mask1MC,"mask3MC",16486);
   this.dataMC.setMask(this.mask1MC);
   this.curveMC.setMask(this.mask2MC);
   this.cursorMC.setMask(this.mask3MC);
   this.curveMC.createEmptyMovieClip("mc1",1);
   this._numCurvePoints = 300;
   this._positionTable = [];
   i = 0;
   while(i < this._numCurvePoints)
   {
      this._positionTable[i] = {};
      i++;
   }
   this._dataType = "visual flux";
   this._c = {};
}
var p = LightcurveClass.prototype = new MovieClip();
Object.registerClass("Lightcurve",LightcurveClass);
p.solarRadius = 696000000;
p.positionMagTicks = function()
{
   var start = getTimer();
   var s = (this._maxVisMag - this._minVisMag) / this.plotHeight;
   var l = Math.log(s * this.minMagTickSpacing) / 2.302585092994046;
   var f = Math.floor(l);
   var h = - (this.yTopMargin + this.plotHeight);
   var min = this._minVisMag - s * this.yTopMargin;
   var max = this._maxVisMag + s * this.yBottomMargin;
   if(f == l)
   {
      var majorTickSpacing = Math.pow(10,f);
      var minorTickSpacing = 5 * Math.pow(10,f - 1);
      var p = f;
   }
   else if(l <= f + 0.698970004336019)
   {
      var majorTickSpacing = 5 * Math.pow(10,f);
      var minorTickSpacing = Math.pow(10,f);
      var p = f;
   }
   else
   {
      var majorTickSpacing = Math.pow(10,f + 1);
      var minorTickSpacing = 5 * Math.pow(10,f);
      var p = f + 1;
   }
   if(minorTickSpacing > s * this.minMagMinorTickSpacing)
   {
      var majorMC = this.magTicksMC;
      var minorMC = majorMC.minorTicksMC;
      minorMC._visible = true;
      var startTick = minorTickSpacing * Math.ceil(min / minorTickSpacing);
      var numTicks = 1 + Math.floor((max - startTick) / minorTickSpacing);
      var majorCounter = 0;
      var minorCounter = 0;
      var round = Math.round;
      var abs = Math.abs;
      var format = this.formatNumber;
      var i = 0;
      while(i < numTicks)
      {
         var tickValue = startTick + minorTickSpacing * i;
         var k = tickValue / majorTickSpacing;
         if(abs(k - round(k)) < 1e-9)
         {
            var mc = majorMC["tick" + majorCounter];
            mc.labelField.text = format(tickValue,p);
            majorCounter++;
         }
         else
         {
            var mc = minorMC["minorTick" + minorCounter];
            minorCounter++;
         }
         mc._visible = true;
         mc._y = h + (tickValue - min) / s;
         i++;
      }
      var i = majorCounter;
      while(i < this.maxNumberOfMagTicks)
      {
         majorMC["tick" + i]._visible = false;
         i++;
      }
      var i = minorCounter;
      while(i < this.maxNumberOfMagMinorTicks)
      {
         minorMC["minorTick" + i]._visible = false;
         i++;
      }
   }
   else
   {
      this.magTicksMC.minorTicksMC._visible = false;
      var startTick = majorTickSpacing * Math.ceil(min / majorTickSpacing);
      var numTicks = 1 + Math.floor((max - startTick) / majorTickSpacing);
      var i = 0;
      while(i < numTicks)
      {
         var mc = this.magTicksMC["tick" + i];
         mc._visible = true;
         var tickValue = startTick + majorTickSpacing * i;
         mc.labelField.text = this.formatNumber(tickValue,p);
         mc._y = h + (tickValue - min) / s;
         i++;
      }
      i = numTicks;
      while(i < this.maxNumberOfMagTicks)
      {
         this.magTicksMC["tick" + i]._visible = false;
         i++;
      }
   }
};
p.positionTimeTicks = function()
{
   var k = 10 * this._phaseOffset;
   var fk = Math.floor(k);
   var startX = this.plotWidth * (k - fk) / 10;
   var startTick = (20 - fk) % 10;
   this.timeTicksMC._x = startX;
   var spacing = this.plotWidth / 10;
   var i = 0;
   while(i < 10)
   {
      this["timeTickLabel" + (i + startTick) % 10]._x = startX + i * spacing;
      i++;
   }
};
p.setParameters = function(dataObj)
{
   var currObj = this._c;
   if(dataObj.eccentricity != currObj.eccentricity)
   {
      this._c = dataObj;
      this.generatePositionTable();
      this.generateOverlapTable();
      this.generateMagnitudeTable();
      this.plotCurve();
   }
   else if(dataObj.separation != currObj.separation || dataObj.theta != currObj.theta || dataObj.phi != currObj.phi || dataObj.radius1 != currObj.radius1 || dataObj.radius2 != currObj.radius2)
   {
      this._c = dataObj;
      this.generateOverlapTable();
      this.generateMagnitudeTable();
      this.plotCurve();
   }
   else if(dataObj.temperature1 != currObj.temperature1 || dataObj.temperature2 != currObj.temperature2)
   {
      this._c = dataObj;
      this.generateMagnitudeTable();
      this.plotCurve();
   }
};
p.getDataType = function()
{
   return this._dataType;
};
p.setDataType = function(arg)
{
   this._dataType = arg;
   if(this._dataType == "visual flux")
   {
      this.fluxTicksMC._visible = true;
      this.magTicksMC._visible = false;
   }
   else
   {
      this.fluxTicksMC._visible = false;
      this.magTicksMC._visible = true;
   }
   this.plotCurve();
};
p.addProperty("dataType",p.getDataType,p.setDataType);
p.displayDataset = function(arg)
{
   var mc = this.dataMC.createEmptyMovieClip("fluxMC",1);
   mc.attachMovie(arg + " - flux","_1",1,{_x:- this.plotWidth});
   mc.attachMovie(arg + " - flux","_2",2);
   mc.attachMovie(arg + " - flux","_3",3,{_x:this.plotWidth});
   var mc = this.dataMC.createEmptyMovieClip("magMC",2);
   mc.attachMovie(arg + " - mag","_1",1,{_x:- this.plotWidth});
   mc.attachMovie(arg + " - mag","_2",2);
   mc.attachMovie(arg + " - mag","_3",3,{_x:this.plotWidth});
   if(mc == undefined)
   {
      this.dataMC.fluxMC._visible = false;
      this.dataMC.magMC._visible = false;
   }
   else
   {
      this.dataMC.fluxMC._visible = true;
      this.dataMC.magMC._visible = true;
   }
   switch(this._dataType)
   {
      case "visual flux":
         this.dataMC.fluxMC._visible = true;
         this.dataMC.magMC._visible = false;
         return;
      case "visual magnitude":
         this.dataMC.fluxMC._visible = false;
         this.dataMC.magMC._visible = true;
         return;
      default:
         this.dataMC.fluxMC._visible = false;
         this.dataMC.magMC._visible = false;
         return;
   }
};
p.plotCurve = function()
{
   var noEclipse = this._noEclipse;
   switch(this._dataType)
   {
      case "visual flux":
         this.dataMC.fluxMC._visible = true;
         this.dataMC.magMC._visible = false;
         if(!noEclipse)
         {
            var dT = this._visualFluxTable;
            var yScale = (- this.plotHeight) / this._maxVisFlux;
            var yOffset = 0;
         }
         break;
      case "visual magnitude":
         this.dataMC.fluxMC._visible = false;
         this.dataMC.magMC._visible = true;
         if(!noEclipse)
         {
            var dT = this._visualMagnitudeTable;
            var yScale = this.plotHeight / (this._maxVisMag - this._minVisMag);
            var yOffset = - this.plotHeight - yScale * this._minVisMag;
         }
         this.positionMagTicks();
         break;
      default:
         this.dataMC.fluxMC._visible = false;
         this.dataMC.magMC._visible = false;
         this.curveMC.mc1.clear();
         this.positionClips();
         return undefined;
   }
   var mc = this.curveMC.mc1;
   mc.clear();
   mc.lineStyle(2,0,100);
   if(noEclipse)
   {
      mc.moveTo(0,- this.plotHeight);
      mc.lineTo(this.plotWidth,- this.plotHeight);
   }
   else
   {
      var w = this.plotWidth;
      var si = Math.floor(this._closestIndex);
      var xOffset = (- w / this._numCurvePoints) * (this._closestIndex - si);
      var y0 = yOffset + yScale * dT[si];
      mc.moveTo(0,y0);
      var len = dT.length;
      var xScale = w / len;
      var i = 0;
      while(i < len)
      {
         mc.lineTo(xOffset + i * xScale,yOffset + yScale * dT[(i + si) % len]);
         i++;
      }
      mc.lineTo(w,y0);
   }
   this.positionClips();
};
p.getShowCursor = function()
{
   return this.cursorMC._visible;
};
p.setShowCursor = function(arg)
{
   this.cursorMC._visible = Boolean(arg);
};
p.addProperty("showCursor",p.getShowCursor,p.setShowCursor);
p.getCursorPhase = function()
{
   return this._cursorPhase;
};
p.setCursorPhase = function(arg)
{
   this._cursorPhase = (arg % 1 + 1) % 1;
   this.cursorMC._x = this.plotWidth * ((this._phaseOffset + this._cursorPhase) % 1);
};
p.addProperty("cursorPhase",p.getCursorPhase,p.setCursorPhase);
p.getPhaseOffset = function()
{
   return this._phaseOffset;
};
p.setPhaseOffset = function(arg)
{
   this._phaseOffset = (arg % 1 + 1) % 1;
   this.positionTimeTicks();
   this.positionClips();
};
p.addProperty("phaseOffset",p.getPhaseOffset,p.setPhaseOffset);
p.positionClips = function()
{
   duplicateMovieClip(this.curveMC.mc1,"mc2",16386);
   duplicateMovieClip(this.curveMC.mc1,"mc3",16387);
   var x = this._phaseOffset * this.plotWidth;
   if(this._phaseOffset < 0.5)
   {
      this.curveMC.mc1._x = x - this.plotWidth;
      this.curveMC.mc2._x = x;
      this.curveMC.mc3._x = x + this.plotWidth;
   }
   else
   {
      this.curveMC.mc1._x = x - 2 * this.plotWidth;
      this.curveMC.mc2._x = x - this.plotWidth;
      this.curveMC.mc3._x = x;
   }
   if(this._phaseOffset < 0.5)
   {
      this.dataMC._x = x;
   }
   else
   {
      this.dataMC._x = x - this.plotWidth;
   }
   this.cursorMC._x = this.plotWidth * ((this._phaseOffset + this._cursorPhase) % 1);
};
p.generatePositionTable = function()
{
   var cos = Math.cos;
   var sin = Math.sin;
   var tan = Math.tan;
   var atan = Math.atan;
   var abs = Math.abs;
   var pT = this._positionTable;
   var np = this._numCurvePoints;
   var n = np / 2;
   var step = 6.283185307179586 / np;
   var e = this._c.eccentricity;
   if(isNaN(e) || !isFinite(e) || e >= 1 || e < 0)
   {
      e = 0;
      this._c.eccentricity = e;
   }
   var k1 = Math.sqrt((1 + e) / (1 - e));
   var k2 = this.solarRadius * (1 - e * e);
   pT[0] = {x:k2 / (1 + e),y:0};
   pT[n] = {x:(- k2) / (1 - e),y:0};
   var i = 1;
   while(i < n)
   {
      var ma = i * step;
      var ea0 = 0;
      var ea1 = ma + e * sin(ma);
      do
      {
         ea0 = ea1;
         ea1 = ma + e * sin(ea0);
      }
      while(abs(ea1 - ea0) > 0.001);
      var ta = 2 * atan(k1 * tan(ea1 / 2));
      var k3 = k2 / (1 + e * cos(ta));
      var fpT = pT[i];
      var spT = pT[np - i];
      spT.x = fpT.x = k3 * cos(ta);
      fpT.y = k3 * sin(ta);
      spT.y = - fpT.y;
      i++;
   }
};
p.generateOverlapTable = function()
{
   var acos = Math.acos;
   var sin = Math.sin;
   var sqrt = Math.sqrt;
   this._overlapTable = [];
   var oT = this._overlapTable;
   var pT = this._positionTable;
   var c = this._c;
   var a = c.separation;
   var _ct = a * Math.cos(0.017453292519943295 * c.theta);
   var _st = a * sin(0.017453292519943295 * c.theta);
   var cp = Math.cos(0.017453292519943295 * c.phi);
   var sp = sin(0.017453292519943295 * c.phi);
   var k0 = - _st;
   var k1 = _ct;
   var k3 = _ct * sp;
   var k4 = _st * sp;
   var k6 = _ct * cp;
   var k7 = _st * cp;
   var r1 = this.solarRadius * c.radius1;
   var r2 = this.solarRadius * c.radius2;
   var r12 = r1 * r1;
   var r22 = r2 * r2;
   var R = r1 + r2;
   var RSQRD = R * R;
   var j0 = 1 / (2 * r2);
   var j1 = (r22 - r12) * j0;
   var j2 = 1 / (2 * r1);
   var j3 = (r12 - r22) * j2;
   var np = this._numCurvePoints;
   var closestIndex = 0;
   var minD2 = Infinity;
   var i = 0;
   while(i < np)
   {
      var p = pT[i];
      var dx = k0 * p.x + k1 * p.y;
      var dy = k3 * p.x + k4 * p.y;
      var dz = k6 * p.x + k7 * p.y;
      var d2 = dx * dx + dy * dy;
      if(dz > 0 && d2 < minD2)
      {
         minD2 = d2;
         closestIndex = i;
      }
      if(d2 >= RSQRD)
      {
         oT.push(0);
      }
      else
      {
         var d = sqrt(d2);
         if(d == 0)
         {
            d = 1e-8;
         }
         var ca = j0 * d + j1 / d;
         var cb = j2 * d + j3 / d;
         if(ca < -1)
         {
            ca = -1;
         }
         else if(ca > 1)
         {
            ca = 1;
         }
         if(cb < -1)
         {
            cb = -1;
         }
         else if(cb > 1)
         {
            cb = 1;
         }
         var alpha = acos(ca);
         var beta = acos(cb);
         var o = r22 * (alpha - ca * sin(alpha)) + r12 * (beta - cb * sin(beta));
         if(dz < 0)
         {
            oT.push(o);
         }
         else
         {
            oT.push(- o);
         }
      }
      i++;
   }
   var refinement = 15;
   var cos = Math.cos;
   var tan = Math.tan;
   var atan = Math.atan;
   var abs = Math.abs;
   var e = c.eccentricity;
   var q1 = sqrt((1 + e) / (1 - e));
   var q2 = this.solarRadius * (1 - e * e);
   var q4 = np / 6.283185307179586;
   var step = 2 / (q4 * refinement);
   var start = (closestIndex - 1) / q4;
   var refinedIndex = closestIndex;
   var i = 1;
   while(i < refinement)
   {
      var ma = start + i * step;
      var ea0 = 0;
      var ea1 = ma + e * sin(ma);
      do
      {
         ea0 = ea1;
         ea1 = ma + e * sin(ea0);
      }
      while(abs(ea1 - ea0) > 0.001);
      var ta = 2 * atan(q1 * tan(ea1 / 2));
      var q3 = q2 / (1 + e * cos(ta));
      var px = q3 * cos(ta);
      var py = q3 * sin(ta);
      var dx = k0 * px + k1 * py;
      var dy = k3 * px + k4 * py;
      var d2 = dx * dx + dy * dy;
      if(d2 < minD2)
      {
         minD2 = d2;
         refinedIndex = ma * q4;
      }
      i++;
   }
   this._closestIndex = (refinedIndex % np + np) % np;
};
p.generateMagnitudeTable = function()
{
   var log = Math.log;
   this._visualMagnitudeTable = [];
   this._visualFluxTable = [];
   var vMT = this._visualMagnitudeTable;
   var vFT = this._visualFluxTable;
   var oT = this._overlapTable;
   var c = this._c;
   var np = this._numCurvePoints;
   var logTeff = log(c.temperature1) / 2.302585092994046;
   if(logTeff > 3.9)
   {
      var k = {a:-100139.4991,b:116264.1842,c:-53931.97541,d:12495.04227,e:-1445.868048,f:66.84924471};
   }
   else if(logTeff < 3.7)
   {
      var k = {a:-13884.14899,b:8595.127427,c:-488.3425525,d:-627.0092238,e:137.4608131,f:-7.549572042};
   }
   else
   {
      var k = {a:1439.981506,b:-151.9002581,c:-995.1089203,d:582.5176671,e:-123.3293641,f:9.160761128};
   }
   var BC1 = k.a + logTeff * (k.b + logTeff * (k.c + logTeff * (k.d + logTeff * (k.e + k.f * logTeff))));
   var logTeff = log(c.temperature2) / 2.302585092994046;
   if(logTeff > 3.9)
   {
      var k = {a:-100139.4991,b:116264.1842,c:-53931.97541,d:12495.04227,e:-1445.868048,f:66.84924471};
   }
   else if(logTeff < 3.7)
   {
      var k = {a:-13884.14899,b:8595.127427,c:-488.3425525,d:-627.0092238,e:137.4608131,f:-7.549572042};
   }
   else
   {
      var k = {a:1439.981506,b:-151.9002581,c:-995.1089203,d:582.5176671,e:-123.3293641,f:9.160761128};
   }
   var BC2 = k.a + logTeff * (k.b + logTeff * (k.c + logTeff * (k.d + logTeff * (k.e + k.f * logTeff))));
   var j1 = 1.89553328524593e-43 * Math.pow(c.temperature1,4) * Math.pow(10,BC1 / 2.5);
   var j2 = -1.89553328524593e-43 * Math.pow(c.temperature2,4) * Math.pow(10,BC2 / 2.5);
   var fullVisFlux = (c.radius1 * c.radius1 * j1 - c.radius2 * c.radius2 * j2) * 1521837746881349890;
   var minVisFlux = Infinity;
   var i = 0;
   while(i < np)
   {
      var o = oT[i];
      if(o < 0)
      {
         var visFlux = fullVisFlux + j1 * o;
      }
      else
      {
         var visFlux = fullVisFlux + j2 * o;
      }
      if(visFlux < minVisFlux)
      {
         minVisFlux = visFlux;
      }
      var visMag = -18.9669559998301 - 1.0857362047581294 * log(visFlux);
      vFT.push(visFlux);
      vMT.push(visMag);
      i++;
   }
   this._noEclipse = fullVisFlux == minVisFlux;
   this._maxVisFlux = fullVisFlux;
   this._minVisFlux = minVisFlux;
   if(this._noEclipse)
   {
      this._minVisMag = -18.9669559998301 - 1.0857362047581294 * log(this._maxVisFlux);
      this._maxVisMag = this._minVisMag + 3;
   }
   else
   {
      this._minVisMag = -18.9669559998301 - 1.0857362047581294 * log(this._maxVisFlux);
      this._maxVisMag = -18.9669559998301 - 1.0857362047581294 * log(this._minVisFlux);
      if(this._maxVisMag - this._minVisMag < this.minMagDiff)
      {
         this._maxVisMag = this._minVisMag + this.minMagDiff;
      }
   }
};
p.formatNumber = function(x, place)
{
   var f = - place;
   if(f <= 0)
   {
      var p = Math.pow(10,place);
      return String(Math.round(p * x) / p);
   }
   if(f > 14)
   {
      f = 14;
   }
   var s = "";
   if(x < 0)
   {
      s = "-";
      x = - x;
   }
   var m = "";
   if(x < 1e+21)
   {
      var n = Math.round(x * Math.pow(10,f));
      if(n == 0)
      {
         m = "0";
      }
      else
      {
         m = n.toString();
      }
      if(f > 0)
      {
         var k = m.length;
         if(k <= f)
         {
            var z = "";
            var i = 0;
            while(i < f + 1 - k)
            {
               z += "0";
               i++;
            }
            m = z + m;
            k = f + 1;
         }
         var a = m.substr(0,k - f);
         var b = m.substr(k - f);
         m = a + "." + b;
      }
   }
   else
   {
      m = x.toString();
   }
   return s + m;
};
