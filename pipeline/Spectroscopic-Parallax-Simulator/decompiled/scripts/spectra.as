function spectraClass()
{
   this._lineCount = 0;
   this._spectX = 0;
   this._spectY = 0;
   this.fillType = "linear";
   this.colors = [16711680,16753920,16776960,65280,65535,255,8388736];
   this.alphas = [100,100,100,100,100,100,100];
   var _loc2_ = this.spectPos(400);
   var _loc3_ = this.spectPos(445);
   var _loc4_ = this.spectPos(475);
   var _loc7_ = this.spectPos(510);
   var _loc8_ = this.spectPos(570);
   var _loc6_ = this.spectPos(590);
   var _loc5_ = this.spectPos(700);
   this.ratios = [_loc5_,_loc6_,_loc8_,_loc7_,_loc4_,_loc3_,_loc2_];
}
var p = spectraClass.prototype = new MovieClip();
Object.registerClass("spectra",spectraClass);
p.spectPos = function(wavelength)
{
   return 255 - (wavelength - 395) * 0.8225806451612904;
};
p.colorFromLength = function(wavelength)
{
   var _loc1_ = 0;
   if(wavelength < 430)
   {
      _loc1_ = 10485920;
   }
   else if(wavelength < 460)
   {
      _loc1_ = 255;
   }
   else if(wavelength < 495)
   {
      _loc1_ = 65535;
   }
   else if(wavelength < 540)
   {
      _loc1_ = 65280;
   }
   else if(wavelength < 580)
   {
      _loc1_ = 16776960;
   }
   else if(wavelength < 620)
   {
      _loc1_ = 16753920;
   }
   else
   {
      _loc1_ = 16711680;
   }
   return _loc1_;
};
p.xPos = function(wavelength)
{
   return this.spectPos(wavelength) * 1.9607843137254901 + this.spectX;
};
p.deleteSpectra = function()
{
   this.removeMovieClip("spectraBox");
};
p.createSpectra = function(xPost, yPost)
{
   this.spectX = xPost;
   this.spectY = yPost;
   this.matrix = {matrixType:"box",x:this.spectX,y:this.spectY,w:500,h:50,r:0};
   this.createEmptyMovieClip("spectraBox",1);
   this.createEmptyMovieClip("spectraBoxMask",2);
   this.spectraBoxMask.moveTo(this.spectX,this.spectY);
   this.spectraBoxMask.beginFill(16711680,10);
   this.spectraBoxMask.lineTo(this.spectX + 500,this.spectY);
   this.spectraBoxMask.lineTo(this.spectX + 500,this.spectY + 50);
   this.spectraBoxMask.lineTo(this.spectX,this.spectY + 50);
   this.spectraBoxMask.lineTo(this.spectX,this.spectY);
   this.spectraBoxMask.endFill();
   this.spectraBox.setMask(this.spectraBoxMask);
};
p.drawContinuous = function()
{
   this.spectraBox.moveTo(this.spectX,this.spectY);
   this.spectraBox.beginGradientFill(this.fillType,this.colors,this.alphas,this.ratios,this.matrix);
   this.spectraBox.lineTo(this.spectX + 500,this.spectY);
   this.spectraBox.lineTo(this.spectX + 500,this.spectY + 50);
   this.spectraBox.lineTo(this.spectX,this.spectY + 50);
   this.spectraBox.lineTo(this.spectX,this.spectY);
   this.spectraBox.endFill();
};
p.drawEmission = function()
{
   this.spectraBox.moveTo(this.spectX,this.spectY);
   this.spectraBox.beginFill(0,100);
   this.spectraBox.lineTo(this.spectX + 500,this.spectY);
   this.spectraBox.lineTo(this.spectX + 500,this.spectY + 50);
   this.spectraBox.lineTo(this.spectX,this.spectY + 50);
   this.spectraBox.lineTo(this.spectX,this.spectY);
   this.spectraBox.endFill();
};
p.drawColorLineAt = function(wavelength, lineNum, alpha, color)
{
   this.SpectraBox.createEmptyMovieClip("spectLine",lineNum);
   var _loc2_;
   if(wavelength == "red")
   {
      _loc2_ = 650;
   }
   else if(wavelength == "orange")
   {
      _loc2_ = 590;
   }
   else if(wavelength == "yellow")
   {
      _loc2_ = 570;
   }
   else if(wavelength == "green")
   {
      _loc2_ = 510;
   }
   else if(wavelength == "blue")
   {
      _loc2_ = 445;
   }
   else if(wavelength == "cyan")
   {
      _loc2_ = 475;
   }
   else if(wavelength == "purple")
   {
      _loc2_ = 400;
   }
   else if(wavelength >= 395 && wavelength <= 705)
   {
      _loc2_ = wavelength;
   }
   else if(wavelength < 400)
   {
      _loc2_ = 400;
   }
   else
   {
      _loc2_ = 700;
   }
   this.SpectraBox.spectLine.moveTo(this.xPos(_loc2_),this.spectY);
   this.SpectraBox.spectLine.lineStyle(this._parent.lineThickness,color,alpha);
   this.SpectraBox.spectLine.lineTo(this.xPos(_loc2_),this.spectY + 50);
};
p.drawColorSet = function(elementArray, alphaArray, colorArray)
{
   var _loc2_ = 1;
   i = 0;
   while(i < elementArray.length)
   {
      if(alphaArray[i] > 10)
      {
         _loc2_ = _loc2_ + 1;
         this.drawColorLineAt(parseInt(elementArray[i]),_loc2_,alphaArray[i],colorArray[i]);
      }
      i++;
   }
};
p.setX = function(arg)
{
   this._spectX = arg;
};
p.getX = function()
{
   return this._spectX;
};
p.setY = function(arg)
{
   this._spectY = arg;
};
p.getY = function()
{
   return this._spectY;
};
p.addProperty("spectX",p.getX,p.setX);
p.addProperty("spectY",p.getY,p.setY);
