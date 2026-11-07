package
{
   import flash.display.Graphics;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.geom.Matrix;
   import flash.text.TextField;
   import flash.text.TextFormat;
   
   public class SHZHabitabilityPlot extends MovieClip
   {
      
      public const cursorThickness:Number = 2;
      
      protected var _hotLabel:TextField;
      
      protected var _shadingSP:Sprite;
      
      protected var _curveSP:Sprite;
      
      protected var _destroyedSP:Sprite;
      
      protected var _cursorSP:Sprite;
      
      public const hotColor:uint = 16437932;
      
      protected var _curveMaskSP:Sprite;
      
      public var plotWidth:Number = 100;
      
      public const coldColor:uint = 10268139;
      
      public var plotHeight:Number = 30;
      
      protected var _backgroundSP:Sprite;
      
      public const cursorColor:uint = 14692400;
      
      public const cursorAlpha:Number = 0.5;
      
      protected var _coldLabel:TextField;
      
      public const shadingExtent:Number = 5;
      
      protected var _borderSP:Sprite;
      
      protected var _labelsSP:Sprite;
      
      public function SHZHabitabilityPlot(param1:Number, param2:Number)
      {
         super();
         _backgroundSP = new Sprite();
         addChild(_backgroundSP);
         _curveSP = new Sprite();
         addChild(_curveSP);
         _curveMaskSP = new Sprite();
         addChild(_curveMaskSP);
         _shadingSP = new Sprite();
         addChild(_shadingSP);
         _labelsSP = new Sprite();
         addChild(_labelsSP);
         _destroyedSP = new Sprite();
         addChild(_destroyedSP);
         _borderSP = new Sprite();
         addChild(_borderSP);
         _cursorSP = new Sprite();
         addChild(_cursorSP);
         var _loc3_:TextFormat = new TextFormat("Verdana",10,0,false,true);
         _curveMaskSP.visible = false;
         _curveSP.mask = _curveMaskSP;
         _coldLabel = new TextField();
         _loc3_.color = 6654686;
         _coldLabel.defaultTextFormat = _loc3_;
         _coldLabel.selectable = false;
         _coldLabel.embedFonts = true;
         _coldLabel.width = 0;
         _coldLabel.height = 0;
         _coldLabel.autoSize = "left";
         _coldLabel.text = "too cold";
         _hotLabel = new TextField();
         _loc3_.color = 15832376;
         _hotLabel.defaultTextFormat = _loc3_;
         _hotLabel.selectable = false;
         _hotLabel.embedFonts = true;
         _hotLabel.width = 0;
         _hotLabel.height = 0;
         _hotLabel.autoSize = "left";
         _hotLabel.text = "too hot";
         _labelsSP.addChild(_coldLabel);
         _labelsSP.addChild(_hotLabel);
         plotWidth = param1;
         plotHeight = param2;
         drawStaticContent();
      }
      
      public function drawStaticContent() : void
      {
         var _loc1_:Graphics = null;
         _loc1_ = _backgroundSP.graphics;
         _loc1_.clear();
         _loc1_.beginFill(16777215);
         _loc1_.drawRect(0,0,plotWidth,plotHeight);
         _loc1_.endFill();
         _loc1_ = _curveMaskSP.graphics;
         _loc1_.clear();
         _loc1_.beginFill(16711680);
         _loc1_.drawRect(0,0,plotWidth,plotHeight);
         _loc1_.endFill();
         _loc1_ = _shadingSP.graphics;
         _loc1_.clear();
         var _loc2_:String = "linear";
         var _loc3_:Array = [hotColor,hotColor];
         var _loc4_:Array = [1,0.2];
         var _loc5_:Array = [0,255];
         var _loc6_:Matrix = new Matrix();
         _loc6_.createGradientBox(plotWidth,shadingExtent,90 * Math.PI / 180,0,0);
         _loc1_.beginGradientFill(_loc2_,_loc3_,_loc4_,_loc5_,_loc6_);
         _loc1_.drawRect(0,0,plotWidth,shadingExtent);
         _loc1_.endFill();
         _loc3_ = [coldColor,coldColor];
         _loc6_.createGradientBox(plotWidth,shadingExtent,270 * Math.PI / 180,0,plotHeight - shadingExtent);
         _loc1_.beginGradientFill(_loc2_,_loc3_,_loc4_,_loc5_,_loc6_);
         _loc1_.drawRect(0,plotHeight - shadingExtent,plotWidth,shadingExtent);
         _loc1_.endFill();
         _loc1_ = _borderSP.graphics;
         _loc1_.clear();
         _loc1_.lineStyle(1,14737632);
         _loc1_.drawRect(0,0,plotWidth,plotHeight);
         _loc1_ = _cursorSP.graphics;
         _loc1_.clear();
         _loc1_.lineStyle(cursorThickness,cursorColor,cursorAlpha);
         _loc1_.moveTo(0,0);
         _loc1_.lineTo(0,plotHeight);
         _coldLabel.x = plotWidth - _coldLabel.width;
         _coldLabel.y = plotHeight - _coldLabel.height + 3 - shadingExtent;
         _hotLabel.x = plotWidth - _hotLabel.width;
         _hotLabel.y = -4 + shadingExtent;
      }
      
      public function setCursorTime(param1:Number, param2:Number) : void
      {
         _cursorSP.x = param1 * plotWidth / param2;
      }
      
      public function plotDataTable(param1:Array, param2:Number, param3:Number) : void
      {
         var _loc8_:int = 0;
         var _loc9_:Number = NaN;
         var _loc10_:Number = NaN;
         var _loc11_:int = 0;
         var _loc12_:Number = NaN;
         var _loc13_:Number = NaN;
         var _loc14_:int = 0;
         var _loc4_:Graphics = _curveSP.graphics;
         _loc4_.clear();
         _loc4_.lineStyle(1,5263440);
         var _loc5_:Number = plotWidth / param2;
         var _loc6_:Number = -(plotHeight - 2 * shadingExtent);
         var _loc7_:Number = plotHeight - shadingExtent;
         _loc12_ = _loc5_ * param1[0].time;
         _loc13_ = _loc6_ * param1[0].shzTemp + _loc7_;
         if(_loc13_ < 0)
         {
            _loc14_ = 1;
         }
         else if(_loc13_ > plotHeight)
         {
            _loc14_ = -1;
         }
         else
         {
            _loc14_ = 0;
         }
         var _loc15_:Number = -10;
         var _loc16_:Number = plotHeight + 10;
         if(_loc13_ < _loc15_)
         {
            _loc13_ = _loc15_;
         }
         else if(_loc13_ > _loc16_)
         {
            _loc13_ = _loc16_;
         }
         if(_loc14_ == 0)
         {
            _loc4_.moveTo(_loc12_,_loc13_);
         }
         _loc8_ = 1;
         while(_loc8_ < param1.length)
         {
            _loc9_ = _loc5_ * param1[_loc8_].time;
            _loc10_ = _loc6_ * param1[_loc8_].shzTemp + _loc7_;
            if(_loc10_ < 0)
            {
               _loc11_ = 1;
            }
            else if(_loc10_ > plotHeight)
            {
               _loc11_ = -1;
            }
            else
            {
               _loc11_ = 0;
            }
            if(_loc10_ < _loc15_)
            {
               _loc10_ = _loc15_;
            }
            else if(_loc10_ > _loc16_)
            {
               _loc10_ = _loc16_;
            }
            if(_loc14_ == 0)
            {
               _loc4_.lineTo(_loc9_,_loc10_);
            }
            else if(_loc14_ != _loc11_)
            {
               _loc4_.moveTo(_loc12_,_loc13_);
               _loc4_.lineTo(_loc9_,_loc10_);
            }
            _loc12_ = _loc9_;
            _loc13_ = _loc10_;
            _loc14_ = _loc11_;
            _loc8_++;
         }
         _loc4_ = _destroyedSP.graphics;
         _loc4_.clear();
         var _loc17_:Number = _loc5_ * param3;
         if(_loc17_ < plotWidth)
         {
            _loc4_.beginFill(0,0.15);
            _loc4_.drawRect(_loc17_,0,plotWidth - _loc17_,plotHeight);
            _loc4_.endFill();
         }
      }
   }
}

