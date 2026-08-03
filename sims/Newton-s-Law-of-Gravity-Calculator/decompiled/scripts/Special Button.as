function SpecialButtonClass()
{
   this.selected(false);
   this.attachMovie(this.def.icon,"icon",1);
   var _loc3_ = Math.floor(Math.log(this.def.v) / 2.302585092994046);
   var _loc6_ = (this.def.v / Math.pow(10,_loc3_)).toFixed(2);
   var _loc9_ = parseFloat(_loc6_);
   if(_loc9_ >= 10)
   {
      _loc9_ /= 10;
      _loc6_ = _loc9_.toFixed(2);
      _loc3_ = _loc3_ + 1;
   }
   _loc3_ = _loc3_.toString();
   var _loc18_ = _loc3_ != "0" ? _loc6_ + "×10<sup>" + _loc3_ + "</sup>" : _loc6_;
   var _loc14_ = new TextFormat("Verdana",12,5263440);
   this.createEmptyMovieClip("label",2);
   var _loc2_ = 0;
   var _loc10_ = 0;
   var _loc17_ = this.displayText(this.def.text,{mc:this.label,depth:100,x:0,y:0,hAlign:"center",vAlign:"top",embedFonts:true,textFormat:_loc14_,sizeRatio:1.3});
   _loc2_ = Math.max(_loc17_.textWidth,_loc2_);
   var _loc19_ = this.displayText(_loc18_ + " " + this.def.unit,{mc:this.label,depth:101,x:0,y:18,hAlign:"center",vAlign:"top",embedFonts:true,textFormat:_loc14_,sizeRatio:1.3});
   _loc2_ = Math.max(_loc19_.textWidth,_loc2_);
   _loc10_ = 34;
   var _loc5_ = 0;
   var _loc16_ = this._parent._parent.controller._maxP + 29 - this._x;
   var _loc15_;
   if(_loc2_ / 2 > _loc16_)
   {
      _loc15_ = _loc2_ / 2 - _loc16_;
      _loc5_ = _loc15_;
      this.label._x = - _loc15_;
   }
   var _loc11_ = 2;
   var _loc12_ = 5;
   var _loc7_ = - _loc11_;
   var _loc4_ = _loc10_ + _loc11_;
   var _loc8_ = - (_loc2_ / 2 + _loc12_);
   var _loc13_ = _loc2_ / 2 + _loc12_;
   this.label.clear();
   this.label.moveTo(_loc8_,_loc7_);
   this.label.lineStyle(2,14211288,100);
   this.label.beginFill(16448250,100);
   this.label.lineTo(_loc13_,_loc7_);
   this.label.lineTo(_loc13_,_loc4_);
   this.label.lineTo(_loc5_ + 8,_loc4_);
   this.label.lineTo(_loc5_,_loc4_ + 5);
   this.label.lineTo(_loc5_ - 8,_loc4_);
   this.label.lineTo(_loc8_,_loc4_);
   this.label.lineTo(_loc8_,_loc7_);
   this.endFill();
   this.label._y = - _loc10_ - 5;
   this.label._visible = false;
   this.icon.gotoAndStop(1);
   this.stop();
}
var p = SpecialButtonClass.prototype = new MovieClip();
Object.registerClass("Special Button",SpecialButtonClass);
p.setSelected = function(arg)
{
   this.selected = arg;
   if(this.selected)
   {
      this.icon.gotoAndStop(2);
      this.gotoAndStop(2);
   }
   else
   {
      this.icon.gotoAndStop(1);
      this.gotoAndStop(1);
   }
};
