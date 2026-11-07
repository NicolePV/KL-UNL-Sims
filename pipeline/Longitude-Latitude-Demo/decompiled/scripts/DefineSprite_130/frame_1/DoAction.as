function updateStrings()
{
   var cp = sphere.shores.instance.cursorPosition;
   if(formatGroup.getValue() == "d")
   {
      var latStr = cp.latValStr + "° " + cp.latDirStr;
      var lonStr = cp.lonValStr + "° " + cp.lonDirStr;
      latitudeField.text = latStr;
      longitudeField.text = lonStr;
      sphere.latLabel.instance.labelText = latStr;
      sphere.longLabel.instance.labelText = lonStr;
   }
   else
   {
      latitudeField.text = cp.latitudeDMSString;
      longitudeField.text = cp.longitudeDMSString;
      sphere.latLabel.instance.labelText = cp.latitudeDMSString;
      sphere.longLabel.instance.labelText = cp.longitudeDMSString;
   }
}
function openGoogle()
{
   var cp = sphere.shores.instance.cursorPosition;
   var lonStr = cp.lonValStr + cp.lonDirStr;
   var latStr = cp.latValStr + cp.latDirStr;
   var url = "http://maps.google.com/maps?q=" + lonStr + "+" + latStr + "&spn=30.454102,33.222656&t=k&hl=en";
   getURL(url,"googleMapPage");
}
function changeShowFeatures()
{
   var tmp = showFeaturesCheck.getValue();
   var i = 0;
   while(i < IDL.length)
   {
      sphere["IDL" + i].visible = tmp;
      i++;
   }
   sphere.primeMeridianLabel.visible = tmp;
   sphere.primeMeridian.visible = tmp;
   sphere.IDLLabel.visible = tmp;
   sphere.equatorLabel.visible = tmp;
   sphere.equator.visible = tmp;
   sphere.grayEquator.visible = !tmp;
   if(tmp)
   {
      sphere.updateObjects();
   }
}
function changeShowCities()
{
   var tmp = showCitiesCheck.getValue();
   var i = 0;
   while(i < cityList.length)
   {
      sphere["city" + i].visible = tmp;
      i++;
   }
   if(tmp)
   {
      sphere.updateObjects();
   }
}
function addCities()
{
   var i = 0;
   while(i < cityList.length)
   {
      var city = cityList[i];
      var lat = city.lat.deg + city.lat.min / 60;
      if(city.lat.dir == "S")
      {
         lat *= -1;
      }
      var lon = city.lon.deg + city.lon.min / 60;
      if(city.lon.dir == "W")
      {
         lon *= -1;
      }
      sphere.addObject("City Dot","city" + i,{az:- lon,alt:lat,r:0.99},{cityName:city.name});
      sphere["city" + i].setOrientationType("absolute");
      i++;
   }
}
function addIDL()
{
   var lp = IDL[0];
   var i = 1;
   while(i < IDL.length)
   {
      var np = IDL[i];
      sphere.addCircle("IDL" + i,{thickness:1,color:16745273,alpha:70},{alt:0,az:0,tilt:0});
      sphere["IDL" + i].setArcPoints({az:- lp.lon,alt:lp.lat},{az:- np.lon,alt:np.lat});
      lp = np;
      i++;
   }
}
decRadioButton.setStyleProperty("textSize",10);
sexRadioButton.setStyleProperty("textSize",10);
sphere.size = 300;
sphere.setMouseBehavior("none");
sphere.showHorizonPlane = false;
sphere.sortObjects = true;
sphere.addObject("Cursor Dot","cursor",{az:0,alt:0});
sphere.addObject("shoreDemo","shores",{x:0,y:0,z:0,system:"horizon"},{shoreXMLFile:"si100.xml"});
sphere.addObject("Label","equatorLabel",{alt:0,az:0,r:1.1},{labelColor:4688176,labelText:"Equator"});
sphere.equatorLabel.az = sphere.viewerAzimuth;
sphere.equatorLabel.setOrientationType("absolute");
sphere.addObject("Label","primeMeridianLabel",{alt:45,az:0,r:1.1},{labelColor:16745273,labelText:"Prime Meridian"});
sphere.primeMeridianLabel.setOrientationType("absolute");
sphere.addObject("Label","IDLLabel",{alt:30,az:180,r:1.1},{labelColor:16745273,labelText:"International\nDate Line"});
sphere.IDLLabel.setOrientationType("absolute");
sphere.addCircle("primeMeridian",{thickness:1,color:16745273,alpha:70},{alt:0,az:0,tilt:90,gammaStart:-90,gammaEnd:90});
sphere.addCircle("equator",{thickness:1,color:4688176,alpha:70},{alt:0,az:0,tilt:0});
sphere.addCircle("meridian1",{thickness:1,color:5263440,alpha:10},{alt:0,az:0,tilt:90});
sphere.addCircle("meridian2",{thickness:1,color:5263440,alpha:10},{alt:0,az:90,tilt:90});
sphere.addCircle("grayEquator",{thickness:1,color:5263440,alpha:10},{alt:0,az:0,tilt:0});
latColor = 4934654;
longColor = 16665419;
sphere.addObject("Label","latLabel",{alt:0,az:0},{labelColor:latColor});
sphere.addObject("Label","longLabel",{alt:0,az:0},{labelColor:longColor});
sphere.addCircle("latCircle",{thickness:1,color:9474192,alpha:50},{az:0,alt:0,tilt:90});
sphere.addCircle("longCircle",{thickness:1,color:9474192,alpha:50},{az:0,alt:0,tilt:90});
sphere.addCircle("latArc",{thickness:3,color:latColor,alpha:100},{az:0,alt:0,tilt:0});
sphere.addCircle("longArc",{thickness:3,color:longColor,alpha:100},{az:0,alt:0,tilt:90});
cityList = [{name:"Buenos Aires, Argentina",lat:{deg:34,min:20,dir:"S"},lon:{deg:58,min:30,dir:"W"},side:"left"},{name:"Lima, Peru",lat:{deg:12,min:6,dir:"S"},lon:{deg:76,min:55,dir:"W"},side:"left"},{name:"Casablanca, Morocco",lat:{deg:33,min:32,dir:"N"},lon:{deg:7,min:41,dir:"W"},side:"bottom"},{name:"Monrovia, Liberia",lat:{deg:6,min:20,dir:"N"},lon:{deg:10,min:46,dir:"W"}},{name:"São Paulo, Brazil",lat:{deg:23,min:34,dir:"S"},lon:{deg:46,min:38,dir:"W"},side:"bottom"},{name:"Lincoln",lat:{deg:40,min:49,dir:"W"},lon:{deg:96,min:40,dir:"W"},side:"left"},{name:"Baghdad, Iraq",lat:{deg:33,min:14,dir:"N"},lon:{deg:44,min:22,dir:"E"}},{name:"Greenwich, England",lat:{deg:51,min:40,dir:"N"},lon:{deg:0,min:0,dir:"E"},side:"left"},{name:"Singapore",lat:{deg:1,min:22,dir:"N"},lon:{deg:103,min:45,dir:"E"},side:"left"},{name:"Havana, Cuba",lat:{deg:23,min:8,dir:"N"},lon:{deg:82,min:23,dir:"W"},side:"bottom"},{name:"Canberra, Australia",lat:{deg:35,min:18,dir:"S"},lon:{deg:149,min:8,dir:"E"},side:"bottom"},{name:"Calcutta, India",lat:{deg:22,min:32,dir:"N"},lon:{deg:88,min:22,dir:"E"},side:"bottom"},{name:"Beijing, China",lat:{deg:39,min:55,dir:"N"},lon:{deg:116,min:23,dir:"E"}},{name:"Reykjavik, Iceland",lat:{deg:64,min:9,dir:"N"},lon:{deg:21,min:58,dir:"W"}},{name:"Murmansk, Russia",lat:{deg:68,min:59,dir:"N"},lon:{deg:33,min:8,dir:"E"},side:"top"},{name:"Washington DC",lat:{deg:38,min:53,dir:"N"},lon:{deg:77,min:2,dir:"W"}},{name:"Barrow, Alaska",lat:{deg:71,min:17,dir:"N"},lon:{deg:156,min:47,dir:"W"}},{name:"Moscow, Russia",lat:{deg:55,min:45,dir:"N"},lon:{deg:37,min:37,dir:"E"}},{name:"Cape Town, South Africa",lat:{deg:33,min:55,dir:"S"},lon:{deg:18,min:27,dir:"E"},side:"bottom"},{name:"McMurdo Station",lat:{deg:77,min:51,dir:"S"},lon:{deg:166,min:40,dir:"E"},side:"left"}];
IDL = [{lat:90,lon:180},{lat:75,lon:180},{lat:72,lon:-169},{lat:65.5,lon:-169},{lat:64,lon:-175},{lat:50.5,lon:167},{lat:48,lon:180},{lat:2,lon:180},{lat:0,lon:-179},{lat:0,lon:-165},{lat:-3,lon:-165},{lat:-3,lon:-160},{lat:2,lon:-160},{lat:2,lon:-162},{lat:5,lon:-162},{lat:5,lon:-154},{lat:-8,lon:-151},{lat:-12,lon:-151},{lat:-12,lon:-157},{lat:-9,lon:-157},{lat:-9,lon:-178},{lat:-15,lon:-175.5},{lat:-44.75,lon:-175.5},{lat:-51.5,lon:180},{lat:-90,lon:180}];
addCities();
addIDL();
changeShowFeatures();
changeShowCities();
cityLabel._visible = false;
sphere.shores.instance.moveCursor({alt:40.8,az:96.7});
sphere.setThetaAndPhi(290,25);
sphere.shores.instance.setThetaAndPhi(sphere.theta,sphere.phi);
