this.grabber.onPress = function()
{
   this.offset = this._x - this._parent._xmouse;
   this.active = true;
};
this.grabber.onRelease = function()
{
   this.active = false;
};
this.grabber.onReleaseOutside = function()
{
   this.active = false;
};
this.grabber.onMouseMove = function()
{
   if(this.active)
   {
      this._x = this._parent._xmouse + this.offset;
      if(this._x > this.max_x)
      {
         this._x = this.max_x;
      }
      else if(this._x < this.min_x)
      {
         this._x = this.min_x;
      }
      var old_val = this._parent._val;
      this._parent._val = (this._x - this.min_x) / this.px_per_unit + this._parent._min;
      this._parent.label_text = Math.round(100 * this._parent._val) / 100;
      if(this._parent._val != old_val)
      {
         this._parent.handleChange();
      }
      updateAfterEvent();
   }
};
