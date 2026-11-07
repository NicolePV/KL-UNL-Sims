function CSLinesClass(parent, name, id, style, head, tail, depth)
{
   var _loc1_ = this;
   var _loc2_ = depth;
   var _loc3_ = style;
   _loc1_._parent = parent;
   _loc1_._name = name;
   _loc1_._id = id;
   _loc1_.setStyle(1,255,100);
   if(typeof _loc3_ == "object")
   {
      _loc1_.setStyle(_loc3_.thickness,_loc3_.color,_loc3_.alpha);
   }
   _loc1_._visible = true;
   _loc1_._head = new Object();
   _loc1_._tail = new Object();
   _loc1_.setPoints(head,tail);
   _loc1_._bE = _loc1_._parent._bEL.createEmptyMovieClip("_" + _loc2_,_loc2_);
   _loc1_._fE = _loc1_._parent._fEL.createEmptyMovieClip("_" + _loc2_,_loc2_);
   _loc1_._aI = _loc1_._parent._iLA.createEmptyMovieClip("_" + _loc2_,_loc2_);
   _loc1_._bI = _loc1_._parent._iLB.createEmptyMovieClip("_" + _loc2_,_loc2_);
}
var p = CelestialSphereClass.prototype;
p.addLine = function(name, style, head, tail, depth)
{
   var _loc1_ = depth;
   var _loc2_ = this;
   if(_loc1_ == undefined)
   {
      _loc1_ = 0;
      while(_loc2_._fEL["_" + _loc1_] != undefined)
      {
         _loc1_ = _loc1_ + 1;
      }
   }
   var id = _loc2_._lineFreeID++;
   _loc2_[name] = new CSLinesClass(_loc2_,name,id,style,head,tail,_loc1_);
   _loc2_._lineList.push({id:id,name:_loc2_[name]});
};
p.updateLines = function(notHorizon)
{
   var _loc3_ = this;
   var start = getTimer();
   var _loc2_;
   var _loc1_;
   if(notHorizon)
   {
      _loc2_ = 0;
      while(_loc2_ < _loc3_._lineList.length)
      {
         _loc1_ = _loc3_._lineList[_loc2_].name;
         if(_loc1_._head.sys != 0 || _loc1_._tail.sys != 0)
         {
            _loc1_.update();
         }
         _loc2_ = _loc2_ + 1;
      }
   }
   else
   {
      _loc2_ = 0;
      while(_loc2_ < _loc3_._lineList.length)
      {
         _loc3_._lineList[_loc2_].name.update();
         _loc2_ = _loc2_ + 1;
      }
   }
   if(_loc3_._traceOn)
   {
      trace("lines: " + (getTimer() - start) + " ms");
   }
};
p.showLines = function()
{
   var _loc2_ = this._lineList;
   var _loc1_ = 0;
   while(_loc1_ < _loc2_.length)
   {
      _loc2_[_loc1_].name.visible = true;
      _loc1_ = _loc1_ + 1;
   }
};
p.hideLines = function()
{
   var _loc2_ = this._lineList;
   var _loc1_ = 0;
   while(_loc1_ < _loc2_.length)
   {
      _loc2_[_loc1_].name.visible = false;
      _loc1_ = _loc1_ + 1;
   }
};
p.removeLines = function()
{
   var _loc3_ = this;
   var _loc2_ = _loc3_._lineList;
   var _loc1_ = 0;
   while(_loc1_ < _loc2_.length)
   {
      _loc2_[_loc1_].name._bE.removeMovieClip();
      _loc2_[_loc1_].name._fE.removeMovieClip();
      _loc2_[_loc1_].name._aI.removeMovieClip();
      _loc2_[_loc1_].name._bI.removeMovieClip();
      delete _loc3_[_loc2_[_loc1_].name._name];
      _loc1_ = _loc1_ + 1;
   }
   _loc3_._lineFreeID = 0;
   _loc3_._lineList = [];
};
var p = CSLinesClass.prototype = new Object();
p.toString = function()
{
   return String(this._parent) + "." + this._name + " (line)";
};
p.update = function()
{
   var bE = this._bE;
   var fE = this._fE;
   var aI = this._aI;
   var bI = this._bI;
   bE.clear();
   fE.clear();
   aI.clear();
   bI.clear();
   var _loc1_;
   var _loc3_;
   var _loc2_;
   if(this._visible)
   {
      var head = {};
      _loc1_ = {};
      if(this._head.sys == 0)
      {
         this._parent.WtoSz(this._head,head);
      }
      else if(this._head.sys == 1)
      {
         this._parent.CtoSz(this._head,head);
      }
      else
      {
         return;
      }
      if(this._tail.sys == 0)
      {
         this._parent.WtoSz(this._tail,_loc1_);
      }
      else if(this._tail.sys == 1)
      {
         this._parent.CtoSz(this._tail,_loc1_);
      }
      else
      {
         return;
      }
      var mx = head.x - _loc1_.x;
      var my = head.y - _loc1_.y;
      _loc3_ = head.z - _loc1_.z;
      var A = mx * mx + my * my + _loc3_ * _loc3_;
      var B = 2 * (mx * _loc1_.x + my * _loc1_.y + _loc3_ * _loc1_.z);
      var C = _loc1_.x * _loc1_.x + _loc1_.y * _loc1_.y + _loc1_.z * _loc1_.z;
      var rad = this._parent._c.r;
      var rad2 = rad * rad;
      var phi = this._parent._phi;
      var stmp = [];
      var D = B * B - 4 * A * (C - rad2);
      if(D > 0)
      {
         var sD = Math.sqrt(D);
         stmp.push((- B + sD) / (2 * A));
         stmp.push((- B - sD) / (2 * A));
      }
      if(phi > -1.5707963267948966 && phi < 1.5707963267948966)
      {
         var tp = Math.tan(phi);
         if(my != tp * _loc3_)
         {
            stmp.push((tp * _loc1_.z - _loc1_.y) / (my - tp * _loc3_));
         }
         if(_loc3_ != 0)
         {
            var tmp = (- _loc1_.z) / _loc3_;
            if(tmp * (tmp * A + B) + C >= rad2)
            {
               stmp.push(tmp);
            }
         }
      }
      else if(_loc3_ != 0)
      {
         stmp.push((- _loc1_.z) / _loc3_);
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
      if(this._parent._showUnder)
      {
         var i = 0;
         while(i < s.length - 1)
         {
            var s1 = s[i];
            var s2 = s[i + 1];
            var mc;
            _loc2_ = s1 + (s2 - s1) / 2;
            var r2 = _loc2_ * (_loc2_ * A + B) + C;
            if(r2 < rad2)
            {
               if(phi == -1.5707963267948966)
               {
                  if(_loc2_ * _loc3_ + _loc1_.z > 0)
                  {
                     mc = bI;
                  }
                  else
                  {
                     mc = aI;
                  }
               }
               else if(phi == 1.5707963267948966)
               {
                  if(_loc2_ * _loc3_ + _loc1_.z > 0)
                  {
                     mc = aI;
                  }
                  else
                  {
                     mc = bI;
                  }
               }
               else if(_loc2_ * my + _loc1_.y - (_loc2_ * _loc3_ + _loc1_.z) * tp > 1e-9)
               {
                  mc = bI;
               }
               else
               {
                  mc = aI;
               }
            }
            else if(_loc2_ * _loc3_ + _loc1_.z < 0)
            {
               mc = bE;
            }
            else
            {
               mc = fE;
            }
            mc.lineStyle(this._thick,this._color,this._alpha);
            mc.moveTo(s1 * mx + _loc1_.x,s1 * my + _loc1_.y);
            mc.lineTo(s2 * mx + _loc1_.x,s2 * my + _loc1_.y);
            i++;
         }
      }
      else
      {
         var i = 0;
         for(; i < s.length - 1; i++)
         {
            var s1 = s[i];
            var s2 = s[i + 1];
            var mc;
            _loc2_ = s1 + (s2 - s1) / 2;
            var r2 = _loc2_ * (_loc2_ * A + B) + C;
            if(r2 < rad2)
            {
               if(phi == -1.5707963267948966)
               {
                  if(_loc2_ * _loc3_ + _loc1_.z > 0)
                  {
                     continue;
                  }
                  mc = aI;
               }
               else if(phi == 1.5707963267948966)
               {
                  if(_loc2_ * _loc3_ + _loc1_.z <= 0)
                  {
                     continue;
                  }
                  mc = aI;
               }
               else
               {
                  if(_loc2_ * my + _loc1_.y - (_loc2_ * _loc3_ + _loc1_.z) * tp > 1e-9)
                  {
                     continue;
                  }
                  mc = aI;
               }
            }
            else if(phi == -1.5707963267948966)
            {
               if(_loc2_ * _loc3_ + _loc1_.z > 0)
               {
                  continue;
               }
               mc = bE;
            }
            else if(phi == 1.5707963267948966)
            {
               if(_loc2_ * _loc3_ + _loc1_.z <= 0)
               {
                  continue;
               }
               mc = fE;
            }
            else
            {
               if(_loc2_ * my + _loc1_.y - (_loc2_ * _loc3_ + _loc1_.z) * tp > 1e-9)
               {
                  continue;
               }
               if(_loc2_ * _loc3_ + _loc1_.z < 0)
               {
                  mc = bE;
               }
               else
               {
                  mc = fE;
               }
            }
            mc.lineStyle(this._thick,this._color,this._alpha);
            mc.moveTo(s1 * mx + _loc1_.x,s1 * my + _loc1_.y);
            mc.lineTo(s2 * mx + _loc1_.x,s2 * my + _loc1_.y);
         }
      }
   }
};
p.remove = function()
{
   var _loc3_ = this;
   var _loc2_ = _loc3_._parent._lineList;
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
   _loc3_._bE.removeMovieClip();
   _loc3_._fE.removeMovieClip();
   _loc3_._aI.removeMovieClip();
   _loc3_._bI.removeMovieClip();
   delete _loc3_._parent[_loc3_._name];
};
p.setStyle = function(thickness, lineColor, alpha)
{
   var _loc1_ = this;
   if(thickness != undefined)
   {
      _loc1_._thick = thickness;
   }
   if(lineColor != undefined)
   {
      _loc1_._color = lineColor;
   }
   if(alpha != undefined)
   {
      _loc1_._alpha = alpha;
   }
};
p.setPoints = function(head, tail)
{
   this.setHeadPoint(head);
   this.setTailPoint(tail);
};
p.setTailPoint = function(tail)
{
   var _loc1_ = this;
   _loc1_._parent.parsePointInput(tail,_loc1_._tail);
   if(_loc1_._tail.sys == -1)
   {
      _loc1_._tail.sys = 0;
   }
};
p.setHeadPoint = function(head)
{
   var _loc1_ = this;
   _loc1_._parent.parsePointInput(head,_loc1_._head);
   if(_loc1_._head.sys == -1)
   {
      _loc1_._head.sys = 0;
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
