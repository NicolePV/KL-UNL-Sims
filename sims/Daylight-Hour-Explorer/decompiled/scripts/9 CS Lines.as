function CSLinesClass(parent, name, id, style, head, tail, depth)
{
   this._parent = parent;
   this._name = name;
   this._id = id;
   this.setStyle(1,255,100);
   if(typeof style == "object")
   {
      this.setStyle(style.thickness,style.color,style.alpha);
   }
   this._visible = true;
   this._head = new Object();
   this._tail = new Object();
   this.setPoints(head,tail);
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
         depth = depth + 1;
      }
   }
   var _loc4_ = this._lineFreeID++;
   this[name] = new CSLinesClass(this,name,_loc4_,style,head,tail,depth);
   this._lineList.push({id:_loc4_,name:this[name]});
   return this[name];
};
p.updateLines = function(notHorizon)
{
   var _loc4_ = getTimer();
   var _loc3_;
   var _loc2_;
   if(notHorizon)
   {
      _loc3_ = 0;
      while(_loc3_ < this._lineList.length)
      {
         _loc2_ = this._lineList[_loc3_].name;
         if(_loc2_._head.sys != 0 || _loc2_._tail.sys != 0)
         {
            _loc2_.update();
         }
         _loc3_ = _loc3_ + 1;
      }
   }
   else
   {
      _loc3_ = 0;
      while(_loc3_ < this._lineList.length)
      {
         this._lineList[_loc3_].name.update();
         _loc3_ = _loc3_ + 1;
      }
   }
   if(this._traceOn)
   {
      trace("lines: " + (getTimer() - _loc4_) + " ms");
   }
};
p.showLines = function()
{
   var _loc3_ = this._lineList;
   var _loc2_ = 0;
   while(_loc2_ < _loc3_.length)
   {
      _loc3_[_loc2_].name.visible = true;
      _loc2_ = _loc2_ + 1;
   }
};
p.hideLines = function()
{
   var _loc3_ = this._lineList;
   var _loc2_ = 0;
   while(_loc2_ < _loc3_.length)
   {
      _loc3_[_loc2_].name.visible = false;
      _loc2_ = _loc2_ + 1;
   }
};
p.removeLines = function()
{
   var _loc3_ = this._lineList;
   var _loc2_ = 0;
   while(_loc2_ < _loc3_.length)
   {
      _loc3_[_loc2_].name._bE.removeMovieClip();
      _loc3_[_loc2_].name._fE.removeMovieClip();
      _loc3_[_loc2_].name._aI.removeMovieClip();
      _loc3_[_loc2_].name._bI.removeMovieClip();
      delete this[_loc3_[_loc2_].name._name];
      _loc2_ = _loc2_ + 1;
   }
   this._lineFreeID = 0;
   this._lineList = [];
};
var p = CSLinesClass.prototype = new Object();
p.toString = function()
{
   return String(this._parent) + "." + this._name + " (line)";
};
p.update = function()
{
   var _loc19_ = this._bE;
   var _loc17_ = this._fE;
   var _loc11_ = this._aI;
   var _loc18_ = this._bI;
   _loc19_.clear();
   _loc17_.clear();
   _loc11_.clear();
   _loc18_.clear();
   if(!this._visible)
   {
      return undefined;
   }
   var _loc25_ = {};
   var _loc2_ = {};
   if(this._head.sys == 0)
   {
      this._parent.WtoSz(this._head,_loc25_);
   }
   else
   {
      if(this._head.sys != 1)
      {
         return undefined;
      }
      this._parent.CtoSz(this._head,_loc25_);
   }
   if(this._tail.sys == 0)
   {
      this._parent.WtoSz(this._tail,_loc2_);
   }
   else
   {
      if(this._tail.sys != 1)
      {
         return undefined;
      }
      this._parent.CtoSz(this._tail,_loc2_);
   }
   var _loc15_ = _loc25_.x - _loc2_.x;
   var _loc8_ = _loc25_.y - _loc2_.y;
   var _loc4_ = _loc25_.z - _loc2_.z;
   var _loc21_ = _loc15_ * _loc15_ + _loc8_ * _loc8_ + _loc4_ * _loc4_;
   var _loc20_ = 2 * (_loc15_ * _loc2_.x + _loc8_ * _loc2_.y + _loc4_ * _loc2_.z);
   var _loc23_ = _loc2_.x * _loc2_.x + _loc2_.y * _loc2_.y + _loc2_.z * _loc2_.z;
   var _loc28_ = this._parent._c.r;
   var _loc24_ = _loc28_ * _loc28_;
   var _loc10_ = this._parent._phi;
   var _loc7_ = [];
   var _loc27_ = _loc20_ * _loc20_ - 4 * _loc21_ * (_loc23_ - _loc24_);
   var _loc29_;
   if(_loc27_ > 0)
   {
      _loc29_ = Math.sqrt(_loc27_);
      _loc7_.push((- _loc20_ + _loc29_) / (2 * _loc21_));
      _loc7_.push((- _loc20_ - _loc29_) / (2 * _loc21_));
   }
   var _loc16_;
   var _loc26_;
   if(_loc10_ > -1.5707963267948966 && _loc10_ < 1.5707963267948966)
   {
      _loc16_ = Math.tan(_loc10_);
      if(_loc8_ != _loc16_ * _loc4_)
      {
         _loc7_.push((_loc16_ * _loc2_.z - _loc2_.y) / (_loc8_ - _loc16_ * _loc4_));
      }
      if(_loc4_ != 0)
      {
         _loc26_ = (- _loc2_.z) / _loc4_;
         if(_loc26_ * (_loc26_ * _loc21_ + _loc20_) + _loc23_ >= _loc24_)
         {
            _loc7_.push(_loc26_);
         }
      }
   }
   else if(_loc4_ != 0)
   {
      _loc7_.push((- _loc2_.z) / _loc4_);
   }
   var _loc6_ = [0,1];
   var _loc13_ = 0;
   var _loc9_;
   while(_loc13_ < _loc7_.length)
   {
      if(_loc7_[_loc13_] > 0 && _loc7_[_loc13_] < 1)
      {
         _loc9_ = 1;
         while(_loc7_[_loc13_] > _loc6_[_loc9_])
         {
            _loc9_ = _loc9_ + 1;
         }
         if(_loc7_[_loc13_] != _loc6_[_loc9_])
         {
            _loc6_.splice(_loc9_,0,_loc7_[_loc13_]);
         }
      }
      _loc13_ = _loc13_ + 1;
   }
   var _loc12_;
   var _loc14_;
   var _loc5_;
   var _loc3_;
   var _loc22_;
   if(this._parent._showUnder)
   {
      _loc13_ = 0;
      while(_loc13_ < _loc6_.length - 1)
      {
         _loc12_ = _loc6_[_loc13_];
         _loc14_ = _loc6_[_loc13_ + 1];
         _loc3_ = _loc12_ + (_loc14_ - _loc12_) / 2;
         _loc22_ = _loc3_ * (_loc3_ * _loc21_ + _loc20_) + _loc23_;
         if(_loc22_ < _loc24_)
         {
            if(_loc10_ == -1.5707963267948966)
            {
               if(_loc3_ * _loc4_ + _loc2_.z > 0)
               {
                  _loc5_ = _loc18_;
               }
               else
               {
                  _loc5_ = _loc11_;
               }
            }
            else if(_loc10_ == 1.5707963267948966)
            {
               if(_loc3_ * _loc4_ + _loc2_.z > 0)
               {
                  _loc5_ = _loc11_;
               }
               else
               {
                  _loc5_ = _loc18_;
               }
            }
            else if(_loc3_ * _loc8_ + _loc2_.y - (_loc3_ * _loc4_ + _loc2_.z) * _loc16_ > 1e-9)
            {
               _loc5_ = _loc18_;
            }
            else
            {
               _loc5_ = _loc11_;
            }
         }
         else if(_loc3_ * _loc4_ + _loc2_.z < 0)
         {
            _loc5_ = _loc19_;
         }
         else
         {
            _loc5_ = _loc17_;
         }
         _loc5_.lineStyle(this._thick,this._color,this._alpha);
         _loc5_.moveTo(_loc12_ * _loc15_ + _loc2_.x,_loc12_ * _loc8_ + _loc2_.y);
         _loc5_.lineTo(_loc14_ * _loc15_ + _loc2_.x,_loc14_ * _loc8_ + _loc2_.y);
         _loc13_ = _loc13_ + 1;
      }
   }
   else
   {
      _loc13_ = 0;
      for(; _loc13_ < _loc6_.length - 1; _loc13_ = _loc13_ + 1)
      {
         _loc12_ = _loc6_[_loc13_];
         _loc14_ = _loc6_[_loc13_ + 1];
         _loc3_ = _loc12_ + (_loc14_ - _loc12_) / 2;
         _loc22_ = _loc3_ * (_loc3_ * _loc21_ + _loc20_) + _loc23_;
         if(_loc22_ < _loc24_)
         {
            if(_loc10_ == -1.5707963267948966)
            {
               if(_loc3_ * _loc4_ + _loc2_.z > 0)
               {
                  continue;
               }
               _loc5_ = _loc11_;
            }
            else if(_loc10_ == 1.5707963267948966)
            {
               if(_loc3_ * _loc4_ + _loc2_.z <= 0)
               {
                  continue;
               }
               _loc5_ = _loc11_;
            }
            else
            {
               if(_loc3_ * _loc8_ + _loc2_.y - (_loc3_ * _loc4_ + _loc2_.z) * _loc16_ > 1e-9)
               {
                  continue;
               }
               _loc5_ = _loc11_;
            }
         }
         else if(_loc10_ == -1.5707963267948966)
         {
            if(_loc3_ * _loc4_ + _loc2_.z > 0)
            {
               continue;
            }
            _loc5_ = _loc19_;
         }
         else if(_loc10_ == 1.5707963267948966)
         {
            if(_loc3_ * _loc4_ + _loc2_.z <= 0)
            {
               continue;
            }
            _loc5_ = _loc17_;
         }
         else
         {
            if(_loc3_ * _loc8_ + _loc2_.y - (_loc3_ * _loc4_ + _loc2_.z) * _loc16_ > 1e-9)
            {
               continue;
            }
            if(_loc3_ * _loc4_ + _loc2_.z < 0)
            {
               _loc5_ = _loc19_;
            }
            else
            {
               _loc5_ = _loc17_;
            }
         }
         _loc5_.lineStyle(this._thick,this._color,this._alpha);
         _loc5_.moveTo(_loc12_ * _loc15_ + _loc2_.x,_loc12_ * _loc8_ + _loc2_.y);
         _loc5_.lineTo(_loc14_ * _loc15_ + _loc2_.x,_loc14_ * _loc8_ + _loc2_.y);
      }
   }
};
p.remove = function()
{
   var _loc3_ = this._parent._lineList;
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
   this._bE.removeMovieClip();
   this._fE.removeMovieClip();
   this._aI.removeMovieClip();
   this._bI.removeMovieClip();
   delete this._parent[this._name];
};
p.setStyle = function(thickness, lineColor, alpha)
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
p.setPoints = function(head, tail)
{
   this.setHeadPoint(head);
   this.setTailPoint(tail);
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
p.getVisible = function()
{
   return this._visible;
};
p.setVisible = function(arg)
{
   this._visible = Boolean(arg);
   this.update();
};
p.addProperty("visible",p.getVisible,p.setVisible);
