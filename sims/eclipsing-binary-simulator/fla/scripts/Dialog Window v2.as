function DialogWindowV2Class()
{
   if(this.borderColor == undefined)
   {
      this.borderColor = 6316128;
   }
   if(this.borderThickness == undefined)
   {
      this.borderThickness = 1;
   }
   if(this.fontSourceLinkageName == undefined)
   {
      this.fontSourceLinkageName = "Dialog Window Font";
   }
   if(this.closeButtonLinkageName == undefined)
   {
      this.closeButtonLinkageName = "Dialog Window Close Button";
   }
   if(this.leftLimit == undefined)
   {
      this.leftLimit = 0;
   }
   if(this.rightLimit == undefined)
   {
      this.rightLimit = Stage.width;
   }
   if(this.topLimit == undefined)
   {
      this.topLimit = 0;
   }
   if(this.bottomLimit == undefined)
   {
      this.bottomLimit = Stage.height;
   }
   if(this.buffer == undefined)
   {
      this.buffer = 0;
   }
   if(this.titleBarColor == undefined)
   {
      this.titleBarColor = 6710886;
   }
   if(this.titleBarHeight == undefined)
   {
      this.titleBarHeight = 26;
   }
   if(this.title == undefined)
   {
      this.title = "";
   }
   if(this.titleSize == undefined)
   {
      this.titleSize = 12;
   }
   if(this.titleColor == undefined)
   {
      this.titleColor = 16777215;
   }
   if(this.titleXPosition == undefined)
   {
      this.titleXPosition = 10;
   }
   if(this.titleYPosition == undefined)
   {
      this.titleYPosition = 7;
   }
   this.initialize();
}
var p = DialogWindowV2Class.prototype = new MovieClip();
Object.registerClass("Dialog Window v2",DialogWindowV2Class);
p.initialize = function()
{
   this.createEmptyMovieClip("backgroundMC",1);
   this.createEmptyMovieClip("titleBarBackgroundMC",5);
   this.attachMovie(this.contentLinkageName,"contentMC",15,{_x:0,_y:0});
   this.createEmptyMovieClip("contentMaskMC",16);
   this.createEmptyMovieClip("borderMC",20);
   this.attachMovie(this.closeButtonLinkageName,"closeButtonMC",25);
   this.attachMovie(this.fontSourceLinkageName,"fontMC",121212);
   this.titleTextFormat = this.fontMC.fontField.getTextFormat();
   this.fontMC.removeMovieClip();
   this.loadSuccessful = this.contentMC != undefined;
   if(!this.loadSuccessful)
   {
      this._visible = false;
      return undefined;
   }
   this.contentMC.setMask(this.contentMaskMC);
   var width = this.contentMC._width;
   var cHeight = this.contentMC._height;
   var tHeight = this.titleBarHeight;
   this.minX = this.leftLimit + this.buffer;
   this.maxX = this.rightLimit - this.buffer - width;
   this.minY = this.topLimit + this.buffer + tHeight;
   this.maxY = this.bottomLimit - this.buffer - cHeight;
   this.closeButtonMC._x = width - (tHeight - this.closeButtonMC._height) / 2;
   this.closeButtonMC._y = (- tHeight) / 2;
   this.titleTextFormat.color = this.titleColor;
   this.titleTextFormat.size = this.titleFontSize;
   this.displayText(this.title,{depth:10,vAlign:"top",hAlign:"left",x:this.titleXPosition,y:this.titleYPosition - tHeight,embedFonts:true,textFormat:this.titleTextFormat});
   var mc = this.backgroundMC;
   mc.beginFill(16711680,0);
   mc.moveTo(0,- tHeight);
   mc.lineTo(0,cHeight);
   mc.lineTo(width,cHeight);
   mc.lineTo(width,- tHeight);
   mc.lineTo(0,- tHeight);
   mc.endFill();
   var mc = this.titleBarBackgroundMC;
   mc.beginFill(this.titleBarColor);
   mc.moveTo(0,0);
   mc.lineTo(width,0);
   mc.lineTo(width,- tHeight);
   mc.lineTo(0,- tHeight);
   mc.lineTo(0,0);
   mc.endFill();
   var mc = this.contentMaskMC;
   mc.beginFill(16711680,10);
   mc.moveTo(0,0);
   mc.lineTo(width,0);
   mc.lineTo(width,cHeight);
   mc.lineTo(0,cHeight);
   mc.lineTo(0,0);
   mc.endFill();
   var mc = this.borderMC;
   mc.lineStyle(this.borderThickness,this.borderColor);
   mc.moveTo(0,- tHeight);
   mc.lineTo(0,cHeight);
   mc.lineTo(width,cHeight);
   mc.lineTo(width,- tHeight);
   mc.lineTo(0,- tHeight);
   mc.moveTo(0,0);
   mc.lineTo(width,0);
   this.backgroundMC.tabEnabled = false;
   this.backgroundMC.useHandCursor = false;
   this.backgroundMC.onPress = function()
   {
   };
   this.closeButtonMC.tabEnabled = true;
   this.closeButtonMC.useHandCursor = true;
   this.closeButtonMC._focusrect = false;
   this.closeButtonMC.onSetFocus = function()
   {
      this.gotoAndStop(2);
      this.onKeyDown = this.onKeyDownFunc;
   };
   this.closeButtonMC.onKillFocus = function()
   {
      this.gotoAndStop(1);
      delete this.onKeyDown;
   };
   this.closeButtonMC.onKeyDownFunc = function()
   {
      if(Key.isDown(32) || Key.isDown(13))
      {
         this._parent.hide();
      }
   };
   this.closeButtonMC.onPress = function()
   {
      this._parent.hide();
   };
   this.titleBarBackgroundMC.tabEnabled = false;
   this.titleBarBackgroundMC.useHandCursor = false;
   this.titleBarBackgroundMC.onPress = function()
   {
      this.xOffset = this._parent._parent._xmouse - this._parent._x;
      this.yOffset = this._parent._parent._ymouse - this._parent._y;
      this.onMouseMove = this.onMouseMoveFunc;
   };
   this.titleBarBackgroundMC.onMouseMoveFunc = function()
   {
      var newX = this._parent._parent._xmouse - this.xOffset;
      var newY = this._parent._parent._ymouse - this.yOffset;
      if(newX < this._parent.minX)
      {
         newX = this._parent.minX;
      }
      else if(newX > this._parent.maxX)
      {
         newX = this._parent.maxX;
      }
      if(newY < this._parent.minY)
      {
         newY = this._parent.minY;
      }
      else if(newY > this._parent.maxY)
      {
         newY = this._parent.maxY;
      }
      this._parent._x = newX;
      this._parent._y = newY;
      updateAfterEvent();
   };
   this.titleBarBackgroundMC.onRelease = this.titleBarBackgroundMC.onReleaseOutside = function()
   {
      delete this.onMouseMove;
   };
   this._x = this.leftLimit + (this.rightLimit - this.leftLimit) / 2 - width / 2;
   this._y = this.topLimit + (this.bottomLimit - this.topLimit) / 2 - (cHeight - tHeight) / 2;
};
p.hide = function()
{
   this._visible = false;
   this.closeButtonMC.gotoAndStop(1);
   delete this.closeButtonMC.onKeyDown;
};
p.show = function()
{
   this._visible = true;
};
p.getVisible = function()
{
   return this._visible;
};
p.setVisible = function(arg)
{
   this._visible = arg;
};
p.addProperty("visible",p.getVisible,p.setVisible);
p.displayText = function(textString, options)
{
   textString = String(textString);
   if(options.depth != undefined)
   {
      var mcDepth = options.depth;
   }
   else if(_global._displayedTextLastDepthUsed != undefined)
   {
      var mcDepth = ++_global._displayedTextLastDepthUsed;
   }
   else
   {
      var mcDepth = _global._displayedTextLastDepthUsed = 913001;
   }
   if(options.name != undefined)
   {
      var mcName = options.name;
   }
   else
   {
      var mcName = "_textWrapper_" + mcDepth;
   }
   if(options.mc != undefined)
   {
      var mc = options.mc.createEmptyMovieClip(mcName,mcDepth);
   }
   else
   {
      var mc = this.createEmptyMovieClip(mcName,mcDepth);
   }
   if(options.x != undefined)
   {
      mc._x = options.x;
   }
   if(options.y != undefined)
   {
      mc._y = options.y;
   }
   if(options.embedFonts != undefined)
   {
      var embedFonts = options.embedFonts;
   }
   else
   {
      var embedFonts = false;
   }
   if(options.textFormat != undefined)
   {
      var normalFormat = options.textFormat;
   }
   else
   {
      var normalFormat = new TextFormat(null,12);
   }
   var scriptFormat = new TextFormat();
   for(var x in normalFormat)
   {
      scriptFormat[x] = normalFormat[x];
   }
   if(options.sizeRatio != undefined)
   {
      scriptFormat.size = normalFormat.size / options.sizeRatio;
   }
   else
   {
      scriptFormat.size = normalFormat.size / 1.5;
   }
   mc.createTextField("_0",0,0,0,0,0);
   mc._0.autoSize = "left";
   mc._0.embedFonts = embedFonts;
   mc._0.setNewTextFormat(normalFormat);
   mc._0.text = "X";
   mc._0._visible = false;
   mc.createTextField("_1",1,0,0,0,0);
   mc._1.autoSize = "left";
   mc._1.embedFonts = embedFonts;
   mc._1.setNewTextFormat(scriptFormat);
   mc._1.text = "X";
   mc._1._visible = false;
   var lineHeight = mc._0._height;
   var scriptHeight = mc._1._height;
   if(options.superscriptPosition != undefined)
   {
      var superscriptDelta = - options.superscriptPosition;
   }
   else
   {
      var superscriptDelta = 0;
   }
   if(options.subscriptPosition != undefined)
   {
      var subscriptDelta = lineHeight - scriptHeight + options.subscriptPosition;
   }
   else
   {
      var subscriptDelta = lineHeight - scriptHeight;
   }
   if(options.extraSpacing != undefined)
   {
      var extraSpacing = options.extraSpacing;
   }
   else
   {
      var extraSpacing = 0.5;
   }
   var aL = [];
   var pos = 0;
   var iLimit = 0;
   var startInd = 0;
   do
   {
      var ind = textString.indexOf("<su",startInd);
      if(ind == -1)
      {
         aL.push({pos:pos,str:textString});
      }
      else if(textString.charAt(ind + 3) == "b" && textString.charAt(ind + 4) == ">")
      {
         if(ind != 0)
         {
            aL.push({pos:pos,str:textString.substring(0,ind)});
         }
         textString = textString.slice(ind + 5);
         pos = -1;
         var ind2 = textString.indexOf("</sub>");
         if(ind2 != -1)
         {
            if(ind2 != 0)
            {
               aL.push({pos:pos,str:textString.substring(0,ind2)});
            }
            textString = textString.slice(ind2 + 6);
            pos = 0;
         }
         startInd = 0;
      }
      else if(textString.charAt(ind + 3) == "p" && textString.charAt(ind + 4) == ">")
      {
         if(ind != 0)
         {
            aL.push({pos:pos,str:textString.substring(0,ind)});
         }
         textString = textString.slice(ind + 5);
         pos = 1;
         var ind2 = textString.indexOf("</sup>");
         if(ind2 != -1)
         {
            if(ind2 != 0)
            {
               aL.push({pos:pos,str:textString.substring(0,ind2)});
            }
            textString = textString.slice(ind2 + 6);
            pos = 0;
         }
         startInd = 0;
      }
      else
      {
         startInd = ind + 3;
      }
      iLimit++;
   }
   while(ind != -1 && textString.length > 0 && iLimit < 100);
   if(iLimit >= 100)
   {
      trace("WARNING: iteration limit reached");
   }
   var tL = [];
   var totalWidth = 0;
   var depth = 2;
   var i = 0;
   while(i < aL.length)
   {
      var name = "_" + depth;
      mc.createTextField(name,depth++,0,0,0,0);
      var tf = mc[name];
      tf.autoSize = "left";
      tf.embedFonts = embedFonts;
      tf.selectable = false;
      if(aL[i].pos == 0)
      {
         var dy = 0;
         tf.setNewTextFormat(normalFormat);
      }
      else if(aL[i].pos == 1)
      {
         var dy = superscriptDelta;
         tf.setNewTextFormat(scriptFormat);
      }
      else
      {
         var dy = subscriptDelta;
         tf.setNewTextFormat(scriptFormat);
      }
      tf.text = aL[i].str;
      tL.push({tf:tf,dy:dy});
      totalWidth += tf.textWidth;
      i++;
   }
   totalWidth += extraSpacing * (tL.length - 1);
   if(options.hAlign == "left")
   {
      var x = -2;
   }
   else if(options.hAlign == "right")
   {
      var x = -2 - totalWidth;
   }
   else
   {
      var x = -2 - totalWidth / 2;
   }
   if(options.vAlign == "top")
   {
      var y = -2;
   }
   else if(options.vAlign == "bottom")
   {
      var y = - lineHeight + 2;
   }
   else
   {
      var y = (- lineHeight) / 2;
   }
   var i = 0;
   while(i < tL.length)
   {
      var t = tL[i];
      t.tf._x = x;
      t.tf._y = y + t.dy;
      x += t.tf.textWidth + extraSpacing;
      i++;
   }
   mc.textWidth = totalWidth;
   return mc;
};
