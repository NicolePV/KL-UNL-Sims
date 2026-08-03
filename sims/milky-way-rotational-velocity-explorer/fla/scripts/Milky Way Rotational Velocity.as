function MilkyWayRotationalVelocityClass()
{
   var _loc1_ = this;
   _loc1_.attachMovie("MWRV Draggable Point","pointMC",100,{_x:100});
   _loc1_.createEmptyMovieClip("curveMC",10);
   _loc1_.attachMovie("MWRV Dashed Line","verticalLineMC",30,{_rotation:-90});
   _loc1_.attachMovie("MWRV Dashed Line","horizontalLineMC",40);
   _loc1_.createEmptyMovieClip("verticalLineMaskMC",31);
   _loc1_.createEmptyMovieClip("horizontalLineMaskMC",41);
   _loc1_.verticalLineMC.setMask(_loc1_.verticalLineMaskMC);
   _loc1_.horizontalLineMC.setMask(_loc1_.horizontalLineMaskMC);
   _loc1_.equationMC.swapDepths(50);
   _loc1_.distance = 0;
   _loc1_.drawCurve();
   _loc1_.snapPointToCurve();
}
var p = MilkyWayRotationalVelocityClass.prototype = new MovieClip();
Object.registerClass("Milky Way Rotational Velocity",MilkyWayRotationalVelocityClass);
p.plotWidth = 500;
p.plotHeight = 250;
p.maxDistance = 40;
p.maxVelocity = 300;
p.updateEquation = function()
{
   var _loc1_ = this;
   var G = 0.000004298675311966532;
   var _loc3_ = _loc1_.xScale * _loc1_.pointMC._x;
   _loc1_.distance = _loc3_;
   var _loc2_ = _loc1_.yScale * _loc1_.pointMC._y;
   _loc1_.equationMC.distanceField.text = "(" + _loc3_.toFixed(1) + " kpc)";
   _loc1_.equationMC.velocityField.text = "(" + Math.toSigDigits(_loc2_,3) + " km/s)";
   _loc1_.equationMC.massNumber.setValue(_loc2_ * _loc2_ * _loc3_ / G);
   _loc1_.equationMC.solarMassMC._x = 10 + _loc1_.equationMC.massNumber._x + (_loc1_.equationMC.massNumber.exponentField._x + _loc1_.equationMC.massNumber.exponentField.textWidth);
};
p.updateDashedLines = function()
{
   var _loc2_ = this;
   var x = _loc2_.pointMC._x;
   var _loc3_ = _loc2_.pointMC._y;
   _loc2_.verticalLineMC._x = x;
   _loc2_.horizontalLineMC._y = _loc3_;
   var _loc1_ = _loc2_.verticalLineMaskMC;
   _loc1_.clear();
   _loc1_.beginFill(16711680,20);
   _loc1_.moveTo(-10,0);
   _loc1_.lineTo(_loc2_.plotWidth + 10,0);
   _loc1_.lineTo(_loc2_.plotWidth + 10,_loc3_);
   _loc1_.lineTo(-10,_loc3_);
   _loc1_.lineTo(-10,0);
   _loc1_.endFill();
   _loc1_ = _loc2_.horizontalLineMaskMC;
   _loc1_.clear();
   _loc1_.beginFill(255,20);
   _loc1_.moveTo(0,10);
   _loc1_.lineTo(x,10);
   _loc1_.lineTo(x,- _loc2_.plotHeight - 10);
   _loc1_.lineTo(0,- _loc2_.plotHeight - 10);
   _loc1_.lineTo(0,10);
   _loc1_.endFill();
};
p.snapPointToCurve = function()
{
   var _loc2_ = this;
   if(_loc2_.pointMC._y > -100)
   {
      _loc2_.pointMC._y = -100;
   }
   if(_loc2_.pointMC._x < 10)
   {
      _loc2_.pointMC._x = 10;
   }
   var x = _loc2_.pointMC._x;
   var _loc1_;
   var _loc3_;
   if(x <= _loc2_.leftmostX)
   {
      _loc2_.pointMC._x = _loc2_.leftmostX;
      _loc2_.pointMC._y = 0;
   }
   else if(x >= _loc2_.rightmostX)
   {
      _loc2_.pointMC._x = _loc2_.rightmostX;
      _loc2_.pointMC._y = _loc2_.rightmostY;
   }
   else
   {
      var pL = _loc2_.pointsList;
      var x_ = x / _loc2_.pointsXScale;
      if(x_ < pL[0].ax)
      {
         var y_ = _loc2_.pointMC._y / _loc2_.pointsYScale;
         var p = pL[0];
         var x0 = _loc2_.startPoint.x;
         var y0 = _loc2_.startPoint.y;
         var x1 = p.cx;
         var y1 = p.cy;
         var x2 = p.ax;
         var y2 = p.ay;
         var a = y0 - 2 * y1 + y2;
         var b = 2 * y1 - 2 * y0;
         var c = y0 - y_;
         var d = b * b - 4 * a * c;
         if(a == 0)
         {
            _loc1_ = (- c) / b;
         }
         else if(d < 0)
         {
            _loc1_ = 0.5;
         }
         else
         {
            var u1 = (- b + Math.sqrt(d)) / (2 * a);
            _loc3_ = (- b - Math.sqrt(d)) / (2 * a);
            if(u1 >= 0 && u1 <= 1)
            {
               _loc1_ = u1;
            }
            else if(_loc3_ >= 0 && _loc3_ <= 1)
            {
               _loc1_ = _loc3_;
            }
            else
            {
               if(u1 < 0)
               {
                  var d1 = - u1;
               }
               else
               {
                  d1 -= 1;
               }
               if(_loc3_ < 0)
               {
                  var d2 = - _loc3_;
               }
               else
               {
                  d2 -= 1;
               }
               if(d1 < d2)
               {
                  _loc1_ = u1;
               }
               else
               {
                  _loc1_ = _loc3_;
               }
               if(_loc1_ < 0)
               {
                  _loc1_ = 0;
               }
               else if(_loc1_ > 1)
               {
                  _loc1_ = 1;
               }
            }
         }
         var a = (1 - _loc1_) * (1 - _loc1_);
         var b = 2 * _loc1_ * (1 - _loc1_);
         var c = _loc1_ * _loc1_;
         _loc2_.pointMC._x = _loc2_.pointsXScale * (a * x0 + b * x1 + c * x2);
         _loc2_.pointMC._y = _loc2_.pointsYScale * (a * y0 + b * y1 + c * y2);
      }
      else
      {
         var i = 1;
         while(i < pL.length)
         {
            if(x_ < pL[i].ax)
            {
               var p = pL[i];
               var x0 = pL[i - 1].ax;
               var y0 = pL[i - 1].ay;
               var x1 = p.cx;
               var y1 = p.cy;
               var x2 = p.ax;
               var y2 = p.ay;
               var a = x0 - 2 * x1 + x2;
               var b = 2 * x1 - 2 * x0;
               var c = x0 - x_;
               var d = b * b - 4 * a * c;
               if(a == 0)
               {
                  _loc1_ = (- c) / b;
               }
               else if(d < 0)
               {
                  _loc1_ = 0.5;
               }
               else
               {
                  var u1 = (- b + Math.sqrt(d)) / (2 * a);
                  _loc3_ = (- b - Math.sqrt(d)) / (2 * a);
                  if(u1 >= 0 && u1 <= 1)
                  {
                     _loc1_ = u1;
                  }
                  else if(_loc3_ >= 0 && _loc3_ <= 1)
                  {
                     _loc1_ = _loc3_;
                  }
                  else
                  {
                     if(u1 < 0)
                     {
                        var d1 = - u1;
                     }
                     else
                     {
                        d1 -= 1;
                     }
                     if(_loc3_ < 0)
                     {
                        var d2 = - _loc3_;
                     }
                     else
                     {
                        d2 -= 1;
                     }
                     if(d1 < d2)
                     {
                        _loc1_ = u1;
                     }
                     else
                     {
                        _loc1_ = _loc3_;
                     }
                     if(_loc1_ < 0)
                     {
                        _loc1_ = 0;
                     }
                     else if(_loc1_ > 1)
                     {
                        _loc1_ = 1;
                     }
                  }
               }
               var a = (1 - _loc1_) * (1 - _loc1_);
               var b = 2 * _loc1_ * (1 - _loc1_);
               var c = _loc1_ * _loc1_;
               _loc2_.pointMC._x = _loc2_.pointsXScale * (a * x0 + b * x1 + c * x2);
               _loc2_.pointMC._y = _loc2_.pointsYScale * (a * y0 + b * y1 + c * y2);
               break;
            }
            i++;
         }
      }
   }
   _loc2_.updateDashedLines();
   _loc2_.updateEquation();
   _loc2_.onPointDragged();
};
p.drawCurve = function()
{
   var xs = this.pointsXScale;
   var _loc3_ = this.pointsYScale;
   var mc = this.curveMC;
   mc.clear();
   mc.lineStyle(2,16740464,100);
   mc.moveTo(xs * this.startPoint.x,_loc3_ * this.startPoint.y);
   var pL = this.pointsList;
   var _loc2_ = 0;
   var _loc1_;
   while(_loc2_ < pL.length)
   {
      _loc1_ = pL[_loc2_];
      mc.curveTo(xs * _loc1_.cx,_loc3_ * _loc1_.cy,xs * _loc1_.ax,_loc3_ * _loc1_.ay);
      _loc2_ = _loc2_ + 1;
   }
};
p.xScale = p.maxDistance / p.plotWidth;
p.yScale = (- p.maxVelocity) / p.plotHeight;
p.pointsXScale = 0.055031446540880505 / p.xScale;
p.pointsYScale = -1.1070110701107012 / p.yScale;
p.startPoint = {x:7.75,y:0};
p.pointsList = [{cx:15.9,cy:-134.3,ax:20.7,ay:-219.8},{cx:21.5,cy:-233.1,ax:34.7,ay:-222.9},{cx:49.1,cy:-211.7,ax:59,ay:-196.2},{cx:69.2,cy:-180,ax:86.8,ay:-183.2},{cx:95.9,cy:-184.8,ax:110,ay:-201.5},{cx:121.5,cy:-215.3,ax:133,ay:-214},{cx:147.2,cy:-212.4,ax:158.3,ay:-200.8},{cx:167.6,cy:-191,ax:182,ay:-192.1},{cx:192.4,cy:-192.8,ax:204.5,ay:-206.1},{cx:212.4,cy:-214.7,ax:222.8,ay:-218.8},{cx:232.6,cy:-222.6,ax:250,ay:-221.9},{cx:260.6,cy:-221.5,ax:269.3,ay:-220.6},{cx:278.7,cy:-219.6,ax:287.5,ay:-219.7},{cx:296.2,cy:-219.8,ax:308,ay:-222.9},{cx:316.4,cy:-225.1,ax:328.3,ay:-225},{cx:394.2,cy:-224,ax:513,ay:-236.2},{cx:582.3,cy:-243.2,ax:710.3,ay:-263.7}];
p.leftmostX = p.startPoint.x * p.pointsXScale;
p.rightmostX = p.pointsList[p.pointsList.length - 1].ax * p.pointsXScale;
p.rightmostY = p.pointsList[p.pointsList.length - 1].ay * p.pointsYScale;
