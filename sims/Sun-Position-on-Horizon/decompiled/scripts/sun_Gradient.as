function horizonClass()
{
   this._oldTime = getTimer();
   this._day = 0;
}
shadowArray = ["bush1","bush2","house","tree1","tree2","tree3","tree4"];
var monthArray = [];
monthArray.push({month:"January",days:31});
monthArray.push({month:"February",days:29});
monthArray.push({month:"March",days:31});
monthArray.push({month:"April",days:30});
monthArray.push({month:"May",days:31});
monthArray.push({month:"June",days:30});
monthArray.push({month:"July",days:31});
monthArray.push({month:"August",days:31});
monthArray.push({month:"September",days:30});
monthArray.push({month:"October",days:31});
monthArray.push({month:"November",days:30});
monthArray.push({month:"December",days:31});
dateArray = [];
var i = 0;
while(i < monthArray.length)
{
   var j = 0;
   while(j < monthArray[i].days)
   {
      dateArray.push(monthArray[i].month + " " + (j + 1));
      j++;
   }
   i++;
}
var i = 0;
while(i < 80)
{
   dateArray.push(dateArray.shift());
   i++;
}
var p = horizonClass.prototype = new MovieClip();
Object.registerClass("sun_Gradient",horizonClass);
p.getOffsetAt = function(dayNum)
{
   return Math.sin(dayNum / 365 * 360 * 3.141592653589793 / 180);
};
p.moveSunTo = function(theDay)
{
   this.mySun.date.dateTextField.text = dateArray[Math.floor(theDay)].split(" ")[0] + "\r" + dateArray[Math.floor(theDay)].split(" ")[1];
   typeNum = this._currentframe - 1;
   var offset = this.getOffsetAt(theDay);
   if(typeNum == 0)
   {
      offset *= -1;
   }
   this.mySun._x = this._range * offset;
   if(typeNum == 1)
   {
      offset *= -1;
   }
   var shadowFrame = 184 - Math.floor(offset * 91);
   shadowFrame = shadowFrame >= 0 ? shadowFrame : shadowFrame + 183;
   var i = 0;
   while(i < shadowArray.length)
   {
      var shadowName = "this." + shadowArray[i] + "_" + typeNum;
      var shadowObject = eval(shadowName);
      shadowObject.gotoAndStop(shadowFrame);
      i++;
   }
};
p.onEnterFrame = function()
{
   var _loc1_ = this;
   var _loc2_ = getTimer();
   var _loc3_;
   if(_loc1_._anim)
   {
      _loc3_ = _loc2_ - _loc1_._oldTime;
      _loc1_._day += _loc1_._speed * _loc3_;
      if(_loc1_._day > 365)
      {
         _loc1_._day -= 365;
      }
      _loc1_.moveSunTo(_loc1_._day);
   }
   _loc1_._oldTime = _loc2_;
};
p.getAnimate = function()
{
   return this._anim;
};
p.setAnimate = function(arg)
{
   var _loc1_ = this;
   _loc1_._anim = Boolean(arg);
   if(_loc1_._anim)
   {
      _loc1_._parent.playpause.gotoAndStop(2);
   }
   else
   {
      _loc1_._parent.playpause.gotoAndStop(1);
   }
};
p.setDay = function(arg)
{
   this._day = arg;
};
p.setType = function(arg)
{
   var _loc1_ = this;
   var _loc3_ = arg;
   var _loc2_ = _loc3_ != 0 ? "sunset" : "sunrise";
   _loc1_.descTextField.text = "Position of the sun on the horizon at " + _loc2_;
   _loc1_.mySun.gotoAndStop(_loc3_ + 1);
   _loc1_.gotoAndStop(_loc3_ + 1);
   _loc1_.moveSunTo(_loc1_._day);
};
p.addProperty("animate",p.getAnimate,p.setAnimate);
