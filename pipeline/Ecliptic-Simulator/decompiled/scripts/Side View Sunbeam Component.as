function SideViewSunbeamComponentClass()
{
   this.createEmptyMovieClip("boxMC",1);
   this.createEmptyMovieClip("boxMaskMC",2);
   this.createEmptyMovieClip("borderMC",3);
   this.boxMC.createEmptyMovieClip("raysMC",1);
   this.boxMC.createEmptyMovieClip("pallMC",10);
   var _loc2_ = 0;
   while(_loc2_ < this.maxBeams)
   {
      this.boxMC.raysMC.attachMovie("Ray Component","_" + _loc2_,_loc2_,{length:this.beamLength});
      _loc2_ = _loc2_ + 1;
   }
   this.boxMaskMC.lineStyle(1,16711680,100);
   this.boxMaskMC.moveTo(0,0);
   this.boxMaskMC.beginFill(16711680,40);
   this.boxMaskMC.lineTo(this.width,0);
   this.boxMaskMC.lineTo(this.width,this.height);
   this.boxMaskMC.lineTo(0,this.height);
   this.boxMaskMC.lineTo(0,0);
   this.boxMaskMC.endFill();
   this.boxMC.setMask(this.boxMaskMC);
   this.borderMC.lineStyle(1,6710886,100);
   this.borderMC.moveTo(0,0);
   this.borderMC.lineTo(this.width,0);
   this.borderMC.lineTo(this.width,this.height);
   this.borderMC.lineTo(0,this.height);
   this.borderMC.lineTo(0,0);
   this.boxMC.pallMC.clear();
   this.boxMC.pallMC.lineStyle(undefined);
   this.boxMC.pallMC.moveTo(0,0);
   this.boxMC.pallMC.beginFill(0,100);
   this.boxMC.pallMC.lineTo(this.width,0);
   this.boxMC.pallMC.lineTo(this.width,this.height);
   this.boxMC.pallMC.lineTo(0,this.height);
   this.boxMC.pallMC.lineTo(0,0);
   this.boxMC.pallMC.endFill();
}
var p = SideViewSunbeamComponentClass.prototype = new MovieClip();
Object.registerClass("Side View Sunbeam Component",SideViewSunbeamComponentClass);
p.width = 365;
p.height = 220;
p.horizonHeight = 50;
p.beamSpacing = 30;
p.margin = 42.5;
p.pallIntensity = 40;
p.diagonal = Math.sqrt(p.width * p.width + p.height * p.height);
p.beamLength = p.diagonal + 2 * p.margin;
p.maxBeams = Math.ceil(p.beamLength / p.beamSpacing);
p.update = function()
{
   var _loc3_ = this.boxMC.raysMC;
   if(this.sunDirection == "S")
   {
      _loc3_._xscale = -100;
      _loc3_._x = this.width;
   }
   else
   {
      _loc3_._xscale = 100;
      _loc3_._x = 0;
   }
   var _loc11_ = this.sunAltitude;
   var _loc13_ = Math.sin(this.sunAltitude * 0.017453292519943295);
   if(_loc13_ < 0)
   {
      _loc13_ = 0;
   }
   if(_loc13_ == 0)
   {
      _loc3_._alpha = 0;
   }
   else
   {
      _loc3_._alpha = 100 * Math.pow(_loc13_,0.5);
   }
   var _loc14_;
   if(this.sunAltitude > 0)
   {
      _loc14_ = this.pallIntensity * Math.pow((10 - this.sunAltitude) / 10,3);
      if(_loc14_ < 0)
      {
         _loc14_ = 0;
      }
      this.boxMC.pallMC._alpha = _loc14_;
   }
   else
   {
      this.boxMC.pallMC._alpha = this.pallIntensity;
   }
   var _loc12_;
   var _loc5_;
   var _loc6_;
   var _loc8_;
   var _loc9_;
   var _loc2_;
   var _loc4_;
   var _loc10_;
   var _loc7_;
   if(_loc11_ >= 90)
   {
      _loc12_ = this.beamSpacing;
      _loc5_ = - this.margin;
      _loc6_ = this.height - this.horizonHeight;
      _loc8_ = this.maxBeams;
      _loc9_ = this.width + this.margin;
      _loc2_ = 0;
      while(_loc5_ < _loc9_)
      {
         _loc4_ = _loc3_["_" + _loc2_];
         _loc4_._visible = true;
         _loc4_._x = _loc5_;
         _loc4_._y = _loc6_;
         _loc4_._rotation = 180;
         _loc5_ += _loc12_;
         _loc2_ = _loc2_ + 1;
      }
      while(_loc2_ < _loc8_)
      {
         _loc3_["_" + _loc2_]._visible = false;
         _loc2_ = _loc2_ + 1;
      }
   }
   else if(_loc11_ > 0)
   {
      _loc12_ = this.beamSpacing / Math.sin(0.017453292519943295 * _loc11_);
      _loc10_ = this.beamSpacing / Math.cos(0.017453292519943295 * _loc11_);
      _loc5_ = - this.margin;
      _loc6_ = this.height - this.horizonHeight;
      _loc7_ = 90 + _loc11_;
      _loc8_ = this.maxBeams;
      _loc9_ = this.width + this.margin;
      _loc2_ = 0;
      while(_loc5_ < _loc9_)
      {
         _loc4_ = _loc3_["_" + _loc2_];
         _loc4_._visible = true;
         _loc4_._x = _loc5_;
         _loc4_._y = _loc6_;
         _loc4_._rotation = _loc7_;
         _loc5_ += _loc12_;
         _loc2_ = _loc2_ + 1;
      }
      _loc6_ -= (_loc5_ - _loc9_) * Math.tan(0.017453292519943295 * _loc11_);
      _loc5_ = _loc9_;
      while(_loc6_ > minY && _loc2_ < _loc8_)
      {
         _loc4_ = _loc3_["_" + _loc2_];
         _loc4_._visible = true;
         _loc4_._x = _loc5_;
         _loc4_._y = _loc6_;
         _loc4_._rotation = _loc7_;
         _loc6_ -= _loc10_;
         _loc2_ = _loc2_ + 1;
      }
      while(_loc2_ < _loc8_)
      {
         _loc3_["_" + _loc2_]._visible = false;
         _loc2_ = _loc2_ + 1;
      }
   }
};
