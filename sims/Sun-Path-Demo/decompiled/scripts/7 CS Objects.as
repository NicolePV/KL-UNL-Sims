function CSObjectsClass(parent, name, id, linkageName, position, initObject)
{
   this._parent = parent;
   this._name = name;
   this._id = id;
   this._p = new Object();
   this._sp = new Object();
   this._o = {x:0,y:0,z:0};
   this._oType = 0;
   this.setLinkageName(linkageName,initObject);
   if(typeof position != "object")
   {
      this.setPosition({alt:0,az:0,r:1});
      this.instance._visible = false;
   }
   else
   {
      this.setPosition(position);
   }
}
var p = CelestialSphereClass.prototype;
p.addObject = function(linkageName, name, position, initObject)
{
   var id = this._objectFreeID++;
   this[name] = new CSObjectsClass(this,name,id,linkageName,position,initObject);
   this._objectList.push({id:id,name:this[name]});
};
p.removeAllObjects = function()
{
   var list = this._objectList;
   var i = 0;
   while(i < list.length)
   {
      list[i].name.shell.removeMovieClip();
      delete list[i].name;
      i++;
   }
   this._objectList = [];
   this._objectFreeID = 0;
};
p.updateObjectsNoSort = function()
{
   var start = getTimer();
   var bEd = 0;
   var bSd = this._N;
   if(this._phi < 0)
   {
      var bId = 3 * this._N;
      var aId = 2 * this._N;
   }
   else
   {
      var bId = 2 * this._N;
      var aId = 3 * this._N;
   }
   var fSd = 4 * this._N;
   var fEd = 5 * this._N;
   var hU = !this._showUnder;
   var list = this._objectList;
   var i = 0;
   for(; i < list.length; i++)
   {
      var obj = list[i].name;
      if(obj._r > 1)
      {
         if(hu)
         {
            var wp = {};
            if(obj._sys == 0)
            {
               wp = obj._p;
            }
            else if(obj._sys == 1)
            {
               this.CtoW(obj._p,wp);
            }
            if(wp.z < 0)
            {
               obj.shell._visible = false;
               continue;
            }
            obj.shell._visible = true;
            this.WtoSz(wp,obj._sp);
         }
         else
         {
            obj.shell._visible = true;
            if(obj._sys == 0)
            {
               this.WtoSz(obj._p,obj._sp);
            }
            else if(obj._sys == 1)
            {
               this.CtoSz(obj._p,obj._sp);
            }
         }
         if(obj._sp.z < 0)
         {
            obj.shell.swapDepths(bEd++);
         }
         else
         {
            obj.shell.swapDepths(fEd++);
         }
      }
      else if(obj._r < 1)
      {
         var wp = {};
         if(obj._sys == 0)
         {
            wp = obj._p;
         }
         else if(obj._sys == 1)
         {
            this.CtoW(obj._p,wp);
         }
         if(hU && wp.z < 0)
         {
            obj.shell._visible = false;
            continue;
         }
         obj.shell._visible = true;
         if(wp.z < 0)
         {
            obj.shell.swapDepths(bId++);
         }
         else
         {
            obj.shell.swapDepths(aId++);
         }
         this.WtoSz(wp,obj._sp);
      }
      else
      {
         if(hu)
         {
            var wp = {};
            if(obj._sys == 0)
            {
               wp = obj._p;
            }
            else if(obj._sys == 1)
            {
               this.CtoW(obj._p,wp);
            }
            if(wp.z < 0)
            {
               obj.shell._visible = false;
               continue;
            }
            obj.shell._visible = true;
            this.WtoSz(wp,obj._sp);
         }
         else
         {
            obj.shell._visible = true;
            if(obj._sys == 0)
            {
               this.WtoSz(obj._p,obj._sp);
            }
            else if(obj._sys == 1)
            {
               this.CtoSz(obj._p,obj._sp);
            }
         }
         if(obj._sp.z < 0)
         {
            obj.shell.swapDepths(bSd++);
         }
         else
         {
            obj.shell.swapDepths(fSd++);
         }
      }
      obj.update();
   }
   trace("objects: " + (getTimer() - start) + " ms, (not sorted)");
};
p.updateObjectsSort = function()
{
   var start = getTimer();
   var bE = [];
   var bS = [];
   var bI = [];
   var aI = [];
   var fS = [];
   var fE = [];
   var hU = !this._showUnder;
   var list = this._objectList;
   var i = 0;
   for(; i < list.length; i++)
   {
      var obj = list[i].name;
      if(obj._r > 1)
      {
         if(hu)
         {
            var wp = {};
            if(obj._sys == 0)
            {
               wp = obj._p;
            }
            else if(obj._sys == 1)
            {
               this.CtoW(obj._p,wp);
            }
            if(wp.z < 0)
            {
               obj.shell._visible = false;
               continue;
            }
            obj.shell._visible = true;
            this.WtoSz(wp,obj._sp);
         }
         else
         {
            obj.shell._visible = true;
            if(obj._sys == 0)
            {
               this.WtoSz(obj._p,obj._sp);
            }
            else if(obj._sys == 1)
            {
               this.CtoSz(obj._p,obj._sp);
            }
         }
         if(obj._sp.z < 0)
         {
            bE.push([obj._sp.z,obj.shell]);
         }
         else
         {
            fE.push([obj._sp.z,obj.shell]);
         }
      }
      else if(obj._r < 1)
      {
         var wp = {};
         if(obj._sys == 0)
         {
            wp = obj._p;
         }
         else if(obj._sys == 1)
         {
            this.CtoW(obj._p,wp);
         }
         if(hU && wp.z < 0)
         {
            obj.shell._visible = false;
            continue;
         }
         obj.shell._visible = true;
         this.WtoSz(wp,obj._sp);
         if(wp.z < 0)
         {
            bI.push([obj._sp.z,obj.shell]);
         }
         else
         {
            aI.push([obj._sp.z,obj.shell]);
         }
      }
      else
      {
         if(hu)
         {
            var wp = {};
            if(obj._sys == 0)
            {
               wp = obj._p;
            }
            else if(obj._sys == 1)
            {
               this.CtoW(obj._p,wp);
            }
            if(wp.z < 0)
            {
               obj.shell._visible = false;
               continue;
            }
            obj.shell._visible = true;
            this.WtoSz(wp,obj._sp);
         }
         else
         {
            obj.shell._visible = true;
            if(obj._sys == 0)
            {
               this.WtoSz(obj._p,obj._sp);
            }
            else if(obj._sys == 1)
            {
               this.CtoSz(obj._p,obj._sp);
            }
         }
         if(obj._sp.z < 0)
         {
            bS.push([obj._sp.z,obj.shell]);
         }
         else
         {
            fS.push([obj._sp.z,obj.shell]);
         }
      }
      obj.update();
   }
   bE.sort(this.sortRegion);
   bS.sort(this.sortRegion);
   bI.sort(this.sortRegion);
   aI.sort(this.sortRegion);
   fS.sort(this.sortRegion);
   fE.sort(this.sortRegion);
   var i = 0;
   while(i < bE.length)
   {
      bE[i][1].swapDepths(i);
      i++;
   }
   var B = this._N;
   var i = 0;
   while(i < bS.length)
   {
      bS[i][1].swapDepths(B + i);
      i++;
   }
   if(this._phi < 0)
   {
      B = 3 * this._N;
      var i = 0;
      while(i < bI.length)
      {
         bI[i][1].swapDepths(B + i);
         i++;
      }
      B = 2 * this._N;
      var i = 0;
      while(i < aI.length)
      {
         aI[i][1].swapDepths(B + i);
         i++;
      }
   }
   else
   {
      B = 2 * this._N;
      var i = 0;
      while(i < bI.length)
      {
         bI[i][1].swapDepths(B + i);
         i++;
      }
      B = 3 * this._N;
      var i = 0;
      while(i < aI.length)
      {
         aI[i][1].swapDepths(B + i);
         i++;
      }
   }
   B = 4 * this._N;
   var i = 0;
   while(i < fS.length)
   {
      fS[i][1].swapDepths(B + i);
      i++;
   }
   B = 5 * this._N;
   var i = 0;
   while(i < fE.length)
   {
      fE[i][1].swapDepths(B + i);
      i++;
   }
   trace("objects: " + (getTimer() - start) + " ms, (sorted)");
};
p.sortRegion = function(a, b)
{
   if(a[0] < b[0])
   {
      return -1;
   }
   if(a[0] == b[0])
   {
      return 0;
   }
   if(a[0] > b[0])
   {
      return 1;
   }
};
p.getSortObjects = function()
{
   if(this.updateObjects == this.updateObjectsSort)
   {
      return true;
   }
   return false;
};
p.setSortObjects = function(arg)
{
   if(arg)
   {
      this.updateObjects = this.updateObjectsSort;
      this.updateObjects();
   }
   else
   {
      this.updateObjects = this.updateObjectsNoSort;
   }
};
p.addProperty("sortObjects",p.getSortObjects,p.setSortObjects);
var p = CSObjectsClass.prototype = new Object();
p.setLinkageName = function(linkageName, initObject)
{
   this.shell.removeMovieClip();
   this._linkageName = linkageName;
   this._initObject = initObject;
   this.shell = this._parent.createEmptyMovieClip("_obj" + this._id,7 * this._parent._N + this._id);
   this.instance = this.shell.attachMovie(linkageName,"_obj" + this._id,0,initObject);
};
p.setPosition = function(arg)
{
   var pt = new Object();
   this._parent.parsePointInput(arg,pt);
   if(pt.sys == 0 || pt.sys == -1)
   {
      this._sys = 0;
      this._p = pt;
      this._alt = arg.alt;
      this._az = arg.az;
      this._r = pt.r;
   }
   else if(pt.sys == 1)
   {
      this._sys = 1;
      this._p = pt;
      this._dec = arg.dec;
      this._ra = arg.ra;
      this._r = pt.r;
   }
   this._p_o = {x:this._p.x + this._o.x,y:this._p.y + this._o.y,z:this._p.z + this._o.z};
   this._p_n = {x:this._p.x + this._n.x,y:this._p.y + this._n.y,z:this._p.z + this._n.z};
   this._p_u = {x:this._p.x + this._u.x,y:this._p.y + this._u.y,z:this._p.z + this._u.z};
};
p.getPosition = function(arg)
{
   if(typeof arg == "object")
   {
      arg.x = this._p.x;
      arg.y = this._p.y;
      arg.z = this._p.z;
      if(this._sys == 0)
      {
         arg.system = "horizon";
      }
      else if(this._sys == 1)
      {
         arg.system = "celestial";
      }
   }
};
p.setOrientationType = function(type, arg2, arg3)
{
   if(type == "flat")
   {
      this._oType = 0;
   }
   else if(type == "skewed")
   {
      this._oType = 1;
      if(typeof arg2 != "object")
      {
         var m = Math.sqrt(this._p.x * this._p.x + this._p.y * this._p.y + this._p.z * this._p.z);
         this._o = {x:this._p.x / m,y:this._p.y / m,z:this._p.z / m};
      }
      else
      {
         var v = new Object();
         this._parent.parsePointInput(arg2,v);
         if(v.sys == 0 && this._sys == 1)
         {
            var tv = new Object();
            this._parent.WtoC(v,tv);
            v = tv;
         }
         else if(v.sys == 1 && this._sys == 0)
         {
            var tv = new Object();
            this._parent.CtoW(v,tv);
            v = tv;
         }
         else if(v.sys == null)
         {
            return undefined;
         }
         var m = Math.sqrt(v.x * v.x + v.y * v.y + v.z * v.z);
         this._o = {x:v.x / m,y:v.y / m,z:v.z / m};
      }
      this._p_o = {x:this._p.x + this._o.x,y:this._p.y + this._o.y,z:this._p.z + this._o.z};
   }
   else if(type == "absolute")
   {
      this._oType = 2;
      if(typeof arg2 != "object" || typeof arg3 != "object")
      {
         var nm = Math.sqrt(this._p.x * this._p.x + this._p.y * this._p.y + this._p.z * this._p.z);
         this._n = {x:this._p.x / nm,y:this._p.y / nm,z:this._p.z / nm};
         if(!(this._n.x == 0 && this._n.y == 0))
         {
            this._u = {x:(- this._n.x) * this._n.z,y:(- this._n.z) * this._n.y,z:this._n.x * this._n.x + this._n.y * this._n.y};
            var nu = Math.sqrt(this._u.x * this._u.x + this._u.y * this._u.y + this._u.z * this._u.z);
            this._u = {x:this._u.x / nu,y:this._u.y / nu,z:this._u.z / nu};
         }
         else
         {
            this._u = {x:0,y:1,z:0};
         }
      }
      else
      {
         var v1 = new Object();
         this._parent.parsePointInput(arg2,v1);
         if(v1.sys == 0 && this._sys == 1)
         {
            var tv = new Object();
            this._parent.WtoC(v1,tv);
            v1 = tv;
         }
         else if(v1.sys == 1 && this._sys == 0)
         {
            var tv = new Object();
            this._parent.CtoW(v1,tv);
            v1 = tv;
         }
         else if(v1.sys == null)
         {
            return undefined;
         }
         var v2 = new Object();
         this._parent.parsePointInput(arg3,v2);
         if(v2.sys == 0 && this._sys == 1)
         {
            var tv = new Object();
            this._parent.WtoC(v2,tv);
            v2 = tv;
         }
         else if(v2.sys == 1 && this._sys == 0)
         {
            var tv = new Object();
            this._parent.CtoW(v2,tv);
            v2 = tv;
         }
         else if(v2.sys == null)
         {
            return undefined;
         }
         trace("v2.x " + v2.x + ", v2.y: " + v2.y + ", v2.z: " + v2.z);
         var nm = Math.sqrt(v1.x * v1.x + v1.y * v1.y + v1.z * v1.z);
         this._n = {x:v1.x / nm,y:v1.y / nm,z:v1.z / nm};
         trace("this._n.x " + this._n.x + ", this._n.y: " + this._n.y + ", this._n.z: " + this._n.z);
         var nx = this._n.x;
         var ny = this._n.y;
         var nz = this._n.z;
         var ax = v2.x;
         var ay = v2.y;
         var az = v2.z;
         var ux = ny * ny * ax - nx * ny * ay - nx * nz * az + nz * nz * ax;
         var uy = nz * nz * ay - ny * nz * az - nx * ny * ax + nx * nx * ay;
         var uz = nx * nx * az - nx * nz * ax - ny * nz * ay + ny * ny * az;
         var un = Math.sqrt(ux * ux + uy * uy + uz * uz);
         this._u = {x:ux / un,y:uy / un,z:uz / un};
      }
      this._p_u = {x:this._p.x + this._u.x,y:this._p.y + this._u.y,z:this._p.z + this._u.z};
      this._p_n = {x:this._p.x + this._n.x,y:this._p.y + this._n.y,z:this._p.z + this._n.z};
   }
};
p.update = function()
{
   var sp = this._sp;
   this.shell._x = sp.x;
   this.shell._y = sp.y;
   switch(this._oType)
   {
      case 0:
         return undefined;
      case 1:
         var sp_o = new Object();
         var c = this._parent._c;
         if(this._sys == 0)
         {
            var opz = this._o.x * c.a6 + this._o.y * c.a7 + this._o.z * c.a8;
            this._parent.WtoSz(this._p_o,sp_o);
         }
         else if(this._sys == 1)
         {
            var opz = this._o.x * c.b6 + this._o.y * c.b7 + this._o.z * c.b8;
            this._parent.CtoSz(this._p_o,sp_o);
         }
         this.shell._yscale = 100 * Math.sqrt(1 - opz * opz / c.r2);
         this.shell._rotation = 180 / Math.PI * Math.atan2(sp_o.y - sp.y,sp_o.x - sp.x) + 90;
         return undefined;
      case 2:
         var c = this._parent._c;
         var sp_u = new Object();
         var sp_n = new Object();
         if(this._sys == 0)
         {
            var npz = (this._n.x * c.a6 + this._n.y * c.a7 + this._n.z * c.a8) / c.r;
            this._parent.WtoSz(this._p_n,sp_n);
            this._parent.WtoSz(this._p_u,sp_u);
         }
         else if(this._sys == 1)
         {
            var npz = (this._n.x * c.b6 + this._n.y * c.b7 + this._n.z * c.b8) / c.r;
            this._parent.CtoSz(this._p_n,sp_n);
            this._parent.CtoSz(this._p_u,sp_u);
         }
         this.shell._yscale = 100 * npz;
         var A = Math.atan2(sp_n.y - sp.y,sp_n.x - sp.x) + Math.PI / 2;
         this.shell._rotation = 180 / Math.PI * A;
         var cA = Math.cos(A);
         var sA = Math.sin(A);
         var x0 = sp_u.x - sp.x;
         var y0 = sp_u.y - sp.y;
         var x1 = cA * x0 + sA * y0;
         var y1 = (- sA) * x0 + cA * y0;
         var x2 = x1;
         var y2 = y1 / npz;
         this.instance._rotation = 180 / Math.PI * Math.atan2(y2,x2) + 90;
         return undefined;
      default:
         return;
   }
};
p.removeObject = function()
{
   var list = this._parent._objectList;
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
   this.shell.removeMovieClip();
   delete this;
};
p.getAlt = function()
{
   if(this._sys == 0)
   {
      return this._alt;
   }
   if(this._sys == 1)
   {
      var hp = new Object();
      this._parent.CtoMH({ra:this._ra * 0.2617993877991494,dec:this._dec * 0.017453292519943295},hp);
      return hp.alt * 57.29577951308232;
   }
};
p.setAlt = function(arg)
{
   if(this._sys == 0)
   {
      this.setPosition({az:this._az,alt:arg,r:this._r});
   }
};
p.getAz = function()
{
   if(this._sys == 0)
   {
      return this._az;
   }
   if(this._sys == 1)
   {
      var hp = new Object();
      this._parent.CtoMH({ra:this._ra * 0.2617993877991494,dec:this._dec * 0.017453292519943295},hp);
      return ((- hp.az) * 57.29577951308232 % 360 + 360) % 360;
   }
   return this._az;
};
p.setAz = function(arg)
{
   if(this._sys == 0)
   {
      this.setPosition({az:arg,alt:this._alt,r:this._r});
   }
};
p.getRA = function()
{
   if(this._sys == 1)
   {
      return this._ra;
   }
   if(this._sys == 0)
   {
      var cp = new Object();
      this._parent.MHtoC({az:(- this._az) * 0.017453292519943295,alt:this._alt * 0.017453292519943295},cp);
      return cp.ra * 57.29577951308232;
   }
};
p.setRA = function(arg)
{
   if(this._sys == 1)
   {
      this.setPosition({ra:arg,dec:this._dec,r:this._r});
   }
};
p.getDec = function()
{
   if(this._sys == 1)
   {
      return this._dec;
   }
   if(this._sys == 0)
   {
      var cp = new Object();
      this._parent.MHtoC({az:(- this._az) * 0.017453292519943295,alt:this._alt * 0.017453292519943295},cp);
      return cp.dec * 57.29577951308232;
   }
};
p.setDec = function(arg)
{
   if(this._sys == 1)
   {
      this.setPosition({ra:this._ra,dec:arg,r:this._r});
   }
};
p.getR = function()
{
   return this._r;
};
p.setR = function(arg)
{
   if(this._sys == 0)
   {
      this.setPosition({alt:this._alt,az:this._az,r:arg});
   }
   else if(this._sys == 1)
   {
      this.setPosition({ra:this._ra,dec:this._dec,r:arg});
   }
};
p.addProperty("alt",p.getAlt,p.setAlt);
p.addProperty("az",p.getAz,p.setAz);
p.addProperty("ra",p.getRA,p.setRA);
p.addProperty("dec",p.getDec,p.setDec);
p.addProperty("r",p.getR,p.setR);
