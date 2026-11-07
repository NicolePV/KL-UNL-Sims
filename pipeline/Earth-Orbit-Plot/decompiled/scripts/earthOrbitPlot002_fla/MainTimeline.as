package earthOrbitPlot002_fla
{
   import adobe.utils.*;
   import fl.controls.CheckBox;
   import flash.accessibility.*;
   import flash.desktop.*;
   import flash.display.*;
   import flash.errors.*;
   import flash.events.*;
   import flash.external.*;
   import flash.filters.*;
   import flash.geom.*;
   import flash.media.*;
   import flash.net.*;
   import flash.printing.*;
   import flash.profiler.*;
   import flash.sampler.*;
   import flash.system.*;
   import flash.text.*;
   import flash.text.engine.*;
   import flash.ui.*;
   import flash.utils.*;
   import flash.xml.*;
   
   public dynamic class MainTimeline extends MovieClip
   {
      
      public var xIsLogCheckBox:CheckBox;
      
      public var yIsLogCheckBox:CheckBox;
      
      public var test:EarthOrbitPlot;
      
      public var titlebar:NAAPTitleBar;
      
      public function MainTimeline()
      {
         super();
         addFrameScript(0,this.frame1);
         this.__setProp_xIsLogCheckBox_Scene1_Layer1_0();
         this.__setProp_yIsLogCheckBox_Scene1_Layer1_0();
         this.__setProp_titlebar_Scene1_Layer2_0();
      }
      
      internal function __setProp_titlebar_Scene1_Layer2_0() : *
      {
         try
         {
            this.titlebar["componentInspectorSetting"] = true;
         }
         catch(e:Error)
         {
         }
         this.titlebar.aboutContent = "";
         this.titlebar.enabled = true;
         this.titlebar.helpContent = "";
         this.titlebar.title = "Earth Orbit Plot";
         this.titlebar.visible = true;
         try
         {
            this.titlebar["componentInspectorSetting"] = false;
         }
         catch(e:Error)
         {
         }
      }
      
      internal function __setProp_yIsLogCheckBox_Scene1_Layer1_0() : *
      {
         try
         {
            this.yIsLogCheckBox["componentInspectorSetting"] = true;
         }
         catch(e:Error)
         {
         }
         this.yIsLogCheckBox.enabled = true;
         this.yIsLogCheckBox.label = "y is log";
         this.yIsLogCheckBox.labelPlacement = "right";
         this.yIsLogCheckBox.selected = false;
         this.yIsLogCheckBox.visible = true;
         try
         {
            this.yIsLogCheckBox["componentInspectorSetting"] = false;
         }
         catch(e:Error)
         {
         }
      }
      
      public function onXIsLogChanged(param1:Event) : void
      {
         this.test.xIsLog = this.xIsLogCheckBox.selected;
         this.test.update();
      }
      
      public function onYIsLogChanged(param1:Event) : void
      {
         this.test.yIsLog = this.yIsLogCheckBox.selected;
         this.test.update();
      }
      
      internal function __setProp_xIsLogCheckBox_Scene1_Layer1_0() : *
      {
         try
         {
            this.xIsLogCheckBox["componentInspectorSetting"] = true;
         }
         catch(e:Error)
         {
         }
         this.xIsLogCheckBox.enabled = true;
         this.xIsLogCheckBox.label = "x is log";
         this.xIsLogCheckBox.labelPlacement = "right";
         this.xIsLogCheckBox.selected = false;
         this.xIsLogCheckBox.visible = true;
         try
         {
            this.xIsLogCheckBox["componentInspectorSetting"] = false;
         }
         catch(e:Error)
         {
         }
      }
      
      internal function frame1() : *
      {
         this.titlebar.allowReset = false;
         this.xIsLogCheckBox.visible = false;
         this.xIsLogCheckBox.addEventListener("change",this.onXIsLogChanged);
         this.yIsLogCheckBox.visible = false;
         this.yIsLogCheckBox.addEventListener("change",this.onYIsLogChanged);
      }
   }
}

