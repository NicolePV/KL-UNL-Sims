function MiniAboutLinkClass()
{
   var _loc2_ = this._width / 2;
   var _loc3_ = - this._height;
   this.createEmptyMovieClip("backgroundMC",0);
   this.backgroundMC.beginFill(16711680,0);
   this.backgroundMC.moveTo(- _loc2_,0);
   this.backgroundMC.lineTo(_loc2_,0);
   this.backgroundMC.lineTo(_loc2_,_loc3_);
   this.backgroundMC.lineTo(- _loc2_,_loc3_);
   this.backgroundMC.lineTo(- _loc2_,0);
   this.backgroundMC.endFill();
   this.createEmptyMovieClip("underlineMC",1);
   this.underlineMC.lineStyle(1,13260);
   this.underlineMC.moveTo(- _loc2_,0);
   this.underlineMC.lineTo(_loc2_,0);
   this.underlineMC._visible = false;
   this.attachMovie("Dialog Window v2","aboutWindowMC",2,{topLimit:- this._y,bottomLimit:Stage.height - this._y,leftLimit:- this._x,rightLimit:Stage.width - this._x,contentLinkageName:"About",title:"About",topLimit:0,buffer:5});
   this.aboutWindowMC.hide();
   this.backgroundMC._focusrect = false;
   this.backgroundMC.useHandCursor = true;
   this.backgroundMC.onSetFocus = function()
   {
      this._parent.underlineMC._visible = true;
      this.onKeyDown = this.onKeyDownFunc;
   };
   this.backgroundMC.onKillFocus = function()
   {
      this._parent.underlineMC._visible = false;
      delete this.onKeyDown;
   };
   this.backgroundMC.onKeyDownFunc = function()
   {
      if(Key.isDown(32))
      {
         this._parent.doToggle();
         this._parent.underlineMC._visible = false;
         delete this.onKeyDown;
      }
   };
   this.backgroundMC.onRollOver = function()
   {
      this._parent.underlineMC._visible = true;
   };
   this.backgroundMC.onRollOut = function()
   {
      this._parent.underlineMC._visible = false;
   };
   this.backgroundMC.onRelease = function()
   {
      this._parent.doToggle();
      this._parent.underlineMC._visible = false;
   };
   this.backgroundMC.onReleaseOutside = function()
   {
      this._parent.underlineMC._visible = false;
   };
}
var p = MiniAboutLinkClass.prototype = new MovieClip();
Object.registerClass("Mini About Link",MiniAboutLinkClass);
p.doToggle = function()
{
   if(this.aboutWindowMC.visible)
   {
      this.aboutWindowMC.hide();
   }
   else
   {
      this.aboutWindowMC.show();
   }
};
