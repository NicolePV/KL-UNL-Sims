function Slider2Class()
{
   this.grabber.min_x = -80;
   this.grabber.max_x = 80;
   this.setMinValue(this.init_min);
   this.setMaxValue(this.init_max);
   this.setValue(this.init_value);
   this.setTitle(this.init_title);
}
var p = Slider2Class.prototype = new MovieClip();
p.handleChange = function()
{
   this._parent[this.change_func](this._val);
};
p.getValue = function()
{
   return this._val;
};
p.setValue = function()
{
   var tmp = parseFloat(arguments[0]);
   if(isFinite(tmp))
   {
      if(tmp < this._min)
      {
         this._val = this._min;
      }
      else if(tmp > this._max)
      {
         this._val = this._max;
      }
      else
      {
         this._val = tmp;
      }
      this.grabber._x = (this._val - this._min) * this.grabber.px_per_unit + this.grabber.min_x;
   }
};
p.getMinValue = function()
{
   return this._min;
};
p.setMinValue = function()
{
   var tmp = parseFloat(arguments[0]);
   if(isFinite(tmp))
   {
      this._min = tmp;
      this.grabber.px_per_unit = (this.grabber.max_x - this.grabber.min_x) / (this._max - this._min);
      this.grabber._x = (this._val - this._min) * this.grabber.px_per_unit + this.grabber.min_x;
      this.min_text = "Slow";
   }
};
p.getMaxValue = function()
{
   return this._max;
};
p.setMaxValue = function()
{
   var tmp = parseFloat(arguments[0]);
   if(isFinite(tmp))
   {
      this._max = tmp;
      this.grabber.px_per_unit = (this.grabber.max_x - this.grabber.min_x) / (this._max - this._min);
      this.grabber._x = (this._val - this._min) * this.grabber.px_per_unit + this.grabber.min_x;
      this.max_text = "Fast";
   }
};
p.getTitle = function()
{
   return this.box_title;
};
p.setTitle = function()
{
   this.box_title = arguments[0];
};
p.addProperty("value",p.getValue,p.setValue);
p.addProperty("minValue",p.getMinValue,p.setMinValue);
p.addProperty("maxValue",p.getMaxValue,p.setMaxValue);
p.addProperty("title",p.getTitle,p.setTitle);
Object.registerClass("Slider v2",Slider2Class);
