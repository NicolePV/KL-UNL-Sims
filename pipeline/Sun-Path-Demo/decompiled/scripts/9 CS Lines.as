function CSLinesClass(parent, name, id, style, head, tail, depth)
{
   this._parent = parent;
   this._name = name;
   this._id = id;
   this.setLineStyle(1,255,100);
   if(typeof style == "object")
   {
      this.setLineStyle(style.thickness,style.color,style.alpha);
   }
   this.visible = true;
   this._head = new Object();
   this._tail = new Object();
   this.setPoints(tail,head);
   this._bE = this._parent._bEL.createEmptyMovieClip("_" + depth,depth);
   this._fE = this._parent._fEL.createEmptyMovieClip("_" + depth,depth);
   this._aI = this._parent._iLA.createEmptyMovieClip("_" + depth,depth);
   this._bI = this._parent._iLB.createEmptyMovieClip("_" + depth,depth);
}
var p = CelestialSphereClass.prototype;
p.addLine = function(name, style, head, tail, depth)
{
   if(depth == undefined)
   {
      depth = 0;
      while(this._fEL["_" + depth] != undefined)
      {
         depth++;
      }
   }
   var id = this._lineFreeID++;
   this[name] = new CSLinesClass(this,name,id,style,head,tail,depth);
   this._lineList.push({id:id,name:this[name]});
};
p.updateLines = function(notHorizon)
{
   var start = getTimer();
   if(notHorizon)
   {
      var i = 0;
      while(i < this._lineList.length)
      {
         var line = this._lineList[i].name;
         if(line._head.sys != 0 || line._tail.sys != 0)
         {
            line.update();
         }
         i++;
      }
   }
   else
   {
      var i = 0;
      while(i < this._lineList.length)
      {
         this._lineList[i].name.update();
         i++;
      }
   }
   trace("lines: " + (getTimer() - start) + " ms");
};
var p = CSLinesClass.prototype = new Object();
p.update = function()
{
   function getMC(u)
   {
      var r = Math.sqrt(u * (u * A + B) + C);
      if(r < rad)
      {
         if(phi == -1.5707963267948966)
         {
            if(u * mz + tail.z > 0)
            {
               return bI;
            }
            return aI;
         }
         if(phi == 1.5707963267948966)
         {
            if(u * mz + tail.z > 0)
            {
               return aI;
            }
            return bI;
         }
         var diff = u * my + tail.y - (u * mz + tail.z) * tp;
         if(diff > 1e-9)
         {
            return bI;
         }
         return aI;
      }
      if(u * mz + tail.z < 0)
      {
         return bE;
      }
      return fE;
   }
   var head = new Object();
   var tail = new Object();
   if(this._head.sys == 0)
   {
      this._parent.WtoSz(this._head,head);
   }
   else
   {
      if(this._head.sys != 1)
      {
         return undefined;
      }
      this._parent.CtoSz(this._head,head);
   }
   if(this._tail.sys == 0)
   {
      this._parent.WtoSz(this._tail,tail);
   }
   else
   {
      if(this._tail.sys != 1)
      {
         return undefined;
      }
      this._parent.CtoSz(this._tail,tail);
   }
   var bE = this._bE;
   var fE = this._fE;
   var aI = this._aI;
   var bI = this._bI;
   bE.clear();
   fE.clear();
   aI.clear();
   bI.clear();
   if(!this.visible)
   {
      return undefined;
   }
   var mx = head.x - tail.x;
   var my = head.y - tail.y;
   var mz = head.z - tail.z;
   var A = mx * mx + my * my + mz * mz;
   var B = 2 * (mx * tail.x + my * tail.y + mz * tail.z);
   var C = tail.x * tail.x + tail.y * tail.y + tail.z * tail.z;
   var rad = this._parent._c.r;
   var phi = this._parent._phi;
   var stmp = [];
   var Q = B * B - 4 * A * (C - rad * rad);
   if(Q > 0)
   {
      var sQ = Math.sqrt(Q);
      stmp.push((- B + sQ) / (2 * A));
      stmp.push((- B - sQ) / (2 * A));
   }
   if(phi > -1.5707963267948966 && phi < 1.5707963267948966)
   {
      var tp = Math.tan(phi);
      if(my != tp * mz)
      {
         var tmp = (tp * tail.z - tail.y) / (my - tp * mz);
         if(Math.sqrt(tmp * (tmp * A + B) + C) < rad)
         {
            stmp.push(tmp);
         }
      }
   }
   else if(mz != 0)
   {
      var tmp = (- tail.z) / mz;
      if(Math.sqrt(tmp * (tmp * A + B) + C) < rad)
      {
         stmp.push(tmp);
      }
   }
   if(mz != 0)
   {
      var tmp = (- tail.z) / mz;
      if(Math.sqrt(tmp * (tmp * A + B) + C) >= rad)
      {
         stmp.push(tmp);
      }
   }
   var s = [0,1];
   var i = 0;
   while(i < stmp.length)
   {
      if(stmp[i] > 0 && stmp[i] < 1)
      {
         var k = 1;
         while(stmp[i] > s[k])
         {
            k++;
         }
         if(stmp[i] != s[k])
         {
            s.splice(k,0,stmp[i]);
         }
      }
      i++;
   }
   var i = 0;
   while(i < s.length - 1)
   {
      var s1 = s[i];
      var s2 = s[i + 1];
      var mc = getMC(s1 + (s2 - s1) / 2);
      mc.lineStyle(this._thick,this._color,this._alpha);
      mc.moveTo(s1 * mx + tail.x,s1 * my + tail.y);
      mc.lineTo(s2 * mx + tail.x,s2 * my + tail.y);
      i++;
   }
};
p.removeLine = function()
{
   var list = this._parent._lineList;
   var i = 0;
   while(i < list.length)
   {
      if(list[i].id == this._id)
      {
         break;
      }
      i++;
   }
   list.splice(i,1);
   this._bE.removeMovieClip();
   this._fE.removeMovieClip();
   this._aI.removeMovieClip();
   this._bI.removeMovieClip();
   delete this;
};
p.setLineStyle = function(thickness, lineColor, alpha)
{
   if(thickness != undefined)
   {
      this._thick = thickness;
   }
   if(lineColor != undefined)
   {
      this._color = lineColor;
   }
   if(alpha != undefined)
   {
      this._alpha = alpha;
   }
};
p.setPoints = function(tail, head)
{
   this.setTailPoint(tail);
   this.setHeadPoint(head);
};
p.setTailPoint = function(tail)
{
   this._parent.parsePointInput(tail,this._tail);
   if(this._tail.sys == -1)
   {
      this._tail.sys = 0;
   }
};
p.setHeadPoint = function(head)
{
   this._parent.parsePointInput(head,this._head);
   if(this._head.sys == -1)
   {
      this._head.sys = 0;
   }
};
