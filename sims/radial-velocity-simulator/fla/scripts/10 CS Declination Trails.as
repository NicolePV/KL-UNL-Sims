function CSDeclinationTrailsClass(parent, name, id, style, head, depth)
{
   this._parent = parent;
   this._name = name;
   this._id = id;
   this._fwmc = this._parent._fDT.createEmptyMovieClip("_" + depth,depth);
   this._fimc = this._fwmc.createEmptyMovieClip("innerMC",1);
   this._bwmc = this._parent._bDT.createEmptyMovieClip("_" + depth,depth);
   this._bimc = this._bwmc.createEmptyMovieClip("innerMC",1);
   this._fmmc = this._parent._fDT.createEmptyMovieClip("m" + depth,500000 + depth);
   this._bmmc = this._parent._bDT.createEmptyMovieClip("m" + depth,500000 + depth);
   this._fwmc.setMask(this._fmmc);
   this._bwmc.setMask(this._bmmc);
   this._style = {};
   this.setStyle(style);
   this._head = {};
   this.setHeadPoint(head);
   this._visible = true;
   this.updateMasks();
}
var p = CelestialSphereClass.prototype;
p.addDeclinationTrail = function(name, style, head, depth)
{
   if(this._fDT._ir == undefined)
   {
      this._fDT._ir = 0;
   }
   if(depth == undefined)
   {
      depth = 0;
      while(this._fDT["_" + depth] != undefined)
      {
         depth++;
      }
   }
   var id = this._decTrailFreeID++;
   this[name] = new CSDeclinationTrailsClass(this,name,id,style,head,depth);
   this._decTrailList.push({id:id,name:this[name]});
   return this[name];
};
p._decTrailAngle = 1.0471975511965976;
p.getDeclinationTrailLength = function()
{
   return this._decTrailAngle * 180 / 3.141592653589793;
};
p.setDeclinationTrailLength = function(arg)
{
   this._decTrailAngle = (arg % 360 + 360) % 360 * 3.141592653589793 / 180;
   this.updateTrailArcs();
};
p.addProperty("declinationTrailLengths",p.getDeclinationTrailLengths,p.setDeclinationTrailLengths);
p.updateTrailArcs = function()
{
   var list = this._decTrailList;
   var i = 0;
   while(i < list.length)
   {
      list[i].name.updateArcs();
      i++;
   }
};
p.updateTrailMasks = function()
{
   var list = this._decTrailList;
   var i = 0;
   while(i < list.length)
   {
      list[i].name.updateMasks();
      i++;
   }
};
p.updateDeclinationTrails = function(arg)
{
   var start = getTimer();
   if(arg)
   {
      var st = this._sTime * 180 / 3.141592653589793;
      var ir = this._fDT._ir;
      var list = this._decTrailList;
      var i = list.length - 1;
      var trail = list[i].name;
      while(i >= 0)
      {
         trail._bimc._rotation = trail._fimc._rotation = ir + st - trail._rot;
         trail = list[--i].name;
      }
   }
   else
   {
      var c = this._c;
      var b0 = c.b0;
      var b1 = c.b1;
      var b2 = c.b2;
      var b3 = c.b3;
      var b4 = c.b4;
      var b5 = c.b5;
      var b6 = c.b6;
      var b7 = c.b7;
      var b8 = c.b8;
      var sqrt = Math.sqrt;
      var atan2 = Math.atan2;
      var asin = Math.asin;
      var cos = Math.cos;
      var sin = Math.sin;
      var ir = -57.29577951308232 * atan2(c.a7,c.a8 * c.m2 - c.a6 * c.m8);
      this._fDT._ir = ir;
      var wr = -57.29577951308232 * atan2(b2,b5);
      var ws = 100 * b8 / c.r;
      var st = this._sTime * 180 / 3.141592653589793;
      var list = this._decTrailList;
      var i = list.length - 1;
      var trail = list[i].name;
      while(i >= 0)
      {
         var cd = trail._cd;
         var sd = trail._sd;
         if(cd != null)
         {
            var x = b2 * sd;
            var y = b5 * sd;
            var tr = st - trail._rot;
            trail._fwmc._rotation = wr;
            trail._fwmc._yscale = ws;
            trail._fwmc._x = x;
            trail._fwmc._y = y;
            trail._fimc._rotation = ir + tr;
            trail._bwmc._rotation = wr;
            trail._bwmc._yscale = ws;
            trail._bwmc._x = x;
            trail._bwmc._y = y;
            trail._bimc._rotation = ir + tr;
            var k1 = b6 * cd;
            var k2 = b7 * cd;
            var k3 = b8 * sd;
            var A = sqrt(k1 * k1 + k2 * k2);
            if(A == 0)
            {
               if(k3 < 0)
               {
                  trail._fmmc._rotation = 0;
                  trail._fmmc._x = 0;
                  trail._fmmc._y = - trail._yOffset;
                  trail._bmmc._rotation = 0;
                  trail._bmmc._x = 0;
                  trail._bmmc._y = trail._yOffset;
               }
               else
               {
                  trail._fmmc._rotation = 0;
                  trail._fmmc._x = 0;
                  trail._fmmc._y = trail._yOffset;
                  trail._bmmc._rotation = 0;
                  trail._bmmc._x = 0;
                  trail._bmmc._y = - trail._yOffset;
               }
            }
            else
            {
               var sj = (- k3) / A;
               if(sj <= -1)
               {
                  trail._fmmc._rotation = 0;
                  trail._fmmc._x = 0;
                  trail._fmmc._y = trail._yOffset;
                  trail._bmmc._rotation = 0;
                  trail._bmmc._x = 0;
                  trail._bmmc._y = - trail._yOffset;
               }
               else if(sj >= 1)
               {
                  trail._fmmc._rotation = 0;
                  trail._fmmc._x = 0;
                  trail._fmmc._y = - trail._yOffset;
                  trail._bmmc._rotation = 0;
                  trail._bmmc._x = 0;
                  trail._bmmc._y = trail._yOffset;
               }
               else
               {
                  var j = asin(sj);
                  var t = atan2(k1,k2);
                  var g1 = j - t;
                  var g2 = 3.141592653589793 - j - t;
                  var ix = cos(g1);
                  var iy = sin(g1);
                  var x1 = (ix * b0 + iy * b1) * cd + x;
                  var y1 = (ix * b3 + iy * b4) * cd + y;
                  var ix = cos(g2);
                  var iy = sin(g2);
                  var x2 = (ix * b0 + iy * b1) * cd + x;
                  var y2 = (ix * b3 + iy * b4) * cd + y;
                  var mx = x2 + (x1 - x2) / 2;
                  var my = y2 + (y1 - y2) / 2;
                  trail._fmmc._x = mx;
                  trail._fmmc._y = my;
                  trail._bmmc._x = mx;
                  trail._bmmc._y = my;
                  var angle = atan2(my,mx) * 180 / 3.141592653589793;
                  if(k3 > 0)
                  {
                     trail._fmmc._rotation = angle - 90;
                     trail._bmmc._rotation = angle + 90;
                  }
                  else if(k3 < 0)
                  {
                     trail._fmmc._rotation = angle + 90;
                     trail._bmmc._rotation = angle - 90;
                  }
               }
            }
         }
         trail = list[--i].name;
      }
   }
};
p.showDeclinationTrails = function()
{
   var list = this._decTrailList;
   var i = 0;
   while(i < list.length)
   {
      list[i].name.visible = true;
      i++;
   }
};
p.hideDeclinationTrails = function()
{
   var list = this._decTrailList;
   var i = 0;
   while(i < list.length)
   {
      list[i].name.visible = false;
      i++;
   }
};
p.removeDeclinationTrails = function()
{
   var list = this._decTrailList;
   var i = 0;
   while(i < list.length)
   {
      i++;
   }
   this._decTrailFreeID = 0;
   this._decTrailList = [];
};
var p = CSDeclinationTrailsClass.prototype = new Object();
p.setHeadPoint = function(arg)
{
   this._parent.pointToCelestial(arg,this._head);
   if(this._head.dec != null)
   {
      this._cd = Math.cos(this._head.dec * 3.141592653589793 / 180);
      this._sd = Math.sin(this._head.dec * 3.141592653589793 / 180);
      this._rot = this._head.ra * 15;
      this.updateArcs();
   }
   else
   {
      this._cd = null;
      this._sd = null;
      this._rot = null;
   }
};
p.updateArcs = function()
{
   var cos = Math.cos;
   var sin = Math.sin;
   var r = this._parent._c.r * this._cd;
   var fmc = this._fimc;
   var bmc = this._bimc;
   fmc.clear();
   bmc.clear();
   var n = 50;
   var angleStep = (- this._parent._decTrailAngle) / n;
   var alphaStep = -100 / n;
   var angle = 4.71238898038469;
   var alpha = 100;
   fmc.lineStyle(1,0,alpha);
   bmc.lineStyle(1,0,alpha);
   var x = r * cos(angle);
   var y = r * sin(angle);
   fmc.moveTo(x,y);
   bmc.moveTo(x,y);
   var i = 0;
   while(i < n)
   {
      angle += angleStep;
      alpha += alphaStep;
      fmc.lineStyle(1,0,alpha);
      bmc.lineStyle(1,0,alpha);
      var x = r * cos(angle);
      var y = r * sin(angle);
      fmc.lineTo(x,y);
      bmc.lineTo(x,y);
      i++;
   }
};
p.updateMasks = function()
{
   var w = 1.3 * this._parent._c.r;
   var h = -2.3 * this._parent._c.r;
   this._yOffset = (- h) / 2;
   var fmc = this._fmmc;
   fmc.clear();
   fmc.beginFill(16711680,100);
   fmc.moveTo(w,0);
   fmc.lineTo(w,h);
   fmc.lineTo(- w,h);
   fmc.lineTo(- w,0);
   fmc.lineTo(w,0);
   fmc.endFill();
   var bmc = this._bmmc;
   bmc.clear();
   bmc.beginFill(255,100);
   bmc.moveTo(w,0);
   bmc.lineTo(w,h);
   bmc.lineTo(- w,h);
   bmc.lineTo(- w,0);
   bmc.lineTo(w,0);
   bmc.endFill();
};
