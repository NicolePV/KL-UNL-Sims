function ZodiacStripClass()
{
   this.placeholderMC._visible = false;
   if(this.simulatorMC == undefined)
   {
      this.simulatorMC = this._parent;
   }
   this.initialize();
}
var p = ZodiacStripClass.prototype = new MovieClip();
Object.registerClass("Zodiac Strip",ZodiacStripClass);
p.stripWidth = 400;
p.stripHeight = 60;
p.allowDragging = true;
p.backgroundColor = 16777215;
p.borderThickness = 1;
p.borderColor = 10066329;
p.normalConstellationColor = 11579568;
p.activeConstellationColor = 1799908;
p.showConstellationName = function(arg)
{
   this.hideConstellationName(this.activeConstellation);
   this.stripAreaMC.constellationsMC[arg + "1MC"]._visible = true;
   this.stripAreaMC.constellationsMC[arg + "2MC"]._visible = true;
   this.stripAreaMC.constellationsMC[arg + "3MC"]._visible = true;
   this.stripAreaMC.constellationsMC.names1MC[arg + "NameMC"]._visible = true;
   this.stripAreaMC.constellationsMC.names2MC[arg + "NameMC"]._visible = true;
   this.stripAreaMC.constellationsMC.names3MC[arg + "NameMC"]._visible = true;
   this.activeConstellation = arg;
};
p.hideConstellationName = function(arg)
{
   if(typeof arg != "string")
   {
      return undefined;
   }
   this.stripAreaMC.constellationsMC[arg + "1MC"]._visible = false;
   this.stripAreaMC.constellationsMC[arg + "2MC"]._visible = false;
   this.stripAreaMC.constellationsMC[arg + "3MC"]._visible = false;
   this.stripAreaMC.constellationsMC.names1MC[arg + "NameMC"]._visible = false;
   this.stripAreaMC.constellationsMC.names2MC[arg + "NameMC"]._visible = false;
   this.stripAreaMC.constellationsMC.names3MC[arg + "NameMC"]._visible = false;
   this.activeConstellation = null;
};
p.initializeConstellations = function()
{
   var cmc = this.stripAreaMC.constellationsMC;
   cmc.attachMovie("Zodiac Constellation Areas","areas1MC",1,{_alpha:0});
   cmc.attachMovie("Zodiac Constellation Areas","areas2MC",2,{_alpha:0,_x:- this.stripWidth});
   cmc.attachMovie("Zodiac Constellation Areas","areas3MC",3,{_alpha:0,_x:this.stripWidth});
   cmc.attachMovie("Zodiac Constellation Names","names1MC",1001);
   cmc.attachMovie("Zodiac Constellation Names","names2MC",1002,{_x:- this.stripWidth});
   cmc.attachMovie("Zodiac Constellation Names","names3MC",1003,{_x:this.stripWidth});
   var names1ColorObj = new Color(cmc.names1MC);
   var names2ColorObj = new Color(cmc.names2MC);
   var names3ColorObj = new Color(cmc.names3MC);
   names1ColorObj.setRGB(this.activeConstellationColor);
   names2ColorObj.setRGB(this.activeConstellationColor);
   names3ColorObj.setRGB(this.activeConstellationColor);
   var consts = _root.constellationsData;
   var scale = this.stripWidth / 700;
   var i = 0;
   while(i < consts.length)
   {
      var const = consts[i];
      var curves = const.path;
      var points = const.stars;
      var mc = cmc.createEmptyMovieClip(const.name + "1MC",500 + i);
      mc.lineStyle(1,this.activeConstellationColor,100);
      if(i == 7)
      {
         var j = 0;
         while(j < curves.length)
         {
            var cv = curves[j];
            var pt = points[cv.m];
            var ra = (- pt.x) * 3.141592653589793 / 350;
            var dec = (- pt.y) * 3.141592653589793 / 350;
            var e = 0.40913426548833737;
            var elat = Math.asin(Math.sin(dec) * Math.cos(e) - Math.cos(dec) * Math.sin(ra) * Math.sin(e));
            var coselon = Math.cos(dec) * Math.cos(ra) / Math.cos(elat);
            var sinelon = (Math.cos(dec) * Math.sin(ra) * Math.cos(e) + Math.sin(dec) * Math.sin(e)) / Math.cos(elat);
            var elon = Math.atan2(sinelon,coselon);
            elon = (elon % 6.283185307179586 + 6.283185307179586) % 6.283185307179586;
            var x = (- elon) * 111.40846016432674;
            if(x > -350)
            {
               x -= 700;
            }
            var y = (- elat) * 111.40846016432674;
            mc.moveTo(scale * x,scale * y);
            var k = cv.b;
            while(k < cv.e)
            {
               var pt = points[k];
               var ra = (- pt.x) * 3.141592653589793 / 350;
               var dec = (- pt.y) * 3.141592653589793 / 350;
               var e = 0.40913426548833737;
               var elat = Math.asin(Math.sin(dec) * Math.cos(e) - Math.cos(dec) * Math.sin(ra) * Math.sin(e));
               var coselon = Math.cos(dec) * Math.cos(ra) / Math.cos(elat);
               var sinelon = (Math.cos(dec) * Math.sin(ra) * Math.cos(e) + Math.sin(dec) * Math.sin(e)) / Math.cos(elat);
               var elon = Math.atan2(sinelon,coselon);
               elon = (elon % 6.283185307179586 + 6.283185307179586) % 6.283185307179586;
               var x = (- elon) * 111.40846016432674;
               if(x > -350)
               {
                  x -= 700;
               }
               var y = (- elat) * 111.40846016432674;
               mc.lineTo(scale * x,scale * y);
               k++;
            }
            j++;
         }
         var j = 0;
         while(j < curves.length)
         {
            var cv = curves[j];
            var pt = points[cv.m];
            var ra = (- pt.x) * 3.141592653589793 / 350;
            var dec = (- pt.y) * 3.141592653589793 / 350;
            var e = 0.40913426548833737;
            var elat = Math.asin(Math.sin(dec) * Math.cos(e) - Math.cos(dec) * Math.sin(ra) * Math.sin(e));
            var coselon = Math.cos(dec) * Math.cos(ra) / Math.cos(elat);
            var sinelon = (Math.cos(dec) * Math.sin(ra) * Math.cos(e) + Math.sin(dec) * Math.sin(e)) / Math.cos(elat);
            var elon = Math.atan2(sinelon,coselon);
            elon = (elon % 6.283185307179586 + 6.283185307179586) % 6.283185307179586;
            var x = (- elon) * 111.40846016432674;
            if(x < -350)
            {
               x += 700;
            }
            var y = (- elat) * 111.40846016432674;
            mc.moveTo(scale * x,scale * y);
            var k = cv.b;
            while(k < cv.e)
            {
               var pt = points[k];
               var ra = (- pt.x) * 3.141592653589793 / 350;
               var dec = (- pt.y) * 3.141592653589793 / 350;
               var e = 0.40913426548833737;
               var elat = Math.asin(Math.sin(dec) * Math.cos(e) - Math.cos(dec) * Math.sin(ra) * Math.sin(e));
               var coselon = Math.cos(dec) * Math.cos(ra) / Math.cos(elat);
               var sinelon = (Math.cos(dec) * Math.sin(ra) * Math.cos(e) + Math.sin(dec) * Math.sin(e)) / Math.cos(elat);
               var elon = Math.atan2(sinelon,coselon);
               elon = (elon % 6.283185307179586 + 6.283185307179586) % 6.283185307179586;
               var x = (- elon) * 111.40846016432674;
               if(x < -350)
               {
                  x += 700;
               }
               var y = (- elat) * 111.40846016432674;
               mc.lineTo(scale * x,scale * y);
               k++;
            }
            j++;
         }
      }
      else
      {
         var j = 0;
         while(j < curves.length)
         {
            var cv = curves[j];
            var pt = points[cv.m];
            var ra = (- pt.x) * 3.141592653589793 / 350;
            var dec = (- pt.y) * 3.141592653589793 / 350;
            var e = 0.40913426548833737;
            var elat = Math.asin(Math.sin(dec) * Math.cos(e) - Math.cos(dec) * Math.sin(ra) * Math.sin(e));
            var coselon = Math.cos(dec) * Math.cos(ra) / Math.cos(elat);
            var sinelon = (Math.cos(dec) * Math.sin(ra) * Math.cos(e) + Math.sin(dec) * Math.sin(e)) / Math.cos(elat);
            var elon = Math.atan2(sinelon,coselon);
            elon = (elon % 6.283185307179586 + 6.283185307179586) % 6.283185307179586;
            var x = (- elon) * 111.40846016432674;
            var y = (- elat) * 111.40846016432674;
            mc.moveTo(scale * x,scale * y);
            var k = cv.b;
            while(k < cv.e)
            {
               var pt = points[k];
               var ra = (- pt.x) * 3.141592653589793 / 350;
               var dec = (- pt.y) * 3.141592653589793 / 350;
               var e = 0.40913426548833737;
               var elat = Math.asin(Math.sin(dec) * Math.cos(e) - Math.cos(dec) * Math.sin(ra) * Math.sin(e));
               var coselon = Math.cos(dec) * Math.cos(ra) / Math.cos(elat);
               var sinelon = (Math.cos(dec) * Math.sin(ra) * Math.cos(e) + Math.sin(dec) * Math.sin(e)) / Math.cos(elat);
               var elon = Math.atan2(sinelon,coselon);
               elon = (elon % 6.283185307179586 + 6.283185307179586) % 6.283185307179586;
               var x = (- elon) * 111.40846016432674;
               var y = (- elat) * 111.40846016432674;
               mc.lineTo(scale * x,scale * y);
               k++;
            }
            j++;
         }
         var margin = 2;
      }
      mc._visible = false;
      mc.duplicateMovieClip(const.name + "2MC",600 + i,{_x:this.stripWidth,_visible:false});
      mc.duplicateMovieClip(const.name + "3MC",700 + i,{_x:2 * this.stripWidth,_visible:false});
      var nmc = mc.duplicateMovieClip(const.name + "Normal1MC",100 + i,{_x:0});
      var tmpColorObj = new Color(nmc);
      tmpColorObj.setRGB(this.normalConstellationColor);
      nmc.duplicateMovieClip(const.name + "Normal2MC",200 + i,{_x:this.stripWidth});
      nmc.duplicateMovieClip(const.name + "Normal3MC",300 + i,{_x:2 * this.stripWidth});
      i++;
   }
};
p.initialize = function()
{
   this.simulatorMC.addUpdateListener(this);
   this.simulatorMC.addSystemPropertiesListener(this);
   this.simulatorMC.addResetListener(this);
   this.createEmptyMovieClip("backgroundMC",5);
   this.createEmptyMovieClip("stripAreaMC",10);
   this.createEmptyMovieClip("maskMC",11);
   this.createEmptyMovieClip("planetLabelMC",15);
   this.createEmptyMovieClip("sunLabelMC",16);
   this.createEmptyMovieClip("elongationLabelMC",17);
   this.createEmptyMovieClip("borderMC",20);
   var w = this.stripWidth;
   var h = this.stripHeight;
   var a = 5;
   var b = 18;
   var c = 14;
   var d = 8;
   var e = 12;
   this.planetLabelMC.attachMovie("Zodiac Label Text","labelMC",1);
   this.planetLabelMC.labelMC.labelField.text = "planet";
   this.planetLabelMC.labelMC._y = 1 - a - this.planetLabelMC.labelMC._height / 2;
   this.planetLabelMC.lineStyle(1,10066329);
   this.planetLabelMC.moveTo(0,- a);
   this.planetLabelMC.lineTo(0,h / 2 - d);
   this.planetLabelMC.moveTo(0,h / 2 + d);
   this.planetLabelMC.lineTo(0,h + c);
   this.sunLabelMC.attachMovie("Zodiac Label Text","labelMC",1);
   this.sunLabelMC.labelMC.labelField.text = "sun";
   this.sunLabelMC.labelMC._y = 1 - b - this.sunLabelMC.labelMC._height / 2;
   this.sunLabelMC.lineStyle(1,10066329);
   this.sunLabelMC.moveTo(0,- b);
   this.sunLabelMC.lineTo(0,h / 2 - e);
   this.sunLabelMC.moveTo(0,h / 2 + e);
   this.sunLabelMC.lineTo(0,h + c);
   this.elongationLabelY = h + c / 2;
   this.elongationLabelMC.attachMovie("Zodiac Arrow Head","planetArrowHeadMC",2,{_y:this.elongationLabelY});
   this.elongationLabelMC.attachMovie("Zodiac Label Text","labelMC",3);
   this.elongationLabelMC.labelMC._y = this.elongationLabelY + 5 + this.elongationLabelMC.labelMC._height / 2;
   this.arrowHeadWidth = this.elongationLabelMC.planetArrowHeadMC._width;
   this.stripAreaMC.attachMovie("Zodiac Image","zodiacImage1MC",1,{_x:- w});
   this.stripAreaMC.attachMovie("Zodiac Image","zodiacImage2MC",2,{_x:0});
   this.stripAreaMC.attachMovie("Zodiac Image","zodiacImage3MC",3,{_x:w});
   this.stripAreaMC.createEmptyMovieClip("constellationsMC",5);
   this.stripAreaMC.createEmptyMovieClip("sunIconsMC",10);
   this.stripAreaMC.createEmptyMovieClip("planetIconsMC",11);
   this.stripAreaMC.createEmptyMovieClip("planetOutlinesMC",12);
   this.stripAreaMC.constellationsMC._y = h / 2;
   this.stripAreaMC.sunIconsMC._y = h / 2;
   this.stripAreaMC.sunIconsMC.attachMovie("Zodiac Sun Icon","sunIcon1MC",1,{_x:0});
   this.stripAreaMC.sunIconsMC.attachMovie("Zodiac Sun Icon","sunIcon2MC",2,{_x:w});
   this.stripAreaMC.sunIconsMC.attachMovie("Zodiac Sun Icon","sunIcon3MC",3,{_x:2 * w});
   this.stripAreaMC.planetIconsMC._y = h / 2;
   this.stripAreaMC.planetIconsMC.attachMovie("Zodiac Planet Icon","planetIcon1MC",1,{_x:0});
   this.stripAreaMC.planetIconsMC.attachMovie("Zodiac Planet Icon","planetIcon2MC",2,{_x:w});
   this.stripAreaMC.planetIconsMC.attachMovie("Zodiac Planet Icon","planetIcon3MC",3,{_x:2 * w});
   this.stripAreaMC.planetOutlinesMC._y = h / 2;
   this.stripAreaMC.planetOutlinesMC.attachMovie("Zodiac Planet Outline","planetOutline1MC",1,{_x:0});
   this.stripAreaMC.planetOutlinesMC.attachMovie("Zodiac Planet Outline","planetOutline2MC",2,{_x:w});
   this.stripAreaMC.planetOutlinesMC.attachMovie("Zodiac Planet Outline","planetOutline3MC",3,{_x:2 * w});
   this.initializeConstellations();
   this.stripAreaMC.setMask(this.maskMC);
   this.backgroundMC.moveTo(0,0);
   this.backgroundMC.beginFill(16711680,0);
   this.backgroundMC.lineTo(w,0);
   this.backgroundMC.lineTo(w,h);
   this.backgroundMC.lineTo(0,h);
   this.backgroundMC.lineTo(0,0);
   this.backgroundMC.endFill();
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
   if(this.allowDragging)
   {
      this.backgroundMC.useHandCursor = false;
      this.backgroundMC.tabEnabled = false;
      this.backgroundMC.onPress = function()
      {
         this.initX = this._xmouse;
         this.initOffset = this._parent.offset;
         this.onMouseMove = this.onMouseMoveFunc;
      };
      this.backgroundMC.onMouseMoveFunc = function()
      {
         this._parent.setOffset(this.initOffset + this._xmouse - this.initX);
         updateAfterEvent();
      };
      this.backgroundMC.onRelease = this.backgroundMC.onReleaseOutside = function()
      {
         delete this.onMouseMove;
      };
   }
   this.scale = this.stripWidth / 6.283185307179586;
};
p.onSimulatorReset = function()
{
   this.setOffset(-100);
};
p.setOffset = function(arg)
{
   this.offset = (arg % this.stripWidth + this.stripWidth) % this.stripWidth;
   if(this.offset < this.stripWidth / 2)
   {
      this.stripAreaMC._x = this.offset;
   }
   else
   {
      this.stripAreaMC._x = this.offset - this.stripWidth;
   }
   this.updateLabelPositions();
};
p.updateLabelPositions = function()
{
   var w = this.stripWidth;
   var planetX = ((w + this.stripAreaMC.planetIconsMC._x + this.offset) % w + w) % w;
   var sunX = ((w + this.stripAreaMC.sunIconsMC._x + this.offset) % w + w) % w;
   this.planetLabelMC._x = planetX;
   this.sunLabelMC._x = sunX;
   var emc = this.elongationLabelMC;
   emc.clear();
   emc.lineStyle(1,0);
   emc.planetArrowHeadMC._x = planetX;
   emc.sunArrowHeadMC._x = sunX;
   var y = this.elongationLabelY;
   var arrowLength = Math.abs(this.simulatorMC.elongationValue) * this.stripWidth / 360;
   if(this.simulatorMC.elongationValue < 0)
   {
      emc.sunArrowHeadMC._xscale = 100;
      emc.planetArrowHeadMC._xscale = -100;
      emc.sunArrowHeadMC._yscale = 100;
      emc.planetArrowHeadMC._yscale = 100;
      if(planetX > sunX)
      {
         emc.moveTo(sunX,y);
         emc.lineTo(-2,y);
         emc.moveTo(-4,y);
         emc.lineTo(-5,y);
         emc.moveTo(-7,y);
         emc.lineTo(-8,y);
         emc.moveTo(-10,y);
         emc.lineTo(-11,y);
         emc.moveTo(w + 4,y);
         emc.lineTo(w + 5,y);
         emc.moveTo(w + 7,y);
         emc.lineTo(w + 8,y);
         emc.moveTo(w + 10,y);
         emc.lineTo(w + 11,y);
         emc.moveTo(w + 2,y);
         emc.lineTo(planetX,y);
         this.elongationLabelMC.labelMC._x = sunX - arrowLength / 2;
         if(this.elongationLabelMC.labelMC._x < 0)
         {
            this.elongationLabelMC.labelMC._x += w;
         }
      }
      else
      {
         emc.moveTo(sunX,y);
         emc.lineTo(planetX,y);
         this.elongationLabelMC.labelMC._x = sunX - arrowLength / 2;
      }
   }
   else if(this.simulatorMC.elongationValue > 0)
   {
      emc.sunArrowHeadMC._xscale = -100;
      emc.planetArrowHeadMC._xscale = 100;
      emc.sunArrowHeadMC._yscale = 100;
      emc.planetArrowHeadMC._yscale = 100;
      if(planetX < sunX)
      {
         emc.moveTo(sunX,y);
         emc.lineTo(w + 2,y);
         emc.moveTo(w + 4,y);
         emc.lineTo(w + 5,y);
         emc.moveTo(w + 7,y);
         emc.lineTo(w + 8,y);
         emc.moveTo(w + 10,y);
         emc.lineTo(w + 11,y);
         emc.moveTo(-4,y);
         emc.lineTo(-5,y);
         emc.moveTo(-7,y);
         emc.lineTo(-8,y);
         emc.moveTo(-10,y);
         emc.lineTo(-11,y);
         emc.moveTo(-2,y);
         emc.lineTo(planetX,y);
         this.elongationLabelMC.labelMC._x = sunX + arrowLength / 2;
         if(this.elongationLabelMC.labelMC._x > w)
         {
            this.elongationLabelMC.labelMC._x -= w;
         }
      }
      else
      {
         emc.moveTo(sunX,y);
         emc.lineTo(planetX,y);
         this.elongationLabelMC.labelMC._x = sunX + arrowLength / 2;
      }
   }
   else
   {
      emc.sunArrowHeadMC._xscale = 0;
      emc.planetArrowHeadMC._xscale = 0;
      emc.sunArrowHeadMC._yscale = 0;
      emc.planetArrowHeadMC._yscale = 0;
      this.elongationLabelMC.labelMC._x = sunX;
   }
   var arrowHeadScalingFactor = arrowLength / (3 * this.arrowHeadWidth);
   if(arrowHeadScalingFactor > 1)
   {
      arrowHeadScalingFactor = 1;
   }
   emc.sunArrowHeadMC._xscale *= arrowHeadScalingFactor;
   emc.planetArrowHeadMC._xscale *= arrowHeadScalingFactor;
   emc.sunArrowHeadMC._yscale *= arrowHeadScalingFactor;
   emc.planetArrowHeadMC._yscale *= arrowHeadScalingFactor;
   this.elongationLabelMC.labelMC.labelField.text = this.simulatorMC.elongationString;
};
p.onSimulatorUpdated = function()
{
   this.stripAreaMC.planetIconsMC._x = this.stripAreaMC.planetOutlinesMC._x = (- this.simulatorMC.planetLongitude) * this.scale;
   this.stripAreaMC.sunIconsMC._x = (- this.simulatorMC.sunLongitude) * this.scale;
   this.updateLabelPositions();
   if(this.planetIsInferior)
   {
      var fracSynodicPeriod = ((this.simulatorMC.time - this.simulatorMC.cycleOffset) / this.simulatorMC.synodicPeriod % 1 + 1) % 1;
      if(fracSynodicPeriod > 0.25 && fracSynodicPeriod < 0.75)
      {
         this.stripAreaMC.planetIconsMC.swapDepths(10);
      }
      else
      {
         this.stripAreaMC.planetIconsMC.swapDepths(11);
      }
   }
};
p.onSystemPropertiesChanged = function()
{
   if(this.simulatorMC.semimajorAxis1 < this.simulatorMC.semimajorAxis2)
   {
      this.planetIsInferior = false;
      this.stripAreaMC.planetIconsMC.swapDepths(10);
   }
   else
   {
      this.planetIsInferior = true;
   }
};
