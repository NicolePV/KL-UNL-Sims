function TitleBarClass()
{
   this.width = this._width;
   this.height = this._height;
   this.placeholderMC._visible = false;
   this._xscale = 100;
   this._yscale = 100;
   this.selectedLanguage = null;
   this.easerIntervalID = null;
   this.easer = new CubicEasingClass(0);
   this.easerEpoch = 0;
   this.easerTargetTime = 1;
   this.openedLangPanelPosition = this.closedLangPanelPosition = 0;
   this.initialize();
}
var p = TitleBarClass.prototype = new MovieClip();
Object.registerClass("Title Bar",TitleBarClass);
p.easerDuration = 220;
p.onMouseDown = function()
{
   var _loc2_ = !this.langPanel.hitTest(_xmouse,_ymouse,true);
   var _loc3_ = !this.barContentsMC.hitTest(_xmouse,_ymouse,true);
   if(this.isLanguagePanelOpen() && _loc2_ && _loc3_)
   {
      this.closeLanguagePanel();
   }
};
p.isLanguagePanelOpen = function()
{
   return this.easer.splinePointsList[1].y == this.openedLangPanelPosition;
};
p.closeLanguagePanel = function()
{
   if(!this.isLanguagePanelOpen())
   {
      return undefined;
   }
   this.setLangPanelTargetPosition(this.closedLangPanelPosition);
};
p.openLanguagePanel = function()
{
   if(this.isLanguagePanelOpen())
   {
      return undefined;
   }
   this.setLangPanelTargetPosition(this.openedLangPanelPosition);
};
p.setLangPanelTargetPosition = function(targetPosition)
{
   var _loc2_ = getTimer() - this.easerEpoch;
   var _loc3_;
   if(_loc2_ > this.easerTargetTime)
   {
      this.easerEpoch = getTimer();
      _loc2_ = 0;
      _loc3_ = this.easer.getValue(this.easerTargetTime);
   }
   else
   {
      _loc3_ = null;
   }
   this.easerTargetTime = _loc2_ + this.easerDuration;
   this.easer.setTarget(_loc2_,_loc3_,this.easerTargetTime,targetPosition);
   if(this.easerIntervalID == null)
   {
      this.easerIntervalID = setInterval(this.easerIntervalFunc,10,this);
   }
   this.easerIntervalFunc(this);
};
p.easerIntervalFunc = function(thisObj)
{
   var _loc2_ = getTimer() - thisObj.easerEpoch;
   if(_loc2_ > thisObj.easerTargetTime)
   {
      _loc2_ = thisObj.easerTargetTime;
   }
   thisObj.langPanel._y = thisObj.easer.getValue(_loc2_);
   if(_loc2_ >= thisObj.easerTargetTime)
   {
      clearInterval(thisObj.easerIntervalID);
      thisObj.easerIntervalID = null;
   }
   updateAfterEvent();
};
p.onOptionClicked = function(type)
{
   this.aboutWindow.hide();
   this.helpWindow.hide();
   if(type == "about")
   {
      this.aboutWindow.show();
      this.closeLanguagePanel();
   }
   else if(type == "help")
   {
      this.helpWindow.show();
      this.closeLanguagePanel();
   }
   else if(type == "reset")
   {
      this._parent[this.resetHandlerFunc]();
      this.closeLanguagePanel();
   }
   else if(type == "lang")
   {
      if(this.isLanguagePanelOpen())
      {
         this.closeLanguagePanel();
      }
      else
      {
         this.openLanguagePanel();
      }
   }
};
p.setLanguages = function(langList)
{
   this.langPanel.setChoices(langList);
   this.closedLangPanelPosition = this.height - 1 - this.langPanel._height;
   this.openedLangPanelPosition = this.height - 1;
   this.easer.init(this.closedLangPanelPosition);
   this.langPanel._x = this.width - 2 - 5 - this.langPanel.rightExtent;
   this.langPanel._y = this.closedLangPanelPosition;
   var _loc2_;
   if(langList.length > 1)
   {
      _loc2_ = {label:"lang",type:"lang",mc:null};
      this.optionsList.splice(0,0,_loc2_);
      this.update();
   }
};
p.onLanguageSelectedViaPanel = function(lang)
{
   this.selectLanguage(lang);
};
p.selectLanguage = function(lang)
{
   this.selectedLanguage = lang;
   this.langPanel.selectLanguage(lang);
   this._parent[this.langHandlerFunc](lang);
   this.closeLanguagePanel();
};
p.resetLabel = "reset";
p.helpLabel = "help";
p.aboutLabel = "about";
p.update = function()
{
   var _loc3_ = 0;
   var _loc2_;
   while(_loc3_ < this.optionsList.length)
   {
      _loc2_ = this.optionsList[_loc3_];
      if(_loc2_.type == "reset")
      {
         _loc2_.label = this.resetLabel;
      }
      else if(_loc2_.type == "help")
      {
         _loc2_.label = this.helpLabel;
      }
      else if(_loc2_.type == "about")
      {
         _loc2_.label = this.aboutLabel;
      }
      else if(_loc2_.type == "lang")
      {
         _loc2_.label = "lang:" + this.selectedLanguage.langCode;
      }
      _loc3_ = _loc3_ + 1;
   }
   if(this.barContentsMC != undefined)
   {
      this.barContentsMC.removeMovieClip();
   }
   var _loc9_ = this.createEmptyMovieClip("barContentsMC",11);
   this.interfaceTextFormat.color = this.titleColor;
   this.interfaceTextFormat.size = this.titleFontSize;
   this.displayText(this.title,{mc:this.barContentsMC,depth:1,vAlign:"top",hAlign:"left",x:this.titleXPosition,y:this.titleYPosition,embedFonts:true,textFormat:this.interfaceTextFormat});
   this.interfaceTextFormat.color = this.optionsColor;
   this.interfaceTextFormat.size = this.optionsFontSize;
   var _loc5_ = this.width + this.optionsSpacing * 0.3;
   var optionsList = this.optionsList;
   _loc3_ = 0;
   var _loc0_;
   var _loc4_;
   while(_loc3_ < this.optionsList.length)
   {
      if(this[optionsList[_loc3_] + "HandlerFunc"] != "")
      {
         _loc4_ = this[optionsList[_loc3_]].mc = this.addOptionsLabel(optionsList[_loc3_].label,optionsList[_loc3_].type,2 + _loc3_);
         _loc5_ = _loc5_ - this.optionsSpacing - _loc4_._width / 2;
         _loc4_._x = _loc5_;
         _loc4_._y = this.optionsYPosition;
         _loc5_ -= _loc4_._width / 2;
      }
      _loc3_ = _loc3_ + 1;
   }
};
p.initialize = function()
{
   this.attachMovie(this.fontSourceLinkageName,"fontMC",121212,{_visible:false});
   this.interfaceTextFormat = this.fontMC.fontField.getTextFormat();
   this.interfaceTextFormat.color = this.optionsColor;
   this.interfaceTextFormat.size = this.optionsFontSize;
   this.createEmptyMovieClip("dialogWindowsMC",5);
   this.attachMovie("Language Panel","langPanel",7,{_visible:true,textFormat:this.interfaceTextFormat,changeHandler:"selectLanguage"});
   var _loc3_ = this.createEmptyMovieClip("langPanelMask",8);
   _loc3_.moveTo(0,this.height - 1);
   _loc3_.beginFill(16711680,10);
   _loc3_.lineTo(this.width,this.height - 1);
   _loc3_.lineTo(this.width,Math.max(700,Stage.height));
   _loc3_.lineTo(0,Math.max(700,Stage.height));
   _loc3_.lineTo(0,this.height - 1);
   _loc3_.endFill();
   this.langPanel.setMask(this.langPanelMask);
   this.createEmptyMovieClip("backgroundMC",10);
   this.aboutWindow = this.dialogWindowsMC.attachMovie("Dialog Window v2","aboutWindowMC",1,{contentLinkageName:this.aboutLinkageName,title:"About",topLimit:this.height,buffer:5});
   this.helpWindow = this.dialogWindowsMC.attachMovie("Dialog Window v2","helpWindowMC",2,{contentLinkageName:this.helpLinkageName,title:"Help",topLimit:this.height,buffer:5});
   this.optionsList = [];
   if(this.aboutWindow.loadSuccessful)
   {
      this.optionsList.push({label:"about",type:"about",mc:null});
   }
   if(this.helpWindow.loadSuccessful)
   {
      this.optionsList.push({label:"help",type:"help",mc:null});
   }
   if(this.resetHandlerFunc != "" && this.resetHandlerFunc != undefined)
   {
      this.optionsList.push({label:"reset",type:"reset",mc:null});
   }
   this.aboutWindow.hide();
   this.helpWindow.hide();
   var _loc2_ = this.backgroundMC;
   _loc2_.beginFill(this.backgroundColor);
   _loc2_.moveTo(-2,-2);
   _loc2_.lineTo(this.width + 2,-2);
   _loc2_.lineTo(this.width + 2,this.height);
   _loc2_.lineStyle(this.borderThickness,this.borderColor);
   _loc2_.lineTo(-2,this.height);
   _loc2_.lineStyle();
   _loc2_.lineTo(-2,-2);
   _loc2_.endFill();
   _loc2_.useHandCursor = false;
   _loc2_.tabEnabled = false;
   _loc2_.onPress = function()
   {
   };
   this.update();
};
p.addOptionsLabel = function(label, type, depth)
{
   var _loc2_ = this.barContentsMC.createEmptyMovieClip(type + "MC",depth);
   _loc2_.type = type;
   _loc2_.createTextField("labelField",1,0,0,0,0);
   _loc2_.labelField.autoSize = "center";
   _loc2_.labelField.embedFonts = true;
   _loc2_.labelField.setNewTextFormat(this.interfaceTextFormat);
   _loc2_.labelField.text = label;
   _loc2_.createEmptyMovieClip("underlineMC",2);
   _loc2_.underlineMC._visible = false;
   _loc2_.underlineMC.lineStyle(1,this.interfaceTextFormat.color);
   _loc2_.underlineMC.moveTo(_loc2_.labelField._x,_loc2_.labelField._height - 2);
   _loc2_.underlineMC.lineTo(_loc2_.labelField._x + _loc2_.labelField._width,_loc2_.labelField._height - 2);
   _loc2_._focusrect = false;
   _loc2_.onSetFocus = function()
   {
      this.underlineMC._visible = true;
      this.onKeyDown = this.onKeyDownFunc;
   };
   _loc2_.onKillFocus = function()
   {
      this.underlineMC._visible = false;
      delete this.onKeyDown;
   };
   _loc2_.onKeyDownFunc = function()
   {
      if(Key.isDown(32))
      {
         this._parent._parent.onOptionClicked(this.type);
         this.underlineMC._visible = false;
         delete this.onKeyDown;
      }
   };
   _loc2_.useHandCursor = true;
   _loc2_.onRollOver = function()
   {
      this.underlineMC._visible = true;
   };
   _loc2_.onRollOut = function()
   {
      this.underlineMC._visible = false;
   };
   _loc2_.onRelease = function()
   {
      this._parent._parent.onOptionClicked(this.type);
      this.underlineMC._visible = false;
   };
   _loc2_.onReleaseOutside = function()
   {
      this.underlineMC._visible = false;
   };
   return _loc2_;
};
p.displayText = function(textString, options)
{
   textString = String(textString);
   var _loc29_;
   var _loc0_;
   if(options.depth != undefined)
   {
      _loc29_ = options.depth;
   }
   else if(_global._displayedTextLastDepthUsed != undefined)
   {
      _loc29_ = ++_global._displayedTextLastDepthUsed;
   }
   else
   {
      _loc29_ = _global._displayedTextLastDepthUsed = 913001;
   }
   var _loc30_;
   if(options.name != undefined)
   {
      _loc30_ = options.name;
   }
   else
   {
      _loc30_ = "_textWrapper_" + _loc29_;
   }
   var _loc7_;
   if(options.mc != undefined)
   {
      _loc7_ = options.mc.createEmptyMovieClip(_loc30_,_loc29_);
   }
   else
   {
      _loc7_ = this.createEmptyMovieClip(_loc30_,_loc29_);
   }
   if(options.x != undefined)
   {
      _loc7_._x = options.x;
   }
   if(options.y != undefined)
   {
      _loc7_._y = options.y;
   }
   var _loc23_;
   if(options.embedFonts != undefined)
   {
      _loc23_ = options.embedFonts;
   }
   else
   {
      _loc23_ = false;
   }
   var _loc12_;
   if(options.textFormat != undefined)
   {
      _loc12_ = options.textFormat;
   }
   else
   {
      _loc12_ = new TextFormat(null,12);
   }
   var _loc13_ = new TextFormat();
   for(var _loc19_ in _loc12_)
   {
      _loc13_[_loc19_] = _loc12_[_loc19_];
   }
   if(options.sizeRatio != undefined)
   {
      _loc13_.size = _loc12_.size / options.sizeRatio;
   }
   else
   {
      _loc13_.size = _loc12_.size / 1.5;
   }
   _loc7_.createTextField("_0",0,0,0,0,0);
   _loc7_._0.autoSize = "left";
   _loc7_._0.embedFonts = _loc23_;
   _loc7_._0.setNewTextFormat(_loc12_);
   _loc7_._0.text = "X";
   _loc7_._0._visible = false;
   _loc7_.createTextField("_1",1,0,0,0,0);
   _loc7_._1.autoSize = "left";
   _loc7_._1.embedFonts = _loc23_;
   _loc7_._1.setNewTextFormat(_loc13_);
   _loc7_._1.text = "X";
   _loc7_._1._visible = false;
   var _loc28_ = _loc7_._0._height;
   var _loc31_ = _loc7_._1._height;
   var _loc25_;
   if(options.superscriptPosition != undefined)
   {
      _loc25_ = - options.superscriptPosition;
   }
   else
   {
      _loc25_ = 0;
   }
   var _loc26_;
   if(options.subscriptPosition != undefined)
   {
      _loc26_ = _loc28_ - _loc31_ + options.subscriptPosition;
   }
   else
   {
      _loc26_ = _loc28_ - _loc31_;
   }
   var _loc24_;
   if(options.extraSpacing != undefined)
   {
      _loc24_ = options.extraSpacing;
   }
   else
   {
      _loc24_ = 0.5;
   }
   var _loc4_ = [];
   var _loc15_ = 0;
   var _loc17_ = 0;
   var _loc9_ = 0;
   var _loc6_;
   do
   {
      var ind = textString.indexOf("<su",_loc9_);
      if(ind == -1)
      {
         _loc4_.push({pos:_loc15_,str:textString});
      }
      else if(textString.charAt(ind + 3) == "b" && textString.charAt(ind + 4) == ">")
      {
         if(ind != 0)
         {
            _loc4_.push({pos:_loc15_,str:textString.substring(0,ind)});
         }
         textString = textString.slice(ind + 5);
         _loc15_ = -1;
         _loc6_ = textString.indexOf("</sub>");
         if(_loc6_ != -1)
         {
            if(_loc6_ != 0)
            {
               _loc4_.push({pos:_loc15_,str:textString.substring(0,_loc6_)});
            }
            textString = textString.slice(_loc6_ + 6);
            _loc15_ = 0;
         }
         _loc9_ = 0;
      }
      else if(textString.charAt(ind + 3) == "p" && textString.charAt(ind + 4) == ">")
      {
         if(ind != 0)
         {
            _loc4_.push({pos:_loc15_,str:textString.substring(0,ind)});
         }
         textString = textString.slice(ind + 5);
         _loc15_ = 1;
         _loc6_ = textString.indexOf("</sup>");
         if(_loc6_ != -1)
         {
            if(_loc6_ != 0)
            {
               _loc4_.push({pos:_loc15_,str:textString.substring(0,_loc6_)});
            }
            textString = textString.slice(_loc6_ + 6);
            _loc15_ = 0;
         }
         _loc9_ = 0;
      }
      else
      {
         _loc9_ = ind + 3;
      }
      _loc17_ = _loc17_ + 1;
   }
   while(ind != -1 && textString.length > 0 && _loc17_ < 100);
   if(_loc17_ >= 100)
   {
   }
   var _loc14_ = [];
   var _loc22_ = 0;
   var _loc18_ = 2;
   var _loc8_ = 0;
   var _loc11_;
   var _loc16_;
   var _loc21_;
   while(_loc8_ < _loc4_.length)
   {
      _loc11_ = "_" + _loc18_;
      _loc7_.createTextField(_loc11_,_loc18_++,0,0,0,0);
      _loc16_ = _loc7_[_loc11_];
      _loc16_.autoSize = "left";
      _loc16_.embedFonts = _loc23_;
      _loc16_.selectable = false;
      if(_loc4_[_loc8_].pos == 0)
      {
         _loc21_ = 0;
         _loc16_.setNewTextFormat(_loc12_);
      }
      else if(_loc4_[_loc8_].pos == 1)
      {
         _loc21_ = _loc25_;
         _loc16_.setNewTextFormat(_loc13_);
      }
      else
      {
         _loc21_ = _loc26_;
         _loc16_.setNewTextFormat(_loc13_);
      }
      _loc16_.text = _loc4_[_loc8_].str;
      _loc14_.push({tf:_loc16_,dy:_loc21_});
      _loc22_ += _loc16_.textWidth;
      _loc8_ = _loc8_ + 1;
   }
   _loc22_ += _loc24_ * (_loc14_.length - 1);
   var _loc19_;
   if(options.hAlign == "left")
   {
      _loc19_ = -2;
   }
   else if(options.hAlign == "right")
   {
      _loc19_ = -2 - _loc22_;
   }
   else
   {
      _loc19_ = -2 - _loc22_ / 2;
   }
   var _loc27_;
   if(options.vAlign == "top")
   {
      _loc27_ = -2;
   }
   else if(options.vAlign == "bottom")
   {
      _loc27_ = - _loc28_ + 2;
   }
   else
   {
      _loc27_ = (- _loc28_) / 2;
   }
   _loc8_ = 0;
   var _loc5_;
   while(_loc8_ < _loc14_.length)
   {
      _loc5_ = _loc14_[_loc8_];
      _loc5_.tf._x = _loc19_;
      _loc5_.tf._y = _loc27_ + _loc5_.dy;
      _loc19_ += _loc5_.tf.textWidth + _loc24_;
      _loc8_ = _loc8_ + 1;
   }
   _loc7_.textWidth = _loc22_;
   return _loc7_;
};
