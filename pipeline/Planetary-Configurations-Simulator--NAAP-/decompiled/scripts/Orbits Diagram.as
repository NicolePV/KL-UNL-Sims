function OrbitsDiagramClass()
{
   this.diagramWidth = 450;
   this.diagramHeight = 465;
   this.placeholderMC._visible = false;
   if(this.simulatorMC == undefined)
   {
      this.simulatorMC = this._parent;
   }
   this.initialize();
}
var p = OrbitsDiagramClass.prototype = new MovieClip();
Object.registerClass("Orbits Diagram",OrbitsDiagramClass);
p.angleMargin = 15;
p.orbitMargin = 60;
p.snapToEvents = true;
p.snapDistance = 10;
p.orbitThickness = 1;
p.orbitColor = 13158600;
p._backgroundColor = 16777215;
p.borderThickness = 1;
p.borderColor = 6710886;
p._showBorder = true;
p.observerPlanetColor = 8626940;
p.observedPlanetColor = 10000536;
p.initialize = function()
{
   this.simulatorMC.addUpdateListener(this);
   this.simulatorMC.addSystemPropertiesListener(this);
   this.simulatorMC.addResetListener(this);
   var w = this.diagramWidth;
   var h = this.diagramHeight;
   this.createEmptyMovieClip("backgroundMC",1);
   this.createEmptyMovieClip("maskedAreaMC",5);
   this.createEmptyMovieClip("maskMC",6);
   this.createEmptyMovieClip("borderMC",10);
   this.attachMovie("Orbits Diagram Options","optionsMC",15,{diagramMC:this});
   this.optionsMC._y = h - this.optionsMC._height;
   this.maskedAreaMC.attachMovie("Orbits Diagram Sun","sunMC",1);
   this.maskedAreaMC.createEmptyMovieClip("labelsMC",5);
   this.maskedAreaMC.createEmptyMovieClip("orbitsMC",10);
   this.maskedAreaMC.createEmptyMovieClip("angleMC",15);
   this.maskedAreaMC.createEmptyMovieClip("planetsMC",20);
   this.maskedAreaMC.labelsMC.attachMovie("CurvedText","label1MC",1,{fontSource:"Verdana 10pt",text:"observer\'s planet",radius:100,gap:0.25});
   this.maskedAreaMC.labelsMC.attachMovie("CurvedText","label2MC",2,{fontSource:"Verdana 10pt",text:"target planet",radius:100,gap:0.25});
   this.maskedAreaMC.labelsMC.label1MC.update();
   this.maskedAreaMC.labelsMC.label2MC.update();
   this.maskedAreaMC.labelsMC.label1MC.doFlip();
   this.maskedAreaMC.angleMC.createEmptyMovieClip("linesMC",0);
   this.maskedAreaMC.angleMC.attachMovie("Orbits Diagram Angle Arrow Head","angleHeadMC",5);
   this.maskedAreaMC.angleMC.attachMovie("Orbits Diagram Arrow Tip","arrowTip1MC",10);
   this.maskedAreaMC.angleMC.attachMovie("Orbits Diagram Arrow Tip","arrowTip2MC",11);
   this.maskedAreaMC.angleMC.createEmptyMovieClip("labelMC",15);
   this.maskedAreaMC.angleMC.labelMC.createTextField("labelField",1,0,0,0,0);
   this.maskedAreaMC.angleMC.labelMC.labelField.embedFonts = true;
   this.maskedAreaMC.angleMC.labelMC.labelField.autoSize = "center";
   this.maskedAreaMC.angleMC.labelMC.labelField.setNewTextFormat(new TextFormat("Verdana",10,0));
   this.maskedAreaMC.angleMC.labelMC.labelField.border = false;
   this.maskedAreaMc.angleMC.labelMC.labelField.background = false;
   this.maskedAreaMC.angleMC.labelMC.labelField.selectable = false;
   this.maskedAreaMC.angleMC.labelMC.labelField.text = "8";
   this.maskedAreaMC.angleMC.labelMC.labelField._y = (- this.maskedAreaMC.angleMC.labelMC.labelField._height) / 2;
   this.maskedAreaMC.angleMC._visible = false;
   this.maskedAreaMC.planetsMC.attachMovie("Orbits Diagram Planet","planet1MC",1,{discColor:this.observerPlanetColor,id:1,diagramMC:this,simulatorMC:this.simulatorMC});
   this.maskedAreaMC.planetsMC.attachMovie("Orbits Diagram Planet","planet2MC",2,{discColor:this.observedPlanetColor,id:2,diagramMC:this,simulatorMC:this.simulatorMC});
   this.maskedAreaMC.setMask(this.maskMC);
   this.angleArrowHeadWidth = this.maskedAreaMC.angleMC.angleHeadMC._width;
   this.backgroundColorObject = new Color(this.backgroundMC);
   this.borderMC._visible = this._showBorder;
   this.backgroundMC._visible = false;
   this.borderMC._visible = false;
   this.maskedAreaMC._x = this.maskedAreaMC._y = w / 2;
   this.backgroundMC.lineStyle();
   this.backgroundMC.moveTo(0,0);
   this.backgroundMC.beginFill(this._backgroundColor);
   this.backgroundMC.lineTo(w,0);
   this.backgroundMC.lineTo(w,h);
   this.backgroundMC.lineTo(0,h);
   this.backgroundMC.lineTo(0,0);
   this.backgroundMC.endFill();
   this.maskMC.lineStyle();
   this.maskMC.moveTo(0,0);
   this.maskMC.beginFill(16711680,30);
   this.maskMC.lineTo(w,0);
   this.maskMC.lineTo(w,h);
   this.maskMC.lineTo(0,h);
   this.maskMC.lineTo(0,0);
   this.maskMC.endFill();
   this.borderMC.lineStyle(this.borderThickness,this.borderColor);
   this.borderMC.moveTo(0,0);
   this.borderMC.lineTo(w,0);
   this.borderMC.lineTo(w,h);
   this.borderMC.lineTo(0,h);
   this.borderMC.lineTo(0,0);
};
p.getShowBorder = function()
{
   return this._showBorder;
};
p.setShowBorder = function(arg)
{
   this._showBorder = arg;
   this.borderMC._visible = this._showBorder;
};
p.addProperty("showBorder",p.getShowBorder,p.setShowBorder);
p.getBackgroundColor = function()
{
   return this._backgroundColor;
};
p.setBackgroundColor = function(arg)
{
   this._backgroundColor = arg;
   this.backgroundColorObject.setRGB(this._backgroundColor);
};
p.addProperty("backgroundColor",p.getBackgroundColor,p.setBackgroundColor);
p.setShowOrbitLabels = function(arg)
{
   this.maskedAreaMC.labelsMC._visible = arg;
};
p.setShowElongationAngle = function(arg)
{
   this.maskedAreaMC.angleMC._visible = arg;
};
p.maxArcStep = 0.5;
p.drawArc = function(mc, x, y, radius, startAngle, endAngle)
{
   if(startAngle == undefined)
   {
      startAngle = 0;
      endAngle = 6.283185307179586;
   }
   else
   {
      if(startAngle < 0)
      {
         startAngle = startAngle % 6.283185307179586 + 6.283185307179586;
      }
      else
      {
         startAngle %= 6.283185307179586;
      }
      if(endAngle < 0)
      {
         endAngle = endAngle % 6.283185307179586 + 6.283185307179586;
      }
      else
      {
         endAngle %= 6.283185307179586;
      }
   }
   var range = endAngle - startAngle;
   if(range < 0)
   {
      range = 6.283185307179586 + range;
   }
   var n = Math.ceil(range / this.maxArcStep);
   var step = range / n;
   var half = step / 2;
   var cos = Math.cos;
   var sin = Math.sin;
   var cRadius = radius / cos(half);
   var aAngle = startAngle;
   var cAngle = startAngle - half;
   mc.moveTo(x + radius * cos(startAngle),y - radius * sin(startAngle));
   var i = 0;
   while(i < n)
   {
      aAngle += step;
      cAngle += step;
      mc.curveTo(x + cRadius * cos(cAngle),y - cRadius * sin(cAngle),x + radius * cos(aAngle),y - radius * sin(aAngle));
      i++;
   }
};
p.onSimulatorReset = function()
{
   this.optionsMC.labelOrbitsCheck.setValue(true);
   this.optionsMC.showElongationAngleCheck.setValue(false);
   this.optionsMC.snapToEventsCheck.setValue(true);
};
p.onSimulatorUpdated = function()
{
   var x1 = this.screenRadius1 * Math.cos(this.simulatorMC.angle1);
   var y1 = (- this.screenRadius1) * Math.sin(this.simulatorMC.angle1);
   var x2 = this.screenRadius2 * Math.cos(this.simulatorMC.angle2);
   var y2 = (- this.screenRadius2) * Math.sin(this.simulatorMC.angle2);
   this.maskedAreaMC.planetsMC.planet1MC._x = x1;
   this.maskedAreaMC.planetsMC.planet1MC._y = y1;
   this.maskedAreaMC.planetsMC.planet2MC._x = x2;
   this.maskedAreaMC.planetsMC.planet2MC._y = y2;
   var mc = this.maskedAreaMC.angleMC.linesMC;
   mc.clear();
   mc.lineStyle(1,10526880);
   var planetAngle = Math.atan2(y2 - y1,x2 - x1);
   var sunAngle = Math.atan2(- y1,- x1);
   var r = this.diagramWidth / 2 - this.angleMargin;
   var t = Math.sqrt(x1 * x1 + y1 * y1);
   var b = t * Math.cos(sunAngle - planetAngle);
   var Q = b * b - t * t + r * r;
   if(Q < 0)
   {
      trace("WARNING, Q < 0");
   }
   var d1 = b + Math.sqrt(Q);
   var x3 = x1 + d1 * Math.cos(planetAngle);
   var y3 = y1 + d1 * Math.sin(planetAngle);
   var x4 = r * Math.cos(sunAngle);
   var y4 = r * Math.sin(sunAngle);
   mc.moveTo(x1,y1);
   mc.lineTo(x3,y3);
   mc.moveTo(x1,y1);
   mc.lineTo(x4,y4);
   this.maskedAreaMC.angleMC.arrowTip1MC._x = x3;
   this.maskedAreaMC.angleMC.arrowTip1MC._y = y3;
   this.maskedAreaMC.angleMC.arrowTip1MC._rotation = planetAngle * 180 / 3.141592653589793;
   this.maskedAreaMC.angleMC.arrowTip2MC._x = x4;
   this.maskedAreaMC.angleMC.arrowTip2MC._y = y4;
   this.maskedAreaMC.angleMC.arrowTip2MC._rotation = sunAngle * 180 / 3.141592653589793;
   var r = 35;
   var dr = 10;
   var labelAngle = sunAngle + this.simulatorMC.elongationValue / 2 * 0.017453292519943295;
   this.maskedAreaMC.angleMC.labelMC._x = x1 + (r + dr) * Math.cos(labelAngle);
   this.maskedAreaMC.angleMC.labelMC._y = y1 + (r + dr) * Math.sin(labelAngle);
   this.maskedAreaMC.angleMC.labelMC.labelField.text = this.simulatorMC.elongationString;
   var labelRotation = ((90 + labelAngle * 180 / 3.141592653589793) % 360 + 360) % 360;
   if(labelRotation <= 90 || labelRotation >= 270)
   {
      this.maskedAreaMC.angleMC.labelMC._rotation = labelRotation;
   }
   else
   {
      this.maskedAreaMC.angleMC.labelMC._rotation = labelRotation + 180;
   }
   var hh = this.maskedAreaMC.angleMC.labelMC.labelField.textHeight / 2;
   var hw = (this.maskedAreaMC.angleMC.labelMC.labelField.textWidth + 4) / 2;
   this.maskedAreaMC.angleMC.labelMC.clear();
   this.maskedAreaMC.angleMC.labelMC.moveTo(- hw,- hh);
   this.maskedAreaMC.angleMC.labelMC.beginFill(16777215,60);
   this.maskedAreaMC.angleMC.labelMC.lineTo(hw,- hh);
   this.maskedAreaMC.angleMC.labelMC.lineTo(hw,hh);
   this.maskedAreaMC.angleMC.labelMC.lineTo(- hw,hh);
   this.maskedAreaMC.angleMC.labelMC.lineTo(- hw,- hh);
   this.maskedAreaMC.angleMC.labelMC.endFill();
   this.maskedAreaMC.angleMC.angleHeadMC._x = x1 + r * Math.cos(planetAngle);
   this.maskedAreaMC.angleMC.angleHeadMC._y = y1 + r * Math.sin(planetAngle);
   this.maskedAreaMC.angleMC.angleHeadMC._rotation = 90 + planetAngle * 180 / 3.141592653589793;
   if(this.simulatorMC.elongationValue < 0)
   {
      this.drawArc(mc,x1,y1,r,- sunAngle,- planetAngle);
      this.maskedAreaMC.angleMC.angleHeadMC._xscale = -100;
      this.maskedAreaMC.angleMC.angleHeadMC._yscale = 100;
   }
   else if(this.simulatorMC.elongationValue > 0)
   {
      this.drawArc(mc,x1,y1,r,- planetAngle,- sunAngle);
      this.maskedAreaMC.angleMC.angleHeadMC._xscale = 100;
      this.maskedAreaMC.angleMC.angleHeadMC._yscale = 100;
   }
   else
   {
      this.maskedAreaMC.angleMC.angleHeadMC._xscale = 0;
      this.maskedAreaMC.angleMC.angleHeadMC._yscale = 0;
   }
   var scalingFactor = Math.abs(this.simulatorMC.elongationValue * 3.141592653589793 / 180) / (2 * Math.atan(this.angleArrowHeadWidth / r));
   if(scalingFactor > 1)
   {
      scalingFactor = 1;
   }
   this.maskedAreaMC.angleMC.angleHeadMC._xscale *= scalingFactor;
   this.maskedAreaMC.angleMC.angleHeadMC._yscale *= scalingFactor;
};
p.onSystemPropertiesChanged = function()
{
   var scale = (this.diagramWidth - 2 * this.orbitMargin) / Math.max(this.simulatorMC.semimajorAxis1,this.simulatorMC.semimajorAxis2);
   this.screenRadius1 = scale * this.simulatorMC.semimajorAxis1 / 2;
   this.screenRadius2 = scale * this.simulatorMC.semimajorAxis2 / 2;
   this.maskedAreaMC.orbitsMC.clear();
   this.maskedAreaMC.orbitsMC.lineStyle(this.orbitThickness,this.orbitColor);
   this.drawArc(this.maskedAreaMC.orbitsMC,0,0,this.screenRadius1);
   this.drawArc(this.maskedAreaMC.orbitsMC,0,0,this.screenRadius2);
   var minR = 30;
   var eR = 13;
   if(this.screenRadius1 + eR < minR)
   {
      this.maskedAreaMC.labelsMC.label1MC.radius = minR;
   }
   else
   {
      this.maskedAreaMC.labelsMC.label1MC.radius = eR + this.screenRadius1;
   }
   if(this.screenRadius2 + eR < minR)
   {
      this.maskedAreaMC.labelsMC.label2MC.radius = minR;
   }
   else
   {
      this.maskedAreaMC.labelsMC.label2MC.radius = eR + this.screenRadius2;
   }
   this.maskedAreaMC.labelsMC.label1MC.update(true);
   this.maskedAreaMC.labelsMC.label2MC.update(true);
};
