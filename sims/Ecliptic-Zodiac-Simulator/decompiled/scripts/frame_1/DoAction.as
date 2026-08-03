function changeDay(arg)
{
   zodiac.setDayOfYear(arg);
}
function changeRotAngle(arg)
{
   zodiac.setRotationAngle(arg);
}
zodiac.onDayChanged = function(arg)
{
   dayOfYearSlider.value = arg;
};
