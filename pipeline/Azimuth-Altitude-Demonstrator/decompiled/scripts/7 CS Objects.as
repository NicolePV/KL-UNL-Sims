function CSObjectsClass(parent, name, id, linkageName, position, initObject)
{
   var _loc1_ = this;
   _loc1_._parent = parent;
   _loc1_._name = name;
   _loc1_._id = id;
   _loc1_._p = new Object();
   _loc1_._sp = new Object();
   _loc1_._o = {x:0,y:0,z:0};
   _loc1_._oType = 0;
   _loc1_.setLinkageName(linkageName,initObject);
   if(typeof position != "object")
   {
      _loc1_.setPosition({alt:0,az:0,r:1});
      _loc1_.visible = false;
   }
   else
   {
      _loc1_.setPosition(position);
      _loc1_.visible = true;
   }
}
var p = CelestialSphereClass.prototype;
p.addObject = function(linkageName, name, position, initObject)
{
   var _loc1_ = this;
   var _loc2_ = name;
   var id = _loc1_._objectFreeID++;
   _loc1_[_loc2_] = new CSObjectsClass(_loc1_,_loc2_,id,linkageName,position,initObject);
   _loc1_._objectList.push({id:id,name:_loc1_[_loc2_]});
   return _loc1_[_loc2_];
};
p.removeObjects = function()
{
   var _loc3_ = this;
   var _loc2_ = _loc3_._objectList;
   var _loc1_ = 0;
   while(_loc1_ < _loc2_.length)
   {
      _loc2_[_loc1_].name.shell.removeMovieClip();
      delete _loc2_[_loc1_].name;
      _loc1_ = _loc1_ + 1;
   }
   _loc3_._objectList = [];
   _loc3_._objectFreeID = 0;
};
p.updateObjectsNoSort = function()
{
   var _loc2_ = this;
   var start = getTimer();
   var bEd = 0;
   var bSd = _loc2_._N;
   if(_loc2_._phi < 0)
   {
      var bId = 3 * _loc2_._N;
      var aId = 2 * _loc2_._N;
   }
   else
   {
      var bId = 2 * _loc2_._N;
      var aId = 3 * _loc2_._N;
   }
   var fSd = 4 * _loc2_._N;
   var fEd = 5 * _loc2_._N;
   var hU = !_loc2_._showUnder;
   var list = _loc2_._objectList;
   var i = 0;
   var _loc1_;
   var _loc3_;
   for(; i < list.length; i++)
   {
      _loc1_ = list[i].name;
      if(_loc1_._visible)
      {
         if(_loc1_._r > 1)
         {
            if(hu)
            {
               _loc3_ = {};
               if(_loc1_._sys == 0)
               {
                  _loc3_ = _loc1_._p;
               }
               else if(_loc1_._sys == 1)
               {
                  _loc2_.CtoW(_loc1_._p,_loc3_);
               }
               if(_loc3_.z < 0)
               {
                  _loc1_.shell._visible = false;
                  continue;
               }
               _loc1_.shell._visible = true;
               _loc2_.WtoSz(_loc3_,_loc1_._sp);
            }
            else
            {
               _loc1_.shell._visible = true;
               if(_loc1_._sys == 0)
               {
                  _loc2_.WtoSz(_loc1_._p,_loc1_._sp);
               }
               else if(_loc1_._sys == 1)
               {
                  _loc2_.CtoSz(_loc1_._p,_loc1_._sp);
               }
            }
            if(_loc1_._sp.z < 0)
            {
               _loc1_.shell.swapDepths(bEd++);
            }
            else
            {
               _loc1_.shell.swapDepths(fEd++);
            }
         }
         else if(_loc1_._r < 1)
         {
            _loc3_ = {};
            if(_loc1_._sys == 0)
            {
               _loc3_ = _loc1_._p;
            }
            else if(_loc1_._sys == 1)
            {
               _loc2_.CtoW(_loc1_._p,_loc3_);
            }
            if(hU && _loc3_.z < 0)
            {
               _loc1_.shell._visible = false;
               continue;
            }
            _loc1_.shell._visible = true;
            if(_loc3_.z < 0)
            {
               _loc1_.shell.swapDepths(bId++);
            }
            else
            {
               _loc1_.shell.swapDepths(aId++);
            }
            _loc2_.WtoSz(_loc3_,_loc1_._sp);
         }
         else
         {
            if(hu)
            {
               _loc3_ = {};
               if(_loc1_._sys == 0)
               {
                  _loc3_ = _loc1_._p;
               }
               else if(_loc1_._sys == 1)
               {
                  _loc2_.CtoW(_loc1_._p,_loc3_);
               }
               if(_loc3_.z < 0)
               {
                  _loc1_.shell._visible = false;
                  continue;
               }
               _loc1_.shell._visible = true;
               _loc2_.WtoSz(_loc3_,_loc1_._sp);
            }
            else
            {
               _loc1_.shell._visible = true;
               if(_loc1_._sys == 0)
               {
                  _loc2_.WtoSz(_loc1_._p,_loc1_._sp);
               }
               else if(_loc1_._sys == 1)
               {
                  _loc2_.CtoSz(_loc1_._p,_loc1_._sp);
               }
            }
            if(_loc1_._sp.z < 0)
            {
               _loc1_.shell.swapDepths(bSd++);
            }
            else
            {
               _loc1_.shell.swapDepths(fSd++);
            }
         }
         _loc1_.update();
      }
   }
   if(_loc2_._traceOn)
   {
      trace("objects: " + (getTimer() - start) + " ms, (not sorted)");
   }
};
p.updateObjectsSort = function()
{
   var _loc2_ = this;
   var start = getTimer();
   var bE = [];
   var bS = [];
   var bI = [];
   var aI = [];
   var fS = [];
   var fE = [];
   var hU = !_loc2_._showUnder;
   var list = _loc2_._objectList;
   var i = 0;
   var _loc1_;
   for(; i < list.length; i++)
   {
      _loc1_ = list[i].name;
      if(_loc1_._visible)
      {
         if(_loc1_._r > 1)
         {
            if(hu)
            {
               var wp = {};
               if(_loc1_._sys == 0)
               {
                  wp = _loc1_._p;
               }
               else if(_loc1_._sys == 1)
               {
                  _loc2_.CtoW(_loc1_._p,wp);
               }
               if(wp.z < 0)
               {
                  _loc1_.shell._visible = false;
                  continue;
               }
               _loc1_.shell._visible = true;
               _loc2_.WtoSz(wp,_loc1_._sp);
            }
            else
            {
               _loc1_.shell._visible = true;
               if(_loc1_._sys == 0)
               {
                  _loc2_.WtoSz(_loc1_._p,_loc1_._sp);
               }
               else if(_loc1_._sys == 1)
               {
                  _loc2_.CtoSz(_loc1_._p,_loc1_._sp);
               }
            }
            if(_loc1_._sp.z < 0)
            {
               bE.push([_loc1_._sp.z,_loc1_.shell]);
            }
            else
            {
               fE.push([_loc1_._sp.z,_loc1_.shell]);
            }
         }
         else if(_loc1_._r < 1)
         {
            var wp = {};
            if(_loc1_._sys == 0)
            {
               wp = _loc1_._p;
            }
            else if(_loc1_._sys == 1)
            {
               _loc2_.CtoW(_loc1_._p,wp);
            }
            if(hU && wp.z < 0)
            {
               _loc1_.shell._visible = false;
               continue;
            }
            _loc1_.shell._visible = true;
            _loc2_.WtoSz(wp,_loc1_._sp);
            if(wp.z < 0)
            {
               bI.push([_loc1_._sp.z,_loc1_.shell]);
            }
            else
            {
               aI.push([_loc1_._sp.z,_loc1_.shell]);
            }
         }
         else
         {
            if(hu)
            {
               var wp = {};
               if(_loc1_._sys == 0)
               {
                  wp = _loc1_._p;
               }
               else if(_loc1_._sys == 1)
               {
                  _loc2_.CtoW(_loc1_._p,wp);
               }
               if(wp.z < 0)
               {
                  _loc1_.shell._visible = false;
                  continue;
               }
               _loc1_.shell._visible = true;
               _loc2_.WtoSz(wp,_loc1_._sp);
            }
            else
            {
               _loc1_.shell._visible = true;
               if(_loc1_._sys == 0)
               {
                  _loc2_.WtoSz(_loc1_._p,_loc1_._sp);
               }
               else if(_loc1_._sys == 1)
               {
                  _loc2_.CtoSz(_loc1_._p,_loc1_._sp);
               }
            }
            if(_loc1_._sp.z < 0)
            {
               bS.push([_loc1_._sp.z,_loc1_.shell]);
            }
            else
            {
               fS.push([_loc1_._sp.z,_loc1_.shell]);
            }
         }
         _loc1_.update();
      }
   }
   if(!_loc2_.showHorizonPlane)
   {
      var i = aI.length;
      while(i > 0)
      {
         bI.push(aI.pop());
         i--;
      }
   }
   bE.sort(_loc2_.sortRegion);
   bS.sort(_loc2_.sortRegion);
   bI.sort(_loc2_.sortRegion);
   aI.sort(_loc2_.sortRegion);
   fS.sort(_loc2_.sortRegion);
   fE.sort(_loc2_.sortRegion);
   var i = 0;
   while(i < bE.length)
   {
      bE[i][1].swapDepths(i);
      i++;
   }
   var _loc3_ = _loc2_._N;
   var i = 0;
   while(i < bS.length)
   {
      bS[i][1].swapDepths(_loc3_ + i);
      i++;
   }
   if(_loc2_._phi < 0)
   {
      _loc3_ = 3 * _loc2_._N;
      var i = 0;
      while(i < bI.length)
      {
         bI[i][1].swapDepths(_loc3_ + i);
         i++;
      }
      _loc3_ = 2 * _loc2_._N;
      var i = 0;
      while(i < aI.length)
      {
         aI[i][1].swapDepths(_loc3_ + i);
         i++;
      }
   }
   else
   {
      _loc3_ = 2 * _loc2_._N;
      var i = 0;
      while(i < bI.length)
      {
         bI[i][1].swapDepths(_loc3_ + i);
         i++;
      }
      _loc3_ = 3 * _loc2_._N;
      var i = 0;
      while(i < aI.length)
      {
         aI[i][1].swapDepths(_loc3_ + i);
         i++;
      }
   }
   _loc3_ = 4 * _loc2_._N;
   var i = 0;
   while(i < fS.length)
   {
      fS[i][1].swapDepths(_loc3_ + i);
      i++;
   }
   _loc3_ = 5 * _loc2_._N;
   var i = 0;
   while(i < fE.length)
   {
      fE[i][1].swapDepths(_loc3_ + i);
      i++;
   }
   if(_loc2_._traceOn)
   {
      trace("objects: " + (getTimer() - start) + " ms, (sorted)");
   }
};
p.sortRegion = function(a, b)
{
   var _loc1_ = b;
   var _loc2_ = a;
   if(_loc2_[0] < _loc1_[0])
   {
      return -1;
   }
   if(_loc2_[0] == _loc1_[0])
   {
      return 0;
   }
   if(_loc2_[0] > _loc1_[0])
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
   var _loc1_ = this;
   if(arg)
   {
      _loc1_.updateObjects = _loc1_.updateObjectsSort;
      _loc1_.updateObjects();
   }
   else
   {
      _loc1_.updateObjects = _loc1_.updateObjectsNoSort;
   }
};
p.addProperty("sortObjects",p.getSortObjects,p.setSortObjects);
var p = CSObjectsClass.prototype = new Object();
p.toString = function()
{
   return String(this._parent) + "." + this._name + " (object)";
};
p.setLinkageName = function(linkageName, initObject)
{
   var _loc1_ = this;
   _loc1_.shell.removeMovieClip();
   _loc1_._linkageName = linkageName;
   if(typeof initObject != "object")
   {
      _loc1_._initObject = {};
      _loc1_._initObject._sphere = _loc1_._parent;
      _loc1_._initObject._object = _loc1_;
   }
   else
   {
      _loc1_._initObject = initObject;
      _loc1_._initObject._sphere = _loc1_._parent;
      _loc1_._initObject._object = _loc1_;
   }
   _loc1_.shell = _loc1_._parent.createEmptyMovieClip("_obj" + _loc1_._id,7 * _loc1_._parent._N + _loc1_._id);
   _loc1_.instance = _loc1_.shell.attachMovie(linkageName,"_obj" + _loc1_._id,0,_loc1_._initObject);
};
p.setPosition = function(arg)
{
   var _loc1_ = this;
   var _loc2_ = {};
   _loc1_._parent.parsePointInput(arg,_loc2_);
   if(_loc2_.sys == 0 || _loc2_.sys == -1)
   {
      _loc1_._sys = 0;
      _loc1_._p = _loc2_;
      _loc1_._r = _loc2_.r;
   }
   else if(_loc2_.sys == 1)
   {
      _loc1_._sys = 1;
      _loc1_._p = _loc2_;
      _loc1_._r = _loc2_.r;
   }
   _loc1_._p_o = {x:_loc1_._p.x + _loc1_._o.x,y:_loc1_._p.y + _loc1_._o.y,z:_loc1_._p.z + _loc1_._o.z};
   _loc1_._p_n = {x:_loc1_._p.x + _loc1_._n.x,y:_loc1_._p.y + _loc1_._n.y,z:_loc1_._p.z + _loc1_._n.z};
   _loc1_._p_u = {x:_loc1_._p.x + _loc1_._u.x,y:_loc1_._p.y + _loc1_._u.y,z:_loc1_._p.z + _loc1_._u.z};
};
p.getPosition = function(arg)
{
   var _loc1_ = this;
   var _loc2_ = arg;
   _loc2_.x = _loc1_._p.x;
   _loc2_.y = _loc1_._p.y;
   _loc2_.z = _loc1_._p.z;
   if(_loc1_._sys == 0)
   {
      _loc2_.system = "horizon";
   }
   else if(_loc1_._sys == 1)
   {
      _loc2_.system = "celestial";
   }
};
p.setOrientationType = function(type, arg2, arg3)
{
   var _loc1_ = this;
   var _loc2_;
   var _loc3_;
   if(type == "flat")
   {
      _loc1_._oType = 0;
      _loc1_.instance._rotation = 0;
      _loc1_.shell._rotation = 0;
      _loc1_.shell._yscale = 100;
   }
   else if(type == "skewed")
   {
      _loc1_.instance._rotation = 0;
      _loc1_._oType = 1;
      if(typeof arg2 != "object")
      {
         var m = Math.sqrt(_loc1_._p.x * _loc1_._p.x + _loc1_._p.y * _loc1_._p.y + _loc1_._p.z * _loc1_._p.z);
         _loc1_._o = {x:_loc1_._p.x / m,y:_loc1_._p.y / m,z:_loc1_._p.z / m};
      }
      else
      {
         _loc2_ = new Object();
         _loc1_._parent.parsePointInput(arg2,_loc2_);
         if(_loc2_.sys == 0 && _loc1_._sys == 1)
         {
            var tv = new Object();
            _loc1_._parent.WtoC(_loc2_,tv);
            _loc2_ = tv;
         }
         else if(_loc2_.sys == 1 && _loc1_._sys == 0)
         {
            var tv = new Object();
            _loc1_._parent.CtoW(_loc2_,tv);
            _loc2_ = tv;
         }
         else if(_loc2_.sys == null)
         {
            return;
         }
         var m = Math.sqrt(_loc2_.x * _loc2_.x + _loc2_.y * _loc2_.y + _loc2_.z * _loc2_.z);
         _loc1_._o = {x:_loc2_.x / m,y:_loc2_.y / m,z:_loc2_.z / m};
      }
      _loc1_._p_o = {x:_loc1_._p.x + _loc1_._o.x,y:_loc1_._p.y + _loc1_._o.y,z:_loc1_._p.z + _loc1_._o.z};
   }
   else if(type == "absolute")
   {
      _loc1_._oType = 2;
      if(typeof arg2 != "object" || typeof arg3 != "object")
      {
         var nm = Math.sqrt(_loc1_._p.x * _loc1_._p.x + _loc1_._p.y * _loc1_._p.y + _loc1_._p.z * _loc1_._p.z);
         _loc1_._n = {x:_loc1_._p.x / nm,y:_loc1_._p.y / nm,z:_loc1_._p.z / nm};
         if(!(_loc1_._n.x == 0 && _loc1_._n.y == 0))
         {
            _loc1_._u = {x:(- _loc1_._n.x) * _loc1_._n.z,y:(- _loc1_._n.z) * _loc1_._n.y,z:_loc1_._n.x * _loc1_._n.x + _loc1_._n.y * _loc1_._n.y};
            var nu = Math.sqrt(_loc1_._u.x * _loc1_._u.x + _loc1_._u.y * _loc1_._u.y + _loc1_._u.z * _loc1_._u.z);
            _loc1_._u = {x:_loc1_._u.x / nu,y:_loc1_._u.y / nu,z:_loc1_._u.z / nu};
         }
         else
         {
            _loc1_._u = {x:0,y:1,z:0};
         }
      }
      else
      {
         _loc3_ = new Object();
         _loc1_._parent.parsePointInput(arg2,_loc3_);
         if(_loc3_.sys == 0 && _loc1_._sys == 1)
         {
            var tv = new Object();
            _loc1_._parent.WtoC(_loc3_,tv);
            _loc3_ = tv;
         }
         else if(_loc3_.sys == 1 && _loc1_._sys == 0)
         {
            var tv = new Object();
            _loc1_._parent.CtoW(_loc3_,tv);
            _loc3_ = tv;
         }
         else if(_loc3_.sys == null)
         {
            return;
         }
         var v2 = new Object();
         _loc1_._parent.parsePointInput(arg3,v2);
         if(v2.sys == 0 && _loc1_._sys == 1)
         {
            var tv = new Object();
            _loc1_._parent.WtoC(v2,tv);
            v2 = tv;
         }
         else if(v2.sys == 1 && _loc1_._sys == 0)
         {
            var tv = new Object();
            _loc1_._parent.CtoW(v2,tv);
            v2 = tv;
         }
         else if(v2.sys == null)
         {
            return;
         }
         var nm = Math.sqrt(_loc3_.x * _loc3_.x + _loc3_.y * _loc3_.y + _loc3_.z * _loc3_.z);
         _loc1_._n = {x:_loc3_.x / nm,y:_loc3_.y / nm,z:_loc3_.z / nm};
         var nx = _loc1_._n.x;
         var ny = _loc1_._n.y;
         var nz = _loc1_._n.z;
         var ax = v2.x;
         var ay = v2.y;
         var az = v2.z;
         var ux = ny * ny * ax - nx * ny * ay - nx * nz * az + nz * nz * ax;
         var uy = nz * nz * ay - ny * nz * az - nx * ny * ax + nx * nx * ay;
         var uz = nx * nx * az - nx * nz * ax - ny * nz * ay + ny * ny * az;
         var un = Math.sqrt(ux * ux + uy * uy + uz * uz);
         _loc1_._u = {x:ux / un,y:uy / un,z:uz / un};
      }
      _loc1_._p_u = {x:_loc1_._p.x + _loc1_._u.x,y:_loc1_._p.y + _loc1_._u.y,z:_loc1_._p.z + _loc1_._u.z};
      _loc1_._p_n = {x:_loc1_._p.x + _loc1_._n.x,y:_loc1_._p.y + _loc1_._n.y,z:_loc1_._p.z + _loc1_._n.z};
   }
};
p.update = function()
{
   var _loc1_ = this;
   var _loc3_ = _loc1_._sp;
   _loc1_.shell._x = _loc3_.x;
   _loc1_.shell._y = _loc3_.y;
   var _loc2_;
   switch(_loc1_._oType)
   {
      case 0:
      case 1:
         var sp_o = new Object();
         _loc2_ = _loc1_._parent._c;
         if(_loc1_._sys == 0)
         {
            var opz = _loc1_._o.x * _loc2_.a6 + _loc1_._o.y * _loc2_.a7 + _loc1_._o.z * _loc2_.a8;
            _loc1_._parent.WtoSz(_loc1_._p_o,sp_o);
         }
         else if(_loc1_._sys == 1)
         {
            var opz = _loc1_._o.x * _loc2_.b6 + _loc1_._o.y * _loc2_.b7 + _loc1_._o.z * _loc2_.b8;
            _loc1_._parent.CtoSz(_loc1_._p_o,sp_o);
         }
         _loc1_.shell._yscale = 100 * Math.sqrt(1 - opz * opz / _loc2_.r2);
         _loc1_.shell._rotation = 57.29577951308232 * Math.atan2(sp_o.y - _loc3_.y,sp_o.x - _loc3_.x) + 90;
         break;
      case 2:
         _loc2_ = _loc1_._parent._c;
         var sp_u = new Object();
         var sp_n = new Object();
         if(_loc1_._sys == 0)
         {
            var npz = (_loc1_._n.x * _loc2_.a6 + _loc1_._n.y * _loc2_.a7 + _loc1_._n.z * _loc2_.a8) / _loc2_.r;
            _loc1_._parent.WtoSz(_loc1_._p_n,sp_n);
            _loc1_._parent.WtoSz(_loc1_._p_u,sp_u);
         }
         else if(_loc1_._sys == 1)
         {
            var npz = (_loc1_._n.x * _loc2_.b6 + _loc1_._n.y * _loc2_.b7 + _loc1_._n.z * _loc2_.b8) / _loc2_.r;
            _loc1_._parent.CtoSz(_loc1_._p_n,sp_n);
            _loc1_._parent.CtoSz(_loc1_._p_u,sp_u);
         }
         _loc1_.shell._yscale = 100 * npz;
         var A = Math.atan2(sp_n.y - _loc3_.y,sp_n.x - _loc3_.x) + 1.5707963267948966;
         _loc1_.shell._rotation = 57.29577951308232 * A;
         var cA = Math.cos(A);
         var sA = Math.sin(A);
         var x0 = sp_u.x - _loc3_.x;
         var y0 = sp_u.y - _loc3_.y;
         var x1 = cA * x0 + sA * y0;
         var y1 = (- sA) * x0 + cA * y0;
         var x2 = x1;
         var y2 = y1 / npz;
         _loc1_.instance._rotation = 57.29577951308232 * Math.atan2(y2,x2) + 90;
      default:
         return;
   }
};
p.remove = function()
{
   var _loc3_ = this;
   var _loc2_ = _loc3_._parent._objectList;
   var _loc1_ = 0;
   while(_loc1_ < _loc2_.length)
   {
      if(_loc2_[_loc1_].id == _loc3_._id)
      {
         break;
      }
      _loc1_ = _loc1_ + 1;
   }
   _loc2_.splice(_loc1_,1);
   _loc3_.shell.removeMovieClip();
   false;
};
p.getPositionHorizon = function(arg)
{
   this._parent.pointToHorizon(this._p,arg);
};
p.getPositionCelestial = function(arg)
{
   this._parent.pointToCelestial(this._p,arg);
};
p.getAlt = function()
{
   var _loc1_ = {};
   this._parent.pointToHorizon(this._p,_loc1_);
   return _loc1_.alt;
};
p.setAlt = function(arg)
{
   var _loc2_ = this;
   var _loc1_ = {};
   _loc2_._parent.pointToHorizon(_loc2_._p,_loc1_);
   _loc1_.alt = arg;
   _loc2_.setPosition(_loc1_);
};
p.getAz = function()
{
   var _loc1_ = {};
   this._parent.pointToHorizon(this._p,_loc1_);
   return _loc1_.az;
};
p.setAz = function(arg)
{
   var _loc2_ = this;
   var _loc1_ = {};
   _loc2_._parent.pointToHorizon(_loc2_._p,_loc1_);
   _loc1_.az = arg;
   _loc2_.setPosition(_loc1_);
};
p.getRa = function()
{
   var _loc1_ = {};
   this._parent.pointToCelestial(this._p,_loc1_);
   return _loc1_.ra;
};
p.setRa = function(arg)
{
   var _loc2_ = this;
   var _loc1_ = {};
   _loc2_._parent.pointToCelestial(_loc2_._p,_loc1_);
   _loc1_.ra = arg;
   _loc2_.setPosition(_loc1_);
};
p.getDec = function()
{
   var _loc1_ = {};
   this._parent.pointToCelestial(this._p,_loc1_);
   return _loc1_.dec;
};
p.setDec = function(arg)
{
   var _loc2_ = this;
   var _loc1_ = {};
   _loc2_._parent.pointToCelestial(_loc2_._p,_loc1_);
   _loc1_.dec = arg;
   _loc2_.setPosition(_loc1_);
};
p.getR = function()
{
   return this._r;
};
p.setR = function(arg)
{
   var _loc1_ = this;
   var _loc2_ = arg / _loc1_._r;
   _loc1_._p.x *= _loc2_;
   _loc1_._p.y *= _loc2_;
   _loc1_._p.z *= _loc2_;
   _loc1_._r = arg;
   _loc1_._p_o = {x:_loc1_._p.x + _loc1_._o.x,y:_loc1_._p.y + _loc1_._o.y,z:_loc1_._p.z + _loc1_._o.z};
   _loc1_._p_n = {x:_loc1_._p.x + _loc1_._n.x,y:_loc1_._p.y + _loc1_._n.y,z:_loc1_._p.z + _loc1_._n.z};
   _loc1_._p_u = {x:_loc1_._p.x + _loc1_._u.x,y:_loc1_._p.y + _loc1_._u.y,z:_loc1_._p.z + _loc1_._u.z};
};
p.getVisible = function()
{
   return this._visible;
};
p.setVisible = function(arg)
{
   var _loc1_ = this;
   _loc1_._visible = Boolean(arg);
   if(!_loc1_._visible)
   {
      _loc1_.shell._visible = false;
   }
};
p.addProperty("alt",p.getAlt,p.setAlt);
p.addProperty("az",p.getAz,p.setAz);
p.addProperty("ra",p.getRa,p.setRa);
p.addProperty("dec",p.getDec,p.setDec);
p.addProperty("r",p.getR,p.setR);
p.addProperty("visible",p.getVisible,p.setVisible);
