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
      this.visible = false;
   }
   else
   {
      this.setPosition(position);
      this.visible = true;
   }
}
var p = CelestialSphereClass.prototype;
p.addObject = function(linkageName, name, position, initObject)
{
   var _loc3_ = this._objectFreeID++;
   this[name] = new CSObjectsClass(this,name,_loc3_,linkageName,position,initObject);
   this._objectList.push({id:_loc3_,name:this[name]});
   return this[name];
};
p.removeObjects = function()
{
   var _loc3_ = this._objectList;
   var _loc2_ = 0;
   while(_loc2_ < _loc3_.length)
   {
      _loc3_[_loc2_].name.shell.removeMovieClip();
      delete _loc3_[_loc2_].name;
      _loc2_ = _loc2_ + 1;
   }
   this._objectList = [];
   this._objectFreeID = 0;
};
p.updateObjectsNoSort = function()
{
   var _loc13_ = getTimer();
   var _loc7_ = 0;
   var _loc8_ = this._N;
   var _loc12_;
   var _loc11_;
   if(this._phi < 0)
   {
      _loc12_ = 3 * this._N;
      _loc11_ = 2 * this._N;
   }
   else
   {
      _loc12_ = 2 * this._N;
      _loc11_ = 3 * this._N;
   }
   var _loc10_ = 4 * this._N;
   var _loc9_ = 5 * this._N;
   var _loc5_ = !this._showUnder;
   var _loc6_ = this._objectList;
   var _loc4_ = 0;
   var _loc2_;
   var _loc3_;
   for(; _loc4_ < _loc6_.length; _loc4_ = _loc4_ + 1)
   {
      _loc2_ = _loc6_[_loc4_].name;
      if(_loc2_._visible)
      {
         if(_loc2_._r > 1)
         {
            if(_loc5_)
            {
               _loc3_ = {};
               if(_loc2_._sys == 0)
               {
                  _loc3_ = _loc2_._p;
               }
               else if(_loc2_._sys == 1)
               {
                  this.CtoW(_loc2_._p,_loc3_);
               }
               if(_loc3_.z < 0)
               {
                  _loc2_.shell._visible = false;
                  continue;
               }
               _loc2_.shell._visible = true;
               this.WtoSz(_loc3_,_loc2_._sp);
            }
            else
            {
               _loc2_.shell._visible = true;
               if(_loc2_._sys == 0)
               {
                  this.WtoSz(_loc2_._p,_loc2_._sp);
               }
               else if(_loc2_._sys == 1)
               {
                  this.CtoSz(_loc2_._p,_loc2_._sp);
               }
            }
            if(_loc2_._sp.z < 0)
            {
               _loc2_.shell.swapDepths(_loc7_++);
            }
            else
            {
               _loc2_.shell.swapDepths(_loc9_++);
            }
         }
         else if(_loc2_._r < 1)
         {
            _loc3_ = {};
            if(_loc2_._sys == 0)
            {
               _loc3_ = _loc2_._p;
            }
            else if(_loc2_._sys == 1)
            {
               this.CtoW(_loc2_._p,_loc3_);
            }
            if(_loc5_ && _loc3_.z < 0)
            {
               _loc2_.shell._visible = false;
               continue;
            }
            _loc2_.shell._visible = true;
            if(_loc3_.z < 0)
            {
               _loc2_.shell.swapDepths(_loc12_++);
            }
            else
            {
               _loc2_.shell.swapDepths(_loc11_++);
            }
            this.WtoSz(_loc3_,_loc2_._sp);
         }
         else
         {
            if(_loc5_)
            {
               _loc3_ = {};
               if(_loc2_._sys == 0)
               {
                  _loc3_ = _loc2_._p;
               }
               else if(_loc2_._sys == 1)
               {
                  this.CtoW(_loc2_._p,_loc3_);
               }
               if(_loc3_.z < 0)
               {
                  _loc2_.shell._visible = false;
                  continue;
               }
               _loc2_.shell._visible = true;
               this.WtoSz(_loc3_,_loc2_._sp);
            }
            else
            {
               _loc2_.shell._visible = true;
               if(_loc2_._sys == 0)
               {
                  this.WtoSz(_loc2_._p,_loc2_._sp);
               }
               else if(_loc2_._sys == 1)
               {
                  this.CtoSz(_loc2_._p,_loc2_._sp);
               }
            }
            if(_loc2_._sp.z < 0)
            {
               _loc2_.shell.swapDepths(_loc8_++);
            }
            else
            {
               _loc2_.shell.swapDepths(_loc10_++);
            }
         }
         _loc2_.update();
      }
   }
   if(this._traceOn)
   {
      trace("objects: " + (getTimer() - _loc13_) + " ms, (not sorted)");
   }
};
p.updateObjectsSort = function()
{
   var _loc14_ = getTimer();
   var _loc10_ = [];
   var _loc11_ = [];
   var _loc5_ = [];
   var _loc4_ = [];
   var _loc9_ = [];
   var _loc8_ = [];
   var _loc12_ = !this._showUnder;
   var _loc13_ = this._objectList;
   var _loc7_ = 0;
   var _loc2_;
   var _loc6_;
   for(; _loc7_ < _loc13_.length; _loc7_ = _loc7_ + 1)
   {
      _loc2_ = _loc13_[_loc7_].name;
      if(_loc2_._visible)
      {
         if(_loc2_._r > 1)
         {
            if(_loc12_)
            {
               _loc6_ = {};
               if(_loc2_._sys == 0)
               {
                  _loc6_ = _loc2_._p;
               }
               else if(_loc2_._sys == 1)
               {
                  this.CtoW(_loc2_._p,_loc6_);
               }
               if(_loc6_.z < 0)
               {
                  _loc2_.shell._visible = false;
                  continue;
               }
               _loc2_.shell._visible = true;
               this.WtoSz(_loc6_,_loc2_._sp);
            }
            else
            {
               _loc2_.shell._visible = true;
               if(_loc2_._sys == 0)
               {
                  this.WtoSz(_loc2_._p,_loc2_._sp);
               }
               else if(_loc2_._sys == 1)
               {
                  this.CtoSz(_loc2_._p,_loc2_._sp);
               }
            }
            if(_loc2_._sp.z < 0)
            {
               _loc10_.push([_loc2_._sp.z,_loc2_.shell]);
            }
            else
            {
               _loc8_.push([_loc2_._sp.z,_loc2_.shell]);
            }
         }
         else if(_loc2_._r < 1)
         {
            _loc6_ = {};
            if(_loc2_._sys == 0)
            {
               _loc6_ = _loc2_._p;
            }
            else if(_loc2_._sys == 1)
            {
               this.CtoW(_loc2_._p,_loc6_);
            }
            if(_loc12_ && _loc6_.z < 0)
            {
               _loc2_.shell._visible = false;
               continue;
            }
            _loc2_.shell._visible = true;
            this.WtoSz(_loc6_,_loc2_._sp);
            if(_loc6_.z < 0)
            {
               _loc5_.push([_loc2_._sp.z,_loc2_.shell]);
            }
            else
            {
               _loc4_.push([_loc2_._sp.z,_loc2_.shell]);
            }
         }
         else
         {
            if(_loc12_)
            {
               _loc6_ = {};
               if(_loc2_._sys == 0)
               {
                  _loc6_ = _loc2_._p;
               }
               else if(_loc2_._sys == 1)
               {
                  this.CtoW(_loc2_._p,_loc6_);
               }
               if(_loc6_.z < 0)
               {
                  _loc2_.shell._visible = false;
                  continue;
               }
               _loc2_.shell._visible = true;
               this.WtoSz(_loc6_,_loc2_._sp);
            }
            else
            {
               _loc2_.shell._visible = true;
               if(_loc2_._sys == 0)
               {
                  this.WtoSz(_loc2_._p,_loc2_._sp);
               }
               else if(_loc2_._sys == 1)
               {
                  this.CtoSz(_loc2_._p,_loc2_._sp);
               }
            }
            if(_loc2_._sp.z < 0)
            {
               _loc11_.push([_loc2_._sp.z,_loc2_.shell]);
            }
            else
            {
               _loc9_.push([_loc2_._sp.z,_loc2_.shell]);
            }
         }
         _loc2_.update();
      }
   }
   if(!this._hp._visible)
   {
      _loc7_ = _loc4_.length;
      while(_loc7_ > 0)
      {
         _loc5_.push(_loc4_.pop());
         _loc7_ = _loc7_ - 1;
      }
   }
   _loc10_.sort(this.sortRegion);
   _loc11_.sort(this.sortRegion);
   _loc5_.sort(this.sortRegion);
   _loc4_.sort(this.sortRegion);
   _loc9_.sort(this.sortRegion);
   _loc8_.sort(this.sortRegion);
   _loc7_ = 0;
   while(_loc7_ < _loc10_.length)
   {
      _loc10_[_loc7_][1].swapDepths(_loc7_);
      _loc7_ = _loc7_ + 1;
   }
   var _loc3_ = this._N;
   _loc7_ = 0;
   while(_loc7_ < _loc11_.length)
   {
      _loc11_[_loc7_][1].swapDepths(_loc3_ + _loc7_);
      _loc7_ = _loc7_ + 1;
   }
   if(this._phi < 0)
   {
      _loc3_ = 3 * this._N;
      _loc7_ = 0;
      while(_loc7_ < _loc5_.length)
      {
         _loc5_[_loc7_][1].swapDepths(_loc3_ + _loc7_);
         _loc7_ = _loc7_ + 1;
      }
      _loc3_ = 2 * this._N;
      _loc7_ = 0;
      while(_loc7_ < _loc4_.length)
      {
         _loc4_[_loc7_][1].swapDepths(_loc3_ + _loc7_);
         _loc7_ = _loc7_ + 1;
      }
   }
   else
   {
      _loc3_ = 2 * this._N;
      _loc7_ = 0;
      while(_loc7_ < _loc5_.length)
      {
         _loc5_[_loc7_][1].swapDepths(_loc3_ + _loc7_);
         _loc7_ = _loc7_ + 1;
      }
      _loc3_ = 3 * this._N;
      _loc7_ = 0;
      while(_loc7_ < _loc4_.length)
      {
         _loc4_[_loc7_][1].swapDepths(_loc3_ + _loc7_);
         _loc7_ = _loc7_ + 1;
      }
   }
   _loc3_ = 4 * this._N;
   _loc7_ = 0;
   while(_loc7_ < _loc9_.length)
   {
      _loc9_[_loc7_][1].swapDepths(_loc3_ + _loc7_);
      _loc7_ = _loc7_ + 1;
   }
   _loc3_ = 5 * this._N;
   _loc7_ = 0;
   while(_loc7_ < _loc8_.length)
   {
      _loc8_[_loc7_][1].swapDepths(_loc3_ + _loc7_);
      _loc7_ = _loc7_ + 1;
   }
   if(this._traceOn)
   {
      trace("objects: " + (getTimer() - _loc14_) + " ms, (sorted)");
   }
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
p.toString = function()
{
   return String(this._parent) + "." + this._name + " (object)";
};
p.setLinkageName = function(linkageName, initObject)
{
   this.shell.removeMovieClip();
   this._linkageName = linkageName;
   if(typeof initObject != "object")
   {
      this._initObject = {};
      this._initObject._sphere = this._parent;
      this._initObject._object = this;
   }
   else
   {
      this._initObject = initObject;
      this._initObject._sphere = this._parent;
      this._initObject._object = this;
   }
   this.shell = this._parent.createEmptyMovieClip("_obj" + this._id,7 * this._parent._N + this._id);
   this.instance = this.shell.attachMovie(linkageName,"_obj" + this._id,0,this._initObject);
};
p.setPosition = function(arg)
{
   var _loc2_ = {};
   this._parent.parsePointInput(arg,_loc2_);
   if(_loc2_.sys == 0 || _loc2_.sys == -1)
   {
      this._sys = 0;
      this._p = _loc2_;
      this._r = _loc2_.r;
   }
   else if(_loc2_.sys == 1)
   {
      this._sys = 1;
      this._p = _loc2_;
      this._r = _loc2_.r;
   }
   this._p_o = {x:this._p.x + this._o.x,y:this._p.y + this._o.y,z:this._p.z + this._o.z};
   this._p_n = {x:this._p.x + this._n.x,y:this._p.y + this._n.y,z:this._p.z + this._n.z};
   this._p_u = {x:this._p.x + this._u.x,y:this._p.y + this._u.y,z:this._p.z + this._u.z};
};
p.getPosition = function(arg)
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
};
p.setOrientationType = function(type, arg2, arg3)
{
   var _loc15_;
   var _loc2_;
   var _loc18_;
   var _loc14_;
   var _loc16_;
   var _loc3_;
   var _loc4_;
   var _loc7_;
   var _loc6_;
   var _loc5_;
   var _loc10_;
   var _loc9_;
   var _loc8_;
   var _loc13_;
   var _loc12_;
   var _loc11_;
   var _loc17_;
   if(type == "flat")
   {
      this._oType = 0;
      this.instance._rotation = 0;
      this.shell._rotation = 0;
      this.shell._yscale = 100;
   }
   else if(type == "skewed")
   {
      this.instance._rotation = 0;
      this._oType = 1;
      if(typeof arg2 != "object")
      {
         _loc15_ = Math.sqrt(this._p.x * this._p.x + this._p.y * this._p.y + this._p.z * this._p.z);
         this._o = {x:this._p.x / _loc15_,y:this._p.y / _loc15_,z:this._p.z / _loc15_};
      }
      else
      {
         _loc2_ = new Object();
         this._parent.parsePointInput(arg2,_loc2_);
         if(_loc2_.sys == 0 && this._sys == 1)
         {
            _loc18_ = new Object();
            this._parent.WtoC(_loc2_,_loc18_);
            _loc2_ = _loc18_;
         }
         else if(_loc2_.sys == 1 && this._sys == 0)
         {
            _loc18_ = new Object();
            this._parent.CtoW(_loc2_,_loc18_);
            _loc2_ = _loc18_;
         }
         else if(_loc2_.sys == null)
         {
            return undefined;
         }
         _loc15_ = Math.sqrt(_loc2_.x * _loc2_.x + _loc2_.y * _loc2_.y + _loc2_.z * _loc2_.z);
         this._o = {x:_loc2_.x / _loc15_,y:_loc2_.y / _loc15_,z:_loc2_.z / _loc15_};
      }
      this._p_o = {x:this._p.x + this._o.x,y:this._p.y + this._o.y,z:this._p.z + this._o.z};
   }
   else if(type == "absolute")
   {
      this._oType = 2;
      if(typeof arg2 != "object" || typeof arg3 != "object")
      {
         _loc14_ = Math.sqrt(this._p.x * this._p.x + this._p.y * this._p.y + this._p.z * this._p.z);
         this._n = {x:this._p.x / _loc14_,y:this._p.y / _loc14_,z:this._p.z / _loc14_};
         if(!(this._n.x == 0 && this._n.y == 0))
         {
            this._u = {x:(- this._n.x) * this._n.z,y:(- this._n.z) * this._n.y,z:this._n.x * this._n.x + this._n.y * this._n.y};
            _loc16_ = Math.sqrt(this._u.x * this._u.x + this._u.y * this._u.y + this._u.z * this._u.z);
            this._u = {x:this._u.x / _loc16_,y:this._u.y / _loc16_,z:this._u.z / _loc16_};
         }
         else
         {
            this._u = {x:0,y:1,z:0};
         }
      }
      else
      {
         _loc3_ = new Object();
         this._parent.parsePointInput(arg2,_loc3_);
         if(_loc3_.sys == 0 && this._sys == 1)
         {
            _loc18_ = new Object();
            this._parent.WtoC(_loc3_,_loc18_);
            _loc3_ = _loc18_;
         }
         else if(_loc3_.sys == 1 && this._sys == 0)
         {
            _loc18_ = new Object();
            this._parent.CtoW(_loc3_,_loc18_);
            _loc3_ = _loc18_;
         }
         else if(_loc3_.sys == null)
         {
            return undefined;
         }
         _loc4_ = new Object();
         this._parent.parsePointInput(arg3,_loc4_);
         if(_loc4_.sys == 0 && this._sys == 1)
         {
            _loc18_ = new Object();
            this._parent.WtoC(_loc4_,_loc18_);
            _loc4_ = _loc18_;
         }
         else if(_loc4_.sys == 1 && this._sys == 0)
         {
            _loc18_ = new Object();
            this._parent.CtoW(_loc4_,_loc18_);
            _loc4_ = _loc18_;
         }
         else if(_loc4_.sys == null)
         {
            return undefined;
         }
         _loc14_ = Math.sqrt(_loc3_.x * _loc3_.x + _loc3_.y * _loc3_.y + _loc3_.z * _loc3_.z);
         this._n = {x:_loc3_.x / _loc14_,y:_loc3_.y / _loc14_,z:_loc3_.z / _loc14_};
         _loc7_ = this._n.x;
         _loc6_ = this._n.y;
         _loc5_ = this._n.z;
         _loc10_ = _loc4_.x;
         _loc9_ = _loc4_.y;
         _loc8_ = _loc4_.z;
         _loc13_ = _loc6_ * _loc6_ * _loc10_ - _loc7_ * _loc6_ * _loc9_ - _loc7_ * _loc5_ * _loc8_ + _loc5_ * _loc5_ * _loc10_;
         _loc12_ = _loc5_ * _loc5_ * _loc9_ - _loc6_ * _loc5_ * _loc8_ - _loc7_ * _loc6_ * _loc10_ + _loc7_ * _loc7_ * _loc9_;
         _loc11_ = _loc7_ * _loc7_ * _loc8_ - _loc7_ * _loc5_ * _loc10_ - _loc6_ * _loc5_ * _loc9_ + _loc6_ * _loc6_ * _loc8_;
         _loc17_ = Math.sqrt(_loc13_ * _loc13_ + _loc12_ * _loc12_ + _loc11_ * _loc11_);
         this._u = {x:_loc13_ / _loc17_,y:_loc12_ / _loc17_,z:_loc11_ / _loc17_};
      }
      this._p_u = {x:this._p.x + this._u.x,y:this._p.y + this._u.y,z:this._p.z + this._u.z};
      this._p_n = {x:this._p.x + this._n.x,y:this._p.y + this._n.y,z:this._p.z + this._n.z};
   }
};
p.update = function()
{
   var _loc3_ = this._sp;
   this.shell._x = _loc3_.x;
   this.shell._y = _loc3_.y;
   var _loc4_;
   var _loc2_;
   var _loc11_;
   var _loc6_;
   var _loc5_;
   var _loc10_;
   var _loc7_;
   var _loc13_;
   var _loc12_;
   var _loc9_;
   var _loc8_;
   var _loc17_;
   var _loc15_;
   var _loc16_;
   var _loc14_;
   switch(this._oType)
   {
      case 0:
         return undefined;
      case 1:
         _loc4_ = new Object();
         _loc2_ = this._parent._c;
         if(this._sys == 0)
         {
            _loc11_ = this._o.x * _loc2_.a6 + this._o.y * _loc2_.a7 + this._o.z * _loc2_.a8;
            this._parent.WtoSz(this._p_o,_loc4_);
         }
         else if(this._sys == 1)
         {
            _loc11_ = this._o.x * _loc2_.b6 + this._o.y * _loc2_.b7 + this._o.z * _loc2_.b8;
            this._parent.CtoSz(this._p_o,_loc4_);
         }
         this.shell._yscale = 100 * Math.sqrt(1 - _loc11_ * _loc11_ / _loc2_.r2);
         this.shell._rotation = 57.29577951308232 * Math.atan2(_loc4_.y - _loc3_.y,_loc4_.x - _loc3_.x) + 90;
         return undefined;
      case 2:
         _loc2_ = this._parent._c;
         _loc6_ = new Object();
         _loc5_ = new Object();
         if(this._sys == 0)
         {
            _loc10_ = (this._n.x * _loc2_.a6 + this._n.y * _loc2_.a7 + this._n.z * _loc2_.a8) / _loc2_.r;
            this._parent.WtoSz(this._p_n,_loc5_);
            this._parent.WtoSz(this._p_u,_loc6_);
         }
         else if(this._sys == 1)
         {
            _loc10_ = (this._n.x * _loc2_.b6 + this._n.y * _loc2_.b7 + this._n.z * _loc2_.b8) / _loc2_.r;
            this._parent.CtoSz(this._p_n,_loc5_);
            this._parent.CtoSz(this._p_u,_loc6_);
         }
         this.shell._yscale = 100 * _loc10_;
         _loc7_ = Math.atan2(_loc5_.y - _loc3_.y,_loc5_.x - _loc3_.x) + 1.5707963267948966;
         this.shell._rotation = 57.29577951308232 * _loc7_;
         _loc13_ = Math.cos(_loc7_);
         _loc12_ = Math.sin(_loc7_);
         _loc9_ = _loc6_.x - _loc3_.x;
         _loc8_ = _loc6_.y - _loc3_.y;
         _loc17_ = _loc13_ * _loc9_ + _loc12_ * _loc8_;
         _loc15_ = (- _loc12_) * _loc9_ + _loc13_ * _loc8_;
         _loc16_ = _loc17_;
         _loc14_ = _loc15_ / _loc10_;
         this.instance._rotation = 57.29577951308232 * Math.atan2(_loc14_,_loc16_) + 90;
         return undefined;
      default:
         return;
   }
};
p.remove = function()
{
   var _loc3_ = this._parent._objectList;
   var _loc2_ = 0;
   while(_loc2_ < _loc3_.length)
   {
      if(_loc3_[_loc2_].id == this._id)
      {
         break;
      }
      _loc2_ = _loc2_ + 1;
   }
   _loc3_.splice(_loc2_,1);
   this.shell.removeMovieClip();
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
   var _loc2_ = {};
   this._parent.pointToHorizon(this._p,_loc2_);
   return _loc2_.alt;
};
p.setAlt = function(arg)
{
   var _loc2_ = {};
   this._parent.pointToHorizon(this._p,_loc2_);
   _loc2_.alt = arg;
   this.setPosition(_loc2_);
};
p.getAz = function()
{
   var _loc2_ = {};
   this._parent.pointToHorizon(this._p,_loc2_);
   return _loc2_.az;
};
p.setAz = function(arg)
{
   var _loc2_ = {};
   this._parent.pointToHorizon(this._p,_loc2_);
   _loc2_.az = arg;
   this.setPosition(_loc2_);
};
p.getRa = function()
{
   var _loc2_ = {};
   this._parent.pointToCelestial(this._p,_loc2_);
   return _loc2_.ra;
};
p.setRa = function(arg)
{
   var _loc2_ = {};
   this._parent.pointToCelestial(this._p,_loc2_);
   _loc2_.ra = arg;
   this.setPosition(_loc2_);
};
p.getDec = function()
{
   var _loc2_ = {};
   this._parent.pointToCelestial(this._p,_loc2_);
   return _loc2_.dec;
};
p.setDec = function(arg)
{
   var _loc2_ = {};
   this._parent.pointToCelestial(this._p,_loc2_);
   _loc2_.dec = arg;
   this.setPosition(_loc2_);
};
p.getR = function()
{
   return this._r;
};
p.setR = function(arg)
{
   var _loc2_ = arg / this._r;
   this._p.x *= _loc2_;
   this._p.y *= _loc2_;
   this._p.z *= _loc2_;
   this._r = arg;
   this._p_o = {x:this._p.x + this._o.x,y:this._p.y + this._o.y,z:this._p.z + this._o.z};
   this._p_n = {x:this._p.x + this._n.x,y:this._p.y + this._n.y,z:this._p.z + this._n.z};
   this._p_u = {x:this._p.x + this._u.x,y:this._p.y + this._u.y,z:this._p.z + this._u.z};
};
p.getVisible = function()
{
   return this._visible;
};
p.setVisible = function(arg)
{
   this._visible = Boolean(arg);
   if(!this._visible)
   {
      this.shell._visible = false;
   }
};
p.addProperty("alt",p.getAlt,p.setAlt);
p.addProperty("az",p.getAz,p.setAz);
p.addProperty("ra",p.getRa,p.setRa);
p.addProperty("dec",p.getDec,p.setDec);
p.addProperty("r",p.getR,p.setR);
p.addProperty("visible",p.getVisible,p.setVisible);
