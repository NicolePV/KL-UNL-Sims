var p = CelestialSphereClass.prototype;
p.createMasks = function()
{
   var _loc4_ = 6 * this._N;
   var _loc3_ = this.createEmptyMovieClip("_M0",_loc4_);
   var _loc9_ = this.createEmptyMovieClip("_M1",_loc4_ + 1);
   var _loc8_ = this.createEmptyMovieClip("_M2",_loc4_ + 2);
   var _loc7_ = this.createEmptyMovieClip("_M3",_loc4_ + 3);
   var _loc6_ = this.createEmptyMovieClip("_M4",_loc4_ + 4);
   var _loc5_ = this.createEmptyMovieClip("_M5",_loc4_ + 5);
   _loc3_._visible = false;
   _loc9_._visible = false;
   _loc8_._visible = false;
   _loc7_._visible = false;
   _loc6_._visible = false;
   _loc5_._visible = false;
   var _loc10_ = 100;
   var _loc2_ = 120;
   _loc3_.lineStyle(0,16711680,0);
   _loc3_.moveTo(_loc2_,_loc2_);
   _loc3_.beginFill(0);
   _loc3_.lineTo(_loc2_,- _loc2_);
   _loc3_.lineTo(- _loc2_,- _loc2_);
   _loc3_.lineTo(- _loc2_,_loc2_);
   _loc3_.lineTo(_loc2_,_loc2_);
   _loc3_.endFill();
   this.updateMasks(true);
};
p.updateMasks = function(redraw)
{
   var _loc29_ = getTimer();
   var _loc18_ = this._M0;
   var _loc9_ = this._M1;
   var _loc12_ = this._M2;
   var _loc8_ = this._M3;
   var _loc11_ = this._M4;
   var _loc25_ = this._M5;
   var _loc20_;
   var _loc6_;
   var _loc19_;
   var _loc15_;
   var _loc28_;
   var _loc17_;
   var _loc16_;
   var _loc27_;
   var _loc26_;
   var _loc24_;
   var _loc23_;
   var _loc22_;
   var _loc21_;
   var _loc13_;
   var _loc14_;
   var _loc10_;
   var _loc5_;
   var _loc4_;
   var _loc3_;
   var _loc2_;
   if(redraw)
   {
      _loc20_ = 100;
      _loc6_ = 120;
      _loc19_ = 4;
      _loc15_ = 3.141592653589793 / _loc19_;
      _loc28_ = _loc15_ / 2;
      _loc17_ = Math.cos;
      _loc16_ = Math.sin;
      _loc27_ = _loc20_ / _loc17_(_loc28_);
      _loc26_ = _loc16_(this._phi);
      _loc24_ = _loc20_;
      _loc23_ = _loc26_ * _loc20_;
      _loc22_ = _loc27_;
      _loc21_ = _loc26_ * _loc27_;
      _loc9_.lineStyle(0,16711680,0);
      _loc12_.lineStyle(0,16711680,0);
      _loc8_.lineStyle(0,16711680,0);
      _loc11_.lineStyle(0,16711680,0);
      _loc9_.clear();
      _loc12_.clear();
      _loc8_.clear();
      _loc11_.clear();
      _loc9_.moveTo(_loc6_,- _loc6_);
      _loc12_.moveTo(_loc6_,_loc6_);
      _loc8_.moveTo(_loc6_,- _loc6_);
      _loc11_.moveTo(_loc6_,_loc6_);
      _loc9_.beginFill(0);
      _loc12_.beginFill(0);
      _loc8_.beginFill(0);
      _loc11_.beginFill(0);
      _loc9_.lineTo(_loc6_,0);
      _loc9_.lineTo(_loc20_,0);
      _loc12_.lineTo(_loc6_,0);
      _loc12_.lineTo(_loc20_,0);
      _loc8_.lineTo(_loc6_,0);
      _loc8_.lineTo(_loc20_,0);
      _loc11_.lineTo(_loc6_,0);
      _loc11_.lineTo(_loc20_,0);
      _loc13_ = _loc15_;
      _loc14_ = _loc13_ - _loc28_;
      _loc10_ = 0;
      while(_loc10_ < _loc19_)
      {
         _loc5_ = _loc24_ * _loc17_(_loc13_);
         _loc4_ = _loc23_ * _loc16_(_loc13_);
         _loc3_ = _loc22_ * _loc17_(_loc14_);
         _loc2_ = _loc21_ * _loc16_(_loc14_);
         _loc9_.curveTo(_loc3_,_loc2_,_loc5_,_loc4_);
         _loc12_.curveTo(_loc3_,_loc2_,_loc5_,_loc4_);
         _loc8_.curveTo(_loc3_,- _loc2_,_loc5_,- _loc4_);
         _loc11_.curveTo(_loc3_,- _loc2_,_loc5_,- _loc4_);
         _loc13_ += _loc15_;
         _loc14_ += _loc15_;
         _loc10_ = _loc10_ + 1;
      }
      _loc9_.lineTo(- _loc6_,0);
      _loc9_.lineTo(- _loc6_,- _loc6_);
      _loc9_.lineTo(_loc6_,- _loc6_);
      _loc12_.lineTo(- _loc6_,0);
      _loc12_.lineTo(- _loc6_,_loc6_);
      _loc12_.lineTo(_loc6_,_loc6_);
      _loc8_.lineTo(- _loc6_,0);
      _loc8_.lineTo(- _loc6_,- _loc6_);
      _loc8_.lineTo(_loc6_,- _loc6_);
      _loc11_.lineTo(- _loc6_,0);
      _loc11_.lineTo(- _loc6_,_loc6_);
      _loc11_.lineTo(_loc6_,_loc6_);
      _loc9_.endFill();
      _loc12_.endFill();
      _loc8_.endFill();
      _loc11_.endFill();
   }
   _loc18_._xscale = _loc18_._yscale = _loc9_._xscale = _loc12_._xscale = _loc8_._xscale = _loc11_._xscale = this._c.r;
   _loc9_._yscale = _loc12_._yscale = _loc8_._yscale = _loc11_._yscale = this._c.r;
   var _loc7_ = 6 * this._N;
   if(this._showUnder)
   {
      _loc11_.duplicateMovieClip("_bOSBMask",_loc7_ + 25);
      _loc8_.duplicateMovieClip("_bOSAMask",_loc7_ + 24);
      _loc18_.duplicateMovieClip("_bOSFMask",_loc7_ + 23);
      _loc18_.duplicateMovieClip("_bFMask",_loc7_ + 22);
      _loc18_.duplicateMovieClip("_bCMask",_loc7_ + 21);
      _loc11_.duplicateMovieClip("_bISBMask",_loc7_ + 20);
      _loc8_.duplicateMovieClip("_bISAMask",_loc7_ + 19);
      _loc18_.duplicateMovieClip("_bISFMask",_loc7_ + 18);
      _loc12_.duplicateMovieClip("_fISBMask",_loc7_ + 17);
      _loc9_.duplicateMovieClip("_fISAMask",_loc7_ + 16);
      _loc18_.duplicateMovieClip("_fISFMask",_loc7_ + 15);
      _loc18_.duplicateMovieClip("_fFMask",_loc7_ + 14);
      _loc18_.duplicateMovieClip("_fCMask",_loc7_ + 13);
      _loc12_.duplicateMovieClip("_fOSBMask",_loc7_ + 12);
      _loc9_.duplicateMovieClip("_fOSAMask",_loc7_ + 11);
      _loc18_.duplicateMovieClip("_fOSFMask",_loc7_ + 10);
   }
   else
   {
      _loc25_.duplicateMovieClip("_bOSBMask",_loc7_ + 25);
      _loc8_.duplicateMovieClip("_bOSAMask",_loc7_ + 24);
      _loc8_.duplicateMovieClip("_bOSFMask",_loc7_ + 23);
      _loc8_.duplicateMovieClip("_bFMask",_loc7_ + 22);
      _loc8_.duplicateMovieClip("_bCMask",_loc7_ + 21);
      _loc25_.duplicateMovieClip("_bISBMask",_loc7_ + 20);
      _loc8_.duplicateMovieClip("_bISAMask",_loc7_ + 19);
      _loc8_.duplicateMovieClip("_bISFMask",_loc7_ + 18);
      _loc25_.duplicateMovieClip("_fISBMask",_loc7_ + 17);
      _loc9_.duplicateMovieClip("_fISAMask",_loc7_ + 16);
      _loc9_.duplicateMovieClip("_fISFMask",_loc7_ + 15);
      _loc9_.duplicateMovieClip("_fFMask",_loc7_ + 14);
      _loc9_.duplicateMovieClip("_fCMask",_loc7_ + 13);
      _loc25_.duplicateMovieClip("_fOSBMask",_loc7_ + 12);
      _loc9_.duplicateMovieClip("_fOSAMask",_loc7_ + 11);
      _loc9_.duplicateMovieClip("_fOSFMask",_loc7_ + 10);
   }
   this._bOSB.setMask(this._bOSBMask);
   this._bOSA.setMask(this._bOSAMask);
   this._bOSF.setMask(this._bOSFMask);
   this._bF.setMask(this._bFMask);
   this._bC.setMask(this._bCMask);
   this._bISB.setMask(this._bISBMask);
   this._bISA.setMask(this._bISAMask);
   this._bISF.setMask(this._bISFMask);
   this._fISB.setMask(this._fISBMask);
   this._fISA.setMask(this._fISAMask);
   this._fISF.setMask(this._fISFMask);
   this._fF.setMask(this._fFMask);
   this._fC.setMask(this._fCMask);
   this._fOSB.setMask(this._fOSBMask);
   this._fOSA.setMask(this._fOSAMask);
   this._fOSF.setMask(this._fOSFMask);
   if(!this._traceOn)
   {
   }
};
p.addShadingClip = function(linkageName, name, side, surface, hemisphere, initObject)
{
   var _loc3_ = "_";
   if(side == "back")
   {
      _loc3_ += "b";
   }
   else
   {
      _loc3_ += "f";
   }
   if(surface == "inner")
   {
      _loc3_ += "I";
   }
   else
   {
      _loc3_ += "O";
   }
   _loc3_ += "S";
   if(hemisphere == "below")
   {
      _loc3_ += "B";
   }
   else if(hemisphere == "above")
   {
      _loc3_ += "A";
   }
   else
   {
      _loc3_ += "F";
   }
   var _loc4_ = this[_loc3_];
   var _loc2_ = 0;
   while(_loc4_["_" + _loc2_] != undefined)
   {
      _loc2_ = _loc2_ + 1;
   }
   this[name] = _loc4_.attachMovie(linkageName,"_" + _loc2_,_loc2_,initObject);
   return this[name];
};
p.updateShading = function()
{
   this._bOSB._xscale = this._bOSB._yscale = this._bOSA._xscale = this._bOSA._yscale = this._bOSF._xscale = this._bOSF._yscale = this._bISB._xscale = this._bISB._yscale = this._bISA._xscale = this._bISA._yscale = this._bISF._xscale = this._bISF._yscale = this._fISB._xscale = this._fISB._yscale = this._fISA._xscale = this._fISA._yscale = this._fISF._xscale = this._fISF._yscale = this._fOSB._xscale = this._fOSB._yscale = this._fOSA._xscale = this._fOSA._yscale = this._fOSF._xscale = this._fOSF._yscale = this._c.r;
};
