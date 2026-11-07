function FCheckBoxClass()
{
   this.init();
}
FCheckBoxClass.prototype = new FUIComponentClass();
Object.registerClass("FCheckBoxSymbol",FCheckBoxClass);
FCheckBoxClass.prototype.init = function()
{
   var _loc1_ = this;
   super.setSize(_loc1_._width,_loc1_._height);
   _loc1_.boundingBox_mc.unloadMovie();
   _loc1_.attachMovie("fcb_hitArea","fcb_hitArea_mc",1);
   _loc1_.attachMovie("fcb_states","fcb_states_mc",2);
   _loc1_.attachMovie("FLabelSymbol","fLabel_mc",3);
   super.init();
   _loc1_.setChangeHandler(_loc1_.changeHandler);
   _loc1_._xscale = 100;
   _loc1_._yscale = 100;
   _loc1_.setSize(_loc1_.width,_loc1_.height);
   if(_loc1_.initialValue == undefined)
   {
      _loc1_.setCheckState(false);
   }
   else
   {
      _loc1_.setCheckState(_loc1_.initialValue);
   }
   if(_loc1_.label != undefined)
   {
      _loc1_.setLabel(_loc1_.label);
   }
   _loc1_.ROLE_SYSTEM_CHECKBUTTON = 44;
   _loc1_.STATE_SYSTEM_CHECKED = 16;
   _loc1_.EVENT_OBJECT_STATECHANGE = 32778;
   _loc1_.EVENT_OBJECT_NAMECHANGE = 32780;
   _loc1_._accImpl.master = _loc1_;
   _loc1_._accImpl.stub = false;
   _loc1_._accImpl.get_accRole = _loc1_.get_accRole;
   _loc1_._accImpl.get_accName = _loc1_.get_accName;
   _loc1_._accImpl.get_accState = _loc1_.get_accState;
   _loc1_._accImpl.get_accDefaultAction = _loc1_.get_accDefaultAction;
   _loc1_._accImpl.accDoDefaultAction = _loc1_.accDoDefaultAction;
};
FCheckBoxClass.prototype.setLabelPlacement = function(pos)
{
   var _loc1_ = this;
   var _loc3_ = pos;
   _loc1_.setLabel(_loc1_.getLabel());
   _loc1_.txtFormat(_loc3_);
   var halfLabelH = _loc1_.fLabel_mc._height / 2;
   var halfFrameH = _loc1_.fcb_states_mc._height / 2;
   var vertCenter = halfFrameH - halfLabelH;
   var checkWidth = _loc1_.fcb_states_mc._width;
   var frame = _loc1_.fcb_states_mc;
   var label = _loc1_.fLabel_mc;
   var _loc2_ = 0;
   if(frame._width > _loc1_.width)
   {
      _loc2_ = 0;
   }
   else
   {
      _loc2_ = _loc1_.width - frame._width;
   }
   _loc1_.fLabel_mc.setSize(_loc2_);
   if(_loc3_ == "right" || _loc3_ == undefined)
   {
      _loc1_.labelPlacement = "right";
      _loc1_.fcb_states_mc._x = 0;
      _loc1_.fLabel_mc._x = checkWidth;
      _loc1_.txtFormat("left");
   }
   else if(_loc3_ == "left")
   {
      _loc1_.labelPlacement = "left";
      _loc1_.fLabel_mc._x = 0;
      _loc1_.fcb_states_mc._x = _loc1_.width - checkWidth;
      _loc1_.txtFormat("right");
   }
   _loc1_.fLabel_mc._y = vertCenter;
   _loc1_.fcb_hitArea_mc._y = vertCenter;
};
FCheckBoxClass.prototype.txtFormat = function(pos)
{
   var _loc1_ = this;
   var _loc2_ = _loc1_.textStyle;
   var _loc3_ = _loc1_.styleTable;
   _loc2_.align = _loc3_.textAlign.value != undefined ? undefined : (_loc2_.align = pos);
   _loc2_.leftMargin = _loc3_.textLeftMargin.value != undefined ? undefined : (_loc2_.leftMargin = 0);
   _loc2_.rightMargin = _loc3_.textRightMargin.value != undefined ? undefined : (_loc2_.rightMargin = 0);
   if(_loc1_.flabel_mc._height > _loc1_.height)
   {
      super.setSize(_loc1_.width,_loc1_.flabel_mc._height);
   }
   else
   {
      super.setSize(_loc1_.width,_loc1_.height);
   }
   _loc1_.fLabel_mc.labelField.setTextFormat(_loc1_.textStyle);
   _loc1_.setEnabled(_loc1_.enable);
};
FCheckBoxClass.prototype.setHitArea = function(w, h)
{
   var _loc2_ = this;
   var _loc1_ = _loc2_.fcb_hitArea_mc;
   _loc2_.hitArea = _loc1_;
   if(_loc2_.fcb_states_mc._width > w)
   {
      _loc1_._width = _loc2_.fcb_states_mc._width;
   }
   else
   {
      _loc1_._width = w;
   }
   _loc1_._visible = false;
   if(arguments.length > 1)
   {
      _loc1_._height = h;
   }
};
FCheckBoxClass.prototype.setSize = function(w)
{
   var _loc1_ = this;
   _loc1_.setLabel(_loc1_.getLabel());
   _loc1_.setLabelPlacement(_loc1_.labelPlacement);
   if(_loc1_.fcb_states_mc._height < _loc1_.flabel_mc.labelField._height)
   {
      super.setSize(w,_loc1_.flabel_mc.labelField._height);
   }
   _loc1_.setHitArea(_loc1_.width,_loc1_.height);
   _loc1_.setLabelPlacement(_loc1_.labelPlacement);
};
FCheckBoxClass.prototype.drawFocusRect = function()
{
   var _loc1_ = this;
   _loc1_.drawRect(-2,-2,_loc1_._width + 6,_loc1_._height - 1);
};
FCheckBoxClass.prototype.onPress = function()
{
   var _loc2_ = this;
   _loc2_.pressFocus();
   _root.focusRect.removeMovieClip();
   var _loc1_ = _loc2_.fcb_states_mc;
   if(_loc2_.getValue())
   {
      _loc1_.gotoAndStop("checkedPress");
   }
   else
   {
      _loc1_.gotoAndStop("press");
   }
};
FCheckBoxClass.prototype.onRelease = function()
{
   var _loc1_ = this;
   _loc1_.fcb_states_mc.gotoAndStop("up");
   _loc1_.setValue(!_loc1_.checked);
};
FCheckBoxClass.prototype.onReleaseOutside = function()
{
   var _loc1_ = this.fcb_states_mc;
   if(this.getValue())
   {
      _loc1_.gotoAndStop("checkedEnabled");
   }
   else
   {
      _loc1_.gotoAndStop("up");
   }
};
FCheckBoxClass.prototype.onDragOut = function()
{
   var _loc1_ = this.fcb_states_mc;
   if(this.getValue())
   {
      _loc1_.gotoAndStop("checkedEnabled");
   }
   else
   {
      _loc1_.gotoAndStop("up");
   }
};
FCheckBoxClass.prototype.onDragOver = function()
{
   var _loc1_ = this.fcb_states_mc;
   if(this.getValue())
   {
      _loc1_.gotoAndStop("checkedPress");
   }
   else
   {
      _loc1_.gotoAndStop("press");
   }
};
FCheckBoxClass.prototype.setValue = function(checkedValue)
{
   var _loc1_ = this;
   var _loc2_ = checkedValue;
   if(_loc2_ || _loc2_ == undefined)
   {
      _loc1_.setCheckState(_loc2_);
   }
   else if(_loc2_ == false)
   {
      _loc1_.setCheckState(_loc2_);
   }
   _loc1_.executeCallBack();
   if(Accessibility.isActive())
   {
      Accessibility.sendEvent(_loc1_,0,_loc1_.EVENT_OBJECT_STATECHANGE,true);
   }
};
FCheckBoxClass.prototype.setCheckState = function(checkedValue)
{
   var _loc1_ = this;
   var _loc3_ = checkedValue;
   var _loc2_ = _loc1_.fcb_states_mc;
   if(_loc1_.enable)
   {
      _loc1_.flabel_mc.setEnabled(true);
      if(_loc3_ || _loc3_ == undefined)
      {
         _loc2_.gotoAndStop("checkedEnabled");
         _loc1_.enabled = true;
         _loc1_.checked = true;
      }
      else
      {
         _loc2_.gotoAndStop("up");
         _loc1_.enabled = true;
         _loc1_.checked = false;
      }
   }
   else
   {
      _loc1_.flabel_mc.setEnabled(false);
      if(_loc3_ || _loc3_ == undefined)
      {
         _loc2_.gotoAndStop("checkedDisabled");
         _loc1_.enabled = false;
         _loc1_.checked = true;
      }
      else
      {
         _loc2_.gotoAndStop("uncheckedDisabled");
         _loc1_.enabled = false;
         _loc1_.checked = false;
         _loc1_.focusRect.removeMovieClip();
      }
   }
};
FCheckBoxClass.prototype.getValue = function()
{
   return this.checked;
};
FCheckBoxClass.prototype.setEnabled = function(enable)
{
   var _loc1_ = this;
   if(enable == true || enable == undefined)
   {
      _loc1_.enable = true;
      Super.setEnabled(true);
   }
   else
   {
      _loc1_.enable = false;
      Super.setEnabled(false);
   }
   _loc1_.setCheckState(_loc1_.checked);
};
FCheckBoxClass.prototype.getEnabled = function()
{
   return this.enable;
};
FCheckBoxClass.prototype.setLabel = function(label)
{
   var _loc1_ = this;
   _loc1_.fLabel_mc.setLabel(label);
   _loc1_.txtFormat();
   if(Accessibility.isActive())
   {
      Accessibility.sendEvent(_loc1_,0,_loc1_.EVENT_OBJECT_NAMECHANGE);
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
   var _loc1_ = this;
   if(Key.getCode() == 32 && _loc1_.pressOnce == undefined && _loc1_.enabled == true)
   {
      _loc1_.setValue(!_loc1_.getValue());
      _loc1_.pressOnce = true;
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
