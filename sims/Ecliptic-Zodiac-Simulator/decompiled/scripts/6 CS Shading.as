var p = CelestialSphereClass.prototype;
p.createMasks = function()
{
   var _loc3_ = this;
   var M = 6 * _loc3_._N;
   var _loc2_ = _loc3_.createEmptyMovieClip("_M0",M);
   var M1 = _loc3_.createEmptyMovieClip("_M1",M + 1);
   var M2 = _loc3_.createEmptyMovieClip("_M2",M + 2);
   var M3 = _loc3_.createEmptyMovieClip("_M3",M + 3);
   var M4 = _loc3_.createEmptyMovieClip("_M4",M + 4);
   var M5 = _loc3_.createEmptyMovieClip("_M5",M + 5);
   _loc2_._visible = false;
   M1._visible = false;
   M2._visible = false;
   M3._visible = false;
   M4._visible = false;
   M5._visible = false;
   var r = 100;
   var _loc1_ = 120;
   _loc2_.lineStyle(0,16711680,0);
   _loc2_.moveTo(_loc1_,_loc1_);
   _loc2_.beginFill(0);
   _loc2_.lineTo(_loc1_,- _loc1_);
   _loc2_.lineTo(- _loc1_,- _loc1_);
   _loc2_.lineTo(- _loc1_,_loc1_);
   _loc2_.lineTo(_loc1_,_loc1_);
   _loc2_.endFill();
   _loc3_.updateMasks(true);
};
p.updateMasks = function(redraw)
{
   var _loc1_ = this;
   var start = getTimer();
   var M0 = _loc1_._M0;
   var M1 = _loc1_._M1;
   var M2 = _loc1_._M2;
   var M3 = _loc1_._M3;
   var M4 = _loc1_._M4;
   var M5 = _loc1_._M5;
   var _loc3_;
   var _loc2_;
   if(redraw)
   {
      var r = 100;
      var d = 120;
      var hnp = 4;
      var step = 3.141592653589793 / hnp;
      var halfStep = step / 2;
      var cos = Math.cos;
      var sin = Math.sin;
      var cr = r / cos(halfStep);
      var s = sin(_loc1_._phi);
      var sax = r;
      var say = s * r;
      var scx = cr;
      var scy = s * cr;
      M1.lineStyle(0,16711680,0);
      M2.lineStyle(0,16711680,0);
      M3.lineStyle(0,16711680,0);
      M4.lineStyle(0,16711680,0);
      M1.clear();
      M2.clear();
      M3.clear();
      M4.clear();
      M1.moveTo(d,- d);
      M2.moveTo(d,d);
      M3.moveTo(d,- d);
      M4.moveTo(d,d);
      M1.beginFill(0);
      M2.beginFill(0);
      M3.beginFill(0);
      M4.beginFill(0);
      M1.lineTo(d,0);
      M1.lineTo(r,0);
      M2.lineTo(d,0);
      M2.lineTo(r,0);
      M3.lineTo(d,0);
      M3.lineTo(r,0);
      M4.lineTo(d,0);
      M4.lineTo(r,0);
      var aAngle = step;
      var cAngle = aAngle - halfStep;
      var i = 0;
      while(i < hnp)
      {
         var ax = sax * cos(aAngle);
         var ay = say * sin(aAngle);
         _loc3_ = scx * cos(cAngle);
         _loc2_ = scy * sin(cAngle);
         M1.curveTo(_loc3_,_loc2_,ax,ay);
         M2.curveTo(_loc3_,_loc2_,ax,ay);
         M3.curveTo(_loc3_,- _loc2_,ax,- ay);
         M4.curveTo(_loc3_,- _loc2_,ax,- ay);
         aAngle += step;
         cAngle += step;
         i++;
      }
      M1.lineTo(- d,0);
      M1.lineTo(- d,- d);
      M1.lineTo(d,- d);
      M2.lineTo(- d,0);
      M2.lineTo(- d,d);
      M2.lineTo(d,d);
      M3.lineTo(- d,0);
      M3.lineTo(- d,- d);
      M3.lineTo(d,- d);
      M4.lineTo(- d,0);
      M4.lineTo(- d,d);
      M4.lineTo(d,d);
      M1.endFill();
      M2.endFill();
      M3.endFill();
      M4.endFill();
   }
   M0._xscale = M0._yscale = M1._xscale = M2._xscale = M3._xscale = M4._xscale = _loc1_._c.r;
   M1._yscale = M2._yscale = M3._yscale = M4._yscale = _loc1_._c.r;
   var M = 6 * _loc1_._N;
   if(_loc1_._showUnder)
   {
      M4.duplicateMovieClip("_bOSBMask",M + 25);
      M3.duplicateMovieClip("_bOSAMask",M + 24);
      M0.duplicateMovieClip("_bOSFMask",M + 23);
      M0.duplicateMovieClip("_bFMask",M + 22);
      M0.duplicateMovieClip("_bCMask",M + 21);
      M4.duplicateMovieClip("_bISBMask",M + 20);
      M3.duplicateMovieClip("_bISAMask",M + 19);
      M0.duplicateMovieClip("_bISFMask",M + 18);
      M2.duplicateMovieClip("_fISBMask",M + 17);
      M1.duplicateMovieClip("_fISAMask",M + 16);
      M0.duplicateMovieClip("_fISFMask",M + 15);
      M0.duplicateMovieClip("_fFMask",M + 14);
      M0.duplicateMovieClip("_fCMask",M + 13);
      M2.duplicateMovieClip("_fOSBMask",M + 12);
      M1.duplicateMovieClip("_fOSAMask",M + 11);
      M0.duplicateMovieClip("_fOSFMask",M + 10);
   }
   else
   {
      M5.duplicateMovieClip("_bOSBMask",M + 25);
      M3.duplicateMovieClip("_bOSAMask",M + 24);
      M3.duplicateMovieClip("_bOSFMask",M + 23);
      M3.duplicateMovieClip("_bFMask",M + 22);
      M3.duplicateMovieClip("_bCMask",M + 21);
      M5.duplicateMovieClip("_bISBMask",M + 20);
      M3.duplicateMovieClip("_bISAMask",M + 19);
      M3.duplicateMovieClip("_bISFMask",M + 18);
      M5.duplicateMovieClip("_fISBMask",M + 17);
      M1.duplicateMovieClip("_fISAMask",M + 16);
      M1.duplicateMovieClip("_fISFMask",M + 15);
      M1.duplicateMovieClip("_fFMask",M + 14);
      M1.duplicateMovieClip("_fCMask",M + 13);
      M5.duplicateMovieClip("_fOSBMask",M + 12);
      M1.duplicateMovieClip("_fOSAMask",M + 11);
      M1.duplicateMovieClip("_fOSFMask",M + 10);
   }
   _loc1_._bOSB.setMask(_loc1_._bOSBMask);
   _loc1_._bOSA.setMask(_loc1_._bOSAMask);
   _loc1_._bOSF.setMask(_loc1_._bOSFMask);
   _loc1_._bF.setMask(_loc1_._bFMask);
   _loc1_._bC.setMask(_loc1_._bCMask);
   _loc1_._bISB.setMask(_loc1_._bISBMask);
   _loc1_._bISA.setMask(_loc1_._bISAMask);
   _loc1_._bISF.setMask(_loc1_._bISFMask);
   _loc1_._fISB.setMask(_loc1_._fISBMask);
   _loc1_._fISA.setMask(_loc1_._fISAMask);
   _loc1_._fISF.setMask(_loc1_._fISFMask);
   _loc1_._fF.setMask(_loc1_._fFMask);
   _loc1_._fC.setMask(_loc1_._fCMask);
   _loc1_._fOSB.setMask(_loc1_._fOSBMask);
   _loc1_._fOSA.setMask(_loc1_._fOSAMask);
   _loc1_._fOSF.setMask(_loc1_._fOSFMask);
   if(_loc1_._traceOn)
   {
      trace("masks: " + (getTimer() - start) + " ms");
   }
};
p.addShadingClip = function(linkageName, name, side, surface, hemisphere, initObject)
{
   var _loc2_ = "_";
   if(side == "back")
   {
      _loc2_ += "b";
   }
   else
   {
      _loc2_ += "f";
   }
   if(surface == "inner")
   {
      _loc2_ += "I";
   }
   else
   {
      _loc2_ += "O";
   }
   _loc2_ += "S";
   if(hemisphere == "below")
   {
      _loc2_ += "B";
   }
   else if(hemisphere == "above")
   {
      _loc2_ += "A";
   }
   else
   {
      _loc2_ += "F";
   }
   var _loc3_ = this[_loc2_];
   var _loc1_ = 0;
   while(_loc3_["_" + _loc1_] != undefined)
   {
      _loc1_ = _loc1_ + 1;
   }
   this[name] = _loc3_.attachMovie(linkageName,"_" + _loc1_,_loc1_,initObject);
};
p.updateShading = function()
{
   var _loc1_ = this;
   _loc1_._bOSB._xscale = _loc1_._bOSB._yscale = _loc1_._bOSA._xscale = _loc1_._bOSA._yscale = _loc1_._bOSF._xscale = _loc1_._bOSF._yscale = _loc1_._bISB._xscale = _loc1_._bISB._yscale = _loc1_._bISA._xscale = _loc1_._bISA._yscale = _loc1_._bISF._xscale = _loc1_._bISF._yscale = _loc1_._fISB._xscale = _loc1_._fISB._yscale = _loc1_._fISA._xscale = _loc1_._fISA._yscale = _loc1_._fISF._xscale = _loc1_._fISF._yscale = _loc1_._fOSB._xscale = _loc1_._fOSB._yscale = _loc1_._fOSA._xscale = _loc1_._fOSA._yscale = _loc1_._fOSF._xscale = _loc1_._fOSF._yscale = _loc1_._c.r;
};
