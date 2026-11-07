package lunarPhaseQuizzer003_fla
{
   import adobe.utils.*;
   import astroUNL.naap.NAAPTitleBar;
   import astroUNL.utils.PhaseDisc;
   import astroUNL.utils.easing.CubicEaser;
   import fl.controls.Button;
   import fl.controls.RadioButton;
   import fl.controls.RadioButtonGroup;
   import fl.managers.StyleManager;
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
   
   [Embed(source="/_assets/assets.swf", symbol="symbol119")]
   public dynamic class LunarPhaseQuizzer_1 extends MovieClip
   {
      
      public var hideSunlightRadioButton:RadioButton;
      
      public var toggleAnswerButton:Button;
      
      public var moonAppearance:PhaseDisc;
      
      public var moonAppearanceQuestion:MovieClip;
      
      public var diagram:Diagram;
      
      public var phaseAngleSlider:ProtoSimpleSliderMoonPhase;
      
      public var moonImage:moonPhaseImage;
      
      public var modeGroup:RadioButtonGroup;
      
      public var moonBlank:MoonBlank;
      
      public var hideMoonAppearanceRadioButton:RadioButton;
      
      public var hideMoonRadioButton:RadioButton;
      
      public var moonAppearanceAlphaEaser:CubicEaser;
      
      public var titlebar:NAAPTitleBar;
      
      public var noTransition:Boolean;
      
      public function LunarPhaseQuizzer_1()
      {
         super();
         addFrameScript(0,this.frame1);
         this.__setProp_hideSunlightRadioButton_LunarPhaseQuizzer_Layer2_0();
         this.__setProp_hideMoonRadioButton_LunarPhaseQuizzer_Layer2_0();
         this.__setProp_hideMoonAppearanceRadioButton_LunarPhaseQuizzer_Layer2_0();
         this.__setProp_toggleAnswerButton_LunarPhaseQuizzer_Layer2_0();
         this.__setProp_titlebar_LunarPhaseQuizzer_Layer3_0();
      }
      
      public function syncMoonAppearance(param1:Event = null) : void
      {
         this.phaseAngleSlider.value = ((Math.PI - this.diagram.phaseAngle) % (2 * Math.PI) + 2 * Math.PI) % (2 * Math.PI);
         this.moonAppearance.phaseAngle = this.diagram.phaseAngle;
      }
      
      public function onModeTransitionStep(param1:Event) : void
      {
         this.moonAppearance.alpha = this.phaseAngleSlider.grabberMC.alpha = this.moonAppearanceAlphaEaser.getValue(getTimer());
         this.moonBlank.alpha = this.moonAppearanceQuestion.alpha = 1 - this.moonAppearance.alpha;
      }
      
      public function onToggleShowAnswer(param1:MouseEvent) : void
      {
         if(this.diagram.mode == Diagram.SHOW_ALL)
         {
            this.setMode(this.modeGroup.selectedData as String);
         }
         else
         {
            this.setMode(Diagram.SHOW_ALL);
         }
      }
      
      public function reset(param1:Event = null) : void
      {
         var _loc2_:Number = getTimer();
         this.noTransition = true;
         if(!this.hideMoonAppearanceRadioButton.selected)
         {
            this.hideMoonAppearanceRadioButton.selected = true;
         }
         else
         {
            this.setMode(Diagram.HIDE_MOON_APPEARANCE);
         }
         this.noTransition = false;
         this.diagram.moonAngle = Math.PI / 4;
         this.diagram.sunlightAngle = Math.PI;
         this.syncMoonAppearance();
      }
      
      internal function __setProp_hideMoonAppearanceRadioButton_LunarPhaseQuizzer_Layer2_0() : *
      {
         try
         {
            this.hideMoonAppearanceRadioButton["componentInspectorSetting"] = true;
         }
         catch(e:Error)
         {
         }
         this.hideMoonAppearanceRadioButton.enabled = true;
         this.hideMoonAppearanceRadioButton.groupName = "modeGroup";
         this.hideMoonAppearanceRadioButton.label = "What is the Moon\'s phase?";
         this.hideMoonAppearanceRadioButton.labelPlacement = "right";
         this.hideMoonAppearanceRadioButton.selected = false;
         this.hideMoonAppearanceRadioButton.value = "hideMoonAppearance";
         this.hideMoonAppearanceRadioButton.visible = true;
         try
         {
            this.hideMoonAppearanceRadioButton["componentInspectorSetting"] = false;
         }
         catch(e:Error)
         {
         }
      }
      
      internal function __setProp_hideSunlightRadioButton_LunarPhaseQuizzer_Layer2_0() : *
      {
         try
         {
            this.hideSunlightRadioButton["componentInspectorSetting"] = true;
         }
         catch(e:Error)
         {
         }
         this.hideSunlightRadioButton.enabled = true;
         this.hideSunlightRadioButton.groupName = "modeGroup";
         this.hideSunlightRadioButton.label = "Where is the Sun?";
         this.hideSunlightRadioButton.labelPlacement = "right";
         this.hideSunlightRadioButton.selected = false;
         this.hideSunlightRadioButton.value = "hideSunlight";
         this.hideSunlightRadioButton.visible = true;
         try
         {
            this.hideSunlightRadioButton["componentInspectorSetting"] = false;
         }
         catch(e:Error)
         {
         }
      }
      
      internal function frame1() : *
      {
         this.diagram.addEventListener(Diagram.MOON_DRAGGED,this.syncMoonAppearance);
         this.diagram.addEventListener(Diagram.SUNLIGHT_DRAGGED,this.syncMoonAppearance);
         this.phaseAngleSlider.addEventListener(Event.CHANGE,this.onPhaseAngleSliderChanged);
         this.modeGroup = this.hideSunlightRadioButton.group;
         this.modeGroup.addEventListener(Event.CHANGE,this.onModeChanged);
         this.toggleAnswerButton.addEventListener(MouseEvent.CLICK,this.onToggleShowAnswer);
         this.diagram.addEventListener(Diagram.MODE_FINALIZED,this.onModeFinalized);
         this.diagram.addEventListener(Diagram.MODE_TRANSITION_STEP,this.onModeTransitionStep);
         this.moonAppearanceAlphaEaser = new CubicEaser(1);
         this.moonAppearance = new PhaseDisc({
            "radius":101,
            "darkColor":0,
            "darkAlpha":0.8,
            "lightAlpha":0
         });
         this.moonAppearance.x = this.moonImage.x;
         this.moonAppearance.y = this.moonImage.y;
         addChild(this.moonAppearance);
         this.moonBlank = new MoonBlank(100);
         this.moonBlank.x = this.moonImage.x;
         this.moonBlank.y = this.moonImage.y;
         addChild(this.moonBlank);
         setChildIndex(this.moonAppearanceQuestion,numChildren - 1);
         setChildIndex(this.titlebar,numChildren - 1);
         this.titlebar.addEventListener(NAAPTitleBar.RESET,this.reset);
         this.noTransition = false;
         this.reset();
         StyleManager.setStyle("disabledTextFormat",new TextFormat("Verdana",12,6316128));
         StyleManager.setStyle("textFormat",new TextFormat("Verdana",12,0));
         StyleManager.setStyle("embedFonts",true);
         StyleManager.setStyle("focusRectSkin",NAAP_focusRectSkin);
      }
      
      public function setMode(param1:String) : void
      {
         var _loc2_:Boolean = this.diagram.setMode(param1,this.noTransition);
         if(this.diagram.mode == Diagram.HIDE_MOON_APPEARANCE)
         {
            this.phaseAngleSlider.setEnabled(false);
            if(!this.noTransition)
            {
               this.moonAppearanceAlphaEaser.setTarget(getTimer(),null,this.diagram.modeTransitionStopTime,0);
            }
         }
         else
         {
            this.phaseAngleSlider.setEnabled(true);
            if(!this.noTransition)
            {
               this.moonAppearanceAlphaEaser.setTarget(getTimer(),null,this.diagram.modeTransitionStopTime,1);
            }
         }
         if(this.diagram.mode == Diagram.SHOW_ALL)
         {
            this.toggleAnswerButton.label = "hide answer";
            this.hideSunlightRadioButton.enabled = false;
            this.hideMoonRadioButton.enabled = false;
            this.hideMoonAppearanceRadioButton.enabled = false;
         }
         else
         {
            this.toggleAnswerButton.label = "show answer";
            this.hideSunlightRadioButton.enabled = true;
            this.hideMoonRadioButton.enabled = true;
            this.hideMoonAppearanceRadioButton.enabled = true;
         }
         if(!_loc2_)
         {
            this.onModeFinalized();
         }
      }
      
      internal function __setProp_hideMoonRadioButton_LunarPhaseQuizzer_Layer2_0() : *
      {
         try
         {
            this.hideMoonRadioButton["componentInspectorSetting"] = true;
         }
         catch(e:Error)
         {
         }
         this.hideMoonRadioButton.enabled = true;
         this.hideMoonRadioButton.groupName = "modeGroup";
         this.hideMoonRadioButton.label = "Where is the Moon?";
         this.hideMoonRadioButton.labelPlacement = "right";
         this.hideMoonRadioButton.selected = false;
         this.hideMoonRadioButton.value = "hideMoon";
         this.hideMoonRadioButton.visible = true;
         try
         {
            this.hideMoonRadioButton["componentInspectorSetting"] = false;
         }
         catch(e:Error)
         {
         }
      }
      
      internal function __setProp_titlebar_LunarPhaseQuizzer_Layer3_0() : *
      {
         try
         {
            this.titlebar["componentInspectorSetting"] = true;
         }
         catch(e:Error)
         {
         }
         this.titlebar.aboutContent = "About";
         this.titlebar.enabled = true;
         this.titlebar.helpContent = "Help";
         this.titlebar.title = "Lunar Phase Quizzer";
         this.titlebar.visible = true;
         try
         {
            this.titlebar["componentInspectorSetting"] = false;
         }
         catch(e:Error)
         {
         }
      }
      
      public function onModeFinalized(param1:Event = null) : void
      {
         if(this.diagram.mode != Diagram.HIDE_MOON_APPEARANCE)
         {
            this.moonAppearanceAlphaEaser.init(1);
            this.moonAppearance.alpha = this.phaseAngleSlider.grabberMC.alpha = 1;
         }
         else
         {
            this.moonAppearanceAlphaEaser.init(0);
            this.moonAppearance.alpha = this.phaseAngleSlider.grabberMC.alpha = 0;
         }
         this.moonBlank.alpha = this.moonAppearanceQuestion.alpha = 1 - this.moonAppearance.alpha;
      }
      
      public function onModeChanged(param1:Event) : void
      {
         this.setMode(this.modeGroup.selectedData as String);
      }
      
      public function onPhaseAngleSliderChanged(param1:Event) : void
      {
         this.diagram.phaseAngle = Math.PI - this.phaseAngleSlider.value;
         this.moonAppearance.phaseAngle = this.diagram.phaseAngle;
      }
      
      internal function __setProp_toggleAnswerButton_LunarPhaseQuizzer_Layer2_0() : *
      {
         try
         {
            this.toggleAnswerButton["componentInspectorSetting"] = true;
         }
         catch(e:Error)
         {
         }
         this.toggleAnswerButton.emphasized = false;
         this.toggleAnswerButton.enabled = true;
         this.toggleAnswerButton.label = "show answer";
         this.toggleAnswerButton.labelPlacement = "right";
         this.toggleAnswerButton.selected = false;
         this.toggleAnswerButton.toggle = false;
         this.toggleAnswerButton.visible = true;
         try
         {
            this.toggleAnswerButton["componentInspectorSetting"] = false;
         }
         catch(e:Error)
         {
         }
      }
   }
}

