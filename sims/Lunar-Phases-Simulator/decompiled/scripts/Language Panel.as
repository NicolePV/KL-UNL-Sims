function LanguagePanelClass()
{
   this.createEmptyMovieClip("backgroundMC",5);
}
var p = LanguagePanelClass.prototype = new MovieClip();
Object.registerClass("Language Panel",LanguagePanelClass);
p.borderColor = 6710886;
p.borderThickness = 1;
p.backgroundColor = 16448250;
p.selectLanguage = function(lang)
{
   var _loc2_ = 0;
   while(_loc2_ < this.languagesList.length)
   {
      if(this.languagesList[_loc2_].option.langName == lang.langName)
      {
         this.languagesList[_loc2_].checkmark._visible = true;
      }
      else
      {
         this.languagesList[_loc2_].checkmark._visible = false;
      }
      _loc2_ = _loc2_ + 1;
   }
};
p.setChoices = function(list)
{
   var _loc12_ = this.createEmptyMovieClip("optionsMC",10);
   var _loc3_ = [];
   var _loc5_ = 0;
   var _loc6_ = 0;
   var _loc2_ = 0;
   var _loc4_;
   while(_loc2_ < list.length)
   {
      _loc4_ = _loc12_.attachMovie("Language Panel Option","_" + _loc2_,_loc2_,{textFormat:this.textFormat,option:list[_loc2_]});
      if(_loc4_.leftExtent < _loc5_)
      {
         _loc5_ = _loc4_.leftExtent;
      }
      if(_loc4_.rightExtent > _loc6_)
      {
         _loc6_ = _loc4_.rightExtent;
      }
      _loc3_.push(_loc4_);
      _loc2_ = _loc2_ + 1;
   }
   var _loc11_ = 2;
   var _loc13_ = 3;
   var _loc7_ = _loc11_ + 2;
   _loc5_ -= 2;
   _loc6_ += 2;
   _loc2_ = 0;
   while(_loc2_ < _loc3_.length)
   {
      _loc3_[_loc2_].backgroundLeft = _loc5_;
      _loc3_[_loc2_].backgroundRight = _loc6_;
      _loc3_[_loc2_].drawBackground();
      _loc3_[_loc2_]._y = _loc7_;
      _loc7_ += _loc3_[_loc2_]._height + _loc11_;
      _loc2_ = _loc2_ + 1;
   }
   this.backgroundMC.clear();
   this.backgroundMC.moveTo(_loc5_ - _loc13_,0);
   this.backgroundMC.beginFill(this.backgroundColor);
   this.backgroundMC.lineTo(_loc6_ + _loc13_,0);
   this.backgroundMC.lineStyle(this.borderThickness,this.borderColor);
   this.backgroundMC.lineTo(_loc6_ + _loc13_,_loc7_);
   this.backgroundMC.lineTo(_loc5_ - _loc13_,_loc7_);
   this.backgroundMC.lineTo(_loc5_ - _loc13_,0);
   this.backgroundMC.endFill();
   this.backgroundMC.useHandCursor = false;
   this.backgroundMC.tabEnabled = false;
   this.backgroundMC.onPress = function()
   {
   };
   this.leftExtent = _loc5_;
   this.rightExtent = _loc6_;
   this.languagesList = _loc3_;
};
