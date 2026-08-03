package
{
   import flash.display.Graphics;
   import flash.display.Shape;
   import flash.display.Sprite;
   
   public class SpectrumGraph extends Spectrum
   {
      
      protected var _filters:Shape;
      
      protected var _numObservedWavelengths:int;
      
      protected var _filterSet:Array;
      
      protected var _lineColor:uint = 0;
      
      protected var _tickmarks:Sprite;
      
      protected var _lineAlpha:Number = 1;
      
      protected var _observedFluxes:Vector.<Number>;
      
      protected var _mags:Object = {};
      
      protected var _lineThickness:Number = 0;
      
      protected var _observedMinWavelength:int;
      
      protected var _curve:Shape;
      
      protected var _observedWavelengthResolution:Number = 1;
      
      public function SpectrumGraph(param1:Number, param2:Number, param3:Array, param4:Number, param5:Number, param6:Number, param7:Array)
      {
         super(param1,param2,param3,param4,param5,param6);
         this._filterSet = param7;
         this._filters = new Shape();
         _content.addChild(this._filters);
         this._curve = new Shape();
         _content.addChild(this._curve);
         var _loc8_:int = Math.floor(param4 / this._observedWavelengthResolution);
         var _loc9_:int = Math.ceil(param5 / this._observedWavelengthResolution);
         this._observedMinWavelength = _loc8_ * this._observedWavelengthResolution;
         this._numObservedWavelengths = _loc9_ - _loc8_ + 1;
         this._observedFluxes = new Vector.<Number>(this._numObservedWavelengths);
         this.redraw();
      }
      
      protected function valueAt(param1:Number) : Number
      {
         var _loc2_:int = Math.round((param1 - this._observedMinWavelength) / this._observedWavelengthResolution);
         if(_loc2_ < 0 || _loc2_ >= this._observedFluxes.length)
         {
            return 0;
         }
         return this._observedFluxes[_loc2_];
      }
      
      protected function redrawFilters() : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc7_:Object = null;
         var _loc8_:Array = null;
         var _loc9_:Number = NaN;
         var _loc10_:Number = NaN;
         var _loc11_:Number = NaN;
         var _loc12_:Number = NaN;
         var _loc13_:Number = NaN;
         var _loc14_:Number = NaN;
         var _loc15_:Number = NaN;
         var _loc16_:Number = NaN;
         var _loc1_:Graphics = this._filters.graphics;
         _loc1_.clear();
         if(!this._filters.visible)
         {
            return;
         }
         var _loc4_:Number = _width / (_maxW - _minW);
         var _loc5_:Number = -_height / (_maxF - _minF);
         var _loc6_:Number = _redshift + 1;
         _loc2_ = 0;
         while(_loc2_ < this._filterSet.length)
         {
            _loc7_ = this._filterSet[_loc2_];
            _loc8_ = _loc7_.data;
            _loc13_ = Number(_loc8_[0].w);
            _loc9_ = _loc4_ * (_loc13_ - _minW);
            _loc1_.moveTo(_loc9_,0);
            _loc1_.beginFill(_loc7_.color,0.3);
            _loc14_ = _loc8_[0].t * this.valueAt(_loc13_);
            _loc1_.lineTo(_loc9_,_loc5_ * (_loc14_ - _minF));
            _loc12_ = 0;
            _loc15_ = _loc13_;
            _loc16_ = _loc14_;
            _loc3_ = 1;
            while(_loc3_ < _loc8_.length)
            {
               _loc13_ = Number(_loc8_[_loc3_].w);
               _loc11_ = _loc4_ * (_loc13_ - _minW);
               _loc14_ = _loc8_[_loc3_].t * this.valueAt(_loc13_);
               _loc1_.lineTo(_loc11_,_loc5_ * (_loc14_ - _minF));
               _loc12_ += (_loc13_ - _loc15_) * (_loc16_ + _loc14_) / 2;
               _loc15_ = _loc13_;
               _loc16_ = _loc14_;
               _loc3_++;
            }
            _loc1_.lineTo(_loc11_,0);
            _loc1_.lineTo(_loc9_,0);
            _loc1_.endFill();
            this._mags[_loc7_.name] = -Math.log(_loc12_);
            _loc2_++;
         }
      }
      
      public function getMagnitudes() : Object
      {
         return this._mags;
      }
      
      public function setFiltersAlpha(param1:Number) : void
      {
         this._filters.alpha = param1;
      }
      
      public function addTickmarks(param1:Array) : void
      {
         var _loc3_:TickmarkWithLabel = null;
         var _loc4_:TickmarkWithoutLabel = null;
         var _loc5_:Object = null;
         if(this._tickmarks != null)
         {
            removeChild(this._tickmarks);
         }
         this._tickmarks = new Sprite();
         addChild(this._tickmarks);
         var _loc2_:Number = _width / (_maxW - _minW);
         for each(_loc5_ in param1)
         {
            if(_loc5_.label != undefined)
            {
               _loc3_ = new TickmarkWithLabel();
               _loc3_.label.text = _loc5_.label;
               _loc3_.x = _loc2_ * (_loc5_.w - _minW);
               this._tickmarks.addChild(_loc3_);
            }
            else
            {
               _loc4_ = new TickmarkWithoutLabel();
               _loc4_.x = _loc2_ * (_loc5_.w - _minW);
               this._tickmarks.addChild(_loc4_);
            }
         }
      }
      
      public function set showFilters(param1:Boolean) : void
      {
         this._filters.visible = param1;
         if(this._filters.visible)
         {
            this.redraw();
         }
      }
      
      override public function redraw() : void
      {
         var _loc4_:int = 0;
         var _loc5_:Number = NaN;
         var _loc6_:* = 0;
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         super.redraw();
         _loc6_ = 0;
         while(_loc6_ < this._numObservedWavelengths)
         {
            this._observedFluxes[_loc6_] = Number.NaN;
            _loc6_++;
         }
         var _loc1_:Number = _width / (_maxW - _minW);
         var _loc2_:Number = -_height / (_maxF - _minF);
         var _loc3_:Number = _redshift + 1;
         _loc5_ = _loc3_ * _data[0].w;
         _loc4_ = Math.round((_loc5_ - this._observedMinWavelength) / this._observedWavelengthResolution);
         if(_loc4_ >= 0 && _loc4_ < this._numObservedWavelengths)
         {
            this._observedFluxes[_loc4_] = _data[0].f;
         }
         this._curve.graphics.clear();
         this._curve.graphics.lineStyle(this._lineThickness,this._lineColor,this._lineAlpha);
         this._curve.graphics.moveTo(_loc1_ * (_loc5_ - _minW),_loc2_ * (_data[0].f - _minF));
         _loc6_ = 1;
         while(_loc6_ < _data.length)
         {
            _loc5_ = _loc3_ * _data[_loc6_].w;
            _loc4_ = Math.round((_loc5_ - this._observedMinWavelength) / this._observedWavelengthResolution);
            if(_loc4_ >= 0 && _loc4_ < this._numObservedWavelengths)
            {
               this._observedFluxes[_loc4_] = _data[_loc6_].f;
            }
            _data[_loc6_].wShifted = _loc5_;
            _loc7_ = _loc1_ * (_loc5_ - _minW);
            _loc8_ = _loc2_ * (_data[_loc6_].f - _minF);
            if(_loc7_ < 0)
            {
               this._curve.graphics.moveTo(_loc7_,_loc8_);
            }
            else
            {
               if(_loc7_ >= _width)
               {
                  this._curve.graphics.lineTo(_loc7_,_loc8_);
                  break;
               }
               this._curve.graphics.lineTo(_loc7_,_loc8_);
            }
            _loc6_++;
         }
         var _loc9_:int = 0;
         var _loc10_:int = 0;
         _loc6_ = int(this._numObservedWavelengths - 1);
         while(_loc6_ >= 0)
         {
            if(!isNaN(this._observedFluxes[_loc6_]))
            {
               _loc10_ = _loc6_;
               break;
            }
            this._observedFluxes[_loc6_] = 0;
            _loc6_--;
         }
         _loc6_ = 0;
         while(_loc6_ < _loc10_)
         {
            if(!isNaN(this._observedFluxes[_loc6_]))
            {
               _loc9_ = _loc6_;
               break;
            }
            this._observedFluxes[_loc6_] = 0;
            _loc6_++;
         }
         var _loc11_:int = 0;
         _loc6_ = _loc9_;
         while(_loc6_ <= _loc10_)
         {
            if(isNaN(this._observedFluxes[_loc6_]))
            {
               this._observedFluxes[_loc6_] = 0;
               _loc11_++;
            }
            _loc6_++;
         }
         if(_loc11_ > 0)
         {
            trace("WARNING, NEED TO IMPLEMENT INTERPOLATION, gaps: " + _loc11_);
         }
         this.redrawFilters();
      }
      
      public function get showFilters() : Boolean
      {
         return this._filters.visible;
      }
   }
}

