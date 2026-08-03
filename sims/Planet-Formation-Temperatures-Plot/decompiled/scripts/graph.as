function graphClass()
{
   var _loc1_ = this;
   _loc1_._currTemp = _loc1_._initTemp;
   _loc1_._initAlpha = 60;
   _loc1_.t_pixel_high = _loc1_.twoThous._y;
   _loc1_.t_pixel_low = _loc1_.twenty._y;
   _loc1_.t_high = 2000;
   _loc1_.t_low = 20;
   _loc1_.d_pixel_high = _loc1_.fifty._x;
   _loc1_.d_pixel_low = _loc1_.pointOne._x;
   _loc1_.d_high = 50;
   _loc1_.d_low = 0.1;
   _loc1_.mercury_d = 0.387;
   _loc1_.venus_d = 0.723;
   _loc1_.earth_t = 600;
   _loc1_.earth_d = 1;
   _loc1_.mars_d = 1.524;
   _loc1_.jupiter_t = 175;
   _loc1_.jupiter_d = 5.203;
   _loc1_.saturn_d = 9.529;
   _loc1_.uranus_d = 19.19;
   _loc1_.neptune_d = 30.06;
   _loc1_.pluto_d = 39.53;
   _loc1_.createEmptyMovieClip("myLine",1);
   _loc1_.myLine.lineStyle(3,0,70);
   _loc1_.myLine.moveTo(_loc1_.findX(0.2),_loc1_.findY(_loc1_.findTemp(0.2)));
   _loc1_.myLine.lineTo(_loc1_.findX(65),_loc1_.findY(_loc1_.findTemp(65)));
   _loc1_.attachMovie("mercury","mercury_mc",2);
   _loc1_.place(_loc1_.mercury_mc,_loc1_.mercury_d,_loc1_.findTemp(_loc1_.mercury_d),10,10,_loc1_._initAlpha);
   _loc1_.attachMovie("venus","venus_mc",3);
   _loc1_.place(_loc1_.venus_mc,_loc1_.venus_d,_loc1_.findTemp(_loc1_.venus_d),15,15,_loc1_._initAlpha);
   _loc1_.attachMovie("earth","earth_mc",4);
   _loc1_.place(_loc1_.earth_mc,_loc1_.earth_d,_loc1_.earth_t,15,15,_loc1_._initAlpha);
   _loc1_.attachMovie("mars","mars_mc",5);
   _loc1_.place(_loc1_.mars_mc,_loc1_.mars_d,_loc1_.findTemp(_loc1_.mars_d),10,10,_loc1_._initAlpha);
   _loc1_.attachMovie("jupiter","jupiter_mc",6);
   _loc1_.place(_loc1_.jupiter_mc,_loc1_.jupiter_d,_loc1_.jupiter_t,25,25,_loc1_._initAlpha);
   _loc1_.attachMovie("saturn","saturn_mc",7);
   _loc1_.place(_loc1_.saturn_mc,_loc1_.saturn_d,_loc1_.findTemp(_loc1_.saturn_d),30,41,_loc1_._initAlpha);
   _loc1_.attachMovie("uranus","uranus_mc",8);
   _loc1_.place(_loc1_.uranus_mc,_loc1_.uranus_d,_loc1_.findTemp(_loc1_.uranus_d),20,20,_loc1_._initAlpha);
   _loc1_.attachMovie("neptune","neptune_mc",9);
   _loc1_.place(_loc1_.neptune_mc,_loc1_.neptune_d,_loc1_.findTemp(_loc1_.neptune_d),20,20,_loc1_._initAlpha);
   _loc1_.attachMovie("pluto","pluto_mc",10);
   _loc1_.place(_loc1_.pluto_mc,_loc1_.pluto_d,_loc1_.findTemp(_loc1_.pluto_d),8,8,_loc1_._initAlpha);
   _loc1_.attachMovie("circle","circle_mc",11);
   _loc1_.place(_loc1_.circle_mc,_loc1_.findDist(_loc1_._currTemp),_loc1_._currTemp,40,40,80);
   _loc1_.attachMovie("readout","readout_mc",12);
   _loc1_.readout_mc._visible = false;
}
var p = graphClass.prototype = new MovieClip();
Object.registerClass("graph",graphClass);
p.setTemp = function(arg)
{
   var _loc1_ = this;
   _loc1_._currTemp = arg;
   _loc1_.place(_loc1_.circle_mc,_loc1_.findDist(_loc1_._currTemp),_loc1_._currTemp,40,40);
};
p.place = function(obj, dist, temp, rad1, rad2, alph)
{
   var _loc1_ = obj;
   _loc1_._x = this.findX(dist);
   _loc1_._y = this.findY(temp);
   _loc1_._width = rad1;
   _loc1_._height = rad2;
};
p.findX = function(d)
{
   var _loc1_ = this;
   var _loc2_ = _loc1_.d_pixel_high;
   var low = _loc1_.d_pixel_low;
   var _loc3_ = _loc1_.logBaseTen(_loc1_.d_high);
   var log10_low = _loc1_.logBaseTen(_loc1_.d_low);
   var log10_d = _loc1_.logBaseTen(d);
   var ans = (_loc2_ - low) / (_loc3_ - log10_low) * (log10_d - _loc3_) + _loc2_;
   return ans;
};
p.findY = function(k)
{
   var _loc1_ = this;
   var _loc2_ = _loc1_.t_pixel_high;
   var low = _loc1_.t_pixel_low;
   var _loc3_ = _loc1_.logBaseTen(_loc1_.t_high);
   var log10_low = _loc1_.logBaseTen(_loc1_.t_low);
   var log10_k = _loc1_.logBaseTen(k);
   var ans = (_loc2_ - low) / (_loc3_ - log10_low) * (log10_k - _loc3_) + _loc2_;
   return ans;
};
p.logBaseTen = function(num)
{
   return Math.log(num) / 2.302585092994046;
};
p.findTemp = function(d)
{
   var _loc1_ = this;
   var _loc3_ = (_loc1_.logBaseTen(_loc1_.earth_t) - _loc1_.logBaseTen(_loc1_.jupiter_t)) / (_loc1_.logBaseTen(_loc1_.earth_d) - _loc1_.logBaseTen(_loc1_.jupiter_d));
   var _loc2_ = _loc3_ * (_loc1_.logBaseTen(d) - _loc1_.logBaseTen(_loc1_.earth_d)) + _loc1_.logBaseTen(_loc1_.earth_t);
   return Math.pow(10,_loc2_);
};
p.findDist = function(k)
{
   var _loc1_ = this;
   var _loc3_ = (_loc1_.logBaseTen(_loc1_.earth_t) - _loc1_.logBaseTen(_loc1_.jupiter_t)) / (_loc1_.logBaseTen(_loc1_.earth_d) - _loc1_.logBaseTen(_loc1_.jupiter_d));
   var _loc2_ = (_loc1_.logBaseTen(k) - _loc1_.logBaseTen(_loc1_.earth_t)) / _loc3_ + _loc1_.logBaseTen(_loc1_.earth_d);
   return Math.pow(10,_loc2_);
};
