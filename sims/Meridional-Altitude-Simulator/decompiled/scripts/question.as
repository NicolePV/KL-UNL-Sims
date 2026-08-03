function questionClass()
{
   var _loc1_ = this;
   _loc1_.pole.textColor = _loc1_.merDiag.poleArrow.pole_arrow._myColor;
   _loc1_.pole_2.textColor = _loc1_.pole.textColor;
   _loc1_.equator.textColor = _loc1_.merDiag.poleArrow.equ_arrow1._myColor;
   _loc1_.sLabel.textColor = _loc1_.merDiag.southArrow._myColor;
   _loc1_.sLabel_2.textColor = _loc1_.sLabel.textColor;
   _loc1_.nLabel.textColor = _loc1_.merDiag.northArrow._myColor;
   _loc1_.nLabel_2.textColor = _loc1_.nLabel.textColor;
   _loc1_.zLabel.textColor = _loc1_.merDiag.zenithArrow._myColor;
   _loc1_.zLabel_2.textColor = _loc1_.zLabel.textColor;
   _loc1_._latColor = 14156033;
   _loc1_._decColor = 16776960;
   _loc1_.latFormat = new TextFormat();
   _loc1_.latFormat.color = _loc1_._latColor;
   _loc1_.decFormat = new TextFormat();
   _loc1_.decFormat.color = _loc1_._decColor;
   _loc1_.pole.text = "NCP";
   _loc1_.sLabel._visible = false;
   _loc1_.nLabel._visible = false;
   _loc1_._latitude = _loc1_.latSlider.initValue;
   _loc1_._dec = _loc1_.decSlider.initValue;
   _loc1_.tanDiag._lat = _loc1_._latitude;
   _loc1_._objVisible = true;
   _loc1_.objRad._value = _loc1_._obj;
}
var p = questionClass.prototype = new MovieClip();
Object.registerClass("question",questionClass);
p.onEnterFrame = function()
{
   var _loc1_ = this;
   _loc1_.decSlider._valueLabel.label_text.textColor = _loc1_._decColor;
   _loc1_.latSlider._valueLabel.label_text.textColor = _loc1_._latColor;
   _loc1_._obj = _loc1_.objRad.objValue;
   if(_loc1_._obj == 1)
   {
      _loc1_.myStar._visible = true;
      _loc1_.mySun._visible = false;
      _loc1_.myPlanet._visible = false;
      _loc1_.myMoon._visible = false;
      _loc1_.moveObj(_loc1_.myStar,_loc1_._dec);
      _loc1_.decSlider._visible = true;
      _loc1_.altitude._visible = true;
      _loc1_.decSlider.min = -90;
      _loc1_.decSlider.max = 90;
      _loc1_.decSlider.positionSlider();
   }
   else if(_loc1_._obj == 2)
   {
      _loc1_.myStar._visible = false;
      _loc1_.mySun._visible = true;
      _loc1_.myPlanet._visible = false;
      _loc1_.myMoon._visible = false;
      _loc1_.moveObj(_loc1_.mySun,_loc1_._dec);
      _loc1_.decSlider._visible = true;
      _loc1_.altitude._visible = true;
      _loc1_.decSlider.min = -23.5;
      _loc1_.decSlider.max = 23.5;
      if(_loc1_.decSlider.value > 23.5)
      {
         _loc1_.decSlider.value = 23.5;
         _loc1_._dec = _loc1_.decSlider.value;
      }
      else if(_loc1_.decSlider.value < -23.5)
      {
         _loc1_.decSlider.value = -23.5;
         _loc1_._dec = _loc1_.decSlider.value;
      }
      _loc1_.decSlider.positionSlider();
   }
   else if(_loc1_._obj == 3)
   {
      _loc1_.myStar._visible = false;
      _loc1_.mySun._visible = false;
      _loc1_.myPlanet._visible = true;
      _loc1_.myMoon._visible = false;
      _loc1_.moveObj(_loc1_.myPlanet,_loc1_._dec);
      _loc1_.decSlider._visible = true;
      _loc1_.altitude._visible = true;
      _loc1_.decSlider.min = -23.5;
      _loc1_.decSlider.max = 23.5;
      if(_loc1_.decSlider.value > 23.5)
      {
         _loc1_.decSlider.value = 23.5;
         _loc1_._dec = _loc1_.decSlider.value;
      }
      else if(_loc1_.decSlider.value < -23.5)
      {
         _loc1_.decSlider.value = -23.5;
         _loc1_._dec = _loc1_.decSlider.value;
      }
      _loc1_.decSlider.positionSlider();
   }
   else if(_loc1_._obj == 4)
   {
      _loc1_.myStar._visible = false;
      _loc1_.mySun._visible = false;
      _loc1_.myPlanet._visible = false;
      _loc1_.myMoon._visible = true;
      _loc1_.moveObj(_loc1_.myMoon,_loc1_._dec);
      _loc1_.decSlider._visible = true;
      _loc1_.altitude._visible = true;
      _loc1_.decSlider.min = -29.3;
      _loc1_.decSlider.max = 29.3;
      if(_loc1_.decSlider.value > 29.3)
      {
         _loc1_.decSlider.value = 29.3;
         _loc1_._dec = _loc1_.decSlider.value;
      }
      else if(_loc1_.decSlider.value < -29.3)
      {
         _loc1_.decSlider.value = -29.3;
         _loc1_._dec = _loc1_.decSlider.value;
      }
      _loc1_.decSlider.positionSlider();
   }
   else
   {
      _loc1_.mySun._visible = false;
      _loc1_.myStar._visible = false;
      _loc1_.myPlanet._visible = false;
      _loc1_.myMoon._visible = false;
      _loc1_.decSlider._visible = false;
      _loc1_.oneEighty._visible = false;
      _loc1_.altitude._visible = false;
      _loc1_.objLine._visible = false;
      _loc1_._objVisible = false;
   }
   _loc1_._latitude = 90 - _loc1_.tanDiag.angle;
   _loc1_.moveText();
   if(_loc1_._dec > 90 || _loc1_._dec < -90)
   {
      _loc1_._dec = 90;
   }
   if(_loc1_._latitude == 90 || _loc1_._latitude == -90)
   {
      _loc1_.nLabel._visible = false;
      _loc1_.sLabel._visible = false;
   }
   else
   {
      _loc1_.nLabel._visible = true;
      _loc1_.sLabel._visible = true;
   }
   if(_loc1_._latitude >= 0)
   {
      _loc1_.merDiag.poleArrow.equ_arrow1._visible = false;
      _loc1_.merDiag.poleArrow.right1._visible = false;
      _loc1_.merDiag.poleArrow.equ_arrow2._visible = true;
      _loc1_.merDiag.poleArrow.right2._visible = true;
   }
   else
   {
      _loc1_.merDiag.poleArrow.equ_arrow1._visible = true;
      _loc1_.merDiag.poleArrow.right1._visible = true;
      _loc1_.merDiag.poleArrow.equ_arrow2._visible = false;
      _loc1_.merDiag.poleArrow.right2._visible = false;
   }
   if(_loc1_.tanDiag.angle <= 90)
   {
      _loc1_.pole.text = "NCP";
      _loc1_.pole_2.text = "NCP";
      _loc1_.merDiag.poleArrow._rotation = 180 + _loc1_._latitude;
   }
   else
   {
      _loc1_.pole.text = "SCP";
      _loc1_.pole_2.text = "SCP";
      _loc1_.merDiag.poleArrow._rotation = _loc1_._latitude;
   }
   if(_loc1_.tanDiag.active)
   {
      _loc1_.latSlider.value = _loc1_._latitude;
   }
   _loc1_.tanDiag._lat = _loc1_.latSlider.value;
   _loc1_.tanDiag.setPos();
   _loc1_._dec = _loc1_.decSlider.value;
   _loc1_.drawAngles();
   if(_loc1_._objVisible)
   {
      _loc1_.decAngClip._visible = true;
   }
   else
   {
      _loc1_.decAngClip._visible = false;
   }
   _loc1_.createEmptyMovieClip("sunRange",6);
   _loc1_.sunRange.moveTo(_loc1_.merDiag._x,_loc1_.merDiag._y);
   _loc1_.createEmptyMovieClip("moonRange",7);
   _loc1_.moonRange.moveTo(_loc1_.merDiag._x,_loc1_.merDiag._y);
   var _loc3_;
   var _loc2_;
   if(_loc1_.ranges.showSunRange)
   {
      if(_loc1_._latitude > 66.5)
      {
         var point_rngCon_x = 125 * Math.cos(_loc1_.rad((90 - _loc1_._latitude + 23.5) / 2)) + _loc1_.merDiag._x;
         var point_rngCon_y = 125 * Math.sin(- _loc1_.rad((90 - _loc1_._latitude + 23.5) / 2)) + _loc1_.merDiag._y;
         var point_1_x = _loc1_.merDiag._x + 120;
         var point_1_y = _loc1_.merDiag._y;
         _loc3_ = 120 * Math.cos(_loc1_.rad(113.5 - _loc1_._latitude)) + _loc1_.merDiag._x;
         _loc2_ = 120 * Math.sin(- _loc1_.rad(113.5 - _loc1_._latitude)) + _loc1_.merDiag._y;
      }
      else if(_loc1_._latitude < -66.5)
      {
         var point_rngCon_x = 125 * Math.cos(_loc1_.rad(90 + (90 - _loc1_._latitude - 23.5) / 2)) + _loc1_.merDiag._x;
         var point_rngCon_y = 125 * Math.sin(- _loc1_.rad(90 + (90 - _loc1_._latitude - 23.5) / 2)) + _loc1_.merDiag._y;
         var point_1_x = 120 * Math.cos(_loc1_.rad(66.5 - _loc1_._latitude)) + _loc1_.merDiag._x;
         var point_1_y = 120 * Math.sin(- _loc1_.rad(66.5 - _loc1_._latitude)) + _loc1_.merDiag._y;
         _loc3_ = _loc1_.merDiag._x - 120;
         _loc2_ = _loc1_.merDiag._y;
      }
      else
      {
         var point_rngCon_x = 135 * Math.cos(_loc1_.rad(90 - _loc1_._latitude)) + _loc1_.merDiag._x;
         var point_rngCon_y = 135 * Math.sin(- _loc1_.rad(90 - _loc1_._latitude)) + _loc1_.merDiag._y;
         var point_1_x = 120 * Math.cos(_loc1_.rad(66.5 - _loc1_._latitude)) + _loc1_.merDiag._x;
         var point_1_y = 120 * Math.sin(- _loc1_.rad(66.5 - _loc1_._latitude)) + _loc1_.merDiag._y;
         _loc3_ = 120 * Math.cos(_loc1_.rad(113.5 - _loc1_._latitude)) + _loc1_.merDiag._x;
         _loc2_ = 120 * Math.sin(- _loc1_.rad(113.5 - _loc1_._latitude)) + _loc1_.merDiag._y;
      }
      _loc1_.sunRange._visible = true;
      _loc1_.sunRange.beginFill(16751001,40);
      _loc1_.sunRange.lineTo(point_1_x,point_1_y);
      _loc1_.sunRange.curveTo(point_rngCon_x,point_rngCon_y,_loc3_,_loc2_);
      _loc1_.sunRange.lineTo(_loc1_.merDiag._x,_loc1_.merDiag._y);
      _loc1_.sunRange.endFill();
   }
   else
   {
      _loc1_.sunRange._visible = false;
   }
   if(_loc1_.ranges.showMoonRange)
   {
      if(_loc1_._latitude > 60.7)
      {
         var point_rngCon_x = 128 * Math.cos(_loc1_.rad((90 - _loc1_._latitude + 29.3) / 2)) + _loc1_.merDiag._x;
         var point_rngCon_y = 128 * Math.sin(- _loc1_.rad((90 - _loc1_._latitude + 29.3) / 2)) + _loc1_.merDiag._y;
         var point_1_x = _loc1_.merDiag._x + 123;
         var point_1_y = _loc1_.merDiag._y;
         _loc3_ = 123 * Math.cos(_loc1_.rad(119.3 - _loc1_._latitude)) + _loc1_.merDiag._x;
         _loc2_ = 123 * Math.sin(- _loc1_.rad(119.3 - _loc1_._latitude)) + _loc1_.merDiag._y;
      }
      else if(_loc1_._latitude < -60.7)
      {
         var point_rngCon_x = 128 * Math.cos(_loc1_.rad(90 + (90 - _loc1_._latitude - 29.3) / 2)) + _loc1_.merDiag._x;
         var point_rngCon_y = 128 * Math.sin(- _loc1_.rad(90 + (90 - _loc1_._latitude - 29.3) / 2)) + _loc1_.merDiag._y;
         var point_1_x = 123 * Math.cos(_loc1_.rad(60.7 - _loc1_._latitude)) + _loc1_.merDiag._x;
         var point_1_y = 123 * Math.sin(- _loc1_.rad(60.7 - _loc1_._latitude)) + _loc1_.merDiag._y;
         _loc3_ = _loc1_.merDiag._x - 123;
         _loc2_ = _loc1_.merDiag._y;
      }
      else
      {
         var point_rngCon_x = 138 * Math.cos(_loc1_.rad(90 - _loc1_._latitude)) + _loc1_.merDiag._x;
         var point_rngCon_y = 138 * Math.sin(- _loc1_.rad(90 - _loc1_._latitude)) + _loc1_.merDiag._y;
         var point_1_x = 123 * Math.cos(_loc1_.rad(60.3 - _loc1_._latitude)) + _loc1_.merDiag._x;
         var point_1_y = 123 * Math.sin(- _loc1_.rad(60.3 - _loc1_._latitude)) + _loc1_.merDiag._y;
         _loc3_ = 123 * Math.cos(_loc1_.rad(119.3 - _loc1_._latitude)) + _loc1_.merDiag._x;
         _loc2_ = 123 * Math.sin(- _loc1_.rad(119.3 - _loc1_._latitude)) + _loc1_.merDiag._y;
      }
      _loc1_.moonRange._visible = true;
      _loc1_.moonRange.beginFill(16750899,40);
      _loc1_.moonRange.lineTo(point_1_x,point_1_y);
      _loc1_.moonRange.curveTo(point_rngCon_x,point_rngCon_y,_loc3_,_loc2_);
      _loc1_.moonRange.lineTo(_loc1_.merDiag._x,_loc1_.merDiag._y);
      _loc1_.moonRange.endFill();
   }
   else
   {
      _loc1_.moonRange._visible = false;
   }
   _loc1_.calcAlt();
};
p.moveObj = function(object, declin)
{
   var _loc1_ = this;
   var _loc3_ = object;
   var _loc2_ = _loc1_._latitude - 90 - declin;
   _loc1_.createEmptyMovieClip("objLine",2);
   if(_loc2_ < -180 || _loc2_ > 0)
   {
      _loc3_._visible = false;
      _loc1_.objLine._visible = false;
      _loc1_._objVisible = false;
   }
   else
   {
      _loc1_.objLine._visible = true;
      var lineX = 115 * Math.cos(_loc1_.rad(_loc2_)) + _loc1_.merDiag._x;
      var lineY = 115 * Math.sin(_loc1_.rad(_loc2_)) + _loc1_.merDiag._y;
      _loc3_._visible = true;
      _loc1_.objLine.moveTo(_loc1_.merDiag._x,_loc1_.merDiag._y);
      _loc1_.objLine.lineStyle(2,16777215,90);
      _loc1_.objLine.lineTo(lineX,lineY);
      _loc1_._objVisible = true;
   }
   var objX = 123 * Math.cos(_loc1_.rad(_loc2_)) + _loc1_.merDiag._x;
   var objY = 123 * Math.sin(_loc1_.rad(_loc2_)) + _loc1_.merDiag._y;
   _loc3_._x = objX;
   _loc3_._y = objY;
};
p.moveText = function()
{
   var _loc1_ = this;
   var _loc3_;
   var _loc2_;
   if(_loc1_._latitude >= 0)
   {
      _loc3_ = 130 * Math.cos(_loc1_.rad(_loc1_._latitude + 180)) + _loc1_.merDiag._x;
      _loc2_ = 130 * Math.sin(_loc1_.rad(_loc1_._latitude + 180)) + _loc1_.merDiag._y;
   }
   else
   {
      _loc3_ = 130 * Math.cos(_loc1_.rad(_loc1_._latitude)) + _loc1_.merDiag._x;
      _loc2_ = 130 * Math.sin(_loc1_.rad(_loc1_._latitude)) + _loc1_.merDiag._y;
   }
   var equTextX = 130 * Math.cos(_loc1_.rad(_loc1_._latitude - 90)) + _loc1_.merDiag._x;
   var equTextY = 130 * Math.sin(_loc1_.rad(_loc1_._latitude - 90)) + _loc1_.merDiag._y;
   _loc1_.pole._x = _loc3_ - 85;
   _loc1_.pole._y = _loc2_ - 26;
   _loc1_.equator._x = equTextX - 10;
   _loc1_.equator._y = equTextY - 27;
   var zTextX = 180 * Math.cos(_loc1_.rad(_loc1_._latitude)) + _loc1_.tanDiag._x + 5;
   var zTextY = 180 * Math.sin(- _loc1_.rad(_loc1_._latitude)) + _loc1_.tanDiag._y - _loc1_.zLabel._height;
   _loc1_.zLabel_2._x = zTextX;
   _loc1_.zLabel_2._y = zTextY;
   var nTextX = 130 * Math.cos(_loc1_.rad(90 + _loc1_._latitude)) + _loc1_.tanDiag._x + _loc1_.tanDiag._arrowX - 10;
   var nTextY = 130 * Math.sin(- _loc1_.rad(90 + _loc1_._latitude)) + _loc1_.tanDiag._y + _loc1_.tanDiag._arrowY - 10;
   _loc1_.nLabel_2._x = nTextX;
   _loc1_.nLabel_2._y = nTextY;
   var sTextX = 130 * Math.cos(_loc1_.rad(-90 + _loc1_._latitude)) + _loc1_.tanDiag._x + _loc1_.tanDiag._arrowX - 10;
   var sTextY = 130 * Math.sin(- _loc1_.rad(-90 + _loc1_._latitude)) + _loc1_.tanDiag._y + _loc1_.tanDiag._arrowY - 10;
   _loc1_.sLabel_2._x = sTextX;
   _loc1_.sLabel_2._y = sTextY;
   _loc3_ = _loc1_.tanDiag._x + _loc1_.tanDiag._arrowX + 10;
   if(_loc1_._latitude >= 0)
   {
      _loc2_ = -130 + _loc1_.tanDiag._y + _loc1_.tanDiag._arrowY;
   }
   else
   {
      _loc2_ = 110 + _loc1_.tanDiag._y + _loc1_.tanDiag._arrowY;
   }
   _loc1_.pole_2._x = _loc3_;
   _loc1_.pole_2._y = _loc2_;
};
p.drawAngles = function()
{
   var _loc1_ = this;
   var point_ce_x = 30 * Math.cos(_loc1_.rad(90 - _loc1_._latitude)) + _loc1_.merDiag._x;
   var point_ce_y = 30 * Math.sin(- _loc1_.rad(90 - _loc1_._latitude)) + _loc1_.merDiag._y;
   var point_obj_x = 30 * Math.cos(_loc1_.rad(90 - _loc1_._latitude + _loc1_._dec)) + _loc1_.merDiag._x;
   var point_obj_y = 30 * Math.sin(- _loc1_.rad(90 - _loc1_._latitude + _loc1_._dec)) + _loc1_.merDiag._y;
   var _loc3_ = 30 * Math.cos(_loc1_.rad(90 - _loc1_._latitude + _loc1_._dec / 2)) + _loc1_.merDiag._x;
   var _loc2_ = 30 * Math.sin(- _loc1_.rad(90 - _loc1_._latitude + _loc1_._dec / 2)) + _loc1_.merDiag._y;
   _loc1_.createEmptyMovieClip("decAngClip",1);
   _loc1_.decAngClip.moveTo(_loc1_.merDiag._x,_loc1_.merDiag._y);
   _loc1_.decAngClip.beginFill(_loc1_._decColor,80);
   _loc1_.decAngClip.lineTo(point_ce_x,point_ce_y);
   _loc1_.decAngClip.curveTo(_loc3_,_loc2_,point_obj_x,point_obj_y);
   _loc1_.decAngClip.lineTo(_loc1_.merDiag._x,_loc1_.merDiag._y);
   _loc1_.decAngClip.endFill();
   point_ce_x = _loc1_.tanDiag._x + 30;
   point_ce_y = _loc1_.tanDiag._y;
   var point_z_x = 30 * Math.cos(_loc1_.rad(_loc1_._latitude)) + _loc1_.tanDiag._x;
   var point_z_y = 30 * Math.sin(- _loc1_.rad(_loc1_._latitude)) + _loc1_.tanDiag._y;
   _loc3_ = 30 * Math.cos(_loc1_.rad(_loc1_._latitude / 2)) + _loc1_.tanDiag._x;
   _loc2_ = 30 * Math.sin(- _loc1_.rad(_loc1_._latitude / 2)) + _loc1_.tanDiag._y;
   _loc1_.createEmptyMovieClip("latAngClip_ce_z",3);
   _loc1_.latAngClip_ce_z.moveTo(_loc1_.tanDiag._x,_loc1_.tanDiag._y);
   _loc1_.latAngClip_ce_z.beginFill(_loc1_._latColor,80);
   _loc1_.latAngClip_ce_z.lineTo(point_ce_x,point_ce_y);
   _loc1_.latAngClip_ce_z.curveTo(_loc3_,_loc2_,point_z_x,point_z_y);
   _loc1_.latAngClip_ce_z.lineTo(_loc1_.tanDiag._x,_loc1_.tanDiag._y);
   _loc1_.latAngClip_ce_z.endFill();
   var point_cp_x = _loc1_.tanDiag._x + _loc1_.tanDiag._arrowX;
   if(_loc1_._latitude >= 0)
   {
      var point_cp_y = -30 + _loc1_.tanDiag._y + _loc1_.tanDiag._arrowY;
      var point_hor_x = 30 * Math.cos(_loc1_.rad(90 + _loc1_._latitude)) + _loc1_.tanDiag._x + _loc1_.tanDiag._arrowX;
      var point_hor_y = 30 * Math.sin(- _loc1_.rad(90 + _loc1_._latitude)) + _loc1_.tanDiag._y + _loc1_.tanDiag._arrowY;
      _loc3_ = 30 * Math.cos(_loc1_.rad(90 + _loc1_._latitude / 2)) + _loc1_.tanDiag._x + _loc1_.tanDiag._arrowX;
      _loc2_ = 30 * Math.sin(- _loc1_.rad(90 + _loc1_._latitude / 2)) + _loc1_.tanDiag._y + _loc1_.tanDiag._arrowY;
   }
   else
   {
      var point_cp_y = 30 + _loc1_.tanDiag._y + _loc1_.tanDiag._arrowY;
      var point_hor_x = 30 * Math.cos(_loc1_.rad(-90 + _loc1_._latitude)) + _loc1_.tanDiag._x + _loc1_.tanDiag._arrowX;
      var point_hor_y = 30 * Math.sin(- _loc1_.rad(-90 + _loc1_._latitude)) + _loc1_.tanDiag._y + _loc1_.tanDiag._arrowY;
      _loc3_ = 30 * Math.cos(_loc1_.rad(-90 + _loc1_._latitude / 2)) + _loc1_.tanDiag._x + _loc1_.tanDiag._arrowX;
      _loc2_ = 30 * Math.sin(- _loc1_.rad(-90 + _loc1_._latitude / 2)) + _loc1_.tanDiag._y + _loc1_.tanDiag._arrowY;
   }
   _loc1_.createEmptyMovieClip("latAngClip_cp_hor",4);
   _loc1_.latAngClip_cp_hor.moveTo(_loc1_.tanDiag._x + _loc1_.tanDiag._arrowX,_loc1_.tanDiag._y + _loc1_.tanDiag._arrowY);
   _loc1_.latAngClip_cp_hor.beginFill(_loc1_._latColor,80);
   _loc1_.latAngClip_cp_hor.lineTo(point_cp_x,point_cp_y);
   _loc1_.latAngClip_cp_hor.curveTo(_loc3_,_loc2_,point_hor_x,point_hor_y);
   _loc1_.latAngClip_cp_hor.lineTo(_loc1_.tanDiag._x + _loc1_.tanDiag._arrowX,_loc1_.tanDiag._y + _loc1_.tanDiag._arrowY);
   _loc1_.latAngClip_cp_hor.endFill();
   point_hor_y = _loc1_.merDiag._y;
   if(_loc1_._latitude >= 0)
   {
      point_hor_x = _loc1_.merDiag._x - 30;
      point_cp_x = 30 * Math.cos(_loc1_.rad(180 - _loc1_._latitude)) + _loc1_.merDiag._x;
      point_cp_y = 30 * Math.sin(- _loc1_.rad(180 - _loc1_._latitude)) + _loc1_.merDiag._y;
      _loc3_ = 30 * Math.cos(_loc1_.rad(180 - _loc1_._latitude / 2)) + _loc1_.merDiag._x;
      _loc2_ = 30 * Math.sin(- _loc1_.rad(180 - _loc1_._latitude / 2)) + _loc1_.merDiag._y;
   }
   else
   {
      point_hor_x = _loc1_.merDiag._x + 30;
      point_cp_x = 30 * Math.cos(_loc1_.rad(- _loc1_._latitude)) + _loc1_.merDiag._x;
      point_cp_y = 30 * Math.sin(- _loc1_.rad(- _loc1_._latitude)) + _loc1_.merDiag._y;
      _loc3_ = 30 * Math.cos(_loc1_.rad((- _loc1_._latitude) / 2)) + _loc1_.merDiag._x;
      _loc2_ = 30 * Math.sin(- _loc1_.rad((- _loc1_._latitude) / 2)) + _loc1_.merDiag._y;
   }
   _loc1_.createEmptyMovieClip("latAngClip_hor_cp",5);
   _loc1_.latAngClip_hor_cp.moveTo(_loc1_.merDiag._x,_loc1_.merDiag._y);
   _loc1_.latAngClip_hor_cp.beginFill(_loc1_._latColor,80);
   _loc1_.latAngClip_hor_cp.lineTo(point_hor_x,point_hor_y);
   _loc1_.latAngClip_hor_cp.curveTo(_loc3_,_loc2_,point_cp_x,point_cp_y);
   _loc1_.latAngClip_hor_cp.lineTo(_loc1_.merDiag._x,_loc1_.merDiag._y);
   _loc1_.latAngClip_hor_cp.endFill();
};
p.calcAlt = function()
{
   var _loc3_ = this;
   var _loc2_ = Math.round(10 * _loc3_._latitude) / 10;
   var latStr = Math.abs(_loc2_) + "";
   var _loc1_ = Math.round(10 * _loc3_._dec) / 10;
   var decStr = Math.abs(_loc1_) + "";
   if(_loc2_ >= 0)
   {
      if(90 - _loc2_ + _loc1_ <= 90)
      {
         _loc3_.oneEighty._visible = false;
         var alt_ans = Math.round(10 * (90 - _loc2_ + _loc1_)) / 10;
         if(_loc1_ >= 0)
         {
            var alt_equ = "90-" + _loc2_ + "+" + _loc1_ + "= " + alt_ans + "°";
         }
         else
         {
            var alt_equ = "90-" + _loc2_ + "" + _loc1_ + "= " + alt_ans + "°";
         }
      }
      else
      {
         if(_loc3_._obj == 0)
         {
            _loc3_.oneEighty._visible = false;
         }
         else
         {
            _loc3_.oneEighty._visible = true;
         }
         var alt_ans = Math.round(10 * (180 - (90 - _loc2_ + _loc1_))) / 10;
         if(_loc1_ >= 0)
         {
            var alt_equ = "90-" + _loc2_ + "+" + _loc1_ + ") = " + alt_ans + "°";
         }
         else
         {
            var alt_equ = "90-" + _loc2_ + "" + _loc1_ + ") = " + alt_ans + "°";
         }
      }
   }
   else if(90 + _loc2_ - _loc1_ <= 90)
   {
      _loc3_.oneEighty._visible = false;
      var alt_ans = Math.round(10 * (90 + _loc2_ - _loc1_)) / 10;
      if(_loc1_ >= 0)
      {
         var alt_equ = "90" + _loc2_ + "-" + _loc1_ + "= " + alt_ans + "°";
      }
      else
      {
         var alt_equ = "90" + _loc2_ + "+" + Math.abs(_loc1_) + "= " + alt_ans + "°";
      }
   }
   else
   {
      _loc3_.oneEighty._visible = true;
      var alt_ans = Math.round(10 * (180 - (90 + _loc2_ - _loc1_))) / 10;
      if(_loc1_ >= 0)
      {
         var alt_equ = "90" + _loc2_ + "-" + _loc1_ + ") = " + alt_ans + "°";
      }
      else
      {
         var alt_equ = "90" + _loc2_ + "+" + Math.abs(_loc1_) + ") = " + alt_ans + "°";
      }
   }
   _loc3_.altitude.text = alt_equ;
   _loc3_.altitude.setTextFormat(3,3 + latStr.length,_loc3_.latFormat);
   _loc3_.altitude.setTextFormat(4 + latStr.length,4 + latStr.length + decStr.length,_loc3_.decFormat);
};
p.rad = function(deg)
{
   return deg * 0.017453292519943295;
};
