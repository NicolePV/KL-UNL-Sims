function GasListClass()
{
   this.createEmptyMovieClip("backgroundMC",0);
   var x = this.entryWidth + this.margin;
   var y = this.verticalSpacing * this._parent.gasLimit + this.margin;
   this.backgroundMC.lineStyle(this.borderThickness,this.borderColor);
   this.backgroundMC.moveTo(- this.margin,- this.margin);
   this.backgroundMC.beginFill(this.backgroundColor);
   this.backgroundMC.lineTo(x,- this.margin);
   this.backgroundMC.lineTo(x,y);
   this.backgroundMC.lineTo(- this.margin,y);
   this.backgroundMC.lineTo(- this.margin,- this.margin);
   this.backgroundMC.endFill();
   this.entryFreeDepth = 1;
   this.entriesList = [];
   this.selectedEntry = null;
}
var p = GasListClass.prototype = new MovieClip();
Object.registerClass("Gas List",GasListClass);
p.entryHeight = 21;
p.entryWidth = 290;
p.verticalSpacing = 21;
p.margin = 5;
p.backgroundColor = 16777215;
p.borderThickness = 1;
p.borderColor = 12632256;
p.getSelectedEntry = function()
{
   if(this.selectedEntry != null)
   {
      return this.selectedEntry.id;
   }
   return null;
};
p.setSelectedEntry = function(id, callChangeHandler)
{
   this.selectedEntry.setSelectedState(false);
   this.selectedEntry = this.getMCFromID(id);
   if(this.selectedEntry != null)
   {
      this.selectedEntry.setSelectedState(true);
      if(callChangeHandler)
      {
         this._parent[this.onEntrySelectedChangeHandler](this.selectedEntry.id);
      }
   }
};
p.addEntry = function(id, infoObject)
{
   var depth = this.entryFreeDepth++;
   var mc = this.attachMovie("Gas List Entry","_" + depth,depth,{listMC:this,id:id,infoObject:infoObject});
   this[id] = mc;
   this.entriesList.push({id:id,mc:mc});
   this.refreshList();
};
p.removeEntry = function(id)
{
   var index = this.getIndexFromID(id);
   if(index == null)
   {
      return undefined;
   }
   if(this.selectedEntry.id == id)
   {
      this.selectedEntry = null;
   }
   this.entriesList[index].mc.removeMovieClip();
   this.entriesList.splice(index,1);
   this.refreshList();
};
p.refreshList = function()
{
   var eL = this.entriesList;
   var i = 0;
   while(i < eL.length)
   {
      eL[i].mc._y = i * this.verticalSpacing;
      i++;
   }
};
p.getIndexFromID = function(id)
{
   var eL = this.entriesList;
   var i = 0;
   while(i < eL.length)
   {
      if(eL[i].id == id)
      {
         return i;
      }
      i++;
   }
   return null;
};
p.getMCFromID = function(id)
{
   var eL = this.entriesList;
   var i = 0;
   while(i < eL.length)
   {
      if(eL[i].id == id)
      {
         return eL[i].mc;
      }
      i++;
   }
   return null;
};
