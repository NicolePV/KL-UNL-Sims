function MoonSymbolClass()
{
   this.stop();
}
var p = MoonSymbolClass.prototype = new MovieClip();
Object.registerClass("MoonSymbol",MoonSymbolClass);
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
   var _loc2_;
   if(this._object._sp.z > 0)
   {
      _loc2_ = {};
      this._sphere.screenToCelestial({x:this._sphere._xmouse,y:this._sphere._ymouse},_loc2_);
      this._offset = _loc2_.ra - this._object.getRA();
      this.onMouseMove = this.onMouseMoveFunc;
   }
};
p.onMouseMoveFunc = function()
{
   var _loc3_ = {};
   this._sphere.screenToCelestial({x:this._sphere._xmouse,y:this._sphere._ymouse},_loc3_);
   var _loc4_ = _loc3_.ra - this._offset;
   var _loc5_ = (_loc4_ - _root.sunRA()) * 15;
   _root.geometryDiagram.setPhase(_loc5_);
   _root.phaseChanged();
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
