package
{
   import flash.display.Sprite;
   import flash.text.TextField;
   import flash.text.TextFormat;
   
   public class SHZDiagramRefOrbits extends Sprite
   {
      
      public var highlightLineColor:uint = 16736416;
      
      protected var _labelBaseR:Number;
      
      protected var _orbitsList:Array;
      
      public var labelMargin:Number = 0;
      
      public var lineAlpha:Number = 0.8;
      
      protected var _KY1:Number;
      
      public var highlightLineAlpha:Number = 0.8;
      
      public var lineColor:uint = 9474192;
      
      public var highlightLineThickness:Number = 1.5;
      
      protected var _diagram:SHZDiagram;
      
      protected var _labelTextFormat:TextFormat;
      
      protected var _KY2:Number;
      
      public var lineThickness:Number = 1;
      
      protected var _labelCurveX:Number;
      
      protected var _KX2:Number;
      
      protected var _labelBaseX:Number;
      
      protected var _labelBaseY:Number;
      
      protected var _KX1:Number;
      
      public var highlightedOrbit:int = -1;
      
      protected var _labelsSP:Sprite;
      
      protected const _ptsPerOrbit:int = 12;
      
      public function SHZDiagramRefOrbits(param1:SHZDiagram, param2:uint = 0, param3:uint = 0, param4:Number = 25)
      {
         super();
         if(param2 != 0)
         {
            lineColor = param2;
         }
         if(param3 != 0)
         {
            highlightLineColor = param3;
         }
         _diagram = param1;
         _labelTextFormat = new TextFormat("Verdana",11,lineColor,true);
         _labelTextFormat.align = "center";
         _labelsSP = new Sprite();
         addChild(_labelsSP);
         _orbitsList = [];
         _labelBaseX = 200;
         _labelBaseY = _diagram.height / 2 - param4;
         _labelBaseR = Math.sqrt(_labelBaseX * _labelBaseX + _labelBaseY * _labelBaseY);
         _labelCurveX = _labelBaseX / 4;
         _KX1 = 2 * _labelCurveX;
         _KX2 = _labelBaseX - 2 * _labelCurveX;
         _KY1 = 2 * _labelBaseY;
         _KY2 = _labelBaseY - 2 * _labelBaseY;
      }
      
      public function update() : void
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         var _loc3_:Number = NaN;
         var _loc4_:Object = null;
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc10_:Number = NaN;
         var _loc11_:Number = NaN;
         var _loc12_:Number = NaN;
         var _loc13_:Boolean = false;
         var _loc14_:Number = _diagram.scale;
         graphics.clear();
         _loc1_ = 0;
         while(_loc1_ < _orbitsList.length)
         {
            _loc4_ = _orbitsList[_loc1_];
            _loc3_ = _loc4_.a * _loc14_;
            if(_loc3_ < _diagram.safeRadius)
            {
               if(_loc1_ == highlightedOrbit)
               {
                  graphics.lineStyle(highlightLineThickness,highlightLineColor,highlightLineAlpha);
                  _loc4_.labelField.textColor = highlightLineColor;
               }
               else
               {
                  graphics.lineStyle(lineThickness,lineColor,lineAlpha);
                  _loc4_.labelField.textColor = lineColor;
               }
               graphics.moveTo(_loc14_ * _loc4_.pts[_ptsPerOrbit - 1].ax,_loc14_ * _loc4_.pts[_ptsPerOrbit - 1].ay);
               _loc2_ = 0;
               while(_loc2_ < _ptsPerOrbit)
               {
                  graphics.curveTo(_loc14_ * _loc4_.pts[_loc2_].cx,_loc14_ * _loc4_.pts[_loc2_].cy,_loc14_ * _loc4_.pts[_loc2_].ax,_loc14_ * _loc4_.pts[_loc2_].ay);
                  _loc2_++;
               }
               if(_loc4_.labelField != undefined && _labelsSP.visible)
               {
                  _loc12_ = _labelBaseY / ((labelMargin + _loc14_ * _loc4_.a) * _loc4_.k);
                  _loc13_ = _loc12_ > 1 || _loc12_ < -1;
                  if(!_loc13_)
                  {
                     _loc10_ = (labelMargin + _loc14_ * _loc4_.a) * (-_loc4_.e + Math.cos(Math.asin(_loc12_)));
                     _loc13_ = _loc10_ < _labelBaseX;
                     if(!_loc13_)
                     {
                        _loc4_.labelField.scaleX = _loc4_.labelField.scaleY = 1;
                        _loc4_.labelField.x = _loc10_;
                        _loc4_.labelField.y = _labelBaseY;
                     }
                  }
                  if(_loc13_)
                  {
                     _loc5_ = 0.5;
                     _loc6_ = 0.5;
                     _loc2_ = 0;
                     while(_loc2_ < 12)
                     {
                        _loc6_ *= 0.5;
                        _loc7_ = _loc5_ * (_KX1 + _loc5_ * _KX2);
                        _loc8_ = _loc5_ * (_KY1 + _loc5_ * _KY2);
                        _loc12_ = _loc8_ / ((labelMargin + _loc14_ * _loc4_.a) * _loc4_.k);
                        if(_loc12_ > 1)
                        {
                           _loc12_ = 1;
                           _loc5_ -= _loc6_;
                        }
                        else
                        {
                           if(_loc12_ < -1)
                           {
                              _loc12_ = -1;
                           }
                           _loc9_ = (labelMargin + _loc14_ * _loc4_.a) * (-_loc4_.e + Math.cos(Math.asin(_loc12_)));
                           if(_loc9_ > _loc7_)
                           {
                              _loc5_ += _loc6_;
                           }
                           else
                           {
                              _loc5_ -= _loc6_;
                           }
                        }
                        _loc2_++;
                     }
                     _loc4_.labelField.scaleX = _loc4_.labelField.scaleY = Math.pow(Math.sqrt(_loc7_ * _loc7_ + _loc8_ * _loc8_) / _labelBaseR,0.4);
                     _loc4_.labelField.x = _loc7_;
                     _loc4_.labelField.y = _loc8_;
                  }
                  _loc4_.labelField.visible = true;
               }
            }
            else if(_loc4_.labelField != undefined && _labelsSP.visible)
            {
               _loc4_.labelField.visible = false;
            }
            _loc1_++;
         }
      }
      
      public function get showLabels() : Boolean
      {
         return _labelsSP.visible;
      }
      
      public function setList(param1:Array) : void
      {
         var _loc2_:TextField = null;
         var _loc3_:* = 0;
         var _loc4_:Object = null;
         var _loc5_:int = 0;
         var _loc8_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc10_:Number = NaN;
         var _loc11_:Number = NaN;
         var _loc12_:Array = null;
         var _loc13_:Number = NaN;
         var _loc14_:Number = NaN;
         _orbitsList = [];
         var _loc6_:Number = 2 * Math.PI / _ptsPerOrbit;
         var _loc7_:Number = 1 / Math.cos(_loc6_ / 2);
         _loc3_ = int(_labelsSP.numChildren - 1);
         while(_loc3_ >= 0)
         {
            _labelsSP.removeChildAt(_loc3_);
            _loc3_--;
         }
         _loc3_ = 0;
         while(_loc3_ < param1.length)
         {
            _loc4_ = {};
            _loc8_ = Number(_loc4_.a = param1[_loc3_].a);
            _loc9_ = Number(_loc4_.e = param1[_loc3_].e);
            _loc10_ = _loc8_ * Math.sqrt(1 - _loc9_ * _loc9_);
            _loc11_ = _loc9_ * _loc8_;
            _loc12_ = [];
            _loc13_ = _loc6_ / 2;
            _loc14_ = _loc6_;
            _loc5_ = 0;
            while(_loc5_ < _ptsPerOrbit)
            {
               _loc12_[_loc5_] = {
                  "cx":-_loc11_ + _loc8_ * _loc7_ * Math.cos(_loc13_),
                  "cy":_loc10_ * _loc7_ * Math.sin(_loc13_),
                  "ax":-_loc11_ + _loc8_ * Math.cos(_loc14_),
                  "ay":_loc10_ * Math.sin(_loc14_)
               };
               _loc13_ += _loc6_;
               _loc14_ += _loc6_;
               _loc5_++;
            }
            _loc4_.pts = _loc12_;
            _loc4_.k = Math.sqrt(1 - _loc9_ * _loc9_);
            if(param1[_loc3_].label is String)
            {
               _loc2_ = new TextField();
               _loc2_.width = 0;
               _loc2_.height = 0;
               _loc2_.autoSize = "center";
               _loc2_.embedFonts = true;
               _loc2_.defaultTextFormat = _labelTextFormat;
               _loc2_.selectable = false;
               _loc2_.text = param1[_loc3_].label;
               _labelsSP.addChild(_loc2_);
               _loc4_.labelField = _loc2_;
            }
            _orbitsList.push(_loc4_);
            _loc3_++;
         }
         update();
      }
      
      public function set showLabels(param1:Boolean) : void
      {
         _labelsSP.visible = param1;
         update();
      }
   }
}

