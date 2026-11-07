function TimelineEventCycleClass()
{
   this.createEmptyMovieClip("backgroundFillsMC",5);
   this.eventsList = [];
   var i = 0;
   while(i < 4)
   {
      this.eventsList.push(this.attachMovie("Timeline Event Item","event" + i + "MC",10 + i,{eventNumber:i}));
      i++;
   }
}
var p = TimelineEventCycleClass.prototype = new MovieClip();
Object.registerClass("Timeline Event Cycle",TimelineEventCycleClass);
p.onEventClicked = function(eventNumber)
{
   this.timelineMC.simulatorMC.slewToEvent(this.cycleNumber,eventNumber);
};
p.deselectEvent = function(arg)
{
   this.eventsList[arg].setSelected(false);
};
p.selectEvent = function(arg)
{
   this.eventsList[arg].setSelected(true);
};
p.setLabelNamesAndPositions = function(namesList, yList)
{
   var mc = this.backgroundFillsMC;
   mc.clear();
   var w = this.timelineMC.areaWidth;
   var colors = [10526928,10526928];
   var alphas1 = [0,12];
   var alphas2 = [12,0];
   var ratios = [0,255];
   var ly = yList[0];
   var i = 0;
   while(i < 4)
   {
      var ny = yList[i + 1];
      var h = ny - ly;
      this.eventsList[i]._y = ly;
      this.eventsList[i].setEventName(namesList[i]);
      ly = ny;
      i++;
   }
};
