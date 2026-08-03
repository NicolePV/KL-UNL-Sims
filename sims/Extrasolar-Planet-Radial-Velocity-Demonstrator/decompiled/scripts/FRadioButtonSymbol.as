function FRadioButtonClass()
{
   this.init();
}
function FRadioButtonGroupClass()
{
   this.radioInstances = new Array();
}
FRadioButtonClass.prototype = new FUIComponentClass();
FRadioButtonGroupClass.prototype = new FUIComponentClass();
Object.registerClass("FRadioButtonSymbol",FRadioButtonClass);
FRadioButtonClass.prototype.init = function()
{
   if(this.initialState == undefined)
   {
      this.selected = false;
   }
   else
   {
      this.selected = this.initialState;
   }
   super.setSize(this._width,this._height);
   this.boundingBox_mc.unloadMovie();
   this.boundingBox_mc._width = 0;
   this.boundingBox_mc._height = 0;
   this.attachMovie("frb_hitArea","frb_hitArea_mc",1);
   this.attachMovie("frb_states","frb_states_mc",2);
   this.attachMovie("FLabelSymbol","fLabel_mc",3);
   super.init();
   this._xscale = 100;
   this._yscale = 100;
   this.setSize(this.width,this.height);
   this.setChangeHandler(this.changeHandler);
   if(this.label != undefined)
   {
      this.setLabel(this.label);
   }
   if(this.initialState == undefined)
   {
      this.setValue(false);
   }
   else
   {
      this.setValue(this.initialState);
   }
   if(this.data == "")
   {
      this.data = undefined;
   }
   else
   {
      this.setData(this.data);
   }
   this.addToRadioGroup();
   this.ROLE_SYSTEM_RADIOBUTTON = 45;
   this.STATE_SYSTEM_SELECTED = 16;
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
FRadioButtonClass.prototype.setHitArea = function(w, h)
{
   var _loc3_ = this.frb_hitArea_mc;
   this.hitArea = _loc3_;
   if(this.frb_states_mc._width > w)
   {
      _loc3_._width = this.frb_states_mc._width;
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
FRadioButtonClass.prototype.txtFormat = function(pos)
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
   this.setEnabled(this.enable);
};
FRadioButtonClass.prototype.setSize = function(w, h)
{
   this.setLabel(this.getLabel());
   this.setLabelPlacement(this.labelPlacement);
   if(this.frb_states_mc._height < this.flabel_mc.labelField._height)
   {
      super.setSize(w,this.flabel_mc.labelField._height);
   }
   this.setHitArea(this.width,this.height);
   this.setLabelPlacement(this.labelPlacement);
};
FRadioButtonClass.prototype.setLabelPlacement = function(pos)
{
   this.setLabel(this.getLabel());
   this.txtFormat(pos);
   var _loc7_ = this.fLabel_mc._height / 2;
   var _loc8_ = this.frb_states_mc._height / 2;
   var _loc5_ = _loc8_ - _loc7_;
   var _loc6_ = this.frb_states_mc._width;
   var _loc2_ = this.frb_states_mc;
   var _loc9_ = this.fLabel_mc;
   var _loc3_ = this.width - _loc2_._width;
   if(_loc2_._width > this.width)
   {
      _loc3_ = 0;
   }
   else
   {
      _loc3_ = this.width - _loc2_._width;
   }
   this.fLabel_mc.setSize(_loc3_);
   if(pos == "right" || pos == undefined)
   {
      this.labelPlacement = "right";
      this.frb_states_mc._x = 0;
      this.fLabel_mc._x = _loc6_;
      this.txtFormat("left");
   }
   else if(pos == "left")
   {
      this.labelPlacement = "left";
      this.fLabel_mc._x = 0;
      this.frb_states_mc._x = this.width - _loc6_;
      this.txtFormat("right");
   }
   this.fLabel_mc._y = _loc5_;
   this.frb_hitArea_mc._y = _loc5_;
   this.setLabel(this.getLabel());
};
FRadioButtonClass.prototype.setData = function(dataValue)
{
   this.data = dataValue;
};
FRadioButtonClass.prototype.getData = function()
{
   return this.data;
};
FRadioButtonClass.prototype.getState = function()
{
   return this.selected;
};
FRadioButtonClass.prototype.getSize = function()
{
   return this.width;
};
FRadioButtonClass.prototype.getGroupName = function()
{
   return this.groupName;
};
FRadioButtonClass.prototype.setGroupName = function(groupName)
{
   var _loc2_ = 0;
   while(_loc2_ < this._parent[this.groupName].radioInstances.length)
   {
      if(this._parent[this.groupName].radioInstances[_loc2_] == this)
      {
         delete this._parent[this.groupName].radioInstances[_loc2_];
      }
      _loc2_ = _loc2_ + 1;
   }
   this.groupName = groupName;
   this.addToRadioGroup();
};
FRadioButtonClass.prototype.addToRadioGroup = function()
{
   if(this._parent[this.groupName] == undefined)
   {
      this._parent[this.groupName] = new FRadioButtonGroupClass();
   }
   this._parent[this.groupName].addRadioInstance(this);
};
FRadioButtonClass.prototype.setValue = function(selected)
{
   if(selected || selected == undefined)
   {
      this.setState(true);
      this.focusRect.removeMovieClip();
      this.executeCallBack();
   }
   else if(selected == false)
   {
      this.setState(false);
   }
};
FRadioButtonClass.prototype.setTabState = function(selected)
{
   Selection.setFocus(this);
   this.setState(selected);
   this.drawFocusRect();
   this.executeCallBack();
};
FRadioButtonClass.prototype.setState = function(selected)
{
   if(selected || selected == undefined)
   {
      this.tabEnabled = true;
      for(var _loc3_ in this._parent)
      {
         if(this != this._parent[_loc3_] && this._parent[_loc3_].groupName == this.groupName)
         {
            this._parent[_loc3_].setState(false);
            this._parent[_loc3_].tabEnabled = false;
         }
      }
   }
   var _loc4_;
   var _loc5_;
   if(this.enable)
   {
      this.flabel_mc.setEnabled(true);
      if(selected || selected == undefined)
      {
         this.frb_states_mc.gotoAndStop("selectedEnabled");
         this.enabled = false;
         this.selected = true;
         this.tabEnabled = true;
         this.tabFocused = true;
      }
      else
      {
         this.frb_states_mc.gotoAndStop("unselectedEnabled");
         this.enabled = true;
         this.selected = false;
         this.tabEnabled = false;
         _loc4_ = this._parent[this.groupName].getEnabled();
         _loc5_ = this._parent[this.groupName].getValue() == undefined;
         if(_loc4_ && _loc5_)
         {
            this._parent[this.groupName].radioInstances[0].tabEnabled = true;
         }
      }
   }
   else
   {
      this.flabel_mc.setEnabled(false);
      if(selected || selected == undefined)
      {
         this.frb_states_mc.gotoAndStop("selectedDisabled");
         this.enabled = false;
         this.selected = true;
         this.tabEnabled = false;
      }
      else
      {
         this.frb_states_mc.gotoAndStop("unselectedDisabled");
         this.enabled = false;
         this.selected = false;
         this.tabEnabled = false;
      }
   }
   if(Accessibility.isActive())
   {
      Accessibility.sendEvent(this,0,this.EVENT_OBJECT_STATECHANGE,true);
   }
};
FRadioButtonClass.prototype.getValue = function()
{
   if(this.selected)
   {
      if(this.data == "" || this.data == undefined)
      {
         return this.getLabel();
      }
      return this.data;
   }
};
FRadioButtonClass.prototype.setEnabled = function(enable)
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
   this.setState(this.selected);
   var _loc5_ = this._parent[this.groupName].getEnabled() == undefined;
   var _loc4_ = this._parent[this.groupName].radioInstances[0].getEnabled() == false;
   var _loc3_;
   if(_loc5_ && _loc4_)
   {
      _loc3_ = 0;
      while(_loc3_ < this._parent[this.groupName].radioInstances.length)
      {
         if(this._parent[this.groupName].radioInstances[_loc3_].getEnabled() == true)
         {
            this._parent[this.groupName].radioInstances[_loc3_].tabEnabled = true;
            return undefined;
         }
         _loc3_ = _loc3_ + 1;
      }
   }
};
FRadioButtonClass.prototype.getEnabled = function()
{
   return this.enable;
};
FRadioButtonClass.prototype.setLabel = function(label)
{
   this.fLabel_mc.setLabel(label);
   this.txtFormat();
   if(Accessibility.isActive())
   {
      Accessibility.sendEvent(this,0,this.EVENT_OBJECT_NAMECHANGE);
   }
};
FRadioButtonClass.prototype.getLabel = function()
{
   return this.fLabel_mc.getLabel();
};
FRadioButtonClass.prototype.onPress = function()
{
   this.pressFocus();
   this.frb_states_mc.gotoAndStop("press");
};
FRadioButtonClass.prototype.onRelease = function()
{
   this.frb_states_mc.gotoAndStop("unselectedDisabled");
   this.setValue(!this.selected);
};
FRadioButtonClass.prototype.onReleaseOutside = function()
{
   this.frb_states_mc.gotoAndStop("unselectedEnabled");
};
FRadioButtonClass.prototype.onDragOut = function()
{
   this.frb_states_mc.gotoAndStop("unselectedEnabled");
};
FRadioButtonClass.prototype.onDragOver = function()
{
   this.frb_states_mc.gotoAndStop("press");
};
FRadioButtonClass.prototype.executeCallBack = function()
{
   this.handlerObj[this.changeHandler](this._parent[this.groupName]);
};
FRadioButtonGroupClass.prototype.addRadioInstance = function(instance)
{
   this.radioInstances.push(instance);
   this.radioInstances[0].tabEnabled = true;
};
FRadioButtonGroupClass.prototype.setEnabled = function(enableFlag)
{
   var _loc2_ = 0;
   while(_loc2_ < this.radioInstances.length)
   {
      this.radioInstances[_loc2_].setEnabled(enableFlag);
      _loc2_ = _loc2_ + 1;
   }
};
FRadioButtonGroupClass.prototype.getEnabled = function()
{
   var _loc2_ = 0;
   while(_loc2_ < this.radioInstances.length)
   {
      if(this.radioInstances[_loc2_].getEnabled() != this.radioInstances[0].getEnabled())
      {
         return undefined;
      }
      _loc2_ = _loc2_ + 1;
   }
   return this.radioInstances[0].getEnabled();
};
FRadioButtonGroupClass.prototype.setChangeHandler = function(changeHandler, obj)
{
   var _loc2_ = 0;
   while(_loc2_ < this.radioInstances.length)
   {
      this.radioInstances[_loc2_].setChangeHandler(changeHandler,obj);
      _loc2_ = _loc2_ + 1;
   }
};
FRadioButtonGroupClass.prototype.getValue = function()
{
   var _loc2_ = 0;
   while(_loc2_ < this.radioInstances.length)
   {
      if(this.radioInstances[_loc2_].selected == true)
      {
         if(this.radioInstances[_loc2_].data == "" || this.radioInstances[_loc2_].data == undefined)
         {
            return this.radioInstances[_loc2_].getLabel();
         }
         return this.radioInstances[_loc2_].data;
      }
      _loc2_ = _loc2_ + 1;
   }
};
FRadioButtonGroupClass.prototype.getData = function()
{
   var _loc2_ = 0;
   while(_loc2_ < this.radioInstances.length)
   {
      if(this.radioInstances[_loc2_].selected)
      {
         return this.radioInstances[_loc2_].getData();
      }
      _loc2_ = _loc2_ + 1;
   }
};
FRadioButtonGroupClass.prototype.getInstance = function()
{
   var _loc2_ = 0;
   while(_loc2_ < this.radioInstances.length)
   {
      if(this.radioInstances[_loc2_].selected == true)
      {
         return _loc2_;
      }
      undefined;
      _loc2_ = _loc2_ + 1;
   }
};
FRadioButtonGroupClass.prototype.setValue = function(dataValue)
{
   var _loc2_ = 0;
   while(_loc2_ < this.radioInstances.length)
   {
      if(this.radioInstances[_loc2_].data == dataValue)
      {
         this.radioInstances[_loc2_].setValue(true);
         return undefined;
      }
      _loc2_ = _loc2_ + 1;
   }
   _loc2_ = 0;
   while(_loc2_ < this.radioInstances.length)
   {
      if(this.radioInstances[_loc2_].getLabel() == dataValue)
      {
         this.radioInstances[_loc2_].setValue(true);
      }
      _loc2_ = _loc2_ + 1;
   }
};
FRadioButtonGroupClass.prototype.setSize = function(w)
{
   var _loc2_ = 0;
   while(_loc2_ < this.radioInstances.length)
   {
      this.radioInstances[_loc2_].setSize(w);
      _loc2_ = _loc2_ + 1;
   }
};
FRadioButtonGroupClass.prototype.getSize = function()
{
   var _loc3_ = 0;
   var _loc2_ = 0;
   while(_loc2_ < this.radioInstances.length)
   {
      if(this.radioInstances[_loc2_].width >= _loc3_)
      {
         _loc3_ = this.radioInstances[_loc2_].width;
      }
      _loc2_ = _loc2_ + 1;
   }
   return _loc3_;
};
FRadioButtonGroupClass.prototype.setGroupName = function(groupName)
{
   this.oldGroupName = this.radioInstances[0].groupName;
   var _loc2_ = 0;
   while(_loc2_ < this.radioInstances.length)
   {
      this.radioInstances[_loc2_].groupName = groupName;
      this.radioInstances[_loc2_].addToRadioGroup();
      _loc2_ = _loc2_ + 1;
   }
   delete this._parent[this.oldGroupName];
};
FRadioButtonGroupClass.prototype.getGroupName = function()
{
   return this.radioInstances[0].groupName;
};
FRadioButtonGroupClass.prototype.setLabelPlacement = function(pos)
{
   var _loc2_ = 0;
   while(_loc2_ < this.radioInstances.length)
   {
      this.radioInstances[_loc2_].setLabelPlacement(pos);
      _loc2_ = _loc2_ + 1;
   }
};
FRadioButtonGroupClass.prototype.setStyleProperty = function(propName, value, isGlobal)
{
   var _loc2_ = 0;
   while(_loc2_ < this.radioInstances.length)
   {
      this.radioInstances[_loc2_].setStyleProperty(propName,value,isGlobal);
      _loc2_ = _loc2_ + 1;
   }
};
FRadioButtonGroupClass.prototype.addListener = function()
{
   var _loc2_ = 0;
   while(_loc2_ < this.radioInstances.length)
   {
      this.radioInstances[_loc2_].addListener();
      _loc2_ = _loc2_ + 1;
   }
};
FRadioButtonGroupClass.prototype.applyChanges = function()
{
   var _loc2_ = 0;
   while(_loc2_ < this.radioInstances.length)
   {
      this.radioInstances[_loc2_].applyChanges();
      _loc2_ = _loc2_ + 1;
   }
};
FRadioButtonGroupClass.prototype.removeListener = function(component)
{
   var _loc2_ = 0;
   while(_loc2_ < this.radioInstances.length)
   {
      this.radioInstances[_loc2_].removeListener(component);
      _loc2_ = _loc2_ + 1;
   }
};
FRadioButtonClass.prototype.drawFocusRect = function()
{
   this.drawRect(-2,-2,this._width + 6,this._height - 3);
};
FRadioButtonClass.prototype.myOnKillFocus = function()
{
   Key.removeListener(this.keyListener);
   this.focused = false;
   this.focusRect.removeMovieClip();
   this._parent[this.groupName].foobar = 0;
};
FRadioButtonClass.prototype.myOnKeyDown = function()
{
   if(Key.getCode() == 32 && this._parent[this.groupName].getValue() == undefined)
   {
      if(this._parent[this.groupName].radioInstances[0] == this)
      {
         this.setTabState(true);
      }
   }
   var _loc2_;
   var _loc3_;
   if(Key.getCode() == 40 && this.pressOnce == undefined)
   {
      this.foobar = this._parent[this.groupName].getInstance();
      _loc2_ = this.foobar;
      while(_loc2_ < this._parent[this.groupName].radioInstances.length)
      {
         _loc3_ = _loc2_ + 1;
         if(this._parent[this.groupName].radioInstances[_loc3_].getEnabled())
         {
            this._parent[this.groupName].radioInstances[_loc3_].setTabState(true);
            return undefined;
         }
         _loc2_ = _loc2_ + 1;
      }
   }
   if(Key.getCode() == 38 && this.pressOnce == undefined)
   {
      this.foobar = this._parent[this.groupName].getInstance();
      _loc2_ = this.foobar;
      while(_loc2_ >= 0)
      {
         _loc3_ = _loc2_ - 1;
         if(this._parent[this.groupName].radioInstances[_loc3_].getEnabled())
         {
            this._parent[this.groupName].radioInstances[_loc3_].setTabState(true);
            return undefined;
         }
         _loc2_ = _loc2_ - 1;
      }
   }
};
FRadioButtonClass.prototype.get_accRole = function(childId)
{
   return this.master.ROLE_SYSTEM_RADIOBUTTON;
};
FRadioButtonClass.prototype.get_accName = function(childId)
{
   return this.master.getLabel();
};
FRadioButtonClass.prototype.get_accState = function(childId)
{
   if(this.master.getState())
   {
      return this.master.STATE_SYSTEM_SELECTED;
   }
   return 0;
};
FRadioButtonClass.prototype.get_accDefaultAction = function(childId)
{
   if(this.master.getState())
   {
      return "UnCheck";
   }
   return "Check";
};
FRadioButtonClass.prototype.accDoDefaultAction = function(childId)
{
   this.master.setValue(!this.master.getValue());
};
