function SunbeamComponentClass()
{
   this.drawGrid();
   this.update();
}
var p = SunbeamComponentClass.prototype = new MovieClip();
Object.registerClass("Sunbeam Component",SunbeamComponentClass);
p.borderColor = 6710886;
p.gridColor = 12966910;
p.backgroundColor = 16777215;
p.pallIntensity = 20;
p.update = function()
{
   this.gridAreaMC.beamMC._rotation = this.sunAzimuth;
   var _loc2_ = Math.sin(this.sunAltitude * 0.017453292519943295);
   if(_loc2_ < 0)
   {
      _loc2_ = 0;
   }
   if(_loc2_ == 0)
   {
      this.gridAreaMC.beamMC._alpha = 0;
   }
   else
   {
      this.gridAreaMC.beamMC._alpha = 100 * Math.pow(_loc2_,0.5);
   }
   var _loc3_;
   if(this.sunAltitude > 0)
   {
      _loc3_ = this.pallIntensity * Math.pow((10 - this.sunAltitude) / 10,3);
      if(_loc3_ < 0)
      {
         _loc3_ = 0;
      }
      this.gridAreaMC.pallMC._alpha = _loc3_;
   }
   else
   {
      this.gridAreaMC.pallMC._alpha = this.pallIntensity;
   }
   if(_loc2_ < 0.05)
   {
      _loc2_ = 0.05;
   }
   this.gridAreaMC.beamMC._yscale = this.gridAreaMC.beamMC._xscale / _loc2_;
};
p.drawGrid = function()
{
   var _loc9_ = this.gridWidth;
   var _loc8_ = this.gridHeight;
   var _loc6_ = _loc9_ / 2;
   var _loc7_ = _loc8_ / 2;
   var _loc10_ = this.beamDiameter;
   var _loc17_ = this.createEmptyMovieClip("gridAreaMC",1);
   var _loc11_ = this.createEmptyMovieClip("gridAreaMaskMC",2);
   var _loc14_ = this.createEmptyMovieClip("borderMC",3);
   _loc11_.clear();
   _loc11_.lineStyle(undefined);
   _loc11_.beginFill(16711680,50);
   _loc11_.moveTo(0,0);
   _loc11_.lineTo(_loc9_,0);
   _loc11_.lineTo(_loc9_,_loc8_);
   _loc11_.lineTo(0,_loc8_);
   _loc11_.lineTo(0,0);
   _loc11_.endFill();
   _loc17_.setMask(_loc11_);
   _loc14_.clear();
   _loc14_.lineStyle(1,this.borderColor,100);
   _loc14_.moveTo(0,0);
   _loc14_.lineTo(_loc9_,0);
   _loc14_.lineTo(_loc9_,_loc8_);
   _loc14_.lineTo(0,_loc8_);
   _loc14_.lineTo(0,0);
   var _loc13_ = _loc17_.createEmptyMovieClip("backgroundMC",1);
   _loc13_.clear();
   _loc13_.lineStyle(undefined);
   _loc13_.beginFill(this.backgroundColor,100);
   _loc13_.moveTo(0,0);
   _loc13_.lineTo(_loc9_,0);
   _loc13_.lineTo(_loc9_,_loc8_);
   _loc13_.lineTo(0,_loc8_);
   _loc13_.lineTo(0,0);
   _loc13_.endFill();
   var _loc2_ = _loc17_.createEmptyMovieClip("gridMC",2);
   _loc2_.clear();
   _loc2_.lineStyle(1,this.gridColor,100);
   var _loc16_ = Math.ceil(_loc6_ / _loc10_);
   var _loc5_ = 0;
   var _loc4_;
   while(_loc5_ < _loc16_)
   {
      _loc4_ = _loc10_ * (_loc5_ + 0.5);
      _loc2_.moveTo(_loc6_ - _loc4_,0);
      _loc2_.lineTo(_loc6_ - _loc4_,_loc8_);
      _loc2_.moveTo(_loc6_ + _loc4_,0);
      _loc2_.lineTo(_loc6_ + _loc4_,_loc8_);
      _loc5_ = _loc5_ + 1;
   }
   var _loc15_ = Math.ceil(_loc7_ / _loc10_);
   _loc5_ = 0;
   var _loc3_;
   while(_loc5_ < _loc15_)
   {
      _loc3_ = _loc10_ * (_loc5_ + 0.5);
      _loc2_.moveTo(0,_loc7_ - _loc3_);
      _loc2_.lineTo(_loc9_,_loc7_ - _loc3_);
      _loc2_.moveTo(0,_loc7_ + _loc3_);
      _loc2_.lineTo(_loc9_,_loc7_ + _loc3_);
      _loc5_ = _loc5_ + 1;
   }
   _loc17_.attachMovie("Sun Beam Spot","beamMC",3,{_xscale:_loc10_,_yscale:_loc10_,_x:_loc6_,_y:_loc7_});
   var _loc12_ = _loc17_.createEmptyMovieClip("pallMC",10);
   _loc12_.clear();
   _loc12_.lineStyle(undefined);
   _loc12_.beginFill(0,100);
   _loc12_.moveTo(0,0);
   _loc12_.lineTo(_loc9_,0);
   _loc12_.lineTo(_loc9_,_loc8_);
   _loc12_.lineTo(0,_loc8_);
   _loc12_.lineTo(0,0);
   _loc12_.endFill();
};
