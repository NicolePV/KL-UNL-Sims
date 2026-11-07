function histogramClass()
{
   this._w = this.init_width;
   this._h = this.init_height;
   this._no_bins = this.init_no_bins;
   this._max = this.init_max;
   this._min = this.init_min;
   this._create_bin_mcs();
   this._counts_array = new Array();
   var _loc2_ = 0;
   while(_loc2_ < this._no_bins)
   {
      this._counts_array[_loc2_] = 0;
      _loc2_ = _loc2_ + 1;
   }
   this._bin_size = (this._max - this._min) / this._no_bins;
}
var p = histogramClass.prototype = new MovieClip();
Object.registerClass("histogramSymbol",histogramClass);
p._scale_bins = function()
{
   var _loc4_ = 0;
   var _loc2_ = 0;
   while(_loc2_ < this._no_bins)
   {
      if(this._counts_array[_loc2_] > _loc4_)
      {
         _loc4_ = this._counts_array[_loc2_];
      }
      _loc2_ = _loc2_ + 1;
   }
   if(_loc4_ == 0)
   {
      _loc2_ = 0;
      while(_loc2_ < this._no_bins)
      {
         this["_bin" + _loc2_]._visible = false;
         _loc2_ = _loc2_ + 1;
      }
      return undefined;
   }
   _loc2_ = 0;
   var _loc3_;
   var _loc5_;
   while(_loc2_ < this._no_bins)
   {
      _loc3_ = this._w * (this._counts_array[_loc2_] / _loc4_);
      _loc5_ = this._counts_array[_loc2_];
      if(_loc3_ == 0)
      {
         this["_bin" + _loc2_]._visible = false;
      }
      else
      {
         this["_bin" + _loc2_]._visible = true;
         this["_bin" + _loc2_]._xscale = _loc3_;
      }
      _loc2_ = _loc2_ + 1;
   }
};
p.addMeasurement = function(m)
{
   if(m < this._min || m > this._max || !isFinite(m))
   {
      return undefined;
   }
   var _loc2_ = Math.floor((m - this._min) / this._bin_size);
   if(_loc2_ == this._no_bins)
   {
      _loc2_ = _loc2_ - 1;
   }
   this._counts_array[_loc2_]++;
   this._scale_bins();
};
p.clearMeasurements = function()
{
   var _loc2_ = 0;
   while(_loc2_ < this._no_bins)
   {
      this._counts_array[_loc2_] = 0;
      _loc2_ = _loc2_ + 1;
   }
   this._scale_bins();
};
p._create_bin_mcs = function()
{
   this.createEmptyMovieClip("_proto_mc",1);
   var _loc4_ = this._h / this._no_bins;
   this._proto_mc.lineStyle(1,16711680,0);
   this._proto_mc.beginFill(10267051,100);
   this._proto_mc.moveTo(0,0);
   this._proto_mc.lineTo(100,0);
   this._proto_mc.lineTo(100,- _loc4_);
   this._proto_mc.lineTo(0,- _loc4_);
   this._proto_mc.lineTo(0,0);
   this._proto_mc._visible = false;
   this.lineStyle(1,0,100);
   this.moveTo(0,0);
   this.lineTo(0,- this._h);
   var _loc2_ = 0;
   var _loc3_;
   while(_loc2_ < this._no_bins)
   {
      _loc3_ = "_bin" + _loc2_;
      duplicateMovieClip(this._proto_mc,_loc3_,16384 + (10 + _loc2_));
      this[_loc3_]._x = 0;
      this[_loc3_]._y = (- _loc2_) * _loc4_;
      this[_loc3_]._visible = false;
      _loc2_ = _loc2_ + 1;
   }
};
