function playpause(playStatus)
{
   horizonMC.setAnimate(playStatus);
}
radio_0.color = 16777215;
radio_1.color = 16777215;
form = new Object();
form.click = function(eventObj)
{
   var _loc1_ = Number(eventObj.target.selection._name.split("_")[1]);
   horizonMC.setType(_loc1_);
};
radioGroup.addEventListener("click",form);
