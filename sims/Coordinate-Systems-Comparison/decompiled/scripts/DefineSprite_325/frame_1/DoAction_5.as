function selectStar(starID)
{
   starLocationMC._visible = true;
   selectedStar = starID;
   sphere1.raArc.visible = true;
   sphere1.decArc.visible = true;
   sphere2.azArc.visible = true;
   sphere2.altArc.visible = true;
   sphere1.raLabel.visible = true;
   sphere1.decLabel.visible = true;
   sphere2.azLabel.visible = true;
   sphere2.altLabel.visible = true;
   updateCelestialArcs();
   updateHorizonArcs();
   sphere1.updateObjects();
   sphere2.updateObjects();
}
function deselectSelectedStar()
{
   starLocationMC._visible = false;
   selectedStar = null;
   sphere1.raArc.visible = false;
   sphere1.decArc.visible = false;
   sphere2.azArc.visible = false;
   sphere2.altArc.visible = false;
   sphere1.raLabel.visible = false;
   sphere1.decLabel.visible = false;
   sphere2.azLabel.visible = false;
   sphere2.altLabel.visible = false;
}
function moveStar(starID, pt)
{
   if(pt.ra != null)
   {
      sphere1[starID].setPosition(pt);
      sphere2[starID].setPosition(pt);
      sphere1[starID].setOrientationType("absolute");
      sphere2[starID].setOrientationType("absolute");
      updateCelestialArcs();
      updateHorizonArcs();
      sphere1.updateObjects();
      sphere2.updateObjects();
      sphere2[starID].updateTrail();
      sphere2[starID].trailCircle.update();
   }
}
function removeAllStars()
{
   deselectSelectedStar();
   removeAllConstellations();
   var _loc1_ = 0;
   while(_loc1_ < starsList.length)
   {
      sphere1[starsList[_loc1_]].remove();
      sphere2[starsList[_loc1_]].removeTrail();
      sphere2[starsList[_loc1_]].remove();
      _loc1_ = _loc1_ + 1;
   }
   starsList = [];
}
function removeStar(starID)
{
   if(selectedStar == starID)
   {
      deselectSelectedStar();
   }
   sphere1[starID].remove();
   sphere2[starID].removeTrail();
   sphere2[starID].remove();
   var _loc1_ = 0;
   while(_loc1_ < starsList.length)
   {
      if(starsList[_loc1_] == starID)
      {
         starsList.splice(_loc1_,1);
         break;
      }
      _loc1_ = _loc1_ + 1;
   }
}
function addStarRandomly()
{
   var _loc1_ = {};
   _loc1_.dec = 180 * Math.random() - 90;
   _loc1_.ra = 24 * Math.random();
   addStar(_loc1_);
}
function addStar(cp, isConstellationStar)
{
   var _loc1_;
   var _loc4_;
   var _loc3_;
   if(isConstellationStar)
   {
      _loc1_ = "_" + starCounter++;
      _loc4_ = sphere1.addObject("Constellation Star",_loc1_,cp,{starID:_loc1_});
      _loc3_ = sphere2.addObject("Constellation Star",_loc1_,cp,{starID:_loc1_});
   }
   else
   {
      if(starsList.length >= starLimit)
      {
         return null;
      }
      _loc1_ = "_" + starCounter++;
      _loc4_ = sphere1.addObject("Draggable Star",_loc1_,cp,{starID:_loc1_});
      _loc3_ = sphere2.addObject("Draggable Star",_loc1_,cp,{starID:_loc1_});
   }
   starsList.push(_loc1_);
   _loc3_.addTrail();
   _loc4_.setPosition(cp);
   _loc3_.setPosition(cp);
   _loc4_.setOrientationType("absolute");
   _loc3_.setOrientationType("absolute");
   sphere1.updateObjects();
   sphere2.updateObjects();
   return _loc1_;
}
function removeAllConstellations()
{
   for(var _loc1_ in constellations)
   {
      removeConstellation(_loc1_);
   }
   constellationsMenu.deselectAll();
}
function removeConstellation(constellationName)
{
   var _loc2_ = constellations[constellationName];
   if(_loc2_ == undefined || !_loc2_.inUse)
   {
      return undefined;
   }
   _loc2_.inUse = false;
   var _loc1_ = 0;
   while(_loc1_ < _loc2_.stars.length)
   {
      removeStar(_loc2_.stars[_loc1_].starID);
      _loc1_ = _loc1_ + 1;
   }
   _loc1_ = 0;
   while(_loc1_ < _loc2_.arcNames.length)
   {
      sphere1[_loc2_.arcNames[_loc1_]].remove();
      sphere2[_loc2_.arcNames[_loc1_]].remove();
      _loc1_ = _loc1_ + 1;
   }
   constellationsMenu.setSelected(constellationName,false);
}
function addConstellation(constellationName)
{
   var _loc1_ = constellations[constellationName];
   if(_loc1_ == undefined || _loc1_.inUse)
   {
      return false;
   }
   _loc1_.inUse = true;
   var _loc8_ = 0;
   var _loc7_;
   while(_loc8_ < _loc1_.stars.length)
   {
      _loc7_ = addStar(_loc1_.stars[_loc8_],true);
      sphere1[_loc7_].instance.constellation = constellationName;
      sphere2[_loc7_].instance.constellation = constellationName;
      _loc1_.stars[_loc8_].starID = _loc7_;
      _loc8_ = _loc8_ + 1;
   }
   var _loc15_ = 0;
   _loc1_.arcNames = [];
   _loc8_ = 0;
   var _loc6_;
   var _loc5_;
   var _loc3_;
   var _loc2_;
   var _loc4_;
   while(_loc8_ < _loc1_.paths.length)
   {
      _loc6_ = _loc1_.paths[_loc8_];
      _loc5_ = _loc1_.stars[_loc6_.m];
      _loc3_ = _loc6_.b;
      while(_loc3_ < _loc6_.e)
      {
         p1 = _loc1_.stars[_loc3_];
         _loc2_ = "_" + constellationName + _loc15_++;
         _loc1_.arcNames.push(_loc2_);
         _loc4_ = sphere1.addCircle(_loc2_,{thickness:1,color:16777215,alpha:80},{ra:0,dec:0});
         _loc4_.setArcPoints(_loc5_,p1);
         _loc4_.update();
         _loc4_ = sphere2.addCircle(_loc2_,{thickness:1,color:16777215,alpha:80},{ra:0,dec:0});
         _loc4_.setArcPoints(_loc5_,p1);
         _loc4_.update();
         _loc5_ = p1;
         _loc3_ = _loc3_ + 1;
      }
      _loc8_ = _loc8_ + 1;
   }
   constellationsMenu.setSelected(constellationName,true);
   return true;
}
function onConstellationToggled(name)
{
   if(!constellations[name].inUse)
   {
      addConstellation(name);
   }
   else
   {
      removeConstellation(name);
   }
}
selectedStar = null;
backgroundMC.useHandCursor = false;
backgroundMC.tabEnabled = false;
backgroundMC.onPress = function()
{
   deselectSelectedStar();
};
starCounter = 0;
starsList = [];
starLimit = 50;
constellations = {bigDipper:{inUse:false,paths:[{m:0,b:1,e:7}],stars:[{dec:61.75092,ra:11.06215},{dec:56.38236,ra:11.03068},{dec:53.69475,ra:11.89717},{dec:57.03258,ra:12.25709},{dec:55.95989,ra:12.90048},{dec:54.92539,ra:13.39875},{dec:49.31336,ra:13.79235}]},orion:{inUse:false,paths:[{m:0,b:1,e:5},{m:1,b:5,e:6},{m:3,b:6,e:7}],stars:[{dec:7.40706,ra:5.91953},{dec:-1.94257,ra:5.67931},{dec:-1.20192,ra:5.60356},{dec:-0.29909,ra:5.53344},{dec:6.3497,ra:5.41885},{dec:-9.6696,ra:5.79594},{dec:-8.20164,ra:5.2423}]},southernCross:{inUse:false,paths:[{m:0,b:1,e:2},{m:2,b:3,e:4}],stars:[{dec:-63.09905,ra:12.4433},{dec:-57.11321,ra:12.51943},{dec:-59.68876,ra:12.79535},{dec:-58.74893,ra:12.25242}]}};
