function moonPhaseClass()
{
   this._SYNODIC = 29.5;
   this._MARGIN = 10;
   this._RADIUS = 101;
   this._N = 5;
   this._term_aP = new Array();
   this._term_cP = new Array();
   var step = 3.141592653589793 / (this._N - 1);
   var a_dist = 1 / Math.cos(step / 2);
   var i = 0;
   while(i < this._N)
   {
      var obj = new Object();
      var angle = i * step;
      obj.x = this._RADIUS * Math.sin(angle);
      obj.y = this._RADIUS * Math.cos(angle);
      this._term_aP[i] = obj;
      if(i != 0)
      {
         var obj2 = new Object();
         var angle2 = step / 2 + (i - 1) * step;
         obj2.x = this._RADIUS * a_dist * Math.sin(angle2);
         obj2.y = this._RADIUS * a_dist * Math.cos(angle2);
         this._term_cP[i] = obj2;
      }
      else
      {
         this._term_cP[0] = null;
      }
      i++;
   }
   this.attachMovie("moonPhaseImage","_moon_mc",1);
   this.createEmptyMovieClip("_mask_mc",2);
   this.setDarkAlpha(70);
   this._phase = 0;
   this.setPhase(this.init_phase);
   this._phase_tol;
   this.setPhaseTolerance(12);
   this._animating = Boolean(this.init_anim);
   this._stop_at = null;
   this._time_last = getTimer();
   this._speed;
   this.setSpeed("period",this.init_period);
   this.updateMask();
}
var p = moonPhaseClass.prototype = new MovieClip();
Object.registerClass("moonPhaseSymbol",moonPhaseClass);
p.updateMask = function()
{
   this._phase = this.mod(this._phase,6.283185307179586);
   var box_direction = 1;
   if(this._phase < 3.141592653589793)
   {
      box_direction = -1;
   }
   var box_side = this._RADIUS + this._MARGIN;
   this._mask_mc.clear();
   this._mask_mc.moveTo(0,this._RADIUS);
   this._mask_mc.beginFill(0,this._dark_alpha);
   this._mask_mc.lineTo(0,box_side);
   this._mask_mc.lineTo(box_direction * box_side,box_side);
   this._mask_mc.lineTo(box_direction * box_side,- box_side);
   this._mask_mc.lineTo(0,- box_side);
   this._mask_mc.lineTo(0,- this._RADIUS);
   var cos_phase = Math.cos(this.mod(this._phase,3.141592653589793));
   var i = 0;
   while(i < this._N)
   {
      var cx = this._term_cP[i].x * cos_phase;
      var cy = - this._term_cP[i].y;
      var ax = this._term_aP[i].x * cos_phase;
      var ay = - this._term_aP[i].y;
      this._mask_mc.curveTo(cx,cy,ax,ay);
      i++;
   }
   this._mask_mc.endFill();
};
p.getSpeed = function(arg1)
{
   if(this.stringCompare(arg1,"period"))
   {
      return this._SYNODIC / (1000 * this._speed);
   }
   return this._speed * 1000;
};
p.setSpeed = function(arg1, arg2)
{
   var tmp = parseFloat(arg2);
   if(!isFinite(tmp))
   {
      return false;
   }
   if(this.stringCompare(arg1,"period"))
   {
      if(tmp == 0)
      {
         return false;
      }
      this._speed = this._SYNODIC / (1000 * tmp);
      return true;
   }
   if(this.stringCompare(arg1,"rate"))
   {
      this._speed = tmp / 1000;
      return true;
   }
   return false;
};
p.startAnimation = function()
{
   this._stop_at = null;
   this._animating = true;
};
p.stopAnimation = function()
{
   this._stop_at = null;
   this._animating = false;
};
p.getPhase = function()
{
   return this._phase * 57.29577951308232;
};
p.getPhaseAsName = function()
{
   return this.getNameFromAngle(this.getPhase());
};
p.setPhase = function(arg1)
{
   var tmp = this.getAngleFromName(arg1);
   if(tmp == Math.NaN)
   {
      tmp = Number(arg1);
      if(!isFinite(tmp))
      {
         return false;
      }
   }
   this._phase = this.mod(tmp,360) * 0.017453292519943295;
   this.updateMask();
   return true;
};
p.animateTo = function(arg1)
{
   var tmp = this.getAngleFromName(arg1);
   if(tmp == Math.NaN)
   {
      tmp = Number(arg1);
      if(!isFinite(tmp))
      {
         return false;
      }
   }
   this._stop_at = this.mod(tmp,360) * 0.017453292519943295;
   this._animating = true;
   return true;
};
p.animateFor = function()
{
   var arg1 = Math.abs(parseFloat(arguments[0]));
   if(!isFinite(arg1))
   {
      return false;
   }
   this._stop_at = this.mod(this._phase + arg1 * (360 / this._SYNODIC) * 0.017453292519943295,6.283185307179586);
   this._animating = true;
   return true;
};
p.getNameFromAngle = function(angle)
{
   var tmp = parseFloat(angle);
   if(!isFinite(tmp))
   {
      return "<invalid phase>";
   }
   tmp = this.mod(tmp,360);
   var tol = this._phase_tol;
   if(tmp <= tol)
   {
      return "New Moon";
   }
   if(tmp < 90 - tol)
   {
      return "Waxing Crescent";
   }
   if(tmp <= 90 + tol)
   {
      return "First Quarter";
   }
   if(tmp < 180 - tol)
   {
      return "Waxing Gibbous";
   }
   if(tmp <= 180 + tol)
   {
      return "Full Moon";
   }
   if(tmp < 270 - tol)
   {
      return "Waning Gibbous";
   }
   if(tmp <= 270 + tol)
   {
      return "Third Quarter";
   }
   if(tmp < 360 - tol)
   {
      return "Waning Crescent";
   }
   if(tmp <= 360)
   {
      return "New Moon";
   }
   return "<invalid phase>";
};
p.getAngleFromName = function(name)
{
   if(this.stringCompare(name,"new") || this.stringCompare(name,"new moon"))
   {
      return 0;
   }
   if(this.stringCompare(name,"waxing crescent"))
   {
      return 45;
   }
   if(this.stringCompare(name,"first quarter"))
   {
      return 90;
   }
   if(this.stringCompare(name,"waxing gibbous"))
   {
      return 135;
   }
   if(this.stringCompare(name,"full") || this.stringCompare(name,"full moon"))
   {
      return 180;
   }
   if(this.stringCompare(name,"waning gibbous"))
   {
      return 225;
   }
   if(this.stringCompare(name,"third quarter") || this.stringCompare(name,"last quarter"))
   {
      return 270;
   }
   if(this.stringCompare(name,"waning crescent"))
   {
      return 315;
   }
   return Math.NaN;
};
p.stringCompare = function(str1, str2)
{
   var tmp1 = str1.toLowerCase();
   var tmp2 = str2.toLowerCase();
   if(tmp1 == tmp2)
   {
      return true;
   }
   return false;
};
p.mod = function(number, modulus)
{
   if(number < 0)
   {
      return number % modulus + modulus;
   }
   return number % modulus;
};
p.onEnterFrame = function()
{
   var time_now = getTimer();
   if(this._animating)
   {
      var dt = this._speed * (time_now - this._time_last);
      var da = dt * (360 / this._SYNODIC) * 0.017453292519943295;
      var old_phase = this._phase;
      var mid_step = old_phase + da;
      this._phase = this.mod(mid_step,6.283185307179586);
      var wrapped = false;
      if(mid_step != this._phase)
      {
         wrapped = true;
      }
      if(this._stop_at != null)
      {
         if(wrapped == false)
         {
            if(this._stop_at > old_phase && this._stop_at <= this._phase || this._stop_at < old_phase && this._stop_at >= this._phase)
            {
               this._phase = this._stop_at;
               this._animating = false;
               this._stop_at = null;
            }
         }
         else if(this._stop_at < old_phase && this._stop_at <= this._phase || this._stop_at > old_phase && this._stop_at >= this._phase)
         {
            this._phase = this._stop_at;
            this._animating = false;
            this._stop_at = null;
         }
      }
      this.updateMask();
   }
   this._time_last = time_now;
};
p.getAnimating = function()
{
   return this._animating;
};
p.getPhaseTolerance = function()
{
   return this._phase_tol * this._SYNODIC * 24 / 360;
};
p.setPhaseTolerance = function()
{
   var arg = Math.abs(parseFloat(arguments[0]));
   if(!isFinite(arg))
   {
      return undefined;
   }
   this._phase_tol = arg * 360 / (this._SYNODIC * 24);
   if(this._phase_tol > 30)
   {
      this._phase_tol = 30;
   }
};
p.getDarkAlpha = function()
{
   return this._dark_alpha;
};
p.setDarkAlpha = function(arg)
{
   var tmp = Number(arg);
   if(isFinite(tmp))
   {
      this._dark_alpha = tmp;
      this.updateMask();
   }
};
p.addProperty("animating",p.getAnimating,null);
p.addProperty("phaseNameTolerance",p.getPhaseTolerance,p.setPhaseTolerance);
p.addProperty("darkAlpha",p.getDarkAlpha,p.setDarkAlpha);
