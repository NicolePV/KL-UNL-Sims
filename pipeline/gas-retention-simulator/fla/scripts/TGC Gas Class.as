function TGCGasClass(parent, name, depthOffset, initObject)
{
   this._parent = parent;
   this._name = name;
   this._depthOffset = depthOffset;
   this.particlesMC = this._parent.particlesMC;
   this.escapeesMC = this._parent.escapeesMC.createEmptyMovieClip("_" + depthOffset,depthOffset);
   this.escapeeMCsTotal = 0;
   this.freeEscapeeMCsList = [];
   this.escapeesList = [];
   this.particleMCsTotal = 0;
   this.freeParticleMCsList = [];
   this.particlesList = [];
   if(typeof initObject.initObject == "object")
   {
      this.initObject = initObject.initObject;
   }
   else
   {
      this.initObject = {};
   }
   if(initObject.expireParticles != undefined)
   {
      this._expireParticles = initObject.expireParticles;
   }
   else
   {
      this._expireParticles = true;
   }
   if(initObject.minAlpha != undefined)
   {
      this._minAlpha = initObject.minAlpha;
   }
   else
   {
      this._minAlpha = 10;
   }
   if(initObject.maxAlpha != undefined)
   {
      this._maxAlpha = initObject.maxAlpha;
   }
   else
   {
      this._maxAlpha = 100;
   }
   if(initObject.maxAlphaTime != undefined)
   {
      this._maxAlphaTime = initObject.maxAlphaTime;
   }
   else
   {
      this._maxAlphaTime = 10000;
   }
   if(initObject.fadeTime != undefined)
   {
      this._fadeTime = initObject.fadeTime;
   }
   else
   {
      this._fadeTime = 2500;
   }
   this._lifetime = 2 * this._fadeTime + this._maxAlphaTime;
   if(initObject.linkageName != undefined)
   {
      this._linkageName = initObject.linkageName;
   }
   else
   {
      this._linkageName = "TGC Default Particle";
   }
   if(initObject.mass != undefined)
   {
      this._mass = initObject.mass;
   }
   else
   {
      this._mass = 4;
   }
   if(initObject.numberOfParticles != undefined)
   {
      this.setNumberOfParticles(initObject.numberOfParticles);
   }
   else
   {
      this.setNumberOfParticles(20);
   }
}
var p = TGCGasClass.prototype = new Object();
p.sendObjectToMovieClips = function(obj)
{
   var pL = this.particlesList;
   var i = 0;
   while(i < pL.length)
   {
      pL[i].mc.receiveObject(obj);
      i++;
   }
};
p.advanceEscapees = function(deltaTime)
{
   var max = Math.max;
   var w = this._parent._boundaryWidth;
   var h = this._parent._boundaryHeight;
   var d = this._parent._escapeeTravelDistance;
   var fL = this.freeEscapeeMCsList;
   var eL = this.escapeesList;
   var i = eL.length - 1;
   while(i >= 0)
   {
      var e = eL[i];
      var nx = e.mc._x + deltaTime * e.vx;
      var ny = e.mc._y + deltaTime * e.vy;
      if(nx > w)
      {
         var dx = nx - w;
      }
      else
      {
         var dx = - nx;
      }
      if(ny > h)
      {
         var dy = ny - h;
      }
      else
      {
         var dy = - ny;
      }
      var u = max(dx,dy) / d;
      if(u < 1)
      {
         e.mc._x = nx;
         e.mc._y = ny;
         e.mc._alpha = (1 - u) * e.alpha;
      }
      else
      {
         e.mc._visible = false;
         fL.push(e.mc);
         eL.splice(i,1);
      }
      i--;
   }
};
p.addEscapees = function(newEscapeesList)
{
   var mcShortage = newEscapeesList.length - this.freeEscapeeMCsList.length;
   var i = 0;
   while(i < mcShortage)
   {
      var depth = this.escapeeMCsTotal++;
      this.freeEscapeeMCsList.push(this.escapeesMC.attachMovie(this._linkageName,"_" + depth,depth,this.initObject));
      i++;
   }
   var i = 0;
   while(i < newEscapeesList.length)
   {
      var e = newEscapeesList[i];
      e.mc = this.freeEscapeeMCsList.pop();
      e.mc._visible = true;
      e.mc._alpha = e.alpha;
      e.mc._x = e.x;
      e.mc._y = e.y;
      this.escapeesList.push(e);
      i++;
   }
};
p.clearEscapees = function()
{
   var fL = this.freeEscapeeMCsList;
   var eL = this.escapeesList;
   var i = eL.length - 1;
   while(i >= 0)
   {
      eL[i].mc._visible = false;
      fL.push(eL[i].mc);
      i--;
   }
   var eL = [];
};
p.remove = function()
{
   var pL = this.particlesList;
   var i = 0;
   while(i < pL.length)
   {
      pL[i].mc.removeMovieClip();
      i++;
   }
   var fL = this.freeParticleMCsList;
   var i = 0;
   while(i < fL.length)
   {
      fL[i].removeMovieClip();
      i++;
   }
   this.escapeesMC.removeMovieClip();
   var gL = this._parent.gassesList;
   var i = 0;
   while(i < gL.length)
   {
      if(gL[i] == this)
      {
         gL.splice(i,1);
         break;
      }
      i++;
   }
   this._parent.depthOffsetsList.push(this._depthOffset);
};
p.advanceParticles = function(deltaTime, deltaAge)
{
   var pL = this.particlesList;
   var pLlen = pL.length;
   if(this._expireParticles)
   {
      var exL = [];
      var lifetime = this._lifetime;
      var fadeTime = this._fadeTime;
      var fadeInEnd = fadeTime;
      var fadeOutStart = fadeInEnd + this._maxAlphaTime;
      var minAlpha = this._minAlpha;
      var maxAlpha = this._maxAlpha;
      var alphaRange = maxAlpha - minAlpha;
      var i = 0;
      while(i < pLlen)
      {
         var p = pL[i];
         p.age += deltaAge;
         if(p.age > lifetime)
         {
            exL.push(p);
         }
         else if(p.age < fadeInEnd)
         {
            p.mc._alpha = minAlpha + alphaRange * p.age / fadeTime;
         }
         else if(p.age < fadeOutStart)
         {
            p.mc._alpha = maxAlpha;
         }
         else
         {
            p.mc._alpha = maxAlpha - alphaRange * (p.age - fadeOutStart) / fadeTime;
         }
         i++;
      }
      if(exL.length > 0)
      {
         this.initializeParticles(exL,true);
      }
   }
   var w = this._parent._boundaryWidth;
   var h = this._parent._boundaryHeight;
   if(this._parent._allowEscape)
   {
      var rand = Math.random;
      var cos = Math.cos;
      var sin = Math.sin;
      var espL = [];
      var esiL = [];
      var ev = this._parent._escapeSpeedPxPerSimSec;
      var i = 0;
      while(i < pLlen)
      {
         var p = pL[i];
         if(p.v > ev)
         {
            var nx = p.mc._x + deltaTime * p.vx;
            var ny = p.mc._y + deltaTime * p.vy;
            if(nx > w || nx < 0 || ny < 0 || ny > h)
            {
               esiL.push({x:p.mc._x,y:p.mc._y,vx:p.vx,vy:p.vy,alpha:p.mc._alpha});
               p.mc._x = w * rand();
               p.mc._y = h * rand();
               var angle = 6.283185307179586 * rand();
               p.unscaledVX = p.unscaledV * cos(angle);
               p.unscaledVY = p.unscaledV * sin(angle);
               espL.push(p);
            }
            else
            {
               p.mc._x = nx;
               p.mc._y = ny;
            }
         }
         else
         {
            var nx = p.mc._x + deltaTime * p.vx;
            var ny = p.mc._y + deltaTime * p.vy;
            var mx = (nx / w % 2 + 2) % 2;
            var my = (ny / h % 2 + 2) % 2;
            if(mx < 1)
            {
               p.mc._x = mx * w;
            }
            else
            {
               p.vx *= -1;
               p.unscaledVX *= -1;
               p.mc._x = 2 * w - mx * w;
            }
            if(my < 1)
            {
               p.mc._y = my * h;
            }
            else
            {
               p.vy *= -1;
               p.unscaledVY *= -1;
               p.mc._y = 2 * h - my * h;
            }
         }
         i++;
      }
      if(espL.length > 0)
      {
         this.calculateSpeeds(espL);
         this.addEscapees(esiL);
      }
   }
   else
   {
      var i = 0;
      while(i < pLlen)
      {
         var p = pL[i];
         var nx = p.mc._x + deltaTime * p.vx;
         var ny = p.mc._y + deltaTime * p.vy;
         var mx = (nx / w % 2 + 2) % 2;
         var my = (ny / h % 2 + 2) % 2;
         if(mx < 1)
         {
            p.mc._x = mx * w;
         }
         else
         {
            p.vx *= -1;
            p.unscaledVX *= -1;
            p.mc._x = 2 * w - mx * w;
         }
         if(my < 1)
         {
            p.mc._y = my * h;
         }
         else
         {
            p.vy *= -1;
            p.unscaledVY *= -1;
            p.mc._y = 2 * h - my * h;
         }
         i++;
      }
   }
   this.advanceEscapees(deltaTime);
};
p.calculateSpeeds = function(calcList)
{
   if(typeof calcList != "object")
   {
      var cL = this.particlesList;
   }
   else
   {
      var cL = calcList;
   }
   var cLlen = cL.length;
   var a = Math.sqrt(1.3806503e-23 * this._parent._temperature / (1.66053886e-27 * this._mass)) / this._parent._scale;
   var i = 0;
   while(i < cLlen)
   {
      var p = cL[i];
      p.v = a * p.unscaledV;
      p.vx = a * p.unscaledVX;
      p.vy = a * p.unscaledVY;
      i++;
   }
};
p.initializeParticles = function(initList, fadeIn)
{
   if(typeof initList != "object")
   {
      var iL = this.particlesList;
   }
   else
   {
      var iL = initList;
   }
   var iLlen = iL.length;
   var rand = Math.random;
   var sin = Math.sin;
   var cos = Math.cos;
   var minAlpha = this._minAlpha;
   var maxAlpha = this._maxAlpha;
   if(this._expireParticles)
   {
      if(fadeIn)
      {
         var i = 0;
         while(i < iLlen)
         {
            var p = iL[i];
            p.age = 0;
            p.mc._alpha = minAlpha;
            i++;
         }
      }
      else
      {
         var lifetime = this._lifetime;
         var fadeTime = this._fadeTime;
         var fadeInEnd = fadeTime;
         var fadeOutStart = fadeInEnd + this._maxAlphaTime;
         var alphaRange = maxAlpha - minAlpha;
         var i = 0;
         while(i < iLlen)
         {
            var p = iL[i];
            p.age = lifetime * rand();
            if(p.age < fadeInEnd)
            {
               p.mc._alpha = minAlpha + alphaRange * p.age / fadeTime;
            }
            else if(p.age < fadeOutStart)
            {
               p.mc._alpha = maxAlpha;
            }
            else
            {
               p.mc._alpha = maxAlpha - alphaRange * (p.age - fadeOutStart) / fadeTime;
            }
            i++;
         }
      }
   }
   else
   {
      var i = 0;
      while(i < iLlen)
      {
         iL[i].mc._alpha = maxAlpha;
         i++;
      }
   }
   var w = this._parent._boundaryWidth;
   var h = this._parent._boundaryHeight;
   var i = 0;
   while(i < iLlen)
   {
      var p = iL[i];
      p.mc._x = w * rand();
      p.mc._y = h * rand();
      var u = rand();
      var speed = (0.0335009738566387 + u * (324.499855174808 + u * (67952.3527878137 + u * (1649609.82033456 + u * (2184252.22113819 + u * (-21058874.6332882 + u * (26738095.9605488 + u * (769197.569308745 + u * (-21394748.7073447 + u * (13624855.3507324 + u * -2580664.4615644)))))))))) / (1 + u * (1632.61962771862 + u * (155759.053592243 + u * (1790252.45942473 + u * (-3060237.16137971 + u * (-9765674.6273682 + u * (28452708.8769605 + u * (-25616300.7710808 + u * (7698980.62184725 + u * (1037426.91742616 + u * -694548.98898973))))))))));
      var angle = 6.283185307179586 * rand();
      p.unscaledV = speed;
      p.unscaledVX = speed * cos(angle);
      p.unscaledVY = speed * sin(angle);
      i++;
   }
   this.calculateSpeeds(iL);
};
p.getExpireParticles = function()
{
   return this._expireParticles;
};
p.setExpireParticles = function(arg)
{
   this._expireParticles = Boolean(arg);
   var maxAlpha = this._maxAlpha;
   var pL = this.particlesList;
   var pLlen = pL.length;
   if(this._expireParticles)
   {
      var rand = Math.random;
      var lifetime = this._lifetime;
      var fadeTime = this._fadeTime;
      var fadeInEnd = fadeTime;
      var fadeOutStart = fadeInEnd + this._maxAlphaTime;
      var minAlpha = this._minAlpha;
      var alphaRange = maxAlpha - minAlpha;
      var i = 0;
      while(i < pLlen)
      {
         var p = pL[i];
         p.age = lifetime * rand();
         if(p.age < fadeInEnd)
         {
            p.mc._alpha = minAlpha + alphaRange * p.age / fadeTime;
         }
         else if(p.age < fadeOutStart)
         {
            p.mc._alpha = maxAlpha;
         }
         else
         {
            p.mc._alpha = maxAlpha - alphaRange * (p.age - fadeOutStart) / fadeTime;
         }
         i++;
      }
   }
   else
   {
      var i = 0;
      while(i < pLlen)
      {
         pL[i].mc._alpha = maxAlpha;
         i++;
      }
   }
};
p.addProperty("expireParticles",p.getExpireParticles,p.setExpireParticles);
p.getMinAlpha = function()
{
   return this._minAlpha;
};
p.setMinAlpha = function(arg)
{
   this._minAlpha = arg;
   if(this._expireParticles)
   {
      this.advanceParticles(0,0);
   }
};
p.addProperty("minAlpha",p.getMinAlpha,p.setMinAlpha);
p.getMaxAlpha = function()
{
   return this._maxAlpha;
};
p.setMaxAlpha = function(arg)
{
   this._maxAlpha = arg;
   if(this._expireParticles)
   {
      this.advanceParticles(0,0);
   }
};
p.addProperty("maxAlpha",p.getMaxAlpha,p.setMaxAlpha);
p.getMaxAlphaTime = function()
{
   return this._maxAlphaTime;
};
p.setMaxAlphaTime = function(arg)
{
   this._maxAlphaTime = arg;
   this._lifetime = 2 * this._fadeTime + this._maxAlphaTime;
   if(this._expireParticles)
   {
      this.advanceParticles(0,0);
   }
};
p.addProperty("maxAlphaTime",p.getMaxAlphaTime,p.setMaxAlphaTime);
p.getFadeTime = function()
{
   return this._fadeTime;
};
p.setFadeTime = function(arg)
{
   this._fadeTime = arg;
   this._lifetime = 2 * this._fadeTime + this._maxAlphaTime;
   if(this._expireParticles)
   {
      this.advanceParticles(0,0);
   }
};
p.addProperty("fadeTime",p.getFadeTime,p.setFadeTime);
p.getLinkageName = function()
{
   return this._linkageName;
};
p.setLinkageName = function(arg)
{
   this._linkageName = arg;
};
p.addProperty("linkageName",p.getLinkageName,p.setLinkageName);
p.getMass = function()
{
   return this._mass;
};
p.setMass = function(arg)
{
   this._mass = arg;
   this.calculateSpeeds();
};
p.addProperty("mass",p.getMass,p.setMass);
p.getNumberOfParticles = function()
{
   return this.particlesList.length;
};
p.setNumberOfParticles = function(arg)
{
   var pL = this.particlesList;
   var change = arg - pL.length;
   if(change > 0)
   {
      var mcShortage = change - this.freeParticleMCsList.length;
      if(mcShortage > 0)
      {
         var newMCsList = [];
         var i = 0;
         while(i < mcShortage)
         {
            var depth = this._parent.STARTDEPTH + this._depthOffset - this.particleMCsTotal++ * this._parent.MAXGASSES;
            newMCsList.push(this.particlesMC.attachMovie(this._linkageName,"_" + depth,depth,this.initObject));
            i++;
         }
         newMCsList.reverse();
         this.freeParticleMCsList = newMCsList.concat(this.freeParticleMCsList);
      }
      var iL = [];
      var fL = this.freeParticleMCsList;
      var i = 0;
      while(i < change)
      {
         var p = {};
         p.mc = fL.pop();
         p.mc._visible = true;
         pL.push(p);
         iL.push(p);
         i++;
      }
      this.initializeParticles(iL,false);
   }
   else if(change < 0)
   {
      change *= -1;
      var fL = this.freeParticleMCsList;
      var i = 0;
      while(i < change)
      {
         var p = pL[pL.length - 1 - i];
         p.mc._visible = false;
         fL.push(p.mc);
         i++;
      }
      pL.splice(pL.length - change,change);
   }
};
p.addProperty("numberOfParticles",p.getNumberOfParticles,p.setNumberOfParticles);
