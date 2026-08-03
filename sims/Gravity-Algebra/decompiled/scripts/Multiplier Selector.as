function MultiplierSelectorClass()
{
   this.instancesList.push(this);
   this.choicesList = [{value:0.3333333333333333,p2:0,p3:-1,link:"One Third"},{value:0.5,p2:-1,p3:0,link:"One Half"},{value:1,p2:0,p3:0,link:"One"},{value:2,p2:1,p3:0,link:"Two"},{value:3,p2:0,p3:1,link:"Three"}];
   this.createEmptyMovieClip("backgroundMC",1);
   this.createEmptyMovieClip("currChoiceMC",5);
   this.createEmptyMovieClip("choicesMC",10);
   with(this.backgroundMC)
   {
      moveTo(0,0);
      beginFill(16711680,0);
      lineTo(this.selectorWidth,0);
      lineTo(this.selectorWidth,this.selectorHeight);
      lineTo(0,this.selectorHeight);
      lineTo(0,0);
   }
   this.backgroundMC.onPress = function()
   {
      if(!this._parent.getExpanded())
      {
         this._parent.setExpanded(true);
      }
   };
   var i = 0;
   while(i < this.choicesList.length)
   {
      this.currChoiceMC.attachMovie(this.choicesList[i].link,"_" + i,i,{_visible:false});
      this.currChoiceMC["_" + i].gotoAndStop(1);
      i++;
   }
   var i = 0;
   while(i < this.choicesList.length)
   {
      this.choicesList[i].index = i;
      this.choicesList[i].mc = this.choicesMC.attachMovie("Multiplier Choice","_" + i,i,{_x:i * this.selectorWidth,def:this.choicesList[i]});
      i++;
   }
   this.choicesMC._xscale = this.choicesMC._yscale = 60;
   var margin = 7;
   var midX = this.selectorWidth * this.choicesList.length / 2;
   this.choicesMC._x = this.selectorWidth / 2 - this.choicesMC._yscale / 100 * midX;
   this.choicesMC._y = - this.choicesMC._height - 5;
   var bottomY = this.selectorHeight + margin;
   var rightX = this.selectorWidth * this.choicesList.length + margin;
   var k = 100 / this.choicesMC._yscale;
   with(this.choicesMC)
   {
      clear();
      moveTo(- margin,- margin);
      lineStyle(3,10526880);
      beginFill(16777215,100);
      lineTo(rightX,- margin);
      lineTo(rightX,bottomY);
      lineTo(midX + 18,bottomY);
      lineTo(midX,bottomY + 8);
      lineTo(midX - 18,bottomY);
      lineTo(- margin,bottomY);
      lineTo(- margin,- margin);
      endFill();
      lineStyle();
      moveTo(- margin,bottomY);
      beginFill(65280,0);
      lineTo(rightX,bottomY);
      lineTo(midX + k * this.selectorWidth / 2,bottomY + this.selectorHeight + 18);
      lineTo(midX - k * this.selectorWidth / 2,bottomY + this.selectorHeight + 18);
      lineTo(- margin,bottomY);
      endFill();
   }
   this.setSelected(2);
}
var p = MultiplierSelectorClass.prototype = new MovieClip();
Object.registerClass("Multiplier Selector",MultiplierSelectorClass);
p.selectorHeight = 30;
p.selectorWidth = 26;
p.instancesList = [];
p.onEnterFrame = function()
{
   if(this.expanded && getTimer() > this.cancelExpandedTime)
   {
      this.setExpanded(false);
   }
};
p.onMouseMove = function()
{
   if(this.expanded && !this.hitTest(_root._xmouse,_root._ymouse,true))
   {
      if(!isFinite(this.cancelExpandedTime))
      {
         this.cancelExpandedTime = getTimer() + 500;
      }
   }
   else
   {
      this.cancelExpandedTime = Infinity;
   }
};
p.onMouseDown = function()
{
   if(this.expanded && !this.hitTest(_root._xmouse,_root._ymouse,true))
   {
      this.setExpanded(false);
      this.setBackgroundStyle("mouseOut");
   }
};
p.getSelectedChoice = function()
{
   return this.choicesList[this.selectedIndex];
};
p.setSelected = function(index)
{
   this.selectedIndex = index;
   var _loc2_ = 0;
   while(_loc2_ < this.choicesList.length)
   {
      this.choicesList[_loc2_].mc.setSelected(index == _loc2_);
      this.currChoiceMC["_" + _loc2_]._visible = index == _loc2_;
      _loc2_ = _loc2_ + 1;
   }
   this.setExpanded(false);
   this.changeHandler();
};
p.getExpanded = function()
{
   return this.expanded;
};
p.setExpanded = function(arg)
{
   this.expanded = arg;
   var _loc2_;
   if(arg)
   {
      this.swapDepths(1000010);
      this.choicesMC._visible = true;
      _loc2_ = 0;
      while(_loc2_ < this.instancesList.length)
      {
         if(this.instancesList[_loc2_] != this)
         {
            this.instancesList[_loc2_].setExpanded(false);
         }
         _loc2_ = _loc2_ + 1;
      }
   }
   else
   {
      this.choicesMC._visible = false;
   }
   this.cancelExpandedTime = Infinity;
};
