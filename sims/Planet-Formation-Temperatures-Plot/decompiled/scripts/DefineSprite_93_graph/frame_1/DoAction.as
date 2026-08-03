circle_mc.onRollOver = function()
{
   var _loc1_ = this;
   circle_mc._alpha = 100;
   readout_mc._visible = true;
   readout_mc._x = circle_mc._x + 20;
   readout_mc._y = circle_mc._y;
   readout_mc.temp.text = _loc1_._parent._currTemp + " K";
   var _loc2_ = Math.round(100 * _loc1_._parent.findDist(_loc1_._parent._currTemp)) / 100;
   readout_mc.dist.text = _loc2_ + " AU";
};
circle_mc.onRollOut = function()
{
   circle_mc._alpha = 80;
   readout_mc._visible = false;
};
mercury_mc.onRollOver = function()
{
   var _loc2_ = this;
   readout_mc._visible = true;
   readout_mc._x = mercury_mc._x + 10;
   readout_mc._y = mercury_mc._y;
   var _loc1_ = Math.round(_loc2_._parent.findTemp(_loc2_._parent.mercury_d));
   readout_mc.temp.text = _loc1_ + " K";
   readout_mc.dist.text = _loc2_._parent.mercury_d + " AU";
};
mercury_mc.onRollOut = function()
{
   readout_mc._visible = false;
};
venus_mc.onRollOver = function()
{
   var _loc2_ = this;
   readout_mc._visible = true;
   readout_mc._x = venus_mc._x + 15;
   readout_mc._y = venus_mc._y;
   var _loc1_ = Math.round(_loc2_._parent.findTemp(_loc2_._parent.venus_d));
   readout_mc.temp.text = _loc1_ + " K";
   readout_mc.dist.text = _loc2_._parent.venus_d + " AU";
};
venus_mc.onRollOut = function()
{
   readout_mc._visible = false;
};
earth_mc.onRollOver = function()
{
   var _loc2_ = this;
   readout_mc._visible = true;
   readout_mc._x = earth_mc._x + 15;
   readout_mc._y = earth_mc._y;
   var _loc1_ = Math.round(_loc2_._parent.findTemp(_loc2_._parent.earth_d));
   readout_mc.temp.text = _loc1_ + " K";
   readout_mc.dist.text = _loc2_._parent.earth_d + " AU";
};
earth_mc.onRollOut = function()
{
   readout_mc._visible = false;
};
mars_mc.onRollOver = function()
{
   var _loc2_ = this;
   readout_mc._visible = true;
   readout_mc._x = mars_mc._x + 10;
   readout_mc._y = mars_mc._y;
   var _loc1_ = Math.round(_loc2_._parent.findTemp(_loc2_._parent.mars_d));
   readout_mc.temp.text = _loc1_ + " K";
   readout_mc.dist.text = _loc2_._parent.mars_d + " AU";
};
mars_mc.onRollOut = function()
{
   readout_mc._visible = false;
};
jupiter_mc.onRollOver = function()
{
   var _loc2_ = this;
   readout_mc._visible = true;
   readout_mc._x = jupiter_mc._x + 20;
   readout_mc._y = jupiter_mc._y;
   var _loc1_ = Math.round(_loc2_._parent.findTemp(_loc2_._parent.jupiter_d));
   readout_mc.temp.text = _loc1_ + " K";
   readout_mc.dist.text = _loc2_._parent.jupiter_d + " AU";
};
jupiter_mc.onRollOut = function()
{
   readout_mc._visible = false;
};
saturn_mc.onRollOver = function()
{
   var _loc2_ = this;
   readout_mc._visible = true;
   readout_mc._x = saturn_mc._x + 20;
   readout_mc._y = saturn_mc._y;
   var _loc1_ = Math.round(_loc2_._parent.findTemp(_loc2_._parent.saturn_d));
   readout_mc.temp.text = _loc1_ + " K";
   readout_mc.dist.text = _loc2_._parent.saturn_d + " AU";
};
saturn_mc.onRollOut = function()
{
   readout_mc._visible = false;
};
uranus_mc.onRollOver = function()
{
   var _loc2_ = this;
   readout_mc._visible = true;
   readout_mc._x = uranus_mc._x + 15;
   readout_mc._y = uranus_mc._y;
   var _loc1_ = Math.round(_loc2_._parent.findTemp(_loc2_._parent.uranus_d));
   readout_mc.temp.text = _loc1_ + " K";
   readout_mc.dist.text = _loc2_._parent.uranus_d + " AU";
};
uranus_mc.onRollOut = function()
{
   readout_mc._visible = false;
};
neptune_mc.onRollOver = function()
{
   var _loc2_ = this;
   readout_mc._visible = true;
   readout_mc._x = neptune_mc._x + 20;
   readout_mc._y = neptune_mc._y;
   var _loc1_ = Math.round(_loc2_._parent.findTemp(_loc2_._parent.neptune_d));
   readout_mc.temp.text = _loc1_ + " K";
   readout_mc.dist.text = _loc2_._parent.neptune_d + " AU";
};
neptune_mc.onRollOut = function()
{
   readout_mc._visible = false;
};
pluto_mc.onRollOver = function()
{
   var _loc2_ = this;
   readout_mc._visible = true;
   readout_mc._x = pluto_mc._x + 10;
   readout_mc._y = pluto_mc._y;
   var _loc1_ = Math.round(_loc2_._parent.findTemp(_loc2_._parent.pluto_d));
   readout_mc.temp.text = _loc1_ + " K";
   readout_mc.dist.text = _loc2_._parent.pluto_d + " AU";
};
pluto_mc.onRollOut = function()
{
   readout_mc._visible = false;
};
