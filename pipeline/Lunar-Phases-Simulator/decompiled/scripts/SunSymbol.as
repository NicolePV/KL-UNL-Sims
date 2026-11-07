function SunSymbolClass()
{
   this.stop();
}
var p = SunSymbolClass.prototype = new MovieClip();
Object.registerClass("SunSymbol",SunSymbolClass);
p.useHandCursor = false;
p.onRollOver = function()
{
   if(this._object._sp.z > 0)
   {
      this.gotoAndStop(2);
   }
};
p.onPress = function()
{
   var _loc3_;
   if(this._object._sp.z > 0)
   {
      _loc3_ = {};
      this._sphere.screenToCelestial({x:this._sphere._xmouse,y:this._sphere._ymouse},_loc3_);
      this._offset = _loc3_.ra - this._object.getRA();
      this._constantMoonRA = _root.sunRA() + _root.geometryDiagram.phase * 0.06666666666666667;
      this.onMouseMove = this.onMouseMoveFunc;
   }
};
p.onMouseMoveFunc = function()
{
   var _loc3_ = {};
   this._sphere.screenToCelestial({x:this._sphere._xmouse,y:this._sphere._ymouse},_loc3_);
   var _loc4_ = _loc3_.ra - this._offset;
   var _loc5_ = 12 - _loc4_;
   var _loc6_ = (this._constantMoonRA - _loc4_) * 15;
   _root.geometryDiagram.setTime(_loc5_);
   _root.geometryDiagram.setPhase(_loc6_);
   _root.timeAndPhaseChanged();
};
p.onRollOut = function()
{
   this.gotoAndStop(1);
};
p.onRelease = function()
{
   delete this.onMouseMove;
};
p.onReleaseOutside = function()
{
   this.gotoAndStop(1);
   delete this.onMouseMove;
};
