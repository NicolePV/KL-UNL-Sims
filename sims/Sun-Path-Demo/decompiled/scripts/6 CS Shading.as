var p = CelestialSphereClass.prototype;
p._maskExcess = 1.1;
p.createMasks = function()
{
   var M = 6 * this._N;
   var M0 = this.createEmptyMovieClip("_M0",M);
   var M1 = this.createEmptyMovieClip("_M1",M + 1);
   var M2 = this.createEmptyMovieClip("_M2",M + 2);
   var M3 = this.createEmptyMovieClip("_M3",M + 3);
   var M4 = this.createEmptyMovieClip("_M4",M + 4);
   var M5 = this.createEmptyMovieClip("_M5",M + 5);
   M0._visible = false;
   M1._visible = false;
   M2._visible = false;
   M3._visible = false;
   M4._visible = false;
   M5._visible = false;
   var mE = this._maskExcess;
   var aP = this._aP;
   var cP = this._cP;
   M0.lineStyle(0,16711680,0);
   M0.moveTo(mE * this._sP.x,mE * this._sP.y);
   M0.beginFill(0);
   var i = 0;
   while(i < this._nP)
   {
      M0.curveTo(mE * cP[i].x,mE * cP[i].y,mE * aP[i].x,mE * aP[i].y);
      i++;
   }
   M0.endFill();
   this.updateMasks(true);
};
p.updateMasks = function(redraw)
{
   var start = getTimer();
   var M0 = this._M0;
   var M1 = this._M1;
   var M2 = this._M2;
   var M3 = this._M3;
   var M4 = this._M4;
   var M5 = this._M5;
   if(redraw)
   {
      var mE = this._maskExcess;
      var sP = this._sP;
      var aP = this._aP;
      var cP = this._cP;
      var nP = this._nP;
      var hnP = nP / 2;
      var s = Math.sin(this._phi);
      M1.clear();
      M2.clear();
      M3.clear();
      M4.clear();
      M1.moveTo(sP.x,sp.y);
      M2.moveTo(sP.x,sp.y);
      M3.moveTo(sP.x,sp.y);
      M4.moveTo(sP.x,sp.y);
      M1.beginFill(0);
      M2.beginFill(0);
      M3.beginFill(0);
      M4.beginFill(0);
      var cx;
      var cy;
      var ax = mE * sP.x;
      var ay = mE * sP.y;
      M1.lineTo(ax,ay);
      M2.lineTo(ax,ay);
      M3.lineTo(ax,ay);
      M4.lineTo(ax,ay);
      var i = 0;
      while(i < hnP)
      {
         ax = mE * aP[i].x;
         ay = mE * aP[i].y;
         cx = mE * cP[i].x;
         cy = mE * cP[i].y;
         M1.curveTo(cx,cy,ax,ay);
         M2.curveTo(cx,- cy,ax,- ay);
         M3.curveTo(cx,cy,ax,ay);
         M4.curveTo(cx,- cy,ax,- ay);
         i++;
      }
      ax /= mE;
      ay /= mE;
      M1.lineTo(ax,ay);
      M2.lineTo(ax,ay);
      M3.lineTo(ax,ay);
      M4.lineTo(ax,ay);
      var i = hnP;
      while(i < nP)
      {
         ax = aP[i].x;
         ay = s * aP[i].y;
         cx = cP[i].x;
         cy = s * cP[i].y;
         M1.curveTo(cx,cy,ax,ay);
         M2.curveTo(cx,cy,ax,ay);
         M3.curveTo(cx,- cy,ax,- ay);
         M4.curveTo(cx,- cy,ax,- ay);
         i++;
      }
      M1.endFill();
      M2.endFill();
      M3.endFill();
      M4.endFill();
   }
   M0._xscale = M0._yscale = M1._xscale = M1._yscale = M2._xscale = M2._yscale = M3._xscale = M3._yscale = M4._xscale = M4._yscale = this._c.r;
   var M = 6 * this._N;
   if(this._showUnder)
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
   trace("masks: " + (getTimer() - start) + " ms");
};
p.addShadingClip = function(linkageName, name, side, surface, hemisphere, initObject)
{
   var layer = "_";
   if(side == "back")
   {
      layer += "b";
   }
   else
   {
      layer += "f";
   }
   if(surface == "inner")
   {
      layer += "I";
   }
   else
   {
      layer += "O";
   }
   layer += "S";
   if(hemisphere == "below")
   {
      layer += "B";
   }
   else if(hemisphere == "above")
   {
      layer += "A";
   }
   else
   {
      layer += "F";
   }
   var mc = this[layer];
   var depth = 0;
   while(mc["_" + depth] != undefined)
   {
      depth++;
   }
   this[name] = mc.attachMovie(linkageName,"_" + depth,depth,initObject);
};
p.updateShading = function()
{
   this._bOSB._xscale = this._bOSB._yscale = this._bOSA._xscale = this._bOSA._yscale = this._bOSF._xscale = this._bOSF._yscale = this._bISB._xscale = this._bISB._yscale = this._bISA._xscale = this._bISA._yscale = this._bISF._xscale = this._bISF._yscale = this._fISB._xscale = this._fISB._yscale = this._fISA._xscale = this._fISA._yscale = this._fISF._xscale = this._fISF._yscale = this._fOSB._xscale = this._fOSB._yscale = this._fOSA._xscale = this._fOSA._yscale = this._fOSF._xscale = this._fOSF._yscale = this._c.r;
};
