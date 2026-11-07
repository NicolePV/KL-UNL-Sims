function FormulaPanelClass()
{
   var _loc3_ = new TextFormat("Verdana",20,0,false);
   this.G = 6.67e-11;
   var _loc4_ = this.G.toScientific(3,true).string + " m<sup>3</sup> kg<sup>-1</sup> s<sup>-2</sup>";
   var _loc2_ = this.displayText(_loc4_,{mc:this,depth:10,name:"gText1",x:0,y:0,vAlign:"bottom",hAlign:"left",embedFonts:true,textFormat:_loc3_});
   trace("test");
   trace(_loc2_);
}
var p = FormulaPanelClass.prototype = new MovieClip();
Object.registerClass("Formula Panel",FormulaPanelClass);
