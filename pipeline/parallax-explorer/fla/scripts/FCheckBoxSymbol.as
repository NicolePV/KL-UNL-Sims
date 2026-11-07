function FCheckBoxClass()
{
   this.init();
}
FCheckBoxClass.prototype = new FUIComponentClass();
Object.registerClass("FCheckBoxSymbol",FCheckBoxClass);
FCheckBoxClass.prototype.init = function()
{
   super.setSize(this._width,this._height);
   this.boundingBox_mc.unloadMovie();
   this.attachMovie("fcb_hitArea","fcb_hitArea_mc",1);
   this.attachMovie("fcb_states","fcb_states_mc",2);
   this.attachMovie("FLabelSymbol","fLabel_mc",3);
   super.init();
   this.setChangeHandler(this.changeHandler);
   this._xscale = 100;
   this._yscale = 100;
   this.setSize(this.width,this.height);
   if(this.initialValue == undefined)
   {
      this.setCheckState(false);
   }
   else
   {
      this.setCheckState(this.initialValue);
   }
   if(this.label != undefined)
   {
      this.setLabel(this.label);
   }
   this.ROLE_SYSTEM_CHECKBUTTON = 44;
   this.STATE_SYSTEM_CHECKED = 16;
   this.EVENT_OBJECT_STATECHANGE = 32778;
   this.EVENT_OBJECT_NAMECHANGE = 32780;
   this._accImpl.master = this;
   this._accImpl.stub = false;
   this._accImpl.get_accRole = this.get_accRole;
   this._accImpl.get_accName = this.get_accName;
   this._accImpl.get_accState = this.get_accState;
   this._accImpl.get_accDefaultAction = this.get_accDefaultAction;
   this._accImpl.accDoDefaultAction = this.accDoDefaultAction;
};
FCheckBoxClass.prototype.setLabelPlacement = function(pos)
{
   this.setLabel(this.getLabel());
   this.txtFormat(pos);
   var _loc8_ = this.fLabel_mc._height / 2;
   var _loc7_ = this.fcb_states_mc._height / 2;
   var _loc5_ = _loc7_ - _loc8_;
   var _loc6_ = this.fcb_states_mc._width;
   var _loc4_ = this.fcb_states_mc;
   var _loc9_ = this.fLabel_mc;
   var _loc2_ = 0;
   if(_loc4_._width > this.width)
   {
      _loc2_ = 0;
   }
   else
   {
      _loc2_ = this.width - _loc4_._width;
   }
   this.fLabel_mc.setSize(_loc2_);
   if(pos == "right" || pos == undefined)
   {
      this.labelPlacement = "right";
      this.fcb_states_mc._x = 0;
      this.fLabel_mc._x = _loc6_;
      this.txtFormat("left");
   }
   else if(pos == "left")
   {
      this.labelPlacement = "left";
      this.fLabel_mc._x = 0;
      this.fcb_states_mc._x = this.width - _loc6_;
      this.txtFormat("right");
   }
   this.fLabel_mc._y = _loc5_;
   this.fcb_hitArea_mc._y = _loc5_;
};
FCheckBoxClass.prototype.txtFormat = function(pos)
{
   var _loc3_ = this.textStyle;
   var _loc4_ = this.styleTable;
   _loc3_.align = _loc4_.textAlign.value != undefined ? undefined : (_loc3_.align = pos);
   _loc3_.leftMargin = _loc4_.textLeftMargin.value != undefined ? undefined : (_loc3_.leftMargin = 0);
   _loc3_.rightMargin = _loc4_.textRightMargin.value != undefined ? undefined : (_loc3_.rightMargin = 0);
   if(this.flabel_mc._height > this.height)
   {
      super.setSize(this.width,this.flabel_mc._height);
   }
   else
   {
      super.setSize(this.width,this.height);
   }
   this.fLabel_mc.labelField.setTextFormat(this.textStyle);
   this.setEnabled(this.enable);
};
FCheckBoxClass.prototype.setHitArea = function(w, h)
{
   var _loc3_ = this.fcb_hitArea_mc;
   this.hitArea = _loc3_;
   if(this.fcb_states_mc._width > w)
   {
      _loc3_._width = this.fcb_states_mc._width;
   }
   else
   {
      _loc3_._width = w;
   }
   _loc3_._visible = false;
   if(arguments.length > 1)
   {
      _loc3_._height = h;
   }
};
FCheckBoxClass.prototype.setSize = function(w)
{
   this.setLabel(this.getLabel());
   this.setLabelPlacement(this.labelPlacement);
   if(this.fcb_states_mc._height < this.flabel_mc.labelField._height)
   {
      super.setSize(w,this.flabel_mc.labelField._height);
   }
   this.setHitArea(this.width,this.height);
   this.setLabelPlacement(this.labelPlacement);
};
FCheckBoxClass.prototype.drawFocusRect = function()
{
   this.drawRect(-2,-2,this._width + 6,this._height - 1);
};
FCheckBoxClass.prototype.onPress = function()
{
   this.pressFocus();
   _root.focusRect.removeMovieClip();
   var _loc3_ = this.fcb_states_mc;
   if(this.getValue())
   {
      _loc3_.gotoAndStop("checkedPress");
   }
   else
   {
      _loc3_.gotoAndStop("press");
   }
};
FCheckBoxClass.prototype.onRelease = function()
{
   this.fcb_states_mc.gotoAndStop("up");
   this.setValue(!this.checked);
};
FCheckBoxClass.prototype.onReleaseOutside = function()
{
   var _loc2_ = this.fcb_states_mc;
   if(this.getValue())
   {
      _loc2_.gotoAndStop("checkedEnabled");
   }
   else
   {
      _loc2_.gotoAndStop("up");
   }
};
FCheckBoxClass.prototype.onDragOut = function()
{
   var _loc2_ = this.fcb_states_mc;
   if(this.getValue())
   {
      _loc2_.gotoAndStop("checkedEnabled");
   }
   else
   {
      _loc2_.gotoAndStop("up");
   }
};
FCheckBoxClass.prototype.onDragOver = function()
{
   var _loc2_ = this.fcb_states_mc;
   if(this.getValue())
   {
      _loc2_.gotoAndStop("checkedPress");
   }
   else
   {
      _loc2_.gotoAndStop("press");
   }
};
FCheckBoxClass.prototype.setValue = function(checkedValue)
{
   if(checkedValue || checkedValue == undefined)
   {
      this.setCheckState(checkedValue);
   }
   else if(checkedValue == false)
   {
      this.setCheckState(checkedValue);
   }
   this.executeCallBack();
   if(Accessibility.isActive())
   {
      Accessibility.sendEvent(this,0,this.EVENT_OBJECT_STATECHANGE,true);
   }
};
FCheckBoxClass.prototype.setCheckState = function(checkedValue)
{
   var _loc2_ = this.fcb_states_mc;
   if(this.enable)
   {
      this.flabel_mc.setEnabled(true);
      if(checkedValue || checkedValue == undefined)
      {
         _loc2_.gotoAndStop("checkedEnabled");
         this.enabled = true;
         this.checked = true;
      }
      else
      {
         _loc2_.gotoAndStop("up");
         this.enabled = true;
         this.checked = false;
      }
   }
   else
   {
      this.flabel_mc.setEnabled(false);
      if(checkedValue || checkedValue == undefined)
      {
         _loc2_.gotoAndStop("checkedDisabled");
         this.enabled = false;
         this.checked = true;
      }
      else
      {
         _loc2_.gotoAndStop("uncheckedDisabled");
         this.enabled = false;
         this.checked = false;
         this.focusRect.removeMovieClip();
      }
   }
};
FCheckBoxClass.prototype.getValue = function()
{
   return this.checked;
};
FCheckBoxClass.prototype.setEnabled = function(enable)
{
   if(enable == true || enable == undefined)
   {
      this.enable = true;
      super.setEnabled(true);
   }
   else
   {
      this.enable = false;
      super.setEnabled(false);
   }
   this.setCheckState(this.checked);
};
FCheckBoxClass.prototype.getEnabled = function()
{
   return this.enable;
};
FCheckBoxClass.prototype.setLabel = function(label)
{
   this.fLabel_mc.setLabel(label);
   this.txtFormat();
   if(Accessibility.isActive())
   {
      Accessibility.sendEvent(this,0,this.EVENT_OBJECT_NAMECHANGE);
   }
};
FCheckBoxClass.prototype.getLabel = function()
{
   return this.fLabel_mc.labelField.text;
};
FCheckBoxClass.prototype.setTextColor = function(color)
{
   this.fLabel_mc.labelField.textColor = color;
};
FCheckBoxClass.prototype.myOnKeyDown = function()
{
   if(Key.getCode() == 32 && this.pressOnce == undefined && this.enabled == true)
   {
      this.setValue(!this.getValue());
      this.pressOnce = true;
   }
};
FCheckBoxClass.prototype.myOnKeyUp = function()
{
   if(Key.getCode() == 32)
   {
      this.pressOnce = undefined;
   }
};
FCheckBoxClass.prototype.get_accRole = function(childId)
{
   return this.master.ROLE_SYSTEM_CHECKBUTTON;
};
FCheckBoxClass.prototype.get_accName = function(childId)
{
   return this.master.getLabel();
};
FCheckBoxClass.prototype.get_accState = function(childId)
{
   if(this.master.getValue())
   {
      return this.master.STATE_SYSTEM_CHECKED;
   }
   return 0;
};
FCheckBoxClass.prototype.get_accDefaultAction = function(childId)
{
   if(this.master.getValue())
   {
      return "UnCheck";
   }
   return "Check";
};
FCheckBoxClass.prototype.accDoDefaultAction = function(childId)
{
   this.master.setValue(!this.master.getValue());
};
