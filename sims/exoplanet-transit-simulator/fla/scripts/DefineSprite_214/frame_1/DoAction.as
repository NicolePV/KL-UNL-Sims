getLuminosityFromMass = function(mass)
{
   if(mass < 0.43)
   {
      return 0.232220431737728 * Math.pow(mass,2.26);
   }
   return Math.pow(mass,3.99);
};
getTempFromLuminosity = function(lum)
{
   var logL = Math.log(lum) / 2.302585092994046;
   if(logL < -1.61)
   {
      var a = 3.76424847491303;
      var b = 0.140316436337353;
      var c = 0.0139709648834783;
      var d = 0.00146257952166353;
      var e = 0.000114203991057792;
      var f = 0.00000534009520193973;
      var g = 1.00897501873505e-7;
   }
   else if(logL < 0.22)
   {
      var a = 3.76404749064937;
      var b = 0.139720836051662;
      var c = 0.0131949471107482;
      var d = 0.000878016217920958;
      var e = -0.00016087678534046;
      var f = -0.0000718923778642037;
      var g = -0.0000098430921759891;
   }
   else if(logL < 1.48)
   {
      var a = 3.76404935999916;
      var b = 0.139700505514371;
      var c = 0.0132834512392025;
      var d = 0.000681148684168764;
      var e = 0.0000515647954029831;
      var f = -0.000230931527900807;
      var g = 0.0000134429776870977;
   }
   else if(logL < 2.61)
   {
      var a = 3.76208682178285;
      var b = 0.14541668375348;
      var c = 0.00684584757963743;
      var d = 0.00396076543835346;
      var e = -0.000464655201610208;
      var f = -0.000381007438333072;
      var g = 0.0000623586254118745;
   }
   else if(logL < 3.62)
   {
      var a = 3.7785507438146;
      var b = 0.129897095940252;
      var c = 0.00142810707728862;
      var d = 0.0167045399494531;
      var e = -0.00693250229182094;
      var f = 0.00103845665508301;
      var g = -0.000055992055857869;
   }
   else if(logL < 5.43)
   {
      var a = 3.94943146036608;
      var b = -0.154281251321452;
      var c = 0.1979230342627;
      var d = -0.055596100619304;
      var e = 0.00799539610207913;
      var f = -0.000600846748510063;
      var g = 0.0000187770530697032;
   }
   else
   {
      var a = 4.36797099518548;
      var b = -0.314871178456464;
      var c = 0.143399968097621;
      var d = -0.0130740129137381;
      var e = -0.00159255369850374;
      var f = 0.000357973227398207;
      var g = -0.000017804556980593;
   }
   var logT = a + logL * (b + logL * (c + logL * (d + logL * (e + logL * (f + logL * g)))));
   return Math.pow(10,logT);
};
getRadiusFromTempAndLuminosity = function(temp, luminosity)
{
   return 33736108.2311059 * Math.sqrt(luminosity) / (temp * temp);
};
getSpectralTypeFromTemp = function(temp, §class§)
{
   var §class§ = eval("class").toLowerCase();
   if(eval("class") == undefined || eval("class") == "")
   {
      set("class","v");
   }
   var aIndex = eval("class").indexOf("a");
   if(aIndex > 0)
   {
      set("class",eval("class").slice(0,aIndex));
   }
   var bIndex = eval("class").indexOf("b");
   if(bIndex > 0)
   {
      set("class",eval("class").slice(0,bIndex));
   }
   if(eval("class") == "iv")
   {
      set("class","v");
   }
   else if(eval("class") == "ii")
   {
      set("class","i");
   }
   else if(eval("class") == "iii" && temp > 6000)
   {
      set("class","v");
   }
   var typesArray = this.spectralTypesAndTemps[eval("class")];
   if(typesArray == undefined)
   {
      return null;
   }
   var spectralType = {};
   spectralType["class"] = eval("class").toUpperCase();
   var len = typesArray.length;
   var i = 0;
   while(i < len)
   {
      if(temp > typesArray[i].teff)
      {
         break;
      }
      i++;
   }
   if(i == 0)
   {
      var i1 = 0;
      var i2 = 1;
   }
   else if(i == len)
   {
      var i1 = len - 2;
      var i2 = len - 1;
   }
   else
   {
      var i1 = i - 1;
      var i2 = i;
   }
   var m = (typesArray[i2].type - typesArray[i1].type) / (typesArray[i2].teff - typesArray[i1].teff);
   var b = typesArray[i1].type - m * typesArray[i1].teff;
   var spectralTypeNumber = m * temp + b;
   if(!isFinite(spectralTypeNumber) || isNaN(spectralTypeNumber) || spectralTypeNumber < 0 || spectralTypeNumber >= 70)
   {
      return null;
   }
   var base = Math.floor(spectralTypeNumber / 10);
   var excess = spectralTypeNumber - 10 * base;
   switch(base)
   {
      case 0:
         spectralType.type = "O";
         break;
      case 1:
         spectralType.type = "B";
         break;
      case 2:
         spectralType.type = "A";
         break;
      case 3:
         spectralType.type = "F";
         break;
      case 4:
         spectralType.type = "G";
         break;
      case 5:
         spectralType.type = "K";
         break;
      case 6:
         spectralType.type = "M";
         break;
      default:
         return null;
   }
   spectralType.number = excess;
   spectralType.spectralTypeNumber = spectralTypeNumber;
   return spectralType;
};
spectralTypesAndTemps = {v:[{type:7,teff:38000},{type:9,teff:33200},{type:9.5,teff:31450},{type:10,teff:29700},{type:11,teff:25600},{type:12,teff:22300},{type:13,teff:19000},{type:14,teff:17200},{type:15,teff:15400},{type:16,teff:14100},{type:17,teff:13000},{type:18,teff:11800},{type:19,teff:10700},{type:20,teff:9480},{type:22,teff:8810},{type:25,teff:8160},{type:27,teff:7930},{type:30,teff:7020},{type:32,teff:6750},{type:35,teff:6530},{type:37,teff:6240},{type:40,teff:5930},{type:42,teff:5830},{type:44,teff:5740},{type:46,teff:5620},{type:50,teff:5240},{type:52,teff:5010},{type:54,teff:4560},{type:55,teff:4340},{type:57,teff:4040},{type:60,teff:3800},{type:61,teff:3680},{type:62,teff:3530},{type:63,teff:3380},{type:64,teff:3180},{type:65,teff:3030},{type:66,teff:2850}],iii:[{type:40,teff:5910},{type:44,teff:5190},{type:46,teff:5050},{type:48,teff:4960},{type:50,teff:4810},{type:51,teff:4610},{type:52,teff:4500},{type:53,teff:4320},{type:54,teff:4080},{type:55,teff:3980},{type:60,teff:3820},{type:61,teff:3780},{type:62,teff:3710},{type:63,teff:3630},{type:64,teff:3560},{type:65,teff:3420},{type:66,teff:3250}],i:[{type:9,teff:32500},{type:10,teff:26000},{type:11,teff:20700},{type:12,teff:17800},{type:13,teff:15600},{type:14,teff:13900},{type:15,teff:13400},{type:16,teff:12700},{type:17,teff:12000},{type:18,teff:11200},{type:19,teff:10500},{type:20,teff:9730},{type:21,teff:9230},{type:22,teff:9080},{type:25,teff:8510},{type:30,teff:7700},{type:32,teff:7170},{type:35,teff:6640},{type:38,teff:6100},{type:40,teff:5510},{type:43,teff:4980},{type:48,teff:4590},{type:50,teff:4420},{type:51,teff:4330},{type:52,teff:4260},{type:53,teff:4130},{type:55,teff:3850},{type:60,teff:3650},{type:61,teff:3550},{type:62,teff:3450},{type:63,teff:3200},{type:64,teff:2980}]};
