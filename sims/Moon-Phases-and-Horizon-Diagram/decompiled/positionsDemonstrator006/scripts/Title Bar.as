function TitleBarClass()
{
   this.width = this._width;
   this.height = this._height;
   this.placeholderMC._visible = false;
   this._xscale = 100;
   this._yscale = 100;
   this.initialize();
}
var p = TitleBarClass.prototype = new MovieClip();
Object.registerClass("Title Bar",TitleBarClass);
p.onOptionClicked = function(type)
{
   this.aboutWindow.hide();
   this.helpWindow.hide();
   if(type == "about")
   {
      this.aboutWindow.show();
   }
   else if(type == "help")
   {
      this.helpWindow.show();
   }
   else if(type == "reset")
   {
      this._parent[this.resetHandlerFunc]();
   }
};
p.initialize = function()
{
   this.attachMovie(this.fontSourceLinkageName,"fontMC",121212,{_visible:false});
   this.interfaceTextFormat = this.fontMC.fontField.getTextFormat();
   this.createEmptyMovieClip("dialogWindowsMC",5);
   this.createEmptyMovieClip("backgroundMC",10);
   this.aboutWindow = this.dialogWindowsMC.attachMovie("Dialog Window v2","aboutWindowMC",1,{contentLinkageName:this.aboutLinkageName,title:"About",topLimit:this.height,buffer:5});
   this.helpWindow = this.dialogWindowsMC.attachMovie("Dialog Window v2","helpWindowMC",2,{contentLinkageName:this.helpLinkageName,title:"Help",topLimit:this.height,buffer:5});
   this.optionsList = [];
   if(this.aboutWindow.loadSuccessful)
   {
      this.optionsList.push("about");
   }
   if(this.helpWindow.loadSuccessful)
   {
      this.optionsList.push("help");
   }
   if(this.resetHandlerFunc != "" && this.resetHandlerFunc != undefined)
   {
      this.optionsList.push("reset");
   }
   this.aboutWindow.hide();
   this.helpWindow.hide();
   var bmc = this.backgroundMC;
   bmc.beginFill(this.backgroundColor);
   bmc.moveTo(-2,-2);
   bmc.lineTo(this.width + 2,-2);
   bmc.lineTo(this.width + 2,this.height);
   bmc.lineStyle(this.borderThickness,this.borderColor);
   bmc.lineTo(-2,this.height);
   bmc.lineStyle();
   bmc.lineTo(-2,-2);
   bmc.endFill();
   this.interfaceTextFormat.color = this.titleColor;
   this.interfaceTextFormat.size = this.titleFontSize;
   this.displayText(this.title,{depth:15,vAlign:"top",hAlign:"left",x:this.titleXPosition,y:this.titleYPosition,embedFonts:true,textFormat:this.interfaceTextFormat});
   this.interfaceTextFormat.color = this.optionsColor;
   this.interfaceTextFormat.size = this.optionsFontSize;
   var x = this.width + this.optionsSpacing * 0.3;
   var optionsList = this.optionsList;
   var i = 0;
   while(i < optionsList.length)
   {
      this[optionsList[i] + "MC"].removeMovieClip();
      if(this[optionsList[i] + "HandlerFunc"] != "")
      {
         var mc = this.addOptionsLabel(optionsList[i],16 + i);
         x = x - this.optionsSpacing - mc._width / 2;
         mc._x = x;
         mc._y = this.optionsYPosition;
         x -= mc._width / 2;
      }
      i++;
   }
};
p.addOptionsLabel = function(type, depth)
{
   var mc = this.createEmptyMovieClip(type + "MC",depth);
   mc.type = type;
   mc.createTextField("labelField",1,0,0,0,0);
   mc.labelField.autoSize = "center";
   mc.labelField.embedFonts = true;
   mc.labelField.setNewTextFormat(this.interfaceTextFormat);
   mc.labelField.text = type;
   mc.createEmptyMovieClip("underlineMC",2);
   mc.underlineMC._visible = false;
   mc.underlineMC.lineStyle(1,this.interfaceTextFormat.color);
   mc.underlineMC.moveTo(mc.labelField._x,mc.labelField._height - 2);
   mc.underlineMC.lineTo(mc.labelField._x + mc.labelField._width,mc.labelField._height - 2);
   mc._focusrect = false;
   mc.onSetFocus = function()
   {
      this.underlineMC._visible = true;
      this.onKeyDown = this.onKeyDownFunc;
   };
   mc.onKillFocus = function()
   {
      this.underlineMC._visible = false;
      delete this.onKeyDown;
   };
   mc.onKeyDownFunc = function()
   {
      if(Key.isDown(32))
      {
         this._parent.onOptionClicked(this.type);
         this.underlineMC._visible = false;
         delete this.onKeyDown;
      }
   };
   mc.useHandCursor = true;
   mc.onRollOver = function()
   {
      this.underlineMC._visible = true;
   };
   mc.onRollOut = function()
   {
      this.underlineMC._visible = false;
   };
   mc.onRelease = function()
   {
      this._parent.onOptionClicked(this.type);
      this.underlineMC._visible = false;
   };
   mc.onReleaseOutside = function()
   {
      this.underlineMC._visible = false;
   };
   return mc;
};
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
