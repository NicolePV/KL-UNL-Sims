function PhaseDemonstratorClass()
{
   var _loc1_ = this;
   _loc1_.activeAreaMC.createEmptyMovieClip("orbit1MC",1);
   _loc1_.activeAreaMC.createEmptyMovieClip("orbit2MC",2);
   _loc1_.activeAreaMC.attachMovie("Draggable Planet","planet1MC",3,{labelText:"1",id:1,state:0,discColor:16748688,_x:100,_y:-160});
   _loc1_.activeAreaMC.attachMovie("Draggable Planet","planet2MC",4,{labelText:"2",id:2,state:0,discColor:9474303,_x:120,_y:-40});
   var _loc3_ = _loc1_.activeAreaMC.planet1MC;
   _loc3_.orbitRadius = Math.sqrt(_loc3_._x * _loc3_._x + _loc3_._y * _loc3_._y);
   var _loc2_ = _loc1_.activeAreaMC.planet2MC;
   _loc2_.orbitRadius = Math.sqrt(_loc2_._x * _loc2_._x + _loc2_._y * _loc2_._y);
   _loc1_.xDragLimit = _loc1_.activeAreaMC._width / 2 - _loc1_.activeAreaMC.planet1MC.discRadius - _loc1_.dragMargin;
   _loc1_.yDragLimit = _loc1_.activeAreaMC._height / 2 - _loc1_.activeAreaMC.planet1MC.discRadius - _loc1_.dragMargin;
}
var p = PhaseDemonstratorClass.prototype = new MovieClip();
Object.registerClass("Phase Demonstrator",PhaseDemonstratorClass);
p.moonDistance = 30;
p.moonSnappingDistance = 42;
p.sunSeparation = 50;
p.dragMargin = 20;
p.setPlanetPosition = function(id, x, y)
{
   var _loc1_ = this;
   var _loc2_ = y;
   var _loc3_ = x;
   var thisPlanetMC = _loc1_.activeAreaMC["planet" + id + "MC"];
   if(id == 1)
   {
      var otherPlanetMC = _loc1_.activeAreaMC.planet2MC;
   }
   else
   {
      var otherPlanetMC = _loc1_.activeAreaMC.planet1MC;
   }
   if(Key.isDown(16) && thisPlanetMC.state >= 0)
   {
      var angle = Math.atan2(_loc2_,_loc3_);
      _loc3_ = thisPlanetMC.orbitRadius * Math.cos(angle);
      _loc2_ = thisPlanetMC.orbitRadius * Math.sin(angle);
   }
   var wasOutOfBounds = false;
   if(_loc3_ < - _loc1_.xDragLimit)
   {
      _loc3_ = - _loc1_.xDragLimit;
      wasOutOfBounds = true;
   }
   else if(_loc3_ > _loc1_.xDragLimit)
   {
      _loc3_ = _loc1_.xDragLimit;
      wasOutOfBounds = true;
   }
   if(_loc2_ < - _loc1_.yDragLimit)
   {
      _loc2_ = - _loc1_.yDragLimit;
      wasOutOfBounds = true;
   }
   else if(_loc2_ > _loc1_.yDragLimit)
   {
      _loc2_ = _loc1_.yDragLimit;
      wasOutOfBounds = true;
   }
   var sunDistance = Math.sqrt(_loc3_ * _loc3_ + _loc2_ * _loc2_);
   if(sunDistance < _loc1_.sunSeparation)
   {
      var angle = Math.atan2(_loc2_,_loc3_);
      _loc3_ = _loc1_.sunSeparation * Math.cos(angle);
      _loc2_ = _loc1_.sunSeparation * Math.sin(angle);
   }
   var dx = _loc3_ - otherPlanetMC._x;
   var dy = _loc2_ - otherPlanetMC._y;
   if(thisPlanetMC.state == 1)
   {
      var angle = Math.atan2(- dy,- dx);
      otherPlanetMC._x = _loc3_ + _loc1_.moonDistance * Math.cos(angle);
      otherPlanetMC._y = _loc2_ + _loc1_.moonDistance * Math.sin(angle);
   }
   else
   {
      var planetDistance = Math.sqrt(dx * dx + dy * dy);
      if(planetDistance < _loc1_.moonSnappingDistance || Key.isDown(16) && thisPlanetMC.state == -1)
      {
         var angle = Math.atan2(dy,dx);
         _loc3_ = otherPlanetMC._x + _loc1_.moonDistance * Math.cos(angle);
         _loc2_ = otherPlanetMC._y + _loc1_.moonDistance * Math.sin(angle);
         thisPlanetMC.state = -1;
         otherPlanetMC.state = 1;
      }
      else
      {
         thisPlanetMC.state = 0;
         otherPlanetMC.state = 0;
      }
   }
   thisPlanetMC._x = _loc3_;
   thisPlanetMC._y = _loc2_;
   if((!Key.isDown(16) || wasOutOfBounds) && thisPlanetMC.state >= 0)
   {
      thisPlanetMC.orbitRadius = Math.sqrt(_loc3_ * _loc3_ + _loc2_ * _loc2_);
   }
   _loc1_.updatePhases();
   _loc1_.updateOrbits();
   _loc1_.updatePanelTitles();
};
p.updatePanelTitles = function()
{
   var _loc1_ = this;
   var _loc3_ = _loc1_.activeAreaMC.planet1MC.state >= 0 ? "planet 1" : "moon 1";
   var _loc2_ = _loc1_.activeAreaMC.planet2MC.state >= 0 ? "planet 2" : "moon 2";
   _loc1_.phasePanel1MC.title = _loc3_ + " as seen from " + _loc2_;
   _loc1_.phasePanel2MC.title = _loc2_ + " as seen from " + _loc3_;
};
p.updatePhases = function()
{
   var _loc1_ = this;
   var x1 = _loc1_.activeAreaMC.planet1MC._x;
   var y1 = _loc1_.activeAreaMC.planet1MC._y;
   var x2 = _loc1_.activeAreaMC.planet2MC._x;
   var y2 = _loc1_.activeAreaMC.planet2MC._y;
   var _loc3_ = Math.sqrt(x1 * x1 + y1 * y1);
   var _loc2_ = Math.sqrt(x2 * x2 + y2 * y2);
   var angle1 = Math.atan2(y1,x1);
   var angle2 = Math.atan2(y2,x2);
   var theta = 6.283185307179586 * (((angle1 - angle2) / 6.283185307179586 % 1 + 1) % 1);
   var cosTheta = Math.cos(theta);
   var d = Math.sqrt(_loc3_ * _loc3_ + _loc2_ * _loc2_ - 2 * _loc3_ * _loc2_ * cosTheta);
   var cosBeta1 = (_loc3_ - _loc2_ * cosTheta) / d;
   if(cosBeta1 > 1)
   {
      cosBeta1 = 1;
   }
   else if(cosBeta1 < -1)
   {
      cosBeta1 = -1;
   }
   var beta1 = Math.acos(cosBeta1);
   var cosBeta2 = (_loc2_ - _loc3_ * cosTheta) / d;
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
   _loc1_.phasePanel1MC.setPhaseAngle(angle1);
   _loc1_.phasePanel2MC.setPhaseAngle(angle2);
   var labelAngle2 = Math.atan2(y2 - y1,x2 - x1);
   _loc1_.activeAreaMC.planet1MC.setLabelAngle(labelAngle2 + 3.141592653589793);
   _loc1_.activeAreaMC.planet2MC.setLabelAngle(labelAngle2);
};
p.updateOrbits = function()
{
   var _loc1_ = this;
   _loc1_.activeAreaMC.orbit1MC.clear();
   _loc1_.activeAreaMC.orbit2MC.clear();
   var _loc3_;
   var _loc2_;
   if(_loc1_.showOrbitsCheck.getValue())
   {
      _loc3_ = _loc1_.activeAreaMC.orbit1MC;
      _loc2_ = _loc1_.activeAreaMC.planet1MC;
      var opmc = _loc1_.activeAreaMC.planet2MC;
      _loc3_.lineStyle(1,16752800);
      if(_loc2_.state < 0)
      {
         _loc1_.drawCircle(_loc3_,opmc._x,opmc._y,_loc1_.moonDistance);
      }
      else
      {
         var r = Math.sqrt(_loc2_._x * _loc2_._x + _loc2_._y * _loc2_._y);
         _loc1_.drawCircle(_loc3_,0,0,r);
      }
      _loc3_ = _loc1_.activeAreaMC.orbit2MC;
      _loc2_ = _loc1_.activeAreaMC.planet2MC;
      var opmc = _loc1_.activeAreaMC.planet1MC;
      _loc3_.clear();
      _loc3_.lineStyle(1,9211315);
      if(_loc2_.state < 0)
      {
         _loc1_.drawCircle(_loc3_,opmc._x,opmc._y,_loc1_.moonDistance);
      }
      else
      {
         var r = Math.sqrt(_loc2_._x * _loc2_._x + _loc2_._y * _loc2_._y);
         _loc1_.drawCircle(_loc3_,0,0,r);
      }
   }
};
p.drawCircle = function(mc, x, y, r)
{
   var _loc1_ = r;
   var _loc2_ = y;
   var _loc3_ = x;
   mc.moveTo(_loc3_ + _loc1_,_loc2_);
   mc.curveTo(_loc3_ + _loc1_,_loc2_ - 0.4142 * _loc1_,_loc3_ + 0.7071 * _loc1_,_loc2_ - 0.7071 * _loc1_);
   mc.curveTo(_loc3_ + 0.4142 * _loc1_,_loc2_ - _loc1_,_loc3_,_loc2_ - _loc1_);
   mc.curveTo(_loc3_ - 0.4142 * _loc1_,_loc2_ - _loc1_,_loc3_ - 0.7071 * _loc1_,_loc2_ - 0.7071 * _loc1_);
   mc.curveTo(_loc3_ - _loc1_,_loc2_ - 0.4142 * _loc1_,_loc3_ - _loc1_,_loc2_);
   mc.curveTo(_loc3_ - _loc1_,_loc2_ + 0.4142 * _loc1_,_loc3_ - 0.7071 * _loc1_,_loc2_ + 0.7071 * _loc1_);
   mc.curveTo(_loc3_ - 0.4142 * _loc1_,_loc2_ + _loc1_,_loc3_,_loc2_ + _loc1_);
   mc.curveTo(_loc3_ + 0.4142 * _loc1_,_loc2_ + _loc1_,_loc3_ + 0.7071 * _loc1_,_loc2_ + 0.7071 * _loc1_);
   mc.curveTo(_loc3_ + _loc1_,_loc2_ + 0.4142 * _loc1_,_loc3_ + _loc1_,_loc2_);
};
