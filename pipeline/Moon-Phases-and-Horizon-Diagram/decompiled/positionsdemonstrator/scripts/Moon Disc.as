function MoonDiscClass()
{
   var _loc1_ = this;
   _loc1_.stop();
   _loc1_.lineColor = _loc1_.normalLineColor;
   _loc1_.setShowPhase(false);
}
var p = MoonDiscClass.prototype = new MovieClip();
Object.registerClass("Moon Disc",MoonDiscClass);
p.radius = 12;
p.darkColor = 9474192;
p.lightColor = 13684944;
p.normalLineColor = 8421504;
p.mouseOverLineColor = 0;
p.solidColor = 11053224;
p.useHandCursor = false;
p.setShowPhase = function(arg)
{
   this._showPhase = arg;
   this.update();
};
p.update = function()
{
   var _loc1_ = this;
   var _loc2_;
   if(_loc1_._showPhase)
   {
      _loc2_ = 15 * (_loc1_._sphere.sun.ra - _loc1_._sphere.moon.ra) + 180;
      _loc1_.drawPhaseDisc(_loc2_,{radius:_loc1_.radius,lightColor:_loc1_.lightColor,darkColor:_loc1_.darkColor,lineThickness:0,lineAlpha:100,lineColor:_loc1_.lineColor});
   }
   else
   {
      _loc1_.drawPhaseDisc(180,{radius:_loc1_.radius,lightColor:_loc1_.solidColor,darkColor:_loc1_.solidColor,lineThickness:0,lineAlpha:100,lineColor:_loc1_.lineColor});
   }
};
p.onRollOver = function()
{
   var _loc1_ = this;
   if(_loc1_._object._sp.z > 0 && _loc1_._sphere._parent.getMoonDiscEnabled())
   {
      _loc1_.lineColor = _loc1_.mouseOverLineColor;
      _loc1_.update();
   }
};
p.onPress = function()
{
   var _loc1_ = this;
   var _loc2_;
   if(_loc1_._object._sp.z > 0 && _loc1_._sphere._parent.getMoonDiscEnabled())
   {
      _loc2_ = {};
      _loc1_._sphere.screenToCelestial({x:_loc1_._sphere._xmouse,y:_loc1_._sphere._ymouse},_loc2_);
      _loc1_._offset = _loc2_.ra - _loc1_._object.getRA();
      _loc1_.onMouseMove = _loc1_.onMouseMoveFunc;
   }
};
p.onMouseMoveFunc = function()
{
   var _loc1_ = this;
   var _loc3_ = {};
   _loc1_._sphere.screenToCelestial({x:_loc1_._sphere._xmouse,y:_loc1_._sphere._ymouse},_loc3_);
   var newRa = _loc3_.ra - _loc1_._offset;
   var _loc2_ = 1 + (newRa - 6) / -3;
   _loc2_ = 0.5 + ((_loc2_ - 0.5) % 8 + 8) % 8;
   _loc1_._sphere._parent.moonPositionSlider.setValue(_loc2_,true);
   updateAfterEvent();
};
p.onRollOut = function()
{
   var _loc1_ = this;
   _loc1_.lineColor = _loc1_.normalLineColor;
   _loc1_.update();
};
p.onRelease = function()
{
   this._sphere._parent.moonPositionSlider.grabberMC.doTween();
   delete this.onMouseMove;
};
p.onReleaseOutside = function()
{
   this.onRollOut();
   this.onRelease();
};
