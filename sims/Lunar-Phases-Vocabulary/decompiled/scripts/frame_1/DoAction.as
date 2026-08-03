var run_time;
var start_time;
var elapsed_time;
myMoon.setSpeed("period",29.5);
myMoon.darkAlpha = 60;
myMoon.stopAnimation();
RunAnimationButton._visible = true;
StopAnimationButton._visible = false;
runtime.text = "";
_root.onEnterFrame = function()
{
   if(myMoon.animating)
   {
      current_time = getTimer();
      elapsed_time = (current_time - start_time) / 1000;
      days = Math.round(elapsed_time * 10) / 10;
      temp = days + " days";
      place = temp.indexof(".");
      if(place == -1)
      {
         i = temp.split(" ");
         i[0] += ".0 ";
         temp = i[0] + i[1];
      }
      run_time.text = temp;
   }
};
RunAnimationButton.onRelease = function()
{
   start_time = getTimer();
   myMoon.startAnimation();
   RunAnimationButton._visible = false;
   StopAnimationButton._visible = true;
};
StopAnimationButton.onRelease = function()
{
   myMoon.stopAnimation();
   RunAnimationButton._visible = true;
   StopAnimationButton._visible = false;
};
NewMoonButton.onRelease = function()
{
   myMoon.setPhase("new moon");
   start_time = getTimer();
   run_time.text = "";
};
WaxingCrescentButton.onRelease = function()
{
   myMoon.setPhase("waxing crescent");
   start_time = getTimer();
   run_time.text = "";
};
FirstQuarterButton.onRelease = function()
{
   myMoon.setPhase("first quarter");
   start_time = getTimer();
   run_time.text = "";
};
WaxingGibbousButton.onRelease = function()
{
   myMoon.setPhase("waxing gibbous");
   start_time = getTimer();
   run_time.text = "";
};
FullMoonButton.onRelease = function()
{
   myMoon.setPhase("full moon");
   start_time = getTimer();
   run_time.text = "";
};
WaningGibbousButton.onRelease = function()
{
   myMoon.setPhase("waning gibbous");
   start_time = getTimer();
   run_time.text = "";
};
LastQuarterButton.onRelease = function()
{
   myMoon.setPhase("last quarter");
   start_time = getTimer();
   run_time.text = "";
};
WaningCrescentButton.onRelease = function()
{
   myMoon.setPhase("waning crescent");
   start_time = getTimer();
   run_time.text = "";
};
stop();
