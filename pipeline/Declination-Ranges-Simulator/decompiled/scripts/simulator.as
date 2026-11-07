function latClass()
{
   var _loc1_ = this;
   _loc1_.myEarth._xscale = 20;
   _loc1_.myEarth._yscale = 20;
   _loc1_.myEarth._alpha = 100;
   _loc1_._active = false;
   _loc1_._lat = _loc1_.latSlider.initValue;
   _loc1_.cirColor = _loc1_.cir_label.textColor;
   _loc1_.riseColor = _loc1_.rise_label.textColor;
   _loc1_.nevColor = _loc1_.nev_label.textColor;
}
var p = latClass.prototype = new MovieClip();
Object.registerClass("simulator",latClass);
p.onEnterFrame = function()
{
   var _loc1_ = this;
   _loc1_.pers_tan._rotation = 90 - _loc1_.lat;
   if(_loc1_._active)
   {
      _loc1_.latSlider.value = _loc1_.lat;
   }
   else
   {
      _loc1_.lat = _loc1_.latSlider.value;
   }
   if(_loc1_.myEnlargeBox.enlarge)
   {
      _loc1_.myGrid._alpha = 50;
      _loc1_.myEarth._alpha = 50;
      _loc1_.myEarth._xscale = 100;
      _loc1_.myEarth._yscale = 100;
      _loc1_.np_text._y = 182;
      _loc1_.sp_text._y = 247;
      _loc1_.pers_tan._x = 225 - 25 * Math.cos(_loc1_.radian(_loc1_.pers_tan._rotation + 90));
      _loc1_.pers_tan._y = 225 - 25 * Math.sin(_loc1_.radian(_loc1_.pers_tan._rotation + 90));
   }
   else
   {
      _loc1_.myGrid._alpha = 100;
      _loc1_.myEarth._alpha = 100;
      _loc1_.myEarth._xscale = 20;
      _loc1_.myEarth._yscale = 20;
      _loc1_.np_text._y = 192;
      _loc1_.sp_text._y = 237;
      _loc1_.pers_tan._x = 225;
      _loc1_.pers_tan._y = 225;
   }
   _loc1_.calcRanges();
};
p.calcRanges = function()
{
   var _loc1_ = this;
   var _loc3_ = Math.round(10 * (90 - Math.abs(_loc1_.lat))) / 10;
   var cir_end = 90;
   var _loc2_ = _loc3_;
   var nev_start = Math.round(10 * (- (90 - Math.abs(_loc1_.lat)))) / 10;
   var rise_end = nev_start;
   var nev_end = -90;
   if(_loc1_.lat < 0)
   {
      var temp = _loc3_;
      _loc3_ = nev_start;
      nev_start = temp;
      temp = cir_end;
      cir_end = nev_end;
      nev_end = temp;
   }
   var sign = "";
   if(_loc3_ != 0)
   {
      var cirStart = "+" + Math.round(10 * (90 - Math.abs(_loc1_.lat))) / 10 + "°";
   }
   else
   {
      var cirStart = (- Math.round(10 * (90 - Math.abs(_loc1_.lat)))) / 10 + "°";
   }
   var cirEnd = "+90°";
   var riseStart = cirStart;
   if(nev_start != 0)
   {
      var nevStart = (- Math.round(10 * (90 - Math.abs(_loc1_.lat)))) / 10 + "°";
   }
   else
   {
      var nevStart = Math.round(10 * (90 - Math.abs(_loc1_.lat))) / 10 + "°";
   }
   var riseEnd = nevStart;
   var nevEnd = "-90°";
   if(_loc1_.lat < 0)
   {
      var temp = cirStart;
      cirStart = nevStart;
      nevStart = temp;
      temp = cirEnd;
      cirEnd = nevEnd;
      nevEnd = temp;
   }
   if(_loc3_ == cir_end)
   {
      _loc1_.cir_range.text = "None";
   }
   else
   {
      _loc1_.cir_range.text = cirStart + " to " + cirEnd;
   }
   if(_loc2_ == rise_end)
   {
      _loc1_.rise_range.text = "None";
   }
   else
   {
      _loc1_.rise_range.text = riseStart + " to " + riseEnd;
   }
   if(nev_start == nev_end)
   {
      _loc1_.nev_range.text = "None";
   }
   else
   {
      _loc1_.nev_range.text = nevStart + " to " + nevEnd;
   }
   _loc1_.createEmptyMovieClip("cir_polar_1",1);
   _loc1_.createEmptyMovieClip("cir_polar_1b",7);
   _loc1_.createEmptyMovieClip("cir_polar_2",2);
   _loc1_.createEmptyMovieClip("cir_polar_2b",8);
   if(_loc1_._lat < 45 && _loc1_._lat > -45)
   {
      _loc1_.cir_polar_1b._visible = false;
      _loc1_.cir_polar_2b._visible = false;
      var point1_x = 225 - 165 * Math.cos(_loc1_.radian(_loc3_));
      var point1_y = 225 - 165 * Math.sin(_loc1_.radian(_loc3_));
      _loc1_.cir_polar_1.moveTo(point1_x,point1_y);
      _loc1_.cir_polar_1.beginFill(_loc1_.cirColor,90);
      var point2_x = 225 - 178 * Math.cos(_loc1_.radian(_loc3_));
      var point2_y = 225 - 178 * Math.sin(_loc1_.radian(_loc3_));
      _loc1_.cir_polar_1.lineTo(point2_x,point2_y);
      var point3_x = 225 - 178 * Math.cos(_loc1_.radian(cir_end));
      var point3_y = 225 - 178 * Math.sin(_loc1_.radian(cir_end));
      var conAng = (_loc3_ + cir_end) / 2;
      var conRad = _loc1_.findControlRadius(point2_x,point2_y,point3_x,point3_y);
      var conPt_23_x = 225 - conRad * Math.cos(_loc1_.radian(conAng));
      var conPt_23_y = 225 - conRad * Math.sin(_loc1_.radian(conAng));
      _loc1_.cir_polar_1.curveTo(conPt_23_x,conPt_23_y,point3_x,point3_y);
      var point4_x = 225 - 165 * Math.cos(_loc1_.radian(cir_end));
      var point4_y = 225 - 165 * Math.sin(_loc1_.radian(cir_end));
      _loc1_.cir_polar_1.lineTo(point4_x,point4_y);
      conAng = (_loc3_ + cir_end) / 2;
      conRad = _loc1_.findControlRadius(point4_x,point4_y,point1_x,point1_y);
      var conPt_41_x = 225 - conRad * Math.cos(_loc1_.radian(conAng));
      var conPt_41_y = 225 - conRad * Math.sin(_loc1_.radian(conAng));
      _loc1_.cir_polar_1.curveTo(conPt_41_x,conPt_41_y,point1_x,point1_y);
      _loc1_.cir_polar_1.endFill();
      point1_x = 225 - 165 * Math.cos(_loc1_.radian(180 - _loc3_));
      point1_y = 225 - 165 * Math.sin(_loc1_.radian(180 - _loc3_));
      _loc1_.cir_polar_2.moveTo(point1_x,point1_y);
      _loc1_.cir_polar_2.beginFill(_loc1_.cirColor,90);
      point2_x = 225 - 178 * Math.cos(_loc1_.radian(180 - _loc3_));
      point2_y = 225 - 178 * Math.sin(_loc1_.radian(180 - _loc3_));
      _loc1_.cir_polar_2.lineTo(point2_x,point2_y);
      point3_x = 225 - 178 * Math.cos(_loc1_.radian(cir_end));
      point3_y = 225 - 178 * Math.sin(_loc1_.radian(cir_end));
      conAng = (180 - _loc3_ + cir_end) / 2;
      conRad = _loc1_.findControlRadius(point2_x,point2_y,point3_x,point3_y);
      if(_loc1_._lat < 0)
      {
         conPt_23_x = 225 + conRad * Math.cos(_loc1_.radian(conAng));
         conPt_23_y = 225 + conRad * Math.sin(_loc1_.radian(conAng));
      }
      else
      {
         conPt_23_x = 225 - conRad * Math.cos(_loc1_.radian(conAng));
         conPt_23_y = 225 - conRad * Math.sin(_loc1_.radian(conAng));
      }
      _loc1_.cir_polar_2.curveTo(conPt_23_x,conPt_23_y,point3_x,point3_y);
      point4_x = 225 - 165 * Math.cos(_loc1_.radian(cir_end));
      point4_y = 225 - 165 * Math.sin(_loc1_.radian(cir_end));
      _loc1_.cir_polar_2.lineTo(point4_x,point4_y);
      conAng = (180 - _loc3_ + cir_end) / 2;
      conRad = _loc1_.findControlRadius(point4_x,point4_y,point1_x,point1_y);
      if(_loc1_._lat < 0)
      {
         conPt_41_x = 225 + conRad * Math.cos(_loc1_.radian(conAng));
         conPt_41_y = 225 + conRad * Math.sin(_loc1_.radian(conAng));
      }
      else
      {
         conPt_41_x = 225 - conRad * Math.cos(_loc1_.radian(conAng));
         conPt_41_y = 225 - conRad * Math.sin(_loc1_.radian(conAng));
      }
      _loc1_.cir_polar_2.curveTo(conPt_41_x,conPt_41_y,point1_x,point1_y);
      _loc1_.cir_polar_2.endFill();
   }
   else
   {
      if(_loc1_._lat >= 0)
      {
         var breakLat = 45;
      }
      else
      {
         var breakLat = -45;
      }
      var point1_x = 225 - 165 * Math.cos(_loc1_.radian(breakLat));
      var point1_y = 225 - 165 * Math.sin(_loc1_.radian(breakLat));
      _loc1_.cir_polar_1.moveTo(point1_x,point1_y);
      _loc1_.cir_polar_1.beginFill(_loc1_.cirColor,90);
      var point2_x = 225 - 178 * Math.cos(_loc1_.radian(breakLat));
      var point2_y = 225 - 178 * Math.sin(_loc1_.radian(breakLat));
      _loc1_.cir_polar_1.lineTo(point2_x,point2_y);
      var point3_x = 225 - 178 * Math.cos(_loc1_.radian(cir_end));
      var point3_y = 225 - 178 * Math.sin(_loc1_.radian(cir_end));
      var conAng = (breakLat + cir_end) / 2;
      var conRad = _loc1_.findControlRadius(point2_x,point2_y,point3_x,point3_y);
      var conPt_23_x = 225 - conRad * Math.cos(_loc1_.radian(conAng));
      var conPt_23_y = 225 - conRad * Math.sin(_loc1_.radian(conAng));
      _loc1_.cir_polar_1.curveTo(conPt_23_x,conPt_23_y,point3_x,point3_y);
      var point4_x = 225 - 165 * Math.cos(_loc1_.radian(cir_end));
      var point4_y = 225 - 165 * Math.sin(_loc1_.radian(cir_end));
      _loc1_.cir_polar_1.lineTo(point4_x,point4_y);
      conAng = (breakLat + cir_end) / 2;
      conRad = _loc1_.findControlRadius(point4_x,point4_y,point1_x,point1_y);
      var conPt_41_x = 225 - conRad * Math.cos(_loc1_.radian(conAng));
      var conPt_41_y = 225 - conRad * Math.sin(_loc1_.radian(conAng));
      _loc1_.cir_polar_1.curveTo(conPt_41_x,conPt_41_y,point1_x,point1_y);
      _loc1_.cir_polar_1.endFill();
      point1_x = 225 - 165 * Math.cos(_loc1_.radian(_loc3_));
      point1_y = 225 - 165 * Math.sin(_loc1_.radian(_loc3_));
      _loc1_.cir_polar_1b.moveTo(point1_x,point1_y);
      _loc1_.cir_polar_1b.beginFill(_loc1_.cirColor,90);
      point2_x = 225 - 178 * Math.cos(_loc1_.radian(_loc3_));
      point2_y = 225 - 178 * Math.sin(_loc1_.radian(_loc3_));
      _loc1_.cir_polar_1b.lineTo(point2_x,point2_y);
      point3_x = 225 - 178 * Math.cos(_loc1_.radian(breakLat));
      point3_y = 225 - 178 * Math.sin(_loc1_.radian(breakLat));
      conAng = (_loc3_ + breakLat) / 2;
      var conRad1 = _loc1_.findControlRadius(point2_x,point2_y,point3_x,point3_y);
      conPt_23_x = 225 - conRad1 * Math.cos(_loc1_.radian(conAng));
      conPt_23_y = 225 - conRad1 * Math.sin(_loc1_.radian(conAng));
      _loc1_.cir_polar_1b.curveTo(conPt_23_x,conPt_23_y,point3_x,point3_y);
      point4_x = 225 - 165 * Math.cos(_loc1_.radian(breakLat));
      point4_y = 225 - 165 * Math.sin(_loc1_.radian(breakLat));
      _loc1_.cir_polar_1b.lineTo(point4_x,point4_y);
      conRad = _loc1_.findControlRadius(point4_x,point4_y,point1_x,point1_y);
      conPt_41_x = 225 - conRad * Math.cos(_loc1_.radian(conAng));
      conPt_41_y = 225 - conRad * Math.sin(_loc1_.radian(conAng));
      _loc1_.cir_polar_1b.curveTo(conPt_41_x,conPt_41_y,point1_x,point1_y);
      _loc1_.cir_polar_1b.endFill();
      point1_x = 225 - 165 * Math.cos(_loc1_.radian(180 - breakLat));
      point1_y = 225 - 165 * Math.sin(_loc1_.radian(180 - breakLat));
      _loc1_.cir_polar_2.moveTo(point1_x,point1_y);
      _loc1_.cir_polar_2.beginFill(_loc1_.cirColor,90);
      point2_x = 225 - 178 * Math.cos(_loc1_.radian(180 - breakLat));
      point2_y = 225 - 178 * Math.sin(_loc1_.radian(180 - breakLat));
      _loc1_.cir_polar_2.lineTo(point2_x,point2_y);
      point3_x = 225 - 178 * Math.cos(_loc1_.radian(cir_end));
      point3_y = 225 - 178 * Math.sin(_loc1_.radian(cir_end));
      conAng = (180 - breakLat + cir_end) / 2;
      conRad = _loc1_.findControlRadius(point2_x,point2_y,point3_x,point3_y);
      if(_loc1_._lat < 0)
      {
         conPt_23_x = 225 + conRad * Math.cos(_loc1_.radian(conAng));
         conPt_23_y = 225 + conRad * Math.sin(_loc1_.radian(conAng));
      }
      else
      {
         conPt_23_x = 225 - conRad * Math.cos(_loc1_.radian(conAng));
         conPt_23_y = 225 - conRad * Math.sin(_loc1_.radian(conAng));
      }
      _loc1_.cir_polar_2.curveTo(conPt_23_x,conPt_23_y,point3_x,point3_y);
      point4_x = 225 - 165 * Math.cos(_loc1_.radian(cir_end));
      point4_y = 225 - 165 * Math.sin(_loc1_.radian(cir_end));
      _loc1_.cir_polar_2.lineTo(point4_x,point4_y);
      conRad = _loc1_.findControlRadius(point4_x,point4_y,point1_x,point1_y);
      if(_loc1_._lat < 0)
      {
         conPt_41_x = 225 + conRad * Math.cos(_loc1_.radian(conAng));
         conPt_41_y = 225 + conRad * Math.sin(_loc1_.radian(conAng));
      }
      else
      {
         conPt_41_x = 225 - conRad * Math.cos(_loc1_.radian(conAng));
         conPt_41_y = 225 - conRad * Math.sin(_loc1_.radian(conAng));
      }
      _loc1_.cir_polar_2.curveTo(conPt_41_x,conPt_41_y,point1_x,point1_y);
      _loc1_.cir_polar_2.endFill();
      point1_x = 225 - 165 * Math.cos(_loc1_.radian(180 - _loc3_));
      point1_y = 225 - 165 * Math.sin(_loc1_.radian(180 - _loc3_));
      _loc1_.cir_polar_2b.moveTo(point1_x,point1_y);
      _loc1_.cir_polar_2b.beginFill(_loc1_.cirColor,90);
      point2_x = 225 - 178 * Math.cos(_loc1_.radian(180 - _loc3_));
      point2_y = 225 - 178 * Math.sin(_loc1_.radian(180 - _loc3_));
      _loc1_.cir_polar_2b.lineTo(point2_x,point2_y);
      point3_x = 225 - 178 * Math.cos(_loc1_.radian(180 - breakLat));
      point3_y = 225 - 178 * Math.sin(_loc1_.radian(180 - breakLat));
      conAng = (180 - _loc3_ + (180 - breakLat)) / 2;
      conRad = conRad1;
      conPt_23_x = 225 - conRad * Math.cos(_loc1_.radian(conAng));
      conPt_23_y = 225 - conRad * Math.sin(_loc1_.radian(conAng));
      _loc1_.cir_polar_2b.curveTo(conPt_23_x,conPt_23_y,point3_x,point3_y);
      point4_x = 225 - 165 * Math.cos(_loc1_.radian(180 - breakLat));
      point4_y = 225 - 165 * Math.sin(_loc1_.radian(180 - breakLat));
      _loc1_.cir_polar_2b.lineTo(point4_x,point4_y);
      conRad = _loc1_.findControlRadius(point4_x,point4_y,point1_x,point1_y);
      conPt_41_x = 225 - conRad * Math.cos(_loc1_.radian(conAng));
      conPt_41_y = 225 - conRad * Math.sin(_loc1_.radian(conAng));
      _loc1_.cir_polar_2b.curveTo(conPt_41_x,conPt_41_y,point1_x,point1_y);
      _loc1_.cir_polar_2b.endFill();
   }
   _loc1_.createEmptyMovieClip("rise_set_1",3);
   _loc1_.createEmptyMovieClip("rise_set_2",4);
   _loc1_.createEmptyMovieClip("rise_set_1b",9);
   _loc1_.createEmptyMovieClip("rise_set_2b",10);
   _loc1_.createEmptyMovieClip("rise_set_3",11);
   _loc1_.createEmptyMovieClip("rise_set_4",12);
   _loc1_.createEmptyMovieClip("rise_set_3b",13);
   _loc1_.createEmptyMovieClip("rise_set_4b",14);
   if(_loc1_._lat >= 45 || _loc1_._lat <= -45)
   {
      _loc1_.rise_set_1b._visible = false;
      _loc1_.rise_set_2b._visible = false;
      _loc1_.rise_set_3b._visible = false;
      _loc1_.rise_set_4b._visible = false;
      var point1_x = 225 - 165 * Math.cos(_loc1_.radian(_loc2_));
      var point1_y = 225 - 165 * Math.sin(_loc1_.radian(_loc2_));
      _loc1_.rise_set_1.moveTo(point1_x,point1_y);
      _loc1_.rise_set_1.beginFill(_loc1_.riseColor,90);
      var point2_x = 225 - 178 * Math.cos(_loc1_.radian(_loc2_));
      var point2_y = 225 - 178 * Math.sin(_loc1_.radian(_loc2_));
      _loc1_.rise_set_1.lineTo(point2_x,point2_y);
      var point3_x = 225 - 178 * Math.cos(_loc1_.radian(0));
      var point3_y = 225 - 178 * Math.sin(_loc1_.radian(0));
      var conAng = _loc2_ / 2;
      var conRad = _loc1_.findControlRadius(point2_x,point2_y,point3_x,point3_y);
      var conPt_23_x = 225 - conRad * Math.cos(_loc1_.radian(conAng));
      var conPt_23_y = 225 - conRad * Math.sin(_loc1_.radian(conAng));
      _loc1_.rise_set_1.curveTo(conPt_23_x,conPt_23_y,point3_x,point3_y);
      var point4_x = 225 - 165 * Math.cos(_loc1_.radian(0));
      var point4_y = 225 - 165 * Math.sin(_loc1_.radian(0));
      _loc1_.rise_set_1.lineTo(point4_x,point4_y);
      conAng = _loc2_ / 2;
      var conRad1 = _loc1_.findControlRadius(point4_x,point4_y,point1_x,point1_y);
      var conPt_41_x = 225 - conRad1 * Math.cos(_loc1_.radian(conAng));
      var conPt_41_y = 225 - conRad1 * Math.sin(_loc1_.radian(conAng));
      _loc1_.rise_set_1.curveTo(conPt_41_x,conPt_41_y,point1_x,point1_y);
      _loc1_.rise_set_1.endFill();
      point1_x = 225 - 165 * Math.cos(_loc1_.radian(360 - _loc2_));
      point1_y = 225 - 165 * Math.sin(_loc1_.radian(360 - _loc2_));
      _loc1_.rise_set_3.moveTo(point1_x,point1_y);
      _loc1_.rise_set_3.beginFill(_loc1_.riseColor,90);
      point2_x = 225 - 178 * Math.cos(_loc1_.radian(360 - _loc2_));
      point2_y = 225 - 178 * Math.sin(_loc1_.radian(360 - _loc2_));
      _loc1_.rise_set_3.lineTo(point2_x,point2_y);
      point3_x = 225 - 178 * Math.cos(_loc1_.radian(0));
      point3_y = 225 - 178 * Math.sin(_loc1_.radian(0));
      conAng = (360 - _loc2_) / 2;
      conRad = _loc1_.findControlRadius(point2_x,point2_y,point3_x,point3_y);
      conPt_23_x = 225 + conRad * Math.cos(_loc1_.radian(conAng));
      conPt_23_y = 225 + conRad * Math.sin(_loc1_.radian(conAng));
      _loc1_.rise_set_3.curveTo(conPt_23_x,conPt_23_y,point3_x,point3_y);
      var point4_x = 225 - 165 * Math.cos(_loc1_.radian(0));
      var point4_y = 225 - 165 * Math.sin(_loc1_.radian(0));
      _loc1_.rise_set_3.lineTo(point4_x,point4_y);
      conRad = _loc1_.findControlRadius(point4_x,point4_y,point1_x,point1_y);
      conPt_41_x = 225 + conRad * Math.cos(_loc1_.radian(conAng));
      conPt_41_y = 225 + conRad1 * Math.sin(_loc1_.radian(conAng));
      _loc1_.rise_set_3.curveTo(conPt_41_x,conPt_41_y,point1_x,point1_y);
      _loc1_.rise_set_3.endFill();
      point1_x = 225 - 165 * Math.cos(_loc1_.radian(180 - _loc2_));
      point1_y = 225 - 165 * Math.sin(_loc1_.radian(180 - _loc2_));
      _loc1_.rise_set_2.moveTo(point1_x,point1_y);
      _loc1_.rise_set_2.beginFill(_loc1_.riseColor,90);
      point2_x = 225 - 178 * Math.cos(_loc1_.radian(180 - _loc2_));
      point2_y = 225 - 178 * Math.sin(_loc1_.radian(180 - _loc2_));
      _loc1_.rise_set_2.lineTo(point2_x,point2_y);
      point3_x = 225 - 178 * Math.cos(_loc1_.radian(180));
      point3_y = 225 - 178 * Math.sin(_loc1_.radian(180));
      conAng = (180 - _loc2_ + 180) / 2;
      conRad = _loc1_.findControlRadius(point2_x,point2_y,point3_x,point3_y);
      conPt_23_x = 225 - conRad * Math.cos(_loc1_.radian(conAng));
      conPt_23_y = 225 - conRad * Math.sin(_loc1_.radian(conAng));
      _loc1_.rise_set_2.curveTo(conPt_23_x,conPt_23_y,point3_x,point3_y);
      point4_x = 225 - 165 * Math.cos(_loc1_.radian(180));
      point4_y = 225 - 165 * Math.sin(_loc1_.radian(180));
      _loc1_.rise_set_2.lineTo(point4_x,point4_y);
      conAng = (180 - _loc2_ + 180) / 2;
      conRad = conRad1;
      conPt_41_x = 225 - conRad * Math.cos(_loc1_.radian(conAng));
      conPt_41_y = 225 - conRad * Math.sin(_loc1_.radian(conAng));
      _loc1_.rise_set_2.curveTo(conPt_41_x,conPt_41_y,point1_x,point1_y);
      _loc1_.rise_set_2.endFill();
      point1_x = 225 - 165 * Math.cos(_loc1_.radian(180 + _loc2_));
      point1_y = 225 - 165 * Math.sin(_loc1_.radian(180 + _loc2_));
      _loc1_.rise_set_4.moveTo(point1_x,point1_y);
      _loc1_.rise_set_4.beginFill(_loc1_.riseColor,90);
      point2_x = 225 - 178 * Math.cos(_loc1_.radian(180 + _loc2_));
      point2_y = 225 - 178 * Math.sin(_loc1_.radian(180 + _loc2_));
      _loc1_.rise_set_4.lineTo(point2_x,point2_y);
      point3_x = 225 - 178 * Math.cos(_loc1_.radian(180));
      point3_y = 225 - 178 * Math.sin(_loc1_.radian(180));
      conAng = (180 + _loc2_ + 180) / 2;
      conRad = _loc1_.findControlRadius(point2_x,point2_y,point3_x,point3_y);
      conPt_23_x = 225 - conRad * Math.cos(_loc1_.radian(conAng));
      conPt_23_y = 225 - conRad * Math.sin(_loc1_.radian(conAng));
      _loc1_.rise_set_4.curveTo(conPt_23_x,conPt_23_y,point3_x,point3_y);
      point4_x = 225 - 165 * Math.cos(_loc1_.radian(180));
      point4_y = 225 - 165 * Math.sin(_loc1_.radian(180));
      _loc1_.rise_set_4.lineTo(point4_x,point4_y);
      conRad = conRad1;
      conPt_41_x = 225 - conRad * Math.cos(_loc1_.radian(conAng));
      conPt_41_y = 225 - conRad * Math.sin(_loc1_.radian(conAng));
      _loc1_.rise_set_4.curveTo(conPt_41_x,conPt_41_y,point1_x,point1_y);
      _loc1_.rise_set_4.endFill();
   }
   else
   {
      var breakLat = 45;
      var point1_x = 225 - 165 * Math.cos(_loc1_.radian(breakLat));
      var point1_y = 225 - 165 * Math.sin(_loc1_.radian(breakLat));
      _loc1_.rise_set_1.moveTo(point1_x,point1_y);
      _loc1_.rise_set_1.beginFill(_loc1_.riseColor,90);
      var point2_x = 225 - 178 * Math.cos(_loc1_.radian(breakLat));
      var point2_y = 225 - 178 * Math.sin(_loc1_.radian(breakLat));
      _loc1_.rise_set_1.lineTo(point2_x,point2_y);
      var point3_x = 225 - 178 * Math.cos(_loc1_.radian(0));
      var point3_y = 225 - 178 * Math.sin(_loc1_.radian(0));
      var conAng = breakLat / 2;
      var conRad = _loc1_.findControlRadius(point2_x,point2_y,point3_x,point3_y);
      var conPt_23_x = 225 - conRad * Math.cos(_loc1_.radian(conAng));
      var conPt_23_y = 225 - conRad * Math.sin(_loc1_.radian(conAng));
      _loc1_.rise_set_1.curveTo(conPt_23_x,conPt_23_y,point3_x,point3_y);
      var point4_x = 225 - 165 * Math.cos(_loc1_.radian(0));
      var point4_y = 225 - 165 * Math.sin(_loc1_.radian(0));
      _loc1_.rise_set_1.lineTo(point4_x,point4_y);
      conAng = breakLat / 2;
      var conRad2 = _loc1_.findControlRadius(point4_x,point4_y,point1_x,point1_y);
      var conPt_41_x = 225 - conRad2 * Math.cos(_loc1_.radian(conAng));
      var conPt_41_y = 225 - conRad2 * Math.sin(_loc1_.radian(conAng));
      _loc1_.rise_set_1.curveTo(conPt_41_x,conPt_41_y,point1_x,point1_y);
      _loc1_.rise_set_1.endFill();
      var point1_x = 225 - 165 * Math.cos(_loc1_.radian(360 - breakLat));
      var point1_y = 225 - 165 * Math.sin(_loc1_.radian(360 - breakLat));
      _loc1_.rise_set_3.moveTo(point1_x,point1_y);
      _loc1_.rise_set_3.beginFill(_loc1_.riseColor,90);
      var point2_x = 225 - 178 * Math.cos(_loc1_.radian(360 - breakLat));
      var point2_y = 225 - 178 * Math.sin(_loc1_.radian(360 - breakLat));
      _loc1_.rise_set_3.lineTo(point2_x,point2_y);
      var point3_x = 225 - 178 * Math.cos(_loc1_.radian(0));
      var point3_y = 225 - 178 * Math.sin(_loc1_.radian(0));
      var conAng = (360 - breakLat) / 2;
      var conRad = _loc1_.findControlRadius(point2_x,point2_y,point3_x,point3_y);
      var conPt_23_x = 225 + conRad * Math.cos(_loc1_.radian(conAng));
      var conPt_23_y = 225 + conRad * Math.sin(_loc1_.radian(conAng));
      _loc1_.rise_set_3.curveTo(conPt_23_x,conPt_23_y,point3_x,point3_y);
      var point4_x = 225 - 165 * Math.cos(_loc1_.radian(0));
      var point4_y = 225 - 165 * Math.sin(_loc1_.radian(0));
      _loc1_.rise_set_3.lineTo(point4_x,point4_y);
      var conRad2 = _loc1_.findControlRadius(point4_x,point4_y,point1_x,point1_y);
      var conPt_41_x = 225 + conRad2 * Math.cos(_loc1_.radian(conAng));
      var conPt_41_y = 225 + conRad2 * Math.sin(_loc1_.radian(conAng));
      _loc1_.rise_set_3.curveTo(conPt_41_x,conPt_41_y,point1_x,point1_y);
      _loc1_.rise_set_3.endFill();
      point1_x = 225 - 165 * Math.cos(_loc1_.radian(breakLat));
      point1_y = 225 - 165 * Math.sin(_loc1_.radian(breakLat));
      _loc1_.rise_set_1b.moveTo(point1_x,point1_y);
      _loc1_.rise_set_1b.beginFill(_loc1_.riseColor,90);
      point2_x = 225 - 178 * Math.cos(_loc1_.radian(breakLat));
      point2_y = 225 - 178 * Math.sin(_loc1_.radian(breakLat));
      _loc1_.rise_set_1b.lineTo(point2_x,point2_y);
      point3_x = 225 - 178 * Math.cos(_loc1_.radian(_loc2_));
      point3_y = 225 - 178 * Math.sin(_loc1_.radian(_loc2_));
      conAng = (_loc2_ + breakLat) / 2;
      var conRad1 = _loc1_.findControlRadius(point2_x,point2_y,point3_x,point3_y);
      conPt_23_x = 225 - conRad1 * Math.cos(_loc1_.radian(conAng));
      conPt_23_y = 225 - conRad1 * Math.sin(_loc1_.radian(conAng));
      _loc1_.rise_set_1b.curveTo(conPt_23_x,conPt_23_y,point3_x,point3_y);
      point4_x = 225 - 165 * Math.cos(_loc1_.radian(_loc2_));
      point4_y = 225 - 165 * Math.sin(_loc1_.radian(_loc2_));
      _loc1_.rise_set_1b.lineTo(point4_x,point4_y);
      conRad = _loc1_.findControlRadius(point4_x,point4_y,point1_x,point1_y);
      conPt_41_x = 225 - conRad * Math.cos(_loc1_.radian(conAng));
      conPt_41_y = 225 - conRad * Math.sin(_loc1_.radian(conAng));
      _loc1_.rise_set_1b.curveTo(conPt_41_x,conPt_41_y,point1_x,point1_y);
      _loc1_.rise_set_1b.endFill();
      point1_x = 225 - 165 * Math.cos(_loc1_.radian(360 - breakLat));
      point1_y = 225 - 165 * Math.sin(_loc1_.radian(360 - breakLat));
      _loc1_.rise_set_3b.moveTo(point1_x,point1_y);
      _loc1_.rise_set_3b.beginFill(_loc1_.riseColor,90);
      point2_x = 225 - 178 * Math.cos(_loc1_.radian(360 - breakLat));
      point2_y = 225 - 178 * Math.sin(_loc1_.radian(360 - breakLat));
      _loc1_.rise_set_3b.lineTo(point2_x,point2_y);
      point3_x = 225 - 178 * Math.cos(_loc1_.radian(360 - _loc2_));
      point3_y = 225 - 178 * Math.sin(_loc1_.radian(360 - _loc2_));
      conAng = (360 - _loc2_ + (360 - breakLat)) / 2;
      var conRad1 = _loc1_.findControlRadius(point2_x,point2_y,point3_x,point3_y);
      conPt_23_x = 225 - conRad1 * Math.cos(_loc1_.radian(conAng));
      conPt_23_y = 225 - conRad1 * Math.sin(_loc1_.radian(conAng));
      _loc1_.rise_set_3b.curveTo(conPt_23_x,conPt_23_y,point3_x,point3_y);
      point4_x = 225 - 165 * Math.cos(_loc1_.radian(360 - _loc2_));
      point4_y = 225 - 165 * Math.sin(_loc1_.radian(360 - _loc2_));
      _loc1_.rise_set_3b.lineTo(point4_x,point4_y);
      conRad = _loc1_.findControlRadius(point4_x,point4_y,point1_x,point1_y);
      conPt_41_x = 225 - conRad * Math.cos(_loc1_.radian(conAng));
      conPt_41_y = 225 - conRad * Math.sin(_loc1_.radian(conAng));
      _loc1_.rise_set_3b.curveTo(conPt_41_x,conPt_41_y,point1_x,point1_y);
      _loc1_.rise_set_3b.endFill();
      point1_x = 225 - 165 * Math.cos(_loc1_.radian(180 - breakLat));
      point1_y = 225 - 165 * Math.sin(_loc1_.radian(180 - breakLat));
      _loc1_.rise_set_2.moveTo(point1_x,point1_y);
      _loc1_.rise_set_2.beginFill(_loc1_.riseColor,90);
      point2_x = 225 - 178 * Math.cos(_loc1_.radian(180 - breakLat));
      point2_y = 225 - 178 * Math.sin(_loc1_.radian(180 - breakLat));
      _loc1_.rise_set_2.lineTo(point2_x,point2_y);
      point3_x = 225 - 178 * Math.cos(_loc1_.radian(180));
      point3_y = 225 - 178 * Math.sin(_loc1_.radian(180));
      conAng = (180 - breakLat + 180) / 2;
      conRad = _loc1_.findControlRadius(point2_x,point2_y,point3_x,point3_y);
      conPt_23_x = 225 - conRad * Math.cos(_loc1_.radian(conAng));
      conPt_23_y = 225 - conRad * Math.sin(_loc1_.radian(conAng));
      _loc1_.rise_set_2.curveTo(conPt_23_x,conPt_23_y,point3_x,point3_y);
      point4_x = 225 - 165 * Math.cos(_loc1_.radian(180));
      point4_y = 225 - 165 * Math.sin(_loc1_.radian(180));
      _loc1_.rise_set_2.lineTo(point4_x,point4_y);
      conRad = conRad2;
      conPt_41_x = 225 - conRad * Math.cos(_loc1_.radian(conAng));
      conPt_41_y = 225 - conRad * Math.sin(_loc1_.radian(conAng));
      _loc1_.rise_set_2.curveTo(conPt_41_x,conPt_41_y,point1_x,point1_y);
      _loc1_.rise_set_2.endFill();
      point1_x = 225 - 165 * Math.cos(_loc1_.radian(180 + breakLat));
      point1_y = 225 - 165 * Math.sin(_loc1_.radian(180 + breakLat));
      _loc1_.rise_set_4.moveTo(point1_x,point1_y);
      _loc1_.rise_set_4.beginFill(_loc1_.riseColor,90);
      point2_x = 225 - 178 * Math.cos(_loc1_.radian(180 + breakLat));
      point2_y = 225 - 178 * Math.sin(_loc1_.radian(180 + breakLat));
      _loc1_.rise_set_4.lineTo(point2_x,point2_y);
      point3_x = 225 - 178 * Math.cos(_loc1_.radian(180));
      point3_y = 225 - 178 * Math.sin(_loc1_.radian(180));
      conAng = (180 + breakLat + 180) / 2;
      conRad = _loc1_.findControlRadius(point2_x,point2_y,point3_x,point3_y);
      conPt_23_x = 225 - conRad * Math.cos(_loc1_.radian(conAng));
      conPt_23_y = 225 - conRad * Math.sin(_loc1_.radian(conAng));
      _loc1_.rise_set_4.curveTo(conPt_23_x,conPt_23_y,point3_x,point3_y);
      point4_x = 225 - 165 * Math.cos(_loc1_.radian(180));
      point4_y = 225 - 165 * Math.sin(_loc1_.radian(180));
      _loc1_.rise_set_4.lineTo(point4_x,point4_y);
      conRad = conRad2;
      conPt_41_x = 225 - conRad * Math.cos(_loc1_.radian(conAng));
      conPt_41_y = 225 - conRad * Math.sin(_loc1_.radian(conAng));
      _loc1_.rise_set_4.curveTo(conPt_41_x,conPt_41_y,point1_x,point1_y);
      _loc1_.rise_set_4.endFill();
      point1_x = 225 - 165 * Math.cos(_loc1_.radian(180 - breakLat));
      point1_y = 225 - 165 * Math.sin(_loc1_.radian(180 - breakLat));
      _loc1_.rise_set_2b.moveTo(point1_x,point1_y);
      _loc1_.rise_set_2b.beginFill(_loc1_.riseColor,90);
      point2_x = 225 - 178 * Math.cos(_loc1_.radian(180 - breakLat));
      point2_y = 225 - 178 * Math.sin(_loc1_.radian(180 - breakLat));
      _loc1_.rise_set_2b.lineTo(point2_x,point2_y);
      point3_x = 225 - 178 * Math.cos(_loc1_.radian(180 - _loc2_));
      point3_y = 225 - 178 * Math.sin(_loc1_.radian(180 - _loc2_));
      conAng = (180 - _loc2_ + (180 - breakLat)) / 2;
      conRad = conRad1;
      conPt_23_x = 225 - conRad * Math.cos(_loc1_.radian(conAng));
      conPt_23_y = 225 - conRad * Math.sin(_loc1_.radian(conAng));
      _loc1_.rise_set_2b.curveTo(conPt_23_x,conPt_23_y,point3_x,point3_y);
      point4_x = 225 - 165 * Math.cos(_loc1_.radian(180 - _loc2_));
      point4_y = 225 - 165 * Math.sin(_loc1_.radian(180 - _loc2_));
      _loc1_.rise_set_2b.lineTo(point4_x,point4_y);
      conRad = _loc1_.findControlRadius(point4_x,point4_y,point1_x,point1_y);
      conPt_41_x = 225 - conRad * Math.cos(_loc1_.radian(conAng));
      conPt_41_y = 225 - conRad * Math.sin(_loc1_.radian(conAng));
      _loc1_.rise_set_2b.curveTo(conPt_41_x,conPt_41_y,point1_x,point1_y);
      _loc1_.rise_set_2b.endFill();
      point1_x = 225 - 165 * Math.cos(_loc1_.radian(180 + breakLat));
      point1_y = 225 - 165 * Math.sin(_loc1_.radian(180 + breakLat));
      _loc1_.rise_set_4b.moveTo(point1_x,point1_y);
      _loc1_.rise_set_4b.beginFill(_loc1_.riseColor,90);
      point2_x = 225 - 178 * Math.cos(_loc1_.radian(180 + breakLat));
      point2_y = 225 - 178 * Math.sin(_loc1_.radian(180 + breakLat));
      _loc1_.rise_set_4b.lineTo(point2_x,point2_y);
      point3_x = 225 - 178 * Math.cos(_loc1_.radian(180 + _loc2_));
      point3_y = 225 - 178 * Math.sin(_loc1_.radian(180 + _loc2_));
      conAng = (180 + _loc2_ + (180 + breakLat)) / 2;
      conRad = conRad1;
      conPt_23_x = 225 - conRad * Math.cos(_loc1_.radian(conAng));
      conPt_23_y = 225 - conRad * Math.sin(_loc1_.radian(conAng));
      _loc1_.rise_set_4b.curveTo(conPt_23_x,conPt_23_y,point3_x,point3_y);
      point4_x = 225 - 165 * Math.cos(_loc1_.radian(180 + _loc2_));
      point4_y = 225 - 165 * Math.sin(_loc1_.radian(180 + _loc2_));
      _loc1_.rise_set_4b.lineTo(point4_x,point4_y);
      conRad = _loc1_.findControlRadius(point4_x,point4_y,point1_x,point1_y);
      conPt_41_x = 225 - conRad * Math.cos(_loc1_.radian(conAng));
      conPt_41_y = 225 - conRad * Math.sin(_loc1_.radian(conAng));
      _loc1_.rise_set_4b.curveTo(conPt_41_x,conPt_41_y,point1_x,point1_y);
      _loc1_.rise_set_4b.endFill();
   }
   _loc1_.createEmptyMovieClip("nev_rise_1",5);
   _loc1_.createEmptyMovieClip("nev_rise_2",6);
   _loc1_.createEmptyMovieClip("nev_rise_1b",16);
   _loc1_.createEmptyMovieClip("nev_rise_2b",17);
   if(_loc1_._lat < 45 && _loc1_._lat > -45)
   {
      _loc1_.nev_rise_1b._visible = false;
      _loc1_.nev_rise_2b._visible = false;
      var point1_x = 225 - 165 * Math.cos(_loc1_.radian(nev_start));
      var point1_y = 225 - 165 * Math.sin(_loc1_.radian(nev_start));
      _loc1_.nev_rise_1.moveTo(point1_x,point1_y);
      _loc1_.nev_rise_1.beginFill(_loc1_.nevColor,90);
      var point2_x = 225 - 178 * Math.cos(_loc1_.radian(nev_start));
      var point2_y = 225 - 178 * Math.sin(_loc1_.radian(nev_start));
      _loc1_.nev_rise_1.lineTo(point2_x,point2_y);
      var point3_x = 225 - 178 * Math.cos(_loc1_.radian(nev_end));
      var point3_y = 225 - 178 * Math.sin(_loc1_.radian(nev_end));
      var conAng = (nev_start + nev_end) / 2;
      var conRad = _loc1_.findControlRadius(point2_x,point2_y,point3_x,point3_y);
      var conPt_23_x = 225 - conRad * Math.cos(_loc1_.radian(conAng));
      var conPt_23_y = 225 - conRad * Math.sin(_loc1_.radian(conAng));
      _loc1_.nev_rise_1.curveTo(conPt_23_x,conPt_23_y,point3_x,point3_y);
      var point4_x = 225 - 165 * Math.cos(_loc1_.radian(nev_end));
      var point4_y = 225 - 165 * Math.sin(_loc1_.radian(nev_end));
      _loc1_.nev_rise_1.lineTo(point4_x,point4_y);
      conRad = _loc1_.findControlRadius(point4_x,point4_y,point1_x,point1_y);
      var conPt_41_x = 225 - conRad * Math.cos(_loc1_.radian(conAng));
      var conPt_41_y = 225 - conRad * Math.sin(_loc1_.radian(conAng));
      _loc1_.nev_rise_1.curveTo(conPt_41_x,conPt_41_y,point1_x,point1_y);
      _loc1_.nev_rise_1.endFill();
      point1_x = 225 - 165 * Math.cos(_loc1_.radian(180 - nev_start));
      point1_y = 225 - 165 * Math.sin(_loc1_.radian(180 - nev_start));
      _loc1_.nev_rise_2.moveTo(point1_x,point1_y);
      _loc1_.nev_rise_2.beginFill(_loc1_.nevColor,90);
      point2_x = 225 - 178 * Math.cos(_loc1_.radian(180 - nev_start));
      point2_y = 225 - 178 * Math.sin(_loc1_.radian(180 - nev_start));
      _loc1_.nev_rise_2.lineTo(point2_x,point2_y);
      point3_x = 225 - 178 * Math.cos(_loc1_.radian(nev_end));
      point3_y = 225 - 178 * Math.sin(_loc1_.radian(nev_end));
      conAng = (180 - nev_start + nev_end) / 2;
      conRad = _loc1_.findControlRadius(point2_x,point2_y,point3_x,point3_y);
      if(_loc1_._lat > 0)
      {
         conPt_23_x = 225 + conRad * Math.cos(_loc1_.radian(conAng));
         conPt_23_y = 225 + conRad * Math.sin(_loc1_.radian(conAng));
      }
      else
      {
         conPt_23_x = 225 - conRad * Math.cos(_loc1_.radian(conAng));
         conPt_23_y = 225 - conRad * Math.sin(_loc1_.radian(conAng));
      }
      _loc1_.nev_rise_2.curveTo(conPt_23_x,conPt_23_y,point3_x,point3_y);
      point4_x = 225 - 165 * Math.cos(_loc1_.radian(nev_end));
      point4_y = 225 - 165 * Math.sin(_loc1_.radian(nev_end));
      _loc1_.nev_rise_2.lineTo(point4_x,point4_y);
      conRad = _loc1_.findControlRadius(point4_x,point4_y,point1_x,point1_y);
      if(_loc1_._lat > 0)
      {
         conPt_41_x = 225 + conRad * Math.cos(_loc1_.radian(conAng));
         conPt_41_y = 225 + conRad * Math.sin(_loc1_.radian(conAng));
      }
      else
      {
         conPt_41_x = 225 - conRad * Math.cos(_loc1_.radian(conAng));
         conPt_41_y = 225 - conRad * Math.sin(_loc1_.radian(conAng));
      }
      _loc1_.nev_rise_2.curveTo(conPt_41_x,conPt_41_y,point1_x,point1_y);
      _loc1_.nev_rise_2.endFill();
   }
   else
   {
      if(_loc1_._lat <= 0)
      {
         var breakLat = 45;
      }
      else
      {
         var breakLat = -45;
      }
      var point1_x = 225 - 165 * Math.cos(_loc1_.radian(breakLat));
      var point1_y = 225 - 165 * Math.sin(_loc1_.radian(breakLat));
      _loc1_.nev_rise_1.moveTo(point1_x,point1_y);
      _loc1_.nev_rise_1.beginFill(_loc1_.nevColor,90);
      var point2_x = 225 - 178 * Math.cos(_loc1_.radian(breakLat));
      var point2_y = 225 - 178 * Math.sin(_loc1_.radian(breakLat));
      _loc1_.nev_rise_1.lineTo(point2_x,point2_y);
      var point3_x = 225 - 178 * Math.cos(_loc1_.radian(nev_end));
      var point3_y = 225 - 178 * Math.sin(_loc1_.radian(nev_end));
      var conAng = (breakLat + nev_end) / 2;
      var conRad = _loc1_.findControlRadius(point2_x,point2_y,point3_x,point3_y);
      var conPt_23_x = 225 - conRad * Math.cos(_loc1_.radian(conAng));
      var conPt_23_y = 225 - conRad * Math.sin(_loc1_.radian(conAng));
      _loc1_.nev_rise_1.curveTo(conPt_23_x,conPt_23_y,point3_x,point3_y);
      var point4_x = 225 - 165 * Math.cos(_loc1_.radian(nev_end));
      var point4_y = 225 - 165 * Math.sin(_loc1_.radian(nev_end));
      _loc1_.nev_rise_1.lineTo(point4_x,point4_y);
      conAng = (breakLat + nev_end) / 2;
      conRad = _loc1_.findControlRadius(point4_x,point4_y,point1_x,point1_y);
      var conPt_41_x = 225 - conRad * Math.cos(_loc1_.radian(conAng));
      var conPt_41_y = 225 - conRad * Math.sin(_loc1_.radian(conAng));
      _loc1_.nev_rise_1.curveTo(conPt_41_x,conPt_41_y,point1_x,point1_y);
      _loc1_.nev_rise_1.endFill();
      point1_x = 225 - 165 * Math.cos(_loc1_.radian(nev_start));
      point1_y = 225 - 165 * Math.sin(_loc1_.radian(nev_start));
      _loc1_.nev_rise_1b.moveTo(point1_x,point1_y);
      _loc1_.nev_rise_1b.beginFill(_loc1_.nevColor,90);
      point2_x = 225 - 178 * Math.cos(_loc1_.radian(nev_start));
      point2_y = 225 - 178 * Math.sin(_loc1_.radian(nev_start));
      _loc1_.nev_rise_1b.lineTo(point2_x,point2_y);
      point3_x = 225 - 178 * Math.cos(_loc1_.radian(breakLat));
      point3_y = 225 - 178 * Math.sin(_loc1_.radian(breakLat));
      conAng = (nev_start + breakLat) / 2;
      var conRad1 = _loc1_.findControlRadius(point2_x,point2_y,point3_x,point3_y);
      conPt_23_x = 225 - conRad1 * Math.cos(_loc1_.radian(conAng));
      conPt_23_y = 225 - conRad1 * Math.sin(_loc1_.radian(conAng));
      _loc1_.nev_rise_1b.curveTo(conPt_23_x,conPt_23_y,point3_x,point3_y);
      point4_x = 225 - 165 * Math.cos(_loc1_.radian(breakLat));
      point4_y = 225 - 165 * Math.sin(_loc1_.radian(breakLat));
      _loc1_.nev_rise_1b.lineTo(point4_x,point4_y);
      conRad = _loc1_.findControlRadius(point4_x,point4_y,point1_x,point1_y);
      conPt_41_x = 225 - conRad * Math.cos(_loc1_.radian(conAng));
      conPt_41_y = 225 - conRad * Math.sin(_loc1_.radian(conAng));
      _loc1_.nev_rise_1b.curveTo(conPt_41_x,conPt_41_y,point1_x,point1_y);
      _loc1_.nev_rise_1b.endFill();
      point1_x = 225 - 165 * Math.cos(_loc1_.radian(180 - breakLat));
      point1_y = 225 - 165 * Math.sin(_loc1_.radian(180 - breakLat));
      _loc1_.nev_rise_2.moveTo(point1_x,point1_y);
      _loc1_.nev_rise_2.beginFill(_loc1_.nevColor,90);
      point2_x = 225 - 178 * Math.cos(_loc1_.radian(180 - breakLat));
      point2_y = 225 - 178 * Math.sin(_loc1_.radian(180 - breakLat));
      _loc1_.nev_rise_2.lineTo(point2_x,point2_y);
      point3_x = 225 - 178 * Math.cos(_loc1_.radian(nev_end));
      point3_y = 225 - 178 * Math.sin(_loc1_.radian(nev_end));
      conAng = (180 - breakLat + nev_end) / 2;
      conRad = _loc1_.findControlRadius(point2_x,point2_y,point3_x,point3_y);
      if(_loc1_._lat > 0)
      {
         conPt_23_x = 225 + conRad * Math.cos(_loc1_.radian(conAng));
         conPt_23_y = 225 + conRad * Math.sin(_loc1_.radian(conAng));
      }
      else
      {
         conPt_23_x = 225 - conRad * Math.cos(_loc1_.radian(conAng));
         conPt_23_y = 225 - conRad * Math.sin(_loc1_.radian(conAng));
      }
      _loc1_.nev_rise_2.curveTo(conPt_23_x,conPt_23_y,point3_x,point3_y);
      point4_x = 225 - 165 * Math.cos(_loc1_.radian(nev_end));
      point4_y = 225 - 165 * Math.sin(_loc1_.radian(nev_end));
      _loc1_.nev_rise_2.lineTo(point4_x,point4_y);
      conRad = _loc1_.findControlRadius(point4_x,point4_y,point1_x,point1_y);
      if(_loc1_._lat > 0)
      {
         conPt_41_x = 225 + conRad * Math.cos(_loc1_.radian(conAng));
         conPt_41_y = 225 + conRad * Math.sin(_loc1_.radian(conAng));
      }
      else
      {
         conPt_41_x = 225 - conRad * Math.cos(_loc1_.radian(conAng));
         conPt_41_y = 225 - conRad * Math.sin(_loc1_.radian(conAng));
      }
      _loc1_.nev_rise_2.curveTo(conPt_41_x,conPt_41_y,point1_x,point1_y);
      _loc1_.nev_rise_2.endFill();
      point1_x = 225 - 165 * Math.cos(_loc1_.radian(180 - nev_start));
      point1_y = 225 - 165 * Math.sin(_loc1_.radian(180 - nev_start));
      _loc1_.nev_rise_2b.moveTo(point1_x,point1_y);
      _loc1_.nev_rise_2b.beginFill(_loc1_.nevColor,90);
      point2_x = 225 - 178 * Math.cos(_loc1_.radian(180 - nev_start));
      point2_y = 225 - 178 * Math.sin(_loc1_.radian(180 - nev_start));
      _loc1_.nev_rise_2b.lineTo(point2_x,point2_y);
      point3_x = 225 - 178 * Math.cos(_loc1_.radian(180 - breakLat));
      point3_y = 225 - 178 * Math.sin(_loc1_.radian(180 - breakLat));
      conAng = (180 - nev_start + (180 - breakLat)) / 2;
      conRad = conRad1;
      conPt_23_x = 225 - conRad * Math.cos(_loc1_.radian(conAng));
      conPt_23_y = 225 - conRad * Math.sin(_loc1_.radian(conAng));
      _loc1_.nev_rise_2b.curveTo(conPt_23_x,conPt_23_y,point3_x,point3_y);
      point4_x = 225 - 165 * Math.cos(_loc1_.radian(180 - breakLat));
      point4_y = 225 - 165 * Math.sin(_loc1_.radian(180 - breakLat));
      _loc1_.nev_rise_2b.lineTo(point4_x,point4_y);
      conRad = _loc1_.findControlRadius(point4_x,point4_y,point1_x,point1_y);
      conPt_41_x = 225 - conRad * Math.cos(_loc1_.radian(conAng));
      conPt_41_y = 225 - conRad * Math.sin(_loc1_.radian(conAng));
      _loc1_.nev_rise_2b.curveTo(conPt_41_x,conPt_41_y,point1_x,point1_y);
      _loc1_.nev_rise_2b.endFill();
   }
};
p.degree = function(rad)
{
   return rad * 57.29577951308232;
};
p.radian = function(deg)
{
   return deg * 0.017453292519943295;
};
p.findControlRadius = function(x1, y1, x2, y2)
{
   var con_rad;
   var _loc3_ = 225;
   var _loc1_ = 225;
   var slope1 = (_loc1_ - y1) / (_loc3_ - x1);
   var slope2 = (_loc1_ - y2) / (_loc3_ - x2);
   var _loc2_ = -1 / slope1;
   var tanSlope2 = -1 / slope2;
   if(_loc1_ - y2 == 0)
   {
      var x3 = x2;
      var y3 = x3 * _loc2_ - x1 * _loc2_ + y1;
   }
   else if(_loc1_ - y1 == 0)
   {
      var x3 = x1;
      var y3 = x3 * tanSlope2 - x2 * tanSlope2 + y2;
   }
   else
   {
      var x3 = (x1 * _loc2_ - y1 - x2 * tanSlope2 + y2) / (_loc2_ - tanSlope2);
      var y3 = x3 * _loc2_ - x1 * _loc2_ + y1;
   }
   con_rad = Math.sqrt((x3 - _loc3_) * (x3 - _loc3_) + (y3 - _loc1_) * (y3 - _loc1_));
   return con_rad;
};
p.setLatitude = function(arg)
{
   this._lat = arg;
};
p.getLatitude = function()
{
   return this._lat;
};
p.addProperty("lat",p.getLatitude,p.setLatitude);
