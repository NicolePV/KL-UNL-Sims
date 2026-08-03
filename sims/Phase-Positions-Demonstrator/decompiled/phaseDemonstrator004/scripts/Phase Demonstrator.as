function PhaseDemonstratorClass()
{
   this.activeAreaMC.createEmptyMovieClip("orbit1MC",1);
   this.activeAreaMC.createEmptyMovieClip("orbit2MC",2);
   this.activeAreaMC.attachMovie("Draggable Planet","planet1MC",3,{labelText:"1",id:1,state:0,discColor:16748688,_x:100,_y:-160});
   this.activeAreaMC.attachMovie("Draggable Planet","planet2MC",4,{labelText:"2",id:2,state:0,discColor:9474303,_x:120,_y:-40});
   var p1 = this.activeAreaMC.planet1MC;
   p1.orbitRadius = Math.sqrt(p1._x * p1._x + p1._y * p1._y);
   var p2 = this.activeAreaMC.planet2MC;
   p2.orbitRadius = Math.sqrt(p2._x * p2._x + p2._y * p2._y);
   this.xDragLimit = this.activeAreaMC._width / 2 - this.activeAreaMC.planet1MC.discRadius - this.dragMargin;
   this.yDragLimit = this.activeAreaMC._height / 2 - this.activeAreaMC.planet1MC.discRadius - this.dragMargin;
}
var p = PhaseDemonstratorClass.prototype = new MovieClip();
Object.registerClass("Phase Demonstrator",PhaseDemonstratorClass);
p.moonDistance = 30;
p.moonSnappingDistance = 42;
p.sunSeparation = 50;
p.dragMargin = 20;
p.setPlanetPosition = function(id, x, y)
{
   var thisPlanetMC = this.activeAreaMC["planet" + id + "MC"];
   if(id == 1)
   {
      var otherPlanetMC = this.activeAreaMC.planet2MC;
   }
   else
   {
      var otherPlanetMC = this.activeAreaMC.planet1MC;
   }
   if(Key.isDown(16) && thisPlanetMC.state >= 0)
   {
      var angle = Math.atan2(y,x);
      x = thisPlanetMC.orbitRadius * Math.cos(angle);
      y = thisPlanetMC.orbitRadius * Math.sin(angle);
   }
   var wasOutOfBounds = false;
   if(x < - this.xDragLimit)
   {
      x = - this.xDragLimit;
      wasOutOfBounds = true;
   }
   else if(x > this.xDragLimit)
   {
      x = this.xDragLimit;
      wasOutOfBounds = true;
   }
   if(y < - this.yDragLimit)
   {
      y = - this.yDragLimit;
      wasOutOfBounds = true;
   }
   else if(y > this.yDragLimit)
   {
      y = this.yDragLimit;
      wasOutOfBounds = true;
   }
   var sunDistance = Math.sqrt(x * x + y * y);
   if(sunDistance < this.sunSeparation)
   {
      var angle = Math.atan2(y,x);
      x = this.sunSeparation * Math.cos(angle);
      y = this.sunSeparation * Math.sin(angle);
   }
   var dx = x - otherPlanetMC._x;
   var dy = y - otherPlanetMC._y;
   if(thisPlanetMC.state == 1)
   {
      var angle = Math.atan2(- dy,- dx);
      otherPlanetMC._x = x + this.moonDistance * Math.cos(angle);
      otherPlanetMC._y = y + this.moonDistance * Math.sin(angle);
   }
   else
   {
      var planetDistance = Math.sqrt(dx * dx + dy * dy);
      if(planetDistance < this.moonSnappingDistance || Key.isDown(16) && thisPlanetMC.state == -1)
      {
         var angle = Math.atan2(dy,dx);
         x = otherPlanetMC._x + this.moonDistance * Math.cos(angle);
         y = otherPlanetMC._y + this.moonDistance * Math.sin(angle);
         thisPlanetMC.state = -1;
         otherPlanetMC.state = 1;
      }
      else
      {
         thisPlanetMC.state = 0;
         otherPlanetMC.state = 0;
      }
   }
   thisPlanetMC._x = x;
   thisPlanetMC._y = y;
   if((!Key.isDown(16) || wasOutOfBounds) && thisPlanetMC.state >= 0)
   {
      thisPlanetMC.orbitRadius = Math.sqrt(x * x + y * y);
   }
   this.updatePhases();
   this.updateOrbits();
};
p.updatePhases = function()
{
   var x1 = this.activeAreaMC.planet1MC._x;
   var y1 = this.activeAreaMC.planet1MC._y;
   var x2 = this.activeAreaMC.planet2MC._x;
   var y2 = this.activeAreaMC.planet2MC._y;
   var r1 = Math.sqrt(x1 * x1 + y1 * y1);
   var r2 = Math.sqrt(x2 * x2 + y2 * y2);
   var angle1 = Math.atan2(y1,x1);
   var angle2 = Math.atan2(y2,x2);
   var theta = 6.283185307179586 * (((angle1 - angle2) / 6.283185307179586 % 1 + 1) % 1);
   var cosTheta = Math.cos(theta);
   var d = Math.sqrt(r1 * r1 + r2 * r2 - 2 * r1 * r2 * cosTheta);
   var cosBeta1 = (r1 - r2 * cosTheta) / d;
   if(cosBeta1 > 1)
   {
      cosBeta1 = 1;
   }
   else if(cosBeta1 < -1)
   {
      cosBeta1 = -1;
   }
   var beta1 = Math.acos(cosBeta1);
   var cosBeta2 = (r2 - r1 * cosTheta) / d;
   if(cosBeta2 > 1)
   {
      cosBeta2 = 1;
   }
   else if(cosBeta2 < -1)
   {
      cosBeta2 = -1;
   }
   var beta2 = Math.acos(cosBeta2);
   if(theta < 3.141592653589793)
   {
      var angle1 = beta1;
      var angle2 = 6.283185307179586 - beta2;
   }
   else
   {
      var angle1 = 6.283185307179586 - beta1;
      var angle2 = beta2;
   }
   this.phasePanel1MC.setPhaseAngle(angle1);
   this.phasePanel2MC.setPhaseAngle(angle2);
   var labelAngle2 = Math.atan2(y2 - y1,x2 - x1);
   this.activeAreaMC.planet1MC.setLabelAngle(labelAngle2 + 3.141592653589793);
   this.activeAreaMC.planet2MC.setLabelAngle(labelAngle2);
};
p.updateOrbits = function()
{
   this.activeAreaMC.orbit1MC.clear();
   this.activeAreaMC.orbit2MC.clear();
   if(!this.showOrbitsCheck.getValue())
   {
      return undefined;
   }
   var omc = this.activeAreaMC.orbit1MC;
   var pmc = this.activeAreaMC.planet1MC;
   var opmc = this.activeAreaMC.planet2MC;
   omc.lineStyle(1,16752800);
   if(pmc.state < 0)
   {
      this.drawCircle(omc,opmc._x,opmc._y,this.moonDistance);
   }
   else
   {
      var r = Math.sqrt(pmc._x * pmc._x + pmc._y * pmc._y);
      this.drawCircle(omc,0,0,r);
   }
   var omc = this.activeAreaMC.orbit2MC;
   var pmc = this.activeAreaMC.planet2MC;
   var opmc = this.activeAreaMC.planet1MC;
   omc.clear();
   omc.lineStyle(1,9211315);
   if(pmc.state < 0)
   {
      this.drawCircle(omc,opmc._x,opmc._y,this.moonDistance);
   }
   else
   {
      var r = Math.sqrt(pmc._x * pmc._x + pmc._y * pmc._y);
      this.drawCircle(omc,0,0,r);
   }
};
p.drawCircle = function(mc, x, y, r)
{
   mc.moveTo(x + r,y);
   mc.curveTo(x + r,y - 0.4142 * r,x + 0.7071 * r,y - 0.7071 * r);
   mc.curveTo(x + 0.4142 * r,y - r,x,y - r);
   mc.curveTo(x - 0.4142 * r,y - r,x - 0.7071 * r,y - 0.7071 * r);
   mc.curveTo(x - r,y - 0.4142 * r,x - r,y);
   mc.curveTo(x - r,y + 0.4142 * r,x - 0.7071 * r,y + 0.7071 * r);
   mc.curveTo(x - 0.4142 * r,y + r,x,y + r);
   mc.curveTo(x + 0.4142 * r,y + r,x + 0.7071 * r,y + 0.7071 * r);
   mc.curveTo(x + r,y + 0.4142 * r,x + r,y);
};
