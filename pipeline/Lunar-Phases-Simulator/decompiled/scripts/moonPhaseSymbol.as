function moonPhaseClass()
{
   this._SYNODIC = 29.5;
   this._MARGIN = 10;
   this._RADIUS = 100;
   this._N = 5;
   this._term_aP = new Array();
   this._term_cP = new Array();
   var _loc7_ = 3.141592653589793 / (this._N - 1);
   var _loc8_ = 1 / Math.cos(_loc7_ / 2);
   var _loc2_ = 0;
   var _loc4_;
   var _loc6_;
   var _loc3_;
   var _loc5_;
   while(_loc2_ < this._N)
   {
      _loc4_ = new Object();
      _loc6_ = _loc2_ * _loc7_;
      _loc4_.x = this._RADIUS * Math.sin(_loc6_);
      _loc4_.y = this._RADIUS * Math.cos(_loc6_);
      this._term_aP[_loc2_] = _loc4_;
      if(_loc2_ != 0)
      {
         _loc3_ = new Object();
         _loc5_ = _loc7_ / 2 + (_loc2_ - 1) * _loc7_;
         _loc3_.x = this._RADIUS * _loc8_ * Math.sin(_loc5_);
         _loc3_.y = this._RADIUS * _loc8_ * Math.cos(_loc5_);
         this._term_cP[_loc2_] = _loc3_;
      }
      else
      {
         this._term_cP[0] = null;
      }
      _loc2_ = _loc2_ + 1;
   }
   this.attachMovie("moonPhaseImage","_moon_mc",1);
   this.createEmptyMovieClip("_mask_mc",2);
   this.attachMovie("Moon Diagram Landmark","lunarLandmarkMC",17);
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
   var _loc9_ = 1;
   if(this._phase < 3.141592653589793)
   {
      _loc9_ = -1;
   }
   var _loc8_ = this._RADIUS + this._MARGIN;
   this._mask_mc.clear();
   this._mask_mc.moveTo(0,this._RADIUS);
   this._mask_mc.beginFill(0,this._dark_alpha);
   this._mask_mc.lineTo(0,_loc8_);
   this._mask_mc.lineTo(_loc9_ * _loc8_,_loc8_);
   this._mask_mc.lineTo(_loc9_ * _loc8_,- _loc8_);
   this._mask_mc.lineTo(0,- _loc8_);
   this._mask_mc.lineTo(0,- this._RADIUS);
   var _loc7_ = Math.cos(this.mod(this._phase,3.141592653589793));
   var _loc2_ = 0;
   var _loc4_;
   var _loc3_;
   var _loc6_;
   var _loc5_;
   while(_loc2_ < this._N)
   {
      _loc4_ = this._term_cP[_loc2_].x * _loc7_;
      _loc3_ = - this._term_cP[_loc2_].y;
      _loc6_ = this._term_aP[_loc2_].x * _loc7_;
      _loc5_ = - this._term_aP[_loc2_].y;
      this._mask_mc.curveTo(_loc4_,_loc3_,_loc6_,_loc5_);
      _loc2_ = _loc2_ + 1;
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
   var _loc2_ = parseFloat(arg2);
   if(!isFinite(_loc2_))
   {
      return false;
   }
   if(this.stringCompare(arg1,"period"))
   {
      if(_loc2_ == 0)
      {
         return false;
      }
      this._speed = this._SYNODIC / (1000 * _loc2_);
      return true;
   }
   if(this.stringCompare(arg1,"rate"))
   {
      this._speed = _loc2_ / 1000;
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
   var _loc2_ = this.getAngleFromName(arg1);
   if(_loc2_ == Math.NaN)
   {
      _loc2_ = Number(arg1);
      if(!isFinite(_loc2_))
      {
         return false;
      }
   }
   this._phase = this.mod(_loc2_,360) * 0.017453292519943295;
   this.updateMask();
   return true;
};
p.animateTo = function(arg1)
{
   var _loc2_ = this.getAngleFromName(arg1);
   if(_loc2_ == Math.NaN)
   {
      _loc2_ = Number(arg1);
      if(!isFinite(_loc2_))
      {
         return false;
      }
   }
   this._stop_at = this.mod(_loc2_,360) * 0.017453292519943295;
   this._animating = true;
   return true;
};
p.animateFor = function()
{
   var _loc3_ = Math.abs(parseFloat(arguments[0]));
   if(!isFinite(_loc3_))
   {
      return false;
   }
   this._stop_at = this.mod(this._phase + _loc3_ * (360 / this._SYNODIC) * 0.017453292519943295,6.283185307179586);
   this._animating = true;
   return true;
};
p.getNameFromAngle = function(angle)
{
   var _loc2_ = parseFloat(angle);
   if(!isFinite(_loc2_))
   {
      return "<invalid phase>";
   }
   _loc2_ = this.mod(_loc2_,360);
   var _loc3_ = this._phase_tol;
   if(_loc2_ <= _loc3_)
   {
      return "New Moon";
   }
   if(_loc2_ < 90 - _loc3_)
   {
      return "Waxing Crescent";
   }
   if(_loc2_ <= 90 + _loc3_)
   {
      return "First Quarter";
   }
   if(_loc2_ < 180 - _loc3_)
   {
      return "Waxing Gibbous";
   }
   if(_loc2_ <= 180 + _loc3_)
   {
      return "Full Moon";
   }
   if(_loc2_ < 270 - _loc3_)
   {
      return "Waning Gibbous";
   }
   if(_loc2_ <= 270 + _loc3_)
   {
      return "Third Quarter";
   }
   if(_loc2_ < 360 - _loc3_)
   {
      return "Waning Crescent";
   }
   if(_loc2_ <= 360)
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
   var _loc2_ = str1.toLowerCase();
   var _loc1_ = str2.toLowerCase();
   if(_loc2_ == _loc1_)
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
   var _loc5_ = getTimer();
   var _loc6_;
   var _loc7_;
   var _loc2_;
   var _loc3_;
   var _loc4_;
   if(this._animating)
   {
      _loc6_ = this._speed * (_loc5_ - this._time_last);
      _loc7_ = _loc6_ * (360 / this._SYNODIC) * 0.017453292519943295;
      _loc2_ = this._phase;
      _loc3_ = _loc2_ + _loc7_;
      this._phase = this.mod(_loc3_,6.283185307179586);
      _loc4_ = false;
      if(_loc3_ != this._phase)
      {
         _loc4_ = true;
      }
      if(this._stop_at != null)
      {
         if(_loc4_ == false)
         {
            if(this._stop_at > _loc2_ && this._stop_at <= this._phase || this._stop_at < _loc2_ && this._stop_at >= this._phase)
            {
               this._phase = this._stop_at;
               this._animating = false;
               this._stop_at = null;
            }
         }
         else if(this._stop_at < _loc2_ && this._stop_at <= this._phase || this._stop_at > _loc2_ && this._stop_at >= this._phase)
         {
            this._phase = this._stop_at;
            this._animating = false;
            this._stop_at = null;
         }
      }
      this.updateMask();
   }
   this._time_last = _loc5_;
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
   var _loc3_ = Math.abs(parseFloat(arguments[0]));
   if(!isFinite(_loc3_))
   {
      return undefined;
   }
   this._phase_tol = _loc3_ * 360 / (this._SYNODIC * 24);
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
   var _loc2_ = Number(arg);
   if(isFinite(_loc2_))
   {
      this._dark_alpha = _loc2_;
      this.updateMask();
   }
};
p.addProperty("animating",p.getAnimating,null);
p.addProperty("phaseNameTolerance",p.getPhaseTolerance,p.setPhaseTolerance);
p.addProperty("darkAlpha",p.getDarkAlpha,p.setDarkAlpha);
