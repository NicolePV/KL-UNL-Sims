function CurvedTextClass()
{
}
var p = CurvedTextClass.prototype = new MovieClip();
Object.registerClass("CurvedText",CurvedTextClass);
p.getTextWidth = function(format, txt)
{
   if(System.capabilities.os.toLowerCase().indexOf("mac") != -1)
   {
      return 0.05 * format.getTextExtent(txt).width;
   }
   return format.getTextExtent(txt).width;
};
p.update = function(quickUpdate)
{
   var cos = Math.cos;
   var sin = Math.sin;
   var r = this.radius;
   if(!quickUpdate)
   {
      var mc = this.createEmptyMovieClip("curvedTextMC",1);
      var fontSource = this.fontSource;
      var spacingTest = mc.attachMovie(fontSource,"testLetter",-1,{_visible:false});
      var format = spacingTest.letterField.getTextFormat();
      this._spacingAngle = this.gap * this.getTextWidth(format," ") / r;
      var letters = this.text.split("");
      this.lettersMCList = [];
      var i = 0;
      while(i < letters.length)
      {
         var newLetter = mc.attachMovie(fontSource,"_" + i,i,{letter:letters[i]});
         newLetter.letterWidth = this.getTextWidth(format,letters[i]);
         this.lettersMCList.push(newLetter);
         i++;
      }
   }
   var spacingAngle = this._spacingAngle;
   var cursorAngle = 0;
   var i = 0;
   while(i < this.lettersMCList.length)
   {
      var letter = this.lettersMCList[i];
      var letterAngle = letter.letterWidth / r;
      var newAngle = cursorAngle + letterAngle / 2;
      letter._x = r * cos(newAngle);
      letter._y = r * sin(newAngle);
      letter._rotation = 90 + newAngle * 57.29577951308232;
      cursorAngle = cursorAngle + letterAngle + spacingAngle;
      i++;
   }
   cursorAngle -= spacingAngle;
   this.curvedTextMC._rotation = -90 - 57.29577951308232 * cursorAngle / 2;
};
p.doFlip = function()
{
   var i = 0;
   while(i < this.lettersMCList.length)
   {
      var letter = this.lettersMCList[i];
      letter._yscale = -100;
      i++;
   }
   this._yscale = -100;
};
