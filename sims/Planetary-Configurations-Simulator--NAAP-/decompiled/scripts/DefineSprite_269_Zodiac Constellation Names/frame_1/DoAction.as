namesList = ["leo","cancer","gemini","taurus","aries","pisces","aquarius","capricornus","sagittarius","scorpius","libra","virgo"];
var i = 0;
while(i < namesList.length)
{
   this[namesList[i] + "NameMC"]._visible = false;
   i++;
}
