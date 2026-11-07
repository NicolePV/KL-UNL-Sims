package moonBisectorDemo005_fla
{
   import adobe.utils.*;
   import fl.controls.Button;
   import fl.controls.CheckBox;
   import fl.controls.Slider;
   import fl.managers.StyleManager;
   import flash.accessibility.*;
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
   import flash.ui.*;
   import flash.utils.*;
   import flash.xml.*;
   
   public dynamic class MainTimeline extends MovieClip
   {
      
      public var moon:Globe3D;
      
      public var maxEarthPlanesLineAlpha1:Number;
      
      public var maxEarthPlanesLineAlpha2:Number;
      
      public var slewMode:String;
      
      public var thetaSlider:ProtoCyclicSimpleSlider;
      
      public var minEarthAlpha:Number;
      
      public var maxEarthLineAlpha:Number;
      
      public var contrastSliderLabel:MovieClip;
      
      public var showAllStepsButton:Button;
      
      public var showMoonDiscCheckbox:CheckBox;
      
      public var shadowsCheckbox:CheckBox;
      
      public var overheadPerspectiveButton:Button;
      
      public var minEarthPlanesAlpha1:Number;
      
      public var minEarthPlanesAlpha2:Number;
      
      public var moonDist:Number;
      
      public var slewTimer:Timer;
      
      public var earth:Globe3D;
      
      public var earthBack:Globe3D;
      
      public var slewEaser:CubicEaser;
      
      public var earthMoonBisectorsCheckbox:CheckBox;
      
      public var orbitalPlane:OrbitalPlane;
      
      public var earthPerspectiveButton:Button;
      
      public var maxEarthPlanesAlpha2:Number;
      
      public var maxEarthPlanesAlpha1:Number;
      
      public const slewDuration:Number = 900;
      
      public var earthPlanes:BisectingPlanesForGlobe3D;
      
      public var contrastSlider:Slider;
      
      public var scene:Scene3D;
      
      public var minEarthLineAlpha:Number;
      
      public var disc:PhaseDisc;
      
      public var slewTargetPhi:Number;
      
      public var sunBisectorsCheckbox:CheckBox;
      
      public var sunAngleSlider:ProtoCyclicSimpleSlider;
      
      public var phiSlider:ProtoSimpleSlider;
      
      public var maxEarthAlpha:Number;
      
      public var hideAllStepsButton:Button;
      
      public var titlebar:NAAPTitleBar;
      
      public var slewTargetTheta:Number;
      
      public var moonAngleSlider:ProtoCyclicSimpleSlider;
      
      public var minEarthPlanesLineAlpha1:Number;
      
      public var minEarthPlanesLineAlpha2:Number;
      
      public var earthMoonLineCheckbox:CheckBox;
      
      public var slewInitTheta:Number;
      
      public var moonLayersData:Array;
      
      public var slewInitTime:Number;
      
      public var phaseNameField:TextField;
      
      public var sunLinesCheckbox:CheckBox;
      
      public var moonPlanes:BisectingPlanesForGlobe3D;
      
      public var slewInitPhi:Number;
      
      public function MainTimeline()
      {
         super();
         addFrameScript(0,frame1);
         __setProp_earthPerspectiveButton_Scene1_Layer10_0();
         __setProp_overheadPerspectiveButton_Scene1_Layer10_0();
         __setProp_hideAllStepsButton_Scene1_Layer10_0();
         __setProp_showAllStepsButton_Scene1_Layer10_0();
         __setProp_sunLinesCheckbox_Scene1_Layer1_0();
         __setProp_sunBisectorsCheckbox_Scene1_Layer1_0();
         __setProp_shadowsCheckbox_Scene1_Layer1_0();
         __setProp_earthMoonLineCheckbox_Scene1_Layer1_0();
         __setProp_earthMoonBisectorsCheckbox_Scene1_Layer1_0();
         __setProp_showMoonDiscCheckbox_Scene1_Layer1_0();
         __setProp_contrastSlider_Scene1_Layer1_0();
         __setProp_titlebar_Scene1_titlebar_0();
      }
      
      public function updateHideAllShowAllStepsButtons() : void
      {
         var _loc1_:int = 0;
         if(sunLinesCheckbox.selected)
         {
            _loc1_++;
         }
         if(sunBisectorsCheckbox.selected)
         {
            _loc1_++;
         }
         if(shadowsCheckbox.selected)
         {
            _loc1_++;
         }
         if(earthMoonLineCheckbox.selected)
         {
            _loc1_++;
         }
         if(earthMoonBisectorsCheckbox.selected)
         {
            _loc1_++;
         }
         if(showMoonDiscCheckbox.selected)
         {
            _loc1_++;
         }
         if(_loc1_ == 6)
         {
            showAllStepsButton.enabled = false;
            hideAllStepsButton.enabled = true;
         }
         else if(_loc1_ == 0)
         {
            showAllStepsButton.enabled = true;
            hideAllStepsButton.enabled = false;
         }
         else
         {
            showAllStepsButton.enabled = true;
            hideAllStepsButton.enabled = true;
         }
      }
      
      public function updateShowShadows(... rest) : void
      {
         earthBack.showShading = moon.showShading = earth.showShading = shadowsCheckbox.selected;
         scene.update();
         contrastSlider.enabled = shadowsCheckbox.selected;
         if(shadowsCheckbox.selected)
         {
            contrastSliderLabel.gotoAndStop("enabled");
         }
         else
         {
            contrastSliderLabel.gotoAndStop("disabled");
         }
         updateHideAllShowAllStepsButtons();
      }
      
      public function onSlewTimer(param1:TimerEvent) : void
      {
         var _loc2_:Number = (getTimer() - slewInitTime) / slewDuration;
         if(_loc2_ > 1)
         {
            _loc2_ = 1;
         }
         var _loc3_:Number = slewEaser.getValue(_loc2_);
         var _loc4_:Number = ((slewInitTheta + _loc3_ * (slewTargetTheta - slewInitTheta)) % 360 + 360) % 360;
         var _loc5_:Number = slewInitPhi + _loc3_ * (slewTargetPhi - slewInitPhi);
         if(_loc5_ > 90)
         {
            _loc5_ = 90;
         }
         else if(_loc5_ < -90)
         {
            _loc5_ = -90;
         }
         thetaSlider.value = _loc4_;
         phiSlider.value = _loc5_;
         scene.setViewerThetaAndPhi(_loc4_,_loc5_);
         if(_loc2_ >= 1)
         {
            cancelSlew();
         }
      }
      
      public function updateSunBisectors(... rest) : *
      {
         earthPlanes.show1 = moonPlanes.show1 = sunBisectorsCheckbox.selected;
         scene.update();
         updateHideAllShowAllStepsButtons();
      }
      
      public function updateEarthMoonBisectors(... rest) : void
      {
         earthPlanes.show2 = moonPlanes.show2 = earthMoonBisectorsCheckbox.selected;
         scene.update();
         updateHideAllShowAllStepsButtons();
      }
      
      internal function __setProp_overheadPerspectiveButton_Scene1_Layer10_0() : *
      {
         try
         {
            overheadPerspectiveButton["componentInspectorSetting"] = true;
         }
         catch(e:Error)
         {
         }
         overheadPerspectiveButton.emphasized = false;
         overheadPerspectiveButton.enabled = true;
         overheadPerspectiveButton.label = "overhead";
         overheadPerspectiveButton.labelPlacement = "right";
         overheadPerspectiveButton.selected = false;
         overheadPerspectiveButton.toggle = false;
         overheadPerspectiveButton.visible = true;
         try
         {
            overheadPerspectiveButton["componentInspectorSetting"] = false;
         }
         catch(e:Error)
         {
         }
      }
      
      public function updateShowEarthMoonLine(... rest) : void
      {
         orbitalPlane.passData({"showEarthMoonLine":earthMoonLineCheckbox.selected});
         updateHideAllShowAllStepsButtons();
      }
      
      internal function __setProp_sunLinesCheckbox_Scene1_Layer1_0() : *
      {
         try
         {
            sunLinesCheckbox["componentInspectorSetting"] = true;
         }
         catch(e:Error)
         {
         }
         sunLinesCheckbox.enabled = true;
         sunLinesCheckbox.label = "Step 1 - show Sun direction";
         sunLinesCheckbox.labelPlacement = "right";
         sunLinesCheckbox.selected = false;
         sunLinesCheckbox.visible = true;
         try
         {
            sunLinesCheckbox["componentInspectorSetting"] = false;
         }
         catch(e:Error)
         {
         }
      }
      
      public function getPhaseNameFromAngle(param1:Number) : String
      {
         param1 = (param1 % 360 + 360) % 360;
         var _loc2_:Number = 5;
         var _loc3_:Number = 12;
         if(param1 <= _loc3_)
         {
            return "New Moon";
         }
         if(param1 <= 90 - _loc2_)
         {
            return "Waxing Crescent";
         }
         if(param1 <= 90 + _loc2_)
         {
            return "First Quarter";
         }
         if(param1 <= 180 - _loc3_)
         {
            return "Waxing Gibbous";
         }
         if(param1 <= 180 + _loc3_)
         {
            return "Full Moon";
         }
         if(param1 <= 270 - _loc2_)
         {
            return "Waning Gibbous";
         }
         if(param1 <= 270 + _loc2_)
         {
            return "Third Quarter";
         }
         if(param1 <= 360 - _loc3_)
         {
            return "Waning Crescent";
         }
         return "New Moon";
      }
      
      internal function __setProp_earthMoonBisectorsCheckbox_Scene1_Layer1_0() : *
      {
         try
         {
            earthMoonBisectorsCheckbox["componentInspectorSetting"] = true;
         }
         catch(e:Error)
         {
         }
         earthMoonBisectorsCheckbox.enabled = true;
         earthMoonBisectorsCheckbox.label = "Step 5 - show Earth-Moon bisectors";
         earthMoonBisectorsCheckbox.labelPlacement = "right";
         earthMoonBisectorsCheckbox.selected = false;
         earthMoonBisectorsCheckbox.visible = true;
         try
         {
            earthMoonBisectorsCheckbox["componentInspectorSetting"] = false;
         }
         catch(e:Error)
         {
         }
      }
      
      public function reset(... rest) : void
      {
         trace("reset");
         sunLinesCheckbox.selected = false;
         sunBisectorsCheckbox.selected = false;
         shadowsCheckbox.selected = false;
         earthMoonLineCheckbox.selected = false;
         earthMoonBisectorsCheckbox.selected = false;
         showMoonDiscCheckbox.selected = false;
         sunAngleSlider.value = 270;
         moonAngleSlider.value = 180;
         thetaSlider.value = 0;
         phiSlider.value = 90;
         updateShowSunLines();
         updateSunBisectors();
         updateShowShadows();
         updateShowEarthMoonLine();
         updateEarthMoonBisectors();
         updateShowMoonDisc();
         updateSunAngle();
         updateMoonAngle();
         updatePerspective();
         onContrastChanged();
      }
      
      internal function __setProp_contrastSlider_Scene1_Layer1_0() : *
      {
         try
         {
            contrastSlider["componentInspectorSetting"] = true;
         }
         catch(e:Error)
         {
         }
         contrastSlider.direction = "horizontal";
         contrastSlider.enabled = true;
         contrastSlider.liveDragging = true;
         contrastSlider.maximum = 0.85;
         contrastSlider.minimum = 0.5;
         contrastSlider.snapInterval = 0.001;
         contrastSlider.tickInterval = 0;
         contrastSlider.value = 0.65;
         contrastSlider.visible = true;
         try
         {
            contrastSlider["componentInspectorSetting"] = false;
         }
         catch(e:Error)
         {
         }
      }
      
      public function onMouseDrag(... rest) : void
      {
         cancelSlew();
         thetaSlider.value = (scene.viewerTheta % 360 + 360) % 360;
         phiSlider.value = scene.viewerPhi;
      }
      
      internal function __setProp_shadowsCheckbox_Scene1_Layer1_0() : *
      {
         try
         {
            shadowsCheckbox["componentInspectorSetting"] = true;
         }
         catch(e:Error)
         {
         }
         shadowsCheckbox.enabled = true;
         shadowsCheckbox.label = "Step 3 - show shadows";
         shadowsCheckbox.labelPlacement = "right";
         shadowsCheckbox.selected = false;
         shadowsCheckbox.visible = true;
         try
         {
            shadowsCheckbox["componentInspectorSetting"] = false;
         }
         catch(e:Error)
         {
         }
      }
      
      public function cancelSlew() : void
      {
         if(slewTimer.running)
         {
            slewTimer.stop();
         }
         slewMode = "";
      }
      
      public function onEarthPerspectiveChoosen(... rest) : void
      {
         slewTo(180 + moonAngleSlider.value,0,"earth");
      }
      
      public function onOverheadPerspectiveChoosen(... rest) : void
      {
         slewTo(90 + sunAngleSlider.value,90,"overhead");
      }
      
      public function onContrastChanged(... rest) : void
      {
         earthBack.shadingAlpha = earth.shadingAlpha = moon.shadingAlpha = contrastSlider.value;
         earthBack.updateShading();
         earth.updateShading();
         moon.updateShading();
      }
      
      internal function __setProp_showMoonDiscCheckbox_Scene1_Layer1_0() : *
      {
         try
         {
            showMoonDiscCheckbox["componentInspectorSetting"] = true;
         }
         catch(e:Error)
         {
         }
         showMoonDiscCheckbox.enabled = true;
         showMoonDiscCheckbox.label = "Step 6 - determine Moon\'s phase";
         showMoonDiscCheckbox.labelPlacement = "right";
         showMoonDiscCheckbox.selected = false;
         showMoonDiscCheckbox.visible = true;
         try
         {
            showMoonDiscCheckbox["componentInspectorSetting"] = false;
         }
         catch(e:Error)
         {
         }
      }
      
      internal function __setProp_earthPerspectiveButton_Scene1_Layer10_0() : *
      {
         try
         {
            earthPerspectiveButton["componentInspectorSetting"] = true;
         }
         catch(e:Error)
         {
         }
         earthPerspectiveButton.emphasized = false;
         earthPerspectiveButton.enabled = true;
         earthPerspectiveButton.label = "earth";
         earthPerspectiveButton.labelPlacement = "right";
         earthPerspectiveButton.selected = false;
         earthPerspectiveButton.toggle = false;
         earthPerspectiveButton.visible = true;
         try
         {
            earthPerspectiveButton["componentInspectorSetting"] = false;
         }
         catch(e:Error)
         {
         }
      }
      
      public function updateMoonAngle(... rest) : void
      {
         earthPlanes.angle2 = moonAngleSlider.value - 90;
         moonPlanes.angle2 = moonAngleSlider.value - 90;
         orbitalPlane.passData({"moonAngle":moonAngleSlider.value});
         moon.worldX = moonDist * Math.cos(moonAngleSlider.value * Math.PI / 180);
         moon.worldY = moonDist * Math.sin(moonAngleSlider.value * Math.PI / 180);
         moon.worldZ = 0;
         moon.rotationAngle = moonAngleSlider.value;
         scene.update();
         updateDisc();
      }
      
      internal function frame1() : *
      {
         moonLayersData = [new GlobeLayer(5461076,0.1,[new GlobeLayerFill([new Point3D(-0.6473212114222926,0.7069223926739387,-0.2850192624699761),new Point3D(-0.6267275086840581,0.7384889774943195,-0.24868988716485474),new Point3D(-0.5572210564614738,0.8089455712098835,-0.1873813145857246),new Point3D(-0.4017617383441595,0.912640881163909,0.07532680552793272),new Point3D(-0.38616289600136045,0.9079798292083445,0.16263716519488358),new Point3D(-0.2812245001076185,0.9457599764404244,0.16263716519488358),new Point3D(-0.25093674694907686,0.9287238501987343,0.2729519355173252),new Point3D(-0.18659481489205637,0.9155069348549415,0.3564118787132507),new Point3D(-0.12392931105662008,0.8908262077454833,0.4371157666509329),new Point3D(-0.14777685629961157,0.831295162096316,0.5358267949789967),new Point3D(-0.15226737901745171,0.747083146567099,0.6470559615694442),new Point3D(-0.17615482691727394,0.6519538930617516,0.7375131173581738),new Point3D(-0.16319932238100324,0.5752011386805431,0.8015669848708765),new Point3D(-0.19847708468215478
         ,0.5203050058332827,0.8305958991958126),new Point3D(-0.2524661350530763,0.5194719226193737,0.8163392507171839),new Point3D(-0.3694213414967015,0.49525586713830566,0.7862884321366189),new Point3D(-0.46198133355632826,0.5174245414652744,0.7203090248879068),new Point3D(-0.5454115702739329,0.5663706538329693,0.6178596130903343),new Point3D(-0.6060035549610273,0.48863406178409685,0.6276913612907005),new Point3D(-0.6157250070025124,0.4356350090317296,0.6565857557529564),new Point3D(-0.5388149192097041,0.3914719535296229,0.7459411454241821),new Point3D(-0.5854737384874463,0.27550302891999506,0.7624425110114478),new Point3D(-0.5628601204729916,0.12953266970010338,0.8163392507171839),new Point3D(-0.6844930569669148,0.008602046235133661,0.7289686274214114),new Point3D(-0.7568653348962767,-0.14437978433703674,0.6374239897486896),new Point3D(-0.7591627327109552,-0.25725780162673967,0.5979049830575188),new Point3D(-0.7404456626019772,-0.32595815363539027,0.5877852522924731),new Point3D(-0.6725318117255824
         ,-0.3920516766679275,0.6276913612907005),new Point3D(-0.636436489860571,-0.48729685573471904,0.5979049830575188),new Point3D(-0.7235600863480249,-0.4720428711655166,0.5036232016357608),new Point3D(-0.7747780999277226,-0.505456956107076,0.37977909552180106),new Point3D(-0.7199128232715183,-0.5955636822383672,0.3564118787132507),new Point3D(-0.7019605014639609,-0.6759837869118238,0.22427076094938117),new Point3D(-0.6139122998800729,-0.7812650795019883,0.11285638487348168),new Point3D(-0.5665524638279504,-0.8224924402212636,0.05024431817976955),new Point3D(-0.4371157666509333,-0.8994052515663709,0),new Point3D(-0.443294848898608,-0.8836978835061686,-0.15022558912075706),new Point3D(-0.51899281089818,-0.8178018111119209,-0.24868988716485474),new Point3D(-0.6059617150443054,-0.7515132124566949,-0.26084150628989694),new Point3D(-0.6478439363685428,-0.7442092357716905,-0.16263716519488358),new Point3D(-0.8232725172085448,-0.5670897995133708,0.025130095443337476),new Point3D(-0.8878559658051174
         ,-0.459434720376324,-0.025130095443337476),new Point3D(-0.9459020787371688,-0.3205382441010011,0.05024431817976955),new Point3D(-0.9571704102087285,-0.27157380582997653,0.10036171485121488),new Point3D(-0.9836600588673243,-0.149467102672312,0.10036171485121488),new Point3D(-0.9946368007875459,0.025003214018186094,0.10036171485121488),new Point3D(-0.9999210442038161,1.2245096640526994e-16,-0.012566039883352606),new Point3D(-0.9876474259982325,0.1373988147256844,-0.07532680552793272),new Point3D(-0.9667259807947579,0.09751462691917438,-0.23649899702372468),new Point3D(-0.9382293926903468,0.09464014727067407,-0.3328195445229866),new Point3D(-0.892313172518443,0.11272536846353007,-0.4371157666509329),new Point3D(-0.854770408003096,0.16305617588111776,-0.4927273415482915),new Point3D(-0.8086395210664682,0.28540163113069134,-0.5144395337815064),new Point3D(-0.7449431209044527,0.39742847457079666,-0.5358267949789967),new Point3D(-0.7128896457825363,0.4524135262330098,-0.5358267949789967),new Point3D(-0.667321820134222
         ,0.6110593942057466,-0.42577929156507266)]),new GlobeLayerFill([new Point3D(-0.4708362421407444,-0.7848437023683725,0.40290643571366264),new Point3D(-0.5586399305096703,-0.7489272332825411,0.3564118787132507),new Point3D(-0.5919070131588396,-0.7340825829270797,0.3328195445229866),new Point3D(-0.6173981429700105,-0.7463061523792459,0.24868988716485474),new Point3D(-0.5275559518214132,-0.8312951620963157,0.17502305897527604),new Point3D(-0.45143943778015583,-0.8724051105769972,0.1873813145857246),new Point3D(-0.35655924292838925,-0.9005658478447123,0.24868988716485474),new Point3D(-0.36205085854631897,-0.8512855070013327,0.37977909552180106)]),new GlobeLayerFill([new Point3D(0.7747780999277222,-0.5054569561070765,0.37977909552180106),new Point3D(0.7276341333472689,-0.5286571427051149,0.4371157666509329),new Point3D(0.7294346666310382,-0.46291331574173994,0.5036232016357608),new Point3D(0.783594996665286,-0.40548327887253793,0.4707039321653325),new Point3D(0.803609885167597,-0.4158402906588855
         ,0.42577929156507266)]),new GlobeLayerFill([new Point3D(0.5531082716792535,-0.7415113474550689,-0.37977909552180106),new Point3D(0.5993602259402447,-0.7433260511882201,-0.2970415815770349),new Point3D(0.6073925169792364,-0.6977407605423885,-0.37977909552180106)]),new GlobeLayerFill([new Point3D(0.08613180303501393,0.9111792999001074,-0.40290643571366264),new Point3D(0.1523178186443154,0.9240806093039121,-0.35053432019125896),new Point3D(0.12634042329645287,0.9519464586794159,-0.2789911060392293),new Point3D(0.06051271044253072,0.9618219897526384,-0.26690198932037557),new Point3D(0.0060111595535294994,0.9566931668820093,-0.2910361668282718),new Point3D(0.011624557076262384,0.9250041666270609,-0.37977909552180106)]),new GlobeLayerFill([new Point3D(0.0062057880370627065,-0.987668844472891,0.15643446504023087),new Point3D(-0.09304034815669199,-0.9842640732995405,0.15022558912075706),new Point3D(-0.1280250819310179,-0.9646399797189561,0.23038942667659057),new Point3D(-0.15529646270269773,-0.9421514249239573
         ,0.2970415815770349),new Point3D(-0.07710827427440434,-0.9419121668747743,0.32688802965494246),new Point3D(-0.0121310241762355,-0.9653054163573584,0.26084150628989694),new Point3D(0.07962564544619849,-0.9726629852216471,0.21814324139654254)]),new GlobeLayerFill([new Point3D(-0.15022262379624207,-0.9886322295988943,-0.00628314396555895),new Point3D(-0.10630826135263347,-0.9914758826805306,0.07532680552793272),new Point3D(-0.03760019759856631,-0.9969036753813652,0.0690600257144058),new Point3D(0.031400839223791374,-0.9991909054825561,0.025130095443337476),new Point3D(0.018824633318138283,-0.9985595333634784,-0.05024431817976955),new Point3D(-0.031231742578352678,-0.9938101629786327,-0.1066111542752599),new Point3D(-0.11187539553999987,-0.9849744744354574,-0.1315643590922825),new Point3D(-0.15606097875006236,-0.9853302409648748,-0.0690600257144058)])]),new GlobeLayer(6842211,0.1,[new GlobeLayerFill([new Point3D(-0.6714726841851901,-0.09126405978838126,0.7353878607810158),new Point3D(-0.6140476226431911
         ,-0.04056971442518971,0.78822561199044),new Point3D(-0.5742789954581802,0.02889074683870114,0.8181497174250234),new Point3D(-0.5432803308263356,0.0582517319948171,0.8375280400421417),new Point3D(-0.5441169810381229,0.10556853133041487,0.8323412738406634),new Point3D(-0.5282255531745884,0.19959980366004168,0.8253106586929996),new Point3D(-0.49379400573728754,0.23998652999810918,0.8358073613682702),new Point3D(-0.439023275965518,0.2236935320248473,0.8701837546695257),new Point3D(-0.4297435605613234,0.17800561112700372,0.8852313113324551),new Point3D(-0.41277919862089074,0.12556931368987023,0.9021339593682028),new Point3D(-0.46508688871332265,0.08872006894015767,0.8808081149230036),new Point3D(-0.4623586242974365,0.002905123144822353,0.8866882557005564),new Point3D(-0.5017218026838656,-0.06819215386674794,0.8623369775573039),new Point3D(-0.5065610853149968,-0.13857943137232304,0.8509944817946918),new Point3D(-0.4758167427858983,-0.2577026130794492,0.840944582298169),new Point3D(-0.4545994235066374
         ,-0.3216361552850246,0.8305958991958126),new Point3D(-0.48429158056431576,-0.3756550564175725,0.7901550123756903),new Point3D(-0.5441382053255567,-0.3501357321206173,0.7624425110114478),new Point3D(-0.6760062176907119,-0.31035652205347297,0.668352020167793)]),new GlobeLayerFill([new Point3D(-0.11340057562358961,-0.5844845815195665,0.8034414001121275),new Point3D(-0.1469444673740857,-0.5371385070419414,0.8305958991958126),new Point3D(-0.0732924505917632,-0.49276425993407186,0.86707070116449),new Point3D(-0.04286960635557766,-0.5447099953131818,0.8375280400421417)]),new GlobeLayerFill([new Point3D(0.005676726102250148,-0.9034671304133439,0.4286197837751283),new Point3D(0.05567561623597812,-0.8849385789725972,0.46236775104099176),new Point3D(0.0861318030350131,-0.9111792999001074,0.40290643571366264)]),new GlobeLayerFill([new Point3D(-0.21525726571138573,-0.05096400567416704,0.9752266299092234),new Point3D(-0.17237946144193678,-0.04483723785974843,0.9840096256511397),new Point3D(-0.21598307303498315
         ,-0.07092808872193856,0.9738174974771289)]),new GlobeLayerFill([new Point3D(-0.4410473160539092,0.44662479783439685,0.7784623015670235),new Point3D(-0.3549658772556621,0.5294417519342954,0.7705132427757893),new Point3D(-0.3549658772556621,0.42908003708308057,0.8305958991958126),new Point3D(-0.41286164136542475,0.3415488534697654,0.844327925502015),new Point3D(-0.49007692899697614,0.2856898043477707,0.8235325976284275)]),new GlobeLayerFill([new Point3D(-0.8147693455315836,0.4479232381700471,0.3681245526846779),new Point3D(-0.841918289284639,0.3833294050456732,0.37977909552180106),new Point3D(-0.9071829895727277,0.2573910919464773,0.3328195445229866),new Point3D(-0.9367327901522388,0.2032134342868914,0.2850192624699761),new Point3D(-0.9642567212471345,0.2091844354322239,0.16263716519488358),new Point3D(-0.9653054163573584,0.26082091134109014,0.012566039883352606),new Point3D(-0.9465654483959265,0.205346516710049,-0.24868988716485474),new Point3D(-0.939630151975309,0.3184128735826702,-0.12533323356430423)
         ,new Point3D(-0.9098185494661206,0.4142447167440678,0.025130095443337476),new Point3D(-0.8371408513567616,0.47401733711650507,0.2729519355173252)])])];
         sunLinesCheckbox.addEventListener("change",updateShowSunLines);
         sunBisectorsCheckbox.addEventListener("change",updateSunBisectors);
         shadowsCheckbox.addEventListener("change",updateShowShadows);
         earthMoonLineCheckbox.addEventListener("change",updateShowEarthMoonLine);
         earthMoonBisectorsCheckbox.addEventListener("change",updateEarthMoonBisectors);
         showMoonDiscCheckbox.addEventListener("change",updateShowMoonDisc);
         contrastSlider.addEventListener("change",onContrastChanged);
         hideAllStepsButton.setStyle("textFormat",new TextFormat("Verdana",10,0));
         showAllStepsButton.setStyle("textFormat",new TextFormat("Verdana",10,0));
         hideAllStepsButton.setStyle("disabledTextFormat",new TextFormat("Verdana",10,8421504));
         showAllStepsButton.setStyle("disabledTextFormat",new TextFormat("Verdana",10,8421504));
         hideAllStepsButton.addEventListener(MouseEvent.CLICK,onHideAllSteps);
         showAllStepsButton.addEventListener(MouseEvent.CLICK,onShowAllSteps);
         titlebar.addEventListener("reset",reset);
         scene = new Scene3D();
         scene.x = 307;
         scene.y = 337;
         addChild(scene);
         earth = new Globe3D(scene);
         earth.radius = 0.4;
         earth.worldX = 0;
         earth.worldY = 0;
         earth.worldZ = 0;
         moonDist = 2.2;
         moon = new Globe3D(scene);
         moon.radius = 0.2;
         moon._baseColor = 10526880;
         moon._layersList = moonLayersData;
         earthPlanes = new BisectingPlanesForGlobe3D(earth);
         earthPlanes.angle1 = 10;
         earthPlanes.angle2 = 70;
         moonPlanes = new BisectingPlanesForGlobe3D(moon);
         moonPlanes.angle1 = 10;
         moonPlanes.angle2 = 70;
         orbitalPlane = new OrbitalPlane(earth,moon,MBDOrbitalPlane);
         earthBack = new Globe3D(scene);
         earthBack.radius = 0.4;
         earthBack.worldX = 0;
         earthBack.worldY = 0;
         earthBack.worldZ = 0;
         earthBack.earthBackHack = true;
         disc = new PhaseDisc({"radius":21});
         disc.x = 707;
         disc.y = 333;
         disc.lineAlpha = 0.3;
         addChild(disc);
         scene.addEventListener("postUpdate",onPostUpdate);
         scene.addEventListener("prePostUpdate",onPrePostUpdate);
         scene.addEventListener("mouseDrag",onMouseDrag);
         maxEarthAlpha = 1;
         maxEarthLineAlpha = 0;
         maxEarthPlanesAlpha1 = 0.5;
         maxEarthPlanesAlpha2 = 0.5;
         maxEarthPlanesLineAlpha1 = 0.8;
         maxEarthPlanesLineAlpha2 = 0.8;
         minEarthAlpha = 0.08;
         minEarthLineAlpha = 0.9;
         minEarthPlanesAlpha1 = 0.05;
         minEarthPlanesAlpha2 = 0.05;
         minEarthPlanesLineAlpha1 = 0.15;
         minEarthPlanesLineAlpha2 = 0.15;
         StyleManager.setStyle("disabledTextFormat",new TextFormat("Verdana",12,10066329));
         StyleManager.setStyle("textFormat",new TextFormat("Verdana",12,0));
         StyleManager.setStyle("embedFonts",true);
         StyleManager.setStyle("focusRectSkin",NAAP_focusRectSkin);
         earthPerspectiveButton.addEventListener(MouseEvent.CLICK,onEarthPerspectiveChoosen);
         overheadPerspectiveButton.addEventListener(MouseEvent.CLICK,onOverheadPerspectiveChoosen);
         earthPerspectiveButton.setStyle("textFormat",new TextFormat("Verdana",10,0));
         overheadPerspectiveButton.setStyle("textFormat",new TextFormat("Verdana",10,0));
         slewMode = "";
         slewEaser = new CubicEaser(0);
         slewTimer = new Timer(20);
         slewTimer.addEventListener(TimerEvent.TIMER,onSlewTimer);
         thetaSlider.setValueFormat("fixed digits",1);
         thetaSlider.setValueRange(0,360);
         thetaSlider.addEventListener("sliderChange",updatePerspective);
         thetaSlider.valueField.alpha = 0;
         phiSlider.setValueFormat("fixed digits",1);
         phiSlider.setValueRange(-90,90);
         phiSlider.addEventListener("sliderChange",updatePerspective);
         phiSlider.valueField.alpha = 0;
         moonAngleSlider.setValueFormat("fixed digits",1);
         moonAngleSlider.setValueRange(0,360);
         moonAngleSlider.addEventListener("sliderChange",updateMoonAngle);
         moonAngleSlider.valueField.alpha = 0;
         sunAngleSlider.setValueFormat("fixed digits",1);
         sunAngleSlider.setValueRange(0,360);
         sunAngleSlider.addEventListener("sliderChange",updateSunAngle);
         sunAngleSlider.valueField.alpha = 0;
         reset();
         setChildIndex(titlebar,numChildren - 1);
      }
      
      public function updateShowSunLines(... rest) : void
      {
         orbitalPlane.passData({"showSunLines":sunLinesCheckbox.selected});
         updateHideAllShowAllStepsButtons();
      }
      
      internal function __setProp_earthMoonLineCheckbox_Scene1_Layer1_0() : *
      {
         try
         {
            earthMoonLineCheckbox["componentInspectorSetting"] = true;
         }
         catch(e:Error)
         {
         }
         earthMoonLineCheckbox.enabled = true;
         earthMoonLineCheckbox.label = "Step 4 - show Earth-Moon line";
         earthMoonLineCheckbox.labelPlacement = "right";
         earthMoonLineCheckbox.selected = false;
         earthMoonLineCheckbox.visible = true;
         try
         {
            earthMoonLineCheckbox["componentInspectorSetting"] = false;
         }
         catch(e:Error)
         {
         }
      }
      
      public function onShowAllSteps(param1:MouseEvent) : void
      {
         sunLinesCheckbox.selected = true;
         sunBisectorsCheckbox.selected = true;
         shadowsCheckbox.selected = true;
         earthMoonLineCheckbox.selected = true;
         earthMoonBisectorsCheckbox.selected = true;
         showMoonDiscCheckbox.selected = true;
         updateShowSunLines();
         updateSunBisectors();
         updateShowShadows();
         updateShowEarthMoonLine();
         updateEarthMoonBisectors();
         updateShowMoonDisc();
      }
      
      public function slewTo(param1:Number, param2:Number, param3:String) : void
      {
         if(slewMode == param3)
         {
            return;
         }
         param1 = (param1 % 360 + 360) % 360;
         if(param2 > 90)
         {
            param2 = 90;
         }
         else if(param2 < -90)
         {
            param2 = -90;
         }
         var _loc4_:Number = (scene.viewerTheta % 360 + 360) % 360;
         var _loc5_:Number = scene.viewerPhi;
         var _loc6_:Number = param1 - _loc4_;
         var _loc7_:Number = param2 - _loc5_;
         if(Math.abs(_loc6_) < 0.01 && Math.abs(_loc7_) < 0.01)
         {
            return;
         }
         if(_loc6_ < -180)
         {
            param1 += 360;
         }
         else if(_loc6_ > 180)
         {
            param1 -= 360;
         }
         slewInitTime = getTimer();
         slewInitTheta = _loc4_;
         slewInitPhi = _loc5_;
         slewTargetTheta = param1;
         slewTargetPhi = param2;
         slewMode = param3;
         slewEaser.setTarget(0,0,1,1);
         if(!slewTimer.running)
         {
            slewTimer.start();
         }
      }
      
      public function updatePerspective(... rest) : void
      {
         cancelSlew();
         scene.setViewerThetaAndPhi(thetaSlider.value,phiSlider.value);
      }
      
      public function updateShowMoonDisc(... rest) : void
      {
         disc.visible = showMoonDiscCheckbox.selected;
         phaseNameField.visible = showMoonDiscCheckbox.selected;
         updateHideAllShowAllStepsButtons();
      }
      
      public function updateTransparency() : void
      {
         var _loc1_:Number = NaN;
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         if(moon.screenZ < 0)
         {
            _loc2_ = Math.sqrt(moon.screenX * moon.screenX + moon.screenY * moon.screenY);
            _loc3_ = scene.scale * (earth.radius - moon.radius);
            _loc4_ = scene.scale * (earth.radius + moon.radius);
            _loc1_ = (_loc2_ - _loc3_) / (_loc4_ - _loc3_);
            if(_loc1_ < 0)
            {
               _loc1_ = 0;
            }
            else if(_loc1_ > 1)
            {
               _loc1_ = 1;
            }
         }
         else
         {
            _loc1_ = 1;
         }
         earth.alpha = earthBack.alpha = minEarthAlpha + (maxEarthAlpha - minEarthAlpha) * _loc1_;
         earth.lineAlpha = earthBack.lineAlpha = minEarthLineAlpha + (maxEarthLineAlpha - minEarthLineAlpha) * _loc1_;
         earthPlanes.alpha1 = minEarthPlanesAlpha1 + (maxEarthPlanesAlpha1 - minEarthPlanesAlpha1) * _loc1_;
         earthPlanes.alpha2 = minEarthPlanesAlpha2 + (maxEarthPlanesAlpha2 - minEarthPlanesAlpha2) * _loc1_;
         earthPlanes.lineAlpha1 = minEarthPlanesLineAlpha1 + (maxEarthPlanesLineAlpha1 - minEarthPlanesLineAlpha1) * _loc1_;
         earthPlanes.lineAlpha2 = minEarthPlanesLineAlpha2 + (maxEarthPlanesLineAlpha2 - minEarthPlanesLineAlpha2) * _loc1_;
      }
      
      public function onPostUpdate(... rest) : void
      {
         if(scene._containerSP.getChildIndex(earth) < scene._containerSP.getChildIndex(earthBack))
         {
            scene._containerSP.swapChildren(earth,earthBack);
         }
      }
      
      public function updateSunAngle(... rest) : void
      {
         earthPlanes.angle1 = sunAngleSlider.value - 90;
         moonPlanes.angle1 = sunAngleSlider.value - 90;
         moon.setSunDirection(sunAngleSlider.value,0);
         earth.setSunDirection(sunAngleSlider.value,0);
         earthBack.setSunDirection(sunAngleSlider.value,0);
         orbitalPlane.passData({"sunAngle":sunAngleSlider.value});
         scene.update();
         updateDisc();
      }
      
      internal function __setProp_titlebar_Scene1_titlebar_0() : *
      {
         try
         {
            titlebar["componentInspectorSetting"] = true;
         }
         catch(e:Error)
         {
         }
         titlebar.aboutContent = "About";
         titlebar.enabled = true;
         titlebar.helpContent = "";
         titlebar.title = "Determining Moon Phases Using Bisectors";
         titlebar.visible = true;
         try
         {
            titlebar["componentInspectorSetting"] = false;
         }
         catch(e:Error)
         {
         }
      }
      
      internal function __setProp_showAllStepsButton_Scene1_Layer10_0() : *
      {
         try
         {
            showAllStepsButton["componentInspectorSetting"] = true;
         }
         catch(e:Error)
         {
         }
         showAllStepsButton.emphasized = false;
         showAllStepsButton.enabled = true;
         showAllStepsButton.label = "show all";
         showAllStepsButton.labelPlacement = "right";
         showAllStepsButton.selected = false;
         showAllStepsButton.toggle = false;
         showAllStepsButton.visible = true;
         try
         {
            showAllStepsButton["componentInspectorSetting"] = false;
         }
         catch(e:Error)
         {
         }
      }
      
      public function onHideAllSteps(param1:MouseEvent) : void
      {
         sunLinesCheckbox.selected = false;
         sunBisectorsCheckbox.selected = false;
         shadowsCheckbox.selected = false;
         earthMoonLineCheckbox.selected = false;
         earthMoonBisectorsCheckbox.selected = false;
         showMoonDiscCheckbox.selected = false;
         updateShowSunLines();
         updateSunBisectors();
         updateShowShadows();
         updateShowEarthMoonLine();
         updateEarthMoonBisectors();
         updateShowMoonDisc();
      }
      
      internal function __setProp_sunBisectorsCheckbox_Scene1_Layer1_0() : *
      {
         try
         {
            sunBisectorsCheckbox["componentInspectorSetting"] = true;
         }
         catch(e:Error)
         {
         }
         sunBisectorsCheckbox.enabled = true;
         sunBisectorsCheckbox.label = "Step 2 - show Sun bisectors";
         sunBisectorsCheckbox.labelPlacement = "right";
         sunBisectorsCheckbox.selected = false;
         sunBisectorsCheckbox.visible = true;
         try
         {
            sunBisectorsCheckbox["componentInspectorSetting"] = false;
         }
         catch(e:Error)
         {
         }
      }
      
      internal function __setProp_hideAllStepsButton_Scene1_Layer10_0() : *
      {
         try
         {
            hideAllStepsButton["componentInspectorSetting"] = true;
         }
         catch(e:Error)
         {
         }
         hideAllStepsButton.emphasized = false;
         hideAllStepsButton.enabled = true;
         hideAllStepsButton.label = "hide all";
         hideAllStepsButton.labelPlacement = "right";
         hideAllStepsButton.selected = false;
         hideAllStepsButton.toggle = false;
         hideAllStepsButton.visible = true;
         try
         {
            hideAllStepsButton["componentInspectorSetting"] = false;
         }
         catch(e:Error)
         {
         }
      }
      
      public function onPrePostUpdate(... rest) : void
      {
         updateTransparency();
      }
      
      public function updateDisc() : void
      {
         var _loc1_:Number = moonAngleSlider.value - sunAngleSlider.value;
         disc.phaseAngle = Math.PI - _loc1_ * Math.PI / 180;
         phaseNameField.text = getPhaseNameFromAngle(_loc1_);
      }
   }
}

