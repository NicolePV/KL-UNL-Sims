package edu.unl.astro.utils
{
   import fl.data.DataProvider;
   import fl.events.DataChangeEvent;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   
   public class PlotSeries extends EventDispatcher
   {
      
      public static const REFRESH_REQUESTED:String = "refreshRequested";
      
      public var pointOutlineThickness:Number = 1;
      
      public var showLines:Boolean = false;
      
      public var showPoints:Boolean = true;
      
      public var lineAlpha:Number = 1;
      
      public var pointRadius:Number = 2;
      
      public var lineColor:uint = 10526880;
      
      public var yAxisPropertyName:String = "";
      
      public var lineThickness:Number = 1;
      
      public var xAxisPropertyName:String = "";
      
      private var _dataProvider:DataProvider;
      
      public var pointFillAlpha:Number = 1;
      
      public var pointFillColor:uint = 16448250;
      
      public var pointOutlineColor:uint = 9474192;
      
      public var pointOutlineAlpha:Number = 1;
      
      public function PlotSeries(... rest)
      {
         super();
         dataProvider = new DataProvider();
         if(rest.length > 0)
         {
            loadSettingsFromObjectsList(rest);
         }
      }
      
      private function onDataChanged(param1:DataChangeEvent) : void
      {
         dispatchEvent(param1);
      }
      
      private function loadSettingsFromObjectsList(param1:Array) : void
      {
         var _loc2_:String = null;
         var _loc3_:* = undefined;
         for each(_loc3_ in param1)
         {
            if(_loc3_ is Object)
            {
               for(_loc2_ in _loc3_)
               {
                  this[_loc2_] = _loc3_[_loc2_];
               }
            }
         }
      }
      
      public function refresh() : void
      {
         dispatchEvent(new Event(PlotSeries.REFRESH_REQUESTED));
      }
      
      public function get dataProvider() : DataProvider
      {
         return _dataProvider;
      }
      
      public function set dataProvider(param1:DataProvider) : void
      {
         if(_dataProvider != null)
         {
            _dataProvider.removeEventListener(DataChangeEvent.DATA_CHANGE,onDataChanged);
         }
         _dataProvider = param1;
         if(_dataProvider != null)
         {
            _dataProvider.addEventListener(DataChangeEvent.DATA_CHANGE,onDataChanged);
         }
         dispatchEvent(new Event(PlotSeries.REFRESH_REQUESTED));
      }
      
      public function loadSettings(... rest) : void
      {
         loadSettingsFromObjectsList(rest);
      }
   }
}

