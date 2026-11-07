_global.displayText = function(textString, options)
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
      trace("WARNING: iteration limit reached");
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
